/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-12
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-15   Krrish Joy   Initial Version
**/
trigger ContentDocumentTrigger on ContentDocument (after update, after delete, after undelete) {
    new ContentDocumentTriggerHandler().run();
}