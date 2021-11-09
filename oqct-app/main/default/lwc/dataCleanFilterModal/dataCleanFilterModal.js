import { LightningElement, api } from "lwc";

import { output } from "c/utilsJS";

export default class DataCleanFilterModal extends LightningElement {
    @api filterColumns;

    @api filters;

    @api
    show() {
        this.template
            .querySelector('c-data-clean-modal[data-id="filterModal"]')
            .show();
    }

    hide() {
        this.template
            .querySelector('c-data-clean-modal[data-id="filterModal"]')
            .hide();
    }

    handleAddNewFilter() {
        this.template.querySelector("c-data-clean-filter").addFilterCondition();
    }

    handleClearAllFilters() {
        this.template.querySelector("c-data-clean-filter").clearAllFilters();
    }

    handleCancel() {
        this.hide();
    }

    handleSave(event) {
        const result = this.template
            .querySelector("c-data-clean-filter")
            .saveFilter();
        this.filters = result.filters;
        output("Filter Results", result);
        const saveEvent = new CustomEvent("save", {
            detail: {
                filters: this.filters,
                filterWhereCondition: result.filterWhereCondition
            }
        });
        this.dispatchEvent(saveEvent);
        this.hide();
    }
}