/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-20
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-09   Krrish Joy   Initial Version
**/
@IsTest
@SuppressWarnings('PMD.CognitiveComplexity')
private with sharing class DataCleanRollbackBatchTest {

    private static List<String> backupFileNames;
    
    @TestSetup
    static void setupData(){
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

        dcConfig = DCConfigurationSelector.getDCConfigurationById(dcConfig.Id);

        List<OQCT_DaCl__Related_Object__c> relatedObjects = DataFactory.initRelatedObjectsFromDcConfig(dcConfig);
        DataFactory.initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(dcConfig, relatedObjects);
        DataFactory.initDataCleansFromDcConfig(dcConfig.Id);

        DataCleanRollbackController.updateDcConfigAndCreateResult(dcConfig, Constants.PROCESS_ROLLBACK);
    }

    @IsTest
    private static void maskBatchTestSuccess(){

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        DataFactory.insertBackups(dcConfigs[0], dcResult, false, false, false);

        DataFactory.maskOrDeleteSobjectRecords(dcConfigs[0], false, false, false);

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ROLLBACK;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> rollbackedAccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < rollbackedAccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account rollbackedAccount = rollbackedAccounts[i];

            System.assertEquals(oldAccount.Name, rollbackedAccount.Name, 'Account Name is still masked');
            System.assertEquals(oldAccount.Phone, rollbackedAccount.Phone, 'Account Phone is still masked');
            System.assertEquals(oldAccount.Industry, rollbackedAccount.Industry, 'Account Industry is still masked');
            System.assertEquals(oldAccount.Rating, rollbackedAccount.Rating, 'Account Rating is still masked');
            System.assertEquals(oldAccount.NumberOfEmployees, rollbackedAccount.NumberOfEmployees, 'Account Employees is still masked');
            System.assertEquals(oldAccount.Website, rollbackedAccount.Website, 'Account Website is still masked');
            System.assertNotEquals(null, rollbackedAccount.Description, 'Account Description is still emptied');

            for (Integer j = 0;  j < rollbackedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact rollbackedContact = rollbackedAccount.contacts[j];

                System.assertEquals(oldContact.FirstName, rollbackedContact.FirstName, 'Contact First Name is still masked');
                System.assertEquals(oldContact.LastName, rollbackedContact.LastName, 'Contact Last Name is still masked');
                System.assertEquals(oldContact.Email, rollbackedContact.Email, 'Contact Email is still masked');
                System.assertEquals(oldContact.Phone, rollbackedContact.Phone, 'Contact Phone is still masked');
                System.assertNotEquals(null, rollbackedContact.Description, 'Contact Description is still emptied');
            }

            for (Integer k = 0;  k < rollbackedAccount.opportunities.size(); k++) {
                Opportunity oldOpportunity = oldAccount.opportunities[k];
                Opportunity rollbackedOpportunity = rollbackedAccount.opportunities[k];

                System.assertEquals(oldOpportunity.Name, rollbackedOpportunity.Name, 'Opportunity Name is still masked');
                System.assertEquals(oldOpportunity.StageName, rollbackedOpportunity.StageName, 'Opportunity Stage is still masked');
                System.assertEquals(oldOpportunity.CloseDate, rollbackedOpportunity.CloseDate, 'Opportunity Close Date is still masked');
                System.assertEquals(oldOpportunity.Amount, rollbackedOpportunity.Amount, 'Opportunity Amount is still masked');
                System.assertEquals(oldOpportunity.Probability, rollbackedOpportunity.Probability, 'Opportunity Probability is still masked');
                System.assertNotEquals(null, rollbackedOpportunity.Description, 'Opportunity Description is still emptied');
            }

            System.assertNotEquals(0, rollbackedAccount.Attachments.size(), 'Attachments were not restored');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcResults[1].OQCT_DaCl__Overall_Result__c, 'Overall Status not Success');
        System.assertEquals(true, dcResults[1].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job Not completed');
        System.assertEquals(14, dcResults[1].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[1].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Rollback_Completed__c, 'Rollback not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for Data Clean is not Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for DC-Config is not Success');
        System.assertEquals(14, dcConfigs[0].OQCT_DaCl__Overall_Success_Rollback__c, 'Overall Success (Rollback) for DC-Config is not correct');
    }

    @IsTest
    private static void maskBatchTestFailure(){

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        DataFactory.insertBackups(dcConfigs[0], dcResult, true, false, false);

        DataFactory.maskOrDeleteSobjectRecords(dcConfigs[0], false, false, false);

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ROLLBACK;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> rollbackedAccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < rollbackedAccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account rollbackedAccount = rollbackedAccounts[i];

            System.assertEquals(oldAccount.Name, rollbackedAccount.Name, 'Account Name is still masked');
            System.assertEquals(oldAccount.Phone, rollbackedAccount.Phone, 'Account Phone is still masked');
            System.assertEquals(oldAccount.Industry, rollbackedAccount.Industry, 'Account Industry is still masked');
            System.assertEquals(oldAccount.Rating, rollbackedAccount.Rating, 'Account Rating is still masked');
            System.assertEquals(oldAccount.NumberOfEmployees, rollbackedAccount.NumberOfEmployees, 'Account Employees is still masked');
            System.assertEquals(oldAccount.Website, rollbackedAccount.Website, 'Account Website is still masked');
            System.assertNotEquals(null, rollbackedAccount.Description, 'Account Description is still emptied');

            for (Integer j = 0;  j < rollbackedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact rollbackedContact = rollbackedAccount.contacts[j];

                System.assertNotEquals(oldContact.FirstName, rollbackedContact.FirstName, 'Contact First Name is rollbacked');
                System.assertNotEquals(oldContact.LastName, rollbackedContact.LastName, 'Contact Last Name is rollbacked');
                System.assertNotEquals(oldContact.Email, rollbackedContact.Email, 'Contact Email is rollbacked');
                System.assertNotEquals(oldContact.Phone, rollbackedContact.Phone, 'Contact Phone is rollbacked');
                System.assertEquals(null, rollbackedContact.Description, 'Contact Description is rollbacked');
            }

            for (Integer k = 0;  k < rollbackedAccount.opportunities.size(); k++) {
                Opportunity oldOpportunity = oldAccount.opportunities[k];
                Opportunity rollbackedOpportunity = rollbackedAccount.opportunities[k];

                System.assertEquals(oldOpportunity.Name, rollbackedOpportunity.Name, 'Opportunity Name is still masked');
                System.assertEquals(oldOpportunity.StageName, rollbackedOpportunity.StageName, 'Opportunity Stage is still masked');
                System.assertEquals(oldOpportunity.CloseDate, rollbackedOpportunity.CloseDate, 'Opportunity Close Date is still masked');
                System.assertEquals(oldOpportunity.Amount, rollbackedOpportunity.Amount, 'Opportunity Amount is still masked');
                System.assertEquals(oldOpportunity.Probability, rollbackedOpportunity.Probability, 'Opportunity Probability is still masked');
                System.assertNotEquals(null, rollbackedOpportunity.Description, 'Opportunity Description is still emptied');
            }

            System.assertNotEquals(0, rollbackedAccount.Attachments.size(), 'Attachments were not restored');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();

        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(Constants.DC_STATUS_PARTIAL_SUCCESS, dcResults[1].OQCT_DaCl__Overall_Result__c, 'Overall Status not Partial Success');
        System.assertEquals(true, dcResults[1].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job Not completed');
        System.assertEquals(10, dcResults[1].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(4, dcResults[1].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();

        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Rollback_Completed__c, 'Rollback not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PARTIAL_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for Data Clean is not Partial Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        System.assertEquals(Constants.DC_STATUS_PARTIAL_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for DC-Config is not Partial Success');
        System.assertEquals(10, dcConfigs[0].OQCT_DaCl__Overall_Success_Rollback__c, 'Overall Success (Rollback) for DC-Config is not correct');
    }

    @IsTest
    private static void maskBatchTestRecycleBinEmpty(){

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        DataFactory.insertBackups(dcConfigs[0], dcResult, false, false, false);

        DataFactory.maskOrDeleteSobjectRecords(dcConfigs[0], true, false, false);

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ROLLBACK;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> rollbackedAccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < rollbackedAccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account rollbackedAccount = rollbackedAccounts[i];

            System.assertEquals(oldAccount.Name, rollbackedAccount.Name, 'Account Name is still masked');
            System.assertEquals(oldAccount.Phone, rollbackedAccount.Phone, 'Account Phone is still masked');
            System.assertEquals(oldAccount.Industry, rollbackedAccount.Industry, 'Account Industry is still masked');
            System.assertEquals(oldAccount.Rating, rollbackedAccount.Rating, 'Account Rating is still masked');
            System.assertEquals(oldAccount.NumberOfEmployees, rollbackedAccount.NumberOfEmployees, 'Account Employees is still masked');
            System.assertEquals(oldAccount.Website, rollbackedAccount.Website, 'Account Website is still masked');
            System.assertNotEquals(null, rollbackedAccount.Description, 'Account Description is still emptied');

            for (Integer j = 0;  j < rollbackedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact rollbackedContact = rollbackedAccount.contacts[j];

                System.assertEquals(oldContact.FirstName, rollbackedContact.FirstName, 'Contact First Name is still masked');
                System.assertEquals(oldContact.LastName, rollbackedContact.LastName, 'Contact Last Name is still masked');
                System.assertEquals(oldContact.Email, rollbackedContact.Email, 'Contact Email is still masked');
                System.assertEquals(oldContact.Phone, rollbackedContact.Phone, 'Contact Phone is still masked');
                System.assertNotEquals(null, rollbackedContact.Description, 'Contact Description is still emptied');
            }

            for (Integer k = 0;  k < rollbackedAccount.opportunities.size(); k++) {
                Opportunity oldOpportunity = oldAccount.opportunities[k];
                Opportunity rollbackedOpportunity = rollbackedAccount.opportunities[k];

                System.assertEquals(oldOpportunity.Name, rollbackedOpportunity.Name, 'Opportunity Name is still masked');
                System.assertEquals(oldOpportunity.StageName, rollbackedOpportunity.StageName, 'Opportunity Stage is still masked');
                System.assertEquals(oldOpportunity.CloseDate, rollbackedOpportunity.CloseDate, 'Opportunity Close Date is still masked');
                System.assertEquals(oldOpportunity.Amount, rollbackedOpportunity.Amount, 'Opportunity Amount is still masked');
                System.assertEquals(oldOpportunity.Probability, rollbackedOpportunity.Probability, 'Opportunity Probability is still masked');
                System.assertNotEquals(null, rollbackedOpportunity.Description, 'Opportunity Description is still emptied');
            }

            System.assertEquals(0, rollbackedAccount.Attachments.size(), 'Attachments were restored');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();

        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(Constants.DC_STATUS_PARTIAL_SUCCESS, dcResults[1].OQCT_DaCl__Overall_Result__c, 'Overall Status not Partial Success');
        System.assertEquals(true, dcResults[1].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job Not completed');
        System.assertEquals(10, dcResults[1].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(4, dcResults[1].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();

        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Rollback_Completed__c, 'Rollback not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PARTIAL_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for Data Clean is not Partial Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        System.assertEquals(Constants.DC_STATUS_PARTIAL_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for DC-Config is not Partial Success');
        System.assertEquals(10, dcConfigs[0].OQCT_DaCl__Overall_Success_Rollback__c, 'Overall Success (Rollback) for DC-Config is not correct');
    }

    @IsTest
    private static void maskBatchTestNoChild(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        DatabaseUtils.deleteRecords(ContactSelector.getAllContacts());
        DatabaseUtils.deleteRecords(OpportunitySelector.getAllOpportunities());
        DatabaseUtils.deleteRecords(AttachmentSelector.getAllAttachments());

        DatabaseUtils.deleteRecords(RecordTypeAndFieldSelector.getRecordTypeAndFieldForChildByDcConfigId(dcConfigs[0].Id));
        DatabaseUtils.deleteRecords(RelatedObjectSelector.getAllRelatedObjects());
        DatabaseUtils.deleteRecords(DCRelatedResultSelector.getAllDcRelatedResults());
        DatabaseUtils.deleteRecords(DataCleanRelatedResultSelector.getAllDataCleanRelatedResults());

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();
        
        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        DataFactory.insertBackups(dcConfigs[0], dcResult, false, true, false);

        DataFactory.maskOrDeleteSobjectRecords(dcConfigs[0], false, true, false);

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ROLLBACK;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> rollbackedAccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < rollbackedAccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account rollbackedAccount = rollbackedAccounts[i];

            System.assertEquals(oldAccount.Name, rollbackedAccount.Name, 'Account Name is still masked');
            System.assertEquals(oldAccount.Phone, rollbackedAccount.Phone, 'Account Phone is still masked');
            System.assertEquals(oldAccount.Industry, rollbackedAccount.Industry, 'Account Industry is still masked');
            System.assertEquals(oldAccount.Rating, rollbackedAccount.Rating, 'Account Rating is still masked');
            System.assertEquals(oldAccount.NumberOfEmployees, rollbackedAccount.NumberOfEmployees, 'Account Employees is still masked');
            System.assertEquals(oldAccount.Website, rollbackedAccount.Website, 'Account Website is still masked');
            System.assertNotEquals(null, rollbackedAccount.Description, 'Account Description is still emptied');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();

        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcResults[1].OQCT_DaCl__Overall_Result__c, 'Overall Status not Success');
        System.assertEquals(true, dcResults[1].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job Not completed');
        System.assertEquals(2, dcResults[1].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[1].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();

        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Rollback_Completed__c, 'Rollback not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for Data Clean is not Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for DC-Config is not Success');
        System.assertEquals(2, dcConfigs[0].OQCT_DaCl__Overall_Success_Rollback__c, 'Overall Success (Rollback) for DC-Config is not correct');
    }

    @IsTest
    private static void maskBatchTestNoParent(){

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        DataFactory.insertBackups(dcConfigs[0], dcResult, false, false, true);

        DataFactory.maskOrDeleteSobjectRecords(dcConfigs[0], false, false, true);

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ROLLBACK;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> rollbackedAccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < rollbackedAccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account rollbackedAccount = rollbackedAccounts[i];

            System.assertEquals(oldAccount.Name, rollbackedAccount.Name, 'Account Name is masked');
            System.assertEquals(oldAccount.Phone, rollbackedAccount.Phone, 'Account Phone is masked');
            System.assertEquals(oldAccount.Industry, rollbackedAccount.Industry, 'Account Industry is masked');
            System.assertEquals(oldAccount.Rating, rollbackedAccount.Rating, 'Account Rating is masked');
            System.assertEquals(oldAccount.NumberOfEmployees, rollbackedAccount.NumberOfEmployees, 'Account Employees is masked');
            System.assertEquals(oldAccount.Website, rollbackedAccount.Website, 'Account Website is masked');
            System.assertNotEquals(null, rollbackedAccount.Description, 'Account Description is empty');

            for (Integer j = 0;  j < rollbackedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact rollbackedContact = rollbackedAccount.contacts[j];

                System.assertEquals(oldContact.FirstName, rollbackedContact.FirstName, 'Contact First Name is still masked');
                System.assertEquals(oldContact.LastName, rollbackedContact.LastName, 'Contact Last Name is still masked');
                System.assertEquals(oldContact.Email, rollbackedContact.Email, 'Contact Email is still masked');
                System.assertEquals(oldContact.Phone, rollbackedContact.Phone, 'Contact Phone is still masked');
                System.assertNotEquals(null, rollbackedContact.Description, 'Contact Description is still emptied');
            }

            for (Integer k = 0;  k < rollbackedAccount.opportunities.size(); k++) {
                Opportunity oldOpportunity = oldAccount.opportunities[k];
                Opportunity rollbackedOpportunity = rollbackedAccount.opportunities[k];

                System.assertEquals(oldOpportunity.Name, rollbackedOpportunity.Name, 'Opportunity Name is still masked');
                System.assertEquals(oldOpportunity.StageName, rollbackedOpportunity.StageName, 'Opportunity Stage is still masked');
                System.assertEquals(oldOpportunity.CloseDate, rollbackedOpportunity.CloseDate, 'Opportunity Close Date is still masked');
                System.assertEquals(oldOpportunity.Amount, rollbackedOpportunity.Amount, 'Opportunity Amount is still masked');
                System.assertEquals(oldOpportunity.Probability, rollbackedOpportunity.Probability, 'Opportunity Probability is still masked');
                System.assertNotEquals(null, rollbackedOpportunity.Description, 'Opportunity Description is still emptied');
            }

            System.assertNotEquals(0, rollbackedAccount.Attachments.size(), 'Attachments were not restored');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();

        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcResults[1].OQCT_DaCl__Overall_Result__c, 'Overall Status not Success');
        System.assertEquals(true, dcResults[1].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job Not completed');
        System.assertEquals(12, dcResults[1].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[1].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();

        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Rollback_Completed__c, 'Rollback not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for DC-Config is not Pending');
        System.assertEquals(12, dcConfigs[0].OQCT_DaCl__Overall_Success_Rollback__c, 'Overall Success (Rollback) for DC-Config is not correct');
    }

    @IsTest
    private static void maskBatchTestSuccessFromResultId(){

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        DataFactory.insertBackups(dcConfigs[0], dcResult, false, false, false);

        DataFactory.maskOrDeleteSobjectRecords(dcConfigs[0], false, false, false);

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ROLLBACK;
        scheduleWrapper.resultIds = new List<Id>{dcResult.Id};
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> rollbackedAccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < rollbackedAccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account rollbackedAccount = rollbackedAccounts[i];

            System.assertEquals(oldAccount.Name, rollbackedAccount.Name, 'Account Name is still masked');
            System.assertEquals(oldAccount.Phone, rollbackedAccount.Phone, 'Account Phone is still masked');
            System.assertEquals(oldAccount.Industry, rollbackedAccount.Industry, 'Account Industry is still masked');
            System.assertEquals(oldAccount.Rating, rollbackedAccount.Rating, 'Account Rating is still masked');
            System.assertEquals(oldAccount.NumberOfEmployees, rollbackedAccount.NumberOfEmployees, 'Account Employees is still masked');
            System.assertEquals(oldAccount.Website, rollbackedAccount.Website, 'Account Website is still masked');
            System.assertNotEquals(null, rollbackedAccount.Description, 'Account Description is still emptied');

            for (Integer j = 0;  j < rollbackedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact rollbackedContact = rollbackedAccount.contacts[j];

                System.assertEquals(oldContact.FirstName, rollbackedContact.FirstName, 'Contact First Name is still masked');
                System.assertEquals(oldContact.LastName, rollbackedContact.LastName, 'Contact Last Name is still masked');
                System.assertEquals(oldContact.Email, rollbackedContact.Email, 'Contact Email is still masked');
                System.assertEquals(oldContact.Phone, rollbackedContact.Phone, 'Contact Phone is still masked');
                System.assertNotEquals(null, rollbackedContact.Description, 'Contact Description is still emptied');
            }

            for (Integer k = 0;  k < rollbackedAccount.opportunities.size(); k++) {
                Opportunity oldOpportunity = oldAccount.opportunities[k];
                Opportunity rollbackedOpportunity = rollbackedAccount.opportunities[k];

                System.assertEquals(oldOpportunity.Name, rollbackedOpportunity.Name, 'Opportunity Name is still masked');
                System.assertEquals(oldOpportunity.StageName, rollbackedOpportunity.StageName, 'Opportunity Stage is still masked');
                System.assertEquals(oldOpportunity.CloseDate, rollbackedOpportunity.CloseDate, 'Opportunity Close Date is still masked');
                System.assertEquals(oldOpportunity.Amount, rollbackedOpportunity.Amount, 'Opportunity Amount is still masked');
                System.assertEquals(oldOpportunity.Probability, rollbackedOpportunity.Probability, 'Opportunity Probability is still masked');
                System.assertNotEquals(null, rollbackedOpportunity.Description, 'Opportunity Description is still emptied');
            }

            System.assertNotEquals(0, rollbackedAccount.Attachments.size(), 'Attachments were not restored');
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcResults[1].OQCT_DaCl__Overall_Result__c, 'Overall Status not Success');
        System.assertEquals(true, dcResults[1].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job Not completed');
        System.assertEquals(14, dcResults[1].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[1].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Rollback_Completed__c, 'Rollback not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for Data Clean is not Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for DC-Config is not Success');
        System.assertEquals(14, dcConfigs[0].OQCT_DaCl__Overall_Success_Rollback__c, 'Overall Success (Rollback) for DC-Config is not correct');
    }

    @SuppressWarnings('PMD.CognitiveComplexity,PMD.NcssMethodCount')
    @IsTest
    private static void maskBatchTestSuccessFromDataCleanId(){

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        DataFactory.insertBackups(dcConfigs[0], dcResult, false, false, false);

        DataFactory.maskOrDeleteSobjectRecords(dcConfigs[0], false, false, false);

        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ROLLBACK;
        scheduleWrapper.dataCleanIds = new List<Id>{dataCleans[0].Id};
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> rollbackedAccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < rollbackedAccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account rollbackedAccount = rollbackedAccounts[i];

            if (i == 0) {
                System.assertEquals(oldAccount.Name, rollbackedAccount.Name, 'Account Name is still masked');
                System.assertEquals(oldAccount.Phone, rollbackedAccount.Phone, 'Account Phone is still masked');
                System.assertEquals(oldAccount.Industry, rollbackedAccount.Industry, 'Account Industry is still masked');
                System.assertEquals(oldAccount.Rating, rollbackedAccount.Rating, 'Account Rating is still masked');
                System.assertEquals(oldAccount.NumberOfEmployees, rollbackedAccount.NumberOfEmployees, 'Account Employees is still masked');
                System.assertEquals(oldAccount.Website, rollbackedAccount.Website, 'Account Website is still masked');
                System.assertNotEquals(null, rollbackedAccount.Description, 'Account Description is still emptied');
            } else {
                System.assertNotEquals(oldAccount.Name, rollbackedAccount.Name, 'Account Name is rollbacked');
                System.assertNotEquals(oldAccount.Phone, rollbackedAccount.Phone, 'Account Phone is rollbacked');
                System.assertNotEquals(oldAccount.Industry, rollbackedAccount.Industry, 'Account Industry is rollbacked');
                System.assertNotEquals(oldAccount.Rating, rollbackedAccount.Rating, 'Account Rating is rollbacked');
                System.assertNotEquals(oldAccount.NumberOfEmployees, rollbackedAccount.NumberOfEmployees, 'Account Employees is rollbacked');
                System.assertNotEquals(oldAccount.Website, rollbackedAccount.Website, 'Account Website is rollbacked');
                System.assertEquals(null, rollbackedAccount.Description, 'Account Description is rollbacked');
            }

            for (Integer j = 0;  j < rollbackedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact rollbackedContact = rollbackedAccount.contacts[j];

                if (i == 0) {
                    System.assertEquals(oldContact.FirstName, rollbackedContact.FirstName, 'Contact First Name is still masked');
                    System.assertEquals(oldContact.LastName, rollbackedContact.LastName, 'Contact Last Name is still masked');
                    System.assertEquals(oldContact.Email, rollbackedContact.Email, 'Contact Email is still masked');
                    System.assertEquals(oldContact.Phone, rollbackedContact.Phone, 'Contact Phone is still masked');
                    System.assertNotEquals(null, rollbackedContact.Description, 'Contact Description is still emptied');
                } else {
                    System.assertNotEquals(oldContact.FirstName, rollbackedContact.FirstName, 'Contact First Name is rollbacked');
                    System.assertNotEquals(oldContact.LastName, rollbackedContact.LastName, 'Contact Last Name is rollbacked');
                    System.assertNotEquals(oldContact.Email, rollbackedContact.Email, 'Contact Email is rollbacked');
                    System.assertNotEquals(oldContact.Phone, rollbackedContact.Phone, 'Contact Phone is rollbacked');
                    System.assertEquals(null, rollbackedContact.Description, 'Contact Description is rollbacked');
                }
            }

            for (Integer k = 0;  k < rollbackedAccount.opportunities.size(); k++) {
                Opportunity oldOpportunity = oldAccount.opportunities[k];
                Opportunity rollbackedOpportunity = rollbackedAccount.opportunities[k];

                if (i == 0) {
                    System.assertEquals(oldOpportunity.Name, rollbackedOpportunity.Name, 'Opportunity Name is still masked');
                    System.assertEquals(oldOpportunity.StageName, rollbackedOpportunity.StageName, 'Opportunity Stage is still masked');
                    System.assertEquals(oldOpportunity.CloseDate, rollbackedOpportunity.CloseDate, 'Opportunity Close Date is still masked');
                    System.assertEquals(oldOpportunity.Amount, rollbackedOpportunity.Amount, 'Opportunity Amount is still masked');
                    System.assertEquals(oldOpportunity.Probability, rollbackedOpportunity.Probability, 'Opportunity Probability is still masked');
                    System.assertNotEquals(null, rollbackedOpportunity.Description, 'Opportunity Description is still emptied');
                } else {
                    System.assertNotEquals(oldOpportunity.Name, rollbackedOpportunity.Name, 'Opportunity Name is rollbacked');
                    System.assertNotEquals(oldOpportunity.StageName, rollbackedOpportunity.StageName, 'Opportunity Stage is rollbacked');
                    System.assertNotEquals(oldOpportunity.CloseDate, rollbackedOpportunity.CloseDate, 'Opportunity Close Date is rollbacked');
                    System.assertNotEquals(oldOpportunity.Amount, rollbackedOpportunity.Amount, 'Opportunity Amount is rollbacked');
                    System.assertNotEquals(oldOpportunity.Probability, rollbackedOpportunity.Probability, 'Opportunity Probability is rollbacked');
                    System.assertEquals(null, rollbackedOpportunity.Description, 'Opportunity Description is rollbacked');
                }
            }

            if (i == 0) {
                System.assertNotEquals(0, rollbackedAccount.Attachments.size(), 'Attachments were not restored');
            } else {
                System.assertEquals(0, rollbackedAccount.Attachments.size(), 'Attachments were restored');
            }
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();

        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcResults[1].OQCT_DaCl__Overall_Result__c, 'Overall Status not Success');
        System.assertEquals(true, dcResults[1].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job Not completed');
        System.assertEquals(7, dcResults[1].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[1].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');

        // Data Clean Field updates assertions
        dataCleans = DataCleanSelector.getAllDataCleans();

        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Rollback_Completed__c, 'Rollback not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for Data Clean is not Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Rollback_Status__c, 'Overall Rollback Status for DC-Config is not Pending');
        System.assertEquals(7, dcConfigs[0].OQCT_DaCl__Overall_Success_Rollback__c, 'Overall Success (Rollback) for DC-Config is not correct');
    }

}