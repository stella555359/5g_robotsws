import re

from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
lsu_vm_address = tl.ues[0].airmosaic_ssh_connection_details.addr
lsu_vm_username = tl.ues[0].airmosaic_ssh_connection_details.username
lsu_vm_password = tl.ues[0].airmosaic_ssh_connection_details.password
lsu_address = tl.ues[0].lsu_uu_ssh_connection_details.addr
lsu_username = tl.ues[0].lsu_uu_ssh_connection_details.username
lsu_password = tl.ues[0].lsu_uu_ssh_connection_details.password


def ssh_lsu(gnb_device):
    gnb_device.get_cmd(cmd_name="ssh", cmd_params={'login': lsu_vm_username, 'password': lsu_vm_password,
                                                   'host': lsu_vm_address, 'expected_prompt': r'.*ute@.*$.*'})()
    gnb_device.get_cmd(cmd_name="ssh", cmd_params={'login': lsu_username, 'password': lsu_password,
                                                   'host': lsu_address, 'expected_prompt': r'.*{}:.*$.*'
                       .format(lsu_username)})()


def exit_lsu(gnb_device):
    gnb_device.get_cmd(cmd_name="exit", cmd_params={'expected_prompt': r'.*ute@.*$.*'})()
    gnb_device.get_cmd(cmd_name="exit", cmd_params={'expected_prompt': r'moler_bash#'})()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def get_cell_id(cmd):
    """
    Get 5g cell id.

    :return: Cell id
    """
    gnb_device = DeviceFactory.get_device(name='GNB0_DU0', initial_state="UNIX_LOCAL")
    ssh_lsu(gnb_device)
    trcinfo_cmd = gnb_device.get_cmd(cmd_name="cat", cmd_params={'path': cmd, 'prompt': r'.*{}:.*$.*'
                                     .format(lsu_username)})
    trcinfo_cmd.command_string = trcinfo_cmd.command_string[4:]
    trcinfo_cmd.start()
    MolerTest.sleep(5)
    trcinfo_cmd.break_cmd()
    trcinfo = trcinfo_cmd.await_done()
    exit_lsu(gnb_device)
    re_cell_id = r'.*(CELL_ID|lteCellId)=(?P<VALUE>\d+).*'
    for line in trcinfo['LINES']:
        msg = re.search(re_cell_id, line)
        if msg:
            return msg.group('VALUE')
    MolerTest.error("Missing cell ID in trcinfo", dump=trcinfo['LINES'])


def get_4g_cell_id_v2():
    return get_cell_id("trcinfo -p0-11 | grep 'DN_ADJ_FREQ_OFF lteCellId='")


def get_5g_cell_id_v2():
    return get_cell_id("trcinfo -p0-3 | grep -i cell_id")
