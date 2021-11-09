/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-27   Krrish Joy   Initial Version
**/
public with sharing class DeleteDataCleanFileBatch implements Database.Batchable<sObject>{

    private BatchParameters batchParams;

    // Parameterized Constructor
    public DeleteDataCleanFileBatch(BatchParameters batchParams){
        this.batchParams = batchParams;
    }

    // Batch Methods
	public Database.QueryLocator start(Database.BatchableContext bc){
        List<String> stringList = DeleteDataCleanFileBatch.getIdsToForQuery(this.batchParams.ids2Name.keySet(), this.batchParams.dataSetName);
        List<String> filePrefixes = this.batchParams.deleteFilePrefixes;
        if (this.batchParams.dataSetName == Constants.DATA_SET_DATA_CLEAN_FILES) {
            return Database.getQueryLocator(ContentVersionSelector.getContentVersionByIdsAndFilePrefixDeleteString(stringList));
        } else {
            return Database.getQueryLocator(ContentVersionSelector.getContentVersionByFirstPublishLocationIdAndFilePrefixDeleteString(stringList));
        }
    }
    
	public void execute(Database.BatchableContext bc, List<SObject> scope){
        Set<Id> contentDocumentIds = Utils.extractIds(scope, Utils.getSObjectFieldType(Constants.OBJECT_CONTENT_VERSION, Constants.CONTENT_VERSION_FIELD_CONTENT_DOCUMENT_ID));
        List<ContentDocument> contentDocuments = ContentDocumentSelector.getContentDocumentsByIds(contentDocumentIds);
		DatabaseUtils.deleteRecords(contentDocuments);
    }

	public void finish(Database.BatchableContext bc){
        Boolean isBackupFiles = false;
        if (this.batchParams.deleteFilePrefixes.contains(Constants.LITERAL_PERCENT + Constants.FILE_PREFIX_BACKUP + Constants.LITERAL_PERCENT)) {
            isBackupFiles = true;
        }
		DeleteDataCleanFileBatch.sendMail(this.batchParams.dataSetName, this.batchParams.parentName, this.batchParams.ids2Name.values(), isBackupFiles);
    }
    
    // Other Helper Methods
    @SuppressWarnings('PMD.ExcessiveParameterList,PMD.CognitiveComplexity')
    public static void sendMail(String dataSetName, String parentName, List<String> dcConfigNames, Boolean isBackupFiles){
        String body = '';
        if (dataSetName == Constants.DATA_SET_DATA_CLEAN_FILES) {
            if (isBackupFiles) {
                body += 'The following backup report files under ';
            } else {
                body += 'The following success & error report files under ';
            }
            body += Constants.OBJECT_LABEL_SINGULAR_DC_RESULTS + Constants.LITERAL_SPACE + Constants.HTML_TAG_BOLD_OPEN + parentName + Constants.HTML_TAG_BOLD_CLOSE;
            body += ' were successfully deleted: ';
        } else if (dataSetName == Constants.DATA_SET_DATA_CLEAN_RESULTS){
            if (isBackupFiles) {
                body += 'The backup report files associated with following Results for ';
            } else {
                body += 'The success & error report files associated with following Results for ';
            }
            body += Constants.OBJECT_LABEL_SINGULAR_DC_CONFIGURATION + Constants.LITERAL_SPACE + Constants.HTML_TAG_BOLD_OPEN + parentName + Constants.HTML_TAG_BOLD_CLOSE;
            body += ' were successfully deleted: ';
        } else {
            if (isBackupFiles) {
                body += 'The backup report files associated with following ';
            } else {
                body += 'The success & error report files associated with following ';
            }
            body += Constants.OBJECT_LABEL_PLURAL_DC_CONFIGURATION;
            body += ' were successfully deleted: ';
        }

        EmailUtils.EmailParameters emailParams = new EmailUtils.EmailParameters();
        emailParams.subject = Constants.DATA_CLEAN_EMAIL_SUBJECT_FILES_CLEANUP;
        emailParams.htmlBody = body;
        emailParams.htmlBody += Constants.HTML_TAG_BREAK_LINE;
        emailParams.htmlBody += EmailUtils.getHTMLUnorderedList(dcConfigNames);
        EmailUtils.sendEmail(emailParams);
    }

    public static List<Id> getIdsToForQuery(Set<Id> ids, String dataSetName){
        if (dataSetName == Constants.DATA_SET_DATA_CLEAN_CONFIGURATIONS) {
            List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getDCResultsByDcConfigIds(ids);
            return new List<Id>(Utils.extractIds(dcResults));
        } else {
            return new List<Id>(ids);
        }
    }

    public with sharing class BatchParameters{
        @AuraEnabled
        public String parentName {get; set;}

        @AuraEnabled
        public Map<Id, String> ids2Name {get; set;}

        @AuraEnabled
        public String dataSetName {get; set;}

        @AuraEnabled
        public List<String> deleteFilePrefixes {get; set;}
    }
}