import { LightningElement, api } from "lwc";

export default class DataCleanCard extends LightningElement {
    @api alignHeadingCenter = false;

    @api hideHeader = false;
    @api hideFooter = false;

    get headingClass() {
        if (this.alignHeadingCenter) {
            return "slds-card__header-title slds-align_absolute-center";
        } else {
            return "slds-card__header-title";
        }
    }
}