import os
import time

from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from ..base_lib.ute_fsmaccess import ute_fsmaccess
from ..common_lib import common_lib
from ..cm import cm
from taf.sbts.oam.coam.admin import admin
import traceback

os_obj = OperatingSystem()
builtin_obj = BuiltIn()
comm_obj = common_lib()


class gnb_bip_base(object):
    def __init__(self, alias):
        self._setup_gnb_bip_flag = False
        self.alias = alias
        self.bts_host = "192.168.255.129"
        self.remote_host = None
        self.gnb_mirror_repository = "https://gitlabe2.ext.net.nokia.com/juhakang/tools.git"
        self.gnb_bip_shell_script_path = os.path.join(os.path.dirname(__file__), "gnbMirroring")
        self.gnb_bip_method = ""

    def _setup_gnb_bip(self):
        if not self._setup_gnb_bip_flag:
            self._setup_gnb_bip_flag = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#",
                                              host="192.168.255.129")
            self.cm_obj = cm()
            self.admin_obj = admin()

        comm_obj.setup_admin_if_alias_not_exist(self.admin_obj, self.alias, self.bts_host, self.remote_host)

    def __del__(self):
        if self._setup_gnb_bip_flag:
            self.fsm_obj.teardown_all_aliases_for_enb_fsmaccess()

    def execute_cmd_on_bts(self, cmd):
        if self.alias == "bts1":
            return comm_obj.execute_cmd_on_bts(cmd)
        else:
            return comm_obj.execute_cmd_on_bts2(cmd)

    def _download_gnbmirror_script(self, shell_script_path):
        """
        This keyword is to download gnbmirror script from gitlab and save on destination folder
        """
        builtin_obj.log("step: download gnbmirror script from {}".format(self.gnb_mirror_repository))
        comm_obj.execute_cmd_on_pc("rm -rf /home/ute/script_folder;mkdir -p /home/ute/script_folder")
        comm_obj.execute_cmd_on_pc("cd /home/ute/script_folder;git clone {}".format(self.gnb_mirror_repository))
        if os.path.exists("/home/ute/script_folder/tools/gnbMirroring/gnbMirroring.sh"):
            comm_obj.execute_cmd_on_pc("rm -rf {}/gulp".format(shell_script_path))
            comm_obj.execute_cmd_on_pc("rm -rf {}/gnbMirroring.sh".format(shell_script_path))
            comm_obj.execute_cmd_on_pc("rm -rf {}/gnbMirroringConfig.sh".format(shell_script_path))
            comm_obj.execute_cmd_on_pc(
                "cp -r /home/ute/script_folder/tools/gnbMirroring/gulp {}".format(shell_script_path))
            comm_obj.execute_cmd_on_pc(
                "cp -r /home/ute/script_folder/tools/gnbMirroring/gnbMirroring.sh {}".format(shell_script_path))
            comm_obj.execute_cmd_on_pc(
                "cp -r /home/ute/script_folder/tools/gnbMirroring/gnbMirroringConfig.sh {}".format(shell_script_path))
            comm_obj.execute_cmd_on_pc("chmod 777 {}/*".format(shell_script_path))
        else:
            builtin_obj.log("step: download fail, use local script")

    def _check_gnb_process_exist(self, gnb_bip_name):
        retry_times = 10
        while retry_times > 0:
            result = self.execute_cmd_on_bts("ps aux|grep '{}' | grep -v -w grep".format(gnb_bip_name))
            if gnb_bip_name not in result:
                time.sleep(2)
                retry_times = retry_times - 1
            else:
                break
        if retry_times == 0:
            raise Exception("Fail to execute gnb bip script")

    def _start_gnb_bip_log_by_script(self, gnb_bip_name, shell_script="gnbMirroring"):
        self._setup_gnb_bip()
        self.gnb_bip_method = "script"

        # put required gnb mirror script to temp folder"
        temp_gnbmirror_script_folder = "/tmp/{}_script".format(gnb_bip_name)
        os_obj.remove_directory(temp_gnbmirror_script_folder, recursive=True)
        os_obj.create_directory(temp_gnbmirror_script_folder)
        source_shell_script_path = os.path.join(self.gnb_bip_shell_script_path, "{}.sh".format(shell_script))
        source_config_file = os.path.join(self.gnb_bip_shell_script_path, "{}Config.sh".format(shell_script))
        shell_script_with_path = os.path.join(temp_gnbmirror_script_folder, "{}.sh".format(shell_script))
        config_file = os.path.join(temp_gnbmirror_script_folder, "{}Config.sh".format(shell_script))
        try:
            os_obj.copy_file(source_shell_script_path, shell_script_with_path)
            os_obj.copy_file(source_config_file, config_file)
        except Exception:
            pass

        # update gnb bip log name in shell script
        builtin_obj.log(
            "step: update gnb bip log name from tcpdump_L2L1_bip to {} in shell script".format(gnb_bip_name))
        comm_obj.replace_string_in_file(shell_script_with_path,
                                        "tcpdump_L2L1_bip",
                                        gnb_bip_name)

        if os.path.exists(config_file):
            # modify gnbmirror slot config in config file
            builtin_obj.log("step: modify gnbmirror slot config in config file")
            if self.alias == "bts1":
                self.cm_obj.modify_gnbmirror_slot_config(config_file)
            else:
                self.cm_obj.modify_gnbmirror_slot_config_bts2(config_file)
            # modify @{PARAMS_IN_GNBMIRROR} in config file
            builtin_obj.log("step: modify @{PARAMS_IN_GNBMIRROR} in config file")
            params_in_gnbmirror = builtin_obj.get_variable_value("${PARAMS_IN_GNBMIRROR}")
            self.cm_obj.modify_mirror_script_parameters(params_in_gnbmirror, config_file)

        # upload script and config file to /ffs/run/config/scripts
        builtin_obj.log("step: upload gnb mirror script to /ffs/run/config/scripts")
        self.execute_cmd_on_bts("rm -rf /tmp/gnb_bip*")
        self.execute_cmd_on_bts("rm -rf /ffs/run/config/scripts")
        self.execute_cmd_on_bts("mkdir -p /ffs/run/config/scripts")
        self.fsm_obj.put_enb_file("{}/*".format(temp_gnbmirror_script_folder),
                                  "/ffs/run/config/scripts", alias=self.alias)
        self.execute_cmd_on_bts("chmod 777 /ffs/run/config/scripts/*")

        # execute shell script
        builtin_obj.log("step: execute gib bip script")
        self.execute_cmd_on_bts("nohup sh /ffs/run/config/scripts/{}.sh > /ffs/run/logs/{}.log 2>&1 &".format(
            shell_script, gnb_bip_name))

        # check if shell script is started successfully
        builtin_obj.log("step: check if gnb bip script is started successfully")
        self._check_gnb_process_exist(gnb_bip_name)

    def _start_gnb_bip_log_by_admin(self, interface):
        self._setup_gnb_bip()
        self.gnb_bip_method = "admin"
        # clean up
        builtin_obj.log("step: stop mirroring and clean up gnb logs under /tmp/CCSPacketCapture")
        try:
            self.admin_obj.interface_mirroring(operation="Stop", connection=self.alias)
        except Exception:
            pass
        self.execute_cmd_on_bts("rm -rf /tmp/CCSPacketCapture/*")

        # start mirroring
        builtin_obj.log("step: start mirroring")
        try:
            self.admin_obj.interface_mirroring(operation="Start", interface=interface,
                                               destination="Local", mirroring_time="0", connection=self.alias)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log("fail to start interface mirroring", level="WARN")
            raise Exception("fail to start interface mirroring: {}".format(detail))

    def _stop_gnb_bip_log_by_admin(self, tag, combine_flag):
        self._setup_gnb_bip()
        # stop mirroring
        builtin_obj.log("step: stop mirroring")
        try:
            self.admin_obj.interface_mirroring(operation="Stop", connection=self.alias)
        except Exception:
            detail = traceback.format_exc()
            raise Exception("fail to stop interface mirroring: {}".format(detail))

        # download mirroring logs from /tmp/CCSPacketCapture/
        # mirroring_L2L1_nac_eth3_20220927T131758Z.pcap
        builtin_obj.log("step: download mirroring logs from /tmp/CCSPacketCapture/")
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        if 'startup' in tag:
            bip_log_dir = "{}/{}_logs/gnb_bip_logs/".format(save_log_dir, tag)
        else:
            bip_log_dir = "{}/gnb_bip_logs/".format(save_log_dir) \
                if len(tag) == 0 else "{}/gnb_bip_logs_{}/".format(save_log_dir, tag)
        comm_obj.execute_cmd_on_pc("rm -rf {}; mkdir -p {}".format(bip_log_dir, bip_log_dir))
        self.execute_cmd_on_bts("ls -ltrh /tmp/CCSPacketCapture")
        out = self.execute_cmd_on_bts("ls /tmp/CCSPacketCapture/*.pcap")
        if out.count("No such file or directory"):
            builtin_obj.log("fail to capture gnb bip logs", level="WARN")
            raise Exception("fail to capture gnb bip logs")
        else:
            builtin_obj.log("gnb bip logs are {}".format(out))
        self.fsm_obj.get_enb_file("/tmp/CCSPacketCapture/*", bip_log_dir, alias=self.alias)

        # combine one file if combine_flag is True
        if combine_flag:
            new_bip_name = "mirroring_{}.pcap".format(out.splitlines()[0].split("_")[1])
            builtin_obj.log("step: combine mirroring_*.pcap to {}".format(new_bip_name))
            comm_obj.execute_cmd_on_pc("mergecap -a -w {}/{} {}/mirroring_*.pcap".format(
                bip_log_dir, new_bip_name, bip_log_dir), timeout=120)
            out2 = comm_obj.execute_cmd_on_pc("ls -ltrh {}/{}".format(bip_log_dir, new_bip_name))
            if out2.count("No such file or directory"):
                builtin_obj.log("fail to merge gnb bip logs", level="WARN")
                raise Exception("fail to merge gnb bip logs")
            else:
                comm_obj.execute_cmd_on_pc("rm -rf {}/mirroring_*_*.pcap".format(bip_log_dir), timeout=120)

    def start_to_capture_gnb_bip_log_bak_script(self, tag):
        """
        capture gnb bip log via script
        1) mirroring by lfs-nw_switch-mirror-tool.sh or dbgnet or dbgnac to interface
        2) tcpdump on the interface
        """
        self._setup_gnb_bip()
        gnb_bip_name = "gnb_bip" if 'startup' in tag or len(tag) == 0 else "gnb_bip_{}".format(tag)
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        l1_type = builtin_obj.get_variable_value("${L1_TYPE}").upper()
        if self.alias == "bts1":
            fsp_boards = self.cm_obj.get_bbmod_type()
        else:
            fsp_boards = self.cm_obj.get_bbmod_type_bts2()
        fsp_boards_str = " ".join(fsp_boards)
        builtin_obj.log("l1_type={}, bbu_type={}, fsp_boards_str={}".format(l1_type, bbu_type, fsp_boards_str))
        if l1_type == "FS" and bbu_type == "ASIL" and 'ABIP' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_ASIL_ABIP_FS")
        elif l1_type == "FS" and bbu_type == "ASIM" and 'ABIO' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_ASIM_ABIO_FS")
        elif l1_type == "FS" and bbu_type != "ASOE" and bbu_type != "ASIM":
            self._download_gnbmirror_script(self.gnb_bip_shell_script_path)
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring")
        elif l1_type == 'L1B' and bbu_type == 'ASIB' and 'ABIL ABIL ABIL' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_On_ASIB_3ABIL_L1bypass")
        elif l1_type == "L1B" and bbu_type == 'ASIB' and 'ABIO' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_ASIB_ABIO")
        elif l1_type == "L1B" and bbu_type == 'ASIL' and 'ABIO' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_On_ASIL_ABIO_L1bypass")
        else:
            builtin_obj.log("don't support to capture GNB BIP on such HW, please contact TA core team for help",
                            level="WARN")

    def start_to_capture_gnb_bip_log_bak_admin(self, tag):
        self._setup_gnb_bip()
        gnb_bip_name = "gnb_bip" if 'startup' in tag or len(tag) == 0 else "gnb_bip_{}".format(tag)
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        l1_type = builtin_obj.get_variable_value("${L1_TYPE}").upper()
        if self.alias == "bts1":
            fsp_boards = self.cm_obj.get_bbmod_type()
        else:
            fsp_boards = self.cm_obj.get_bbmod_type_bts2()
        fsp_boards_str = " ".join(fsp_boards)
        builtin_obj.log("l1_type={}, bbu_type={}, fsp_boards_str={}".format(l1_type, bbu_type, fsp_boards_str))
        if l1_type == "FS" and bbu_type == "ASIL" and 'ABIP' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_ASIL_ABIP_FS")
        elif l1_type == "FS" and bbu_type == "ASIM" and 'ABIO' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_ASIM_ABIO_FS")
        elif l1_type == "FS" and bbu_type != "ASOE" and bbu_type != "ASIM":
            self._start_gnb_bip_log_by_admin("L1-L2")
            # self._start_gnb_bip_log_by_admin("L2Hi-L2Lo")
        elif l1_type == 'L1B':
            self._start_gnb_bip_log_by_admin("L2Hi-L2Lo")  # no message between L1-L2 for l1bypass
        else:
            builtin_obj.log("don't support to capture GNB BIP on such HW, please contact TA core team for help",
                            level="WARN")

    def start_to_capture_gnb_bip_log(self, tag, interface):
        """
        ABIP: dbgnet + tcpdump
        ASIM: dbgnac + tcpdump
        other FS: admin interface mirroring
        l1bypss: lfs-nw_switch-mirror-tool.sh/other command + tcpdump
        """
        self._setup_gnb_bip()
        gnb_bip_name = "gnb_bip" if 'startup' in tag or len(tag) == 0 else "gnb_bip_{}".format(tag)
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        l1_type = builtin_obj.get_variable_value("${L1_TYPE}").upper()
        if self.alias == "bts1":
            fsp_boards = self.cm_obj.get_bbmod_type()
        else:
            fsp_boards = self.cm_obj.get_bbmod_type_bts2()
        fsp_boards_str = " ".join(fsp_boards)
        builtin_obj.log("l1_type={}, bbu_type={}, fsp_boards_str={}".format(l1_type, bbu_type, fsp_boards_str))
        if l1_type == "FS" and bbu_type == "ASIL" and 'ABIP' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_ASIL_ABIP_FS")
        elif l1_type == "FS" and bbu_type == "ASIM" and 'ABIO' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_ASIM_ABIO_FS")
        elif l1_type == "FS" and bbu_type != "ASOE":
            # self._download_gnbmirror_script(self.gnb_bip_shell_script_path)
            # self._start_gnb_bip_log_by_script(gnb_bip_name,
            #                                   shell_script="gnbMirroring")
            self._start_gnb_bip_log_by_admin(interface)
        elif l1_type == 'L1B' and bbu_type == 'ASIB' and 'ABIL ABIL ABIL' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_On_ASIB_3ABIL_L1bypass")
        elif l1_type == "L1B" and bbu_type == 'ASIB' and 'ABIO' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_ASIB_ABIO")
        elif l1_type == "L1B" and bbu_type == 'ASIL' and 'ABIO' in fsp_boards_str:
            self._start_gnb_bip_log_by_script(gnb_bip_name,
                                              shell_script="gnbMirroring_On_ASIL_ABIO_L1bypass")
        else:
            builtin_obj.log("don't support to capture GNB BIP on such HW, please contact TA core team for help",
                            level="WARN")

    def _stop_to_capture_gnb_bip_log_by_script(self, tag):
        self._setup_gnb_bip()
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        bip_log_dir = "{}/{}_logs/gnb_bip_logs/".format(save_log_dir, tag) \
            if 'startup' in tag else "{}/gnb_bip_logs/".format(save_log_dir)
        gnb_bip_name = "gnb_bip" if 'startup' in tag or len(tag) == 0 else "gnb_bip_{}".format(tag)
        comm_obj.execute_cmd_on_pc("mkdir -p {}".format(bip_log_dir))

        # stop gnb shell script
        builtin_obj.log("step: stop gnb bip shell script")
        self.execute_cmd_on_bts(
            "ps aux | grep '{}' | grep -v -w grep".format(gnb_bip_name))
        self.execute_cmd_on_bts(
            "ps aux | grep '%s' | grep -v -w grep |awk '{print $2}' | xargs kill -9" % gnb_bip_name)

        # copy script file and script log to bip log dir
        try:
            temp_gnbmirror_script_folder = "/tmp/{}_script".format(gnb_bip_name)
            os_obj.copy_directory(temp_gnbmirror_script_folder, bip_log_dir)
            os_obj.remove_directory(temp_gnbmirror_script_folder, recursive=True)
            self.fsm_obj.get_enb_file("/ffs/run/logs/{}.log".format(gnb_bip_name), bip_log_dir, alias=self.alias)
        except Exception:
            pass

        # check gnb bip logs exist
        builtin_obj.log("step: check gnb bip logs exist or not on /tmp/{}*.pcap*".format(gnb_bip_name))
        self.verify_gnb_bip_log_exist(bip_folder="/tmp", bip_name="{}*.pcap*".format(gnb_bip_name))

        # download gnb bip logs
        builtin_obj.log("step: download gnb bip logs from /tmp/{}*.pcap*".format(gnb_bip_name))
        self.fsm_obj.get_enb_file("/tmp/{}*.pcap*".format(gnb_bip_name),
                                  bip_log_dir,
                                  alias=self.alias)
        self.execute_cmd_on_bts("rm -rf /tmp/{}*.pcap*".format(gnb_bip_name))

    def verify_gnb_bip_log_exist(self, bip_folder, bip_name, timeout=30):
        retry_times = int(timeout) / 10
        self._setup_gnb_bip()
        while retry_times >= 0:
            out1 = self.execute_cmd_on_bts("find {} -name {}".format(bip_folder, bip_name))
            out2 = self.execute_cmd_on_bts("echo $?")
            if out1 and str(out2) == "0":
                return True
            else:
                retry_times = retry_times - 1
                time.sleep(10)
        raise Exception("failure to find gnb bip log file for {}".format(bip_name))

    def stop_to_capture_gnb_bip_log(self, tag, combine_flag):
        if self.gnb_bip_method == "script":
            self._stop_to_capture_gnb_bip_log_by_script(tag)
        else:
            self._stop_gnb_bip_log_by_admin(tag, combine_flag)


class gnb_bip_bts1(object):

    def __init__(self):
        alias = "bts1"
        self.gnb_bip_base_instance_1 = gnb_bip_base(alias)

    def start_to_capture_gnb_bip_log(self, tag='', interface="L1-L2"):
        """
        This keyword is used to start to capture gnb bip logs.

        | Arguments | Man. | Default | Description |
        | tag       | No   | ''      | bip logs directory, gnb_bip_logs if tag is empty, else gnb_bip_logs_${tag} |

        Examples:
         | start_to_capture_gnb_bip_log |
         | start_to_capture_gnb_bip_log | 1st
        """
        self.gnb_bip_base_instance_1.start_to_capture_gnb_bip_log(tag, interface)

    def stop_to_capture_gnb_bip_log(self, tag='', combine_flag=True):
        """
        This keyword is used to stop to capture gnb bip logs.

        | Arguments    | Man. | Default | Description |
        | tag          | No   | ''   | bip logs directory, gnb_bip_logs if tag is empty, else gnb_bip_logs_${tag} |
        | combine_flag | No   | True | if True, combine all bip logs to mirroring_L2L1.pcap or mirroring_L2HIL2LO.pcap |

        Examples:
         | stop_to_capture_gnb_bip_log |
         | stop_to_capture_gnb_bip_log | 1st |
         | stop_to_capture_gnb_bip_log | 1st | ${False}
        """
        self.gnb_bip_base_instance_1.stop_to_capture_gnb_bip_log(tag, combine_flag)


class gnb_bip_bts2(object):

    def __init__(self):
        alias = "bts2"
        self.gnb_bip_base_instance_2 = gnb_bip_base(alias)

    def _setup_gnb_bip_bts2(self):
        self.gnb_bip_base_instance_2.bts_host = builtin_obj.get_variable_value('${BTS2_IP}')  # NG IP
        self.gnb_bip_base_instance_2.remote_host = builtin_obj.get_variable_value('${BTS2_PC_IP}')

    def start_to_capture_gnb_bip_log_bts2(self, tag='', interface="L1-L2"):
        """
        This keyword is used to start to capture gnb bip logs.

        | Arguments | Man. | Default | Description |
        | tag       | No   | ''      | bip logs directory, gnb_bip_logs if tag is empty, else gnb_bip_logs_${tag} |

        Examples:
         | start_to_capture_gnb_bip_log_bts2 |
         | start_to_capture_gnb_bip_log_bts2 | 1st
        """
        self._setup_gnb_bip_bts2()
        self.gnb_bip_base_instance_2.start_to_capture_gnb_bip_log(tag, interface)

    def stop_to_capture_gnb_bip_log_bts2(self, tag='', combine_flag=True):
        """
        This keyword is used to stop to capture gnb bip logs.

        | Arguments    | Man. | Default | Description |
        | tag          | No   | ''   | bip logs directory, gnb_bip_logs if tag is empty, else gnb_bip_logs_${tag} |
        | combine_flag | No   | True | if True, combine all bip logs to mirroring_L2L1.pcap or mirroring_L2HIL2LO.pcap |

        Examples:
         | stop_to_capture_gnb_bip_log_bts2 |
         | stop_to_capture_gnb_bip_log_bts2 | 1st |
         | stop_to_capture_gnb_bip_log_bts2 | 1st | ${False}
         """
        self._setup_gnb_bip_bts2()
        self.gnb_bip_base_instance_2.stop_to_capture_gnb_bip_log(tag, combine_flag)


class gnb_bip(gnb_bip_bts1, gnb_bip_bts2):
    def __init__(self):
        gnb_bip_bts1.__init__(self)
        gnb_bip_bts2.__init__(self)


if __name__ == "__main__":
    gnb_bip_obj = gnb_bip()
    help(gnb_bip_obj)
