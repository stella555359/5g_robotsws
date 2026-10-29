from contextlib import contextmanager
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from taf.analyzer.ims2 import Ims2ChangesetLogEntry, Ims2LogReader, Ims2ResetLogEntry


@contextmanager
def admin_connection(bts_host='192.168.255.129', username='Nemuadmin', password='nemuuser', alias='alarm'):
    conn = admin().connect_to(bts_host=bts_host, username=username, password=password, name=alias)
    yield conn
    admin().teardown_admin(connection=alias)


def check_fault_in_alarm_list(alarm_list, fault_id_expected):
    for alarm in alarm_list:
        fault_id_present = alarm['faultId']
        if str(fault_id_present) == str(fault_id_expected):
            return True
    return False


def check_if_expected_faults_except_allowed_are_present(bts_host, username, password, alias,
                                                        allowed_faults, expected_faults=None):
    """
    Checks if expected faults, except allowed are visible on BTS.
    If there are no any expected faults, empty 'expected_faults' list should be passed to keyword.
    In that case, there will be only check whether there are no unexpected faults on BTS.
    Pass if all expected faults are present on BTS and there are no unexpected faults.
    :author: artur.czainski@nokia.com
    :param: expected_faults: Expected faults list
    :param: allowed_faults: Allowed faults list that
    :return: none
    """
    unexpected_faults = {}
    if expected_faults is None:
        expected_faults = []
    active_faults = get_active_faults(bts_host, username, password, alias)
    logger.info("Active faults: \n{}".format(active_faults))

    logger.info("Check if expected faults occurred.")
    not_raised_faults_id = [fault for fault in expected_faults if fault not in active_faults.keys()]
    if len(not_raised_faults_id) != 0:
        BuiltIn().fail("\nExpected faults not raised! Not raised faults: {}".format(not_raised_faults_id))

    if len(expected_faults) != 0:
        allowed_fault_ids = list(allowed_faults) + expected_faults
    else:
        allowed_fault_ids = list(allowed_faults)
    logger.info("Check if no unexpected faults occurred.")
    unexpected_faults_id = [fault for fault in active_faults.keys() if fault not in allowed_fault_ids]
    for fault in unexpected_faults_id:
        unexpected_faults[fault] = active_faults[fault]
    if len(unexpected_faults) != 0:
        BuiltIn().fail("\nUnexpected faults occurred! Unexpected faults: \n{}".format(unexpected_faults))


def get_active_faults(bts_host, username, password, alias):
    """
    Connects to local bts (lmp 192.168.255.129), gets all alarms from BTS and, fetch faultID with description.
    :author: artur.czainski@nokia.com
    :param: none
    :return: dictionary {"faultId": "faultName", "faultId": "faultName"}:
        {'4681': u'Sanity Check Error', '4655': u'Service account root access is enabled',
        '4654': u'Ethernet port security is disabled', '61524': u'SSH enabled',
        '61649': u'LMP access via port 443', '61652': u'R&D Service Port enabled'}
    """
    with admin_connection(bts_host, username, password, alias) as conn:
        active_alarms = conn.get_active_alarms()
    fault_id_with_name = {}
    for alarm in active_alarms:
        fault_id_with_name[str(alarm["faultId"])] = alarm["faultName"]
    return fault_id_with_name


def get_all_faults_from_infomodel(file_path):
    """
    Fetch all faults from .ims2 log
    :author: artur.czainski@nokia.com
    :param: file_path: Path to .ims2 log
    :return: fault_ids: List of faultIDs
    """
    faults_list = {}
    fault_ids = []
    for log_entry in Ims2LogReader.from_file(file_path=file_path):
        if isinstance(log_entry, Ims2ChangesetLogEntry):
            for dist_name, value in log_entry.updates.items():
                if "ALARM-" in dist_name:
                    if value["alarmActivity"] == "Set":
                        faults_list[str(value["faultId"])] = str(value["alarmText"]["faultDescription"])
                        fault_ids.append(str(value["faultId"]))
    logger.info(faults_list)
    return fault_ids


def get_critical_alarms_list(alarm_list):
    """
       Returns the alarm list which have severity as critical
       :param alarm_list: Active alarms list present in the system.
       :return: List of alarms that have severity as Critical
       contact : gopalakrishnan.n@nokia.com
       """
    critical_alarm_list = [alarm['faultId'] for alarm in alarm_list if alarm['severity'] == 'Critical']
    return critical_alarm_list


def get_new_alarms_raised(original_alarm_list, new_alarm_list):
    """
           Returns the alarm list where alarms from second argument not present in alarm_list
           :param original_alarm_list: Alarm list which is base ideally the alarm list before the test
           :param new_alarm_list: Alarm list which needs to be compared ideally the alarm list got at the end of a test
           :return: List of alarms that not present in alarm_list
           contact : gopalakrishnan.n@nokia.com
           """
    if not new_alarm_list:
        return []
    if (not original_alarm_list) and new_alarm_list:
        return new_alarm_list
    if original_alarm_list == new_alarm_list:
        return []
    alarms_raised = list(set(new_alarm_list).difference(set(original_alarm_list)))
    return alarms_raised


def error_in_log_html(status_com, alarm_com, minutes):
    """
        Returns information about errors in the Test Execution Errors section. Mentioned errors relate to
        checking BTS status and alarms in the Suite Teardown with a given time gap.
    """
    if str(status_com) == 'False':
        logger.write("<h4>BTS status in the Suite Teardown has changed within " + minutes,
                     level="ERROR", html=True)
    if str(alarm_com) == 'False':
        logger.write("<h4>The alarm list in the Suite Teardown has changed within " + minutes,
                     level="ERROR", html=True)
