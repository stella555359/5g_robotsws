import os
import time
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.tl_config import tl
from taf.rfrl.utilities.transfer_files import upload_files
from robot.api import logger
from moler.exceptions import CommandFailure


class IperfSvrManager:
    def __init__(self):
        pass

    @load_moler_configuration_from_tl()
    def prepart_iperf_server(self, ue_capability, protocol_name, local_script, force=False):
        self.ue_capability = ue_capability
        self.protocol_name = protocol_name
        self.local_script = local_script
        self.force = force
        self.app_server = None
        self.script_path = None
        self.iperf_cmd = None
        self.server_iperf_id = None
        assert self.ue_capability is not None, "ue_capability is not defined"
        assert self.protocol_name is not None, "protocol_name is not defined"
        assert self.local_script is not None, "local_script is not defined"

        app_server_user, app_server_alias = self.get_app_server_alias()
        self.app_server = DeviceFactory.get_device(app_server_alias)
        script_name = os.path.basename(self.local_script)
        self.dest_dir = os.path.join('/home', app_server_user, 'burst_script')
        self.run_mkdir()
        self.script_path = os.path.join(self.dest_dir, script_name)
        self.run_upload_file(app_server_alias, self.local_script, self.dest_dir)
        self.run_chmod(self.script_path, "775")

    def get_app_server_alias(self):
        for i, ue in enumerate(tl.ues):
            if self.ue_capability in ue.capabilities:
                for j, app_server in enumerate(ue.data_transfer):
                    if app_server.protocol_name and self.protocol_name in app_server.protocol_name:
                        return app_server.app_server.user, f"APP_SERVER{i}_{j}"
        raise EnvironmentError(f"Fail to get server for \"{self.protocol_name}\" service for ue capability "
                               f"\"{self.ue_capability}\", please check your init.py declaration")

    def remove_dir(self, path):
        cmd_rm = self.app_server.get_cmd(
            cmd_name="rm",
            cmd_params={f"options": '-rf', "file": f"{path}"}
        )
        cmd_rm()

    def run_mkdir(self):
        try:
            cmd_mkdir = self.app_server.get_cmd(
                cmd_name="run_script",
                cmd_params={"script_command": f'[ ! -d "{self.dest_dir}" ] && mkdir -p "{self.dest_dir}"'}
            )
            cmd_mkdir()
            path = os.path.join(self.dest_dir, '*')
            self.remove_dir(path)
        except CommandFailure as ex:
            logger.warn(f"Error occurred : {ex}")

    def run_upload_file(self, device_name, source_file_path, dest_dir):
        filename = os.path.basename(source_file_path)
        local_dir = os.path.dirname(source_file_path)
        logger.info(f"local_dir {local_dir} and filename {filename}")
        try:
            upload_files(
                local_dir=f"{local_dir}",
                local_file=filename,
                device_name=device_name,
                remote_dir=dest_dir,
                timeout=20,
                remove_source_file=False
            )
        except CommandFailure as ex:
            logger.warn(f"Error occurred : {ex}")

    def run_chmod(self, filename, permission):
        cmd_chmod = self.app_server.get_cmd(
            cmd_name="chmod",
            cmd_params={
                "options": '',
                "permission": permission,
                "filename": filename,
            }
        )
        cmd_chmod()

    def build_iperf_server_command(self, ue_ip, port=56757, buff_size=1350, cmd_timeout=60):
        self.ue_ip = ue_ip
        self.port = port
        self.buff_size = buff_size
        self.cmd_timeout = cmd_timeout
        assert self.ue_ip is not None, "ue_ip is not defined"
        assert self.port is not None, "port is not defined"
        assert self.buff_size is not None, "buff_size is not defined"
        iperf_output = f"/tmp/iperf_server_{self.ue_ip}_{self.port}.log"
        self.iperf_cmd = self.app_server.get_cmd(
            cmd_name="run_script",
            cmd_params={
                "script_command": f"sh {self.script_path} {self.ue_ip} {self.port} {self.buff_size} > {iperf_output}"
            }
        )

    def start_iperf_server_command(self):
        self.iperf_cmd.start(timeout=self.cmd_timeout)
        time.sleep(2)
        if self.iperf_cmd.done():
            raise Exception(f"start cmd \"{self.iperf_cmd} {self.app_server}\" failed")
        # self.server_iperf_id = self._get_running_process(self.script_path)
        # logger.debug(f"running process id: {self.server_iperf_id}")

    def stop_iperf_server_command(self):
        # self.kill_process(self.server_iperf_id)
        if self.iperf_cmd and not self.iperf_cmd.done():
            try:
                self.iperf_cmd.break_cmd()
                self.iperf_cmd.await_done(timeout=10)
            except CommandFailure:
                print("CommandFailure during breaking iperf client command")

    def wait_untill_iperf_server_is_done(self):
        while not self.iperf_cmd.done():
            time.sleep(1)
        self.iperf_cmd.cancel()

    def _get_running_process(self, script):
        cmd_ps = self.app_server.get_cmd(cmd_name="ps", cmd_params={"options": '-ef'})
        processes = cmd_ps()
        logger.info(f"running process {processes}")
        script_process = [str(process['PID']) for process in processes if script in process['CMD']]
        logger.debug("Running process for script {}: {}".format(script, script_process))
        return script_process

    def kill_process(self, process_id):
        if process_id:
            kill = self.app_server.get_cmd(cmd_name='kill', cmd_params={'options': '-9', 'pid': " ".join(process_id)})
            kill()

    def clean_up(self):
        self.remove_dir(self.dest_dir)
        self.stop_iperf_server_command()
        self.app_server = None
        self.app_server = None
        self.script_path = None
        self.iperf_cmd = None
        self.server_iperf_id = None
        self.ue_ip = None
        self.port = None
        self.buff_size = None
        self.cmd_timeout = None
        self.ue_capability = None
        self.protocol_name = None
        self.local_script = None
        self.force = False
        self.dest_dir = None
