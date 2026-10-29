import sys
import os
import re
import json
import subprocess
import tempfile
from shutil import copyfile
from datetime import datetime

import unittest
from unittest.mock import patch, call
from importlib.util import spec_from_file_location, module_from_spec
from context import ExceptionNotNeedToSendByMail

from perf_portal import ArgList
from perf_portal import RC_BAD_ARGS
from perf_portal import RC_SRUNNER_FILE_NOT_FOUND
from perf_portal import RC_MAJOR_CHECK_ALARM
from perf_portal import RETURN_CODE_MESSAGE


# TEST_TYPE = "Precheck,Check,Gate,Post,Continuous,Endurance,Manual,ET"
TEST_TYPE = "Manual,ET"


class TestArgList(unittest.TestCase):
    def setUp(self):
        self.arg_list = ArgList(TEST_TYPE.split(","))

    def test_contains(self):
        self.assertTrue("Manual" in self.arg_list)
        self.assertTrue("Man" in self.arg_list)
        self.assertTrue("man" in self.arg_list)
        self.assertFalse("Manuel" in self.arg_list)
        self.assertFalse("C" in self.arg_list)

    def test_find(self):
        self.assertEqual(self.arg_list.find("Manual"), "Manual")
        self.assertEqual(self.arg_list.find("Man"), "Manual")
        self.assertEqual(self.arg_list.find("man"), "Manual")
        self.assertIsNone(self.arg_list.find("Blabla"))
        self.assertIsNone(self.arg_list.find(None))


class TestPerfServer(unittest.TestCase):
    def setUp(self):
        self.commit_info = {
            "nb": "123456789ABCDEFG",
            "date": "2019-05-03 05:17:57",
            "nb_small": "1234567",
        }
        self.env_values = {
            "ZUUL_PIPELINE": "cont",
            "JOB_BASE_NAME": "SCT.performance.abil",
            "JOB_NAME": "MASTER/GNB/UPLANE/L2-PS/SCT.performance.abil",
            "METRICS_IGNORE": "false",
        }

        self.info_message = (
            "For any support, contact I_MN_5GSC_SW_ENG_PERF_SERVER@groups.nokia.com\n"
            "Find performance portal at https://app.powerbi.com/groups/me/apps/"
            "4b451a02-844c-47b2-bd6b-e43667c7cf16"
        )

        self.header = {
            "minimal": (
                '{"header":{"snapshotData": {"5gnbSwVersion": "git-commit:'
                + self.commit_info["nb"]
                + '"}}}'
            ),
            "extend_true": (
                '{"header":{"snapshotData": {"5gnbSwVersion": "git-commit:'
                + self.commit_info["nb"]
                + '"}, "KPImode": "extended"}}'
            ),
            "extend_false": (
                '{"header":{"snapshotData": {"5gnbSwVersion": "git-commit:'
                + self.commit_info["nb"]
                + '"}, "KPImode": "nominal"}}'
            ),
        }

        result_file = (
            f"{os.path.dirname(__file__)}/"
            f"test_data/ResForTimeMarkerKPIv2_L2RT_ft123_plusExtendedPlusSync"
            f"_4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json"
        )
        with open(result_file, "r") as f_h:
            self.result_content = json.load(f_h)

        kpi_file_to_use = f"{os.path.dirname(__file__)}/{self.result_content['KpiFileToUse']}"
        base_kpi_file_name = os.path.basename(kpi_file_to_use)
        self.tempdir = tempfile.TemporaryDirectory()
        self.filename = {
            "KPI_REPLAY": f"{self.tempdir.name}/TimeMarkerKPI_replay.json",
            "KPI_FULL": f"{self.tempdir.name}/{base_kpi_file_name}",
            "PERF_PORTAL_JSON": f"{self.tempdir.name}/perf_portal.json",
        }
        copyfile(
            f"{os.path.dirname(__file__)}/test_data/perf_portal.json",
            self.filename["PERF_PORTAL_JSON"],
        )
        copyfile(kpi_file_to_use, self.filename["KPI_FULL"])

        with open(self.filename["KPI_FULL"], "r") as f_h:
            self.kpi_content = json.load(f_h)

        self.kpi_test_def = {
            "board": self.kpi_content["header"]["snapshotData"]["board"],
            "feature": self.kpi_content["header"]["scriptParam"]["feature"],
            "CCNumber": self.kpi_content["header"]["TestConfig"]["CCnumber"],
            "UENumber": self.kpi_content["header"]["TestConfig"]["UEnumber"],
            "DDtype": self.kpi_content["header"]["TestConfig"]["DDtype"],
            "TTIDuration": self.kpi_content["header"]["TestConfig"]["TTIduration"],
            "configKey": self.kpi_content["header"]["scriptParam"]["config"],
            "testNameConfig": self.kpi_content["header"]["scriptParam"]["testNameConfig"],
        }
        self.res_run_ok = subprocess.run(
            "echo FAKE", check=False, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        self.res_run_except = subprocess.run(
            "exit 1", check=False, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )

        self.mock = {
            "save": patch("save_file.SaveFile.save").start(),
            "report": patch("report.Report", autospec=True).start(),
            "stdout": patch("sys.stdout.write").start(),
            "stderr": patch("sys.stderr.write").start(),
            "kpi": patch("time_marker_kpi_file.TimeMarkerKPIFile").start(),
            "context": patch("context.Context", autospec=True).start(),
            "glob_glob": patch("glob.glob", autospec=True).start(),
            "rmtree": patch("shutil.rmtree", autospec=True).start(),
            "run": patch("subprocess.run", autospec=True).start(),
            "datetime": patch("datetime.datetime").start(),
        }

        # Mock Context method init
        self.mock["context"].return_value.clone_time_marker.return_value = True
        self.mock["context"].return_value.get_commit_date.return_value = self.commit_info["date"]
        self.mock["context"].return_value.is_alarm_critical = False
        self.mock["context"].return_value.get_configure_option_list.return_value = dict()

        # Mock Glob method init
        self.mock["glob_glob"].side_effect = [[self.filename["KPI_FULL"]]]

        # Mock run init
        self.mock["run"].return_value = self.res_run_ok

        # Action list
        self.action_dict = {
            "context_init": "Active",
            "clone_decoder": "Active",
            "get_commit_date": "Active",
            "get_configure_option_list": "Active",
            "run_decoder": "Active",
            "glob_glob": "Active",
            "save": "Active",
            "kpi": "Active",
            "rmtree": "Active",
            "report_alarm": "Inactive",
            "report_error": "Inactive",
            "stdout": "Active",
            "stderr": "Inactive",
        }

        self.action_extra_params = {}

        self.kpi_dir_option_args = [
            "perf_portal.py",
            "--dirKpi",
            self.tempdir.name,
            "--testType",
            "ET",
            "--softwareCommit",
            self.commit_info["nb"],
        ]

        # Mock datetime init
        self.testdate = {
            "dir": "2019/11/11/11.43.28",
            "file": "2019.11.11_11.43.28",
            "param": "2019-11-11T11:43:28",
        }
        self.mock["datetime"].utcnow.return_value = datetime(2019, 11, 11, 11, 43, 28)
        self.mock["datetime"].strptime.side_effect = datetime.strptime
        self.addCleanup(patch.stopall)
        self.addCleanup(self.tempdir.cleanup)

    def get_stderr_call_str_message(self):
        res = []
        for stderr_call in self.mock["stderr"].call_args_list:
            stderr_str = re.sub("[ ]+", " ", re.sub("\\\\n", "", str(stderr_call)))
            res.append(re.sub("call\\('(.*)'\\)", r"\1", stderr_str))
        return res

    def set_kpi_content_header(self):
        file_kpi = os.path.basename(self.filename["KPI_FULL"]).replace(
            ".json", f"_{self.testdate['file']}_{self.commit_info['nb'][:7]}.json"
        )
        self.kpi_content["header"]["snapshotData"]["gnbCommitDate"] = (
            self.commit_info["date"]
            if not self.action_extra_params.get("get_commit_date_except", False)
            else self.testdate["param"]
        )
        self.kpi_content["header"]["scriptParam"].update(
            {
                "extended": False,
                "userCSL": None,
                "testDate": self.testdate["param"],
                "fileKpi": file_kpi,
                "fileSnapshot": (
                    None
                    if self.action_extra_params.get("save_snapshot_except")
                    else f"{file_kpi.replace('KPIv2', 'Snapshot')}.xz"
                ),
                "testType": self.kpi_dir_option_args[
                    self.kpi_dir_option_args.index("--testType") + 1
                ],
            }
        )

    def assert_check_stdout(self, msg_array, replay=False):
        general_traces = (
            "perf_portal.py start",
            "Srunner result file not found",
            "param was",
            "b''",
            "commit ",
            "Warning: No TimeMarker",
            "WARNING an error occur but eror mail will not be sent",
            "perf_portal.py ends",
            self.info_message,
        )
        calls = []
        index = None if replay else 1
        for msg in msg_array:
            if not msg.startswith(general_traces):
                msg = f"{msg} - perf_index: {index}"
            calls.append(call(msg))
            calls.append(call("\n"))
        self.mock["stdout"].assert_has_calls(calls)
        self.assertEqual(self.mock["stdout"].call_count, len(calls) + 14)

    # Test suite for invalid parameters
    def common_invalid_parameters(self, args, stderr_call_2):
        with patch.object(sys, "argv", args):
            with patch.dict("os.environ", values=self.env_values):
                spec = spec_from_file_location("__main__", "perf_portal.py")
                module = module_from_spec(spec)
                self.assertRaises(SystemExit, spec.loader.exec_module, module)

        self.mock["save"].assert_not_called()
        self.mock["report"].return_value.error.assert_not_called()
        self.mock["report"].return_value.alarm.assert_not_called()
        self.mock["kpi"].assert_not_called()

        self.mock["glob_glob"].assert_not_called()
        self.mock["context"].assert_not_called()
        self.mock["kpi"].assert_not_called()

        stderr_call_1 = (
            "usage: perf_portal.py [-h] (--dirKpi DIRKPI | --replay) [--fileJunit FILEJUNIT] "
            "[--softwareBranch SOFTWAREBRANCH] [--softwareCommit SOFTWARECOMMIT] "
            "[--noMultiProcess] [--extended] (--fileKpi FILEKPI | --testType {"
            f"{TEST_TYPE}"
            "}) [--userCSL USERCSL]"
        )

        stderr_call_params_array = self.get_stderr_call_str_message()
        self.assertEqual(stderr_call_params_array[0], stderr_call_1)
        self.assertEqual(stderr_call_params_array[1], stderr_call_2)

        self.mock["stdout"].assert_has_calls(
            [
                call("perf_portal.py start ..."),
                call("\n"),
                call(RETURN_CODE_MESSAGE[RC_BAD_ARGS]),
                call("\n"),
                call(self.info_message),
                call("\n"),
            ]
        )
        self.assertEqual(self.mock["stdout"].call_count, 20)
        self.mock["context"].return_value.clone_time_marker.assert_not_called()
        self.mock["context"].return_value.get_commit_date.assert_not_called()
        self.mock["rmtree"].return_value.assert_not_called()
        self.mock["run"].assert_not_called()

    def test_given_main_when_call_without_parameters_then_help_is_printed_and_exception_raised(
        self,
    ):
        args = ["perf_portal.py"]
        stderr_call_2 = "perf_portal.py: error: one of the arguments --dirKpi --replay is required"

        self.common_invalid_parameters(args, stderr_call_2)

    def test_with_parameter_dir_kpi_only_then_help_is_printed_and_exception_raised(self):
        args = ["perf_portal.py", "--dirKpi", self.tempdir.name]
        stderr_call_2 = (
            "perf_portal.py: error: one of the arguments --fileKpi --testType is required"
        )

        self.common_invalid_parameters(args, stderr_call_2)

    def test_with_parameter_dir_kpi_and_file_kpi_then_help_is_printed_and_exception_raised(self):
        args = ["perf_portal.py", "--dirKpi", self.tempdir.name, "--fileKpi", "some_filename"]
        stderr_call_2 = (
            "perf_portal.py: error: argument --testType is mandatory with --dirKpi option"
        )
        self.common_invalid_parameters(args, stderr_call_2)

    def test_with_parameter_dir_kpi_and_test_type_then_help_is_printed_and_exception_raised(self):
        args = ["perf_portal.py", "--dirKpi", self.tempdir.name, "--testType", "ET"]
        stderr_call_2 = (
            "perf_portal.py: error: argument --softwareCommit is mandatory with --dirKpi option"
        )

        self.common_invalid_parameters(args, stderr_call_2)

    def test_with_parameter_replay_and_test_type_then_help_is_printed_and_exception_raised(self):
        args = ["perf_portal.py", "--replay", "--testType", "ET"]
        stderr_call_2 = (
            "perf_portal.py: error: argument --fileKpi is mandatory with --replay option"
        )

        self.common_invalid_parameters(args, stderr_call_2)

    # Test suite for job with nothing to do - filtering at the beginning
    def assert_not_called_with_filtered_jobs(self, env_values, args):
        self.env_values = env_values
        if "METRICS_IGNORE" not in self.env_values:
            self.env_values.update({"METRICS_IGNORE": "false"})

        with patch.object(sys, "argv", args + ["--noMultiProcess"]):
            with patch.dict("os.environ", values=self.env_values):
                spec = spec_from_file_location("__main__", "perf_portal.py")
                module = module_from_spec(spec)
                spec.loader.exec_module(module)

        self.assert_check_stdout([])
        self.mock["report"].return_value.error.assert_not_called()

    def test_perf_portal_not_called_when_job_like_fuse(self):
        env_values = {
            "JOB_BASE_NAME": "SCT.simple.abil",
            "JOB_NAME": "MASTER/GNB/UPLANE/SCT/CPP_TESTSUITES/FUSE/SCT.simple.abil",
            "ZUUL_PIPELINE": "check",
        }

        args = [
            "perf_portal.py",
            "--dirKpi",
            self.tempdir.name,
            "--testType",
            "Check",
            "--softwareCommit",
            self.commit_info["nb"],
        ]

        self.assert_not_called_with_filtered_jobs(env_values, args)

    def test_perf_portal_not_called_when_job_like_sct_fuse_and_not_post(self):
        env_values = {
            "JOB_BASE_NAME": "SCT.fuse.abil",
            "JOB_NAME": "MASTER/GNB/UPLANE/L2-PS/SCT.fuse.abil",
            "ZUUL_PIPELINE": "check",
        }

        args = [
            "perf_portal.py",
            "--dirKpi",
            self.tempdir.name,
            "--testType",
            "Post",
            "--softwareCommit",
            self.commit_info["nb"],
        ]

        self.assert_not_called_with_filtered_jobs(env_values, args)

    def test_perf_portal_not_called_when_metrics_ignore_is_true(self):
        env_values = {
            "JOB_BASE_NAME": "SCT.simple.abil",
            "JOB_NAME": "MASTER/GNB/UPLANE/L2-PS/SCT.simple.abil",
            "ZUUL_PIPELINE": "check",
            "METRICS_IGNORE": "true",
        }

        args = [
            "perf_portal.py",
            "--dirKpi",
            self.tempdir.name,
            "--testType",
            "Check",
            "--softwareCommit",
            self.commit_info["nb"],
        ]

        self.assert_not_called_with_filtered_jobs(env_values, args)

    def test_perf_portal_not_called_when_job_like_sct_stability_abil(self):
        env_values = {
            "JOB_BASE_NAME": "SCT.stability.abil",
            "JOB_NAME": "MASTER/GNB/UPLANE/L2-PS/SCT.stability.abil",
            "ZUUL_PIPELINE": "check",
        }

        args = [
            "perf_portal.py",
            "--dirKpi",
            self.tempdir.name,
            "--testType",
            "Check",
            "--softwareCommit",
            self.commit_info["nb"],
        ]

        self.assert_not_called_with_filtered_jobs(env_values, args)

    # Test suite for replay option
    def common_replay_parameters(self, args, call_error=False):
        with patch.object(sys, "argv", args):
            with patch.dict("os.environ", values=self.env_values):
                spec = spec_from_file_location("__main__", "perf_portal.py")
                module = module_from_spec(spec)
                spec.loader.exec_module(module)

        self.mock["save"].assert_not_called()
        self.mock["stderr"].assert_not_called()
        self.mock["context"].assert_called_once_with(
            zuul_branch="master",
            check_threshold=False,
            insert_into_db=True,
            send_gerrit_comment=False,
            multiprocess=True,
        )
        if call_error:
            self.mock["report"].return_value.error.assert_called_once_with()
        else:
            self.mock["report"].return_value.error.assert_not_called()
        self.mock["report"].return_value.alarm.assert_not_called()
        self.mock["glob_glob"].assert_not_called()
        self.mock["context"].return_value.clone_time_marker.assert_not_called()
        self.mock["context"].return_value.get_commit_date.assert_not_called()
        self.mock["rmtree"].return_value.assert_not_called()
        self.mock["run"].assert_not_called()

    def test_replay_parameters_but_file_kpi_not_exist(self):
        args = ["perf_portal.py", "--fileKpi", "FileDoesNotExistHere.json", "--replay"]

        self.common_replay_parameters(args, call_error=True)

        self.mock["kpi"].assert_not_called()

        self.assert_check_stdout(
            [
                "perf_portal.py start ...",
                "param was {"
                "'dirKpi': None, 'replay': True, 'fileJunit': 'junit-report.xml', "
                "'softwareBranch': 'master', 'softwareCommit': None, 'extended': False, "
                "'fileKpi': 'FileDoesNotExistHere.json', 'testType': None, 'userCSL': None, "
                "'fileSnapshot': None}",
                self.info_message,
            ]
        )

    def test_replay_parameters_file_kpi_correct_json(self):
        args = ["perf_portal.py", "--fileKpi", self.filename["KPI_REPLAY"], "--replay"]
        with open(self.filename["KPI_REPLAY"], "w") as kpi_file:
            kpi_file.write(self.header["minimal"])
        self.common_replay_parameters(args)
        self.mock["kpi"].assert_called_once_with(
            json.loads(self.header["minimal"]), self.mock["context"].return_value
        )

        self.assert_check_stdout(
            [
                "perf_portal.py start ...",
                "param was {"
                "'dirKpi': None, 'replay': True, 'fileJunit': 'junit-report.xml', "
                f"'softwareBranch': 'master', 'softwareCommit': None, 'extended': False, "
                f"'fileKpi': '{self.filename['KPI_REPLAY']}', 'testType': None, 'userCSL': None, "
                "'fileSnapshot': None}",
                "TimeMarkerKPIFile object creation",
                "TimeMarkerKPIFile computed",
                "perf_portal.py ends successfully",
            ],
            replay=True,
        )

    # Test suite for dirKpi option
    def get_run_call(self):
        extended = self.action_extra_params["decode_extended"]

        decoder_params = [
            "timeMarker/tools/TimeMarkerKPI/script/launch.sh",
            "--gnbCommit",
            self.commit_info["nb"],
            "--kpiVersion",
            "2",
        ]
        if extended:
            decoder_params.append("--extended")

        decoder_params += ["--betaVersion", self.filename["KPI_FULL"].replace("KPIv2", "Snapshot")]

        return [call(decoder_params, check=False, stderr=-1, stdout=-1, universal_newlines=True)]

    def check_action_context_init(self, status):
        if status == "Active":
            self.mock["context"].assert_called_once_with(
                zuul_branch="master",
                check_threshold=self.action_extra_params.get("check_threshold", True),
                insert_into_db=self.action_extra_params.get("insert_into_db", True),
                send_gerrit_comment=self.action_extra_params.get("send_gerrit_comment", True),
                multiprocess=False,
            )

    def check_action_clone_decoder(self, status):
        if status == "Active":
            self.mock["context"].return_value.clone_time_marker.assert_called_once_with()
        else:
            self.mock["context"].return_value.clone_time_marker.assert_not_called()

    def check_action_get_commit_date(self, status):
        if status == "Active":
            self.mock["context"].return_value.get_commit_date.assert_called_once_with(
                self.commit_info["nb"]
            )

    def check_action_get_configure_option_list(self, status):
        if status == "Active":
            self.mock["context"].return_value.get_configure_option_list.assert_called_once_with(
                self.kpi_test_def
            )
        else:
            self.mock["context"].return_value.get_configure_option_list.assert_not_called()

    def check_action_run_decoder(self, status):
        if status == "Active":
            self.mock["run"].assert_has_calls(self.get_run_call())
        else:
            self.mock["run"].assert_not_called()

    def check_action_glob_glob(self, status):
        if status == "Active":
            self.mock["glob_glob"].assert_called_once_with(self.filename["KPI_FULL"])
        else:
            self.mock["glob_glob"].return_value.assert_not_called()

    def check_action_save(self, status):
        if status == "Active":
            self.mock["save"].assert_has_calls(
                [
                    call(
                        self.testdate["dir"],
                        self.filename["KPI_FULL"].replace("KPIv2", "Snapshot"),
                        os.path.basename(self.filename["KPI_FULL"])
                        .replace("KPIv2", "Snapshot")
                        .replace(
                            ".json",
                            f"_{self.testdate['file']}_{self.commit_info['nb_small']}.json.xz",
                        ),
                        True,
                    ),
                    call(
                        self.testdate["dir"],
                        self.filename["KPI_FULL"],
                        os.path.basename(self.filename["KPI_FULL"]).replace(
                            ".json",
                            f"_{self.testdate['file']}_{self.commit_info['nb_small']}.json",
                        ),
                        False,
                    ),
                ]
            )
            self.assertEqual(self.mock["save"].call_count, 2)
        else:
            self.mock["save"].assert_not_called()

    def check_action_kpi(self, status):
        if status == "Active":
            self.mock["kpi"].assert_called_once_with(
                self.kpi_content, self.mock["context"].return_value
            )
            self.mock["kpi"].return_value.compute_kpi_file.assert_called_once_with()
        else:
            self.mock["kpi"].assert_not_called()
            self.mock["kpi"].return_value.compute_kpi_file.assert_not_called()

    def check_action_rmtree(self, status):
        if status == "Active":
            self.mock["rmtree"].assert_has_calls([call("timeMarker/")])
        else:
            self.mock["rmtree"].assert_not_called()

    def check_action_report_alarm(self, status):
        self.mock["report"].return_value.alarm.assert_not_called()

    def check_action_report_error(self, status):
        if status == "Active":
            self.mock["report"].return_value.error.assert_called_once()
        else:
            self.mock["report"].return_value.error.assert_not_called()

    def check_action_stdout(self, status):
        if self.action_extra_params["stdout_message_dict"]:
            self.mock["stdout"].assert_has_calls(
                self.action_extra_params["stdout_message_dict"], any_order=True
            )

    def check_action_stderr(self, status):
        if status == "Inactive":
            self.mock["stderr"].assert_not_called()

    def update_test_type_into_default_args(self, test_type):
        idx = self.kpi_dir_option_args.index("--testType") + 1
        self.kpi_dir_option_args[idx] = test_type

    def common_dir_kpi(
        self,
        system_exit=False,
        stdout_message_dict=[],
    ):

        args = self.kpi_dir_option_args
        test_type = args[args.index("--testType") + 1]

        self.action_extra_params.update(
            {
                "decode_extended": ("--extended" in args or test_type in ["Continuous"]),
                "stdout_message_dict": stdout_message_dict,
                "check_threshold": (
                    self.env_values["JOB_BASE_NAME"] not in ["SCT.wip.abil"]
                    and test_type not in ["Endurance", "Continuous", "Manual"]
                ),
                "insert_into_db": test_type in ["Post", "Continuous", "Endurance", "Manual", "ET"],
                # todo: not used
                "send_gerrit_comment": test_type not in ["Continuous", "Endurance", "Manual", "ET"],
            }
        )

        self.set_kpi_content_header()

        with patch.object(sys, "argv", args + ["--noMultiProcess"]):
            with patch.dict("os.environ", values=self.env_values):
                spec = spec_from_file_location("__main__", "perf_portal.py")
                module = module_from_spec(spec)
                if system_exit:
                    self.assertRaises(SystemExit, spec.loader.exec_module, module)
                else:
                    spec.loader.exec_module(module)

        for action, status in self.action_dict.items():
            getattr(self, f"check_action_{action}")(status)

    def test_dir_kpi_with_no_srunner_result_file(self):
        os.remove(self.filename["PERF_PORTAL_JSON"])

        self.action_dict.update(
            {
                "clone_decoder": "Inactive",
                "get_commit_date": "Inactive",
                "get_configure_option_list": "Inactive",
                "run_decoder": "Inactive",
                "glob_glob": "Inactive",
                "save": "Inactive",
                "kpi": "Inactive",
                "rmtree": "Inactive",
            }
        )

        self.common_dir_kpi(
            system_exit=True,
            stdout_message_dict=[call(RETURN_CODE_MESSAGE[RC_SRUNNER_FILE_NOT_FOUND])],
        )

    def test_dir_kpi_with_context_clone_exit(self):
        self.mock["context"].return_value.clone_time_marker.side_effect = [SystemExit]

        self.action_dict.update(
            {
                "clone_decoder": "Active",
                "get_commit_date": "Inactive",
                "get_configure_option_list": "Inactive",
                "run_decoder": "Inactive",
                "glob_glob": "Inactive",
                "save": "Inactive",
                "kpi": "Inactive",
                "rmtree": "Inactive",
                "report_error": "Active",
            }
        )

        self.common_dir_kpi(system_exit=True, stdout_message_dict=[call(self.info_message)])

    def test_dir_kpi_with_srunner_file_but_no_snapshot_file(self):
        copyfile(
            f"{os.path.dirname(__file__)}/test_data/perf_portal_no_snapshot.json",
            self.filename["PERF_PORTAL_JSON"],
        )

        self.action_dict.update(
            {
                "clone_decoder": "Inactive",
                "get_commit_date": "Inactive",
                "get_configure_option_list": "Inactive",
                "run_decoder": "Inactive",
                "glob_glob": "Inactive",
                "save": "Inactive",
                "kpi": "Inactive",
                "rmtree": "Inactive",
            }
        )
        perf_portal_json = self.filename["PERF_PORTAL_JSON"]
        self.common_dir_kpi(
            # todo; ready to block jobs if no timemarker, just need to system_exit=True param
            stdout_message_dict=[
                call(f"Warning: No TimeMarker file found into {perf_portal_json}")
            ],
        )

    def common_dir_kpi_with_srunner_snapshot_file_ok(self):
        self.common_dir_kpi(
            stdout_message_dict=[
                call(
                    # BHR begin 18/10/2024 : PEP8 _ too long line to be cut into 120 characters max per line
                    # f"### File: {self.tempdir.name}/TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_\
                    # 4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json - perf_index: 1"
                    f"### File: {self.tempdir.name}/"
                    "TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_"
                    "REF_0_0.json - perf_index: 1"
                    # BHR end
                ),
                call("TimeMarker decode done - perf_index: 1"),
                call("TimeMarkerKPIFile computed - perf_index: 1"),
                call("perf_portal.py ends successfully"),
            ]
        )

    def test_dir_kpi_with_srunner_snapshot_file_ok_post(self):
        self.common_dir_kpi_with_srunner_snapshot_file_ok()

    # check threshold variation
    def test_dir_kpi_with_srunner_snapshot_file_ok_post_wip_abil(self):
        self.env_values["JOB_BASE_NAME"] = "SCT.wip.abil"
        self.common_dir_kpi_with_srunner_snapshot_file_ok()

    def test_dir_kpi_with_srunner_snapshot_file_ok_manual(self):
        self.update_test_type_into_default_args("Manual")
        self.common_dir_kpi_with_srunner_snapshot_file_ok()

    def test_dir_kpi_with_srunner_snapshot_file_ok_but_critical_alarm_detected(self):
        self.mock["context"].return_value.is_alarm_critical = True
        self.common_dir_kpi(
            system_exit=True,
            stdout_message_dict=[
                call(
                    # BHR begin 18/10/2024 : PEP8 _ too long line to be cut into 120 characters max per line
                    # f"### File: {self.tempdir.name}/TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_\
                    # TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json - perf_index: 1"
                    f"### File: {self.tempdir.name}/"
                    "TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_"
                    "REF_0_0.json - perf_index: 1"
                    # BHR end
                ),
                call("TimeMarker decode done - perf_index: 1"),
                call("TimeMarkerKPIFile computed - perf_index: 1"),
                call("perf_portal.py ends successfully"),
                call(RETURN_CODE_MESSAGE[RC_MAJOR_CHECK_ALARM]),
            ],
        )

    def test_dir_kpi_with_srunner_snapshot_file_get_commit_date_except(self):
        self.mock["context"].return_value.get_commit_date.side_effect = [ValueError]
        self.action_extra_params.update({"get_commit_date_except": True})

        self.common_dir_kpi(
            stdout_message_dict=[
                call(
                    "commit 123456789ABCDEFG is not a real one so test date is used as commit date"
                ),
                call(
                    # BHR begin 18/10/2024 : PEP8 _ too long line to be cut into 120 characters max per line
                    # f"### File: {self.tempdir.name}/TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_\
                    # TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json - perf_index: 1"
                    f"### File: {self.tempdir.name}/"
                    "TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_"
                    "REF_0_0.json - perf_index: 1"
                    # BHR end
                ),
                call("TimeMarker decode done - perf_index: 1"),
                call("TimeMarkerKPIFile computed - perf_index: 1"),
                call("perf_portal.py ends successfully"),
            ],
        )

    def test_dir_kpi_with_srunner_snapshot_file_ok_and_save_snapshot_failed(self):
        self.mock["save"].side_effect = [SystemError, True]
        self.action_extra_params.update({"save_snapshot_except": True})

        self.common_dir_kpi(
            stdout_message_dict=[
                call(
                    # BHR begin 18/10/2024 : PEP8 _ too long line to be cut into 120 characters max per line
                    # f"### File: {self.tempdir.name}/TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_\
                    # \TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json - perf_index: 1"
                    f"### File: {self.tempdir.name}/"
                    "TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_"
                    "REF_0_0.json - perf_index: 1"
                    # BHR end
                ),
                call("TimeMarker decode done - perf_index: 1"),
                call("TimeMarkerKPIFile computed - perf_index: 1"),
                call("perf_portal.py ends successfully"),
            ],
        )

    def test_dir_kpi_with_srunner_snapshot_file_ok_with_critical_threshold(self):
        self.mock["context"].return_value.is_alarm_critical = True
        self.common_dir_kpi(
            stdout_message_dict=[
                call(
                    # BHR begin 18/10/2024 : PEP8 _ too long line to be cut into 120 characters max per line
                    # f"### File: {self.tempdir.name}/TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_\
                    # TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json - perf_index: 1"
                    f"### File: {self.tempdir.name}/"
                    "TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_"
                    "REF_0_0.json - perf_index: 1"
                    # BHR end
                ),
                call("TimeMarker decode done - perf_index: 1"),
                call("TimeMarkerKPIFile computed - perf_index: 1"),
                call("perf_portal.py ends successfully"),
                call("Critical Alarm detected"),
            ],
            system_exit=True,
        )

    def test_dir_kpi_with_srunner_snapshot_file_decode_but_no_kpi_file(self):
        self.mock["glob_glob"].side_effect = [[]]

        self.action_dict.update(
            {
                "save": "Inactive",
                "kpi": "Inactive",
                "report_error": "Active",
            }
        )
        self.common_dir_kpi(
            stdout_message_dict=[
                call(
                    # BHR begin 18/10/2024 : PEP8 _ too long line to be cut into 120 characters max per line
                    # f"### File: {self.tempdir.name}/TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_\
                    # TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json - perf_index: 1"
                    f"### File: {self.tempdir.name}/"
                    "TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_"
                    "REF_0_0.json - perf_index: 1"
                    # BHR end
                ),
                call("decode snapshot active - perf_index: 1"),
                call("perf_portal.py ends with 1 snapshot file process in error"),
            ],
        )

    def test_dir_kpi_with_srunner_snapshot_file_decode_kpi_except(self):
        self.mock["kpi"].return_value.compute_kpi_file.side_effect = ValueError

        self.action_dict.update({"report_error": "Active"})
        self.common_dir_kpi(
            stdout_message_dict=[
                call(
                    # BHR begin 18/10/2024 : PEP8 _ too long line to be cut into 120 characters max per line
                    # f"### File: {self.tempdir.name}/TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_\
                    # TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json - perf_index: 1"
                    f"### File: {self.tempdir.name}/"
                    "TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_REF_"
                    "0_0.json - perf_index: 1"
                    # BHR end
                ),
                call("decode snapshot active - perf_index: 1"),
                call("perf_portal.py ends with 1 snapshot file process in error"),
            ],
        )

    def test_dir_kpi_with_srunner_snapshot_file_decode_kpi_except_but_not_mail(self):
        self.mock["kpi"].return_value.compute_kpi_file.side_effect = ExceptionNotNeedToSendByMail

        self.action_dict.update({"report_error": "Inactive"})
        self.common_dir_kpi(
            stdout_message_dict=[
                call(
                    # BHR begin 18/10/2024 : PEP8 _ too long line to be cut into 120 characters max per line
                    # f"### File: {self.tempdir.name}/TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE_\
                    # TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json - perf_index: 1"
                    f"### File: {self.tempdir.name}/TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_4CC_48UE"
                    "_TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json - perf_index: 1"
                    # BHR end
                ),
                call("decode snapshot active - perf_index: 1"),
                call(
                    "WARNING an error occur but eror mail will not be sent for: perf_index: 1 => "
                ),
                call("perf_portal.py ends with 1 snapshot file process in error"),
            ],
        )
