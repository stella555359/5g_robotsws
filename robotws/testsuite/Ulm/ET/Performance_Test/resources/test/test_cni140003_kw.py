"""test cni140003
"""
import mock  # pylint: disable=locally-disabled, E0401
from testsuite.Ulm.ET.Performance_Test.resources.python import perf_keywords
from testsuite.Ulm.ET.Performance_Test.resources.test.testmock.ute_wtssim import UteWtsSimMock
from testsuite.Ulm.ET.Performance_Test.resources.test.testmock.builtin import BuiltInMock
from testsuite.Ulm.ET.Performance_Test.resources.features.CNI140003 import cni140003_kw

rbi = BuiltInMock()
_PYTHONP = "testsuite.Ulm.ET.Performance_Test.resources.python"


@mock.patch(f"{_PYTHONP}.perf_log_collection.rbi.get_variable_value", side_effect=rbi.get_variable_value)
@mock.patch(f"{_PYTHONP}.perf_keywords.rbi.get_variable_value", side_effect=rbi.get_variable_value)
@mock.patch(f"{_PYTHONP}.perf_keywords.rbi.set_test_variable", side_effect=rbi.set_test_variable)
@mock.patch(f"{_PYTHONP}.perf_log_collection.rbi.set_test_variable", side_effect=rbi.set_test_variable)
@mock.patch(f"{_PYTHONP}.pmcounter_manager.get_pmc_tput")
@mock.patch("testsuite.Ulm.ET.Performance_Test.resources.features.CNI140003.cni140003_kw.rbi.log_to_console")
@mock.patch("testsuite.Ulm.ET.Performance_Test.resources.features.CNI140003.cni140003_kw.rbi.run_keyword",
            side_effect=rbi.run_keyword)
@mock.patch("json.dumps")
@mock.patch("time.sleep")
def test_run_cni140003_tc2(*_):
    """test run_cni140003_tc2
    """
    ute_mock = UteWtsSimMock()
    with mock.patch('testsuite.Ulm.ET.Performance_Test.resources.python.wts_manager.get_egate_obj',
                    return_value=ute_mock):
        args = perf_keywords.calculate_values_for_common_run_dictionary_py(
            get_from_cli=False,
            start_cell=1,
            end_cell=9,
            cell_a=1,
            cell_b=3
        )
        args = cni140003_kw.run_cni140003_tc2(args)
        expected_total_ue = (int(args["group1_ue_count"])
                             + int(args["group2_ue_count"]) + int(args["group3_ue_count"]))
        assert len(ute_mock.registered_ue_ids) == expected_total_ue


@mock.patch(f"{_PYTHONP}.perf_log_collection.rbi.get_variable_value", side_effect=rbi.get_variable_value)
@mock.patch(f"{_PYTHONP}.perf_keywords.rbi.get_variable_value", side_effect=rbi.get_variable_value)
@mock.patch(f"{_PYTHONP}.perf_keywords.rbi.set_test_variable", side_effect=rbi.set_test_variable)
@mock.patch(f"{_PYTHONP}.perf_log_collection.rbi.set_test_variable", side_effect=rbi.set_test_variable)
@mock.patch(f"{_PYTHONP}.pmcounter_manager.get_pmc_tput")
@mock.patch("testsuite.Ulm.ET.Performance_Test.resources.features.CNI140003.cni140003_kw.rbi.log_to_console")
@mock.patch("testsuite.Ulm.ET.Performance_Test.resources.features.CNI140003.cni140003_kw.rbi.run_keyword",
            side_effect=rbi.run_keyword)
@mock.patch("json.dumps")
@mock.patch("time.sleep")
def test_run_cni140003_tc5(*_):
    """test test_run_cni140003_tc5
    """
    ute_mock = UteWtsSimMock()
    with mock.patch('testsuite.Ulm.ET.Performance_Test.resources.python.wts_manager.get_egate_obj',
                    return_value=ute_mock):
        args = perf_keywords.calculate_values_for_common_run_dictionary_py(
            get_from_cli=False,
            start_cell=1,
            end_cell=9,
            cell_a=1,
            cell_b=3
        )
        args = cni140003_kw.run_cni140003_tc5(args)
        expected_total_ue = (int(args["group1_ue_count"]) + int(args["group2_ue_count"]))
        assert len(ute_mock.registered_ue_ids) == expected_total_ue
