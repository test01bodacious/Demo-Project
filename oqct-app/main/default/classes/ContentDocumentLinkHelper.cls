/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-16   Krrish Joy   Initial Version
**/
public with sharing class ContentDocumentLinkHelper {

    public static List<ContentVersion> getContentVersionsFromContentDocumentLinks(List<SObject> contentDocumentLinks, Schema.SObjectType filterByParentSObjectType){
        contentDocumentLinks = ContentDocumentLinkHelper.filterLinkedEntityIdForDcResults(contentDocumentLinks, filterByParentSObjectType);
        Map<Id, Id> contentDocumentId2LinkedEntityId = new Map<Id, Id>();
        Set<Id> contentDocumentIds = new Set<Id>();
        for (SObject contentDocumentLink : contentDocumentLinks) {
            Id contentDocumentId = (Id)contentDocumentLink.get(Constants.CONTENT_DOCUMENT_LINK_FIELD_CONTENT_DOCUMENT_ID);
            Id linkedEntityId = (Id)contentDocumentLink.get(Constants.CONTENT_DOCUMENT_LINK_FIELD_LINKED_ENTITY_ID);
            contentDocumentIds.add(contentDocumentId);
            contentDocumentId2LinkedEntityId.put(contentDocumentId, linkedEntityId);
        }
        List<ContentVersion> contentVersions = ContentVersionSelector.getContentVersionsByContentDocumentIds(contentDocumentIds);
        return populateFirstPublishLocationIdWithLinkedEntityId(contentVersions.deepClone(), contentDocumentId2LinkedEntityId);
    }

    private static List<SObject> filterLinkedEntityIdForDcResults(List<SObject> contentDocumentLinks, Schema.SObjectType filterByParentSObjectType){
        List<SObject> contentDocumentLinksForDcResults = new List<SObject>();
        for (SObject contentDocumentLink : contentDocumentLinks) {
            Id i = (Id)contentDocumentLink.get(Constants.CONTENT_DOCUMENT_LINK_FIELD_LINKED_ENTITY_ID);
            Schema.SObjectType s = (i).getSobjectType();
            if (s == filterByParentSObjectType) {
                contentDocumentLinksForDcResults.add(contentDocumentLink);
            }
        }
        return contentDocumentLinksForDcResults;
    }

    private static List<ContentVersion> populateFirstPublishLocationIdWithLinkedEntityId(List<ContentVersion> contentVersions, Map<Id, Id> contentDocumentId2LinkedEntityId){
        for (ContentVersion contentVersion : contentVersions) {
            contentVersion.FirstPublishLocationId = contentDocumentId2LinkedEntityId.get(contentVersion.ContentDocumentId);
        }
        return contentVersions;
    }
}