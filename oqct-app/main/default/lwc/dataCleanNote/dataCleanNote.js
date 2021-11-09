import { LightningElement, track, wire } from "lwc";

import { refreshApex } from "@salesforce/apex";

import { output, showToast } from "c/utilsJS";

// Apex Methods (DataCleanJobStatusController)
import getTeamNotes from "@salesforce/apex/DataCleanNoteController.getTeamNotes";
import saveTeamNotes from "@salesforce/apex/DataCleanNoteController.saveTeamNotes";

export default class DataCleanNote extends LightningElement {
    _serverError;

    get serverError() {
        return this._serverError;
    }

    set serverError(errorValue) {
        this._serverError = errorValue;
        if (this._serverError) {
            if ("body" in this._serverError) {
                output("Server Error", this._serverError.body.message);
                showToast(
                    this._serverError.body.exceptionType,
                    this._serverError.body.message,
                    "error"
                );
            } else {
                output("Local Error", this._serverError.message);
                showToast("Error", this._serverError.message, "error");
            }
        }
    }

    isLoading;

    isEditMode = false;

    dataCleanTeamNotes = "";
    originalDataCleanNotes = "";

    @track wiredResults;

    @wire(getTeamNotes)
    getTeamNotes(result) {
        this.wiredResults = result;
        const { error, data } = result;
        if (data !== undefined) {
            output("Response@getTeamNotes", data);
            this.dataCleanTeamNotes = data;
            this.originalDataCleanNotes = data;
            this.isLoading = false;
        } else if (error) {
            this.isLoading = false;
            this.serverError = error;
        }
    }

    refreshTeamNotes() {
        this.isLoading = true;
        refreshApex(this.wiredResults)
            .then(() => (this.isLoading = false))
            .catch(() => (this.isLoading = false));
    }

    saveTeamNotes() {
        this.isLoading = true;
        saveTeamNotes({
            teamNotes: this.dataCleanTeamNotes
        })
            .then((data) => {
                if (data.isSuccess) {
                    showToast(
                        "Success!",
                        "Team Notes saved successfully.",
                        "success"
                    );
                    this.refreshTeamNotes();
                } else {
                    showToast("Error!", data.errorMessage, "error");
                }
                this.originalDataCleanNotes = this.dataCleanTeamNotes;
                this.isLoading = false;
                this.isEditMode = false;
            })
            .catch((error) => {
                this.serverError = error;
                this.isLoading = false;
            });
    }

    handleEditNotesClick() {
        this.isEditMode = true;
    }

    handledataCleanTeamNotesChange(event) {
        this.dataCleanTeamNotes = event.detail.value;
    }

    handleSaveTeamNotes() {
        this.saveTeamNotes();
    }

    handleCancelTeamNotes() {
        this.isEditMode = false;
        this.dataCleanTeamNotes = this.originalDataCleanNotes;
    }

    handleClearTeamNotes() {
        this.dataCleanTeamNotes = "";
    }
}