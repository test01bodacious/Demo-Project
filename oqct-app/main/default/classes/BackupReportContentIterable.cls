/**
 * @description       : 
 * @author            : Krrish Joy
 * @group             : OQCT.com Limited
 * @last modified on  : 2021-03-10
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   2021-03-10   Krrish Joy   Initial Version
**/
public with sharing class BackupReportContentIterable implements Iterable<ReportUtil.BackupReportContent> {
    
    private List<ReportUtil.BackupReportContent> backupContents;

    // Received records via parameterized constructor through batch apex
    public BackupReportContentIterable(List<ReportUtil.BackupReportContent> backupContents) {
        this.backupContents = backupContents;
    }

    // Overrides the method iterable interface
    public Iterator<ReportUtil.BackupReportContent> iterator() {
        return new BackupReportContentIterator(this.backupContents);
    }

}