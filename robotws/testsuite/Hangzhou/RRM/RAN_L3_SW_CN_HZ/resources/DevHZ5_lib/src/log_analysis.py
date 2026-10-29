# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

import re
import os
from common_lib import common_lib
from ute_admin_infomodel import ute_admin_infomodel
from robot.libraries.BuiltIn import BuiltIn
from cm import cm
from taf.sbts.oam.coam.admin import admin
import traceback

comm_obj = common_lib()
builtin_obj = BuiltIn()
testlines_in_blacklist = []


class log_base(object):
    def __init__(self, alias):
        self.alias = alias
        self.remote_host = None
        self._setup_log_flag = False
        self.wts_dir = "/opt/wts/latest"
        self.bts_host = "192.168.255.129"

    def _setup_log_base(self):
        if not self._setup_log_flag:
            self._setup_log_flag = True
            try:
                cm_obj = cm()
                if self.alias == "gnb1":
                    self.cells = cm_obj.get_all_cells_id()
                elif self.alias == "gnb2":
                    self.cells = cm_obj.get_all_cells_id_gnb2()
                else:
                    raise Exception("Not support alias:%s" % self.alias)
                # del cm_obj
            except Exception as e:
                builtin_obj.log("get cells failed: %s" % e)
                self.cells = [('1', '1'), ('2', '2'), ('3', '3')]
            self.admin_obj = admin()

        comm_obj.setup_admin_if_alias_not_exist(self.admin_obj, self.alias, self.bts_host, self.remote_host)

    def __del__(self):
        pass

    def _get_save_log_dir(self, tag=''):
        if self.alias == "gnb1":
            save_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        else:
            save_log_dir = "%s/%s/" % (builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}"), self.alias)
        if tag.count("startup"):
            save_log_dir = os.path.join(save_log_dir, "%s_logs" % tag)
        return save_log_dir

    def _get_info_from_im(self):
        self._setup_log_base()
        self.all_onair = True
        bts_port, use_ssl = comm_obj.define_admin_port()
        try:
            ute_im_obj = ute_admin_infomodel()
            ute_im_obj.setup_infomodel(port=bts_port, use_ssl=use_ssl, alias=self.alias, remote_host=self.remote_host)
            ute_im_obj.connect_infomodel(alias=self.alias)
            builtin_obj.log("step: check all cells procedureState")
            for cell_id in self.cells:
                cell_m_obj = ute_im_obj.get_infomodel_object(dist_name="//CELL_M-%s" % cell_id[1], alias=self.alias)
                cell_state = cell_m_obj.stateInfo.proceduralState
                if cell_state.lower() == "onairdone":
                    comm_obj.log_to_console_with_time_prefix("cell%s procedureState in IM: %s"
                                                             % (cell_id[0], cell_state))
                else:
                    comm_obj.log_to_console_with_time_prefix("cell%s procedureState in IM: %s"
                                                             % (cell_id[0], cell_state), level="WARN")
                    self.all_onair = False

            builtin_obj.log("step: get gps info")
            self.gnss_obj = ute_im_obj.get_infomodel_object(dist_name="//GNSS-1", alias=self.alias)
        except Exception:
            self.all_onair = False
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix("fail to check cells procedureState")
            builtin_obj.log(detail)
        finally:
            try:
                ute_im_obj.disconnect_infomodel(alias=self.alias)
                ute_im_obj.teardown_infomodel(alias=self.alias)
            except Exception:
                pass

    def _get_wireshark_message_count(self, pcap_file, filter):
        """
        :param pcap_file: full path to pcap file
        :param filter: filter same as wireshark gui
        :return: the number of messges which satisfy filter
        """
        log_file = "/home/ute/tshark_tmp.txt"
        comm_obj.execute_cmd_on_pc("tshark -r %s -Y '%s' > %s" % (pcap_file, filter, log_file), timeout=60)
        count = 0
        try:
            f = open(log_file, "r")
            for line in f.readlines():
                count = count + 1
        finally:
            f.close()
        return count

    def _check_sibs_issue(self):
        if self.all_onair is False or self.reason_found is True:
            return
        if builtin_obj.get_variable_value("${BTS_NUMBER}") != "1":
            return
        try:
            builtin_obj.log("step: check sibs issue")
            self._setup_log_base()
            sib_flag = True
            for cell_id in self.cells:
                sib1_count = self._get_wireshark_message_count(self.ute_wireshark,
                                                               "lte-rrc.c1==1&&iphy.cell_id==%s" % cell_id[1])
                sib2_count = self._get_wireshark_message_count(self.ute_wireshark,
                                                               'lte-rrc.sib_TypeAndInfo_item==sib2&&iphy.cell_id==%s'
                                                               % cell_id[1])
                sib3_count = self._get_wireshark_message_count(self.ute_wireshark,
                                                               'lte-rrc.sib_TypeAndInfo_item==sib3&&iphy.cell_id==%s'
                                                               % cell_id[1])
                if sib1_count == 0 or sib2_count == 0 or sib3_count == 0:
                    sib_flag = False
                    break
            if sib_flag:
                self.reason_found = True
                comm_obj.log_to_console_with_time_prefix("Auto Blacklisted:'Iphy Sib1 And Sib2 Should Be Received' \
                failed even though UEC received SIB messages", level="WARN")
                comm_obj.log_to_console_with_time_prefix("Workaround: restart linux by executing sudo reboot",
                                                         level="WARN")
        except Exception:
            pass

    def _check_no_hb_response_issue(self):
        if self.reason_found:
            return
        try:
            builtin_obj.log("step: check no ho issue")
            comm_obj.file_should_contain_strings(self.egate_console_log, "No HB Response")
            self.reason_found = True
            comm_obj.log_to_console_with_time_prefix("Auto Blacklisted:No HB Response", level="WARN")
            comm_obj.log_to_console_with_time_prefix("Workaround: rerun case", level="WARN")
        except Exception:
            pass

    def _dns_disconnect_issue(self):
        """2021.9.1 Precheck:[Airscale][SBTS00][FDD][CRT][WTS] Failed to send HB-REQ fault raised after s1 link setup
           2021.9.15 [AP Precheck][CRT][ASIK][ABIL][SA][FS]ng link setup failed, no ngsetup response
        """
        if self.reason_found:
            return
        try:
            builtin_obj.log("step: check DNS server disconnect")
            comm_obj.file_should_contain_strings(self.egate_log, "GateStatsLogger - try to DNS server")
            comm_obj.file_should_contain_strings(self.egate_log, "GateStatsLogger - DNS replied, try to connect")
            comm_obj.file_should_contain_strings(self.egate_log, "GateStatsLogger - go for sending data")
            comm_obj.file_should_contain_strings(self.egate_log, "GateStatsLogger - data sent, waiting for response")
            comm_obj.file_should_contain_strings(self.egate_log, "GateStatsLogger - 504 from server")
            self.reason_found = True
            comm_obj.log_to_console_with_time_prefix("Auto Blacklisted:DNS Server Disconnect", level="WARN")
            comm_obj.log_to_console_with_time_prefix("Workaround: rerun case", level="WARN")
        except Exception:
            pass

    def _get_reported_alarm_from_btslog(self):
        self.reported_alarm = comm_obj.execute_cmd_on_pc('''grep -i "reported alarm" %s''' % self.btslog, timeout=60)

    def _list_cplane_abnormal_logs(self, test_status):
        builtin_obj.log("step: List cplane abnormal logs")
        cp_scs = ["cp_nb", "cp_cl", "cp_if", "cp_rt", "cp_nrt", "cp_ue", "cp_sctp", "up_ue"]
        cmd_e = "grep -i"
        cmd_w = "grep -i"
        for sc in cp_scs:
            cmd_e = cmd_e + " -e ERR/%s/" % sc
            cmd_w = cmd_w + " -e WRN/%s/" % sc
        cmd_e = cmd_e + " %s" % self.btslog
        cmd_w = cmd_w + " %s" % self.btslog
        cmd_e_n = cmd_e + " | wc -l"
        cmd_w_n = cmd_w + " | wc -l"
        try:
            number_e = comm_obj.execute_cmd_on_pc(cmd_e_n, timeout=600)
            number_w = comm_obj.execute_cmd_on_pc(cmd_w_n, timeout=600)
        except Exception:
            builtin_obj.log("fail to grep {}".format(self.btslog))
            return

        if number_e != "0" or number_w != "0":
            builtin_obj.log_to_console("")
            if test_status == "PASS":
                comm_obj.log_to_console_with_time_prefix(
                    "Cplane components have {} ERROR and {} WARNING logs, pls check it.".format(number_e, number_w),
                    level="INFO", color="yellow")
            elif self.reason_found is False and test_status == "FAIL":
                comm_obj.log_to_console_with_time_prefix(
                    "Cplane components have {} ERROR and {} WARNING logs, pls check it.".format(number_e, number_w),
                    level="WARN")
            else:
                pass
        if int(number_e) < 100:
            comm_obj.execute_cmd_on_pc(cmd_e, timeout=600)
        if int(number_w) < 100:
            comm_obj.execute_cmd_on_pc(cmd_w, timeout=600)

    def _list_reported_alarm(self):
        try:
            builtin_obj.log("step: List reported alarms from btslog:\n%s" % self.reported_alarm)
        except Exception:
            pass

    def _get_active_alarm(self):
        self._setup_log_base()
        self.active_alarms = []
        try:
            builtin_obj.log("step: get BTS state")
            state = self.admin_obj.get_mrbts_state(alias=self.alias, timeout=60)
            if state == "OnAir":
                level = "INFO"
            else:
                level = "WARN"
            if self.log_to_console:
                comm_obj.log_to_console_with_time_prefix("MRBTS state is %s" % state, level=level)
            else:
                builtin_obj.log("MRBTS state is %s" % state, level=level)
            builtin_obj.log("step: get active alarms")
            alarms = self.admin_obj.get_active_alarms(alias=self.alias, timeout=60)
            for alarm in alarms:
                updatetime = alarm['btsLastUpdateTime']
                updatetime_f = "%s-%s-%s %s:%s:%s" % (updatetime[0:4], updatetime[4:6], updatetime[6:8],
                                                      updatetime[8:10], updatetime[10:12], updatetime[12:])
                self.active_alarms.append((updatetime_f, alarm['severity'], alarm['faultId'], alarm['faultName'],
                                           alarm['configObjectName'].split()[-1]))
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix("fail to get active alarms")
            builtin_obj.log(detail)

    def _list_active_alarm(self):
        alarms_str = ""
        if len(self.active_alarms):
            try:
                fault_name_max_len = 0
                for alarm in self.active_alarms:
                    if len(alarm[3]) > fault_name_max_len:
                        fault_name_max_len = len(alarm[3])

                title = "%-32s%-10s%-10s%s  %s" % ("Report_time", "Severity", "FaultId",
                                                   "FaultName".ljust(fault_name_max_len), "Object")
                for alarm in self.active_alarms:
                    alarms_str = alarms_str + "%s    %-10s%-10s%s  %s\n" % (alarm[0], alarm[1], alarm[2],
                                                                            alarm[3].ljust(fault_name_max_len),
                                                                            alarm[4])
                if self.reason_found or self.log_to_console is False:
                    builtin_obj.log("step: List active alarms: \n%s\n%s" % (title, alarms_str))
                else:
                    comm_obj.log_to_console_with_time_prefix("List active alarms: \n%s\n%s" % (title, alarms_str),
                                                             level="WARN")
            except Exception:
                detail = traceback.format_exc()
                builtin_obj.log(detail)

    def _list_active_alarm_fault_10(self):
        builtin_obj.log(" get current active alarm: %s" % self.active_alarms, level="INFO")
        if len(self.active_alarms):
            try:
                fault_name_max_len = 0
                for alarm in self.active_alarms:
                    if len(str(alarm[3])) > fault_name_max_len:
                        fault_name_max_len = len(str(alarm[3]))
                rmod = []
                for alarm in self.active_alarms:
                    if str(alarm[3]) == "10":
                        rmod.append(str(alarm[2]))
                        builtin_obj.log("Have Fault 10]:[%s]" % alarm[2], level="INFO")
                    else:
                        builtin_obj.log("Have no Fault 10:[%s]" % alarm[2], level="INFO")
            except Exception as e:
                builtin_obj.log("Check fault_10 Fail [%s]." % str(e).splitlines()[0], level="INFO")

    def _list_abnormal_egate_console_log(self):
        try:
            out = comm_obj.execute_cmd_on_pc("grep -e ERR -e soft-reset -e ACR -e WARN %s | grep -v session | "
                                             "grep -v 'closed SCTP connection when X2 Setup Response is expected'" %
                                             self.egate_console_log, timeout=60)
            builtin_obj.log("step: List abnormal logs from egate_console.log:\n%s" % out, level="INFO", console=False)
        except Exception:
            pass

    def _list_abnormal_case_egate_console_log(self):
        try:
            case_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
            case_egate_log = os.path.abspath(os.path.join(case_log_dir, "WTS_logs", "case_egate_console.log"))

            out = comm_obj.execute_cmd_on_pc("grep -e ERR -e soft-reset -e ACR -e WARN %s | "
                                             "grep -v session | "
                                             "grep -v 'closed SCTP connection when X2 "
                                             "Setup Response is expected'" %
                                             case_egate_log, timeout=60)

            if self.reason_found or self.log_to_console is False:
                builtin_obj.log("step: List abnormal logs from case_egate_console.log:\n%s" % out,
                                level="INFO",
                                console=False)
            else:
                comm_obj.log_to_console_with_time_prefix("step: List abnormal logs from case_egate_console.log:\n%s"
                                                         % out, level="WARN")
        except Exception:
            pass

    def _check_gps_issue(self, fault_id):
        if self.reason_found:
            return
        try:
            builtin_obj.log("step: check gps issue")
            builtin_obj.should_contain(self.reported_alarm, "FaultId: %s" % fault_id)
            self.reason_found = True
            comm_obj.log_to_console_with_time_prefix("Auto Blacklisted:BTS_GPS reported fault %s"
                                                     % fault_id, level="WARN")
            comm_obj.log_to_console_with_time_prefix(
                "METIS=https://jiradc.ext.net.nokia.com/browse/WESTLAKE-8937", level="WARN")
            comm_obj.log_to_console_with_time_prefix("Workaround: rerun case or change testline", level="WARN")
        except Exception:
            pass

    def _check_gps_firmware_issue(self):
        """
        FYGB with firmware 1.03 supports only GPS
        FYGB with firmware 1.03 not supports GPS+GLONASS
        FYGB with firmware 1.03 not supports GLONASS only
        the low firmware maybe cause bts can't onair with fault 9 or 16
        """
        if self.reason_found:
            return
        try:
            builtin_obj.log("step: check gps firmware issue")
            faults = [alarm[2] for alarm in self.active_alarms]
            builtin_obj.log("zy:faults are %s" % faults)

            if 16 in faults or 9 in faults:
                nokiaUnitName = self.gnss_obj.hardwareInfo.nokiaUnitName
                version = "%s.%s" % (self.gnss_obj.softwareVersion.versionMajor,
                                     self.gnss_obj.softwareVersion.versionMinor)
                builtin_obj.log("zy: GPS info: %s" % self.gnss_obj)
                for time_source in self.gnss_obj.configuredConstellationModeList:
                    if time_source["satelliteSystem"] == "Glonass":
                        Glonass_status = time_source["constellationStatus"]
                        break
                builtin_obj.log("zy: GPS HW=%s, firmware version=%s, GLONASS=%s"
                                % (nokiaUnitName, version, Glonass_status))
                if nokiaUnitName == "FYGB" and version < "2.12" and Glonass_status == "Enabled":
                    self.reason_found = True
                    comm_obj.log_to_console_with_time_prefix(
                        "Auto Analyzed:GPS with FYGB firmware version %s is too low" % version, level="WARN")
                    comm_obj.log_to_console_with_time_prefix(
                        "AP needed: raise jira to local lab to upgrade GPS firmware, \
                        referring to https://srvjira.ext.net.nokia.com/browse/LSDSUP-863651", level="WARN")
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix("fail to check gps frimware issue")
            builtin_obj.log(detail)

    def _check_bts_crash_issue(self):
        builtin_obj.log("step: check bts crash issue")
        crash_info = comm_obj.execute_cmd_on_pc(
            "grep -i -e 'Please contact the owner' -e 'EU name' -e 'FATAL DSPHWAPI ERROR' %s | "
            "grep -v 'is not defined in SysinfoQuota.xml'" % self.btslog,
            timeout=300)
        if len(crash_info.strip()) and crash_info.count("No such file or directory") == 0:
            comm_obj.log_to_console_with_time_prefix("Auto Analyzed:\n%s" % crash_info, level="WARN")
            comm_obj.log_to_console_with_time_prefix("AP needed: report PR if not reported yet", level="WARN")
            raise Exception("bts crashed, report PR if needed")

    def _check_iphy_crash_issue(self):
        if self.reason_found:
            return
        try:
            builtin_obj.log("step: check iphy crash issue")
            crash_sc = []
            crash_info = comm_obj.execute_cmd_on_pc(
                "grep -i 'CRASH OCCURED' %s/*.log | grep -v egate_console.log | grep -v rrc*.log"
                % self.wts_dir, timeout=60)
            if crash_info.count("No such file or directory"):
                return

            for crash in crash_info.strip().splitlines():
                if crash.split(".")[0].split("/")[-1] not in crash_sc:
                    crash_sc.append(crash.split(".")[0].split("/")[-1])
            if len(crash_sc):
                self.reason_found = True
                comm_obj.log_to_console_with_time_prefix("Auto Analyzed:'%s' crashed" % " ".join(crash_sc),
                                                         level="WARN")
                comm_obj.log_to_console_with_time_prefix("%s" % crash_info.split("/")[-1], level="WARN")
                comm_obj.log_to_console_with_time_prefix(
                    "AP needed: step1 set ${DEBUG_LOG_LEVEL}=0 in TA case and reproduce this issue.", level="WARN")
                comm_obj.log_to_console_with_time_prefix(
                    "AP needed: step2 check if it is a known issue"
                    "https://confluence.ext.net.nokia.com/display/SIMMODE/Known+Issues%3A+UEC", level="WARN")
                comm_obj.log_to_console_with_time_prefix(
                    "AP needed: step3 report PR if it is a different issue", level="WARN")
        except Exception:
            pass

    def _check_ap_crash_issue(self):
        if self.reason_found:
            return
        try:
            builtin_obj.log("step: check APL3 crash issue")
            crash_info = comm_obj.execute_cmd_on_pc(
                "grep -i -e 'Please contact the owner' -e 'EU name' -e 'Program terminated with signal SIGSEGV' %s | "
                "grep -v 'Please contact the owner of the dir/file'" % self.aplog,
                timeout=60)
            if len(crash_info.strip()) and crash_info.count("No such file or directory") == 0:
                self.reason_found = True
                comm_obj.log_to_console_with_time_prefix("Auto Analyzed:\n%s" % crash_info, level="WARN")
                comm_obj.log_to_console_with_time_prefix(
                    "AP needed: step1 set ${AP_UDPLOG_LEVEL}=1 in TA case and reproduce this issue", level="WARN")
        except Exception:
            pass

    def _get_sim_enbs(self):
        out = comm_obj.execute_cmd_on_pc("ps -ef | grep sim_enb")
        sim_enbs = re.findall(r"sim_enb --id (\d+)", out, re.I)
        return sim_enbs

    def _check_handover_cancel_issue(self):
        if self.reason_found:
            return
        try:
            builtin_obj.log("step: check handover cancel issue")
            sim_enbs = self._get_sim_enbs()
            out = comm_obj.execute_cmd_on_pc("ls -ltr %s | awk '{print $9}'" % self.rrc_log)
        except Exception:
            return

        for log in out.strip().splitlines():
            for sim_enb in sim_enbs:
                try:
                    comm_obj.file_should_contain_strings(
                        log, "T_S1HoRequest timer expirations (No S1:HANDOVER_REQUEST_ACKNOWLEDGE from target eNB %s)"
                             % sim_enb)
                    self.reason_found = True
                    comm_obj.log_to_console_with_time_prefix(
                        "Auto Blacklisted:handover cancel received(T_S1HoRequest expiry)", level="WARN")
                    comm_obj.log_to_console_with_time_prefix("Workaround: rerun case", level="WARN")
                except Exception:
                    pass
                finally:
                    if self.reason_found:
                        return

    def _check_no_response_from_proxy_issue(self):
        if self.reason_found:
            return
        try:
            builtin_obj.log("step: check no response from proxy issue")
            out = comm_obj.execute_cmd_on_pc("grep -i 'No response from proxy' %s" % self.rrc_log)
            match = re.search(r"(No response from proxy for CTRL_[a-z_]+)", out, re.I)
            if match is not None:
                self.reason_found = True
                comm_obj.log_to_console_with_time_prefix("Auto Blacklisted:%s" % match.group(1), level="WARN")
                comm_obj.log_to_console_with_time_prefix("Workaround: rerun case", level="WARN")
        except Exception:
            pass

    def _check_testline_in_blacklist(self):
        if self.reason_found:
            return
        try:
            builtin_obj.log("step: check if testline in blacklist")
            hostname = comm_obj.execute_cmd_on_pc("hostname")
            if hostname in testlines_in_blacklist:
                comm_obj.log_to_console_with_time_prefix("Auto Blacklisted:%s in testlines blacklist" % hostname,
                                                         level="ERROR")
        except Exception:
            pass

    def _check_eif_missing_sfp_issue(self):
        builtin_obj.log("step: Begin check eif missing sfp issue: reason_found [%s]" % self.reason_found, level="INFO")
        if self.reason_found:
            return
        try:
            builtin_obj.log(" get current active alarm: [%s]" % self.active_alarms, level="INFO")
            if len(self.active_alarms):
                try:
                    fault_name_max_len = 0
                    for alarm in self.active_alarms:
                        if len(alarm[3]) > fault_name_max_len:
                            fault_name_max_len = len(alarm[3])

                    for alarm in self.active_alarms:
                        if str(61050) == str(alarm[2]):
                            if "EIF1" in str(alarm[3]):
                                comm_obj.log_to_console_with_time_prefix(
                                    "Auto Analyzed: FID-%s, %s" % (alarm[2], alarm[3]), level="WARN")
                                comm_obj.log_to_console_with_time_prefix(
                                    "AP needed: Please Check if there already have JIRA of this EIF issue, "
                                    "If not please raise jira to local lab. For example: "
                                    "https://jiradc.ext.net.nokia.com/browse/UTS-15958", level="WARN")
                                self.reason_found = True
                        # else:
                        # builtin_obj.log("Have no Fault 61050:[%s]" % alarm[2], level="INFO")
                except Exception as e:
                    builtin_obj.log("Check fault 61050 Fail [%s]." % str(e).splitlines()[0], level="INFO")
        except Exception:
            pass

    def _list_egate_sim_state(self):
        try:
            builtin_obj.log("step: list egate simulators state")
            out = comm_obj.execute_egate_command("state_sim_disp", "EGATE>", timeout=10).strip()
            if not out.count("The state is ACTIVE"):
                comm_obj.log_to_console_with_time_prefix("List egate simulators sate: \n %s"
                                                         % out.rstrip("EGATE>").strip(), level="WARN")
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)

    def _analyze_logs(self, tag, test_status):
        self._setup_log_base()
        auto_flag = builtin_obj.get_variable_value("${AUTO_ANALYSIS_FLAG}")
        self.btslog = os.path.join(self._get_save_log_dir(tag), "btslog*.LOG")
        self.aplog = os.path.join(self._get_save_log_dir(tag), "ap_udplog*.LOG")
        self.ute_wireshark = os.path.join(self._get_save_log_dir(tag), "ute_wireshark_eth4.pcap")
        self.egate_console_log = os.path.join(self.wts_dir, "egate_console.log")
        self.egate_log = os.path.join(self.wts_dir, "egate.log")
        self.rrc_log = os.path.join(self.wts_dir, "rrc*.log")

        self.reason_found = False
        if auto_flag is True and test_status is False or auto_flag is True and test_status == "FAIL":
            self.log_to_console = True
            builtin_obj.log_to_console("\n")
            comm_obj.log_to_console_with_time_prefix("###########################################", level="WARN")
            if tag.count("startup_1"):
                comm_obj.log_to_console_with_time_prefix("Analyzing first bts startup failure started", level="WARN")
            if tag.count("startup_2"):
                comm_obj.log_to_console_with_time_prefix("Analyzing second bts startup failure started", level="WARN")
            if tag.count("startup") == 0:
                test_name = builtin_obj.get_variable_value("${TEST_NAME}")
                comm_obj.log_to_console_with_time_prefix("Analyzing common issues to case: %s"
                                                         % test_name[0:50], level="WARN")
            # get info
            self._get_info_from_im()
            self._get_reported_alarm_from_btslog()
            self._get_active_alarm()
            self._list_egate_sim_state()
            self._list_reported_alarm()
            self._list_active_alarm()
            self._list_active_alarm_fault_10()
            if tag.count("startup") == 0:
                self._list_cplane_abnormal_logs(test_status)
                self._list_abnormal_case_egate_console_log()
            self._list_abnormal_egate_console_log()

            # for startup issues only
            if tag.count("startup"):
                # self._check_sibs_issue()
                self._check_gps_firmware_issue()
            # for common issues
            self._check_bts_crash_issue()
            self._check_ap_crash_issue()
            self._check_iphy_crash_issue()
            self._check_no_hb_response_issue()
            self._dns_disconnect_issue()
            self._check_gps_issue("4153")
            self._check_gps_issue("1898")
            # for case issues:
            if tag.count("startup") == 0:
                self._check_handover_cancel_issue()
                # self._check_no_response_from_proxy_issue()
            # dynamic testline blacklist
            self._check_eif_missing_sfp_issue()
            self._check_testline_in_blacklist()

            comm_obj.log_to_console_with_time_prefix("Analyzing finished, hope it could help you:)", level="WARN")
            comm_obj.log_to_console_with_time_prefix("############################################", level="WARN")
        else:
            self.log_to_console = False
            self._get_reported_alarm_from_btslog()
            self._get_active_alarm()
            self._list_egate_sim_state()
            self._list_reported_alarm()
            self._list_active_alarm()
            if tag.count("startup") == 0:
                self._list_cplane_abnormal_logs(test_status)
                self._list_abnormal_case_egate_console_log()
            self._list_abnormal_egate_console_log()
            self._check_bts_crash_issue()

        if builtin_obj.convert_to_boolean(builtin_obj.get_variable_value('${ERR_WRN_STATISTICS}')):
            if tag.count("startup"):
                ft = builtin_obj.get_variable_value("${FLOODING_THRESHOLD_STARTUP}", 200)
            else:
                ft = builtin_obj.get_variable_value("${FLOODING_THRESHOLD}", 100)
            skip_patterns = builtin_obj.get_variable_value("${FLOODING_SKIP_PATERNS}", [])
            sp = " ".join(["-sp " + i for i in skip_patterns])
            curdir = os.path.dirname(os.path.abspath(__file__))
            tool = "{}/../../../tools/log_check/analyze_log.py".format(curdir)
            err_wrn_baseline_file = self.get_err_wrn_baseline_file()
            out = comm_obj.execute_cmd_on_pc(
                f"python {tool} -l {self.btslog} -b {err_wrn_baseline_file} -ft {ft} {sp}",
                timeout=600)

            if out.count("Compare Result: FAIL"):
                builtin_obj.log("Analyzing {}:\n{}".format(self.btslog, out), level="WARN")
                raise Exception("err/wrn logs checking failed")
            if out.count("Exception found"):
                builtin_obj.log("Analyzing {}:\n{}".format(self.btslog, out), level="WARN")
                raise Exception("Exception found")
            if out.count("Flooding ERR found"):
                builtin_obj.log("Analyzing {}:\n{}".format(self.btslog, out), level="WARN")
                raise Exception("Flooding ERR found")

    def get_err_wrn_baseline_file(self):
        tags = builtin_obj.get_variable_value("${TEST TAGS}")
        if tags:
            log_tag = next((tag for tag in tags if tag.startswith("err_wrn_logs-")), None)
        else:
            log_tag = None
        if log_tag:
            suite_path = os.path.dirname(builtin_obj.get_variable_value("${SUITE SOURCE}"))
            err_wrn_baseline_file = os.path.join(suite_path, "test_data", "err_wrn_logs", log_tag.split("-")[-1])
            if os.path.exists(err_wrn_baseline_file):
                return err_wrn_baseline_file
            else:
                builtin_obj.log("file:{} not existing".format(err_wrn_baseline_file), level="WARN")
                return ""
        return ""


class log_bts1(log_base):
    def __init__(self):
        alias = "gnb1"
        self.log_base_1 = log_base(alias)

    def analyze_logs(self, tag="", test_status=""):
        self.log_base_1._analyze_logs(tag, test_status)

    def get_wireshark_message_count(self, pcap_file, filter):
        return self.log_base_1._get_wireshark_message_count(pcap_file, filter)


class log_analysis(log_bts1):
    def __init__(self):
        log_bts1.__init__(self)


if __name__ == "__main__":
    faults = [6202, 61652, 61524, 61649]
    if 6202 in faults or "9" in faults:
        print("ok")
