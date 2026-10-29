import logging
import shlex
import subprocess
from taf.transport.ssh.connection import SSHConnection


class CertServer:
    def __init__(self,
                 host='cmp-server.p04.ska-lab.nsn-rdnet.net',
                 login='ute',
                 password='uteUTE!',
                 sas_sim_file_path='/home/ute/SASSim/SASSim.tar',
                 ssl_ca_dir='/home/ute/SSLCA',
                 end_user_dir='enduser-certs',
                 root_ca='rootca.pem',
                 root_key='rootca.key',
                 intermediate_ca='intermediate1.pem',
                 intermediate_key='intermediate1.key',
                 ):

        self.host = host
        self.login = login
        self.password = password
        self.sas_sim_file_path = sas_sim_file_path
        self.ssl_ca_dir = ssl_ca_dir
        self.ssl_ca_root_dir = "/".join([self.ssl_ca_dir, 'root'])
        self.ssl_ca_intermediate1_dir = "/".join([self.ssl_ca_dir, 'intermediate1'])
        self.end_user_dir = "/".join([self.ssl_ca_intermediate1_dir, end_user_dir])
        self.root_ca = "/".join([self.ssl_ca_root_dir, root_ca])
        self.root_key = "/".join([self.ssl_ca_root_dir, root_key])
        self.intermediate_ca = "/".join([self.ssl_ca_intermediate1_dir, intermediate_ca])
        self.intermediate_key = "/".join([self.ssl_ca_intermediate1_dir, intermediate_key])
        self.ee_ca = "/".join([self.end_user_dir, 'ee.pem'])

    def get_remote_host(self):
        return '{}@{}:'.format(self.login, self.host)

    def copy_from_cert_server(self, source, destination):
        scp_cmd = 'sshpass -p {} scp {} {}'.format(self.password,
                                                   ''.join([self.get_remote_host(), source]),
                                                   destination)
        exec_cmd(scp_cmd)

    def copy_to_cert_server(self, source, destination):
        scp_cmd = 'sshpass -p {} scp {} {}'.format(self.password,
                                                   source,
                                                   ''.join([self.get_remote_host(), destination]))
        exec_cmd(scp_cmd)

    def copy_sas_sim_tar_to_vm(self, destination):
        self.copy_from_cert_server(self.sas_sim_file_path, destination)

    def copy_csr_to_cert_server(self, csr_file):
        self.copy_to_cert_server(csr_file, self.end_user_dir)

    def cmd_to_combine_all_needed_certificates(self, all_cert_file):
        cmd = 'cat {} {} {} > {}'.format(self.root_ca, self.intermediate_ca, self.ee_ca, all_cert_file)
        return cmd

    def copy_cert_files_for_sas_sim(self, destination):
        files_in = [self.root_ca, self.intermediate_ca, self.intermediate_key]
        files_out = ['/'.join([destination, 'ca.cert']),
                     '/'.join([destination, 'nokia04.cert']),
                     '/'.join([destination, 'nokia04.key'])]
        for i in range(len(files_in)):
            self.copy_from_cert_server(source=files_in[i], destination=files_out[i])

    def generate_all_certificate_file(self, csr_file, output_cert, destination):
        conf = '/'.join([self.ssl_ca_intermediate1_dir, 'ca.conf'])
        in_file = '/'.join([self.end_user_dir, csr_file])
        cmd = 'openssl ca -batch -config {} -notext -in {} -out {}'.format(conf, in_file, self.ee_ca)

        ssh_conn = SSHConnection()
        ssh_conn.configure(
            hostname=self.host,
            username=self.login,
            password=self.password,
        )
        ssh_conn.connect()
        ssh_conn.execute('{}'.format(cmd))
        all_cert_file = '/'.join([self.end_user_dir, output_cert])
        cmd = self.cmd_to_combine_all_needed_certificates(all_cert_file=all_cert_file)
        ssh_conn.execute('{}'.format(cmd))
        ssh_conn.disconnect()

        self.copy_from_cert_server(all_cert_file, destination)


def exec_cmd(cmd):
    splitted_cmd = shlex.split(cmd)
    logging.info("Execute:({})".format(splitted_cmd))
    proc = subprocess.Popen(splitted_cmd, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, shell=False)
    stdout, stderr = proc.communicate()
    ret_code = proc.returncode
    assert ret_code == 0, \
        "Error on command {}:ERR CODE={} STDERR={}"\
        .format(cmd, ret_code, stderr)
    logging.info("Return:{}".format(stdout))
    return stdout.decode('utf-8')
