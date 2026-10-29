from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.robot.RobotKWRunner import run_as_robot_kw as convert_to_robot_kw
from taf.ul.moler.converter.interface import get_devices_from_regex
from moler.device import DeviceFactory
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console, log_warn_to_console
import os
import time
from taf.rfrl.utilities.transfer_files import download_files


@load_moler_configuration_from_tl()
def get_rus_snapshot(iteration):
    """
    Get snapshot on all Radio Units

    :param iteration: iteration number
    """
    operations = []
    ru_devs = [device for device in convert_to_robot_kw(get_devices_from_regex, pattern=r'GNB0_RU\d+$')]
    for ru_dev in list(ru_devs):
        device = convert_to_robot_kw(DeviceFactory.get_device, name=ru_dev, initial_state="FHNET")
        ru_ip = device.ru_ip_address
        packets = convert_to_robot_kw(device.get_cmd, cmd_name="ping",
                                      cmd_params={'destination': ru_ip, 'options': '-w 2'})()
        logs_name = "RU_logs_{}.zip".format(ru_ip.replace(".", "_"))
        if int(packets["packet_loss"]) != 0:
            convert_to_robot_kw(log_warn_to_console, msg="RU {} NOT AVAILABLE".format(ru_ip))
            ru_devs.remove(ru_dev)
            continue
        convert_to_robot_kw(device.goto_state, state="RU", rerun=3)
        convert_to_robot_kw(device.get_cmd, cmd_name="telnet",
                            cmd_params={"expected_prompt": r'AaShell>', "host": "0", "port": "15007",
                                        "allowed_newline_after_prompt": True}, check_state=False)()
        convert_to_robot_kw(device.get_cmd, cmd_name='run_script',
                            cmd_params={"script_command": "log -a -z {}".format(logs_name),
                                        "prompt": r'AaShell>'})(timeout=300)
        cmd = convert_to_robot_kw(device.get_cmd, cmd_name='run_script', cmd_params={"script_command": "quit"})
        cmd.start(timeout=90)
        operations.append(cmd)
    for operation in operations:
        operation.await_done(timeout=90)
    convert_to_robot_kw(log_info_to_console, msg="Getting RUs snapshot done", log_hierarchy=3)
    convert_to_robot_kw(collect_rus_snapshot, ru_devs=ru_devs, iteration=iteration)


def collect_rus_snapshot(ru_devs, iteration):
    """
    Download snapshot from all Radio Units

    :param ru_devs: Moler Radio devices, where snapshots are saved
    :param iteration: iteration number
    """
    device = convert_to_robot_kw(DeviceFactory.get_device, name='UnixLocal')
    local_time = time.localtime()
    logs_path = os.path.join("{}/ru_logs/iteration_{}".format(get_builtin_value("OUTPUTDIR"), iteration),
                             "RU_SNAPs_{}_{}_{}".format(local_time.tm_hour,
                                                        local_time.tm_min,
                                                        local_time.tm_sec))
    convert_to_robot_kw(device.get_cmd, cmd_name='mkdir', cmd_params={"path": "'{}'".format(logs_path),
                                                                      "options": "-p"})()
    for ru_dev in ru_devs:
        device = convert_to_robot_kw(DeviceFactory.get_device, name=ru_dev, initial_state="RU")
        ru_ip = device.ru_ip_address
        logs_name = "RU_logs_{}.zip".format(ru_ip.replace(".", "_"))
        find_results = convert_to_robot_kw(device.get_cmd, cmd_name='find',
                                           cmd_params={"paths": ["/"],
                                                       "operators": "-iname '{}' 2>/dev/null".format(logs_name)}
                                           )(timeout=120)
        for result in find_results["RESULT"]:
            if logs_name in result:
                ru_logs_path = result.split(logs_name)[0]
                break
        else:
            convert_to_robot_kw(log_info_to_console, msg="Cannot find logs {}".format(logs_name))
            continue
        convert_to_robot_kw(download_files, local_dir=logs_path, device_name=ru_dev, remote_file=logs_name,
                            remote_dir=ru_logs_path, from_state="RU", timeout=180)
