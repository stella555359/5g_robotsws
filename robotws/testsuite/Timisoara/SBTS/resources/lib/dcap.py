# -*- coding: utf-8 -*-


import logging
import os
import time
from taf.sw.dcap.rd import rd
import math


class dcap():
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
        self.rd.connect_to(host, port, username=username, password=password,
                           rd_version=rd_version, secure=secure, alias=alias)
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.rd_version = rd_version
        self.secure = secure
        self.alias = alias

    def create_bts_to_dcap(self, btsip, btsport='443', btsusername='Nemuadmin', btspassword='nemuuser',
                           bts_alias='target_bts'):
        btsinfo = self.rd.create_bts(host=btsip, port=btsport, username=btsusername, password=btspassword,
                                     bts_alias=bts_alias, connection=self.alias)
        logging.info(btsinfo)
        print(btsinfo)
        return btsinfo

    def delete_bts_from_dcap(self, btsid):
        self.rd.delete_bts(bts_id=btsid, connection=self.alias)

    def edit_bts_in_dcap(self, btsid, btsip, btsport='443', btsusername='Nemuadmin', btspassword='nemuuser',
                         bts_alias='target_bts', lte_cells=None, nr_cells=None):
        btsinfo = self.rd.edit_bts(btsid, host=btsip, port=btsport, username=btsusername, password=btspassword,
                                   bts_alias=bts_alias, lte_cells=lte_cells, nr_cells=nr_cells, connection=self.alias)
        return btsinfo

    def delete_trace_in_dcap(self, trace_id):
        result = self.rd.delete_trace(trace_id=trace_id, connection=self.alias)
        return result

    def start_trace_in_dcap(self, bts_dic, tag='start_trace', force=True, gnb_trace_profile='dcap-lite-default',
                            vcu_trace_profile=None, vdu_trace_profile=None, enb_trace_profile=None,
                            bts_trace_profile=None, custom_filter_file=None, gnb_custom_profile_list=None,
                            enb_custom_profile_list=None, vdu_custom_profile=None, vcu_custom_profile=None,
                            wait_for_activation=False, timeout=400):
        oper_info = self.rd.start_trace(bts=bts_dic, tag=tag, force=force, vcu_trace_profile=vcu_trace_profile,
                                        vdu_trace_profile=vdu_trace_profile, gnb_trace_profile=gnb_trace_profile,
                                        enb_trace_profile=enb_trace_profile, bts_trace_profile=bts_trace_profile,
                                        custom_filter_file=custom_filter_file,
                                        gnb_custom_profile=gnb_custom_profile_list,
                                        enb_custom_profile=enb_custom_profile_list,
                                        vdu_custom_profile=vdu_custom_profile,
                                        vcu_custom_profile=vcu_custom_profile, wait_for_activation=wait_for_activation,
                                        timeout=timeout, connection=self.alias)
        return oper_info

    def stop_trace_in_dcap(self, btsip):
        last_trace_id = self.get_last_trace_id(btsip=btsip)
        trace_info = self.get_trace_status(trace_id=last_trace_id)
        if trace_info["status"] != "ready":
            result = self.rd.stop_trace(trace_id=last_trace_id, connection=self.alias)
            return result

    def get_all_bts_info(self):
        result = self.rd.get_all_bts_info(connection=self.alias)
        return result

    def download_trace_file(self, btsip, target_dir='/tmp', timeout=600, connection='dcap'):
        current_time = str(math.floor(time.time()))
        print(current_time)
        dcap_log_name = "dcap" + current_time + ".zip"
        target_dcap_log_path = os.path.join(target_dir, dcap_log_name)
        print(target_dcap_log_path)
        last_trace_id = self.get_last_trace_id(btsip=btsip)
        print(last_trace_id)
        try:
            # for index in range(0, 60):
            trace_info = self.get_trace_status(trace_id=last_trace_id)
            print(trace_info)

            trace_file_path = self.rd.get_results(result_id=last_trace_id, target_dir=target_dcap_log_path,
                                                  timeout=timeout, connection=connection)
            print("trace _path:    " + trace_file_path)
        except BaseException:
            logging.info(
                "download trace file failed with trace id:{}".format(last_trace_id))
        # return trace_file_path

    def check_trace_status(self, trace_id, connection='dcap'):
        status = self.get_trace_status(trace_id=trace_id, connection=connection)
        return status["results_available"]

    def get_dcap_bts_id(self, host):
        dcap_bts_info = self.get_all_bts_info()
        for bts in dcap_bts_info:
            if host in bts.values():
                return bts['id']

    def get_vcu_trace_profiles_info(self):
        trace_profiles_info = self.rd.get_vcu_profiles(connection=self.alias)
        print(trace_profiles_info)
        trace_id_list = []
        for item in trace_profiles_info:
            if "id" in item.keys():
                trace_id_list.append(item["id"])
        return trace_id_list

    def get_vdu_trace_profiles_info(self):
        trace_profiles_info = self.rd.get_vdu_profiles(connection=self.alias)
        trace_id_list = []
        for item in trace_profiles_info:
            if "id" in item.keys():
                trace_id_list.append(item["id"])
        return trace_id_list

    def get_last_trace_id(self, btsip):
        last_trace_id = None
        trace_infos = self.rd.get_all_trace_info(connection=self.alias)
        for trace_info in trace_infos:
            if "targets" in trace_info.keys():
                for target in trace_info["targets"]:
                    if btsip == target["host"]:
                        last_trace_id = trace_info['id']
                        break
        return last_trace_id

    def get_trace_status(self, trace_id, connection='dcap'):
        trace_info = self.rd.get_trace_info_by_id(trace_id=trace_id, connection='dcap')
        return trace_info

    def getsyslog_from_result(self, target):
        snapshot_dir = target + 'Snapshot/'
        osa = os.listdir(snapshot_dir)
        print(osa)
        for file in osa:
            if 'dcap-master' in file:
                path = snapshot_dir + file
                path_extract = target + "UDPLogs/SMOD1_TMP"
                unzip = os.popen('unzip -d %s %s  | grep .LOG' % (path_extract, path))
                log_finial_path = target + "UDPLogs/SMOD1_TMP/tmp_log/"
                time.sleep(3)
                os.system('mkdir %s/tmp_log/' % (path_extract))
                time.sleep(5)
                for file_path in unzip.readlines():
                    file_paths = file_path.split(' ')
                    file_name = file_paths[-3].split('/')
                    print(file_paths[-3])
                    print(file_name[-1])
                    os.system('cp  %s  %s/%s' % (file_paths[-3], log_finial_path, file_name[-1]))
                os.system('pwd')
                print(path_extract)
                os.system('cd %s/tmp_log/ &&tar -czvf SMOD1.tgz   . ' % (path_extract))
                time.sleep(3)
                os.system('mkdir %sUDPLogs/SMOD1/' % (target))
                time.sleep(3)
                os.system('mv %s/UDPLogs/SMOD1_TMP/tmp_log/SMOD1.tgz  %s/UDPLogs/SMOD1/' % (target, target))
                time.sleep(3)
                os.system('rm -r %s/UDPLogs/SMOD1_TMP/ ' % (target))
            if 'dcap-master' not in file:
                path = snapshot_dir + file
                path_extract = target + "UDPLogs/SMOD2_TMP"
                unzip = os.popen('unzip -d %s %s  | grep .LOG' % (path_extract, path))
                log_finial_path = target + "UDPLogs/SMOD2_TMP/tmp_log/"
                time.sleep(3)
                os.system('mkdir %s/tmp_log/' % (path_extract))
                time.sleep(5)
                for file_path in unzip.readlines():
                    file_paths = file_path.split(' ')
                    file_name = file_paths[-3].split('/')
                    print(file_paths[-3])
                    print(file_name[-1])
                    os.system('cp  %s  %s/%s' % (file_paths[-3], log_finial_path, file_name[-1]))
                os.system('pwd')
                print(path_extract)
                os.system('cd %s/tmp_log/ &&tar -czvf SMOD2.tgz  . ' % (path_extract))
                time.sleep(3)
                os.system('mkdir %sUDPLogs/SMOD2/' % (target))
                os.system('mv %s/tmp_log/SMOD2.tgz  %s/UDPLogs/SMOD2/' % (path_extract, target))
                time.sleep(3)
                os.system('rm -r %s/UDPLogs/SMOD2_TMP/ ' % (target))
        time.sleep(10)
