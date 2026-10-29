# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Mateusz Michalik
:contact: mateusz.michalik@nokia.com
:maintainer: Mateusz Michalik
:contact: mateusz.michalik@nokia.com
"""
from robot.api import logger
import sys
import yaml
from ta5g_commissioning import ta5g_commissioning
from robot.running.signalhandler import STOP_SIGNAL_MONITOR
import signal
from ta5g_pm_counters import counters_checker, PmCountersFile
import json


class listener(object):
    """

    """
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self, expected_counters_yaml, pm_interval="15min"):
        self.ROBOT_LIBRARY_LISTENER = self
        self.level = 'suite'
        self.is_dryrun = '--dryrun' in sys.argv
        self.expected_counters_dict = self.complete_counters_dict(expected_counters_yaml)
        self.pm_interval = pm_interval

    def start_suite(self, data, result):
        if self.is_dryrun:
            return

        try:
            with open(
                "testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener/pm_intervals_delta_template.json"
            ) as delta:
                delta = json.load(delta)

            for i in range(0, len(delta)):
                for j in range(0, len(delta[i]['parameters'])):
                    delta[i]['parameters'][j]['value'] = eval(delta[i]['parameters'][j]['value'],
                                                              {"pm_interval": self.pm_interval})

            with open('generated_delta_{}.json'.format(self.pm_interval), 'w') as f:
                json.dump(delta, f, indent=2)

            ta5g_commissioning().send_delta_commissioning('generated_delta_{}.json'.format(self.pm_interval))
            PmCountersFile().wait_for_next_full_pm_interval()

        except (ValueError, Exception) as e:
            logger.error(e)
            STOP_SIGNAL_MONITOR(signal.SIGINT, None)

    def end_test(self, data, result):
        if self.is_dryrun or result.status == "FAIL":
            return

        try:
            pm_file = PmCountersFile().get_next_unpacked_full_pm_counters_file()

        except (ValueError, AssertionError, Exception) as e:
            result.status = "FAIL"
            logger.error(e)
            STOP_SIGNAL_MONITOR(signal.SIGINT, None)

        for local_moid in self.expected_counters_dict:
            try:
                counters_expectations_list = []
                logger.console("\n\nDN:{} counters result:".format(local_moid))
                for counter_id in self.expected_counters_dict[local_moid]:
                    counters_expectations_list.append(counter_id)
                    counters_expectations_list.append(str(self.expected_counters_dict[local_moid][counter_id]['value']))
                    counters_expectations_list.append(self.expected_counters_dict[local_moid][counter_id]['name'])

                counters_checker().verify_last_counters_in_file(
                    *counters_expectations_list,
                    local_moid=local_moid,
                    file_path=pm_file)

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
                for local_moid in pm_counters_dict:
                    for counter_id in pm_counters_dict[local_moid]:
                        if not isinstance(pm_counters_dict[local_moid][counter_id]['value'], int):
                            pm_counters_dict[local_moid][counter_id]['value'] = eval(
                                pm_counters_dict[local_moid][counter_id]['value'], data_loaded['test_parameters']
                            )
        except (IOError, Exception) as e:
            logger.error(e)
            STOP_SIGNAL_MONITOR(signal.SIGINT, None)

        return pm_counters_dict
