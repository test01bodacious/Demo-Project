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
public with sharing class ContentDocumentTriggerHandler extends TriggerHandler{

    private static final Schema.SObjectType PARENT_SOBJECT_TYPE = OQCT_DaCl__DC_Result__c.getSObjectType();

    public ContentDocumentTriggerHandler(){
        //this.setMaxLoopCount(2);
    }

    public override void afterDelete() {
        List<ContentVersion> contentVersions = ContentDocumentHelper.getContentVersionsFromContentDocuments(Trigger.old, PARENT_SOBJECT_TYPE);
        if (!contentVersions.isEmpty()) {
            ContentVersionRollupHelper.rollupChildFieldsToParent(contentVersions);
            DataCleanDeleteAuditHelper.trackDeletion(contentVersions);
        }
    }

    public override void afterUpdate() {
        List<ContentVersion> contentVersionsOld = ContentDocumentHelper.getContentVersionsFromContentDocuments(Trigger.old, PARENT_SOBJECT_TYPE);
        List<ContentVersion> contentVersionsNew = ContentDocumentHelper.getContentVersionsFromContentDocuments(Trigger.new, PARENT_SOBJECT_TYPE);
        if (!contentVersionsNew.isEmpty()) {
            if (contentVersionsOld.isEmpty()) {
                ContentVersionRollupHelper.rollupChildFieldsToParent(contentVersionsNew);
            } else {
                ContentVersionRollupHelper.rollupChildFieldsToParent(new Map<Id, ContentVersion>(contentVersionsOld), new Map<Id, ContentVersion>(contentVersionsNew));
            }
        }
    }

    public override void afterUndelete() {
        List<ContentVersion> contentVersions = ContentDocumentHelper.getContentVersionsFromContentDocuments(Trigger.new, PARENT_SOBJECT_TYPE);
        if (!contentVersions.isEmpty()) {
            ContentVersionRollupHelper.rollupChildFieldsToParent(contentVersions);
        }
    }
}