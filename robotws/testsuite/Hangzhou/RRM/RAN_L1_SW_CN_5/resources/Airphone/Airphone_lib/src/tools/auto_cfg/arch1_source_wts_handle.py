# -*- coding: utf-8 -*-

"""
:author: eric.jiang
:contact: eric.jiang@nokia-sbell.com
:maintainer: eric.jiang@nokia-sbell.com
"""

import os
import sys
import re
import lxml.objectify
from collections import OrderedDict
import traceback
from .comm_command import command


class SourceWtsCfg(object):
    def __init__(self, source_wts_path, ap_oam_config_path=None):
        self.swc_paras = OrderedDict()  # sc = source wts cfg
        self.swc_path = source_wts_path

        self.swc_f = open(self.swc_path, "r")
        self.swc_content = self.swc_f.read()
        self.swc_f.close()
        self.swc_f = open(self.swc_path, "r")
        self.swc_content_L = self.swc_f.readlines()
        self.swc_f.close()

        if ap_oam_config_path is not None:
            self.s_aoc = ap_oam_config_path  # s_aoc = source ap_oam_config
            self.s_aoc__name = os.path.basename(self.s_aoc)
            self.swc_paras["ap_oam_config_name"] = self.s_aoc__name

        try:
            self.__get_swc_variables()
            self.__get_extend_anchor_point()
        except Exception as e:
            traceback.print_exc(file=sys.stdout)

    def sort_cmdlist(self, flag, cmd_list):
        ret = cmd_list
        idlist = []
        [idlist.append(int(re.search(r"%s=(\d+)" % flag, i).group(1))) for i in ret]
        idlist.sort(reverse=False)
        ret.sort(key=lambda i: idlist.index(int(re.search(r"%s=(\d+)" % flag, i).group(1))))
        return ret

    # eg: set CONTAINER_IP="10.0.2.1"  |  set DAEMON_IP=$CONTAINER_IP
    def __get_swc_variables(self):
        self.swc_paras["swc_variables"] = OrderedDict()
        variables = re.findall(r"set [A-Za-z0-9_]+\s*=\s*\"*.+\"*\n", self.swc_content)

        for i in variables:
            ret = re.search(r"set ([A-Za-z_\d]+)\s*=\s*(\S+)\s*\n", i)
            # if not: set DAEMON_IP=$CONTAINER_IP
            if ret is not None:
                if not ret.group(2).startswith("$"):
                    # Variable name without "$"
                    self.swc_paras["swc_variables"][ret.group(1).upper()] = ret.group(2).strip('"')
                else:
                    try:
                        self.swc_paras["swc_variables"][ret.group(1).upper()] = \
                            self.swc_paras["swc_variables"][ret.group(2)[1:].upper()]
                    except Exception as e:
                        print("Exception: Variable %s not defined in source wts.cfg !" % ret.group(2)[1:])

    def __get_extend_anchor_point(self):
        self.swc_paras["swc_ue_releated"] = OrderedDict()
        self.swc_paras["swc_ue_releated"]["sa_ue_cmd"] = []
        self.swc_paras["swc_ue_releated"]["sa_ue_id"] = []
        self.swc_paras["swc_ue_releated"]["sa_ue_param_cmd"] = []

        self.swc_paras["swc_ue_releated"]["ca_sa_ue_cmd"] = []
        self.swc_paras["swc_ue_releated"]["ca_sa_ue_id"] = []
        self.swc_paras["swc_ue_releated"]["ca_sa_ue_param_cmd"] = []

        self.swc_paras["swc_ue_releated"]["nsa_ue_cmd"] = []
        self.swc_paras["swc_ue_releated"]["nsa_ue_id"] = []
        self.swc_paras["swc_ue_releated"]["nsa_ue_param_cmd"] = []

        self.swc_paras["swc_ue_releated"]["ca_nsa_ue_cmd"] = []
        self.swc_paras["swc_ue_releated"]["ca_nsa_ue_id"] = []
        self.swc_paras["swc_ue_releated"]["ca_nsa_ue_param_cmd"] = []

        self.swc_paras["swc_ue_releated"]["bearer_cmd"] = []

        self.swc_paras["swc_ue_releated"]["ca_bearer_cmd"] = []

        self.swc_paras["swc_ue_releated"]["nwslice_cmd"] = []

        self.swc_paras["swc_ue_releated"]["exist_bearer_pdn_ip"] = []

        self.swc_paras["swc_ue_releated"]["exist_sa_suci"] = []

        self.swc_paras["swc_ue_releated"]["exist_nsa_imsi"] = []

        self.swc_body_L = []
        self.swc_tail_L = []

        self.swc_vari_cmd_map = {}

        tmpL = []
        for line in self.swc_content_L:
            if line.startswith("#") or line.startswith("set ") or len(line.strip()) == 0:
                continue
            else:
                if "#" in line:
                    line = line.split("#")[0].strip()
                ret = re.findall(r"\$[a-zA-Z_\d]+", line)
                if ret != []:
                    source_line = line
                    for i in ret:
                        line = line.replace(i, self.swc_paras["swc_variables"][i[1:].upper()])
                    s = command(line)
                    self.swc_vari_cmd_map[s.diff] = command(source_line)
                tmpL.append(line)

        self.base_wtscfg_sansa = "sa"
        self.maybe_exist_swc_tail_L = []
        for line in tmpL:
            if line != "\n" and line != "\r\n":
                lineL = line.split()
                if lineL[0] == "set_enb" or lineL[0] == "enb_set":
                    self.base_wtscfg_sansa = "nsa_sansa"
                tmp_cmd = " ".join(line.split())
                if lineL[0].strip() in ["debug_log", "sim_debug_log", "link_ctrl_param", "trace", "sim_trace",
                                        "cfg_end", "set_log", "sim_start", "start"]:
                    self.maybe_exist_swc_tail_L.append(tmp_cmd)
                else:
                    self.swc_body_L.append(tmp_cmd)
            else:
                continue

        self.swc_tail_L = ["sim_debug_log level=2",
                           "link_ctrl_param use_hb=off",
                           "sim_trace uec=1 protocol=nr_rrc on",
                           "sim_trace uec=1 protocol=rrc on",
                           "sim_trace uec=1 protocol=x2 on",
                           "sim_trace amf=1 protocol=ng on",
                           "cfg_end",
                           "set_log log_to_file=on",
                           "start version_check=off"]
        if self.base_wtscfg_sansa != "sa":
            self.swc_tail_L.insert(6, "sim_trace enb=1 protocol=x2 on")

        for cmd in self.swc_body_L:
            if cmd.startswith("set_ue simulated") or cmd.startswith("ue_set simulated"):
                # SA UE
                if "suci=" in cmd.lower():
                    ue_id = re.search(r"id=(\d+)", cmd).group(1)
                    suci = re.search(r"suci=(\S+)", cmd).group(1)
                    self.swc_paras["swc_ue_releated"]["exist_sa_suci"].append(suci)

                    if int(ue_id) >= 1 and int(ue_id) <= 10:
                        self.swc_paras["swc_ue_releated"]["sa_ue_cmd"].append(cmd)
                        self.swc_paras["swc_ue_releated"]["sa_ue_id"].append(ue_id)
                    elif int(ue_id) >= 80 and int(ue_id) <= 90:
                        self.swc_paras["swc_ue_releated"]["ca_sa_ue_cmd"].append(cmd)
                        self.swc_paras["swc_ue_releated"]["ca_sa_ue_id"].append(ue_id)
                # NSA UE
                elif "imsi=" in cmd.lower():
                    ue_id = re.search(r"id=(\d+)", cmd).group(1)
                    imsi = re.search(r"imsi=(\d+)", cmd).group(1)
                    self.swc_paras["swc_ue_releated"]["exist_nsa_imsi"].append(imsi)

                    if int(ue_id) >= 11 and int(ue_id) <= 20:
                        self.swc_paras["swc_ue_releated"]["nsa_ue_cmd"].append(cmd)
                        self.swc_paras["swc_ue_releated"]["nsa_ue_id"].append(ue_id)
                    elif int(ue_id) >= 91 and int(ue_id) <= 100:
                        self.swc_paras["swc_ue_releated"]["ca_nsa_ue_cmd"].append(cmd)
                        self.swc_paras["swc_ue_releated"]["ca_nsa_ue_id"].append(ue_id)

        self.swc_paras["swc_ue_releated"]["sa_ue_id"].sort()
        self.swc_paras["swc_ue_releated"]["ca_sa_ue_id"].sort()
        self.swc_paras["swc_ue_releated"]["nsa_ue_id"].sort()
        self.swc_paras["swc_ue_releated"]["ca_nsa_ue_id"].sort()

        for cmd in self.swc_body_L:
            if cmd.startswith("ue_param"):
                ue_id = re.search(r"id=(\d+)", cmd).group(1)
                if ue_id in self.swc_paras["swc_ue_releated"]["sa_ue_id"]:
                    self.swc_paras["swc_ue_releated"]["sa_ue_param_cmd"].append(cmd)
                elif ue_id in self.swc_paras["swc_ue_releated"]["ca_sa_ue_id"]:
                    self.swc_paras["swc_ue_releated"]["ca_sa_ue_param_cmd"].append(cmd)
                elif ue_id in self.swc_paras["swc_ue_releated"]["nsa_ue_id"]:
                    self.swc_paras["swc_ue_releated"]["nsa_ue_param_cmd"].append(cmd)
                elif ue_id in self.swc_paras["swc_ue_releated"]["ca_nsa_ue_id"]:
                    self.swc_paras["swc_ue_releated"]["ca_nsa_ue_param_cmd"].append(cmd)
            elif cmd.startswith("set_bearer") or cmd.startswith("bearer_set"):
                ue_id = re.search(r"ue=(\d+)", cmd).group(1)
                pdn_ip = re.search(r"ip=(\S+)", cmd).group(1)
                self.swc_paras["swc_ue_releated"]["exist_bearer_pdn_ip"].append(pdn_ip)
                if ue_id in self.swc_paras["swc_ue_releated"]["nsa_ue_id"]:
                    self.swc_paras["swc_ue_releated"]["bearer_cmd"].append(cmd)
                elif ue_id in self.swc_paras["swc_ue_releated"]["ca_nsa_ue_id"]:
                    self.swc_paras["swc_ue_releated"]["ca_bearer_cmd"].append(cmd)
            elif cmd.startswith("set_nwslice") or cmd.startswith("nwslice_set"):
                self.swc_paras["swc_ue_releated"]["nwslice_cmd"].append(cmd)

        # SA UE
        self.swc_paras["sa_ue_template"] = OrderedDict()
        if self.swc_paras["swc_ue_releated"]["sa_ue_cmd"] != []:
            self.swc_paras["swc_ue_releated"]["sa_ue_cmd"] = \
                self.sort_cmdlist("id", self.swc_paras["swc_ue_releated"]["sa_ue_cmd"])
            template_cmd = self.swc_paras["swc_ue_releated"]["sa_ue_cmd"][0]
            last_sa_ue_cmd = self.swc_paras["swc_ue_releated"]["sa_ue_cmd"][-1]

            self.swc_paras["sa_ue_template"]["id"] = re.search(r"id=(\d+)", template_cmd).group(1)
            self.swc_paras["sa_ue_template"]["suci"] = re.search(r"suci=(\S+)", last_sa_ue_cmd).group(1)
            self.swc_paras["sa_ue_template"]["whole_ue_cmd"] = template_cmd

            if self.swc_paras["swc_ue_releated"]["sa_ue_param_cmd"] != []:
                self.swc_paras["swc_ue_releated"]["sa_ue_param_cmd"] = \
                    self.sort_cmdlist("id", self.swc_paras["swc_ue_releated"]["sa_ue_param_cmd"])
                template_cmd = self.swc_paras["swc_ue_releated"]["sa_ue_param_cmd"][0]
                template_content = re.sub("ue_param", "", template_cmd)
                template_content = re.sub(r"id=\d+", "", template_content).strip()
                self.swc_paras["sa_ue_template"]["ue_param"] = template_content
                self.swc_paras["sa_ue_template"]["ue_param_whole_cmd"] = template_cmd

        # CA SA NE
        self.swc_paras["ca_sa_ue_template"] = OrderedDict()
        if self.swc_paras["swc_ue_releated"]["ca_sa_ue_cmd"] != []:
            self.swc_paras["swc_ue_releated"]["ca_sa_ue_cmd"] = \
                self.sort_cmdlist("id", self.swc_paras["swc_ue_releated"]["ca_sa_ue_cmd"])
            template_cmd = self.swc_paras["swc_ue_releated"]["ca_sa_ue_cmd"][0]
            last_sa_ue_cmd = self.swc_paras["swc_ue_releated"]["ca_sa_ue_cmd"][-1]

            self.swc_paras["ca_sa_ue_template"]["id"] = re.search(r"id=(\d+)", template_cmd).group(1)
            self.swc_paras["ca_sa_ue_template"]["suci"] = re.search(r"suci=(\S+)", last_sa_ue_cmd).group(1)
            self.swc_paras["ca_sa_ue_template"]["whole_ue_cmd"] = template_cmd

            if self.swc_paras["swc_ue_releated"]["ca_sa_ue_param_cmd"] != []:
                self.swc_paras["swc_ue_releated"]["ca_sa_ue_param_cmd"] = \
                    self.sort_cmdlist("id", self.swc_paras["swc_ue_releated"]["ca_sa_ue_param_cmd"])
                template_cmd = self.swc_paras["swc_ue_releated"]["ca_sa_ue_param_cmd"][0]
                template_content = re.sub("ue_param", "", template_cmd)
                template_content = re.sub(r"id=\d+", "", template_content).strip()
                self.swc_paras["ca_sa_ue_template"]["ue_param"] = template_content
                self.swc_paras["ca_sa_ue_template"]["ue_param_whole_cmd"] = template_cmd

        # nwslice
        if self.swc_paras["swc_ue_releated"]["nwslice_cmd"] != []:
            self.swc_paras["swc_ue_releated"]["nwslice_cmd"] = \
                self.sort_cmdlist("id", self.swc_paras["swc_ue_releated"]["nwslice_cmd"])
            self.swc_paras["nwslice_template"] = self.swc_paras["swc_ue_releated"]["nwslice_cmd"][0]

        # Normal NSA UE
        self.swc_paras["nsa_ue_template"] = OrderedDict()
        self.swc_paras["bearer_template"] = OrderedDict()
        if self.swc_paras["swc_ue_releated"]["nsa_ue_cmd"] != []:
            nsa_ue_cmd = self.sort_cmdlist("id", self.swc_paras["swc_ue_releated"]["nsa_ue_cmd"])
            template_cmd = self.swc_paras["swc_ue_releated"]["nsa_ue_cmd"][0]
            last_nsa_ue_cmd = self.swc_paras["swc_ue_releated"]["nsa_ue_cmd"][-1]
            self.swc_paras["nsa_ue_template"]["id"] = re.search(r"id=(\d+)", template_cmd).group(1)
            self.swc_paras["nsa_ue_template"]["imsi"] = re.search(r"imsi=(\S+)", last_nsa_ue_cmd).group(1)
            self.swc_paras["nsa_ue_template"]["whole_ue_cmd"] = template_cmd

            if self.swc_paras["swc_ue_releated"]["nsa_ue_param_cmd"] != []:
                self.swc_paras["swc_ue_releated"]["nsa_ue_param_cmd"] = \
                    self.sort_cmdlist("id", self.swc_paras["swc_ue_releated"]["nsa_ue_param_cmd"])
                template_cmd = self.swc_paras["swc_ue_releated"]["nsa_ue_param_cmd"][0]
                template_content = re.sub("ue_param", "", template_cmd)
                template_content = re.sub(r"id=\d+", "", template_content).strip()
                self.swc_paras["nsa_ue_template"]["ue_param"] = template_content
                self.swc_paras["nsa_ue_template"]["ue_param_whole_cmd"] = template_cmd

            if self.swc_paras["swc_ue_releated"]["bearer_cmd"] != []:
                self.swc_paras["swc_ue_releated"]["bearer_cmd"] = \
                    self.sort_cmdlist("ue", self.swc_paras["swc_ue_releated"]["bearer_cmd"])
                template_cmd = self.swc_paras["swc_ue_releated"]["bearer_cmd"][0]
                if int(re.search(r"ue=(\d+)", template_cmd).group(1)) == \
                        int(self.swc_paras["swc_ue_releated"]["nsa_ue_id"][0]):
                    ret = re.search(r"ip=(\S+)", template_cmd)
                    if ret is not None:
                        self.swc_paras["bearer_template"]["pdn_ip"] = ret.group(1)
                        self.swc_paras["bearer_template"]["whole_cmd"] = template_cmd

        # CA NSA UE
        self.swc_paras["ca_nsa_ue_template"] = OrderedDict()
        self.swc_paras["ca_bearer_template"] = OrderedDict()
        if self.swc_paras["swc_ue_releated"]["ca_nsa_ue_cmd"] != []:
            nsa_ue_cmd = self.sort_cmdlist("id", self.swc_paras["swc_ue_releated"]["ca_nsa_ue_cmd"])
            template_cmd = self.swc_paras["swc_ue_releated"]["ca_nsa_ue_cmd"][0]
            last_nsa_ue_cmd = self.swc_paras["swc_ue_releated"]["ca_nsa_ue_cmd"][-1]
            self.swc_paras["ca_nsa_ue_template"]["id"] = re.search(r"id=(\d+)", template_cmd).group(1)
            self.swc_paras["ca_nsa_ue_template"]["imsi"] = re.search(r"imsi=(\S+)", last_nsa_ue_cmd).group(1)
            self.swc_paras["ca_nsa_ue_template"]["whole_ue_cmd"] = template_cmd

            if self.swc_paras["swc_ue_releated"]["ca_nsa_ue_param_cmd"] != []:
                self.swc_paras["swc_ue_releated"]["ca_nsa_ue_param_cmd"] = \
                    self.sort_cmdlist("id", self.swc_paras["swc_ue_releated"]["ca_nsa_ue_param_cmd"])
                template_cmd = self.swc_paras["swc_ue_releated"]["ca_nsa_ue_param_cmd"][0]
                template_content = re.sub("ue_param", "", template_cmd)
                template_content = re.sub(r"id=\d+", "", template_content).strip()
                self.swc_paras["ca_nsa_ue_template"]["ue_param"] = template_content
                self.swc_paras["ca_nsa_ue_template"]["ue_param_whole_cmd"] = template_cmd

            if self.swc_paras["swc_ue_releated"]["ca_bearer_cmd"] != []:
                self.swc_paras["swc_ue_releated"]["ca_bearer_cmd"] = \
                    self.sort_cmdlist("ue", self.swc_paras["swc_ue_releated"]["ca_bearer_cmd"])
                template_cmd = self.swc_paras["swc_ue_releated"]["ca_bearer_cmd"][0]
                if int(re.search(r"ue=(\d+)", template_cmd).group(1)) == \
                        int(self.swc_paras["swc_ue_releated"]["ca_nsa_ue_id"][0]):
                    ret = re.search(r"ip=(\S+)", template_cmd)
                    if ret is not None:
                        self.swc_paras["ca_bearer_template"]["pdn_ip"] = ret.group(1)
                        self.swc_paras["ca_bearer_template"]["whole_cmd"] = template_cmd
