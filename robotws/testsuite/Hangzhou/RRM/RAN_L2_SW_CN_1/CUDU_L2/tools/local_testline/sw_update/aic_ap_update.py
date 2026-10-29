# -*- coding:utf-8 -*-
# Author: Zhang Yin
import os
import sys
import time
import datetime
import re
import platform
import traceback
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
        self.confirmed_gnb_version = ""
        self.confirmed_ap_version = ""
        self.download_server_gnb_s3 = "http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build"
        self.download_server_gnb_ute = "http://files.ute.nsn-rdnet.net/builds/enb/base/"
        self.download_server_gnb_hz1 = \
            "http://artifactory-hz1.int.net.nokia.com/artifactory/ute-files-remote-cache/builds/enb/base/"
        self.download_server_ap = "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone"
        # for config init
        self.tl = ""
        self.tl2 = ""
        self.configuration_name = ""
        self.target_dir = "/home/ute/testline_init_results/configs"
        self.target_dir_second = "/home/ute/testline_configuration"

    def _setup_sw_update(self):
        if not self._setup_sw_update_flag:
            self._setup_sw_update_flag = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_wts_fsm_access(alias=self.alias, fallback_prompt="#", host="192.168.200.1")
            self.ssh_obj = ta_ssh_telnet()
            self.pc_conn = self.ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute", conn_type="SSH", timeout="10")

    def __enter__(self):
        pass

    def __exit__(self, exc_type, exc_val, exc_tb):
        try:
            self.fsm_obj.teardown_wts_fsm_access(alias=self.alias)
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

    def _download_sw_build(self, sw_build, type):
        max_try_times = 2
        self._setup_sw_update()
        # no need to download if build already under /home/ute
        if sw_build.count("http"):
            target_dir = "/home/ute/%s_%s" % (type, sw_build.strip("/").split("/")[-1])
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
                download_paths.append("%s/%s/%s_release_BTSSM_downloadable_A54.zip"
                                      % (self.download_server_gnb_s3, sw_build.split("_")[0], sw_build))
                download_paths.append("%s/%s/%s_release_BTSSM_downloadable.zip"
                                      % (self.download_server_gnb_ute, sw_build, sw_build))
                download_paths.append("%s/%s/%s_release_BTSSM_downloadable.zip"
                                      % (self.download_server_gnb_hz1, sw_build, sw_build))
            elif type == "AP":
                download_timeout = "300"
                download_paths.append("%s/%s/AirScale-%s.zip" % (self.download_server_ap, sw_build, sw_build))
            else:
                raise Exception("not support %s" % type)
        for path in download_paths:
            rc = os.system("wget --spider %s" % path)
            if int(rc) == 0:
                find_flag = True
                download_path = path
                break
        if find_flag is False:
            raise Exception("can't get %s, pls manually download it to %s and rerun this script"
                            % (download_paths, target_dir))
        # download SW build
        while (max_try_times > 0):
            try:
                self._log_to_file("Downloading %s build: %s..." % (type, download_path.split("/")[-1]))
                cmd = "wget %s -P %s" % (download_path, target_dir)
                self._log_to_file(cmd)
                rc = os.system(cmd)
                out = self._execute_command("ls -l %s/*.zip" % target_dir)
                self._log_to_file(out, console=False)
                break
            except Exception:
                detail = traceback.format_exc()
                self._log_to_file(detail, console=False)
                self._log_to_file("Downloading %s build failed" % type, level="WARN")
                self._execute_command("rm -rf %s" % target_dir, "300")
                max_try_times = max_try_times - 1
        if max_try_times == 0:
            raise Exception("downloading %s build failed, pls manually download it to %s and rerun this script"
                            % (type, target_dir))

        # download esimode for AP
        if type == "AP":
            self._log_to_file("Downloading esimmode...")
            download_path_e = download_path.rpartition("/")[0]
            cmd = "wget -r -l1 -nd -nv --no-parent -A sandybridge.tar.bz2  %s -P %s" % (download_path_e, target_dir)
            rc = os.system(cmd)
        return target_dir

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
        try:
            if os.path.isdir("/home/ute") is False:
                raise Exception("work folder is not on /home/ute")
            else:
                self._get_configuration()
                self._set_configuration()
        except Exception:
            details = traceback.format_exc()
            self._log_to_file("Get local config module failure, err is :{}".format(details), level="ERROR")

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
            source_dir = "%s/../../resources_aic/configuration_file/variable_files" % curdir
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

    def _get_position_in_rack(self):
        try:
            obj = self.ute_im_obj.get_infomodel_object("//SMOD_L-1/CONCENTRATOR_L-1", timeout=5, alias=self.alias)
        except Exception as e:
            raise Exception("Get rack position failure , need check informodel library status")
            self._log_to_file("Get rack position failure, error info %s" % e)
            exit()
        if obj.positionInRack.lower().count("right"):
            self.bts_info["position"] = "right"
        elif obj.positionInRack.lower().count("left"):
            self.bts_info["position"] = "left"
        else:
            self.bts_info["position"] = "wholeShelf"

    def _wait_restart(self, ip):
        self.fsm_obj.wait_until_host_is_unavailable(ip, timeout=60, alias=self.alias)
        self.fsm_obj.wait_until_host_is_available(ip, timeout=180, alias=self.alias)

    def _download_yaft(self):
        self._setup_sw_update()
        hostname = self._execute_command("hostname")
        if hostname.count("UTE") == 0 and hostname.count("CLOUD") == 0:
            if not os.path.exists("/home/ute/BTS_T_YAFT"):
                raise Exception(
                    "No /home/ute/BTS_T_YAFT, "
                    "pls checkout https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk"
                    "and move it to /home/ute/BTS_T_YAFT")
        if not os.path.exists("/home/ute/BTS_T_YAFT"):
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
                    raise Exception("can't git clone and svn checkout YAFT tool, "
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
        self._cold_reset_equipment(type=type, ip=ip)
        self.fsm_obj.wait_until_host_is_available(ip, timeout=300, alias=self.alias)

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

    def _clean_files_on_ap(self):
        files = ["/ffs/fs*/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf"]
        for file in files:
            try:
                self.fsm_obj.execute_command_on_wts("rm -rf %s" % file, alias=self.alias)
            except Exception:
                pass

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

    def _get_bbu_type(self, type):
        self._setup_sw_update()
        cmd = "cat /proc/device-tree/module-identity/unit-id"
        if type == "ap":
            wts_type = self.fsm_obj.execute_command_on_wts(cmd, alias=self.alias)
            self.bts_info["wts_hw_type"] = re.compile('\x00').sub("", wts_type)
        if type == "gnb":
            gnb_type = self.fsm_obj.execute_command_on_enb(cmd, alias=self.alias)
            self.bts_info["bbu_type"] = re.compile('\x00').sub("", gnb_type)

    def _collect_sys_info(self):
        self._get_bbu_type('ap')
        self._log_to_file("Airphone bbu type is %s" % self.bts_info["wts_hw_type"], console=True)

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

    def sw_update(self, ap_build):
        self._setup_sw_update()
        starttime = datetime.datetime.now()
        self._get_testline_config()
        self._execute_command("rm -rf /home/ute/BTS_T_YAFT/YAFT_IMAGE/*", timeout="300")
        if ap_build is not None:
            self.confirmed_ap_version = self._update_ap(ap_build)

        endtime = datetime.datetime.now()
        time_elapse = (endtime - starttime).seconds
        print("SW update takes %s minutes" % (time_elapse // 60))


if __name__ == "__main__":
    if len(sys.argv) == 1 or len(sys.argv) % 2 == 0:
        """
        cmd:
        <PATH> = /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_3/tools/sw_update/aic_ap_update.py
        python <PATH> -a 4.0.16400
        python <PATH> -a latest
        """
        print("Usages: python %s -a <AP BUILD or PATH>" % sys.argv[0])
        # print("Notes: for 2 enbs testline, pls execute this script in both control PCs,
        # and the SW update can be ongoing simultaneously.")
        print("Example 1: update AP")
        print("   python %s -a 4.0.16400" % sys.argv[0])
        print("Example 2: update the latest AP")
        print("   python %s -a latest" % sys.argv[0])
    else:
        command_options = " ".join(sys.argv[1:])

        # 1. get ap_build from screen input
        ret = re.search(r"-a (\S+)", command_options, re.I)
        if ret:
            ap_build = ret.group(1)
        else:
            ap_build = None

        if not ap_build:
            raise Exception("you must specify ap build with -a")

        update_obj = sw_update()

        with update_obj as f:
            update_obj.sw_update(ap_build)
