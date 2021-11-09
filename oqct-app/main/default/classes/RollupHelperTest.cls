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
private with sharing class RollupHelperTest {
    public static String resultId;
    
    @TestSetup
    private static void setupData(){
        DataFactory.initDataCleanAppConfigurations();
        DataFactory.initDcDataTypes();
        OQCT_DaCl__DC_Configuration__c dcConfig = DataFactory.initDcConfiguration();
        OQCT_DaCl__DC_Configuration__c dcConfigNew = DataFactory.initDcConfiguration();
        List<OQCT_DaCl__Related_Object__c> relatedObjects = DataFactory.initRelatedObjectsFromDcConfig(dcConfig);
        DataFactory.initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(dcConfig, relatedObjects);
        DataFactory.initDataCleansFromDcConfig(dcConfig.Id);
        
		List<OQCT_DaCl__Related_Object__c> relatedObjectsNew = DataFactory.initRelatedObjectsFromDcConfig(dcConfigNew);
        DataFactory.initRecordTypesAndFieldsFromDcConfigAndRelatedObjects(dcConfigNew, relatedObjectsNew);
        DataFactory.initDataCleansFromDcConfig(dcConfigNew.Id);
    }
    
    @IsTest
    private static void rollupFiledIncreaseOnInsertionTest(){      
        List<OQCT_DaCl__DC_Configuration__c> parentObject = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c resultObj = DataFactory.initResultRecords(parentObject[0].Id);
        DataFactory.initContentVersion(resultObj.Id);
        resultId = resultObj.Id;
        
        List<OQCT_DaCl__DC_Result__c> results = DCResultSelector.getAllDcResults();
        OQCT_DaCl__DC_Result__c resultForAsserssion = new OQCT_DaCl__DC_Result__c();
        for(OQCT_DaCl__DC_Result__c result : results) {
            if(result.Id == resultId) {
                resultForAsserssion = result;    
            }
        }
 		System.assertEquals(1, resultForAsserssion.OQCT_DaCl__Total_File_Count__c, 'File count not equals to one.');
        System.assertNotEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Size_Bytes__c, 'File should not be 0.');
        
        Test.startTest();
			DataFactory.initContentVersion(resultForAsserssion.Id);
        Test.stopTest();
        
        results = DCResultSelector.getAllDcResults();
        resultForAsserssion = new OQCT_DaCl__DC_Result__c();		
        for(OQCT_DaCl__DC_Result__c result : results) {
            if(result.Id == resultId) {
                resultForAsserssion = result;    
            }
        }
 		System.assertEquals(2, resultForAsserssion.OQCT_DaCl__Total_File_Count__c, 'File count not equals to two.');
        System.assertNotEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Size_Bytes__c, 'File size should not be zero.');
    }
    
    @IsTest
    private static void rollupFieldOnContentDocumentDeleteTest(){        
        List<OQCT_DaCl__DC_Configuration__c> parentObject = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c resultObj = DataFactory.initResultRecords(parentObject[0].Id);
        DataFactory.initContentVersion(resultObj.Id);
        resultId = resultObj.Id;
        
        List<OQCT_DaCl__DC_Result__c> results = DCResultSelector.getAllDcResults();
        OQCT_DaCl__DC_Result__c resultForAsserssion = new OQCT_DaCl__DC_Result__c();
        for(OQCT_DaCl__DC_Result__c result : results) {
            if(result.Id == resultId) {
                resultForAsserssion = result;    
            }
        }
 		System.assertEquals(1, resultForAsserssion.OQCT_DaCl__Total_File_Count__c, 'File count not equals to one.');
        System.assertNotEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Size_Bytes__c, 'File should not be 0.');
		ContentVersion objVersion = ContentVersionSelector.getAllContentVersion()[0];
        List<ContentDocument> objdocument = ContentDocumentSelector.getContentDocumentsByIds(new Set<Id>{objVersion.ContentDocumentId});
        
        Test.startTest();
			DatabaseUtils.deleteRecords(objDocument);
        Test.stopTest();
        
        results = DCResultSelector.getAllDcResults();
        resultForAsserssion = new OQCT_DaCl__DC_Result__c();
        for(OQCT_DaCl__DC_Result__c result : results) {
            if(result.Id == resultId) {
                resultForAsserssion = result;    
            }
        }            
 		System.assertEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Count__c, 'File count not equals to one.');
        System.assertEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Size_Bytes__c, 'File size should not be zero.');
    }
    
    @IsTest
    private static void rollupFieldOnContentDocumentLinkDeleteTest(){        
        List<OQCT_DaCl__DC_Configuration__c> parentObject = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c resultObj = DataFactory.initResultRecords(parentObject[0].Id);
        List<ContentVersion> cvList = ContentVersionSelector.getAllContentVersion();
        DatabaseUtils.deleteRecords(cvList);
        DataFactory.initContentVersion(resultObj.Id);
        resultId = resultObj.Id;
        
        List<OQCT_DaCl__DC_Result__c> results = DCResultSelector.getAllDcResults();
        OQCT_DaCl__DC_Result__c resultForAsserssion = new OQCT_DaCl__DC_Result__c();
        for(OQCT_DaCl__DC_Result__c result : results) {
            if(result.Id == resultId) {
                resultForAsserssion = result;    
            }
        }
 		System.assertEquals(1, resultForAsserssion.OQCT_DaCl__Total_File_Count__c, 'File count not equals to one.');
        System.assertNotEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Size_Bytes__c, 'File should not be 0.');
        ContentVersion objVersion = ContentVersionSelector.getAllContentVersion()[0];
        ContentDocument objdocument = ContentDocumentSelector.getContentDocumentLinkByContentDocumentId(objVersion.ContentDocumentId);
        List<ContentDocumentLink> linkList = objDocument.ContentDocumentLinks;
        
        Test.startTest();
			DatabaseUtils.deleteRecords(linkList);
        Test.stopTest();
        
        results = DCResultSelector.getAllDcResults();
        resultForAsserssion = new OQCT_DaCl__DC_Result__c();
        for(OQCT_DaCl__DC_Result__c result : results) {
            if(result.Id == resultId) {
                resultForAsserssion = result;    
            }
        }            
 		System.assertEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Count__c, 'File count not equals to zero.');
        System.assertEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Size_Bytes__c, 'File size should not be zero.');
    }
    
    @IsTest
    private static void rollupFieldOnContentDocumentUnDeleteTest(){        
        List<OQCT_DaCl__DC_Configuration__c> parentObject = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c resultObj = DataFactory.initResultRecords(parentObject[0].Id);
        DataFactory.initContentVersion(resultObj.Id);
        resultId = resultObj.Id;
        
        List<OQCT_DaCl__DC_Result__c> results = DCResultSelector.getAllDcResults();
        OQCT_DaCl__DC_Result__c resultForAsserssion = new OQCT_DaCl__DC_Result__c();
        for(OQCT_DaCl__DC_Result__c result : results) {
            if(result.Id == resultId) {
                resultForAsserssion = result;    
            }
        }
 		System.assertEquals(1, resultForAsserssion.OQCT_DaCl__Total_File_Count__c, 'File count not equals to one.');
        System.assertNotEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Size_Bytes__c, 'File should not be zero.');
		ContentVersion objVersion = ContentVersionSelector.getAllContentVersion()[0];
        List<ContentDocument> objdocument = ContentDocumentSelector.getContentDocumentsByIds(new Set<Id>{objVersion.ContentDocumentId});
        DatabaseUtils.deleteRecords(objDocument);
        
        Test.startTest();
			DatabaseUtils.unDeleteRecords(objDocument);
        Test.stopTest();
        
        results = DCResultSelector.getAllDcResults();
        resultForAsserssion = new OQCT_DaCl__DC_Result__c();
        for(OQCT_DaCl__DC_Result__c result : results) {
            if(result.Id == resultId) {
                resultForAsserssion = result;    
            }
        }            
 		System.assertEquals(1, resultForAsserssion.OQCT_DaCl__Total_File_Count__c, 'File count not equals to one.');
        System.assertNotEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Size_Bytes__c, 'File size should not be zero.');
    }
    
    @IsTest
    private static void rollupFieldOnContentDocumentUpdateTest(){        
        List<OQCT_DaCl__DC_Configuration__c> parentObject = DCConfigurationSelector.getAllDCConfigurations();
        OQCT_DaCl__DC_Result__c resultObj = DataFactory.initResultRecords(parentObject[0].Id);
        DataFactory.initContentVersion(resultObj.Id);
        resultId = resultObj.Id;
        
        List<OQCT_DaCl__DC_Result__c> results = DCResultSelector.getAllDcResults();
        OQCT_DaCl__DC_Result__c resultForAsserssion = new OQCT_DaCl__DC_Result__c();
        for(OQCT_DaCl__DC_Result__c result : results) {
            if(result.Id == resultId) {
                resultForAsserssion = result;    
            }
        }
 		System.assertEquals(1, resultForAsserssion.OQCT_DaCl__Total_File_Count__c, 'File count not equals to one.');
        System.assertNotEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Size_Bytes__c, 'File should not be zero.');
		ContentVersion objVersion = ContentVersionSelector.getAllContentVersion()[0];
        List<ContentDocument> objdocument = ContentDocumentSelector.getContentDocumentsByIds(new Set<Id>{objVersion.ContentDocumentId});
		objdocument[0].Description = 'Description Update';		
        
        Test.startTest();
			DatabaseUtils.updateRecords(objDocument);
        Test.stopTest();
        
        results = DCResultSelector.getAllDcResults();
        resultForAsserssion = new OQCT_DaCl__DC_Result__c();
        for(OQCT_DaCl__DC_Result__c result : results) {
            if(result.Id == resultId) {
                resultForAsserssion = result;    
            }
        }            
 		System.assertEquals(1, resultForAsserssion.OQCT_DaCl__Total_File_Count__c, 'File count should be one.');
        System.assertNotEquals(0, resultForAsserssion.OQCT_DaCl__Total_File_Size_Bytes__c, 'File size should be zero.');
    }
    
    @IsTest
    private static void rollupFieldOnChangeChildParentTest(){   
		List<OQCT_DaCl__DC_Configuration__c> parentObject = DCConfigurationSelector.getAllDCConfigurations();
        List<OQCT_DaCl__Data_Clean__c> dataCleanList = DataCleanSelector.getAllDataCleans();
        Id configOne = parentObject[0].Id;
        Id configTwo = parentObject[1].Id;
        
        System.assertEquals(2, parentObject[0].OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
        System.assertEquals(2, parentObject[1].OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
		List<OQCT_DaCl__Data_Clean__c> dataCleanListToUpdate = new List<OQCT_DaCl__Data_Clean__c>();
        for(OQCT_DaCl__Data_Clean__c dataClean : dataCleanList) {
            if(dataClean.OQCT_DaCl__DC_Configuration__c != configOne) {
            	dataClean.OQCT_DaCl__DC_Configuration__c = configOne;
            	dataCleanListToUpdate.add(dataClean);
            }
            
        }
        
        Test.startTest();
			DatabaseUtils.updateRecords(dataCleanListToUpdate);
        Test.stopTest();
		
        OQCT_DaCl__DC_Configuration__c parentObjectOne = DCConfigurationSelector.getDCConfigurationNameById(configOne);
        OQCT_DaCl__DC_Configuration__c parentObjectTwo = DCConfigurationSelector.getDCConfigurationNameById(configTwo);
        
        System.assertEquals(2, parentObjectOne.OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
        System.assertEquals(2, parentObjectTwo.OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not zero.');
    }
    
    @IsTest
    private static void rollupFieldOnChangeParentNullOnChildTest(){        
		List<OQCT_DaCl__DC_Configuration__c> parentObject = DCConfigurationSelector.getAllDCConfigurations();
        List<OQCT_DaCl__Data_Clean__c> dataCleanList = DataCleanSelector.getAllDataCleans();
        Id configOne = parentObject[0].Id;
        Id configTwo = parentObject[1].Id;
        
        System.assertEquals(2, parentObject[0].OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
        System.assertEquals(2, parentObject[1].OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
		List<OQCT_DaCl__Data_Clean__c> dataCleanListToUpdate = new List<OQCT_DaCl__Data_Clean__c>();
        for(OQCT_DaCl__Data_Clean__c dataClean : dataCleanList) {
            if(dataClean.OQCT_DaCl__DC_Configuration__c != configOne) {
            	dataClean.OQCT_DaCl__DC_Configuration__c = null;
            	dataCleanListToUpdate.add(dataClean);
            }
            
        }
        
        Test.startTest();
			DatabaseUtils.updateRecords(dataCleanListToUpdate);
        Test.stopTest();
		
        OQCT_DaCl__DC_Configuration__c parentObjectOne = DCConfigurationSelector.getDCConfigurationNameById(configOne);
        OQCT_DaCl__DC_Configuration__c parentObjectTwo = DCConfigurationSelector.getDCConfigurationNameById(configTwo);
        
        System.assertEquals(2, parentObjectOne.OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
        System.assertEquals(2, parentObjectTwo.OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
    }
    
    @IsTest
    private static void rollupFieldOnChangeAllParentNullTest(){        
		List<OQCT_DaCl__DC_Configuration__c> parentObject = DCConfigurationSelector.getAllDCConfigurations();
        List<OQCT_DaCl__Data_Clean__c> dataCleanList = DataCleanSelector.getAllDataCleans();
        Id configOne = parentObject[0].Id;
        Id configTwo = parentObject[1].Id;
        
        System.assertEquals(2, parentObject[0].OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
        System.assertEquals(2, parentObject[1].OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
		List<OQCT_DaCl__Data_Clean__c> dataCleanListToUpdate = new List<OQCT_DaCl__Data_Clean__c>();
        for(OQCT_DaCl__Data_Clean__c dataClean : dataCleanList) {
        	dataClean.OQCT_DaCl__DC_Configuration__c = null;    
        	dataCleanListToUpdate.add(dataClean);
        }
        DatabaseUtils.updateRecords(dataCleanListToUpdate);
        OQCT_DaCl__DC_Configuration__c parentObjectOne = DCConfigurationSelector.getDCConfigurationNameById(configOne);
        OQCT_DaCl__DC_Configuration__c parentObjectTwo = DCConfigurationSelector.getDCConfigurationNameById(configTwo);
        System.assertEquals(2, parentObjectOne.OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
        System.assertEquals(2, parentObjectTwo.OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
        
        for(OQCT_DaCl__Data_Clean__c dataClean : dataCleanList) {
        	dataClean.OQCT_DaCl__DC_Configuration__c = configTwo;
        }
        Test.startTest();
			DatabaseUtils.updateRecords(dataCleanList);
        Test.stopTest();
		

        parentObjectOne = DCConfigurationSelector.getDCConfigurationNameById(configOne);
        parentObjectTwo = DCConfigurationSelector.getDCConfigurationNameById(configTwo);        
        System.assertEquals(2, parentObjectOne.OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not zero.');
        System.assertEquals(2, parentObjectTwo.OQCT_DaCl__Total_Data_Cleans__c, 'Data clean object is not two.');
    }
        
}