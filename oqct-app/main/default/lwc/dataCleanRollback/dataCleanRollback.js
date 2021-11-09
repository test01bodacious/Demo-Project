import { LightningElement, track, wire } from "lwc";

import { refreshApex } from "@salesforce/apex";

import {
    output,
    dataCleanRollbackComponentConstants,
    showToast,
    processDatatableCoulumns,
    processDatatableData,
    exportDatatable
} from "c/utilsJS";

// Apex Methods (DataCleanJobStatusController)
import getDatatable from "@salesforce/apex/DataCleanRollbackController.getDatatable";
import performRollback from "@salesforce/apex/DataCleanRollbackController.performRollback";

const CONSTANTS = dataCleanRollbackComponentConstants;

export default class DataCleanRollback extends LightningElement {
    wiredResults;

    @track datatableRequestParams = Object.assign(
        {},
        CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DC_CONFIG
    );

    get datatableRequestParamsString() {
        return JSON.stringify(this.datatableRequestParams);
    }

    @track dataCleanConfigurationColumns;
    @track dataCleanConfigurationData;

    @track dataCleanResultColumns;
    @track dataCleanResultData;

    @track dataCleanColumns;
    @track dataCleanData;

    @track selectedRows = [];

    @track filtersDcConfig = [];
    @track filtersDcResult = [];
    @track filtersDataClean = [];

    parentId;

    @track
    breadcrumbs = [
        {
            label: CONSTANTS.DATA_CLEAN_CONFIGURATIONS,
            name: CONSTANTS.DATA_CLEAN_CONFIGURATIONS,
            id: CONSTANTS.DATA_CLEAN_CONFIGURATIONS
        }
        // {
        //     label: CONSTANTS.DATA_CLEAN_RESULTS,
        //     name: CONSTANTS.DATA_CLEAN_RESULTS,
        //     id: CONSTANTS.DATA_CLEAN_RESULTS
        // },
        // {
        //     label: CONSTANTS.DATA_CLEANS,
        //     name: CONSTANTS.DATA_CLEANS,
        //     id: CONSTANTS.DATA_CLEANS
        // }
    ];

    childTypeValue = CONSTANTS.DATA_CLEAN_RESULTS;
    childTypeOptions = [
        {
            label: CONSTANTS.DATA_CLEAN_RESULTS,
            value: CONSTANTS.DATA_CLEAN_RESULTS
        },
        {
            label: CONSTANTS.DATA_CLEANS,
            value: CONSTANTS.DATA_CLEANS
        }
    ];

    recordsPerPage = CONSTANTS.RECORDS_PER_PAGE;

    noDataMessage = CONSTANTS.NO_DATA_MESSAGE;
    hideCloseButtonOnNoData = true;

    isLoading = true;
    isCreateOrEdit = false;
    isBreadCrumbUpdating = false;

    @track alerts = {
        rollbackBatchStart: false
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

    get isDataCleanConfigurationData() {
        return (
            this.dataCleanConfigurationData &&
            this.dataCleanConfigurationData.length > 0
        );
    }

    get isDataCleanResultData() {
        return this.dataCleanResultData && this.dataCleanResultData.length > 0;
    }

    get isDataCleanData() {
        return this.dataCleanData && this.dataCleanData.length > 0;
    }

    get showRollbackSelected() {
        return (
            this.breadcrumbs[this.breadcrumbs.length - 1].name ===
                CONSTANTS.DATA_CLEAN_RESULTS ||
            this.breadcrumbs[this.breadcrumbs.length - 1].name ===
                CONSTANTS.DATA_CLEANS
        );
    }

    get showDcConfigurations() {
        return (
            this.breadcrumbs[this.breadcrumbs.length - 1].name ===
            CONSTANTS.DATA_CLEAN_CONFIGURATIONS
        );
    }

    get showDataCleanResults() {
        return (
            this.breadcrumbs[this.breadcrumbs.length - 1].name ===
            CONSTANTS.DATA_CLEAN_RESULTS
        );
    }

    get showDataCleans() {
        return (
            this.breadcrumbs[this.breadcrumbs.length - 1].name ===
            CONSTANTS.DATA_CLEANS
        );
    }

    get showChildTypeSelector() {
        return (
            this.breadcrumbs[this.breadcrumbs.length - 1].name ===
                CONSTANTS.DATA_CLEAN_RESULTS ||
            this.breadcrumbs[this.breadcrumbs.length - 1].name ===
                CONSTANTS.DATA_CLEANS
        );
    }

    get cardTitle() {
        return this.breadcrumbs[this.breadcrumbs.length - 1].label;
    }

    get showBackAction() {
        return this.breadcrumbs.length > 1;
    }

    get filterButtonName() {
        return this.isFilterApplied ? "Change Filter" : "Apply Filter";
    }

    get filterColumns() {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                return this.dataCleanConfigurationColumns;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                return this.dataCleanResultColumns;

            case CONSTANTS.DATA_CLEANS:
                return this.dataCleanColumns;

            default:
                return [];
        }
    }

    get isFilterApplied() {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                return this.filtersDcConfig && this.filtersDcConfig.length > 0;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                return this.filtersDcResult && this.filtersDcResult.length > 0;

            case CONSTANTS.DATA_CLEANS:
                return (
                    this.filtersDataClean && this.filtersDataClean.length > 0
                );

            default:
                return false;
        }
    }

    get filters() {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                return this.filtersDcConfig;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                return this.filtersDcResult;

            case CONSTANTS.DATA_CLEANS:
                return this.filtersDataClean;

            default:
                return [];
        }
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
                const datatableColumns = processDatatableCoulumns(
                    data.datatableColumns
                );
                const datatableData = processDatatableData(data.datatableData);

                if (!this.isBreadCrumbUpdating) {
                    switch (
                        this.breadcrumbs[this.breadcrumbs.length - 1].name
                    ) {
                        case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                            this.dataCleanConfigurationColumns = datatableColumns;
                            this.dataCleanConfigurationData = datatableData;
                            break;

                        case CONSTANTS.DATA_CLEAN_RESULTS:
                            this.dataCleanResultColumns = datatableColumns;
                            this.dataCleanResultData = datatableData;
                            break;

                        case CONSTANTS.DATA_CLEANS:
                            this.dataCleanColumns = datatableColumns;
                            this.dataCleanData = datatableData;
                            break;

                        default:
                            return;
                    }
                } else {
                    switch (
                        this.breadcrumbs[this.breadcrumbs.length - 1].name
                    ) {
                        case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                            if (
                                this.childTypeValue ===
                                CONSTANTS.DATA_CLEAN_RESULTS
                            ) {
                                this.dataCleanResultColumns = datatableColumns;
                                this.dataCleanResultData = datatableData;
                            } else {
                                this.dataCleanColumns = datatableColumns;
                                this.dataCleanData = datatableData;
                            }
                            break;

                        case CONSTANTS.DATA_CLEAN_RESULTS:
                            break;

                        case CONSTANTS.DATA_CLEANS:
                            break;

                        default:
                            return;
                    }
                }
            } catch (error) {
                this.serverError = error;
            }
            this.isLoading = false;
        } else if (error) {
            this.isLoading = false;
            this.serverError = error;
        }
    }

    refreshData(parentColumnName) {
        this.isLoading = true;
        if (parentColumnName) {
            this.isBreadCrumbUpdating = true;
        }
        refreshApex(this.wiredResults)
            .then(() => {
                this.isLoading = false;
                if (parentColumnName) {
                    try {
                        this.clearSelectedRows();
                        this.pushBreadcrumb(parentColumnName);
                        this.isBreadCrumbUpdating = false;
                    } catch (error) {
                        this.serverError = error;
                    }
                } else {
                    this.isBreadCrumbUpdating = false;
                }
            })
            .catch(() => (this.isLoading = false));
    }

    openFilterModal() {
        this.template
            .querySelector('c-data-clean-filter-modal[data-id="filterModal"]')
            .show();
    }

    pushBreadcrumb(fieldName) {
        let dcConfigName = this.searchDcConfigName(fieldName);
        this.breadcrumbs[
            this.breadcrumbs.length - 1
        ].label += ` (${dcConfigName})`;
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                this.breadcrumbs.push({
                    label: this.childTypeValue,
                    name: this.childTypeValue,
                    id: this.childTypeValue
                });
                break;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                break;

            case CONSTANTS.DATA_CLEANS:
                break;

            default:
                break;
        }
        this.selectedRows = [];
    }

    popBreadcrumb(name) {
        let index = this.breadcrumbs.length - 1;
        if (name) {
            const breadcrumbIndex = this.breadcrumbs.findIndex(
                (breadcrumb) => breadcrumb.name === name
            );
            index = breadcrumbIndex + 1;
        }
        this.breadcrumbs.splice(index, this.breadcrumbs.length - index);
        this.breadcrumbs[
            this.breadcrumbs.length - 1
        ].label = this.removeBracketsFromLast(
            this.breadcrumbs[this.breadcrumbs.length - 1].label
        );
        this.selectedRows = [];
    }

    updateBreadCrumb(childTypeValue) {
        this.breadcrumbs[this.breadcrumbs.length - 1].label = childTypeValue;
        this.breadcrumbs[this.breadcrumbs.length - 1].name = childTypeValue;
        this.breadcrumbs[this.breadcrumbs.length - 1].id = childTypeValue;
        this.selectedRows = [];
        if (this.childTypeValue === CONSTANTS.DATA_CLEAN_RESULTS) {
            this.filtersDcResult = [];
            this.datatableRequestParams = Object.assign(
                {},
                CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DC_RESULT
            );
        } else {
            this.filtersDataClean = [];
            this.datatableRequestParams = Object.assign(
                {},
                CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DATA_CLEAN
            );
        }
        this.datatableRequestParams.whereClauseCondition += `'${this.parentId}'`;
        this.refreshData();
    }

    removeBracketsFromLast(str) {
        let tempStr = str.substr(0, str.lastIndexOf(")"));
        return tempStr.substr(0, tempStr.lastIndexOf(" ("));
    }

    searchDcConfigName(parentColumnName) {
        let perPageData;
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                perPageData = this.template
                    .querySelector(
                        'c-data-clean-datatable-client-side[data-id="dcConfigTable"]'
                    )
                    .getPerPageTableData();
                break;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                perPageData = this.template
                    .querySelector(
                        'c-data-clean-datatable-client-side[data-id="dataCleanResultTable"]'
                    )
                    .getPerPageTableData();
                break;

            case CONSTANTS.DATA_CLEANS:
                perPageData = this.template
                    .querySelector(
                        'c-data-clean-datatable-client-side[data-id="dataCleanTable"]'
                    )
                    .getPerPageTableData();
                break;

            default:
                perPageData = [];
                break;
        }
        return perPageData.find((data) => data.Id === this.parentId)[
            parentColumnName
        ];
    }

    clearSelectedRows() {
        this.selectedRows = [];
        let dataTableComponent;
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                dataTableComponent = this.template.querySelector(
                    'c-data-clean-datatable-client-side[data-id="dcConfigTable"]'
                );
                break;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                dataTableComponent = this.template.querySelector(
                    'c-data-clean-datatable-client-side[data-id="dataCleanResultTable"]'
                );
                break;

            case CONSTANTS.DATA_CLEANS:
                dataTableComponent = this.template.querySelector(
                    'c-data-clean-datatable-client-side[data-id="dataCleanTable"]'
                );
                break;

            default:
                break;
        }
        if (dataTableComponent) {
            dataTableComponent.clearSelectedRows();
        }
    }

    updateDatatableRequestParams() {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                this.datatableRequestParams = Object.assign(
                    {},
                    CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DC_CONFIG
                );
                break;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                this.datatableRequestParams = Object.assign(
                    {},
                    CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DC_RESULT
                );
                this.datatableRequestParams.whereClauseCondition += `'${this.parentId}'`;
                break;

            case CONSTANTS.DATA_CLEANS:
                this.datatableRequestParams = Object.assign(
                    {},
                    CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DATA_CLEAN
                );
                this.datatableRequestParams.whereClauseCondition += `'${this.parentId}'`;
                break;

            default:
                break;
        }
    }

    moveToChild(parentColumnName) {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                if (this.childTypeValue === CONSTANTS.DATA_CLEAN_RESULTS) {
                    this.filtersDcResult = [];
                    this.datatableRequestParams = Object.assign(
                        {},
                        CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DC_RESULT
                    );
                } else {
                    this.filtersDataClean = [];
                    this.datatableRequestParams = Object.assign(
                        {},
                        CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DATA_CLEAN
                    );
                }
                break;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                break;

            case CONSTANTS.DATA_CLEANS:
                break;

            default:
                break;
        }
        this.datatableRequestParams.whereClauseCondition += `'${this.parentId}'`;
        this.refreshData(parentColumnName);
    }

    performRollback(parentId, recordIds) {
        output("parentId", parentId);
        output("recordIds", recordIds);
        this.isLoading = true;
        let rollbackParams = {
            dcConfigId: parentId,
            dataCleanIds:
                this.breadcrumbs[this.breadcrumbs.length - 1].name ==
                CONSTANTS.DATA_CLEANS
                    ? recordIds
                    : null,
            resultIds:
                this.breadcrumbs[this.breadcrumbs.length - 1].name ==
                CONSTANTS.DATA_CLEAN_RESULTS
                    ? recordIds
                    : null
        };
        performRollback({
            rollbackParamsString: JSON.stringify(rollbackParams)
        })
            .then((result) => {
                if (result.isSuccess) {
                    this.alerts.rollbackBatchStart = true;
                } else {
                    showToast("Error!", result.errorMessage, "error");
                }
                this.isLoading = false;
                this.refreshData();
            })
            .catch((error) => {
                this.serverError = error;
                this.isLoading = false;
            });
    }

    handleFilterClick() {
        this.openFilterModal();
    }

    handleRefreshClick() {
        this.refreshData();
    }

    handleExportClick() {
        try {
            switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
                case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                    exportDatatable(
                        this.dataCleanConfigurationColumns,
                        this.dataCleanConfigurationData,
                        CONSTANTS.EXPORT_FILE_NAME_DC_CONFIG
                    );
                    break;

                case CONSTANTS.DATA_CLEAN_RESULTS:
                    exportDatatable(
                        this.dataCleanResultColumns,
                        this.dataCleanResultData,
                        CONSTANTS.EXPORT_FILE_NAME_DATA_CLEAN_RESULT
                    );
                    break;

                case CONSTANTS.DATA_CLEANS:
                    exportDatatable(
                        this.dataCleanColumns,
                        this.dataCleanData,
                        CONSTANTS.EXPORT_FILE_NAME_DATA_CLEAN
                    );
                    break;

                default:
                    return;
            }
        } catch (error) {
            this.serverError = error;
        }
    }

    handleSaveFilter(event) {
        const filterWhereCondition = event.detail.filterWhereCondition;
        const filters = event.detail.filters;
        let applyFilterToQuery = false;
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                applyFilterToQuery =
                    JSON.stringify(filters) !==
                    JSON.stringify(this.filtersDcConfig);
                this.filtersDcConfig = filters;
                break;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                applyFilterToQuery =
                    JSON.stringify(filters) !==
                    JSON.stringify(this.filtersDcResult);
                this.filtersDcResult = filters;
                break;

            case CONSTANTS.DATA_CLEANS:
                applyFilterToQuery =
                    JSON.stringify(filters) !==
                    JSON.stringify(this.filtersDataClean);
                this.filtersDataClean = filters;
                break;

            default:
                break;
        }
        if (applyFilterToQuery) {
            this.applyFilterToQuery(filterWhereCondition);
        }
    }

    navigateToChild(event) {
        const { recordId, columnName, rowId } = event.detail;
        if (rowId !== this.parentId) {
            this.parentId = rowId;
            this.moveToChild(columnName);
        } else {
            this.pushBreadcrumb(columnName);
        }
    }

    applyFilterToQuery(filterWhereCondition) {
        this.updateDatatableRequestParams();
        let oldWhereClauseCondition = this.datatableRequestParams
            .whereClauseCondition;
        if (oldWhereClauseCondition) {
            if (filterWhereCondition) {
                this.datatableRequestParams.whereClauseCondition = `${oldWhereClauseCondition} AND (${filterWhereCondition})`;
            } else {
                this.datatableRequestParams.whereClauseCondition = `${oldWhereClauseCondition}`;
            }
        } else {
            if (filterWhereCondition) {
                this.datatableRequestParams.whereClauseCondition = `${filterWhereCondition}`;
            } else {
                this.datatableRequestParams.whereClauseCondition = null;
            }
        }
        this.refreshData();
    }

    handleNavigationLinkClick(event) {
        let tableId = event.target.dataset.id;
        switch (tableId) {
            case "dcConfigTable":
                this.navigateToChild(event);
                break;

            case "dataCleanResultTable":
            case "dataCleanTable":
                const { recordId, columnName, rowId } = event.detail;
                output(
                    "NavigationLinkClick Event DataParam-recordId",
                    recordId
                );
                output(
                    "NavigationLinkClick Event DataParam-columnName",
                    columnName
                );
                output("NavigationLinkClick Event DataParam-rowId", rowId);
                break;

            default:
                break;
        }
    }

    handleNavigateFromBreadcrumb(event) {
        // prevent default navigation by href
        event.preventDefault();

        const name = event.target.name;

        if (name) {
            if (name !== this.breadcrumbs[this.breadcrumbs.length - 1].name) {
                this.popBreadcrumb(name);
            }
        }
    }

    handleChildTypeValueChange(event) {
        this.childTypeValue = event.target.value;
        this.updateBreadCrumb(this.childTypeValue);
    }

    handleRollbackSelectedClick(event) {
        if (this.selectedRows.length === 0) {
            alert("Please select at least one record");
            return;
        }
        let selectedIds = this.selectedRows.map(
            (selectedRow) => selectedRow.Id
        );
        this.performRollback(this.parentId, selectedIds);
    }

    handleBackClick(event) {
        this.popBreadcrumb();
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    handleAlertMessageClose() {
        this.alerts.rollbackBatchStart = false;
    }

    handleRowActionDcConfig(event) {
        const dcConfigId = event.detail.row.Id;
        this.performRollback(dcConfigId, null);
    }

    handleRowActionDcResult(event) {
        const dcResultId = event.detail.row.Id;
        this.performRollback(this.parentId, [dcResultId]);
    }

    handleRowActionDataClean(event) {
        const dataCleanId = event.detail.row.Id;
        this.performRollback(this.parentId, [dataCleanId]);
    }
}