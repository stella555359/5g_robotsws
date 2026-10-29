from unittest.mock import patch
import pytest
import statistic_validator as sta_val
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.pm_counters_validator_vran import (process_counter_value,
                                                                                              compare_counter_value,
                                                                                              ExecutionFailed)

stats = '''
12586632
'''


@patch('statistic_validator._get_statistic_for_given_qfi')
def test_expected_throughput_for_qfi_should_be_reached(mock_get):
    mock_get.return_value = stats
    sta_val.expected_throughput_for_qfi_should_be_reached(ue_id=1, pdu_id=1,
                                                          qfi_id=1, expected_throughput=13.85, unit='mbps',
                                                          margin=0.1, direction='dl')


@patch('statistic_validator._get_statistic_for_given_qfi')
def test_expected_throughput_for_qfi_should_be_reached_with_margin(mock_get):
    mock_get.return_value = stats
    sta_val.expected_throughput_for_qfi_should_be_reached(ue_id=1, pdu_id=1,
                                                          qfi_id=1, expected_throughput=12.58, unit='mbps',
                                                          margin=0.01, direction='dl')


@patch('statistic_validator._get_statistic_for_given_qfi')
def test_expected_throughput_for_qfi_should_not_reached(mock_get):
    mock_get.return_value = stats
    with pytest.raises(ThroughputException) as exc_info:
        sta_val.expected_throughput_for_qfi_should_be_reached(ue_id=1, pdu_id=1,
                                                              qfi_id=1, expected_throughput=50, unit='mbps',
                                                              margin=0.1, direction='dl')
    assert str(exc_info.value) == \
           'QFI 1 throughput 12.586632 mbps is not in margin of 0.1 of expected throughput 50 mbps'


@patch('statistic_validator._get_statistic_for_given_qfi')
def test_expected_throughput_for_qfi_should_not_reached_due_to_margin(mock_get):
    mock_get.return_value = stats
    with pytest.raises(ThroughputException) as exc_info:
        sta_val.expected_throughput_for_qfi_should_be_reached(ue_id=1, pdu_id=1,
                                                              qfi_id=1, expected_throughput=12, unit='mbps',
                                                              margin=0, direction='dl')
    assert str(exc_info.value) == \
           'QFI 1 throughput 12.586632 mbps is not in margin of 0.1 of expected throughput 12 mbps'


@patch('testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.pm_counters_validator_vran.logger.info')
def test_process_counter_value_when_value_none_then_exception_is_raised(mock_logger_info):
    with pytest.raises(ExecutionFailed) as exc_info:
        process_counter_value(None, 'M55353C00001')
    assert 'Counter M55353C00001 value is None, check if counter is enabled and local moid path is correct.' in str(
        exc_info.value)


@patch('testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.pm_counters_validator_vran.logger.info')
def test_process_counter_value_when_input_value_is_str_then_output_is_int(mock_logger_info):
    output = process_counter_value('2', 'M55353C00001')
    assert isinstance(output, int)


@patch('testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.pm_counters_validator_vran.logger.info')
def test_process_counter_value_when_value_in_input_then_value_in_output(mock_logger_info):
    value = process_counter_value('2', 'M55353C00001')
    assert value is 2


@patch('testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.pm_counters_validator_vran.logger.info')
def test_compare_counter_value_when_bigger_value_processed_less_then_exception_is_raised(mock_logger_info):
    with pytest.raises(ExecutionFailed) as exc_info:
        compare_counter_value(value=2, counter_value=3, counter_id='M55353C00001', comparison_type='lower')
    assert 'The PM counter M55353C00001 actual value: 3 - the value should be lower than: 2' in str(exc_info.value)


@patch('testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.pm_counters_validator_vran.logger.info')
def test_compare_counter_value_when_lower_value_processed_less_then_test_pass(mock_logger_info):
    compare_counter_value(value=3, counter_value=2, counter_id='M55353C00001', comparison_type='lower')
    assert True


@patch('testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.pm_counters_validator_vran.logger.info')
def test_compare_counter_value_when_invalid_comparison_type_then_exception_is_raised(mock_logger_info):
    with pytest.raises(ValueError) as exc_info:
        compare_counter_value(value=2, counter_value=3, counter_id='M55353C00001', comparison_type=None)
    assert 'Invalid comparison type: None' in str(exc_info.value)


@patch('testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.pm_counters_validator_vran.logger.info')
def test_compare_counter_value_when_lower_value_processed_equal_then_exception_is_raised(mock_logger_info):
    with pytest.raises(ExecutionFailed) as exc_info:
        compare_counter_value(value=2, counter_value=2, counter_id='M55353C00001', comparison_type='lower')
    assert 'The PM counter M55353C00001 actual value: 2 - the value should be lower than: 2' in str(exc_info.value)
