# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Krzysztof Domino
:contact: krzysztof.domino@nokia.com
"""

import csv
import math
import json
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout_GUI, login_logout

tl = get_builtin_value(param_name="tl")
mrbts_id = tl.gnbs[0].global_bts_id
nrbts_id = tl.gnbs[0].instance_id


class Measuring(GenericBts):
    def __init__(self):
        super(Measuring, self).__init__()

    @login_logout_GUI
    def set_and_start_rf_diagnostic_via_gui(self, bts_id=0, du_id=0):
        """
        Add proper objects to start rf diagnostic test via GUI
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.add_object(object_name='MRBTS-{}/MNL-1/MNLENT-1/TEST-1'.format(mrbts_id),
                                 object_class_name='RFREQ',
                                 id_value=1, is_load_default_values=True, timeout=40, sbts=gui_alias)
        self.gui_coam.add_object(object_name='MRBTS-{}/MNL-1/MNLENT-1/TEST-1'.format(mrbts_id),
                                 object_class_name='RFTHLD',
                                 id_value=1, is_load_default_values=True, timeout=40, sbts=gui_alias)
        if not self.gui_coam.get_object_name_list(object_name="MRBTS-{}/LNBTS-{}".format(mrbts_id, mrbts_id),
                                                  sbts=gui_alias):
            self.gui_coam.remove_element(dist_name='MRBTS-{}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1'.format(mrbts_id),
                                         filter_param="LTE band RF test thresholds",
                                         sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name='MRBTS-{}/MNL-1/MNLENT-1/TEST-1/RFREQ-1'.format(mrbts_id),
                                          filter_param='Target cell type for the test', new_value='NR',
                                          sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(sbts=gui_alias)

    @login_logout_GUI
    def check_diagnostic_test_results_via_gui(self, cell_id, bts_id=0, du_id=0):
        """
        Check results of rf diagnostic test via GUI
        @param cell_id: int, cell id on which rf diagnostic test to be checked
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        test_result = self.gui_coam.get_parameter_value(dist_name='MRBTS-{}/MNL-1/MNLENT-1/TEST-1/RFREQ-1/RFRES-{}'.
                                                        format(mrbts_id, cell_id), filter_param='Test outcome',
                                                        sbts=gui_alias)
        rssi = self.gui_coam.get_parameter_value(dist_name='MRBTS-{}/MNL-1/MNLENT-1/TEST-1/RFREQ-1/RFRES-{}'.
                                                 format(mrbts_id, cell_id), filter_param='Reverse RSSI',
                                                 sbts=gui_alias)
        return test_result, rssi

    @login_logout_GUI
    def remove_diagnostic_test_objects(self, bts_id=0, du_id=0):
        """
        Remove objects created to perform rf diagnostic test
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.remove_object(object_name='MRBTS-{}/MNL-1/MNLENT-1/TEST-1/RFREQ-1'.format(mrbts_id),
                                    sbts=gui_alias)
        self.gui_coam.remove_object(object_name='MRBTS-{}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1'.format(mrbts_id),
                                    sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(sbts=gui_alias)

    @login_logout_GUI
    def start_antenna_line_monitoring_via_gui(self, bts_id=0, du_id=0):
        """
        Start Antenna Line Online Monitoring via GUI
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.select_antenna_lines_for_monitoring(sbts=gui_alias)
        self.gui_coam.start_antenna_line_monitoring(sbts=gui_alias)

    @login_logout_GUI
    def stop_antl_monitoring_and_export_to_csv(self, bts_id=0, du_id=0):
        """
        Stop Antenna Line Online Monitoring via GUI
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.stop_antenna_line_monitoring(sbts=gui_alias)
        output_file = self.gui_coam.export_monitored_value_to_csv(sbts=gui_alias)
        return output_file

    @login_logout_GUI
    def reset_nr_rat_via_gui(self, bts_id=0, du_id=0):
        """
        Reset NR RAT via GUI
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        """
        self.gui_coam.reset_nr(sbts=self.gui_alias.format(bts_id, du_id))

    def evaluate_measuring_rounds(self, time1):
        """
        Evaluate amount of rounds during antenna line online monitoring
        @param du_id: id related to Test Line configuration, default 0
        @return: int, number of measuring rounds, equals to (measuring time/ 10(s) -1)
        """
        return math.floor(time1 / 10) - 1

    def check_RSSI_in_csv_file(self, file, cell_id):
        """
        Get RSSI results list from file contains monitoring results
        @param file: path to csv file with monitoring results
        @param cell_id: int, cell id on which rf diagnostic test to be checked
        @return: list, list of RSSI results
        """
        with open(file, 'r') as f:
            reader = csv.reader(f)
            results = list(reader)
            lenth_csv = len(results)
            for measuring_output in range(lenth_csv):
                if 'RSSI (dBm)' in results[measuring_output]:
                    RSSI_index1 = measuring_output
                if 'ETP (mW)' in results[measuring_output]:
                    ETP_index1 = measuring_output
        f.close()
        RSSI_content = results[RSSI_index1 + 2:ETP_index1 - 1]
        RSSI_value = []
        for meas_value in range(len(RSSI_content)):
            if 'NRCELL-{}'.format(cell_id) in RSSI_content[meas_value]:
                index2 = list(RSSI_content[meas_value]).index('NRCELL-{}'.format(cell_id))
                RSSI_data = RSSI_content[meas_value][index2 + 1:]
                for rssi in RSSI_data:
                    RSSI_value.append(rssi)
        return RSSI_value

    def judge_value(self, values_list):
        """
        Check if values in list are correct
        @param values_list: list of values to be checked
        @return: bollean, if all values in list are different from 0 return True, otherwise -> False
        """
        result = []
        for value in values_list:
            if value != '-':
                rssi = float(value)
                if rssi < 0 or rssi > 0:
                    status = 'true'
            else:
                status = 'false'
            result.append(status)
        if 'false' in result:
            judge_result = False
        else:
            judge_result = True
        return judge_result

    def check_positive_rssi_value(self, measuring_time1, measuring_time2, table):
        """
        Check if RSSI was measured correctly before and after break
        @param measuring_time1: time before break
        @param measuring_time2: time after break
        @param table:list, list of RSSI values
        @return: boolean, return True if RSSI was correctly measured, otherwise False
        """
        first_rounds = self.evaluate_measuring_rounds(measuring_time1)
        last_rounds = self.evaluate_measuring_rounds(measuring_time2)
        first_correct_table = table[:first_rounds]
        second_correct_table = table[-last_rounds:]
        break_table = table[first_rounds:-last_rounds]
        judge_call_before_break = self.judge_value(first_correct_table)
        judge_call_after_break = self.judge_value(second_correct_table)
        break_result = self.judge_value(break_table)
        if judge_call_before_break and judge_call_after_break and not break_result:
            return 'True'
        else:
            return 'False'

    @login_logout
    def start_antl_monitoring_via_cli(self, cell_id, rat_type='NR', bts_id=0, du_id=0):
        """
        Start Antenna Line Online Monitoring via CLI
        @param cell_id: int, cell id to be checked via Antenna Line Online Monitoring
        @param rat_type: str, rat_type
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        """
        target_dns = self.get_runtime_antennas_for_cell(cell_id, str(rat_type))
        self.admin.start_antl_online_monitoring(target_dns, connection=self.rest_alias.format(bts_id, du_id))

    @login_logout
    def get_runtime_antennas_for_cell(self, cell_id, rat_type='NR', bts_id=0, du_id=0):
        """
        Get Runtime antennas related to given cell
        @param cell_id: int, cell id
        @param rat_type: str, rat_type
        @return: list, list of runtime antennas related to given cell
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        """

        cell_id_from_conf = self.admin.get_cell_id_by_configuration_id(rat=str(rat_type),
                                                                       configuration_id=cell_id,
                                                                       connection=self.rest_alias.format(bts_id, du_id))
        info = self.admin.get_cell_specific_info(
            cell_id=cell_id_from_conf,
            connection=self.rest_alias.format(bts_id, du_id))
        runtime_antennas = []
        for ant_info in info['carrierList']:
            runtime_antennas.append(ant_info['antennaLineId']['internal'])
        return list(set(runtime_antennas))

    @login_logout
    def stop_antl_monitoring_via_cli(self, output_file_name, bts_id=0, du_id=0):
        """
        Stop Antenna Line Online Monitoring via CLI
        @param output_file_name: name of file as result of monitoring
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        """
        self.admin.stop_antl_online_monitoring(output_file_name, connection=self.rest_alias.format(bts_id, du_id))

    def check_RSSI_in_csv_file_cli(self, file, cell_id):
        """
        Get RSSI results list from file contains monitoring results via CLI
        @param file: path to csv file with monitoring results
        @param cell_id: int, cell id on which rf diagnostic test to be checked
        @return: list, list of RSSI results
        """
        with open(file, 'r') as f:
            data = f.read()
            json_data = json.loads(data)
            rssi_value = []
            for rssi in json_data['RSSI'][0]['antennaLines'][0]['measureDatas']['NRCELL-{}'.format(
                    cell_id)].values():
                rssi_value.append(rssi)
        f.close()
        return rssi_value

    @login_logout_GUI
    def reset_bbmod(self, abil_index=1, bts_id=0, du_id=0):
        """
        Reset BBMOD via GUI
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        """
        self.gui_coam.reset_abil(abil_index=abil_index, sbts=self.gui_alias.format(bts_id, du_id))
