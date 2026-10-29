import os
import re
from collections import OrderedDict
from robot.libraries.BuiltIn import BuiltIn
from ute_fsmaccess import ute_fsmaccess
from taf.collectors.ttitrace_snapshot_airphone.interface import ttitrace_snapshot_airphone
from taf.collectors.core import core

builtin_obj = BuiltIn()


class ap_ttitrace_base(object):
    def __init__(self, alias):
        self.alias = alias
        self.ap_address = "192.168.200.1"
        self.ap_user = "toor4nsn"
        self.ap_password = "oZPS0POrRieRtu"

        self.ap_info = OrderedDict()
        self.ap_info["act"] = OrderedDict()
        self.ap_info["act"]["ip"] = self.ap_address
        self.ap_info["act"]["user"] = self.ap_user
        self.ap_info["act"]["password"] = self.ap_password

        self.ap_info["asp"] = OrderedDict()

        self.ssh_to_ap()

    def __del__(self):
        self.fsm_obj.teardown_all_aliases_for_wts_fsmaccess()

    def ssh_to_ap(self):
        self.fsm_obj = ute_fsmaccess()
        self.fsm_obj.setup_wts_fsm_access(host=self.ap_address,
                                          user=self.ap_user,
                                          password=self.ap_password,
                                          port=22,
                                          timeout=20.0,
                                          prompt=' >',
                                          remote_host=None,
                                          retry_timeout=60.0,
                                          fallback_prompt="#",
                                          alias=self.alias)
        return self.fsm_obj

    def collect_ap_info(self):
        ret = self.fsm_obj.execute_command_on_wts("cat /proc/device-tree/module-identity/unit-id",
                                                  return_rc=False,
                                                  alias=self.alias)
        act_board_type = re.compile('\x00').sub("", ret)
        self.ap_info["act"]["board_type"] = act_board_type

        for asp_board_number in range(1, 4):
            try:
                cmd = "bsh {}:0 cat /proc/device-tree/module-identity/unit-id".format(asp_board_number)
                ret = self.fsm_obj.execute_command_on_wts(cmd, return_rc=False, alias=self.alias)
                asp_board_type = re.compile('\x00').sub("", ret)

                ret = self.fsm_obj.execute_command_on_wts("bsh %d:0 lxc-ls" % asp_board_number,
                                                          return_rc=False,
                                                          alias=self.alias)

                lxc_container_name = ret.split("\n")[-1]

                cmd = "bsh %d:0 lxc-info -n %s" % (asp_board_number, lxc_container_name)
                ret = self.fsm_obj.execute_command_on_wts(cmd, return_rc=False, alias=self.alias)
                asp_board_ip = re.search(r"IP:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\n", ret).group(1)

                self.ap_info["asp"]["%d:0" % asp_board_number] = OrderedDict()
                self.ap_info["asp"]["%d:0" % asp_board_number]["board_slot"] = str(asp_board_number)
                self.ap_info["asp"]["%d:0" % asp_board_number]["board_type"] = asp_board_type
                self.ap_info["asp"]["%d:0" % asp_board_number]["board_ip"] = asp_board_ip
                self.ap_info["asp"]["%d:0" % asp_board_number]["board_lxc_container"] = lxc_container_name
                self.ap_info["asp"]["%d:0" % asp_board_number]["user"] = self.ap_user
                self.ap_info["asp"]["%d:0" % asp_board_number]["password"] = self.ap_password
            except Exception as e:
                pass
        return self.ap_info

    def create_and_setup_ap_ttitrace_snapshot(self, tag=""):
        self.snapshot_obj = ttitrace_snapshot_airphone()
        builtin_obj.log("[AP TTITRACE] Create ttitrace_snapshot_airphone object: %s" % self.snapshot_obj,
                        level="INFO",
                        console=False)

        self.collector_names = []
        for k, v in self.ap_info["asp"].items():
            ttitrace_proxy = {"host": self.ap_info["act"]["ip"],
                              "user": self.ap_info["act"]["user"],
                              "password": self.ap_info["act"]["password"]}

            if "startup" in tag or len(tag) == 0:
                ttitrace_name = "asp_slot%s_%s_ttitrace" % (v["board_slot"], v["board_type"])
            else:
                ttitrace_name = "asp_slot%s_%s_ttitrace_%s" % (v["board_slot"], v["board_type"], tag)

            ttitrace_executor = {"host": v["board_ip"],
                                 "user": v["user"],
                                 "password": v["password"],
                                 "proxy": ttitrace_proxy}

            ttitrace_script = "/opt/tools/airphone/eventsTraceCollector/eventsCollect.sh"
            ttitrace_container = v["board_lxc_container"]
            ttitrace_log_dir = "/var/eventsTrace"

            ret = self.snapshot_obj.create_ttitrace_snapshot_airphone_collector(name=ttitrace_name,
                                                                                executor=ttitrace_executor,
                                                                                container=ttitrace_container,
                                                                                script_path=None,
                                                                                log_dir=None,
                                                                                target_file_name=None,
                                                                                start_timeout=None,
                                                                                stop_timeout=None)
            self.collector_names.append(ttitrace_name)
            builtin_obj.log("[AP TTITRACE]  create_ttitrace_snapshot_airphone_collector[%s] "
                            "by snapshot_obj[%s] return[%s]" % (ttitrace_name, self.snapshot_obj, ret),
                            level="INFO",
                            console=False)
        self.collector_names_str = ",".join(self.collector_names)

        ret = self.snapshot_obj.setup_collectors(names=self.collector_names_str)
        builtin_obj.log("[AP TTITRACE] setup_collectors[%s] by snapshot_obj[%s] "
                        "return[%s]" % (self.collector_names_str, self.snapshot_obj, ret),
                        level="INFO",
                        console=False)

    def start_ap_ttitrace(self, tag):
        self.collect_ap_info()

        self.abio_startup_flag = False
        if "startup" in tag:
            for k, v in self.ap_info["asp"].items():
                if v["board_type"] == "ABIO":
                    builtin_obj.log("[AP TTITRACE] Start UP & asp board_type is ABIO", level="INFO", console=False)
                    self.abio_startup_flag = True
                    return

        builtin_obj.log("[AP TTITRACE] Collect AP Info: %s" % self.ap_info, level="INFO", console=False)

        self.create_and_setup_ap_ttitrace_snapshot(tag)

        ret = self.snapshot_obj.start_collectors(names=self.collector_names_str)
        builtin_obj.log("[AP TTITRACE] start_collectors[%s] by snapshot_obj[%s] "
                        "return [%s]" % (self.collector_names_str, self.snapshot_obj, ret),
                        level="INFO",
                        console=False)

        for i in self.collector_names:
            builtin_obj.set_global_variable("${collectors::%s}" % i)

    def stop_ap_ttitrace(self, tag=""):
        if "startup" in tag:
            if self.abio_startup_flag is True:
                return
            else:
                ttitrace_log_path = os.path.join(builtin_obj.get_variable_value("${SAVE_LOG_DIRECTORY}"),
                                                 "%s_logs" % tag)
        else:
            ttitrace_log_path = builtin_obj.get_variable_value("${SAVE_LOG_DIRECTORY}")
        ttitrace_log_path = os.path.join(ttitrace_log_path, "ap_ttitrace_log")
        if not os.path.exists(ttitrace_log_path):
            os.mkdir(ttitrace_log_path)

        ret = self.snapshot_obj.stop_collectors(names=self.collector_names_str)
        builtin_obj.log("[AP TTITRACE] stop_collectors[%s] by snapshot_obj[%s] "
                        "return[%s]" % (self.collector_names_str, self.snapshot_obj, ret),
                        level="INFO",
                        console=False)

        ret = self.snapshot_obj.collect_collectors(names=self.collector_names_str, target_dir=ttitrace_log_path)
        builtin_obj.log("[AP TTITRACE] collect_collectors[%s, %s] by snapsjot_obj[%s], "
                        "return[%s]" % (self.collector_names_str, ttitrace_log_path, self.snapshot_obj, ret),
                        level="INFO",
                        console=False)

        ret = self.snapshot_obj.teardown_collectors(names=self.collector_names_str)
        builtin_obj.log("[AP TTITRACE] teardown_collectors[%s] by snapshot-obj[%s] "
                        "return[%s]" % (self.collector_names_str, self.snapshot_obj, ret),
                        level="INFO",
                        console=False)


class ap_ttitrace_gnb1(object):
    def __init__(self):
        alias = "gnb1"
        self.ap_ttitrace_base_instance_1 = ap_ttitrace_base(alias)

    def start_to_capture_ap_ttitrace_log(self, tag=""):
        self.ap_ttitrace_base_instance_1.start_ap_ttitrace(tag)

    def stop_to_capture_ap_ttitrace_log(self, tag=""):
        self.ap_ttitrace_base_instance_1.stop_ap_ttitrace(tag)


class ap_ttitrace(ap_ttitrace_gnb1):
    def __init__(self):
        ap_ttitrace_gnb1.__init__(self)


if __name__ == "__main__":
    ap_ttitrace_obj = ap_ttitrace()
    help(ap_ttitrace_obj)
