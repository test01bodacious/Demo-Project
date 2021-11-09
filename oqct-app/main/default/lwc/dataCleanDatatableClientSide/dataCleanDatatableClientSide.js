/* 

Example: how to use

<c-data-clean-datatable-client-side
    key-field="id"
    table-data={data}
    columns={columns}
    records-per-page={recordsPerPage}
    onnavigationlinkclick={handleNavigationLinkClick}
></c-data-clean-datatable-client-side>

*/

import { LightningElement, track, api } from "lwc";
import { output } from "c/utilsJS";

export default class DataCleanDatatableClientSide extends LightningElement {
    @api
    tableData;
    @api keyField;
    @api columns;
    @api recordsPerPage;
    @api isPaginationDisabled = false;

    selectedRows = [];

    @track perPageTableData = [];

    get showNavigationPanel() {
        return this.tableData && this.tableData.length > 0;
    }

    @api
    getSelectedRows() {
        let sr = this.template
            .querySelector("c-data-clean-custom-lightning-datatable")
            .getSelectedRows();
        return sr;
    }

    @api clearSelectedRows() {
        this.selectedRows = [];
    }

    @api
    getPerPageTableData() {
        return this.perPageTableData;
    }

    handleperpagedatachange(event) {
        this.perPageTableData = [...event.detail.perPageData];
    }

    handleRowAction(event) {
        const rowActionEvent = new CustomEvent("rowaction", {
            detail: { row: event.detail.row }
        });
        this.dispatchEvent(rowActionEvent);
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            this.isPaginationDisabled = true;
        } else {
            this.isPaginationDisabled = false;
        }
        const rowSelectionEvent = new CustomEvent("rowselection", {
            detail: { selectedRows }
        });
        this.dispatchEvent(rowSelectionEvent);
    }
}