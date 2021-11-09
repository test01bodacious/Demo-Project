/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-22   Krrish Joy   Initial Version
**/
public with sharing class DcResultHelper {

    public static void scheuleAutoBackupDeleteJob(Map<Id, OQCT_DaCl__DC_Result__c> dcResultId2RecordOld, Map<Id, OQCT_DaCl__DC_Result__c> dcResultId2RecordNew){

        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationBackupInfoById(dcResultId2RecordNew.values()[0].OQCT_DaCl__DC_Configuration__c);

        for (Id dcResultId : dcResultId2RecordNew.keySet()) {
            OQCT_DaCl__DC_Result__c dcResultNew = dcResultId2RecordNew.get(dcResultId);
            OQCT_DaCl__DC_Result__c dcResultOld = dcResultId2RecordOld.get(dcResultId);
            if (!DataCleanBatchHelper.isProcess2(dcConfig, dcResultNew.OQCT_DaCl__Process__c) && dcResultNew.OQCT_DaCl__Total_Backup_files__c > 0 && !dcResultOld.OQCT_DaCl__Is_All_Job_Completed__c && dcResultNew.OQCT_DaCl__Is_All_Job_Completed__c) {
                DeleteDataCleanFileBatch.BatchParameters batchParams = new DeleteDataCleanFileBatch.BatchParameters();
                batchParams.dataSetName = Constants.DATA_SET_DATA_CLEAN_RESULTS;
                batchParams.parentName = dcConfig.Name;
                batchParams.ids2Name = new Map<Id, String>();
                batchParams.ids2Name.put(dcResultNew.Id, dcResultNew.Name);
                batchParams.deleteFilePrefixes = new List<String>{Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_BACKUP + Constants.LITERAL_PERCENT};
                DcResultHelper.scheduleBackupDeleteJob(batchParams, dcResultNew.Name, dcConfig);
            }
        }
    }

    public static Id scheduleBackupDeleteJob(DeleteDataCleanFileBatch.BatchParameters batchParams, String resultName, OQCT_DaCl__DC_Configuration__c dcConfig) {
        String jobName = resultName + Constants.JOB_SUFFIX_AUTO_DELETE_BACKUP;
        Datetime backupDeleteDate = DateUtils.shiftNowDate((Integer)dcConfig.OQCT_DaCl__Delete_Backups_After__c, dcConfig.OQCT_DaCl__Delete_Backups_Unit__c, dcConfig.OQCT_DaCl__Delete_Backups_Time__c);
        String cronString = DateUtils.getCronStringFromDateTime(backupDeleteDate);
        DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrap.batchParams = batchParams;
        scheduleWrap.batchType  = Constants.BATCH_TYPE.BATCH_AUTO_DELETE_BACKUP;
        scheduleWrap.dataConfigurationId = dcConfig.Id;
        Id scheduleJobId = System.Schedule(jobName, cronString, new DataCleanSchedulable(scheduleWrap));
        return scheduleJobId;
    }

}