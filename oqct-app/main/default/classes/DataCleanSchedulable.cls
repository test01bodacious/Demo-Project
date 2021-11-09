/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-14   Krrish Joy   Initial Version
**/
public with sharing class DataCleanSchedulable implements Schedulable{

    @TestVisible private ScheduleWrapper scheduleWrap;

    public DataCleanSchedulable(ScheduleWrapper scheduleWrap) {
        this.scheduleWrap = scheduleWrap;
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    public void execute(SchedulableContext sc){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationIsActiveById(this.scheduleWrap.dataConfigurationId);
        if (!dcConfig.OQCT_DaCl__Is_Configuration_Active__c) {
            return;
        }
        Integer dataCleanCount = 0;
        switch on this.scheduleWrap.batchType {
            when  BATCH_MASK {
                dataCleanCount = DataCleanSelector.getDataCleansAvailableForMaskCount();
                if (dataCleanCount > 0) {
                    Object dcBatchParams = DataCleanBatchHelper.getBatchParams(this.scheduleWrap.dataConfigurationId, this.scheduleWrap.batchType);
                    DataCleanMaskBatch dcMaskBatch = new DataCleanMaskBatch((DataCleanMaskBatch.DataCleanMaskBatchParameters)dcBatchParams);
                    Integer batchSize = ((DataCleanMaskBatch.DataCleanMaskBatchParameters)dcBatchParams).processInfo.isParent ? Constants.BATCH_SIZE_MASK_PARENT : Constants.BATCH_SIZE_MASK;
                    Database.executeBatch(dcMaskBatch, batchSize);
                }
            }
            when  BATCH_DELETE {
                dataCleanCount = DataCleanSelector.getDataCleansAvailableForDeleteCount();
                if (dataCleanCount > 0) {
                    Object dcBatchParams = DataCleanBatchHelper.getBatchParams(this.scheduleWrap.dataConfigurationId, this.scheduleWrap.batchType);
                    DataCleanDeleteBatch dcDeleteBatch = new DataCleanDeleteBatch((DataCleanDeleteBatch.DataCleanDeleteBatchParameters)dcBatchParams);
                    Integer batchSize = ((DataCleanDeleteBatch.DataCleanDeleteBatchParameters)dcBatchParams).processInfo.isParent ? Constants.BATCH_SIZE_DELETE_PARENT : Constants.BATCH_SIZE_DELETE;
                    Database.executeBatch(dcDeleteBatch, batchSize);
                }
            }
            when  BATCH_ARCHIVE {
                dataCleanCount = DataCleanSelector.getDataCleansAvailableForArchiveCount();
                if (dataCleanCount > 0) {
                    Object dcBatchParams = DataCleanBatchHelper.getBatchParams(this.scheduleWrap.dataConfigurationId, this.scheduleWrap.batchType);
                    DataCleanArchiveBatch dcArchiveBatch = new DataCleanArchiveBatch((DataCleanArchiveBatch.DataCleanArchiveBatchParameters)dcBatchParams);
                    Integer batchSize = ((DataCleanArchiveBatch.DataCleanArchiveBatchParameters)dcBatchParams).processInfo.isParent ? Constants.BATCH_SIZE_ARCHIVE_PARENT : Constants.BATCH_SIZE_ARCHIVE;
                    Database.executeBatch(dcArchiveBatch, batchSize);
                }
            }
            when  BATCH_LARGE_RELATED_MASK {
                DataCleanMaskLargeChildBatch dcMaskLargeChildBatch = new DataCleanMaskLargeChildBatch(this.scheduleWrap.dcMaskLargeChildBatchParams);
                dcMaskLargeChildBatch.parentId2daClRecId = this.scheduleWrap.parentId2daClRecId;
                dcMaskLargeChildBatch.daClRecId2daClMasterId = this.scheduleWrap.daClRecId2daClMasterId;
                dcMaskLargeChildBatch.lookupFieldNames = this.scheduleWrap.lookupFieldNames;
                dcMaskLargeChildBatch.recordTypeAndFieldWrap = this.scheduleWrap.recordTypeAndFieldWrap;
                Database.executeBatch(dcMaskLargeChildBatch, Constants.BATCH_SIZE_LARGE_RELATED_MASK);
            }
            when  BATCH_LARGE_RELATED_DELETE {
                DataCleanDeleteLargeChildBatch dcDeleteLargeChildBatch = new DataCleanDeleteLargeChildBatch(this.scheduleWrap.dcDeleteLargeChildBatchParams);
                dcDeleteLargeChildBatch.parentId2daClRecId = this.scheduleWrap.parentId2daClRecId;
                dcDeleteLargeChildBatch.daClRecId2daClMasterId = this.scheduleWrap.daClRecId2daClMasterId;
                dcDeleteLargeChildBatch.lookupFieldNames = this.scheduleWrap.lookupFieldNames;
                dcDeleteLargeChildBatch.recordTypeAndFieldWrap = this.scheduleWrap.recordTypeAndFieldWrap;
                Database.executeBatch(dcDeleteLargeChildBatch, Constants.BATCH_SIZE_LARGE_RELATED_DELETE);
            }
            when  BATCH_LARGE_RELATED_ARCHIVE {
                DataCleanArchiveLargeChildBatch dcArchiveLargeChildBatch = new DataCleanArchiveLargeChildBatch(this.scheduleWrap.dcArchiveLargeChildBatchParams);
                dcArchiveLargeChildBatch.parentId2daClRecId = this.scheduleWrap.parentId2daClRecId;
                dcArchiveLargeChildBatch.daClRecId2daClMasterId = this.scheduleWrap.daClRecId2daClMasterId;
                dcArchiveLargeChildBatch.lookupFieldNames = this.scheduleWrap.lookupFieldNames;
                dcArchiveLargeChildBatch.recordTypeAndFieldWrap = this.scheduleWrap.recordTypeAndFieldWrap;
                Database.executeBatch(dcArchiveLargeChildBatch, Constants.BATCH_SIZE_LARGE_RELATED_ARCHIVE);
            }
            // when  BATCH_CLONE {
                // !Todo: Pending for next version
            // }
            when  BATCH_ROLLBACK {
                dataCleanCount = DataCleanSelector.getDataCleansAvailableForRollbackCount();
                if (dataCleanCount > 0) {
                    Object dcBatchParams = DataCleanBatchHelper.getBatchParams(this.scheduleWrap.dataConfigurationId, this.scheduleWrap.batchType);
                    DataCleanRollbackBatch.DataCleanRollbackBatchParameters dcRollbackBatchParams = (DataCleanRollbackBatch.DataCleanRollbackBatchParameters)dcBatchParams;
                    dcRollbackBatchParams.dataCleanIds = this.scheduleWrap.dataCleanIds != null? new Set<Id>(this.scheduleWrap.dataCleanIds) : null;
                    dcRollbackBatchParams.dcResultIds = this.scheduleWrap.resultIds != null? new Set<Id>(this.scheduleWrap.resultIds) : null;
                    
                    DataCleanBatchHelper.BackupFiles backupFiles = DataCleanBatchHelper.getBackupFileNames(dcRollbackBatchParams.processInfo.dcConfigId, dcRollbackBatchParams.dcResultIds, dcRollbackBatchParams.dataCleanIds);
                    dcRollbackBatchParams.parentBackupFiles = backupFiles.parentBackupFiles;
                    dcRollbackBatchParams.childBackupFiles = backupFiles.childBackupFiles;
                    if (!dcRollbackBatchParams.parentBackupFiles.isEmpty() || !dcRollbackBatchParams.childBackupFiles.isEmpty()) {
                        DataCleanRollbackBatch dcRollbackBatch = new DataCleanRollbackBatch(dcRollbackBatchParams);
                        Database.executeBatch(dcRollbackBatch, Constants.BATCH_SIZE_ROLLBACK);
                    }
                }
            }
            when  BATCH_AUTO_DELETE_BACKUP {
                DeleteDataCleanFileBatch deleteDcConfigBatch = new DeleteDataCleanFileBatch(this.scheduleWrap.batchParams);
                Id deleteDcConfigBatchId = Database.executeBatch(deleteDcConfigBatch);
            }
        }
    }

    public with sharing class ScheduleWrapper{
        public String dataConfigurationId;
        public Constants.BATCH_TYPE batchType;
        public DataCleanMaskBatch.DataCleanMaskBatchParameters dcMaskLargeChildBatchParams;
        public DataCleanDeleteBatch.DataCleanDeleteBatchParameters dcDeleteLargeChildBatchParams;
        public DataCleanArchiveBatch.DataCleanArchiveBatchParameters dcArchiveLargeChildBatchParams;
        public Map<Id, Id> parentId2daClRecId;
        public Map<Id, String> daClRecId2daClMasterId;
        public List<String> lookupFieldNames;
        public DataCleanBatchHelper.RecordTypeAndFieldWrapper recordTypeAndFieldWrap;
        public List<Id> dataCleanIds;
        public List<Id> resultIds;
        public DeleteDataCleanFileBatch.BatchParameters batchParams;
    }
}