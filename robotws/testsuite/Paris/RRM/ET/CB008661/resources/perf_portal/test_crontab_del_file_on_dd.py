import sys
import unittest
from unittest.mock import patch, call
from datetime import datetime, timedelta
from importlib.util import spec_from_file_location, module_from_spec
from crontab_del_file_on_dd import ROOT_DIR, DELTA_WEEKS_TO_CHECK

CURRENT_DATE_TIME = datetime.utcnow() - timedelta(days=20)
LAST_REFRESH_DATE = datetime(2020, 7, 15, 10, 16, 0)
FILE_CHROME_TRACING_LIST = [
    {
        "id": 10,
        "testDate": datetime(2020, 12, 30, 7, 16, 2),
        "fileChromeTracing": "ChromeTracingSnapshot_L2RT_simpleTraffic.json.xz",
        "filePath": f"{ROOT_DIR}/2020/12/30/07.16.02/"
        "ChromeTracingSnapshot_L2RT_simpleTraffic.json.xz",
        "except": True,
    },
    {
        "id": 13,
        "testDate": datetime(2020, 12, 30, 8, 24, 18),
        "fileChromeTracing": "ChromeTracingSnapshot_L2RT_FuseTraffic.json.xz",
        "filePath": f"{ROOT_DIR}/2020/12/30/08.24.18/"
        "ChromeTracingSnapshot_L2RT_FuseTraffic.json.xz",
        "except": False,
    },
]


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
    if table_name == "CrontabLastRefresh":
        return [{"lastRefreshDate": LAST_REFRESH_DATE}]
    return FILE_CHROME_TRACING_LIST


class TestCronDelFileOnDD(unittest.TestCase):
    def setUp(self):
        self.mock = {}
        self.mock["report"] = patch("report.Report", autospec=True).start()
        self.mock["stdout"] = patch("sys.stdout.write").start()
        self.mock["stderr"] = patch("sys.stderr.write").start()
        self.mock["context"] = patch("context.Context", autospec=True).start()
        self.mock["context"].return_value.select_list_into_one_table.side_effect = (
            func_select_list_into_one_table
        )

        self.mock["datetime"] = patch("crontab.datetime").start()
        self.mock["datetime"].utcnow.return_value = CURRENT_DATE_TIME

        self.mock["os_remove"] = patch("os.remove").start()

        self.fixture_select_list_into_one_table_calls = [
            call(
                "CrontabLastRefresh",
                select_col=["lastRefreshDate"],
                where_dict={"=": {"action": "checkDelFileOnDD"}},
            ),
            call(
                "Test",
                select_col=["id", "testDate", "fileChromeTracing"],
                where_dict={
                    "!=": {"testType": "Endurance", "fileChromeTracing": None},
                    ">": {
                        "softwareCommitDate": LAST_REFRESH_DATE
                        - timedelta(weeks=DELTA_WEEKS_TO_CHECK)
                    },
                    "<=": {
                        "softwareCommitDate": CURRENT_DATE_TIME
                        - timedelta(weeks=DELTA_WEEKS_TO_CHECK)
                    },
                },
                limit_result=0,
            ),
        ]

        self.fixture_os_remove_calls = []
        self.fixture_update_db_calls = []
        self.fixture_os_remove_side_effect = []

        self.compute_os_remove_and_update_db_calls()

        self.mock["os_remove"].side_effect = self.fixture_os_remove_side_effect

        self.addCleanup(patch.stopall)

    def compute_os_remove_and_update_db_calls(self):
        for chrome_file_info in FILE_CHROME_TRACING_LIST:
            self.fixture_os_remove_calls.append(call(chrome_file_info["filePath"]))
            if not chrome_file_info["except"]:
                self.fixture_update_db_calls.append(
                    call("Test", {"fileChromeTracing": None}, {"=": {"id": chrome_file_info["id"]}})
                )
                self.fixture_os_remove_side_effect.append(True)
            else:
                self.fixture_os_remove_side_effect.append(FileNotFoundError)

        self.fixture_update_db_calls.append(
            call(
                "CrontabLastRefresh",
                set_dict={"lastRefreshDate": CURRENT_DATE_TIME},
                where_dict={"=": {"action": "checkDelFileOnDD"}},
            )
        )

    def test_del_file_on_dd_ok(self):
        args = ["crontab_del_file_on_dd.py"]
        with patch.object(sys, "argv", args):
            spec = spec_from_file_location("__main__", "crontab_del_file_on_dd.py")
            module = module_from_spec(spec)
            spec.loader.exec_module(module)

        self.mock["context"].assert_called_once_with(
            check_threshold=False,
            insert_into_db=True,
            multiprocess=False,
            send_gerrit_comment=False,
            zuul_branch="master",
        )

        self.mock["context"].return_value.select_list_into_one_table.assert_has_calls(
            self.fixture_select_list_into_one_table_calls
        )
        self.assertEqual(
            len(self.fixture_select_list_into_one_table_calls),
            self.mock["context"].return_value.select_list_into_one_table.call_count,
        )

        self.mock["os_remove"].assert_has_calls(self.fixture_os_remove_calls)
        self.assertEqual(len(self.fixture_os_remove_calls), self.mock["os_remove"].call_count)

        self.mock["context"].return_value.update_one_table.assert_has_calls(
            self.fixture_update_db_calls
        )
        self.assertEqual(
            len(self.fixture_update_db_calls),
            self.mock["context"].return_value.update_one_table.call_count,
        )
        self.mock["report"].return_value.error.assert_not_called()
        self.mock["context"].return_value.db_commit.assert_called_once_with()

    def test_db_access_except(self):
        self.mock["context"].return_value.select_list_into_one_table.side_effect = ConnectionError

        args = ["crontab_del_file_on_dd.py"]
        with patch.object(sys, "argv", args):
            spec = spec_from_file_location("__main__", "crontab_del_file_on_dd.py")
            module = module_from_spec(spec)
            spec.loader.exec_module(module)

        self.mock["context"].assert_called_once_with(
            check_threshold=False,
            insert_into_db=True,
            multiprocess=False,
            send_gerrit_comment=False,
            zuul_branch="master",
        )

        self.mock["context"].return_value.select_list_into_one_table.assert_has_calls(
            [self.fixture_select_list_into_one_table_calls[0]]
        )
        self.assertEqual(self.mock["context"].return_value.select_list_into_one_table.call_count, 2)

        self.mock["os_remove"].assert_not_called()
        self.mock["context"].return_value.update_one_table.assert_not_called()
        self.mock["context"].return_value.db_commit.assert_not_called()
        self.mock["report"].return_value.error.assert_called_once_with()
