import os
import inspect

from datetime import datetime

from .utility.trace.Logger import Logger
from .component.statemachine.Error import StateMachineError
from .component.statemachine.StateMachinePool import StateMachinePool


class sm_engine():
    """
    This class is the API class of the Python/Qt State Machine engine
    This is the entry point of the SM ENGINE module
    """

    def __init__(self):
        self.stateMachinePool = None

    def initLib(self, pDebugMode, pQtEventLoop, pWorkspace):
        """
        Initialization method (should be call at first)

        Args:
            pDebugMode (bool) : debug mode activation
            pQtEventLoop (bool) : QT event loop activation - deprecated
            pWorkspace (str) : workspace path - deprecated

        Returns:
            (bool) True for success, False otherwise
        """
        ret = True
        # Create the unique logger of the SM engine
        logger = Logger("/home/ute/traces/Cockpit/sm_engine.log")
        if logger is None:
            print("[ERROR]" +
                  __file__ +
                  ":" +
                  str(inspect.currentframe().f_lineno) +
                  "> Can not create logger")
        if self.stateMachinePool is None:
            self.stateMachinePool = StateMachinePool(pDebugMode)
        else:
            if self.stateMachinePool is not None:
                self.stateMachinePool.setLastError(
                    StateMachineError.INIT_ALREADY_DONE)
            ret = False

        if ret is True:
            Logger.logDEBUG(__file__, "[API] initLib ok")
        else:
            Logger.logDEBUG(__file__, "[API] initLib ko")
        return ret

    def exitLib(self):
        """
        Exit method (should be call at last)

        Returns:
            (bool) True for success, False otherwise
        """
        Logger.logDEBUG(__file__, "[API] exitLib +")
        ret = False
        if self.stateMachinePool is None:
            exit(0)
        Logger.logDEBUG(__file__, "[API] exitLib -")
        return ret

    def loadStateMachine(self, pSmFile):
        """
        Load a state machine (.sm) method

        Args:
            pSmFile (str) : state machine filename (.sm)

        Returns:
            (bool) True for success, False otherwise
        """
        Logger.logDEBUG(__file__, "[API] loadStateMachine + " + pSmFile)
        ret = True
        if self.stateMachinePool is not None:
            self.stateMachinePool.addStateMachine(pSmFile)
        else:
            ret = False
        if ret:
            Logger.logDEBUG(__file__, "[API] loadStateMachine - ok")
        else:
            Logger.logDEBUG(__file__, "[API] loadStateMachine - ko")
        return ret

    def addKpi(self, pKpiName, pKpiShortName, pSmFile):
        """
        Add a kpi method

        Args:
            pKpiName (str) : name of the kpi
            pKpiShortName (str) : short name of the kpi - deprecated
            pSmFile (str) : state machine filename linked to the kpi

        Returns:
            (bool) True for success, False otherwise
        """
        Logger.logDEBUG(__file__, "[API] addKpi")
        ret = False
        if self.stateMachinePool is not None:
            self.stateMachinePool.addKpi(pKpiName, pKpiShortName, pSmFile)
            ret = True
        return ret

    def start(self):
        """
        Start method
        Should be call after state machine loading and kpi adding

        Returns:
            (bool) True for success, False otherwise
        """
        Logger.logDEBUG(__file__, "[API] start")
        ret = False
        if self.stateMachinePool is not None:
            self.stateMachinePool.start()
            ret = True
        return ret

    def stop(self):
        """
        Stop method
        Should be call after processing

        Returns:
            (bool) True for success, False otherwise
        """
        Logger.logDEBUG(__file__, "[API] stop")
        ret = False
        if self.stateMachinePool is not None:
            self.stateMachinePool.stop()
            ret = True
        return ret

    def setTimestamp(self, pTimestamp):
        """
        Set timestamp method
        Should be call before each call to processEvent method

        Args:
            pTimestamp (str / float) : timestamp value to string ("%Y/%m/%d %H:%M:%S.%f") or float (epoch time)

        Returns:
            (bool) True for success, False otherwise
        """
        Logger.logDEBUG(__file__, "[API] setTimestamp")
        ret = False
        if self.stateMachinePool is not None:
            if isinstance(pTimestamp, str):
                self.stateMachinePool.setCurrentTimestamp(
                    datetime.strptime(pTimestamp, "%Y/%m/%d %H:%M:%S.%f"))
                ret = True
            elif isinstance(pTimestamp, float) or isinstance(pTimestamp, int):
                self.stateMachinePool.setCurrentTimestamp(
                    datetime.utcfromtimestamp(pTimestamp))
                ret = True
            elif isinstance(pTimestamp, datetime):
                self.stateMachinePool.setCurrentTimestamp(pTimestamp)
                ret = True
        return ret

    def addEvent(self, pEvent, pValue):
        """
        Add event / value pair method

        Args:
            pEvent (str) : event key
            pValue (str/int/float/bool) : event value

        Returns:
            (bool) True for success, False otherwise
        """
        Logger.logDEBUG(
            __file__,
            "[API] addEvent " +
            pEvent +
            "=" +
            str(pValue))
        ret = False
        if self.stateMachinePool is not None:
            ret = self.stateMachinePool.addEvent(pEvent, pValue)
        return ret

    def processEvent(self):
        """
        State machine processing method

        Returns:
            (bool) True for success, False otherwise
        """
        Logger.logDEBUG(__file__, "[API] processEvent +")
        ret = True
        if self.stateMachinePool is not None:
            i = 0
            self.stateMachinePool.processEvents()
        else:
            ret = False
        if ret is True:
            Logger.logDEBUG(__file__, "[API] processEvent - ok")
        else:
            Logger.logDEBUG(__file__, "[API] processEvent - ko")
        return ret

    def getLastError(self):
        """
        Last error information method
            0 = No error
            1 = Initialization not done
            2 = Event key already exist
            3 = State machine file error
            4 = State machine not valid
            5 = State machine already exist
            6 = Initialization already done
            7 = Python check error

        Returns:
            (int) Last code error
        """
        ret = StateMachineError.NOT_INIT
        if self.stateMachinePool is not None:
            ret = self.stateMachinePool.getLastError()
        return ret

    def getReport(self, pType="TXT", pFilename=None, pClear=False):
        """
        Report method (smReport and variable)

        Args:
            pType (str) : export type (TXT/JSON)(TXT by default)
            pFilename (str) : export filename (None by default)
            pClear (bool) : clear report & variable report data after export (False by default)

        Returns:
            (str) Report data for success, None otherwise
        """
        ret = None
        if self.stateMachinePool is not None:
            ret = self.stateMachinePool.stateMachineReport_.getReportInfo(
                pType, pFilename, pClear)
            # clear report data
            if pClear:
                self.stateMachinePool.stateMachineReport_.clear()
                self.stateMachinePool.stateMachineVariable_.clear()
        return ret

    def getJsonReportList(self, pFilename=None, pClear=False):
        """
        JSON report in list method (smReport and variable)

        Args:
            pFilename (str) : export filename (None by default)
            pClear (bool) : clear report & variable report data after export (False by default)

        Returns:
            (list) Report data list for success, None otherwise
        """
        ret = None
        if self.stateMachinePool is not None:
            ret = self.stateMachinePool.stateMachineReport_.getReportInfoJsonList(
                pFilename, pClear)
            # clear report data
            if pClear:
                self.stateMachinePool.stateMachineReport_.clear()
                self.stateMachinePool.stateMachineVariable_.clear()
        return ret

    def getDebug(self, pFilename=None):
        """
        Report debug data method

        Args:
            pFilename (str) : export filename (None by default)

        Returns:
            (str) Debug data for success, None otherwise
        """
        ret = None
        if self.stateMachinePool is not None and self.stateMachinePool.stateMachineDebug_ is not None:
            ret = self.stateMachinePool.stateMachineDebug_.getDebugInfo(
                pFilename)
        return ret

    def getEvent(self):
        """
        Event information method

        Returns:
            (str) All event / value pair added for current processing step, None otherwise
        """
        ret = None
        if self.stateMachinePool is not None:
            ret = self.stateMachinePool.getEventInfo()
        return ret

    def getVariable(self):
        """
        Report variable data method

        Returns:
            (str) Variable data for success, None otherwise
        """
        ret = None
        if self.stateMachinePool is not None:
            ret = self.stateMachinePool.stateMachineVariable_.getVariableInfo()
        return ret

    def getVarValue(self, pVar):
        """
        Variable vlaue method

        Args:
            pVar (str) : variable name

        Returns:
            (variant) Variable value for success, None otherwise
        """
        ret = None
        if self.stateMachinePool is not None:
            ret = self.stateMachinePool.getVarValue(pVar)
        return ret

    def getCurrentState(self, pSmName):
        """
        Get current state of a given SM in pool

        Args:
            pSmName (str) : State Machine name (without path or extension)

        Returns:
            (variant) state name or None
        """
        ret = None
        if self.stateMachinePool is not None:
            ret = self.stateMachinePool.getVarValue(pSmName)
        return ret

    def getInputVariable(self):
        """
        Input variable information method

        Returns:
            (str) Input state machine variable for success, None otherwise
        """
        ret = None
        if self.stateMachinePool is not None:
            ret = self.stateMachinePool.getInputVariable()
        return ret

    def getKpiResult(self, pType="TXT", pFilename=None, pClear=False):
        """
        Report kpi data method

        Args:
            pType (str) : export type (TXT/JSON)(TXT by default)
            pFilename (str) : export filename (None by default)
            pClear (bool) : clear kpi report data after export (False by default)

        Returns:
            (str) Kpi data for success, None otherwise
        """
        ret = None
        if self.stateMachinePool is not None:
            ret = self.stateMachinePool.getKpiResult(pType, pFilename, pClear)
        return ret
