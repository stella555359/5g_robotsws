# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

import time
import datetime
import os
import re
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from ..common_lib import common_lib
from ..base_lib.ute_fsmaccess import ute_fsmaccess
from ..base_lib.ta_xml import ta_xml
from ..base_lib.ta_xml.common_xml import CommonXML
from taf.sbts.oam.coam.admin import admin
from ute_admin_infomodel import ute_admin_infomodel
import traceback
from taf.hw.pdu import pdu
import xml.etree.ElementTree as ET

comm_obj = common_lib()
os_obj = OperatingSystem()
builtin_obj = BuiltIn()
xml_obj = ta_xml()

PRECATEGORY_STARTUP_RECORD = {}


class startup_base(object):
    def __init__(self, alias):
        self.alias = alias
        self.remote_host = None
        self.bts_host = "192.168.255.129"
        self.info_obj = ute_admin_infomodel()
        self.stateinfo_change_flag = False
        self._setup_startup_flag = False

        global PRECATEGORY_STARTUP_RECORD
        PRECATEGORY_STARTUP_RECORD[self.alias] = []

    def _precategory_startup(self, message):
        current_date = time.strftime("%Y-%m-%d_%H:%M:%S", time.localtime())
        error_info = "%s^%s" % (message, current_date)
        PRECATEGORY_STARTUP_RECORD[self.alias].append(error_info)

    def _setup_startup(self):
        if not self._setup_startup_flag:
            self._setup_startup_flag = True
            self.admin_obj = admin()
            comm_obj.setup_admin_if_alias_not_exist(self.admin_obj, self.alias, self.bts_host, self.remote_host)
            if self.alias == "bts1":
                self.scf_for_analysis = "/home/ute/scf_a.xml"
            else:
                os_obj.create_directory("/home/ute/{}".format(self.alias))
                self.scf_for_analysis = "/home/ute/{}/scf_a.xml".format(self.alias)
            directory, file_name = os.path.split(self.scf_for_analysis)
            self.admin_obj.get_current_scf_file(local_dir_path=directory, file_name=file_name,
                                                export_type="configurationAndRuntimeObjects",
                                                with_auto_configured_parameters=True,
                                                timeout=60,
                                                connection=self.alias)
        comm_obj.setup_admin_if_alias_not_exist(self.admin_obj, self.alias, self.bts_host, self.remote_host)

    def _get_rrus_from_iphy_xml(self, source_file_name='iphy', target_file_name='iphy'):
        try:
            rrus_in_iphy_xml = []
            fsm_obj = ute_fsmaccess()
            fsm_obj.setup_wts_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#")
            fsm_obj.get_wts_file("/ffs/run/simmode/{}.xml".format(source_file_name),
                                 "/home/ute/{}.xml".format(target_file_name), alias=self.alias)
            fsm_obj.teardown_wts_fsm_access(alias=self.alias)
            commonxml_obj = CommonXML("/home/ute/{}.xml".format(target_file_name))
            all_elements = commonxml_obj.get_elements("//cardName")
            for element in all_elements:
                rrus_in_iphy_xml.append(commonxml_obj.get_element_text(element))
            builtin_obj.log("RRUs in {}.xml are %{}".format(target_file_name, rrus_in_iphy_xml))
        except Exception:
            rrus_in_iphy_xml = []
            builtin_obj.log("Get {}}.xml RRU Type failure".format(target_file_name, rrus_in_iphy_xml), level="WARN")
        finally:
            return rrus_in_iphy_xml

    def _ping_ok(self, ip):
        out = comm_obj.execute_cmd_on_pc("ping %s -c 2" % ip)
        if out.count("100% packet loss"):
            return False
        else:
            return True

    def _ping_ok_until_timeout(self, ip, timeout=60):
        retry_times = int(timeout) / 10
        while retry_times > 0:
            result = self._ping_ok(ip)
            if result is False:
                retry_times = retry_times - 1
                continue
            else:
                return True
        if retry_times <= 0:
            return False

    def _wait_restart(self, ip, timeout=60):
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

    def _start_to_capture_infomodel_log(self, alias):
        bts_port, use_ssl = comm_obj.define_admin_port()
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        ping_ok = self._ping_ok(self.bts_host)
        if ping_ok:
            self.info_obj.setup_infomodel(alias=alias, port=bts_port, use_ssl=use_ssl,
                                          admin_api_log_dir=save_log_dir + "/admin_logs", address=self.bts_host,
                                          timeout=120)
        else:
            self.info_obj.setup_infomodel(alias=alias, port=bts_port, use_ssl=use_ssl,
                                          admin_api_log_dir=save_log_dir + "/admin_logs", remote_host=self.remote_host,
                                          address="192.168.255.129", timeout=120)
        self.info_obj.connect_infomodel(alias=alias)

    def _stop_to_capture_infomodel_log(self, tag, save, alias, timeout=60):
        if save:
            save_log_dir = comm_obj._get_save_log_dir(self.alias)
            if "startup" in tag or len(tag) == 0:
                im_name = "infomodel_log.ims2"
            else:
                im_name = "infomodel_log_{}.ims2".format(tag)
            if "startup" in tag:
                im_dir = save_log_dir + "%s_logs" % tag
            else:
                im_dir = save_log_dir
            self.info_obj.save_infomodel_log("%s/%s" % (im_dir, im_name), alias=alias, timeout=timeout)
            builtin_obj.log("infomodel log saved to {}".format("%s/%s" % (im_dir, im_name)))
        self.info_obj.disconnect_infomodel(alias=alias)
        self.info_obj.teardown_infomodel(alias=alias)

    def _wait_all_rrus_detected(self, rru_startup_time):
        self._setup_startup()
        comm_obj.log_to_console_with_time_prefix("step: wait all RRUs detected")
        start_time = datetime.datetime.now()
        try:
            commonxml_obj = CommonXML(self.scf_for_analysis)
            rrus_num = len(commonxml_obj.get_elements("//*[matches(@class, '.*:RMOD$')]"))
            if not self.stateinfo_change_flag:
                self.info_obj.query_infomodel(
                    "count //RMOD_R-* is [stateInfo.availabilityStatus=Online] = %s"
                    % rrus_num, timeout=rru_startup_time, alias=self.alias)
            else:
                self.info_obj.query_infomodel(
                    "count //RMOD_R-* is [availabilityStatus=empty] = %s"
                    % rrus_num, timeout=rru_startup_time, alias=self.alias)
            endtime = datetime.datetime.now()
            time_elapse = (endtime - start_time).seconds
            comm_obj.log_to_console_with_time_prefix("step: wait all RRUs detected cost {} sec".format(time_elapse))
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix("fail to detect all RRUs of {}".format(self.alias), level="WARN")
            raise Exception("fail to detect all RRUs of {}: {}".format(self.alias, detail))

    def _wait_bbmod_startup(self):
        comm_obj.log_to_console_with_time_prefix("step: wait all BBMODs startup")
        start_time = datetime.datetime.now()
        self._check_stateinfo_change_or_not("BBMOD_R")
        try:
            if not self.stateinfo_change_flag:
                self.info_obj.query_infomodel(
                    "every //BBMOD_R-* is [stateInfo.availabilityStatus=regex\"Online|Degraded\"]",
                    timeout=300, alias=self.alias)
            else:
                self.info_obj.query_infomodel(
                    "every //BBMOD_R-* is [availabilityStatus=empty]",
                    timeout=300, alias=self.alias)
            endtime = datetime.datetime.now()
            time_elapse = (endtime - start_time).seconds
            comm_obj.log_to_console_with_time_prefix("step: wait all BBMODs startup cost {} sec".format(time_elapse))
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix("fail to startup all BBMODs of {}".format(self.alias),
                                                     level="WARN")
            raise Exception("fail to startup all BBMODs of {}: {}".format(self.alias, detail))

    def _wait_smod_startup(self):
        comm_obj.log_to_console_with_time_prefix("step: wait all SMOD startup")
        start_time = datetime.datetime.now()
        self._check_stateinfo_change_or_not("SMOD_R")
        try:
            if not self.stateinfo_change_flag:
                self.info_obj.query_infomodel(
                    "every //SMOD_R-* is [stateInfo.availabilityStatus=regex\"Online|Degraded\"]",
                    timeout=300, alias=self.alias)
            else:
                self.info_obj.query_infomodel(
                    "every //SMOD_R-* is [availabilityStatus=empty]",
                    timeout=300, alias=self.alias)
            endtime = datetime.datetime.now()
            time_elapse = (endtime - start_time).seconds
            comm_obj.log_to_console_with_time_prefix("step: wait all SMODs startup cost %s sec" % time_elapse)
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix("fail to startup all SMODs", level="WARN")
            raise Exception("fail to startup all SMODs: %s" % detail)

    def _wait_gnb_configured(self):
        comm_obj.log_to_console_with_time_prefix("step: wait GNB enter Into Configured State")
        start_time = datetime.datetime.now()
        try:
            self.info_obj.query_infomodel("//MRBTS_M-* is [stateInfo.proceduralState=Configured]",
                                          timeout=300, alias=self.alias)
            endtime = datetime.datetime.now()
            time_elapse = (endtime - start_time).seconds
            comm_obj.log_to_console_with_time_prefix(
                "step: wait GNB enter Into Configured State cost {} sec".format(time_elapse))
        except Exception:
            detail = traceback.format_exc()
            obj = self.info_obj.get_infomodel_object("//MRBTS_M-*", timeout=20, alias=self.alias)
            comm_obj.log_to_console_with_time_prefix("{} state is {}".format(
                self.alias, obj.stateInfo.proceduralState), level="WARN")
            raise Exception("{} state is %s, failed to enter into Configured state: {}".format(
                self.alias, obj.stateInfo.proceduralState, detail))

    def _wait_ng_link_up(self):
        if self.alias == "bts1":
            gnb_ip = "10.0.1.2"
        else:
            gnb_ip = self.bts_host
        comm_obj.log_to_console_with_time_prefix("step: wait NG link {} is pingable".format(gnb_ip))
        ping_ok = self._ping_ok_until_timeout(ip=gnb_ip, timeout=60)
        if not ping_ok:
            comm_obj.log_to_console_with_time_prefix("NG link {} is not pingable".format(gnb_ip), level="WARN")
            raise Exception("NG link {} is not pingable".format(gnb_ip))
        comm_obj.log_to_console_with_time_prefix("step: wait NG link up between AMF and gnb")
        start_time = datetime.datetime.now()
        try:
            comm_obj.egate_console_log_should_contain("/opt/wts/latest/egate_console.log", "IP:%s NG link is Up"
                                                      % gnb_ip, timeout=300, interval=10)
            endtime = datetime.datetime.now()
            time_elapse = (endtime - start_time).seconds
            comm_obj.log_to_console_with_time_prefix(
                "step: wait NG link up between AMF and gnb cost %s sec" % time_elapse)
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix("fail to setup NG link of {}".format(self.alias), level="WARN")
            self._precategory_startup("[Pre-Category][NG Link Up Fail][%s(%s)'s ng link up fail]"
                                      % (self.alias, gnb_ip))
            raise Exception("fail to setup NG link of {}: {}".format(self.alias, detail))

    def _wait_cell_state(self, cell_id, expected_state, alias="default"):
        if builtin_obj.get_variable_value("${TEST NAME}") is not None:
            builtin_obj.log("step: wait cell{} reach {}".format(cell_id, expected_state), console=False)
        else:
            comm_obj.log_to_console_with_time_prefix("step: wait cell{} reach {}".format(cell_id, expected_state))
        start_time = datetime.datetime.now()
        try:
            self.info_obj.query_infomodel(
                "//CELL_M-{} is [stateInfo.proceduralState={}]".format(cell_id, expected_state),
                timeout=360, alias=alias)
        except Exception:
            detail = traceback.format_exc()
            obj = self.info_obj.get_infomodel_object("//CELL_M-%s" % cell_id)
            comm_obj.log_to_console_with_time_prefix("CELL{} state is {}".format(
                cell_id, obj.stateInfo.proceduralState), "WARN")
            raise Exception(detail)
        endtime = datetime.datetime.now()
        time_elapse = (endtime - start_time).seconds
        if builtin_obj.get_variable_value("${TEST NAME}") is not None:
            builtin_obj.log("step: wait cell{} reach {} cost {} sec".format(cell_id, expected_state, time_elapse),
                            console=False)
        else:
            comm_obj.log_to_console_with_time_prefix("step: wait cell{} reach {} cost {} sec".format(
                cell_id, expected_state, time_elapse))

    def _wait_cell_onair(self, cell_id, alias):
        self._wait_cell_state(cell_id, "OnAirDone", alias=alias)

    def _wait_cell_validated(self, cell_id, alias):
        self._wait_cell_state(cell_id, "Validated", alias=alias)

    def _cells_should_be_onair(self, cell_id="all", timeout="120", alias="default", **kwargs):
        cell_id = str(cell_id)
        # check onair state from IM
        if cell_id == "all":
            cells_info = self._get_cells_info()
            for cell in cells_info:
                self._wait_cell_onair(cell["instance_id"], alias=alias)
        else:
            cell_ids = cell_id.split(",")
            for cell_id_s in cell_ids:
                self._wait_cell_onair(cell_id_s, alias=alias)

        # don't check SIB for ST env
        pid = comm_obj.get_linux_process_id("egate")
        if len(pid) == 0:
            return

        # check SIB for AP env
        check_sib = kwargs.get("check_sib", True)
        if check_sib:
            self._wait_sibs_cmd(cell_id, timeout)
        if builtin_obj.get_variable_value("${TEST NAME}") is not None:
            builtin_obj.log("step: wait 10s+ for CuConfigurationUpdate", console=False)
        else:
            comm_obj.log_to_console_with_time_prefix("step: wait 10s+ for CuConfigurationUpdate")
        time.sleep(12)  # internal timer timeToWait=10s for PR654414 to wait cell really available

    def _cell_adminstate_should_be(self, cell_id, state, alias="default"):
        try:
            self.info_obj.query_infomodel("//NRCELL_R-%s is [administrativeState=%s]" % (cell_id, state),
                                          timeout=120, alias=alias)
        except Exception:
            detail = traceback.format_exc()
            raise Exception("fail to check infomodel: %s" % detail)
        finally:
            obj = self.info_obj.get_infomodel_object("//NRCELL_R-%s" % cell_id, alias=alias)
            builtin_obj.log(obj)
            builtin_obj.log("administrativeState is %s" % obj.administrativeState)

    def _wait_sibs(self, instance_id, lcr_id):
        wts_gnb_id = 2 if self.alias == "bts1" else 3
        comm_obj.log_to_console_with_time_prefix("step: wait cell{} sibs".format(instance_id))
        start_time = datetime.datetime.now()
        try:
            comm_obj.egate_console_log_should_contain(
                "/opt/wts/latest/egate_console.log",
                ["eNB {} cell {}: SystemInformationBlockType1-NR updated".format(wts_gnb_id, lcr_id),
                 "eNB {} cell {}: SystemInformationBlockType2-NR updated".format(wts_gnb_id, lcr_id)],
                timeout=300, interval=10)
            endtime = datetime.datetime.now()
            time_elapse = (endtime - start_time).seconds
            comm_obj.log_to_console_with_time_prefix("step: wait cell{} sibs cost {} sec".format(
                instance_id, time_elapse))
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix("fail to wait cell{} sibs".format(instance_id), level="WARN")
            self._precategory_startup("[Pre-Category][SIB Message Not Received][GNB(%s)-cell(%s) SIB message not "
                                      "received]" % (wts_gnb_id, instance_id))
            raise Exception("fail to wait cell{} sibs: {}".format(instance_id, detail))
        finally:
            comm_obj.execute_egate_command("ib_enb_cell_disp enb=%s cell=%s" % (wts_gnb_id, instance_id), "EGATE>")

    def _wait_cell_sib(self, gnb_id, cell_id, sib_type, timeout):
        interval = 10
        retry_times = int(timeout) / interval
        while retry_times > 0:
            lb_output = comm_obj.execute_egate_command("ib_enb_cell_disp enb=%s cell=%s type=%s"
                                                       % (gnb_id, cell_id, sib_type), "EGATE>")
            if lb_output.count("information block is unknown"):
                retry_times = retry_times - 1
                time.sleep(interval)
            else:
                break
        if retry_times == 0:
            comm_obj.execute_egate_command("ib_enb_cell_disp enb=%s cell=%s" % (gnb_id, cell_id), "EGATE>")
            comm_obj.log_to_console_with_time_prefix("no %s from gnb%s cell%s" % (sib_type, gnb_id, cell_id),
                                                     level="WARN")
            raise Exception("no %s from gnb%s cell%s" % (sib_type, gnb_id, cell_id))

    def _wait_sibs_cmd(self, cell_id='all', timeout=120):
        # get cells lcrId
        self._setup_startup()
        try:
            cells_to_check = []
            if cell_id == "all":
                if builtin_obj.get_variable_value("${TEST NAME}") is not None:
                    builtin_obj.log("step: wait all cells sibs messages", console=False)
                else:
                    comm_obj.log_to_console_with_time_prefix("step: wait all cells sibs messages")
                scf = "/home/ute/scf.xml"
                self.admin_obj.get_current_scf_file(local_dir_path="/home/ute/", file_name="scf.xml",
                                                    export_type="configurationAndRuntimeObjects",
                                                    with_auto_configured_parameters=True,
                                                    connection=self.alias, timeout=60)
                commonxml_obj = CommonXML(scf)
                all_elements = commonxml_obj.get_elements(
                    "//*[matches(@class, '.*:NRCELL$')]/*[matches(@name, 'lcrId')]")
                for each_element in all_elements:
                    cells_to_check.append(commonxml_obj.get_element_text(each_element))
            else:
                cells_to_check = [cell_id]
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail, level="WARN")
            cells_to_check = ["1"]

        # wait SIBs
        if self.alias == "bts1":
            gnb_id = "2"
        else:
            gnb_id = "3"
        start_time = datetime.datetime.now()
        try:
            for lcr_id in cells_to_check:
                if builtin_obj.get_variable_value("${TEST NAME}") is not None:
                    builtin_obj.log("step: wait gnb{} cell{} sibs messages".format(gnb_id, lcr_id), console=False)
                else:
                    comm_obj.log_to_console_with_time_prefix("step: wait gnb{} cell{} sibs messages".format(
                        gnb_id, lcr_id))
                self._wait_cell_sib(gnb_id=gnb_id, cell_id=lcr_id, sib_type="sib1", timeout=timeout)
                self._wait_cell_sib(gnb_id=gnb_id, cell_id=lcr_id, sib_type="sib2", timeout=timeout)
            endtime = datetime.datetime.now()
            time_elapse = (endtime - start_time).seconds
            if builtin_obj.get_variable_value("${TEST NAME}") is not None:
                builtin_obj.log("step: wait sibs messages cost %s sec" % time_elapse, console=False)
            else:
                comm_obj.log_to_console_with_time_prefix("step: wait sibs messages cost %s sec" % time_elapse)
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)

    def _wait_mib(self, instance_id, lcr_id):
        wts_gnb_id = 2 if self.alias == "bts1" else 3
        comm_obj.log_to_console_with_time_prefix("step: wait cell{} mib".format(instance_id))
        start_time = datetime.datetime.now()
        try:
            comm_obj.egate_console_log_should_contain(
                "/opt/wts/latest/egate_console.log",
                ["eNB {} cell {}: MasterInformationBlock-NR Updated".format(wts_gnb_id, lcr_id)],
                timeout=300, interval=10)
            endtime = datetime.datetime.now()
            time_elapse = (endtime - start_time).seconds
            comm_obj.log_to_console_with_time_prefix("step: wait cell{} mib cost {} sec".format(
                instance_id, time_elapse))
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix("fail to wait cell{} mib".format(
                instance_id), level="WARN")
            self._precategory_startup("[Pre-Category][MIB Message Not Received][GNB(%s)-cell(%s) not receive MIB]"
                                      % (wts_gnb_id, lcr_id))
            raise Exception("fail to wait cell{} mib: {}".format(instance_id, detail))

    def _kill_edaemon_and_egate(self):
        comm_obj.execute_cmd_on_pc("sudo pkill edaemon")
        comm_obj.execute_cmd_on_pc("sudo pkill egate")
        comm_obj.execute_cmd_on_pc("ps -ef | grep -e edaemon -e egate")
        comm_obj.execute_cmd_on_pc("sudo rm -rf /opt/wts/latest/*.log*")

    def _configure_and_start_wts(self, cfg_file, debug_log_level):
        self._configure_sctp()
        comm_obj.log_to_console_with_time_prefix("step: configure wts with %s and start wts" % cfg_file)
        comm_obj.execute_cmd_on_pc("cd /opt/wts/latest")
        comm_obj.execute_cmd_on_pc("sudo ./edaemon --port 22222")
        time.sleep(3)
        comm_obj.execute_cmd_on_pc("./egate --port 20000")
        time.sleep(3)  # can't execute too fast, otherwise maybe no sib for some cell
        try:
            comm_obj.execute_egate_command(command="cfg file=%s" % cfg_file,
                                           pass_regexp="CHANGE STATE: STARTED",
                                           fail_regexp="Failed to execute",
                                           timeout=120,
                                           pf_mode=1)
        except Exception:
            detail = traceback.format_exc()
            raise Exception("fail to execute cfg file=%s: %s" % (cfg_file, detail))
        comm_obj.execute_egate_command("debug_log level=%s" % debug_log_level)
        comm_obj.execute_egate_command("debug_log", "Max number")
        # PR660109[Airscale][TDD][AP_LO][GNB_LO]pdu session setup failed due to failure-in-radio-interface-procedure
        comm_obj.execute_egate_command("uec_param id=1 srb_reordering_enabled=on")

    def _auto_setup_nsa_link_by_x2_peers(self, cfg_file):
        if self._check_x2_peers_in_cfg_file(cfg_file):
            wts_enb_id, wts_gnb_id = self._get_enb_gnb_id_from_wts_file(cfg_file)
            comm_obj.execute_egate_command("enb_x2_link_up enb=%s target=%s" % (wts_enb_id, wts_gnb_id))
            comm_obj.log_to_console_with_time_prefix(
                "step: setup enb x2 link up by enb_x2_link_up enb=%s target=%s" %
                (wts_enb_id, wts_gnb_id))
        else:
            comm_obj.log_to_console_with_time_prefix("step: setup enb x2 link up by x2_peers=all")
            pass

    def _setup_x2_link(self, cfg_file):
        if self._check_x2_peers_in_cfg_file(cfg_file):
            wts_gnb_id = 2 if self.alias == "bts1" else 3
            try:
                start_time = datetime.datetime.now()
                comm_obj.log_to_console_with_time_prefix(
                    "step: setup x2 link by enb_x2_link_up enb=1 target=%s" % wts_gnb_id)
                comm_obj.execute_egate_command("enb_x2_link_up enb=1 target=%s" % wts_gnb_id,
                                               "ENB-1: X2AP Link with GNB-{} .* is up".format(wts_gnb_id),
                                               timeout=60)
                endtime = datetime.datetime.now()
                time_elapse = (endtime - start_time).seconds
                comm_obj.log_to_console_with_time_prefix(
                    "step: setup x2 link cost {} sec".format(time_elapse))
            except Exception:
                detail = traceback.format_exc()
                comm_obj.log_to_console_with_time_prefix("fail to setup x2 link", level="WARN")
                self._precategory_startup("[Pre-Category][Establish X2 Link Fail][Between LTE ENB and GNB(%s)]" %
                                          self.alias)
                raise Exception("fail to setup x2 link")
        else:
            comm_obj.log_to_console_with_time_prefix("step: setup x2 link by x2_peers=all")
            pass

    def _check_x2_peers_in_cfg_file(self, cfg_file):
        with open(cfg_file, 'r') as f_obj:
            for line in f_obj:
                if line.lower().count("set_enb"):
                    for sub_line in line.lower().split(" "):
                        if sub_line.count("x2_peers"):
                            if sub_line.count("none"):
                                return True
                            else:
                                return False

    def _get_enb_gnb_id_from_wts_file(self, file_path):
        wts_enb_id = 1
        wts_gnb_id = 2
        with open(file_path, 'r') as f_obj:
            for line in f_obj:
                match_result = re.match(r"set_enb\s*id=(\d+)", line, re.I)
                if match_result:
                    wts_enb_id = match_result.group(1)
                    break
            for line in f_obj:
                match_result = re.match(r"set_gnb\s*id=(\d+)", line, re.I)
                if match_result:
                    wts_gnb_id = match_result.group(1)
                    break
        return wts_enb_id, wts_gnb_id

    def _configure_sctp(self):
        builtin_obj.log("step: configure SCTP on WTS")
        comm_obj.execute_cmd_on_pc("sudo sysctl -w net.sctp.sack_timeout=20")
        comm_obj.execute_cmd_on_pc("sudo sysctl -w net.sctp.rto_min=200")
        comm_obj.execute_cmd_on_pc("sudo sysctl -w net.sctp.rto_initial=200")
        comm_obj.execute_cmd_on_pc("sudo sysctl -w net.sctp.rto_max=800")
        builtin_obj.log("step: configure SCTP on AP")
        fsm_obj = ute_fsmaccess()
        fsm_obj.setup_wts_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#")
        fsm_obj.execute_command_on_wts("sysctl -w net.sctp.sack_timeout\\=20", alias=self.alias)
        fsm_obj.execute_command_on_wts("sysctl -w net.sctp.rto_min\\=200", alias=self.alias)
        fsm_obj.execute_command_on_wts("sysctl -w net.sctp.rto_initial\\=200", alias=self.alias)
        fsm_obj.execute_command_on_wts("sysctl -w net.sctp.rto_max\\=800", alias=self.alias)
        fsm_obj.teardown_wts_fsm_access(alias=self.alias)

    def _get_link_status(self, param):
        """
        param: LTEENB:x2LinkStatus or SERVEDAMF:ngLinkStatus
        get all values of param, and remove duplicate
        """
        self._setup_startup()
        param_values = set()
        try:
            scf = "/home/ute/scf.xml"
            self.admin_obj.get_current_scf_file(local_dir_path="/home/ute/", file_name="scf.xml",
                                                export_type="configurationAndRuntimeObjects",
                                                with_auto_configured_parameters=True,
                                                connection=self.alias, timeout=60)
            commonxml = CommonXML(scf)
            xpath = comm_obj.match_to_xpath(param.partition(":")[0] + "-.*:" + param.partition(":")[-1])
            all_elements = commonxml.get_elements("text|%s" % xpath[0])
            param_values.update(commonxml.get_element_text(element) for element in all_elements)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        finally:
            return list(param_values)

    def _wait_status(self, param, target_status, timeout="300"):
        comm_obj.log_to_console_with_time_prefix("step: wait {}={}".format(param, target_status))
        start_time = datetime.datetime.now()
        interval = 10
        retry_times = int(timeout) / interval
        for _ in range(int(retry_times)):
            status_list = self._get_link_status(param)
            if len(status_list) == 1 and status_list[0].lower() == target_status.lower():
                endtime = datetime.datetime.now()
                time_elapse = (endtime - start_time).seconds
                comm_obj.log_to_console_with_time_prefix(
                    "step: wait {}={} cost {} sec".format(param, target_status, time_elapse))
                break
            else:
                retry_times = retry_times - 1
                time.sleep(interval)
        else:
            comm_obj.log_to_console_with_time_prefix("fail to wait {}={} in {}".format(
                param, target_status, self.alias.upper()), level="WARN")
            raise Exception("fail to wait {}={} in {}".format(param, target_status, self.alias.upper()))

    def _check_sim_state(self, timeout=300):
        comm_obj.log_to_console_with_time_prefix("step: wait egate state active")
        start_time = datetime.datetime.now()
        retry_times = timeout/10
        while retry_times > 0:
            try:
                comm_obj.execute_egate_command("state_sim_disp", "The state is ACTIVE", timeout=10)
                break
            except Exception:
                detail = traceback.format_exc()
                retry_times = retry_times - 1
        if retry_times == 0:
            comm_obj.log_to_console_with_time_prefix("fail to wait egate state active", level="WARN")
            raise Exception("fail to check state_sim_disp: %s" % detail)
        endtime = datetime.datetime.now()
        time_elapse = (endtime - start_time).seconds
        comm_obj.log_to_console_with_time_prefix("step: wait egate state active cost %s sec" % time_elapse)

    def _establish_x2_and_wait_up(self, cfg_file):
        self._check_sim_state()
        self._setup_x2_link(cfg_file)
        self._wait_status("LTEENB:x2LinkStatus", "available")

    def _download_scf(self):
        self._setup_startup()
        scf = "/home/ute/scf.xml"
        try:
            self.admin_obj.get_current_scf_file(local_dir_path="/home/ute/", file_name="scf.xml",
                                                export_type="configurationAndRuntimeObjects",
                                                with_auto_configured_parameters=True,
                                                timeout=60,
                                                connection=self.alias)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail, level="WARN")
        return scf

    def _evaluate_network_type(self):
        """
        if gNbCuType=SA, return SA;
        if gNbCuType=NSA, return NSA;
        if gNbCuType=SA+NSA and cellDepType under all unlocked cells are SA, then return SA;
        if gNbCuType=SA+NSA and cellDepType under all unlocked cells are NSA, then return NSA;
        if gNbCuType=SA+NSA and cellDepType under all unlocked cells are SA+NSA, then return SA+NSA;
        if gNbCuType=SA+NSA and cellDepType are different among unlocked cells, then retrun SA+NSA
        """
        scf = self.scf_for_analysis
        commonxml_obj = CommonXML(scf)
        cu_type_xpath = comm_obj.match_to_xpath("gNbCuType")
        cu_type_value = xml_obj.read_xml(scf, "text|%s" % cu_type_xpath[0])
        if cu_type_value == "SA+NSA":
            cells_deptype = []
            all_elements = commonxml_obj.get_elements(
                "//*[@name='administrativeState'][text()='Unlocked']/../*[@name='cellDepType']")
            for element in all_elements:
                cells_deptype.append(commonxml_obj.get_element_text(element))
            cells_deptype = list(set(cells_deptype))  # remove duplicate

            if len(cells_deptype) == 1:
                actual_network_type = cells_deptype[0]
            else:
                actual_network_type = "SA+NSA"
        else:
            actual_network_type = cu_type_value
        return actual_network_type

    def _get_element_value(self, element, xpath):
        """
        return None if fail to get the value
        """
        value = None
        try:
            value = xml_obj.read_xml(element, xpath)
        except Exception:
            pass
        return value

    def _get_cells_info(self, cell_type="NRCELL", scf=None):
        cells_info = []
        if scf is None:
            scf = self._download_scf()
        try:
            commonxml_obj = CommonXML(scf)
            all_elements = commonxml_obj.get_elements("//*[matches(@class, '.*:{}$')]".format(cell_type))
            for each_element in all_elements:
                cell = {}
                dn = commonxml_obj.get_element_attribute(each_element, "distName")
                instance_id = dn.rpartition("-")[-1]
                each_element = commonxml_obj.element_to_string(each_element)
                cell["instance_id"] = instance_id
                cell["administrativeState"] = self._get_element_value(each_element,
                                                                      "text|//*[@name='administrativeState']")
                cell["cellDepType"] = self._get_element_value(each_element, "text|//*[@name='cellDepType']")
                cell["lcrid"] = self._get_element_value(each_element, "text|//*[@name='lcrId']")
                cell["sCellOnlyFr2Sa"] = self._get_element_value(each_element, "text|//*[@name='sCellOnlyFr2Sa']")
                cell["physCellId"] = self._get_element_value(each_element, "text|//*[@name='physCellId']")
                cells_info.append(cell)
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix("fail to get cells info", level="WARN")
            raise Exception("fail to get cells info: {}".format(detail))
        return cells_info

    # def _get_rat_type(self, scf):
    #     commonxml_obj = CommonXML(scf)
    #     nrbts = commonxml_obj.get_elements("//*[matches(@class, '.*:NRBTS$')]")
    #     lnbts = commonxml_obj.get_elements("//*[matches(@class, '.*:LNBTS$')]")
    #     if len(nrbts) == 1 and len(lnbts) == 1:
    #         rat_type = "SRAN"
    #     elif len(nrbts) == 1:
    #         rat_type = "5g"
    #     elif len(lnbts) == 1:
    #         rat_type = "lte"
    #     else:
    #         raise Exception("fail to get rat type")
    #
    # def _get_configuration_info(self, scf=None):
    #     config_info = {}
    #     if scf is None:
    #         scf = self._download_scf()
    #     config_info["rat_type"] = self._get_rat_type(scf)
    #     config_info["NRCELL"] = self._get_cells_info("NRCELL")
    #     config_info["LNCEL"] = self._get_cells_info("LNCEL")
    #     return config_info

    def _get_mplaneonly_flag(self):
        result = {}
        # download iphy.xml
        try:
            fsm_obj = ute_fsmaccess()
            fsm_obj.setup_wts_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#")
            fsm_obj.get_wts_file("/ffs/run/simmode/iphy.xml", "/home/ute/iphy.xml", alias=self.alias)
        except Exception as _err:
            builtin_obj.log("fail with {}".format(_err))
        finally:
            fsm_obj.teardown_wts_fsm_access(alias=self.alias)

        # parse iphy.xml and get MPlaneOnly flags for each cell (identify with phy_cell_id)
        tree = ET.parse("/home/ute/iphy.xml")
        root = tree.getroot()
        for vcell_list in root.findall('.//vcellList'):
            for vcell in vcell_list.findall('vcell'):
                phy_cell_id = vcell.find('phy_cell_id').text
                mplane_only = vcell.find('MPlaneOnly')
                mplane_only_value = mplane_only.text if mplane_only is not None else "false"
                result[phy_cell_id] = mplane_only_value
        builtin_obj.log("pci and mplaneonly mapping:{}".format(result))
        return result

    def _wait_for_gnb_onair(self, cfg_file):
        result = False
        try:
            self._start_to_capture_infomodel_log(alias=self.alias)
            actual_network_type = self._evaluate_network_type()
            # handle ng link and x2 link
            if actual_network_type == "SA":
                self._wait_ng_link_up()
            elif actual_network_type == "NSA":
                self._establish_x2_and_wait_up(cfg_file)
            elif actual_network_type == "SA+NSA":
                x2ng_flag = builtin_obj.get_variable_value("${SETUP_X2_BEFORE_NG}")
                if bool(x2ng_flag) is True:
                    self._establish_x2_and_wait_up(cfg_file)
                    self._wait_ng_link_up()
                else:
                    self._wait_ng_link_up()
                    self._establish_x2_and_wait_up(cfg_file)

            # check cell state and mib sibs
            cells_info = self._get_cells_info()
            cells_mplaneonly_flag = self._get_mplaneonly_flag()
            for cell in cells_info:
                cell_id = cell["instance_id"]
                lcrid = cell["lcrid"]
                physCellId = cell["physCellId"]
                mplaneonly_flag = cells_mplaneonly_flag[physCellId]
                if cell["administrativeState"].lower() == "locked":
                    self._wait_cell_validated(cell_id, alias=self.alias)
                elif cell["administrativeState"].lower() == "unlocked":
                    self._wait_cell_onair(cell_id, alias=self.alias)
                    if mplaneonly_flag == "false":
                        if cell["cellDepType"] == "SA" or cell["cellDepType"] == "SA+NSA":
                            if cell["sCellOnlyFr2Sa"] == "true" and cell["cellDepType"] == "SA":
                                self._wait_mib(cell_id, lcrid)
                            else:
                                self._wait_mib(cell_id, lcrid)
                                self._wait_sibs(cell_id, lcrid)
                        elif cell["cellDepType"] == "NSA":
                            self._wait_mib(cell_id, lcrid)
                        else:
                            raise Exception("not support %s yet, pls contact TA core team to support it"
                                            % cell["cellDepType"])
                    else:
                        builtin_obj.log("cell{} is MPlaneOnly, can't attach any UE".format(cell_id), level="WARN")
                else:
                    raise Exception("not support NRCELL:administrativeState={}, please contact TA core team".format(
                        cell["administrativeState"]))
            builtin_obj.log("gnb is already onair")
            result = True
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        finally:
            try:
                self._stop_to_capture_infomodel_log(tag="", save=False, alias=self.alias)
            except Exception:
                detail = traceback.format_exc()
                builtin_obj.log(detail)
        return result

    def _check_cell_state(self, cell_type="NRCELL"):
        cells_info = self._get_cells_info(cell_type)
        for cell in cells_info:
            cell_id = cell["instance_id"]
            lcrid = cell["lcrid"]
            if cell["administrativeState"].lower() == "locked":
                self._wait_cell_validated(cell_id, alias=self.alias)
            elif cell["administrativeState"].lower() == "unlocked":
                self._wait_cell_onair(cell_id, alias=self.alias)
            else:
                raise Exception("not support {}:administrativeState={}, please contact TA core team".format(
                    cell_type, cell["administrativeState"]))

    def _wait_bts_onair(self):
        self._setup_startup()
        rru_startup_time = 900
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        result = False
        try:
            self._start_to_capture_infomodel_log(alias=self.alias)
            if bbu_type.count("ASOE"):
                self._wait_smod_startup()
            else:
                self._wait_bbmod_startup()
            self._wait_all_rrus_detected(rru_startup_time)
            commonxml_obj = CommonXML(self.scf_for_analysis)
            # check NR
            if len(commonxml_obj.get_elements("//*[matches(@class, '.*:NRBTS$')]")):
                actual_network_type = self._evaluate_network_type()
                if actual_network_type == "SA":
                    self._wait_status("SERVEDAMF:ngLinkStatus", "active")
                elif actual_network_type == "NSA":
                    self._wait_status("LTEENB:x2LinkStatus", "available")
                elif actual_network_type == "SA+NSA":
                    self._wait_status("SERVEDAMF:ngLinkStatus", "active")
                    self._wait_status("LTEENB:x2LinkStatus", "available")
                self._check_cell_state("NRCELL")
            # check LTE
            if len(commonxml_obj.get_elements("//*[matches(@class, '.*:LNBTS$')]")):
                self._wait_status("LNMME:s1LinkStatus", "available")
                self._check_cell_state("LNCEL")
            result = True
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        finally:
            try:
                self._stop_to_capture_infomodel_log(tag="", save=False, alias=self.alias)
            except Exception:
                detail = traceback.format_exc()
                builtin_obj.log(detail)
        return result

    def _wait_gnb_configured_state(self, rru_startup_time):
        self._setup_startup()
        rru_startup_time = int(rru_startup_time)
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        result = False
        try:
            self._kill_edaemon_and_egate()
            self._start_to_capture_infomodel_log(alias=self.alias)
            if bbu_type.count("ASOE"):
                self._wait_smod_startup()
            else:
                self._wait_bbmod_startup()
            self._wait_all_rrus_detected(rru_startup_time)
            self._wait_gnb_configured()
            builtin_obj.log("gnb is already configured")
            result = True
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        finally:
            try:
                self._stop_to_capture_infomodel_log(tag="", save=False, alias=self.alias)
            except Exception:
                pass
        return result

    def _power_off_ap(self):
        comm_obj.log_to_console_with_time_prefix("step: power off Airphone")
        tl = builtin_obj.get_variable_value("${tl}")
        pdu_obj = pdu()
        ap_model = tl.ues[0].l1.common_units[0].pdu_port.pdu
        ap_port = tl.ues[0].l1.common_units[0].pdu_port.port_no
        # power off AP
        builtin_obj.log("step: ap_model=%s" % ap_model)
        pdu_obj.setup_pdu(ap_model, alias="ap", timeout=30)
        try:
            pdu_obj.power_off(ap_port, pdu_device="ap")
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log("fail to power off airphone: %s" % detail)

    def _get_pdu_info(self, hw):
        tl = builtin_obj.get_variable_value("${tl}")
        if hw == "bts1":
            pdu_model = tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu
            pdu_port = tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no
        elif hw == "bts2":
            pdu_model = tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu
            pdu_port = tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.port_no
        elif hw == "ap":
            pdu_model = tl.ues[0].l1.common_units[0].pdu_port.pdu
            pdu_port = tl.ues[0].l1.common_units[0].pdu_port.port_no
        else:
            raise Exception("Not support {}".format(hw))
        builtin_obj.log("debug: hw={}, pdu_model={}, pdu_port={}".format(hw, pdu_model, pdu_port))
        return pdu_model, pdu_port

    def _power_off(self, hw):
        hw = hw.lower()
        pdu_model, pdu_port = self._get_pdu_info(hw)
        pdu_obj = pdu()
        builtin_obj.log("debug: power off {}".format(hw))
        pdu_obj.setup_pdu(pdu_model, alias=hw, timeout=30)
        try:
            pdu_obj.power_off(pdu_port, pdu_device=hw)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log("fail to power off {}: {}".format(hw, detail))

    def _power_on(self, hw):
        hw = hw.lower()
        pdu_model, pdu_port = self._get_pdu_info(hw)
        pdu_obj = pdu()
        builtin_obj.log("debug: power on {}".format(hw))
        pdu_obj.setup_pdu(pdu_model, alias=hw, timeout=30)
        try:
            pdu_obj.power_on(pdu_port, pdu_device=hw)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log("fail to power on {}: {}".format(hw, detail))

    def _restart_gnb_and_airphone(self, gnb_num):
        gnb_num = int(gnb_num)
        tl = builtin_obj.get_variable_value("${tl}")
        bts2_ip = builtin_obj.get_variable_value("${BTS2_IP}")
        if tl is not None:
            # power off AP and GNBs
            comm_obj.log_to_console_with_time_prefix("step: cold reset {}GNB and Airphone".format(gnb_num))
            self._power_off("ap")
            self._power_off("bts1")
            if gnb_num == 2:
                self._power_off("bts2")
            # check restart
            self._wait_restart("192.168.200.1", timeout=60)
            self._wait_restart("192.168.255.1", timeout=60)
            if gnb_num == 2:
                self._wait_restart(bts2_ip, timeout=60)
            # power on AP and gnbs
            self._power_on("bts1")
            if gnb_num == 2:
                self._power_on("bts2")
            self._power_on("ap")
        else:
            comm_obj.log_to_console_with_time_prefix("step: reboot Airphone")
            fsm_obj = ute_fsmaccess()
            fsm_obj.setup_wts_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#")
            fsm_obj.execute_command_on_wts("step: reboot")
            fsm_obj.teardown_wts_fsm_access(alias=self.alias)
            comm_obj.reboot_bts()

    def _configuration_reset_if_in_commissioned_state(self):
        self._setup_startup()
        try:
            self._start_to_capture_infomodel_log(alias=self.alias)
            obj = self.info_obj.get_infomodel_object("//MRBTS_M-*", timeout=20, alias=self.alias)
            if obj.stateInfo.proceduralState.lower() == "commissioned":
                comm_obj.log_to_console_with_time_prefix("GNB in %s state, configuration reset it"
                                                         % obj.stateInfo.proceduralState)
                try:
                    self.admin_obj.reset_configuration(alias=self.alias, timeout=400)
                except Exception:
                    detail = traceback.format_exc()
                    builtin_obj.log(detail)
                #                     raise Exception(detail)
                finally:
                    self._wait_bbmod_startup()
                    self.info_obj.query_infomodel("//MRBTS_M-* is [stateInfo.proceduralState=NotCommissioned]",
                                                  timeout=100, alias=self.alias)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        #             raise Exception("fail to configuration reset gNB")
        finally:
            self._stop_to_capture_infomodel_log(tag="", save=False, alias=self.alias)

    def _judge_sw_updated(self):
        fsm_obj = ute_fsmaccess()
        fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#",
                                     host="192.168.255.129")
        fsm_obj.setup_wts_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#")
        try:
            fsm_obj.get_enb_swconfig_file("/tmp/gnb_swconfig.txt", alias=self.alias)
            fsm_obj.get_enb_file("/ffs/run/config/Role.txt", "/tmp/Role.txt", alias=self.alias)
            fsm_obj.get_wts_file("/ffs/run/swconfig.txt", "/tmp/ap_swconfig.txt", alias=self.alias)
            sw_updated = False
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
            sw_updated = True
        finally:
            fsm_obj.teardown_enb_fsm_access(alias=self.alias)
            fsm_obj.teardown_wts_fsm_access(alias=self.alias)
        return sw_updated

    def _check_stateinfo_change_or_not(self, mod_type):
        try:
            mod_info = self.info_obj.query_infomodel("get list //%s-*" % mod_type, timeout=300, alias=self.alias)
            self.stateinfo_change_flag = True if "stateInfo" not in mod_info[0].keys() else False
        except Exception as e:
            raise Exception("CNI-61110, check infomodel %s stateinfo is removed,error: %s"
                            % (mod_type, e))


class startup_1(startup_base):
    def __init__(self):
        alias = "bts1"
        self.startup_base_instant_1 = startup_base(alias)

    def start_to_capture_infomodel_log(self):
        self.startup_base_instant_1._start_to_capture_infomodel_log(alias="default")

    def stop_to_capture_infomodel_log(self, tag="", timeout=60):
        self.startup_base_instant_1._stop_to_capture_infomodel_log(tag, save=True, alias="default", timeout=timeout)

    def get_all_cells_info(self, cell_type="NRCELL", scf=None):
        return self.startup_base_instant_1._get_cells_info(cell_type, scf)

    def cells_should_be_onair(self, cell_id="all", timeout="120", **kwargs):
        """This keyword is to check cell should be onair.

        | step1 | find which cells to be checked |
        | step2 | wait cells state onairdone |
        | step3 | wait sib1 and sib2 if check_sib is True |

        | Arguments  | Man.    | Default | Description |
        | cell_id    | No      | all     | which cells need to be checked |
        | timeout    | No      | 120     | timeout for wait sib1 and sib2 |
        | check_sib  | No      | True    | check sib1 and sib2 if True, don't check if False. That's only
                                           available during ET testing with default True. |

        Example:
        | cells_should_be_onair |
        | cells_should_be_onair | 1 |
        | cells_should_be_onair | check_sib=${False} | # For ET
        """
        self.startup_base_instant_1._cells_should_be_onair(cell_id, timeout, alias="default", **kwargs)

    def cell_should_be_locked(self, cell_id):
        self.startup_base_instant_1._cell_adminstate_should_be(cell_id, "Locked", alias="default")

    def cell_should_be_unlocked(self, cell_id):
        self.startup_base_instant_1._cell_adminstate_should_be(cell_id, "Unlocked", alias="default")

    def kill_edaemon_and_egate(self):
        self.startup_base_instant_1._kill_edaemon_and_egate()

    def configure_and_start_wts(self, cfg_file, debug_log_level):
        self.startup_base_instant_1._configure_and_start_wts(cfg_file, debug_log_level)

    def wait_for_gnb_onair(self, cfg_file):
        return self.startup_base_instant_1._wait_for_gnb_onair(cfg_file)

    def wait_bts_onair(self):
        return self.startup_base_instant_1._wait_bts_onair()

    def wait_gnb_configured_state(self, rru_startup_time=300):
        return self.startup_base_instant_1._wait_gnb_configured_state(rru_startup_time=rru_startup_time)

    def restart_gnb_and_airphone(self, gnb_num=1):
        self.startup_base_instant_1._restart_gnb_and_airphone(gnb_num)

    def configuration_reset_gnb_if_in_commissioned_state(self):
        self.startup_base_instant_1._configuration_reset_if_in_commissioned_state()

    def judge_sw_updated(self):
        return self.startup_base_instant_1._judge_sw_updated()

    def get_rrus_from_iphy_xml(self, source_file_name='iphy', target_file_name='iphy'):
        return self.startup_base_instant_1._get_rrus_from_iphy_xml(source_file_name=source_file_name,
                                                                   target_file_name=target_file_name)


class startup_2(startup_base):
    def __init__(self):
        alias = "bts2"
        self.startup_base_instant_2 = startup_base(alias)

    def _setup_startup_bts2(self):
        self.startup_base_instant_2.bts_host = builtin_obj.get_variable_value('${BTS2_IP}')  # NG IP
        self.startup_base_instant_2.remote_host = builtin_obj.get_variable_value('${BTS2_PC_IP}')

    def start_to_capture_infomodel_log_bts2(self):
        self._setup_startup_bts2()
        self.startup_base_instant_2._start_to_capture_infomodel_log(alias="default_bts2")

    def stop_to_capture_infomodel_log_bts2(self, tag="", timeout=60):
        self._setup_startup_bts2()
        self.startup_base_instant_2._stop_to_capture_infomodel_log(tag, save=True, alias="default_bts2",
                                                                   timeout=timeout)

    def cells_should_be_onair_bts2(self, cell_id="all", timeout="120", check_sib=True):
        """This keyword is to check cell should be onair.

        | step1 | find which cells to be checked |
        | step2 | wait cells state onairdone |
        | step3 | wait sib1 and sib2 |


        | Arguments  | Man.    | Default | Description |
        | cell_id    | No      | all     | which cells need to be checked |
        | timeout    | No      | 120     | timeout for wait sib1 and sib2 |
        | check_sib  | No      | True    | check sib1 and sib2 if True, don't check if False |

        Example:
        | cells_should_be_onair_bts2 |
        | cells_should_be_onair_bts2 | 1 |
        | cells_should_be_onair_bts2 | check_sib=${False} |
        """
        self._setup_startup_bts2()
        self.startup_base_instant_2._cells_should_be_onair(cell_id, timeout, check_sib=check_sib, alias="default_bts2")

    def cell_should_be_locked_bts2(self, cell_id):
        self._setup_startup_bts2()
        self.startup_base_instant_2._cell_adminstate_should_be(cell_id, "Locked", alias="default_bts2")

    def cell_should_be_unlocked_bts2(self, cell_id):
        self._setup_startup_bts2()
        self.startup_base_instant_2._cell_adminstate_should_be(cell_id, "Unlocked", alias="default_bts2")

    def wait_gnb_configured_state_bts2(self, rru_startup_time=300):
        self._setup_startup_bts2()
        return self.startup_base_instant_2._wait_gnb_configured_state(rru_startup_time=rru_startup_time)

    def wait_for_gnb_onair_bts2(self, cfg_file):
        self._setup_startup_bts2()
        return self.startup_base_instant_2._wait_for_gnb_onair(cfg_file)

    def wait_bts_onair_bts2(self):
        self._setup_startup_bts2()
        return self.startup_base_instant_2._wait_bts_onair()


class startup(startup_1, startup_2):
    def __init__(self):
        startup_1.__init__(self)
        startup_2.__init__(self)


if __name__ == "__main__":
    obj = startup()
    help(obj)
