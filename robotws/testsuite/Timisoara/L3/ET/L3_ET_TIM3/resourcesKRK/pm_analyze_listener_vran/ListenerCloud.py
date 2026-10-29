# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Bartosz Szlezak
:contact: bartosz.szlezak@nokia.com
:maintainer: Bartosz Szlezak
:contact: bartosz.szlezak@nokia.com
"""
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from robot.running.signalhandler import STOP_SIGNAL_MONITOR
from robot.libraries.OperatingSystem import OperatingSystem
from testsuite.Timisoara.L3.ET.L3_ET_TIM3.resourcesKRK.krk3_common.Python.VRanPmCountersExtension \
    import VRanPmCountersExtension
import sys
import yaml
import time
import signal
import json
BuiltIn().import_resource('testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/krk3_common/configurators_vran.robot')


class ListenerCloud(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self, expected_counters_yaml_vcu, expected_counters_yaml_vdu, pm_interval="15min"):
        self.ROBOT_LIBRARY_LISTENER = self
        self.level = 'suite'
        self.is_dryrun = '--dryrun' in sys.argv
        self.expected_counters_dict_vcu, self.measurement_type_vcu = \
            self.complete_counters_dict(expected_counters_yaml_vcu)
        self.expected_counters_dict_vdu, self.measurement_type_vdu = \
            self.complete_counters_dict(expected_counters_yaml_vdu)
        self.pm_interval = pm_interval

    def start_suite(self, data, result):
        if self.is_dryrun:
            return
        try:
            with open(
                "testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener_vran/pm_intervals_delta_vdu.json"
            ) as delta_vdu:
                delta_vdu = json.load(delta_vdu)

            for i in range(len(delta_vdu)):
                for j in range(len(delta_vdu[i]['parameters'])):
                    delta_vdu[i]['parameters'][j]['value'] = eval(delta_vdu[i]['parameters'][j]['value'],
                                                                  {"pm_interval": self.pm_interval})

            with open('generated_delta_vdu_{}.json'.format(self.pm_interval), 'w') as f:
                json.dump(delta_vdu, f, indent=2)

            with open(
                "testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener_vran/pm_intervals_delta_vcu.json"
            ) as delta_vcu:
                delta_vcu = json.load(delta_vcu)

            for i in range(len(delta_vcu)):
                for j in range(len(delta_vcu[i]['parameters'])):
                    delta_vcu[i]['parameters'][j]['value'] = eval(delta_vcu[i]['parameters'][j]['value'],
                                                                  {"pm_interval": self.pm_interval})

            with open('generated_delta_vcu_{}.json'.format(self.pm_interval), 'w') as f:
                json.dump(delta_vcu, f, indent=2)

            BuiltIn().run_keyword('Upload delta vcu', 'generated_delta_vcu_{}.json'.format(self.pm_interval))
            BuiltIn().run_keyword('Upload delta vdu', 'generated_delta_vdu_{}.json'.format(self.pm_interval))
            VRanPmCountersExtension().wait_for_new_vran_pm_filenames(
                vDU=self.measurement_type_vdu, vCU=self.measurement_type_vcu, timeout=3600)

        except (ValueError, Exception) as e:
            logger.error(e)
            STOP_SIGNAL_MONITOR(signal.SIGINT, None)

    def end_test(self, data, result):
        if self.is_dryrun or result.status == "FAIL":
            return

        try:
            _time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
            output_path = "PM_LISTENER_CLOUD/{}".format(_time)
            OperatingSystem().create_directory(output_path)
            OperatingSystem().create_directory("{}/{}".format(output_path, "vcu"))
            OperatingSystem().create_directory("{}/{}".format(output_path, "vdu"))
            pm_files_dict = VRanPmCountersExtension().get_next_vran_unpacked_full_pm_counters_files(
                vDU=self.measurement_type_vdu, vCU=self.measurement_type_vcu,
                timeout=3600, output_dirpath=output_path
            )

        except (ValueError, AssertionError, Exception) as e:
            result.status = "FAIL"
            logger.error(e)
            STOP_SIGNAL_MONITOR(signal.SIGINT, None)

        logger.console("Waiting for saving files...")
        time.sleep(120)
        logger.console("Collected files: {}".format(pm_files_dict))

        for local_moid in self.expected_counters_dict_vcu:
            try:
                logger.console("\n\nDN:{} counters result:".format(local_moid))
                for measurement_type in self.expected_counters_dict_vcu[local_moid]:
                    counters_expectations_list_vcu = []
                    for counter_id in self.expected_counters_dict_vcu[local_moid][measurement_type]:
                        counters_expectations_list_vcu.append(counter_id)
                        counters_expectations_list_vcu.append(
                            str(self.expected_counters_dict_vcu[local_moid][measurement_type][counter_id]['value']))
                        counters_expectations_list_vcu.append(
                            self.expected_counters_dict_vcu[local_moid][measurement_type][counter_id]['name'])
                    VRanPmCountersExtension().verify_vran_last_counters_in_files(
                        *counters_expectations_list_vcu,
                        local_moid=local_moid,
                        measurement_type=measurement_type,
                        files_list=pm_files_dict['vcu'])

            except (ValueError, AssertionError, Exception) as e:
                result.status = "FAIL"
                logger.error(e)
                logger.error("For additional information, check the log.txt file in the test logs folder")
                continue

        for local_moid in self.expected_counters_dict_vdu:
            try:
                logger.console("\n\nDN:{} counters result:".format(local_moid))
                for measurement_type in self.expected_counters_dict_vdu[local_moid]:
                    counters_expectations_list_vdu = []
                    for counter_id in self.expected_counters_dict_vdu[local_moid][measurement_type]:
                        counters_expectations_list_vdu.append(counter_id)
                        counters_expectations_list_vdu.append(
                            str(self.expected_counters_dict_vdu[local_moid][measurement_type][counter_id]['value']))
                        counters_expectations_list_vdu.append(
                            self.expected_counters_dict_vdu[local_moid][measurement_type][counter_id]['name'])
                    VRanPmCountersExtension().verify_vran_last_counters_in_files(
                        *counters_expectations_list_vdu,
                        local_moid=local_moid,
                        measurement_type=measurement_type,
                        files_list=pm_files_dict['vdu'])

            except (ValueError, AssertionError, Exception) as e:
                result.status = "FAIL"
                logger.error(e)
                logger.error("For additional information, check the log.txt file in the test logs folder")
                continue

    @staticmethod
    def complete_counters_dict(expected_counters_yaml):
        try:
            with open(expected_counters_yaml, 'r') as stream:
                data_loaded = yaml.safe_load(stream)

                pm_counters_dict = data_loaded['pm_counters']
                measurement_type_list = []
                for local_moid in pm_counters_dict:
                    for measurement_type in pm_counters_dict[local_moid]:
                        measurement_type_list.append(measurement_type)
                        for counter_id in pm_counters_dict[local_moid][measurement_type]:
                            if not isinstance(pm_counters_dict[local_moid][measurement_type][counter_id]['value'], int):
                                pm_counters_dict[local_moid][measurement_type][counter_id]['value'] = eval(
                                    pm_counters_dict[local_moid][measurement_type][counter_id]['value'],
                                    data_loaded['test_parameters']
                                )
        except (IOError, Exception) as e:
            logger.error(e)
            STOP_SIGNAL_MONITOR(signal.SIGINT, None)

        return pm_counters_dict, measurement_type_list
