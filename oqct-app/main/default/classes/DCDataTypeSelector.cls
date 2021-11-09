/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-26
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-02-22   Krrish Joy   Initial Version
**/
public with sharing class DCDataTypeSelector {

    public static List<OQCT_DaCl__DC_Data_Type__c> getAllDCDataTypes(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM OQCT_DaCl__DC_Data_Type__c
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static OQCT_DaCl__DC_Data_Type__c getDCDataTypeByDataTypeName(String dataTypeName){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM OQCT_DaCl__DC_Data_Type__c
                WHERE OQCT_DaCl__Data_Type_Name__c = :dataTypeName
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static List<OQCT_DaCl__DC_Data_Type__c> getDCDataType(){
        Utils.validateQueryStatementLimits();
        return [SELECT OQCT_DaCl__Match_Record_Original_Data_Length__c, 
                        OQCT_DaCl__Match_Object_Field_Length__c, 
                        OQCT_DaCl__Custom_Length__c,
                        OQCT_DaCl__Data_Type_Name__c,
                        OQCT_DaCl__Text_Masking_Option__c,
                        OQCT_DaCl__URL_Domain__c,
                        OQCT_DaCl__Email_Domain__c,
                        OQCT_DaCl__Value_Type__c
                FROM OQCT_DaCl__DC_Data_Type__c
                WITH SECURITY_ENFORCED
                LIMIT :Utils.getRemainingQueryRowsLimit()];
    }

    public static OQCT_DaCl__DC_Data_Type__c getDCDataTypeText(){
        Utils.validateQueryStatementLimits();
        return [SELECT Id
                FROM OQCT_DaCl__DC_Data_Type__c
                WHERE OQCT_DaCl__Data_Type_Name__c = :Constants.DC_DATA_TYPE_TEXT
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }

    public static Integer getDCDataTypeCount(){
        Utils.validateQueryStatementLimits();
        return [SELECT Count()
                FROM OQCT_DaCl__DC_Data_Type__c
                WITH SECURITY_ENFORCED];
    }
}