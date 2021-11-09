/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-23
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-04   Krrish Joy   Initial Version
**/
public with sharing class CronTriggerSelector {

    public static List<CronTrigger> getAbortableCronTriggers(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id  
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :(Constants.DISPLAY_FORMAT_DC_CONFIG + Constants.LITERAL_PERCENT)
                    AND State = :Constants.CRON_TRIGGER_STATE_WAITING
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<CronTrigger> getAbortableCronTriggersById(List<Id> jobIds){
        Utils.validateQueryStatementLimits();
        return [SELECT Id  
                FROM CronTrigger
                WHERE Id IN :jobIds
                AND State = :Constants.CRON_TRIGGER_STATE_WAITING
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<CronTrigger> getActiveCronTriggersByNames(Set<String> jobNames){
        Utils.validateQueryStatementLimits();
        return [SELECT CronJobDetail.Name  
                FROM CronTrigger
                WHERE CronJobDetail.Name IN :jobNames
                AND State NOT IN (:Constants.CRON_TRIGGER_STATE_COMPLETE, :Constants.CRON_TRIGGER_STATE_DELETED)
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<CronTrigger> getNextCronTrigger(){
        Utils.validateQueryStatementLimits();
        return [SELECT CronJobDetail.Name, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :(Constants.DISPLAY_FORMAT_DC_CONFIG + Constants.LITERAL_PERCENT)
                    AND State NOT IN (:Constants.CRON_TRIGGER_STATE_COMPLETE, :Constants.CRON_TRIGGER_STATE_DELETED)
                WITH SECURITY_ENFORCED
                ORDER BY NextFireTime ASC
                LIMIT 1];
    }

    public static List<CronTrigger> getCronTriggerNameById(Id jobId){
        Utils.validateQueryStatementLimits();
        return [SELECT CronJobDetail.Name
                FROM CronTrigger
                WHERE Id = :jobId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static List<CronTrigger> getCronTriggerNameAndNextFireTimeById(Id jobId){
        Utils.validateQueryStatementLimits();
        return [SELECT CronJobDetail.Name, NextFireTime
                FROM CronTrigger
                WHERE Id = :jobId
                    AND State NOT IN (:Constants.CRON_TRIGGER_STATE_COMPLETE, :Constants.CRON_TRIGGER_STATE_DELETED)
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static Integer getActiveCronTriggerCount(){
        Utils.validateQueryStatementLimits();
        return [SELECT Count()
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :(Constants.DISPLAY_FORMAT_DC_CONFIG + Constants.LITERAL_PERCENT)
                    AND State NOT IN (:Constants.CRON_TRIGGER_STATE_COMPLETE, :Constants.CRON_TRIGGER_STATE_DELETED)
                WITH SECURITY_ENFORCED];
    }
}