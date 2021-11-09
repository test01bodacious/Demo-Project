/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-02-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-15   Krrish Joy   Initial Version
**/
public with sharing class OrganizationSelector {
    
    public static Organization getOrganization(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id, Name
                FROM Organization
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static Organization getOrganizationForTimeZone(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id, TimeZoneSidKey
                FROM Organization
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }
}