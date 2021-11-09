/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-17   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DataCleanArchiveBatchTest {

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
        OQCT_DaCl__DC_Configuration__c dcConfig = DataFactory.initDcConfiguration(Constants.DC_ACTION_ARCHIVE_DELETION);
        List<OQCT_DaCl__Related_Object__c> relatedObjects = DataFactory.initRelatedObjectsFromDcConfig(dcConfig, false);
        // DataFactory.initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(dcConfig, relatedObjects);
        DataFactory.initDataCleansFromDcConfig(dcConfig.Id);
    }

    @IsTest
    private static void archiveBatchTestSuccess(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ARCHIVE;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

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

        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Archive_Completed__c, 'Archive not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Archive_Status__c, 'Overall Archive Status for Data Clean is not Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Archive_Status__c, 'Overall Archive Status for DC-Config is not Success');
        System.assertEquals(14, dcConfigs[0].OQCT_DaCl__Overall_Success_Archive__c, 'Overall Success (Archive) for DC-Config is not correct');
    }

    @IsTest
    private static void archiveBatchTestInvalidMasterId(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        List<Account> accounts = AccountSelector.getAllAccounts();

        for (Account account : accounts) {
            account.AccountNumber = 'CHANGED';
        }

        DatabaseUtils.updateRecords(accounts);

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ARCHIVE;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

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
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Archive_Completed__c, 'Archive Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_FAILED, dataCleans[0].OQCT_DaCl__Overall_Archive_Status__c, 'Overall Archive Status for Data Clean is not Failed');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Archive_Status__c, 'Overall Archive Status for DC-Config is not Pending');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Archive__c, 'Overall Success (Archive) for DC-Config is not correct');
    }

    @IsTest
    private static void archiveBatchTestNoChildRecords(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        DatabaseUtils.deleteRecords(ContactSelector.getAllContacts());
        DatabaseUtils.deleteRecords(OpportunitySelector.getAllOpportunities());
        DatabaseUtils.deleteRecords(AttachmentSelector.getAllAttachments());

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ARCHIVE;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

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
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Archive_Completed__c, 'Archive not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Archive_Status__c, 'Overall Archive Status for Data Clean is not Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Archive_Status__c, 'Overall Archive Status for DC-Config is not Success');
        System.assertEquals(2, dcConfigs[0].OQCT_DaCl__Overall_Success_Archive__c, 'Overall Success (Archive) for DC-Config is not correct');
    }

    @IsTest
    private static void archiveBatchTestNoChildConfig(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        DatabaseUtils.deleteRecords(RecordTypeAndFieldSelector.getRecordTypeAndFieldForChildByDcConfigId(dcConfigs[0].Id));
        DatabaseUtils.deleteRecords(RelatedObjectSelector.getAllRelatedObjects());
        DatabaseUtils.deleteRecords(DCRelatedResultSelector.getAllDcRelatedResults());
        DatabaseUtils.deleteRecords(DataCleanRelatedResultSelector.getAllDataCleanRelatedResults());

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ARCHIVE;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

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
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Archive_Completed__c, 'Archive not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Archive_Status__c, 'Overall Archive Status for Data Clean is not Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Archive_Status__c, 'Overall Archive Status for DC-Config is not Success');
        System.assertEquals(2, dcConfigs[0].OQCT_DaCl__Overall_Success_Archive__c, 'Overall Success (Archive) for DC-Config is not correct');
    }

    @IsTest
    private static void archiveBatchTestLargeNumberOfChildRecords(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        DataCleanArchiveBatch.startLargeBatchForTest = true;

        DataCleanSchedulable.ScheduleWrapper scheduleWrapper = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrapper.dataConfigurationId = dcConfigs[0].Id;
        scheduleWrapper.batchType = Constants.BATCH_TYPE.BATCH_ARCHIVE;
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrapper);

        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

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
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Archive_Completed__c, 'Archive not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Archive_Status__c, 'Overall Archive Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Archive_Status__c, 'Overall Archive Status for DC-Config is not Pending');
        System.assertEquals(2, dcConfigs[0].OQCT_DaCl__Overall_Success_Archive__c, 'Overall Success (Archive) for DC-Config is not correct');
    }

}