import logging
import requests
import re
import json
from robot.libraries.BuiltIn import BuiltIn


__all__ = ['get_execution_env_type', 'get_running_case_qc_id', 'get_execute_case_scope']


def get_execution_env_type():
    builtin = BuiltIn()
    configuration = builtin.get_variable_value("${CONFIGURATION}", default=None)
    enb_build = builtin.get_variable_value("${ENB_BUILD}", default=None)
    upload_qc = builtin.get_variable_value("${upload_qc}", default=None)
    if configuration is not None and enb_build is not None:
        execution_env_type = "UTE_CLOUD"
    elif upload_qc is True or upload_qc == "true":
        execution_env_type = "CI"
    else:
        execution_env_type = "DEBUG"
    builtin.set_test_variable("${execution_env_type}", execution_env_type)
    return execution_env_type


def get_execute_case_scope():
    builtin = BuiltIn()
    case_name = builtin.get_variable_value("${TEST NAME}", default="")
    suite_path = builtin.get_variable_value("${SUITE SOURCE}", default="")
    if "uuf" in case_name.lower() or "uuf" in suite_path.lower():
        execute_case_scope = "UUF"
    else:
        execute_case_scope = "Regression"
    builtin.set_test_variable("${execute_case_scope}", execute_case_scope)
    return execute_case_scope


class CaseSearcher():
    def __init__(self, **param):
        self.mongo_api_url = 'http://10.182.68.169:5000/api/db/'
        self.db_name = "tribe_common_usage"
        self.headers = {'Accept': 'application/json'}

    def get_instance(self, params):
        url = self.mongo_api_url + self.db_name
        logging.info("Using filter {}".format(params))
        res = requests.get(url, headers=self.headers, params=params)
        if res.status_code == 200 and len(res.json()) > 0:
            instance_info = res.json()[0]
            qc_id = instance_info["qc_id"]
        else:
            qc_id = ""
        logging.info(f"Got QC_ID {qc_id}")
        return qc_id

    @staticmethod
    def generate_filter(release, source, case_name):
        filter = {
            'm_path': {'$regex': release},
            'source': source,
            'ta_case_name': case_name
        }
        return {'q': json.dumps(filter)}

    @staticmethod
    def generate_release_from_build(build):
        if re.findall("SBTS(.+)_ENB_999.", build) or re.findall(r"vDUCNF00_", build):
            return "Trunk"
        elif re.findall(r"SBTS(\w+)_ENB_000.", build):
            return re.findall(r"SBTS(\w+)_ENB_000.", build)[0]
        elif re.findall(r"vDUCNF(.+?)_", build):
            return re.findall(r"vDUCNF(.+?)_", build)[0]
        else:
            return ""

    def generate_case_qc_id(self):
        builtin = BuiltIn()
        source = builtin.get_variable_value("${SUITE SOURCE}", default=None)
        if source:
            source = re.findall("testsuite.Hangzhou.+", source)[0]
        case_name = builtin.get_variable_value("${TEST NAME}", default=None)
        build = builtin.get_variable_value("${AF_PATH}", default=None)
        if build:
            build = self.extract_version(build)
        else:
            build = builtin.get_variable_value("${ENB_BUILD}", default=None)
        release = self.generate_release_from_build(build)
        logging.info(f"source:{source} ta_case_name:{case_name} release:{release}")
        if source and case_name and release:
            filter = self.generate_filter(release, source, case_name)
            qc_id = self.get_instance(filter)
        else:
            qc_id = ""
        builtin.set_test_variable('${CASE_QC_ID}', qc_id)
        if qc_id and build:
            testrun_link = (
                f"https://rep-portal.ext.net.nokia.com/reports/test-runs/"
                f"?build={build}&columns=%3Ahash%3A5a42f6cbb518bbc9fa9a7c19229f283f"
                f"&limit=5&qc_test_instance_id={qc_id}"
            )
        else:
            testrun_link = ""
        builtin.set_test_variable("${CASE_TEST_RUN_LINK}", testrun_link)

    @staticmethod
    def extract_version(url):
        patterns = [
            r"SBTS\w+_ENB_\d+_\d+_\d+",
            r"\d+\.\d+\.\d+"
        ]

        for pattern in patterns:
            matches = re.findall(pattern, url)
            if matches:
                return matches[0]
        return None


def get_running_case_qc_id():
    cs = CaseSearcher()
    cs.generate_case_qc_id()
