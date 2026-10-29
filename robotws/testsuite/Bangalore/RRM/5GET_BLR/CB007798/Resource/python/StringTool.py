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
        raise (Exception("ERROR while attempting to set fields in {}:{}".format(srcFile, e)))


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


def datedConsole(str, deep=0):
    """
    Print a string as "Dated log" KW from robot, meaning with a timestamp as prefix
    Deep may be specified to indicate the number of tabulation after timestamp
    :param str:
    :return:
    """
    console("\t[{}] {}{}".format(getTimeStamp(), "\t" * deep, str))


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
        toNormalizedHexa(bc:01:bc:01,reverse=True ,digit=2)=0x01bc
        toNormalizedHexa(05:00:00   ,reverse=False,digit=4)=0x00000005
        toNormalizedHexa(00:01:00:00,reverse=False,digit=4)=0x00000001
    :param str: reversed doubled hexa string
    :return: normalized hexa string
    """
    digit = int(digit)
    listBytes = str.split(":")
    length = len(listBytes)
    # If no ":" return hexa if already in hexa (0x...) otherwise convert into hexa
    if length == 1:
        if str.startswith("0x"):
            return str
        try:
            intVal = int(str)
        except Exception:
            BuiltIn().fail('Unable to normalize string [{}] in hexa'.format(str))
        return hex(intVal)
    # Extension to 4 bytes
    if length < 4:
        listBytes.insert(0, '00')
    if length < 3:
        listBytes.insert(0, '00')
    # Swap 1-2 with 3-4
    listBytes = [listBytes[2], listBytes[3], listBytes[0], listBytes[1]]
    # Reverse 1/2 and 3:4 on demand
    if reverse:
        listBytes = [listBytes[1], listBytes[0], listBytes[3], listBytes[2]]
    # Take N last digit
    res = ""
    for i in range(digit):
        res = "{}".format(listBytes[3 - i]) + res
    return "0x" + res


def getTestName():
    """
    Retrieve current Robot Test name variable (fromRobotframework)
    :return: Full test name
    """
    return BuiltIn().get_variable_value("${TEST NAME}")


def getFormattedTestName():
    """
    rework test name by removing "[1]" and " " to avoid
    side effects when launching linux command including such name
    :return: formatted test name
    """
    return getTestName().replace("[1]", "").replace(" ", "_")


def setVarWithTestName(varname=None, prefix=None):
    """
    Set a variable as a suite variable with a prefix and the (formatted) test name
    :param varname: name of the variable to set
    :param prefix: string to prefix name
    :return: None. variable is set to <prefix>.<test_name>
    """
    BuiltIn().set_suite_variable("${" + varname + "}", "{}.{}".format(prefix, getFormattedTestName()))


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
