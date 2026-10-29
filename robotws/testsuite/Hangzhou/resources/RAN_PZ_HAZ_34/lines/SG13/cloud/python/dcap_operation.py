# -*- coding: UTF-8 -*-

import logging
import os
import time

from taf.sw.dcap.rd import rd


class dcap_operation():
    def __init__(self):
        self.rd = rd()
        self.host = None
        self.port = None
        self.username = None
        self.password = None
        self.rd_version = None
        self.secure = None
        self.alias = None

    def connect_to_dcap(self, host, port, username='dcapuser', password='dcapadmin!',
                        rd_version='dcapv3', secure=True, alias='dcap'):
        """
         | host | yes | dcap server ip address  |
         | port | yes | dcap server port  |
         | username | no | user name to log in dcap server  |
         | password | no | password to log in dcap server  |
         | rd_version | no | dcap api version   If user wants to run keywords from v2 version please pass
           rd_version=`dcapv2`
          If user wants to run keywords from v3 version please pass rd_version=`dcapv3`
          would suggest to use the latest version as those provide more info.|
         | secure | no | true for https, false for http |
         | alias | no | the instance alias |
         Return Value | Description |
        """
        self.rd.connect_to(host, port, username=username, password=password,
                           rd_version=rd_version, secure=secure, alias=alias)
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.rd_version = rd_version
        self.secure = secure
        self.alias = alias

    def create_bts_to_dcap(self, bts_web_ip, bts_web_port='443', bts_username='Nemuadmin', bts_password='nemuuser',
                           bts_alias='target_bts'):
        """
        | bts_web_ip | yes | bts ip  |
        | bts_web_port | yes | bts port  |
        | bts_username | no | bts user name  |
        | bts_password | no | bts password  |
        | bts_alias | no | alias for bts
        | alias | no | the instance alias, same as alias in Connect To DCAP Server
        | Return Value | Description |
        """
        btsinfo = self.rd.create_bts(host=bts_web_ip, port=bts_web_port, username=bts_username, password=bts_password,
                                     bts_alias=bts_alias, connection=self.alias)
        logging.info(btsinfo)
        return btsinfo

    def start_trace_in_dcap(self, bts_dic, tag='start_trace', force=True, gnb_trace_profile='dcap-lite-default',
                            enb_trace_profile=None, bts_trace_profile=None, vcu_trace_profile=None,
                            vdu_trace_profile=None,
                            gnb_custom_profile_list=None,
                            enb_custom_profile_list=None, vdu_custom_profile_list=None, vcu_custom_profile_list=None,
                            wait_for_activation=False, timeout=400):
        """
        | bts_dic | yes | bts info as dict type |
        | tag | no | the tag of this StartTraceBody. |
        | force | no | signifying whether the trace should
          force a shutdown of any previously running traces.
          Defaults to true.
          If the trace startup finds an ongoing trace and 'force' is
          set to false, the startup fails due to ongoing traces error.
          If the 'force' flag is set to true, the startup first shuts
          down any ongoing traces and then continues with the startup |
        | gnb_trace_profile | no | the id or name of the gNB (5G) start trace |
        | enb_trace_profile | no | the id or name of the LTE (ENB)  start trace|
        | bts_trace_profile | no | the id or name of the BTS start trace|
        | vcu_trace_profile | no | the id or name of the vCU start trace|
        | vdu_trace_profile | no | the id or name of the vDU start trace|
        | gnb_custom_profile_list | no | The gNB (5G) custom profile name list of the start trace to be started.
          e.g : [cp_5g, controlPlane5g, pmFiles5g, condor5gSyslog, SCF5g,
          L2Ps_Component, L2Lo_Component, L2HiRlc_Component, L2HiPdcp_Component,
          L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa, L2HiPdcp_Sherpa,
          bip_interface_mirroring, L1stream, Tracer_5g, l1IqTracer] |
        | enb_custom_profile_list | no | The LTE (ENB) custom profile name list of the start trace to be started.
          e.g : [lteTracer_4g, condor4gTti, condor4gAa, condor4gSyslog,
          pmFiles4g, scf4g, cp_4g, controlPlane4g, condor4gL2, l1Iq4g] |
        | vdu_custom_profile_list | The VDU custom profile name list of the start trace to be started.
          e.g : [snapshotVdu, L1StreamVdu, L2Ps_Component, L2Lo_Component, L2HiRlc_Component,
          L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa, L2HiPdcp_Sherpa] |
        | vcu_custom_profile_list | no | The VCU custom profile name list of the start trace to be started.
          e.g : [snapshotVcu, L2Ps_Component, L2Lo_Component, L2HiRlc_Component,
          L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa, L2HiPdcp_Sherpa] |
        | wait_for_activation | no | f user wants to confirm if the traces are started and it is in "running"
        state. pass wait_for_activation=True |

        | Return Value | Description |
        | trace_id | dcap trace id |
        """
        trace_info = self.rd.start_trace(bts=bts_dic, tag=tag, force=force, vcu_trace_profile=vcu_trace_profile,
                                         vdu_trace_profile=vdu_trace_profile, gnb_trace_profile=gnb_trace_profile,
                                         enb_trace_profile=enb_trace_profile, bts_trace_profile=bts_trace_profile,
                                         gnb_custom_profile=gnb_custom_profile_list,
                                         enb_custom_profile=enb_custom_profile_list,
                                         vdu_custom_profile=vdu_custom_profile_list,
                                         vcu_custom_profile=vcu_custom_profile_list,
                                         wait_for_activation=wait_for_activation,
                                         timeout=timeout, connection=self.alias)
        return trace_info

    def stop_trace_in_dcap(self, bts_ip):
        """
        stop trace under DCAP-LITE
        | bts_ip | yes | bts ip |
        | Return Value | Description |
        | dict with operation information
        """
        last_trace_id = self.get_last_trace_id(bts_ip=bts_ip)
        trace_info = self.get_trace_status(trace_id=last_trace_id)
        if trace_info["status"] != "ready":
            result = self.rd.stop_trace(trace_id=last_trace_id, connection=self.alias)
            return result

    def get_last_trace_id(self, bts_ip):
        """
        get last trace id
        | bts_ip | yes | bts ip |
        """
        last_trace_id = None
        trace_infos = self.rd.get_all_trace_info(connection=self.alias)
        logging.info("444 trace_infos in get_last_trace_id=".format(trace_infos))
        for trace_info in trace_infos:
            if "targets" in trace_info.keys():
                for target in trace_info["targets"]:
                    if bts_ip == target["host"]:
                        last_trace_id = trace_info['id']
                        break
        return last_trace_id

    def get_trace_status(self, trace_id):
        """
        get trace info under DCAP-LITE
        | bts_ip | yes | bts ip |
        """
        trace_info = self.rd.get_trace_info_by_id(trace_id=trace_id, connection=self.alias)
        return trace_info

    def check_trace_status(self, trace_id):
        status = self.get_trace_status(trace_id=trace_id)
        return status["results_available"]

    def download_trace_file(self, bts_ip, target_dir='/tmp', timeout=600):
        current_time = str(time.time())
        print(current_time)
        dcap_log_name = "dcap" + current_time + ".zip"
        target_dcap_log_path = os.path.join(target_dir, dcap_log_name)
        print(target_dcap_log_path)
        last_trace_id = self.get_last_trace_id(bts_ip=bts_ip)
        logging.info("111last_trace_id=".format(last_trace_id))
        print(last_trace_id)
        try:
            # for index in range(0, 60):
            trace_info = self.get_trace_status(trace_id=last_trace_id)
            print(trace_info)
            logging.info("222trace_info=".format(trace_info))
            if trace_info["status"] == "ready":
                trace_file_path = self.rd.get_results(target_dir=target_dcap_log_path, timeout=timeout,
                                                      connection=self.alias)
                print(trace_file_path)
                logging.info("333trace_file_path=".format(trace_file_path))
        except BaseException:
            logging.info(
                "download trace file failed with trace id:{}".format(last_trace_id))

    def get_all_bts_info(self):
        result = self.rd.get_all_bts_info(connection=self.alias)
        return result
