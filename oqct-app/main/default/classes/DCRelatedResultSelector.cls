/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-14
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-19   Krrish Joy   Initial Version
**/
public with sharing class DCRelatedResultSelector {

    public static List<OQCT_DaCl__DC_Related_Result__c> getAllDcRelatedResults(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM OQCT_DaCl__DC_Related_Result__c
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__DC_Related_Result__c> getDcRelatedResultsByDcResultIdAndRelatedObjectName(Id dcResultId, String relatedObjectName){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Total_Related_Success__c,
                    OQCT_DaCl__Total_Related_Failure__c
                FROM OQCT_DaCl__DC_Related_Result__c
                WHERE OQCT_DaCl__DC_Result__c = :dcResultId
                    AND OQCT_DaCl__Related_Object_Name__c = :relatedObjectName
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static List<OQCT_DaCl__DC_Related_Result__c> getDcRelatedResultsByDcResultIdAndRelatedObjectNameExcluded(Id dcResultId, String relatedObjectName){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM OQCT_DaCl__DC_Related_Result__c
                WHERE OQCT_DaCl__DC_Result__c = :dcResultId
                    AND OQCT_DaCl__Related_Object_Name__c != :relatedObjectName
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__DC_Related_Result__c> getDcRelatedResultsFieldHistoryDeletionStatusByDcResultIdAndRelatedObjectName(Id dcResultId, String relatedObjectName){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Related_Field_History_Deletion_Status__c
                FROM OQCT_DaCl__DC_Related_Result__c
                WHERE OQCT_DaCl__DC_Result__c = :dcResultId
                    AND OQCT_DaCl__Related_Object_Name__c = :relatedObjectName
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }
    
}