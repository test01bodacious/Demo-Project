/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-20
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-09   Krrish Joy   Initial Version
**/
public with sharing class DataCleanRollbackController {

    @AuraEnabled(cacheable=true)
    public static DatatableUtil.DatatableResponse getDatatable(String datatableRequestParamsString){
        try {
            Utils.debug('datatableRequestParamsString', datatableRequestParamsString);
            DatatableUtil.DatatableRequestParameters datatableRequestParams = (DatatableUtil.DatatableRequestParameters)JSON.deserialize(datatableRequestParamsString, DatatableUtil.DatatableRequestParameters.class);
            DatatableUtil.DatatableResponse dataTableResponse = DatatableUtil.fetchDatatableResponse(
                datatableRequestParams
            );
            dataTableResponse.datatableColumns.add(DataCleanRollbackController.getRollbackButtonColumn(datatableRequestParams.objectName));
            return dataTableResponse;
        } catch (Exception e) {
            Utils.debug('AuraException', e.getMessage());
            Utils.debug('AuraException Line', e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static DatatableUtil.DatatableColumn getRollbackButtonColumn(String objectName){
        // Available Type Attributes (button): disabled, iconName, iconPosition, label, name, title, variant
        DatatableUtil.DatatableColumn dataTableColumnForRollbackButton = new DatatableUtil.DatatableColumn();
        dataTableColumnForRollbackButton.label = 'Rollback';
        dataTableColumnForRollbackButton.fieldName = 'Rollback';
        dataTableColumnForRollbackButton.type = Constants.LIGHTNING_DATA_TYPE_BUTTON;
        dataTableColumnForRollbackButton.hideDefaultActions = true;
        dataTableColumnForRollbackButton.typeAttributes.label = 'Rollback';
        dataTableColumnForRollbackButton.typeAttributes.title = 'Rollback';
        dataTableColumnForRollbackButton.typeAttributes.name = 'Rollback';
        if (objectName == Constants.OBJECT_DC_CONFIGURATION) {
            dataTableColumnForRollbackButton.typeAttributes.disabled = new DatatableUtil.FieldNameWrapper(Constants.DC_CONFIG_FIELD_DISABLE_ROLLBACK_BUTTON);
        } else if (objectName == Constants.OBJECT_DC_RESULTS) {
            dataTableColumnForRollbackButton.typeAttributes.disabled = new DatatableUtil.FieldNameWrapper(Constants.DC_RESULT_DISABLE_ROLLBACK_BUTTON);
        } else if (objectName == Constants.OBJECT_DATA_CLEAN) {
            dataTableColumnForRollbackButton.typeAttributes.disabled = new DatatableUtil.FieldNameWrapper(Constants.DC_FIELD_RESULT_DISABLE_ROLLBACK_BUTTON);
        } else {
            dataTableColumnForRollbackButton.typeAttributes.disabled = false;
        }
        dataTableColumnForRollbackButton.typeAttributes.variant = 'brand';
        dataTableColumnForRollbackButton.typeAttributes.iconName = 'utility:undo';
        dataTableColumnForRollbackButton.typeAttributes.iconPosition = 'left';
        return dataTableColumnForRollbackButton;
    }

    @AuraEnabled
    public static Utils.Response performRollback(String rollbackParamsString){
        Utils.debug('rollbackParamsString', rollbackParamsString);
        Utils.Response response = new Utils.Response();
        try {
            DataCleanRollbackController.DataCleanRollbackParameters rollbackParams = (DataCleanRollbackController.DataCleanRollbackParameters)JSON.deserialize(rollbackParamsString, DataCleanRollbackController.DataCleanRollbackParameters.class);
            DataCleanRollbackController.scheduleRollbackJob(rollbackParams);
            // Return Success Response
            response.isSuccess = true;
            response.errorMessage = '';
        } catch (Exception e) {
            Utils.debug('AuraException', e.getMessage());
            Utils.debug('AuraException Line', e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    private static void scheduleRollbackJob(DataCleanRollbackController.DataCleanRollbackParameters rollbackParams){
        OQCT_DaCl__DC_Configuration__c dcConfiguration = DCConfigurationSelector.getDCConfigurationNameById(rollbackParams.dcConfigId);
        String jobName = dcConfiguration.Name + Constants.JOB_SUFFIX_ROLLBACK;
        String cronString = DateUtils.getCronStringFromDateTime(DateUtils.getNow().addSeconds(3));
        DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrap.dataConfigurationId = dcConfiguration.Id;
        scheduleWrap.batchType  = Constants.BATCH_TYPE.BATCH_ROLLBACK;
        scheduleWrap.dataCleanIds = rollbackParams.dataCleanIds;
        scheduleWrap.resultIds = rollbackParams.resultIds;
        if (!Test.isRunningTest()) {
            System.Schedule(jobName, cronString, new DataCleanSchedulable(scheduleWrap));
        }
        DataCleanRollbackController.updateDcConfigAndCreateResult(dcConfiguration, Constants.PROCESS_ROLLBACK);
    }

    public static void updateDcConfigAndCreateResult(OQCT_DaCl__DC_Configuration__c dcConfiguration, String processName){
        dcConfiguration.OQCT_DaCl__Rollback_Job_Date__c = DateUtils.getNow();
        DatabaseUtils.updateRecords(dcConfiguration);

        OQCT_DaCl__DC_Result__c dcResult = new OQCT_DaCl__DC_Result__c();
        dcResult.OQCT_DaCl__DC_Configuration__c = dcConfiguration.Id;
        dcResult.OQCT_DaCl__Job_Schedule_Date__c = DateUtils.getNow();
        dcResult.OQCT_DaCl__Process__c = processName;
        dcResult.OQCT_DaCl__Job_Name__c = dcConfiguration.Name + Constants.JOB_SUFFIX_ROLLBACK;
        List<OQCT_DaCl__DC_Result__c> results = DCResultSelector.getLatestDCResultsByDcConfigIdAndProcessName(dcConfiguration.Id, processName);
        dcResult.OQCT_DaCl__Attempt_No__c = results.isEmpty() ? 0 : results[0].OQCT_DaCl__Attempt_No__c + 1;
        DatabaseUtils.insertRecords(dcResult);
        DataCleanHelper.createDcRelatedResults(dcResult, dcConfiguration.Id);
    }

    public with sharing class DataCleanRollbackParameters{
        @AuraEnabled
        public String dcConfigId;
        @AuraEnabled
        public List<Id> dataCleanIds;
        @AuraEnabled
        public List<Id> resultIds;
    }
}