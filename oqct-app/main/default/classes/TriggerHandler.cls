/**
 * @description       : NA
 * @author            : Krrish Joy
 * @group             : OQCT Limited
 * @last modified on  : 2021-03-20
 * @last modified by  : Krrish Joy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   2020-12-05   Krrish Joy   Initial Version
**/
public with sharing virtual class TriggerHandler {

    // Constants
    @TestVisible private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';
    @TestVisible private static final String TRIGGER_MAX_LOOP_COUNT_ERROR = 'Maximum loop count of {0} reached in {1}';
    @TestVisible private static final String TRIGGER_CONTEXT_BEFORE_INSERT = 'before insert';
    @TestVisible private static final String TRIGGER_CONTEXT_BEFORE_UPDATE = 'before update';
    @TestVisible private static final String TRIGGER_CONTEXT_BEFORE_DELETE = 'before delete';
    @TestVisible private static final String TRIGGER_CONTEXT_AFTER_INSERT = 'after insert';
    @TestVisible private static final String TRIGGER_CONTEXT_AFTER_UPDATE = 'after update';
    @TestVisible private static final String TRIGGER_CONTEXT_AFTER_DELETE = 'after delete';
    @TestVisible private static final String TRIGGER_CONTEXT_AFTER_UNDELETE = 'after undelete';

    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
  
    // the current context of the trigger, overridable in tests
    @TestVisible
    private System.TriggerOperation context;
  
    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;
  
    // static initialization
    static {
      loopCountMap = new Map<String, LoopCount>();
      bypassedHandlers = new Set<String>();
    }
    
    // constructor
    public TriggerHandler() {
      this.setTriggerContext();
    }
  
    /***************************************
     * public instance methods
     ***************************************/
  
    // main method that will be called during execution
    public void run() {
  
      if (!validateRun()) {
        return;
      }
      
      if(!addToLoopCount()){
        this.clearMaxLoopCount();
        this.setCurrentLoopCount(0);
        return;
      }
  
      // dispatch to the correct handler method
      switch on this.context {
        when BEFORE_INSERT {
          this.beforeInsert();
        }
        when BEFORE_UPDATE {
          this.beforeUpdate();
        }
        when BEFORE_DELETE {
          this.beforeDelete();
        }
        when AFTER_INSERT {
          this.afterInsert();
        }
        when AFTER_UPDATE {
          this.afterUpdate();
        }
        when AFTER_DELETE {
          this.afterDelete();
        }
        when AFTER_UNDELETE {
          this.afterUndelete();
        }
      }
    }

    public Integer getCurrentLoopCount() {
      String handlerName = getHandlerName();
      return TriggerHandler.loopCountMap.get(handlerName).getCount();
    }

    public void setCurrentLoopCount(Integer count) {
      String handlerName = getHandlerName();
      TriggerHandler.loopCountMap.get(handlerName).setCount(count);
    }
  
    public void setMaxLoopCount(Integer max) {
      String handlerName = getHandlerName();
      if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
        TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
      } else {
        TriggerHandler.loopCountMap.get(handlerName).setMax(max);
      }
    }
  
    public void clearMaxLoopCount() {
      this.setMaxLoopCount(-1);
    }
  
    /***************************************
     * public static methods
     ***************************************/
  
    public static void bypass(String handlerName) {
      TriggerHandler.bypassedHandlers.add(handlerName);
    }
  
    public static void clearBypass(String handlerName) {
      TriggerHandler.bypassedHandlers.remove(handlerName);
    }
  
    public static Boolean isBypassed(String handlerName) {
      return TriggerHandler.bypassedHandlers.contains(handlerName);
    }
  
    public static void clearAllBypasses() {
      TriggerHandler.bypassedHandlers.clear();
    }
  
    /***************************************
     * private instancemethods
     ***************************************/
  
    @TestVisible
    private void setTriggerContext() {
      this.setTriggerContext(null, false);
    }
  
    @TestVisible
    @SuppressWarnings('PMD.CognitiveComplexity')
    private void setTriggerContext(String ctx, Boolean testMode) {
      if (!Trigger.isExecuting && !testMode) {
        this.isTriggerExecuting = false;
        return;
      } else {
        this.isTriggerExecuting = true;
      }
      
      if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
          (ctx != null && ctx == TriggerHandler.TRIGGER_CONTEXT_BEFORE_INSERT)) {
        this.context = TriggerOperation.BEFORE_INSERT;
      } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
          (ctx != null && ctx == TriggerHandler.TRIGGER_CONTEXT_BEFORE_UPDATE)){
        this.context = TriggerOperation.BEFORE_UPDATE;
      } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
          (ctx != null && ctx == TriggerHandler.TRIGGER_CONTEXT_BEFORE_DELETE)) {
        this.context = TriggerOperation.BEFORE_DELETE;
      } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
          (ctx != null && ctx == TriggerHandler.TRIGGER_CONTEXT_AFTER_INSERT)) {
        this.context = TriggerOperation.AFTER_INSERT;
      } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
          (ctx != null && ctx == TriggerHandler.TRIGGER_CONTEXT_AFTER_UPDATE)) {
        this.context = TriggerOperation.AFTER_UPDATE;
      } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
          (ctx != null && ctx == TriggerHandler.TRIGGER_CONTEXT_AFTER_DELETE)) {
        this.context = TriggerOperation.AFTER_DELETE;
      } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
          (ctx != null && ctx == TriggerHandler.TRIGGER_CONTEXT_AFTER_UNDELETE)) {
        this.context = TriggerOperation.AFTER_UNDELETE;
      }
    }
  
    // increment the loop count
    @TestVisible
    private Boolean addToLoopCount() {
      String handlerName = getHandlerName();
      if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
        Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
        if (exceeded) {
          return false;
          // Throw exeption on max loop reach;
          // Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
          // List<String> maxLoopCountErrorStringFormatter = new List<String>();
          // maxLoopCountErrorStringFormatter.add(String.valueOf(max));
          // maxLoopCountErrorStringFormatter.add(String.valueOf(handlerName));
          // String maxLoopCountErrorString = String.format(TriggerHandler.TRIGGER_MAX_LOOP_COUNT_ERROR, maxLoopCountErrorStringFormatter);
          // throw new DataCleanCustomExceptions.TriggerHandlerException(maxLoopCountErrorString);
        }
      }
      return true;
    }
  
    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
      if (!this.isTriggerExecuting || this.context == null) {
        throw new DataCleanCustomExceptions.TriggerHandlerException(TriggerHandler.TRIGGER_CONTEXT_ERROR);
      }
      return !TriggerHandler.bypassedHandlers.contains(getHandlerName());
    }
  
    @TestVisible
    private String getHandlerName() {
      return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
  
    /***************************************
     * context methods
     ***************************************/
  
    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert(){}
    @TestVisible
    protected virtual void beforeUpdate(){}
    @TestVisible
    protected virtual void beforeDelete(){}
    @TestVisible
    protected virtual void afterInsert(){}
    @TestVisible
    protected virtual void afterUpdate(){}
    @TestVisible
    protected virtual void afterDelete(){}
    @TestVisible
    protected virtual void afterUndelete(){}
  
    /***************************************
     * inner classes
     ***************************************/
  
    // inner class for managing the loop count per handler
    @TestVisible
    private with sharing class LoopCount {
      private Integer max;
      private Integer count;
  
      public LoopCount() {
        this.max = 5;
        this.count = 0;
      }
  
      public LoopCount(Integer max) {
        this.max = max;
        this.count = 0;
      }
  
      public Boolean increment() {
        this.count++;
        return this.exceeded();
      }
  
      public Boolean exceeded() {
        return this.max >= 0 && this.count > this.max;
      }
  
      public Integer getMax() {
        return this.max;
      }
  
      public Integer getCount() {
        return this.count;
      }

      public void setCount(Integer count) {
        this.count = count;
      }
  
      public void setMax(Integer max) {
        this.max = max;
      }
    }
  
  }