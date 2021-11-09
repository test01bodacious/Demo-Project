/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-26
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-21   Krrish Joy   Initial Version
**/
public with sharing class DataCleanDataTypeController {

    @AuraEnabled(cacheable=true)
    public static DatatableUtil.DatatableResponse getDatatable(String datatableRequestParamsString){
        try {
            Utils.debug('datatableRequestParamsString', datatableRequestParamsString);
            DatatableUtil.DatatableRequestParameters datatableRequestParams = (DatatableUtil.DatatableRequestParameters)JSON.deserialize(datatableRequestParamsString, DatatableUtil.DatatableRequestParameters.class);
            DatatableUtil.DatatableResponse dataTableResponse = DatatableUtil.fetchDatatableResponse(
                datatableRequestParams
            );
            dataTableResponse.datatableColumns.add(DataCleanDataTypeController.getEditButtonColumn());
            return dataTableResponse;
        } catch (Exception e) {
            Utils.debug('AuraException', e.getMessage());
            Utils.debug('AuraException Line', e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static DatatableUtil.DatatableColumn getEditButtonColumn(){
        // Available Type Attributes (button): disabled, iconName, iconPosition, label, name, title, variant
        DatatableUtil.DatatableColumn dataTableColumnForRollbackButton = new DatatableUtil.DatatableColumn();
        dataTableColumnForRollbackButton.label = 'Edit';
        dataTableColumnForRollbackButton.fieldName = 'Edit';
        dataTableColumnForRollbackButton.type = Constants.LIGHTNING_DATA_TYPE_BUTTON;
        dataTableColumnForRollbackButton.hideDefaultActions = true;
        dataTableColumnForRollbackButton.typeAttributes.label = 'Edit';
        dataTableColumnForRollbackButton.typeAttributes.title = 'Edit';
        dataTableColumnForRollbackButton.typeAttributes.name = 'Edit';
        dataTableColumnForRollbackButton.typeAttributes.disabled = false;
        dataTableColumnForRollbackButton.typeAttributes.variant = 'brand';
        dataTableColumnForRollbackButton.typeAttributes.iconName = 'utility:edit';
        dataTableColumnForRollbackButton.typeAttributes.iconPosition = 'left';
        return dataTableColumnForRollbackButton;
    }

    @AuraEnabled
    public static Utils.Response saveDataType(OQCT_DaCl__DC_Data_Type__c dcDataType){
        Utils.debug('dcDataType', dcDataType);
        Utils.Response response = new Utils.Response();
        Map<Id, String> errorIds2errorMessages = DatabaseUtils.updateRecordsAndReturnFailedRecordsIdWithErrorMessages(dcDataType);
        if (errorIds2errorMessages.isEmpty()) {
            response.isSuccess = true;
            response.message = 'Data Type setting updated successfully.';
            response.errorMessage = '';
        } else {
            response.isSuccess = false;
            response.message = '';
            response.errorMessage = errorIds2errorMessages.get(dcDataType.Id);
        }
        return response;
    }
}