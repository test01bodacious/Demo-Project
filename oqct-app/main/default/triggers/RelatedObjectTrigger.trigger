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
trigger RelatedObjectTrigger on OQCT_DaCl__Related_Object__c (after insert, after update, after delete, after undelete) {
    new RelatedObjectTriggerHandler().run();
}