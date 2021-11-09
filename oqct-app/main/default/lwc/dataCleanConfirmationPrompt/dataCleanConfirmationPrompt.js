import { LightningElement, api } from "lwc";

export default class DataCleanConfirmationPrompt extends LightningElement {
    @api
    promptHeading = "Please Confirm";

    @api
    promptData;

    @api
    type = "info-prompt";

    @api
    showConfirmButtonPanel = false;

    connectedCallback() {
        if (
            this.type.toLowerCase() !== "error-prompt" &&
            this.type.toLowerCase() !== "success-prompt" &&
            this.type.toLowerCase() !== "warning-prompt" &&
            this.type.toLowerCase() !== "offline-prompt"
        ) {
            this.type = "info-prompt";
        }
    }

    get cancelButtonVariant() {
        switch (this.type.toLowerCase()) {
            case "error-prompt":
                return "destructive-text";

            case "success-prompt":
                return "brand-outline";

            case "info-prompt":
                return "brand-outline";

            case "warning-prompt":
                return "brand-outline";

            case "offline-prompt":
                return "brand-outline";

            default:
                return "brand-outline";
        }
    }

    get confirmButtonVariant() {
        switch (this.type.toLowerCase()) {
            case "error-prompt":
                return "destructive";

            case "success-prompt":
                return "success";

            case "info-prompt":
                return "brand";

            case "warning-prompt":
                return "brand";

            case "offline-prompt":
                return "brand";

            default:
                return "brand";
        }
    }

    @api
    show() {
        this.template
            .querySelector('c-data-clean-modal[data-id="promptModal"]')
            .show();
    }

    hide() {
        this.template
            .querySelector('c-data-clean-modal[data-id="promptModal"]')
            .hide();
    }

    handleCancel() {
        this.hide();
    }

    handleConfirm() {
        const confirmEvent = new CustomEvent("confirm", {
            detail: { promptData: this.promptData }
        });
        this.dispatchEvent(confirmEvent);
        this.hide();
    }
}