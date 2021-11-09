/*
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-03   Krrish Joy   Initial Version
**/
@IsTest
private with sharing class DateUtilsTest {

    private final static Datetime TEST_DATE_TIME = Datetime.newInstance(2021, 12, 1);
    private final static Date TEST_DATE = Date.newInstance(2021, 12, 1);
    private final static Time TEST_TIME = Time.newInstance(3, 25, 35, 200);

    @IsTest
    private static void getSetNowTest(){
        
        Test.startTest();
        DateUtils.setNow(TEST_DATE_TIME);
        Datetime now = DateUtils.getNow();
        Test.stopTest();
        
        System.assertEquals(TEST_DATE_TIME, now, 'DateUtils.now() is incorrect');
    }

    @IsTest
    private static void getSetTodayTest(){
        
        Test.startTest();
        DateUtils.setToday(TEST_DATE);
        Date today = DateUtils.getToday();
        Test.stopTest();
        
        System.assertEquals(TEST_DATE, today, 'DateUtils.today() is incorrect');
    }

    @IsTest
    private static void getCronStringFromDateTimeRepeatCustomTestEvery1Day(){
        
        Test.startTest();
        String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(TEST_DATE_TIME, 1, Constants.DC_UNIT_DAYS);
        Test.stopTest();
        
        System.assertEquals('0 0 0 1/1 12/1 ? 2021/1', cronString, 'Cron String is incorrect');
    }

    @IsTest
    private static void getCronStringFromDateTimeRepeatCustomTestEvery1Month(){
        
        Test.startTest();
        String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(TEST_DATE_TIME, 1, Constants.DC_UNIT_MONTHS);
        Test.stopTest();
        
        System.assertEquals('0 0 0 1 12/1 ? 2021/1', cronString, 'Cron String is incorrect');
    }

    @IsTest
    private static void getCronStringFromDateTimeRepeatCustomTestEvery1Year(){
        
        Test.startTest();
        String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(TEST_DATE_TIME, 1, Constants.DC_UNIT_YEARS);
        Test.stopTest();
        
        System.assertEquals('0 0 0 1 12 ? 2021/1', cronString, 'Cron String is incorrect');
    }

    @IsTest
    private static void getCronStringFromDateTimeRepeatCustomTestEvery1Hour(){
        
        Test.startTest();
        String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(TEST_DATE_TIME, 1, Constants.DC_UNIT_HOURS);
        Test.stopTest();
        
        System.assertEquals('0 0 0/1 1/1 12/1 ? 2021/1', cronString, 'Cron String is incorrect');
    }

    @IsTest
    private static void getCronStringFromDateTimeRepeatCustomTestEvery1Minute(){
        
        Test.startTest();
        String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(TEST_DATE_TIME, 1, Constants.DC_UNIT_MINUTES);
        Test.stopTest();
        
        System.assertEquals('0 0/1 0/1 1/1 12/1 ? 2021/1', cronString, 'Cron String is incorrect');
    }

    @IsTest
    private static void getCronStringFromDateTimeRepeatCustomNoUnit(){
        
        Test.startTest();
        String cronString = DateUtils.getCronStringFromDateTimeRepeatCustom(TEST_DATE_TIME, 1, null);
        Test.stopTest();
        
        System.assertEquals('0 0 0 1 12 ? 2021', cronString, 'Cron String is incorrect');
    }

    @IsTest
    private static void getCronStringFromDateTimeEveryYearTest(){
        
        Test.startTest();
        String cronString = DateUtils.getCronStringFromDateTimeEveryYear(TEST_DATE_TIME);
        Test.stopTest();
        
        System.assertEquals('0 0 0 1 12 ? *', cronString, 'Cron String is incorrect');
    }

    @IsTest
    private static void getCronStringFromDateTimeEveryMonthYearTest(){
        
        Test.startTest();
        String cronString = DateUtils.getCronStringFromDateTimeEveryMonthYear(TEST_DATE_TIME);
        Test.stopTest();
        
        System.assertEquals('0 0 0 1 * ? *', cronString, 'Cron String is incorrect');
    }

    @IsTest
    private static void getCronStringFromDateTimeEveryDayMonthYearTest(){
        
        Test.startTest();
        String cronString = DateUtils.getCronStringFromDateTimeEveryDayMonthYear(TEST_DATE_TIME);
        Test.stopTest();
        
        System.assertEquals('0 0 0 * * ? *', cronString, 'Cron String is incorrect');
    }

    @IsTest
    private static void getCronStringFromDateTimeTest(){
        
        Test.startTest();
        String cronString = DateUtils.getCronStringFromDateTime(TEST_DATE_TIME);
        Test.stopTest();
        
        System.assertEquals('0 0 0 1 12 ? 2021', cronString, 'Cron String is incorrect');
    }

    @IsTest
    private static void shiftDateTestWithTime(){
        
        Test.startTest();
        Datetime shiftedDate = DateUtils.shiftDate(TEST_DATE_TIME, 1, Constants.DC_UNIT_DAYS, TEST_TIME);
        Test.stopTest();
        
        System.assertEquals(Datetime.newInstance(TEST_DATE_TIME.addDays(1).date(), TEST_TIME), shiftedDate, 'Shifted Datetime is incorrect');
    }

    @IsTest
    private static void shiftDateTest1Day(){
        
        Test.startTest();
        Datetime shiftedDate = DateUtils.shiftDate(TEST_DATE_TIME, 1, Constants.DC_UNIT_DAYS, null);
        Test.stopTest();
        
        System.assertEquals(TEST_DATE_TIME.addDays(1), shiftedDate, 'Shifted Datetime is incorrect');
    }

    @IsTest
    private static void shiftDateTest1Month(){
        
        Test.startTest();
        Datetime shiftedDate = DateUtils.shiftDate(TEST_DATE_TIME, 1, Constants.DC_UNIT_MONTHS, null);
        Test.stopTest();
        
        System.assertEquals(TEST_DATE_TIME.addMonths(1), shiftedDate, 'Shifted Datetime is incorrect');
    }

    @IsTest
    private static void shiftDateTest1Year(){
        
        Test.startTest();
        Datetime shiftedDate = DateUtils.shiftDate(TEST_DATE_TIME, 1, Constants.DC_UNIT_YEARS, null);
        Test.stopTest();
        
        System.assertEquals(TEST_DATE_TIME.addYears(1), shiftedDate, 'Shifted Datetime is incorrect');
    }

    @IsTest
    private static void shiftDateTest1Hour(){
        
        Test.startTest();
        Datetime shiftedDate = DateUtils.shiftDate(TEST_DATE_TIME, 1, Constants.DC_UNIT_HOURS, null);
        Test.stopTest();
        
        System.assertEquals(TEST_DATE_TIME.addHours(1), shiftedDate, 'Shifted Datetime is incorrect');
    }

    @IsTest
    private static void shiftDateTest1Minute(){
        
        Test.startTest();
        Datetime shiftedDate = DateUtils.shiftDate(TEST_DATE_TIME, 1, Constants.DC_UNIT_MINUTES, null);
        Test.stopTest();
        
        System.assertEquals(TEST_DATE_TIME.addMinutes(1), shiftedDate, 'Shifted Datetime is incorrect');
    }

    @IsTest
    private static void shiftDateTestNoUnit(){
        
        Test.startTest();
        Datetime shiftedDate = DateUtils.shiftDate(TEST_DATE_TIME, 1, null, null);
        Test.stopTest();
        
        System.assertEquals(TEST_DATE_TIME, shiftedDate, 'Shifted Datetime is incorrect');
    }

    @IsTest
    private static void shiftNowDateTest(){

        DateUtils.setNow(TEST_DATE_TIME);
        Test.startTest();
        Datetime shiftedDate = DateUtils.shiftNowDate(1, null, null);
        Test.stopTest();
        
        System.assertEquals(TEST_DATE_TIME, shiftedDate, 'Shifted Datetime is incorrect');
    }


}