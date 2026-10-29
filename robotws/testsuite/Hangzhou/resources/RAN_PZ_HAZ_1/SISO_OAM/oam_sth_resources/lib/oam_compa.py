import paramiko
import requests
import time
import logging
import re
import os
from SSHExecutor import SSHExecutor
from tool_ping import tool_ping
import subprocess

requests.packages.urllib3.disable_warnings()
try:
    from robotide.lib.robot.api import logger
except ImportError:
    from robot.api import logger


def run_command(cmd, also_console=False):
    logger.info(cmd, also_console=True)
    out = subprocess.PIPE if also_console else open(os.devnull, "w")
    process = subprocess.Popen(cmd, stdout=out, stderr=subprocess.STDOUT, shell=True)
    stdout = process.communicate()[0]
    if also_console:
        logger.info(stdout, also_console=True)
    process.wait()
    return process.returncode


class oam_compa(object):
    ROBOT_LIBRARY_SCOPE = "TEST SUITE"

    def __init__(self):
        self.ssh_tools = None
        self.working_module_status = {
            "operationalState": "enabled",
            "availabilityStatus": "online",
            "proceduralStatus": "configured",
        }
        self.non_working_module_status = {
            "operationalState": "disabled",
            "availabilityStatus": "offline",
            "proceduralStatus": "notInitialized",
        }
        self.ssh_user = None
        self.ssh_password = None

    def setup_hran_compa(self, ssh_user, ssh_password):
        """
        Hran COMPA setup

        | **Author:** jaroslaw.piszczala@nokia.com
        | **Maintainer:** jaroslaw.piszczala@nokia.com
        | **Released with version:** ---

        **Input Parameters:**

        +------------------+------+--------------------------------------+
        | Parameter name   | Man. | Description                          |
        +==================+======+======================================+
        | ssh_user         | yes  | Login for ssh connection with BTS    |
        +------------------+------+--------------------------------------+
        | ssh_password     | yes  | Password for ssh connection with BTS |
        +------------------+------+--------------------------------------+

        """
        self.ssh_tools = SSHTools(ssh_user, ssh_password)

    def check_if_ssh_is_enabled(self, log_info=True):
        """
        Check if SSH is enable, and return status.

        | **Author:** jaroslaw.piszczala@nokia.com
        | **Maintainer:** jaroslaw.piszczala@nokia.com
        | **Released with version:** ---

        **Input Parameters:**

        +------------------+------+------------------------------------------------------------------+
        | Parameter name   | Man. | Description                                                      |
        +==================+======+==================================================================+
        | ssh_user         | yes  | Login for ssh connection with BTS                                |
        +------------------+------+------------------------------------------------------------------+
        | ssh_password     | yes  | Password for ssh connection with BTS                             |
        +------------------+------+------------------------------------------------------------------+
        | log_info         | no   | Pattern for software, which should be installed. (default: True) |
        +------------------+------+------------------------------------------------------------------+

        **Return Value:**

        True if SSH is enable, False if disable.


        **Example:**

        .. code-block:: robotframework

            ${ssh_status}=  Check if ssh is enabled  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}

        """
        return self.ssh_tools.check_if_ssh_is_enabled_tools(log_info)

    def enable_ssh_by_trs(self):
        """
        Try to enable SSH connection by Transport.

        | **Author:** jaroslaw.piszczala@nokia.com
        | **Maintainer:** jaroslaw.piszczala@nokia.com
        | **Released with version:** ---

        **Return Value:**

        True if SSH enabled successfully, False if not.

        """
        return self.ssh_tools.enable_ssh_by_trs_tools()


class SSHTools(object):
    AVAILABLE_SSH_URLS = [
        {
            "url_service": "https://192.168.255.129/protected/sshservice.html",
            "frame": "sshservice",
            "url_cgi": "https://192.168.255.129/protected/enableSsh.cgi",
        },
        {
            "url_service": "https://192.168.255.129/protected/EnableFTM_Ssh.html",
            "frame": "EnableFTM_Ssh.html",
            "url_cgi": "https://192.168.255.129/protected/EnableSsh.cgi",
        },
    ]

    PASS_MESSAGE = ["SSH Service Enabled Successfully", "Starting sshd: done", "ssh is already enabled"]

    login_data = {
        "Username": "Nemuadmin",
        "Password": "nemuuser",
        "EncodedCreds": "TmVtdWFkbWluOm5lbXV1c2Vy",
        "Validate1": "Validate2",
    }

    def __init__(self, user=None, password=None, ip="192.168.255.129"):
        self.ip = ip
        self.user = user
        self.password = password
        self.session = None
        self.ssh = SSHExecutor()
        self.ssh.set_connection_parameters(self.ip, user=self.user, password=self.password)

    def ssh_copy_id(self):
        cmd = "sshpass -p {password} ssh-copy-id -i ~/.ssh/{user}/id_rsa.pub {user}@{ip}"
        cmd = cmd.format(password=self.password, user=self.user, ip=self.ip)
        return run_command(cmd)

    def ssh_keygen(self):
        cmd = 'ssh-keygen -f "/home/ute/.ssh/known_hosts" -R {ip}'.format(ip=self.ip)
        return run_command(cmd)

    def add_ssh_public_key(self):
        logger.info("Add SSH public key to BTS")
        if self.ssh_copy_id() != 0:
            self.ssh_keygen()
            return self.ssh_copy_id()
        return 0

    def sign_files_in_dedicated_directories(self, dedicated_directories):
        logger.info("Signing files in dedicated directories")
        passive_partition_path = self.get_passive_partition_path()
        self.sign_files(passive_partition_path, dedicated_directories)

    def get_passive_partition_path(self):
        command = "readlink -f /ffs/stb"
        logger.info("Run command '{}'".format(command))
        return self.ssh.run_command(command).stdout.rstrip()

    def sign_files(self, fs_path, regex_dir):
        logger.info("Signing files in dedicated directories")
        command = (
                          r"for d in $(find " + fs_path + " -maxdepth 1 -type d | egrep -e '%s') ;"
                                                          r" do for f in $(find ${d} -type f | grep -v \.p7 ) ;"
                                                          r" do  echo \"Signing: $f\" ;"
                                                          r" crasign $f;"
                                                          r" done;"
                                                          r" done"
                  ) % regex_dir
        logger.info("Run command '{}'".format(command), also_console=True)
        output = self.ssh.run_command(command)
        logger.info(output.stdout)

    def reboot_and_wait_for_reset(self):
        command = "reboot"
        logger.info("Run command '{}'".format(command), also_console=True)
        self.ssh.run_command("reboot")
        ping = tool_ping()
        ping.wait_for_target_to_be_not_reachable("192.168.255.129")

    def check_if_ssh_is_enabled_tools(self, log_info=True):
        enabled = False
        try:
            client = paramiko.SSHClient()
            client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            client.connect("192.168.255.129", username=self.user, password=self.password, timeout=10)
            enabled = True
        finally:
            if log_info:
                logger.debug("SSH is {}.".format("enabled" if enabled else "disabled"))
            return enabled

    def session_setup(self):
        self.session = requests.Session()
        self.session.auth = (self.login_data["Username"], self.login_data["Password"])
        self.session.post("https://192.168.255.129/protected/login.cgi", data=self.login_data, verify=False)

    def enable_ssh_by_trs_tools(self):
        self.session_setup()
        for ssh_trs in self.AVAILABLE_SSH_URLS:
            status = self._enable_ssh_by_ssh_url(ssh_trs)
            if status:
                return True
        logger.debug("SSH could not be enabled on TRS module using custom method")
        return False

    def _enable_ssh_by_ssh_url(self, ssh_url):
        url_service, frame, url_cgi = map(ssh_url.get, ("url_service", "frame", "url_cgi"))
        response = self.session.get(url_service, verify=False)
        if response.status_code == requests.codes.ok:
            logging.debug("Searching for stamp and token on {}.".format(str(url_service)))
            stamps, tokens = self._get_stamps_and_tokens_from_url(url_service)
            time.sleep(1)
            if stamps and tokens:
                return self._enable_ssh_with_stamp_and_token(url_cgi, stamps, tokens, frame)
            else:
                return self._enable_ssh_with_url(url_cgi)
        else:
            logging.debug(
                "{} URL under check is not available, status code: ({}).".format(str(url_service), response.status_code)
            )
            return False

    def _get_stamps_and_tokens_from_url(self, url):
        response = self.session.get(url, verify=False)
        stamps = re.findall(r"name=stamp value=[\'\"](\w+)", response.text)
        tokens = re.findall(r"name=token value=[\'\"](\w+)", response.text)
        return stamps, tokens

    def _enable_ssh_with_stamp_and_token(self, url, stamps, tokens, frame):
        for stamp, token in zip(stamps, tokens):
            url_with_token = "{0}?stamp={1}&token={2}&frame={3}".format(url, stamp, token, frame)
            logging.debug("New url was built: {}".format(url_with_token))
            if self._enable_ssh_with_url(url_with_token):
                return True

    def _enable_ssh_with_url(self, url):
        response = self.session.get(url, verify=False)
        for message in self.PASS_MESSAGE:
            if message in response.text:
                logging.debug("SSH enabling message was detected.")
                response.connection.close()
                ssh_status = self.check_if_ssh_is_enabled_tools(log_info=False)
                if ssh_status:
                    logger.debug("SSH was enabled on TRS module using custom method")
                    return True
