// eslint-disable-next-line no-console
import { LightningElement, track, wire } from "lwc";

import { refreshApex } from "@salesforce/apex";

import {
    output,
    getMapFromObjectArray,
    dataCleanConfigurationsComponentConstants,
    showToast,
    processDatatableCoulumns,
    processDatatableData,
    exportDatatable,
    DC_CONFIGURATION_OBJECT,
    DC_CONFIGURATION_Id_FIELD,
    DC_CONFIGURATION_IS_CONFIGURATION_ACTIVE_FIELD
} from "c/utilsJS";

// Apex Methods (DataCleanJobStatusController)
import getDatatable from "@salesforce/apex/DataCleanConfigurationController.getDatatable";
import getDataCleanConfigurationComponentEditData from "@salesforce/apex/DataCleanConfigurationController.getDataCleanConfigurationComponentEditData";
import activeOrDeactivateDcConfiguration from "@salesforce/apex/DataCleanConfigurationController.activeOrDeactivateDcConfiguration";
import deleteDcConfigurations from "@salesforce/apex/DataCleanConfigurationController.deleteDcConfigurations";

const CONSTANTS = dataCleanConfigurationsComponentConstants;

export default class DataCleanConfigurations extends LightningElement {
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
    @track filtersDataClean = [];

    @track dataCleanConfigurationColumns;
    @track dataCleanConfigurationData;

    @track dataCleanColumns;
    @track dataCleanData;

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
        //     label: CONSTANTS.DATA_CLEANS,
        //     name: CONSTANTS.DATA_CLEANS,
        //     id: CONSTANTS.DATA_CLEANS
        // }
    ];

    recordsPerPage = CONSTANTS.RECORDS_PER_PAGE;
    noDataMessage = CONSTANTS.NO_DATA_MESSAGE;

    hideCloseButtonOnNoData = true;

    isLoading = true;
    isCreateOrEdit = false;
    isBreadCrumbUpdating = false;

    @track alerts = {
        deleteBatchStart: false
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

    get isDataCleanData() {
        return this.dataCleanData && this.dataCleanData.length > 0;
    }

    get showDcConfigurations() {
        return (
            this.breadcrumbs[this.breadcrumbs.length - 1].name ===
            CONSTANTS.DATA_CLEAN_CONFIGURATIONS
        );
    }

    get showDataCleans() {
        return (
            this.breadcrumbs[this.breadcrumbs.length - 1].name ===
            CONSTANTS.DATA_CLEANS
        );
    }

    get cardTitle() {
        return this.breadcrumbs[this.breadcrumbs.length - 1].label;
    }

    get showDeleteAction() {
        switch (this.breadcrumbs[this.breadcrumbs.length - 1].name) {
            case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                return true;

            case CONSTANTS.DATA_CLEANS:
                return false;

            default:
                return false;
        }
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

                        case CONSTANTS.DATA_CLEANS:
                            this.dataCleanColumns = datatableColumns;
                            this.dataCleanData = datatableData;
                            break;

                        default:
                            break;
                    }
                } else {
                    switch (
                        this.breadcrumbs[this.breadcrumbs.length - 1].name
                    ) {
                        case CONSTANTS.DATA_CLEAN_CONFIGURATIONS:
                            this.dataCleanColumns = datatableColumns;
                            this.dataCleanData = datatableData;
                            break;

                        case CONSTANTS.DATA_CLEANS:
                            break;

                        default:
                            break;
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
                    label: CONSTANTS.DATA_CLEANS,
                    name: CONSTANTS.DATA_CLEANS,
                    id: CONSTANTS.DATA_CLEANS
                });
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
                this.filtersDataClean = [];
                this.datatableRequestParams = Object.assign(
                    {},
                    CONSTANTS.DATA_TABLE_REQUEST_PARAMS_DATA_CLEAN
                );
                break;

            case CONSTANTS.DATA_CLEANS:
                break;

            default:
                break;
        }
        this.datatableRequestParams.whereClauseCondition += `'${this.parentId}'`;
        this.refreshData(parentColumnName);
    }

    activeOrDeactivateDcConfiguration(dcConfigId, state) {
        this.isLoading = true;
        let dcConfig = { sobjectType: DC_CONFIGURATION_OBJECT.objectApiName };
        dcConfig[DC_CONFIGURATION_Id_FIELD.fieldApiName] = dcConfigId;
        dcConfig[
            DC_CONFIGURATION_IS_CONFIGURATION_ACTIVE_FIELD.fieldApiName
        ] = state;
        activeOrDeactivateDcConfiguration({
            dcConfig
        })
            .then((result) => {
                if (result.isSuccess) {
                    showToast(
                        "Success!",
                        "Configuration saved Successfully.",
                        "success"
                    );
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

    deleteDcConfigurations(dcConfigId2Name) {
        this.isLoading = true;
        deleteDcConfigurations({
            dcConfigId2Name
        })
            .then((result) => {
                if (result.isSuccess) {
                    this.alerts.deleteBatchStart = true;
                } else {
                    showToast("Error!", result.errorMessage, "error");
                }
                this.isLoading = false;
            })
            .catch((error) => {
                this.serverError = error;
                this.isLoading = false;
            });
    }

    initDataCleanConfigurationData(dcConfigId) {
        this.isLoading = true;
        getDataCleanConfigurationComponentEditData({
            dcConfigId
        })
            .then((result) => {
                if (result) {
                    output(
                        "response@getDataCleanConfigurationComponentEditData",
                        result
                    );
                    this.configurationData = result;
                    this.isCreateOrEdit = true;
                } else {
                    showToast(
                        "Error!",
                        "Something went wrong! Could not fetch DC-Configuration Data",
                        "error"
                    );
                }
                this.isLoading = false;
                this.refreshData();
            })
            .catch((error) => {
                this.serverError = error;
                this.isLoading = false;
            });
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

    handleToggleChange(event) {
        let rowId = event.detail.value.rowId;
        let checked = event.detail.value.state;
        this.activeOrDeactivateDcConfiguration(rowId, checked);
    }

    handleRowAction(event) {
        const dcConfigId = event.detail.row.Id;
        this.initDataCleanConfigurationData(dcConfigId);
    }

    handleNavigationLinkClick(event) {
        let tableId = event.target.dataset.id;
        switch (tableId) {
            case "dcConfigTable":
                try {
                    this.navigateToChild(event);
                } catch (error) {
                    this.serverError = error;
                }
                break;

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

    handleBackClick(event) {
        this.popBreadcrumb();
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    handleNewClick(event) {
        this.isCreateOrEdit = true;
    }

    handleDeleteClick() {
        if (this.selectedRows.length === 0) {
            alert("Please select at least one record");
            return;
        }
        try {
            this.template
                .querySelector(
                    'c-data-clean-confirmation-prompt[data-id="deleteConfirmation"]'
                )
                .show();
        } catch (error) {
            this.serverError = error;
        }
    }

    handleCloseAlert(event) {
        this.alerts[event.currentTarget.dataset.id] = false;
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

    handleConfirmDelete(event) {
        try {
            const dcConfigRows = event.detail.promptData;
            let dcConfigId2NameArray = dcConfigRows.map((dcConfigRow) => {
                let el = {};
                el.key = dcConfigRow.Id;
                el.val = dcConfigRow.Name;
                return el;
            });
            let dcConfigId2NameMap = getMapFromObjectArray(
                dcConfigId2NameArray
            );
            output("Data to Delete", dcConfigId2NameMap);
            this.deleteDcConfigurations(dcConfigId2NameMap);
        } catch (error) {
            this.serverError = error;
        }
    }

    handleConfigurationSave(event) {
        this.isCreateOrEdit = false;
        this.refreshData();
    }

    handleConfigurationCancel(event) {
        this.isCreateOrEdit = false;
    }
}