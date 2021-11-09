/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-16
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-12   Krrish Joy   Initial Version
**/
public with sharing class RelatedObjectRollupHelper {

    public static void rollupChildFieldsToParent(List<SObject> relatedObjects){
        RollupHelper.RollupHelperParameters rollupHelperParams = new RollupHelper.RollupHelperParameters();
        rollupHelperParams.childObjectName = Constants.OBJECT_RELATED_OBJECT;
        rollupHelperParams.childs = relatedObjects;
        rollupHelperParams.lookupFieldName = Constants.DC_FIELD_DC_CONFIGURATION;
        rollupHelperParams.aggregateFieldInfos = RelatedObjectRollupHelper.getAggregateInformation();
        RollupHelper.rollupChildFieldsOnInsertDeleteUndelete(rollupHelperParams);
    }

    public static void rollupChildFieldsToParent(Map<Id, SObject> relatedObjectId2relatedObjectRecordOld, Map<Id, SObject> relatedObjectId2relatedObjectRecordNew){
        RollupHelper.RollupHelperParameters rollupHelperParams = new RollupHelper.RollupHelperParameters();
        rollupHelperParams.childObjectName = Constants.OBJECT_RELATED_OBJECT;
        rollupHelperParams.childId2childRecordOld = relatedObjectId2relatedObjectRecordOld;
        rollupHelperParams.childId2childRecordNew = relatedObjectId2relatedObjectRecordNew;
        rollupHelperParams.lookupFieldName = Constants.DC_FIELD_DC_CONFIGURATION;
        rollupHelperParams.aggregateFieldInfos = RelatedObjectRollupHelper.getAggregateInformation();
        RollupHelper.rollupChildFieldsOnUpdate(rollupHelperParams);
    }

    public static void rollupChildFieldsToParentDeleteOnly(List<SObject> relatedObjects){
        RollupHelper.RollupHelperParameters rollupHelperParams = new RollupHelper.RollupHelperParameters();
        rollupHelperParams.childObjectName = Constants.OBJECT_RELATED_OBJECT;
        rollupHelperParams.childs = relatedObjects;
        rollupHelperParams.lookupFieldName = Constants.DC_FIELD_DC_CONFIGURATION;
        rollupHelperParams.whereClauseCondition = Constants.RELATED_OBJECT_FIELD_DELETE_RELATED_RECORDS + Constants.SOQL_OPERATOR_EQUAL + String.escapeSingleQuotes(Constants.LITERAL_TRUE);
        rollupHelperParams.aggregateFieldInfos = RelatedObjectRollupHelper.getAggregateInformationDeleteOnly();
        RollupHelper.rollupChildFieldsOnInsertDeleteUndelete(rollupHelperParams);
    }

    public static void rollupChildFieldsToParentDeleteOnly(Map<Id, SObject> relatedObjectId2relatedObjectRecordOld, Map<Id, SObject> relatedObjectId2relatedObjectRecordNew){
        RollupHelper.RollupHelperParameters rollupHelperParams = new RollupHelper.RollupHelperParameters();
        rollupHelperParams.childObjectName = Constants.OBJECT_RELATED_OBJECT;
        rollupHelperParams.childId2childRecordOld = relatedObjectId2relatedObjectRecordOld;
        rollupHelperParams.childId2childRecordNew = relatedObjectId2relatedObjectRecordNew;
        rollupHelperParams.lookupFieldName = Constants.DC_FIELD_DC_CONFIGURATION;
        rollupHelperParams.aggregateFieldInfos = RelatedObjectRollupHelper.getAggregateInformationDeleteOnly();
        RollupHelper.rollupChildFieldsOnUpdate(rollupHelperParams);
    }

    private static List<RollupHelper.AggregateFieldInformation> getAggregateInformation(){
        List<RollupHelper.AggregateFieldInformation> aggregateFieldInfos = new List<RollupHelper.AggregateFieldInformation>();
        
        RollupHelper.AggregateFieldInformation aggregateFieldInfo = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo.aggregateFunction = Constants.AGGREGATE_FUNCTION_COUNT;
        aggregateFieldInfo.childFieldApiName = Constants.FIELD_RECORD_ID;
        aggregateFieldInfo.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_OBJECTS;
        aggregateFieldInfos.add(aggregateFieldInfo);

        return aggregateFieldInfos;
    }

    private static List<RollupHelper.AggregateFieldInformation> getAggregateInformationDeleteOnly(){
        List<RollupHelper.AggregateFieldInformation> aggregateFieldInfos = new List<RollupHelper.AggregateFieldInformation>();
        
        RollupHelper.AggregateFieldInformation aggregateFieldInfo = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo.aggregateFunction = Constants.AGGREGATE_FUNCTION_COUNT;
        aggregateFieldInfo.childFieldApiName = Constants.FIELD_RECORD_ID;
        aggregateFieldInfo.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_OBJECTS_DELETED;
        aggregateFieldInfos.add(aggregateFieldInfo);

        return aggregateFieldInfos;
    }
}