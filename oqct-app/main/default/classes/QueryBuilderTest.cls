/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : 
 * @last modified on  : 2021-03-20
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-04-2021   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class QueryBuilderTest {
    public static QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
    public static String sortField = 'Id';
    public static String sortDirection = 'DESC';  
    public static Integer recordLimit = 1;
    public static Integer offset = 0;

    @TestSetup
    private static void setupData(){
        DataFactory.initAccount('Test Account');
        DataFactory.initContentVersion('test');
    }
    
    @IsTest
    private static void getQueryStringWithoutWhereClauseTest(){
        queryParams = getqueryBuilder();
        String expectedResult = 'SELECT ContentDocumentId FROM ContentVersion WITH SECURITY_ENFORCED';
        
        Test.startTest();
            String resultSQLString = QueryBuilder.getQueryString(queryParams);
        Test.stopTest();

        System.assertEquals(resultSQLString, expectedResult, 'SQL should be return.');
        
    }
    
    @IsTest
    private static void getQueryStringWithWhereClauseTest(){
        queryParams = getqueryBuilder();
        queryParams.whereClauseCondition = getWhereClause();
        String expectedResult = 'SELECT ContentDocumentId FROM ContentVersion WHERE (PathOnClient LIKE \'%Backup-%\') WITH SECURITY_ENFORCED';
        
        Test.startTest();
            String resultSQLString = QueryBuilder.getQueryString(queryParams);
        Test.stopTest();

        System.assertEquals(resultSQLString, expectedResult, 'SQL should be returned with where condition.');
        
    }

    @IsTest
    private static void getQueryStringWithNotInClauseTest(){
        queryParams = getqueryBuilder();
        queryParams.addWhereNotInClause = true;
        queryParams.whereClauseCondition = getWhereClause();
        queryParams.whereInOrNotInField = Constants.DC_FIELD_DC_CONFIGURATION;
        queryParams.stringList = new List<String>{'test'};
        String expectedResult = 'SELECT ContentDocumentId FROM ContentVersion WHERE (PathOnClient LIKE \'%Backup-%\') AND OQCT_DaCl__DC_Configuration__c NOT IN :stringList WITH SECURITY_ENFORCED';
        
        Test.startTest();
            String resultSQLString = QueryBuilder.getQueryString(queryParams);
        Test.stopTest();

        System.assertEquals(resultSQLString, expectedResult, 'SQL should be returned with not in condition.');
        
    }

    
    @IsTest
    private static void getQueryStringWithWhereNotInClauseTest(){
        queryParams = getqueryBuilder();
        queryParams.whereClauseCondition = getWhereClause();
        queryParams.addWhereInClause = true;
        queryParams.whereInOrNotInField = Constants.DC_FIELD_DC_CONFIGURATION;
        queryParams.stringList = new List<String>{'test'};
        String expectedResult = 'SELECT ContentDocumentId FROM ContentVersion WHERE (PathOnClient LIKE \'%Backup-%\') AND OQCT_DaCl__DC_Configuration__c IN :stringList WITH SECURITY_ENFORCED';
        
        Test.startTest();
            String resultSQLString = QueryBuilder.getQueryString(queryParams);
        Test.stopTest();

        System.assertEquals(resultSQLString, expectedResult, 'SQL should be returned with not in condition.');
        
    }
    
    @IsTest
    private static void getQueryStringWithSortingOrderTest(){
        queryParams = getqueryBuilder();
        queryParams.whereClauseCondition = getWhereClause();
        queryParams.addWhereInClause = false;
        queryParams.whereInOrNotInField = Constants.DC_FIELD_DC_CONFIGURATION;
        queryParams.sortField = sortField;
        queryParams.sortDirection = sortDirection;
        queryParams.recordLimit = recordLimit;
        queryParams.offset = offset;
        queryParams.queryAllRows = true;
        String expectedResult = 'SELECT ContentDocumentId FROM ContentVersion WHERE (PathOnClient LIKE \'%Backup-%\') WITH SECURITY_ENFORCED ORDER BY Id DESC LIMIT 1 OFFSET 0 ALL ROWS';
        
        Test.startTest();
            String resultSQLString = QueryBuilder.getQueryString(queryParams);
        Test.stopTest();

        System.assertEquals(resultSQLString, expectedResult, 'SQL should be returned with the sorting.');
        
    }
    
    @IsTest
    private static void getAggregateQueryStringTest(){
        queryParams = getqueryBuilder();
        queryParams.aggregateParams = new List<QueryBuilder.AggregateParameters>();
        queryParams.aggregateParams.add(getAggregateParameters());

        String expectedResult = 'SELECT SUM(ContentSize) ContentSize, ContentDocumentId FROM ContentVersion GROUP BY ContentDocumentId';
        
        Test.startTest();
            String resultSQLString = QueryBuilder.getAggregateQueryString(queryParams);
        Test.stopTest();

        System.assertEquals(resultSQLString, expectedResult, 'Aggregated SQL should be returned.');
    }
    
    @IsTest
    private static void getAggregateQueryStringWithWhereClauseTest(){
        queryParams = getqueryBuilder();
        queryParams.whereClauseCondition = getWhereClause();
        queryParams.aggregateParams = new List<QueryBuilder.AggregateParameters>();
        queryParams.aggregateParams.add(getAggregateParameters());

        String expectedResult = 'SELECT SUM(ContentSize) ContentSize, ContentDocumentId FROM ContentVersion WHERE (PathOnClient LIKE \'%Backup-%\') GROUP BY ContentDocumentId';
        
        Test.startTest();
            String resultSQLString = QueryBuilder.getAggregateQueryString(queryParams);
        Test.stopTest();

        System.assertEquals(resultSQLString, expectedResult, 'Aggregated SQL should bereturned with the where condition.');
    }

    @IsTest
    private static void getAggregateQueryStringForHavingClauseTest(){
        queryParams = getqueryBuilder();
        queryParams.aggregateParams = new List<QueryBuilder.AggregateParameters>();
        queryParams.aggregateParams.add(getAggregateParameters());
        queryParams.havingClauseCondition = 'test';
        
        String expectedResult = 'SELECT SUM(ContentSize) ContentSize, ContentDocumentId FROM ContentVersion GROUP BY ContentDocumentId WHERE (test)';
        
        Test.startTest();
            String resultSQLString = QueryBuilder.getAggregateQueryString(queryParams);
        Test.stopTest();

        System.assertEquals(resultSQLString, expectedResult, 'Aggregated SQL should be returned with having clause.');
    }
    
    @IsTest
    private static void getQueryResultsTest(){
        queryParams = getqueryBuilderForAccount();
        
        Test.startTest();
            List<SObject> objectList = QueryBuilder.getQueryResults(queryParams);
        Test.stopTest();

        System.assertEquals(objectList.size(), 1, 'Record size should be one.');
    }
    
    @IsTest
    private static void getAggregateQueryResultsTest(){
        queryParams = getqueryBuilderForAccount();
        queryParams.aggregateParams = new List<QueryBuilder.AggregateParameters>();
        queryParams.aggregateParams.add(getAggregateParametersForAccount());

        String expectedResult = 'SELECT SUM(ContentSize) ContentSize, ContentDocumentId FROM ContentVersion WHERE (PathOnClient LIKE \'%Backup-%\') GROUP BY ContentDocumentId';
        
        Test.startTest();
            List<AggregateResult> aggregateResultList = QueryBuilder.getAggregateQueryResults(queryParams);
        Test.stopTest();

        System.assertEquals(aggregateResultList.size(), 1, 'Result should contain one record.');
    }
    
    @IsTest
    private static void getAggregateQueryResultsShouldNotReturnRecordTest(){
        queryParams = getqueryBuilder();
        queryParams.whereClauseCondition = getWhereClause();
        queryParams.aggregateParams = new List<QueryBuilder.AggregateParameters>();
        queryParams.aggregateParams.add(getAggregateParameters());
        
        Test.startTest();
            List<AggregateResult> aggregateResultList = QueryBuilder.getAggregateQueryResults(queryParams);
        Test.stopTest();

        System.assertEquals(aggregateResultList.size(), 0, 'Result size should be zero..');
    }
    
    @IsTest
    private static void getCountQueryResultsTest(){
        queryParams.objectName = Constants.OBJECT_ACCOUNT;
       
        Test.startTest();
            Integer count = QueryBuilder.getCountQueryResults(queryParams);
        Test.stopTest();

        System.assertEquals(1, count, 'Count of the record should be 1.');
    }
    
    private static QueryBuilder.QueryBuilderParameters getqueryBuilder() {
        queryParams.objectName = Constants.OBJECT_CONTENT_VERSION;
        queryParams.fieldApiName = Constants.CONTENT_VERSION_FIELD_CONTENT_DOCUMENT_ID;
        return queryParams;
    }
    
    private static QueryBuilder.QueryBuilderParameters getqueryBuilderForAccount() {
        queryParams.objectName = Constants.OBJECT_ACCOUNT;
        queryParams.fieldApiNames = new List<String>();
        queryParams.fieldApiNames.add('Name');
        queryParams.fieldApiNames.add('Id');
        return queryParams;
    }
    
    private static String getWhereClause() {
        final StringBuilder whereClauseCondition = new StringBuilder();
        whereClauseCondition.append(Constants.CONTENT_VERSION_FIELD_PATH_ON_CLIENT);
        whereClauseCondition.append(Constants.SOQL_OPERATOR_LIKE);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE);
        whereClauseCondition.append(Constants.LITERAL_PERCENT);
        whereClauseCondition.append(String.escapeSingleQuotes(Constants.FILE_PREFIX_BACKUP));
        whereClauseCondition.append(Constants.LITERAL_PERCENT);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE);
        return whereClauseCondition.toString();
    }
    
    private static QueryBuilder.AggregateParameters getAggregateParameters() {
        QueryBuilder.AggregateParameters aggregateParameters = new QueryBuilder.AggregateParameters();
        aggregateParameters.aggregateFieldAlias = 'ContentSize';
        aggregateParameters.aggregateFieldApiName = 'ContentSize';
        aggregateParameters.aggregateFunction = 'SUM';
        return aggregateParameters;
    }
    
    private static QueryBuilder.AggregateParameters getAggregateParametersForAccount() {
        QueryBuilder.AggregateParameters aggregateParameters = new QueryBuilder.AggregateParameters();
        aggregateParameters.aggregateFieldAlias = 'NumberOfAccount';
        aggregateParameters.aggregateFieldApiName = 'Id';
        aggregateParameters.aggregateFunction = 'COUNT';
        return aggregateParameters;
    }
}