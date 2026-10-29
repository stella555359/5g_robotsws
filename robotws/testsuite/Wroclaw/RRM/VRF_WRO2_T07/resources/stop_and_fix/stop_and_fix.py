from taf.ul.alarms_watchdog import Alarm, alarms_watchdog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from json import load
from subprocess import check_output, call
from os.path import exists


AWS = alarms_watchdog()


@logged_keyword
def stop_and_fix(alarms_ids):
    alarms = [Alarm(fault_id=i) for i in alarms_ids]
    start_watchdog(alarms)


def start_watchdog(alarms):
    AWS.run_when_alarm_detected(callback=print_alarms, trigger_alarms=alarms)
    AWS.run_when_alarm_detected(callback=notification, trigger_alarms=alarms)
    AWS.run_when_alarm_detected(callback=AWS.stop_watching_alarms, trigger_alarms=alarms)
    AWS.run_when_alarm_detected(callback=stop_testline, trigger_alarms=alarms)
    AWS.watch_alarms()


@logged_keyword
def stop_watchdog():
    AWS.stop_watching_alarms()


def stop_testline():
    pid = get_pid_robot()
    pause_robot(pid)


def get_pid_robot():
    cmd = 'pgrep robot'
    pid = str(check_output(cmd, shell=True))[2:-3]
    return pid


def pause_robot(pid):
    cmd = 'kill -STOP {}'.format(pid)
    result = call(cmd, shell=True)
    blog(result)


def print_alarms():
    alarms = [i.fault_id for i in AWS.get_detected_alarms()]
    blog('Found alarms: {}'.format(alarms))


def notification():
    if exists('/opt/ute/execution.context.json'):
        with open('/opt/ute/execution.context.json') as json_file:
            result = load(json_file)

        cm_execution_id = result['CM_EXECUTION_ID']
        cmd = r'echo "put /opt/ute/execution.context.json %s.json"' % cm_execution_id \
              + r' | cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/'

        check_output(cmd, shell=True)
