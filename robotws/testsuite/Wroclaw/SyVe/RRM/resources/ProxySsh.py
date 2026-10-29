import socket
from paramiko import SSHException, SSHClient, AutoAddPolicy
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import Ssh, SSH_PORT

DEFAULT_TIMEOUT = 60


def create_proxy_ssh(host, username=None, password=None, timeout=DEFAULT_TIMEOUT, look_for_keys=False, sock=None):
    """
    Function creates and returns ssh client object.
    It may be used as one connection used many times in the test
    WARNING - close() function must be called to close ssh_client in teardown
    :param host: The host to be connected
    :param username: the host user
    :param password: password for the user
    :param timeout: how long wait for the connection
    :param look_for_keys: Try to connect with ssh keys first
    :param sock: proxy connection
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
                           look_for_keys=look_for_keys,
                           sock=sock)
    except (SSHException, socket.timeout):
        ssh_client.close()
        raise
    else:
        return ssh_client


def execute_ssh_proxy_command(proxy_connection_details, ssh_connection_parameters, command,
                              execution_timeout=DEFAULT_TIMEOUT, look_for_keys=False):
    """
    Safe function for ssh commands, uses context manager to open and close the ssh connection
    :param proxy_connection_details: TAF compatible SshServiceDetails object
    :param ssh_connection_parameters: TAF compatible SshServiceDetails object
    :param command: command to be executed via ssh
    :param execution_timeout: how long wait for the execution ends
    :param look_for_keys: Try to connect with ssh keys first
    :return: the output and errors from the command
    """
    with Ssh(proxy_connection_details, look_for_keys=look_for_keys) as proxy:
        with ProxySsh(ssh_connection_parameters, proxy=proxy, look_for_keys=True) as ssh_conn:
            _, stdout, stderr = ssh_conn.exec_command(command, timeout=execution_timeout)
            output = stdout.read().decode('utf-8').strip()
            errors = stderr.read().decode('utf-8').strip()
        return output, errors


def _prepare_channel_for_connection(proxy_connection, dest_host):
    src_addr = proxy_connection.get_transport().getpeername()
    dest_addr = ("{}".format(dest_host), SSH_PORT)
    transport = proxy_connection.get_transport()
    channel = transport.open_channel("direct-tcpip", dest_addr, src_addr)
    return channel


class ProxySsh(Ssh):

    def __init__(self, ssh_connection_parameters, proxy, look_for_keys=False):
        super(ProxySsh, self).__init__(ssh_connection_parameters, look_for_keys=look_for_keys)
        self.proxy = proxy

    def __enter__(self):
        self.connection = create_proxy_ssh(host=self.host,
                                           username=self.username,
                                           password=self.password,
                                           timeout=self.timeout,
                                           sock=_prepare_channel_for_connection(self.proxy, self.host))
        return self.connection
