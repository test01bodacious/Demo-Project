/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-22
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-16   Krrish Joy   Initial Version
**/
public with sharing class DcResultTriggerHandler extends TriggerHandler{
    
    public DcResultTriggerHandler(){
        //this.setMaxLoopCount(2);
    }

    public override void afterUpdate() {
        DcResultHelper.scheuleAutoBackupDeleteJob((Map<Id, OQCT_DaCl__DC_Result__c>)Trigger.oldMap, (Map<Id, OQCT_DaCl__DC_Result__c>)Trigger.newMap);
    }

    public override void afterDelete() {
        DataCleanDeleteAuditHelper.trackDeletion(Trigger.old);
    }

}