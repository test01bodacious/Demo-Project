/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-12
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-28   Krrish Joy   Initial Version
**/
trigger DcConfigurationTrigger on OQCT_DaCl__DC_Configuration__c (before insert, before update, after delete) {
    new DcConfigurationTriggerHandler().run();
}