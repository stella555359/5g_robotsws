from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.ue.connections.device_aliases import ue_pc
from moler.util.moler_test import MolerTest

ue_configuration = get_builtin_value("tl.ues")


@load_moler_configuration_from_tl()
def attach_ue_with_adb_cmd(ue_id=0):
    """
    Attach ue with adb cmd.

    :param ue_id: UE_ID in configuration file
    :return: None
    """
    ue_serial_number = ue_configuration[ue_id].serial_number
    ue_controller = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    ue_controller.get_cmd(cmd_name="run_script", cmd_params={
        'script_command': "adb -s {} shell 'settings put global airplane_mode_on 0'".format(ue_serial_number)})()
    ue_controller.get_cmd(cmd_name="run_script", cmd_params={
        'script_command': "adb -s {} shell 'am broadcast -a android.intent.action.AIRPLANE_MODE'".format(
            ue_serial_number)})()
    MolerTest.sleep(5)


@load_moler_configuration_from_tl()
def detach_ue_with_adb_cmd(ue_id=0):
    """
    Detach ue with adb cmd.

    :param ue_id: UE_ID in configuration file
    :return: None
    """
    ue_serial_number = ue_configuration[ue_id].serial_number
    ue_controller = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    ue_controller.get_cmd(cmd_name="run_script", cmd_params={
        'script_command': "adb -s {} shell 'settings put global airplane_mode_on 1'".format(ue_serial_number)})()
    ue_controller.get_cmd(cmd_name="run_script", cmd_params={
        'script_command': "adb -s {} shell 'am broadcast -a android.intent.action.AIRPLANE_MODE'".format(
            ue_serial_number)})()
    MolerTest.sleep(5)
