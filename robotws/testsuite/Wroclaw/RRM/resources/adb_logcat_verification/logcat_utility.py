import re
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture


def check_logcat_attach(logcatdump_path):
    """
    Checks for last 5G connection status from logcat dump from UE, raises exception,
    if file does not contain neccessary prints - probably not collected properly
    or QC-UE 5G modem is not responding from boottime to log collection
    :param str logcatdump_path: path to local(testPC) logcat dump file from UE
    :return: bool:  last is5GConnected from UE
    """
    logcontent = str(fixture.file_to_string(logcatdump_path))
    fiveGstatuses = re.findall("(is5GConnected) (true|false)", logcontent)
    fixture.log_message(message="fiveGstatus_statement: {}, type: {}".format(fiveGstatuses, type(fiveGstatuses)))
    try:
        last5Gstatus = fiveGstatuses[-1][-1]
    except LookupError:
        last5Gstatus = None

    fixture.log_message(message="Is 5G connected: {}".format(last5Gstatus))

    assert last5Gstatus in ['true', 'false'], "There's no 'is5GConnected' statement inside logcat dump"
    assert last5Gstatus == 'true', "Last 5G Connection status is: FALSE - UE not connected to 5G network"
    return True
