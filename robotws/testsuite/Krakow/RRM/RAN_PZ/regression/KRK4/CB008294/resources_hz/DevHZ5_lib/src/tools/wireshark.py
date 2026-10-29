# -*- coding:utf-8 -*-

import os
import time
import traceback
import re
import requests
import sys
import collections
import csv
import copy
import html
from bs4 import BeautifulSoup
from common_lib import common_lib
from base_lib.ta_enb_dependency_selector import ta_enb_dependency_selector
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from ute_fsmaccess import ute_fsmaccess
from taf.analyzer.pcap import pcap
from base_lib.ta_xml.common_xml import CommonXML

if sys.version_info.major == 2:
    import ConfigParser as configparser
else:
    import configparser

comm_obj = common_lib()
selector_obj = ta_enb_dependency_selector()
os_obj = OperatingSystem()
builtin_obj = BuiltIn()
pcap_obj = pcap()

# NSETAPX_PLUGIN_URL = r"http://files.ute.nsn-rdnet.net/builds/wireshark/nsetapx/"
NSETAPX_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X"
MCSHARK_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/"
NOKIAF1AP_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/Nokia_F1_AP/"
NOKIAXNAP_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/Nokia_Xn_AP/"

wireshark_protocol_info = {}


class wireshark_plugin(object):
    def __init__(self):
        self._setup_wireshark_plugin_flag = False
        self.wireshark_version = ''
        self.local_plugin_path = ''
        self.plugins = {}
        try:
            reload(sys)
            sys.setdefaultencoding('utf-8')
        except Exception as err:
            pass

    def _setup_wireshark_plugin(self):
        if not self._setup_wireshark_plugin_flag:
            self._setup_wireshark_plugin_flag = True
            builtin_obj.log("step: get wireshak version")
            self.wireshark_version = self._get_wireshark_version()
            self.local_plugin_path = "/home/ute/.local/lib/wireshark/plugins/%s/epan/" % self.wireshark_version
            if not os.path.exists(self.local_plugin_path):
                comm_obj.execute_cmd_on_pc("mkdir -p %s" % self.local_plugin_path)
            else:
                builtin_obj.log("step: clean up plugins")
                comm_obj.execute_cmd_on_pc("rm -rf {}/*mcshark*.so".format(self.local_plugin_path))
                comm_obj.execute_cmd_on_pc("rm -rf {}/*nsetapx*.so".format(self.local_plugin_path))
                comm_obj.execute_cmd_on_pc("rm -rf {}/*nokiaf1ap*.so".format(self.local_plugin_path))
                comm_obj.execute_cmd_on_pc("rm -rf {}/*nokiaxnap*.so".format(self.local_plugin_path))
                comm_obj.execute_cmd_on_pc("ls -ltr {}".format(self.local_plugin_path))

            # get gnb version
            self.bts_version = comm_obj.get_gnb_sw_version()
            if self.bts_version.count("_9999_") or self.bts_version.count("_9990_"):
                self.bts_version = "SBTS00_" + self.bts_version.partition("_")[-1]

            # check plugin situation in wireshark global install folder
            glb_pulgin_path = "/usr/lib/x86_64-linux-gnu/wireshark/plugins/%s/epan" % self.wireshark_version
            if os.path.exists(glb_pulgin_path):
                builtin_obj.log("step: check global wireshark plugin folder")
                comm_obj.execute_cmd_on_pc("ls -lrt {}".format(glb_pulgin_path))

    def _get_wireshark_version(self):
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

    def _get_supported_mcshark_version(self, gnb_version):
        r = requests.get(MCSHARK_PLUGIN_URL)
        soup = BeautifulSoup(r.content, 'lxml')
        # check gnb_version exists in library
        build_pattern = re.compile(r'.*">({}.*)/</a>.*'.format(gnb_version))
        builds = build_pattern.findall(str(soup))
        if not builds:
            # if gnb version do not mcshark and find lastest version return
            gnb_release = gnb_version.partition("_")[0]
            build_prefix = gnb_release + '_ENB_'
            build_pattern = re.compile(r'.*">({}.*)/</a>.*'.format(build_prefix))
            builds = build_pattern.findall(str(soup))
            if not builds:
                raise Exception("no any mcshark plugin match for gnb version: {}".format(gnb_version))
            else:
                return builds[-1]
        else:
            return builds[0]

    def _get_mcshark_plugin_file_name(self, wireshark_version, gnb_version):
        # get supported mcshark file name
        save_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        comm_obj.execute_cmd_on_pc("wget {}".format(MCSHARK_PLUGIN_URL))
        comm_obj.execute_cmd_on_pc("mv index.html {}/mcshark_list.html".format(save_log_dir))
        r = requests.get("{}/{}/".format(MCSHARK_PLUGIN_URL, gnb_version))
        soup = BeautifulSoup(r.content, 'lxml')
        mcshark_plugin_file_name = ""
        for a_tag in soup.find_all('a')[::-1]:
            search_result = re.search("mcshark-{}.*{}.*buster.so$".format(wireshark_version, gnb_version),
                                      a_tag.text)
            if search_result:
                mcshark_plugin_file_name = search_result.group(0)
                break
        if not mcshark_plugin_file_name:
            raise Exception("get mcshark pulgin file name failure. gnb_version is {}"
                            .format(gnb_version))
        else:
            return mcshark_plugin_file_name

    def _download_wireshark_mcshark_plugin(self):
        self._setup_wireshark_plugin()
        builtin_obj.log("step: get mcshark download path")
        supported_gnb_version = self._get_supported_mcshark_version(self.bts_version)
        builtin_obj.log("debug: supported_gnb_version={}".format(supported_gnb_version))
        mcshark_pulgin_file = self._get_mcshark_plugin_file_name(self.wireshark_version, supported_gnb_version)
        builtin_obj.log("debug: mcshark_pulgin_file={}".format(mcshark_pulgin_file))
        builtin_obj.log("step: download mcshark")
        self._download_plugin_to_specific_folder(
            plugin_url="{}/{}".format(MCSHARK_PLUGIN_URL, supported_gnb_version),
            plugin_file=mcshark_pulgin_file,
            local_plugin_path=self.local_plugin_path
        )

        builtin_obj.log("step: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc(" tshark -G plugins")
        if "mcshark" not in active_plugins:
            self._download_plugin_to_specific_folder(
                plugin_url="{}/{}".format(MCSHARK_PLUGIN_URL, supported_gnb_version),
                plugin_file=mcshark_pulgin_file,
                local_plugin_path=self.local_plugin_path
            )
            builtin_obj.log("step: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "mcshark" not in active_plugins:
                raise Exception("fail to download mcshark plugin")

    def _get_nokiaf1ap_plugin_file_name(self, wireshark_version, plugin_folder_name):
        r = requests.get("{}/{}/".format(NOKIAF1AP_PLUGIN_URL, plugin_folder_name))
        soup = BeautifulSoup(r.content, 'lxml')
        nokiaf1ap_plugin_file_name = ""
        for a_tag in soup.find_all('a')[::-1]:
            search_result = re.search("nokiaf1ap-{}-.*buster.so$".format(wireshark_version),
                                      a_tag.text)
            if search_result:
                nokiaf1ap_plugin_file_name = search_result.group(0)
                break
        if not nokiaf1ap_plugin_file_name:
            raise Exception("get nokiaf1ap pulgin file name failure")
        else:
            return nokiaf1ap_plugin_file_name

    def _get_nokiaxnap_plugin_file_name(self, wireshark_version, plugin_folder_name):
        r = requests.get("{}/{}/".format(NOKIAXNAP_PLUGIN_URL, plugin_folder_name))
        soup = BeautifulSoup(r.content, 'lxml')
        nokiaxnap_plugin_file_name = ""
        for a_tag in soup.find_all('a')[::-1]:
            search_result = re.search("nokiaxnap-{}-.*buster.so$".format(wireshark_version),
                                      a_tag.text)
            if search_result:
                nokiaxnap_plugin_file_name = search_result.group(0)
                break
        if not nokiaxnap_plugin_file_name:
            raise Exception("get nokiaxnap pulgin file name failure")
        else:
            return nokiaxnap_plugin_file_name

    def _get_nsetapx_plugin_file_name(self, wireshark_version, plugin_folder_name):
        r = requests.get("{}/{}/".format(NSETAPX_PLUGIN_URL, plugin_folder_name))
        soup = BeautifulSoup(r.content, 'lxml')
        nsetapx_plugin_file_name = ""
        for a_tag in soup.find_all('a')[::-1]:
            search_result = re.search("nsetapx-{}-.*buster.so$".format(wireshark_version),
                                      a_tag.text)
            if search_result:
                nsetapx_plugin_file_name = search_result.group(0)
                break
        if not nsetapx_plugin_file_name:
            raise Exception("get nsetapx pulgin file name failure")
        else:
            return nsetapx_plugin_file_name

    def _download_wireshark_nokiaf1ap_plugin(self):
        self._setup_wireshark_plugin()
        # do nothing if NOKIA_F1AP_PLUGIN_FLAG=False
        nokiaf1ap_plugin_flag = builtin_obj.convert_to_boolean(
            builtin_obj.get_variable_value('${NOKIA_F1AP_PLUGIN_FLAG}'))
        if nokiaf1ap_plugin_flag is not True:
            return

        builtin_obj.log("step: get nokiaf1ap download path")
        nokiaf1ap_plugin_ver = builtin_obj.get_variable_value("${NOKIA_F1AP_PLUGIN_VERSION}")
        if len(nokiaf1ap_plugin_ver):
            nokiaf1ap_plugin_folder_name = "nokiaf1ap-" + nokiaf1ap_plugin_ver
        else:
            try:
                self._get_matched_plugin_folder_name()
                nokiaf1ap_plugin_folder_name = self.plugins["nokiaf1ap"]
            except Exception:
                builtin_obj.log("fail to get matched nokiaf1ap plugin version, try the latest", level="WARN")
                nokiaf1ap_plugin_folder_name = self._get_latest_plugin_folder_name(plugin_name="nokiaf1ap",
                                                                                   plugin_address=NOKIAF1AP_PLUGIN_URL)
        nokiaf1ap_pulgin_file = self._get_nokiaf1ap_plugin_file_name(self.wireshark_version,
                                                                     nokiaf1ap_plugin_folder_name)
        builtin_obj.log("nokiaf1ap download path: {}/{}/{}".format(NOKIAF1AP_PLUGIN_URL,
                                                                   nokiaf1ap_plugin_folder_name,
                                                                   nokiaf1ap_pulgin_file))
        # download plugin, retry 1 time if failed
        builtin_obj.log("step: download nokiaf1ap")
        self._download_plugin_to_specific_folder(
            plugin_url="{}/{}".format(NOKIAF1AP_PLUGIN_URL, nokiaf1ap_plugin_folder_name),
            plugin_file=nokiaf1ap_pulgin_file,
            local_plugin_path=self.local_plugin_path)
        builtin_obj.log("step: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc(" tshark -G plugins")
        if "nokiaf1ap" not in active_plugins:
            builtin_obj.log("step: download nokiaf1ap")
            self._download_plugin_to_specific_folder(
                plugin_url="{}/{}".format(NOKIAF1AP_PLUGIN_URL, nokiaf1ap_plugin_folder_name),
                plugin_file=nokiaf1ap_pulgin_file,
                local_plugin_path=self.local_plugin_path)
            builtin_obj.log("step: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "nokiaf1ap" not in active_plugins:
                raise Exception("fail to download nokiaf1ap plugin")

    def _download_wireshark_nokiaxnap_plugin(self):
        self._setup_wireshark_plugin()
        # do nothing if NOKIA_XNAP_PLUGIN_FLAG=False
        nokiaxnap_plugin_flag = builtin_obj.convert_to_boolean(
            builtin_obj.get_variable_value('${NOKIA_XNAP_PLUGIN_FLAG}'))
        if nokiaxnap_plugin_flag is not True:
            return

        builtin_obj.log("step: get nokiaxnap download path")
        nokiaxnap_plugin_ver = builtin_obj.get_variable_value("${NOKIA_XNAP_PLUGIN_VERSION}")
        if len(nokiaxnap_plugin_ver):
            nokiaxnap_plugin_folder_name = "nokiaxnap-" + nokiaxnap_plugin_ver
        else:
            try:
                self._get_matched_plugin_folder_name()
                nokiaxnap_plugin_folder_name = self.plugins["nokiaxnap"]
            except Exception:
                builtin_obj.log("fail to get matched nokiaxnap plugin version, try the latest", level="WARN")
                nokiaxnap_plugin_folder_name = self._get_latest_plugin_folder_name(plugin_name="nokiaxnap",
                                                                                   plugin_address=NOKIAXNAP_PLUGIN_URL)
        nokiaxnap_pulgin_file = self._get_nokiaxnap_plugin_file_name(self.wireshark_version,
                                                                     nokiaxnap_plugin_folder_name)
        builtin_obj.log("nokiaxnap download path: {}/{}/{}".format(NOKIAXNAP_PLUGIN_URL,
                                                                   nokiaxnap_plugin_folder_name,
                                                                   nokiaxnap_pulgin_file))
        # download plugin, retry 1 time if failed
        builtin_obj.log("step: download nokiaxnap")
        self._download_plugin_to_specific_folder(
            plugin_url="{}/{}".format(NOKIAXNAP_PLUGIN_URL, nokiaxnap_plugin_folder_name),
            plugin_file=nokiaxnap_pulgin_file,
            local_plugin_path=self.local_plugin_path
        )
        builtin_obj.log("step: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc(" tshark -G plugins")
        if "nokiaxnap" not in active_plugins:
            builtin_obj.log("step: download nokiaxnap")
            self._download_plugin_to_specific_folder(
                plugin_url="{}/{}".format(NOKIAXNAP_PLUGIN_URL, nokiaxnap_plugin_folder_name),
                plugin_file=nokiaxnap_pulgin_file,
                local_plugin_path=self.local_plugin_path)
            builtin_obj.log("step: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "nokiaxnap" not in active_plugins:
                raise Exception("fail to download nokiaxnap plugin")

    def _download_wireshark_nsetapx_plugin(self):
        self._setup_wireshark_plugin()
        builtin_obj.log("step: get nsetapx download path")
        nsetapx_plugin_ver = builtin_obj.get_variable_value("${NSETAPX_PLUGIN_VERSION}")
        builtin_obj.log("debug: nsetapx_plugin_ver={}, length={}".format(nsetapx_plugin_ver, len(nsetapx_plugin_ver)))
        if len(nsetapx_plugin_ver):
            nsetapx_plugin_folder_name = "nsetapx-" + nsetapx_plugin_ver
        else:
            nsetapx_plugin_folder_name = self._get_latest_plugin_folder_name(plugin_name="nsetapx",
                                                                             plugin_address=NSETAPX_PLUGIN_URL)
        nsetapx_pulgin_file = self._get_nsetapx_plugin_file_name(self.wireshark_version, nsetapx_plugin_folder_name)
        builtin_obj.log("nsetapx download path: {}/{}/{}".format(NSETAPX_PLUGIN_URL,
                                                                 nsetapx_plugin_folder_name,
                                                                 nsetapx_pulgin_file))

        # download plugin, retry 1 time if failed
        builtin_obj.log("step: download nsetapx")
        self._download_plugin_to_specific_folder(
            plugin_url="{}/{}".format(NSETAPX_PLUGIN_URL, nsetapx_plugin_folder_name),
            plugin_file=nsetapx_pulgin_file,
            local_plugin_path=self.local_plugin_path)

        builtin_obj.log("step: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
        if "nsetapx" not in active_plugins:
            builtin_obj.log("step: download nsetapx")
            self._download_plugin_to_specific_folder(
                plugin_url="{}/{}".format(NSETAPX_PLUGIN_URL, nsetapx_plugin_folder_name),
                plugin_file=nsetapx_pulgin_file,
                local_plugin_path=self.local_plugin_path)
            builtin_obj.log("step: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "nsetapx" not in active_plugins:
                raise Exception("fail to download nsetapx plugin")

    def _download_plugin_to_specific_folder(self, plugin_url, plugin_file, local_plugin_path):
        os.system("sudo chmod 777 %s" % local_plugin_path)
        comm_obj.execute_cmd_on_pc("cd {}".format(local_plugin_path))
        comm_obj.execute_cmd_on_pc("wget {}/{}".format(plugin_url, plugin_file))

    def _get_matched_plugin_folder_name(self):
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
                'PASSWORD': "Cplansg4@123",
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

    def _get_latest_plugin_folder_name(self, plugin_name, plugin_address):
        builtin_obj.log("debug: get latest {} plugin".format(plugin_name))
        try:
            r = requests.get(plugin_address)
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

    def download_wireshark_plugin(self):
        # download nsetapx plugin
        try:
            self._download_wireshark_nsetapx_plugin()
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("download wireshark nsetapx plugin failure. {}".format(details))
            builtin_obj.log("download wireshark nsetapx plugin failure.", level="WARN")

        # download mcshark plugin
        try:
            self._download_wireshark_mcshark_plugin()
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("download wireshark mcshark plugin failure. {}".format(details))
            builtin_obj.log("download wireshark mcshark plugin failure.", level="WARN")

        # donwload nokiaf1ap plugin
        try:
            self._download_wireshark_nokiaf1ap_plugin()
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("download wireshark nokiaf1ap plugin failure. {}".format(details))
            builtin_obj.log("download wireshark nokiaf1ap plugin failure.", level="WARN")

        # donwload nokiaxnap plugin
        try:
            self._download_wireshark_nokiaxnap_plugin()
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("download wireshark nokiaxnap plugin failure. {}".format(details))
            builtin_obj.log("download wireshark nokiaxnap plugin failure.", level="WARN")


class wireshark_log_base(object):
    def __init__(self, alias):
        self.alias = alias
        self.remote_host = None
        self.bts_host = "192.168.255.129"
        self._setup_wireshark_flag = False

    def _delete_pcap_when_setup_wireshark(self):
        # stop all wireshark and remove wireshark logs
        builtin_obj.log("step: stop all wireshark and remove wireshark logs")
        # kill tcpdump
        self._execute_cmd_on_bts("ps -ef | grep 'tcpdump' | grep -v -w grep")
        self._execute_cmd_on_bts("ps aux | grep tcpdump | grep -v -w grep | awk '{print $2}' | xargs kill -9")
        self._execute_cmd_on_bts("ps -ef | grep 'tcpdump' | grep -v -w grep")

        # delete /ffs/run/logs/*.pcap*
        self._execute_cmd_on_bts("ls -ltrh /ffs/run/logs/*.pcap*")
        self._execute_cmd_on_bts("rm -rf /ffs/run/logs/*.pcap*")
        self._execute_cmd_on_bts("ls -ltrh /ffs/run/logs/*.pcap*")

        # delete /var/tmp/*.pcap*
        self._execute_cmd_on_bts("ls -ltrh /var/tmp/*.pcap*")
        self._execute_cmd_on_bts("rm -rf /var/tmp/*.pcap*")
        self._execute_cmd_on_bts("ls -ltrh /var/tmp/*.pcap*")

        self._execute_cmd_on_bts("df -h /ffs/run/logs/;df -h /var/tmp/;df -h /var/log/")

    def _setup_wireshark(self):
        if not self._setup_wireshark_flag:
            self._setup_wireshark_flag = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#",
                                              host="192.168.255.129")
            self._delete_pcap_when_setup_wireshark()

    def __del__(self):
        if self._setup_wireshark_flag:
            self.fsm_obj.teardown_all_aliases_for_enb_fsmaccess()

    def _execute_cmd_on_bts(self, cmd):
        if self.alias == "gnb1":
            return comm_obj.execute_cmd_on_gnb(cmd, board="auto")
        else:
            return comm_obj.execute_cmd_on_gnb2(cmd, board="auto")

    def _start_to_capture_wireshark_log(self, tag):
        self._setup_wireshark()
        wireshark_ports = [
            "38412",  # NGAP
            "38472",  # F1AP
            "38462",  # E1AP
            "38422",  # XNAP
            "36422",  # X2AP
            "49150",  # PCMD
        ]
        syscom_flag = builtin_obj.get_variable_value("${SYSCOM_FLAG}")
        if syscom_flag:
            wireshark_ports.append("29211")  # SYSCOM
        wireshark_name = "wireshark" if tag.count("startup") or len(tag) == 0 else "wireshark_{}".format(tag)
        # stop all wireshark and remove wireshark logs
        builtin_obj.log("step: stop all wireshark and remove wireshark logs")
        self._execute_cmd_on_bts("ps -ef | grep 'tcpdump' | grep -v -w grep")
        self._execute_cmd_on_bts(
            "ps aux | grep wireshark | grep -v -w grep | awk '{print $2}' | xargs kill -9")
        self._execute_cmd_on_bts("ps -ef | grep 'tcpdump' | grep -v -w grep")
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("rm -rf /tmp/wireshark*.pcap /tmp/cpue_*.pcap /tmp/x2.pcap")
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("df -h /tmp/;df -h /var/tmp/;df -h /var/log/")
        # start wireshark
        builtin_obj.log("step: start wireshark")
        wireshark_cmd = "nohup tcpdump -n -X -tt -i any -w /tmp/{}.pcap".format(wireshark_name)
        wireshark_cmd = wireshark_cmd + " port {}".format(wireshark_ports[0])
        for port in wireshark_ports[1:]:
            wireshark_cmd = wireshark_cmd + " or {}".format(port)
        wireshark_cmd = wireshark_cmd + " > /tmp/nohup_w1.out 2>&1 &"
        self._execute_cmd_on_bts(wireshark_cmd)
        time.sleep(10)
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")

    def _start_to_capture_xpsyscom_log(self, tag):
        self._setup_wireshark()
        xpsyscom_flag = builtin_obj.get_variable_value("${xpsyscom_FLAG}")
        if xpsyscom_flag:
            # stop all xpsyscom and remove xpsyscom logs
            builtin_obj.log("step: stop all xpsyscom and remove xpsyscom logs")
            self._execute_cmd_on_bts("ps -ef | grep 'xpsyscom' | grep -v -w grep")
            self._execute_cmd_on_bts(
                "ps aux | grep xpsyscom | grep -v -w grep | awk '{print $2}' | xargs kill -9")
            self._execute_cmd_on_bts("ps -ef | grep 'xpsyscom' | grep -v -w grep")
            self._execute_cmd_on_bts("rm -rf /tmp/xpsyscom*.pcap")

            # start xpsyscom
            xpsyscom_name = "xpsyscom" if tag.count("startup") or len(tag) == 0 \
                else "xpsyscom_{}".format(tag)
            xpsyscom_cmd = "syscomdump -w xp_syscom_pri_gnb.pcap -w /tmp/{}.pcap".format(xpsyscom_name)
            builtin_obj.log("step: start xpsyscom")
            xpsyscom_cmd = xpsyscom_cmd + " > /tmp/xpsyscom_w1.out 2>&1 &"
            self._execute_cmd_on_bts(xpsyscom_cmd)

    def _stop_capture_wireshark_log(self, tag, decode_option, decode_flag=True):
        self._setup_wireshark()
        wireshark_name = "wireshark" if tag.count("startup") or len(tag) == 0 else "wireshark_{}".format(tag)
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        wireshark_dir = "{}/{}_logs/".format(save_log_dir, tag) if tag.count("startup") else save_log_dir
        # kill wireshark, also consider case failed and wireshark started by case is not collected yet
        builtin_obj.log("step: kill wireshark")
        out_put = self._execute_cmd_on_bts("ps -ef | grep 'tcpdump' | grep -v -w grep")
        if out_put:
            time.sleep(10)
        out = self._execute_cmd_on_bts(
            "ps aux | grep wireshark | grep -v -w grep | awk '{print $2}' | xargs kill -9")
        if out.count("kill: no process ID specified"):
            # wireshark has been stopped before
            return

        # download wireshark, also consider case failed and wireshark started by case is not collected yet
        builtin_obj.log("step: download wireshark")
        time.sleep(10)
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("df -h /tmp/;df -h /var/tmp/;df -h /var/log/")
        self.fsm_obj.get_enb_file("/tmp/wireshark*.pcap", wireshark_dir, alias=self.alias)

        # convert pcap to txt, only decode wireshark specified by input tag
        if decode_flag:
            if tag.count("startup") == 0:
                wireshark_in_gnb = self._execute_cmd_on_bts("ls /tmp/wireshark*.pcap").strip().splitlines()
                if len(wireshark_in_gnb) == 1 and wireshark_in_gnb[0].split("/")[-1].rstrip(".pcap") == wireshark_name:
                    builtin_obj.log("step: decode wireshark")
                    try:
                        self._decode_wireshark(wireshark_dir, wireshark_name, decode_option)
                    except Exception:
                        detail = traceback.format_exc()
                        builtin_obj.log("debug: fail to decode {}/{}.pcap:{}".format(wireshark_dir, wireshark_name,
                                                                                     detail))

        # delete wireshark Tag pcap
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("rm -rf /tmp/%s.pcap" % wireshark_name)
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("df -h /tmp/;df -h /var/tmp/;df -h /var/log/")

    def _stop_capture_xpsyscom_log(self, tag):
        self._setup_wireshark()
        wireshark_name = "xpsyscom" if tag.count("startup") or len(tag) == 0 else "xpsyscom_{}".format(tag)
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        wireshark_dir = "{}/{}_logs/".format(save_log_dir, tag) if tag.count("startup") else save_log_dir
        # kill wireshark, also consider case failed and wireshark started by case is not collected yet
        builtin_obj.log("step: kill xpsyscom")
        out_put = self._execute_cmd_on_bts("ps -ef | grep 'xpsyscom' | grep -v -w grep")
        if out_put:
            time.sleep(10)
        out = self._execute_cmd_on_bts(
            "ps aux | grep xpsyscom | grep -v -w grep | awk '{print $2}' | xargs kill -9")
        if out.count("kill: no process ID specified"):
            # wireshark has been stopped before
            return

        # download wireshark, also consider case failed and wireshark started by case is not collected yet
        builtin_obj.log("step: download xpsyscom")
        time.sleep(10)
        self._execute_cmd_on_bts("ls -ltrh /tmp/xpsyscom*.pcap")
        self.fsm_obj.get_enb_file("/tmp/xpsyscom*.pcap", wireshark_dir, alias=self.alias)

        # delete wireshark Tag pcap
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("rm -rf /tmp/xpsyscom%s.pcap" % tag)
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("df -h /tmp/;df -h /var/tmp/;df -h /var/log/")

    def _decode_wireshark(self, wireshark_dir, wireshark_name, decode_option):
        tce_port = builtin_obj.get_variable_value('${TCE_PORT}')
        oms_port = builtin_obj.get_variable_value('${OMS_PORT}')
        wireshark_pcap = "{}/{}.pcap".format(wireshark_dir, wireshark_name)
        wireshark_txt = "{}/{}.txt".format(wireshark_dir, wireshark_name)
        decode_cmd = "tshark -r {} -o ntrstr.defragment:TRUE {} " \
                     "-d tcp.port=={},ntrstr -d tcp.port=={},ntrstr -V > {}".format(wireshark_pcap,
                                                                                    decode_option,
                                                                                    tce_port,
                                                                                    oms_port,
                                                                                    wireshark_txt)
        comm_obj.execute_cmd_on_pc(decode_cmd, timeout='30')
        return wireshark_txt

    def _download_and_decode_wireshark(self, wireshark_name, decode_option):
        self._setup_wireshark()
        # download wireshark log
        builtin_obj.log("step: download wireshark")
        wireshark_dir = comm_obj._get_save_log_dir(self.alias)
        self._execute_cmd_on_bts("ls -ltrh /tmp/wireshark*")
        self._execute_cmd_on_bts("df -h /tmp/;df -h /var/tmp/;df -h /var/log/")
        self.fsm_obj.get_enb_file("/tmp/{}.pcap".format(wireshark_name), wireshark_dir, alias=self.alias)
        # convert pcap to txt
        builtin_obj.log("step: decode wireshark")
        wireshark_txt = self._decode_wireshark(wireshark_dir, wireshark_name, decode_option)
        # validate wireshark txt
        builtin_obj.log("step: validate wireshark txt")
        if not os.path.exists(wireshark_txt):
            builtin_obj.log("fail to decode {}.pcap to txt, {}.txt doesn't exist".format(
                wireshark_name, wireshark_name), level="WARN")
        if os.path.getsize(wireshark_txt) == 0:
            builtin_obj.log("fail to decode {}.pcap to txt, {}.txt size is 0".format(wireshark_name, wireshark_name),
                            level="WARN")
        return wireshark_txt

    def _stop_wireshark_log_after_string_found(self, tag, string, decode_option):
        wireshark_name = "wireshark" if len(tag) == 0 else "wireshark_{}".format(tag)
        string = string if string.count("::") else "{}::1".format(string)
        expect_string, expect_times = string.split("::")
        time.sleep(10)
        # wait string in wireshark log with timeout 2min and interval 10s
        maxtime = time.time() + 120
        while time.time() < maxtime:
            try:
                wireshark_txt = self._download_and_decode_wireshark(wireshark_name, decode_option)
                builtin_obj.log("step: check string in wireshark txt")
                comm_obj.file_contain_string_no_less_than(wireshark_txt, expect_string, expect_times)
                break
            except Exception as e:
                builtin_obj.log("debug: {}".format(e))
                time.sleep(10)

        # warn if wait_sting improper
        builtin_obj.log("step: warn if wait_sting improper")
        actual_times = comm_obj.count_string_in_file(wireshark_txt, expect_string)
        if actual_times != int(expect_times):
            builtin_obj.log("{} contains {} for {} times, not equal to expected times: {}".format(
                wireshark_txt, expect_string, actual_times, expect_times), level="WARN")

        # kill wireshark
        builtin_obj.log("step: kill wireshark")
        self._execute_cmd_on_bts("ps -ef | grep 'tcpdump' | grep -v -w grep")
        self._execute_cmd_on_bts(
            "ps aux | grep '%s' | grep -v -w grep | awk '{print $2}' | xargs kill -9" % wireshark_name)
        self._execute_cmd_on_bts("ps -ef | grep 'tcpdump' | grep -v -w grep")

        # delete wireshark Tag pcap
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("rm -rf /tmp/%s.pcap" % wireshark_name)
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("df -h /tmp/;df -h /var/tmp/;df -h /var/log/")

    def _get_protocol_version_from_wireshark(self):
        """
        This keyword is used to get field value on wireshark pcap by setting filter condition.
        | step1 | download wireshark pcap file. |
        | step2 | set condition of lookup on this pcap and return specific field value. |

        | Input Parameters   | Man. | Default  | Description |
        | None               | None | None     |  None       |

        return: list of values

        Examples:
            ${IgNBCAXpProtocol_Version}    Get Xp Verison
            ${IgNBCAXgUProtocol_Version}    Get Xgu Verison
        """
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        local_wireshark_protocol_path = save_log_dir + "wireshark_protocol.pcap"
        xp_field_name = "nokiaf1ap.IgNBCAXpProtocolVersion"
        xp_filter = "(nokiaf1ap.procedureCode == 14) && (nokiaf1ap.IgNBCAXpProtocolVersion)"
        xgu_field_name = "nokiaf1ap.IgNBCAXgUProtocolVersion"
        xgu_filter = "(nokiaf1ap.procedureCode == 14) && (nokiaf1ap.IgNBCAXgUProtocolVersion)"

        if wireshark_protocol_info == {}:
            time.sleep(10)
            # wait string in wireshark log with timeout 2min and interval 10s
            maxtime = time.time() + 120
            while time.time() < maxtime:
                builtin_obj.log("====================================================================================")
                try:
                    builtin_obj.log("step: download /tmp/wireshark.pcap to %s" % local_wireshark_protocol_path)
                    self.fsm_obj.get_enb_file("/tmp/wireshark.pcap", local_wireshark_protocol_path, alias=self.alias)
                    builtin_obj.log("step: check string in wireshark")
                    # get xp string "show"
                    pcap_obj.setup(infile=local_wireshark_protocol_path, alias="xp_version", display_filter=xp_filter)
                    pcap_obj.get_packets(pcap_parser="xp_version", filter=xp_filter)
                    wireshark_protocol_info["IgNBCAXpProtocol_Version"] = \
                        pcap_obj.get_field_value(pcap_parser="xp_version", fmt="show",
                                                 field_name=xp_field_name, filter=xp_filter)[0]
                    # get xgu string "show"
                    pcap_obj.setup(infile=local_wireshark_protocol_path, alias="xgu_version", display_filter=xgu_filter)
                    pcap_obj.get_packets(pcap_parser="xgu_version", filter=xgu_filter)
                    wireshark_protocol_info["IgNBCAXgUProtocol_Version"] = \
                        pcap_obj.get_field_value(pcap_parser="xgu_version", fmt="show",
                                                 field_name=xgu_field_name, filter=xgu_filter)[0]

                    builtin_obj.log("step: wireshark_protocol_info =[%s]" % wireshark_protocol_info)
                    if wireshark_protocol_info != {}:
                        break
                except Exception as e:
                    builtin_obj.log("debug: {}".format(e))
                    time.sleep(10)

    def _get_elem_value_from_pcap(self, cap_file="", element_expression="", display_filter="", timeout=60):
        """
        This keyword is used to get field value on wireshark pcap by setting filter condition.
        | step1 | set condition of lookup on this pcap and return specific field value. |

        | Input Parameters   | Man. | Default  | Description |
        | cap_file           | None | None     |  pcap path  |
        | element_expression | None | None     |  Wireshark field expression |
        | display_filter     | None | None     |  pcap parser alias name     |
        | timeout            | None |  60      |  None       |

        return: list of values

        Examples:
            Get Wireshark Field Value    cap_file=${SAVE LOG DIRECTORY}${/}gnb_bip_logs_pagingUE1/mirroring_L2L1.pcap
            ...    element_expression=_3gpp.slot
            ...    display_filter=DlData_PdschGrant.mcs == 0 && 3gpp.rnti == 65534

        Guide: https://confluence.ext.net.nokia.com/display/5GRANHZ/taf.analyzer.pcap
        """
        elem_values_info = {}
        # wait string in wireshark log with timeout 1min and interval 10s
        maxtime = time.time() + timeout
        while time.time() < maxtime:
            builtin_obj.log("\r\n====================================================================================")
            try:
                # <field name="3gpp.slot" showname="slot (Uint8): 0" size="1" pos="42" show="0" value="00"/>
                # fmt: return value format, default is “show” e.g “show”, “value” and “showname”.
                # get elem string "value"
                builtin_obj.log("step: pcap_obj.setup")
                pcap_obj.setup(infile=cap_file, alias="elem1")
                builtin_obj.log("step: pcap_obj.get_packets")
                pcap_obj.get_packets(pcap_parser="elem1")
                builtin_obj.log("step: check string in wireshark,field_name=%s, display_filter=%s"
                                % (element_expression, display_filter))
                elem_values_info["elem"] = pcap_obj.get_field_value(pcap_parser="elem1", fmt="show",
                                                                    field_name=element_expression,
                                                                    filter=display_filter)[0]
                builtin_obj.log("step: elem_values = %s" % elem_values_info)
                if elem_values_info != {}:
                    return elem_values_info["elem"]
                time.sleep(3)
            except Exception as e:
                builtin_obj.log("debug: Find no value [{}]".format(e))
                time.sleep(2)

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

    def _generate_pucch_csv_from_wireshark(self, wireshark_pcap, flag="ra"):
        try:
            wireshark_pcap_dir = os.path.abspath(os.path.dirname(wireshark_pcap))
            wireshark_pcap_name = os.path.basename(wireshark_pcap)
            if flag == "ra":
                wireshark_ra_txt = os.path.join(wireshark_pcap_dir, "%s_ra.txt" % wireshark_pcap_name.split(".")[0], )
                ra_tshark_command = 'tshark -r %s -Y "((x2ap.procedureCode==27)&&(x2ap.id==211))||(nr-rrc.c1==1)" ' \
                                    '-V > %s' % (wireshark_pcap, wireshark_ra_txt)
                comm_obj.execute_cmd_on_pc(ra_tshark_command, timeout='30')
                if os.path.exists(wireshark_ra_txt):
                    with open(wireshark_ra_txt) as f:
                        ra_txt = f.read()
                    res_ra = {}
                else:
                    raise Exception("Flag is '%s', but ra_txt file was transfered from pcap not exist under '%s'."
                                    % (flag, wireshark_pcap_dir))

                # Split every frame(SA/NSA UE) message
                ra_frames = re.findall(pattern=r"Frame.+?^\s*$", string=ra_txt, flags=re.M | re.S)
                for pkg in ra_frames:
                    frame_num = re.search(pattern=r"Frame Number: (\d+)", string=pkg).group(1)
                    sa_or_nsa_flag = re.search(pattern=r"(F1 Application Protocol|EUTRAN X2 Application Protocol)",
                                               string=pkg).group()
                    if sa_or_nsa_flag == "F1 Application Protocol":
                        # SA UE
                        ue_du_f1ap_id = re.search(pattern=r"GNB-DU-UE-F1AP-ID:\s*(\d+)", string=pkg).group(1)
                        ra_ue_id = "sa_ue^{}".format(ue_du_f1ap_id)
                    elif sa_or_nsa_flag == "EUTRAN X2 Application Protocol":
                        # NSA UE
                        ue_x2ap_id = re.search(pattern=r"SgNB-UE-X2AP-ID:\s*(\d+)", string=pkg).group(1)
                        ra_ue_id = "nsa_ue^{}".format(ue_x2ap_id)
                    res_ra[(ra_ue_id, frame_num)] = {}

                    sr_left_space_num = len(re.search(pattern=r"uplinkConfig.*uplinkBWP-ToAddModList.*BWP-Uplink"
                                                              r".*bwp-Dedicated.*pucch-Config.*setup.*\n"
                                                              r"(\s*)schedulingRequestResourceToAddModList: "
                                                              r"\d+ (item|items)\n",
                                                      string=pkg,
                                                      flags=re.DOTALL).group(1))
                    sr_part1 = re.search(pattern=r"uplinkConfig.*uplinkBWP-ToAddModList.*BWP-Uplink.*bwp-Dedicated"
                                                 r".*pucch-Config.*setup.*\n(\s{%d}"
                                                 r"schedulingRequestResourceToAddModList"
                                                 r".+?\n)\s{%d}\S+" % (sr_left_space_num, sr_left_space_num),
                                         string=pkg,
                                         flags=re.DOTALL).group(1)

                    # sr period;slot
                    sr_period = re.search(pattern=r"periodicityAndOffset: (\S+) \(\d+\)", string=sr_part1).group(1)
                    sr_slot = re.search(pattern=r"%s: (\d+)" % sr_period, string=sr_part1).group(1)
                    sr_pucch_resource_id = re.search(pattern=r"resource: (\d+)", string=sr_part1).group(1)
                    res_ra[(ra_ue_id, frame_num)]["sr_period"] = sr_period
                    res_ra[(ra_ue_id, frame_num)]["sr_slot"] = sr_slot

                    # sr starting_prb;hopping_prb;cs;occ
                    sr_part2_left_space_num = len(
                        re.search(pattern=r"uplinkConfig.*uplinkBWP-ToAddModList.*BWP-Uplink.*"
                                          r"bwp-Dedicated.*pucch-Config.*setup.*\n"
                                          r"(\s*)resourceToAddModList: \d+ (item|items)\n",
                                  string=pkg,
                                  flags=re.DOTALL).group(1))
                    sr_part2 = re.search(pattern=r"uplinkConfig.*uplinkBWP-ToAddModList.*BWP-Uplink.*bwp-Dedicated.*"
                                                 r"pucch-Config.*setup.*\n"
                                                 r"(\s{%d}resourceToAddModList.+?\n)\s{%d}\S+"
                                                 % (sr_left_space_num, sr_left_space_num),
                                         string=pkg,
                                         flags=re.M | re.S).group(1)
                    pucch_resource_pool = re.findall(pattern=r"(\s*Item \d+.*?)(?=\s*Item \d+|$)",
                                                     string=sr_part2,
                                                     flags=re.DOTALL)
                    for item in pucch_resource_pool:
                        pucch_resource_id = re.search(pattern=r"pucch-ResourceId: (\d+)\n", string=item).group(1)
                        if pucch_resource_id == sr_pucch_resource_id:
                            sr_starting_prb = re.search(pattern=r"startingPRB: (\d+)", string=item).group(1)
                            sr_hopping_prb = re.search(pattern=r"secondHopPRB: (\d+)", string=item).group(1)
                            sr_cs = re.search(pattern=r"initialCyclicShift: (\d+)", string=item).group(1)
                            sr_occ = re.search(pattern=r"timeDomainOCC: (\d+)", string=item).group(1)
                            break
                        else:
                            continue
                    res_ra[(ra_ue_id, frame_num)]["sr_starting_prb"] = sr_starting_prb
                    res_ra[(ra_ue_id, frame_num)]["sr_hopping_prb"] = sr_hopping_prb
                    res_ra[(ra_ue_id, frame_num)]["sr_cs"] = sr_cs
                    res_ra[(ra_ue_id, frame_num)]["sr_occ"] = sr_occ

                    # HARQ F1
                    left_space_num = len(re.search(pattern=r"uplinkConfig.*uplinkBWP-ToAddModList.*BWP-Uplink"
                                                           r".*bwp-Dedicated.*pucch-Config"
                                                           r".*setup.*resourceSetToAddModList"
                                                           r".*PUCCH-ResourceSet.*\n(\s*)pucch-ResourceSetId: 0\n",
                                                   string=pkg,
                                                   flags=re.DOTALL).group(1))
                    harq_f1_part = re.search(pattern=r"pucch-ResourceSetId: 0\n\s*resourceList: \d+ (item|items)\n"
                                                     r"(\s{%d}Item \d+.*?\n)(?=\s{%d}Item)"
                                                     % (left_space_num + 4, left_space_num - 8),
                                             string=pkg,
                                             flags=re.DOTALL).group()
                    harq_f1_items = re.findall(pattern=r"(\s*Item \d+.*?)(?=\s*Item \d+|$)",
                                               string=harq_f1_part,
                                               flags=re.DOTALL)
                    harq_f1_resource = collections.OrderedDict()
                    for item in harq_f1_items:
                        resource_id = re.search(pattern=r"PUCCH-ResourceId: (\d+)", string=item).group(1)
                        for item in pucch_resource_pool:
                            item_id = re.search(pattern=r"Item (\d+)", string=item).group(1)
                            pucch_resource_id = re.search(pattern=r"pucch-ResourceId: (\d+)\n", string=item).group(1)
                            if pucch_resource_id == resource_id:
                                sr_starting_prb = re.search(pattern=r"startingPRB: (\d+)", string=item).group(1)
                                sr_hopping_prb = re.search(pattern=r"secondHopPRB: (\d+)", string=item).group(1)
                                sr_cs = re.search(pattern=r"initialCyclicShift: (\d+)", string=item).group(1)
                                sr_occ = re.search(pattern=r"timeDomainOCC: (\d+)", string=item).group(1)
                                harq_f1_resource["%s^%s" % (item_id, resource_id)] = \
                                    (sr_starting_prb, sr_hopping_prb, sr_cs, sr_occ)
                                res_ra[(ra_ue_id, frame_num)]["harq_f1"] = harq_f1_resource
                                break

                            else:
                                continue

                    # HARQ F3
                    left_space_num = len(re.search(pattern=r"uplinkConfig.*uplinkBWP-ToAddModList.*BWP-Uplink"
                                                           r".*bwp-Dedicated.*pucch-Config.*setup"
                                                           r".*resourceSetToAddModList"
                                                           r".*PUCCH-ResourceSet.*\n(\s*)pucch-ResourceSetId: 1\n",
                                                   string=pkg,
                                                   flags=re.DOTALL).group(1))
                    harq_f3_part = re.search(pattern=r"pucch-ResourceSetId: 1\n\s*resourceList: \d+ (item|items)\n"
                                                     r"(\s{%d}Item \d+.*?\n)(?=\s{%d}\S+)"
                                                     % (left_space_num + 4, left_space_num - 8),
                                             string=pkg,
                                             flags=re.DOTALL).group()
                    harq_f3_items = re.findall(pattern=r"(\s*Item \d+.*?)(?=\s*Item \d+|$)",
                                               string=harq_f3_part,
                                               flags=re.DOTALL)
                    harq_f3_resource = collections.OrderedDict()
                    for item in harq_f3_items:
                        item_id = re.search(pattern=r"Item (\d+)", string=item).group(1)
                        resource_id = re.search(pattern=r"PUCCH-ResourceId: (\d+)", string=item).group(1)
                        for item in pucch_resource_pool:
                            pucch_resource_id = re.search(pattern=r"pucch-ResourceId: (\d+)\n", string=item).group(1)
                            if pucch_resource_id == resource_id:
                                sr_starting_prb = re.search(pattern=r"startingPRB: (\d+)", string=item).group(1)
                                sr_hopping_prb = re.search(pattern=r"secondHopPRB: (\d+)", string=item).group(1)
                                harq_f3_resource["%s^%s" % (item_id, resource_id)] = (sr_starting_prb, sr_hopping_prb)
                                res_ra[(ra_ue_id, frame_num)]["harq_f3"] = harq_f3_resource
                                break
                            else:
                                continue

                # Generate csv/manual csv
                csv_ra_data = []
                csv_ra_data_for_compare = []
                csv_ra_title = ["sr_slot", "sr_period", "sr_starting_prb", "sr_hopping_prb", "sr_cs", "sr_occ"]
                csv_ra_title_for_compare = copy.deepcopy(csv_ra_title)
                csv_ra_title_for_compare.insert(0, "frame")
                csv_ra_title_for_compare.insert(0, "ue")
                # Only one cycle is enough
                for k, v in res_ra.items():
                    for ids in v["harq_f1"].keys():
                        csv_ra_title.append("harq_f1_%s(starting_prb;hopping_prb;cs;occ)" % ids.partition("^")[0])
                        csv_ra_title_for_compare.append(
                            "harq_f1_%s(starting_prb;hopping_prb;cs;occ)" % ids.partition("^")[0])
                    for ids in v["harq_f3"].keys():
                        csv_ra_title.append("harq_f3_%s(starting_prb;hopping_prb)" % ids.partition("^")[0])
                        csv_ra_title_for_compare.append(
                            "harq_f3_%s(starting_prb;hopping_prb)" % ids.partition("^")[0])
                    break
                csv_ra_data.append(csv_ra_title)
                csv_ra_data_for_compare.append(csv_ra_title_for_compare)
                for k, v in res_ra.items():
                    tmp_data = [v["sr_slot"],
                                re.search(r"\d+", v["sr_period"]).group(),
                                v["sr_starting_prb"],
                                v["sr_hopping_prb"],
                                v["sr_cs"],
                                v["sr_occ"]]
                    tmp_data_for_compare = copy.deepcopy(tmp_data)
                    tmp_data_for_compare.insert(0, k[1])
                    tmp_data_for_compare.insert(0, k[0])
                    for k1, v1 in v["harq_f1"].items():
                        tmp_data.append(";".join(v1))
                        tmp_data_for_compare.append(";".join(v1))
                    for k2, v2 in v["harq_f3"].items():
                        tmp_data.append(";".join(v2))
                        tmp_data_for_compare.append(";".join(v2))
                    csv_ra_data.append(tmp_data)
                    csv_ra_data_for_compare.append(tmp_data_for_compare)

                ret = re.search(pattern=r"wireshark_(\S+).pcap", string=wireshark_pcap_name)
                if ret is not None:
                    csv_ra_file = os.path.join(wireshark_pcap_dir, "pucch_%s_ra.csv" % ret.group(1))
                else:
                    csv_ra_file = os.path.join(wireshark_pcap_dir, "pucch_ra.csv")
                csv_ra_file_for_compare = os.path.join(wireshark_pcap_dir, "%s_for_compare.csv" %
                                                       os.path.basename(csv_ra_file).split(".")[0])
                with open(file=csv_ra_file, mode="w", newline="") as csvf:
                    writer = csv.writer(csvf)
                    writer.writerows(csv_ra_data)
                with open(file=csv_ra_file_for_compare, mode="w", newline="") as csvf:
                    writer = csv.writer(csvf)
                    writer.writerows(csv_ra_data_for_compare)

                return (csv_ra_file, csv_ra_file_for_compare)
            elif flag == "l2ps":
                wireshark_l2ps_txt = os.path.join(wireshark_pcap_dir,
                                                  "%s_l2ps.txt" % wireshark_pcap_name.split(".")[0], )
                l2ps_tshark_command = 'tshark -r %s -Y "syscom&&(itf_l2_ps_user_UserSetupReq_t.ueAddCause==0||' \
                                      'itf_l2_ps_user_UserSetupReq_t.ueAddCause==10)" -V > %s' \
                                      % (wireshark_pcap, wireshark_l2ps_txt)
                comm_obj.execute_cmd_on_pc(l2ps_tshark_command, timeout='30')
                if os.path.exists(wireshark_l2ps_txt):
                    with open(wireshark_l2ps_txt) as f:
                        l2ps_txt = f.read()
                    res_l2ps = {}
                else:
                    raise Exception("Flag is '%s', but l2ps_txt file was transfered from pcap not exist under '%s'."
                                    % (flag, wireshark_pcap_dir))

                # Split every frame(SA/NSA UE) message
                l2ps_frames = re.findall(pattern=r"Frame.+?^\s*$", string=l2ps_txt, flags=re.M | re.S)
                for pkg in l2ps_frames:
                    frame_num = re.search(pattern=r"Frame Number: (\d+)", string=pkg).group(1)
                    sa_or_nsa_flag = re.search(pattern=r"(ueAddCause \(itf_UeAddCause\): InitialAccess \(0\)|"
                                                       r"ueAddCause \(itf_UeAddCause\): InitialAccessSgnbAddition "
                                                       r"\(10\))",
                                               string=pkg).group()
                    if sa_or_nsa_flag == "ueAddCause (itf_UeAddCause): InitialAccess (0)":
                        # SA UE
                        ue_du_id = re.search(pattern=r"ueIdDu \(Uint32\):\s*(\d+)", string=pkg).group(1)
                        l2ps_ue_id = "sa_ue^{}".format(ue_du_id)
                    elif sa_or_nsa_flag == "ueAddCause (itf_UeAddCause): InitialAccessSgnbAddition (10)":
                        # NSA UE
                        ue_cu_id = re.search(pattern=r"ueIdCu \(Uint32\):\s*(\d+)", string=pkg).group(1)
                        l2ps_ue_id = "nsa_ue^{}".format(ue_cu_id)
                    res_l2ps[(l2ps_ue_id, frame_num)] = {}

                    # sr sr_period;sr_slot;sr_starting_prb;sr_hopping_prb;sr_cs, sr_occ
                    sr_left_space_num = len(re.search(pattern=r"perSrConfig \(DynamicVariableSizedArray\).*"
                                                              r"\n(\s*)perSrConfig_item_0 "
                                                              r"\(itf_l2_ps_sr_PerSrConfig\)\n",
                                                      string=pkg,
                                                      flags=re.DOTALL).group(1))
                    sr_part = re.search(pattern=r"\n\s{%d}(perSrConfig_item_0 \(itf_l2_ps_sr_PerSrConfig\).*?)"
                                                r"\n\s{%d}\S+" % (sr_left_space_num, sr_left_space_num - 4),
                                        string=pkg,
                                        flags=re.DOTALL).group(1)
                    sr_period = re.search(pattern=r"periodicity \(itf_l2_ps_sr_Periodicity\): (\S+) \(\d+\)",
                                          string=sr_part).group(1)
                    sr_slot = re.search(pattern=r"slotOffset.*: (\d+)", string=sr_part).group(1)
                    sr_starting_prb = re.search(pattern=r"startingPrb.*: (\d+)", string=sr_part).group(1)
                    sr_hopping_prb = re.search(pattern=r"secondHopPrb.*: (\d+)", string=sr_part).group(1)
                    sr_cs = re.search(pattern=r"initialCyclicShift.*: (\d+)", string=sr_part).group(1)
                    sr_occ = re.search(pattern=r"timeDomainOcc.*: (\d+)", string=sr_part).group(1)
                    res_l2ps[(l2ps_ue_id, frame_num)]["sr_period"] = sr_period
                    res_l2ps[(l2ps_ue_id, frame_num)]["sr_slot"] = sr_slot
                    res_l2ps[(l2ps_ue_id, frame_num)]["sr_starting_prb"] = sr_starting_prb
                    res_l2ps[(l2ps_ue_id, frame_num)]["sr_hopping_prb"] = sr_hopping_prb
                    res_l2ps[(l2ps_ue_id, frame_num)]["sr_cs"] = sr_cs
                    res_l2ps[(l2ps_ue_id, frame_num)]["sr_occ"] = sr_occ

                    # HARQ F1
                    left_space_num = len(re.search(pattern=r"\n(\s*)pucchResourcesSet0 \(StaticVariableSizedArray "
                                                           r"capacity=32\)",
                                                   string=pkg).group(1))
                    harq1_part = re.search(pattern=r"cellConfiguration \(DynamicVariableSizedArray\).*"
                                                   r"cellConfiguration_item_0 \(itf_l2_ps_CellConfigParam_t\).*"
                                                   r"pucchConfig \(StaticVariableSizedArray\).*"
                                                   r"\n(\s{%d}pucchResourcesSet0 \(StaticVariableSizedArray "
                                                   r"capacity=32\).*?)"
                                                   r"\n\s{%d}\S+" % (left_space_num, left_space_num),
                                           string=pkg,
                                           flags=re.DOTALL).group(1)
                    harq1_items = re.findall(
                        pattern=r"(pucchResourcesSet0_item_\d+.*?)(?=pucchResourcesSet0_item_\d+|$)",
                        string=harq1_part,
                        flags=re.DOTALL)
                    harq_f1_resource = collections.OrderedDict()
                    for item in harq1_items:
                        item_id = re.search(pattern=r"pucchResourcesSet0_item_(\d+)", string=item).group(1)
                        ret = re.search(pattern=r"resourceItemId_item_0.*: (\d+)", string=item)
                        if ret is not None:
                            resource_item_id = ret.group(1)
                        else:
                            resource_item_id = item_id
                        starting_prb = re.search(pattern=r"startingPrb.*: (\d+)", string=item).group(1)
                        hopping_prb = re.search(pattern=r"secondHopPrb.*: (\d+)", string=item).group(1)
                        cs = re.search(pattern=r"initialCyclicShift.*: (\d+)", string=item).group(1)
                        occ = re.search(pattern=r"timeDomainOcc.*: (\d+)", string=item).group(1)
                        harq_f1_resource["%s^%s" % (item_id, resource_item_id)] = (starting_prb, hopping_prb, cs, occ)
                        res_l2ps[(l2ps_ue_id, frame_num)]["harq_f1"] = harq_f1_resource

                    # HARQ F3
                    left_space_num = len(re.search(pattern=r"pucchResourceSet \(StaticVariableSizedArray capacity=3\).*"
                                                           r"\n(\s*)pucchResourceSet_item_0 \(itf_l2_ps_pucch_"
                                                           r"PucchResourceSet\)",
                                                   string=pkg,
                                                   flags=re.DOTALL).group(1))
                    harq3_part = re.search(pattern=r"cellConfiguration \(DynamicVariableSizedArray\).*"
                                                   r"cellConfiguration_item_0 \(itf_l2_ps_CellConfigParam_t\).*"
                                                   r"pucchConfig \(StaticVariableSizedArray\).*"
                                                   r"pucchResourceSet \(StaticVariableSizedArray capacity=3\).*"
                                                   r"\n(\s{%d}pucchResourceSet_item_0 "
                                                   r"\(itf_l2_ps_pucch_PucchResourceSet\).*?)"
                                                   r"\n\s{%d,%d}\S+" %
                                                   (left_space_num, left_space_num - 4, left_space_num),
                                           string=pkg,
                                           flags=re.DOTALL).group(1)
                    harq3_items = re.findall(pattern=r"(pucchResources_item_\d+.*?)(?=pucchResources_item_\d+|$)",
                                             string=harq3_part,
                                             flags=re.DOTALL)
                    harq_f3_resource = collections.OrderedDict()
                    for item in harq3_items:
                        item_id = re.search(pattern=r"pucchResources_item_(\d+)", string=item).group(1)
                        ret = re.search(pattern=r"resourceItemId_item_0.*: (\d+)", string=item)
                        if ret is not None:
                            resource_item_id = ret.group(1)
                        else:
                            resource_item_id = item_id
                        starting_prb = re.search(pattern=r"startingPrb.*: (\d+)", string=item).group(1)
                        hopping_prb = re.search(pattern=r"secondHopPrb.*: (\d+)", string=item).group(1)
                        harq_f3_resource["%s^%s" % (item_id, resource_item_id)] = (starting_prb, hopping_prb)
                        res_l2ps[(l2ps_ue_id, frame_num)]["harq_f3"] = harq_f3_resource

                # Generate csv/manual csv
                csv_l2ps_data = []
                csv_l2ps_data_for_compare = []
                csv_l2ps_title = ["sr_slot", "sr_period", "sr_starting_prb", "sr_hopping_prb", "sr_cs", "sr_occ"]
                csv_l2ps_title_for_compare = copy.deepcopy(csv_l2ps_title)
                csv_l2ps_title_for_compare.insert(0, "frame")
                csv_l2ps_title_for_compare.insert(0, "ue")
                # Only one cycle is enough
                for k, v in res_l2ps.items():
                    for ids in v["harq_f1"].keys():
                        csv_l2ps_title.append("harq_f1_%s(starting_prb;hopping_prb;cs;occ)" % ids.partition("^")[0])
                        csv_l2ps_title_for_compare.append(
                            "harq_f1_%s(starting_prb;hopping_prb;cs;occ)" % ids.partition("^")[0])
                    for ids in v["harq_f3"].keys():
                        csv_l2ps_title.append("harq_f3_%s(starting_prb;hopping_prb)" % ids.partition("^")[0])
                        csv_l2ps_title_for_compare.append(
                            "harq_f3_%s(starting_prb;hopping_prb)" % ids.partition("^")[0])
                    break
                csv_l2ps_data.append(csv_l2ps_title)
                csv_l2ps_data_for_compare.append(csv_l2ps_title_for_compare)
                for k, v in res_l2ps.items():
                    tmp_data = [v["sr_slot"],
                                re.search(r"\d+", v["sr_period"]).group(),
                                v["sr_starting_prb"],
                                v["sr_hopping_prb"],
                                v["sr_cs"],
                                v["sr_occ"]]
                    tmp_data_for_compare = copy.deepcopy(tmp_data)
                    tmp_data_for_compare.insert(0, k[1])
                    tmp_data_for_compare.insert(0, k[0])
                    for k1, v1 in v["harq_f1"].items():
                        tmp_data.append(";".join(v1))
                        tmp_data_for_compare.append(";".join(v1))
                    for k2, v2 in v["harq_f3"].items():
                        tmp_data.append(";".join(v2))
                        tmp_data_for_compare.append(";".join(v2))
                    csv_l2ps_data.append(tmp_data)
                    csv_l2ps_data_for_compare.append(tmp_data_for_compare)

                ret = re.search(pattern=r"wireshark_(\S+).pcap", string=wireshark_pcap_name)
                if ret is not None:
                    csv_l2ps_file = os.path.join(wireshark_pcap_dir, "pucch_%s_l2ps.csv" % ret.group(1))
                else:
                    csv_l2ps_file = os.path.join(wireshark_pcap_dir, "pucch_l2ps.csv")
                csv_l2ps_file_for_compare = os.path.join(wireshark_pcap_dir, "%s_for_compare.csv" %
                                                         os.path.basename(csv_l2ps_file).split(".")[0])
                with open(file=csv_l2ps_file, mode="w", newline="") as csvf:
                    writer = csv.writer(csvf)
                    writer.writerows(csv_l2ps_data)
                with open(file=csv_l2ps_file_for_compare, mode="w", newline="") as csvf:
                    writer = csv.writer(csvf)
                    writer.writerows(csv_l2ps_data_for_compare)

                return (csv_l2ps_file, csv_l2ps_file_for_compare)
        except Exception as e:
            traceback.print_exc()
            print("There was an error appear in the process of generate pussh csv from wireshark,"
                  "Maybe there is a sw issue or TA error, could contact TA team "
                  "(I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com) to check first, ")

    def _csv_should_be_same(self, csv1, csv2, remove_index=1, delete_flag=True):
        csv1L = []
        csv2L = []
        with open(file=csv1, mode="r") as csvf1:
            reader = csv.reader(csvf1)
            for line in reader:
                tmp = line
                tmp.remove(tmp[remove_index])
                csv1L.append(tuple(line))
            csv1T = tuple(csv1L)
        with open(file=csv2, mode="r") as csvf2:
            reader = csv.reader(csvf2)
            for line in reader:
                tmp = line
                tmp.remove(tmp[remove_index])
                csv2L.append(tuple(line))
            csv2T = tuple(csv2L)

        both_own = list(set(csv1T) & set(csv2T))
        csv1_separate_own = list(set(csv1T) - set(csv2T))
        csv2_separate_own = list(set(csv2T) - set(csv1T))

        if len(csv1_separate_own) > 0 or len(csv2_separate_own) > 0:
            print("The 2 csv data is different, detail as below:")
            print("{}:".format(os.path.basename(csv1)))
            for i in csv1_separate_own:
                print("    {}".format(i))
            print("{}:".format(os.path.basename(csv2)))
            for j in csv2_separate_own:
                print("    {}".format(j))
            raise Exception("The 2 pucch resource csv file is different.")
        else:
            if delete_flag:
                os.remove(csv1)
                os.remove(csv2)
            return True

    def _stop_wireshark_log_after_filter_found(self, tag, string):
        self._setup_wireshark()
        wireshark_name = "wireshark" if len(tag) == 0 else "wireshark_{}".format(tag)
        string = string if string.count("::") else "{}::1".format(string)
        expect_string, expect_times = string.split("::")
        time.sleep(10)
        if expect_string.lower() == "l2ps_filter":
            except_string = ("syscom&&(itf_l2_ps_user_UserSetupReq_t.ueAddCause == 0||"
                             "itf_l2_ps_user_UserSetupReq_t.ueAddCause == 10)")
        # check wireshark if exist in save_log_dir
        wireshark_dir = comm_obj._get_save_log_dir(self.alias)
        wireshark_full_dir = wireshark_dir + wireshark_name + ".pcap"
        check_filter_cmd = ("tshark -r {} -Y '{}' |wc -l".format(wireshark_full_dir, except_string))
        if not os.path.isfile(wireshark_full_dir):
            # wait filter string in wireshark log with timeout 2min and interval 10s
            maxtime = time.time() + 120
            while time.time() < maxtime:
                try:
                    # download wireshark log
                    builtin_obj.log("step: download wireshark")
                    self._execute_cmd_on_bts("ls -ltrh /tmp/wireshark*")
                    self._execute_cmd_on_bts("df -h /tmp/;df -h /var/tmp/;df -h /var/log/")
                    self.fsm_obj.get_enb_file("/tmp/{}.pcap".format(wireshark_name), wireshark_dir, alias=self.alias)

                    # wireshark_txt = self._download_and_decode_wireshark(wireshark_name, decode_option)
                    builtin_obj.log("step: check filter string in wireshark pcap")
                    if not os.path.isfile(wireshark_full_dir):
                        raise Exception("file does not exist or it is not a file: %s" % wireshark_full_dir)

                    filter_string_return = comm_obj.execute_cmd_on_pc(check_filter_cmd)
                    filter_string_num = filter_string_return.split("\n")[-1]
                    if int(filter_string_num) >= int(expect_times):
                        break
                    else:
                        builtin_obj.log("%s only contain '%s' for %s times" % (wireshark_full_dir, expect_string,
                                                                               filter_string_num))
                        time.sleep(10)
                except Exception as e:
                    builtin_obj.log("debug: {}".format(e))
        else:
            filter_string_return = comm_obj.execute_cmd_on_pc(check_filter_cmd)
            filter_string_num = filter_string_return.split("\n")[-1]
            if int(filter_string_num) < int(expect_times):
                builtin_obj.log("%s only contain '%s' for %s times" % (wireshark_full_dir, expect_string,
                                                                       filter_string_num))

        # warn if wait_filter_sting improper
        builtin_obj.log("step: warn if filter string improper")
        # actual_times = comm_obj.count_string_in_file(wireshark_txt, expect_string)
        if int(filter_string_num) != int(expect_times):
            builtin_obj.log("{} contains {} for {} times, not equal to expected times: {}".format(
                wireshark_full_dir, expect_string, filter_string_num, expect_times), level="WARN")

        # kill wireshark
        builtin_obj.log("step: kill wireshark")
        self._execute_cmd_on_bts("ps -ef | grep 'tcpdump' | grep -v -w grep")
        self._execute_cmd_on_bts(
            "ps aux | grep '%s' | grep -v -w grep | awk '{print $2}' | xargs kill -9" % wireshark_name)
        self._execute_cmd_on_bts("ps -ef | grep 'tcpdump' | grep -v -w grep")

        # delete wireshark Tag pcap
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("rm -rf /tmp/%s.pcap" % wireshark_name)
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("df -h /tmp/;df -h /var/tmp/;df -h /var/log/")

    def _recreate_sr_a2a_expected_csv(self, a2a_csv_ini, full_csv_file):
        # get need modified csv file dict
        ini_dic, self.ini_file_dir, self.ini_file, self.ini_file_new = self._read_ini_file(a2a_csv_ini)
        self._change_ini_file_to_new(self.ini_file, self.ini_file_new, ini_dic)
        for sect in ini_dic:
            filter_sr_slot_id = int(ini_dic[sect]["filter"].split("=")[-1].strip())
            a2a_csv_file_name = ini_dic[sect]["paradigm"].split("./")[-1].strip()
            a2a_csv_file_org = self.ini_file_dir + a2a_csv_file_name
            a2a_csv_file = self.ini_file_dir + a2a_csv_file_name.split(".csv")[0] + "_new.csv"

            # delete a2a_csv_file if exist
            comm_obj.execute_cmd_on_pc("rm %s" % a2a_csv_file)

            sr_slot_list = []
            # read input a2a_csv_file and get the sr_slot_id is 8/9/18/19 ...
            with open(a2a_csv_file_org) as f_a2a_org:
                f_a2a_org_csv = csv.reader(f_a2a_org)
                f_a2a_org_csv_list = list(f_a2a_org_csv)
                f_a2a_org_csv_list_new = []
                f_a2a_org_csv_list_slot_part = []
                for item in f_a2a_org_csv_list:
                    if item[0].lower().count("global") or item[0].lower().count("relation") or item[0].lower().count(
                            "blocksize") or item[0].lower().count("[cp") or item[0].lower().count("sr_slot") or item[
                            0].lower() == "":
                        f_a2a_org_csv_list_new.append(item)
                    else:
                        # add slot_part with slot line into f_a2a_org_csv_list_slot_part list
                        f_a2a_org_csv_list_slot_part.append(item)
                sr_slot_id = int(f_a2a_org_csv_list_slot_part[0][0])
                if sr_slot_id != filter_sr_slot_id:
                    raise Exception("Defined filter sr_slot id:%s from ini must be same in csv checking file %s" % (
                        filter_sr_slot_id, a2a_csv_file_org))
                for row in f_a2a_org_csv_list_slot_part:
                    if int(row[0]) != sr_slot_id:
                        raise Exception("sr_slot id must be same in one csv checking file")

            # read generated pucch full_csv_file from wireshark and get needed lines based on sr_slot_id
            with open(full_csv_file) as f:
                f_csv = csv.reader(f)
                f_csv_list = list(f_csv)
                for row in f_csv_list:
                    if row[0].lower() == "sr_slot":
                        builtin_obj.log("It's header, ignore")
                        pass
                    elif int(row[0]) == sr_slot_id:
                        sr_slot_list.append(row)

            # remove needless lines from a2a_csv_file
            if len(f_a2a_org_csv_list_slot_part) < len(sr_slot_list):
                builtin_obj.log(
                    "Need checked pucch csv for sr_slot id:%s length less than generated pucch csv" % sr_slot_id,
                    level="WARN")
            for i in range(len(f_a2a_org_csv_list_slot_part) - len(sr_slot_list)):
                f_a2a_org_csv_list_slot_part.pop()
            # append left slot part into f_a2a_org_csv_list_new list
            for i in f_a2a_org_csv_list_slot_part:
                f_a2a_org_csv_list_new.append(i)
            with open(a2a_csv_file, "w") as f_a2a_org_new:
                f_a2a_org_csv_new = csv.writer(f_a2a_org_new)
                f_a2a_org_csv_new.writerows(f_a2a_org_csv_list_new)
        return self.ini_file_new

    def _read_ini_file(self, ini_file):
        ini_dic = {}
        self.conf = configparser.ConfigParser()
        self.conf.read(ini_file)
        ini_file_temp_list = ini_file.split("/")
        # org ini file name
        ini_file_name_org = ini_file_temp_list[-1]
        del ini_file_temp_list[-1]
        self.ini_file_dir = "/".join(ini_file_temp_list) + "/"
        self.ini_file = ini_file
        # new ini file dir
        self.ini_file_new = self.ini_file_dir + ini_file_name_org.split(".ini")[0] + "_new.ini"
        print(self.conf.sections())
        for sect in self.conf.sections():
            if "filter" in self.conf.options(sect) and "paradigm" in self.conf.options(sect):
                ini_dic[sect] = {}
                ini_dic[sect]["filter"] = self.conf.get(sect, "filter")
                ini_dic[sect]["paradigm"] = self.conf.get(sect, "paradigm")
        return ini_dic, self.ini_file_dir, self.ini_file, self.ini_file_new

    def _change_ini_file_to_new(self, ini_file_org, ini_file_new, ini_dic):
        comm_obj.execute_cmd_on_pc("rm %s" % ini_file_new)
        comm_obj.execute_cmd_on_pc("cp %s %s" % (ini_file_org, ini_file_new))
        for sect in ini_dic:
            ini_csv_org_name = ini_dic[sect]["paradigm"]
            ini_csv_new_name = ini_dic[sect]["paradigm"].split(".csv")[0] + "_new.csv"
            comm_obj.execute_cmd_on_pc('sed -i "s|{}|{}|" {}'.format(ini_csv_org_name, ini_csv_new_name, ini_file_new))


class wireshark_log_bts1(object):

    def __init__(self):
        alias = "gnb1"
        self.wireshark_log_base_instance_1 = wireshark_log_base(alias)

    def start_to_capture_wireshark_log(self, tag=''):
        """
        This keyword is to start to capture wireshark log in GNB
        The following protocols are supported and the mapping between protocol and port as below:
        NGAP 38412
        E1AP 38462
        F1AP 38472
        XNAP 38422
        X2AP 36422
        ICOM 29211
        PCMD 49150

        | Input Parameters | Man. | Default  | Description |
        | tag              | No   | ${EMPTY} | used to name wireshark as wireshark.pcap and wireshark.txt
                                               or wireshark_${tag}.pcap and wireshark_${tag}.txt |
        Example:
        | Start To Capture Wireshark Log | 1st |
        """
        self.wireshark_log_base_instance_1._start_to_capture_wireshark_log(tag)

    def start_to_capture_xpsyscom_log(self, tag=''):
        self.wireshark_log_base_instance_1._start_to_capture_xpsyscom_log(tag)

    def stop_capture_wireshark_log(self, tag='', decode_option='', decode_flag=True):
        self.wireshark_log_base_instance_1._stop_capture_wireshark_log(tag, decode_option, decode_flag)

    def stop_capture_xpsyscom_log(self, tag=''):
        self.wireshark_log_base_instance_1._stop_capture_xpsyscom_log(tag)

    def stop_wireshark_log_after_string_found(self, tag, string, decode_option=''):
        self.wireshark_log_base_instance_1._stop_wireshark_log_after_string_found(tag, string, decode_option)

    def get_xp_version(self):
        self.wireshark_log_base_instance_1._get_protocol_version_from_wireshark()
        return wireshark_protocol_info["IgNBCAXpProtocol_Version"][0]

    def get_xgu_version(self):
        self.wireshark_log_base_instance_1._get_protocol_version_from_wireshark()
        return wireshark_protocol_info["IgNBCAXgUProtocol_Version"][0]

    def get_wireshark_field_value_old(self, cap_file="", element_expression="", display_filter="", timeout=60):
        return self.wireshark_log_base_instance_1._get_elem_value_from_pcap(cap_file, element_expression,
                                                                            display_filter, timeout)

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
        return self.wireshark_log_base_instance_1._get_wireshark_field_value(pcap_file, field_path,
                                                                             display_filter, packet)

    def generate_pucch_csv_from_wireshark(self, wireshark_pcap, flag="ra"):
        return self.wireshark_log_base_instance_1._generate_pucch_csv_from_wireshark(wireshark_pcap=wireshark_pcap,
                                                                                     flag=flag)

    def csv_should_be_same(self, csv1, csv2, remove_index=1, delete_flag=True):
        return self.wireshark_log_base_instance_1._csv_should_be_same(csv1=csv1, csv2=csv2, remove_index=remove_index,
                                                                      delete_flag=delete_flag)

    def stop_wireshark_log_after_filter_found(self, tag, wait_string):
        self.wireshark_log_base_instance_1._stop_wireshark_log_after_filter_found(tag, wait_string)

    def recreate_sr_a2a_expected_csv(self, a2a_ini_file, full_csv_file):
        return self.wireshark_log_base_instance_1._recreate_sr_a2a_expected_csv(a2a_ini_file, full_csv_file)


class wireshark_log_bts2(object):

    def __init__(self):
        alias = "gnb2"
        self.wireshark_log_base_instance_2 = wireshark_log_base(alias)

    def _setup_wireshark_bts2(self):
        self.wireshark_log_base_instance_2.bts_host = builtin_obj.get_variable_value('${GNB2_IP}')  # NG IP
        self.wireshark_log_base_instance_2.remote_host = builtin_obj.get_variable_value('${GNB2_PC_IP}')

    def start_to_capture_wireshark_log_gnb2(self, tag=''):
        """
        This keyword is to start to capture wireshark log in GNB
        The following protocols are supported and the mapping between protocol and port as below:
        NGAP 38412
        E1AP 38462
        F1AP 38472
        XNAP 38422
        X2AP 36422
        ICOM 29211
        PCMD 49150

        | Input Parameters | Man. | Default  | Description |
        | tag              | No   | ${EMPTY} | used to name wireshark as wireshark.pcap and wireshark.txt
                                               or wireshark_${tag}.pcap and wireshark_${tag}.txt |
        Example:
        | Start To Capture Wireshark Log GNB2 | 1st |
        """
        self._setup_wireshark_bts2()
        self.wireshark_log_base_instance_2._start_to_capture_wireshark_log(tag)

    def start_to_capture_xpsyscom_log_gnb2(self, tag=''):
        self._setup_wireshark_bts2()
        self.wireshark_log_base_instance_2._start_to_capture_xpsyscom_log(tag)

    def stop_capture_wireshark_log_gnb2(self, tag='', decode_option='', decode_flag=True):
        self._setup_wireshark_bts2()
        self.wireshark_log_base_instance_2._stop_capture_wireshark_log(tag, decode_option, decode_flag)

    def stop_capture_xpsyscom_log_gnb2(self, tag=''):
        self.wireshark_log_base_instance_2._stop_capture_xpsyscom_log(tag)

    def stop_wireshark_log_after_string_found_gnb2(self, tag, string, decode_option=''):
        self._setup_wireshark_bts2()
        self.wireshark_log_base_instance_2._stop_wireshark_log_after_string_found(tag, string, decode_option)

    def generate_pucch_csv_from_wireshark_gnb2(self, wireshark_pcap, flag="ra"):
        return self.wireshark_log_base_instance_2._generate_pucch_csv_from_wireshark(wireshark_pcap=wireshark_pcap,
                                                                                     flag=flag)

    def compare_pucch_resource_csv(self, csv1, csv2, remove_index=1, delete_flag=True):
        return self.wireshark_log_base_instance_2._csv_should_be_same(csv1=csv1, csv2=csv2, remove_index=remove_index,
                                                                      delete_flag=delete_flag)


class wireshark(wireshark_plugin, wireshark_log_bts1, wireshark_log_bts2):
    def __init__(self):
        wireshark_plugin.__init__(self)
        wireshark_log_bts1.__init__(self)
        wireshark_log_bts2.__init__(self)


if __name__ == "__main__":
    wireshark_obj = wireshark()
    help(wireshark_obj)
