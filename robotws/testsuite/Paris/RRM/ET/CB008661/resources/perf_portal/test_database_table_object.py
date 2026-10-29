import unittest
import os
from unittest.mock import patch
from datetime import datetime, timedelta
from copy import deepcopy

from context import Context
from database_table_object import DatabaseTable
from database_table_object import TableTest
from database_table_object import TableThresholdAlarm
from database_table_object import TableWithoutSubLevel
from database_table_object import TableKpiLeadTime
from database_table_object import TableKpiProcessingTime
from database_table_object import TableKpiMiddleware
from database_table_object import TableWithSubLevel
from database_table_object import TableKpiValues
from database_table_object import TableKpiProcessingTimePerEO
from database_table_object import TableRelatedCommit


CURRENT_DATE_TIME = datetime.utcnow()


class TestDatabaseTable(unittest.TestCase):
    def setUp(self):
        self.context_mocked = patch("context.Context", autospec=True).start()
        self.context_mocked.save_into_db.side_effect = [1000, 1001, 1002, 1003]

        self.mock_datetime = patch("database_table_object.datetime").start()
        self.mock_datetime.utcnow.return_value = CURRENT_DATE_TIME

        self.addCleanup(patch.stopall)

        self.fixture_env_dict_for_check_mandatory_param = {}
        self.fixture_param_dict_for_check_mandatory_param = {}
        self.mock_stdout = patch("sys.stdout.write").start()

    def set_attrib_key(self, attrib, key, val, delete=False):
        if key:
            attrib_dict = getattr(self, attrib)
            if delete:
                del attrib_dict[key]
            else:
                attrib_dict[key] = val
            setattr(self, attrib, attrib_dict)

    def check_mandatory_bool(self, attrib, key, instance_func):
        self.set_attrib_key(attrib, key, "")
        self.assertRaisesRegex(ValueError, "mandatory boolean missing", instance_func)
        self.set_attrib_key(attrib, key, None)
        self.assertRaisesRegex(ValueError, "mandatory boolean missing", instance_func)
        self.set_attrib_key(attrib, key, None, delete=True)
        self.assertRaisesRegex(KeyError, key, instance_func)
        self.mock_stdout.assert_not_called()

    def check_mandatory_int(self, attrib, key, instance_func):
        self.set_attrib_key(attrib, key, "")
        self.assertRaisesRegex(ValueError, "mandatory and positive int missing", instance_func)
        self.set_attrib_key(attrib, key, "0")
        self.assertRaisesRegex(ValueError, "mandatory and positive int missing", instance_func)
        self.set_attrib_key(attrib, key, 0)
        self.assertRaisesRegex(ValueError, "mandatory and positive int missing", instance_func)
        self.set_attrib_key(attrib, key, None)
        self.assertRaisesRegex(ValueError, "mandatory and positive int missing", instance_func)
        self.set_attrib_key(attrib, key, "not an int")
        self.assertRaisesRegex(ValueError, "invalid literal for int()", instance_func)
        self.mock_stdout.assert_not_called()

    def check_mandatory_str(self, attrib, key, instance_func):
        self.set_attrib_key(attrib, key, "")
        self.assertRaisesRegex(
            ValueError, "mandatory, non null and non empty str missing", instance_func
        )
        self.set_attrib_key(attrib, key, None)
        self.assertRaisesRegex(
            ValueError, "mandatory, non null and non empty str missing", instance_func
        )
        self.set_attrib_key(attrib, key, None, delete=True)
        self.assertRaisesRegex(KeyError, key, instance_func)
        self.mock_stdout.assert_not_called()

    def test_init_ok(self):
        db_table_obj = DatabaseTable(self.context_mocked, "Test")
        self.assertIsNotNone(db_table_obj)
        self.assertIsInstance(getattr(db_table_obj, "context"), Context)
        self.assertEqual(db_table_obj.table_name, "Test")
        self.assertDictEqual(db_table_obj.auto_increment, {})
        self.assertIsInstance(db_table_obj.columns, dict)
        self.assertDictEqual(db_table_obj.columns, {})
        db_table_obj.save_into_db()
        self.assertDictEqual(db_table_obj.auto_increment, {})
        self.assertEqual("{}".format(db_table_obj), "Table Test: auto_increment={}, columns={}")
        self.mock_stdout.assert_not_called()


class TestTableRelatedCommit(TestDatabaseTable):
    def setUp(self):
        TestDatabaseTable.setUp(self)
        self.fixture_table_name = "RelatedCommit"
        self.fixture_columns = {
            "softwareBranch": "master",
            "softwareCommit": "abcdefghijklmnopqr004",
            "softwareCommitDate": "2022-02-21 10:00:00",
            "relatedCommit": "abcdefghijklmnopqr007",
        }

    def instance_table_related_commit_obj(self):
        return TableRelatedCommit(
            self.context_mocked,
            self.fixture_columns["softwareBranch"],
            self.fixture_columns["softwareCommit"],
            self.fixture_columns["softwareCommitDate"],
            self.fixture_columns["relatedCommit"],
        )

    def test_init_ok_and_save(self):
        related_commit_table_obj = self.instance_table_related_commit_obj()

        self.assertIsNotNone(related_commit_table_obj)
        self.assertIsInstance(getattr(related_commit_table_obj, "context"), Context)
        self.assertIs(related_commit_table_obj.context, self.context_mocked)
        self.assertIsInstance(related_commit_table_obj.columns, dict)
        self.assertDictEqual(related_commit_table_obj.columns, self.fixture_columns)
        self.assertEqual(related_commit_table_obj.table_name, self.fixture_table_name)
        self.assertDictEqual(related_commit_table_obj.auto_increment, {})
        related_commit_table_obj.save_into_db()
        self.context_mocked.save_into_db.assert_called_once_with(
            self.fixture_table_name, self.fixture_columns
        )
        self.context_mocked.save_into_db.reset_mock()
        related_commit_table_obj.save_into_db()
        self.context_mocked.save_into_db.assert_called_once_with(
            self.fixture_table_name, self.fixture_columns
        )
        self.mock_stdout.assert_not_called()


class TestTableTest(TestDatabaseTable):
    def setUp(self):
        TestDatabaseTable.setUp(self)
        self.fixture_test_info = {
            "board": "ASIK",
            "CCNumber": "1",
            "UENumber": "10",
            "DDtype": "TDD",
            "TTIDuration": "125",
            "UESchedNumber": 1,
            "beamNumber": 1,
            "feature": "425",
            "configKey": None,
            "softwareBranch": "master",
            "userCSL": None,
        }
        self.fixture_columns_name_for_table_test = {
            "softwareCommit": "e550c8860e375ee2a5bcd646617808b179c909c1",
            "softwareCommitDate": "2019-02-16T19:45:47",
            "testDate": "2019-02-16T23:40:32",
            "testType": "Post",
            "testStatus": "NA",
            "fileKPI": "TimeMarkerKPIv2_L2RT_ft425_simpleTraffic_1CC_"
            "10UE_TDD125_ASIK_2019.02.16_23.40.32.json",
            "fileSnapshot": "TimeMarkerSnapshot_L2RT_ft425_simpleTraffic_1CC_"
            "10UE_TDD125_ASIK_2019.02.16_23.40.32.json",
            "jenkinsJob": os.environ.get("JOB_BASE_NAME"),
            "jenkinsJobId": os.environ.get("BUILD_NUMBER"),
            "jenkinsURL": os.environ.get("BUILD_URL"),
            "testNameConfig": "ft123_plusExtendedPlusSync_4CC_48UE_TDD125_CFG_SA_LA_HARQ_REF",
        }
        self.fixture_columns_name_for_table_test.update(self.fixture_test_info)

        self.fixture_snapshot_data = {
            "tickTimePicoSec": 8000,
            "xeon": "master",
            "5gnbSwVersion": "git-commit:e550c8860e375ee2a5bcd646617808b179c909c1",
            "board": "ASIK",
            "gnbCommitDate": "2019-02-16 19:45:47",
            "module": "5G-L2-RT",
        }

        self.fixture_test_config = {
            "UEnumber": "10",
            "TTIduration": "125",
            "CCnumber": "1",
            "BMnumber": 1,
            "UEsched": 1,
            "DDtype": "TDD",
        }

        fixture_json_str_kpi_file_content = {
            "header": {
                "KPIalgo": "de59cda42b4b7f0e85bc52541ef13bc8525a44c4",
                "snapshotData": self.fixture_snapshot_data,
                "version": 1,
                "TestConfig": self.fixture_test_config,
                "swComponentList": ["L2PSUL", "L2PSDL"],
                "title": "timeMarker KPI file",
            }
        }

        self.fixture_script_param_content = {
            "fileKpi": "TimeMarkerKPIv2_L2RT_ft425_simpleTraffic_1CC_"
            "10UE_TDD125_ASIK_2019.02.16_23.40.32.json",
            "softwareBranch": "master",
            "testType": "Post",
            "testStatus": "NA",
            "feature": "425",
            "testDate": "2019-02-16T23:40:32",
            "fileSnapshot": "TimeMarkerSnapshot_L2RT_ft425_simpleTraffic_1CC_"
            "10UE_TDD125_ASIK_2019.02.16_23.40.32.json",
            "testNameConfig": "ft123_plusExtendedPlusSync_4CC_48UE_TDD125_CFG_SA_LA_HARQ_REF",
        }

        self.fixture_header_dictionary = fixture_json_str_kpi_file_content["header"]
        self.fixture_header_dictionary["scriptParam"] = self.fixture_script_param_content

        self.context_mocked.select_list_into_one_table.return_value = [{"id": 999}]

    def instance_table_test_obj(self):
        return TableTest(self.context_mocked, self.fixture_header_dictionary)

    def test_init_ok(self):
        test_table_obj = self.instance_table_test_obj()

        self.assertIsNotNone(test_table_obj)
        self.assertIsInstance(getattr(test_table_obj, "context"), Context)
        self.assertIs(test_table_obj.context, self.context_mocked)
        self.assertEqual(test_table_obj.table_name, "Test")
        self.assertDictEqual(test_table_obj.auto_increment, {"name": "id", "value": None})
        self.assertIsInstance(test_table_obj.columns, dict)
        self.assertDictEqual(test_table_obj.columns, self.fixture_columns_name_for_table_test)
        self.assertIsNotNone(test_table_obj.auto_increment)
        test_table_obj.save_into_db()
        self.assertIsNotNone(test_table_obj.auto_increment["value"])
        self.assertEqual(test_table_obj.auto_increment["value"], 1000)
        self.assertRaises(SystemError, test_table_obj.save_into_db)
        self.mock_stdout.assert_not_called()

    def test_init_check_ci_test_type_nok(self):
        self.check_mandatory_str(
            "fixture_script_param_content", "testType", self.instance_table_test_obj
        )
        self.mock_stdout.assert_not_called()

    def test_init_check_software_branch_nok(self):
        self.check_mandatory_str(
            "fixture_script_param_content", "softwareBranch", self.instance_table_test_obj
        )
        self.mock_stdout.assert_not_called()

    def test_init_check_json_file_nok(self):
        self.check_mandatory_str(
            "fixture_script_param_content", "fileKpi", self.instance_table_test_obj
        )
        self.mock_stdout.assert_not_called()

    def test_set_test_date_nok(self):
        self.check_mandatory_str(
            "fixture_script_param_content", "testDate", self.instance_table_test_obj
        )
        self.mock_stdout.assert_not_called()

    def test_set_feature_nok(self):
        self.check_mandatory_str(
            "fixture_script_param_content", "feature", self.instance_table_test_obj
        )
        self.mock_stdout.assert_not_called()

    def test_init_check_gnb_commit_date_nok(self):
        self.fixture_snapshot_data["gnbCommitDate"] = ""
        self.assertEqual(
            self.instance_table_test_obj().columns["softwareCommitDate"], "2019-02-16T23:40:32"
        )
        self.fixture_snapshot_data["gnbCommitDate"] = None
        self.assertEqual(
            self.instance_table_test_obj().columns["softwareCommitDate"], "2019-02-16T23:40:32"
        )
        del self.fixture_snapshot_data["gnbCommitDate"]
        self.assertEqual(
            self.instance_table_test_obj().columns["softwareCommitDate"], "2019-02-16T23:40:32"
        )
        self.check_mandatory_str(
            "fixture_script_param_content", "testDate", self.instance_table_test_obj
        )
        self.mock_stdout.assert_not_called()

    def test_init_check_5gnb_sw_version_nok(self):
        self.check_mandatory_str(
            "fixture_snapshot_data", "5gnbSwVersion", self.instance_table_test_obj
        )
        self.mock_stdout.assert_not_called()

    def test_init_check_bm_number_nok(self):
        self.check_mandatory_str("fixture_test_config", "BMnumber", self.instance_table_test_obj)
        self.mock_stdout.assert_not_called()

    def test_init_check_ue_sched_nok(self):
        self.check_mandatory_str("fixture_test_config", "UEsched", self.instance_table_test_obj)
        self.mock_stdout.assert_not_called()

    def test_init_check_tti_duration_nok(self):
        self.check_mandatory_str("fixture_test_config", "TTIduration", self.instance_table_test_obj)
        self.mock_stdout.assert_not_called()

    def test_init_check_dd_type_nok(self):
        self.check_mandatory_str("fixture_test_config", "DDtype", self.instance_table_test_obj)
        self.mock_stdout.assert_not_called()

    def test_init_check_ue_number_nok(self):
        self.check_mandatory_str("fixture_test_config", "UEnumber", self.instance_table_test_obj)
        self.mock_stdout.assert_not_called()

    def test_init_check_cc_number_nok(self):
        self.check_mandatory_str("fixture_test_config", "CCnumber", self.instance_table_test_obj)
        self.mock_stdout.assert_not_called()

    def test_init_check_board_nok(self):
        self.check_mandatory_str("fixture_snapshot_data", "board", self.instance_table_test_obj)
        self.mock_stdout.assert_not_called()

    def test_search_last_id_found(self):
        self.context_mocked.get_parent_commit_date.return_value = "myPreviousCommitDate"

        test_table_obj = self.instance_table_test_obj()
        test_table_obj.save_into_db()
        last_id = test_table_obj.search_last_id()
        self.mock_stdout.assert_not_called()
        self.context_mocked.select_list_into_one_table.assert_called_once_with(
            "Test",
            select_col=[
                "MAX(id) as id",
                "MAX(fileKPI) as fileKPI",
                "MAX(softwareCommitDate) as softwareCommitDate",
                "MAX(testDate) as testDate",
            ],
            where_dict={
                "=": self.fixture_test_info,
                "!=": {"id": 1000, "testStatus": "FAILED", "testType": "Endurance"},
                "<=": {"softwareCommitDate": "myPreviousCommitDate"},
                ">": {"softwareCommitDate": CURRENT_DATE_TIME - timedelta(days=14)},
            },
            order_list=["softwareCommitDate", "testDate"],
            group_by_str="softwareCommit",
            limit_result=3,
        )
        self.assertListEqual(last_id, [{"id": 999}])

    def test_search_last_id_for_continuous(self):
        self.context_mocked.get_parent_commit_date.return_value = None

        test_table_obj = self.instance_table_test_obj()
        test_table_obj.save_into_db()
        last_id = test_table_obj.search_last_id()
        self.mock_stdout.assert_not_called()
        self.context_mocked.select_list_into_one_table.assert_called_once_with(
            "Test",
            select_col=[
                "MAX(id) as id",
                "MAX(fileKPI) as fileKPI",
                "MAX(softwareCommitDate) as softwareCommitDate",
                "MAX(testDate) as testDate",
            ],
            where_dict={
                "=": self.fixture_test_info,
                "!=": {"id": 1000, "testStatus": "FAILED", "testType": "Endurance"},
                ">": {"softwareCommitDate": CURRENT_DATE_TIME - timedelta(days=14)},
            },
            order_list=["softwareCommitDate", "testDate"],
            group_by_str="softwareCommit",
            limit_result=3,
        )
        self.assertListEqual(last_id, [{"id": 999}])

    def test_search_last_id_error_then_return_empty_list(self):
        self.context_mocked.get_parent_commit_date.side_effect = EnvironmentError

        test_table_obj = self.instance_table_test_obj()
        test_table_obj.save_into_db()
        last_id = test_table_obj.search_last_id()
        self.mock_stdout.assert_not_called()
        self.context_mocked.select_list_into_one_table.assert_not_called()
        self.assertListEqual(last_id, [])


class TestTableThresholdAlarm(TestDatabaseTable):
    def setUp(self):
        TestDatabaseTable.setUp(self)
        self.fixture_threshold_dict = {
            "testId": 100,
            "type": "thresholdType",
            "message": "myMessage",
            "criticity": "Minor",
        }

    def test_init_ok(self):
        threshold_alarm = TableThresholdAlarm(self.context_mocked, self.fixture_threshold_dict)
        self.assertDictEqual(
            threshold_alarm.columns,
            {
                "testId": self.fixture_threshold_dict["testId"],
                "thresholdType": self.fixture_threshold_dict["type"],
                "message": self.fixture_threshold_dict["message"],
                "criticity": self.fixture_threshold_dict["criticity"],
            },
        )


# For new TimeMarkerKpi Format
class TestTableWithoutSubLevel(TestDatabaseTable):
    @staticmethod
    def instance_method():
        raise NotImplementedError("Not really to implement here")

    def setUp(self):
        TestDatabaseTable.setUp(self)
        self.table_name = None
        self.fixture_result = None
        self.fixture_env_dict_for_check_mandatory_param = {"testInfo": "What"}
        self.fixture_kpi_values = {"data": "not need for this test"}
        self.class_name = TableWithoutSubLevel
        self.kpi_type = None
        self.with_name_field = True

    def test_init_kpi_nok(self):
        if not self.table_name:
            self.assertRaisesRegex(
                TypeError,
                r"Can't instantiate abstract class TableWith(out){0,1}SubLevel",
                self.class_name,
            )
            self.assertRaisesRegex(
                NotImplementedError, "Not really to implement here", self.instance_method
            )
            self.assertRaisesRegex(
                NotImplementedError, "Abstract Method declaration", self.class_name.get_kpi_type
            )
            self.mock_stdout.assert_not_called()

    def test_get_table_abstract_method(self):
        if self.table_name:
            obj_to_test = self.instance_method()
            self.assertEqual(self.table_name, obj_to_test.get_table_name())
        else:
            self.assertRaisesRegex(
                NotImplementedError,
                "Abstract Method declaration -> return string with table name",
                self.class_name.get_table_name,
            )

    @staticmethod
    def get_where_dict(obj_columns):
        kpi_columns = deepcopy(obj_columns)
        for key_to_del in ["min", "avg", "95p", "max", "testId", "kpiType", "nbSlots"]:
            if key_to_del in kpi_columns:
                del kpi_columns[key_to_del]

        return kpi_columns

    def test_check_init_ok(self):
        if self.table_name:
            kpi_obj = self.instance_method()
            self.assertIsNotNone(kpi_obj)
            self.assertIsInstance(getattr(kpi_obj, "context"), Context)
            self.assertEqual(kpi_obj.table_name, self.table_name)
            self.assertDictEqual(kpi_obj.auto_increment, {"name": "id", "value": None})
            self.assertIsInstance(kpi_obj.columns, dict)
            self.assertDictEqual(kpi_obj.columns, self.fixture_result)
            kpi_obj.save_into_db()
            self.assertIsNotNone(kpi_obj.auto_increment["value"])
            self.assertEqual(kpi_obj.auto_increment["value"], 1000)
            self.assertRaises(SystemError, kpi_obj.save_into_db)
            self.mock_stdout.assert_not_called()
            kpi_obj.columns["kpiType"] = kpi_obj.get_kpi_type()
            kpi_obj.get_reference_kpi_list("95p", "97, 98, 99")
            self.context_mocked.select_list_into_one_table.assert_called_once_with(
                kpi_obj.table_name,
                select_col=["max(95p)"],
                where_dict={
                    "=": self.get_where_dict(kpi_obj.columns),
                    "in": {"testId": "97, 98, 99"},
                },
            )
            self.assertEqual(self.kpi_type, kpi_obj.get_kpi_type())

    def test_init_check_test_id_nok(self):
        if self.table_name:
            self.check_mandatory_int(
                "fixture_env_dict_for_check_mandatory_param", "testId", self.instance_method
            )
            self.mock_stdout.assert_not_called()

    def test_init_check_component_nok(self):
        if self.table_name:
            self.check_mandatory_str(
                "fixture_env_dict_for_check_mandatory_param", "component", self.instance_method
            )
            self.mock_stdout.assert_not_called()

    def test_init_cell_group_instance_nok(self):
        if self.table_name:
            self.check_mandatory_str(
                "fixture_env_dict_for_check_mandatory_param",
                "cellGroupInstance",
                self.instance_method,
            )
            self.mock_stdout.assert_not_called()

    def test_init_check_name_nok(self):
        if self.table_name and self.with_name_field:
            self.check_mandatory_str(
                "fixture_env_dict_for_check_mandatory_param", "name", self.instance_method
            )
            self.mock_stdout.assert_not_called()

    def test_init_check_min_nok(self):
        if self.table_name:
            if "min" in self.fixture_kpi_values:
                del self.fixture_kpi_values["min"]
            else:
                del self.fixture_kpi_values["minTime_MicroSec"]

            self.assertRaises(KeyError, self.instance_method)
            self.mock_stdout.assert_not_called()

    def test_init_check_avg_nok(self):
        if self.table_name:
            if "avg" in self.fixture_kpi_values:
                del self.fixture_kpi_values["avg"]
            else:
                del self.fixture_kpi_values["avgTime_MicroSec"]

            self.assertRaises(KeyError, self.instance_method)
            self.mock_stdout.assert_not_called()

    def test_init_check_95p_nok(self):
        if self.table_name:
            if "95p" in self.fixture_kpi_values:
                del self.fixture_kpi_values["95p"]
            else:
                del self.fixture_kpi_values["95pTime_MicroSec"]

            self.assertRaises(KeyError, self.instance_method)
            self.mock_stdout.assert_not_called()

    def test_init_check_max_nok(self):
        if self.table_name:
            if "max" in self.fixture_kpi_values:
                del self.fixture_kpi_values["max"]
            else:
                del self.fixture_kpi_values["maxTime_MicroSec"]

            self.assertRaises(KeyError, self.instance_method)
            self.mock_stdout.assert_not_called()


class TestTableKpiLeadTime(TestTableWithoutSubLevel):
    def instance_method(self):
        return TableKpiLeadTime(
            self.context_mocked,
            self.fixture_env_dict_for_check_mandatory_param,
            self.fixture_kpi_values,
        )

    def setUp(self):
        TestTableWithoutSubLevel.setUp(self)
        self.table_name = "KpiLeadTime"
        self.class_name = TableKpiLeadTime
        self.kpi_type = "LeadTime"

        self.fixture_result = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ltBetweenTwoConsecutiveSlotSynchroInds",
            "min": 114.608,
            "avg": 125.551,
            "95p": 133.936,
            "max": 136.712,
            "nbSlots": 215,
        }
        self.fixture_env_dict_for_check_mandatory_param = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ltBetweenTwoConsecutiveSlotSynchroInds",
        }

        self.fixture_kpi_values = {
            "min": 114.608,
            "avg": 125.551,
            "95p": 133.936,
            "max": 136.712,
            "nbSlots": 215,
        }


class TestTableKpiProcessingTime(TestTableWithoutSubLevel):
    def instance_method(self):
        return TableKpiProcessingTime(
            self.context_mocked,
            self.fixture_env_dict_for_check_mandatory_param,
            self.fixture_kpi_values,
        )

    def setUp(self):
        TestTableWithoutSubLevel.setUp(self)
        self.table_name = "KpiProcessingTime"
        self.class_name = TableKpiProcessingTime
        self.kpi_type = "ProcessingTime"

        self.fixture_result = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ptScheduling",
            "min": 87.936,
            "avg": 110.578,
            "95p": 124.64,
            "max": 128.592,
            "nbSlots": 115,
        }
        self.fixture_env_dict_for_check_mandatory_param = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "ptScheduling",
        }

        self.fixture_kpi_values = {
            "min": 87.936,
            "avg": 110.578,
            "95p": 124.64,
            "max": 128.592,
            "nbSlots": 115,
        }


class TestTableKpiMiddleware(TestTableWithoutSubLevel):
    def instance_method(self):
        return TableKpiMiddleware(
            self.context_mocked,
            self.fixture_env_dict_for_check_mandatory_param,
            self.fixture_kpi_values,
        )

    def setUp(self):
        TestTableWithoutSubLevel.setUp(self)
        self.table_name = "KpiMiddleware"
        self.class_name = TableKpiMiddleware
        self.kpi_type = "Middleware"

        self.fixture_result = {
            "testId": 1,
            "component": "Middleware",
            "cellGroupInstance": "1",
            "name": "leadTime",
            "min": 63.832,
            "avg": 118.765,
            "95p": 156.288,
            "max": 180.04,
        }
        self.fixture_env_dict_for_check_mandatory_param = {
            "testId": 1,
            "component": "Middleware",
            "cellGroupInstance": "1",
            "name": "leadTime",
        }

        self.fixture_kpi_values = {
            "95pTime_MicroSec": 156.288,
            "avgTime_MicroSec": 118.765,
            "maxMarker": "8d758db3843f0000",
            "maxTime_MicroSec": 180.04,
            "minTime_MicroSec": 63.832,
        }


class TestTableWithSubLevel(TestTableWithoutSubLevel):
    def instance_method(self):
        raise NotImplementedError("Not really to implement here")

    def setUp(self):
        TestTableWithoutSubLevel.setUp(self)
        self.class_name = TableWithSubLevel
        self.with_name_field = False

    def test_name_no_more_exist(self):
        if self.table_name:
            obj_to_test = self.instance_method()
            self.assertNotIn("name", obj_to_test.columns)

    def test_init_check_sub_components_nok(self):
        if self.table_name:
            original_mandatory = self.fixture_env_dict_for_check_mandatory_param.copy()
            self.check_mandatory_str(
                "fixture_env_dict_for_check_mandatory_param", "subComponent1", self.instance_method
            )
            self.fixture_env_dict_for_check_mandatory_param = original_mandatory.copy()
            self.mock_stdout.assert_not_called()


class TestTableKpiValues(TestTableWithSubLevel):
    def instance_method(self):
        return TableKpiValues(
            self.context_mocked,
            self.fixture_env_dict_for_check_mandatory_param,
            self.fixture_kpi_values,
        )

    def setUp(self):
        TestTableWithSubLevel.setUp(self)
        self.class_name = TableKpiValues
        self.table_name = "KpiValues"
        self.kpi_type = "Values"

        self.fixture_result = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "ventilated": True,
            "subComponent1": "cs2",
            "subComponent2": "[SubcellIndex-0]",
            "min": 2,
            "avg": 2,
            "95p": 2,
            "max": 2,
            "nbSlots": 100,
        }
        self.fixture_env_dict_for_check_mandatory_param = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "name": "MustNotUsed",
            "ventilated": True,
            "subComponent1": "cs2",
            "subComponent2": "SubcellIndex-0",
        }

        self.fixture_kpi_values = {"min": 2, "avg": 2, "95p": 2, "max": 2, "nbSlots": 100}


class TestTableKpiProcessingTimePerEO(TestTableWithSubLevel):
    def instance_method(self):
        return TableKpiProcessingTimePerEO(
            self.context_mocked,
            self.fixture_env_dict_for_check_mandatory_param,
            self.fixture_kpi_values,
        )

    def setUp(self):
        TestTableWithSubLevel.setUp(self)
        self.class_name = TableKpiProcessingTimePerEO
        self.table_name = "KpiProcTimePerEO"
        self.kpi_type = "ProcessingTimePerEO"

        self.fixture_result = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "coreId": "Core5",
            "eoNameAndInstance": "L2PsDlSch-1",
            "ventilated": False,
            "isProbe": True,
            "subComponent1": "DL_MESSAGE",
            "subComponent2": "All",
            "subComponent3": "All",
            "subComponent4": "All",
            "subComponent5": "All",
            "min": 55.96,
            "avg": 78.757,
            "95p": 93.928,
            "max": 96.64,
            "nbSlots": 99,
        }

        self.fixture_env_dict_for_check_mandatory_param = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "coreId": "Core5",
            "eoNameAndInstance": "L2PsDlSch-1",
            "ventilated": False,
            "isProbe": True,
            "subComponent1": "EO_L2_PS_DL_MESSAGE",
            "subComponent2": "All",
            "subComponent3": "All",
            "subComponent4": "All",
            "subComponent5": "All",
            "name": "MustNotUsed",
        }

        self.fixture_kpi_values = {
            "95pTime_MicroSec": 93.928,
            "avgTime_MicroSec": 78.757,
            "maxTime_MicroSec": 96.64,
            "minTime_MicroSec": 55.96,
            "nbSlots": 99,
        }

    def test_init_check_core_id_nok(self):
        self.check_mandatory_str(
            "fixture_env_dict_for_check_mandatory_param", "coreId", self.instance_method
        )

    def test_init_check_eo_name_and_instance_nok(self):
        self.check_mandatory_str(
            "fixture_env_dict_for_check_mandatory_param", "eoNameAndInstance", self.instance_method
        )

    def test_init_check_is_probe_nok(self):
        self.check_mandatory_bool(
            "fixture_env_dict_for_check_mandatory_param", "isProbe", self.instance_method
        )

    def test_init_ventilated_true_ok(self):
        self.maxDiff = None

        self.fixture_result = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "coreId": "Core5",
            "eoNameAndInstance": "L2PsDlSch-1",
            "ventilated": True,
            "isProbe": True,
            "subComponent1": "FD_SCH_MESSAGE",
            "subComponent2": "PsInternal_FdScheduleReq",
            "subComponent3": "FD_PROCESSING",
            "subComponent4": "[SubcellIndex-6]",
            "subComponent5": None,
            "min": 55.96,
            "avg": 78.757,
            "95p": 93.928,
            "max": 96.64,
            "nbSlots": 99,
        }

        self.fixture_env_dict_for_check_mandatory_param = {
            "testId": 1,
            "component": "L2PSDL",
            "cellGroupInstance": "1",
            "coreId": "Core5",
            "eoNameAndInstance": "L2PsDlSch-1",
            "ventilated": True,
            "isProbe": True,
            "subComponent1": "EO_L2_PS_FD_SCH_MESSAGE",
            "subComponent2": "PsInternal_FdScheduleReq",
            "subComponent3": "EO_L2_PS_FD_PROCESSING",
            "subComponent4": "SubcellIndex-6",
            "subComponent5": None,
            "name": "MustNotUsed",
        }

        self.test_check_init_ok()
