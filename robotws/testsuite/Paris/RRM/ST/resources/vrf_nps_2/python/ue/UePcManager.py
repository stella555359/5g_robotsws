import time
from moler.device import DeviceFactory
from taf.rfrl.utilities.robot.general import get_builtin_instance
from taf.rfrl.utilities.tl_config import tl, load_moler_configuration_from_tl
from moler.exceptions import CommandFailure
from ute_common_abstract_core.aliases_registry import aliases_registry


class UePcManager:
    def __init__(self):
        self.protocol_name = None
        self.ue_capability = None
        self.ue_alias = None
        self.port = None
        self.buff_size = None
        self.cmd_timeout = None
        self.ue_iperf_cmd = None
        self.ue_ip = None
        self.ue_sn = None
        self.ue_pc = None

    def attach_ue(self):
        taf_ue = get_builtin_instance("taf_ue")
        print(taf_ue)
        if self.ue_alias in list(aliases_registry().keys()):
            aliases_registry().release([self.ue_alias])
        try:
            taf_ue.require_ue(self.ue_alias, capabilities=self.ue_capability)
            taf_ue.attach_ue(self.ue_alias)
            taf_ue.log_ue_info(self.ue_alias)
        except Exception as e:
            raise Exception(f"could not establish connection to Ue {self.ue_alias}")

    def get_ue_info(self, Param='ALL'):
        assert Param in ['State', 'IMSI', 'IP', 'ALL'], "Param not in ['State', 'IMSI', 'IP']"
        ue = aliases_registry()[self.ue_alias]
        try:
            return ue.get_info(Param)
        except Exception as e:
            raise EnvironmentError(f"Fail UE with alias {self.ue_alias} is not accessible!")

    def get_uepc_alias(self):
        for i, ue in enumerate(tl.ues):
            if self.ue_capability in ue.capabilities:
                user = ue.ssh_connection_details.username
                for j, app_server in enumerate(ue.data_transfer):
                    if app_server.protocol_name and self.protocol_name in app_server.protocol_name:
                        return user, f"UE{i}_PC"
        raise EnvironmentError(f"Fail to get server for \"{self.protocol_name}\" service for ue capability "
                               f"\"{self.ue_capability}\", please check your init.py declaration")

    def _built_ue_iperf_command(self):
        ue_info = self.get_ue_info()
        self.ue_sn = ue_info['serial']
        self.ue_ip = ue_info['ip']
        iperf_cmd = f'adb -s {self.ue_sn} shell su 0 "/data/data/com.nokia.android.application/iperf ' \
                    f'-s -u -p {self.port} -i 1 -B {self.ue_ip} -w 20m 2>&1"'
        self.ue_iperf_cmd = self.ue_pc.get_cmd(cmd_name="run_script",
                                               cmd_params={"script_command": iperf_cmd})

    def start_iperf_client_command(self):
        self._built_ue_iperf_command()
        print(self.ue_iperf_cmd)
        self.ue_iperf_cmd.start(timeout=self.cmd_timeout)
        time.sleep(2)
        if self.ue_iperf_cmd.done():
            raise Exception(f"start cmd \"{self.ue_iperf_cmd} on {self.ue_pc}\" failed")

    def stop_iperf_client_command(self):
        if self.ue_iperf_cmd and not self.ue_iperf_cmd.done():
            try:
                self.ue_iperf_cmd.break_cmd()
                self.ue_iperf_cmd.await_done(timeout=10)
            except CommandFailure:
                print("CommandFailure during breaking iperf client command")

    def get_iperf_client_result(self):
        if self.ue_iperf_cmd.done():
            return self.ue_iperf_cmd.result()
        else:
            raise Exception(f"No result for \"{self.ue_iperf_cmd}\" on {self.ue_pc}\".")

    def wait_untill_iperf_client_done(self):
        while self.ue_iperf_cmd and not self.ue_iperf_cmd.done():
            time.sleep(1)
        self.ue_iperf_cmd.cancel()

    @load_moler_configuration_from_tl()
    def prepare_ue_pc(self, ue_capability, protocol_name, ue_alias, port=56757, buff_size=1350, cmd_timeout=180):
        self.ue_capability = ue_capability
        self.protocol_name = protocol_name
        self.ue_alias = ue_alias
        self.port = port
        self.buff_size = buff_size
        self.cmd_timeout = cmd_timeout
        self.ue_iperf_cmd = None
        self.validate_parameters()
        ue_pc_user, ue_pc_alias = self.get_uepc_alias()
        self.ue_pc = DeviceFactory.get_device(ue_pc_alias)

    def validate_parameters(self):
        assert self.ue_capability is not None, "ue_capability is not defined"
        assert self.protocol_name is not None, "protocol_name is not defined"
        assert self.ue_alias is not None, "ue_alias is not defined"
        assert self.port is not None, "port is not defined"
        assert self.buff_size is not None, "buff_size is not defined"

    def clean_up(self):
        self.stop_iperf_client_command()
        self.ue_pc = None
