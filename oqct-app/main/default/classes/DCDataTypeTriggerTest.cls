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
private with sharing class DCDataTypeTriggerTest {

    @IsTest
    private static void dCDataTypeTriggerDeletetTest() {

        List<OQCT_DaCl__DC_Data_Type__c> dcDataTypes = DataFactory.initDcDataTypes();

        Test.startTest();

        try {
            DatabaseUtils.deleteRecords(dcDataTypes);
        } catch(Exception e) {
            System.assertEquals(Constants.DC_DATA_TYPE_TRIGGER_ERROR_CANNOT_DELETE, e.getMessage(), 'DC-Data Types were deleted');
        }

        Test.stopTest();

        System.assertNotEquals(0, DCDataTypeSelector.getAllDCDataTypes().size(), 'DC-Data Types were deleted');
    }
}