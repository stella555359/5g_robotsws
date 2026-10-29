import subprocess
from time import sleep

import psutil
from six import ensure_str

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.connections import \
    ConnectionManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.decorators import \
    wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import \
    TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import \
    logger

_cm = ConnectionManager()


def check_vm_disk_space():
    free_space = round(float(psutil.disk_usage("/home/ute").free) / (1024**3), 2)
    if free_space < 1:
        raise SystemError("Not enough free space on VM. Available space : {} GB.".format(free_space))


def kill_uepc_python_processes():
    with _cm.uepc_connection(autoconnect=False) as connection:
        python_processes = connection.execute_command("ps | grep python").split("\n")
        python_pids = [proc.split("\n")[0] for proc in python_processes]
        for pid in python_pids:
            if pid:
                connection.send_command("kill {}".format(pid))


def reboot_ue(timeout=60):
    @wait_until_function_succeeds(timeout=timeout, interval=10, console=False)
    def __get_adb_devices(host_connection):
        output = host_connection.execute_command("adb devices")
        assert len([line for line in ensure_str(output).splitlines() if line]) >= 2

    with _cm.uepc_connection(autoconnect=False) as connection:
        connection.send_command("adb reboot")
        sleep(60)
        __get_adb_devices(host_connection=connection)


def reboot_uepc(timeout=120):
    @wait_until_function_succeeds(timeout=timeout, interval=10, console=False)
    def __ping_host(hostname):
        subprocess.check_call(["ping", "-c", "1", hostname], stdout=subprocess.DEVNULL)

    with _cm.uepc_connection(autoconnect=False) as connection:
        connection.send_command("shutdown -t 0 -r -f")
    sleep(60)
    __ping_host(TestlineConfiguration().get_uepc_connection_details()["hostname"])
    sleep(60)


def get_ue_battery_state(sn=None):
    with _cm.uepc_connection(autoconnect=False) as connection:
        output = ensure_str(
            connection.execute_command("adb {}shell dumpsys battery".format("" if sn is None else "-s {} ".format(sn)))
        )
        logger.info("Output of 'adb shell dumpsys battery':", also_to_console=False)
        logger.info(output, also_to_console=False)
    lines = output.splitlines()
    assert len(lines) > 3, "Could not extract battery info. Wrong output format of 'adb shell dumpsys battery'"
    battery_info = [line.split(":") for line in lines if ":" in line]
    battery_info_dict = dict([(key.strip().lower(), value.strip()) for key, value in battery_info])
    return battery_info_dict


def print_ue_battery_info_banner():
    current_ue_state = get_ue_battery_state()
    info = """
    ----- UE battery state -----
    |   level: {} %
    |   temperature: {} deg.
    ----------------------------
    """.format(
        current_ue_state.get("level"), str(float(current_ue_state.get("temperature", float("nan"))) / 10)
    )
    for line in info.splitlines():
        logger.info(line, also_to_console=True)
