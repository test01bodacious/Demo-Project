import { LightningElement, api } from "lwc";

export default class DataCleanAlertMessage extends LightningElement {
    @api type = "info";

    @api iconDescription = "";

    @api moreInfoUrl;

    @api hideCloseButton = false;

    assistiveText;

    containerClass = "slds-notify slds-notify_alert slds-theme_alert-texture ";

    iconName;

    iconClass = "slds-icon_container slds-m-right_x-small ";

    get iconText() {
        return this.type.charAt(0).toUpperCase() + this.type.slice(1);
    }

    connectedCallback() {
        this.type = this.type.toLowerCase();
        if (this.type === "info") {
            this.containerClass += "slds-theme_info";
            this.iconName = "utility:info";
            this.iconClass += "slds-icon-utility-info";
        } else if (this.type === "offline") {
            this.containerClass += "slds-theme_offline";
            this.iconName = "utility:info";
            this.iconClass += "slds-icon-utility-info";
        } else if (this.type === "warning") {
            this.containerClass += "slds-theme_warning";
            this.iconName = "utility:warning";
            this.iconClass += "slds-icon-utility-warning";
        } else if (this.type === "error") {
            this.containerClass += "slds-theme_error";
            this.iconName = "utility:error";
            this.iconClass += "slds-icon-utility-error";
        } else if (this.type === "success") {
            this.containerClass += "slds-theme_success";
            this.iconName = "utility:success";
            this.iconClass += "slds-icon-utility-success";
        } else {
            this.type = "info";
            this.containerClass += "slds-theme_info";
            this.iconName = "utility:info";
            this.iconClass += "slds-icon-utility-info";
        }
    }

    handleAlertClose() {
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        const closealert = new CustomEvent("closealert");
        this.dispatchEvent(closealert);
    }
}