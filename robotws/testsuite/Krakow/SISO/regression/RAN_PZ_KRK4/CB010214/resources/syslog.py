from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections import device_aliases
from robot.libraries.BuiltIn import BuiltIn
import os

builtin = BuiltIn()
tl = builtin.get_variable_value('${tl}')


@load_moler_configuration_from_tl()
def unpack_syslog_file(syslog_dir_path, gnb_id=0, du_id=0):
    syslog_tgz_name = "syslog_files.tgz"
    syslog_tgz_path = "{}{}".format(syslog_dir_path, syslog_tgz_name)
    vm = DeviceFactory.get_device(device_aliases.ssh_bts_du.format("GNB", gnb_id, du_id), initial_state="UNIX_LOCAL")
    vm.get_cmd(cmd_name="tar", cmd_params={"file": syslog_tgz_path,
                                           "options": "-C {} -xvzf".format(syslog_dir_path)})()


def verify_nms_msg_in_syslog(msg, gnb_id=0, du_id=0):
    rest_alias = device_aliases.rest_bts_du.format("GNB", gnb_id, du_id)
    syslog_dir = "btslog_{}_{}_{}".format(rest_alias, tl.gnbs[gnb_id].instance_id, tl.gnbs[gnb_id].global_bts_id)
    syslog_dir_path = "{}/{}/".format(builtin.get_variable_value("${LOG_PATH}"), syslog_dir)
    unpack_syslog_file(syslog_dir_path)
    return _verify_msg_in_syslog(msg, syslog_dir_path)


def _verify_msg_in_syslog(msg, syslog_dir_path, gnb_id=0, du_id=0):
    vm = DeviceFactory.get_device(device_aliases.ssh_bts_du.format("GNB", gnb_id, du_id),
                                  initial_state="UNIX_LOCAL")
    for filename in os.listdir(syslog_dir_path):
        if "SYSLOG" in filename:
            grep_cmd = vm.get_cmd(cmd_name="grep", cmd_params={"options": "-i -e {} {}/{}"
                                  .format(msg, syslog_dir_path, filename)})
            syslog_lines = grep_cmd()["LINES"]
            if syslog_lines:
                return syslog_lines
    raise SyslogException(f"{msg} not in syslog.")


class SyslogException(Exception):
    pass
