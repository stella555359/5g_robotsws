from __future__ import print_function
import re
from datetime import datetime
import os
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
import xml.etree.ElementTree as ET
import logging

FLD = "field"
VAL = "value"
PREFIX_DISPLAY = "    "


# =================================================================================================
# Object managing list of errors
# =================================================================================================
class ObjWithErrors(object):
    def __init__(self):
        self.errors = []
        self.warns = []

    def displayErrors(self):
        # for idx, warn in enumerate(self.warns):
        #    prefixDatedConsole("WARN  {:02}/{:02}:{}".format(idx + 1, len(self.warns), warn))
        for idx, error in enumerate(self.errors):
            prefixDatedConsole("ERROR {:02}/{:02}:{}".format(idx + 1, len(self.errors), error))

    def aggregateErrors(self, list):
        for elt in list:
            self.errors.extend(elt.errors)
            self.warns.extend(elt.warns)

    def addErrorUponState(self, state, msg):
        fullMsg = state.fullDiag(msg)
        if state.isWarn():
            self.warns.append(fullMsg)
        if state.isKO():
            self.errors.append(fullMsg)


def getUserName():
    """
    Return user name from OS
    """
    return os.environ['USER']


def getDateTimeStamp():
    """
    :return: a formatted string with date and time
    """
    return datetime.now().strftime("%Y/%m/%d_%H:%M:%S")


def getTimeStamp():
    """
    :return: a formatted string with time
    """
    return datetime.now().strftime("%H:%M:%S")


def setFieldsInFile(srcFile, paramList, separator="="):
    """
    Set a list of parameters in <scrFile> local file
    Each parameter should be a dictionary containing a "field" and a "value" keys
    Change only lines starting with <field>.
    Lines starting with # or anything else are not modified
    If no line is matching, a new line is added to set this field
    A timestamped comment is added at the end of added/modified line
    :param srcFile: file to be modified
    :param paramList:list of "field","value" dictionary
    :param separator:separator between field and value
    :return:none
    """
    try:
        dstFile = "{}.new".format(srcFile)
        dst = open(dstFile, "w+")
        found = [False for idx in paramList]
        with open(srcFile, "r") as src:
            for line in src:
                for idx, p in enumerate(paramList):
                    match = re.match(r"^{}{}(\w*)".format(p[FLD], separator), line)
                    if match:
                        found[idx] = True
                        str = match.group(1)
                        if str != p[VAL]:
                            print("Previous value was :{}, modifying it with :{}".format(str, p[VAL]))
                            line = "{}={} # Modified by script ({})\n".format(p[FLD], p[VAL], getDateTimeStamp())
                        else:
                            print("Field {} already set to {}. Nothing to change".format(p[FLD], p[VAL]))
                dst.write(line)
        for idx, p in enumerate(paramList):
            if not found[idx]:
                print("Field {} not found. adding a line for it".format(p[FLD]))
                dst.write("{}={} # Added by script ({})\n".format(p[FLD], p[VAL], getDateTimeStamp()))
        dst.close()
        os.remove(srcFile)
        os.rename(dstFile, srcFile)
    except Exception as e:
        raise(Exception("ERROR while attempting to set fields in {}:{}".format(srcFile, e)))


def console(str):
    """
    Service to print a message to robotframework console thru a python call
    :param str: string to print in console
    :return: None
    """
    logger.console(str)
    logging.info(str)


def consoleError(str):
    """
    Print a ERROR message in robotframework console
    :param str: error message
    :return: none
    """
    console("ERROR:{}".format(str))


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


def datedConsole(str, deep=0, first=False):
    """
    Print a string as "Dated log" KW from robot, meaning with a timestamp as prefix
    Deep may be specified to indicate the number of tabulation after timestamp
    :param str:
    :return:
    """
    console(getDatedString(str, deep, first))


def datedConsoleInFile(file, str, deep=0, first=False):
    """
    print a message in a file
    """
    try:
        handle = open(file, "a")
        handle.write(getDatedString(str, deep, first)+"\n")
        handle.close()
    except Exception as e:
        consoleError("Unable to open trace file : {}".format(file))


def prefixDatedConsole(str):
    datedConsole(PREFIX_DISPLAY + str)


def toDecimalStr(str):
    """
    Convert a string into a decimal if possible
    In particular, an hexa string will be converted into a decimal
    Ex : '0x000c'    will be converted into '12'
         '0x0000001' will be converted into '1'
         '0x0000'    will be converted into '0'
    :param str: string to convert in decimal
    :return: string containing decimal value
    """
    if str.isdigit():
        return "{}".format(int(str, 10))
    if str.isalnum():
        return "{}".format((int(str, 16)))
    return "{}".format(str)


def toHexastr(str, len=8):
    """
    Convert a string representing an integer into an hexa string
    len is the number of expected digit (default is 8)
    :param str: string (with an integer inside) to convert
    :param len: expected number of digit in hexa string
    :return: hexa string
    Ex.: toHexaStr('10')  will return '0x0000000a'
         toHexaStr('100') will return '0x00000064'
    """
    formatStr = "0x{" + ":0{}x".format(len) + "}"
    return formatStr.format(int(str))


def compareInDecimal(v1, v2):
    """
    Compare to values converted in decimal
    compareInDecimal("0x0000C", "12") will return True
    :param v1: first value to compare
    :param v2: second value to compare
    :return: status of comparison
    """
    return toDecimalStr(v1) == toDecimalStr(v2)


def toNormalizedHexa(str, reverse=True, digit=2):
    """
    Return a string normalized in hexa
    In some cases, wireshark reverse bytes
    Also, in some other cases, bytes are doubled
    This service perform the reverse operation to provide a normalized hexa value
    So, this service :
    -	Extension to 4 digits
    -	Reverse 2 first digits and 2 last digits
    -	Reverse 1 and 2, then 3 and 4  (if reverse is True)
    -	Take (N) digits
    -	Prefix with 0x
    Examples :
        toNormalizedHexa(bc:01:bc:01, reverse=True, digit=2)=0x01bc
        toNormalizedHexa(05:00:00, reverse=False, digit=4)=0x00000005
        toNormalizedHexa(00:01:00:00, reverse=False, digit=4)=0x00000001
    :param str: reversed doubled hexa string
    :return: normalized hexa string
    """
    digit = int(digit)
    listBytes = str.split(":")
    lenListBytes = len(listBytes)
    # If no ":" return hexa if already in hexa (0x...) otherwise convert into hexa
    if lenListBytes == 1:
        if str.startswith("0x"):
            return str
        try:
            intVal = int(str)
        except Exception as e:
            BuiltIn().fail('Unable to normalize string [{}] in hexa'.format(str))
        return hex(intVal)
    # Extension to 4 bytes
    if lenListBytes < 4:
        listBytes.insert(0, '00')
    if lenListBytes < 3:
        listBytes.insert(0, '00')
    # Swap 1-2 with 3-4
    listBytes = [listBytes[2], listBytes[3], listBytes[0], listBytes[1]]
    # Reverse 1/2 and 3:4 on demand
    if reverse:
        listBytes = [listBytes[1], listBytes[0], listBytes[3], listBytes[2]]
    # Take N last digit
    res = ""
    for i in range(digit):
        res = "{}".format(listBytes[3-i]) + res
    return "0x" + res


def getTestName():
    """
    Retrieve current Robot Test name variable (fromRobotframework)
    :return: Full test name
    """
    return BuiltIn().get_variable_value("${TEST NAME}")


def getSuiteName():
    """
    Retrieve current Robot Test name variable (fromRobotframework)
    :return: Full test name
    """
    return BuiltIn().get_variable_value("${SUITE NAME}")


def getFormattedTestName():
    """
    rework test name by removing "[1]" and " " to avoid
    side effects when launching linux command including such name
    :return: formatted test name
    """
    return getTestName().replace("[1]", "").replace(" ", "_")


def getFormattedSuiteName():
    """
    rework Suite name by removing "[1]" and " " to avoid
    side effects when launching linux command including such name
    :return: formatted test name
    """
    return getSuiteName().replace("[1]", "").replace(" ", "_").replace(".robot", "")


def getFormattedName():
    try:
        name = getFormattedTestName()
    except Exception as e:
        name = getFormattedSuiteName()
    return name


def setVarWithTestName(varname=None, prefix=None):
    """
    Set a variable as a suite variable with a prefix and the (formatted) test name
    :param varname: name of the variable to set
    :param prefix: string to prefix name
    :return: None. variable is set to <prefix>.<test_name>
    """
    BuiltIn().set_suite_variable("${"+varname+"}", "{}.{}".format(prefix, getFormattedTestName()))


RAML_NAMESPACE = "raml21.xsd"


def getFirstElementMatching(rootElement, attrName, attrValue):
    fullChildName = "{" + RAML_NAMESPACE + "}" + "managedObject"
    for element in rootElement.iter(fullChildName):
        if (element.get(attrName) == attrValue):
            return element
    return None


def GetFieldValueFromSCF(file, className, fieldName):
    """
    Parse a raml file and retrieve the value of a field knowing its class name and
    :param file: raml file to parse
    :param className: class name of the field to retrieve
    :param fieldName: name of the field to retrieve
    :return: value of the field
    """
    tree = ET.parse(file)
    ET.register_namespace('', RAML_NAMESPACE)
    root = tree.getroot()
    mo = getFirstElementMatching(root, "class", className)
    fieldValue = mo.get(fieldName)
    return fieldValue


def getStringFromCmdReturn(str):
    """
    remove all unexpected chars from a string corresponding to the return of a command (\n, \r, ...)
    :param str:
    :return:
    """
    return str.replace("\n", "").replace("\r", "")


def getHeaderLine(name, value):
    return "{}{:43}={}".format(PREFIX_DISPLAY, name, value)


def printHeaderLine(name, value):
    datedConsole(getHeaderLine(name, value))


def printLineWithTitle(title=""):
    datedConsole("-"*4 + title + "-"*(78 - len(title) - 4))


def displayHeader(level, obj, title=""):
    # Print a string with <level> indentation (2 spaces), then the obj type, then some "..."
    # to have standars final size (17 chars)
    prefix = title
    if len(title) == 0:
        prefix = type(obj).__name__
    prefix = "{}{}".format("  " * level, prefix)
    prefixDatedConsole("{}:{}".format(prefix.ljust(17, "."), obj))


def getRobotVar(name):
    return BuiltIn().get_variable_value("${"+name+"}")


def reduceSpaces(str):
    """
    replace all sequence of several spaces with one unique space
    "I     am    A  Rock"  => "I am A Rock"
    """
    return ' '.join(str.split())


def getKeyValueFromLine(line, separator):
    """
    Split a line into a couple of (key, value) upon a separator
    It will search for the first separator
    It means:
    'containerID:   url:blablabla' => ('containerID', 'url:blablabla')
    """
    if line is None or len(line) == 0:
        return None, None
    pos = line.index(separator)
    if pos < 0:
        return line, None
    key = line[0:pos].strip()
    value = line[pos+1:].strip()
    if len(value) == 0:
        value = None
    return key, value
