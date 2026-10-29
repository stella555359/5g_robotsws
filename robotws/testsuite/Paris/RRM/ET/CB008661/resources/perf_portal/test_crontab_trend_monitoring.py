import os
import unittest
import json
from unittest.mock import patch, call
from importlib.util import spec_from_file_location, module_from_spec
from datetime import datetime, timedelta

NB_SELECT_LAST_TIME = 1
NB_SELECT_NEW_COMMIT = 1
NB_SELECT_RELATED_COMMIT = 1
NB_FIND_RELATED = 18


class TestTrendMonitoring(unittest.TestCase):
    @staticmethod
    def compute_previous_commit_list(commit_date):
        date_idx = int(commit_date.replace("D", "")) - 5
        commit_list = []
        for idx in range(0, 6):
            commit_list.append(
                {"softwareCommit": f"C{date_idx + idx}", "softwareCommitDate": f"D{date_idx + idx}"}
            )
        return commit_list

    def compute_next_commit_list(self, commit_date):
        date_idx = int(commit_date.replace("D", ""))
        commit_list = []
        for idx in range(date_idx + 1, date_idx + 6):
            if idx <= self.result_expected_content["InputMaxCommitIdx"]:
                commit_list.append({"softwareCommit": f"C{idx}", "softwareCommitDate": f"D{idx}"})
        return commit_list

    def select_list_into_one_table(self, *args, **opt):
        if args[0] == "Test":
            if opt["limit_result"] == 0:
                return self.result_expected_content["InputCommitCreated"]
            if opt["limit_result"] == 5:
                return self.compute_next_commit_list(opt["where_dict"][">"]["softwareCommitDate"])
            if opt["limit_result"] == 6:
                return self.compute_previous_commit_list(
                    opt["where_dict"]["<="]["softwareCommitDate"]
                )

        if args[0] == "RelatedCommit":
            return self.result_expected_content["InputCommitAlreadyIntoRelatedtable"]

    def setUp(self):
        self.current_datetime = datetime(2022, 1, 1, 0, 0, 0, 0)
        self.default_time_delta = timedelta(weeks=2)

        result_expected_file = (
            f"{os.path.dirname(__file__)}/test_data/"
            f"crontab_trend_monitoring_result_expected.json"
        )
        with open(result_expected_file, "r") as f_h:
            self.result_expected_content = json.load(f_h)

        self.mock = {
            "datetime": patch("datetime.datetime", autospec=True).start(),
            "context": patch("context.Context", autospec=True).start(),
            "tableRelated": patch(
                "database_table_object.TableRelatedCommit", autospec=True
            ).start(),
            "report": patch("report.Report", autospec=True).start(),
        }

        self.mock["datetime"].utcnow.return_value = self.current_datetime
        self.mock["context"].return_value.select_list_into_one_table.side_effect = (
            self.select_list_into_one_table
        )

        self.addCleanup(patch.stopall)

    def compute_related_commit_instance_list(self):
        call_list = []
        for commit_info in self.result_expected_content["TableRelatedCommitList"]:
            for idx in range(commit_info["firstRelatedIdx"], commit_info["lastRelatedIdx"] + 1):
                call_list.append(
                    call(
                        self.mock["context"].return_value,
                        "master",
                        f"C{commit_info['softwareCommitIdx']}",
                        f"D{commit_info['softwareCommitIdx']}",
                        f"C{idx}",
                    )
                )
        return call_list

    def common_init(self):
        spec = spec_from_file_location("__main__", "crontab_trend_monitoring.py")
        module = module_from_spec(spec)
        spec.loader.exec_module(module)

        self.mock["context"].assert_called_once_with(
            zuul_branch="master",
            check_threshold=False,
            insert_into_db=True,
            send_gerrit_comment=False,
            multiprocess=False,
        )

    def test_init_ok(self):
        self.common_init()
        self.mock["report"].return_value.error.assert_not_called()
        self.mock["context"].return_value.delete_into_db.assert_called_once()
        nb_select = (
            NB_SELECT_LAST_TIME
            + NB_SELECT_NEW_COMMIT
            + NB_SELECT_RELATED_COMMIT
            + 2 * NB_FIND_RELATED
        )
        self.assertEqual(
            self.mock["context"].return_value.select_list_into_one_table.call_count, nb_select
        )
        self.mock["context"].return_value.db_commit.assert_called_once_with()
        self.mock["tableRelated"].assert_has_calls(
            self.compute_related_commit_instance_list(), any_order=True
        )

    def test_no_new_commit(self):
        self.mock["context"].return_value.select_list_into_one_table.side_effect = (
            lambda *args, **opt: []
        )
        self.common_init()

        self.mock["context"].return_value.db_commit.assert_called_once_with()
        self.mock["tableRelated"].assert_not_called()
        self.mock["report"].return_value.error.assert_not_called()
        self.mock["context"].return_value.delete_into_db.assert_not_called()

    def test_main_except_and_send_error(self):
        self.mock["context"].return_value.select_list_into_one_table.side_effect = ConnectionError
        self.common_init()

        self.mock["report"].return_value.error.assert_called_once_with()
        self.mock["context"].return_value.delete_into_db.assert_not_called()
        nb_select = NB_SELECT_LAST_TIME + NB_SELECT_NEW_COMMIT
        self.assertEqual(
            self.mock["context"].return_value.select_list_into_one_table.call_count, nb_select
        )
        self.mock["context"].return_value.db_commit.assert_not_called()
        self.mock["tableRelated"].assert_not_called()
