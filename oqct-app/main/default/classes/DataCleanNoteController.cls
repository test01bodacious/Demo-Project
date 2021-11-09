/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-02-22
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-16   Krrish Joy   Initial Version
**/
public with sharing class DataCleanNoteController {

    @AuraEnabled(cacheable=true)
    public static String getTeamNotes(){
        List<OQCT_DaCl__Data_Clean_App_Configurations__c> dataCleanAppConfigurations = DataCleanAppConfigurationSelector.getDataCleanAppConfigurationForTeamNotes();
        if (dataCleanAppConfigurations.isEmpty()) {
            return '';
        } else {
            return dataCleanAppConfigurations[0].OQCT_DaCl__Team_Notes__c;
        }
    }

    @AuraEnabled
    public static Utils.Response saveTeamNotes(String teamNotes){
        Utils.Response response = new Utils.Response();
        List<OQCT_DaCl__Data_Clean_App_Configurations__c> dataCleanAppConfigurations = DataCleanAppConfigurationSelector.getDataCleanAppConfiguration();
        OQCT_DaCl__Data_Clean_App_Configurations__c dataCleanAppConfiguration = new OQCT_DaCl__Data_Clean_App_Configurations__c();
        dataCleanAppConfiguration.OQCT_DaCl__Team_Notes__c = teamNotes;
        if (!dataCleanAppConfigurations.isEmpty()) {
            dataCleanAppConfiguration.Id = dataCleanAppConfigurations[0].Id;
        }
        DatabaseUtils.upsertRecords(dataCleanAppConfiguration);
        response.isSuccess = true;
        response.errorMessage = '';
        return response;
    }
}