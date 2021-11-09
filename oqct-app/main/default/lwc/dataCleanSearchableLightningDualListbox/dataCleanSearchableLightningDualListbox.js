import { LightningElement, track, api } from "lwc";

import { dataCleanSearchableLightningDualListboxComponentConstants } from "c/utilsJS";

const CONSTANTS = dataCleanSearchableLightningDualListboxComponentConstants;

export default class DataCleanSearchableLightningDualListbox extends LightningElement {
    @api disabled = false; // Indicates the component is loading data

    @api isLoading = false; // Indicates the component is loading data

    @api
    get allOptions() {
        return this._allOptions;
    }

    set allOptions(value) {
        this.setAttribute("allOptions", value);
        this._allOptions = value;
        this.allOptionsveValueChange();
    }

    @api
    get selectedValues() {
        return this._selectedValues;
    }

    set selectedValues(value) {
        this.setAttribute("selectedValues", value);
        this._selectedValues = value;
    }

    @track filteredAllOptions; // 'allOptions' after searching something (filtered all options)

    get inputDisabled() {
        return this.disabled || this.isLoading;
    }

    _allOptions = []; // All options including selected and available/source options

    _selectedValues = []; // Selected Options Values

    searchTerm; // The search term

    @api inputLabel = CONSTANTS.DEFAULT_INPUT_LABEL;
    @api inputPlaceHolder = CONSTANTS.DEFAULT_INPUT_PLACEHOLDER;
    @api dualListBoxLabel = CONSTANTS.DEFAULT_DUAL_LISTBOX_LABEL;
    @api dualListBoxSourceLabel = CONSTANTS.DEFAULT_DUAL_LISTBOX_SOURCE_LABEL;
    @api dualListBoxSelectedLabel =
        CONSTANTS.DEFAULT_DUAL_LISTBOX_SELECTED_LABEL;
    @api dualListBoxSize = CONSTANTS.DEFAULT_DUAL_LISTBOX_SIZE;

    allOptionsveValueChange() {
        if (this._allOptions) {
            this.filteredAllOptions = this._allOptions;
        }
    }

    handleSelectedValuesChange(event) {
        this.selectedValues = event.detail.value;
    }

    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
        if (this.searchTerm) {
            // If there is a search term, filter the options

            //trim the search term
            if (
                typeof this.searchTerm === "string" ||
                this.searchTerm instanceof String
            ) {
                this.searchTerm = this.searchTerm.trim();
            }
            // Filter search term from all options except selected options
            this.filteredAllOptions = this._allOptions.filter((option) => {
                return (
                    option.label
                        .toLowerCase()
                        .includes(this.searchTerm.toLowerCase()) &&
                    !this.selectedValues.find((value) => option.value === value)
                );
            });
            // Filter search term from selected options
            // (This is done separately to appeand it at last of filteredAllOptions)
            let filteredSelectedOptions = this._allOptions.filter((option) => {
                return this.selectedValues.find(
                    (value) => option.value === value
                );
            });
            // Add both options
            this.filteredAllOptions = this.filteredAllOptions.concat(
                filteredSelectedOptions
            );
        } else {
            // If there is no saerch term, get all options back
            this.filteredAllOptions = this._allOptions;
        }
    }

    @api
    getSelectedValues() {
        return this.selectedValues;
    }
}