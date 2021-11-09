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
public with sharing class BackupReportContentIterator implements Iterator<ReportUtil.BackupReportContent> {

    private List<ReportUtil.BackupReportContent> backupContents;
    private Integer index;
    
     // Constrcutor used to receive the list from iterable class
    public BackupReportContentIterator(List<ReportUtil.BackupReportContent> backupContents) {
        this.backupContents = backupContents;
        this.index = 0;
    }

    // Method override of iterator interface
    public Boolean hasNext() {
        return !(this.index >= this.backupContents.size());
    }

    // Method override of iterator interface
    public ReportUtil.BackupReportContent next() {
        if (this.index == this.backupContents.size()) {
            return null;
        }
        this.index++;
        return this.backupContents[this.index - 1];
    }
}