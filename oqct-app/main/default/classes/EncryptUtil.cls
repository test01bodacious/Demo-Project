/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-26
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-07   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class EncryptUtil {
    
    @TestVisible private static Schema.DisplayType testDisplayType; // Will be supplied from test class

    @SuppressWarnings('PMD.CognitiveComplexity,PMD.NcssMethodCount')
    public static Object getEncryptedValue(Object value, Schema.DescribeFieldResult fieldDescription, Map<String, DataTypeConfiguration> dataTypeName2dataTypeConfig){

        Object maskedValue;
        
        Schema.DisplayType dataType = EncryptUtil.testDisplayType != null ? testDisplayType: fieldDescription.getType();

        DataTypeConfiguration dataTypeConfig;

        switch on dataType {

            when BOOLEAN {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_BOOLEAN_CHECKBOX);
                maskedValue = EncryptUtil.generateRandomBooleanValue(dataTypeConfig);
            }
            when CURRENCY {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_CURRENCY);
                maskedValue = (Decimal)EncryptUtil.generateRandomNumericValue(value, fieldDescription, dataTypeConfig);
            }
            when DATE {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_DATE);
                maskedValue = EncryptUtil.generateRandomDatetimeValue(dataTypeConfig).date();
            }
            when DATETIME {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_DATE_TIME);
                maskedValue = EncryptUtil.generateRandomDatetimeValue(dataTypeConfig);
            }
            when DOUBLE {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_NUMBER);
                maskedValue = (Double)EncryptUtil.generateRandomNumericValue(value, fieldDescription, dataTypeConfig);
            }
            when EMAIL {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_EMAIL);
                maskedValue = EncryptUtil.generateRandomEmailValue(dataTypeConfig);
            }
            when ENCRYPTEDSTRING {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_TEXT_ENCRYPTED);
                maskedValue = EncryptUtil.generateRandomTextValue(value, fieldDescription, dataTypeConfig);
            }
            when ID {
                maskedValue = null;
            }
            when INTEGER {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_NUMBER);
                maskedValue = (Integer)EncryptUtil.generateRandomNumericValue(value, fieldDescription, dataTypeConfig);
            }
            when LONG {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_NUMBER);
                maskedValue = (Long)EncryptUtil.generateRandomNumericValue(value, fieldDescription, dataTypeConfig);
            }
            when MULTIPICKLIST {
                if (!fieldDescription.isRestrictedPicklist()) {
                    dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_MULTIPICKLIST_UNRESTRICTIVE);
                    maskedValue = EncryptUtil.generateRandomTextValue(value, fieldDescription, dataTypeConfig);
                } else {
                    maskedValue = EncryptUtil.getRandomMultiPicklistValueForRestrictedPicklist(String.valueOf(value), fieldDescription);
                }
            }
            when PERCENT {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_PERCENT);
                maskedValue = (Decimal)EncryptUtil.generateRandomNumericValue(value, fieldDescription, dataTypeConfig);
            }
            when PHONE {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_PHONE);
                String phoneValue = String.valueOf(EncryptUtil.generateRandomNumericValue(value, fieldDescription, dataTypeConfig));
                if (phoneValue.length() > 1) {
                    phoneValue = String.valueOf(EncryptUtil.generateRandomNumberForGivenRange(7, 9)) + phoneValue.substring(1);
                }
                maskedValue = phoneValue;
            }
            when PICKLIST {
                if (!fieldDescription.isRestrictedPicklist()) {
                    dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_PICKLIST_UNRESTRICTIVE);
                    maskedValue = EncryptUtil.generateRandomTextValue(value, fieldDescription, dataTypeConfig);
                } else {
                    maskedValue = EncryptUtil.getRandomPicklistValueForRestrictedPicklist(String.valueOf(value), fieldDescription);
                }
            }
            when REFERENCE {
                maskedValue = null;
            }
            when STRING {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_TEXT);
                maskedValue = EncryptUtil.generateRandomTextValue(value, fieldDescription, dataTypeConfig);
            }
            when TEXTAREA {
                if (fieldDescription.getLength() <= 255) {
                    dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_TEXTAREA);
                    maskedValue = EncryptUtil.generateRandomTextValue(value, fieldDescription, dataTypeConfig);
                }else {
                    if (fieldDescription.isHtmlFormatted()) {
                        dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_TEXTAREA_RICH);
                        maskedValue = EncryptUtil.generateRandomTextValue(value, fieldDescription, dataTypeConfig);
                    }else {
                        dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_TEXTAREA_LONG);
                        maskedValue = EncryptUtil.generateRandomTextValue(value, fieldDescription, dataTypeConfig);
                    }
                }
            }
            when TIME {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_TIME);
                maskedValue = EncryptUtil.generateRandomDatetimeValue(dataTypeConfig).time();
            }
            when URL {
                dataTypeConfig = dataTypeName2dataTypeConfig.get(Constants.DC_DATA_TYPE_URL);
                maskedValue = EncryptUtil.generateRandomURLValue(dataTypeConfig);
            }
            when else {
                maskedValue = null;
            }
        }

        return maskedValue;
    }

    public static Map<String, DataTypeConfiguration> getDataTypesWithConfigurations(List<OQCT_DaCl__DC_Data_Type__c> dcDataTypes){
        Map<String, DataTypeConfiguration> dataTypeName2dataTypeConfig = new Map<String, DataTypeConfiguration>();
        for (OQCT_DaCl__DC_Data_Type__c dcDataType : dcDataTypes) {
            DataTypeConfiguration dataTypeConfig = new DataTypeConfiguration();
            dataTypeConfig.customLength = dcDataType.OQCT_DaCl__Custom_Length__c;
            dataTypeConfig.textMaskingOption = dcDataType.OQCT_DaCl__Text_Masking_Option__c;
            dataTypeConfig.matchObjectFieldLength = dcDataType.OQCT_DaCl__Match_Object_Field_Length__c;
            dataTypeConfig.matchRecordOriginalDataLength = dcDataType.OQCT_DaCl__Match_Record_Original_Data_Length__c;
            dataTypeConfig.valueType = dcDataType.OQCT_DaCl__Value_Type__c;
            dataTypeConfig.emailDomain = dcDataType.OQCT_DaCl__Email_Domain__c;
            dataTypeConfig.urlDomain = dcDataType.OQCT_DaCl__URL_Domain__c;
            dataTypeName2dataTypeConfig.put(dcDataType.OQCT_DaCl__Data_Type_Name__c, dataTypeConfig);
        }
        return dataTypeName2dataTypeConfig;
    }

    @TestVisible
    private static String getRandomPicklistValueForRestrictedPicklist(String value, Schema.DescribeFieldResult fieldDescription){
        List<String> picklistValues = EncryptUtil.getPicklistOptions(fieldDescription);
        if (!picklistValues.isEmpty()) {
            Integer index = (Integer)EncryptUtil.generateRandomNumberForGivenRange(0, picklistValues.size() - 1);
            String newValue = picklistValues[index];
            if (newValue.equals(value) && picklistValues.size() > 1) {
                if (index == 0) {
                    return picklistValues[index + 1];
                } else {
                    return picklistValues[index - 1];
                }
            } else {
                return newValue;
            }
        } else {
            return Constants.LITERAL_EMPTY;
        }
    }

    @TestVisible
    private static String getRandomMultiPicklistValueForRestrictedPicklist(String value, Schema.DescribeFieldResult fieldDescription){
        List<String> picklistValues = EncryptUtil.getPicklistOptions(fieldDescription);
        if (!picklistValues.isEmpty()) {
            StringBuilder mutiSelectPicklistValues = new StringBuilder();
            mutiSelectPicklistValues.setSeparator(Constants.LITERAL_SEMI_COLON);
            Integer valueCount = value.countMatches(Constants.LITERAL_SEMI_COLON) + 1;
            for (Integer i = 1; i <= valueCount; i++) {
                Integer index = (Integer)EncryptUtil.generateRandomNumberForGivenRange(0, picklistValues.size() - 1);
                mutiSelectPicklistValues.append(picklistValues[index]);
            }
            return mutiSelectPicklistValues.toString();
        } else {
            return Constants.LITERAL_EMPTY;
        }
    }

    private static List<String> getPicklistOptions(Schema.DescribeFieldResult fieldDescription){
        List<String> picklistValues = new List<String>();
        for (Schema.PicklistEntry picklistEntry : fieldDescription.getPicklistValues()) {
            picklistValues.add(picklistEntry.getLabel());
        }
        return picklistValues;
    }

    private static Boolean generateRandomBooleanValue(DataTypeConfiguration dataTypeConfig){
        return Math.random() < 0.5;
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    private static Decimal generateRandomNumericValue(Object value, Schema.DescribeFieldResult fieldDescription, DataTypeConfiguration dataTypeConfig){

        Long integerPart;
        Long fractionalPart;

        if (fieldDescription.getType() == DisplayType.DOUBLE &&
            (fieldDescription.getName().endsWithIgnoreCase(Constants.LATITUDE_SUFFIX) ||
                fieldDescription.getName().endsWithIgnoreCase(Constants.LONGITUDE_SUFFIX))) {
            if (fieldDescription.getName().endsWithIgnoreCase(Constants.LATITUDE_SUFFIX)) {
                integerPart = EncryptUtil.generateRandomNumberForGivenRange(-89, 89); 
                fractionalPart = EncryptUtil.generateRandomNumberForGivenLength(2);
            } else if (fieldDescription.getName().endsWithIgnoreCase(Constants.LONGITUDE_SUFFIX)) {
                integerPart = EncryptUtil.generateRandomNumberForGivenRange(-179, 179);
                fractionalPart = EncryptUtil.generateRandomNumberForGivenLength(2);
            }
        }else {
            Integer integerPartLength;
            Integer fractionalPartLength;
            if (dataTypeConfig.matchRecordOriginalDataLength) {
                if (String.valueOf(value).contains(Constants.LITERAL_DOT)) {
                    List<String> valueSplit = String.valueOf(value).split(Constants.ESCAPED_LITERAL_DOT);
                    integerPartLength = valueSplit[0].length();
                    fractionalPartLength = valueSplit[1].length();
                } else {
                    integerPartLength = String.valueOf(value).length();
                }
            } else if (dataTypeConfig.matchObjectFieldLength) {
                integerPartLength = fieldDescription.getPrecision() - fieldDescription.getScale();
                fractionalPartLength = fieldDescription.getScale();
                if (integerPartLength == 0 && fractionalPartLength == 0) {
                    integerPartLength = 5;
                }
            } else {
                integerPartLength = (Integer)dataTypeConfig.customLength;
            }

            if (integerPartLength >= 10 && fieldDescription.getType() == DisplayType.INTEGER) {
                integerPart = EncryptUtil.generateRandomNumberForGivenRange(1000000000, 2147483647);
            } else {
                integerPart = EncryptUtil.generateRandomNumberForGivenLength(integerPartLength);
            }

            if (fractionalPartLength != null) {
                fractionalPart = EncryptUtil.generateRandomNumberForGivenLength(fractionalPartLength);
            }
        }

        if (fractionalPart == null) {
            return Decimal.valueOf(integerPart);
        } else {
            return Decimal.valueOf(String.valueOf(integerPart) + Constants.LITERAL_DOT + String.valueOf(fractionalPart));
        }
    }

    private static String generateRandomTextValue(Object value, Schema.DescribeFieldResult fieldDescription, DataTypeConfiguration dataTypeConfig){
        Long length = 0;
        if (dataTypeConfig.matchRecordOriginalDataLength) {
            length = String.valueOf(value).length();
        } else if (dataTypeConfig.matchObjectFieldLength) {
            length = fieldDescription.getLength();
        } else {
            length = (Long)dataTypeConfig.customLength;
        }
        if (length > Constants.DC_DATA_TYPE_MASK_MAX_CHARACTER_LENGTH) {
            length = Constants.DC_DATA_TYPE_MASK_MAX_CHARACTER_LENGTH;
        }
        return EncryptUtil.generateRandomTextForGivenLengthAndPattern(length, dataTypeConfig.textMaskingOption);
    }

    private static Datetime generateRandomDatetimeValue(DataTypeConfiguration dataTypeConfig){
        Datetime randomDatetime = DateUtils.getNow();
        if (dataTypeConfig.valueType == Constants.MASK_VALUE_TYPE_FUTURE_DATE || dataTypeConfig.valueType == Constants.MASK_VALUE_TYPE_FUTURE_DATE_TIME) {
            randomDatetime = randomDatetime.addDays((Integer)EncryptUtil.generateRandomNumberForGivenRange(1, 50));
            randomDatetime = randomDatetime.addMonths((Integer)EncryptUtil.generateRandomNumberForGivenRange(1, 40));
            randomDatetime = randomDatetime.addYears((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, 3));
            randomDatetime = randomDatetime.addHours((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, 59));
            randomDatetime = randomDatetime.addMinutes((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, 59));
            randomDatetime = randomDatetime.addSeconds((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, 59));
        } else if (dataTypeConfig.valueType == Constants.MASK_VALUE_TYPE_PAST_DATE || dataTypeConfig.valueType == Constants.MASK_VALUE_TYPE_PAST_DATE_TIME) {
            randomDatetime = randomDatetime.addDays((Integer)EncryptUtil.generateRandomNumberForGivenRange(-1, -50));
            randomDatetime = randomDatetime.addMonths((Integer)EncryptUtil.generateRandomNumberForGivenRange(-1, -40));
            randomDatetime = randomDatetime.addYears((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, -3));
            randomDatetime = randomDatetime.addHours((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, -59));
            randomDatetime = randomDatetime.addMinutes((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, -59));
            randomDatetime = randomDatetime.addSeconds((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, -59));
        } else {
            if (EncryptUtil.generateRandomBooleanValue(dataTypeConfig)) {
                randomDatetime = randomDatetime.addDays((Integer)EncryptUtil.generateRandomNumberForGivenRange(-1, -50));
                randomDatetime = randomDatetime.addMonths((Integer)EncryptUtil.generateRandomNumberForGivenRange(-1, -40));
                randomDatetime = randomDatetime.addYears((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, -3));
                randomDatetime = randomDatetime.addHours((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, -59));
                randomDatetime = randomDatetime.addMinutes((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, -59));
                randomDatetime = randomDatetime.addSeconds((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, -59));
            } else {
                randomDatetime = randomDatetime.addDays((Integer)EncryptUtil.generateRandomNumberForGivenRange(1, 50));
                randomDatetime = randomDatetime.addMonths((Integer)EncryptUtil.generateRandomNumberForGivenRange(1, 40));
                randomDatetime = randomDatetime.addYears((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, 3));
                randomDatetime = randomDatetime.addHours((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, 59));
                randomDatetime = randomDatetime.addMinutes((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, 59));
                randomDatetime = randomDatetime.addSeconds((Integer)EncryptUtil.generateRandomNumberForGivenRange(0, 59));
            }
        }
        return randomDatetime;
    }

    private static String generateRandomEmailValue(DataTypeConfiguration dataTypeConfig){
        List<String> emailValueParams = new List<String>();
        emailValueParams.add(EncryptUtil.generateRandomAlphabetsLowerCaseOnly((Long)dataTypeConfig.customLength));
        emailValueParams.add(dataTypeConfig.emailDomain);
        return String.format(Constants.DC_DATA_TYPE_EMAIL_VALUE, emailValueParams);
    }

    private static String generateRandomURLValue(DataTypeConfiguration dataTypeConfig){
        List<String> urlValueParams = new List<String>();
        urlValueParams.add(EncryptUtil.generateRandomAlphabetsLowerCaseOnly((Long)dataTypeConfig.customLength));
        urlValueParams.add(dataTypeConfig.urlDomain);
        return String.format(Constants.DC_DATA_TYPE_URL_VALUE, urlValueParams);
    }

    // Helper Methods

    private static Long generateRandomNumberForGivenRange(Long minValue, Long maxValue){
        return minValue + (Long)(Math.random() * ((maxValue - minValue) + 1));
    }

    private static Long generateRandomNumberForGivenLength(Integer length){
        if (length > 18) {
            length = 18;
        }
        String str = String.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, length);
        return Long.valueOf(randomNumber);
    }

    private static String generateRandomTextForGivenLengthAndPattern(Long length, String pattern){
        if (pattern == Constants.MASK_PATTERN_ALPHABETS_LOWER_CASE_ONLY) {
            return EncryptUtil.generateRandomAlphabetsLowerCaseOnly(length);
        } else if (pattern == Constants.MASK_PATTERN_ALPHABETS_UPPER_CASE_ONLY) {
            return EncryptUtil.generateRandomAlphabetsUpperCaseOnly(length);
        } else if (pattern == Constants.MASK_PATTERN_ALPHABETS_LOWER_CASE_UPPER_CASE) {
            return EncryptUtil.generateRandomAlphabetsLowerAndUpperCase(length);
        } else if (pattern == Constants.MASK_PATTERN_ALPHA_NUMBERIC_LOWER_CASE_ONLY) {
            return EncryptUtil.generateRandomAlphaNumericLowerCaseOnly(length);
        } else if (pattern == Constants.MASK_PATTERN_ALPHA_NUMBERIC_UPPER_CASE_ONLY) {
            return EncryptUtil.generateRandomAlphaNumericUpperCaseOnly(length);
        } else if (pattern == Constants.MASK_PATTERN_ALPHA_NUMBERIC_LOWER_CASE_UPPER_CASE) {
            return EncryptUtil.generateRandomAlphaNumericLowerAndUpperCase(length);
        } else if (pattern == Constants.MASK_PATTERN_ALPHA_NUMBERIC_WITH_SPECIAL_CHARACTER) {
            return EncryptUtil.generateRandomAlphaNumericWithSpecialCharacter(length);
        }
        return null;
    }

    private static String generateRandomAlphabetsLowerCaseOnly(Long length){
        final String chars = 'abcdefghijklmnopqrstuvwxyz';
        return EncryptUtil.generateRandomStringForGivenLengthAndGivenCharacterSet(chars, length);
    }

    private static String generateRandomAlphabetsUpperCaseOnly(Long length){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        return EncryptUtil.generateRandomStringForGivenLengthAndGivenCharacterSet(chars, length);
    }

    private static String generateRandomAlphabetsLowerAndUpperCase(Long length){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        return EncryptUtil.generateRandomStringForGivenLengthAndGivenCharacterSet(chars, length);
    }

    private static String generateRandomAlphaNumericLowerCaseOnly(Long length){
        final String chars = '0123456789abcdefghijklmnopqrstuvwxyz';
        return EncryptUtil.generateRandomStringForGivenLengthAndGivenCharacterSet(chars, length);
    }

    private static String generateRandomAlphaNumericUpperCaseOnly(Long length){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        return EncryptUtil.generateRandomStringForGivenLengthAndGivenCharacterSet(chars, length);
    }

    private static String generateRandomAlphaNumericLowerAndUpperCase(Long length){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        return EncryptUtil.generateRandomStringForGivenLengthAndGivenCharacterSet(chars, length);
    }

    private static String generateRandomAlphaNumericWithSpecialCharacter(Long length){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz!@#$%^&*';
        return EncryptUtil.generateRandomStringForGivenLengthAndGivenCharacterSet(chars, length);
    }

    public static String generateRandomStringForGivenLengthAndGivenCharacterSet(String chars, Long length){
        if (length > 255) {
            chars += Constants.LITERAL_SPACE.repeat(10);
        }
        String randStr = '';
        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr.normalizeSpace();
    }

    public with sharing class DataTypeConfiguration{
            
            public Decimal customLength;

            public String textMaskingOption;

            public Boolean matchObjectFieldLength;

            public Boolean matchRecordOriginalDataLength;

            public String valueType;

            public String emailDomain;

            public String urlDomain;

    }
}