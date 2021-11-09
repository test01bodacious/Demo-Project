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
trigger DataCleanAppConfigurationTrigger on OQCT_DaCl__Data_Clean_App_Configurations__c (before insert, before delete) {
    new DataCleanAppConfigurationTriggerHandler().run();
}