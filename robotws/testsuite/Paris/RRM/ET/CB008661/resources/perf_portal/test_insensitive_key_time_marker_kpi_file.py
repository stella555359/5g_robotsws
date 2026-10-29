import os
import unittest
import json
from copy import deepcopy
from unittest.mock import patch, Mock, DEFAULT
from time_marker_kpi_file import TimeMarkerKPIFile
from context import Context
from datetime import datetime


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

        self.fixture["initial_json_file"] = (
            f"{os.path.dirname(__file__)}/test_data/"
            f"TimeMarkerKPIv2_L2RT_ft000_perfOnFuse_4CC_48UE_TDD125_ABIL_"
            "CFG_SA_LA_HARQ_REF_0_0_2022.04.05_14.23.15_fcea893.json"
        )
        self.fixture["key_changed_json_file"] = (
            f"{os.path.dirname(__file__)}/test_data"
            f"/TimeMarkerKPIv2_L2RT_ft000_perfOnFuse_4CC_48UE_TDD125_ABIL_"
            f"CFG_SA_LA_HARQ_REF_0_0_2022.04.05_14.23.15_fcea893_keyChanged.json"
        )

        self.fixture["json_file"] = None
        self.addCleanup(patch.stopall)

    def common_compute_kpi_file(self):
        nb_max = 1

        with open(self.fixture["json_file"]) as f_h:
            content_json_file = json.load(f_h)

        time_marker_kpi_file = TimeMarkerKPIFile(content_json_file, self.mock["context"])

        start_date = datetime.utcnow()
        for i in range(0, nb_max):
            time_marker_kpi_file.compute_kpi_file()
        self.assertEqual(self.mock["TableTest_init"].call_count, 1 * nb_max)
        self.assertEqual(self.mock["TableKpiLeadTime_init"].call_count, 13 * nb_max)
        self.assertEqual(self.mock["TableKpiProcessingTime_init"].call_count, 4 * nb_max)
        self.assertEqual(self.mock["TableKpiValues_init"].call_count, 35 * nb_max)
        self.assertEqual(self.mock["TableKpiProcessingTimePerEO_init"].call_count, 60 * nb_max)
        self.assertEqual(self.mock["TableKpiMiddleware_init"].call_count, 6 * nb_max)

        end_time = datetime.utcnow()
        print(f"Delta time: {end_time - start_date}", flush=True)

    def test_compute_kpi_file(self):
        self.fixture["json_file"] = self.fixture["initial_json_file"]
        print("Standard keys:", flush=True)
        self.common_compute_kpi_file()

    def test_key_changed_compute_kpi_file(self):
        self.fixture["json_file"] = self.fixture["key_changed_json_file"]
        print("Key changed", flush=True)
        self.common_compute_kpi_file()
