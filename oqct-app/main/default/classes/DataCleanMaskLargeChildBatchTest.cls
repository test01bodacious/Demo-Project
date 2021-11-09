/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-19
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-08   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DataCleanMaskLargeChildBatchTest {

    @TestSetup
    private static void setupData(){
        // Insert Standard Salesforce Objects
        List<Account> accounts = DataFactory.initAccounts();
        DataFactory.initContactsForAccounts(accounts);
        DataFactory.initOpportunitiesForAccounts(accounts);
        //DataFactory.initCasesForAccounts(accounts);
        DataFactory.initAttachmentsForAccounts(accounts);

        // Insert Custom Data Clean App Objects
        DataFactory.initDataCleanAppConfigurations();
        DataFactory.initDcDataTypes();
        OQCT_DaCl__DC_Configuration__c dcConfig = DataFactory.initDcConfiguration();
        List<OQCT_DaCl__Related_Object__c> relatedObjects = DataFactory.initRelatedObjectsFromDcConfig(dcConfig);
        DataFactory.initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(dcConfig, relatedObjects);
        DataFactory.initDataCleansFromDcConfig(dcConfig.Id);
    }

    private static DataCleanSchedulable getDataCleanSchedulable(){
        DataCleanSchedulable.ScheduleWrapper scheduleWrap = new DataCleanSchedulable.ScheduleWrapper();
        scheduleWrap.dataConfigurationId = DCConfigurationSelector.getAllDCConfigurations()[0].Id;
        scheduleWrap.batchType = Constants.BATCH_TYPE.BATCH_LARGE_RELATED_MASK;

        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(scheduleWrap.dataConfigurationId);

        List<OQCT_DaCl__Data_Clean__c> daClrecords = DataCleanSelector.getDataCleanByDcConfigIds(dcConfig.Id);

        scheduleWrap.daClRecId2daClMasterId = new Map<Id, String>();
        for (OQCT_DaCl__Data_Clean__c daClrecord : daClrecords) {
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
        Object dcBatchParams = DataCleanBatchHelper.getBatchParams(scheduleWrap.dataConfigurationId, Constants.BATCH_TYPE.BATCH_MASK);
        scheduleWrap.dcMaskLargeChildBatchParams = (DataCleanMaskBatch.DataCleanMaskBatchParameters)dcBatchParams;
        scheduleWrap.dcMaskLargeChildBatchParams.results = ResultsUtil.initialize(scheduleWrap.dcMaskLargeChildBatchParams.results);
        scheduleWrap.dcMaskLargeChildBatchParams.processInfo = DataCleanBatchHelper.updateProcessInformation(scheduleWrap.dcMaskLargeChildBatchParams.processInfo, dcConfig, scheduleWrap.dcMaskLargeChildBatchParams.processedRelatedObjects);
        scheduleWrap.lookupFieldNames = Utils.getLookupFieldNames(dcConfig.OQCT_DaCl__Master_Object_Name__c, Constants.OBJECT_CONTACT);
        scheduleWrap.recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, scheduleWrap.dcMaskLargeChildBatchParams.processInfo);
        scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(scheduleWrap.dcMaskLargeChildBatchParams.processInfo);
        if (!scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName)) {
            scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName, 1);
            scheduleWrap.dcMaskLargeChildBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.add(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName);
        } else {
            Integer numberOfChildBatchActive = scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.get(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName);
            scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName, numberOfChildBatchActive + 1);
        }
        return scheduleWrap;
    }

    private static DataCleanSchedulable.ScheduleWrapper modifyScheduleWrapperFor2ChildBatch(DataCleanSchedulable.ScheduleWrapper scheduleWrap){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(scheduleWrap.dataConfigurationId);
        Object dcBatchParams = DataCleanBatchHelper.getBatchParams(scheduleWrap.dataConfigurationId, Constants.BATCH_TYPE.BATCH_MASK);
        scheduleWrap.dcMaskLargeChildBatchParams = (DataCleanMaskBatch.DataCleanMaskBatchParameters)dcBatchParams;
        scheduleWrap.dcMaskLargeChildBatchParams.results = ResultsUtil.initialize(scheduleWrap.dcMaskLargeChildBatchParams.results);
        scheduleWrap.dcMaskLargeChildBatchParams.processInfo = DataCleanBatchHelper.updateProcessInformation(scheduleWrap.dcMaskLargeChildBatchParams.processInfo, dcConfig, scheduleWrap.dcMaskLargeChildBatchParams.processedRelatedObjects);
        scheduleWrap.lookupFieldNames = Utils.getLookupFieldNames(dcConfig.OQCT_DaCl__Master_Object_Name__c, Constants.OBJECT_CONTACT);
        scheduleWrap.recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, scheduleWrap.dcMaskLargeChildBatchParams.processInfo);
        OQCT_DaCl__DC_Result__c result = new OQCT_DaCl__DC_Result__c(Id = scheduleWrap.dcMaskLargeChildBatchParams.processInfo.resultId);
        result.OQCT_DaCl__Child_Batch_Information_Json__c = JSON.serialize(new Map<String, Integer>{Constants.OBJECT_CONTACT => 1});
        DatabaseUtils.updateRecords(result);
        scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(scheduleWrap.dcMaskLargeChildBatchParams.processInfo);
        if (!scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName)) {
            scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName, 1);
            scheduleWrap.dcMaskLargeChildBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.add(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName);
        } else {
            Integer numberOfChildBatchActive = scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.get(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName);
            scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName, numberOfChildBatchActive + 1);
        }
        return scheduleWrap;
    }

    private static DataCleanSchedulable.ScheduleWrapper modifyScheduleWrapperForMultipleChildBatch(DataCleanSchedulable.ScheduleWrapper scheduleWrap){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(scheduleWrap.dataConfigurationId);
        Object dcBatchParams = DataCleanBatchHelper.getBatchParams(scheduleWrap.dataConfigurationId, Constants.BATCH_TYPE.BATCH_MASK);
        scheduleWrap.dcMaskLargeChildBatchParams = (DataCleanMaskBatch.DataCleanMaskBatchParameters)dcBatchParams;
        scheduleWrap.dcMaskLargeChildBatchParams.results = ResultsUtil.initialize(scheduleWrap.dcMaskLargeChildBatchParams.results);
        scheduleWrap.dcMaskLargeChildBatchParams.processInfo = DataCleanBatchHelper.updateProcessInformation(scheduleWrap.dcMaskLargeChildBatchParams.processInfo, dcConfig, scheduleWrap.dcMaskLargeChildBatchParams.processedRelatedObjects);
        scheduleWrap.lookupFieldNames = Utils.getLookupFieldNames(dcConfig.OQCT_DaCl__Master_Object_Name__c, Constants.OBJECT_CONTACT);
        scheduleWrap.recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, scheduleWrap.dcMaskLargeChildBatchParams.processInfo);
        OQCT_DaCl__DC_Result__c result = new OQCT_DaCl__DC_Result__c(Id = scheduleWrap.dcMaskLargeChildBatchParams.processInfo.resultId);
        result.OQCT_DaCl__Child_Batch_Information_Json__c = JSON.serialize(new Map<String, Integer>{Constants.OBJECT_CONTACT => 2});
        DatabaseUtils.updateRecords(result);
        scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(scheduleWrap.dcMaskLargeChildBatchParams.processInfo);
        if (!scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName)) {
            scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName, 1);
            scheduleWrap.dcMaskLargeChildBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.add(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName);
        } else {
            Integer numberOfChildBatchActive = scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.get(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName);
            scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName, numberOfChildBatchActive + 1);
        }
        return scheduleWrap;
    }

    private static DataCleanSchedulable.ScheduleWrapper modifyScheduleWrapperForParallelChildBatch(DataCleanSchedulable.ScheduleWrapper scheduleWrap){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(scheduleWrap.dataConfigurationId);
        Object dcBatchParams = DataCleanBatchHelper.getBatchParams(scheduleWrap.dataConfigurationId, Constants.BATCH_TYPE.BATCH_MASK);
        scheduleWrap.dcMaskLargeChildBatchParams = (DataCleanMaskBatch.DataCleanMaskBatchParameters)dcBatchParams;
        scheduleWrap.dcMaskLargeChildBatchParams.results = ResultsUtil.initialize(scheduleWrap.dcMaskLargeChildBatchParams.results);
        scheduleWrap.dcMaskLargeChildBatchParams.processedRelatedObjects.add(Constants.OBJECT_CONTACT);
        scheduleWrap.dcMaskLargeChildBatchParams.processInfo = DataCleanBatchHelper.updateProcessInformation(scheduleWrap.dcMaskLargeChildBatchParams.processInfo, dcConfig, scheduleWrap.dcMaskLargeChildBatchParams.processedRelatedObjects);
        scheduleWrap.lookupFieldNames = Utils.getLookupFieldNames(dcConfig.OQCT_DaCl__Master_Object_Name__c, Constants.OBJECT_OPPORTUNITY);
        scheduleWrap.recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, scheduleWrap.dcMaskLargeChildBatchParams.processInfo);
        scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(scheduleWrap.dcMaskLargeChildBatchParams.processInfo);
        OQCT_DaCl__DC_Result__c result = new OQCT_DaCl__DC_Result__c(Id = scheduleWrap.dcMaskLargeChildBatchParams.processInfo.resultId);
        result.OQCT_DaCl__Child_Batch_Information_Json__c = JSON.serialize(new Map<String, Integer>{Constants.OBJECT_CONTACT => 1});
        DatabaseUtils.updateRecords(result);
        if (!scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName)) {
            scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName, 1);
            scheduleWrap.dcMaskLargeChildBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.add(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName);
        } else {
            Integer numberOfChildBatchActive = scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.get(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName);
            scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName, numberOfChildBatchActive + 1);
        }
        return scheduleWrap;
    }

    private static DataCleanSchedulable.ScheduleWrapper modifyScheduleWrapperForDeleteChildBatch(DataCleanSchedulable.ScheduleWrapper scheduleWrap){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationById(scheduleWrap.dataConfigurationId);
        Object dcBatchParams = DataCleanBatchHelper.getBatchParams(scheduleWrap.dataConfigurationId, Constants.BATCH_TYPE.BATCH_MASK);
        scheduleWrap.dcMaskLargeChildBatchParams = (DataCleanMaskBatch.DataCleanMaskBatchParameters)dcBatchParams;
        scheduleWrap.dcMaskLargeChildBatchParams.results = ResultsUtil.initialize(scheduleWrap.dcMaskLargeChildBatchParams.results);
        scheduleWrap.dcMaskLargeChildBatchParams.processedRelatedObjects.add(Constants.OBJECT_CONTACT);
        scheduleWrap.dcMaskLargeChildBatchParams.processedRelatedObjects.add(Constants.OBJECT_OPPORTUNITY);
        scheduleWrap.dcMaskLargeChildBatchParams.processInfo = DataCleanBatchHelper.updateProcessInformation(scheduleWrap.dcMaskLargeChildBatchParams.processInfo, dcConfig, scheduleWrap.dcMaskLargeChildBatchParams.processedRelatedObjects);
        scheduleWrap.lookupFieldNames = Utils.getLookupFieldNames(dcConfig.OQCT_DaCl__Master_Object_Name__c, Constants.OBJECT_ATTACHMENT);
        scheduleWrap.recordTypeAndFieldWrap = DataCleanBatchHelper.getRecordsTypeAndFieldInfo(dcConfig, scheduleWrap.dcMaskLargeChildBatchParams.processInfo);
        scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive = DataCleanBatchHelper.getRelatedObjectName2numberOfChildBatchActive(scheduleWrap.dcMaskLargeChildBatchParams.processInfo);
        if (!scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.containsKey(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName)) {
            scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName, 1);
            scheduleWrap.dcMaskLargeChildBatchParams.processInfo.childObjectsProcessingInSeparateChildBatch.add(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName);
        } else {
            Integer numberOfChildBatchActive = scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.get(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName);
            scheduleWrap.dcMaskLargeChildBatchParams.relatedObjectName2numberOfChildBatchActive.put(scheduleWrap.dcMaskLargeChildBatchParams.processInfo.objectName, numberOfChildBatchActive + 1);
        }
        return scheduleWrap;
    }

    @IsTest
    static void maskLargeBatchTestFor1ChildBatchSuccess(){

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperFor1ChildBatch(dataCleanSchedulable.scheduleWrap);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertEquals(oldAccount.Name, maskedAccount.Name, 'Account Name is masked');
            System.assertEquals(oldAccount.Phone, maskedAccount.Phone, 'Account Phone is masked');
            System.assertEquals(oldAccount.Industry, maskedAccount.Industry, 'Account Industry is masked');
            System.assertEquals(oldAccount.Rating, maskedAccount.Rating, 'Account Rating is masked');
            System.assertEquals(oldAccount.NumberOfEmployees, maskedAccount.NumberOfEmployees, 'Account Employees is masked');
            System.assertEquals(oldAccount.Website, maskedAccount.Website, 'Account Website is masked');
            System.assertNotEquals(null, maskedAccount.Description, 'Account Description is emptied');

            for (Integer j = 0;  j < maskedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact maskedContact = maskedAccount.contacts[j];

                System.assertNotEquals(maskedContact.FirstName, oldContact.FirstName, 'Contact First Name is not masked');
                System.assertNotEquals(maskedContact.LastName, oldContact.LastName, 'Contact Last Name is not masked');
                System.assertNotEquals(maskedContact.Email, oldContact.Email, 'Contact Email is not masked');
                System.assertNotEquals(maskedContact.Phone, oldContact.Phone, 'Contact Phone is not masked');
                System.assertEquals(null, maskedContact.Description, 'Contact Description is not emptied');
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

            System.assertNotEquals(0, maskedAccount.Attachments.size(), 'Attachments were deleted');
        }

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
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Pending');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
        
    }

    @IsTest
    static void maskLargeBatchTestFor1ChildBatchFailure(){

        OQCT_DaCl__DC_Data_Type__c dcDataTypeText = DCDataTypeSelector.getDCDataTypeText();
        dcDataTypeText.OQCT_DaCl__Custom_Length__c = 255;
        dcDataTypeText.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        DatabaseUtils.updateRecords(dcDataTypeText);

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperFor1ChildBatch(dataCleanSchedulable.scheduleWrap);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertEquals(oldAccount.Name, maskedAccount.Name, 'Account Name is masked');
            System.assertEquals(oldAccount.Phone, maskedAccount.Phone, 'Account Phone is masked');
            System.assertEquals(oldAccount.Industry, maskedAccount.Industry, 'Account Industry is masked');
            System.assertEquals(oldAccount.Rating, maskedAccount.Rating, 'Account Rating is masked');
            System.assertEquals(oldAccount.NumberOfEmployees, maskedAccount.NumberOfEmployees, 'Account Employees is masked');
            System.assertEquals(oldAccount.Website, maskedAccount.Website, 'Account Website is masked');
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

                System.assertEquals(oldOpportunity.Name, maskedOpportunity.Name, 'Opportunity Name is masked');
                System.assertEquals(oldOpportunity.StageName, maskedOpportunity.StageName, 'Opportunity Stage is masked');
                System.assertEquals(oldOpportunity.CloseDate, maskedOpportunity.CloseDate, 'Opportunity Close Date is masked');
                System.assertEquals(oldOpportunity.Amount, maskedOpportunity.Amount, 'Opportunity Amount is masked');
                System.assertEquals(oldOpportunity.Probability, maskedOpportunity.Probability, 'Opportunity Probability is masked');
                System.assertNotEquals(null, maskedOpportunity.Description, 'Opportunity Description is emptied');
            }

            System.assertNotEquals(0, maskedAccount.Attachments.size(), 'Attachments were deleted');
        }
        
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
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Pending');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    static void maskLargeBatchTestFor1ChildBatchDelete(){

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperForDeleteChildBatch(dataCleanSchedulable.scheduleWrap);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertEquals(oldAccount.Name, maskedAccount.Name, 'Account Name is masked');
            System.assertEquals(oldAccount.Phone, maskedAccount.Phone, 'Account Phone is masked');
            System.assertEquals(oldAccount.Industry, maskedAccount.Industry, 'Account Industry is masked');
            System.assertEquals(oldAccount.Rating, maskedAccount.Rating, 'Account Rating is masked');
            System.assertEquals(oldAccount.NumberOfEmployees, maskedAccount.NumberOfEmployees, 'Account Employees is masked');
            System.assertEquals(oldAccount.Website, maskedAccount.Website, 'Account Website is masked');
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
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Pending');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    static void maskLargeBatchTestFor2ChildBatch(){

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperFor2ChildBatch(dataCleanSchedulable.scheduleWrap);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertEquals(oldAccount.Name, maskedAccount.Name, 'Account Name is masked');
            System.assertEquals(oldAccount.Phone, maskedAccount.Phone, 'Account Phone is masked');
            System.assertEquals(oldAccount.Industry, maskedAccount.Industry, 'Account Industry is masked');
            System.assertEquals(oldAccount.Rating, maskedAccount.Rating, 'Account Rating is masked');
            System.assertEquals(oldAccount.NumberOfEmployees, maskedAccount.NumberOfEmployees, 'Account Employees is masked');
            System.assertEquals(oldAccount.Website, maskedAccount.Website, 'Account Website is masked');
            System.assertNotEquals(null, maskedAccount.Description, 'Account Description is emptied');

            for (Integer j = 0;  j < maskedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact maskedContact = maskedAccount.contacts[j];

                System.assertNotEquals(maskedContact.FirstName, oldContact.FirstName, 'Contact First Name is not masked');
                System.assertNotEquals(maskedContact.LastName, oldContact.LastName, 'Contact Last Name is not masked');
                System.assertNotEquals(maskedContact.Email, oldContact.Email, 'Contact Email is not masked');
                System.assertNotEquals(maskedContact.Phone, oldContact.Phone, 'Contact Phone is not masked');
                System.assertEquals(null, maskedContact.Description, 'Contact Description is not emptied');
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

            System.assertNotEquals(0, maskedAccount.Attachments.size(), 'Attachments were deleted');
        }
        
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
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Pending');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    static void maskLargeBatchTestForMultipleChildBatch(){

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperForMultipleChildBatch(dataCleanSchedulable.scheduleWrap);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertEquals(oldAccount.Name, maskedAccount.Name, 'Account Name is masked');
            System.assertEquals(oldAccount.Phone, maskedAccount.Phone, 'Account Phone is masked');
            System.assertEquals(oldAccount.Industry, maskedAccount.Industry, 'Account Industry is masked');
            System.assertEquals(oldAccount.Rating, maskedAccount.Rating, 'Account Rating is masked');
            System.assertEquals(oldAccount.NumberOfEmployees, maskedAccount.NumberOfEmployees, 'Account Employees is masked');
            System.assertEquals(oldAccount.Website, maskedAccount.Website, 'Account Website is masked');
            System.assertNotEquals(null, maskedAccount.Description, 'Account Description is emptied');

            for (Integer j = 0;  j < maskedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact maskedContact = maskedAccount.contacts[j];

                System.assertNotEquals(maskedContact.FirstName, oldContact.FirstName, 'Contact First Name is not masked');
                System.assertNotEquals(maskedContact.LastName, oldContact.LastName, 'Contact Last Name is not masked');
                System.assertNotEquals(maskedContact.Email, oldContact.Email, 'Contact Email is not masked');
                System.assertNotEquals(maskedContact.Phone, oldContact.Phone, 'Contact Phone is not masked');
                System.assertEquals(null, maskedContact.Description, 'Contact Description is not emptied');
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

            System.assertNotEquals(0, maskedAccount.Attachments.size(), 'Attachments were deleted');
        }
        
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
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Pending');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    static void maskLargeBatchTestForChildBatchInParallel(){

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperForParallelChildBatch(dataCleanSchedulable.scheduleWrap);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertEquals(oldAccount.Name, maskedAccount.Name, 'Account Name is masked');
            System.assertEquals(oldAccount.Phone, maskedAccount.Phone, 'Account Phone is masked');
            System.assertEquals(oldAccount.Industry, maskedAccount.Industry, 'Account Industry is masked');
            System.assertEquals(oldAccount.Rating, maskedAccount.Rating, 'Account Rating is masked');
            System.assertEquals(oldAccount.NumberOfEmployees, maskedAccount.NumberOfEmployees, 'Account Employees is masked');
            System.assertEquals(oldAccount.Website, maskedAccount.Website, 'Account Website is masked');
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

                System.assertNotEquals(maskedOpportunity.Name, oldOpportunity.Name, 'Opportunity Name is not masked');
                System.assertNotEquals(maskedOpportunity.StageName, oldOpportunity.StageName, 'Opportunity Stage is not masked');
                System.assertNotEquals(maskedOpportunity.CloseDate, oldOpportunity.CloseDate, 'Opportunity Close Date is not masked');
                System.assertNotEquals(maskedOpportunity.Amount, oldOpportunity.Amount, 'Opportunity Amount is not masked');
                System.assertNotEquals(maskedOpportunity.Probability, oldOpportunity.Probability, 'Opportunity Probability is not masked');
                System.assertEquals(null, maskedOpportunity.Description, 'Opportunity Description is not emptied');
            }

            System.assertNotEquals(0, maskedAccount.Attachments.size(), 'Attachments were deleted');
        }
        
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
        System.assertEquals(false, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PENDING, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Pending');

        // DC-Config Field updates assertions
        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_PENDING, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Pending');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
    }

    @IsTest
    static void maskLargeBatchTestForChildBatchAllBatchCompleted(){

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();

        List<Account> oldAccounts = AccountSelector.getAllAccountsWithChilds();

        DataCleanSchedulable dataCleanSchedulable = getDataCleanSchedulable();
        dataCleanSchedulable.scheduleWrap = modifyScheduleWrapperFor1ChildBatch(dataCleanSchedulable.scheduleWrap);

        DatabaseUtils.deleteRecords(OpportunitySelector.getAllOpportunities());
        DatabaseUtils.deleteRecords(AttachmentSelector.getAllAttachments());
        DatabaseUtils.deleteRecords(RecordTypeAndFieldSelector.getRecordTypeAndFieldForChildByDcConfigIdAndRelatedObjectNameExcluded(dcConfigs[0].Id, Constants.OBJECT_CONTACT));
        DatabaseUtils.deleteRecords(RelatedObjectSelector.getRelatedObjectsByDcConfigIdAndRelatedObjectNamesExcluded(dcConfigs[0].Id, new List<String>{Constants.OBJECT_CONTACT}));
        DatabaseUtils.deleteRecords(DCRelatedResultSelector.getDcRelatedResultsByDcResultIdAndRelatedObjectNameExcluded(dataCleanSchedulable.scheduleWrap.dcMaskLargeChildBatchParams.processInfo.resultId, Constants.OBJECT_CONTACT));
        DatabaseUtils.deleteRecords(DataCleanRelatedResultSelector.getDataCleanRelatedResultsRelatedObjectNameExcluded(Constants.OBJECT_CONTACT));

        OQCT_DaCl__DC_Result__c result = new OQCT_DaCl__DC_Result__c(Id = dataCleanSchedulable.scheduleWrap.dcMaskLargeChildBatchParams.processInfo.resultId);
        result.OQCT_DaCl__Is_Parent_Job_Completed__c = true;
        DatabaseUtils.updateRecords(result);

        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getAllDataCleans();
        for (OQCT_DaCl__Data_Clean__c dataClean : dataCleans) {
            dataClean.OQCT_DaCl__Is_Parent_Masking_Completed__c = true;
        }
        DatabaseUtils.updateRecords(dataCleans);
        
        Test.startTest();
        dataCleanSchedulable.execute(null);
        Test.stopTest();

        List<Account> maskedaccounts = AccountSelector.getAllAccountsWithChilds();

        for (Integer i = 0;  i < maskedaccounts.size(); i++) {

            Account oldAccount = oldAccounts[i];
            Account maskedAccount = maskedAccounts[i];

            System.assertEquals(oldAccount.Name, maskedAccount.Name, 'Account Name is masked');
            System.assertEquals(oldAccount.Phone, maskedAccount.Phone, 'Account Phone is masked');
            System.assertEquals(oldAccount.Industry, maskedAccount.Industry, 'Account Industry is masked');
            System.assertEquals(oldAccount.Rating, maskedAccount.Rating, 'Account Rating is masked');
            System.assertEquals(oldAccount.NumberOfEmployees, maskedAccount.NumberOfEmployees, 'Account Employees is masked');
            System.assertEquals(oldAccount.Website, maskedAccount.Website, 'Account Website is masked');
            System.assertNotEquals(null, maskedAccount.Description, 'Account Description is emptied');

            for (Integer j = 0;  j < maskedAccount.contacts.size(); j++) {
                Contact oldContact = oldAccount.contacts[j];
                Contact maskedContact = maskedAccount.contacts[j];

                System.assertNotEquals(maskedContact.FirstName, oldContact.FirstName, 'Contact First Name is not masked');
                System.assertNotEquals(maskedContact.LastName, oldContact.LastName, 'Contact Last Name is not masked');
                System.assertNotEquals(maskedContact.Email, oldContact.Email, 'Contact Email is not masked');
                System.assertNotEquals(maskedContact.Phone, oldContact.Phone, 'Contact Phone is not masked');
                System.assertEquals(null, maskedContact.Description, 'Contact Description is not emptied');
            }
        }

        // DC-Result Field updates assertions
        List<OQCT_DaCl__DC_Result__c> dcResults = DCResultSelector.getAllDcResults();
        System.assertEquals(2, dcResults.size(), 'Result record count not correct');
        System.assertEquals(null, dcResults[0].OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c, 'Backup File for parent not null');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR).size(), 'Backup File for child count not correct');
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcResults[0].OQCT_DaCl__Overall_Result__c, 'Overall Status not Success');
        System.assertEquals(true, dcResults[0].OQCT_DaCl__Is_All_Job_Completed__c, 'Overall Job not completed');
        System.assertEquals(4, dcResults[0].OQCT_DaCl__Total_Success__c, 'Total Success count is not correct');
        System.assertEquals(0, dcResults[0].OQCT_DaCl__Total_Failure__c, 'Total Failure count is not correct');
        System.assertEquals(1, dcResults[0].OQCT_DaCl__Total_Backup_files__c, 'Backup file count is not correct');

        // Data Clean Field updates assertions
        dataCleans = DataCleanSelector.getAllDataCleans();
        System.assertEquals(true, dataCleans[0].OQCT_DaCl__Is_Masking_Completed__c, 'Masking not Complete on Data Clean');
        System.assertEquals(Constants.DC_STATUS_PARTIAL_SUCCESS, dataCleans[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for Data Clean is not Partial Success');

        // DC-Config Field updates assertions
        dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        System.assertEquals(Constants.DC_STATUS_SUCCESS, dcConfigs[0].OQCT_DaCl__Overall_Masking_Status__c, 'Overall Masking Status for DC-Config is not Success');
        System.assertEquals(4, dcConfigs[0].OQCT_DaCl__Overall_Success_Masking__c, 'Overall Success (Masking) for DC-Config is not correct');
        System.assertEquals(0, dcConfigs[0].OQCT_DaCl__Overall_Success_Deletion__c, 'Overall Success (Deletion) for DC-Config is not correct');
        
    }

}