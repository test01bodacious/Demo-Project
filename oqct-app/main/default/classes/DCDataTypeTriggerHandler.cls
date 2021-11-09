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
public with sharing class DCDataTypeTriggerHandler extends TriggerHandler{
    
    public DCDataTypeTriggerHandler(){
        //this.setMaxLoopCount(2);
    }

    public override void beforeDelete() {
        DCDataTypeHelper.blockDelete((List<OQCT_DaCl__DC_Data_Type__c>)Trigger.old);
    }
}