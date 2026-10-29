from robot.libraries.BuiltIn import BuiltIn
from tools import (check_if_cloud_run, get_tl_from_vm_host, get_cm_context_variables, get_timestamp)
import json
import os
import requests
import datetime
import pytz
import sys
import logging

logging.basicConfig(level=logging.INFO)


class RfsElasticSearchContextManager(object):
    def __init__(self):
        if "--dryrun" not in sys.argv:
            self.session = requests.Session()
            self.session.trust_env = False
            self.url = "http://rfs-tools-timisoara.emea.nsn-net.net"
            self.port = 9200
            self.index = "tsr_test_reporter"
            self.api_key = "LUt2TGo1d0JtU2xVQVNRamY4Skw6cXFleERpenJfMmV6QW1JVGhha18zUQ=="

    def __enter__(self):
        if "--dryrun" not in sys.argv:
            return self

    def __exit__(self, exec_type, exec_value, traceback):
        if "--dryrun" not in sys.argv:
            self.session.close()

    def send_test_data(self, report_result):
        if "--dryrun" not in sys.argv:
            json_data = json.dumps(report_result)
            try:
                logging.debug(f"ElasticSearch POST data: {json_data}")
                req_response = self.session.post(self.url + ":" + str(self.port) + "/" + self.index + "/_doc/",
                                                 headers={"Authorization": "ApiKey {}".format(self.api_key),
                                                          "Content-Type": "application/json"},
                                                 data=json_data)
                if req_response.status_code == 201:
                    BuiltIn().log_to_console(
                        'Data successfully sent to index: {}'.format(req_response.json()['_index']))
                else:
                    BuiltIn().log_to_console('Failed to index data. Status Code: {}, Response: {}'
                                             .format(req_response.status_code, req_response.text))
            except Exception as e:
                BuiltIn().log_to_console('Failed to send data to RFS ElasticSearch. Error: {}'.format(e))

    def build_and_execute_query(self, index_name, match_fields_dict, last_match_only=False):

        query = {
            "query": {
                "bool": {
                    "must": [{"match": {key: value}} for key, value in match_fields_dict.items()]
                }
            }
        }

        if last_match_only:
            query["sort"] = [{"created_at": {"order": "desc"}}]
            query["size"] = 1

        url = f"{self.url}:{self.port}/{index_name}/_search"
        logging.debug(f"ElasticSearch URL: {url}")
        logging.debug(f"ElasticSearch POST data: {query}")

        try:
            response = requests.post(url, headers={"Authorization": "ApiKey {}".format(self.api_key),
                                                   "Content-Type": "application/json"}, data=json.dumps(query))
            logging.debug(f"ElasticSearch POST response: {response}")
            response.raise_for_status()
            return response.json().get('hits', {}).get('hits', [])
        except requests.exceptions.RequestException as e:
            print(f"Error occurred: {e}")
            return None

    def check_query_match(self, index_name, match_fields_dict):
        match_result = self.build_and_execute_query(index_name, match_fields_dict, last_match_only=True)
        if match_result is None:
            return False
        if len(match_result) == 0:
            return False
        else:
            return True

    def update_document(self, index_name, document_id, update_fields_dict):

        url = f"{self.url}:{self.port}/{index_name}/_update/{document_id}"
        body = {
            "doc": update_fields_dict
        }

        logging.debug(f"ElasticSearch URL: {url}")
        logging.debug(f"ElasticSearch POST Data: {body}")

        try:
            response = requests.post(url, headers={"Authorization": "ApiKey {}".format(self.api_key),
                                                   "Content-Type": "application/json"}, data=json.dumps(body))
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error occurred: {e}")
            return None


class RfsListenerLib(object):
    if "--dryrun" not in sys.argv:
        ROBOT_LISTENER_API_VERSION = 2
        ROBOT_LIBRARY_SCOPE = 'GLOBAL'
        execution_context_path = '/opt/ute/execution.context.json'
        reservation_context_path = '/opt/ute/reservation.context.json'

    def __init__(self):
        if "--dryrun" not in sys.argv:
            self.ROBOT_LIBRARY_LISTENER = self

    def end_test(self, name, attrs):
        if "--dryrun" not in sys.argv:
            BuiltIn().log_to_console('RFS ElasticSearch test listener, end test started')
            self.report_test_result(name, attrs['status'], attrs)

    def report_test_result(self, test, verdict, attrs):
        if "--dryrun" not in sys.argv:
            check_if_cloud_run()
            test_report = {
                "hran_version": self._parse_tags_from_attrs(attrs['tags'], 'workspace'),
                "result_url": get_cm_context_variables('CM_EXECUTION_LINK',
                                                       context_file_path=self.execution_context_path),
                "tester": get_cm_context_variables('CM_USERNAME', context_file_path=self.execution_context_path),
                "qc_id": 0,  # not known yet
                "mail_reporting": False,  # irrelevant
                "ute_reporting": self._reported_to_reporting_portal('CM_TAGS'),
                "power_off_rm": False,  # not known yet
                "test_name": test if test else 'NA',
                "sw_build": os.environ.get('qc_tc_swbuild', 'NA'),
                "start_date": self._format_time(attrs['starttime']),
                "end_date": self._format_time(attrs['endtime']),
                "job_name": self._job_name_formatting(self.reservation_context_path),
                "job_id": get_cm_context_variables('CM_EXECUTION_ID', context_file_path=self.execution_context_path),
                "node_name": self._get_tl_name(attrs['tags'], 'testline'),
                "verdict": attrs['status'],
                "robot_verdict": attrs['status'],
                "comment": get_cm_context_variables('CM_TOPOLOGY_NAME', context_file_path=self.execution_context_path),
                "taf_config_format": True,
                "timestamp": get_timestamp(),
                "test_message": BuiltIn().get_variable_value('${TEST_MESSAGE}', 'NA'),
                "ute_cloud": BuiltIn().get_variable_value('${CM_RUN_ENV}', 'NA'),
                "test_resource_name": BuiltIn().get_variable_value('${TEST_RESOURCE_NAME}', 'NA'),
                "tc_variables": str(self._get_tc_variables_dict())

            }
            if ('10_18' or '10-18') in test_report['node_name']:
                with RfsElasticSearchContextManager() as request_to_send:
                    request_to_send.send_test_data(test_report)

    def _parse_tags_from_attrs(self, tag_list, pattern_tag):
        if "--dryrun" not in sys.argv:
            for tag in tag_list:
                if pattern_tag in tag:
                    element = tag.split('= ')
                    return element[1]
            return 'NA'

    def _get_tl_name(self, tag_list, pattern_tag):
        tl_name = self._parse_tags_from_attrs(tag_list, pattern_tag)
        if tl_name == 'NA':
            tl_config = BuiltIn().get_variable_value('${CONFIGURATION}', 'NA')
            if tl_config != 'NA':
                return tl_config.split('.')[-1]
            else:
                return get_tl_from_vm_host()
        return tl_name

    def _reported_to_reporting_portal(self, variable):
        if "--dryrun" not in sys.argv:
            test_reported = get_cm_context_variables(variable, self.execution_context_path)
            return False if 'CM_SKIPREPORT' in test_reported or test_reported == 'NA' else True

    def _job_name_formatting(self, execution_context_file):
        reservation_username = get_cm_context_variables('CM_USERNAME',
                                                        context_file_path=execution_context_file)
        ute_reporting = self._reported_to_reporting_portal('CM_TAGS')
        job_name_dict = {
            "app_cloud_singlerun": "Single Run",
            "app_cloud_singlerun_reported": "Reported Single Run",
            "app_cloud_rftrun": "RFT Run",
            "app_cloud_regression": "Regression"
        }
        try:
            if 'singlerun' in reservation_username:
                return job_name_dict["app_cloud_singlerun_reported"] if ute_reporting else \
                    job_name_dict["app_cloud_singlerun"]

            return job_name_dict[reservation_username]
        except KeyError:
            return 'NA'

    def _format_time(self, string_time):
        if "--dryrun" not in sys.argv:
            datetime_object = datetime.datetime.strptime(string_time, '%Y%m%d %H:%M:%S.%f').replace(
                tzinfo=pytz.timezone('Etc/GMT-2'))
            return datetime.datetime.strptime(str(datetime_object),
                                              '%Y-%m-%d %H:%M:%S.%f%z').isoformat(timespec="seconds")

    def _get_tc_variables_dict(self):

        variables = BuiltIn().get_variables(no_decoration='Yes')
        pop_list = ['/', ':', 'None', 'null', '\n', '\\n', 'True', 'true', 'False', 'false',
                    'SPACE', 'TEMPDIR', 'LOG_FILE', 'LOG_LEVEL', 'DEBUG_FILE',
                    'OUTPUT_FILE', 'OUTPUT_DIR', 'REPORT_FILE', 'OPTIONS',
                    'SUITE_METADATA', 'SUITE_DOCUMENTATION', 'SUITE_NAME',
                    'TEST_DOCUMENTATION', 'TEST_MESSAGE', 'TEST_NAME', 'TEST_STATUS',
                    'PREV_TEST_NAME', 'PREV_TEST_STATUS', 'PREV_TEST_MESSAGE',
                    'KEYWORD MESSAGE', 'KEYWORD_STATUS', 'TEST_TAGS']

        accepted_types = (str, int, float, bool, list, dict, float, tuple, set, bytes)

        for key in variables:
            if key in pop_list:
                variables.pop(key)

        self._convert_obj_dict_values(variables, accepted_types=accepted_types)

        return dict(variables)

    def _convert_obj_dict_values(self, d, parent_key='', accepted_types=()):
        for key, value in d.items():
            full_key = f"{parent_key}.{key}" if parent_key else key
            if isinstance(value, dict):
                self._convert_obj_dict_values(value, full_key, accepted_types=accepted_types)
            else:
                if (not isinstance(value, accepted_types)) and (value is not None):
                    d[key] = str(type(value))
