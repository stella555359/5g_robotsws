import os
import time
import enum
from datetime import datetime, timedelta
import re
from taf.analyzer.pmcounter import PMCounterLogReader
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import logging

# Guard Delay : Delay to ensure PM period will start : default is 40 seconds
GUARD_DELAY_DEF = 40
# Granulity Period : Period for PM aggregation : default is 5 mn (300 seconds)
GP_DEF = 300
# Additionnal delay to ensure PM files are fully available : 1 mn (60 seconds)
PM_AVAIL_DELAY_DEF = 60

# Path to KPI config files
KPI_REL_PATH = "config/KPI"

# Separator char for csv files
CSV_SEPARATOR = ";"

# Formats for date/time display
FORMAT_DATE = "%Y-%m-%d"
FORMAT_TIME = "%H:%M:%S"
FORMAT_LONG = FORMAT_DATE + " " + FORMAT_TIME


def getTimeStamp():
    """
    :return: a formatted string with time
    """
    return datetime.now().strftime("%H:%M:%S")


def console(str, isConsole=True, isLogFile=True):
    """
    Service to print a message to robotframework console thru a python call
    :param str: string to print in console
    :return: None
    """
    if isConsole:
        logger.console(str)
    if isLogFile:
        logging.info(str)


def getDatedString(str, deep=0, first=False):
    """
    compute a string to be printed.
    This string will be time stamped, and some tab will be introduced after date (deep)
    A CR is also added at the beginning if first if True
    :return: string to be printed
    """
    prefix = "\t"
    if first:
        prefix = "\n\t"
    return "{}[{}] {}{}".format(prefix, getTimeStamp(), "\t" * deep, str)


def datedConsole(str, deep=0, first=False, isConsole=True, isLogFile=True):
    """
    Print a string as "Dated log" KW from robot, meaning with a timestamp as prefix
    Deep may be specified to indicate the number of tabulation after timestamp
    :param str:
    :return:
    """
    console(str=getDatedString(str, deep, first), isConsole=isConsole, isLogFile=isLogFile)


def getStringFromCmdReturn(str):
    """
    remove all unexpected chars from a string corresponding to the return of a command (\n, \r, ...)
    :param str:
    :return:
    """
    return str.replace("\n", "").replace("\r", "")


# =================================================================================================
# Internal services
# =================================================================================================


def currentPath():
    return os.path.dirname(os.path.abspath(__file__))


def rootToSWENG():
    return currentPath()


def getCsvField(line, field):
    return line.split(CSV_SEPARATOR)[field]


def title(title, subTitle, content):
    if len(subTitle) > 0:
        subTitle = "({})".format(subTitle)
    Log.fullTrace("{:35} {:20}:{}".format(title, subTitle, content))


def extract_Cell_Id(tdd_fdd, idx):
    return get_robot_variable(f"${{{tdd_fdd}_Cell_list[{idx}-1].nrCellId}}")


# =================================================================================================
# Class State : to manage state of a constraint
#               By default, set to CSV_OK.
#               Then, set to
#               - CSV_ERROR if an error occurs while parsing csv line
#               - NOT_GENERIC_FORMAT if name ends with a non numeric (version letter)
#               - OUT_OF_SCOPE if scope is not matching baseband card
#               - NOT_CHECKED if OK and ready for evaluation
#               After evaluation, it is set to
#               - PASSED if inside threshold
#               - FAILED if outside Threshold
#               - KEY_ERROR if error during evaluation (counter not evaluated,...)
# =================================================================================================
class State(enum.Enum):
    NOT_CHECKED = 0
    FAILED = 1
    PASSED = 2
    KEY_ERROR = 3
    CSV_ERROR = 4
    CSV_OK = 5
    OUT_OF_SCOPE = 6
    NO_KPI = 7
    NOT_GENERIC_FORMAT = 8

    @staticmethod
    def finalStateRange():
        return range(State.NOT_CHECKED.value, State.KEY_ERROR.value + 1)

    def __str__(self):
        return self.name


# =================================================================================================
# Class CsvLine : to ease management of line in a CSV file
# =================================================================================================
class CsvLine:
    def __init__(self, path, line, index):
        self.path = path
        self.line = line
        self.index = index
        self.status = State.CSV_OK

    def getField(self, pos):
        result = "NA"
        try:
            result = self.line.split(CSV_SEPARATOR)[pos]
        except Exception as e:
            self.err(e)
        return result

    def err(self, str):
        Log.fullTrace(f"  ERROR:File {self.path}:{self.index + 1}: [{str}]")
        self.status = State.CSV_ERROR

    def isOK(self):
        return self.status != State.CSV_ERROR


# =================================================================================================
# Class Log : to trace info in console and/or in a specific file upon requirement
# =================================================================================================
class Log:
    Driver = None
    Path = ""

    def __init__(self, constraintsFile):
        name = os.path.basename(constraintsFile).replace(".csv", "")
        rootPath = BuiltIn().get_variable_value("${OUTPUT_DIR}")
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        Log.Path = "{}/{}_{}.kpi".format(rootPath, name, ts)
        Log.Driver = open(Log.Path, "+w")

    @staticmethod
    def close():
        Log.fullTrace("  All details are logged in:{}".format(Log.Path))
        Log.Driver.close()

    @staticmethod
    def trace(str, inConsole=False):
        if inConsole:
            datedConsole(str)
        Log.Driver.write(str + "\n")

    @staticmethod
    def fullTrace(str):
        Log.trace(str, inConsole=True)


# =================================================================================================
# Class : ZOI : Zone Of Interest
#         Set of tools to manage period during which PM are aggregated/comptuted
# =================================================================================================
class ZOI:

    def __init__(self, guardDelay, gp, pmAvailDelay):
        self.guardDelay = guardDelay
        self.gp = gp
        self.pmAvailDelay = pmAvailDelay

    @staticmethod
    def dtToStr(dt, isShort=True):
        return dt.strftime({True: FORMAT_TIME, False: FORMAT_LONG}.get(isShort))

    def remainingTime(self):
        return int((self.endTime - datetime.now()).total_seconds())

    def printStatus(self, title):
        datedConsole("{}: PM Available at {}: Remaining {} sec".format(
            title, ZOI.dtToStr(self.endTime, isShort=False), self.remainingTime()))

    def start(self):
        t0 = datetime.now()
        startTime = t0 + timedelta(seconds=self.guardDelay)
        pmStartTime = (int(startTime.timestamp() / self.gp) + 1) * self.gp
        self.endTime = datetime.fromtimestamp(pmStartTime + self.gp + self.pmAvailDelay)
        self.printStatus("Start ZOI")

    def waitEnd(self, printPeriod):
        while self.remainingTime() > 0:
            self.printStatus("  Wait end of ZOI")
            time.sleep(min(int(printPeriod), self.remainingTime()))


# =================================================================================================
# Class CounterDef : for management of Counter definition
# =================================================================================================
class CounterDef(CsvLine):
    def __init__(self, path, csvLine, index):
        super().__init__(path, csvLine, index)
        try:
            self.id, self.desc = csvLine.split(CSV_SEPARATOR)
        except Exception as e:
            self.err(e)

    def __str__(self):
        return "ID={:12} DESC={}".format(self.id, self.desc)


# =================================================================================================
# Class CounterDefFile : for management of Counter definition file
# =================================================================================================
class CounterDefFile:
    FILENAME = "Counter_Definitions.csv"

    def __init__(self, branchName):
        self.branchName = branchName
        self.path = "{}/{}/{}/{}".format(rootToSWENG(), KPI_REL_PATH, self.branchName, CounterDefFile.FILENAME)
        self.counterDefs = []
        title("Parsing:Counter Definition file", "Branch={}".format(self.branchName), self.path)
        with open(self.path, "r") as f:
            for idx, line in enumerate(f.readlines()):
                if not line.startswith("#"):
                    counterDef = CounterDef(self.path, getStringFromCmdReturn(line), idx)
                    if counterDef.isOK():
                        self.counterDefs.append(counterDef)

    def display(self):
        for idx, counter in enumerate(self.counterDefs):
            Log.trace("Counter[{}]: {}".format(idx + 1, counter))

    def getFromId(self, id):
        for counterDef in self.counterDefs:
            if counterDef.id == id:
                return counterDef
        return None


# =================================================================================================
# Class for KpiDef : for KPI definition
# =================================================================================================
class KpiDef(CsvLine):
    def __init__(self, path, csvLine, index):
        super().__init__(path, csvLine, index)
        try:
            self.id = getCsvField(csvLine, 0)
            self.name = getCsvField(csvLine, 1)
            self.formula = getCsvField(csvLine, 2)
        except Exception as e:
            self.err(e)

    def match(self, rootParam):
        return self.id == rootParam or self.id[0:-1] == rootParam

    def __str__(self):
        return "ID={} Name={}".format(self.id, self.name)


# =================================================================================================
# Class for KpiDefFile : for management of KPI definition file
# =================================================================================================
class KpiDefFile:
    FILENAME = "KPI_Definitions.csv"

    def __init__(self, branchName, localKpiFile=None):
        self.branchName = branchName
        if localKpiFile is not None:
            self.path = localKpiFile
        else:
            self.path = f"{rootToSWENG()}/{KPI_REL_PATH}/{self.branchName}/{KpiDefFile.FILENAME}"
        self.kpis = []
        title("Parsing:KPI Definition file", f"Branch={self.branchName}", self.path)
        with open(self.path, "r") as f:
            for idx, line in enumerate(f.readlines()):
                if not line.startswith("#"):
                    kpiDef = KpiDef(self.path, getStringFromCmdReturn(line), idx)
                    if kpiDef.isOK():
                        self.kpis.append(kpiDef)

    def getKpiFromRoot(self, rootName):
        for kpi in self.kpis:
            if kpi.match(rootName):
                return kpi
        return None

    def display(self):
        for idx, kpi in enumerate(self.kpis):
            Log.trace(f"KPI[{idx + 1}]: {kpi}")


# =================================================================================================
# Class Constraints : management of a constraint on a counter or a KPI
# =================================================================================================
class Constraint(CsvLine):
    def __init__(self, path, csvLine, index):
        super().__init__(path, csvLine, index)
        self.status = State.NOT_CHECKED
        self.oam_id = self.rootParam = self.curParam = self.min = self.max = self.variant = "NA"
        self.val = None
        self.type = None
        try:
            csvOamId = self.getField(0).strip()
            type_check = re.search(r'(TDD|FDD)', csvOamId)
            idx_check = re.search(r'_(\d+)', csvOamId)
            tdd_fdd = type_check.group(1) if type_check else None
            idx = idx_check.group(1) if idx_check else None
            cell_id = extract_Cell_Id(tdd_fdd, idx) if tdd_fdd and idx else None
            self.oam_id = f"NRCELL[@id='{cell_id}']" if cell_id is not None else csvOamId
            self.rootParam = self.getField(1).strip().upper()
            self.min = float(self.getField(2))
            self.max = float(self.getField(3))
            self.variant = self.getField(4).strip()
        except Exception as e:
            self.err(e)

    def isCandidate(self, bb):
        self.curParam = self.rootParam
        if self.status == State.CSV_ERROR:
            return False
        if self.variant == "ALL" or self.variant == bb:
            return True
        self.status = State.OUT_OF_SCOPE
        return False

    def isFound(self, counterDefFile, kpiDefFile):
        # Constraints ending with an alpha should be dropped : not generic format
        if not self.rootParam[-1].isnumeric():
            self.status = State.NOT_GENERIC_FORMAT
            return False
        # Attempting to find constraint name in list of counters
        if counterDefFile.getFromId(self.rootParam) is not None:
            self.type = "counter"
            return True
        # Otherwise, attempting to find root in list of KPI
        kpi = kpiDefFile.getKpiFromRoot(self.rootParam)
        if kpi is not None:
            self.curParam = kpi.id
            self.type = "kpi"
            return True
        # Root not found, no KPI matching, so will be dropped
        self.status = State.NO_KPI
        return False

    def diagStr(self):
        if self.status == State.NOT_CHECKED:
            return ""
        try:
            strVal = f"{self.val:10.4f}"
        except Exception as e:
            strVal = f"{str(self.val):10}"
        return f"VAL:{strVal}  STATUS={self.status}"

    def report(self, counter_report):
        if self.type != "counter":
            return
        if self.rootParam in counter_report:
            (reported_status, reported_value) = counter_report[self.rootParam]
            if reported_value == State.FAILED:
                return
        if self.status == State.FAILED:
            counter_report[self.rootParam] = (self.status, self.val)
        if (self.status != State.PASSED) or (self.val == 0):
            # counter with value 0 can not be reported as passed (this is default value !)
            return
        range = self.max - self.min
        median = (self.max + self.min) / 2
        if median == 0:
            return
        if (range / median) > 0.1:
            # range is too large to declare counter as passed
            return
        counter_report[self.rootParam] = (self.status, self.val)

    def check(self, oam_id):
        if self.oam_id == oam_id:
            try:
                self.val = float(globals()[self.curParam])
                if (self.val < self.min) or (self.val > self.max):
                    self.status = State.FAILED
                else:
                    self.status = State.PASSED
            except KeyError:
                self.status = State.KEY_ERROR

    def __str__(self):
        return f"OAM:{self.oam_id:15} ROOT:{self.rootParam:12} PARAM:{self.curParam:12} MIN:{self.min:8}  " + \
            f"MAX:{self.max:8}  VARIANT:{self.variant}  {self.diagStr()}"


# =================================================================================================
# Class ConstraintsFile : management of a CSV file of constraints
# =================================================================================================
class ConstraintFile:
    def __init__(self, path, counterDefFile, kpiDefFile):
        self.path = path
        self.constraints = []
        self.oam_ids = []
        self.drops = []
        bb = 'VDU'
        title("Parsing:Contraints file", "Topology BB={}".format(bb), self.path)
        with open(self.path, "r") as f:
            for idx, line in enumerate(f.readlines()):
                if not line.startswith("#"):
                    constraint = Constraint(self.path, getStringFromCmdReturn(line), idx)
                    if constraint.oam_id not in self.oam_ids:
                        self.oam_ids.append(constraint.oam_id)
                    if constraint.isCandidate(bb) and constraint.isFound(counterDefFile, kpiDefFile):
                        self.constraints.append(constraint)
                    else:
                        self.drops.append(constraint)

    def printObj(self, kind, index, value):
        Log.fullTrace("  {:10}[{:2}]={}".format(kind, index + 1, value))

    def displayAll(self):
        for idx, oam in enumerate(self.oam_ids):
            self.printObj("OAM_ID", idx, oam)
        Log.fullTrace("  {} constraints were selected".format(len(self.constraints)))
        if len(self.drops) > 0:
            Log.fullTrace("  ERROR: {} constraints were dropped".format(len(self.drops)))
            for idx, drop in enumerate(self.drops):
                self.printObj("Drop", idx, drop)

    def display(self):
        Log.fullTrace("Constraints evaluations:")
        for idx, constraint in enumerate(self.constraints):
            self.printObj("Constraint", idx, constraint)

    def checkConstraints(self, oam_id, counter_report):
        for constraint in self.constraints:
            constraint.check(oam_id)
            constraint.report(counter_report)

    def stats(self, failOnError):
        self.stats = [0] * len(State)
        for constraint in self.constraints:
            self.stats[constraint.status.value] += 1
        Log.fullTrace("Constraints Synthesis:")
        for i in State.finalStateRange():
            Log.fullTrace("  Number of {:12}:{}".format(str(State(i)), self.stats[i]))
        if failOnError:
            assert self.isOK(), "All constraints are NOT passed"

    def isOK(self):
        return self.stats[State.PASSED.value] == len(self.constraints)


# =================================================================================================
# class Var, Cnt, Kpi : to store counters and KPIs in dynamic variables
# =================================================================================================
class Var:
    VARS = []

    def __init__(self, entry, oam_id, id, val, desc):
        self.entry = entry
        self.oam_id = oam_id
        self.id = id
        self.val = val
        self.desc = desc
        self.check()
        self.add()
        Log.trace("    {}".format(self))

    def __str__(self):
        return "{}[{:3}] : {:15}={:10}    DESC={}" \
            .format(type(self).__name__, self.getCardinal(), self.id, self.val, self.desc)

    def check(self):
        pass

    def add(self):
        Var.VARS.append(self.id)
        self.updateCardinal()
        globals()[self.id] = float(self.val)

    @staticmethod
    def clean():
        for var in Var.VARS:
            del (globals()[var])
        Var.VARS.clear()
        Cnt.clearCardinal()
        Kpi.clearCardinal()

    @classmethod
    def updateCardinal(cls):
        cls.NB += 1

    @classmethod
    def getCardinal(cls):
        return cls.NB

    @classmethod
    def clearCardinal(cls):
        cls.NB = 0


class Cnt(Var):
    NB = 0

    def check(self):
        if len(self.val) != 1:
            raise ValueError("{}:Found {} values instead of 1".format(self, len(self.val)))
        self.val = self.val[0]


class Kpi(Var):
    NB = 0


# =================================================================================================
# class PMParser : to parse a PM file
# =================================================================================================
class PMParser:
    def __init__(self, pmFile, counterDefFile, kpiDefFile, constraintFile):
        self.pmFile = pmFile
        self.counterDefFile = counterDefFile
        self.kpiDefFile = kpiDefFile
        self.constraintFile = constraintFile
        self.counterReport = {}
        title("Parsing:PM file", "", self.pmFile)
        with open(pmFile, "rb") as f:
            for idx, entry in enumerate(PMCounterLogReader(file_obj_iterator=[f])):
                for oam_id in constraintFile.oam_ids:
                    Log.fullTrace("  PM_SETUP Entry[{}] Timestamp={}: Searching Cnt/Kpi matching OAM_ID={}"
                                  .format(idx + 1, entry.timestamp, oam_id))
                    self.setCounters(entry, oam_id)
                    if len(Var.VARS) == 0:
                        continue
                    self.setKpis(entry, oam_id)
                    Log.fullTrace("  Found {} counters and evaluate {} KPIs".format(Cnt.NB, Kpi.NB))
                    constraintFile.checkConstraints(oam_id, self.counterReport)
                    Var.clean()
        # self.reportToPortal()

    def reportToPortal(self):
        for counter in self.counterReport:
            (status, value) = self.counterReport[counter]
            BuiltIn().run_keyword("taf.sw.reporting_portal.report_pm_counter", counter, value, str(status))

    def setCounters(self, entry, oam_id):
        for path in entry.pm_setup.paths():
            end_of_oam_id_from_path = path.rfind("]")
            oam_id_from_path = path[:end_of_oam_id_from_path + 1]
            if oam_id_from_path.endswith(oam_id):
                counterId = path.split("@")[-1]
                counterVal = entry.pm_setup.xpath(path)
                counterDef = self.counterDefFile.getFromId(counterId)
                if counterDef is None:
                    # Log.fullTrace(f"{counterId} NOT FOUND: PLEASE REQUEST COUNTERS DATABASE UPDATE TO AF TEAM !")
                    continue
                Cnt(entry, oam_id, counterId, counterVal, counterDef.desc)

    def setKpis(self, entry, oam_id):
        for kpi in self.kpiDefFile.kpis:
            try:
                value = eval(kpi.formula)
                Kpi(entry, oam_id, kpi.id, value, kpi.name)
            except NameError:
                pass
            except ZeroDivisionError:
                pass


# =================================================================================================
# EXTERNAL SERVICES (method accessible directly via Robot
# =================================================================================================
def newZOI(guardDelay=GUARD_DELAY_DEF, gp=GP_DEF, pmAvailDelay=PM_AVAIL_DELAY_DEF):
    return ZOI(guardDelay=guardDelay, gp=gp, pmAvailDelay=pmAvailDelay)


def evaluateConstraints(pmFile, constraintsFile, failOnError=False, localKpiFile=None):
    # Init log file to store details
    Log(constraintsFile)
    # Reading Counter and KPI definitions,
    branchName = 'vDUCNF00'
    counterDefFile = CounterDefFile(branchName)

    if localKpiFile is None:
        kpiDefFile = KpiDefFile(branchName)
    else:
        kpiDefFile = KpiDefFile(branchName, localKpiFile)

    # Reading Constraints file
    constraintFile = ConstraintFile(constraintsFile, counterDefFile, kpiDefFile)
    constraintFile.displayAll()

    # Parsing PM files
    PMParser(pmFile=pmFile,
             counterDefFile=counterDefFile,
             kpiDefFile=kpiDefFile,
             constraintFile=constraintFile)

    # Display constraints failed
    constraintFile.display()
    constraintFile.stats(failOnError)
    Log.close()
    return constraintFile.isOK()
