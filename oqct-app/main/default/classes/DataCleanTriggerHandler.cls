/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-25
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-21   Krrish Joy   Initial Version
**/
public with sharing class DataCleanTriggerHandler extends TriggerHandler{

    public DataCleanTriggerHandler(){
        //this.setMaxLoopCount(2);
    }

    public override void beforeInsert() {
        DataCleanHelper.setDCConfigurationIdFromDCConfigurationName(Trigger.new);
    }

    public override void afterInsert() {
        List<OQCT_DaCl__DC_Configuration__c> dcConfigurations = DataCleanHelper.getDCConfigurations(Trigger.new);
        if (RelatedObjectSelector.getRelatedObjectsByDcConfigsCount(dcConfigurations) != 0) {
            if (!System.isFuture() || !System.isBatch()) {
                DataCleanHelper.createDataCleanRelatedResults(new Map<Id, SObject>(dcConfigurations).keySet(), Trigger.newMap.keySet());
            }
        }
        dcConfigurations = DataCleanHelper.removeDCConfigurationsWithAlreadyActiveJobs(dcConfigurations);
        if (!dcConfigurations.isEmpty()) {
            dcConfigurations = DataCleanHelper.updateDCConfigurationProcessDates(dcConfigurations);
            DataCleanHelper.scheduleJob(dcConfigurations);
        }
        DataCleanRollupHelper.rollupChildFieldsToParent(Trigger.new);
    }

    public override void afterDelete() {
        DataCleanRollupHelper.rollupChildFieldsToParent(Trigger.old);
    }

    public override void afterUpdate() {
        DataCleanRollupHelper.rollupChildFieldsToParent(Trigger.oldMap, Trigger.newMap);
    }

    public override void afterUndelete() {
        DataCleanRollupHelper.rollupChildFieldsToParent(Trigger.new);
    }
}