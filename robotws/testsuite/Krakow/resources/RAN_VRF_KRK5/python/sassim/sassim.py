import logging
import os
import re
import time
from moler.device import DeviceFactory
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.sassim.certserver import CertServer
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.utilities.test_config import get_log_path, get_repository_path
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.transfer_files import upload_files_between_devices, download_files_between_devices


class SASSim:
    DEFAULT_SAS_SIM_PATH = '/home/ute/SASSim'
    DEFAULT_SAS_SIM_CONFIG = 'SAS_Sim.conf'
    SAS_SIM_TAR_NAME = 'SASSim.tar'
    SAS_SIM_LOG = '/home/ute/SAS_Sim.log'
    CSR_FILE = 'bts_csr.pem'
    CERT_FILE = 'bts_all_cert.pem'

    def __init__(self, bts_id=0, sas_sim_config=None, sas_sim_path=None, cert_server=None):
        load_moler_configuration_from_tl()
        self.gnb_du = GnbDuOperations()
        self.gnb_du.connect(bts_id)
        self.bts_vm = self._get_bts_vm(bts_id)
        self.sas_sim_config = sas_sim_config
        self.sas_sim_path = sas_sim_path or self.DEFAULT_SAS_SIM_PATH
        self.cert_server = cert_server or CertServer()
        self.sas_sim_tar_file = os.path.join(self.sas_sim_path, self.SAS_SIM_TAR_NAME)

    @staticmethod
    @load_moler_configuration_from_tl()
    def _get_bts_vm(bts_id=0):
        """Retrieve the BTS VM device."""
        return DeviceFactory.get_device(GnbDuOperations().ws_du_alias.format(bts_id, 0))

    def _get_config_name(self):
        """Extract the configuration file name from the path."""
        match = re.search(r"([^\/]*\.conf)", self.sas_sim_config)
        return match.group(1) if match else None

    def set_sas_sim_config(self, sas_sim_config):
        """Set the SASSim configuration file."""
        logging.info(f'Setting SAS Sim config to {sas_sim_config}')
        self.sas_sim_config = sas_sim_config

    def create_sas_sim_directory(self):
        """Create a directory if it does not exist."""
        self.bts_vm.get_cmd(
            cmd_name="mkdir",
            cmd_params={
                "path": self.sas_sim_path,
                "options": "-p"
            }
        )()

    def get_sas_sim_tar(self):
        """Retrieve the SASSim.tar file to BTS VM."""
        cert_server_path = self.cert_server.get_remote_host()
        self.bts_vm.get_cmd(
            cmd_name="scp",
            cmd_params={
                "source": f"{cert_server_path}{self.cert_server.sas_sim_file_path}",
                "dest": self.sas_sim_path,
                "password": self.cert_server.password,
            },
        )()

    def extract_sas_sim_tar(self):
        """Extract the SASSim.tar file."""
        self.bts_vm.get_cmd(
            cmd_name="tar",
            cmd_params={
                "options": "-xvf",
                "file": f"{self.sas_sim_tar_file} -C {self.sas_sim_path}",
            },
        )()

    def get_csr_from_bts(self):
        """Generate BTS CSR file."""
        csr_file_path = os.path.join(self.sas_sim_path, self.CSR_FILE)
        self.gnb_du.generate_csr(cert_file=csr_file_path)

    def copy_csr_to_sas_server(self):
        """Copy the BTS CSR file to the certificate server."""
        csr_file_path = os.path.join(self.sas_sim_path, self.CSR_FILE)
        self.cert_server.copy_csr_to_cert_server(csr_file_path)

    def generate_certificates(self):
        """Generate BTS certificates using the BTS CSR file."""
        self.cert_server.generate_all_certificate_file(
            csr_file=self.CSR_FILE,
            output_cert=self.CERT_FILE,
            destination=self.sas_sim_path,
        )

    def get_cert_files_for_sas_sim(self):
        """Retrieve the certificate files for SASSim."""
        self.cert_server.copy_cert_files_for_sas_sim(
            bts_vm=self.bts_vm,
            destination=self.sas_sim_path
        )

    def install_bts_certificates(self):
        """Install the BTS CBRS certificates."""
        cert_file_path = os.path.join(self.sas_sim_path, self.CERT_FILE)
        self.gnb_du.install_certificate(
            cert_file=cert_file_path,
            cert_type="CBRSVendorChain",
            cert_format="PEM"
        )

    def copy_sas_sim_config(self):
        """Copy the SASSim configuration file to the BTS VM device."""
        upload_files_between_devices(
            local_dir=get_repository_path(),
            local_file=self.sas_sim_config,
            remote_device_name=self.bts_vm.public_name,
            remote_dir=self.sas_sim_path,
            timeout=60,
        )

    def start_sas_sim(self):
        """Start the SASSim server."""
        logging.info(f"Starting SASSim with config: {self.sas_sim_config}")
        sas_sim_config_name = self._get_config_name() or self.DEFAULT_SAS_SIM_CONFIG
        sas_sim_script = os.path.join(self.sas_sim_path, "SAS_Sim.py")
        sas_sim_config = os.path.join(self.sas_sim_path, sas_sim_config_name)
        start_sasim = self.bts_vm.get_cmd(
            cmd_name="run_script",
            cmd_params={
                "script_command": f"nohup python3 {sas_sim_script} -c {sas_sim_config} &"
            },
        )
        self.bts_vm.get_cmd(
            cmd_name="sudo",
            cmd_params={
                "cmd_object": start_sasim
            }
        )()

    def check_sas_sim_running(self):
        """Check if the SASSim is running."""
        ps_cmd = self.bts_vm.get_cmd(cmd_name="ps", cmd_params={"options": "-ef"})
        sas_sim_script = os.path.join(self.sas_sim_path, "SAS_Sim.py")
        for process in ps_cmd():
            if "CMD" in process and sas_sim_script in process["CMD"]:
                return True
            elif "'nohup.out'" in process and sas_sim_script in process["'nohup.out'"]:
                return True
        return False

    def kill_sas_sim(self):
        """Stop the SASSim server."""
        stop_sasim = self.bts_vm.get_cmd(
            cmd_name="run_script",
            cmd_params={"script_command": f"{self.sas_sim_path}/stop.sh"},
        )
        self.bts_vm.get_cmd(
            cmd_name="sudo",
            cmd_params={
                "cmd_object": stop_sasim
            }
        )()

    def get_sas_sim_log(self):
        """Retrieve the SASSim log file."""
        download_files_between_devices(
            local_dir=get_log_path(),
            remote_file=self.SAS_SIM_LOG,
            remote_device_name=self.bts_vm.public_name,
            remote_dir=self.sas_sim_path,
            timeout=60,
        )

    def prepare_and_start_sas_sim(self):
        """Prepare and start the SASSim."""
        self.create_sas_sim_directory()
        self.get_sas_sim_tar()
        self.extract_sas_sim_tar()
        if self.check_sas_sim_running():
            self.kill_sas_sim()
        self.get_csr_from_bts()
        self.copy_csr_to_sas_server()
        self.generate_certificates()
        self.get_cert_files_for_sas_sim()
        self.install_bts_certificates()
        if self.sas_sim_config:
            self.copy_sas_sim_config()
        self.start_sas_sim()
        time.sleep(5)
        if not self.check_sas_sim_running():
            raise Exception("SASSim failed to start.")

    def stop_sas_sim(self):
        """Stop the SASSim server and retrieve the log file."""
        self.kill_sas_sim()
        self.get_sas_sim_log()
