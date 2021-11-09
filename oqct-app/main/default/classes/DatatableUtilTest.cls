/**
* @description       : 
* @author            : Krrish Joy
* @group             : 
* @last modified on  : 2021-03-20
* @last modified by  : Krrish Joy
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   02-26-2021   Krrish Joy   Initial Version
**/
@isTest
private with sharing class DatatableUtilTest {

    @TestSetup
    static void setupData(){
        DataFactory.initAccounts();
    }

    @IsTest
    private static void buildDatatableColumnTest(){
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
        //from account
        Schema.SObjectType accountSchema = schemaMap.get(Constants.OBJECT_ACCOUNT);
        Map<String, Schema.SObjectField> accountFieldMap = accountSchema.getDescribe().fields.getMap();
        
        //from opportunity
        Schema.DisplayType fieldBoolDataType = schema.DisplayType.BOOLEAN; 
        Schema.DisplayType fieldCurrencyDataType =  schema.DisplayType.CURRENCY;
        Schema.DisplayType fieldDateDataType = schema.DisplayType.DATE; 
        Schema.DisplayType fieldPercentageDataType = schema.DisplayType.PERCENT; 
        Schema.DisplayType fieldPicklistDataType =schema.DisplayType.PICKLIST; 
        
        //from case object
        Schema.DisplayType fieldDateTimeDataType = schema.DisplayType.DATETIME;
        Schema.DisplayType fieldDoubleDataType = schema.DisplayType.DOUBLE;
        Schema.DisplayType fieldEmailDataType = schema.DisplayType.EMAIL;
        Schema.DisplayType fieldEncryptedStringDataType = schema.DisplayType.ENCRYPTEDSTRING;
        Schema.DisplayType fieldIdDataType =schema.DisplayType.ID ; 
        
        Schema.DisplayType fieldPhoneDataType = schema.DisplayType.PHONE; 
        Schema.DisplayType fieldReferenceDataType = schema.DisplayType.REFERENCE; 
        
        //from account field
        
        Schema.DisplayType fieldURLDataType = schema.DisplayType.URL;

        DatatableUtil.DatatableColumn column;

        Test.startTest();
        DatatableUtil.FieldSetMember fieldSetRecord= new DatatableUtil.FieldSetMember();
        //boolean type
        fieldSetRecord.type = fieldBoolDataType;
        fieldSetRecord.sObjectField = accountFieldMap.get('Name');
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        //for currency type        
        fieldSetRecord.type = fieldCurrencyDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        //for date datatype
        fieldSetRecord.type = fieldDateDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        //for date time
        //caseFieldMap 
        fieldSetRecord.type = fieldDateTimeDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        
        //for double type
        fieldSetRecord.type = fieldDoubleDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        //for Email Type
        fieldSetRecord.type = fieldEmailDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        //FOR encryptedText type
        fieldSetRecord.type = fieldEncryptedStringDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        //for ID Type   
        fieldSetRecord.type = fieldIdDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        //for percentace
        fieldSetRecord.type = fieldPercentageDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        //for phone 
        fieldSetRecord.type = fieldPhoneDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        //for picklist type
        fieldSetRecord.type = fieldPicklistDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        //for rReference/Lookup
        fieldSetRecord.type = fieldReferenceDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        fieldSetRecord.type = fieldURLDataType;
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        fieldSetRecord.sObjectField = accountFieldMap.get(Constants.FIELD_RECORD_NAME);
        column = DatatableUtil.buildDatatableColumn(fieldSetRecord);
        System.assertNotEquals(null, column, 'Datatable Column was not returned');
        
        Test.stopTest();
        
    }
    @IsTest
    private static void buildDatatableRowTest(){
        
        List<String> fieldsToBeQueried  = new List<String>();
        fieldsToBeQueried.add('ID');
        fieldsToBeQueried.add('Name');
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = Constants.OBJECT_ACCOUNT;
        datatableRequestParams.fieldApiNames = fieldsToBeQueried;
        datatableRequestParams.fieldSetName = Constants.OBJECT_ACCOUNT;
        Test.startTest();
        //test covergae for buildDatatableRow method
        List<SObject> rows = DatatableUtil.buildDatatableRow(fieldsToBeQueried,datatableRequestParams);
        Test.stopTest();

        System.assertEquals(2, rows.size(), 'Account rows was not returned');
        
    }
    
    @IsTest
    private static void fetchDatatableResponseTest(){
		DatatableUtil.FieldSetMember fieldSetRecord= new DatatableUtil.FieldSetMember();
        fieldSetRecord.type = Schema.Contact.Name.getDescribe().getType();
        fieldSetRecord.sObjectField = Schema.Contact.Name.getDescribe().getSObjectField();
        fieldSetRecord.fieldPath = 'Name';
		DatatableUtil.FieldSetMember fieldSetRecord3 = new DatatableUtil.FieldSetMember();
        fieldSetRecord3.type = Schema.Contact.AccountId.getDescribe().getType();
        fieldSetRecord3.sObjectField = Schema.Contact.AccountId.getDescribe().getSObjectField();
        fieldSetRecord3.fieldPath = 'AccountId';
        DatatableUtil.testFieldSetMembers = new List<DatatableUtil.FieldSetMember>{fieldSetRecord, fieldSetRecord3};

        List<String> fieldsToBeQueried  = new List<String>();
        fieldsToBeQueried.add('ID');
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = Constants.OBJECT_CONTACT;
        datatableRequestParams.fieldApiNames = fieldsToBeQueried;
        datatableRequestParams.fieldSetName='Name';
        
        Test.startTest();
        	Datatableutil.DatatableResponse response = DatatableUtil.fetchDatatableResponse(datatableRequestParams);
        Test.stopTest();
        
        System.assertEquals(response != null, true, 'Response is null.');
        
    }
    
    @IsTest
    private static void fetchDatatableResponseForNullFieldSetTest(){
		DatatableUtil.FieldSetMember fieldSetRecord= new DatatableUtil.FieldSetMember();
        fieldSetRecord.type = Schema.Contact.Name.getDescribe().getType();
        fieldSetRecord.sObjectField = Schema.Contact.Name.getDescribe().getSObjectField();
        fieldSetRecord.fieldPath = 'Name';
		DatatableUtil.FieldSetMember fieldSetRecord3 = new DatatableUtil.FieldSetMember();
        fieldSetRecord3.type = Schema.Contact.AccountId.getDescribe().getType();
        fieldSetRecord3.sObjectField = Schema.Contact.AccountId.getDescribe().getSObjectField();
        fieldSetRecord3.fieldPath = 'AccountId';

        List<String> fieldsToBeQueried  = new List<String>();
        fieldsToBeQueried.add('ID');
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = Constants.OBJECT_CONTACT;
        datatableRequestParams.fieldApiNames = fieldsToBeQueried;
        
        Test.startTest();
        	Datatableutil.DatatableResponse response = DatatableUtil.fetchDatatableResponse(datatableRequestParams);
        Test.stopTest();
        
        System.assertEquals(response != null, true, 'Response is null.');
    }
    
    @IsTest
    private static void fetchDatatableResponseForFieldAPINameNullTest(){
		DatatableUtil.FieldSetMember fieldSetRecord= new DatatableUtil.FieldSetMember();
        fieldSetRecord.type = Schema.Account.AccountNumber.getDescribe().getType();
        fieldSetRecord.sObjectField = Schema.Account.AccountNumber.getDescribe().getSObjectField();
        fieldSetRecord.fieldPath = 'Name';
        DatatableUtil.FieldSetMember fieldSetRecord1	 = new DatatableUtil.FieldSetMember();
        fieldSetRecord1.type = Schema.Account.ParentId.getDescribe().getType();
        fieldSetRecord1.sObjectField = Schema.Account.ParentId.getDescribe().getSObjectField();
        fieldSetRecord1.fieldPath = 'ParentId';
		DatatableUtil.FieldSetMember fieldSetRecord2= new DatatableUtil.FieldSetMember();
        fieldSetRecord2.type = Schema.Contact.Description.getDescribe().getType();
        fieldSetRecord2.sObjectField = Schema.Contact.Description.getDescribe().getSObjectField();
        fieldSetRecord2.fieldPath = 'Description';
		DatatableUtil.FieldSetMember fieldSetRecord3 = new DatatableUtil.FieldSetMember();
        fieldSetRecord3.type = Schema.Contact.AccountId.getDescribe().getType();
        fieldSetRecord3.sObjectField = Schema.Contact.AccountId.getDescribe().getSObjectField();
        fieldSetRecord3.fieldPath = 'Accoint.Id';
        DatatableUtil.testFieldSetMembers = new List<DatatableUtil.FieldSetMember>{fieldSetRecord, fieldSetRecord1, fieldSetRecord2, fieldSetRecord3};
                    
        List<String> fieldsToBeQueried  = new List<String>();
        fieldsToBeQueried.add('ID');
        fieldsToBeQueried.add('Name');
        fieldsToBeQueried.add('ParentId');
        fieldsToBeQueried.add('Description');
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = Constants.OBJECT_ACCOUNT;
        datatableRequestParams.fieldApiNames = fieldsToBeQueried;
        
        Test.startTest();
            Datatableutil.DatatableResponse response = DatatableUtil.fetchDatatableResponse(datatableRequestParams);
        Test.stopTest();
        
        System.assertEquals(response != null, true, 'Response is null.');
    }
    
    @IsTest
    private static void fetchDatatableResponseForParentChildRelationshipTest(){
		DatatableUtil.FieldSetMember fieldSetRecord= new DatatableUtil.FieldSetMember();
        fieldSetRecord.type = Schema.Contact.Name.getDescribe().getType();
        fieldSetRecord.sObjectField = Schema.Contact.Name.getDescribe().getSObjectField();
        fieldSetRecord.fieldPath = 'Name';
        DatatableUtil.FieldSetMember fieldSetRecord1	 = new DatatableUtil.FieldSetMember();
        fieldSetRecord1.type = Schema.Contact.AccountId.getDescribe().getType();
        fieldSetRecord1.sObjectField = Schema.Contact.AccountId.getDescribe().getSObjectField();
        fieldSetRecord1.fieldPath = 'Account.Name';
        DatatableUtil.testFieldSetMembers = new List<DatatableUtil.FieldSetMember>{fieldSetRecord, fieldSetRecord1};

        List<String> fieldsToBeQueried  = new List<String>();
        fieldsToBeQueried.add('ID');
        fieldsToBeQueried.add('Name');
        fieldsToBeQueried.add('Account.Name');
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = Constants.OBJECT_CONTACT;
        datatableRequestParams.fieldApiNames = fieldsToBeQueried;
        datatableRequestParams.additionalFields = new List<String>{'AccountId'};
        
        Test.startTest();
            Datatableutil.DatatableResponse response = DatatableUtil.fetchDatatableResponse(datatableRequestParams);
        Test.stopTest();
        
        System.assertEquals(response != null, true, 'Response is null.');
    }
}