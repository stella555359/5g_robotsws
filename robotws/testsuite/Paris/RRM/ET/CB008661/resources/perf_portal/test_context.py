import unittest
import json
import os
from unittest.mock import patch, call
import context


def set_threshold_cpu_increase_messages(context):
    context.cpu_increase_perc_message = {
        "Critical": "\nWarning Critical CPU increase PERC message",
        "Major": "",
        "Minor": "",
    }
    context.cpu_increase_abs_message = {
        "Critical": "\nWarning Critical CPU increase ABS message",
        "Major": "",
        "Minor": "",
    }
    context.threshold_message = {
        "Critical": "\nWarning Critical threshold message",
        "Major": "\nWarning Major threshold message",
        "Minor": "",
    }
    message_dict = {
        "Critical": f"<b>Threshold Alarm:</b>{context.threshold_message['Critical']}"
        f"\n\n<b>CPU Increase PERC Alarm:</b>{context.cpu_increase_perc_message['Critical']}"
        f"\n\n<b>CPU Increase ABS Alarm:</b>{context.cpu_increase_abs_message['Critical']}",
        "Major": f"<b>Threshold Alarm:</b>{context.threshold_message['Major']}",
    }

    return message_dict


class Test(unittest.TestCase):
    def setUp(self):

        self.mock = {
            "database": patch("context.Database", autospec=True).start(),
            "threshold": patch("context.Threshold", autospec=True).start(),
            "under_threshold": patch("context.UnderThreshold", autospec=True).start(),
            "cpu_increase_perc": patch("context.CPUIncreasePercent", autospec=True).start(),
            "cpu_increase_abs": patch("context.CPUIncreaseAbsolute", autospec=True).start(),
            "boxplot_increase": patch("context.BoxPlotIncrease", autospec=True).start(),
            "stdout": patch("sys.stdout.write", autospec=True).start(),
            "report": patch("context.Report", autospec=True).start(),
            "gerrit": patch("context.Gerrit", autospec=True).start(),
        }

        self.mock["threshold"].return_value.get_messages.return_value = {
            "Critical": "threshold_message",
            "Major": "threshold_message2",
            "Minor": "threshold_message3",
        }
        self.mock["under_threshold"].return_value.get_messages.return_value = {
            "Critical": "critical_under_threshold_message",
            "Major": "major_under_threshold_message",
            "Minor": "minor_under_threshold_message",
        }
        self.mock["cpu_increase_perc"].return_value.get_messages.return_value = {
            "Critical": "cpu_increase_perc_message",
            "Major": "cpu_increase_perc_message2",
            "Minor": "cpu_increase_perc_message3",
        }
        self.mock["cpu_increase_abs"].return_value.get_messages.return_value = {
            "Critical": "cpu_increase_abs_message",
            "Major": "cpu_increase_abs_message2",
            "Minor": "cpu_increase_abs_message3",
        }
        self.mock["boxplot_increase"].return_value.get_messages.return_value = {
            "Major": "box_plot_increase_message"
        }
        self.mock["gerrit"].return_value.get_perf_portal_commit.return_value = (
            "PefPortalShortCommit"
        )

        self.last_same_test_info = [{"id": 99, "fileKPI": "ref_kpi_file.json"}]

        self.test_info = {
            "feature": "ft425",
            "beamNumber": "1",
            "CCNumber": "1",
            "UENumber": "1",
            "UESchedNumber": "1",
            "DDtype": "TDD",
            "TTIDuration": "125",
            "board": "ABIL",
            "testStatus": "NA",
            "fileKPI": "TimeMarkerKPI_L2RT_ft425_simpleTraffic_1CC_"
            "1UE_TDD125_ABIL_2019.05.03_08.40.28.json",
        }

        self.context = None

        context.THRESHOLD_DIR = f"{os.path.dirname(__file__)}/test_data/default_threshold"
        context.DECODER_DIR = f"{os.path.dirname(__file__)}/test_data/decoder"
        self.fixture_threshold_filename = (
            f"{os.path.dirname(__file__)}/test_data/default_threshold/threshold_scheduler.json"
        )
        self.fixture_decoder_option_filename = (
            f"{os.path.dirname(__file__)}/test_data/decoder/configure_options.json"
        )
        with open(self.fixture_threshold_filename) as f_h:
            self.fixture_default_threshold_content = json.load(f_h)
        self.fixture_active_conf_threshold = (
            f"{os.path.dirname(__file__)}/test_data/conf/active_threshold.json"
        )
        self.addCleanup(patch.stopall)

    def create_context(self, zuul_branch="master"):
        self.context = context.Context()

        self.context.init_check(self.test_info, self.last_same_test_info)
        self.mock["threshold"].assert_called_once_with(
            self.fixture_default_threshold_content, self.test_info, zuul_branch
        )
        self.mock["under_threshold"].assert_called_once_with(
            self.fixture_default_threshold_content, self.test_info, zuul_branch
        )
        self.mock["cpu_increase_perc"].assert_called_once_with(
            self.fixture_default_threshold_content,
            self.test_info,
            zuul_branch,
            self.last_same_test_info,
        )

    # todo: need that ?
    def create_context_logger_duration_inactive(self):
        with open(
            f"{os.path.dirname(__file__)}/test_data/conf/"
            f"active_threshold_min_logger_duration_inactive.json"
        ) as file_h:
            with open(self.fixture_threshold_filename) as f_h:
                with open(self.fixture_threshold_filename) as fixt:
                    with open(self.fixture_decoder_option_filename) as decoder_option_fh:
                        with patch("context.open") as mock_open:
                            mock_open.side_effect = [
                                file_h,
                                f_h,
                                fixt,
                                decoder_option_fh,
                            ]
                            self.create_context()

    def create_context_conf_file_not_found_then_all_active(self):
        with open(self.fixture_threshold_filename) as f_h:
            with open(self.fixture_threshold_filename) as fixt:
                with open(self.fixture_decoder_option_filename) as decoder_option_fh:
                    with patch("context.open") as mock_open:
                        mock_open.side_effect = [
                            FileNotFoundError,
                            f_h,
                            fixt,
                            decoder_option_fh,
                        ]
                        self.create_context()

    def assert_stdout_calls(self, msg_list):
        if len(msg_list) > 0:
            calls = []
            for msg in msg_list:
                calls.append(call(msg))
                calls.append(call("\n"))
                self.mock["stdout"].assert_has_calls(calls)

            self.assertEqual(self.mock["stdout"].call_count, int(2 * int(len(msg_list))))

        else:
            self.mock["stdout"].assert_not_called()

    def test_save_into_db_function(self):
        context.Context.clone_time_marker()
        self.mock["gerrit"].git_clone_time_marker.assert_called_once_with()

        dummy_dict = {}
        my_context = context.Context(insert_into_db=False)
        my_context.save_into_db("dummy_table", dummy_dict)
        self.mock["database"].return_value.insert.assert_not_called()
        my_context.get_commit_date("my_commit_hash")
        self.mock["gerrit"].return_value.get_commit_date.assert_not_called()

        self.create_context()
        self.context.get_commit_date("my_commit_hash")
        self.mock["gerrit"].return_value.get_commit_date.assert_called_once_with("my_commit_hash")
        self.context.save_into_db("dummy_table", dummy_dict)
        self.mock["database"].return_value.insert.assert_called_once_with("dummy_table", dummy_dict)
        self.assert_stdout_calls([])

    def test_delete_into_db(self):
        self.create_context()
        self.context.delete_into_db("dummy_table")
        self.mock["database"].return_value.clean_table.assert_called_once_with(
            "dummy_table", where_dict=None
        )
        self.assert_stdout_calls([])

    def test_select_list_into_one_table(self):
        self.create_context()
        self.context.select_list_into_one_table("tableName")
        self.mock["database"].return_value.select_list_into_one_table.assert_called_once_with(
            "tableName",
            select_col=["id"],
            where_dict=None,
            where_str=None,
            order_list=None,
            sort_order="DESC",
            group_by_str=None,
            limit_result=1,
        )
        self.assert_stdout_calls([])

    def test_update_one_table(self):
        self.create_context()
        table_name = "table_name"
        set_dict = {"set_key1": "set_val1", "set_key2": "set_val2"}
        where_dict = {"=": {"where_key1": "where_val1", "where_key2": "where_val2"}}
        self.context.update_one_table(table_name, set_dict, where_dict)
        self.mock["database"].return_value.update_one_table.assert_called_once_with(
            table_name, set_dict, where_dict
        )

    def test_db_commit_function(self):
        self.create_context()
        self.context.db_disconnect()
        self.context.db_reconnect()
        self.context.db_commit()
        self.mock["database"].return_value.commit.assert_called_once_with()
        self.mock["database"].return_value.connect.assert_called_once_with()
        self.mock["database"].return_value.disconnect.assert_called_once_with()
        self.assert_stdout_calls(["Database commit active"])

    def test_launch_check_for_all_except_logger_and_send_alarm_mail_and_gerrit(self):
        dummy_dict = {"dummy_key": "dummy_value"}
        self.create_context_logger_duration_inactive()
        dummy_method = self.create_context
        self.context.launch_check(dummy_dict, dummy_method)
        self.mock["threshold"].return_value.check_kpi_scheduler.assert_called_once_with(
            dummy_dict, kpi_with_name=False
        )
        self.mock["under_threshold"].return_value.check_kpi_scheduler.assert_called_once_with(
            dummy_dict, kpi_with_name=False
        )
        self.mock["cpu_increase_perc"].return_value.check_kpi_scheduler.assert_called_once_with(
            dummy_dict, dummy_method, kpi_with_name=False
        )
        self.mock["cpu_increase_abs"].return_value.check_kpi_scheduler.assert_called_once_with(
            dummy_dict, dummy_method, kpi_with_name=False
        )

        self.mock["threshold"].return_value.get_messages.return_value = {
            "Critical": "my Critical threshold message",
            "Major": "my Major threshold message",
            "Minor": "my Minor threshold message",
        }
        self.mock["cpu_increase_perc"].return_value.get_messages.return_value = {
            "Critical": "my Critical cpu increase perc message",
            "Major": "my Major cpu increase perc message",
            "Minor": "my Minor cpu increase perc message",
        }
        self.mock["cpu_increase_abs"].return_value.get_messages.return_value = {
            "Critical": "my Critical cpu increase abs message",
            "Major": "my Major cpu increase abs message",
            "Minor": "my Minor cpu increase abs message",
        }

        message_dict = {
            "Critical": "<b>Threshold Alarm:</b>my Critical threshold message"
            "\n\n<b>Under Threshold Alarm:</b>critical_under_threshold_message"
            "\n\n<b>CPU Increase PERC Alarm:</b>my Critical cpu increase perc message"
            "\n\n<b>CPU Increase ABS Alarm:</b>my Critical cpu increase abs message",
            "Major": "<b>Threshold Alarm:</b>my Major threshold message"
            "\n\n<b>Under Threshold Alarm:</b>major_under_threshold_message"
            "\n\n<b>CPU Increase PERC Alarm:</b>my Major cpu increase perc message"
            "\n\n<b>CPU Increase ABS Alarm:</b>my Major cpu increase abs message",
            "Minor": "<b>Threshold Alarm:</b>my Minor threshold message"
            "\n\n<b>Under Threshold Alarm:</b>minor_under_threshold_message"
            "\n\n<b>CPU Increase PERC Alarm:</b>my Minor cpu increase perc message"
            "\n\n<b>CPU Increase ABS Alarm:</b>my Minor cpu increase abs message",
        }

        gerrit_message = (
            "\n\n<b>Critical alarms:</b>\n\n"
            "<b>Threshold Alarm:</b>my Critical threshold message\n\n"
            "<b>CPU Increase PERC Alarm:</b>my Critical cpu increase perc message"
            "<b>CPU Increase ABS Alarm:</b>my Critical cpu increase abs message"
            "\n\n<b>Major alarms:</b>\n\n"
            "<b>Threshold Alarm:</b>my Major threshold message\n\n"
            "<b>CPU Increase PERC Alarm:</b>my Major cpu increase perc message"
            "<b>CPU Increase ABS Alarm:</b>my Major cpu increase abs message"
        )

        self.mock["report"].return_value.alarm.return_value = gerrit_message
        self.context.alarm_threshold()
        self.context.send_alarm()

        self.mock["threshold"].return_value.get_messages.assert_called_once_with(
            True, context=self.context
        )
        self.mock["under_threshold"].return_value.get_messages.assert_called_once_with(
            True, context=self.context
        )
        self.mock["cpu_increase_perc"].return_value.get_messages.assert_called_once_with(
            True, context=self.context
        )
        self.mock["cpu_increase_abs"].return_value.get_messages.assert_called_once_with(
            True, context=self.context
        )

        self.mock["report"].return_value.error.assert_not_called()
        self.mock["report"].return_value.alarm.assert_called_once_with(
            message_dict,
            os.path.basename(self.fixture_threshold_filename),
            perf_portal_short_commit="PefPortalShortCommit",
        )
        self.mock["gerrit"].return_value.send_comments.assert_called_once_with(gerrit_message)
        self.assertTrue(self.context.is_alarm_critical)

        self.assert_stdout_calls([])
        self.assertTrue(self.context.is_alarm_critical)

    def test_alarm_threshold_function(self):
        self.create_context_conf_file_not_found_then_all_active()
        self.context.insert_into_db = False
        self.context.alarm_threshold()
        self.mock["threshold"].return_value.get_messages.assert_called_once_with(
            False, context=self.context
        )
        self.mock["under_threshold"].return_value.get_messages.assert_called_once_with(
            False, context=self.context
        )
        self.mock["cpu_increase_perc"].return_value.get_messages.assert_called_once_with(
            False, context=self.context
        )
        self.mock["cpu_increase_abs"].return_value.get_messages.assert_called_once_with(
            False, context=self.context
        )
        self.assertFalse(self.context.is_alarm_critical)
        calls = [
            call("Warning: conf file threshold/active_threshold.json not found"),
            call("\n"),
        ]
        self.mock["stdout"].assert_has_calls(calls)
        self.assertEqual(self.mock["stdout"].call_count, 2)

    def test_if_send_gerrit_comment_is_false_then_send_no_comment_to_gerrit(self):
        self.create_context()
        context_no_comment_to_gerrit = context.Context(send_gerrit_comment=False)

        context_no_comment_to_gerrit.init_check(self.test_info, self.last_same_test_info)
        message = set_threshold_cpu_increase_messages(context_no_comment_to_gerrit)

        context_no_comment_to_gerrit.send_alarm()
        self.mock["report"].return_value.alarm.assert_called_once_with(
            message, "threshold_scheduler.json", perf_portal_short_commit="PefPortalShortCommit"
        )
        self.mock["report"].return_value.error.assert_not_called()
        self.mock["gerrit"].return_value.send_comments.assert_not_called()
        self.assertFalse(self.context.is_alarm_critical)
        self.assert_stdout_calls(["No message sent to gerrit"])
        self.assertIsNone(context_no_comment_to_gerrit.get_parent_commit_date())

    def test_if_check_threshold_is_false_then_no_check_threshold_and_cpu_increase_nor_alarm(self):
        self.create_context()
        context_no_check_thresholds_and_cpu_increase = context.Context(check_threshold=False)
        dummy_dict = {}
        context_no_check_thresholds_and_cpu_increase.init_check(
            self.test_info, self.last_same_test_info
        )
        context_no_check_thresholds_and_cpu_increase.check_threshold(dummy_dict)
        context_no_check_thresholds_and_cpu_increase.alarm_threshold()

        self.mock["threshold"].return_value.check_kpi_scheduler.assert_not_called()
        self.mock["threshold"].return_value.get_messages.assert_not_called()
        self.mock["under_threshold"].return_value.check_kpi_scheduler.assert_not_called()
        self.mock["under_threshold"].return_value.get_messages.assert_not_called()
        self.mock["cpu_increase_perc"].return_value.get_messages.assert_not_called()
        self.mock["cpu_increase_abs"].return_value.get_messages.assert_not_called()
        self.assertFalse(self.context.is_alarm_critical)
        self.assert_stdout_calls([])

    def test_problem_init_of_gerrit(self):
        self.mock["gerrit"].side_effect = KeyError("ZUUL_CHANGE")
        self.create_context()

        message = set_threshold_cpu_increase_messages(self.context)

        self.context.send_alarm()
        self.mock["gerrit"].return_value.send_comments.assert_not_called()
        self.mock["report"].return_value.error.assert_called_once()
        self.mock["report"].return_value.alarm.assert_called_once_with(
            message, "threshold_scheduler.json", perf_portal_short_commit=None
        )
        self.assertIsNone(self.context.gerrit)
        self.assertTrue(self.context.is_alarm_critical)
        self.assertRaises(AttributeError, self.context.get_parent_commit_date)

    def test_problem_send_comments_of_gerrit(self):
        self.mock["gerrit"].return_value.send_comments.side_effect = KeyError("ZUUL_CHANGE")
        self.create_context()

        self.context.check_threshold({"dummyKey": "dummyValue"})
        self.mock["threshold"].return_value.check_kpi_scheduler.assert_called_once_with(
            {"dummyKey": "dummyValue"}, kpi_with_name=False
        )

        self.context.threshold_message = {
            "Critical": "",
            "Major": "\nWarning threshold message",
            "Minor": "\nWarning threshold message",
        }

        message_dict = {
            "Major": "<b>Threshold Alarm:</b>\nWarning threshold message",
            "Minor": "<b>Threshold Alarm:</b>\nWarning threshold message",
        }

        gerrit_message = (
            "\n\n<b>Major alarms:</b>\n\n<b>Threshold Alarm:</b>my Critical threshold message"
        )

        self.mock["report"].return_value.alarm.return_value = gerrit_message

        self.context.send_alarm()
        self.mock["gerrit"].return_value.send_comments.assert_called_once_with(gerrit_message)
        self.mock["report"].return_value.error.assert_called_once()
        self.mock["report"].return_value.alarm.assert_called_once_with(
            message_dict,
            "threshold_scheduler.json",
            perf_portal_short_commit="PefPortalShortCommit",
        )
        self.assertFalse(self.context.is_alarm_critical)

    def test_status_is_failed(self):
        self.create_context()

        dummy_dict = {}
        dummy_method = self.create_context
        self.test_info["testStatus"] = "FAILED"
        self.mock["threshold"].reset_mock()
        self.mock["under_threshold"].reset_mock()
        self.mock["cpu_increase_perc"].reset_mock()
        self.mock["cpu_increase_abs"].reset_mock()

        self.context.init_check(self.test_info, [])
        self.context.launch_check(dummy_dict, dummy_method)
        self.context.alarm_threshold()

        self.mock["threshold"].assert_not_called()
        self.mock["under_threshold"].assert_not_called()
        self.mock["cpu_increase_perc"].assert_not_called()
        self.mock["cpu_increase_abs"].assert_not_called()
        self.mock["threshold"].return_value.check_kpi_scheduler.assert_not_called()
        self.mock["under_threshold"].return_value.check_kpi_scheduler.assert_not_called()
        self.mock["cpu_increase_perc"].return_value.check_kpi_scheduler.assert_not_called()
        self.mock["cpu_increase_abs"].return_value.check_kpi_scheduler.assert_not_called()
        self.mock["threshold"].return_value.get_messages.assert_not_called()
        self.mock["under_threshold"].return_value.get_messages.assert_not_called()
        self.mock["cpu_increase_perc"].return_value.get_messages.assert_not_called()
        self.mock["cpu_increase_abs"].return_value.get_messages.assert_not_called()
        self.assertFalse(self.context.is_alarm_critical)

    def common_init_with_threshold(self, zuul_branch="master", error=False):
        self.context = context.Context(zuul_branch=zuul_branch)
        self.assertDictEqual(
            self.context.threshold_file_content, self.fixture_default_threshold_content
        )
        self.assertEqual(
            self.context.threshold_filename, os.path.basename(self.fixture_threshold_filename)
        )
        self.mock["stdout"].assert_not_called()
        if error:
            self.mock["report"].return_value.error.assert_called_once_with()
            self.mock["report"].return_value.alarm.assert_called_once_with(
                f"\nWarning : {self.fixture_threshold_filename} cannot be opened "
                "as a JSON file to check Threshold."
            )
        else:
            self.mock["report"].return_value.alarm.assert_not_called()
            self.mock["report"].return_value.error.assert_not_called()

    def test_init_with_threshold_5g19z_but_not_found(self):
        self.common_init_with_threshold(zuul_branch="rel/5G19Z")

    def test_init_with_threshold_5g19_23_and_found_it(self):
        self.fixture_threshold_filename = "5G19_threshold_scheduler.json"
        with open("test_data/test_threshold_scheduler1.json") as f_h:
            self.fixture_default_threshold_content = json.load(f_h)

        with open(self.fixture_active_conf_threshold) as file_h:
            with open("test_data/test_threshold_scheduler1.json") as f_h:
                with open(self.fixture_decoder_option_filename) as decoder_option_fh:
                    with patch("context.open") as mock_open:
                        mock_open.side_effect = [file_h, FileNotFoundError, f_h, decoder_option_fh]
                        self.common_init_with_threshold(zuul_branch="rel/5G19_23")
                        decoder_option_list = self.context.get_configure_option_list(
                            {"CCNumber": 48, "configKey": "SA_LA_HARQ"}
                        )
                        self.assertListEqual(decoder_option_list, [])
                        decoder_option_list = self.context.get_configure_option_list(
                            {"CCNumber": 48, "configKey": "SA_LA_HARQ_REF"}
                        )
                        self.assertListEqual(
                            decoder_option_list,
                            ["--maxCs1Scheduling"],
                        )

    def test_init_with_default_threshold_and_not_found_it(self):
        self.fixture_default_threshold_content = dict()

        with open(self.fixture_active_conf_threshold) as file_h:
            with open(self.fixture_decoder_option_filename) as decoder_option_fh:
                with patch("context.open") as mock_open:
                    mock_open.side_effect = [
                        file_h,
                        FileNotFoundError,
                        FileNotFoundError,
                        FileNotFoundError,
                        decoder_option_fh,
                    ]
                    self.common_init_with_threshold(zuul_branch="rel/5G19_23", error=True)

    def test_init_with_threshold_5g19_23_but_weird_structure(self):
        with open(self.fixture_active_conf_threshold) as file_h:
            with open("test_data/test_threshold_scheduler_with_missing_bracket.json") as f_h:
                with open(self.fixture_threshold_filename) as fixt:
                    with open(self.fixture_decoder_option_filename) as decoder_fh:
                        with patch("context.open") as mock_open:
                            mock_open.side_effect = [
                                file_h,
                                f_h,
                                FileNotFoundError,
                                fixt,
                                decoder_fh,
                            ]
                            self.common_init_with_threshold(zuul_branch="rel/5G19_23")

    def test_init_with_default_threshold_but_weird_structure(self):
        self.fixture_default_threshold_content = dict()
        with open("threshold/active_threshold.json") as file_h:
            with open("test_data/test_threshold_scheduler_with_missing_bracket.json") as f_h:
                with open(self.fixture_decoder_option_filename) as decoder_option_fh:
                    with patch("context.open") as mock_open:
                        mock_open.side_effect = [
                            file_h,
                            FileNotFoundError,
                            FileNotFoundError,
                            f_h,
                            decoder_option_fh,
                        ]
                        self.common_init_with_threshold(zuul_branch="rel/5G19_23", error=True)

    def test_save_get_message_multiprocess_mode(self):
        threshold_message = {
            "Critical": "critical_thresold",
            "Major": "major_thresold",
            "Minor": "minor_threshold",
        }
        my_context = context.Context(multiprocess=True)
        self.assertDictEqual(
            my_context.threshold_message, {"Critical": "", "Major": "", "Minor": ""}
        )

        my_context.threshold_message = threshold_message
        my_context.save_messages()
        self.assertDictEqual(my_context.threshold_message, threshold_message)

        my_context.threshold_message = {}
        self.assertDictEqual(my_context.threshold_message, {})

        my_context.get_messages()
        self.assertDictEqual(my_context.threshold_message, threshold_message)

    def test_boxplot_increase(self):
        self.create_context()
        self.context.threshold_file_content = None
        self.context.compute_boxplot_increase(self.test_info, "previous_commit")
        self.mock["boxplot_increase"].assert_called_once_with(
            self.fixture_default_threshold_content, self.test_info, "master"
        )
        self.mock["boxplot_increase"].return_value.check_kpi_scheduler.assert_called_once_with(
            "previous_commit", self.context.select_list_into_one_table, previous_commit_kpi=None
        )
        self.mock["boxplot_increase"].return_value.get_messages.assert_called_once_with(
            True, self.context
        )

    def test_get_configure_option_list(self):
        self.create_context()
        expected_config_result_list = [
            {
                "config": {
                    "board": "ABIL",
                    "feature": "ft000_perfTestSA",
                    "CCNumber": "4",
                    "UENumber": "48",
                    "DDtype": "TDD",
                    "TTIDuration": "125",
                    "configKey": "SA_LA_HARQ",
                },
                "decode_option_list": ["--extended", "--synchronized"],
            },
            {
                "config": {
                    "board": "ABIO",
                    "feature": "ft000_perfTestSA",
                    "CCNumber": "4",
                    "UENumber": "48",
                    "DDtype": "TDD",
                    "TTIDuration": "125",
                    "configKey": "SA_LA_HARQ",
                },
                "decode_option_list": [],
            },
            {
                "config": {
                    "board": "ABIL",
                    "feature": "ft000_perfTestSA",
                    "CCNumber": "4",
                    "UENumber": "48",
                    "DDtype": "TDD",
                    "TTIDuration": "125",
                    "configKey": "SA_LA_HARQ_REF",
                },
                "decode_option_list": ["--maxCs1Scheduling", "--extended", "--synchronized"],
            },
            {
                "config": {
                    "board": "ABIN",
                    "feature": "ft000_perfTestSA",
                    "CCNumber": "4",
                    "UENumber": "48",
                    "DDtype": "TDD",
                    "TTIDuration": "125",
                    "configKey": "SA_LA_HARQ_REF",
                },
                "decode_option_list": ["--maxCs1Scheduling"],
            },
            {
                "config": {
                    "board": "ABIL",
                    "feature": "ft000_perfTestNSA",
                    "CCNumber": "4",
                    "UENumber": "24",
                    "DDtype": "TDD",
                    "TTIDuration": "125",
                    "configKey": "NSA_LA_HARQ",
                },
                "decode_option_list": ["--extended"],
            },
            {
                "config": {
                    "board": "ABIL",
                    "feature": "ft1948A_MultiCellGroupSetupFDD",
                    "CCNumber": "3",
                    "UENumber": "408",
                    "DDtype": "FDD",
                    "TTIDuration": "1000",
                    "configKey": "NSA_CG3",
                },
                "decode_option_list": ["--extended"],
            },
            {
                "config": {
                    "board": "ABIL",
                    "feature": "ft000_perfTestSA",
                    "CCNumber": "2",
                    "UENumber": "200",
                    "DDtype": "TDD",
                    "TTIDuration": "500",
                    "configKey": "SA_CG2",
                },
                "decode_option_list": ["--extended"],
            },
            {
                "config": {
                    "board": "ABIO",
                    "feature": "ft000_FuseTraffic",
                    "CCNumber": "2",
                    "UENumber": "200",
                    "DDtype": "TDD",
                    "TTIDuration": "500",
                    "configKey": "TestDGUI",
                },
                "decode_option_list": ["--extended"],
            },
            {
                "config": {
                    "board": "ABIL",
                    "feature": "ft000_perfTestNSA",
                    "CCNumber": "_4",
                    "UENumber": "24",
                    "DDtype": "TDD",
                    "TTIDuration": "125",
                    "configKey": "NSA_LA_HARQ_DGUI",
                },
                "decode_option_list": [],
            },
        ]
        for expected_config_result in expected_config_result_list:
            print(expected_config_result)
            result = self.context.get_configure_option_list(expected_config_result["config"])
            self.assertListEqual(result, expected_config_result["decode_option_list"])
