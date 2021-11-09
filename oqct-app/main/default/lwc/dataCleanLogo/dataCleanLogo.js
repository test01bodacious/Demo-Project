import { LightningElement } from "lwc";

import DATA_CLEAN_LOGO from "@salesforce/contentAssetUrl/Data_Clean_Logo";

export default class DataCleanLogo extends LightningElement {
    // Expose the asset file URL for use in the template
    dataCleanLogoUrl = DATA_CLEAN_LOGO;

    hideHeader = true;
    hideFooter = true;
}