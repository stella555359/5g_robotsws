import logging
import re
import os
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB010916.resources.SYSLOG_exeptions import \
    WrongAntPortMappingException


class BtsHelper(GnbDuOperations):

    def get_current_sw_release(self):
        """
        Get current SW release for BTS
        :return: SW release version
        """
        sw_version = self.get_bts_sw_version()
        sw_release = SbtsSwVersion(sw_version).release
        return sw_release

    def _get_current_config_name(self):
        """
        Get name of currently activated config file on BTS (from 'btsName' parameter)
        :return: name of config currently active on BTS
        """
        return self.get_gnb_parameter_value_via_gui(dist_name="MRBTS-77149", param_name="BTS name",
                                                    param_abbr="btsName")

    def is_config_active_on_bts(self, config_name):
        """
        Check if specific config file is active on BTS
        :param config_name:   configuration file name
        :return: True/False depending if config with specific name is active on BTS
        """
        full_config_name = self._get_current_config_name().lower()
        if config_name.lower() in full_config_name:
            return True
        else:
            return False

    @staticmethod
    def get_cell_to_block_for_l3call(cell_for_l3call):
        """
        Get id of cell which should be blocked when making L3 call for Config1
        :param cell_for_l3call:   id of cell where L3 call should be checked
        :return: id of cell which should be blocked
        """
        cell_to_block = 0
        if int(cell_for_l3call) == 0:
            cell_to_block = 1
        return cell_to_block

    @staticmethod
    def check_correct_port_mapping_for_cpri(syslog, port_mapping):
        """
        Check in SYSLOG correct antenna port re-mapping for CPRI cell
        :param syslog:         SYSLOG with antenna port re-mapping prints for CPRI cell
        :param port_mapping:   expected antenna port mapping (i.e. [2,3,1,0])
        """
        ant_port_mapping_cpri_syslog_reqex = re.compile("\\(page [147]0* of 24\\)[a-zA-z: 0-9,{\\[\\]]*")
        ant_port_mapping_cpri_syslog = ant_port_mapping_cpri_syslog_reqex.findall(syslog)
        rru_port_order_cpri_regex = re.compile("rruPortOrder: [0-3]")
        rru_port_order_cpri_syslog = [int(rru_port_order_cpri_regex.findall(ant_port)[0][-1]) for ant_port
                                      in ant_port_mapping_cpri_syslog]
        rru_port_order_cpri_list = rru_port_order_cpri_syslog[-4:]
        expected_port_mapping_list = [int(port) for port in port_mapping.split(",")]
        if rru_port_order_cpri_list != expected_port_mapping_list:
            raise WrongAntPortMappingException("Different antenna port mapping found in SYSLOG for CPRI cell! "
                                               f"Expected {expected_port_mapping_list}, but last prints in SYSLOG for "
                                               f"antenna port mapping is {rru_port_order_cpri_list}")
        else:
            logging.info(f"Antenna port re-mapping OK, expected {expected_port_mapping_list} and found "
                         f"{rru_port_order_cpri_list}")

    def check_correct_port_mapping_for_ecpri(self, syslog, port_mapping, hw="AWHENHD"):
        """
        Check in SYSLOG correct antenna port re-mapping for eCPRI cell
        :param syslog:          SYSLOG with antenna port re-mapping prints for eCPRI cell
        :param port_mapping:    expected antenna port mapping (i.e. [2,3,1,0])
        :param hw:              type of RMOD with eCPRI cell (i.e. AWHENHD)
        """
        ant_port_mapping_ecpri_in_syslog_regex = re.compile("\"ceAxcIdList\":\\[[0123],[0123],[0123],[0123]]")
        ant_port_mapping_ecpri_in_syslog = ant_port_mapping_ecpri_in_syslog_regex.findall(syslog)
        ant_port_mapping_ecpri_str_list = [re.findall("[0123]", port) for port in ant_port_mapping_ecpri_in_syslog][-1]
        ant_port_mapping_ecpri_list = [int(port) for port in ant_port_mapping_ecpri_str_list]
        expected_port_mapping_list = [int(port) for port in port_mapping.split(",")]
        expected_port_mapping_final = \
            self._match_correct_eaxc_values_for_ecpri_awhenhd(port_mapping=expected_port_mapping_list)
        if ant_port_mapping_ecpri_list != expected_port_mapping_final:
            raise WrongAntPortMappingException("Different antenna port mapping found in SYSLOG for eCPRI cell !\n"
                                               f"Checking {expected_port_mapping_list} (for {hw} -> "
                                               f"{expected_port_mapping_final}), but last prints in SYSLOG "
                                               f"for antenna port mapping is {ant_port_mapping_ecpri_list}")
        else:
            logging.info(f"Antenna port re-mapping OK, checking {expected_port_mapping_list} (for {hw} -> "
                         f"{expected_port_mapping_final}) and found {ant_port_mapping_ecpri_list}")

    @staticmethod
    def _match_correct_eaxc_values_for_ecpri_awhenhd(port_mapping):
        """
        Match correct values of eAxC for eCPRI cell of AWHENHD
        :param port_mapping:    antenna port mapping set by user on BTS (i.e. [2,3,1,0])
        :return:                antenna mapping for AWHENHD based on antenna port mapping set by user on BTS
        """
        mapping = {
            (0, 1, 2, 3): [0, 1, 2, 3],
            (0, 1, 3, 2): [0, 1, 3, 2],
            (0, 2, 1, 3): [0, 2, 1, 3],
            (0, 2, 3, 1): [0, 3, 1, 2],
            (0, 3, 1, 2): [0, 2, 3, 1],
            (0, 3, 2, 1): [0, 3, 2, 1],
            (1, 0, 2, 3): [1, 0, 2, 3],
            (1, 0, 3, 2): [1, 0, 3, 2],
            (1, 2, 0, 3): [2, 0, 1, 3],
            (1, 2, 3, 0): [3, 0, 1, 2],
            (1, 3, 0, 2): [2, 0, 3, 1],
            (1, 3, 2, 0): [3, 0, 2, 1],
            (2, 0, 1, 3): [1, 2, 0, 3],
            (2, 0, 3, 1): [1, 3, 0, 2],
            (2, 1, 0, 3): [2, 1, 0, 3],
            (2, 1, 3, 0): [3, 1, 0, 2],
            (2, 3, 0, 1): [2, 3, 0, 1],
            (2, 3, 1, 0): [3, 2, 0, 1],
            (3, 0, 1, 2): [1, 2, 3, 0],
            (3, 0, 2, 1): [1, 3, 2, 0],
            (3, 1, 0, 2): [2, 1, 3, 0],
            (3, 1, 2, 0): [3, 1, 2, 0],
            (3, 2, 0, 1): [2, 3, 1, 0],
            (3, 2, 1, 0): [3, 2, 1, 0],
        }
        return mapping.get(tuple(port_mapping), None)

    def prepare_delta_for_ant_mapping(self, cell_id="1", port_mapping="0,1,2,3", delta_file_path=None,
                                      enable_port_mapping=True, supercell=False):
        """
        Prepare delta json for enabling/disabling antenna port mapping on cell
        :param port_mapping:        required antenna port mapping (i.e. 2,3,1,0)
        :param cell_id:             cell id of cell where port mapping should be set
        :param delta_file_path:     path to delta template for antenna port mapping
        :param enable_port_mapping: if antenna port mapping should be enabled/disabled (true/false)
        :param supercell:           prepare delta for supercell (true/false)
        :return final_delta:        full path of delta json file prepared for enabling/disabling antenna port mapping
        """
        cell_type = "supercell" if supercell else "cell"
        if not delta_file_path:
            delta_file_path = os.path.realpath(__file__).replace("automation_helper.py", "deltas")
        template_delta = f"{delta_file_path}/TEMPLATE-delta_ant_port_mapping_for_{cell_type}.json"
        final_delta = template_delta.replace("TEMPLATE", "FINAL")
        port_mapping = port_mapping.split(",")
        port_mapping_delta = self._get_delta_as_list(delta_json=template_delta)
        port_mapping_delta = self._set_values_in_delta(port_mapping_delta_template=port_mapping_delta, cell_id=cell_id,
                                                       should_enable_port_mapping=enable_port_mapping,
                                                       ant_port_mapping=port_mapping)
        with open(final_delta, 'w') as delta:
            delta.writelines(port_mapping_delta)
        return final_delta

    @staticmethod
    def _get_delta_as_list(delta_json):
        """
        Open delta json file and return it as list of lines
        :param delta_json:      delta json file
        :return final_delta:    return list of lines from delta file
        """
        delta_as_list = list()
        with open(delta_json, 'r') as delta:
            delta_lines = delta.readlines()
            for line in delta_lines:
                delta_as_list.append(line)
        return delta_as_list

    @staticmethod
    def _set_values_in_delta(port_mapping_delta_template, cell_id, should_enable_port_mapping, ant_port_mapping):
        """
        Set correct values in delta template and return final delta for port mapping
        :param port_mapping_delta_template:     template delta json file for port mapping enabling/disabling
        :param cell_id:                         cell id where port mapping should be enabled/disabled
        :param should_enable_port_mapping:      should port mapping should be enabled/disabled (true/false)
        :param ant_port_mapping:                required antenna port mapping (i.e. 2,3,1,0)
        :return:                                return final delta as a list o lines
        """
        for i in range(0, len(port_mapping_delta_template)):
            if port_mapping_delta_template[i].__contains__("$cell_id"):
                port_mapping_delta_template[i] = port_mapping_delta_template[i].replace("$cell_id", cell_id)
            elif port_mapping_delta_template[i].__contains__("$activate_ant_port_mapping"):
                port_mapping_activation = 'true' if should_enable_port_mapping else 'false'
                port_mapping_delta_template[i] = port_mapping_delta_template[i].replace("$activate_ant_port_mapping",
                                                                                        port_mapping_activation)
            elif port_mapping_delta_template[i].__contains__("$mapping_port_operation"):
                port_mapping_operation = 'update' if should_enable_port_mapping else 'delete'
                port_mapping_delta_template[i] = port_mapping_delta_template[i].replace("$mapping_port_operation",
                                                                                        port_mapping_operation)
            elif port_mapping_delta_template[i].__contains__("mapping_port0"):
                port_mapping_delta_template[i] = port_mapping_delta_template[i].replace("$mapping_port0",
                                                                                        ant_port_mapping[0])
            elif port_mapping_delta_template[i].__contains__("mapping_port1"):
                port_mapping_delta_template[i] = port_mapping_delta_template[i].replace("$mapping_port1",
                                                                                        ant_port_mapping[1])
            elif port_mapping_delta_template[i].__contains__("mapping_port2"):
                port_mapping_delta_template[i] = port_mapping_delta_template[i].replace("$mapping_port2",
                                                                                        ant_port_mapping[2])
            elif port_mapping_delta_template[i].__contains__("mapping_port3"):
                port_mapping_delta_template[i] = port_mapping_delta_template[i].replace("$mapping_port3",
                                                                                        ant_port_mapping[3])
        return port_mapping_delta_template
