# -*- coding: utf-8 -*-
"""
Keywords for ASiRHUB device.


:copyright: Nokia Networks
:author: cuicui wang
:contact: cuicui.wang@nokia-sbell.com
:maintainer: cuicui wang
:contact: cuicui.wang@nokia-sbell.com

"""

__author__ = 'Cuicui Wang'
__copyright__ = 'Copyright (C) 2020, Nokia'
__email__ = 'cuicui.wang@nokia-sbell.com'

import re
import time
from moler.util.moler_test import MolerTest
from moler.cmd import RegexHelper
from moler.exceptions import CommandFailure, CommandTimeout
from taf.ul.sc.unix_functionality import UnixFunctionality
from taf.ul.sc.util import util


class GenericHub(UnixFunctionality):
    """
    Class with robot keywords for the Hub device.
    Dic info for devmem cmd is in ta_moler.cmd.shared.enblinux.devmem.Devmem
    """

    def __init__(self, device_name='GNB0_HUB0', autoconnect=False, get_device=False):
        super(GenericHub, self).__init__(device_name=device_name,
                                         autoconnect=autoconnect, get_device=get_device)

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def connect_to_hub(self):
        """
        The keyword creates the Hub device object based on the given device name.
        :return: nothing
        """
        self.connect()

        MolerTest.steps_end()

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_hub_build_version(self):
        """
        The keyword gets the build version set as current running build on the hub.
        The keyword gets the build from configuration received by calling swmanshellcommand with -i option.
        :return: the build version as string.
        """
        cmd = self.device.get_cmd(
            cmd_name="swman_shell_command", cmd_params={"options": "-i"})
        result = cmd()
        MolerTest.steps_end()
        return result["Current runningBuildName"]

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_active_hub_build_version(self):
        """
        The keyword gets the build version installed on the hub.
        The keyword gets the build from /boot/version.
        :return: the build version as string.
        """
        regex_helper = RegexHelper()
        build_version = None
        self.device.goto_state(state='LINUX')
        cmd_cat = self.device.get_cmd(cmd_name="cat", cmd_params={
                                      "path": "/boot/version"})
        result = cmd_cat()
        for line in result['LINES']:
            if regex_helper.search(r"(?P<BUILD_VERSION>ASIHUB\S+)", line):
                build_version = regex_helper.group("BUILD_VERSION")
                break

        if build_version is None:
            MolerTest.error(
                "Getting active hub build version failed, cat has returned : {}".format(result))

        MolerTest.steps_end()

        return build_version

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def code_load(self, build_version, filename, directory):
        """
        The keyword loads a build on the hub from a given file.
        :param build_version: loaded version of the build
        :param filename: name of file with build to load
        :param directory: path to file with build to load
        :return: None
        """
        file_version = GenericHub.get_file_version_from_filename(filename)

        param = "-s {}{} {}".format(directory, filename, file_version)
        cmd_save = self.device.get_cmd(
            cmd_name="swman_shell_command", cmd_params={"options": param})
        result = cmd_save(timeout=60)

        if result["status"] != "OK":
            MolerTest.error(
                "Code load failure, SWmanShellCommand save returned: ", result["failureReason"])

        param = "-a {} {} {} {}".format(build_version,
                                        build_version, filename, file_version)
        cmd_activate = self.device.get_cmd(
            cmd_name="swman_shell_command", cmd_params={"options": param})
        result = cmd_activate(timeout=60)

        if result["status"] != "OK":
            MolerTest.error(
                "Code load failure, SWmanShellCommand activate returned: ", result["failureReason"])

        MolerTest.steps_end()

    @staticmethod
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_file_version_from_filename(filename):
        """
        The keyword gets the version of the file from the file name.
        :param filename: the name of the file.
        :return: the version of the file.
        """
        regex_helper = RegexHelper()

        if regex_helper.search(r"fzhub-bundle_(?P<FILE_VERSION>\S+)\.tgz", filename):
            return regex_helper.group("FILE_VERSION")
        else:
            MolerTest.error("Wrong build file format in file: ", filename)

        MolerTest.steps_end()

    @staticmethod
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_hub_build_version_from_url(url):
        """
        The keyword gets a Hub's build version from the given URL.
        :param url: URL to Hub's configuration
        :return: Hub's build version
        """
        re_filename = re.compile(r"/(?P<BUILD_VERSION>ASIHUB.*?)/", re.I)
        match = re_filename.search(url)

        build_version = None
        if match:
            build_version = match.group("BUILD_VERSION")
        else:
            MolerTest.error(
                "Can not get build version from URL: {}".format(url))

        MolerTest.steps_end()

        return build_version

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_hostname_for_hub(self):
        """
        The keyword is to check hub linux env hostname to get hub version such as hub10 or hub20.
        :return: hostname
        """
        self.device.goto_state("LINUX")
        cmd_devmem = self.device.get_cmd(cmd_name="hostname")
        result = cmd_devmem()
        hostname = result["hostname"]

        MolerTest.steps_end()
        return hostname

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_ant_status(self, port=0, device=0, address=0, timeout=120, step=10):
        """
        Check if there is a record in the register corresponding to the given antenna parameters.
        :param port: port where antenna is connected
        :param device: antenna number
        :param address: antenna address
        :param timeout: timeout for vrha_mem command checking ant status
        :param step: step between checks
        :return: 'Detected' or 'Not detected'
        """
        start_time = time.time()
        while (time.time() - start_time) < timeout:
            try:
                self.device.goto_state("LINUX", rerun=100)
                cmd_vrha_mem = self.device.get_cmd(cmd_name="vrha_mem",
                                                   cmd_params={"port": port, "device": device, "address": address})
                result = cmd_vrha_mem()
                if result["RESULT"] is None or not re.search(r"0x.+", result["RESULT"]):
                    MolerTest.steps_end()
                    return 'Not detected'
                else:
                    MolerTest.steps_end()
                    return 'Detected'
            except (CommandFailure, CommandTimeout):
                MolerTest.warning("Unable to get vrha_mem result, retrying...")
                MolerTest.sleep(step)

    @MolerTest.raise_background_exceptions()
    def collect_snapshot(self, filename):
        """
        Collect snapshot from Hub.
        :return: result of log command
        """
        self.device.goto_state("AASHELL")
        cmd_log = self.device.get_cmd(cmd_name="log", cmd_params={
                                      "filename": filename, "options": "-a -z"})
        result = cmd_log(timeout=200)
        return result

    @MolerTest.raise_background_exceptions()
    def download_snapshot_from_hub(self, output_dir, filename):
        """
        Download snapshot from Hub to local directory.
        :param output_dir: directory on local device
        :param filename: name of file to download
        :return: None
        """

        util().download_files(local_dir=output_dir, remote_file=filename,
                              remote_dir='/tmp', remote_device_name=self.name,
                              hops=[self.ws_name], timeout=60, log_level='error')

    @MolerTest.raise_background_exceptions()
    def collect_vrha_log(self, output_dir):
        """
        Collect rfsw vrha log of all ANTs from Hub.

        :param output_dir: directory on local device
        :return: None
        """

        util().download_files(local_dir=output_dir, remote_file='RFSW_vrha_conn_log_*.bin',
                              remote_dir='/tmp', remote_device_name=self.name,
                              hops=[self.ws_name])

    @MolerTest.raise_background_exceptions()
    def collect_lola_log(self, output_dir):
        """
        Collect lola log from Hub.

        :param output_dir: directory on local device
        :return: None
        """

        util().download_files(local_dir=output_dir, remote_file='lola_debug.*',
                              remote_dir='/tmp', remote_device_name=self.name,
                              hops=[self.ws_name], timeout=120)

    @MolerTest.raise_background_exceptions()
    def unplug_ant(self, ant_port):
        """
        Unplug ant.

        :param ant_port: ant port
        :return: status of unplug ant
        """
        self.device.goto_state("RFSW_CLI")
        cmd = self.device.get_cmd(cmd_name="poe_switch", cmd_params={
                                  "port": ant_port, "mode": "off"})
        result = cmd(timeout=20)
        return result["STATUS"]

    @MolerTest.raise_background_exceptions()
    def plug_ant(self, ant_port):
        """
        Plug ant.

        :param ant_port: ant port
        :return: status of plug ant
        """
        self.device.goto_state("RFSW_CLI")
        cmd = self.device.get_cmd(cmd_name="poe_switch", cmd_params={
                                  "port": ant_port, "mode": "on"})
        result = cmd(timeout=20)
        return result["STATUS"]

    @MolerTest.raise_background_exceptions()
    def get_fpga_version_on_hub(self, path):
        """
        Gets the fpga version on hub.

        :return: the fpga version as string.
        """
        self.device.goto_state("LINUX")
        # cmd_cat = self.device.get_cmd(cmd_name="cat",
        #                               cmd_params={"path": "/lib/firmware/ant/squatch2/metainfo |head -1"})
        cmd_cat = self.device.get_cmd(cmd_name="cat",
                                      cmd_params={"path": path})
        result_not_parsed = cmd_cat()
        result = result_not_parsed["LINES"][0].lower().strip().split('_')
        result = '0x' + result[0] + result[1]
        return result

    @MolerTest.raise_background_exceptions()
    def get_fpga_version_of_specific_ant(self, ant_port, device=0, address=0x00000000):
        """
        Get the fpga version of specific ant.

        :param ant_port: port where antenna is connected
        :param device: antenna number
        :param address: antenna address
        :return: fpga version of specific ant
        """
        self.device.goto_state("LINUX")
        cmd_vrha_mem = self.device.get_cmd(cmd_name="vrha_mem",
                                           cmd_params={"port": ant_port, "device": device, "address": address})
        result = cmd_vrha_mem()
        return result["RESULT"]

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def change_cpri_link_value(self, address, size, value):
        """
        The keyword is to change cpri link value to simulate cpri plug in or out .
        :return: result of cmd
        """

        self.device.goto_state("LINUX")
        cmd_devmem = self.device.get_cmd(cmd_name="devmem",
                                         cmd_params={"address": address, "size": size, "value": value})
        result = cmd_devmem()
        MolerTest.steps_end()
        return result

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_cpri_link_value(self, address):
        """
        The keyword is to get cpri link value.
        :return: value of cpri link
        """

        self.device.goto_state("LINUX")
        cmd_devmem = self.device.get_cmd(
            cmd_name="devmem", cmd_params={"address": address})
        result = cmd_devmem()

        value = result["VALUE"]
        MolerTest.steps_end()

        return value

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_ant_port_rate(self, cmd, options, port_num):
        """
        The keyword gets the ant rate by calling like cmd quadphy with -c -p PORT_NUM option.

        :param cmd: cmd use to get ant port rate
        :param options: like "-c -p"
        :param port_num: The port num of ant, index is from 0 to 11
        :return: the result of the command, 10G
        """

        self.device.goto_state("LINUX")
        cmd = self.device.get_cmd(cmd_name=cmd, cmd_params={
                                  "options": options, "port_num": port_num})
        result = cmd()
        MolerTest.steps_end()
        return result

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def disable_hub_reboot(self):
        """
        The keyword stop hub reboot for some log collection.

        :return: None
        """
        self.device.goto_state("LINUX")
        cmd_echo_appinhibitreboot = self.device.get_cmd(cmd_name="echo",
                                                        cmd_params={"output_file": "/configuration/appInhibitReboot"})
        cmd_echo_appinhibitreboot()
        MolerTest.steps_end()

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def enable_hub_reboot(self):
        """
        The keyword remove the file appInhibitReboot to recover hub reboot mechanism.

        :return: None
        """
        self.device.goto_state("LINUX")
        cmd_rm_appinhibitreboot = self.device.get_cmd(cmd_name="rm",
                                                      cmd_params={"options": "-f",
                                                                  "file": "/configuration/appInhibitReboot"})
        cmd_rm_appinhibitreboot()
        MolerTest.steps_end()

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_newest_tokelau_version(self):
        """
        The keyword get newest tokelau version which is used by collects ArmMemDump logs from HUB

        :return version of tokelua
        """

        self.device.goto_state("LINUX")
        ls_tokelau_cmd = self.device.get_cmd(cmd_name="ls", cmd_params={"options": "-lart",
                                                                        "path": "/usr/lib/libtokelau* | awk '{print "
                                                                                "$9}'| tail -n 1"})
        result = ls_tokelau_cmd()
        MolerTest.steps_end()

        tokelau_version = re.search(
            r'[/\w+]+\w+_\w+_\w+(?P<version>\d+.\d+.\d+.\d+).so', result['files'].keys()[0])
        return tokelau_version.group('version')

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def collect_arm_dump_log(self, output_dir, port_num, tokelau_version):
        """
        The keyword collects ArmMemDump logs from HUB and download it to local.

        :param output_dir: directory on local device
        :param port_num: The port num of ant, index is from 0 to 11
        :param tokelau_version: such as 4.1.0.40
        :return: None
        """
        self.device.goto_state("RFSW_CLI")
        cmd_tokelau_create = self.device.get_cmd(cmd_name="tokelau",
                                                 cmd_params={"options": "create {}.0 {}".format(port_num,
                                                                                                tokelau_version)})
        cmd_tokelau_create()
        cmd_tokelau_armmemdump = self.device.get_cmd(
            cmd_name="tokelau",
            cmd_params={"options": "ArmMemDump {port_num}.0 /tmp/arm{port_num}.bin".format(port_num=port_num)})
        cmd_tokelau_armmemdump(timeout=300)
        self.device.goto_state("LINUX")
        util().download_files(local_dir=output_dir, remote_file='arm*.bin',
                              remote_dir='/tmp', remote_device_name=self.name,
                              hops=[self.ws_name])
        MolerTest.steps_end()

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def collect_hub_power_management_log(self, output_dir):
        """
        Collect powerstats info of all hub components from HUB and download it to local.

        :param output_dir: directory on local device
        :return: None
        """
        self.device.goto_state("LINUX")
        powerstate_cmd_params = {
            "script_command": 'powerstat -H | tee /tmp/hub_powerstats.log'}
        powerstate_cmd = self.device.get_cmd(
            cmd_name="run_script", cmd_params=powerstate_cmd_params)
        powerstate_cmd()
        util().download_files(local_dir=output_dir, remote_file='hub_powerstats.log',
                              remote_dir='/tmp', remote_device_name=self.name,
                              hops=[self.ws_name])
        MolerTest.steps_end()

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def change_tx_dis_content(self, text, output_file):
        """
        The keyword used to plug in or plug out hub 2.0 cpri link.

        :param text: text to echo
        :param output_file: path to file to write to
        """

        self.device.goto_state("LINUX")
        cmd = self.device.get_cmd(cmd_name="echo",
                                  cmd_params={"text": text, "output_file": output_file, "text_in_quotation": False})
        result = cmd()
        MolerTest.steps_end()

    @MolerTest.raise_background_exceptions()
    def get_ant_relevant_info(self, ant_port):
        """
        get_ant_relevant_info: Collect Ant relevant infomation as a Dictionary, by specify the ant's port

        :param ant_port: ant port
        :return: Dictionary of Ant relevant infomation
        """
        self.device.goto_state("RFSW_CLI")
        cmd = self.device.get_cmd(
            cmd_name="ant_status", cmd_params={"port": ant_port})
        result = cmd(timeout=20)
        return result

    @MolerTest.raise_background_exceptions()
    def change_password(self, new_password="", user=None, reset_to_default=False):
        """
        Main Function:
            This keyword is used to change/reset user hubadmin/hubapp password with password CLI.
        Arguments:
            :new_password: new password
            :user: hubadmin or hubapp, default is hubadmin user
            :reset_to_default: True means to reset password
        Return Value:
            :return: Dictionary of PASSWORD_CHANGED status
        Examples:
            change_password(new_password=new_password, user=user, reset_to_default=True)
        """
        self.device.goto_state("RFSW_CLI")

        cmd = self.device.get_cmd(cmd_name="password", cmd_params={"user": user, "reset_to_default": reset_to_default,
                                                                   "new_password": new_password})
        result = cmd(timeout=30)
        return result

    @MolerTest.raise_background_exceptions()
    def change_user_hubadmin_default_login_password(self, password):
        """
        Main Function:
            This keyword is used to change hubadmin login default password.
        Arguments:
            :password: password for user
        Return Value:
            None
        Examples:
            change_user_hubadmin_default_login_password(password=password)
        """
        self.device.hub_password = password

    @MolerTest.raise_background_exceptions()
    def config_reset(self):
        """
        Main Function:
            This keyword is used to reset user hubadmin/hubapp password with config_reset CLI.
        Return Value:
            :return: Dictionary of PASSWORD_RESET status
        Examples:
            config_reset
        """
        self.device.goto_state("RFSW_CLI")
        cmd = self.device.get_cmd(cmd_name="config_reset", cmd_params={})
        result = cmd(timeout=20)
        return result

    @MolerTest.raise_background_exceptions()
    def check_hub_account_status(self, user="hubapp", options="-S", check_user_status="L"):
        """
        Main Function:
            This keyword is used to check hub account status.
        Arguments:
            :param user: hub user
            :options: additional command parameters
            :check_user_status: check hub account status
        Return Value:
            None
        Examples:
            check_hub_account_status(user=user, options=options)
        """
        self.device.goto_state("LINUX")
        cmd = self.device.get_cmd(cmd_name="passwd", cmd_params={"user": user, "options": options})
        result_not_parsed = cmd()
        result = result_not_parsed["LINES"][0].lower().strip().split('_')
        check_point = user+" "+check_user_status.lower().strip()
        if check_point in result[0]:
            MolerTest.info("User {} is {}".format(user, check_user_status))
        else:
            MolerTest.error("User {} is not {} as expect".format(user, check_user_status), raise_exception=True)

    @MolerTest.raise_background_exceptions()
    def connect_to_hubapp(self, login='hubapp', host='192.168.255.129', password=None):
        """
        Main Function:
            This keyword is used to connect to hubapp with ssh command.
        Arguments:
            :param login: user
            :host: host ip
            :password: login password
        Return Value:
            None
        Examples:
            connect_to_hubapp(login=login, host=host, password=password)
        """
        cmd = self.device.get_cmd(cmd_name="ssh", cmd_params={"login": login, "host": host, "password": password})
        result_not_parsed = cmd()
        result = result_not_parsed["LINES"][0].lower().strip().split('_')
        if "you are about to access a private system" in "".join(result):
            MolerTest.info("Connect to hubapp with ssh command successfully")
        else:
            MolerTest.error("Connect to hubapp with ssh command failed", raise_exception=True)
        MolerTest.info("Start to exit to proxy_pc mode")
        exit_cmd = self.device.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": r'ute@.*(\$|#|>)\s+'})
        exit_cmd()

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_hub_password_info(self):
        """
        Main Function:
            This keyword is used to get the content which in the Hub file '/etc/passwd'
            e.g.
                    toor4nsn:x:0:0::/user/toor4nsn:/bin/bash
                    root:x:0:0:root:/user/toor4nsn:/sbin/nologin
                    daemon:x:1:1:daemon:/usr/sbin:/bin/false
                    bin:x:2:2:bin:/bin:/bin/false
                    ... ...

        Return Value:
            :return: content of '/etc/passwd'

        Examples:
            get_hub_password_info()
        """
        self.device.goto_state("LINUX")
        cmd = self.device.get_cmd(cmd_name="cat", cmd_params={"path": "/etc/passwd"})
        result = cmd()
        MolerTest.info("result: {}".format(result))
        MolerTest.steps_end()
        return result["LINES"]
