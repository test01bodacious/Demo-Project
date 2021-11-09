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
private with sharing class DataCleanReportControllerTest {
    private final static String OBJECTNAME = Constants.OBJECT_DC_RESULTS;
    
    @TestSetup
    private static void setupData(){
        OQCT_DaCl__DC_Configuration__c dcConfig = DataFactory.initDcConfiguration();
        DataFactory.initResultRecords(dcConfig.Id);
    }
    
    @IsTest
    static void getDatatableTest(){
        List<String> fieldsToBeQueried  = new List<String>();
        fieldsToBeQueried.add(Constants.FIELD_RECORD_ID);
        fieldsToBeQueried.add(Constants.FIELD_RECORD_NAME);
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = OBJECTNAME;
        datatableRequestParams.fieldApiNames = fieldsToBeQueried;
        String datatableRequestParamsString = JSON.serialize(datatableRequestParams);
        
        Test.startTest();
        DatatableUtil.DatatableResponse response  = DataCleanReportController.getDatatable(datatableRequestParamsString);
        Test.stopTest();

        System.assertNotEquals(null, response, 'Datatable Response is null');
    }
    @IsTest
    static void getDatatableNegativeTest(){
  
        DatatableUtil.DatatableRequestParameters datatableRequestParams = new DatatableUtil.DatatableRequestParameters();
        datatableRequestParams.objectName = OBJECTNAME;
        datatableRequestParams.fieldSetName = 'Wrong Field Set';
        String datatableRequestParamsString = JSON.serialize(datatableRequestParams);
		Test.startTest();
        try{
            DataCleanReportController.getDatatable(datatableRequestParamsString);
        }catch(Exception e){
            System.assertEquals( 'System.AuraHandledException', e.getTypeName(), 'Exception did not matched');
        }
        Test.stopTest();
    }
}