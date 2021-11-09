/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-08   Krrish Joy   Initial Version
**/
public with sharing class FieldDefinitionSelector {

    public static List<FieldDefinition> getAllFieldDefinitionsNameFieldByEntityDefinitionQualifiedApiNames(List<String> objectApiNames){
        Utils.validateQueryStatementLimits();
        return [SELECT QualifiedApiName, EntityDefinition.QualifiedApiName
                FROM FieldDefinition
                WHERE EntityDefinition.QualifiedApiName IN :objectApiNames
                    AND IsNameField = true
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<FieldDefinition> getAllFieldDefinitionsIsFieldHistoryTrackedByEntityDefinitionQualifiedApiName(String objectApiNames){
        Utils.validateQueryStatementLimits();
        return [SELECT QualifiedApiName 
                FROM FieldDefinition
                WHERE EntityDefinition.QualifiedApiName = :objectApiNames
                    AND IsFieldHistoryTracked = true
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

}