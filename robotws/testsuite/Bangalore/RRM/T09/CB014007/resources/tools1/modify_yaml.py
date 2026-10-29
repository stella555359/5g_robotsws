# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
import re
import yaml
import sys
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
builtin_obj = BuiltIn()
os_obj = OperatingSystem()


class modify_yaml(object):

    def __init__(self):
        self.yaml_context = ""
        self.yaml_context_formatted = []

    def _remove_empty_from_list(self, list_in):
        list_out = []
        list1 = []
        if not isinstance(list_in, list):
            list_in = [list_in]
        for value in list_in:
            is_python2 = sys.version_info.major == 2
            if is_python2:
                str_type = (unicode, bytes)
            else:
                str_type = (str, bytes)
            if isinstance(value, str_type):
                if len(value.strip()) != 0:
                    list1.append(value.strip())
            else:
                list1.append(value.strip())
        return list1

    def _get_new_plmn(self, plmn_old, scf_params):
        new_mcc = new_mnc = ""
        for param in scf_params:
            if re.search(r"LNBTS(-\d+|):mcc=", param, re.I):
                new_mcc = param.split("=")[-1]
            elif re.search(r"LNBTS(-\d+|):mnc=", param, re.I):
                new_mnc = param.split("=")[-1]
                if len(new_mnc) == 1:
                    new_mnc = "0" + new_mnc
            else:
                pass
        plmn_new = plmn_old
        if len(new_mcc) != 0:
            plmn_new = "{}:".format(new_mcc) + plmn_new.split(":")[-1]
        if len(new_mnc) != 0:
            plmn_new = plmn_new.split(":")[0] + ":{}".format(new_mnc)
        return plmn_new

    def _adapt_mme_and_ue_plmn(self):
        if "MME_POOL_AREA" in self.yaml_context.get("EPC"):
            mme_plmn = self.yaml_context.get("EPC").get("MME_POOL_AREA")[0]["plmn"]
            enb_plmn = self.yaml_context.get("BASE_STATIONS")[0].get("plmn")
            if mme_plmn != enb_plmn:
                # update plmn in EPC/MME_POOL_AREA/1
                self.yaml_context.get("EPC").get("MME_POOL_AREA")[0]["plmn"] = enb_plmn
                # update mcc, mnc in UEs/UE_sets/*
                ue_sets_list = self.yaml_context.get("UEs").get("UE_sets")
                for ue in ue_sets_list:
                    ue["mcc"] = enb_plmn.split(":")[0]
                    ue["mnc"] = enb_plmn.split(":")[-1]

    def _adapt_mme_tac(self, enb_id=1):
        # update tac in mme
        if "MME_POOL_AREA" in self.yaml_context.get("EPC"):
            mme_tac = self.yaml_context.get("EPC").get("MME_POOL_AREA")[0].get("tac_list")
            enb_tac = self.yaml_context.get("BASE_STATIONS")[enb_id-1].get("cells")[0].get("tac")
            if str(enb_tac) not in str(mme_tac).split(","):
                self.yaml_context.get("EPC").get("MME_POOL_AREA")[0]["tac_list"] = "{},{}".format(mme_tac, enb_tac)

    def _adapt_real_enb_part(self, real_enb_dict, scf_params, lcrid_start='1', rrhid_start=1):
        # update enb2
        if lcrid_start == "51":
            # update id, s1, lmp_ip, trsw_ip
            enb2_s1_ip = builtin_obj.get_variable_value("${ENB2_IP}")
            real_enb_dict["id"] = 2
            real_enb_dict["s1"] = enb2_s1_ip
            real_enb_dict["cus_config"][0]["id"] = "2"
            real_enb_dict["cus_config"][0]["lmp_ip"] = "192.168.200.2"
            real_enb_dict["cus_config"][0]["trsw_ip"] = "10.0.2.4"

            # update rru id
            # update cell id in RRU to 51,52...
            rrhid = rrhid_start
            for rru in real_enb_dict["RRH"]:
                rru["id"] = rrhid
                rrhid = rrhid + 1
                antennas = rru["antennas"]
                for key in antennas.keys():
                    if type(antennas[key]) is dict:
                        antennas[key]["cell"] = int(antennas[key]["cell"]) + int(lcrid_start) - 1
                    elif type(antennas[key]) is list:
                        for item in antennas[key]:
                            item["cell"] = int(item["cell"]) + int(lcrid_start) - 1
                    else:
                        raise Exception("antennas[key]={} is wrong".format(antennas[key]))

            # update cells id nad pci to 51,52..., laa_bound_to_lte to 51,...
            for cell in real_enb_dict["cells"]:
                cell["id"] = int(cell["id"]) + int(lcrid_start) - 1
                mod3 = int(cell["id"]) % 3
                quotient3 = int(cell["id"]) // 3
                cell["pci"] = "{}:{}".format(quotient3, mod3)
                if "laa_bound_to_lte" in cell.keys():
                    cell["laa_bound_to_lte"] = int(cell["laa_bound_to_lte"]) + int(lcrid_start) - 1

        # update sync_source, it is PPS in 2enb, but backplanePPS for single enb (FSMF excluded)
        bts_number = builtin_obj.get_variable_value("${BTS_NUMBER}")
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        if bts_number == "1":
            if bbu_type == "FSMF":  # for CLOUD_FCC_CUS or CLOUD_FCC_CUS_A
                real_enb_dict["cus_config"][0]["sync_source"] = "PPS"
            else:
                real_enb_dict["cus_config"][0]["sync_source"] = "BackplanePPS"
        else:
            real_enb_dict["cus_config"][0]["sync_source"] = "PPS"

        # update connector according to system module type
        # delete connector, by default all EIF are enabled
        if "connector" in real_enb_dict.get("cus_config")[0]:
            del real_enb_dict.get("cus_config")[0]["connector"]

        # update PLMN
        plmn_old = real_enb_dict.get("plmn")
        plmn_new = self._get_new_plmn(plmn_old, scf_params)
        if plmn_new != plmn_old:
            real_enb_dict["plmn"] = plmn_new

        # update pci, tac and earfcn of real enb
        cells_list = real_enb_dict.get("cells")
        for cell in cells_list:
            # update pci, tac
            cell_id = cell['id']
            if lcrid_start == "51":
                cell_id = int(cell_id) - int(lcrid_start) + 1
            for param in scf_params:
                if param.count("LNCEL-{}:phyCellId".format(cell_id)) \
                        or param.count("LNCEL:phyCellId"):
                    mod3 = int(param.split("=")[-1]) % 3
                    quotient3 = int(param.split("=")[-1]) // 3
                    cell["pci"] = "{}:{}".format(quotient3, mod3)
                elif param.count("LNCEL-{}:tac".format(cell_id)) \
                        or param.count("LNCEL:tac"):
                    cell["tac"] = int(param.split("=")[-1])
                else:
                    pass
            # update earfcn, but it may be optional
            if "earfcn" in cell.keys():
                current_earfcn = cell["earfcn"]
                for param in scf_params:
                    # for FDD earfcn: '<earfcnDL>:<earfcnUL>', for TDD earfcn: 'earfcn'
                    if param.count("LNCEL-{}/LNCEL_FDD-0:earfcnDL".format(cell_id)) \
                            or param.count("LNCEL/LNCEL_FDD-0:earfcnDL"):
                        cell["earfcn"] = "{}:{}".format(param.split("=")[-1], current_earfcn.split(":")[-1])
                        current_earfcn = cell["earfcn"]
                    elif param.count("LNCEL-{}/LNCEL_FDD-0:earfcnUL".format(cell_id)) \
                            or param.count("LNCEL/LNCEL_FDD-0:earfcnUL"):
                        cell["earfcn"] = "{}:{}".format(current_earfcn.split(":")[0], param.split("=")[-1])
                        current_earfcn = cell["earfcn"]
                    elif param.count("LNCEL-{}/LNCEL_TDD-0:earfcn".format(cell_id)) \
                            or param.count("LNCEL/LNCEL_TDD-0:earfcn"):
                        cell["earfcn"] = param.split("=")[-1]
                    else:
                        pass

    def setup_yaml(self, input_yaml, ue_count, scf_params):
        self.yaml_context_formatted = []
        with open(input_yaml, "r") as f:
            self.yaml_context = yaml.safe_load(f)
            # print(self.yaml_context)
        real_enb_dict = self.yaml_context.get("BASE_STATIONS")[0]
        self._adapt_real_enb_part(real_enb_dict, scf_params)
        self._adapt_mme_and_ue_plmn()
        self._adapt_mme_tac()
        # extend ue count according to ue[0]
        ue_sets_list = self.yaml_context.get("UEs").get("UE_sets")
        current_ue_count = len(ue_sets_list)
        for ue_id in range(current_ue_count + 1, int(ue_count) + 1):
            ue_dict = ue_sets_list[0].copy()
            ue_dict["ids"] = ue_id
            self.yaml_context["UEs"]["UE_sets"].append(ue_dict)

        # set LOGS/ECP/log_level according to ${DEBUG_LOG_LEVEL}
        log_level = builtin_obj.get_variable_value("${DEBUG_LOG_LEVEL}")
        self.yaml_context["LOGS"]["EPC"]["log_level"] = int(log_level)
        # set LOGS/CUS/syslog_level according to ${CUS_SYSLOG_MODE}
        CUS_SYSLOG_MODE = builtin_obj.get_variable_value("${CUS_SYSLOG_MODE}")
        self.yaml_context["LOGS"]["CUS"]["syslog_mode"] = CUS_SYSLOG_MODE
        # set LOGS/CUS/log_level according to ${CUS_LOG_LEVEL}
        cus_log_level = builtin_obj.get_variable_value("${CUS_LOG_LEVEL}")
        self.yaml_context["LOGS"]["CUS"]["log_level"] = cus_log_level

    def setup_yaml_2cus(self, input_yaml_enb1, scf_params_enb1, input_yaml_enb2, scf_params_enb2, ue_count):
        self.yaml_context_formatted = []
        with open(input_yaml_enb1, "r") as f:
            self.yaml_context = yaml.safe_load(f)
            # print(self.yaml_context)
        with open(input_yaml_enb2, "r") as f2:
            yaml_context_enb2 = yaml.safe_load(f2)
        # modify enb1 part based on input_yaml_enb1
        real_enb_dict = self.yaml_context.get("BASE_STATIONS")[0]
        self._adapt_real_enb_part(real_enb_dict, scf_params_enb1, lcrid_start="1")
        # add enb2 part based on input_yaml_enb2
        enb1_rrh_number = len(real_enb_dict["RRH"])
        real_enb2_dict = yaml_context_enb2.get("BASE_STATIONS")[0]
        self._adapt_real_enb_part(real_enb2_dict, scf_params_enb2, lcrid_start="51", rrhid_start=enb1_rrh_number + 1)
        self.yaml_context["BASE_STATIONS"].append(real_enb2_dict)
        # update mme and ue plmn
        if real_enb_dict.get("plmn") == real_enb2_dict.get("plmn"):
            self._adapt_mme_and_ue_plmn()
        else:
            raise Exception("plmn is different in enb1 and enb2, "
                            "enb1 plmn={}, enb2 plmn={}".format(real_enb_dict.get("plmn"),
                                                                real_enb2_dict.get("plmn")))
        # update mme tac
        self._adapt_mme_tac()
        self._adapt_mme_tac(enb_id=2)
        # extend ue count according to ue[0]
        ue_sets_list = self.yaml_context.get("UEs").get("UE_sets")
        current_ue_count = len(ue_sets_list)
        for ue_id in range(current_ue_count + 1, int(ue_count) + 1):
            ue_dict = ue_sets_list[0].copy()
            ue_dict["ids"] = ue_id
            self.yaml_context["UEs"]["UE_sets"].append(ue_dict)
        # set LOGS/ECP/log_level according to ${DEBUG_LOG_LEVEL}
        log_level = builtin_obj.get_variable_value("${DEBUG_LOG_LEVEL}")
        self.yaml_context["LOGS"]["EPC"]["log_level"] = int(log_level)
        # set LOGS/CUS/syslog_level according to ${CUS_SYSLOG_MODE}
        CUS_SYSLOG_MODE = builtin_obj.get_variable_value("${CUS_SYSLOG_MODE}")
        self.yaml_context["LOGS"]["CUS"]["syslog_level"] = CUS_SYSLOG_MODE

    def _format_list(self, list_in, level, first_list_one_line=False):
        """
        list with dict element, one line per element, and start with -
        """
        space_number = " " * 2 * level
        for element1 in list_in:
            if type(element1) is dict:
                if first_list_one_line:
                    self.yaml_context_formatted.append("{}- {}".format(space_number, element1))
                else:
                    first_key, first_value = list(element1.items())[0]
                    self.yaml_context_formatted.append("{}- {}: {}".format(space_number, first_key, repr(first_value)))
                    for key, value in list(element1.items())[1:]:
                        if type(value) is list and type(value[0]) is dict:
                            self.yaml_context_formatted.append("{}  {}:".format(space_number, key))
                            for element2 in value:
                                self.yaml_context_formatted.append("{}    - {}".format(space_number, element2))
                        else:
                            self.yaml_context_formatted.append("{}  {}: {}".format(space_number, key, repr(value)))

    def _format_yaml_file_content(self):
        for key_l1, value_l1 in self.yaml_context.items():
            if type(value_l1) is list:
                self.yaml_context_formatted.append("{}:".format(key_l1))
                self._format_list(value_l1, level=1, first_list_one_line=False)
            elif type(value_l1) is dict:
                self.yaml_context_formatted.append("{}:".format(key_l1))
                for key_l2, value_l2 in value_l1.items():
                    if type(value_l2) is list:
                        self.yaml_context_formatted.append("  {}:".format(key_l2))
                        if key_l2 in ["UE_sets", "MME_POOL_AREA"]:
                            self._format_list(value_l2, level=2, first_list_one_line=True)
                        else:
                            self._format_list(value_l2, level=2, first_list_one_line=False)
                    elif type(value_l2) is dict:
                        self.yaml_context_formatted.append("  {}:".format(key_l2))
                        for key_l3, value_l3 in value_l2.items():
                            if type(value_l3) is list:
                                self.yaml_context_formatted.append("    {}:".format(key_l3))
                                self._format_list(value_l3, level=3, first_list_one_line=True)
                            elif type(value_l3) is dict:
                                self.yaml_context_formatted.append("    {}:".format(key_l3))
                                for key_l4, value_l4 in value_l3.items():
                                    self.yaml_context_formatted.append("      {}: {}".format(key_l4, repr(value_l4)))
                            else:
                                self.yaml_context_formatted.append("    {}: {}".format(key_l3, repr(value_l3)))
                    else:
                        self.yaml_context_formatted.append("  {}: {}".format(key_l2, repr(value_l2)))
            else:
                self.yaml_context_formatted.append("{}: {}".format(key_l1, repr(value_l1)))

    def add_yaml(self, key_path, *add_content):
        """
        This keyword is to add new configuration to cus yaml file
        | Arguments        | Man. | Default | Description |
        | key_path         | Yes  | NA      | target key path, separated by / |
        | add_content      | Yes  | NA      | add content, only one dictionary structure or list structure |

        Examples:
        1) add one dictionary structure
        | Add Yaml | UEs/bearer_sets |
        | ...      | bearer_set_2: |
        | ...      |  - {qci: 8, default: on, pdn: 1, trf_type: external} |
        | ...      |  - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31} |
        2) add one list (start with -)
        | Add Yaml |  BASE_STATIONS
        | ...      |   - id: 2
        | ...      |     type: simulated
        | ...      |     plmn: '262:03'
        | ...      |     s1: 10.0.1.3
        | ...      |     cells:
        | ...      |      - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}
        3) add multiple dictionary or list structure
        | Add Yaml | UEs/bearer_sets |
        | ...      | bearer_set_2: |
        | ...      |  - {qci: 8, default: on, pdn: 1, trf_type: external} |
        | ...      |  - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31} |
        | Add Yaml | UEs/bearer_sets |
        | ...      | bearer_set_3: |
        | ...      |  - {qci: 5, default: on, pdn: 1, trf_type: external} |
        | ...      |  - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31} |
        """
        # convert input into yaml string
        indent = 0
        add_content_2 = []
        for key in key_path.split("/"):
            add_content_2.append("{}{}:".format(indent * "  ", key))
            indent = indent + 1
        for line in add_content:
            if len(line.strip()) == 0:
                continue
            add_content_2.append("{}{}".format(indent * "  ", line))
            if line.endswith(":"):
                indent = indent + 1
            elif line.startswith("- ") and not line.startswith("- {"):
                indent = indent + 1
        input_str = "\n".join(add_content_2)
        print("debug: add content\n{}".format(input_str))

        # load yaml string
        input_yaml = yaml.safe_load(input_str)
        if len(input_yaml.keys()) != 1:
            raise Exception("only one key supported, but keys are：{}".format(input_yaml.keys()))
        key1, value1 = list(input_yaml.items())[0]
        # new key
        if key1 not in self.yaml_context.keys():
            self.yaml_context[key1] = value1
        else:
            # add list to existing key
            if type(value1) is list:
                self.yaml_context[key1].extend(value1)
            # add dict to existing key
            elif type(value1) is dict:
                for key2, value2 in value1.items():
                    if key2 not in self.yaml_context[key1].keys():
                        self.yaml_context[key1][key2] = value2
                    else:
                        if type(value2) is list:
                            self.yaml_context[key1][key2].extend(value2)
                        elif type(value2) is dict:
                            for key3, value3 in value2.items():
                                if key3 not in self.yaml_context[key1][key2].keys():
                                    self.yaml_context[key1][key2][key3] = value3
                                else:
                                    if type(value3) is list:
                                        self.yaml_context[key1][key2][key3].extend(value3)
                                    elif type(value3) is dict:
                                        for key4, value4 in value4.items():
                                            self.yaml_context[key1][key2][key3][key4] = value4
                                    else:
                                        self.yaml_context[key1][key2][key3] = value3
                        else:
                            self.yaml_context[key1][key2] = value2

            else:
                self.yaml_context[key1] = value1

    def update_yaml(self, key_path, *update_content):
        """
        This keyword is to add new configuration to cus yaml file
        | Arguments        | Man. | Default | Description |
        | key_path         | Yes  | NA      | target key path, separated by / |
        | update_content   | Yes  | NA      | update content, format is key: value |

        Example:
        | Update Yaml | UEs/UE_sets/3 | capability: xxx | capability_nr: yyy |
        | Update Yaml | UEs/UE_sets/4 | bearer: bearer_set_2 |
        | Update Yaml | LOGS/EPC | log_level: 1 |
        | Update Yaml | EPC/WS/1 | link_ctrl_param: {use_hb: off} |

        Note: if key_path ends with digital, even if the key in update_content is new, update yaml need to be used.
        For example: mirroring_l2_on_startup not in original cus.yaml, need to add it:
        | Update Yaml | BASE_STATIONS/1/cus_config/1 | mirroring_l2_on_startup: 1 |
        """
        # key_path, values = "UEs/UE_sets/1", "bearer:bearer_set_2"
        keys = []
        for key in key_path.split("/"):
            if key.isdigit():
                keys.append(int(key) - 1)
            else:
                keys.append(key)
        for value in update_content:
            if len(value.strip()) == 0:
                continue
            target_key = value.partition(":")[0].strip().replace("'", "")
            target_value = value.partition(":")[-1].strip()
            if target_value.startswith("'"):
                target_value = target_value.replace("'", "")
            if target_value.isdigit() and not target_value.startswith("0"):
                target_value = int(target_value)
            if len(keys) == 1:
                key1 = keys[0]
                self.yaml_context[key1][target_key] = target_value
            elif len(keys) == 2:
                key1, key2 = keys
                self.yaml_context[key1][key2][target_key] = target_value
            elif len(keys) == 3:
                key1, key2, key3 = keys
                self.yaml_context[key1][key2][key3][target_key] = target_value
            elif len(keys) == 4:
                key1, key2, key3, key4 = keys
                self.yaml_context[key1][key2][key3][key4][target_key] = target_value
            elif len(keys) == 5:
                key1, key2, key3, key4, key5 = keys
                self.yaml_context[key1][key2][key3][key4][key5][target_key] = target_value
            else:
                raise Exception("not support {} level key path:{}".format(len(keys), key_path))

    def teardown_yaml(self, output_yaml):
        # enable simulated enb x2 trace
        for enb in self.yaml_context["BASE_STATIONS"]:
            if enb["type"] == "simulated":
                if "TRACE" in self.yaml_context["LOGS"]["EPC"].keys():
                    self.yaml_context["LOGS"]["EPC"]["TRACE"]["ENB-{}".format(enb["id"])] = {"x2": True}
                else:
                    self.yaml_context["LOGS"]["EPC"]["TRACE"] = {"ENB-{}".format(enb["id"]): {"x2": False}}

        self._format_yaml_file_content()
        params_on_off = ["default", "s1", "nas", "x2"]
        with open(output_yaml, "w") as f:
            for line in self.yaml_context_formatted:
                for param in params_on_off:
                    line = line.replace("'{}': True".format(param), "'{}': on".format(param))
                    line = line.replace("'{}': False".format(param), "'{}': off".format(param))
                line = line.replace("\"[", "[").replace("]\"", "]").replace("\'[", "[").replace("]\'", "]")
                line = line.replace("\"{", "{").replace("}\"", "}").replace("\'{", "{").replace("}\'", "}")
                f.write(line + "\n")

    def wa_for_ue_capability(self):
        """
        UE-EUTRA-Capability ::=
        should be
        value UE-EUTRA-Capability ::=
        """
        # Capabilities-1670153766455.asn:UE-EUTRA-Capability ::=
        ue_cap_dir = "/home/cus/test/ue_capabilities"
        out = os_obj.run("grep 'Capability ::=' {}/Capabilities*.asn".format(ue_cap_dir))
        for line in out.splitlines():
            if line.count("value"):
                continue
            else:
                file_name = line.split(":")[0]
                capability = line.split(":")[1].strip()
                cmd = "sudo sed -i 's:{}:value {}:g' {}".format(capability, capability, file_name)
                os_obj.run(cmd)


if __name__ == "__main__":
    yaml_obj = modify_yaml()
    # scf_params = ["LNBTS:mcc=214", "LNBTS-1:mnc=3", "LNBTS-1:mncLength=2"]
    scf_params = []
    yaml_obj.setup_yaml(r"..\..\..\configuration_file\trunk\CLOUD_R4xAPO_CUS\3CELLs_FDD\cus.yaml",
                        ue_count=10, scf_params=scf_params)
    input_1 = [
        '- {qci: 8, default: on, pdn: 1, trf_type: external}',
        '- {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 4, precedence: 4}']
    input_2 = [
        '- id: 2',
        'type: simulated',
        "plmn: '262:03'",
        's1: 10.0.1.3',
        'cells:',
        "- {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400', bw: 20}",
        "- {id: 22, technology: lte, tac: 33, pci: '3:1', earfcn: '8770', bw: 20}",
        "- {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '8770', bw: 20}"
    ]
    input_3 = ['qci: 6']
    yaml_obj.add_yaml("UEs/bearer_sets/bearer_set_2", *input_1)
    yaml_obj.add_yaml("BASE_STATIONS", *input_2)
    yaml_obj.update_yaml("UEs/bearer_sets/bearer_set_1/1", *input_3)
    yaml_obj.teardown_yaml(r"test_output.yaml")
