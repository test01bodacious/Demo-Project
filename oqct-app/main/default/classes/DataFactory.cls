/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-02   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.CognitiveComplexity')
@IsTest
public with sharing class DataFactory {

    // Create Email Template
    @future
    public static void initEmailTemplate(String developerName){
        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.isActive = true;
        emailTemplate.Name = 'Test Email Template';
        emailTemplate.DeveloperName = developerName;
        emailTemplate.TemplateType = Constants.EMAIL_TEMPLATE_TYPE_TEXT;
        emailTemplate.FolderId = Utils.getUserId();
        DatabaseUtils.insertRecords(emailTemplate);
    }

    // Create Content Version from PathOnClient
    @future
    public static void initContentVersion(String pathOnClient){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.title = 'Test File';
        contentVersion.pathOnClient = pathOnClient;
        contentVersion.FirstPublishLocationId = Utils.getUserId();
        contentVersion.VersionData  = Blob.valueOf('Test Data');
        contentVersion.isMajorVersion = false;
        DatabaseUtils.insertRecords(contentVersion);
    }

    // ConrentVersion From PublisherId
    public static void initContentVersion(Id publisherId){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.title = 'Test File';
        contentVersion.pathOnClient = 'pathOnClient';
        contentVersion.FirstPublishLocationId = publisherId;
        contentVersion.VersionData  = Blob.valueOf('Test Data');
        contentVersion.isMajorVersion = false;
        DatabaseUtils.insertRecords(contentVersion);
    }

    // Create Single Account and It's Child Object's Record

    // Account
    public static Account initAccount(){
        return initAccount('Test Account');
    }

    public static Account initAccount(String name){
        Account account = new Account(Name = name);
        DatabaseUtils.insertRecords(account);
        return account;
    }

    // Account - Contacts
    public static List<Contact> initContactsForAccount(Id accountId){
        return initContactsForAccount(accountId, 'Test Last Name', 2);
    }

    public static List<Contact> initContactsForAccount(Id accountId, Integer numberOfContacts){
        return initContactsForAccount(accountId, 'Test Last Name', numberOfContacts);
    }

    public static List<Contact> initContactsForAccount(Id accountId, String lastName, Integer numberOfContacts){
        return initContactsForAccounts(new List<Account>{new Account(Id = accountId)}, numberOfContacts);
    }

    // Account - Opportunities
    public static List<Opportunity> initOpportunitiesForAccount(Id accountId){
        return initOpportunitiesForAccount(accountId, 'Test Opportunity', 2);
    }

    public static List<Opportunity> initOpportunitiesForAccount(Id accountId, Integer numberOfOpportunities){
        return initOpportunitiesForAccount(accountId, 'Test Opportunity', numberOfOpportunities);
    }

    public static List<Opportunity> initOpportunitiesForAccount(Id accountId, String name, Integer numberOfOpportunities){
        return initOpportunitiesForAccounts(new List<Account>{new Account(Id = accountId)}, numberOfOpportunities);
    }

    // Account - Cases
    public static List<Case> initCasesForAccount(Id accountId){
        return initCasesForAccount(accountId, 2);
    }

    public static List<Case> initCasesForAccount(Id accountId, Integer numberOfCases){
        return initCasesForAccounts(new List<Account>{new Account(Id = accountId)}, numberOfCases);
    }

    // Account - Attachments
    public static List<Attachment> initAttachmentsForAccount(Id accountId){
        return initAttachmentsForAccount(accountId, 'Test Attachment', 2);
    }

    public static List<Attachment> initAttachmentsForAccount(Id accountId, Integer numberOfAttachments){
        return initAttachmentsForAccount(accountId, 'Test Attachment', numberOfAttachments);
    }

    public static List<Attachment> initAttachmentsForAccount(Id accountId, String name, Integer numberOfAttachments){
        return initAttachmentsForAccounts(new List<Account>{new Account(Id = accountId)}, numberOfAttachments);
    }

    // Create Bulk Account and It's Child Object's Record

    // Accounts
    public static List<Account> initAccounts(){
        return initAccounts('Test Account', 2);
    }

    public static List<Account> initAccounts(Integer numberOfAccounts){
        return initAccounts('Test Account', numberOfAccounts);
    }

    public static List<Account> initAccounts(String name, Integer numberOfAccounts){
        List<Account> accounts = new List<Account>();
        for (Integer i = 1; i <= numberOfAccounts; i++) {
            Account account = new Account(Name = name + i);
            account.AccountNumber = String.valueOf(i);
            account.Phone = '987654321' + (2*i-1);
            account.Industry = 'Education';
            account.Rating = 'Hot';
            account.NumberOfEmployees = i*1000;
            account.Website = 'https://test' + i + '.com';
            account.Description = 'Test Account Description' + i;
            accounts.add(account);
        }
        DatabaseUtils.insertRecords(accounts);
        return accounts;
    }

    // Accounts - Contacts
    public static List<Contact> initContactsForAccounts(List<Account> accounts){
        return initContactsForAccounts(accounts, 'Test Last Name', 2);
    }

    public static List<Contact> initContactsForAccounts(List<Account> accounts, Integer numberOfContactsPerAccount){
        return initContactsForAccounts(accounts, 'Test Last Name', numberOfContactsPerAccount);
    }

    public static List<Contact> initContactsForAccounts(List<Account> accounts, String lastName, Integer numberOfContactsPerAccount){
        List<Contact> contacts = new List<Contact>();
        Integer count = 1;
        for (Account account : accounts) {
            for (Integer i = 1; i <= numberOfContactsPerAccount; i++) {
                Contact contact = new Contact(AccountId = account.Id, LastName = lastName + count);
                contact.FirstName = 'Test First Name' + count;
                contact.Email = 'lastname' + count + '@test.com';
                contact.Phone = '987654321' + count;
                contact.Description = 'Test Contact Description' + count;
                contacts.add(contact);
                count++;
            }
        }
        DatabaseUtils.insertRecords(contacts);
        return contacts;
    }

    // Accounts - Opportunities
    public static List<Opportunity> initOpportunitiesForAccounts(List<Account> accounts){
        return initOpportunitiesForAccounts(accounts, 'Test Opportunity', 2);
    }

    public static List<Opportunity> initOpportunitiesForAccounts(List<Account> accounts, Integer numberOfOpportunitiesPerAccount){
        return initOpportunitiesForAccounts(accounts, 'Test Opportunity', numberOfOpportunitiesPerAccount);
    }

    public static List<Opportunity> initOpportunitiesForAccounts(List<Account> accounts, String name, Integer numberOfOpportunitiesPerAccount){
        List<Opportunity> opportunities = new List<Opportunity>();
        Integer count = 1;
        for (Account account : accounts) {
            for (Integer i = 1; i <= numberOfOpportunitiesPerAccount; i++) {
                Opportunity opportunity = new Opportunity(AccountId = account.Id, Name = name + count);
                opportunity.StageName = 'Prospecting';
                opportunity.CloseDate = DateUtils.getToday();
                opportunity.Amount = 15000 * count;
                opportunity.Probability = 0.1;
                opportunity.Description = 'Test Opportunity Description' + count;
                opportunities.add(opportunity);
                count++;
            }
        }
        DatabaseUtils.insertRecords(opportunities);
        return opportunities;
    }

    // Accounts - Cases
    public static List<Case> initCasesForAccounts(List<Account> accounts){
        return initCasesForAccounts(accounts, 2);
    }

    public static List<Case> initCasesForAccounts(List<Account> accounts, Integer numberOfCasesPerAccount){
        List<Case> cases = new List<Case>();
        for (Account account : accounts) {
            for (Integer i = 1; i <= numberOfCasesPerAccount; i++) {
                Case caseForAccount = new Case(AccountId = account.Id);
                cases.add(caseForAccount);
            }
        }
        DatabaseUtils.insertRecords(cases);
        return cases;
    }

    public static List<Case> initCasesForContacts(List<Contact> contacts, Integer numberOfCasesPerContact){
        List<Case> cases = new List<Case>();
        for (Contact contact : contacts) {
            for (Integer i = 1; i <= numberOfCasesPerContact; i++) {
                Case caseForContact = new Case(ContactId = contact.Id);
                cases.add(caseForContact);
            }
        }
        DatabaseUtils.insertRecords(cases);
        return cases;
    }

    // Accounts - Attachment
    public static List<Attachment> initAttachmentsForAccounts(List<Account> accounts){
        return initAttachmentsForAccounts(accounts, 'Test Attachment', 2);
    }

    public static List<Attachment> initAttachmentsForAccounts(List<Account> accounts, Integer numberOfAttachmentsPerAccount){
        return initAttachmentsForAccounts(accounts, 'Test Attachment', numberOfAttachmentsPerAccount);
    }

    public static List<Attachment> initAttachmentsForAccounts(List<Account> accounts, String name, Integer numberOfAttachmentsPerAccount){
        List<Attachment> attachments = new List<Attachment>();
        Integer count = 1;
        for (Account account : accounts) {
            for (Integer i = 1; i <= numberOfAttachmentsPerAccount; i++) {
                Attachment attachment = new Attachment(ParentId = account.Id, Name = name + count);
                attachment.Body = Blob.valueOf('Test Body' + count);
                attachments.add(attachment);
                count++;
            }
        }
        DatabaseUtils.insertRecords(attachments);
        return attachments;
    }

    // Create DC-Data Types
    public static List<OQCT_DaCl__DC_Data_Type__c> initDcDataTypes(){
        return DataCleanPostInstallScript.initDcDataTypesWithDefaultValues();
    }

    // Create Data Clean App Configuration
    public static OQCT_DaCl__Data_Clean_App_Configurations__c initDataCleanAppConfigurations(){
        OQCT_DaCl__Data_Clean_App_Configurations__c dataCleanAppConfigurations = new OQCT_DaCl__Data_Clean_App_Configurations__c();
        dataCleanAppConfigurations.OQCT_DaCl__Admin_Team_Email_Id__c = 'admin@test.com';
        dataCleanAppConfigurations.OQCT_DaCl__External_Department_Email_Id__c = 'externaldept@test.com';
        dataCleanAppConfigurations.OQCT_DaCl__Send_Global_Email_App_Notification__c = true;
        dataCleanAppConfigurations.OQCT_DaCl__Team_Notes__c = Constants.LITERAL_EMPTY;
        DatabaseUtils.insertRecords(dataCleanAppConfigurations);
        return dataCleanAppConfigurations;
    }

    // DC-Configurations
    public static OQCT_DaCl__DC_Configuration__c initDcConfiguration(){
        return initDcConfiguration(Constants.DC_ACTION_MASKING_ROLLBACK_DELETION);
    }

    public static OQCT_DaCl__DC_Configuration__c initDcConfiguration(String action){
        OQCT_DaCl__DC_Configuration__c dcConfig = new OQCT_DaCl__DC_Configuration__c();
        dcConfig.OQCT_DaCl__Data_Clean_Action__c = action;
        dcConfig.OQCT_DaCl__Master_Object_Name__c = Constants.OBJECT_ACCOUNT;
        dcConfig.OQCT_DaCl__Master_Object_Match_By_Field_Name__c = Constants.ACCOUNT_FIELD_ACCOUNT_NUMBER;
        dcConfig.OQCT_DaCl__Configuration_Notes__c = Constants.LITERAL_EMPTY;
        dcConfig.OQCT_DaCl__Receive_Email_Notification__c = true;
        dcConfig.OQCT_DaCl__Email_Ids_to_Notify__c = 'success@test.com';
        dcConfig.OQCT_DaCl__Receive_Error_Email_Notification__c = true;
        dcConfig.OQCT_DaCl__Error_Email_Ids_to_Notify__c = 'failure@test.com';
        dcConfig.OQCT_DaCl__Data_Clean_Process_Start_After__c = 1;
        dcConfig.OQCT_DaCl__Data_Clean_Process_Start_Unit__c = Constants.DC_UNIT_DAYS;
        dcConfig.OQCT_DaCl__Data_Clean_Process_Start_Time__c = DateUtils.getNow().time();
        dcConfig.OQCT_DaCl__Process2_Start_After__c = 3;
        dcConfig.OQCT_DaCl__Process2_Start_Unit__c = Constants.DC_UNIT_DAYS;
        dcConfig.OQCT_DaCl__Process2_Start_Time__c = DateUtils.getNow().time();
        dcConfig.OQCT_DaCl__Delete_Backups_After__c = 2;
        dcConfig.OQCT_DaCl__Delete_Backups_Unit__c = Constants.DC_UNIT_DAYS;
        dcConfig.OQCT_DaCl__Delete_Backups_Time__c = DateUtils.getNow().time();
        dcConfig.OQCT_DaCl__Retry_Process__c = true;
        dcConfig.OQCT_DaCl__Retry_Process_After__c = 1;
        dcConfig.OQCT_DaCl__Retry_Process_Unit__c = Constants.DC_UNIT_DAYS;
        dcConfig.OQCT_DaCl__Retry_Process2__c = true;
        dcConfig.OQCT_DaCl__Retry_Process2_After__c = 1;
        dcConfig.OQCT_DaCl__Retry_Process2_Unit__c = Constants.DC_UNIT_DAYS;
        dcConfig.OQCT_DaCl__Is_Configuration_Active__c = true;
        DatabaseUtils.insertRecords(dcConfig);
        return dcConfig;
    }

    // DC-Configuration - Related Objects
    public static List<OQCT_DaCl__Related_Object__c> initRelatedObjectsFromDcConfig(OQCT_DaCl__DC_Configuration__c dcConfig){
        return initRelatedObjectsFromDcConfig(dcConfig, true);
    }

    // DC-Configuration - Related Objects
    public static List<OQCT_DaCl__Related_Object__c> initRelatedObjectsFromDcConfig(OQCT_DaCl__DC_Configuration__c dcConfig, Boolean deleteAttachment){
        List<OQCT_DaCl__Related_Object__c> relatedObjects = new List<OQCT_DaCl__Related_Object__c>();

        OQCT_DaCl__Related_Object__c relatedObject1 = new OQCT_DaCl__Related_Object__c();
        relatedObject1.OQCT_DaCl__DC_Configuration__c = dcConfig.Id;
        relatedObject1.OQCT_DaCl__Related_Object_Name__c = Constants.OBJECT_CONTACT;
        relatedObject1.OQCT_DaCl__Delete_Related_Records__c = false;
        relatedObjects.add(relatedObject1);

        OQCT_DaCl__Related_Object__c relatedObject2 = new OQCT_DaCl__Related_Object__c();
        relatedObject2.OQCT_DaCl__DC_Configuration__c = dcConfig.Id;
        relatedObject2.OQCT_DaCl__Related_Object_Name__c = Constants.OBJECT_OPPORTUNITY;
        relatedObject2.OQCT_DaCl__Delete_Related_Records__c = false;
        relatedObjects.add(relatedObject2);

        OQCT_DaCl__Related_Object__c relatedObject3 = new OQCT_DaCl__Related_Object__c();
        relatedObject3.OQCT_DaCl__DC_Configuration__c = dcConfig.Id;
        relatedObject3.OQCT_DaCl__Related_Object_Name__c = Constants.OBJECT_ATTACHMENT;
        relatedObject3.OQCT_DaCl__Delete_Related_Records__c = deleteAttachment;
        relatedObjects.add(relatedObject3);

        DatabaseUtils.insertRecords(relatedObjects);
        return relatedObjects;
    }

    // DC-Configuration - Record Types & Fields
    public static List<OQCT_DaCl__Record_Type_Field__c> initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(OQCT_DaCl__DC_Configuration__c dcConfig, List<OQCT_DaCl__Related_Object__c> relatedObjects){
        
        List<OQCT_DaCl__Record_Type_Field__c> recordTypesAndFields = new List<OQCT_DaCl__Record_Type_Field__c>();

        OQCT_DaCl__Record_Type_Field__c recordTypeAndField1 = new OQCT_DaCl__Record_Type_Field__c();
        recordTypeAndField1.OQCT_DaCl__DC_Configuration__c = dcConfig.Id;
        recordTypeAndField1.OQCT_DaCl__Related_Object__c = null;
        Schema.DescribeSObjectResult objectDescribe = Utils.getSObjectDescription(dcConfig.OQCT_DaCl__Master_Object_Name__c);
        recordTypeAndField1.OQCT_DaCl__Record_Type_Id__c = objectDescribe.getRecordTypeInfos()[0].getRecordTypeId();
        recordTypeAndField1.OQCT_DaCl__Record_Type_Name__c = objectDescribe.getRecordTypeInfos()[0].getName();
        recordTypeAndField1.OQCT_DaCl__Record_Type_Enabled__c = true;
        StringBuilder fields = new StringBuilder();
        fields.setSeparator(Constants.LITERAL_COMMA_SEPARATOR);
        fields.append('Name');
        fields.append('Phone');
        fields.append('Industry');
        fields.append('Rating');
        fields.append('NumberOfEmployees');
        fields.append('Website');
        recordTypeAndField1.OQCT_DaCl__Fields_To_Mask__c = fields.toString().toLowerCase();
        recordTypeAndField1.OQCT_DaCl__Fields_to_Empty__c = 'Description';
        recordTypesAndFields.add(recordTypeAndField1);
        
        OQCT_DaCl__Record_Type_Field__c recordTypeAndField2 = new OQCT_DaCl__Record_Type_Field__c();
        recordTypeAndField2.OQCT_DaCl__DC_Configuration__c = dcConfig.Id;
        recordTypeAndField2.OQCT_DaCl__Related_Object__c = relatedObjects[0].Id;
        objectDescribe = Utils.getSObjectDescription(relatedObjects[0].OQCT_DaCl__Related_Object_Name__c);
        recordTypeAndField2.OQCT_DaCl__Record_Type_Id__c = objectDescribe.getRecordTypeInfos()[0].getRecordTypeId();
        recordTypeAndField2.OQCT_DaCl__Record_Type_Name__c = objectDescribe.getRecordTypeInfos()[0].getName();
        recordTypeAndField2.OQCT_DaCl__Record_Type_Enabled__c = true;
        fields = new StringBuilder();
        fields.setSeparator(Constants.LITERAL_COMMA_SEPARATOR);
        fields.append('FirstName');
        fields.append('LastName');
        fields.append('Email');
        fields.append('Phone');
        recordTypeAndField2.OQCT_DaCl__Fields_To_Mask__c = fields.toString().toLowerCase();
        recordTypeAndField2.OQCT_DaCl__Fields_to_Empty__c = 'Description';
        recordTypesAndFields.add(recordTypeAndField2);

        OQCT_DaCl__Record_Type_Field__c recordTypeAndField3 = new OQCT_DaCl__Record_Type_Field__c();
        recordTypeAndField3.OQCT_DaCl__DC_Configuration__c = dcConfig.Id;
        recordTypeAndField3.OQCT_DaCl__Related_Object__c = relatedObjects[1].Id;
        objectDescribe = Utils.getSObjectDescription(relatedObjects[1].OQCT_DaCl__Related_Object_Name__c);
        recordTypeAndField3.OQCT_DaCl__Record_Type_Id__c = objectDescribe.getRecordTypeInfos()[0].getRecordTypeId();
        recordTypeAndField3.OQCT_DaCl__Record_Type_Name__c = objectDescribe.getRecordTypeInfos()[0].getName();
        recordTypeAndField3.OQCT_DaCl__Record_Type_Enabled__c = true;
        fields = new StringBuilder();
        fields.setSeparator(Constants.LITERAL_COMMA_SEPARATOR);
        fields.append('Name');
        fields.append('StageName');
        fields.append('CloseDate');
        fields.append('Amount');
        fields.append('Probability');
        recordTypeAndField3.OQCT_DaCl__Fields_To_Mask__c = fields.toString().toLowerCase();
        recordTypeAndField3.OQCT_DaCl__Fields_to_Empty__c = 'Description';
        recordTypesAndFields.add(recordTypeAndField3);

        OQCT_DaCl__Record_Type_Field__c recordTypeAndField4 = new OQCT_DaCl__Record_Type_Field__c();
        recordTypeAndField4.OQCT_DaCl__DC_Configuration__c = dcConfig.Id;
        recordTypeAndField4.OQCT_DaCl__Related_Object__c = relatedObjects[2].Id;
        recordTypeAndField4.OQCT_DaCl__Record_Type_Id__c = null;
        recordTypeAndField4.OQCT_DaCl__Record_Type_Name__c = null;
        recordTypeAndField4.OQCT_DaCl__Record_Type_Enabled__c = true;
        recordTypeAndField4.OQCT_DaCl__Fields_To_Mask__c = null;
        recordTypeAndField4.OQCT_DaCl__Fields_to_Empty__c = null;
        recordTypesAndFields.add(recordTypeAndField4);

        DatabaseUtils.insertRecords(recordTypesAndFields);

        return recordTypesAndFields;
    }
    
    // DC-Configuration - Data Clean
    public static List<OQCT_DaCl__Data_Clean__c> initDataCleansFromDcConfig(Id dcConfigId){
        return initDataCleansFromDcConfig(dcConfigId, 2);
    }

    public static List<OQCT_DaCl__Data_Clean__c> initDataCleansFromDcConfig(Id dcConfigId, Integer numberOfDataCleans){
        List<OQCT_DaCl__Data_Clean__c> dataCleans = new List<OQCT_DaCl__Data_Clean__c>();
        String dcConfigName = DCConfigurationSelector.getDCConfigurationNameById(dcConfigId).Name;
        for (Integer i = 1; i <= numberOfDataCleans; i++) {
            OQCT_DaCl__Data_Clean__c dataClean = new OQCT_DaCl__Data_Clean__c();
            dataClean.OQCT_DaCl__Master_Id__c = String.valueOf(i);
            dataClean.OQCT_DaCl__DC_Configuration_Id__c = dcConfigName;
            dataCleans.add(dataClean);
        }
        DatabaseUtils.insertRecords(dataCleans);
        return dataCleans;
    }
    
    public static OQCT_DaCl__DC_Result__c initResultRecords(Id dcConfigId){
        OQCT_DaCl__DC_Configuration__c dcConfiguration = DCConfigurationSelector.getDCConfigurationsByIds(new Set<Id>{dcConfigId})[0];
        OQCT_DaCl__DC_Result__c dcResult = new OQCT_DaCl__DC_Result__c();
        dcResult.OQCT_DaCl__DC_Configuration__c = dcConfiguration.Id;
        dcResult.OQCT_DaCl__Job_Schedule_Date__c = dcConfiguration.OQCT_DaCl__Process_Scheduled_Date_Time_Next__c;
        dcResult.OQCT_DaCl__Process__c = Constants.PROCESS_MASK;
        dcResult.OQCT_DaCl__Job_Name__c = DataCleanHelper.getInitialJobName(dcConfiguration.Name, dcConfiguration.OQCT_DaCl__Data_Clean_Action__c);
        dcResult.OQCT_DaCl__Attempt_No__c = 1;
        DatabaseUtils.insertRecords(dcResult);
        return dcResult; 
    }
    
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static void insertBackups(OQCT_DaCl__DC_Configuration__c dcConfig, OQCT_DaCl__DC_Result__c dcResult, Boolean testFailure, Boolean noChild, Boolean noParent){

        List<ReportUtil.BackupReportContent> backupReportContents;
        ContentVersion contentVersion;

        if (!noChild) {
            // First Backup - Contacts
            backupReportContents = getBackupContents(dcConfig, Constants.PROCESS_MASK, Constants.OBJECT_CONTACT, false);
            if (testFailure) {
                for (ReportUtil.BackupReportContent backupReportContent : backupReportContents) {
                    backupReportContent.record.put('LastName', 'Test LastName'.repeat(100));
                }
            }
            contentVersion = new ContentVersion();
            contentVersion.title = dcConfig.Name + Constants.LITERAL_HYPHEN + Constants.PROCESS_MASK + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_BACKUP + Constants.CHILD + Constants.LITERAL_HYPHEN + Constants.OBJECT_CONTACT + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
            contentVersion.pathOnClient = contentVersion.title + Constants.FILE_EXTENSION_JSON;
            contentVersion.FirstPublishLocationId = dcResult.Id;
            contentVersion.VersionData  = Blob.valueOf(JSON.serialize(backupReportContents));
            contentVersion.isMajorVersion = false;
            DatabaseUtils.insertRecords(contentVersion);

            ReportUtil.updateDataCleanWithBackupFileName(backupReportContents, contentVersion.pathOnClient, false);
            ReportUtil.updateDcResultBackupFileName(backupReportContents, contentVersion.pathOnClient, dcResult.Id, false);

            // Second Backup - Opportunities
            backupReportContents = getBackupContents(dcConfig, Constants.PROCESS_MASK, Constants.OBJECT_OPPORTUNITY, false);
            contentVersion = new ContentVersion();
            contentVersion.title = dcConfig.Name + Constants.LITERAL_HYPHEN + Constants.PROCESS_MASK + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_BACKUP + Constants.CHILD + Constants.LITERAL_HYPHEN + Constants.OBJECT_OPPORTUNITY + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
            contentVersion.pathOnClient = contentVersion.title + Constants.FILE_EXTENSION_JSON;
            contentVersion.FirstPublishLocationId = dcResult.Id;
            contentVersion.VersionData  = Blob.valueOf(JSON.serialize(backupReportContents));
            contentVersion.isMajorVersion = false;
            DatabaseUtils.insertRecords(contentVersion);

            ReportUtil.updateDataCleanWithBackupFileName(backupReportContents, contentVersion.pathOnClient, false);
            ReportUtil.updateDcResultBackupFileName(backupReportContents, contentVersion.pathOnClient, dcResult.Id, false);

            // Third Backup - Attachment
            backupReportContents = getBackupContents(dcConfig, Constants.PROCESS_DELETE ,Constants.OBJECT_ATTACHMENT, false);
            contentVersion = new ContentVersion();
            contentVersion.title = dcConfig.Name + Constants.LITERAL_HYPHEN + Constants.PROCESS_DELETE + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_BACKUP + Constants.CHILD + Constants.LITERAL_HYPHEN + Constants.OBJECT_ATTACHMENT + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
            contentVersion.pathOnClient = contentVersion.title + Constants.FILE_EXTENSION_JSON;
            contentVersion.FirstPublishLocationId = dcResult.Id;
            contentVersion.VersionData  = Blob.valueOf(JSON.serialize(backupReportContents));
            contentVersion.isMajorVersion = false;
            DatabaseUtils.insertRecords(contentVersion);

            ReportUtil.updateDataCleanWithBackupFileName(backupReportContents, contentVersion.pathOnClient, false);
            ReportUtil.updateDcResultBackupFileName(backupReportContents, contentVersion.pathOnClient, dcResult.Id, false);
        }

        if (!noParent) {
            // Fourth Backup - Account
            backupReportContents = getBackupContents(dcConfig, Constants.PROCESS_MASK, dcConfig.OQCT_DaCl__Master_Object_Name__c, true);
            contentVersion = new ContentVersion();
            contentVersion.title = dcConfig.Name + Constants.LITERAL_HYPHEN + Constants.PROCESS_MASK + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_BACKUP + Constants.PARENT + Constants.LITERAL_HYPHEN + dcConfig.OQCT_DaCl__Master_Object_Name__c + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
            contentVersion.pathOnClient = contentVersion.title + Constants.FILE_EXTENSION_JSON;
            contentVersion.FirstPublishLocationId = dcResult.Id;
            contentVersion.VersionData  = Blob.valueOf(JSON.serialize(backupReportContents));
            contentVersion.isMajorVersion = false;
            DatabaseUtils.insertRecords(contentVersion);

            ReportUtil.updateDataCleanWithBackupFileName(backupReportContents, contentVersion.pathOnClient, true);
            ReportUtil.updateDcResultBackupFileName(backupReportContents, contentVersion.pathOnClient, dcResult.Id, true);
        }
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static List<ReportUtil.BackupReportContent> getBackupContents(OQCT_DaCl__DC_Configuration__c dcConfig, String processName, String objectName, Boolean isParent){
        List<ReportUtil.BackupReportContent> backupContents = new List<ReportUtil.BackupReportContent>();
        List<SObject> records = getRecordForBackup(dcConfig, processName, objectName, isParent);
        Integer indexCount = 0;
        Integer maxChild = isParent ? 1 : 2;
        for (OQCT_DaCl__Data_Clean__c dataClean : DataCleanSelector.getDataCleanByDcConfigIds(dcConfig.Id)) {
            for (Integer i = 0; i < maxChild; i++) {
                ReportUtil.BackupReportContent backupContent = new ReportUtil.BackupReportContent();
                backupContent.dataCleanId = dataClean.Id;
                backupContent.masterId = dataClean.OQCT_DaCl__Master_Id__c;
                backupContent.objName = objectName;
                backupContent.isMasterObject = isParent;
                backupContent.actionType = processName;
                backupContent.record = objectName != Constants.OBJECT_ATTACHMENT ? records[indexCount] : null;
                backupContent.recordId = (Id)records[indexCount].get(Constants.FIELD_RECORD_ID);
                backupContents.add(backupContent);
                indexCount++;
            }
        }
        return backupContents;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static List<SObject> getRecordForBackup(OQCT_DaCl__DC_Configuration__c dcConfig, String processName, String objectName, Boolean isParent){
        DataCleanBatchHelper.RecordTypeAndFieldWrapper recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, processName, objectName, isParent);
        List<String> fieldApiNames = new List<String>();
        if (processName == Constants.PROCESS_DELETE) {
            fieldApiNames.addAll(recordTypeAndFieldWrap.fieldsToQuery);
        } else {
            Schema.DescribeSObjectResult objectDescribe = Utils.getSObjectDescription(objectName);
            fieldApiNames.addAll(recordTypeAndFieldWrap.recordTypesAndFields.get(objectDescribe.getRecordTypeInfos()[0].getRecordTypeId()).fieldsToMask);
            fieldApiNames.addAll(recordTypeAndFieldWrap.recordTypesAndFields.get(objectDescribe.getRecordTypeInfos()[0].getRecordTypeId()).fieldsToEmpty);
        }
        return SObjectSelector.getRecords(objectName, fieldApiNames);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static void maskOrDeleteSobjectRecords(OQCT_DaCl__DC_Configuration__c dcConfig, Boolean emptyRecycleBin, Boolean noChild, Boolean noParent){
        if (!noChild) {
            maskOrDeleteSobjectRecords(dcConfig, Constants.PROCESS_MASK, Constants.OBJECT_CONTACT, false, emptyRecycleBin);
            maskOrDeleteSobjectRecords(dcConfig, Constants.PROCESS_MASK, Constants.OBJECT_OPPORTUNITY, false, emptyRecycleBin);
            maskOrDeleteSobjectRecords(dcConfig, Constants.PROCESS_DELETE, Constants.OBJECT_ATTACHMENT, false, emptyRecycleBin);
        }
        if (!noParent) {
            maskOrDeleteSobjectRecords(dcConfig, Constants.PROCESS_MASK, Constants.OBJECT_ACCOUNT, true, emptyRecycleBin);
        }
    }

    @SuppressWarnings('PMD.CognitiveComplexity,PMD.ExcessiveParameterList')
    private static void maskOrDeleteSobjectRecords(OQCT_DaCl__DC_Configuration__c dcConfig, String processName, String objectName, Boolean isParent, Boolean emptyRecycleBin){
        DataCleanBatchHelper.RecordTypeAndFieldWrapper recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, processName, objectName, isParent);
        List<String> fieldApiNames = new List<String>();
        Schema.DescribeSObjectResult objectDescribe = Utils.getSObjectDescription(objectName);
        if (processName == Constants.PROCESS_DELETE || processName == Constants.PROCESS_ARCHIVE) {
            fieldApiNames.addAll(recordTypeAndFieldWrap.fieldsToQuery);
        } else {
            fieldApiNames.addAll(recordTypeAndFieldWrap.recordTypesAndFields.get(objectDescribe.getRecordTypeInfos()[0].getRecordTypeId()).fieldsToMask);
            fieldApiNames.addAll(recordTypeAndFieldWrap.recordTypesAndFields.get(objectDescribe.getRecordTypeInfos()[0].getRecordTypeId()).fieldsToEmpty);
        }
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Map<String, Schema.SObjectField> sObjectFieldMap = Utils.getSObjectDescription(objectName).fields.getMap();
        List<SObject> recordsToUpdateOrDelete = new List<SObject>();
        for (SObject record : SObjectSelector.getRecords(objectName, fieldApiNames)) {
            if (processName != Constants.PROCESS_DELETE && processName != Constants.PROCESS_ARCHIVE) {
                for (String fieldToEmpty : recordTypeAndFieldWrap.recordTypesAndFields.get(objectDescribe.getRecordTypeInfos()[0].getRecordTypeId()).fieldsToEmpty) {
                    record.put(fieldToEmpty, null);
                }
                for (String fieldToMask : recordTypeAndFieldWrap.recordTypesAndFields.get(objectDescribe.getRecordTypeInfos()[0].getRecordTypeId()).fieldsToMask) {
                    Schema.DescribeFieldResult fieldDescription = sObjectFieldMap.get(fieldToMask).getDescribe();
                    Object maskedValue = EncryptUtil.getEncryptedValue(record.get(fieldToMask), fieldDescription, dataTypeName2dataTypeConfig);
                    record.put(fieldToMask, maskedValue);
                }
            }
            recordsToUpdateOrDelete.add(record);
        }
        if (processName == Constants.PROCESS_DELETE) {
            DatabaseUtils.deleteRecords(recordsToUpdateOrDelete, emptyRecycleBin);
        } else {
            DatabaseUtils.updateRecords(recordsToUpdateOrDelete);
        }
    }

    public static void initReportsForResult(Id dcResultId){

        List<ContentVersion> reports = new List<ContentVersion>();

        ContentVersion contentVersionSuccess = new ContentVersion();
        contentVersionSuccess.title = 'DC-Config-0001' + Constants.LITERAL_HYPHEN + Constants.PROCESS_MASK + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_SUCCESS + Constants.PARENT + Constants.LITERAL_HYPHEN + Constants.OBJECT_ACCOUNT + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
        contentVersionSuccess.pathOnClient = contentVersionSuccess.title + Constants.FILE_EXTENSION_CSV;
        contentVersionSuccess.FirstPublishLocationId = dcResultId;
        contentVersionSuccess.VersionData  = Blob.valueOf('Test Success Report');
        contentVersionSuccess.isMajorVersion = false;
        reports.add(contentVersionSuccess);

        ContentVersion contentVersionError = new ContentVersion();
        contentVersionError.title = 'DC-Config-0001' + Constants.LITERAL_HYPHEN + Constants.PROCESS_MASK + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_ERROR + Constants.PARENT + Constants.LITERAL_HYPHEN + Constants.OBJECT_ACCOUNT + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
        contentVersionError.pathOnClient = contentVersionError.title + Constants.FILE_EXTENSION_CSV;
        contentVersionError.FirstPublishLocationId =dcResultId;
        contentVersionError.VersionData  = Blob.valueOf('Test Error Report');
        contentVersionError.isMajorVersion = false;
        reports.add(contentVersionError);

        ContentVersion contentVersionBackup = new ContentVersion();
        contentVersionBackup.title = 'DC-Config-0001' + Constants.LITERAL_HYPHEN + Constants.PROCESS_MASK + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_BACKUP + Constants.PARENT + Constants.LITERAL_HYPHEN + Constants.OBJECT_ACCOUNT + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
        contentVersionBackup.pathOnClient = contentVersionBackup.title + Constants.FILE_EXTENSION_JSON;
        contentVersionBackup.FirstPublishLocationId =dcResultId;
        contentVersionBackup.VersionData  = Blob.valueOf('Test Backup Report');
        contentVersionBackup.isMajorVersion = false;
        reports.add(contentVersionBackup);

        DatabaseUtils.insertRecords(reports);
    }
}