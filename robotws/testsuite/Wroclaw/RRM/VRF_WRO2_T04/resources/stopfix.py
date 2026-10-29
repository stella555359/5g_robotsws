import os
import json
import importlib
import subprocess
from robot.api import logger
from taf.ul.alarms_watchdog import alarms_watchdog
from taf.transport.ssh import ssh
from taf.transport.ssh.connection import FileProtocolClientError, ConnectionError
from taf.internal.sbts.admin.exceptions.exception import AdminApiProcedureFailureException
from testsuite.Wroclaw.RRM.resources.rrm_fixture import (
    get_oam_ip,
    get_oam_user,
    get_oam_pass
)
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog import \
    start_btslog_on_local_machine, stop_and_collect_btslog
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.HR.resources.aashell_commands import execute_aashell_command
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import wait_for_ru, wait_for_bbmod


class TruckRollFaultException(Exception):
    pass


class TruckRollHostNotPingable(Exception):
    pass


STOP_FIX_FAULTS = {
    'NO_CONNECTION_TO_UNIT': 10,
    'COMMUNICATION_FAILURE': 1806,
    'FSP_SUBUNIT_LOST': 4341,
    'NO_CONNECTION_BETWEEN_PRIMARY_AND_EXTENSION': 4352,
    'VIRTUAL_NODE_NOT_RESPONDING': 4383
}

watchdog = alarms_watchdog()


def import_pause():
    try:
        from robot.libraries.Dialogs import pause_execution as robot_pause
    except (ImportError, ModuleNotFoundError):
        robot_pause = importlib.import_module('robot.libraries.Dialogs').pause_execution
    return robot_pause


def start_watching_stopfix_alarms():
    watchdog.watch_alarms()


def stop_watching_stopfix_alarms():
    robot_pause = import_pause()
    try:
        verify_stop_fix_alarms()
        check_lmp_connectivity()
        check_mplane_connectivity()
        wait_for_ru()
        wait_for_bbmod()
    except (TruckRollFaultException, TruckRollHostNotPingable):
        __collect_snapshot(filename='{}/stopfix_snapshot.zip'.format(get_robot_output_dir()))
        os.system('killall btslog')
        start_btslog_on_local_machine(log_name='stopfix_syslog')
        notification()
        robot_pause("[ STOP&FIX ] FAULT detected!! Execution paused. Press OK to continue")
        stop_and_collect_btslog(log_name='stopfix_syslog', target_dir=get_robot_output_dir())


def verify_stop_fix_alarms():
    logger.info("Stop watching alarms")
    alarms = watchdog.get_detected_alarms()
    faults = [int(alarm.fault_id) for alarm in alarms]
    logger.info("Detected faults: {}".format(faults))
    logger.info("Unallowed faults: {}".format(STOP_FIX_FAULTS.values()))
    watchdog.stop_watching_alarms()

    if any([fault in faults for fault in STOP_FIX_FAULTS.values()]):
        raise TruckRollFaultException("STOP&FIX FAULT detected!! Execution will be stopped!")


def __collect_snapshot(filename):
    with AdminSession() as admin_session:
        try:
            admin_session.collect_snapshot(target_file_name=filename)
            raise AdminApiProcedureFailureException
        except AdminApiProcedureFailureException:
            logger.error("Snapshot collection failed! Trying to collect snapshot via ssh")
            try:
                collect_snapshot_via_ssh()
            except ConnectionError:
                logger.error("Connection error, snapshot could not be collected. "
                             "Please try to collect snapshot manually.")


def check_lmp_connectivity():
    lmp = tl.gnbs[0].cu.oam_ssh_connection_details.addr
    if not __is_host_pingable(lmp):
        raise TruckRollFaultException("[STOP&FIX] \n"
                                      "BTS LMP ({}) is not pingable!! Execution will be stopped!".format(lmp))


def check_mplane_connectivity():
    mplane = tl.gnbs[0].cu.backhaul_site_oam_ip.v4
    if not __is_host_pingable(mplane):
        raise TruckRollFaultException("[STOP&FIX] \n"
                                      "BTS MPLANE ({}) is not pingable!! Execution will be stopped!".format(mplane))


def __is_host_pingable(host):
    result = os.system('ping -c 1 {}'.format(host))
    if result != 0:
        return False
    return True


def collect_snapshot_via_ssh():
    snapshot_filename = 'stopfix_snapshot_ssh.zip'
    remote_filepath = '/ram/{}'.format(snapshot_filename)
    execute_aashell_command('log -a -z {}'.format(snapshot_filename), json_output=False)
    ssh_client = ssh()
    try:
        ssh_client.connect_to(get_oam_ip(), get_oam_user(), get_oam_pass(), alias='stopfix_snapshot')
        ssh_client.download_file('/ram/{}'.format(snapshot_filename),
                                 '{}/{}'.format(get_robot_output_dir(), snapshot_filename),
                                 connection='stopfix_snapshot')
        ssh_client.execute('rm -f {}'.format(remote_filepath), connection='stopfix_snapshot')
    except FileProtocolClientError:
        logger.error("Snapshot collection failed via ssh!")
    finally:
        ssh_client.disconnect(connection='stopfix_snapshot')


def notification():
    if os.path.exists('/opt/ute/execution.context.json'):
        with open('/opt/ute/execution.context.json') as json_file:
            result = json.load(json_file)

        cmd = r'echo "put /opt/ute/execution.context.json {}.json"'.format(result['CM_EXECUTION_ID']) \
              + r' | cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/'
        subprocess.check_output(cmd, shell=True)
