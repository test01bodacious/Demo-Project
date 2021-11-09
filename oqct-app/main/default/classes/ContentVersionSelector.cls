/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-21
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-27   Krrish Joy   Initial Version
**/
public with sharing class ContentVersionSelector {

    public static List<ContentVersion> getContentVersionsByIds(Set<Id> contentVersionIds){
        Utils.validateQueryStatementLimits();
        return [SELECT ContentDocumentId, FirstPublishLocationId, Title, PathOnClient, ContentSize
                FROM ContentVersion
                WHERE Id
                    IN :contentVersionIds
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()
                ALL ROWS];
    }


    public static List<ContentVersion> getContentVersionsByContentDocumentIds(Set<Id> contentDocumentIds){
        Utils.validateQueryStatementLimits();
        return [SELECT ContentDocumentId, FirstPublishLocationId, Title, PathOnClient
                FROM ContentVersion
                WHERE ContentDocumentId
                    IN :contentDocumentIds
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()
                ALL ROWS];
    }

    public static List<ContentVersion> getContentVersionsSuccessAndErrorByFirstPublishLocationId(Id firstPublishLocationId){
        Utils.validateQueryStatementLimits();
        List<String> filePrefixes = new List<String>();
        filePrefixes.add(Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_SUCCESS + Constants.LITERAL_PERCENT);
        filePrefixes.add(Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_ERROR + Constants.LITERAL_PERCENT);
        return [SELECT Id
                FROM ContentVersion
                WHERE FirstPublishLocationId = :firstPublishLocationId
                    AND PathOnClient LIKE :filePrefixes
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<ContentVersion> getContentVersionsErrorOnlyByFirstPublishLocationId(Id firstPublishLocationId){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM ContentVersion
                WHERE FirstPublishLocationId = :firstPublishLocationId
                    AND PathOnClient LIKE :(Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_ERROR + Constants.LITERAL_PERCENT)
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static Decimal getContentVersionsTotalSizeByFirstPublishLocationId(Id firstPublishLocationId){
        Utils.validateQueryStatementLimits();
        return (Decimal)([SELECT SUM(ContentSize)
                FROM ContentVersion
                WHERE FirstPublishLocationId = :firstPublishLocationId
                WITH SECURITY_ENFORCED][0].get(Constants.AGGREGATE_RESULT_EXPRESSION));
    }

    public static Decimal getContentVersionsTotalSizeErrorOnlyByFirstPublishLocationId(Id firstPublishLocationId){
        Utils.validateQueryStatementLimits();
        return (Decimal)([SELECT SUM(ContentSize)
                FROM ContentVersion
                WHERE FirstPublishLocationId = :firstPublishLocationId
                    AND PathOnClient LIKE :(Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_ERROR + Constants.LITERAL_PERCENT)
                WITH SECURITY_ENFORCED][0].get(Constants.AGGREGATE_RESULT_EXPRESSION));
    }

    public static ContentVersion getContentVersionByPathOnClient(String pathOnClient){
        Utils.validateQueryStatementLimits();
        return [SELECT PathOnClient
                FROM ContentVersion
                WHERE PathOnClient = :pathOnClient
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static ContentVersion getContentVersionVersionDataByPathOnClient(String pathOnClient){
        Utils.validateQueryStatementLimits();
        return [SELECT VersionData
                FROM ContentVersion
                WHERE PathOnClient = :pathOnClient
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static Integer getContentVersionByFirstPublishLocationIdSuccessAndErrorReportCount(Id dcResultId){
        Utils.validateQueryStatementLimits();
        List<String> filePrefixes = new List<String>();
        filePrefixes.add(Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_SUCCESS + Constants.LITERAL_PERCENT);
        filePrefixes.add(Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_ERROR + Constants.LITERAL_PERCENT);
        return [SELECT Count()
                FROM ContentVersion
                WHERE FirstPublishLocationId = :dcResultId
                    AND PathOnClient LIKE :filePrefixes
                WITH SECURITY_ENFORCED];
    }

    public static Integer getContentVersionByFirstPublishLocationIdBackupReportCount(Id dcResultId){
        Utils.validateQueryStatementLimits();
        List<String> filePrefixes = new List<String>();
        filePrefixes.add(Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_BACKUP + Constants.LITERAL_PERCENT);
        return [SELECT Count()
                FROM ContentVersion
                WHERE FirstPublishLocationId = :dcResultId
                    AND PathOnClient LIKE :filePrefixes
                WITH SECURITY_ENFORCED];
    }

    public static String getContentVersionByFirstPublishLocationIdAndFilePrefixDeleteString(List<Id> dcResultIds){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_CONTENT_VERSION;
        queryParams.fieldApiName = Constants.CONTENT_VERSION_FIELD_CONTENT_DOCUMENT_ID;
        queryParams.whereClauseCondition = Constants.CONTENT_VERSION_FIELD_PATH_ON_CLIENT + Constants.SOQL_OPERATOR_LIKE + Constants.SOQL_BIND_VARIABLE_FILE_PREFIXES;
        queryParams.addWhereInClause = true;
        queryParams.whereInOrNotInField = Constants.CONTENT_VERSION_FIELD_FIRST_PUBLISH_LOCATION_ID;
        queryParams.stringList = dcResultIds;
        return QueryBuilder.getQueryString(queryParams);
    }

    public static String getContentVersionByIdsAndFilePrefixDeleteString(List<Id> contentVersionIds){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_CONTENT_VERSION;
        queryParams.fieldApiName = Constants.CONTENT_VERSION_FIELD_CONTENT_DOCUMENT_ID;
        queryParams.whereClauseCondition = Constants.CONTENT_VERSION_FIELD_PATH_ON_CLIENT + Constants.SOQL_OPERATOR_LIKE + Constants.SOQL_BIND_VARIABLE_FILE_PREFIXES;
        queryParams.addWhereInClause = true;
        queryParams.whereInOrNotInField = Constants.FIELD_RECORD_ID;
        queryParams.stringList = contentVersionIds;
        return QueryBuilder.getQueryString(queryParams);
    }
    
    public static List<ContentVersion> getAllContentVersion(){
        Utils.validateQueryStatementLimits();
        return [SELECT ContentDocumentId, FirstPublishLocationId, Title, PathOnClient, Id
                FROM ContentVersion
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()
                ALL ROWS];
    }    
}