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
from common_lib import common_lib
from robot.libraries.BuiltIn import BuiltIn

comm_obj = common_lib()
builtin_obj = BuiltIn()

# 1. CIT/CRT auto triggering by UTE CLOUD       no report    mode 1
# 2. singlerun + cases in CIT/CRT dir           report       mode 2
# 3. singlerun + cases in NewFeature dir        no report    mode 3
# 4. manual open switch + cases in any dir      report       mode 4
# 5. manual close switch + cases in any dir     no report    mode 5


class SuiteTeardownReport(object):
    def __init__(self):
        pass

    def initial_and_judge_mode(self, source):
        self.source_output = source
        with open(self.source_output, "r") as f1:
            self.source_content_lines = f1.readlines()
            self.reverse_scl = self.source_content_lines[::-1]
            f1.close()
        for i in self.source_content_lines:
            if sys.version_info.major == 2:
                ret = re.search('<suite source="(.+?)".+>', i)
            else:
                ret = re.search('<suite.*source="(.+?)".*>', i)
            if ret:
                self.suite_path = ret.group(1)
                break
        with open(self.source_output, "r") as f2:
            self.source_content = f2.read()
            f2.close()
        ret = re.search(r"export CM_QUEUE\s*=\s*'?([^;']+)'?;", self.source_content, re.S)
        if ret:
            if ret.group(1) == "Single Run":
                self.run_mode = "singlerun"
            else:
                self.run_mode = ret.group(1)
        else:
            self.run_mode = "manual"

    def singlerun_mode_handle(self):
        if "new_feature" in [i.lower() for i in self.suite_path.split("/")]:
            builtin_obj.log('The suite belong to "New Feature",Not allowed to report to REP.', console=False)
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
                                    r'Configuration Parameters" library="\S*" .*>\n*', line)
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

                ret = builtin_obj.convert_to_boolean(builtin_obj.get_variable_value('${ONLY_REPORT_REP}'))
                if ret:
                    builtin_obj.log("Singlerun on CLOUD, ${ONLY_REPORT_REP}=True, "
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

            self.execute_id = re.search(r"export CM_EXECUTION_ID=(.*?);", info).group(1)

            self.reservation_id = re.search(r"export CM_RESERVATION_ID=(.*?);", info).group(1)
            self.execution_link = "http://logs.ute.nsn-rdnet.net/cloud/execution/%s" % self.execute_id
            self.log_link = \
                "http://logs.ute.nsn-rdnet.net/cloud/execution/%s/execution_for_preparation_%s" \
                "/test_results/log.html" % (self.execute_id, self.reservation_id)

            self.sw_version = re.search(r"\$\{GNB_SW_VERSION\} = (.+)</msg>", info).group(1)

            self.tl = re.search(r"TestLineHostName=(\S+)</msg>", info).group(1).replace(
                "-", "_")
            # delete TL name end str "-1"
            if self.tl.endswith("_1"):
                self.tl = self.tl.split("_1")[0]
                builtin_obj.log("tl name = %s" % self.tl, console=False)

            self.username = re.search(r"export CM_USERNAME=(.*?);", info).group(1)
            self.label = re.search(r"export CM_TOPOLOGY_NAME=(.*?);", info).group(1)

            self.report_cmd = \
                'ute_reporting_portal send -ie -nc -ro %s -tl %s --username "%s" -v --sw_version "%s" \
                -l %s --log_link %s --execution_link %s' % (
                    self.suiteteardown_report_output,
                    self.tl,
                    self.username,
                    self.sw_version,
                    self.label,
                    self.log_link,
                    self.execution_link
                )

            builtin_obj.log("Execute auto report command is:  %s" % self.report_cmd, console=False)
            out = comm_obj.execute_cmd_on_pc(self.report_cmd)

            time.sleep(3)
            if os.path.exists(self.incomplete_output):
                os.remove(self.incomplete_output)

            if os.path.exists(self.suiteteardown_report_output):
                shutil.move(self.suiteteardown_report_output, self.suite_log_dir)

            if os.path.exists("/home/ute/reporting_portal_report"):
                tmp = os.listdir("/home/ute/reporting_portal_report")
                for i in tmp:
                    i = "/home/ute/reporting_portal_report/%s" % i
                    if os.path.isdir(i):
                        shutil.rmtree(i)
                    else:
                        os.remove(i)

    def manual_mode_handle(self):
        if self.manual_switch:
            builtin_obj.log('ManualRun on reserved CLOUD testline,${MANUAL_AUTO_REPORT}=True', console=True)

            self.incomplete_output = os.path.join(os.path.dirname(self.source_output), "incomplete_output.xml")
            self.suiteteardown_report_output = os.path.join(os.path.dirname(self.source_output),
                                                            "suiteteardown_report_output.xml")

            with open(self.incomplete_output, "w") as f2:
                f2.writelines(self.source_content_lines)
                f2.close()

            with open(self.suiteteardown_report_output, "w") as f3:
                for line in self.reverse_scl:
                    ret1 = re.match(r'<kw type="teardown" .*>\n*', line)
                    ret2 = re.match(r'<kw \S*\s*name="Common Suite Teardown And Restore BTS '
                                    r'Configuration Parameters" library="\S*" .*>\n*', line)
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

                ret = builtin_obj.convert_to_boolean(builtin_obj.get_variable_value('${ONLY_REPORT_REP}'))
                if ret:
                    builtin_obj.log("ManualRun on reserved CLOUD testline, ${ONLY_REPORT_REP}=True, "
                                    "only report REP, don't insert QC", console=True)
                    tmp_list = []
                    for line in self.save_content_lines:
                        if not re.match(r"<tag>((QC_\d+)|(QCD_([A-Z_])+)|(QCP_([A-Z_])+))</tag>", line):
                            tmp_list.append(line)
                    self.save_content_lines = tmp_list

                new_content_lines = self.save_content_lines + self.add_content_lines
                f3.writelines(new_content_lines)
                f3.close()

            with open(self.suiteteardown_report_output, "r") as f:
                info = f.read()
                f.close()

            self.suite_log_dir = re.search(r"\$\{SUITE_LOG_DIRECTORY\} = (\S+)</msg>", info).group(1)
            if self.suite_log_dir.endswith("/"):
                self.suite_log_dir = self.suite_log_dir[:-1]

            self.tl = re.search(r"TestLineHostName=(\S+)</msg>", info).group(1).replace("-", "_")
            # delete TL name end str "-1"
            if self.tl.endswith("_1"):
                self.tl = self.tl.split("_1")[0]
                builtin_obj.log("tl name = %s" % self.tl, console=False)
            self.sw_version = re.search(r"\$\{GNB_SW_VERSION\} = (.+)</msg>", info).group(1)  # "5G_0.800.3629"
            ret = re.search(r"<tag>(CLOUD_\S+)</tag>", info)
            if ret:
                self.label = ret.group(1)
            else:
                self.label = None

            self.report_cmd = 'ute_reporting_portal send -ro %s -tl %s -l %s --sw_version %s' % (
                self.suiteteardown_report_output,
                self.tl,
                self.label,
                self.sw_version
            )

            builtin_obj.log("Execute auto report command is:  %s" % self.report_cmd, console=False)
            out = comm_obj.execute_cmd_on_pc(self.report_cmd)

            time.sleep(3)
            if os.path.exists(self.incomplete_output):
                os.remove(self.incomplete_output)
            if os.path.exists(self.suiteteardown_report_output):
                shutil.move(self.suiteteardown_report_output, self.suite_log_dir)

    def suite_teardown_report_rep(self, source, manual_switch=False):
        try:
            self.initial_and_judge_mode(source)
            if self.run_mode == "singlerun":
                self.singlerun_mode_handle()
            elif self.run_mode == "manual":
                self.manual_switch = bool(manual_switch)
                self.manual_mode_handle()
            else:
                builtin_obj.log("Action! It's in Queue '%s', no need to report to REP" % self.run_mode,
                                console=False)
        except Exception as e:
            traceback.print_exc()


if __name__ == "__main__":
    obj = SuiteTeardownReport()
    obj.initial_and_judge_mode("C:\\Temp\\output.xml")
    print(obj.run_mode)
