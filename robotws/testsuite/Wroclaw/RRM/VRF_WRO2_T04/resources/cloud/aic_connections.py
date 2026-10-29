from taf.transport.ssh import ssh
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl


ssh_client = ssh()


class k8s_connection:
    def __init__(self):
        self.ssh = ssh_client
        self.type = self.get_hosting()

    def __enter__(self):
        self.ssh.connect_to(self.host, self.username, self.password, alias=f'{self.type.namespace}')
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.ssh.disconnect(connection=f'{self.type.namespace}')

    @property
    def host(self):
        return self.type.master_node.ssh_connection_details.addr

    @property
    def username(self):
        return self.type.master_node.ssh_connection_details.username

    @property
    def password(self):
        return self.type.master_node.ssh_connection_details.password

    @property
    def namespace(self):
        return self.type.namespace

    @staticmethod
    def show_type():
        return tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting

    def get_hosting(self):
        raise NotImplementedError

    def execute_command(self, cmd):
        output = self.ssh.execute(cmd, connection=self.type.namespace)
        return output

    def send_command(self, cmd):
        self.ssh.send_command(cmd, connection=self.type.namespace)

    def download_file(self, remote_path, local_path):
        self.ssh.download_file(remote_path, local_path, connection=self.type.namespace)

    def upload_file(self, local_path, remote_path):
        self.ssh.upload_file(local_path, remote_path, connection=self.type.namespace)


class VduKubeConnection(k8s_connection):
    def __init__(self, vdu_id=0):
        self.vdu_id = vdu_id
        super().__init__()

    def get_hosting(self):
        return tl.gnbs[0].dus[self.vdu_id].cloud_deployment.cloud_hosting

    def get_worker_node(self):
        return self.execute_command("oc get nodes | grep ^worker | awk '{print $1}' | xargs -n1 oc describe node $1 | "
                                    "grep InternalIP | awk '{print $2}'").strip()

    def execute_command_on_worker(self, cmd):
        worker_addr = self.get_worker_node()
        if worker_addr == self.host:
            self.send_command(cmd)
            return
        logger.debug(f"execute command on worker: {cmd}")
        self.ssh.connect_to(worker_addr, self.username, self.password, alias='worker', proxy=self.namespace)
        self.ssh.send_command(cmd, connection='worker')
        self.ssh.disconnect(connection='worker')

    def download_file_from_worker(self, remote_path, local_path):
        worker_addr = self.get_worker_node()
        if worker_addr == self.host:
            self.download_file(remote_path, local_path)
            return
        self.ssh.connect_to(worker_addr, self.username, self.password, alias='worker', proxy=self.namespace)
        self.ssh.download_file(remote_path, local_path, connection='worker')
        self.ssh.disconnect(connection='worker')


class VcuKubeConnection(k8s_connection):
    def __init__(self):
        super().__init__()

    def get_hosting(self):
        return tl.gnbs[0].cloud_deployment.cloud_hosting
