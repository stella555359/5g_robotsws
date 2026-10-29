import time
from taf.transport.ssh import ssh
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import wait_until_function_succeeds, logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources import connections

_ssh = ssh()


@logged_keyword
def reboot_ues():
    for ue in tl.ues:
        serial = ue.serial_number
        blog("Rebooting {}... ".format(serial))
        ue_pc = _ssh.connect_to(hostname=ue.ssh_connection_details.addr,
                                username=ue.ssh_connection_details.username,
                                password=ue.ssh_connection_details.password,
                                alias='reboot_connection')
        time.sleep(3)
        blog(_ssh.execute(command='adb devices', connection=ue_pc))
        time.sleep(3)
        blog(_ssh.execute(command='adb -s {} reboot'.format(serial), connection=ue_pc))
        time.sleep(3)
        __wait_for_ue_uprise(serial, ue_pc)
        blog("... done")


@wait_until_function_succeeds(retry_time_in_seconds=400, retry_interval_in_seconds=20)
def __wait_for_ue_uprise(serial, connection):
    assert serial in _ssh.execute(command='adb devices', connection=connection), "Device not detected"


@logged_keyword
def remove_pyro_server_dir(pyro_dir='/cygdrive/c/pyro_server'):
    blog("Connecting to UE PC...", level='INFO')
    connection_alias = connections.connect_to_uepc()
    try:
        blog("Killing adb.exe service...", level='INFO')
        _ssh.execute(command='taskkill /F /IM adb.exe', connection=connection_alias)
        blog("Removing pyro dir...", level='INFO')
        _ssh.execute(command='rm -rf "{}"'.format(pyro_dir), connection=connection_alias)
        time.sleep(10)
    except BaseException:
        blog("Unable to kill adb.exe or remove pyro dir!", level='WARN')
    blog("Waiting until adb will be reloaded...", level='INFO')
    time.sleep(60)
