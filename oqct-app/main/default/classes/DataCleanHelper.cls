/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-04   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class DataCleanHelper {

    public static void setDCConfigurationIdFromDCConfigurationName(List<OQCT_DaCl__Data_Clean__c> dataCleans){
        Set<String> dcConfigNames = new Set<String>();
        for (OQCT_DaCl__Data_Clean__c dataClean : dataCleans) {
            dcConfigNames.add(dataClean.OQCT_DaCl__DC_Configuration_Id__c);
        }
        Map<String, OQCT_DaCl__DC_Configuration__c> dcConfigName2dcConfig = new Map<String, OQCT_DaCl__DC_Configuration__c>();
        for(OQCT_DaCl__DC_Configuration__c dcConfig: DCConfigurationSelector.getDCConfigurationsByNames(dcConfigNames)){
            dcConfigName2dcConfig.put(dcConfig.Name, dcConfig);
        }
        for (OQCT_DaCl__Data_Clean__c dataClean : dataCleans) {
            if (dcConfigName2dcConfig.containsKey(dataClean.OQCT_DaCl__DC_Configuration_Id__c)) {
                dataClean.OQCT_DaCl__DC_Configuration__c = dcConfigName2dcConfig.get(dataClean.OQCT_DaCl__DC_Configuration_Id__c).Id;
                final String action = dcConfigName2dcConfig.get(dataClean.OQCT_DaCl__DC_Configuration_Id__c).OQCT_DaCl__Data_Clean_Action__c;
                if (!action.contains(Constants.PROCESS_MASK)) {
                    dataClean.OQCT_DaCl__Master_Record_Masking_Status__c = Constants.DC_STATUS_NOT_ELIGIBLE;
                }
                if (!action.contains(Constants.PROCESS_DELETE)) {
                    dataClean.OQCT_DaCl__Master_Record_Deletion_Status__c = Constants.DC_STATUS_NOT_ELIGIBLE;
                }
                if (!action.contains(Constants.PROCESS_ARCHIVE)) {
                    dataClean.OQCT_DaCl__Master_Record_Archive_Status__c = Constants.DC_STATUS_NOT_ELIGIBLE;
                }
                // if (!action.contains(Constants.PROCESS_CLONE)) {
                //     dataClean.OQCT_DaCl__Master_Record_Cloning_Status__c = Constants.DC_STATUS_NOT_ELIGIBLE;
                // }
                if (!action.contains(Constants.PROCESS_ROLLBACK) && !action.contains(Constants.PROCESS_ARCHIVE)) {
                    dataClean.OQCT_DaCl__Master_Record_Rollback_Status__c = Constants.DC_STATUS_NOT_ELIGIBLE;
                }
            } else {
                dataClean.OQCT_DaCl__DC_Configuration_Id__c.addError(Constants.DC_TRIGGER_ERROR_INVALID_DC_CONFIG_NAME);
            }
        }
    }

    public static List<OQCT_DaCl__DC_Configuration__c> getDCConfigurations(List<OQCT_DaCl__Data_Clean__c> dataCleans){
        Set<Id> dcConfigIds = new Set<Id>();
        for (OQCT_DaCl__Data_Clean__c dataClean : dataCleans) {
            dcConfigIds.add(dataClean.OQCT_DaCl__DC_Configuration__c);
        }
        return DCConfigurationSelector.getDCConfigurationsByIds(dcConfigIds);
    }

    public static List<OQCT_DaCl__DC_Configuration__c> removeDCConfigurationsWithAlreadyActiveJobs(List<OQCT_DaCl__DC_Configuration__c> dcConfigurations){
        Map<String, OQCT_DaCl__DC_Configuration__c> dcConfigName2dcConfig = new Map<String,OQCT_DaCl__DC_Configuration__c>();
        for (OQCT_DaCl__DC_Configuration__c dcConfiguration : dcConfigurations) {
            dcConfigName2dcConfig.put(DataCleanHelper.getInitialJobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c), dcConfiguration);
        }
        for (CronTrigger cronTrigger : CronTriggerSelector.getActiveCronTriggersByNames(dcConfigName2dcConfig.keySet())){
            dcConfigName2dcConfig.remove(cronTrigger.CronJobDetail.Name);
        }
        return dcConfigName2dcConfig.values();
    }

    @future
    public static void createDataCleanRelatedResults(Set<Id> dcConfigurationIds, Set<Id> dataCleanIds){
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getDataCleanDcConfigsByIds(dataCleanIds);
        Map<Id, Map<String, Boolean>> dcConfigId2relatedObjectName2deleteRecord = new Map<Id, Map<String, Boolean>>();
        for (OQCT_DaCl__Related_Object__c relatedObject : RelatedObjectSelector.getRelatedObjectNamesByDcConfigs(dcConfigurationIds)) {
            Map<String, Boolean> relatedObjectName2deleteRecord;
            if (!dcConfigId2relatedObjectName2deleteRecord.containsKey(relatedObject.OQCT_DaCl__DC_Configuration__c)) {
                relatedObjectName2deleteRecord = new Map<String, Boolean>{relatedObject.OQCT_DaCl__Related_Object_Name__c => relatedObject.OQCT_DaCl__Delete_Related_Records__c};
            } else {
                relatedObjectName2deleteRecord = dcConfigId2relatedObjectName2deleteRecord.get(relatedObject.OQCT_DaCl__DC_Configuration__c);
                relatedObjectName2deleteRecord.put(relatedObject.OQCT_DaCl__Related_Object_Name__c, relatedObject.OQCT_DaCl__Delete_Related_Records__c);
            }
            dcConfigId2relatedObjectName2deleteRecord.put(relatedObject.OQCT_DaCl__DC_Configuration__c, relatedObjectName2deleteRecord);
        }
        List<OQCT_DaCl__Data_Clean_Related_Result__c> dataCleanRelatedResults = new List<OQCT_DaCl__Data_Clean_Related_Result__c>();
        for (OQCT_DaCl__Data_Clean__c dataClean : dataCleans) {
            Map<String, Boolean> relatedObjectName2deleteRecord = dcConfigId2relatedObjectName2deleteRecord.get(dataClean.OQCT_DaCl__DC_Configuration__c);
            if (relatedObjectName2deleteRecord != null) {
                for (String relatedObjectName : relatedObjectName2deleteRecord.keySet()) {
                    OQCT_DaCl__Data_Clean_Related_Result__c dataCleanRelatedResult = new OQCT_DaCl__Data_Clean_Related_Result__c();
                    dataCleanRelatedResult.OQCT_DaCl__Data_Clean__c = dataClean.Id;
                    dataCleanRelatedResult.OQCT_DaCl__Related_Object_Name__c = relatedObjectName;
                    dataCleanRelatedResult.OQCT_DaCl__Delete_Related_Records__c = relatedObjectName2deleteRecord.get(relatedObjectName);
                    dataCleanRelatedResults.add(dataCleanRelatedResult);
                }
            }
        }
        DatabaseUtils.insertRecords(dataCleanRelatedResults);
    }

    public static List<OQCT_DaCl__DC_Configuration__c> updateDCConfigurationProcessDates(List<OQCT_DaCl__DC_Configuration__c> dcConfigurations){

        for (OQCT_DaCl__DC_Configuration__c dcConfiguration : dcConfigurations) {
            Integer processStartAfter = (Integer)dcConfiguration.OQCT_DaCl__Data_Clean_Process_Start_After__c;
            dcConfiguration.OQCT_DaCl__Process_Scheduled_Date_Time_Next__c = DateUtils.shiftNowDate(processStartAfter, dcConfiguration.OQCT_DaCl__Data_Clean_Process_Start_Unit__c, dcConfiguration.OQCT_DaCl__Data_Clean_Process_Start_Time__c);
            dcConfiguration.OQCT_DaCl__Process_Scheduled_Date_Time_Init__c = dcConfiguration.OQCT_DaCl__Process_Scheduled_Date_Time_Next__c;
        }
        DatabaseUtils.updateRecords(dcConfigurations);
        return dcConfigurations;
    }
    
    public static void scheduleJob(List<OQCT_DaCl__DC_Configuration__c> dcConfigurations){
        for (OQCT_DaCl__DC_Configuration__c dcConfiguration : dcConfigurations) {
            if (dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_MASKING_ONLY || 
                dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_MASKING_DELETION ||
                dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_MASKING_ROLLBACK || 
                dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_MASKING_ROLLBACK_DELETION
                ) {
                DataCleanHelper.scheduleMaskJob(dcConfiguration);
            } else if (dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_DELETION_ONLY ||
                dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_DELETION_ROLLBACK
                ){
                    DataCleanHelper.scheduleDeleteJob(dcConfiguration);
            } else if (dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_ARCHIVE_DELETION ||
                    dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_ARCHIVE_ROLLBACK
                ){
                    DataCleanHelper.scheduleArchiveJob(dcConfiguration);
            }
            // else if (dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_CLONING
            //     ){
            //         DataCleanHelper.scheduleCloneJob(dcConfiguration);
            // }
        }
    }

    private static void scheduleMaskJob(OQCT_DaCl__DC_Configuration__c dcConfiguration){
        String jobName = DataCleanHelper.getInitialJobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c);
        String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(dcConfiguration.OQCT_DaCl__Process_Scheduled_Date_Time_Next__c,
                                                                            dcConfiguration.OQCT_DaCl__Retry_Masking_After__c,
                                                                            dcConfiguration.OQCT_DaCl__Retry_Masking_Unit__c);
        DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrap.dataConfigurationId = dcConfiguration.Id;
        scheduleWrap.batchType  = Constants.BATCH_TYPE.BATCH_MASK;
        Id scheduleJobId = System.Schedule(jobName, cronString, new DataCleanSchedulable(scheduleWrap));
        DataCleanHelper.updateDcConfigAndCreateResult(dcConfiguration, scheduleJobId, Constants.PROCESS_MASK);
    }

    private static void scheduleDeleteJob(OQCT_DaCl__DC_Configuration__c dcConfiguration){
        String jobName = DataCleanHelper.getInitialJobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c);
        String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(dcConfiguration.OQCT_DaCl__Process_Scheduled_Date_Time_Next__c,
                                                                            dcConfiguration.OQCT_DaCl__Retry_Deletion_After__c,
                                                                            dcConfiguration.OQCT_DaCl__Retry_Deletion_Unit__c);
        DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrap.dataConfigurationId = dcConfiguration.Id;
        scheduleWrap.batchType  = Constants.BATCH_TYPE.BATCH_DELETE;
        Id scheduleJobId = System.Schedule(jobName, cronString, new DataCleanSchedulable(scheduleWrap));
        DataCleanHelper.updateDcConfigAndCreateResult(dcConfiguration, scheduleJobId, Constants.PROCESS_DELETE);
    }

    private static void scheduleArchiveJob(OQCT_DaCl__DC_Configuration__c dcConfiguration){
        String jobName = DataCleanHelper.getInitialJobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c);
        String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(dcConfiguration.OQCT_DaCl__Process_Scheduled_Date_Time_Next__c,
                                                                            dcConfiguration.OQCT_DaCl__Retry_Archive_After__c,
                                                                            dcConfiguration.OQCT_DaCl__Retry_Archive_Unit__c);
        DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrap.dataConfigurationId = dcConfiguration.Id;
        scheduleWrap.batchType  = Constants.BATCH_TYPE.BATCH_ARCHIVE;
        Id scheduleJobId = System.Schedule(jobName, cronString, new DataCleanSchedulable(scheduleWrap));
        DataCleanHelper.updateDcConfigAndCreateResult(dcConfiguration, scheduleJobId, Constants.PROCESS_ARCHIVE);
    }

    // private static void scheduleCloneJob(OQCT_DaCl__DC_Configuration__c dcConfiguration){
    //     String jobName = DataCleanHelper.getInitialJobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c);
    //     String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(dcConfiguration.OQCT_DaCl__Process_Scheduled_Date_Time_Next__c,
    //                                                                         dcConfiguration.OQCT_DaCl__Retry_Cloning_After__c,
    //                                                                         dcConfiguration.OQCT_DaCl__Retry_Cloning_Unit__c);
    //     DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
    //     scheduleWrap.dataConfigurationId = dcConfiguration.Id;
    //     scheduleWrap.batchType  = Constants.BATCH_TYPE.BATCH_CLONE;
    //     Id scheduleJobId = System.Schedule(jobName, cronString, new DataCleanSchedulable(scheduleWrap));
    //     DataCleanHelper.updateDcConfigAndCreateResult(dcConfiguration, scheduleJobId, Constants.PROCESS_CLONE);
    // }

    public static String getInitialJobName(String dcConfigName, String dcConfigActionName){
        if (dcConfigActionName == Constants.DC_ACTION_MASKING_ONLY || 
            dcConfigActionName == Constants.DC_ACTION_MASKING_DELETION ||
            dcConfigActionName == Constants.DC_ACTION_MASKING_ROLLBACK || 
            dcConfigActionName == Constants.DC_ACTION_MASKING_ROLLBACK_DELETION
            ) {
            return dcConfigName + Constants.JOB_SUFFIX_MASK;
        } else if (dcConfigActionName == Constants.DC_ACTION_DELETION_ONLY ||
            dcConfigActionName == Constants.DC_ACTION_DELETION_ROLLBACK
            ){
                return dcConfigName + Constants.JOB_SUFFIX_DELETE;
        } else if (dcConfigActionName == Constants.DC_ACTION_ARCHIVE_DELETION ||
                dcConfigActionName == Constants.DC_ACTION_ARCHIVE_ROLLBACK
            ){
                return dcConfigName + Constants.JOB_SUFFIX_ARCHIVE;
        }
        // else if (dcConfigActionName == Constants.DC_ACTION_CLONING
        //     ){
        //         return dcConfigName + Constants.JOB_SUFFIX_CLONE;
        // }
        else {
            return dcConfigName + Constants.JOB_SUFFIX_GENERIC;
        }
    }

    private static void updateDcConfigAndCreateResult(OQCT_DaCl__DC_Configuration__c dcConfiguration, Id scheduleJobId, String processName){
        dcConfiguration.OQCT_DaCl__Job_Id__c = scheduleJobId;
        dcConfiguration.OQCT_DaCl__Job_Submit_Date__c = DateUtils.getNow();
        DatabaseUtils.updateRecords(dcConfiguration);

        OQCT_DaCl__DC_Result__c dcResult = new OQCT_DaCl__DC_Result__c();
        dcResult.OQCT_DaCl__DC_Configuration__c = dcConfiguration.Id;
        dcResult.OQCT_DaCl__Job_Schedule_Date__c = dcConfiguration.OQCT_DaCl__Process_Scheduled_Date_Time_Next__c;
        dcResult.OQCT_DaCl__Process__c = processName;
        dcResult.OQCT_DaCl__Job_Name__c = DataCleanHelper.getInitialJobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c);
        dcResult.OQCT_DaCl__Attempt_No__c = 1;
        DatabaseUtils.insertRecords(dcResult);
        DataCleanHelper.createDcRelatedResults(dcResult, dcConfiguration.Id);
    }

    public static void createDcRelatedResults(OQCT_DaCl__DC_Result__c dcResult, Id dcConfigurationId){
        List<OQCT_DaCl__DC_Related_Result__c> dcRelatedResults = new List<OQCT_DaCl__DC_Related_Result__c>();
        for (OQCT_DaCl__Related_Object__c relatedObject : RelatedObjectSelector.getRelatedObjectNamesByDcConfigId(dcConfigurationId)) {
            OQCT_DaCl__DC_Related_Result__c dcRelatedResult = new OQCT_DaCl__DC_Related_Result__c();
            dcRelatedResult.OQCT_DaCl__DC_Result__c = dcResult.Id;
            dcRelatedResult.OQCT_DaCl__Related_Object_Name__c = relatedObject.OQCT_DaCl__Related_Object_Name__c;
            if (dcResult.OQCT_DaCl__Process__c == Constants.PROCESS_MASK && relatedObject.OQCT_DaCl__Delete_Related_Records__c) {
                dcRelatedResult.OQCT_DaCl__Process__c = Constants.PROCESS_DELETE;
            } else {
                dcRelatedResult.OQCT_DaCl__Process__c = dcResult.OQCT_DaCl__Process__c;
            }
            dcRelatedResults.add(dcRelatedResult);
        }
        DatabaseUtils.insertRecords(dcRelatedResults);
    }
}