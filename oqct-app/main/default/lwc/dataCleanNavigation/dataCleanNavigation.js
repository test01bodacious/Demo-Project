/*
    <c-navigation-link 
        label="The Label" 
        title="The Title" 
        type="PageReferenceType" 
        record-id="RecordId"
        api-name="ApiName"
        object-api-name="ObjectApiName"
        relationship-api-name="RelationshipApiName"
        page-name="PageName" 
        action-name="ActionName"></c-record-link>
*/

import { LightningElement, api, track } from "lwc";

import { output, dataCleanNavigationComponentConstants } from "c/utilsJS";

import { NavigationMixin } from "lightning/navigation";

// Constants Properties
const CONSTANTS = dataCleanNavigationComponentConstants;

export default class DataCleanNavigation extends NavigationMixin(
    LightningElement
) {
    @api label; // Text to be displayed as the link
    @api title; // Text to be displayed when hovering on the link (optional, will default to label)
    @api target; // Target for anchor tag

    @api type; // PageReference Type (default of "standard__recordPage" if recordId provided)
    @api recordId; // Id of the record
    @api pageName; // The name of the Page
    @api apiName; // API Name of Page
    @api objectApiName; // Object type
    @api relationshipApiName; // The API Name of Relationship to open
    @api actionName; // Action to perform when clicked (default of "view" if recordId provided)

    @api showAsAnIcon = false; // If true, icon will be shown for preview and edit

    // For Custom Event
    @api columnName; // Column Name (If the component is displayed in Table)
    @api rowId; // Row Id (If the component is displayed in Table)

    @track url;

    get isPreviewIcon() {
        return this.showAsAnIcon && this.actionName === "view";
    }

    get isEditIcon() {
        return this.showAsAnIcon && this.actionName === "edit";
    }

    get isLink() {
        return (
            !(this.showAsAnIcon && this.actionName === "edit") &&
            !(this.showAsAnIcon && this.actionName === "view")
        );
    }

    connectedCallback() {
        // Set defaults...
        if (!this.title) this.title = this.label;
        if (this.type !== CONSTANTS.TYPE_CUSTOM_RAISE_EVENT) {
            if (this.recordId) {
                if (!this.type) this.type = CONSTANTS.TYPE_STANDARD_RECORD_PAGE;
                if (!this.actionName)
                    this.actionName = CONSTANTS.ACTION_DEFAULT;
            }

            // Generate the page reference for NavigationMixin...

            this.navigationLinkRef = {
                type: this.type,
                attributes: {
                    recordId: this.recordId,
                    pageName: this.pageName,
                    apiName: this.apiName,
                    objectApiName: this.objectApiName,
                    relationshipApiName: this.relationshipApiName,
                    actionName: this.actionName
                }
            };

            // Set the link's HREF value so the user can click "open in new tab" or copy the link...
            this[NavigationMixin.GenerateUrl](this.navigationLinkRef).then(
                (url) => {
                    this.url = url;
                }
            );
        }
    }

    @api
    navigate() {
        // Navigate as requested...
        this[NavigationMixin.Navigate](this.navigationLinkRef);
    }

    handleClick(event) {
        if (this.type !== CONSTANTS.TYPE_CUSTOM_RAISE_EVENT) {
            // Stop the event's default behavior (don't follow the HREF link) and prevent click bubbling up in the DOM...
            event.preventDefault();
            event.stopPropagation();

            this.navigate();
        } else {
            const event = new CustomEvent(
                CONSTANTS.EVENT_NAVIGATION_LINK_CLICK,
                {
                    composed: true,
                    bubbles: true,
                    cancelable: true,
                    detail: {
                        recordId: this.recordId,
                        columnName: this.columnName,
                        //rowId: this.rowId
                        rowId: this.recordId // !Todo: rowId is not comming???
                    }
                }
            );
            this.dispatchEvent(event);
        }
    }
}