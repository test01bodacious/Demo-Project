/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-06   Krrish Joy   Initial Version
**/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.ExcessivePublicCount')
public with sharing class QueryBuilder {

    private static final String SOQL_BASE_QUERY = 'SELECT {0} FROM {1}';
    private static final String SOQL_WHERE_CLAUSE = 'WHERE ({0})';
    private static final String SOQL_GROUP_BY_CLAUSE = 'GROUP BY {0}';
    private static final String SOQL_HAVING_CLAUSE = 'HAVING ({0})';
    private static final String SOQL_ALL_ROWS_CLAUSE = 'ALL ROWS';
    private static final String SOQL_WITH_SECURITY_ENFORCED = 'WITH SECURITY_ENFORCED';
    private static final String SOQL_ORDER_BY = 'ORDER BY {0} {1}';
    private static final String SOQL_LIMIT = 'LIMIT {0}';
    private static final String SOQL_OFFSET = 'OFFSET {0}';

    // SOQL Clauses
    private static final String SOQL_CLAUSE_WHERE_IN = 'WHERE {0} IN';
    private static final String SOQL_CLAUSE_IN = '{0} IN';
    private static final String SOQL_CLAUSE_WHERE_NOT_IN = 'WHERE {0} NOT IN';
    private static final String SOQL_CLAUSE_NOT_IN = '{0} NOT IN';

    // SOQL Operator
    private static final String SOQL_OPERATOR_AND = 'AND';
    private static final String SOQL_OPERATOR_OR = 'OR';
    private static final String SOQL_OPERATOR_NOT = 'NOT';

    // list properties used as bind variable
    private static final String SOQL_STRING_LIST = ':stringList';
    private static final String SOQL_DECIMAL_LIST = ':numberList';

    

    @SuppressWarnings('PMD.CognitiveComplexity,PMD.NcssMethodCount')
    public static String getQueryString(QueryBuilderParameters queryBuilderParams){

        queryBuilderParams.fieldApiNames = QueryBuilder.updateQueryParameterFieldApiNames(queryBuilderParams, false);

        List<String> soqlBaseQueryParams = new List<String>();
        soqlBaseQueryParams.add(String.join(queryBuilderParams.fieldApiNames, Constants.LITERAL_COMMA_SEPARATOR));
        soqlBaseQueryParams.add(queryBuilderParams.objectName);

        final StringBuilder query = new StringBuilder();
        query.setSeparator(Constants.LITERAL_SPACE);

        query.append(String.format(QueryBuilder.SOQL_BASE_QUERY, soqlBaseQueryParams));

        if (queryBuilderParams.whereClauseCondition != null) {
            List<String> soqlWhereClauseParams = new List<String>();
            soqlWhereClauseParams.add(queryBuilderParams.whereClauseCondition);
            query.append(String.format(QueryBuilder.SOQL_WHERE_CLAUSE, soqlWhereClauseParams));
        }
        
        if ((queryBuilderParams.addWhereInClause || queryBuilderParams.addWhereNotInClause) &&
            queryBuilderParams.whereInOrNotInField != null &&
            (queryBuilderParams.numberList != null || queryBuilderParams.stringList != null)){
            
            String clauseIn = QueryBuilder.SOQL_CLAUSE_WHERE_IN;
            String clauseNotIn = QueryBuilder.SOQL_CLAUSE_WHERE_NOT_IN;
            if (queryBuilderParams.whereClauseCondition != null) {
                query.append(QueryBuilder.SOQL_OPERATOR_AND);
                clauseIn = QueryBuilder.SOQL_CLAUSE_IN;
                clauseNotIn = QueryBuilder.SOQL_CLAUSE_NOT_IN;
            }
                
            List<String> soqlwhereInNotInClauseParams = new List<String>();
            soqlwhereInNotInClauseParams.add(queryBuilderParams.whereInOrNotInField);

            if (queryBuilderParams.addWhereInClause) {
                query.append(String.format(clauseIn, soqlwhereInNotInClauseParams)); 
            } else if (queryBuilderParams.addWhereNotInClause){
                query.append(String.format(clauseNotIn, soqlwhereInNotInClauseParams));
            }

            if (queryBuilderParams.stringList != null) {
                query.append(QueryBuilder.SOQL_STRING_LIST);
            } else if (queryBuilderParams.numberList != null) {
                query.append(QueryBuilder.SOQL_DECIMAL_LIST);
            }
        }

        if (queryBuilderParams.isSecurityEnforced) {
            query.append(QueryBuilder.SOQL_WITH_SECURITY_ENFORCED);
        }

        if (
            queryBuilderParams.sortField != null &&
            queryBuilderParams.sortDirection != null
        ) {
            List<String> soqlorderByParams = new List<String>();
            soqlorderByParams.add(queryBuilderParams.sortField);
            soqlorderByParams.add(queryBuilderParams.sortDirection);
            query.append(String.format(QueryBuilder.SOQL_ORDER_BY, soqlorderByParams));
        }

        if (queryBuilderParams.recordLimit != null) {
            List<String> soqlLimitParams = new List<String>();
            soqlLimitParams.add(String.valueOf(queryBuilderParams.recordLimit));
            query.append(String.format(QueryBuilder.SOQL_LIMIT, soqlLimitParams));
        }

        if (queryBuilderParams.offset != null) {
            List<String> soqlOffsetParams = new List<String>();
            soqlOffsetParams.add(String.valueOf(queryBuilderParams.offset));
            query.append(String.format(QueryBuilder.SOQL_OFFSET, soqlOffsetParams));
        }

        if (queryBuilderParams.queryAllRows) {
            query.append(QueryBuilder.SOQL_ALL_ROWS_CLAUSE);
        }

        Utils.debug('QUERY', query.toString());

        return query.toString();
    }

    @SuppressWarnings('PMD.CognitiveComplexity,PMD.NcssMethodCount')
    public static String getAggregateQueryString(QueryBuilderParameters queryBuilderParams){

        queryBuilderParams.fieldApiNames = QueryBuilder.updateQueryParameterFieldApiNames(queryBuilderParams, true);
        
        final StringBuilder aggregateParams = new StringBuilder();
        aggregateParams.setSeparator(', ');
        for (AggregateParameters aggregateParam : queryBuilderParams.aggregateParams) {
            if (aggregateParam.aggregateFieldAlias == null) {
                aggregateParam.aggregateFieldAlias = '';
            }
            if (aggregateParam.aggregateFieldApiName == null) {
                aggregateParam.aggregateFieldApiName = '';
            }
            String aggregateParamString = aggregateParam.aggregateFunction + Constants.LITERAL_OPEN_BRACKET + aggregateParam.aggregateFieldApiName + Constants.LITERAL_CLOSE_BRACKET + Constants.LITERAL_SPACE + aggregateParam.aggregateFieldAlias;
            aggregateParams.append(aggregateParamString.trim());
        }
        for (String fieldApiName : queryBuilderParams.fieldApiNames) {
            aggregateParams.append(fieldApiName);
        }
        List<String> soqlBaseQueryParams = new List<String>();
        soqlBaseQueryParams.add(aggregateParams.toString());
        soqlBaseQueryParams.add(queryBuilderParams.objectName);

        final StringBuilder query = new StringBuilder();
        query.setSeparator(Constants.LITERAL_SPACE);

        query.append(String.format(QueryBuilder.SOQL_BASE_QUERY, soqlBaseQueryParams));

        if (queryBuilderParams.whereClauseCondition != null) {
            List<String> soqlWhereClauseParams = new List<String>();
            soqlWhereClauseParams.add(queryBuilderParams.whereClauseCondition);
            query.append(String.format(QueryBuilder.SOQL_WHERE_CLAUSE, soqlWhereClauseParams));
        }

        if ((queryBuilderParams.addWhereInClause || queryBuilderParams.addWhereNotInClause) &&
            queryBuilderParams.whereInOrNotInField != null &&
            (queryBuilderParams.numberList != null || queryBuilderParams.stringList != null)){
            
            String clauseIn = QueryBuilder.SOQL_CLAUSE_WHERE_IN;
            String clauseNotIn = QueryBuilder.SOQL_CLAUSE_WHERE_NOT_IN;
            if (queryBuilderParams.whereClauseCondition != null) {
                query.append(QueryBuilder.SOQL_OPERATOR_AND);
                clauseIn = QueryBuilder.SOQL_CLAUSE_IN;
                clauseNotIn = QueryBuilder.SOQL_CLAUSE_NOT_IN;
            }
                
            List<String> soqlwhereInNotInClauseParams = new List<String>();
            soqlwhereInNotInClauseParams.add(queryBuilderParams.whereInOrNotInField);

            if (queryBuilderParams.addWhereInClause) {
                query.append(String.format(clauseIn, soqlwhereInNotInClauseParams)); 
            } else if (queryBuilderParams.addWhereNotInClause){
                query.append(String.format(clauseNotIn, soqlwhereInNotInClauseParams));
            }

            if (queryBuilderParams.stringList != null) {
                query.append(QueryBuilder.SOQL_STRING_LIST);
            } else if (queryBuilderParams.numberList != null) {
                query.append(QueryBuilder.SOQL_DECIMAL_LIST);
            }
        }
        
        if (!queryBuilderParams.fieldApiNames.isEmpty()) {
            final StringBuilder soqlGroupByClauseFields = new StringBuilder();
            soqlGroupByClauseFields.setSeparator(Constants.LITERAL_COMMA_SEPARATOR);
            for (String fieldApiName : queryBuilderParams.fieldApiNames) {
                soqlGroupByClauseFields.append(fieldApiName);
            }
            List<String> soqlGroupByClauseParams = new List<String>();
            soqlGroupByClauseParams.add(soqlGroupByClauseFields.toString());
            query.append(String.format(QueryBuilder.SOQL_GROUP_BY_CLAUSE, soqlGroupByClauseParams));
        }

        if (queryBuilderParams.havingClauseCondition != null) {
            List<String> soqlHavingClauseParams = new List<String>();
            soqlHavingClauseParams.add(queryBuilderParams.havingClauseCondition);
            query.append(String.format(QueryBuilder.SOQL_WHERE_CLAUSE, soqlHavingClauseParams));
        }

        if (queryBuilderParams.isSecurityEnforced) {
            query.append(QueryBuilder.SOQL_WITH_SECURITY_ENFORCED);
        }

        if (queryBuilderParams.queryAllRows) {
            query.append(QueryBuilder.SOQL_ALL_ROWS_CLAUSE);
        }

        Utils.debug('AGGREGATE QUERY', query.toString());

        return query.toString();
    }

    public static List<SObject> getQueryResults(QueryBuilderParameters queryBuilderParams){
        List <String> stringList = queryBuilderParams.stringList;
        List <Decimal> numberList = queryBuilderParams.numberList;
        return Database.Query(QueryBuilder.getQueryString(queryBuilderParams));
    }

    public static List<AggregateResult> getAggregateQueryResults(QueryBuilderParameters queryBuilderParams){
        List <String> stringList = queryBuilderParams.stringList;
        List <Decimal> numberList = queryBuilderParams.numberList;
        return Database.Query(QueryBuilder.getAggregateQueryString(queryBuilderParams));
    }

    public static Integer getCountQueryResults(QueryBuilderParameters queryBuilderParams){
        queryBuilderParams.aggregateParams = new List<AggregateParameters>();
        AggregateParameters aggregateParam = new AggregateParameters();
        aggregateParam.aggregateFunction = Constants.AGGREGATE_FUNCTION_COUNT;
        queryBuilderParams.aggregateParams.add(aggregateParam);
        List <String> stringList = queryBuilderParams.stringList;
        List <Decimal> numberList = queryBuilderParams.numberList;
        return Database.CountQuery(QueryBuilder.getAggregateQueryString(queryBuilderParams));
    }

    @SuppressWarnings('PMD.CognitiveComplexity')
    public static List<String> updateQueryParameterFieldApiNames(QueryBuilderParameters queryBuilderParams, Boolean removeRecordIdAndSecurity){
        if (queryBuilderParams.fieldApiName != null &&
            (queryBuilderParams.fieldApiNames == null ||
                queryBuilderParams.fieldApiNames.isEmpty()
            )
        ) {
            queryBuilderParams.fieldApiNames = new List<String>{queryBuilderParams.fieldApiName};
        } else if (queryBuilderParams.fieldApiName != null &&
            !queryBuilderParams.fieldApiNames.contains(queryBuilderParams.fieldApiName)
        ){
            queryBuilderParams.fieldApiNames.add(queryBuilderParams.fieldApiName);
        } else if (queryBuilderParams.fieldApiName == null && (queryBuilderParams.fieldApiNames == null || queryBuilderParams.fieldApiNames.isEmpty())) {
            queryBuilderParams.fieldApiNames = new List<String>{Constants.FIELD_RECORD_ID};
        }
        if (removeRecordIdAndSecurity) {
            if (!(queryBuilderParams.aggregateParams.size() == 1 &&
                    queryBuilderParams.aggregateParams[0].aggregateFunction == Constants.AGGREGATE_FUNCTION_COUNT &&
                    (queryBuilderParams.aggregateParams[0].aggregateFieldApiName == null ||
                            queryBuilderParams.aggregateParams[0].aggregateFieldApiName == Constants.LITERAL_EMPTY))) {
                queryBuilderParams.isSecurityEnforced = false;
            } else {
                queryBuilderParams.havingClauseCondition = null;
            }
            if (queryBuilderParams.fieldApiNames.indexOf(Constants.FIELD_RECORD_ID) != -1) {
                queryBuilderParams.fieldApiNames.remove(queryBuilderParams.fieldApiNames.indexOf(Constants.FIELD_RECORD_ID));
            }
        }
        return queryBuilderParams.fieldApiNames;
    }

    // !Todo: Enhancements in query, make use of fieldset, queryAllAccessable, queryAllCreateable, queryAllUpdateable, additionalFields
    // !Todo: Validate object and field names, aggregatequeryfunction, handle exceptions on invalid functions
    // !Todo: Escaping string
    public with sharing class QueryBuilderParameters{

        // Object

        public String objectName;

        // Fields

        public String fieldApiName;

        public List<String> fieldApiNames;

        public String fieldSetName;

        // Where clause

        public String whereClauseCondition;

        // Sort

        public String sortField;

        public String sortDirection;

        // Limit clause

        public Integer recordLimit;

        // Offset clause

        public Integer offset;

        // Security

        public Boolean isSecurityEnforced = true;

        // IN and NOT IN Clause

        public Boolean addWhereInClause = false;

        public Boolean addWhereNotInClause = false;

        public String whereInOrNotInField;

        public List<String> stringList;

        public List<Decimal> numberList;

        // Aggregate Functions

        public List<AggregateParameters> aggregateParams;

        // Having clause

        public String havingClauseCondition;

        public Boolean queryAllRows = false;
    }

    public with sharing class AggregateParameters{
        
        public String aggregateFunction;

        public String aggregateFieldApiName;

        public String aggregateFieldAlias;
    }
}