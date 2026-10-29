# -*- coding:utf-8 -*-

import os
import time
import traceback
import re
import requests
import sys
from bs4 import BeautifulSoup
from common_lib import common_lib
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from base_lib.ute_fsmaccess import ute_fsmaccess

comm_obj = common_lib()
os_obj = OperatingSystem()
builtin_obj = BuiltIn()

NSETAP_PLUGIN_URL = r"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP"


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
                comm_obj.execute_cmd_on_pc("rm -rf {}/*nsetap*.so".format(self.local_plugin_path))
                comm_obj.execute_cmd_on_pc("ls -ltr {}".format(self.local_plugin_path))

            # get debian version
            builtin_obj.log("step: mapping debian version to plugin postfix")
            debian_version = comm_obj.execute_cmd_on_pc("lsb_release -a | grep -i release").split()[-1]
            builtin_obj.log("debug: debian version is {}".format(debian_version))
            if debian_version == "10":
                self.plugin_postfix = "buster.so"
            elif debian_version == "12":
                self.plugin_postfix = "bookworm.so"
            else:
                raise Exception("not support debian {} yet".format(debian_version))

            # get bts version
            self.bts_version = builtin_obj.get_variable_value("${ENB_SW_VERSION}")
            if self.bts_version.count("_9999_"):
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

    def _get_nsetap_plugin_file_name(self, wireshark_version, plugin_folder_name):
        r = requests.get("{}/{}/".format(NSETAP_PLUGIN_URL, plugin_folder_name))
        soup = BeautifulSoup(r.content, 'lxml')
        nsetap_plugin_file_name = ""
        for a_tag in soup.find_all('a')[::-1]:
            search_result = re.search("nsetap-{}-.*{}$".format(wireshark_version, self.plugin_postfix),
                                      a_tag.text)
            if search_result:
                nsetap_plugin_file_name = search_result.group(0)
                break
        if not nsetap_plugin_file_name:
            raise Exception("get nsetap pulgin file name failure")
        else:
            return nsetap_plugin_file_name

    def _download_wireshark_nsetap_plugin(self):
        self._setup_wireshark_plugin()
        builtin_obj.log("step: get nsetap download path")
        nsetap_plugin_ver = builtin_obj.get_variable_value("${NSETAP_PLUGIN_VERSION}")
        builtin_obj.log("debug: nsetap_plugin_ver={}, length={}".format(nsetap_plugin_ver, len(nsetap_plugin_ver)))
        if len(nsetap_plugin_ver):
            nsetap_plugin_folder_name = "nsetap-" + nsetap_plugin_ver
        else:
            nsetap_plugin_folder_name = self._get_latest_plugin_folder_name(plugin_name="nsetap",
                                                                            plugin_address=NSETAP_PLUGIN_URL)
        nsetap_pulgin_file = self._get_nsetap_plugin_file_name(self.wireshark_version, nsetap_plugin_folder_name)
        builtin_obj.log("nsetap download path: {}/{}/{}".format(NSETAP_PLUGIN_URL,
                                                                nsetap_plugin_folder_name,
                                                                nsetap_pulgin_file))

        # download plugin, retry 1 time if failed
        builtin_obj.log("step: download nsetap")
        self._download_plugin_to_specific_folder(
            plugin_url="{}/{}".format(NSETAP_PLUGIN_URL, nsetap_plugin_folder_name),
            plugin_file=nsetap_pulgin_file,
            local_plugin_path=self.local_plugin_path)

        builtin_obj.log("step: check active plugins")
        active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
        if "nsetap" not in active_plugins:
            builtin_obj.log("step: download nsetap")
            self._download_plugin_to_specific_folder(
                plugin_url="{}/{}".format(NSETAP_PLUGIN_URL, nsetap_plugin_folder_name),
                plugin_file=nsetap_pulgin_file,
                local_plugin_path=self.local_plugin_path)
            builtin_obj.log("step: check active plugins")
            active_plugins = comm_obj.execute_cmd_on_pc("tshark -G plugins")
            if "nsetap" not in active_plugins:
                raise Exception("fail to download nsetap plugin")

    def _download_plugin_to_specific_folder(self, plugin_url, plugin_file, local_plugin_path):
        os.system("sudo chmod 777 %s" % local_plugin_path)
        comm_obj.execute_cmd_on_pc("cd {}".format(local_plugin_path))
        comm_obj.execute_cmd_on_pc("wget {}/{}".format(plugin_url, plugin_file))

    def _get_latest_plugin_folder_name(self, plugin_name, plugin_address):
        builtin_obj.log("debug: get latest {} plugin".format(plugin_name))
        try:
            r = requests.get(plugin_address)
            soup = BeautifulSoup(r.content, 'lxml')
            # check bts_version exists in library
            plugin_folder_pattern = re.compile(r'.*">({}.*)/</a>.*'.format(plugin_name))
            plugin_folder_result = plugin_folder_pattern.findall(str(soup))
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

                for version in plugin_folder_result:
                    try:
                        key = version.split('-', 1)[-1]
                        split_key_left = key.rsplit(".", 1)[0]
                        split_key_right = key.rsplit(".", 1)[-1].rsplit('-', 1)[-1]
                        key = float(split_key_left) * 100 + float(split_key_right)
                    except Exception:
                        continue
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
            builtin_obj.log("get latest {} plugin name fails.".format(plugin_name), level="WARN")
            if plugin_name.lower() == "nokiaf1ap":
                return "nokiaf1ap-16.8.0-26"
            elif plugin_name.lower() == "nokiaxnap":
                return "nokiaxnap-16.8.0-24"
            elif plugin_name.lower() == "nsetap":
                return "nsetap-1.7.1"
            else:
                raise Exception("no default {} plugin use.".format(plugin_name))

    def download_wireshark_plugin(self):
        # download nsetap plugin
        try:
            self._download_wireshark_nsetap_plugin()
        except Exception:
            details = traceback.format_exc()
            builtin_obj.log("download wireshark nsetap plugin failure. {}".format(details))
            builtin_obj.log("download wireshark nsetap plugin failure.", level="WARN")


class wireshark_log_base(object):
    def __init__(self, alias):
        self.alias = alias
        self.remote_host = None
        self.bts_host = "192.168.255.129"
        self._setup_wireshark_flag = False
        self.wireshark_protocol_info = {}

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
        if self.alias == "enb1":
            return comm_obj.execute_cmd_on_enb(cmd)
        else:
            return comm_obj.execute_cmd_on_enb2(cmd)

    def _start_to_capture_wireshark_log(self, tag):
        self._setup_wireshark()
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
        enb_s1_interface = comm_obj.get_s1_interface()
        wireshark_cmd = "nohup tcpdump -n -X -tt -i {} -w /tmp/{}.pcap -s 1600 > /tmp/nohup_w1.out 2>&1 &".format(
            enb_s1_interface, wireshark_name)
        self._execute_cmd_on_bts(wireshark_cmd)
        time.sleep(10)
        self._execute_cmd_on_bts("ps -ef | grep 'tcpdump' | grep -v -w grep")
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")

    def _stop_capture_wireshark_log(self, tag):
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

        # delete wireshark Tag pcap
        self._execute_cmd_on_bts("ls -ltrh /tmp/*.pcap")
        self._execute_cmd_on_bts("rm -rf /tmp/%s.pcap" % wireshark_name)
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


class wireshark_log_bts1(object):

    def __init__(self):
        alias = "enb1"
        self.wireshark_log_base_instance_1 = wireshark_log_base(alias)

    def start_to_capture_wireshark_log(self, tag=''):
        """
        This keyword is to start to capture wireshark log in BTS
        | Input Parameters | Man. | Default  | Description |
        | tag              | No   | ${EMPTY} | used to name wireshark as wireshark.pcap and wireshark.txt
                                               or wireshark_${tag}.pcap and wireshark_${tag}.txt |
        Example:
        | Start To Capture Wireshark Log | 1st |
        """
        self.wireshark_log_base_instance_1._start_to_capture_wireshark_log(tag)

    def stop_capture_wireshark_log(self, tag=''):
        self.wireshark_log_base_instance_1._stop_capture_wireshark_log(tag)

    def stop_wireshark_log_after_string_found(self, tag, string, decode_option=''):
        self.wireshark_log_base_instance_1._stop_wireshark_log_after_string_found(tag, string, decode_option)


class wireshark_log_bts2(object):

    def __init__(self):
        alias = "enb2"
        self.wireshark_log_base_instance_2 = wireshark_log_base(alias)

    def _setup_wireshark_bts2(self):
        self.wireshark_log_base_instance_2.bts_host = builtin_obj.get_variable_value('${ENB2_IP}')  # S1 IP
        self.wireshark_log_base_instance_2.remote_host = builtin_obj.get_variable_value('${ENB2_PC_IP}')

    def start_to_capture_wireshark_log_enb2(self, tag=''):
        """
        This keyword is to start to capture wireshark log in BTS
        | Input Parameters | Man. | Default  | Description |
        | tag              | No   | ${EMPTY} | used to name wireshark as wireshark.pcap and wireshark.txt
                                               or wireshark_${tag}.pcap and wireshark_${tag}.txt |
        Example:
        | Start To Capture Wireshark Log eNB2 | 1st |
        """
        self._setup_wireshark_bts2()
        self.wireshark_log_base_instance_2._start_to_capture_wireshark_log(tag)

    def stop_capture_wireshark_log_enb2(self, tag=''):
        self._setup_wireshark_bts2()
        self.wireshark_log_base_instance_2._stop_capture_wireshark_log(tag)

    def stop_wireshark_log_after_string_found_enb2(self, tag, string, decode_option=''):
        self._setup_wireshark_bts2()
        self.wireshark_log_base_instance_2._stop_wireshark_log_after_string_found(tag, string, decode_option)


class wireshark(wireshark_plugin, wireshark_log_bts1, wireshark_log_bts2):
    def __init__(self):
        wireshark_plugin.__init__(self)
        wireshark_log_bts1.__init__(self)
        wireshark_log_bts2.__init__(self)


if __name__ == "__main__":
    wireshark_obj = wireshark()
    help(wireshark_obj)
