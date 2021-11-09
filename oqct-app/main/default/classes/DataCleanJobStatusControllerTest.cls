/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-22
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-21   Krrish Joy   Initial Version
**/
@isTest
private with sharing class DataCleanJobStatusControllerTest {

	@testSetup
    private static void setupData() {
        OQCT_DaCl__DC_Configuration__c dcConfig = DataFactory.initDcConfiguration();
        DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrap.dataConfigurationId = dcConfig.Id;
		String cronExp = '0 6 * * * ?';
        System.schedule('DC-Config-DataCleanJobStatusControllerTest', cronExp, new DataCleanSchedulable(scheduleWrap));
    }
    
    @isTest
    private static void getDatatableTest() {
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = 'CronTrigger';
        datatableRequestParams.fieldApiNames = new List<String>{'Id', 'EndTime'};
        String jsonString = JSON.serialize(datatableRequestParams);
        
        Test.startTest();
        	DatatableUtil.DatatableResponse response = DataCleanJobStatusController.getDatatable(jsonString);
        Test.stopTest();
        
        System.assertEquals(response.datatableData.size() > 0, true, 'Records not retrieved.');    
    }
    
    @isTest
    private static void getDatatableForErrorTest() {
        String errorMessage = '';
        
        Test.startTest();
            try {
                DatatableUtil.DatatableResponse response = DataCleanJobStatusController.getDatatable(null);
            } catch (Exception e) {
                errorMEssage = e.getMessage();
            }
        Test.stopTest();
        
        System.assertEquals(errorMessage, 'Script-thrown exception', 'Error not retrieved.');    
    }
    
    @isTest
    private static void getNextJobInfoTest() {
		DeleteDataCleanFileBatch.BatchParameters batchParams = new DeleteDataCleanFileBatch.BatchParameters();
        batchParams.parentName = Constants.OBJECT_DC_CONFIGURATION;
        Map<Id, String> idToNameMap = new Map<Id, String>();
		batchParams.ids2Name = idToNameMap;        
        batchParams.dataSetName = Constants.DATA_SET_DATA_CLEAN_FILES;        
        
        Test.startTest();
        	DataCleanJobStatusController.NextDataCleanJob response = DataCleanJobStatusController.getNextJobInfo();
        Test.stopTest();
        
        System.assertEquals(response.nextJobDateTime != null, true, 'Records not retrieved.');    
    }
    
    @isTest
    private static void abortDataCleanJobsTest() {    
        
        Test.startTest();
        Utils.Response response = DataCleanJobStatusController.abortDataCleanJobs(new List<Id>{CronTriggerSelector.getAbortableCronTriggers()[0].Id});
        Test.stopTest();
        
        System.assertEquals(response.isSuccess, true, 'Records not retrieved.');    
    }
    
    @isTest
    private static void abortDataCleanJobsFailureTest() {    
        
        Test.startTest();
        Utils.Response response = DataCleanJobStatusController.abortDataCleanJobs(new List<Id>{DataFactory.initAccount().Id});
        Test.stopTest();
        
        System.assertEquals(response.isSuccess, true, 'Records not retrieved.');    
    }
}