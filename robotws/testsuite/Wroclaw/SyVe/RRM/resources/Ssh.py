import socket
from paramiko import SSHException, SSHClient, AutoAddPolicy

SSH_PORT = 22
DEFAULT_TIMEOUT = 40


def create_ssh(host, username=None, password=None, timeout=DEFAULT_TIMEOUT, look_for_keys=False):
    """
    Function creates and returns ssh client object.
    It may be used as one connection used many times in the test
    WARNING - close() function must be called to close ssh_client in teardown
    :param host: The host to be connected
    :param username: the host user
    :param password: password for the user
    :param timeout: how long wait for the connection
    :param look_for_keys: Try to connect with ssh keys first
    :return: ssh client
    """
    ssh_client = SSHClient()
    ssh_client.set_missing_host_key_policy(AutoAddPolicy())
    try:
        ssh_client.connect(host,
                           port=SSH_PORT,
                           username=username,
                           password=password,
                           timeout=timeout,
                           allow_agent=False,
                           look_for_keys=look_for_keys)
    except (SSHException, socket.timeout):
        ssh_client.close()
        raise
    else:
        return ssh_client


def execute_ssh_command(ssh_connection_parameters, command, execution_timeout=DEFAULT_TIMEOUT, look_for_keys=False):
    """
    Safe function for ssh commands, uses context manager to open and close the ssh connection
    :param ssh_connection_parameters: TAF compatible SshServiceDetails object
    :param command: command to be executed via ssh
    :param execution_timeout: how long wait for the execution ends
    :param look_for_keys: Try to connect with ssh keys first
    :return: the output and errors from the command
    """
    with Ssh(ssh_connection_parameters, look_for_keys=look_for_keys) as ssh_conn:
        _, stdout, stderr = ssh_conn.exec_command(command, timeout=execution_timeout)
        output = stdout.read().decode('utf-8').strip()
        errors = stderr.read().decode('utf-8').strip()
    return output, errors


def download_file(ssh_connection_parameters, source, target, look_for_keys=False):
    """
    Downloads file with sftp
    :param ssh_connection_parameters: SSH connection parameters
    :param source: remote file path to be downloaded
    :param target: local target file path
    :param look_for_keys: Try to connect with ssh keys first
    :return: None
    """
    with Ssh(ssh_connection_parameters, look_for_keys=look_for_keys) as ssh_client:
        ssh_client.open_sftp().get(source, target)


def upload_file(ssh_connection_parameters, source, target, look_for_keys=False):
    """
    Uploadss file with sftp
    :param ssh_connection_parameters: SSH connection parameters
    :param source: local file path to be uploaded
    :param target: remote target file path
    :param look_for_keys: Try to connect with ssh keys first
    :return: None
    """
    with Ssh(ssh_connection_parameters, look_for_keys=look_for_keys) as ssh_client:
        ssh_client.open_sftp().put(source, target)


class Ssh(object):
    def __init__(self, ssh_connection_parameters, look_for_keys=False):
        self.host = ssh_connection_parameters.addr
        self.username = ssh_connection_parameters.username
        self.password = ssh_connection_parameters.password
        self.timeout = DEFAULT_TIMEOUT
        self.look_for_keys = look_for_keys
        self.connection = None

    def __enter__(self):
        self.connection = create_ssh(host=self.host,
                                     username=self.username,
                                     password=self.password,
                                     timeout=self.timeout,
                                     look_for_keys=self.look_for_keys)
        return self.connection

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.connection.close()
