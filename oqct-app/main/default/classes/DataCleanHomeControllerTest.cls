/**
* @description       : 
* @author            : Krrish Joy
* @group             : 
* @last modified on  : 2021-03-18
* @last modified by  : Krrish Joy
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   03-05-2021   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DataCleanHomeControllerTest {

    @IsTest
    private static void getTotalActiveJobCountTest(){

        Test.startTest();
		Integer activeCronTriggerCount = DataCleanHomeController.getTotalActiveJobCount();
        Test.stopTest();

        System.assertEquals(0, activeCronTriggerCount, 'Cron Trigger count not correct');
    }
}