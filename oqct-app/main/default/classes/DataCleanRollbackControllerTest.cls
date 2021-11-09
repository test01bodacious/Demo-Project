/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-21   Krrish Joy   Initial Version
**/
@isTest
private with sharing class DataCleanRollbackControllerTest {

	@TestSetup
    private static void setupData() {
        DataFactory.initDataCleanAppConfigurations();
        DataFactory.initDcDataTypes();
        OQCT_DaCl__DC_Configuration__c dcConfig = DataFactory.initDcConfiguration();
        OQCT_DaCl__DC_Configuration__c dcConfigNew = DataFactory.initDcConfiguration();
        List<OQCT_DaCl__Related_Object__c> relatedObjects = DataFactory.initRelatedObjectsFromDcConfig(dcConfig);
        DataFactory.initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(dcConfig, relatedObjects);
        DataFactory.initDataCleansFromDcConfig(dcConfig.Id);
        List<OQCT_DaCl__DC_Configuration__c> parentObject = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c resultObj = DataFactory.initResultRecords(parentObject[0].Id);
        DataFactory.initContentVersion(resultObj.Id);
    }

    private static String getRollbackParamsString(Id dcConfigId, List<Id> resultIds, List<Id> dataCleanIds){
        DataCleanRollbackController.DataCleanRollbackParameters rollbackParams = new DataCleanRollbackController.DataCleanRollbackParameters();
        rollbackParams.dcConfigId = DCConfigurationSelector.getAllDCConfigurations()[0].Id;
        rollbackParams.resultIds = null;
        rollbackParams.dataCleanIds = null;
        return JSON.serialize(rollbackParams);
    }
    
    @IsTest
    private static void getDatatableTest() {
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = Constants.OBJECT_DC_CONFIGURATION;
        datatableRequestParams.fieldApiNames = new List<String>{Constants.FIELD_RECORD_ID, Constants.FIELD_RECORD_NAME};
        String jsonString = JSON.serialize(datatableRequestParams);
        
        Test.startTest();
        DatatableUtil.DatatableResponse response = DataCleanRollbackController.getDatatable(jsonString);
        Test.stopTest();
        
        System.assertEquals(response.datatableData.size() > 0, true, 'Records not retrieved.');
    }
    
    @IsTest
    private static void getDatatableForErrorTest() {
        String errorMessage = '';
        
        Test.startTest();
            try {
                DatatableUtil.DatatableResponse response = DataCleanRollbackController.getDatatable(null);
            } catch (Exception e) {
                errorMEssage = e.getMessage();
            }
        Test.stopTest();
        
        System.assertEquals(errorMessage, 'Script-thrown exception', 'Error not retrieved.');    
    }

    @IsTest
    private static void performRollbackTest() {

        Id dcConfigId = DCConfigurationSelector.getAllDCConfigurations()[0].Id;
        
        Test.startTest();
        Utils.Response response = DataCleanRollbackController.performRollback(getRollbackParamsString(dcConfigId, null, null));
        Test.stopTest();
        
        System.assertEquals(true, response.isSuccess, 'Response is not successfull');
        System.assertEquals(Constants.LITERAL_EMPTY, response.errorMessage, 'Error Message is not empty');    
    }
}