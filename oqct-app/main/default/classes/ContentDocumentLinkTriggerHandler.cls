/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-14
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-15   Krrish Joy   Initial Version
**/
public with sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler{

    private static final Schema.SObjectType PARENT_SOBJECT_TYPE = OQCT_DaCl__DC_Result__c.getSObjectType();

    public ContentDocumentLinkTriggerHandler(){
        //this.setMaxLoopCount(2);
    }

    public override void afterDelete() {
        List<ContentVersion> contentVersions = ContentDocumentLinkHelper.getContentVersionsFromContentDocumentLinks(Trigger.old, PARENT_SOBJECT_TYPE);
        if (!contentVersions.isEmpty()) {
            ContentVersionRollupHelper.rollupChildFieldsToParent(contentVersions);
            DataCleanDeleteAuditHelper.trackDeletion(contentVersions, true);
        }
    }
}