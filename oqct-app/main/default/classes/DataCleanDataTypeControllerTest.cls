/**
* @description       : 
* @author            : Krrish Joy
* @group             : 
* @last modified on  : 2021-03-26
* @last modified by  : Krrish Joy
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   02-26-2021   Krrish Joy   Initial Version
**/
@isTest
private with sharing class DataCleanDataTypeControllerTest {

	@TestSetup
    private static void setupData() {
        DataFactory.initDcDataTypes();
    }
    
    @isTest
    private static void getDatatableTest() {
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = 'OQCT_DaCl__DC_Data_Type__c';
        datatableRequestParams.fieldApiNames = new List<String>{'Id', 'Name'};
        String jsonString = JSON.serialize(datatableRequestParams);
        
        Test.startTest();
        	DatatableUtil.DatatableResponse response = DataCleanDataTypeController.getDatatable(jsonString);
        Test.stopTest();
        
        System.assertEquals(response.datatableData.size() > 0, true, 'Records not retrieved.');    
    }
    
    @IsTest
    private static void saveDataTypeTest() {
        OQCT_DaCl__DC_Data_Type__c dcDataTypeCurrency = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeCurrency.Id = DCDataTypeSelector.getDCDataTypeByDataTypeName(Constants.DC_DATA_TYPE_CURRENCY).Id;
        dcDataTypeCurrency.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeCurrency.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeCurrency.OQCT_DaCl__Custom_Length__c = 12;
        dcDataTypeCurrency.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_CURRENCY;
        dcDataTypeCurrency.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeCurrency.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeCurrency.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeCurrency.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_CURRENCY;
        
        Test.startTest();
        	Utils.Response response = DataCleanDataTypeController.saveDataType(dcDataTypeCurrency);
        Test.stopTest();
        
        System.assertEquals(response.isSuccess, true, 'Records not retrieved.');    
    }
    
    @IsTest
    private static void saveDataTypeFailureTest() {
        OQCT_DaCl__DC_Data_Type__c dcDataTypeCurrency = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeCurrency.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeCurrency.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeCurrency.OQCT_DaCl__Custom_Length__c = 12;
        dcDataTypeCurrency.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_CURRENCY;
        dcDataTypeCurrency.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeCurrency.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeCurrency.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeCurrency.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_CURRENCY;
        
        Test.startTest();
        	Utils.Response response = DataCleanDataTypeController.saveDataType(dcDataTypeCurrency);
        Test.stopTest();
        
        System.assertEquals(response.isSuccess, false, 'Records saved successfuly.');    
    }    
    
    @IsTest
    private static void getDatatableForErrorTest() {
        String errorMessage = '';
        
        Test.startTest();
            try {
                DatatableUtil.DatatableResponse response = DataCleanDataTypeController.getDatatable(null);
            } catch (Exception e) {
                errorMEssage = e.getMessage();
            }
        Test.stopTest();
        
        System.assertEquals(errorMessage, 'Script-thrown exception', 'Error not retrieved.');    
    }
}