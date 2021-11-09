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
public virtual inherited sharing class StringBuilder {
    @TestVisible
    private final List<String> buffer;
    @TestVisible
    private String separator = '';
    private Integer count = 0;

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public StringBuilder() {
        buffer = new List<String>();
    }

    // public StringBuilder(Boolean uniqueBuffer) {
    //     if (uniqueBuffer) {
    //         buffer = new Set<String>();
    //     } else {
    //         this();
    //     }
    // }

    public StringBuilder(Object value) {
        this();
        append(value);
    }

    public StringBuilder append(String value) {
        if (value != null) {
            buffer.add(value);
            count += value.length(); // This isn't correct if the buffer is unique
        }
        return this;
    }

    public StringBuilder append(Object value) {
        String stringValue = String.valueOf(value);
        return append(stringValue);
    }

    public StringBuilder append(StringBuilder stringBuilder) {
        if (stringBuilder == null) {
            return append('null');
        }
        count += stringBuilder.count;
        buffer.addAll(stringBuilder.buffer);
        return this;
    }

    public void setSeparator(String separator) {
        if (String.isNotEmpty(separator)) {
            this.separator = separator;
        }
    }

    public Integer capacity() {
        return buffer.size();
    }

    public Integer length() {
        return count + (separator.length() * (capacity() - 1));
    }

    // delete
    // replace
    // subString
    // insert
    // indexOf
    // lastIndexOf
    // reverse

    public override String toString() {
        return String.join(buffer, separator);
    }
}