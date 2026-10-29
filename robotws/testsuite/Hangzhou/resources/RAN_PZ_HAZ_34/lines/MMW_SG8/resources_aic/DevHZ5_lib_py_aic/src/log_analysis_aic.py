# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

import re
import os
from .common_lib_aic import common_lib_aic
from ute_admin_infomodel import ute_admin_infomodel
from robot.libraries.BuiltIn import BuiltIn
from .cm_aic_cluster import cm_aic_cluster
from taf.sbts.oam.coam.admin import admin as ute_admin
import traceback
from taf.gnb.oam.coam.vdu import Vdu
from taf.gnb.oam.coam.cu import cu
import urllib3
from urllib3.exceptions import InsecureRequestWarning
urllib3.disable_warnings(InsecureRequestWarning)

comm_obj = common_lib_aic()
builtin_obj = BuiltIn()


class log_base(object):
    def __init__(self, alias):
        self.alias = alias
        self.alias_cu = self.alias + "_cu_analysis"
        self.alias_du = self.alias + "_du_analysis"
        self.alias_du2 = self.alias + "_du2_analysis"
        self.remote_host = None
        self._setup_log_flag = False
        self.wts_dir = "/opt/wts/latest"

    def _setup_log_base(self):
        if not self._setup_log_flag:
            self._setup_log_flag = True
            try:
                cm_obj = cm_aic_cluster()
                if self.alias == "gnb1":
                    self.cells = cm_obj.get_all_cells_id()
                elif self.alias == "gnb2":
                    self.cells = cm_obj.get_all_cells_id_gnb2()
                else:
                    raise Exception("Not support alias:%s" % self.alias)
                del cm_obj
            except Exception as e:
                builtin_obj.log("get cells failed: %s" % e)
                self.cells = [('1', '1'), ('2', '2'), ('3', '3')]

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
        cp_scs = ["CPNB", "CPCL", "CPIF", "CPRT", "CPNRT", "CPUE", "UPUE"]
        cmd = "grep -i"
        for sc in cp_scs:
            cmd = cmd + " -e ERR/%s/ -e WRN/%s/" % (sc, sc)
        cmd = cmd + " %s" % self.btslog
        cmd1 = cmd + " | wc -l"
        number = comm_obj.execute_cmd_on_pc(cmd1, timeout=60)
        if number != "0":
            builtin_obj.log_to_console("")
            if test_status == "PASS":
                comm_obj.log_to_console_with_time_prefix(
                    "Cplane components have %s ERROR or WARNING logs, pls check it."
                    % number, level="INFO", color="yellow")
            elif self.reason_found is False and test_status == "FAIL":
                comm_obj.log_to_console_with_time_prefix("Cplane components have %s ERROR or WARNING logs."
                                                         % number, level="WARN")
            else:
                pass
        if int(number) < 100:
            comm_obj.execute_cmd_on_pc(cmd, timeout=60)

    def _list_reported_alarm(self):
        try:
            builtin_obj.log("step: List reported alarms from btslog:\n%s" % self.reported_alarm)
        except Exception:
            pass

    def _get_active_alarm_aic(self, productVariant, du_identity="du"):
        self.active_alarms = []
        try:
            bts_port, use_ssl = comm_obj.define_admin_port()
            if productVariant == "cu":
                self.cu_host = builtin_obj.get_variable_value("${VCU_IP}")
                admin_obj = cu()
                if not comm_obj.check_alias_exist_on_admin(admin_obj, self.alias_cu):
                    admin_obj.connect_to(alias=self.alias_cu, port=bts_port, secure=use_ssl,
                                         host=self.cu_host, username="Nemuadmin", password="nemuuser")
                builtin_obj.log("step: get BTS state")
                state_info = admin_obj.get_cu_state(connection=self.alias_cu)
                state = state_info["operational_state"]
                if state == "enabled":
                    level = "INFO"
                else:
                    level = "WARN"
                if self.log_to_console:
                    comm_obj.log_to_console_with_time_prefix("vCU state is %s" % state, level=level)
                else:
                    builtin_obj.log("vCU state is %s" % state, level=level)
                builtin_obj.log("step: get cu active alarms")
                alarms = admin_obj.get_active_alarms(connection=self.alias_cu)
            elif productVariant == "du":
                admin_obj = Vdu()
                if du_identity == "du":
                    self.du_host = builtin_obj.get_variable_value("${VDU_IP}")
                    if not comm_obj.check_alias_exist_on_admin(admin_obj, self.alias_du):
                        admin_obj.connect_to(host=self.du_host, port=bts_port, username="Nemuadmin",
                                             password="nemuuser", secure=use_ssl, connection_name=self.alias_du)
                    state_info = admin_obj.get_vdu_state_data(vdu_connection=self.alias_du)
                elif du_identity == "du2":
                    self.du2_host = builtin_obj.get_variable_value("${VDU2_IP}")
                    if not comm_obj.check_alias_exist_on_admin(admin_obj, self.alias_du2):
                        admin_obj.connect_to(host=self.du2_host, port=bts_port, username="Nemuadmin",
                                             password="nemuuser", secure=use_ssl, connection_name=self.alias_du2)
                    state_info = admin_obj.get_vdu_state_data(vdu_connection=self.alias_du2)
                state = state_info["operational_state"]
                if state == "onAir":
                    level = "INFO"
                else:
                    level = "WARN"
                if self.log_to_console:
                    comm_obj.log_to_console_with_time_prefix("v%s state is %s" % (du_identity.upper(), state),
                                                             level=level)
                else:
                    builtin_obj.log("v%s state is %s" % (du_identity.upper(), state), level=level)
                builtin_obj.log("step: get %s active alarms" % du_identity)
                if du_identity == "du":
                    alarms = admin_obj.vdu_get_active_alarms(vdu_connection=self.alias_du)
                if du_identity == "du2":
                    alarms = admin_obj.vdu_get_active_alarms(vdu_connection=self.alias_du2)

            for alarm in alarms['alarms']:
                updatetime = alarm['last_updated_time']
                updatetime_f = "%s-%s-%s %s:%s:%s" % (updatetime[0:4], updatetime[5:7], updatetime[8:10],
                                                      updatetime[11:13], updatetime[14:16], updatetime[17:])
                self.active_alarms.append((updatetime_f, alarm['severity'].capitalize(), alarm['fault_id'],
                                           alarm['fault_name'], alarm['alarming_object']))
            return self.active_alarms
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix("fail to get %s active alarms" % productVariant)
            builtin_obj.log(detail)
        finally:
            try:
                if productVariant == "cu":
                    admin_obj.disconnect(connection=self.alias_cu)
                if productVariant == "du" and du_identity == "du":
                    admin_obj.disconnect(vdu_connection=self.alias_du)
                if productVariant == "du" and du_identity == "du2":
                    admin_obj.disconnect(vdu_connection=self.alias_du2)
            except Exception:
                pass

    def _get_active_alarm_cu(self):
        self.active_alarms_cu = self._get_active_alarm_aic(productVariant="cu")

    def _get_active_alarm_du(self):
        self.active_alarms_du = self._get_active_alarm_aic(productVariant="du")

    def _get_active_alarm_du2(self):
        self.active_alarms_du2 = self._get_active_alarm_aic(productVariant="du", du_identity="du2")

    def _get_active_alarm(self):
        du_num = builtin_obj.get_variable_value("${DU_NUMBER}")
        self._get_active_alarm_cu()
        self._get_active_alarm_du()
        if du_num == "2du":
            self._get_active_alarm_du2()

    def _list_active_alarm_aic(self, alarms_info, product_type):
        self.active_alarms = alarms_info
        alarms_str = ""
        if self.active_alarms is not None:
            if len(self.active_alarms):
                try:
                    fault_name_max_len = 0
                    for alarm in self.active_alarms:
                        if len(alarm[3]) > fault_name_max_len:
                            fault_name_max_len = len(alarm[3])

                    title = "%-29s%-10s%-10s%s  %s" % ("Appeared", "Severity", "Fault ID",
                                                       "Fault name".ljust(fault_name_max_len), "Alarming object")
                    for alarm in self.active_alarms:
                        alarms_str = alarms_str + "%s    %-10s%-10s%s  %s\n" % (alarm[0], alarm[1], alarm[2],
                                                                                alarm[3].ljust(fault_name_max_len),
                                                                                alarm[4])
                    if self.reason_found or self.log_to_console is False:
                        builtin_obj.log("step: List %s active alarms: \n%s\n%s" % (product_type, title, alarms_str))
                    else:
                        comm_obj.log_to_console_with_time_prefix(
                            "List %s active alarms: \n%s\n%s" % (product_type, title, alarms_str), level="WARN")
                except Exception:
                    detail = traceback.format_exc()
                    builtin_obj.log(detail)

    def _list_active_alarm_cu(self):
        self._list_active_alarm_aic(alarms_info=self.active_alarms_cu, product_type="cu")

    def _list_active_alarm_du(self):
        self._list_active_alarm_aic(alarms_info=self.active_alarms_du, product_type="du")

    def _list_active_alarm_du2(self):
        self._list_active_alarm_aic(alarms_info=self.active_alarms_du2, product_type="du2")

    def _list_active_alarm(self):
        du_num = builtin_obj.get_variable_value("${DU_NUMBER}")
        self._list_active_alarm_cu()
        self._list_active_alarm_du()
        if du_num == "2du":
            self._list_active_alarm_du2()

    def _list_abnormal_egate_console_log(self):
        try:
            out = comm_obj.execute_cmd_on_pc("grep -e ERR -e soft-reset -e ACR %s | grep -v session | grep -v \
            'closed SCTP connection when X2 Setup Response is expected'" % self.egate_console_log, timeout=60)
            if self.reason_found or self.log_to_console is False:
                builtin_obj.log("step: List abnormal logs from egate_console.log:\n%s" % out)
            else:
                comm_obj.log_to_console_with_time_prefix("List abnormal logs from egate_console.log:\n%s"
                                                         % out, level="INFO")  # 2022.08.02 WARN --> INFO
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

    def _check_gnb_crash_issue(self):
        if self.reason_found:
            return
        try:
            builtin_obj.log("step: check gnb crash issue")
            crash_str_list = ["Handler exception report"]
            syslog_str_ret = comm_obj.execute_cmd_on_pc("ls %s | grep .*_syslog.zip | head -n 5" % self.btslog)
            syslog_list_ret = syslog_str_ret.split('\r\n')
            for sys_log in syslog_list_ret:
                for crash_str in crash_str_list:
                    crash_check_cmd = "zipinfo -1 %s|grep 'syslog_latest'|head -n 1 |" \
                                      "xargs -I {} unzip -p %s {} > %s/inner.zip;zipgrep -c '%s' %s/inner.zip |" \
                                      "awk -F: '{print $2}'" % (self.btslog + "/" + sys_log,
                                                                self.btslog + "/" + sys_log,
                                                                self.btslog, crash_str, self.btslog)
                    crash_ret = comm_obj.execute_cmd_on_pc(crash_check_cmd)
                    comm_obj.execute_cmd_on_pc("rm %s/inner.zip" % self.btslog)
                    if int(crash_ret) > 0:
                        self.reason_found = True
                        comm_obj.log_to_console_with_time_prefix("Auto Analyzed:\n%s found crash" % sys_log,
                                                                 level="WARN")
                        comm_obj.log_to_console_with_time_prefix("AP needed: report PR if not reported yet",
                                                                 level="WARN")
                        raise Exception("%s found crash" % sys_log)
        except Exception as e:
            if str(e).count("found crash"):
                raise Exception(str(e))
            else:
                pass

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
                    "AP needed: step2 check if it is a known issue "
                    "https://confluence.ext.net.nokia.com/display/SIMMODE/Known+Issues%3A+UEC", level="WARN")
                comm_obj.log_to_console_with_time_prefix(
                    "AP needed: step3 report PR if it is a different issue", level="WARN")
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

    def _analyze_logs(self, tag, test_status):
        self._setup_log_base()
        auto_flag = builtin_obj.get_variable_value("${AUTO_ANALYSIS_FLAG}")
        self.btslog = self._get_save_log_dir(tag)
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
            # (1) check if it is special issue
            # no need or different in Aic
            # self._get_info_from_im()
            # self._get_reported_alarm_from_btslog()
            self._get_active_alarm()
            # for startup issues only, no need in Aic.
            # if tag.count("startup"):
            #                     self._check_sibs_issue()
            #     self._check_gps_firmware_issue()
            # for common issues
            self._check_gnb_crash_issue()
            self._check_iphy_crash_issue()
            self._check_no_hb_response_issue()
            self._dns_disconnect_issue()
            # self._check_gps_issue("4153")
            # self._check_gps_issue("1898")
            # for case issues:
            if tag.count("startup") == 0:
                self._check_handover_cancel_issue()
                # self._check_no_response_from_proxy_issue()

            # (2)list all reported alarm and abnormal egate console log if cause not found
            # self._list_reported_alarm()
            self._list_active_alarm()
            # if tag.count("startup") == 0:
            #     self._list_cplane_abnormal_logs(test_status)
            self._list_abnormal_egate_console_log()
            comm_obj.log_to_console_with_time_prefix("Analyzing finished, hope it could help you:)", level="WARN")
            comm_obj.log_to_console_with_time_prefix("############################################", level="WARN")
        else:
            self.log_to_console = False
            # self._get_reported_alarm_from_btslog()
            self._get_active_alarm()
            # self._list_reported_alarm()
            self._list_active_alarm()
            # if tag.count("startup") == 0:
            #     self._list_cplane_abnormal_logs(test_status)
            self._list_abnormal_egate_console_log()
            self._check_gnb_crash_issue()


class log_gnb1(log_base):

    def __init__(self):
        alias = "gnb1"
        self.log_base_1 = log_base(alias)

    def analyze_logs(self, tag="", test_status=""):
        self.log_base_1._analyze_logs(tag, test_status)

    def get_wireshark_message_count(self, pcap_file, filter):
        return self.log_base_1._get_wireshark_message_count(pcap_file, filter)


class log_analysis_aic(log_gnb1):
    def __init__(self):
        log_gnb1.__init__(self)


if __name__ == "__main__":
    faults = [6202, 61652, 61524, 61649]
    if 6202 in faults or "9" in faults:
        print("ok")
