from robot.libraries.BuiltIn import BuiltIn

import logging
import time
import SISO_exceptions as ex
import SISO_Utilities as utility
import tl_topology as topology

from taf.sbts.oam.coam.admin import admin
from taf.gnb.oam.megazone_client import megazone_client
from taf.ul.alarms_watchdog import Alarm

log = logging.getLogger(__name__)


allowed_alarms = {'CLASSICAL': ['LMP access via port',
                                'SSH enabled',
                                'R&D Service Port enabled',
                                'Temp Fault1',
                                'LMP access via port 443',
                                'LMP access via port 3600',
                                'BTS Reset Cause'],
                  'CLOUD': ['LOS on BBMOD-1, Q-RF2-1',
                            'LOS on BBMOD-1, Q-RF2-2',
                            'LOS on BBMOD-1, Q-RF2-3',
                            'LOS on BBMOD-1, Q-RF2-4',
                            '61029 LOS on BBMOD-1, Q-RF2-1',
                            '61029 LOS on BBMOD-1, Q-RF2-2',
                            '61029 LOS on BBMOD-1, Q-RF2-3',
                            '61029 LOS on BBMOD-1, Q-RF2-4']}


def set_global_allowed_alarms():
    """
    [DEPRECATED]
    Sets global allowed alarms variable in Robot global scope. Allowed alarms are defined allowed_alarms dict
    in alarms.py. If user would like to extend the list, append desired fault name to suitable list.
    :raises: ValueError exception if there are no allowed alarms for chosen testline topology
    """
    log.warning("Keyword set_global_allowed_alarms is deprecated and will be removed soon.")
    tl_topology = _get_tl_topology()
    allowed_fault_names = _get_allowed_fault_names(tl_topology)
    BuiltIn().set_global_variable('${ALLOWED_ALARMS}', allowed_fault_names)


def get_default_allowed_alarms():
    """
    Gets default allowed alarms for particular testline topology.
    :return: list of default allowed alarms read from allowed_alarms variable in alarms.py.
    Each alarm is converted to Alarm object from taf.ul.alarms-watchdog library.
    :rtype: list(Alarm)
    :raises: ValueError exception if there are no allowed alarms for chosen testline topology
    """
    tl_topology = _get_tl_topology()
    allowed_fault_names = _get_allowed_fault_names(tl_topology)
    return [Alarm(fault_name=allowed_fault_name) for allowed_fault_name in allowed_fault_names]


def get_active_alarms(session, coam=False):
    """
    Get all active alarms on BTS via megazone/coam API
    :param session: Session to use, can be an alias or SessionHandler object.
    :type session; object
    :param coam: (Optional) if True , return list active alarms for coam.
    :type coam: bool
    :return: List of dicts
    """
    if coam:
        adm = admin()
        return adm.get_active_alarms(connection=session)
    megazone = megazone_client()
    return megazone.get_active_alarms(session=session)


def check_fault_report_by_admin(fault, session):
    """
    [DEPRECATED]
    Get active alarms and prints the information about fault requested by user (if is present) on cOAM BTS

    :param fault: Fault ID user wants to check.
    :type fault: int/str
    :param session: Session to use, can be an alias or SessionHandler object
    :type session: object
    :return: True if fault with id requested by user is present on cOAM BTS.
    :rtype: Boolean
    :raises: FaultIsNotPresent exception when fault asked by user is not present in active alarms on cOAM BTS.
    """
    alarms = get_active_alarms(session, coam=True)
    for alarm in alarms:
        alarm_get = alarm.get('faultId')
        if int(alarm_get) == int(fault):
            return True
    raise ex.FaultIsNotPresent("Fault {} doesn't occur".format(fault))


def wait_for_fault_to_disappear_admin(fault, timeout, session):
    """
    [DEPRECATED]
    Waits for given fault to disappear in WebUI on cOAM BTS.
    :param fault: Fault ID user wants to check.
    :type fault: int/str
    :param timeout: Max timeout to wait in seconds for fault to disappear
    :type timeout: int/str
    :param session: Session to use, can be an alias or SessionHandler object.
    :type session: object
    :raises: TimeoutError when timeout to wait for fault to disappear exceeds provided timeout
    """
    timeout = int(timeout)
    while timeout > 0:
        alarms = get_active_alarms(session, coam=True)
        alarms_get = [int(alarm.get('faultId')) for alarm in alarms]
        if int(fault) not in alarms_get:
            break
        timeout -= 1
        time.sleep(1)
    if timeout == 0:
        raise ex.TimeoutError


def show_alarms_coam1(fail_test, tl_topology, allowed_alarms_names=None, admin_api_log_dir='/tmp'):
    """
    [DEPRECATED]
    Show alarms reported on WebUI,

    :param fail_test: If True raise UnexpectedAlarm exception
        in case of any unexpected alarms
    :type fail_test: boolean
    :param tl_topology: Type of test line topology
    :type tl_topology: Str
    :param admin_api_log_dir: (optional) AdminAPI log dir
    :type admin_api_log_dir: Str
    :param allowed_alarms_names: List allowed alarms names
    :type allowed_alarms_names: List of Str
    :raises UnexpectedAlarm exception if not allowed alarms are present and 'fail_test' switch is set to True
    """
    log.info("Allowed alarms names: {}".format(allowed_alarms_names))
    alarms = get_all_active_alarms(tl_topology, admin_api_log_dir)
    log.info("Response from API: {}".format(alarms))
    allowed_alarms_names = [] if not allowed_alarms_names else allowed_alarms_names
    not_allowed_alarms = [_get_alarm_name_and_desc(tl_topology, alarm) for alarm in alarms
                          if _get_alarm_name_and_desc(tl_topology, alarm)[1] not in allowed_alarms_names]
    log.info("Not allowed alarms names: {}".format(not_allowed_alarms))
    log.info("Number of not allowed alarms: {}".format(len(not_allowed_alarms)))
    if fail_test and not_allowed_alarms:
        raise ex.UnexpectedAlarm("Unexpected alarms: {}".format(not_allowed_alarms))


def get_all_active_alarms(tl_topology, admin_api_log_dir='/tmp'):
    """
    Gets active alarms from BTS.

    :param tl_topology: Type of test line topology
    :type tl_topology: Str
    :param admin_api_log_dir: (optional) AdminAPI log dir
    :type admin_api_log_dir: Str
    :return: list of active alarms
    :rtype: list of dicts
    :raises: TypeLineDoseNotExist exception if user requests for testline topology that is not
             handled by get_all_active_alarms
    """
    base_url, username, password = utility.get_details_to_login_from_init('http')

    if tl_topology == 'CLOUD':
        return _get_active_alarms_cloud(base_url=base_url, username=username, password=password)
    if tl_topology == 'CLASSICAL':
        return _get_active_alarms_coam(base_url=base_url, username=username, password=password,
                                       log_dir=admin_api_log_dir)
    else:
        raise ex.TypeLineDoseNotExist("This test line topology: {} doesn't exist".format(tl_topology))


def wait_for_active_alarm(fault_id, tl_topology, timeout=60):
    """
    [DEPRECATED]
    Waits for active alarm with given fault ID.
    :param fault_id: fault ID which expected alarm should have
    :type fault_id: int
    :param tl_topology: type of test line topology, i.e. 'cOAM'
    :type tl_topology: str
    :param timeout: time to wait for alarm to be detected, in seconds; defaults to 60 seconds
    :type timeout: int
    :return: True if alarm with given fault ID is detected before timeout, False otherwise
    :rtype: bool
    """

    start = time.time()

    while time.time() - start < int(timeout):
        active_alarms = get_all_active_alarms(tl_topology)
        for active_alarm in active_alarms:
            if str(active_alarm.get('faultId', '')) == str(fault_id):
                return True
    return False


def _get_allowed_fault_names(tl_topology):
    allowed_fault_names = allowed_alarms.get(tl_topology, None)

    if allowed_fault_names is None:
        raise ValueError('No allowed alarms defined for test line topology: {}'.format(tl_topology))

    return allowed_fault_names


def _get_tl_topology():
    tl_topology_from_config = BuiltIn().get_variable_value('${tl.tl_cloud_topology}')
    return topology.get_test_line_topology(tl_topology_from_config)


def _get_active_alarms_coam(base_url, username, password, log_dir):
    ad = admin()
    ad.connect_to(bts_host=base_url, username=username, password=password, bts_port=3600,
                  reconnect_with_default_on_failure=True, name='_ad_alarms', admin_api_log_dir=log_dir)
    try:
        alarms = ad.get_active_alarms(connection='_ad_alarms')
    finally:
        ad.teardown(connection='_ad_alarms')
    return alarms


def _get_alarm_name_and_desc(tl_topology, alarm):
    if tl_topology == 'CLOUD':
        return alarm["additionalText1"].split(' ', 1)
    if tl_topology == 'CLASSICAL':
        return ['AlarmId: {0}'.format(alarm["alarmId"]), alarm["alarmDetail"],
                "FaultID: {0}".format(str(alarm["faultId"]))]


def number_of_specific_active_faults_cOAM1(alarm_id, connection):
    """
    Returns count of specific alarms on WebUI
    :param alarm_id: Alarm ID, ex. 10
    :type alarm_id: int
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: number of alarms
    :rtype int
    """
    adm = admin()
    list_of_active_faults = adm.get_active_alarms(connection=connection)

    return len([alarm['faultId'] for alarm in list_of_active_faults if alarm['faultId'] == int(alarm_id)])
