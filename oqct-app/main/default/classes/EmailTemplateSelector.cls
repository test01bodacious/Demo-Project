/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-03   Krrish Joy   Initial Version
**/
public with sharing class EmailTemplateSelector {

    public static EmailTemplate getEmailTemplateByDeveloperName(String developerName){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM EmailTemplate
                WHERE DeveloperName = :developerName
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }
}