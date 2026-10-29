from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections import device_aliases as connection_names
from taf.rfrl.bts.devices.exceptions import FileNotFound
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest


@load_moler_configuration_from_tl()
def verify_if_coam_log_file_exists(bts_id=0, du_id=0):
    gnb = DeviceFactory.get_device(name=connection_names.ssh_bts_du.format('GNB', bts_id, du_id))
    gnb.goto_state("FCT")
    coam_log_xz = "startup_BTSOM.log.xz"
    coam_log = "startup_BTSOM.log"

    cd_cmd = gnb.get_cmd(cmd_name="cd",
                         cmd_params={'path': '/ffs/run/logs/fct-4a_aasyslog'})
    cd_cmd()

    ls_cmd = gnb.get_cmd(cmd_name="ls",
                         cmd_params={'options': '-l', 'path': "startup_*"})
    ls_output = ls_cmd()

    filenames = ls_output["files"].keys()

    if coam_log_xz in filenames:
        unxz_cmd = gnb.get_cmd(cmd_name="unxz",
                               cmd_params={'xz_file': "{}".format(coam_log_xz)})
        unxz_cmd()

    elif coam_log in filenames:
        MolerTest.info("File exists")
    else:
        cd_tmp_cmd = gnb.get_cmd(cmd_name="cd",
                                 cmd_params={'path': '/tmp'})
        cd_tmp_cmd()

        ls_tmp_cmd = gnb.get_cmd(cmd_name="ls", cmd_params={'options': '-l', 'path': "startup_*"})
        ls_output = ls_tmp_cmd()

        tmp_filenames = ls_output["files"].keys()
        if coam_log not in tmp_filenames:
            raise FileNotFound("{} not found in the /tmp directory".format(coam_log))


@load_moler_configuration_from_tl()
def _get_led_state(grep_phrase, bts_id=0, du_id=0):
    gnb = DeviceFactory.get_device(name=connection_names.ssh_bts_du.format('GNB', bts_id, du_id))
    gnb.goto_state("FCT")
    coam_log = "startup_BTSOM.log"

    grep_cmd = gnb.get_cmd(cmd_name="grep",
                           cmd_params={
                               'options': "-i -E {} {} | grep -v grep |  tail -1".format(grep_phrase, coam_log)
                           })

    grepped_log = grep_cmd()

    led_status = grepped_log['LINES'][0][-3]
    return led_status


def get_asik_led_state(bts_id=0, du_id=0):
    return _get_led_state(grep_phrase='"Led state of.*SMOD.*LED_L-1.*set to"', bts_id=bts_id, du_id=du_id)


def get_abil_led_state(bts_id=0, du_id=0):
    return _get_led_state(grep_phrase='"Led state of.*BBMOD.*LED_L-3.*set to"', bts_id=bts_id, du_id=du_id)
