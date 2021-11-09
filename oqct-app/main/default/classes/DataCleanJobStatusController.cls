/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-22   Krrish Joy   Initial Version
**/
public with sharing class DataCleanJobStatusController {

    @AuraEnabled(cacheable = true)
    public static DatatableUtil.DatatableResponse getDatatable(String datatableRequestParamsString){
        try {
            Utils.debug('datatableRequestParamsString', datatableRequestParamsString);
            DatatableUtil.DatatableRequestParameters datatableRequestParams = (DatatableUtil.DatatableRequestParameters)JSON.deserialize(datatableRequestParamsString, DatatableUtil.DatatableRequestParameters.class);
            return DatatableUtil.fetchDatatableResponse(
                datatableRequestParams
            );
        } catch (Exception e) {
            Utils.debug('AuraException', e.getMessage());
            Utils.debug('AuraException Line', e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static NextDataCleanJob getNextJobInfo(){
        try {
            List<CronTrigger> nextCronTriggers = CronTriggerSelector.getNextCronTrigger();
            if (nextCronTriggers.isEmpty()) {
                return null;
            }
            NextDataCleanJob nextDataCleanJobInfo = new NextDataCleanJob();
            nextDataCleanJobInfo.nextJobDateTime =  nextCronTriggers[0].NextFireTime;
            nextDataCleanJobInfo.nextJobId = nextCronTriggers[0].Id;
            nextDataCleanJobInfo.nextJobName = nextCronTriggers[0].CronJobDetail.Name;
            return nextDataCleanJobInfo;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Utils.Response abortDataCleanJobs(List<Id> dataCleanJobIds){
        try {
            Utils.debug('dataCleanJobIds', dataCleanJobIds);
            Utils.Response response = new Utils.Response();
            for ( CronTrigger job : CronTriggerSelector.getAbortableCronTriggersById(dataCleanJobIds)){
                System.AbortJob(job.Id);
            }
            // Return Success Response
            response.isSuccess = true;
            response.errorMessage = '';
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public with sharing class NextDataCleanJob{
        @AuraEnabled
        public Datetime nextJobDateTime;

        @AuraEnabled
        public String nextJobId;

        @AuraEnabled
        public String nextJobName;
    }
}