import os
import time
import sys
import smtplib
import traceback
import pysftp

from email.mime.text import MIMEText
from .StateVectorManager.StateVectorManager import StateVectorManager
from .StateVariableBuilder.Oam.OamStateVariableBuilder import OamStateVariableBuilder
from .StateVariableBuilder.Emil.EmilStateVariableBuilder import EmilStateVariableBuilder
from .StateVariableBuilder.Sherpa.SherpaStateVariableBuilder import SherpaStateVariableBuilder
from .StateVariableBuilder.SysLog.SysLogStateVariableBuilder import SysLogStateVariableBuilder
from .StateVariableBuilder.TtiTrace.TtiTraceStateVariableBuilder import TtiTraceStateVariableBuilder
from .StateVariableBuilder.Tshark.TsharkStateVariableBuilder import TsharkStateVariableBuilder
from .StateVariableBuilder.Tshark.L1L2StateVariableBuilder import Class_L1L2StateVariableBuilder
from .StateVariableBuilder.Tshark.PETsharkStateVariableBuilder import Class_PETsharkStateVariableBuilder

# from EquipmentInterface.Prisma.PrismaInterface import *
# from EquipmentInterface.Spirent.SpirentInterface import *

from .smengine.SmEngineInterface import SmEngineInterface
from .Cockpit_Debug import debugWrite
from .Cockpit_Config import ConfigClass


# ----------------
class Cockpit_Actions:
    # ----------------
    """
        This class implements interface methods for all Cockpit actions.
        Following methods can be used by users, others are deprecated or reserved for internal use.
        Details about each method is given in "Static methods" section.

        Methods related to Campaign:
        - campaignSetup
        - campaignTeardown

        Methods related to Test:
        - prepareTest
        - checkTest

        Methods related to State Vector Manager:
        - startStateVectorManager
        - stopStateVectorManager

        Methods related to Use Case Detectors:
        - launchUseCaseDetectors

        Methods related to OAM State Variable Builder:
        - startOamStateVariableBuilder
        - stopOamStateVariableBuilder

        Methods related to EMIL State Variable Builder:
        - startEmilStateVariableBuilder
        - stopEmilStateVariableBuilder(self)

        Methods related to SHERPA State Variable Builder:
        - startSherpaStateVariableBuilder
        - waitSherpaStateVariableBuilderCounter
        - getSherpaStateVariableBuilderCounters
        - stopSherpaStateVariableBuilder

        Methods related to SYSLOG State Variable Builder:
        - startSysLogStateVariableBuilder
        - waitSysLogStateVariableBuilderCounter
        - getSysLogStateVariableBuilderCounters
        - stopSysLogStateVariableBuilder

        Methods related to TTI Trace State Variable Builder:
        - startTtiTraceStateVariableBuilder
        - stopTtiTraceStateVariableBuilder

        Methods related to TSHARK State Variable Builder:
        - startTsharkStateVariableBuilder
        - waitTsharkStateVariableBuilderCounter
        - getTsharkStateVariableBuilderDecodedFrame
        - getTsharkStateVariableBuilderCounters
        - stopTsharkStateVariableBuilder

        Methods related to PRISMA Interface:
        - startPrismaInterfaceS1
        - stopPrismaInterfaceS1
        - startPrismaInterfaceUu
        - stopPrismaInterfaceUu

        Methods related to SPIRENT Interface:
        - startSpirentVertex
        - stopSpirentVertex

        Generic method:
        - stop(self):

        Other methods are deprecated or reserved for internal use.
        Details about each method is given in "Static methods" section.
    """

    def __init__(self, debug=None, config=None, endApplication=None):
        """
            This method is called by Cockpit main program or by users in case no GUI is needed
            No parameter needed in case of no GUI
        """

        self._debug = debug
        if config is not None:
            self._config = config
        else:
            self._config = ConfigClass()
        if endApplication is not None:
            self._endApplication = endApplication
        else:
            self._endApplication = self.stop
        self._stateVectorManager = None
        self._oamStateVariableBuilder = {}
        self._emilStateVariableBuilder = None
        self._sysLogStateVariableBuilder = {}
        self._sherpaStateVariableBuilder = {}
        self._ttiTraceStateVariableBuilder = None
        self._tsharkStateVariableBuilder = {}
        self._L1L2StateVariableBuilder = {}
        self._PETsharkStateVariableBuilder = {}
        self._startTimestamp = time.strftime(
            "%Y%m%d-%Hh%Mm%Ss", time.localtime())
        # self._startTimestamp = time.strftime("%Y%m%d", time.localtime())
        self._traceDirectory = self._config.traceDirectory + \
            "/" + self._startTimestamp + "/"
        debugWrite(self._traceDirectory)
        self._defaultTestLine = list(self._config.tlConfig)[0]
        self._smEngineInterface = SmEngineInterface(
            self._config.useCaseDetectorDirectory)
        self._campaignTestResult = ""
        self._patternForTestOK = " OK"
        self._patternForTestNotOK = " FAILED"
        self._lengthOfNotOkPattern = self._patternForTestNotOK.__len__()
        self._tlConfigFromLogbook = ""
        self._campaignStartTime = 0.0
        self._testStartTime = 0.0

    # ---------------- BASIC actions

    def campaignSetup(self, testLine=None, campaignName="TBD", sendMail=True):
        """
            To be called at start of campaign.
            Parameter sendMail to indicate if the start_campaign mail has to be sent.
        """
        self._config.createConfig(testLine)
        testLineNumber = 'CV' + testLine.split('.')[-1]
        self._campaignTestResult = ""
        self._campaignStartTime = time.time()
        if sendMail:
            self._LogBookGetTLConfig(gNodebName=testLineNumber)
            content = self._tlConfigFromLogbook
            parSubject = self._createMailTitle(
                testLineNumber) + "Start Campaign " + campaignName
            self._sendMail(
                testLineNumber,
                parSubject=parSubject,
                content=content)

    def setup(self, *args, **kwargs):
        """
            Deprecated. Please use campaignSetup.
        """
        self.campaignSetup(*args, **kwargs)

    def campaignTeardown(
            self,
            testLine=None,
            campaignName="TBD",
            status="TBD",
            details="TBD",
            sendMail=True):
        """
            To be called at end of campaign. Will close Cockpit application.
            Parameter sendMail to indicate if the stop_campaign mail has to be sent.
        """
        testLineNumber = 'CV' + testLine.split('.')[-1]
        if sendMail:
            parSubject = self._createMailTitle(testLineNumber) + \
                "Stop Campaign " + campaignName + " - Status " + status
            content = "\nGeneral Results:\n" + details + "\n\nDetailed Results:" + \
                self._campaignTestResult + self._tlConfigFromLogbook
            self._sendMail(
                testLineNumber,
                parSubject=parSubject,
                content=content)

        # self.stopPrismaInterfaceS1()
        # self.stopPrismaInterfaceUu()

        # self.stopSpirentVertex()
        # self.stopSpirentVR5()

        self._endApplication()

    def teardown(self, *args, **kwargs):
        """
            Deprecated. Please use campaignTeardown.
        """
        self.campaignTeardown(*args, **kwargs)

    # ---------------- MAIL actions

    def _createMailTitle(self, testLine=None):
        campaignTitle = "Sorry, it was impossible to create an intelligent title for this mail"
        if (testLine is not None):
            campaignTitle = testLine + " - " + \
                time.strftime("%Y%m%d - %H:%M - ")
        return campaignTitle

    def _sendMail(
            self,
            testLine=None,
            parSubject="TRY",
            content="Not Yet Implemented"):
        if testLine is None:
            testLine = self._defaultTestLine

        subjectNoCr = parSubject.replace("\n", " ")

        if len(subjectNoCr) > 120:
            subject = subjectNoCr[0:117] + "..."
        else:
            subject = subjectNoCr

        destAddr = self._config.tlConfig["logbook"]
        debugWrite("Send mail %s to %s" % (subject, destAddr))

        try:
            # debugWrite("content is : %s" % content)
            msg = MIMEText(content)

            msg['Subject'] = subject
            msg['From'] = "richard.duthu@nokia.com"
            msg['To'] = destAddr

            s = smtplib.SMTP("135.120.130.211", 25)
            s.sendmail(
                "richard.duthu@nokia.com",
                destAddr.split(";"),
                msg.as_string())
            s.quit()
            debugWrite("Mail sent")
        except Exception:
            debugWrite("EXCEPTION")
            debugWrite(traceback.format_exc(limit=5))

    # ---------------- CONFIGURATION and PREPARE TEST actions
    def getConfig(self, testLine):
        '''
            Deprecated - Not to be called by users.
        '''
        return self._config.tlConfig

    def getConfigParam(
            self,
            testLineName,
            par1,
            par2=None,
            par3=None,
            par4=None):
        '''
            Deprecated - Not to be called by users.
            In order to get configuration parameter from robot script, please use ConfigClass. As an example:
            ${GN_OAM}= ${ConfigClass.tlConfig['${GNODEB}']['oam-0']['hostname']}.
        '''
        tlconfig = self.getConfig(testLineName)

        returnValue = tlconfig[par1]

        if par2 is not None:
            returnValue = returnValue[par2]

        if par3 is not None:
            returnValue = returnValue[par3]

        if par4 is not None:
            returnValue = returnValue[par4]

        return returnValue

    def setDefaultTestLine(self, testLine):
        '''
            Deprecated - Not to be called by users.
        '''
        self._defaultTestLine = testLine

    # ---------------- PREPARE and CHECK TEST actions

    def prepareTest(self, campaignName, testName):
        '''
            This method has to be called at the very beginning of each test.
            Test status will be set to "FAILED" as default, until checkTest method is called.
        '''
        self.stop()
        self._testStartTime = time.time()
        self._updateOutputDirectory(campaignName, testName)
        self._updateCampaignTestResult(
            "\n" + testName, self._patternForTestNotOK)

    def checkTest(self):
        '''
            This method has to be called at the very end of each test.
            After final generic checks, test status will be set to "OK"
        '''
        self._campaignTestResult = self._campaignTestResult[:-
                                                            self._lengthOfNotOkPattern]
        # debugWrite("self._campaignTestResult:%s" % self._campaignTestResult)
        self._updateCampaignTestResult(self._patternForTestOK, "")
        # debugWrite("self._campaignTestResult:%s" % self._campaignTestResult)

    def _updateOutputDirectory(self, campaignName, testName):
        self._traceDirectory = self._config.traceDirectory + "/" + \
            campaignName + "_" + self._startTimestamp + "/" + testName + "/"
        ConfigClass.campaignTraceDirectory = self._config.traceDirectory + \
            "/" + campaignName + "_" + self._startTimestamp + "/"

    def _updateCampaignTestResult(self, text1ToAdd=None, text2ToAdd=None):
        if text1ToAdd is not None:
            self._campaignTestResult += text1ToAdd
        if text2ToAdd is not None:
            self._campaignTestResult += text2ToAdd

    # ---------------- State Vector Manager actions

    def startStateVectorManager(self):
        '''
            This method starts the State Vector Manager.
            State Vector Manager role is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("startStateVectorManager")
        if self._stateVectorManager:
            debugWrite("StateVectorManager already started, stopping it")
            self.stopStateVectorManager()
            time.sleep(2)
        self._stateVectorManager = StateVectorManager(
            self._traceDirectory + "/StateVectorManager", 5001)

    def stopStateVectorManager(self):
        '''
            This method stops the State Vector Manager
        '''
        debugWrite("stopStateVectorManager")
        if self._stateVectorManager:
            self._stateVectorManager.stop()
            self._stateVectorManager = None

    def printStateVectorManager(self):
        '''
            Deprecated - Not to be called by users.
        '''
        debugWrite("printStateVectorManager")
        # if self._stateVectorManager:
        # self._stateVectorManager.print()

    # ---------------- State Machine actions

    def fillStateMachineRequiredFields(
        self,
        shortFileNames=(
            "TtiTraceMultiUe.py",
            "TtiTraceMonoUe.py")):
        '''
            Deprecated - Not to be called by users.
            This method configures the State Vector Manager with the list of fields needed by Use Case Detectors.
            It takes Use Case Detectors file names as input parameter (shortFileNames).
            State Vector Manager and Use Case Detector are defined in
            https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("fillStateMachineRequiredFields")
        stateMachineRequiredFields = self._smEngineInterface.getStateMachinesInfo(
            shortFileNames)
        if self._stateVectorManager:
            self._stateVectorManager.fillStateMachineRequiredFields(
                stateMachineRequiredFields)

    def writeSmInputFiles(self):
        '''
            Deprecated - Not to be called by users.
            This method triggers, in State Vector Manager, the writing of input files for Use Case Detectors.
            State Vector Manager and Use Case Detector are defined in
            https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("writeSmInputFiles")
        if self._stateVectorManager:
            self._stateVectorManager.writeSmInputFiles(
                self._traceDirectory + "/UseCaseDetector/")

    def launchSmAnalysis(self):
        '''
            Deprecated - Not to be called by users.
            This method triggers Use Case Detectors analysis.
            Use Case Detectors are defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("launchSmAnalysis")
        debugWrite(self._traceDirectory + "/UseCaseDetector/")
        self._smEngineInterface.launchSmAnalysis(
            self._traceDirectory + "/UseCaseDetector/")

    def launchUseCaseDetectors(
        self,
        shortFileNames=(
            "TtiTraceMultiUe.py",
            "TtiTraceMonoUe.py")):
        '''
            This method triggers Use Case Detectors analysis.
            It takes Use Case Detectors file names as input parameter (shortFileNames).
            Use Case Detectors are defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("launchUseCaseDetectors")
        self.fillStateMachineRequiredFields(shortFileNames)
        self.writeSmInputFiles()
        self.launchSmAnalysis()

    def getUseCaseDetectorCounter(self, UCD, CounterName):
        return self._smEngineInterface.getUseCaseDetectorCounter(
            UCD, CounterName)

    def checkUseCaseDetectorCounterGreater(self, UCD, CounterName, threshold):
        if self.getUseCaseDetectorCounter(UCD, CounterName) < threshold:
            raise Exception("'%s' < %f" % (CounterName, float(threshold)))
        debugWrite("Check OK: '%s' >= %f" % (CounterName, float(threshold)))

    def checkUseCaseDetectorCounterLower(self, UCD, CounterName, threshold):
        if self.getUseCaseDetectorCounter(UCD, CounterName) > threshold:
            raise Exception("'%s' > %f" % (CounterName, float(threshold)))
        debugWrite("Check OK: '%s' <= %f" % (CounterName, float(threshold)))

    def checkUseCaseDetectorRateGreater(
            self,
            UCDNum,
            CounterNameNum,
            UCDDen,
            CounterNameDen,
            threshold):
        num = self.getUseCaseDetectorCounter(UCDNum, CounterNameNum)
        den = self.getUseCaseDetectorCounter(UCDDen, CounterNameDen)
        try:
            rate = num / den
        except ZeroDivisionError:
            raise Exception(
                "Can not calculate rate as '%s' is zero" %
                (CounterNameDen))
        else:
            if rate < threshold:
                raise Exception(
                    "'%s'/'%s' < %f" %
                    (CounterNameNum, CounterNameDen, float(threshold)))
        debugWrite("Check OK: '%s'/'%s' >= %f" %
                   (CounterNameNum, CounterNameDen, float(threshold)))

    def checkUseCaseDetectorRateLower(
            self,
            UCDNum,
            CounterNameNum,
            UCDDen,
            CounterNameDen,
            threshold):
        num = self.getUseCaseDetectorCounter(UCDNum, CounterNameNum)
        den = self.getUseCaseDetectorCounter(UCDDen, CounterNameDen)
        try:
            rate = num / den
        except ZeroDivisionError:
            raise Exception(
                "Can not calculate rate as '%s' is zero" %
                (CounterNameDen))
        else:
            if rate > threshold:
                raise Exception(
                    "'%s'/'%s' > %f" %
                    (CounterNameNum, CounterNameDen, float(threshold)))
        debugWrite("Check OK: '%s'/'%s' <= %f" %
                   (CounterNameNum, CounterNameDen, float(threshold)))

    # ---------------- OAM State Variable Builder actions

    def startOamStateVariableBuilder(self, testLine=None, swModule="oam-0"):
        '''
            This method starts Oam State Variable Builder.
            Oam State Variable Builder is responsible for configuration parameter retrieval,
            and software status retrieval.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("startOamStateVariableBuilder")
        if testLine is None:
            testLine = self._defaultTestLine
        instanceName = testLine + swModule
        if instanceName in self._oamStateVariableBuilder:
            debugWrite(
                "OamStateVariableBuilder already started for %s, stopping it" %
                instanceName)
            self.stopOamStateVariableBuilder(testLine, swModule)
            time.sleep(2)
        self._oamStateVariableBuilder[instanceName] = OamStateVariableBuilder(
            self._config.tlConfig,
            swModule,
            self._traceDirectory +
            "/Config/" +
            testLine +
            "/",
            "127.0.0.1",
            5001)

    def stopOamStateVariableBuilder(self, testLine=None, swModule="oam-0"):
        '''
            This method stops Oam State Variable Builder.
            Oam State Variable Builder is responsible for configuration parameter retrieval,
            and software status retrieval.
            If first parameter is None, it stops all Oam State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("stopOamStateVariableBuilder")
        if testLine is None:
            for instanceName in self._oamStateVariableBuilder:
                self._oamStateVariableBuilder[instanceName].stop()
            self._oamStateVariableBuilder = {}
        else:
            instanceName = testLine + swModule
            self._oamStateVariableBuilder[instanceName].stop()
            del self._oamStateVariableBuilder[instanceName]

    # ---------------- EMIL State Variable Builder actions

    def startEmilStateVariableBuilder(self):
        '''
            This method starts EMIL State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("startEmilStateVariableBuilder")
        if self._emilStateVariableBuilder:
            debugWrite("EmilStateVariableBuilder already started, stopping it")
            self.stopEmilStateVariableBuilder()
            time.sleep(2)
        self._emilStateVariableBuilder = EmilStateVariableBuilder(
            "//135.120.146.217/d$/TRACES/Emil/", "127.0.0.1", 5001)
        # self._emilStateVariableBuilder = EmilStateVariableBuilder("P:/5G/Traces/2018/201803/20180307_CV29_emil/",
        # "127.0.0.1", 5001)

    def stopEmilStateVariableBuilder(self):
        '''
            This method stops EMIL State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("stopEmilStateVariableBuilder")
        if self._emilStateVariableBuilder:
            self._emilStateVariableBuilder.stop()
            self._emilStateVariableBuilder = None

    # ---------------- SHERPA State Variable Builder actions

    def startSherpaStateVariableBuilder(self, testLine=None):
        '''
            This method starts SHERPA State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("startSherpaStateVariableBuilder")
        if testLine is None:
            testLine = self._defaultTestLine
        if testLine in self._sherpaStateVariableBuilder:
            debugWrite(
                "SherpaStateVariableBuilder already started for %s, stopping it" %
                testLine)
            self.stopSherpaStateVariableBuilder(testLine)
            time.sleep(2)
        self._sherpaStateVariableBuilder[testLine] = SherpaStateVariableBuilder(
            self._config.tlConfig,
            self._traceDirectory +
            "/Sherpa/" +
            testLine +
            "/",
            "127.0.0.1",
            5001)

    def waitSherpaStateVariableBuilderCounter(
            self, counterName, counterValue, timeOut, testLine=None):
        '''
            This method waits until a counter has reached a target value in SHERPA State Variable Builder.
            An exception is raised in case of timeout.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("waitSherpaStateVariableBuilderCounter")
        if testLine is None:
            testLine = self._defaultTestLine
        return self._sherpaStateVariableBuilder[testLine].waitCounter(
            counterName, counterValue, timeOut)

    def getSherpaStateVariableBuilderCounters(self, testLine=None):
        '''
            This method returns all counters built in SHERPA State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("getSherpaStateVariableBuilderCounter")
        if testLine is None:
            testLine = self._defaultTestLine
        return self._sherpaStateVariableBuilder[testLine].getCounters()

    def stopSherpaStateVariableBuilder(self, testLine=None):
        '''
            This method stops SHERPA State Variable Builder.
            If first parameter is None, it stops all SHERPA State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("stopSherpaStateVariableBuilder")
        if testLine is None:
            # print(self._sherpaStateVariableBuilder)
            for testLine in self._sherpaStateVariableBuilder:
                # print(testLine)
                self._sherpaStateVariableBuilder[testLine].stop()
            self._sherpaStateVariableBuilder = {}
        else:
            self._sherpaStateVariableBuilder[testLine].stop()
            del self._sherpaStateVariableBuilder[testLine]

    # ---------------- SYSLOG State Variable Builder actions

    # def startSysLogStateVariableBuilder(self, testLine=None,
    # swModule="fspj-1a", shortCommand='journalctl'):
    def startSysLogStateVariableBuilder(
            self,
            testLine=None,
            swModule="oam-0",
            shortCommand='journalctl',
            startAnalysis='boot'):
        '''
            This method starts SYSLOG State Variable Builder for the given SW module.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("startSysLogStateVariableBuilder")
        if testLine is None:
            testLine = self._defaultTestLine
        instanceName = testLine + swModule + shortCommand
        if instanceName in self._sysLogStateVariableBuilder:
            debugWrite(
                "SysLogStateVariableBuilder already started for %s, stopping it" %
                instanceName)
            self.stopSysLogStateVariableBuilder(
                testLine, swModule, shortCommand)
            time.sleep(2)

        if startAnalysis == 'campaignStart':
            minimumTimeForAnalysis = self._campaignStartTime
        elif startAnalysis == 'testStart':
            minimumTimeForAnalysis = self._testStartTime
        else:
            minimumTimeForAnalysis = 0.0
        self._sysLogStateVariableBuilder[instanceName] = SysLogStateVariableBuilder(
            self._config.tlConfig,
            swModule,
            shortCommand,
            minimumTimeForAnalysis,
            self._traceDirectory +
            "/SysLog/" +
            testLine +
            "/",
            "127.0.0.1",
            5001)

    def waitSysLogStateVariableBuilderCounter(
            self,
            counterName,
            counterValue,
            timeOut,
            testLine=None,
            swModule="oam-0",
            shortCommand='journalctl'):
        '''
            This method waits until a counter has reached a target value in SYSLOG State Variable Builder.
            An exception is raised in case of timeout.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("waitSysLogStateVariableBuilderCounter enter")
        if testLine is None:
            testLine = self._defaultTestLine
        instanceName = testLine + swModule + shortCommand
        if instanceName in self._sysLogStateVariableBuilder:
            return self._sysLogStateVariableBuilder[instanceName].waitCounter(
                counterName, counterValue, timeOut)

    def getSysLogStateVariableBuilderCounters(
            self,
            testLine=None,
            swModule="oam-0",
            shortCommand='journalctl'):
        '''
            This method returns all counters built in SYSLOG State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("getSysLogStateVariableBuilderCounter")
        if testLine is None:
            testLine = self._defaultTestLine
        instanceName = testLine + swModule + shortCommand
        if instanceName in self._sysLogStateVariableBuilder:
            return self._sysLogStateVariableBuilder[instanceName].getCounters()

    def stopSysLogStateVariableBuilder(
            self,
            testLine=None,
            swModule="oam-0",
            shortCommand='journalctl'):
        '''
            This method stops SYSLOG State Variable Builder for the given SW module.
            If first parameter is None, it stops all SYSLOG State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("stopSysLogStateVariableBuilder")
        if testLine is None:
            for instanceName in self._sysLogStateVariableBuilder:
                self._sysLogStateVariableBuilder[instanceName].stop()
            self._sysLogStateVariableBuilder = {}
        else:
            instanceName = testLine + swModule + shortCommand
            self._sysLogStateVariableBuilder[instanceName].stop()
            del self._sysLogStateVariableBuilder[instanceName]

    # ---------------- TTI Trace State Variable Builder actions

    def startTtiTraceStateVariableBuilder(
            self, testLine=None, swModule="fct-1-0b"):
        '''
            This method starts TTI Trace State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("startTtiTraceStateVariableBuilder")
        if testLine is None:
            testLine = self._defaultTestLine
        if self._ttiTraceStateVariableBuilder:
            debugWrite(
                "TtiTraceStateVariableBuilder already started, stopping it")
            self.stopTtiTraceStateVariableBuilder(testLine, swModule)
            time.sleep(2)
        self._ttiTraceStateVariableBuilder = TtiTraceStateVariableBuilder(
            self._config.tlConfig,
            swModule,
            "/var/ttiTrace/",
            self._traceDirectory +
            "/TtiTrace/",
            "127.0.0.1",
            5001)
        # self._ttiTraceStateVariableBuilder = \
        #     TtiTraceStateVariableBuilder("135.120.146.224", "_rcpadmin", "RCP_owner", "/var/ttiTrace/",
        #                                  "c:/TRACES/StateVariableBuilder/TtiTrace/", "127.0.0.1", 5001)

    def stopTtiTraceStateVariableBuilder(
            self, testLine=None, swModule="fct-1-0b"):
        '''
            This method stops TTI Trace State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("stopTtiTraceStateVariableBuilder")
        if testLine is None:
            testLine = self._defaultTestLine
        if self._ttiTraceStateVariableBuilder:
            # debugWrite("ttiTraceStateVariableBuilder.stop enter cockpit_actions")
            self._ttiTraceStateVariableBuilder.stop()
            self._ttiTraceStateVariableBuilder = None

    # ---------------- TSHARK State Variable Builder actions

    def startTsharkStateVariableBuilder(
            self,
            testLine=None,
            swModule="asik",
            itf="etha01",
            filter=""):
        '''
            This method starts TSHARK State Variable Builder for the given SW module and network interface.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("startTsharkStateVariableBuilder")
        if testLine is None:
            testLine = self._defaultTestLine
        instanceName = testLine + swModule + itf
        if instanceName in self._tsharkStateVariableBuilder:
            debugWrite(
                "TsharkStateVariableBuilder already started for %s, stopping it" %
                instanceName)
            self.stopTsharkStateVariableBuilder(testLine, swModule, itf)
            time.sleep(2)
        self._tsharkStateVariableBuilder[instanceName] = TsharkStateVariableBuilder(
            self._config.tlConfig,
            swModule,
            itf,
            self._traceDirectory +
            "/Tshark/" +
            testLine +
            "/" +
            itf +
            "/",
            "127.0.0.1",
            5001,
            tsharkMode="Analyze",
            fieldList=(
                "DlData_PatternConfigReq_t.sfn",
            ),
            tsharkDissector=self._config.wiresharkDissector,
            filter=filter)

    def waitTsharkStateVariableBuilderCounter(
            self,
            counterName,
            counterValue,
            timeOut,
            testLine=None,
            swModule="cpif-0",
            itf="backhaul"):
        '''
            This method waits until a counter has reached a target value in TSHARK State Variable Builder.
            An exception is raised in case of timeout.
            It returns frame information useful to call getTsharkStateVariableBuilderDecodedFrame method.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("waitTsharkStateVariableBuilderCounter")
        if testLine is None:
            testLine = self._defaultTestLine
        instanceName = testLine + swModule + itf
        return self._tsharkStateVariableBuilder[instanceName].waitCounter(
            counterName, counterValue, timeOut)

    def getTsharkStateVariableBuilderDecodedFrame(
            self,
            frameInfo,
            testLine=None,
            swModule="cpif-0",
            itf="backhaul"):
        '''
            This method returns a dictionary with all decoded fields.
            The parameter frameInfo is given by waitTsharkStateVariableBuilderCounter.
        '''
        debugWrite("getTsharkStateVariableBuilderDecodedFrame")
        if testLine is None:
            testLine = self._defaultTestLine
        instanceName = testLine + swModule + itf
        return self._tsharkStateVariableBuilder[instanceName].getDecodedFrame(
            frameInfo)

    def getTsharkStateVariableBuilderCounters(
            self, testLine=None, swModule="cpif-0", itf="backhaul"):
        '''
            This method returns all counters built in TSHARK State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("getTsharkStateVariableBuilderCounter")
        if testLine is None:
            testLine = self._defaultTestLine
        instanceName = testLine + swModule + itf
        return self._tsharkStateVariableBuilder[instanceName].getCounters()

    def stopTsharkStateVariableBuilder(
            self,
            testLine=None,
            swModule="cpif-0",
            itf="backhaul"):
        '''
            This method stops TSHARK State Variable Builder for the given SW module and network interface.
            If first parameter is None, it stops all TSHARK State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("stopTsharkStateVariableBuilder")
        if testLine is None:
            # print(self._tsharkStateVariableBuilder)
            for instanceName in self._tsharkStateVariableBuilder:
                # print(instanceName)
                self._tsharkStateVariableBuilder[instanceName].stop()
            self._tsharkStateVariableBuilder = {}
        else:
            instanceName = testLine + swModule + itf
            self._tsharkStateVariableBuilder[instanceName].stop()
            del self._tsharkStateVariableBuilder[instanceName]

    # ---------------- L1L2 State Variable Builder actions

    def startL1L2StateVariableBuilder(
            self,
            testLine=None,
            swModule="asik",
            itf="etha01",
            WiresharkFilter=None):
        '''
            This method starts L1L2 State Variable Builder for the given SW module and network interface.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("L1L2StateVariableBuilder")
        if testLine is None:
            testLine = self._defaultTestLine
        instanceName = testLine + swModule + itf
        if instanceName in self._L1L2StateVariableBuilder:
            debugWrite(
                "L1L2StateVariableBuilder already started for %s, stopping it" %
                instanceName)
            self.stopL1L2StateVariableBuilder(testLine, swModule, itf)
            time.sleep(2)
        self._L1L2StateVariableBuilder[instanceName] = Class_L1L2StateVariableBuilder(
            self._config.tlConfig,
            swModule,
            itf,
            self._traceDirectory +
            "/Tshark/" +
            testLine +
            "/" +
            itf +
            "/",
            "127.0.0.1",
            5001,
            tsharkDissector=self._config.wiresharkDissector,
            Filter=WiresharkFilter)

    def stopL1L2StateVariableBuilder(
            self,
            testLine=None,
            swModule="asik",
            itf="etha01"):
        '''
            This method stops L1L2 State Variable Builder for the given SW module and network interface.
            If first parameter is None, it stops all L1L2 State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("stopL1L2StateVariableBuilder")
        if testLine is None:
            # print(self._tsharkStateVariableBuilder)
            for instanceName in self._L1L2StateVariableBuilder:
                # print(instanceName)
                self._L1L2StateVariableBuilder[instanceName].F_stop()
            self._L1L2StateVariableBuilder = {}
        else:
            instanceName = testLine + swModule + itf
            self._L1L2StateVariableBuilder[instanceName].F_stop()
            del self._L1L2StateVariableBuilder[instanceName]

    # ---------------- PE Thark State Variable Builder actions

    def startPETsharkStateVariableBuilder(
            self, testLine=None, swModule="asik"):
        '''
            This method starts L1L2 State Variable Builder for the given SW module and network interface.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("PETsharkStateVariableBuilder")
        if testLine is None:
            testLine = self._defaultTestLine
        instanceName = testLine + swModule
        if instanceName in self._PETsharkStateVariableBuilder:
            debugWrite(
                "PETsharkStateVariableBuilder already started for %s, stopping it" %
                instanceName)
            self.stopPETsharkStateVariableBuilder(testLine, swModule)
            time.sleep(2)
        self._PETsharkStateVariableBuilder[instanceName] = Class_PETsharkStateVariableBuilder(
            self._config.tlConfig,
            swModule,
            self._traceDirectory +
            "/Tshark/" +
            testLine +
            "/",
            "127.0.0.1",
            5001)

    def stopPETsharkStateVariableBuilder(self, testLine=None, swModule="asik"):
        '''
            This method stops L1L2 State Variable Builder for the given SW module and network interface.
            If first parameter is None, it stops all L1L2 State Variable Builder.
            State Variable Builder is defined in https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        debugWrite("stopPETsharkStateVariableBuilder")
        if testLine is None:
            # print(self._tsharkStateVariableBuilder)
            for instanceName in self._PETsharkStateVariableBuilder:
                # print(instanceName)
                self._PETsharkStateVariableBuilder[instanceName].F_stop()
            self._PETsharkStateVariableBuilder = {}
        else:
            instanceName = testLine + swModule
            self._PETsharkStateVariableBuilder[instanceName].F_stop()
            del self._PETsharkStateVariableBuilder[instanceName]

    # ---------------- PRISMA Interface actions

    # def startPrismaInterfaceS1(self, testLine=None, swModule="lsuS1"):
    # '''
    # This method performs all steps needed to start S1 Prisma LSU
    # '''
    # debugWrite("startPrismaInterfaceS1")
    # if testLine is None:
    # testLine = self._defaultTestLine
    # startLsuS1(self._config.tlConfig[testLine][swModule]["hostname"])

    # def stopPrismaInterfaceS1(self, testLine=None, swModule="lsuS1"):
    # '''
    # This method performs all steps needed to stop S1 Prisma LSU
    # '''
    # debugWrite("stopPrismaInterfaceS1")
    # if testLine is None:
    # stopLsuS1()
    # else:
    # stopLsuS1(self._config.tlConfig[testLine][swModule]["hostname"])

    # def startPrismaInterfaceUu(self, testLine=None, swModule="lsuUu"):
    # '''
    # This method performs all steps needed to start Uu Prisma LSU
    # '''
    # debugWrite("startPrismaInterfaceUu")
    # if testLine is None:
    # testLine = self._defaultTestLine
    # startLsuUu(self._config.tlConfig[testLine][swModule]["hostname"])

    # def stopPrismaInterfaceUu(self, testLine=None, swModule="lsuUu"):
    # '''
    # This method performs all steps needed to stop Uu Prisma LSU
    # '''
    # debugWrite("stopPrismaInterfaceUu")
    # if testLine is None:
    # stopLsuUu()
    # else:
    # stopLsuUu(self._config.tlConfig[testLine][swModule]["hostname"])

    # ---------------- SPIRENT Interface actions

    # def startSpirentVertex(self, spirentId=None):
    # '''
    # This method performs all steps needed to start Spirent Vertex
    # '''
    # debugWrite("startSpirentVertex: %s" % spirentId)
    # if spirentId is not None:
    # startVertex(self._config.tlConfig[spirentId]["spirentPC"]["hostname"])

    # def stopSpirentVertex(self, spirentId=None):
    # '''
    # This method performs all steps needed to stop Spirent Vertex
    # '''
    # debugWrite("stopSpirentVertex: %s" % spirentId)
    # if spirentId is None:
    # stopVertex()
    # else:
    # stopVertex(self._config.tlConfig[spirentId]["spirentPC"]["hostname"])

    # ---------------- LOGBOOK actions

    def _LogBookGetTLConfig(self, gNodebName=None):
        if "TL" in gNodebName:
            gNodebName = gNodebName.replace("TL", "CV")
        if "AP" in gNodebName:
            gNodebName = gNodebName.replace("AP", "CV")
        if gNodebName is not None:
            self._tlConfigFromLogbook = "Sorry, it was impossible to read the %s logbook"
            fileOut = self._LogBookGetFile(gNodebName)
            if fileOut is not None:
                self._LogBookReadFile(fileOut)

    def _LogBookGetFile(self, gNodebName=None):
        if gNodebName is not None:
            # connection parameter
            cnopts = pysftp.CnOpts()
            cnopts.hostkeys = None
            fileIn = "%s.txt" % gNodebName
            fileOut = "%s.txt" % gNodebName
            host = self._config.tlConfig["LOGBOOK"]["server"]["hostname"]
            username = self._config.tlConfig["LOGBOOK"]["server"]["username"]
            password = self._config.tlConfig["LOGBOOK"]["server"]["password"]
            # open connection
            try:
                sftpConn = pysftp.Connection(
                    host=host, username=username, password=password, cnopts=cnopts)
                sftpConn.get(fileIn, fileOut)
                # Close the connection
                sftpConn.close()
            except Exception:
                fileOut = None
                pass
            return fileOut

    def _LogBookReadFile(self, fileName=None):
        if fileName is not None:
            self._tlConfigFromLogbook = "\n\nTL Config:\n"
            fileIn = open(fileName, "r")
            line = fileIn.readline()
            while line:
                self._tlConfigFromLogbook += line
                line = fileIn.readline()
            # close and remove local file
            fileIn.close()
            os.remove(fileName)
            time.sleep(1)

    # ---------------- GENERIC actions

    def stop(self):
        '''
            This method stops all State Variable Builders, and State Vector Manager
            State Variable Builders and State Vector Manager are defined in
             https://sharenet-ims.int.net.nokia.com/Overview/D563965173
        '''
        self.stopStateVectorManager()
        self.stopOamStateVariableBuilder()
        self.stopEmilStateVariableBuilder()
        self.stopSherpaStateVariableBuilder()
        self.stopSysLogStateVariableBuilder()
        self.stopTtiTraceStateVariableBuilder()
        self.stopTsharkStateVariableBuilder()
