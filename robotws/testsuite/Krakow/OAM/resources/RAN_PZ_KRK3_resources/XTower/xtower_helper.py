import time
from moler.device import DeviceFactory
from taf.ul.sc.util.helpers import generate_unix_remote_device
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


@load_moler_configuration_from_tl()
def xtower_start(device_name, host, login, password):
    generate_unix_remote_device(device_name=device_name, host=host, login=login, password=password)
    xtower = DeviceFactory.get_device(device_name)
    xtower.goto_state("UNIX_REMOTE")
    xtower_stop(device_name)
    time.sleep(90)
    start_cmd = xtower.get_cmd(cmd_name="run_script",
                               cmd_params={
                                   'script_command': '/home/ute/xtower_turn_on.sh &'
                               })
    start_cmd(timeout=60)


def xtower_stop(device_name):
    xtower = DeviceFactory.get_device(device_name)
    xtower.goto_state("UNIX_REMOTE")
    start_cmd = xtower.get_cmd(cmd_name="run_script",
                               cmd_params={
                                   'script_command': '/home/ute/xtower_turn_off.sh &'
                               })
    start_cmd(timeout=60)


@load_moler_configuration_from_tl()
def xtower_x2_start(device_name, host, login, password):
    generate_unix_remote_device(device_name=device_name, host=host, login=login, password=password)
    xtower = DeviceFactory.get_device(device_name)
    xtower.goto_state("UNIX_REMOTE")
    xtower_x2_stop(device_name)
    start_cmd = xtower.get_cmd(cmd_name="run_script",
                               cmd_params={
                                   'script_command': '/home/ute/xtower_turn_on_x2.sh &'
                               })
    start_cmd(timeout=60)


def xtower_x2_stop(device_name):
    xtower = DeviceFactory.get_device(device_name)
    xtower.goto_state("UNIX_REMOTE")
    start_cmd = xtower.get_cmd(cmd_name="run_script",
                               cmd_params={
                                   'script_command': '/home/ute/xtower_turn_off_x2.sh &'
                               })
    start_cmd(timeout=60)
