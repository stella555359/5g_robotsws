"""
:author:  Test script team
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import os
import paramiko
import re
import pexpect
import time
from traceback import format_exception
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh.interface import ssh
from taf.transport.ssh.exceptions import (CommandOutputTimeoutError, CommandExecutionError, ConnectFailedError,
                                          ConnectionError, CommandOutputCollectionError, FileProtocolClientError,
                                          CommandOutputCollectionTerminationError)
from taf.internal.aliasing.exceptions import AliasLookupError
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (SSHConnectionFailure, EnvironmentIssue,
                                                                        ScriptIssue)
import testsuite.Oulu.TrunkEng.Common.Python.Resources.RMODLoginInfo as RMODLoginInfo


class SSHConnection(object):
    all_created_alias = []
    all_created_objects = []

    def __init__(self):
        """
        Provides Keywords for SSH connections. If you want to collect SSH logs, start the log collection
        before creating the connection. In order to send a command over SSH, connect to the IP with Take SSH Connection.
        Close SSH connection and stop log collection before ending the test case or once the connection is no
        longer needed.
        """
        self.logger = BuiltIn().get_library_instance("LOG")

        self.ssh = ssh()
        self.ssh_log = None
        self.pexpect_log = None

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)

    def connection_command_and_output(self, command, ip="192.168.255.129", alias="ssh", username="toor4nsn",
                                      password="oZPS0POrRieRtu", use_existing_connection=False, timeout="60 s"):
        output = ""
        if ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        try:
            if not use_existing_connection:
                self.make_ssh_log()
                self.take_ssh_connection(ip, alias=alias, username=username, password=password)
            output = self.send_command_to_ip_return_output(command, alias=alias, timeout=timeout)
        except (paramiko.ssh_exception.SSHException, CommandOutputTimeoutError, CommandExecutionError,
                ConnectFailedError, ConnectionError, CommandOutputCollectionError, FileProtocolClientError,
                CommandOutputCollectionTerminationError, EOFError, AliasLookupError) as e:
            self.logger.debug(f"SSH error: {e.__class__.__name__}:{e}\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            print(f"SSH error: {e.__class__.__name__}:{e}\n{''.join(format_exception(type(e), e, e.__traceback__))}")
        finally:
            if not use_existing_connection:
                self.close_ssh_connection(alias)
                self.close_ssh_log()
        return output

    def take_ssh_connection(self, ip, alias="ssh", proxy=None, username="toor4nsn", password="oZPS0POrRieRtu",
                            print_eventlog=False):
        """
        Take SSH connection to given IP. Alias is used to recognize the connection, this is useful when multiple
        SSH connections need to be created.

        :param str ip: IP address for the SSH connection.
        :param str alias: User can define any name for the connection with alias to identify the connection when using
                          other methods/KWs.
        :param str proxy: (Optional) Alias of a previously made connection. Used when multiple SSH connections
                          are needed, e.g. when first connecting to SMOD and then BBMOD.
        :param str username: (Optional) Login information username. 'toor4nsn' when not given.
        :param str password: (Optional) Login information password. 'oZPS0POrRieRtu' when not given.
        :param bool print_eventlog: Prints ssh information to eventlog if set to True. Default is False.
        :raise SSHConnectionFailure: If SSH connection fails.
        """
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        try:
            if not self.ssh_log:
                self.make_ssh_log()
            if print_eventlog:
                info(f"Take SSH connection to IP {ip}, alias name will be {alias} (proxy {proxy}).")
            else:
                self.logger.debug(f"Take SSH connection to IP {ip}, alias name will be {alias} (proxy {proxy}).")
            connection = None
            attempt = 0
            while not connection and attempt < 10:
                try:
                    connection = self.ssh.connect_to(ip, username, password, timeout=60, proxy=proxy, alias=alias)
                except (paramiko.ssh_exception.SSHException, CommandOutputTimeoutError, CommandExecutionError,
                        ConnectFailedError, ConnectionError, CommandOutputCollectionError, FileProtocolClientError,
                        CommandOutputCollectionTerminationError, EOFError, AliasLookupError) as ex:
                    self.logger.debug(f"Attempt {attempt} was not successful. {ex.__class__.__name__}:{ex}\n"
                                      f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
                    print(f"Attempt {attempt} was not successful. {ex.__class__.__name__}:{ex}\n"
                          f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
                if not connection:
                    self.logger.debug(f"Cannot open SSH connection, {attempt}. attempt, try again in 5s.")
                    print(f"Cannot open SSH connection, {attempt}. attempt, try again in 5s.")
                    attempt += 1
                    BuiltIn().sleep("5s")
                    if attempt > 8:
                        self.close_all_ssh_connections()
                        self.delete_known_host_file()
                    else:
                        self.delete_known_host_file()
            if connection:
                if print_eventlog:
                    info("SSH connection created to {}.".format(ip))
                else:
                    self.logger.debug("SSH connection created to {}.".format(ip))
                self.ssh_log.write("\n" + datetime.now().isoformat(sep=" ") +
                                   "  SSH connection created to IP {} with alias {}.\n\n".format(ip, alias))
            else:
                error(f"{loop}Cannot open SSH connection to {ip}")
                raise SSHConnectionFailure
            if alias not in SSHConnection.all_created_alias:
                SSHConnection.all_created_alias.append(alias)
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError) as e:
            warning(f"{loop}Unable to take ssh connection ERROR {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def close_ssh_connection(self, alias="ssh", print_eventlog=False, close_ssh_log=False):
        """
        Close SSH connection created for the alias.

        :param str alias: Alias that was used when creating connection to the IP.
        :param bool print_eventlog: Prints ssh information to eventlog if set to True. Default is False.
        :param bool close_ssh_log: Default is False.
        """
        try:
            self.ssh.disconnect(connection=alias)
            if alias in SSHConnection.all_created_alias:
                SSHConnection.all_created_alias.remove(alias)
            if print_eventlog:
                info("SSH connection to alias {} is now closed.".format(alias))
            if self.ssh_log:
                self.ssh_log.write("\n" + datetime.now().isoformat(sep=" ") +
                                   "  SSH connection to alias {} is now closed.\n\n".format(alias))
            else:
                self.logger.debug("File ssh_log is none, we cannot write to it.")
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError, EOFError,
                paramiko.ssh_exception.SSHException, CommandOutputTimeoutError, CommandExecutionError,
                ConnectFailedError, ConnectionError, CommandOutputCollectionError, FileProtocolClientError,
                CommandOutputCollectionTerminationError) as e:
            print(f"Unable to close ssh connection ERROR {e.__class__.__name__}:{e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            self.logger.debug(f"Unable to close ssh connection ERROR {e.__class__.__name__}:{e}\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        finally:
            if close_ssh_log:
                self.close_ssh_log()

    def send_command_to_ip_return_output(self, command, alias="ssh", print_eventlog=False, timeout="60 s"):
        """
        Send command to an IP address. First a connection needs to be made under the alias using take_ssh_connection.

        :param str command: Command to be sent via SSH.
        :param str alias: Alias that was used when creating connection to the IP.
        :param bool print_eventlog: If set true output is written to eventlog, otherwise not.
        :param str timeout: Time to wait for ssh commands.
        :return str output: Output received from the command.
        """
        if self.ssh_log:
            self._write_to_ssh_log("Sending command '{}' to alias '{}'.".format(command, alias))
        try:
            output = self.ssh.execute(command, alias, timeout)
        except CommandOutputTimeoutError as e:
            warning(f"We received 'CommandOutputTimeoutError' after giving command '{command}'. In case there "
                    f"are unexpected issues afterwards, this is most likely the reason.\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            output = ""
        except EOFError as e:
            warning(f"We received 'EOFError' after giving command '{command}'. CommandExecutionError: cannot send "
                    f"command: not connected.\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            output = ""
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError, CommandOutputTimeoutError,
                CommandExecutionError, ConnectFailedError, ConnectionError, CommandOutputCollectionError,
                FileProtocolClientError, CommandOutputCollectionTerminationError) as e:
            warning(f"Unable to send command {command} to ip and return output ERROR {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            output = ""
        if print_eventlog:
            info("'{}' gives:\n'{}'".format(command, output))
        else:
            self.logger.debug("'{}' gives:\n'{}'".format(command, output))
        if self.ssh_log:
            self._write_to_ssh_log("Output: '{}'.".format(output))
        return output

    def make_ssh_log(self):
        """
        Initialize an SSH log for debugging purposes. Should be initialized before establishing the SSH connection.
        """
        try:
            log_time = datetime.now().strftime("%Y%m%d_%H%M%S")
            ssh_folder = os.path.join(self.logger.log_dir, "ssh_logs")
            if not os.path.exists(ssh_folder):
                self.logger.debug(f"Folder {ssh_folder} doesn't exists, create it.")
                os.makedirs(ssh_folder, exist_ok=True)
            self.ssh_log = open(os.path.join(ssh_folder, "ssh_log_{}.txt".format(log_time)), "w")
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError) as e:
            warning(f"Unable to make ssh log ERROR {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def close_ssh_log(self):
        """
        Stop collecting the SSH log.
        """
        try:
            self.ssh_log.close()
            self.ssh_log = None
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError) as e:
            self.logger.debug(f"Unable to close ssh log ERROR {e.__class__.__name__}:{e}\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def _write_to_ssh_log(self, message):
        """
        Write to the SSH log.

        :param str message: Message to be printed to the SSH log.
        """
        try:
            if not self.ssh_log:
                self.logger.debug("File ssh_log is None, we cannot write to it. Call make ssh log")
                self.make_ssh_log()
            self.ssh_log.write(datetime.now().isoformat(sep=" ") + "  {}\n".format(message))
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError) as e:
            warning(f"Unable to write to ssh log ERROR {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def connection_and_download_file(self, remote_path, local_path, ip="192.168.255.129", alias="ssh",
                                     username="toor4nsn", password="oZPS0POrRieRtu", use_existing_connection=False):
        """
        Download file. Will not create directories. Folders can't be downloaded.

        :param str remote_path: path or list of paths to the files on the remote to download
        :param str local_path:  if remote path is a single path, then local path must be a path to the file
                                (existing or not), otherwise local path must be a path to an existing directory
                                that the downloaded files will be written to.
        :param str ip: Default 192.168.255.129.
        :param str alias: (Optional) default ssh.
        :param str username: Username for ssh connection.
        :param str password: Password for ssh connection.
        :param bool use_existing_connection: If set to True uses previously created ssh connection, otherwise creates
        new one.
        """
        if ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        try:
            if not use_existing_connection:
                self.make_ssh_log()
                self.take_ssh_connection(ip, alias=alias, username=username, password=password)
            self.download_file(remote_path, local_path)
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError) as e:
            warning(f"Unable to make connection and download file ERROR {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        finally:
            if not use_existing_connection:
                self.close_ssh_connection(alias)
                self.close_ssh_log()

    def connection_and_upload_file(self, local_path, remote_path, ip="192.168.255.129", alias="upload",
                                   username="toor4nsn", password="oZPS0POrRieRtu", use_existing_connection=False):
        """
        Uploads local file to given ip. Folders can't be uploaded.

        :param str local_path:  Path to local file that will be uploaded to remote path.
        :param str remote_path: Path or list of paths to the files on the remote to upload.
        :param str ip: Default 192.168.255.129.
        :param str alias: (Optional) default upload.
        :param str username: Username for ssh connection.
        :param str password: Password for ssh connection.
        :param bool use_existing_connection: If set to True uses previously created ssh connection, otherwise creates
        new one.
        """
        if ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        try:
            if not use_existing_connection:
                self.make_ssh_log()
                self.take_ssh_connection(ip, alias=alias, username=username, password=password)
            self.upload_file(local_path, remote_path)
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError) as e:
            warning(f"Unable to make connection and upload file ERROR {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        finally:
            if not use_existing_connection:
                self.close_ssh_connection(alias)
                self.close_ssh_log()

    def download_file(self, remote_path, local_path, connection="ssh", timeout="30", smod_object=None):
        """
        Download(s) file(s). Will not create directories. Folders can't be downloaded

        :param str remote_path: path or list of paths to the files on the remote to download
        :param str local_path:  if remote path is a single path, then local path must be a path to the file
                                (existing or not), otherwise local path must be a path to an existing directory
                                that the downloaded files will be written to.
        :param str connection: (Optional) Alias
        :param str timeout: (Optional) Timeout for transmission of a single packet of data
        :param obj smod_object: Default is None, if fullrack in question and file needs to be downloaded
                                 from the extension SMOD then this is useful.
        """
        try:
            if smod_object and not smod_object.master:
                info("Download file {} from extension module to master smod.".format(remote_path))
                remote_path = self.move_file_from_extension_to_master(remote_path, smod_object)
                name_of_file = remote_path[remote_path.rfind("/") + 1:]
                local_path = os.path.join(self.logger.log_dir, name_of_file)
            if self.ssh_log:
                self._write_to_ssh_log("Downloading '{}' to '{}'.".format(remote_path, local_path))
            info("Downloading '{}' to '{}'.".format(remote_path, local_path))
            self.ssh.download_file(remote_path, local_path, connection=connection, timeout=timeout)
            info("Downloaded")
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError) as e:
            warning(f"Unable to download file ERROR {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def upload_file(self, local_path, remote_path, connection="upload", timeout="30"):
        """
        Upload(s) file(s). Folders can't be uploaded

        :param str local_path:  Path to local file that will be uploaded to remote path.
        :param str remote_path: Path or list of paths to the files on the remote to upload.
        :param str connection: (Optional) Alias
        :param str timeout: (Optional) Timeout for transmission of a single packet of data
        """
        try:
            if self.ssh_log:
                self._write_to_ssh_log("Uploading '{}' to '{}'.".format(local_path, remote_path))
            info("Uploading '{}' to '{}'.".format(local_path, remote_path))
            self.ssh.upload_file(local_path, remote_path, connection=connection, timeout=timeout)
            info("Uploaded")
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError) as e:
            warning(f"Unable to upload file ERROR {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def ssh_connection_to_smod_ltx_attach(self, name_for_log, ip_to_connect="192.168.255.129", print_to_eventlog=True,
                                          raise_error=True):
        """
        Take ssh connection to BTS, do lxc-attach. Return ssh connection object.
        :param str name_for_log: Name for log ssh_<name_for_log>_<timestamp>.log
        :param str ip_to_connect: IP address to connect. Default is 192.168.255.129
        :param bool print_to_eventlog: Print input and output to eventlog if set to True, otherwise to debug file.
                                       Default is True.
        :param bool raise_error: Default True, if False will raise just warning.
        """
        if ip_to_connect == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                ip_to_connect = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        enb_ssh_prompt = re.compile(r'(:~ >)')
        enb_ssh = self.ssh_connection_to_smod(
            name_for_log, ip_to_connect=ip_to_connect, print_to_eventlog=print_to_eventlog, raise_error=raise_error)
        enb_ssh.sendline("cat /rom/config/FRIps.txt")
        enb_ssh.expect(enb_ssh_prompt)
        if print_to_eventlog:
            info("Output for command 'cat /rom/config/FRIps.txt' is: {}".format(enb_ssh.before))
        else:
            self.logger.debug("Output for command 'cat /rom/config/FRIps.txt' is: {}".format(enb_ssh.before))
        enb_ssh.sendline("lxc-ls\n")  # right or left
        index = enb_ssh.expect(["0x1018", "0x2018", "fct-4", "fct-0", pexpect.EOF, pexpect.TIMEOUT])
        self.logger.debug("right or left : {}.".format(index))
        half_location = '0x1018'
        if index in [0, 3]:  # fct-0 was needed also here because sometimes nodes just are not printed
            half_location = "0x1018"
        elif index in [1, 2]:  # fct-4 was needed also here because sometimes nodes just are not printed
            half_location = "0x2018"
        elif index in [4, 5]:
            if raise_error:
                error("Unable to get bts location in rack due to EOF or TIMEOUT.")
                self.disconnect_ssh_connection(enb_ssh)
                raise EnvironmentIssue
            else:
                warning("Unable to get bts location in rack due to EOF or TIMEOUT.")
                self.disconnect_ssh_connection(enb_ssh)
                return None
        else:
            warning(f"Unable to get bts location in rack. Using default {half_location}")
        try_time = 0
        lxc_attach = False
        BuiltIn().sleep("1s")
        while try_time < 20 and not lxc_attach:
            try_time += 1
            if print_to_eventlog:
                info("Give command ({}. try): lxc-attach -n {}".format(try_time, half_location))
            else:
                self.logger.debug("Give command ({}. try): lxc-attach -n {}".format(try_time, half_location))
            enb_ssh.sendline("lxc-attach -n {}".format(half_location))
            # enb_ssh.expect(":~ >", timeout=300)
            BuiltIn().sleep("1s")
            index = enb_ssh.expect(["FHNET", "fct-4", "fct-0", pexpect.EOF, pexpect.TIMEOUT])
            self.logger.debug(f"Index: {index}\nBefore: {enb_ssh.before}\nAfter: {enb_ssh.after}")
            other_index = enb_ssh.expect(["(.+)FHNET", "(.+)fct-4", "(.+)fct-0", pexpect.EOF, pexpect.TIMEOUT])
            self.logger.debug(f"Other index: {other_index}\nBefore: {enb_ssh.before}\nAfter: {enb_ssh.after}")
            # self.logger.debug(f"Other index: {other_index}")
            if index == 0 or other_index == 0:
                if print_to_eventlog:
                    info("Ssh connection with lxc-attach to BTS is established")
                else:
                    self.logger.debug("Ssh connection with lxc-attach to BTS is established")
                lxc_attach = True
                break
            else:
                if print_to_eventlog:
                    info("Ssh connection with lxc-attach to BTS was not successful, try again in 5s.")
                else:
                    self.logger.debug("Ssh connection with lxc-attach to BTS was not successful, try again in 5s.")
                BuiltIn().sleep("5s")
        if not lxc_attach:
            if raise_error:
                error("Failed to create SSH connection to BTS with lxc-attach. Lxc-attach was not successful.")
                self.disconnect_ssh_connection(enb_ssh)
                raise SSHConnectionFailure("Lxc-attach was not successful.")
            else:
                warning("Failed to create SSH connection to BTS with lxc-attach. Lxc-attach was not successful.")
                self.disconnect_ssh_connection(enb_ssh)
        return enb_ssh

    def ssh_connection_to_smod(self, name_for_log="to_smod", ip_to_connect="192.168.255.129", print_to_eventlog=True,
                               raise_error=True):
        """
        Take ssh connection to BTS. Return ssh connection object.

        :param str name_for_log: Name for log ssh_<name_for_log>_<timestamp>.log. Default is to_smod.
        :param str ip_to_connect: IP address to connect. Default is 192.168.255.129.
        :param bool print_to_eventlog: Print input and output to eventlog if set to True, otherwise to debug file.
                                       Default is True
        :param bool raise_error: Default True, if False will raise just warning.
        :return object: Returns Pexpect ssh connection object.
        """
        if ip_to_connect == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                ip_to_connect = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        enb_ssh = None
        self.delete_known_host_file()
        save_path = self.logger.log_dir
        if not os.path.exists(self.logger.log_dir):
            if "/loop_" in save_path:
                save_path = SSHConnection._safe_split(save_path, "/loop_")[0]
                self.logger.debug(f"Folder {self.logger.log_dir} doesn't exists anymore, use test folder path to save "
                                  f"the ssh file: {save_path}")
        if not os.path.exists(save_path):
            self.logger.debug(f"Folder {save_path} doesn't exists anymore, use suite folder path to save the "
                              f"ssh file: {self.logger.suite_folder}")
            save_path = self.logger.suite_folder
        if not os.path.exists(f"{save_path}/ssh_logs"):
            self.logger.debug(f"Folder {save_path}/ssh_logs doesn't exists, create it.")
            os.makedirs(f"{save_path}/ssh_logs", exist_ok=True)
        save_path = f"{save_path}/ssh_logs"
        self.logger.debug(f"Save ssh logs to folder {save_path}.")
        pexpect_log_file_path = os.path.join(save_path, "ssh_{}_{}.log".format(
            name_for_log, datetime.now().strftime("%Y%m%d_%H%M%S")))
        self.logger.debug("Log file path: {}".format(pexpect_log_file_path))
        enb_ssh_prompt = re.compile(r'(:~ >|AaShell>)')  # r'root@(fct|asc)-[04]a:~ >')
        self.pexpect_log = open(pexpect_log_file_path, 'a')
        try_time = 0
        ssh_ok = False
        while try_time < 11 and not ssh_ok:
            try_time += 1
            try:
                if print_to_eventlog:
                    info(f"Create ssh connection to {ip_to_connect} ({try_time}.try)")
                else:
                    self.logger.debug(f"Create ssh connection to {ip_to_connect} ({try_time}.try)")
                ssh_enb_ute_cmd = "ssh {user}@{host}".format(user="toor4nsn", host=ip_to_connect)
                self.logger.debug("ssh login to eNB with command: {}".format(ssh_enb_ute_cmd))
                enb_ssh = pexpect.spawn(ssh_enb_ute_cmd, encoding='utf-8', codec_errors='ignore')
                if enb_ssh:
                    if enb_ssh not in SSHConnection.all_created_objects:
                        SSHConnection.all_created_objects.append(enb_ssh)
                    enb_ssh.logfile = self.pexpect_log
                    index = enb_ssh.expect(["yes/no", "assword:", pexpect.EOF], timeout=60)
                    if index == 0:
                        enb_ssh.sendline("yes")
                        enb_ssh.expect("assword:", timeout=60)
                        self.logger.debug("'Password:' prompt detected, about to enter password oZPS0POrRieRtu")
                        enb_ssh.sendline("oZPS0POrRieRtu")
                        self.logger.debug("Password entered, waiting for command prompt")
                        enb_ssh.expect(enb_ssh_prompt, timeout=60)
                        self.logger.debug("Command prompt detected. SSH Login successful.")
                    elif index == 1:
                        self.logger.debug("'Password:' prompt detected, about to enter password oZPS0POrRieRtu")
                        enb_ssh.sendline("oZPS0POrRieRtu")
                        self.logger.debug("Password entered, waiting for command prompt")
                        enb_ssh.expect(enb_ssh_prompt, timeout=60)
                        self.logger.debug("Command prompt detected. SSH Login successful.")
                    if enb_ssh.isalive():
                        if print_to_eventlog:
                            info(f"Ssh connection to {ip_to_connect} successfully established.")
                        else:
                            self.logger.debug(f"Ssh connection to {ip_to_connect} successfully established.")
                        ssh_ok = True
                    else:
                        self.logger.debug("SSH connection is not alive")
                        print("SSH connection is not alive")
                else:
                    if try_time == 10:
                        if raise_error:
                            error(f"Failed to create ssh connection to {ip_to_connect}.")
                            raise SSHConnectionFailure
                        else:
                            warning(f"Failed to create ssh connection to {ip_to_connect}.")
                    else:
                        if print_to_eventlog:
                            error(f"Failed to create ssh connection to {ip_to_connect}.")
                        else:
                            self.logger.debug(f"Failed to create ssh connection to {ip_to_connect}.")
            except pexpect.TIMEOUT as e:
                if try_time == 10:
                    if raise_error:
                        error(f"Timeout while taking ssh connection to {ip_to_connect}.\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                        raise SSHConnectionFailure
                    else:
                        warning(f"Timeout while taking ssh connection to {ip_to_connect}.\n"
                                f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                else:
                    if print_to_eventlog:
                        info(f"Timeout while taking ssh connection to {ip_to_connect}. Try again.\n"
                             f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    else:
                        self.logger.debug(f"Timeout while taking ssh connection to {ip_to_connect}. Try again.\n"
                                          f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            except pexpect.EOF as e:
                if try_time == 10:
                    if raise_error:
                        error(f"End Of File (EOF) while taking ssh connection to {ip_to_connect}.\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                        raise SSHConnectionFailure
                    else:
                        warning(f"End Of File (EOF) while taking ssh connection to {ip_to_connect}.\n"
                                f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                else:
                    if print_to_eventlog:
                        info(f"End Of File (EOF) while taking ssh connection to {ip_to_connect}. Try again.\n"
                             f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    else:
                        self.logger.debug(f"End Of File (EOF) while taking ssh connection to {ip_to_connect}. "
                                          f"Try again\n"
                                          f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if not ssh_ok and try_time > 5:
                self.logger.debug("SSH was not successful in first 5 tries. Wait 60s before retrying ssh connection.")
                BuiltIn().sleep("60s")
        return enb_ssh

    def send_command_to_smod_by_ssh(self, command, enb_ssh=None, return_output=False, ssh_timeout=60,
                                    print_to_eventlog=True, name_for_log="", ip_to_connect="192.168.255.129",
                                    raise_error=True, disconnect_ssh=True, return_ssh_object=False):
        """
        With this method you can give ssh command to BTS by using pexpect ssh connection. This allows for example child
        connection and scp to other units etc.

        :param command str/list command: Command to be given to SMOD or list of commands to be given.
        :param object enb_ssh: Pexpect ssh connection object. Default is None.
        :param bool return_output: Default is False, if True returns output.
        :param int ssh_timeout: Time to max wait for prompt after ssh commands.
        :param bool print_to_eventlog: Print input and output to eventlog if set to True. Default is True.
        :param str name_for_log: You can give name for the ssh log. For example to_smod_get_side
        :param str ip_to_connect: IP address to connect. Default is 192.168.255.129
        :param bool raise_error: Default True, if False will raise just warning.
        :param bool disconnect_ssh: Default True, if False will not disconnect ssh connection.
        :param bool return_ssh_object: Default False, if True returns ssh_object

        :raise ScriptIssue: If command is not str or list.
        """
        output_for_return = ""
        if ip_to_connect == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                ip_to_connect = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        if not enb_ssh:
            try:
                enb_ssh = self.ssh_connection_to_smod(name_for_log, ip_to_connect=ip_to_connect,
                                                      print_to_eventlog=print_to_eventlog,
                                                      raise_error=raise_error)
            except SSHConnectionFailure:
                ip_to_connect = "192.168.255.1"
                enb_ssh = self.ssh_connection_to_smod(name_for_log, ip_to_connect=ip_to_connect,
                                                      print_to_eventlog=print_to_eventlog,
                                                      raise_error=raise_error)
        if isinstance(command, str):
            if return_output:
                output_for_return = self._send_command_to_smod(enb_ssh, command, return_output, ssh_timeout,
                                                               print_to_eventlog, raise_error)
            else:
                self._send_command_to_smod(enb_ssh, command, return_output, ssh_timeout, print_to_eventlog, raise_error)
        elif isinstance(command, list):
            for cmd in command:
                if return_output:
                    output = self._send_command_to_smod(enb_ssh, cmd, return_output, ssh_timeout,
                                                        print_to_eventlog, raise_error)
                    output_for_return = output_for_return + output
                else:
                    self._send_command_to_smod(enb_ssh, cmd, return_output, ssh_timeout, print_to_eventlog, raise_error)
        else:
            error("Command to send_command_to_smod_by_ssh method is expected to be str or list (command {}).".format(
                command))
            raise ScriptIssue
        if print_to_eventlog:
            info("Command(s) sent.")
        if disconnect_ssh:
            self.disconnect_ssh_connection(enb_ssh, print_to_eventlog=print_to_eventlog)
        if return_output and return_ssh_object:
            return output_for_return, return_ssh_object
        elif return_output:
            return output_for_return
        elif return_ssh_object:
            return return_ssh_object
        else:
            if not disconnect_ssh:
                self.logger.debug("Command(s) sent, no output returned, return ssh object.")
                return enb_ssh
        return None

    def ssh_connection_to_given_ip(self, user_name="", ssh_password="", ip_to_connect="", name_for_log="",
                                   print_to_eventlog=True, raise_error=True, set_dumb_term=False):
        """
        Take ssh connection to given IP. Return ssh connection object.

        :param str ip_to_connect: IP address to connect.
        :param str user_name: Username for ssh connection.
        :param str ssh_password: Password for ssh connection.
        :param str name_for_log: Name for log ssh_<name_for_log>_<timestamp>.log. Default is empty str.
        :param bool print_to_eventlog: Print input and output to eventlog if set to True, otherwise to debug file.
                                       Default is True
        :param bool raise_error: Default True, if False will raise just warning.
        :param bool set_dumb_term: If True reduce escape output from remote shell (TERM=dumb, disable fancy prompt/color
                                   , non-interactive mode)
        :return object: Returns Pexpect ssh connection object.
        """
        ssh_object = None
        if not ip_to_connect:
            if raise_error:
                error("IP address to connect is not given.")
                raise ScriptIssue("IP address to connect is not given.")
            else:
                warning("IP address to connect is not given.")
                return None
        self.delete_known_host_file()
        save_path = self._get_save_path()
        save_path = f"{save_path}/ssh_logs"
        self.logger.debug(f"Save ssh logs to folder {save_path}.")
        pexpect_log_file_path = os.path.join(save_path, "ssh_{}_{}.log".format(
            name_for_log, datetime.now().strftime("%Y%m%d_%H%M%S")))
        self.logger.debug("Log file path: {}".format(pexpect_log_file_path))
        ssh_prompt = re.compile(r'(:~ >|AaShell>|:~)')
        self.pexpect_log = open(pexpect_log_file_path, 'a')
        try_time = 0
        ssh_ok = False
        while try_time < 11 and not ssh_ok:
            try_time += 1
            try:
                if print_to_eventlog:
                    info(f"Create ssh connection to {ip_to_connect} ({try_time}.try)")
                else:
                    self.logger.debug(f"Create ssh connection to {ip_to_connect} ({try_time}.try)")
                if set_dumb_term:
                    ssh_cmd = "TERM=dumb ssh {user}@{host}".format(user=user_name, host=ip_to_connect)
                else:
                    ssh_cmd = "ssh {user}@{host}".format(user=user_name, host=ip_to_connect)
                self.logger.debug("ssh login with command: {}".format(ssh_cmd))
                ssh_object = pexpect.spawn(ssh_cmd, encoding='utf-8', codec_errors='ignore')
                if ssh_object:
                    ssh_object.logfile = self.pexpect_log
                    if ssh_object not in SSHConnection.all_created_objects:
                        SSHConnection.all_created_objects.append(ssh_object)
                    index = ssh_object.expect(["yes/no", "assword:", ":~", pexpect.EOF], timeout=60)
                    if index == 0:
                        ssh_object.sendline("yes")
                        ssh_object.expect("assword:", timeout=60)
                        self.logger.debug("'Password:' prompt detected, about to enter password")
                        ssh_object.sendline(ssh_password)
                        self.logger.debug("Password entered, waiting for command prompt")
                        ssh_object.expect(ssh_prompt, timeout=60)
                        self.logger.debug("Command prompt detected. SSH Login successful.")
                    elif index == 1:
                        self.logger.debug("'Password:' prompt detected, about to enter password")
                        ssh_object.sendline(ssh_password)
                        self.logger.debug("Password entered, waiting for command prompt")
                        ssh_object.expect(ssh_prompt, timeout=60)
                        self.logger.debug("Command prompt detected. SSH Login successful.")
                    else:
                        self.logger.debug("No password needed.")
                    if ssh_object.isalive():
                        if print_to_eventlog:
                            info(f"Ssh connection to {ip_to_connect} successfully established.")
                        else:
                            self.logger.debug(f"Ssh connection to {ip_to_connect} successfully established.")
                        ssh_ok = True
                    else:
                        self.logger.debug("SSH object is not alive")
                        print("SSH object is not alive")
                else:
                    if try_time == 10:
                        if raise_error:
                            error(f"Failed to create ssh connection to {ip_to_connect}.")
                            raise SSHConnectionFailure
                        else:
                            warning(f"Failed to create ssh connection to {ip_to_connect}.")
                    else:
                        if print_to_eventlog:
                            error(f"Failed to create ssh connection to {ip_to_connect}.")
                        else:
                            self.logger.debug(f"Failed to create ssh connection to {ip_to_connect}.")
            except pexpect.TIMEOUT as e:
                if try_time == 10:
                    if raise_error:
                        error(f"Timeout while taking ssh connection to {ip_to_connect}.\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                        raise SSHConnectionFailure
                    else:
                        warning(f"Timeout while taking ssh connection to {ip_to_connect}.\n"
                                f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                else:
                    if print_to_eventlog:
                        info(f"Timeout while taking ssh connection to {ip_to_connect}. Try again.\n"
                             f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    else:
                        self.logger.debug(f"Timeout while taking ssh connection to {ip_to_connect}. Try again.\n"
                                          f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            except pexpect.EOF as e:
                if try_time == 10:
                    if raise_error:
                        error(f"End Of File (EOF) while taking ssh connection to {ip_to_connect}.\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                        raise SSHConnectionFailure
                    else:
                        warning(f"End Of File (EOF) while taking ssh connection to {ip_to_connect}.\n"
                                f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                else:
                    if print_to_eventlog:
                        info(f"End Of File (EOF) while taking ssh connection to {ip_to_connect}. Try again.\n"
                             f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    else:
                        self.logger.debug(f"End Of File (EOF) while taking ssh connection to {ip_to_connect}. "
                                          f"Try again\n"
                                          f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if not ssh_ok and try_time > 5:
                self.logger.debug("Wasn't able to create SSH connection in first 5 tries. Wait 60s before retrying.")
                BuiltIn().sleep("60s")
        return ssh_object

    def _special_prompt_to_wait(self, ssh_object, special_wait_prompt, catch_str_only, ssh_timeout):
        """
        Special prompt to wait

        :param instance ssh_object: Pexpect ssh connection object.
        :param str special_wait_prompt: Special prompt to wait for.
        :param bool catch_str_only: Default is False, if True will not recompile str to regex uses plain string matching
        :return str: Output from the special prompt.
        """
        self.logger.debug(f"Special prompt: {special_wait_prompt}")
        if catch_str_only:
            index = ssh_object.expect_exact([special_wait_prompt, pexpect.EOF, pexpect.TIMEOUT], timeout=ssh_timeout)
        else:
            index = ssh_object.expect([special_wait_prompt, pexpect.EOF, pexpect.TIMEOUT], timeout=ssh_timeout)
        if index == 0:
            self.logger.debug(f"Special prompt {special_wait_prompt} detected.")
        elif index == 1:
            self.logger.debug(f"Special prompt {special_wait_prompt} not detected. EOF detected.")
        elif index == 2:
            self.logger.debug(f"Special prompt {special_wait_prompt} not detected. TIMEOUT detected.")
        return str(ssh_object.before)

    def _send_command_to_ip(self, ssh_object, command, return_output, ssh_timeout, print_to_eventlog, raise_error, pw,
                            special_wait_prompt, delay_before_expect, retry_command, catch_str_only, try_time=0):
        """
        Send command to ssh object via ssh.

        :param instance ssh_object: Pexpect ssh connection object.
        :param command str/list command: Command to be given to the ssh connection.
        :param bool return_output: If True returns output.
        :param int ssh_timeout: Time to max wait for prompt after ssh commands.
        :param bool print_to_eventlog: Print input and output to eventlog if set to True.
        :param bool raise_error: Default True, if False will raise just warning.
        :param str pw: Password for ssh connection. Default is empty string.
        :param str special_wait_prompt: Special prompt to wait for. Default is None.
        :param int delay_before_expect: Delay before expect. Default is 0.
        :param bool retry_command: Default is True, if False will not retry command.
        :param bool catch_str_only: Default is False, if True will not recompile str to regex catch only string output.
        :param int try_time: Default 0, used for recursive call.
        """
        # TODO later we could merge send_command_to_ip and send_command_to_smod_by_ssh methods
        output = ""
        prompt_catched = False
        if print_to_eventlog:
            info("Sending command: {}".format(command))
        else:
            self.logger.debug("Sending command: {}".format(command))
        try:
            ssh_object.sendline(command)
            if delay_before_expect:
                time.sleep(delay_before_expect)
            if special_wait_prompt:
                output = self._special_prompt_to_wait(ssh_object, special_wait_prompt, catch_str_only, ssh_timeout)
            else:
                prompt_list = [r"test_repo.+:~\$\s*", r"ute@.+:~\$\s*", r"assword:", r"yes/no", pexpect.EOF,
                               pexpect.TIMEOUT]
                index = ssh_object.expect(prompt_list, timeout=ssh_timeout)
                self.logger.debug(f"Expect Index: {index}")
                if index == 0 or index < 4:
                    self.logger.debug(f"Prompt {prompt_list[index]} detected.Output:\n"
                                      f"{str(ssh_object.before)}")
                    prompt_catched = True
                if index == 3:
                    ssh_object.sendline("yes")
                    time.sleep(1)
                    index2 = ssh_object.expect(prompt_list, timeout=ssh_timeout)
                    if pw and index2 == 2:
                        ssh_object.sendline(pw)
                        time.sleep(1)
                        index3 = ssh_object.expect(prompt_list, timeout=ssh_timeout)
                        if index3 and index3 in range(0, len(prompt_list)):
                            self.logger.debug(f"Prompt after password {prompt_list[index3]} detected. Output:\n"
                                              f"{str(ssh_object.before)}")
                if index in (4, 5):
                    self.logger.debug(f"EOF or TIMEOUT detected while sending command {command}.\n{str(ssh_object)}")
        except pexpect.TIMEOUT as e:
            if raise_error:
                error(f"Timeout while sending command {command} (given timeout was {ssh_timeout}).\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            else:
                warning(f"Timeout while sending command {command} (given timeout was {ssh_timeout}).\n"
                        f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        except pexpect.EOF as e:
            if raise_error:
                error(f"End Of File (EOF) while sending command {command}.\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            else:
                warning(f"End Of File (EOF) while sending command {command}.\n"
                        f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        if not output:
            output = ssh_object.before
        if print_to_eventlog:
            info("SSH output: {}".format(output))
        else:
            self.logger.debug("SSH output: {}".format(output))
        BuiltIn().sleep("1s")
        if return_output:
            if not prompt_catched and retry_command and try_time < 4:
                try_time += 1
                self.logger.debug(f"Could not catch the prompt from SSH output. give the command ({command}) again "
                                  f"\n{str(ssh_object)}\n{try_time}. retry")
                self._send_command_to_ip(ssh_object, command, return_output, ssh_timeout, print_to_eventlog,
                                         raise_error, pw, special_wait_prompt, delay_before_expect, retry_command,
                                         catch_str_only, try_time=try_time)
            elif not prompt_catched and not retry_command and try_time < 3:
                try_time += 1
                self.logger.debug(f"Could not catch the prompt from SSH output. Try to sync pexpect.before by giving "
                                  f"command 'echo syncing...'\n{str(ssh_object)}\n{try_time}. retry")
                self._send_command_to_ip(ssh_object, 'echo syncing...', return_output, ssh_timeout, print_to_eventlog,
                                         raise_error, pw, special_wait_prompt, delay_before_expect, retry_command,
                                         catch_str_only, try_time=try_time)
            return output
        return None

    def _get_save_path(self):
        """Get save path"""
        save_path = self.logger.log_dir
        if not os.path.exists(self.logger.log_dir):
            if "/loop_" in save_path:
                save_path = SSHConnection._safe_split(save_path, "/loop_")[0]
                self.logger.debug(f"Folder {self.logger.log_dir} doesn't exists anymore, use test folder path to save "
                                  f"the ssh file: {save_path}")
        if not os.path.exists(save_path):
            self.logger.debug(f"Folder {save_path} doesn't exists anymore, use suite folder path to save the "
                              f"ssh file: {self.logger.suite_folder}")
            save_path = self.logger.suite_folder
        if not os.path.exists(f"{save_path}/ssh_logs"):
            self.logger.debug(f"Folder {save_path}/ssh_logs doesn't exists, create it.")
            os.makedirs(f"{save_path}/ssh_logs", exist_ok=True)
        return save_path

    def send_command_to_ip_by_ssh(self, command, ssh_object=None, return_output=False, ssh_timeout=60,
                                  print_to_eventlog=True, name_for_log="", ip_to_connect="", username="", pw="",
                                  special_wait_prompt=None, delay_before_expect=0, retry_command=True, raise_error=True,
                                  disconnect_ssh=True, catch_str_only=False):
        """
        With this method you can give ssh command to BTS or to other ssh object by using pexpect ssh connection. This
        allows for example child connection and scp to other units etc.

        :param command str/list command: Command/list of command to be given to the ip.
        :param object ssh_object: Pexpect ssh connection object. Default is None.
        :param bool return_output: Default is False, if True returns output.
        :param int ssh_timeout: Time to max wait for prompt after ssh commands.
        :param bool print_to_eventlog: Print input and output to eventlog if set to True. Default is True.
        :param str name_for_log: You can give name for the ssh log. For example ssh_lmp_swdl.
        :param str ip_to_connect: IP address to connect (OPTIONAL if ssh_object is given)
        :param str username: Username for ssh connection (OPTIONAL if ssh_object is given)
        :param str pw: Password for ssh connection. Default is empty string (OPTIONAL if ssh_object is given)
        :param bool raise_error: Default True, if False will raise just warning.
        :param str special_wait_prompt: Special prompt to wait for. Default is None.
        :param int delay_before_expect: Delay before expect. Default is 0.
        :param bool retry_command: Default is True, if False will not retry command.
        :param bool disconnect_ssh: Default True, if False will not disconnect ssh connection.
        :param bool catch_str_only: Default False, if True will catch only string from output, will not use regex.

        :raise ScriptIssue: If command is not str or list.
        :return str output_for_return: Output received from the command.
        """
        output_for_return = ""
        if not ssh_object:
            if not ip_to_connect or not username:
                if raise_error:
                    error("IP address or user name to connect ssh is not given.")
                    raise ScriptIssue("IP address or user name to connect SSH is not given.")
                else:
                    warning("IP address or user name to connect SSH is not given.")
                    return None
            ssh_object = self.ssh_connection_to_given_ip(user_name=username, ssh_password=pw,
                                                         ip_to_connect=ip_to_connect, name_for_log=name_for_log,
                                                         print_to_eventlog=print_to_eventlog, raise_error=raise_error)
        if isinstance(command, str):
            # if return_output: if no return in the method this will just be None
            output_for_return = self._send_command_to_ip(ssh_object, command, return_output, ssh_timeout,
                                                         print_to_eventlog, raise_error, pw=pw,
                                                         special_wait_prompt=special_wait_prompt,
                                                         delay_before_expect=delay_before_expect,
                                                         retry_command=retry_command, catch_str_only=catch_str_only)
        elif isinstance(command, list):
            for cmd in command:
                output = self._send_command_to_ip(ssh_object, cmd, return_output, ssh_timeout, print_to_eventlog,
                                                  raise_error, pw=pw, special_wait_prompt=special_wait_prompt,
                                                  delay_before_expect=delay_before_expect, retry_command=retry_command,
                                                  catch_str_only=catch_str_only)
                if return_output:  # if method does not return anything then it returns just None
                    output_for_return = output_for_return + output
        else:
            error(f"Command to send_command_to_ip_by_ssh method is expected to be str or list (command: '{command}'"
                  f"\ntype of command: {type(command)}).")
            raise ScriptIssue
        if print_to_eventlog:
            info("All command(s) are sent.")
        if disconnect_ssh:
            self.disconnect_ssh_connection(ssh_object, print_to_eventlog=print_to_eventlog)
        if return_output:
            return output_for_return
        return None

    def connect_to_smod_interface_soc(self, enb_ssh, use_lxc_attach=False, node="", lxc_hex="0x1014"):
        """
        Connect to smod interface soc

        :param enb_ssh: ssh object
        :param bool use_lxc_attach: default is false
        :param str node: Node to which to do lxc attach. Default empty
        :param str lxc_hex: Hex to do lxc-attach, default value is 0x1014
        """
        soc_ssh_prompt = re.compile(r"asc-0b")
        if use_lxc_attach:
            soc_ssh_prompt = re.compile(r"\w+NODE\d\d") if not node else re.compile(f"{node}")
            try:
                enb_ssh.sendline(f"lxc-attach -n {lxc_hex}")
                enb_ssh.expect(soc_ssh_prompt, timeout=60)
            except pexpect.TIMEOUT as e:
                error(f"Timeout while sending command 'lxc-attach -n {lxc_hex}' (given timeout was 60).\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            else:
                return enb_ssh
        else:
            try:
                enb_ssh.sendline("ssh toor4nsn@fct0s1icom")
                index = enb_ssh.expect(["(.+)(yes/no)|(Please type 'yes', 'no')", "(.+)assword:", ":~ >", ":~#",
                                        "AaShell>", pexpect.EOF], timeout=60)
                if index == 0:
                    enb_ssh.sendline("yes")
                    enb_ssh.expect("(.+)assword:", timeout=60)
                    self.logger.debug("'Password:' prompt detected, about to enter password oZPS0POrRieRtu")
                    enb_ssh.sendline("oZPS0POrRieRtu")
                    enb_ssh.expect(soc_ssh_prompt, timeout=60)
                    self.logger.debug("Password entered, waiting for command prompt")
                elif index == 1:
                    self.logger.debug("'Password:' prompt detected, about to enter password oZPS0POrRieRtu")
                    enb_ssh.sendline("oZPS0POrRieRtu")
                    enb_ssh.expect(soc_ssh_prompt, timeout=60)
                    self.logger.debug("Password entered, waiting for command prompt")
                elif index in (2, 3, 4, 5):
                    self.logger.debug("No yes nor password asked, index {}".format(index))
            except pexpect.TIMEOUT as e:
                error(f"Timeout while sending command 'ssh toor4nsn@fct0s1icom' (given timeout was 60).\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            else:
                return enb_ssh

    def send_command_to_fsp_by_ssh(self, fsp_ssh, command, ssh_timeout=60):
        """
        With this method you can give ssh command to FSP by using pexpect ssh connection.

        :param instance fsp_ssh: Pexpect ssh connection object.
        :param command str/list command: Command to be given to FSP or list of commands to be given.
        :param int ssh_timeout: Time to max wait for prompt after ssh commands.

        :return str output: Output received from the command.
        """
        output = ""
        if isinstance(command, str):
            output = self._send_command_to_fsp(fsp_ssh, command, ssh_timeout)
        elif isinstance(command, list):
            for cmd in command:
                o = self._send_command_to_fsp(fsp_ssh, cmd, ssh_timeout)
                output = output + o
        else:
            error(f"Command to send_command_to_fsp_by_ssh method is expected to be str or list (command {command}).")
            raise ScriptIssue
        return output

    def get_smod2_ip(self, check_side, master_is_right_side, ssh_object, print_to_eventlog):
        """
        Get smod2 ip
        :param bool check_side: If true checks with ddal_sysinfo_module_get_domain_id the side
        :param bool master_is_right_side: If True and check_side=False side will be decided byt this value.
                                          If check_side is True then this parameter doesn't matter.
        :param ssh_object: ssh object to use when check_side is True.
        :param bool print_to_eventlog: If true prints to evenlog else to debug
        """
        smod2_ip = "fct-4a"
        if check_side:
            command = "ddal -s ddal_sysinfo_module_get_domain_id 0"
            output = self.send_command_to_smod_by_ssh(command, enb_ssh=ssh_object, return_output=True,
                                                      print_to_eventlog=False, disconnect_ssh=False)
            if output:
                if "dimd=2" in output or "dmid=2" in output:
                    if print_to_eventlog:
                        info("Primary SMOD is on right side, secondary SMOD is fct-0a")
                    smod2_ip = "fct-0a"
                else:
                    info("Primary SMOD is on left side, secondary SMOD is fct-4a")
        else:
            if master_is_right_side:
                smod2_ip = "fct-0a"
        return smod2_ip

    def _ssh_object_to_master_smod(self, name_for_log):
        ip = "192.168.255.129"
        if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
            ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
        other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
        if other_master:
            ip = remote_mplane_ip
        self.delete_known_host_file()
        ssh_object = self.ssh_connection_to_given_ip(user_name="toor4nsn", ssh_password="oZPS0POrRieRtu",
                                                     ip_to_connect=ip, name_for_log=name_for_log,
                                                     print_to_eventlog=False, raise_error=False)
        return ssh_object

    def send_command_to_ssh_object(self, ssh_object, command, special_prompt=None, ssh_timeout=60):
        """
        Send command to ssh object.
        :param ssh_object: pexpect object to unit
        :param str command: Command to be sent to ssh object.
        :param str special_prompt: Text for prompt.
        :param int ssh_timeout: Timeout for command, default is 60s.
        """
        return_txt = ""
        output = ""
        ssh_prompt = re.compile(r"(?m)(?:^(?:[A-Za-z0-9._-]+@[A-Za-z0-9._-]+)?:~(?: >)?\s*\r?$|^AaShell>\s*\r?$)")
        try:
            if special_prompt:
                ssh_prompt = re.compile(special_prompt)
            if ssh_object and ssh_object.isalive():
                ssh_object.sendline(command)
                index = ssh_object.expect(["(.+)(yes/no)|(Please type 'yes', 'no')", "(.+)assword:",
                                           "kex_exchange_identification.*Connection closed by", "No route to host",
                                           ssh_prompt], timeout=ssh_timeout)
                if index == 0:
                    ssh_object.sendline("yes")
                    ssh_object.expect("assword:", timeout=ssh_timeout)
                    ssh_object.sendline("oZPS0POrRieRtu")
                    ssh_object.expect(ssh_prompt, timeout=ssh_timeout)
                elif index == 1:
                    ssh_object.sendline("oZPS0POrRieRtu")
                    ssh_object.expect(ssh_prompt, timeout=ssh_timeout)
                elif index == 2:
                    return_txt = "kex_exchange_identification"
                elif index == 3:
                    return_txt = 'No route to host'
                else:
                    self.logger.debug("No yes nor password asked, index {}".format(index))
                output = ssh_object.before
            else:
                return_txt = "SSH objet is not alive"
        except pexpect.TIMEOUT as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return_txt = f"Timeout while sending command '{command}' (given timeout was {ssh_timeout})."
            print(return_txt)
        except pexpect.EOF as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return_txt = f"EOF while sending command '{command}'."
            print(return_txt)
        return return_txt, output

    def connect_to_secondary_smod(self, ssh_object, master_is_right_side=False, check_side=False,
                                  print_to_eventlog=True, name_for_log="secondary_smod"):
        """
        Connect to secondary smod. This is needed for example when we want to connect to extension SMOD by ssh.
        :param ssh_object: Pexpect ssh connection object.
        :param bool check_side: If True checks the side of master smod.
        :param bool master_is_right_side: If true master is left and secondary is right
        :param bool print_to_eventlog: If True prints to evenlog.
        :param str name_for_log: Name for log. Default is secondary_smod
        """
        if not ssh_object:
            ssh_object = self._ssh_object_to_master_smod(name_for_log=name_for_log)
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        try:
            smod2_ip = self.get_smod2_ip(check_side, master_is_right_side, ssh_object, print_to_eventlog)
            if print_to_eventlog:
                info(f"Create SSH connection to secondary SMOD (with command: ssh toor4nsn@{smod2_ip})")
            else:
                self.logger.debug(f"Create SSH connection to secondary SMOD (with command: ssh toor4nsn@{smod2_ip})")
                print(f"Create SSH connection to secondary SMOD (with command: ssh toor4nsn@{smod2_ip})")
            return_txt, output = self.send_command_to_ssh_object(ssh_object, "rm /user/toor4nsn/.ssh/known_hosts")
            for try_time in range(1, 4):
                return_txt, output = self.send_command_to_ssh_object(ssh_object, f"ssh toor4nsn@{smod2_ip}")
                if not return_txt:
                    break
                elif "kex_exchange_identification" in return_txt:
                    info("kex_exchange_identification problems when taking ssh connection to secondary SMOD. Wait "
                         "5min and try again.")
                    BuiltIn().Sleep(300)
                elif "No route" in return_txt:
                    error("Unable to create ssh connection there is 'No route to to host' in response. Check used IP.")
                    break
                elif "SSH objet is not alive" in return_txt:
                    info("SSH object was not alive when trying to create ssh connection to remote SMOD. Wait 5min and "
                         "create new connection to master smod and try again.")
                    BuiltIn().Sleep(300)
                    ssh_object = self._ssh_object_to_master_smod(name_for_log=name_for_log)
            if not return_txt:  # no errors
                if print_to_eventlog:
                    info("SSH connection to secondary SMOD successfully created.")
                else:
                    self.logger.debug("SSH connection to secondary SMOD successfully created.")
                return ssh_object
            else:
                info(f"{loop}Unable to create ssh connection to secondary SMOD (command: ssh toor4nsn@{smod2_ip})")
        except Exception as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"Exception while trying to create ssh connection to secondary smod. {e.__class__.__name__}: {e}")
        return None

    def send_command_to_secondary_smod_by_ssh(self, command, ssh_object=None, master_is_right_side=False,
                                              check_side=True, return_output=False, ssh_timeout=60,
                                              print_to_eventlog=True, raise_error=True, disconnect_ssh=True,
                                              return_ssh_object=False, name_for_log="secondary_smod"):
        """
        Send command to secondary smod by ssh.

        :param command str/list command: Command or list of commands to be given to secondary SMOD.
        :param ssh_object: Pexpect ssh connection object. If not given, will try to connect to master SMOD and from
                                                          there to secondary SMOD.
        :param bool master_is_right_side: If true master is right and secondary is left. This is needed when check_side
                                          is False.
        :param bool check_side: If True checks the side of master smod by command
                                "ddal -s ddal_sysinfo_module_get_domain_id 0". Default is True.
        :param bool return_output: Default is False, if True returns output.
        :param int ssh_timeout: Time to max wait for prompt after ssh commands.
        :param bool print_to_eventlog: Print input and output to eventlog if set to True. Default is True.
        :param bool raise_error: Default True, if False will raise just warning.
        :param bool disconnect_ssh: Default True, if False will not disconnect ssh connection.
        :param bool return_ssh_object: If True returns ssh_object.
        :param str name_for_log: Name for log. Default is secondary_smod.
        :raise ScriptIssue: If command is not str or list.
        :return str output_for_return: Output received from the command.
        """
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        output_for_return = ""
        return_txt = ""
        if not ssh_object:
            ssh_object = self.connect_to_secondary_smod(ssh_object, master_is_right_side=master_is_right_side,
                                                        check_side=check_side, print_to_eventlog=print_to_eventlog,
                                                        name_for_log=name_for_log)
        if not ssh_object:
            if raise_error:
                error("SSH connection to secondary SMOD failed. Cannot send command(s) to secondary SMOD.")
                raise ScriptIssue("Unable to create ssh connection to secondary SMOD")
            else:
                warning("SSH connection to secondary SMOD failed. Cannot send command(s) to secondary SMOD.")
                return None
        if isinstance(command, str):
            command = [command]
        if not isinstance(command, list):
            error(f"Command to send_command_to_secondary_smod_by_ssh method is expected to be str or list (command "
                  f"{command}).")
            raise ScriptIssue(f"{loop}Wrong type of command, expected str or list but got {type(command)}")
        for cmd in command:
            if print_to_eventlog:
                info(f"Give command '{cmd}' to secondary SMOD.")
            else:
                self.logger.debug(f"Give command '{cmd}' to secondary SMOD.")
            for try_time in range(1,  4):  # try to send the command max 3 times
                return_txt, output = self.send_command_to_ssh_object(ssh_object, cmd, ssh_timeout=ssh_timeout)
                if not return_txt:
                    if print_to_eventlog:
                        info(f"SSH output: {output}")
                    else:
                        self.logger.debug(f"SSH output: {output}")
                    output_for_return = output_for_return + output
                    break
                elif "kex_exchange_identification" in return_txt:
                    info(f"kex_exchange_identification problems when giving command {cmd}. Wait 5min and try again.")
                    BuiltIn().Sleep(300)
                elif "No route" in return_txt:
                    info("'No route to to host' in ssh response. Check used IP and network.")
                    break
                elif "SSH objet is not alive" in return_txt:
                    info(f"SSH object was not alive when trying to give {cmd}. Wait 5min and create new connection to "
                         f"master smod and secondary smod and try again.")
                    BuiltIn().Sleep(300)
                    ssh_object = self.connect_to_secondary_smod(ssh_object, master_is_right_side=master_is_right_side,
                                                                check_side=check_side,
                                                                print_to_eventlog=print_to_eventlog,
                                                                name_for_log=name_for_log)
            if return_txt:
                error(f"{loop}Problems to send command '{cmd}' to secondary SMOD: {return_txt}")
        if print_to_eventlog:
            info("All command(s) sent to secondary SMOD.")
        else:
            self.logger.debug("All command(s) sent to secondary SMOD.")
        if disconnect_ssh:
            self.disconnect_ssh_connection(ssh_object, print_to_eventlog=print_to_eventlog)
        if return_output and return_ssh_object:
            return output_for_return, ssh_object
        if return_output:
            return output_for_return
        if return_ssh_object:
            return ssh_object
        return None

    def connect_to_fsp(self, enb_ssh, fsp_ip, fsp_user, known_hosts=True, save_to_own_file=True):
        """
        Connect to FSP via ssh.
        :param instance enb_ssh: Pexpect ssh connection object.
        :param str fsp_ip: FSP IP address.
        :param str fsp_user: FSP username.
        :param bool known_hosts: If True, remove known_hosts file from SMOD before taking ssh connection to BBMOD.
                                 Default is True.
        :param bool save_to_own_file: If True, saves ssh log to own file. Default is True.
        :return instance: Returns Pexpect ssh connection object to FSP.
        """
        if save_to_own_file:
            save_path = self.logger.log_dir
            if not os.path.exists(self.logger.log_dir):
                save_path = SSHConnection._safe_split(save_path, "/loop_")[0]
                self.logger.debug(f"Folder {self.logger.log_dir} doesn't exist anymore, use test folder path to save "
                                  f"the ssh file: {save_path}")
            if not os.path.exists(save_path):
                self.logger.debug(f"Folder {save_path} doesn't exist anymore, use suite folder path to save the "
                                  f"ssh file: {self.logger.suite_folder}")
                save_path = self.logger.suite_folder
            if not os.path.exists(f"{save_path}/ssh_logs"):
                self.logger.debug(f"Folder {save_path}/ssh_logs doesn't exists, create it.")
                os.makedirs(f"{save_path}/ssh_logs", exist_ok=True)
            save_path = f"{save_path}/ssh_logs"
            self.logger.debug(f"Save ssh logs to folder {save_path}.")
            pexpect_log_file_path = os.path.join(save_path, f"fsp_ssh_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log")
            self.logger.debug("Log file path: {}".format(pexpect_log_file_path))
            self.pexpect_log = open(pexpect_log_file_path, 'a')
        if not enb_ssh or not enb_ssh.isalive():
            warning("SSH connection to SMOD is not alive. Cannot connect to FSP. Try to reconnect to SMOD before"
                    "connecting to FSP.")
            enb_ssh = self.ssh_connection_to_smod()

        if known_hosts:
            self.logger.debug("Remove known_hosts file from SMOD before taking ssh connection to radio. Used command:"
                              " rm /user/toor4nsn/.ssh/known_hosts")
            enb_ssh.sendline("rm /user/toor4nsn/.ssh/known_hosts")
        fsp_ssh_prompt = re.compile(r"(:~ >|AaShell>|:~#)")
        command = f"ssh {fsp_user}@{fsp_ip}"

        def create_connection():
            try:
                enb_ssh.sendline(command)
                index = enb_ssh.expect(["(.+)(yes/no)|(Please type 'yes', 'no')", "(.+)assword:",
                                        "Host key verification failed", ":~ >", ":~#", "AaShell>",
                                        pexpect.EOF], timeout=60)
                if index == 0:
                    enb_ssh.sendline("yes")
                    enb_ssh.expect("(.+)assword:", timeout=60)
                    self.logger.debug("'Password:' prompt detected, about to enter password oZPS0POrRieRtu")
                    enb_ssh.sendline("oZPS0POrRieRtu")
                    enb_ssh.expect(fsp_ssh_prompt, timeout=60)
                    self.logger.debug("Password entered, waiting for command prompt")
                elif index == 1:
                    self.logger.debug("'Password:' prompt detected, about to enter password oZPS0POrRieRtu")
                    enb_ssh.sendline("oZPS0POrRieRtu")
                    enb_ssh.expect(fsp_ssh_prompt, timeout=60)
                    self.logger.debug("Password entered, waiting for command prompt")
                elif index == 2:
                    self.logger.debug("Remove known_hosts file")
                    enb_ssh.sendline("rm /user/toor4nsn/.ssh/known_hosts")
                    enb_ssh.expect(fsp_ssh_prompt, timeout=60)
                elif index in (3, 4, 5, 6):
                    self.logger.debug("No yes nor password asked, index {}".format(index))
            except pexpect.TIMEOUT as e:
                error(f"Timeout while sending command {command} (given timeout was 60)."
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            self.logger.debug(f"Output from ssh login attempt: {enb_ssh.before}\n")
            if "fsp" in enb_ssh.before or "asp" in enb_ssh.before or "Last login" in enb_ssh.before:
                return True
            return False

        attempt_counter = 0
        connected = False
        while attempt_counter < 60 and not connected:
            connected = create_connection()
            attempt_counter += 1
            BuiltIn().sleep("2s")
        if connected:
            info(f"SSH connection to {fsp_ip} successfully established.")
        else:
            error(f"Failed to create SSH connection to {fsp_ip}.")
            raise SSHConnectionFailure(f"Failed to create SSH connection to {fsp_ip}.")
        return enb_ssh  # = fsp_ssh

    def _send_command_to_fsp(self, fsp_ssh, command, ssh_timeout):
        """
        Send command to FSP via ssh.

        :param instance fsp_ssh: Pexpect ssh connection object.
        :param command str/list command: Command to be given to FSP.
        :param int ssh_timeout: Time to max wait for prompt after ssh commands.
        """
        self.logger.debug("Sending command: {}".format(command))
        fsp_ssh_prompt = re.compile(r"(:~ >|:~#)")
        try:
            fsp_ssh.sendline(command)
            fsp_ssh.expect(fsp_ssh_prompt, timeout=ssh_timeout)
        except pexpect.TIMEOUT as e:
            error(f"Timeout while sending command {command} (given timeout was {ssh_timeout}).\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        output = fsp_ssh.before
        self.logger.debug(f"FSP SSH output: {output}")
        BuiltIn().sleep("5s")
        return output

    def _ssh_was_lost_unexpectedly_do_reconnect(self, try_time, enb_ssh_prompt, ssh_timeout):
        """ssh was lost unexpectedly do reconnect"""
        self.logger.debug("In ssh: 'kex_exchange_identification: Connection closed by remote host' was"
                          " found. Reconnect the ssh connection.")
        if try_time == 2:
            self.logger.debug("Huge SSH problems. Try to disconnect all created ssh connections before creating new.")
            print("Huge SSH problems. Try to disconnect all created ssh connections before creating new.")
            self.close_all_ssh_connections()
            self.delete_known_host_file()
        enb_ssh = self.ssh_connection_to_smod(name_for_log=f"retry_{try_time}_to_smod")
        self.logger.debug(
            "Remove known_hosts file from SMOD. Used command: rm /user/toor4nsn/.ssh/known_hosts")
        enb_ssh.sendline("rm /user/toor4nsn/.ssh/known_hosts")
        enb_ssh.expect(enb_ssh_prompt, timeout=ssh_timeout)
        return enb_ssh

    def _send_command_return_outputs_and_kex(self, enb_ssh, command, enb_ssh_prompt, ssh_timeout, loop):
        """
        Send command return outputs and kex
        """
        return_text = ""
        kex_exchange_problem = False
        self.logger.debug("Send command: {}".format(command))
        try:
            enb_ssh.sendline(command)
            index = enb_ssh.expect(["yes/no", "assword:", "kex_exchange_identification.*Connection closed by", ":~ >",
                                    ":~#", "asp-..:", "AaShell>", pexpect.EOF], timeout=ssh_timeout)
            if index == 0:
                enb_ssh.sendline("yes")
                enb_ssh.expect("assword:", timeout=ssh_timeout)
                enb_ssh.sendline("oZPS0POrRieRtu")
                enb_ssh.expect(enb_ssh_prompt, timeout=ssh_timeout)
            elif index == 1:
                enb_ssh.sendline("oZPS0POrRieRtu")
                enb_ssh.expect(enb_ssh_prompt, timeout=ssh_timeout)
            elif index == 2:
                kex_exchange_problem = True
                return_text = (f"{loop}'kex_exchange_identification: Connection closed by remote host' is found from "
                               f"the SMOD connection try. (Content of ssh.read():\n{enb_ssh.read()}).")
            elif index in (3, 4, 5, 6):
                self.logger.debug("No yes nor password asked, index {}".format(index))
            else:
                return_text = (f"{loop}Problems sending command {command} by ssh to SMOD. Check if prompts are correct"
                               f" (yes/no, assword:, kex_exchange_identification.*Connection closed, :~ >, :~#, "
                               f"asp-..:, AaShell>). \n(ssh.read():\n{enb_ssh.read()}).")
        except pexpect.TIMEOUT as e:
            return_text = (f"{loop}Timeout while sending command {command} (given timeout was {ssh_timeout}.\n"
                           f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        except pexpect.EOF as e:
            return_text = (f"{loop}End Of File (EOF) while sending command {command}.\n"
                           f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        BuiltIn().sleep("1s")
        output = enb_ssh.before
        self.logger.debug(f"SSH output: {output}")
        return output, return_text, kex_exchange_problem

    def _check_if_enb_ssh_object_exist_or_isalive_if_not_delete(self, enb_ssh, loop, try_time):
        """Check if enb_ssh object exist or isalive if not delete and reconnect"""
        if not enb_ssh or not enb_ssh.isalive():  # ssh connection has been lost
            info(f"{loop}SSH problems, enb_ssh object is not alive anymore. Disconnect all, wait and try to "
                 f"reconnect. Try time is {try_time}.")
            self.logger.debug(f"{loop}SSH problems, enb_ssh is no alive. Try to disconnect all created, possible "
                              f"hanging ssh connections, before creating new. Try time is {try_time}.")
            print(f"{loop}SSH problems, enb_ssh is no alive. Try to disconnect all created ssh connections, possible "
                  f"hanging ssh connections, before creating new. Try time is {try_time}.")
            self.close_all_ssh_connections()
            self.delete_known_host_file()
            if try_time == 3:
                BuiltIn().sleep("61s")
            else:
                BuiltIn().sleep("5s")
            enb_ssh = self.ssh_connection_to_smod()
        return enb_ssh

    def _send_command_to_smod(self, enb_ssh, command, return_output, ssh_timeout, print_to_eventlog, raise_error):
        """
        Send command to smod via ssh.

        :param instance enb_ssh: Pexpect ssh connection object.
        :param command str/list command: Command to be given to SMOD.
        :param bool return_output: If True returns output.
        :param int ssh_timeout: Time to max wait for prompt after ssh commands.
        :param bool print_to_eventlog: Print input and output to eventlog if set to True.
        :param bool raise_error: Default True, if False will raise just warning.
        """
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        # enb_ssh_prompt = re.compile(r"(:~ >|AaShell>|:~#|asp-..:|tmp#|:~.|\$|#|> )")
        enb_ssh_prompt = re.compile(
            r"(?m)^(?:"
            r"(?:[A-Za-z0-9._-]+@[A-Za-z0-9._-]+:)?:~(?: >|#)?"
            r"|AaShell>"
            r"|asp-[A-Za-z0-9]{2}:"
            r"|tmp#"
            r"|\$"
            r"|#"
            r"|>"
            r")\s*\r?$"
        )
        try_time = 0
        if print_to_eventlog:
            info("Send command: {}".format(command))
        output, return_text, kex_exchange_problem = self._send_command_return_outputs_and_kex(
            enb_ssh, command, enb_ssh_prompt, ssh_timeout, loop)
        if not output or (output and "kex_exchange_identification: Connection closed" in output):
            if return_text:
                print(return_text)
                self.logger.debug(return_text)
            for try_time in range(1, 5):
                if kex_exchange_problem:
                    enb_ssh = self._ssh_was_lost_unexpectedly_do_reconnect(try_time, enb_ssh_prompt, ssh_timeout)
                output, return_text, kex_exchange_problem = self._send_command_return_outputs_and_kex(
                    enb_ssh, command, enb_ssh_prompt, ssh_timeout, loop)
                if return_text:
                    print(return_text)
                    self.logger.debug(return_text)
                if not kex_exchange_problem and ((return_output and output) or (not return_output)):
                    break
                enb_ssh = self._check_if_enb_ssh_object_exist_or_isalive_if_not_delete(enb_ssh, loop, try_time)
        if print_to_eventlog:
            info("SSH output: {}".format(output))
        if try_time == 4:
            if return_text:
                error(return_text) if raise_error else warning(return_text)
            else:
                info("Command has been given multiple times, but no output get. Check ssh logs if there are some "
                     "problems.")
        if return_output:
            return output
        return None

    def _give_password_check_radio_credentials(self, enb_ssh, radio_prompt, radio_object, radio_user, radio_password):
        try:
            enb_ssh.sendline(radio_password)
            enb_ssh.expect(radio_prompt, timeout=30)
            self.logger.debug("Password is successfully given.")
            return enb_ssh
        except pexpect.TIMEOUT as e:
            if "Permission denied" in str(enb_ssh.before):
                error(
                    f"Username '{radio_user}', password '{radio_password}' or both are wrong for "
                    f"{radio_object.name}. Take contact to script developer to add correct credentials.\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                raise ScriptIssue
            elif "Host key verification failed" in str(enb_ssh.before):
                error(f"Removing file /user/toor4nsn/.ssh/known_hosts should help to get rid of this. Take contact to "
                      f"script developer to check where the problem is.\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                raise ScriptIssue
        except pexpect.EOF as eof:
            error(f"End Of File (EOF) while giving password to radio {radio_object.name}.\n"
                  f"{''.join(format_exception(type(eof), eof, eof.__traceback__))}")
            raise ScriptIssue
        except Exception as ex:
            error(f"Exception while giving password to radio {radio_object.name}.\n"
                  f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            raise ScriptIssue

    def send_command_to_radio_by_ssh(self, radio_object, command, enb_ssh=None, expect_output=True,
                                     return_output=False, print_to_eventlog=True, raise_error=True,
                                     ignore_expect=False, disconnect_ssh=True, remove_known_hosts=True,
                                     ssh_connection_to_radio=True, set_dumb_term=False, return_ssh_object=False):
        """
        Send command(s) to radio by ssh connection.

        :param obj radio_object: Radio object (from BTS.py).
        :param str/list command: Command(s) to be sent to radio.
        :param obj enb_ssh: Pexpect ssh connection object. Default is None.
        :param bool expect_output: Default is True. If set False output for command is not required, usable for example
                                   if connection to radio is lost with the command and prompt is not seen.
        :param bool return_output: Default is False, if set to True returns output of SSH command as string.
        :param bool print_to_eventlog: Default is True. If set to False doesn't print commands and outputs to eventlog.
        :param bool raise_error: Default True, if False will raise just warning.
        :param bool ignore_expect: Default False, if set to True will ignore expect output. Useful e.g. for multiline
                                   output
        :param bool disconnect_ssh: Default True, if False will not disconnect ssh connection after command.
        :param bool remove_known_hosts: Default True, if set to True will remove known_hosts file from SMOD before
                                        taking ssh connection to radio.
        :param bool ssh_connection_to_radio: Default True, if set to True will take ssh connection to radio, if False
                                             expects that ssh connection to radio is already taken and given as
                                             parameter enb_ssh.
        :param bool set_dumb_term: If True reduce escape output from remote shell (TERM=dumb, disable fancy prompt/color
                                   , non-interactive mode)
        :param bool return_ssh_object: Default false, if True will return ssh object.
        :return str output: Output of the command if return_output is set to True, otherwise None.
        """
        output = ""
        if not radio_object:
            error("Radio object is not given.")
            raise ScriptIssue("No radio object is given.")
        rmod_info = RMODLoginInfo.get_rmod(radio_object.name)
        rname = radio_object.name
        rname = rname[:rname.find("(")].lower()
        try:
            if enb_ssh is None:
                rmod_log_name = f"to_{radio_object.name.replace('.', '').replace('(', '').replace(')', '')}"
                enb_ssh = self.ssh_connection_to_smod_ltx_attach(
                    rmod_log_name, print_to_eventlog=print_to_eventlog, raise_error=raise_error)
                ssh_connection_to_radio = True
            radio_prompt = re.compile(r"(?m)(?:^\$\s*\r?$|^>\s*\r?$|^(?:[A-Za-z0-9._-]+@[A-Za-z0-9._-]+)?:~("
                                      r"?: >)?\s*\r?$|^-{}\s*\r?$)".format(re.escape(rname)))
            if remove_known_hosts:
                self.logger.debug("Remove known_hosts file from SMOD before taking ssh connection to radio. Used "
                                  "command: rm /user/toor4nsn/.ssh/known_hosts")
                enb_ssh.sendline("rm /user/toor4nsn/.ssh/known_hosts")
                enb_ssh.expect(radio_prompt, timeout=60)
            ssh_ok = False
            try_time = 0
            while try_time < 25 and ssh_ok is False:
                try_time += 1
                if ssh_connection_to_radio:
                    if print_to_eventlog:
                        info(f"Take ssh connection to {radio_object.name} with command: "
                             f"ssh {rmod_info['user_name']}@{radio_object.ip}  ({try_time}. try)")
                    else:
                        self.logger.debug(f"Take ssh connection to {radio_object.name} with command: "
                                          f"ssh {rmod_info['user_name']}@{radio_object.ip}")
                    if set_dumb_term:
                        enb_ssh.sendline(rf"TERM=dumb ssh {rmod_info['user_name']}@{radio_object.ip}")
                    else:
                        enb_ssh.sendline(rf"ssh {rmod_info['user_name']}@{radio_object.ip}")
                    index = enb_ssh.expect(["yes/no", "assword:", pexpect.EOF, pexpect.TIMEOUT], timeout=30)
                    if index == 0:
                        self.logger.debug("Giving yes to ssh connection to radio.")
                        enb_ssh.sendline("yes")  # there may be password asking after yes or not, depends on radio
                        index2 = enb_ssh.expect(["assword:", pexpect.EOF, pexpect.TIMEOUT, rname], timeout=30)
                        if index2 == 0:
                            self.logger.debug("Giving password to ssh connection to radio.")
                            enb_ssh = self._give_password_check_radio_credentials(
                                enb_ssh, radio_prompt, radio_object, rmod_info['user_name'], rmod_info['password'])
                        elif index2 == 2:
                            self.logger.debug("TIMEOUT, after giving yes when taking ssh connection to radio. Most "
                                              "likely this radio type doesn't have any password asking. Check logs.")
                        else:
                            self.logger.debug(f"INDEX after yes: {index2}")
                    elif index == 1:
                        enb_ssh = self._give_password_check_radio_credentials(
                            enb_ssh, radio_prompt, radio_object, rmod_info['user_name'], rmod_info['password'])
                    else:
                        self.logger.debug(f"INDEX: {index}")
                    self.logger.debug(f"Output after ssh to radio {radio_object.name}: {enb_ssh.before}")
                    if (str(rmod_info['user_name']) in str(enb_ssh.before) or rname.lower() in str(enb_ssh.before) or
                            rname.lower() in str(enb_ssh.after) or str(rmod_info['user_name']) in str(enb_ssh.after)):
                        if print_to_eventlog:
                            info(f"SSH connection to {radio_object.name} is successfully established")
                        else:
                            self.logger.debug(f"SSH connection to {radio_object.name} is successfully established")
                        ssh_ok = True
                    else:
                        if try_time == 24:
                            if raise_error:
                                error(f"The user {rmod_info['user_name']} was not found from the output of radio ssh. "
                                      f"Check that user & password for this radio type are correct and that used radio "
                                      f"prompt regex is ok for this radio type {radio_prompt}")
                                raise ScriptIssue
                            else:
                                warning(f"The user {rmod_info['user_name']} was not found from the output of radio ssh."
                                        f" Check that user & password for this radio type are correct and that used "
                                        f"radio prompt regex is ok for this radio type {radio_prompt}")
                        else:
                            info(f"SSH connection to {radio_object.name} was not successful, try again in 5s.")
                            BuiltIn().sleep("5s")
            if ignore_expect:
                radio_prompt = re.compile(r"($\s*)", re.MULTILINE)
            output, enb_ssh = self._send_commands_to_radio(
                enb_ssh, command, radio_object, radio_prompt, expect_output=expect_output,
                return_output=return_output, print_to_eventlog=print_to_eventlog, ignore_expect=ignore_expect)
            self.logger.debug("Command(s) sent.")
            if return_output and return_ssh_object:
                return output, enb_ssh
            if return_output:
                return output
            if return_ssh_object:
                return enb_ssh
        except Exception as e:
            error(f"Unexpected error while sending command(s) {command} to radio {radio_object.name}. "
                  f"{e.__class__.__name__}: {e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise EnvironmentIssue
        finally:
            if disconnect_ssh:
                if enb_ssh:
                    self.disconnect_ssh_connection(enb_ssh)

    def _command_to_radio(self, enb_ssh, command, radio_object, radio_ssh_prompt, expect_output=True,
                          return_output=False, print_to_eventlog=True, ignore_expect=False):
        """
        Send command to radio. Commands can be telnet or ssh commands.

        :param obj radio_object: Radio object (from BTS.py).
        :param obj enb_ssh: Pexpect ssh connection object to smod.
        :param str command: Command to be sent to radio.
        :param str radio_ssh_prompt: String to wait after giving command.
        :param bool expect_output: Default is True. If set False output for command is not required, usable for example
                                   if connection to radio is lost with the command and prompt is not seen.
        :param bool return_output: Default is False, if set to True returns output
        :param bool print_to_eventlog: Default is True. If set to False doesn't print commands and outputs to eventlog.
        :param bool ignore_expect: Default False, if set to True will ignore expected output and collect all the output.
        """
        try:
            if print_to_eventlog:
                info("Send command: {}".format(command))
            else:
                self.logger.debug("Send command: {}".format(command))
            enb_ssh.sendline(command)
            if ignore_expect:
                enb_ssh.expect([pexpect.TIMEOUT, radio_ssh_prompt], timeout=3)
            else:
                index = enb_ssh.expect(["yes/no", "assword:", radio_ssh_prompt, pexpect.EOF, pexpect.TIMEOUT],
                                       timeout=60)
                if index == 0:
                    rmod_info = RMODLoginInfo.get_rmod(radio_object.name)
                    enb_ssh.sendline("yes")
                    enb_ssh.expect("assword:", timeout=60)
                    self.logger.debug(f"'Password:' prompt detected, about to enter password {rmod_info['password']}")
                    enb_ssh.sendline(f"{rmod_info['password']}")
                    self.logger.debug("Password entered, waiting for command prompt")
                    enb_ssh.expect(radio_ssh_prompt, timeout=60)
                    self.logger.debug("Command prompt detected. SSH Login successful.")
                elif index == 1:
                    rmod_info = RMODLoginInfo.get_rmod(radio_object.name)
                    self.logger.debug(f"'Password:' prompt detected, about to enter password {rmod_info['password']}")
                    enb_ssh.sendline(f"{rmod_info['password']}")
                    self.logger.debug("Password entered, waiting for command prompt")
                    enb_ssh.expect(radio_ssh_prompt, timeout=60)
                    self.logger.debug("Command prompt detected. SSH Login successful.")
                elif index == 2:
                    self.logger.debug(f"Command prompt detected without asking yes or password. Index: {index}")
                elif index in (3, 4):
                    self.logger.debug(f"Problems with giving commands to radio. Index: {index}")
                # enb_ssh.expect(radio_ssh_prompt, timeout=60)
            output = enb_ssh.before
            if output and "not found" in str(output):
                if "reboot" in command:
                    info(f"{radio_object.name} doesn't have 'reboot' command, try to give command 'pssreboot por'")
                    enb_ssh.sendline("pssreboot por")
                    enb_ssh.expect(radio_ssh_prompt, timeout=60)
                    output = enb_ssh.before
            if output and "fingerprint" in str(output):
                enb_ssh.sendline(command)
                enb_ssh.expect(radio_ssh_prompt, timeout=60)
                output = enb_ssh.before
            if output and "dapd -pwr" in command and "Power" not in str(output):
                enb_ssh.sendline(command)
                enb_ssh.expect(radio_ssh_prompt, timeout=60)
                output = enb_ssh.before
            if not output and expect_output:
                error("Problems sending command {} to {}. Check if user, password or prompt are correct.".format(
                    command, radio_object.name))
                raise ScriptIssue(f"No output for command {command} to {radio_object.name} although output was"
                                  f"expected.")
            if print_to_eventlog:
                info("Output: {}".format(output))
            else:
                self.logger.debug("Output: {}".format(output))
            # BuiltIn().sleep("1s")
            if return_output:
                return str(output), enb_ssh
            else:
                return output, enb_ssh
        except (pexpect.TIMEOUT, pexpect.EOF) as perror:
            if expect_output:
                error(f"Problems while sending command {command}. {perror.__class__.__name__}: {perror} was raised\n"
                      f"{''.join(format_exception(type(perror), perror, perror.__traceback__))}")
            else:
                self.logger.debug(
                    f"Problems while sending command {command}. {perror.__class__.__name__}: {perror} was raised\n"
                    f"{''.join(format_exception(type(perror), perror, perror.__traceback__))}")
            return "", enb_ssh
        except Exception as e:
            if expect_output:
                error(f"Unexpected error while sending command {command}. {e.__class__.__name__}: {e}")
                info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                raise ScriptIssue
            else:
                self.logger.debug(f"Unexpected error while sending command {command}. {e.__class__.__name__}: {e}\n"
                                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                return "", enb_ssh

    def send_command_to_radio_by_telnet(self, radio_object, command, return_output=False, expect_output=False,
                                        print_to_eventlog=True, name_for_log="", raise_error=True):
        """
        Send command(s) to radio by telnet connection.

        :param obj radio_object: Radio object (from BTS.py).
        :param str/list command: Command(s) to be sent to radio.
        :param bool expect_output: Default is False. If set False output for command is not required, usable for example
                                   if connection to radio is lost with the command and prompt is not seen.
        :param bool return_output: Default is False, if set to True returns output of telnet command as string.
        :param bool print_to_eventlog: Default is True. If set to False doesn't print commands and outputs to eventlog.
        :param str name_for_log: You can give extra name for the ssh log. For example
                                 "ssh_to_smod_telnet_to_FRIG1111_manual"
        :param bool raise_error: Default True, if False will raise just warning.
        """
        enb_ssh = None
        try_time = 0
        try:
            enb_ssh = self.ssh_connection_to_smod_ltx_attach("to_smod_telnet_to_{}{}".format(
                radio_object.name.replace(".", "").replace("(", "").replace(")", ""), name_for_log),
                raise_error=raise_error)
            telnet_port = RMODLoginInfo.select_telnet_port(radio_object)
            rmod_info = RMODLoginInfo.get_rmod(radio_object.name)
            radio_prompt = re.compile(r"(:~ >|\$|#|> |:~.)")
            BuiltIn().sleep("1s")
            telnet_ok = False
            while try_time < 25 and telnet_ok is False:
                try_time += 1
                if print_to_eventlog:
                    info(f"Take telnet connection to {radio_object.name} with command: "
                         f"telnet {radio_object.ip} {telnet_port} ({try_time}. try)")
                else:
                    self.logger.debug(f"Take telnet connection to {radio_object.name} with command: "
                                      f"telnet {radio_object.ip} {telnet_port}")
                enb_ssh.sendline("telnet {} {}".format(radio_object.ip, telnet_port))
                index = enb_ssh.expect(["yes/no", "assword:", r"\$", "#", "> ", ":~.",
                                        ":~ >", pexpect.EOF, pexpect.TIMEOUT])
                other_index = enb_ssh.expect(["(.+)yes/no", "(.+)assword:", r"(.+)\$", "(.+)#", "(.+)> ", "(.+):~.",
                                              "(.+):~ >", pexpect.EOF])
                if index == 0 or other_index == 0:
                    enb_ssh.sendline("yes")
                    enb_ssh.expect("assword:", timeout=60)
                    enb_ssh.sendline(rmod_info['password'])
                    enb_ssh.expect(radio_prompt, timeout=30)
                    telnet_ok = True
                elif index == 1 or other_index == 1:
                    enb_ssh.sendline(rmod_info['password'])
                    enb_ssh.expect(radio_prompt, timeout=30)
                    telnet_ok = True
                elif index in [7, 8] or other_index == 7:
                    if try_time == 24:
                        error(f"Unable to create Telnet connection to {radio_object.name}. Check if BTS is on air and "
                              f"that radio really supports telnet.")
                        raise EnvironmentIssue
                    else:
                        info(f"Unable to create Telnet connection to {radio_object.name}. Wait 5s and try again.")
                else:
                    telnet_ok = True
                BuiltIn().sleep("5s")
            output, enb_ssh = self._send_commands_to_radio(
                enb_ssh, command, radio_object, radio_prompt, expect_output=expect_output,
                return_output=True, print_to_eventlog=print_to_eventlog)
            self.logger.debug("Command(s) sent.")
            if return_output:
                return output
        finally:
            if enb_ssh:
                self.disconnect_ssh_connection(enb_ssh)

    def _send_commands_to_radio(self, enb_ssh, command, radio_object, radio_prompt, expect_output, return_output,
                                print_to_eventlog, ignore_expect=False):
        """
        Send command(s) to radio by ssh/telnet connection. Checks if command is list or string.

        :param obj enb_ssh: Pexpect ssh connection object. Default is None.
        :param str/list command: Command(s) to be sent to radio.
        :param obj radio_object: Radio object (from BTS.py).
        :param Pattern[str] radio_prompt: Expected radio prompt.
        :param bool expect_output: If set False output for command is not required, usable for example if connection to
                                   radio is lost with the command and prompt is not seen.
        :param bool return_output: If set to True returns output of ssh/telnet command as string.
        :param bool print_to_eventlog: If set to False doesn't print commands and outputs to eventlog.
        :param bool ignore_expect: If set to True will ignore expected output and collect all the output.
        """
        output = ""
        if isinstance(command, str):
            if "frmonShellClient" in command or "/test action write 0xf4200180 32 0x0" in command:
                radio_prompt = re.compile(r"(?m)^(?:\x1b\[[0-9;?]*[ -/]*[@-~])*\$\s*(?:\x1b\[[0-9;?]*[ -/]*[@-~])*\r?$")
            output, enb_ssh = self._command_to_radio(
                enb_ssh, command, radio_object, radio_prompt, expect_output=expect_output,
                return_output=True, print_to_eventlog=print_to_eventlog, ignore_expect=ignore_expect)
        elif isinstance(command, list):
            for i in range(len(command)):
                self.logger.debug(f"Sending {i}. command: {command[i]}")
                if "frmonShellClient" in command[i] or "/test action write 0xf4200180 32 0x0" in command[i]:
                    radio_prompt = re.compile(
                        r"(?m)^(?:\x1b\[[0-9;?]*[ -/]*[@-~])*\$\s*(?:\x1b\[[0-9;?]*[ -/]*[@-~])*\r?$")
                o, enb_ssh = self._command_to_radio(enb_ssh, command[i], radio_object, radio_prompt,
                                                    expect_output=expect_output, return_output=True,
                                                    print_to_eventlog=print_to_eventlog, ignore_expect=ignore_expect)
                self.logger.debug(f"Output of {i}. command {command[i]}: {o}\nBefore:\n{enb_ssh.before}\n"
                                  f"After:\n{enb_ssh.after}")

                # echo is true so echoes command    or (command[i] and command[i - 1] in o)):
                if not o and expect_output or (o and command[i] not in o and expect_output):
                    self.logger.debug(f"Command {command[i]} output doesn't include command or previous "
                                      f"command {command[i - 1]} is in output. o: {o}")
                    tries = 0
                    while tries < 5:
                        if o and command[i] == "exit" and ("logout" in o or "closed" in o):
                            self.logger.debug("Exit command have successfully given")
                            break
                        self.logger.debug(f"sending {i}. command: {command[i]} in {tries} < 5 loop")
                        o, enb_ssh = self._command_to_radio(
                            enb_ssh, command[i], radio_object, radio_prompt, expect_output=expect_output,
                            return_output=True, print_to_eventlog=print_to_eventlog, ignore_expect=ignore_expect)
                        tries += 1
                        if command[i] in o:
                            self.logger.debug(f"Command {command[i]} was successfully given after retry.")
                            break
                        BuiltIn().sleep("1s")
                        # output = output + str(o)
                else:
                    self.logger.debug(f"Command '{command[i]}' is given.")
                output = output + str(o)
        else:
            error(f"Command should be given as list or string, not as {type(command)}")
            raise ScriptIssue(f"Command should be given as list or string, not as {type(command)}")
        return output, enb_ssh

    def disconnect_ssh_connection(self, enb_ssh, print_to_eventlog=True):
        """
        Check if ssh connection is alive, if it is close it.

        :param obj enb_ssh: SSh connection object
        :param bool print_to_eventlog:
        """
        try:
            if enb_ssh:
                if print_to_eventlog:
                    info("Close SSH connection")
                else:
                    self.logger.debug("Close SSH connection")
                if enb_ssh.isalive():
                    #  Set force to True if you want to make sure that the child is terminated (SIGKILL is sent if the
                    #  child ignores SIGHUP and SIGINT)
                    enb_ssh.close(force=True)
                if self.pexpect_log:
                    self.pexpect_log.close()
                    self.pexpect_log = None
                enb_ssh.logfile.close()
                if enb_ssh in SSHConnection.all_created_objects:
                    SSHConnection.all_created_objects.remove(enb_ssh)
            else:
                self.logger.debug("No ssh connection to close, enb_ssh is empty.")
        except (pexpect.EOF, pexpect.TIMEOUT, ValueError, TypeError, AttributeError) as e:
            print(f"disconnect_ssh_connection method: {e.__class__.__name__}:{e} was raised.\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            self.logger.debug(f"disconnect_ssh_connection method: {e.__class__.__name__}:{e} was raised.\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def check_if_pexpect_object_is_alive(self, enb_ssh):
        """
        Check if pexpect object is alive.
        :param obj enb_ssh: Pexpect ssh connection object.
        """
        self.logger.debug("Check if pexpect object is alive.")
        if enb_ssh:
            return enb_ssh.isalive()
        return False

    def move_file_from_extension_to_master(self, remote_path, smod_object=None):
        """
        Move file from extension SMOD to Master SMOD.

        :param str remote_path: Path in extension SMOD
        :param obj smod_object: SMOD object (from BTS.py)
        :return str: Return path in master smod
        """
        ip = "192.168.253.32"  # ASIA2 is extension
        if smod_object and smod_object.master:
            self.logger.debug("Master SMOD in question, no need to move files from extension to master.")
            return remote_path
        if smod_object and '1' in smod_object.name and not smod_object.master:  # ASIA1 is extension
            ip = "192.168.253.16"
        if not smod_object:
            info("SMOD object is not given to move_file_from_extension_to_master method -> we assume that ASIA2 is "
                 "extension (ip of extension 192.168.253.32)")
        path_in_master_smod = "/tmp/extension_{fil}".format(fil=remote_path[remote_path.rfind("/") + 1:])
        command = "scp -r toor4nsn@{}:{} {}\n".format(ip, remote_path, path_in_master_smod)
        info("Move file {} from extension SMOD to master SMOD to path {}".format(remote_path, path_in_master_smod))
        self.send_command_to_smod_by_ssh(command)
        return path_in_master_smod

    def _check_if_path_exists_and_remove_path(self, path):
        """Check if path exists and remove path"""
        if os.path.exists(path):
            handle = os.popen(f"rm -v -r {path}")
            output = "".join(handle.readlines())
            handle.close()
            self.logger.debug(f"Removed file {path} output: {output}")
            print(f"Removed file {path} output: {output}")

    def delete_known_host_file(self, also_rsa=False):
        """
        Delete /home/ute/.ssh/known_hosts and /home/ute/.ssh/known_hosts2 and /home/ute/.ssh/known_hosts.old files if
        exists. If also_rsa then remove also files /home/ute/.ssh/toor4nsn/id_rsa and /home/ute/.ssh/toor4nsn/id_rsa.pub
        and /home/ute/.ssh/id_rsa and /home/ute/.ssh/id_rsa.pub
        """
        self._check_if_path_exists_and_remove_path("/home/ute/.ssh/known_hosts")
        self._check_if_path_exists_and_remove_path("/home/ute/.ssh/known_hosts2")
        self._check_if_path_exists_and_remove_path("/home/ute/.ssh/known_hosts.old")
        if also_rsa:
            self._check_if_path_exists_and_remove_path("/home/ute/.ssh/toor4nsn/id_rsa")
            self._check_if_path_exists_and_remove_path("/home/ute/.ssh/toor4nsn/id_rsa.pub")
            self._check_if_path_exists_and_remove_path("/home/ute/.ssh/id_rsa")
            self._check_if_path_exists_and_remove_path("/home/ute/.ssh/id_rsa.pub")

    def get_content_of_folder_of_smod(self, folder_in_smod, grep="", ip_to_connect="192.168.255.129", full_path=False):
        """
        Take ssh connection to smod and get names of all files that are in the folder or all files that are grep from
        the folder. Return list of file names.
        :param str folder_in_smod: Folder to grep, for example /var/log
        :param str grep: If you want to grep something from the folder, for example ".log"
        :param str ip_to_connect: IP address to connect. Default is 192.168.255.129
        :param bool full_path: Default is False and then returns just name of files found. if True returns full path.
        :return list: List of file names
        """
        file_names = []
        if ip_to_connect == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                ip_to_connect = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        command = "ls %s" % folder_in_smod  # return whole content of folder
        if grep:
            command = "ls %s|grep %s" % (folder_in_smod, grep)

        ssh_output = self.send_command_to_smod_by_ssh(command, return_output=True, ip_to_connect=ip_to_connect)
        if not ssh_output:
            error("Unable to get content of folder {} from SMOD with command {}.".format(folder_in_smod, command))
            # raise EnvironmentIssue
        output = SSHConnection._safe_split(ssh_output, '\n')
        if output:
            for o_text in output:
                if o_text and grep and grep in o_text and "|grep " not in o_text and "root@" not in o_text:
                    file_names.append(o_text)
                elif o_text and ("root@" not in o_text) and ('ls ' not in o_text):
                    o_text = o_text.replace('\r', '')
                    if '\t' in o_text:
                        op2 = SSHConnection._safe_split(o_text, '\t')
                        for t_r in op2:
                            file_names.append(t_r)
                    else:
                        file_names.append(o_text)
        else:
            warning("Folder {} is empty.".format(folder_in_smod))
        if full_path:
            file_names = [os.path.join(folder_in_smod, f_name) for f_name in file_names]
        return file_names

    def collect_pcap_logs(self, smod_tcpdump_command="tcpdump -i any", file_on_smod="/tmp/smod.pcap",
                          smod_address="192.168.255.129", wait_time="900", also_bbmod=False,
                          bbmod_tcpdump_command="tcpdump -i any", bbmod_address="fsp-1a",
                          file_on_bbmod="/tmp/bbmod.pcap", only_bbmod=False):
        """
        Collect pcap logs from SMOD (and/or BBMOD) to test folder. NOTE don't give destination folder/filename in
        the tcpdump commands. Use the parameters file_on_smod and bbmod_file to give destination folder/filename.
        Default command for SMOD (and/or BBMOD) is tcpdump -i any which captures all interfaces.

        :param str smod_tcpdump_command: (Optional) default is tcpdump -i any. tcpdump command to be given on SMOD
        :param str file_on_smod: (Optional) default is /tmp/smod.pcap. Destination folder/filename on SMOD
        :param str smod_address: (Optional) default address is 192.168.255.129
        :param str wait_time: (Optional) default waiting time is 900 seconds --> 15 min
        :param bool also_bbmod: (Optional) default is False. If True, both SMOD and BBMOD pcap logs are collected
        :param str bbmod_tcpdump_command: (Optional) default is tcpdump -i any. tcpdump command to be given on BBMOD
        :param str bbmod_address: (Optional) address can be f.ex. fsp-1a/fsp-2b etc. or ipv6 format x:x:x:x:x:x:x:x
        :param str file_on_bbmod: (Optional) default is /tmp/bbmod.pcap. Destination folder/filename on BBMOD
        :param bool only_bbmod: (Optional) default is False. If True, only BBMOD pcap logs are collected
        """
        if smod_address == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                smod_address = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        if not only_bbmod:
            smod_connection = self.ssh_connection_to_smod_ltx_attach(name_for_log="smod_logs")
            smod_connection.sendline(smod_tcpdump_command + " -w " + file_on_smod)
            info(f"command: {smod_tcpdump_command} -w {file_on_smod} was sent to SMOD")

            if also_bbmod:
                self.make_ssh_log()
                self.take_ssh_connection(ip=smod_address, alias="smod_proxy")
                self.take_ssh_connection(ip=bbmod_address, proxy="smod_proxy", alias="bbmod_connection")
                complete_bbmod_command = bbmod_tcpdump_command + " -w " + file_on_bbmod
                info(f"sending command: {complete_bbmod_command} to BBMOD")
                self.send_command_without_expecting_output(complete_bbmod_command, alias="bbmod_connection")
                info(f"Waiting for {wait_time}s to collect pcap logs from SMOD and BBMOD")
                BuiltIn().sleep(f"{wait_time}s")
                self.send_command_to_ip_return_output(alias="bbmod_connection",
                                                      command=f"pgrep -f {bbmod_tcpdump_command} | xargs kill -9")
                smod_connection.sendline("\x03")
                info("Transferring bbmod.pcap from BBMOD to SMOD")
                self.scp_file_from_bbmod_to_smod(bbmod_address, file_on_bbmod)
                self.close_ssh_connection("bbmod_connection")
                self.close_ssh_connection("smod_proxy")
                self.close_ssh_log()
            else:
                # Only SMOD
                info(f"Waiting for {wait_time}s to collect pcap logs only from the SMOD")
                BuiltIn().sleep(f"{wait_time}s")
                smod_connection.sendline("\x03")

            # Collect logs to test folder
            self._make_pcap_log_folder()
            smod_command = f"sshpass -p 'oZPS0POrRieRtu' scp toor4nsn@{smod_address}"
            f":/ram/node_FHNET00{file_on_smod} {self.logger.log_dir}/pcap_logs"

            logs_from_smod = os.popen(smod_command, mode="w")
            logs_from_smod.close()
            if also_bbmod:
                bbmod_command = f"sshpass -p 'oZPS0POrRieRtu' scp toor4nsn@{smod_address}"
                f":/ram/node_FHNET00{file_on_bbmod} {self.logger.log_dir}/pcap_logs"
                bbmod_logs_from_smod = os.popen(bbmod_command, mode="w")
                bbmod_logs_from_smod.close()
            self.disconnect_ssh_connection(smod_connection)
        else:
            # only BBMOD
            self.make_ssh_log()
            self.take_ssh_connection(ip=smod_address, alias="smod_proxy")
            self.take_ssh_connection(ip=bbmod_address, proxy="smod_proxy", alias="bbmod_connection")
            complete_bbmod_command = bbmod_tcpdump_command + " -w " + file_on_bbmod
            info(f"sending command: {complete_bbmod_command} to BBMOD")
            self.send_command_without_expecting_output(complete_bbmod_command, alias="bbmod_connection")
            info(f"Waiting for {wait_time}s to collect pcap logs from BBMOD")
            BuiltIn().sleep(f"{wait_time}s")
            self.send_command_to_ip_return_output(alias="bbmod_connection",
                                                  command=f"pgrep -f {bbmod_tcpdump_command} | xargs kill -9")
            # Transfer bbmod.pcap from BBMOD to SMOD
            info(f"Transferring bbmod.pcap from BBMOD to SMOD")
            self.scp_file_from_bbmod_to_smod(bbmod_address, file_on_bbmod)
            self.close_ssh_connection("bbmod_connection")
            self.close_ssh_connection("smod_proxy")

            bbmod_command = f"sshpass -p 'oZPS0POrRieRtu' scp toor4nsn@{smod_address}"
            f":/ram/node_FHNET00{file_on_bbmod} {self.logger.log_dir}/pcap_logs"
            bbmod_logs_from_smod = os.popen(bbmod_command, mode="w")
            bbmod_logs_from_smod.close()
            self.close_ssh_log()

    def scp_file_from_bbmod_to_smod(self, bbmod_address, file_on_bbmod="/tmp/bbmod.pcap",
                                    folder_on_smod="/ram/node_FHNET00/tmp"):
        """
        Copy file from bbmod to smod

        :param str bbmod_address: Address of BBMOD. Can be fsp-1a/fsp-2b etc. or ipv6 format x:x:x:x:x:x:x:x
        :param str file_on_bbmod: (Optional) default is /tmp/bbmod.pcap. File to be copied from BBMOD to SMOD
        :param str folder_on_smod: (Optional) destination folder that file is copied to on SMOD
        """
        connection = self.ssh_connection_to_smod(name_for_log="thru_smod_to_bbmod")
        if ":" in bbmod_address:
            bbmod_address = f"[{bbmod_address}]"

        connection.sendline(f"scp toor4nsn@{bbmod_address}"
                            f":{file_on_bbmod} {folder_on_smod}")

        index = connection.expect(["yes/no", "assword:", pexpect.EOF], timeout=60)
        enb_ssh_prompt = re.compile(r'(:~ >|AaShell>)')
        if index == 0:
            connection.sendline("yes")
            connection.expect("assword:", timeout=60)
            self.logger.debug("'Password:' prompt detected, about to enter password oZPS0POrRieRtu")
            connection.sendline("oZPS0POrRieRtu")
            self.logger.debug("Password entered, waiting for command prompt")
            connection.expect(enb_ssh_prompt, timeout=60)
            self.logger.debug("Command prompt detected. SSH Login successful.")
        elif index == 1:
            self.logger.debug("'Password:' prompt detected, about to enter password oZPS0POrRieRtu")
            connection.sendline("oZPS0POrRieRtu")
            self.logger.debug("Password entered, waiting for command prompt")
            connection.expect(enb_ssh_prompt, timeout=60)
            self.logger.debug("Command prompt detected. SSH Login successful.")
        self.disconnect_ssh_connection(connection)

    def _make_pcap_log_folder(self):
        try:
            pcap_folder = os.path.join(self.logger.log_dir, "pcap_logs")
            if not os.path.exists(pcap_folder):
                self.logger.debug(f"Folder {pcap_folder} doesn't exists, create it.")
                os.makedirs(pcap_folder, exist_ok=True)
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError) as e:
            warning(f"Unable to make pcap_log folder ERROR {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def send_command_without_expecting_output(self, command, alias="ssh"):
        """
        Send command to IP without expecting output.

        :param str command: Command to be sent
        :param str alias: Alias to be used. Default is ssh.
        """
        if self.ssh_log:
            self._write_to_ssh_log("Sending command '{}' to alias '{}'.".format(command, alias))
        try:
            self.ssh.send_command(command, connection=alias)
            return True
        except CommandOutputTimeoutError as e:
            warning(f"We received 'CommandOutputTimeoutError' after giving command '{command}'. In case there "
                    "are unexpected issues afterwards, this is most likely the reason.\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return False
        except EOFError as e:
            warning(f"We received 'EOFError' after giving command '{command}'. CommandExecutionError: cannot send "
                    "command: not connected.\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return False
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError, CommandOutputTimeoutError,
                CommandExecutionError, ConnectFailedError, ConnectionError, CommandOutputCollectionError,
                FileProtocolClientError, CommandOutputCollectionTerminationError) as e:
            warning(f"Unable to send command {command}, ERROR {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return False

    def ssh_to_bbmod_soc_lxc_attach_container_and_command(self, bbmod_object, soc=None, container="", command="",
                                                          disconnect_smod_ssh=True, enb_ssh=None, right_smod=False):
        """
        SSH to BBMOD SOC lxc-attach container command. This method takes ssh connection to SOC of BBMOD unit, then
        lxc-attach to given container and gives the given command.

        :param obj bbmod_object: BBMOD unit object (from BTS.py)
        :param str soc: SOC of BBMOD. If not given, primary SOC is used.
        :param str container: Container to attach. If not given, lxc attach will not be made. Can be for example 0x1730
                              or 0x1731.
        :param str command: Command to be given in container if container is given. Command can be anything for example:
                            pkill -SIGABRT l2CounterClient
                            pkill -SIGABRT Disp_0
                            pkill -SIGABRT CCSRTDaemonExe
                            pkill -SIGABRT Disp_1
                            pkill -SIGABRT RTHWAPIDaemon
        :param bool disconnect_smod_ssh: Default is True. If set to False, doesn't disconnect SMOD ssh connection after
                                         only bbmod ssh, this enables that with same SMOD ssh connection ssh can be
                                          taken to another BBMOD unit.
        :param obj enb_ssh: Pexpect ssh connection object. Default is None. Can be given so no need to reestablish
                            connection to SMOD before calling this method again or if connection was already created.
        :param bool right_smod: Default is False. If set to True, container name is changed from 0x1 to 0x2.
        """
        fsp_ssh = None
        try:
            fsp_ips = BuiltIn().get_library_instance("FSP")
            if not soc:
                soc = bbmod_object.primary_soc
            fsp_ip = fsp_ips.get_ip_of_selected_fsp(bbmod_object.name, soc)
            if not enb_ssh:
                enb_ssh = self.ssh_connection_to_smod()
            fsp_ssh = self.connect_to_fsp(enb_ssh, fsp_ip, "toor4nsn")
            if container:
                # for debug reasons 'lxc-ls --active' command, we could also check if given container really exists
                active_lxcs = self.send_command_to_fsp_by_ssh(fsp_ssh, "lxc-ls --active", ssh_timeout=60)
                info(active_lxcs)
                if right_smod and '0x1' in container:  # or '.' in bbmod_object.name:
                    info(f"Given container name {container} is from the left side, environment is right side SMOD -> "
                         "Change container name from 0x1 to 0x2.")
                    container = container.replace("0x1", "0x2")
                attach_command = rf"lxc-attach -n {container}"
                info(f"Perform lxc-attach to container: '{attach_command}'")
                attach_success = False
                attach_attempt = 0
                while not attach_success and attach_attempt < 10:
                    output = self.send_command_to_fsp_by_ssh(fsp_ssh, attach_command, ssh_timeout=60)
                    self.logger.debug(f"Output from attach command: {output}")
                    if "Connection refused" in output:
                        self.logger.debug(f"Could not perform lxc-attach, connection refused.")
                        attach_attempt += 1
                        BuiltIn().sleep("5s")
                    else:
                        attach_success = True
                if not attach_success:
                    error(f"Could not perform lxc-attach to container {container}.")
                    raise SSHConnectionFailure(f"Could not perform lxc-attach to container {container}.")
                else:
                    self.logger.debug(f"lxc-attach to container {container} was successful.")
                    o = self.send_command_to_fsp_by_ssh(fsp_ssh, "pstree -palt", ssh_timeout=60)
                    self.logger.debug(rf"Process tree of container:\n{o}")
            if command:
                info(f"Give command: '{command}'")
                self.send_command_to_fsp_by_ssh(fsp_ssh, command, ssh_timeout=60)
        finally:
            self.disconnect_ssh_connection(fsp_ssh)
            if disconnect_smod_ssh:
                self.disconnect_ssh_connection(enb_ssh)
            else:
                self.logger.debug("SMOD ssh connection is not disconnected. Return enb_ssh for later use.")
                return enb_ssh

    def _close_ssh_connections_made_with_pexpect(self):
        """Close ssh connections made with pexpect"""
        if SSHConnection.all_created_objects:
            for obj in SSHConnection.all_created_objects:
                try:
                    self.disconnect_ssh_connection(obj, print_to_eventlog=False)
                except (AttributeError, TypeError, ValueError, IndexError, EOFError,
                        paramiko.ssh_exception.SSHException) as e:
                    print(f"Unable to close pexpect ssh connection ERROR {e.__class__.__name__}:{e}\n"
                          f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    self.logger.debug(f"Unable to close pexpect ssh connection ERROR {e.__class__.__name__}:{e}\n"
                                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    continue
        else:
            self.logger.debug("No hanging pexpect ssh connections")
            print("No hanging pexpect ssh connections")

    def _close_ssh_connections_made_with_taf_library(self):
        """Close ssh connections made with taf library"""
        if SSHConnection.all_created_alias:
            for alias in SSHConnection.all_created_alias:
                try:
                    self.logger.debug(f"Connection {alias} was still found, it may be hanging. Disconnect it.")
                    print(f"Connection {alias} was still found, it may be hanging. Disconnect it.")
                    if self.ssh.is_alive(connection=alias):
                        self.ssh.disconnect(connection=alias)
                except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError, EOFError,
                        paramiko.ssh_exception.SSHException, CommandOutputTimeoutError, CommandExecutionError,
                        ConnectFailedError, ConnectionError, CommandOutputCollectionError, FileProtocolClientError,
                        CommandOutputCollectionTerminationError) as e:
                    print(f"Unable to close ssh connection ERROR {e.__class__.__name__}:{e}\n"
                          f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    self.logger.debug(f"Unable to close ssh connection ERROR {e.__class__.__name__}:{e}\n"
                                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    continue
                finally:
                    self.close_ssh_log()
        else:
            self.logger.debug("No hanging taf ssh connections")
            print("No hanging taf ssh connections")

    def close_all_ssh_connections(self):
        """Close all created SSH connections method is for ensuring that there will be no hanging ssh connections"""
        self._close_ssh_connections_made_with_taf_library()
        self._close_ssh_connections_made_with_pexpect()
        SSHConnection.all_created_alias = []
        SSHConnection.all_created_objects = []
