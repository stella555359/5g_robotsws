import re
import time
from datetime import datetime
import xml.etree.ElementTree as ET
from xml.parsers.expat import ExpatError


def estimateDeltaInHours():
    """
    This function is estimated the delta between GMT and Local Time
    :return: Hour delta
    """
    local_time = time.localtime()
    gmt_time = time.gmtime()
    tuple_local_time = [x for x in local_time]
    tuple_gmt_time = [x for x in gmt_time]
    deltaInHours = tuple_local_time[3] - tuple_gmt_time[3]
    return deltaInHours


def getCallDuration(DateTime1, DateTime2):
    """
    This function is invoked to get the time (in sec) between two date
    :param: DateTime1 is a timestamp (the older)
    :param: DateTime2 is a timestamp (the newer)
    :return: DateTime2 - DateTime1 in second
    """

    PMformat = "%Y-%m-%d %H:%M:%S"
    diff = datetime.strptime(DateTime2, PMformat) - datetime.strptime(
        DateTime1, PMformat
    )
    deltaInSeconds = int((diff.seconds))
    return deltaInSeconds


def getPMFormattedTime(pm_interval):
    """
    This function is invoked to get the time rounded to the previous Xmin
    :param: pm_interval is either 5 or 10 or 15 minutes: see your SCF file for PM counter interval
    :return: the rounded and formatted time to timeStep minutes
    """

    currTime = time.time()
    PMformat = "%Y-%m-%dT%H:%M:00"
    step = int(pm_interval)
    # Next slot time:
    # roundedTime = (int ((currTime / (step * 60)))+1) * ( step * 60)
    # Previous slot time:
    roundedTime = (int((currTime / (step * 60))) + 0) * (step * 60)
    formattedTime = time.strftime(PMformat, time.localtime(roundedTime))
    return formattedTime


def getTimeSlotNumber(startTime, stopTime, pm_interval):
    """
    This function estimate the time delta between the two dates
    :param: startTime is formatted  like this : %Y-%m-%dT%H:%M:00
    :param: stopTime is formatted  like this : %Y-%m-%dT%H:%M:00
    :param: timeStamp is the counter timeslot : 5 or 10 or 15 minutes
    :return: the number of time slots
    """
    PMformat = "%Y-%m-%dT%H:%M:00"
    step = int(pm_interval)
    diff = datetime.strptime(stopTime, PMformat) - datetime.strptime(
        startTime, PMformat
    )
    slotNumber = int((diff.seconds / (step * 60)))
    return slotNumber


def setToPMFormat(inputTime):
    """
    This function set to PM format (%Y-%m-%dT%H:%M:00) the input date (%Y-%m-%d %H:%M:00)
    :param: inputTime is formatted  like this : %Y-%m-%dT%H:%M:00
    :return: the input time in PM format
    """
    outputTime = inputTime.replace(" ", "T")
    return outputTime


def timeToSleepBeforeNextCountersPeriod(counterPeriod=5, delay=1, offset=30):
    """
    This function calculates the time to sleep before the start of the next PM counters period
    :param: counterPeriod defined the PM counter Period: either 5min ou 15min. See in your SCF file the
     counters duration
    :param: delay    defined the minimum time (in minute) to generate the next PM counters reporting file
    :param: offset        defined the minimum time (in seconds) before the start of the next PM counters period
    :return: the time to sleep (in seconds) before the next PM counters period
    """
    currTime = time.time()
    getNextTimeSlot = (int((currTime / (int(counterPeriod) * 60))) + 1) * (
        int(counterPeriod) * 60
    )
    timeToSleep = int(getNextTimeSlot - currTime) + 1
    if timeToSleep < int(offset):
        timeToSleep += int(counterPeriod) * 60
    timeToSleep += int(delay) * 60
    return timeToSleep


def cOamGetPMCounterValue(xmlList, xmlPathname, timeSlot, counterName):
    """
    Get the summed value of a counter in a specified time slots list
    :param xmlList      : List of PM files to be parsed
    :param xmlPathname  : (string) directory pathname where xml files are stored
    :param timeSlot     : List of time slot in which we will extract the counter values
    :param counterName  : (string) DRX counter name
    :return: Either the counter value or 'None' if counter is not found
    """

    # if winter time : timeSlot = timeSlot + '.000+01:00:00'
    # if summer time : timeSlot = timeSlot + '.000+02:00:00'
    deltaInHours = estimateDeltaInHours()
    timeSlot = timeSlot + ".000+0" + str(deltaInHours) + ":00:00"
    counterValue = 0
    timeslotfound = "Not Found"

    for PMfile in xmlList:
        PMfile = PMfile.replace(".gz", "")
        response = cOamGetDrxCounterValue(
            xmlPathname, PMfile, timeSlot, counterName)
        if response != "Not Found" and timeslotfound == "Not Found":
            counterValue += int(response)
            timeslotfound = "Found"
    return counterValue


def cOamGetPMCounterValueForSpecifiedCell(
    xmlList, xmlPathname, timeSlot, counterName, cellName=None
):
    """
    Get the summed value of a counter in a specified time slots list
    :param xmlList      : List of PM files to be parsed
    :param xmlPathname  : (string) directory pathname where xml files are stored
    :param timeSlot     : List of time slot in which we will extract the counter values
    :param counterName  : (string) DRX counter name
    :param cellName     : (string) CellId like "PLMN-PLMN/MRBTS-39/NRBTS-23178/NRCELL-2")
    :return: Either the counter value or 'None' if counter is not found
    """

    # if winter time : timeSlot = timeSlot + '.000+01:00:00'
    # if summer time : timeSlot = timeSlot + '.000+02:00:00'
    deltaInHours = estimateDeltaInHours()
    timeSlot = timeSlot + ".000+0" + str(deltaInHours) + ":00:00"
    counterValue = 0
    timeslotfound = "Not Found"

    for PMfile in xmlList:
        PMfile = PMfile.replace(".gz", "")
        response = cOamGetCounterValue(
            xmlPathname, PMfile, timeSlot, counterName, cellName
        )
        if response != "Not Found" and timeslotfound == "Not Found":
            counterValue += int(response)
            timeslotfound = "Found"
    print("***************************")
    print("timeslotfound:%s" % timeslotfound)
    return counterValue


def cOamGetCounterValue(
    targetDirectory, fileToAnalyse, expectedTime, counterName, objectName=None
):
    """
    This function is invoked to get the value of a specified Counter
    :param targetDirectory : (string) directory pathname where xml files are stored
    :param fileToAnalyse   : (string) xml file to be parsed
    :param expectedTime    : (string) time slot in which we will extract the counter value
    :param counterName     : (string) counter name
    :param objectName      : (string) Network element name (optional)
    :return: Either the counter value or 'None' if counter is not found
    """

    fullname = targetDirectory + "/" + fileToAnalyse
    print("***************************")
    print("fullname:%s" % fullname)
    print("targetDirectory:%s" % targetDirectory)

    timeInterval = "5"
    objFlag = False
    counterFlag = False
    pmFlag = False
    coutValue = None
    selectObj = None
    selectCouter = None
    selectTime = None
    selectInterval = None

    if objectName is None:
        objFlag = True

    # Parsing starts at the innermost node
    for event, elem in ET.iterparse(fullname, events=('end',)):
        if counterFlag is False and elem.tag == "DN":
            if objectName is not None and elem.text == objectName:
                objFlag = True
                selectObj = elem.text
        if objFlag is True and counterFlag is False:
            if elem.tag == counterName:
                counterFlag = True
                coutValue = elem.text
                selectCouter = elem.tag
        if elem.tag == "PMSetup":
            if objFlag is True and counterFlag is True:
                if elem.attrib["startTime"] == expectedTime and elem.attrib["interval"] == timeInterval:
                    selectTime = elem.attrib["startTime"]
                    selectInterval = elem.attrib["interval"]
                    pmFlag = True
                else:
                    objFlag = False
                    counterFlag = False
                    selectObj = None
                    selectCouter = None
            else:
                objFlag = False
                counterFlag = False
                selectObj = None
                selectCouter = None
        if objFlag is True and counterFlag is True and pmFlag is True:
            print("start time is: %s and interval is: %s" % (selectTime, selectInterval))
            print("objectName is: %s" % selectObj)
            print("counterName is: %s" % selectCouter)
            print("the couter value is: %s" % coutValue)
            elem.clear
            return coutValue
        elem.clear
    return "Not Found"


def cOamGetDrxCounterValue(
        targetDirectory,
        fileToAnalyse,
        expectedTime,
        counterName):
    """
    This function is invoked to get the value of a DRX Counters
    :param targetDirectory : (string) directory pathname where xml files are stored
    :param fileToAnalyse   : (string) xml file to be parsed
    :param expectedTime    : (string) time slot in which we will extract the counter value
    :param counterName     : (string) DRX counter name
    :return: Either the counter value or 'None' if counter is not found
    """

    patternToFind = ".//PMMOResult/..[@startTime=" + "'" + expectedTime + "']"
    iterToFind = "./PMMOResult/NE-WBTS_1.0/" + counterName
    value = "Not Found"
    fullname = targetDirectory + "/" + fileToAnalyse
    tree = ET.parse(fullname)
    root = tree.getroot()
    my_item1 = root.findall(patternToFind)
    for element in my_item1:
        iterator = element.iterfind(iterToFind)
        for item in iterator:
            value = item.text
    return value


def cOamGetPMCounterValueMultiCells(
        xmlList,
        xmlPathname,
        timeSlot,
        counterName):
    """
    Get the summed value of a counter in a specified time slots list
    :param xmlList      : List of PM files to be parsed
    :param xmlPathname  : (string) directory pathname where xml files are stored
    :param timeSlot     : List of time slot in which we will extract the counter values
    :param counterName  : (string) counter name
    :return: Either the counter value or 'None' if counter is not found
    """

    # if winter time : timeSlot = timeSlot + '.000+01:00:00'
    # if summer time : timeSlot = timeSlot + '.000+02:00:00'
    deltaInHours = estimateDeltaInHours()
    counterValue = 0
    for timeSlotElement in timeSlot:
        timeSlotElement = timeSlotElement + \
            ".000+0" + str(deltaInHours) + ":00:00"
        print(timeSlotElement)
        # counterValue = 0
        timeslotfound = "Not Found"

        for PMfile in xmlList:
            PMfile = PMfile.replace(".gz", "")
            response = cOamGetCounterValueMultiCells(
                xmlPathname, PMfile, timeSlotElement, counterName
            )
            counterValue += int(response)
    return counterValue


def cOamGetCounterValueMultiCells(
    targetDirectory, fileToAnalyse, expectedTime, counterName
):
    """
    This function is invoked to get the value of Counters - multicell case
    :param targetDirectory : (string) directory pathname where xml files are stored
    :param fileToAnalyse   : (string) xml file to be parsed
    :param expectedTime    : (string) time slot in which we will extract the counter value
    :param counterName     : (string) counter name
    :return: Either the counter value or 0 if counter is not found
    """

    patternToFind = ".//PMMOResult/..[@startTime=" + "'" + expectedTime + "']"
    iterToFind = "./PMMOResult/NE-WBTS_1.0/" + counterName
    value = 0
    total_value = 0
    fullname = targetDirectory + "/" + fileToAnalyse
    tree = ET.parse(fullname)
    root = tree.getroot()
    my_item1 = root.findall(patternToFind)
    for element in my_item1:
        # print (element)
        iterator = element.iterfind(iterToFind)
        for item in iterator:
            # print (item)
            value = int(item.text)
            print(value)
            total_value = total_value + value
    return total_value


def cOamFilterXMLFilesList(xmlFileList, startingDate, endingDate):
    XMLList = []
    for filename in xmlFileList:
        xmlDate = cOamGetFileDate(filename)
        if xmlDate:
            if xmlDate < startingDate:
                pass
            elif xmlDate > endingDate:
                XMLList.append(filename.rstrip())
                break
            else:
                XMLList.append(filename.rstrip())
    return XMLList


def cOamGetFileDate(filename):
    regularExpression = "(\\d{8}.\\d{6})"
    m = re.search(regularExpression, filename)
    print("m", m)
    if m:
        try:
            result = m.group(1)
        except IndexError:
            result = None
    else:
        result = None
    return result


def cOamCreateXMLFilesList(xmlFileList):
    XMLList = []
    for filename in xmlFileList:
        if filename != "":
            XMLList.append(filename.rstrip())
    return XMLList


def filterXMLFilesList(xmlFileList, startingDate, endingDate):
    XMLList = []
    for filename in xmlFileList:
        xmlDate = getFileDate(filename)
        if xmlDate:
            if xmlDate < startingDate:
                pass
            elif xmlDate > endingDate:
                XMLList.append(filename.rstrip())
                break
            else:
                XMLList.append(filename.rstrip())
    return XMLList


def getFileDate(filename):
    regularExpression = "(\\d{8}_\\d{6})"
    m = re.search(regularExpression, filename)
    if m:
        try:
            result = m.group(1)
        except IndexError:
            result = None
    else:
        result = None
    return result


def checkTestResult(result_xml, **kwargs):
    """Get test result parsing Airmosaic xml file got from getTestResult API
    Input arguments are:

    :paramr result_xml: string containing the Airmosaic test result xml
    :param path(optional): full path and name of the saved result xml. If present, check is done on the xml file,
                           result_xml string otherwise
    :return: return {'output': <output>, 'result': success/failed, 'error': <array of errors if any>}

    :example: checkTestResult('',path='/tmp/Result.xml')
    :example output: {'output': 'No Error', 'result': 'success', 'error': ''}


    """
    path = ""
    if "path" in kwargs:
        path = kwargs["path"]
        resultfile = open(path, "r")
        result_xml = resultfile.read()
    if len(result_xml) == 0 and path == "":
        return {"result": "failed", "error": "Nothing to check"}
    try:
        root = ET.fromstring(result_xml)
    except ExpatError:
        return {
            "result": "failed",
            "error": "Wrong Test Result format",
            "output": "No Error",
        }
    errdescr = []
    toterr = 0
    for elem in root.iter("TestProcedure"):
        if elem.attrib.get("NumFailure") != "0" and elem.attrib.get(
                "NumFailure") != "":
            sessionname = root.find(".//%s/.." % elem.tag)
            groupname = root.find(".//%s/.." % sessionname.tag)
            errdescr.append(
                {
                    "Group": groupname.attrib["GroupName"],
                    "Session": sessionname.attrib["SessionName"],
                    "TestProcedure": elem.attrib["TestProcedureKind"],
                    "NumFailure": elem.attrib["NumFailure"],
                }
            )
            toterr = toterr + 1

    if errdescr == []:
        result = {"result": "success", "error": "", "output": "No Error"}
    else:
        result = {
            "result": "failed",
            "error": "Counter checks not passed.",
            "output": errdescr,
        }
    return result


def cOamCheckSleepStatusForSpecifiedCell(xmlList, xmlPathname, timeSlot, counterName, counterName1, cellName):
    deltaInHours = estimateDeltaInHours()
    timeSlot = timeSlot + '.000+0' + str(deltaInHours) + ':00:00'
    print('timeslot:%s' % timeSlot)
    result = 1
    for PMfile in xmlList:
        PMfile = PMfile.replace('.gz', '')
        response_active = cOamGetCounterValue(xmlPathname, PMfile, timeSlot, counterName, cellName)
        response_sleep = cOamGetCounterValue(xmlPathname, PMfile, timeSlot, counterName1, cellName)
        active = 0
        sleep = 0
        if response_active != 'Not Found':
            print('active:%s' % response_active)
            active = response_active
        else:
            print('active no found')
        if response_sleep != 'Not Found':
            print('sleep:%s' % response_sleep)
            sleep = response_sleep
        else:
            print('sleep not found')
        if int(active) >= 120000 and int(sleep) == 0:
            result = 0
            return result

    print("***************************")
    return result
