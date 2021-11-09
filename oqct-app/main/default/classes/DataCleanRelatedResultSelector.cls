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
public with sharing class DataCleanRelatedResultSelector {

    public static List<OQCT_DaCl__Data_Clean_Related_Result__c> getAllDataCleanRelatedResults(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM OQCT_DaCl__Data_Clean_Related_Result__c
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Data_Clean_Related_Result__c> getDataCleanRelatedResultsRelatedObjectNameExcluded(String relatedObjectName){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM OQCT_DaCl__Data_Clean_Related_Result__c
                WHERE OQCT_DaCl__Related_Object_Name__c != :relatedObjectName
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__Data_Clean_Related_Result__c> getDataCleanResultsByDataCleanIdsAndObjectName(Set<Id> dataCleanIds, String objectName){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Data_Clean__c,
                    OQCT_DaCl__Total_Related_Success_Masking__c, OQCT_DaCl__Total_Related_Failure_Masking__c,
                    OQCT_DaCl__Total_Related_Success_Deletion__c, OQCT_DaCl__Total_Related_Failure_Deletion__c,
                    OQCT_DaCl__Total_Related_Success_Archive__c, OQCT_DaCl__Total_Related_Failure_Archive__c,
                    OQCT_DaCl__Total_Related_Success_Cloning__c, OQCT_DaCl__Total_Related_Failure_Cloning__c,
                    OQCT_DaCl__Total_Related_Success_Rollback__c, OQCT_DaCl__Total_Related_Failure_Rollback__c
                FROM OQCT_DaCl__Data_Clean_Related_Result__c
                WHERE OQCT_DaCl__Data_Clean__c IN :dataCleanIds
                    AND OQCT_DaCl__Related_Object_Name__c = :objectName
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

}