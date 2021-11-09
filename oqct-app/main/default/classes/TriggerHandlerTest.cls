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
@isTest
private with sharing class TriggerHandlerTest {

    // Constants
    private static final String METHOD_BEFORE_INSERT = 'beforeInsert';
    private static final String METHOD_BEFORE_UPDATE = 'beforeUpdate';
    private static final String METHOD_BEFORE_DELETE = 'beforeDelete';
    private static final String METHOD_AFTER_INSERT = 'afterInsert';
    private static final String METHOD_AFTER_UPDATE = 'afterUpdate';
    private static final String METHOD_AFTER_DELETE = 'afterDelete';
    private static final String METHOD_AFTER_UNDELETE = 'afterUndelete';

    private static String lastMethodCalled;

    private static TriggerHandlerTest.TestHandler handler;

    static {
        handler = new TriggerHandlerTest.TestHandler();
        // override its internal trigger detection
        handler.isTriggerExecuting = true;
    }

    /***************************************
     * unit tests
     ***************************************/

    // contexts tests

    @isTest
    private static void testBeforeInsert() {
        beforeInsertMode();
        handler.run();
        System.assertEquals(TriggerHandlerTest.METHOD_BEFORE_INSERT, lastMethodCalled, 'last method should be beforeInsert');
    }

    @isTest
    private static void testBeforeUpdate() {
        beforeUpdateMode();
        handler.run();
        System.assertEquals(TriggerHandlerTest.METHOD_BEFORE_UPDATE, lastMethodCalled, 'last method should be beforeUpdate');
    }

    @isTest
    private static void testBeforeDelete() {
        beforeDeleteMode();
        handler.run();
        System.assertEquals(TriggerHandlerTest.METHOD_BEFORE_DELETE, lastMethodCalled, 'last method should be beforeDelete');
    }

    @isTest
    private static void testAfterInsert() {
        afterInsertMode();
        handler.run();
        System.assertEquals(TriggerHandlerTest.METHOD_AFTER_INSERT, lastMethodCalled, 'last method should be afterInsert');
    }

    @isTest
    private static void testAfterUpdate() {
        afterUpdateMode();
        handler.run();
        System.assertEquals(TriggerHandlerTest.METHOD_AFTER_UPDATE, lastMethodCalled, 'last method should be afterUpdate');
    }

    @isTest
    private static void testAfterDelete() {
        afterDeleteMode();
        handler.run();
        System.assertEquals(TriggerHandlerTest.METHOD_AFTER_DELETE, lastMethodCalled, 'last method should be afterDelete');
    }

    @isTest
    private static void testAfterUndelete() {
        afterUndeleteMode();
        handler.run();
        System.assertEquals(TriggerHandlerTest.METHOD_AFTER_UNDELETE, lastMethodCalled, 'last method should be afterUndelete');
    }

    @isTest 
    private static void testNonTriggerContext() {
        try{
        handler.run();
        System.assert(false, 'the handler ran but should have thrown');
        } catch(DataCleanCustomExceptions.TriggerHandlerException te) {
        System.assertEquals(TriggerHandler.TRIGGER_CONTEXT_ERROR, te.getMessage(), 'the exception message should match');
        } catch(Exception e) {
        System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }
    }

    // test bypass api

    @isTest
    private static void testBypassAPI() {
        afterUpdateMode();

        // test a bypass and run handler
        TriggerHandler.bypass('TestHandler');
        handler.run();
        System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
        System.assertEquals(true, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();

        // clear that bypass and run handler
        TriggerHandler.clearBypass('TestHandler');
        handler.run();
        System.assertEquals(TriggerHandlerTest.METHOD_AFTER_UPDATE, lastMethodCalled, 'last method called should be afterUpdate');
        System.assertEquals(false, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();

        // test a re-bypass and run handler
        TriggerHandler.bypass('TestHandler');
        handler.run();
        System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
        System.assertEquals(true, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();

        // clear all bypasses and run handler
        TriggerHandler.clearAllBypasses();
        handler.run();
        System.assertEquals(TriggerHandlerTest.METHOD_AFTER_UPDATE, lastMethodCalled, 'last method called should be afterUpdate');
        System.assertEquals(false, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();
    }

    // instance method tests

    @isTest
    private static void testLoopCount() {
        beforeInsertMode();
        
        // set the max loops to 2
        handler.setMaxLoopCount(2);

        // run the handler twice
        handler.run();
        handler.run();

        // clear the tests
        resetTest();

        try {
        // try running it. This should exceed the limit.
        handler.run();
        // System.assert(false, 'the handler should throw on the 3rd run when maxloopcount is 3');
        } catch(DataCleanCustomExceptions.TriggerHandlerException te) {
        // we're expecting to get here
        System.assertEquals(null, lastMethodCalled, 'last method should be null');
        } catch(Exception e) {  
        System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }

        // clear the tests
        resetTest();

        // now clear the loop count
        handler.clearMaxLoopCount();

        try {
        // re-run the handler. We shouldn't throw now.
        handler.run();
        System.assertEquals(TriggerHandlerTest.METHOD_BEFORE_INSERT, lastMethodCalled, 'last method should be beforeInsert');
        } catch(DataCleanCustomExceptions.TriggerHandlerException te) {
        System.assert(false, 'running the handler after clearing the loop count should not throw');
        } catch(Exception e) {  
        System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }
    }

    @isTest
    private static void testLoopCountClass() {
        TriggerHandler.LoopCount lc = new TriggerHandler.LoopCount();
        System.assertEquals(5, lc.getMax(), 'max should be five on init');
        System.assertEquals(0, lc.getCount(), 'count should be zero on init');

        lc.increment();
        System.assertEquals(1, lc.getCount(), 'count should be 1');
        System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 1');

        lc.increment();
        lc.increment();
        lc.increment();
        lc.increment();
        System.assertEquals(5, lc.getCount(), 'count should be 5');
        System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 5');

        lc.increment();
        System.assertEquals(6, lc.getCount(), 'count should be 6');
        System.assertEquals(true, lc.exceeded(), 'should not be exceeded with count of 6');
    }

    // private method tests

    @isTest 
    private static void testGetHandlerName() {
        System.assertEquals('TestHandler', handler.getHandlerName(), 'handler name should match class name');
    }

    // test virtual methods
    
    @isTest
    private static void testVirtualMethods() {
        TriggerHandler h = new TriggerHandler();
        h.beforeInsert();
        h.beforeUpdate();
        h.beforeDelete();
        h.afterInsert();
        h.afterUpdate();
        h.afterDelete();
        h.afterUndelete();
        System.assertNotEquals(null, h, 'Trigger handler is null');
    }

    /***************************************
     * testing utilities
     ***************************************/

    private static void resetTest() {
        lastMethodCalled = null;
    }

    // modes for testing

    private static void beforeInsertMode() {
        handler.setTriggerContext(TriggerHandler.TRIGGER_CONTEXT_BEFORE_INSERT, true);
    }

    private static void beforeUpdateMode() {
        handler.setTriggerContext(TriggerHandler.TRIGGER_CONTEXT_BEFORE_UPDATE, true);
    }

    private static void beforeDeleteMode() {
        handler.setTriggerContext(TriggerHandler.TRIGGER_CONTEXT_BEFORE_DELETE, true);
    }

    private static void afterInsertMode() {
        handler.setTriggerContext(TriggerHandler.TRIGGER_CONTEXT_AFTER_INSERT, true);
    }

    private static void afterUpdateMode() {
        handler.setTriggerContext(TriggerHandler.TRIGGER_CONTEXT_AFTER_UPDATE, true);
    }

    private static void afterDeleteMode() {
        handler.setTriggerContext(TriggerHandler.TRIGGER_CONTEXT_AFTER_DELETE, true);
    }

    private static void afterUndeleteMode() {
        handler.setTriggerContext(TriggerHandler.TRIGGER_CONTEXT_AFTER_UNDELETE, true);
    }

    // test implementation of the TriggerHandler

    private with sharing class TestHandler extends TriggerHandler {

        public override void beforeInsert() {
            TriggerHandlerTest.lastMethodCalled = TriggerHandlerTest.METHOD_BEFORE_INSERT;
        }

        public override void  beforeUpdate() {
            TriggerHandlerTest.lastMethodCalled = TriggerHandlerTest.METHOD_BEFORE_UPDATE;
        }

        public override void beforeDelete() {
            TriggerHandlerTest.lastMethodCalled = TriggerHandlerTest.METHOD_BEFORE_DELETE;
        }

        public override void afterInsert() {
            TriggerHandlerTest.lastMethodCalled = TriggerHandlerTest.METHOD_AFTER_INSERT;
        }

        public override void afterUpdate() {
            TriggerHandlerTest.lastMethodCalled = TriggerHandlerTest.METHOD_AFTER_UPDATE;
        }

        public override void afterDelete() {
            TriggerHandlerTest.lastMethodCalled = TriggerHandlerTest.METHOD_AFTER_DELETE;
        }

        public override void afterUndelete() {
            TriggerHandlerTest.lastMethodCalled = TriggerHandlerTest.METHOD_AFTER_UNDELETE;
        }

    }
	
}