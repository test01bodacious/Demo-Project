/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-25
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-03   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class EncryptUtilTest {
    
    @TestSetup
    private static void setupData(){
		DataFactory.initDcDataTypes();
    }

    @IsTest
    private static void getEncryptedValueTest(){
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        EncryptUtil.testDisplayType = Schema.Account.Id.getDescribe().getType();
        Schema.DescribeFieldResult fieldResult =  Schema.Account.Id.getDescribe();
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(true, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertEquals(null, maskedValue, 'Masked Value should be null.');
    }
    
    @IsTest
    private static void getEncryptedValueForStringTest(){
		EncryptUtil.testDisplayType = Schema.Account.AccountNumber.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.AccountNumber.getDescribe();

        String input = 'Test';

        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(input, maskedValue, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueForStringUpperCaseTest(){
		EncryptUtil.testDisplayType = Schema.Account.AccountNumber.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.AccountNumber.getDescribe();
        dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_TEXT).textMaskingOption = Constants.MASK_PATTERN_ALPHABETS_UPPER_CASE_ONLY;

        String input = 'Test';
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(input, maskedValue, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueForStringLowerAndUpperCaseTest(){
		EncryptUtil.testDisplayType = Schema.Account.AccountNumber.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.AccountNumber.getDescribe();
        dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_TEXT).textMaskingOption = Constants.MASK_PATTERN_ALPHABETS_LOWER_CASE_UPPER_CASE;

        String input = 'Test';
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(input, maskedValue, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueForStringAlphaNumericUpperCaseTest(){
		EncryptUtil.testDisplayType = Schema.Account.AccountNumber.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.AccountNumber.getDescribe();
        dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_TEXT).textMaskingOption = Constants.MASK_PATTERN_ALPHA_NUMBERIC_UPPER_CASE_ONLY;
        
        String input = 'Test';

        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(input, maskedValue, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueForStringAlphaNumericUpperLowerCaseTest(){
		EncryptUtil.testDisplayType = Schema.Account.AccountNumber.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_TEXT).textMaskingOption = Constants.MASK_PATTERN_ALPHA_NUMBERIC_LOWER_CASE_UPPER_CASE;
        Schema.DescribeFieldResult fieldResult =  Schema.Account.AccountNumber.getDescribe();
        
        String input = 'Test';

        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(input, maskedValue, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueForStringAlphaNumericUpperCaseSpecialCharsTest(){
		EncryptUtil.testDisplayType = Schema.Account.AccountNumber.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.AccountNumber.getDescribe();
        dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_TEXT).textMaskingOption = Constants.MASK_PATTERN_ALPHA_NUMBERIC_WITH_SPECIAL_CHARACTER;
        
        String input = 'Test';

        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(input, maskedValue, 'Masked Value is same.');
    }

    @IsTest
    private static void getEncryptedValuePicklistTest(){
		EncryptUtil.testDisplayType = Schema.Account.AccountSource.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
		Schema.DescribeFieldResult fieldResult =  Schema.Account.AccountSource.getDescribe();
        
        String input = 'Test';

        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(input, maskedValue, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueCurrencyTest(){
		EncryptUtil.testDisplayType = Schema.Account.AnnualRevenue.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.AnnualRevenue.getDescribe();
        
        Decimal input = 3500000;

        Test.startTest();
        Decimal maskedValue = (Decimal)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(input, maskedValue, 'Masked Value is same.');
    }
        
    @IsTest
    private static void getEncryptedValueDateTest(){
		Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        EncryptUtil.testDisplayType = Schema.Account.LastActivityDate.getDescribe().getType();
        Schema.DescribeFieldResult fieldResult =  Schema.Account.LastActivityDate.getDescribe();
        Date input = System.today();
        input.addDays(10);
        
        Test.startTest();
        Date maskedValue = (Date)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

		System.assertEquals(true, maskedValue != null, 'Date should not be null.');
    }
    
    @IsTest
    private static void getEncryptedValueDateTimeTest(){
		Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        EncryptUtil.testDisplayType = Schema.Account.LastViewedDate.getDescribe().getType();
        Schema.DescribeFieldResult fieldResult =  Schema.Account.LastViewedDate.getDescribe();
        Datetime input = System.now();
        input.addDays(10);
        
        Test.startTest();
        DateTime maskedValue = (DateTime)EncryptUtil.getEncryptedValue(input, null, dataTypeName2dataTypeConfig);
        Test.stopTest();

		System.assertEquals(true, maskedValue != null, 'DateTime should not be null.');
    }
    
    @IsTest
    private static void getEncryptedValueDateTimeForPastTest(){
		Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        EncryptUtil.testDisplayType = Schema.Account.LastViewedDate.getDescribe().getType();
		dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_DATE_TIME).valueType = Constants.MASK_VALUE_TYPE_PAST_DATE;
        Schema.DescribeFieldResult fieldResult =  Schema.Account.LastViewedDate.getDescribe();
        Datetime input = System.now();
        input.addDays(-10);
        
        Test.startTest();
        DateTime maskedValue = (DateTime)EncryptUtil.getEncryptedValue(input, null, dataTypeName2dataTypeConfig);
        Test.stopTest();

		System.assertEquals(true, maskedValue != null, 'DateTime should not be null.');
    }
    
    @IsTest
    private static void getEncryptedValueDoubleTest(){
		EncryptUtil.testDisplayType = Schema.Account.ShippingLatitude.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.ShippingLatitude.getDescribe();
        Double input = 1.2;
        
        Test.startTest();
        Double maskedValue = (Double)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueMultiPhoneTest(){
		EncryptUtil.testDisplayType = Schema.Account.Phone.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.Phone.getDescribe();
        String input = '123456789';
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueRatingTest(){
		EncryptUtil.testDisplayType = Schema.Account.Rating.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.Rating.getDescribe();
        String input = '3.4';
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue,input, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueBooleanTest(){
		EncryptUtil.testDisplayType = Schema.Account.isDeleted.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.isDeleted.getDescribe();
        
        Test.startTest();
        Boolean maskedValue = (Boolean)EncryptUtil.getEncryptedValue(true, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertEquals(maskedValue == true || maskedValue == false, true, 'Masked Value is null.');
    }
    
    @IsTest
    private static void getEncryptedValueTextAreaForLowLengthTest(){
		EncryptUtil.testDisplayType = Schema.Contact.Description.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Contact.Description.getDescribe();
        String input = 'Description';
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueTextAreaForHighLengthTest(){
		EncryptUtil.testDisplayType = Schema.Contact.Description.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Contact.Description.getDescribe();
        String input = 'Description'.repeat(25);
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueURLTest(){
		EncryptUtil.testDisplayType = Schema.Contact.PhotoURL.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Contact.PhotoURL.getDescribe();
        String input = 'http//test.com';
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueEmailTest(){
		EncryptUtil.testDisplayType = Schema.Contact.Email.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Contact.Email.getDescribe();
        String input = 'random@test.com';
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValuePercentTest(){
		EncryptUtil.testDisplayType = Schema.Opportunity.Probability.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Opportunity.Probability.getDescribe();
        Decimal input = 74;
        
        Test.startTest();
        Decimal maskedValue = (Decimal)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }
    
    @IsTest
    private static void getEncryptedValueNumericLatitudeTest(){
		EncryptUtil.testDisplayType = Schema.Account.BillingLatitude.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.BillingLatitude.getDescribe();
        Decimal input = 12;
        
        Test.startTest();
        Decimal maskedValue = (Decimal)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getEncryptedValueMultiPicklistTest(){
		EncryptUtil.testDisplayType = Schema.DisplayType.MULTIPICKLIST;
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.Industry.getDescribe();
        String input = 'Banking';
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getRandomPicklistValueForRestrictedPicklistTest(){
        Schema.DescribeFieldResult fieldResult =  Schema.Account.Industry.getDescribe();
        String input = 'Banking';
        
        Test.startTest();
        String maskedValue = EncryptUtil.getRandomPicklistValueForRestrictedPicklist(input, fieldResult);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getRandomMultiPicklistValueForRestrictedPicklistTest(){
        Schema.DescribeFieldResult fieldResult =  Schema.Account.Industry.getDescribe();
        String input = 'Banking;Agriculture';
        
        Test.startTest();
        String maskedValue = EncryptUtil.getRandomMultiPicklistValueForRestrictedPicklist(input, fieldResult);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getEncryptedValueEncryptedStringTest(){
		EncryptUtil.testDisplayType = Schema.DisplayType.ENCRYPTEDSTRING;
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.AccountNumber.getDescribe();
        String input = 'AOD20XP';
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getEncryptedValueReferenceTest(){
		EncryptUtil.testDisplayType = Schema.Contact.AccountId.getDescribe().getType();
        List<OQCT_DaCl__DC_Data_Type__c> dcDataTypes = DCDataTypeSelector.getDCDataType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(dcDataTypes);
        Schema.DescribeFieldResult fieldResult =  Schema.Contact.AccountId.getDescribe();
        Id input = dcDataTypes[0].Id;
        
        Test.startTest();
        Id maskedValue = (Id)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getEncryptedValueCurrencyMatchObjectFieldLengthTest(){
		EncryptUtil.testDisplayType = Schema.Opportunity.Amount.getDescribe().getType();
        List<OQCT_DaCl__DC_Data_Type__c> dcDataTypes = DCDataTypeSelector.getDCDataType();
        for (OQCT_DaCl__DC_Data_Type__c dcDataType : dcDataTypes) {
            if (dcDataType.OQCT_DaCl__Data_Type_Name__c == Constants.DC_DATA_TYPE_CURRENCY) {
                dcDataType.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
                dcDataType.OQCT_DaCl__Match_Object_Field_Length__c = true;
            }
        }
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(dcDataTypes);
        Schema.DescribeFieldResult fieldResult =  Schema.Opportunity.Amount.getDescribe();
        Decimal input = 1024.58;
        
        Test.startTest();
        Decimal maskedValue = (Decimal)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getEncryptedValueCurrencyCustomLengthTest(){
		EncryptUtil.testDisplayType = Schema.Opportunity.Amount.getDescribe().getType();
        List<OQCT_DaCl__DC_Data_Type__c> dcDataTypes = DCDataTypeSelector.getDCDataType();
        for (OQCT_DaCl__DC_Data_Type__c dcDataType : dcDataTypes) {
            if (dcDataType.OQCT_DaCl__Data_Type_Name__c == Constants.DC_DATA_TYPE_CURRENCY) {
                dcDataType.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
                dcDataType.OQCT_DaCl__Match_Object_Field_Length__c = false;
                dcDataType.OQCT_DaCl__Custom_Length__c = 5;
            }
        }
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(dcDataTypes);
        Schema.DescribeFieldResult fieldResult =  Schema.Opportunity.Amount.getDescribe();
        Decimal input = 1024.58;
        
        Test.startTest();
        Decimal maskedValue = (Decimal)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getEncryptedValueTextyMatchObjectFieldLengthTest(){
		EncryptUtil.testDisplayType = Schema.Account.Name.getDescribe().getType();
        List<OQCT_DaCl__DC_Data_Type__c> dcDataTypes = DCDataTypeSelector.getDCDataType();
        for (OQCT_DaCl__DC_Data_Type__c dcDataType : dcDataTypes) {
            if (dcDataType.OQCT_DaCl__Data_Type_Name__c == Constants.DC_DATA_TYPE_TEXT) {
                dcDataType.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
                dcDataType.OQCT_DaCl__Match_Object_Field_Length__c = true;
            }
        }
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(dcDataTypes);
        Schema.DescribeFieldResult fieldResult =  Schema.Account.Name.getDescribe();
        String input = 'Test Account';
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getEncryptedValueTextCustomLengthTest(){
		EncryptUtil.testDisplayType = Schema.Account.Name.getDescribe().getType();
        List<OQCT_DaCl__DC_Data_Type__c> dcDataTypes = DCDataTypeSelector.getDCDataType();
        for (OQCT_DaCl__DC_Data_Type__c dcDataType : dcDataTypes) {
            if (dcDataType.OQCT_DaCl__Data_Type_Name__c == Constants.DC_DATA_TYPE_TEXT) {
                dcDataType.OQCT_DaCl__Match_Record_Original_Data_Length__c = false;
                dcDataType.OQCT_DaCl__Match_Object_Field_Length__c = false;
                dcDataType.OQCT_DaCl__Custom_Length__c = 5;
            }
        }
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(dcDataTypes);
        Schema.DescribeFieldResult fieldResult =  Schema.Account.Name.getDescribe();
        String input = 'Test Account';
        
        Test.startTest();
        String maskedValue = (String)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getEncryptedValueIntegerTest(){
		EncryptUtil.testDisplayType = Schema.Account.NumberOfEmployees.getDescribe().getType();
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.NumberOfEmployees.getDescribe();
        Integer input = 1024;
        
        Test.startTest();
        Integer maskedValue = (Integer)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getEncryptedValueLongTest(){
		EncryptUtil.testDisplayType = Schema.DisplayType.LONG;
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.NumberOfEmployees.getDescribe();
        Long input = 1024L;
        
        Test.startTest();
        Long maskedValue = (Long)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

    @IsTest
    private static void getEncryptedValueTimeTest(){
		EncryptUtil.testDisplayType = Schema.DisplayType.TIME;
        Map<String, EncryptUtil.DataTypeConfiguration> dataTypeName2dataTypeConfig = EncryptUtil.getDataTypesWithConfigurations(DCDataTypeSelector.getDCDataType());
        Schema.DescribeFieldResult fieldResult =  Schema.Account.NumberOfEmployees.getDescribe();
        Time input = DateUtils.getNow().time();
        
        Test.startTest();
        Time maskedValue = (Time)EncryptUtil.getEncryptedValue(input, fieldResult, dataTypeName2dataTypeConfig);
        Test.stopTest();

        System.assertNotEquals(maskedValue, input, 'Masked Value is same.');
    }

}