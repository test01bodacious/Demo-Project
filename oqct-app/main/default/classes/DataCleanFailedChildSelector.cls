/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-18   Krrish Joy   Initial Version
**/
public with sharing class DataCleanFailedChildSelector {

    public static List<OQCT_DaCl__Data_Clean_Failed_Child__c> getDataCleanFailedChildsByDataCleanIdsAndChildRecordIds(Set<Id> dataCleanIds, Set<Id> childRecordIds){
        return DataCleanFailedChildSelector.getDataCleanFailedChildsByDataCleanIdsAndChildRecordIds(dataCleanIds, childRecordIds, false);
    }

    public static List<OQCT_DaCl__Data_Clean_Failed_Child__c> getDataCleanFailedChildsByDataCleanIdsAndChildRecordIds(Set<Id> dataCleanIds, Set<Id> childRecordIds, Boolean isProcess2){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Data_Clean__c, OQCT_DaCl__Child_Record_Id__c
                FROM OQCT_DaCl__Data_Clean_Failed_Child__c
                WHERE OQCT_DaCl__Data_Clean__c  IN :dataCleanIds
                    AND OQCT_DaCl__Child_Record_Id__c IN :childRecordIds
                    AND OQCT_DaCl__Is_Process2__c = :isProcess2
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

}