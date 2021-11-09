/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-13   Krrish Joy   Initial Version
**/
public with sharing class DataCleanSuccessChildSelector {

    public static List<OQCT_DaCl__Data_Clean_Success_Child__c> getDataCleanSuccededChildsByDataCleanIdsAndChildRecordIds(Set<Id> dataCleanIds, Set<Id> childRecordIds){
        return DataCleanSuccessChildSelector.getDataCleanSuccededChildsByDataCleanIdsAndChildRecordIds(dataCleanIds, childRecordIds, false);
    }

    public static List<OQCT_DaCl__Data_Clean_Success_Child__c> getDataCleanSuccededChildsByDataCleanIdsAndChildRecordIds(Set<Id> dataCleanIds, Set<Id> childRecordIds, Boolean isProcess2){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Data_Clean__c, OQCT_DaCl__Child_Record_Id__c
                FROM OQCT_DaCl__Data_Clean_Success_Child__c
                WHERE OQCT_DaCl__Data_Clean__c  IN :dataCleanIds
                    AND OQCT_DaCl__Child_Record_Id__c IN :childRecordIds
                    AND OQCT_DaCl__Is_Process2__c = :isProcess2
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

}