# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
import time
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import Vdu
from common_lib_aic import common_lib_aic
from robot.libraries.BuiltIn import BuiltIn
from urllib3.exceptions import InsecureRequestWarning
import traceback
import urllib3
urllib3.disable_warnings(InsecureRequestWarning)
comm_obj = common_lib_aic()
builtin_obj = BuiltIn()


class tti_trace_base_aic(object):
    def __init__(self, alias):
        self.alias = alias
        self.alias_cu = self.alias + "_cu_tti"
        self.alias_du = self.alias + "_du_tti"
        self.alias_du2 = self.alias + "_du2_tti"
        self.alias_du3 = self.alias + "_du3_tti"
        self.alias_du4 = self.alias + "_du4_tti"

    def _start_admin_cu(self):
        self.cu_host = builtin_obj.get_variable_value("${VCU_IP}")
        self.cu_obj = cu()
        if comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu):
            return
        bts_port, use_ssl = comm_obj.define_admin_port()
        cu_ping_ok = self._ping_ok(self.cu_host)
        if cu_ping_ok:
            self.cu_obj.connect_to(alias=self.alias_cu, port=bts_port, secure=use_ssl, host=self.cu_host,
                                   username="Nemuadmin", password="Nokia@123")
        else:
            self.cu_obj.connect_to(alias=self.alias_cu, port=bts_port, secure=use_ssl, host="192.168.100.129",
                                   username="Nemuadmin", password="Nokia@123")

    def _stop_admin_cu(self):
        try:
            if comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu):
                self.cu_obj.disconnect(connection=self.alias_cu)
        except Exception:
            pass

    def _start_admin_du(self, du_identity=None):
        self.du_host = builtin_obj.get_variable_value("${VDU_IP}")
        self.du2_host = builtin_obj.get_variable_value("${VDU2_IP}")
        self.du3_host = builtin_obj.get_variable_value("${VDU3_IP}")
        self.du4_host = builtin_obj.get_variable_value("${VDU4_IP}")
        self.du_obj = Vdu()
        bts_port, use_ssl = comm_obj.define_admin_port()
        if du_identity == "du2":
            if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du2):
                return
            du2_ping_ok = self._ping_ok(self.du2_host)
            if du2_ping_ok:
                self.du_obj.connect_to(host=self.du2_host, port=bts_port, username="Nemuadmin", password="Nokia@123",
                                       secure=use_ssl, connection_name=self.alias_du2)
            else:
                builtin_obj.log("du2 ip ping nok")
        elif du_identity == "du3":
            if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du3):
                return
            du3_ping_ok = self._ping_ok(self.du3_host)
            if du3_ping_ok:
                self.du_obj.connect_to(host=self.du3_host, port=bts_port, username="Nemuadmin", password="Nokia@123",
                                       secure=use_ssl, connection_name=self.alias_du3)
            else:
                builtin_obj.log("du3 ip ping nok")
        elif du_identity == "du4":
            if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du4):
                return
            du4_ping_ok = self._ping_ok(self.du4_host)
            if du4_ping_ok:
                self.du_obj.connect_to(host=self.du4_host, port=bts_port, username="Nemuadmin", password="Nokia@123",
                                       secure=use_ssl, connection_name=self.alias_du4)
            else:
                builtin_obj.log("du4 ip ping nok")
        else:
            if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du):
                return
            du_ping_ok = self._ping_ok(self.du_host)
            if du_ping_ok:
                self.du_obj.connect_to(host=self.du_host, port=bts_port, username="Nemuadmin", password="Nokia@123",
                                       secure=use_ssl, connection_name=self.alias_du)
            else:
                builtin_obj.log("du ip ping nok")

    def _stop_admin_du(self, du_identity=None):
        try:
            if du_identity == "du2":
                if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du2):
                    self.du_obj.disconnect(vdu_connection=self.alias_du2)
            elif du_identity == "du3":
                if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du3):
                    self.du_obj.disconnect(vdu_connection=self.alias_du3)
            elif du_identity == "du4":
                if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du4):
                    self.du_obj.disconnect(vdu_connection=self.alias_du4)
            else:
                if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du):
                    self.du_obj.disconnect(vdu_connection=self.alias_du)
        except Exception:
            pass

    def _ping_ok(self, ip):
        out = comm_obj.execute_cmd_on_pc("ping %s -c 2" % ip)
        if out.count("100% packet loss"):
            return False
        else:
            return True

    def _set_route_for_ttitrace(self):
        """Use delta commission for parameter configuration or configure it into du_scf file directly"""
        pass

    def _update_uplane_trace_configuration_cu(self, conn, uplane_ip_addr="172.16.2.10", uplane_port=5678, dscp=0):
        """uplane_ip_addr: configure at eth8 with ip 172.16.2.10 currently"""
        builtin_obj.log("step: --- _update_uplane_trace_configuration_cu ---")
        self.cu_obj.update_uplane_configuration(uplane_ip_addr, uplane_port, dscp, connection=conn)
        # sleep for update finish
        time.sleep(3)
        uplan_config_ret = self.cu_obj.get_uplane_configuration(connection=conn)
        builtin_obj.log(uplan_config_ret)
        return uplan_config_ret

    def _start_tti_trace_cu(self, trace_type, target_component, uplane_port=5678):
        """
           :param str trace_type: Component/Sherpa (currently Sherpa not implement)
           :param str target_component: must be l2hiPdcp, set to L2-Hi will not be identified
           :param int uplane_port: 5678/5679
           :return tti_trace_id: tti_trace_id
        """
        builtin_obj.log("step: --- _start_tti_trace_cu ---")
        CU_TTITRACE_FLAG = builtin_obj.get_variable_value("${TTITRACE_FLAG_CU}")
        DU1_TTITRACE_FLAG = builtin_obj.get_variable_value("${TTITRACE_FLAG_DU1}")
        DU2_TTITRACE_FLAG = builtin_obj.get_variable_value("${TTITRACE_FLAG_DU2}")
        self._start_admin_cu()
        try:
            if str(CU_TTITRACE_FLAG).lower() == "true" and str(DU1_TTITRACE_FLAG).lower() == "false" and str(
                    DU2_TTITRACE_FLAG).lower() == "true":
                self._update_uplane_trace_configuration_cu(uplane_port=5679, conn=self.alias_cu)
            else:
                self._update_uplane_trace_configuration_cu(uplane_port=uplane_port, conn=self.alias_cu)
            cu_trace_id = self.cu_obj.start_uplane_trace_stream(trace_type=trace_type,
                                                                target_component=target_component,
                                                                connection=self.alias_cu)
            time.sleep(2)
            cu_trace_status = self.cu_obj.get_active_trace_streams(connection=self.alias_cu)
            builtin_obj.log("cu_trace_status: %s" % cu_trace_status)
            if str(CU_TTITRACE_FLAG).lower() == "true" and str(DU1_TTITRACE_FLAG).lower() == "false" and str(
                    DU2_TTITRACE_FLAG).lower() == "false":
                self._capture_tti_trace_log_aic(uplane_port=uplane_port, productVariant="cu")
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)
        finally:
            self._stop_admin_cu()
        return cu_trace_status[0]["trace_id"]

    def _stop_uplane_trace_stream_in_cu_admin_aic(self, trace_id, connection):
        builtin_obj.log("step: --- _stop_uplane_trace_stream_in_cu_admin_aic ---")
        self._start_admin_cu()
        try:
            self.cu_obj.stop_uplane_trace_stream(trace_id=trace_id, connection=connection)
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)
        finally:
            self._stop_admin_cu()

    def _update_uplane_trace_configuration_du(self, conn, uplane_ip_addr="172.16.2.10", uplane_port=55900, dscp=0):
        """uplane_ip_addr: configure at eth8 with ip 172.16.2.10 currently"""
        builtin_obj.log("step: --- _update_uplane_trace_configuration_du ---")
        try:
            opt_id = self.du_obj.update_uplane_configuration(uplane_ip_addr, uplane_port, dscp, vdu_connection=conn)
            opt_status = "ongoing"
            retry_times = 3
            while opt_status.lower() != "successful" and retry_times > 0:
                time.sleep(3)
                ret_status = self.du_obj.get_trs_api_operation_status(opt_id, vdu_connection=conn)
                opt_status = ret_status["status"]
                retry_times -= 1
            if opt_status.lower() != "successful":
                builtin_obj.log("operation_status:%s" % opt_status)
            time.sleep(2)
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)

    def _get_nrcell_dist_name(self, cell, conn):
        builtin_obj.log("step: --- _get_nrcell_dist_name ---")
        try:
            du_cell_list = []
            if cell == "All":
                du_cells_status_info = self.du_obj.get_vdu_cells_status(vdu_connection=conn)
                for i in du_cells_status_info:
                    du_cell_list.append(i["dist_names"]["config"])
            else:
                du_cell_list.append("MRBTS-1/NRBTS-1/NRCELL-%s" % cell)
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)
        finally:
            return du_cell_list

    def _start_tti_trace_du_aic(self, trace_type, target_component, cell, uplane_port, vdu_connection):
        """
           :param str trace_type: Component/Sherpa (currently Sherpa not implement)
           :param str target_component: must be L2HiRlc/L2Lo/L2Ps, set to L2-PS/5G-L2-PS will not be identified
           :param cell: cell id,like as 1,default value is all
           :param int uplane_port: 5678/5679
           :param vdu_connection: Unique identifier for a certain connections
           :return tti_trace status: if target_component=All, then return one list, otherwise tti_trace_id
           nr_cell_dn_list: list like as ["MRBTS-1/NRBTS-1/NRCELL-1"]
        """
        builtin_obj.log("step: --- _start_tti_trace_du_aic ---")
        du_num = builtin_obj.get_variable_value("${DU_NUMBER}")
        self._start_admin_du()
        if du_num != "du" and du_num >= "2du":
            self._start_admin_du(du_identity="du2")
        if du_num != "du" and du_num >= "3du":
            self._start_admin_du(du_identity="du3")
        if du_num != "du" and du_num >= "4du":
            self._start_admin_du(du_identity="du4")
        try:
            self._set_route_for_ttitrace()
            self._update_uplane_trace_configuration_du(uplane_port=uplane_port, conn=vdu_connection)
            du_cell_list = self._get_nrcell_dist_name(cell=cell, conn=vdu_connection)
            if target_component.lower() == "all":
                self.du_obj.start_uplane_trace_stream(trace_type=trace_type, target_component="L2Ps",
                                                      nr_cell_dn_list=du_cell_list, vdu_connection=vdu_connection)
                self.du_obj.start_uplane_trace_stream(trace_type=trace_type, target_component="L2Lo",
                                                      nr_cell_dn_list=du_cell_list, vdu_connection=vdu_connection)
                self.du_obj.start_uplane_trace_stream(trace_type=trace_type, target_component="L2HiRlc",
                                                      nr_cell_dn_list=du_cell_list, vdu_connection=vdu_connection)
            else:
                self.du_obj.start_uplane_trace_stream(trace_type=trace_type, target_component=target_component,
                                                      nr_cell_dn_list=du_cell_list, vdu_connection=vdu_connection)
            # wait for trace start
            time.sleep(2)
            trace_status = self.du_obj.get_active_trace_streams(vdu_connection=vdu_connection)
            builtin_obj.log("trace_status: %s" % trace_status)
            if vdu_connection.count("du"):
                du_identity = "du"
            if vdu_connection.count("du2"):
                du_identity = "du2"
            self._capture_tti_trace_log_aic(uplane_port, du_identity)
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)
        finally:
            if vdu_connection.count("du2"):
                self._stop_admin_du(du_identity="du2")
            else:
                self._stop_admin_du()
        if target_component.lower() == "all" or str(cell).lower() == "all":
            trace_status_id_list = []
            for i in trace_status:
                trace_status_id_list.append(i["trace_id"])
            return trace_status_id_list
        else:
            return trace_status[0]["trace_id"]

    def _capture_tti_trace_log_aic(self, uplane_port, du_identity="du", productVariant="du"):
        builtin_obj.log("step: --- _capture_tti_trace_log_aic in %s  ---" % productVariant)
        if productVariant == "cu":
            tti_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}") + "/cu_ttitrace"
        else:
            tti_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}") + "/du_ttitrace"
            if du_identity == "du2":
                tti_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}") + "/du2_ttitrace"
            elif du_identity == "du3":
                tti_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}") + "/du3_ttitrace"
            elif du_identity == "du4":
                tti_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}") + "/du4_ttitrace"
        comm_obj.execute_cmd_on_pc(cmd="mkdir %s" % tti_log_dir)
        comm_obj.execute_cmd_on_pc(cmd="chmod 777 %s" % tti_log_dir)
        if productVariant == "cu":
            comm_obj.execute_cmd_on_pc(
                cmd="sudo nohup tcpdump -v -ni eth9 port %s -C 150 -W 6 -vv "
                    "-w %s/ttitrace_cu.pcap 1>/dev/null 2>&1 &" % (uplane_port, tti_log_dir))
            comm_obj.log_to_console_with_time_prefix("... Start to capture tti trace in %s ..." % productVariant)
        else:
            comm_obj.execute_cmd_on_pc(
                cmd="sudo nohup tcpdump -v -ni eth9 port %s -C 150 -W 6 -vv "
                    "-w %s/ttitrace_%s.pcap 1>/dev/null 2>&1 &" % (uplane_port, tti_log_dir, du_identity))
            comm_obj.log_to_console_with_time_prefix("... Start to capture tti trace in %s ..." % du_identity)

    def _start_tti_trace_du(self, trace_type, target_component, cell):
        return self._start_tti_trace_du_aic(trace_type, target_component, cell, uplane_port=5678,
                                            vdu_connection=self.alias_du)

    def _start_tti_trace_du2(self, trace_type, target_component, cell):
        return self._start_tti_trace_du_aic(trace_type, target_component, cell, uplane_port=5679,
                                            vdu_connection=self.alias_du2)

    def _start_tti_trace_du3(self, trace_type, target_component, cell):
        return self._start_tti_trace_du_aic(trace_type, target_component, cell, uplane_port=5680,
                                            vdu_connection=self.alias_du3)

    def _start_tti_trace_du4(self, trace_type, target_component, cell):
        return self._start_tti_trace_du_aic(trace_type, target_component, cell, uplane_port=5681,
                                            vdu_connection=self.alias_du4)

    def _stop_uplane_trace_stream_in_du_admin_aic(self, trace_id, target_component, vdu_connection):
        builtin_obj.log("step: --- _stop_uplane_trace_stream_in_du_admin_aic ---")
        du_num = builtin_obj.get_variable_value("${DU_NUMBER}")
        self._start_admin_du()
        if du_num != "du" and du_num >= "2du":
            self._start_admin_du(du_identity="du2")
        if du_num != "du" and du_num >= "3du":
            self._start_admin_du(du_identity="du3")
        if du_num != "du" and du_num >= "4du":
            self._start_admin_du(du_identity="du4")
        try:
            if target_component.lower() == "all" or isinstance(trace_id, list):
                for id in trace_id:
                    self.du_obj.stop_uplane_trace_stream(trace_id=id, vdu_connection=vdu_connection)
                    time.sleep(1)
            else:
                self.du_obj.stop_uplane_trace_stream(trace_id=trace_id, vdu_connection=vdu_connection)
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)
        finally:
            if vdu_connection.count("du2"):
                self._stop_admin_du(du_identity="du2")
            elif vdu_connection.count("du3"):
                self._stop_admin_du(du_identity="du3")
            elif vdu_connection.count("du4"):
                self._stop_admin_du(du_identity="du4")
            else:
                self._stop_admin_du()

    def _stop_tti_trace_aic(self, uplane_port, productVariant="du"):
        builtin_obj.log("step: --- _stop_tti_trace_aic in %s ---" % productVariant)
        ret1 = comm_obj.execute_cmd_on_pc(cmd="ps -ef|grep ttitrace")
        builtin_obj.log(ret1)
        comm_obj.execute_cmd_on_pc(
            cmd="sudo ps aux|grep 'tcpdump -v -ni eth9 port %s'|awk '{print $2}'|xargs sudo kill -2" % uplane_port)
        # wait ttitrace killed successful
        time.sleep(1)
        ret2 = comm_obj.execute_cmd_on_pc(cmd="ps -ef|grep ttitrace")
        builtin_obj.log(ret2)

    def _stop_tti_trace_cu(self, trace_id):
        CU_TTITRACE_FLAG = builtin_obj.get_variable_value("${TTITRACE_FLAG_CU}")
        DU1_TTITRACE_FLAG = builtin_obj.get_variable_value("${TTITRACE_FLAG_DU1}")
        DU2_TTITRACE_FLAG = builtin_obj.get_variable_value("${TTITRACE_FLAG_DU2}")
        if str(CU_TTITRACE_FLAG).lower() == "true" and str(DU1_TTITRACE_FLAG).lower() == "false" and str(
                DU2_TTITRACE_FLAG).lower() == "false":
            self._stop_tti_trace_aic(uplane_port=5678, productVariant="cu")
        self._stop_uplane_trace_stream_in_cu_admin_aic(trace_id, connection=self.alias_cu)
        comm_obj.log_to_console_with_time_prefix("... Stop to capture tti trace in cu ...")

    def _stop_tti_trace_du(self, trace_id, target_component):
        self._stop_tti_trace_aic(uplane_port=5678)
        self._stop_uplane_trace_stream_in_du_admin_aic(trace_id, target_component, vdu_connection=self.alias_du)
        comm_obj.log_to_console_with_time_prefix("... Stop to capture tti trace in du1 ...")

    def _stop_tti_trace_du2(self, trace_id, target_component):
        self._stop_tti_trace_aic(uplane_port=5679)
        self._stop_uplane_trace_stream_in_du_admin_aic(trace_id, target_component, vdu_connection=self.alias_du2)
        comm_obj.log_to_console_with_time_prefix("... Stop to capture tti trace in du2 ...")

    def _stop_tti_trace_du3(self, trace_id, target_component):
        self._stop_tti_trace_aic(uplane_port=5680)
        self._stop_uplane_trace_stream_in_du_admin_aic(trace_id, target_component, vdu_connection=self.alias_du3)
        comm_obj.log_to_console_with_time_prefix("... Stop to capture tti trace in du3 ...")

    def _stop_tti_trace_du4(self, trace_id, target_component):
        self._stop_tti_trace_aic(uplane_port=5681)
        self._stop_uplane_trace_stream_in_du_admin_aic(trace_id, target_component, vdu_connection=self.alias_du4)
        comm_obj.log_to_console_with_time_prefix("... Stop to capture tti trace in du4 ...")

    def _decode_tti_trace_cu(self):
        self._download_and_install_tti_trace_decode_tool_aic()
        tti_dec_bin_dir = "/opt/tti-dec/tti-dec-bin"
        tti_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}") + "/cu_ttitrace"
        comm_obj.execute_cmd_on_pc("sudo rm %s/ttiTrace_*.csv" % tti_dec_bin_dir)
        pcap_size = comm_obj.execute_cmd_on_pc("ls -l %s/ttitrace_cu.pcap0 | awk '{print$5}'" % tti_log_dir)
        if int(pcap_size) / 1024 ** 2 > 100:
            comm_obj.log_to_console_with_time_prefix(
                "cu TTI Trace file size > 100M,please decode it by manual...", level="WARN")
        else:
            comm_obj.log_to_console_with_time_prefix("... Start to decode tti trace in cu ...")
            comm_obj.execute_cmd_on_pc("cd %s;python TtiTraceDecoder.py %s excelCsv" % (tti_dec_bin_dir, tti_log_dir),
                                       timeout=600)
            time.sleep(2)
            comm_obj.execute_cmd_on_pc("cp %s/ttiTrace_*.csv %s" % (tti_dec_bin_dir, tti_log_dir))
            comm_obj.log_to_console_with_time_prefix("... Decode cu tti trace done ...")

    def _decode_tti_trace_du_aic(self, du_identity):
        builtin_obj.log("--- start to decode tti trace ---")
        tti_dec_bin_dir = "/opt/tti-dec/tti-dec-bin"
        tti_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}") + "/du_ttitrace"
        if du_identity == "du2":
            tti_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}") + "/du2_ttitrace"
        elif du_identity == "du3":
            tti_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}") + "/du3_ttitrace"
        elif du_identity == "du4":
            tti_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}") + "/du4_ttitrace"
        comm_obj.execute_cmd_on_pc("sudo rm %s/ttiTrace_*.csv" % tti_dec_bin_dir)
        pcap_size = comm_obj.execute_cmd_on_pc("ls -l %s/ttitrace_%s.pcap0 | awk '{print$5}'" % (tti_log_dir,
                                                                                                 du_identity))
        if int(pcap_size) / 1024 ** 2 > 100:
            comm_obj.log_to_console_with_time_prefix(
                "%s TTI Trace file size > 100M,please decode it by manual..." % du_identity, level="WARN")
        else:
            comm_obj.log_to_console_with_time_prefix("... Start to decode tti trace in %s ..." % du_identity)
            comm_obj.execute_cmd_on_pc("cd %s;python TtiTraceDecoder.py %s excelCsv" % (tti_dec_bin_dir, tti_log_dir),
                                       timeout=600)
            time.sleep(2)
            comm_obj.execute_cmd_on_pc("cp %s/ttiTrace_*.csv %s" % (tti_dec_bin_dir, tti_log_dir))
            comm_obj.log_to_console_with_time_prefix("... Decode %s tti trace done ..." % du_identity)

    def _decode_tti_trace_du(self):
        self._download_and_install_tti_trace_decode_tool_aic()
        self._decode_tti_trace_du_aic(du_identity="du")

    def _decode_tti_trace_du2(self):
        self._download_and_install_tti_trace_decode_tool_aic()
        self._decode_tti_trace_du_aic(du_identity="du2")

    def _decode_tti_trace_du3(self):
        self._download_and_install_tti_trace_decode_tool_aic()
        self._decode_tti_trace_du_aic(du_identity="du3")

    def _decode_tti_trace_du4(self):
        self._download_and_install_tti_trace_decode_tool_aic()
        self._decode_tti_trace_du_aic(du_identity="du4")

    def _download_and_install_tti_trace_decode_tool_aic(self):
        builtin_obj.log("--- start to download tti trace tool ---")

        tool_base_link = "https://artifactory-espoo1.int.net.nokia.com/artifactory" \
                         "/mnp5g-central-public-local/System_Release/"
        du_version = builtin_obj.get_variable_value("${GNB_DU_VERSION}")
        du_version_release = du_version.split("_")[0]
        dec_tool_filename = du_version + "_tti-dec.deb"
        dec_tool_ver_link = tool_base_link + du_version_release + "/" + du_version + "/" + dec_tool_filename
        dec_tool_dest_path = "/home/ute/" + du_version
        comm_obj.execute_cmd_on_pc("sudo rm -rf %s" % dec_tool_dest_path)
        comm_obj.execute_cmd_on_pc(
            "wget --no-check-certificate %s -P %s" % (dec_tool_ver_link, dec_tool_dest_path), timeout="120")
        comm_obj.execute_cmd_on_pc("ls -l %s" % dec_tool_dest_path)
        comm_obj.execute_cmd_on_pc("chmod +x %s/%s" % (dec_tool_dest_path, dec_tool_filename))

        builtin_obj.log("--- start to install tti trace tool ---")
        comm_obj.execute_cmd_on_pc("pip install -U numpy pandas", timeout="120")
        time.sleep(2)
        comm_obj.execute_cmd_on_pc("cd %s;sudo dpkg -i %s" % (dec_tool_dest_path, dec_tool_filename), timeout="120")
        time.sleep(2)


class tti_trace_aic_gnb1(object):
    def __init__(self):
        alias = "gnb1"
        self.tti_trace_base_aic_instant_1 = tti_trace_base_aic(alias)

    def start_tti_trace_cu(self, target_component, trace_type):
        return self.tti_trace_base_aic_instant_1._start_tti_trace_cu(trace_type, target_component)

    def start_tti_trace_du(self, cell, target_component, trace_type):
        """This keyword is to start to capture tti trace in du
        | Arguments         | Man.  | Default   | Description |
        | target_component  | Yes   | L2Ps      | L2HiRlc/L2Lo/L2Ps (H/L/P is Capital)|
        | cell              | Yes   | All       | cell id like as 1 |
        | trace_type        | Yes   | Component | Component/Sherpa |
        """
        return self.tti_trace_base_aic_instant_1._start_tti_trace_du(trace_type, target_component, cell)

    def start_tti_trace_du2(self, cell, target_component, trace_type):
        """This keyword is to start to capture tti trace in du2
        | Arguments         | Man.  | Default   | Description |
        | target_component  | Yes   | L2Ps      | L2HiRlc/L2Lo/L2Ps (H/L/P is Capital)|
        | cell              | Yes   | All       | cell id like as 2 |
        | trace_type        | Yes   | Component | Component/Sherpa |
        """
        return self.tti_trace_base_aic_instant_1._start_tti_trace_du2(trace_type, target_component, cell)

    def start_tti_trace_du3(self, cell, target_component, trace_type):
        """This keyword is to start to capture tti trace in du3
        | Arguments         | Man.  | Default   | Description |
        | target_component  | Yes   | L2Ps      | L2HiRlc/L2Lo/L2Ps (H/L/P is Capital)|
        | cell              | Yes   | All       | cell id like as 2 |
        | trace_type        | Yes   | Component | Component/Sherpa |
        """
        return self.tti_trace_base_aic_instant_1._start_tti_trace_du3(trace_type, target_component, cell)

    def start_tti_trace_du4(self, cell, target_component, trace_type):
        """This keyword is to start to capture tti trace in du4
        | Arguments         | Man.  | Default   | Description |
        | target_component  | Yes   | L2Ps      | L2HiRlc/L2Lo/L2Ps (H/L/P is Capital)|
        | cell              | Yes   | All       | cell id like as 2 |
        | trace_type        | Yes   | Component | Component/Sherpa |
        """
        return self.tti_trace_base_aic_instant_1._start_tti_trace_du4(trace_type, target_component, cell)

    def stop_tti_trace_du(self, trace_id, target_component):
        self.tti_trace_base_aic_instant_1._stop_tti_trace_du(trace_id, target_component)

    def stop_tti_trace_du2(self, trace_id, target_component):
        self.tti_trace_base_aic_instant_1._stop_tti_trace_du2(trace_id, target_component)

    def stop_tti_trace_du3(self, trace_id, target_component):
        self.tti_trace_base_aic_instant_1._stop_tti_trace_du3(trace_id, target_component)

    def stop_tti_trace_du4(self, trace_id, target_component):
        self.tti_trace_base_aic_instant_1._stop_tti_trace_du4(trace_id, target_component)

    def decode_tti_trace_du(self):
        self.tti_trace_base_aic_instant_1._decode_tti_trace_du()

    def decode_tti_trace_du2(self):
        self.tti_trace_base_aic_instant_1._decode_tti_trace_du2()

    def decode_tti_trace_du3(self):
        self.tti_trace_base_aic_instant_1._decode_tti_trace_du3()

    def decode_tti_trace_du4(self):
        self.tti_trace_base_aic_instant_1._decode_tti_trace_du4()

    def stop_tti_trace_cu(self, trace_id):
        self.tti_trace_base_aic_instant_1._stop_tti_trace_cu(trace_id)

    def decode_tti_trace_cu(self):
        self.tti_trace_base_aic_instant_1._decode_tti_trace_cu()


class tti_trace_aic(tti_trace_aic_gnb1):
    def __init__(self):
        tti_trace_aic_gnb1.__init__(self)


if __name__ == "__main__":
    obj = tti_trace_aic()
    help(obj)
