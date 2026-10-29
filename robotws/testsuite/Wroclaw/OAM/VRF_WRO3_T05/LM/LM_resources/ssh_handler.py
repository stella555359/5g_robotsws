import paramiko
from functools import wraps


def ssh_client_decorator(method):
    @wraps(method)
    def wrapper(self, value):
        ssh_client = paramiko.SSHClient()
        self.setup(ssh_client)
        return method(self, ssh_client, value)
    return wrapper


class SshHandler:
    def __init__(self, ip_address, user, password):
        """
        :param str ip_address:
        :param str user:
        :param str password:
        """
        self.ip_address = ip_address
        self.user = user
        self.password = password

    def setup(self, ssh_client):
        """ :param paramiko.ssh_client ssh_client: """
        ssh_client.load_system_host_keys()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy)
        ssh_client.connect(self.ip_address,
                           username=self.user,
                           password=self.password)

    def check_connection(self):
        ssh_client = paramiko.SSHClient()
        ssh_client.load_system_host_keys()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy)
        status = ssh_client.connect(self.ip_address,
                                    username=self.user,
                                    password=self.password)
        if status is None:
            result = True
        else:
            result = False
        return result

    @ssh_client_decorator
    def exec_command(self, ssh_client, command):
        """
        :param paramiko.SSHClient ssh_client:
        :param str command:
        :rtype: str
        """
        _, stdout, _ = ssh_client.exec_command(command)
        filtered_stdout = stdout.read().decode("utf-8").strip()
        return filtered_stdout


def get_ssh_handler(ip_address, user, password):
    return SshHandler(ip_address, user, password)
