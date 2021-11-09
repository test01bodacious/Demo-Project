/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-02-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-27   Krrish Joy   Initial Version
**/
public with sharing class ContentDocumentSelector {
    
    public static List<ContentDocument> getContentDocumentsByIds(Set<Id> contentDocumentIds){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM ContentDocument
                WHERE Id
                    IN :contentDocumentIds
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }
    
    public static ContentDocument getContentDocumentLinkByContentDocumentId(Id contentDocumentIds){
        Utils.validateQueryStatementLimits();
        return [SELECT Id, (SELECT Id FROM ContentDocumentLinks)
                FROM ContentDocument
                WHERE Id =:contentDocumentIds
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

}