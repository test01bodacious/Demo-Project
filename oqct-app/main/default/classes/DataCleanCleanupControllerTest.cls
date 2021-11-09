/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-21   Krrish Joy   Initial Version
**/
@isTest
private with sharing class DataCleanCleanupControllerTest {

	@TestSetup
    private static void setupData() {
        OQCT_DaCl__DC_Configuration__c dcConfig = DataFactory.initDcConfiguration();
        OQCT_DaCl__DC_Result__c dcResult = DataFactory.initResultRecords(dcConfig.Id);
        DataFactory.initReportsForResult(dcResult.Id);
    }
    
    @IsTest
    private static void getDatatableTest() {
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = Constants.OBJECT_DC_CONFIGURATION;
        datatableRequestParams.fieldApiNames = new List<String>{'Id', 'Name'};
        String jsonString = JSON.serialize(datatableRequestParams);
        
        Test.startTest();
        	DatatableUtil.DatatableResponse response = DataCleanCleanupController.getDatatable(jsonString);
        Test.stopTest();
        
        System.assertEquals(response.datatableData.size() > 0, true, 'Records not received.');    
    }
    
    @IsTest
    private static void getDatatableForErrorTest() {
        String errorMessage = '';
        
        Test.startTest();
            try {
                DatatableUtil.DatatableResponse response = DataCleanCleanupController.getDatatable(null);
            } catch (Exception e) {
                errorMEssage = e.getMessage();
            }
        Test.stopTest();
        
        System.assertEquals(errorMessage, 'Script-thrown exception', 'Error not received.');    
    }

    @IsTest
    private static void deleteDataCleanSuccessAndErrorFilesTestForDcConfig(){

        Map<Id, String> id2Name = new Map<Id, String>();

        for (OQCT_DaCl__DC_Configuration__c dcConfig : DCConfigurationSelector.getAllDCConfigurations()) {
            id2Name.put(dcConfig.Id, dcConfig.Name);
        }

        DeleteDataCleanFileBatch.BatchParameters batchParams = new DeleteDataCleanFileBatch.BatchParameters();
        batchParams.parentName = null;
        batchParams.dataSetName = Constants.DATA_SET_DATA_CLEAN_CONFIGURATIONS;
        batchParams.ids2Name = id2Name;
        batchParams.deleteFilePrefixes = new List<String>{Constants.FILE_PREFIX_SUCCESS, Constants.FILE_PREFIX_ERROR};
        
        Test.startTest();
        Utils.Response response = DataCleanCleanupController.deleteDataCleanSuccessAndErrorFiles(JSON.serialize(batchParams));
        Test.stopTest();

        System.assertEquals(true, response.isSuccess, 'Response was not successfull');

        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        System.assertEquals(0, ContentVersionSelector.getContentVersionByFirstPublishLocationIdSuccessAndErrorReportCount(dcResult.Id), 'Success & Error Report not deleted for DC-Configuration');

    }

    @IsTest
    private static void deleteDataCleanSuccessAndErrorFilesTestForDcResults(){

        Map<Id, String> id2Name = new Map<Id, String>();

        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        id2Name.put(dcResult.Id, dcResult.Name);

        DeleteDataCleanFileBatch.BatchParameters batchParams = new DeleteDataCleanFileBatch.BatchParameters();
        batchParams.parentName = DCConfigurationSelector.getAllDCConfigurations()[0].Name;
        batchParams.dataSetName = Constants.DATA_SET_DATA_CLEAN_RESULTS;
        batchParams.ids2Name = id2Name;
        batchParams.deleteFilePrefixes = new List<String>{Constants.FILE_PREFIX_SUCCESS, Constants.FILE_PREFIX_ERROR};
        
        Test.startTest();
        Utils.Response response = DataCleanCleanupController.deleteDataCleanSuccessAndErrorFiles(JSON.serialize(batchParams));
        Test.stopTest();

        System.assertEquals(true, response.isSuccess, 'Response was not successfull');

        System.assertEquals(0, ContentVersionSelector.getContentVersionByFirstPublishLocationIdSuccessAndErrorReportCount(dcResult.Id), 'Success & Error Report not deleted for DC-Result');

    }

    @IsTest
    private static void deleteDataCleanSuccessAndErrorFilesTestForContentVersions(){

        Map<Id, String> id2Name = new Map<Id, String>();

        for (ContentVersion contentVersions : ContentVersionSelector.getAllContentVersion()) {
            id2Name.put(contentVersions.Id, contentVersions.Title);
        }

        DeleteDataCleanFileBatch.BatchParameters batchParams = new DeleteDataCleanFileBatch.BatchParameters();
        batchParams.parentName = DCResultSelector.getAllDcResults()[0].Name;
        batchParams.dataSetName = Constants.DATA_SET_DATA_CLEAN_FILES;
        batchParams.ids2Name = id2Name;
        batchParams.deleteFilePrefixes = new List<String>{Constants.FILE_PREFIX_SUCCESS, Constants.FILE_PREFIX_ERROR};
        
        Test.startTest();
        Utils.Response response = DataCleanCleanupController.deleteDataCleanSuccessAndErrorFiles(JSON.serialize(batchParams));
        Test.stopTest();

        System.assertEquals(true, response.isSuccess, 'Response was not successfull');

        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        System.assertEquals(0, ContentVersionSelector.getContentVersionByFirstPublishLocationIdSuccessAndErrorReportCount(dcResult.Id), 'Success & Error Report not deleted for ContentVersion');

    }

    @IsTest
    private static void deleteDataCleanSuccessAndErrorFilesTestForError(){
        
        String errorMessage = '';

        Test.startTest();
        try {
            DataCleanCleanupController.deleteDataCleanSuccessAndErrorFiles('Error String');
        } catch(Exception e) {
            errorMEssage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(errorMessage, 'Script-thrown exception', 'Error not received.'); 

        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        System.assertNotEquals(0, ContentVersionSelector.getContentVersionByFirstPublishLocationIdSuccessAndErrorReportCount(dcResult.Id), 'Success & Error Report deleted');

    }
    
    @IsTest
    private static void deleteDataCleanBackupFilesTestForDcConfig(){
        
        Map<Id, String> id2Name = new Map<Id, String>();

        for (OQCT_DaCl__DC_Configuration__c dcConfig : DCConfigurationSelector.getAllDCConfigurations()) {
            id2Name.put(dcConfig.Id, dcConfig.Name);
        }

        DeleteDataCleanFileBatch.BatchParameters batchParams = new DeleteDataCleanFileBatch.BatchParameters();
        batchParams.parentName = null;
        batchParams.dataSetName = Constants.DATA_SET_DATA_CLEAN_CONFIGURATIONS;
        batchParams.ids2Name = id2Name;
        batchParams.deleteFilePrefixes = new List<String>{Constants.FILE_PREFIX_BACKUP};
        
        Test.startTest();
        Utils.Response response = DataCleanCleanupController.deleteDataCleanBackupFiles(JSON.serialize(batchParams));
        Test.stopTest();

        System.assertEquals(true, response.isSuccess, 'Response was not successfull');

        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        System.assertEquals(0, ContentVersionSelector.getContentVersionByFirstPublishLocationIdBackupReportCount(dcResult.Id), 'Backup Report not deleted for DC-Configuration');

    }

    @IsTest
    private static void deleteDataCleanBackupFilesTestForDcResults(){

        Map<Id, String> id2Name = new Map<Id, String>();

        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        id2Name.put(dcResult.Id, dcResult.Name);

        DeleteDataCleanFileBatch.BatchParameters batchParams = new DeleteDataCleanFileBatch.BatchParameters();
        batchParams.parentName = DCConfigurationSelector.getAllDCConfigurations()[0].Name;
        batchParams.dataSetName = Constants.DATA_SET_DATA_CLEAN_RESULTS;
        batchParams.ids2Name = id2Name;
        batchParams.deleteFilePrefixes = new List<String>{Constants.FILE_PREFIX_BACKUP};
        
        Test.startTest();
        Utils.Response response = DataCleanCleanupController.deleteDataCleanBackupFiles(JSON.serialize(batchParams));
        Test.stopTest();

        System.assertEquals(true, response.isSuccess, 'Response was not successfull');

        System.assertEquals(0, ContentVersionSelector.getContentVersionByFirstPublishLocationIdBackupReportCount(dcResult.Id), 'Backup Report not deleted for DC-Result');

    }

    @IsTest
    private static void deleteDataCleanBackupFilesTestForContentVersions(){

        Map<Id, String> id2Name = new Map<Id, String>();

        for (ContentVersion contentVersions : ContentVersionSelector.getAllContentVersion()) {
            id2Name.put(contentVersions.Id, contentVersions.Title);
        }

        DeleteDataCleanFileBatch.BatchParameters batchParams = new DeleteDataCleanFileBatch.BatchParameters();
        batchParams.parentName = DCResultSelector.getAllDcResults()[0].Name;
        batchParams.dataSetName = Constants.DATA_SET_DATA_CLEAN_FILES;
        batchParams.ids2Name = id2Name;
        batchParams.deleteFilePrefixes = new List<String>{Constants.FILE_PREFIX_BACKUP};
        
        Test.startTest();
        Utils.Response response = DataCleanCleanupController.deleteDataCleanBackupFiles(JSON.serialize(batchParams));
        Test.stopTest();

        System.assertEquals(true, response.isSuccess, 'Response was not successfull');

        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        System.assertEquals(0, ContentVersionSelector.getContentVersionByFirstPublishLocationIdBackupReportCount(dcResult.Id), 'Backup Report not deleted for ContentVersion');

    }

    @IsTest
    private static void deleteDataCleanBackupFilesTestForError(){
        
        String errorMessage = '';

        Test.startTest();
        try {
            DataCleanCleanupController.deleteDataCleanBackupFiles('Error String');
        } catch(Exception e) {
            errorMEssage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(errorMessage, 'Script-thrown exception', 'Error not received.');

        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        System.assertNotEquals(0, ContentVersionSelector.getContentVersionByFirstPublishLocationIdBackupReportCount(dcResult.Id), 'Backup Report deleted');

    }
}