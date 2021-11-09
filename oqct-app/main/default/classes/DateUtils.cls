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
public with sharing class DateUtils {

    @TestVisible
    private static Datetime now;

    @TestVisible
    private static Date today;

    public static Datetime getNow() {
        return now == null ? Datetime.now() : now;
    }

    public static Date getToday() {
        return today == null ? Date.today() : today;
    }

    @TestVisible
    private static void setNow(Datetime newNow) {
        now = newNow;
    }

    @TestVisible
    private static void setToday(Date newToday) {
        today = newToday;
    }

    public static String getCronStringFromDateTimeEveryYear(Datetime dt){
        return dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? *';
    }

    public static String getCronStringFromDateTimeEveryMonthYear(Datetime dt){
        return dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' * ? *';
    }

    public static String getCronStringFromDateTimeEveryDayMonthYear(Datetime dt){
        return dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' * * ? *';
    }

    public static String getCronStringFromDateTime(Datetime dt){
        return dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
    }

    public static String getCronStringFromDateTimeRepeatCustom(Datetime dt, Decimal repeatBy, String repeatUnit){
        if (repeatUnit == Constants.DC_UNIT_DAYS) {
            return dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + '/' + repeatBy + ' ' + dt.month() + '/1' + ' ? ' + dt.year() + '/1';
        } else if (repeatUnit == Constants.DC_UNIT_MINUTES) {
            return dt.second() + ' ' + dt.minute() + '/' + repeatBy + ' ' + dt.hour() + '/1' + ' ' + dt.day() + '/1' + ' ' + dt.month() + '/1' + ' ? ' + dt.year() + '/1';
        } else if (repeatUnit == Constants.DC_UNIT_HOURS) {
            return dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + '/' + repeatBy + ' ' + dt.day() + '/1' + ' ' + dt.month() + '/1' + ' ? ' + dt.year() + '/1';
        } else if (repeatUnit == Constants.DC_UNIT_MONTHS) {
            return dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + '/' + repeatBy + ' ? ' + dt.year() + '/1';
        } else if (repeatUnit == Constants.DC_UNIT_YEARS) {
            return dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year() + '/' + repeatBy;
        } else {
            return DateUtils.getCronStringFromDateTime(dt);
        }
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static Datetime shiftDate(Datetime dateToShift, Integer shiftBy, String unit, Time startTime){
        Datetime shiftedDate;
        if (unit == Constants.DC_UNIT_DAYS) {
            shiftedDate = dateToShift.addDays(shiftBy);
        } else if (unit == Constants.DC_UNIT_MINUTES) {
            return dateToShift.addMinutes(shiftBy);
        } else if (unit == Constants.DC_UNIT_HOURS) {
            return dateToShift.addHours(shiftBy);
        } else if (unit == Constants.DC_UNIT_MONTHS) {
            shiftedDate = dateToShift.addMonths(shiftBy);
        } else if (unit == Constants.DC_UNIT_YEARS) {
            shiftedDate = dateToShift.addYears(shiftBy);
        } else {
            shiftedDate = dateToShift;
        }
        if (startTime != null) {
            return Datetime.newInstance(shiftedDate.date(), startTime);
        }
        return shiftedDate;
    }

    public static Datetime shiftNowDate(Integer shiftBy, String unit, Time startTime){
        return DateUtils.shiftDate(DateUtils.getNow(), shiftBy, unit, startTime);
    }

}