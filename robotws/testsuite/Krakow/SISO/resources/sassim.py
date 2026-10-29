import re
import os
import tarfile
import logging
from testsuite.Krakow.SISO.resources.certserver import CertServer, exec_cmd
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.utilities.test_config import get_log_path


class SASSim:

    def __init__(self,
                 sas_sim_config=None,
                 sas_sim_path='/home/ute/SASSim',
                 cert_server=CertServer(),
                 ):

        self.sas_sim_config = sas_sim_config
        self.sas_sim_path = sas_sim_path
        self.cert_server = cert_server
        self.sas_sim_tar_name = 'SASSim.tar'
        self.sas_sim_tar_file = '/'.join([self.sas_sim_path, self.sas_sim_tar_name])
        self.csr_file = 'bts_csr.pem'
        self.cert_file = 'bts_all_cert.pem'
        self.default_sas_sim_config = 'SAS_Sim.conf'

    def set_sas_sim_config(self, sas_sim_config):
        self.sas_sim_config = sas_sim_config

    def get_default_sas_sim_config(self):
        return self.default_sas_sim_config

    def get_config_name(self):
        config_name = re.search(r"([^\/]*\.conf)", self.sas_sim_config)
        return config_name.group(1)

    def create_sas_sim_dir(self):
        mkdir_cmd = 'mkdir -p {}'.format(self.sas_sim_path)
        exec_cmd(mkdir_cmd)

    def get_sas_sim_tar(self):
        self.cert_server.copy_sas_sim_tar_to_vm(self.sas_sim_path)

    def extract_sas_sim_tar(self):
        with tarfile.open(self.sas_sim_tar_file, 'r') as tar:
            tar.extractall(path=self.sas_sim_path)

    def get_csr_from_bts(self):
        gnb_cert = GnbDuOperations()
        csr_file_path = '/'.join([self.sas_sim_path, self.csr_file])
        gnb_cert.generate_csr(cert_file=csr_file_path)

    def copy_csr_to_sas_server(self):
        csr_file_path = '/'.join([self.sas_sim_path, self.csr_file])
        self.cert_server.copy_csr_to_cert_server(csr_file_path)

    def generate_certificates(self):
        self.cert_server.generate_all_certificate_file(csr_file=self.csr_file, output_cert=self.cert_file,
                                                       destination=self.sas_sim_path)

    def get_cert_files_for_sas_sim(self):
        self.cert_server.copy_cert_files_for_sas_sim(destination=self.sas_sim_path)

    def install_bts_certificates(self):
        gnb_cert = GnbDuOperations()
        cert_file_path = '/'.join([self.sas_sim_path, self.cert_file])
        gnb_cert.install_certificate(cert_file=cert_file_path, cert_type='CBRSVendorChain', cert_format='PEM')

    def copy_sas_sim_config(self):
        cp_cmd = 'cp {} {}'.format(self.sas_sim_config, self.sas_sim_path)
        exec_cmd(cp_cmd)

    def start_sas_sim_server(self):
        if self.sas_sim_config:
            self.copy_sas_sim_config()
            sas_sim_config_name = self.get_config_name()
        else:
            sas_sim_config_name = self.get_default_sas_sim_config()

        sas_sim_config = '/'.join([self.sas_sim_path, sas_sim_config_name])
        start_cmd = 'cd {}; sudo python3 SAS_Sim.py -c {} &'.format(self.sas_sim_path, sas_sim_config)
        logging.info("Execute:({})".format(start_cmd))
        os.system(start_cmd)

    def kill_sas_sim_server(self):
        stop_cmd = 'sudo {}/stop.sh'.format(self.sas_sim_path)
        exec_cmd(stop_cmd)

    def get_sas_sim_log(self):
        cp_cmd = 'cp {}/SAS_Sim.log {}'.format(self.sas_sim_path, get_log_path())
        exec_cmd(cp_cmd)

    def modify_port_number(self, new_port: int, config_file: str = None):
        """
        Modify the port_number in the .conf file.

        :param new_port: The new port number to set.
        :param config_file: Optional path to the config file.
                            If None, uses self.sas_sim_config or default config.
        """
        if config_file is None:
            if self.sas_sim_config:
                config_file = self.sas_sim_config
            else:
                config_file = os.path.join(self.sas_sim_path, self.default_sas_sim_config)

        if not os.path.isfile(config_file):
            raise FileNotFoundError(f"Config file not found: {config_file}")

        with open(config_file, "r") as f:
            lines = f.readlines()

        port_line_pattern = re.compile(r"^\s*port_number\s*=\s*\d+", re.IGNORECASE)
        updated = False
        for i, line in enumerate(lines):
            if port_line_pattern.match(line):
                lines[i] = f"port_number = {new_port}\n"
                break

        with open(config_file, "w") as f:
            f.writelines(lines)

    def reset_iptables(self):
        """
        Executes a series of iptables commands to display, set default policies,
        and flush rules.
        """
        commands = [
            "sudo iptables -P INPUT ACCEPT",
            "sudo iptables -F"
        ]

        for cmd in commands:
            logging.info(f"Executing: {cmd}")
            output = exec_cmd(cmd)
            if output:
                logging.info(output)

    def prepare_sas_sim(self, port_number=None, reset_iptables=False):
        self.create_sas_sim_dir()
        self.get_sas_sim_tar()
        self.extract_sas_sim_tar()
        self.get_csr_from_bts()
        self.copy_csr_to_sas_server()
        self.generate_certificates()
        self.get_cert_files_for_sas_sim()
        self.install_bts_certificates()
        if port_number is not None:
            self.modify_port_number(new_port=port_number)
        self.start_sas_sim_server()
        if reset_iptables:
            self.reset_iptables()

    def stop_sas_sim_server(self):
        self.kill_sas_sim_server()
        self.get_sas_sim_log()
