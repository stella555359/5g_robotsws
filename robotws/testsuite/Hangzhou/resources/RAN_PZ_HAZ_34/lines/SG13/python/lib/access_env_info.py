# -*- coding: UTF-8 -*-

import os
import re
import sys
import yaml


class access_env_info():
    def __init__(self):
        self.excludeip = ["10.0.1.1", "10.0.2.1"]
        self.env_info = None

    def get_envinfo(self, file):
        fp = open(file, "rb")
        self.env_info = yaml.safe_load(fp)
        fp.close()

    def get_ue_ip(self, file, ue_name):
        self.get_envinfo(file)
        ue_ip = self.env_info.get(ue_name)
        return ue_ip

    def get_mcs_related_ip(self, file):
        self.get_envinfo(file)
        mcs_pc_ip = self.env_info.get("mcs_pc_ip")
        mcs_ip = self.env_info.get("mcs_ip")
        mcs_db_path = self.env_info.get("mcs_db_path")
        mcs_pc_username = self.env_info.get("mcs_pc_username")
        mcs_pc_pwd = self.env_info.get("mcs_pc_pwd")
        return [mcs_pc_ip, mcs_ip, mcs_db_path, mcs_pc_username, mcs_pc_pwd]

    def get_iperf_pc_info(self, file):
        self.get_envinfo(file)
        iperfpc = self.env_info.get("iperfpc_ip")
        iperfpc_username = self.env_info.get("iperfpc_username")
        iperfpc_pwd = self.env_info.get("iperfpc_pwd")
        iperf_info = [iperfpc, iperfpc_username, iperfpc_pwd, 22]
        return iperf_info

    def get_mcs_another_db_file(self, file, mcs_db_path):
        mcs_db_path = self.env_info.get(mcs_db_path)
        return mcs_db_path
