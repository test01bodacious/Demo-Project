/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-22
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-02   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class EmailUtilsTest {

    private final static String TEST_EMAIL_ADDRESS = 'test@oqct.com';
    private final static String TEST_EMAIL_SUBJECT = 'Test Subject';
    private final static String TEST_EMAIL_PLAIN_TEXT_BODY = 'Test Plain Text Body';
    private final static String TEST_EMAIL_HTML_BODY = 'Test <b>HTML</b> Body';
    private final static String EXPECTED_HTML_UNORDERED_LIST = '<ul><li>Test</li></ul>';
    private final static String EMAIL_TEMPLATE_DEVELOPER_NAME = 'Test_Email_Template';
    private final static String FILE_PATH_ON_CLIENT = 'Test File.txt';
    
    @TestSetup
    private static void setupData(){
        // Standard Objects
        DataFactory.initEmailTemplate(EMAIL_TEMPLATE_DEVELOPER_NAME);
        DataFactory.initContentVersion(FILE_PATH_ON_CLIENT);
        DataFactory.initAccount();

        // Custom Objects - Data Clean App
        DataFactory.initDcConfiguration();
    }

    private static EmailUtils.EmailParameters getEmailParameters(){
        EmailUtils.EmailParameters emailParams = new EmailUtils.EmailParameters();
        emailParams.toAddresses = new List<String>{TEST_EMAIL_ADDRESS};
        emailParams.toAddress = TEST_EMAIL_ADDRESS;
        emailParams.bccAddresses = new List<String>{TEST_EMAIL_ADDRESS};
        emailParams.bccAddress = TEST_EMAIL_ADDRESS;
        emailParams.ccAddresses = new List<String>{TEST_EMAIL_ADDRESS};
        emailParams.ccAddress = TEST_EMAIL_ADDRESS;
        emailParams.subject = TEST_EMAIL_SUBJECT;
        emailParams.plainTextBody = TEST_EMAIL_PLAIN_TEXT_BODY;
        emailParams.htmlBody = TEST_EMAIL_HTML_BODY;
        // emailParams.templateId = '';
        // emailParams.whatId = '';
        // emailParams.entityAttachments = new List<String>();
        // emailParams.emailPriority = '';
        // emailParams.saveAsActivity = false;
        // emailParams.replyTo = '';
        // emailParams.senderDisplayName = '';
        return emailParams;
    }

    @IsTest
    private static void sendEmailTestBulkEmailAddresses(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.toAddresses = null;
        emailParams.bccAddresses = null;
        emailParams.ccAddresses = null;
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'Email was not send');
    }

    @IsTest
    private static void sendEmailTestSingleEmailAddress(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.toAddress = null;
        emailParams.bccAddress = null;
        emailParams.ccAddress = null;
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'Email was not send');
    }

    @IsTest
    private static void sendEmailTestSingleEmailAddressErrorEmail(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.toAddress = null;
        emailParams.bccAddress = null;
        emailParams.ccAddress = null;
        emailParams.isErrorEmail = true;
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'Email was not send');
    }

    @IsTest
    private static void sendEmailTestSingleEmailAddressWithGlobalConfigEmail(){

        DataFactory.initDataCleanAppConfigurations();

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.toAddress = null;
        emailParams.bccAddress = null;
        emailParams.ccAddress = null;
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'Email was not send');
    }

    @IsTest
    private static void sendEmailTestNoToAddress(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.toAddresses = null;
        emailParams.toAddress = null;
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'Email was not send');
    }

    @IsTest
    private static void sendEmailTestTemplate(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.htmlBody = null;
        emailParams.plainTextBody = null;
        emailParams.templateId = EmailTemplateSelector.getEmailTemplateByDeveloperName(EMAIL_TEMPLATE_DEVELOPER_NAME).Id;
        emailParams.whatId = AccountSelector.getAllAccounts()[0].Id;
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'Email was not send');
    }

    @IsTest
    private static void sendEmailTestAttachment(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        Id contentVersionId = ContentVersionSelector.getContentVersionByPathOnClient(FILE_PATH_ON_CLIENT).Id;
        emailParams.entityAttachments = new List<String>{contentVersionId};
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'Email was not send');
    }

    @IsTest
    private static void sendEmailTestFailureWrongEmail(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.toAddresses = null;
        emailParams.toAddress = 'Wrong Email';
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams);
        Test.stopTest();
        
        System.assertEquals(false, results[0].isSuccess(), 'Email should\'nt have been send');
    }

    @IsTest
    private static void sendEmailTestIsErrorEmail(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.toAddress = null;
        emailParams.bccAddress = null;
        emailParams.ccAddress = null;
        emailParams.isErrorEmail = true;
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'Email was not send');
    }

    @IsTest
    private static void getHTMLUnorderedListTest(){

        List<Object> unorderedList = new List<Object>{'Test'};
        
        Test.startTest();
        string htmlUnorderedList = EmailUtils.getHTMLUnorderedList(unorderedList);
        Test.stopTest();

        System.assertEquals(EXPECTED_HTML_UNORDERED_LIST, htmlUnorderedList, 'Html unordered list is not correct');
        
    }

    @IsTest
    private static void sendEmailTestWithDcConfig(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.toAddress = null;
        emailParams.toAddresses = null;
        emailParams.bccAddress = null;
        emailParams.bccAddresses = null;
        emailParams.ccAddress = null;
        emailParams.ccAddresses = null;

        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams, dcConfig.Id);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'Email was not send');
    }

    @IsTest
    private static void sendEmailTestWithDcConfigErrorEmail(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.toAddress = null;
        emailParams.toAddresses = null;
        emailParams.bccAddress = null;
        emailParams.bccAddresses = null;
        emailParams.ccAddress = null;
        emailParams.ccAddresses = null;
        emailParams.isErrorEmail = true;

        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams, dcConfig.Id);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'Email was not send');
    }

    @IsTest
    private static void sendEmailTestWithDcConfigNoEmail(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.toAddress = null;
        emailParams.toAddresses = null;
        emailParams.bccAddress = null;
        emailParams.bccAddresses = null;
        emailParams.ccAddress = null;
        emailParams.ccAddresses = null;

        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        dcConfig.OQCT_DaCl__Receive_Email_Notification__c = false;
        dcConfig.OQCT_DaCl__Receive_Error_Email_Notification__c = false;
        DatabaseUtils.updateRecords(dcConfig);
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams, dcConfig.Id);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'Email was not send');
    }

    @IsTest
    private static void sendEmailTestWithDcConfigErrorEmailNoEmail(){

        EmailUtils.EmailParameters emailParams = getEmailParameters();
        emailParams.toAddress = null;
        emailParams.toAddresses = null;
        emailParams.bccAddress = null;
        emailParams.bccAddresses = null;
        emailParams.ccAddress = null;
        emailParams.ccAddresses = null;
        emailParams.isErrorEmail = true;

        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getAllDCConfigurations()[0];
        dcConfig.OQCT_DaCl__Receive_Email_Notification__c = false;
        dcConfig.OQCT_DaCl__Receive_Error_Email_Notification__c = false;
        DatabaseUtils.updateRecords(dcConfig);
        
        Test.startTest();
        Messaging.SendEmailResult[] results = EmailUtils.sendEmail(emailParams, dcConfig.Id);
        Test.stopTest();

        System.assertEquals(null, results, 'Email was send');
    }

}