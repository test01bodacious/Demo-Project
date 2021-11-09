import { LightningElement, api } from "lwc";

import { output, dataCleanToggleButtonComponentConstants } from "c/utilsJS";

const CONSTANTS = dataCleanToggleButtonComponentConstants;

export default class DataCleanToggleButton extends LightningElement {
    @api checked = false;

    @api buttonDisabled = false;

    @api rowId;

    @api columnName;

    @api showLabel = false;

    @api label;

    @api showToggleOnOffText = false;

    @api toggleOnText = CONSTANTS.DEFAULT_TOGGLE_ON_TEXT;

    @api toggleOffText = CONSTANTS.DEFAULT_TOGGLE_OFF_TEXT;

    @api toggleColor;

    connectedCallback() {
        if (this.checked === undefined) {
            this.checked = false;
        }
        if (this.buttonDisabled === undefined) {
            this.buttonDisabled = false;
        }
        if (this.showLabel === undefined) {
            this.showLabel = false;
        }
        if (this.showToggleOnOffText === undefined) {
            this.showToggleOnOffText = false;
        }
        if (this.toggleOnText === undefined) {
            this.toggleOnText = CONSTANTS.DEFAULT_TOGGLE_ON_TEXT;
        }
        if (this.toggleOffText === undefined) {
            this.toggleOffText = CONSTANTS.DEFAULT_TOGGLE_OFF_TEXT;
        }
    }

    handleToggleChange(event) {
        this.checked = event.target.checked;
        const toggleChangeEvent = new CustomEvent("togglechange", {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                value: {
                    rowId: this.rowId,
                    state: event.target.checked,
                    columnName: this.columnName
                }
            }
        });
        this.dispatchEvent(toggleChangeEvent);
    }

    get inactiveText() {
        return this.buttonDisabled
            ? CONSTANTS.TOGGLE_DISABLED_TEXT
            : this.toggleOffText;
    }

    get toggleStyle() {
        if (this.toggleColor) {
            if (this.checked) {
                return "background: " + this.toggleColor;
            } else {
                return "background: " + "darkgray";
            }
        } else {
            return "";
        }
    }

    get toggleTextStyle() {
        if (this.toggleColor) {
            if (this.checked) {
                return "color: " + this.toggleColor;
            } else {
                return "color: " + "black";
            }
        } else {
            return "";
        }
    }
}