"""
Generic Interface to Scout tool.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
"""

import os
import time
import logging
from datetime import timedelta
from dateutil import parser as date_parser
from functools import wraps
from taf.sw.scout import scout
from testsuite.Bangalore.ORAN.resources.\
    python.Macro.Python.utilities import get_configuration


class GenericScout(object):
    def __init__(self, test_line_name=None,
                 api_key='a010cd9f185846c6ac6adb91dd70d526',
                 bts_type='GNB'):
        self.test_line_name = test_line_name
        self.api_key = api_key
        self.bts_type = bts_type

    def connect_to_scout(function):
        @wraps(function)
        def wrapper(self, *args, **kwargs):
            self._connect_to_scout()
            results = function(self, *args, **kwargs)
            return results

        return wrapper

    @connect_to_scout
    def generate_kpi_report_on_the_scout(self, report_name, kpi_template_id,
                                         start_time, end_time):
        """
        Open interface for collecting KPI results from Scout.
        Example:
        generate_kpi_report_on_the_scout('Test_kpi_report','awesome_template_id',
        '2020-12-01T12:23:24.426000',
                                         '2020-12-02T10:23:24.426000')
        :param report_name: Name for generated KPI Report.
                            Current date and time will be added as
                            suffix to avoid
                            KPI Report names duplications
        :param kpi_template_id: id of the KPI Template defined in scout eg: 102
        :param start_time: start time from which PM counters will be used,
        eg: 2020-12-01T12:23:24.426000Z
        :param end_time: end time from which PM counters will be used,
        eg: 2020-12-02T10:23:24.426000Z
        :return: KPI report as a dict
        """
        report_data = []
        try:
            kpi_report = self.scout.generate_kpi_report(
                report_name,
                kpi_template_id,
                start_time, end_time)[0]
            report_data = kpi_report['report']
            logging.info("Generated Scout report - Name: {}, ID: {}".
                         format(kpi_report['name'], kpi_report['id']))
            logging.debug("Generated report {}".format(kpi_report))
        except Exception as e:
            logging.warning("Cannot generate SCOUT report. {}".format(repr(e)))

        return report_data

    @connect_to_scout
    def wait_for_kpi_data_available_in_scoaut(self, start_time,
                                              attempt=20,
                                              interval_checking=30):
        logging.debug("Waiting for KPI from period start at {}".
                      format(start_time))
        start_time = date_parser.parse("{}Z".format(start_time))
        before_time = int(time.time())
        while attempt:
            kpi_update_time = self.scout.get_last_kpi_update_time()
            kpi_update_time = date_parser.parse(kpi_update_time)
            logging.debug("Last KPI update time from SCOUT {}".
                          format(kpi_update_time))
            if start_time <= kpi_update_time:
                logging.info("Scout KPI data are already available for {}".
                             format(start_time))
                break
            attempt -= 1

            logging.debug("Scout PM stats data are not available for {}".
                          format(start_time))
            logging.debug("Waiting {} seconds for next check".
                          format(interval_checking))
            time.sleep(interval_checking)

        logging.debug(
            "Total waiting time: {}".
            format(timedelta(seconds=int(time.time()) - before_time)))

    def _connect_to_scout(self):
        self.test_line_name = self.test_line_name or self._get_testline_name()
        self.api_key = self.api_key or self._get_scout_api_key_from_env()
        self.scout = scout()
        self.scout.setup_scout(scout_testline_name=self.test_line_name,
                               api_key=self.api_key)

    @staticmethod
    def _get_scout_api_key_from_env():
        api_key = os.environ.get('SCOUT_API_KEY', None)
        if not api_key:
            raise ValueError("Scout api_key not defined. "
                             "Please pass api_key or set SCOUT_API_KEY "
                             "as environment variable")

        return api_key

    def _get_testline_name(self):
        configuration = get_configuration()
        testline_name = configuration[1] if self.bts_type.upper() == 'GNB' \
            else "{}_ENB".format(configuration[1])
        return testline_name
