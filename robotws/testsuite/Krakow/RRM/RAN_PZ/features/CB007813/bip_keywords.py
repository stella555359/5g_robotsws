from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.robot.general import get_builtin_value
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def join_pcap_files():
    device = DeviceFactory.get_device(name="GNB0_DU0", initial_state="PROXY_PC")
    device.get_cmd(
        cmd_name="run_script",
        cmd_params={
            "script_command": "cd {}/BipCollectorAdmin_GNB0_DU0; "
            "mergecap -a *mirroring_L2L1*.pcap -w ../L2L1_bip.pcap".format(
                get_builtin_value("OUTPUT_DIR")
            )
        },
    )(timeout=90)
    device.get_cmd(
        cmd_name="run_script",
        cmd_params={
            "script_command": "cd {}/BipCollectorAdmin_GNB0_DU0; rm *mirroring_L2L1*.pcap".format(
                get_builtin_value("OUTPUT_DIR")
            )
        },
    )()
