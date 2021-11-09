/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-20
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-09   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class DataCleanRollbackBatch implements Database.Batchable<ReportUtil.BackupReportContent>, Database.Stateful {

    private DataCleanRollbackBatch.DataCleanRollbackBatchParameters dcBatchParams;

    public DataCleanRollbackBatch(DataCleanRollbackBatch.DataCleanRollbackBatchParameters dcBatchParams){
        this.dcBatchParams = dcBatchParams;
    }
    
    public Iterable<ReportUtil.BackupReportContent> start(Database.BatchableContext bc) {

        List<ReportUtil.BackupReportContent> backupContents = new List<ReportUtil.BackupReportContent>();

        if (!this.dcBatchParams.parentBackupFiles.isEmpty()) {
            backupContents = DataCleanBatchHelper.getBackupReportContents(this.dcBatchParams.parentBackupFiles[0]);
        } else {
            if (this.dcBatchParams.processInfo.isParent) {
                this.dcBatchParams.results = ResultsUtil.initialize(this.dcBatchParams.results);
                DataCleanBatchHelper.onBatchFinishParent(this.dcBatchParams.processInfo, this.dcBatchParams.results.resultInfo);
                this.dcBatchParams.processInfo.isParent = false;
            }
            if (!this.dcBatchParams.childBackupFiles.isEmpty()) {
                backupContents = DataCleanBatchHelper.getBackupReportContents(this.dcBatchParams.childBackupFiles[0]);
            }
        }

        this.dcBatchParams.results = ResultsUtil.initialize(this.dcBatchParams.results);

        return new BackupReportContentIterable(backupContents);
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    public void execute(Database.BatchableContext bc, List<ReportUtil.BackupReportContent> backupContents) {

        if (!backupContents.isEmpty()) {
            this.dcBatchParams.processInfo.objectName = backupContents[0].objName;
        }

        Set<Id> dataCleanIds = new Set<Id>();

        List<SObject> rollbackRecords = new List<SObject>();
        Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2recordWrapper = new Map<Id, DataCleanBatchHelper.RecordWrapper>();

        Map<Id, SObject> rollbackRecordId2RecordForDelete = new Map<Id, SObject>();
        
        for (ReportUtil.BackupReportContent backupContent : backupContents) {
            DataCleanBatchHelper.RecordWrapper recWrap = new DataCleanBatchHelper.RecordWrapper();
            recWrap.record = backupContent.record;
            recWrap.dataCleanId = backupContent.dataCleanId;
            recWrap.masterId = backupContent.masterId;
            if (this.dcBatchParams.dataCleanIds != null && this.dcBatchParams.dataCleanIds.contains(backupContent.dataCleanId)) {
                if (backupContent.actionType == Constants.PROCESS_MASK || backupContent.actionType == Constants.PROCESS_ARCHIVE) {
                    rollbackRecords.add(backupContent.record);
                }else if (backupContent.actionType == Constants.PROCESS_DELETE) {
                    rollbackRecordId2RecordForDelete.put(backupContent.recordId, backupContent.record);
                }
                recordId2recordWrapper.put(backupContent.recordId, recWrap);
                dataCleanIds.add(backupContent.dataCleanId);
            }else if (this.dcBatchParams.dataCleanIds == null) {
                if (backupContent.actionType == Constants.PROCESS_MASK || backupContent.actionType == Constants.PROCESS_ARCHIVE) {
                    rollbackRecords.add(backupContent.record);
                }else if (backupContent.actionType == Constants.PROCESS_DELETE) {
                    rollbackRecordId2RecordForDelete.put(backupContent.recordId, backupContent.record);
                }
                recordId2recordWrapper.put(backupContent.recordId, recWrap);
                dataCleanIds.add(backupContent.dataCleanId);
            }
        }

        DataCleanBatchHelper.onBatchExceuteStart(dataCleanIds, this.dcBatchParams.processInfo);

        DatabaseUtils.DMLResult dmlResults = new DatabaseUtils.DMLResult();
        dmlResults.successIds = new List<Id>();
        dmlResults.errorIds2errorInfo = new Map <Id, List<Database.Error>>();

        if (!rollbackRecords.isEmpty()) {
            dmlResults = this.processRollback(rollbackRecords, recordId2recordWrapper);
        }
        if (!rollbackRecordId2RecordForDelete.isEmpty()) {
            dmlResults = this.processRollbackForDelete(rollbackRecordId2RecordForDelete, recordId2recordWrapper);
        }

        this.dcBatchParams.results.resultInfo.success += dmlResults.successIds.size();
        this.dcBatchParams.results.resultInfo.failure += dmlResults.errorIds2errorInfo.size();
        
        DataCleanBatchHelper.onBatchExceuteEnd(dmlResults, recordId2recordWrapper, dataCleanIds, this.dcBatchParams.processInfo);

    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    public void finish(Database.BatchableContext bc) {
        if (this.dcBatchParams.processInfo.isParent) {
            this.dcBatchParams.parentBackupFiles.remove(0);
        } else {
            this.dcBatchParams.childBackupFiles.remove(0);
        }

        if (this.dcBatchParams.isParentBackupFilesCompleted() && this.dcBatchParams.processInfo.isParent) {
            this.saveAllReports();
            DataCleanBatchHelper.onBatchFinishParent(this.dcBatchParams.processInfo, this.dcBatchParams.results.resultInfo);
            this.dcBatchParams.results = null;
            this.dcBatchParams.results = ResultsUtil.initialize(this.dcBatchParams.results);
            this.dcBatchParams.processInfo.isParent = false;
            if (this.dcBatchParams.isChildBackupFilesCompleted()) {
                DataCleanBatchHelper.onBatchFinishChild(this.dcBatchParams.processInfo, this.dcBatchParams.results.resultInfo);
                DataCleanBatchHelper.onBatchFinishAllJobCompleted(this.dcBatchParams.processInfo);
                // Send Result Email
                DataCleanBatchHelper.sendResultEmail(this.dcBatchParams.processInfo);
            } else {
                DataCleanRollbackBatch dcRollbackBatch = new DataCleanRollbackBatch(this.dcBatchParams);
                Database.executeBatch(dcRollbackBatch, Constants.BATCH_SIZE_ROLLBACK);
            }
        } else {
            if (!this.dcBatchParams.processInfo.isParent) {
                this.saveAllReports();
                DataCleanBatchHelper.onBatchFinishChild(this.dcBatchParams.processInfo, this.dcBatchParams.results.resultInfo);
                this.dcBatchParams.results = null;
                this.dcBatchParams.results = ResultsUtil.initialize(this.dcBatchParams.results);
                if (!this.dcBatchParams.isChildBackupFilesCompleted()) {
                    DataCleanRollbackBatch dcRollbackBatch = new DataCleanRollbackBatch(this.dcBatchParams);
                    Database.executeBatch(dcRollbackBatch, Constants.BATCH_SIZE_ROLLBACK);
                } else {
                    DataCleanBatchHelper.onBatchFinishAllJobCompleted(this.dcBatchParams.processInfo);
                    // Send Result Email
                    DataCleanBatchHelper.sendResultEmail(this.dcBatchParams.processInfo);
                }
            } else {
                DataCleanRollbackBatch dcRollbackBatch = new DataCleanRollbackBatch(this.dcBatchParams);
                Database.executeBatch(dcRollbackBatch, Constants.BATCH_SIZE_ROLLBACK);
            }
        }
    }

    private void saveAllReports(){
        this.dcBatchParams.successReport = ReportUtil.saveSuccessReport(this.dcBatchParams.successReport, this.dcBatchParams.processInfo);
        this.dcBatchParams.errorReport = ReportUtil.saveErrorReport(this.dcBatchParams.errorReport, this.dcBatchParams.processInfo);
    }

    private DatabaseUtils.DMLResult processRollback(List<SObject> records, Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2RecordWrapper){
        DatabaseUtils.DMLResult updateResults = DatabaseUtils.updateRecordsAndReturnDMLResult(records);
        this.processSuccessRecords(updateResults.successIds, recordId2RecordWrapper);
        this.processErrorRecords(updateResults.errorIds2errorInfo, recordId2RecordWrapper);
        return updateResults;
    }

    private DatabaseUtils.DMLResult processRollbackForDelete(Map<Id, SObject> recordId2record, Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2RecordWrapper){
        Map<Id, SObject> recordId2recordFromRecycleBin = SObjectSelector.getRecycleBinRecordId2RecordByIdAndObject(this.dcBatchParams.processInfo.objectName, recordId2record.keySet());
        for (Id recordId : recordId2record.keySet()) {
            if (recordId2recordFromRecycleBin.containsKey(recordId)) {
                recordId2record.remove(recordId);
            }
        }
        if (this.dcBatchParams.processInfo.objectName == Constants.OBJECT_ATTACHMENT) {
            recordId2record.clear();
        }
        DatabaseUtils.DMLResult undeleteResults = DatabaseUtils.undeleteRecordsAndReturnDMLResult(recordId2recordFromRecycleBin.values());
        DatabaseUtils.DMLResult insertResults = DatabaseUtils.insertRecordsAndReturnDMLResult(recordId2record.values());

        DatabaseUtils.DMLResult dmlResults = new DatabaseUtils.DMLResult();
        dmlResults.successIds = new List<Id>();
        dmlResults.errorIds2errorInfo = new Map <Id, List<Database.Error>>();

        dmlResults.successIds.addAll(undeleteResults.successIds);
        dmlResults.successIds.addAll(insertResults.successIds);
        dmlResults.errorIds2errorInfo.putAll(undeleteResults.errorIds2errorInfo);
        dmlResults.errorIds2errorInfo.putAll(insertResults.errorIds2errorInfo);

        this.processSuccessRecords(dmlResults.successIds, recordId2RecordWrapper);
        this.processErrorRecords(dmlResults.errorIds2errorInfo, recordId2RecordWrapper);
        return dmlResults;
    }

    private void processSuccessRecords(List<Id> successIds, Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2RecordWrapper){
        if (successIds.isEmpty()) {
            return;
        }

        // Success Report
        ReportUtil.SuccessReportInfo successReportInfo = new ReportUtil.SuccessReportInfo();
        successReportInfo.processInfo = this.dcBatchParams.processInfo;
        successReportInfo.successReportInfoWraps = new List<ReportUtil.SuccessReportInfoWrapper>();

        for (Id recordId : recordId2RecordWrapper.keySet()) {
            DataCleanBatchHelper.RecordWrapper recordWrap = recordId2RecordWrapper.get(recordId);

            // Success Report
            ReportUtil.SuccessReportInfoWrapper successReportInfoWrap = new ReportUtil.SuccessReportInfoWrapper();
            successReportInfoWrap.recordId = recordId;
            successReportInfoWrap.masterId = recordWrap.masterId;
            successReportInfo.successReportInfoWraps.add(successReportInfoWrap);
        }

        // Success Report
        this.dcBatchParams.successReport = ReportUtil.prepareSuccessReport(successReportInfo, this.dcBatchParams.successReport);
    }

    private void processErrorRecords(Map<Id, List<Database.Error>> errorIds2errorInfo, Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2RecordWrapper){
        if (errorIds2errorInfo.isEmpty()) {
            return;
        }
        ReportUtil.ErrorReportInfo errorReportInfo = new ReportUtil.ErrorReportInfo();
        errorReportInfo.processInfo = this.dcBatchParams.processInfo;
        errorReportInfo.errorReportInfoWraps = new List<ReportUtil.ErrorReportInfoWrapper>();
        for (Id recordId : recordId2RecordWrapper.keySet()) {
            DataCleanBatchHelper.RecordWrapper recordWrap = recordId2RecordWrapper.get(recordId);
            ReportUtil.ErrorReportInfoWrapper errorReportInfoWrap = new ReportUtil.ErrorReportInfoWrapper();
            errorReportInfoWrap.recordId = recordId;
            errorReportInfoWrap.masterId = recordWrap.masterId;
            errorReportInfoWrap.errors = errorIds2errorInfo.get(recordId);
            errorReportInfo.errorReportInfoWraps.add(errorReportInfoWrap);
        }
        this.dcBatchParams.errorReport = ReportUtil.prepareErrorReport(errorReportInfo, this.dcBatchParams.errorReport);
    }

    public with sharing class DataCleanRollbackBatchParameters {

        public DataCleanBatchHelper.ProcessInformation processInfo;
        
        public List<String> parentBackupFiles;

        public List<String> childBackupFiles;

        public Set<Id> dataCleanIds;

        public Set<Id> dcResultIds;

        //Result Variable
        public ResultsUtil results;

        //Report Variables
        public ReportUtil.SuccessReport successReport;
        public ReportUtil.ErrorReport errorReport;

        public Boolean isParentBackupFilesCompleted(){
            return this.parentBackupFiles.isEmpty();
        }

        public Boolean isChildBackupFilesCompleted(){
            return this.childBackupFiles.isEmpty();
        }
    }

}