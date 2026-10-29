import os

from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
import re
import requests


class McsharkParser(object):

    def __init__(self):
        self.epan_dir = 'epan'
        self.wireshark_plugins_path = '/usr/lib/x86_64-linux-gnu/wireshark/plugins/'
        self.ute_plugins_path = '/home/ute/.local/lib/wireshark/plugins/'
        self.nsetapx_plugin_location = 'https://artifactory-espoo1.int.net.nokia.com/artifactory/' \
                                       'wslte5g_plugins-local/NSETAP_X/'
        self.tshark_output = None

    def convert_pcap_with_filter_and_get_l1_common_parameter_values(self, param_name, l1_param,
                                                                    pcap_file, tshark_filter):
        self.convert_pcap_file_with_filter_using_mcshark(pcap_file, tshark_filter)
        return self.get_l1_common_parameter_values(param_name, l1_param)

    def get_parameter_integer_values(self, param_name):
        return [int(value) for value in self._get_parameter_values(param_name, "Uint")]

    def get_l1_common_parameter_values(self, param_name, l1_param):
        return self._get_parameter_values(param_name, l1_param)

    def convert_pcap_file_with_filter_using_mcshark(self, pcap_file, tshark_filter):
        tshark_cmd = self._get_tshark_with_mcshark_cmd(pcap_file, tshark_filter)
        Logger.debug("Converting pcap using mcshark with cmd: {}".format(tshark_cmd))
        self.tshark_output = [str(line).strip() for line in Os.execute_command(tshark_cmd).splitlines()]

    def convert_pcap_file_with_filter_using_mcshark_with_custom_param(self, pcap_file, tshark_filter, custom_param):
        tshark_cmd = self._get_tshark_with_mcshark_and_customization_cmd(pcap_file, tshark_filter, custom_param)
        Logger.debug("Converting pcap with cmd: {}".format(tshark_cmd))
        self.tshark_output = [str(line) for line in Os.execute_command(tshark_cmd).splitlines()]

    def decode_nsetapx_from_pcap(self, pcap_file):
        self.convert_pcap_file_with_filter_using_mcshark(pcap_file, 'nsetapx')
        return [mesg.strip(' ') for mesg in self.tshark_output]

    def decode_nsetapx_from_pcap_with_custom_param(self, pcap_file, custom_param):
        self.convert_pcap_file_with_filter_using_mcshark_with_custom_param(pcap_file, 'nsetapx', custom_param)
        return [mesg.strip(' ') for mesg in self.tshark_output]

    def download_nsetapx_plugin(self):
        if not self._check_if_nsetapx_plugin_already_exists():
            release = self._get_tshark_release()
            plugin_location = Os.join_path_elements(self.nsetapx_plugin_location +
                                                    self._get_nsetapx_plugin_recent_version(),
                                                    self._get_nsetapx_plugin_filename())
            wireshark_plugins_path = Os.join_path_elements(self.wireshark_plugins_path, release, self.epan_dir)
            return Os.execute_single_command_in_shell(f'cd {wireshark_plugins_path} && '
                                                      f'sudo wget --method GET '
                                                      f'--header "authorization: Bearer {Os().ute_ca_token}" '
                                                      f'{plugin_location}')
        else:
            Logger.info("NSETAPX plugin already exists. Omitting download")

    def _get_parameter_values(self, param_name, param_type):
        assert self.tshark_output, \
            "Output missing, make sure that UE is attached to proper BTS/Cell " \
            "or convert_pcap_file_with_filter function was called for this parser object"
        regex = re.compile(r"{}.*\({}.*\):.(\S+)".format(param_name, param_type))
        return [re.search(regex, line).group(1) for line in self.tshark_output if regex.findall(line)]

    @staticmethod
    def _get_tshark_release():
        version = Os.execute_command('tshark --version | head -1')
        return re.search(r'(\d+.\d+)', version).group(0)

    def _get_nsetapx_plugin_recent_version(self):
        return re.findall(r'>(nsetapx.*\d/)',
                          requests.get(self.nsetapx_plugin_location, headers=Os().authorization_bearer_token).text)[-1]

    def _get_nsetapx_plugin_filename(self):
        return re.findall(r'>(nsetapx-{}.*\.so)'.format(self._get_tshark_release()),
                          requests.get(self.nsetapx_plugin_location+self._get_nsetapx_plugin_recent_version(),
                                       headers=Os().authorization_bearer_token).text)[1]

    def _check_if_nsetapx_plugin_already_exists(self):
        return any(file.startswith('nsetapx') for file in os.listdir(
            Os.join_path_elements(self.wireshark_plugins_path, self._get_tshark_release(), self.epan_dir))) or \
            any(file.startswith('nsetapx') for file in os.listdir(
                Os.join_path_elements(self.ute_plugins_path, self._get_tshark_release(), self.epan_dir)))

    @staticmethod
    def _get_tshark_with_mcshark_cmd(pcap_file, tshark_filter):
        return "tshark -V -r {pcap} -Y {t_filter}".format(pcap=pcap_file, t_filter=tshark_filter)

    @staticmethod
    def _get_tshark_with_mcshark_and_customization_cmd(pcap_file, tshark_filter, custom_param):
        return "tshark -V -o {custom} -r {pcap} -Y {t_filter}".format(pcap=pcap_file, t_filter=tshark_filter,
                                                                      custom=custom_param)
