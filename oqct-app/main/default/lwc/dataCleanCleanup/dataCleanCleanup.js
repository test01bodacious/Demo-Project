import { LightningElement, track, wire } from "lwc";

import { refreshApex } from "@salesforce/apex";

import {
    output,
    dataCleanCleanupComponentConstants,
    showToast,
    getMapFromObjectArray,
    exportDatatable,
    processDatatableCoulumns,
    processDatatableData
} from "c/utilsJS";

// Apex Methods (DataCleanJobStatusController)
import getDatatable from "@salesforce/apex/DataCleanCleanupController.getDatatable";
import deleteDataCleanSuccessAndErrorFiles from "@salesforce/apex/DataCleanCleanupController.deleteDataCleanSuccessAndErrorFiles";
import deleteDataCleanBackupFiles from "@salesforce/apex/DataCleanCleanupController.deleteDataCleanBackupFiles";

const CONSTANTS = dataCleanCleanupComponentConstants;

export default class DataCleanCleanup extends LightningElement {
    @track wiredResults;

    @track datatableRequestParams = Object.assign(
        {},
        CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DC_CONFIG
    );

    get datatableRequestParamsString() {
        return JSON.stringify(this.datatableRequestParams);
    }

    configurationData;

    @track filtersDcConfig = [];
    @track filtersDcResult = [];
    @track filtersDcFile = [];

    @track dataCleanConfigurationColumns;
    @track dataCleanConfigurationData;

    @track dataCleanResultColumns;
    @track dataCleanResultData;

    @track dataCleanFileColumns;
    @track dataCleanFiletData;

    @track selectedRows = [];

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

    @track alerts = {
        deleteFileBatch: false
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

    get isDataCleanFileData() {
        return this.dataCleanFileData && this.dataCleanFileData.length > 0;
    }

    get showDCConfigurations() {
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

    get filterColumns() {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                return this.dataCleanConfigurationColumns;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                return this.dataCleanResultColumns;

            case CONSTANTS.DATA_CLEAN_FILES:
                return this.dataCleanFileColumns;

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

            case CONSTANTS.DATA_CLEAN_FILES:
                return this.filtersDcFile && this.filtersDcFile.length > 0;

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

            case CONSTANTS.DATA_CLEAN_FILES:
                return this.filtersDcFile;

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
                        case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                            this.dataCleanResultColumns = datatableColumns;
                            this.dataCleanResultData = datatableData;
                            break;

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
                    //this.isBreadCrumbUpdating = false;
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
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                this.breadcrumbs.push({
                    label: CONSTANTS.DATA_CLEAN_RESULTS,
                    name: CONSTANTS.DATA_CLEAN_RESULTS,
                    id: CONSTANTS.DATA_CLEAN_RESULTS
                });
                break;

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
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                this.filtersDcResult = [];
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
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                this.filtersDcResult = [];
                this.datatableRequestParams = Object.assign(
                    {},
                    CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DC_RESULT
                );
                break;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                this.filtersDcFile = [];
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

    getParentNameFromId() {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                return null;

            case CONSTANTS.DATA_CLEAN_RESULTS:
                return this.dataCleanConfigurationData.find(
                    (dataCleanConfiguration) =>
                        dataCleanConfiguration.Id == this.parentId
                ).Name;

            case CONSTANTS.DATA_CLEAN_FILES:
                return this.dataCleanResultData.find(
                    (dataCleanResult) => dataCleanResult.Id == this.parentId
                ).Name;

            default:
                return null;
        }
    }

    performFileCleanupSuccessAndError(ids2NameMap) {
        this.isLoading = true;
        let batchParams = {
            parentName: this.getParentNameFromId(),
            ids2Name: ids2NameMap,
            dataSetName: this.breadcrumbs[this.breadcrumbs.length - 1].name
        };
        deleteDataCleanSuccessAndErrorFiles({
            batchParamString: JSON.stringify(batchParams)
        })
            .then((result) => {
                if (result.isSuccess) {
                    if (result.message) {
                        showToast("Success!", result.message, "success");
                    } else {
                        this.alerts.deleteFileBatch = true;
                    }
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

    performFileCleanupBackup(ids2NameMap) {
        this.isLoading = true;
        let batchParams = {
            parentName: this.getParentNameFromId(),
            ids2Name: ids2NameMap,
            dataSetName: this.breadcrumbs[this.breadcrumbs.length - 1].name
        };
        deleteDataCleanBackupFiles({
            batchParamString: JSON.stringify(batchParams)
        })
            .then((result) => {
                if (result.isSuccess) {
                    if (result.message) {
                        showToast("Success!", result.message, "success");
                    } else {
                        this.alerts.deleteFileBatch = true;
                    }
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

    handleNavigationLinkClick(event) {
        let tableId = event.target.dataset.id;
        switch (tableId) {
            case "dcConfigTable":
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

    handleAlertMessageClose() {
        this.alerts.deleteFileBatch = false;
    }

    handledeleteBackupsManuallyClick() {
        if (this.selectedRows.length === 0) {
            alert("Please select at least one record");
            return;
        }
        let ids2NameArray = this.selectedRows.map((selectedRow) => {
            let el = {};
            el.key = selectedRow.Id;
            switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
                case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                case CONSTANTS.DATA_CLEAN_RESULTS:
                    el.val = selectedRow.Name;
                    break;

                case CONSTANTS.DATA_CLEAN_FILES:
                    el.val = selectedRow.Title;
                    break;

                default:
                    el.val = selectedRow.Id;
            }
            return el;
        });
        let ids2NameMap = getMapFromObjectArray(ids2NameArray);
        this.performFileCleanupBackup(ids2NameMap);
    }

    handleCleanSuccessErrorFilesClick(event) {
        if (this.selectedRows.length === 0) {
            alert("Please select at least one record");
            return;
        }
        let ids2NameArray = this.selectedRows.map((selectedRow) => {
            let el = {};
            el.key = selectedRow.Id;
            switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
                case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                case CONSTANTS.DATA_CLEAN_RESULTS:
                    el.val = selectedRow.Name;
                    break;

                case CONSTANTS.DATA_CLEAN_FILES:
                    el.val = selectedRow.Title;
                    break;

                default:
                    el.val = selectedRow.Id;
            }
            return el;
        });
        let ids2NameMap = getMapFromObjectArray(ids2NameArray);
        this.performFileCleanupSuccessAndError(ids2NameMap);
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

            case CONSTANTS.DATA_CLEAN_FILES:
                applyFilterToQuery =
                    JSON.stringify(filters) !==
                    JSON.stringify(this.filtersDcFile);
                this.filtersDcFile = filters;
                break;

            default:
                return;
        }
        if (applyFilterToQuery) {
            this.applyFilterToQuery(filterWhereCondition);
        }
    }
}