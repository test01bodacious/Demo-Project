/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-06   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DatabaseUtilsTest {
    
    @TestSetup
    private static void setupData(){

    }

    @IsTest
    private static void getErrorStringTest(){        
		Database.SaveResult saveResult = (Database.SaveResult) JSON.deserialize('{"success":false, "errors":[{"message":"Error occured","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.Class);
        List<Database.Error> errors = saveResult.getErrors(); 
        String errorString = 'FIELD_CUSTOM_VALIDATION_EXCEPTION: Error occured Fields that affected this error: ()';
        
        Test.startTest();
            String result = DatabaseUtils.getErrorString(errors);
        Test.stopTest();

        System.assertEquals(result.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), true, 'Error string is not matched with the given errors');        
    }
    
    @IsTest
    private static void insertRecordTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'test';
		        
        Test.startTest();
       	 	DatabaseUtils.insertRecords(objAccount);
        Test.stopTest();

        System.assertEquals(AccountSelector.getAllAccounts().size() > 0, true, 'Account record is not inserted.');        
    }
    
    @IsTest
    private static void insertRecordsTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'test';
		        
        Test.startTest();
        	DatabaseUtils.insertRecords(new List<Account> {objAccount});
        Test.stopTest();

        System.assertEquals(AccountSelector.getAllAccounts().size() > 0, true, 'Account record is not inserted.');        
    }
    
    @IsTest
    private static void insertRecordsForErrorTest(){        
		Account objAccount = new Account();
		        
        Test.startTest();
        	DatabaseUtils.insertRecords(new List<Account> {objAccount});
        Test.stopTest();

        System.assertEquals(AccountSelector.getAllAccounts().size() > 0, false, 'Account record is inserted.');        
    }    
    
    @IsTest
    private static void insertRecordsAndReturnSuccessRecordsIdsTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'Test';
		        
        Test.startTest();
        	Set<Id> idSet = DatabaseUtils.insertRecordsAndReturnSuccessRecordsIds(objAccount);
        Test.stopTest();

        System.assertEquals(idSet.size() > 0, true, 'Account record id is not returned.');        
    }
        
    @IsTest
    private static void insertRecordsAndReturnFailedRecordsErrorMessagesTest(){        
		Account objAccount = new Account();
		        
        Test.startTest();
      		List<String> errorMessage = DatabaseUtils.insertRecordsAndReturnFailedRecordsErrorMessages(objAccount);
        Test.stopTest();

        System.assertEquals(errorMessage[0], 'REQUIRED_FIELD_MISSING: Required fields are missing: [Name]', 'Account record id is not returned.');        
    }
    
    @IsTest
    private static void insertRecordsAndReturnSuccessRecordsIdsFailureTest(){        
		Account objAccount = new Account();		
        
        Test.startTest();
        	Set<Id> idSet = DatabaseUtils.insertRecordsAndReturnSuccessRecordsIds(objAccount);
        Test.stopTest();

        System.assertEquals(idSet.size() == 0, true, 'Account record id is returned.');        
    }

    @IsTest
    private static void updateRecordsTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'Test';
        DatabaseUtils.insertRecords(objAccount);
        objAccount = AccountSelector.getAllAccounts()[0];
		objAccount.Name = 'Test Updated';
        
        Test.startTest();
        	DatabaseUtils.updateRecords(objAccount);
        Test.stopTest();

        System.assertEquals(AccountSelector.getAllAccounts()[0].Name, 'Test Updated', 'Account name not updated.');        
    }    
    
    @IsTest
    private static void updateRecordsAndReturnFailedRecordsIdsTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'Test';
        DatabaseUtils.insertRecords(objAccount);
        objAccount = AccountSelector.getAllAccounts()[0];
		objAccount.Name = '';
        
        Test.startTest();
        	Set<Id> idSet = DatabaseUtils.updateRecordsAndReturnFailedRecordsIds(objAccount);
        Test.stopTest();

        System.assertEquals(idSet.size() > 0, true, 'Account name updated.');        
    } 
    
    @IsTest
    private static void updateRecordsAndReturnFailedRecordsIdWithErrorMessagesTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'Test';
        DatabaseUtils.insertRecords(objAccount);
        objAccount = AccountSelector.getAllAccounts()[0];
		objAccount.Name = '';
        
        Test.startTest();
        	Map<Id, String> errorMap = DatabaseUtils.updateRecordsAndReturnFailedRecordsIdWithErrorMessages(objAccount);
        Test.stopTest();

        System.assertEquals(errorMap.values()[0], 'REQUIRED_FIELD_MISSING: Required fields are missing: [Name]', 'Account name updated.');        
    }
    
    @IsTest
    private static void updateRecordsAndReturnDMLResultTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'Test';
        DatabaseUtils.insertRecords(objAccount);
        objAccount = AccountSelector.getAllAccounts()[0];
		objAccount.Name = 'Test Updated';
        
        Test.startTest();
        	DatabaseUtils.DMLResult result = DatabaseUtils.updateRecordsAndReturnDMLResult(objAccount);
        Test.stopTest();

        System.assertEquals(result.successIds.size() > 0, true, 'Account not name updated.');        
    }
    
    @IsTest
    private static void upsertRecordsTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'Test';
        DatabaseUtils.insertRecords(objAccount);
        objAccount = AccountSelector.getAllAccounts()[0];
		objAccount.Name = 'Test Updated';
        
        Test.startTest();
        	DatabaseUtils.upsertRecords(objAccount);
        Test.stopTest();

        System.assertEquals(AccountSelector.getAllAccounts()[0].Name, 'Test Updated', 'Account name not updated.');        
    }
    
    @IsTest
    private static void deleteRecordsTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'Test';
        DatabaseUtils.insertRecords(objAccount);
        
        Test.startTest();
        	DatabaseUtils.deleteRecords(objAccount);
        Test.stopTest();

        System.assertEquals(AccountSelector.getAllAccounts().size(), 0, 'Account name not deleted.');        
    }
    
    @IsTest
    private static void deleteRecordListTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'Test';
        DatabaseUtils.insertRecords(objAccount);
        
        Test.startTest();
        	DatabaseUtils.deleteRecords(new List<Account> {objAccount});
        Test.stopTest();

        System.assertEquals(AccountSelector.getAllAccounts().size(), 0, 'Account name not deleted.');        
    }
    
    //Getting Error??
    @IsTest
    private static void deleteRecordFroRecycleBinTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'Test';
        DatabaseUtils.insertRecords(objAccount);
        
        Test.startTest();
        	DatabaseUtils.deleteRecords(objAccount, true);
        Test.stopTest();

        System.assertEquals(AccountSelector.getAllAccounts().size(), 0, 'Account name not deleted.');        
    }
    
    @IsTest
    private static void deleteRecordsAndReturnDMLResultTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'Test';
        DatabaseUtils.insertRecords(objAccount);
        
        Test.startTest();
        	DatabaseUtils.DMLResult result = DatabaseUtils.deleteRecordsAndReturnDMLResult(objAccount);
        Test.stopTest();

        System.assertEquals(result.successIds.size() > 0, true, 'Account not name deleted.');        
    }
    
    @IsTest
    private static void undeleteRecordsTest(){        
		Account objAccount = new Account();
        objAccount.Name = 'Test';
        DatabaseUtils.insertRecords(objAccount);
        DatabaseUtils.deleteRecords(objAccount);
        
        Test.startTest();
        	DatabaseUtils.undeleteRecords(objAccount);
        Test.stopTest();

        System.assertEquals(AccountSelector.getAllAccounts().size() > 0, true, 'Account not name undeleted.');        
    }
}