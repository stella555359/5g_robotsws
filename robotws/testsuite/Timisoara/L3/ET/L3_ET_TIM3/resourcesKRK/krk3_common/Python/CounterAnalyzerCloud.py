"""
:copyright: Nokia Networks
:author: Bartosz Szlezak
:contact: bartosz.szlezak@nokia.com
:maintainer: Bartosz Szlezak
:contact: bartosz.szlezak@nokia.com
"""

from robot.api import logger
from robot.running.signalhandler import STOP_SIGNAL_MONITOR
from robot.libraries.BuiltIn import BuiltIn
import yaml
import signal
import json
import time
from robot.libraries.OperatingSystem import OperatingSystem
from testsuite.Timisoara.L3.ET.L3_ET_TIM3.resourcesKRK.krk3_common.Python.VRanPmCountersExtension \
    import VRanPmCountersExtension


class CounterAnalyzerCloud:
    @staticmethod
    def prepare_deltas_for_new_vran_pm_interval(pm_interval):
        """
        Keyword used to prepare delta commissioning .json files for vDU and vCU
        based on the templates:
        testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/krk3_common/configs/pm_intervals_delta_vdu.json
        testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/krk3_common/configs/pm_intervals_delta_vcu.json.
        :param pm_interval: Length of the interval to be set i.e. "15min"
        :return: List containing file paths to delta commissioning files
        """
        deltas = []
        try:
            with open(
                    "testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/krk3_common/configs/pm_intervals_delta_vdu.json"
            ) as delta_vdu:
                delta_vdu = json.load(delta_vdu)

            for i in range(len(delta_vdu)):
                for j in range(len(delta_vdu[i]['parameters'])):
                    delta_vdu[i]['parameters'][j]['value'] = eval(delta_vdu[i]['parameters'][j]['value'],
                                                                  {"pm_interval": pm_interval})

            with open('generated_delta_vdu_{}.json'.format(pm_interval), 'w') as f:
                json.dump(delta_vdu, f, indent=2)
                deltas.append(f.name)

            with open(
                    "testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/krk3_common/configs/pm_intervals_delta_vcu.json"
            ) as delta_vcu:
                delta_vcu = json.load(delta_vcu)

            for i in range(len(delta_vcu)):
                for j in range(len(delta_vcu[i]['parameters'])):
                    delta_vcu[i]['parameters'][j]['value'] = eval(delta_vcu[i]['parameters'][j]['value'],
                                                                  {"pm_interval": pm_interval})

            with open('generated_delta_vcu_{}.json'.format(pm_interval), 'w') as f:
                json.dump(delta_vcu, f, indent=2)
                deltas.append(f.name)

            return deltas

        except (ValueError, Exception) as e:
            logger.error(e)
            STOP_SIGNAL_MONITOR(signal.SIGINT, None)
            BuiltIn().fail(e)

    @staticmethod
    def fill_counters_dict_and_measurement_type_list(expected_counters_yaml):
        """
        Keyword used to prepare pm counters dictionary with objects and measurement types
        according to yaml template file
        :param expected_counters_yaml: Path to the yaml file that is used as the template
        :return: Tuple that consist of pm counters dictionary and list of measurements
        """
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
            measurement_type_list = list(set(measurement_type_list))

        except (IOError, Exception) as e:
            logger.error(e)
            STOP_SIGNAL_MONITOR(signal.SIGINT, None)
            BuiltIn().fail(e)

        return pm_counters_dict, measurement_type_list

    @staticmethod
    def wait_for_next_pm_interval_and_get_files_dict(measurements_vdu, measurements_vcu, dirpath):
        """
        Keyword used to wait for next pm interval for specific vdu and vcu measurement types
        and to get dictionary with those measurement types
        :param measurements_vdu: List of vdu measurement types
        :param measurements_vcu: List of vcu measurement types
        :param dirpath: Path where file for each measurement should be saved
        :return: Dictionary consisting of lists of files for each measurement type for both vdu and vcu
        with structure: {'vdu': [], 'vcu': []}
        """
        try:
            _time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
            output_path = "{}/PM_LISTENER_CLOUD/{}".format(dirpath, _time)
            OperatingSystem().create_directory(output_path)
            OperatingSystem().create_directory("{}/{}".format(output_path, "vcu"))
            OperatingSystem().create_directory("{}/{}".format(output_path, "vdu"))
            pm_files_dict = VRanPmCountersExtension().get_next_vran_unpacked_full_pm_counters_files(
                vDU=measurements_vdu, vCU=measurements_vcu,
                timeout=3600, output_dirpath=output_path
            )

        except (ValueError, AssertionError, Exception) as e:
            logger.error(e)
            STOP_SIGNAL_MONITOR(signal.SIGINT, None)
            BuiltIn().fail(e)

        logger.console("Waiting for saving files...")
        time.sleep(120)
        logger.console("Collected files: {}".format(pm_files_dict))

        return pm_files_dict

    @staticmethod
    def perform_pm_counters_verification(counters_dict_vdu, counters_dict_vcu, pm_files_dict):
        """
        Keyword used to perform counters verification
        :param counters_dict_vdu: Dictionary for vdu counters consisting of moid-id, i.e. the path to the counter
        e.g. PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1, measurementType e.g. NF1CD
        and with proper counter name e.g. M55117C00543
        :param counters_dict_vcu: Dictionary for vcu counters consisting of moid-id, i.e. the path to the counter
        e.g. PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1, measurementType e.g. NX2CC
        and with proper counter name e.g. M55112C00502
        :param pm_files_dict: Dictionary consisting of lists of files for each measurement type for both vdu and vcu
        with structure: {'vdu': [], 'vcu': []}
        :return: None
        """
        for local_moid in counters_dict_vcu:
            try:
                logger.console("\n\nDN:{} counters result:".format(local_moid))
                for measurement_type in counters_dict_vcu[local_moid]:
                    counters_expectations_list_vcu = []
                    for counter_id in counters_dict_vcu[local_moid][measurement_type]:
                        counters_expectations_list_vcu.append(counter_id)
                        counters_expectations_list_vcu.append(
                            str(counters_dict_vcu[local_moid][measurement_type][counter_id]['value']))
                        counters_expectations_list_vcu.append(
                            counters_dict_vcu[local_moid][measurement_type][counter_id]['name'])
                    VRanPmCountersExtension().verify_vran_last_counters_in_files(
                        *counters_expectations_list_vcu,
                        local_moid=local_moid,
                        measurement_type=measurement_type,
                        files_list=pm_files_dict['vcu'])

            except (ValueError, AssertionError, Exception) as e:
                logger.error(e)
                BuiltIn().log(e, level='FAIL')

        for local_moid in counters_dict_vdu:
            try:
                logger.console("\n\nDN:{} counters result:".format(local_moid))
                for measurement_type in counters_dict_vdu[local_moid]:
                    counters_expectations_list_vdu = []
                    for counter_id in counters_dict_vdu[local_moid][measurement_type]:
                        counters_expectations_list_vdu.append(counter_id)
                        counters_expectations_list_vdu.append(
                            str(counters_dict_vdu[local_moid][measurement_type][counter_id]['value']))
                        counters_expectations_list_vdu.append(
                            counters_dict_vdu[local_moid][measurement_type][counter_id]['name'])
                    VRanPmCountersExtension().verify_vran_last_counters_in_files(
                        *counters_expectations_list_vdu,
                        local_moid=local_moid,
                        measurement_type=measurement_type,
                        files_list=pm_files_dict['vdu'])

            except (ValueError, AssertionError, Exception) as e:
                logger.error(e)
                BuiltIn().log(e, level='FAIL')
