import { LightningElement, track, api, wire } from "lwc";

import { refreshApex } from "@salesforce/apex";

import {
    output,
    dataCleanJobStatusComponentConstants,
    showToast,
    processDatatableCoulumns,
    processDatatableData,
    exportDatatable
} from "c/utilsJS";

// Apex Methods (DataCleanJobStatusController)
import getDatatable from "@salesforce/apex/DataCleanJobStatusController.getDatatable";
import abortDataCleanJobs from "@salesforce/apex/DataCleanJobStatusController.abortDataCleanJobs";

const CONSTANTS = dataCleanJobStatusComponentConstants;

export default class DataCleanJobStatus extends LightningElement {
    @api isHome = false;

    @track dataCleanJobColumns;
    @track dataCleanJobData;

    wiredResults;

    @track datatableRequestParams = Object.assign(
        {},
        CONSTANTS.DATA_TABLE_REQUEST_PARAMS_JOB_STATUS
    );

    get datatableRequestParamsString() {
        return JSON.stringify(
            this.isHome
                ? Object.assign(
                      {},
                      CONSTANTS.DATA_TABLE_REQUEST_PARAMS_JOB_STATUS_HOME
                  )
                : this.datatableRequestParams
        );
    }

    noDataMessage = CONSTANTS.NO_DATA_MESSAGE;
    hideCloseButtonOnNoData = true;

    @track filters = [];

    isLoading = true;

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

    get isDataCleanJobData() {
        return this.dataCleanJobData && this.dataCleanJobData.length > 0;
    }

    get filterButtonName() {
        return this.isFilterApplied ? "Change Filter" : "Apply Filter";
    }

    get isFilterApplied() {
        return this.filters && this.filters.length > 0;
    }

    get filterColumns() {
        return this.dataCleanJobColumns;
    }

    connectedCallback() {
        //this.loadInitialData();
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
                this.dataCleanJobColumns = processDatatableCoulumns(
                    data.datatableColumns
                );
                this.dataCleanJobData = processDatatableData(
                    data.datatableData
                );
                this.addNewColumnAndRowData();
            } catch (error) {
                this.serverError = error;
            }
            this.isLoading = false;
        } else if (error) {
            this.isLoading = false;
            this.serverError = error;
        }
    }

    addNewColumnAndRowData() {
        // No Need because columns are hard coded

        // if (!this.dataCleanJobColumns || this.dataCleanJobColumns.length == 0) {
        //     return;
        // }
        // let fieldNames = [];
        // for (let i = 0; i < this.dataCleanJobColumns.length; i++) {
        //     const element = this.dataCleanJobColumns[i];
        //     if (element.fieldName === CONSTANTS.JOB_NAME_FIELD_API_NAME) {
        //         fieldNames.push(element.fieldName);
        //         break;
        //     }
        // }
        // if (fieldNames.length !== 1) {
        //     return;
        // }
        this.addNewColumns();
        this.addNewRowData();
    }

    addNewColumns() {
        let dcConfigurationColumn = {};
        dcConfigurationColumn.fieldName =
            CONSTANTS.DC_CONFIGURATION_FIELD_API_NAME;
        dcConfigurationColumn.label = CONSTANTS.DC_CONFIGURATION_FIELD_LABEL;
        let actionColumn = {};
        actionColumn.fieldName = CONSTANTS.ACTION_FIELD_API_NAME;
        actionColumn.label = CONSTANTS.ACTION_FIELD_LABEL;
        if (this.dataCleanJobColumns.length > 1) {
            this.dataCleanJobColumns.splice(
                1,
                0,
                dcConfigurationColumn,
                actionColumn
            );
        } else {
            this.dataCleanJobColumns.push(dcConfigurationColumn);
            this.dataCleanJobColumns.push(actionColumn);
        }
    }

    addNewRowData() {
        this.dataCleanJobData.forEach((dataCleanJobRow) => {
            let jobNameSplitArray = dataCleanJobRow[
                CONSTANTS.JOB_NAME_FIELD_API_NAME
            ].split("-");
            dataCleanJobRow[CONSTANTS.ACTION_FIELD_API_NAME] =
                jobNameSplitArray[jobNameSplitArray.length - 1];
            jobNameSplitArray.splice(jobNameSplitArray.length - 1, 1);
            dataCleanJobRow[
                CONSTANTS.DC_CONFIGURATION_FIELD_API_NAME
            ] = jobNameSplitArray.join("-");
        });
    }

    abortSelectedJobs(selectedJobIds) {
        this.isLoading = true;
        abortDataCleanJobs({
            dataCleanJobIds: selectedJobIds
        })
            .then((result) => {
                if (result.isSuccess) {
                    showToast(
                        "Success!",
                        "Selected Jobs Aborted Successfully.",
                        "success"
                    );
                    this.refreshData();
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

    refreshData() {
        this.isLoading = true;
        refreshApex(this.wiredResults)
            .then(() => (this.isLoading = false))
            .catch(() => (this.isLoading = false));
    }

    openFilterModal() {
        this.template
            .querySelector('c-data-clean-filter-modal[data-id="filterModal"]')
            .show();
    }

    updateDatatableRequestParams() {
        this.datatableRequestParams = Object.assign(
            {},
            CONSTANTS.DATA_TABLE_REQUEST_PARAMS_JOB_STATUS
        );
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

    handleFilterClick() {
        this.openFilterModal();
    }

    handleRefreshClick() {
        this.refreshData();
    }

    handleExportClick() {
        try {
            exportDatatable(
                this.dataCleanJobColumns,
                this.dataCleanJobData,
                CONSTANTS.EXPORT_FILE_NAME_JOB_STATUS
            );
        } catch (error) {
            this.serverError = error;
        }
    }

    handleSaveFilter(event) {
        const filterWhereCondition = event.detail.filterWhereCondition;
        const filters = event.detail.filters;
        if (JSON.stringify(filters) !== JSON.stringify(this.filters)) {
            this.filters = filters;
            this.applyFilterToQuery(filterWhereCondition);
        }
    }

    handleNavigationLinkClick(event) {
        const { recordId, columnName, rowId } = event.detail;
        output("NavigationLinkClick Event DataParam-recordId", recordId);
        output("NavigationLinkClick Event DataParam-columnName", columnName);
        output("NavigationLinkClick Event DataParam-rowId", rowId);
    }

    handleAbortClick(event) {
        let selectedRows = this.template
            .querySelector("c-data-clean-datatable-client-side")
            .getSelectedRows();
        if (selectedRows.length === 0) {
            alert("Please select at least one record");
            return;
        }
        let selectedJobIds = selectedRows.map((a) => a.Id);
        this.abortSelectedJobs(selectedJobIds);
    }
}