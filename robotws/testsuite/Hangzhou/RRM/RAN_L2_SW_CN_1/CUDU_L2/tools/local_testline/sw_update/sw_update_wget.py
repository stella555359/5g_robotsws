# -*- coding:utf-8 -*-
# Author: Zhang Yin
import os
import sys
import time
import datetime
import re
import platform
import traceback
import json
try:
    from robot.libraries.BuiltIn import BuiltIn
    from robot.libraries.OperatingSystem import OperatingSystem
except ModuleNotFoundError as e:
    print("[\033[31m ERROR \033[0m ] please switch to virtual env and execute this script, "
          "input 'robot' command , 'source /home/ute/test_repo/bin/activate' or install library. {}".format(e))
    exit()
from taf.sbts.oam.coam.admin import admin as ute_admin
from taf.pdu import pdu
from ute_fsmaccess import ute_fsmaccess
from ute_fsmaccess.exception import UnknownFsmHwVersion
from ute_admin_infomodel import ute_admin_infomodel
curdir = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, curdir)
sys.path.insert(1, os.path.join(curdir, "../../resources/DevHZ5_lib/src/base_lib"))
try:
    from ta_ssh_telnet import ta_ssh_telnet
    from ta_enb_dependency_selector.downloader import Downloader
except Exception:
    raise
builtin_obj = BuiltIn()
os_obj = OperatingSystem()

downloader = Downloader()
debug_log = "/home/ute/update.log"
os_obj.remove_file(debug_log)


class sw_update(object):
    def __init__(self):
        self.ap_build_file = ""
        self.alias = "enb"
        self.bts_host = "192.168.255.129"
        self.ap = "192.168.200.1"
        self._setup_sw_update_flag = False
        self.bts_port = "443"
        self.use_ssl = True
        self.bts_info = {}
        self.vm_memory_size = ""
        self.confirmed_gnb_version = ""
        self.confirmed_ap_version = ""
        self.ip_127_add_flag = False
        self.download_server_gnb_s3 = "http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build"
        self.download_server_gnb_ute = "http://files.ute.nsn-rdnet.net/builds/enb/base/"
        self.download_server_gnb_hz1 = \
            "http://artifactory-hz1.int.net.nokia.com/artifactory/ute-files-remote-cache/builds/enb/base/"
        self.download_server_gnb_wro1 = \
            "http://artifactory-wro1.int.net.nokia.com/artifactory/ute-files-remote-cache/builds/enb/base/"
        self.download_server_ap = "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone"
        # for config init
        self.tl = ""
        self.tl2 = ""
        self.configuration_name = ""
        self.target_dir = "/home/ute/testline_init_results/configs"
        self.target_dir_second = "/home/ute/testline_configuration"
        self.testline_site = "Hangzhou"

    def _setup_sw_update(self):
        if not self._setup_sw_update_flag:
            try:
                self._setup_sw_update_flag = True
                self.admin_obj = ute_admin()
                self.admin_obj.setup_admin(alias=self.alias, bts_port=self.bts_port, use_ssl=self.use_ssl,
                                           bts_host=self.bts_host)
                self.fsm_obj = ute_fsmaccess()
                self.fsm_obj.setup_enb_fsm_access(alias=self.alias, fallback_prompt="#", host=self.bts_host)
                self.fsm_obj.setup_wts_fsm_access(alias=self.alias, fallback_prompt="#", host="192.168.200.1")
                self.ute_im_obj = ute_admin_infomodel()
                self.ute_im_obj.setup_infomodel(port=self.bts_port, use_ssl=self.use_ssl, alias=self.alias,
                                                address=self.bts_host)
                self.ute_im_obj.connect_infomodel(alias=self.alias)
                self.ssh_obj = ta_ssh_telnet()
                self.pc_conn = self.ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute",
                                                            conn_type="SSH", timeout="10")
            except Exception:
                detail = traceback.format_exc()
                traceback.print_exc()
                self._log_to_file("Setup gnb or ap connection failure, please check gnb or airphone state.",
                                  level="ERROR")

    def __enter__(self):
        pass

    def __exit__(self, exc_type, exc_val, exc_tb):
        try:
            # delete 192.168.200.127
            if self.ip_127_add_flag:
                self.ssh_obj.execute_shell_command("sudo ip addr del 192.168.200.127/24 dev eth2")
                eth2_info = self.ssh_obj.execute_shell_command("ip addr show eth2")
                self._log_to_file("eth2 after delete 192.168.200.127: {}".format(eth2_info), console=False)

            self.admin_obj.teardown_admin(alias=self.alias)
            self.fsm_obj.teardown_enb_fsm_access(alias=self.alias)
            self.fsm_obj.teardown_wts_fsm_access(alias=self.alias)
            self.ute_im_obj.disconnect_infomodel(alias=self.alias)
            self.ute_im_obj.teardown_infomodel(alias=self.alias)
            self.ssh_obj.disconnect_all_hosts()
        except Exception:
            pass

    def _log_to_file(self, log, console=True, level="INFO"):
        current_time = builtin_obj.get_time()
        log_on_file = "[ %s ] %s  %s" % (level, current_time, log)
        if console:
            log_on_console = "[ %s ] %s  %s" % (self._set_color_by_level(level), current_time, log)
            print(log_on_console)
        if not os.path.exists(debug_log):
            self._execute_command("touch %s" % debug_log)
        try:
            self._execute_command("echo '%s' >> %s" % (log_on_file, debug_log))
        except Exception:
            pass

    def _set_color_by_level(self, level):
        if level.upper() == "INFO":
            return self._set_font_color(font=level, color="green")
        elif level.upper() == "WARN":
            return self._set_font_color(font=level, color="yellow")
        elif level.upper() == "ERROR":
            return self._set_font_color(font=level, color="red")
        else:
            return level

    def _set_font_color(self, font, color="green"):
        if color.lower() == "green":
            return "\033[32m{}\033[0m".format(font)
        elif color.lower() == "yellow":
            return "\033[33m{}\033[0m".format(font)
        elif color.lower() == "red":
            return "\033[31m{}\033[0m".format(font)
        else:
            return font

    def _execute_command(self, cmd, timeout="10"):
        self._setup_sw_update()
        try:
            self.ssh_obj.switch_host_connection(self.pc_conn)
            self.ssh_obj.set_shell_timeout(int(timeout))
            out = self.ssh_obj.execute_shell_command(cmd)
        except Exception:
            detail = traceback.format_exc()
            try:
                self.ssh_obj.disconnect_from_host(self.pc_conn)
            except Exception:
                pass
            self.pc_conn = self.ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute", conn_type="SSH", timeout="10")
            self.ssh_obj.switch_host_connection(self.pc_conn)
            self.ssh_obj.set_shell_timeout(int(timeout))
            out = self.ssh_obj.execute_shell_command(cmd)
        return out.strip()

    def _execute_command_on_aashell(self, cmd, port='15007', timeout="10"):
        self._setup_sw_update()
        try:
            self.ssh_obj.switch_host_connection(self.pc_conn)
            old_timeout = self.ssh_obj.set_shell_timeout(int(timeout))
            old_prompt = self.ssh_obj.set_shell_prompt("Password:", ">")
            self.ssh_obj.execute_shell_command("ssh toor4nsn@192.168.255.129")
            self.ssh_obj.execute_shell_command("oZPS0POrRieRtu")
            self.ssh_obj.set_shell_prompt("AaShell>")
            self.ssh_obj.execute_shell_command("telnet 127.0.0.1 %s" % port)
            out = self.ssh_obj.execute_shell_command(cmd)
        except Exception:
            detail = traceback.format_exc()
            self._log_to_file("Execute cmd aashell failure {}, "
                              "please check gnb or gnb port: {} status  ".format(detail, port), level="WARN")
            try:
                self.ssh_obj.disconnect_from_host(self.pc_conn)
                self.pc_conn = self.ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute",
                                                            conn_type="SSH", timeout="10")
                self.ssh_obj.switch_host_connection(self.pc_conn)
                old_timeout = self.ssh_obj.set_shell_timeout(int(timeout))
                old_prompt = self.ssh_obj.set_shell_prompt("Password:", ">")
                self.ssh_obj.execute_shell_command("ssh toor4nsn@192.168.255.129")
                self.ssh_obj.execute_shell_command("oZPS0POrRieRtu")
                self.ssh_obj.set_shell_prompt("AaShell>")
                self.ssh_obj.execute_shell_command("telnet 127.0.0.1 15007")
                out = self.ssh_obj.execute_shell_command(cmd)
            except Exception:
                detail = traceback.format_exc()
                raise Exception("re-execute cmd aashell failure {}, "
                                "please check gnb or gnb port: {} status  ".format(detail, port))
        finally:
            self.ssh_obj.set_shell_prompt(old_prompt)
            self.ssh_obj.set_shell_timeout(old_timeout)
            self.ssh_obj.execute_shell_command("quit")
            self.ssh_obj.execute_shell_command("exit")
        return out.strip()

    def _set_ip_to_connect_ap(self):
        # gnb2 control PC can not access AP, add 192.168.200.127 to connect AP
        self._setup_sw_update()
        eth2_info = self.ssh_obj.execute_shell_command("ip addr show eth2")
        self._log_to_file("eth2 info: {}".format(eth2_info))
        if eth2_info.count("192.168.200.126") == 0 and eth2_info.count("192.168.200.127") == 0:
            self.ip_127_add_flag = True
            self.ssh_obj.execute_shell_command("sudo ip addr add 192.168.200.127/24 dev eth2")
            eth2_info = self.ssh_obj.execute_shell_command("ip addr show eth2")
            self._log_to_file("eth2 info after modified: {}".format(eth2_info))

    def _get_vm_space(self, path):
        out = self._execute_command("df --output=avail {} | tail -n 1".format(path))
        self._log_to_file("Current available space on folder {} is {}G".format(path, int(int(out)/1024/1024)))
        return int(out)

    def _check_available_download_space(self, download_path, target_dir):
        self._setup_sw_update()
        out = self._execute_command("wget --spider --tries 1 -T 5 {}".format(download_path))
        ret = re.search(r"Length:\s(\d+)", out, re.I)
        if ret:
            file_size = ret.group(1)
        else:
            self._log_to_file("Get download file size failure, "
                              "download path is {}, output is {}".format(download_path, out), level="WARN")
            return
        dir_space_size = int(self._get_vm_space(path=target_dir)) * 1024
        if int(file_size) > int(dir_space_size):
            self._log_to_file("Available space is not enough, available space is {}, request space is {}"
                              "".format(dir_space_size, file_size), level="ERROR")
            raise Exception("Download file failure due to space not enough")

    def _check_if_aria2_support(self):
        # self._setup_sw_update()
        # self._log_to_file("Check aria2 download method support or not")
        # out = self._execute_command("aria2c -h")
        # out_status = self._execute_command("echo $?")
        # if int(out_status) == 0:
        #     self._log_to_file("aria2 download support")
        #     return True
        # else:
        #     self._log_to_file("aria2 download not support, you can use command 'sudo apt install aria2' to install.")
        #     return False
        return False

    def _download_sw_build(self, sw_build, type):
        max_try_times = 2
        self._setup_sw_update()
        # no need to download if build already under /home/ute
        if sw_build.count("http"):
            remove_regexp = re.compile('|'.join([
                r"_release_BTSSM_downloadable_A\d+.zip"]
            ))
            target_dir = "/home/ute/%s_%s" % (type, remove_regexp.sub("", sw_build.strip("/").split("/")[-1]))
        else:
            if sw_build.count("_9999_"):
                sw_build = "SBTS00_" + sw_build.partition("_")[-1]
            target_dir = "/home/ute/%s_%s" % (type, sw_build)
        out = self._execute_command("ls %s/*.zip | grep -i release_BTSSM_downloadable" % target_dir)
        if out.count("No such file or directory") == 0:
            self._log_to_file("Existing %s build: %s, no need to download" % (type, out))
            return target_dir

        # test download path
        find_flag = False
        download_paths = []
        print(sw_build)
        if sw_build.count("http"):
            download_paths.append(sw_build)
        else:
            if type == "GNB":
                download_timeout = "1200"
                download_paths = self._get_gnb_optimal_download_path(download_paths, sw_build)
            elif type == "AP":
                download_timeout = "300"
                download_paths.append("%s/%s/AirScale-%s.zip" % (self.download_server_ap, sw_build, sw_build))
            else:
                raise Exception("not support %s" % type)
        for path in download_paths:
            rc = os.system("wget --spider --tries 1 -T 5 %s" % path)
            if int(rc) == 0:
                find_flag = True
                download_path = path
                break
        if find_flag is False:
            raise Exception("can not get %s, pls manually download it to %s and rerun this script"
                            % (download_paths, target_dir))
        self._check_available_download_space(download_path=download_path, target_dir="/home/ute")
        # check if need download by aria2
        is_aria2c = self._check_if_aria2_support()
        # download SW build
        while (max_try_times > 0):
            try:
                self._log_to_file("Downloading %s build: %s..." % (type, download_path.split("/")[-1]))
                if is_aria2c:
                    cmd = "aria2c -j 16 -x 16 -s 16 -d %s %s --console-log-level error" % (target_dir, download_path)
                else:
                    cmd = "wget -c %s -P %s" % (download_path, target_dir)
                self._log_to_file("download path:{},target dir:{}".format(download_path, target_dir))
                rc = os.system(cmd)
                out = self._execute_command("ls -l %s/*.zip" % target_dir)
                self._log_to_file(out, console=False)
                break
            except Exception:
                detail = traceback.format_exc()
                self._log_to_file(detail, console=False)
                self._log_to_file("Downloading %s build failed" % type)
                self._execute_command("rm -rf %s" % target_dir, "300")
                max_try_times = max_try_times - 1
        if max_try_times == 0:
            raise Exception("downloading %s build failed, pls manually download it to %s and rerun this script"
                            % (type, target_dir))

        # download esimode for AP
        if type == "AP":
            self._log_to_file("Downloading esimmode...")
            download_path_e = download_path.rpartition("/")[0]
            cmd = "wget -r -l1 -nd -nv --no-parent -A core2.tar.bz2  %s -P %s" % (download_path_e, target_dir)
            rc = os.system(cmd)
        return target_dir

    def _get_gnb_optimal_download_path(self, download_paths, sw_build):
        if not isinstance(download_paths, list):
            download_paths = list()
        if self.testline_site.lower().count("hangzhou"):
            download_paths.append("%s/%s/%s_release_BTSSM_downloadable.zip"
                                  % (self.download_server_gnb_hz1, sw_build, sw_build))
            download_paths.append("%s/%s/%s_release_BTSSM_downloadable_A54.zip"
                                  % (self.download_server_gnb_s3, sw_build.split("_")[0], sw_build))
            download_paths.append("%s/%s/%s_release_BTSSM_downloadable.zip"
                                  % (self.download_server_gnb_ute, sw_build, sw_build))
        elif self.testline_site.lower().count("wroclaw"):
            download_paths.append("%s/%s/%s_release_BTSSM_downloadable.zip"
                                  % (self.download_server_gnb_wro1, sw_build, sw_build))
            download_paths.append("%s/%s/%s_release_BTSSM_downloadable_A54.zip"
                                  % (self.download_server_gnb_s3, sw_build.split("_")[0], sw_build))
            download_paths.append("%s/%s/%s_release_BTSSM_downloadable.zip"
                                  % (self.download_server_gnb_ute, sw_build, sw_build))
        else:
            download_paths.append("%s/%s/%s_release_BTSSM_downloadable_A54.zip"
                                  % (self.download_server_gnb_s3, sw_build.split("_")[0], sw_build))
            download_paths.append("%s/%s/%s_release_BTSSM_downloadable.zip"
                                  % (self.download_server_gnb_ute, sw_build, sw_build))
            download_paths.append("%s/%s/%s_release_BTSSM_downloadable.zip"
                                  % (self.download_server_gnb_hz1, sw_build, sw_build))
        return download_paths

    def _power_off(self, hw):
        hw = hw.lower()
        pdu_model, pdu_port = self._get_pdu_info(hw)
        pdu_obj = pdu()
        self._log_to_file("Power off {}".format(hw))
        pdu_obj.setup_pdu(pdu_model, alias=hw, timeout=30)
        try:
            pdu_obj.power_off(pdu_port, pdu_device=hw)
        except Exception:
            detail = traceback.format_exc()
            self._log_to_file("Fail to power off {}: {}".format(hw, detail), level="ERROR")

    def _power_on(self, hw):
        hw = hw.lower()
        pdu_model, pdu_port = self._get_pdu_info(hw)
        pdu_obj = pdu()
        self._log_to_file("Power on {}".format(hw))
        pdu_obj.setup_pdu(pdu_model, alias=hw, timeout=30)
        try:
            pdu_obj.power_on(pdu_port, pdu_device=hw)
        except Exception:
            detail = traceback.format_exc()
            self._log_to_file("Fail to power on {}: {}".format(hw, detail), level="ERROR")

    def _wait_equipment_disconnect(self, ip, timeout=60):
        retry_times = int(timeout) / 10
        while retry_times > 0:
            time.sleep(10)
            result = self._ping_ok(ip)
            if result is False:
                break
            else:
                retry_times = retry_times - 1
        if retry_times == 0:
            raise Exception("%s is not restarted via PDU successfully" % ip)

    def _ping_ok(self, ip):
        out = self._execute_command("ping %s -c 2" % ip)
        if out.count("100% packet loss"):
            return False
        else:
            return True

    def _get_pdu_info(self, hw):
        tl = self.tl
        tl2 = self.tl2
        if hw == "gnb1" or hw == "gnb":
            pdu_model = tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu
            pdu_port = tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no
        elif hw == "gnb2":
            pdu_model = tl2.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu
            pdu_port = tl2.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no
        elif hw == "ap":
            pdu_model = tl.ues[0].l1.common_units[0].pdu_port.pdu
            pdu_port = tl.ues[0].l1.common_units[0].pdu_port.port_no
        else:
            raise Exception("Not support {}".format(hw))
        return pdu_model, pdu_port

    def _get_testline_config(self):
        # try:
        #     if os.path.isdir("/home/ute") is False:
        #         raise Exception("work folder is not on /home/ute")
        #     else:
        #         self._get_configuration()
        #         self._set_configuration()
        # except Exception:
        #     # details = traceback.format_exc()
        #     # self._log_to_file("Get local config module failure, err is :{}".format(details), level="WARN")
        #     self._log_to_file("Get local config module failure", level="WARN")
        # read testline location
        self._get_testline_site()

    def _get_configuration(self):
        self._setup_sw_update()
        sysstr = platform.system()
        if sysstr == "Windows":  # for dryrun
            return

        host_name = self._execute_command("hostname")
        host_name = re.sub("-1$", "", host_name)
        host_name = re.sub("-2$", "", host_name)
        host_name = host_name.replace("-", "_")
        if os.path.isdir("%s/%s" % (self.target_dir, host_name)):
            # read init file from target_dir folder
            self.configuration_name = host_name
        elif os.path.isdir("%s/%s" % (self.target_dir_second, host_name)):
            # read init file from target_dir_second folder and copy to target_dir folder
            self._execute_command("mkdir -p %s" % self.target_dir)
            self._execute_command("rm -rf %s/%s" % (self.target_dir, host_name))
            self._execute_command("cp -r %s/%s %s/%s"
                                  % (self.target_dir_second, host_name, self.target_dir, host_name))
            self.configuration_name = host_name
        else:
            # read init file from variable_files and copy to target_dir folder
            self._log_to_file("Hostname is %s" % host_name)
            host_ip = self._execute_command("sudo ifconfig eth0 | grep -w inet | awk '{print $2}'")
            self._log_to_file("Hostip is %s" % host_ip)
            curdir = os.path.dirname(os.path.realpath(__file__))
            source_dir = "%s/../../resources/configuration_file/variable_files" % curdir
            source_name = self._execute_command("ls %s | grep %s" % (source_dir, host_ip))
            self._log_to_file("Source_dir=%s, source_name=%s" % (source_dir, source_name))
            if len(source_name):
                target_name = source_name.split("_")[0] + "_" + source_name.split(".")[-1]
                self._log_to_file("Target_dir=%s, target_name=%s" % (self.target_dir, target_name))
                self._execute_command("mkdir -p %s" % self.target_dir)
                self._execute_command("rm -rf %s/%s" % (self.target_dir, target_name))
                self._execute_command("cp -r %s/%s %s/%s" % (source_dir, source_name, self.target_dir, target_name))
                self.configuration_name = target_name
            else:
                self._log_to_file("No testline config module __init__.py under %s" % source_dir)
                self._log_to_file("Pls fill the following info and send them to "
                                  "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com to create for you")
                self._log_to_file("   host ip:")
                self._log_to_file("   powerbreak vendor, IP and port for GNB:")
                self._log_to_file("   powerbreak vendor, IP and port for AP:")
                self._log_to_file("   vlan_id:")
                self._log_to_file("Lack of local testline config module", level='ERROR')
                raise Exception("lack of local testline config module")

    def _set_configuration(self):
        self._setup_sw_update()
        curdir = os.path.dirname(os.path.realpath(__file__))
        cmd = "cp -r {}/{} {}/{}".format(self.target_dir, self.configuration_name, curdir, "localConfig")
        self._execute_command(cmd)
        import localConfig
        self.tl = localConfig.tl
        self._execute_command("rm -rf {}/{}".format(curdir, "localConfig"))
        self._log_to_file("Read local config module success,"
                          " path is {}/{}".format(self.target_dir, self.configuration_name))

    def _get_testline_site(self):
        ute_context_file = "/opt/ute/reservation.context.json"
        try:
            if os.path.exists(ute_context_file):
                with open(ute_context_file, "r") as f_obj:
                    ute_reservation_dict = json.load(f_obj)
                    self.testline_site = ute_reservation_dict["CM_RESOURCES"][
                        0]["properties"]["machines"][0]["properties"]["server"]["properties"]["site"]
            else:
                self.testline_site = "Hangzhou"
        except Exception as err:
            self.testline_site = "Hangzhou"
        finally:
            self._log_to_file("Read testline location is:{}".format(self.testline_site))

    def _update_gnb_build(self, target_dir):
        gnb_build = self._execute_command("ls %s/*.zip" % target_dir)
        self._setup_sw_update()
        try:
            self._log_to_file("Updating SW Build: %s" % gnb_build)
            self.admin_obj.update_software(gnb_build, timeout="1200", alias=self.alias)
            time.sleep(30)
        except Exception:
            detail = traceback.format_exc()
            self._log_to_file("Fail to update SW build: %s\r\nUpdating SW Build failed" % detail,
                              console=True, level="ERROR")
            raise Exception(detail)

    def _wait_bbmod_startup(self):
        self._log_to_file("Wait all BBMODs startup")
        self.ute_im_obj.query_infomodel("every //BBMOD_R-* is [stateInfo.availabilityStatus=Online]", timeout=600,
                                        alias=self.alias)

    def _execute_deploy_cmd(self, target, dci_script, cmd):
        if cmd.count("deploy.sh"):
            prompt = "(type yes to confirm)"
            answer = "yes"
        elif cmd.count("uninstall.sh"):
            prompt = "Are you sure (y/n)?"
            answer = "y"
        try:
            conn = self.ssh_obj.connect_to_host(target, "22", "toor4nsn", "oZPS0POrRieRtu", conn_type="SSH",
                                                timeout="10")
            # self.ssh_obj.execute_shell_command("rm -rf /rom/DCI_link; mkdir /rom/DCI_link; cd /rom/DCI_link")
            # self.ssh_obj.execute_shell_command(
            #    "tar -zxvf /rom/%s -C /rom/DCI_link; chmod -R 777 /rom/DCI_link" % dci_script)
            #             modify_dci = 'export ROUTE_CREATION_METHOD=\\"DIRECT_ROUTES\\"'
            #             self.ssh_obj.execute_shell_command("echo %s >> /rom/DCI_link/deploy.cfg" %modify_dci)
            old_prompt = self.ssh_obj.set_shell_prompt(prompt)
            out1 = self.ssh_obj.execute_shell_command("cd /rom/DCI_link;" + cmd)
            self.ssh_obj.set_shell_prompt(old_prompt)
            out2 = self.ssh_obj.execute_shell_command(answer, timeout=300)
            self._log_to_file(out1 + out2, console=False)
        except Exception:
            detail = traceback.format_exc()
            self._log_to_file(detail, level="WARN")
            self.ssh_obj.disconnect_from_host(conn)

    def _download_DCI(self):
        self._setup_sw_update()
        self.fsm_obj.wait_until_host_is_available(self.bts_host, timeout=180, alias=self.alias)
        self.fsm_obj.wait_until_host_is_available(self.ap, timeout=180, alias=self.alias)
        # Imporve robustness on Get Wts Version ,if fail , retry 10 times and interval 60 seconds
        wts_version = self._retry_function_on_specific_times(
                    func_name=self.fsm_obj.get_wts_sw_version, retry_times=10, interval_time=60, alias=self.alias
                                                            )
        wts_version_s = "%s.%s.%s" % (wts_version.split("_")[3].lstrip("0"),
                                      wts_version.split("_")[4][:-1].lstrip("0") + wts_version.split("_")[4][-1],
                                      wts_version.split("_")[5].lstrip("0"))
        target_dir = "/home/ute/AP_%s" % wts_version_s
        dci_script = "DCI_link_network_config-%s.tar.gz" % wts_version_s
        out = self._execute_command("ls %s/%s" % (target_dir, dci_script))
        if out.count("No such file or directory"):
            download_path = "%s/%s/%s" % (self.download_server_ap, wts_version_s, dci_script)
            out = self._execute_command("wget --tries 1 -T 10 --spider %s" % download_path)
            if out.count("Remote file does not exist"):
                raise Exception("can not find %s from %s" % (dci_script, download_path.rpartition("/")[0]))
            self._log_to_file("Downloading DCI script: %s..." % dci_script)
            cmd = "wget -nv %s -P %s" % (download_path, target_dir)
            self._log_to_file(cmd)
            self._execute_command(cmd, "120")
        self.fsm_obj.execute_command_on_enb("rm -rf /rom/%s" % dci_script, alias=self.alias)
        self.fsm_obj.execute_command_on_wts("rm -rf /rom/%s" % dci_script, alias=self.alias)
        self.fsm_obj.put_enb_file("%s/%s" % (target_dir, dci_script), "/rom", alias=self.alias)
        self.fsm_obj.put_wts_file("%s/%s" % (target_dir, dci_script), "/rom", alias=self.alias)
        self.fsm_obj.execute_command_on_enb(
            "rm -rf /rom/DCI_link; mkdir /rom/DCI_link; cd /rom/DCI_link", alias=self.alias)
        self.fsm_obj.execute_command_on_enb(
            "tar -zxvf /rom/%s -C /rom/DCI_link; chmod -R 777 /rom/DCI_link" % dci_script, alias=self.alias)
        self.fsm_obj.execute_command_on_wts(
            "rm -rf /rom/DCI_link; mkdir /rom/DCI_link; cd /rom/DCI_link", alias=self.alias)
        self.fsm_obj.execute_command_on_wts(
            "tar -zxvf /rom/%s -C /rom/DCI_link; chmod -R 777 /rom/DCI_link" % dci_script, alias=self.alias)
        return dci_script

    def _uninstall_DCI_link(self):
        dci_script = self._download_DCI()
        self._log_to_file("Uninstall DCI script on GNB")
        self._execute_deploy_cmd(self.bts_host, dci_script, "./uninstall.sh")
        self._log_to_file("Uninstall DCI script on AP")
        self._execute_deploy_cmd(self.ap, dci_script, "./uninstall.sh")

    def _install_DCI_link(self):
        # download DCI script
        dci_script = self._download_DCI()
        # set airphone domain id
        self.fsm_obj.execute_command_on_wts("ddal -s ddal_sysinfo_module_set_domain_id 0 5", alias=self.alias)
        self.fsm_obj.execute_command_on_wts("ddal -s ddal_bip_domain_id_set 4", alias=self.alias)
        self.fsm_obj.execute_command_on_wts("ddal -s ddal_sysinfo_module_get_domain_id 0", alias=self.alias)
        self.fsm_obj.execute_command_on_wts("ddal -s ddal_bip_domain_id_get 0", alias=self.alias)
        # install DCI script on GNB
        self._log_to_file("Install DCI script on GNB")
        if self.bts_info["bbu_type"].count("ASOE"):
            self._log_to_file("Skip install DCI script on GNB Due To Hardware is ASOE", console=True)
        elif self.bts_info["bbu_type"].count("ASIB"):
            self._log_to_file("Skip install DCI script on GNB Due To Hardware is ASIB", console=True)
        elif self.bts_info["bbu_type"].count("ASIL"):
            self._log_to_file("Skip install DCI script on GNB Due To Hardware is ASIL", console=True)
        elif self.bts_info["bbu_type"].count("ASIK") and self.bts_info["wts_hw_type"].count("ASIK") \
                and self.bts_info["ap_port_state"]["15"]:
            self._log_to_file("Airphone DCI port on EIF2 can be up and deploy on GNB", console=True)
            self._execute_deploy_cmd(self.bts_host, dci_script, "./deploy.sh")
        elif self.bts_info["bbu_type"].count("ASIK") and self.bts_info["wts_hw_type"].count("ASIK") \
                and self.bts_info["ap_port_state"]["13"]:
            self._log_to_file("Airphone DCI port on SEI13 can be up and deploy on GNB and AP", console=True)
            self.fsm_obj.execute_command_on_enb("cd /rom/DCI_link;sed -i 's/eif02/sei13/1' deploy.cfg;",
                                                alias=self.alias)
            self.fsm_obj.execute_command_on_wts("cd /rom/DCI_link;sed -i 's/eif02/sei13/1' deploy.cfg;",
                                                alias=self.alias)
            self._execute_deploy_cmd(self.bts_host, dci_script, "./deploy.sh")
        else:
            self._log_to_file("Installation dci_script on gnb by default DCI port", console=True)
            self._execute_deploy_cmd(self.bts_host, dci_script, "./deploy.sh")
        # install DCI script on AP
        if self.bts_info["bbu_type"].count("ASOE"):
            self.fsm_obj.execute_command_on_wts("cd /rom/DCI_link;sed -i 's/eif02/sei10/1' deploy.cfg;",
                                                alias=self.alias)
            self._log_to_file("Change Airphone DCI port to SEI10 successfully due to ASOE", console=True)

        if self.bts_info["bbu_type"].count("ASIB"):
            self.fsm_obj.execute_command_on_wts("cd /rom/DCI_link;sed -i 's/eif02/sei13/1' deploy.cfg;",
                                                alias=self.alias)
            self._log_to_file("Change Airphone DCI port to SEI13 successfully due to ASIB", console=True)
        if self.bts_info["bbu_type"].count("ASIL") and self.bts_info["wts_hw_type"].count("ASIK") \
                and self.bts_info["ap_port_state"]["13"]:
            self.fsm_obj.execute_command_on_wts("cd /rom/DCI_link;sed -i 's/eif02/sei13/1' deploy.cfg;",
                                                alias=self.alias)
            self._log_to_file("Change Airphone DCI port to SEI13 successfully due to ASIL", console=True)
        if self.bts_info["bbu_type"].count("ASIL") and self.bts_info["wts_hw_type"].count("ASIK") \
                and self.bts_info["ap_port_state"]["10"]:
            self.fsm_obj.execute_command_on_wts("cd /rom/DCI_link;sed -i 's/eif02/sei10/1' deploy.cfg;",
                                                alias=self.alias)
            self._log_to_file("Change Airphone DCI port to SEI10 successfully due to ASIL", console=True)
        if self.bts_info["wts_hw_type"].count("ASIL"):
            self.fsm_obj.execute_command_on_wts(
                r"mkdir -p /ffs/run/config/envdata/bts-config/0/mcu-fctp", alias=self.alias)
            self.fsm_obj.execute_command_on_wts(
                r"echo 1 > /ffs/run/config/envdata/bts-config/0/mcu-fctp/board-config.txt", alias=self.alias)
            self.fsm_obj.execute_command_on_wts(
                r"crasign /ffs/run/config/envdata/bts-config/0/mcu-fctp/board-config.txt", alias=self.alias)
            self.fsm_obj.execute_command_on_wts(
                r"mkdir -p /ffs/run/config/envdata/bts-config/1/mcu-aspd", alias=self.alias)
            self.fsm_obj.execute_command_on_wts(
                r"echo 5403 > /ffs/run/config/envdata/bts-config/1/mcu-aspd/board-config.txt", alias=self.alias)
            self.fsm_obj.execute_command_on_wts(
                r"crasign /ffs/run/config/envdata/bts-config/1/mcu-aspd/board-config.txt", alias=self.alias)
            self._log_to_file("Skip install DCI script on Airphone because its hardware is ASIL", console=True)
            return
        self._log_to_file("Install DCI script on AP")
        self._execute_deploy_cmd(self.ap, dci_script, "./deploy.sh")

    def _get_position_in_rack(self):
        try:
            obj = self.ute_im_obj.get_infomodel_object("//SMOD_L-1/CONCENTRATOR_L-1", timeout=5, alias=self.alias)
        except Exception as e:
            self._log_to_file("Get rack position failure, error info %s" % e, level="ERROR")
            raise Exception("Get rack position failure , need check informodel library status")
        if obj.positionInRack.lower().count("right"):
            self.bts_info["position"] = "right"
        elif obj.positionInRack.lower().count("left"):
            self.bts_info["position"] = "left"
        else:
            self.bts_info["position"] = "wholeShelf"

    def _enable_l1bypass_test_mode(self, target_gnb):
        self._log_to_file("Starting to enable l1bypass test mode on GNB")
        if target_gnb == "gnb1":
            # ap version>4.0.19037 start to use 0x574,0x584,0x594 instead of 0x524A,0x534A,0x544
            self._enable_l1bypass_test_mode_on_asoe()
            self._enable_l1bypass_test_mode_on_asik()
            self._enable_l1bypass_test_mode_on_asib()
            self._enable_l1bypass_test_mode_on_asil()
        else:
            self._enable_l1bypass_test_mode_on_asib_gnb2()
        out = self._execute_command_on_aashell("tag -3r app.btsom.nts.L1BypassMap")
        if out.count("Configuration tag read failed"):
            self._log_to_file("Fail to enable l1bypass test node", level="ERROR")
            raise Exception("Fail to enable l1bypass test node")
        else:
            self._log_to_file(out.strip())

    def _enable_l1bypass_test_mode_on_asoe(self):
        if self.bts_info["bbu_type"].count("ASOE"):
            self._execute_command_on_aashell("tag -3w app.btsom.nts.L1BypassMap 0x104D:0x574A,0x105D:0x584A")
            self._log_to_file("Enable l1bypass test mode on ASOE")

    def _enable_l1bypass_test_mode_on_asik(self):
        if self.bts_info["bbu_type"].count("ASIK") \
                and self.bts_info["position"].count("left") and "ABIL" in self.bts_info["gnb_fsp_types"]:
            self._execute_command_on_aashell("tag -3w app.btsom.nts.L1BypassMap 0x125D:0x574A,0x135D:0x584A")
            self._log_to_file("Enable l1bypass test mode on ASIK ABIL Left Rack")
        if self.bts_info["bbu_type"].count("ASIK") \
                and self.bts_info["position"].count("right") and "ABIL" in self.bts_info["gnb_fsp_types"]:
            self._execute_command_on_aashell("tag -3w app.btsom.nts.L1BypassMap 0x225D:0x574A,0x235D:0x584A")
            self._log_to_file("Enable l1bypass test mode on ASIK ABIL Right Rack")

    def _enable_l1bypass_test_mode_on_asib(self):
        # enable l1bypass on ASIB ABIO Left
        if self.bts_info["bbu_type"].count("ASIB") and \
                self.bts_info["position"].count("left") and "ABIO" in self.bts_info["gnb_fsp_types"]:
            cmd = "tag -3w app.btsom.nts.L1BypassMap 0x124D:0x574A,0x125D:0x584A,0x134D:0x594A"
            self._execute_command_on_aashell(cmd)
            self._log_to_file("Enable l1bypass test mode on ASIB ABIO Left Rack")

        # enable l1bypass on ASIB ABIO Right
        if self.bts_info["bbu_type"].count("ASIB") and \
                self.bts_info["position"].count("right") and "ABIO" in self.bts_info["gnb_fsp_types"]:
            cmd = "tag -3w app.btsom.nts.L1BypassMap 0x224D:0x574A,0x225D:0x584A,0x234D:0x594A"
            self._execute_command_on_aashell(cmd)
            self._log_to_file("Enable l1bypass test mode on ASIB ABIO Right Rack")

        # enable l1bypass on ASIB ABIL Left
        if self.bts_info["bbu_type"].count("ASIB") and \
                self.bts_info["position"].count("left") and "ABIL" in self.bts_info["gnb_fsp_types"]:
            cmd = "tag -3w app.btsom.nts.L1BypassMap 0x125D:0x574A,0x135D:0x584A,0x145D:0x594"
            self._execute_command_on_aashell(cmd)
            self._log_to_file("Enable l1bypass test mode on ASIB ABIO Left Rack")

        # enable l1bypass on ASIB ABIL Right
        if self.bts_info["bbu_type"].count("ASIB") and \
                self.bts_info["position"].count("right") and "ABIL" in self.bts_info["gnb_fsp_types"]:
            cmd = "tag -3w app.btsom.nts.L1BypassMap 0x225D:0x574A,0x235D:0x584A,0x245D:0x594A"
            self._execute_command_on_aashell(cmd)
            self._log_to_file("Enable l1bypass test mode on ASIB ABIO Right Rack")

    def _enable_l1bypass_test_mode_on_asib_gnb2(self):
        # enable l1bypass on ASIB ABIO Right
        if self.bts_info["bbu_type"].count("ASIB") and \
                self.bts_info["position"].count("right") and "ABIO" in self.bts_info["gnb_fsp_types"]:
            cmd = "tag -3w app.btsom.nts.L1BypassMap 0x224D:0x584A,0x225D:0x594A"
            self._execute_command_on_aashell(cmd)
            self._log_to_file("Enable l1bypass test mode on ASIB ABIO Right Rack")

    def _enable_l1bypass_test_mode_on_asil(self):
        if self.bts_info["bbu_type"].count("ASIL") and self.bts_info["position"].count("left"):
            self._execute_command_on_aashell("tag -3w app.btsom.nts.L1BypassMap 0x124D:0x574A,0x134D:0x584A")
            self._log_to_file("Enable l1bypass test mode on ASIL Left Rack")

        if self.bts_info["bbu_type"].count("ASIL") and self.bts_info["position"].count("right"):
            self._execute_command_on_aashell("tag -3w app.btsom.nts.L1BypassMap 0x224D:0x574A,0x234D:0x584A")
            self._log_to_file("Enable l1bypass test mode on ASIL Right Rack")

    def _disable_l1bypass_test_mode(self):
        self._log_to_file("Disable l1bypass test mode on GNB")
        self._execute_command_on_aashell("tag -fd app.btsom.nts.L1BypassMap")
        self._execute_command_on_aashell("tag -3r app.btsom.nts.L1BypassMap")

    def _wait_restart(self, ip):
        self.fsm_obj.wait_until_host_is_unavailable(ip, timeout=60, alias=self.alias)
        self.fsm_obj.wait_until_host_is_available(ip, timeout=180, alias=self.alias)

    def _download_yaft(self):
        self._setup_sw_update()
        self._execute_command("rm -rf /home/ute/BTS_T_YAFT")
        self._log_to_file("Begin to checkout BTS_T_YAFT")
        check_cmd = "svn co https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk " \
                    "/home/ute/BTS_T_YAFT --username ca_ute_test --password utetest"
        cmd_out = self._execute_command(check_cmd, "30")
        cmd_rc = self._execute_command("echo $?")
        if int(cmd_rc) != 0:
            self._log_to_file("svn checkout yaft failure, "
                              "output is :{},{}".format(cmd_out, cmd_rc), level="ERROR")
            self._log_to_file("Switch to git clone yaft")
            check_cmd = "git clone ssh://gerrit.ext.net.nokia.com:29418/MN/RPSW/LFS/build/yaft " \
                        "/home/ute/BTS_T_YAFT"
            cmd_out = self._execute_command(check_cmd, "30")
            cmd_rc = self._execute_command("echo $?")
            if int(cmd_rc) != 0:
                raise Exception("can not git clone and svn checkout YAFT tool, "
                                "pls checkout it with your account. Command is: %s" % check_cmd)
        self._log_to_file("download yaft success")

    def _update_with_yaft(self, sw_build, type):
        self._download_yaft()
        self._log_to_file("Updating %s..." % type)
        if type == "GNB":
            ip = self.bts_host
        else:
            ip = self.ap
        self._log_to_file("Check %s host is available, if ping is unsuccessful, then exit." % type)
        self.fsm_obj.wait_until_host_is_available(ip, timeout=150, alias=self.alias)
        self._log_to_file("You can follow the last log under /home/ute/BTS_T_YAFT/log to check the progress")
        cmd = "cd /home/ute/BTS_T_YAFT; echo oZPS0POrRieRtu | python yaft.py -i %s -z %s --ask_for_password \
        --clean_to_default" % (ip, sw_build)
        self._log_to_file(cmd, console=False)
        rc = os.system(cmd)
        self.fsm_obj.wait_until_host_is_available(ip, timeout=180, alias=self.alias)
        # classical gnb and ap no need to cold reset.
        # self._cold_reset_equipment(type=type, ip=ip)
        # self.fsm_obj.wait_until_host_is_available(ip, timeout=300, alias=self.alias)

    def _update_ap(self, ap_build):
        if ap_build == "latest":
            ap_build = self._get_latest_ap_build(r"SBTS00")
        elif ap_build == "latest_SBTS00":
            ap_build = self._get_latest_ap_build(r"SBTS00")
        elif ap_build == "latest_SBTS22R1":
            ap_build = self._get_latest_ap_build(r"SBTS22R1")
        elif ap_build == "latest_SBTS22R2":
            ap_build = self._get_latest_ap_build(r"SBTS22R2")

        target_dir = self._download_sw_build(ap_build, "AP")
        ap_build_file = self._execute_command("ls %s/*.zip" % target_dir)
        self._update_with_yaft(ap_build_file, "AP")
        self._clean_files_on_ap()
        wts_sw = self.fsm_obj.get_wts_sw_version(alias=self.alias)
        self._log_to_file("Current AP version is %s" % wts_sw)
        self._log_to_file("Relinking the matched esimmode to latest directory")
        esimmode = self._execute_command("ls %s/esimmode*.bz2" % target_dir)
        if len(esimmode):
            self._execute_command("rm -rf %s/esimmode; mkdir -p %s/esimmode" % (target_dir, target_dir), timeout="30")
            self._execute_command("cd %s;tar -jxvf %s -C %s/esimmode" % (target_dir, esimmode, target_dir), "60")
            self._execute_command("rm -rf /opt/iphy/latest")
            self._execute_command("ln -s %s/esimmode /opt/iphy/latest" % target_dir)
            self._execute_command("chmod +x /opt/iphy/latest/*")
            self._execute_command("sudo pkill edaemon")
            self._execute_command("sudo pkill egate")
        return ap_build

    def _check_status(self, gnb_build, ap_build):
        if gnb_build is not None:
            print(self.fsm_obj.execute_command_on_enb(
                "export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -n 0x1011",
                alias=self.alias))
            print(self.fsm_obj.execute_command_on_enb(
                "export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -n 0x2011",
                alias=self.alias))
        if ap_build is not None:
            print(self.fsm_obj.execute_command_on_wts(
                "export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -n 0x5011",
                alias=self.alias))
            print(self.fsm_obj.execute_command_on_wts(
                "export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -n 0x6011",
                alias=self.alias))

    def _clean_files_on_gnb(self):
        files = ["/ffs/fs*/config/fallbackCause.txt",
                 "/ffs/fs*/config/Role.txt",
                 "/ffs/fs*/config/SCFC_*.xml",
                 "/ffs/fs*/config/model_*.ims2",
                 "/ffs/fs*/config/NCF.xml",
                 "/ffs/fs*/config/hwf.bin.gz",
                 "/ffs/fs*/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf"]
        for file in files:
            try:
                self.fsm_obj.execute_command_on_enb("rm -rf %s" % file, alias=self.alias)
            except Exception:
                pass

    def _clean_files_on_ap(self):
        files = ["/ffs/fs*/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf"]
        for file in files:
            try:
                self.fsm_obj.execute_command_on_wts("rm -rf %s" % file, alias=self.alias)
            except Exception:
                pass

    def _get_latest_gnb_build(self, stream_build):
        url = 'http://files.ute.nsn-rdnet.net/builds/enb/base/'
        index_path = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_3/tools/sw_update"
        index_html = os.path.join(index_path, 'index.html')
        if os.path.exists(index_html):
            os.remove(index_html)
        cmd = "wget -nv --no-directories --no-check-certificate --no-parent --no-cache --no-proxy {} -P {}"\
            .format(url, index_path)
        result = self._execute_command(cmd)
        if not result:
            raise AssertionError(
                'wget ulr {} failed'.format(
                    self.ute_build_url))
        with open(index_html) as f:
            index_content = f.read()
        stream_build = stream_build + '_ENB_'
        stream_build_pattern = re.compile(r'.*">({}.*)/</a>.*'.format(stream_build))
        builds = stream_build_pattern.findall(index_content)

        # get latest build both have "Manifest.ini" and "_A54.zip"
        latest_gnb_build = builds[-1]
        os.remove(index_html)
        Manifest_file = url + latest_gnb_build + "/Manifest.ini"
        cmd = "wget -nv --no-directories --no-check-certificate --no-parent --no-cache --no-proxy {} -P {}"\
            .format(Manifest_file, index_path)
        result = self._execute_command(cmd)

        if os.path.exists(index_path + "/Manifest.ini"):
            os.remove(index_path + "/Manifest.ini")
            return latest_gnb_build
        else:
            latest_gnb_build = builds[-2]
            return latest_gnb_build

    def _get_latest_ap_build(self, stream_build):
        index_path = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_3/tools/sw_update"
        index_html = os.path.join(index_path, 'Manifest.ini')
        if os.path.exists(index_html):
            os.remove(index_html)

        manifest_url = 'http://files.ute.nsn-rdnet.net/builds/enb/base/' + \
                       self._get_latest_gnb_build(stream_build) + '/Manifest.ini'
        cmd = "wget -nv --no-directories --no-check-certificate --no-parent --no-cache --no-proxy {} -P {}"\
            .format(manifest_url, index_path)
        result = self._execute_command(cmd)
        print(cmd)
        if not result:
            raise AssertionError(
                'wget ulr {} failed'.format(
                    self.ute_build_url))

        with open(index_html) as f:
            index_content = f.read()

        # 'version': '5G_4.0.19328'}]}
        regex = re.compile(r'5G_.*?}]}')
        #  print(regex.findall(index_content))  # find all "5G_4.0.19328'}]}"
        latest_ap_build = regex.findall(index_content)[0]
        latest_ap_build = latest_ap_build.split("5G_")[1].split("'}]}")[0]

        os.remove(index_html)
        return latest_ap_build

    def _update_gnb(self, gnb_build):
        if gnb_build == "latest_SBTS00":
            gnb_build = self._get_latest_gnb_build(r"SBTS00")
        elif gnb_build == "latest_SBTS22R1":
            gnb_build = self._get_latest_gnb_build(r"SBTS22R1")
        elif gnb_build == "latest_SBTS22R2":
            gnb_build = self._get_latest_gnb_build(r"SBTS22R2")

        target_dir = self._download_sw_build(gnb_build, "GNB")
        gnb_build_file = self._execute_command("ls %s/*.zip | grep -i release_BTSSM_downloadable" % target_dir)
        self._update_with_yaft(gnb_build_file, "GNB")
        self._clean_files_on_gnb()
        return gnb_build

    def _get_bbu_type(self, type):
        self._setup_sw_update()
        cmd = "cat /proc/device-tree/module-identity/unit-id"
        if type == "ap":
            wts_type = self.fsm_obj.execute_command_on_wts(cmd, alias=self.alias)
            self.bts_info["wts_hw_type"] = re.compile('\x00').sub("", wts_type)
        if type == "gnb":
            gnb_type = self.fsm_obj.execute_command_on_enb(cmd, alias=self.alias)
            self.bts_info["bbu_type"] = re.compile('\x00').sub("", gnb_type)

    def _get_gnb_fsp_types(self):
        # return gnb fsp boards type such as [u'ABIO', u'ABIL', None]
        self._setup_sw_update()
        self.bts_info["gnb_fsp_types"] = []
        for board_number in range(1, 4):
            cmd = "bsh {}:0 cat /proc/device-tree/module-identity/unit-id".format(board_number)
            try:
                ret = self.fsm_obj.execute_command_on_enb(cmd, alias=self.alias)
                board_type = re.compile('\x00').sub("", ret)
                self.bts_info["gnb_fsp_types"].append(board_type)
            except Exception:
                self.bts_info["gnb_fsp_types"].append("None")

    def _get_ap_port_state(self, port):
        self._setup_sw_update()
        try:
            out = self.fsm_obj.execute_command_on_wts("dbgrrc show port %s" % port, alias=self.alias)
            self._log_to_file("Check Airphone port %s state" % port, console=True)
            self._log_to_file(out, console=True)
            ret = re.search(r"%s\s+up\s+up" % port, out, re.I)
            if ret:
                return True
            else:
                return False
        except Exception:
            self._log_to_file("Get ap port %s state exception" % port, console=True, level="WARN")
            return False

    def _collect_ap_sei_port_state(self):
        self.bts_info["ap_port_state"] = {}
        self.bts_info["ap_port_state"]["15"] = self._get_ap_port_state(15)
        self.bts_info["ap_port_state"]["13"] = self._get_ap_port_state(13)
        self.bts_info["ap_port_state"]["10"] = self._get_ap_port_state(10)

    def _collect_sys_info(self):
        self._get_testline_config()
        self.vm_memory_size = self._get_vm_space("/home/ute")
        self._get_bbu_type('gnb')
        self._get_gnb_fsp_types()
        self._get_position_in_rack()
        self._get_bbu_type('ap')
        self._log_to_file("Gnb bbu type is %s" % self.bts_info["bbu_type"], console=True)
        self._log_to_file("Gnb gnb fsp types are {}".format(self.bts_info["gnb_fsp_types"]), console=True)
        self._log_to_file("Gnb rack position is {}".format(self.bts_info["position"]), console=True)
        self._log_to_file("Airphone bbu type is %s" % self.bts_info["wts_hw_type"], console=True)
        self._collect_ap_sei_port_state()

    def _retry_function_on_specific_times(self, func_name, retry_times, interval_time, return_flag=True, **kwargs):
        # perform function on specific times , if fails ,delay certain interval time until retry_times reaches.
        # retrun_flag is to provide return value or not
        for retry_time in range(1, retry_times + 1):
            try:
                if return_flag:
                    return_value = func_name(**kwargs)
                else:
                    func_name(**kwargs)
            except Exception:
                if retry_time == retry_times:
                    self._log_to_file(
                        "Max Retry Times Reaches, Sysytem Exit Due to {} Function Perform Failure".format(func_name),
                        console=True, level="ERROR")
                    sys.exit(-1)
                self._log_to_file("Function {} Work Failure,Retry {} After {} Seconds".format(func_name, retry_time,
                                                                                              int(interval_time)),
                                  console=True, level="WARN")
                time.sleep(int(interval_time))
                continue
            if return_flag:
                return return_value
            else:
                return

    def install_gnb_tti_dec_file(self, file_path):
        self._setup_sw_update()
        output_log_path = "/home/ute/tti_dec_install.log"
        cmd = "sudo dpkg -i %s 1>%s 2>&1" % (file_path, output_log_path)
        try:
            self._execute_command(cmd, timeout='120')
            self._file_should_contain_strings(output_log_path, "Successfully installed")
        except Exception:
            self._log_to_file("Tti Dec File: %s Install Failure after 120s timeout.please use command: %s"
                              "Check by yourself," % (file_path, cmd), console=True, level="ERROR")
        else:
            self._log_to_file("Tti-Dec Install Success.", console=True)
            self._execute_command("chmod +x /opt/tti-dec/tti-dec-bin/bin/eventDecoder")

    def install_gnb_tti_dissectors_file(self, file_path):
        self._setup_sw_update()
        # delete tti_dissectors folder
        self._execute_command("sudo rm -rf /opt/tti_dissectors")
        if os.path.exists("/opt/tti_dissectors"):
            self._log_to_file("Tti_dissectors folder delete failure.", console=True, level="ERROR")
            return
        self._execute_command("sudo mkdir -p /opt/tti_dissectors && sudo chown ute /opt/tti_dissectors")
        if not os.path.exists("/opt/tti_dissectors"):
            self._log_to_file("Tti_dissectors folder creation failure.", console=True, level="ERROR")
            return
        out = self._execute_command("unzip -q -o -d /opt/tti_dissectors %s" % file_path)
        if out:
            self._log_to_file("Unzip tti_dissectors failure.reason: %s" % out, console=True, level="ERROR")
        else:
            self._log_to_file("Unzip tti_dissectors Success", console=True, level="INFO")

    def _file_should_contain_strings(self, file_with_path, *string):
        if not os.path.isfile(file_with_path):
            raise Exception("file does not exist or it is not a file: %s" % file_with_path)
        for each in string:
            count = self._check_string_in_file(file_with_path, each)
            if count is False:
                raise Exception("no %s in %s" % (each, file_with_path))

    def _check_string_in_file(self, file_with_path, string):
        self._setup_sw_update()
        if string.count("'"):
            command = '''grep -i "%s" "%s"''' % (string, file_with_path)
        else:
            command = "grep -i '''%s''' '%s'" % (string, file_with_path)
        self._execute_command(command)
        out2 = self._execute_command("echo $?")
        if out2 == "0":
            return True
        else:
            return False

    def download_gnb_tti_dec_file(self, sw_build):
        tti_dec_file_postfix = "tti-dec.deb"
        return self.download_gnb_accessory_file(tti_dec_file_postfix, sw_build)

    def download_gnb_tti_dissectors_file(self, sw_build):
        tti_dissectors_file_postfix = "tti-dissectors.zip"
        return self.download_gnb_accessory_file(tti_dissectors_file_postfix, sw_build)

    def download_gnb_accessory_file(self, file_postfix, sw_build):
        max_try_times = 2
        self._setup_sw_update()
        if sw_build.count("_9999_"):
            sw_build = "SBTS00_" + sw_build.partition("_")[-1]
        target_dir = "/home/ute/%s_%s" % ("GNB", sw_build)
        ret = self._execute_command("ls %s/*_%s" % (target_dir, file_postfix))
        if ret.count("No such file or directory") == 0:
            self._log_to_file("Existing GNB file :%s , no need to download" % ret)
            return target_dir

        # test download path
        find_flag = False
        download_paths = []
        download_timeout = "1200"
        download_paths.append("%s/%s/%s_%s"
                              % (self.download_server_gnb_s3, sw_build.split("_")[0], sw_build, file_postfix))
        download_paths.append("%s/%s/%s_%s"
                              % (self.download_server_gnb_ute, sw_build, sw_build, file_postfix))
        download_paths.append("%s/%s/%s_%s"
                              % (self.download_server_gnb_hz1, sw_build, sw_build, file_postfix))

        for path in download_paths:
            rc = os.system("wget --tries 1 -T 5 --spider %s" % path)
            if int(rc) == 0:
                find_flag = True
                download_path = path
                break
        if find_flag is False:
            raise Exception("can not get %s, pls manually download it to %s." % (download_paths, target_dir))
        self._check_available_download_space(download_path=download_path, target_dir="/home/ute")
        # download Accessory File
        while (max_try_times > 0):
            try:
                self._log_to_file("Downloading GNB file: %s..." % (download_path.split("/")[-1]))
                cmd = "wget -c %s -P %s" % (download_path, target_dir)
                self._log_to_file(cmd)
                rc = os.system(cmd)
                out = self._execute_command("ls -l %s/*" % target_dir)
                self._log_to_file(out, console=False)
                break
            except Exception:
                detail = traceback.format_exc()
                self._log_to_file(detail, console=False)
                self._log_to_file("Downloading GNB file: %s failed", (download_path.split("/")[-1]))
                self._execute_command("rm -rf %s" % target_dir, "300")
                max_try_times = max_try_times - 1
        if max_try_times == 0:
            raise Exception("downloading Gnb file failed, pls manually download it to %s and rerun this script"
                            % (target_dir))
        return target_dir

    def update_tti_plugin(self, gnb_build):
        try:
            # download gnb tti-dec file
            tti_dec_file_folder = self.download_gnb_tti_dec_file(gnb_build)
            # download gnb tti dissectors file
            tti_dissectors_file_folder = self.download_gnb_tti_dissectors_file(gnb_build)
            # install gnb tti dec file
            self.install_gnb_tti_dec_file(
                r"%s/%s_tti-dec.deb" % (tti_dec_file_folder, gnb_build))
            # install gnb tti dissectors file
            self.install_gnb_tti_dissectors_file(
                r"%s/%s_tti-dissectors.zip" % (tti_dissectors_file_folder, gnb_build))
        except Exception:
            details = traceback.format_exc()
            self._log_to_file("Tti install failure:{}".format(details), console=False, level="ERROR")
            self._log_to_file("Tti plugin install failure and skip all tti install steps.", level="ERROR")

    def _cold_reset_equipment(self, type, ip):
        try:
            if self.tl:
                self._log_to_file("{} pdu info exists and start cold reset {}".format(type, type))
                self._power_off("{}".format(type))
                # check restart
                self._wait_equipment_disconnect(ip=ip, timeout=60)
                self._power_on("{}".format(type))
        except Exception:
            details = traceback.format_exc()
            self._log_to_file("Cold reset {} failure, err is {}".format(type, details), level="WARN")
        else:
            self._log_to_file("Cold reset {} success.".format(type))

    def sw_update(self, gnb_build, ap_build, test_mode, target_gnb):
        self._setup_sw_update()
        starttime = datetime.datetime.now()
        self._set_ip_to_connect_ap()
        self._collect_sys_info()
        self._execute_command("rm -rf /home/ute/BTS_T_YAFT/YAFT_IMAGE/*", timeout="300")
        if ap_build is not None:
            self.confirmed_ap_version = self._update_ap(ap_build)
        if gnb_build is not None:
            self.confirmed_gnb_version = self._update_gnb(gnb_build)
            self.update_tti_plugin(self.confirmed_gnb_version)
        if gnb_build is not None:
            self._log_to_file("Start to setup gnb admin, disable port security and enable ssh")
            self.admin_obj.teardown_admin(alias=self.alias)
            self.admin_obj.setup_admin(alias=self.alias, bts_port=self.bts_port, use_ssl=self.use_ssl,
                                       bts_host=self.bts_host, timeout=600)
            self.admin_obj.disable_ethernet_port_security(alias=self.alias)
            self.admin_obj.enable_ssh_access(alias=self.alias)
            self._log_to_file("Gnb admin setup success")
        self._install_DCI_link()
        if test_mode == "l1bypass":
            self._enable_l1bypass_test_mode(target_gnb)
        elif test_mode == "fs":
            self._disable_l1bypass_test_mode()
        endtime = datetime.datetime.now()
        time_elapse = (endtime - starttime).seconds
        self._log_to_file("SW update takes %s minutes" % (time_elapse // 60))


if __name__ == "__main__":
    if len(sys.argv) == 1 or len(sys.argv) % 2 == 0:
        """
        cmd:
        <PATH> = /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_3/tools/sw_update/sw_update.py
        python <PATH> -g SBTS00_ENB_9999_210414_000008 -a 4.0.16400 -t l1bypass
        python <PATH> -g latest_SBTS00 -t l1bypass
        python <PATH> -a latest
        """
        print("Usages: python %s -g <GNB BUILD or PATH> -a <AP BUILD or PATH> -t <l1bypss/fs> [-s <gnb1/gnb2>]"
              % sys.argv[0])
        print("Example 1: update GNB only with l1bypass")
        print("   python %s -g SBTS00_ENB_9999_210414_000008 -t l1bypass" % sys.argv[0])
        print("Example 2: update GNB only with fs")
        print("   python %s -g SBTS00_ENB_9999_210414_000008 -t fs" % (sys.argv[0]))
        print("Example 3: update AP only")
        print("   python %s -a 4.0.16400" % sys.argv[0])
        print("Example 4: update GNB and AP with l1bypss")
        print("   python %s -g SBTS00_ENB_9999_210414_000008 -a 4.0.16400 -t l1bypass" % sys.argv[0])
        print("Example 5: update GNB and AP with fs")
        print("   python %s -g SBTS00_ENB_9999_210414_000008 -a 4.0.16400 -t fs" % sys.argv[0])
        print("Example 6: update with knife")
        print("   python %s -g http://knife-results.es-si-s3-z2.eecloud.nsn-net.net/"
              "499203/SBTS00_ENB_9999_210414_000008.zip -t l1bypass" % sys.argv[0])
        print("Example 7: update the second gnb on 2GNB testline")
        print("   python %s -g SBTS00_ENB_9999_210414_000008 -a 4.0.16400 -t l1bypass -s gnb2" % sys.argv[0])
    else:
        command_options = " ".join(sys.argv[1:])

        # 1. get ap_build from screen input
        ret = re.search(r"-a (\S+)", command_options, re.I)
        if ret:
            ap_build = ret.group(1)
        else:
            ap_build = None

        # 2. get gnb_build from screen input
        ret = re.search(r"-g (\S+)", command_options, re.I)
        if ret:
            gnb_build = ret.group(1)
        else:
            gnb_build = None

        # 3. get test_mode from screen input
        ret = re.search(r"-t (\S+)", command_options, re.I)
        if ret:
            test_mode = ret.group(1).lower()
            if test_mode != "l1bypass" and test_mode != "fs":
                raise Exception("-t only support l1bypass or fs")
        else:
            test_mode = None

        # 4. get target gnb from screen input
        ret = re.search(r"-s (\S+)", command_options, re.I)
        if ret:
            target_gnb = ret.group(1).lower()
            if target_gnb != "gnb1" and target_gnb != "gnb2":
                raise Exception("-s only support gnb1 or gnb2")
        else:
            target_gnb = "gnb1"

        if gnb_build is not None and test_mode is None:
            raise Exception("you must specify test_mode with -t <l1bypass|fs>")
        update_obj = sw_update()

        with update_obj as f:
            update_obj.sw_update(gnb_build, ap_build, test_mode, target_gnb)
