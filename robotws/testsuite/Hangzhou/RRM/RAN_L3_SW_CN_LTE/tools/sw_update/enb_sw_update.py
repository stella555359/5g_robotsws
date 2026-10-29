# -*- coding:utf-8 -*-
# Author: Zhang Yin
import os
import sys
import time
import datetime
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from ute_admin import ute_admin
from ute_fsmaccess import ute_fsmaccess
from ute_admin_infomodel import ute_admin_infomodel
import traceback

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
ssh_obj = ta_ssh_telnet()
downloader = Downloader()

debug_log = "/home/ute/update.log"
os_obj.remove_file(debug_log)

support, may_support, not_support = 0, 1, 2


class sw_update(object):
    def __init__(self):
        self.enb_build_file = ""
        self.alias = "enb"
        self.bts_host = "192.168.255.129"
        self._setup_sw_update_flag = False
        self.bts_port = "443"
        self.use_ssl = True

    def _setup_sw_update(self):
        if not self._setup_sw_update_flag:
            self._setup_sw_update_flag = True
            self.admin_obj = ute_admin()
            self.admin_obj.setup_admin(alias=self.alias, bts_port=self.bts_port, use_ssl=self.use_ssl,
                                       bts_host=self.bts_host)
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(alias=self.alias, fallback_prompt="#", host=self.bts_host)
            self.ute_im_obj = ute_admin_infomodel()
            self.ute_im_obj.setup_infomodel(port=self.bts_port, use_ssl=self.use_ssl, alias=self.alias,
                                            address=self.bts_host)
            self.ute_im_obj.connect_infomodel(alias=self.alias)
            self.pc_conn = ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute", conn_type="SSH", timeout="10")

    def __del__(self):
        if self._setup_sw_update_flag:
            self.admin_obj.teardown_admin(alias=self.alias)
            self.fsm_obj.teardown_enb_fsm_access(alias=self.alias)
            self.ute_im_obj.disconnect_infomodel(alias=self.alias)
            self.ute_im_obj.teardown_infomodel(alias=self.alias)

    def _log_to_file(self, log, console=True, level="INFO"):
        current_time = builtin_obj.get_time()
        log = "[ %s ] %s  %s" % (level, current_time, log)
        if console:
            print(log)
        if not os.path.exists(debug_log):
            self._execute_command("touch %s" % debug_log)
        try:
            self._execute_command("echo '%s' >> %s" % (log, debug_log))
        except Exception:
            pass

    def _execute_command(self, cmd, timeout="10"):
        ssh_obj.switch_host_connection(self.pc_conn)
        ssh_obj.set_shell_timeout(int(timeout))
        out = ssh_obj.execute_shell_command(cmd)
        return out

    def _download_sw_build(self, sw_build):
        """This keyword is to download enb sw build
        | Input Parameters | Man. | Description |
        | sw_build  | Yes   | sw build name or path |

        for example
        | 1 | download_sw_build | SBTS00_ENB_9999_200810_000010 |
        | 2 | download_sw_build | http://knife-results.es-si-s3-z2.eecloud.nsn-net.net
        /499203/SBTS00_ENB_9999_200507_499203_release_BTSSM_downloadable_A54.zip |
        """
        max_try_times = 2
        self._setup_sw_update()
        # no need to download if build already under /home/ute
        out = self._execute_command("ls /home/ute/%s*" % sw_build.split("/")[-1])
        if out.count("No such file or directory") == 0:
            self.enb_build_file = out.split()[0]
            self.new_build = self.enb_build_file.split("/")[-1].split("_release")[0]
            self._log_to_file("Existing SW build: %s, no need to download" % self.enb_build_file)
            return

        # try to download
        if sw_build.count("http"):
            download_path = sw_build
            out = self._execute_command("wget --spider %s" % download_path)
            if out.count("Remote file does not exist"):
                raise Exception("%s is inaccessible, pls manually download it to /home/ute and rerun this script"
                                % download_path)
        else:
            file_server = "http://files.ute.nsn-rdnet.net/builds/enb/base"
            s3_server = "http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build"
            if sw_build.count("ENB_9999"):
                sw_build = "SBTS00_" + sw_build.partition("_")[-1]
            download_path = "%s/%s/%s_release_BTSSM_downloadable.zip" % (file_server, sw_build, sw_build)
            out = self._execute_command("wget --spider %s" % download_path)
            if out.count("Remote file does not exist"):
                download_path = "%s/%s/%s_release_BTSSM_downloadable_A54.zip" % (s3_server, sw_build.split("_")[0],
                                                                                 sw_build)
                out = self._execute_command("wget --spider %s" % download_path)
                if out.count("Remote file does not exist"):
                    raise Exception("can't find %s from %s and %s, pls manually download it to /home/ute and rerun "
                                    "this script" % (sw_build, file_server, s3_server))

        self.enb_build_file = "/home/ute/%s" % download_path.split("/")[-1]
        self.new_build = self.enb_build_file.split("/")[-1].split("_release")[0]
        while (max_try_times > 0):
            try:
                self._log_to_file("downloading SW build: %s..." % download_path.split("/")[-1])
                self._log_to_file("wget %s -P /home/ute" % download_path)
                downloader.execute_wget(download_path, self.enb_build_file)
                out = self._execute_command("ls -l SBTS*")
                self._log_to_file(out, console=False)
                self._log_to_file("downloading SW build suceeds")
                break
            except Exception:
                detail = traceback.format_exc()
                self._log_to_file(detail, console=False)
                self._log_to_file("downloading SW build failed")
                self._execute_command("rm -rf %s" % self.enb_build_file, "60")
                max_try_times = max_try_times - 1
        if max_try_times == 0:
            raise Exception("downloading SW build failed, pls manually download it to /home/ute and rerun this script")

    def _check_sw_update_path(self):
        """
        check SW update path supported or not, return True or False accordingly
        """
        self._setup_sw_update()
        self.old_build = self.fsm_obj.get_enb_sw_version(alias=self.alias)
        self._log_to_file("current_build is %s" % self.old_build)
        self.new_build = self.enb_build_file.split("/")[-1].split("_release")[0]
        if self.old_build.count("ENB_9999"):
            self.old_build = "SBTS00_" + self.old_build.partition("_")[-1]
        rel_o = self.old_build.partition("_")[0]
        rel_n = self.new_build.partition("_")[0]
        if rel_o == rel_n:  # same release
            if self.new_build >= self.old_build:
                result = support
            else:
                gap = int(self.old_build.split("_")[3]) - int(self.new_build.split("_")[3])
                # TRUNK build < 7 days, branch build < 20, maybe it can update directly
                if self.new_build.count("SBTS00") and gap < 7 or self.new_build.count("SBTS00") == 0 and gap < 20:
                    result = may_support
                else:
                    result = not_support

        elif rel_n == "SBTS00":  # branch-> trunk
            result = support
        elif rel_o == "SBTS00":  # trunk -> branch
            result = not_support
        elif rel_n > rel_o:
            result = support
        else:
            result = not_support
        return result

    def _wait_expected_state(self, expected_state):
        self._log_to_file("wait eNB enter into %s state" % expected_state)
        try:
            self.ute_im_obj.query_infomodel("//MRBTS_M-* is [stateInfo.proceduralState=%s]" % expected_state,
                                            timeout=600, alias=self.alias)
            self._log_to_file("current state is %s" % (expected_state))
            current_state = expected_state
        except Exception:
            detail = traceback.format_exc()
            self._log_to_file(detail, console=False)
            try:
                current_state = self.admin_obj.get_mrbts_state(alias=self.alias)
                self._log_to_file("fail to enter %s state, current state is %s" % (expected_state, current_state))
            except Exception:
                current_state = None
                detail = traceback.format_exc()
                self._log_to_file(detail, console=False)
                self._log_to_file("fail to enter %s state, current state is unknown" % (expected_state))
        return current_state

    def _decide_target_state(self):
        # decide target state after sw update
        self._setup_sw_update()
        current_state = self.admin_obj.get_mrbts_state(alias=self.alias)
        if current_state == "NotCommissioned":
            self.admin_obj.disable_ethernet_port_security(alias=self.alias)
            self.admin_obj.enable_ssh_access(alias=self.alias)
        self._log_to_file("current_state=%s" % current_state)
        if current_state == "NotCommissioned" or current_state == "Commissioned":
            self.target_state = current_state
        else:
            self.target_state = "Configured"

    def _configuration_reset(self):
        self._setup_sw_update()
        if self.target_state == "NotCommissioned":
            return
        self._log_to_file("Executing Configuration Reset...")
        self.admin_obj.reset_configuration(False, False, alias=self.alias)
        self.target_state = "NotCommissioned"
        # reduce sw update failed ratio
        self.admin_obj.teardown_admin(self.alias)
        self.admin_obj.setup_admin(alias=self.alias, bts_port=self.bts_port, use_ssl=self.use_ssl,
                                   bts_host=self.bts_host)
        time.sleep(30)

    def _update_enb_build(self):
        self._setup_sw_update()
        try:
            self._log_to_file("Updating SW Build: %s" % self.enb_build_file)
            self.admin_obj.update_software(self.enb_build_file, timeout="1200", alias=self.alias)
            self._log_to_file("Updating SW Build succeeds")
            time.sleep(30)
        except Exception:
            detail = traceback.format_exc()
            self._log_to_file("fail to update SW build: %s" % detail, console=False)
            self._log_to_file("Updating SW Build failed")
            raise Exception(detail)

    def _wait_bts_reach_target_state(self):
        self._setup_sw_update()
        current_state = self._wait_expected_state(self.target_state)
        if current_state == "NotCommissioned":
            self.admin_obj.disable_ethernet_port_security(alias=self.alias)
            self.admin_obj.enable_ssh_access(alias=self.alias)
        current_build = self.fsm_obj.get_enb_sw_version(alias=self.alias)
        self._log_to_file("new build is %s" % current_build)

    def sw_update(self, sw_build):
        starttime = datetime.datetime.now()
        self._download_sw_build(sw_build)
        self._decide_target_state()
        result = self._check_sw_update_path()
        if result == not_support and self.target_state != "NotCommissioned":
            self._log_to_file("SW update from %s to %s not supported" % (self.old_build, self.new_build))
            self._configuration_reset()
        try:
            self._update_enb_build()
        except Exception:
            if result == may_support and self.target_state != "NotCommissioned":
                self._configuration_reset()
            else:
                time.sleep(30)
            self._update_enb_build()
        self._wait_bts_reach_target_state()
        endtime = datetime.datetime.now()
        time_elapse = (endtime - starttime).seconds
        print("SW update takes %s minutes" % (time_elapse / 60))


if __name__ == "__main__":
    if len(sys.argv) == 1 or len(sys.argv) > 2:
        print("Usages: python %s <SW BUILD or PATH>" % sys.argv[0])
        print("Notes: for 2 enbs testline, pls execute this script in both control PCs, and the SW update can be "
              "ongoing simultaneously.")
        print("Examples:")
        print("   python %s SBTS20C_ENB_0000_000209_000000" % sys.argv[0])
        print("   python %s http://knife-results.es-si-s3-z2.eecloud.nsn-net.net/499203/SBTS00_ENB_9999_200507_"
              "499203_release_BTSSM_downloadable_A53.zip" % sys.argv[0])
    else:
        sw_build = sys.argv[1]
        update_obj = sw_update()
        update_obj.sw_update(sw_build)
