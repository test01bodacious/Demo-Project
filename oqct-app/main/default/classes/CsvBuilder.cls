/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-26
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-06   Krrish Joy   Initial Version
**/
public with sharing class CsvBuilder {
    public static final String COLUMN_DELIMITER = ',';

    public static final String WINDOWS_LINE_ENDING = '\r\n';
    public static final String UNIX_LINE_ENDING = '\n';

    public with sharing class InvalidRowException extends Exception {
    }

    @TestVisible
    private final Map<String, Map<Integer, String>> headerToValues = new Map<String, Map<Integer, String>>();
    
    public Integer currentRow = 0;

    private final String lineEnding;

    public CsvBuilder(String lineEnding) {
        this.lineEnding = lineEnding;
    }

    public CsvBuilder() {
        this(UNIX_LINE_ENDING);
    }

    public CsvBuilder appendField(String headerName, String fieldValue) {
        headerName = String.isBlank(headerName) ? Constants.LITERAL_NULL : headerName;
        fieldValue = String.isBlank(fieldValue) ? Constants.LITERAL_NULL : fieldValue;
        Map<Integer, String> column = headerToValues.containsKey(headerName)
            ? headerToValues.get(headerName)
            : new Map<Integer, String>();
        column.put(currentRow, fieldValue);
        headerToValues.put(headerName, column);
        return this;
    }

    public CsvBuilder newRow() {
        currentRow++;
        return this;
    }

    public Integer totalRows() {
        return (headerToValues.values() != null && !headerToValues.values().isEmpty())? headerToValues.values()[0].size() : 0;
    }

    public override String toString() {
        ColumnBuilder csvDocument = new ColumnBuilder(lineEnding);
        RowBuilder headerRow = new RowBuilder();
        RowBuilder[] rows = new List<RowBuilder>(totalRows());
        for (String headerName : headerToValues.keySet()) {
            headerRow.append(headerName.escapeCsv());
            Map<Integer, String> values = headerToValues.get(headerName);
            for (Integer rowIterator = 0; rowIterator <= currentRow; rowIterator++) {
                String value = values.containsKey(rowIterator) ? values.get(rowIterator) : Constants.LITERAL_EMPTY;
                RowBuilder row = rows[rowIterator];
                if (row == null) {
                    row = new RowBuilder();
                }
                row.append(value.escapeCsv());
                rows[rowIterator] = row;
            }
        }
        csvDocument.append(headerRow);
        for (RowBuilder row : rows) {
            csvDocument.append(row);
        }
        return csvDocument.toString();
    }

    private with sharing class RowBuilder extends StringBuilder {
        public RowBuilder() {
            setSeparator(COLUMN_DELIMITER);
        }
    }

    private with sharing class ColumnBuilder extends StringBuilder {
        private Integer numberOfColumns;

        public ColumnBuilder(String lineEnding) {
            setSeparator(lineEnding);
        }

        public ColumnBuilder append(RowBuilder rowToAdd) {
            Boolean isAddedRowValid =
                numberOfColumns == null ||
                rowToAdd.capacity() == numberOfColumns;
            if (!isAddedRowValid) {
                throw new DataCleanCustomExceptions.InvalidRowException(
                    Constants.CSV_BUILDER_INVALID_ROW_ERROR
                );
            }
            numberOfColumns = rowToAdd.capacity();
            append(rowToAdd.toString());
            return this;
        }
    }

    // Enhancements - Add-ons

    public static String getSObjectRecordsAsCsv(List<SObject> records, Map<String, String> fieldApiName2headerValue){
        CsvBuilder recordsCsv = new CsvBuilder();
        Integer count = 1;
        for (SObject record : records) {
            for (String field : fieldApiName2headerValue.keySet()) {
                recordsCsv.appendField(fieldApiName2headerValue.get(field), String.valueOf(record.get(field)));
            }
            if (count++ < records.size()) {
                recordsCsv.newRow();
            }
        }
        return recordsCsv.toString();
    }

    public static String getSObjectRecordsAsCsv(List<SObject> records, List<String> fieldApiNamesAsHeaderValues){
        CsvBuilder recordsCsv = new CsvBuilder();
        Integer count = 1;
        for (SObject record : records) {
            for (String field : fieldApiNamesAsHeaderValues) {
                recordsCsv.appendField(field, String.valueOf(record.get(field)));
            }
            if (count++ < records.size()) {
                recordsCsv.newRow();
            }
        }
        return recordsCsv.toString();
    }

    public static String getSObjectRecordsAsCsv(List<SObject> records, List<Schema.SObjectField> sObjectFields){
        CsvBuilder recordsCsv = new CsvBuilder();
        Integer count = 1;
        for (SObject record : records) {
            for (Schema.SObjectField sObjectField : sObjectFields) {
                Schema.DescribeFieldResult fieldDescription = sObjectField.getDescribe();
                recordsCsv.appendField(fieldDescription.getLabel(), String.valueOf(record.get(fieldDescription.getName())));
            }
            if (count++ < records.size()) {
                recordsCsv.newRow();
            }
        }
        return recordsCsv.toString();
    }

    public static String getSObjectRecordsAsCsv(List<SObject> records, String objectName, String fieldSetName){
        Schema.FieldSet fieldSetObj = Utils.getSObjectDescription(objectName)
                                        ?.FieldSets
                                        ?.getMap()
                                        ?.get(fieldSetName);

        if (fieldSetObj == null) {
            return '';
        }

        CsvBuilder recordsCsv = new CsvBuilder();
        Integer count = 1;
        for (SObject record : records) {
            for (Schema.FieldSetMember schemaFieldSetMember : fieldSetObj.getFields()) {
                recordsCsv.appendField(schemaFieldSetMember.label, String.valueOf(record.get(schemaFieldSetMember.fieldpath)));
            }
            if (count++ < records.size()) {
                recordsCsv.newRow();
            }
        }
        return recordsCsv.toString();
    }

    public static CsvBuilder getRowsAndHeadersAsCsv(CsvBuilder existingRecordsCsv, List<Map<String, Object>> rows, List<String> headers){
        if (existingRecordsCsv == null) {
            existingRecordsCsv = new CsvBuilder();
        } else {
            if (existingRecordsCsv.currentRow != 0) {
                existingRecordsCsv.newRow();
            }
        }
        CsvBuilder recordsCsv = existingRecordsCsv;
        Integer count = 1;
        for (Map<String, Object> row : rows) {
            for (String header : headers) {
                recordsCsv.appendField(header, String.valueOf(row.get(header)));
            }
            if (count++ < rows.size()) {
                recordsCsv.newRow();
            }
        }
        return recordsCsv;
    }
}