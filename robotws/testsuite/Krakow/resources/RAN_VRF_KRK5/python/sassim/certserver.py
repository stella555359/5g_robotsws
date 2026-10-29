import logging
from moler.device import DeviceFactory
from taf.transport.ssh.connection import SSHConnection


class CertServer:
    DEFAULT_HOST = 'cmp-server.p04.ska-lab.nsn-rdnet.net'
    DEFAULT_LOGIN = 'ute'
    DEFAULT_PASSWORD = 'uteUTE!'
    DEFAULT_SAS_SIM_FILE_PATH = '/home/ute/SASSim/SASSim.tar'
    DEFAULT_SSL_CA_DIR = '/home/ute/SSLCA'
    END_USER_DIR_NAME = 'enduser-certs'
    ROOT_CA_FILE = 'rootca.pem'
    ROOT_KEY_FILE = 'rootca.key'
    INTERMEDIATE_CA_FILE = 'intermediate1.pem'
    INTERMEDIATE_KEY_FILE = 'intermediate1.key'
    EE_CA_FILE = 'ee.pem'

    def __init__(self,
                 host=DEFAULT_HOST,
                 login=DEFAULT_LOGIN,
                 password=DEFAULT_PASSWORD,
                 sas_sim_file_path=DEFAULT_SAS_SIM_FILE_PATH,
                 ssl_ca_dir=DEFAULT_SSL_CA_DIR,
                 end_user_dir=END_USER_DIR_NAME,
                 root_ca=ROOT_CA_FILE,
                 root_key=ROOT_KEY_FILE,
                 intermediate_ca=INTERMEDIATE_CA_FILE,
                 intermediate_key=INTERMEDIATE_KEY_FILE):
        self.host = host
        self.login = login
        self.password = password
        self.sas_sim_file_path = sas_sim_file_path
        self.ssl_ca_dir = ssl_ca_dir
        self.ssl_ca_root_dir = f"{self.ssl_ca_dir}/root"
        self.ssl_ca_intermediate1_dir = f"{self.ssl_ca_dir}/intermediate1"
        self.end_user_dir = f"{self.ssl_ca_intermediate1_dir}/{end_user_dir}"
        self.root_ca = f"{self.ssl_ca_root_dir}/{root_ca}"
        self.root_key = f"{self.ssl_ca_root_dir}/{root_key}"
        self.intermediate_ca = f"{self.ssl_ca_intermediate1_dir}/{intermediate_ca}"
        self.intermediate_key = f"{self.ssl_ca_intermediate1_dir}/{intermediate_key}"
        self.ee_ca = f"{self.end_user_dir}/{self.EE_CA_FILE}"

    def get_remote_host(self):
        """
        Get the remote host string for SCP commands.

        Returns:
            str: The remote host string in the format `username@hostname:`.
        """
        return f"{self.login}@{self.host}:"

    def copy_csr_to_cert_server(self, csr_file):
        """
        Copy the CSR (Certificate Signing Request) file to the certificate server.

        Args:
            csr_file (str): The path to the CSR file on the local machine.
        """
        local_pc = DeviceFactory.get_device(name='UnixLocal')
        local_pc.get_cmd(
            cmd_name="scp",
            cmd_params={
                "source": csr_file,
                "dest": f"{self.get_remote_host()}{self.end_user_dir}",
                "password": self.password,
            },
        )()

    def cmd_to_combine_all_needed_certificates(self, all_cert_file):
        """
        Generate the command to combine all required certificates into a single file.

        Args:
            all_cert_file (str): The path to the output file where the combined certificates will be saved.

        Returns:
            str: The command to combine the certificates.
        """
        return f"cat {self.root_ca} {self.intermediate_ca} {self.ee_ca} > {all_cert_file}"

    def copy_cert_files_for_sas_sim(self, bts_vm, destination):
        """
        Copy the required certificate files for SASSim to the specified destination.

        Args:
            bts_vm (device): The BTS VM device instance.
            destination (str): The path where the certificate files will be copied.
        """
        files_in = [self.root_ca, self.intermediate_ca, self.intermediate_key]
        files_out = [
            f"{destination}/ca.cert",
            f"{destination}/nokia04.cert",
            f"{destination}/nokia04.key"
        ]
        for src, dest in zip(files_in, files_out):
            bts_vm.get_cmd(
                cmd_name="scp",
                cmd_params={
                    "source": f"{self.get_remote_host()}{src}",
                    "dest": dest,
                    "password": self.password,
                },
            )()

    def generate_all_certificate_file(self, csr_file, output_cert, destination, local_vm=None):
        """
        Generate all certificate file.

        Args:
            csr_file (str): The name of the CSR file to use for certificate generation.
            output_cert (str): The name of the output certificate file.
            destination (str): The path where the generated certificate files will be copied.
            local_vm (device): The local VM device instance. If None, a UnixLocal device will be used.

        Raises:
            Exception: If the certificate generation or combination fails.
        """
        conf = f"{self.ssl_ca_intermediate1_dir}/ca.conf"
        in_file = f"{self.end_user_dir}/{csr_file}"
        cmd = f"openssl ca -batch -config {conf} -notext -in {in_file} -out {self.ee_ca}"

        ssh_conn = None
        try:
            ssh_conn = SSHConnection()
            ssh_conn.configure(
                hostname=self.host,
                username=self.login,
                password=self.password,
            )
            ssh_conn.connect()
            ssh_conn.execute(cmd)
            logging.info("Certificate generation command executed.")

            all_cert_file = f"{self.end_user_dir}/{output_cert}"
            combine_cmd = self.cmd_to_combine_all_needed_certificates(all_cert_file)
            ssh_conn.execute(combine_cmd)
            logging.info("Certificates combined successfully.")
        except Exception as e:
            logging.error(f"Failed to generate certificates: {e}")
            raise
        finally:
            if ssh_conn:
                ssh_conn.disconnect()

        local_vm = local_vm or DeviceFactory.get_device(name='UnixLocal')
        local_vm.get_cmd(
            cmd_name="scp",
            cmd_params={
                "source": f"{self.get_remote_host()}{all_cert_file}",
                "dest": destination,
                "password": self.password,
            },
        )()
