import { api, track, wire, LightningElement } from "lwc";

// importing to get the record details based on record id
import { getRecord } from "lightning/uiRecordApi";

// impoting USER id
import USER_ID from "@salesforce/user/Id";

import {
    output,
    showToast,
    sortOptionsByLabel,
    shiftDate,
    getDateAsStringFormatted,
    validateEmail,
    dataCleanConfiguationCreateEditComponentConstants
} from "c/utilsJS";

// Apex Methods (DataCleanConfigurationController)
import getObjectOptions from "@salesforce/apex/DataCleanConfigurationController.getObjectOptions";
import getMaskableFieldOptions from "@salesforce/apex/DataCleanConfigurationController.getMaskableFieldOptions";
import getNillableFieldOptions from "@salesforce/apex/DataCleanConfigurationController.getNillableFieldOptions";
import getPotentialExternalIdFieldOptions from "@salesforce/apex/DataCleanConfigurationController.getPotentialExternalIdFieldOptions";
import getRecordTypeOptions from "@salesforce/apex/DataCleanConfigurationController.getRecordTypeOptions";
import getRelatedObjectOptions from "@salesforce/apex/DataCleanConfigurationController.getRelatedObjectOptions";
import getRelatedObjectRecordTypeOptions from "@salesforce/apex/DataCleanConfigurationController.getRelatedObjectRecordTypeOptions";
import saveDataCleanConfigurations from "@salesforce/apex/DataCleanConfigurationController.saveDataCleanConfigurations";

// User Object Fields
import USER_NAME_FIELD from "@salesforce/schema/User.Name";
const USER_FIELDS = [USER_NAME_FIELD];

// Constants Properties
const CONSTANTS = dataCleanConfiguationCreateEditComponentConstants;

export default class DataCleanConfigurationCreateEdit extends LightningElement {
    // API Properties
    @api isEditMode = false;

    @api configurationData;

    previewData;

    // Track Properties
    @track progressIndiacatorSteps = [
        { value: "step1", label: "Select Action" },
        { value: "step2", label: "Select Object & Match By Field" },
        { value: "step3", label: "Select Record Types & Fields" },
        { value: "step4", label: "Select Related Objects" },
        { value: "step6", label: "Select Date & Time" },
        { value: "step7", label: "Preview Configuration" }
    ];

    @track steps = {
        step1: true,
        step2: false,
        step3: false,
        step4: false,
        step6: false,
        step7: false
    };

    @track modals = {
        fieldSelectorModal: false,
        relatedObjectModal: false
    };

    @track spinners = {
        full: false,
        isFieldSelectorDualListBoxLoading: false,
        isRelatedObjectMaskingSelectorDualListBoxLoading: false,
        isRelatedObjectDeletionSelectorDualListBoxLoading: false
    };

    @track alerts = {
        step6TimeInfo: true,
        step6TimeInfoConfirmationPrompt: false
    };

    @track allObjectOptions;

    @track allFieldOptions;

    @track selectedFieldValues = [];

    @track potentialExternalIdFieldsOptions;

    @track recordTypeColumns = [
        {
            label: "Record Type Id",
            fieldName: "recordTypeId"
        },
        {
            label: "Record Type Name",
            fieldName: "recordTypeName",
            //sortable: true,
            wrapText: true
        },
        {
            label: "Fields To Mask",
            fieldName: "fieldsToMask",
            type: "button",
            wrapText: true,
            typeAttributes: {
                label: "Select Fields to Mask",
                name: "fieldsToMask",
                title: "Select Fields to Mask",
                disabled: { fieldName: "maskFieldSelectedButtonCellDisabled" },
                variant: { fieldName: "maskFieldSelectedButtonCellVariant" },
                iconName: { fieldName: "maskFieldSelectedButtonCellIconName" },
                iconPosition: "right"
            }
        },
        {
            label: "Fields To Empty",
            fieldName: "fieldsToEmpty",
            type: "button",
            wrapText: true,
            typeAttributes: {
                label: "Select Fields to Empty",
                name: "fieldsToEmpty",
                title: "Select Fields to Empty",
                disabled: { fieldName: "emptyFieldSelectedButtonCellDisabled" },
                variant: { fieldName: "emptyFieldSelectedButtonCellVariant" },
                iconName: { fieldName: "emptyFieldSelectedButtonCellIconName" },
                iconPosition: "right"
            }
        },
        {
            label: "Enabled",
            fieldName: "recordTypeEnabled",
            type: "toggleButton",
            typeAttributes: {
                checked: { fieldName: "recordTypeToggleCellChecked" },
                buttonDisabled: { fieldName: "recordTypeToggleCellDisabled" },
                rowId: { fieldName: "recordTypeId" }
            }
        }
    ];

    @track relatedObjectRecordTypeColumns = [
        // {
        //     label: "Related Object Label",
        //     fieldName: "relatedObjectLabel",
        //     sortable: true,
        //     cellAttributes: {
        //         class: { fieldName: "recordTypeActionCellClass" }
        //     }
        // },
        {
            label: "Related Object API Name",
            fieldName: "relatedObjectApiName",
            //sortable: true,
            cellAttributes: {
                class: { fieldName: "recordTypeActionCellClass" }
            }
        },
        {
            label: "Action",
            fieldName: "action",
            //sortable: true,
            wrapText: true,
            cellAttributes: {
                class: { fieldName: "recordTypeActionCellClass" }
            }
        },
        {
            label: "Record Type Id",
            fieldName: "relatedObjectRecordTypeId"
        },
        {
            label: "Record Type Name",
            fieldName: "relatedObjectRecordTypeName",
            //sortable: true,
            wrapText: true
        },
        {
            label: "Fields To Mask",
            fieldName: "fieldsToMask",
            type: "button",
            wrapText: true,
            typeAttributes: {
                label: "Select Fields to Mask",
                name: "fieldsToMask",
                title: "Select Fields to Mask",
                disabled: { fieldName: "maskFieldSelectedButtonCellDisabled" },
                variant: { fieldName: "maskFieldSelectedButtonCellVariant" },
                iconName: { fieldName: "maskFieldSelectedButtonCellIconName" },
                iconPosition: "right"
            }
        },
        {
            label: "Fields To Empty",
            fieldName: "fieldsToEmpty",
            type: "button",
            wrapText: true,
            typeAttributes: {
                label: "Select Fields to Empty",
                name: "fieldsToEmpty",
                title: "Select Fields to Empty",
                disabled: { fieldName: "emptyFieldSelectedButtonCellDisabled" },
                variant: { fieldName: "emptyFieldSelectedButtonCellVariant" },
                iconName: { fieldName: "emptyFieldSelectedButtonCellIconName" },
                iconPosition: "right"
            }
        },
        {
            label: "Enabled",
            fieldName: "recordTypeEnabled",
            type: "toggleButton",
            typeAttributes: {
                checked: { fieldName: "recordTypeToggleCellChecked" },
                buttonDisabled: { fieldName: "recordTypeToggleCellDisabled" },
                rowId: { fieldName: "relatedObjectApiNameAndRecordTypeId" },
                toggleColor: { fieldName: "recordTypeToggleCellColor" }
            },
            cellAttributes: {
                class: { fieldName: "recordTypeActionCellClass" }
            }
        }
    ];

    // [
    //     {
    //         recordId: "",
    //         recordTypeId: "",
    //         recordTypeName: "",
    //         fieldsToMask: [],
    //         fieldsToEmpty: [],
    //         recordTypeEnabled: true,
    //         recordTypeToggleCellChecked: false,
    //         recordTypeToggleCellDisabled: false,
    //         maskFieldSelectedButtonCellDisabled: false,
    //         emptyFieldSelectedButtonCellDisabled: false,
    //         maskFieldSelectedButtonCellVariant: "brand-outline",
    //         maskFieldSelectedButtonCellIconName: "",
    //         emptyFieldSelectedButtonCellVariant: "brand-outline",
    //         emptyFieldSelectedButtonCellIconName: ""
    //     }
    //     {
    //         recordId: "",
    //         recordTypeId: "",
    //         recordTypeName: "",
    //         fieldsToMask: [],
    //         fieldsToEmpty: [],
    //         recordTypeEnabled: false,
    //         recordTypeToggleCellChecked: false,
    //         recordTypeToggleCellDisabled: false,
    //         maskFieldSelectedButtonCellDisabled: false,
    //         emptyFieldSelectedButtonCellDisabled: false,
    //         maskFieldSelectedButtonCellVariant: "brand-outline",
    //         maskFieldSelectedButtonCellIconName: "",
    //         emptyFieldSelectedButtonCellVariant: "brand-outline",
    //         emptyFieldSelectedButtonCellIconName: ""
    //     }
    // ]
    @track recordTypeData;

    // [
    //     {
    //         recordId: "",
    //         recordTypeId: "",
    //         fieldsToMask: [],
    //         fieldsToEmpty: [],
    //         recordTypeEnabled: true
    //     },
    //     {
    //         recordId: "",
    //         recordTypeId: "",
    //         fieldsToMask: [],
    //         fieldsToEmpty: [],
    //         recordTypeEnabled: false
    //     }
    // ];
    @track recordTypeSelectedFields = [];

    @track relatedObjectMaskingOptions = [];

    @track relatedObjectDeletionOptions = [];

    @track selectedRelatedObjectMaskingValues = [];

    @track selectedRelatedObjectDeletionValues = [];

    // [
    //     {
    //         recordId: "",
    //         relatedObjectApiNameAndRecordTypeId: "[relatedObjectApiName]-[recordTypeId]",
    //         relatedObjectApiName: "",
    //         action: "",
    //         relatedObjectRecordTypeId: "",
    //         relatedObjectRecordTypeName: "",
    //         fieldsToMask:[],
    //         fieldsToEmpty: [],
    //         recordTypeEnabled: true,
    //         recordTypeToggleCellChecked: true,
    //         recordTypeToggleCellDisabled: false,
    //         maskFieldSelectedButtonCellDisabled: false,
    //         emptyFieldSelectedButtonCellDisabled: false,
    //         maskFieldSelectedButtonCellVariant: "brand-outline",
    //         maskFieldSelectedButtonCellIconName: "",
    //         emptyFieldSelectedButtonCellVariant: "brand-outline",
    //         emptyFieldSelectedButtonCellIconName: ""
    //     },
    //     {
    //         recordId: "",
    //         relatedObjectApiNameAndRecordTypeId: "[relatedObjectApiName]-[relatedObjectRecordTypeId]",
    //         relatedObjectApiName: "",
    //         action: "",
    //         relatedObjectRecordTypeId: "",
    //         relatedObjectRecordTypeName: "",
    //         fieldsToMask:[],
    //         fieldsToEmpty: [],
    //         recordTypeEnabled: false,
    //         recordTypeToggleCellChecked: true,
    //         recordTypeToggleCellDisabled: false,
    //         maskFieldSelectedButtonCellDisabled: false,
    //         emptyFieldSelectedButtonCellDisabled: false,
    //         maskFieldSelectedButtonCellVariant: "brand-outline",
    //         maskFieldSelectedButtonCellIconName: "",
    //         emptyFieldSelectedButtonCellVariant: "brand-outline",
    //         emptyFieldSelectedButtonCellIconName: ""
    //     }
    // ]
    @track relatedObjectRecordTypeData;

    // [
    //     {
    //         recordId: "",
    //         relatedObjectApiNameAndRecordTypeId: "[relatedObjectApiName]-[recordTypeId]",
    //         relatedObjectApiName: "",
    //         recordTypeId: "",
    //         fieldsToMask: [],
    //         fieldsToEmpty: [],
    //         recordTypeEnabled: true
    //     },
    //     {
    //         recordId: "",
    //         relatedObjectApiNameAndRecordTypeId: "[relatedObjectApiName]-[recordTypeId]",
    //         relatedObjectApiName: "",
    //         recordTypeId: "",
    //         fieldsToMask: [],
    //         fieldsToEmpty: [],
    //         recordTypeEnabled: false
    //     }
    // ];
    @track relatedObjectRecordTypeSelectedFields = [];

    @track dataConfigUser = {};

    // Properties
    recordId;

    actionValue = "";

    selectedObject = "";

    selectedMatchByField = "";

    configurationNotes = "";

    isConfigurationActive = true;

    receiveEmailNotifications = false;
    emailIdsToNotify = "";

    receiveErrorEmailNotifications = false;
    errorEmailIdsToNotify = "";

    showConfirmButttonPanelOnStep6Example = false;

    _progressIndicatorCurrentStep;

    _maskableAllFieldOptions;

    _emptiableAllFieldOptions;

    //{actionName: '', recordTypeId: '', relatedObjectApiName: '', relatedObjectApiNameAndRecordTypeId: ''}
    currentModalProperty = {};

    addRelatedObjectsFlag = false;

    isSelectedObjectChanged = false;

    isSelectedrelatedObjectMaskingValuesChanged = false;

    isSelectedRelatedObjectDeletionValuesChanged = false;

    processStartAfter = "1";

    processStartUnitValue = "Day(s)";

    processStartTime = "00:00:00.000Z";

    process2StartAfter = "2";

    process2StartUnitValue = "Month(s)";

    process2StartTime = "00:00:00.000Z";

    deleteBackupsAfter = "1";

    deleteBackupsUnitValue = "Month(s)";

    deleteBackupsTime = "00:00:00.000Z";

    retryProcess = false;

    retryProcess2 = false;

    retryProcessAfter = "1";

    retryProcessUnitValue = "Month(s)";

    retryProcess2After = "1";

    retryProcess2UnitValue = "Month(s)";

    __recordTypeAndFieldIdToRelatedObjectId;

    _serverError;

    // Getters & Setters

    get actionOptions() {
        return CONSTANTS.ACTION_OPTIONS;
    }

    get cardHeading() {
        return this.isEditMode
            ? "Edit Data Clean Configuration"
            : "Create Data Clean Configuration";
    }

    get progressIndicatorCurrentStep() {
        this._progressIndicatorCurrentStep = CONSTANTS.FIRST_STEP;
        for (const [key, value] of Object.entries(this.steps)) {
            if (value) {
                this._progressIndicatorCurrentStep = key;
            }
        }
        return this._progressIndicatorCurrentStep;
    }

    set progressIndicatorCurrentStep(progressIndicatorCurrentStepValue) {
        this._progressIndicatorCurrentStep = progressIndicatorCurrentStepValue;
    }

    get isFirstStep() {
        if (this.progressIndicatorCurrentStep === CONSTANTS.FIRST_STEP) {
            return true;
        }
        return false;
    }

    get isFinalStep() {
        if (this.progressIndicatorCurrentStep === CONSTANTS.FINAL_STEP) {
            return true;
        }
        return false;
    }

    get processNameLabel() {
        if (this.actionValue.includes("Masking")) {
            return "Masking";
        } else if (this.actionValue.includes("Deletion")) {
            return "Deletion";
        } else if (this.actionValue.includes("Archive")) {
            return "Archive";
        } else {
            return "Cloning";
        }
    }

    get exampleDataCleanInsertDate() {
        return getDateAsStringFormatted(new Date());
    }

    get exampleProcessStartDate() {
        return getDateAsStringFormatted(
            shiftDate(this.processStartAfter, this.processStartUnitValue)
        );
    }

    get exampleBackupexpieryDate() {
        return getDateAsStringFormatted(
            shiftDate(
                this.deleteBackupsAfter,
                this.deleteBackupsUnitValue,
                shiftDate(this.processStartAfter, this.processStartUnitValue)
            )
        );
    }

    get postMaskingDeletionDate() {
        return getDateAsStringFormatted(
            shiftDate(
                this.process2StartAfter,
                this.process2StartUnitValue,
                shiftDate(this.processStartAfter, this.processStartUnitValue)
            )
        );
    }

    get maskRetryDate() {
        return getDateAsStringFormatted(
            shiftDate(
                this.retryProcessAfter,
                this.retryProcessUnitValue,
                shiftDate(this.processStartAfter, this.processStartUnitValue)
            )
        );
    }

    get deleteRetryDate() {
        return getDateAsStringFormatted(
            shiftDate(
                this.retryProcess2After,
                this.retryProcess2UnitValue,
                shiftDate(this.processStartAfter, this.processStartUnitValue)
            )
        );
    }

    get step4LabelDoYouWantToProcessRelatedObjects() {
        if (this.actionValue.includes("Masking")) {
            return "Do you want to Mask/Delete Related Child Object Records?";
        } else if (this.actionValue.includes("Archive")) {
            return "Do you want to Archive Related Child Object Records?";
        } else if (this.actionValue.includes("Deletion")) {
            return "Do you want to Delete Related Child Object Records?";
        } else {
            return "Do you want to Clone Related Child Object Records?";
        }
    }

    get step6LabelDoYouWantToRepeatProcess() {
        if (this.actionValue.includes("Masking")) {
            return "Do you want to repeat masking of failed and/or new records after masking processing?";
        } else if (this.actionValue.includes("Deletion")) {
            return "Do you want to repeat deletion of failed and/or new records after masking processing?";
        } else if (this.actionValue.includes("Archive")) {
            return "Do you want to repeat archival of failed and/or new records after masking processing?";
        } else {
            return "Do you want to repeat cloning of failed and/or new records after masking processing?";
        }
    }

    get step6LabelRetryProcessEvery() {
        if (this.actionValue.includes("Masking")) {
            return "Retry Masking Every";
        } else if (this.actionValue.includes("Deletion")) {
            return "Retry Deletion Every";
        } else if (this.actionValue.includes("Archive")) {
            return "Retry Archival Every";
        } else {
            return "Retry Cloning Every";
        }
    }

    get step6LabelDoYouWantToRepeatProcess2() {
        if (this.actionValue.endsWith("Deletion")) {
            return "Do you want to repeat deletion of failed and/or new records after masking processing?";
        } else {
            return "";
        }
    }

    get step6LabelRetryProcess2Every() {
        if (this.actionValue.endsWith("Deletion")) {
            return "Retry Deletion Every";
        } else {
            return "";
        }
    }

    get isMaskAction() {
        return this.actionValue.includes("Masking");
    }

    get isPostDeleteAction() {
        return this.actionValue.endsWith("Deletion");
    }

    get isDeleteAction() {
        return this.actionValue.includes("Deletion");
    }

    get isBackupAction() {
        return (
            this.actionValue.includes("Rollback") ||
            this.actionValue.includes("Archive")
        );
    }

    get isArchiveAction() {
        return this.actionValue.includes("Archive");
    }

    get isMaskOrDeleteAction() {
        return (
            this.actionValue.includes("Masking") ||
            this.actionValue.includes("Deletion")
        );
    }

    get isMaskOrArchiveAction() {
        return (
            this.actionValue.includes("Masking") ||
            this.actionValue.includes("Archive")
        );
    }

    get processStartUnitOptions() {
        return CONSTANTS.UNIT_OPTIONS;
    }

    get process2StartUnitOptions() {
        return CONSTANTS.UNIT_OPTIONS;
    }

    get deleteBackupsUnitOptions() {
        return CONSTANTS.UNIT_OPTIONS;
    }

    get retryProcessUnitOptions() {
        let options = [];
        CONSTANTS.UNIT_OPTIONS.forEach((option) => {
            options.push(Object.assign({}, option));
        });
        options.splice(0, 1);
        return options;
    }

    get retryProcess2UnitOptions() {
        let options = [];
        CONSTANTS.UNIT_OPTIONS.forEach((option) => {
            options.push(Object.assign({}, option));
        });
        options.splice(0, 1);
        return options;
    }

    get fieldOptions() {
        if (this.currentModalProperty.actionName === "fieldsToMask") {
            return this.maskableAllFieldOptions;
        } else {
            return this.emptiableAllFieldOptions;
        }
    }

    get maskableAllFieldOptions() {
        if (this.currentModalProperty.relatedObjectApiNameAndRecordTypeId) {
            let filteredRelatedObjectRecordTypeSelectedFields = this.relatedObjectRecordTypeSelectedFields.filter(
                (relatedObjectRecordTypeSelectedField) =>
                    relatedObjectRecordTypeSelectedField.relatedObjectApiNameAndRecordTypeId ===
                    this.currentModalProperty
                        .relatedObjectApiNameAndRecordTypeId
            );
            if (
                filteredRelatedObjectRecordTypeSelectedFields.length > 0 &&
                filteredRelatedObjectRecordTypeSelectedFields[0].fieldsToEmpty
                    .length > 0
            ) {
                if (this.allFieldOptions) {
                    return this.allFieldOptions.filter(
                        (allFieldOption) =>
                            !filteredRelatedObjectRecordTypeSelectedFields[0].fieldsToEmpty.includes(
                                allFieldOption.value
                            )
                    );
                } else {
                    return this.allFieldOptions;
                }
            } else {
                return this.allFieldOptions;
            }
        } else {
            let filteredRecordTypeSelectedFields = this.recordTypeSelectedFields.filter(
                (recordTypeSelectedField) =>
                    recordTypeSelectedField.recordTypeId ===
                    this.currentModalProperty.recordTypeId
            );
            if (
                filteredRecordTypeSelectedFields.length > 0 &&
                filteredRecordTypeSelectedFields[0].fieldsToEmpty.length > 0
            ) {
                if (this.allFieldOptions) {
                    return this.allFieldOptions.filter(
                        (allFieldOption) =>
                            !filteredRecordTypeSelectedFields[0].fieldsToEmpty.includes(
                                allFieldOption.value
                            )
                    );
                } else {
                    return this.allFieldOptions;
                }
            } else {
                return this.allFieldOptions;
            }
        }
    }

    set maskableAllFieldOptions(maskableAllFieldOptionsValue) {
        this._maskableAllFieldOptions = maskableAllFieldOptionsValue;
    }

    get emptiableAllFieldOptions() {
        if (this.currentModalProperty.relatedObjectApiNameAndRecordTypeId) {
            let filteredRelatedObjectRecordTypeSelectedFields = this.relatedObjectRecordTypeSelectedFields.filter(
                (filteredRelatedObjectRecordTypeSelectedField) =>
                    filteredRelatedObjectRecordTypeSelectedField.relatedObjectApiNameAndRecordTypeId ===
                    this.currentModalProperty
                        .relatedObjectApiNameAndRecordTypeId
            );
            if (
                filteredRelatedObjectRecordTypeSelectedFields.length > 0 &&
                filteredRelatedObjectRecordTypeSelectedFields[0].fieldsToMask
                    .length > 0
            ) {
                if (this.allFieldOptions) {
                    return this.allFieldOptions.filter(
                        (allFieldOption) =>
                            !filteredRelatedObjectRecordTypeSelectedFields[0].fieldsToMask.includes(
                                allFieldOption.value
                            )
                    );
                } else {
                    return this.allFieldOptions;
                }
            } else {
                return this.allFieldOptions;
            }
        } else {
            let filteredRecordTypeSelectedFields = this.recordTypeSelectedFields.filter(
                (recordTypeSelectedField) =>
                    recordTypeSelectedField.recordTypeId ===
                    this.currentModalProperty.recordTypeId
            );
            if (
                filteredRecordTypeSelectedFields.length > 0 &&
                filteredRecordTypeSelectedFields[0].fieldsToMask.length > 0
            ) {
                if (this.allFieldOptions) {
                    return this.allFieldOptions.filter(
                        (allFieldOption) =>
                            !filteredRecordTypeSelectedFields[0].fieldsToMask.includes(
                                allFieldOption.value
                            )
                    );
                } else {
                    return this.allFieldOptions;
                }
            } else {
                return this.allFieldOptions;
            }
        }
    }

    set emptiableAllFieldOptions(emptiableAllFieldOptionsValue) {
        this._emptiableAllFieldOptions = emptiableAllFieldOptionsValue;
    }

    get serverError() {
        return this._serverError;
    }

    set serverError(errorValue) {
        this._serverError = errorValue;
        if (this._serverError) {
            if ("body" in this._serverError) {
                output("Server Error", this._serverError.body.message);
                showToast(
                    this._serverError.body.exceptionType,
                    this._serverError.body.message,
                    "error"
                );
            } else {
                output("Local Error", this._serverError.message);
                showToast("Error", this._serverError.message, "error");
            }
        }
    }

    // Lifecycle Hooks

    connectedCallback() {
        if (this.configurationData) {
            this.isEditMode = true;
            this.inititialize();
            try {
                this.initComponentFromConfigurationData();
            } catch (error) {
                this.serverError = error;
            }
        }
    }

    // Wire Adapters
    // using wire service getting current user data
    @wire(getRecord, { recordId: USER_ID, fields: USER_FIELDS })
    userData({ error, data }) {
        if (data) {
            let currentUserData = data.fields;
            this.dataConfigUser = {
                Name: currentUserData.Name.value,
                Id: USER_ID
            };
        } else if (error) {
            window.console.log("error ====> " + JSON.stringify(error));
        }
    }

    // Methods

    inititialize() {
        this.isSelectedObjectChanged = true;
        this.isSelectedrelatedObjectMaskingValuesChanged = true;
        this.isSelectedRelatedObjectDeletionValuesChanged = true;
        this.recordTypeSelectedFields = [];
        this.relatedObjectRecordTypeSelectedFields = [];
        this.selectedRelatedObjectMaskingValues = [];
        this.selectedRelatedObjectDeletionValues = [];
    }

    movePrevious() {
        let stepKeys = Object.keys(this.steps);
        let currentStepFlag = false;
        for (let i = stepKeys.length - 1; i >= 0; i--) {
            const stepKey = stepKeys[i];
            if (currentStepFlag) {
                this.steps[stepKey] = true;
                break;
            }
            if (this.steps[stepKey]) {
                this.steps[stepKey] = false;
                currentStepFlag = true;
            }
        }
    }

    moveNext() {
        let currentStepFlag = false;
        for (const [key, value] of Object.entries(this.steps)) {
            if (currentStepFlag) {
                this.steps[key] = true;
                break;
            }
            if (value) {
                this.steps[key] = false;
                currentStepFlag = true;
            }
        }
    }

    toggleActiveInactive(activeValue, obj) {
        for (const [key, value] of Object.entries(obj)) {
            if (key === activeValue) {
                obj[key] = true;
            } else {
                obj[key] = false;
            }
        }
    }

    addStep3() {
        if ("step3" in this.steps) {
            return;
        }
        let keyValues = Object.entries(this.steps);
        keyValues.splice(2, 0, ["step3", false]);
        this.steps = Object.fromEntries(keyValues);
        this.progressIndiacatorSteps.splice(2, 0, {
            value: "step3",
            label: "Select Record Types & Fields"
        });
    }

    removeStep3() {
        if ("step3" in this.steps) {
            delete this.steps.step3;
            this.progressIndiacatorSteps.splice(2, 1);
        }
    }

    addStep5() {
        if ("step5" in this.steps) {
            return;
        }
        let keyValues = Object.entries(this.steps);
        keyValues.splice(4, 0, ["step5", false]);
        this.steps = Object.fromEntries(keyValues);
        this.progressIndiacatorSteps.splice(4, 0, {
            value: "step5",
            label: "Select Related Objects Record Types & Fields"
        });
    }

    removeStep5() {
        if ("step5" in this.steps) {
            delete this.steps.step5;
            this.progressIndiacatorSteps.splice(4, 1);
        }
    }

    updateRecordTypeSelectedFields() {
        for (let i = 0; i < this.recordTypeSelectedFields.length; i++) {
            if (
                this.recordTypeSelectedFields[i].recordTypeId ===
                this.currentModalProperty.recordTypeId
            ) {
                switch (this.currentModalProperty.actionName) {
                    case "fieldsToMask":
                        this.recordTypeSelectedFields[
                            i
                        ].fieldsToMask = this.selectedFieldValues;
                        break;

                    case "fieldsToEmpty":
                        this.recordTypeSelectedFields[
                            i
                        ].fieldsToEmpty = this.selectedFieldValues;
                        break;
                }
                break;
            }
        }
    }

    updateRelatedObjectRecordTypeSelectedFields() {
        for (
            let i = 0;
            i < this.relatedObjectRecordTypeSelectedFields.length;
            i++
        ) {
            if (
                this.relatedObjectRecordTypeSelectedFields[i]
                    .relatedObjectApiNameAndRecordTypeId ===
                this.currentModalProperty.relatedObjectApiNameAndRecordTypeId
            ) {
                switch (this.currentModalProperty.actionName) {
                    case "fieldsToMask":
                        this.relatedObjectRecordTypeSelectedFields[
                            i
                        ].fieldsToMask = this.selectedFieldValues;
                        break;

                    case "fieldsToEmpty":
                        this.relatedObjectRecordTypeSelectedFields[
                            i
                        ].fieldsToEmpty = this.selectedFieldValues;
                        break;
                }
                break;
            }
        }
    }

    updateRecordTypeColumns(isFieldsSelected) {
        for (let i = 0; i < this.recordTypeData.length; i++) {
            if (
                this.recordTypeData[i].recordTypeId ===
                this.currentModalProperty.recordTypeId
            ) {
                switch (this.currentModalProperty.actionName) {
                    case "fieldsToMask":
                        this.recordTypeData[
                            i
                        ].maskFieldSelectedButtonCellVariant = isFieldsSelected
                            ? "brand"
                            : "brand-outline";
                        this.recordTypeData[
                            i
                        ].maskFieldSelectedButtonCellIconName = isFieldsSelected
                            ? "action:approval"
                            : "";
                        break;
                    case "fieldsToEmpty":
                        this.recordTypeData[
                            i
                        ].emptyFieldSelectedButtonCellVariant = isFieldsSelected
                            ? "brand"
                            : "brand-outline";
                        this.recordTypeData[
                            i
                        ].emptyFieldSelectedButtonCellIconName = isFieldsSelected
                            ? "action:approval"
                            : "";
                        break;
                }
                break;
            }
        }
        this.recordTypeData = [...this.recordTypeData];
    }

    updateRelatedObjectRecordTypeColumns(isFieldsSelected) {
        for (let i = 0; i < this.relatedObjectRecordTypeData.length; i++) {
            if (
                this.relatedObjectRecordTypeData[i]
                    .relatedObjectApiNameAndRecordTypeId ===
                this.currentModalProperty.relatedObjectApiNameAndRecordTypeId
            ) {
                switch (this.currentModalProperty.actionName) {
                    case "fieldsToMask":
                        this.relatedObjectRecordTypeData[
                            i
                        ].maskFieldSelectedButtonCellVariant = isFieldsSelected
                            ? "brand"
                            : "brand-outline";
                        this.relatedObjectRecordTypeData[
                            i
                        ].maskFieldSelectedButtonCellIconName = isFieldsSelected
                            ? "action:approval"
                            : "";
                        break;
                    case "fieldsToEmpty":
                        this.relatedObjectRecordTypeData[
                            i
                        ].emptyFieldSelectedButtonCellVariant = isFieldsSelected
                            ? "brand"
                            : "brand-outline";
                        this.relatedObjectRecordTypeData[
                            i
                        ].emptyFieldSelectedButtonCellIconName = isFieldsSelected
                            ? "action:approval"
                            : "";
                        break;
                }
                break;
            }
        }
        this.relatedObjectRecordTypeData = [
            ...this.relatedObjectRecordTypeData
        ];
    }

    clearCurrentModalProperties() {
        this.currentModalProperty = {};
    }

    saveSelectedRelatedObjectMaskingValues() {
        let selectedRelatedObjectMaskingValues = this.template
            .querySelector(
                'c-data-clean-searchable-lightning-dual-listbox[data-id="relatedObjectMaskingOptions"]'
            )
            .getSelectedValues();
        if (
            this.selectedRelatedObjectMaskingValues
                .slice()
                .sort()
                .toString() !==
            selectedRelatedObjectMaskingValues.slice().sort().toString()
        ) {
            this.isSelectedrelatedObjectMaskingValuesChanged = true;
            this.relatedObjectRecordTypeSelectedFields = [];
        }
        this.selectedRelatedObjectMaskingValues = selectedRelatedObjectMaskingValues;
    }

    saveSelectedRelatedObjectDeletionValues() {
        let selectedRelatedObjectDeletionValues = this.template
            .querySelector(
                'c-data-clean-searchable-lightning-dual-listbox[data-id="relatedObjectDeletionOptions"]'
            )
            .getSelectedValues();
        if (
            this.selectedRelatedObjectDeletionValues
                .slice()
                .sort()
                .toString() !==
            selectedRelatedObjectDeletionValues.slice().sort().toString()
        ) {
            this.isSelectedRelatedObjectDeletionValuesChanged = true;
            this.relatedObjectRecordTypeSelectedFields = [];
        }
        this.selectedRelatedObjectDeletionValues = selectedRelatedObjectDeletionValues;
    }

    openFieldsSelectorModal(
        recordTypeId,
        actionName,
        relatedObjectApiName,
        relatedObjectApiNameAndRecordTypeId
    ) {
        this.initCurrentModalProperties(
            recordTypeId,
            actionName,
            relatedObjectApiName,
            relatedObjectApiNameAndRecordTypeId
        );
        if (relatedObjectApiNameAndRecordTypeId) {
            this.initSelectedFieldValuesForRelatedObjectRecordTypeAndFields(
                relatedObjectApiNameAndRecordTypeId,
                actionName
            );
        } else {
            this.initSelectedFieldValues(recordTypeId, actionName);
        }
        this.modals.fieldSelectorModal = true;
        this.alerts.topOfFieldSelectorModal = true;
        let objectApiName;
        if (relatedObjectApiName) {
            objectApiName = relatedObjectApiName;
        } else {
            objectApiName = this.selectedObject;
        }
        setTimeout(() => {
            try {
                this.showFieldSelectorModal();
                switch (actionName) {
                    case "fieldsToMask":
                        this.initMaskablefieldOptions(
                            objectApiName,
                            this.showFieldSelectorModal
                        );
                        break;
                    case "fieldsToEmpty":
                        this.initEmptiablefieldOptions(
                            objectApiName,
                            this.showFieldSelectorModal
                        );
                        break;
                }
            } catch (error) {
                this.serverError = error;
            }
        }, 1);
    }

    showFieldSelectorModal() {
        this.template.querySelector("c-data-clean-modal").show();
    }

    hideFieldSelectorModal() {
        this.template.querySelector("c-data-clean-modal").hide();
    }

    initAllObjectOptions() {
        this.spinners.full = true;
        getObjectOptions({ actionName: this.actionValue })
            .then((result) => {
                this.allObjectOptions = result;
                sortOptionsByLabel(this.allObjectOptions);
                this.spinners.full = false;
            })
            .catch((error) => {
                this.serverError = error;
                this.spinners.full = false;
            });
    }

    initMaskablefieldOptions(objectApiName) {
        this.spinners.isFieldSelectorDualListBoxLoading = true;
        getMaskableFieldOptions({ objectApiName })
            .then((result) => {
                this.allFieldOptions = result.filter(
                    (allFieldOption) =>
                        allFieldOption.value !== this.selectedMatchByField
                );
                sortOptionsByLabel(this.allFieldOptions);
                this.spinners.isFieldSelectorDualListBoxLoading = false;
            })
            .catch((error) => {
                this.serverError = error;
                this.spinners.isFieldSelectorDualListBoxLoading = false;
            });
    }

    initEmptiablefieldOptions(objectApiName) {
        this.spinners.isFieldSelectorDualListBoxLoading = true;
        getNillableFieldOptions({ objectApiName })
            .then((result) => {
                this.allFieldOptions = result.filter(
                    (allFieldOption) =>
                        allFieldOption.value !== this.selectedMatchByField
                );
                sortOptionsByLabel(this.allFieldOptions);
                this.spinners.isFieldSelectorDualListBoxLoading = false;
            })
            .catch((error) => {
                this.serverError = error;
                this.spinners.isFieldSelectorDualListBoxLoading = false;
            });
    }

    initPotentialExternalIdFieldsOptions() {
        this.spinners.full = true;
        getPotentialExternalIdFieldOptions({
            objectApiName: this.selectedObject
        })
            .then((result) => {
                this.potentialExternalIdFieldsOptions = result;
                sortOptionsByLabel(this.potentialExternalIdFieldsOptions);
                this.spinners.full = false;
            })
            .catch((error) => {
                this.serverError = error;
                this.spinners.full = false;
            });
    }

    initRecordTypesAndFields() {
        this.spinners.full = true;
        getRecordTypeOptions({
            objectApiName: this.selectedObject
        })
            .then((result) => {
                if (this.isSelectedObjectChanged) {
                    this.isSelectedObjectChanged = false;
                    this.recordTypeData = [];
                    result.forEach((recordTypeOption) => {
                        let rtDataRow = {};
                        if (!this.isEditMode) {
                            rtDataRow.recordId = null;
                            rtDataRow.recordTypeId = recordTypeOption.value;
                            rtDataRow.recordTypeName = recordTypeOption.label;
                            rtDataRow.recordTypeToggleCellChecked = true;
                            rtDataRow.recordTypeToggleCellDisabled = false;
                            rtDataRow.maskFieldSelectedButtonCellDisabled = false;
                            rtDataRow.emptyFieldSelectedButtonCellDisabled = false;
                            rtDataRow.maskFieldSelectedButtonCellIconName = "";
                            rtDataRow.emptyFieldSelectedButtonCellIconName = "";
                            rtDataRow.maskFieldSelectedButtonCellVariant =
                                "brand-outline";
                            rtDataRow.emptyFieldSelectedButtonCellVariant =
                                "brand-outline";
                        } else {
                            let selectedRTAndFld = this.recordTypeSelectedFields.find(
                                (selectedRTAndFld) => {
                                    return (
                                        selectedRTAndFld.recordTypeId ===
                                        recordTypeOption.value
                                    );
                                }
                            );
                            if (!selectedRTAndFld) {
                                rtDataRow.recordId = null;
                                rtDataRow.recordTypeId = recordTypeOption.value;
                                rtDataRow.recordTypeName =
                                    recordTypeOption.label;
                                rtDataRow.recordTypeToggleCellChecked = true;
                                rtDataRow.recordTypeToggleCellDisabled = false;
                                rtDataRow.maskFieldSelectedButtonCellDisabled = false;
                                rtDataRow.emptyFieldSelectedButtonCellDisabled = false;
                                rtDataRow.maskFieldSelectedButtonCellIconName =
                                    "";
                                rtDataRow.emptyFieldSelectedButtonCellIconName =
                                    "";
                                rtDataRow.maskFieldSelectedButtonCellVariant =
                                    "brand-outline";
                                rtDataRow.emptyFieldSelectedButtonCellVariant =
                                    "brand-outline";
                            } else {
                                rtDataRow.recordId = selectedRTAndFld.recordId;
                                rtDataRow.recordTypeId =
                                    selectedRTAndFld.recordTypeId;
                                rtDataRow.recordTypeName =
                                    recordTypeOption.label;
                                rtDataRow.recordTypeToggleCellChecked =
                                    selectedRTAndFld.recordTypeEnabled;
                                rtDataRow.recordTypeToggleCellDisabled = false;
                                rtDataRow.maskFieldSelectedButtonCellDisabled = !selectedRTAndFld.recordTypeEnabled;
                                rtDataRow.emptyFieldSelectedButtonCellDisabled = !selectedRTAndFld.recordTypeEnabled;
                                let isMaskFieldsSelected =
                                    selectedRTAndFld.fieldsToMask.length > 0;
                                let isEmptyFieldsSelected =
                                    selectedRTAndFld.fieldsToEmpty.length > 0;
                                rtDataRow.maskFieldSelectedButtonCellIconName = isMaskFieldsSelected
                                    ? "action:approval"
                                    : "";
                                rtDataRow.emptyFieldSelectedButtonCellIconName = isEmptyFieldsSelected
                                    ? "action:approval"
                                    : "";
                                rtDataRow.maskFieldSelectedButtonCellVariant = isMaskFieldsSelected
                                    ? "brand"
                                    : "brand-outline";
                                rtDataRow.emptyFieldSelectedButtonCellVariant = isEmptyFieldsSelected
                                    ? "brand"
                                    : "brand-outline";
                            }
                        }
                        this.recordTypeData.push(rtDataRow);
                        if (!this.isEditMode) {
                            this.initRecordTypeSelectedFields(
                                recordTypeOption.value,
                                recordTypeOption.label
                            );
                        }
                    });
                }
                this.spinners.full = false;
            })
            .catch((error) => {
                this.serverError = error;
                this.spinners.full = false;
            });
    }

    initRecordTypeSelectedFields(
        recordTypeId,
        recordTypeName,
        recordTypeEnabled = true
    ) {
        let recordTypeSelectedField = {};
        recordTypeSelectedField.recordId = null;
        recordTypeSelectedField.recordTypeId = recordTypeId;
        recordTypeSelectedField.recordTypeName = recordTypeName;
        recordTypeSelectedField.recordTypeEnabled = recordTypeEnabled;
        recordTypeSelectedField.fieldsToMask = [];
        recordTypeSelectedField.fieldsToEmpty = [];
        this.recordTypeSelectedFields.push(recordTypeSelectedField);
    }

    initRelatedObjectRecordTypeSelectedFields(
        relatedObjectApiName,
        recordTypeId,
        recordTypeName,
        relatedObjectApiNameAndRecordTypeId,
        recordTypeEnabled = true
    ) {
        let relatedObjectRecordTypeSelectedField = {};
        relatedObjectRecordTypeSelectedField.recordId = null;
        relatedObjectRecordTypeSelectedField.relatedObjectApiNameAndRecordTypeId = relatedObjectApiNameAndRecordTypeId;
        relatedObjectRecordTypeSelectedField.relatedObjectApiName = relatedObjectApiName;
        relatedObjectRecordTypeSelectedField.recordTypeId = recordTypeId;
        relatedObjectRecordTypeSelectedField.recordTypeName = recordTypeName;
        relatedObjectRecordTypeSelectedField.recordTypeEnabled = recordTypeEnabled;
        relatedObjectRecordTypeSelectedField.fieldsToMask = [];
        relatedObjectRecordTypeSelectedField.fieldsToEmpty = [];
        this.relatedObjectRecordTypeSelectedFields.push(
            relatedObjectRecordTypeSelectedField
        );
    }

    initSelectedFieldValues(recordTypeId, actionName) {
        let selectedFieldValuesFoundFlag = false;
        for (let i = 0; i < this.recordTypeSelectedFields.length; i++) {
            const recordTypeSelectedField = this.recordTypeSelectedFields[i];
            if (recordTypeSelectedField.recordTypeId === recordTypeId) {
                this.selectedFieldValues = recordTypeSelectedField[actionName];
                selectedFieldValuesFoundFlag = true;
                break;
            }
        }
        if (!selectedFieldValuesFoundFlag) {
            this.selectedFieldValues = [];
        }
    }

    initSelectedFieldValuesForRelatedObjectRecordTypeAndFields(
        relatedObjectApiNameAndRecordTypeId,
        actionName
    ) {
        let selectedFieldValuesFoundFlag = false;
        for (
            let i = 0;
            i < this.relatedObjectRecordTypeSelectedFields.length;
            i++
        ) {
            const relatedObjectRecordTypeSelectedField = this
                .relatedObjectRecordTypeSelectedFields[i];
            if (
                relatedObjectRecordTypeSelectedField.relatedObjectApiNameAndRecordTypeId ===
                relatedObjectApiNameAndRecordTypeId
            ) {
                this.selectedFieldValues =
                    relatedObjectRecordTypeSelectedField[actionName];
                selectedFieldValuesFoundFlag = true;
                break;
            }
        }
        if (!selectedFieldValuesFoundFlag) {
            this.selectedFieldValues = [];
        }
    }

    initCurrentModalProperties(
        recordTypeId,
        actionName,
        relatedObjectApiName,
        relatedObjectApiNameAndRecordTypeId
    ) {
        this.currentModalProperty.recordTypeId = recordTypeId;
        this.currentModalProperty.actionName = actionName;
        this.currentModalProperty.relatedObjectApiName = relatedObjectApiName;
        this.currentModalProperty.relatedObjectApiNameAndRecordTypeId = relatedObjectApiNameAndRecordTypeId;
    }

    initRelatedObjectMaskingOptions() {
        this.spinners.isRelatedObjectMaskingSelectorDualListBoxLoading = true;
        getRelatedObjectOptions({
            objectApiName: this.selectedObject,
            checkRecordTypeSize: true
        })
            .then((result) => {
                this.relatedObjectMaskingOptions = result;
                sortOptionsByLabel(this.relatedObjectMaskingOptions);
                this.spinners.isRelatedObjectMaskingSelectorDualListBoxLoading = false;
            })
            .catch((error) => {
                this.serverError = error;
                this.spinners.isRelatedObjectMaskingSelectorDualListBoxLoading = false;
            });
    }

    initRelatedObjectDeletionOptions() {
        this.spinners.isRelatedObjectDeletionSelectorDualListBoxLoading = true;
        getRelatedObjectOptions({
            objectApiName: this.selectedObject,
            checkRecordTypeSize: false
        })
            .then((result) => {
                this.relatedObjectDeletionOptions = result;
                sortOptionsByLabel(this.relatedObjectDeletionOptions);
                this.spinners.isRelatedObjectDeletionSelectorDualListBoxLoading = false;
            })
            .catch((error) => {
                this.serverError = error;
                this.spinners.isRelatedObjectDeletionSelectorDualListBoxLoading = false;
            });
    }

    initRelatedObjectRecordTypesandFields() {
        this.spinners.full = true;
        getRelatedObjectRecordTypeOptions({
            relatedObjectApiNames: this.selectedRelatedObjectMaskingValues
        })
            .then((result) => {
                if (
                    this.isSelectedrelatedObjectMaskingValuesChanged ||
                    this.isSelectedRelatedObjectDeletionValuesChanged
                ) {
                    this.isSelectedrelatedObjectMaskingValuesChanged = false;
                    this.isSelectedRelatedObjectDeletionValuesChanged = false;
                    this.relatedObjectRecordTypeData = [];
                    result.forEach((res) => {
                        let relatedObjectRTDataRow = {};
                        if (!this.isEditMode) {
                            relatedObjectRTDataRow.recordId = null;
                            relatedObjectRTDataRow.relatedObjectApiName =
                                res.relatedObjectApiName;
                            relatedObjectRTDataRow.action = this.isArchiveAction
                                ? "Archive"
                                : "Mask";
                            relatedObjectRTDataRow.relatedObjectRecordTypeId =
                                res.relatedObjectRecordTypeId;
                            relatedObjectRTDataRow.relatedObjectRecordTypeName =
                                res.relatedObjectRecordTypeName;
                            relatedObjectRTDataRow.relatedObjectApiNameAndRecordTypeId =
                                res.relatedObjectApiName +
                                "-" +
                                res.relatedObjectRecordTypeId;
                            relatedObjectRTDataRow.recordTypeToggleCellChecked = true;
                            relatedObjectRTDataRow.recordTypeToggleCellDisabled = false;
                            relatedObjectRTDataRow.maskFieldSelectedButtonCellDisabled = false;
                            relatedObjectRTDataRow.emptyFieldSelectedButtonCellDisabled = false;
                            relatedObjectRTDataRow.maskFieldSelectedButtonCellIconName =
                                "";
                            relatedObjectRTDataRow.emptyFieldSelectedButtonCellIconName =
                                "";
                            relatedObjectRTDataRow.maskFieldSelectedButtonCellVariant =
                                "brand-outline";
                            relatedObjectRTDataRow.emptyFieldSelectedButtonCellVariant =
                                "brand-outline";
                        } else {
                            let relObjRTData = this.relatedObjectRecordTypeSelectedFields.find(
                                (relObjRTData) => {
                                    if (relObjRTData.recordTypeId) {
                                        return (
                                            relObjRTData.relatedObjectApiNameAndRecordTypeId ===
                                            res.relatedObjectApiName +
                                                "-" +
                                                res.relatedObjectRecordTypeId
                                        );
                                    } else {
                                        return false;
                                    }
                                }
                            );
                            if (!relObjRTData) {
                                relatedObjectRTDataRow.recordId = null;
                                relatedObjectRTDataRow.relatedObjectApiName =
                                    res.relatedObjectApiName;
                                relatedObjectRTDataRow.action = this
                                    .isArchiveAction
                                    ? "Archive"
                                    : "Mask";
                                relatedObjectRTDataRow.relatedObjectRecordTypeId =
                                    res.relatedObjectRecordTypeId;
                                relatedObjectRTDataRow.relatedObjectRecordTypeName =
                                    res.relatedObjectRecordTypeName;
                                relatedObjectRTDataRow.relatedObjectApiNameAndRecordTypeId =
                                    res.relatedObjectApiName +
                                    "-" +
                                    res.relatedObjectRecordTypeId;
                                relatedObjectRTDataRow.recordTypeToggleCellChecked = true;
                                relatedObjectRTDataRow.recordTypeToggleCellDisabled = false;
                                relatedObjectRTDataRow.maskFieldSelectedButtonCellDisabled = false;
                                relatedObjectRTDataRow.emptyFieldSelectedButtonCellDisabled = false;
                                relatedObjectRTDataRow.maskFieldSelectedButtonCellIconName =
                                    "";
                                relatedObjectRTDataRow.emptyFieldSelectedButtonCellIconName =
                                    "";
                                relatedObjectRTDataRow.maskFieldSelectedButtonCellVariant =
                                    "brand-outline";
                                relatedObjectRTDataRow.emptyFieldSelectedButtonCellVariant =
                                    "brand-outline";
                            } else {
                                relatedObjectRTDataRow.recordId =
                                    relObjRTData.recordId;
                                relatedObjectRTDataRow.relatedObjectApiName =
                                    relObjRTData.relatedObjectApiName;
                                relatedObjectRTDataRow.action = this
                                    .isArchiveAction
                                    ? "Archive"
                                    : "Mask";
                                relatedObjectRTDataRow.relatedObjectRecordTypeId =
                                    relObjRTData.recordTypeId;
                                relatedObjectRTDataRow.recordTypeName =
                                    relObjRTData.recordTypeName;
                                relatedObjectRTDataRow.relatedObjectApiNameAndRecordTypeId =
                                    relObjRTData.relatedObjectApiNameAndRecordTypeId;
                                relatedObjectRTDataRow.recordTypeToggleCellChecked =
                                    relObjRTData.recordTypeEnabled;
                                relatedObjectRTDataRow.recordTypeToggleCellDisabled = false;
                                relatedObjectRTDataRow.maskFieldSelectedButtonCellDisabled = !relObjRTData.recordTypeEnabled;
                                relatedObjectRTDataRow.emptyFieldSelectedButtonCellDisabled = !relObjRTData.recordTypeEnabled;
                                let isMaskFieldsSelected =
                                    relObjRTData.fieldsToMask.length > 0;
                                let isEmptyFieldsSelected =
                                    relObjRTData.fieldsToEmpty.length > 0;
                                relatedObjectRTDataRow.maskFieldSelectedButtonCellIconName = isMaskFieldsSelected
                                    ? "action:approval"
                                    : "";
                                relatedObjectRTDataRow.emptyFieldSelectedButtonCellIconName = isEmptyFieldsSelected
                                    ? "action:approval"
                                    : "";
                                relatedObjectRTDataRow.maskFieldSelectedButtonCellVariant = isMaskFieldsSelected
                                    ? "brand"
                                    : "brand-outline";
                                relatedObjectRTDataRow.emptyFieldSelectedButtonCellVariant = isEmptyFieldsSelected
                                    ? "brand"
                                    : "brand-outline";
                            }
                        }
                        this.relatedObjectRecordTypeData.push(
                            relatedObjectRTDataRow
                        );
                        if (!this.isEditMode) {
                            this.initRelatedObjectRecordTypeSelectedFields(
                                res.relatedObjectApiName,
                                res.relatedObjectRecordTypeId,
                                res.relatedObjectRecordTypeName,
                                res.relatedObjectApiName +
                                    "-" +
                                    res.relatedObjectRecordTypeId
                            );
                        }
                    });
                    this.selectedRelatedObjectDeletionValues.forEach(
                        (relObjApiNameForDeletion) => {
                            let relatedObjectRTDataRow = {};
                            if (!this.isEditMode) {
                                relatedObjectRTDataRow.relatedObjectApiName = relObjApiNameForDeletion;
                                relatedObjectRTDataRow.action = "Delete";
                                relatedObjectRTDataRow.relatedObjectRecordTypeId =
                                    "";
                                relatedObjectRTDataRow.relatedObjectRecordTypeName =
                                    "";
                                relatedObjectRTDataRow.relatedObjectApiNameAndRecordTypeId =
                                    relObjApiNameForDeletion +
                                    "-" +
                                    "undefined";
                                relatedObjectRTDataRow.recordTypeActionCellClass =
                                    "slds-text-color_destructive";
                                relatedObjectRTDataRow.recordTypeToggleCellChecked = true;
                                relatedObjectRTDataRow.recordTypeToggleCellDisabled = false;
                                relatedObjectRTDataRow.recordTypeToggleCellColor =
                                    "red";
                                relatedObjectRTDataRow.maskFieldSelectedButtonCellDisabled = true;
                                relatedObjectRTDataRow.emptyFieldSelectedButtonCellDisabled = true;
                                relatedObjectRTDataRow.maskFieldSelectedButtonCellIconName =
                                    "";
                                relatedObjectRTDataRow.emptyFieldSelectedButtonCellIconName =
                                    "";
                                relatedObjectRTDataRow.maskFieldSelectedButtonCellVariant =
                                    "brand-outline";
                                relatedObjectRTDataRow.emptyFieldSelectedButtonCellVariant =
                                    "brand-outline";
                            } else {
                                let relObjRTData = this.relatedObjectRecordTypeSelectedFields.find(
                                    (relObjRTData) => {
                                        if (!relObjRTData.recordTypeId) {
                                            return (
                                                relObjRTData.relatedObjectApiNameAndRecordTypeId ===
                                                relObjApiNameForDeletion +
                                                    "-" +
                                                    "undefined"
                                            );
                                        } else {
                                            return false;
                                        }
                                    }
                                );
                                if (!relObjRTData) {
                                    relatedObjectRTDataRow.relatedObjectApiName = relObjApiNameForDeletion;
                                    relatedObjectRTDataRow.action = "Delete";
                                    relatedObjectRTDataRow.relatedObjectRecordTypeId =
                                        "";
                                    relatedObjectRTDataRow.relatedObjectRecordTypeName =
                                        "";
                                    relatedObjectRTDataRow.relatedObjectApiNameAndRecordTypeId =
                                        relObjApiNameForDeletion +
                                        "-" +
                                        "undefined";
                                    relatedObjectRTDataRow.recordTypeActionCellClass =
                                        "slds-text-color_destructive";
                                    relatedObjectRTDataRow.recordTypeToggleCellChecked = true;
                                    relatedObjectRTDataRow.recordTypeToggleCellDisabled = false;
                                    relatedObjectRTDataRow.recordTypeToggleCellColor =
                                        "red";
                                    relatedObjectRTDataRow.maskFieldSelectedButtonCellDisabled = true;
                                    relatedObjectRTDataRow.emptyFieldSelectedButtonCellDisabled = true;
                                    relatedObjectRTDataRow.maskFieldSelectedButtonCellIconName =
                                        "";
                                    relatedObjectRTDataRow.emptyFieldSelectedButtonCellIconName =
                                        "";
                                    relatedObjectRTDataRow.maskFieldSelectedButtonCellVariant =
                                        "brand-outline";
                                    relatedObjectRTDataRow.emptyFieldSelectedButtonCellVariant =
                                        "brand-outline";
                                } else {
                                    relatedObjectRTDataRow.relatedObjectApiName = relObjApiNameForDeletion;
                                    relatedObjectRTDataRow.action = "Delete";
                                    relatedObjectRTDataRow.relatedObjectRecordTypeId =
                                        "";
                                    relatedObjectRTDataRow.relatedObjectRecordTypeName =
                                        "";
                                    relatedObjectRTDataRow.relatedObjectApiNameAndRecordTypeId =
                                        relObjApiNameForDeletion +
                                        "-" +
                                        "undefined";
                                    relatedObjectRTDataRow.recordTypeActionCellClass =
                                        "slds-text-color_destructive";
                                    relatedObjectRTDataRow.recordTypeToggleCellChecked =
                                        relObjRTData.recordTypeEnabled;
                                    relatedObjectRTDataRow.recordTypeToggleCellDisabled = false;
                                    relatedObjectRTDataRow.recordTypeToggleCellColor =
                                        "red";
                                    relatedObjectRTDataRow.maskFieldSelectedButtonCellDisabled = true;
                                    relatedObjectRTDataRow.emptyFieldSelectedButtonCellDisabled = true;
                                    relatedObjectRTDataRow.maskFieldSelectedButtonCellIconName =
                                        "";
                                    relatedObjectRTDataRow.emptyFieldSelectedButtonCellIconName =
                                        "";
                                    relatedObjectRTDataRow.maskFieldSelectedButtonCellVariant =
                                        "brand-outline";
                                    relatedObjectRTDataRow.emptyFieldSelectedButtonCellVariant =
                                        "brand-outline";
                                }
                            }
                            this.relatedObjectRecordTypeData.push(
                                relatedObjectRTDataRow
                            );
                            if (!this.isEditMode) {
                                this.initRelatedObjectRecordTypeSelectedFields(
                                    relObjApiNameForDeletion,
                                    "",
                                    "",
                                    relObjApiNameForDeletion + "-" + "undefined"
                                );
                            }
                        }
                    );
                }
                this.spinners.full = false;
            })
            .catch((error) => {
                this.serverError = error;
                this.spinners.full = false;
            });
    }

    initPreviewData() {
        this.previewData = {};
        this.previewData.dcConfigInfos = [];
        let index = 1;

        let label = () => {
            return `label${index % 2 === 0 ? "2" : "1"}`;
        };

        let value = () => {
            return `value${index % 2 === 0 ? "2" : "1"}`;
        };

        let dcConfigInfo = {};

        let pushDcConfigInfo = () => {
            if (index % 2 !== 0) {
                this.previewData.dcConfigInfos.push(dcConfigInfo);
                dcConfigInfo = {};
            }
        };

        dcConfigInfo[label()] = "Master Object Name";
        dcConfigInfo[value()] = this.selectedObject;
        dcConfigInfo.index = index++;
        pushDcConfigInfo();

        dcConfigInfo[label()] = "Configuration Created By";
        dcConfigInfo[value()] = this.dataConfigUser.Name;
        dcConfigInfo.userId = this.dataConfigUser.Id;
        dcConfigInfo.index = index++;
        pushDcConfigInfo();

        dcConfigInfo[label()] = "Action Name";
        dcConfigInfo[value()] = this.actionValue;
        dcConfigInfo.index = index++;
        pushDcConfigInfo();

        dcConfigInfo[label()] = "Master Object Match By Field Name";
        dcConfigInfo[value()] = this.selectedMatchByField;
        dcConfigInfo.index = index++;
        pushDcConfigInfo();

        dcConfigInfo[label()] = "Receive Email Notifications?";
        dcConfigInfo[value()] = this.receiveEmailNotifications ? "Yes" : "No";
        dcConfigInfo.index = index++;
        pushDcConfigInfo();

        if (this.receiveEmailNotifications) {
            dcConfigInfo[label()] = "Email Ids To Notify (Success and Errors)";
            dcConfigInfo[value()] = this.emailIdsToNotify;
            dcConfigInfo.index = index++;
            pushDcConfigInfo();
        }

        dcConfigInfo[label()] = "Receive Error Email Notifications?";
        dcConfigInfo[value()] = this.receiveErrorEmailNotifications
            ? "Yes"
            : "No";
        dcConfigInfo.index = index++;
        pushDcConfigInfo();

        if (this.receiveEmailNotifications) {
            dcConfigInfo[label()] = "Email Ids To Notify (Errors Only)";
            dcConfigInfo[value()] = this.errorEmailIdsToNotify;
            dcConfigInfo.index = index++;
            pushDcConfigInfo();
        }

        dcConfigInfo[label()] = `${this.processNameLabel} Start Date`;
        dcConfigInfo[value()] = `After ${this.processStartAfter} ${
            this.processStartUnitValue
        } (at ${this.processStartTime.substring(
            0,
            this.processStartTime.lastIndexOf(":")
        )}) of Data Clean records insertion`;
        dcConfigInfo.index = index++;
        pushDcConfigInfo();

        if (this.isBackupAction) {
            dcConfigInfo[label()] = "Auto-Delete Backups After";
            dcConfigInfo[value()] = `After ${this.deleteBackupsAfter} ${
                this.deleteBackupsUnitValue
            } (at ${this.deleteBackupsTime.substring(
                0,
                this.deleteBackupsTime.lastIndexOf(":")
            )}) of ${this.processNameLabel} completion`;
            dcConfigInfo.index = index++;
            pushDcConfigInfo();
        }

        if (this.isPostDeleteAction) {
            dcConfigInfo[label()] = "Delete Start After";
            dcConfigInfo[value()] = `After ${this.process2StartAfter} ${
                this.process2StartUnitValue
            } (at ${this.process2StartTime.substring(
                0,
                this.process2StartTime.lastIndexOf(":")
            )}) of ${this.processNameLabel} completion`;
            dcConfigInfo.index = index++;
            pushDcConfigInfo();
        }

        if (this.retryProcess) {
            dcConfigInfo[label()] = "Retry Masking?";
            dcConfigInfo[value()] = this.retryProcess ? "Yes" : "No";
            dcConfigInfo.index = index++;
            pushDcConfigInfo();

            dcConfigInfo[label()] = "Retry Masking Frequency";
            dcConfigInfo[
                value()
            ] = `Every ${this.retryProcessAfter} ${this.retryProcessUnitValue}`;
            dcConfigInfo.index = index++;
            pushDcConfigInfo();
        }

        if (this.retryProcess2) {
            dcConfigInfo[label()] = "Retry Deletion?";
            dcConfigInfo[value()] = this.retryProcess2 ? "Yes" : "No";
            dcConfigInfo.index = index++;
            pushDcConfigInfo();

            dcConfigInfo[label()] = "Retry Deletion Frequency";
            dcConfigInfo[
                value()
            ] = `Every ${this.retryProcess2After} ${this.retryProcess2UnitValue}`;
            dcConfigInfo.index = index++;
            pushDcConfigInfo();
        }

        dcConfigInfo[label()] = "Is Configuration Active";
        dcConfigInfo[value()] = this.isConfigurationActive ? "Yes" : "No";
        dcConfigInfo.index = index++;
        pushDcConfigInfo();

        if (index % 2 === 0) {
            this.previewData.dcConfigInfos.push(dcConfigInfo);
        }

        this.previewData.configurationNotesLabel = "Configuration Notes";
        this.previewData.configurationNotesValue = this.configurationNotes;

        this.previewData.recordTypeData = [];

        this.recordTypeSelectedFields.forEach((recordTypeSelectedField) => {
            let dcRecordTypeAndField = {};
            dcRecordTypeAndField.recordTypeEnabled = recordTypeSelectedField.recordTypeEnabled
                ? "Yes"
                : "No";
            dcRecordTypeAndField.recordTypeId =
                recordTypeSelectedField.recordTypeId;
            dcRecordTypeAndField.recordTypeName = this.recordTypeData.find(
                (rtData) =>
                    rtData.recordTypeId === recordTypeSelectedField.recordTypeId
            ).recordTypeName;
            dcRecordTypeAndField.fieldsToMask = recordTypeSelectedField.fieldsToMask.join(
                ", "
            );
            dcRecordTypeAndField.fieldsToEmpty = recordTypeSelectedField.fieldsToEmpty.join(
                ", "
            );
            this.previewData.recordTypeData.push(dcRecordTypeAndField);
        });

        let columns = [];
        for (let i = 0; i < this.recordTypeColumns.length; i++) {
            const { type, typeAttributes, ...column } = this.recordTypeColumns[
                i
            ];
            columns.push(column);
        }
        this.previewData.recordTypeColumns = columns;

        this.previewData.relatedObjectRecordTypeData = [];

        this.relatedObjectRecordTypeSelectedFields.forEach(
            (relatedObjectRecordTypeSelectedField) => {
                let dcRelatedObjectRecordType = {};
                dcRelatedObjectRecordType.relatedObjectApiName =
                    relatedObjectRecordTypeSelectedField.relatedObjectApiName;
                dcRelatedObjectRecordType.relatedObjectRecordTypeId =
                    relatedObjectRecordTypeSelectedField.recordTypeId;
                dcRelatedObjectRecordType.recordTypeEnabled = relatedObjectRecordTypeSelectedField.recordTypeEnabled
                    ? "Yes"
                    : "No";
                dcRelatedObjectRecordType.fieldsToMask = relatedObjectRecordTypeSelectedField.fieldsToMask.join(
                    ", "
                );
                dcRelatedObjectRecordType.fieldsToEmpty = relatedObjectRecordTypeSelectedField.fieldsToEmpty.join(
                    ", "
                );
                let relObjRtFld = this.relatedObjectRecordTypeData.find(
                    (relObjRtFld) => {
                        return (
                            relObjRtFld.relatedObjectApiNameAndRecordTypeId ===
                            relatedObjectRecordTypeSelectedField.relatedObjectApiNameAndRecordTypeId
                        );
                    }
                );
                dcRelatedObjectRecordType.action = relObjRtFld.action;
                dcRelatedObjectRecordType.relatedObjectRecordTypeName =
                    relObjRtFld.relatedObjectRecordTypeName;
                if (relObjRtFld.action === "Delete") {
                    dcRelatedObjectRecordType.recordTypeActionCellClass =
                        "slds-text-color_destructive";
                }
                this.previewData.relatedObjectRecordTypeData.push(
                    dcRelatedObjectRecordType
                );
            }
        );

        columns = [];
        for (let i = 0; i < this.relatedObjectRecordTypeColumns.length; i++) {
            const {
                type,
                typeAttributes,
                ...column
            } = this.relatedObjectRecordTypeColumns[i];
            columns.push(column);
        }
        this.previewData.relatedObjectRecordTypeColumns = columns;
    }

    initConfigurationData() {
        let dcConfigId;
        if (this.isEditMode) {
            dcConfigId = this.configurationData.recordId;
        }
        this.configurationData = {};

        if (dcConfigId) {
            this.configurationData.recordId = dcConfigId;
        }

        this.configurationData.dataCleanAction = this.actionValue;
        this.configurationData.masterObjectName = this.selectedObject;
        this.configurationData.masterObjectMatchByFieldName = this.selectedMatchByField;
        this.configurationData.configurationNotes = this.configurationNotes;

        this.configurationData.receiveEmailNotifications = this.receiveEmailNotifications;
        this.configurationData.emailIdsToNotify = this.emailIdsToNotify;

        this.configurationData.receiveErrorEmailNotifications = this.receiveErrorEmailNotifications;
        this.configurationData.errorEmailIdsToNotify = this.errorEmailIdsToNotify;

        this.configurationData.dataCleanProcessStartAfter = this.processStartAfter;
        this.configurationData.dataCleanProcessStartUnit = this.processStartUnitValue;
        this.configurationData.dataCleanProcessStartTime = this.processStartTime;

        this.configurationData.dataCleanProcess2StartAfter = this.process2StartAfter;
        this.configurationData.dataCleanProcess2StartUnit = this.process2StartUnitValue;
        this.configurationData.dataCleanProcess2StartTime = this.process2StartTime;

        this.configurationData.dataCleanDeleteBackupsAfter = this.deleteBackupsAfter;
        this.configurationData.dataCleanDeleteBackupsUnit = this.deleteBackupsUnitValue;
        this.configurationData.dataCleanDeleteBackupsTime = this.deleteBackupsTime;

        this.configurationData.retryProcess = this.retryProcess;
        this.configurationData.retryProcessAfter = this.retryProcessAfter;
        this.configurationData.retryProcessUnit = this.retryProcessUnitValue;

        this.configurationData.retryProcess2 = this.retryProcess2;
        this.configurationData.retryProcess2After = this.retryProcess2After;
        this.configurationData.retryProcess2Unit = this.retryProcess2UnitValue;

        this.configurationData.isConfigurationActive = this.isConfigurationActive;

        this.configurationData.dataCleanRecordTypeAndField = [];
        this.recordTypeSelectedFields.forEach((recordTypeSelectedField) => {
            let dcRecordTypeAndField = {};
            dcRecordTypeAndField.recordId = recordTypeSelectedField.recordId;
            dcRecordTypeAndField.recordTypeName =
                recordTypeSelectedField.recordTypeName;
            dcRecordTypeAndField.recordTypeEnabled =
                recordTypeSelectedField.recordTypeEnabled;
            dcRecordTypeAndField.recordTypeId =
                recordTypeSelectedField.recordTypeId;
            dcRecordTypeAndField.fieldsToMask = recordTypeSelectedField.fieldsToMask.join(
                ", "
            );
            dcRecordTypeAndField.fieldsToEmpty = recordTypeSelectedField.fieldsToEmpty.join(
                ", "
            );
            this.configurationData.dataCleanRecordTypeAndField.push(
                dcRecordTypeAndField
            );
        });
        this.configurationData.dataCleanRelatedObject = [];

        let dcRelatedObjectRecordTypes = [];
        let dcRelatedObject = {};
        let currentRelatedObjetcName;
        let isRelatedObjectChanged;
        this.relatedObjectRecordTypeSelectedFields.forEach(
            (relatedObjectRecordTypeSelectedField) => {
                if (
                    !currentRelatedObjetcName ||
                    currentRelatedObjetcName !==
                        relatedObjectRecordTypeSelectedField.relatedObjectApiName
                ) {
                    currentRelatedObjetcName =
                        relatedObjectRecordTypeSelectedField.relatedObjectApiName;
                    isRelatedObjectChanged = true;
                } else {
                    isRelatedObjectChanged = false;
                }
                if (isRelatedObjectChanged) {
                    dcRelatedObject = {};
                    dcRelatedObjectRecordTypes = [];
                    if (
                        this._recordTypeAndFieldIdToRelatedObjectId &&
                        this._recordTypeAndFieldIdToRelatedObjectId.has(
                            relatedObjectRecordTypeSelectedField.recordId
                        )
                    ) {
                        dcRelatedObject.recordId = this._recordTypeAndFieldIdToRelatedObjectId.get(
                            relatedObjectRecordTypeSelectedField.recordId
                        );
                    }
                    dcRelatedObject.relatedObjectApiName =
                        relatedObjectRecordTypeSelectedField.relatedObjectApiName;
                    dcRelatedObject.deleteRecords = this.selectedRelatedObjectDeletionValues.includes(
                        relatedObjectRecordTypeSelectedField.relatedObjectApiName
                    );
                }

                let dcRelatedObjectRecordType = {};
                dcRelatedObjectRecordType.recordId =
                    relatedObjectRecordTypeSelectedField.recordId;
                dcRelatedObjectRecordType.recordTypeId =
                    relatedObjectRecordTypeSelectedField.recordTypeId;
                dcRelatedObjectRecordType.recordTypeName =
                    relatedObjectRecordTypeSelectedField.recordTypeName;
                dcRelatedObjectRecordType.recordTypeEnabled =
                    relatedObjectRecordTypeSelectedField.recordTypeEnabled;
                dcRelatedObjectRecordType.fieldsToMask = relatedObjectRecordTypeSelectedField.fieldsToMask.join(
                    ", "
                );
                dcRelatedObjectRecordType.fieldsToEmpty = relatedObjectRecordTypeSelectedField.fieldsToEmpty.join(
                    ", "
                );
                dcRelatedObjectRecordTypes.push(dcRelatedObjectRecordType);
                if (isRelatedObjectChanged) {
                    dcRelatedObject.dataCleanRelatedObjectRecordTypeAndField = dcRelatedObjectRecordTypes;
                    this.configurationData.dataCleanRelatedObject.push(
                        dcRelatedObject
                    );
                }
            }
        );
        output("this.configurationData", this.configurationData);
    }

    initComponentFromConfigurationData() {
        this.recordId = this.configurationData.recordId;
        this.actionValue = this.configurationData.dataCleanAction;
        this.selectedObject = this.configurationData.masterObjectName;
        this.selectedMatchByField = this.configurationData.masterObjectMatchByFieldName;
        this.configurationNotes = this.configurationData.configurationNotes;

        this.receiveEmailNotifications = this.configurationData.receiveEmailNotifications;
        this.emailIdsToNotify = this.configurationData.emailIdsToNotify;

        this.receiveErrorEmailNotifications = this.configurationData.receiveErrorEmailNotifications;
        this.errorEmailIdsToNotify = this.configurationData.errorEmailIdsToNotify;

        this.processStartAfter = this.configurationData.dataCleanProcessStartAfter;
        this.processStartUnitValue = this.configurationData.dataCleanProcessStartUnit;
        this.processStartTime = this.configurationData.dataCleanProcessStartTime;

        this.process2StartAfter = this.configurationData.dataCleanProcess2StartAfter;
        this.process2StartUnitValue = this.configurationData.dataCleanProcess2StartUnit;
        this.process2StartTime = this.configurationData.dataCleanProcess2StartTime;

        this.deleteBackupsAfter = this.configurationData.dataCleanDeleteBackupsAfter;
        this.deleteBackupsUnitValue = this.configurationData.dataCleanDeleteBackupsUnit;
        this.deleteBackupsTime = this.configurationData.dataCleanDeleteBackupsTime;

        this.retryProcess = this.configurationData.retryProcess;
        this.retryProcessAfter = this.configurationData.retryProcessAfter;
        this.retryProcessUnitValue = this.configurationData.retryProcessUnit;

        this.retryProcess2 = this.configurationData.retryProcess2;
        this.retryProcess2After = this.configurationData.retryProcess2After;
        this.retryProcess2UnitValue = this.configurationData.retryProcess2Unit;

        this.isConfigurationActive = this.configurationData.isConfigurationActive;

        this.configurationData.dataCleanRecordTypeAndField.forEach(
            (dcRecordTypeAndField) => {
                let recordTypeSelectedField = {};
                recordTypeSelectedField.recordId =
                    dcRecordTypeAndField.recordId;
                recordTypeSelectedField.recordTypeId =
                    dcRecordTypeAndField.recordTypeId;
                recordTypeSelectedField.recordTypeName =
                    dcRecordTypeAndField.recordTypeName;
                recordTypeSelectedField.recordTypeEnabled =
                    dcRecordTypeAndField.recordTypeEnabled;
                recordTypeSelectedField.fieldsToMask = dcRecordTypeAndField.fieldsToMask
                    ? dcRecordTypeAndField.fieldsToMask
                          .replace(/\s/g, "")
                          .split(",")
                    : [];
                recordTypeSelectedField.fieldsToEmpty = dcRecordTypeAndField.fieldsToEmpty
                    ? dcRecordTypeAndField.fieldsToEmpty
                          .replace(/\s/g, "")
                          .split(",")
                    : [];
                this.recordTypeSelectedFields.push(recordTypeSelectedField);
            }
        );

        this.configurationData.dataCleanRelatedObject.forEach(
            (dcRelatedObject) => {
                if (dcRelatedObject.deleteRecords) {
                    this.selectedRelatedObjectDeletionValues.push(
                        dcRelatedObject.relatedObjectApiName
                    );
                } else {
                    this.selectedRelatedObjectMaskingValues.push(
                        dcRelatedObject.relatedObjectApiName
                    );
                }
            }
        );

        this._recordTypeAndFieldIdToRelatedObjectId = new Map();

        this.configurationData.dataCleanRelatedObject.forEach(
            (dcRelatedObject) => {
                dcRelatedObject.dataCleanRelatedObjectRecordTypeAndField.forEach(
                    (dcRelatedObjectRecordTypeAndField) => {
                        this._recordTypeAndFieldIdToRelatedObjectId.set(
                            dcRelatedObjectRecordTypeAndField.recordId,
                            dcRelatedObject.recordId
                        );
                        let relatedObjectRecordTypeSelectedField = {};
                        relatedObjectRecordTypeSelectedField.recordId =
                            dcRelatedObjectRecordTypeAndField.recordId;
                        relatedObjectRecordTypeSelectedField.relatedObjectApiNameAndRecordTypeId =
                            dcRelatedObject.relatedObjectApiName +
                            "-" +
                            dcRelatedObjectRecordTypeAndField.recordTypeId;
                        relatedObjectRecordTypeSelectedField.relatedObjectApiName =
                            dcRelatedObject.relatedObjectApiName;
                        relatedObjectRecordTypeSelectedField.recordTypeId = dcRelatedObjectRecordTypeAndField.recordTypeId
                            ? dcRelatedObjectRecordTypeAndField.recordTypeId
                            : "";
                        relatedObjectRecordTypeSelectedField.recordTypeName = dcRelatedObjectRecordTypeAndField.recordTypeName
                            ? dcRelatedObjectRecordTypeAndField.recordTypeName
                            : "";
                        relatedObjectRecordTypeSelectedField.recordTypeEnabled =
                            dcRelatedObjectRecordTypeAndField.recordTypeEnabled;
                        relatedObjectRecordTypeSelectedField.fieldsToMask = dcRelatedObjectRecordTypeAndField.fieldsToMask
                            ? dcRelatedObjectRecordTypeAndField.fieldsToMask
                                  .replace(/\s/g, "")
                                  .split(",")
                            : [];
                        relatedObjectRecordTypeSelectedField.fieldsToEmpty = dcRelatedObjectRecordTypeAndField.fieldsToEmpty
                            ? dcRelatedObjectRecordTypeAndField.fieldsToEmpty
                                  .replace(/\s/g, "")
                                  .split(",")
                            : [];
                        this.relatedObjectRecordTypeSelectedFields.push(
                            relatedObjectRecordTypeSelectedField
                        );
                    }
                );
            }
        );
        if (this.relatedObjectRecordTypeSelectedFields.length > 0) {
            this.addRelatedObjectsFlag = true;
            this.addStep5();
        }
    }

    navigateOnConfigurationSave() {
        const configurationSaveEvent = new CustomEvent("configurationsave", {
            detail: {}
        });
        this.dispatchEvent(configurationSaveEvent);
    }

    // Validations

    validateInputFields() {
        const allValid = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

    validateRadioButtons() {
        const allValid = [
            ...this.template.querySelectorAll("lightning-radio-group")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

    validateComboBox() {
        const allValid = [
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

    validateTextArea() {
        const allValid = [
            ...this.template.querySelectorAll("lightning-textarea")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

    validateRecordTypeSelectedFieldsForEnabledRT() {
        let index = this.recordTypeSelectedFields.findIndex(
            (recordTypeSelectedField) =>
                recordTypeSelectedField.recordTypeEnabled
        );
        return index >= 0;
    }

    validateRecordTypeSelectedFieldsForFieldSelection() {
        let index1 = this.recordTypeSelectedFields.findIndex(
            (recordTypeSelectedField) =>
                recordTypeSelectedField.fieldsToMask.length > 0
        );
        let index2 = this.recordTypeSelectedFields.findIndex(
            (recordTypeSelectedField) =>
                recordTypeSelectedField.fieldsToEmpty.length > 0
        );
        return index1 >= 0 || index2 >= 0;
    }

    validateSelectedRelatedObjectMaskingValues() {
        if (!this.addRelatedObjectsFlag) {
            return true;
        }
        if (!this.isMaskAction) {
            return true;
        } else {
            this.saveSelectedRelatedObjectMaskingValues();
            return this.selectedRelatedObjectMaskingValues.length > 0;
        }
    }

    validateSelectedRelatedObjectDeletionValues() {
        if (!this.addRelatedObjectsFlag) {
            return true;
        }
        this.saveSelectedRelatedObjectDeletionValues();
        return this.selectedRelatedObjectDeletionValues.length > 0;
    }

    validateSelectedRelatedObjectMaskingDeletionCommonValues() {
        if (!this.addRelatedObjectsFlag) {
            return { isStep4Valid3: true, commonObjectList: undefined };
        }
        if (!this.isMaskAction) {
            return { isStep4Valid3: true, commonObjectList: undefined };
        } else {
            const commonValues = this.selectedRelatedObjectMaskingValues.filter(
                (value) =>
                    this.selectedRelatedObjectDeletionValues.includes(value)
            );
            if (commonValues.length > 0) {
                return {
                    isStep4Valid3: false,
                    commonObjectList: commonValues.join(", ")
                };
            } else {
                return { isStep4Valid3: true, commonObjectList: undefined };
            }
        }
    }

    validateRelatedObjectRecordTypeSelectedFieldsForEnabledRT() {
        let index = this.relatedObjectRecordTypeSelectedFields.findIndex(
            (recordTypeSelectedField) =>
                recordTypeSelectedField.recordTypeEnabled
        );
        return index >= 0;
    }

    validateRelatedObjectRecordTypeSelectedFieldsForFieldSelection() {
        let index1 = this.relatedObjectRecordTypeSelectedFields.findIndex(
            (recordTypeSelectedField) =>
                recordTypeSelectedField.fieldsToMask.length > 0
        );
        let index2 = this.relatedObjectRecordTypeSelectedFields.findIndex(
            (recordTypeSelectedField) =>
                recordTypeSelectedField.fieldsToEmpty.length > 0
        );
        return index1 >= 0 || index2 >= 0;
    }

    validateProcessStartAndBackupExpiryDates() {
        if (!this.isBackupAction) {
            return true;
        }

        let d1 = shiftDate(
            this.processStartAfter,
            this.processStartUnitValue
        ).getTime();

        let d2 = shiftDate(
            this.deleteBackupsAfter,
            this.deleteBackupsUnitValue
        ).getTime();

        let t1 = this.processStartTime;
        let t2 = this.deleteBackupsTime;

        if (d1 > d2) {
            return false;
        } else if (d1 === d2) {
            if (t1 >= t2) {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    }

    validateBackupExpiryAndPostDeleteDates() {
        if (!this.isBackupAction || !this.isPostDeleteAction) {
            return true;
        }

        if (!this.isBackupAction) {
            return true;
        }

        let d1 = shiftDate(
            this.deleteBackupsAfter,
            this.deleteBackupsUnitValue
        ).getTime();

        let d2 = shiftDate(
            this.process2StartAfter,
            this.process2StartUnitValue
        ).getTime();

        let t1 = this.deleteBackupsTime;
        let t2 = this.process2StartTime;

        if (d1 > d2) {
            return false;
        } else if (d1 === d2) {
            if (t1 >= t2) {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    }

    validateProcessStartAndPostDeleteDates() {
        if (!this.isPostDeleteAction) {
            return true;
        }

        if (!this.isBackupAction) {
            return true;
        }

        let d1 = shiftDate(
            this.processStartAfter,
            this.processStartUnitValue
        ).getTime();

        let d2 = shiftDate(
            this.process2StartAfter,
            this.process2StartUnitValue
        ).getTime();

        let t1 = this.processStartTime;
        let t2 = this.process2StartTime;

        if (d1 > d2) {
            return false;
        } else if (d1 === d2) {
            if (t1 >= t2) {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    }

    validateEmailIdsToNotify() {
        if (!this.receiveEmailNotifications) {
            return true;
        }
        const emailIdsToNotify = this.emailIdsToNotify.replace(/\s/g, "");
        let emailIdsToNotifyArray = emailIdsToNotify.split(",");
        for (let i = 0; i < emailIdsToNotifyArray.length; i++) {
            const emailId = emailIdsToNotifyArray[i];
            if (!validateEmail(emailId)) {
                return false;
            }
        }
        return true;
    }

    validateErrorEmailIdsToNotify() {
        if (!this.receiveErrorEmailNotifications) {
            return true;
        }
        const errorEmailIdsToNotify = this.errorEmailIdsToNotify.replace(
            /\s/g,
            ""
        );
        let errorEmailIdsToNotifyArray = errorEmailIdsToNotify.split(",");
        for (let i = 0; i < errorEmailIdsToNotifyArray.length; i++) {
            const emailId = errorEmailIdsToNotifyArray[i];
            if (!validateEmail(emailId)) {
                return false;
            }
        }
        return true;
    }

    validateEmailIdsToNotifyForMaxEmails(maxEmails) {
        if (!this.receiveEmailNotifications) {
            return true;
        }
        const emailIdsToNotify = this.emailIdsToNotify.replace(/\s/g, "");
        let emailIdsToNotifyArray = emailIdsToNotify.split(",");
        return emailIdsToNotifyArray.length <= maxEmails;
    }

    validateErrorEmailIdsToNotifyForMaxEmails(maxErrorEmails) {
        if (!this.receiveErrorEmailNotifications) {
            return true;
        }
        const errorEmailIdsToNotify = this.errorEmailIdsToNotify.replace(
            /\s/g,
            ""
        );
        let errorEmailIdsToNotifyArray = errorEmailIdsToNotify.split(",");
        return errorEmailIdsToNotifyArray.length <= maxErrorEmails;
    }

    validateData() {
        let validity = {
            isValid: true,
            errorMessage: "Please resolve all errors"
        };
        validity.isValid =
            this.validateInputFields() &&
            this.validateRadioButtons() &&
            this.validateComboBox() &&
            this.validateTextArea();
        if (!validity.isValid) {
            showToast("Error!", validity.errorMessage, "Error");
            return false;
        }
        switch (this.progressIndicatorCurrentStep) {
            case "step1":
                break;

            case "step2":
                break;

            case "step3":
                let isStep3Valid1 = this.validateRecordTypeSelectedFieldsForEnabledRT();
                let isStep3Valid2 = this.validateRecordTypeSelectedFieldsForFieldSelection();
                if (!isStep3Valid1) {
                    validity.errorMessage =
                        "At least one record type should be enabled for masking";
                } else if (!isStep3Valid2) {
                    validity.errorMessage =
                        "Please select fields to mask or empty";
                }
                validity.isValid = isStep3Valid1 && isStep3Valid2;
                break;

            case "step4":
                let isStep4Valid1 = this.validateSelectedRelatedObjectMaskingValues();
                let isStep4Valid2 = this.validateSelectedRelatedObjectDeletionValues();
                let {
                    isStep4Valid3,
                    commonObjectList
                } = this.validateSelectedRelatedObjectMaskingDeletionCommonValues();
                if (!isStep4Valid1) {
                    validity.errorMessage =
                        "Please select at least one related object to mask";
                } else if (!isStep4Valid2) {
                    validity.errorMessage =
                        "Please select at least one related object to delete";
                } else if (!isStep4Valid3) {
                    validity.errorMessage =
                        "Please make sure the object selected for masking and deletion are mutually exclusive. Common objects found: " +
                        commonObjectList;
                }
                validity.isValid =
                    (isStep4Valid1 || isStep4Valid2) && isStep4Valid3;
                break;

            case "step5":
                let isStep5Valid1 = this.validateRecordTypeSelectedFieldsForEnabledRT();
                let isStep5Valid2 = this.validateRecordTypeSelectedFieldsForFieldSelection();
                if (!isStep5Valid1) {
                    validity.errorMessage =
                        "At least one related object should be enabled for masking";
                } else if (!isStep5Valid2) {
                    validity.errorMessage =
                        "Please select fields to mask or empty";
                }
                validity.isValid = isStep5Valid1 && isStep5Valid2;
                break;

            case "step6":
                //let isStep6Valid1 = this.validateProcessStartAndBackupExpiryDates();
                let isStep6Valid1 = true;
                let isStep6Valid2 = this.validateBackupExpiryAndPostDeleteDates();
                //let isStep6Valid3 = this.validateProcessStartAndPostDeleteDates();
                let isStep6Valid3 = true;
                let isStep6Valid4 = this.validateEmailIdsToNotify();
                let isStep6Valid5 = this.validateErrorEmailIdsToNotify();
                let isStep6Valid6 = this.validateEmailIdsToNotifyForMaxEmails(
                    5
                );
                let isStep6Valid7 = this.validateErrorEmailIdsToNotifyForMaxEmails(
                    5
                );
                if (!isStep6Valid1) {
                    if (this.isMaskAction) {
                        validity.errorMessage =
                            "Backup expiry date should be ahead of masking process start date";
                    } else if (this.isDeleteAction) {
                        validity.errorMessage =
                            "Backup expiry date should be ahead of delete process start date";
                    } else {
                        validity.errorMessage =
                            "Backup expiry date should be ahead of archive process start date";
                    }
                } else if (!isStep6Valid2) {
                    validity.errorMessage =
                        "Backup expiry date should be before deletion start date";
                } else if (!isStep6Valid3) {
                    if (this.isMaskAction) {
                        validity.errorMessage =
                            "Deletion date should be ahead of masking process start date";
                    } else {
                        validity.errorMessage =
                            "Archiving date should be ahead of masking process start date";
                    }
                } else if (!isStep6Valid4) {
                    validity.errorMessage =
                        "Please check the emails entered in 'Enter Email Ids to Notify (Success & Errors)' field";
                } else if (!isStep6Valid5) {
                    validity.errorMessage =
                        "Please check the emails entered in 'Enter Email Ids to Notify (Errors Only)' field";
                } else if (!isStep6Valid6) {
                    validity.errorMessage =
                        "You can only enter maximum 5 emails on 'Enter Email Ids to Notify (Success & Errors)' field";
                } else if (!isStep6Valid7) {
                    validity.errorMessage =
                        "You can only enter maximum 5 emails on 'Enter Email Ids to Notify (Errors Only)' field";
                }
                validity.isValid =
                    isStep6Valid1 &&
                    isStep6Valid2 &&
                    isStep6Valid3 &&
                    isStep6Valid4 &&
                    isStep6Valid5 &&
                    isStep6Valid6 &&
                    isStep6Valid7;
                break;
        }
        if (!validity.isValid) {
            showToast("Error!", validity.errorMessage, "Error");
            return false;
        } else {
            return true;
        }
    }

    // Event Handlers

    handlePrevious() {
        switch (this.progressIndicatorCurrentStep) {
            case "step2":
                break;

            case "step3":
                this.alerts.topOfStep = false;
                break;

            case "step4":
                break;

            case "step5":
                break;

            case "step6":
                break;

            case "step7":
                break;
        }
        this.movePrevious();
    }

    handleNext() {
        try {
            if (!this.validateData()) {
                return;
            }
        } catch (error) {
            this.serverError = error;
            return;
        }
        switch (this.progressIndicatorCurrentStep) {
            case "step1":
                if (!this.isEditMode) {
                    this.initAllObjectOptions();
                    if (this.selectedObject) {
                        this.initPotentialExternalIdFieldsOptions();
                    }
                } else {
                    this.allObjectOptions = [
                        {
                            label: this.selectedObject,
                            value: this.selectedObject
                        }
                    ];
                    this.potentialExternalIdFieldsOptions = [
                        {
                            label: this.selectedMatchByField,
                            value: this.selectedMatchByField
                        }
                    ];
                }
                break;

            case "step2":
                this.alerts.topOfStep = true;
                if (this.isMaskAction) {
                    this.initRecordTypesAndFields();
                }
                break;

            case "step3":
                if (this.addRelatedObjectsFlag) {
                    if (this.isMaskOrArchiveAction) {
                        this.initRelatedObjectMaskingOptions();
                    }
                    if (this.isDeleteAction) {
                        this.initRelatedObjectDeletionOptions();
                    }
                }
                break;

            case "step4":
                if (this.addRelatedObjectsFlag) {
                    this.initRelatedObjectRecordTypesandFields();
                }
                break;

            case "step5":
                break;

            case "step6":
                this.openExampleBeforeMovingToNextStep();
                return;
        }
        this.moveNext();
    }

    handleCancel(event) {
        const configurationCancelEvent = new CustomEvent(
            "configurationcancel",
            {
                detail: {}
            }
        );
        this.dispatchEvent(configurationCancelEvent);
    }

    handleSave() {
        this.spinners.full = true;
        this.initConfigurationData();
        saveDataCleanConfigurations({
            dataCleanConfigString: JSON.stringify(this.configurationData)
        })
            .then((result) => {
                if (result.isSuccess) {
                    showToast(
                        "Success!",
                        "Configuration saved Successfully.",
                        "success"
                    );
                    this.navigateOnConfigurationSave();
                } else {
                    showToast("Error!", result.errorMessage, "error");
                }
                this.spinners.full = false;
            })
            .catch((error) => {
                this.serverError = error;
                this.spinners.full = false;
            });
    }

    handleStepBlur(event) {
        const stepIndex = event.detail.index;
        if (
            stepIndex + 1 >=
            parseInt(
                this.progressIndicatorCurrentStep.substr(
                    this.progressIndicatorCurrentStep.length - 1
                )
            )
        ) {
            return;
        }
        this.toggleActiveInactive(
            CONSTANTS.STEP_PREFIX + (stepIndex + 1),
            this.steps
        );
    }

    handleCloseAlert(event) {
        this.alerts[event.currentTarget.dataset.id] = false;
    }

    handleProgressStepClick(event) {
        event.currentTarget.classList.remove("slds-is-active");
    }

    handleActionValueChange(event) {
        if (this.isEditMode) {
            this.serverError = {
                message:
                    "You cannot edit action in an existing Data Clean Configuration. Please try creating a new one."
            };
            this.actionValue = this.actionValue;
            return;
        }
        this.actionValue = event.detail.value;
        if (this.isMaskAction) {
            this.addStep3();
            if (this.addRelatedObjectsFlag) {
                this.addStep5();
            }
        } else {
            this.removeStep3();
        }
    }

    handleObjectChange(event) {
        if (this.isEditMode) {
            this.serverError = {
                message:
                    "You cannot edit object in an existing Data Clean Configuration. Please try creating a new one."
            };
            this.selectedObject = this.selectedObject;
            return;
        }
        this.selectedObject = event.detail.value;
        if (this.selectedObject) {
            this.initPotentialExternalIdFieldsOptions();
            this.inititialize();
        }
    }

    handleMatchByFieldChange(event) {
        if (this.isEditMode) {
            this.serverError = {
                message:
                    "You cannot edit Match By Field in an existing Data Clean Configuration. Please try creating a new one."
            };
            this.selectedMatchByField = this.selectedMatchByField;
            return;
        }
        this.selectedMatchByField = event.detail.value;
    }

    handleRowActionStep3(event) {
        const recordTypeId = event.detail.row.recordTypeId;
        const actionName = event.detail.action.name;
        this.openFieldsSelectorModal(recordTypeId, actionName);
    }

    handleRowActionStep5(event) {
        const recordTypeId = event.detail.row.relatedObjectRecordTypeId;
        const actionName = event.detail.action.name;
        const relatedObjectApiName = event.detail.row.relatedObjectApiName;
        const relatedObjectApiNameAndRecordTypeId =
            event.detail.row.relatedObjectApiNameAndRecordTypeId;
        this.openFieldsSelectorModal(
            recordTypeId,
            actionName,
            relatedObjectApiName,
            relatedObjectApiNameAndRecordTypeId
        );
    }

    handleToggleChangeStep3(event) {
        const recordTypeId = event.detail.value.rowId;
        const state = event.detail.value.state;
        for (let i = 0; i < this.recordTypeData.length; i++) {
            if (this.recordTypeData[i].recordTypeId === recordTypeId) {
                this.recordTypeData[i].recordTypeToggleCellChecked = state;
                if (state) {
                    this.recordTypeData[
                        i
                    ].maskFieldSelectedButtonCellDisabled = false;
                    this.recordTypeData[
                        i
                    ].emptyFieldSelectedButtonCellDisabled = false;
                } else {
                    this.recordTypeData[
                        i
                    ].maskFieldSelectedButtonCellDisabled = true;
                    this.recordTypeData[
                        i
                    ].emptyFieldSelectedButtonCellDisabled = true;
                }
                break;
            }
        }
        for (let i = 0; i < this.recordTypeSelectedFields.length; i++) {
            if (
                this.recordTypeSelectedFields[i].recordTypeId === recordTypeId
            ) {
                this.recordTypeSelectedFields[i].recordTypeEnabled = state;
                break;
            }
        }
        this.recordTypeData = [...this.recordTypeData];
        this.recordTypeSelectedFields = [...this.recordTypeSelectedFields];
    }

    handleToggleChangeStep5(event) {
        const relatedObjectApiNameAndRecordTypeId = event.detail.value.rowId;
        const state = event.detail.value.state;
        for (let i = 0; i < this.relatedObjectRecordTypeData.length; i++) {
            if (
                this.relatedObjectRecordTypeData[i]
                    .relatedObjectApiNameAndRecordTypeId ===
                relatedObjectApiNameAndRecordTypeId
            ) {
                this.relatedObjectRecordTypeData[
                    i
                ].recordTypeToggleCellChecked = state;
                if (state) {
                    if (
                        this.relatedObjectRecordTypeData[i].action !== "Delete"
                    ) {
                        this.relatedObjectRecordTypeData[
                            i
                        ].maskFieldSelectedButtonCellDisabled = false;
                        this.relatedObjectRecordTypeData[
                            i
                        ].emptyFieldSelectedButtonCellDisabled = false;
                    }
                } else {
                    this.relatedObjectRecordTypeData[
                        i
                    ].maskFieldSelectedButtonCellDisabled = true;
                    this.relatedObjectRecordTypeData[
                        i
                    ].emptyFieldSelectedButtonCellDisabled = true;
                }
                break;
            }
        }
        for (
            let i = 0;
            i < this.relatedObjectRecordTypeSelectedFields.length;
            i++
        ) {
            if (
                this.relatedObjectRecordTypeSelectedFields[i]
                    .relatedObjectApiNameAndRecordTypeId ===
                relatedObjectApiNameAndRecordTypeId
            ) {
                this.relatedObjectRecordTypeSelectedFields[
                    i
                ].recordTypeEnabled = state;
                break;
            }
        }
        this.relatedObjectRecordTypeData = [
            ...this.relatedObjectRecordTypeData
        ];
        this.relatedObjectRecordTypeSelectedFields = [
            ...this.relatedObjectRecordTypeSelectedFields
        ];
    }

    handleToggleChangeStep6Process(event) {
        this.retryProcess = event.detail.value.state;
    }

    handleToggleChangeStep6Process2(event) {
        this.retryProcess2 = event.detail.value.state;
    }

    handleToggleChangeStep6ReceiveEmailNotifications(event) {
        this.receiveEmailNotifications = event.detail.value.state;
    }

    handleToggleChangeStep6ReceiveErrorEmailNotifications(event) {
        this.receiveErrorEmailNotifications = event.detail.value.state;
    }

    handleEmailIdsToNotifyChange(event) {
        this.emailIdsToNotify = event.detail.value;
    }

    handleErrorEmailIdsToNotifyChange(event) {
        this.errorEmailIdsToNotify = event.detail.value;
    }

    handleSeeExampleClick() {
        try {
            this.showConfirmButttonPanelOnStep6Example = false;
            this.template
                .querySelector(
                    'c-data-clean-confirmation-prompt[data-id="exampleInfo"]'
                )
                .show();
        } catch (error) {
            this.serverError = error;
        }
    }

    openExampleBeforeMovingToNextStep() {
        try {
            this.showConfirmButttonPanelOnStep6Example = true;
            this.template
                .querySelector(
                    'c-data-clean-confirmation-prompt[data-id="exampleInfo"]'
                )
                .show();
        } catch (error) {
            this.serverError = error;
        }
    }

    handleConfirmExampleStep6(event) {
        try {
            this.initPreviewData();
            this.initConfigurationData();
            this.moveNext();
        } catch (error) {
            this.serverError = error;
        }
    }

    handleSaveFieldsSelectorModal() {
        this.selectedFieldValues = this.template
            .querySelector("c-data-clean-searchable-lightning-dual-listbox")
            .getSelectedValues();
        let isFieldSelected =
            this.selectedFieldValues && this.selectedFieldValues.length > 0;
        if (this.currentModalProperty.relatedObjectApiName) {
            this.updateRelatedObjectRecordTypeSelectedFields();
            this.updateRelatedObjectRecordTypeColumns(isFieldSelected);
        } else {
            this.updateRecordTypeSelectedFields();
            this.updateRecordTypeColumns(isFieldSelected);
        }
        this.clearCurrentModalProperties();
        this.hideFieldSelectorModal();
        this.modals.fieldSelectorModal = false;
    }

    handleCancelFieldsSelectorModal() {
        this.clearCurrentModalProperties();
        this.hideFieldSelectorModal();
        this.modals.fieldSelectorModal = false;
    }

    handleAddRelatedObjectsFlagChange(event) {
        this.addRelatedObjectsFlag = event.target.checked;
        if (this.addRelatedObjectsFlag) {
            this.addStep5();
            if (
                this.relatedObjectMaskingOptions.length === 0 &&
                this.isMaskOrArchiveAction
            ) {
                this.initRelatedObjectMaskingOptions();
            }
            if (this.relatedObjectDeletionOptions.length === 0) {
                this.initRelatedObjectDeletionOptions();
            }
        } else {
            this.removeStep5();
        }
    }

    handleConfigurationNotesChange(event) {
        this.configurationNotes = event.detail.value;
    }

    handleProcessStartAfterChange(event) {
        this.processStartAfter = event.detail.value;
    }

    handleProcessStartUnitChange(event) {
        this.processStartUnitValue = event.detail.value;
    }

    handleProcessStartTimeChange(event) {
        this.processStartTime = event.detail.value;
    }

    handleProcess2StartAfterChange(event) {
        this.process2StartAfter = event.detail.value;
    }

    handleProcess2StartUnitChange(event) {
        this.process2StartUnitValue = event.detail.value;
    }

    handleProcess2StartTimeChange(event) {
        this.process2StartTime = event.detail.value;
    }

    handleDeleteBackupsAfterChange(event) {
        this.deleteBackupsAfter = event.detail.value;
    }

    handleDeleteBackupsUnitChange(event) {
        this.deleteBackupsUnitValue = event.detail.value;
    }

    handleDeleteBackupsTimeChange(event) {
        this.deleteBackupsTime = event.detail.value;
    }

    handleRetryProcessAfterChange(event) {
        this.retryProcessAfter = event.detail.value;
    }

    handleRetryProcessUnitChange(event) {
        this.retryProcessUnitValue = event.detail.value;
    }

    handleRetryProcess2AfterChange(event) {
        this.retryProcess2After = event.detail.value;
    }

    handleRetryProcess2UnitChange(event) {
        this.retryProcess2UnitValue = event.detail.value;
    }
}