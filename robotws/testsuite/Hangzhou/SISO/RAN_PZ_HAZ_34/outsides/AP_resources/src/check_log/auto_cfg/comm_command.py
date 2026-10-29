# -*- coding: utf-8 -*-

"""
:author:     eric.jiang
:contact:    eric.jiang@nokia-sbell.com
:maintainer: eric.jiang@nokia-sbell.com
"""

import re
from collections import OrderedDict


class command(object):
    def __init__(self, command):
        cmdlist = command.split()
        if command.startswith("set_ue simulated") or command.startswith("ue_set simulated"):
            self.cmd_header = "%s %s" % (cmdlist[0], cmdlist[1])
            self.cmd_content = " ".join(cmdlist[2:]).strip()
        else:
            self.cmd_header = cmdlist[0]
            self.cmd_content = " ".join(command.split()[1:]).strip()

        ret = re.match(r"(.+)_set\s+(simulated)*", self.cmd_header)
        if ret:
            self.cmd_header = re.sub(r"(.+_set)", "set_%s" % ret.group(1), self.cmd_header)

        self.args = self.transfer_param_str_to_dict(self.cmd_content)
        for key, value in self.args.items():
            self.__setattr__(key, value)

        if self.cmd_header.startswith("set_"):
            if self.cmd_header == "set_ue simulated":
                if "suci" in self.args:
                    self.type = "sa_ue"
                elif "imsi" in self.args:
                    self.type = "nsa_ue"
                else:
                    # Update Cfg Param , maybe didn't write "suci" or "imsi"
                    self.type = "ucp_ue"
            else:
                self.type = re.sub(r"set_", "", self.cmd_header)
        elif self.cmd_header.endswith("_set"):
            if self.cmd_header == "ue_set simulated":
                if "suci" in self.args:
                    self.type = "sa_ue"
                elif "imsi" in self.args:
                    self.type = "nsa_ue"
                else:
                    # Update Cfg Param , maybe didn't write "suci" or "imsi"
                    self.type = "ucp_ue"
            else:
                self.type = re.sub(r"_set", "", self.cmd_header)
        elif self.cmd_header == "ue_param":
            if "dual_conn=" in self.cmd_content or "ue_eutra_nr_capabilities" in self.cmd_content:
                self.type = "nsa_ue_param"
            else:
                self.type = "sa_ue_param"
        else:
            self.type = self.cmd_header

        if self.cmd_header == "set_cell" or self.cmd_header == "cell_set":
            if "gnb" in self.args.keys():
                self.diff = "%s_id^gnb=%s^%s" % (self.type, self.args["id"], self.args["gnb"])
            elif "enb" in self.args.keys():
                self.diff = "%s_id^enb=%s^%s" % (self.type, self.args["id"], self.args["enb"])
        elif self.cmd_header == "set_bearer" or self.cmd_header == "bearer_set":
            self.diff = "%s_id^ue=%s^%s" % (self.type, self.args["id"], self.args["ue"])
        elif self.cmd_header in ["set_backup_amf", "enb_timer", "enb_x2_link_up"]:
            self.diff = self.type
        elif self.cmd_header == "gnb_make_plmnset":
            self.diff = "%s*plmn_set_id=%s" % (self.type, self.args["plmn_set_id"])
        elif self.cmd_header == "gnb_set_nwslice_per_plmn":
            ret = {}
            for k, v in self.args.items():
                if k != "nssai":
                    ret[k] = v
            sorted(ret)
            self.diff = "%s_%s=%s" % (self.type, "^".join(ret.keys()), "^".join(ret.values()))
        elif self.cmd_header == "enb_cell_param":
            self.diff = "%s_id^enb=%s^%s" % (self.type, self.args["id"], self.args["enb"])
        elif self.cmd_header == "gnb_cell_param":
            self.diff = "%s_id^gnb=%s^%s" % (self.type, self.args["id"], self.args["gnb"])
        elif self.cmd_header == "amf_ue_ics_param":
            self.diff = "%s_id=%s" % (self.type, self.args["id"])
        elif self.cmd_header == "set_qci" or self.cmd_header == "qci_set":
            self.diff = "%s_qci=%s" % (self.type, self.args["qci"])
        elif self.cmd_header == "cell_srs_beam_pos_nr":
            self.diff = "%s^profile_id=%s" % (self.type, self.args["profile_id"])
        elif self.cmd_header == "cell_testmode_set_nr":
            self.diff = "%s_cell_id^gnb=%s^%s" % (self.type, self.args["cell_id"], self.args["gnb"])
        else:
            if "id" in self.args.keys():
                self.diff = "%s_id=%s" % (self.type, self.args["id"])
            else:
                tmp = "%s_" % self.type
                for k, v in self.args.items():
                    tmp += "%s_%s^" % (k, v)
                self.diff = tmp[:-1]

    def transfer_param_str_to_dict(self, str):
        res_dict = OrderedDict()
        tmpL = str.strip().split()
        spindex = 0
        for i in tmpL:
            if i.strip().partition("=")[0] not in res_dict.keys():
                res_dict[i.strip().partition("=")[0]] = i.strip().partition("=")[2]
            else:
                spindex += 1
                res_dict["%s----%d" % (i.strip().partition("=")[0], spindex)] = i.strip().partition("=")[2]
        return res_dict

    def generate_cmd(self):
        self.whole_cmd = "%s" % self.cmd_header
        for key, value in self.args.items():
            if "----" not in key:
                if len(value) > 0:
                    self.whole_cmd += " {}={}".format(key, value)
                else:
                    self.whole_cmd += " {}".format(key)
            else:
                self.whole_cmd += " {}={}".format(key.partition("----")[0], value)
        return self.whole_cmd

    def modify_cmd(self, param_str):
        ret = self.transfer_param_str_to_dict(param_str)
        for key, value in ret.items():
            if key in self.args.keys():
                self.args[key] = value
            else:
                self.args[key] = value
        return self.generate_cmd()

    def replace_cmd(self, param_str):
        self.args = self.transfer_param_str_to_dict(param_str)
        return self.generate_cmd()
