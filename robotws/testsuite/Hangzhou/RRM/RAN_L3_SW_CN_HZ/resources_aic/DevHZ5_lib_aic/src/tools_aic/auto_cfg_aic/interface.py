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
from .comm_cfg_file_generator import cfg_file_generator_aic
from .comm_command import command_aic
from .comm_sync_gnb import Real_GNB_AIC
from .arch1_source_wts_handle import SourceWtsCfgAic

builtin_obj = BuiltIn()


class auto_cfg_aic(object):
    def __init__(self):
        self.command_obj_L = []
        self.update_command_obj_L = []

    def set_cfg_aic(self, cmd_str):
        cmd_list = cmd_str.strip().split()
        command_obj = command_aic(cmd_str)
        self.command_obj_L.append(command_obj)
        return command_obj

    def fuzzy_match_aic(self, real_gnb_cell_obj):
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

    def update_cfg_aic(self, cmd_str):
        ret = re.search(r"id=(\S+)", cmd_str)
        objlist = []
        if ret is not None:
            id_txt = re.search(r"id=(\S+)", cmd_str).group(1)
            if "-" not in id_txt:
                update_command_obj = command_aic(cmd_str)
                objlist.append(update_command_obj)
            else:
                for num in range(int(id_txt.split("-")[0]), int(id_txt.split("-")[1]) + 1, ):
                    tmp_cmd_str = re.sub(r"id=(\S+)", r"id=%d" % num, cmd_str)
                    update_command_obj = command_aic(tmp_cmd_str)
                    objlist.append(update_command_obj)
        else:
            update_command_obj = command_aic(cmd_str)
            objlist = [update_command_obj]

        for cmd_obj in objlist:
            # if self.fuzzy_match_aic(cmd_obj):
            #     break
            exist = False
            if cmd_obj.type == "ucp_ue":
                ret = re.search(r"ue_id=\d+", cmd_obj.diff)
                if ret is not None:
                    for i in self.command_obj_L:
                        if i.diff.endswith(ret.group()):
                            exist = True
                            cmd_obj.diff = i.diff
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

    def update_cfg_param_aic(self, cmd_str, exception=True):
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
            cmd_obj = command_aic(cmd)
            if cmd_obj.type == "ucp_ue":
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

    def delete_cfg_aic(self, cmd_str, exception=True):
        exist = False
        cmd_obj = command_aic(cmd_str)
        if cmd_obj.type == "ucp_ue":
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

    def generate_default_cfg_aic(self, ue_count, cfg_store_dir, cfg_file_name, source_wts_path, cu_scfc_path,
                                 du_scfc_path, cu_mode="SA+NSA", du2_scfc_path=None, du3_scfc_path=None,
                                 du4_scfc_path=None, *args, **kwargs):
        # twcf means target wts.cfg file
        self.twcf_store_dir = cfg_store_dir
        self.twcf_name = cfg_file_name
        self.twcf_name_wov = \
            self.twcf_name.replace(self.twcf_name.partition(".")[0], "%s_wov" % self.twcf_name.partition(".")[0])
        self.twcf_path_wov = os.path.abspath(os.path.join(self.twcf_store_dir, self.twcf_name_wov))
        self.twcf_path_wv = os.path.abspath(os.path.join(self.twcf_store_dir, self.twcf_name))

        self.swc_obj = SourceWtsCfgAic(source_wts_path=source_wts_path)

        self.gnb2_obj = Real_GNB_AIC(cu_scfc_path, du_scfc_path, du2_scfc_path, du3_scfc_path, du4_scfc_path)

        for line in self.swc_obj.swc_body_L:
            ret = self.set_cfg_aic(line)

        for command_obj in self.command_obj_L:
            if command_obj.diff == "gnb_id=2":
                command_obj.args["plmn"] = self.gnb2_obj.plmn
                command_obj.args["gnb_id"] = self.gnb2_obj.gnb_id
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

        self.mode = cu_mode.lower()
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
                    continue
                else:
                    tmp_cmd = re.sub(r"id=\d+", "id=%s" % sa_ue_id,
                                     self.swc_obj.swc_paras["sa_ue_template"]["whole_ue_cmd"])
                    tmp_cmd = re.sub(r"suci=\S+", "suci=%s:%s%s" % (pre, zero_head, str(num + suci_add)), tmp_cmd)
                    self.set_cfg_aic(cmd_str=tmp_cmd)
                    suci_add += 1

                    tmp_cmd = re.sub(r"id=\d+", "id=%s" % sa_ue_id,
                                     self.swc_obj.swc_paras["sa_ue_template"]["ue_param_whole_cmd"])
                    self.set_cfg_aic(cmd_str=tmp_cmd)

            for cmd in self.swc_obj.swc_paras["swc_ue_releated"]["nwslice_cmd"]:
                ret = re.search(r"ue=(\S+)", cmd)
                if ret is not None:
                    num = ret.group(1)
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
                            self.set_cfg_aic(new_cmd)
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
                            self.set_cfg_aic(cmd_str=tmp_cmd)
                    for obj in self.command_obj_L:
                        if obj.type == "nsa_ue_param" and obj.diff.split("=")[-1] == exist_ue_id:
                            tmp_cmd = re.sub(r"id=(\d+)", "id=%s" % nsa_ue_id, obj.generate_cmd())
                            self.command_obj_L.remove(obj)
                            self.set_cfg_aic(cmd_str=tmp_cmd)
                    for obj in self.command_obj_L:
                        if obj.type == "bearer" and obj.diff.split("=")[-1].split("^")[-1] == exist_ue_id:
                            tmp_cmd = re.sub(r"ue=(\d+)", "ue=%s" % nsa_ue_id, obj.generate_cmd())
                            self.command_obj_L.remove(obj)
                            self.set_cfg_aic(cmd_str=tmp_cmd)
                    imsi_add += 1
                else:
                    tmp_cmd = re.sub(r"id=(\d+)", "id=%s" % nsa_ue_id,
                                     self.swc_obj.swc_paras["nsa_ue_template"]["whole_ue_cmd"])
                    tmp_cmd = re.sub(r"imsi=\S+", "imsi=%s:%s" % (pre, str(num + imsi_add)), tmp_cmd)
                    self.set_cfg_aic(cmd_str=tmp_cmd)

                    tmp_cmd = re.sub(r"id=\d+", "id=%s" % nsa_ue_id,
                                     self.swc_obj.swc_paras["nsa_ue_template"]["ue_param_whole_cmd"])
                    self.set_cfg_aic(cmd_str=tmp_cmd)

                    tmp_pdn_ip = IPy.intToIp(IPy.IP(tmp_pdn_ip).int() + 1, 4)
                    while tmp_pdn_ip in self.swc_obj.swc_paras["swc_ue_releated"]["exist_bearer_pdn_ip"]:
                        tmp_pdn_ip = IPy.intToIp(IPy.IP(tmp_pdn_ip).int() + 1, 4)

                    tmp_cmd = re.sub(r"ue=\S+", "ue=%s" % nsa_ue_id,
                                     self.swc_obj.swc_paras["bearer_template"]["whole_cmd"])
                    tmp_cmd = re.sub(r"ip=\S+", "ip=%s" % tmp_pdn_ip, tmp_cmd)
                    self.set_cfg_aic(tmp_cmd)
                    imsi_add += 1

        ue_pdugateway_map = OrderedDict()
        exist_pdugateway = OrderedDict()
        for i in self.command_obj_L:
            if i.type == "sa_ue" or i.type == "nsa_ue":
                ue_pdugateway_map[i.args["id"]] = None
            elif i.type == "pdu_gateway":
                exist_pdugateway[i.args["id"]] = i

        ret1 = sorted(ue_pdugateway_map.items(),
                      key=lambda ue_pdugateway_map: int(ue_pdugateway_map[0]),
                      reverse=False)
        ret2 = sorted(exist_pdugateway.items(),
                      key=lambda exist_pdugateway: int(exist_pdugateway[0]),
                      reverse=False)

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
            self.set_cfg_aic(map_pdugateway_cmd)

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
                          "enb_xp_param_id", "smf_upf_mapping_id",
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

    def teardown_cfg_aic(self):
        try:
            tail_debug_log_level = builtin_obj.get_variable_value("${DEBUG_LOG_LEVEL}")
            tail_ap_log_level = builtin_obj.get_variable_value("${AP_UDPLOG_LEVEL}")
            if tail_debug_log_level is None:
                tail_debug_log_level = "2"
            if tail_ap_log_level is None:
                tail_ap_log_level = "1"
        except Exception as e:
            if str(e) == "Cannot access execution context":
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

        self.nwc_nv_L = []
        self.rwc_nv_L = []

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
                [r"^gnb_id=\d+$", r"^gnb_param_id=\d+$", r"^cell_id\^gnb=\d+\^\d+$",
                 r"gnb_cell_param_id\^gnb=\d+\^\d+$", r"^gnb_endc_param_id=\d+$"])

        NWC_RWC("5GCN CONFIGURATION",
                [r"^amf_region_id=\d+$", r"^amf_id=\d+$", r"^amf_param_id=\d+$", r"^upf_id=\d+$", r"^backup_amf$",
                 r"^amf_ng_setup_param_id=\d+$"])

        NWC_RWC("UEC CONFIGURATION",
                [r"^uec_id=\d+$", r"^uec_param_id=\d+$"])

        NWC_RWC("SA UE CONFIGURATION",
                [r"^sa_ue_id=\d+$", r"^sa_ue_param_id=\d+$", r"^amf_ue_ics_param_id=\S+$"])

        NWC_RWC("NSA UE CONFIGURATION",
                [r"^nsa_ue_id=\d+$", r"^nsa_ue_param_id=\d+$", r"^qci_qci=\d+$", r"^bearer_id\^ue=\d+\^\d+$"])

        NWC_RWC("COMMON CONFIGURATION",
                [r"^qosflow_id=\d+$", r"^qosrule_id=\d+$", r"^nwslice_id=\d+$", r"^pdu_gateway_id=\d+$",
                 r"smf_upf_mapping_id=\d+$"])

        if len(self.nwc_nv_L) > 0:
            self.rwc_nv_L.append("#" + "-" * 100)
            self.rwc_nv_L.append("# CONFIGURATION NOT CLASSIFICATION")
            self.rwc_nv_L.append("#" + "-" * 100)
            for cnc in self.nwc_nv_L:
                self.rwc_nv_L.append(cnc)
            self.rwc_nv_L.append("\n")

        self.rwc_nv_L.append("#" + "-" * 100)
        self.rwc_nv_L.append("#OTHER CONFIGURATION")
        self.rwc_nv_L.append("#" + "-" * 100)

        for line in self.define_tail_L:
            self.rwc_nv_L.append(line)

        self.twcf_file_wov = cfg_file_generator_aic(self.twcf_path_wov)
        self.twcf_file_wov.setup()
        for i in self.rwc_nv_L:
            if isinstance(i, command_aic):
                self.twcf_file_wov.write_content(i.generate_cmd())
            else:
                self.twcf_file_wov.write_content(i)
        self.twcf_file_wov.teardown()

        self.twcf_file_wv = cfg_file_generator_aic(self.twcf_path_wv)
        self.twcf_file_wv.setup()

        res_rwc_nv_L = self.rwc_nv_L
        for i in res_rwc_nv_L:
            if isinstance(i, command_aic):
                cmd = i.generate_cmd()
                ret = re.findall(r"\S+=\d+\.\d+\.\d+\.\d+", cmd)
                if ret != []:
                    for diffv, obj in self.swc_obj.swc_vari_cmd_map.items():
                        if diffv == i.diff:
                            for arg_name, arg_value in i.args.items():
                                ret1 = re.match(r"^\d+\.\d+\.\d+\.\d+[\:\d+]*\|*\d*\.*\d*\.*\d*\.*\d*[\:\d+]*",
                                                arg_value)
                                if ret1 is not None:
                                    if arg_name in obj.args:
                                        tmpstr = obj.args[arg_name]
                                        ret2 = re.findall(r"\$[A-Za-z0-9_]+", tmpstr)
                                        for z in ret2:
                                            tmpstr = re.sub(r"\%s" % z,
                                                            self.swc_obj.swc_paras["swc_variables"][z[1:]],
                                                            tmpstr,
                                                            1)
                                        if tmpstr == i.args[arg_name]:
                                            i.args[arg_name] = obj.args[arg_name]
                                    else:
                                        pass
                self.twcf_file_wv.write_content(i.generate_cmd())
            else:
                self.twcf_file_wv.write_content(i)

        self.twcf_file_wv.teardown()
