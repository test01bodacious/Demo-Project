/* 

Example: how to use

<c-data-clean-datatable-client-side
    key-field="id"
    table-data={data}
    columns={columns}
    onnavigationlinkclick={handleNavigationLinkClick}
></c-data-clean-datatable-client-side>;

*/

import { LightningElement, api } from "lwc";

export default class DataCleanDatatableDisplayOnly extends LightningElement {
    @api keyField;
    @api tableData;
    @api columns;

    handleNavigationLinkClick(event) {
        const { recordId, columnName, rowId } = event.detail;
        const navigationLinkClickEvent = new CustomEvent(
            "navigationlinkclick",
            {
                detail: { recordId, columnName, rowId }
            }
        );
        this.dispatchEvent(navigationLinkClickEvent);
    }

    handleRowAction(event) {
        const rowActionEvent = new CustomEvent("rowaction", {
            detail: { row: event.detail.row }
        });
        this.dispatchEvent(rowActionEvent);
    }
}