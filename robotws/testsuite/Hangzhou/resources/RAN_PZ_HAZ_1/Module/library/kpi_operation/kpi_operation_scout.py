"""
:copyright: Nokia
:author: gcao
:contact: ge.cao@nokia-sbell.com
:maintainer gcao:
:contact ge.cao@nokia-sbell.com
"""
from datetime import datetime, timezone, timedelta
import time
import re
try:
    import robot.api.logger as logging
except ImportError:
    import logging
import json
import os
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import vdu
from module_utils import module_utils
import shutil
from taf.sw.scout import scout


class KpiModuleFactory(object):

    def __init__(self):
        self.api_key = "de0a937a-3edd-4c6e-a5dc-9a4b8173880b"
        self.scout = scout()

    def set_api_key(self, api_key):
        self.api_key = api_key

    def finish_kpi_collection_scout(self):
        end_time = datetime.now(tz=timezone.utc)
        end_time = end_time.strftime("%Y-%m-%dT%H:%M:%S")
        return end_time

    def start_kpi_collection_scout(self, alias, scout_testline_name):
        self.scout.setup_scout(scout_testline_name=scout_testline_name, api_key=self.api_key, alias=alias)
        logging.debug(f"Alias {alias} stored: {self.scout.store.get_alias_value(alias)}")
        start_time = datetime.now(tz=timezone.utc)
        start_time = start_time.strftime("%Y-%m-%dT%H:%M:%S")
        return start_time

    def generate_comparator_report_scout(self, report_name, template_ids, first_start_time,
                                         first_end_time, second_start_time, second_end_time,
                                         alpha_factor=0.05,
                                         alias=None):
        scout_api = self.scout.store.get_alias_value(alias)
        if scout_api is None:
            raise ValueError(f"Alias {alias} is not initialized. Please check setup_scout.")
        try:
            res = scout_api.generate_comparator_report(
                report_name, template_ids, first_start_time, first_end_time,
                second_start_time, second_end_time, reference_period_description="first",
                current_period_description="second", alpha_factor=alpha_factor,
                block_until_ready=False, timeout=600)
            logging.info(res)
            report_id = res[0]["comparator_reports"][0]["id"]
            report_link = "https://scout.nsn-rdnet.net/comparator/reports/"+report_id
        finally:
            self.scout.teardown_scout_api(alias=alias)
        return report_link


class kpi_operation_scout(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        self.kpi_scout = KpiModuleFactory()

    def start_kpi_collection_scout(self, product_type,
                                   bts_index,
                                   du_index,
                                   alias,
                                   scout_testline_name,
                                   *args,
                                   **kwargs):
        alias = f"kpi_operation_{product_type}_{bts_index}_{du_index}"
        if "api_key" in kwargs and kwargs["api_key"] is not None and kwargs["api_key"] != "":
            self.kpi_scout.api_key = kwargs["api_key"]
        start_time = self.kpi_scout.start_kpi_collection_scout(alias, scout_testline_name)
        return start_time

    def finish_kpi_collection_scout(self, alias=None):
        return self.kpi_scout.finish_kpi_collection_scout()

    def generate_comparator_report_scout(self, scout_testline_name, product_type, bts_index, du_index,
                                         report_name, template_ids, first_start_time, first_end_time,
                                         second_start_time, second_end_time, alpha_factor=0.05, alias=None,
                                         *args,
                                         **kwargs):
        logging.debug(scout_testline_name)
        if "alpha_factor" in kwargs:
            alpha_factor = kwargs["alpha_factor"]
        for time_var in ['first_start_time', 'first_end_time', 'second_start_time', 'second_end_time']:
            time_val = locals()[time_var]
            if isinstance(time_val, str) and not time_val.endswith('Z'):
                locals()[time_var] = time_val.replace(' ', 'T') + 'Z'

        alias = f"kpi_operation_{product_type}_{bts_index}_{du_index}"
        return self.kpi_scout.generate_comparator_report_scout(report_name,
                                                               template_ids,
                                                               first_start_time,
                                                               first_end_time,
                                                               second_start_time,
                                                               second_end_time,
                                                               alpha_factor=alpha_factor,
                                                               alias=alias)
