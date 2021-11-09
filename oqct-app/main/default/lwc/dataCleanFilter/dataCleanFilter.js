import { api, track, LightningElement } from "lwc";

import {
    output,
    getFilterWhereCondition,
    isDateColumn,
    isDateTimeColumn,
    isTimeColumn,
    isColumnField,
    TIME_ZONE
} from "c/utilsJS";

export default class DataCleanFilter extends LightningElement {
    @api
    columns = [];

    @api filters = [];

    @track fieldOptions = [];

    filterLogic;

    timezone = TIME_ZONE;

    get isFilters() {
        return this.filters && this.filters.length > 0;
    }

    connectedCallback() {
        if (!this.filters) {
            this.filters = [];
        } else {
            this.filters = JSON.parse(JSON.stringify(this.filters));
        }
        this.initFieldOptions();
    }

    refreshFilters() {
        this.filters = [...this.filters];
    }

    initFieldOptions() {
        this.columns.forEach((column) => {
            if (isColumnField(column)) {
                let fieldOption = {
                    label: column.label,
                    value: column.fieldName,
                    type: column.type
                };
                if (fieldOption.type === "toggleButton") {
                    fieldOption.type = "boolean";
                }
                if (fieldOption.type === "navigation") {
                    fieldOption.value = column.typeAttributes.label.fieldName;
                }
                if (isDateColumn(column)) {
                    fieldOption.type = "date";
                } else if (isDateTimeColumn(column)) {
                    fieldOption.type = "date-time";
                } else if (isTimeColumn(column)) {
                    fieldOption.type = "time";
                }
                this.fieldOptions.push(fieldOption);
            }
        });
    }

    getOperatorOptions(fieldOption) {
        switch (fieldOption.type) {
            case "boolean":
                return [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" }
                ];

            case "currency":
            case "percent":
            case "number":
            case "date":
            case "date-time":
            case "time":
                return [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    {
                        label: "less or equal",
                        value: "<="
                    },
                    {
                        label: "greater or equal",
                        value: ">="
                    }
                ];

            case "email":
            case "phone":
            case "text":
            case "url":
            case "navigation":
                return [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    {
                        label: "less or equal",
                        value: "<="
                    },
                    {
                        label: "greater or equal",
                        value: ">="
                    },
                    { label: "contains", value: "contains" },
                    { label: "does not contain", value: "does not contain" },
                    { label: "starts with", value: "starts with" },
                    { label: "ends with", value: "ends with" }
                ];

            default:
                return [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" }
                ];
        }
    }

    updateFilterNumber() {
        for (let i = 0; i < this.filters.length; i++) {
            this.filters[i].filterNumber = i + 1;
        }
    }

    updateFilterFromFieldOption(fieldOption, filter) {
        filter.field = fieldOption.value;
        filter.operatorOptions = this.getOperatorOptions(fieldOption);
        filter.operator = filter.operatorOptions[0].value;
        filter.value = null;
        filter.type = fieldOption.type;
        filter.isBoolean = fieldOption.type === "boolean";
        filter.isCurrency = fieldOption.type === "currency";
        filter.isDate = fieldOption.type === "date";
        filter.isDateTime = fieldOption.type === "date-time";
        filter.isTime = fieldOption.type === "time";
        filter.isEmail = fieldOption.type === "email";
        filter.isNumber = fieldOption.type === "number";
        filter.isPercent = fieldOption.type === "percent";
        filter.isPhone = fieldOption.type === "phone";
        filter.isText = fieldOption.type === "text";
        filter.isUrl = fieldOption.type === "url";
        filter.isNavigation = fieldOption.type === "navigation";
    }

    @api
    addFilterCondition() {
        let filter = {};
        this.updateFilterFromFieldOption(this.fieldOptions[0], filter);
        if (this.filters.length === 0) {
            filter.filterNumber = 1;
            filter.showRemoveButton = false;
        } else {
            const lastFilter = this.filters[this.filters.length - 1];
            filter.filterNumber = lastFilter.filterNumber + 1;
            filter.showRemoveButton = true;
        }
        this.filters.push(filter);
        this.refreshFilters();
    }

    @api
    clearAllFilters() {
        this.filters = [];
        this.refreshFilters();
    }

    @api
    saveFilter() {
        let results = {};
        results.filters = this.filters;
        results.filterWhereCondition = getFilterWhereCondition(this.filters);
        return results;
    }

    optimizeValueForDifferentDatatypes(value, type) {
        switch (type) {
            case "boolean":
                return value ? true : false;

            case "currency":
            case "percent":
            case "number":
            case "date":
            case "date-time":
                return value ? value : null;

            case "time":
                return value ? value + "Z" : null;

            case "email":
            case "phone":
            case "text":
            case "url":
            case "navigation":
                return value ? value : "";

            default:
                return value ? value : null;
        }
    }

    handleFieldChange(event) {
        const filterNumber = parseInt(event.currentTarget.dataset.filterNumber);
        let filter = this.filters.find(
            (filter) => filter.filterNumber === filterNumber
        );
        const value = event.currentTarget.value;
        let fieldOption = this.fieldOptions.find(
            (fieldOption) => fieldOption.value === value
        );
        this.updateFilterFromFieldOption(fieldOption, filter);
        this.refreshFilters();
    }

    handleOperatorChange(event) {
        const filterNumber = parseInt(event.currentTarget.dataset.filterNumber);
        let filter = this.filters.find(
            (filter) => filter.filterNumber === filterNumber
        );
        const value = event.currentTarget.value;
        filter.operator = value;
        this.refreshFilters();
    }

    handleValueChange(event) {
        const filterNumber = parseInt(event.currentTarget.dataset.filterNumber);
        let filter = this.filters.find(
            (filter) => filter.filterNumber === filterNumber
        );
        filter.value = this.optimizeValueForDifferentDatatypes(
            event.currentTarget.value,
            filter.type
        );
        this.refreshFilters();
    }

    handleToggleValueChange(event) {
        const filterNumber = parseInt(event.currentTarget.dataset.filterNumber);
        let filter = this.filters.find(
            (filter) => filter.filterNumber === filterNumber
        );
        filter.value = event.detail.value.state;
        this.refreshFilters();
    }

    handleRemoveFilterClick(event) {
        const filterNumber = parseInt(event.currentTarget.dataset.filterNumber);
        this.filters = this.filters.filter(
            (filter) => filter.filterNumber !== filterNumber
        );
        this.updateFilterNumber();
        this.refreshFilters();
    }

    handleFilterLogicChange() {}
}