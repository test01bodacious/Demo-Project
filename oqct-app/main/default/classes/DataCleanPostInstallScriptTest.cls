/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-26
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-05   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DataCleanPostInstallScriptTest {

    @IsTest
    public static void installScriptTestFirstTimeInstall() {
        DataCleanPostInstallScript postinstall = new DataCleanPostInstallScript();
        Test.startTest();
        Test.testInstall(postinstall, null);
        Test.stopTest();
        Integer dataCleanAppConfigurationCount = DataCleanAppConfigurationSelector.getDataCleanAppConfigurationCount();
        Integer dcDataTypeCount = DCDataTypeSelector.getDCDataTypeCount();
        System.assertEquals(1, dataCleanAppConfigurationCount, 'Data Clean App Configuration was not inserted');
        System.assertEquals(21, dcDataTypeCount, 'DC-Data Types were not inserted');
    }

    @IsTest
    public static void installScriptTestVersion1Upgrade() {
        DataCleanPostInstallScript postinstall = new DataCleanPostInstallScript();
        Test.startTest();
        Test.testInstall(postinstall, new Version(1,0));
        Test.stopTest();
        Integer dataCleanAppConfigurationCount = DataCleanAppConfigurationSelector.getDataCleanAppConfigurationCount();
        Integer dcDataTypeCount = DCDataTypeSelector.getDCDataTypeCount();
        System.assertEquals(0, dataCleanAppConfigurationCount, 'Data Clean App Configuration was inserted');
        System.assertEquals(0, dcDataTypeCount, 'DC-Data Types were inserted');
    }

    @IsTest
    public static void installScriptTestVersion1Push() {
        DataCleanPostInstallScript postinstall = new DataCleanPostInstallScript();
        Test.startTest();
        Test.testInstall(postinstall, new Version(1,0), true);
        Test.stopTest();
        Integer dataCleanAppConfigurationCount = DataCleanAppConfigurationSelector.getDataCleanAppConfigurationCount();
        Integer dcDataTypeCount = DCDataTypeSelector.getDCDataTypeCount();
        System.assertEquals(0, dataCleanAppConfigurationCount, 'Data Clean App Configuration was inserted');
        System.assertEquals(0, dcDataTypeCount, 'DC-Data Types were inserted');
    }
}