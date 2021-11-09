/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-05   Krrish Joy   Initial Version
**/
public with sharing class AttachmentSelector {

    public static List<Attachment> getAllAttachments(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM Attachment
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }
}