import { ShowToastEvent } from "lightning/platformShowToastEvent";

import TIME_ZONE from "@salesforce/i18n/timeZone";
import LOCALE from "@salesforce/i18n/locale";

// DC_Configuration__c Object and Fields
import DC_CONFIGURATION_OBJECT from "@salesforce/schema/DC_Configuration__c";
import DC_CONFIGURATION_Id_FIELD from "@salesforce/schema/DC_Configuration__c.Id";
import DC_CONFIGURATION_NAME_FIELD from "@salesforce/schema/DC_Configuration__c.Name";
import DC_CONFIGURATION_IS_CONFIGURATION_ACTIVE_FIELD from "@salesforce/schema/DC_Configuration__c.Is_Configuration_Active__c";
import DC_CONFIGURATION_DISABLE_ROLLBACK_BUTTON_FIELD from "@salesforce/schema/DC_Configuration__c.Disable_Rollback_Button__c";

// Data_Clean__c Object  and Fields
import DATA_CLEAN_OBJECT from "@salesforce/schema/Data_Clean__c";
import DATA_CLEAN_NAME_FIELD from "@salesforce/schema/Data_Clean__c.Name";
import DATA_CLEAN_DC_CONFIGURATION_FIELD from "@salesforce/schema/Data_Clean__c.DC_Configuration__c";
import DATA_CLEAN_DISABLE_ROLLBACK_BUTTON_FIELD from "@salesforce/schema/Data_Clean__c.Disable_Rollback_Button__c";

// DC_Result__c Object  and Fields
import DC_RESULT_OBJECT from "@salesforce/schema/DC_Result__c";
import DC_RESULT_NAME_FIELD from "@salesforce/schema/DC_Result__c.Name";
import DC_RESULT_DC_CONFIGURATION_FIELD from "@salesforce/schema/DC_Result__c.DC_Configuration__c";
import DC_RESULT_DISABLE_ROLLBACK_BUTTON_FIELD from "@salesforce/schema/DC_Result__c.Disable_Rollback_Button__c";

// DC_Data_Type__c Object and Fields
import DC_DATA_TYPE_OBJECT from "@salesforce/schema/DC_Data_Type__c";
import DC_DATA_TYPE_DATA_TYPE_NAME_FIELD from "@salesforce/schema/DC_Data_Type__c.Data_Type_Name__c";

// ContentVersion Object and Fields
import CONTENT_VERSION_OBJECT from "@salesforce/schema/ContentVersion";
import CONTENT_VERSION_FIRST_PUBLISH_LOCATION_ID_FIELD from "@salesforce/schema/ContentVersion.FirstPublishLocationId";
import CONTENT_VERSION_TITLE_FIELD from "@salesforce/schema/ContentVersion.Title";
import CONTENT_VERSION_FILE_TYPE_FIELD from "@salesforce/schema/ContentVersion.FileType";
import CONTENT_VERSION_CONTENT_SIZE_FIELD from "@salesforce/schema/ContentVersion.ContentSize";
import CONTENT_VERSION_LAST_MODIFIED_DATE_FIELD from "@salesforce/schema/ContentVersion.LastModifiedDate";

// CronTrigger Object and Fields
import CRONTRIGGER_OBJECT from "@salesforce/schema/CronTrigger";
import CRONTRIGGER_STATE_FIELD from "@salesforce/schema/CronTrigger.State";
import CRONTRIGGER_ENDTIME_FIELD from "@salesforce/schema/CronTrigger.EndTime";
import CRONTRIGGER_STARTTIME_FIELD from "@salesforce/schema/CronTrigger.StartTime";
import CRONTRIGGER_PREVIOUSFIRETIME_FIELD from "@salesforce/schema/CronTrigger.PreviousFireTime";
import CRONTRIGGER_NEXTFIRETIME_FIELD from "@salesforce/schema/CronTrigger.NextFireTime";
import CRONTRIGGER_TIMESTRIGGERED_FIELD from "@salesforce/schema/CronTrigger.TimesTriggered";

// CronDetail Object and Fields
import CRONJOBDETAIL_OBJECT from "@salesforce/schema/CronJobDetail";
import CRONJOBDETAIL_NAME_FIELD from "@salesforce/schema/CronJobDetail.Name";

// Todo: Custom Labels

const NO_DATA_MESSAGE = "No Records Found";
const QUERY_LIMIT = 50;
const QUERY_LIMIT_HOME = 5;
const DEFAULT_RECORDS_PER_PAGE = 10;
const SORT_ASC = "ASC";
const SORT_DESC = "DESC";

const FIELD_SET = {
    DC_CONFIG_ALL: "OQCT_DaCl__DC_Configuration_All",
    DC_CONFIG_CLEANUP: "OQCT_DaCl__DC_Configuration_Cleanup",
    DC_CONFIG_ROLLBACK: "OQCT_DaCl__DC_Configuration_Rollback",
    DATA_CLEAN_ALL: "OQCT_DaCl__Data_Clean_All",
    DATA_CLEAN_ROLLBACK: "OQCT_DaCl__Data_Clean_Rollback",
    DC_RESULT_ALL: "OQCT_DaCl__DC_Results_All",
    DC_RESULT_CLEANUP: "OQCT_DaCl__DC_Results_Cleanup",
    DC_RESULT_ROLLBACK: "OQCT_DaCl__DC_Results_Rollback",
    DC_DATA_TYPE_ALL: "OQCT_DaCl__DC_DataType_All"
};

const LEVEL = {
    DATA_CLEAN_CONFIGURATIONS: "Data Clean Configurations",
    DATA_CLEANS: "Data Cleans",
    DATA_CLEAN_RESULTS: "Data Clean Results",
    DATA_CLEAN_FILES: "Data Clean Files"
};

const EXPORT_FILE_NAME = {
    JOB_STATUS: "Data Clean Job Status",
    DC_CONFIG: "Data Clean Configurations",
    DC_CONFIG_ROLLBACK: "Data Clean Configuration Rollbacks",
    DATA_CLEAN: "Data Cleans",
    DATA_CLEAN_ROLLBACK: "Data Clean Rollbacks",
    DATA_TYPE: "Data Clean Data Types",
    DATA_CLEAN_REPORT: "Data Clean Reports",
    DATA_CLEAN_RESULT: "Data Clean Results",
    DATA_CLEAN_RESULT_ROLLBACK: "Data Clean Result Rollbacks",
    DATA_CLEAN_FILE: "Data Clean Files"
};

const showToast = (title, message, variant = "info", mode = "dismissable") => {
    const event = new ShowToastEvent({
        title,
        message,
        variant,
        mode
    });
    dispatchEvent(event);
};

const sortOptionsByLabel = (optionList) => {
    optionList.sort((a, b) =>
        a.label > b.label ? 1 : b.label > a.label ? -1 : 0
    );
};

const getMapFromObjectArray = (arr) => {
    let result = arr.reduce((map, obj) => {
        map[obj.key] = obj.val;
        return map;
    }, {});
    return result;
};

const processDatatableCoulumns = (datatableColumns) => {
    let processedDatatableColumns = datatableColumns.map((col) => ({
        ...col
    }));
    for (let index = 0; index < processedDatatableColumns.length; index++) {
        transformCellAttribute(processedDatatableColumns[index]);
    }
    return processedDatatableColumns;
};

const processDatatableData = (datatableData) => {
    let processedDatatableData = datatableData.map((data) => ({
        ...data
    }));
    for (let index = 0; index < processedDatatableData.length; index++) {
        transformRelationships(processedDatatableData[index]);
    }
    return processedDatatableData;
};

const transformCellAttribute = (col) => {
    if ("cellAttributes" in col) {
        if ("className" in col.cellAttributes) {
            col.cellAttributes = Object.assign({}, col.cellAttributes);
            col.cellAttributes.class = col.cellAttributes.className;
            delete col.cellAttributes.className;
        }
    }
};

const transformRelationships = (sObj) => {
    for (var field in sObj) {
        switch (typeof sObj[field]) {
            case "object":
                for (var relField in sObj[field]) {
                    sObj[field + "." + relField] = sObj[field][relField];
                }
            default:
                break;
        }
    }
};

const getFilterWhereCondition = (filters) => {
    if (!filters || filters.length === 0) {
        return "";
    }
    let conditions = [];
    filters.forEach((filter) => {
        switch (filter.type) {
            case "boolean":
                if (!filter.value) {
                    filter.value = false;
                }
                conditions.push(
                    `(${filter.field} ${filter.operator} ${filter.value})`
                );
                break;

            case "currency":
            case "percent":
            case "number":
            case "date":
            case "time":
                if (!filter.value) {
                    filter.value = null;
                }
                conditions.push(
                    `(${filter.field} ${filter.operator} ${filter.value})`
                );
                break;

            case "date-time":
                if (!filter.value) {
                    filter.value = null;
                }
                if (filter.operator === "=" && filter.value !== null) {
                    let d1 =
                        filter.value.substr(0, filter.value.lastIndexOf(":")) +
                        ":00.000Z";
                    let d2 =
                        filter.value.substr(0, filter.value.lastIndexOf(":")) +
                        ":59.999Z";
                    conditions.push(
                        `(${filter.field} >= ${d1} AND ${filter.field} <= ${d2})`
                    );
                } else if (filter.operator === "!=" && filter.value !== null) {
                    let d1 =
                        filter.value.substr(0, filter.value.lastIndexOf(":")) +
                        ":00.000Z";
                    let d2 =
                        filter.value.substr(0, filter.value.lastIndexOf(":")) +
                        ":59.999Z";
                    conditions.push(
                        `(${filter.field} < ${d1} AND ${filter.field} > ${d2})`
                    );
                } else {
                    conditions.push(
                        `(${filter.field} ${filter.operator} ${filter.value})`
                    );
                }
                break;

            case "email":
            case "phone":
            case "text":
            case "url":
            case "navigation":
                if (!filter.value) {
                    filter.value = "";
                }
                switch (filter.operator) {
                    case "contains":
                        conditions.push(
                            `(${filter.field} LIKE '%${filter.value}%')`
                        );
                        break;

                    case "does not contain":
                        conditions.push(
                            `NOT (${filter.field} LIKE '%${filter.value}%')`
                        );
                        break;

                    case "starts with":
                        conditions.push(
                            `(${filter.field} LIKE '${filter.value}%')`
                        );
                        break;

                    case "ends with":
                        conditions.push(
                            `(${filter.field} LIKE '%${filter.value}')`
                        );
                        break;

                    default:
                        conditions.push(
                            `(${filter.field} ${filter.operator} '${filter.value}')`
                        );
                        break;
                }
                break;

            default:
                if (!filter.value) {
                    filter.value = null;
                }
                conditions.push(
                    `(${filter.field} ${filter.operator} ${filter.value})`
                );
                break;
        }
    });
    let filterWhereCondition = conditions.join(" AND ");
    return filterWhereCondition;
};

const exportDatatable = (columns, data, fileName) => {
    let rowEnd;
    if (isWindows) {
        rowEnd = "\r\n";
    } else {
        rowEnd = "\n";
    }
    let csvString = "";

    columns = columns.filter((column) => {
        return isColumnField(column);
    });

    // this set elminates the duplicates if have any duplicate keys
    let headerRow = [];

    columns.forEach((column) => {
        if (column.fieldName) {
            headerRow.push(column.label);
        }
    });

    // Preparing first row: header row
    csvString += headerRow.join(",");
    csvString += rowEnd;

    // main for loop to get the data for one row
    data.forEach((dataRow) => {
        let colNum = 0;
        // loop for each column
        columns.forEach((column) => {
            // add , after every value except the first.
            if (colNum > 0) {
                csvString += ",";
            }
            // If the column is undefined, it as blank in the CSV file.
            let value =
                dataRow[column.fieldName] === undefined
                    ? ""
                    : dataRow[column.fieldName];
            if (isTimeColumn(column)) {
                value = getTimeFormatted(value);
            }
            csvString += '"' + value + '"';
            colNum++;
        });
        csvString += rowEnd;
    });

    // Remove rowEnd from csv end
    csvString = csvString.slice(0, -1);

    // Creating anchor element to download
    let downloadElement = document.createElement("a");

    // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
    downloadElement.href =
        "data:text/csv;charset=utf-8," + encodeURI(csvString);
    downloadElement.target = "_self";
    // hide download element
    downloadElement.style = "visibility:hidden";
    // CSV File Name
    downloadElement.download = fileName ? fileName + ".csv" : "Download.csv";
    // below statement is required if you are using firefox browser
    document.body.appendChild(downloadElement);
    // click() Javascript function to download CSV file
    downloadElement.click();
    // remove anchor element
    document.body.removeChild(downloadElement);
};

const isColumnField = (column) => {
    if (column.fieldName.includes("_") && !column.fieldName.includes("__")) {
        return false;
    }
    switch (column.type) {
        case "boolean":
        case "currency":
        case "percent":
        case "number":
        case "date":
        case "date-local":
        case "email":
        case "phone":
        case "text":
        case "url":
        case "toggleButton":
            return true;

        case "navigation":
            if (!column.typeAttributes.showAsAnIcon) {
                return true;
            } else {
                return false;
            }

        default:
            return false;
    }
};

const isDateColumn = (column) => {
    return (
        (column.type === "date" || column.type === "date-local") &&
        column.typeAttributes &&
        column.typeAttributes.day !== undefined &&
        column.typeAttributes.month !== undefined &&
        column.typeAttributes.year !== undefined &&
        column.typeAttributes.hour === undefined &&
        column.typeAttributes.minute === undefined
    );
};

const isDateTimeColumn = (column) => {
    return (
        column.type === "date" &&
        column.typeAttributes &&
        column.typeAttributes.day !== undefined &&
        column.typeAttributes.month !== undefined &&
        column.typeAttributes.year !== undefined &&
        column.typeAttributes.hour !== undefined &&
        column.typeAttributes.minute !== undefined
    );
};

const isTimeColumn = (column) => {
    return (
        column.type === "date" &&
        column.typeAttributes &&
        column.typeAttributes.day === undefined &&
        column.typeAttributes.month === undefined &&
        column.typeAttributes.year === undefined &&
        column.typeAttributes.hour !== undefined &&
        column.typeAttributes.minute !== undefined
    );
};

const isWindows = () => {
    return navigator.platform.indexOf("Win") > -1;
};

const getTimeFormatted = (unixTimeStamp) => {
    if (!unixTimeStamp && unixTimeStamp !== 0) {
        return "";
    }
    // Create a new JavaScript Date object based on the timestamp
    let date = new Date(unixTimeStamp);
    // Convert date into user's timezone
    date = getDateInUserLocalTimeZone(date);
    // Hours part from the timestamp
    let hours = date.getHours();
    // Minutes part from the timestamp
    let minutes = "0" + date.getMinutes();
    // Seconds part from the timestamp
    let seconds = "0" + date.getSeconds();

    // Will display time in 10:30:23 format
    return hours + ":" + minutes.substr(-2) + ":" + seconds.substr(-2);
};

const shiftDate = (shiftBy, unit, date) => {
    let shiftByNum;
    if (typeof shiftBy === "string" || shiftBy instanceof String) {
        shiftByNum = parseFloat(shiftBy.trim());
    } else {
        shiftByNum = shiftBy;
    }
    let dateToShift;
    if (date) {
        dateToShift = date;
    } else {
        dateToShift = new Date();
    }
    //dateToShift = getDateInUserLocalTimeZone(dateToShift);
    let shiftedDate;
    if (unit === "Day(s)") {
        dateToShift.setDate(dateToShift.getDate() + shiftByNum);
        shiftedDate = dateToShift;
    } else if (unit === "Minute(s)") {
        dateToShift.setMinutes(dateToShift.getMinutes() + shiftByNum);
        shiftedDate = dateToShift;
    } else if (unit === "Hour(s)") {
        dateToShift.setHours(dateToShift.getHours() + shiftByNum);
        shiftedDate = dateToShift;
    } else if (unit === "Month(s)") {
        dateToShift.setMonth(dateToShift.getMonth() + shiftByNum);
        shiftedDate = dateToShift;
    } else if (unit === "Year(s)") {
        dateToShift.setFullYear(dateToShift.getFullYear() + shiftByNum);
        shiftedDate = dateToShift;
    } else {
        shiftedDate = dateToShift;
    }
    shiftedDate.setMilliseconds(0);
    shiftedDate.setSeconds(0);
    return shiftedDate;
};

const getDateAsString = (date) => {
    date = getDateInUserLocalTimeZone(date);
    let dateString = JSON.stringify(date);
    dateString = dateString.substring(0, dateString.lastIndexOf(":"));
    dateString = dateString.replace("T", " ");
    dateString = dateString.replaceAll('"', "");
    return dateString;
};

const getDateAsStringFormatted = (date) => {
    let dateString = date.toLocaleString(LOCALE, {
        timeZone: TIME_ZONE
    });
    return dateString.substring(0, dateString.lastIndexOf(":"));
};

const getDateInUserLocalTimeZone = (date) => {
    let dateStringInUserTimeZone = date.toLocaleString("en-US", {
        timeZone: TIME_ZONE
    });
    return new Date(Date.parse(dateStringInUserTimeZone));
};

const validateEmail = (email) => {
    let reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
    if (reg.test(email) == false) {
        return false;
    }
    return true;
};

const output = (label, value) => {
    if (value === undefined) {
        console.log(`${label}`);
    } else {
        if (value !== Object(value)) {
            console.log(`${label}: `, value);
        } else {
            console.log(`${label}: `, JSON.parse(JSON.stringify(value)));
        }
    }
};

const dataCleanConfiguationCreateEditComponentConstants = {
    FIRST_STEP: "step1",
    FINAL_STEP: "step7",
    STEP_PREFIX: "step",
    UNIT_OPTIONS: [
        { value: "Minute(s)", label: "Minute(s)" },
        { value: "Hour(s)", label: "Hour(s)" },
        { value: "Day(s)", label: "Day(s)" },
        { value: "Month(s)", label: "Month(s)" },
        { value: "Year(s)", label: "Year(s)" }
    ],
    ACTION_OPTIONS: [
        { label: "Masking Only", value: "Masking Only" },
        { label: "Masking + Deletion", value: "Masking + Deletion" },
        { label: "Masking + Rollback", value: "Masking + Rollback" },
        {
            label: "Masking + Rollback + Deletion",
            value: "Masking + Rollback + Deletion"
        },
        { label: "Deletion Only", value: "Deletion Only" },
        { label: "Deletion + Rollback", value: "Deletion + Rollback" },
        { label: "Archive + Deletion", value: "Archive + Deletion" },
        { label: "Archive + Rollback", value: "Archive + Rollback" }
    ],

    LABLES: {}
};

const dataCleanHomeComponentConstants = {
    LIMIT_HOME: QUERY_LIMIT_HOME,

    LABLES: {}
};

const dataCleanSearchableLightningDualListboxComponentConstants = {
    DEFAULT_INPUT_LABEL: " ",
    DEFAULT_INPUT_PLACEHOLDER: "Search...",
    DEFAULT_DUAL_LISTBOX_LABEL: "Select Options",
    DEFAULT_DUAL_LISTBOX_SOURCE_LABEL: "",
    DEFAULT_DUAL_LISTBOX_SELECTED_LABEL: "",
    DEFAULT_DUAL_LISTBOX_SIZE: 10,

    LABLES: {}
};

const dataCleanToggleButtonComponentConstants = {
    DEFAULT_TOGGLE_ON_TEXT: "Selected",
    DEFAULT_TOGGLE_OFF_TEXT: "Not Selected",
    TOGGLE_DISABLED_TEXT: "Disabled",

    LABLES: {}
};

const dataCleanNavigationComponentConstants = {
    TYPE_CUSTOM_RAISE_EVENT: "custom__raiseEvent",
    TYPE_STANDARD_RECORD_PAGE: "standard__recordPage",
    ACTION_DEFAULT: "view",
    EVENT_NAVIGATION_LINK_CLICK: "navigationlinkclick",

    LABLES: {}
};

const dataCleanJobStatusComponentConstants = {
    DATA_TABLE_REQUEST_PARAMS_JOB_STATUS_HOME: {
        objectName: CRONTRIGGER_OBJECT.objectApiName,
        fieldSetName: null,
        fieldApiNames: [
            CRONJOBDETAIL_OBJECT.objectApiName +
                "." +
                CRONJOBDETAIL_NAME_FIELD.fieldApiName,
            CRONTRIGGER_STATE_FIELD.fieldApiName,
            CRONTRIGGER_ENDTIME_FIELD.fieldApiName,
            CRONTRIGGER_STARTTIME_FIELD.fieldApiName,
            CRONTRIGGER_PREVIOUSFIRETIME_FIELD.fieldApiName,
            CRONTRIGGER_NEXTFIRETIME_FIELD.fieldApiName,
            //"OwnerId",
            CRONTRIGGER_TIMESTRIGGERED_FIELD.fieldApiName
        ],
        additionalFields: null,
        whereClauseCondition:
            "(CronJobDetail.Name LIKE 'DC-Config-%' AND State NOT IN ('COMPLETE', 'DELETED') AND CronJobDetail.JobType = '7')",
        sortField: CRONTRIGGER_NEXTFIRETIME_FIELD.fieldApiName,
        sortDirection: SORT_ASC,
        recordLimit: QUERY_LIMIT_HOME,
        offset: null
    },

    DATA_TABLE_REQUEST_PARAMS_JOB_STATUS: {
        objectName: CRONTRIGGER_OBJECT.objectApiName,
        fieldSetName: null,
        fieldApiNames: [
            CRONJOBDETAIL_OBJECT.objectApiName +
                "." +
                CRONJOBDETAIL_NAME_FIELD.fieldApiName,
            CRONTRIGGER_STATE_FIELD.fieldApiName,
            CRONTRIGGER_ENDTIME_FIELD.fieldApiName,
            CRONTRIGGER_STARTTIME_FIELD.fieldApiName,
            CRONTRIGGER_PREVIOUSFIRETIME_FIELD.fieldApiName,
            CRONTRIGGER_NEXTFIRETIME_FIELD.fieldApiName,
            //"OwnerId",
            CRONTRIGGER_TIMESTRIGGERED_FIELD.fieldApiName
        ],
        additionalFields: null,
        whereClauseCondition:
            "(CronJobDetail.Name LIKE 'DC-Config-%' AND State NOT IN ('COMPLETE', 'DELETED') AND CronJobDetail.JobType = '7')",
        sortField: CRONTRIGGER_NEXTFIRETIME_FIELD.fieldApiName,
        sortDirection: SORT_ASC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    EXPORT_FILE_NAME_JOB_STATUS: EXPORT_FILE_NAME.JOB_STATUS,

    DC_CONFIGURATION_FIELD_API_NAME: "DC_Configuration",
    DC_CONFIGURATION_FIELD_LABEL: "DC-Configuration",

    ACTION_FIELD_API_NAME: "Action__c",
    ACTION_FIELD_LABEL: "Action",

    JOB_NAME_FIELD_API_NAME:
        CRONJOBDETAIL_OBJECT.objectApiName +
        "." +
        CRONJOBDETAIL_NAME_FIELD.fieldApiName,

    RECORDS_PER_PAGE: DEFAULT_RECORDS_PER_PAGE,
    NO_DATA_MESSAGE: NO_DATA_MESSAGE,

    LABLES: {}
};

const dataCleanConfigurationsComponentConstants = {
    DATA_TABLE_REQUEST_PARAMS_DC_CONFIG: {
        objectName: DC_CONFIGURATION_OBJECT.objectApiName,
        fieldSetName: FIELD_SET.DC_CONFIG_ALL,
        fieldApiNames: null,
        additionalFields: [
            DC_CONFIGURATION_IS_CONFIGURATION_ACTIVE_FIELD.fieldApiName
        ],
        whereClauseCondition: null,
        sortField: DC_CONFIGURATION_NAME_FIELD.fieldApiName,
        sortDirection: SORT_DESC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    DATA_TABLE_REQUEST_PARAMS_DATA_CLEAN: {
        objectName: DATA_CLEAN_OBJECT.objectApiName,
        fieldSetName: FIELD_SET.DATA_CLEAN_ALL,
        fieldApiNames: null,
        additionalFields: null,
        nameFieldToStandardPage: true,
        whereClauseCondition: `${DATA_CLEAN_DC_CONFIGURATION_FIELD.fieldApiName} = `,
        sortField: DATA_CLEAN_NAME_FIELD.fieldApiName,
        sortDirection: SORT_ASC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    EXPORT_FILE_NAME_DC_CONFIG: EXPORT_FILE_NAME.DC_CONFIG,
    EXPORT_FILE_NAME_DATA_CLEAN: EXPORT_FILE_NAME.DATA_CLEAN,

    DATA_CLEAN_CONFIGURATIONS: LEVEL.DATA_CLEAN_CONFIGURATIONS,
    DATA_CLEANS: LEVEL.DATA_CLEANS,

    RECORDS_PER_PAGE: DEFAULT_RECORDS_PER_PAGE,
    NO_DATA_MESSAGE: NO_DATA_MESSAGE,

    LABLES: {}
};

const dataCleanDataTypeComponentConstants = {
    DATA_TABLE_REQUEST_PARAMS_DC_DATA_TYPE: {
        objectName: DC_DATA_TYPE_OBJECT.objectApiName,
        fieldSetName: FIELD_SET.DC_DATA_TYPE_ALL,
        fieldApiNames: null,
        additionalFields: null,
        whereClauseCondition: null,
        sortField: DC_DATA_TYPE_DATA_TYPE_NAME_FIELD.fieldApiName,
        sortDirection: SORT_ASC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    EXPORT_FILE_NAME_DATA_TYPE: EXPORT_FILE_NAME.DATA_TYPE,

    NO_DATA_MESSAGE: NO_DATA_MESSAGE,

    LABLES: {}
};

const dataCleanReportsComponentConstants = {
    DATA_TABLE_REQUEST_PARAMS_DC_REPORT: {
        objectName: DC_RESULT_OBJECT.objectApiName,
        fieldSetName: FIELD_SET.DC_RESULT_ALL,
        fieldApiNames: null,
        additionalFields: null,
        whereClauseCondition: null,
        sortField: DC_RESULT_NAME_FIELD.fieldApiName,
        sortDirection: SORT_DESC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    DATA_TABLE_REQUEST_PARAMS_DATA_CLEAN_FILE: {
        objectName: CONTENT_VERSION_OBJECT.objectApiName,
        fieldSetName: null,
        fieldApiNames: [
            CONTENT_VERSION_TITLE_FIELD.fieldApiName,
            CONTENT_VERSION_FILE_TYPE_FIELD.fieldApiName,
            CONTENT_VERSION_CONTENT_SIZE_FIELD.fieldApiName,
            CONTENT_VERSION_LAST_MODIFIED_DATE_FIELD.fieldApiName
        ],
        additionalFields: null,
        nameFieldToStandardPage: true,
        whereClauseCondition: `(NOT PathOnClient LIKE '%Backup-%') AND ${CONTENT_VERSION_FIRST_PUBLISH_LOCATION_ID_FIELD.fieldApiName} = `,
        sortField: CONTENT_VERSION_TITLE_FIELD.fieldApiName,
        sortDirection: SORT_ASC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    EXPORT_FILE_NAME_DATA_CLEAN_REPORT: EXPORT_FILE_NAME.DATA_CLEAN_REPORT,
    EXPORT_FILE_NAME_DATA_CLEAN_FILE: EXPORT_FILE_NAME.DATA_CLEAN_FILE,

    DATA_CLEAN_RESULTS: LEVEL.DATA_CLEAN_RESULTS,
    DATA_CLEAN_FILES: LEVEL.DATA_CLEAN_FILES,

    RECORDS_PER_PAGE: DEFAULT_RECORDS_PER_PAGE,
    NO_DATA_MESSAGE: NO_DATA_MESSAGE,

    LABLES: {}
};

const dataCleanCleanupComponentConstants = {
    DATA_TABLE_REQUEST_PARAMS_DC_CONFIG: {
        objectName: DC_CONFIGURATION_OBJECT.objectApiName,
        fieldSetName: FIELD_SET.DC_CONFIG_CLEANUP,
        fieldApiNames: null,
        additionalFields: null,
        whereClauseCondition: null,
        sortField: DC_CONFIGURATION_NAME_FIELD.fieldApiName,
        sortDirection: SORT_DESC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    DATA_TABLE_REQUEST_PARAMS_DC_RESULT: {
        objectName: DC_RESULT_OBJECT.objectApiName,
        fieldSetName: FIELD_SET.DC_RESULT_CLEANUP,
        fieldApiNames: null,
        additionalFields: null,
        whereClauseCondition: `${DC_RESULT_DC_CONFIGURATION_FIELD.fieldApiName} = `,
        sortField: DC_RESULT_NAME_FIELD.fieldApiName,
        sortDirection: SORT_DESC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    DATA_TABLE_REQUEST_PARAMS_DATA_CLEAN_FILE: {
        objectName: CONTENT_VERSION_OBJECT.objectApiName,
        fieldSetName: null,
        fieldApiNames: [
            CONTENT_VERSION_TITLE_FIELD.fieldApiName,
            CONTENT_VERSION_FILE_TYPE_FIELD.fieldApiName,
            CONTENT_VERSION_CONTENT_SIZE_FIELD.fieldApiName,
            CONTENT_VERSION_LAST_MODIFIED_DATE_FIELD.fieldApiName
        ],
        additionalFields: null,
        nameFieldToStandardPage: true,
        whereClauseCondition: `${CONTENT_VERSION_FIRST_PUBLISH_LOCATION_ID_FIELD.fieldApiName} = `,
        sortField: CONTENT_VERSION_TITLE_FIELD.fieldApiName,
        sortDirection: SORT_ASC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    EXPORT_FILE_NAME_DC_CONFIG: EXPORT_FILE_NAME.DC_CONFIG,
    EXPORT_FILE_NAME_DATA_CLEAN_RESULT: EXPORT_FILE_NAME.DATA_CLEAN_RESULT,
    EXPORT_FILE_NAME_DATA_CLEAN_FILE: EXPORT_FILE_NAME.DATA_CLEAN_FILE,

    DATA_CLEAN_CONFIGURATIONS: LEVEL.DATA_CLEAN_CONFIGURATIONS,
    DATA_CLEAN_RESULTS: LEVEL.DATA_CLEAN_RESULTS,
    DATA_CLEAN_FILES: LEVEL.DATA_CLEAN_FILES,

    RECORDS_PER_PAGE: DEFAULT_RECORDS_PER_PAGE,
    NO_DATA_MESSAGE: NO_DATA_MESSAGE,

    LABLES: {}
};

const dataCleanRollbackComponentConstants = {
    DATA_TABLE_REQUEST_PARAMS_DC_CONFIG: {
        objectName: DC_CONFIGURATION_OBJECT.objectApiName,
        fieldSetName: FIELD_SET.DC_CONFIG_ROLLBACK,
        fieldApiNames: null,
        additionalFields: [
            DC_CONFIGURATION_DISABLE_ROLLBACK_BUTTON_FIELD.fieldApiName
        ],
        whereClauseCondition: `NOT OQCT_DaCl__Overall_Rollback_Status__c LIKE '%Success'`,
        sortField: DC_CONFIGURATION_NAME_FIELD.fieldApiName,
        sortDirection: SORT_DESC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    DATA_TABLE_REQUEST_PARAMS_DC_RESULT: {
        objectName: DC_RESULT_OBJECT.objectApiName,
        fieldSetName: FIELD_SET.DC_RESULT_ROLLBACK,
        fieldApiNames: null,
        additionalFields: [
            DC_RESULT_DISABLE_ROLLBACK_BUTTON_FIELD.fieldApiName
        ],
        nameFieldToStandardPage: true,
        whereClauseCondition: `(NOT OQCT_DaCl__DC_Configuration__r.OQCT_DaCl__Overall_Rollback_Status__c LIKE '%Success') AND ${DC_RESULT_DC_CONFIGURATION_FIELD.fieldApiName} = `,
        sortField: DC_RESULT_NAME_FIELD.fieldApiName,
        sortDirection: SORT_DESC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    DATA_TABLE_REQUEST_PARAMS_DATA_CLEAN: {
        objectName: DATA_CLEAN_OBJECT.objectApiName,
        fieldSetName: FIELD_SET.DATA_CLEAN_ROLLBACK,
        fieldApiNames: null,
        additionalFields: [
            DATA_CLEAN_DISABLE_ROLLBACK_BUTTON_FIELD.fieldApiName
        ],
        nameFieldToStandardPage: true,
        whereClauseCondition: `(NOT OQCT_DaCl__Overall_Rollback_Status__c LIKE '%Success') AND ${DATA_CLEAN_DC_CONFIGURATION_FIELD.fieldApiName} = `,
        sortField: DATA_CLEAN_NAME_FIELD.fieldApiName,
        sortDirection: SORT_ASC,
        recordLimit: QUERY_LIMIT,
        offset: null
    },

    EXPORT_FILE_NAME_DC_CONFIG: EXPORT_FILE_NAME.DC_CONFIG_ROLLBACK,
    EXPORT_FILE_NAME_DATA_CLEAN_RESULT:
        EXPORT_FILE_NAME.DATA_CLEAN_RESULT_ROLLBACK,
    EXPORT_FILE_NAME_DATA_CLEAN: EXPORT_FILE_NAME.DATA_CLEAN_ROLLBACK,

    DATA_CLEAN_CONFIGURATIONS: LEVEL.DATA_CLEAN_CONFIGURATIONS,
    DATA_CLEAN_RESULTS: LEVEL.DATA_CLEAN_RESULTS,
    DATA_CLEANS: LEVEL.DATA_CLEANS,

    RECORDS_PER_PAGE: DEFAULT_RECORDS_PER_PAGE,
    NO_DATA_MESSAGE: NO_DATA_MESSAGE,

    LABLES: {}
};

export {
    output,
    showToast,
    sortOptionsByLabel,
    getMapFromObjectArray,
    processDatatableCoulumns,
    processDatatableData,
    exportDatatable,
    shiftDate,
    getDateAsStringFormatted,
    validateEmail,
    getFilterWhereCondition,
    isColumnField,
    isDateColumn,
    isDateTimeColumn,
    isTimeColumn,
    TIME_ZONE,
    dataCleanHomeComponentConstants,
    dataCleanSearchableLightningDualListboxComponentConstants,
    dataCleanToggleButtonComponentConstants,
    dataCleanConfiguationCreateEditComponentConstants,
    dataCleanNavigationComponentConstants,
    dataCleanJobStatusComponentConstants,
    dataCleanConfigurationsComponentConstants,
    dataCleanDataTypeComponentConstants,
    dataCleanRollbackComponentConstants,
    dataCleanReportsComponentConstants,
    dataCleanCleanupComponentConstants,
    DC_CONFIGURATION_OBJECT,
    DC_CONFIGURATION_Id_FIELD,
    DC_CONFIGURATION_IS_CONFIGURATION_ACTIVE_FIELD,
    DC_DATA_TYPE_OBJECT
};