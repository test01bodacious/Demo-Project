/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-20
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-06   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.ExcessivePublicCount')
public with sharing class DatabaseUtils {
    
    private static final String ERROR_STRING_SEPARATOR = '\n';
    private static final Boolean LOG_DML_ERRORS = true;

    private static Map<Id, String> put(Map<Id, String> recordId2ErrorMessages, Id recordId, String errorMessages){
        if (!recordId2ErrorMessages.containsKey(recordId)) {
            recordId2ErrorMessages.put(recordId, errorMessages);
        } else {
            String oldErrorMessages = recordId2ErrorMessages.get(recordId);
            recordId2ErrorMessages.put(recordId, oldErrorMessages + '\n' + errorMessages);
        }
        return recordId2ErrorMessages;
    }

    public static String getErrorString(List<Database.Error> errors) {
        final StringBuilder fullErrors = new StringBuilder();
        fullErrors.setSeparator(DatabaseUtils.ERROR_STRING_SEPARATOR);
        for (Database.Error error : errors) {
            fullErrors.append(error.getStatusCode() + ': ' + error.getMessage());
            fullErrors.append('Fields that affected this error: ' + error.getFields());
        }
        return fullErrors.toString();
    }

    private static void logErrorsInsert(List<Database.SaveResult> results) {
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                Utils.debug('The following Error occurred during insert of record');
                Utils.debug(DatabaseUtils.getErrorString(sr.getErrors()));
            }
        }
    }

    private static void logErrorsUpdate(List<Database.SaveResult> results, List<SObject> records) {
        for (Integer i = 0; i < records.size(); i++) {
            Database.SaveResult sr = results[i];
            SObject origRecord = records[i];
            if (!sr.isSuccess()) {
                Utils.debug('The following Error occurred during update of record', (Id)origRecord.get(Constants.FIELD_RECORD_ID));
                Utils.debug(DatabaseUtils.getErrorString(sr.getErrors()));
            }
        }
    }

    private static void logErrorsUpsert(List<Database.UpsertResult> results) {
        for (Database.UpsertResult ur : results) {
            if (!ur.isSuccess()) {
                Utils.debug('The following Error occurred during upsert of record', ur.getId());
                Utils.debug(DatabaseUtils.getErrorString(ur.getErrors()));
            }
        }
    }

    private static void logErrorsDelete(List<Database.DeleteResult> results) {
        for (Database.DeleteResult dr : results) {
            if (!dr.isSuccess()) {
                Utils.debug('The following Error occurred during delete of record', dr.getId());
                Utils.debug(DatabaseUtils.getErrorString(dr.getErrors()));
            }
        }
    }

    private static void logErrorsEmptyRecycleBin(List<Database.EmptyRecycleBinResult> results) {
        for (Database.EmptyRecycleBinResult erbr : results) {
            if (!erbr.isSuccess()) {
                Utils.debug('The following Error occurred during emptying recycle bin', erbr.getId());
                Utils.debug(DatabaseUtils.getErrorString(erbr.getErrors()));
            }
        }
    }

    private static void logErrorsUndelete(List<Database.UndeleteResult> results) {
        for (Database.UndeleteResult udr : results) {
            if (!udr.isSuccess()) {
                Utils.debug('The following Error occurred during undelete of record', udr.getId());
                Utils.debug(DatabaseUtils.getErrorString(udr.getErrors()));
            }
        }
    }

    private static void validateDMLLimits(List<SObject> records){
        if (records.size() > Utils.getRemainingDMLRowsLimit()) {
            throw new DataCleanCustomExceptions.DMLRowLimitException(Constants.DML_ROW_EXCEPTION_MESSAGE);
        }
        if (Utils.getRemainingDMLLimit() == 0) {
            throw new DataCleanCustomExceptions.DMLStatementLimitException(Constants.DML_STATEMENT_EXCEPTION_MESSAGE);
        }
    }

    private static void validateDMLPermission(List<SObject> records, Constants.DML_OPERATION dmlOperation){
        if (records.isEmpty()) {
            return;
        }
        Boolean isDMLPermitted = false;
        Schema.DescribeSObjectResult sObjectDescription = records.getSObjectType().getDescribe();
        SObjectAccessDecision decision;
        switch on dmlOperation {
            when  DML_INSERT{
                isDMLPermitted = sObjectDescription.isCreateable();
                decision = Security.stripInaccessible(AccessType.CREATABLE, records);
            }
            when  DML_UPDATE{
                isDMLPermitted = sObjectDescription.isUpdateable();
                decision = Security.stripInaccessible(AccessType.UPDATABLE, records);
            }
            when  DML_UPSERT{
                isDMLPermitted = sObjectDescription.isCreateable() && sObjectDescription.isUpdateable();
                decision = Security.stripInaccessible(AccessType.UPSERTABLE, records);
            }
            when  DML_DELETE{
                isDMLPermitted = sObjectDescription.isDeletable();
            }
            when  DML_UNDELETE{
                isDMLPermitted = sObjectDescription.isUndeletable();
            }
        }
        if (!isDMLPermitted) {
            String exceptionString = Constants.DML_INSUFFICIENT_PRIVILIEGES_EXCEPTION_MESSAGE;
            List<String> exceptionStringFormatParams = new List<String>();
            exceptionStringFormatParams.add(dmlOperation.name());
            exceptionStringFormatParams.add(sObjectDescription.getLabel());
            exceptionString = String.format(exceptionString, exceptionStringFormatParams);
            throw new DataCleanCustomExceptions.InsufficientPrivilegesException(exceptionString);
        }
    }

    private static List<Database.SaveResult> doInsert(List<SObject> records) {
        DatabaseUtils.validateDMLLimits(records);
        DatabaseUtils.validateDMLPermission(records, Constants.DML_OPERATION.DML_INSERT);
        return Database.insert(records, false);
    }

    private static List<Database.SaveResult> doUpdate(List<SObject> records) {
        DatabaseUtils.validateDMLLimits(records);
        DatabaseUtils.validateDMLPermission(records, Constants.DML_OPERATION.DML_UPDATE);
        return Database.update(records, false);
    }

    private static List<Database.UpsertResult> doUpsert(List<SObject> records) {
        DatabaseUtils.validateDMLLimits(records);
        DatabaseUtils.validateDMLPermission(records, Constants.DML_OPERATION.DML_UPSERT);
        return Database.upsert(records, false);
    }

    private static List<Database.DeleteResult> doDelete(List<SObject> records) {
        DatabaseUtils.validateDMLLimits(records);
        DatabaseUtils.validateDMLPermission(records, Constants.DML_OPERATION.DML_DELETE);
        return Database.delete(records, false);
    }

    private static List<Database.EmptyRecycleBinResult> doEmptyRecycleBin(List<SObject> records) {
        DatabaseUtils.validateDMLLimits(records);
        return Database.emptyRecycleBin(records);
    }

    private static List<Database.UndeleteResult> doUndelete(List<SObject> records) {
        DatabaseUtils.validateDMLLimits(records);
        DatabaseUtils.validateDMLPermission(records, Constants.DML_OPERATION.DML_UNDELETE);
        return Database.undelete(records, false);
    }

     /**
     *  Method for single record insert
     *
     * @param records - record to be inserted
     */
    public static void insertRecords(SObject record) {
        DatabaseUtils.insertRecords(new List<SObject>{record});
    }

     /**
     *  Method for record insert
     *
     * @param records - list of records to be inserted
     */
    public static void insertRecords(List<SObject> records) {
        Database.SaveResult[] results = DatabaseUtils.doInsert(Utils.dynamicCastToListofSObject(records));
        if (DatabaseUtils.LOG_DML_ERRORS) {
            DatabaseUtils.logErrorsInsert(results);
        }
    }

    /**
     *  Method for returning success ids for record insert
     *
     * @param records - record to be inserted
     *
     * @return Set of Ids of records that successful insert
     */
    public static Set<Id> insertRecordsAndReturnSuccessRecordsIds(SObject record) {
        return DatabaseUtils.insertRecordsAndReturnSuccessRecordsIds(new List<SObject>{record});
    }

    /**
     *  Method for returning success ids for record insert
     *
     * @param records - list of records to be inserted
     *
     * @return Set of Ids of records that successful insert
     */
    public static Set<Id> insertRecordsAndReturnSuccessRecordsIds(List<SObject> records) {
        Database.SaveResult[] results = DatabaseUtils.doInsert(Utils.dynamicCastToListofSObject(records));
        Set<Id> successRecordIds = new Set<Id>();
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                successRecordIds.add(sr.getId());
            } else {
                Utils.debug('The following Error occurred during insert of record');
                for (Database.Error err : sr.getErrors()) {
                    Utils.debug(err.getStatusCode().name(), err.getMessage());
                    Utils.debug('Fields that affected this error', err.getFields());
                }
            }
        }
        return successRecordIds;
    }

     /**
     *  Method for returning errors msg for record insert
     *
     * @param records - record to be inserted
     *
     * @return list of msg of records that failed insert
     */
    public static List <String> insertRecordsAndReturnFailedRecordsErrorMessages(SObject record) {
        return DatabaseUtils.insertRecordsAndReturnFailedRecordsErrorMessages(new List<SObject>{record});
    }

     /**
     *  Method for returning errors msg for record insert
     *
     * @param records - list of records to be inserted
     *
     * @return list of msg of records that failed insert
     */
    public static List <String> insertRecordsAndReturnFailedRecordsErrorMessages(List<SObject> records) {
        Database.SaveResult[] results = DatabaseUtils.doInsert(Utils.dynamicCastToListofSObject(records));
        Map <Id, String> failedRecordNos2Message = new Map <Id, String>();
        for (Integer i = 0; i < records.size(); i++) {
            Database.SaveResult sr = results[i];
            SObject origRecord = records[i];
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    failedRecordNos2Message = DatabaseUtils.put(failedRecordNos2Message, (Id)origRecord.get(Constants.FIELD_RECORD_ID), err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        return failedRecordNos2Message.values();
    }

    /**
     *  Method for returning DML Result for record insert
     *
     * @param records - record to be insertd
     *
     * @return map of DML Result of record that failed & success insert
     */
    public static DMLResult insertRecordsAndReturnDMLResult(SObject record) {
        return DatabaseUtils.insertRecordsAndReturnDMLResult(new List<SObject>{record});
    }

     /**
     *  Method for returning DML Result for record insert
     *
     * @param records - list of records to be insertd
     *
     * @return map of DML Result of records that failed & success insert
     */
    public static DMLResult insertRecordsAndReturnDMLResult(List<SObject> records) {
        Database.SaveResult[] results = DatabaseUtils.doInsert(Utils.dynamicCastToListofSObject(records));
        DMLResult dmlResult = new DMLResult();
        dmlResult.successIds = new List<Id>();
        dmlResult.errorIds2errorInfo = new Map<Id, List<Database.Error>>();
        for (Integer i = 0; i < records.size(); i++) {
            Database.SaveResult dr = results[i];
            SObject origRecord = records[i];
            if (!dr.isSuccess()) {
                dmlResult.errorIds2errorInfo.put((Id)origRecord.get(Constants.FIELD_RECORD_ID), dr.getErrors());
            } else {
                dmlResult.successIds.add((Id)origRecord.get(Constants.FIELD_RECORD_ID));
            }
        }
        return dmlResult;
    }

     /**
     *  Method for single record update
     *
     * @param records - record to be updated
     */
    public static void updateRecords(SObject record) {
        DatabaseUtils.updateRecords(new List<SObject>{record});
    }

     /**
     *  Method for record update
     *
     * @param records - list of records to be updated
     */
    public static void updateRecords(List<SObject> records) {
        Database.SaveResult[] results = DatabaseUtils.doUpdate(Utils.dynamicCastToListofSObject(records));
        if (DatabaseUtils.LOG_DML_ERRORS) {
            DatabaseUtils.logErrorsUpdate(results, records);
        }
    }

    /**
     *  Method for returning error ids for record update
     *
     * @param record - record to be updated
     *
     * @return Set of Ids of record that failed update
     */
    public static Set<Id> updateRecordsAndReturnFailedRecordsIds(SObject record) {
        return DatabaseUtils.updateRecordsAndReturnFailedRecordsIds(new List<SObject>{record});
    }

    /**
     *  Method for returning error ids for record update
     *
     * @param records - list of records to be updated
     *
     * @return Set of Ids of records that failed update
     */
    public static Set<Id> updateRecordsAndReturnFailedRecordsIds(List<SObject> records) {
        Database.SaveResult[] results = DatabaseUtils.doUpdate(Utils.dynamicCastToListofSObject(records));
        Set<Id> failedRecordIds = new Set<Id>();
        for (Integer i = 0; i < records.size(); i++) {
            Database.SaveResult sr = results[i];
            SObject origRecord = records[i];
            if (!sr.isSuccess()) {
                failedRecordIds.add((Id)origRecord.get(Constants.FIELD_RECORD_ID));
                Utils.debug('The following Error occurred during update of record', (Id)origRecord.get(Constants.FIELD_RECORD_ID));
                for (Database.Error err : sr.getErrors()) {
                    Utils.debug(err.getStatusCode().name(), err.getMessage());
                    Utils.debug('Fields that affected this error', err.getFields());
                }
            }
        }
        return failedRecordIds;
    }

    /**
     *  Method for returning errors ids and msg for record update
     *
     * @param records - record to be updated
     *
     * @return map of Id to error msg of record that failed update
     */
    public static Map <Id, String> updateRecordsAndReturnFailedRecordsIdWithErrorMessages(SObject record) {
        return DatabaseUtils.updateRecordsAndReturnFailedRecordsIdWithErrorMessages(new List<SObject>{record});
    }

     /**
     *  Method for returning errors ids and msg for record update
     *
     * @param records - list of records to be updated
     *
     * @return map of Id to error msg of records that failed update
     */
    public static Map <Id, String> updateRecordsAndReturnFailedRecordsIdWithErrorMessages(List<SObject> records) {
        Database.SaveResult[] results = DatabaseUtils.doUpdate(Utils.dynamicCastToListofSObject(records));
        Map <Id, String> failedRecordIds2Message = new Map <Id, String>();
        for (Integer i = 0; i < records.size(); i++) {
            Database.SaveResult sr = results[i];
            SObject origRecord = records[i];
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    failedRecordIds2Message = DatabaseUtils.put(failedRecordIds2Message, (Id)origRecord.get(Constants.FIELD_RECORD_ID), err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        return failedRecordIds2Message;
    }

    /**
     *  Method for returning DML Result for record update
     *
     * @param records - record to be updated
     *
     * @return map of DML Result of record that failed & success update
     */
    public static DMLResult updateRecordsAndReturnDMLResult(SObject record) {
        return DatabaseUtils.updateRecordsAndReturnDMLResult(new List<SObject>{record});
    }

     /**
     *  Method for returning DML Result for record update
     *
     * @param records - list of records to be updated
     *
     * @return map of DML Result of records that failed & success update
     */
    public static DMLResult updateRecordsAndReturnDMLResult(List<SObject> records) {
        Database.SaveResult[] results = DatabaseUtils.doUpdate(Utils.dynamicCastToListofSObject(records));
        DMLResult dmlResult = new DMLResult();
        dmlResult.successIds = new List<Id>();
        dmlResult.errorIds2errorInfo = new Map<Id, List<Database.Error>>();
        for (Integer i = 0; i < records.size(); i++) {
            Database.SaveResult sr = results[i];
            SObject origRecord = records[i];
            if (!sr.isSuccess()) {
                dmlResult.errorIds2errorInfo.put((Id)origRecord.get(Constants.FIELD_RECORD_ID), sr.getErrors());
            } else {
                dmlResult.successIds.add((Id)origRecord.get(Constants.FIELD_RECORD_ID));
            }
        }
        return dmlResult;
    }

     /**
     *  Method for single record upsert
     *
     * @param records - record to be upserted
     */
    public static void upsertRecords(SObject record) {
        DatabaseUtils.upsertRecords(new List<SObject>{record});
    }

     /**
     *  Method for records upsert
     *
     * @param records - list of records to be upserted
     */
    public static void upsertRecords(List<SObject> records) {
        Database.UpsertResult[] results = DatabaseUtils.doUpsert(Utils.dynamicCastToListofSObject(records));
        if (DatabaseUtils.LOG_DML_ERRORS) {
            DatabaseUtils.logErrorsUpsert(results);
        }
    }

    /**
     *  Method for single record delete
     *
     * @param records - record to be deleted
     */
    public static void deleteRecords(SObject record) {
        DatabaseUtils.deleteRecords(new List<SObject>{record}, false);
    }

     /**
     *  Method for records delete
     *
     * @param records - list of records to be deleted
     */
    public static void deleteRecords(List<SObject> records) {
        DatabaseUtils.deleteRecords(records, false);
    }

    /**
     *  Method for single record delete and empty recycle in
     *
     * @param records - record to be deleted
     */
    public static void deleteRecords(SObject record, Boolean emptyRecycleBin) {
        DatabaseUtils.deleteRecords(new List<SObject>{record}, emptyRecycleBin);
    }

     /**
     *  Method for records delete and empty recycle in
     *
     * @param records - list of records to be deleted
     */
    public static void deleteRecords(List<SObject> records, Boolean emptyRecycleBin) {
        Database.DeleteResult[] resultsDelete = DatabaseUtils.doDelete(Utils.dynamicCastToListofSObject(records));
        if (DatabaseUtils.LOG_DML_ERRORS) {
            DatabaseUtils.logErrorsDelete(resultsDelete);
            
        }
        if (emptyRecycleBin) {
            Database.EmptyRecycleBinResult[] resultsEmptyRecycleBin = DatabaseUtils.doEmptyRecycleBin(records);
            if (DatabaseUtils.LOG_DML_ERRORS) {
                DatabaseUtils.logErrorsEmptyRecycleBin(resultsEmptyRecycleBin);
            }
        }
    }

    /**
     *  Method for returning DML Result for record delete
     *
     * @param records - record to be deleted
     *
     * @return map of DML Result of record that failed & success delete
     */
    public static DMLResult deleteRecordsAndReturnDMLResult(SObject record) {
        return DatabaseUtils.deleteRecordsAndReturnDMLResult(new List<SObject>{record});
    }

     /**
     *  Method for returning DML Result for record delete
     *
     * @param records - list of records to be deleted
     *
     * @return map of DML Result of records that failed & success delete
     */
    public static DMLResult deleteRecordsAndReturnDMLResult(List<SObject> records) {
        Database.DeleteResult[] results = DatabaseUtils.doDelete(Utils.dynamicCastToListofSObject(records));
        DMLResult dmlResult = new DMLResult();
        dmlResult.successIds = new List<Id>();
        dmlResult.errorIds2errorInfo = new Map<Id, List<Database.Error>>();
        for (Integer i = 0; i < records.size(); i++) {
            Database.DeleteResult dr = results[i];
            SObject origRecord = records[i];
            if (!dr.isSuccess()) {
                dmlResult.errorIds2errorInfo.put((Id)origRecord.get(Constants.FIELD_RECORD_ID), dr.getErrors());
            } else {
                dmlResult.successIds.add((Id)origRecord.get(Constants.FIELD_RECORD_ID));
            }
        }
        return dmlResult;
    }

    /**
     *  Method for single record undelete
     *
     * @param records - record to be undeleted
     */
    public static void undeleteRecords(SObject record) {
        DatabaseUtils.undeleteRecords(new List<SObject>{record});
    }

     /**
     *  Method for records undelete
     *
     * @param records - list of records to be undeleted
     */
    public static void undeleteRecords(List<SObject> records) {
        Database.UndeleteResult[] results = DatabaseUtils.doUndelete(Utils.dynamicCastToListofSObject(records));
        if (DatabaseUtils.LOG_DML_ERRORS) {
            DatabaseUtils.logErrorsUndelete(results);
        }
    }

     /**
     *  Method for returning DML Result for record undelete
     *
     * @param records - record to be undeleted
     *
     * @return map of DML Result of record that failed & success undelete
     */
    public static DMLResult undeleteRecordsAndReturnDMLResult(SObject record) {
        return DatabaseUtils.undeleteRecordsAndReturnDMLResult(new List<SObject>{record});
    }

     /**
     *  Method for returning DML Result for record undelete
     *
     * @param records - list of records to be undeleted
     *
     * @return map of DML Result of records that failed & success undelete
     */
    public static DMLResult undeleteRecordsAndReturnDMLResult(List<SObject> records) {
        Database.UndeleteResult[] results = DatabaseUtils.doUndelete(Utils.dynamicCastToListofSObject(records));
        DMLResult dmlResult = new DMLResult();
        dmlResult.successIds = new List<Id>();
        dmlResult.errorIds2errorInfo = new Map<Id, List<Database.Error>>();
        for (Integer i = 0; i < records.size(); i++) {
            Database.UndeleteResult dr = results[i];
            SObject origRecord = records[i];
            if (!dr.isSuccess()) {
                dmlResult.errorIds2errorInfo.put((Id)origRecord.get(Constants.FIELD_RECORD_ID), dr.getErrors());
            } else {
                dmlResult.successIds.add((Id)origRecord.get(Constants.FIELD_RECORD_ID));
            }
        }
        return dmlResult;
    }

    public with sharing class DMLResult{
        public List<Id> successIds;
        public Map <Id, List<Database.Error>> errorIds2errorInfo;
    }

}