/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-25
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-30   Krrish Joy   Initial Version
**/
public with sharing class RelatedObjectSelector {
    public static List<OQCT_DaCl__Related_Object__c> getAllRelatedObjects(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id, OQCT_DaCl__Delete_Related_Records__c,
                    OQCT_DaCl__DC_Configuration__c
                FROM OQCT_DaCl__Related_Object__c
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Related_Object__c> getRelatedObjectNamesByDcConfigId(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Related_Object_Name__c,
                    OQCT_DaCl__Delete_Related_Records__c
                FROM OQCT_DaCl__Related_Object__c
                WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Related_Object__c> getRelatedObjectNamesByDcConfigs(Set<Id> dcConfigIds){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Related_Object_Name__c,
                    OQCT_DaCl__Delete_Related_Records__c,
                    OQCT_DaCl__DC_Configuration__c
                FROM OQCT_DaCl__Related_Object__c
                WHERE OQCT_DaCl__DC_Configuration__c IN :dcConfigIds
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Related_Object__c> getRelatedObjectsAndRecordTypeAndFieldsByDcConfigId(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT Id,
                    OQCT_DaCl__Related_Object_Name__c,
                    OQCT_DaCl__Delete_Related_Records__c,
                    (SELECT OQCT_DaCl__Record_Type_Id__c,
                        OQCT_DaCl__Record_Type_Name__c,
                        OQCT_DaCl__Fields_to_Empty__c,
                        OQCT_DaCl__Fields_To_Mask__c,
                        OQCT_DaCl__Record_Type_Enabled__c
                    FROM Record_Types_Fields__r)
                FROM OQCT_DaCl__Related_Object__c
                WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Related_Object__c> getRelatedObjectsByDcConfigIdAndRelatedObjectNamesExcluded(Id dcConfigId, List<String> relatedObjectNames){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Related_Object_Name__c,
                    OQCT_DaCl__Delete_Related_Records__c
                FROM OQCT_DaCl__Related_Object__c
                WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                    AND OQCT_DaCl__Related_Object_Name__c
                        NOT IN :relatedObjectNames
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static Integer getRelatedObjectsByDcConfigIdCount(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT Count()
                FROM OQCT_DaCl__Related_Object__c
                WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                WITH SECURITY_ENFORCED];
    }

    public static Integer getRelatedObjectsByDcConfigsCount(List<OQCT_DaCl__DC_Configuration__c> dcConfigs){
        Utils.validateQueryStatementLimits();
        return [SELECT Count()
                FROM OQCT_DaCl__Related_Object__c
                WHERE OQCT_DaCl__DC_Configuration__c IN :dcConfigs
                WITH SECURITY_ENFORCED];
    }
}