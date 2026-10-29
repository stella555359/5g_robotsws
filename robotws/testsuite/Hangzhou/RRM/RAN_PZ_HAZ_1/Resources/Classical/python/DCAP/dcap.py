"""
:copyright: Nokia
:author: winnie.he
:contact: winnie.he@nokia-sbell.com
:maintainer winnie.he:
:contact winnie.he@nokia-sbell.com
"""
import os
import shutil
import re
try:
    import robot.api.logger as logging
except ImportError:
    import logging

from taf.sw.dcap.rd import rd
import collections
import time
from zipfile import ZipFile
Dcap_Server_Define = collections.namedtuple(
    "Dcap_Server_Define", ['port', "username", "password"])
BTS_Default_Define = collections.namedtuple(
    "BTS_Default_Define", ["username", "password"])
LOGTYPE_Traceid_resultlogpath = collections.namedtuple(
    "LOGTYPE_Traceid_resultlogpath", [
        "traceid", "resultlog_regex", "resultlog_path", "resultlog_ext"])


class BTSDcap(object):
    BTSID_INVAILD = -1
    DEFAULT_TRACELOG_PROFILE = 'dcap-lite-default'
    DCAP_SERVER_DEFAULT = Dcap_Server_Define(
        port="8100", username=None, password=None)

    BTS_DEFAULT = BTS_Default_Define(username="Nemuadmin", password="nemuuser")
    LOGTYPE_4G_TRACERS_ID = {
        "Syslog": LOGTYPE_Traceid_resultlogpath(
            traceid="condor4gSyslog",
            resultlog_path="/4g/condor",
            resultlog_regex="_condor4gSyslog_",
            resultlog_ext=".LOG"),
        "KPI": LOGTYPE_Traceid_resultlogpath(
            traceid="condor4gKpi",
            resultlog_regex=r"_condor4gKpi_",
            resultlog_path="/4g/condor",
            resultlog_ext=None),
        "Emil": LOGTYPE_Traceid_resultlogpath(
            traceid="condor4gAa",
            resultlog_path="/4g/condor",
            resultlog_regex=r"_condor4gAa_",
            resultlog_ext=".emil"),
        "TTITrace": LOGTYPE_Traceid_resultlogpath(
            traceid="condor4gTti",
            resultlog_path="/4g/condor",
            resultlog_regex=r"((_condor4gTti_)|" +
            r"(_condor4gTti_TTITracelog)|" +
                    r"(_condor4gTti_logs.conf)|" +
                    r"(_condor4gTti_settings))",
                    resultlog_ext=".dat,.log,.xml,.conf"),
        "L2 Trace": LOGTYPE_Traceid_resultlogpath(
            traceid="condor4gL2",
            resultlog_regex="_condor4gL2_",
            resultlog_path="/4g/condor",
            resultlog_ext=".log"),
        "PM Files": LOGTYPE_Traceid_resultlogpath(
            traceid="pmFiles4g",
            resultlog_path="/4g/pmFiles",
            resultlog_regex="_pmFiles4g_",
            resultlog_ext=".log"),
        "Condor Immediate Snapshot": LOGTYPE_Traceid_resultlogpath(
            traceid="immediateSnapshot4g",
            resultlog_path="/4g/snapshot",
            resultlog_regex="_immediateSnapshot4g_Full_Snapshot.zip",
            resultlog_ext=None),
        "Cell Trace": LOGTYPE_Traceid_resultlogpath(
            traceid="lteTracer",
            resultlog_path="/4g/ltetracer",
            resultlog_regex="_lteTracer_[^.]*.lcbin",
            resultlog_ext=None),
        "SCF": LOGTYPE_Traceid_resultlogpath(
            traceid="scf4g",
            resultlog_path="/4g/scf",
            resultlog_regex="_scf4g_",
            resultlog_ext=".xml")}
    LOGTYPE_5G_TRACERS_ID = {"5G Control Plane": LOGTYPE_Traceid_resultlogpath(
        traceid="flowTracer",
        resultlog_path="/5g/flowtracer",
        resultlog_regex="_flowtracer_",
        resultlog_ext=".5gm"),
        "Syslog": LOGTYPE_Traceid_resultlogpath(
        traceid="condor5gSyslog",
        resultlog_path="/5g/condor",
        resultlog_regex="_condor5gSyslog_",
        resultlog_ext=".LOG"),
        "5G L2 Component": LOGTYPE_Traceid_resultlogpath(
        traceid="l2Tracer",
        resultlog_path="/5g/udptracer",
        resultlog_regex="_l2Tracer_",
        resultlog_ext=".pcap"),
        "5G L2 Sherpa trace": LOGTYPE_Traceid_resultlogpath(
        traceid="l2Tracer",
        resultlog_path="/5g/udptracer",
        resultlog_regex="_l2Tracer_",
        resultlog_ext=".pcap"),
        "KPI": LOGTYPE_Traceid_resultlogpath(
        traceid="condor5gKpi",
        resultlog_path="/5g/condor",
        resultlog_regex=None,
        resultlog_ext=None),
        "PM Files": LOGTYPE_Traceid_resultlogpath(traceid="pmFiles5g",
                                                  resultlog_path="/5g/pmFiles",
                                                  resultlog_regex="_pmFiles5g_",
                                                  resultlog_ext=".zip"),
        "Condor Immediate Snapshot": LOGTYPE_Traceid_resultlogpath(
        traceid="immediateSnapshot5g",
        resultlog_path="/5g/snapshot",
        resultlog_regex="_immediateSnapshot5g_",
        resultlog_ext=".zip"),
        "Cell Trace": LOGTYPE_Traceid_resultlogpath(traceid="lteTracer",
                                                    resultlog_ext=None,
                                                    resultlog_regex=None,
                                                    resultlog_path=None),
        "SCF": LOGTYPE_Traceid_resultlogpath(traceid="scf5g",
                                             resultlog_path="/5g/scf",
                                             resultlog_regex="_scf5g_",
                                             resultlog_ext=".xml")}

    def __init__(self, bts_s1_ip,
                 mrBtsId,
                 url_ip,
                 bts_type="lte",  # lte or 5g
                 port=DCAP_SERVER_DEFAULT.port,
                 username=DCAP_SERVER_DEFAULT.username,
                 password=DCAP_SERVER_DEFAULT.password):
        self._dcapserver_obj = rd()
        self._dcapserver_obj.connect_to(
            host=url_ip,
            port=port,
            username=username,
            password=password,
            secure=True,
            alias="BTSDcap_server_{}".format(url_ip))
        self.dcap_server_ip = url_ip
        self.bts_type = bts_type.lower()
        self.bts_s1_ip = bts_s1_ip
        self.mrBtsId = mrBtsId
        self.current_trace_id = None
        self.alias = "BTSDcap_server_{}".format(self.dcap_server_ip)
        self.traceid_logpathlist = {}
        try:
            self.bts_info, self.request_bts_info = self.get_bts_info()
        except Exception as e:
            logging.info("Can't get the bts info try to create the bts")
            self._dcapserver_obj.create_bts(
                host=bts_s1_ip,
                bts_alias="btsalias_{}".format(bts_s1_ip),
                username=BTSDcap.BTS_DEFAULT.username,
                password=BTSDcap.BTS_DEFAULT.password,
                connection=self.alias)
            self.bts_info, self.request_bts_info = self.get_bts_info()

    def get_custom_profile_list(self):
        logprofiles = []
        if self.bts_type == "lte":
            logprofiles = BTSDcap.LOGTYPE_4G_TRACERS_ID.keys()
        elif self.bts_type == "5g":
            logprofiles = BTSDcap.LOGTYPE_5G_TRACERS_ID.keys()
        return logprofiles

    def get_trace_profile_id_list(self):
        if self.bts_type == "lte":
            res = self._dcapserver_obj.get_lte_profiles(connection=self.alias)
        elif self.bts_type == "5g":
            res = self._dcapserver_obj.get_5g_profiles(connection=self.alias)
        id_list = []
        for item in res:
            if "id" in item.keys():
                id_list.append(item["id"])
        return id_list

    def get_request_bts_info(self, bts_info):
        request_bts_info = {"alias": bts_info["alias"],
                            "host": bts_info["host"],
                            "port": bts_info["port"],
                            "username": BTSDcap.BTS_DEFAULT.username,
                            "password": BTSDcap.BTS_DEFAULT.password,
                            "lteCells": bts_info["lte_cells"],
                            "nrCells": bts_info["nr_cells"],
                            "id": int(bts_info["id"])}
        return request_bts_info

    def get_bts_info(self):
        bts = None
        all_bts_info = self._dcapserver_obj.get_all_bts_info(
            connection=self.alias)
        id = BTSDcap.BTSID_INVAILD
        for bts_info in all_bts_info:
            if int(bts_info["mr_bts_id"]) == self.mrBtsId:
                print(
                    "name:{},mrbtsid:{}, id:{}".format(
                        bts_info["name"],
                        bts_info["mr_bts_id"],
                        bts_info["id"]))
                id = bts_info["id"]
                bts = bts_info.copy()
                request_bts_info = self.get_request_bts_info(bts_info=bts)
        if id == BTSDcap.BTSID_INVAILD or bts is None:
            raise "Can't find BTS {} on DCAP {}".format(
                self.mrBtsId, self.dcap_server_ip)
        return bts, request_bts_info

    def start_trace(self, tag,
                    trace_profile=None,
                    custom_profile=None,
                    custom_filter_file=None):
        # try to stop trace
        # lastest_trace_id = self.get_lastest_trace_id()
        # try:
        #     trace_info = self.get_trace_info_by_id(trace_id=lastest_trace_id)
        #     if trace_info.status != "ready":
        #         self.stop_trace(trace_id=lastest_trace_id)
        #         self.check_trace_status(check_attr="status",
        #                                 check_value="ready",
        #                                 trace_id=lastest_trace_id,
        #                                 timeout=180)
        # except BaseException:
        #     logging.info(
        #         "error happen when try to stop trace:{}".format(lastest_trace_id))
        if self.bts_type == "lte":
            if custom_profile:
                custom_profile = [
                    BTSDcap.LOGTYPE_4G_TRACERS_ID[item].traceid for item in custom_profile]
            res = self._dcapserver_obj.start_trace(
                bts=[
                    self.request_bts_info],
                tag=tag,
                duration=-1,
                enb_trace_profile=trace_profile,
                enb_custom_profile=custom_profile,
                custom_filter_file=custom_filter_file,
                connection=self.alias)
        elif self.bts_type == "5g":
            if custom_profile:
                custom_profile = [
                    BTSDcap.LOGTYPE_5G_TRACERS_ID[item].traceid for item in custom_profile]
            res = self._dcapserver_obj.start_trace(
                bts=[
                    self.request_bts_info],
                tag=tag,
                duration=-1,
                gnb_trace_profile=trace_profile,
                gnb_custom_profile=custom_profile,
                custom_filter_file=custom_filter_file,
                connection=self.alias)

        logging.info(
            "Start Trace on {} {}, trace id {}".format(
                res["targets"][0]["host"],
                res["targets"][0]["mrBtsId"],
                res["id"]))
        self.current_trace_id = res["id"]
        return int(res["id"])

    def stop_trace(self, trace_id=None, timeout=120):
        if trace_id is None:
            trace_id = self.current_trace_id
        self.check_trace_status(check_attr="status",
                                check_value="running",
                                trace_id=trace_id,
                                timeout=timeout)
        return self._dcapserver_obj.stop_trace(trace_id=trace_id,
                                               connection=self.alias)

    def delete_trace(self, trace_id=None, timeout=120):
        if trace_id is None:
            trace_id = self.current_trace_id

        self.check_trace_status(check_attr="status",
                                check_value="ready",
                                trace_id=trace_id,
                                timeout=timeout)
        self._dcapserver_obj.delete_trace(trace_id=trace_id,
                                          connection=self.alias)

    def check_trace_status(
            self,
            check_attr,
            check_value=False,
            trace_id=None,
            timeout=120):
        starttime = time.time()
        res = self.get_trace_info_by_id(trace_id)
        logging.info(starttime)
        logging.info(time.time())
        logging.info(res)
        while (
                time.time() -
                starttime < int(timeout)) and (
                getattr(
                res,
                check_attr) != check_value):
            res = self.get_trace_info_by_id(trace_id)
            logging.info(
                "the trace status {} is {}".format(
                    check_attr, check_value))
            time.sleep(10)
        if getattr(res, check_attr) == check_value:
            pass
        else:
            raise (
                "timeout {} and {} result is not available!".format(
                    timeout, trace_id))
        return getattr(res, check_attr)

    def get_result_file(
            self,
            trace_id=None,
            target_dir="/tmp",
            file_name="dcap_log.zip",
            timeout=180):

        self.check_trace_status(check_attr="results_available",
                                check_value=True,
                                trace_id=trace_id,
                                timeout=timeout)

        target_file_path = os.path.join(target_dir, file_name)
        # clear old log file
        if os.path.exists(target_file_path):
            os.remove(target_file_path)
        return self._dcapserver_obj.get_results(result_id=trace_id,
                                                target_dir=target_file_path,
                                                connection=self.alias)

    def get_trace_info_by_id(self, trace_id):
        res = self._dcapserver_obj.get_trace_info_by_id(trace_id=trace_id,
                                                        connection=self.alias)
        return res

    def get_all_files(self, path):
        allfiles = []
        current_path = path
        for root, dirs, files in os.walk(path):
            for file in files:
                allfiles.append(os.path.join(current_path, file))
            for dir in dirs:
                current_path = os.path.join(current_path, dir)
                self.get_all_files(os.path.join(path, dir))

        return allfiles

    def unzip_dcap_log_and_get_all_file_paths(self, log_path):

        # to create a execute dir
        execute_dir = os.path.join(
            os.path.dirname(log_path),
            os.path.basename(log_path).replace(
                ".zip",
                ""))
        if os.path.exists(execute_dir):
            shutil.rmtree(execute_dir, True)
        os.mkdir(execute_dir)
        zipfile = ZipFile(log_path)
        zipfile.extractall(execute_dir)
        all_files_list = self.get_all_files(execute_dir)
        return self.get_log_path_from_result_log_paths(
            all_files_list=all_files_list)

    def get_log_path_from_result_log_paths(self, all_files_list):
        for filepath in all_files_list:
            file_name = os.path.basename(filepath)
            if self.bts_type == "lte":
                logtypes = self.LOGTYPE_4G_TRACERS_ID
            elif self.bts_type == "5g":
                logtypes = self.LOGTYPE_5G_TRACERS_ID

            if "_condor4gSyslog_" in file_name:
                print(file_name)
            for traceid, logobj in logtypes.items():
                print(logobj.resultlog_regex)
                print(file_name)

                matched_path_str = re.search(
                    logobj.resultlog_regex,
                    file_name) if logobj.resultlog_regex is not None else None
                ext_match = (os.path.splitext(file_name)[-1] in logobj.resultlog_ext.split(
                    ",")) if logobj.resultlog_ext is not None else False
                ispath_contain = os.path.splitdrive(os.path.abspath(
                    logobj.resultlog_path))[-1] in filepath if logobj.resultlog_path is not None else False
                print(os.path.splitdrive(os.path.abspath(logobj.resultlog_path))
                      [-1] if logobj.resultlog_path is not None else "")
                if matched_path_str is not None and ispath_contain and ext_match:
                    if traceid not in self.traceid_logpathlist:
                        self.traceid_logpathlist[traceid] = []
                    self.traceid_logpathlist[traceid].append(filepath)
        return self.traceid_logpathlist

    def get_log_paths(self, log_type):
        if log_type in self.traceid_logpathlist.keys():
            return self.traceid_logpathlist[log_type]
        else:
            return None

    def get_lastest_trace_id(self):
        last_trace_id = None
        trace_infos = self._dcapserver_obj.get_all_trace_info(
            connection=self.alias)
        for trace_info in trace_infos:
            if "targets" in trace_info.keys():
                for target in trace_info["targets"]:
                    if self.bts_s1_ip == target["host"]:
                        last_trace_id = trace_info['id']
                        break
        return last_trace_id
