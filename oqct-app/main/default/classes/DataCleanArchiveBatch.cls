/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-07   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class DataCleanArchiveBatch implements Database.Batchable<SObject>, Database.Stateful {

    @TestVisible private static Boolean startLargeBatchForTest = false;

    private DataCleanArchiveBatchParameters dcBatchParams;

    public DataCleanArchiveBatch(DataCleanArchiveBatchParameters dcBatchParams){
        this.dcBatchParams = dcBatchParams;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        this.initBatchParams();
        DataCleanBatchHelper.onBatchStart(this.dcBatchParams.processInfo);
        List<String> stringList = Utils.getRetryableDCStatuses();
        if (this.dcBatchParams.processInfo.isParent) {
            return Database.getQueryLocator(DataCleanSelector.getDataCleansAvailableForParentArchiveQueryString(stringList));
        } else {
            return Database.getQueryLocator(DataCleanSelector.getDataCleansAvailableForChildArchiveQueryString(this.dcBatchParams.processInfo.objectName));
        }
    } 

    @SuppressWarnings('PMD.CognitiveComplexity,PMD.NcssMethodCount')
    public void execute(Database.BatchableContext bc, List<OQCT_DaCl__Data_Clean__c> daClrecords) {  
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(this.dcBatchParams.processInfo.dcConfigId);

        Map<Id, String> daClRecId2daClMasterId = new Map<Id, String>();
        for (OQCT_DaCl__Data_Clean__c daClrecord : daClrecords) {
            daClRecId2daClMasterId.put(daClrecord.Id, daClrecord.OQCT_DaCl__Master_Id__c);
        }

        DataCleanBatchHelper.onBatchExceuteStart(daClRecId2daClMasterId.keySet(), this.dcBatchParams.processInfo);

        Map<String, Id> daClMasterId2daClRecId = new Map<String, Id>();
        for (OQCT_DaCl__Data_Clean__c daClrecord : daClrecords) {
            daClMasterId2daClRecId.put(daClrecord.OQCT_DaCl__Master_Id__c, daClrecord.Id);
        }

        Map<Id, Id> parentId2daClRecId = new Map<Id, Id>();
        for(SObject parentRecord: SObjectSelector.getParentRecordByMasterId(dcConfig, new List<String>(daClMasterId2daClRecId.keySet()))){
            String masterId = String.valueOf(parentRecord.get(dcConfig.OQCT_DaCl__Master_Object_Match_By_Field_Name__c));
            if (daClMasterId2daClRecId.containsKey(masterId)){
                parentId2daClRecId.put(String.valueOf(parentRecord.get(Constants.FIELD_RECORD_ID)), daClMasterId2daClRecId.get(masterId));
                daClMasterId2daClRecId.remove(masterId);
            }
        }

        if (!daClMasterId2daClRecId.isEmpty()) {
            if (this.dcBatchParams.processInfo.isParent) {
                Map<Id, List<Id>> dataCleanId2successRecordIds = new Map<Id, List<Id>>();
                Map<Id, Map<Id, String>> dataCleanId2errorRecordId2ErrorMessage = new Map<Id, Map<Id, String>>();
                for (Id daClRecId : daClMasterId2daClRecId.values()) {
                    String errorMessage = String.format(Constants.DC_TRIGGER_ERROR_INVALID_MASTER_ID, new List<String>{this.dcBatchParams.processInfo.objectName.capitalize()});
                    Map<Id, String> errorMasterId2ErrorMessage = new Map<Id, String>{daClMasterId2daClRecId.get(daClRecId) => errorMessage};
                    dataCleanId2errorRecordId2ErrorMessage.put(daClRecId, errorMasterId2ErrorMessage);
                }
                DataCleanBatchHelper.updateDataClean(dataCleanId2successRecordIds, dataCleanId2errorRecordId2ErrorMessage, this.dcBatchParams.processInfo);
            } else {
                Map<Id, DataCleanBatchHelper.SuccessFailureCount> dataCleanId2successFailureCount = new Map<Id, DataCleanBatchHelper.SuccessFailureCount>();
                for (Id daClRecId : daClMasterId2daClRecId.values()) {
                    dataCleanId2successFailureCount.put(daClRecId, new DataCleanBatchHelper.SuccessFailureCount());
                }
                DataCleanBatchHelper.upsertDataCleanRelatedResult(dataCleanId2successFailureCount, daClRecId2daClMasterId.keySet(), this.dcBatchParams.processInfo);
            }
            if (this.dcBatchParams.processInfo.isParent) {
                this.dcBatchParams.results.resultInfo.failure += daClMasterId2daClRecId.size();
            }
        }

        if (!parentId2daClRecId.isEmpty()) {
            
            List<String> lookupFieldNames;
            if (!this.dcBatchParams.processInfo.isParent) {
                lookupFieldNames = Utils.getLookupFieldNames(dcConfig.OQCT_DaCl__Master_Object_Name__c, this.dcBatchParams.processInfo.objectName);
            }

            Integer relatedSObjectRecordCount = 0;
            if (!this.dcBatchParams.processInfo.isParent) {
                relatedSObjectRecordCount = SObjectSelector.getRelatedRecordByIdCount(this.dcBatchParams.processInfo.objectName, lookupFieldNames, parentId2daClRecId.keySet());
                if (startLargeBatchForTest) {
                    relatedSObjectRecordCount = Constants.RELATED_RECORD_COUNT_FOR_LARGE_BATCH;
                }
            }

            DataCleanBatchHelper.RecordTypeAndFieldWrapper recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, this.dcBatchParams.processInfo);

            // For small number of child records or for parent records
            if (relatedSObjectRecordCount < Constants.RELATED_RECORD_COUNT_FOR_LARGE_BATCH) {
                Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2RecordWrapper = new Map<Id, DataCleanBatchHelper.RecordWrapper>();
                Map<Id, SObject> recordId2records = new Map<Id, SObject>(SObjectSelector.getRecordsById(this.dcBatchParams.processInfo.objectName, recordTypeAndFieldWrap.fieldsToQuery, parentId2daClRecId.keySet(), lookupFieldNames));
                if (!this.dcBatchParams.processInfo.isParent) {
                    for (OQCT_DaCl__Data_Clean_Success_Child__c dataCleanSuccessChild : DataCleanSuccessChildSelector.getDataCleanSuccededChildsByDataCleanIdsAndChildRecordIds(daClRecId2daClMasterId.keySet(), recordId2records.keySet())) {
                        recordId2records.remove(dataCleanSuccessChild.OQCT_DaCl__Child_Record_Id__c);
                    }
                }
                for (SObject record : recordId2records.values()) {
                    DataCleanBatchHelper.RecordWrapper recWrap = new DataCleanBatchHelper.RecordWrapper();
                    recWrap.record = record;
                    if (this.dcBatchParams.processInfo.isParent) {
                        recWrap.dataCleanId = parentId2daClRecId.get((Id)record.get(Constants.FIELD_RECORD_ID));
                    } else {
                        Id parentId;
                        for (String lookupFieldName : lookupFieldNames) {
                            if (record.get(lookupFieldName) != null) {
                                parentId = (Id)record.get(lookupFieldName);
                                break;
                            }
                        }
                        recWrap.dataCleanId = parentId2daClRecId.get(parentId);
                    }
                    recWrap.masterId = daClRecId2daClMasterId.get(recWrap.dataCleanId);
                    recordId2RecordWrapper.put((Id)record.get(Constants.FIELD_RECORD_ID), recWrap);
                }
                recordId2records.clear();
                DatabaseUtils.DMLResult dmlResults;
                dmlResults = this.processRecordsForArchival(recordId2RecordWrapper, recordTypeAndFieldWrap.fieldsToBackup);
                this.dcBatchParams.results.resultInfo.success += dmlResults.successIds.size();
                this.dcBatchParams.results.resultInfo.failure += dmlResults.errorIds2errorInfo.size();
                DataCleanBatchHelper.onBatchExceuteEnd(dmlResults, recordId2RecordWrapper, daClRecId2daClMasterId.keySet(), this.dcBatchParams.processInfo);

            } else {
                // Send for Large Child Record Batch Processing
                this.dcBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(this.dcBatchParams.processInfo);
                if (!this.dcBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(this.dcBatchParams.processInfo.objectName)) {
                    this.dcBatchParams.relatedObjectName2numberOfChildBatchActive.put(this.dcBatchParams.processInfo.objectName, 1);
                    this.dcBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.add(this.dcBatchParams.processInfo.objectName);
                } else {
                    Integer numberOfChildBatchActive = this.dcBatchParams.relatedObjectName2numberOfChildBatchActive.get(this.dcBatchParams.processInfo.objectName);
                    this.dcBatchParams.relatedObjectName2numberOfChildBatchActive.put(this.dcBatchParams.processInfo.objectName, numberOfChildBatchActive + 1);
                }
                DataCleanBatchHelper.updateRelatedObjectName2numberOfChildBatchActive(this.dcBatchParams.processInfo, this.dcBatchParams.relatedObjectName2numberOfChildBatchActive);
                this.initBatchForLargeNumberChildRecords(parentId2daClRecId, daClRecId2daClMasterId, lookupFieldNames, recordTypeAndFieldWrap, this.dcBatchParams.processInfo.dcConfigId);
            }
        } 
    }

    public void finish(Database.BatchableContext bc) {
        if (this.dcBatchParams.processInfo.isParent) {
            this.saveAllReports();
            DataCleanBatchHelper.onBatchFinishParent(this.dcBatchParams.processInfo, this.dcBatchParams.results.resultInfo);
            if (this.dcBatchParams.processInfo.isAllJobCompleted()) {
                DataCleanBatchHelper.onBatchFinishAllJobCompleted(this.dcBatchParams.processInfo);
                // Send Result Email
                DataCleanBatchHelper.sendResultEmail(this.dcBatchParams.processInfo);
            }
        } else {
            this.saveAllReports();
            this.dcBatchParams.processedRelatedObjects.add(this.dcBatchParams.processInfo.objectName);
            Map<String, Integer> relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(this.dcBatchParams.processInfo);
            if (relatedObjectName2numberOfChildBatchActive.isEmpty() || !relatedObjectName2numberOfChildBatchActive.containsKey(this.dcBatchParams.processInfo.objectName)) {
                DataCleanBatchHelper.onBatchFinishChild(this.dcBatchParams.processInfo, this.dcBatchParams.results.resultInfo);
            }
            this.dcBatchParams.results = null;
            this.dcBatchParams.results = ResultsUtil.initialize(this.dcBatchParams.results);

            this.initBatchParams();
            
            // Re-initiate Batch
            DataCleanArchiveBatch dcArchiveBatch = new DataCleanArchiveBatch(this.dcBatchParams);
            Integer batchSize = this.dcBatchParams.processInfo.isParent ? Constants.BATCH_SIZE_ARCHIVE_PARENT : Constants.BATCH_SIZE_ARCHIVE;
            Database.executeBatch(dcArchiveBatch, batchSize);
        }
    }

    private OQCT_DaCl__DC_Configuration__c initBatchParams(){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(this.dcBatchParams.processInfo.dcConfigId);
        this.dcBatchParams.processInfo = DataCleanBatchHelper.updateProcessInformation(this.dcBatchParams.processInfo, dcConfig, this.dcBatchParams.processedRelatedObjects);
        this.dcBatchParams.results = ResultsUtil.initialize(this.dcBatchParams.results);
        return dcConfig;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private void initBatchForLargeNumberChildRecords(Map<Id, Id> parentId2daClRecId, Map<Id, String> daClRecId2daClMasterId, List<String> lookupFieldNames, DataCleanBatchHelper.RecordTypeAndFieldWrapper recordTypeAndFieldWrap, Id dcConfigId){
        DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrap.batchType  = Constants.BATCH_TYPE.BATCH_LARGE_RELATED_ARCHIVE;
        scheduleWrap.dcArchiveLargeChildBatchParams = this.dcBatchParams;
        scheduleWrap.parentId2daClRecId = parentId2daClRecId;
        scheduleWrap.daClRecId2daClMasterId = daClRecId2daClMasterId;
        scheduleWrap.lookupFieldNames = lookupFieldNames;
        scheduleWrap.recordTypeAndFieldWrap = recordTypeAndFieldWrap;
        scheduleWrap.dataConfigurationId = dcConfigId;
        String cronString = DateUtils.getCronStringFromDateTime(DateUtils.getNow().addSeconds(10));
        String jobId = DCConfigurationSelector.getDCConfigurationJobIdById(this.dcBatchParams.processInfo.dcConfigId).OQCT_DaCl__Job_Id__c;
        StringBuilder jobName = new StringBuilder();
        jobName.setSeparator(Constants.LITERAL_HYPHEN);
        jobName.append(CronTriggerSelector.getCronTriggerNameById(jobId)[0].CronJobDetail.Name);
        jobName.append(this.dcBatchParams.processInfo.objectName);
        jobName.append(this.dcBatchParams.relatedObjectName2numberOfChildBatchActive.get(this.dcBatchParams.processInfo.objectName));
        Id scheduleJobId = System.Schedule(jobName.toString(), cronString, new DataCleanSchedulable(scheduleWrap));
    }

    private void saveAllReports(){
        this.dcBatchParams.successReport = ReportUtil.saveSuccessReport(this.dcBatchParams.successReport, this.dcBatchParams.processInfo);
        this.dcBatchParams.backupReport = ReportUtil.saveBackupReport(this.dcBatchParams.backupReport, this.dcBatchParams.processInfo);
    }

    private DatabaseUtils.DMLResult processRecordsForArchival(Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2RecordWrapper, List<String> fieldsToBackup){
        Map<Id, SObject> id2SObjectRecordClone = new Map<Id, SObject>();
        Map<String, Schema.SObjectField> sObjectFieldMap = Utils.getSObjectDescription(this.dcBatchParams.processInfo.objectName).fields.getMap();
        for (Id recordId : recordId2RecordWrapper.keySet()) {
            DataCleanBatchHelper.RecordWrapper recordWrap = recordId2RecordWrapper.get(recordId);
            SObject record = recordWrap.record;
            SObject recordClone = record.getSObjectType().newSObject();
            recordClone.put(Constants.FIELD_RECORD_ID, recordId);
            for (String fieldToArchive : fieldsToBackup) {
                recordClone.put(fieldToArchive, record.get(fieldToArchive));
            }
            id2SObjectRecordClone.put(recordId, recordClone);
        }
        DatabaseUtils.DMLResult archiveResult = new DatabaseUtils.DMLResult();
        archiveResult.successIds = new List<Id>(recordId2RecordWrapper.keySet());
        archiveResult.errorIds2errorInfo = new Map <Id, List<Database.Error>>();
        this.processSuccessRecords(archiveResult.successIds, id2SObjectRecordClone, recordId2RecordWrapper);
        return archiveResult;
    }

    private void processSuccessRecords(List<Id> successIds, Map<Id, SObject> id2SObjectRecordClone, Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2RecordWrapper){
        if (successIds.isEmpty()) {
            return;
        }
        // Backup Report
        ReportUtil.BackupReportInfo backupReportInfo = new ReportUtil.BackupReportInfo();
        backupReportInfo.processInfo = this.dcBatchParams.processInfo;
        backupReportInfo.recordId2recordWrap = new Map<Id, DataCleanBatchHelper.RecordWrapper>();

        // Success Report
        ReportUtil.SuccessReportInfo successReportInfo = new ReportUtil.SuccessReportInfo();
        successReportInfo.processInfo = this.dcBatchParams.processInfo;
        successReportInfo.successReportInfoWraps = new List<ReportUtil.SuccessReportInfoWrapper>();

        for (Id recordId : recordId2RecordWrapper.keySet()) {
            DataCleanBatchHelper.RecordWrapper recordWrap = recordId2RecordWrapper.get(recordId);
            
            // Backup Report
            DataCleanBatchHelper.RecordWrapper backupRecordWrap = new DataCleanBatchHelper.RecordWrapper();
            backupRecordWrap.dataCleanId = recordWrap.dataCleanId;
            backupRecordWrap.masterId = recordWrap.masterId;
            backupRecordWrap.record = id2SObjectRecordClone.get(recordId);
            backupReportInfo.recordId2recordWrap.put(recordId, backupRecordWrap);

            // Success Report
            ReportUtil.SuccessReportInfoWrapper successReportInfoWrap = new ReportUtil.SuccessReportInfoWrapper();
            successReportInfoWrap.recordId = recordId;
            successReportInfoWrap.masterId = recordWrap.masterId;
            successReportInfo.successReportInfoWraps.add(successReportInfoWrap);
        }
        // Backup Report
        this.dcBatchParams.backupReport = ReportUtil.prepareBackupReport(backupReportInfo, this.dcBatchParams.backupReport);

        // Success Report
        this.dcBatchParams.successReport = ReportUtil.prepareSuccessReport(successReportInfo, this.dcBatchParams.successReport);
    }

    public with sharing class DataCleanArchiveBatchParameters {
        // Process Information
        public DataCleanBatchHelper.ProcessInformation processInfo;

        // Related Object List
        public List<String> processedRelatedObjects = new List<String>();

        // Child Object Records went for Large Batch Processing
        public Map<String, Integer> relatedObjectName2numberOfChildBatchActive = new Map<String, Integer>();

        //Result Variable
        public ResultsUtil results;

        //Report Variables
        public ReportUtil.SuccessReport successReport;
        public ReportUtil.ErrorReport errorReport;
        public ReportUtil.BackupReport backupReport;
    }
}