/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-31   Krrish Joy   Initial Version
**/
public with sharing class DataCleanCustomExceptions {

    public with sharing class SOQLStatementLimitException extends Exception{}

    public with sharing class DMLRowLimitException extends Exception{}

    public with sharing class DMLStatementLimitException extends Exception{}

    public with sharing class InsufficientPrivilegesException extends Exception{}

    public with sharing class TriggerHandlerException extends Exception {}

    public with sharing class InvalidRowException extends Exception {}
}