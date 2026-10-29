from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections import device_aliases as connection_names
from moler.device import DeviceFactory
from robot.libraries.BuiltIn import BuiltIn
import time

tl = BuiltIn().get_variable_value('${tl}')


@load_moler_configuration_from_tl()
def allocate_all_memory(bts_id=0, du_id=0):
    allocate_dir = "/ram/temp/"
    du = DeviceFactory.get_device(connection_names.ssh_bts_du.format("GNB", bts_id, du_id))
    du.get_cmd(cmd_name="mkdir", cmd_params={"path": allocate_dir, "options": "-p"})()
    df_cmd = du.get_cmd(cmd_name="df")
    avail = df_cmd()["by_MOUNTPOINT"]["/tmp"]["Avail"]
    while avail != "0":
        du.get_cmd(cmd_name="run_script", cmd_params={"script_command": 'fallocate -l {} {}{}'.format(
            int(avail) * pow(10, 6),
            allocate_dir,
            time.strftime("%Y%m%d-%H%M%S")
        )})()
        df_cmd = du.get_cmd(cmd_name="df")
        avail = df_cmd()["by_MOUNTPOINT"]["/tmp"]["Avail"]
