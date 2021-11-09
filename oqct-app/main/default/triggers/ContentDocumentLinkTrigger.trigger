/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-02-16
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-15   Krrish Joy   Initial Version
**/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (after delete) {
    new ContentDocumentLinkTriggerHandler().run();
}