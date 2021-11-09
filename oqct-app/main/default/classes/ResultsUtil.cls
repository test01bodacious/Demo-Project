/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-18
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2021-01-06   Krrish Joy   Initial Version
**/
public with sharing class ResultsUtil {
    
    public ResultInformation resultInfo;

    public ResultsUtil(){
        resultInfo = new ResultInformation();
    }

    public static ResultsUtil initialize(ResultsUtil resultUtil){
        if (resultUtil == null) {
            resultUtil = new ResultsUtil();
        }
        return resultUtil;
    }

    public with sharing class ResultInformation{

        public Integer success;

        public Integer failure;

        public ResultInformation(){
            this.success = 0;
            this.failure = 0;
        }
    }

}