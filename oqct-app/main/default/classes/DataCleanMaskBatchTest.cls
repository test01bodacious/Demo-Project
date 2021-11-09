/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-22
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-05   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DataCleanMaskBatchTest {

    @TestSetup
    private static void setupData(){
        // Insert Standard Salesforce Objects
        List<Account> accounts = DataFactory.initAccounts();
        DataFactory.initContactsForAccounts(accounts);
        DataFactory.initOpportunitiesForAccounts(accounts);
        // DataFactory.initCasesForAccounts(accounts);
        DataFactory.initAttachmentsForAccounts(accounts);

        // Insert Custom Data Clean App Objects
        DataFactory.initDataCleanAppConfigurations();
        DataFactory.initDcDataTypes();
        OQCT_DaCl__DC_Configuration__c dcConfig = DataFactory.initDcConfiguration();
        List<OQCT_DaCl__Related_Object__c> relatedObjects = DataFactory.initRelatedObjectsFromDcConfig(dcConfig);
        DataFactory.initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(dcConfig, relatedObjects);
        DataFactory.initDataCleansFromDcConfig(dcConfig.Id);
    }

    @IsTest
    private static void maskBatchTestSuccess(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_MASK;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {
            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertNotEquals(maskedAccount.Name, oldAccount.Name, 'Account Name is not masked');
            System.assertNotEquals(maskedAccount.Phone, oldAccount.Phone, 'Account Phone is not masked');
            System.assertNotEquals(maskedAccount.Industry, oldAccount.Industry, 'Account Industry is not masked');
            System.assertNotEquals(maskedAccount.Rating, oldAccount.Rating, 'Account Rating is not masked');
            System.assertNotEquals(maskedAccount.NumberOfEmployees, oldAccount.NumberOfEmployees, 'Account Employees is not masked');
            System.assertNotEquals(maskedAccount.Website, oldAccount.Website, 'Account Website is not masked');
            System.assertEquals(null, maskedAccount.Description, 'Account Description is not emptied');

            for (Integer j = 0;  j < maskedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact maskedContact = maskedAccount.contacts[j];

                System.assertNotEquals(oldContact.FirstName, maskedContact.FirstName, 'Contact First Name is masked');
                System.assertNotEquals(oldContact.LastName, maskedContact.LastName, 'Contact Last Name is masked');
                System.assertNotEquals(oldContact.Email, maskedContact.Email, 'Contact Email is masked');
                System.assertNotEquals(oldContact.Phone, maskedContact.Phone, 'Contact Phone is masked');
                System.assertEquals(null, maskedContact.Description, 'Contact Description is emptied');
            }

            for (Integer k = 0;  k < maskedaccount.opportunities.size(); k++) {
                Opportunity oldOpportunity = oldAccount.opportunities[k];
                Opportunity maskedOpportunity = maskedaccount.opportunities[k];

                System.assertNotEquals(oldOpportunity.Name, maskedOpportunity.Name, 'Opportunity Name is masked');
                System.assertNotEquals(oldOpportunity.StageName, maskedOpportunity.StageName, 'Opportunity Stage is masked');
                System.assertNotEquals(oldOpportunity.CloseDate, maskedOpportunity.CloseDate, 'Opportunity Close Date is masked');
                System.assertNotEquals(oldOpportunity.Amount, maskedOpportunity.Amount, 'Opportunity Amount is masked');
                System.assertNotEquals(oldOpportunity.Probability, maskedOpportunity.Probability, 'Opportunity Probability is masked');
                System.assertEquals(null, maskedOpportunity.Description, 'Opportunity Description is emptied');
            }

            System.assertEquals(0, maskedAccount.Attachments.size(), 'Attachments were not deleted');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for parent count not correct');
        System.assertEquals(3, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for child count not correct');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Status not Success');
        System.assertEquals(true, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job Not completed');
        System.assertEquals(14, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(4, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Success');
        System.assertEquals(10, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    private static void maskBatchTestInvalidMasterId(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        List<Account> accounts = AccountSelector.getAllAccounts();

        for (Account account : accounts) {
            account.AccountNumber = 'CHANGED';
        }

        DatabaseUtils.updateRecords(accounts);

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_MASK;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertEquals(maskedAccount.Name, oldAccount.Name, 'Account Name is masked');
            System.assertEquals(maskedAccount.Phone, oldAccount.Phone, 'Account Phone is masked');
            System.assertEquals(maskedAccount.Industry, oldAccount.Industry, 'Account Industry is masked');
            System.assertEquals(maskedAccount.Rating, oldAccount.Rating, 'Account Rating is masked');
            System.assertEquals(maskedAccount.NumberOfEmployees, oldAccount.NumberOfEmployees, 'Account Employees is masked');
            System.assertEquals(maskedAccount.Website, oldAccount.Website, 'Account Website is masked');
            System.assertNotEquals(null, maskedAccount.Description, 'Account Description is emptied');

            for (Integer j = 0;  j < maskedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact maskedContact = maskedAccount.contacts[j];

                System.assertEquals(oldContact.FirstName, maskedContact.FirstName, 'Contact First Name is masked');
                System.assertEquals(oldContact.LastName, maskedContact.LastName, 'Contact Last Name is masked');
                System.assertEquals(oldContact.Email, maskedContact.Email, 'Contact Email is masked');
                System.assertEquals(oldContact.Phone, maskedContact.Phone, 'Contact Phone is masked');
                System.assertNotEquals(null, maskedContact.Description, 'Contact Description is emptied');
            }

            for (Integer k = 0;  k < maskedaccount.opportunities.size(); k++) {
                Opportunity oldOpportunity = oldAccount.opportunities[k];
                Opportunity maskedOpportunity = maskedaccount.opportunities[k];

                System.assertEquals(maskedOpportunity.Name, oldOpportunity.Name, 'Opportunity Name is masked');
                System.assertEquals(maskedOpportunity.StageName, oldOpportunity.StageName, 'Opportunity Stage is masked');
                System.assertEquals(maskedOpportunity.CloseDate, oldOpportunity.CloseDate, 'Opportunity Close Date is masked');
                System.assertEquals(maskedOpportunity.Amount, oldOpportunity.Amount, 'Opportunity Amount is masked');
                System.assertEquals(maskedOpportunity.Probability, oldOpportunity.Probability, 'Opportunity Probability is masked');
                System.assertNotEquals(null, maskedOpportunity.Description, 'Opportunity Description is emptied');
            }

            System.assertNotEquals(0, maskedAccount.Attachments.size(), 'Attachments were deleted');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c, 'Backup File for parent were found');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c, 'Backup File for child(s) were found');
        System.assertEquals(Constants.DC_STATUS_FAILED, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Result not Failed');
        System.assertEquals(true, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'All Job is not completed');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(2, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_FAILED, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Failed');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Pending');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    private static void maskBatchTestNoChildRecords(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        DatabaseUtils.deleteRecords(ContactSelector.getAllContacts());
        DatabaseUtils.deleteRecords(OpportunitySelector.getAllOpportunities());
        DatabaseUtils.deleteRecords(AttachmentSelector.getAllAttachments());

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_MASK;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertNotEquals(maskedAccount.Name, oldAccount.Name, 'Account Name is not masked');
            System.assertNotEquals(maskedAccount.Phone, oldAccount.Phone, 'Account Phone is not masked');
            System.assertNotEquals(maskedAccount.Industry, oldAccount.Industry, 'Account Industry is not masked');
            System.assertNotEquals(maskedAccount.Rating, oldAccount.Rating, 'Account Rating is not masked');
            System.assertNotEquals(maskedAccount.NumberOfEmployees, oldAccount.NumberOfEmployees, 'Account Employees is not masked');
            System.assertNotEquals(maskedAccount.Website, oldAccount.Website, 'Account Website is not masked');
            System.assertEquals(null, maskedAccount.Description, 'Account Description is not emptied');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for parent count not correct');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c, 'Backup File for child(s) were found');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Result not Success');
        System.assertEquals(true, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'All Job is not completed');
        System.assertEquals(2, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Success');
        System.assertEquals(2, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    private static void maskBatchTestNoChildConfig(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        DatabaseUtils.deleteRecords(RecordTypeAndFieldSelector.getRecordTypeAndFieldForChildByDcConfigId(dcConfigs[0].Id));
        DatabaseUtils.deleteRecords(RelatedObjectSelector.getAllRelatedObjects());
        DatabaseUtils.deleteRecords(DCRelatedResultSelector.getAllDcRelatedResults());
        DatabaseUtils.deleteRecords(DataCleanRelatedResultSelector.getAllDataCleanRelatedResults());

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_MASK;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertNotEquals(maskedAccount.Name, oldAccount.Name, 'Account Name is not masked');
            System.assertNotEquals(maskedAccount.Phone, oldAccount.Phone, 'Account Phone is not masked');
            System.assertNotEquals(maskedAccount.Industry, oldAccount.Industry, 'Account Industry is not masked');
            System.assertNotEquals(maskedAccount.Rating, oldAccount.Rating, 'Account Rating is not masked');
            System.assertNotEquals(maskedAccount.NumberOfEmployees, oldAccount.NumberOfEmployees, 'Account Employees is not masked');
            System.assertNotEquals(maskedAccount.Website, oldAccount.Website, 'Account Website is not masked');
            System.assertEquals(null, maskedAccount.Description, 'Account Description is not emptied');

            for (Integer j = 0;  j < maskedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact maskedContact = maskedAccount.contacts[j];

                System.assertEquals(oldContact.FirstName, maskedContact.FirstName, 'Contact First Name is masked');
                System.assertEquals(oldContact.LastName, maskedContact.LastName, 'Contact Last Name is masked');
                System.assertEquals(oldContact.Email, maskedContact.Email, 'Contact Email is masked');
                System.assertEquals(oldContact.Phone, maskedContact.Phone, 'Contact Phone is masked');
                System.assertNotEquals(null, maskedContact.Description, 'Contact Description is emptied');
            }

            for (Integer k = 0;  k < maskedaccount.opportunities.size(); k++) {
                Opportunity oldOpportunity = oldAccount.opportunities[k];
                Opportunity maskedOpportunity = maskedaccount.opportunities[k];

                System.assertEquals(maskedOpportunity.Name, oldOpportunity.Name, 'Opportunity Name is masked');
                System.assertEquals(maskedOpportunity.StageName, oldOpportunity.StageName, 'Opportunity Stage is masked');
                System.assertEquals(maskedOpportunity.CloseDate, oldOpportunity.CloseDate, 'Opportunity Close Date is masked');
                System.assertEquals(maskedOpportunity.Amount, oldOpportunity.Amount, 'Opportunity Amount is masked');
                System.assertEquals(maskedOpportunity.Probability, oldOpportunity.Probability, 'Opportunity Probability is masked');
                System.assertNotEquals(null, maskedOpportunity.Description, 'Opportunity Description is emptied');
            }

            System.assertNotEquals(0, maskedAccount.Attachments.size(), 'Attachments were deleted');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for parent count not correct');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c, 'Backup File for child(s) were found');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Result not Success');
        System.assertEquals(true, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'All Job is not completed');
        System.assertEquals(2, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Success');
        System.assertEquals(2, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    private static void maskBatchTestFailure(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        OQCT_DaCl__DC_Data_Type__c dcDataTypeText = DCDataTypeSelector.getDCDataTypeText();
        dcDataTypeText.OQCT_DaCl__Custom_Length__c = 255;
        dcDataTypeText.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        DatabaseUtils.updateRecords(dcDataTypeText);

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_MASK;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {
            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertNotEquals(maskedAccount.Name, oldAccount.Name, 'Account Name is not masked');
            System.assertNotEquals(maskedAccount.Phone, oldAccount.Phone, 'Account Phone is not masked');
            System.assertNotEquals(maskedAccount.Industry, oldAccount.Industry, 'Account Industry is not masked');
            System.assertNotEquals(maskedAccount.Rating, oldAccount.Rating, 'Account Rating is not masked');
            System.assertNotEquals(maskedAccount.NumberOfEmployees, oldAccount.NumberOfEmployees, 'Account Employees is not masked');
            System.assertNotEquals(maskedAccount.Website, oldAccount.Website, 'Account Website is not masked');
            System.assertEquals(null, maskedAccount.Description, 'Account Description is not emptied');

            for (Integer j = 0;  j < maskedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact maskedContact = maskedAccount.contacts[j];

                System.assertEquals(oldContact.FirstName, maskedContact.FirstName, 'Contact First Name is masked');
                System.assertEquals(oldContact.LastName, maskedContact.LastName, 'Contact Last Name is masked');
                System.assertEquals(oldContact.Email, maskedContact.Email, 'Contact Email is masked');
                System.assertEquals(oldContact.Phone, maskedContact.Phone, 'Contact Phone is masked');
                System.assertNotEquals(null, maskedContact.Description, 'Contact Description is emptied');
            }

            for (Integer k = 0;  k < maskedaccount.opportunities.size(); k++) {
                Opportunity oldOpportunity = oldAccount.opportunities[k];
                Opportunity maskedOpportunity = maskedaccount.opportunities[k];

                System.assertEquals(oldOpportunity.Name, maskedOpportunity.Name, 'Opportunity Name is masked');
                System.assertEquals(oldOpportunity.StageName, maskedOpportunity.StageName, 'Opportunity Stage is masked');
                System.assertEquals(oldOpportunity.CloseDate, maskedOpportunity.CloseDate, 'Opportunity Close Date is masked');
                System.assertEquals(oldOpportunity.Amount, maskedOpportunity.Amount, 'Opportunity Amount is masked');
                System.assertEquals(oldOpportunity.Probability, maskedOpportunity.Probability, 'Opportunity Probability is masked');
                System.assertNotEquals(null, maskedOpportunity.Description, 'Opportunity Description is emptied');
            }

            System.assertEquals(0, maskedAccount.Attachments.size(), 'Attachments were not deleted');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(3, dcResults.size(), 'Result record count not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for parent count not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for child(s) count not correct');
        System.assertEquals(Constants.DC_STATUS_PARTIAL_SUCCESS, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Result not Partial Success');
        System.assertEquals(true, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'All Job is not completed');
        System.assertEquals(6, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(8, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(2, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PARTIAL_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Partial Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Pending');
        System.assertEquals(2, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    private static void maskBatchTestLargeNumberOfChildRecords(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        DataCleanMaskBatch.startLargeBatchForTest = true;

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_MASK;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertNotEquals(maskedAccount.Name, oldAccount.Name, 'Account Name is not masked');
            System.assertNotEquals(maskedAccount.Phone, oldAccount.Phone, 'Account Phone is not masked');
            System.assertNotEquals(maskedAccount.Industry, oldAccount.Industry, 'Account Industry is not masked');
            System.assertNotEquals(maskedAccount.Rating, oldAccount.Rating, 'Account Rating is not masked');
            System.assertNotEquals(maskedAccount.NumberOfEmployees, oldAccount.NumberOfEmployees, 'Account Employees is not masked');
            System.assertNotEquals(maskedAccount.Website, oldAccount.Website, 'Account Website is not masked');
            System.assertEquals(null, maskedAccount.Description, 'Account Description is not emptied');

            for (Integer j = 0;  j < maskedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact maskedContact = maskedAccount.contacts[j];

                System.assertEquals(oldContact.FirstName, maskedContact.FirstName, 'Contact First Name is masked');
                System.assertEquals(oldContact.LastName, maskedContact.LastName, 'Contact Last Name is masked');
                System.assertEquals(oldContact.Email, maskedContact.Email, 'Contact Email is masked');
                System.assertEquals(oldContact.Phone, maskedContact.Phone, 'Contact Phone is masked');
                System.assertNotEquals(null, maskedContact.Description, 'Contact Description is emptied');
            }

            for (Integer k = 0;  k < maskedaccount.opportunities.size(); k++) {
                Opportunity oldOpportunity = oldAccount.opportunities[k];
                Opportunity maskedOpportunity = maskedaccount.opportunities[k];

                System.assertEquals(maskedOpportunity.Name, oldOpportunity.Name, 'Opportunity Name is masked');
                System.assertEquals(maskedOpportunity.StageName, oldOpportunity.StageName, 'Opportunity Stage is masked');
                System.assertEquals(maskedOpportunity.CloseDate, oldOpportunity.CloseDate, 'Opportunity Close Date is masked');
                System.assertEquals(maskedOpportunity.Amount, oldOpportunity.Amount, 'Opportunity Amount is masked');
                System.assertEquals(maskedOpportunity.Probability, oldOpportunity.Probability, 'Opportunity Probability is masked');
                System.assertNotEquals(null, maskedOpportunity.Description, 'Opportunity Description is emptied');
            }

            System.assertNotEquals(0, maskedAccount.Attachments.size(), 'Attachments were deleted');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(1, dcResults.size(), 'Result record count not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for parent count not correct');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c, 'Backup File for child not null');
        System.assertEquals(Constants.DC_STATUS_PENDING, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Status not Pending');
        System.assertEquals(false, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job Not completed');
        System.assertEquals(2, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Pending');
        System.assertEquals(2, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

}