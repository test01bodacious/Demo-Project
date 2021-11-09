/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-22
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-11   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class DataCleanConfigurationController {

    @AuraEnabled(cacheable=true)
    public static DatatableUtil.DatatableResponse getDatatable(String datatableRequestParamsString){
        try {
            DatatableUtil.DatatableRequestParameters datatableRequestParams = (DatatableUtil.DatatableRequestParameters)JSON.deserialize(datatableRequestParamsString, DatatableUtil.DatatableRequestParameters.class);
            DatatableUtil.DatatableResponse datatableResponse = DatatableUtil.fetchDatatableResponse(
                datatableRequestParams
            );
            if (datatableRequestParams.objectName == Constants.OBJECT_DC_CONFIGURATION) {
                DatatableUtil.DatatableColumn checkBoxColumn = DataCleanConfigurationController.findAndRemoveCheckBoxColumn(datatableResponse.datatableColumns);
                DatatableUtil.DatatableColumn toggleButtonColumn = DataCleanConfigurationController.convertCheckBoxColumnToToggleButtonColumn(checkBoxColumn);
                datatableResponse.datatableColumns.add(toggleButtonColumn);
                datatableResponse.datatableColumns.add(0, DataCleanConfigurationController.getEditColumn());
                datatableResponse.datatableColumns.add(0, DataCleanConfigurationController.getPreviewColumn());
            }
            return datatableResponse;
        } catch (Exception e) {
            Utils.debug('AuraException', e.getMessage());
            Utils.debug('AuraException Line', e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static DatatableUtil.DatatableColumn findAndRemoveCheckBoxColumn(List<DatatableUtil.DatatableColumn> dataTableColumns){
        Integer index = -1;
        
        for (Integer i = 0; i < dataTableColumns.size(); i++) {
            if (dataTableColumns[i].fieldName == Constants.DC_CONFIG_FIELD_IS_CONFIGURATION_ACTIVE) {
                index = i;
                break;
            }
        }
        if (index != -1) {
            return dataTableColumns.remove(index);
        } else {
            return null;
        }
        
    }

    public static DatatableUtil.DatatableColumn convertCheckBoxColumnToToggleButtonColumn(DatatableUtil.DatatableColumn checkBoxColumn){
        // Available Type Attributes (button): disabled, iconName, iconPosition, label, name, title, variant
        DatatableUtil.DatatableColumn dataTableColumnForToggleButton = new DatatableUtil.DatatableColumn();
        dataTableColumnForToggleButton.label = checkBoxColumn == null? Utils.getLabelForField(Constants.OBJECT_DC_CONFIGURATION, Constants.DC_CONFIG_FIELD_IS_CONFIGURATION_ACTIVE) : checkBoxColumn.label;
        dataTableColumnForToggleButton.fieldName = checkBoxColumn == null? Constants.DC_CONFIG_FIELD_IS_CONFIGURATION_ACTIVE : checkBoxColumn.fieldName;
        dataTableColumnForToggleButton.type = Constants.LIGHTNING_DATA_TYPE_TOGGLE_BUTTON;
        dataTableColumnForToggleButton.hideDefaultActions = true;
        dataTableColumnForToggleButton.typeAttributes.buttonDisabled = false;
        dataTableColumnForToggleButton.typeAttributes.rowId = new DatatableUtil.FieldNameWrapper(Constants.FIELD_RECORD_ID);
        dataTableColumnForToggleButton.typeAttributes.columnName = checkBoxColumn == null? Constants.DC_CONFIG_FIELD_IS_CONFIGURATION_ACTIVE : checkBoxColumn.fieldName;
        dataTableColumnForToggleButton.typeAttributes.checked = new DatatableUtil.FieldNameWrapper(Constants.DC_CONFIG_FIELD_IS_CONFIGURATION_ACTIVE);
        dataTableColumnForToggleButton.typeAttributes.showToggleOnOffText = true;
        dataTableColumnForToggleButton.typeAttributes.toggleOnText = Constants.TOGGLE_ACTIVE;
        dataTableColumnForToggleButton.typeAttributes.toggleOffText = Constants.TOGGLE_INACTIVE;
        return dataTableColumnForToggleButton;
    }

    public static DatatableUtil.DatatableColumn getEditColumn(){
        // TYPE: button-icon
        // SUPPORTED TYPE ATTRIBUTES: alternativeText, class(className), disabled, iconClass, iconName, name, title, variant
        DatatableUtil.DatatableColumn dataTableColumnForEditButton = new DatatableUtil.DatatableColumn();
        dataTableColumnForEditButton.label = 'Edit';
        dataTableColumnForEditButton.fieldName = 'edit';
        dataTableColumnForEditButton.type = Constants.LIGHTNING_DATA_TYPE_BUTTON_ICON;
        dataTableColumnForEditButton.initialWidth = 50;
        dataTableColumnForEditButton.hideDefaultActions = true;
        dataTableColumnForEditButton.typeAttributes.variant = 'brand';
        dataTableColumnForEditButton.typeAttributes.title = 'Edit';
        dataTableColumnForEditButton.typeAttributes.alternativeText = 'Edit';
        dataTableColumnForEditButton.typeAttributes.name = 'edit';
        dataTableColumnForEditButton.typeAttributes.iconName = 'utility:edit';
        dataTableColumnForEditButton.typeAttributes.iconClass = '';
        dataTableColumnForEditButton.typeAttributes.className = '';
        dataTableColumnForEditButton.typeAttributes.disabled = false;
        return dataTableColumnForEditButton;
    }

    public static DatatableUtil.DatatableColumn getPreviewColumn(){
        // TYPE: navigation
        // SUPPORTED TYPE ATTRIBUTES: label, title, target, pageReferencetype, recordId, actionName, pageName, pageApiName, objectApiName, relationshipApiName, columnName, rowId, showAsAnIcon
        DatatableUtil.DatatableColumn dataTableColumnForPreviewButton = new DatatableUtil.DatatableColumn();
        dataTableColumnForPreviewButton.label = 'View';
        dataTableColumnForPreviewButton.fieldName = 'view';
        dataTableColumnForPreviewButton.type = Constants.LIGHTNING_DATA_TYPE_NAVIGATION;
        dataTableColumnForPreviewButton.initialWidth = 50;
        dataTableColumnForPreviewButton.hideDefaultActions = true;
        dataTableColumnForPreviewButton.typeAttributes.label = 'Preview';
        dataTableColumnForPreviewButton.typeAttributes.title = 'Preview';
        dataTableColumnForPreviewButton.typeAttributes.recordId = new DatatableUtil.FieldNameWrapper(Constants.FIELD_RECORD_ID);
        dataTableColumnForPreviewButton.typeAttributes.showAsAnIcon = true;
        return dataTableColumnForPreviewButton;
    }
    
    @AuraEnabled
    public static List<Utils.Options> getObjectOptions(String actionName){
        List<Utils.Options> objectListOptions = Utils.getObjectListAsOptions(actionName);
        return objectListOptions;
    }

    @AuraEnabled(cacheable = true)
    public static List<Utils.Options> getMaskableFieldOptions(String objectApiName){
        List<Utils.Options> fieldListOptions = Utils.getMaskableFieldListAsOptions(objectApiName);
        return fieldListOptions;
    }

    @AuraEnabled(cacheable = true)
    public static List<Utils.Options> getNillableFieldOptions(String objectApiName){
        List<Utils.Options> fieldListOptions = Utils.getNillableFieldListAsOptions(objectApiName);
        return fieldListOptions;
    }

    @AuraEnabled
    public static List<Utils.Options> getPotentialExternalIdFieldOptions(String objectApiName){
        List<Utils.Options> potentialExternalIdFieldListOptions = Utils.getPotentialExternalFieldListAsOptions(objectApiName);
        return potentialExternalIdFieldListOptions;
    }

    @AuraEnabled(cacheable = true)
    public static List<Utils.Options> getRecordTypeOptions(String objectApiName){
        List<Utils.Options> recordTypeOptions = Utils.getRecordTypeListAsOptions(objectApiName);
        return recordTypeOptions;
    }

    @AuraEnabled
    public static List<Utils.Options> getRelatedObjectOptions(String objectApiName, Boolean checkRecordTypeSize){
        List<Utils.Options> recordTypeOptions = Utils.getRelatedObjectAsOptions(objectApiName, checkRecordTypeSize);
        return recordTypeOptions;
    }

    @AuraEnabled
    public static Utils.Response activeOrDeactivateDcConfiguration(OQCT_DaCl__DC_Configuration__c dcConfig){
        Utils.Response response = new Utils.Response();
        Map<Id, String> failedRecordId2ErrorMessage = DatabaseUtils.updateRecordsAndReturnFailedRecordsIdWithErrorMessages(dcConfig);
        if (failedRecordId2ErrorMessage.isEmpty()) {
            // Return Success Response
            response.isSuccess = true;
            response.errorMessage = '';
        } else {
            // Return Error Response
            response.isSuccess = false;
            response.errorMessage = failedRecordId2ErrorMessage.get(dcConfig.Id);
        }
        return response;
    }

    @AuraEnabled
    public static List<DataCleanConfigurationController.RelatedObjectRecordTypes> getRelatedObjectRecordTypeOptions(List<String> relatedObjectApiNames){
        List<DataCleanConfigurationController.RelatedObjectRecordTypes> relatedObjectRecordTypeData = new List<DataCleanConfigurationController.RelatedObjectRecordTypes>();
        for (String relatedObjectApiName : relatedObjectApiNames) {
            Schema.DescribeSObjectResult relatedObjectDescribe = Utils.GLOBAL_DESCRIBE_MAP_CACHE.get(relatedObjectApiName).getDescribe();
            List<Schema.RecordTypeInfo> recordTypeInfos = relatedObjectDescribe.getRecordTypeInfos();
            for (Schema.RecordTypeInfo rtInfo : recordTypeInfos) {
                DataCleanConfigurationController.RelatedObjectRecordTypes relatedObjectRTData = new DataCleanConfigurationController.RelatedObjectRecordTypes();
                relatedObjectRTData.relatedObjectApiName = relatedObjectApiName;
                relatedObjectRTData.relatedObjectRecordTypeId = rtInfo.getRecordTypeId();
                relatedObjectRTData.relatedObjectRecordTypeName = rtInfo.getName();
                relatedObjectRecordTypeData.add(relatedObjectRTData);
            }
        }
        return relatedObjectRecordTypeData;
    }

    @AuraEnabled
    public static Utils.Response deleteDcConfigurations(Map<Id, String> dcConfigId2Name){
        try {
            Utils.Response response = new Utils.Response();
            if (DCConfigurationSelector.getDcConfigWithoutResultsByIdsCount(dcConfigId2Name.keySet()) > 0) {
                DeleteDataCleanConfigurationBatch deleteDcConfigBatch = new DeleteDataCleanConfigurationBatch(dcConfigId2Name);
                Id deleteDcConfigBatchId = Database.executeBatch(deleteDcConfigBatch);
                response.isSuccess = true;
                response.errorMessage = '';
                return response;
            } else {
                response.isSuccess = false;
                response.errorMessage = 'No DC-Configurations matched for deletion. Only configurations without results can be deleted.';
                return response;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Utils.Response saveDataCleanConfigurations(String dataCleanConfigString){
        Utils.debug('dataCleanConfigString', dataCleanConfigString);
        DataCleanConfigurationController.DataCleanConfiguration dataCleanConfig = (DataCleanConfigurationController.DataCleanConfiguration)JSON.deserialize(dataCleanConfigString, DataCleanConfigurationController.DataCleanConfiguration.class);
        Utils.Response response = new Utils.Response();
        try{
            // Save DC Config
            OQCT_DaCl__DC_Configuration__c dcConfig = new OQCT_DaCl__DC_Configuration__c();
            dcConfig.Id = dataCleanConfig.recordId;
            dcConfig.OQCT_DaCl__Data_Clean_Action__c = dataCleanConfig.dataCleanAction;
            dcConfig.OQCT_DaCl__Master_Object_Name__c = dataCleanConfig.masterObjectName;
            dcConfig.OQCT_DaCl__Master_Object_Match_By_Field_Name__c = dataCleanConfig.masterObjectMatchByFieldName;
            dcConfig.OQCT_DaCl__Configuration_Notes__c = dataCleanConfig.configurationNotes;

            dcConfig.OQCT_DaCl__Receive_Email_Notification__c = dataCleanConfig.receiveErrorEmailNotifications;
            dcConfig.OQCT_DaCl__Email_Ids_to_Notify__c = dataCleanConfig.emailIdsToNotify;

            dcConfig.OQCT_DaCl__Receive_Error_Email_Notification__c = dataCleanConfig.receiveEmailNotifications;
            dcConfig.OQCT_DaCl__Error_Email_Ids_to_Notify__c = dataCleanConfig.errorEmailIdsToNotify;

            dcConfig.OQCT_DaCl__Data_Clean_Process_Start_After__c = Decimal.valueOf(dataCleanConfig.dataCleanProcessStartAfter);
            dcConfig.OQCT_DaCl__Data_Clean_Process_Start_Unit__c = dataCleanConfig.dataCleanProcessStartUnit;
            String[] dataCleanProcessStartTimeSplit = dataCleanConfig.dataCleanProcessStartTime.split(':');
            dcConfig.OQCT_DaCl__Data_Clean_Process_Start_Time__c = Time.newInstance( Integer.valueOf(dataCleanProcessStartTimeSplit[0]) //hour
                                                ,Integer.valueOf(dataCleanProcessStartTimeSplit[1]) //min
                                                ,0                                //sec
                                                ,0);

            dcConfig.OQCT_DaCl__Process2_Start_After__c = Decimal.valueOf(dataCleanConfig.dataCleanProcess2StartAfter);
            dcConfig.OQCT_DaCl__Process2_Start_Unit__c = dataCleanConfig.dataCleanProcess2StartUnit;
            String[] dataCleanMaskingDeletesStartTimeSplit = dataCleanConfig.dataCleanProcess2StartTime.split(':');
            dcConfig.OQCT_DaCl__Process2_Start_Time__c = Time.newInstance( Integer.valueOf(dataCleanMaskingDeletesStartTimeSplit[0]) //hour
                                                ,Integer.valueOf(dataCleanMaskingDeletesStartTimeSplit[1]) //min
                                                ,0                                //sec
                                                ,0);

            dcConfig.OQCT_DaCl__Delete_Backups_After__c = Decimal.valueOf(dataCleanConfig.dataCleanDeleteBackupsAfter);
            dcConfig.OQCT_DaCl__Delete_Backups_Unit__c = dataCleanConfig.dataCleanDeleteBackupsUnit;
            String[] dataCleanDeleteBackupsTimeSplit = dataCleanConfig.dataCleanDeleteBackupsTime.split(':');
            dcConfig.OQCT_DaCl__Delete_Backups_Time__c = Time.newInstance( Integer.valueOf(dataCleanDeleteBackupsTimeSplit[0]) //hour
                                                ,Integer.valueOf(dataCleanDeleteBackupsTimeSplit[1]) //min
                                                ,0                                //sec
                                                ,0);
                                                
            dcConfig.OQCT_DaCl__Retry_Process__c = dataCleanConfig.retryProcess;
            dcConfig.OQCT_DaCl__Retry_Process_After__c = Decimal.valueOf(dataCleanConfig.retryProcessAfter);
            dcConfig.OQCT_DaCl__Retry_Process_Unit__c = dataCleanConfig.retryProcessUnit;

            dcConfig.OQCT_DaCl__Retry_Process2__c = dataCleanConfig.retryProcess2;
            dcConfig.OQCT_DaCl__Retry_Process2_After__c = Decimal.valueOf(dataCleanConfig.retryProcess2After);
            dcConfig.OQCT_DaCl__Retry_Process2_Unit__c = dataCleanConfig.retryProcess2Unit;

            dcConfig.OQCT_DaCl__Is_Configuration_Active__c = dataCleanConfig.isConfigurationActive;
            DatabaseUtils.upsertRecords(dcConfig);

            // Save Related Object
            List<OQCT_DaCl__Related_Object__c> dcRelatedObjects = new List<OQCT_DaCl__Related_Object__c>();
            for (DataCleanRelatedObject dataCleanRelatedObject : dataCleanConfig.dataCleanRelatedObject) {
                OQCT_DaCl__Related_Object__c dcRelatedObject = new OQCT_DaCl__Related_Object__c();
                dcRelatedObject.Id = dataCleanRelatedObject.recordId;
                dcRelatedObject.OQCT_DaCl__DC_Configuration__c = dcConfig.Id;
                dcRelatedObject.OQCT_DaCl__Related_Object_Name__c = dataCleanRelatedObject.relatedObjectApiName;
                dcRelatedObject.OQCT_DaCl__Delete_Related_Records__c = dataCleanRelatedObject.deleteRecords;
                dcRelatedObjects.add(dcRelatedObject);
            }
            DatabaseUtils.upsertRecords(dcRelatedObjects);

            // Save Record Types and Fields
            List<OQCT_DaCl__Record_Type_Field__c> dcRecordTypeAndFields = new List<OQCT_DaCl__Record_Type_Field__c>();
            for (Integer i = 0; i < dataCleanConfig.dataCleanRelatedObject.size(); i++){
                for (DataCleanRecordTypeAndField dataCleanRecordTypeAndField : dataCleanConfig.dataCleanRelatedObject[i].dataCleanRelatedObjectRecordTypeAndField) {
                    OQCT_DaCl__Record_Type_Field__c dcRecordTypeAndField = new OQCT_DaCl__Record_Type_Field__c();
                    dcRecordTypeAndField.Id = dataCleanRecordTypeAndField.recordId;
                    dcRecordTypeAndField.OQCT_DaCl__DC_Configuration__c = dcConfig.Id;
                    dcRecordTypeAndField.OQCT_DaCl__Related_Object__c = dcRelatedObjects[i].Id;
                    dcRecordTypeAndField.OQCT_DaCl__Record_Type_Id__c = dataCleanRecordTypeAndField.recordTypeId;
                    dcRecordTypeAndField.OQCT_DaCl__Record_Type_Name__c = dataCleanRecordTypeAndField.recordTypeName;
                    dcRecordTypeAndField.OQCT_DaCl__Record_Type_Enabled__c = dataCleanRecordTypeAndField.recordTypeEnabled;
                    dcRecordTypeAndField.OQCT_DaCl__Fields_To_Mask__c = dataCleanRecordTypeAndField.fieldsToMask;
                    dcRecordTypeAndField.OQCT_DaCl__Fields_to_Empty__c = dataCleanRecordTypeAndField.fieldsToEmpty;
                    dcRecordTypeAndFields.add(dcRecordTypeAndField);
                }
            }
            for (DataCleanRecordTypeAndField dataCleanRecordTypeAndField : dataCleanConfig.dataCleanRecordTypeAndField) {
                OQCT_DaCl__Record_Type_Field__c dcRecordTypeAndField = new OQCT_DaCl__Record_Type_Field__c();
                dcRecordTypeAndField.Id = dataCleanRecordTypeAndField.recordId;
                dcRecordTypeAndField.OQCT_DaCl__DC_Configuration__c = dcConfig.Id;
                dcRecordTypeAndField.OQCT_DaCl__Record_Type_Id__c = dataCleanRecordTypeAndField.recordTypeId;
                dcRecordTypeAndField.OQCT_DaCl__Record_Type_Name__c = dataCleanRecordTypeAndField.recordTypeName;
                dcRecordTypeAndField.OQCT_DaCl__Record_Type_Enabled__c = dataCleanRecordTypeAndField.recordTypeEnabled;
                dcRecordTypeAndField.OQCT_DaCl__Fields_To_Mask__c = dataCleanRecordTypeAndField.fieldsToMask;
                dcRecordTypeAndField.OQCT_DaCl__Fields_to_Empty__c = dataCleanRecordTypeAndField.fieldsToEmpty;
                dcRecordTypeAndFields.add(dcRecordTypeAndField);
            }
            DatabaseUtils.upsertRecords(dcRecordTypeAndFields);

            // Return Success Response
            response.isSuccess = true;
            response.errorMessage = '';
            //DataCleanConfigurationController.sendMail();
        }catch(Exception e){
            // Return Error Response
            response.isSuccess = false;
            response.errorMessage = e.getMessage();
        }
        return response;
    }

    @AuraEnabled(cacheable = true)
    public static DataCleanConfiguration getDataCleanConfigurationComponentEditData(String dcConfigId){
        try {
            DataCleanConfiguration dataCleanConfig = new DataCleanConfiguration();

            // DC-Configuration
            OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationForEditById(dcConfigId);
            dataCleanConfig.recordId = dcConfig.Id;
            dataCleanConfig.dataCleanAction = dcConfig.OQCT_DaCl__Data_Clean_Action__c;
            dataCleanConfig.masterObjectName = dcConfig.OQCT_DaCl__Master_Object_Name__c;
            dataCleanConfig.masterObjectMatchByFieldName = dcConfig.OQCT_DaCl__Master_Object_Match_By_Field_Name__c;
            dataCleanConfig.configurationNotes = dcConfig.OQCT_DaCl__Configuration_Notes__c;
            dataCleanConfig.receiveEmailNotifications = dcConfig.OQCT_DaCl__Receive_Email_Notification__c;
            dataCleanConfig.emailIdsToNotify = dcConfig.OQCT_DaCl__Email_Ids_to_Notify__c;
            dataCleanConfig.receiveErrorEmailNotifications = dcConfig.OQCT_DaCl__Receive_Error_Email_Notification__c;
            dataCleanConfig.errorEmailIdsToNotify = dcConfig.OQCT_DaCl__Error_Email_Ids_to_Notify__c;
            dataCleanConfig.dataCleanProcessStartAfter = String.valueOf(dcConfig.OQCT_DaCl__Data_Clean_Process_Start_After__c);
            dataCleanConfig.dataCleanProcessStartUnit = dcConfig.OQCT_DaCl__Data_Clean_Process_Start_Unit__c;
            dataCleanConfig.dataCleanProcessStartTime = String.valueOf(dcConfig.OQCT_DaCl__Data_Clean_Process_Start_Time__c);
            dataCleanConfig.dataCleanProcess2StartAfter =  String.valueOf(dcConfig.OQCT_DaCl__Process2_Start_After__c);
            dataCleanConfig.dataCleanProcess2StartUnit = dcConfig.OQCT_DaCl__Process2_Start_Unit__c;
            dataCleanConfig.dataCleanProcess2StartTime = String.valueOf(dcConfig.OQCT_DaCl__Process2_Start_Time__c);
            dataCleanConfig.dataCleanDeleteBackupsAfter =  String.valueOf(dcConfig.OQCT_DaCl__Delete_Backups_After__c);
            dataCleanConfig.dataCleanDeleteBackupsUnit = dcConfig.OQCT_DaCl__Delete_Backups_Unit__c;
            dataCleanConfig.dataCleanDeleteBackupsTime = String.valueOf(dcConfig.OQCT_DaCl__Delete_Backups_Time__c);
            dataCleanConfig.retryProcess = dcConfig.OQCT_DaCl__Retry_Process__c;
            dataCleanConfig.retryProcessAfter =  String.valueOf(dcConfig.OQCT_DaCl__Retry_Process_After__c);
            dataCleanConfig.retryProcessUnit = dcConfig.OQCT_DaCl__Retry_Process_Unit__c;
            dataCleanConfig.retryProcess2 = dcConfig.OQCT_DaCl__Retry_Process2__c;
            dataCleanConfig.retryProcess2After =  String.valueOf(dcConfig.OQCT_DaCl__Retry_Process2_After__c);
            dataCleanConfig.retryProcess2Unit = dcConfig.OQCT_DaCl__Retry_Process2_Unit__c;
            dataCleanConfig.isConfigurationActive = dcConfig.OQCT_DaCl__Is_Configuration_Active__c;

            // Record Type and Field
            List<DataCleanRecordTypeAndField> dataCleanRecordTypeAndField = new List<DataCleanRecordTypeAndField>();
            List<OQCT_DaCl__Record_Type_Field__c> dcRecordTypeAndFields = RecordTypeAndFieldSelector.getAllRecordTypeAndFieldByDcConfigIdAndNoRelatedObject(dcConfig.Id);
            for (OQCT_DaCl__Record_Type_Field__c dcRecordTypeAndField : dcRecordTypeAndFields) {
                DataCleanRecordTypeAndField dataCleanRTAndFld = new DataCleanRecordTypeAndField();
                dataCleanRTAndFld.recordId = dcRecordTypeAndField.Id;
                dataCleanRTAndFld.fieldsToMask = dcRecordTypeAndField.OQCT_DaCl__Fields_To_Mask__c;
                dataCleanRTAndFld.fieldsToEmpty = dcRecordTypeAndField.OQCT_DaCl__Fields_to_Empty__c;
                dataCleanRTAndFld.recordTypeId = dcRecordTypeAndField.OQCT_DaCl__Record_Type_Id__c;
                dataCleanRTAndFld.recordTypeName = dcRecordTypeAndField.OQCT_DaCl__Record_Type_Name__c;
                dataCleanRTAndFld.recordTypeEnabled = dcRecordTypeAndField.OQCT_DaCl__Record_Type_Enabled__c;
                dataCleanRecordTypeAndField.add(dataCleanRTAndFld);
            }
            dataCleanConfig.dataCleanRecordTypeAndField = dataCleanRecordTypeAndField;
            
            // Related Object
            List<DataCleanRelatedObject> dataCleanRelatedObjects = new List<DataCleanRelatedObject>();
            List<OQCT_DaCl__Related_Object__c> dcRelatedObjects = RelatedObjectSelector.getRelatedObjectsAndRecordTypeAndFieldsByDcConfigId(dcConfig.Id);
            for (OQCT_DaCl__Related_Object__c dcRelatedObject : dcRelatedObjects) {
                DataCleanRelatedObject dataCleanRelObj = new DataCleanRelatedObject();
                dataCleanRelObj.recordId = dcRelatedObject.Id;
                dataCleanRelObj.relatedObjectApiName = dcRelatedObject.OQCT_DaCl__Related_Object_Name__c;
                dataCleanRelObj.deleteRecords = dcRelatedObject.OQCT_DaCl__Delete_Related_Records__c;
                List<DataCleanRecordTypeAndField> dataCleanRecordTypeAndFields = new List<DataCleanRecordTypeAndField>();
                for (OQCT_DaCl__Record_Type_Field__c dataCleanRTAndFld : dcRelatedObject.Record_Types_Fields__r) {
                    DataCleanRecordTypeAndField dcRTAndFld = new DataCleanRecordTypeAndField();
                    dcRTAndFld.recordId = dataCleanRTAndFld.Id;
                    dcRTAndFld.fieldsToMask = dataCleanRTAndFld.OQCT_DaCl__Fields_To_Mask__c;
                    dcRTAndFld.fieldsToEmpty = dataCleanRTAndFld.OQCT_DaCl__Fields_to_Empty__c;
                    dcRTAndFld.recordTypeId = dataCleanRTAndFld.OQCT_DaCl__Record_Type_Id__c;
                    dcRTAndFld.recordTypeName = dataCleanRTAndFld.OQCT_DaCl__Record_Type_Name__c;
                    dcRTAndFld.recordTypeEnabled = dataCleanRTAndFld.OQCT_DaCl__Record_Type_Enabled__c;
                    dataCleanRecordTypeAndFields.add(dcRTAndFld);
                }
                dataCleanRelObj.dataCleanRelatedObjectRecordTypeAndField = dataCleanRecordTypeAndFields;
                dataCleanRelatedObjects.add(dataCleanRelObj);
            }
            dataCleanConfig.dataCleanRelatedObject = dataCleanRelatedObjects;

            return dataCleanConfig;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void sendMail(){
        EmailUtils.EmailParameters emailParams = new EmailUtils.EmailParameters();
        emailParams.subject = Constants.DATA_CLEAN_EMAIL_SUBJECT_DC_CONFIGURATION_DELETE;
        emailParams.htmlBody = 'A new Configuration was created successfully.';
        EmailUtils.sendEmail(emailParams);
    }

    public with sharing class RelatedObjectRecordTypes{
        @AuraEnabled
        public String relatedObjectApiName;
        @AuraEnabled
        public String relatedObjectRecordTypeId;
        @AuraEnabled
        public String relatedObjectRecordTypeName;
    }

    @SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields')
    public with sharing class DataCleanConfiguration{
        // Main Information
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String dataCleanAction;
        @AuraEnabled
        public String masterObjectName;
        @AuraEnabled
        public String masterObjectMatchByFieldName;
        @AuraEnabled
        public String configurationNotes;

        @AuraEnabled
        public Boolean receiveEmailNotifications;
        @AuraEnabled
        public String emailIdsToNotify;

        @AuraEnabled
        public Boolean receiveErrorEmailNotifications;
        @AuraEnabled
        public String errorEmailIdsToNotify;


        @AuraEnabled
        public String dataCleanProcessStartAfter;
        @AuraEnabled
        public String dataCleanProcessStartUnit;
        @AuraEnabled
        public String dataCleanProcessStartTime;

        @AuraEnabled
        public String dataCleanProcess2StartAfter;
        @AuraEnabled
        public String dataCleanProcess2StartUnit;
        @AuraEnabled
        public String dataCleanProcess2StartTime;

        @AuraEnabled
        public String dataCleanDeleteBackupsAfter;
        @AuraEnabled
        public String dataCleanDeleteBackupsUnit;
        @AuraEnabled
        public String dataCleanDeleteBackupsTime;

        @AuraEnabled
        public Boolean retryProcess;
        @AuraEnabled
        public String retryProcessAfter;
        @AuraEnabled
        public String retryProcessUnit;

        @AuraEnabled
        public Boolean retryProcess2;
        @AuraEnabled
        public String retryProcess2After;
        @AuraEnabled
        public String retryProcess2Unit;

        @AuraEnabled
        public Boolean isConfigurationActive;

        // Other Related Object Information
        @AuraEnabled
        public List<DataCleanRecordTypeAndField> dataCleanRecordTypeAndField;
        @AuraEnabled
        public List<DataCleanRelatedObject> dataCleanRelatedObject;
        
    }

    public with sharing class DataCleanRecordTypeAndField{
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String recordTypeId;
        @AuraEnabled
        public String recordTypeName;
        @AuraEnabled
        public Boolean recordTypeEnabled;
        @AuraEnabled
        public String fieldsToMask;
        @AuraEnabled
        public String fieldsToEmpty;
    }

    public with sharing class DataCleanRelatedObject{
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String relatedObjectApiName;
        @AuraEnabled
        public Boolean deleteRecords;
        @AuraEnabled
        public List<DataCleanRecordTypeAndField> dataCleanRelatedObjectRecordTypeAndField;
    }
    
}