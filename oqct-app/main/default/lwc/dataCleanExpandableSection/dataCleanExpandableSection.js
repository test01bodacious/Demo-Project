/* 
    How to Use:

    <c-data-clean-expandable-section is-collapsed={isCollapsed} section-title={sectionTitle}>
        Content Here...
    </c-data-clean-expandable-section>

*/

import { LightningElement, api } from "lwc";

export default class DataCleanExpandableSection extends LightningElement {
    @api
    collapsible = false;

    @api
    isCollapsed = false; // default section is open

    @api
    sectionTitle = "Information";

    sectionIconName = "utility:chevrondown";

    sectionButtonName = "Collapse";

    connectedCallback() {
        if (this.isCollapsed) {
            this.sectionIconName = "utility:chevronright";
            this.sectionButtonName = "Expand";
        } else {
            this.sectionIconName = "utility:chevrondown";
            this.sectionButtonName = "Collapse";
        }
    }

    toggleSectionProperties() {
        if (this.isCollapsed) {
            this.isCollapsed = false;
            this.sectionIconName = "utility:chevrondown";
            this.sectionButtonName = "Collapse";
        } else {
            this.isCollapsed = true;
            this.sectionIconName = "utility:chevronright";
            this.sectionButtonName = "Expand";
        }
    }

    handleSectionClick() {
        this.toggleSectionProperties();
        const sectionToggleEvent = new CustomEvent("sectiontoggle", {
            detail: { isCollapsed: this.isCollapsed }
        });
        this.dispatchEvent(sectionToggleEvent);
    }
}