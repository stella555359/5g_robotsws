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
import signal
import json
import time
from robot.libraries.OperatingSystem import OperatingSystem
from testsuite.Paris.RRM.ET.resources_KRK.krk3_common.Python.VRanPmCountersExtension \
    import VRanPmCountersExtension


class CounterAnalyzerCloud:
    @staticmethod
    def prepare_deltas_for_new_vran_pm_interval(pm_interval):
        """
        Keyword used to prepare delta commissioning .json files for vDU and vCU
        based on the templates:
        testsuite/Paris/RRM/ET/resources_KRK/krk3_common/configs/pm_intervals_delta_vdu.json
        testsuite/Paris/RRM/ET/resources_KRK/krk3_common/configs/pm_intervals_delta_vcu.json.
        :param pm_interval: Length of the interval to be set
        :return: List containing file paths to delta commissioning files
        """
        deltas = []
        try:
            with open(
                    "testsuite/Paris/RRM/ET/resources_KRK/krk3_common/configs/pm_intervals_delta_vdu.json"
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
                    "testsuite/Paris/RRM/ET/resources_KRK/krk3_common/configs/pm_intervals_delta_vcu.json"
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
    def wait_for_next_pm_interval_and_get_files_dict(dirpath):
        """
        Keyword used to wait for next pm interval for specific vdu and vcu expected interval
        :param dirpath: Path where file for each measurement should be saved
        :return: Dictionary consisting of pm counters xml filepath for both vdu and vcu
        with structure: {'vcu': 'path_to_pm_vcu.xml', 'vdu': 'path_to_pm_vdu.xml'}
        """
        try:
            _time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
            output_path = "{}/PM_LISTENER_CLOUD/{}".format(dirpath, _time)
            OperatingSystem().create_directory(output_path)
            OperatingSystem().create_directory("{}/{}".format(output_path, "vcu"))
            OperatingSystem().create_directory("{}/{}".format(output_path, "vdu"))
            pm_files_dict = VRanPmCountersExtension().get_next_vran_unpacked_full_pm_counters_files(
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
