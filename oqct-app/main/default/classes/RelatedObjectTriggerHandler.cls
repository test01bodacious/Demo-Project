/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-14
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-21   Krrish Joy   Initial Version
**/
public with sharing class RelatedObjectTriggerHandler extends TriggerHandler{

    public RelatedObjectTriggerHandler(){
        //this.setMaxLoopCount(2);
    }

    public override void afterInsert() {
        RelatedObjectRollupHelper.rollupChildFieldsToParent(Trigger.new);
        RelatedObjectRollupHelper.rollupChildFieldsToParentDeleteOnly(Trigger.new);
    }

    public override void afterDelete() {
        RelatedObjectRollupHelper.rollupChildFieldsToParent(Trigger.old);
        RelatedObjectRollupHelper.rollupChildFieldsToParentDeleteOnly(Trigger.old);
    }

    public override void afterUpdate() {
        RelatedObjectRollupHelper.rollupChildFieldsToParent(Trigger.oldMap, Trigger.newMap);
        RelatedObjectRollupHelper.rollupChildFieldsToParentDeleteOnly(Trigger.oldMap, Trigger.newMap);
    }

    public override void afterUndelete() {
        RelatedObjectRollupHelper.rollupChildFieldsToParent(Trigger.new);
        RelatedObjectRollupHelper.rollupChildFieldsToParentDeleteOnly(Trigger.new);
    }
}