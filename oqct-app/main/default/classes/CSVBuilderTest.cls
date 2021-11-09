/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : 
 * @last modified on  : 2021-03-25
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   03-04-2021   Krrish Joy   Initial Version
**/
@isTest
private with sharing class CSVBuilderTest {

    public static CsvBuilder objCSVBuilder = new CsvBuilder();
    public static String headerValue = 'Header';
    public static String fieldValue = 'Field';

    @TestSetup
    private static void setupData(){
        DataFactory.initAccount('Test Account');
    }
    
    @IsTest
    private static void appendFieldTest(){
        
        Test.startTest();
            objCSVBuilder = objCSVBuilder.appendField(headerValue, fieldValue);
        Test.stopTest();

        System.assertEquals(objCSVBuilder.toString(), 'Header' + '\n' + 'Field', 'CSV with header and field should return.');
    }
    
    @IsTest
    private static void appendFieldWithNullValueTest(){
        
        Test.startTest();
            objCSVBuilder = objCSVBuilder.appendField(null, null);
        Test.stopTest();

        System.assertEquals(objCSVBuilder.toString(), 'null' + '\n' + 'null', 'Null CSV should be return.');
    }
    
    @IsTest
    private static void newRowTest(){
        
        Test.startTest();
            objCSVBuilder = objCSVBuilder.newRow();
        Test.stopTest();

        System.assertEquals(objCSVBuilder.currentRow, 1, 'Current row should be one.');
    }
    
    @IsTest
    private static void totalRowsTest(){
        objCSVBuilder.appendField(headerValue, fieldValue);
        
        Test.startTest();
            Integer totalRows = objCSVBuilder.totalRows();
        Test.stopTest();

        System.assertEquals(totalRows, 1, 'Total row should be one.');
    }
    
    @IsTest
    private static void totalRowsWithoutCreatingCSVTest(){
        
        Test.startTest();
            Integer totalRows = objCSVBuilder.totalRows();
        Test.stopTest();

        System.assertEquals(totalRows, 0, 'Total row should be zero.');
    }
        
    @IsTest
    private static void toStringTest(){
        objCSVBuilder.appendField(headerValue, fieldValue);
        
        Test.startTest();
            String result = objCSVBuilder.toString();
        Test.stopTest();

        System.assertEquals(result, 'Header' + '\n' + 'Field', 'String with header and field value should return.');
    }
        
    @IsTest
    private static void getSObjectRecordsAsCsvTest(){
		List<Account> accountList = AccountSelector.getAllAccounts();
        Map<String, String> fieldApiName2headerValue = new Map<String, String>();
        fieldApiName2headerValue.put('Id', 'Id');
        
        Test.startTest();
            String result = CSVBuilder.getSObjectRecordsAsCsv(accountList, fieldApiName2headerValue);
        Test.stopTest();

        System.assertEquals(result, 'Id' + '\n' + accountList[0].Id, 'SObject CSV String with header and field value should return.');
    }
    
    @IsTest
    private static void getSObjectRecordsAsCsvForListInputTest(){
		List<Account> accountList = AccountSelector.getAllAccounts();
        List<String> fieldString = new List<String>();
        fieldString.add('Id');
        
        Test.startTest();
            String result = CSVBuilder.getSObjectRecordsAsCsv(accountList, fieldString);
        Test.stopTest();

        System.assertEquals(result, 'Id' + '\n' + accountList[0].Id, 'SObject CSV String with header and field value should return.');
    }
        
    @IsTest
    private static void getSObjectRecordsAsCsvForSchemaInputTest(){
		List<Account> accountList = AccountSelector.getAllAccounts();
		Schema.DescribeFieldResult describeResult = Account.Id.getDescribe();
        Schema.SObjectField schemaField =  describeResult.getSObjectField();
        
        Test.startTest();
        	String result = CSVBuilder.getSObjectRecordsAsCsv(accountList, new List<Schema.SObjectField>{schemaField});
        Test.stopTest();

        System.assertEquals(result, 'Account ID' + '\n' + accountList[0].Id, 'SObject CSV String with header and field value should return.');
    }

    @IsTest
    private static void getSObjectRecordsAsCsvForStringInputTest(){
		List<Account> accountList = AccountSelector.getAllAccounts();
        
        Test.startTest();
        	String result = CSVBuilder.getSObjectRecordsAsCsv(accountList, Constants.OBJECT_ACCOUNT, 'Id');
        Test.stopTest();

        System.assertEquals(result, '', 'Should return blank string.');
    }
    
    @IsTest
    private static void getRowsAndHeadersAsCsvTest(){
        Map<String, Object> row = new Map<String, Object>();
        row.put('Header', 'Test');
        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        rows.add(row);
        
        Test.startTest();
            CSVBuilder csvReport = new CSVBuilder();
        	csvReport = CSVBuilder.getRowsAndHeadersAsCsv(csvReport, rows, new List<String>{headerValue});
        Test.stopTest();

        System.assertEquals(csvReport.toString(), 'Header' + '\n' + 'Test', 'CSV string should not be blank.');
    }
    
}