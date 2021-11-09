/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-02-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-14   Krrish Joy   Initial Version
**/
public with sharing class DataCleanReportController {

    @AuraEnabled(cacheable=true)
    public static DatatableUtil.DatatableResponse getDatatable(String datatableRequestParamsString){
        try {
            Utils.debug('datatableRequestParamsString', datatableRequestParamsString);
            DatatableUtil.DatatableRequestParameters datatableRequestParams = (DatatableUtil.DatatableRequestParameters)JSON.deserialize(datatableRequestParamsString, DatatableUtil.DatatableRequestParameters.class);
            DatatableUtil.DatatableResponse datatableResponse = DatatableUtil.fetchDatatableResponse(
                datatableRequestParams
            );
            if (datatableRequestParams.objectName == Constants.OBJECT_DC_RESULTS) {
                datatableResponse.datatableColumns.add(0, DataCleanReportController.getPreviewColumn());
            }
            return datatableResponse;
        } catch (Exception e) {
            Utils.debug('AuraException', e.getMessage());
            Utils.debug('AuraException Line', e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static DatatableUtil.DatatableColumn getPreviewColumn(){
        // TYPE: navigation
        // SUPPORTED TYPE ATTRIBUTES: label, title, target, pageReferencetype, recordId, actionName, pageName, pageApiName, objectApiName, relationshipApiName, columnName, rowId, showAsAnIcon
        DatatableUtil.DatatableColumn dataTableColumnForPreviewButton = new DatatableUtil.DatatableColumn();
        dataTableColumnForPreviewButton.label = 'View';
        dataTableColumnForPreviewButton.fieldName = 'view';
        dataTableColumnForPreviewButton.type = Constants.LIGHTNING_DATA_TYPE_NAVIGATION;
        dataTableColumnForPreviewButton.initialWidth = 50;
        dataTableColumnForPreviewButton.hideDefaultActions = true;
        dataTableColumnForPreviewButton.typeAttributes.label = 'Preview';
        dataTableColumnForPreviewButton.typeAttributes.title = 'Preview';
        dataTableColumnForPreviewButton.typeAttributes.recordId = new DatatableUtil.FieldNameWrapper(Constants.FIELD_RECORD_ID);
        dataTableColumnForPreviewButton.typeAttributes.showAsAnIcon = true;
        return dataTableColumnForPreviewButton;
    }
}