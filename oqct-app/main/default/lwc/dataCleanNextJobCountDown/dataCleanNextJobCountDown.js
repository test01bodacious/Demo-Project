import { LightningElement, track, wire } from "lwc";

import { output } from "c/utilsJS";

// Apex Methods (DataCleanJobStatusController)
import getNextJobInfo from "@salesforce/apex/DataCleanJobStatusController.getNextJobInfo";

export default class DataCleanNextJobCountDown extends LightningElement {
    nextJobName;

    nextJobInfo;

    @track nextDataCleanJobCountDown = {
        days: "00",
        hours: "00",
        minutes: "00",
        seconds: "00"
    };

    isLoadComplete = false;

    get isNoData() {
        return this.isLoadComplete && !this.nextJobInfo;
    }

    @wire(getNextJobInfo, {})
    getNextJobInfo({ error, data }) {
        if (data) {
            try {
                output("Response@getNextJobInfo", data);
                if (data) {
                    this.initNextDataCleanJobCountDown(
                        new Date(data.nextJobDateTime)
                    );
                    this.nextJobName = data.nextJobName;
                    this.isLoadComplete = true;
                } else {
                    this.isLoadComplete = true;
                }
            } catch (error) {
                output("Local Error@getNextJobInfo", error.message);
            }
        } else if (error) {
            output("Server Error@getNextJobInfo", error.body.message);
        }
    }

    initNextDataCleanJobCountDown(nextJobDateTime) {
        let countDownInterval = setInterval(() => {
            // Get today's date and time
            let now = new Date();

            let nowDateTime = now.getTime();

            // Find the distance between now and the count down date
            let distance = nextJobDateTime - nowDateTime;

            // Time calculations for days, hours, minutes and seconds
            let days = Math.floor(distance / (1000 * 60 * 60 * 24));
            let hours = Math.floor(
                (distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
            );
            let minutes = Math.floor(
                (distance % (1000 * 60 * 60)) / (1000 * 60)
            );
            let seconds = Math.floor((distance % (1000 * 60)) / 1000);

            // Output the result in an element with id="demo"
            this.nextDataCleanJobCountDown = {
                days: days.toString().length == 1 ? `0${days}` : `${days}`,
                hours: hours.toString().length == 1 ? `0${hours}` : `${hours}`,
                minutes:
                    minutes.toString().length == 1
                        ? `0${minutes}`
                        : `${minutes}`,
                seconds:
                    seconds.toString().length == 1
                        ? `0${seconds}`
                        : `${seconds}`
            };

            // If the count down is over, write some text
            if (distance < 0) {
                clearInterval(countDownInterval);
            }
        }, 1000);
    }
}