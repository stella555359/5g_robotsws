import os
import unittest
import json
from copy import deepcopy
from unittest.mock import patch, Mock, DEFAULT, call
from time_marker_kpi_file import TimeMarkerKPIFile
from context import Context
from context import ExceptionNotNeedToSendByMail


class Test(unittest.TestCase):
    @staticmethod
    def get_kpi_type(kpi_instance):
        res_dict = {
            "TableKpiLeadTime": "LeadTime",
            "TableKpiProcessingTime": "ProcessingTime",
            "TableKpiValues": "Values",
            "TableKpiProcessingTimePerEO": "ProcessingTimePerEO",
            "TableKpiMiddleware": "Middleware",
        }
        return res_dict[kpi_instance]

    def table_without_sub_level_deep_copy_args(self, mock_init_name, args):
        """
        Copy args from Mock tableKpiLeadTime or tableKpiProcessingTime
        else all call_arg_list have same content (dict is mutable)
        For param1 it's a Mock and I'm not able to have id if always change
        :param mock_init_name:
        :param args:
        :return:
        """
        mock_instance = mock_init_name.replace("_init", "")
        if isinstance(args[0], Context):
            self.mock[mock_init_name](
                self.mock["context"].return_value, deepcopy(args[1]), deepcopy(args[2])
            )
        columns_dict = deepcopy(args[1])
        columns_dict.update(args[2])

        self.mock[mock_instance].return_value.columns = columns_dict
        self.mock[mock_instance].return_value.get_kpi_type.return_value = self.get_kpi_type(
            mock_instance
        )
        return DEFAULT

    def table_test_deep_copy_args(self, *args):
        self.mock["TableTest_init"](self.mock["context"].return_value, deepcopy(args[1]))
        self.mock["TableTest"].return_value.columns = self.fixture["test_info"]
        self.mock["TableTest"].return_value.auto_increment = {"value": 100}
        self.mock["TableTest"].return_value.search_last_id.return_value = self.fixture["last_ids"]
        return DEFAULT

    def table_kpi_lead_time_deep_copy_args(self, *args):
        return self.table_without_sub_level_deep_copy_args("TableKpiLeadTime_init", args)

    def table_kpi_processing_time_deep_copy_args(self, *args):
        return self.table_without_sub_level_deep_copy_args("TableKpiProcessingTime_init", args)

    def table_kpi_middleware_deep_copy_args(self, *args):
        return self.table_without_sub_level_deep_copy_args("TableKpiMiddleware_init", args)

    def table_kpi_values_deep_copy_args(self, *args):
        return self.table_without_sub_level_deep_copy_args("TableKpiValues_init", args)

    def table_kpi_processing_time_per_eo_deep_copy_args(self, *args):
        return self.table_without_sub_level_deep_copy_args("TableKpiProcessingTimePerEO_init", args)

    def setUp(self):
        self.fixture = {
            "test_info": {
                "board": "master",
                "CCNumber": 1,
                "id": 100,
                "testStatus": "NA",
            },
            "last_ids": [{"id": 99}],
        }

        self.mock = {
            "context": patch("context.Context", autospec=True).start(),
            "TableTest_init": Mock(),
        }

        self.mock["TableTest_init"].search_last_id.return_value = self.fixture["last_ids"]
        self.mock["TableTest"] = patch("time_marker_kpi_file.TableTest", autospec=True).start()
        self.mock["TableTest"].side_effect = self.table_test_deep_copy_args

        self.mock["TableKpiLeadTime_init"] = Mock(columns={"95p": 1.0})
        self.mock["TableKpiLeadTime"] = patch(
            "time_marker_kpi_file.TableKpiLeadTime", autospec=True
        ).start()
        self.mock["TableKpiLeadTime"].side_effect = self.table_kpi_lead_time_deep_copy_args

        self.mock["TableKpiProcessingTime_init"] = Mock(columns={"95p": 1.0})
        self.mock["TableKpiProcessingTime"] = patch(
            "time_marker_kpi_file.TableKpiProcessingTime", autospec=True
        ).start()
        self.mock["TableKpiProcessingTime"].side_effect = (
            self.table_kpi_processing_time_deep_copy_args
        )

        self.mock["TableKpiValues_init"] = Mock(columns={"95p": 1.0})
        self.mock["TableKpiValues"] = patch(
            "time_marker_kpi_file.TableKpiValues", autospec=True
        ).start()
        self.mock["TableKpiValues"].side_effect = self.table_kpi_values_deep_copy_args

        self.mock["TableKpiProcessingTimePerEO_init"] = Mock(columns={"95p": 1.0})
        self.mock["TableKpiProcessingTimePerEO"] = patch(
            "time_marker_kpi_file.TableKpiProcessingTimePerEO", autospec=True
        ).start()
        self.mock["TableKpiProcessingTimePerEO"].side_effect = (
            self.table_kpi_processing_time_per_eo_deep_copy_args
        )

        self.mock["TableKpiMiddleware_init"] = Mock(columns={"95p": 1.0})
        self.mock["TableKpiMiddleware"] = patch(
            "time_marker_kpi_file.TableKpiMiddleware", autospec=True
        ).start()
        self.mock["TableKpiMiddleware"].side_effect = self.table_kpi_middleware_deep_copy_args

        self.mock["stdout"] = patch("sys.stdout.write").start()
        self.mock["stderr"] = patch("sys.stderr.write").start()

        self.fixture["json_file_version_1"] = (
            "test_data/TimeMarkerKPI_L2RT_ft425_"
            "simpleTraffic_1CC_1UE_TDD125_ABIL_2019.05.03_08.40.28.json"
        )
        with open(self.fixture["json_file_version_1"]) as f_h:
            self.fixture_content_json_file_version_1 = json.load(f_h)
        self.fixture["json_file_version_2"] = (
            "test_data/TimeMarkerKPIv2_L2RT_ft425_"
            "simpleTraffic_1CC_1UE_TDD125_ABIL_2019.05.03_08.40.29.json"
        )
        with open(self.fixture["json_file_version_2"]) as f_h:
            self.fixture["content_json_file_version_2"] = json.load(f_h)
        self.fixture["json_file_version_2_multi_EO"] = (
            "test_data/TimeMarkerKPIv2_L2RT_ft425_"
            "simpleTraffic_1CC_10UE_TDD125_ABIL_2019.05.03_08.40.30.json"
        )
        with open(self.fixture["json_file_version_2_multi_EO"]) as f_h:
            self.fixture["content_json_file_version_2_multi_EO"] = json.load(f_h)

        # For reformatting KPI: FIVEG_FTPS-30146
        result_file = (
            "test_data/"
            "ResForTimeMarkerKPIv2_L2RT_ft123_plusExtendedPlusSync_"
            "4CC_48UE_TDD125_ABIL_CFG_SA_LA_HARQ_REF_0_0.json"
        )
        with open(result_file, "r") as result_fh:
            self.fixture["json_result_content"] = json.load(result_fh)

        self.addCleanup(patch.stopall)

    # For reformatting KPI: FIVEG_FTPS-30146
    def get_database_obj_calls(self, result_key):
        res_list = []
        for res_dict in self.fixture["json_result_content"]["TimeMarkerKpiFileDatabaseObject"][
            result_key
        ]:
            if "kpi_env" in res_dict:
                res_list.append(
                    call(
                        self.mock["context"].return_value, res_dict["kpi_env"], res_dict["kpi_data"]
                    )
                )
            else:
                res_list.append(call(self.mock["context"].return_value, res_dict["data_input"]))

        return res_list

    def get_launch_check_calls(self, result_key, kpi_type):
        res_list = []
        for res_dict in self.fixture["json_result_content"]["TimeMarkerKpiFileDatabaseObject"][
            result_key
        ]:
            kpi_obj_columns = res_dict["kpi_env"]
            kpi_obj_columns.update(res_dict["kpi_data"])
            kpi_obj_columns["kpiType"] = kpi_type

            if result_key in ["TableKpiLeadTime", "TableKpiProcessingTime", "TableKpiMiddleware"]:
                res_list.append(
                    call(
                        kpi_obj_columns,
                        self.mock[result_key].return_value.get_reference_kpi_list,
                        kpi_with_name=True,
                    )
                )
            else:
                if not kpi_obj_columns["ventilated"]:
                    res_list.append(
                        call(
                            kpi_obj_columns,
                            self.mock[result_key].return_value.get_reference_kpi_list,
                        )
                    )

        return res_list

    def common_check_init(self, table_name):
        call_list = self.get_database_obj_calls(table_name)
        self.mock[f"{table_name}_init"].assert_has_calls(call_list)
        self.assertEqual(self.mock[f"{table_name}_init"].call_count, len(call_list))

    def common_insert_test_info_and_get_l2ps_results(self, time_marker_kpi_content):
        time_marker_kpi_obj = TimeMarkerKPIFile(
            time_marker_kpi_content, self.mock["context"].return_value
        )

        time_marker_kpi_obj.compute_kpi_file()

        # insert tableTest
        self.common_check_init("TableTest")
        self.mock["TableTest"].return_value.search_last_id.assert_called_once_with()
        self.mock["context"].return_value.init_check.assert_called_once_with(
            self.fixture["test_info"], self.fixture["last_ids"]
        )

        # insert all kpis
        self.common_check_init("TableKpiLeadTime")
        self.common_check_init("TableKpiProcessingTime")
        self.common_check_init("TableKpiValues")
        self.common_check_init("TableKpiProcessingTimePerEO")
        self.common_check_init("TableKpiMiddleware")

        launch_check_calls = (
            self.get_launch_check_calls("TableKpiLeadTime", "LeadTime")
            + self.get_launch_check_calls("TableKpiProcessingTime", "ProcessingTime")
            + self.get_launch_check_calls("TableKpiValues", "Values")
            + self.get_launch_check_calls("TableKpiProcessingTimePerEO", "ProcessingTimePerEO")
            + self.get_launch_check_calls("TableKpiMiddleware", "Middleware")
        )
        self.mock["context"].return_value.launch_check.assert_has_calls(
            launch_check_calls, any_order=True
        )
        self.assertEqual(
            self.mock["context"].return_value.launch_check.call_count, len(launch_check_calls)
        )

    def test_insert_test_info_and_get_l2ps_results(self):
        kpi_file_to_use = (
            f"{os.path.dirname(__file__)}/" f"{self.fixture['json_result_content']['KpiFileToUse']}"
        )
        with open(kpi_file_to_use, "r") as kpi_fh:
            time_marker_kpi_content = json.load(kpi_fh)

        self.common_insert_test_info_and_get_l2ps_results(time_marker_kpi_content)

    def test_insert_test_info_and_get_l2ps_results_middleware_dict(self):
        kpi_file_to_use = (
            f"{os.path.dirname(__file__)}/" f"{self.fixture['json_result_content']['KpiFileToUse']}"
        )
        with open(kpi_file_to_use, "r") as kpi_fh:
            time_marker_kpi_content = json.load(kpi_fh)

        first_middleware = time_marker_kpi_content["middlewareResults"][0]
        time_marker_kpi_content["middlewareResults"] = first_middleware

        self.common_insert_test_info_and_get_l2ps_results(time_marker_kpi_content)

    def test_cell_group_instance_list_with_empty_dict(self):
        kpi_file_to_use = (
            f"{os.path.dirname(__file__)}/" f"{self.fixture['json_result_content']['KpiFileToUse']}"
        )
        with open(kpi_file_to_use, "r") as kpi_fh:
            time_marker_kpi_content = json.load(kpi_fh)

        time_marker_kpi_content["l2psResults"] = [{}]

        time_marker_kpi_obj = TimeMarkerKPIFile(
            time_marker_kpi_content, self.mock["context"].return_value
        )

        self.assertRaisesRegex(
            ExceptionNotNeedToSendByMail,
            "No KPI data found into ",
            time_marker_kpi_obj.compute_kpi_file,
        )

        self.common_check_init("TableTest")
        self.mock["TableTest"].return_value.search_last_id.assert_called_once_with()
        self.mock["context"].return_value.init_check.assert_called_once_with(
            self.fixture["test_info"], self.fixture["last_ids"]
        )

        for table_name in [
            "TableKpiLeadTime",
            "TableKpiProcessingTime",
            "TableKpiValues",
            "TableKpiProcessingTimePerEO",
            "TableKpiMiddleware",
        ]:
            self.mock[f"{table_name}_init"].assert_not_called()

        self.mock["context"].return_value.launch_check.assert_not_called()
