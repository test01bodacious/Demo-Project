import { LightningElement, api } from "lwc";
import feedType from "./dataCleanStencilFeedType.html";
import listType from "./dataCleanStencilListType.html";

export default class DataCleanStencil extends LightningElement {
    /* Exposed properties */
    @api type = "list"; //Type of stencil to render
    @api iterations = 1; //Number of stencil items to display (Rows)
    @api childClass = ""; //Add custom styling to each stencil item
    @api columns = 1; //Number of columns in which iterations should be rendered

    /* Private properties */

    //default configuration object for text type skeleton - Change sizing from available classes in css file
    listWrap = {
        key: 1,
        lines: [
            {
                key: 1,
                class: "text text-primary text-short text-thinnest"
            },
            {
                key: 2,
                class: "text text-longer text-thinnest"
            },
            {
                key: 3,
                class: "text text-long text-thinnest"
            }
        ]
    };

    //default configuration object for feed type skeleton - Change sizing from available classes in css file
    feedWrap = {
        key: 1,
        lines: [
            {
                key: 1,
                class: "text text-long text-thinnest"
            },
            {
                key: 2,
                class: "text text-short text-thinnest"
            }
        ],
        isActionAvailable: true,
        isIconAvailable: true,
        isHeaderImageAvailable: false
    };

    //Conditionally render stencil type based on specified type (Add more stencil templates here)
    render() {
        switch (`${this.type}`.toLocaleLowerCase()) {
            case "feed":
                return feedType;
                break;
            case "list":
            default:
                return listType;
                break;
        }
    }

    //Get list of elements iterated in list - convert count to list
    get getIterationsForList() {
        let list = [];
        if (this.iterations <= 1) {
            list.push({ ...this.listWrap });
        } else {
            for (let i = 0; i < this.iterations; i++) {
                let temp = { ...this.listWrap };
                temp.key = i;
                list.push(temp);
            }
        }
        return list;
    }

    //Get feed elements iterated in list - convert count to list
    get getIterationsForFeed() {
        let list = [];
        if (this.iterations <= 1) {
            list.push({ ...this.feedWrap });
        } else {
            for (let i = 0; i < this.iterations; i++) {
                let temp = { ...this.feedWrap };
                temp.key = i;
                list.push(temp);
            }
        }
        return list;
    }

    //Calculates division of columns for dynamic grid
    get viewPortSize() {
        return Math.ceil(12 / this.columns);
    }

    //change or update style class for each element in list (Example: Apply custom margin around each stencil card)
    get getChildClass() {
        return `${this.childClass}`
            ? `${this.childClass}`
            : "slds-var-m-around_xx-small";
    }
}