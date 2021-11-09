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
public with sharing class AccountSelector {
    
    public static List<Account> getAllAccounts(){
        Utils.validateQueryStatementLimits();
        return [SELECT Name, AccountNumber, Phone, Industry,
                    Rating, NumberOfEmployees, Website, Description
                FROM Account
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static List<Account> getAllAccountsWithChilds(){
        Utils.validateQueryStatementLimits();
        return [SELECT Name, AccountNumber, Phone, Industry,
                    Rating, NumberOfEmployees, Website, Description,
                (
                    SELECT FirstName, LastName,
                        Email, Phone, Description
                    FROM Contacts
                ),
                (
                    SELECT Name, StageName, CloseDate,
                    Amount, Probability, Description
                    FROM Opportunities
                ),
                (
                    SELECT Id
                    FROM Attachments
                )
                FROM Account
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }
}