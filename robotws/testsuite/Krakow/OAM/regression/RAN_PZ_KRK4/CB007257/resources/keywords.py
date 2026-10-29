import os
import re
from time import time

from moler.exceptions import CommandFailure
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.bts.connections import device_aliases
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.generic_bts import login_logout_GUI
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from testsuite.Krakow.OAM.regression.RAN_PZ_KRK4.CB007257.delta.TC_7_Intervals_and_timing_check\
    import tc_7_intervals_and_timing_check_delta, tc_7_intervals_and_timing_check_kpiAlarmMutingTime_delta, \
    tc_7_intervals_and_timing_check_cleaning_delta
from testsuite.Krakow.resources.alarm import Alarm

tl = BuiltIn().get_variable_value('${tl}')
global_bts_id = tl.gnbs[0].dus[0].global_bts_id
gnb_commissioning = GnbCommissioning()
alarm = Alarm()
builtin = BuiltIn()
cell_operations = GnbCellOperations()

fault_name = "The following KPI formula {} has been evaluated to true: {}".format(
        tc_7_intervals_and_timing_check_delta[1]['parameters'][0]['value'][0]['triggeringFormula'],
        tc_7_intervals_and_timing_check_delta[1]['parameters'][0]['value'][0]['formulaDescription']
    )


@MolerTest.raise_background_exceptions()
def check_interval_and_timing(cell_id=1):
    """
    Check interval and timing of kpiAlarmTriggers.

    :return: None
    """
    delta_timeToTrigger = tc_7_intervals_and_timing_check_delta.copy()
    delta_kpiAlarmMutingTime = tc_7_intervals_and_timing_check_kpiAlarmMutingTime_delta.copy()
    for x in range(3):
        delta_timeToTrigger[1]['parameters'][0]['value'][0]['timeToTrigger'] = str(x)
        delta_kpiAlarmMutingTime[0]['parameters'][0]['value'] = str(x+1)
        timeToTrigger_timeout = (x + 3) * 60 + 30
        kpiAlarmMutingTime_timeout = (x + 4) * 60 + 30
        builtin.log_to_console("Performing bts delta commissioning\nkpiAlarmMutingTime={}".format(x + 1))
        gnb_commissioning.perform_bts_delta_commissioning(delta=delta_kpiAlarmMutingTime)
        builtin.log_to_console("Performing bts delta commissioning\ntimeToTrigger={}".format(x))
        gnb_commissioning.perform_bts_delta_commissioning(delta=delta_timeToTrigger)
        builtin.log_to_console("Delta commissioning completed",)
        builtin.run_keyword("block_cell_and_wait_until_alarm_is_active", cell_id, timeToTrigger_timeout)
        builtin.run_keyword("unblock_cell_and_wait_until_alarm_is_not_active", cell_id, 120)
        MolerTest.sleep(kpiAlarmMutingTime_timeout)
        builtin.run_keyword("block_cell_and_wait_until_alarm_is_active", cell_id, timeToTrigger_timeout)
        builtin.run_keyword("unblock_cell_and_wait_until_alarm_is_not_active", cell_id, 120)
        gnb_commissioning.perform_bts_delta_commissioning(delta=tc_7_intervals_and_timing_check_cleaning_delta)


def block_cell_and_wait_until_alarm_is_active(cell_id=1, timeout=60):
    """
    Block cell (cell_id=1) and wait until alarm is active.

    :return: None
    """
    builtin.log_to_console("Blocking cell")
    cell_operations.block_cell(cell_id=cell_id)
    builtin.log_to_console("Cell blocked")
    builtin.log_to_console("Waiting until alarm {} is active".format(fault_name))
    alarm.wait_until_alarm_is_active_on_gnb(fault_name, timeout)
    builtin.log_to_console("Alarm {} is active".format(fault_name))


def unblock_cell_and_wait_until_alarm_is_not_active(cell_id=1, timeout=60):
    """
    Unblock cell (cell_id=1) and wait until alarm is not active.

    :return: None
    """
    builtin.log_to_console("Unblocking cell")
    cell_operations.unblock_cell(cell_id=cell_id)
    builtin.log_to_console("Cell unblocked")
    builtin.log_to_console("Waiting until alarm {} is not active".format(fault_name))
    alarm.wait_until_alarm_is_not_active_on_gnb(fault_name, timeout)
    builtin.log_to_console("Alarm {} is not active".format(fault_name))


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def prepare_snapshot_directory(bts_id=0, du_id=0):
    """
    Prepare directory for collected snapshot.

    :param bts_id: BTS ID
    :param du_id: DU ID
    :return: None
    """
    snapshot_path = os.path.join(get_builtin_value("OUTPUTDIR"), 'alarm_triggered_snapshot')
    vm = DeviceFactory.get_device(device_aliases.ssh_bts_du.format('GNB', bts_id, du_id), initial_state="PROXY_PC")
    try:
        vm.get_cmd(cmd_name="rm", cmd_params={
            "file": os.path.join(get_builtin_value("OUTPUTDIR"), 'alarm_triggered_snapshot'), "options": "-rf"})()
    except CommandFailure as e:
        if "No such file or directory" in str(e):
            MolerTest.info("snapshot directory does not exist")
        else:
            raise e
    vm.get_cmd(cmd_name="mkdir", cmd_params={"path": snapshot_path})()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def prepare_snapshot_directory_on_gnb(bts_id=0, du_id=0):
    """
    Prepare directory for collected snapshot on gNB.

    :param bts_id: BTS ID
    :param du_id: DU ID
    :return: None
    """
    snapshot_path = "snapshot/alarm_triggered_snapshot"
    vm = DeviceFactory.get_device(device_aliases.ssh_bts_du.format('GNB', bts_id, du_id), initial_state="FCT")
    try:
        vm.get_cmd(cmd_name="rm", cmd_params={
            "file": snapshot_path.split("/")[0], "options": "-rf"})()
    except CommandFailure as e:
        if "No such file or directory" in str(e):
            MolerTest.info("snapshot directory does not exist")
        else:
            raise e
    vm.get_cmd(cmd_name="mkdir", cmd_params={"path": snapshot_path, "options": "-p"})()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def configure_lss_user():
    """
    Configure lss user via admin api.

    :return: None
    """
    lss_username = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username
    lss_password = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password
    admin_connection = admin()
    admin_connection.connect_to()
    admin_connection.configure_lss_account(lss_username=lss_username, lss_password=lss_password)
    admin_connection.teardown()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def verify_snapshot_collected(timeout=180, bts_id=0, du_id=0):
    """
    Verify snapshot collected.

    :param timeout: timeout
    :param bts_id: BTS ID
    :param du_id: DU ID
    :return: None
    """
    snapshot_path = os.path.join(get_builtin_value("OUTPUTDIR"), 'alarm_triggered_snapshot')
    snapshot_dir_files = _wait_until_snapshot_collected(snapshot_path=snapshot_path, timeout=timeout, bts_id=bts_id,
                                                        du_id=du_id)
    _re_snapshot_file_name = r"Snapshot_MRBTS-{}.*".format(global_bts_id)
    snapshot_file_name = list(snapshot_dir_files.keys())[0]
    if not re.match(_re_snapshot_file_name, snapshot_file_name):
        MolerTest.error("Snapshot regex {} does not match, check in {}".format(_re_snapshot_file_name, snapshot_path),
                        raise_exception=True)
    else:
        MolerTest.info("Snapshot collected")


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def verify_snapshot_collected_on_gnb(timeout=180, bts_id=0, du_id=0):
    """
    Verify snapshot collected on gNB.

    :param timeout: timeout
    :param bts_id: BTS ID
    :param du_id: DU ID
    :return: None
    """
    snapshot_path = "snapshot/alarm_triggered_snapshot"
    snapshot_dir_files = _wait_until_snapshot_collected(snapshot_path=snapshot_path, timeout=timeout, bts_id=bts_id,
                                                        du_id=du_id, state="FCT")
    _re_snapshot_file_name = r"Snapshot_MRBTS-{}.*".format(global_bts_id)
    snapshot_file_name = list(snapshot_dir_files.keys())[0]
    if not re.match(_re_snapshot_file_name, snapshot_file_name):
        MolerTest.error("Snapshot regex {} does not match, check in {}".format(_re_snapshot_file_name, snapshot_path),
                        raise_exception=True)
    else:
        MolerTest.info("Snapshot collected")


def _wait_until_snapshot_collected(snapshot_path, timeout, bts_id, du_id, state="PROXY_PC"):
    vm = DeviceFactory.get_device(device_aliases.ssh_bts_du.format('GNB', bts_id, du_id), initial_state=state)
    timeout = int(timeout)
    start_time = time()
    elapsed_time = 0
    while elapsed_time < timeout:
        ls_cmd = vm.get_cmd(cmd_name="ls", cmd_params={"path": snapshot_path})
        files = ls_cmd()
        if files["files"]:
            return files["files"]
        MolerTest.sleep(15)
        elapsed_time = int(time() - start_time)
    MolerTest.error("Snapshot not collected, directory {} is empty".format(snapshot_path), raise_exception=True)


class SeleniumKeywords(GenericBts):
    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.

        """
        super(SeleniumKeywords, self).__init__(bts_type=SeleniumKeywords.bts_type)

    @login_logout_GUI
    def modify_fault_number(self, fault_number, gnb_id=0, du_id=0):
        """


        :return: None
        """
        gui_alias = self.gui_alias.format(gnb_id, du_id)
        self.gui_coam.activate_or_restore_default_faults(sbts=gui_alias)
        self.gui_coam.modify_fault_snapshot_trigger_list(fault_number=fault_number, new_fault_number="4570",
                                                         sbts=gui_alias)
        self.gui_coam.send_snapshot_configuration(sbts=gui_alias)

    @login_logout_GUI
    def get_fault_number(self, gnb_id=0, du_id=0):
        gui_alias = self.gui_alias.format(gnb_id, du_id)
        fault_list = self.gui_coam.get_snapshot_default_fault_list(sbts=gui_alias)
        return next(fault for fault in fault_list if fault["Trigger Type"] == "onFaultDetection")["Fault Number"]
