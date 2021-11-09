/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-14
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-14   Krrish Joy   Initial Version
**/
trigger DataCleanTrigger on OQCT_DaCl__Data_Clean__c (before insert, after insert, after update, after delete, after undelete) {
    new DataCleanTriggerHandler().run();
}