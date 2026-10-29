from .src import ParameterParser
import pytest


@pytest.fixture
def param_parser():
    param_parser = ParameterParser.ParameterParser()
    param_parser.load_parameter_file(r'../../5GC000708B/Test_Variables.yaml')
    return param_parser


def test_name_present_check(param_parser):
    assert param_parser.is_testcase_parameter_present('TC_3')
    assert param_parser.is_testcase_parameter_present('Default')
    assert not param_parser.is_testcase_parameter_present('TC_4')


def test_redirect_flag(param_parser):
    assert param_parser.get_redirect_flag_for_test('Default') == 'true'
    assert param_parser.get_redirect_flag_for_test('TC_1') == 'false'


def test_is_type_needed_for_test(param_parser):
    assert not param_parser.is_rsrp_needed_for_test('Default')
    assert param_parser.is_rsrq_needed_for_test('TC_3')
    assert param_parser.is_rsrp_and_rsrq_both_needed_for_test('Default')
    assert not param_parser.is_rsrp_needed_for_test('TC_1')
    assert not param_parser.is_rsrq_needed_for_test('TC_1')
    assert not param_parser.is_rsrp_and_rsrq_both_needed_for_test('TC_1')
