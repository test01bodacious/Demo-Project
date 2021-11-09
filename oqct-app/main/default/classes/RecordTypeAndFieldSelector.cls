/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-30   Krrish Joy   Initial Version
**/
public with sharing class RecordTypeAndFieldSelector {

    public static List<OQCT_DaCl__Record_Type_Field__c> getRecordTypeAndFieldForChildByDcConfigIdAndRelatedObjectName(Id dcConfigId, String relatedObjectName){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Record_Type_Id__c,
                    OQCT_DaCl__Fields_to_Empty__c,
                    OQCT_DaCl__Fields_To_Mask__c
            FROM OQCT_DaCl__Record_Type_Field__c
            WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                AND OQCT_DaCl__Related_Object_Name__c = :relatedObjectName
                AND OQCT_DaCl__Record_Type_Enabled__c = true
            WITH SECURITY_ENFORCED
            LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Record_Type_Field__c> getRecordTypeAndFieldForChildByDcConfigIdAndRelatedObjectNameExcluded(Id dcConfigId, String relatedObjectName){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
            FROM OQCT_DaCl__Record_Type_Field__c
            WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                AND OQCT_DaCl__Related_Object_Name__c != :relatedObjectName
            WITH SECURITY_ENFORCED
            LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Record_Type_Field__c> getRecordTypeAndFieldForParentByDcConfigId(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Record_Type_Id__c,
                        OQCT_DaCl__Fields_to_Empty__c,
                        OQCT_DaCl__Fields_To_Mask__c
                FROM OQCT_DaCl__Record_Type_Field__c
                WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                    AND OQCT_DaCl__Related_Object__c = null
                    AND OQCT_DaCl__Record_Type_Enabled__c = true
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Record_Type_Field__c> getRecordTypeAndFieldForChildByDcConfigId(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM OQCT_DaCl__Record_Type_Field__c
                WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                    AND OQCT_DaCl__Related_Object__c != null
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Record_Type_Field__c> getAllRecordTypeAndFieldByDcConfigIdAndNoRelatedObject(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Record_Type_Id__c,
                        OQCT_DaCl__Record_Type_Name__c,
                        OQCT_DaCl__Fields_to_Empty__c,
                        OQCT_DaCl__Fields_To_Mask__c,
                        OQCT_DaCl__Record_Type_Enabled__c
                FROM OQCT_DaCl__Record_Type_Field__c
                WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                    AND OQCT_DaCl__Related_Object__c = null
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }
}