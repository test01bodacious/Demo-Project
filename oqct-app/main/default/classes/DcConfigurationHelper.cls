/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-02-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-28   Krrish Joy   Initial Version
**/
public with sharing class DcConfigurationHelper {

    public static void setLastActivatedDeactivatedBy(List<OQCT_DaCl__DC_Configuration__c> newDcConfigs){
        for (OQCT_DaCl__DC_Configuration__c dcConfig : newDcConfigs) {
            OQCT_DaCl__DC_Configuration__c dcConfigToUpdate = new OQCT_DaCl__DC_Configuration__c();
            dcConfig.OQCT_DaCl__Last_Activated_Deactivated_By__c = Utils.getUserId();
        }
    }
    
    public static void setLastActivatedDeactivatedBy(Map<Id, OQCT_DaCl__DC_Configuration__c> oldMap, Map<Id, OQCT_DaCl__DC_Configuration__c> newMap){
        List<OQCT_DaCl__DC_Configuration__c> dcConfigsToUpdate = new List<OQCT_DaCl__DC_Configuration__c>();
        for (Id dcConfigId : newMap.keySet()) {
            OQCT_DaCl__DC_Configuration__c oldDcConfig = oldMap.get(dcConfigId);
            OQCT_DaCl__DC_Configuration__c newDcConfig = newMap.get(dcConfigId);
            if (oldDcConfig.OQCT_DaCl__Is_Configuration_Active__c != newDcConfig.OQCT_DaCl__Is_Configuration_Active__c) {
                newDcConfig.OQCT_DaCl__Last_Activated_Deactivated_By__c = Utils.getUserId();
            }
        }
    }
    
}