/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-20
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-20   Krrish Joy   Initial Version
**/
public with sharing class DataCleanAppConfigurationHelper {

    public static void blockMoreThanOneInsert(List<OQCT_DaCl__Data_Clean_App_Configurations__c> dataCleanAppConfigs) {
        Integer totalDataCleanAppConfigs = DataCleanAppConfigurationSelector.getDataCleanAppConfigurationCount();
        for (OQCT_DaCl__Data_Clean_App_Configurations__c dataCleanAppConfig : dataCleanAppConfigs) {
            if (totalDataCleanAppConfigs++ > 0) {
                dataCleanAppConfig.addError(Constants.DC_APP_CONFIG_TRIGGER_ERROR_CANNOT_INSERT_MORE_THAN_ONE);
            }
        }
    }

    public static void blockDelete(List<OQCT_DaCl__Data_Clean_App_Configurations__c> dataCleanAppConfigs) {
        for (OQCT_DaCl__Data_Clean_App_Configurations__c dataCleanAppConfig : dataCleanAppConfigs) {
            dataCleanAppConfig.addError(Constants.DC_APP_CONFIG_TRIGGER_ERROR_CANNOT_DELETE);
        }
    }
}