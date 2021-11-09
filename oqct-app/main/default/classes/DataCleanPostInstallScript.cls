/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-26
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-05   Krrish Joy   Initial Version
**/
public with sharing class DataCleanPostInstallScript implements InstallHandler{

    public void onInstall(InstallContext context) {
        if(context.previousVersion() == null) {
            Utils.debug('Package Installation', 'First Time Installation');
            initDataCleanAppConfigurationsWithDefaultValues();
            initDcDataTypesWithDefaultValues();
        } else if (context.previousVersion().compareTo(new Version(1,0)) == 0) {
            Utils.debug('Package Installation', 'Upgrading from Version 1.0');
        }
        if (context.isUpgrade()) {
            Utils.debug('Package Installation', 'Upgrade');
        }
        if (context.isPush()) {
            Utils.debug('Package Installation', 'Push');
        }
    }

    private static void initDataCleanAppConfigurationsWithDefaultValues(){

        OQCT_DaCl__Data_Clean_App_Configurations__c dataCleanAppConfigurations = new OQCT_DaCl__Data_Clean_App_Configurations__c();
        dataCleanAppConfigurations.OQCT_DaCl__Admin_Team_Email_Id__c = Constants.LITERAL_EMPTY;
        dataCleanAppConfigurations.OQCT_DaCl__External_Department_Email_Id__c = Constants.LITERAL_EMPTY;
        dataCleanAppConfigurations.OQCT_DaCl__Send_Global_Email_App_Notification__c = false;
        dataCleanAppConfigurations.OQCT_DaCl__Team_Notes__c = Constants.DEFAULT_TEAM_NOTES;
        DatabaseUtils.insertRecords(dataCleanAppConfigurations);
    }

    @TestVisible
    private static List<OQCT_DaCl__DC_Data_Type__c> initDcDataTypesWithDefaultValues(){

        List<OQCT_DaCl__DC_Data_Type__c> dcDataTypes = new List<OQCT_DaCl__DC_Data_Type__c>();
        
        OQCT_DaCl__DC_Data_Type__c dcDataTypeBoolean = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeBoolean.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeBoolean.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeBoolean.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeBoolean.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_BOOLEAN_CHECKBOX;
        dcDataTypeBoolean.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeBoolean.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeBoolean.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeBoolean.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_BOOLEAN;
        dcDataTypes.add(dcDataTypeBoolean);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeCurrency = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeCurrency.OQCT_DaCl__Match_Record_Original_Data_Length__c = true;
        dcDataTypeCurrency.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeCurrency.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeCurrency.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_CURRENCY;
        dcDataTypeCurrency.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeCurrency.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeCurrency.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeCurrency.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_CURRENCY;
        dcDataTypes.add(dcDataTypeCurrency);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeDate = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeDate.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeDate.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeDate.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeDate.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_DATE;
        dcDataTypeDate.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeDate.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeDate.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeDate.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_FUTURE_DATE;
        dcDataTypes.add(dcDataTypeDate);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeDateTime = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeDateTime.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeDateTime.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeDateTime.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeDateTime.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_DATE_TIME;
        dcDataTypeDateTime.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeDateTime.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeDateTime.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeDateTime.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_FUTURE_DATE_TIME;
        dcDataTypes.add(dcDataTypeDateTime);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeEmail = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeEmail.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeEmail.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeEmail.OQCT_DaCl__Custom_Length__c = 5;
        dcDataTypeEmail.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_EMAIL;
        dcDataTypeEmail.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeEmail.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeEmail.OQCT_DaCl__Email_Domain__c = Constants.DEFAULT_EMAIL_DOMAIN;
        dcDataTypeEmail.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_EMAIL;
        dcDataTypes.add(dcDataTypeEmail);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeLocationLongitude = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeLocationLongitude.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeLocationLongitude.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeLocationLongitude.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeLocationLongitude.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_LOCATION_LONGITUDE;
        dcDataTypeLocationLongitude.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeLocationLongitude.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeLocationLongitude.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeLocationLongitude.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_LOCATION_LONGITUDE;
        dcDataTypes.add(dcDataTypeLocationLongitude);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeLocationLatitude = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeLocationLatitude.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeLocationLatitude.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeLocationLatitude.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeLocationLatitude.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_LOCATION_LATITUDE;
        dcDataTypeLocationLatitude.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeLocationLatitude.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeLocationLatitude.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeLocationLatitude.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_LOCATION_LONGITUDE;
        dcDataTypes.add(dcDataTypeLocationLatitude);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeMultiselectUnrestrictive = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeMultiselectUnrestrictive.OQCT_DaCl__Match_Record_Original_Data_Length__c = true;
        dcDataTypeMultiselectUnrestrictive.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeMultiselectUnrestrictive.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeMultiselectUnrestrictive.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_MULTIPICKLIST_UNRESTRICTIVE;
        dcDataTypeMultiselectUnrestrictive.OQCT_DaCl__Text_Masking_Option__c = Constants.MASK_PATTERN_ALPHABETS_LOWER_CASE_UPPER_CASE;
        dcDataTypeMultiselectUnrestrictive.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeMultiselectUnrestrictive.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeMultiselectUnrestrictive.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_TEXT;
        dcDataTypes.add(dcDataTypeMultiselectUnrestrictive);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeMultiselectRestrictive = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeMultiselectRestrictive.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeMultiselectRestrictive.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeMultiselectRestrictive.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeMultiselectRestrictive.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_MULTIPICKLIST_RESTRICTIVE;
        dcDataTypeMultiselectRestrictive.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeMultiselectRestrictive.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeMultiselectRestrictive.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeMultiselectRestrictive.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_VALUE_FROM_PICKLIST_VALUE_SET;
        dcDataTypes.add(dcDataTypeMultiselectRestrictive);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeNumber = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeNumber.OQCT_DaCl__Match_Record_Original_Data_Length__c = true;
        dcDataTypeNumber.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeNumber.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeNumber.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_NUMBER;
        dcDataTypeNumber.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeNumber.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeNumber.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeNumber.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_NUMBER;
        dcDataTypes.add(dcDataTypeNumber);

        OQCT_DaCl__DC_Data_Type__c dcDataTypePercent = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypePercent.OQCT_DaCl__Match_Record_Original_Data_Length__c = true;
        dcDataTypePercent.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypePercent.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypePercent.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_PERCENT;
        dcDataTypePercent.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypePercent.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypePercent.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypePercent.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_PERCENTAGE;
        dcDataTypes.add(dcDataTypePercent);

        OQCT_DaCl__DC_Data_Type__c dcDataTypePhone = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypePhone.OQCT_DaCl__Match_Record_Original_Data_Length__c = true;
        dcDataTypePhone.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypePhone.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypePhone.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_PHONE;
        dcDataTypePhone.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypePhone.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypePhone.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypePhone.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_PHONE;
        dcDataTypes.add(dcDataTypePhone);

        OQCT_DaCl__DC_Data_Type__c dcDataTypePicklistUnrestrictive = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypePicklistUnrestrictive.OQCT_DaCl__Match_Record_Original_Data_Length__c = true;
        dcDataTypePicklistUnrestrictive.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypePicklistUnrestrictive.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypePicklistUnrestrictive.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_PICKLIST_UNRESTRICTIVE;
        dcDataTypePicklistUnrestrictive.OQCT_DaCl__Text_Masking_Option__c = Constants.MASK_PATTERN_ALPHA_NUMBERIC_LOWER_CASE_ONLY;
        dcDataTypePicklistUnrestrictive.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypePicklistUnrestrictive.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypePicklistUnrestrictive.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_TEXT;
        dcDataTypes.add(dcDataTypePicklistUnrestrictive);

        OQCT_DaCl__DC_Data_Type__c dcDataTypePicklistRestrictive = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypePicklistRestrictive.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypePicklistRestrictive.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypePicklistRestrictive.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypePicklistRestrictive.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_PICKLIST_RESTRICTIVE;
        dcDataTypePicklistRestrictive.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypePicklistRestrictive.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypePicklistRestrictive.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypePicklistRestrictive.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_VALUE_FROM_PICKLIST_VALUE_SET;
        dcDataTypes.add(dcDataTypePicklistRestrictive);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeText = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeText.OQCT_DaCl__Match_Record_Original_Data_Length__c = true;
        dcDataTypeText.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeText.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeText.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_TEXT;
        dcDataTypeText.OQCT_DaCl__Text_Masking_Option__c = Constants.MASK_PATTERN_ALPHABETS_LOWER_CASE_ONLY;
        dcDataTypeText.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeText.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeText.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_TEXT;
        dcDataTypes.add(dcDataTypeText);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeTextEncrypted = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeTextEncrypted.OQCT_DaCl__Match_Record_Original_Data_Length__c = true;
        dcDataTypeTextEncrypted.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeTextEncrypted.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeTextEncrypted.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_TEXT_ENCRYPTED;
        dcDataTypeTextEncrypted.OQCT_DaCl__Text_Masking_Option__c = Constants.MASK_PATTERN_ALPHA_NUMBERIC_WITH_SPECIAL_CHARACTER;
        dcDataTypeTextEncrypted.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeTextEncrypted.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeTextEncrypted.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_TEXT;
        dcDataTypes.add(dcDataTypeTextEncrypted);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeTextArea = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeTextArea.OQCT_DaCl__Match_Record_Original_Data_Length__c = true;
        dcDataTypeTextArea.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeTextArea.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeTextArea.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_TEXTAREA;
        dcDataTypeTextArea.OQCT_DaCl__Text_Masking_Option__c = Constants.MASK_PATTERN_ALPHA_NUMBERIC_LOWER_CASE_ONLY;
        dcDataTypeTextArea.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeTextArea.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeTextArea.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_TEXT;
        dcDataTypes.add(dcDataTypeTextArea);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeTextAreaLong = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeTextAreaLong.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeTextAreaLong.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeTextAreaLong.OQCT_DaCl__Custom_Length__c = 255;
        dcDataTypeTextAreaLong.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_TEXTAREA_LONG;
        dcDataTypeTextAreaLong.OQCT_DaCl__Text_Masking_Option__c = Constants.MASK_PATTERN_ALPHA_NUMBERIC_LOWER_CASE_ONLY;
        dcDataTypeTextAreaLong.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeTextAreaLong.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeTextAreaLong.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_TEXT;
        dcDataTypes.add(dcDataTypeTextAreaLong);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeTextAreaRich = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeTextAreaRich.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeTextAreaRich.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeTextAreaRich.OQCT_DaCl__Custom_Length__c = 255;
        dcDataTypeTextAreaRich.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_TEXTAREA_RICH;
        dcDataTypeTextAreaRich.OQCT_DaCl__Text_Masking_Option__c = Constants.MASK_PATTERN_ALPHA_NUMBERIC_LOWER_CASE_ONLY;
        dcDataTypeTextAreaRich.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeTextAreaRich.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeTextAreaRich.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_TEXT;
        dcDataTypes.add(dcDataTypeTextAreaRich);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeTime = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeTime.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeTime.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeTime.OQCT_DaCl__Custom_Length__c = null;
        dcDataTypeTime.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_TIME;
        dcDataTypeTime.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeTime.OQCT_DaCl__URL_Domain__c = null;
        dcDataTypeTime.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeTime.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_TIME;
        dcDataTypes.add(dcDataTypeTime);

        OQCT_DaCl__DC_Data_Type__c dcDataTypeURL = new OQCT_DaCl__DC_Data_Type__c();
        dcDataTypeURL.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
        dcDataTypeURL.OQCT_DaCl__Match_Object_Field_Length__c = false;
        dcDataTypeURL.OQCT_DaCl__Custom_Length__c = 5;
        dcDataTypeURL.OQCT_DaCl__Data_Type_Name__c = Constants.DC_DATA_TYPE_URL;
        dcDataTypeURL.OQCT_DaCl__Text_Masking_Option__c = null;
        dcDataTypeURL.OQCT_DaCl__URL_Domain__c = Constants.DEFAULT_URL_DOMAIN;
        dcDataTypeURL.OQCT_DaCl__Email_Domain__c = null;
        dcDataTypeURL.OQCT_DaCl__Value_Type__c = Constants.MASK_VALUE_TYPE_URL;
        dcDataTypes.add(dcDataTypeURL);

        DatabaseUtils.insertRecords(dcDataTypes);

        return dcDataTypes;
    }
}