/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-30   Krrish Joy   Initial Version
**/
public with sharing class DCConfigurationSelector {
    public static List<OQCT_DaCl__DC_Configuration__c> getAllDCConfigurations(){
        Utils.validateQueryStatementLimits();
        return [SELECT Name, OQCT_DaCl__Master_Object_Name__c,
                    OQCT_DaCl__Master_Object_Match_By_Field_Name__c,
                    OQCT_DaCl__Data_Clean_Action__c,
                    OQCT_DaCl__Total_Data_Cleans__c,
                    OQCT_DaCl__Overall_Masking_Status__c,
                    OQCT_DaCl__Overall_Success_Masking__c,
                    OQCT_DaCl__Overall_Success_Deletion__c,
                    OQCT_DaCl__Overall_Rollback_Status__c,
                    OQCT_DaCl__Overall_Success_Rollback__c,
                    OQCT_DaCl__Overall_Deletion_Status__c,
                    OQCT_DaCl__Overall_Archive_Status__c,
                    OQCT_DaCl__Overall_Success_Archive__c,
                    OQCT_DaCl__Total_Related_Objects__c,
                    OQCT_DaCl__Total_Related_Objects_Delete__c
                FROM OQCT_DaCl__DC_Configuration__c
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static OQCT_DaCl__DC_Configuration__c getDCConfigurationNameById(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT Name, OQCT_DaCl__Total_Data_Cleans__c,
                    OQCT_DaCl__Data_Clean_Action__c
                FROM OQCT_DaCl__DC_Configuration__c
                WHERE Id = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static OQCT_DaCl__DC_Configuration__c getDCConfigurationIsActiveById(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Is_Configuration_Active__c
                FROM OQCT_DaCl__DC_Configuration__c
                WHERE Id = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static OQCT_DaCl__DC_Configuration__c getDCConfigurationBackupInfoById(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT Name,
                    OQCT_DaCl__Data_Clean_Action__c,
                    OQCT_DaCl__Delete_Backups_After__c,
                    OQCT_DaCl__Delete_Backups_Time__c,
                    OQCT_DaCl__Delete_Backups_Unit__c,
                    OQCT_DaCl__Total_Backup_files__c
                FROM OQCT_DaCl__DC_Configuration__c
                WHERE Id = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static List<OQCT_DaCl__DC_Configuration__c> getDCConfigurationsByIds(Set<Id> dcConfigIds){
        Utils.validateQueryStatementLimits();
        return [SELECT Name,
                    OQCT_DaCl__Data_Clean_Process_Start_After__c,
                    OQCT_DaCl__Data_Clean_Process_Start_Unit__c, 
                    OQCT_DaCl__Data_Clean_Process_Start_Time__c,
                    OQCT_DaCl__Process_Scheduled_Date_Time_Init__c,
                    OQCT_DaCl__Process_Scheduled_Date_Time_Next__c,
                    OQCT_DaCl__Job_Id__c,
                    OQCT_DaCl__Job_Submit_Date__c,
                    OQCT_DaCl__Retry_Masking__c,
                    OQCT_DaCl__Retry_Deletion__c,
                    OQCT_DaCl__Retry_Archive__c,
                    OQCT_DaCl__Retry_Cloning__c,
                    OQCT_DaCl__Retry_Masking_After__c,
                    OQCT_DaCl__Retry_Masking_Unit__c,
                    OQCT_DaCl__Retry_Deletion_After__c,
                    OQCT_DaCl__Retry_Deletion_Unit__c,
                    OQCT_DaCl__Retry_Archive_After__c,
                    OQCT_DaCl__Retry_Archive_Unit__c,
                    OQCT_DaCl__Retry_Cloning_After__c,
                    OQCT_DaCl__Retry_Cloning_Unit__c,
                    OQCT_DaCl__Data_Clean_Action__c
                FROM OQCT_DaCl__DC_Configuration__c
                WHERE Id IN :dcConfigIds
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static OQCT_DaCl__DC_Configuration__c getDCConfigurationForNextJobsById(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT Name,
                    OQCT_DaCl__Retry_Masking__c,
                    OQCT_DaCl__Retry_Deletion__c,
                    OQCT_DaCl__Retry_Archive__c,
                    OQCT_DaCl__Retry_Cloning__c,
                    OQCT_DaCl__Retry_Masking_After__c,
                    OQCT_DaCl__Retry_Masking_Unit__c,
                    OQCT_DaCl__Retry_Deletion_After__c,
                    OQCT_DaCl__Retry_Deletion_Unit__c,
                    OQCT_DaCl__Retry_Archive_After__c,
                    OQCT_DaCl__Retry_Archive_Unit__c,
                    OQCT_DaCl__Retry_Cloning_After__c,
                    OQCT_DaCl__Retry_Cloning_Unit__c,
                    OQCT_DaCl__Job_Id__c,
                    OQCT_DaCl__Job_Submit_Date__c,
                    OQCT_DaCl__Process2_Job_Id__c,
                    OQCT_DaCl__Process2_Job_Submit_Date__c,
                    OQCT_DaCl__Process2_Scheduled_DateTime_Init__c,
                    OQCT_DaCl__Process2_Scheduled_DateTime_Next__c,
                    OQCT_DaCl__Process2_Start_After__c,
                    OQCT_DaCl__Process2_Start_Time__c,
                    OQCT_DaCl__Process2_Start_Unit__c,
                    OQCT_DaCl__Process_Scheduled_Date_Time_Next__c,
                    OQCT_DaCl__Data_Clean_Action__c,
                    OQCT_DaCl__Overall_Masking_Status__c,
                    OQCT_DaCl__Overall_Deletion_Status__c,
                    OQCT_DaCl__Overall_Archive_Status__c,
                    OQCT_DaCl__Overall_Cloning_Status__c,
                    OQCT_DaCl__Overall_Rollback_Status__c
                FROM OQCT_DaCl__DC_Configuration__c
                WHERE Id = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static OQCT_DaCl__DC_Configuration__c getDCConfigurationForEditById(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT Name,
                    OQCT_DaCl__Data_Clean_Action__c,
                    OQCT_DaCl__Master_Object_Name__c,
                    OQCT_DaCl__Master_Object_Match_By_Field_Name__c,
                    OQCT_DaCl__Configuration_Notes__c,
                    OQCT_DaCl__Receive_Email_Notification__c,
                    OQCT_DaCl__Email_Ids_to_Notify__c,
                    OQCT_DaCl__Receive_Error_Email_Notification__c,
                    OQCT_DaCl__Error_Email_Ids_to_Notify__c,
                    OQCT_DaCl__Data_Clean_Process_Start_After__c,
                    OQCT_DaCl__Data_Clean_Process_Start_Unit__c, 
                    OQCT_DaCl__Data_Clean_Process_Start_Time__c,
                    OQCT_DaCl__Delete_Backups_After__c,
                    OQCT_DaCl__Delete_Backups_Time__c,
                    OQCT_DaCl__Delete_Backups_Unit__c,
                    OQCT_DaCl__Process2_Start_After__c,
                    OQCT_DaCl__Process2_Start_Time__c,
                    OQCT_DaCl__Process2_Start_Unit__c,
                    OQCT_DaCl__Retry_Process__c,
                    OQCT_DaCl__Retry_Process_After__c,
                    OQCT_DaCl__Retry_Process_Unit__c,
                    OQCT_DaCl__Retry_Process2__c,
                    OQCT_DaCl__Retry_Process2_After__c,
                    OQCT_DaCl__Retry_Process2_Unit__c,
                    OQCT_DaCl__Is_Configuration_Active__c
                FROM OQCT_DaCl__DC_Configuration__c
                WHERE Id = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static OQCT_DaCl__DC_Configuration__c getDCConfigurationEmailById(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Receive_Email_Notification__c,
                    OQCT_DaCl__Email_Ids_to_Notify__c,
                    OQCT_DaCl__Receive_Error_Email_Notification__c,
                    OQCT_DaCl__Error_Email_Ids_to_Notify__c
                FROM OQCT_DaCl__DC_Configuration__c
                WHERE Id = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static List<OQCT_DaCl__DC_Configuration__c> getDCConfigurationsByNames(Set<String> dcConfigNames){
        Utils.validateQueryStatementLimits();
        return [SELECT Name,
                    OQCT_DaCl__Data_Clean_Action__c  
                FROM OQCT_DaCl__DC_Configuration__c
                WHERE Name IN :dcConfigNames
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static OQCT_DaCl__DC_Configuration__c getDCConfigurationById(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT Name,
                    OQCT_DaCl__Master_Object_Name__c,
                    OQCT_DaCl__Master_Object_Match_By_Field_Name__c,
                    OQCT_DaCl__Data_Clean_Action__c
                FROM OQCT_DaCl__DC_Configuration__c
                WHERE Id = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()][0];
    }

    public static OQCT_DaCl__DC_Configuration__c getDCConfigurationJobIdById(Id dcConfigId){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Job_Id__c
                FROM OQCT_DaCl__DC_Configuration__c
                WHERE Id = :dcConfigId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static Integer getDcConfigWithoutResultsByIdsCount(Set<Id> dcConfigIds){
        Utils.validateQueryStatementLimits();
        return [SELECT Count()
                FROM OQCT_DaCl__DC_Configuration__c
                WHERE OQCT_DaCl__Total_DC_Results__c = 0
                    AND Id IN :dcConfigIds
                WITH SECURITY_ENFORCED];
    }

    public static String getDcConfigWithoutResultsByIdsDeleteString(List<Id> dcConfigIds){
        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();
        queryParams.objectName = Constants.OBJECT_DC_CONFIGURATION;
        queryParams.fieldApiName = Constants.FIELD_RECORD_ID;

        final StringBuilder whereClauseCondition = new StringBuilder();
        whereClauseCondition.setSeparator(Constants.LITERAL_SPACE);
        whereClauseCondition.append(Constants.DC_CONFIG_FIELD_TOTAL_DC_RESULTS);
        whereClauseCondition.append(Constants.SOQL_OPERATOR_EQUAL);
        whereClauseCondition.append(String.escapeSingleQuotes(String.valueOf(0)));
        queryParams.whereClauseCondition = whereClauseCondition.toString();

        queryParams.addWhereInClause = true;
        queryParams.whereInOrNotInField = Constants.FIELD_RECORD_ID;
        queryParams.stringList = dcConfigIds;
        return QueryBuilder.getQueryString(queryParams);
    }
}