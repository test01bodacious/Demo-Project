/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-22   Krrish Joy   Initial Version
**/
public with sharing class DeleteDataCleanConfigurationBatch implements Database.Batchable<SObject>{

    private Map<Id, String> dcConfigId2Name;
    private Integer batchCount; // 1 = DataClean, 2 = DC-Configuration

    // Parameterized Constructors
    public DeleteDataCleanConfigurationBatch(Map<Id, String> dcConfigId2Name){
        this.dcConfigId2Name = dcConfigId2Name;
        this.batchCount = 1;
    }

    public DeleteDataCleanConfigurationBatch(Map<Id, String> dcConfigId2Name, Integer batchCount){
        this.dcConfigId2Name = dcConfigId2Name;
        this.batchCount = batchCount;
    }

    // Batch Methods
	public Database.QueryLocator start(Database.BatchableContext bc){
        List<String> stringList = new List<Id>(this.dcConfigId2Name.keySet());
		if (this.batchCount == 1) {
            return Database.getQueryLocator(DataCleanSelector.getDataCleansByDcConfigIdsDeleteString(stringList));
        } else {
            return Database.getQueryLocator(DCConfigurationSelector.getDcConfigWithoutResultsByIdsDeleteString(stringList));
        }
    }
    
	public void execute(Database.BatchableContext bc, List<SObject> scope){
		DatabaseUtils.deleteRecords(scope);
    }

	public void finish(Database.BatchableContext bc){
		if (this.batchCount == 1) {
            DeleteDataCleanConfigurationBatch deleteDcConfigBatch = new DeleteDataCleanConfigurationBatch(this.dcConfigId2Name, 2);
            Id deleteDcConfigBatchId = Database.executeBatch(deleteDcConfigBatch);
        } else {
            DeleteDataCleanConfigurationBatch.sendMail(this.dcConfigId2Name.values());
        }
    }
    
    // Other Helper Methods
    public static void sendMail(List<String> dcConfigNames){
        EmailUtils.EmailParameters emailParams = new EmailUtils.EmailParameters();
        emailParams.subject = Constants.DATA_CLEAN_EMAIL_SUBJECT_DC_CONFIGURATION_DELETE;
        emailParams.htmlBody = 'The following DC-Configurations and their related records were successfully deleted: ';
        emailParams.htmlBody += Constants.HTML_TAG_BREAK_LINE;
        emailParams.htmlBody += EmailUtils.getHTMLUnorderedList(dcConfigNames);
        EmailUtils.sendEmail(emailParams);
    }
}