/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-08   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.ExcessivePublicCount,PMD.ExcessiveClassLength')
public with sharing class DataCleanBatchHelper {

    public static RecordTypeAndFieldWrapper getRecordsTypeAndFieldInfo(OQCT_DaCl__DC_Configuration__c dcConfig, ProcessInformation processInfo){
        String processName = processInfo.isParent? processInfo.processName : processInfo.relatedProcessName;
        return DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, processName, processInfo.objectName, processInfo.isParent);
    }

    public static Boolean isProcess2(OQCT_DaCl__DC_Configuration__c dcConfig, String parentProcessName){
        return (parentProcessName == Constants.PROCESS_DELETE && dcConfig.OQCT_DaCl__Data_Clean_Action__c.endsWith(Constants.PROCESS_DELETE));
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static RecordTypeAndFieldWrapper getRecordsTypeAndFieldInfo(OQCT_DaCl__DC_Configuration__c dcConfig, String processName, String objectName, Boolean isParent){
        RecordTypeAndFieldWrapper recordTypeAndFieldWrap = new RecordTypeAndFieldWrapper();
        Map<String, FieldToMaskAndEmptyWrapper> recordTypesAndFields = new Map<String, FieldToMaskAndEmptyWrapper>();
        Set<String> fieldsToQuery = new Set<String>();
        if (processName == Constants.PROCESS_MASK) {
            List<OQCT_DaCl__Record_Type_Field__c> recordTypeAndFields;
            if (isParent) {
                recordTypeAndFields = RecordTypeAndFieldSelector.getRecordTypeAndFieldForParentByDcConfigId(dcConfig.Id);
            } else {
                recordTypeAndFields = RecordTypeAndFieldSelector.getRecordTypeAndFieldForChildByDcConfigIdAndRelatedObjectName(dcConfig.Id, objectName);
            }
            for (OQCT_DaCl__Record_Type_Field__c recordTypeAndField : recordTypeAndFields) {
                FieldToMaskAndEmptyWrapper fieldMaskAndEmptyWrap = new FieldToMaskAndEmptyWrapper();
                String fieldsToEmpty = recordTypeAndField.OQCT_DaCl__Fields_to_Empty__c == null ? '' : recordTypeAndField.OQCT_DaCl__Fields_to_Empty__c;
                String fieldsToMask = recordTypeAndField.OQCT_DaCl__Fields_To_Mask__c == null ? '' : recordTypeAndField.OQCT_DaCl__Fields_To_Mask__c;
                fieldMaskAndEmptyWrap.fieldsToEmpty = fieldsToEmpty.split(Constants.LITERAL_COMMA_SEPARATOR);
                fieldMaskAndEmptyWrap.fieldsToMask = fieldsToMask.split(Constants.LITERAL_COMMA_SEPARATOR);
                recordTypesAndFields.put(recordTypeAndField.OQCT_DaCl__Record_Type_Id__c, fieldMaskAndEmptyWrap);
                fieldsToQuery.addAll(fieldMaskAndEmptyWrap.fieldsToEmpty);
                fieldsToQuery.addAll(fieldMaskAndEmptyWrap.fieldsToMask);
            }
            fieldsToQuery.add(Constants.FIELD_RECORD_TYPE_ID);
        } else if (processName == Constants.PROCESS_DELETE || processName == Constants.PROCESS_ARCHIVE) {
            recordTypeAndFieldWrap.fieldsToBackup = Utils.getFieldsForBackup(objectName);
            fieldsToQuery.addAll(recordTypeAndFieldWrap.fieldsToBackup);
        }
        // else if (processName == Constants.PROCESS_CLONE){
            // !Todo: Planned for next version
        // }
        
        if (isParent) {
            fieldsToQuery.add(dcConfig.OQCT_DaCl__Master_Object_Match_By_Field_Name__c);
        } else {
            Schema.DescribeSObjectResult sObjectDescribe = Utils.getSObjectDescription(dcConfig.OQCT_DaCl__Master_Object_Name__c);
            fieldsToQuery.addAll(Utils.getLookupFieldNames(sObjectDescribe, objectName));
        }
        recordTypeAndFieldWrap.fieldsToQuery = Utils.filterFieldsForSObject(objectName, fieldsToQuery);
        recordTypeAndFieldWrap.recordTypesAndFields = recordTypesAndFields;
        return recordTypeAndFieldWrap;
    }

    public static ProcessInformation updateProcessInformation(ProcessInformation processInfo, OQCT_DaCl__DC_Configuration__c dcConfig, List<String> processedRelatedObjects){
        processInfo = (processInfo == null) ? new ProcessInformation() : processInfo;
        if (!processInfo.isParent) {
            List<OQCT_DaCl__Related_Object__c> remainingRelatedObjects = DataCleanBatchHelper.getRemainingRelatedObjects(dcConfig.Id, processedRelatedObjects);
            if (remainingRelatedObjects.isEmpty()) {
                processInfo.objectName = dcConfig.OQCT_DaCl__Master_Object_Name__c;
                processInfo.isParent = true;
            } else {
                processInfo.objectName = remainingRelatedObjects[0].OQCT_DaCl__Related_Object_Name__c;
                processInfo.isParent = false;
                if (remainingRelatedObjects[0].OQCT_DaCl__Delete_Related_Records__c) {
                    processInfo.relatedProcessName = Constants.PROCESS_DELETE;
                } else {
                    processInfo.relatedProcessName = processInfo.processName;
                }
            }
        } else {
            processInfo.objectName = dcConfig.OQCT_DaCl__Master_Object_Name__c;
        }
        return processInfo;
    }

    public static List<OQCT_DaCl__Related_Object__c> getRemainingRelatedObjects(Id dcConfigId, List<String> processedRelatedObjects){
        return RelatedObjectSelector.getRelatedObjectsByDcConfigIdAndRelatedObjectNamesExcluded(dcConfigId, processedRelatedObjects);
    }

    public static BackupFiles getBackupFileNames(Id dcConfigId, Set<Id> dcResultIds, Set<Id> dataCleanIds){
        BackupFiles backupFiles = new BackupFiles();
        backupFiles.parentBackupFiles = new List<String>();
        backupFiles.childBackupFiles = new List<String>();
        if (dcResultIds == null && dataCleanIds == null) {
            for(OQCT_DaCl__DC_Result__c dcResult: DCResultSelector.getDCResultsBackupFileNamesBydcConfigIds(dcConfigId)){
                String parentBackupFileNames = dcResult.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c == null ? '' : dcResult.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c;
                String childBackupFileNames = dcResult.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c == null ? '' : dcResult.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c;
                if (!String.isBlank(parentBackupFileNames)) {
                    backupFiles.parentBackupFiles.addAll(parentBackupFileNames.split(Constants.LITERAL_COMMA_SEPARATOR));
                }
                if (!String.isBlank(childBackupFileNames)) {
                    backupFiles.childBackupFiles.addAll(childBackupFileNames.split(Constants.LITERAL_COMMA_SEPARATOR));
                }
            }
        } else if (dcResultIds != null) {
            for(OQCT_DaCl__DC_Result__c dcResult: DCResultSelector.getDCResultsBackupFileNamesByIds(dcResultIds)){
                String parentBackupFileNames = dcResult.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c == null ? '' : dcResult.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c;
                String childBackupFileNames = dcResult.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c == null ? '' : dcResult.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c;
                if (!String.isBlank(parentBackupFileNames)) {
                    backupFiles.parentBackupFiles.addAll(parentBackupFileNames.split(Constants.LITERAL_COMMA_SEPARATOR));
                }
                if (!String.isBlank(childBackupFileNames)) {
                    backupFiles.childBackupFiles.addAll(childBackupFileNames.split(Constants.LITERAL_COMMA_SEPARATOR));
                }
            }
        } else {
            List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getDataCleanBackupFileNamesByIds(dataCleanIds);
            for(OQCT_DaCl__Data_Clean__c dataClean: dataCleans){
                String parentBackupFileNames = dataClean.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c == null ? '' : dataClean.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c;
                String childBackupFileNames = dataClean.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c == null ? '' : dataClean.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c;
                if (!String.isBlank(parentBackupFileNames)) {
                    backupFiles.parentBackupFiles.addAll(parentBackupFileNames.split(Constants.LITERAL_COMMA_SEPARATOR));
                }
                if (!String.isBlank(childBackupFileNames)) {
                    backupFiles.childBackupFiles.addAll(childBackupFileNames.split(Constants.LITERAL_COMMA_SEPARATOR));
                }
            }
        }
        return backupFiles;
    }

    public static List<ReportUtil.BackupReportContent> getBackupReportContents(String backupFileName){
        return (List<ReportUtil.BackupReportContent>)JSON.deserialize(ContentVersionSelector.getContentVersionVersionDataByPathOnClient(backupFileName).VersionData.toString(), List<ReportUtil.BackupReportContent>.class);
    }

    public static ProcessInformation initProcessInformation(OQCT_DaCl__DC_Configuration__c dcConfig, Constants.BATCH_TYPE batchType){
        ProcessInformation processInfo = new ProcessInformation();
        processInfo.dcConfigName = dcConfig.Name;
        processInfo.dcConfigId = dcConfig.Id;
        processInfo.childObjectsProcessingInSeparateChildBatch = new Set<String>();
        if (RelatedObjectSelector.getRelatedObjectsByDcConfigIdCount(dcConfig.Id) == 0) {
            processInfo.isParent = true;
        }
        switch on batchType {
            when  BATCH_MASK {
                processInfo.processName = Constants.PROCESS_MASK;
            }
            when  BATCH_DELETE {
                processInfo.processName = Constants.PROCESS_DELETE;
            }
            when  BATCH_ARCHIVE {
                processInfo.processName = Constants.PROCESS_ARCHIVE;
            }
            when  BATCH_LARGE_RELATED_MASK {
                processInfo.processName = Constants.PROCESS_MASK;
            }
            when  BATCH_LARGE_RELATED_DELETE {
                processInfo.processName = Constants.PROCESS_DELETE;
            }
            when  BATCH_LARGE_RELATED_ARCHIVE {
                processInfo.processName = Constants.PROCESS_ARCHIVE;
            }
            // when  BATCH_CLONE {
            //     processInfo.processName = Constants.PROCESS_CLONE;
            // }
            when  BATCH_ROLLBACK {
                processInfo.isParent = true;
                processInfo.processName = Constants.PROCESS_ROLLBACK;
                processInfo.relatedProcessName = Constants.PROCESS_ROLLBACK;
            }
        }
        OQCT_DaCl__DC_Result__c result = DCResultSelector.getLatestDCResultByDcConfigIdAndProcessName(dcConfig.Id,  processInfo.processName);
        processInfo.resultId = result.Id;
        processInfo.resultName = result.Name;
        return processInfo;
    }

    public static Object getBatchParams(Id dcConfigId, Constants.BATCH_TYPE batchType){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(dcConfigId);
        switch on batchType {
            when  BATCH_MASK {
                DataCleanMaskBatch.DataCleanMaskBatchParameters dcMaskBatchParams = new DataCleanMaskBatch.DataCleanMaskBatchParameters();
                dcMaskBatchParams.processInfo = DataCleanBatchHelper.initProcessInformation(dcConfig, batchType);
                dcMaskBatchParams.processedRelatedObjects = new List<String>();
                return dcMaskBatchParams;
            }
            when  BATCH_DELETE {
                DataCleanDeleteBatch.DataCleanDeleteBatchParameters dcDeleteBatchParams = new DataCleanDeleteBatch.DataCleanDeleteBatchParameters();
                dcDeleteBatchParams.processInfo = DataCleanBatchHelper.initProcessInformation(dcConfig, batchType);
                dcDeleteBatchParams.processedRelatedObjects = new List<String>();
                return dcDeleteBatchParams;
            }
            when  BATCH_ARCHIVE {
                DataCleanArchiveBatch.DataCleanArchiveBatchParameters dcArchiveBatchParams = new DataCleanArchiveBatch.DataCleanArchiveBatchParameters();
                dcArchiveBatchParams.processInfo = DataCleanBatchHelper.initProcessInformation(dcConfig, batchType);
                dcArchiveBatchParams.processedRelatedObjects = new List<String>();
                return dcArchiveBatchParams;
            }
            // when  BATCH_LARGE_RELATED_MASK {
                
            // }
            // when  BATCH_LARGE_RELATED_DELETE {
                
            // }
            // when  BATCH_LARGE_RELATED_ARCHIVE {
                
            // }
            // when  BATCH_CLONE {
                
            // }
            when  BATCH_ROLLBACK {
                DataCleanRollbackBatch.DataCleanRollbackBatchParameters dcRollbackBatchParams = new DataCleanRollbackBatch.DataCleanRollbackBatchParameters();
                dcRollbackBatchParams.processInfo = DataCleanBatchHelper.initProcessInformation(dcConfig, batchType);
                return dcRollbackBatchParams;
            }
        }
        return null;
    }

    public static void onBatchStart(ProcessInformation processInfo){
        DataCleanBatchHelper.updateDcResult(Constants.BATCH_METHOD.BATCH_START, processInfo);
    }

    public static void onBatchExceuteStart(Set<Id> dataCleanIds, ProcessInformation processInfo){
        DataCleanBatchHelper.updateDcResult(Constants.BATCH_METHOD.BATCH_EXECUTE_START, processInfo);
        if (processInfo.isParent) {
            DataCleanBatchHelper.onBatchExceuteStartForParent(dataCleanIds, processInfo);
        } else {
            DataCleanBatchHelper.onBatchExceuteStartForChild(dataCleanIds, processInfo);
        }
    }

    private static void onBatchExceuteStartForParent(Set<Id> dataCleanIds, ProcessInformation processInfo){
        List<OQCT_DaCl__Data_Clean__c> dataCleans = new List<OQCT_DaCl__Data_Clean__c>();
        for (Id dataCleanId : dataCleanIds) {
            OQCT_DaCl__Data_Clean__c dataClean = new OQCT_DaCl__Data_Clean__c(Id = dataCleanId);
            if (processInfo.processName == Constants.PROCESS_MASK) {
                dataClean.OQCT_DaCl__Is_Parent_Masking_Completed__c = false;
                dataClean.OQCT_DaCl__Master_Record_Masking_Status__c = Constants.DC_STATUS_PENDING;
                dataClean.OQCT_DaCl__Master_Record_Masking_Error_Message__c = Constants.LITERAL_EMPTY;
            } else if (processInfo.processName == Constants.PROCESS_DELETE) {
                dataClean.OQCT_DaCl__Is_Parent_Deletion_Completed__c = false;
                dataClean.OQCT_DaCl__Master_Record_Deletion_Status__c = Constants.DC_STATUS_PENDING;
                dataClean.OQCT_DaCl__Master_Record_Delete_Error_Message__c = Constants.LITERAL_EMPTY;
            } else if (processInfo.processName == Constants.PROCESS_ARCHIVE) {
                dataClean.OQCT_DaCl__Is_Parent_Archive_Completed__c = false;
                dataClean.OQCT_DaCl__Master_Record_Archive_Status__c = Constants.DC_STATUS_PENDING;
                dataClean.OQCT_DaCl__Master_Record_Archive_Error_Message__c = Constants.LITERAL_EMPTY;
            }
            // else if (processInfo.processName == Constants.PROCESS_CLONE) {
            //     dataClean.OQCT_DaCl__Is_Parent_Cloning_Completed__c = false;
            //     dataClean.OQCT_DaCl__Master_Record_Cloning_Status__c = Constants.DC_STATUS_PENDING;
            //     dataClean.OQCT_DaCl__Master_Record_Cloning_Error_Message__c = Constants.LITERAL_EMPTY;
            // }
            else if (processInfo.processName == Constants.PROCESS_ROLLBACK) {
                dataClean.OQCT_DaCl__Is_Parent_Rollback_Completed__c = false;
                dataClean.OQCT_DaCl__Master_Record_Rollback_Status__c = Constants.DC_STATUS_PENDING;
                dataClean.OQCT_DaCl__Master_Record_Rollback_Error_Message__c = Constants.LITERAL_EMPTY;
            }
            dataCleans.add(dataClean);
        }
        DatabaseUtils.updateRecords(dataCleans);
    }

    private static void onBatchExceuteStartForChild(Set<Id> dataCleanIds, ProcessInformation processInfo){
        List<OQCT_DaCl__Data_Clean_Related_Result__c> dataCleanRelatedResults = DataCleanRelatedResultSelector.getDataCleanResultsByDataCleanIdsAndObjectName(dataCleanIds, processInfo.objectName);
        for (OQCT_DaCl__Data_Clean_Related_Result__c dataCleanRelatedResult : dataCleanRelatedResults) {
            if (processInfo.relatedProcessName == Constants.PROCESS_MASK) {
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Masking_Completed__c = false;
            } else if (processInfo.relatedProcessName == Constants.PROCESS_DELETE) {
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Deletion_Completed__c = false;
            } else if (processInfo.relatedProcessName == Constants.PROCESS_ARCHIVE) {
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Archive_Completed__c = false;
            }
            // else if (processInfo.relatedProcessName == Constants.PROCESS_CLONE) {
            //     dataCleanRelatedResult.OQCT_DaCl__Is_Related_Cloning_Completed__c = false;
            // }
            else if (processInfo.relatedProcessName == Constants.PROCESS_ROLLBACK) {
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Rollback_Completed__c = false;
            }
        }
        DatabaseUtils.updateRecords(dataCleanRelatedResults);
    }

    @SuppressWarnings('PMD.CognitiveComplexity,PMD.NcssMethodCount,PMD.ExcessiveParameterList')
    public static void onBatchExceuteEnd(DatabaseUtils.DMLResult dmlResults, Map<Id, RecordWrapper> recordId2RecordWrapper, Set<Id> dataCleanIds, ProcessInformation processInfo){
        Map<Id, Map<Id, String>> dataCleanId2errorRecordId2ErrorMessage = new Map<Id, Map<Id, String>>();
        Map<Id, List<Id>> dataCleanId2successRecordIds = new Map<Id, List<Id>>();
        Map<Id, SuccessFailureCount> dataCleanId2successFailureCount = new Map<Id, SuccessFailureCount>();
        for (Id recordId : recordId2RecordWrapper.keySet()) {
            final Id dataCleanId = recordId2RecordWrapper.get(recordId).dataCleanId;
            if (dmlResults.successIds.contains(recordId)) {
                if (!dataCleanId2successRecordIds.containsKey(dataCleanId)) {
                    dataCleanId2successRecordIds.put(dataCleanId, new List<Id>{recordId});
                } else {
                    List<Id> successRecordIds = dataCleanId2successRecordIds.get(dataCleanId);
                    successRecordIds.add(recordId);
                    dataCleanId2successRecordIds.put(dataCleanId, successRecordIds);
                }

                if (!dataCleanId2successFailureCount.containsKey(dataCleanId)) {
                    SuccessFailureCount sucessFailureCount = new SuccessFailureCount();
                    sucessFailureCount.successCount++;
                    dataCleanId2successFailureCount.put(dataCleanId, sucessFailureCount);
                } else {
                    SuccessFailureCount sucessFailureCount = dataCleanId2successFailureCount.get(dataCleanId);
                    sucessFailureCount.successCount++;
                    dataCleanId2successFailureCount.put(dataCleanId, sucessFailureCount);
                }
            }
            if (dmlResults.errorIds2errorInfo.containsKey(recordId)) {
                if (!dataCleanId2errorRecordId2ErrorMessage.containsKey(dataCleanId)){
                    final List<Database.Error> errors = dmlResults.errorIds2errorInfo.get(recordId);
                    final String errorMessage = DatabaseUtils.getErrorString(errors);
                    Map<Id, String> recordId2ErrorMessage = new Map<Id, String>();
                    recordId2ErrorMessage.put(recordId, errorMessage);
                    dataCleanId2errorRecordId2ErrorMessage.put(dataCleanId, recordId2ErrorMessage);
                } else {
                    final List<Database.Error> errors = dmlResults.errorIds2errorInfo.get(recordId);
                    final String errorMessage = DatabaseUtils.getErrorString(errors);
                    Map<Id, String> recordId2ErrorMessage = dataCleanId2errorRecordId2ErrorMessage.get(dataCleanId);
                    recordId2ErrorMessage.put(recordId, errorMessage);
                    dataCleanId2errorRecordId2ErrorMessage.put(dataCleanId, recordId2ErrorMessage);
                }

                if (!dataCleanId2successFailureCount.containsKey(dataCleanId)) {
                    SuccessFailureCount sucessFailureCount = new SuccessFailureCount();
                    sucessFailureCount.failureCount++;
                    dataCleanId2successFailureCount.put(dataCleanId, sucessFailureCount);
                } else {
                    SuccessFailureCount sucessFailureCount = dataCleanId2successFailureCount.get(dataCleanId);
                    sucessFailureCount.failureCount++;
                    dataCleanId2successFailureCount.put(dataCleanId, sucessFailureCount);
                }
            }
        }

        if (processInfo.isParent) {
            DataCleanBatchHelper.updateDataClean(dataCleanId2successRecordIds, dataCleanId2errorRecordId2ErrorMessage, processInfo);
        } else {
            if (processInfo.processName != Constants.PROCESS_ROLLBACK) {
                if (!dataCleanId2successRecordIds.isEmpty()) {
                    DataCleanBatchHelper.deleteDataCleanFailedChild(dataCleanId2successRecordIds.keySet(), dmlResults.successIds);
                    DataCleanBatchHelper.insertDataCleanSuccessChild(dataCleanId2successRecordIds, processInfo);
                }
                if (!dataCleanId2errorRecordId2ErrorMessage.isEmpty()) {
                    DataCleanBatchHelper.upsertDataCleanFailedChild(dataCleanId2errorRecordId2ErrorMessage, dmlResults.errorIds2errorInfo.keySet(), processInfo);
                }
            }

            DataCleanBatchHelper.upsertDataCleanRelatedResult(dataCleanId2successFailureCount, dataCleanIds, processInfo);
        }
    }

    public static void onBatchFinishParent(ProcessInformation processInfo, ResultsUtil.ResultInformation resultInfo){
        DataCleanBatchHelper.updateDcResult(Constants.BATCH_METHOD.BATCH_FINSIH_PARENT, processInfo, resultInfo);
    }

    public static void onBatchFinishChild(ProcessInformation processInfo, ResultsUtil.ResultInformation resultInfo){
        DataCleanBatchHelper.upsertDcRelatedResult(processInfo, resultInfo);
        if (processInfo.processName == Constants.PROCESS_MASK || processInfo.processName == Constants.PROCESS_DELETE) {
            DataCleanBatchHelper.updateDcResultForFieldHistoryDeletion(processInfo);
            DataCleanBatchHelper.updateDcRelatedResultForFieldHistoryDeletion(processInfo);
        }
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    public static void onBatchFinishAllJobCompleted(ProcessInformation processInfo){

        DataCleanBatchHelper.updateDcResult(Constants.BATCH_METHOD.BATCH_FINSIH_ALL, processInfo);

        OQCT_DaCl__DC_Configuration__c dcConfiguration = DCConfigurationSelector.getDCConfigurationForNextJobsById(processInfo.dcConfigId);

        Boolean isProcessOverallComplete = DataCleanBatchHelper.isProcessOverallComplete(dcConfiguration);
        Boolean isProcess2OverallComplete = DataCleanBatchHelper.isProcess2OverallComplete(dcConfiguration);

        Boolean isRetry = false;
        if (processInfo.processName == Constants.PROCESS_MASK) {
            isRetry = dcConfiguration.OQCT_DaCl__Retry_Masking__c;
        } else if (processInfo.processName == Constants.PROCESS_DELETE) {
            isRetry = dcConfiguration.OQCT_DaCl__Retry_Deletion__c;
        } else if (processInfo.processName == Constants.PROCESS_ARCHIVE) {
            isRetry = dcConfiguration.OQCT_DaCl__Retry_Archive__c;
        } else if (processInfo.processName == Constants.PROCESS_ROLLBACK) {
            isRetry = false;
            return;
        }
        // else if (processInfo.processName == Constants.PROCESS_CLONE) {
        //     isRetry = dcConfiguration.OQCT_DaCl__Retry_Cloning__c;
        // }

        // Process 1 Repetition

        Datetime nextFireDate;
        if (isRetry && !isProcessOverallComplete) {
            nextFireDate = DataCleanBatchHelper.insertDcResultForNextRepetition(processInfo, dcConfiguration.OQCT_DaCl__Job_Id__c);
        } else if (isRetry) {
            List<CronTrigger> cronTriggers = CronTriggerSelector.getCronTriggerNameById(dcConfiguration.OQCT_DaCl__Job_Id__c);
            if (!cronTriggers.isEmpty()) {
                System.AbortJob(dcConfiguration.OQCT_DaCl__Job_Id__c);
            }
        }
        DataCleanBatchHelper.updateDcConfigurationProcessScheduledDateTimeNext(processInfo, nextFireDate);

        // Process 2 Initialization or Repetition

        if (dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_MASKING_DELETION ||
            dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_MASKING_ROLLBACK_DELETION ||
            dcConfiguration.OQCT_DaCl__Data_Clean_Action__c == Constants.DC_ACTION_ARCHIVE_DELETION) {
            if (processInfo.processName == Constants.PROCESS_MASK || processInfo.processName == Constants.PROCESS_ARCHIVE) {
                OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getDCResultsTotalSuccessById(processInfo.resultId);
                if (dcResult.OQCT_DaCl__Total_Success__c > 0) {
                    dcConfiguration = DataCleanBatchHelper.updateDCConfigurationProcess2Dates(dcConfiguration);
                    DataCleanBatchHelper.scheduleDeleteJob(dcConfiguration);
                }
            } else {
                nextFireDate = null;
                if (isRetry && !isProcess2OverallComplete) {
                    nextFireDate = DataCleanBatchHelper.insertDcResultForNextRepetition(processInfo, dcConfiguration.OQCT_DaCl__Process2_Job_Id__c, Constants.PROCESS_DELETE);
                    DataCleanBatchHelper.updateDcConfigurationProcess2ScheduledDateTimeNext(processInfo, nextFireDate);
                } else {
                    DataCleanBatchHelper.updateDcConfigurationProcess2ScheduledDateTimeNext(processInfo, nextFireDate);
                    if (isRetry) {
                        System.AbortJob(dcConfiguration.OQCT_DaCl__Process2_Job_Id__c);
                    }
                }
            }
        }
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    public static void updateDataClean(Map<Id, List<Id>> dataCleanId2successRecordIds, Map<Id, Map<Id, String>> dataCleanId2errorRecordId2ErrorMessage, ProcessInformation processInfo){

        List<OQCT_DaCl__Data_Clean__c> dataCleans = new List<OQCT_DaCl__Data_Clean__c>();

        for (Id dataCleanId : dataCleanId2successRecordIds.keySet()) {

            OQCT_DaCl__Data_Clean__c dataClean = new OQCT_DaCl__Data_Clean__c(Id = dataCleanId);

            if (processInfo.processName == Constants.PROCESS_MASK) {
                dataClean.OQCT_DaCl__Is_Parent_Masking_Completed__c = true;
                dataClean.OQCT_DaCl__Master_Record_Masking_Status__c = Constants.DC_STATUS_SUCCESS;
                dataClean.OQCT_DaCl__Master_Record_Masking_Error_Message__c = Constants.LITERAL_EMPTY;
                dataClean.OQCT_DaCl__Master_Record_Masking_DateTime__c = DateUtils.getNow();
            } else if (processInfo.processName == Constants.PROCESS_DELETE) {
                dataClean.OQCT_DaCl__Is_Parent_Deletion_Completed__c = true;
                dataClean.OQCT_DaCl__Master_Record_Deletion_Status__c = Constants.DC_STATUS_SUCCESS;
                dataClean.OQCT_DaCl__Master_Record_Delete_Error_Message__c = Constants.LITERAL_EMPTY;
                dataClean.OQCT_DaCl__Master_Record_Delete_DateTime__c = DateUtils.getNow();
            } else if (processInfo.processName == Constants.PROCESS_ARCHIVE) {
                dataClean.OQCT_DaCl__Is_Parent_Archive_Completed__c = true;
                dataClean.OQCT_DaCl__Master_Record_Archive_Status__c = Constants.DC_STATUS_SUCCESS;
                dataClean.OQCT_DaCl__Master_Record_Archive_Error_Message__c = Constants.LITERAL_EMPTY;
                dataClean.OQCT_DaCl__Master_Record_Archive_DateTime__c = DateUtils.getNow();
            }
            // else if (processInfo.processName == Constants.PROCESS_CLONE) {
            //     dataClean.OQCT_DaCl__Is_Parent_Cloning_Completed__c = true;
            //     dataClean.OQCT_DaCl__Master_Record_Cloning_Status__c = Constants.DC_STATUS_SUCCESS;
            //     dataClean.OQCT_DaCl__Master_Record_Cloning_Error_Message__c = Constants.LITERAL_EMPTY;
            //     dataClean.OQCT_DaCl__Master_Record_Cloning_DateTime__c = DateUtils.getNow();
            // }
            else if (processInfo.processName == Constants.PROCESS_ROLLBACK) {
                dataClean.OQCT_DaCl__Is_Parent_Rollback_Completed__c = true;
                dataClean.OQCT_DaCl__Master_Record_Rollback_Status__c = Constants.DC_STATUS_SUCCESS;
                dataClean.OQCT_DaCl__Master_Record_Rollback_Error_Message__c = Constants.LITERAL_EMPTY;
                dataClean.OQCT_DaCl__Master_Record_Rollback_DateTime__c = DateUtils.getNow();
            }

            dataCleans.add(dataClean);
        }

        for (Id dataCleanId : dataCleanId2errorRecordId2ErrorMessage.keySet()) {

            OQCT_DaCl__Data_Clean__c dataClean = new OQCT_DaCl__Data_Clean__c(Id = dataCleanId);

            if (processInfo.processName == Constants.PROCESS_MASK) {
                dataClean.OQCT_DaCl__Is_Parent_Masking_Completed__c = true;
                dataClean.OQCT_DaCl__Master_Record_Masking_Status__c = Constants.DC_STATUS_FAILED;
                dataClean.OQCT_DaCl__Master_Record_Masking_Error_Message__c = dataCleanId2errorRecordId2ErrorMessage.get(dataCleanId).values()[0];
            } else if (processInfo.processName == Constants.PROCESS_DELETE) {
                dataClean.OQCT_DaCl__Is_Parent_Deletion_Completed__c = true;
                dataClean.OQCT_DaCl__Master_Record_Deletion_Status__c = Constants.DC_STATUS_FAILED;
                dataClean.OQCT_DaCl__Master_Record_Delete_Error_Message__c = dataCleanId2errorRecordId2ErrorMessage.get(dataCleanId).values()[0];
            } else if (processInfo.processName == Constants.PROCESS_ARCHIVE) {
                dataClean.OQCT_DaCl__Is_Parent_Archive_Completed__c = true;
                dataClean.OQCT_DaCl__Master_Record_Archive_Status__c = Constants.DC_STATUS_FAILED;
                dataClean.OQCT_DaCl__Master_Record_Archive_Error_Message__c = dataCleanId2errorRecordId2ErrorMessage.get(dataCleanId).values()[0];
            }
            // else if (processInfo.processName == Constants.PROCESS_CLONE) {
            //     dataClean.OQCT_DaCl__Is_Parent_Cloning_Completed__c = true;
            //     dataClean.OQCT_DaCl__Master_Record_Cloning_Status__c = Constants.DC_STATUS_FAILED;
            //     dataClean.OQCT_DaCl__Master_Record_Cloning_Error_Message__c = dataCleanId2errorRecordId2ErrorMessage.get(dataCleanId).values()[0];
            // }
            else if (processInfo.processName == Constants.PROCESS_ROLLBACK) {
                dataClean.OQCT_DaCl__Is_Parent_Rollback_Completed__c = true;
                dataClean.OQCT_DaCl__Master_Record_Rollback_Status__c = Constants.DC_STATUS_FAILED;
                dataClean.OQCT_DaCl__Master_Record_Rollback_Error_Message__c = dataCleanId2errorRecordId2ErrorMessage.get(dataCleanId).values()[0];
            }

            dataCleans.add(dataClean);
        }

        DatabaseUtils.updateRecords(dataCleans);
    }

    private static void deleteDataCleanFailedChild(Set<Id> dataCleanIds, List<Id> successRecordIds){
        List<OQCT_DaCl__Data_Clean_Failed_Child__c> dataCleanFailedChilds = DataCleanFailedChildSelector.getDataCleanFailedChildsByDataCleanIdsAndChildRecordIds(dataCleanIds, new Set<Id>(successRecordIds));
        if (!dataCleanFailedChilds.isEmpty()) {
            DatabaseUtils.deleteRecords(dataCleanFailedChilds);
        }
    }

    private static void upsertDataCleanFailedChild(Map<Id, Map<Id, String>> dataCleanId2errorRecordId2ErrorMessage, Set<Id> errorRecordIds, ProcessInformation processInfo){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationNameById(processInfo.dcConfigId);
        Map<String, OQCT_DaCl__Data_Clean_Failed_Child__c> dataCleanIdrecordId2dataCleanFailedChilds = new Map<String, OQCT_DaCl__Data_Clean_Failed_Child__c>();
        for (Id dataCleanId : dataCleanId2errorRecordId2ErrorMessage.keySet()) {
            Map<Id, String> errorRecordId2ErrorMessage = dataCleanId2errorRecordId2ErrorMessage.get(dataCleanId);
            for (Id recordId : errorRecordId2ErrorMessage.keySet()) {
                OQCT_DaCl__Data_Clean_Failed_Child__c dataCleanFailedChild = new OQCT_DaCl__Data_Clean_Failed_Child__c();
                dataCleanFailedChild.OQCT_DaCl__Data_Clean__c = dataCleanId;
                dataCleanFailedChild.OQCT_DaCl__Child_Record_Id__c = recordId;
                dataCleanFailedChild.OQCT_DaCl__Child_Record_Error_Messages__c = errorRecordId2ErrorMessage.get(recordId);
                dataCleanFailedChild.OQCT_DaCl__Child_Object_Name__c = processInfo.objectName;
                dataCleanFailedChild.OQCT_DaCl__Is_Process2__c = DataCleanBatchHelper.isProcess2(dcConfig, processInfo.processName);
                dataCleanIdrecordId2dataCleanFailedChilds.put(String.valueOf(dataCleanId) + String.valueOf(recordId), dataCleanFailedChild);
            }
        }
        for (OQCT_DaCl__Data_Clean_Failed_Child__c dataCleanFailedChild : DataCleanFailedChildSelector.getDataCleanFailedChildsByDataCleanIdsAndChildRecordIds(dataCleanId2errorRecordId2ErrorMessage.keySet(), errorRecordIds)) {
            dataCleanIdrecordId2dataCleanFailedChilds.get(String.valueOf(dataCleanFailedChild.OQCT_DaCl__Data_Clean__c) + dataCleanFailedChild.OQCT_DaCl__Child_Record_Id__c).Id = dataCleanFailedChild.id;
        }
        DatabaseUtils.upsertRecords(dataCleanIdrecordId2dataCleanFailedChilds.Values());
    }

    private static void insertDataCleanSuccessChild(Map<Id, List<Id>> dataCleanId2successRecordIds, ProcessInformation processInfo){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationNameById(processInfo.dcConfigId);
        List<OQCT_DaCl__Data_Clean_Success_Child__c> dataCleanSuccessChilds = new List<OQCT_DaCl__Data_Clean_Success_Child__c>();
        for (Id dataCleanId : dataCleanId2successRecordIds.keySet()) {
            for (Id recordId : dataCleanId2successRecordIds.get(dataCleanId)) {
                OQCT_DaCl__Data_Clean_Success_Child__c dataCleanSuccessChild = new OQCT_DaCl__Data_Clean_Success_Child__c();
                dataCleanSuccessChild.OQCT_DaCl__Data_Clean__c = dataCleanId;
                dataCleanSuccessChild.OQCT_DaCl__Child_Record_Id__c = recordId;
                dataCleanSuccessChild.OQCT_DaCl__Child_Object_Name__c = processInfo.objectName;
                dataCleanSuccessChild.OQCT_DaCl__Is_Process2__c = DataCleanBatchHelper.isProcess2(dcConfig, processInfo.processName);
                dataCleanSuccessChilds.add(dataCleanSuccessChild);
            }
        }
        DatabaseUtils.insertRecords(dataCleanSuccessChilds);
    }

    @SuppressWarnings('PMD.CognitiveComplexity,PMD.NcssMethodCount')
    public static void upsertDataCleanRelatedResult(Map<Id, SuccessFailureCount> dataCleanId2successFailureCount, Set<Id> dataCleanIds, ProcessInformation processInfo){

        List<OQCT_DaCl__Data_Clean_Related_Result__c> dataCleanRelatedResults = DataCleanRelatedResultSelector.getDataCleanResultsByDataCleanIdsAndObjectName(dataCleanIds, processInfo.objectName);

        Map<Id, OQCT_DaCl__Data_Clean_Related_Result__c> dataCleanId2dataCleanRelatedResult = new Map<Id, OQCT_DaCl__Data_Clean_Related_Result__c>();

        for (OQCT_DaCl__Data_Clean_Related_Result__c dataCleanRelatedResult : dataCleanRelatedResults) {
            dataCleanId2dataCleanRelatedResult.put(dataCleanRelatedResult.OQCT_DaCl__Data_Clean__c, dataCleanRelatedResult);
        }

        if (dataCleanId2successFailureCount.isEmpty()) {
            for (OQCT_DaCl__Data_Clean_Related_Result__c dataCleanRelatedResult : dataCleanId2dataCleanRelatedResult.values()) {
                if (processInfo.relatedProcessName == Constants.PROCESS_MASK) {
                    dataCleanRelatedResult.OQCT_DaCl__Is_Related_Masking_Completed__c = !processInfo.childObjectsProcessingInSeparateChildBatch.contains(processInfo.objectName);
                } else if (processInfo.relatedProcessName == Constants.PROCESS_DELETE) {
                    dataCleanRelatedResult.OQCT_DaCl__Is_Related_Deletion_Completed__c = !processInfo.childObjectsProcessingInSeparateChildBatch.contains(processInfo.objectName);
                } else if (processInfo.relatedProcessName == Constants.PROCESS_ARCHIVE) {
                    dataCleanRelatedResult.OQCT_DaCl__Is_Related_Archive_Completed__c = !processInfo.childObjectsProcessingInSeparateChildBatch.contains(processInfo.objectName);
                }
                // else if (processInfo.relatedProcessName == Constants.PROCESS_CLONE) {
                //     dataCleanRelatedResult.OQCT_DaCl__Is_Related_Cloning_Completed__c = !processInfo.childObjectsProcessingInSeparateChildBatch.contains(processInfo.objectName);
                // }
                else if (processInfo.relatedProcessName == Constants.PROCESS_ROLLBACK) {
                    dataCleanRelatedResult.OQCT_DaCl__Is_Related_Rollback_Completed__c = true;
                }
            }
        }

        for (Id dataCleanId : dataCleanId2successFailureCount.keySet()) {

            SuccessFailureCount successFailureCount = dataCleanId2successFailureCount.get(dataCleanId);

            OQCT_DaCl__Data_Clean_Related_Result__c dataCleanRelatedResult;
            if (dataCleanId2dataCleanRelatedResult.containsKey(dataCleanId)) {
                dataCleanRelatedResult = dataCleanId2dataCleanRelatedResult.get(dataCleanId);
            }else {
                dataCleanRelatedResult = new OQCT_DaCl__Data_Clean_Related_Result__c();
                dataCleanRelatedResult.OQCT_DaCl__Data_Clean__c = dataCleanId;
                dataCleanRelatedResult.OQCT_DaCl__Related_Object_Name__c = processInfo.objectName;
                dataCleanRelatedResult.OQCT_DaCl__Delete_Related_Records__c = processInfo.relatedProcessName == Constants.PROCESS_DELETE ? true : false;
            }

            if (processInfo.relatedProcessName == Constants.PROCESS_MASK) {
                if (dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Masking__c == null) {
                    dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Masking__c = 0;
                }
                if (dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Masking__c == null) {
                    dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Masking__c = 0;
                }
                dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Masking__c += successFailureCount.successCount;
                dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Masking__c += successFailureCount.failureCount;
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Masking_Completed__c = !processInfo.childObjectsProcessingInSeparateChildBatch.contains(processInfo.objectName);
            } else if (processInfo.relatedProcessName == Constants.PROCESS_DELETE) {
                if (dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Deletion__c == null) {
                    dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Deletion__c = 0;
                }
                if (dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Deletion__c == null) {
                    dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Deletion__c = 0;
                }
                dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Deletion__c += successFailureCount.successCount;
                dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Deletion__c += successFailureCount.failureCount;
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Deletion_Completed__c = !processInfo.childObjectsProcessingInSeparateChildBatch.contains(processInfo.objectName);
            } else if (processInfo.relatedProcessName == Constants.PROCESS_ARCHIVE) {
                if (dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Archive__c == null) {
                    dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Archive__c = 0;
                }
                if (dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Archive__c == null) {
                    dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Archive__c = 0;
                }
                dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Archive__c += successFailureCount.successCount;
                dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Archive__c += successFailureCount.failureCount;
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Archive_Completed__c = !processInfo.childObjectsProcessingInSeparateChildBatch.contains(processInfo.objectName);
            }
            // else if (processInfo.relatedProcessName == Constants.PROCESS_CLONE) {
            //     if (dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Cloning__c == null) {
            //         dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Cloning__c = 0;
            //     }
            //     if (dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Cloning__c == null) {
            //         dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Cloning__c = 0;
            //     }
            //     dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Cloning__c += successFailureCount.successCount;
            //     dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Cloning__c += successFailureCount.failureCount;
            //     dataCleanRelatedResult.OQCT_DaCl__Is_Related_Cloning_Completed__c = !processInfo.childObjectsProcessingInSeparateChildBatch.contains(processInfo.objectName);
            // }
            else if (processInfo.relatedProcessName == Constants.PROCESS_ROLLBACK) {
                if (dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Rollback__c == null) {
                    dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Rollback__c = 0;
                }
                if (dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Rollback__c == null) {
                    dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Rollback__c = 0;
                }
                dataCleanRelatedResult.OQCT_DaCl__Total_Related_Success_Rollback__c += successFailureCount.successCount;
                dataCleanRelatedResult.OQCT_DaCl__Total_Related_Failure_Rollback__c += successFailureCount.failureCount;
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Rollback_Completed__c = true;
            }
            if (dataCleanRelatedResult.Id == null) {
                dataCleanId2dataCleanRelatedResult.put(dataCleanId, dataCleanRelatedResult);
            }
        }
        DatabaseUtils.upsertRecords(dataCleanId2dataCleanRelatedResult.values());
    }

    public static void updateDataCleanRelatedResult(ProcessInformation processInfo, Set<Id> dataCleanIds){
        List<OQCT_DaCl__Data_Clean_Related_Result__c> dataCleanRelatedResults = DataCleanRelatedResultSelector.getDataCleanResultsByDataCleanIdsAndObjectName(dataCleanIds, processInfo.objectName);
        for (OQCT_DaCl__Data_Clean_Related_Result__c dataCleanRelatedResult : dataCleanRelatedResults) {
            if (processInfo.relatedProcessName == Constants.PROCESS_MASK) {
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Masking_Completed__c = true;
            } else if (processInfo.relatedProcessName == Constants.PROCESS_DELETE) {
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Deletion_Completed__c = true;
            } else if (processInfo.relatedProcessName == Constants.PROCESS_ARCHIVE) {
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Archive_Completed__c = true;
            }
            // else if (processInfo.relatedProcessName == Constants.PROCESS_CLONE) {
            //     dataCleanRelatedResult.OQCT_DaCl__Is_Related_Cloning_Completed__c = true;
            // }
            else if (processInfo.relatedProcessName == Constants.PROCESS_ROLLBACK) {
                dataCleanRelatedResult.OQCT_DaCl__Is_Related_Rollback_Completed__c = true;
            }
        }
        DatabaseUtils.updateRecords(dataCleanRelatedResults);
    }

    private static void updateDcResult(Constants.BATCH_METHOD batchMethod, ProcessInformation processInfo){
        DataCleanBatchHelper.updateDcResult(batchMethod, processInfo, null);
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    private static void updateDcResult(Constants.BATCH_METHOD batchMethod, ProcessInformation processInfo, ResultsUtil.ResultInformation resultInfo){

        OQCT_DaCl__DC_Result__c dcResult = new OQCT_DaCl__DC_Result__c();
        dcResult.Id = processInfo.resultId;

        switch on batchMethod {

            when  BATCH_START {
                dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_PROCESSING;
                dcResult.OQCT_DaCl__Job_Start_Date__c = DateUtils.getNow();
            }
            when  BATCH_EXECUTE_START {
                if (!processInfo.isParent) {
                    if (processInfo.relatedProcessName == Constants.PROCESS_MASK) {
                        dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_MASKING_CHILD;
                    } else if (processInfo.relatedProcessName == Constants.PROCESS_DELETE) {
                        dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_DELETING_CHILD;
                    } else if (processInfo.relatedProcessName == Constants.PROCESS_ARCHIVE) {
                        dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_ARCHIVING_CHILD;
                    } else if (processInfo.relatedProcessName == Constants.PROCESS_ROLLBACK) {
                        dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_ROLLBACKING_CHILD;
                    }
                    // else if (processInfo.relatedProcessName == Constants.PROCESS_CLONE) {
                    //     dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_CLONING_CHILD;
                    // }
                } else {
                    if (processInfo.processName == Constants.PROCESS_MASK) {
                        dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_MASKING_PARENT;
                    } else if (processInfo.processName == Constants.PROCESS_DELETE) {
                        dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_DELETING_PARENT;
                    } else if (processInfo.processName == Constants.PROCESS_ARCHIVE) {
                        dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_ARCHIVING_PARENT;
                    } else if (processInfo.processName == Constants.PROCESS_ROLLBACK) {
                        dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_ROLLBACKING_PARENT;
                    }
                    // else if (processInfo.processName == Constants.PROCESS_CLONE) {
                    //     dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_CLONING_PARENT;
                    // }
                }
            }
            // when  BATCH_EXECUTE_END {
                
            // }
            when  BATCH_FINSIH_PARENT {
                dcResult.OQCT_DaCl__Is_Parent_Job_Completed__c = true;
                dcResult.OQCT_DaCl__Total_Success_Parent__c = resultInfo.success;
                dcResult.OQCT_DaCl__Total_Failure_Parent__c = resultInfo.failure;
            }
            // when  BATCH_FINSIH_CHILD {

            // }
            when  BATCH_FINSIH_ALL {
                dcResult.OQCT_DaCl__Job_Status__c = Constants.DC_RESULT_STATUS_COMPLETED;
                dcResult.OQCT_DaCl__Backup_Expiry_Date__c = DateUtils.getNow();
            }
            when else {
                
            }
        }
        DatabaseUtils.updateRecords(dcResult);
    }

    public static void upsertDcRelatedResult(ProcessInformation processInfo, ResultsUtil.ResultInformation resultInfo){

        List<OQCT_DaCl__DC_Related_Result__c> dcRelatedResults = DCRelatedResultSelector.getDcRelatedResultsByDcResultIdAndRelatedObjectName(processInfo.resultId, processInfo.objectName);

        OQCT_DaCl__DC_Related_Result__c dcRelatedResult;

        if (!dcRelatedResults.isEmpty()) {
            dcRelatedResult = dcRelatedResults[0];
        }else {
            dcRelatedResult = new OQCT_DaCl__DC_Related_Result__c();
            dcRelatedResult.OQCT_DaCl__DC_Result__c = processInfo.resultId;
            dcRelatedResult.OQCT_DaCl__Related_Object_Name__c = processInfo.objectName;
            dcRelatedResult.OQCT_DaCl__Process__c = processInfo.relatedProcessName;
        }
        dcRelatedResult.OQCT_DaCl__Is_Related_Job_Completed__c = true;
        if (dcRelatedResult.OQCT_DaCl__Total_Related_Success__c == null) {
            dcRelatedResult.OQCT_DaCl__Total_Related_Success__c = 0;
        }
        dcRelatedResult.OQCT_DaCl__Total_Related_Success__c += resultInfo.success;
        if (dcRelatedResult.OQCT_DaCl__Total_Related_Failure__c == null) {
            dcRelatedResult.OQCT_DaCl__Total_Related_Failure__c = 0;
        }
        dcRelatedResult.OQCT_DaCl__Total_Related_Failure__c += resultInfo.failure;

        DatabaseUtils.upsertRecords(dcRelatedResult);
    }

    private static Boolean isProcessOverallComplete(OQCT_DaCl__DC_Configuration__c dcConfiguration){
        String dcConfigActionName = dcConfiguration.OQCT_DaCl__Data_Clean_Action__c;
        if (dcConfigActionName == Constants.DC_ACTION_MASKING_ONLY || 
            dcConfigActionName == Constants.DC_ACTION_MASKING_DELETION ||
            dcConfigActionName == Constants.DC_ACTION_MASKING_ROLLBACK || 
            dcConfigActionName == Constants.DC_ACTION_MASKING_ROLLBACK_DELETION
            ) {
                return dcConfiguration.OQCT_DaCl__Overall_Masking_Status__c == Constants.DC_STATUS_SUCCESS;
        } else if (dcConfigActionName == Constants.DC_ACTION_DELETION_ONLY ||
            dcConfigActionName == Constants.DC_ACTION_DELETION_ROLLBACK
            ){
                return dcConfiguration.OQCT_DaCl__Overall_Deletion_Status__c == Constants.DC_STATUS_SUCCESS;
        } else if (dcConfigActionName == Constants.DC_ACTION_ARCHIVE_DELETION ||
                dcConfigActionName == Constants.DC_ACTION_ARCHIVE_ROLLBACK
            ){
                return dcConfiguration.OQCT_DaCl__Overall_Archive_Status__c == Constants.DC_STATUS_SUCCESS;
        } else if (dcConfigActionName == Constants.DC_ACTION_CLONING
            ){
                return dcConfiguration.OQCT_DaCl__Overall_Cloning_Status__c == Constants.DC_STATUS_SUCCESS;
        } else {
            return true;
        }
    }

    private static Boolean isProcess2OverallComplete(OQCT_DaCl__DC_Configuration__c dcConfiguration){
        String dcConfigActionName = dcConfiguration.OQCT_DaCl__Data_Clean_Action__c;
        if (dcConfigActionName == Constants.DC_ACTION_MASKING_DELETION || 
            dcConfigActionName == Constants.DC_ACTION_MASKING_ROLLBACK_DELETION
            ) {
                return dcConfiguration.OQCT_DaCl__Overall_Deletion_Status__c == Constants.DC_STATUS_SUCCESS;
        } else if (dcConfigActionName == Constants.DC_ACTION_ARCHIVE_DELETION
            ){
                return dcConfiguration.OQCT_DaCl__Overall_Deletion_Status__c == Constants.DC_STATUS_SUCCESS;
        } else {
            return true;
        }
    }

    private static Datetime insertDcResultForNextRepetition(ProcessInformation processInfo, Id jobId){
        return DataCleanBatchHelper.insertDcResultForNextRepetition(processInfo, jobId, null);
    }

    private static Datetime insertDcResultForNextRepetition(ProcessInformation processInfo, Id jobId, String processName){
        if (processName == null) {
            processName = processInfo.processName;
        }
        Datetime nextFireDate;
        List<CronTrigger> cronTriggers = CronTriggerSelector.getCronTriggerNameAndNextFireTimeById(jobId);
            if (!cronTriggers.isEmpty()) {
                CronTrigger cronTrigger = cronTriggers[0];
                nextFireDate = cronTrigger.NextFireTime;
                OQCT_DaCl__DC_Result__c dcResult = new OQCT_DaCl__DC_Result__c();
                dcResult.OQCT_DaCl__DC_Configuration__c = processInfo.dcConfigId;
                dcResult.OQCT_DaCl__Job_Schedule_Date__c = cronTrigger.NextFireTime;
                dcResult.OQCT_DaCl__Process__c = processName;
                dcResult.OQCT_DaCl__Job_Name__c = cronTrigger.CronJobDetail.Name;
                dcResult.OQCT_DaCl__Attempt_No__c = DCResultSelector.getLatestDCResultByDcConfigIdAndProcessName(processInfo.dcConfigId, processName).OQCT_DaCl__Attempt_No__c + 1;
                DatabaseUtils.insertRecords(dcResult);
                DataCleanHelper.createDcRelatedResults(dcResult, processInfo.dcConfigId);
            }
        return nextFireDate;
    }

    private static void updateDcConfigurationProcessScheduledDateTimeNext(ProcessInformation processInfo, Datetime nextFireDate){
        OQCT_DaCl__DC_Configuration__c dcConfiguration = new OQCT_DaCl__DC_Configuration__c(Id = processInfo.dcConfigId);
        dcConfiguration.OQCT_DaCl__Process_Scheduled_Date_Time_Next__c = nextFireDate;
        DatabaseUtils.updateRecords(dcConfiguration);
    }

    private static void updateDcConfigurationProcess2ScheduledDateTimeNext(ProcessInformation processInfo, Datetime nextFireDate){
        OQCT_DaCl__DC_Configuration__c dcConfiguration = new OQCT_DaCl__DC_Configuration__c(Id = processInfo.dcConfigId);
        dcConfiguration.OQCT_DaCl__Process2_Scheduled_DateTime_Next__c = nextFireDate;
        DatabaseUtils.updateRecords(dcConfiguration);
    }

    public static OQCT_DaCl__DC_Configuration__c updateDCConfigurationProcess2Dates(OQCT_DaCl__DC_Configuration__c dcConfiguration){
        Integer processStartAfter = (Integer)dcConfiguration.OQCT_DaCl__Process2_Start_After__c;
        dcConfiguration.OQCT_DaCl__Process2_Scheduled_DateTime_Next__c = DateUtils.shiftNowDate(processStartAfter, dcConfiguration.OQCT_DaCl__Process2_Start_Unit__c, dcConfiguration.OQCT_DaCl__Process2_Start_Time__c);
        dcConfiguration.OQCT_DaCl__Process2_Scheduled_DateTime_Init__c = dcConfiguration.OQCT_DaCl__Process2_Scheduled_DateTime_Next__c;
        DatabaseUtils.updateRecords(dcConfiguration);
        return dcConfiguration;
    }

    private static String getProcess2JobName(String dcConfigName, String dcConfigActionName){
        if (dcConfigActionName == Constants.DC_ACTION_MASKING_DELETION || 
            dcConfigActionName == Constants.DC_ACTION_MASKING_ROLLBACK_DELETION || 
            dcConfigActionName == Constants.DC_ACTION_ARCHIVE_DELETION
            ) {
            return dcConfigName + Constants.JOB_SUFFIX_DELETE;
        } else {
            return dcConfigName + Constants.JOB_SUFFIX_GENERIC;
        }
    }

    // private static void scheduleMaskJob(OQCT_DaCl__DC_Configuration__c dcConfiguration){
    //     String jobName = DataCleanBatchHelper.getProcess2JobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c);
    //     String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(dcConfiguration.OQCT_DaCl__Process2_Scheduled_DateTime_Next__c,
    //                                                                         dcConfiguration.OQCT_DaCl__Retry_Masking_After__c,
    //                                                                         dcConfiguration.OQCT_DaCl__Retry_Masking_Unit__c);
    //     DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
    //     scheduleWrap.dataConfigurationId = dcConfiguration.Id;
    //     scheduleWrap.batchType  = Constants.BATCH_TYPE.BATCH_MASK;
    //     Id scheduleJobId = System.Schedule(jobName, cronString, new DataCleanSchedulable(scheduleWrap));
    //     DataCleanBatchHelper.updateDcConfigAndCreateResult(dcConfiguration, scheduleJobId, Constants.PROCESS_MASK);
    // }

    private static void scheduleDeleteJob(OQCT_DaCl__DC_Configuration__c dcConfiguration){
        String jobName = DataCleanBatchHelper.getProcess2JobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c);
        String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(dcConfiguration.OQCT_DaCl__Process2_Scheduled_DateTime_Next__c,
                                                                            dcConfiguration.OQCT_DaCl__Retry_Deletion_After__c,
                                                                            dcConfiguration.OQCT_DaCl__Retry_Deletion_Unit__c);
        DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrap.dataConfigurationId = dcConfiguration.Id;
        scheduleWrap.batchType  = Constants.BATCH_TYPE.BATCH_DELETE;
        Id scheduleJobId = System.Schedule(jobName, cronString, new DataCleanSchedulable(scheduleWrap));
        DataCleanBatchHelper.updateDcConfigAndCreateResult(dcConfiguration, scheduleJobId, Constants.PROCESS_DELETE);
    }

    // private static void scheduleArchiveJob(OQCT_DaCl__DC_Configuration__c dcConfiguration){
    //     String jobName = DataCleanBatchHelper.getProcess2JobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c);
    //     String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(dcConfiguration.OQCT_DaCl__Process2_Scheduled_DateTime_Next__c,
    //                                                                         dcConfiguration.OQCT_DaCl__Retry_Archive_After__c,
    //                                                                         dcConfiguration.OQCT_DaCl__Retry_Archive_Unit__c);
    //     DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
    //     scheduleWrap.dataConfigurationId = dcConfiguration.Id;
    //     scheduleWrap.batchType  = Constants.BATCH_TYPE.BATCH_ARCHIVE;
    //     Id scheduleJobId = System.Schedule(jobName, cronString, new DataCleanSchedulable(scheduleWrap));
    //     DataCleanBatchHelper.updateDcConfigAndCreateResult(dcConfiguration, scheduleJobId, Constants.PROCESS_ARCHIVE);
    // }

    // private static void scheduleCloneJob(OQCT_DaCl__DC_Configuration__c dcConfiguration){
    //     String jobName = DataCleanBatchHelper.getProcess2JobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c);
    //     String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(dcConfiguration.OQCT_DaCl__Process2_Scheduled_DateTime_Next__c,
    //                                                                         dcConfiguration.OQCT_DaCl__Retry_Cloning_After__c,
    //                                                                         dcConfiguration.OQCT_DaCl__Retry_Cloning_Unit__c);
    //     DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
    //     scheduleWrap.dataConfigurationId = dcConfiguration.Id;
    //     scheduleWrap.batchType  = Constants.BATCH_TYPE.BATCH_CLONE;
    //     Id scheduleJobId = System.Schedule(jobName, cronString, new DataCleanSchedulable(scheduleWrap));
    //     DataCleanBatchHelper.updateDcConfigAndCreateResult(dcConfiguration, scheduleJobId, Constants.PROCESS_CLONE);
    // }

    private static void updateDcConfigAndCreateResult(OQCT_DaCl__DC_Configuration__c dcConfiguration, Id scheduleJobId, String processName){
        dcConfiguration.OQCT_DaCl__Process2_Job_Id__c = scheduleJobId;
        dcConfiguration.OQCT_DaCl__Process2_Job_Submit_Date__c = DateUtils.getNow();
        DatabaseUtils.updateRecords(dcConfiguration);

        OQCT_DaCl__DC_Result__c dcResult = new OQCT_DaCl__DC_Result__c();
        dcResult.OQCT_DaCl__DC_Configuration__c = dcConfiguration.Id;
        dcResult.OQCT_DaCl__Job_Schedule_Date__c = dcConfiguration.OQCT_DaCl__Process2_Scheduled_DateTime_Next__c;
        dcResult.OQCT_DaCl__Process__c = processName;
        dcResult.OQCT_DaCl__Job_Name__c = DataCleanBatchHelper.getProcess2JobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c);
        dcResult.OQCT_DaCl__Attempt_No__c = 1;
        DatabaseUtils.insertRecords(dcResult);
        DataCleanHelper.createDcRelatedResults(dcResult, dcConfiguration.Id);
    }

    public static Map<String, Integer> getRelatedObjectName2numberOfChildBatchActive(ProcessInformation processInfo){
        Map<String, Integer> relatedObjectName2numberOfChildBatchActive = new Map<String, Integer>();
        String childBatchInformationJson = DCResultSelector.getDCResultChildBatchInformationJsonById(processInfo.resultId).OQCT_DaCl__Child_Batch_Information_Json__c;
        if (String.isNotBlank(childBatchInformationJson)) {
            relatedObjectName2numberOfChildBatchActive = (Map<String, Integer>)JSON.deserialize(childBatchInformationJson, Map<String, Integer>.class); 
        }
        return relatedObjectName2numberOfChildBatchActive;
    }

    public static void updateRelatedObjectName2numberOfChildBatchActive(ProcessInformation processInfo, Map<String, Integer> relatedObjectName2numberOfChildBatchActive){
        OQCT_DaCl__DC_Result__c result = new OQCT_DaCl__DC_Result__c(Id = processInfo.resultId);
        if (relatedObjectName2numberOfChildBatchActive.isEmpty()) {
            result.OQCT_DaCl__Child_Batch_Information_Json__c = Constants.LITERAL_EMPTY;
        } else {
            result.OQCT_DaCl__Child_Batch_Information_Json__c = JSON.serialize(relatedObjectName2numberOfChildBatchActive);
        }
        DatabaseUtils.updateRecords(result);
    }

    public static void updateDcResultForFieldHistoryDeletion(ProcessInformation processInfo){
        OQCT_DaCl__DC_Result__c result = DCResultSelector.getDCResultFieldHistoryDeletionStatusById(processInfo.resultId);
        if (String.isBlank(result.OQCT_DaCl__Parent_Field_History_Deletion_Status__c)) {
            result.OQCT_DaCl__Parent_Field_History_Deletion_Status__c = Constants.FIELD_HISTORY_DELETE_SUCCESS;
        }
        DatabaseUtils.updateRecords(result);
    }

    public static void updateDcRelatedResultForFieldHistoryDeletion(ProcessInformation processInfo){
        List<OQCT_DaCl__DC_Related_Result__c> dcRelatedResults = DCRelatedResultSelector.getDcRelatedResultsFieldHistoryDeletionStatusByDcResultIdAndRelatedObjectName(processInfo.resultId, processInfo.objectName);
        for (OQCT_DaCl__DC_Related_Result__c dcRelatedResult : dcRelatedResults) {
            if (String.isBlank(dcRelatedResult.OQCT_DaCl__Related_Field_History_Deletion_Status__c)) {
                dcRelatedResult.OQCT_DaCl__Related_Field_History_Deletion_Status__c = Constants.FIELD_HISTORY_DELETE_SUCCESS;
            }
        }
        DatabaseUtils.updateRecords(dcRelatedResults);
    }

    public static void updateDcResultForFieldHistoryDeletion(ProcessInformation processInfo, Boolean dmlErrorFlag, Boolean deleteFieldHistoryPermission){
        OQCT_DaCl__DC_Result__c result = new OQCT_DaCl__DC_Result__c(Id = processInfo.resultId);
        if (dmlErrorFlag) {
            result.OQCT_DaCl__Parent_Field_History_Deletion_Status__c = Constants.FIELD_HISTORY_DELETE_FAILURE;
        }
        if (!deleteFieldHistoryPermission) {
            result.OQCT_DaCl__Parent_Field_History_Deletion_Status__c = Constants.FIELD_HISTORY_DELETE_INSUFFICIENT_PRIVILEGES;
        }
        DatabaseUtils.updateRecords(result);
    }

    private static void updateDcRelatedResultForFieldHistoryDeletion(ProcessInformation processInfo, Boolean dmlErrorFlag, Boolean deleteFieldHistoryPermission){
        List<OQCT_DaCl__DC_Related_Result__c> dcRelatedResults = DCRelatedResultSelector.getDcRelatedResultsByDcResultIdAndRelatedObjectName(processInfo.resultId, processInfo.objectName);
        for (OQCT_DaCl__DC_Related_Result__c dcRelatedResult : dcRelatedResults) {
            if (dmlErrorFlag) {
                dcRelatedResult.OQCT_DaCl__Related_Field_History_Deletion_Status__c = Constants.FIELD_HISTORY_DELETE_FAILURE;
            }
            if (!deleteFieldHistoryPermission) {
                dcRelatedResult.OQCT_DaCl__Related_Field_History_Deletion_Status__c = Constants.FIELD_HISTORY_DELETE_INSUFFICIENT_PRIVILEGES;
            }
        }
        DatabaseUtils.updateRecords(dcRelatedResults);
    }

    @TestVisible
    private static void updateDcResultForFieldHistoryDeletionNotEnabled(ProcessInformation processInfo){
        OQCT_DaCl__DC_Result__c result = new OQCT_DaCl__DC_Result__c(Id = processInfo.resultId);
        result.OQCT_DaCl__Parent_Field_History_Deletion_Status__c = Constants.FIELD_HISTORY_DELETE_NOT_TRACKED;
        DatabaseUtils.updateRecords(result);
    }

    private static void updateDcRelatedResultForFieldHistoryDeletionNotEnabled(ProcessInformation processInfo){
        List<OQCT_DaCl__DC_Related_Result__c> dcRelatedResults = DCRelatedResultSelector.getDcRelatedResultsByDcResultIdAndRelatedObjectName(processInfo.resultId, processInfo.objectName);
        for (OQCT_DaCl__DC_Related_Result__c dcRelatedResult : dcRelatedResults) {
            dcRelatedResult.OQCT_DaCl__Related_Field_History_Deletion_Status__c = Constants.FIELD_HISTORY_DELETE_NOT_TRACKED;
        }
        DatabaseUtils.updateRecords(dcRelatedResults);
    }

    public static void deleteFieldHistory(ProcessInformation processInfo, Map<String, FieldToMaskAndEmptyWrapper> recordTypesAndFields, Set<Id> recordIds){
        String processName = processInfo.isParent? processInfo.processName : processInfo.relatedProcessName;
        Set<String> fieldsForHistoryTrackingDeletion;
        if (processName == Constants.PROCESS_MASK) {
            for (String recordTypeId : recordTypesAndFields.keySet()) {
                fieldsForHistoryTrackingDeletion = new Set<String>();
                fieldsForHistoryTrackingDeletion.addAll(recordTypesAndFields.get(recordTypeId).fieldsToMask);
                fieldsForHistoryTrackingDeletion.addAll(recordTypesAndFields.get(recordTypeId).fieldsToEmpty);
            }
        }else if (processName == Constants.PROCESS_DELETE) {
            fieldsForHistoryTrackingDeletion = new Set<String>();
        }
        if (!Utils.isFieldHistoryEnabled(processInfo.objectName)) {
            if (processInfo.isParent) {
                DataCleanBatchHelper.updateDcResultForFieldHistoryDeletionNotEnabled(processInfo);
            } else {
                DataCleanBatchHelper.updateDcRelatedResultForFieldHistoryDeletionNotEnabled(processInfo);
            }
            return;
        }
        if (fieldsForHistoryTrackingDeletion != null) {
            Set<String> fieldsForWhichHistoryTrackingIsEnabled = new Set<String>();
            for (FieldDefinition fieldDefinition : FieldDefinitionSelector.getAllFieldDefinitionsIsFieldHistoryTrackedByEntityDefinitionQualifiedApiName(processInfo.objectName)){
                fieldsForWhichHistoryTrackingIsEnabled.add(fieldDefinition.QualifiedApiName);
            }
            fieldsForHistoryTrackingDeletion.retainAll(fieldsForWhichHistoryTrackingIsEnabled);
            List<SObject> fieldHistoryRecords;
            if (!fieldsForHistoryTrackingDeletion.isEmpty()) {
                fieldHistoryRecords = SObjectSelector.getFieldHistoryByIdObjectAndFields(processInfo.objectName, fieldsForHistoryTrackingDeletion, recordIds);
            }else {
                fieldHistoryRecords = SObjectSelector.getFieldHistoryByIdAndObject(processInfo.objectName, recordIds);
            }
            DatabaseUtils.DMLResult results;
            Boolean dmlError = false;
            Boolean deleteFieldHistoryPermission = true;
            try {
                results = DatabaseUtils.deleteRecordsAndReturnDMLResult(fieldHistoryRecords);
                dmlError = results.errorIds2errorInfo.size() > 0;
            } catch(Exception e) {
                deleteFieldHistoryPermission = false;
            }
            if (processInfo.isParent) {
                DataCleanBatchHelper.updateDcResultForFieldHistoryDeletion(processInfo, dmlError, deleteFieldHistoryPermission);
            } else {
                DataCleanBatchHelper.updateDcRelatedResultForFieldHistoryDeletion(processInfo, dmlError, deleteFieldHistoryPermission);
            }
        }
    }

    public static void sendResultEmail(ProcessInformation processInfo){

        EmailUtils.EmailParameters emailParams = new EmailUtils.EmailParameters();
        
        List<String> emailSubjectParamFormatString = new List<String>();
        emailSubjectParamFormatString.add(processInfo.processName);
        emailParams.subject = String.format(Constants.DATA_CLEAN_EMAIL_SUBJECT_PROCESS_COMPLETED, emailSubjectParamFormatString);

        List<String> emailBodyParamFormatString = new List<String>();
        emailBodyParamFormatString.add(processInfo.processName);
        emailBodyParamFormatString.add(Utils.getRecordLink(processInfo.dcConfigId, processInfo.dcConfigName));
        emailBodyParamFormatString.add(Utils.getRecordLink(processInfo.resultId, processInfo.resultName));
        emailParams.htmlBody = String.format(Constants.DATA_CLEAN_EMAIL_BODY_PROCESS_COMPLETED, emailBodyParamFormatString);

        OQCT_DaCl__DC_Result__c result = DCResultSelector.getDCResultForEmail(processInfo.resultId);

        emailParams.htmlBody += ('Overall Total Success (Parent + Child): ' +  result.OQCT_DaCl__Total_Success__c + Constants.HTML_TAG_BREAK_LINE);
        emailParams.htmlBody += ('Overall Total Failure (Parent + Child): ' +  result.OQCT_DaCl__Total_Failure__c + Constants.HTML_TAG_BREAK_LINE + Constants.HTML_TAG_BREAK_LINE);

        emailParams.htmlBody += ('Master Object: ' + result.OQCT_DaCl__Master_Object_Name__c + Constants.HTML_TAG_BREAK_LINE);
        List<String> parentResult = new List<String>();
        parentResult.add('Total Success: ' + result.OQCT_DaCl__Total_Success_Parent__c);
        parentResult.add('Total Failure: ' + result.OQCT_DaCl__Total_Failure_Parent__c);
        emailParams.htmlBody += EmailUtils.getHTMLUnorderedList(parentResult);
        emailParams.htmlBody += Constants.HTML_TAG_BREAK_LINE;

        if (!result.OQCT_DaCl__DC_Related_Results__r.isEmpty()) {
            emailParams.htmlBody += ('The result for related child object are as follows:' + Constants.HTML_TAG_BREAK_LINE);
            for (OQCT_DaCl__DC_Related_Result__c relatedResult : result.OQCT_DaCl__DC_Related_Results__r) {
                emailParams.htmlBody += ('Child Object: ' + relatedResult.OQCT_DaCl__Related_Object_Name__c + Constants.HTML_TAG_BREAK_LINE);
                List<String> childResult = new List<String>();
                childResult.add('Success: ' + relatedResult.OQCT_DaCl__Total_Related_Success__c);
                childResult.add('Failure: ' + relatedResult.OQCT_DaCl__Total_Related_Failure__c);
                emailParams.htmlBody += EmailUtils.getHTMLUnorderedList(childResult);
                emailParams.htmlBody += Constants.HTML_TAG_BREAK_LINE;
            }
        }
        if (ContentVersionSelector.getContentVersionsTotalSizeByFirstPublishLocationId(processInfo.resultId) < Constants.DATA_CLEAN_EMAIL_ATTACHMENT_THRESHOLD) {
            List<ContentVersion> resultAttachments = ContentVersionSelector.getContentVersionsSuccessAndErrorByFirstPublishLocationId(processInfo.resultId);
            Set<Id> resultAttachmentIds = new Map<Id, ContentVersion>(resultAttachments).keySet();
            emailParams.entityAttachments = new List<Id>(resultAttachmentIds);
        }

        EmailUtils.sendEmail(emailParams, processInfo.dcConfigId);

        if (result.OQCT_DaCl__Total_Failure__c > 0) {
            emailParams.entityAttachments = null;
            emailParams.isErrorEmail = true;

            if (ContentVersionSelector.getContentVersionsTotalSizeErrorOnlyByFirstPublishLocationId(processInfo.resultId) < Constants.DATA_CLEAN_EMAIL_ATTACHMENT_THRESHOLD) {
                List<ContentVersion> resultAttachments = ContentVersionSelector.getContentVersionsErrorOnlyByFirstPublishLocationId(processInfo.resultId);
                Set<Id> resultAttachmentIds = new Map<Id, ContentVersion>(resultAttachments).keySet();
                emailParams.entityAttachments = new List<Id>(resultAttachmentIds);
            }

            EmailUtils.sendEmail(emailParams, processInfo.dcConfigId);
        }
    }

    public with sharing class SuccessFailureCount {
        public Integer successCount = 0;
        public Integer failureCount = 0;
    }
    
    public with sharing class RecordTypeAndFieldWrapper{
        public List<String> fieldsToQuery;
        public List<String> fieldsToBackup;
        public Map<String, FieldToMaskAndEmptyWrapper> recordTypesAndFields;
    }

    public with sharing class FieldToMaskAndEmptyWrapper{
        public List<String> fieldsToEmpty;
        public List<String> fieldsToMask;
    }

    public with sharing class RecordWrapper{
        public SObject record;
        public Id dataCleanId;
        public String masterId;
    }

    public with sharing class RollbackWrapper{
        public SObject record;
        public ReportUtil.BackupReportContent backupContent;
    }

    public with sharing class BackupFiles{
        public List<String> parentBackupFiles;
        public List<String> childBackupFiles;
    }

    public with sharing class ChildBatchInformation{
        public Integer childBatchNumber;
        public Boolean isCompleted;
    }

    public with sharing class ProcessInformation{
        
        public String objectName;

        public Boolean isParent = false;

        public String processName;

        public String relatedProcessName;

        public Set<String> childObjectsProcessingInSeparateChildBatch;

        public String resultName;

        public Id resultId;

        public String dcConfigName;

        public Id dcConfigId;

        public Boolean isAllJobCompleted(){
            return DCResultSelector.getIsAllJobCompletedByDcResultId(this.resultId).OQCT_DaCl__Is_All_Job_Completed__c;
        }
    }
}