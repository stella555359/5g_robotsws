import urllib
import json
import sys
import os
import time
import requests
import zipfile
import traceback
import logging
import traceback
from datetime import datetime
from log import *


class UploadTestRecordToFDDRP(object):
    TRUNK_STR = "_ENB_9999_"
    DOMAIN_CHANGE_LINE = "SBTS21B"

    def __init__(self, log_save_path):
        self.logger = Logger_by_time().get_logger("StabilityReport.report_result")
        self.log_save_path = log_save_path

    def delete_specail_char(self, name):
        return name.replace("/", "")

    def file_write(self, file_full_path, file_content, WriteMode="w"):
        dir_name = os.path.dirname(file_full_path)
        if not (isinstance(file_content, list) or isinstance(file_content, str)):
            self.logger.error(
                "Fail to write file: %s, file content: %s must be list or string"
                % (file_full_path, file_content)
            )
        if os.path.isfile(file_full_path):
            pass
        elif os.path.isdir(dir_name):
            pass
        else:
            self.dir_create(dir_name)
        try:
            with open(file_full_path, WriteMode) as file_object:
                file_object.writelines(file_content)
        except BaseException:
            self.logger.error("Dir File write failure")

    def dir_create(self, dir_name):
        dir_full_path = dir_name
        if os.path.isdir(dir_full_path):
            self.logger.debug("File %s has existed" % dir_full_path)
        try:
            os.makedirs(dir_full_path)
        except BaseException:
            self.logger.error("Create directory %s fail" % dir_full_path)

    def transfer_kpi_result(self, stability_kpi_result):
        kpi_result_list = stability_kpi_result.split("(")
        kpi_result = {}
        kpi_result["name"] = kpi_result_list[1].rstrip(")")
        kpi_result["category"] = "Traffic model"
        kpi_result["type"] = "String"
        kpi_result["unit"] = "%"
        kpi_result["target"] = "100"
        kpi_result["value"] = kpi_result_list[0].strip("%")
        return kpi_result

    def transfer_run_status(self, test_status):
        if test_status == "pass":
            run_result = "passed"
        else:
            run_result = "failed"
        return run_result

    def upload_result_data(
        self,
        domain,
        project,
        ca,
        case_name,
        result,
        build,
        testline_name,
        qc_id,
        parameter_1,
        scf_id=None,
    ):
        # kpi_result = self.transfer_kpi_result(counter_results)
        run_status = self.transfer_run_status(result)
        start_time = datetime.now().strftime("%Y%m%d %H:%M:%S.%f")
        end_time = datetime.now().strftime("%Y%m%d %H:%M:%S.%f")
        release = build.split("_")[0]
        project = "RAN_ST"
        domain = "MN_RAN"
        # if self.TRUNK_STR in build or release > self.DOMAIN_CHANGE_LINE:
        #     project = "RAN_ST"
        #     domain = "MN_RAN"
        # else:
        #     project = "SRAN_SBTS"
        #     domain = "MN_SRAN"
        if scf_id is None:
            upload_data = [
                {
                    "qc_domain": domain,
                    "qc_project": project,
                    "ca": ca,
                    "name": case_name,
                    "starttime": start_time,
                    "endtime": end_time,
                    "test_cases": [
                        {
                            "result": result,
                            "build": build,
                            # 'uuf_test': uuf_test,
                            "parameter_1": parameter_1,
                            # 'starttime': starttime,
                            # 'endtime': endtime,
                            "starttime": start_time,
                            "endtime": end_time,
                            "qc_id": qc_id,
                            # 'case_type': case_type,
                            # 'hw_id': hw_id,
                            # 'ru_type': ru_type,
                            # 'tdd/fdd_variant': tdd_fdd_variant,
                            # 'sa/nsa_variant': sa_nsa_variant,
                            # 'customers': customers,
                            # 'username': username,
                            # 'reset_downtime': reset_downtime,
                            "name": case_name,
                        }
                    ],
                    "testline": testline_name,
                    # 'tool': tool,
                    "result": result,
                }
            ]
        else:
            upload_data = [
                {
                    "domain": domain,
                    "project": project,
                    "ca": ca,
                    # 'ca': 'RAN_PZ_HAZ_1',
                    "sending_from": "tdd_tc",
                    # 'qc_testlab_path': qc_testlab_path,
                    # 'qc_test_set_name': qc_test_set_name,
                    "name": case_name,
                    # 'starttime': starttime,
                    # 'endtime': endtime,
                    "starttime": start_time,
                    "endtime": end_time,
                    "test_cases": [
                        {
                            "result": run_status,
                            "build": build,
                            # 'uuf_test': uuf_test,
                            "parameter_1": parameter_1,
                            "starttime": start_time,
                            "endtime": end_time,
                            "qc_id": qc_id,
                            "tc_execution_id": scf_id,
                            # 'case_type': case_type,
                            # 'hw_id': hw_id,
                            # 'ru_type': ru_type,
                            # 'tdd/fdd_variant': tdd_fdd_variant,
                            # 'sa/nsa_variant': sa_nsa_variant,
                            # 'customers': customers,
                            # 'username': username,
                            # 'reset_downtime': reset_downtime,
                            "name": case_name,
                        }
                    ],
                    "testline": testline_name,
                    # 'tool': tool,
                    "result": run_status,
                }
            ]
        PR_URL = "https://rep-portal.wroclaw.nsn-rdnet.net/testbook/upload/robot/"
        API1_STORE_PATH = self.log_save_path
        try:
            file_name = self.delete_specail_char(upload_data[0]["name"])
            report_filename = file_name + ".json"
            report_filename = os.path.join(API1_STORE_PATH, report_filename)
            self.file_write(report_filename, json.dumps(upload_data, indent=4))
        except Exception as err:
            print(err)
            self.logger.error(
                "Upload to RP failed because create json file failure: %s" % err
            )
        try:
            zip_report_filename = file_name + ".zip"
            zip_report_filename = os.path.join(API1_STORE_PATH, zip_report_filename)
            zfile = zipfile.ZipFile(zip_report_filename, "w")
            zfile.write(
                report_filename, os.path.basename(report_filename), zipfile.ZIP_DEFLATED
            )
            zfile.close()
            req = requests.post(
                PR_URL,
                files={zip_report_filename: open(zip_report_filename, "rb")},
                verify=False,
            )
            res = req.content.decode(encoding="utf-8")
            if "Error" in res:
                # print upload_data
                print(res)
                self.logger.error(
                    "upload %s failure, reason is\n%s" % (upload_data, res)
                )
                return None
            else:
                # print upload_data
                print(res)
                self.logger.info(
                    "upload %s successfully, and return is %s " % (upload_data, res)
                )
                return res
        except Exception as err:
            print(err)
            print(traceback.format_exc())
            self.logger.error("Upload to ReP failed because %s" % err)
        finally:
            try:
                os.remove(report_filename)
                os.remove(zip_report_filename)
            except Exception as err2:
                print("Delete file failed because %s " % err2)
                self.logger.error("Delete file failed because %s " % err2)


if __name__ == "__main__":
    log = Logger_by_time()
    LOG_PATH = "/home/ute"
    log.config_logging(
        logtag="StabilityReport",
        stream_loglevel="INFO",
        file_loglevel="DEBUG",
        filename=os.path.join(LOG_PATH, "stability_report_result.log"),
        filemode="w",
        when="midnight",
        interval=1,
        backupcount=24,
    )
    domain = sys.argv[1]
    project = sys.argv[2]
    ca = sys.argv[3]
    case_name = sys.argv[4]
    result = sys.argv[5]
    build = sys.argv[6]
    testline_name = sys.argv[7]
    qc_id = sys.argv[8]
    parameter_1 = sys.argv[9]
    # username = sys.argv[9]
    scf_id = None
    if len(sys.argv) > 10:
        scf_id = sys.argv[10]
    upload_results = UploadTestRecordToFDDRP(log_save_path=LOG_PATH)
    upload_results.upload_result_data(
        domain, project, ca, case_name, result, build, testline_name, qc_id, parameter_1, scf_id
    )
