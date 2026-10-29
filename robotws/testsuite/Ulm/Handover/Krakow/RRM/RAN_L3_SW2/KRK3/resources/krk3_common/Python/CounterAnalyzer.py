"""
:copyright: Nokia Networks
:author: Mateusz Michalik
:contact: mateusz.michalik@nokia.com
:maintainer: Mateusz Michalik
:contact: mateusz.michalik@nokia.com
"""

from robot.api import logger
from robot.running.signalhandler import STOP_SIGNAL_MONITOR
from ta5g_pm_counters import counters_checker
from robot.libraries.BuiltIn import BuiltIn
import yaml
import signal


class CounterAnalyzer:
    @staticmethod
    def fill_counters_dict(expected_counters_yaml, **kwargs):
        """
        Keyword used to prepare pm counters dictionary with objects and measurement types
        according to yaml template file
        :param expected_counters_yaml: Path to the yaml file that is used as the template
        :return: Tuple that consist of pm counters dictionary and list of measurements
        """
        try:
            with open(expected_counters_yaml, 'r') as stream:
                data_loaded = yaml.safe_load(stream)
                data_loaded['test_parameters'].update(
                    {k: int(v) for k, v in kwargs.items()})

                pm_counters_dict = data_loaded['pm_counters']
                for local_moid in pm_counters_dict:
                    for counter_id in pm_counters_dict[local_moid]:
                        if not isinstance(pm_counters_dict[local_moid][counter_id]['value'], int):
                            pm_counters_dict[local_moid][counter_id]['value'] = eval(
                                pm_counters_dict[local_moid][counter_id]['value'], data_loaded['test_parameters']
                            )
        except (IOError, Exception) as e:
            logger.error("Failed to load or process YAML file: %s", e)
            STOP_SIGNAL_MONITOR(signal.SIGINT, None)

        return pm_counters_dict

    def perform_pm_counters_verification(self, expected_counters_yaml, pm_file, **kwargs):
        """
        Keyword used to perform counters verification
        :param expected_counters_yaml: Path to the yaml file that is used as the template
        :param pm_file: Pm counters xml filepath
        :return: None
        """
        expected_counters_dict = self.fill_counters_dict(
            expected_counters_yaml, **kwargs)

        for local_moid in expected_counters_dict:
            try:
                counters_expectations_list = []
                logger.console("\n\nDN:{} counters result:".format(local_moid))
                for counter_id in expected_counters_dict[local_moid]:
                    counters_expectations_list.append(counter_id)
                    counters_expectations_list.append(
                        str(expected_counters_dict[local_moid][counter_id]['value']))
                    counters_expectations_list.append(
                        expected_counters_dict[local_moid][counter_id]['name'])

                counters_checker().verify_last_counters_in_file(
                    *counters_expectations_list,
                    local_moid=local_moid,
                    file_path=pm_file)

            except (ValueError, AssertionError, Exception) as e:
                logger.error(e)
                BuiltIn().log(e, level='FAIL')
