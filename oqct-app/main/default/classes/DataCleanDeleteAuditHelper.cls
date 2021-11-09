/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-02-16
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-16   Krrish Joy   Initial Version
**/
public with sharing class DataCleanDeleteAuditHelper {

    private static final Schema.SObjectType PARENT_SOBJECT_TYPE = OQCT_DaCl__DC_Result__c.getSObjectType();

    // Data Clean Delete Audit Default Note on File Removal
    public final static String DATA_CLEAN_DELETE_AUDIT_FILE_REMOVAL_NOTE = 'The file was removed from the record';

    public static void trackDeletion(List<SObject> recordsDeleted){
        DataCleanDeleteAuditHelper.trackDeletion(recordsDeleted, false);
    }
    
    public static void trackDeletion(List<SObject> recordsDeleted, Boolean isFileRemovedFromRecord){

        List<OQCT_DaCl__Data_Clean_Delete_Audit__c> deleteAudits = new List<OQCT_DaCl__Data_Clean_Delete_Audit__c>();

        for (SObject recordDeleted : recordsDeleted) {

            OQCT_DaCl__Data_Clean_Delete_Audit__c deleteAudit = new OQCT_DaCl__Data_Clean_Delete_Audit__c();
            deleteAudit.OQCT_DaCl__Deleted_By__c = Utils.getUserId();
            deleteAudit.OQCT_DaCl__Deletion_DateTime__c = DateUtils.getNow();

            switch on recordDeleted {
                when OQCT_DaCl__DC_Configuration__c dcConfig {
                    deleteAudit.OQCT_DaCl__Record_Type__c = Constants.DC_DELETE_AUDIT_RECORD_TYPE_DC_CONFIGURATION;
                    deleteAudit.OQCT_DaCl__Record_Name__c = dcConfig.Name;
                }
                when OQCT_DaCl__DC_Result__c dcResult {
                    deleteAudit.OQCT_DaCl__Record_Type__c = Constants.DC_DELETE_AUDIT_RECORD_TYPE_DC_RESULT;
                    deleteAudit.OQCT_DaCl__Record_Name__c = dcResult.Name;
                    deleteAudit.OQCT_DaCl__DC_Configuration__c = dcResult.OQCT_DaCl__DC_Configuration__c;
                }
                when ContentVersion contentVersion {
                    deleteAudit.OQCT_DaCl__Record_Type__c = Constants.DC_DELETE_AUDIT_RECORD_TYPE_DC_FILE;
                    deleteAudit.OQCT_DaCl__Record_Name__c = contentVersion.title;
                    deleteAudit.OQCT_DaCl__DC_Result__c = contentVersion.FirstPublishLocationId;
                    if (isFileRemovedFromRecord) {
                        deleteAudit.OQCT_DaCl__Note__c = DataCleanDeleteAuditHelper.DATA_CLEAN_DELETE_AUDIT_FILE_REMOVAL_NOTE;
                    }
                }
                when else {
                    continue;
                }
            }

            deleteAudits.add(deleteAudit);
        }
        DatabaseUtils.insertRecords(deleteAudits);
    }

}