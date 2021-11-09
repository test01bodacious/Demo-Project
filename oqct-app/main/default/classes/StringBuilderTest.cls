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
private  with sharing class StringBuilderTest {

    private static StringBuilder objStringBuilder = new StringBuilder();

    @IsTest
    private static void stringBuilderBaseTest(){        
        Object stringValue = 'String';
        StringBuilder newStringBuilder = new StringBuilder(stringValue);
        
        Test.startTest();
            objStringBuilder = objStringBuilder.append(stringValue);
        Test.stopTest();

        System.assertEquals(objStringBuilder.toString(), 'String', 'Return value should containf String value.');        
    }
    
    @IsTest
    private static void appendForObjectInputTest(){        
        Object objString = 'String';
        
        Test.startTest();
            objStringBuilder = objStringBuilder.append(objString);
        Test.stopTest();

        System.assertEquals(objStringBuilder.toString(), 'String', 'Return value should containf String value.');        
    }
    
	@isTest
    private static void appendForStringInputTest(){        
        
        Test.startTest();
            objStringBuilder = objStringBuilder.append('String');
        Test.stopTest();

        System.assertEquals(objStringBuilder.toString(), 'String', 'Return value should containf String value.');        
    }
    
	@isTest
    private static void appendForStringBuilderInputTest(){        
        objStringBuilder = objStringBuilder.append('String');
        
        Test.startTest();
            objStringBuilder = objStringBuilder.append(objStringBuilder);
        Test.stopTest();

        System.assertEquals(objStringBuilder.toString(), 'StringString', 'Return value should containf String value.');        
    }
    
	@isTest
    private static void setSeparatorTest(){        
        
        Test.startTest();
            objStringBuilder.setSeparator(',');
        Test.stopTest();

        System.assertEquals(objStringBuilder.separator, ',', 'Separator value should return.');        
    }
   
	@isTest
    private static void capacityTest(){        
        objStringBuilder = objStringBuilder.append('String');
        
        Test.startTest();
            Integer capacity = objStringBuilder.capacity();
        Test.stopTest();

        System.assertEquals(capacity > 0, true, 'Capacity should not be zero');        
    }
    
	@isTest
    private static void capacityForBlankStringBuilderTest(){        
        
        Test.startTest();
            Integer capacity = objStringBuilder.capacity();
        Test.stopTest();

        System.assertEquals(capacity, 0, 'Capacity should be zero');        
    }
    
	@isTest
    private static void lengthTest(){        
        objStringBuilder.append('String');
        
        Test.startTest();
            Integer length = objStringBuilder.length();
        Test.stopTest();

        System.assertEquals(length, 6, 'Length should not be zero.');        
    }
    
	@isTest
    private static void toStringTest(){        
        objStringBuilder.append('String');
        
        Test.startTest();
            String result = objStringBuilder.toString();
        Test.stopTest();

        System.assertEquals(result, 'String', 'Rssult should contains String value.');        
    }
}