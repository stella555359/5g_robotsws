# -*- coding:utf-8 -*-

import os
import sys
import time
import datetime
import re
import traceback

try:
    from robot.libraries.BuiltIn import BuiltIn
    from robot.libraries.OperatingSystem import OperatingSystem
except ModuleNotFoundError as e:
    print("[\033[31m ERROR \033[0m ] please switch to virtual env and execute this script, "
          "input 'robot' command , 'source /home/ute/test_repo/bin/activate' or install library. {}".format(e))
    exit()
from taf.sbts.oam.coam.admin import admin as ute_admin
from ute_fsmaccess import ute_fsmaccess
from ute_admin_infomodel import ute_admin_infomodel

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


class sw_update_local(object):
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
        self.ssh_obj = ta_ssh_telnet()
        self.fsm_obj = ute_fsmaccess()
        self.admin_obj = ute_admin()
        self.ute_im_obj = ute_admin_infomodel()

    def _setup_sw_update(self):
        if not self._setup_sw_update_flag:
            try:
                self._setup_sw_update_flag = True
                self.fsm_obj = ute_fsmaccess()
                self.fsm_obj.setup_wts_fsm_access(alias=self.alias, fallback_prompt="#", host="192.168.200.1")
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
        self._log_to_file("Current available space on folder {} is {}G".format(path, int(int(out) / 1024 / 1024)))
        return int(out)

    def _check_available_download_space(self, download_path, target_dir):
        self._setup_sw_update()
        out = self._execute_command("wget --http-user=ncommon --http-password=ba+v3Zxj --spider "
                                    "--tries 3 -T 20 {}".format(download_path))
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
        self._setup_sw_update()
        self._log_to_file("Check aria2 download method support or not")
        out = self._execute_command("aria2c -h")
        out_status = self._execute_command("echo $?")
        if int(out_status) == 0:
            self._log_to_file("aria2 download support")
            return True
        else:
            self._log_to_file("aria2 download not support, you can use command 'sudo apt install aria2' to install.")
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
            rc = os.system("wget --http-user=ncommon --http-password=ba+v3Zxj --spider --tries 3 -T 20 %s" % path)
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
                    print("download_path=" + download_path)
                    if "/mnp5g-airphone-ci-gen-local/Airphone/" in download_path:
                        cmd = "aria2c -x 4 -s 4 --check-integrity=true --file-allocation=none " \
                              "--http-user=ncommon --http-passwd=ba+v3Zxj " \
                              "-d %s %s --console-log-level error" % (target_dir, download_path)
                    else:
                        cmd = "aria2c -x 4 -s 4 --check-integrity=true --file-allocation=none " \
                              "-d %s %s --console-log-level error" % (target_dir, download_path)
                else:
                    cmd = "wget --http-user=ncommon --http-password=ba+v3Zxj -c" \
                          " %s -P %s" % (download_path, target_dir)
                self._log_to_file(cmd)
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
            cmd = "wget --http-user=ncommon --http-password=ba+v3Zxj -r -l1 -nd -nv --no-parent -A " \
                  "sandybridge.tar.bz2  %s -P %s" % (download_path_e, target_dir)
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

    def _download_yaft(self):
        # give a initial value for cmd_out and flag to record svn download issue
        cmd_out = None
        svn_yaft_download_failure_flag = False

        self._setup_sw_update()
        self._log_to_file("Begin to checkout BTS_T_YAFT")
        check_cmds = ["svn co https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk "
                      "/home/ute/BTS_T_YAFT --username ca_ute_test --password utetest",
                      "git clone ssh://gerrit-mn-essl1.int.net.nokia.com:29418/MN/RPSW/LFS/build/yaft "
                      "/home/ute/BTS_T_YAFT",
                      "git clone ssh://gerrit-hzsl2.int.net.nokia.com:29418/MN/RPSW/LFS/build/yaft "
                      "/home/ute/BTS_T_YAFT"]
        fail_times = 0
        for cmd in check_cmds:
            try:
                self._execute_command("rm -rf /home/ute/BTS_T_YAFT")
                cmd_out = self._execute_command(cmd, "60")
                break
            except Exception:
                # download timeout and set flag to true
                fail_times += 1
                continue
        if fail_times == len(check_cmds):
            svn_yaft_download_failure_flag = True

        cmd_rc = self._execute_command("echo $?")

        if int(cmd_rc) != 0 or svn_yaft_download_failure_flag:
            self._log_to_file("svn checkout yaft failure, "
                              "output is :{},{}".format(cmd_out, cmd_rc), level="ERROR")
            self._log_to_file("Switch to git clone yaft")
            svn_yaft_download_failure_flag = False
            check_cmd = "git clone ssh://gerrit.ext.net.nokia.com:29418/MN/RPSW/LFS/build/yaft " \
                        "/home/ute/BTS_T_YAFT"
            try:
                self._execute_command("rm -rf /home/ute/BTS_T_YAFT")
                cmd_out = self._execute_command(check_cmd, "60")
            except Exception:
                svn_yaft_download_failure_flag = True
            cmd_rc = self._execute_command("echo $?")
            if int(cmd_rc) != 0 or svn_yaft_download_failure_flag:
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
            if not os.path.exists("/opt/wts") or not os.path.isdir("/opt/wts"):
                self._execute_command("sudo mkdir -p /opt/wts")
            self._execute_command("sudo rm -rf /opt/wts/latest")
            self._execute_command("sudo ln -s %s/esimmode /opt/wts/latest" % target_dir)
            self._execute_command("sudo chmod +x /opt/wts/latest/*")
            self._execute_command("sudo pkill edaemon")
            self._execute_command("sudo pkill egate")
        return ap_build

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
        cmd = "wget -nv --no-directories --no-check-certificate --no-parent --no-cache --no-proxy {} -P {}" \
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
        cmd = "wget -nv --no-directories --no-check-certificate --no-parent --no-cache --no-proxy {} -P {}" \
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
        cmd = "wget -nv --no-directories --no-check-certificate --no-parent --no-cache --no-proxy {} -P {}" \
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

    def sw_update(self, ap_build):
        self._setup_sw_update()
        starttime = datetime.datetime.now()
        self._set_ip_to_connect_ap()
        self._execute_command("rm -rf /home/ute/BTS_T_YAFT/YAFT_IMAGE/*", timeout="300")
        if ap_build is not None:
            self.confirmed_ap_version = self._update_ap(ap_build)
        endtime = datetime.datetime.now()
        time_elapse = (endtime - starttime).seconds
        self._log_to_file("SW update takes %s minutes" % (time_elapse // 60))
        self._execute_command("ln -sfn /opt/wts/latest /opt/iphy/latest", timeout="300")


if __name__ == "__main__":
    command_options = " ".join(sys.argv[1:])
    # Extract ap_build from command-line arguments
    ret = re.search(r"-a (\S+)", command_options, re.I)
    if ret:
        ap_build = ret.group(1)
    else:
        ap_build = None

    print(f"ap Build: {ap_build}")
    update_obj = sw_update_local()
    with update_obj as f:
        update_obj.sw_update(ap_build)
