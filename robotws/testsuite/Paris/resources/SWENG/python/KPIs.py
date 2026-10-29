import os
import time
import enum
import math
from datetime import datetime, timedelta
import re
import traceback
import StringTool
from ReadConfig import TLConfig
from taf.analyzer.pmcounter import PMCounterLogReader
from taf.sw.reporting_portal.interface import reporting_portal
from robot.libraries.BuiltIn import BuiltIn


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

LAST_CONSTRAINTFILE = None
COLUMN_ALIASES = {
    "oam_id": ["oam_id", "level"],
    "id_extension": ["id_extension", "pmqap_id", "pmqap", "nrpmqap", "nrpmqap_id"],
    "rootParam": ["Counter_or_KPI", "kpi_name", "counter_or_kpi"],
    "min": ["Min", "min"],
    "max": ["Max", "max"],
    "variant": ["Variant", "scope"],
    "comment": ["Comment from MIND/JUMP", "description", "comment"]
}
RP_PORTAL = reporting_portal()


# =================================================================================================
# Internal services
# =================================================================================================
def currentPath():
    return os.path.dirname(os.path.abspath(__file__))


def rootToSWENG():
    return f"{currentPath().split('SWENG')[0]}/SWENG"


def getCsvField(line, field):
    return line.split(CSV_SEPARATOR)[field]


def title(title, subTitle, content):
    if len(subTitle) > 0:
        subTitle = f"({subTitle})"
    Log.fullTrace(f"{title:35} {subTitle:20}:{content}")


def extract_Cell_Id(tdd_fdd, idx):
    try:
        return StringTool.getRobotVar(f"{tdd_fdd}_Cell_list[{idx}-1].nrCellId")
    except Exception as e:
        # Fallback for pytest/non-Robot context
        print(f"extract_Cell_Id fallback: {e}")
        return idx  # Use idx as cell_id for testing when Robot variable is not available


def extract_nrcell_id(oam_id_str):
    if not oam_id_str:
        return None
    # Original pattern NRCELL[@id='X']
    match = re.search(r"NRCELL\[@id='(\d+)'\]", oam_id_str)
    if match:
        return match.group(1)
    # Alternate patterns: NRCELL_TDD_X or NRCELL_FDD_X
    match = re.search(r"NRCELL_(?:TDD|FDD)_(\d+)", oam_id_str)
    if match:
        return match.group(1)
    return None


def extract_nrpmqap_id(obj_path):
    match = re.search(r"NRPMQAP(?:_|\-|@id=['\"]?|\[)?(\d+)", obj_path)
    if not match:
        match = re.search(r"NRPMQAP\[@id=['\"]?(\d+)['\"]?\]", obj_path)
    return match.group(1) if match else None


def make_counter_key(counterId, pmqap_id):
    # Only add PMQAP suffix if pmqap_id is not None and not "NA"
    if pmqap_id and str(pmqap_id).upper() != "NA":
        return f"{counterId}__NRPMQAP_{pmqap_id}"
    else:
        return counterId


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

    def getFieldbyColumnName(self, name, columns_names):
        result = "NA"
        try:
            pos = columns_names.index(name)
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
        rootPath = BuiltIn().get_variable_value("${LOG_PATH}")
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        Log.Path = f"{rootPath}/{name}_{ts}.kpi"
        Log.Driver = open(Log.Path, "+w")

    @staticmethod
    def close():
        Log.fullTrace(f"  All details are logged in:{Log.Path}")
        if Log.Driver is not None:
            Log.Driver.close()

    @staticmethod
    def trace(str, inConsole=False):
        if inConsole:
            StringTool.datedConsole(str)
        if Log.Driver is not None:
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
        StringTool.datedConsole(
            f"{title}: PM Available at {ZOI.dtToStr(self.endTime, isShort=False)}: "
            f"Remaining {self.remainingTime()} sec"
        )

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
        return f"ID={self.id:12} DESC={self.desc}"


# =================================================================================================
# Class CounterDefFile : for management of Counter definition file
# =================================================================================================
class CounterDefFile:
    FILENAME = "Counter_Definitions.csv"

    def __init__(self, branchName):
        self.branchName = branchName
        # self.path = f"{rootToSWENG()}/{KPI_REL_PATH}/{self.branchName}/{CounterDefFile.FILENAME}"
        self.path = f"{rootToSWENG()}/{KPI_REL_PATH}/SBTS00/{CounterDefFile.FILENAME}"
        self.counterDefs = []
        # title("Parsing:Counter Definition file", f"Branch={self.branchName}", self.path)
        with open(self.path, "r") as f:
            for idx, line in enumerate(f.readlines()):
                if not line.startswith("#"):
                    counterDef = CounterDef(self.path, StringTool.getStringFromCmdReturn(line), idx)
                    if counterDef.isOK():
                        self.counterDefs.append(counterDef)

    def display(self):
        for idx, counter in enumerate(self.counterDefs):
            Log.trace(f"Counter[{idx + 1}]: {counter}")

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
        return f"ID={self.id} Name={self.name}"


# =================================================================================================
# Class for KpiDefFile : for management of KPI definition file
# =================================================================================================
class KpiDefFile:
    FILENAME = "KPI_Definitions.csv"

    def __init__(self, branchName, localKpiFile=None):
        # self.branchName = branchName
        self.branchName = "SBTS00"
        if localKpiFile is not None:
            self.path = localKpiFile
        else:
            self.path = f"{rootToSWENG()}/{KPI_REL_PATH}/{self.branchName}/{KpiDefFile.FILENAME}"
        self.kpis = []
        title("Parsing:KPI Definition file", f"Branch={self.branchName}", self.path)
        with open(self.path, "r") as f:
            for idx, line in enumerate(f.readlines()):
                if not line.startswith("#"):
                    kpiDef = KpiDef(self.path, StringTool.getStringFromCmdReturn(line), idx)
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
    def __init__(self, path, csvLine, index, columns_names):
        super().__init__(path, csvLine, index)
        self.status = State.NOT_CHECKED
        self.oam_id = self.pmqap_id = self.rootParam = self.curParam = self.min = self.max = self.variant = "NA"
        self.id_extension = None
        self.val = None
        self.type = None
        self.ever_passed = False
        self.ever_failed = False
        self.ever_key_error = False
        self.should_not_calculate = False  # True if min=None and max=None
        self.columns_names = columns_names
        # print(f"DEBUG: Constraint columns_names: {self.columns_names}")
        try:
            fields = [f.strip() for f in csvLine.split(CSV_SEPARATOR)]

            def get_field_by_alias(logical_key, default=None):
                aliases = COLUMN_ALIASES.get(logical_key, [])
                if logical_key not in aliases:
                    aliases = [logical_key] + aliases  # ensure canonical present
                # print(f"DEBUG: get_field_by_alias({logical_key})")
                # print(f"  Aliases: {aliases}")
                # print(f"  columns_names: {self.columns_names}")
                for alias in aliases:
                    for i, col in enumerate(self.columns_names):
                        if col.strip().lower() == alias.lower():
                            # print(f"      MATCH: returning fields[{i}] = {fields[i]}")
                            return fields[i]
                # print(f"  No match found, returning default: {default}")
                return default

            # OAM ID extraction
            self.oam_id = get_field_by_alias("oam_id", fields[0])

            # id_extension extraction
            self.id_extension = get_field_by_alias("id_extension", "NA")
            self.pmqap_id = extract_nrpmqap_id(self.id_extension) if self.id_extension != "NA" else None

            # rootParam extraction
            self.rootParam = get_field_by_alias("rootParam", fields[1])

            # min extraction - check for explicit "None" first
            min_str = get_field_by_alias("min")
            if min_str and min_str.strip().upper() == "NONE":
                # Explicitly "None" in CSV
                self.min = None
            elif min_str and min_str.strip() != "":
                # Numeric value
                try:
                    self.min = float(min_str)
                except Exception:
                    self.status = State.NOT_CHECKED
                    return
            else:
                # Empty or missing -> reject constraint
                self.status = State.NOT_CHECKED
                return

            # max extraction - check for explicit "None" first
            max_str = get_field_by_alias("max")
            if max_str and max_str.strip().upper() == "NONE":
                # Explicitly "None" in CSV
                self.max = None
            elif max_str and max_str.strip() != "":
                # Numeric value
                try:
                    self.max = float(max_str)
                except Exception:
                    self.status = State.NOT_CHECKED
                    return
            else:
                # Empty or missing -> reject constraint
                self.status = State.NOT_CHECKED
                return

            # Check if this is a "should not be calculated" constraint
            # Both min and max must be explicitly set to "None" in the file
            if self.min is None and self.max is None:
                self.should_not_calculate = True
                Log.trace(
                    f"  Constraint {self.rootParam}: Should-Not-Calculate mode (min=None, max=None)"
                )
                print(
                    f"  Constraint {self.rootParam}: Should-Not-Calculate mode (min=None, max=None)"
                )

            # variant extraction, default to 'ALL'
            variant_str = get_field_by_alias("variant")
            self.variant = variant_str if variant_str and variant_str.strip() else "ALL"

            # comment extraction (optional)
            self.comment = get_field_by_alias("comment", "")

        except Exception as e:
            self.err(e)

    def _rootParam_init(self, columns_names):
        # Get and strip the field value
        result = self.getField(2 if self.columns_names[1].strip().lower() == "id_extension" else 1).strip()
        # Check if it ends with 4 digits
        if re.match(r".*\d{4}$", result):
            return result  # Ends with 4 digits, return as is
        # Check if it ends with 4 digits followed by a letter
        match = re.match(r"(.*\d{4})[a-zA-Z]$", result)
        if match:
            return match.group(1)  # Remove the trailing letter and return
        # If neither condition is met, return the original result
        return result

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

    def isFoundInReportDataframe(self, dfReport):
        # Clean the rootParam
        clean_root_param = str(self.rootParam).strip().lower()
        dfReport['code'] = dfReport['code'].str.strip().str.lower()
        # Remove trailing letters if the value ends with 4 digits followed by a letter
        dfReport['code'] = dfReport['code'].str.replace(r"(\d{4})[a-zA-Z]$", r"\1", regex=True)
        res = False
        # Filter the DataFrame
        filtered_df = dfReport[dfReport['code'] == clean_root_param]
        if not filtered_df.empty:
            row = filtered_df.iloc[0]  # Get the first matching row
            if row['type'] == "counter":
                self.type = "counter"
                res = True
            if row['type'] == "kpi":
                self.type = "kpi"
                self.curParam = row['code']
                res = True
        return res

    def diagStr(self):
        if self.status == State.NOT_CHECKED:
            return ""
        try:
            strVal = f"{self.val:10.4f}"
        except Exception as e:
            strVal = f"{str(self.val):10}"
        indicator = "  [SHOULD-NOT-CALC]" if self.should_not_calculate else ""
        return f"VAL:{strVal}  STATUS={self.status}{indicator}"

    def report(self, counter_report):
        # Only report for counters and KPIs
        if self.type not in ("counter", "kpi"):
            return
        # Use correct key for reporting
        key = make_counter_key(self.rootParam, self.pmqap_id)
        if key in counter_report:
            (reported_status, reported_value) = counter_report[key]
            if reported_value == State.FAILED:
                return
        if self.status == State.FAILED:
            counter_report[key] = (self.status, self.val)
        if (self.status != State.PASSED) or (self.val == 0):
            return
        # Skip range calculation for Should-Not-Calculate constraints (min=None, max=None)
        if self.min is None or self.max is None:
            return
        range = self.max - self.min
        median = (self.max + self.min) / 2
        if median == 0:
            return
        if (range / median) > 0.1:
            return
        counter_report[key] = (self.status, self.val)
        return self.status, self.val

    def check(self, oam_id):
        if self.oam_id == oam_id:
            key = make_counter_key(self.curParam, self.pmqap_id)
            found = False
            # Try main key first
            if key in globals():
                try:
                    self.val = float(globals()[key])
                    found = True
                except Exception as e:
                    # Log.fullTrace(f"  KEY_ERROR converting {key} value={globals().get(key)!r}: {e}")
                    self.ever_key_error = True
                    self.status = State.KEY_ERROR
                    return self.status
            # Fallback for KPIs or counters with NA PMQAP: try plain key
            if not found and (self.type == "kpi" or self.pmqap_id is None or str(self.pmqap_id).upper() == "NA"):
                if self.curParam in globals():
                    try:
                        self.val = float(globals()[self.curParam])
                        found = True
                    except Exception as e:
                        # Log.fullTrace(
                        #     f"  KEY_ERROR converting {self.curParam} value={globals().get(self.curParam)!r}: {e}")
                        self.ever_key_error = True
                        self.status = State.KEY_ERROR
                        return self.status
            if not found:
                # For Should-Not-Calculate constraints (min=None, max=None),
                # KEY_ERROR (value not found) means PASSED (correctly not calculated)
                if self.min is None and self.max is None:
                    self.ever_passed = True
                    self.status = State.PASSED
                    Log.trace(
                        f"  {self.rootParam}: Should-Not-Calculate constraint PASSED "
                        f"(value not calculated - correct behavior)"
                    )
                    print(
                        f"  {self.rootParam}: Should-Not-Calculate constraint PASSED "
                        f"(value not calculated - correct behavior)"
                    )
                    return self.status
                else:
                    self.ever_key_error = True
                    self.status = State.KEY_ERROR
                    return self.status
            # case min and max are both None
            if self.min is None and self.max is None:
                # PASSED if value not calculated, FAILED if value is numeric
                if self.val is None or (isinstance(self.val, float) and math.isnan(self.val)):
                    self.ever_passed = True
                    self.status = State.PASSED
                    Log.trace(
                        f"  {self.rootParam}: Should-Not-Calculate constraint PASSED "
                        f"(value not calculated - correct behavior)"
                    )
                    print(
                        f"  {self.rootParam}: Should-Not-Calculate constraint PASSED "
                        f"(value not calculated - correct behavior)"
                    )
                else:
                    self.ever_failed = True
                    self.status = State.FAILED
                    Log.trace(
                        f"  {self.rootParam}: Should-Not-Calculate constraint FAILED "
                        f"(value={self.val} was calculated - should NOT have been calculated)"
                    )
                    print(
                        f"  {self.rootParam}: Should-Not-Calculate constraint FAILED "
                        f"(value={self.val} was calculated - should NOT have been calculated)"
                    )
            # standard case: check thresholds
            elif (self.val < self.min) or (self.val > self.max):
                self.ever_failed = True
                self.status = State.FAILED
            else:
                self.ever_passed = True
                self.status = State.PASSED
        return self.status

    def finalize_status(self):
        # Only consolidate when multiple PM entries were parsed (set externally)
        # Priority: FAILED > PASSED > KEY_ERROR > NOT_CHECKED
        if self.ever_failed:
            self.status = State.FAILED
        elif self.ever_passed:
            self.status = State.PASSED
        elif self.ever_key_error:
            self.status = State.KEY_ERROR
        else:
            self.status = State.NOT_CHECKED

    def check_fromdf(self, dfReport):
        try:
            print(f"Checking {self.curParam} in DataFrame")
            self.val = self.get_value_fromdf(dfReport)
            print(f"          Value found in DF: {self.val}")
        except Exception as e:
            # For Should-Not-Calculate constraints (min=None, max=None),
            # KEY_ERROR (value not found) means PASSED (correctly not calculated)
            if self.min is None and self.max is None:
                self.status = State.PASSED
                print(
                    f"  {self.rootParam}: Should-Not-Calculate constraint PASSED "
                    f"(value not found - correct behavior)"
                )
                return self.status, None
            else:
                self.status = State.KEY_ERROR
                print(f"KEY_ERROR: {self.curParam} not found in DataFrame: {e}")
                return self.status, None
        # case min and max are both None
        # PASSED if value not calculated, FAILED if value is numeric
        if self.min is None and self.max is None:
            # check for NaN
            if self.val is None or (isinstance(self.val, float) and math.isnan(self.val)):
                self.status = State.PASSED
                print(
                    f"  {self.rootParam}: Should-Not-Calculate constraint PASSED "
                    f"(value not calculated - correct behavior)"
                )
            else:
                self.status = State.FAILED
                print(
                    f"  {self.rootParam}: Should-Not-Calculate constraint FAILED "
                    f"(value={self.val} was calculated - should NOT have been calculated)"
                )
        # standard case: check thresholds
        elif (self.val < self.min) or (self.val > self.max):
            self.status = State.FAILED
        else:
            self.status = State.PASSED
        return self.status, self.val

    def get_value_fromdf(self, dfReport):
        """
        get value from a DataFrame based on rootParam value.
        :param dfReport: The pandas DataFrame containing the report data.
        returns the value as a float.
        """
        try:
            clean_root_param = str(self.rootParam).strip().lower()
            # Filter the DataFrame
            filtered_df = dfReport[dfReport['code'].str.strip().str.lower() == clean_root_param]
            # Ensure the filtered DataFrame is not empty
            if filtered_df.empty:
                raise ValueError(f"No matching rows found for rootParam: {self.rootParam}")
            # Extract the 'value' column from the filtered DataFrame
            value = filtered_df['global_result.value'].values[0]
            if str(value) == 'nan':
                value = filtered_df['result.value'].values[0]
            # Convert the value to float and print it
            return float(value)
        except KeyError as e:
            print(f"KeyError: Missing column in DataFrame - {e}")
            raise
        except IndexError:
            print(f"IndexError: No value found for rootParam: {self.rootParam}")
            raise
        except ValueError as e:
            raise

    def __str__(self):
        oam_id = str(self.oam_id) if self.oam_id is not None else ""
        id_extension = str(self.id_extension) if self.id_extension is not None else ""
        rootParam = str(self.rootParam) if self.rootParam is not None else ""
        curParam = str(self.curParam) if self.curParam is not None else ""
        # Format min/max: show "None" explicitly for None values to make them visible
        if isinstance(self.min, (int, float)):
            min_val = f"{self.min:8}"
        elif self.min is None:
            min_val = f"{'None':>8}"
        else:
            min_val = str(self.min)
        if isinstance(self.max, (int, float)):
            max_val = f"{self.max:8}"
        elif self.max is None:
            max_val = f"{'None':>8}"
        else:
            max_val = str(self.max)
        variant = str(self.variant) if self.variant is not None else ""
        indicator = " [SHOULD-NOT-CALC]" if self.should_not_calculate else ""
        return (
            f"OAM:{oam_id:15} EXT: {id_extension:12} ROOT:{rootParam:12} PARAM:{curParam:12}"
            f" MIN:{min_val}  MAX:{max_val}  VARIANT:{variant}{indicator}  {self.diagStr()}"
        )


# =================================================================================================
# Class ConstraintsFile : management of a CSV file of constraints
# =================================================================================================
class ConstraintFile:
    def __init__(self, path, counterDefFile=None, kpiDefFile=None, reportDf=None):
        self.path = path
        self.constraints = []
        self.oam_ids = []
        self.ext_ids = []
        self.drops = []
        self.unsupported_counters = []
        self.columns_names = []
        bb = TLConfig.topo.getBB()
        print(f"Parsing:Constraints file {self.path} - Topology BB={bb}")
        try:
            with open(self.path, "r") as f:
                raw_lines = [ln.rstrip("\n") for ln in f]
        except FileNotFoundError:
            print("WARNING: Constraints file missing.")
            return
        # Strip empty lines
        lines = [cur_line for cur_line in raw_lines if cur_line.strip()]
        if not lines:
            print("WARNING: Empty constraints file.")
            return
        # Find header: first comment line containing oam_id and Counter_or_KPI (case-insensitive)
        header_idx = None
        for i, l in enumerate(lines):
            ls = l.strip()
            if ls.startswith("#"):
                core = ls.lstrip("#").strip()
                lower = core.lower()
                if "oam_id" in lower and ("counter_or_kpi" in lower or "counter_or_kpi".replace("_", " ") in lower):
                    header_idx = i
                    header_line = core
                    break
        if header_idx is None:
            # Fallback: first non-comment line treated as data, inject default header
            first = lines[0].lstrip("#").strip()
            cols_guess = [c.strip() for c in first.split(CSV_SEPARATOR)]
            print("INFO: Header not found, injecting default column list.")
            self.columns_names = ["oam_id", "rootParam", "min", "max", "variant", "comment"][:len(cols_guess)]
            data_start = 0
        else:
            raw_header_cols = [c.strip() for c in header_line.split(CSV_SEPARATOR)]
            self.columns_names = self._map_columns(raw_header_cols)
            # print(f"DEBUG: mapped columns_names = {self.columns_names}")
            data_start = header_idx + 1  # skip header line
        # Iterate data
        for idx in range(data_start, len(lines)):
            line = lines[idx].strip()
            if not line or line.startswith("#"):
                # Skip pure comment section headers like "# NRCELL-1"
                continue
            fields = [c.strip() for c in line.split(CSV_SEPARATOR)]
            # Basic sanity: need at least min/max
            if len(fields) < 4:
                continue
            constraint = Constraint(self.path, line, idx, self.columns_names)
            # Debug raw extraction
            # print(f"DEBUG: Constraint raw: oam_id={constraint.oam_id}, rootParam={constraint.rootParam}")
            # print(f"DEBUG:                 min={constraint.min}, max={constraint.max}, variant={constraint.variant}")
            if not constraint.isCandidate(bb):
                continue
            if reportDf is not None and counterDefFile is None and kpiDefFile is None:
                if not constraint.isFoundInReportDataframe(reportDf):
                    self.drops.append(constraint)
                    continue
                self.constraints.append(constraint)
            else:
                if counterDefFile and kpiDefFile and constraint.isFound(counterDefFile, kpiDefFile):
                    self.constraints.append(constraint)
                else:
                    self.drops.append(constraint)
            if constraint.oam_id and constraint.oam_id not in self.oam_ids:
                self.oam_ids.append(constraint.oam_id)
            if constraint.id_extension and constraint.id_extension not in self.ext_ids:
                self.ext_ids.append(constraint.id_extension)
        print(f"  Found {len(self.constraints)} valid constraints")
        print(f"  Dropped {len(self.drops)} constraints")

    def _map_columns(self, header):
        mapping = []
        for col in header:
            col_clean = col.strip().replace("#", "").lower()
            for key, aliases in COLUMN_ALIASES.items():
                if col_clean in [a.lower() for a in aliases]:
                    mapping.append(key)
                    break
            else:
                mapping.append(col_clean)  # fallback: use the raw column name
        return mapping

    def printObj(self, kind, index, value):
        Log.fullTrace(f"  {kind:10}[{index + 1:2}]={value}")
        print(f"  {kind:10}[{index + 1:2}]={value}")

    def displayAll(self, deactivate_constr_print=False):
        for idx, oam in enumerate(self.oam_ids):
            self.printObj("OAM_ID", idx, oam)
        for idx, ext in enumerate(self.ext_ids):
            self.printObj("EXT_ID", idx, ext)
        Log.fullTrace(f"  {len(self.constraints)} constraints were selected")
        if len(self.drops) > 0:
            Log.fullTrace(f"  ERROR: {len(self.drops)} constraints were dropped")
            for idx, drop in enumerate(self.drops):
                self.printObj("Drop", idx, drop)
        if len(self.constraints) > 0:
            Log.fullTrace(f"  {len(self.constraints)} constraints were selected")
            if not deactivate_constr_print:
                Log.fullTrace("  Selected constraints details:")
                for idx, constraint in enumerate(self.constraints):
                    Log.fullTrace(f"Valid Constraint[{idx + 1}]: {constraint}")
                    self.printObj("Valid", idx, constraint)
        if len(self.unsupported_counters) > 0:
            Log.fullTrace(f"  WARNING: {len(self.unsupported_counters)} unsupported counters were found")
            for idx, counter in enumerate(self.unsupported_counters):
                self.printObj("Unsupported", idx, counter)

    def display(self, filterStatus=None):
        Log.fullTrace("Constraints evaluations:")
        for idx, constraint in enumerate(self.constraints):
            if filterStatus is None or constraint.status == filterStatus:
                if filterStatus is None:
                    Log.fullTrace(f"  Constraint[{idx + 1}]: {constraint}")
                else:
                    Log.fullTrace(f"  {filterStatus}[{idx + 1}]: {constraint}")
        if len(self.unsupported_counters) > 0:
            Log.fullTrace(f"  WARNING: {len(self.unsupported_counters)} unsupported counters were found")
            for idx, counter in enumerate(self.unsupported_counters):
                self.printObj("Unsupported", idx, counter)

    def get_constraint(self, index):
        """
        Returns the constraint at the specified index.
        :param index: Index of the constraint to retrieve.
        :return: Constraint object at the specified index.
        """
        if 0 <= index < len(self.constraints):
            return self.constraints[index]
        else:
            raise IndexError("Index out of range for constraints list.")

    def checkConstraints(self, oam_id, counter_report):
        for constraint in self.constraints:
            constraint.check(oam_id)
            constraint.report(counter_report)

    def checkConstraintsIndf(self, counter_report, dfReport):
        for constraint in self.constraints:
            constraint.check_fromdf(dfReport)
            constraint.report(counter_report)

    def stats(self, failOnError):
        """
        Checks the status of all constraints and counts the number of each status.
        The assertion is raised if the number of PASSED constraints is not equal to the total number of constraints.
        :param failOnError: If True, raises an assertion error if any constraints failed.
        :return: A list of counts for each status.
        """
        self.stats = [0] * len(State)
        # Detailed breakdowns for PASSED and FAILED
        passed_numeric = 0  # Numeric values within range
        passed_should_not_calc = 0  # None value with min=None, max=None
        failed_numeric = 0  # Numeric values out of range
        failed_should_not_calc = 0  # Numeric value with min=None, max=None (should not have been calculated)
        failed_key_error = 0  # None value with numeric min/max (value missing but expected)

        for constraint in self.constraints:
            self.stats[constraint.status.value] += 1

            if constraint.status == State.PASSED:
                if constraint.should_not_calculate:
                    passed_should_not_calc += 1
                else:
                    passed_numeric += 1
            elif constraint.status == State.FAILED:
                if constraint.should_not_calculate:
                    failed_should_not_calc += 1
                else:
                    failed_numeric += 1
            elif constraint.status == State.KEY_ERROR:
                failed_key_error += 1

        Log.fullTrace("Constraints Synthesis:")
        print("Constraints Synthesis:")
        for i in State.finalStateRange():
            # Skip KEY_ERROR as it's included in FAILED breakdown
            if i == State.KEY_ERROR.value:
                continue
            msg = f"  Number of {str(State(i)):12}:{self.stats[i]}"
            if i == State.PASSED.value:
                msg += f" (numeric checked: {passed_numeric}, should-not-calc: {passed_should_not_calc})"
            elif i == State.FAILED.value:
                msg += (f" (numeric out-of-range: {failed_numeric}, "
                        f"should-not-calc calculated: {failed_should_not_calc}, "
                        f"missing values: {failed_key_error})")
            Log.fullTrace(msg)
            print(msg)

        passed_names = [c.rootParam for c in self.constraints if c.status == State.PASSED]
        key_error_names = [c.rootParam for c in self.constraints if c.status == State.KEY_ERROR]
        failed_names = [c.rootParam for c in self.constraints if c.status == State.FAILED]
        Log.fullTrace(f"Names of PASSED parameters:\n{passed_names}")
        Log.fullTrace(f"Names of KEY_ERROR parameters:\n{key_error_names}")
        Log.fullTrace(f"Names of FAILED parameters:\n{failed_names}")
        if failOnError:
            assert self.isOK(), f"Some constraints failed: {self.stats}"
        return self.stats

    def isOK(self):
        return self.stats[State.PASSED.value] == len(self.constraints)


# =================================================================================================
# class Var, Cnt, Kpi : to store counters and KPIs in dynamic variables
# =================================================================================================
class Var:
    VARS = []
    KEYS = []

    def __init__(self, entry, oam_id, id, val, desc, pmqap_id=None):
        self.entry = entry
        self.oam_id = oam_id
        self.pmqap_id = pmqap_id
        self.id = id
        self.val = val
        self.desc = desc
        self.check()
        self.add()
        Log.trace(f"    {self}")

    def __str__(self):
        pmqap_str = f" PMQAP_ID={self.pmqap_id}" if self.pmqap_id else ""
        return (
            f"{type(self).__name__}[{self.getCardinal():3}] : {self.id:15}={self.val:10}    "
            f"DESC={self.desc}{pmqap_str}"
        )

    def check(self):
        pass

    def add(self):
        Var.VARS.append(self.id)
        self.updateCardinal()
        key = make_counter_key(self.id, self.pmqap_id)
        globals()[key] = float(self.val)
        self.key = key
        if key not in Var.KEYS:
            Var.KEYS.append(key)
            # print(f"Stored key: {self.key} for counterId={self.id} PMQAP={self.pmqap_id} value={self.val}")

    @staticmethod
    def clean():
        for var in Var.VARS:
            if var in globals():
                del globals()[var]
        for key in Var.KEYS:
            if key in globals():
                del globals()[key]
        Var.VARS.clear()
        Var.KEYS.clear()
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
        if isinstance(self.val, (list, tuple)) and len(self.val) != 1:
            raise ValueError(f"{self}:Found {len(self.val)} values instead of 1")
        if isinstance(self.val, (list, tuple)):
            self.val = self.val[0]


class Kpi(Var):
    NB = 0


# =================================================================================================
# class PMParser : to parse a PM file
# =================================================================================================
class PMParser:
    def __init__(self, pmFile, counterDefFile, kpiDefFile, constraintFile, usePMQAP=False):
        self.pmFile = pmFile
        self.counterDefFile = counterDefFile
        self.kpiDefFile = kpiDefFile
        self.constraintFile = constraintFile
        self.counterReport = {}
        self.unsupported_counters_list = []
        self.usePMQAP = usePMQAP
        self.entry_count = 0
        print(f"Parsing:PM file {self.pmFile}")
        with open(pmFile, "rb") as f:
            for idx, entry in enumerate(PMCounterLogReader(file_obj_iterator=[f])):
                self.entry_count += 1
                if not self.usePMQAP:
                    self._constraints_checker_oamid(constraintFile, entry, idx)
                else:
                    self._constraints_checker_pmqap(constraintFile, entry, idx)
        ctr_nr = len(self.unsupported_counters_list)
        if ctr_nr > 0:
            constraintFile.unsupported_counters = self.unsupported_counters_list
            print(f"WARNING! There are {ctr_nr} unsupported counters.")
            print("Please ask counter definitions update to AF team")
        print("Reporting Counters/KPIs to TAF portal")
        self.reportToPortal()

    def _constraints_checker_oamid(self, constraintFile, entry, idx):
        for oam_id in constraintFile.oam_ids:
            # print(f"DEBUG:     PM_SETUP Entry[{idx + 1}] Timestamp={entry.timestamp}:")
            # print(f"DEBUG:     Searching Cnt/Kpi matching OAM_ID={oam_id}")
            temp_list = self.setCounters(entry, oam_id)
            if len(temp_list) > 0:
                self.unsupported_counters_list.extend(temp_list)
            if len(Var.VARS) == 0:
                continue
            self.setKpis(entry, oam_id)
            print(f"  Found {Cnt.NB} counters and evaluate {Kpi.NB} KPIs")
            constraintFile.checkConstraints(oam_id, self.counterReport)
            Var.clean()

    def _constraints_checker_pmqap(self, constraintFile, entry, idx):
        # Build groups
        groups = {}
        for c in constraintFile.constraints:
            key = (c.oam_id, c.pmqap_id)  # pmqap_id already None when NA
            groups.setdefault(key, []).append(c)

        for (oam_id, pmqap_id), group in groups.items():
            # print(f"DEBUG:  PM_SETUP Entry[{idx + 1}] Timestamp={entry.timestamp}:")
            # print(f"DEBUG:  Searching Cnt/Kpi matching OAM_ID={oam_id} and PMQAP_ID={pmqap_id}")
            # Use id_extension from first constraint (all share same pmqap_id value / None)
            id_extension = group[0].id_extension
            temp_list = self.setCounters(entry, oam_id, id_extension)
            if temp_list:
                self.unsupported_counters_list.extend(temp_list)
            if not Var.VARS and not Var.KEYS:
                # No counters for this group -> all KEY_ERROR
                for constr in group:
                    constr.ever_key_error = True
                    constr.status = State.KEY_ERROR
                Var.clean()
                continue
            self.setKpis(entry, oam_id)
            print(f"  Found {Cnt.NB} counters and evaluate {Kpi.NB} KPIs")
            # Check each constraint in the group
            for constr in group:
                constr.check(constr.oam_id)
                constr.report(self.counterReport)
            Var.clean()

    def reportToPortal(self):
        for counter in self.counterReport:
            (status, value) = self.counterReport[counter]
            RP_PORTAL.report_pm_counter(counter, value, str(status))

    def setCounters(self, entry, oam_id, id_extension=None):
        unsupported_counters_list = []
        nrcell_id_constraint = extract_nrcell_id(oam_id)
        pmqap_id_constraint = extract_nrpmqap_id(id_extension) if id_extension else None
        # Build required counter id set:
        required_ids = set()
        for c in self.constraintFile.constraints:
            # Always include rootParam
            required_ids.add(c.rootParam)
            # For KPI constraints include its evaluated param id (curParam) in case formula uses that directly
            if getattr(c, "type", None) == "kpi":
                required_ids.add(c.curParam)
        # Add counters referenced inside KPI formulas (simple token regex)
        kpi_tokens = set()
        token_re = re.compile(r"\b[A-Z][A-Z0-9_]*\d[A-Z0-9_]*\b")
        for kpi in self.kpiDefFile.kpis:
            for tok in token_re.findall(kpi.formula):
                kpi_tokens.add(tok)
        required_ids.update(kpi_tokens)
        # printed = set()  # keep track to avoid duplicate debug lines
        for path in entry.pm_setup.paths():
            end_of_oam_id_from_path = path.rfind("]")
            oam_id_from_path = path[:end_of_oam_id_from_path + 1] if end_of_oam_id_from_path != -1 else path
            nrcell_id_path = extract_nrcell_id(oam_id_from_path)
            pmqap_id_path = extract_nrpmqap_id(path)
            counterId = path.split("@")[-1]
            counterVal = entry.pm_setup.xpath(path)
            # OAM match logic:
            if nrcell_id_constraint is not None:
                if nrcell_id_path != nrcell_id_constraint:
                    continue
            else:
                # Generic match for any OAM like SERVEDAMF[@id='1'], NRBTS[@id='1'], etc.
                if re.search(r"\[@id='\d+'\]", oam_id) and oam_id not in oam_id_from_path:
                    continue
            if id_extension and id_extension.strip().upper() != "NA":
                if pmqap_id_path != pmqap_id_constraint:
                    continue
            else:
                if pmqap_id_path is not None:
                    continue
            if counterId in required_ids:
                # Debug only once per matching counterId (with PMQAP context)
                # if counterId not in printed:
                #     print(f"DEBUG MATCH counterId={counterId} OAM={oam_id} PMQAP={pmqap_id_path}")
                #     printed.add(counterId)
                counterDef = self.counterDefFile.getFromId(counterId)
                if counterDef is None:
                    if counterId not in unsupported_counters_list:
                        unsupported_counters_list.append(counterId)
                else:
                    key = make_counter_key(counterId, pmqap_id_path)
                    if isinstance(counterVal, list):
                        value = float(counterVal[0]) if counterVal else 0.0
                    else:
                        value = float(counterVal)
                    globals()[key] = value
                    # Store using Cnt for cardinality tracking (optional, but keep for consistency)
                    # print(f"DEBUG STORE key={key} value={value}")
                    if pmqap_id_path is not None:
                        Cnt(entry, oam_id, counterId, counterVal, counterDef.desc, pmqap_id=pmqap_id_path)
                    else:
                        Cnt(entry, oam_id, counterId, counterVal, counterDef.desc)
        return unsupported_counters_list

    def setKpis(self, entry, oam_id):
        for kpi in self.kpiDefFile.kpis:
            try:
                # eval uses current globals so counters/KPIs are available
                value = eval(kpi.formula)
                # ensure numeric result
                try:
                    value = float(value)
                except Exception:
                    # leave as-is and let Constraint.check mark KEY_ERROR
                    # Log.fullTrace(f"  KPI {kpi.id} evaluated to non-numeric {value!r}")
                    pass
                Kpi(entry, oam_id, kpi.id, value, kpi.name)
            except NameError:
                # missing variable => KPI cannot be evaluated; signal and continue
                # Log.fullTrace(f"  KPI {kpi.id} NameError evaluating formula: {kpi.formula}")
                # create placeholder to avoid re-evaluating later; actual check will mark KEY_ERROR
                globals()[kpi.id] = None
            except ZeroDivisionError:
                # Log.fullTrace(f"  KPI {kpi.id} ZeroDivisionError evaluating formula: {kpi.formula}")
                globals()[kpi.id] = None
            except Exception as e:
                # Catch all other exceptions (TypeError, ValueError, etc.), log stacktrace and continue
                # Log.fullTrace(f"  KPI {kpi.id} ERROR evaluating formula: {kpi.formula} -> {e}")
                # Log.fullTrace(traceback.format_exc())
                globals()[kpi.id] = None


# For pytest only
def get_last_constraints():
    return LAST_CONSTRAINTFILE


# =================================================================================================
# EXTERNAL SERVICES (method accessible directly via Robot
# =================================================================================================
def newZOI(guardDelay=GUARD_DELAY_DEF, gp=GP_DEF, pmAvailDelay=PM_AVAIL_DELAY_DEF):
    return ZOI(guardDelay=guardDelay, gp=gp, pmAvailDelay=pmAvailDelay)


def evaluateConstraints(pmFile, constraintsFilePath, failOnError=False, localKpiFile=None, usePMQAP=False,
                        deactivate_constr_print=False):
    # Init log file to store details
    Log(constraintsFilePath)
    # Reading Counter and KPI definitions,
    branchName = TLConfig.topo.getBranchName()
    counterDefFile = CounterDefFile(branchName)
    Log.fullTrace(
        f"Evaluating constraints for branch {branchName}\n\tPM file {pmFile}\n\tconstraints file {constraintsFilePath}")
    if localKpiFile is None:
        kpiDefFile = KpiDefFile(branchName)
    else:
        kpiDefFile = KpiDefFile(branchName, localKpiFile)
    # Reading Constraints file
    constraintFile = ConstraintFile(constraintsFilePath, counterDefFile, kpiDefFile)
    constraintFile.displayAll(deactivate_constr_print)
    # Parsing PM files
    parser = PMParser(pmFile=pmFile,
                      counterDefFile=counterDefFile,
                      kpiDefFile=kpiDefFile,
                      constraintFile=constraintFile,
                      usePMQAP=usePMQAP)
    # Call finalize_status only if multiple PM entries aggregated
    if parser.entry_count > 1:
        for constraint in constraintFile.constraints:
            constraint.finalize_status()
    constraintFile.display()
    constraintFile.stats(failOnError)
    Log.close()
    # for pytest only
    global LAST_CONSTRAINTFILE
    LAST_CONSTRAINTFILE = constraintFile
    return constraintFile.isOK()
