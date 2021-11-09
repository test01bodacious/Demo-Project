/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-14
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-28   Krrish Joy   Initial Version
**/
public with sharing class DcConfigurationTriggerHandler extends TriggerHandler{
    
    public DcConfigurationTriggerHandler(){
        //this.setMaxLoopCount(2);
    }

    public override void beforeInsert() {
        DcConfigurationHelper.setLastActivatedDeactivatedBy((List<OQCT_DaCl__DC_Configuration__c>)Trigger.new);
    }

    public override void beforeUpdate() {
        DcConfigurationHelper.setLastActivatedDeactivatedBy((Map<Id, OQCT_DaCl__DC_Configuration__c>)Trigger.oldMap, (Map<Id, OQCT_DaCl__DC_Configuration__c>)Trigger.newMap);
    }

    public override void afterDelete() {
        DataCleanDeleteAuditHelper.trackDeletion(Trigger.old);
    }

}