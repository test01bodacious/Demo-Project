/**
* @description       : 
* @author            : Krrish Joy
* @group             : 
* @last modified on  : 2021-03-20
* @last modified by  : Krrish Joy
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   03-05-2021   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DataCleanNoteControllerTest {

    private final static String TEAM_NOTES = 'Some Team Notes';
    
    @TestSetup
    private static void setupData(){
        DataFactory.initDataCleanAppConfigurations();
    }

    @IsTest
    static void getTeamNotesTest(){
        Test.startTest();
        DataCleanNoteController.getTeamNotes();
        Utils.Response response = DataCleanNoteController.saveTeamNotes(TEAM_NOTES);
        Test.stopTest();

        System.assertEquals(true, response.isSuccess, 'Response is not successfull');
    }

    @IsTest
    static void getTeamNotesTestForEmptyNotes(){
        Test.startTest();
        DataCleanNoteController.getTeamNotes();
        Utils.Response response = DataCleanNoteController.saveTeamNotes(Constants.LITERAL_EMPTY);
        Test.stopTest();

        System.assertEquals(true, response.isSuccess, 'Response is not successfull');
    }
}