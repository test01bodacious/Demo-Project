/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-21
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-19   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DataCleanAppGenericCodeCoverageTest {
    
    @TestSetup
    static void setupData(){
        DataFactory.initAccounts();
        OQCT_DaCl__DC_Configuration__c dcConfig = DataFactory.initDcConfiguration();
        List<OQCT_DaCl__Related_Object__c> relatedObjects = DataFactory.initRelatedObjectsFromDcConfig(dcConfig);
        DataFactory.initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(dcConfig, relatedObjects);
        DataFactory.initDataCleansFromDcConfig(dcConfig.Id);
        DataFactory.initResultRecords(dcConfig.Id);
    }

    @IsTest
    private static void getFieldHistoryByIdObjectAndFieldsTest(){
        Set<Id> accountIds = new Map<Id, SObject>(AccountSelector.getAllAccounts()).keySet();
        Set<String> accountFields = new Set<String>{Constants.FIELD_RECORD_NAME};

        Test.startTest();
        List<SObject> accountHistory = SObjectSelector.getFieldHistoryByIdObjectAndFields(Constants.OBJECT_ACCOUNT, accountFields, accountIds);
        Test.stopTest();

        System.assertEquals(0, accountHistory.size(), 'Account History returned');
    }

    @IsTest
    private static void updateDcResultForFieldHistoryDeletionNotEnabledTest(){
        DataCleanBatchHelper.ProcessInformation processinfo = new DataCleanBatchHelper.ProcessInformation();
        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];
        processinfo.resultId = dcResult.Id;

        Test.startTest();
        DataCleanBatchHelper.updateDcResultForFieldHistoryDeletionNotEnabled(processinfo);
        Test.stopTest();

        dcResult = DCResultSelector.getAllDcResults()[0];
        System.assertEquals(Constants.FIELD_HISTORY_DELETE_NOT_TRACKED, dcResult.OQCT_DaCl__Parent_Field_History_Deletion_Status__c, 'Field History Deletion Status not correct on DC-Result');
    }

    @IsTest
    private static void relatedObjectCountRollupTest(){

        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        System.assertEquals(3, dcConfig.OQCT_DaCl__Total_Related_Objects__c, 'Total Related object count not correct');
        System.assertEquals(1, dcConfig.OQCT_DaCl__Total_Related_Objects_Delete__c, 'Total Related object count not correct');

        Test.startTest();

        List<OQCT_DaCl__Related_Object__c> relatedObjects = RelatedObjectSelector.getAllRelatedObjects();

        DatabaseUtils.deleteRecords(relatedObjects[1]);
        dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        System.assertEquals(2, dcConfig.OQCT_DaCl__Total_Related_Objects__c, 'Total Related object count not correct after delete');
        System.assertEquals(1, dcConfig.OQCT_DaCl__Total_Related_Objects_Delete__c, 'Total Related object delete count not correct after delete');

        DatabaseUtils.deleteRecords(new List<SObject>{relatedObjects[0], relatedObjects[2]});
        dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        System.assertEquals(0, dcConfig.OQCT_DaCl__Total_Related_Objects__c, 'Total Related object count not correct after delete');
        System.assertEquals(0, dcConfig.OQCT_DaCl__Total_Related_Objects_Delete__c, 'Total Related object delete count not correct after delete');

        DatabaseUtils.undeleteRecords(relatedObjects);
        dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        System.assertEquals(3, dcConfig.OQCT_DaCl__Total_Related_Objects__c, 'Total Related object count not correct after undelete');
        System.assertEquals(1, dcConfig.OQCT_DaCl__Total_Related_Objects_Delete__c, 'Total Related object delete count not correct after undelete');

        for (OQCT_DaCl__Related_Object__c relatedObject : relatedObjects) {
            relatedObject.OQCT_DaCl__Delete_Related_Records__c = false;
        }
        DatabaseUtils.updateRecords(relatedObjects);
        dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        System.assertEquals(3, dcConfig.OQCT_DaCl__Total_Related_Objects__c, 'Total Related object count not correct after update');
        System.assertEquals(1, dcConfig.OQCT_DaCl__Total_Related_Objects_Delete__c, 'Total Related object delete count not correct after update');

        OQCT_DaCl__DC_Configuration__c dcConfigNew = DataFactory.initDcConfiguration();

        for (OQCT_DaCl__Related_Object__c relatedObject : relatedObjects) {
            relatedObject.OQCT_DaCl__DC_Configuration__c = dcConfigNew.Id;
        }
        DatabaseUtils.updateRecords(relatedObjects);

        dcConfig = DCConfigurationSelector.getAllDCConfigurations()[1];

        dcConfigNew = DCConfigurationSelector.getAllDCConfigurations()[0];

        System.assertEquals(0, dcConfig.OQCT_DaCl__Total_Related_Objects__c, 'Total Related object count not correct under old DC-Config after update');
        System.assertEquals(0, dcConfig.OQCT_DaCl__Total_Related_Objects_Delete__c, 'Total Related object delete count not correct under old DC-Config after update');

        System.assertEquals(3, dcConfigNew.OQCT_DaCl__Total_Related_Objects__c, 'Total Related object count not correct under new DC-Config after update');
        System.assertEquals(1, dcConfigNew.OQCT_DaCl__Total_Related_Objects_Delete__c, 'Total Related object delete count not correct under new DC-Config after update');

        Test.stopTest();
    }

    @IsTest
    private static void dataCleanCountRollupTest(){

        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        System.assertEquals(2, dcConfig.OQCT_DaCl__Total_Data_Cleans__c, 'Total Data Clean count not correct after insert');

        Test.startTest();

        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();

        DatabaseUtils.deleteRecords(dataCleans);
        dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        System.assertEquals(0, dcConfig.OQCT_DaCl__Total_Data_Cleans__c, 'Total Data Clean count not correct after delete');

        DatabaseUtils.undeleteRecords(dataCleans);
        dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        System.assertEquals(2, dcConfig.OQCT_DaCl__Total_Data_Cleans__c, 'Total Data Clean count not correct after undelete');

        Test.stopTest();
    }
}