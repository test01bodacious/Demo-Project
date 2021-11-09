import { LightningElement, wire } from "lwc";

import { output, dataCleanHomeComponentConstants } from "c/utilsJS";

import getTotalActiveJobCount from "@salesforce/apex/DataCleanHomeController.getTotalActiveJobCount";

const CONSTANTS = dataCleanHomeComponentConstants;

export default class DataCleanHome extends LightningElement {
    activeJobCount = 0;

    get isMoreActiveJob() {
        return this.activeJobCount > CONSTANTS.LIMIT_HOME;
    }

    @wire(getTotalActiveJobCount, {})
    getNextJobInfo({ error, data }) {
        if (data) {
            output("Response@getTotalActiveJobCount", data);
            this.activeJobCount = data;
        } else if (error) {
            output("Server Error@getTotalActiveJobCount", error.body.message);
        }
    }
}