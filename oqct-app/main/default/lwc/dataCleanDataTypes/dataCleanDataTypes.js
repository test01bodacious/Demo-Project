import { LightningElement, track, api, wire } from "lwc";

import { refreshApex } from "@salesforce/apex";

import {
    output,
    dataCleanDataTypeComponentConstants,
    showToast,
    processDatatableCoulumns,
    processDatatableData,
    exportDatatable,
    DC_DATA_TYPE_OBJECT
} from "c/utilsJS";

// Apex Methods (DataCleanDataTypeController)
import getDatatable from "@salesforce/apex/DataCleanDataTypeController.getDatatable";
import saveDataType from "@salesforce/apex/DataCleanDataTypeController.saveDataType";

const CONSTANTS = dataCleanDataTypeComponentConstants;

export default class DataCleanDataTypes extends LightningElement {
    @track dataCleanDataTypeColumns;
    @track dataCleanDataTypeData;

    wiredResults;

    @track currentRow = {};

    isCustomLength = false;

    customLengthValue = 255;

    valueType = "";

    domainValue = "";

    dataLengthValueForMasking = "Match Record Original Data Length";

    maskingPattern = "Alphabets (Lower Case Letters Only)";

    get dataLengthOptionsForMasking() {
        return [
            {
                label: "Match Record Original Data Length",
                value: "Match Record Original Data Length"
            },
            {
                label: "Match Object field Length",
                value: "Match Object field Length"
            },
            { label: "Enter Custom Length", value: "Enter Custom Length" }
        ];
    }

    get dataTypeMaskingOptions() {
        return [
            {
                label: "Alphabets (Lower Case Letters Only)",
                value: "Alphabets (Lower Case Letters Only)"
            },
            {
                label: "Alphabets (Upper Case Letters Only)",
                value: "Alphabets (Upper Case Letters Only)"
            },
            {
                label: "Alphabets (Lower Case and Upper Case Letters Mix)",
                value: "Alphabets (Lower Case and Upper Case Letters Mix)"
            },
            {
                label: "Alphanumeric (Numbers and Lower Case Letters Only)",
                value: "Alphanumeric (Numbers and Lower Case Letters Only)"
            },
            {
                label: "Alphanumeric (Numbers and Upper Case Letters Only)",
                value: "Alphanumeric (Numbers and Upper Case Letters Only)"
            },
            {
                label:
                    "Alphanumeric (Numbers, Lower Case and Upper Case Letters Mix)",
                value:
                    "Alphanumeric (Numbers, Lower Case and Upper Case Letters Mix)"
            },
            {
                label:
                    "AlphanumericWithSpecialCharacters (Special Characters, Numbers, Lower Case and Upper Case Letters Mix)",
                value:
                    "AlphanumericWithSpecialCharacters (Special Characters, Numbers, Lower Case and Upper Case Letters Mix)"
            }
        ];
    }

    get dataTypeOptions() {
        switch (this.currentRow.OQCT_DaCl__Data_Type_Name__c) {
            case "TEXT":
            case "TEXTAREA":
            case "TEXTAREA (Long)":
            case "TEXTAREA (Rich)":
            case "TEXT (Encrypted)":
            case "PICKLIST (Unrestrictive)":
            case "MULTIPICKLIST (Unrestrictive)":
                return this.textOptions;

            case "PICKLIST (Restrictive)":
            case "MULTIPICKLIST (Restrictive)":
                return this.restrictivePicklistOptions;

            case "PHONE":
                return this.phoneOptions;

            case "NUMBER":
                return this.numberOptions;

            case "PERCENT":
                return this.percentOptions;

            case "CURRENCY":
                return this.currencyOptions;

            case "BOOLEAN (Checkbox)":
                return this.booleanOptions;

            case "DATE":
                return this.dateOptions;

            case "DATE TIME":
                return this.dateTimeOptions;

            case "TIME":
                return this.timeOptions;

            case "LOCATION (Latitude)":
                return this.locationLatitudeOptions;

            case "LOCATION (Longitude)":
                return this.locationLongitudeOptions;

            case "EMAIL":
                return this.emailOptions;

            case "URL":
                return this.urlOptions;

            default:
                break;
        }
    }

    get textOptions() {
        return [
            {
                label: "Random Text",
                value: "Random Text"
            }
        ];
    }

    get numberOptions() {
        return [
            {
                label: "Random Number",
                value: "Random Number"
            }
        ];
    }

    get percentOptions() {
        return [
            {
                label: "Random Percentage",
                value: "Random Percentage"
            }
        ];
    }

    get currencyOptions() {
        return [
            {
                label: "Random Currency",
                value: "Random Currency"
            }
        ];
    }

    get phoneOptions() {
        return [
            {
                label: "Random Phone",
                value: "Random Phone"
            }
        ];
    }

    get booleanOptions() {
        return [
            {
                label: "Random Boolean",
                value: "Random Boolean"
            }
        ];
    }

    get restrictivePicklistOptions() {
        return [
            {
                label: "Random Value Available in Picklist Value Set",
                value: "Random Value Available in Picklist Value Set"
            }
        ];
    }

    get emailOptions() {
        return [
            {
                label: "Random Email",
                value: "Random Email"
            }
        ];
    }

    get urlOptions() {
        return [
            {
                label: "Random URL",
                value: "Random URL"
            }
        ];
    }

    get dateOptions() {
        return [
            {
                label: "Random Date",
                value: "Random Date"
            },
            {
                label: "Random Future Date",
                value: "Random Future Date"
            },
            {
                label: "Random Past Date",
                value: "Random Past Date"
            }
        ];
    }

    get dateTimeOptions() {
        return [
            {
                label: "Random DateTime",
                value: "Random DateTime"
            },
            {
                label: "Random Future DateTime",
                value: "Random Future DateTime"
            },
            {
                label: "Random Past DateTime",
                value: "Random Past DateTime"
            }
        ];
    }

    get timeOptions() {
        return [
            {
                label: "Random Time",
                value: "Random Time"
            }
        ];
    }

    get locationLatitudeOptions() {
        return [
            {
                label: "Random Location (Latitude)",
                value: "Random Location (Latitude)"
            }
        ];
    }

    get locationLongitudeOptions() {
        return [
            {
                label: "Random Location (Longitude)",
                value: "Random Location (Longitude)"
            }
        ];
    }

    get datatableRequestParamsString() {
        return JSON.stringify(
            Object.assign({}, CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DC_DATA_TYPE)
        );
    }

    recordsPerPage = CONSTANTS.RECORDS_PER_PAGE;

    noDataMessage = CONSTANTS.NO_DATA_MESSAGE;
    hideCloseButtonOnNoData = true;

    @track spinners = {
        full: true,
        dataTypeModal: false
    };

    _serverError;

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

    get isDataCleanDataTypeData() {
        return (
            this.dataCleanDataTypeData && this.dataCleanDataTypeData.length > 0
        );
    }

    get editDatatypeHeader() {
        return `Edit Datatype - ${this.currentRow.OQCT_DaCl__Data_Type_Name__c}`;
    }

    get maxLength() {
        let dataType = this.currentRow.OQCT_DaCl__Data_Type_Name__c;
        switch (dataType) {
            case "TEXT":
            case "TEXTAREA":
            case "URL":
            case "PICKLIST (Unrestrictive)":
            case "MULTIPICKLIST (Unrestrictive)":
                return 255;

            case "TEXTAREA (Long)":
            case "TEXT (Rich)":
                //return 131072;
                return 1000;

            case "PHONE":
                return 40;

            case "TEXT (Encrypted)":
                return 175;

            case "EMAIL":
                return 80;

            case "CURRENCY":
            case "NUMBER":
            case "PERCENT":
                return 18;

            default:
                return 1000;
        }
    }

    get showDataLengthValueForMasking() {
        return (
            this.currentRow.OQCT_DaCl__Data_Type_Name__c === "TEXT" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c === "TEXTAREA" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                "TEXTAREA (Long)" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                "TEXTAREA (Rich)" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                "TEXT (Encrypted)" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                "PICKLIST (Unrestrictive)" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                "MULTIPICKLIST (Unrestrictive)" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c === "CURRENCY" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c === "PHONE" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c === "NUMBER" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c === "PERCENT"
        );
    }

    get showCustomLengthValue() {
        return (
            this.isCustomLength &&
            (this.currentRow.OQCT_DaCl__Data_Type_Name__c === "TEXT" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c === "TEXTAREA" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                    "TEXTAREA (Long)" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                    "TEXTAREA (Rich)" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                    "TEXT (Encrypted)" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                    "PICKLIST (Unrestrictive)" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                    "MULTIPICKLIST (Unrestrictive)" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c === "PHONE" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c === "EMAIL" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c === "URL" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c === "CURRENCY" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c === "NUMBER" ||
                this.currentRow.OQCT_DaCl__Data_Type_Name__c === "PERCENT")
        );
    }

    get showMaskingPattern() {
        return (
            this.currentRow.OQCT_DaCl__Data_Type_Name__c === "TEXT" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c === "TEXTAREA" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                "TEXTAREA (Long)" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                "TEXTAREA (Rich)" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                "TEXT (Encrypted)" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                "PICKLIST (Unrestrictive)" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c ===
                "MULTIPICKLIST (Unrestrictive)"
        );
    }

    get showDomainValue() {
        return (
            this.currentRow.OQCT_DaCl__Data_Type_Name__c === "EMAIL" ||
            this.currentRow.OQCT_DaCl__Data_Type_Name__c === "URL"
        );
    }

    get showValueType() {
        return true;
    }

    @wire(getDatatable, {
        datatableRequestParamsString: "$datatableRequestParamsString"
    })
    getDatatable(result) {
        this.wiredResults = result;
        const { error, data } = result;
        if (data) {
            try {
                output("Response@getDatatable", data);
                this.dataCleanDataTypeColumns = processDatatableCoulumns(
                    data.datatableColumns
                );
                this.dataCleanDataTypeData = processDatatableData(
                    data.datatableData
                );
            } catch (error) {
                this.serverError = error;
            }
            this.spinners.full = false;
        } else if (error) {
            this.spinners.full = false;
            this.serverError = error;
        }
    }

    refreshData() {
        this.spinners.full = true;
        refreshApex(this.wiredResults)
            .then(() => (this.spinners.full = false))
            .catch(() => (this.spinners.full = false));
    }

    saveDataType(dcDataType) {
        this.spinners.dataTypeModal = true;
        saveDataType({
            dcDataType
        })
            .then((result) => {
                if (result.isSuccess) {
                    showToast("Success!", result.message, "success");
                } else {
                    showToast("Error!", result.errorMessage, "error");
                }
                this.spinners.dataTypeModal = false;
                this.closeEditDataTypeModal();
                this.refreshData();
            })
            .catch((error) => {
                this.serverError = error;
                this.spinners.dataTypeModal = false;
            });
    }

    initPropertiesForCurrentDataType() {
        if (this.currentRow.OQCT_DaCl__Match_Object_Field_Length__c) {
            this.dataLengthValueForMasking = "Match Object field Length";
            this.isCustomLength = false;
        } else if (
            this.currentRow.OQCT_DaCl__Match_Record_Original_Data_Length__c
        ) {
            this.dataLengthValueForMasking =
                "Match Record Original Data Length";
            this.isCustomLength = false;
        } else {
            this.dataLengthValueForMasking = "Enter Custom Length";
            this.isCustomLength = true;
        }
        this.customLengthValue = this.currentRow.OQCT_DaCl__Custom_Length__c;
        this.maskingPattern = this.currentRow.OQCT_DaCl__Text_Masking_Option__c;
        if (this.currentRow.OQCT_DaCl__Data_Type_Name__c === "EMAIL") {
            this.domainValue = this.currentRow.OQCT_DaCl__Email_Domain__c;
        }
        if (this.currentRow.OQCT_DaCl__Data_Type_Name__c === "URL") {
            this.domainValue = this.currentRow.OQCT_DaCl__URL_Domain__c;
        }
        this.valueType = this.currentRow.OQCT_DaCl__Value_Type__c;
    }

    openEditDataTypeModal() {
        this.template
            .querySelector('c-data-clean-modal[data-id="editDatatypeModal"]')
            .show();
    }

    closeEditDataTypeModal() {
        this.template
            .querySelector('c-data-clean-modal[data-id="editDatatypeModal"]')
            .hide();
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

    validateData() {
        let validity = {
            isValid: true,
            errorMessage: "Please resolve all errors"
        };
        validity.isValid =
            this.validateInputFields() &&
            this.validateRadioButtons() &&
            this.validateComboBox();
        if (!validity.isValid) {
            showToast("Error!", validity.errorMessage, "Error");
            return false;
        } else {
            return true;
        }
    }

    handleExportClick() {
        try {
            exportDatatable(
                this.dataCleanDataTypeColumns,
                this.dataCleanDataTypeData,
                CONSTANTS.EXPORT_FILE_NAME_DATA_TYPE
            );
        } catch (error) {
            this.serverError = error;
        }
    }

    handleRefreshClick() {
        this.refreshData();
    }

    handleRowActionDcDataType(event) {
        this.currentRow = event.detail.row;
        output("this.currentRow", this.currentRow);
        this.initPropertiesForCurrentDataType();
        this.openEditDataTypeModal();
    }

    handleNavigationLinkClick(event) {
        const { recordId, columnName, rowId } = event.detail;
        output("NavigationLinkClick Event DataParam-recordId", recordId);
        output("NavigationLinkClick Event DataParam-columnName", columnName);
        output("NavigationLinkClick Event DataParam-rowId", rowId);
    }

    handleCancelDatatype() {
        this.closeEditDataTypeModal();
    }

    handleSaveDatatype() {
        let dcDataType = { sobjectType: DC_DATA_TYPE_OBJECT.objectApiName };
        dcDataType.Id = this.currentRow.Id;
        switch (this.currentRow.OQCT_DaCl__Data_Type_Name__c) {
            case "TEXT":
            case "TEXTAREA":
            case "TEXTAREA (Long)":
            case "TEXTAREA (Rich)":
            case "TEXT (Encrypted)":
            case "PICKLIST (Unrestrictive)":
            case "MULTIPICKLIST (Unrestrictive)":
                if (
                    this.dataLengthValueForMasking ===
                    "Match Record Original Data Length"
                ) {
                    dcDataType.OQCT_DaCl__Match_Object_Field_Length__c = false;
                    dcDataType.OQCT_DaCl__Match_Record_Original_Data_Length__c = true;
                    dcDataType.OQCT_DaCl__Custom_Length__c = null;
                } else if (
                    this.dataLengthValueForMasking ===
                    "Match Object field Length"
                ) {
                    dcDataType.OQCT_DaCl__Match_Object_Field_Length__c = true;
                    dcDataType.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
                    dcDataType.OQCT_DaCl__Custom_Length__c = null;
                } else {
                    dcDataType.OQCT_DaCl__Match_Object_Field_Length__c = false;
                    dcDataType.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
                    dcDataType.OQCT_DaCl__Custom_Length__c = this.customLengthValue;
                }
                dcDataType.OQCT_DaCl__Text_Masking_Option__c = this.maskingPattern;
                break;

            case "PHONE":
            case "NUMBER":
            case "PERCENT":
            case "CURRENCY":
                if (
                    this.dataLengthValueForMasking ===
                    "Match Record Original Data Length"
                ) {
                    dcDataType.OQCT_DaCl__Match_Object_Field_Length__c = false;
                    dcDataType.OQCT_DaCl__Match_Record_Original_Data_Length__c = true;
                    dcDataType.OQCT_DaCl__Custom_Length__c = null;
                } else if (
                    this.dataLengthValueForMasking ===
                    "Match Object field Length"
                ) {
                    dcDataType.OQCT_DaCl__Match_Object_Field_Length__c = true;
                    dcDataType.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
                    dcDataType.OQCT_DaCl__Custom_Length__c = null;
                } else {
                    dcDataType.OQCT_DaCl__Match_Object_Field_Length__c = false;
                    dcDataType.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
                    dcDataType.OQCT_DaCl__Custom_Length__c = this.customLengthValue;
                }
                break;

            case "DATE":
            case "DATE TIME":
            case "TIME":
            case "BOOLEAN (Checkbox)":
            case "LOCATION (Latitude)":
            case "LOCATION (Longitude)":
            case "PICKLIST (Restrictive)":
            case "MULTIPICKLIST (Restrictive)":
                dcDataType.OQCT_DaCl__Value_Type__c = this.valueType;
                break;

            case "EMAIL":
                dcDataType.OQCT_DaCl__Email_Domain__c = this.domainValue;
                dcDataType.OQCT_DaCl__Custom_Length__c = this.customLengthValue;
                break;

            case "URL":
                dcDataType.OQCT_DaCl__URL_Domain__c = this.domainValue;
                dcDataType.OQCT_DaCl__Custom_Length__c = this.customLengthValue;
                break;

            default:
                break;
        }
        output("dcDataType", dcDataType);
        const isValid = this.validateData();
        if (isValid) {
            this.saveDataType(dcDataType);
        }
    }

    handleChange(event) {
        const name = event.currentTarget.name;
        const value = event.currentTarget.value;
        switch (name) {
            case "dataLengthValueForMasking":
                this.dataLengthValueForMasking = value;
                if (this.dataLengthValueForMasking === "Enter Custom Length") {
                    this.isCustomLength = true;
                } else {
                    this.isCustomLength = false;
                }
                break;

            case "customLengthValue":
                this.customLengthValue = value;
                break;

            case "maskingPattern":
                this.maskingPattern = value;
                break;

            case "valueType":
                this.valueType = value;
                break;

            case "domainValue":
                this.domainValue = value;
                break;

            default:
                break;
        }
    }
}