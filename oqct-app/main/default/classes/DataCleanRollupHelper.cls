/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-14   Krrish Joy   Initial Version
**/
public with sharing class DataCleanRollupHelper {

    public static void rollupChildFieldsToParent(List<SObject> dataCleans){
        RollupHelper.RollupHelperParameters rollupHelperParams = new RollupHelper.RollupHelperParameters();
        rollupHelperParams.childObjectName = Constants.OBJECT_DATA_CLEAN;
        rollupHelperParams.childs = dataCleans;
        rollupHelperParams.lookupFieldName = Constants.DC_FIELD_DC_CONFIGURATION;
        rollupHelperParams.aggregateFieldInfos = DataCleanRollupHelper.getAggregateInformation();
        RollupHelper.rollupChildFieldsOnInsertDeleteUndelete(rollupHelperParams);
    }

    public static void rollupChildFieldsToParent(Map<Id, SObject> dataCleanId2dataCleanRecordOld, Map<Id, SObject> dataCleanId2dataCleanRecordNew){
        RollupHelper.RollupHelperParameters rollupHelperParams = new RollupHelper.RollupHelperParameters();
        rollupHelperParams.childObjectName = Constants.OBJECT_DATA_CLEAN;
        rollupHelperParams.childId2childRecordOld = dataCleanId2dataCleanRecordOld;
        rollupHelperParams.childId2childRecordNew = dataCleanId2dataCleanRecordNew;
        rollupHelperParams.lookupFieldName = Constants.DC_FIELD_DC_CONFIGURATION;
        rollupHelperParams.aggregateFieldInfos = DataCleanRollupHelper.getAggregateInformation();
        RollupHelper.rollupChildFieldsOnUpdate(rollupHelperParams);
    }

    private static List<RollupHelper.AggregateFieldInformation> getAggregateInformation(){
        List<RollupHelper.AggregateFieldInformation> aggregateFieldInfos = new List<RollupHelper.AggregateFieldInformation>();
        
        RollupHelper.AggregateFieldInformation aggregateFieldInfo1 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo1.aggregateFunction = Constants.AGGREGATE_FUNCTION_COUNT;
        aggregateFieldInfo1.childFieldApiName = Constants.FIELD_RECORD_ID;
        aggregateFieldInfo1.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_DATA_CLEANS;
        aggregateFieldInfos.add(aggregateFieldInfo1);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo2 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo2.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo2.childFieldApiName = Constants.DC_FIELD_TOTAL_MASTER_FAILURE_DELETION;
        aggregateFieldInfo2.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_MASTER_FAILURE_DELETION;
        aggregateFieldInfos.add(aggregateFieldInfo2);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo3 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo3.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo3.childFieldApiName = Constants.DC_FIELD_TOTAL_MASTER_FAILURE_MASKING;
        aggregateFieldInfo3.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_MASTER_FAILURE_MASKING;
        aggregateFieldInfos.add(aggregateFieldInfo3);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo4 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo4.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo4.childFieldApiName = Constants.DC_FIELD_TOTAL_MASTER_SUCCESS_DELETION;
        aggregateFieldInfo4.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_MASTER_SUCCESS_DELETION;
        aggregateFieldInfos.add(aggregateFieldInfo4);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo5 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo5.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo5.childFieldApiName = Constants.DC_FIELD_TOTAL_MASTER_SUCCESS_MASKING;
        aggregateFieldInfo5.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_MASTER_SUCCESS_MASKING;
        aggregateFieldInfos.add(aggregateFieldInfo5);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo6 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo6.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo6.childFieldApiName = Constants.DC_FIELD_TOTAL_MASTER_FAILURE_ROLLBACK;
        aggregateFieldInfo6.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_MASTER_FAILURE_ROLLBACK;
        aggregateFieldInfos.add(aggregateFieldInfo6);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo7 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo7.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo7.childFieldApiName = Constants.DC_FIELD_TOTAL_MASTER_SUCCESS_ROLLBACK;
        aggregateFieldInfo7.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_MASTER_SUCCESS_ROLLBACK;
        aggregateFieldInfos.add(aggregateFieldInfo7);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo8 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo8.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo8.childFieldApiName = Constants.DC_FIELD_TOTAL_MASTER_FAILURE_ARCHIVE;
        aggregateFieldInfo8.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_MASTER_FAILURE_ARCHIVE;
        aggregateFieldInfos.add(aggregateFieldInfo8);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo9 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo9.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo9.childFieldApiName = Constants.DC_FIELD_TOTAL_MASTER_FAILURE_CLONING;
        aggregateFieldInfo9.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_MASTER_FAILURE_CLONING;
        aggregateFieldInfos.add(aggregateFieldInfo9);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo10 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo10.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo10.childFieldApiName = Constants.DC_FIELD_TOTAL_MASTER_SUCCESS_ARCHIVE;
        aggregateFieldInfo10.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_MASTER_SUCCESS_ARCHIVE;
        aggregateFieldInfos.add(aggregateFieldInfo10);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo11 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo11.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo11.childFieldApiName = Constants.DC_FIELD_TOTAL_MASTER_SUCCESS_CLONING;
        aggregateFieldInfo11.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_MASTER_SUCCESS_CLONING;
        aggregateFieldInfos.add(aggregateFieldInfo11);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo12 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo12.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo12.childFieldApiName = Constants.DC_FIELD_TOTAL_RELATED_FAILURE_MASKING;
        aggregateFieldInfo12.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_FAILURE_MASKING;
        aggregateFieldInfos.add(aggregateFieldInfo12);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo13 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo13.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo13.childFieldApiName = Constants.DC_FIELD_TOTAL_RELATED_SUCCESS_DELETION;
        aggregateFieldInfo13.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_SUCCESS_DELETION;
        aggregateFieldInfos.add(aggregateFieldInfo13);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo14 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo14.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo14.childFieldApiName = Constants.DC_FIELD_TOTAL_RELATED_FAILURE_DELETION;
        aggregateFieldInfo14.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_FAILURE_DELETION;
        aggregateFieldInfos.add(aggregateFieldInfo14);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo15 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo15.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo15.childFieldApiName = Constants.DC_FIELD_TOTAL_RELATED_SUCCESS_ROLLBACK;
        aggregateFieldInfo15.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_SUCCESS_ROLLBACK;
        aggregateFieldInfos.add(aggregateFieldInfo15);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo16 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo16.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo16.childFieldApiName = Constants.DC_FIELD_TOTAL_RELATED_FAILURE_ROLLBACK;
        aggregateFieldInfo16.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_FAILURE_ROLLBACK;
        aggregateFieldInfos.add(aggregateFieldInfo16);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo17 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo17.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo17.childFieldApiName = Constants.DC_FIELD_TOTAL_RELATED_SUCCESS_ARCHIVE;
        aggregateFieldInfo17.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_SUCCESS_ARCHIVE;
        aggregateFieldInfos.add(aggregateFieldInfo17);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo18 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo18.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo18.childFieldApiName = Constants.DC_FIELD_TOTAL_RELATED_FAILURE_CLONING;
        aggregateFieldInfo18.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_FAILURE_CLONING;
        aggregateFieldInfos.add(aggregateFieldInfo18);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo19 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo19.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo19.childFieldApiName = Constants.DC_FIELD_TOTAL_RELATED_SUCCESS_CLONING;
        aggregateFieldInfo19.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_SUCCESS_CLONING;
        aggregateFieldInfos.add(aggregateFieldInfo19);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo20 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo20.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo20.childFieldApiName = Constants.DC_FIELD_TOTAL_RELATED_FAILURE_ARCHIVE;
        aggregateFieldInfo20.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_FAILURE_ARCHIVE;
        aggregateFieldInfos.add(aggregateFieldInfo20);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo21 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo21.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo21.childFieldApiName = Constants.DC_FIELD_TOTAL_RELATED_SUCCESS_MASKING;
        aggregateFieldInfo21.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_RELATED_SUCCESS_MASKING;
        aggregateFieldInfos.add(aggregateFieldInfo21);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo22 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo22.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo22.childFieldApiName = Constants.DC_FIELD_IS_MASKING_COMPLETED_1_0;
        aggregateFieldInfo22.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_MASKING_COMPLETED_DATA_CLEAN;
        aggregateFieldInfos.add(aggregateFieldInfo22);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo23 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo23.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo23.childFieldApiName = Constants.DC_FIELD_IS_DELETION_COMPLETED_1_0;
        aggregateFieldInfo23.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_DELETION_COMPLETED_DATA_CLEAN;
        aggregateFieldInfos.add(aggregateFieldInfo23);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo24 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo24.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo24.childFieldApiName = Constants.DC_FIELD_IS_ARCHIVE_COMPLETED_1_0;
        aggregateFieldInfo24.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_ARCHIVE_COMPLETED_DATA_CLEAN;
        aggregateFieldInfos.add(aggregateFieldInfo24);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo25 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo25.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo25.childFieldApiName = Constants.DC_FIELD_IS_CLONING_COMPLETED_1_0;
        aggregateFieldInfo25.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_CLONING_COMPLETED_DATA_CLEAN;
        aggregateFieldInfos.add(aggregateFieldInfo25);

        RollupHelper.AggregateFieldInformation aggregateFieldInfo26 = new RollupHelper.AggregateFieldInformation();
        aggregateFieldInfo26.aggregateFunction = Constants.AGGREGATE_FUNCTION_SUM;
        aggregateFieldInfo26.childFieldApiName = Constants.DC_FIELD_IS_ROLLBACK_COMPLETED_1_0;
        aggregateFieldInfo26.parentFieldApiName = Constants.DC_CONFIG_FIELD_TOTAL_ROLLBACK_COMPLETED_DATA_CLEAN;
        aggregateFieldInfos.add(aggregateFieldInfo26);

        return aggregateFieldInfos;
    }

}