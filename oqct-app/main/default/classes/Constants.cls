/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-26
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-11-09   Krrish Joy   Initial Version
**/
public with sharing class Constants {

    // Turn Debug logs on an off
    public static final Boolean DEBUG_LOG_FLAG = false;

    // Data Clean Data Type Labels
    public static final String DC_DATA_TYPE_BOOLEAN_CHECKBOX = 'BOOLEAN (Checkbox)';
    public static final String DC_DATA_TYPE_CURRENCY = 'CURRENCY';
    public static final String DC_DATA_TYPE_DATE = 'DATE';
    public static final String DC_DATA_TYPE_DATE_TIME = 'DATE TIME';
    public static final String DC_DATA_TYPE_EMAIL = 'EMAIL';
    public static final String DC_DATA_TYPE_LOCATION_LATITUDE  = 'LOCATION (Latitude)';
    public static final String DC_DATA_TYPE_LOCATION_LONGITUDE  = 'LOCATION (Longitude)';
    public static final String DC_DATA_TYPE_MULTIPICKLIST_UNRESTRICTIVE  = 'MULTIPICKLIST (Unrestrictive)';
    public static final String DC_DATA_TYPE_MULTIPICKLIST_RESTRICTIVE  = 'MULTIPICKLIST (Restrictive)';
    public static final String DC_DATA_TYPE_NUMBER  = 'NUMBER';
    public static final String DC_DATA_TYPE_PERCENT  = 'PERCENT';
    public static final String DC_DATA_TYPE_PHONE = 'PHONE';
    public static final String DC_DATA_TYPE_PICKLIST_UNRESTRICTIVE  = 'PICKLIST (Unrestrictive)';
    public static final String DC_DATA_TYPE_PICKLIST_RESTRICTIVE  = 'PICKLIST (Restrictive)';
    public static final String DC_DATA_TYPE_TEXT  = 'TEXT';
    public static final String DC_DATA_TYPE_TEXT_ENCRYPTED  = 'TEXT (Encrypted)';
    public static final String DC_DATA_TYPE_TEXTAREA  = 'TEXTAREA';
    public static final String DC_DATA_TYPE_TEXTAREA_LONG  = 'TEXTAREA (Long)';
    public static final String DC_DATA_TYPE_TEXTAREA_RICH  = 'TEXTAREA (Rich)';
    public static final String DC_DATA_TYPE_TIME  = 'TIME';
    public static final String DC_DATA_TYPE_URL  = 'URL';

    public static final String DC_DATA_TYPE_EMAIL_VALUE = '{0}@{1}';
    public static final String DC_DATA_TYPE_URL_VALUE = 'https://{0}.{1}';

    public static final Long DC_DATA_TYPE_MASK_MAX_CHARACTER_LENGTH = 1000;

    // Text Masking Pattern
    public static final String MASK_PATTERN_ALPHABETS_LOWER_CASE_ONLY = 'Alphabets (Lower Case Letters Only)';
    public static final String MASK_PATTERN_ALPHABETS_UPPER_CASE_ONLY = 'Alphabets (Upper Case Letters Only)';
    public static final String MASK_PATTERN_ALPHABETS_LOWER_CASE_UPPER_CASE = 'Alphabets (Lower Case and Upper Case Letters Mix)';
    public static final String MASK_PATTERN_ALPHA_NUMBERIC_LOWER_CASE_ONLY = 'Alphanumeric (Numbers and Lower Case Letters Only)';
    public static final String MASK_PATTERN_ALPHA_NUMBERIC_UPPER_CASE_ONLY = 'Alphanumeric (Numbers and Upper Case Letters Only)';
    public static final String MASK_PATTERN_ALPHA_NUMBERIC_LOWER_CASE_UPPER_CASE = 'Alphanumeric (Numbers, Lower Case and Upper Case Letters Mix)';
    public static final String MASK_PATTERN_ALPHA_NUMBERIC_WITH_SPECIAL_CHARACTER = 'AlphanumericWithSpecialCharacters (Special Characters, Numbers, Lower Case and Upper Case Letters Mix)';

    // Masking Value Type
    public static final String MASK_VALUE_TYPE_PAST_DATE = 'Random Past Date';
    public static final String MASK_VALUE_TYPE_FUTURE_DATE = 'Random Future Date';
    public static final String MASK_VALUE_TYPE_DATE = 'Random Date';
    public static final String MASK_VALUE_TYPE_PAST_DATE_TIME = 'Random Past DateTime';
    public static final String MASK_VALUE_TYPE_FUTURE_DATE_TIME = 'Random Future DateTime';
    public static final String MASK_VALUE_TYPE_DATE_TIME = 'Random DateTime';
    public static final String MASK_VALUE_TYPE_TEXT = 'Random Text';
    public static final String MASK_VALUE_TYPE_BOOLEAN = 'Random Boolean';
    public static final String MASK_VALUE_TYPE_CURRENCY = 'Random Currency';
    public static final String MASK_VALUE_TYPE_EMAIL = 'Random Email';
    public static final String MASK_VALUE_TYPE_LOCATION_LATITUDE = 'Random Location (Latitude)';
    public static final String MASK_VALUE_TYPE_LOCATION_LONGITUDE = 'Random Location (Longitude)';
    public static final String MASK_VALUE_TYPE_NUMBER = 'Random Number';
    public static final String MASK_VALUE_TYPE_PERCENTAGE = 'Random Percentage';
    public static final String MASK_VALUE_TYPE_PHONE = 'Random Phone';
    public static final String MASK_VALUE_TYPE_TIME = 'Random Time';
    public static final String MASK_VALUE_TYPE_URL = 'Random URL';
    public static final String MASK_VALUE_TYPE_VALUE_FROM_PICKLIST_VALUE_SET = 'Random Value Available in Picklist Value Set';

    // Masking Domains Default
    public static final String DEFAULT_URL_DOMAIN = 'oqct.com';
    public static final String DEFAULT_EMAIL_DOMAIN = 'oqct.com';

    // Team Note Defauult
    public static final String DEFAULT_TEAM_NOTES = '<p><b>Data Clean Team Notes: </b></p><p>Write here any knowledge you want to share with the Team! </p>';

    // Location (Lat, Long) Suffexes
    public static final String LATITUDE_SUFFIX = 'Latitude__s';
    public static final String LONGITUDE_SUFFIX = 'Longitude__s';

    // Lightning Data Types
    public static final String LIGHTNING_DATA_TYPE_BUTTON = 'button';
    public static final String LIGHTNING_DATA_TYPE_BUTTON_ICON = 'button-icon';
    public static final String LIGHTNING_DATA_TYPE_TOGGLE_BUTTON = 'toggleButton';
    public static final String LIGHTNING_DATA_TYPE_NAVIGATION = 'navigation';

    // Email Template Types
    public static final String EMAIL_TEMPLATE_TYPE_TEXT = 'text';
    
    // DML Operations
    public enum DML_OPERATION {DML_INSERT, DML_UPDATE, DML_UPSERT, DML_DELETE, DML_UNDELETE}

    // Object Names - Custom (Data Clean App)
    public static final String OBJECT_DC_CONFIGURATION = 'OQCT_DaCl__DC_Configuration__c';
    public static final String OBJECT_RELATED_OBJECT = 'OQCT_DaCl__Related_Object__c';
    public static final String OBJECT_RECORD_TYPE_FIELD = 'OQCT_DaCl__Record_Type_Field__c';
    public static final String OBJECT_DATA_CLEAN = 'OQCT_DaCl__Data_Clean__c';
    public static final String OBJECT_DATA_CLEAN_RELATED_RESULT = 'OQCT_DaCl__Data_Clean_Related_Result__c';
    public static final String OBJECT_DC_RESULTS = 'OQCT_DaCl__DC_Result__c';
    public static final String OBJECT_DC_RELATED_RESULTS = 'OQCT_DaCl__DC_Related_Result__c';
    public static final String OBJECT_DATA_CLEAN_APP_CONFIGURATIONS = 'OQCT_DaCl__Data_Clean_App_Configurations__c';
    public static final String OBJECT_DC_DATA_TYPE = 'OQCT_DaCl__DC_Data_Type__c';
    public static final String OBJECT_DATA_CLEAN_DELETE_AUDIT = 'OQCT_DaCl__Data_Clean_Delete_Audit__c';
    public static final String OBJECT_DATA_CLEAN_FAILED_CHILD = 'OQCT_DaCl__Data_Clean_Failed_Child__c';
    public static final String OBJECT_DATA_CLEAN_SUCCESS_CHILD = 'OQCT_DaCl__Data_Clean_Success_Child__c';

    // Object Names - Standard
    public static final String OBJECT_CONTENT_VERSION = 'ContentVersion';
    public static final String OBJECT_CONTENT_DOCUMENT = 'ContentDocument';
    public static final String OBJECT_CONTENT_DOCUMENT_LINK = 'ContentDocumentLink';
    public static final String OBJECT_ACCOUNT = 'Account';
    public static final String OBJECT_CONTACT = 'Contact';
    public static final String OBJECT_OPPORTUNITY = 'Opportunity';
    public static final String OBJECT_ATTACHMENT = 'Attachment';

    // Account Fields
    public static final String ACCOUNT_FIELD_ACCOUNT_NUMBER = 'AccountNumber';

    // Master Record Type Name
    public static final String RECORD_TYPE_NAME_MASTER = 'Master';

    // Object Singular Label
    public static final String OBJECT_LABEL_SINGULAR_DC_CONFIGURATION = 'DC-Configuration';
    public static final String OBJECT_LABEL_SINGULAR_RELATED_OBJECT = 'DC-Related Object';
    public static final String OBJECT_LABEL_SINGULAR_RECORD_TYPE_FIELD = 'DC-Record Type & Field';
    public static final String OBJECT_LABEL_SINGULAR_DATA_CLEAN = 'Data Clean';
    public static final String OBJECT_LABEL_SINGULAR_DATA_CLEAN_RELATED_RESULT = 'Data Clean Related Result';
    public static final String OBJECT_LABEL_SINGULAR_DC_RESULTS = 'DC-Result';
    public static final String OBJECT_LABEL_SINGULAR_DATA_CLEAN_APP_CONFIGURATIONS = 'Data Clean App Configuration';

    // Object Plural Label
    public static final String OBJECT_LABEL_PLURAL_DC_CONFIGURATION = 'DC-Configurations';
    public static final String OBJECT_LABEL_PLURAL_RELATED_OBJECT = 'DC-Related Objects';
    public static final String OBJECT_LABEL_PLURAL_RECORD_TYPE_FIELD = 'DC-Record Type & Fields';
    public static final String OBJECT_LABEL_PLURAL_DATA_CLEAN = 'Data Cleans';
    public static final String OBJECT_LABEL_PLURAL_DATA_CLEAN_RELATED_RESULT = 'Data Clean Related Results';
    public static final String OBJECT_LABEL_PLURAL_DC_RESULTS = 'DC-Results';
    public static final String OBJECT_LABEL_PLURAL_DATA_CLEAN_APP_CONFIGURATIONS = 'Data Clean App Configurations';

    // Universal Fields
    public static final String FIELD_CREATED_BY_ID = 'CreatedById';
    public static final String FIELD_CREATED_DATE = 'CreatedDate';
    public static final String FIELD_RECORD_ID = 'Id';
    public static final String FIELD_DELETED = 'IsDeleted';
    public static final String FIELD_LAST_ACTIVITY_DATE = 'LastActivityDate';
    public static final String FIELD_LAST_MODIFIED_BY_ID = 'LastModifiedById';
    public static final String FIELD_LAST_MODIFIED_DATE = 'LastModifiedDate';
    public static final String FIELD_LAST_REFERENCED_DATE = 'LastReferencedDate';
    public static final String FIELD_LAST_VIEWED_DATE = 'LastViewedDate';
    public static final String FIELD_RECORD_NAME = 'Name';
    public static final String FIELD_OWNER_ID = 'OwnerId';
    public static final String FIELD_RECORD_TYPE_ID = 'RecordTypeId';
    public static final String FIELD_SYSTEM_MODSTAMP = 'SystemModstamp';

    // DC-Config AutoNumber Display Format Prefix
    public static final String DISPLAY_FORMAT_DC_CONFIG = 'DC-Config-';

    // DC-Configuration Fields
    public static final String DC_CONFIG_FIELD_IS_CONFIGURATION_ACTIVE = 'OQCT_DaCl__Is_Configuration_Active__c';
    public static final String DC_CONFIG_FIELD_TOTAL_DC_RESULTS = 'OQCT_DaCl__Total_DC_Results__c';
    public static final String DC_CONFIG_FIELD_TOTAL_DATA_CLEANS = 'OQCT_DaCl__Total_Data_Cleans__c';
    public static final String DC_CONFIG_FIELD_TOTAL_MASTER_FAILURE_DELETION = 'OQCT_DaCl__Total_Master_Failure_Deletion__c';
    public static final String DC_CONFIG_FIELD_TOTAL_MASTER_FAILURE_MASKING = 'OQCT_DaCl__Total_Master_Failure_Masking__c';
    public static final String DC_CONFIG_FIELD_TOTAL_MASTER_SUCCESS_DELETION = 'OQCT_DaCl__Total_Master_Success_Deletion__c';
    public static final String DC_CONFIG_FIELD_TOTAL_MASTER_SUCCESS_MASKING = 'OQCT_DaCl__Total_Master_Success_Masking__c';
    public static final String DC_CONFIG_FIELD_TOTAL_MASTER_FAILURE_ROLLBACK = 'OQCT_DaCl__Total_Master_Failure_Rollback__c';
    public static final String DC_CONFIG_FIELD_TOTAL_MASTER_SUCCESS_ROLLBACK = 'OQCT_DaCl__Total_Master_Success_Rollback__c';
    public static final String DC_CONFIG_FIELD_TOTAL_MASTER_FAILURE_ARCHIVE = 'OQCT_DaCl__Total_Master_Failure_Archive__c';
    public static final String DC_CONFIG_FIELD_TOTAL_MASTER_FAILURE_CLONING = 'OQCT_DaCl__Total_Master_Failure_Cloning__c';
    public static final String DC_CONFIG_FIELD_TOTAL_MASTER_SUCCESS_ARCHIVE = 'OQCT_DaCl__Total_Master_Success_Archive__c';
    public static final String DC_CONFIG_FIELD_TOTAL_MASTER_SUCCESS_CLONING = 'OQCT_DaCl__Total_Master_Success_Cloning__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_FAILURE_MASKING = 'OQCT_DaCl__Total_Related_Failure_Masking__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_SUCCESS_DELETION = 'OQCT_DaCl__Total_Related_Success_Deletion__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_FAILURE_DELETION = 'OQCT_DaCl__Total_Related_Failure_Deletion__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_SUCCESS_ROLLBACK = 'OQCT_DaCl__Total_Related_Success_Rollback__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_FAILURE_ROLLBACK = 'OQCT_DaCl__Total_Related_Failure_Rollback__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_SUCCESS_ARCHIVE = 'OQCT_DaCl__Total_Related_Success_Archive__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_FAILURE_CLONING = 'OQCT_DaCl__Total_Related_Failure_Cloning__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_SUCCESS_CLONING = 'OQCT_DaCl__Total_Related_Success_Cloning__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_FAILURE_ARCHIVE = 'OQCT_DaCl__Total_Related_Failure_Archive__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_SUCCESS_MASKING = 'OQCT_DaCl__Total_Related_Success_Masking__c';
    public static final String DC_CONFIG_FIELD_DISABLE_ROLLBACK_BUTTON = 'OQCT_DaCl__Disable_Rollback_Button__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_OBJECTS = 'OQCT_DaCl__Total_Related_Objects__c';
    public static final String DC_CONFIG_FIELD_TOTAL_RELATED_OBJECTS_DELETED = 'OQCT_DaCl__Total_Related_Objects_Delete__c';
    public static final String DC_CONFIG_FIELD_TOTAL_MASKING_COMPLETED_DATA_CLEAN = 'OQCT_DaCl__Total_Masking_Completed_Data_Clean__c';
    public static final String DC_CONFIG_FIELD_TOTAL_DELETION_COMPLETED_DATA_CLEAN = 'OQCT_DaCl__Total_Deletion_Completed_Data_Clean__c';
    public static final String DC_CONFIG_FIELD_TOTAL_ARCHIVE_COMPLETED_DATA_CLEAN = 'OQCT_DaCl__Total_Archive_Completed_Data_Clean__c';
    public static final String DC_CONFIG_FIELD_TOTAL_CLONING_COMPLETED_DATA_CLEAN = 'OQCT_DaCl__Total_Cloning_Completed_Data_Clean__c';
    public static final String DC_CONFIG_FIELD_TOTAL_ROLLBACK_COMPLETED_DATA_CLEAN = 'OQCT_DaCl__Total_Rollback_Completed_Data_Clean__c';

    // Data Clean Fields
    public static final String DC_FIELD_DC_CONFIGURATION = 'OQCT_DaCl__DC_Configuration__c';
    public static final String DC_FIELD_MASTER_ID = 'OQCT_DaCl__Master_Id__c';
    public static final String DC_FIELD_MASTER_OBJECT_NAME = 'OQCT_DaCl__Master_Object_Name__c';
    public static final String DC_FIELD_OVERALL_DELETION_STATUS = 'OQCT_DaCl__Overall_Deletion_Status__c';
    public static final String DC_FIELD_OVERALL_MASKING_STATUS = 'OQCT_DaCl__Overall_Masking_Status__c';
    public static final String DC_FIELD_OVERALL_ROLLBACK_STATUS = 'OQCT_DaCl__Overall_Rollback_Status__c';
    public static final String DC_FIELD_OVERALL_ARCHIVE_STATUS = 'OQCT_DaCl__Overall_Archive_Status__c';
    public static final String DC_FIELD_OVERALL_CLONING_STATUS = 'OQCT_DaCl__Overall_Cloning_Status__c';
    public static final String DC_FIELD_RELATED_DELETION_STATUS = 'OQCT_DaCl__Related_Deletion_Status__c';
    public static final String DC_FIELD_RELATED_MASKING_STATUS = 'OQCT_DaCl__Related_Masking_Status__c';
    public static final String DC_FIELD_RELATED_ROLLBACK_STATUS = 'OQCT_DaCl__Related_Rollback_Status__c';
    public static final String DC_FIELD_RELATED_ARCHIVE_STATUS = 'OQCT_DaCl__Related_Archive_Status__c';
    public static final String DC_FIELD_RELATED_CLONING_STATUS = 'OQCT_DaCl__Related_Cloning_Status__c';
    public static final String DC_FIELD_MASTER_RECORD_DELETION_STATUS = 'OQCT_DaCl__Master_Record_Deletion_Status__c';
    public static final String DC_FIELD_MASTER_RECORD_MASKING_STATUS = 'OQCT_DaCl__Master_Record_Masking_Status__c';
    public static final String DC_FIELD_MASTER_RECORD_ROLLBACK_STATUS = 'OQCT_DaCl__Master_Record_Rollback_Status__c';
    public static final String DC_FIELD_MASTER_RECORD_ARCHIVE_STATUS = 'OQCT_DaCl__Master_Record_Archive_Status__c';
    public static final String DC_FIELD_MASTER_RECORD_CLONING_STATUS = 'OQCT_DaCl__Master_Record_Cloning_Status__c';
    public static final String DC_FIELD_TOTAL_MASTER_FAILURE_DELETION = 'OQCT_DaCl__Total_Master_Failure_Deletion__c';
    public static final String DC_FIELD_TOTAL_MASTER_FAILURE_MASKING = 'OQCT_DaCl__Total_Master_Failure_Masking__c';
    public static final String DC_FIELD_TOTAL_MASTER_SUCCESS_DELETION = 'OQCT_DaCl__Total_Master_Success_Deletion__c';
    public static final String DC_FIELD_TOTAL_MASTER_SUCCESS_MASKING = 'OQCT_DaCl__Total_Master_Success_Masking__c';
    public static final String DC_FIELD_TOTAL_MASTER_FAILURE_ROLLBACK = 'OQCT_DaCl__Total_Master_Failure_Rollback__c';
    public static final String DC_FIELD_TOTAL_MASTER_SUCCESS_ROLLBACK = 'OQCT_DaCl__Total_Master_Success_Rollback__c';
    public static final String DC_FIELD_TOTAL_MASTER_FAILURE_ARCHIVE = 'OQCT_DaCl__Total_Master_Failure_Archive__c';
    public static final String DC_FIELD_TOTAL_MASTER_FAILURE_CLONING = 'OQCT_DaCl__Total_Master_Failure_Cloning__c';
    public static final String DC_FIELD_TOTAL_MASTER_SUCCESS_ARCHIVE = 'OQCT_DaCl__Total_Master_Success_Archive__c';
    public static final String DC_FIELD_TOTAL_MASTER_SUCCESS_CLONING = 'OQCT_DaCl__Total_Master_Success_Cloning__c';
    public static final String DC_FIELD_TOTAL_RELATED_FAILURE_MASKING = 'OQCT_DaCl__Total_Related_Failure_Masking__c';
    public static final String DC_FIELD_TOTAL_RELATED_SUCCESS_DELETION = 'OQCT_DaCl__Total_Related_Success_Deletion__c';
    public static final String DC_FIELD_TOTAL_RELATED_FAILURE_DELETION = 'OQCT_DaCl__Total_Related_Failure_Deletion__c';
    public static final String DC_FIELD_TOTAL_RELATED_SUCCESS_ROLLBACK = 'OQCT_DaCl__Total_Related_Success_Rollback__c';
    public static final String DC_FIELD_TOTAL_RELATED_FAILURE_ROLLBACK = 'OQCT_DaCl__Total_Related_Failure_Rollback__c';
    public static final String DC_FIELD_TOTAL_RELATED_SUCCESS_ARCHIVE = 'OQCT_DaCl__Total_Related_Success_Archive__c';
    public static final String DC_FIELD_TOTAL_RELATED_FAILURE_CLONING = 'OQCT_DaCl__Total_Related_Failure_Cloning__c';
    public static final String DC_FIELD_TOTAL_RELATED_SUCCESS_CLONING = 'OQCT_DaCl__Total_Related_Success_Cloning__c';
    public static final String DC_FIELD_TOTAL_RELATED_FAILURE_ARCHIVE = 'OQCT_DaCl__Total_Related_Failure_Archive__c';
    public static final String DC_FIELD_TOTAL_RELATED_SUCCESS_MASKING = 'OQCT_DaCl__Total_Related_Success_Masking__c';
    public static final String DC_FIELD_RESULT_DISABLE_ROLLBACK_BUTTON = 'OQCT_DaCl__Disable_Rollback_Button__c';
    public static final String DC_FIELD_IS_MASKING_COMPLETED_1_0 = 'OQCT_DaCl__Is_Masking_Completed_1_or_0__c';
    public static final String DC_FIELD_IS_DELETION_COMPLETED_1_0 = 'OQCT_DaCl__Is_Deletion_Completed_1_or_0__c';
    public static final String DC_FIELD_IS_ARCHIVE_COMPLETED_1_0 = 'OQCT_DaCl__Is_Archive_Completed_1_or_0__c';
    public static final String DC_FIELD_IS_CLONING_COMPLETED_1_0 = 'OQCT_DaCl__Is_Cloning_Completed_1_or_0__c';
    public static final String DC_FIELD_IS_ROLLBACK_COMPLETED_1_0 = 'OQCT_DaCl__Is_Rollback_Completed_1_or_0__c';

    // Data Clean Related Result Fields
    public static final String DC_RELATED_RESULT_FIELD_DATA_CLEAN = 'OQCT_DaCl__Data_Clean__c';
    public static final String DC_RELATED_RESULT_FIELD_RELATED_OBJECT_NAME = 'OQCT_DaCl__Related_Object_Name__c';
    public static final String DC_RELATED_RESULT_FIELD_RELATED_MASKING_STATUS = 'OQCT_DaCl__Related_Masking_Status__c';
    public static final String DC_RELATED_RESULT_FIELD_RELATED_DELETE_STATUS = 'OQCT_DaCl__Related_Delete_Status__c';
    public static final String DC_RELATED_RESULT_FIELD_RELATED_ARCHIVE_STATUS = 'OQCT_DaCl__Related_Archive_Status__c';
    public static final String DC_RELATED_RESULT_FIELD_RELATED_CLONING_STATUS = 'OQCT_DaCl__Related_Cloning_Status__c';
    public static final String DC_RELATED_RESULT_FIELD_RELATED_ROLLBACK_STATUS = 'OQCT_DaCl__Related_Rollback_Status__c';

    // Related Object Fields
    public static final String RELATED_OBJECT_FIELD_DELETE_RELATED_RECORDS = 'OQCT_DaCl__Delete_Related_Records__c';

    // DC-Result Fields
    public static final String DC_RESULT_TOTAL_FILE_COUNT = 'OQCT_DaCl__Total_File_Count__c';
    public static final String DC_RESULT_TOTAL_BACKUP_FILES = 'OQCT_DaCl__Total_Backup_files__c';
    public static final String DC_RESULT_TOTAL_FILE_SIZE_BYTES = 'OQCT_DaCl__Total_File_Size_Bytes__c';
    public static final String DC_RESULT_BACKUP_FILE_SIZE_BYTES = 'OQCT_DaCl__Total_Backup_File_Size_Bytes__c';
    public static final String DC_RESULT_DISABLE_ROLLBACK_BUTTON = 'OQCT_DaCl__Disable_Rollback_Button__c';

    // ContentDocument Field
    public static final String CONTENT_DOCUMENT_FIELD_LATEST_PUBLISHED_VERSION_ID = 'LatestPublishedVersionId';

    // ContentVersion Field
    public static final String CONTENT_VERSION_FIELD_FIRST_PUBLISH_LOCATION_ID = 'FirstPublishLocationId';
    public static final String CONTENT_VERSION_FIELD_CONTENT_DOCUMENT_ID = 'ContentDocumentId';
    public static final String CONTENT_VERSION_FIELD_CONTENT_SIZE = 'ContentSize';
    public static final String CONTENT_VERSION_FIELD_PATH_ON_CLIENT = 'PathOnClient';
    public static final String CONTENT_VERSION_FIELD_TITLE = 'Title';

    // ContentDocumentLink Field
    public static final String CONTENT_DOCUMENT_LINK_FIELD_LINKED_ENTITY_ID = 'LinkedEntityId';
    public static final String CONTENT_DOCUMENT_LINK_FIELD_CONTENT_DOCUMENT_ID = 'ContentDocumentId';

    // History Object Fields
    public static final String OBJECT_HISTORY_FIELD = 'Field';

    // History Object Suffix
    public static final String HISTORY_OBJECT_SUFFIX_STANDARD = 'History';
    public static final String HISTORY_OBJECT_SUFFIX_CUSTOM = '__History';

    // Data Clean Actions
    public static final String DC_ACTION_MASKING_ONLY = 'Masking Only';
    public static final String DC_ACTION_MASKING_DELETION = 'Masking + Deletion';
    public static final String DC_ACTION_MASKING_ROLLBACK = 'Masking + Rollback';
    public static final String DC_ACTION_MASKING_ROLLBACK_DELETION = 'Masking + Rollback + Deletion';
    public static final String DC_ACTION_DELETION_ONLY = 'Deletion Only';
    public static final String DC_ACTION_DELETION_ROLLBACK = 'Deletion + Rollback';
    public static final String DC_ACTION_ARCHIVE_DELETION = 'Archive + Deletion';
    public static final String DC_ACTION_ARCHIVE_ROLLBACK = 'Archive + Rollback';
    public static final String DC_ACTION_CLONING = 'Cloning';

    // Data Clean Delete Audit Record Type
    public static final String DC_DELETE_AUDIT_RECORD_TYPE_DC_CONFIGURATION = 'DC-Configuration';
    public static final String DC_DELETE_AUDIT_RECORD_TYPE_DC_RESULT = 'DC-Result';
    public static final String DC_DELETE_AUDIT_RECORD_TYPE_DC_FILE = 'DC-File';

    // Data Clean Statuses
    public static final String DC_STATUS_PENDING = 'Pending';
    public static final String DC_STATUS_SUCCESS = 'Success';
    public static final String DC_STATUS_FAILED = 'Failed';
    public static final String DC_STATUS_PARTIAL_SUCCESS = 'Partial Success';
    public static final String DC_STATUS_NO_RECORDS_FOUND = 'No Records Found';
    public static final String DC_STATUS_NOT_ELIGIBLE = 'Not Eligible';

    // Data Clean Processes
    public static final String PROCESS_MASK = 'Masking';
    public static final String PROCESS_DELETE = 'Deletion';
    public static final String PROCESS_ARCHIVE = 'Archive';
    public static final String PROCESS_ROLLBACK = 'Rollback';
    public static final String PROCESS_CLONE = 'Cloning';

    // Field History Deletion Statuses
    public static final String FIELD_HISTORY_DELETE_SUCCESS = 'Field History Deleted successfully';
    public static final String FIELD_HISTORY_DELETE_FAILURE = 'Field History Deletion could not be completed';
    public static final String FIELD_HISTORY_DELETE_NOT_TRACKED = 'Field History Tracking is not Enabled on Object';
    public static final String FIELD_HISTORY_DELETE_INSUFFICIENT_PRIVILEGES = 'Insufficient Privileges! No Permission to Delete Field History';

    // Data Clean Job Status
    public static final String DC_RESULT_STATUS_QUEUED = 'Queued';
    public static final String DC_RESULT_STATUS_PROCESSING = 'Processing';
    public static final String DC_RESULT_STATUS_MASKING_CHILD = 'Masking Child Records';
    public static final String DC_RESULT_STATUS_MASKING_PARENT = 'Masking Parent Records';
    public static final String DC_RESULT_STATUS_DELETING_CHILD = 'Deleting Child Records';
    public static final String DC_RESULT_STATUS_DELETING_PARENT = 'Deleting Parent Records';
    public static final String DC_RESULT_STATUS_ARCHIVING_CHILD = 'Archiving Child Records';
    public static final String DC_RESULT_STATUS_ARCHIVING_PARENT = 'Archiving Parent Records';
    public static final String DC_RESULT_STATUS_ROLLBACKING_CHILD = 'Rollbacking Child Records';
    public static final String DC_RESULT_STATUS_ROLLBACKING_PARENT = 'Rollbacking Parent Records';
    public static final String DC_RESULT_STATUS_CLONING_CHILD = 'Cloning Child Records';
    public static final String DC_RESULT_STATUS_CLONING_PARENT = 'Cloning Parent Records';
    public static final String DC_RESULT_STATUS_COMPLETED = 'Completed';
    public static final String DC_RESULT_STATUS_ABORTED = 'Aborted';

    // Data Clean Time Units
    public static final String DC_UNIT_MINUTES = 'Minute(s)';
    public static final String DC_UNIT_HOURS = 'Hour(s)';
    public static final String DC_UNIT_DAYS = 'Day(s)';
    public static final String DC_UNIT_MONTHS = 'Month(s)';
    public static final String DC_UNIT_YEARS = 'Year(s)';

    // Data Clean Trigger Error
    public static final String DC_TRIGGER_ERROR_INVALID_DC_CONFIG_NAME = 'Invalid DC-Configuration Id! The DC-Configuration Name was not found.';
    public static final String DC_TRIGGER_ERROR_INVALID_MASTER_ID = 'The Master Id provided does not match with any {0} record in Salesforce Database. Please check the Master Id value.';

    // DcDataType Trigger Error
    public static final String DC_DATA_TYPE_TRIGGER_ERROR_CANNOT_DELETE = 'DC-Data Type cannot be deleted.';

    // Data Clean App Configuration Error
    public static final String DC_APP_CONFIG_TRIGGER_ERROR_CANNOT_DELETE = 'Data Clean App Configuration cannot be deleted.';
    public static final String DC_APP_CONFIG_TRIGGER_ERROR_CANNOT_INSERT_MORE_THAN_ONE = 'There must be one Data Clean App Configuration Only.';

    // Custom Execption Messages
    public static final String SOQL_STATEMENT_EXCEPTION_MESSAGE = 'You exceeded SOQL Statement Limit';
    public static final String DML_ROW_EXCEPTION_MESSAGE = 'You exceeded DML Rows Limit';
    public static final String DML_STATEMENT_EXCEPTION_MESSAGE = 'You exceeded DML Statement Limit';
    public static final String DML_INSUFFICIENT_PRIVILIEGES_EXCEPTION_MESSAGE = 'Insufficient Privileges! You do not have permission to perform the operation {0} on {1}';

    // Aggregate Functions
    public static final String AGGREGATE_FUNCTION_COUNT = 'COUNT';
    public static final String AGGREGATE_FUNCTION_SUM = 'SUM';
    public static final String AGGREGATE_FUNCTION_MIN = 'MIN';
    public static final String AGGREGATE_FUNCTION_MAX = 'MAX';
    public static final String AGGREGATE_FUNCTION_AVG = 'AVG';
    public static final String AGGREGATE_FUNCTION_COUNT_DISTINCT = 'COUNT_DISTINCT';

    // Aggregate Suffix
    public static final String AGGREGATE_SUFFIX = 'agr';
    public static final String AGGREGATE_RESULT_EXPRESSION = 'expr0';

    // Emails
    public static final String DATA_CLEAN_EMAIL_HEADER_HTML = 'Organization Name: <b>{0}</b><br/>Organization Id: <b>{1}</b><br/><br/>';
    public static final String DATA_CLEAN_EMAIL_HEADER_PLAIN_TEXT = 'Organization Name: {0}\nOrganization Id: {1}\n\n';

    public static final String DATA_CLEAN_EMAIL_FOOTER_HTML = '<br/>Data Clean V1.5™, Copyright © 2021 oqct.com. All rights reserved.';
    public static final String DATA_CLEAN_EMAIL_FOOTER_PLAIN_TEXT = '\n\nData Clean V1.5™, Copyright © 2021 oqct.com. All rights reserved.';

    public static final String DATA_CLEAN_EMAIL_SENDER_DISPLAY_NAME = 'Data Clean For Salesforce';

    public static final String DATA_CLEAN_EMAIL_SUBJECT_DC_CONFIGURATION_DELETE = 'Delete Completed - Data Clean Configurations';
    public static final String DATA_CLEAN_EMAIL_SUBJECT_FILES_CLEANUP = 'Clean-Up Completed - Data Clean Files';
    public static final String DATA_CLEAN_EMAIL_SUBJECT_NEW_CONFIGURATION_CREATED = 'New Data Clean Configuration Created';
    public static final String DATA_CLEAN_EMAIL_SUBJECT_PROCESS_COMPLETED = 'Data Clean {0} Process Completed';

    public static final String DATA_CLEAN_EMAIL_BODY_PROCESS_COMPLETED = 'Data Clean <b>{0}</b> Process Successfully Completed for configuration <b>{1}</b>.<br/>The result record associated is <b>{2}</b>.<br/>Following is the summary of the result:<br/><br/>';

    public static final Decimal DATA_CLEAN_EMAIL_ATTACHMENT_THRESHOLD = 26214400;
    
    // CronTrigger State
    public static final String CRON_TRIGGER_STATE_WAITING = 'WAITING';
    public static final String CRON_TRIGGER_STATE_COMPLETE = 'COMPLETE';
    public static final String CRON_TRIGGER_STATE_DELETED = 'DELETED';

    // Schedule Job Suffixes
    public static final String JOB_SUFFIX_MASK = '-Mask';
    public static final String JOB_SUFFIX_DELETE = '-Delete';
    public static final String JOB_SUFFIX_ROLLBACK = '-Rollback';
    public static final String JOB_SUFFIX_ARCHIVE = '-Archive';
    public static final String JOB_SUFFIX_CLONE = '-Clone';
    public static final String JOB_SUFFIX_AUTO_DELETE_BACKUP = '-Auto-Delete-Backup';
    public static final String JOB_SUFFIX_GENERIC = '';

    // Master and Related
    public static final String PARENT = 'Parent';
    public static final String CHILD = 'Child';

    // Batch Job Names
    public enum BATCH_TYPE {BATCH_MASK, BATCH_DELETE, BATCH_LARGE_RELATED_MASK, BATCH_LARGE_RELATED_DELETE, BATCH_ARCHIVE, BATCH_LARGE_RELATED_ARCHIVE, BATCH_CLONE, BATCH_ROLLBACK, BATCH_AUTO_DELETE_BACKUP}

    // Batch Method
    public enum BATCH_METHOD {BATCH_START, BATCH_EXECUTE_START, BATCH_EXECUTE_END, BATCH_FINSIH_PARENT, BATCH_FINSIH_CHILD, BATCH_FINSIH_ALL}

    // Batch Size
    public static final Integer BATCH_SIZE_MASK = 5;
    public static final Integer BATCH_SIZE_MASK_PARENT = 50;
    public static final Integer BATCH_SIZE_DELETE = 5;
    public static final Integer BATCH_SIZE_DELETE_PARENT = 50;
    public static final Integer BATCH_SIZE_ARCHIVE = 5;
    public static final Integer BATCH_SIZE_ARCHIVE_PARENT = 50;
    public static final Integer BATCH_SIZE_CLONE = 5;
    public static final Integer BATCH_SIZE_CLONE_PARENT = 50;
    public static final Integer BATCH_SIZE_ROLLBACK = 50;
    public static final Integer BATCH_SIZE_LARGE_RELATED_MASK = 50;
    public static final Integer BATCH_SIZE_LARGE_RELATED_DELETE = 50;
    public static final Integer BATCH_SIZE_LARGE_RELATED_ARCHIVE = 50;
    public static final Integer BATCH_SIZE_LARGE_RELATED_CLONE = 50;

    // Batch Constants
    public static final String MASTER_OBJECT_SUFFIX = '__Master';
    public static final String OBJECT_NAME_SUFFIX = '__c';
    public static final String FIELD_NAME_SUFFIX = '__c';
    public static final String FIELD_NAME_PERSON_ACCOUNT_SUFFIX = '__pc';
    public static final String RELATIONSHIP_SUFFIX = '__r';
    public static final Integer RELATED_RECORD_COUNT_FOR_LARGE_BATCH = 100;
    public static final Long  BATCH_HEAP_SIZE_CAPPING = (Limits.getLimitHeapSize() / 2) - 1000000;

    // File Prefixes
    public static final String FILE_PREFIX_SUCCESS = 'Success-';
    public static final String FILE_PREFIX_ERROR = 'Error-';
    public static final String FILE_PREFIX_BACKUP = 'Backup-';

    // File Extensions
    public static final String FILE_EXTENSION_JSON = '.json';
    public static final String FILE_EXTENSION_CSV = '.csv';

    // CSV File Headers and Values
    public static final String FILE_HEADER_MASTER_ID = 'Master Id';
    public static final String FILE_HEADER_RECORD_ID = 'Record Id';
    public static final String FILE_HEADER_OBJECT = 'Object Name';
    public static final String FILE_HEADER_ACTION = 'Action';
    public static final String FILE_HEADER_RESULT = 'Result';
    public static final String FILE_HEADER_ERROR_STATUS_CODES = 'Error Reason(s)';
    public static final String FILE_HEADER_ERROR_MESSAGES = 'Error Message(s)';
    public static final String FILE_VALUE_SUCCESS = 'Success';
    public static final String FILE_VALUE_ERROR = 'Error';

    // CSV File Errors
    public static final String CSV_BUILDER_INVALID_ROW_ERROR = 'The number of columns provided does not match those already in the csv';

    // Data Set Names (Used in Datatable)
    public static final String DATA_SET_DATA_CLEAN_CONFIGURATIONS = 'Data Clean Configurations';
    public static final String DATA_SET_DATA_CLEANS = 'Data Cleans';
    public static final String DATA_SET_DATA_CLEAN_RESULTS = 'Data Clean Results';
    public static final String DATA_SET_DATA_CLEAN_FILES = 'Data Clean Files';

    // Switch (Toggle) Text
    public static final String TOGGLE_ACTIVE = 'Active';
    public static final String TOGGLE_INACTIVE = 'Inactive';
    public static final String TOGGLE_SELECTED = 'Selected';
    public static final String TOGGLE_NOT_SELECTED = 'Not Selected';
    public static final String TOGGLE_ENABLED = 'Enabled';
    public static final String TOGGLE_DISABLED = 'Disabled';
    public static final String TOGGLE_YES = 'Yes';
    public static final String TOGGLE_NO = 'No';

    // Special String Literals
    public static final String LITERAL_COMMA = ',';
    public static final String LITERAL_COMMA_SEPARATOR = ', ';
    public static final String LITERAL_SINGLE_QUOTE = '\'';
    public static final String LITERAL_GREATER_THAN = '>';
    public static final String LITERAL_LESS_THAN = '<';
    public static final String LITERAL_EQUAL_TO = '=';
    public static final String LITERAL_OPEN_BRACKET = '(';
    public static final String LITERAL_CLOSE_BRACKET = ')';
    public static final String LITERAL_PERCENT = '%';
    public static final String LITERAL_DOT = '.';
    public static final String LITERAL_UNDERSCORE = '_';
    public static final String LITERAL_HYPHEN = '-';
    public static final String LITERAL_COLON = ':';
    public static final String LITERAL_SEMI_COLON = ';';
    public static final String LITERAL_SPACE = ' ';
    public static final String LITERAL_EMPTY = '';
    public static final String LITERAL_NULL = 'null';
    public static final String LITERAL_TRUE = 'true';
    public static final String LITERAL_FALSE = 'false';

    // Escaped Literals
    public static final String ESCAPED_LITERAL_DOT = '\\.';

    // SOQL Clauses
    public static final String CLAUSE_WHERE = 'WHERE';
    public static final String CLAUSE_IN = 'IN';
    public static final String CLAUSE_NOT_IN = 'NOT IN';

    // SOQL Operators
    public static final String SOQL_OPERATOR_EQUAL = ' = ';
    public static final String SOQL_OPERATOR_NOT_EQUAL = ' != ';
    public static final String SOQL_OPERATOR_GREATER_THAN = ' > ';
    public static final String SOQL_OPERATOR_GREATER_THAN_OR_EQUAL = ' >= ';
    public static final String SOQL_OPERATOR_LESS_THAN = ' < ';
    public static final String SOQL_OPERATOR_LESS_THAN_OR_EQUAL = ' <= ';
    public static final String SOQL_OPERATOR_AND = ' AND ';
    public static final String SOQL_OPERATOR_OR = ' OR ';
    public static final String SOQL_OPERATOR_LIKE = ' LIKE ';

    public static final String SOQL_LITERAL_SELECT = 'SELECT';
    public static final String SOQL_LITERAL_FROM = 'FROM';

    public static final String SOQL_BIND_VARIABLE_STRING_LIST = ':stringList';
    public static final String SOQL_BIND_VARIABLE_FILE_PREFIXES = ':filePrefixes';

    // HTML Tags
    public static final String HTML_TAG_UNORDERED_LIST_OPEN = '<ul>';
    public static final String HTML_TAG_UNORDERED_LIST_CLOSE = '</ul>';
    public static final String HTML_TAG_LIST_ELEMENT_OPEN = '<li>';
    public static final String HTML_TAG_LIST_ELEMENT_CLOSE = '</li>';
    public static final String HTML_TAG_BREAK_LINE = '<br/>';
    public static final String HTML_TAG_BOLD_OPEN = '<b>';
    public static final String HTML_TAG_BOLD_CLOSE = '</b>';

}