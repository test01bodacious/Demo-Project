/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-26
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-05   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.ExcessivePublicCount')
public with sharing class Utils {

    public static final Map<String,SObjectType> GLOBAL_DESCRIBE_MAP_CACHE;
    
    static {
        GLOBAL_DESCRIBE_MAP_CACHE = Schema.getGlobalDescribe();
    }

    public static final List<String> OBJECT_API_NAMES_TO_EXCLUDE = new List<String>(); // new List<String>{'history', 'tag', 'share', 'feed'};

    public static final String SALESFORCE_RECORD_ID_REGEX = '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}';

    public static Boolean isValidSalesforceId( String sfdcId, System.Type sObjectType ){
        try {

            if (Pattern.compile(Utils.SALESFORCE_RECORD_ID_REGEX).matcher(sfdcId).matches()) {
                // Try to assign it to an Id before checking the type
                Id id = sfdcId;

                // Use the Type to construct an instance of this sObject
                sObject sObj = (sObject) sObjectType.newInstance();

                // Set the ID of the new object to the value to test
                sObj.Id = id;

                // If the tests passed, it's valid
                return true;
            }
        } catch ( Exception e ){
            // StringException, TypeException
            Utils.debug('Invalid Salesforce Id Exception: ', e.getMessage());
        }
        // ID is not valid
        return false;
    }

    /**
     * Provides label for given object name
     *
     * @param objectName object name for which label needs to be provided
     *
     * @return label
     */
    public static String getLabelForObject(String objectName){
        return Utils.getSObjectDescription(objectName).getLabel();
    }

    /**
     * Provides label for given object and field name
     *
     * @param objectName object name
     * @param fieldName field for which label needs to be provided
     *
     * @return label
     */
    public static String getLabelForField(String objectName, String fieldName){
        return Utils.getSObjectFieldMap(objectName).get(fieldName).getDescribe().getLabel();
    }

    public static Set<Id> extractIds(List<SObject> objs) {
        return new Map<Id, SObject>(objs).keySet();
    }

    public static Set<Id> extractIds(List<SObject> objs, SObjectField field) {
        // !Todo: Check if field is valid reference type (id) field
        Set<Id> values = new Set<Id>();
        for (SObject obj : objs) {
            String value = String.valueOf(obj.get(field));
            if (String.isNotBlank(value)) {
                values.add(Id.valueOf(value));
            }
        }
        return values;
    }

    /**
     * @description Convert Set of Schema.SObjectField to Set of String
     * 
     * @param fields Set of Schema.SObjectField
     * 
     * @return Set of fields converted as strings
     */
    public static Set<String> convertSObjectFieldToString(Set<Schema.SObjectField> fields) {
        Set<String> fieldsAsStrings = new Set<String>();
        for (Schema.SObjectField f : fields) {
            fieldsAsStrings.add(convertSObjectFieldToString(f));
        }
        return fieldsAsStrings;
    }

    /**
     * @description Convert Schema.SObjectField to String
     * 
     * @param fields Schema.SObjectField
     * 
     * @return Field converted as string
     */
    public static String convertSObjectFieldToString(Schema.SObjectField field) {
        return field.getDescribe().getName();
    }

    public static Map<String, Schema.SObjectField> getSObjectFieldMap(String objectName) {
        return Utils.getSObjectDescription(objectName).Fields.getMap();
    }

    public static Schema.SObjectField getSObjectFieldType(String objectName, String fieldName) {
        return Utils.getSObjectFieldMap(objectName).get(fieldName);
    }

    public static Schema.DisplayType getFieldDisplayType(String objectName, String fieldName) {
        return Utils.getSObjectFieldMap(objectName).get(fieldName).getDescribe().getType();
    }

    public static List<String> filterFieldsForSObject(String objectName, Set<String> fields){
        Set<String> filterFields = new Set<String>();
        Map<String, Schema.SObjectField> fieldsName2SObjectField = Utils.getSObjectFieldMap(objectName);
        for (String field : fields) {
            if (fieldsName2SObjectField.containsKey(field.toLowerCase())) {
                filterFields.add(field.toLowerCase());
            }
        }
        return new List<String>(filterFields);
    }

    public static Boolean objectValidation(String objectName){
        return Utils.GLOBAL_DESCRIBE_MAP_CACHE.containsKey(objectName);
    }

    public static Boolean fieldsValidation(String objectName, List<String> fields){
        Set<String> fieldsToVerify = new Set<String>();
        for (String field : fields) {
            fieldsToVerify.add(field.toLowerCase());
        }
        Map<String, Schema.SObjectField> sObjectFieldMap = Utils.getSObjectFieldMap(objectName);
        fieldsToVerify.removeAll(sObjectFieldMap.keySet());
        return fieldsToVerify.isEmpty();
    }

    public static Boolean fieldSetValidation(String objectName, String fieldSetName){
        Schema.DescribeSObjectResult sObjectDescription = Utils.getSObjectDescription(objectName);
        return sObjectDescription.fieldsets.getMap().containsKey(fieldSetName);
    }

    public static List<SObject> prepareDynamicListofSObject(SObject record){
        String listType = 'List<' + record.getSObjectType() + '>';
        List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
        return castRecords;
    }
    
    public static List<SObject> dynamicCastToListofSObject(List<SObject> records){
        if (records.isEmpty() || records.getSObjectType() != null) {
            return records;
        } else {
            List<SObject> castRecords = Utils.prepareDynamicListofSObject(records[0]);
            castRecords.addAll(records);
            return castRecords;
        }
    }

    public static String convertWhereInClauseFromListtoString(List<Object> whereInClauseList){
        return Utils.convertWhereInClauseFromListtoString(whereInClauseList, true);
    }

    public static String convertWhereInClauseFromListtoString(List<Object> whereInClauseList, Boolean applyQuotes){
        final StringBuilder whereInClauseString = new StringBuilder();
        whereInClauseString.setSeparator(Constants.LITERAL_COMMA_SEPARATOR);
        for (Object whereInClauseVar : whereInClauseList) {
            if (applyQuotes) {
                whereInClauseString.append(Constants.LITERAL_SINGLE_QUOTE + String.escapeSingleQuotes(String.valueOf(whereInClauseVar)) + Constants.LITERAL_SINGLE_QUOTE);
            } else {
                whereInClauseString.append(String.escapeSingleQuotes(String.valueOf(whereInClauseVar)));
            }
        }
        return Constants.LITERAL_OPEN_BRACKET +  whereInClauseString.toString() + Constants.LITERAL_CLOSE_BRACKET;
    }

    public static List<String> getRetryableDCStatuses(){
        List<String> retryableDCStatuses = new List<String>();
        retryableDCStatuses.add(Constants.DC_STATUS_PENDING);
        retryableDCStatuses.add(Constants.DC_STATUS_FAILED);
        retryableDCStatuses.add(Constants.DC_STATUS_NO_RECORDS_FOUND);
        retryableDCStatuses.add(Constants.DC_STATUS_PARTIAL_SUCCESS);
        return retryableDCStatuses;
    }

    public static Schema.SObjectType getSObjectType(String objectName){
	    return GLOBAL_DESCRIBE_MAP_CACHE.get(objectName);
    }

    public static Schema.DescribeSObjectResult getSObjectDescription(String objectName){
	    return Utils.getSObjectType(objectName).getDescribe();
    }

    public static String getLookupFieldName(String parentObjectName, String childObjectName){
        return Utils.getLookupFieldNames(parentObjectName, childObjectName)[0];
    }

    public static List<String> getLookupFieldNames(String parentObjectName, String childObjectName){
	    Schema.DescribeSObjectResult parentObjDescribe = Utils.getSObjectDescription(parentObjectName);
        return Utils.getLookupFieldNames(parentObjDescribe, childObjectName);
    }

    public static List<String> getLookupFieldNames(Schema.DescribeSObjectResult parentObjDescribe, String childObjectName){
        List<String> relRefFields = new List<String>();
        for(Schema.ChildRelationship childRel : parentObjDescribe.getChildRelationships()){
            if (childRel.getChildSObject().getDescribe().getName() == childObjectName){
                relRefFields.add(childRel.getField().getDescribe().getName());
            }
        }
        return relRefFields;
    }

    public static String getOrgBaseUrl(){
        return System.URL.getSalesforceBaseUrl().toExternalForm();
    }

    public static String getRecordLink(Id recordId, String label){
        return '<a href="' + Utils.getOrgBaseUrl() + '/' + recordId + '" target="_blank">' + label + '</a>';
    }

    public static Boolean isFieldHistoryEnabled(String objectName){
        return Utils.GLOBAL_DESCRIBE_MAP_CACHE.containsKey(Utils.getHistoryObjectName(objectName));
    }

    public static String getHistoryObjectName(String objectName){
        Schema.DescribeSObjectResult objectDescribe = Utils.getSObjectDescription(objectName);
        if (objectDescribe.isCustom()) {
            return objectName.removeEnd(Constants.FIELD_NAME_SUFFIX) + Constants.HISTORY_OBJECT_SUFFIX_CUSTOM;
        } else {
            return objectName + Constants.HISTORY_OBJECT_SUFFIX_STANDARD;
        }
    }
    
    // public static String getParentToChildRelationshipName(String parentObjectName, String childObjectName){
	//     Schema.DescribeSObjectResult parentObjDescribe = Utils.getSObjectDescription(parentObjectName);
    //     return Utils.getParentToChildRelationshipName(parentObjDescribe, childObjectName);
    // }

    // public static String getParentToChildRelationshipName(Schema.DescribeSObjectResult parentObjDescribe, String childObjectName){
    //     Map<String, String> rlFldMap = new Map<String, String>();
    //     for (Schema.ChildRelationship cr: parentObjDescribe.getChildRelationships()){
    //         rlFldMap.put(cr.getRelationshipName(), String.valueOf(cr.getChildSObject()));
    //     }
    //     for(String s: rlFldMap.keySet()){
    //         if (rlFldMap.get(s) == childObjectName){
    //             return s;
    //         }
    //     }
    //     return '';
    // }
    
    // public static String getChildToParentRelationshipName(String parentObjectName, String childObjectName){
    //     Schema.DescribeSObjectResult parentObjDescribe = Utils.getSObjectDescription(parentObjectName);
    //     return Utils.getChildToParentRelationshipName(parentObjDescribe, childObjectName);
    // }

    // public static String getChildToParentRelationshipName(Schema.DescribeSObjectResult parentObjDescribe, String childObjectName){
    //     Schema.DescribeFieldResult relFieldDescription;
    //     for(Schema.ChildRelationship childRel : parentObjDescribe.getChildRelationships()){
    //         if (childRel.getChildSObject().getDescribe().getName() == childObjectName){
    //             relFieldDescription = childRel.getField().getDescribe();
    //             break;
    //         }
    //     }
    //     if (relFieldDescription == null) {
    //         return '';
    //     }
    //     if (relFieldDescription.isCustom()){
    //         return relFieldDescription.getName().replace(Constants.FIELD_NAME_SUFFIX, Constants.RELATIONSHIP_SUFFIX);
    //     } else {
    //         return relFieldDescription.getName().replace(Constants.FIELD_RECORD_ID, Constants.LITERAL_EMPTY);
    //     }
    // }

    public static List<String> getMaskableFieldList(String objectApiName){
        List<String> fields = new List<String>();
        Map<String, SObjectField> fieldDescriptionMap = Utils.getSObjectFieldMap(objectApiName);
        for (String fieldApiName : fieldDescriptionMap.keySet()) {
            Schema.DescribeFieldResult fieldDescription = fieldDescriptionMap.get(fieldApiName).getDescribe();
            Schema.DisplayType fieldType = fieldDescription.getType();
            if (fieldDescription.isUpdateable() && 
                    (fieldType != Schema.DisplayType.REFERENCE &&
                    fieldType != Schema.DisplayType.ID  &&
                    fieldType != Schema.DisplayType.LOCATION && 
                    fieldType != Schema.DisplayType.ADDRESS &&
                    fieldType != Schema.DisplayType.SOBJECT &&
                    fieldType != Schema.DisplayType.ANYTYPE &&
                    fieldType != Schema.DisplayType.COMBOBOX && 
                    fieldType != Schema.DisplayType.COMPLEXVALUE && 
                    fieldType != Schema.DisplayType.DATACATEGORYGROUPREFERENCE && 
                    fieldType != Schema.DisplayType.JSON)) {
                fields.add(fieldApiName);
            }
        }
        return fields;
    }

    public static List<Options> getObjectListAsOptions(String actionName){
        List<Options> objectOptions = new List<Options>();
        List<String> dataCleanAppCustomObjects = Utils.getDataCleanAppCustomObjects();
        for (String objectApiName : GLOBAL_DESCRIBE_MAP_CACHE.keySet()) {
            Schema.DescribeSObjectResult objectDescription = Utils.getSObjectDescription(objectApiName);
            Boolean objectLevelSecurity = false;
            if (actionName == Constants.DC_ACTION_MASKING_ONLY || actionName == Constants.DC_ACTION_MASKING_ROLLBACK || actionName == Constants.DC_ACTION_ARCHIVE_DELETION || actionName == Constants.DC_ACTION_ARCHIVE_ROLLBACK) {
                objectLevelSecurity = objectDescription.isUpdateable();
            } else {
                objectLevelSecurity = objectDescription.isUpdateable() && objectDescription.isDeletable();
            }
            Boolean excludeUnwantedObjects = true;
            for (String objectApiNameToExclude : OBJECT_API_NAMES_TO_EXCLUDE) {
                excludeUnwantedObjects = excludeUnwantedObjects && !objectApiName.containsignorecase(objectApiNameToExclude);
            }
            if (!dataCleanAppCustomObjects.contains(objectApiName) && !objectDescription.isCustomSetting() && objectDescription.getRecordTypeInfos().size() > 0 && objectLevelSecurity && excludeUnwantedObjects) {
                Options objectOption = new Options();
                objectOption.label = objectDescription.getLabel();
                objectOption.value = objectApiName;
                objectOptions.add(objectOption);
            }
        }
        return objectOptions;
    }

    public static List<Options> getFieldListAsOptions(String objectApiName){
        List<Options> fieldOptions = new List<Options>();
        Map<String, SObjectField> fieldDescriptionMap = Utils.getSObjectFieldMap(objectApiName);
        for (String fieldApiName : fieldDescriptionMap.keySet()) {
            Schema.DescribeFieldResult fieldDescription = fieldDescriptionMap.get(fieldApiName).getDescribe();
            if (fieldDescription.isUpdateable()) {
                Options fieldOption = new Options();
                fieldOption.label = fieldDescription.getLabel();
                fieldOption.value = fieldApiName;
                fieldOptions.add(fieldOption);
            }
        }
        return fieldOptions;
    }

    public static List<String> getFieldsForBackup(String objectApiName){
        List<String> archivableFields = new List<String>();
        Map<String, SObjectField> fieldDescriptionMap = Utils.getSObjectFieldMap(objectApiName);
        for (String fieldApiName : fieldDescriptionMap.keySet()) {
            Schema.DescribeFieldResult fieldDescription = fieldDescriptionMap.get(fieldApiName).getDescribe();
            Schema.DisplayType fieldType = fieldDescription.getType();
            if (fieldDescription.isUpdateable() && 
                    (fieldType != Schema.DisplayType.BASE64 &&
                    fieldType != Schema.DisplayType.REFERENCE &&
                    fieldType != Schema.DisplayType.ID  &&
                    fieldType != Schema.DisplayType.LOCATION && 
                    fieldType != Schema.DisplayType.ADDRESS &&
                    fieldType != Schema.DisplayType.SOBJECT &&
                    fieldType != Schema.DisplayType.ANYTYPE &&
                    fieldType != Schema.DisplayType.COMBOBOX && 
                    fieldType != Schema.DisplayType.COMPLEXVALUE && 
                    fieldType != Schema.DisplayType.DATACATEGORYGROUPREFERENCE && 
                    fieldType != Schema.DisplayType.JSON)) {
                archivableFields.add(fieldApiName);
            }
        }
        return archivableFields;
    }

    public static List<Options> getMaskableFieldListAsOptions(String objectApiName){
        List<Options> fieldOptions = new List<Options>();
        Map<String, SObjectField> fieldDescriptionMap = Utils.getSObjectFieldMap(objectApiName);
        for (String fieldApiName : fieldDescriptionMap.keySet()) {
            Schema.DescribeFieldResult fieldDescription = fieldDescriptionMap.get(fieldApiName).getDescribe();
            Schema.DisplayType fieldType = fieldDescription.getType();
            if (fieldDescription.isUpdateable() && 
                    (fieldType != Schema.DisplayType.REFERENCE &&
                    fieldType != Schema.DisplayType.ID  &&
                    fieldType != Schema.DisplayType.LOCATION && 
                    fieldType != Schema.DisplayType.ADDRESS &&
                    fieldType != Schema.DisplayType.SOBJECT &&
                    fieldType != Schema.DisplayType.ANYTYPE &&
                    fieldType != Schema.DisplayType.COMBOBOX && 
                    fieldType != Schema.DisplayType.COMPLEXVALUE && 
                    fieldType != Schema.DisplayType.DATACATEGORYGROUPREFERENCE && 
                    fieldType != Schema.DisplayType.JSON)) {
                Options fieldOption = new Options();
                fieldOption.label = fieldDescription.getLabel();
                fieldOption.value = fieldApiName;
                fieldOptions.add(fieldOption);
            }
        }
        return fieldOptions;
    }

    public static List<Options> getNillableFieldListAsOptions(String objectApiName){
        List<Options> fieldOptions = new List<Options>();
        Map<String, SObjectField> fieldDescriptionMap = Utils.getSObjectFieldMap(objectApiName);
        for (String fieldApiName : fieldDescriptionMap.keySet()) {
            Schema.DescribeFieldResult fieldDescription = fieldDescriptionMap.get(fieldApiName).getDescribe();
            Schema.DisplayType fieldType = fieldDescription.getType();
            if (fieldDescription.isUpdateable() && fieldDescription.isNillable() && 
                    (fieldType != Schema.DisplayType.LOCATION && 
                    fieldType != Schema.DisplayType.ADDRESS &&
                    fieldType != Schema.DisplayType.SOBJECT &&
                    fieldType != Schema.DisplayType.ANYTYPE &&
                    fieldType != Schema.DisplayType.COMBOBOX && 
                    fieldType != Schema.DisplayType.COMPLEXVALUE && 
                    fieldType != Schema.DisplayType.DATACATEGORYGROUPREFERENCE && 
                    fieldType != Schema.DisplayType.JSON)) {
                Options fieldOption = new Options();
                fieldOption.label = fieldDescription.getLabel();
                fieldOption.value = fieldApiName;
                fieldOptions.add(fieldOption);
            }
        }
        return fieldOptions;
    }
    

    public static List<Options> getPotentialExternalFieldListAsOptions(String objectApiName){
        List<Options> fieldOptions = new List<Options>();
        Map<String, SObjectField> fieldDescriptionMap = Utils.getSObjectFieldMap(objectApiName);
        for (String fieldApiName : fieldDescriptionMap.keySet()) {
            Schema.DescribeFieldResult fieldDescription = fieldDescriptionMap.get(fieldApiName).getDescribe();
            Schema.DisplayType fieldType = fieldDescription.getType();
            if (fieldDescription.isUpdateable() && 
                    (fieldType == Schema.DisplayType.ID ||
                    fieldType == Schema.DisplayType.DOUBLE ||
                    fieldType == Schema.DisplayType.INTEGER || 
                    fieldType == Schema.DisplayType.LONG || 
                    fieldType == Schema.DisplayType.EMAIL || 
                    fieldType == Schema.DisplayType.STRING)) {
                Options fieldOption = new Options();
                fieldOption.label = fieldDescription.getLabel();
                fieldOption.value = fieldApiName;
                fieldOptions.add(fieldOption);
            }
        }
        return fieldOptions;
    }

    public static List<Options> getRecordTypeListAsOptions(String objectApiName){
        List<Options> recordTypeOptions = new List<Options>();
        List<Schema.RecordTypeInfo> recordTypeInfos = Utils.getSObjectDescription(objectApiName).getRecordTypeInfos();
        for (Schema.RecordTypeInfo rtInfo : recordTypeInfos) {
            Options recordTypeOption = new Options();
            recordTypeOption.label = rtInfo.getName();
            recordTypeOption.value = rtInfo.getRecordTypeId();
            recordTypeOptions.add(recordTypeOption);
        }
        return recordTypeOptions;
    }

    public static List<Options> getRelatedObjectAsOptions(String objectApiName, Boolean checkRecordTypeCount){
        List<Options> relatedObjectOptions = new List<Options>();
        Schema.DescribeSObjectResult objectDescription = Utils.getSObjectDescription(objectApiName);
        Set<String> addedrelatedObjectApiNames = new Set<String>();
        for (Schema.ChildRelationship childRelationship : objectDescription.getChildRelationships()) {
            Schema.DescribeSObjectResult childObjectDescription = childRelationship.getChildSObject().getDescribe();
            String childObjectApiName = childObjectDescription.getName();
            Schema.DescribeFieldResult referenceFieldDescription = childRelationship.getField().getDescribe();
            Boolean recordTypeCondition;
            if (checkRecordTypeCount) {
                recordTypeCondition = childObjectDescription.getRecordTypeInfos().size() > 0;
            } else {
                recordTypeCondition = true;
            }
            Boolean excludeUnwantedObjects = true;
            for (String objectApiNameToExclude : OBJECT_API_NAMES_TO_EXCLUDE) {
                excludeUnwantedObjects = excludeUnwantedObjects && !objectApiName.containsignorecase(objectApiNameToExclude);
            }
            if (!childObjectDescription.isCustomSetting() && recordTypeCondition && childObjectDescription.isUpdateable() &&
                    childObjectDescription.isDeletable() && childObjectDescription.isQueryable() && referenceFieldDescription.isFilterable() && excludeUnwantedObjects) {
                if (!addedrelatedObjectApiNames.contains(childObjectApiName)) {
                    Options relatedObjectOption = new Options();
                    relatedObjectOption.label = childObjectDescription.getLabel();
                    relatedObjectOption.value = childObjectApiName;
                    relatedObjectOptions.add(relatedObjectOption);
                    addedrelatedObjectApiNames.add(childObjectApiName);
                }
            }
        }
        return relatedObjectOptions;
    }

    public static List<String> getDataCleanAppCustomObjects(){
        List<String> dataCleanAppCustomObjects = new List<String>();
        dataCleanAppCustomObjects.add(Constants.OBJECT_DC_CONFIGURATION.toLowerCase());
        dataCleanAppCustomObjects.add(Constants.OBJECT_RELATED_OBJECT.toLowerCase());
        dataCleanAppCustomObjects.add(Constants.OBJECT_RECORD_TYPE_FIELD.toLowerCase());
        dataCleanAppCustomObjects.add(Constants.OBJECT_DATA_CLEAN.toLowerCase());
        dataCleanAppCustomObjects.add(Constants.OBJECT_DATA_CLEAN_RELATED_RESULT.toLowerCase());
        dataCleanAppCustomObjects.add(Constants.OBJECT_DC_RESULTS.toLowerCase());
        dataCleanAppCustomObjects.add(Constants.OBJECT_DC_RELATED_RESULTS.toLowerCase());
        dataCleanAppCustomObjects.add(Constants.OBJECT_DATA_CLEAN_APP_CONFIGURATIONS.toLowerCase());
        dataCleanAppCustomObjects.add(Constants.OBJECT_DC_DATA_TYPE.toLowerCase());
        dataCleanAppCustomObjects.add(Constants.OBJECT_DATA_CLEAN_DELETE_AUDIT.toLowerCase());
        dataCleanAppCustomObjects.add(Constants.OBJECT_DATA_CLEAN_FAILED_CHILD.toLowerCase());
        dataCleanAppCustomObjects.add(Constants.OBJECT_DATA_CLEAN_SUCCESS_CHILD.toLowerCase());
        return dataCleanAppCustomObjects;
    }

    public static String getUserEmail(){
        return UserInfo.getUserEmail();
    }

    public static String getUserId(){
        return UserInfo.getUserId();
    }

    public static String getUserName(){
        return UserInfo.getUserName();
    }

    public static Boolean isMultiCurrencyOrganization(){
        return UserInfo.isMultiCurrencyOrganization();
    }

    public static String getUserTimeZone(){
        return UserInfo.getTimeZone().toString();
    }

    public static String getOrgTimeZone(){
        return OrganizationSelector.getOrganizationForTimeZone().TimeZoneSidKey;
    }

    public static Integer getRemainingQueryRowsLimit() {
        return Limits.getLimitQueryRows() - Limits.getQueryRows();
    }

    public static Integer getRemainingQueryLimit() {
        return Limits.getLimitQueries() - Limits.getQueries();
    }

    public static Integer getRemainingDMLRowsLimit() {
        return Limits.getLimitDMLRows() - Limits.getDMLRows();
    }

    public static Integer getRemainingDMLLimit() {
        return Limits.getLimitDMLStatements() - Limits.getDMLStatements();
    }

    public static void validateQueryStatementLimits(){
        if (Utils.getRemainingQueryLimit() == 0) {
            throw new DataCleanCustomExceptions.SOQLStatementLimitException(Constants.SOQL_STATEMENT_EXCEPTION_MESSAGE);
        }
    }

    public static void debug(String label, Object value) {
        if (Constants.DEBUG_LOG_FLAG) {
            System.debug(LoggingLevel.DEBUG, label + ': ' + String.valueOf(value));
        }
    }

    public static void debug(Object value) {
        if (Constants.DEBUG_LOG_FLAG) {
            System.debug(LoggingLevel.DEBUG, String.valueOf(value));
        }
    }

    public with sharing class Options{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }

    public with sharing class Response{
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String message;
    }

}