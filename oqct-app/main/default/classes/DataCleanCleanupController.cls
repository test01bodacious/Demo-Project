/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-19
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-14   Krrish Joy   Initial Version
**/
public with sharing class DataCleanCleanupController {

    @AuraEnabled(cacheable=true)
    public static DatatableUtil.DatatableResponse getDatatable(String datatableRequestParamsString){
        try {
            Utils.debug('datatableRequestParamsString', datatableRequestParamsString);
            DatatableUtil.DatatableRequestParameters datatableRequestParams = (DatatableUtil.DatatableRequestParameters)JSON.deserialize(datatableRequestParamsString, DatatableUtil.DatatableRequestParameters.class);
            return DatatableUtil.fetchDatatableResponse(
                datatableRequestParams
            );
        } catch (Exception e) {
            Utils.debug('AuraException', e.getMessage());
            Utils.debug('AuraException Line', e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Utils.Response deleteDataCleanSuccessAndErrorFiles(String batchParamString){
        Utils.debug('batchParamString', batchParamString);
        try {
            DeleteDataCleanFileBatch.BatchParameters batchParams = (DeleteDataCleanFileBatch.BatchParameters)JSON.deserialize(batchParamString, DeleteDataCleanFileBatch.BatchParameters.class);
            batchParams.deleteFilePrefixes = new List<String>{Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_SUCCESS + Constants.LITERAL_PERCENT, Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_ERROR + Constants.LITERAL_PERCENT};
            Utils.Response response = new Utils.Response();
            // if (batchParams.dataSetName == Constants.DATA_SET_DATA_CLEAN_FILES) {
            //     return DataCleanCleanupController.deleteDataCleanFiles(batchParams.ids2Name.keySet());
            // }
            DeleteDataCleanFileBatch deleteDcConfigBatch = new DeleteDataCleanFileBatch(batchParams);
            Id deleteDcConfigBatchId = Database.executeBatch(deleteDcConfigBatch);
            response.isSuccess = true;
            response.errorMessage = '';
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Utils.Response deleteDataCleanBackupFiles(String batchParamString){
        Utils.debug('batchParamString', batchParamString);
        try {
            DeleteDataCleanFileBatch.BatchParameters batchParams = (DeleteDataCleanFileBatch.BatchParameters)JSON.deserialize(batchParamString, DeleteDataCleanFileBatch.BatchParameters.class);
            batchParams.deleteFilePrefixes = new List<String>{Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_BACKUP + Constants.LITERAL_PERCENT};
            Utils.Response response = new Utils.Response();
            // if (batchParams.dataSetName == Constants.DATA_SET_DATA_CLEAN_FILES) {
            //     return DataCleanCleanupController.deleteDataCleanFiles(batchParams.ids2Name.keySet());
            // }
            DeleteDataCleanFileBatch deleteDcConfigBatch = new DeleteDataCleanFileBatch(batchParams);
            Id deleteDcConfigBatchId = Database.executeBatch(deleteDcConfigBatch);
            response.isSuccess = true;
            response.errorMessage = '';
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // private static Utils.Response deleteDataCleanFiles(Set<Id> contentVersionIds){
    //     List<ContentVersion> contentVersions = ContentVersionSelector.getContentVersionsByIds(contentVersionIds);
    //     Set<Id> contentDocumentIds = Utils.extractIds(contentVersions, Utils.getSObjectFieldType(Constants.OBJECT_CONTENT_VERSION, Constants.CONTENT_VERSION_FIELD_CONTENT_DOCUMENT_ID));
    //     List<ContentDocument> contentDocuments = ContentDocumentSelector.getContentDocumentsByIds(contentDocumentIds);
    //     DatabaseUtils.deleteRecords(contentDocuments);
    //     response.isSuccess = true;
    //     response.errorMessage = '';
    //     response.message = 'Selected Files Deleted Successfully';
    //     return response;
    // }
}