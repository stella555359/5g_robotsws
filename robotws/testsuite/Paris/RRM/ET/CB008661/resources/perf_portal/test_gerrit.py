import os
import sys
import subprocess
import unittest
from unittest.mock import patch, call

from gerrit import Gerrit


class Test(unittest.TestCase):
    @staticmethod
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
                "created": "2019-09-20 06:08:48.044000000",
                "updated": "2019-09-30 09:57:27.234000000",
                "submitted": "2019-09-30 09:35:45.346000000",
                "insertions": 378,
                "deletions": 103,
                "unresolved_comment_count": 0,
                "_number": 1384267,
                "owner": {"_account_id": 1016103},
            }
        ]

        ret = None
        if "changes/1185271" in args[0]:
            ret = change_return
        elif "changes/?q=commit:990b6b352c682807e691fc6b7f02c1319fa55125" in args[0]:
            ret = commit_return
        elif "changes/1185272" in args[0]:
            change_return["parents"][0]["commit"] = "990b6b352c682807e691fc6b7f02c1319fa55126"
            ret = change_return
        elif "changes/?q=commit:990b6b352c682807e691fc6b7f02c1319fa55126" in args[0]:
            del commit_return[0]["submitted"]
            print(f"commit_return = [{commit_return}]")
            ret = commit_return
        elif "changes/?q=commit:990b6b352c682807e691fc6b7f02c1319fa55127" in args[0]:
            del commit_return[0]["submitted"]
            del commit_return[0]["updated"]
            ret = commit_return
        elif "changes/?q=commit:990b6b352c682807e691fc6b7f02c1319fa55128" in args[0]:
            ret = []
        elif "changes/?q=commit:990b6b352c682807e691fc6b7f02c1319fa55129" in args[0]:
            raise SystemError("Gerrit connection timeout")
        elif "projects/MN" in args[0]:
            ret = {"revision": "a42f90ae4fc9bf1d25a80f93ae2be84f855a4667"}

        if ret is None:
            raise SystemError("except for test")
        return ret

    def setUp(self):
        self.env_values = {
            "ZUUL_CHANGE": "1185271",
            "ZUUL_PATCHSET": "5",
            "ZUUL_PIPELINE": "check",
            "BUILD_URL": "https://ece-ci.dynamic.nsn"
            + "-net.net/job/MASTER/job/GNB/job/L2-PS/"
            + "job/SCT.wip.abil/1123/",
            "GIT_HOME": "/opt/git/version",
        }

        with patch.dict("os.environ", values=self.env_values):
            self.mock = {}
            self.mock["gerrit_api_rest_set_message"] = patch(
                "gerrit_api_rest.GerritReview.set_message"
            ).start()
            self.mock["gerrit_api_rest_label"] = patch(
                "gerrit_api_rest.GerritReview.add_labels"
            ).start()
            self.mock["gerrit_api_rest_get"] = patch("gerrit_api_rest.GerritRestAPI.get").start()
            self.mock["gerrit_api_rest_review"] = patch(
                "gerrit_api_rest.GerritRestAPI.review"
            ).start()
            self.mock["stdout"] = patch("sys.stdout.write").start()

            self.mock["gerrit_api_rest_get"].side_effect = self.gerrit_rest_get_side_effect

            self.mock["run"] = patch("subprocess.run", autospec=True).start()
            self.mock["run"].return_value.returncode = 0

            self.gerrit = Gerrit()
            self.mock["gerrit_api_rest_get"].assert_has_calls(
                [
                    call("changes/1185271/revisions/5/commit"),
                    call("changes/?q=commit:990b6b352c682807e691fc6b7f02c1319fa55125"),
                ],
                any_order=False,
            )
            self.assertEqual(self.gerrit.parent_commit_date, "2019-09-30 09:35:45.346000000")

            self.addCleanup(patch.stopall)

    def run_assert_once_with(self, git_bin):
        git_destination = "gerrit.ext.net.nokia.com:29418"
        git_option = f"clone --depth=1 ssh://{git_destination}/MN/5G/COMMON/timeMarker"
        self.mock["run"].assert_called_once_with(
            f"{git_bin} {git_option}",
            check=False,
            shell=True,
            stderr=subprocess.PIPE,
            stdout=sys.stderr.buffer,
            universal_newlines=True,
        )

    def test_check_project_no_allowed_or_no_exists(self):
        with patch.dict("os.environ", values=self.env_values):
            self.mock["gerrit_api_rest_review"].assert_not_called()

    def test_check_product_no_allowed_or_no_exists(self):
        with patch.dict("os.environ", values=self.env_values):
            self.mock["gerrit_api_rest_review"].assert_not_called()
        self.gerrit = None

    def test_send_comments_pipeline_is_check(self):
        message = "test message"
        self.gerrit.send_comments(message)
        self.mock["gerrit_api_rest_set_message"].assert_called_once_with(message)
        self.mock["gerrit_api_rest_label"].assert_called_once_with({"Code-Review": -1})
        self.mock["gerrit_api_rest_review"].assert_called_once_with(
            self.env_values["ZUUL_CHANGE"], self.env_values["ZUUL_PATCHSET"], self.gerrit.review
        )

    def test_send_comments_pipeline_is_post(self):
        message = "test message"
        self.env_values["ZUUL_PIPELINE"] = "post"
        with patch.dict("os.environ", values=self.env_values):
            self.gerrit.send_comments(message)
            self.mock["gerrit_api_rest_set_message"].assert_called_once_with(message)
            self.mock["gerrit_api_rest_label"].assert_not_called()
            self.mock["gerrit_api_rest_review"].assert_called_once_with(
                self.env_values["ZUUL_CHANGE"], self.env_values["ZUUL_PATCHSET"], self.gerrit.review
            )

    def test_gerrit_get_except_parent_not_merged(self):
        self.env_values["ZUUL_CHANGE"] = "1185272"
        with patch.dict("os.environ", values=self.env_values):
            self.gerrit = Gerrit()
        self.mock["gerrit_api_rest_get"].assert_has_calls(
            [
                call("changes/1185272/revisions/5/commit"),
                call("changes/?q=commit:990b6b352c682807e691fc6b7f02c1319fa55126"),
            ],
            any_order=False,
        )
        self.assertIsNone(self.gerrit.parent_commit_date)

    def test_gerrit_get_exception(self):
        self.env_values["ZUUL_CHANGE"] = "1185273"
        with patch.dict("os.environ", values=self.env_values):
            self.gerrit = Gerrit()
        self.mock["gerrit_api_rest_get"].assert_has_calls(
            [call("changes/1185273/revisions/5/commit")]
        )
        self.assertEqual(self.mock["gerrit_api_rest_get"].call_count, 3)
        self.assertIsNone(self.gerrit.parent_commit_date)

    def test_get_commit_date_ok(self):
        commit_name = "990b6b352c682807e691fc6b7f02c1319fa55125"
        self.assertEqual(self.gerrit.get_commit_date(commit_name), "2019-09-30 09:35:45")
        commit_name = "990b6b352c682807e691fc6b7f02c1319fa55126"
        self.assertEqual(self.gerrit.get_commit_date(commit_name), "2019-09-30 09:57:27")
        commit_name = "990b6b352c682807e691fc6b7f02c1319fa55127"
        self.assertEqual(self.gerrit.get_commit_date(commit_name), "2019-09-20 06:08:48")
        commit_name = "990b6b352c682807e691fc6b7f02c1319fa55128"
        self.assertRaises(ValueError, self.gerrit.get_commit_date, commit_name)
        commit_name = "990b6b352c682807e691fc6b7f02c1319fa55129"
        self.assertRaises(SystemError, self.gerrit.get_commit_date, commit_name)

    def test_git_clone_time_marker_default(self):
        with patch.dict("os.environ", values=self.env_values):
            del os.environ["GIT_HOME"]
            self.gerrit.git_clone_time_marker()
        self.mock["run"].assert_called_once()
        self.run_assert_once_with("git")

    def test_git_clone_time_marker_ok(self):
        with patch.dict("os.environ", values=self.env_values):
            self.gerrit.git_clone_time_marker()
        self.mock["run"].assert_called_once()
        self.run_assert_once_with("/opt/git/version/bin/git")

    def test_git_clone_time_marker_nok(self):
        self.mock["run"].return_value.returncode = 1
        self.mock["run"].return_value.stderr = "GIT ERROR MESSAGE ON STDERR"
        error_message = "git clone timeMarker message is: "
        self.assertRaisesRegex(
            SystemError,
            error_message,
            self.gerrit.git_clone_time_marker,
        )

    def test_get_perf_portal_commit(self):
        self.assertEqual(
            self.gerrit.get_perf_portal_commit(), "a42f90ae4fc9bf1d25a80f93ae2be84f855a4667"
        )
        self.mock["gerrit_api_rest_get"].side_effect = [SystemError]
        self.assertIsNone(self.gerrit.get_perf_portal_commit())
