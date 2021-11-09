/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-22
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-06   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class EmailUtils {

    private static final Boolean LOG_EMAIL_RESULTS = true;

    public static Messaging.SendEmailResult[] sendEmail(EmailParameters emailParams, Id dcConfigId){
        Messaging.SingleEmailMessage message = EmailUtils.getEmailMessage(emailParams);

        if (dcConfigId != null) {
            List<String> toAddresses = message.toaddresses;
            toAddresses.addAll(EmailUtils.getDcConfigurationEmails(dcConfigId, emailParams.isErrorEmail));
            message.toaddresses = toAddresses;
        }

        if (message.toaddresses == null || message.toaddresses.isEmpty()) {
            if (!emailParams.isErrorEmail) {
                message.toaddresses = new List<String>{Utils.getUserEmail()};
            } else {
                return null;
            }
        }

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        messages.add(message);

        // Send E-Mail
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);

        // Result Logging
        if (EmailUtils.LOG_EMAIL_RESULTS) {
            EmailUtils.logEmailResults(results);
        }

        return results;
    }

    public static Messaging.SendEmailResult[] sendEmail(EmailParameters emailParams){
        return EmailUtils.sendEmail(emailParams, null);
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    private static Messaging.SingleEmailMessage getEmailMessage(EmailParameters emailParams){

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        // Set ToAddresses
        if (emailParams.toAddresses != null && emailParams.toAddresses.size() > 0) {
            message.toaddresses =  emailParams.toAddresses;
        } else if (emailParams.toAddress != null) {
            message.toaddresses = new List<String>{emailParams.toAddress};
        } else {
            message.toaddresses = new List<String>();
        }

        if (!emailParams.isErrorEmail) {
            List<String> toAddresses = message.toaddresses;
            toAddresses.addAll(EmailUtils.getGlobalDataCleanAppconfigurationEmailsEmails());
            message.toaddresses = toAddresses;
        }

        // Set BccAddresses
        if (emailParams.bccAddresses != null && emailParams.bccAddresses.size() > 0) {
            message.bccAddresses =  emailParams.bccAddresses;
        } else if (emailParams.bccAddress != null) {
            message.bccAddresses = new List<String>{emailParams.bccAddress};
        }

        // Set CcAddresses
        if (emailParams.ccAddresses != null && emailParams.ccAddresses.size() > 0) {
            message.ccAddresses =  emailParams.ccAddresses;
        } else if (emailParams.ccAddress != null) {
            message.ccAddresses = new List<String>{emailParams.ccAddress};
        }

        // Set Subject
        message.subject = emailParams.subject != null? emailParams.subject : '';

        // Set TemplateId
        if (emailParams.templateId != null) {
            message.templateId = emailParams.templateId;
            // Set WhatId
            if (emailParams.whatId != null) {
                message.whatId = emailParams.whatId;
            }
        } else {
            // Set Body
            if (emailParams.htmlbody != null) {
                // Set HTML Body
                message.htmlbody = EmailUtils.addHeaderFooterToHTMLBody(emailParams.htmlBody);
            }
            if (emailParams.plainTextBody != null){
                // Set PlainText Body
                message.plainTextBody = EmailUtils.addHeaderFooterToPlainTextBody( emailParams.plainTextBody);
            }
        }

        // Set EntityAttachments
        if (emailParams.entityAttachments != null && emailParams.entityAttachments.size() > 0) {
            message.entityAttachments = emailParams.entityAttachments;
        }

        // Set EmailPriority
        if (emailParams.emailPriority != null) {
            message.emailPriority = emailParams.emailPriority;
        }

        // Set SaveAsActivity
        if (emailParams.saveAsActivity != null) {
            message.saveAsActivity = emailParams.saveAsActivity;
        }

        // Set ReplyTo
        if (emailParams.replyTo != null) {
            message.replyTo = emailParams.replyTo;
        }

        // Set SenderDisplayName
        if (emailParams.senderDisplayName != null) {
            message.senderDisplayName = emailParams.senderDisplayName;
        }
        return message;
    }

    private static List<String> getGlobalDataCleanAppconfigurationEmailsEmails(){
        List<String> dataCleanAppConfigEmails = new List<String>();
        List<OQCT_DaCl__Data_Clean_App_Configurations__c> dataCleanAppConfigs = DataCleanAppConfigurationSelector.getDataCleanAppConfigurationForEmails();
        if (dataCleanAppConfigs.isEmpty()) {
            return dataCleanAppConfigEmails;
        }
        if (dataCleanAppConfigs[0].OQCT_DaCl__Send_Global_Email_App_Notification__c) {
            if (String.isNotBlank(dataCleanAppConfigs[0].OQCT_DaCl__Admin_Team_Email_Id__c)) {
                dataCleanAppConfigEmails.add(dataCleanAppConfigs[0].OQCT_DaCl__Admin_Team_Email_Id__c);
            }
            if (String.isNotBlank(dataCleanAppConfigs[0].OQCT_DaCl__External_Department_Email_Id__c)) {
                dataCleanAppConfigEmails.add(dataCleanAppConfigs[0].OQCT_DaCl__External_Department_Email_Id__c);
            }
        }
        return dataCleanAppConfigEmails;
    }

    private static List<String> getDcConfigurationEmails(Id dcConfigId, Boolean isErrorEmail){
        List<String> dcConfigEmails = new List<String>();
        OQCT_DaCl__DC_Configuration__c dcConfig = DCConfigurationSelector.getDCConfigurationEmailById(dcConfigId);
        if (!isErrorEmail) {
            if (dcConfig.OQCT_DaCl__Receive_Email_Notification__c) {
                if (String.isNotBlank(dcConfig.OQCT_DaCl__Email_Ids_to_Notify__c)) {
                    dcConfigEmails.addAll(dcConfig.OQCT_DaCl__Email_Ids_to_Notify__c.replaceAll('\\s+','').split(','));
                }
            }
        }
        if (isErrorEmail) {
            if (dcConfig.OQCT_DaCl__Receive_Error_Email_Notification__c) {
                if (String.isNotBlank(dcConfig.OQCT_DaCl__Error_Email_Ids_to_Notify__c)) {
                    dcConfigEmails.addAll(dcConfig.OQCT_DaCl__Error_Email_Ids_to_Notify__c.replaceAll('\\s+','').split(','));
                }
            }
        }
        return dcConfigEmails;
    }

    private static void logEmailResults(Messaging.SendEmailResult[] results){
        Integer success = 0;
        Integer failure = 0;
        String error = '';
        for(Messaging.SendEmailResult result : results){
            if (result.isSuccess()){
                success++;
            } else {
                failure++;
                for(Messaging.SendEmailError e: result.getErrors()){
                    error += e.getStatusCode();
                    error += ': ';
                    error += e.getMessage();
                    // if (e.targetobjectid != null){
                    //     error += '\nTarget record for which the error occurred: ';
                    //     error += e.getTargetObjectId();
                    // }
                    if (e.getFields().size() > 0){
                        error += '\nFields affected this error are: (';
                        error += String.valueOf(e.getFields());
                    }
                    error += '\n\n';
                }  
            }
        }
        String msg = '';
        if (error != ''){
            error = error.substring(0, error.length()-2);
            msg += '\nThere were some problem sending emails:';
            msg += '\nTotal Emails Succeeded: ' + success;
            msg += '\nTotal Emails Failed: ' + failure;
            msg += '\n\n' + error;
            Utils.debug(msg);
        } else {
            msg += 'Emails were send successfully.';
            msg += '\nTotal Emails Succeeded: ' + success;
            msg += '\nTotal Emails Failed: ' + failure;
            Utils.debug(msg);
        }
    }

    private static String addHeaderFooterToHTMLBody(String body){
        Organization org = OrganizationSelector.getOrganization();
        List<String> orgDetails = new List<String>();
        orgDetails.add(org.Name);
        orgDetails.add(org.Id);
        String bodyWihHeaderFooter = String.format(Constants.DATA_CLEAN_EMAIL_HEADER_HTML, orgDetails);
        bodyWihHeaderFooter += body;
        bodyWihHeaderFooter += Constants.DATA_CLEAN_EMAIL_FOOTER_HTML;
        return bodyWihHeaderFooter;
    }

    private static String addHeaderFooterToPlainTextBody(String body){
        Organization org = OrganizationSelector.getOrganization();
        List<String> orgDetails = new List<String>();
        orgDetails.add(org.Name);
        orgDetails.add(org.Id);
        String bodyWihHeaderFooter = String.format(Constants.DATA_CLEAN_EMAIL_HEADER_PLAIN_TEXT, orgDetails);
        bodyWihHeaderFooter += body;
        bodyWihHeaderFooter += Constants.DATA_CLEAN_EMAIL_FOOTER_PLAIN_TEXT;
        return bodyWihHeaderFooter;
    }

    public static String getHTMLUnorderedList(List<Object> unorderedList){
        String htmlUnorderedList = Constants.HTML_TAG_UNORDERED_LIST_OPEN;
        for (Object unorderedListElement : unorderedList) {
            htmlUnorderedList += Constants.HTML_TAG_LIST_ELEMENT_OPEN;
            htmlUnorderedList += String.valueOf(unorderedListElement);
            htmlUnorderedList += Constants.HTML_TAG_LIST_ELEMENT_CLOSE;
        }
        htmlUnorderedList += Constants.HTML_TAG_UNORDERED_LIST_CLOSE;
        return htmlUnorderedList;
    }

    public with sharing class EmailParameters{
        public List<String> toAddresses;
        public String toAddress;
        public List<String> bccAddresses;
        public String bccAddress;
        public List<String> ccAddresses;
        public String ccAddress;
        public String subject;
        public String plainTextBody;
        public String htmlBody;
        public String templateId;
        public String whatId;
        public List<String> entityAttachments;
        public String emailPriority = 'Normal';
        public Boolean saveAsActivity = false;
        public String replyTo = Utils.getUserEmail();
        public String senderDisplayName = Constants.DATA_CLEAN_EMAIL_SENDER_DISPLAY_NAME;
        public Boolean isErrorEmail = false;
    }

}