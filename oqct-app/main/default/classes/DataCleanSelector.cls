/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-21
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-30   Krrish Joy   Initial Version
**/
public with sharing class DataCleanSelector {
    public static List<OQCT_DaCl__Data_Clean__c> getAllDataCleans(){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__DC_Configuration__c,
                        OQCT_DaCl__Is_Masking_Completed__c,
                        OQCT_DaCl__Overall_Masking_Status__c,
                        OQCT_DaCl__Is_Rollback_Completed__c,
                        OQCT_DaCl__Overall_Rollback_Status__c,
                        OQCT_DaCl__Is_Deletion_Completed__c,
                        OQCT_DaCl__Overall_Deletion_Status__c,
                        OQCT_DaCl__Is_Archive_Completed__c,
                        OQCT_DaCl__Overall_Archive_Status__c
                FROM OQCT_DaCl__Data_Clean__c
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Data_Clean__c> getDataCleanDcConfigsByIds(Set<Id> dataCleanIds){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__DC_Configuration__c
                FROM OQCT_DaCl__Data_Clean__c
                WHERE Id
                    IN :dataCleanIds
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Data_Clean__c> getDataCleanBackupFileNamesByIds(Set<Id> dataCleanIds){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c,
                    OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c
                FROM OQCT_DaCl__Data_Clean__c
                WHERE Id
                    IN :dataCleanIds
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Data_Clean__c> getDataCleanByDcConfigIds(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT Name,
                    OQCT_DaCl__DC_Configuration__c,
                    OQCT_DaCl__Master_Id__c,
                    OQCT_DaCl__Master_Object_Name__c
                FROM OQCT_DaCl__Data_Clean__c
                WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static Integer getDataCleansAvailableForMaskCount(){
        Utils.validateQueryStatementLimits();
        return [SELECT Count()
                FROM OQCT_DaCl__Data_Clean__c
                WHERE OQCT_DaCl__Overall_Masking_Status__c
                    IN (:Constants.DC_STATUS_PENDING, :Constants.DC_STATUS_FAILED, :Constants.DC_STATUS_NO_RECORDS_FOUND, :Constants.DC_STATUS_PARTIAL_SUCCESS)
                WITH SECURITY_ENFORCED];
    }

    public static Integer getDataCleansAvailableForDeleteCount(){
        Utils.validateQueryStatementLimits();
        return [SELECT Count()
                FROM OQCT_DaCl__Data_Clean__c
                WHERE OQCT_DaCl__Overall_Deletion_Status__c
                    IN (:Constants.DC_STATUS_PENDING, :Constants.DC_STATUS_FAILED, :Constants.DC_STATUS_NO_RECORDS_FOUND, :Constants.DC_STATUS_PARTIAL_SUCCESS)
                WITH SECURITY_ENFORCED];
    }

    public static Integer getDataCleansAvailableForArchiveCount(){
        Utils.validateQueryStatementLimits();
        return [SELECT Count()
                FROM OQCT_DaCl__Data_Clean__c
                WHERE OQCT_DaCl__Overall_Archive_Status__c
                    IN (:Constants.DC_STATUS_PENDING, :Constants.DC_STATUS_FAILED, :Constants.DC_STATUS_NO_RECORDS_FOUND, :Constants.DC_STATUS_PARTIAL_SUCCESS)
                WITH SECURITY_ENFORCED];
    }

    // public static Integer getDataCleansAvailableForCloneCount(){
    //     Utils.validateQueryStatementLimits();
    //     return [SELECT Count()
    //             FROM OQCT_DaCl__Data_Clean__c
    //             WHERE OQCT_DaCl__Overall_Cloning_Status__c
    //                 IN (:Constants.DC_STATUS_PENDING, :Constants.DC_STATUS_FAILED, :Constants.DC_STATUS_NO_RECORDS_FOUND, :Constants.DC_STATUS_PARTIAL_SUCCESS)
    //             WITH SECURITY_ENFORCED];
    // }

    public static Integer getDataCleansAvailableForRollbackCount(){
        Utils.validateQueryStatementLimits();
        return [SELECT Count()
                FROM OQCT_DaCl__Data_Clean__c
                WHERE OQCT_DaCl__Overall_Rollback_Status__c
                    IN (:Constants.DC_STATUS_PENDING, :Constants.DC_STATUS_FAILED, :Constants.DC_STATUS_NO_RECORDS_FOUND, :Constants.DC_STATUS_PARTIAL_SUCCESS)
                WITH SECURITY_ENFORCED];
    }

    public static String getDataCleansByDcConfigIdsDeleteString(List<Id> dcConfigIds){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
        queryParams.fieldApiName = Constants.FIELD_RECORD_ID;
        queryParams.addWhereInClause = true;
        queryParams.whereInOrNotInField = Constants.DC_FIELD_DC_CONFIGURATION;
        queryParams.stringList = dcConfigIds;
        return QueryBuilder.getQueryString(queryParams);
    }

    public static String getDataCleansAvailableForParentMaskQueryString(List<String> retryableDCStatuses){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
        queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
        queryParams.addWhereInClause = true;
        queryParams.whereInOrNotInField = Constants.DC_FIELD_MASTER_RECORD_MASKING_STATUS;
        queryParams.stringList = retryableDCStatuses;
        return QueryBuilder.getQueryString(queryParams);
    }

    public static String getDataCleansAvailableForChildMaskQueryString(String relatedObjectName){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
        queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
        StringBuilder whereClauseCondition = new StringBuilder();
        whereClauseCondition.setSeparator(Constants.LITERAL_SPACE);
        whereClauseCondition.append(Constants.FIELD_RECORD_ID);
        whereClauseCondition.append(Constants.CLAUSE_IN);
        whereClauseCondition.append(Constants.LITERAL_OPEN_BRACKET + Constants.SOQL_LITERAL_SELECT);
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_DATA_CLEAN);
        whereClauseCondition.append(Constants.SOQL_LITERAL_FROM);
        whereClauseCondition.append(Constants.OBJECT_DATA_CLEAN_RELATED_RESULT);
        whereClauseCondition.append(Constants.CLAUSE_WHERE);
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_RELATED_OBJECT_NAME);
        whereClauseCondition.append(Constants.LITERAL_EQUAL_TO);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE + String.escapeSingleQuotes(relatedObjectName) + Constants.LITERAL_SINGLE_QUOTE);
        whereClauseCondition.append(Constants.SOQL_OPERATOR_AND.trim());
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_RELATED_MASKING_STATUS);
        whereClauseCondition.append(Constants.CLAUSE_IN);
        whereClauseCondition.append(Constants.SOQL_BIND_VARIABLE_STRING_LIST + Constants.LITERAL_CLOSE_BRACKET);
        queryParams.whereClauseCondition = whereClauseCondition.toString();
        return QueryBuilder.getQueryString(queryParams);
    }

    public static String getDataCleansAvailableForParentDeleteQueryString(List<String> retryableDCStatuses){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
        queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
        queryParams.addWhereInClause = true;
        queryParams.whereInOrNotInField = Constants.DC_FIELD_MASTER_RECORD_DELETION_STATUS;
        queryParams.stringList = retryableDCStatuses;
        return QueryBuilder.getQueryString(queryParams);
    }

    public static String getDataCleansAvailableForChildDeleteQueryString(String relatedObjectName){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
        queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
        StringBuilder whereClauseCondition = new StringBuilder();
        whereClauseCondition.setSeparator(Constants.LITERAL_SPACE);
        whereClauseCondition.append(Constants.FIELD_RECORD_ID);
        whereClauseCondition.append(Constants.CLAUSE_IN);
        whereClauseCondition.append(Constants.LITERAL_OPEN_BRACKET + Constants.SOQL_LITERAL_SELECT);
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_DATA_CLEAN);
        whereClauseCondition.append(Constants.SOQL_LITERAL_FROM);
        whereClauseCondition.append(Constants.OBJECT_DATA_CLEAN_RELATED_RESULT);
        whereClauseCondition.append(Constants.CLAUSE_WHERE);
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_RELATED_OBJECT_NAME);
        whereClauseCondition.append(Constants.LITERAL_EQUAL_TO);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE + String.escapeSingleQuotes(relatedObjectName) + Constants.LITERAL_SINGLE_QUOTE);
        whereClauseCondition.append(Constants.SOQL_OPERATOR_AND.trim());
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_RELATED_DELETE_STATUS);
        whereClauseCondition.append(Constants.CLAUSE_IN);
        whereClauseCondition.append(Constants.SOQL_BIND_VARIABLE_STRING_LIST + Constants.LITERAL_CLOSE_BRACKET);
        queryParams.whereClauseCondition = whereClauseCondition.toString();
        return QueryBuilder.getQueryString(queryParams);
    }

    public static String getDataCleansAvailableForParentProcess2DeleteQueryString(List<String> retryableDCStatuses){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
        queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
        StringBuilder whereClauseCondition = new StringBuilder();
        whereClauseCondition.setSeparator(Constants.LITERAL_SPACE);
        whereClauseCondition.append(Constants.DC_FIELD_MASTER_RECORD_MASKING_STATUS);
        whereClauseCondition.append(Constants.LITERAL_EQUAL_TO);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE + String.escapeSingleQuotes(Constants.DC_STATUS_SUCCESS) + Constants.LITERAL_SINGLE_QUOTE);
        whereClauseCondition.append(Constants.SOQL_OPERATOR_OR);
        whereClauseCondition.append(Constants.DC_FIELD_MASTER_RECORD_MASKING_STATUS);
        whereClauseCondition.append(Constants.LITERAL_EQUAL_TO);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE + String.escapeSingleQuotes(Constants.DC_STATUS_PARTIAL_SUCCESS) + Constants.LITERAL_SINGLE_QUOTE);
        queryParams.whereClauseCondition = whereClauseCondition.toString();
        queryParams.addWhereInClause = true;
        queryParams.whereInOrNotInField = Constants.DC_FIELD_MASTER_RECORD_DELETION_STATUS;
        queryParams.stringList = retryableDCStatuses;
        return QueryBuilder.getQueryString(queryParams);
    }

    public static String getDataCleansAvailableForChildProcess2DeleteQueryString(String relatedObjectName){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
        queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
        StringBuilder whereClauseCondition = new StringBuilder();
        whereClauseCondition.setSeparator(Constants.LITERAL_SPACE);
        whereClauseCondition.append(Constants.FIELD_RECORD_ID);
        whereClauseCondition.append(Constants.CLAUSE_IN);
        whereClauseCondition.append(Constants.LITERAL_OPEN_BRACKET + Constants.SOQL_LITERAL_SELECT);
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_DATA_CLEAN);
        whereClauseCondition.append(Constants.SOQL_LITERAL_FROM);
        whereClauseCondition.append(Constants.OBJECT_DATA_CLEAN_RELATED_RESULT);
        whereClauseCondition.append(Constants.CLAUSE_WHERE);
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_RELATED_OBJECT_NAME);
        whereClauseCondition.append(Constants.LITERAL_EQUAL_TO);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE + String.escapeSingleQuotes(relatedObjectName) + Constants.LITERAL_SINGLE_QUOTE);
        whereClauseCondition.append(Constants.SOQL_OPERATOR_AND.trim());
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_RELATED_DELETE_STATUS);
        whereClauseCondition.append(Constants.CLAUSE_IN);
        whereClauseCondition.append(Constants.SOQL_BIND_VARIABLE_STRING_LIST);
        whereClauseCondition.append(Constants.SOQL_OPERATOR_AND.trim());
        whereClauseCondition.append(Constants.LITERAL_OPEN_BRACKET + Constants.DC_RELATED_RESULT_FIELD_RELATED_MASKING_STATUS);
        whereClauseCondition.append(Constants.LITERAL_EQUAL_TO);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE + String.escapeSingleQuotes(Constants.DC_STATUS_NOT_ELIGIBLE) + Constants.LITERAL_SINGLE_QUOTE);
        whereClauseCondition.append(Constants.SOQL_OPERATOR_OR.trim());
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_RELATED_MASKING_STATUS);
        whereClauseCondition.append(Constants.LITERAL_EQUAL_TO);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE + String.escapeSingleQuotes(Constants.DC_STATUS_SUCCESS) + Constants.LITERAL_SINGLE_QUOTE);
        whereClauseCondition.append(Constants.SOQL_OPERATOR_OR.trim());
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_RELATED_MASKING_STATUS);
        whereClauseCondition.append(Constants.LITERAL_EQUAL_TO);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE + String.escapeSingleQuotes(Constants.DC_STATUS_PARTIAL_SUCCESS) + Constants.LITERAL_SINGLE_QUOTE + Constants.LITERAL_CLOSE_BRACKET + Constants.LITERAL_CLOSE_BRACKET);
        queryParams.whereClauseCondition = whereClauseCondition.toString();
        return QueryBuilder.getQueryString(queryParams);
    }

    public static String getDataCleansAvailableForParentArchiveQueryString(List<String> retryableDCStatuses){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
        queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
        queryParams.addWhereInClause = true;
        queryParams.whereInOrNotInField = Constants.DC_FIELD_MASTER_RECORD_ARCHIVE_STATUS;
        queryParams.stringList = retryableDCStatuses;
        return QueryBuilder.getQueryString(queryParams);
    }

    public static String getDataCleansAvailableForChildArchiveQueryString(String relatedObjectName){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
        queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
        StringBuilder whereClauseCondition = new StringBuilder();
        whereClauseCondition.setSeparator(Constants.LITERAL_SPACE);
        whereClauseCondition.append(Constants.FIELD_RECORD_ID);
        whereClauseCondition.append(Constants.CLAUSE_IN);
        whereClauseCondition.append(Constants.LITERAL_OPEN_BRACKET + Constants.SOQL_LITERAL_SELECT);
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_DATA_CLEAN);
        whereClauseCondition.append(Constants.SOQL_LITERAL_FROM);
        whereClauseCondition.append(Constants.OBJECT_DATA_CLEAN_RELATED_RESULT);
        whereClauseCondition.append(Constants.CLAUSE_WHERE);
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_RELATED_OBJECT_NAME);
        whereClauseCondition.append(Constants.LITERAL_EQUAL_TO);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE + String.escapeSingleQuotes(relatedObjectName) + Constants.LITERAL_SINGLE_QUOTE);
        whereClauseCondition.append(Constants.SOQL_OPERATOR_AND.trim());
        whereClauseCondition.append(Constants.DC_RELATED_RESULT_FIELD_RELATED_ARCHIVE_STATUS);
        whereClauseCondition.append(Constants.CLAUSE_IN);
        whereClauseCondition.append(Constants.SOQL_BIND_VARIABLE_STRING_LIST + Constants.LITERAL_CLOSE_BRACKET);
        queryParams.whereClauseCondition = whereClauseCondition.toString();
        return QueryBuilder.getQueryString(queryParams);
    }

    // public static String getDataCleansAvailableForParentCloneQueryString(List<String> retryableDCStatuses){
    //     QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
    //     queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
    //     queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
    //     queryParams.addWhereInClause = true;
    //     queryParams.whereInOrNotInField = Constants.DC_FIELD_MASTER_RECORD_CLONING_STATUS;
    //     queryParams.stringList = retryableDCStatuses;
    //     return QueryBuilder.getQueryString(queryParams);
    // }

    // public static String getDataCleansAvailableForChildCloneQueryString(List<String> retryableDCStatuses){
    //     QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
    //     queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
    //     queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
    //     queryParams.addWhereInClause = true;
    //     queryParams.whereInOrNotInField = Constants.DC_FIELD_RELATED_CLONING_STATUS;
    //     queryParams.stringList = retryableDCStatuses;
    //     return QueryBuilder.getQueryString(queryParams);
    // }

    // public static String getDataCleansAvailableForParentRollbackQueryString(List<String> retryableDCStatuses){
    //     QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
    //     queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
    //     queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
    //     queryParams.addWhereInClause = true;
    //     queryParams.whereInOrNotInField = Constants.DC_FIELD_MASTER_RECORD_ROLLBACK_STATUS;
    //     queryParams.stringList = retryableDCStatuses;
    //     return QueryBuilder.getQueryString(queryParams);
    // }

    // public static String getDataCleansAvailableForChildRollbackQueryString(List<String> retryableDCStatuses){
    //     QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
    //     queryParams.objectName = Constants.OBJECT_DATA_CLEAN;
    //     queryParams.fieldApiNames = DataCleanSelector.getDataCleanFieldsForBatch();
    //     queryParams.addWhereInClause = true;
    //     queryParams.whereInOrNotInField = Constants.DC_FIELD_RELATED_ROLLBACK_STATUS;
    //     queryParams.stringList = retryableDCStatuses;
    //     return QueryBuilder.getQueryString(queryParams);
    // }

    private static List<String> getDataCleanFieldsForBatch(){
        List<String> fields = new List<String>();
        fields.add(Constants.FIELD_RECORD_NAME);
        fields.add(Constants.DC_FIELD_DC_CONFIGURATION);
        fields.add(Constants.DC_FIELD_MASTER_ID);
        fields.add(Constants.DC_FIELD_MASTER_OBJECT_NAME);
        return fields;
    }
}