/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-16   Krrish Joy   Initial Version
**/
public with sharing class ContentVersionRollupHelper {
    
    public static void rollupChildFieldsToParent(List<ContentVersion> contentVersions){
        RollupHelper.RollupHelperParameters rollupHelperParams = new RollupHelper.RollupHelperParameters();
        rollupHelperParams.childObjectName = Constants.OBJECT_CONTENT_VERSION;
        rollupHelperParams.childs = contentVersions;
        rollupHelperParams.lookupFieldName = Constants.CONTENT_VERSION_FIELD_FIRST_PUBLISH_LOCATION_ID;
        rollupHelperParams.aggregateFieldInfos = ContentVersionRollupHelper.getAggregateInformation();
        RollupHelper.rollupChildFieldsOnInsertDeleteUndelete(rollupHelperParams);
        rollupHelperParams.aggregateFieldInfos = ContentVersionRollupHelper.getAggregateInformationForBackupFiles();
        rollupHelperParams.whereClauseCondition = ContentVersionRollupHelper.getWhereClauseConditionForBackupFiles();
        RollupHelper.rollupChildFieldsOnInsertDeleteUndelete(rollupHelperParams);
    }

    public static void rollupChildFieldsToParent(Map<Id, ContentVersion> contentVersionId2ContentVersionRecordOld, Map<Id, ContentVersion> contentVersionId2ContentVersionRecordNew){
        RollupHelper.RollupHelperParameters rollupHelperParams = new RollupHelper.RollupHelperParameters();
        rollupHelperParams.childObjectName = Constants.OBJECT_CONTENT_VERSION;
        rollupHelperParams.childId2childRecordOld = contentVersionId2ContentVersionRecordOld;
        rollupHelperParams.childId2childRecordNew = contentVersionId2ContentVersionRecordNew;
        rollupHelperParams.lookupFieldName = Constants.CONTENT_VERSION_FIELD_FIRST_PUBLISH_LOCATION_ID;
        rollupHelperParams.aggregateFieldInfos = ContentVersionRollupHelper.getAggregateInformation();
        RollupHelper.rollupChildFieldsOnUpdate(rollupHelperParams);
        rollupHelperParams.aggregateFieldInfos = ContentVersionRollupHelper.getAggregateInformationForBackupFiles();
        rollupHelperParams.whereClauseCondition = ContentVersionRollupHelper.getWhereClauseConditionForBackupFiles();
        RollupHelper.rollupChildFieldsOnUpdate(rollupHelperParams);
    }

    public static List<RollupHelper.AggregateFieldInformation> getAggregateInformation(){
        List<RollupHelper.AggregateFieldInformation> aggregateFieldInfos = new List<RollupHelper.AggregateFieldInformation>();
        
        RollupHelper.AggregateFieldInformation aggregateFieldInfo1 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo1.aggregateFunction = Constants.AGGREGATE_FUNCTION_COUNT;
        aggregateFieldInfo1.childFieldApiName = Constants.FIELD_RECORD_ID;
        aggregateFieldInfo1.parentFieldApiName = Constants.DC_RESULT_TOTAL_FILE_COUNT;
        aggregateFieldInfos.add(aggregateFieldInfo1);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo2 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo2.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo2.childFieldApiName = Constants.CONTENT_VERSION_FIELD_CONTENT_SIZE;
        aggregateFieldInfo2.parentFieldApiName = Constants.DC_RESULT_TOTAL_FILE_SIZE_BYTES;
        aggregateFieldInfos.add(aggregateFieldInfo2);

        return aggregateFieldInfos;
    }

    public static List<RollupHelper.AggregateFieldInformation> getAggregateInformationForBackupFiles(){
        List<RollupHelper.AggregateFieldInformation> aggregateFieldInfos = new List<RollupHelper.AggregateFieldInformation>();
        
        RollupHelper.AggregateFieldInformation aggregateFieldInfo1 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo1.aggregateFunction = Constants.AGGREGATE_FUNCTION_COUNT;
        aggregateFieldInfo1.childFieldApiName = Constants.FIELD_RECORD_ID;
        aggregateFieldInfo1.parentFieldApiName = Constants.DC_RESULT_TOTAL_BACKUP_FILES;
        aggregateFieldInfos.add(aggregateFieldInfo1);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo2 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo2.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo2.childFieldApiName = Constants.CONTENT_VERSION_FIELD_CONTENT_SIZE;
        aggregateFieldInfo2.parentFieldApiName = Constants.DC_RESULT_BACKUP_FILE_SIZE_BYTES;
        aggregateFieldInfos.add(aggregateFieldInfo2);

        return aggregateFieldInfos;
    }

    public static String getWhereClauseConditionForBackupFiles(){
        final StringBuilder whereClauseCondition = new StringBuilder();
        whereClauseCondition.append(Constants.CONTENT_VERSION_FIELD_PATH_ON_CLIENT);
        whereClauseCondition.append(Constants.SOQL_OPERATOR_LIKE);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE);
        whereClauseCondition.append(Constants.LITERAL_PERCENT);
        whereClauseCondition.append(String.escapeSingleQuotes(Constants.FILE_PREFIX_BACKUP));
        whereClauseCondition.append(Constants.LITERAL_PERCENT);
        whereClauseCondition.append(Constants.LITERAL_SINGLE_QUOTE);
        return whereClauseCondition.toString();
    }
}