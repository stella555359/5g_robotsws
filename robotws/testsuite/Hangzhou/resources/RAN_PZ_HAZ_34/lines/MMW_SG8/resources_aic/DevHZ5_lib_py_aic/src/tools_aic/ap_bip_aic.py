import os
import time

from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from ute_fsmaccess import ute_fsmaccess
from ..common_lib_aic import common_lib_aic
from ..cm_aic_cluster import cm_iphy
from ..cm_aic_cluster import cm_aic

os_obj = OperatingSystem()
builtin_obj = BuiltIn()
comm_obj = common_lib_aic()


class ap_bip_aic_base(object):
    def __init__(self, alias):
        self._setup_ap_bip_flag = False
        self.alias = alias
        self.remote_host = None
        self.ap_bip_shell_script_path = os.path.join(os.path.dirname(__file__), "apMirroring")

    def _setup_ap_bip(self):
        if not self._setup_ap_bip_flag:
            self._setup_ap_bip_flag = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_wts_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#")
            self.cm_iphy_obj = cm_iphy()
            self.cm_aic_obj = cm_aic()

    def __del__(self):
        if self._setup_ap_bip_flag:
            self.fsm_obj.teardown_all_aliases_for_wts_fsmaccess()

    def _check_ap_process_exist(self, ap_bip_name, fct_type="fct-0a"):
        # check if shell script is started successfully
        retry_times = 10
        while retry_times > 0:
            if fct_type == "fct-0a":
                result = comm_obj.execute_cmd_on_wts("ps aux|grep '{}' | grep -v -w grep".format(ap_bip_name))
            elif fct_type == "fct-0b":
                result = comm_obj.execute_cmd_on_wts("bsh 0:1 ps aux|grep '{}' | grep -v -w grep".format(ap_bip_name))
            if ap_bip_name not in result:
                time.sleep(2)
                retry_times = retry_times - 1
            else:
                break
        if retry_times == 0:
            raise Exception("Fail to execute ap bip script")

    def _start_ap_bip_log_on_fullstack_by_script(self, ap_bip_name, shell_script="apMirroring"):
        self._setup_ap_bip()

        # put all required ap mirror script to /tmp/apMirror folder"
        temp_apmirror_script_folder = "/tmp/{}_script".format(ap_bip_name)
        os_obj.remove_directory(temp_apmirror_script_folder, recursive=True)
        os_obj.create_directory(temp_apmirror_script_folder)
        source_shell_script_path = os.path.join(self.ap_bip_shell_script_path, "{}.sh".format(shell_script))
        source_config_file = os.path.join(self.ap_bip_shell_script_path, "{}Config.sh".format(shell_script))
        shell_script_with_path = os.path.join(temp_apmirror_script_folder, "{}.sh".format(shell_script))
        config_file = os.path.join(temp_apmirror_script_folder, "{}Config.sh".format(shell_script))
        try:
            os_obj.copy_file(source_shell_script_path, shell_script_with_path)
            os_obj.copy_file(source_config_file, config_file)
            # /opt/wts/latest/sosReport_ASIL/gnbMirroring.py is needed for APoverABIO
            os_obj.copy_file("/opt/wts/latest/sosReport_ASIL/gnbMirroring.py", temp_apmirror_script_folder)
        except Exception:
            pass

        # update ap bip log name in shell script
        builtin_obj.log(
            "step: update ap bip log name from tcpdumpapL2L1 to {} in shell script".format(ap_bip_name))
        comm_obj.replace_string_in_file(shell_script_with_path,
                                        "tcpdumpapL2L1",
                                        ap_bip_name)

        # modify apmirror slot config in config file
        builtin_obj.log("step: modify apmirror slot config in config file")
        self.cm_iphy_obj.modify_apmirror_slot_config(config_file)
        # modify @{PARAMS_IN_APMIRROR} in config file
        builtin_obj.log("step: modify @{PARAMS_IN_APMIRROR} in config file")
        params_in_apmirror = builtin_obj.get_variable_value("${PARAMS_IN_APMIRROR}")
        self.cm_aic_obj.modify_mirror_script_parameters(params_in_apmirror, config_file)

        # upload script and config file to /ffs/run/config/scripts
        builtin_obj.log("step: upload ap mirror script to /ffs/run/config/scripts")
        comm_obj.execute_cmd_on_wts("rm -rf /tmp/ap_bip*")
        comm_obj.execute_cmd_on_wts("rm -rf /ffs/run/config/scripts")
        comm_obj.execute_cmd_on_wts("mkdir -p /ffs/run/config/scripts")
        self.fsm_obj.put_wts_file("{}/*".format(temp_apmirror_script_folder),
                                  "/ffs/run/config/scripts", alias=self.alias)
        comm_obj.execute_cmd_on_wts("chmod 777 /ffs/run/config/scripts/*")

        # execute shell script
        builtin_obj.log("step: execute ap bip script")
        comm_obj.execute_cmd_on_wts("nohup sh /ffs/run/config/scripts/{}.sh > /ffs/run/logs/{}.log 2>&1 &".format(
            shell_script, ap_bip_name))
        # check if shell script is started successfully
        builtin_obj.log("step: check if ap bip script is started successfully")
        self._check_ap_process_exist(ap_bip_name)

    def _start_ap_bip_log_on_l1bypass(self, ap_bip_name):
        self._setup_ap_bip()
        # enable mirror ports
        builtin_obj.log("step: enable mirror ports")
        comm_obj.execute_cmd_on_wts("dbgrrc mirror sport 13 dport 6 e b")
        comm_obj.execute_cmd_on_wts("dbgrrc mirror sport 21 dport 6 e b")
        comm_obj.execute_cmd_on_wts("dbgrrc mirror sport 29 dport 6 e b")
        comm_obj.execute_cmd_on_wts("dbgrrc mirror sport 37 dport 6 e b")
        # execute tcpdump
        builtin_obj.log("step: execute tcpdump")
        comm_obj.execute_cmd_on_wts(
            "nohup bsh 0:1 tcpdump -i pepbp1 -C 2000 -W 3 -w /tmp/{}.pcap -vv 1>/dev/null 2>&1 &".format(
                ap_bip_name))
        # check if shell script is started successfully
        builtin_obj.log("step: check if ap bip script is started successfully")
        self._check_ap_process_exist(ap_bip_name, "fct-0b")

    def start_to_capture_ap_bip_log_aic(self, tag):
        self._setup_ap_bip()
        ap_bip_name = "ap_bip" if 'startup' in tag or len(tag) == 0 else "ap_bip_{}".format(tag)
        ap_bbu_type = builtin_obj.get_variable_value("${AP_BBU_TYPE}")
        l1_type = builtin_obj.get_variable_value("${L1_TYPE}").upper()
        ap_fsp_boards_type = self.cm_iphy_obj.get_ap_fsp_types()
        builtin_obj.set_suite_variable("${AP_FSP_BOARDS_TYPE}", ap_fsp_boards_type)
        builtin_obj.log("l1_type={}, ap_bbu_type={}".format(l1_type, ap_bbu_type))
        if ap_bbu_type == "ASIK" and l1_type == "FS":
            # capture ap bip via apMirroring.sh + apMirroringConfig.sh
            self._start_ap_bip_log_on_fullstack_by_script(ap_bip_name,
                                                          shell_script="apMirroring")
        elif ap_bbu_type == "ASIK" and l1_type == 'L1B':
            self._start_ap_bip_log_on_l1bypass(ap_bip_name)
        elif ap_bbu_type == 'ASIL':
            # capture ap bip via apMirror_On_ASIL_ABIO.sh + /opt/wts/latest/sosReport_ASIL/gnbMirroring.py
            # apMirror_On_ASIL_ABIO.sh comes from
            # https://confluence.ext.net.nokia.com/display/AirPhoneWTS/APoABIO+BIP+Logs+Capture+Using+TAF+Keyword
            # and add tcpdump part
            self._start_ap_bip_log_on_fullstack_by_script(ap_bip_name,
                                                          shell_script="apMirror_On_ASIL_ABIO")
        else:
            builtin_obj.log("don't support to capture AP BIP on such HW, please contact TA core team for help",
                            level="WARN")

    def _stop_ap_bip_log_launched_by_script(self, ap_bip_name, bip_log_dir):
        # stop ap shell script
        builtin_obj.log("step: stop ap bip shell script")
        comm_obj.execute_cmd_on_wts(
            "ps aux | grep '{}' | grep -v -w grep".format(ap_bip_name))
        comm_obj.execute_cmd_on_wts(
            "ps aux | grep '%s' | grep -v -w grep |awk '{print $2}' | xargs kill -9" % ap_bip_name)

        # copy script file to bip_log_dir
        try:
            temp_apmirror_script_folder = "/tmp/{}_script".format(ap_bip_name)
            os_obj.copy_directory(temp_apmirror_script_folder, bip_log_dir)
            os_obj.remove_directory(temp_apmirror_script_folder, recursive=True)
            self.fsm_obj.get_wts_file("/ffs/run/logs/{}.log".format(ap_bip_name), bip_log_dir, alias=self.alias)
        except Exception:
            pass

        # check ap bip logs exist
        builtin_obj.log("step: check ap bip logs exist or not on /tmp/{}*.pcap*".format(ap_bip_name))
        self.verify_ap_bip_log_exist(bip_folder="/tmp", bip_name="{}*.pcap*".format(ap_bip_name))

        # download ap bip logs
        builtin_obj.log("step: download ap bip logs from /tmp/{}*.pcap*".format(ap_bip_name))
        self.fsm_obj.get_wts_file("/tmp/{}*.pcap*".format(ap_bip_name),
                                  bip_log_dir,
                                  alias=self.alias)
        comm_obj.execute_cmd_on_wts("rm -rf /tmp/{}*.pcap*".format(ap_bip_name))

    def _stop_ap_bip_log_on_l1bypass(self, ap_bip_name, bip_log_dir):
        # disable mirror ports
        builtin_obj.log("step: disable mirror ports")
        comm_obj.execute_cmd_on_wts("dbgrrc mirror sport 13 dport 6 d b")
        comm_obj.execute_cmd_on_wts("dbgrrc mirror sport 21 dport 6 d b")
        comm_obj.execute_cmd_on_wts("dbgrrc mirror sport 29 dport 6 d b")
        comm_obj.execute_cmd_on_wts("dbgrrc mirror sport 37 dport 6 d b")

        # stop gnb shell script
        builtin_obj.log("step: stop ap bip")
        comm_obj.execute_cmd_on_wts(
            "ps aux | grep '{}' | grep -v -w grep".format(ap_bip_name))
        comm_obj.execute_cmd_on_wts(
            "ps aux | grep '%s' | grep -v -w grep |awk '{print $2}' | xargs kill -9" % ap_bip_name)

        # move gnb bip logs from backup board to main board
        builtin_obj.log("step: move gnb bip logs from backup board to main board")
        comm_obj.execute_cmd_on_wts("bsh 0:1 ls -ltr /tmp/{}*.pcap*".format(ap_bip_name))
        for number in range(0, 3):
            comm_obj.execute_cmd_on_wts("bget 0:1 /tmp/{}.pcap{} /tmp".format(ap_bip_name, number))
        comm_obj.execute_cmd_on_wts("bsh 0:1 rm -rf /tmp/{}*.pcap*".format(ap_bip_name))

        # check ap bip logs exist
        builtin_obj.log("step: check ap bip logs exist or not on /tmp/{}*.pcap*".format(ap_bip_name))
        self.verify_ap_bip_log_exist(bip_folder="/tmp", bip_name="{}*.pcap*".format(ap_bip_name))

        # download gnb bip logs
        builtin_obj.log("step: download ap bip logs from /tmp/{}*.pcap*".format(ap_bip_name))
        self.fsm_obj.get_wts_file("/tmp/{}*.pcap*".format(ap_bip_name),
                                  bip_log_dir,
                                  alias=self.alias)
        comm_obj.execute_cmd_on_wts("rm -rf /tmp/{}*.pcap*".format(ap_bip_name))

    def stop_to_capture_ap_bip_log_aic(self, tag):
        self._setup_ap_bip()
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        bip_log_dir = "{}/{}_logs/ap_bip_logs/".format(save_log_dir, tag) \
            if 'startup' in tag else "{}/ap_bip_logs/".format(save_log_dir)
        ap_bip_name = "ap_bip" if 'startup' in tag or len(tag) == 0 else "ap_bip_{}".format(tag)
        comm_obj.execute_cmd_on_pc("mkdir -p {}".format(bip_log_dir))

        ap_bbu_type = builtin_obj.get_variable_value("${AP_BBU_TYPE}")
        l1_type = builtin_obj.get_variable_value("${L1_TYPE}").upper()
        if ap_bbu_type == "ASIK" and l1_type == "FS":
            self._stop_ap_bip_log_launched_by_script(ap_bip_name, bip_log_dir)
        elif ap_bbu_type == "ASIK" and l1_type == 'L1B':
            self._stop_ap_bip_log_on_l1bypass(ap_bip_name, bip_log_dir)
        elif ap_bbu_type == 'ASIL':
            self._stop_ap_bip_log_launched_by_script(ap_bip_name, bip_log_dir)

    def verify_ap_bip_log_exist(self, bip_folder, bip_name, timeout=30):
        retry_times = int(timeout) / 10
        self._setup_ap_bip()
        while retry_times >= 0:
            out1 = comm_obj.execute_cmd_on_wts("find {} -name {}".format(bip_folder, bip_name))
            out2 = comm_obj.execute_cmd_on_wts("echo $?")
            if out1 and str(out2) == "0":
                return True
            else:
                retry_times = retry_times - 1
                time.sleep(10)
        builtin_obj.log("failure to find ap bip log file for {}", level="WARN")
        raise Exception("failure to find ap bip log file for {}".format(bip_name))


class ap_bip_aic_gnb1(object):

    def __init__(self):
        alias = "gnb1"
        self.ap_bip_aic_base_instance_1 = ap_bip_aic_base(alias)

    def start_to_capture_ap_bip_log_aic(self, tag=''):
        self.ap_bip_aic_base_instance_1.start_to_capture_ap_bip_log_aic(tag)

    def stop_to_capture_ap_bip_log_aic(self, tag=''):
        self.ap_bip_aic_base_instance_1.stop_to_capture_ap_bip_log_aic(tag)


class ap_bip_aic(ap_bip_aic_gnb1):
    def __init__(self):
        ap_bip_aic_gnb1.__init__(self)


if __name__ == "__main__":
    ap_bip_obj = ap_bip_aic()
    help(ap_bip_obj)
