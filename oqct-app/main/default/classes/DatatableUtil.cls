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
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.CognitiveComplexity,PMD.ExcessiveClassLength')
public with sharing class DatatableUtil {

    @TestVisible private static List<DatatableUtil.FieldSetMember> testFieldSetMembers;

    public static final String DEFAULT_TARGET = '_parent';
    @testvisible
    private static DatatableColumn buildDatatableColumn(
        FieldSetMember fieldSetMember
    ) {
        DatatableColumn datatableColumn = new DatatableColumn();
        datatableColumn.label = fieldSetMember.label;
        datatableColumn.fieldName = fieldSetMember.fieldRelationshipPath == null
            ? fieldSetMember.fieldPath
            : fieldSetMember.fieldRelationshipPath;
        datatableColumn.sortable = false;
        datatableColumn.editable = false;
        datatableColumn.wrapText = true;
        datatableColumn.cellAttributes.alignment = 'left';

        // This way we can set the type of a column
        // We do not get the exact type from schema object which matches to lightning:datatable component structure
        Schema.DisplayType dataType = fieldSetMember.type;

        switch on dataType {
            when BOOLEAN {
                datatableColumn.type = 'boolean';
            }
            when CURRENCY {
                datatableColumn.type = 'currency';
                // datatableColumn.typeAttributes.currencyCode = '';
                // datatableColumn.typeAttributes.currencyDisplayAs = '';
                // datatableColumn.typeAttributes.minimumIntegerDigits = 1;
                // datatableColumn.typeAttributes.minimumFractionDigits = 2;
                // datatableColumn.typeAttributes.maximumFractionDigits = 4;
                // datatableColumn.typeAttributes.minimumSignificantDigits = 1;
                // datatableColumn.typeAttributes.maximumSignificantDigits = 16;
            }
            when DATE {
                // datatableColumn.type = 'date-local';
                // datatableColumn.typeAttributes.day = '2-digit';
                // datatableColumn.typeAttributes.month = 'long';
                // datatableColumn.typeAttributes.year = 'numeric';

                datatableColumn.type = 'date';
                datatableColumn.typeAttributes.day = '2-digit';
                // datatableColumn.typeAttributes.era = '';
                // datatableColumn.typeAttributes.hour = '2-digit';
                // datatableColumn.typeAttributes.hour12 = true;
                // datatableColumn.typeAttributes.minute = '2-digit';
                datatableColumn.typeAttributes.month = '2-digit';
                // datatableColumn.typeAttributes.second = '';
                datatableColumn.typeAttributes.timeZone = Utils.getUserTimeZone();
                // datatableColumn.typeAttributes.timeZoneName = 'short';
                // datatableColumn.typeAttributes.weekday = '';
                datatableColumn.typeAttributes.year = 'numeric';
            }
            when DATETIME {
                datatableColumn.type = 'date';
                datatableColumn.typeAttributes.day = '2-digit';
                // datatableColumn.typeAttributes.era = '';
                datatableColumn.typeAttributes.hour = '2-digit';
                // datatableColumn.typeAttributes.hour12 = true;
                datatableColumn.typeAttributes.minute = '2-digit';
                datatableColumn.typeAttributes.month = '2-digit';
                // datatableColumn.typeAttributes.second = '';
                datatableColumn.typeAttributes.timeZone = Utils.getUserTimeZone();
                // datatableColumn.typeAttributes.timeZoneName = 'short';
                // datatableColumn.typeAttributes.weekday = '';
                datatableColumn.typeAttributes.year = 'numeric';
            }
            when DOUBLE {
                datatableColumn.type = 'number';
                // datatableColumn.typeAttributes.minimumIntegerDigits = 1;
                // datatableColumn.typeAttributes.minimumFractionDigits = 2;
                // datatableColumn.typeAttributes.maximumFractionDigits = 4;
                // datatableColumn.typeAttributes.minimumSignificantDigits = 1;
                // datatableColumn.typeAttributes.maximumSignificantDigits = 16;
            }
            when EMAIL {
                datatableColumn.type = 'email';
            }
            when ENCRYPTEDSTRING {
                datatableColumn.type = 'text';
            }
            when ID {
                datatableColumn.type = 'navigation'; // URL
                datatableColumn.typeAttributes.label = new FieldNameWrapper(
                    fieldSetMember.fieldPath
                );
                datatableColumn.typeAttributes.recordId = new FieldNameWrapper(
                    fieldSetMember.fieldPath
                );
            }
            when INTEGER {
                datatableColumn.type = 'number';
                // datatableColumn.typeAttributes.minimumIntegerDigits = 1;
                // datatableColumn.typeAttributes.minimumFractionDigits = 2;
                // datatableColumn.typeAttributes.maximumFractionDigits = 4;
                // datatableColumn.typeAttributes.minimumSignificantDigits = 1;
                // datatableColumn.typeAttributes.maximumSignificantDigits = 16;
            }
            when LONG {
                datatableColumn.type = 'number';
                // datatableColumn.typeAttributes.minimumIntegerDigits = 1;
                // datatableColumn.typeAttributes.minimumFractionDigits = 2;
                // datatableColumn.typeAttributes.maximumFractionDigits = 4;
                // datatableColumn.typeAttributes.minimumSignificantDigits = 1;
                // datatableColumn.typeAttributes.maximumSignificantDigits = 16;
            }
            when MULTIPICKLIST {
                datatableColumn.type = 'text';
            }
            when PERCENT {
                // https://salesforce.stackexchange.com/questions/235367/how-to-handle-percentage-factor-of-100-problems-when-using-lightninginput-and-l
                // datatableColumn.type = 'percent';
                datatableColumn.type = 'number';
                // datatableColumn.typeAttributes.minimumIntegerDigits = 1;
                // datatableColumn.typeAttributes.minimumFractionDigits = 2;
                // datatableColumn.typeAttributes.maximumFractionDigits = 4;
                // datatableColumn.typeAttributes.minimumSignificantDigits = 1;
                // datatableColumn.typeAttributes.maximumSignificantDigits = 16;
            }
            when PHONE {
                datatableColumn.type = 'phone';
            }
            when PICKLIST {
                datatableColumn.type = 'text';
            }
            when REFERENCE {
                // datatableColumn.type = 'lookup'; // URL
                datatableColumn.type = 'navigation'; // URL
                datatableColumn.typeAttributes.label = new FieldNameWrapper(
                    fieldSetMember.fieldPath
                );
                datatableColumn.typeAttributes.recordId = new FieldNameWrapper(
                    fieldSetMember.fieldPath
                );
                datatableColumn.typeAttributes.rowId = new FieldNameWrapper(
                    Constants.FIELD_RECORD_ID
                );
                datatableColumn.typeAttributes.columnName = fieldSetMember.fieldPath;
            }
            when STRING {
                datatableColumn.type = 'text';
            }
            when TEXTAREA {
                datatableColumn.type = 'text';
                datatableColumn.typeAttributes.linkify = true;
                datatableColumn.wrapText = true;
            }
            when TIME {
                datatableColumn.type = 'date';
                // datatableColumn.typeAttributes.day = '2-digit';
                // datatableColumn.typeAttributes.era = '';
                datatableColumn.typeAttributes.hour = '2-digit';
                // datatableColumn.typeAttributes.hour12 = true;
                datatableColumn.typeAttributes.minute = '2-digit';
                // datatableColumn.typeAttributes.month = '2-digit';
                // datatableColumn.typeAttributes.second = '2-digit';
                datatableColumn.typeAttributes.timeZone = Utils.getUserTimeZone();
                // datatableColumn.typeAttributes.timeZoneName = 'short';
                // datatableColumn.typeAttributes.weekday = ;
                // datatableColumn.typeAttributes.year = 'numeric';
                // datatableColumn.cellAttributes.className = 'slds-text-title_caps';
            }
            when URL {
                datatableColumn.type = 'url';
                datatableColumn.typeAttributes.label = new FieldNameWrapper(
                    fieldSetMember.fieldPath
                );
                datatableColumn.typeAttributes.target = DEFAULT_TARGET;
                datatableColumn.typeAttributes.tooltip = new FieldNameWrapper(
                    fieldSetMember.fieldPath
                );
            }
            when else {
                // datatableColumn.type = 'text';
                datatableColumn = null;
            }
        }
        // override for name field
        if (fieldSetMember.sObjectField.getDescribe().isNameField()) {
            datatableColumn.type = 'navigation'; // URL
            datatableColumn.typeAttributes.label = new FieldNameWrapper(
                datatableColumn.fieldName
            );
            datatableColumn.typeAttributes.recordId = new FieldNameWrapper(
                Constants.FIELD_RECORD_ID
            );
            if (fieldSetMember.nameFieldToStandardPage == null || !fieldSetMember.nameFieldToStandardPage) {
                datatableColumn.typeAttributes.pageReferencetype = 'custom__raiseEvent';
                datatableColumn.typeAttributes.rowId = new FieldNameWrapper(
                    Constants.FIELD_RECORD_ID
                );
                datatableColumn.typeAttributes.columnName = fieldSetMember.fieldPath;
            }
        }
        return datatableColumn;
    }
	@testvisible
    private static List<SObject> buildDatatableRow(
        List<String> fieldsToQuery,
        DatatableRequestParameters datatableRequestParams
    ) {
        if (!Utils.objectValidation(datatableRequestParams.objectName)) {
            return new List<SObject>();
        }
        if (!Utils.fieldsValidation(datatableRequestParams.objectName, fieldsToQuery) && !Utils.fieldSetValidation(datatableRequestParams.objectName, datatableRequestParams.fieldSetName)) {
            return new List<SObject>();
        }
        QueryBuilder.QueryBuilderParameters queryBuilderParams = new QueryBuilder.QueryBuilderParameters();
        queryBuilderParams.objectName = datatableRequestParams.objectName;
        queryBuilderParams.fieldApiNames = fieldsToQuery;
        queryBuilderParams.fieldSetName = datatableRequestParams.fieldSetName;
        queryBuilderParams.whereClauseCondition = datatableRequestParams.whereClauseCondition;
        queryBuilderParams.sortField = datatableRequestParams.sortField;
        queryBuilderParams.sortDirection = datatableRequestParams.sortDirection;
        queryBuilderParams.recordLimit = datatableRequestParams.recordLimit;
        queryBuilderParams.offset = datatableRequestParams.offset;
        return QueryBuilder.getQueryResults(queryBuilderParams);
    }

    /**
     * @description Method to prepare Lightning Datatable structure based on field set
     *
     * @param strObjectName sObject name from which data will be fetched
     * @param objectIdsForQuery Set of IDs as condition to SOQL
     * @param strFieldSetName name of the field set which contains columns to be fetched
     * @param datatableRequestParams.additionalFields list of additional hidden fields to query
     *
     * @return structure of Lighting Datatable
     */
    // !Todo: Parent Field itself is reference type
    // !Todo: More than one level deep child to parent
    @SuppressWarnings('PMD.CognitiveComplexity,PMD.NcssMethodCount,PMD.AvoidDeeplyNestedIfStmts')
    public static DatatableResponse fetchDatatableResponse(
        DatatableRequestParameters datatableRequestParams
    ) {
        //The final wrapper response to return to component
        DatatableResponse response = new DatatableResponse();

        //To hold the table column structure in order to build Lightning Datatable
        List<DatatableColumn> datatableColumns = new List<DatatableColumn>();

        //Field to be queried - fetched from fieldset
        List<String> fieldsToQuery = new List<String>();

        Set<String> currencyFieldsInQuery = new Set<String>();

        Map<String, string> referenceField2parentObjectApiName = new Map<String, string>();

        if (datatableRequestParams.fieldSetName != null) {
            //Get the fields from FieldSet
            Schema.FieldSet fieldSetObj = Utils.GLOBAL_DESCRIBE_MAP_CACHE.get(
                    datatableRequestParams.objectName
                )
                ?.getDescribe()
                ?.FieldSets
                ?.getMap()
                ?.get(datatableRequestParams.fieldSetName);

            List<DatatableUtil.FieldSetMember> fieldSetMembers = new List<DatatableUtil.FieldSetMember>();

            if (fieldSetObj == null) {
                if (DatatableUtil.testFieldSetMembers == null) {
                    return response;
                } else {
                    fieldSetMembers = DatatableUtil.testFieldSetMembers;
                }
            } else {
                fieldSetMembers = DatatableUtil.getCustomFieldSetMemberList(fieldSetObj.getFields());
            }

            for (
                DatatableUtil.FieldSetMember fieldSetMember : fieldSetMembers
            ) {
                fieldSetMember.nameFieldToStandardPage = datatableRequestParams.nameFieldToStandardPage;

                // Collect Reference type of field to query label from parent
                if (
                    fieldSetMember.type ==
                    Schema.DisplayType.REFERENCE
                ) {
                    String parentObjectName = fieldSetMember.sobjectfield
                            .getDescribe()
                            .getReferenceTo()[0]
                        .getDescribe()
                        .getName();
                    referenceField2parentObjectApiName.put(
                        fieldSetMember.fieldpath,
                        parentObjectName
                    );
                }

                DatatableColumn dtc = buildDatatableColumn(fieldSetMember);

                if (dtc != null) {
                    datatableColumns.add(dtc);
                }

                if (
                    Utils.isMultiCurrencyOrganization() &&
                    fieldSetMember.type == Schema.DisplayType.CURRENCY
                ) {
                    if (currencyFieldsInQuery.add(fieldSetMember.fieldpath)) {
                        fieldsToQuery.add(
                            getCurrencySoqlStatement(fieldSetMember)
                        );
                    }
                } else {
                    fieldsToQuery.add(fieldSetMember.fieldpath);
                }

                if (!fieldsToQuery.contains(Constants.FIELD_RECORD_ID)) {
                    fieldsToQuery.add(0, Constants.FIELD_RECORD_ID);
                }
            }
        } else if (datatableRequestParams.fieldApiNames != null) {
            Map<String, Schema.SObjectField> schemaFieldMap = Utils.GLOBAL_DESCRIBE_MAP_CACHE.get(
                    datatableRequestParams.objectName
                )
                ?.getDescribe()
                ?.fields
                ?.getMap();

            if (schemaFieldMap == null) {
                return response;
            }

            Map<String, List<FieldWithPosition>> parentObject2Fields = new Map<String, List<FieldWithPosition>>();
            for (
                Integer i = 0;
                i < datatableRequestParams.fieldApiNames.size();
                i++
            ) {
                Schema.DescribeFieldResult schemaFieldDescription = schemaFieldMap.get(
                        datatableRequestParams.fieldApiNames[i]
                    )
                    ?.getDescribe();

                // Handle Child-to-Parent Relationship fields
                if (schemaFieldDescription == null) {
                    List<String> parentRelationships = datatableRequestParams.fieldApiNames[
                            i
                        ]
                        .split('\\.', 5);
                    if (
                        parentRelationships.size() > 0 &&
                        !datatableRequestParams.fieldApiNames[i].endsWith('.')
                    ) {
                        if (
                            parentRelationships[0] !=
                            datatableRequestParams.objectName
                        ) {
                            String relationshipFieldName;
                            if (parentRelationships[0].endsWith('__r')) {
                                relationshipFieldName = parentRelationships[0]
                                    .replace('__r', '__c');
                            } else {
                                relationshipFieldName =
                                    parentRelationships[0] + Constants.FIELD_RECORD_ID;
                            }
                            if (relationshipFieldName == null) {
                                continue;
                            }
                            String parentObjectName = schemaFieldMap.get(
                                        relationshipFieldName
                                    )
                                    ?.getDescribe()
                                    .getReferenceTo()[0]
                                .getDescribe()
                                .getName();
                            if (parentObjectName == 'Group') {
                                parentObjectName = 'User'; // Group
                            }
                            if (
                                !parentObject2Fields.containsKey(
                                    parentObjectName
                                )
                            ) {
                                parentObject2Fields.put(
                                    parentObjectName,
                                    new List<FieldWithPosition>{
                                        new FieldWithPosition(
                                            parentRelationships[1], // Vague Logic
                                            i,
                                            datatableRequestParams.fieldApiNames[
                                                i
                                            ]
                                        )
                                    }
                                );
                            } else {
                                parentObject2Fields.get(parentObjectName)
                                    .add(
                                        new FieldWithPosition(
                                            parentRelationships[1], // Vague Logic
                                            i,
                                            datatableRequestParams.fieldApiNames[
                                                i
                                            ]
                                        )
                                    );
                            }
                        }
                    }
                    continue;
                }

                FieldSetMember fieldSetMember = new FieldSetMember();
                fieldSetMember.fieldpath = schemaFieldDescription.getName();
                fieldSetMember.label = schemaFieldDescription.getLabel();
                fieldSetMember.type = schemaFieldDescription.getType();
                fieldSetMember.dbrequired = !schemaFieldDescription.isNillable(); // Vague Logic
                fieldSetMember.required = !schemaFieldDescription.isNillable(); // Vague Logic
                fieldSetMember.sobjectfield = schemaFieldDescription.getSobjectField();
                fieldSetMember.nameFieldToStandardPage = datatableRequestParams.nameFieldToStandardPage;

                // Collect Reference type of field to query label from parent
                if (
                    schemaFieldDescription.getType() ==
                    Schema.DisplayType.REFERENCE
                ) {
                    String parentObjectName = schemaFieldDescription.getSobjectField()
                            .getDescribe()
                            .getReferenceTo()[0]
                        .getDescribe()
                        .getName();
                    referenceField2parentObjectApiName.put(
                        schemaFieldDescription.getName(),
                        parentObjectName
                    );
                }

                DatatableColumn dtc = buildDatatableColumn(fieldSetMember);

                if (dtc != null) {
                    datatableColumns.add(dtc);
                }

                if (
                    Utils.isMultiCurrencyOrganization() &&
                    fieldSetMember.type == Schema.DisplayType.CURRENCY
                ) {
                    if (currencyFieldsInQuery.add(fieldSetMember.fieldpath)) {
                        fieldsToQuery.add(
                            getCurrencySoqlStatement(fieldSetMember)
                        );
                    }
                } else {
                    fieldsToQuery.add(fieldSetMember.fieldpath);
                }

                if (!fieldsToQuery.contains(Constants.FIELD_RECORD_ID)) {
                    fieldsToQuery.add(0, Constants.FIELD_RECORD_ID);
                }
            }

            try {
                // Prepare DatatableColumn for Child-to-Parent relationship fields
                for (
                    String parentObjectApiName : parentObject2Fields.keySet()
                ) {
                    Map<String, Schema.SObjectField> schemaParentFieldMap = Utils.GLOBAL_DESCRIBE_MAP_CACHE.get(
                            parentObjectApiName
                        )
                        .getDescribe()
                        .fields
                        .getMap();
                    for (
                        FieldWithPosition fldWithPos : parentObject2Fields.get(
                            parentObjectApiName
                        )
                    ) {
                        Schema.DescribeFieldResult schemaParentFieldDescription = schemaParentFieldMap.get(
                                fldWithPos.fieldApiName
                            )
                            .getDescribe();

                        FieldSetMember fieldSetMember = new FieldSetMember();
                        fieldSetMember.fieldpath = schemaParentFieldDescription.getName();
                        fieldSetMember.fieldRelationshipPath = fldWithPos.fieldToQueryFullName;
                        fieldSetMember.label = schemaParentFieldDescription.getLabel();
                        fieldSetMember.type = schemaParentFieldDescription.getType();
                        fieldSetMember.dbrequired = !schemaParentFieldDescription.isNillable(); // Vague Logic
                        fieldSetMember.required = !schemaParentFieldDescription.isNillable(); // Vague Logic
                        fieldSetMember.sobjectfield = schemaParentFieldDescription.getSobjectField();
                        fieldSetMember.nameFieldToStandardPage = datatableRequestParams.nameFieldToStandardPage;

                        DatatableColumn dtc = buildDatatableColumn(
                            fieldSetMember
                        );

                        if (dtc != null) {
                            if (fldWithPos.position < datatableColumns.size()) {
                                datatableColumns.add(fldWithPos.position, dtc);
                            } else {
                                datatableColumns.add(dtc);
                            }
                        }

                        // Also add Child-to-Parent relationship fields in query
                        if (
                            Utils.isMultiCurrencyOrganization() &&
                            fieldSetMember.type == Schema.DisplayType.CURRENCY
                        ) {
                            if (
                                currencyFieldsInQuery.add(
                                    fldWithPos.fieldToQueryFullName
                                )
                            ) {
                                fieldsToQuery.add(
                                    getCurrencySoqlStatement(fieldSetMember)
                                );
                            }
                        } else {
                            fieldsToQuery.add(fldWithPos.fieldToQueryFullName);
                        }
                    }
                }
            } catch (Exception e) {
                Utils.debug('Datatable Column Preparation Error', e.getMessage() + ' : ' +  e.getLineNumber());
            }
        }

        Map<String, String> objectApiName2NameField = new Map<String, String>();

        for (FieldDefinition fldDef : FieldDefinitionSelector.getAllFieldDefinitionsNameFieldByEntityDefinitionQualifiedApiNames(referenceField2parentObjectApiName.values())) {
            objectApiName2NameField.put(
                fldDef.EntityDefinition.QualifiedApiName,
                fldDef.QualifiedApiName
            );
        }

        for (DatatableColumn dtc : datatableColumns) {
            if (referenceField2parentObjectApiName.containsKey(dtc.fieldName)) {
                String referenceFieldPath;
                if (dtc.fieldName.endsWith('__c')) {
                    referenceFieldPath = dtc.fieldName.replace('__c', '__r');
                } else if (dtc.fieldName.endsWith(Constants.FIELD_RECORD_ID)) {
                    referenceFieldPath = dtc.fieldName.removeEndIgnoreCase(
                        Constants.FIELD_RECORD_ID
                    );
                }
                String referenceFieldFull =
                    referenceFieldPath +
                    '.' +
                    objectApiName2NameField.get(
                        referenceField2parentObjectApiName.get(dtc.fieldName)
                    );
                dtc.typeAttributes.label = new FieldNameWrapper(
                    referenceFieldFull
                );
                dtc.typeAttributes.title = new FieldNameWrapper(
                    referenceFieldFull
                );
                if (!fieldsToQuery.contains(referenceFieldFull)) {
                    fieldsToQuery.add(referenceFieldFull);
                }
            }
        }

        if (datatableRequestParams.additionalFields != null) {
            for (
                String additionalField : datatableRequestParams.additionalFields
            ) {
                if (
                    !fieldsToQuery.contains(additionalField) &&
                    !currencyFieldsInQuery.contains(additionalField)
                ) {
                    fieldsToQuery.add(additionalField);
                }
            }
        }

        if (!datatableColumns.isEmpty()) {
            response.datatableColumns = datatableColumns;
        }

        //Form an SOQL to fetch the data - Set the wrapper instance and return as response
        response.datatableData = buildDatatableRow(
            fieldsToQuery,
            datatableRequestParams
        );

        return response;
    }

    private static List<DatatableUtil.FieldSetMember> getCustomFieldSetMemberList(List<Schema.FieldSetMember> schemaFieldSetMembers){
        List<FieldSetMember> fieldSetMembers = new List<FieldSetMember>();
        for (Schema.FieldSetMember schemaFieldSetMember : schemaFieldSetMembers) {
            FieldSetMember fieldSetMember = new FieldSetMember();
            fieldSetMember.fieldpath = schemaFieldSetMember.getFieldPath();
            fieldSetMember.label = schemaFieldSetMember.getLabel();
            fieldSetMember.type = schemaFieldSetMember.getType();
            fieldSetMember.dbrequired = schemaFieldSetMember.getDbRequired();
            fieldSetMember.required = schemaFieldSetMember.getRequired();
            fieldSetMember.sobjectfield = schemaFieldSetMember.getSObjectField();
            fieldSetMembers.add(fieldSetMember);
        }
        return fieldSetMembers;
    }

    private static String getCurrencySoqlStatement(
        FieldSetMember fieldSetMember
    ) {
        return 'convertCurrency(' +
            String.valueOf(fieldSetMember.fieldPath) +
            ') ' +
            fieldSetMember.fieldPath;
    }

    public with sharing class FieldSetMember {
        public String fieldPath;

        public String fieldRelationshipPath;

        public String label;

        public Schema.DisplayType type;

        public Boolean dbRequired;

        public Boolean required;

        public Schema.sObjectField sObjectField;

        public Boolean nameFieldToStandardPage;
    }

    public with sharing class FieldWithPosition {
        public String fieldApiName;

        public Integer position;

        public String fieldToQueryFullName;

        public FieldWithPosition(
            String fieldApiName,
            Integer position,
            String fieldToQueryFullName
        ) {
            this.fieldApiName = fieldApiName;
            this.position = position;
            this.fieldToQueryFullName = fieldToQueryFullName;
        }
    }

    /**
     * @description Wrapper class to hold response - This response is used in the lightning:datatable component
     */
    public with sharing class DatatableResponse {
        @AuraEnabled
        public List<DatatableColumn> datatableColumns { get; set; }

        @AuraEnabled
        public List<sObject> datatableData { get; set; }

        public DatatableResponse() {
            this.datatableColumns = new List<DatatableColumn>();
            this.datatableData = new List<sObject>();
        }
    }

    /**
     * @description Wrapper class to store Columns with headers
     */
    @SuppressWarnings('PMD.ExcessivePublicCount')
    public with sharing class DatatableColumn {
        @AuraEnabled
        public String label; // (String) Required

        @AuraEnabled
        public String fieldName; // Required

        @AuraEnabled
        public String type;

        @AuraEnabled
        public Boolean sortable;

        @AuraEnabled
        public Boolean editable;

        @AuraEnabled
        public Integer initialWidth;

        @AuraEnabled
        public Integer fixedWidth;

        @AuraEnabled
        public Boolean hideDefaultActions;

        @AuraEnabled
        public String iconName;

        @AuraEnabled
        public Boolean wrapText;

        @AuraEnabled
        public DatatableColumnTypeAttribute typeAttributes;

        @AuraEnabled
        public DatatableColumnCellAttribute cellAttributes;

        //Create and set three variables label, fieldname and type as required by the lightning:datatable
        public DatatableColumn() {
            this.typeAttributes = new DatatableColumnTypeAttribute();
            this.cellAttributes = new DatatableColumnCellAttribute();
        }
    }

    /**
     * @description Wrapper class to store Columns Type attributes
     */
    @SuppressWarnings('PMD.TooManyFields,PMD.ExcessivePublicCount')
    public with sharing class DatatableColumnTypeAttribute {
        // TYPE: boolean
        // SUPPORTED TYPE ATTRIBUTES: N/A

        // TYPE: button
        // SUPPORTED TYPE ATTRIBUTES: disabled, iconName, iconPosition, label, name, title, variant

        // TYPE: button-icon
        // SUPPORTED TYPE ATTRIBUTES: alternativeText, class(className), disabled, iconClass, iconName, name, title, variant

        // TYPE: currency
        // SUPPORTED TYPE ATTRIBUTES: currencyCode, currencyDisplayAs, minimumIntegerDigits,
        //                            minimumFractionDigits, maximumFractionDigits, minimumSignificantDigits,
        //                            maximumSignificantDigits

        // TYPE: date
        // SUPPORTED TYPE ATTRIBUTES: day, era, hour, hour12, minute, month, second, timeZone, timeZoneName, weekday, year

        // TYPE: date-local
        // SUPPORTED TYPE ATTRIBUTES: day, month, year

        // TYPE: email
        // SUPPORTED TYPE ATTRIBUTES: N/A

        // TYPE: location
        // SUPPORTED TYPE ATTRIBUTES: latitude, longitude

        // TYPE: number
        // SUPPORTED TYPE ATTRIBUTES: minimumIntegerDigits, minimumFractionDigits, maximumFractionDigits, minimumSignificantDigits, maximumSignificantDigits

        // TYPE: percent
        // SUPPORTED TYPE ATTRIBUTES: minimumIntegerDigits, minimumFractionDigits, maximumFractionDigits, minimumSignificantDigits, maximumSignificantDigits

        // TYPE: phone
        // SUPPORTED TYPE ATTRIBUTES: N/A

        // TYPE: text
        // SUPPORTED TYPE ATTRIBUTES: linkify

        // TYPE: url
        // SUPPORTED TYPE ATTRIBUTES: label, target, tooltip

        // TYPE: action
        // SUPPORTED TYPE ATTRIBUTES: rowActions (required), menuAlignment (defaults to right)

        // CUSTOM TYPES

        // TYPE: navigation
        // SUPPORTED TYPE ATTRIBUTES: label, title, target, pageReferencetype, recordId, actionName, pageName, pageApiName, objectApiName, relationshipApiName, columnName, rowId, showAsAnIcon

        // TYPE: toggleButton
        // SUPPORTED TYPE ATTRIBUTES: buttonDisabled, rowId, checked, showLabel, label, showToggleOnOffText, toggleOnText, toggleOffText, toggleColor

        // TYPE: lookup
        // SUPPORTED TYPE ATTRIBUTES: TO-DO

        // TYPE: mUltiSelectPicklist
        // SUPPORTED TYPE ATTRIBUTES: TO-DO

        // TYPE: picklist
        // SUPPORTED TYPE ATTRIBUTES: TO-DO

        // TYPE: textArea
        // SUPPORTED TYPE ATTRIBUTES: TO-DO

        // TYPE: textAreaLong
        // SUPPORTED TYPE ATTRIBUTES: TO-DO

        // TYPE: textAreaRich
        // SUPPORTED TYPE ATTRIBUTES: TO-DO

        // TYPE: textEncrypted
        // SUPPORTED TYPE ATTRIBUTES: TO-DO

        @AuraEnabled
        public Object disabled; // String

        @AuraEnabled
        public String iconName; // String

        @AuraEnabled
        public String iconPosition; // String

        @AuraEnabled
        public Object label; // String

        @AuraEnabled
        public String name; // String

        @AuraEnabled
        public Object title; // String

        @AuraEnabled
        public String variant; // String

        @AuraEnabled
        public String alternativeText; // String

        @AuraEnabled
        public String className; // String

        @AuraEnabled
        public String iconClass; // String

        @AuraEnabled
        public String currencyCode; // String

        @AuraEnabled
        public String currencyDisplayAs; // String

        @AuraEnabled
        public Integer minimumIntegerDigits; // Integer

        @AuraEnabled
        public Integer minimumFractionDigits; // Integer

        @AuraEnabled
        public Integer maximumFractionDigits; // Integer

        @AuraEnabled
        public Integer minimumSignificantDigits; // Integer

        @AuraEnabled
        public Integer maximumSignificantDigits; // Integer

        @AuraEnabled
        public String day; // String

        @AuraEnabled
        public String era; // String

        @AuraEnabled
        public String hour; // String

        @AuraEnabled
        public Boolean hour12; // Boolean

        @AuraEnabled
        public String minute; // String

        @AuraEnabled
        public String month; // String

        @AuraEnabled
        public String second; // String

        @AuraEnabled
        public String timeZone; // String

        @AuraEnabled
        public String timeZoneName; // String

        @AuraEnabled
        public String weekday; // String

        @AuraEnabled
        public String year; // String

        @AuraEnabled
        public String latitude; // String

        @AuraEnabled
        public String longitude; // String

        @AuraEnabled
        public Boolean linkify; // Boolean

        @AuraEnabled
        public String target; // String

        @AuraEnabled
        public Object tooltip; // String

        @AuraEnabled
        public String pageReferencetype; // String

        @AuraEnabled
        public FieldNameWrapper recordId; // String

        @AuraEnabled
        public String actionName; // String

        @AuraEnabled
        public String pageName; // String

        @AuraEnabled
        public String pageApiName; // String

        @AuraEnabled
        public String objectApiName; // String

        @AuraEnabled
        public Boolean showAsAnIcon; // Boolean

        @AuraEnabled
        public String relationshipApiName; // String

        @AuraEnabled
        public Boolean buttonDisabled; // Boolean

        @AuraEnabled
        public FieldNameWrapper rowId; // String

        @AuraEnabled
        public String columnName; // String

        @AuraEnabled
        public Object checked; // Boolean

        @AuraEnabled
        public Boolean showLabel; // Boolean

        @AuraEnabled
        public Boolean showToggleOnOffText; // Boolean

        @AuraEnabled
        public String toggleOnText; // String

        @AuraEnabled
        public String toggleOffText; // String

        @AuraEnabled
        public String toggleColor; // String
    }

    public with sharing class DatatableColumnCellAttribute {
        @AuraEnabled
        public String iconName; // String

        @AuraEnabled
        public String iconLabel; // String

        @AuraEnabled
        public String iconPosition; // String

        @AuraEnabled
        public String iconAlternativeText; // String

        @AuraEnabled
        public String alignment; // String (left/right/center)

        @AuraEnabled
        public String className; // String (class)
    }

    /**
     * @description Wrapper class to store field names
     */
    public with sharing class FieldNameWrapper {
        @AuraEnabled
        public String fieldName;

        public FieldNameWrapper(String fieldName) {
            this.fieldName = fieldName;
        }
    }

    public with sharing class DatatableRequestParameters {
        @AuraEnabled
        public String objectName { get; set; } // Api Name of the object whose data is to be retrieved

        @AuraEnabled
        public String fieldSetName { get; set; } // These field will be displayed on table

        @AuraEnabled
        public List<String> fieldApiNames { get; set; } // These field will be displayed on table (fieldSetName will take priority)

        @AuraEnabled
        public List<String> additionalFields { get; set; } // These field will not be displayed on table but will be queried and returned

        // If 'true', On clicking standard name field, record detail page will open; if not defined or 'false' will raise custom event
        @AuraEnabled
        public Boolean nameFieldToStandardPage {get; set;} 

        @AuraEnabled
        public String whereClauseCondition { get; set; }

        @AuraEnabled
        public String sortField { get; set; }

        @AuraEnabled
        public String sortDirection { get; set; }

        @AuraEnabled
        public Integer recordLimit { get; set; }

        @AuraEnabled
        public Integer offset { get; set; }
    }
}