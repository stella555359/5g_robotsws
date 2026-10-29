# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui
Authors: renhui-david.liu@nokia-sbell.com
Description: this script is used to
"""
from taf.transport.ssh import ssh
from common_utils import run_local_command


class ssh_connect(object):
    """
    To connect to or disconnect from remote servers.
    """
    ssh_connection_manager = ssh()

    def connect_to_server(self, connection, hostname, username, password, port="22", key_path=None, timeout=10):
        """
        *Usage:*
            - Keyword
            - This keyword is used to connect to a remote server
        *Author:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - connection: an alias for reusing an existing connection later
            - hostname: the ip address of a remote server
            - username: the username of a remote server
            - password: the password of a remote server
            - port: ssh port
            - key_path: the path to key that should be used to authenticate with the remote server
            - timeout: timeout
        """
        conn = self.ssh_connection_manager.connect_to(hostname=hostname, username=username, password=password,
                                                      port=port,
                                                      alias=connection,
                                                      key_path=key_path, timeout=timeout)
        return conn

    def connect_to_server_with_key(self, connection, server):
        """
        *Usage:*
            - Keyword
            - This keyword is used to connect to a remote server with a key.
        *Author:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - connection: an alias for ssh connection
            - server: dict type. the remote_server, {host=x, username=x, password=x, key_path=x}
        """
        run_local_command("chmod 600 {}".format(server["key_path"]))
        self.connect_to_server(connection, server["host"], server["username"], server["password"],
                               key_path=server["key_path"],
                               )

    def disconnect_from_server(self, connection):
        """
        *Usage:*
            - Keyword
            - This keyword is used to disconnect from a remote server.
        *Author:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - connection: an alias for ssh connection
        """
        self.ssh_connection_manager.disconnect(connection=connection)

    def send_command(self, connection, command, timeout=60):
        """
        *Usage:*
            - Keyword
            - This keyword is used to send a command in a remote server.
        *Author:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - connection: an alias for ssh connection
        """
        output = self.ssh_connection_manager.send_command(command, connection=connection, timeout=timeout)
        return output

    def execute(self, connection, command, timeout=60):
        """
        *Usage:*
            - Keyword
            - This keyword is used to execute a command in a remote server.
        *Author:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - connection: an alias for ssh connection
        """
        output = self.ssh_connection_manager.execute(command, connection=connection, timeout=timeout)
        return output

    def execute_command(self, connection, command, check_exit_status=False, timeout=60):
        """
        *Usage:*
            - Keyword
            - This keyword is used to execute a command in a remote server
            - and return the output including stdout, stderr and status.
        *Author:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - connection: an alias for ssh connection
        """
        self.ssh_connection_manager.send_command(command, connection=connection, timeout=timeout)
        stdout = self.ssh_connection_manager.read_output(connection=connection)
        stderr = self.ssh_connection_manager.read_error(connection=connection)
        status = self.ssh_connection_manager.get_exit_status(connection=connection)
        output = self.format_ssh_output(stdout, stderr, status)
        print(f"The output of {command}: {output}")
        if check_exit_status:
            self._check_exit_status(status)
        return output

    @staticmethod
    def _check_exit_status(result):
        if result.status != 0:
            raise Exception('Command execution failed:' + str(result))

    def download_file(self, connection, remote_path, local_path, timeout=60):
        """
        *Usage:*
            - Keyword
            - This keyword is used to execute a command in a remote server.
        *Author:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - connection: an alias for ssh connection
        """
        self.ssh_connection_manager.download_file(remote_path, local_path, connection=connection, timeout=timeout)

    def remove_file(self, connection, remote_path, timeout=60):
        """
        *Usage:*
            - Keyword
            - This keyword is used to execute a command in a remote server.
        *Author:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - connection: an alias for ssh connection
        """
        if self.file_exists(connection, remote_path, timeout=timeout):
            command = f"rm -rf {remote_path}"
            self.execute(connection, command)

    @staticmethod
    def format_ssh_output(stdout, stderr, status):
        return (
            f"\nstdout: \n\t{stdout}\n"
            f"stderr: \n\t{stderr}\n"
            f"exit status: {status}\n"
        )

    def file_exists(self, connection, remote_path, timeout=30):
        """
        *Usage:*
            - Keyword
            - This keyword is used to check if a file exists in a remote server.
        *Author:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - connection: an alias for ssh connection
        """
        return self.ssh_connection_manager.file_exists(remote_path, connection=connection, timeout=timeout)
