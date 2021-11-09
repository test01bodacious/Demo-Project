import { LightningElement, api } from "lwc";

export default class DataCleanPagination extends LightningElement {
    _completeData;

    @api
    recordsPerPage = 20; // Default

    @api
    perPageData;

    @api
    isDisabled;

    @api
    get completeData() {
        return this._completeData;
    }

    set completeData(value) {
        this.setAttribute("completeData", value);
        this._completeData = value;
        if (this.isConnectedCallBack) {
            this.initComponent();
        }
    }

    totalPages;

    currentPage;

    pageViewingText;

    isConnectedCallBack = false;

    connectedCallback() {
        this.isConnectedCallBack = true;
        this.initComponent();
    }

    get showNavigationFirstButton() {
        return this.currentPage > 1;
    }

    get showNavigationPrevButton() {
        return this.currentPage > 1;
    }

    get showNavigationNextButton() {
        return this.currentPage < this.totalPages;
    }

    get showNavigationLastButton() {
        return this.currentPage < this.totalPages;
    }

    get showNavigationPanel() {
        return (
            this.completeData &&
            this.completeData.length > 0 &&
            this.totalPages > 1
        );
    }

    get isFirstDisabled() {
        return this.isDisabled;
    }

    get isPreviousDisabled() {
        return this.isDisabled;
    }

    get isNextDisabled() {
        return this.isDisabled;
    }

    get isLastDisabled() {
        return this.isDisabled;
    }

    initComponent() {
        this.totalPages = Math.ceil(
            this.completeData.length / this.recordsPerPage
        );
        if (!this.totalPages) {
            this.totalPages = 1;
        }
        this.getCurrentPageData(1);
    }

    // Methods for pagination navigation panel at bottom of table
    firstPage() {
        let curr = this.currentPage;
        if (curr != 1) {
            this.getCurrentPageData(1);
        }
    }

    prevPage() {
        let curr = this.currentPage;
        if (curr - 1 >= 1) {
            this.getCurrentPageData(curr - 1);
        }
    }

    nextPage() {
        let curr = this.currentPage;
        let max = this.totalPages;
        if (curr + 1 <= max) {
            this.getCurrentPageData(curr + 1);
        }
    }

    finalPage() {
        let curr = this.currentPage;
        let max = this.totalPages;
        if (curr != max) {
            this.getCurrentPageData(max);
        }
    }

    getCurrentPageData(pageNumber) {
        this.currentPage = pageNumber;

        this.perPageData = [];

        let lowestIndex =
            pageNumber == 1 ? 0 : (pageNumber - 1) * this.recordsPerPage;

        let highestIndex =
            lowestIndex + this.recordsPerPage < this.completeData.length
                ? lowestIndex + this.recordsPerPage
                : this.completeData.length;

        this.pageViewingText = `Viewing ${
            lowestIndex + 1
        } to ${highestIndex} of ${this.completeData.length}`;

        for (; lowestIndex < highestIndex; lowestIndex++) {
            this.perPageData.push(
                Object.assign({}, this.completeData[lowestIndex])
            );
        }
        this.perPageDataChange();
    }

    perPageDataChange() {
        const perPageDataChangeEvent = new CustomEvent("perpagedatachange", {
            detail: { perPageData: this.perPageData }
        });
        this.dispatchEvent(perPageDataChangeEvent);
    }

    out(label, value) {
        if (value !== Object(value)) {
            console.log(`${label}: `, value);
        } else {
            console.log(`${label}: `, JSON.parse(JSON.stringify(value)));
        }
    }
}