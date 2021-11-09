/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-20
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-30   Krrish Joy   Initial Version
**/
public with sharing class DCResultSelector {

    public static List<OQCT_DaCl__DC_Result__c> getAllDcResults(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id, Name,
                    OQCT_DaCl__Overall_Result__c,
                    OQCT_DaCl__Total_File_Count__c, OQCT_DaCl__Total_File_Size_Bytes__c,
                    OQCT_DaCl__Total_Backup_files__c,
                    OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c,
                    OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c,
                    OQCT_DaCl__Is_All_Job_Completed__c,
                    OQCT_DaCl__Total_Success__c,
                    OQCT_DaCl__Total_Failure__c,
                    OQCT_DaCl__Parent_Field_History_Deletion_Status__c
                FROM OQCT_DaCl__DC_Result__c
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static OQCT_DaCl__DC_Result__c getDCResultForEmail(Id dcResultId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Master_Object_Name__c,
                    OQCT_DaCl__Total_Success__c,
                    OQCT_DaCl__Total_Failure__c,
                    OQCT_DaCl__Total_Success_Parent__c,
                    OQCT_DaCl__Total_Failure_Parent__c,
                    (SELECT OQCT_DaCl__Related_Object_Name__c,
                            OQCT_DaCl__Total_Related_Success__c,
                            OQCT_DaCl__Total_Related_Failure__c
                    FROM OQCT_DaCl__DC_Related_Results__r)
                FROM OQCT_DaCl__DC_Result__c
                WHERE Id = :dcResultId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static List<OQCT_DaCl__DC_Result__c> getDCResultsByDcConfigIds(Set<Id> dcConfigIds){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM OQCT_DaCl__DC_Result__c
                WHERE OQCT_DaCl__DC_Configuration__c IN :dcConfigIds
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static OQCT_DaCl__DC_Result__c getDCResultsTotalSuccessById(Id dcResultId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Total_Success__c
                FROM OQCT_DaCl__DC_Result__c
                WHERE Id = :dcResultId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }
    
    public static List<OQCT_DaCl__DC_Result__c> getDCResultsBackupFileNamesByIds(Set<Id> dcResultIds){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c,
                    OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c
                FROM OQCT_DaCl__DC_Result__c
                WHERE Id IN :dcResultIds
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<OQCT_DaCl__DC_Result__c> getDCResultsBackupFileNamesBydcConfigIds(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c,
                    OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c
                FROM OQCT_DaCl__DC_Result__c
                WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static OQCT_DaCl__DC_Result__c getIsAllJobCompletedByDcResultId(Id dcResultId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Is_All_Job_Completed__c, OQCT_DaCl__Total_File_Count__c, OQCT_DaCl__Total_File_Size_Bytes__c
                FROM OQCT_DaCl__DC_Result__c
                WHERE Id = :dcResultId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static OQCT_DaCl__DC_Result__c getLatestDCResultByDcConfigIdAndProcessName(Id dcConfigId, String processName){
        Utils.validateQueryStatementLimits();
        return [SELECT Id, Name, OQCT_DaCl__Attempt_No__c
                FROM OQCT_DaCl__DC_Result__c
                WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                    AND OQCT_DaCl__Process__c = :processName
                WITH SECURITY_ENFORCED
                ORDER BY OQCT_DaCl__Attempt_No__c DESC
                LIMIT 1];
    }

    public static List<OQCT_DaCl__DC_Result__c> getLatestDCResultsByDcConfigIdAndProcessName(Id dcConfigId, String processName){
        Utils.validateQueryStatementLimits();
        return [SELECT Id, Name, OQCT_DaCl__Attempt_No__c
                FROM OQCT_DaCl__DC_Result__c
                WHERE OQCT_DaCl__DC_Configuration__c = :dcConfigId
                    AND OQCT_DaCl__Process__c = :processName
                WITH SECURITY_ENFORCED
                ORDER BY OQCT_DaCl__Attempt_No__c DESC
                LIMIT 1];
    }

    public static OQCT_DaCl__DC_Result__c getDCResultChildBatchInformationJsonById(Id dcResultId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Child_Batch_Information_Json__c
                FROM OQCT_DaCl__DC_Result__c
                WHERE Id = :dcResultId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static OQCT_DaCl__DC_Result__c getDCResultFieldHistoryDeletionStatusById(Id dcResultId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Parent_Field_History_Deletion_Status__c
                FROM OQCT_DaCl__DC_Result__c
                WHERE Id = :dcResultId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }
    
}