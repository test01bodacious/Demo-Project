/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-20
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-20   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DataCleanAppConfigurationTriggerTest {
    
    @IsTest
    private static void dataCleanAppConfigurationTriggerInsertTest(){

        Test.startTest();
        DataFactory.initDataCleanAppConfigurations();
        System.assertEquals(1, DataCleanAppConfigurationSelector.getDataCleanAppConfigurationCount(), 'Data Clean App Configuration was not inserted');
        try {
            DataFactory.initDataCleanAppConfigurations();
        } catch(Exception e) {
            System.assertEquals(Constants.DC_APP_CONFIG_TRIGGER_ERROR_CANNOT_INSERT_MORE_THAN_ONE, e.getMessage(), 'Data Clean App Configuration was inserted second time');
        }
        Test.stopTest();

        System.assertEquals(1, DataCleanAppConfigurationSelector.getDataCleanAppConfigurationCount(), 'Data Clean App Configuration was inserted second time');
    }

    @IsTest
    private static void dataCleanAppConfigurationTriggerDeletetTest(){

        OQCT_DaCl__Data_Clean_App_Configurations__c dataCleanAppConfiguration = DataFactory.initDataCleanAppConfigurations();

        Test.startTest();

        try {
            DatabaseUtils.deleteRecords(dataCleanAppConfiguration);
        } catch(Exception e) {
            System.assertEquals(Constants.DC_APP_CONFIG_TRIGGER_ERROR_CANNOT_DELETE, e.getMessage(), 'Data Clean App Configuration was deleted');
        }

        Test.stopTest();

        System.assertEquals(1, DataCleanAppConfigurationSelector.getDataCleanAppConfigurationCount(), 'Data Clean App Configuration was deleted');
    }

}