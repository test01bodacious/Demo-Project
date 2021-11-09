/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-25
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-08   Krrish Joy   Initial Version
**/

@SuppressWarnings('PMD.CognitiveComplexity,PMD.ExcessivePublicCount')
public with sharing class ReportUtil {

    @SuppressWarnings('PMD.CognitiveComplexity')
    public static SuccessReport prepareSuccessReport(SuccessReportInfo successReportInfo, SuccessReport successReport){
        if (Limits.getHeapSize() >= Constants.BATCH_HEAP_SIZE_CAPPING) {
            successReport = ReportUtil.saveSuccessReport(successReport, successReportInfo.processInfo);
        }
        if (successReport == null) {
            successReport = new ReportUtil.SuccessReport();
            successReport.resultId = successReportInfo.processInfo.resultId;
            successReport.successReportContent = new CsvBuilder();
        }

        List<String> headers = new List<String>();
        headers.add(Constants.FILE_HEADER_MASTER_ID);
        headers.add(Constants.FILE_HEADER_RECORD_ID);
        headers.add(Constants.FILE_HEADER_OBJECT);
        headers.add(Constants.FILE_HEADER_ACTION);
        headers.add(Constants.FILE_HEADER_RESULT);

        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        for (SuccessReportInfoWrapper successReportInfoWrap : successReportInfo.successReportInfoWraps) {
            Map<String, Object> row = new Map<String, Object>();
            for (String header : headers) {
                if (header == Constants.FILE_HEADER_MASTER_ID) {
                    row.put(header, successReportInfoWrap.masterId);
                    continue;
                }
                if (header == Constants.FILE_HEADER_RECORD_ID) {
                    row.put(header, successReportInfoWrap.recordId);
                    continue;
                }
                if (header == Constants.FILE_HEADER_OBJECT) {
                    row.put(header, successReportInfo.processInfo.objectName);
                    continue;
                }
                if (header == Constants.FILE_HEADER_ACTION) {
                    String processName = successReportInfo.processInfo.isParent? successReportInfo.processInfo.processName : successReportInfo.processInfo.relatedProcessName;
                    row.put(header, processName);
                    continue;
                }
                if (header == Constants.FILE_HEADER_RESULT) {
                    row.put(header, Constants.FILE_VALUE_SUCCESS);
                }
            }
            rows.add(row);
        }
        
        successReport.successReportContent = CsvBuilder.getRowsAndHeadersAsCsv(successReport.successReportContent, rows, headers);
        return successReport;
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    public static ErrorReport prepareErrorReport(ErrorReportInfo errorReportInfo, ErrorReport errorReport){
        if (Limits.getHeapSize() >= Constants.BATCH_HEAP_SIZE_CAPPING) {
            errorReport = ReportUtil.saveErrorReport(errorReport, errorReportInfo.processInfo);
        }
        if (errorReport == null) {
            errorReport = new ReportUtil.ErrorReport();
            errorReport.resultId = errorReportInfo.processInfo.resultId;
            errorReport.errorReportContent = new CsvBuilder();
        }
        List<String> headers = new List<String>();
        headers.add(Constants.FILE_HEADER_MASTER_ID);
        headers.add(Constants.FILE_HEADER_RECORD_ID);
        headers.add(Constants.FILE_HEADER_OBJECT);
        headers.add(Constants.FILE_HEADER_ACTION);
        headers.add(Constants.FILE_HEADER_RESULT);
        headers.add(Constants.FILE_HEADER_ERROR_STATUS_CODES);
        headers.add(Constants.FILE_HEADER_ERROR_MESSAGES);

        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        for (ErrorReportInfoWrapper errorReportInfoWrap : errorReportInfo.errorReportInfoWraps) {
            Map<String, Object> row = new Map<String, Object>();
            for (String header : headers) {
                if (header == Constants.FILE_HEADER_MASTER_ID) {
                    row.put(header, errorReportInfoWrap.masterId);
                    continue;
                }
                if (header == Constants.FILE_HEADER_RECORD_ID) {
                    row.put(header, errorReportInfoWrap.recordId);
                    continue;
                }
                if (header == Constants.FILE_HEADER_OBJECT) {
                    row.put(header, errorReportInfo.processInfo.objectName);
                    continue;
                }
                if (header == Constants.FILE_HEADER_ACTION) {
                    String processName = errorReportInfo.processInfo.isParent? errorReportInfo.processInfo.processName : errorReportInfo.processInfo.relatedProcessName;
                    row.put(header, processName);
                    continue;
                }
                if (header == Constants.FILE_HEADER_RESULT) {
                    row.put(header, Constants.FILE_VALUE_ERROR);
                    continue;
                }
                if (header == Constants.FILE_HEADER_ERROR_STATUS_CODES) {
                    row.put(header, errorReportInfoWrap.getErrorStatusCodes());
                    continue;
                }
                if (header == Constants.FILE_HEADER_ERROR_MESSAGES) {
                    row.put(header, errorReportInfoWrap.getErrorMessages());
                }
            }
            rows.add(row);
        }
        
        errorReport.errorReportContent = CsvBuilder.getRowsAndHeadersAsCsv(errorReport.errorReportContent, rows, headers);
        return errorReport;
    }

    public static BackupReport prepareBackupReport(BackupReportInfo backupReportInfo, BackupReport backupReport){
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationNameById(backupReportInfo.processInfo.dcConfigId);
        if (!dcConfig.OQCT_DaCl__Data_Clean_Action__c.containsIgnoreCase(Constants.PROCESS_ROLLBACK) && !dcConfig.OQCT_DaCl__Data_Clean_Action__c.containsIgnoreCase(Constants.PROCESS_ARCHIVE)) {
            return backupReport;
        }
        if (DataCleanBatchHelper.isProcess2(dcConfig, backupReportInfo.processInfo.processName)) {
            return backupReport;
        }
        if (Limits.getHeapSize() >= Constants.BATCH_HEAP_SIZE_CAPPING) {
            backupReport = ReportUtil.saveBackupReport(backupReport, backupReportInfo.processInfo);
        }
        if (backupReport == null) {
            backupReport = new ReportUtil.BackupReport();
            backupReport.resultId = backupReportInfo.processInfo.resultId;
            backupReport.backupReportContents = new List<ReportUtil.BackupReportContent>();
        }
        for (Id recordId : backupReportInfo.recordId2recordWrap.keySet()) {

            DataCleanBatchHelper.RecordWrapper recordWrap = backupReportInfo.recordId2recordWrap.get(recordId);

            ReportUtil.BackupReportContent backupReportContent = new ReportUtil.BackupReportContent();
            backupReportContent.dataCleanId = recordWrap.dataCleanId;
            backupReportContent.masterId = recordWrap.masterId;
            backupReportContent.objName = backupReportInfo.processInfo.objectName;
            backupReportContent.isMasterObject = backupReportInfo.processInfo.isParent;
            if (backupReportInfo.processInfo.isParent) {
                backupReportContent.actionType = backupReportInfo.processInfo.processName;
            } else {
                backupReportContent.actionType = backupReportInfo.processInfo.relatedProcessName;
            }
            backupReportContent.record = recordWrap.record;
            backupReportContent.recordId = recordId;
            backupReport.backupReportContents.add(backupReportContent);
        }
        return backupReport;
    }

    public static SuccessReport saveSuccessReport(SuccessReport successReport, DataCleanBatchHelper.ProcessInformation processInfo){
        if (successReport == null || String.isBlank(successReport.successReportContent.toString())) {
            return null;
        }
        ContentVersion contentVersion = new ContentVersion();
        String processName = processInfo.isParent ? processInfo.processName : processInfo.relatedProcessName;
        if (processInfo.isParent) {
            contentVersion.title = processInfo.dcConfigName + Constants.LITERAL_HYPHEN + processName + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_SUCCESS + Constants.PARENT + Constants.LITERAL_HYPHEN + processInfo.objectName + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
        } else {
            contentVersion.title = processInfo.dcConfigName + Constants.LITERAL_HYPHEN + processName + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_SUCCESS + Constants.CHILD + Constants.LITERAL_HYPHEN + processInfo.objectName + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
        }
        contentVersion.pathOnClient = contentVersion.title + Constants.FILE_EXTENSION_CSV;
        contentVersion.FirstPublishLocationId = successReport.resultId;
        contentVersion.VersionData  = Blob.valueOf(successReport.successReportContent.toString());
        contentVersion.isMajorVersion = false;
        Set<Id> successContentVersionIds = DatabaseUtils.insertRecordsAndReturnSuccessRecordsIds(contentVersion);
        if (!successContentVersionIds.isEmpty()) {
            successReport.lastSavedFileName = contentVersion.pathOnClient;
            successReport.successReportContent = new CsvBuilder();
            return successReport;
        }
        return null;
    }

    public static ErrorReport saveErrorReport(ErrorReport errorReport, DataCleanBatchHelper.ProcessInformation processInfo){
        if (errorReport == null || String.isBlank(errorReport.errorReportContent.toString())) {
            return null;
        }
        ContentVersion contentVersion = new ContentVersion();
        String processName = processInfo.isParent ? processInfo.processName : processInfo.relatedProcessName;
        if (processInfo.isParent) {
            contentVersion.title = processInfo.dcConfigName + Constants.LITERAL_HYPHEN + processName + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_ERROR + Constants.PARENT + Constants.LITERAL_HYPHEN + processInfo.objectName + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
        } else {
            contentVersion.title = processInfo.dcConfigName + Constants.LITERAL_HYPHEN + processName + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_ERROR + Constants.CHILD + Constants.LITERAL_HYPHEN + processInfo.objectName + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
        }
        contentVersion.pathOnClient = contentVersion.title + Constants.FILE_EXTENSION_CSV;
        contentVersion.FirstPublishLocationId = errorReport.resultId;
        contentVersion.VersionData  = Blob.valueOf(errorReport.errorReportContent.toString());
        contentVersion.isMajorVersion = false;
        Set<Id> successContentVersionIds = DatabaseUtils.insertRecordsAndReturnSuccessRecordsIds(contentVersion);
        if (!successContentVersionIds.isEmpty()) {
            errorReport.lastSavedFileName = contentVersion.pathOnClient;
            errorReport.errorReportContent = new CsvBuilder();
            return errorReport;
        }
        return null;
    }

    public static BackupReport saveBackupReport(BackupReport backupReport, DataCleanBatchHelper.ProcessInformation processInfo){
        if (backupReport == null || backupReport.backupReportContents == null || backupReport.backupReportContents.isEmpty()) {
            return null;
        }
        ContentVersion contentVersion = new ContentVersion();
        String processName = processInfo.isParent ? processInfo.processName : processInfo.relatedProcessName;
        if (processInfo.isParent) {
            contentVersion.title = processInfo.dcConfigName + Constants.LITERAL_HYPHEN + processName + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_BACKUP + Constants.PARENT + Constants.LITERAL_HYPHEN + processInfo.objectName + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
        } else {
            contentVersion.title = processInfo.dcConfigName + Constants.LITERAL_HYPHEN + processName + Constants.LITERAL_HYPHEN + Constants.FILE_PREFIX_BACKUP + Constants.CHILD + Constants.LITERAL_HYPHEN + processInfo.objectName + Constants.LITERAL_HYPHEN + ReportUtil.getFileSuffix();
        }
        contentVersion.pathOnClient = contentVersion.title + Constants.FILE_EXTENSION_JSON;
        contentVersion.FirstPublishLocationId = backupReport.resultId;
        contentVersion.VersionData  = Blob.valueOf(JSON.serialize(backupReport.backupReportContents));
        contentVersion.isMajorVersion = false;
        Set<Id> successContentVersionIds = DatabaseUtils.insertRecordsAndReturnSuccessRecordsIds(contentVersion);
        if (!successContentVersionIds.isEmpty()) {
            backupReport.lastSavedFileName = contentVersion.pathOnClient;
            ReportUtil.updateDataCleanWithBackupFileName(backupReport.backupReportContents, backupReport.lastSavedFileName, processInfo.isParent);
            ReportUtil.updateDcResultBackupFileName(backupReport.backupReportContents, backupReport.lastSavedFileName, processInfo.resultId, processInfo.isParent);
            backupReport.backupReportContents = new List<ReportUtil.BackupReportContent>();
            return backupReport;
        }
        return null;
    }

    public static void updateDataCleanWithBackupFileName(List<BackupReportContent> backupReportContents, String backupfileName, Boolean isParent){
        Set<Id> dataCleanIds = new Set<Id>();
        for (ReportUtil.BackupReportContent backupReportContent : backupReportContents) {
            dataCleanIds.add(backupReportContent.dataCleanId);
        }
        List<OQCT_DaCl__Data_Clean__c> dataCleans = DataCleanSelector.getDataCleanBackupFileNamesByIds(dataCleanIds);
        for(OQCT_DaCl__Data_Clean__c dataClean: dataCleans){
            if (isParent) {
                if (String.isBlank(dataClean.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c)) {
                    dataClean.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c = backupfileName;
                } else {
                    List<String> backupFileNames = dataClean.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR);
                    if (!backupFileNames.contains(backupfileName)) {
                        dataClean.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c += (Constants.LITERAL_COMMA_SEPARATOR + backupfileName);
                    }
                }
            } else {
                if (String.isBlank(dataClean.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c)) {
                    dataClean.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c = backupfileName;
                } else {
                    List<String> backupFileNames = dataClean.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR);
                    if (!backupFileNames.contains(backupfileName)) {
                        dataClean.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c += (Constants.LITERAL_COMMA_SEPARATOR + backupfileName);
                    }
                }
            }
        }
        DatabaseUtils.updateRecords(dataCleans);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static void updateDcResultBackupFileName(List<BackupReportContent> backupReportContents, String backupfileName, Id resultId, Boolean isParent){
        OQCT_DaCl__DC_Result__c dcResult = DCResultSelector.getDCResultsBackupFileNamesByIds(new Set<Id>{resultId})[0];
        if (isParent) {
            if (String.isBlank(dcResult.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c)) {
                dcResult.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c = backupfileName;
            } else {
                List<String> backupFileNames = dcResult.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR);
                if (!backupFileNames.contains(backupfileName)) {
                    dcResult.OQCT_DaCl__Data_Clean_Parent_Backup_File_Names__c += (Constants.LITERAL_COMMA_SEPARATOR + backupfileName);
                }
            }
        } else {
            if (String.isBlank(dcResult.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c)) {
                dcResult.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c = backupfileName;
            } else {
                List<String> backupFileNames = dcResult.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c.split(Constants.LITERAL_COMMA_SEPARATOR);
                if (!backupFileNames.contains(backupfileName)) {
                    dcResult.OQCT_DaCl__Data_Clean_Child_Backup_File_Names__c += (Constants.LITERAL_COMMA_SEPARATOR + backupfileName);
                }
            }
        }
        DatabaseUtils.updateRecords(dcResult);
    }

    public static String getFileSuffix(){
        return String.valueOf(DateUtils.getNow().getTime());
    }

    public with sharing class SuccessReport{
        @TestVisible
        CsvBuilder successReportContent;
        Id resultId;
        String lastSavedFileName;
    }

    public with sharing class ErrorReport{
        @TestVisible
        CsvBuilder errorReportContent;
        Id resultId;
        String lastSavedFileName;
    }

    public with sharing class BackupReport{
        @TestVisible
        List<BackupReportContent> backupReportContents;
        Id resultId;
        String lastSavedFileName;
    }

    public with sharing class BackupReportContent{
        public Id recordId;
        public Id dataCleanId;
        public String masterId;
        public sObject record;
        public String objName;
        public String actionType;
        public Boolean isMasterObject;
    }

    public with sharing class SuccessReportInfo{
        public List<SuccessReportInfoWrapper> successReportInfoWraps;
        public DataCleanBatchHelper.ProcessInformation processInfo;
    }

    public with sharing class ErrorReportInfo{
        public List<ErrorReportInfoWrapper> errorReportInfoWraps;
        public DataCleanBatchHelper.ProcessInformation processInfo;
    }

    public with sharing class BackupReportInfo{
        public Map<Id, DataCleanBatchHelper.RecordWrapper> recordId2recordWrap;
        public DataCleanBatchHelper.ProcessInformation processInfo;
    }

    public with sharing class SuccessReportInfoWrapper{
        public Id recordId;
        public String masterId;
    }

    public with sharing class ErrorReportInfoWrapper{
        public Id recordId;
        public String masterId;
        public List<Database.Error> errors;
        
        public String getErrorStatusCodes(){
            final StringBuilder errorStatusCodes = new StringBuilder();
            errorStatusCodes.setSeparator(Constants.LITERAL_COMMA_SEPARATOR);
            if (errors != null) {
                for (Database.Error error : errors) {
                    errorStatusCodes.append(error.getStatusCode().name());
                }
            }
            return errorStatusCodes.toString();
        }

        public String getErrorMessages(){
            final StringBuilder errorMesages = new StringBuilder();
            errorMesages.setSeparator(Constants.LITERAL_COMMA_SEPARATOR);
            if (errors != null) {
                for (Database.Error error : errors) {
                    errorMesages.append(error.getMessage());
                }
            }
            return errorMesages.toString();
        }
    }
}