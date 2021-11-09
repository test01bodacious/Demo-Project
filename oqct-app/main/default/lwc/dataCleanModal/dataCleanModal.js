import { LightningElement, track, api } from "lwc";

const CSS_CLASS = "modal-hidden";

export default class Modal extends LightningElement {
    @api
    size = "medium";

    @api
    type = "default";

    @api
    modalOverflow = false;

    @api
    showCloseIconForPrompt = false;

    @track showModal = false;
    @api
    set header(value) {
        this.hasHeaderString = value !== "";
        this._headerPrivate = value;
    }
    get header() {
        return this._headerPrivate;
    }

    get modalOverflowStyle() {
        if (this.modalOverflow) {
            return "overflow: initial";
        } else {
            return "";
        }
    }

    get modalSectionRole() {
        switch (this.type) {
            case "default":
                return "dialog";

            case "error-prompt":
            case "success-prompt":
            case "info-prompt":
            case "warning-prompt":
            case "offline-prompt":
                return "alertdialog";

            default:
                return "dialog";
        }
    }

    get modalSectionTabIndex() {
        switch (this.type) {
            case "default":
                return "-1";

            case "error-prompt":
            case "success-prompt":
            case "info-prompt":
            case "warning-prompt":
            case "offline-prompt":
                return "0";

            default:
                return "-1";
        }
    }

    get modalSectionAriaLabelledby() {
        switch (this.type) {
            case "default":
                return "modal-heading-01";

            case "error-prompt":
            case "success-prompt":
            case "info-prompt":
            case "warning-prompt":
            case "offline-prompt":
                return "prompt-heading-id";

            default:
                return "modal-heading-01";
        }
    }

    get modalSectionAriaModal() {
        return "true";
    }

    get modalSectionAriaDescribedby() {
        switch (this.type) {
            case "default":
                return "modal-content-id-1";

            case "error-prompt":
            case "success-prompt":
            case "info-prompt":
            case "warning-prompt":
            case "offline-prompt":
                return "prompt-message-wrapper";

            default:
                return "modal-content-id-1";
        }
    }

    get modalSectionClass() {
        let modalSecClass = "slds-modal slds-fade-in-open ";
        switch (this.size) {
            case "small":
                modalSecClass += "slds-modal_small";
                break;

            case "medium":
                modalSecClass += "slds-modal_medium";
                break;

            case "large":
                modalSecClass += "slds-modal_large";
                break;

            default:
                modalSecClass += "slds-modal_medium";
        }
        switch (this.type) {
            case "default":
                return modalSecClass;

            case "error-prompt":
            case "success-prompt":
            case "info-prompt":
            case "warning-prompt":
            case "offline-prompt":
                if (!this.showCloseIconForPrompt) {
                    modalSecClass += " slds-modal_prompt";
                }
                return modalSecClass;

            default:
                return modalSecClass;
        }
    }

    get modalHeaderClass() {
        let modalHeadClass = "slds-modal__header";
        switch (this.type) {
            case "default":
                return modalHeadClass;

            case "error-prompt":
                modalHeadClass += " slds-theme_error slds-theme_alert-texture";
                return modalHeadClass;

            case "success-prompt":
                modalHeadClass +=
                    " slds-theme_success slds-theme_alert-texture";
                return modalHeadClass;

            case "warning-prompt":
                modalHeadClass +=
                    " slds-theme_warning slds-theme_alert-texture";
                return modalHeadClass;

            case "info-prompt":
                modalHeadClass += " slds-theme_info slds-theme_alert-texture";
                return modalHeadClass;

            case "offline-prompt":
                modalHeadClass +=
                    " slds-theme_offline slds-theme_alert-texture";
                return modalHeadClass;

            default:
                return modalHeadClass;
        }
    }

    hasHeaderString = false;
    _headerPrivate;

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    connectedCallback() {
        this.addEventListener("keyup", this.handleKeyPress.bind(this));
    }

    disconnectedCallback() {
        this.removeEventListener("keyup", this.handleKeyPress.bind(this));
    }

    handleKeyPress({ code }) {
        if ("Escape" === code) {
            this.handleDialogClose();
        }
    }

    handleDialogClose() {
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        const closedialog = new CustomEvent("closedialog");
        this.dispatchEvent(closedialog);
        this.hide();
    }

    handleSlotTaglineChange() {
        // Only needed in "show" state. If hiding, we're removing from DOM anyway
        // Added to address Issue #344 where querySelector would intermittently return null element on hide
        if (this.showModal === false) {
            return;
        }
        const taglineEl = this.template.querySelector("p");
        taglineEl.classList.remove(CSS_CLASS);
    }

    handleSlotFooterChange() {
        // Only needed in "show" state. If hiding, we're removing from DOM anyway
        // Added to address Issue #344 where querySelector would intermittently return null element on hide
        if (this.showModal === false) {
            return;
        }
        const footerEl = this.template.querySelector("footer");
        footerEl.classList.remove(CSS_CLASS);
    }
}