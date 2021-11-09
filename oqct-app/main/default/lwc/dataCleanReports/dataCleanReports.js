import { LightningElement, track, wire } from "lwc";

import { refreshApex } from "@salesforce/apex";

import {
    output,
    dataCleanReportsComponentConstants,
    showToast,
    processDatatableCoulumns,
    processDatatableData,
    exportDatatable
} from "c/utilsJS";

// Apex Methods (DataCleanJobStatusController)
import getDatatable from "@salesforce/apex/DataCleanReportController.getDatatable";

const CONSTANTS = dataCleanReportsComponentConstants;

export default class DataCleanReports extends LightningElement {
    @track wiredResults;

    @track datatableRequestParams = Object.assign(
        {},
        CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DC_REPORT
    );

    get datatableRequestParamsString() {
        return JSON.stringify(this.datatableRequestParams);
    }

    reportData;

    @track filtersDataCleanReport = [];
    @track filtersDataCleanFile = [];

    @track dataCleanReportColumns;
    @track dataCleanReportData;

    @track dataCleanFileColumns;
    @track dataCleanFiletData;

    @track selectedRows = [];

    parentId;

    @track
    breadcrumbs = [
        {
            label: CONSTANTS.DATA_CLEAN_RESULTS,
            name: CONSTANTS.DATA_CLEAN_RESULTS,
            id: CONSTANTS.DATA_CLEAN_RESULTS
        }
        // {
        //     label: CONSTANTS.DATA_CLEAN_FILES,
        //     name: CONSTANTS.DATA_CLEAN_FILES,
        //     id: CONSTANTS.DATA_CLEAN_FILES
        // }
    ];

    recordsPerPage = CONSTANTS.RECORDS_PER_PAGE;

    noDataMessage = CONSTANTS.NO_DATA_MESSAGE;
    hideCloseButtonOnNoData = true;

    isLoading = true;
    isBreadCrumbUpdating = false;

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

    get isDataCleanReportData() {
        return this.dataCleanReportData && this.dataCleanReportData.length > 0;
    }

    get isDataCleanFileData() {
        return this.dataCleanFileData && this.dataCleanFileData.length > 0;
    }

    get showDataCleanResults() {
        return (
            this.breadcrumbs[this.breadcrumbs.length - 1].name ===
            CONSTANTS.DATA_CLEAN_RESULTS
        );
    }

    get showDataCleanFiles() {
        return (
            this.breadcrumbs[this.breadcrumbs.length - 1].name ===
            CONSTANTS.DATA_CLEAN_FILES
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

    get isFilterApplied() {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_RESULTS:
                return (
                    this.filtersDataCleanReport &&
                    this.filtersDataCleanReport.length > 0
                );

            case CONSTANTS.DATA_CLEAN_FILES:
                return (
                    this.filtersDataCleanFile &&
                    this.filtersDataCleanFile.length > 0
                );

            default:
                return false;
        }
    }

    get filters() {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                return this.filtersDataCleanReport;

            case CONSTANTS.DATA_CLEANS:
                return this.filtersDataCleanFile;

            default:
                return [];
        }
    }

    get filterColumns() {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_RESULTS:
                return this.dataCleanReportColumns;

            case CONSTANTS.DATA_CLEAN_FILES:
                return this.dataCleanFileColumns;

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
                        case CONSTANTS.DATA_CLEAN_RESULTS:
                            this.dataCleanReportColumns = datatableColumns;
                            this.dataCleanReportData = datatableData;
                            break;

                        case CONSTANTS.DATA_CLEAN_FILES:
                            this.dataCleanFileColumns = datatableColumns;
                            this.dataCleanFileData = datatableData;
                            break;

                        default:
                            return;
                    }
                } else {
                    switch (
                        this.breadcrumbs[this.breadcrumbs.length - 1].name
                    ) {
                        case CONSTANTS.DATA_CLEAN_RESULTS:
                            this.dataCleanFileColumns = datatableColumns;
                            this.dataCleanFileData = datatableData;
                            break;

                        case CONSTANTS.DATA_CLEAN_FILES:
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

    openPreviewModal() {
        this.template
            .querySelector('c-data-clean-modal[data-id="previewModal"]')
            .show();
    }

    closePreviewModal() {
        this.template
            .querySelector('c-data-clean-modal[data-id="previewModal"]')
            .hide();
    }

    openFilterModal() {
        this.template
            .querySelector('c-data-clean-filter-modal[data-id="filterModal"]')
            .show();
    }

    pushBreadcrumb(parentColumnName) {
        let dcConfigName = this.searchDcConfigName(parentColumnName);
        this.breadcrumbs[
            this.breadcrumbs.length - 1
        ].label += ` (${dcConfigName})`;
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_RESULTS:
                this.breadcrumbs.push({
                    label: CONSTANTS.DATA_CLEAN_FILES,
                    name: CONSTANTS.DATA_CLEAN_FILES,
                    id: CONSTANTS.DATA_CLEAN_FILES
                });
                break;

            case CONSTANTS.DATA_CLEAN_FILES:
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

    removeBracketsFromLast(str) {
        let tempStr = str.substr(0, str.lastIndexOf(")"));
        return tempStr.substr(0, tempStr.lastIndexOf(" ("));
    }

    searchDcConfigName(parentColumnName) {
        let perPageData;
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_RESULTS:
                perPageData = this.template
                    .querySelector(
                        'c-data-clean-datatable-client-side[data-id="dataCleanResultTable"]'
                    )
                    .getPerPageTableData();
                break;

            case CONSTANTS.DATA_CLEAN_FILES:
                perPageData = this.template
                    .querySelector(
                        'c-data-clean-datatable-client-side[data-id="dataCleanFileTable"]'
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
            case CONSTANTS.DATA_CLEAN_RESULTS:
                dataTableComponent = this.template.querySelector(
                    'c-data-clean-datatable-client-side[data-id="dataCleanResultTable"]'
                );
                break;

            case CONSTANTS.DATA_CLEAN_FILES:
                dataTableComponent = this.template.querySelector(
                    'c-data-clean-datatable-client-side[data-id="dataCleanFileTable"]'
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
            case CONSTANTS.DATA_CLEAN_RESULTS:
                this.datatableRequestParams = Object.assign(
                    {},
                    CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DC_REPORT
                );
                break;

            case CONSTANTS.DATA_CLEAN_FILES:
                this.datatableRequestParams = Object.assign(
                    {},
                    CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DATA_CLEAN_FILE
                );
                this.datatableRequestParams.whereClauseCondition += `'${this.parentId}'`;
                break;

            default:
                break;
        }
    }

    moveToChild(parentColumnName) {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_RESULTS:
                this.filtersDataCleanFile = [];
                this.datatableRequestParams = Object.assign(
                    {},
                    CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DATA_CLEAN_FILE
                );
                break;

            case CONSTANTS.DATA_CLEAN_FILES:
                break;

            default:
                break;
        }
        this.datatableRequestParams.whereClauseCondition += `'${this.parentId}'`;
        this.refreshData(parentColumnName);
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
            case "dataCleanResultTable":
                this.navigateToChild(event);
                break;

            case "dataCleanFileTable":
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

    handleBackClick(event) {
        this.popBreadcrumb();
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
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
                case CONSTANTS.DATA_CLEAN_RESULTS:
                    exportDatatable(
                        this.dataCleanReportColumns,
                        this.dataCleanReportData,
                        CONSTANTS.EXPORT_FILE_NAME_DATA_CLEAN_REPORT
                    );
                    break;

                case CONSTANTS.DATA_CLEAN_FILES:
                    exportDatatable(
                        this.dataCleanFileColumns,
                        this.dataCleanFileData,
                        CONSTANTS.EXPORT_FILE_NAME_DATA_CLEAN_FILE
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
            case CONSTANTS.DATA_CLEAN_RESULTS:
                applyFilterToQuery =
                    JSON.stringify(filters) !==
                    JSON.stringify(this.filtersDataCleanReport);
                this.filtersDataCleanReport = filters;
                break;

            case CONSTANTS.DATA_CLEAN_FILES:
                applyFilterToQuery =
                    JSON.stringify(filters) !==
                    JSON.stringify(this.filtersDataCleanFile);
                this.filtersDataCleanFile = filters;
                break;

            default:
                break;
        }
        if (applyFilterToQuery) {
            this.applyFilterToQuery(filterWhereCondition);
        }
    }
}