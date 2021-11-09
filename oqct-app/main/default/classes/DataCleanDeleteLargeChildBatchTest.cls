/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-08   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DataCleanDeleteLargeChildBatchTest {

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
        OQCT_DaCl__DC_Configuration__c dcConfig = DataFactory.initDcConfiguration(Constants.DC_ACTION_DELETION_ROLLBACK);
        List<OQCT_DaCl__Related_Object__c> relatedObjects = DataFactory.initRelatedObjectsFromDcConfig(dcConfig);
        // DataFactory.initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(dcConfig, relatedObjects);
        DataFactory.initDataCleansFromDcConfig(dcConfig.Id);
    }

    private static DataCleanSchedulable getDataCleanSchedulable(){
        DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrap.dataConfigurationId = DCConfigurationSelector.getAllDCConfigurations()[0].Id;
        scheduleWrap.batchType = Constants.BATCH_TYPE.BATCH_LARGE_RELATED_DELETE;

        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(scheduleWrap.dataConfigurationId);

        List<OQCT_DaCl__Data_Clean__c> daClrecords = DataCleanSelector.getDataCleanByDcConfigIds(dcConfig.Id);

        scheduleWrap.daClRecId2daClMasterId = new Map<Id, String>();
        for (OQCT_DaCl__Data_Clean__c daClrecord :daClrecords) {
            scheduleWrap.daClRecId2daClMasterId.put(daClrecord.Id, daClrecord.OQCT_DaCl__Master_Id__c);
        }

        Map<String, Id> daClMasterId2daClRecId = new Map<String, Id>();
        for (OQCT_DaCl__Data_Clean__c daClrecord : daClrecords) {
            daClMasterId2daClRecId.put(daClrecord.OQCT_DaCl__Master_Id__c, daClrecord.Id);
        }

        scheduleWrap.parentId2daClRecId = new Map<Id, Id>();
        for(SObject parentRecord: SObjectSelector.getParentRecordByMasterId(dcConfig, new List<String>(daClMasterId2daClRecId.keySet()))){
            String masterId = String.valueOf(parentRecord.get(dcConfig.OQCT_DaCl__Master_Object_Match_By_Field_Name__c));
            if (daClMasterId2daClRecId.containsKey(masterId)){
                scheduleWrap.parentId2daClRecId.put(String.valueOf(parentRecord.get(Constants.FIELD_RECORD_ID)), daClMasterId2daClRecId.get(masterId));
            }
        }
        DataCleanSchedulable dataCleanSchedulable = new DataCleanSchedulable(scheduleWrap);
        return dataCleanSchedulable;
    }

    private static DataCleanSchedulable.ScheduleWrapper modifyScheduleWrapperFor1ChildBatch(DataCleanSchedulable.ScheduleWrapper scheduleWrap){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(scheduleWrap.dataConfigurationId);
        Object dcBatchParams = DataCleanBatchHelper.getBatchParams(scheduleWrap.dataConfigurationId, Constants.BATCH_TYPE.BATCH_DELETE);
        scheduleWrap.dcDeleteLargeChildBatchParams = (DataCleanDeleteBatch.DataCleanDeleteBatchParameters)dcBatchParams;
        scheduleWrap.dcDeleteLargeChildBatchParams.results = ResultsUtil.initialize(scheduleWrap.dcDeleteLargeChildBatchParams.results);
        scheduleWrap.dcDeleteLargeChildBatchParams.processInfo = DataCleanBatchHelper.updateProcessInformation(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo, dcConfig, scheduleWrap.dcDeleteLargeChildBatchParams.processedRelatedObjects);
        scheduleWrap.lookupFieldNames = Utils.getLookupFieldNames(dcConfig.OQCT_DaCl__Master_Object_Name__c, Constants.OBJECT_CONTACT);
        scheduleWrap.recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, scheduleWrap.dcDeleteLargeChildBatchParams.processInfo);
        scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo);
        if (!scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName)) {
            scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName, 1);
            scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.add(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName);
        } else {
            Integer numberOfChildBatchActive = scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.get(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName);
            scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName, numberOfChildBatchActive + 1);
        }
        return scheduleWrap;
    }

    private static DataCleanSchedulable.ScheduleWrapper modifyScheduleWrapperFor2ChildBatch(DataCleanSchedulable.ScheduleWrapper scheduleWrap){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(scheduleWrap.dataConfigurationId);
        Object dcBatchParams = DataCleanBatchHelper.getBatchParams(scheduleWrap.dataConfigurationId, Constants.BATCH_TYPE.BATCH_DELETE);
        scheduleWrap.dcDeleteLargeChildBatchParams = (DataCleanDeleteBatch.DataCleanDeleteBatchParameters)dcBatchParams;
        scheduleWrap.dcDeleteLargeChildBatchParams.results = ResultsUtil.initialize(scheduleWrap.dcDeleteLargeChildBatchParams.results);
        scheduleWrap.dcDeleteLargeChildBatchParams.processInfo = DataCleanBatchHelper.updateProcessInformation(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo, dcConfig, scheduleWrap.dcDeleteLargeChildBatchParams.processedRelatedObjects);
        scheduleWrap.lookupFieldNames = Utils.getLookupFieldNames(dcConfig.OQCT_DaCl__Master_Object_Name__c, Constants.OBJECT_CONTACT);
        scheduleWrap.recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, scheduleWrap.dcDeleteLargeChildBatchParams.processInfo);
        OQCT_DaCl__DC_Result__c result = new OQCT_DaCl__DC_Result__c(Id = scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.resultId);
        result.OQCT_DaCl__Child_Batch_Information_Json__c = JSON.serialize(new Map<String, Integer>{Constants.OBJECT_CONTACT => 1});
        DatabaseUtils.updateRecords(result);
        scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo);
        if (!scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName)) {
            scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName, 1);
            scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.add(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName);
        } else {
            Integer numberOfChildBatchActive = scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.get(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName);
            scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName, numberOfChildBatchActive + 1);
        }
        return scheduleWrap;
    }

    private static DataCleanSchedulable.ScheduleWrapper modifyScheduleWrapperForMultipleChildBatch(DataCleanSchedulable.ScheduleWrapper scheduleWrap){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(scheduleWrap.dataConfigurationId);
        Object dcBatchParams = DataCleanBatchHelper.getBatchParams(scheduleWrap.dataConfigurationId, Constants.BATCH_TYPE.BATCH_DELETE);
        scheduleWrap.dcDeleteLargeChildBatchParams = (DataCleanDeleteBatch.DataCleanDeleteBatchParameters)dcBatchParams;
        scheduleWrap.dcDeleteLargeChildBatchParams.results = ResultsUtil.initialize(scheduleWrap.dcDeleteLargeChildBatchParams.results);
        scheduleWrap.dcDeleteLargeChildBatchParams.processInfo = DataCleanBatchHelper.updateProcessInformation(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo, dcConfig, scheduleWrap.dcDeleteLargeChildBatchParams.processedRelatedObjects);
        scheduleWrap.lookupFieldNames = Utils.getLookupFieldNames(dcConfig.OQCT_DaCl__Master_Object_Name__c, Constants.OBJECT_CONTACT);
        scheduleWrap.recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, scheduleWrap.dcDeleteLargeChildBatchParams.processInfo);
        OQCT_DaCl__DC_Result__c result = new OQCT_DaCl__DC_Result__c(Id = scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.resultId);
        result.OQCT_DaCl__Child_Batch_Information_Json__c = JSON.serialize(new Map<String, Integer>{Constants.OBJECT_CONTACT => 2});
        DatabaseUtils.updateRecords(result);
        scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo);
        if (!scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName)) {
            scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName, 1);
            scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.add(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName);
        } else {
            Integer numberOfChildBatchActive = scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.get(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName);
            scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName, numberOfChildBatchActive + 1);
        }
        return scheduleWrap;
    }

    private static DataCleanSchedulable.ScheduleWrapper modifyScheduleWrapperForParallelChildBatch(DataCleanSchedulable.ScheduleWrapper scheduleWrap){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(scheduleWrap.dataConfigurationId);
        Object dcBatchParams = DataCleanBatchHelper.getBatchParams(scheduleWrap.dataConfigurationId, Constants.BATCH_TYPE.BATCH_DELETE);
        scheduleWrap.dcDeleteLargeChildBatchParams = (DataCleanDeleteBatch.DataCleanDeleteBatchParameters)dcBatchParams;
        scheduleWrap.dcDeleteLargeChildBatchParams.results = ResultsUtil.initialize(scheduleWrap.dcDeleteLargeChildBatchParams.results);
        scheduleWrap.dcDeleteLargeChildBatchParams.processedRelatedObjects.add(Constants.OBJECT_CONTACT);
        scheduleWrap.dcDeleteLargeChildBatchParams.processInfo = DataCleanBatchHelper.updateProcessInformation(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo, dcConfig, scheduleWrap.dcDeleteLargeChildBatchParams.processedRelatedObjects);
        scheduleWrap.lookupFieldNames = Utils.getLookupFieldNames(dcConfig.OQCT_DaCl__Master_Object_Name__c, Constants.OBJECT_OPPORTUNITY);
        scheduleWrap.recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, scheduleWrap.dcDeleteLargeChildBatchParams.processInfo);
        scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo);
        OQCT_DaCl__DC_Result__c result = new OQCT_DaCl__DC_Result__c(Id = scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.resultId);
        result.OQCT_DaCl__Child_Batch_Information_Json__c = JSON.serialize(new Map<String, Integer>{Constants.OBJECT_CONTACT => 1});
        DatabaseUtils.updateRecords(result);
        if (!scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName)) {
            scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName, 1);
            scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.add(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName);
        } else {
            Integer numberOfChildBatchActive = scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.get(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName);
            scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName, numberOfChildBatchActive + 1);
        }
        return scheduleWrap;
    }

    private static DataCleanSchedulable.ScheduleWrapper modifyScheduleWrapperForDeleteChildBatch(DataCleanSchedulable.ScheduleWrapper scheduleWrap){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(scheduleWrap.dataConfigurationId);
        Object dcBatchParams = DataCleanBatchHelper.getBatchParams(scheduleWrap.dataConfigurationId, Constants.BATCH_TYPE.BATCH_DELETE);
        scheduleWrap.dcDeleteLargeChildBatchParams = (DataCleanDeleteBatch.DataCleanDeleteBatchParameters)dcBatchParams;
        scheduleWrap.dcDeleteLargeChildBatchParams.results = ResultsUtil.initialize(scheduleWrap.dcDeleteLargeChildBatchParams.results);
        scheduleWrap.dcDeleteLargeChildBatchParams.processedRelatedObjects.add(Constants.OBJECT_CONTACT);
        scheduleWrap.dcDeleteLargeChildBatchParams.processedRelatedObjects.add(Constants.OBJECT_OPPORTUNITY);
        scheduleWrap.dcDeleteLargeChildBatchParams.processInfo = DataCleanBatchHelper.updateProcessInformation(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo, dcConfig, scheduleWrap.dcDeleteLargeChildBatchParams.processedRelatedObjects);
        scheduleWrap.lookupFieldNames = Utils.getLookupFieldNames(dcConfig.OQCT_DaCl__Master_Object_Name__c, Constants.OBJECT_ATTACHMENT);
        scheduleWrap.recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, scheduleWrap.dcDeleteLargeChildBatchParams.processInfo);
        scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo);
        if (!scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName)) {
            scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName, 1);
            scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.add(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName);
        } else {
            Integer numberOfChildBatchActive = scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.get(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName);
            scheduleWrap.dcDeleteLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.objectName, numberOfChildBatchActive + 1);
        }
        return scheduleWrap;
    }

    @IsTest
    static void deleteLargeBatchTestFor1ChildBatchSuccess(){

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperFor1ChildBatch(dataCleanSchedulable.scheduleWrap);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> deletedAccounts = AccountSelector.getAllAccounts();
        List<Contact> deletedContacts = ContactSelector.getAllContacts();
        List<Opportunity> deletedOpportunities = OpportunitySelector.getAllOpportunities();
        List<Attachment> deletedAttachments = AttachmentSelector.getAllAttachments();

        System.assertNotEquals(0, deletedAccounts.size(), 'Accounts were deleted');

        System.assertEquals(0, deletedContacts.size(), 'Contacts were not deleted');

        System.assertNotEquals(0, deletedOpportunities.size(), 'Opportunities were deleted');

        System.assertNotEquals(0, deletedAttachments.size(), 'Attachments were deleted');

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(1, dcResults.size(), 'Result record count not correct');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c, 'Backup File for parent not null');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for child count not correct');
        System.assertEquals(Constants.DC_STATUS_PENDING, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Status not Pending');
        System.assertEquals(false, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job completed');
        System.assertEquals(4, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Deletion_Completed__c, 'Deletion not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for DC-Config is not Pending');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
        
    }

    @IsTest
    static void deleteLargeBatchTestFor1ChildBatchFailure(){

        DataFactory.initCasesForContacts(ContactSelector.getAllContacts(), 1);

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperFor1ChildBatch(dataCleanSchedulable.scheduleWrap);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> deletedAccounts = AccountSelector.getAllAccounts();
        List<Contact> deletedContacts = ContactSelector.getAllContacts();
        List<Opportunity> deletedOpportunities = OpportunitySelector.getAllOpportunities();
        List<Attachment> deletedAttachments = AttachmentSelector.getAllAttachments();

        System.assertNotEquals(0, deletedAccounts.size(), 'Accounts were deleted');

        System.assertNotEquals(0, deletedContacts.size(), 'Contacts were deleted');

        System.assertNotEquals(0, deletedOpportunities.size(), 'Opportunities were deleted');

        System.assertNotEquals(0, deletedAttachments.size(), 'Attachments were deleted');
        
        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(1, dcResults.size(), 'Result record count not correct');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c, 'Backup File for parent not null');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c, 'Backup File for child not null');
        System.assertEquals(Constants.DC_STATUS_PENDING, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Status not Pending');
        System.assertEquals(false, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job completed');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(4, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Deletion_Completed__c, 'Deletion not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for DC-Config is not Pending');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    static void deleteLargeBatchTestFor2ChildBatch(){

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperFor2ChildBatch(dataCleanSchedulable.scheduleWrap);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> deletedAccounts = AccountSelector.getAllAccounts();
        List<Contact> deletedContacts = ContactSelector.getAllContacts();
        List<Opportunity> deletedOpportunities = OpportunitySelector.getAllOpportunities();
        List<Attachment> deletedAttachments = AttachmentSelector.getAllAttachments();

        System.assertNotEquals(0, deletedAccounts.size(), 'Accounts were deleted');

        System.assertEquals(0, deletedContacts.size(), 'Contacts were not deleted');

        System.assertNotEquals(0, deletedOpportunities.size(), 'Opportunities were deleted');

        System.assertNotEquals(0, deletedAttachments.size(), 'Attachments were deleted');
        
        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(1, dcResults.size(), 'Result record count not correct');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c, 'Backup File for parent not null');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for child count not correct');
        System.assertEquals(Constants.DC_STATUS_PENDING, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Status not Pending');
        System.assertEquals(false, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job completed');
        System.assertEquals(4, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Deletion_Completed__c, 'Deletion not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for DC-Config is not Pending');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    static void deleteLargeBatchTestForMultipleChildBatch(){

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperForMultipleChildBatch(dataCleanSchedulable.scheduleWrap);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> deletedAccounts = AccountSelector.getAllAccounts();
        List<Contact> deletedContacts = ContactSelector.getAllContacts();
        List<Opportunity> deletedOpportunities = OpportunitySelector.getAllOpportunities();
        List<Attachment> deletedAttachments = AttachmentSelector.getAllAttachments();

        System.assertNotEquals(0, deletedAccounts.size(), 'Accounts were deleted');

        System.assertEquals(0, deletedContacts.size(), 'Contacts were not deleted');

        System.assertNotEquals(0, deletedOpportunities.size(), 'Opportunities were deleted');

        System.assertNotEquals(0, deletedAttachments.size(), 'Attachments were deleted');
        
        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();

        System.assertEquals(1, dcResults.size(), 'Result record count not correct');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c, 'Backup File for parent not null');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for child count not correct');
        System.assertEquals(Constants.DC_STATUS_PENDING, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Status not Pending');
        System.assertEquals(false, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job completed');
        System.assertEquals(4, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Deletion_Completed__c, 'Deletion not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for DC-Config is not Pending');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    static void deleteLargeBatchTestForChildBatchInParallel(){

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperForParallelChildBatch(dataCleanSchedulable.scheduleWrap);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> deletedAccounts = AccountSelector.getAllAccounts();
        List<Contact> deletedContacts = ContactSelector.getAllContacts();
        List<Opportunity> deletedOpportunities = OpportunitySelector.getAllOpportunities();
        List<Attachment> deletedAttachments = AttachmentSelector.getAllAttachments();

        System.assertNotEquals(0, deletedAccounts.size(), 'Accounts were deleted');

        System.assertNotEquals(0, deletedContacts.size(), 'Contacts were deleted');

        System.assertEquals(0, deletedOpportunities.size(), 'Opportunities were not deleted');

        System.assertNotEquals(0, deletedAttachments.size(), 'Attachments were deleted');
        
        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(1, dcResults.size(), 'Result record count not correct');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c, 'Backup File for parent not null');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for child count not correct');
        System.assertEquals(Constants.DC_STATUS_PENDING, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Status not Pending');
        System.assertEquals(false, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job completed');
        System.assertEquals(4, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Deletion_Completed__c, 'Deletion not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for DC-Config is not Pending');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    static void deleteLargeBatchTestForChildBatchAllBatchCompleted(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperFor1ChildBatch(dataCleanSchedulable.scheduleWrap);

        DatabaseUtils.deleteRecords(OpportunitySelector.getAllOpportunities());
        DatabaseUtils.deleteRecords(AttachmentSelector.getAllAttachments());
        DatabaseUtils.deleteRecords(RecordTypeAndFieldSelector.getRecordTypeAndFieldForChildByDcConfigIdAndRelatedObjectNameExcluded(dcConfigs[0].Id, Constants.OBJECT_CONTACT));
        DatabaseUtils.deleteRecords(RelatedObjectSelector.getRelatedObjectsByDcConfigIdAndRelatedObjectNamesExcluded(dcConfigs[0].Id, new List<String>{Constants.OBJECT_CONTACT}));
        DatabaseUtils.deleteRecords(DCRelatedResultSelector.getDcRelatedResultsByDcResultIdAndRelatedObjectNameExcluded(dataCleanSchedulable.scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.resultId, Constants.OBJECT_CONTACT));
        DatabaseUtils.deleteRecords(DataCleanRelatedResultSelector.getDataCleanRelatedResultsRelatedObjectNameExcluded(Constants.OBJECT_CONTACT));

        OQCT_DaCl__DC_Result__c result = new OQCT_DaCl__DC_Result__c(Id = dataCleanSchedulable.scheduleWrap.dcDeleteLargeChildBatchParams.processInfo.resultId);
        result.OQCT_DaCl__Is_Parent_Job_Completed__c = true;
        DatabaseUtils.updateRecords(result);

        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        for (OQCT_DaCl__Data_Clean__c dataClean : dataCleans) {
            dataClean.OQCT_DaCl__Is_Parent_Deletion_Completed__c = true;
        }
        DatabaseUtils.updateRecords(dataCleans);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> deletedAccounts = AccountSelector.getAllAccounts();
        List<Contact> deletedContacts = ContactSelector.getAllContacts();

        System.assertNotEquals(0, deletedAccounts.size(), 'Accounts were deleted');

        System.assertEquals(0, deletedContacts.size(), 'Contacts were not deleted');

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(1, dcResults.size(), 'Result record count not correct');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c, 'Backup File for parent not null');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for child count not correct');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Status not Success');
        System.assertEquals(true, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job not completed');
        System.assertEquals(4, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Deletion_Completed__c, 'Deletion not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PARTIAL_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for Data Clean is not Partial Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Deletion_Status__c, 'Overall Deletion Status for DC-Config is not Success');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
        
    }

}