/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-07   Krrish Joy   Initial Version
**/
public with sharing class SObjectSelector {
    
    public static List<SObject> getParentRecordByMasterId(OQCT_DaCl__DC_Configuration__c dcConfig, List<String> masterIds){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = dcConfig.OQCT_DaCl__Master_Object_Name__c;
        queryParams.fieldApiName = dcConfig.OQCT_DaCl__Master_Object_Match_By_Field_Name__c;
        
        final StringBuilder whereClauseCondition = new StringBuilder();
        whereClauseCondition.setSeparator(Constants.LITERAL_SPACE);
        whereClauseCondition.append(dcConfig.OQCT_DaCl__Master_Object_Match_By_Field_Name__c);
        whereClauseCondition.append(Constants.CLAUSE_IN);
        if (dcConfig.OQCT_DaCl__Master_Object_Match_By_Field_Name__c == Constants.FIELD_RECORD_ID) {
            whereClauseCondition.append(Utils.convertWhereInClauseFromListtoString(masterIds));
        } else {
            Schema.DisplayType fieldDisplayType = Utils.getFieldDisplayType(dcConfig.OQCT_DaCl__Master_Object_Name__c, dcConfig.OQCT_DaCl__Master_Object_Match_By_Field_Name__c);
            switch on fieldDisplayType {
                when  ID, EMAIL, STRING{
                    whereClauseCondition.append(Utils.convertWhereInClauseFromListtoString(masterIds, true));
                }
                when DOUBLE, INTEGER, LONG {
                    whereClauseCondition.append(Utils.convertWhereInClauseFromListtoString(masterIds, false));
                }
            }
        }
        queryParams.whereClauseCondition = whereClauseCondition.toString();
        return QueryBuilder.getQueryResults(queryParams);
    }

    public static Integer getRelatedRecordByIdCount(String objectName, List<String> lookupFieldNames, Set<Id> stringList){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = objectName;
        queryParams.stringList = new List<Id>(stringList);
        final StringBuilder whereClauseConditions = new StringBuilder();
        whereClauseConditions.setSeparator(Constants.SOQL_OPERATOR_OR);
        for (String lookupFieldName : lookupFieldNames) {
            final StringBuilder whereClauseCondition = new StringBuilder();
            whereClauseCondition.setSeparator(Constants.LITERAL_SPACE + Constants.CLAUSE_IN + Constants.LITERAL_SPACE);
            whereClauseCondition.append(lookupFieldName);
            whereClauseCondition.append(String.escapeSingleQuotes(Constants.SOQL_BIND_VARIABLE_STRING_LIST));
            whereClauseConditions.append(whereClauseCondition.toString());
        }
        queryParams.whereClauseCondition = whereClauseConditions.toString();
        return QueryBuilder.getCountQueryResults(queryParams);
    }

    public static List<SObject> getRecords(String objectName, List<String> fieldApiNames){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = objectName;
        queryParams.fieldApiNames = fieldApiNames;
        return QueryBuilder.getQueryResults(queryParams);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static List<SObject> getRecordsById(String objectName, List<String> fieldApiNames, Set<Id> stringList, List<String> lookupFieldNames){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = objectName;
        queryParams.fieldApiNames = fieldApiNames;
        queryParams.stringList = new List<Id>(stringList);
        final StringBuilder whereClauseConditions = new StringBuilder();
        whereClauseConditions.setSeparator(Constants.SOQL_OPERATOR_OR);
        if (lookupFieldNames != null) {
            for (String lookupFieldName : lookupFieldNames) {
                final StringBuilder whereClauseCondition = new StringBuilder();
                whereClauseCondition.setSeparator(Constants.SOQL_OPERATOR_EQUAL);
                whereClauseCondition.append(lookupFieldName);
                whereClauseCondition.append(String.escapeSingleQuotes(Constants.SOQL_BIND_VARIABLE_STRING_LIST));
                whereClauseConditions.append(whereClauseCondition.toString());
            }
        } else {
            final StringBuilder whereClauseCondition = new StringBuilder();
            whereClauseCondition.setSeparator(Constants.LITERAL_SPACE + Constants.CLAUSE_IN + Constants.LITERAL_SPACE);
            whereClauseCondition.append(Constants.FIELD_RECORD_ID);
            whereClauseCondition.append(String.escapeSingleQuotes(Constants.SOQL_BIND_VARIABLE_STRING_LIST));
            whereClauseConditions.append(whereClauseCondition.toString());
        }
        queryParams.whereClauseCondition = whereClauseConditions.toString();
        return QueryBuilder.getQueryResults(queryParams);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static String getRecordsByIdString(String objectName, List<String> fieldApiNames, Set<Id> stringList, List<String> lookupFieldNames){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = objectName;
        queryParams.fieldApiNames = fieldApiNames;
        queryParams.stringList = new List<Id>(stringList);
        final StringBuilder whereClauseConditions = new StringBuilder();
        whereClauseConditions.setSeparator(Constants.SOQL_OPERATOR_OR);
        for (String lookupFieldName : lookupFieldNames) {
            final StringBuilder whereClauseCondition = new StringBuilder();
            whereClauseCondition.setSeparator(Constants.SOQL_OPERATOR_EQUAL);
            whereClauseCondition.append(lookupFieldName);
            whereClauseCondition.append(String.escapeSingleQuotes(Constants.SOQL_BIND_VARIABLE_STRING_LIST));
            whereClauseConditions.append(whereClauseCondition.toString());
        }
        queryParams.whereClauseCondition = whereClauseConditions.toString();
        return QueryBuilder.getQueryString(queryParams);
    }

    public static List<SObject> getFieldHistoryByIdObjectAndFields(String objectName, Set<String> fieldsForHistoryTrackingDeletion, Set<Id> recordIds){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Utils.getHistoryObjectName(objectName);
        queryParams.fieldApiName = Constants.FIELD_RECORD_ID;
        queryParams.stringList = new List<Id>(recordIds);
        final StringBuilder whereClauseCondition = new StringBuilder();
        whereClauseCondition.setSeparator(Constants.LITERAL_SPACE);
        whereClauseCondition.append(Constants.OBJECT_HISTORY_FIELD);
        whereClauseCondition.append(Constants.CLAUSE_IN);
        whereClauseCondition.append(Utils.convertWhereInClauseFromListtoString(new List<String>(fieldsForHistoryTrackingDeletion)));
        whereClauseCondition.append(Constants.SOQL_OPERATOR_AND.trim());
        whereClauseCondition.append(Utils.getLookupFieldName(objectName, Utils.getHistoryObjectName(objectName)));
        whereClauseCondition.append(Constants.CLAUSE_IN);
        whereClauseCondition.append(String.escapeSingleQuotes(Constants.SOQL_BIND_VARIABLE_STRING_LIST));
        queryParams.whereClauseCondition = whereClauseCondition.toString();
        return QueryBuilder.getQueryResults(queryParams);
    }

    public static List<SObject> getFieldHistoryByIdAndObject(String objectName,  Set<Id> recordIds){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Utils.getHistoryObjectName(objectName);
        queryParams.fieldApiName = Constants.FIELD_RECORD_ID;
        queryParams.addWhereInClause = true;
        queryParams.whereInOrNotInField = Utils.getLookupFieldName(objectName, Utils.getHistoryObjectName(objectName));
        queryParams.stringList = new List<Id>(recordIds);
        return QueryBuilder.getQueryResults(queryParams);
    }

    public static Map<Id, SObject> getRecycleBinRecordId2RecordByIdAndObject(String objectName,  Set<Id> recordIds){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = objectName;
        queryParams.fieldApiName = Constants.FIELD_RECORD_ID;
        queryParams.stringList = new List<Id>(recordIds);
        queryParams.queryAllRows = true;
        final StringBuilder whereClauseCondition = new StringBuilder();
        whereClauseCondition.setSeparator(Constants.LITERAL_SPACE);
        whereClauseCondition.append(Constants.FIELD_RECORD_ID);
        whereClauseCondition.append(Constants.CLAUSE_IN);
        whereClauseCondition.append(String.escapeSingleQuotes(Constants.SOQL_BIND_VARIABLE_STRING_LIST));
        whereClauseCondition.append(Constants.SOQL_OPERATOR_AND.trim());
        whereClauseCondition.append(Constants.FIELD_DELETED);
        whereClauseCondition.append(Constants.LITERAL_EQUAL_TO);
        whereClauseCondition.append(string.escapeSingleQuotes(Constants.LITERAL_TRUE));
        queryParams.whereClauseCondition = whereClauseCondition.toString();
        return new Map<Id, SObject>(QueryBuilder.getQueryResults(queryParams));
    }

}