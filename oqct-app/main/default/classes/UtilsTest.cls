/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-20
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-06   Krrish Joy   Initial Version
**/
@isTest
private with sharing class UtilsTest {

    @TestSetup
    private static void setupData(){
		DataFactory.initAccount();
    }

    @IsTest
    private static void isValidSalesforceIdTest(){        
		Account objAccount = AccountSelector.getAllAccounts()[0];
        
        Test.startTest();
            Boolean isValid = Utils.isValidSalesforceId(objAccount.Id, Account.Class);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Return value is false.');        
    }
    
    @IsTest
    private static void getLabelForObjectTest(){        
        
        Test.startTest();
            String description = Utils.getLabelForObject(Constants.OBJECT_ACCOUNT);
        Test.stopTest();

        System.assertEquals(Constants.OBJECT_ACCOUNT, description, 'Return value is false.');        
    }
    
    @IsTest
    private static void getLabelForFieldTest(){        
        
        Test.startTest();
            String description = Utils.getLabelForField(Constants.OBJECT_ACCOUNT, 'Name');
        Test.stopTest();

        System.assertEquals('Account Name', description, 'Return value is false.');        
    }
    
    @IsTest
    private static void extractIdsTest(){        
		Account objAccount = AccountSelector.getAllAccounts()[0];
        
        Test.startTest();
       	    Set<Id> idSet = Utils.extractIds(new List<Account>{objAccount});
        Test.stopTest();

        System.assertEquals(true, idSet.size() > 0, 'Return value is Blank.');        
    }
    
    @IsTest
    private static void extractIdsForFieldTest(){        
		Account objAccount = AccountSelector.getAllAccounts()[0];
        
        Test.startTest();
       	    Set<Id> idSet = Utils.extractIds(new List<Account>{objAccount}, Account.Id.getDescribe().getSObjectField());
        Test.stopTest();

        System.assertEquals(true, idSet.size() > 0, 'Return value is Blank.');        
    }
    
    @IsTest
    private static void convertSObjectFieldToStringTest(){        
        
        Test.startTest();
        	Set<String> idSet = Utils.convertSObjectFieldToString(new Set<Schema.SObjectField>{Account.Id.getDescribe().getSObjectField()});
        Test.stopTest();

        System.assertEquals(true, idSet.size() > 0, 'Return value is Blank.');        
    }
    
    @IsTest
    private static void getSObjectFieldTypeTest(){        
        
        Test.startTest();
        	Schema.SObjectField field = Utils.getSObjectFieldType(Constants.OBJECT_ACCOUNT, 'Name');
        Test.stopTest();

        System.assertEquals(true, field != null, 'Return value is Blank.');        
    }
    
    @IsTest
    private static void getFieldDisplayTypeTest(){        
        
        Test.startTest();
        	Schema.DisplayType field = Utils.getFieldDisplayType(Constants.OBJECT_ACCOUNT, 'Name');
        Test.stopTest();

        System.assertEquals(true, field != null, 'Return value is Blank.');        
    }
    
    @IsTest
    private static void filterFieldsForSObjectTest(){        
        
        Test.startTest();
        List<String> field = Utils.filterFieldsForSObject(Constants.OBJECT_ACCOUNT, new Set<String>{'Name'});
        Test.stopTest();

        System.assertEquals(true, field.size() > 0, 'Return value is Blank.');        
    }
    
    @IsTest
    private static void convertWhereInClauseFromListtoStringTest(){        
        
        Test.startTest();
        	String field = Utils.convertWhereInClauseFromListtoString(new List<String>{'Name'});
        Test.stopTest();

        System.assertEquals(true, field != null, 'Return value is Blank.');        
    }
    
    @IsTest
    private static void getRetryableDCStatusesTest(){        
        
        Test.startTest();
        	List<String> field = Utils.getRetryableDCStatuses();
        Test.stopTest();

        System.assertEquals(true, field.contains(Constants.DC_STATUS_PENDING), 'Return value is Blank.');        
    }
    
    @IsTest
    private static void getLookupFieldNameTest(){        
        
        Test.startTest();
        	String field = Utils.getLookupFieldName(Constants.OBJECT_ACCOUNT, Constants.OBJECT_CONTACT);
        Test.stopTest();

        System.assertEquals(field, 'AccountId', 'Return value is Blank.');        
    }
    
    @IsTest
    private static void isFieldHistoryEnabledTest(){        
        
        Test.startTest();
        	Boolean isEnabled = Utils.isFieldHistoryEnabled(Constants.OBJECT_ACCOUNT);
        Test.stopTest();

        System.assertEquals(true, isEnabled, 'Return value is false.');        
    }
    
    @IsTest
    private static void getMaskableFieldListTest(){        
        
        Test.startTest();
        	List<String> fields = Utils.getMaskableFieldList(Constants.OBJECT_ACCOUNT);
        Test.stopTest();

        System.assertEquals(true, fields.contains('name'), 'Return value not contains Name.');     
    }
    
    
    @IsTest
    private static void getObjectListAsOptionsTest(){        
        
        Test.startTest();
        	List<Utils.Options> fields = Utils.getObjectListAsOptions(Constants.DC_ACTION_MASKING_ONLY);
        Test.stopTest();

        System.assertEquals(true, fields.size() > 0, 'Return value size is zero.');        
    }
    
    @IsTest
    private static void getObjectListAsOptionsForMaskDeleteTest(){        
        
        Test.startTest();
        	List<Utils.Options> fields = Utils.getObjectListAsOptions(Constants.DC_ACTION_MASKING_DELETION);
        Test.stopTest();

        System.assertEquals(true, fields.size() > 0, 'Return value size is zero.');        
    }
    
    @IsTest
    private static void getFieldListAsOptionsTest(){        
        
        Test.startTest();
        	List<Utils.Options> fields = Utils.getFieldListAsOptions(Constants.OBJECT_ACCOUNT);
        Test.stopTest();

        System.assertEquals(true, fields.size() > 0, 'Return value size is zero.');        
    }
    
    @IsTest
    private static void getFieldsForBackupTest(){        
        
        Test.startTest();
        	List<String> fields = Utils.getFieldsForBackup(Constants.OBJECT_ACCOUNT);
        Test.stopTest();

        System.assertEquals(true, fields.size() > 0, 'Return value size is zero.');        
    }
    
    @IsTest
    private static void getMaskableFieldListAsOptionsTest(){        
        
        Test.startTest();
        	List<Utils.Options> fields = Utils.getMaskableFieldListAsOptions(Constants.OBJECT_ACCOUNT);
        Test.stopTest();

        System.assertEquals(true, fields.size() > 0, 'Return value size is zero.');        
    }
    
    @IsTest
    private static void getNillableFieldListAsOptionsTest(){        
        
        Test.startTest();
        	List<Utils.Options> fields = Utils.getNillableFieldListAsOptions(Constants.OBJECT_ACCOUNT);
        Test.stopTest();

        System.assertEquals(true, fields.size() > 0, 'Return value size is zero.');        
    }
    
    @IsTest
    private static void getPotentialExternalFieldListAsOptionsTest(){        
        
        Test.startTest();
        	List<Utils.Options> fields = Utils.getPotentialExternalFieldListAsOptions(Constants.OBJECT_ACCOUNT);
        Test.stopTest();

        System.assertEquals(true, fields.size() > 0, 'Return value size is zero.');        
    }
    
    @IsTest
    private static void getRecordTypeListAsOptionsTest(){        
        
        Test.startTest();
        	List<Utils.Options> fields = Utils.getRecordTypeListAsOptions(Constants.OBJECT_ACCOUNT);
        Test.stopTest();

        System.assertEquals(true, fields.size() > 0, 'Return value size is zero.');        
    }
    
    @IsTest
    private static void getRelatedObjectAsOptionsTest(){        
        
        Test.startTest();
        	List<Utils.Options> fields = Utils.getRelatedObjectAsOptions(Constants.OBJECT_ACCOUNT, true);
        Test.stopTest();

        System.assertEquals(true, fields.size() > 0, 'Return value size is zero.');        
    }
    
    @IsTest
    private static void getRelatedObjectAsOptionsForFalseTest(){        
        
        Test.startTest();
        	List<Utils.Options> fields = Utils.getRelatedObjectAsOptions(Constants.OBJECT_ACCOUNT, false);
        Test.stopTest();

        System.assertEquals(true, fields.size() > 0, 'Return value size is zero.');        
    }
    
    @IsTest
    private static void getUserEmailTest(){        
        
        Test.startTest();
        	String result = Utils.getUserEmail();
        Test.stopTest();

        System.assertEquals(true, result == UserInfo.getUserEmail(), 'Return value not a correct email.');        
    }
    
    @IsTest
    private static void getUserIdTest(){        
        
        Test.startTest();
        	String result = Utils.getUserId();
        Test.stopTest();

        System.assertEquals(true, result == UserInfo.getUserId(), 'Return value not a correct id.');        
    }
    
    @IsTest
    private static void getUserNameTest(){        
        
        Test.startTest();
        	String result = Utils.getUserName();
        Test.stopTest();

        System.assertEquals(true, result == UserInfo.getUserName(), 'Return value not a correct user name.');        
    }
    
    @IsTest
    private static void isMultiCurrencyOrganizationTest(){        
        
        Test.startTest();
        	Boolean result = Utils.isMultiCurrencyOrganization();
        Test.stopTest();

        System.assertEquals(true, result == UserInfo.isMultiCurrencyOrganization(), 'Return value not a correct boolean.');        
    }
  
    @IsTest
    private static void getUserTimeZoneTest(){        
        
        Test.startTest();
        	String result = Utils.getUserTimeZone();
        Test.stopTest();

        System.assertEquals(true, result == UserInfo.getTimeZone().toString(), 'Return value not a correct Time Zone.');        
    }
    
    @IsTest
    private static void getOrgTimeZoneTest(){        
        
        Test.startTest();
        	String result = Utils.getOrgTimeZone();
        Test.stopTest();

        System.assertEquals(true, result == OrganizationSelector.getOrganizationForTimeZone().TimeZoneSidKey, 'Return value not a correct Time Zone.');        
    }
}