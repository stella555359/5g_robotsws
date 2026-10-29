# -*- coding:utf-8 -*-

import os
import time
import traceback
import re
import requests
import sys
from bs4 import BeautifulSoup
from base_lib.ta_enb_dependency_selector.downloader import Downloader
from common_lib import common_lib
from base_lib.ta_enb_dependency_selector import ta_enb_dependency_selector
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from ute_fsmaccess import ute_fsmaccess

comm_obj = common_lib()
selector_obj = ta_enb_dependency_selector()
os_obj = OperatingSystem()
builtin_obj = BuiltIn()

# WIRESHARK_PLUGIN_URL = r"http://files.ute.nsn-rdnet.net/builds/wireshark/nsetapx/"
WIRESHARK_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X"
MCSHARK_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/"
NOKIAF1AP_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/Nokia_F1_AP/"
NOKIAXNAP_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/Nokia_Xn_AP/"


class wireshark_plugin(object):
    def __init__(self):
        self._setup_wireshark_plugin_flag = False
        self.wireshark_version = ''
        self.local_plugin_path = ''
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

    def _get_plugin_file_name(self, wireshark_version):
        plugin_file = ''
        r = requests.get(WIRESHARK_PLUGIN_URL)
        soup = BeautifulSoup(r.content, 'lxml')
        for a_tag in soup.find_all('a')[::-1]:
            if 'nsetapx-' + wireshark_version in a_tag.text:
                plugin_file = a_tag.text
                break
        return plugin_file or 'nsetapx-3.4-1.1.0+buster.so'

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

    def _download_plugin(self, plugin_file, local_plugin_path):
        # downloader = Downloader()
        # os.system("sudo chmod 777 %s" % local_plugin_path)
        # plugin_src = "%s/%s" % (WIRESHARK_PLUGIN_URL, plugin_file)
        # plugin_dst = "%s/%s" % (local_plugin_path, plugin_file)
        # builtin_obj.log("step: wget %s -O %s" % (plugin_src, plugin_dst))
        # downloader.execute_wget(plugin_src, plugin_dst)
        os.system("sudo chmod 777 %s" % local_plugin_path)
        comm_obj.execute_cmd_on_pc("cd {}".format(local_plugin_path))
        comm_obj.execute_cmd_on_pc("wget {}/nsetapx-1.5.3/nsetapx-3.6-1.5.3+buster.so".format(WIRESHARK_PLUGIN_URL))

    def _download_wireshark_nsetapx_plugin(self):
        self._setup_wireshark_plugin()
        # get plugin file name
        plugin_file = self._get_plugin_file_name(self.wireshark_version)
        if os.path.exists(self.local_plugin_path):
            comm_obj.execute_cmd_on_pc("cd {}".format(self.local_plugin_path))
        else:
            comm_obj.execute_cmd_on_pc("mkdir -p %s" % self.local_plugin_path)
            comm_obj.execute_cmd_on_pc("cd {}".format(self.local_plugin_path))
        del_old_nsetapx_cmd = "ls -lrt | grep -i nsetapx | grep -v -w grep | awk '{print $9}' | xargs sudo rm -rf"
        comm_obj.execute_cmd_on_pc(del_old_nsetapx_cmd)

        # check plugin situation in wireshark global install folder
        glb_pulgin_path = "/usr/lib/x86_64-linux-gnu/wireshark/plugins/%s/epan" % self.wireshark_version
        if os.path.exists(glb_pulgin_path):
            builtin_obj.log("step: check global wireshark plugin folder")
            comm_obj.execute_cmd_on_pc("ls -lrt {}".format(glb_pulgin_path))

        # download plugin, retry 1 time if failed
        self._download_plugin(plugin_file, self.local_plugin_path)
        builtin_obj.log("step: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc(" tshark -G plugins")
        if "nsetapx" not in active_plugins:
            self._download_plugin(plugin_file, self.local_plugin_path)
            builtin_obj.log("step: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "nsetapx" not in active_plugins:
                raise Exception("fail to download nsetapx plugin")

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
        gnb_version = comm_obj.get_gnb_sw_version()
        if gnb_version.count("_9999_"):
            gnb_version = "SBTS00_" + gnb_version.partition("_")[-1]
        supported_gnb_version = self._get_supported_mcshark_version(gnb_version)
        mcshark_pulgin_file = self._get_mcshark_plugin_file_name(self.wireshark_version, supported_gnb_version)
        if os.path.exists(self.local_plugin_path):
            comm_obj.execute_cmd_on_pc("cd {}".format(self.local_plugin_path))
        else:
            comm_obj.execute_cmd_on_pc("mkdir -p %s" % self.local_plugin_path)
            comm_obj.execute_cmd_on_pc("cd {}".format(self.local_plugin_path))
        del_old_mcshark_cmd = "ls -lrt | grep -i mcshark | grep -v -w grep | awk '{print $9}' | xargs sudo rm -rf"
        comm_obj.execute_cmd_on_pc(del_old_mcshark_cmd)

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

    def _get_nokiaf1ap_plugin_file_name(self, wireshark_version):
        nokiaf1ap_plugin_folder_name = self._get_latest_plugin_folder_name(plugin_name="nokiaf1ap",
                                                                           plugin_address=NOKIAF1AP_PLUGIN_URL)
        r = requests.get("{}/{}/".format(NOKIAF1AP_PLUGIN_URL, nokiaf1ap_plugin_folder_name))
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

    def _get_nokiaxnap_plugin_file_name(self, wireshark_version):
        nokiaxnap_plugin_folder_name = self._get_latest_plugin_folder_name(plugin_name="nokiaxnap",
                                                                           plugin_address=NOKIAXNAP_PLUGIN_URL)
        r = requests.get("{}/{}/".format(NOKIAXNAP_PLUGIN_URL, nokiaxnap_plugin_folder_name))
        soup = BeautifulSoup(r.content, 'lxml')
        nokiaxnap_plugin_file_name = ""
        for a_tag in soup.find_all('a')[::-1]:
            search_result = re.search("nokiaxnap-{}-.*buster.so$".format(wireshark_version),
                                      a_tag.text)
            if search_result:
                nokiaxnap_plugin_file_name = search_result.group(0)
                break
        if not nokiaxnap_plugin_file_name:
            raise Exception("get nokiaf1ap pulgin file name failure")
        else:
            return nokiaxnap_plugin_file_name

    def _download_wireshark_nokiaf1ap_plugin(self):
        self._setup_wireshark_plugin()
        nokiaf1ap_plugin_flag = builtin_obj.convert_to_boolean(
            builtin_obj.get_variable_value('${NOKIA_F1AP_PLUGIN_FLAG}'))
        if nokiaf1ap_plugin_flag is not True:
            del_old_nokiaf1ap_cmd = "cd %s && ls -lrt | grep -i nokiaf1ap | grep -v -w grep | awk '{print $9}' " \
                                    "| xargs sudo rm -rf" % self.local_plugin_path
            comm_obj.execute_cmd_on_pc(del_old_nokiaf1ap_cmd)
            return
        builtin_obj.log("step: get f1ap version")
        nokiaf1ap_plugin_folder_name = self._get_latest_plugin_folder_name(plugin_name="nokiaf1ap",
                                                                           plugin_address=NOKIAF1AP_PLUGIN_URL)
        nokiaf1ap_pulgin_file = self._get_nokiaf1ap_plugin_file_name(self.wireshark_version)
        if os.path.exists(self.local_plugin_path):
            comm_obj.execute_cmd_on_pc("cd {}".format(self.local_plugin_path))
        else:
            comm_obj.execute_cmd_on_pc("mkdir -p %s" % self.local_plugin_path)
            comm_obj.execute_cmd_on_pc("cd {}".format(self.local_plugin_path))
        del_old_nokiaf1ap_cmd = "ls -lrt | grep -i nokiaf1ap | grep -v -w grep | awk '{print $9}' | xargs sudo rm -rf"
        comm_obj.execute_cmd_on_pc(del_old_nokiaf1ap_cmd)

        self._download_plugin_to_specific_folder(
            plugin_url="{}/{}".format(NOKIAF1AP_PLUGIN_URL, nokiaf1ap_plugin_folder_name),
            plugin_file=nokiaf1ap_pulgin_file,
            local_plugin_path=self.local_plugin_path)
        builtin_obj.log("step: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc(" tshark -G plugins")
        if "nokiaf1ap" not in active_plugins:
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
        nokiaxnap_plugin_flag = builtin_obj.convert_to_boolean(
            builtin_obj.get_variable_value('${NOKIA_XNAP_PLUGIN_FLAG}'))
        if nokiaxnap_plugin_flag is not True:
            del_old_nokiaxnap_cmd = "cd %s && ls -lrt | grep -i nokiaxnap | grep -v -w grep | awk '{print $9}' " \
                                    "| xargs sudo rm -rf" % self.local_plugin_path
            comm_obj.execute_cmd_on_pc(del_old_nokiaxnap_cmd)
            return
        nokiaxnap_plugin_folder_name = self._get_latest_plugin_folder_name(plugin_name="nokiaxnap",
                                                                           plugin_address=NOKIAXNAP_PLUGIN_URL)
        nokiaxnap_pulgin_file = self._get_nokiaxnap_plugin_file_name(self.wireshark_version)
        if os.path.exists(self.local_plugin_path):
            comm_obj.execute_cmd_on_pc("cd {}".format(self.local_plugin_path))
        else:
            comm_obj.execute_cmd_on_pc("mkdir -p %s" % self.local_plugin_path)
            comm_obj.execute_cmd_on_pc("cd {}".format(self.local_plugin_path))
        del_old_nokiaxnap_cmd = "ls -lrt | grep -i nokiaxnap | grep -v -w grep | awk '{print $9}' | xargs sudo rm -rf"
        comm_obj.execute_cmd_on_pc(del_old_nokiaxnap_cmd)

        self._download_plugin_to_specific_folder(
            plugin_url="{}/{}".format(NOKIAXNAP_PLUGIN_URL, nokiaxnap_plugin_folder_name),
            plugin_file=nokiaxnap_pulgin_file,
            local_plugin_path=self.local_plugin_path
        )
        builtin_obj.log("step: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc(" tshark -G plugins")
        if "nokiaf1ap" not in active_plugins:
            self._download_plugin_to_specific_folder(
                plugin_url="{}/{}".format(NOKIAXNAP_PLUGIN_URL, nokiaxnap_plugin_folder_name),
                plugin_file=nokiaxnap_pulgin_file,
                local_plugin_path=self.local_plugin_path)
            builtin_obj.log("step: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "nokiaxnap" not in active_plugins:
                raise Exception("fail to download nokiaxnap plugin")

    def _download_plugin_to_specific_folder(self, plugin_url, plugin_file, local_plugin_path):
        os.system("sudo chmod 777 %s" % local_plugin_path)
        comm_obj.execute_cmd_on_pc("cd {}".format(local_plugin_path))
        comm_obj.execute_cmd_on_pc("wget {}/{}".format(plugin_url, plugin_file))

    def _get_latest_plugin_folder_name(self, plugin_name, plugin_address):
        try:
            r = requests.get(plugin_address)
            soup = BeautifulSoup(r.content, 'lxml')
            # check gnb_version exists in library
            plugin_folder_pattern = re.compile(r'.*">({}.*)/</a>.*'.format(plugin_name))
            plugin_folder_result = plugin_folder_pattern.findall(str(soup))
            if plugin_folder_result:
                plugin_dict = {}
                temp_plugin_list = []
                for version in plugin_folder_result:
                    key = version.split('-', 2)[-1]
                    split_key_left = key.rsplit(".", 1)[0]
                    split_key_right = key.rsplit(".", 1)[-1].rsplit('-', 1)[-1]
                    key = float(split_key_left) * 100 + float(split_key_right)
                    temp_plugin_list.append(key)
                    plugin_dict[key] = version
                for i in range(0, len(temp_plugin_list)):
                    for j in range(0, len(temp_plugin_list) - i - 1):
                        if temp_plugin_list[j] > temp_plugin_list[j + 1]:
                            temp = temp_plugin_list[j + 1]
                            temp_plugin_list[j + 1] = temp_plugin_list[j]
                            temp_plugin_list[j] = temp
                return plugin_dict[temp_plugin_list[-1]]
        except Exception:
            builtin_obj.log("get latest {} plugin name fails.", level="WARN")
            if plugin_name.lower() == "nokiaf1ap":
                return "nokiaf1ap-0.0.1-16.7.0-15"
            elif plugin_name.lower() == "nokiaxnap":
                return "nokiaxnap-0.0.1-16.7.0-17"
            else:
                raise Exception("no default {} plugin use.".format(plugin_name))

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

    def _setup_wireshark(self):
        if not self._setup_wireshark_flag:
            self._setup_wireshark_flag = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#",
                                              host="192.168.255.129")

    def __del__(self):
        if self._setup_wireshark_flag:
            self.fsm_obj.teardown_all_aliases_for_enb_fsmaccess()

    def execute_cmd_on_gnb(self, cmd):
        if self.alias == "gnb1":
            return comm_obj.execute_cmd_on_gnb(cmd, board="auto")
        else:
            return comm_obj.execute_cmd_on_gnb2(cmd, board="auto")

    def _start_to_capture_wireshark_log(self, tag):
        wireshark_ports = [
            "38412",  # NGAP
            "38472",  # F1AP
            "38462",  # E1AP
            "38422",  # XNAP
            "36422",  # X2AP
            "49151",  # PCMD
        ]
        syscom_flag = builtin_obj.get_variable_value("${SYSCOM_FLAG}")
        if syscom_flag:
            wireshark_ports.append("29211")  # SYSCOM
        wireshark_name = "wireshark" if tag.count("startup") or len(tag) == 0 else "wireshark_{}".format(tag)
        # stop all wireshark and remove wireshark logs
        builtin_obj.log("step: stop all wireshark and remove wireshark logs")
        self.execute_cmd_on_gnb("ps -ef | grep 'tcpdump' | grep -v -w grep")
        self.execute_cmd_on_gnb(
            "ps aux | grep wireshark | grep -v -w grep | awk '{print $2}' | xargs kill -9")
        self.execute_cmd_on_gnb("ps -ef | grep 'tcpdump' | grep -v -w grep")
        self.execute_cmd_on_gnb("rm -rf /ffs/run/logs/wireshark*.pcap")
        # start wireshark
        builtin_obj.log("step: start wireshark")
        wireshark_cmd = "nohup tcpdump -n -X -tt -i any -w /ffs/run/logs/{}.pcap".format(wireshark_name)
        wireshark_cmd = wireshark_cmd + " port {}".format(wireshark_ports[0])
        for port in wireshark_ports[1:]:
            wireshark_cmd = wireshark_cmd + " or {}".format(port)
        wireshark_cmd = wireshark_cmd + " > /ffs/run/logs/nohup_w1.out 2>&1 &"
        self.execute_cmd_on_gnb(wireshark_cmd)

    def _stop_capture_wireshark_log(self, tag, decode_option):
        self._setup_wireshark()
        wireshark_name = "wireshark" if tag.count("startup") or len(tag) == 0 else "wireshark_{}".format(tag)
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        wireshark_dir = "{}/{}_logs/".format(save_log_dir, tag) if tag.count("startup") else save_log_dir
        # kill wireshark, also consider case failed and wireshark started by case is not collected yet
        builtin_obj.log("step: kill wireshark")
        self.execute_cmd_on_gnb("ps -ef | grep 'tcpdump' | grep -v -w grep")
        out = self.execute_cmd_on_gnb(
            "ps aux | grep wireshark | grep -v -w grep | awk '{print $2}' | xargs kill -9")
        if out.count("kill: no process ID specified"):
            # wireshark has been stopped before
            return

        # download wireshark, also consider case failed and wireshark started by case is not collected yet
        builtin_obj.log("step: download wireshark")
        time.sleep(10)
        self.execute_cmd_on_gnb("ls -ltr /ffs/run/logs/*.pcap")
        self.fsm_obj.get_enb_file("/ffs/run/logs/wireshark*.pcap", wireshark_dir, alias=self.alias)

        # convert pcap to txt, only decode wireshark specified by input tag
        if tag.count("startup") == 0:
            wireshark_in_gnb = self.execute_cmd_on_gnb("ls /ffs/run/logs/*.pcap").strip().splitlines()
            if len(wireshark_in_gnb) == 1 and wireshark_in_gnb[0].split("/")[-1].rstrip(".pcap") == wireshark_name:
                builtin_obj.log("step: decode wireshark")
                try:
                    self._decode_wireshark(wireshark_dir, wireshark_name, decode_option)
                except Exception:
                    detail = traceback.format_exc()
                    builtin_obj.log("debug: fail to decode {}/{}.pcap:{}".format(wireshark_dir, wireshark_name, detail))

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
        self.execute_cmd_on_gnb("ls -ltr /ffs/run/logs/wireshark*")
        self.fsm_obj.get_enb_file("/ffs/run/logs/{}.pcap".format(wireshark_name), wireshark_dir, alias=self.alias)
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
        self.execute_cmd_on_gnb("ps -ef | grep 'tcpdump' | grep -v -w grep")
        self.execute_cmd_on_gnb(
            "ps aux | grep '%s' | grep -v -w grep | awk '{print $2}' | xargs kill -9" % wireshark_name)
        self.execute_cmd_on_gnb("ps -ef | grep 'tcpdump' | grep -v -w grep")


class wireshark_log_gnb1(object):

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
        PCMD 49151

        | Input Parameters | Man. | Default  | Description |
        | tag              | No   | ${EMPTY} | used to name wireshark as wireshark.pcap and wireshark.txt
                                               or wireshark_${tag}.pcap and wireshark_${tag}.txt |
        Example:
        | Start To Capture Wireshark Log | 1st |
        """
        self.wireshark_log_base_instance_1._start_to_capture_wireshark_log(tag)

    def stop_capture_wireshark_log(self, tag='', decode_option=''):
        self.wireshark_log_base_instance_1._stop_capture_wireshark_log(tag, decode_option)

    def stop_wireshark_log_after_string_found(self, tag, string, decode_option=''):
        self.wireshark_log_base_instance_1._stop_wireshark_log_after_string_found(tag, string, decode_option)


class wireshark_log_gnb2(object):

    def __init__(self):
        alias = "gnb2"
        self.wireshark_log_base_instance_2 = wireshark_log_base(alias)

    def _setup_wireshark_gnb2(self):
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
        PCMD 49151

        | Input Parameters | Man. | Default  | Description |
        | tag              | No   | ${EMPTY} | used to name wireshark as wireshark.pcap and wireshark.txt
                                               or wireshark_${tag}.pcap and wireshark_${tag}.txt |
        Example:
        | Start To Capture Wireshark Log GNB2 | 1st |
        """
        self._setup_wireshark_gnb2()
        self.wireshark_log_base_instance_2._start_to_capture_wireshark_log(tag)

    def stop_capture_wireshark_log_gnb2(self, tag='', decode_option=''):
        self._setup_wireshark_gnb2()
        self.wireshark_log_base_instance_2._stop_capture_wireshark_log(tag, decode_option)

    def stop_wireshark_log_after_string_found_gnb2(self, tag, string, decode_option=''):
        self._setup_wireshark_gnb2()
        self.wireshark_log_base_instance_2._stop_wireshark_log_after_string_found(tag, string, decode_option)


class wireshark(wireshark_plugin, wireshark_log_gnb1, wireshark_log_gnb2):
    def __init__(self):
        wireshark_plugin.__init__(self)
        wireshark_log_gnb1.__init__(self)
        wireshark_log_gnb2.__init__(self)


if __name__ == "__main__":
    wireshark_obj = wireshark()
    help(wireshark_obj)
