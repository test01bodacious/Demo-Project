/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-05
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-16   Krrish Joy   Initial Version
**/
public with sharing class DataCleanAppConfigurationSelector {
    
    public static List<OQCT_DaCl__Data_Clean_App_Configurations__c> getDataCleanAppConfiguration(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM OQCT_DaCl__Data_Clean_App_Configurations__c
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static List<OQCT_DaCl__Data_Clean_App_Configurations__c> getDataCleanAppConfigurationForTeamNotes(){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Team_Notes__c
                FROM OQCT_DaCl__Data_Clean_App_Configurations__c
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static List<OQCT_DaCl__Data_Clean_App_Configurations__c> getDataCleanAppConfigurationForEmails(){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Send_Global_Email_App_Notification__c,
                    OQCT_DaCl__Admin_Team_Email_Id__c,
                    OQCT_DaCl__External_Department_Email_Id__c
                FROM OQCT_DaCl__Data_Clean_App_Configurations__c
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static Integer getDataCleanAppConfigurationCount(){
        Utils.validateQueryStatementLimits();
        return [SELECT Count()
                FROM OQCT_DaCl__Data_Clean_App_Configurations__c
                WITH SECURITY_ENFORCED];
    }
}