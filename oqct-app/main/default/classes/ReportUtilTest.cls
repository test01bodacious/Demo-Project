/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-26
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-06   Krrish Joy   Initial Version
**/
@isTest
private with sharing class ReportUtilTest {

    private static OQCT_DaCl__DC_Configuration__c config = new OQCT_DaCl__DC_Configuration__c();
    private static OQCT_DaCl__Data_Clean__c dataCleanObj = new OQCT_DaCl__Data_Clean__c();
    private static Account objAccount = new Account();
    
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

        dcConfig = DCConfigurationSelector.getDCConfigurationById(dcConfig.Id);

        List<OQCT_DaCl__Related_Object__c> relatedObjects = DataFactory.initRelatedObjectsFromDcConfig(dcConfig);
        DataFactory.initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(dcConfig, relatedObjects);
        DataFactory.initDataCleansFromDcConfig(dcConfig.Id);

        DataCleanRollbackController.updateDcConfigAndCreateResult(dcConfig, Constants.PROCESS_ROLLBACK);

        List<OQCT_DaCl__DC_Configuration__c> dcConfigs = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getAllDcResults()[0];

        DataFactory.insertBackups(dcConfig, dcResult, false, false, false);
    }

    @IsTest
    private static void prepareSuccessReportTest(){        
		objAccount = AccountSelector.getAllAccounts()[0];
        ReportUtil.SuccessReportInfoWrapper successWrapper = new ReportUtil.SuccessReportInfoWrapper();
        successWrapper.masterId = '1';
        successWrapper.recordId = objAccount.Id;
        
        DataCleanBatchHelper.ProcessInformation processInfo = new DataCleanBatchHelper.ProcessInformation();
        processInfo.isParent = true;
        
        ReportUtil.SuccessReportInfo reportInfo = new ReportUtil.SuccessReportInfo();
        reportInfo.successReportInfoWraps = new List<ReportUtil.SuccessReportInfoWrapper>{successWrapper};
        reportInfo.processInfo = processInfo;
        
        ReportUtil.SuccessReport successReport = new ReportUtil.SuccessReport(); 
        
        Test.startTest();
            ReportUtil.SuccessReport result = ReportUtil.prepareSuccessReport(reportInfo, successReport);
        Test.stopTest();

        System.assertEquals(true, result != null, 'Success report is null.');
    }
    
    @IsTest
    private static void saveSuccessReportTest(){        
		objAccount = AccountSelector.getAllAccounts()[0];
        ReportUtil.SuccessReportInfoWrapper successWrapper = new ReportUtil.SuccessReportInfoWrapper();
        successWrapper.masterId = '1';
        successWrapper.recordId = objAccount.Id;
        
        DataCleanBatchHelper.ProcessInformation processInfo = new DataCleanBatchHelper.ProcessInformation();
        processInfo.isParent = true;
        
        ReportUtil.SuccessReportInfo reportInfo = new ReportUtil.SuccessReportInfo();
        reportInfo.successReportInfoWraps = new List<ReportUtil.SuccessReportInfoWrapper>{successWrapper};
        reportInfo.processInfo = processInfo;
        
        ReportUtil.SuccessReport successReport = new ReportUtil.SuccessReport();

        Map<String, Object> header2rowValue1 = new Map<String, Object>{'Header' => 'Test1'};
        Map<String, Object> header2rowValue2 = new Map<String, Object>{'Header' => 'Test2'};
        List<Map<String, Object>> rows = new List<Map<String, Object>>{header2rowValue1, header2rowValue2};

        successReport.successReportContent  = new CSVBuilder();
        successReport.successReportContent = CSVBuilder.getRowsAndHeadersAsCsv(successReport.successReportContent, rows, new List<String>{'Header'});

        header2rowValue1 = new Map<String, Object>{'Header' => 'Test3'};
        header2rowValue2 = new Map<String, Object>{'Header' => 'Test4'};
        rows = new List<Map<String, Object>>{header2rowValue1, header2rowValue2};

        successReport.successReportContent = CSVBuilder.getRowsAndHeadersAsCsv(successReport.successReportContent, rows, new List<String>{'Header'});

        header2rowValue1 = new Map<String, Object>{'Header' => 'Test5'};
        header2rowValue2 = new Map<String, Object>{'Header' => 'Test6'};
        rows = new List<Map<String, Object>>{header2rowValue1, header2rowValue2};

        successReport.successReportContent = CSVBuilder.getRowsAndHeadersAsCsv(successReport.successReportContent, rows, new List<String>{'Header'});
        
        Test.startTest();
            ReportUtil.SuccessReport result = ReportUtil.saveSuccessReport(successReport, processInfo);
        Test.stopTest();

        System.assertEquals(true, result != null, 'Success report is null.');
    }
    
    @IsTest
    private static void prepareSuccessReportForNullValueTest(){        
		objAccount = AccountSelector.getAllAccounts()[0];
        ReportUtil.SuccessReportInfoWrapper successWrapper = new ReportUtil.SuccessReportInfoWrapper();
        successWrapper.masterId = '1';
        successWrapper.recordId = objAccount.Id;
        
        DataCleanBatchHelper.ProcessInformation processInfo = new DataCleanBatchHelper.ProcessInformation();
        processInfo.isParent = true;
        
        ReportUtil.SuccessReportInfo reportInfo = new ReportUtil.SuccessReportInfo();
        reportInfo.successReportInfoWraps = new List<ReportUtil.SuccessReportInfoWrapper>{successWrapper};
        reportInfo.processInfo = processInfo;
        
        ReportUtil.SuccessReport successReport = new ReportUtil.SuccessReport(); 
        
        Test.startTest();
            ReportUtil.SuccessReport result = ReportUtil.prepareSuccessReport(reportInfo, null);
        Test.stopTest();

        System.assertEquals(true, result != null, 'Success report is null.');
    }
    
    @IsTest
    private static void prepareErrorReportTest(){        
		objAccount = AccountSelector.getAllAccounts()[0];
        
        Database.SaveResult saveResult = (Database.SaveResult) JSON.deserialize('{"success":false, "errors":[{"message":"Error occured","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.Class);
        List<Database.Error> errors = saveResult.getErrors();
        
        ReportUtil.ErrorReportInfoWrapper errorWrapper = new ReportUtil.ErrorReportInfoWrapper();
        errorWrapper.masterId = '1';
        errorWrapper.recordId = objAccount.Id;
        errorWrapper.errors = errors;
        
        DataCleanBatchHelper.ProcessInformation processInfo = new DataCleanBatchHelper.ProcessInformation();
        processInfo.isParent = true;
        
        ReportUtil.ErrorReportInfo reportInfo = new ReportUtil.ErrorReportInfo();
        reportInfo.errorReportInfoWraps = new List<ReportUtil.ErrorReportInfoWrapper>{errorWrapper};
        reportInfo.processInfo = processInfo;
        
        ReportUtil.ErrorReport errorReport = new ReportUtil.ErrorReport(); 
        
        Test.startTest();
            ReportUtil.ErrorReport result = ReportUtil.prepareErrorReport(reportInfo, errorReport);
        Test.stopTest();

        System.assertEquals(true, result != null, 'Error report is null.');
    }
    
    @IsTest
    private static void saveErrorReportTest(){        
		objAccount = AccountSelector.getAllAccounts()[0];
        
        Database.SaveResult saveResult = (Database.SaveResult) JSON.deserialize('{"success":false, "errors":[{"message":"Error occured","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.Class);
        List<Database.Error> errors = saveResult.getErrors();
        
        ReportUtil.ErrorReportInfoWrapper errorWrapper = new ReportUtil.ErrorReportInfoWrapper();
        errorWrapper.masterId = '1';
        errorWrapper.recordId = objAccount.Id;
        errorWrapper.errors = errors;
        
        DataCleanBatchHelper.ProcessInformation processInfo = new DataCleanBatchHelper.ProcessInformation();
        processInfo.isParent = true;
        
        ReportUtil.ErrorReportInfo reportInfo = new ReportUtil.ErrorReportInfo();
        reportInfo.errorReportInfoWraps = new List<ReportUtil.ErrorReportInfoWrapper>{errorWrapper};
        reportInfo.processInfo = processInfo;
        
        ReportUtil.ErrorReport errorReport = new ReportUtil.ErrorReport(); 

        Map<String, Object> header2rowValue = new Map<String, Object>{'Header' => 'Test'};
        List<Map<String, Object>> rows = new List<Map<String, Object>>{header2rowValue};

        errorReport.errorReportContent = new CSVBuilder();
        errorReport.errorReportContent = CSVBuilder.getRowsAndHeadersAsCsv(errorReport.errorReportContent, rows, new List<String>{'Header'});
        
        Test.startTest();
            ReportUtil.ErrorReport result = ReportUtil.saveErrorReport(errorReport, processInfo);
        Test.stopTest();

        System.assertEquals(true, result != null, 'Error report is null.');
    }
    
    @IsTest
    private static void prepareErrorReportForNullTest(){        
		objAccount = AccountSelector.getAllAccounts()[0];
        
        Database.SaveResult saveResult = (Database.SaveResult) JSON.deserialize('{"success":false, "errors":[{"message":"Error occured","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.Class);
        List<Database.Error> errors = saveResult.getErrors();
        
        ReportUtil.ErrorReportInfoWrapper errorWrapper = new ReportUtil.ErrorReportInfoWrapper();
        errorWrapper.masterId = '1';
        errorWrapper.recordId = objAccount.Id;
        errorWrapper.errors = errors;
        
        DataCleanBatchHelper.ProcessInformation processInfo = new DataCleanBatchHelper.ProcessInformation();
        processInfo.isParent = true;
        
        ReportUtil.ErrorReportInfo reportInfo = new ReportUtil.ErrorReportInfo();
        reportInfo.errorReportInfoWraps = new List<ReportUtil.ErrorReportInfoWrapper>{errorWrapper};
        reportInfo.processInfo = processInfo;
        
        ReportUtil.ErrorReport errorReport = new ReportUtil.ErrorReport(); 
        
        Test.startTest();
            ReportUtil.ErrorReport result = ReportUtil.prepareErrorReport(reportInfo, null);
        Test.stopTest();

        System.assertEquals(true, result != null, 'Error report is null.');
    }
    
    @IsTest
    private static void prepareBackupReportTest(){

        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];

        List<OQCT_DaCl__Data_Clean__c> daClrecords = DataCleanSelector.getDataCleanByDcConfigIds(dcConfig.Id);

        List<Account> accounts = AccountSelector.getAllAccounts();
        
        DataCleanBatchHelper.ProcessInformation processInfo = new DataCleanBatchHelper.ProcessInformation();
        processInfo.isParent = true;
        processInfo.dcConfigId = dcConfig.Id;
        processInfo.processName = Constants.PROCESS_MASK;

        Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2recordWrap = new Map<Id, DataCleanBatchHelper.RecordWrapper>();

        DataCleanBatchHelper.RecordWrapper recordWrap = new DataCleanBatchHelper.RecordWrapper();
        recordWrap.dataCleanId = daClrecords[0].Id;
        recordWrap.record = accounts[0];
        recordWrap.masterId = daClrecords[0].OQCT_DaCl__Master_Id__c;
        recordId2recordWrap.put(accounts[0].Id, recordWrap);

        recordWrap = new DataCleanBatchHelper.RecordWrapper();
        recordWrap.dataCleanId = daClrecords[1].Id;
        recordWrap.record = accounts[1];
        recordWrap.masterId = daClrecords[1].OQCT_DaCl__Master_Id__c;
        recordId2recordWrap.put(accounts[1].Id, recordWrap);

        ReportUtil.BackupReportInfo reportInfo = new ReportUtil.BackupReportInfo();
        reportInfo.recordId2recordWrap = recordId2recordWrap;
        reportInfo.processInfo = processInfo;
        
        Test.startTest();
        ReportUtil.BackupReport backupReport = ReportUtil.prepareBackupReport(reportInfo, null);
        Test.stopTest();

        System.assertEquals(true, backupReport != null, 'Backup report is null.');
    }
    
    @IsTest
    private static void saveBackupReportParentTest(){        
		OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];

        List<OQCT_DaCl__Data_Clean__c> daClrecords = DataCleanSelector.getDataCleanByDcConfigIds(dcConfig.Id);

        List<Account> accounts = AccountSelector.getAllAccounts();
        
        DataCleanBatchHelper.ProcessInformation processInfo = new DataCleanBatchHelper.ProcessInformation();
        processInfo.isParent = true;
        processInfo.dcConfigId = dcConfig.Id;
        processInfo.resultId = DCResultSelector.getAllDcResults()[0].Id;
        processInfo.processName = Constants.PROCESS_MASK;

        Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2recordWrap = new Map<Id, DataCleanBatchHelper.RecordWrapper>();

        DataCleanBatchHelper.RecordWrapper recordWrap = new DataCleanBatchHelper.RecordWrapper();
        recordWrap.dataCleanId = daClrecords[0].Id;
        recordWrap.record = accounts[0];
        recordWrap.masterId = daClrecords[0].OQCT_DaCl__Master_Id__c;
        recordId2recordWrap.put(accounts[0].Id, recordWrap);

        recordWrap = new DataCleanBatchHelper.RecordWrapper();
        recordWrap.dataCleanId = daClrecords[1].Id;
        recordWrap.record = accounts[1];
        recordWrap.masterId = daClrecords[1].OQCT_DaCl__Master_Id__c;
        recordId2recordWrap.put(accounts[1].Id, recordWrap);

        ReportUtil.BackupReportInfo reportInfo = new ReportUtil.BackupReportInfo();
        reportInfo.recordId2recordWrap = recordId2recordWrap;
        reportInfo.processInfo = processInfo;
        
        ReportUtil.BackupReport backupReport = new ReportUtil.BackupReport();
        
        backupReport = ReportUtil.prepareBackupReport(reportInfo, null);
        
        Test.startTest();
        backupReport = ReportUtil.saveBackupReport(backupReport, processInfo);
        Test.stopTest();

        System.assertEquals(0, backupReport.backupReportContents.size(), 'Parent Backup report content size is not zero after save.');
    }

    @IsTest
    private static void saveBackupReportChildTest(){        
		OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];

        List<OQCT_DaCl__Data_Clean__c> daClrecords = DataCleanSelector.getDataCleanByDcConfigIds(dcConfig.Id);

        List<Account> accounts = AccountSelector.getAllAccounts();
        
        DataCleanBatchHelper.ProcessInformation processInfo = new DataCleanBatchHelper.ProcessInformation();
        processInfo.isParent = false;
        processInfo.dcConfigId = dcConfig.Id;
        processInfo.resultId = DCResultSelector.getAllDcResults()[0].Id;
        processInfo.processName = Constants.PROCESS_MASK;

        Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2recordWrap = new Map<Id, DataCleanBatchHelper.RecordWrapper>();

        DataCleanBatchHelper.RecordWrapper recordWrap = new DataCleanBatchHelper.RecordWrapper();
        recordWrap.dataCleanId = daClrecords[0].Id;
        recordWrap.record = accounts[0];
        recordWrap.masterId = daClrecords[0].OQCT_DaCl__Master_Id__c;
        recordId2recordWrap.put(accounts[0].Id, recordWrap);

        recordWrap = new DataCleanBatchHelper.RecordWrapper();
        recordWrap.dataCleanId = daClrecords[1].Id;
        recordWrap.record = accounts[1];
        recordWrap.masterId = daClrecords[1].OQCT_DaCl__Master_Id__c;
        recordId2recordWrap.put(accounts[1].Id, recordWrap);

        ReportUtil.BackupReportInfo reportInfo = new ReportUtil.BackupReportInfo();
        reportInfo.recordId2recordWrap = recordId2recordWrap;
        reportInfo.processInfo = processInfo;
        
        ReportUtil.BackupReport backupReport = new ReportUtil.BackupReport();
        
        backupReport = ReportUtil.prepareBackupReport(reportInfo, null);
        
        Test.startTest();
        backupReport = ReportUtil.saveBackupReport(backupReport, processInfo);
        Test.stopTest();

        System.assertEquals(0, backupReport.backupReportContents.size(), 'Child Backup report content size is not zero after save.');
    }

}