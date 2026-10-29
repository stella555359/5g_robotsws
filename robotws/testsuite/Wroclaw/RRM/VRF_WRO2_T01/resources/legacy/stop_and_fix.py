from json import load
from os.path import exists
from typing import List
from taf.ul.alarms_watchdog import Alarm, alarms_watchdog
from robot.api import logger
from subprocess import check_output, call
from robot.libraries.BuiltIn import BuiltIn

NO_CONNECTION_TO_UNIT = 10
UNIT_SYNCHRONIZATION_FAILED = 16
COMMUNICATION_FAILURE = 1806
BTS_CONFIG_ERROR_NOT_ENOUGH_HW_FOR_LCR = 1868
FSP_SUBUNIT_LOST_LINK = 4341
NO_CONNECTION_BETWEEN_PRIMARY_AND_BTS_EXTENSION_SYSTEM_MODULE = 4352
VIRTUAL_NODE_NOT_RESPONDING = 4383

FORBIDDEN_FAULTS = [NO_CONNECTION_TO_UNIT, UNIT_SYNCHRONIZATION_FAILED, COMMUNICATION_FAILURE,
                    BTS_CONFIG_ERROR_NOT_ENOUGH_HW_FOR_LCR, FSP_SUBUNIT_LOST_LINK,
                    NO_CONNECTION_BETWEEN_PRIMARY_AND_BTS_EXTENSION_SYSTEM_MODULE,
                    VIRTUAL_NODE_NOT_RESPONDING]


AWS = alarms_watchdog()
build_in = BuiltIn()


def check_alarms():
    alarms = [Alarm(fault_id=el) for el in FORBIDDEN_FAULTS]
    start_watchdog(alarms)


def start_watchdog(alarms_list: List[Alarm]):
    AWS.run_when_alarm_detected(callback=print_alarm_and_sleep, trigger_alarms=alarms_list)
    AWS.run_when_alarm_detected(callback=notification, trigger_alarms=alarms_list)
    AWS.run_when_alarm_detected(callback=AWS.stop_watching_alarms, trigger_alarms=alarms_list)
    AWS.run_when_alarm_detected(callback=stop_test_line, trigger_alarms=alarms_list)
    AWS.watch_alarms()


def print_alarm_and_sleep():
    alarms = [fault.fault_id for fault in AWS.get_detected_alarms()]
    alarms = ", ".join(alarms)
    logger.info("Forbidden fault found (faults: {0}), execution stopped".format(alarms))
    logger.console("Forbidden fault found (faults: {0}), execution stopped".format(alarms))


def notification():
    if exists('/opt/ute/execution.context.json'):
        with open('/opt/ute/execution.context.json') as json_file:
            result = load(json_file)

        cm_execution_id = result['CM_EXECUTION_ID']

        cmd = r'echo "put /opt/ute/execution.context.json %s.json"'.format(cm_execution_id) \
              + r' | cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/'

        check_output(cmd, shell=True)


def stop_test_line():
    pid = get_pid_robot()
    pause_robot(pid)


def get_pid_robot() -> List[str]:
    cmd = 'pgrep robot'
    pid = str(check_output(cmd, shell=True))[2:-3].split("\\n")
    return pid


def pause_robot(pid: List[str]):
    for el in pid:
        cmd = 'kill -STOP {}'.format(el)
        call(cmd, shell=True)


def stop_watchdog():
    AWS.stop_watching_alarms()


def remove_fault(fault_id: int) -> None:
    try:
        FORBIDDEN_FAULTS.remove(fault_id)
    except ValueError:
        return
    alarms = [Alarm(fault_id=el) for el in FORBIDDEN_FAULTS]
    stop_watchdog()
    start_watchdog(alarms)


def add_fault(fault_id: int):
    FORBIDDEN_FAULTS.append(fault_id)
    alarms = [Alarm(fault_id=el) for el in FORBIDDEN_FAULTS]
    stop_watchdog()
    start_watchdog(alarms)
