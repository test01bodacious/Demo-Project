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
public with sharing class ContentDocumentHelper {

    public static List<ContentVersion> getContentVersionsFromContentDocuments(List<SObject> contentDocuments, Schema.SObjectType filterByParentSObjectType){
        Set<Id> latestPublishedVersionIds = ContentDocumentHelper.getLatestPublishedVersionIds(contentDocuments);
        List<ContentVersion> contentVersions = ContentVersionSelector.getContentVersionsByIds(latestPublishedVersionIds);
        return ContentDocumentHelper.filterFirstPublishLocationIdForDcResults(contentVersions, filterByParentSObjectType);
    }

    private static Set<Id> getLatestPublishedVersionIds(List<SObject> contentDocuments){
        Set<Id> latestPublishedVersionIds = new Set<Id>();
        for (SObject contentDocument : contentDocuments) {
            latestPublishedVersionIds.add((Id)contentDocument.get(Constants.CONTENT_DOCUMENT_FIELD_LATEST_PUBLISHED_VERSION_ID));
        }
        return latestPublishedVersionIds;
    }

    private static List<ContentVersion> filterFirstPublishLocationIdForDcResults(List<ContentVersion> contentVersions, Schema.SObjectType filterByParentSObjectType){
        List<ContentVersion> contentVersionsForDcResults = new List<ContentVersion>();
        for (ContentVersion contentVersion : contentVersions) {
            if (contentVersion.FirstPublishLocationId.getSobjectType() == filterByParentSObjectType) {
                contentVersionsForDcResults.add(contentVersion);
            }
        }
        return contentVersionsForDcResults;
    }
}