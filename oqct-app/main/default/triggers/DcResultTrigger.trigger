/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-22
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-16   Krrish Joy   Initial Version
**/
trigger DcResultTrigger on OQCT_DaCl__DC_Result__c (after update, after delete) {
    new DcResultTriggerHandler().run();
}