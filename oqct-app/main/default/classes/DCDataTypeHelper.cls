/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-20
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-20   Krrish Joy   Initial Version
**/
public with sharing class DCDataTypeHelper {

    public static void blockDelete(List<OQCT_DaCl__DC_Data_Type__c> dcDataTypes) {
        for (OQCT_DaCl__DC_Data_Type__c dcDataType : dcDataTypes) {
            dcDataType.addError(Constants.DC_DATA_TYPE_TRIGGER_ERROR_CANNOT_DELETE);
        }
    }
}