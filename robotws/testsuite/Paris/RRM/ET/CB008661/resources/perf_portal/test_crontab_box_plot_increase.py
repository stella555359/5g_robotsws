import unittest
from unittest.mock import patch, call
import sys
import os
import shutil
from datetime import datetime, timedelta
import json
from importlib.util import spec_from_file_location, module_from_spec
from crontab_box_plot_increase import ROOT_DIR, DELTA_HOUR_TO_CHECK

TST_ROOT_DIR = os.path.abspath(os.path.dirname(__file__))

TEST_DATE_COMMIT_LIST = [
    {
        "extracted_fileKPI": "TimeMarkerKPIv2_L2RT_ft000_perfTestNSA_"
        "1CC_250UE_TDD125_ABIL_CFG_NSA_HARQ",
        "softwareBranch": "master",
        "softwareCommit": "9651fbf03505f6003bfd81cbde886995d7b928b4",
        "softwareCommitDate": datetime(2020, 7, 15, 14, 43, 56),
        "testDate": datetime(2020, 7, 15, 16, 29, 36),
        "id": 1372854,
    },
    {
        "extracted_fileKPI": "TimeMarkerKPIv2_L2RT_ft000_perfTestNSA_"
        "1CC_250UE_TDD125_ABIL_CFG_NSA_HARQ",
        "softwareBranch": "rel/5G20A2",
        "softwareCommit": "959efb42228d0320d6d23ebf19978651a304aa4e",
        "softwareCommitDate": datetime(2020, 7, 15, 15, 35, 8),
        "testDate": datetime(2020, 7, 15, 17, 22, 24),
        "id": 1373686,
    },
    {
        "extracted_fileKPI": "TimeMarkerKPIv2_L2RT_ft000_perfTestNSA_"
        "1CC_250UE_TDD125_ABIL_CFG_NSA_HARQ",
        "softwareBranch": "master",
        "softwareCommit": "a3076c2feeb3a09d8a39dd4d4f6b81a34a198aec",
        "softwareCommitDate": datetime(2020, 7, 15, 15, 38, 36),
        "testDate": datetime(2020, 7, 15, 17, 38, 27),
        "id": 1374377,
    },
]
LAST_REFRESH_DATE = datetime(2020, 7, 15, 10, 16, 0)
CURRENT_DATE_TIME = datetime.utcnow()


class TestCronBoxPlotCheck(unittest.TestCase):
    def setUp(self):
        self.mock = {}
        self.mock["report"] = patch("report.Report", autospec=True).start()
        self.mock["stdout"] = patch("sys.stdout.write").start()
        self.mock["stderr"] = patch("sys.stderr.write").start()
        self.mock["glob"] = patch("glob.glob", autospec=True).start()
        self.kpi_filename = os.path.sep.join(
            [
                TST_ROOT_DIR,
                "test_data/TimeMarkerKPIv2_L2RT_ft000_perfTestNSA_1CC_"
                "250UE_TDD125_ABIL_CFG_NSA_HARQ_COUNT_1_2019.05.03_08.40.31.json",
            ]
        )
        self.mock["glob"].return_value = [self.kpi_filename]
        shutil.copyfile(
            os.path.sep.join(
                [
                    TST_ROOT_DIR,
                    "test_data/TimeMarkerKPIv2_L2RT_ft425_simpleTraffic_1CC_"
                    "10UE_TDD125_ABIL_2019.05.03_08.40.31.json",
                ]
            ),
            self.kpi_filename,
        )

        self.compute_box_plot_return = "meanValue"
        self.mock["context"] = patch("context.Context", autospec=True).start()
        self.mock["context"].return_value.select_list_into_one_table.side_effect = (
            self.func_select_list_into_one_table
        )
        self.mock["context"].return_value.compute_boxplot_increase.return_value = (
            self.compute_box_plot_return
        )

        self.mock["datetime"] = patch("crontab.datetime").start()
        self.mock["datetime"].utcnow.return_value = CURRENT_DATE_TIME
        self.previous_commit_found = True
        self.test_date_commit_list = TEST_DATE_COMMIT_LIST

        # Last refresh date time request
        self.select_list_into_one_table_calls = [
            call(
                "CrontabLastRefresh",
                select_col=["lastRefreshDate"],
                where_dict={"=": {"action": "checkBoxPlotIncrease"}},
            )
        ]

        self.addCleanup(patch.stopall)

    def tearDown(self):
        os.remove(self.kpi_filename)

    def func_select_list_into_one_table(
        self,
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
        if table_name == "CrontabLastRefresh":
            return [{"lastRefreshDate": LAST_REFRESH_DATE}]
        if limit_result == 0:
            return self.test_date_commit_list
        if where_dict["="]["softwareBranch"] == "master":
            if not self.previous_commit_found:
                return []

            return [
                {
                    "softwareCommit": "myFistCommitMaster",
                    "softwareCommitDate": datetime(2020, 7, 10, 10, 10, 10),
                }
            ]
        return [
            {
                "softwareCommit": "myRelCommit",
                "softwareCommitDate": datetime(2020, 7, 1, 1, 1, 1),
            }
        ]

    def common_for_test(self, action=None, nb_exception=0):
        args = ["crontab_box_plot_inxcrease.py"]

        with patch.object(sys, "argv", args):
            spec = spec_from_file_location("__main__", "crontab_box_plot_increase.py")
            module = module_from_spec(spec)
            spec.loader.exec_module(module)

        # list new commit to check
        self.select_list_into_one_table_calls.append(
            call(
                "Test",
                select_col=[
                    "DISTINCT("
                    "SUBSTRING(fileKPI, 1, LOCATE(configKey, fileKPI)+LENGTH(configKey)-1))"
                    " as extracted_fileKPI",
                    "softwareBranch",
                    "softwareCommit",
                    "softwareCommitDate",
                    "MAX(testDate) as testDate",
                    "MAX(id) as id",
                ],
                where_dict={
                    "=": {"testType": "Endurance"},
                    ">": {
                        "softwareCommitDate": LAST_REFRESH_DATE
                        - timedelta(hours=DELTA_HOUR_TO_CHECK)
                    },
                    "<=": {
                        "softwareCommitDate": CURRENT_DATE_TIME
                        - timedelta(hours=DELTA_HOUR_TO_CHECK)
                    },
                },
                group_by_str="extracted_fileKPI, softwareBranch, "
                "softwareCommit, softwareCommitDate",
                order_list=["softwareBranch", "softwareCommitDate"],
                sort_order="ASC",
                limit_result=0,
            )
        )

        # Get previous hash_date
        for i in (0, 1):
            self.select_list_into_one_table_calls.append(
                call(
                    "Test",
                    select_col=["DISTINCT(softwareCommit) as softwareCommit", "softwareCommitDate"],
                    where_dict={
                        "=": {
                            "testType": "Endurance",
                            "softwareBranch": self.test_date_commit_list[i]["softwareBranch"],
                        },
                        "!=": {"softwareCommit": self.test_date_commit_list[i]["softwareCommit"]},
                        "<=": {
                            "softwareCommitDate": self.test_date_commit_list[i][
                                "softwareCommitDate"
                            ]
                        },
                        "like": {
                            "fileKPI": f"{self.test_date_commit_list[i]['extracted_fileKPI']}%"
                        },
                    },
                    order_list=["softwareCommitDate"],
                    limit_result=1,
                )
            )

        glob_list_call = []
        cpt = 0
        for test_date_commit in self.test_date_commit_list:
            if test_date_commit["softwareBranch"] == "master" and not self.previous_commit_found:
                continue

            cpt += 1
            glob_list_call.append(
                call(
                    os.path.sep.join(
                        [
                            ROOT_DIR,
                            test_date_commit["testDate"].strftime("%Y/%m/%d/%H.%M.%S"),
                            f"{test_date_commit['extracted_fileKPI']}_*",
                        ]
                    )
                )
            )
        self.mock["glob"].assert_has_calls(glob_list_call)
        self.assertEqual(self.mock["glob"].call_count, cpt)

        self.check_compute_box_plot_increase_calls(action)

        self.mock["context"].return_value.update_one_table.assert_called_once_with(
            "CrontabLastRefresh",
            set_dict={"lastRefreshDate": CURRENT_DATE_TIME},
            where_dict={"=": {"action": "checkBoxPlotIncrease"}},
        )
        self.mock["stderr"].assert_not_called()
        stdout_calls = [
            call(f"#############\nStart at {CURRENT_DATE_TIME} UTC \n"),
            call("\n"),
            call(
                f"Between {LAST_REFRESH_DATE - timedelta(hours=DELTA_HOUR_TO_CHECK)} to "
                f"{CURRENT_DATE_TIME - timedelta(hours=DELTA_HOUR_TO_CHECK)} UTC\n"
                f"{nb_exception} exception on 3 commit"
            ),
            call("\n"),
        ]
        self.mock["stdout"].assert_has_calls(stdout_calls)
        self.assertEqual(self.mock["stdout"].call_count, len(stdout_calls))

    def compute_test_info(self, idx, action=None):
        ref_value = None
        kpi_file = os.path.sep.join(
            [
                TST_ROOT_DIR,
                "test_data/TimeMarkerKPIv2_L2RT_ft425_simpleTraffic_"
                "1CC_10UE_TDD125_ABIL_2019.05.03_08.40.31.json",
            ]
        )
        with open(kpi_file, "r") as f_h:
            json_content = json.load(f_h)
        test_info = json_content["header"]["scriptParam"]

        test_info["id"] = self.test_date_commit_list[idx]["id"]
        test_info["softwareCommit"] = self.test_date_commit_list[idx]["softwareCommit"]
        test_info["formatted_test_name_like"] = (
            f"{self.test_date_commit_list[idx]['extracted_fileKPI']}%"
        )
        test_info["commitHashDate"] = (
            f"{self.test_date_commit_list[idx]['softwareCommit'][:7]} "
            f"{self.test_date_commit_list[idx]['softwareCommitDate']}"
        )

        if self.test_date_commit_list[idx]["softwareBranch"] == "master":
            if action != "previous_commit_not_found":
                if idx > 0:
                    ref_commit = self.test_date_commit_list[0]["softwareCommit"]
                    test_info["refCommitHashDate"] = (
                        f"{ref_commit[:7]} {self.test_date_commit_list[0]['softwareCommitDate']}"
                    )
                    ref_value = self.compute_box_plot_return
                else:
                    test_info["refCommitHashDate"] = f"myFistC {datetime(2020, 7, 10, 10, 10, 10)}"
                    ref_commit = "myFistCommitMaster"
            else:
                return None, None, None
        else:
            test_info["refCommitHashDate"] = f"myRelCo {datetime(2020, 7, 1, 1, 1, 1)}"
            ref_commit = "myRelCommit"

        return test_info, ref_commit, ref_value

    def check_compute_box_plot_increase_calls(self, action):
        # global TEST_DATE_COMMIT_LIST

        call_list = []
        if action != "file_not_found":
            for cpt in range(len(self.test_date_commit_list)):
                test_info, ref_commit, ref_value = self.compute_test_info(cpt, action)
                if test_info:
                    call_list.append(call(test_info, ref_commit, ref_value))

        self.mock["context"].return_value.compute_boxplot_increase.assert_has_calls(call_list)
        self.assertEqual(
            self.mock["context"].return_value.compute_boxplot_increase.call_count, len(call_list)
        )
        self.assertEqual(self.mock["context"].return_value.db_commit.call_count, len(call_list))

    def test_check_box_plot_ok(self):
        self.common_for_test()
        self.mock["report"].return_value.error.assert_not_called()
        self.mock["report"].return_value.alarm.assert_not_called()
        self.mock["context"].return_value.select_list_into_one_table.assert_has_calls(
            self.select_list_into_one_table_calls
        )

    def test_check_box_plot_file_not_found(self):
        self.mock["glob"].return_value = []
        self.common_for_test(action="file_not_found", nb_exception=3)
        self.mock["report"].return_value.alarm.assert_not_called()
        self.mock["context"].return_value.select_list_into_one_table.assert_has_calls(
            self.select_list_into_one_table_calls
        )
        self.assertEqual(
            self.mock["report"].return_value.error.call_count, len(self.test_date_commit_list)
        )

    def test_check_box_plot_db_except(self):
        self.mock["context"].return_value.select_list_into_one_table.side_effect = [ConnectionError]
        args = ["crontab_box_plot_inxcrease.py"]

        with patch.object(sys, "argv", args):
            spec = spec_from_file_location("__main__", "crontab_box_plot_increase.py")
            module = module_from_spec(spec)
            spec.loader.exec_module(module)
        self.mock["context"].return_value.select_list_into_one_table.assert_has_calls(
            self.select_list_into_one_table_calls
        )
        self.assertEqual(self.mock["context"].return_value.select_list_into_one_table.call_count, 2)
        self.mock["report"].return_value.error.assert_called_once_with()
        self.mock["stderr"].assert_not_called()
        self.mock["stdout"].assert_has_calls(
            [call(f"#############\nStart at {CURRENT_DATE_TIME} UTC \n"), call("\n")]
        )
        self.assertEqual(self.mock["stdout"].call_count, 2)

    def test_check_box_plot_previous_commit_not_found(self):
        self.previous_commit_found = False
        self.common_for_test(action="previous_commit_not_found", nb_exception=2)
        self.mock["report"].return_value.error.assert_has_calls([call(), call()])
        self.assertEqual(self.mock["report"].return_value.error.call_count, 2)
        self.mock["report"].return_value.alarm.assert_not_called()
