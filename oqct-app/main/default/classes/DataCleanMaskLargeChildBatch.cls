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
public with sharing class DataCleanMaskLargeChildBatch implements Database.Batchable<SObject>, Database.Stateful {

    private DataCleanMaskBatch.DataCleanMaskBatchParameters dcBatchParams;
    public Map<Id, Id> parentId2daClRecId;
    public Map<Id, String> daClRecId2daClMasterId;
    public List<String> lookupFieldNames;
    public DataCleanBatchHelper.RecordTypeAndFieldWrapper recordTypeAndFieldWrap;

    public DataCleanMaskLargeChildBatch(DataCleanMaskBatch.DataCleanMaskBatchParameters dcBatchParams) {
        this.dcBatchParams = dcBatchParams;
        this.dcBatchParams.successReport = null;
        this.dcBatchParams.errorReport = null;
        this.dcBatchParams.backupReport = null;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Id> stringList = this.parentId2daClRecId.keySet();
        return Database.getQueryLocator(SObjectSelector.getRecordsByIdString(this.dcBatchParams.processInfo.objectName, this.recordTypeAndFieldWrap.fieldsToQuery, this.parentId2daClRecId.keySet(), this.lookupFieldNames));
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        Map<Id, SObject> recordId2records = new Map<Id, SObject>(records);
        for (OQCT_DaCl__Data_Clean_Success_Child__c dataCleanSuccessChild : DataCleanSuccessChildSelector.getDataCleanSuccededChildsByDataCleanIdsAndChildRecordIds(this.daClRecId2daClMasterId.keySet(), recordId2records.keySet())) {
            recordId2records.remove(dataCleanSuccessChild.OQCT_DaCl__Child_Record_Id__c);
        }
        Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2RecordWrapper = new Map<Id, DataCleanBatchHelper.RecordWrapper>();
        for (SObject record : recordId2records.values()) {
            DataCleanBatchHelper.RecordWrapper recWrap = new DataCleanBatchHelper.RecordWrapper();
            recWrap.record = record;
            Id parentId;
            for (String lookupFieldName : lookupFieldNames) {
                if (record.get(lookupFieldName) != null) {
                    parentId = (Id)record.get(lookupFieldName);
                    break;
                }
            }
            recWrap.dataCleanId = parentId2daClRecId.get(parentId);
            recWrap.masterId = this.daClRecId2daClMasterId.get(recWrap.dataCleanId);
            recordId2RecordWrapper.put((Id)record.get(Constants.FIELD_RECORD_ID), recWrap);
        }
        recordId2records.clear();
        DatabaseUtils.DMLResult dmlResults;
        if (this.dcBatchParams.processInfo.processName == this.dcBatchParams.processInfo.relatedProcessName) {
            dmlResults = this.processRecordsForMasking(recordId2RecordWrapper, recordTypeAndFieldWrap.recordTypesAndFields);
        } else {
            dmlResults = this.processRecordsForDeletion(recordId2RecordWrapper, this.recordTypeAndFieldWrap.fieldsToBackup);
        }
        this.dcBatchParams.results.resultInfo.success += dmlResults.successIds.size();
        this.dcBatchParams.results.resultInfo.failure += dmlResults.errorIds2errorInfo.size();
        DataCleanBatchHelper.onBatchExceuteEnd(dmlResults, recordId2RecordWrapper, this.daClRecId2daClMasterId.keySet(), this.dcBatchParams.processInfo);
        DataCleanBatchHelper.deleteFieldHistory(this.dcBatchParams.processInfo, this.recordTypeAndFieldWrap.recordTypesAndFields, recordId2RecordWrapper.keySet());
    }

    public void finish(Database.BatchableContext bc) {
        this.saveAllReports();
        this.dcBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(this.dcBatchParams.processInfo);
        if (this.dcBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(this.dcBatchParams.processInfo.objectName)) {
            Integer numberOfChildBatchActive = this.dcBatchParams.relatedObjectName2numberOfChildBatchActive.get(this.dcBatchParams.processInfo.objectName) - 1;
            if (numberOfChildBatchActive == 0) {
                this.dcBatchParams.relatedObjectName2numberOfChildBatchActive.remove(this.dcBatchParams.processInfo.objectName);
            } else {
                this.dcBatchParams.relatedObjectName2numberOfChildBatchActive.put(this.dcBatchParams.processInfo.objectName, numberOfChildBatchActive);
            }
        }
        DataCleanBatchHelper.updateRelatedObjectName2numberOfChildBatchActive(this.dcBatchParams.processInfo, this.dcBatchParams.relatedObjectName2numberOfChildBatchActive);
        if (this.dcBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.contains(this.dcBatchParams.processInfo.objectName)) {
            this.dcBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.remove(this.dcBatchParams.processInfo.objectName);
        }
        DataCleanBatchHelper.updateDataCleanRelatedResult(this.dcBatchParams.processInfo, this.daClRecId2daClMasterId.keySet());
        if (this.dcBatchParams.relatedObjectName2numberOfChildBatchActive.isEmpty() || !this.dcBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(this.dcBatchParams.processInfo.objectName)) {
            DataCleanBatchHelper.onBatchFinishChild(this.dcBatchParams.processInfo, this.dcBatchParams.results.resultInfo);
        }else {
            DataCleanBatchHelper.upsertDcRelatedResult(this.dcBatchParams.processInfo, this.dcBatchParams.results.resultInfo);
        }
        if (this.dcBatchParams.processInfo.isAllJobCompleted()) {
            DataCleanBatchHelper.onBatchFinishAllJobCompleted(this.dcBatchParams.processInfo);
            // Send Result Email
            DataCleanBatchHelper.sendResultEmail(this.dcBatchParams.processInfo);
        }
    }

    private void saveAllReports(){
        this.dcBatchParams.successReport = ReportUtil.saveSuccessReport(this.dcBatchParams.successReport, this.dcBatchParams.processInfo);
        this.dcBatchParams.errorReport = ReportUtil.saveErrorReport(this.dcBatchParams.errorReport, this.dcBatchParams.processInfo);
        this.dcBatchParams.backupReport = ReportUtil.saveBackupReport(this.dcBatchParams.backupReport, this.dcBatchParams.processInfo);
    }

    private DatabaseUtils.DMLResult processRecordsForMasking(Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2RecordWrapper, Map<String, DataCleanBatchHelper.FieldToMaskAndEmptyWrapper> recordTypesAndFields){
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Map<Id, SObject> id2SObjectRecordClone = new Map<Id, SObject>();
        Map<String, Schema.SObjectField> sObjectFieldMap = Utils.getSObjectDescription(this.dcBatchParams.processInfo.objectName).fields.getMap();
        List<SObject> recordsToUpdate = new List<SObject>();
        for (Id recordId : recordId2RecordWrapper.keySet()) {
            DataCleanBatchHelper.RecordWrapper recordWrap = recordId2RecordWrapper.get(recordId);
            SObject record = recordWrap.record;
            DataCleanBatchHelper.FieldToMaskAndEmptyWrapper fieldToMaskAndEmptyWrap;
            fieldToMaskAndEmptyWrap = recordTypesAndFields.size() == 1 ? recordTypesAndFields.values()[0] : recordTypesAndFields.get((Id)record.get(Constants.FIELD_RECORD_TYPE_ID));
            SObject recordClone = record.getSObjectType().newSObject();
            recordClone.put(Constants.FIELD_RECORD_ID, recordId);
            for (String fieldToEmpty : fieldToMaskAndEmptyWrap.fieldsToEmpty) {
                recordClone.put(fieldToEmpty, record.get(fieldToEmpty));
                record.put(fieldToEmpty, null);
            }
            for (String fieldToMask : fieldToMaskAndEmptyWrap.fieldsToMask) {
                recordClone.put(fieldToMask, record.get(fieldToMask));
                Schema.DescribeFieldResult fieldDescription = sObjectFieldMap.get(fieldToMask).getDescribe();
                Object maskedValue = EncryptUtil.getEncryptedValue(record.get(fieldToMask), fieldDescription, dataTypeName2dataTypeConfig);
                record.put(fieldToMask, maskedValue);
            }
            id2SObjectRecordClone.put(recordId, recordClone);
            recordsToUpdate.add(record);
        }
        DatabaseUtils.DMLResult updateResults = DatabaseUtils.updateRecordsAndReturnDMLResult(recordsToUpdate);
        this.processSuccessRecords(updateResults.successIds, id2SObjectRecordClone, recordId2RecordWrapper);
        this.processErrorRecords(updateResults.errorIds2errorInfo, recordId2RecordWrapper);
        return updateResults;
        
    }

    private DatabaseUtils.DMLResult processRecordsForDeletion(Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2RecordWrapper, List<String> fieldsToBackup){
        List<SObject> recordsToDelete = new List<SObject>();
        Map<Id, SObject> id2SObjectRecordClone = new Map<Id, SObject>();
        for (Id recordId : recordId2RecordWrapper.keySet()) {
            DataCleanBatchHelper.RecordWrapper recordWrap = recordId2RecordWrapper.get(recordId);
            recordsToDelete.add(recordWrap.record);
            SObject recordClone = recordWrap.record.getSObjectType().newSObject();
            if (this.dcBatchParams.processInfo.objectName != Constants.OBJECT_ATTACHMENT) {
                for (String fieldToBackup : fieldsToBackup) {
                    recordClone.put(fieldToBackup, recordWrap.record.get(fieldToBackup));
                }
                id2SObjectRecordClone.put(recordId, recordClone);
            } else {
                recordClone.put(Constants.FIELD_RECORD_ID, recordId);
                id2SObjectRecordClone.put(recordId, recordClone);
            }
        }
        DatabaseUtils.DMLResult deleteResults = DatabaseUtils.deleteRecordsAndReturnDMLResult(recordsToDelete);
        this.processSuccessRecords(deleteResults.successIds, id2SObjectRecordClone, recordId2RecordWrapper);
        this.processErrorRecords(deleteResults.errorIds2errorInfo, recordId2RecordWrapper);
        return deleteResults;
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

}