from moler.device import DeviceFactory
from taf.ul.moler.converter import add_unix_remote_device_to_already_loaded_configuration
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


rfc_device_name = 'RFC'


@load_moler_configuration_from_tl()
def connect_to_rfc_via_ssh(rfc_ip, rfc_login, rfc_password, prompt=r'\~\s+\$\s+'):
    add_unix_remote_device_to_already_loaded_configuration(device_name=rfc_device_name,
                                                           host=rfc_ip,
                                                           login=rfc_login,
                                                           password=rfc_password,
                                                           prompt=prompt)
    rfc = DeviceFactory.get_device(name=rfc_device_name)
    return rfc


def raise_rfc_dl_input_power_low_alarm_01():
    _run_rcf_command(command='AutoTest ForceAlarm 350')


def clear_rfc_dl_input_power_low_alarm_01():
    _run_rcf_command(command='AutoTest ForceNormal 350')


def raise_rfc_dl_input_power_overload_alarm_01():
    _run_rcf_command(command='AutoTest ForceAlarm 356')


def clear_rfc_dl_input_power_overload_alarm_01():
    _run_rcf_command(command='AutoTest ForceNormal 356')


def raise_rfc_over_temperature_alarm():
    _run_rcf_command(command='AutoTest ForceAlarm 3a1')


def clear_rfc_over_temperature_alarm():
    _run_rcf_command(command='AutoTest ForceNormal 3a1')


def _run_rcf_command(command):
    rfc = DeviceFactory.get_device(name=rfc_device_name)
    cmd = rfc.get_cmd(cmd_name='run_script', cmd_params={'script_command': command})
    cmd()
