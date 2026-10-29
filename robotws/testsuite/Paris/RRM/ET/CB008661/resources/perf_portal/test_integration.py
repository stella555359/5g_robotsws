import sys
from shutil import copyfile
import os
import re
import json
import subprocess
from datetime import datetime
import unittest
from copy import deepcopy
from unittest.mock import patch, call
from importlib.util import spec_from_file_location, module_from_spec
import context

SUBMITTED_DATE = "2019-09-30 09:35:45"
UPDATED_DATE = "2019-09-30 09:57:27"
CREATED_DATE = "2019-09-20 06:08:48"
TEST_DATE_STR = "2021.12.20_08.40.30"


def func_select_list_into_one_table(
    table_name,
    select_col=["id"],
    where_dict=None,
    where_str=None,
    where_except_dict=None,
    order_list=None,
    sort_order="DESC",
    group_by_str=None,
    limit_result=1,
):
    # pylint: disable=unused-argument,dangerous-default-value
    if table_name == "Test":
        return [
            {"id": 997, "fileKPI": "previous_same_test_kpi_file_1.json"},
            {"id": 998, "fileKPI": "previous_same_test_kpi_file_2.json"},
            {"id": 999, "fileKPI": "previous_same_test_kpi_file_3.json"},
        ]

    return [{"max(max)": 9.0, "max(95p)": 9.0}]


def gerrit_rest_get_side_effect(*args):
    change_return = {
        "commit": "06d2e1b4637263e18219e457c0ab17e4c6cf2742",
        "parents": [
            {
                "commit": "990b6b352c682807e691fc6b7f02c1319fa55125",
                "subject": "MNECECI-4486: Perf Portal: Add cs1list "
                "(UE number) in history & test views",
            }
        ],
        "author": {
            "name": "GUILLAUME David",
            "email": "david.guillaume@nokia.com",
            "date": "2019-09-24 12:15:47.000000000",
            "tz": 180,
        },
        "committer": {
            "name": "GUILLAUME David",
            "email": "david.guillaume@nokia.com",
            "date": "2019-09-26 14:41:26.000000000",
            "tz": 120,
        },
        "subject": "[MNECECI-4445] Add 5G19 thresholds",
        "message": "[MNECECI-4445] Add 5G19 thresholds\n\n"
        "Change-Id: I1ff58d2cf6b8becfba06d5b54e957a23bfe262ce\n",
    }
    commit_return = [
        {
            "id": "MN%2F5G%2FNB%2Fgnb~master~I7cd798af260d4556ae554732c017f86be7a1c1f5",
            "project": "MN/5G/NB/gnb",
            "branch": "master",
            "change_id": "I7cd798af260d4556ae554732c017f86be7a1c1f5",
            "subject": "[5GC000728-B-a2][5GC000728-B-a5]SCT-Inactivity detection and handling",
            "status": "MERGED",
            "created": f"{CREATED_DATE}.044000000",
            "updated": f"{UPDATED_DATE}.234000000",
            "submitted": f"{SUBMITTED_DATE}.346000000",
            "insertions": 378,
            "deletions": 103,
            "unresolved_comment_count": 0,
            "_number": 1_384_267,
            "owner": {"_account_id": 1_016_103},
        }
    ]
    if "changes/ZUUL_CHANGE_TEST_PERF_INTEGRATION" in args[0]:
        return change_return
    return commit_return


class TestIntegrationPerfPortal(unittest.TestCase):
    def setUp(self):
        context.THRESHOLD_DIR = f"{os.path.dirname(__file__)}/test_data/default_threshold"

        #  self.maxDiff = None
        res_run = subprocess.run(
            "echo FAKE", check=False, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        self.mock = {
            "run": patch("subprocess.run", autospec=True).start(),
            "stderr": patch("sys.stderr.write", autospec=True).start(),
            "stdout": patch("sys.stdout.write").start(),
            "send_mail": patch("send_email.Email").start(),
            "database_connect": patch("connect_to_database.Database.connect").start(),
            "database_insert": patch("connect_to_database.Database.insert").start(),
            "database_commit": patch("connect_to_database.Database.commit").start(),
            "database_select_into_one_table": patch(
                "connect_to_database.Database.select_list_into_one_table"
            ).start(),
            "gerrit_send_comments": patch("gerrit.Gerrit.send_comments").start(),
            "gerrit_api_rest_get": patch("gerrit_api_rest.GerritRestAPI.get").start(),
            "gerrit_git_clone_time_marker": patch("gerrit.Gerrit.git_clone_time_marker").start(),
            "glob_glob": patch("glob.glob", autospec=True).start(),
            "rmtree": patch("shutil.rmtree", autospec=True).start(),
            "datetime": patch("datetime.datetime").start(),
        }

        self.mock["run"].return_value = res_run
        self.mock["database_insert"].return_value = 100
        self.mock["database_select_into_one_table"].side_effect = func_select_list_into_one_table
        self.mock["gerrit_api_rest_get"].side_effect = gerrit_rest_get_side_effect
        self.mock["datetime"].utcnow.return_value = datetime.strptime(
            TEST_DATE_STR, "%Y.%m.%d_%H.%M.%S"
        )
        self.mock["datetime"].strptime.side_effect = datetime.strptime
        self.mock["datetime"].strftime.side_effect = datetime.strftime

        self.fixture_email = "i_mn_5gsc_sw_eng_perf_portal_alarm@groups.nokia.com"
        self.fixture_subject = "Alarm provided by perf_portal.py"

        self.fixture_os_environ = {
            "ZUUL_CHANGE": "ZUUL_CHANGE_TEST_PERF_INTEGRATION",
            "ZUUL_PATCHSET": "PERF_INT",
            "JOB_BASE_NAME": "MY_CURRENT_JOB",
            "BUILD_NUMBER": "MY_BUILD_NUMBER",
            "BUILD_URL": "https://ece-ci.dynamic.nsn-net.net/job/MASTER/"
            "job/GNB/job/L2-PS/job/SCT.wip.abil/1123/",
            "GIT_HOME": "/opt/git/version_git",
            "METRICS_IGNORE": "false",
            "ZUUL_PIPELINE": "cont",
        }

        self.directory = "2021/12/20/08.40.30"
        self.user_server = "perfport@5gwebserver.dyn.nesc.nokia.net"

        self.ssh_options = [
            "-o",
            "StrictHostKeyChecking=no",
            "-o",
            "UserKnownHostsFile=/dev/null",
            "-o",
            "ConnectTimeout=10",
            "-o",
            "ConnectionAttempts=2",
        ]

        self.run_args = {
            "shell": False,
            "check": True,
            "universal_newlines": True,
            "stdout": subprocess.PIPE,
            "stderr": subprocess.PIPE,
        }

        self.fixture = {
            "commit_full_hash": "e76f180af7ff6db74bf46ec2246af55ca76f66a4",
            "commit_7_hash": "e76f180",
            "snapshot_file": (
                "/tmp/TimeMarkerSnapshot_L2RT_ft123_plusExtendedPlusSync_"
                "4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json"
            ),
            "original_kpi_file": (
                f"{os.path.dirname(__file__)}/test_data/"
                f"TimeMarkerKPIv2_L2RT_ft123_plusExtendedPlusSync_"
                f"4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json"
            ),
            "result_kpi_file": (
                f"{os.path.dirname(__file__)}/test_data/"
                f"ResForTimeMarkerKPIv2_L2RT_ft123_plusExtendedPlusSync_"
                f"4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json"
            ),
            "original_perf_portal_json": f"{os.path.dirname(__file__)}/test_data/perf_portal.json",
            "dest_perf_portal_json": "/tmp/perf_portal.json",
        }
        self.fixture["kpi_file"] = f"/tmp/{os.path.basename(self.fixture['original_kpi_file'])}"
        copyfile(self.fixture["original_kpi_file"], self.fixture["kpi_file"])
        copyfile(self.fixture["original_perf_portal_json"], self.fixture["dest_perf_portal_json"])

        with open(self.fixture["result_kpi_file"], "r") as f_h:
            self.fixture["res_json_content"] = json.load(f_h)["TimeMarkerKpiFileDatabaseObject"]

        self.test_view_url = (
            "https://app.powerbi.com/groups/me/apps/4b451a02-"
            "844c-47b2-bd6b-e43667c7cf16/reports/40754105-09ce-460f-8c03-"
            "6881db7c58c7/ReportSection047c7ac31e9441232f58"
        )
        self.history_view_url = (
            "https://app.powerbi.com/groups/me/apps/"
            "4b451a02-844c-47b2-bd6b-e43667c7cf16/reports/40754105-09ce-460f-8c03-"
            "6881db7c58c7/ReportSection45750c70ce6fd4a0a73d"
        )
        self.kpi_url_1 = (
            "https://5gwebserver.dyn.nesc.nokia.net/CinqG/perfport/"
            "2019/05/03/08.40.28/TimeMarkerKPI_L2RT_ft425_simpleTraffic_1CC_1UE_TDD125_ABIL_"
            "2019.05.03_08.40.28_0751768.json"
        )
        self.kpi_url_2 = (
            "https://5gwebserver.dyn.nesc.nokia.net/CinqG/perfport/"
            "2019/05/03/08.40.30/TimeMarkerKPIv2_L2RT_ft425_simpleTraffic_1CC_10UE_TDD125_"
            "ABIL_2019.05.03_08.40.30_0751768.json"
        )

        self.message_dict = {
            "Critical": "",
            "Major": (
                "<b>Min Cs1List Alarm:</b>\nWarning : "
                "TimeMarkerKPIv2_L2RT_<b>ft425_simpleTraffic_1CC_10UE_TDD125_ABIL</b>_"
                "2019.05.03_08.40.30_0751768.json :\nL2PSDL.cs1List.95p = "
                "0.2 under minimum CS1 List threshold 0.5."
            ),
            "Minor": (
                "<b>Marker Duration Alarm:</b>\nWarning : TimeMarkerKPIv2_L2RT_<b>"
                "ft425_simpleTraffic_1CC_10UE_TDD125_ABIL</b>_2019.05.03_08.40.30_0751768.json :"
                "\nL2PSUL.max = 26.0 ns exceeds marker duration value 20 ns."
            ),
        }

        self.pbi_links = (
            f'\n<a href="{self.test_view_url}?filter=perf_5g_x0020_Test/FormatedTestName eq '
            "'ft425_simpleTraffic_1BM_1CC_10UE_1UEsched_TDD125_ABIL' and perf_5g_x0020_Test/"
            f"FormatedCommitShortName eq '0751768'\">"
            f'Power BI test view</a>, <a href="{self.history_view_url}?'
            "filter=perf_5g_x0020_Test/FormatedTestName eq "
            "'ft425_simpleTraffic_1BM_1CC_10UE_1UEsched_TDD125_ABIL'\">Power BI history view</a>, "
            f'<a href="{self.kpi_url_2}">Timemarker KPI file</a>\n'
        )

        self.message_dict_with_links = {
            "Critical": "",
            "Major": (
                "<b>Min Cs1List Alarm:</b>\nWarning : "
                "TimeMarkerKPIv2_L2RT_<b>ft425_simpleTraffic_1CC_10UE_TDD125_ABIL</b>_"
                "2019.05.03_08.40.30_0751768.json :\n"
                "L2PSDL.cs1List.95p = 0.2 under minimum CS1 List"
                f" threshold 0.5.{self.pbi_links}"
            ),
            "Minor": (
                "<b>Marker Duration Alarm:</b>\nWarning : TimeMarkerKPIv2_L2RT_<b>"
                "ft425_simpleTraffic_1CC_10UE_TDD125_ABIL</b>_2019.05.03_08.40.30_0751768.json :"
                f"\nL2PSUL.max = 26.0 ns exceeds marker duration value 20 ns.{self.pbi_links}"
            ),
        }

        self.addCleanup(patch.stopall)

    def tearDown(self):
        os.remove(self.fixture["kpi_file"])
        os.remove(self.fixture["dest_perf_portal_json"])

    def get_dest_file(self, src_file, compress=False):
        json_pref = "json.xz" if compress else "json"
        return re.sub(
            ".json",
            f"_{TEST_DATE_STR}_{self.fixture['commit_7_hash']}.{json_pref}",
            os.path.basename(src_file),
        )

    def get_run_calls(self):
        dest_kpi = self.get_dest_file(self.fixture["kpi_file"])
        dest_snapshot_file = dest_kpi.replace("KPIv2", "Snapshot") + ".xz"
        run_call = dict()

        run_call["decodeSnapshot"] = call(
            [
                "timeMarker/tools/TimeMarkerKPI/script/launch.sh",
                "--gnbCommit",
                self.fixture["commit_full_hash"],
                "--kpiVersion",
                "2",
                "--maxCs1Scheduling",
                "--betaVersion",
                self.fixture["snapshot_file"],
            ],
            check=False,
            stdout=-1,
            stderr=-1,
            universal_newlines=True,
        )
        run_call["decodeSnapshot2"] = call(
            [
                "timeMarker/tools/TimeMarkerKPI/script/launch.sh",
                "--gnbCommit",
                self.fixture["commit_full_hash"],
                "--kpiVersion",
                "2",
                "--maxCs1Scheduling",
                "--betaVersion",
                self.fixture["snapshot_file"].replace("_0_0.json", "_1_0.json"),
            ],
            check=False,
            stdout=-1,
            stderr=-1,
            universal_newlines=True,
        )
        run_call["mkdir"] = call(
            ["ssh"] + self.ssh_options + [self.user_server, "mkdir", "-p", self.directory],
            **self.run_args,
        )
        run_call["scp_kpi"] = call(
            ["scp"]
            + self.ssh_options
            + [self.fixture["kpi_file"], f"{self.user_server}:{self.directory}/{dest_kpi}"],
            **self.run_args,
        )
        run_call["chmod_kpi"] = call(
            ["ssh"]
            + self.ssh_options
            + [self.user_server, "chmod", "-w", f"{self.directory}/{dest_kpi}"],
            **self.run_args,
        )
        run_call["scp_snapshot"] = call(
            ["scp"]
            + self.ssh_options
            + [
                f"{self.fixture['snapshot_file']}.xz",
                f"{self.user_server}:{self.directory}/{dest_snapshot_file}",
            ],
            **self.run_args,
        )
        run_call["chmod_snapshot"] = call(
            ["ssh"]
            + self.ssh_options
            + [self.user_server, "chmod", "-w", f"{self.directory}/{dest_snapshot_file}"],
            **self.run_args,
        )
        run_call["rm_xz_snapshot"] = call(
            ["rm", f"{self.fixture['snapshot_file']}.xz"], **self.run_args
        )

        self.run_args["shell"] = True

        run_call["xz_snapshot"] = call(
            f"cat {self.fixture['snapshot_file']} | xz --stdout > {self.fixture['snapshot_file']}.xz",
            **self.run_args,
        )
        return run_call

    def check_run_request(self, multiprocess=False):
        if multiprocess:
            self.mock["run"].assert_not_called()
        else:
            run_call = self.get_run_calls()
            self.mock["run"].assert_has_calls(
                [
                    run_call["decodeSnapshot"],
                    run_call["xz_snapshot"],
                    run_call["mkdir"],
                    run_call["scp_snapshot"],
                    run_call["chmod_snapshot"],
                    run_call["rm_xz_snapshot"],
                    run_call["mkdir"],
                    run_call["scp_kpi"],
                    run_call["chmod_kpi"],
                    run_call["decodeSnapshot2"],
                ]
            )
            self.assertEqual(self.mock["run"].call_count, 10)

    def insert_test_call(self):
        return call("Test", self.fixture["res_json_content"]["TableTest"][0]["data_4_db"])

    def check_insert_request(self, multiprocess=False):
        if multiprocess:
            self.mock["database_insert"].assert_not_called()
        else:
            insert_calls = [self.insert_test_call()]
            for key, table in [
                ("TableKpiLeadTime", "KpiLeadTime"),
                ("TableKpiProcessingTime", "KpiProcessingTime"),
                ("TableKpiValues", "KpiValues"),
                ("TableKpiProcessingTimePerEO", "KpiProcTimePerEO"),
                ("TableKpiMiddleware", "KpiMiddleware"),
            ]:
                for info in self.fixture["res_json_content"][key]:
                    info_dict = deepcopy(info["kpi_env"])
                    info_dict.update(info["kpi_data"])
                    for cpt_key in [2, 4, 5]:
                        if (
                            f"subComponent{cpt_key}" in info_dict
                            and info_dict[f"subComponent{cpt_key}"]
                        ):
                            info_dict[f"subComponent{cpt_key}"] = self.set_ventilated(
                                info_dict[f"subComponent{cpt_key}"]
                            )
                    if table == "KpiProcTimePerEO":
                        self.change_kpi_indexes_for_database_request(info_dict)
                        self.del_eo_l2_ps(info_dict)
                    if table == "KpiMiddleware":
                        self.change_kpi_indexes_for_database_request(info_dict)
                        del info_dict["maxMarker"]

                    insert_calls.append(call(table, info_dict))

            self.mock["database_insert"].assert_has_calls(insert_calls, any_order=True)
            self.assertEqual(self.mock["database_insert"].call_count, len(insert_calls))

    @staticmethod
    def set_ventilated(sub_component):
        return f"[{sub_component}]" if "SubcellInd" in sub_component else sub_component

    @staticmethod
    def change_kpi_indexes_for_database_request(kpi_dict):
        for key, new_key in [
            ("maxTime_MicroSec", "max"),
            ("95pTime_MicroSec", "95p"),
            ("avgTime_MicroSec", "avg"),
            ("minTime_MicroSec", "min"),
        ]:
            kpi_dict[new_key] = kpi_dict[key]
            del kpi_dict[key]

    @staticmethod
    def del_eo_l2_ps(kpi_dict):
        for cpt_key in range(1, 6):
            if kpi_dict[f"subComponent{cpt_key}"]:
                kpi_dict[f"subComponent{cpt_key}"] = kpi_dict[f"subComponent{cpt_key}"].replace(
                    "EO_L2_PS_", ""
                )

    def check_database_commit(self, multiprocess=False):
        if multiprocess:
            self.mock["database_commit"].assert_not_called()
        else:
            self.mock["database_commit"].assert_called_once_with()

    def common_with_2_same_kpi_file(self, multiprocess=False):
        self.maxDiff = None
        patch("os.cpu_count").start().return_value = 1

        # update perf_portal.json to have 2 Snapshot file same
        with open(self.fixture["dest_perf_portal_json"], "r") as f_h:
            perf_portal_content = json.load(f_h)
        perf_portal_content.append(deepcopy(perf_portal_content[0]))
        perf_portal_content[1]["timeMarkerSnapshotPath"] = perf_portal_content[1][
            "timeMarkerSnapshotPath"
        ].replace("_REF_0_0", "_REF_1_0")

        with open(self.fixture["dest_perf_portal_json"], "w") as f_h:
            json.dump(perf_portal_content, f_h)

        self.mock["glob_glob"].side_effect = [
            [self.fixture["kpi_file"]],
            [FileNotFoundError],
        ]

        args = [
            "perf_portal.py",
            "--dirKpi",
            "/tmp",
            "--testType",
            "ET",
            "--softwareCommit",
            self.fixture["commit_full_hash"],
        ]
        if not multiprocess:
            args.append("--noMultiProcess")

        with patch.dict(os.environ, self.fixture_os_environ):
            with patch.object(sys, "argv", args):
                spec = spec_from_file_location("__main__", "perf_portal.py")
                module = module_from_spec(spec)
                sys.modules["__main__"] = module
                spec.loader.exec_module(module)

        self.mock["gerrit_git_clone_time_marker"].assert_called_once_with()
        self.check_run_request(multiprocess=multiprocess)
        self.check_insert_request(multiprocess=multiprocess)
        self.check_database_commit(multiprocess=multiprocess)
        self.mock["rmtree"].assert_called_once_with("timeMarker/")

    def test_no_multiprocess_with_2_same_kpi_file(self):
        self.common_with_2_same_kpi_file(multiprocess=False)

    def test_multiprocess_with_2_same_kpi_file(self):
        self.common_with_2_same_kpi_file(multiprocess=True)
