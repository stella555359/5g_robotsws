# -*- coding: utf-8 -*-

"""
:author: eric.jiang
:contact: eric.jiang@nokia-sbell.com
:maintainer: eric.jiang@nokia-sbell.com
"""

import os
import sys
import re
import IPy
from collections import OrderedDict
from robot.libraries.BuiltIn import BuiltIn
from .comm_cfg_file_generator import cfg_file_generator
from .comm_command import command
from .comm_sync_gnb import Real_GNB
from .arch1_source_wts_handle import SourceWtsCfg

from .arch2_base import ARCH2_WTS_VARIABLES, ARCH2_WTS_TEMPLATE, ARCH2_END_CONFIGURATION
from .arch2_ue_capa import ARCH2_SPECIAL_UE_CAPA, ARCH2_NORMAL_UE_CAPA

builtin_obj = BuiltIn()


class auto_cfg(object):
    def __init__(self):
        self.command_obj_L = []
        self.update_command_obj_L = []

    def set_cfg(self, cmd_str):
        cmd_list = cmd_str.strip().split()
        command_obj = command(cmd_str)
        self.command_obj_L.append(command_obj)
        return command_obj

    def fuzzy_match(self, real_gnb_cell_obj):
        res = False
        if real_gnb_cell_obj.type == "cell" and "gnb" in real_gnb_cell_obj.diff and \
                real_gnb_cell_obj.args["gnb"] in ["2", "3"]:
            mapk = {"id": "lcrid", "pci": "pci", "tac": "tac", "gscn": "gscn", "nr_arfcn": "nrarfcn"}
            sum_cells = OrderedDict()
            if hasattr(self, "gnb2_obj") is True and hasattr(self, "gnb3_obj") is False:
                for k1, v1 in self.gnb2_obj.cells_info.items():
                    sum_cells["gnb2_%s" % k1] = v1
            if hasattr(self, "gnb2_obj") is True and hasattr(self, "gnb3_obj") is True:
                for k1, v1 in self.gnb2_obj.cells_info.items():
                    sum_cells["gnb2_%s" % k1] = v1
                for k2, v2 in self.gnb3_obj.cells_info.items():
                    sum_cells["gnb3_%s" % k2] = v2
            for k1, v1 in sum_cells.items():
                ret = real_gnb_cell_obj.args["pci"].split(":")
                if str(3 * int(ret[0]) + int(ret[1])) == v1[mapk["pci"]]:
                    for i in ["id", "tac", "gscn", "nr_arfcn"]:
                        if i in real_gnb_cell_obj.args.keys() and mapk[i] in v1.keys():
                            if real_gnb_cell_obj.args[i] != v1[mapk[i]]:
                                res = True
                                builtin_obj.log("Update Cfg Param fail! Real GNB cell param '%s' didn't match "
                                                "SCFC's value: [scfc:%s--update_cfg:%s]" %
                                                (i, v1[mapk[i]], real_gnb_cell_obj.args[i]),
                                                console=True, level="WARN")
        return res

    def update_cfg(self, cmd_str):
        ret = re.search(r"id=(\S+)", cmd_str)
        objlist = []
        if ret is not None:
            id_txt = re.search(r"id=(\S+)", cmd_str).group(1)
            if "-" not in id_txt:
                update_command_obj = command(cmd_str)
                objlist.append(update_command_obj)
            else:
                for num in range(int(id_txt.split("-")[0]), int(id_txt.split("-")[1]) + 1, ):
                    tmp_cmd_str = re.sub(r"id=(\S+)", r"id=%d" % num, cmd_str)
                    update_command_obj = command(tmp_cmd_str)
                    objlist.append(update_command_obj)
        else:
            update_command_obj = command(cmd_str)
            objlist = [update_command_obj]

        for cmd_obj in objlist:
            # if self.fuzzy_match(cmd_obj):
            #     break
            exist = False
            if cmd_obj.type == "ucp_ue":  # Update Cfg Param , maybe didn't write "suci" or "imsi"
                ret = re.search(r"ue_id=\d+", cmd_obj.diff)
                if ret is not None:
                    for i in self.command_obj_L:
                        if i.diff.endswith(ret.group()):
                            exist = True
                            cmd_obj.diff = i.diff  # The location will not change
                            self.command_obj_L.insert(self.command_obj_L.index(i), cmd_obj)
                            self.command_obj_L.remove(i)
                            break
            else:
                for i in self.command_obj_L:
                    if i.diff == cmd_obj.diff:
                        exist = True
                        if cmd_obj.type == "nwslice" and "ue" in i.args.keys():
                            if "default" in i.args.keys() and cmd_obj.args["default"] == "on":
                                cmd_obj.args["ue"] = i.args["ue"]
                        self.command_obj_L.insert(self.command_obj_L.index(i), cmd_obj)
                        self.command_obj_L.remove(i)
                        break
            if not exist:
                self.update_command_obj_L.append(cmd_obj)

    def update_cfg_param(self, cmd_str, exception=True):
        cmdl = []
        if cmd_str.startswith("ue_param") or \
                cmd_str.startswith("set_ue simulated") or cmd_str.startswith("ue_set simulated"):
            ret = re.search(r"id=(\d+\-\d+)", cmd_str)
            if ret:
                for i in range(int(ret.group(1).partition("-")[0]), int(ret.group(1).partition("-")[2]) + 1):
                    cmd = re.sub(r"id=(\d+\-\d+)", "id=%d" % i, cmd_str)
                    cmdl.append(cmd)
            else:
                cmdl = [cmd_str]
        else:
            cmdl = [cmd_str]

        for cmd in cmdl:
            exist = False
            cmd_obj = command(cmd)
            if cmd_obj.type == "ucp_ue":  # Update Cfg Param , maybe didn't write "suci" or "imsi"
                ret = re.search(r"ue_id=\d+", cmd_obj.diff)
                if ret is not None:
                    for i in self.command_obj_L:
                        if i.diff.endswith(ret.group()):
                            exist = True
                            param_str = cmd.replace(cmd_obj.cmd_header, "").strip()
                            i.modify_cmd(param_str)
            else:
                for i in self.command_obj_L:
                    if i.diff == cmd_obj.diff:
                        exist = True
                        param_str = cmd.replace(cmd_obj.cmd_header, "").strip()
                        i.modify_cmd(param_str)
            if not exist and exception:
                builtin_obj.log("Update Cfg Param fail! The NE [%s] not exist! not execute any operation this time! "
                                "Please check you case !" % cmd_obj.diff, console=True, level="ERROR")
                # raise ("Modify Param Fail ! The egate command [%s] not exist!" % cmd_str)

    def delete_cfg(self, cmd_str, exception=True):
        exist = False
        cmd_obj = command(cmd_str)
        if cmd_obj.type == "ucp_ue":  # Update Cfg Param , maybe didn't write "suci" or "imsi"
            ret = re.search(r"ue_id=\d+", cmd_obj.diff)
            if ret is not None:
                for i in self.command_obj_L:
                    if i.diff.endswith(ret.group()):
                        exist = True
                        self.command_obj_L.remove(i)
                        break
        else:
            for i in self.command_obj_L:
                if i.diff == cmd_obj.diff:
                    exist = True
                    self.command_obj_L.remove(i)
                    break
        if not exist and exception:
            builtin_obj.log("Delete Cfg fail! The NE [%s] not exist! not execute any operation this time! "
                            "Please check you case !" % i.diff, console=True, level="ERROR")
            # raise ("Delete Cfg Fail ! The egate command [%s] not exist!" % cmd_str)

    def generate_default_cfg1(self, ue_count, cfg_store_dir, cfg_file_name, source_wts_path,
                              gnb_scfc_path, ap_oam_config_path=None, mode="SA+NSA", *args, **kwargs):
        # twcf means target wts.cfg file
        self.twcf_store_dir = cfg_store_dir
        self.twcf_name = cfg_file_name
        # wov = without variables
        self.twcf_name_wov = \
            self.twcf_name.replace(self.twcf_name.partition(".")[0], "%s_wov" % self.twcf_name.partition(".")[0])
        self.twcf_path_wov = os.path.abspath(os.path.join(self.twcf_store_dir, self.twcf_name_wov))
        # wv = with variables
        self.twcf_path_wv = os.path.abspath(os.path.join(self.twcf_store_dir, self.twcf_name))

        # swc means source wts.cfg
        self.swc_obj = SourceWtsCfg(source_wts_path=source_wts_path, ap_oam_config_path=ap_oam_config_path)

        self.gnb2_obj = Real_GNB(gnb_scfc_path)

        for line in self.swc_obj.swc_body_L:
            ret = self.set_cfg(line)

        # Sync Real GNB2
        for command_obj in self.command_obj_L:
            if command_obj.diff == "gnb_id=2":
                command_obj.args["plmn"] = self.gnb2_obj.plmn
                command_obj.args["gnb_id"] = self.gnb2_obj.gnb_id
                if "xn" not in command_obj.args.keys():
                    command_obj.args["xn"] = self.gnb2_obj.ipv4_ip
            ret = re.match(r"^cell_id\^gnb=(\d+)\^2$", command_obj.diff)
            if ret:
                cell_lcrid = ret.group(1)
                if cell_lcrid in self.gnb2_obj.cells_info.keys():
                    int_pci = int(self.gnb2_obj.cells_info[cell_lcrid]["pci"])
                    command_obj.args["pci"] = "%d:%d" % (int_pci / 3, int_pci % 3)  # eg:52 ==>17:1

                    if "tac" in self.gnb2_obj.cells_info[cell_lcrid].keys():
                        command_obj.args["tac"] = self.gnb2_obj.cells_info[cell_lcrid]["tac"]

                    command_obj.args["nr_arfcn"] = self.gnb2_obj.cells_info[cell_lcrid]["nrarfcn"]

                    cell_gscn = self.gnb2_obj.cells_info[cell_lcrid]["gscn"]
                    if cell_gscn not in ["0", "1", "2"]:
                        command_obj.args["gscn"] = cell_gscn
                    else:
                        if "gscn" in command_obj.args.keys():
                            del command_obj.args["gscn"]
                else:
                    self.command_obj_L.remove(command_obj)
                    delete_ue_id = []
                    delete_base_wts_cmd = []
                    for item in self.command_obj_L:
                        if item.type in ["sa_ue", "nsa_ue", "ucp_ue"] \
                                and (hasattr(item, "enb") and item.enb == "2") \
                                and (hasattr(item, "cell") and item.cell == str(cell_lcrid)):
                            self.command_obj_L.remove(item)
                            delete_base_wts_cmd.append(item.generate_cmd())
                            delete_ue_id.append(item.id)
                    for item in self.command_obj_L:
                        if item.type in ["nsa_ue_param", "sa_ue_param"] \
                                and (hasattr(item, "id") and str(item.id) in delete_ue_id):
                            self.command_obj_L.remove(item)
                            delete_base_wts_cmd.append(item.generate_cmd())
                        elif item.type in ["set_bearer", "bearer_set"] \
                                and (hasattr(item, "ue") and str(item.ue) in delete_ue_id):
                            self.command_obj_L.remove(item)
                            delete_base_wts_cmd.append(item.generate_cmd())

        self.mode = mode.lower()
        self.plan_sa_ue_id = []
        self.plan_nsa_ue_id = []

        if self.mode == "sa+nsa":
            for id in range(1, int(ue_count) + 1):
                self.plan_sa_ue_id.append(str(id))
            if len(self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_id"]) > 0:
                if self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_id"][0] in self.plan_sa_ue_id:
                    for id in range(int(self.plan_sa_ue_id[-1]) + 1, int(self.plan_sa_ue_id[-1]) + 1 + int(ue_count)):
                        self.plan_nsa_ue_id.append(str(id))
                else:
                    for id in range(int(self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_id"][0]),
                                    int(self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_id"][0]) + int(ue_count)):
                        self.plan_nsa_ue_id.append(str(id))
        elif self.mode == "sa":
            for id in range(int(self.swc_obj.swc_paras["swc_ue_releated"]["sa_ue_id"][0]), int(ue_count) + 1):
                self.plan_sa_ue_id.append(str(id))
        elif self.mode == "nsa":
            for id in range(int(self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_id"][0]), int(ue_count) + 1):
                self.plan_nsa_ue_id.append(str(id))

        if (self.mode == "sa+nsa" or self.mode == "sa") and len(self.swc_obj.swc_paras["sa_ue_template"]) > 0:
            pre = ":".join(self.swc_obj.swc_paras["sa_ue_template"]["suci"].split(":")[:-1])
            num = int(self.swc_obj.swc_paras["sa_ue_template"]["suci"].split(":")[-1])
            zero_head = "0" * (len(self.swc_obj.swc_paras["sa_ue_template"]["suci"].split(":")[-1]) - len(str(num)))
            suci_add = 1
            for sa_ue_id in self.plan_sa_ue_id:
                if sa_ue_id in self.swc_obj.swc_paras["swc_ue_releated"]["sa_ue_id"]:
                    # suci_add += 1
                    continue
                else:
                    tmp_cmd = re.sub(r"id=\d+", "id=%s" % sa_ue_id,
                                     self.swc_obj.swc_paras["sa_ue_template"]["whole_ue_cmd"])
                    tmp_cmd = re.sub(r"suci=\S+", "suci=%s:%s%s" % (pre, zero_head, str(num + suci_add)), tmp_cmd)
                    self.set_cfg(cmd_str=tmp_cmd)
                    suci_add += 1

                    tmp_cmd = re.sub(r"id=\d+", "id=%s" % sa_ue_id,
                                     self.swc_obj.swc_paras["sa_ue_template"]["ue_param_whole_cmd"])
                    self.set_cfg(cmd_str=tmp_cmd)

            # nwslice
            for cmd in self.swc_obj.swc_paras["swc_ue_releated"]["nwslice_cmd"]:
                num = re.search(r"ue=(\S+)", cmd).group(1)
                if num != "all":
                    numL = num.split(",")
                    resL = []
                    for i in numL:
                        if i.count("-"):
                            iL = range(int(i.split("-")[0]), int(i.split("-")[-1]) + 1)
                            resL += [str(j) for j in iL]
                        else:
                            resL.append(i)

                    resL.sort()
                    if resL == self.swc_obj.swc_paras["swc_ue_releated"]["sa_ue_id"]:
                        new_cmd = re.sub(r"ue=\S+", "ue=all", cmd)
                        for obj in self.command_obj_L:
                            if obj.generate_cmd() == cmd:
                                self.command_obj_L.remove(obj)
                        self.set_cfg(new_cmd)
                    elif resL == self.swc_obj.swc_paras["swc_ue_releated"]["ca_sa_ue_id"]:
                        pass
                    else:
                        pass

        if (self.mode == "sa+nsa" or self.mode == "nsa") and len(self.swc_obj.swc_paras["nsa_ue_template"]) > 0:
            pre = ":".join(self.swc_obj.swc_paras["nsa_ue_template"]["imsi"].split(":")[:-1])
            num = int(self.swc_obj.swc_paras["nsa_ue_template"]["imsi"].split(":")[-1])
            imsi_add = 0
            pdn_ip_start = IPy.IP(self.swc_obj.swc_paras["bearer_template"]["pdn_ip"]).int()
            tmp_pdn_ip = pdn_ip_start
            for nsa_ue_id in self.plan_nsa_ue_id:
                index = self.plan_nsa_ue_id.index(nsa_ue_id)
                if index < len(self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_cmd"]):
                    exist_ue_cmd = self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_cmd"][index]
                    exist_ue_id = re.search(r"id=(\d+)", exist_ue_cmd).group(1)
                    for obj in self.command_obj_L:
                        if obj.type == "nsa_ue" and obj.diff.split("=")[-1] == exist_ue_id:
                            tmp_cmd = re.sub(r"id=(\d+)", "id=%s" % nsa_ue_id, exist_ue_cmd)
                            self.command_obj_L.remove(obj)
                            self.set_cfg(cmd_str=tmp_cmd)
                    for obj in self.command_obj_L:
                        if obj.type == "nsa_ue_param" and obj.diff.split("=")[-1] == exist_ue_id:
                            tmp_cmd = re.sub(r"id=(\d+)", "id=%s" % nsa_ue_id, obj.generate_cmd())
                            self.command_obj_L.remove(obj)
                            self.set_cfg(cmd_str=tmp_cmd)
                    for obj in self.command_obj_L:
                        if obj.type == "bearer" and obj.diff.split("=")[-1].split("^")[-1] == exist_ue_id:
                            tmp_cmd = re.sub(r"ue=(\d+)", "ue=%s" % nsa_ue_id, obj.generate_cmd())
                            self.command_obj_L.remove(obj)
                            self.set_cfg(cmd_str=tmp_cmd)
                    imsi_add += 1
                else:
                    tmp_cmd = re.sub(r"id=(\d+)", "id=%s" % nsa_ue_id,
                                     self.swc_obj.swc_paras["nsa_ue_template"]["whole_ue_cmd"])
                    tmp_cmd = re.sub(r"imsi=\S+", "imsi=%s:%s" % (pre, str(num + imsi_add)), tmp_cmd)
                    self.set_cfg(cmd_str=tmp_cmd)

                    tmp_cmd = re.sub(r"id=\d+", "id=%s" % nsa_ue_id,
                                     self.swc_obj.swc_paras["nsa_ue_template"]["ue_param_whole_cmd"])
                    self.set_cfg(cmd_str=tmp_cmd)

                    tmp_pdn_ip = IPy.intToIp(IPy.IP(tmp_pdn_ip).int() + 1, 4)
                    while tmp_pdn_ip in self.swc_obj.swc_paras["swc_ue_releated"]["exist_bearer_pdn_ip"]:
                        tmp_pdn_ip = IPy.intToIp(IPy.IP(tmp_pdn_ip).int() + 1, 4)

                    tmp_cmd = re.sub(r"ue=\S+", "ue=%s" % nsa_ue_id,
                                     self.swc_obj.swc_paras["bearer_template"]["whole_cmd"])
                    tmp_cmd = re.sub(r"ip=\S+", "ip=%s" % tmp_pdn_ip, tmp_cmd)
                    self.set_cfg(tmp_cmd)
                    imsi_add += 1

        # auto configure same count pdu_gateway for all UEs (SA,NSA,CA SA,CA NSA)
        ue_pdugateway_map = OrderedDict()  # ue_id:mapping_pdu_gateway_whole_command
        exist_pdugateway = OrderedDict()   # pdu_gateway_id:cmd_obj
        for i in self.command_obj_L:
            if i.type == "sa_ue" or i.type == "nsa_ue":
                ue_pdugateway_map[i.args["id"]] = None
            elif i.type == "pdu_gateway":
                exist_pdugateway[i.args["id"]] = i

        ret1 = sorted(ue_pdugateway_map.items(),
                      key=lambda ue_pdugateway_map: int(ue_pdugateway_map[0]),
                      reverse=False)  # ret1 is <class 'list'>
        ret2 = sorted(exist_pdugateway.items(),
                      key=lambda exist_pdugateway: int(exist_pdugateway[0]),
                      reverse=False)  # ret2 is <class 'list'>

        if len(ret2) > 0:
            pdu_gateway_cmd_template = ret2[0][1].generate_cmd()
            template_ue_nat_ip = re.search(r"ue_nat_ip=(\S+)", pdu_gateway_cmd_template).group(1)

            for j in exist_pdugateway.values():
                self.command_obj_L.remove(j)

            for k in ret1:
                tmp = template_ue_nat_ip.split(".")
                tmp[2] = str(int(k[0]) - 1)
                map_pdugateway_cmd = pdu_gateway_cmd_template.replace(
                    re.search(r"id=\S+", pdu_gateway_cmd_template).group(0), "id=%s" % k[0])
                map_pdugateway_cmd = map_pdugateway_cmd.replace(
                    re.search(r"ue_nat_ip=\S+", map_pdugateway_cmd).group(0),
                    "ue_nat_ip=%s" % ".".join(tmp))
                self.set_cfg(map_pdugateway_cmd)

    def generate_default_cfg2(self, ue_count, cfg_store_dir, cfg_file_name, source_wts_path,
                              gnb1_scfc_path, gnb2_scfc_path, ap_oam_config_path=None, mode="SA+NSA",
                              *args, **kwargs):
        # twcf means target wts.cfg file
        self.twcf_store_dir = cfg_store_dir
        self.twcf_name = cfg_file_name
        # wov = without variables
        self.twcf_name_wov = \
            self.twcf_name.replace(self.twcf_name.partition(".")[0], "%s_wov" % self.twcf_name.partition(".")[0])
        self.twcf_path_wov = os.path.abspath(os.path.join(self.twcf_store_dir, self.twcf_name_wov))
        # wv = with variables
        self.twcf_path_wv = os.path.abspath(os.path.join(self.twcf_store_dir, self.twcf_name))

        # swc means source wts.cfg
        self.swc_obj = SourceWtsCfg(source_wts_path=source_wts_path, ap_oam_config_path=ap_oam_config_path)

        self.gnb2_obj = Real_GNB(gnb1_scfc_path)
        self.gnb3_obj = Real_GNB(gnb2_scfc_path)

        for line in self.swc_obj.swc_body_L:
            ret = self.set_cfg(line)

        # Sync Real GNB2
        for command_obj in self.command_obj_L:
            if command_obj.diff == "gnb_id=2":
                command_obj.args["plmn"] = self.gnb2_obj.plmn
                command_obj.args["gnb_id"] = self.gnb2_obj.gnb_id
                if "xn" not in command_obj.args.keys():
                    command_obj.args["xn"] = self.gnb2_obj.ipv4_ip
            ret = re.match(r"^cell_id\^gnb=(\d+)\^2$", command_obj.diff)
            if ret:
                cell_lcrid = ret.group(1)

                int_pci = int(self.gnb2_obj.cells_info[cell_lcrid]["pci"])
                command_obj.args["pci"] = "%d:%d" % (int_pci / 3, int_pci % 3)

                if "tac" in self.gnb2_obj.cells_info[cell_lcrid].keys():
                    command_obj.args["tac"] = self.gnb2_obj.cells_info[cell_lcrid]["tac"]

                command_obj.args["nr_arfcn"] = self.gnb2_obj.cells_info[cell_lcrid]["nrarfcn"]

                cell_gscn = self.gnb2_obj.cells_info[cell_lcrid]["gscn"]
                if cell_gscn not in ["0", "1", "2"]:
                    command_obj.args["gscn"] = cell_gscn
                else:
                    if "gscn" in command_obj.args.keys():
                        del command_obj.args["gscn"]

        # Sync Real GNB3
        for command_obj in self.command_obj_L:
            if command_obj.diff == "gnb_id=3":
                command_obj.args["plmn"] = self.gnb3_obj.plmn
                command_obj.args["gnb_id"] = self.gnb3_obj.gnb_id
                if "xn" not in command_obj.args.keys():
                    command_obj.args["xn"] = self.gnb3_obj.ipv4_ip
            ret = re.match(r"^cell_id\^gnb=(\d+)\^3$", command_obj.diff)
            if ret:
                cell_lcrid = ret.group(1)

                int_pci = int(self.gnb3_obj.cells_info[cell_lcrid]["pci"])
                command_obj.args["pci"] = "%d:%d" % (int_pci / 3, int_pci % 3)

                if "tac" in self.gnb3_obj.cells_info[cell_lcrid].keys():
                    command_obj.args["tac"] = self.gnb3_obj.cells_info[cell_lcrid]["tac"]

                command_obj.args["nr_arfcn"] = self.gnb3_obj.cells_info[cell_lcrid]["nrarfcn"]

                cell_gscn = self.gnb3_obj.cells_info[cell_lcrid]["gscn"]
                if cell_gscn not in ["0", "1", "2"]:
                    command_obj.args["gscn"] = cell_gscn
                else:
                    if "gscn" in command_obj.args.keys():
                        del command_obj.args["gscn"]

        self.mode = mode.lower()
        self.plan_sa_ue_id = []
        self.plan_nsa_ue_id = []

        if self.mode == "sa+nsa":
            for id in range(1, int(ue_count) + 1):
                self.plan_sa_ue_id.append(str(id))
            if len(self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_id"]) > 0:
                if self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_id"][0] in self.plan_sa_ue_id:
                    for id in range(int(self.plan_sa_ue_id[-1]) + 1, int(self.plan_sa_ue_id[-1]) + 1 + int(ue_count)):
                        self.plan_nsa_ue_id.append(str(id))
                else:
                    for id in range(int(self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_id"][0]),
                                    int(self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_id"][0]) + int(ue_count)):
                        self.plan_nsa_ue_id.append(str(id))
        elif self.mode == "sa":
            for id in range(int(self.swc_obj.swc_paras["swc_ue_releated"]["sa_ue_id"][0]), int(ue_count) + 1):
                self.plan_sa_ue_id.append(str(id))
        elif self.mode == "nsa":
            for id in range(int(self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_id"][0]), int(ue_count) + 1):
                self.plan_nsa_ue_id.append(str(id))

        if (self.mode == "sa+nsa" or self.mode == "sa") and len(self.swc_obj.swc_paras["sa_ue_template"]) > 0:
            pre = ":".join(self.swc_obj.swc_paras["sa_ue_template"]["suci"].split(":")[:-1])
            num = int(self.swc_obj.swc_paras["sa_ue_template"]["suci"].split(":")[-1])
            zero_head = "0" * (len(self.swc_obj.swc_paras["sa_ue_template"]["suci"].split(":")[-1]) - len(str(num)))
            suci_add = 1
            for sa_ue_id in self.plan_sa_ue_id:
                if sa_ue_id in self.swc_obj.swc_paras["swc_ue_releated"]["sa_ue_id"]:
                    # suci_add += 1
                    continue
                else:
                    tmp_cmd = re.sub(r"id=\d+", "id=%s" % sa_ue_id,
                                     self.swc_obj.swc_paras["sa_ue_template"]["whole_ue_cmd"])
                    tmp_cmd = re.sub(r"suci=\S+", "suci=%s:%s%s" % (pre, zero_head, str(num + suci_add)), tmp_cmd)
                    self.set_cfg(cmd_str=tmp_cmd)
                    suci_add += 1

                    tmp_cmd = re.sub(r"id=\d+", "id=%s" % sa_ue_id,
                                     self.swc_obj.swc_paras["sa_ue_template"]["ue_param_whole_cmd"])
                    self.set_cfg(cmd_str=tmp_cmd)

            # nwslice
            for cmd in self.swc_obj.swc_paras["swc_ue_releated"]["nwslice_cmd"]:
                num = re.search(r"ue=(\S+)", cmd).group(1)
                if num != "all":
                    numL = num.split(",")
                    resL = []
                    for i in numL:
                        if i.count("-"):
                            iL = range(int(i.split("-")[0]), int(i.split("-")[-1]) + 1)
                            resL += [str(j) for j in iL]
                        else:
                            resL.append(i)

                    resL.sort()
                    if resL == self.swc_obj.swc_paras["swc_ue_releated"]["sa_ue_id"]:
                        new_cmd = re.sub(r"ue=\S+", "ue=all", cmd)
                        # new_cmd = re.sub(r"ue=\S+", r"ue=%s-%s" % (
                        #     self.plan_sa_ue_id[0], self.plan_sa_ue_id[-1]), cmd)
                        for obj in self.command_obj_L:
                            if obj.generate_cmd() == cmd:
                                self.command_obj_L.remove(obj)
                        self.set_cfg(new_cmd)
                    elif resL == self.swc_obj.swc_paras["swc_ue_releated"]["ca_sa_ue_id"]:
                        pass
                    else:
                        pass

        if (self.mode == "sa+nsa" or self.mode == "nsa") and len(self.swc_obj.swc_paras["nsa_ue_template"]) > 0:
            pre = ":".join(self.swc_obj.swc_paras["nsa_ue_template"]["imsi"].split(":")[:-1])
            num = int(self.swc_obj.swc_paras["nsa_ue_template"]["imsi"].split(":")[-1])
            imsi_add = 0
            pdn_ip_start = IPy.IP(self.swc_obj.swc_paras["bearer_template"]["pdn_ip"]).int()
            tmp_pdn_ip = pdn_ip_start
            for nsa_ue_id in self.plan_nsa_ue_id:
                index = self.plan_nsa_ue_id.index(nsa_ue_id)
                if index < len(self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_cmd"]):
                    exist_ue_cmd = self.swc_obj.swc_paras["swc_ue_releated"]["nsa_ue_cmd"][index]
                    exist_ue_id = re.search(r"id=(\d+)", exist_ue_cmd).group(1)
                    for obj in self.command_obj_L:
                        if obj.type == "nsa_ue" and obj.diff.split("=")[-1] == exist_ue_id:
                            tmp_cmd = re.sub(r"id=(\d+)", "id=%s" % nsa_ue_id, exist_ue_cmd)
                            self.command_obj_L.remove(obj)
                            self.set_cfg(cmd_str=tmp_cmd)
                    for obj in self.command_obj_L:
                        if obj.type == "nsa_ue_param" and obj.diff.split("=")[-1] == exist_ue_id:
                            tmp_cmd = re.sub(r"id=(\d+)", "id=%s" % nsa_ue_id, obj.generate_cmd())
                            self.command_obj_L.remove(obj)
                            self.set_cfg(cmd_str=tmp_cmd)
                    for obj in self.command_obj_L:
                        if obj.type == "bearer" and obj.diff.split("=")[-1].split("^")[-1] == exist_ue_id:
                            tmp_cmd = re.sub(r"ue=(\d+)", "ue=%s" % nsa_ue_id, obj.generate_cmd())
                            self.command_obj_L.remove(obj)
                            self.set_cfg(cmd_str=tmp_cmd)
                    imsi_add += 1
                else:
                    tmp_cmd = re.sub(r"id=(\d+)", "id=%s" % nsa_ue_id,
                                     self.swc_obj.swc_paras["nsa_ue_template"]["whole_ue_cmd"])
                    tmp_cmd = re.sub(r"imsi=\S+", "imsi=%s:%s" % (pre, str(num + imsi_add)), tmp_cmd)
                    self.set_cfg(cmd_str=tmp_cmd)

                    tmp_cmd = re.sub(r"id=\d+", "id=%s" % nsa_ue_id,
                                     self.swc_obj.swc_paras["nsa_ue_template"]["ue_param_whole_cmd"])
                    self.set_cfg(cmd_str=tmp_cmd)

                    tmp_pdn_ip = IPy.intToIp(IPy.IP(tmp_pdn_ip).int() + 1, 4)
                    while tmp_pdn_ip in self.swc_obj.swc_paras["swc_ue_releated"]["exist_bearer_pdn_ip"]:
                        tmp_pdn_ip = IPy.intToIp(IPy.IP(tmp_pdn_ip).int() + 1, 4)

                    tmp_cmd = re.sub(r"ue=\S+", "ue=%s" % nsa_ue_id,
                                     self.swc_obj.swc_paras["bearer_template"]["whole_cmd"])
                    tmp_cmd = re.sub(r"ip=\S+", "ip=%s" % tmp_pdn_ip, tmp_cmd)
                    self.set_cfg(cmd_str=tmp_cmd)
                    imsi_add += 1

        # auto configure same count pdu_gateway for all UEs (SA,NSA,CA SA,CA NSA)
        ue_pdugateway_map = OrderedDict()  # ue_id:mapping_pdu_gateway_whole_command
        exist_pdugateway = OrderedDict()   # pdu_gateway_id:cmd_obj
        for i in self.command_obj_L:
            if i.type == "sa_ue" or i.type == "nsa_ue":
                ue_pdugateway_map[i.args["id"]] = None
            elif i.type == "pdu_gateway":
                exist_pdugateway[i.args["id"]] = i

        ret1 = sorted(ue_pdugateway_map.items(),
                      key=lambda ue_pdugateway_map: int(ue_pdugateway_map[0]),
                      reverse=False)  # ret1 is <class 'list'>
        ret2 = sorted(exist_pdugateway.items(),
                      key=lambda exist_pdugateway: int(exist_pdugateway[0]),
                      reverse=False)  # ret2 is <class 'list'>

        if len(ret2) > 0:
            pdu_gateway_cmd_template = ret2[0][1].generate_cmd()
            template_ue_nat_ip = re.search(r"ue_nat_ip=(\S+)", pdu_gateway_cmd_template).group(1)

            for j in exist_pdugateway.values():
                self.command_obj_L.remove(j)

            for k in ret1:
                tmp = template_ue_nat_ip.split(".")
                tmp[2] = str(int(k[0]) - 1)
                map_pdugateway_cmd = pdu_gateway_cmd_template.replace(
                    re.search(r"id=\S+", pdu_gateway_cmd_template).group(0), "id=%s" % k[0])
                map_pdugateway_cmd = map_pdugateway_cmd.replace(
                    re.search(r"ue_nat_ip=\S+", map_pdugateway_cmd).group(0),
                    "ue_nat_ip=%s" % ".".join(tmp))
                self.set_cfg(map_pdugateway_cmd)

    def sort_command_obj(self):
        self.sort_attr = ["enb_id", "enb_param_id", "cell_id^enb", "enb_endc_param_id", "enb_cell_param_id^enb",
                          "mme_pool_area_id", "mme_id", "sgw_id", "pgw_id",
                          "amf_region_id", "amf_id", "amf_param_id", "amf_ng_setup_param_id", "upf_id",
                          "amf_ng_setup_param", "backup_amf",
                          "gnb_id", "gnb_param_id", "gnb_endc_param_id",
                          "cell_srs_beam_pos_nr^profile_id", "cell_testmode_set_nr_cell_id^gnb",
                          "cell_id^gnb", "gnb_cell_param_id^gnb",
                          "enb_timer", "uec_id", "uec_param_id",
                          "sa_ue_id", "sa_ue_param_id", "nsa_ue_id", "nsa_ue_param_id",
                          "ue_nr_capabilities_id",
                          "qci_qci", "bearer_id^ue", "qosflow_id", "qosrule_id", "nwslice_id", "pdu_gateway_id",
                          "amf_ue_ics_param_id",
                          "gnb_make_plmnset*plmn_set_id",
                          "gnb_set_nwslice_per_plmn_gnb^cell^plmn_set_id^plmn",
                          "enb_xp_param_id",
                          ]
        command_obj_diff_prefix = []
        last_cmd = []
        for i in self.command_obj_L:
            command_obj_diff_prefix.append(i.diff.split("=")[0].strip())
        command_obj_diff_prefix = list(set(command_obj_diff_prefix))
        intersection = [i for i in self.sort_attr if i in command_obj_diff_prefix]
        intersection.sort(key=lambda i: self.sort_attr.index(i), reverse=False)
        rest = [i for i in command_obj_diff_prefix if i not in self.sort_attr]
        if len(rest) > 0:
            builtin_obj.log("Below NE didn't exist in sort_attr,if trigger issue,"
                            "please contact eric.jiang@nokia-sbell.com\n%s" % rest, console=True, level="INFO")
            for i in rest:
                intersection.append(i)
        self.command_obj_L.sort(key=lambda i: intersection.index(i.diff.split("=")[0].strip()), reverse=False)

    def teardown_cfg(self):
        try:
            tail_debug_log_level = builtin_obj.get_variable_value("${DEBUG_LOG_LEVEL}")
            tail_ap_log_level = builtin_obj.get_variable_value("${AP_UDPLOG_LEVEL}")
            if tail_debug_log_level is None:
                tail_debug_log_level = "2"
            if tail_ap_log_level is None:
                tail_ap_log_level = "1"
        except Exception as e:
            if str(e) == "Cannot access execution context":  # for local debugging on my own laptop
                tail_debug_log_level = "2"
                tail_ap_log_level = "1"

        self.define_tail_L = []
        for tail_line in self.swc_obj.swc_tail_L:
            try:
                if tail_line.split()[0].lower() in ["debug_log", "sim_debug_log"]:
                    ret = re.sub(r"level\s*=\s*\d+", "level=%s" % tail_debug_log_level, tail_line)
                else:
                    ret = tail_line
            except Exception as e:
                print("Handle tail command lines exception")
                ret = tail_line
            self.define_tail_L.append(ret)

        self.nwc_nv_L = []  # nwc means Need Write Cmd & nv means No Variables
        self.rwc_nv_L = []  # rwc means Real Write Cmd & nv means No Variables

        self.command_obj_L += self.update_command_obj_L
        self.sort_command_obj()

        for line in self.command_obj_L:
            self.nwc_nv_L.append(line)

        self.rwc_nv_L.append("#" + "-" * 100)
        self.rwc_nv_L.append("#VARIABLES")
        self.rwc_nv_L.append("#" + "-" * 100)
        for k, v in self.swc_obj.swc_paras["swc_variables"].items():
            ret = 'set %s="%s"' % (k, v)
            self.rwc_nv_L.append(ret)
        self.rwc_nv_L.append("\n")

        def NWC_RWC(title, re_part_list):
            self.rwc_nv_L.append("#" + "-" * 100)
            self.rwc_nv_L.append("#%s" % title)
            self.rwc_nv_L.append("#" + "-" * 100)
            for i in re_part_list:
                for j in self.nwc_nv_L:
                    if re.match(i, j.diff) is not None:
                        self.rwc_nv_L.append(j)
                self.nwc_nv_L = [k for k in self.nwc_nv_L if k not in self.rwc_nv_L]
            self.rwc_nv_L.append("\n")

        NWC_RWC("ENB CONFIGURATION",
                [r"^enb_id=\d+$", r"^enb_param_id=\d+$", r"^cell_id\^enb=\d+\^\d+$",
                 r"enb_cell_param_id\^enb=\d+\^\d+$", r"^enb_endc_param_id=\d+$"])

        NWC_RWC("EPC CONFIGURATION",
                [r"^mme_pool_area_id=\d+$", r"^mme_id=\d+$", r"^sgw_id=\d+$", r"^pgw_id=\d+$"])

        NWC_RWC("GNB CONFIGURATION",
                [r"^gnb_id=\d+$", r"^gnb_param_id=\d+$",
                 r"^cell_id\^gnb=\d+\^\d+$",
                 r"gnb_cell_param_id\^gnb=\d+\^\d+$", r"^gnb_endc_param_id=\d+$"])

        NWC_RWC("5GCN CONFIGURATION",
                [r"^amf_region_id=\d+$", r"^amf_id=\d+$", r"^amf_param_id=\d+$", r"^upf_id=\d+$", r"^backup_amf$",
                 r"^amf_ng_setup_param_id=\d+$"])

        NWC_RWC("UEC CONFIGURATION",
                [r"^uec_id=\d+$", r"^uec_param_id=\d+$"])

        NWC_RWC("SA UE CONFIGURATION",
                [r"^sa_ue_id=\d+$", r"^sa_ue_param_id=\d+$", r"^amf_ue_ics_param_id=\S+$"])  # id may be 1,2,3

        NWC_RWC("NSA UE CONFIGURATION",
                [r"^nsa_ue_id=\d+$", r"^nsa_ue_param_id=\d+$", r"^qci_qci=\d+$", r"^bearer_id\^ue=\d+\^\d+$"])

        NWC_RWC("COMMON CONFIGURATION",
                [r"^qosflow_id=\d+$", r"^qosrule_id=\d+$", r"^nwslice_id=\d+$", r"^pdu_gateway_id=\d+$"])

        if len(self.nwc_nv_L) > 0:
            self.rwc_nv_L.append("#" + "-" * 100)
            self.rwc_nv_L.append("# CONFIGURATION NOT CLASSIFICATION")
            self.rwc_nv_L.append("#" + "-" * 100)
            for cnc in self.nwc_nv_L:
                self.rwc_nv_L.append(cnc)  # cnc must be a command obj
            self.rwc_nv_L.append("\n")

        self.rwc_nv_L.append("#" + "-" * 100)
        self.rwc_nv_L.append("#OTHER CONFIGURATION")
        self.rwc_nv_L.append("#" + "-" * 100)

        for line in self.define_tail_L:
            self.rwc_nv_L.append(line)

        # Start to generate wts.cfg & wts_wov.cfg actually
        self.twcf_file_wov = cfg_file_generator(self.twcf_path_wov)
        self.twcf_file_wov.setup()
        for i in self.rwc_nv_L:
            if isinstance(i, command):
                self.twcf_file_wov.write_content(i.generate_cmd())
            else:
                self.twcf_file_wov.write_content(i)
        self.twcf_file_wov.teardown()

        self.twcf_file_wv = cfg_file_generator(self.twcf_path_wv)
        self.twcf_file_wv.setup()
        res_rwc_nv_L = self.rwc_nv_L
        for i in res_rwc_nv_L:
            if isinstance(i, command):
                cmd = i.generate_cmd()
                ret = re.findall(r"\S+=\d+\.\d+\.\d+\.\d+", cmd)  # eg:s1=10.0.1.131
                if ret != []:
                    for diffv, obj in self.swc_obj.swc_vari_cmd_map.items():
                        if diffv == i.diff:
                            for arg_name, arg_value in i.args.items():
                                # 10.0.2.1
                                # 10.0.2.1:22222
                                # 10.0.2.80:9999|10.0.2.80:8888
                                ret1 = re.match(r"^\d+\.\d+\.\d+\.\d+[\:\d+]*\|*\d*\.*\d*\.*\d*\.*\d*[\:\d+]*",
                                                arg_value)
                                if ret1 is not None:
                                    if arg_name in obj.args:
                                        tmpstr = obj.args[arg_name]
                                        ret2 = re.findall(r"\$[A-Za-z0-9_]+", tmpstr)
                                        for z in ret2:
                                            tmpstr = re.sub(r"\%s" % z,
                                                            self.swc_obj.swc_paras["swc_variables"][z[1:]],
                                                            tmpstr)
                                        if tmpstr == i.args[arg_name]:
                                            i.args[arg_name] = obj.args[arg_name]
                                    else:
                                        pass
                self.twcf_file_wv.write_content(i.generate_cmd())
            else:
                self.twcf_file_wv.write_content(i)
        self.twcf_file_wv.teardown()

    # =============================================================================================================
    # Below is arch2 interface corresponding Function
    # Will generate a large configuration include TDD+FDD, NSA+SA
    # default_ue_info = {"sa": "1-10", "nsa": "11-20", "ca_sa": "80-90", "ca_nsa": "91-100"}
    def arch2_update_cfg(self, cmd_str):
        cmdl = []
        if cmd_str.startswith("ue_param"):
            ret1 = re.search(r"id=(\d+) ", cmd_str)
            ret2 = re.search(r"id=(\d+\-\d+) ", cmd_str)
            if ret1 is not None:
                cmd = re.sub(r"id=(\d+)", "id=%d" % int(ret1.group(1)), cmd_str)
                cmdl.append(cmd)
            elif ret2 is not None:
                for i in range(int(ret2.group(1).partition("-")[0]), int(ret2.group(1).partition("-")[2]) + 1):
                    cmd = re.sub(r"id=(\d+\-\d+)", "id=%d" % i, cmd_str)
                    cmdl.append(cmd)
        else:
            cmdl = [cmd_str]

        for cmd in cmdl:
            exist_cmd = False
            cmd_obj = command(cmd)
            update_cmd_list = cmd.split()
            update_cmd_header = update_cmd_list[0]
            update_cmd_content = " ".join(update_cmd_list[1:])
            varis = re.findall(r"\$[A-Za-z_]+", update_cmd_content)
            if varis != []:
                for i in varis:
                    if i not in ARCH2_WTS_VARIABLES.keys():
                        raise ("Arch2 Update Cfg Fail [%s] '%s' not exist!" % (cmd, i))
            if cmd_obj.type == "ucp_ue":  # Update Cfg , maybe didn't write "suci" or "imsi"
                ret = re.search(r"ue_id=\d+", cmd_obj.diff)
                if ret is not None:
                    for k1, v1 in self.arch2_cmd_obj.items():
                        for k2, v2 in v1.items():
                            for i in v2:
                                if i.diff.endswith(ret.group()):
                                    exist_cmd = True
                                    param_str = cmd.replace(cmd_obj.cmd_header, "").strip()
                                    i.replace_cmd(param_str)
            else:
                for k1, v1 in self.arch2_cmd_obj.items():
                    for k2, v2 in v1.items():
                        for i in v2:
                            if i.diff == cmd_obj.diff:
                                exist_cmd = True
                                if i.type == "nwslice" and "ue" in i.args.keys():
                                    ori = i.args["ue"]
                                    i.args = cmd_obj.args
                                    if "default" in cmd_obj.args.keys() and cmd_obj.args["default"] == "on":
                                        i.args["ue"] = ori
                                else:
                                    i.args = cmd_obj.args
                                break
            if not exist_cmd:
                if cmd_obj.type in self.arch2_cmd_obj["COMMON_CONFIGURATION"].keys():
                    self.arch2_cmd_obj["COMMON_CONFIGURATION"][cmd_obj.type].append(cmd_obj)
                else:
                    self.arch2_cmd_obj["MODIFY_ADD_CONFIGURATION"]["new_add"].append(cmd_obj)

    def arch2_update_cfg_param(self, cmd_str, exception=True):
        cmdl = []
        if cmd_str.startswith("ue_param") or \
                cmd_str.startswith("set_ue simulated") or cmd_str.startswith("ue_set simulated"):
            ret = re.search(r"id=(\d+\-\d+)", cmd_str)
            if ret:
                for i in range(int(ret.group(1).partition("-")[0]), int(ret.group(1).partition("-")[2]) + 1):
                    cmd = re.sub(r"id=(\d+\-\d+)", "id=%d" % i, cmd_str)
                    cmdl.append(cmd)
            else:
                cmdl = [cmd_str]
        else:
            cmdl = [cmd_str]

        for cmd in cmdl:
            exist = False
            cmd_obj = command(cmd)
            if cmd_obj.type == "ucp_ue":  # Update Cfg Param , maybe didn't write "suci" or "imsi"
                ret = re.search(r"ue_id=\d+", cmd_obj.diff)
                if ret is not None:
                    for k1, v1 in self.arch2_cmd_obj.items():
                        for k2, v2 in v1.items():
                            for i in v2:
                                if i.diff.endswith(ret.group()):
                                    exist = True
                                    param_str = cmd.replace(cmd_obj.cmd_header, "").strip()
                                    i.modify_cmd(param_str)
            else:
                for k1, v1 in self.arch2_cmd_obj.items():
                    for k2, v2 in v1.items():
                        for i in v2:
                            if i.diff == cmd_obj.diff:
                                exist = True
                                param_str = cmd.replace(cmd_obj.cmd_header, "").strip()
                                i.modify_cmd(param_str)
            if not exist and exception:
                builtin_obj.log("Arch2 Update Cfg Param fail! The NE [%s] not exist! not execute any "
                                "operation this time! Please check you case !" % cmd_obj.diff,
                                console=True, level="ERROR")

    def arch2_delete_cfg(self, cmd_str, exception=True):
        exist_cmd = False
        cmd_obj = command(cmd_str)
        if cmd_obj.type == "ucp_ue":  # Update Cfg Param , maybe didn't write "suci" or "imsi"
            ret = re.search(r"ue_id=\d+", cmd_obj.diff)
            if ret is not None:
                for k1, v1 in self.arch2_cmd_obj.items():
                    for k2, v2 in v1.items():
                        for i in v2:
                            if i.diff.endswith(ret.group()):
                                exist_cmd = True
                                self.arch2_cmd_obj[k1][k2].remove(i)
        else:
            for k1, v1 in self.arch2_cmd_obj.items():
                for k2, v2 in v1.items():
                    for i in v2:
                        if i.diff == cmd_obj.diff:
                            exist_cmd = True
                            self.arch2_cmd_obj[k1][k2].remove(i)
                            break
        if not exist_cmd and exception:
            builtin_obj.log("Arch2 Delete Cfg fail! The NE [%s] not exist! not execute any operation this time! "
                            "Please check you case !" % i.diff, console=True, level="ERROR")

    def arch2_generate_default_cfg1(self, gnb_scfc_path, cfg_store_path, mode="SA+NSA", ue_info={},
                                    *args, **kwargs):
        self.scfc = gnb_scfc_path
        self.cfg_store_path = cfg_store_path

        # =====ue capa
        for k, v in ARCH2_NORMAL_UE_CAPA.items():
            ARCH2_WTS_VARIABLES[k] = v
        for k, v in ARCH2_SPECIAL_UE_CAPA.items():
            ARCH2_WTS_VARIABLES[k] = v
        non_ca_sa_nr_capa = str(ARCH2_WTS_VARIABLES["$NON_CA_SA_NR_CAPA"]),
        non_ca_nsa_nr_capa = str(ARCH2_WTS_VARIABLES["$NON_CA_NSA_NR_CAPA"]),
        non_ca_nsa_er_capa = str(ARCH2_WTS_VARIABLES["$NON_CA_NSA_ER_CAPA"]),
        ca_sa_nr_capa = str(ARCH2_WTS_VARIABLES["$CA_SA_NR_CAPA"]),
        ca_nsa_nr_capa = str(ARCH2_WTS_VARIABLES["$CA_NSA_NR_CAPA"]),
        ca_nsa_er_capa = str(ARCH2_WTS_VARIABLES["$CA_NSA_ER_CAPA"]),

        # ===== Real GNB2
        gnb2 = Real_GNB(self.scfc)
        ARCH2_WTS_TEMPLATE["GNB2_CONFIGURATION"]["gnb"] = [
            "set_gnb id=2 type=external gnb_id=%s plmn=%s ng=$GNB2_NG_ADDR xn=$GNB2_XN_ADDR "
            "x2=$GNB2_X2_ADDR:36422 daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none amf=1" % (gnb2.gnb_id,
                                                                                           gnb2.plmn)]
        ue_res = []
        for k, v in gnb2.cells_info.items():
            if v["nrarfcn"].partition(":")[0] == v["nrarfcn"].partition(":")[2]:
                tf = "on"
            else:
                tf = "off"
            if v["gscn"] not in ["0", "1", "2"]:
                tmp = "set_cell id=%s gnb=2 pci=%s tac=%s nrci=%s tdd_cell=%s " \
                      "proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=%s gscn=%s " \
                      "mandatory_for_activation=off" % (v["lcrid"], "%d:%d" % (int(v["pci"]) / 3, int(v["pci"]) % 3),
                                                        v["tac"], "0x{:02X}".format(int(v["lcrid"])),
                                                        tf, v["nrarfcn"], v["gscn"])
            else:
                tmp = "set_cell id=%s gnb=2 pci=%s tac=%s nrci=%s tdd_cell=%s " \
                      "proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=%s " \
                      "mandatory_for_activation=off" % (v["lcrid"], "%d:%d" % (int(v["pci"]) / 3, int(v["pci"]) % 3),
                                                        v["tac"], "0x{:02X}".format(int(v["lcrid"])),
                                                        tf, v["nrarfcn"])
            ue_res.append(tmp)
        ARCH2_WTS_TEMPLATE["GNB2_CONFIGURATION"]["cell"] = \
            sorted(ue_res, key=lambda i: int(re.search(r"id=(\d+)", i).group(1)), reverse=False)

        # Delete Real ENB3
        del ARCH2_WTS_VARIABLES["$GNB3_X2_ADDR"]
        del ARCH2_WTS_VARIABLES["$GNB3_S1U_ADDR"]
        del ARCH2_WTS_TEMPLATE["GNB3_CONFIGURATION"]

        # UE(Now only support write method like '1','1-10',not support like '1,2,3,...')
        self.ue_info = ue_info
        ue_ids = []

        # ===== NON CA SA UE Default 1-10
        if "sa" in self.ue_info.keys():
            if "-" in str(self.ue_info["sa"]):
                sa_ue_ids = range(int(self.ue_info["sa"].partition("-")[0]),
                                  int(self.ue_info["sa"].partition("-")[2]) + 1)
            else:
                sa_ue_ids = [int(self.ue_info["sa"])]
            ue_ids += sa_ue_ids
            for i in sa_ue_ids:
                tmp1 = "set_ue simulated id=%d uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 " \
                       "opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc " \
                       "sec_key=0102030405060708090A0B0C0D0EFF00 enb=2 cell=1 mode=nr " \
                       "suci=0:311:489:0000:0:0:0%s " % (i, str(21645400 + i))
                ARCH2_WTS_TEMPLATE["SA_UE_CONFIGURATION"]["ue"].append(tmp1)
                if non_ca_sa_nr_capa[0] != "":
                    tmp2 = "ue_param id=%d ue_nr_capabilities=$NON_CA_SA_NR_CAPA" % i
                    ARCH2_WTS_TEMPLATE["SA_UE_CONFIGURATION"]["ue_param"].append(tmp2)

        # ===== NON CA NSA UE Default 11-20
        if "nsa" in self.ue_info.keys():
            if "-" in str(self.ue_info["nsa"]):
                nsa_ue_ids = range(int(self.ue_info["nsa"].partition("-")[0]),
                                   int(self.ue_info["nsa"].partition("-")[2]) + 1)
            else:
                nsa_ue_ids = [int(self.ue_info["nsa"])]
            ue_ids += nsa_ue_ids
            for i in nsa_ue_ids:
                tmp1 = "set_ue simulated id=%d uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 " \
                       "sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc " \
                       "imsi=%s:%d" % (i, gnb2.plmn, 21645400 + i)
                ARCH2_WTS_TEMPLATE["NSA_UE_CONFIGURATION"]["ue"].append(tmp1)
                tmp2 = ""
                if non_ca_sa_nr_capa[0] != "":
                    tmp2 = "ue_param id=%d ue_nr_capabilities=$NON_CA_NSA_NR_CAPA dual_conn=eutra_nr " % i
                if non_ca_nsa_er_capa[0] != "":
                    tmp2 += "ue_eutra_nr_capabilities=$NON_CA_NSA_ER_CAPA"
                if tmp2 != "":
                    ARCH2_WTS_TEMPLATE["NSA_UE_CONFIGURATION"]["ue_param"].append(tmp2)
                tmp3 = "set_bearer id=2 ue=%d qci=9 pdn=1 ip=%s ul_nat_gw=$SERVER_IP dl_nat_gw=$SERVER_IP " \
                       "default=on trf_type=internal" % (i, IPy.intToIp(IPy.IP("4.7.254.208").int() + i - 11, 4))
                ARCH2_WTS_TEMPLATE["NSA_UE_CONFIGURATION"]["bearer"].append(tmp3)

        # ===== CA SA UE Default 80-90
        if "ca_sa" in self.ue_info.keys():
            if "-" in str(self.ue_info["ca_sa"]):
                ca_sa_ue_ids = range(int(self.ue_info["ca_sa"].partition("-")[0]),
                                     int(self.ue_info["ca_sa"].partition("-")[2]) + 1)
            else:
                ca_sa_ue_ids = [int(self.ue_info["ca_sa"])]
            ue_ids += ca_sa_ue_ids
            for i in ca_sa_ue_ids:
                tmp1 = "set_ue simulated id=%d uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 " \
                       "opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc " \
                       "sec_key=0102030405060708090A0B0C0D0EFF00 enb=2 cell=1 mode=nr " \
                       "suci=0:311:489:0000:0:0:0%s " % (i, str(21645400 + i))
                ARCH2_WTS_TEMPLATE["CA_SA_UE_CONFIGURATION"]["ue"].append(tmp1)
                if ca_sa_nr_capa[0] != "":
                    # tmp2 = "ue_param id=%d ue_nr_capabilities=%s" % (i, ca_sa_nr_capa)
                    tmp2 = "ue_param id=%d ue_nr_capabilities=$CA_SA_NR_CAPA" % i
                    ARCH2_WTS_TEMPLATE["CA_SA_UE_CONFIGURATION"]["ue_param"].append(tmp2)

        # ===== CA NSA UE Default 91-100
        if "ca_nsa" in self.ue_info.keys():
            if "-" in str(self.ue_info["ca_nsa"]):
                ca_nsa_ue_ids = range(int(self.ue_info["ca_nsa"].partition("-")[0]),
                                      int(self.ue_info["ca_nsa"].partition("-")[2]) + 1)
            else:
                ca_nsa_ue_ids = [int(self.ue_info["ca_nsa"])]
            ue_ids += ca_nsa_ue_ids
            for i in ca_nsa_ue_ids:
                tmp1 = "set_ue simulated id=%d uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 " \
                       "sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc " \
                       "imsi=%s:%d" % (i, gnb2.plmn, 21645400 + i)
                ARCH2_WTS_TEMPLATE["CA_NSA_UE_CONFIGURATION"]["ue"].append(tmp1)
                tmp2 = ""
                if ca_nsa_nr_capa[0] != "":
                    # tmp2 = "ue_param id=%d ue_nr_capabilities=%s dual_conn=eutra_nr " % (i, ca_nsa_nr_capa)
                    tmp2 = "ue_param id=%d ue_nr_capabilities=$CA_NSA_NR_CAPA dual_conn=eutra_nr " % i
                if ca_nsa_er_capa[0] != "":
                    # tmp2 += "ue_eutra_nr_capabilities=%s" % ca_nsa_er_capa
                    tmp2 += "ue_eutra_nr_capabilities=$CA_NSA_ER_CAPA"
                if tmp2 != "":
                    ARCH2_WTS_TEMPLATE["CA_NSA_UE_CONFIGURATION"]["ue_param"].append(tmp2)
                tmp3 = "set_bearer id=2 ue=%d qci=9 pdn=1 ip=%s ul_nat_gw=$SERVER_IP dl_nat_gw=$SERVER_IP " \
                       "default=on trf_type=internal" % (i, IPy.intToIp(IPy.IP("4.7.254.208").int() + i - 11, 4))
                ARCH2_WTS_TEMPLATE["CA_NSA_UE_CONFIGURATION"]["bearer"].append(tmp3)

        # ===== qosflow, nwslice, pdu_gateway
        # nwslice only for 'sa ue','ca_sa ue'
        ARCH2_WTS_TEMPLATE["COMMON_CONFIGURATION"]["qosflow"] = ["set_qosflow id=1 5qi=6 default=on"]
        if 'sa_ue_ids' in dir() or 'ca_sa_ue_ids' in dir():
            # if len(sa_ue_ids) + len(ca_sa_ue_ids) > 0:
            ARCH2_WTS_TEMPLATE["COMMON_CONFIGURATION"]["nwslice"] = [
                "set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1-6",
                "set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1",
                "set_nwslice id=3 snssai=0x01:0xD143A7 ue=all amf=1",
                "set_nwslice id=4 snssai=0x01:0xD143A8 ue=all amf=1"]

        for ue_id in ue_ids:
            ip = IPy.intToIp(IPy.IP("72.23.0.1").int() + 256 * (ue_id - 1), 4)
            ARCH2_WTS_TEMPLATE["COMMON_CONFIGURATION"]["pdu_gateway"].append(
                "set_pdu_gateway id=%d ue_nat_ip=%s dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP" % (ue_id, ip))

        # ===== WTS_TEMPLATE command transfer to OBJ
        self.arch2_cmd_obj = OrderedDict()
        for k1, v1 in ARCH2_WTS_TEMPLATE.items():
            self.arch2_cmd_obj[k1] = OrderedDict()
            for k2, v2 in v1.items():
                self.arch2_cmd_obj[k1][k2] = []
                for i in v2:
                    self.arch2_cmd_obj[k1][k2].append(command(i))

    def arch2_generate_default_cfg2(self, gnb1_scfc_path, gnb2_scfc_path, cfg_store_path, mode="SA+NSA", ue_info={},
                                    *args, **kwargs):
        self.scfc1 = gnb1_scfc_path
        self.scfc2 = gnb1_scfc_path
        self.cfg_store_path = cfg_store_path

        # =====ue capa
        for k, v in ARCH2_NORMAL_UE_CAPA.items():
            ARCH2_WTS_VARIABLES[k] = v
        for k, v in ARCH2_SPECIAL_UE_CAPA.items():
            ARCH2_WTS_VARIABLES[k] = v
        non_ca_sa_nr_capa = str(ARCH2_WTS_VARIABLES["$NON_CA_SA_NR_CAPA"]),
        non_ca_nsa_nr_capa = str(ARCH2_WTS_VARIABLES["$NON_CA_NSA_NR_CAPA"]),
        non_ca_nsa_er_capa = str(ARCH2_WTS_VARIABLES["$NON_CA_NSA_ER_CAPA"]),
        ca_sa_nr_capa = str(ARCH2_WTS_VARIABLES["$CA_SA_NR_CAPA"]),
        ca_nsa_nr_capa = str(ARCH2_WTS_VARIABLES["$CA_NSA_NR_CAPA"]),
        ca_nsa_er_capa = str(ARCH2_WTS_VARIABLES["$CA_NSA_ER_CAPA"]),

        # ===== Real GNB2
        gnb2 = Real_GNB(self.scfc1)
        ARCH2_WTS_TEMPLATE["GNB2_CONFIGURATION"]["gnb"] = [
            "set_gnb id=2 type=external gnb_id=%s plmn=%s ng=$GNB2_NG_ADDR xn=$GNB2_XN_ADDR "
            "x2=$GNB2_X2_ADDR:36422 daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none amf=1" % (gnb2.gnb_id,
                                                                                           gnb2.plmn)]
        ue_res2 = []
        for k, v in gnb2.cells_info.items():
            if v["nrarfcn"].partition(":")[0] == v["nrarfcn"].partition(":")[2]:
                tf = "on"
            else:
                tf = "off"
            if v["gscn"] not in ["0", "1", "2"]:
                tmp = "set_cell id=%s gnb=2 pci=%s tac=%s nrci=%s tdd_cell=%s " \
                      "proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=%s gscn=%s " \
                      "mandatory_for_activation=off" % (v["lcrid"], "%d:%d" % (int(v["pci"]) / 3, int(v["pci"]) % 3),
                                                        v["tac"], "0x{:02X}".format(int(v["lcrid"])),
                                                        tf, v["nrarfcn"], v["gscn"])
            else:
                tmp = "set_cell id=%s gnb=2 pci=%s tac=%s nrci=%s tdd_cell=%s " \
                      "proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=%s " \
                      "mandatory_for_activation=off" % (v["lcrid"], "%d:%d" % (int(v["pci"]) / 3, int(v["pci"]) % 3),
                                                        v["tac"], "0x{:02X}".format(int(v["lcrid"])),
                                                        tf, v["nrarfcn"])
            ue_res2.append(tmp)
        ARCH2_WTS_TEMPLATE["GNB2_CONFIGURATION"]["cell"] = \
            sorted(ue_res2, key=lambda i: int(re.search(r"id=(\d+)", i).group(1)), reverse=False)

        # ===== Real GNB3
        gnb3 = Real_GNB(self.scfc2)

        # Modify These GNB3 IPs
        ARCH2_WTS_VARIABLES["$GNB3_NG_ADDR"] = "10.0.1.3"
        ARCH2_WTS_VARIABLES["$GNB3_X2_ADDR"] = "10.0.1.3"
        ARCH2_WTS_VARIABLES["$GNB3_XN_ADDR"] = "10.0.1.3"
        ARCH2_WTS_VARIABLES["$GNB3_S1U_ADDR"] = "10.0.1.113"

        # Delete previous simulator GNB3 configuration first
        del ARCH2_WTS_TEMPLATE["Simualtor_GNB3_TDD"]
        ARCH2_WTS_TEMPLATE["GNB3_CONFIGURATION"]["gnb"] = [
            "set_gnb id=3 type=external gnb_id=%s plmn=%s ng=$GNB3_NG_ADDR xn=$GNB3_XN_ADDR "
            "x2=$GNB3_X2_ADDR:36422 daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none amf=1" % (gnb3.gnb_id,
                                                                                           gnb3.plmn)]
        ue_res3 = []
        for k, v in gnb3.cells_info.items():
            if v["nrarfcn"].partition(":")[0] == v["nrarfcn"].partition(":")[2]:
                tf = "on"
            else:
                tf = "off"
            if v["gscn"] not in ["0", "1", "2"]:
                tmp = "set_cell id=%s gnb=2 pci=%s tac=%s nrci=%s tdd_cell=%s " \
                      "proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=%s gscn=%s " \
                      "mandatory_for_activation=off" % (v["lcrid"], "%d:%d" % (int(v["pci"]) / 3, int(v["pci"]) % 3),
                                                        v["tac"], "0x{:02X}".format(int(v["lcrid"])),
                                                        tf, v["nrarfcn"], v["gscn"])
            else:
                tmp = "set_cell id=%s gnb=2 pci=%s tac=%s nrci=%s tdd_cell=%s " \
                      "proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=%s " \
                      "mandatory_for_activation=off" % (v["lcrid"], "%d:%d" % (int(v["pci"]) / 3, int(v["pci"]) % 3),
                                                        v["tac"], "0x{:02X}".format(int(v["lcrid"])),
                                                        tf, v["nrarfcn"])
            ue_res3.append(tmp)
        ARCH2_WTS_TEMPLATE["GNB3_CONFIGURATION"]["cell"] = \
            sorted(ue_res3, key=lambda i: int(re.search(r"id=(\d+)", i).group(1)), reverse=False)

        # UE(Now only support write method like '1','1-10',not support like '1,2,3,...')
        self.ue_info = ue_info
        ue_ids = []

        # ===== NON CA SA UE Default 1-10
        if "sa" in self.ue_info.keys():
            if "-" in str(self.ue_info["sa"]):
                sa_ue_ids = range(int(self.ue_info["sa"].partition("-")[0]),
                                  int(self.ue_info["sa"].partition("-")[2]) + 1)
            else:
                sa_ue_ids = [int(self.ue_info["sa"])]
            ue_ids += sa_ue_ids
            for i in sa_ue_ids:
                tmp1 = "set_ue simulated id=%d uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 " \
                       "opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc " \
                       "sec_key=0102030405060708090A0B0C0D0EFF00 enb=2 cell=1 mode=nr " \
                       "suci=0:311:489:0000:0:0:0%s " % (i, str(21645400 + i))
                ARCH2_WTS_TEMPLATE["SA_UE_CONFIGURATION"]["ue"].append(tmp1)
                if non_ca_sa_nr_capa[0] != "":
                    tmp2 = "ue_param id=%d ue_nr_capabilities=$NON_CA_SA_NR_CAPA" % i
                    ARCH2_WTS_TEMPLATE["SA_UE_CONFIGURATION"]["ue_param"].append(tmp2)

        # ===== NON CA NSA UE Default 11-20
        if "nsa" in self.ue_info.keys():
            if "-" in str(self.ue_info["nsa"]):
                nsa_ue_ids = range(int(self.ue_info["nsa"].partition("-")[0]),
                                   int(self.ue_info["nsa"].partition("-")[2]) + 1)
            else:
                nsa_ue_ids = [int(self.ue_info["nsa"])]
            ue_ids += nsa_ue_ids
            for i in nsa_ue_ids:
                tmp1 = "set_ue simulated id=%d uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 " \
                       "sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc " \
                       "imsi=%s:%d" % (i, gnb2.plmn, 21645400 + i)
                ARCH2_WTS_TEMPLATE["NSA_UE_CONFIGURATION"]["ue"].append(tmp1)
                tmp2 = ""
                if non_ca_sa_nr_capa[0] != "":
                    tmp2 = "ue_param id=%d ue_nr_capabilities=$NON_CA_NSA_NR_CAPA dual_conn=eutra_nr " % i
                if non_ca_nsa_er_capa[0] != "":
                    tmp2 += "ue_eutra_nr_capabilities=$NON_CA_NSA_ER_CAPA"
                if tmp2 != "":
                    ARCH2_WTS_TEMPLATE["NSA_UE_CONFIGURATION"]["ue_param"].append(tmp2)
                tmp3 = "set_bearer id=2 ue=%d qci=9 pdn=1 ip=%s ul_nat_gw=$SERVER_IP dl_nat_gw=$SERVER_IP " \
                       "default=on trf_type=internal" % (i, IPy.intToIp(IPy.IP("4.7.254.208").int() + i - 11, 4))
                ARCH2_WTS_TEMPLATE["NSA_UE_CONFIGURATION"]["bearer"].append(tmp3)

        # ===== CA SA UE Default 80-90
        if "ca_sa" in self.ue_info.keys():
            if "-" in str(self.ue_info["ca_sa"]):
                ca_sa_ue_ids = range(int(self.ue_info["ca_sa"].partition("-")[0]),
                                     int(self.ue_info["ca_sa"].partition("-")[2]) + 1)
            else:
                ca_sa_ue_ids = [int(self.ue_info["ca_sa"])]
            ue_ids += ca_sa_ue_ids
            for i in ca_sa_ue_ids:
                tmp1 = "set_ue simulated id=%d uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 " \
                       "opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc " \
                       "sec_key=0102030405060708090A0B0C0D0EFF00 enb=2 cell=1 mode=nr " \
                       "suci=0:311:489:0000:0:0:0%s " % (i, str(21645400 + i))
                ARCH2_WTS_TEMPLATE["CA_SA_UE_CONFIGURATION"]["ue"].append(tmp1)
                if ca_sa_nr_capa[0] != "":
                    # tmp2 = "ue_param id=%d ue_nr_capabilities=%s" % (i, ca_sa_nr_capa)
                    tmp2 = "ue_param id=%d ue_nr_capabilities=$CA_SA_NR_CAPA" % i
                    ARCH2_WTS_TEMPLATE["CA_SA_UE_CONFIGURATION"]["ue_param"].append(tmp2)

        # ===== CA NSA UE Default 91-100
        if "ca_nsa" in self.ue_info.keys():
            if "-" in str(self.ue_info["ca_nsa"]):
                ca_nsa_ue_ids = range(int(self.ue_info["ca_nsa"].partition("-")[0]),
                                      int(self.ue_info["ca_nsa"].partition("-")[2]) + 1)
            else:
                ca_nsa_ue_ids = [int(self.ue_info["ca_nsa"])]
            ue_ids += ca_nsa_ue_ids
            for i in ca_nsa_ue_ids:
                tmp1 = "set_ue simulated id=%d uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 " \
                       "sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc " \
                       "imsi=%s:%d" % (i, gnb2.plmn, 21645400 + i)
                ARCH2_WTS_TEMPLATE["CA_NSA_UE_CONFIGURATION"]["ue"].append(tmp1)
                tmp2 = ""
                if ca_nsa_nr_capa[0] != "":
                    # tmp2 = "ue_param id=%d ue_nr_capabilities=%s dual_conn=eutra_nr " % (i, ca_nsa_nr_capa)
                    tmp2 = "ue_param id=%d ue_nr_capabilities=$CA_NSA_NR_CAPA dual_conn=eutra_nr " % i
                if ca_nsa_er_capa[0] != "":
                    # tmp2 += "ue_eutra_nr_capabilities=%s" % ca_nsa_er_capa
                    tmp2 += "ue_eutra_nr_capabilities=$CA_NSA_ER_CAPA"
                if tmp2 != "":
                    ARCH2_WTS_TEMPLATE["CA_NSA_UE_CONFIGURATION"]["ue_param"].append(tmp2)
                tmp3 = "set_bearer id=2 ue=%d qci=9 pdn=1 ip=%s ul_nat_gw=$SERVER_IP dl_nat_gw=$SERVER_IP " \
                       "default=on trf_type=internal" % (i, IPy.intToIp(IPy.IP("4.7.254.208").int() + i - 11, 4))
                ARCH2_WTS_TEMPLATE["CA_NSA_UE_CONFIGURATION"]["bearer"].append(tmp3)

        # ===== qosflow, nwslice, pdu_gateway
        # nwslice only for 'sa ue','ca_sa ue'
        ARCH2_WTS_TEMPLATE["COMMON_CONFIGURATION"]["qosflow"] = ["set_qosflow id=1 5qi=6 default=on"]
        if 'sa_ue_ids' in dir() or 'ca_sa_ue_ids' in dir():
            # if len(sa_ue_ids) + len(ca_sa_ue_ids) > 0:
            ARCH2_WTS_TEMPLATE["COMMON_CONFIGURATION"]["nwslice"] = [
                "set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1-6",
                "set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1",
                "set_nwslice id=3 snssai=0x01:0xD143A7 ue=all amf=1",
                "set_nwslice id=4 snssai=0x01:0xD143A8 ue=all amf=1"]

        for ue_id in ue_ids:
            ip = IPy.intToIp(IPy.IP("72.23.0.1").int() + 256 * (ue_id - 1), 4)
            ARCH2_WTS_TEMPLATE["COMMON_CONFIGURATION"]["pdu_gateway"].append(
                "set_pdu_gateway id=%d ue_nat_ip=%s dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP" % (ue_id, ip))

        # ===== WTS_TEMPLATE command transfer to OBJ
        self.arch2_cmd_obj = OrderedDict()
        for k1, v1 in ARCH2_WTS_TEMPLATE.items():
            self.arch2_cmd_obj[k1] = OrderedDict()
            for k2, v2 in v1.items():
                self.arch2_cmd_obj[k1][k2] = []
                for i in v2:
                    self.arch2_cmd_obj[k1][k2].append(command(i))

    def arch2_teardown_cfg(self):
        self.cfg_file = cfg_file_generator(self.cfg_store_path)
        self.cfg_file.setup()
        self.cfg_name = os.path.basename(self.cfg_store_path).split(".")[0]
        self.cfg_file.write_content("#%s\n#%s\n#%s" % ("-" * 100, "VARIABLES", "-" * 100))
        for k, v in ARCH2_WTS_VARIABLES.items():
            self.cfg_file.write_content('set %s="%s"' % (k[1:], v))
        self.cfg_file.write_content("")
        for domain, type in self.arch2_cmd_obj.items():
            self.cfg_file.write_content("#%s\n#%s\n#%s" % ("-" * 100, domain, "-" * 100))
            for k, v in type.items():
                for i in v:
                    self.cfg_file.write_content(i.generate_cmd())
            self.cfg_file.write_content("")
        self.cfg_file.write_content("#%s\n#%s\n#%s" % ("-" * 100, "END_CONFIGURATION", "-" * 100))
        for i in ARCH2_END_CONFIGURATION:
            self.cfg_file.write_content(i)
        self.cfg_file.teardown()
        builtin_obj.log("[Auto_Cfg_Arch2] Succeed to generate %s for WTS startup" % self.cfg_store_path)

        # Generate a res.cfg without variables
        # self.cfg_store_path ==> /opt/iphy/latest/
        self.cfg_file_nv = cfg_file_generator(os.path.join(os.path.dirname(self.cfg_store_path),
                                                           "%s_wov.cfg" % self.cfg_name))
        self.cfg_file_nv.setup()
        self.cfg_file_nv.write_content("#%s\n#%s\n#%s" % ("-" * 100, "VARIABLES", "-" * 100))
        for k, v in ARCH2_WTS_VARIABLES.items():
            self.cfg_file_nv.write_content('set %s="%s"' % (k[1:], v))
        self.cfg_file_nv.write_content("")
        for domain, type in self.arch2_cmd_obj.items():
            self.cfg_file_nv.write_content("#%s\n#%s\n#%s" % ("-" * 100, domain, "-" * 100))
            for k, v in type.items():
                for i in v:
                    txt = i.generate_cmd()
                    ret = re.findall(r"\$[^(:|\s|/)]+", txt)
                    if ret != []:
                        for j in ret:
                            if j in ARCH2_WTS_VARIABLES.keys():
                                txt = txt.replace(j, ARCH2_WTS_VARIABLES[j])
                    self.cfg_file_nv.write_content(txt)
            self.cfg_file_nv.write_content("")
        self.cfg_file_nv.write_content("#%s\n#%s\n#%s" % ("-" * 100, "END_CONFIGURATION", "-" * 100))
        for i in ARCH2_END_CONFIGURATION:
            self.cfg_file_nv.write_content(i)
        self.cfg_file_nv.teardown()
        builtin_obj.log("[Auto_Cfg_Arch2] Succeed to generate %s without variables" % self.cfg_file_nv)
