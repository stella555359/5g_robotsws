import os
import sys
import unittest
from unittest.mock import patch, call
import traceback
import report


def get_email_address(email_type):
    return f"i_mn_5gsc_sw_eng_perf_portal_{email_type}@groups.nokia.com"


def get_email_subject(subject_type):
    return f"{subject_type.title()} provided by {os.path.basename(sys.argv[0])}"


class TestReport(unittest.TestCase):
    def setUp(self):
        self.gerrit_url = "https://gerrit.ext.net.nokia.com/gerrit/#/c/1185271/5"
        self.jenkins = (
            "https://ece-ci.dynamic.nsn-net.net/job/MASTER/job/GNB/job/UPLANE/"
            "job/L2-PS/job/SCT.wip.abil/1123/"
        )
        self.threshold_url = (
            "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/UPLANE/"
            "ci-scripts.git;a=blob;hb=HEAD;f=perf_portal/threshold/threshold_scheduler.json"
        )
        self.message = {
            "Critical": "My Critical message\nOn different lines",
            "Major": "My Major message",
            "Minor": "My Minor message \nOn different lines",
        }
        self.environ = {"ZUUL_CHANGE": "1185271", "ZUUL_PATCHSET": "5", "BUILD_URL": self.jenkins}

        self.mock = {}
        self.mock["email"] = patch("send_email.Email", autospec=True).start()
        self.mock["instance_email"] = self.mock["email"].return_value
        self.mock["stderr"] = patch("sys.stderr.write").start()
        self.mock["stdout"] = patch("sys.stdout.write").start()
        self.addCleanup(patch.stopall)

    def assert_mock_stderr_calls(self, check_str):
        calls = [call(check_str), call("\n")]
        self.mock["stderr"].assert_has_calls(calls)
        self.assertEqual(self.mock["stderr"].call_count, len(calls))

    def test_given_alarm_when_report_alarm_then_send_email(self):
        with patch.dict("os.environ", values=self.environ):
            report.Report().alarm(self.message, "threshold_scheduler.json")

        body = (
            f"Gerrit link: <a href='{self.gerrit_url}'>{self.gerrit_url}</a>\n"
            f"Job: <a href='{self.jenkins}'>{self.jenkins}</a>\n"
            f"Threshold file used as reference : <a href='{self.threshold_url}'>"
            f"{self.threshold_url}</a>\n\n<b>Critical alarms:</b>\n\n"
            f"{self.message['Critical']}\n"
        )

        self.mock["instance_email"].send.assert_called_once_with(
            get_email_address("alarm"), get_email_subject("alarm"), body
        )

        body += (
            f'\n<b>Major alarms:</b>\n\n{self.message["Major"]}\n'
            + f'\n<b>Minor alarms:</b>\n\n{self.message["Minor"]}\n'
        )

        self.assert_mock_stderr_calls(f"{get_email_subject('alarm')}\n{body}")
        self.mock["stdout"].assert_not_called()

    def test_given_alarm_no_minor_no_major_when_report_alarm_then_send_email(self):
        del self.message["Major"]
        del self.message["Minor"]
        with patch.dict("os.environ", values=self.environ):
            report.Report().alarm(self.message, "threshold_scheduler.json")

        body = (
            f"Gerrit link: <a href='{self.gerrit_url}'>{self.gerrit_url}</a>\n"
            f"Job: <a href='{self.jenkins}'>{self.jenkins}</a>\n"
            f"Threshold file used as reference : <a href='{self.threshold_url}'>"
            f"{self.threshold_url}</a>\n\n<b>Critical alarms:</b>\n\n"
            f"{self.message['Critical']}\n"
        )

        self.mock["instance_email"].send.assert_called_once_with(
            get_email_address("alarm"), get_email_subject("alarm"), body
        )
        self.assert_mock_stderr_calls(f"{get_email_subject('alarm')}\n{body}")
        self.mock["stdout"].assert_not_called()

    def test_given_alarm_only_minor_when_report_alarm_then_not_send_email_nor_gerrit_comment(self):
        del self.message["Critical"]
        del self.message["Major"]
        with patch.dict("os.environ", values=self.environ):
            gerrit_message = report.Report().alarm(self.message, "threshold_scheduler.json")

        body = (
            f"Gerrit link: <a href='{self.gerrit_url}'>{self.gerrit_url}</a>\n"
            f"Job: <a href='{self.jenkins}'>{self.jenkins}</a>\n"
            f"Threshold file used as reference : <a href='{self.threshold_url}'>"
            f"{self.threshold_url}</a>\n\n<b>Minor alarms:</b>\n\n{self.message['Minor']}\n"
        )

        self.mock["instance_email"].send.assert_not_called()
        self.assert_mock_stderr_calls(f"{get_email_subject('alarm')}\n{body}")
        self.assertFalse(gerrit_message)
        self.mock["stdout"].assert_not_called()

    def test_given_alarm_only_major_when_report_alarm_then_not_send_email_nor_gerrit_comment(self):
        del self.message["Critical"]
        del self.message["Minor"]
        with patch.dict("os.environ", values=self.environ):
            gerrit_message = report.Report().alarm(self.message, "threshold_scheduler.json")

        body = (
            f"Gerrit link: <a href='{self.gerrit_url}'>{self.gerrit_url}</a>\n"
            f"Job: <a href='{self.jenkins}'>{self.jenkins}</a>\n"
            f"Threshold file used as reference : <a href='{self.threshold_url}'>"
            f"{self.threshold_url}</a>\n\n<b>Major alarms:</b>\n\n{self.message['Major']}\n"
        )

        self.mock["instance_email"].send.assert_not_called()
        self.assert_mock_stderr_calls(f"{get_email_subject('alarm')}\n{body}")
        self.assertFalse(gerrit_message)
        self.mock["stdout"].assert_not_called()

    def test_given_alarm_no_critical_when_report_alarm_then_not_send_email_nor_gerrit_comment(self):
        del self.message["Critical"]
        with patch.dict("os.environ", values=self.environ):
            gerrit_message = report.Report().alarm(self.message, "threshold_scheduler.json")

        body = (
            f"Gerrit link: <a href='{self.gerrit_url}'>{self.gerrit_url}</a>\n"
            f"Job: <a href='{self.jenkins}'>{self.jenkins}</a>\n"
            f"Threshold file used as reference : <a href='{self.threshold_url}'>"
            f"{self.threshold_url}</a>\n\n<b>Major alarms:</b>\n\n{self.message['Major']}\n"
            f"\n<b>Minor alarms:</b>\n\n{self.message['Minor']}\n"
        )

        self.mock["instance_email"].send.assert_not_called()
        self.assert_mock_stderr_calls(f"{get_email_subject('alarm')}\n{body}")
        self.assertFalse(gerrit_message)
        self.mock["stdout"].assert_not_called()

    def test_given_error_when_report_error_then_send_email(self):
        with patch.dict("os.environ", values=self.environ):
            report.Report().error(self.message)

        body = (
            f"Gerrit link: <a href='{self.gerrit_url}'>{self.gerrit_url}</a>\n"
            f"Job: <a href='{self.jenkins}'>{self.jenkins}</a>\n\n"
            f"{traceback.format_exc()}\n{self.message}"
        )
        self.mock["instance_email"].send.assert_called_once_with(
            get_email_address("error"), get_email_subject("error"), body
        )
        self.assert_mock_stderr_calls(f"{get_email_subject('error')}\n{body}")
        self.mock["stdout"].assert_not_called()

    def test_not_send_email_with_undefined_job_and_link_when_build_url_and_zuul_change_not_defined(
        self,
    ):
        with patch.dict("os.environ", values=self.environ):
            del os.environ["BUILD_URL"]
            del os.environ["ZUUL_CHANGE"]
            os.environ["PERF_PORTAL_DEV_MODE"] = "True"
            gerrit_message = report.Report().alarm(self.message, "threshold_scheduler.json")

        body_mail = (
            f"Gerrit link: Undefined ZUUL_CHANGE variable\n"
            f"Job: Undefined BUILD_URL variable\n"
            f"Threshold file used as reference : <a href='{self.threshold_url}'>"
            f"{self.threshold_url}</a>\n"
            f'\n<b>Critical alarms:</b>\n\n{self.message["Critical"]}\n'
        )

        body = (
            body_mail
            + f'\n<b>Major alarms:</b>\n\n{self.message["Major"]}\n'
            + f'\n<b>Minor alarms:</b>\n\n{self.message["Minor"]}\n'
        )

        self.mock["instance_email"].send.assert_not_called()
        self.assert_mock_stderr_calls(f"{get_email_subject('alarm')}\n{body}")
        self.assertFalse(gerrit_message)
        self.mock["stdout"].assert_not_called()

        with patch.dict("os.environ", values=self.environ):
            del os.environ["BUILD_URL"]
            del os.environ["ZUUL_CHANGE"]
            os.environ["PERF_PORTAL_DEV_MODE"] = "False"
            report.Report().alarm(self.message, "threshold_scheduler.json")
        self.mock["instance_email"].send.assert_not_called()

    def test_given_job_with_no_zuul_change_only_then_send_email(self):
        del self.message["Major"]
        with patch.dict("os.environ", values=self.environ):
            del os.environ["ZUUL_CHANGE"]
            gerrit_message = report.Report().alarm(self.message, "threshold_scheduler.json")

        body_mail = (
            f"Gerrit link: Undefined ZUUL_CHANGE variable\n"
            f"Job: <a href='{self.jenkins}'>{self.jenkins}</a>\n"
            f"Threshold file used as reference : <a href='{self.threshold_url}'>"
            f"{self.threshold_url}</a>\n"
        )

        body_mail += f'\n<b>Critical alarms:</b>\n\n{self.message["Critical"]}\n'
        body_stderr = body_mail + f'\n<b>Minor alarms:</b>\n\n{self.message["Minor"]}\n'

        expected_gerrit_message = (
            f"Alarm(s):\n{self.message['Critical']}\n\n"
            f"- Job: {self.jenkins}\n"
            f"- Threshold file used as reference: {self.threshold_url}\n"
            "- Support: I_NPS_SQUAD14_RAVEL@internal.nsn.com"
        )

        self.mock["instance_email"].send.assert_called_once_with(
            get_email_address("alarm"), get_email_subject("alarm"), body_mail
        )
        self.assert_mock_stderr_calls(f"{get_email_subject('alarm')}\n{body_stderr}")
        self.mock["stdout"].assert_not_called()
        self.assertEqual(gerrit_message, expected_gerrit_message)

    def test_when_send_email_exception_then_no_exit(self):
        self.message = {
            "Critical": "My <b>Critical</b> message\n<a href='url'>with link</a>",
            "Major": "My Major message",
            "Minor": "My Minor message \nOn different lines",
        }
        with patch.dict("os.environ", values=self.environ):
            self.mock["email"].return_value.send.side_effect = Exception
            gerrit_message = report.Report().alarm(self.message, "threshold_scheduler.json")

            body = (
                f"Gerrit link: <a href='{self.gerrit_url}'>{self.gerrit_url}</a>\n"
                f"Job: <a href='{self.jenkins}'>{self.jenkins}</a>\nThreshold file "
                f"used as reference : <a href='{self.threshold_url}'>{self.threshold_url}</a>\n\n"
                f"<b>Critical alarms:</b>\n\n{self.message['Critical']}\n"
            )

            expected_gerrit_message = (
                f"Alarm(s):\nMy Critical message\n\n\n"
                f"- Job: {self.jenkins}\n"
                f"- Threshold file used as reference: {self.threshold_url}\n"
                "- Support: I_NPS_SQUAD14_RAVEL@internal.nsn.com"
            )

            self.mock["instance_email"].send.assert_called_once_with(
                get_email_address("alarm"), get_email_subject("alarm"), body
            )
            self.assertEqual(gerrit_message, expected_gerrit_message)

            body += (
                f'\n<b>Major alarms:</b>\n\n{self.message["Major"]}\n'
                + f'\n<b>Minor alarms:</b>\n\n{self.message["Minor"]}\n'
            )

            self.assert_mock_stderr_calls(f"{get_email_subject('alarm')}\n{body}")
            self.mock["stdout"].assert_has_calls([call("Warning: email not sent"), call("\n")])
