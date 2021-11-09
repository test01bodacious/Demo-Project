/**
* @description       : NA
* @author            : Krrish Joy
* @group             : OQCT Limited
* @last modified on  : 2021-03-18
* @last modified by  : Krrish Joy
* Modifications Log 
* Ver   Date         Author         Modification
* 1.0   2021-01-28   Krrish Joy   Initial Version
**/
public with sharing class DataCleanHomeController {
    
    @AuraEnabled(cacheable=true)
    public static Integer getTotalActiveJobCount(){
		  return CronTriggerSelector.getActiveCronTriggerCount();
    }
}