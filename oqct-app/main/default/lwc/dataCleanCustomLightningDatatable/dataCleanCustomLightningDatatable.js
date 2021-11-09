import { api } from "lwc";
import LightningDatatable from "lightning/datatable";
import dataCleanToggleButtonColumnTemplate from "./dataCleanToggleButtonColumnTemplate";
import dataCleanNavigationTemplate from "./dataCleanNavigationTemplate";

export default class DataCleanCustomLightningDatatable extends LightningDatatable {
    static customTypes = {
        toggleButton: {
            template: dataCleanToggleButtonColumnTemplate,
            standardCellLayout: true,
            typeAttributes: [
                "buttonDisabled",
                "rowId",
                "checked",
                "showLabel",
                "label",
                "showToggleOnOffText",
                "toggleOnText",
                "toggleOffText",
                "toggleColor"
            ]
        },
        navigation: {
            template: dataCleanNavigationTemplate,
            standardCellLayout: true,
            typeAttributes: [
                "label",
                "title",
                "pageReferencetype",
                "recordId",
                "actionName",
                "pageName",
                "pageApiName",
                "objectApiName",
                "relationshipApiName",
                "showAsAnIcon",
                "columnName",
                "rowId"
            ]
        }
    };
}