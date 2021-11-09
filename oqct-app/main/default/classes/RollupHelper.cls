/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-15   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class RollupHelper {

    public static void rollupChildFieldsOnInsertDeleteUndelete(RollupHelperParameters rollupHelperParams){
        Map<Id, SObject> parentId2parentRecord = new Map<Id, SObject>();
        for (SObject child : rollupHelperParams.childs) {
            Id parentId = (Id)child.get(rollupHelperParams.lookupFieldName);
            if (parentId != null && !parentId2parentRecord.containsKey(parentId)) {
                SObject parentRecord = parentId.getSObjectType().newSObject(parentId);
                for (AggregateFieldInformation aggregateFieldInfo : rollupHelperParams.aggregateFieldInfos) {
                    parentRecord.put(aggregateFieldInfo.parentFieldApiName, 0);
                }
                parentId2parentRecord.put(parentId, parentRecord);
            }
        }
        RollupHelper.calculateAggregate(parentId2parentRecord, rollupHelperParams);
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    public static void rollupChildFieldsOnUpdate(RollupHelperParameters rollupHelperParams){
        Map<Id, SObject> parentId2parentRecordOld = new Map<Id, SObject>();
        Map<Id, SObject> parentId2parentRecordNew = new Map<Id, SObject>();
        for (Id childId : rollupHelperParams.childId2childRecordOld.keySet()) {
            SObject oldChild = rollupHelperParams.childId2childRecordOld.get(childId);
            SObject newChild = rollupHelperParams.childId2childRecordNew.get(childId);
            if (RollupHelper.isAnyChildFieldChanged(oldChild, newChild, rollupHelperParams)) {
                if (oldChild.get(rollupHelperParams.lookupFieldName) != null && newChild.get(rollupHelperParams.lookupFieldName) != null) {
                    Id newParentId = (Id)newChild.get(rollupHelperParams.lookupFieldName);
                    SObject newParentRecord = newParentId.getSObjectType().newSObject(newParentId);
                    for (AggregateFieldInformation aggregateFieldInfo : rollupHelperParams.aggregateFieldInfos) {
                        newParentRecord.put(aggregateFieldInfo.parentFieldApiName, 0);
                    }
                    parentId2parentRecordNew.put(newParentId, newParentRecord);

                    Id oldParentId = (Id)oldChild.get(rollupHelperParams.lookupFieldName);
                    SObject oldParentRecord = oldParentId.getSObjectType().newSObject(oldParentId);
                    for (AggregateFieldInformation aggregateFieldInfo : rollupHelperParams.aggregateFieldInfos) {
                        oldParentRecord.put(aggregateFieldInfo.parentFieldApiName, 0);
                    }
                    parentId2parentRecordOld.put(oldParentId, oldParentRecord);
                } else if (oldChild.get(rollupHelperParams.lookupFieldName) != null && newChild.get(rollupHelperParams.lookupFieldName) == null) {
                    Id oldParentId = (Id)oldChild.get(rollupHelperParams.lookupFieldName);
                    SObject oldParentRecord = oldParentId.getSObjectType().newSObject(oldParentId);
                    for (AggregateFieldInformation aggregateFieldInfo : rollupHelperParams.aggregateFieldInfos) {
                        oldParentRecord.put(aggregateFieldInfo.parentFieldApiName, 0);
                    }
                    parentId2parentRecordOld.put(oldParentId, oldParentRecord);
                } else {
                    Id newParentId = (Id)newChild.get(rollupHelperParams.lookupFieldName);
                    SObject newParentRecord = newParentId.getSObjectType().newSObject(newParentId);
                    for (AggregateFieldInformation aggregateFieldInfo : rollupHelperParams.aggregateFieldInfos) {
                        newParentRecord.put(aggregateFieldInfo.parentFieldApiName, 0);
                    }
                    parentId2parentRecordNew.put(newParentId, newParentRecord);
                }
            }
        }
        RollupHelper.calculateAggregate(parentId2parentRecordOld, rollupHelperParams);
        RollupHelper.calculateAggregate(parentId2parentRecordNew, rollupHelperParams);
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    public static void calculateAggregate(Map<Id, SObject> parentId2parentRecord, RollupHelperParameters rollupHelperParams){

        if (parentId2parentRecord.isEmpty()) {
            return;
        }

        QueryBuilder.QueryBuilderParameters queryParams = new QueryBuilder.QueryBuilderParameters();

        queryParams.objectName = rollupHelperParams.childObjectName;

        queryParams.aggregateParams = new List<QueryBuilder.AggregateParameters>();
        Map<String, String> parentFieldApiName2aggregateAlias = new Map<String, String>();
        for (Integer i = 0; i < rollupHelperParams.aggregateFieldInfos.size(); i++) {
            final AggregateFieldInformation aggregateFieldInfo = rollupHelperParams.aggregateFieldInfos[i];
            QueryBuilder.AggregateParameters aggregateParam = new QueryBuilder.AggregateParameters();
            aggregateParam.aggregateFunction = aggregateFieldInfo.aggregateFunction;
            if (aggregateFieldInfo.childFieldApiName == null) {
                aggregateParam.aggregateFieldApiName = Constants.LITERAL_EMPTY;
            } else {
                aggregateParam.aggregateFieldApiName = aggregateFieldInfo.childFieldApiName;
            }
            aggregateParam.aggregateFieldAlias = Constants.AGGREGATE_SUFFIX + i;
            queryParams.aggregateParams.add(aggregateParam);
            parentFieldApiName2aggregateAlias.put(aggregateFieldInfo.parentFieldApiName, aggregateParam.aggregateFieldAlias);
        }

        queryParams.addWhereInClause = true;
        queryParams.whereInOrNotInField = rollupHelperParams.lookupFieldName;
        queryParams.stringList = new List<Id>(parentId2parentRecord.keySet());

        queryParams.fieldApiNames = new List<String>{rollupHelperParams.lookupFieldName};

        queryParams.whereClauseCondition = rollupHelperParams.whereClauseCondition;

        List<AggregateResult> aggResults  = QueryBuilder.getAggregateQueryResults(queryParams);
        for (AggregateResult aggResult : aggResults) {
            Id parentId = (Id)aggResult.get(rollupHelperParams.lookupFieldName);
            if (parentId2parentRecord.containsKey(parentId)) {
                SObject parentRecord = parentId2parentRecord.get(parentId);
                for (String parentFieldApiName : parentFieldApiName2aggregateAlias.keySet()) {
                    parentRecord.put(parentFieldApiName, aggResult.get(parentFieldApiName2aggregateAlias.get(parentFieldApiName)));
                }
                parentId2parentRecord.put(parentId, parentRecord);
            }
        }
        DatabaseUtils.updateRecords(parentId2parentRecord.values());
    }

    private static Boolean isAnyChildFieldChanged(SObject oldChild, SObject newChild, RollupHelperParameters rollupHelperParams){
        List<AggregateFieldInformation> aggregateFieldInfos = new List<AggregateFieldInformation>();
        Boolean isChildFieldChanged = false;
        for (AggregateFieldInformation aggregateFieldInfo : rollupHelperParams.aggregateFieldInfos) {
            if (oldChild.get(aggregateFieldInfo.childFieldApiName) != newChild.get(aggregateFieldInfo.childFieldApiName)) {
                isChildFieldChanged = true;
                // break;
            }else {
                aggregateFieldInfos.add(aggregateFieldInfo);
            }
        }
        for (AggregateFieldInformation aggregateFieldInfo : aggregateFieldInfos) {
            while (rollupHelperParams.aggregateFieldInfos.contains(aggregateFieldInfo)) {
                rollupHelperParams.aggregateFieldInfos.remove(rollupHelperParams.aggregateFieldInfos.IndexOf(aggregateFieldInfo));
            }
        }
        if (!isChildFieldChanged) {
            isChildFieldChanged = (oldChild.get(rollupHelperParams.lookupFieldName) != newChild.get(rollupHelperParams.lookupFieldName));
        }
        return isChildFieldChanged;
        
    }
    
    public with sharing class RollupHelperParameters{

        public String childObjectName;

        public String lookupFieldName;

        public List<SObject> childs;

        public Map<Id, SObject> childId2childRecordOld;

        public Map<Id, SObject> childId2childRecordNew;

        public List<AggregateFieldInformation> aggregateFieldInfos;

        public String whereClauseCondition;

    }

    public with sharing class AggregateFieldInformation{

        public String aggregateFunction;

        public String childFieldApiName;

        public String parentFieldApiName;

        public Boolean equals(Object obj) {
            if (obj instanceof AggregateFieldInformation) {
                AggregateFieldInformation agrFldInfo = (AggregateFieldInformation)obj;
                return ((aggregateFunction == agrFldInfo.aggregateFunction) &&
                        (childFieldApiName == agrFldInfo.childFieldApiName) &&
                        (parentFieldApiName == agrFldInfo.parentFieldApiName));
            }
            return false;
        }

        public Integer hashCode() {
            return (31 * (childFieldApiName.length() + parentFieldApiName.length())) ^ aggregateFunction.length();
        }
    }

}