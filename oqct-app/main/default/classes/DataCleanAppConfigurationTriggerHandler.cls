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
public with sharing class DataCleanAppConfigurationTriggerHandler extends TriggerHandler{

    public DataCleanAppConfigurationTriggerHandler(){
        //this.setMaxLoopCount(2);
    }

    public override void beforeInsert() {
        DataCleanAppConfigurationHelper.blockMoreThanOneInsert((List<OQCT_DaCl__Data_Clean_App_Configurations__c>)Trigger.new);
    }

    public override void beforeDelete() {
        DataCleanAppConfigurationHelper.blockDelete((List<OQCT_DaCl__Data_Clean_App_Configurations__c>)Trigger.old);
    }
}