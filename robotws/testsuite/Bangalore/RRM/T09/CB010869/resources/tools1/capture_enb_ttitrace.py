# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
import os
from cm.cm import cm
from ta_kiss_enb_ttitrace import ta_kiss_enb_ttitrace
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from base_lib.ta_ssh_telnet import ta_ssh_telnet
from taf.sbts.oam.coam.admin import admin
import traceback

builtin_obj = BuiltIn()
os_obj = OperatingSystem()
ssh_obj = ta_ssh_telnet()


class enb_ttitrace_base(object):

    def __init__(self, alias):
        self.setup_enb_ttitrace_flag = False
        self.alias = alias
        self.enb_ttitrace_port = "15002"
        self.remote_host = None

    def __del__(self):
        if self.setup_enb_ttitrace_flag and self.pc_conn != "":
            ssh_obj.disconnect_from_host(self.pc_conn)

    def _setup_enb_ttitrace(self):
        if not self.setup_enb_ttitrace_flag:
            self.setup_enb_ttitrace_flag = True
            scf_obj = cm()
            if self.alias == "enb1":
                self.all_lcrs = [cell_id[1] for cell_id in scf_obj.get_all_cells_id()]
            elif self.alias == "enb2":
                self.all_lcrs = scf_obj.get_all_cells_id_enb2()
                self.all_lcrs = [cell_id[1] for cell_id in scf_obj.get_all_cells_id_enb2()]
            else:
                raise Exception("Not support alias:%s" % self.alias)
            del scf_obj
            if self.remote_host is None:
                self.remote_host = "127.0.0.1"
            self.pc_conn = ssh_obj.connect_to_host(self.remote_host,
                                                   "22",
                                                   "ute",
                                                   "ute",
                                                   conn_type="SSH",
                                                   timeout="10")
            self.enb_ttitrace_obj = ta_kiss_enb_ttitrace()

    def _create_ttitrace_log_dir(self, enb_ttitrace_sub_dir):
        if self.alias == "enb1":
            save_log_dir = "%s/%s/" % (builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}"),
                                       enb_ttitrace_sub_dir)
        else:
            save_log_dir = "%s/%s/%s/" % (
                builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}"),
                self.alias, enb_ttitrace_sub_dir)
        os_obj.remove_directory(save_log_dir, True)
        os_obj.create_directory(save_log_dir)
        return save_log_dir

    def _kill_process_by_name(self, *keys):
        self._setup_enb_ttitrace()
        ps_cmd = "ps -ef | grep -v -w grep"
        for key in keys:
            ps_cmd += " | grep -i '%s'" % key
        ssh_obj.switch_host_connection(self.pc_conn)
        ps_out = ssh_obj.execute_shell_command(ps_cmd)
        if len(ps_out) != 0:
            kill_cmd = ps_cmd + " | awk '{print $2}' | xargs kill -9"
            ssh_obj.execute_shell_command(kill_cmd)
            ssh_obj.execute_shell_command(ps_cmd)

    def _kill_ttitrace_process(self):
        # TDD R4
        self._kill_process_by_name("onlineTtiStream")
        # TDD R3
        self._kill_process_by_name("ttiStream", self.enb_ttitrace_port)
        # FDD R4
        self._kill_process_by_name("cli_aatrace_utility_debian", self.enb_ttitrace_port)

    def _get_cellmapping(self):
        mapping = {}
        cores_id_ul = self.enb_ttitrace_obj.get_intact_core_id("UL", cell_id=",".join(self.all_lcrs), alias=self.alias)
        for index in range(len(cores_id_ul)):
            mapping[cores_id_ul[index][2:]] = "cell" + self.all_lcrs[index]

        cores_id_dl = self.enb_ttitrace_obj.get_intact_core_id("DL", cell_id=",".join(self.all_lcrs), alias=self.alias)
        for index in range(len(cores_id_dl)):
            mapping[cores_id_dl[index][2:]] = "cell" + self.all_lcrs[index]
        return mapping

    def _start_to_capture_enb_ttitrace(self, tag=""):
        self._setup_enb_ttitrace()
        # clean up
        self._kill_ttitrace_process()
        if len(tag.strip()):
            enb_ttitrace_sub_dir = "enb_ttitrace_" + tag.strip().lower()
        else:
            enb_ttitrace_sub_dir = "enb_ttitrace"
        enb_ttitrace_dir = self._create_ttitrace_log_dir(enb_ttitrace_sub_dir)
        alias = self.alias + tag
        try:
            self.enb_ttitrace_obj.teardown_enb_ttitrace(alias=alias)
        except Exception:
            pass
        # start enb ttitrace
        builtin_obj.log("step: setup enb ttitrace")
        builtin_obj.log(admin().store.all)
        self.enb_ttitrace_obj.setup_enb_ttitrace(log_path=enb_ttitrace_dir, alias=alias, host_ip=self.remote_host)
        builtin_obj.log("step: start enb ttitrace")
        self.enb_ttitrace_obj.start_enb_ttitrace(node_type="ALL", cell_id="ALL",
                                                 prefix="%s/enb_ttitrace" % enb_ttitrace_dir, alias=alias,
                                                 port=self.enb_ttitrace_port)

    def _stop_capture_enb_ttitrace(self, tag=""):
        self._setup_enb_ttitrace()
        try:
            alias = self.alias + tag
            builtin_obj.log("step: stop and decode enb ttitrace")
            csv_files = self.enb_ttitrace_obj.stop_and_decode_enb_ttitrace(ext="csv", alias=alias)
            builtin_obj.log("step: get cell mapping")
            self.cell_core_mapping = self._get_cellmapping()
            builtin_obj.log("step: rename enb ttitrace csv file")
            for csv_file in csv_files:
                csv_file_dir = os.path.dirname(csv_file)
                csv_file_name = os.path.basename(csv_file)
                if csv_file_name.lower().startswith("enb_ttitrace_ul") or csv_file_name.lower().startswith(
                        "enb_ttitrace_dl"):
                    # rename enb_ttitrace_DL_cell_1.csv to cell1_dl_0000.csv
                    new_file_name = csv_file_name.lower()
                    number = "0000"
                    direction = csv_file_name.split("_")[2]
                    cell = "cell%s" % csv_file_name.split(".")[0].split("_")[-1]
                else:
                    # rename enb_ttitrace_20180522092912_123A110D_dl_0000.dat.csv
                    # or enb_ttitrace_20180529025216_1231_dl_0000.dat.csv to cell1_dl_0000.csv
                    core_in_file_name = csv_file_name.split("_")[3]
                    number = csv_file_name.split(".")[0].split("_")[-1]
                    direction = csv_file_name.split(".")[0].split("_")[-2]
                    for core in self.cell_core_mapping.keys():
                        if core[0:len(core_in_file_name)].upper() == core_in_file_name.upper():
                            cell = self.cell_core_mapping[core]
                            break
                new_file_name = "%s_%s_%s.csv" % (cell, direction.lower(), number)
                os_obj.move_file(csv_file, os.path.join(csv_file_dir, new_file_name))
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log("decode enb tttirace failed: %s" % detail)
        finally:
            self.enb_ttitrace_obj.teardown_enb_ttitrace(alias=alias)


class enb_ttitrace_enb1(object):

    def __init__(self):
        alias = "enb1"
        self.enb_ttitrace_base_instance_1 = enb_ttitrace_base(alias)

    def start_to_capture_enb_ttitrace(self, tag=""):
        if not builtin_obj.convert_to_boolean(builtin_obj.get_variable_value('${TTITRACE_FLAG}')):
            return
        self.enb_ttitrace_base_instance_1._start_to_capture_enb_ttitrace(tag)

    def stop_capture_enb_ttitrace(self, tag=""):
        """
        This keyword is to stop and decode enb ttitrace.
        there will be some csv files like cell1_dl_0000.csv under
        ${SAVE_LOG_DIRECTORY}/enb_ttitrace if ${tag} is not specified,
        or under ${SAVE_LOG_DIRECTORY}/enb_ttitrace_${tag} if ${tag} is provided.
        """
        if not builtin_obj.convert_to_boolean(builtin_obj.get_variable_value('${TTITRACE_FLAG}')):
            return
        self.enb_ttitrace_base_instance_1._stop_capture_enb_ttitrace(tag)


class enb_ttitrace_enb2(object):

    def __init__(self):
        alias = "enb2"
        self.enb_ttitrace_base_instance_2 = enb_ttitrace_base(alias)

    def _setup_ttitrace_bts2(self):
        self.enb_ttitrace_base_instance_2.bts_host = builtin_obj.get_variable_value('${ENB2_IP}')  # S1 IP
        self.enb_ttitrace_base_instance_2.remote_host = builtin_obj.get_variable_value('${ENB2_PC_IP}')

    def start_to_capture_enb_ttitrace_enb2(self, tag=""):
        if not builtin_obj.convert_to_boolean(builtin_obj.get_variable_value('${TTITRACE_FLAG}')):
            return
        self._setup_ttitrace_bts2()
        self.enb_ttitrace_base_instance_2._start_to_capture_enb_ttitrace(tag)

    def stop_capture_enb_ttitrace_enb2(self, tag=""):
        """
        This keyword is to stop and decode enb ttitrace.
        there will be some csv files like cell1_dl_0000.csv
        under ${SAVE_LOG_DIRECTORY}/enb_ttitrace if ${tag} is not specified,
        or under ${SAVE_LOG_DIRECTORY}/enb_ttitrace_${tag} if ${tag} is provided.
        """
        if not builtin_obj.convert_to_boolean(builtin_obj.get_variable_value('${TTITRACE_FLAG}')):
            return
        self._setup_ttitrace_bts2()
        self.enb_ttitrace_base_instance_2._stop_capture_enb_ttitrace(tag)


class enb_ttitrace(enb_ttitrace_enb1, enb_ttitrace_enb2):
    def __init__(self):
        enb_ttitrace_enb1.__init__(self)
        enb_ttitrace_enb2.__init__(self)
