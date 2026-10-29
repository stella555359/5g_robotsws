import requests
import json
from zipfile import ZipFile
import os
import datetime as dt

# ROBOT
#   ${link_to_reporting_portal}=
#   ...  report_to_rp
#   ...  name=${NAME_TO_REPORT}
#   ...  result=${status}
#   ...  ca=RAN_PZ_WRO_3    # new
#   ...  testline=${testline}
#   ...  build=${report_candiate}
#   ...  qc_test_set_name=${test_set}
#   ...  qc_testlab_path=${qc_test_path}
#   ...  qc_test_instance_name=${NAME_TO_REPORT}
#   ...  qc_domain=QCD_MN_SRAN
#   ...  qc_project=${qc_project}
#   ...  comment=UUF_${initial_build}
#   ...  links=&{empty_dict}
#   ...  uuf_test=${uuf_test}
#   ...  parameter_1=${parameter1_value}
#   ...  label=${variables['LABEL']}
#   ...  starttime=${starttime}.000
#   ...  endtime=${endtime}.000
#   ...  ru_type=${RUS}
#   ...  sa/nsa_variant=${variables['SA_NSA']}
#   ...  tdd/fdd_variant=${variables['TL_TYPE']}
#   ...  upgrade_downtime=${DOWNTIME}
#   ...  case_type=Upgrade
#   ...  hw_id=${HW}
#   ...  customers=${CUSTOMERS_RP}
#   ...  log_path=${LOG_PATH}
#   set suite variable  ${LINK_TO_RP}  ${link_to_reporting_portal}
#   log to console with time  ${LINK_TO_RP}


# Python

# name = "reset_4G_1_16_CLOUDGTA3812_AS_VzW_4G_FDD"
# result = "passed"
# ca = "RAN_PZ_WRO_3"
# testline = "SRAN_Wroclaw_1_16_CLOUDGTA3812"
# build = "SBTS21B_ENB_0000_002120_000000"
# qc_test_set_name = ""
# qc_testlab_path = ""
# qc_test_instance_name = "reset_4G_1_16_CLOUDGTA3812_AS_VzW_4G_FDD"
# qc_domain = ""
# qc_project = ""
# comment = "UUF_SBTS21B_ENB_0000_002120_000000"
# links = {}
# uuf_test = "True"
# parameter_1 = "SBTS21B_ENB_0000_002120_000000"
# label = "CLOUD_RF_AIL_B1_4075_2a_3xUHIE"
# starttime = "20220310 13:59:26.000"
# endtime = "20220310 15:53:46.000"
# ru_type = "3UHIE"
# sa_nsa_variant = "NSA"
# tdd_fdd_variant = "FDD"
# upgrade_downtime = "None"
# reset_downtime = "None"
# case_type = "Reset"
# hw_id = "1ASIA+1ABIA+3UHIE"
# customers = 'KDDI/Softbank'
# tool = Robot
# log_path='/tmp'

# def report_to_rp(name=name, result=result, ca=ca, testline=testline, build=build,
#                  qc_test_set_name=qc_test_set_name, qc_testlab_path=qc_testlab_path,
#                  qc_test_instance_name=qc_test_instance_name,
#                  qc_domain=qc_domain, qc_project=qc_project, comment=comment, links=links, uuf_test=uuf_test,
#                  parameter_1=parameter_1,
#                  label=label, starttime=starttime, endtime=endtime, ru_type=ru_type, sa_nsa_variant=sa_nsa_variant,
#                  tdd_fdd_variant=tdd_fdd_variant, reset_downtime=reset_downtime, upgrade_downtime=upgrade_downtime,
#                  case_type=case_type, hw_id=hw_id, customers=customers, log_path=log_path):
#     return link


# json example:
# reporting_portal_20220318 10:34:08.000.json
#
# [
#     {
#         "starttime": "20220318 10:28:19.000",
#         "testline": "SRAN_Wroclaw_1_16_CLOUDGTA3812",
#         "tool": "",
#         "result": "passed",
#         "endtime": "20220318 10:34:08.000",
#         "name": "reset_4G_1_16_CLOUDGTA3812_AS_VzW_4G_FDD",
#         "doc": "",
#         "ute_version": "",
#         "label": "CLOUD_RF_AIL_B1_4075_2a_3xUHIE",
#         "env_issue": "",
#         "fail_cause": "",
#         "test_cases": [
#             {
#                 "comment": "UUF_SBTS00_ENB_9999_210928_000009",
#                 "suite_path": "",
#                 "ca": "RAN_PZ_WRO_3",
#                 "build_tag": "",
#                 "qc_test_set_name": "",
#                 "automation_options": {},
#                 "qc_testlab_path": "",
#                 "qc_domain": "",
#                 "hw_id": "1ASIA+1ABIA+3UHIE",
#                 "multi_qc": "false",
#                 "features_covered": "",
#                 "parameter_1": "SBTS00_ENB_9999_210928_000009",
#                 "username": "",
#                 "reset_downtime": "185.05328",
#                 "kpi_results": [],
#                 "teardown_exception_message": "",
#                 "setup_exception": "",
#                 "sa/nsa_variant": "",
#                 "add_info": [],
#                 "name": "reset_4G_1_16_CLOUDGTA3812_AS_VzW_4G_FDD",
#                 "qc_project": "",
#                 "steps": [],
#                 "starttime": "20220318 10:28:19.000",
#                 "teardown_exception": "",
#                 "counter_results": [],
#                 "links": {},
#                 "airphone": "",
#                 "customers": "",
#                 "fail_message": "",
#                 "result": "passed",
#                 "setup_exception_message": "",
#                 "tdd/fdd_variant": "FDD",
#                 "ru_type": "3UHIE",
#                 "test_exception_message": "",
#                 "build": "SBTS00_ENB_9999_210928_000009",
#                 "parameters2": "",
#                 "source_control_revision": "",
#                 "test_exception": "",
#                 "qc_test_instance_name": "",
#                 "uuf_test": "True",
#                 "phase": "",
#                 "endtime": "20220318 10:34:08.000",
#                 "rfsw_build": "",
#                 "iphy": "",
#                 "doc": "",
#                 "qc_id": "",
#                 "case_type": "Reset"
#             }
#         ],
#         "ca": "RAN_PZ_WRO_3",
#         "rtg_build": ""
#     }
# ]
#


json_name = 'reporting_portal.json'
zipfile_name = 'robot_report.zip'


def uuf_report_to_rp(**params):
    json_filename = create_json_report_file(params)
    link = zip_report_and_send(params['log_path'], json_filename)
    return link


def zip_report_and_send(report_path, file_to_zip):
    zipf = ZipFile(os.path.join(report_path, zipfile_name), compression=8, mode='w')
    zipf.write(os.path.join(report_path, file_to_zip), file_to_zip)
    zipf.close()

    with open(os.path.join(report_path, zipfile_name), 'rb') as zipfile:
        url = 'https://rep-portal.wroclaw.nsn-rdnet.net/testbook/upload/robot/'
        response = requests.post(url, files={'file': ('reporting_portal_report.zip', zipfile)}, verify=False)
    return print_hash_link(response.text)


def print_hash_link(nr):
    link = "https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-runs/?file_hash={}".format(nr)
    print("File Hash: {}".format(nr))
    return link


def create_json_report_file(params):
    def check_value(input):
        return params[input] if input in params.keys() else ""

    json_data = [
        {
            "name": check_value('name'),
            "testline": check_value('testline'),
            "doc": check_value('doc'),
            "ca": check_value('ca'),
            "ute_version": check_value('ute_version'),
            "label": check_value('label'),
            "env_issue": check_value('env_issue'),
            "result": check_value('result'),
            "fail_cause": check_value('fail_cause'),
            "starttime": check_value('starttime'),
            "endtime": check_value('endtime'),
            "test_cases": [
                {
                    "comment": check_value('comment'),
                    "suite_path": check_value('suite_path'),
                    "links": check_value('links'),
                    "airphone": check_value('airphones'),
                    "ca": check_value('ca'),
                    "build_tag": check_value('build_tag'),
                    "phase": check_value('phase'),
                    "fail_message": check_value('fail_message'),
                    "result": check_value('result'),
                    "automation_options": {},
                    "qc_testlab_path": check_value('qc_testlab_path'),
                    "qc_domain": check_value('qc_domain'),
                    "hw_id": check_value('hw_id'),
                    "setup_exception_message": "",
                    "tdd/fdd_variant": check_value('tdd/fdd_variant'),
                    "ru_type": check_value('ru_type'),
                    "test_exception_message": "",
                    "multi_qc": "false",
                    "features_covered": "",
                    "build": check_value('build'),
                    "steps": [],
                    "parameter_1": check_value('parameter_1'),
                    "parameters2": "",
                    "username": "",
                    "{}_downtime".format(check_value('case_type').lower()): "{}".format(
                        check_value('reset_downtime') or check_value('upgrade_downtime')),
                    "kpi_results": [],
                    "teardown_exception_message": "",
                    "test_exception": "",
                    "setup_exception": "",
                    "sa/nsa_variant": check_value('sa/nsa_variant'),
                    "qc_test_instance_name": check_value('qc_test_instance_name'),
                    "uuf_test": check_value('uuf_test'),
                    "add_info": [],
                    "qc_test_set_name": check_value('qc_test_set_name'),
                    "endtime": check_value('endtime'),
                    "rfsw_build": "",
                    "name": check_value('name'),
                    "qc_project": check_value('qc_project'),
                    "doc": "",
                    "qc_id": "",
                    "case_type": check_value('case_type'),
                    "iphy": "",
                    "source_control_revision": "",
                    "starttime": check_value('starttime'),
                    "teardown_exception": "",
                    "counter_results": [],
                    "customers": check_value('customers'),
                }
            ],
            "tool": check_value('tool'),
            "rtg_build": ""
        }
    ]

    print(json_data)
    json_name = "reporting_portal_{}.json".format(params['endtime'])
    path_src = os.path.join(params['log_path'], json_name)
    with open(path_src, "w") as json_file:
        json.dump(json_data, json_file)
    return json_name


def time_now():
    time_formated = dt.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    time_and_date = dt.datetime.now()
    return time_formated, time_and_date
