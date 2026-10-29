import json
import sys
import os
import requests
import zipfile
import traceback
import logging

from datetime import datetime
import re


class UploadTestRecordToFDDRP(object):
    TRUNK_STR = "_ENB_999"
    DOMAIN_CHANGE_LINE = "SBTS21B"

    def __init__(self, log_save_path):
        self.logger = logging.getLogger('StabilityReport.report_result')
        self.log_save_path = log_save_path

    def delete_specail_char(self, name):
        return name.replace("/", "")

    def file_write(self, file_full_path, file_content, WriteMode='w'):
        dir_name = os.path.dirname(file_full_path)
        if not (
                isinstance(
                    file_content,
                    list) or isinstance(
                    file_content,
                    str)):
            self.logger.error(
                "Fail to write file: %s, file content: %s must be list or string" %
                (file_full_path, file_content))
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
        kpi_result_list = stability_kpi_result.split('(')
        kpi_result = {'name': kpi_result_list[1].rstrip(')'), 'category': 'Traffic model', 'type': 'String',
                      'unit': '%', 'target': "100", 'value': kpi_result_list[0].strip('%')}
        return kpi_result

    def transfer_run_status(self, test_status):
        if test_status == 'pass':
            run_result = 'passed'
        else:
            run_result = 'failed'
        return run_result

    def get_qc_info_from_qc_file(self,
                                 qc_file_path,
                                 build,
                                 case_name):
        qc_ret_info = {"qc_testlab_path": "",
                       "qc_test_set_name": "",
                       "qc_test_instance_name": ""}
        if os.path.exists(qc_file_path):
            print("qc_file_path already exists {}".format(qc_file_path))
            qc_objects = json.load(open(qc_file_path, mode='r'))
            for release_re, qc_info in qc_objects.items():
                release = re.match(release_re, build)
                if release is not None:
                    print(release)
                    for key, caseinfo in qc_info.items():
                        if "Root\\Test_Sets" in key:
                            for feature_name, case_list in caseinfo.items():
                                for case_name_in_file in case_list:
                                    reportd_case = re.match(case_name_in_file,
                                                            case_name)
                                    if reportd_case is not None:
                                        qc_ret_info["qc_testlab_path"] = key
                                        qc_ret_info["qc_test_set_name"] = feature_name
                                        qc_ret_info["qc_test_instance_name"] = case_name
                                        break
        else:
            raise Exception("Please input the right qc_file_path")
        print(json.dumps(qc_ret_info))
        return qc_ret_info

    def feed_test_cases(self,
                        result,
                        build,
                        starttime,
                        endtime,
                        qc_id,
                        name):

        test_cases = {
            'result': result,
            'build': build,
            'starttime': starttime,
            'endtime': endtime,
            'name': name}
        if qc_id.isdigit():
            test_cases["qc_id"] = qc_id
        else:
            qc_info = self.get_qc_info_from_qc_file(qc_id, build, name)
            test_cases.update(qc_info)
        return test_cases

    def upload_result_data(
            self,
            case_name,
            result,
            build,
            qc_id,
            counter_results,
            scf_id=None,
            testline=None,
            kpi_params=None,
            comment="",
            project="RAN_VRF"):
        kpi_result = self.transfer_kpi_result(counter_results)
        run_status = self.transfer_run_status(result)
        start_time = datetime.now().strftime('%Y%m%d %H:%M:%S.%f')
        end_time = datetime.now().strftime('%Y%m%d %H:%M:%S.%f')
        release = build.split("_")[0]
        domain = "MN_RAN"
        test_cases = self.feed_test_cases(run_status,
                                          build,
                                          start_time,
                                          end_time,
                                          qc_id,
                                          case_name)
        upload_data = [{'name': case_name,
                        'starttime': start_time,
                        'project': project,
                        'sending_from': 'tdd_tc',
                        'domain': domain,
                        'ca': 'RAN_PZ_HAZ_1',
                        'endtime': end_time,
                        'test_cases': [test_cases],
                        'testline': 'GVE_HZ_TL00' if testline is None else testline,
                        'result': run_status}]
        print("scf_id {}".format(scf_id))
        if scf_id is not None:
            upload_data[0]["test_cases"][0]["tc_execution_id"] = scf_id
        if comment:
            upload_data[0]["test_cases"][0]["comment"] = comment
        if kpi_params is not None and kpi_params != 'None':
            params = json.loads(kpi_params)
            if "uuf_test" in params.keys():
                upload_data[0]["test_cases"][0]["uuf_test"] = True
                if params["uuf_test"]["reset_downtime"]:
                    upload_data[0]["test_cases"][0]["reset_downtime"] = params["uuf_test"]["reset_downtime"]
        print(upload_data)

        PR_URL = "https://rep-portal.wroclaw.nsn-rdnet.net/testbook/upload/robot/"
        API1_STORE_PATH = self.log_save_path
        try:
            file_name = self.delete_specail_char(upload_data[0]["name"])
            report_filename = file_name + '.json'
            report_filename = os.path.join(API1_STORE_PATH, report_filename)
            self.file_write(report_filename, json.dumps(upload_data, indent=4))
        except Exception as err:
            print(err)
            self.logger.error(
                'Upload to RP failed because create json file failure: %s' %
                err)
        try:
            zip_report_filename = file_name + '.zip'
            zip_report_filename = os.path.join(
                API1_STORE_PATH, zip_report_filename)
            zfile = zipfile.ZipFile(zip_report_filename, "w")
            zfile.write(
                report_filename,
                os.path.basename(report_filename),
                zipfile.ZIP_DEFLATED)
            zfile.close()
            req = requests.post(
                PR_URL,
                files={
                    zip_report_filename: open(
                        zip_report_filename,
                        "rb")},
                verify=False)
            res = req.content.decode(encoding="utf-8")
            if 'Error' in res:
                # print upload_data
                print(res)
                self.logger.error(
                    'upload %s failure, reason is\n%s' %
                    (upload_data, res))
                return None
            else:
                # print upload_data
                self.logger.info(
                    "upload %s successfully, and return is %s \n" % (upload_data, res))
                print(
                    "link: https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-runs/?file_hash=%s" % (res))
                return res
        except Exception as err:
            print(err)
            print(traceback.format_exc())
            self.logger.error('Upload to ReP failed because %s' % err)
        finally:
            try:
                os.remove(report_filename)
                os.remove(zip_report_filename)
            except Exception as err2:
                print('Delete file failed because %s ' % err2)
                self.logger.error('Delete file failed because %s ' % err2)


if __name__ == "__main__":
    # log = Logger_by_time()
    LOG_PATH = "/home/ute"
    # log.config_logging(
    #     logtag="StabilityReport",
    #     stream_loglevel="INFO",
    #     file_loglevel="DEBUG",
    #     filename=os.path.join(
    #         LOG_PATH,
    #         'stability_report_result.log'),
    #     filemode="w",
    #     when="midnight",
    #     interval=1,
    #     backupcount=24)
    print("input argv is:")
    print(sys.argv)
    case_name = sys.argv[1]
    result = sys.argv[2]
    build = sys.argv[3]
    qc_id = sys.argv[4]
    counter_results = sys.argv[5]
    scf_id = None
    params = None
    testline = None
    comment = ""
    qc_pro = ""
    if len(sys.argv) > 6:
        scf_id = sys.argv[6]
        if len(sys.argv) > 7:
            log_path = sys.argv[7]
        if len(sys.argv) > 8:
            params = sys.argv[8]
        if len(sys.argv) > 9:
            testline = sys.argv[9]
        if len(sys.argv) > 10:
            comment = sys.argv[10]
        if len(sys.argv) > 11:
            qc_pro = sys.argv[11]
    upload_results = UploadTestRecordToFDDRP(log_save_path=(LOG_PATH if log_path is "None" else log_path))
    upload_results.upload_result_data(
        case_name,
        result,
        build,
        qc_id,
        counter_results,
        scf_id,
        testline,
        params,
        comment,
        qc_pro)
