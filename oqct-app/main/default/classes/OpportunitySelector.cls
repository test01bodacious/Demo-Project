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
public with sharing class OpportunitySelector {

    public static List<Opportunity> getAllOpportunities(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM Opportunity
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }
}