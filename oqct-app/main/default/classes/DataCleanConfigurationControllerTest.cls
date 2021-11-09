/**
* @description       : 
* @author            : Krrish Joy
* @group             : 
* @last modified on  : 2021-03-20
* @last modified by  : Krrish Joy
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   03-05-2021   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DataCleanConfigurationControllerTest {
	@TestSetup
    private static void setupData() {
        DataFactory.initDataCleanAppConfigurations();
        DataFactory.initDcDataTypes();
        OQCT_DaCl__DC_Configuration__c dcConfig = DataFactory.initDcConfiguration();
        OQCT_DaCl__DC_Configuration__c dcConfigNew = DataFactory.initDcConfiguration();
        List<OQCT_DaCl__Related_Object__c> relatedObjects = DataFactory.initRelatedObjectsFromDcConfig(dcConfig);
        DataFactory.initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(dcConfig, relatedObjects);
        DataFactory.initDataCleansFromDcConfig(dcConfig.Id);
    }
    
    @IsTest
    private static void getDatatableTest() {
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = Constants.OBJECT_DC_CONFIGURATION;
        datatableRequestParams.fieldApiNames = new List<String>{Constants.FIELD_RECORD_ID, Constants.FIELD_RECORD_NAME};
        String jsonString = JSON.serialize(datatableRequestParams);
        
        Test.startTest();
        	DatatableUtil.DatatableResponse response = DataCleanConfigurationController.getDatatable(jsonString);
        Test.stopTest();
        
        System.assertEquals(response.datatableData.size() > 0, true, 'Records not retrieved.');
    }
    
    @IsTest
    private static void getDatatableForErrorTest() {
        String errorMessage = '';
        
        Test.startTest();
            try {
                DatatableUtil.DatatableResponse response = DataCleanConfigurationController.getDatatable(null);
            } catch (Exception e) {
                errorMEssage = e.getMessage();
            }
        Test.stopTest();
        
        System.assertEquals(errorMessage, 'Script-thrown exception', 'Error not retrieved.');    
    }
    
    @IsTest
    private static void getObjectOptionsTest() {
        
        Test.startTest();
        	List<Utils.Options> response = DataCleanConfigurationController.getObjectOptions(Constants.DC_ACTION_MASKING_ONLY);
        Test.stopTest();
         
        System.assertEquals(response[0].value, 'contract', 'Records not retrieved.');    
    }
    
    @IsTest
    private static void getMaskableFieldOptionsTest() {
        
        Test.startTest();
        	List<Utils.Options> response = DataCleanConfigurationController.getMaskableFieldOptions(Constants.OBJECT_DC_CONFIGURATION);
        Test.stopTest();
         
        System.assertEquals(response[0].value, 'oqct_dacl__process2_job_id__c', 'Records not retrieved.');    
    }
    
    @IsTest
    private static void getNillableFieldOptionsTest() {
        
        Test.startTest();
        	List<Utils.Options> response = DataCleanConfigurationController.getNillableFieldOptions(Constants.OBJECT_DC_CONFIGURATION);
        Test.stopTest();
         
        System.assertEquals(response[0].value, 'oqct_dacl__process2_job_id__c', 'Records not retrieved.');    
    }
    
    @IsTest
    private static void getPotentialExternalIdFieldOptionsTest() {
        
        Test.startTest();
        	List<Utils.Options> response = DataCleanConfigurationController.getPotentialExternalIdFieldOptions(Constants.OBJECT_DC_CONFIGURATION);
        Test.stopTest();
         
        System.assertEquals(response[0].value, 'oqct_dacl__process2_job_id__c', 'Records not retrieved.');    
    }
    
    @IsTest
    private static void getRecordTypeOptionsTest() {
        
        Test.startTest();
        	List<Utils.Options> response = DataCleanConfigurationController.getRecordTypeOptions(Constants.OBJECT_DC_CONFIGURATION);
        Test.stopTest();
         
        System.assertEquals(response[0].value != null, true, 'Records not retrieved.');    
    }
    
    @IsTest
    private static void getRelatedObjectOptionsTest() {
        
        Test.startTest();
        	List<Utils.Options> response = DataCleanConfigurationController.getRelatedObjectOptions(Constants.OBJECT_DC_CONFIGURATION, false);
        Test.stopTest();
         
        System.assertEquals(response[0].value, 'AssessmentTaskContentDocument', 'Records not retrieved.');    
    }
    
    @IsTest
    private static void activeOrDeactivateDcConfigurationTest() {
        
        Test.startTest();
            Utils.response response = DataCleanConfigurationController.activeOrDeactivateDcConfiguration(
                DCConfigurationSelector.getAllDCConfigurations()[0]);
        Test.stopTest();
         
        System.assertEquals(response.isSuccess, true, 'Records not retrieved.');    
    }
    
    @IsTest
    private static void getRelatedObjectRecordTypeOptionsTest() {
        
        Test.startTest();
            List<DataCleanConfigurationController.RelatedObjectRecordTypes>  response = DataCleanConfigurationController.getRelatedObjectRecordTypeOptions(
                new List<String>{'OQCT_DaCl__Data_Clean__c'});
        Test.stopTest();
         
        System.assertEquals(response.size() > 0, true, 'Records not retrieved.');    
    }
    
    @IsTest
    private static void deleteDcConfigurationsTest() {
        DatabaseUtils.deleteRecords(DCResultSelector.getAllDcResults());
        Map<Id, String> dcConfigId2Name = new Map<Id, String>();
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        dcConfigId2Name.put(dcConfig.Id, dcConfig.Name);
        
        Test.startTest();
            Utils.Response response = DataCleanConfigurationController.deleteDcConfigurations(dcConfigId2Name);
        Test.stopTest();
         
        System.assertEquals(response.isSuccess, true, 'Records not retrieved.');    
    }
    
    @IsTest
    private static void deleteDcConfigurationsFailureTest() {
        Map<Id, String> dcConfigId2Name = new Map<Id, String>();
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        dcConfigId2Name.put(dcConfig.Id, dcConfig.Name);
        
        Test.startTest();
            Utils.Response response = DataCleanConfigurationController.deleteDcConfigurations(dcConfigId2Name);
        Test.stopTest();
         
        System.assertEquals(response.isSuccess, false, 'Records not retrieved.');    
    }
    
    @IsTest
    private static void saveDataCleanConfigurationsTest() {
        DataCleanConfigurationController.DataCleanConfiguration request = new DataCleanConfigurationController.DataCleanConfiguration();
        OQCT_DaCl__DC_Configuration__c config = DCConfigurationSelector.getAllDCConfigurations()[0];
        request.recordId = config.Id;
        request.dataCleanProcessStartAfter = '1.2';
        request.dataCleanProcessStartTime = '2:2';
        request.dataCleanProcess2StartAfter = '2.2';
        request.dataCleanProcess2StartTime = '3:2';
        request.dataCleanDeleteBackupsAfter = '1';
        request.dataCleanDeleteBackupsTime = '5:2';        
        request.retryProcessAfter = '4';
        request.retryProcess2After = '5';
        DataCleanConfigurationController.DataCleanRelatedObject relatedObj =
            new DataCleanConfigurationController.DataCleanRelatedObject();
        relatedObj.dataCleanRelatedObjectRecordTypeAndField = new List<DataCleanConfigurationController.DataCleanRecordTypeAndField>{
            new DataCleanConfigurationController.DataCleanRecordTypeAndField()};
        request.dataCleanRelatedObject = new List<DataCleanConfigurationController.DataCleanRelatedObject>{
            relatedObj};
        request.dataCleanRecordTypeAndField = new List<DataCleanConfigurationController.DataCleanRecordTypeAndField>{
            new DataCleanConfigurationController.DataCleanRecordTypeAndField()};
        
        Test.startTest();
            Utils.Response response = DataCleanConfigurationController.saveDataCleanConfigurations(JSON.serialize(request));
        Test.stopTest();
         
        System.assertEquals(response.isSuccess, true, 'Records not retrieved.');    
    }
    
    @IsTest
    private static void getDataCleanConfigurationComponentEditDataTest() {
        OQCT_DaCl__DC_Configuration__c config = DCConfigurationSelector.getAllDCConfigurations()[0];
        
        Test.startTest();
            DataCleanConfigurationController.DataCleanConfiguration response = DataCleanConfigurationController.getDataCleanConfigurationComponentEditData(config.Id);
        Test.stopTest();
         
        System.assertEquals(response.dataCleanRelatedObject.size() > 0, true, 'Records not retrieved.');    
    }
}