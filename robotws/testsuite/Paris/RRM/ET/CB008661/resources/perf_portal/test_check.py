import unittest
import json
import os
from unittest.mock import patch, call
from check import Check
from check import Threshold
from check import CPUIncreasePercent
from check import CPUIncreaseAbsolute
from check import UnderThreshold
from check import ValueIncrease
from check import BoxPlotIncrease


class TestCheck(unittest.TestCase):
    def setUp(self):
        self.kpi_columns = {
            "testId": "122",
            "component": "L2PSDL",
            "componentInstance": "1",
            "subComponent1": "Scheduler",
            "subComponent2": "All",
            "subComponent3": "All",
            "subComponent4": "All",
            "min": "5.06",
            "avg": "9.12",
            "95p": "10.89",
            "max": "11.33",
        }

        self.test_info = {
            "id": 100,
            "feature": "ft425",
            "beamNumber": "1",
            "CCNumber": "1",
            "UENumber": "1",
            "UESchedNumber": "1",
            "DDtype": "TDD",
            "TTIDuration": "125",
            "board": "ABIL",
            "configKey": "null",
            "softwareCommit": "0751768e54b6c0c9255c8fced378c5854f5f956f",
            "fileKPI": "TimeMarkerKPI_L2RT_ft425_simpleTraffic_1CC_100UE_"
            "TDD125_ABIL_2019.04.04_00.14.11_32fb44d.json",
            "testDate": "2019-04-04T00:14:11",
        }

        self.branch = "master"
        self.test_json = {}
        with open(f"{os.path.dirname(__file__)}/test_data/test_threshold_scheduler2.json") as f_h:
            self.test_json[
                "thresh_not_exceeded_for_L2PSDL_Scheduler_TTI125_and_no_thresh_for_TTI500"
            ] = json.load(f_h)
        with open(f"{os.path.dirname(__file__)}/test_data/test_threshold_scheduler1.json") as f_h:
            self.test_json["thresh_exceeded_for_L2PSUL_and_L2PSDL_Sched_subcompos"] = json.load(f_h)
        with open(
            f"{os.path.dirname(__file__)}"
            f"/test_data/test_threshold_scheduler_with_weird_structure.json"
        ) as f_h:
            self.test_json["no_L2PSUL_extra_subcomponent_and_no_threshold_value"] = json.load(f_h)
        with open(
            f"{os.path.dirname(__file__)}"
            f"/test_data/test_threshold_scheduler_with_beta_result.json"
        ) as f_h:
            self.test_json["test_threshold_scheduler_with_beta_result"] = json.load(f_h)

        self.mock = {
            "context": patch("context.Context", autospec=True).start(),
            "table_threshold_alarm": patch("check.TableThresholdAlarm", autospec=True).start(),
            "report": patch("check.Report", autospec=True).start(),
            "stdout": patch("sys.stdout.write").start(),
        }

        self.addCleanup(patch.stopall)

    @staticmethod
    def get_power_bi_url(test_filter, commit_filter):
        test_view = (
            "https://app.powerbi.com/groups/me/apps/4b451a02-844c-47b2-bd6b-e43667c7cf16/"
            "reports/40754105-09ce-460f-8c03-6881db7c58c7/ReportSection047c7ac31e9441232f58"
            f"{test_filter} and {commit_filter}"
        )
        history = (
            "https://app.powerbi.com/groups/me/apps/4b451a02-844c-47b2-bd6b-e43667c7cf16/reports/"
            f"40754105-09ce-460f-8c03-6881db7c58c7/ReportSection45750c70ce6fd4a0a73d{test_filter}"
        )
        return test_view, history

    def test_init_check_nok(self):
        self.assertRaisesRegex(
            TypeError,
            "Can't instantiate abstract class Check",
            Check,
            self.test_json["thresh_exceeded_for_L2PSUL_and_L2PSDL_Sched_subcompos"],
            self.test_info,
            "check_value",
            "check_alarm_str",
        )
        self.mock["stdout"].assert_not_called()

    def test_format_kpi_scheduler_columns_nok(self):
        self.assertRaises(NotImplementedError, Check.check_kpi_scheduler, {"key": "value"})
        self.mock["stdout"].assert_not_called()

    def test_check_test_limit_function_nok(self):
        self.assertRaises(
            NotImplementedError, Check.check_test_limit_function, "value", "kpi_key", "level"
        )
        self.mock["stdout"].assert_not_called()

    def assert_mock_stdout_calls(self, call_count=2, check_str="threshold"):
        calls = [call(f"Checking {check_str} active"), call("\n")]
        self.mock["stdout"].assert_has_calls(calls)
        self.assertEqual(self.mock["stdout"].call_count, call_count)

    def assert_not_send_alarm_nor_error(self, check_obj, call_count=2, check_str="threshold"):
        self.mock["report"].return_value.error.assert_not_called()
        self.assertEqual(check_obj.message, {"Critical": "", "Major": "", "Minor": ""})
        self.assert_mock_stdout_calls(call_count, check_str)
        self.mock["table_threshold_alarm"].assert_not_called()

    def test_set_components_key_dict(self):
        self.assertDictEqual(
            Check.set_components_key_dict("L2PSDL"),
            {
                "component": "L2PSDL",
                "subComponent1": "All",
                "subComponent2": "All",
                "subComponent3": "All",
                "subComponent4": "All",
            },
        )
        self.assertDictEqual(
            Check.set_components_key_dict("L2PSDL.Scheduler"),
            {
                "component": "L2PSDL",
                "subComponent1": "Scheduler",
                "subComponent2": "All",
                "subComponent3": "All",
                "subComponent4": "All",
            },
        )
        self.assertDictEqual(
            Check.set_components_key_dict("L2PSUL.Scheduler.postScheduler"),
            {
                "component": "L2PSUL",
                "subComponent1": "Scheduler",
                "subComponent2": "postScheduler",
                "subComponent3": "All",
                "subComponent4": "All",
            },
        )
        self.assertDictEqual(
            Check.set_components_key_dict("L2PSUL.Scheduler.fdPucch.3"),
            {
                "component": "L2PSUL",
                "subComponent1": "Scheduler",
                "subComponent2": "fdPucch",
                "subComponent3": "3",
                "subComponent4": "All",
            },
        )

    # Use for beta version KPI
    def common_test_time_checker(
        self, obj, time_dict, expected_msg, kpi_with_name=False, lambda_return_dict=None
    ):
        if lambda_return_dict:
            t_object = obj(
                self.test_json["test_threshold_scheduler_with_beta_result"],
                self.test_info,
                self.branch,
                [{"id": 98, "fileKPI": "file98"}, {"id": 99, "fileKPI": "file99"}],
            )

            t_object.check_kpi_scheduler(
                time_dict, lambda x, y: [lambda_return_dict], kpi_with_name=kpi_with_name
            )
        else:
            t_object = obj(
                self.test_json["test_threshold_scheduler_with_beta_result"],
                self.test_info,
                self.branch,
            )

            t_object.check_kpi_scheduler(time_dict, kpi_with_name=kpi_with_name)
        msg = t_object.get_messages()
        self.assertRegex(msg["Critical"], expected_msg["Critical"])
        self.assertEqual(msg["Major"], expected_msg["Major"])
        self.assertEqual(msg["Minor"], expected_msg["Minor"])


class TestThreshold(TestCheck):
    def setUp(self):
        TestCheck.setUp(self)

    def test_when_unexpected_json_structure_then_ignore(self):
        t_object = Threshold(
            self.test_json["no_L2PSUL_extra_subcomponent_and_no_threshold_value"],
            self.test_info,
            self.branch,
        )
        t_object.check_kpi_scheduler(self.kpi_columns)
        t_object.get_messages(context=self.mock["context"])
        self.assert_not_send_alarm_nor_error(t_object)
        self.mock["table_threshold_alarm"].assert_not_called()

    def test_not_send_alarm_when_no_threshold_defined_for_value_or_defined_but_not_exceeded(self):
        t_object = Threshold(
            self.test_json[
                "thresh_not_exceeded_for_L2PSDL_Scheduler_TTI125_and_no_thresh_for_TTI500"
            ],
            self.test_info,
            self.branch,
        )
        t_object.check_kpi_scheduler(self.kpi_columns)
        t_object.get_messages()

        self.test_info["TTIDuration"] = "500"
        file_kpi = (
            "TimeMarkerKPI_L2RT_ft789C_simpleTraffic_1CC_8UE_TDD500_ABIL_"
            "2019.04.04_00.14.13_32fb44d.json"
        )
        self.test_info["fileKpi"] = file_kpi
        t_object2 = Threshold(
            self.test_json[
                "thresh_not_exceeded_for_L2PSDL_Scheduler_TTI125_and_no_thresh_for_TTI500"
            ],
            self.test_info,
            self.branch,
        )
        t_object2.check_kpi_scheduler(self.kpi_columns)
        t_object2.get_messages()
        self.mock["table_threshold_alarm"].return_value.save_into_db.assert_not_called()

        self.assert_not_send_alarm_nor_error(t_object, 4)

    def test_processing_time_checker(self):
        processing_time_dict = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ptScheduling",
            "min": 87.936,
            "avg": 110.578,
            "95p": 124.64,
            "max": 128.592,
            "kpiType": "ProcessingTime",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_ABIL</b>"
                "_2019.04.04_00.14.11_32fb44d.json :\nProcessingTime.L2PSDL.ptScheduling.max = "
                "128.592 us exceeds threshold value 80 us.\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            Threshold, processing_time_dict, expected_msg, kpi_with_name=True
        )

    def test_lead_time_checker(self):
        lead_time_dict = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ltBetweenTwoConsecutiveSlotSynchroInds",
            "95p": 129.232,
            "avg": 125.867,
            "max": 130.168,
            "min": 120.528,
            "kpiType": "LeadTime",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_ABIL</b>"
                "_2019.04.04_00.14.11_32fb44d.json :\nLeadTime.L2PSDL."
                "ltBetweenTwoConsecutiveSlotSynchroInds.max = 130.168 us exceeds "
                "threshold value 80 us.\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(Threshold, lead_time_dict, expected_msg, kpi_with_name=True)

    def test_values_checker(self):
        values_dict = {
            "testId": 100,
            "component": "L2PSDL",
            "cellGroupInstance": 1,
            "ventilated": False,
            "subComponent1": "cs1",
            "subComponent2": None,
            "95p": 32,
            "avg": 32,
            "max": 32,
            "min": 32,
            "unit": "",
            "kpiType": "Values",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_ABIL</b>"
                "_2019.04.04_00.14.11_32fb44d.json :\nValues.L2PSDL.cs1.min = 32 exceeds "
                "threshold value 30.\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(Threshold, values_dict, expected_msg, kpi_with_name=False)

    def test_proc_time_per_eo_checker(self):
        proc_time_per_eo_dict = {
            "testId": 100,
            "component": "L2PSUL",
            "cellGroupInstance": 1,
            "coreId": "Core6",
            "eoNameAndInstance": "L2PsUlSch-1",
            "isProbe": True,
            "ventilated": False,
            "subComponent1": "EO_L2_PS_UL_MESSAGE",
            "subComponent2": "Common_SlotSynchroInd",
            "subComponent3": "EO_L2_PS_PRE_SCHEDULER",
            "subComponent4": None,
            "95p": 1.96,
            "avg": 1.871,
            "max": 2.12,
            "min": 1.736,
            "kpiType": "ProcessingTimePerEO",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_ABIL</b>"
                "_2019.04.04_00.14.11_32fb44d.json :\nProcessingTimePerEO.L2PSUL."
                "L2PsUlSch-1.EO_L2_PS_UL_MESSAGE.Common_SlotSynchroInd."
                "EO_L2_PS_PRE_SCHEDULER.95p = 1.96 us exceeds threshold value 1.9 us.\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            Threshold, proc_time_per_eo_dict, expected_msg, kpi_with_name=False
        )

    def send_one_alarm_when_multiple_thresholds_defined_and_critical_exceeded(
        self, save_alarm=False
    ):
        t_object = Threshold(
            # voting = false for L2PSDL.Scheduler.fdScheduler
            self.test_json["thresh_exceeded_for_L2PSUL_and_L2PSDL_Sched_subcompos"],
            self.test_info,
            self.branch,
        )

        self.kpi_columns = {
            "testId": "122",
            "component": "L2PSUL",
            "componentInstance": "1",
            "subComponent1": "All",
            "subComponent2": "All",
            "subComponent3": "All",
            "subComponent4": "All",
            "min": "41.06",
            "avg": "64.12",
            "95p": "82.89",
            "max": "110.33",
        }
        t_object.check_kpi_scheduler(self.kpi_columns)

        self.kpi_columns = {
            "testId": "123",
            "component": "L2PSDL",
            "componentInstance": "1",
            "subComponent1": "Scheduler",
            "subComponent2": "fdScheduler",
            "subComponent3": "fdProcessing",
            "subComponent4": "All",
            "min": "63.81",
            "avg": "73.95",
            "95p": "89.02",
            "max": "92.44",
        }
        t_object.check_kpi_scheduler(self.kpi_columns)
        t_object.get_messages(save_alarm, context=self.mock["context"])

        if not save_alarm:
            message = (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_ABIL</b>"
                "_2019.04.04_00.14.11_32fb44d.json :\nL2PSUL.max = 110.33 us "
                "exceeds threshold value 80 us."
            )

            self.assertEqual(t_object.message, {"Critical": message, "Major": "", "Minor": ""})
        self.assert_mock_stdout_calls()

    def test_send_one_alarm_when_multiple_thresholds_defined_and_exceeded(self):
        self.send_one_alarm_when_multiple_thresholds_defined_and_critical_exceeded()
        self.mock["table_threshold_alarm"].assert_not_called()
        self.mock["report"].return_value.error.assert_not_called()

    def test_save_alarm_in_db(self):
        self.send_one_alarm_when_multiple_thresholds_defined_and_critical_exceeded(save_alarm=True)
        self.mock["table_threshold_alarm"].assert_called_once()
        self.mock["report"].return_value.error.assert_not_called()


class TestUnderThreshold(TestCheck):
    def setUp(self):
        TestCheck.setUp(self)

    def test_check_kpi_scheduler_minor_threshold_exceeded(self):
        t_object = UnderThreshold(
            self.test_json["thresh_exceeded_for_L2PSUL_and_L2PSDL_Sched_subcompos"],
            self.test_info,
            self.branch,
        )

        t_object.check_kpi_scheduler(
            {
                "testId": "122",
                "component": "L2PSUL",
                "componentInstance": "1",
                "subComponent1": "All",
                "subComponent2": "All",
                "subComponent3": "All",
                "subComponent4": "All",
                "95p": 1,
                "avg": 2.0,
                "max": 2,
                "min": 0,
            }
        )
        t_object.get_messages()
        self.assert_not_send_alarm_nor_error(t_object, check_str="under or egal KPI threshold")

        t_object.check_kpi_scheduler(
            {
                "testId": "122",
                "component": "L2PSUL",
                "componentInstance": "1",
                "subComponent1": "All",
                "subComponent2": "All",
                "subComponent3": "All",
                "subComponent4": "All",
                "95p": 0,
                "avg": 1.0,
                "max": 1,
                "min": 0,
            }
        )
        t_object.get_messages()
        self.assert_mock_stdout_calls(call_count=4, check_str="under or egal KPI threshold")
        self.assertNotEqual(t_object.message, {"Critical": "", "Major": "", "Minor": ""})

        t_object.check_kpi_scheduler(
            {
                "testId": "122",
                "component": "L2PSDL",
                "componentInstance": "1",
                "subComponent1": "cs1",
                "subComponent2": None,
                "kpiType": "Values",
                "95p": 32,
                "avg": 1.0,
                "max": 1,
                "min": 0,
            }
        )
        t_object.get_messages()
        self.assertNotEqual(t_object.message, {"Critical": "", "Major": "", "Minor": ""})
        self.assertRegex(t_object.message["Critical"], "Values.L2PSDL.cs1.95p")

    def test_processing_time_checker(self):
        processing_time_dict = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ptScheduling",
            "min": 87.936,
            "avg": 110.578,
            "95p": 124.64,
            "max": 128.592,
            "kpiType": "ProcessingTime",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_ABIL</b>"
                "_2019.04.04_00.14.11_32fb44d.json :\nProcessingTime.L2PSDL.ptScheduling.max = "
                "128.592 us is under or egal KPI threshold 130 us.\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            UnderThreshold, processing_time_dict, expected_msg, kpi_with_name=True
        )

    def test_lead_time_checker(self):
        lead_time_dict = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ltBetweenTwoConsecutiveSlotSynchroInds",
            "95p": 129.232,
            "avg": 125.867,
            "max": 130.168,
            "min": 120.528,
            "kpiType": "LeadTime",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_ABIL</b>"
                "_2019.04.04_00.14.11_32fb44d.json :\n"
                "LeadTime.L2PSDL.ltBetweenTwoConsecutiveSlotSynchroInds.max = "
                "130.168 us is under or egal KPI threshold 130.2 us.\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            UnderThreshold, lead_time_dict, expected_msg, kpi_with_name=True
        )

    def test_values_checker(self):
        values_dict = {
            "testId": 100,
            "component": "L2PSDL",
            "cellGroupInstance": 1,
            "ventilated": False,
            "subComponent1": "cs1",
            "subComponent2": None,
            "95p": 32,
            "avg": 32,
            "max": 32,
            "min": 32,
            "unit": "",
            "kpiType": "Values",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_ABIL</b>"
                "_2019.04.04_00.14.11_32fb44d.json :\nValues.L2PSDL.cs1.min = "
                "32 is under or egal KPI threshold 35.\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            UnderThreshold, values_dict, expected_msg, kpi_with_name=False
        )

    def test_proc_time_per_eo_checker(self):
        proc_time_per_eo_dict = {
            "testId": 100,
            "component": "L2PSUL",
            "cellGroupInstance": 1,
            "coreId": "Core6",
            "eoNameAndInstance": "L2PsUlSch-1",
            "isProbe": True,
            "ventilated": False,
            "subComponent1": "EO_L2_PS_UL_MESSAGE",
            "subComponent2": "Common_SlotSynchroInd",
            "subComponent3": "EO_L2_PS_PRE_SCHEDULER",
            "subComponent4": None,
            "95p": 1.96,
            "avg": 1.871,
            "max": 2.12,
            "min": 1.736,
            "kpiType": "ProcessingTimePerEO",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_ABIL</b>"
                "_2019.04.04_00.14.11_32fb44d.json :\nProcessingTimePerEO.L2PSUL."
                "L2PsUlSch-1.EO_L2_PS_UL_MESSAGE.Common_SlotSynchroInd."
                "EO_L2_PS_PRE_SCHEDULER.95p = 1.96 us is under or egal KPI threshold 1.97 us.\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            UnderThreshold, proc_time_per_eo_dict, expected_msg, kpi_with_name=False
        )


class TestValueIncrease(TestCheck):
    def setUp(self):
        TestCheck.setUp(self)

    def test_init_check_nok(self):
        self.assertRaisesRegex(
            TypeError,
            "Can't instantiate abstract class ValueIncrease",
            ValueIncrease,
            self.test_json["thresh_exceeded_for_L2PSUL_and_L2PSDL_Sched_subcompos"],
            self.test_info,
            "check_value",
            "check_alarm_str",
        )
        self.mock["stdout"].assert_not_called()


class TestCPUIncreasePercent(TestCheck):
    def setUp(self):
        TestCheck.setUp(self)
        self.fixture_last_test = [
            {"id": 97, "fileKPI": "reference_kpi_file_1.json", "key3": "value1.3"},
            {"id": 98, "fileKPI": "reference_kpi_file_2.json", "key3": "value3.3"},
            {"id": 99, "fileKPI": "reference_kpi_file_3.json", "key3": "value3.3"},
        ]

    def test_check_kpi_scheduler_critical_and_major_threshold_exceeded(self):
        self.test_info["configKey"] = "NSA"
        self.test_info["fileKPI"] = (
            "TimeMarkerKPIv2_L2RT_cni51678_performance_4CC_24UE_TDD125_ABIL_CFG_NSA_"
            "FDPRL_D_CNI51678_ACTIVATED_2020.08.07_11.29.38_bdab787.json"
        )
        test_filter = (
            "?filter=perf_5g_x0020_Test/FormatedTestName eq "
            "'ft425_1BM_1CC_1UE_1UEsched_TDD125_ABIL_NSA'"
        )
        commit_filter = "perf_5g_x0020_Test/FormatedCommitShortName eq '0751768'"
        test_view_url, history_view_url = TestCheck.get_power_bi_url(test_filter, commit_filter)
        filekpi_url = (
            '<a href="'
            "https://5gwebserver.dyn.nesc.nokia.net/CinqG/perfport/"
            f"2019/04/04/00.14.11/{self.test_info['fileKPI']}"
            '">Timemarker KPI file</a>\n'
        )

        # voting for L2PSUL.Scheduler.postScheduler.max = false so no critical error
        message_major = (
            "\nWarning : TimeMarkerKPIv2_L2RT_<b>cni51678_performance_4CC_24UE_TDD125_ABIL_CFG_"
            "NSA_FDPRL_D_CNI51678_ACTIVATED</b>_2020.08.07_11.29.38_bdab787.json with reference "
            "test reference_kpi_file_1.json, reference_kpi_file_2.json, reference_kpi_file_3.json :"
            "\nL2PSDL.Scheduler.max = 92.44 us exceeds cpu increase of 95% with 47.0 us"
            f'\n<a href="{test_view_url}">Power BI test view</a>, '
            f'<a href="{history_view_url}">Power BI history view</a>, '
            f"{filekpi_url}"
        )

        t_object = CPUIncreasePercent(
            self.test_json[
                "thresh_not_exceeded_for_L2PSDL_Scheduler_TTI125_and_no_thresh_for_TTI500"
            ],
            self.test_info,
            self.branch,
            self.fixture_last_test,
        )

        self.assertEqual(
            t_object.previous_test_ids_str,
            f"{self.fixture_last_test[0]['id']}, {self.fixture_last_test[1]['id']}, "
            f"{self.fixture_last_test[2]['id']}",
        )
        self.assertEqual(
            t_object.previous_kpi_files_str,
            f'{self.fixture_last_test[0]["fileKPI"]}, {self.fixture_last_test[1]["fileKPI"]}, '
            f'{self.fixture_last_test[2]["fileKPI"]}',
        )

        self.kpi_columns = {
            "testId": "122",
            "component": "L2PSUL",
            "componentInstance": "1",
            "subComponent1": "Scheduler",
            "subComponent2": "postScheduler",
            "subComponent3": "All",
            "subComponent4": "All",
            "min": "41.06",
            "avg": "64.12",
            "95p": "82.89",
            "max": "110.33",
        }
        t_object.check_kpi_scheduler(self.kpi_columns, lambda x, y: [{"max": 10.0}])

        self.kpi_columns = {
            "testId": "123",
            "component": "L2PSDL",
            "componentInstance": "1",
            "subComponent1": "Scheduler",
            "subComponent2": "All",
            "subComponent3": "All",
            "subComponent4": "All",
            "min": "63.81",
            "avg": "73.95",
            "95p": "89.02",
            "max": "92.44",
        }
        t_object.check_kpi_scheduler(self.kpi_columns, lambda x, y: [{"max": 47.0}])
        t_object.check_kpi_scheduler(self.kpi_columns, lambda x, y: [])
        t_object.check_kpi_scheduler(self.kpi_columns, lambda x, y: [{"max": None}])
        t_object.previous_test_ids_str = None
        t_object.check_kpi_scheduler(self.kpi_columns, lambda x, y: [{"max": 30.0}])
        t_object.get_messages()

        self.assertEqual(
            t_object.message,
            {"Critical": "", "Major": message_major, "Minor": ""},
        )
        self.assert_mock_stdout_calls(check_str="cpu increase")

    def test_processing_time_checker(self):
        processing_time_dict = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ptScheduling",
            "min": 87.936,
            "avg": 110.578,
            "95p": 124.64,
            "max": 128.592,
            "kpiType": "ProcessingTime",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_"
                "ABIL</b>_2019.04.04_00.14.11_32fb44d.json with reference test file98, "
                "file99 :\nProcessingTime.L2PSDL.ptScheduling.max = 128.592 us exceeds "
                "cpu increase of 100% with 0.1 us\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            CPUIncreasePercent,
            processing_time_dict,
            expected_msg,
            kpi_with_name=True,
            lambda_return_dict={"max": 0.1},
        )

    def test_lead_time_checker(self):
        lead_time_dict = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ltBetweenTwoConsecutiveSlotSynchroInds",
            "95p": 129.232,
            "avg": 125.867,
            "max": 130.168,
            "min": 120.528,
            "kpiType": "LeadTime",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_"
                "ABIL</b>_2019.04.04_00.14.11_32fb44d.json with reference test file98, "
                "file99 :\nLeadTime.L2PSDL.ltBetweenTwoConsecutiveSlotSynchroInds.max = "
                "130.168 us exceeds cpu increase of 100% with 0.1 us\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            CPUIncreasePercent,
            lead_time_dict,
            expected_msg,
            kpi_with_name=True,
            lambda_return_dict={"max": 0.1},
        )

    def test_proc_time_per_eo_checker(self):
        proc_time_per_eo_dict = {
            "testId": 100,
            "component": "L2PSUL",
            "cellGroupInstance": 1,
            "coreId": "Core6",
            "eoNameAndInstance": "L2PsUlSch-1",
            "isProbe": True,
            "ventilated": False,
            "subComponent1": "EO_L2_PS_UL_MESSAGE",
            "subComponent2": "Common_SlotSynchroInd",
            "subComponent3": "EO_L2_PS_PRE_SCHEDULER",
            "subComponent4": None,
            "95p": 1.96,
            "avg": 1.871,
            "max": 2.12,
            "min": 1.736,
            "kpiType": "ProcessingTimePerEO",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_"
                "ABIL</b>_2019.04.04_00.14.11_32fb44d.json with reference test file98, "
                "file99 :\nProcessingTimePerEO.L2PSUL.L2PsUlSch-1.EO_L2_PS_UL_MESSAGE."
                "Common_SlotSynchroInd.EO_L2_PS_PRE_SCHEDULER.95p = 1.96 us exceeds "
                "cpu increase of 10% with 0.1 us\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            CPUIncreasePercent,
            proc_time_per_eo_dict,
            expected_msg,
            kpi_with_name=False,
            lambda_return_dict={"95p": 0.1},
        )


class TestCPUIncreaseAbsolute(TestCheck):
    def setUp(self):
        TestCheck.setUp(self)
        self.fixture_last_test = [
            {"id": 97, "fileKPI": "reference_kpi_file_1.json", "key3": "value1.3"},
            {"id": 98, "fileKPI": "reference_kpi_file_2.json", "key3": "value3.3"},
            {"id": 99, "fileKPI": "reference_kpi_file_3.json", "key3": "value3.3"},
        ]

    def test_check_kpi_scheduler_critical_and_major_threshold_exceeded(self):
        self.test_info["configKey"] = "NSA"
        self.test_info["fileKPI"] = (
            "TimeMarkerKPIv2_L2RT_cni51678_performance_4CC_24UE_TDD125_ABIL_CFG_NSA_"
            "FDPRL_D_CNI51678_ACTIVATED_2020.08.07_11.29.38_bdab787.json"
        )
        test_filter = (
            "?filter=perf_5g_x0020_Test/FormatedTestName eq "
            "'ft425_1BM_1CC_1UE_1UEsched_TDD125_ABIL_NSA'"
        )
        commit_filter = "perf_5g_x0020_Test/FormatedCommitShortName eq '0751768'"
        test_view_url, history_view_url = TestCheck.get_power_bi_url(test_filter, commit_filter)
        filekpi_url = (
            "https://5gwebserver.dyn.nesc.nokia.net/CinqG/perfport/"
            f"2019/04/04/00.14.11/{self.test_info['fileKPI']}"
        )

        # voting for L2PSUL.Scheduler.postScheduler.max = false so no critical error
        message_major = (
            "\nWarning : TimeMarkerKPIv2_L2RT_<b>cni51678_performance_4CC_24UE_TDD125_ABIL_CFG_"
            "NSA_FDPRL_D_CNI51678_ACTIVATED</b>_2020.08.07_11.29.38_bdab787.json with reference "
            "test reference_kpi_file_1.json, reference_kpi_file_2.json, reference_kpi_file_3.json :"
            "\nL2PSDL.Scheduler.max = 92.44 us exceeds cpu increase of 20 us with 47.0 us"
            f'\n<a href="{test_view_url}">Power BI test view</a>, '
            f'<a href="{history_view_url}">Power BI history view</a>, '
            f'<a href="{filekpi_url}">Timemarker KPI file</a>\n'
        )

        t_object = CPUIncreaseAbsolute(
            self.test_json[
                "thresh_not_exceeded_for_L2PSDL_Scheduler_TTI125_and_no_thresh_for_TTI500"
            ],
            self.test_info,
            self.branch,
            self.fixture_last_test,
        )

        self.assertEqual(
            t_object.previous_test_ids_str,
            f"{self.fixture_last_test[0]['id']}, {self.fixture_last_test[1]['id']}, "
            f"{self.fixture_last_test[2]['id']}",
        )
        self.assertEqual(
            t_object.previous_kpi_files_str,
            f'{self.fixture_last_test[0]["fileKPI"]}, {self.fixture_last_test[1]["fileKPI"]}, '
            f'{self.fixture_last_test[2]["fileKPI"]}',
        )

        self.kpi_columns = {
            "testId": "122",
            "component": "L2PSUL",
            "componentInstance": "1",
            "subComponent1": "Scheduler",
            "subComponent2": "postScheduler",
            "subComponent3": "All",
            "subComponent4": "All",
            "min": "41.06",
            "avg": "64.12",
            "95p": "82.89",
            "max": "110.33",
        }
        t_object.check_kpi_scheduler(self.kpi_columns, lambda x, y: [{"max": 10.0}])

        self.kpi_columns = {
            "testId": "123",
            "component": "L2PSDL",
            "componentInstance": "1",
            "subComponent1": "Scheduler",
            "subComponent2": "All",
            "subComponent3": "All",
            "subComponent4": "All",
            "min": "63.81",
            "avg": "73.95",
            "95p": "89.02",
            "max": "92.44",
        }
        t_object.check_kpi_scheduler(self.kpi_columns, lambda x, y: [{"max": 47.0}])
        t_object.check_kpi_scheduler(self.kpi_columns, lambda x, y: [])
        t_object.check_kpi_scheduler(self.kpi_columns, lambda x, y: [{"max": None}])
        t_object.previous_test_ids_str = None
        t_object.check_kpi_scheduler(self.kpi_columns, lambda x, y: [{"max": 30.0}])
        t_object.get_messages()

        self.assertEqual(
            t_object.message,
            {"Critical": "", "Major": message_major, "Minor": ""},
        )
        self.assert_mock_stdout_calls(check_str="cpu increase")

    def test_processing_time_checker(self):
        processing_time_dict = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ptScheduling",
            "min": 87.936,
            "avg": 110.578,
            "95p": 124.64,
            "max": 128.592,
            "kpiType": "ProcessingTime",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_"
                "ABIL</b>_2019.04.04_00.14.11_32fb44d.json with reference test file98, "
                "file99 :\nProcessingTime.L2PSDL.ptScheduling.max = 128.592 us exceeds "
                "cpu increase of 20 us with 100 us\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            CPUIncreaseAbsolute,
            processing_time_dict,
            expected_msg,
            kpi_with_name=True,
            lambda_return_dict={"max": 100},
        )

    def test_lead_time_checker(self):
        lead_time_dict = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ltBetweenTwoConsecutiveSlotSynchroInds",
            "95p": 129.232,
            "avg": 125.867,
            "max": 130.168,
            "min": 120.528,
            "kpiType": "LeadTime",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_"
                "ABIL</b>_2019.04.04_00.14.11_32fb44d.json with reference test file98, "
                "file99 :\nLeadTime.L2PSDL.ltBetweenTwoConsecutiveSlotSynchroInds.max = "
                "130.168 us exceeds cpu increase of 20 us with 100 us\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            CPUIncreaseAbsolute,
            lead_time_dict,
            expected_msg,
            kpi_with_name=True,
            lambda_return_dict={"max": 100},
        )

    def test_proc_time_per_eo_checker(self):
        proc_time_per_eo_dict = {
            "testId": 100,
            "component": "L2PSUL",
            "cellGroupInstance": 1,
            "coreId": "Core6",
            "eoNameAndInstance": "L2PsUlSch-1",
            "isProbe": True,
            "ventilated": False,
            "subComponent1": "EO_L2_PS_UL_MESSAGE",
            "subComponent2": "Common_SlotSynchroInd",
            "subComponent3": "EO_L2_PS_PRE_SCHEDULER",
            "subComponent4": None,
            "95p": 21.96,
            "avg": 21.871,
            "max": 22.12,
            "min": 21.736,
            "kpiType": "ProcessingTimePerEO",
        }
        expected_msg = {
            "Critical": (
                "\nError : TimeMarkerKPI_L2RT_<b>ft425_simpleTraffic_1CC_100UE_TDD125_"
                "ABIL</b>_2019.04.04_00.14.11_32fb44d.json with reference test file98, "
                "file99 :\nProcessingTimePerEO.L2PSUL.L2PsUlSch-1.EO_L2_PS_UL_MESSAGE."
                "Common_SlotSynchroInd.EO_L2_PS_PRE_SCHEDULER.95p = 21.96 us exceeds "
                "cpu increase of 20 us with 0.01 us\n"
            ),
            "Major": "",
            "Minor": "",
        }
        self.common_test_time_checker(
            CPUIncreaseAbsolute,
            proc_time_per_eo_dict,
            expected_msg,
            kpi_with_name=False,
            lambda_return_dict={"95p": 0.01},
        )


class TestBoxPlotIncrease(TestCheck):
    def setUp(self):
        TestCheck.setUp(self)
        self.test_info["formatted_test_name_like"] = "%ft000_perfTestSA_4CC%LA_HARQ_REF%"
        del self.test_info["fileKPI"]
        self.ref_kpi = None
        self.current_kpi = None
        self.fixture_last_test = [
            {"id": 97, "fileKPI": "reference_kpi_file_1.json", "key3": "value1.3"},
            {"id": 98, "fileKPI": "reference_kpi_file_2.json", "key3": "value3.3"},
            {"id": 99, "fileKPI": "reference_kpi_file_3.json", "key3": "value3.3"},
        ]

        self.mock["context"].return_value.select_list_into_one_table.side_effect = (
            self.mock_context_side_effect
        )

    def mock_context_side_effect(
        self, table_name, select_col, where_dict, where_str, group_by_str, limit_result
    ):
        # pylint: disable=unused-argument
        return [
            {"softwareCommit": "18ddb21429e7414a64a92608859317bca1088807", "kpi": self.ref_kpi},
            {"softwareCommit": "0751768e54b6c0c9255c8fced378c5854f5f956f", "kpi": self.current_kpi},
        ]

    def common_no_error_or_alarm_test_branch_5g21a(
        self, ref_kpi, current_kpi, only_one_compute=False
    ):
        self.ref_kpi = ref_kpi
        self.current_kpi = current_kpi

        self.test_info["commitHashDate"] = "curentCommitHashAndDate"
        self.test_info["refCommitHashDate"] = "refCurentCommitHashAndDate"

        boxplot_checker = BoxPlotIncrease(
            self.test_json[
                "thresh_not_exceeded_for_L2PSDL_Scheduler_TTI125_and_no_thresh_for_TTI500"
            ],
            self.test_info,
            "rel/5G21A",
        )
        self.assertIsInstance(boxplot_checker, BoxPlotIncrease)
        if only_one_compute:
            self.assertDictEqual(
                boxplot_checker.check_kpi_scheduler(
                    "18ddb21429e7414a64a92608859317bca1088807",
                    self.mock["context"].return_value.select_list_into_one_table,
                    previous_commit_kpi={
                        "L2PSDL.avg": ref_kpi,
                        "L2PSDL.Scheduler.max": ref_kpi,
                        "L2PSUL.Scheduler.fdPucch.3.95p": ref_kpi,
                        "L2PSUL.Scheduler.postScheduler.95p": ref_kpi,
                    },
                ),
                {
                    "L2PSDL.avg": current_kpi,
                    "L2PSDL.Scheduler.max": current_kpi,
                    "L2PSUL.Scheduler.fdPucch.3.95p": current_kpi,
                    "L2PSUL.Scheduler.postScheduler.95p": current_kpi,
                },
            )
        else:
            self.assertDictEqual(
                boxplot_checker.check_kpi_scheduler(
                    "18ddb21429e7414a64a92608859317bca1088807",
                    self.mock["context"].return_value.select_list_into_one_table,
                ),
                {
                    "L2PSDL.avg": current_kpi,
                    "L2PSDL.Scheduler.max": current_kpi,
                    "L2PSUL.Scheduler.fdPucch.3.95p": current_kpi,
                    "L2PSUL.Scheduler.postScheduler.95p": current_kpi,
                },
            )

        self.assertEqual(
            boxplot_checker.get_bold_test_name(),
            f"<b>{self.test_info['formatted_test_name_like']}</b>, "
            + "current commit is <b>curentCommitHashAndDate</b> and "
            + "reference commit is <b>refCurentCommitHashAndDate</b>",
        )
        self.assertEqual(boxplot_checker.ref_kpi_value, ref_kpi)
        self.assertEqual(boxplot_checker.new_kpi_value, current_kpi)
        self.mock["report"].return_value.error.assert_not_called()
        self.mock["report"].return_value.alarm.assert_not_called()

        if only_one_compute:
            list_into_one_table_calls = [
                call(
                    group_by_str="softwareCommit",
                    limit_result=2,
                    select_col=["softwareCommit", "AVG(avg) as kpi"],
                    table_name="Test AS t, KpiScheduler AS k",
                    where_dict={
                        "=": {
                            "component": "L2PSDL",
                            "subComponent1": "All",
                            "subComponent2": "All",
                            "subComponent3": "All",
                            "subComponent4": "All",
                            "testType": "Endurance",
                            "softwareCommit": "0751768e54b6c0c9255c8fced378c5854f5f956f",
                        },
                        "like": {"fileKPI": "%ft000_perfTestSA_4CC%LA_HARQ_REF%"},
                    },
                    where_str="k.testId=t.id",
                ),
                call(
                    group_by_str="softwareCommit",
                    limit_result=2,
                    select_col=["softwareCommit", "AVG(max) as kpi"],
                    table_name="Test AS t, KpiScheduler AS k",
                    where_dict={
                        "=": {
                            "component": "L2PSDL",
                            "subComponent1": "Scheduler",
                            "subComponent2": "All",
                            "subComponent3": "All",
                            "subComponent4": "All",
                            "testType": "Endurance",
                            "softwareCommit": "0751768e54b6c0c9255c8fced378c5854f5f956f",
                        },
                        "like": {"fileKPI": "%ft000_perfTestSA_4CC%LA_HARQ_REF%"},
                    },
                    where_str="k.testId=t.id",
                ),
                call(
                    group_by_str="softwareCommit",
                    limit_result=2,
                    select_col=["softwareCommit", "AVG(95p) as kpi"],
                    table_name="Test AS t, KpiScheduler AS k",
                    where_dict={
                        "=": {
                            "component": "L2PSUL",
                            "subComponent1": "Scheduler",
                            "subComponent2": "postScheduler",
                            "subComponent3": "All",
                            "subComponent4": "All",
                            "testType": "Endurance",
                            "softwareCommit": "0751768e54b6c0c9255c8fced378c5854f5f956f",
                        },
                        "like": {"fileKPI": "%ft000_perfTestSA_4CC%LA_HARQ_REF%"},
                    },
                    where_str="k.testId=t.id",
                ),
                call(
                    group_by_str="softwareCommit",
                    limit_result=2,
                    select_col=["softwareCommit", "AVG(95p) as kpi"],
                    table_name="Test AS t, KpiScheduler AS k",
                    where_dict={
                        "=": {
                            "component": "L2PSUL",
                            "subComponent1": "Scheduler",
                            "subComponent2": "fdPucch",
                            "subComponent3": "3",
                            "subComponent4": "All",
                            "testType": "Endurance",
                            "softwareCommit": "0751768e54b6c0c9255c8fced378c5854f5f956f",
                        },
                        "like": {"fileKPI": "%ft000_perfTestSA_4CC%LA_HARQ_REF%"},
                    },
                    where_str="k.testId=t.id",
                ),
            ]
        else:
            list_into_one_table_calls = [
                call(
                    group_by_str="softwareCommit",
                    limit_result=2,
                    select_col=["softwareCommit", "AVG(avg) as kpi"],
                    table_name="Test AS t, KpiScheduler AS k",
                    where_dict={
                        "=": {
                            "component": "L2PSDL",
                            "subComponent1": "All",
                            "subComponent2": "All",
                            "subComponent3": "All",
                            "subComponent4": "All",
                            "testType": "Endurance",
                        },
                        "like": {"fileKPI": "%ft000_perfTestSA_4CC%LA_HARQ_REF%"},
                        "in": {
                            "softwareCommit": "'18ddb21429e7414a64a92608859317bca1088807', "
                            "'0751768e54b6c0c9255c8fced378c5854f5f956f'"
                        },
                    },
                    where_str="k.testId=t.id",
                ),
                call(
                    group_by_str="softwareCommit",
                    limit_result=2,
                    select_col=["softwareCommit", "AVG(max) as kpi"],
                    table_name="Test AS t, KpiScheduler AS k",
                    where_dict={
                        "=": {
                            "component": "L2PSDL",
                            "subComponent1": "Scheduler",
                            "subComponent2": "All",
                            "subComponent3": "All",
                            "subComponent4": "All",
                            "testType": "Endurance",
                        },
                        "like": {"fileKPI": "%ft000_perfTestSA_4CC%LA_HARQ_REF%"},
                        "in": {
                            "softwareCommit": "'18ddb21429e7414a64a92608859317bca1088807', "
                            "'0751768e54b6c0c9255c8fced378c5854f5f956f'"
                        },
                    },
                    where_str="k.testId=t.id",
                ),
                call(
                    group_by_str="softwareCommit",
                    limit_result=2,
                    select_col=["softwareCommit", "AVG(95p) as kpi"],
                    table_name="Test AS t, KpiScheduler AS k",
                    where_dict={
                        "=": {
                            "component": "L2PSUL",
                            "subComponent1": "Scheduler",
                            "subComponent2": "postScheduler",
                            "subComponent3": "All",
                            "subComponent4": "All",
                            "testType": "Endurance",
                        },
                        "like": {"fileKPI": "%ft000_perfTestSA_4CC%LA_HARQ_REF%"},
                        "in": {
                            "softwareCommit": "'18ddb21429e7414a64a92608859317bca1088807', "
                            "'0751768e54b6c0c9255c8fced378c5854f5f956f'"
                        },
                    },
                    where_str="k.testId=t.id",
                ),
                call(
                    group_by_str="softwareCommit",
                    limit_result=2,
                    select_col=["softwareCommit", "AVG(95p) as kpi"],
                    table_name="Test AS t, KpiScheduler AS k",
                    where_dict={
                        "=": {
                            "component": "L2PSUL",
                            "subComponent1": "Scheduler",
                            "subComponent2": "fdPucch",
                            "subComponent3": "3",
                            "subComponent4": "All",
                            "testType": "Endurance",
                        },
                        "like": {"fileKPI": "%ft000_perfTestSA_4CC%LA_HARQ_REF%"},
                        "in": {
                            "softwareCommit": "'18ddb21429e7414a64a92608859317bca1088807', "
                            "'0751768e54b6c0c9255c8fced378c5854f5f956f'"
                        },
                    },
                    where_str="k.testId=t.id",
                ),
            ]

        self.mock["context"].return_value.select_list_into_one_table.assert_has_calls(
            list_into_one_table_calls
        )
        self.assertEqual(self.mock["context"].return_value.select_list_into_one_table.call_count, 4)
        self.mock["context"].return_value.select_list_into_one_table.reset_mock()

        return boxplot_checker

    def test_check_kpi_scheduler_with_major_exceeded(self):
        ref_kpi = 107.7561
        current_kpi = 109.7591
        # voting = true for L2PSUL.Scheduler.postScheduler
        boxplot_checker = self.common_no_error_or_alarm_test_branch_5g21a(ref_kpi, current_kpi)
        self.assertDictEqual(boxplot_checker.message, {"Critical": "", "Major": "", "Minor": ""})

        ref_kpi = 107.7561
        current_kpi = 120.7591
        boxplot_checker = self.common_no_error_or_alarm_test_branch_5g21a(
            ref_kpi, current_kpi, only_one_compute=True
        )
        self.maxDiff = None
        self.assertEqual(boxplot_checker.message["Critical"], "")
        self.assertEqual(boxplot_checker.message["Minor"], "")
        self.assertEqual(
            boxplot_checker.message["Major"],
            "\nL2PSDL.avg = 120.7591 us exceeds cpu increase of 10 us with 107.7561 us"
            "\nL2PSUL.Scheduler.postScheduler.95p = 120.7591 us exceeds cpu increase "
            "of 10 us with 107.7561 us\nL2PSUL.Scheduler.fdPucch.3.95p = 120.7591 us "
            "exceeds cpu increase of 10 us with 107.7561 us",
        )

    def common_for_exception(self, ref_commit, message):
        self.test_info["formatted_test_name_like"] = "%ft000_perfTestSA_4CC%LA_HARQ_REF%"
        boxplot_checker = BoxPlotIncrease(
            self.test_json[
                "thresh_not_exceeded_for_L2PSDL_Scheduler_TTI125_and_no_thresh_for_TTI500"
            ],
            self.test_info,
            self.branch,
        )
        self.assertIsInstance(boxplot_checker, BoxPlotIncrease)
        self.assertRaisesRegex(
            SystemError,
            message,
            boxplot_checker.check_kpi_scheduler,
            ref_commit,
            lambda table_name, select_col, where_dict, where_str, group_by_str, limit_result: [
                SystemError
            ],
        )

        self.mock["report"].return_value.error.assert_not_called()
        self.mock["report"].return_value.alarm.assert_not_called()

    def test_select_function_except(self):
        ref_commit = "18ddb21429e7414a64a92608859317bca1088807"
        self.common_for_exception(
            ref_commit,
            f"Debug: Endurance kpi check exception for kpi: L2PSDL.avg ref commit id {ref_commit}",
        )

    def test_reference_is_none(self):
        self.common_for_exception(
            None, "Debug: no previous_endurance_commit was set to BoxPlotIncrease check"
        )
