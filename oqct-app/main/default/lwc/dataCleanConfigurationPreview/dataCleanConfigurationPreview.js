import { api, LightningElement } from "lwc";

export default class DataCleanConfigurationPreview extends LightningElement {
    @api
    previewData;

    get showRecordTypes() {
        return (
            this.previewData.recordTypeData &&
            this.previewData.recordTypeData.length > 0
        );
    }

    get showRelatedObjectRecordTypes() {
        return (
            this.previewData.relatedObjectRecordTypeData &&
            this.previewData.relatedObjectRecordTypeData.length > 0
        );
    }
}