# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: eric.jiang
:contact: eric.jiang@nokia-sbell.com
"""

import os
import sys
import re
import datetime
import time
import shutil
import traceback
from ..common_lib_aic import common_lib_aic
from robot.libraries.BuiltIn import BuiltIn

comm_obj_aic = common_lib_aic()
builtin_obj = BuiltIn()


class SuiteTeardownReportAic(object):
    def __init__(self):
        pass

    def initial_and_judge_mode_aic(self, source):  # source mean the output.xml
        self.source_output = source
        with open(self.source_output, "r") as f1:
            self.source_content = f1.read()
            f1.close()
        with open(self.source_output, "r") as f2:
            self.source_content_lines = f2.readlines()
            self.reverse_scl = self.source_content_lines[::-1]
            f2.close()

        for i in self.source_content_lines:
            ret = re.match(r".*\{SUITE_SOURCE\} = (.*)<.*", i)
            if ret is not None:
                self.suite_path = ret.group(1)
                break

        ret = re.search(r"export CM_QUEUE\s*=\s*'?([^;']+)'?;", self.source_content, re.S)
        if ret:
            if ret.group(1) == "Single Run":
                self.run_mode = "singlerun"
            else:
                self.run_mode = ret.group(1)
        else:
            self.run_mode = "manual"

    def singlerun_mode_handle_aic(self):
        if "new_feature" in [i.lower() for i in self.suite_path.split("/")]:
            builtin_obj.log('The suite belong to "New Feature",Not allowed to report to REP.', console=False)
            return
        else:
            self.incomplete_output = os.path.join(os.path.dirname(self.source_output), "incomplete_output.xml")
            self.suiteteardown_report_output = os.path.join(os.path.dirname(self.source_output),
                                                            "suiteteardown_report_output.xml")

            with open(self.incomplete_output, "w") as f3:
                f3.writelines(self.source_content_lines)
                f3.close()

            with open(self.suiteteardown_report_output, "w") as f4:
                for line in self.reverse_scl:
                    ret1 = re.match(r'<kw type="teardown" .*>\n*', line)
                    ret2 = re.match(r'<kw \S*\s*name="Common Suite Teardown And Restore BTS '
                                    r'Configuration Parameters Aic".*type="teardown".*>\n*', line, re.S)
                    if ret1 and not ret2:
                        self.teardown_line = ret1.group()
                        index = self.source_content_lines.index(self.teardown_line)
                        self.save_content_lines = self.source_content_lines[0:index]
                        break
                    elif ret2 and not ret1:
                        self.teardown_line = ret2.group()
                        index = self.source_content_lines.index(self.teardown_line)
                        self.save_content_lines = self.source_content_lines[0:index]
                        break

                now_time = datetime.datetime.now()
                latest_kw_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=1),
                                                                 "%Y%m%d %H:%M:%S.%f")[:-3]
                latest_kw_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=2),
                                                               "%Y%m%d %H:%M:%S.%f")[:-3]
                suite_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=3),
                                                             "%Y%m%d %H:%M:%S.%f")[:-3]
                suite_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=4),
                                                           "%Y%m%d %H:%M:%S.%f")[:-3]

                self.add_content_lines = [
                    self.teardown_line,
                    '<status status="PASS" endtime="%s" starttime="%s"></status>\n' % (
                        latest_kw_endtime, latest_kw_starttime),
                    '</kw>\n',
                    '<status status="PASS" endtime="%s" starttime="%s"></status>\n' % (suite_endtime, suite_starttime),
                    '</suite>\n',
                    '</robot>\n'
                ]

                ret = builtin_obj.convert_to_boolean(builtin_obj.get_variable_value('${ONLY_REPORT_REP_AIC}'))
                if ret:
                    builtin_obj.log("Singlerun on CLOUD, ${ONLY_REPORT_REP_AIC}=True, "
                                    "only report REP, don't insert QC", console=True)
                    tmp_list = []
                    for line in self.save_content_lines:
                        if not re.match(r"<tag>((QC_\d+)|(QCD_([A-Z_])+)|(QCP_([A-Z_])+))</tag>", line):
                            tmp_list.append(line)
                    self.save_content_lines = tmp_list

                new_content_lines = self.save_content_lines + self.add_content_lines
                f4.writelines(new_content_lines)
                f4.close()

            with open(self.suiteteardown_report_output, "r") as f5:
                info = f5.read()
                f5.close()

            # eg: /home/ute/test_results/ev_logs/[suite_name_prefix]_20210121112006/
            self.suite_log_dir = re.search(r"\$\{SUITE_LOG_DIRECTORY\} = (\S+)</msg>", info).group(1)
            if self.suite_log_dir.endswith("/"):
                self.suite_log_dir = self.suite_log_dir[:-1]

            # self.execute_id=14993969
            self.execute_id = re.search(r"export CM_EXECUTION_ID=(.*?);", info).group(1)
            # self.reservation_id=de434e6d-f363-4f28-b8d8-71894fe2c966
            self.reservation_id = re.search(r"export CM_RESERVATION_ID=(.*?);", info).group(1)
            self.execution_link = "http://logs.ute.nsn-rdnet.net/cloud/execution/%s" % self.execute_id
            self.tl = re.search(r"TestLineHostName=(\S+)</msg>", info).group(1).replace(
                "-", "_")  # "2_16_CLOUD345",need use "_" to replace "-"
            self.username = re.search(r"export CM_USERNAME=(.*?);", info).group(1)  # "erjiang"
            self.label = re.search(r"export CM_TOPOLOGY_NAME=(.*?);", info).group(1)  # "CLOUD_5G_Aic_xx"
            self.log_link = \
                "http://logs.ute.nsn-rdnet.net/cloud/execution/%s/execution_for_preparation_%s" \
                "/test_results/log.html" % (self.execute_id, self.reservation_id)

            self.cu_version = re.search(r"\$\{GNB_CU_VERSION\} = (.+)</msg>", info).group(1)  # "vCUCNF22R4_xx"
            self.du_version = re.search(r"\$\{GNB_DU_VERSION\} = (.+)</msg>", info).group(1)  # "vDUCNF22R4_xx"
            self.sw_version = "%s;%s" % (self.cu_version, self.du_version)

            self.report_cmd = \
                'ute_reporting_portal send -ie -nc -ro %s -tl %s --username "%s" -v --sw_version "%s" \
                --cu_build %s -l %s --log_link %s --execution_link %s' % (
                    self.suiteteardown_report_output,
                    self.tl,
                    self.username,
                    self.du_version,
                    self.cu_version,
                    self.label,
                    self.log_link,
                    self.execution_link
                )

            builtin_obj.log("Execute auto report command is:  %s" % self.report_cmd, console=False)
            out = comm_obj_aic.execute_cmd_on_pc(self.report_cmd)

            time.sleep(3)
            # delete /home/ute/test_results/incomplete_output.xml
            if os.path.exists(self.incomplete_output):
                os.remove(self.incomplete_output)
            # move /home/ute/test_results/suiteteardown_report_output.xml to ${SUITE_LOG_DIRECTORY} like \
            # /home/ute/test_results/ev_logs/LTE4056-A-c ET_20210121112006
            if os.path.exists(self.suiteteardown_report_output):
                shutil.move(self.suiteteardown_report_output, self.suite_log_dir)
            # delete all folds and files under /home/ute/reporting_portal_report/
            if os.path.exists("/home/ute/reporting_portal_report"):
                tmp = os.listdir("/home/ute/reporting_portal_report")
                for i in tmp:
                    i = "/home/ute/reporting_portal_report/%s" % i
                    if os.path.isdir(i):
                        shutil.rmtree(i)
                    else:
                        os.remove(i)

    # cmd format: pybot -v MANUAL_AUTO_REPORT_AIC:True LTE4056-A-c_ET.robot
    def manual_mode_handle_aic(self):
        if "new_feature" in [i.lower() for i in self.suite_path.split("/")]:
            builtin_obj.log('The suite belong to "New Feature",Not allowed to report to REP.', console=False)
            return
        else:
            if self.manual_switch:
                builtin_obj.log('ManualRun on reserved CLOUD testline,${MANUAL_AUTO_REPORT_AIC}=True', console=True)

                self.incomplete_output = os.path.join(os.path.dirname(self.source_output),
                                                      "incomplete_output.xml")
                self.suiteteardown_report_output = os.path.join(os.path.dirname(self.source_output),
                                                                "suiteteardown_report_output.xml")

                with open(self.incomplete_output, "w") as f3:
                    f3.writelines(self.source_content_lines)
                    f3.close()

                with open(self.suiteteardown_report_output, "w") as f4:
                    for line in self.reverse_scl:
                        ret1 = re.match(r'<kw type="teardown" .*>\n*', line)
                        ret2 = re.match(r'<kw \S*\s*name="Common Suite Teardown And Restore BTS '
                                        r'Configuration Parameters Aic".*type="teardown".*>\n*', line, re.S)
                        if ret1 and not ret2:
                            self.teardown_line = ret1.group()
                            index = self.source_content_lines.index(self.teardown_line)
                            self.save_content_lines = self.source_content_lines[0:index]
                            break
                        elif ret2 and not ret1:
                            self.teardown_line = ret2.group()
                            index = self.source_content_lines.index(self.teardown_line)
                            self.save_content_lines = self.source_content_lines[0:index]
                            break

                    now_time = datetime.datetime.now()
                    latest_kw_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=1),
                                                                     "%Y%m%d %H:%M:%S.%f")[:-3]
                    latest_kw_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=2),
                                                                   "%Y%m%d %H:%M:%S.%f")[:-3]
                    suite_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=3),
                                                                 "%Y%m%d %H:%M:%S.%f")[:-3]
                    suite_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=4),
                                                               "%Y%m%d %H:%M:%S.%f")[:-3]

                    self.add_content_lines = [
                        self.teardown_line,
                        '<status status="PASS" endtime="%s" starttime="%s"></status>\n' % (
                            latest_kw_endtime, latest_kw_starttime),
                        '</kw>\n',
                        '<status status="PASS" endtime="%s" starttime="%s"></status>\n' % (suite_endtime,
                                                                                           suite_starttime),
                        '</suite>\n',
                        '</robot>\n'
                    ]

                    ret = builtin_obj.convert_to_boolean(builtin_obj.get_variable_value('${ONLY_REPORT_REP_AIC}'))
                    if ret:
                        builtin_obj.log("ManualRun on reserved CLOUD testline, ${ONLY_REPORT_REP_AIC}=True, "
                                        "only report REP, don't insert QC", console=True)
                        tmp_list = []
                        for line in self.save_content_lines:
                            if not re.match(r"<tag>((QC_\d+)|(QCD_([A-Z_])+)|(QCP_([A-Z_])+))</tag>", line):
                                tmp_list.append(line)
                        self.save_content_lines = tmp_list

                    new_content_lines = self.save_content_lines + self.add_content_lines
                    f4.writelines(new_content_lines)
                    f4.close()

                with open(self.suiteteardown_report_output, "r") as f5:
                    info = f5.read()
                    f5.close()

                self.suite_log_dir = re.search(r"\$\{SUITE_LOG_DIRECTORY\} = (\S+)</msg>", info).group(1)
                if self.suite_log_dir.endswith("/"):
                    self.suite_log_dir = self.suite_log_dir[:-1]

                self.tl = re.search(r"TestLineHostName=(\S+)</msg>", info).group(1).replace("-", "_")
                ret = re.search(r"<tag>(CLOUD_\S+)</tag>", info)
                if ret:
                    self.label = ret.group(1)
                else:
                    self.label = None

                self.cu_version = re.search(r"\$\{GNB_CU_VERSION\} = (.+)</msg>", info).group(1)  # "vCUCNF22R4_xx"
                self.du_version = re.search(r"\$\{GNB_DU_VERSION\} = (.+)</msg>", info).group(1)  # "vDUCNF22R4_xx"
                self.sw_version = "%s;%s" % (self.cu_version, self.du_version)

                self.report_cmd = 'ute_reporting_portal send -ro %s -tl %s -l %s --sw_version %s --cu_build %s' % (
                    self.suiteteardown_report_output,
                    self.tl,
                    self.label,
                    self.du_version,
                    self.cu_version
                )

                builtin_obj.log("Execute auto report command is:  %s" % self.report_cmd, console=False)
                out = comm_obj_aic.execute_cmd_on_pc(self.report_cmd)

                time.sleep(3)
                if os.path.exists(self.incomplete_output):
                    os.remove(self.incomplete_output)
                if os.path.exists(self.suiteteardown_report_output):
                    shutil.move(self.suiteteardown_report_output, self.suite_log_dir)
            else:
                builtin_obj.log('Manual run suite on reserved CLOUD testline,but did not open the '
                                '"${MANUAL_AUTO_REPORT_AIC}", No need to report to REP.', console=False)

    def suite_teardown_report_rep_aic(self, source, manual_switch=False):
        try:
            self.initial_and_judge_mode_aic(source)
            if self.run_mode == "singlerun":
                self.singlerun_mode_handle_aic()
            elif self.run_mode == "manual":
                self.manual_switch = bool(manual_switch)
                self.manual_mode_handle_aic()
            else:
                builtin_obj.log("Action! It's in Queue '%s', no need to report to REP "
                                "by TA Framework" % self.run_mode, console=False)
        except Exception as e:
            traceback.print_exc()
