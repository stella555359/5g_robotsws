# -*- coding:utf-8 -*-

import os
import re
import requests
import traceback
from bs4 import BeautifulSoup
from base_lib.ta_enb_dependency_selector.downloader import Downloader
from common_lib_aic import common_lib_aic
from base_lib.ta_enb_dependency_selector import ta_enb_dependency_selector
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from base_lib.ta_xml.common_xml import CommonXML
from requests.auth import HTTPBasicAuth

comm_obj = common_lib_aic()
selector_obj = ta_enb_dependency_selector()
os_obj = OperatingSystem()
builtin_obj = BuiltIn()

WIRESHARK_PLUGIN_URL = r"http://files.ute.nsn-rdnet.net/builds/wireshark/nsetapx/"
NSETAPX_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X"
MCSHARK_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/"
NOKIAF1AP_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/Nokia_F1_AP/"
NOKIAXNAP_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/Nokia_Xn_AP/"


class wireshark(object):
    def __init__(self):
        pass

    def _setup_plugin_postfix(self):
        builtin_obj.log("step: mapping debian version to plugin postfix")
        debian_version = comm_obj.execute_cmd_on_pc("lsb_release -a | grep -i release").split()[-1]
        builtin_obj.log("debug: debian version is {}".format(debian_version))
        if debian_version == "10":
            self.plugin_postfix = "buster.so"
        elif debian_version == "12":
            self.plugin_postfix = "bookworm.so"
        else:
            raise Exception("not support debian {} yet".format(debian_version))

    def get_plugin_file_name(self, wireshark_version):
        plugin_file = ''
        r = requests.get(WIRESHARK_PLUGIN_URL, auth=HTTPBasicAuth('ncommon', 'ba+v3Zxj'))
        soup = BeautifulSoup(r.content, 'lxml')
        for a_tag in soup.find_all('a')[::-1]:
            if 'nsetapx-' + wireshark_version in a_tag.text:
                plugin_file = a_tag.text
                break
        return plugin_file or 'nsetapx-3.4-1.1.0+%s' % self.plugin_postfix

    def get_wireshark_version(self):
        out1 = comm_obj.execute_cmd_on_pc("wireshark --version")
        if out1.lower().count("wireshark"):
            version = out1.strip().splitlines()[0].split()[1][0:3]
        else:
            out2 = comm_obj.execute_cmd_on_pc("tshark --version")
            if out2.lower().count("wireshark"):
                version = out2.strip().splitlines()[0].split()[2][0:3]
            else:
                raise Exception("fail to get wireshark version")
        builtin_obj.log("wireshark_version = %s" % version)
        return version

    def download_plugin(self, plugin_file, local_plugin_path):
        downloader = Downloader()
        os.system("sudo chmod 777 %s" % local_plugin_path)
        plugin_src = "%s/%s" % (WIRESHARK_PLUGIN_URL, plugin_file)
        plugin_dst = "%s/%s" % (local_plugin_path, plugin_file)
        builtin_obj.log("[step]: wget %s -O %s" % (plugin_src, plugin_dst))
        downloader.execute_wget(plugin_src, plugin_dst)

    def download_plugin_to_specific_folder(self, plugin_url, plugin_file, local_plugin_path):
        os.system("sudo chmod 777 %s" % local_plugin_path)
        comm_obj.execute_cmd_on_pc("cd {}".format(local_plugin_path))
        comm_obj.execute_cmd_on_pc("wget --user=ncommon --password=ba+v3Zxj {}/{}".format(plugin_url, plugin_file))

    # get latest plugin name from corresponding plugin URL page (nokiaflap, nokiaxnap, nsetapx)
    def get_latest_plugin_folder_name(self, plugin_name, plugin_address):
        builtin_obj.log("debug: get latest {} plugin".format(plugin_name))
        try:
            r = requests.get(plugin_address, auth=HTTPBasicAuth('ncommon', 'ba+v3Zxj'))
            soup = BeautifulSoup(r.content, 'lxml')
            # get all plugin folder
            plugin_folder_pattern = re.compile(r'.*">({}.*)/</a>.*'.format(plugin_name))
            plugin_folder_result = plugin_folder_pattern.findall(str(soup))
            builtin_obj.log("debug:plugin_folders={}".format(plugin_folder_result))
            if plugin_folder_result:
                plugin_dict = {}
                temp_plugin_list = []

                # add workaround to exclude special vesrion
                excluded_version_regexp = re.compile('|'.join([
                    # r'nokiaf1ap-17',
                    # r'nokiaxnap-17',
                    r'.*-0.0.1.*'
                ]))
                excluded_version_list = []
                for version in plugin_folder_result:
                    # find the special version and remove
                    if excluded_version_regexp.search(version):
                        excluded_version_list.append(version)
                        plugin_folder_result.remove(version)
                builtin_obj.log("excluded version: {}".format(excluded_version_list))

                # sort plugin folder and get latest one
                sorted_versions = sorted(plugin_folder_result,
                                         key=lambda x: tuple(map(int, x.split('-')[1].split('.'))))
                builtin_obj.log("debug:plugin_folders after sorted={}".format(sorted_versions))
                return sorted_versions[-1]
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log("get latest {} plugin folder fails.".format(plugin_name), level="WARN")
            raise Exception("get latest {} plugin folder fails: {}".format(plugin_name, detail))

    def get_matched_plugin_folder_name(self):
        builtin_obj.log("debug: get matched plugin")
        if self.plugins:
            builtin_obj.log("debug: plugins: {}".format(self.plugins))
            return
        # login to wft
        try:
            session = requests.Session()
            login_data = {
                'SMENC': "ISO-8859-1",
                'SMLOCALE': "US-EN",
                'USER': "ncommon",
                'PASSWORD': "ba+v3Zxj",
                "target": "HTTPS://wft.int.net.nokia.com/",
                "smauthreason": 0,
                "postpreservationdata": ""
            }
            session.post("https://wam.inside.nsn.com/siteminderagent/forms/login.fcc", data=login_data, timeout=10)
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("fail to connect to wft to get nokiaf1ap and nokiaxnap plugin version", level="WARN")
            builtin_obj.log("please open firewall to it, otherwise maybe you can't get matched plugins with SW build",
                            level="WARN")
            builtin_obj.log(details)
            raise Exception("fail to connect to wft")

        # get 5g-l2-l3-aggregated link
        try:
            resp1 = session.get("https://wft.int.net.nokia.com/SBTS/CI_ENB/builds/{}/"
                                "partial.js?project_filters=ALL&partial=baselines&force=false"
                                "".format(self.bts_version),
                                timeout=30)
            match = re.search(r"(/5G/5g-l2-l3-aggregated/builds/0\.0\.0-\d+)\?project_filters=",
                              resp1.content.decode("utf-8"), re.I)
            if match:
                aggregated_url = "https://wft.int.net.nokia.com/" + match.group(1) + \
                                 "/partial.js?project_filters=&partial=release&force=false"
                builtin_obj.log("debug: aggregated_url={}".format(aggregated_url))
            else:
                raise Exception("failed to get 5g-l2-l3-aggregated link")
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("debug: fail to get 5g-l2-l3-aggregated link: \n{}".format(details))
            raise Exception("fail to get 5g-l2-l3-aggregated link")

        # get f1ap/xnap version
        try:
            resp2 = session.get(aggregated_url, timeout=30)
            resp2_content = html.unescape(resp2.content.decode("utf-8"))
            nokiaf1ap_ver = re.search(r'ASN1_F1.*"platform":"(.*?)".*ASN1_F1', resp2_content)
            nokiaxnap_ver = re.search(r'ASN1_XN.*"platform":"(.*?)".*ASN1_XN', resp2_content)

            if nokiaf1ap_ver and nokiaxnap_ver:
                nokiaf1ap_ver = nokiaf1ap_ver.group(1)
                nokiaxnap_ver = nokiaxnap_ver.group(1)
                self.plugins['nokiaf1ap'] = "nokiaf1ap-" + nokiaf1ap_ver
                self.plugins['nokiaxnap'] = "nokiaxnap-" + nokiaxnap_ver
                builtin_obj.log("debug: plugins: {}".format(self.plugins))
            else:
                raise Exception("fail to get nokiaf1ap and nokiaxnap version")
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("debug: fail to get nokiaf1ap and nokiaxnap version: \n{}".format(details))
            raise Exception("fail to get nokiaf1ap and nokiaxnap version")

    def get_nsetapx_plugin_file_name(self, wireshark_version, plugin_folder_name):
        r = requests.get("{}/{}/".format(NSETAPX_PLUGIN_URL, plugin_folder_name), auth=HTTPBasicAuth('ncommon',
                                                                                                     'ba+v3Zxj'))
        soup = BeautifulSoup(r.content, 'lxml')
        nsetapx_plugin_file_name = ""
        for a_tag in soup.find_all('a')[::-1]:
            search_result = re.search("nsetapx-{}-.*{}$".format(wireshark_version, self.plugin_postfix),
                                      a_tag.text)
            if search_result:
                nsetapx_plugin_file_name = search_result.group(0)
                break
        if not nsetapx_plugin_file_name:
            raise Exception("get nsetapx pulgin file name failure")
        else:
            return nsetapx_plugin_file_name

    def download_wireshark_nsetapx_plugin(self):
        nsetapx_plugin_ver = builtin_obj.get_variable_value("${NSETAPX_PLUGIN_VERSION}")
        builtin_obj.log("debug: nsetapx_plugin_ver={}, length={}".format(nsetapx_plugin_ver, len(nsetapx_plugin_ver)))
        if len(nsetapx_plugin_ver):
            nsetapx_plugin_folder_name = "nsetapx-" + nsetapx_plugin_ver
        else:
            nsetapx_plugin_folder_name = self.get_latest_plugin_folder_name(plugin_name="nsetapx",
                                                                            plugin_address=NSETAPX_PLUGIN_URL)
        nsetapx_pulgin_file = self.get_nsetapx_plugin_file_name(self.wireshark_version, nsetapx_plugin_folder_name)
        builtin_obj.log("nsetapx download path: {}/{}/{}".format(NSETAPX_PLUGIN_URL,
                                                                 nsetapx_plugin_folder_name,
                                                                 nsetapx_pulgin_file))

        # download plugin, retry 1 time if failed
        builtin_obj.log("[step]: download nsetapx")
        self.download_plugin_to_specific_folder(
            plugin_url="{}/{}".format(NSETAPX_PLUGIN_URL, nsetapx_plugin_folder_name),
            plugin_file=nsetapx_pulgin_file,
            local_plugin_path=self.local_plugin_path)

        builtin_obj.log("[step]: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
        if "nsetapx" not in active_plugins:
            builtin_obj.log("[step]: download nsetapx")
            self.download_plugin_to_specific_folder(
                plugin_url="{}/{}".format(NSETAPX_PLUGIN_URL, nsetapx_plugin_folder_name),
                plugin_file=nsetapx_pulgin_file,
                local_plugin_path=self.local_plugin_path)
            builtin_obj.log("[step]: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "nsetapx" not in active_plugins:
                raise Exception("fail to download nsetapx plugin")

    def get_supported_mcshark_version(self, vdu_version):
        r = requests.get(MCSHARK_PLUGIN_URL, auth=HTTPBasicAuth('ncommon', 'ba+v3Zxj'))
        soup = BeautifulSoup(r.content, 'lxml')
        # check vdu_version exists in library
        build_pattern = re.compile(r'.*">({}.*)/</a>.*'.format(vdu_version))
        builds = build_pattern.findall(str(soup))
        return builds[0]

    def get_mcshark_plugin_file_name(self, wireshark_version, vdu_version):
        # get supported mcshark file name
        save_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        comm_obj.execute_cmd_on_pc("wget --user=ncommon --password=ba+v3Zxj {}".format(MCSHARK_PLUGIN_URL))
        comm_obj.execute_cmd_on_pc("mv index.html {}/mcshark_list.html".format(save_log_dir))
        r = requests.get("{}/{}/".format(MCSHARK_PLUGIN_URL, vdu_version), auth=HTTPBasicAuth('ncommon',
                                                                                              'ba+v3Zxj'))
        soup = BeautifulSoup(r.content, 'lxml')
        mcshark_plugin_file_name = ""
        for a_tag in soup.find_all('a')[::-1]:
            search_result = re.search("mcshark-{}.*{}.*{}$".format(wireshark_version, vdu_version, self.plugin_postfix),
                                      a_tag.text)
            if search_result:
                mcshark_plugin_file_name = search_result.group(0)
                break
        if not mcshark_plugin_file_name:
            raise Exception("get mcshark pulgin file name failure. vdu_version is {}"
                            .format(vdu_version))
        else:
            return mcshark_plugin_file_name

    def download_wireshark_mcshark_plugin(self):
        supported_vdu_version = self.get_supported_mcshark_version(self.active_vdu_version)
        builtin_obj.log("debug: supported_vcu_version={}".format(supported_vdu_version))
        mcshark_pulgin_file = self.get_mcshark_plugin_file_name(self.wireshark_version, supported_vdu_version)
        builtin_obj.log("debug: mcshark_pulgin_file={}".format(mcshark_pulgin_file))
        builtin_obj.log("[step]: download mcshark")
        self.download_plugin_to_specific_folder(
            plugin_url="{}/{}".format(MCSHARK_PLUGIN_URL, supported_vdu_version),
            plugin_file=mcshark_pulgin_file,
            local_plugin_path=self.local_plugin_path
        )

        builtin_obj.log("[step]: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc(" tshark -G plugins")
        if "mcshark" not in active_plugins:
            self.download_plugin_to_specific_folder(
                plugin_url="{}/{}".format(MCSHARK_PLUGIN_URL, supported_vdu_version),
                plugin_file=mcshark_pulgin_file,
                local_plugin_path=self.local_plugin_path
            )
            builtin_obj.log("[step]: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "mcshark" not in active_plugins:
                raise Exception("fail to download mcshark plugin")

    def get_nokiaf1ap_plugin_file_name(self, wireshark_version, plugin_folder_name):
        r = requests.get("{}/{}/".format(NOKIAF1AP_PLUGIN_URL, plugin_folder_name), auth=HTTPBasicAuth('ncommon',
                                                                                                       'ba+v3Zxj'))
        soup = BeautifulSoup(r.content, 'lxml')
        nokiaf1ap_plugin_file_name = ""
        for a_tag in soup.find_all('a')[::-1]:
            search_result = re.search("nokiaf1ap-{}-.*{}$".format(wireshark_version, self.plugin_postfix),
                                      a_tag.text)
            if search_result:
                nokiaf1ap_plugin_file_name = search_result.group(0)
                break
        if not nokiaf1ap_plugin_file_name:
            raise Exception("get nokiaf1ap pulgin file name failure")
        else:
            return nokiaf1ap_plugin_file_name

    def download_wireshark_nokiaf1ap_plugin(self):
        # do nothing if NOKIA_F1AP_PLUGIN_FLAG=False
        nokiaf1ap_plugin_flag = builtin_obj.convert_to_boolean(
            builtin_obj.get_variable_value('${NOKIA_F1AP_PLUGIN_FLAG}'))
        if nokiaf1ap_plugin_flag is not True:
            return

        builtin_obj.log("[step]: get nokiaf1ap download path")
        nokiaf1ap_plugin_ver = builtin_obj.get_variable_value("${NOKIA_F1AP_PLUGIN_VERSION}")
        if len(nokiaf1ap_plugin_ver):
            nokiaf1ap_plugin_folder_name = "nokiaf1ap-" + nokiaf1ap_plugin_ver
        else:
            try:
                self.get_matched_plugin_folder_name()
                nokiaf1ap_plugin_folder_name = self.plugins["nokiaf1ap"]
            except Exception:
                builtin_obj.log("fail to get matched nokiaf1ap plugin version, try the latest", level="WARN")
                nokiaf1ap_plugin_folder_name = self.get_latest_plugin_folder_name(plugin_name="nokiaf1ap",
                                                                                  plugin_address=NOKIAF1AP_PLUGIN_URL)
        nokiaf1ap_pulgin_file = self.get_nokiaf1ap_plugin_file_name(self.wireshark_version,
                                                                    nokiaf1ap_plugin_folder_name)
        builtin_obj.log("nokiaf1ap download path: {}/{}/{}".format(NOKIAF1AP_PLUGIN_URL,
                                                                   nokiaf1ap_plugin_folder_name,
                                                                   nokiaf1ap_pulgin_file))
        # download plugin, retry 1 time if failed
        builtin_obj.log("[step]: download nokiaf1ap")
        self.download_plugin_to_specific_folder(
            plugin_url="{}/{}".format(NOKIAF1AP_PLUGIN_URL, nokiaf1ap_plugin_folder_name),
            plugin_file=nokiaf1ap_pulgin_file,
            local_plugin_path=self.local_plugin_path)
        builtin_obj.log("[step]: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc(" tshark -G plugins")
        if "nokiaf1ap" not in active_plugins:
            builtin_obj.log("[step]: download nokiaf1ap")
            self.download_plugin_to_specific_folder(
                plugin_url="{}/{}".format(NOKIAF1AP_PLUGIN_URL, nokiaf1ap_plugin_folder_name),
                plugin_file=nokiaf1ap_pulgin_file,
                local_plugin_path=self.local_plugin_path)
            builtin_obj.log("[step]: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "nokiaf1ap" not in active_plugins:
                raise Exception("fail to download nokiaf1ap plugin")

    def get_nokiaxnap_plugin_file_name(self, wireshark_version, plugin_folder_name):
        r = requests.get("{}/{}/".format(NOKIAXNAP_PLUGIN_URL, plugin_folder_name), auth=HTTPBasicAuth('ncommon',
                                                                                                       'ba+v3Zxj'))
        soup = BeautifulSoup(r.content, 'lxml')
        nokiaxnap_plugin_file_name = ""
        for a_tag in soup.find_all('a')[::-1]:
            search_result = re.search("nokiaxnap-{}-.*{}$".format(wireshark_version, self.plugin_postfix),
                                      a_tag.text)
            if search_result:
                nokiaxnap_plugin_file_name = search_result.group(0)
                break
        if not nokiaxnap_plugin_file_name:
            raise Exception("get nokiaxnap pulgin file name failure")
        else:
            return nokiaxnap_plugin_file_name

    def download_wireshark_nokiaxnap_plugin(self):
        # do nothing if NOKIA_XNAP_PLUGIN_FLAG=False
        nokiaxnap_plugin_flag = builtin_obj.convert_to_boolean(
            builtin_obj.get_variable_value('${NOKIA_XNAP_PLUGIN_FLAG}'))
        if nokiaxnap_plugin_flag is not True:
            return

        builtin_obj.log("[step]: get nokiaxnap download path")
        nokiaxnap_plugin_ver = builtin_obj.get_variable_value("${NOKIA_XNAP_PLUGIN_VERSION}")
        if len(nokiaxnap_plugin_ver):
            nokiaxnap_plugin_folder_name = "nokiaxnap-" + nokiaxnap_plugin_ver
        else:
            try:
                self.get_matched_plugin_folder_name()
                nokiaxnap_plugin_folder_name = self.plugins["nokiaxnap"]
            except Exception:
                builtin_obj.log("fail to get matched nokiaxnap plugin version, try the latest", level="WARN")
                nokiaxnap_plugin_folder_name = self.get_latest_plugin_folder_name(plugin_name="nokiaxnap",
                                                                                  plugin_address=NOKIAXNAP_PLUGIN_URL)
        nokiaxnap_pulgin_file = self.get_nokiaxnap_plugin_file_name(self.wireshark_version,
                                                                    nokiaxnap_plugin_folder_name)
        builtin_obj.log("nokiaxnap download path: {}/{}/{}".format(NOKIAXNAP_PLUGIN_URL,
                                                                   nokiaxnap_plugin_folder_name,
                                                                   nokiaxnap_pulgin_file))
        # download plugin, retry 1 time if failed
        builtin_obj.log("[step]: download nokiaxnap")
        self.download_plugin_to_specific_folder(
            plugin_url="{}/{}".format(NOKIAXNAP_PLUGIN_URL, nokiaxnap_plugin_folder_name),
            plugin_file=nokiaxnap_pulgin_file,
            local_plugin_path=self.local_plugin_path
        )
        builtin_obj.log("[step]: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc(" tshark -G plugins")
        if "nokiaxnap" not in active_plugins:
            builtin_obj.log("[step]: download nokiaxnap")
            self.download_plugin_to_specific_folder(
                plugin_url="{}/{}".format(NOKIAXNAP_PLUGIN_URL, nokiaxnap_plugin_folder_name),
                plugin_file=nokiaxnap_pulgin_file,
                local_plugin_path=self.local_plugin_path)
            builtin_obj.log("[step]: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "nokiaxnap" not in active_plugins:
                raise Exception("fail to download nokiaxnap plugin")

    def download_wireshark_plugin(self):
        """
        # get wireshark version and plugin file name
        builtin_obj.log("[step]: get wireshak version")
        wireshark_version = self.get_wireshark_version()
        plugin_file = self.get_plugin_file_name(wireshark_version)
        local_plugin_path = "/home/ute/.local/lib/wireshark/plugins/%s/epan/" % wireshark_version
        comm_obj.execute_cmd_on_pc("rm -rf %s" % local_plugin_path)
        comm_obj.execute_cmd_on_pc("mkdir -p %s" % local_plugin_path)

        # download plugin, retry 1 time if failed
        self.download_plugin(plugin_file, local_plugin_path)
        builtin_obj.log("[step]: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc(" tshark -G plugins")
        if "nsetapx" not in active_plugins:
            self.download_plugin(plugin_file, local_plugin_path)
            builtin_obj.log("[step]: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "nsetapx" not in active_plugins:
                raise Exception("fail to download nsetapx plugin")
        """

        # 2024.03.08 sync from 5g classical, not only download nsetapx
        # Add download nsetapx, mcshark, nokiaf1ap, plugin steps
        builtin_obj.log("[step]: download wireshak plugins")
        builtin_obj.log("[step]: get wireshak version")
        self._setup_plugin_postfix()
        self.wireshark_version = self.get_wireshark_version()
        self.local_plugin_path = "/home/ute/.local/lib/wireshark/plugins/%s/epan/" % self.wireshark_version
        comm_obj.execute_cmd_on_pc("rm -rf %s" % self.local_plugin_path)
        comm_obj.execute_cmd_on_pc("mkdir -p %s" % self.local_plugin_path)

        # download mcshark plugin
        builtin_obj.log("[step]: download mcshark plugin")
        try:
            self.active_vdu_version = builtin_obj.get_variable_value("${GNB_DU_VERSION}")
            self.download_wireshark_mcshark_plugin()
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("download wireshark mcshark plugin failure. {}".format(details))
            builtin_obj.log("download wireshark mcshark plugin failure.", level="WARN")

        # download nsetapx plugin
        builtin_obj.log("[step]: download nsetapx plugin")
        try:
            self.download_wireshark_nsetapx_plugin()
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("download wireshark nsetapx plugin failure. {}".format(details))
            builtin_obj.log("download wireshark nsetapx plugin failure.", level="WARN")

        # download nokiaf1ap plugin
        builtin_obj.log("[step]: download nokiaf1ap plugin")
        try:
            self.download_wireshark_nokiaf1ap_plugin()
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("download wireshark nokiaf1ap plugin failure. {}".format(details))
            builtin_obj.log("download wireshark nokiaf1ap plugin failure.", level="WARN")

        # donwload nokiaxnap plugin
        builtin_obj.log("[step]: download nokiaxnap plugin")
        try:
            self.download_wireshark_nokiaxnap_plugin()
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("download wireshark nokiaxnap plugin failure. {}".format(details))
            builtin_obj.log("download wireshark nokiaxnap plugin failure.", level="WARN")

    def _get_wireshark_field_value(self, pcap_file, field_path, display_filter, packet_num):
        field_values = []
        comm_obj.execute_cmd_on_pc("tshark -r {} -Y '{}' -T pdml > /home/ute/wireshark.xml".format(
            pcap_file, display_filter))
        commonxml_obj1 = CommonXML("/home/ute/wireshark.xml")
        field_xpath = ""
        for field in field_path.split("/"):
            field_xpath = field_xpath + "//*[matches(@showname, '{}$|{}[ :]?.*')]".format(field, field)
        builtin_obj.log("debug: field_xpath is {}".format(field_xpath))
        for packet in commonxml_obj1.get_elements("//packet"):
            field_values_under_frame = []
            packet = commonxml_obj1.element_to_string(packet)
            commonxml_obj2 = CommonXML(packet)
            # get frame_number
            frame_number = commonxml_obj2.get_element_attribute(
                commonxml_obj2.get_element("//*[@name='frame.number']"), "show")
            # get field values under the frame
            all = commonxml_obj2.get_elements(field_xpath)
            for element in all:
                field_values_under_frame.append(commonxml_obj2.get_element_attribute(element, "show"))
            field_values.append(field_values_under_frame)
            builtin_obj.log("debug: frame_number={}, field_values={}".format(frame_number, field_values_under_frame))
        if len(field_values) < int(packet_num) + 1:
            raise Exception("fail to get packet{}, only {} packets got according to display_filter and "
                            "field_path".format(packet_num, len(field_values)))
        else:
            return field_values[int(packet_num)]

    def _matches_expected(self, value_exp, value_act):
        if value_exp.lower().startswith("[re]"):
            pattern = value_exp[4:]
            return bool(re.fullmatch(pattern, value_act, re.I))
        else:
            pattern = r"{}(?: \(\d+\))?".format(value_exp)
            return bool(re.fullmatch(pattern, value_act, re.I))

    def _check_wireshark_fields(self, pcap_file, filter, check_fields, packet_num):
        check_fields = comm_obj.remove_empty_from_list(check_fields)
        comm_obj.execute_cmd_on_pc("tshark -r {} -o ntrstr.defragment:TRUE -Y '{}' -T pdml "
                                   "> /home/ute/wireshark.xml".format(pcap_file, filter))
        commonxml_obj1 = CommonXML("/home/ute/wireshark.xml")
        for field_path_value_pair in check_fields:
            builtin_obj.log("step: handle {}".format(field_path_value_pair))
            field_values = []
            field_path, field_value_exp = map(str.strip, field_path_value_pair.split('='))
            field_xpath = ""
            for field in field_path.split("/"):
                field_xpath = field_xpath + "//*[matches(@showname, '{}$|{}[ :].*')]".format(field, field)
            builtin_obj.log("debug: field_xpath is {}".format(field_xpath))
            for packet in commonxml_obj1.get_elements("//packet"):
                field_values_under_frame = []
                packet = commonxml_obj1.element_to_string(packet)
                commonxml_obj2 = CommonXML(packet)
                # get frame_number
                frame_number = commonxml_obj2.get_element_attribute(
                    commonxml_obj2.get_element("//*[@name='frame.number']"), "show")
                # get field values under the frame
                all_elements = commonxml_obj2.get_elements(field_xpath)
                for element in all_elements:
                    showname = commonxml_obj2.get_element_attribute(element, "showname")
                    field_values_under_frame.append(showname.split(":", 1)[-1].strip())
                builtin_obj.log(
                    "debug: frame_number={}, field_values={}".format(frame_number, field_values_under_frame))
                field_values.append(field_values_under_frame)

            # get specified packet or all package
            if packet_num == "all":
                field_value_act = [item for sublist in field_values for item in sublist]
            elif packet_num != "all" and len(field_values) < int(packet_num) + 1:
                raise Exception("fail to get packet{}, only {} packets got according to filter and "
                                "field_path".format(packet_num, len(field_values)))
            else:
                field_value_act = field_values[int(packet_num)]

            # compare field value
            builtin_obj.log("debug: compare field value, expected values={}, actual_values={}".format(
                field_value_exp, field_value_act))
            err_info = "checking {} failed, actual values are {}".format(field_path_value_pair, field_value_act)
            if field_value_exp == "not_existing":
                assert len(field_value_act) == 0, err_info
            elif field_value_exp == "existing":
                assert len(field_value_act) > 0, err_info
            else:
                field_value_exp_list = field_value_exp.split(",")
                assert len(field_value_exp_list) == len(field_value_act), err_info + "\n length not equal"
                flag = all(
                    any(self._matches_expected(value_exp, value_act) for value_act in field_value_act)
                    for value_exp in field_value_exp_list
                )
                assert flag, err_info

    def get_wireshark_field_value(self, pcap_file, field_path, display_filter, packet="0"):
        """
        This keyword is to get field value from pcap file and return field value list
        | Arguments      | Man. | Default | Description |
        | pcap_file      | Yes  | NA      | pcap file |
        | field_path     | Yes  | NA      | field path separated by '/', can jump multiple fields |
        | display_filter | Yes  | NA      | wireshark filter |
        | packet         | No   | 0       | packet index, starts from 0. If two packets according to field_path \
        and display_filter, its available is 0 or 1 |

        Example data:
        csi-ReportConfigToAddModList: 9 items
            Item 0
                CSI-ReportConfig
                    reportConfigId: 0
                    resourcesForChannelMeasurement: 0
                    csi-IM-ResourcesForInterference: 11
                    reportConfigType: periodic (0)
                        periodic
                            reportSlotConfig: slots320 (9)
                                slots320: 19
                            pucch-CSI-ResourceList: 1 item

        Example 1:
        | ${slots320_values}    | Get Wireshark Field Value |
        | ...                   | /home/ute/wireshark.pcap |
        | ...                   | csi-ReportConfigToAddModList/slots320 |
        | ...                   | nr-rrc.csi_ReportConfigToAddModList == 9 |
        | ${unique_values}      | Evaluate | list(set(${slots320_values})) |
        | ${value0_number}      | count values in list | ${slots320_values} | ${unique_values[0]} |
        | ${value1_number}      | count values in list | ${slots320_values} | ${unique_values[1]} |
        | Should Be True        | ${value0_number}+${value1_number}==9 |

        Example 2:
        | ${slots320_values}    | Get Wireshark Field Value |
        | ...                   | /home/ute/wireshark.pcap |
        | ...                   | csi-ReportConfigToAddModList: 9 items/slots320 |
        | ...                   | nr-rrc.csi_ReportConfigToAddModList == 9 |
        | ...                   | packet=1 |
        | xxxx |
        """
        return self._get_wireshark_field_value(pcap_file, field_path, display_filter, packet)

    def check_wireshark_fields(self, pcap_file, filter, check_fields, packet_num=0):
        self._check_wireshark_fields(pcap_file, filter, check_fields, packet_num)


if __name__ == "__main__":
    out = """
TShark (Wireshark) 3.4.9.lte.2202.01 (v3.4.9.lte.2202.01+buster-0-g3735bb2ea5d4)

Copyright 1998-2021 Gerald Combs <gerald@wireshark.org> and contributors.
License GPLv2+: GNU GPL version 2 or later <https://www.gnu.org/licenses/gpl-2.0.html>
This is free software; see the source for copying conditions. There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


    """
    print(out.strip().splitlines()[0].split()[2][0:3])
