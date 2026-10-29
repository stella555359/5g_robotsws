"""
:copyright: Nokia Networks
:author: Kamil Bucki
:contact: kamil.bucki@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.ttitraces_management import *
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console
from robot.libraries.BuiltIn import BuiltIn
import json
import ast
import re


class TtiTracesOtherThanExpectedException(Exception):
    pass


class CannotFindTtiTracePathException(Exception):
    pass


def validate_1UE_1slice_quota_1_15_and_70_100_old(path=None):
    status = True
    all_not_valid = []
    logger_console("Validating validate_1UE_1slice_quota_1_15_and_70_100...")
    if path is None:
        logger_console("Checking TtiTrace path in common Variables...")
        path = BuiltIn().get_variable_value('${TTI_TRACE_PATH}')
        if path is None:
            raise CannotFindTtiTracePathException('Cannot find TtiTrace path')

    tti_list = select_tti_for_1UE_1slice_quota_1_15_and_70_100(tti_path=path)
    drb_tti = tti_list['dlDrbWeightData.drbNumber']
    slice_tti = tti_list['dlSliceData.slicesNumber']
    drb_expected = BuiltIn().get_variable_value('${TTI_DRB_EXPECTED_VALUES_1UE}')
    slice_expected = BuiltIn().get_variable_value('${TTI_SLICE_EXPECTED_VALUES_1UE}')

    drb_tti_values = get_values_for_validation_columns(tti_single_data=drb_tti,
                                                       drb_expected=drb_expected,
                                                       slice_expected=slice_expected
                                                       )
    slice_tti_values = get_values_for_validation_columns(tti_single_data=slice_tti,
                                                         drb_expected=drb_expected,
                                                         slice_expected=slice_expected
                                                         )

    slice_result, slice_not_valid = validate_values(key_values=slice_expected, tti_values=slice_tti_values)
    drb_result, drb_not_valid = validate_values(key_values=drb_expected, tti_values=drb_tti_values)

    if slice_result is False or drb_result is False:
        all_not_valid = slice_not_valid + drb_not_valid
        raise TtiTracesOtherThanExpectedException("UnExpected values:\n{}".format(all_not_valid))
    return status


def validate_1UE_1slice_quota_1_15_and_70_100(path=None):
    status = True
    all_not_valid = []
    logger_console("Validating validate_1UE_1slice_quota_1_15_and_70_100...")
    if path is None:
        logger_console("Checking TtiTrace path in common Variables...")
        path = BuiltIn().get_variable_value('${TTI_TRACE_PATH}')
        if path is None:
            raise CannotFindTtiTracePathException('Cannot find TtiTrace path')
    tti_expected = BuiltIn().get_variable_value('${TTI_EXPECTED_VALUES_1UE}')
    tti_list = select_tti(tti_path=path, expected_values=tti_expected)
    for key, values in tti_expected.items():
        for value, expected_values in values.items():
            if key in tti_list.keys() and value in tti_list[key].keys():
                tti_to_validate = tti_list[key][value]
                tti_values = get_values_for_validation_columns_new(tti_single_data=tti_to_validate,
                                                                   expected=expected_values
                                                                   )
                single_result, single_not_valid = validate_values(key_values=expected_values,
                                                                  tti_values=tti_values,
                                                                  variable_path="->".join([str(key), str(value)])
                                                                  )
                if single_result is False:
                    status = False
                    all_not_valid = all_not_valid + single_not_valid
            else:
                status = False
                all_not_valid.append("Cannot find tti  with column {} equeal {}".format(key, value))
    if status is False:
        raise TtiTracesOtherThanExpectedException("UnExpected values:\n{}".format(all_not_valid))
    return status


def validate_3UE_1slice_quota_1_15_and_70_100(path=None):
    status = True
    all_not_valid = []
    logger_console("Validating validate_3UE_1slice_quota_1_15_and_70_100...")
    if path is None:
        logger_console("Checking TtiTrace path in common Variables...")
        path = BuiltIn().get_variable_value('${TTI_TRACE_PATH}')
        if path is None:
            raise CannotFindTtiTracePathException('Cannot find TtiTrace path')
    cell_tech = BuiltIn().get_variable_value('${CELL_TECHNOLOGY}')
    release = BuiltIn().get_variable_value('${RELEASE}')
    tti_expected = BuiltIn().get_variable_value('${TTI_EXPECTED_VALUES_3UE}')
    tti_expected = tti_expected[cell_tech][release]
    tti_list = select_tti(tti_path=path, expected_values=tti_expected)

    for key, values in tti_expected.items():
        for value, expected_values in values.items():
            if key in tti_list.keys() and value in tti_list[key].keys():
                tti_to_validate = tti_list[key][value]
                tti_values = get_values_for_validation_columns_new(tti_single_data=tti_to_validate,
                                                                   expected=expected_values
                                                                   )
                single_result, single_not_valid = validate_values(key_values=expected_values,
                                                                  tti_values=tti_values,
                                                                  variable_path="->".join([key, value])
                                                                  )
                if single_result is False:
                    status = False
                    all_not_valid = all_not_valid + single_not_valid
            else:
                status = False
                all_not_valid.append("Cannot find tti  with column {} equeal {}".format(key, value))
    if status is False:
        raise TtiTracesOtherThanExpectedException("UnExpected values:\n{}".format(all_not_valid))
    return status


def select_tti_for_1UE_1slice_quota_1_15_and_70_100(tti_path=None):
    logger_console("Selecting TtiTrace messages to validation...")
    if tti_path is None:
        logger_console("Checking TtiTrace path in common Variables...")
        tti_path = BuiltIn().get_variable_value('${TTI_TRACE_PATH}')
        if tti_path is None:
            raise CannotFindTtiTracePathException('Cannot find TtiTrace path')

    tti_list = convert_csv_tti_trace_to_list(path=tti_path)
    tti_list = filter_out_tti_traces_with_empty_columns(tti_data=tti_list,
                                                        columns=['dlDrbWeightData.dlDrbsWeightData[0].sliceId',
                                                                 'dlSliceData.dlSlicesData[0].sliceId'
                                                                 ]
                                                        )
    tti_list = filter_throughput_ttitrace(tti_list=tti_list)['throughput_ttitrace']
    middle_tti = _get_middle_tti_for_not_empty_columns(tti_list=tti_list,
                                                       columns_list=['dlDrbWeightData.drbNumber',
                                                                     'dlSliceData.slicesNumber'
                                                                     ]
                                                       )

    return middle_tti


def select_tti(expected_values, tti_path=None):
    logger_console("Selecting TtiTrace messages to validation...")
    if tti_path is None:
        logger_console("Checking TtiTrace path in common Variables...")
        tti_path = BuiltIn().get_variable_value('${TTI_TRACE_PATH}')
        if tti_path is None:
            raise CannotFindTtiTracePathException('Cannot find TtiTrace path')

    tti_list = convert_csv_tti_trace_to_list(path=tti_path)
    key_list = expected_values.keys()
    tti_list = filter_out_tti_traces_with_empty_columns(tti_data=tti_list, columns=key_list)

    tti_list = filter_throughput_ttitrace(tti_list=tti_list)['throughput_ttitrace']
    column_list_with_values = prepare_dictionary_with_columns_and_values(expected_values=expected_values)
    logger_console("***********************************")
    logger_console(column_list_with_values)

    middle_tti = _get_middle_tti_for_columns_with_values(tti_list=tti_list, columns_list=column_list_with_values)

    return middle_tti


def prepare_dictionary_with_columns_and_values(expected_values):
    to_return = {}

    for column, column_expected_values in expected_values.items():
        to_return[column] = column_expected_values.keys()
    return to_return


def get_values_for_validation_columns(tti_single_data, drb_expected, slice_expected):

    drb_columns_list = list(drb_expected.keys())
    slice_columns_list = list(slice_expected.keys())
    column_list = drb_columns_list + slice_columns_list + ['timeStamp', 'sfn', 'slot', 'physCellId']
    values = get_value_from_columns_for_single_tti(tti_data=tti_single_data, columns_name=column_list)
    return values


def get_values_for_validation_columns_new(tti_single_data, expected):

    columns_list = list(expected.keys())
    column_list = columns_list + ['timeStamp', 'sfn', 'slot', 'physCellId']
    values = get_value_from_columns_for_single_tti(tti_data=tti_single_data, columns_name=column_list)
    return values


def validate_values(key_values, tti_values, variable_path=''):
    valid = True
    all_not_valid = []
    for column, values in key_values.items():
        logger_console("Validation of {}->{}".format(variable_path, column))
        if column == 'dlSliceData.dlSlicesData':
            result, not_valid = validate_dlSliceData_dlSlicesData(key_value=values, value=tti_values[column])
            if result is False:
                valid = False
                all_not_valid = all_not_valid + not_valid
                logger_console("Validation failed!!!!!!")
        elif column == 'dlDrbWeightData.dlDrbsWeightData':
            result, not_valid = validate_dlDrbWeightData_dlDrbsWeightData(key_value=values, value=tti_values[column])
            if result is False:
                valid = False
                all_not_valid = all_not_valid + not_valid
                logger_console("Validation failed!!!!!!")
        else:
            result, not_valid = default_validate(key_value=values,
                                                 value=tti_values[column],
                                                 variable_path="->".join([variable_path, column])
                                                 )
            if result is False:
                valid = False
                all_not_valid = all_not_valid + not_valid
                logger_console("Validation failed!!!!!!")

        logger_console("Validation : {}".format(valid))

    return valid, all_not_valid


def default_validate(key_value, value, variable_path):
    result, not_valid = compare(key_value=key_value, value=value, variable_path=variable_path)
    return result, not_valid


def validate_dlSliceData_dlSlicesData(key_value, value):
    data = prepare_dictionary_base_on_list_with_dictionary(data=value)
    result, not_valid = compare(key_value=key_value, value=data, variable_path='dlSliceData.dlSlicesData')

    return result, not_valid


def validate_dlDrbWeightData_dlDrbsWeightData(key_value, value):
    data = prepare_dictionary_base_on_list_with_dictionary(data=value)
    result, not_valid = compare(key_value=key_value, value=data, variable_path='dlDrbWeightData.dlDrbsWeightData')

    return result, not_valid


def prepare_dictionary_base_on_list_with_dictionary(data, group_by='sliceId'):
    data_to_return = {}
    data = json.dumps(ast.literal_eval(data))
    data = json.loads(data)
    id = 1
    for row in data:
        for key in row:
            if key == group_by:
                data_to_return["{}_{}".format(key, id)] = row
                id = id + 1
    return data_to_return


def compare(key_value, value, variable_path=""):
    logger_console("Comparing {}(collected) with {}(key) in {}".format(value, key_value, variable_path))
    if isinstance(value, str):
        value = json.dumps(ast.literal_eval(value))
        value = json.loads(value)

    result = False
    type_of_key_value = type(key_value)
    type_of_value = type(value)
    not_valid = []
    if isinstance(key_value, list):
        logger_console(dict in [type(i) for i in key_value])

    if type_of_key_value == str and check_if_range_in_str(key_value):
        min, max = check_if_range_in_str(key_value)
        result, not_valid = check_if_in_range(value=value, min=min, max=max, variable_path=variable_path)
    elif type_of_key_value == list and dict in [type(i) for i in key_value]:
        result, not_valid = compare_list_of_dict(key_value=key_value, value=value, variable_path=variable_path)

    elif type_of_key_value == str and check_if_or_in_str(key_value):
        array_values = check_if_or_in_str(key_value)
        result, not_valid = check_if_in_array(value=value, array=array_values, variable_path=variable_path)
    elif type_of_key_value in [int, float] and type_of_value in [int, float]:
        result, not_valid = compare_int_value(key_value=key_value, value=value, variable_path=variable_path)
    elif type_of_key_value in [int, float, str] and type_of_value in [int, float, str]:
        result, not_valid = compare_int_value(key_value=float(key_value),
                                              value=float(value),
                                              variable_path=variable_path
                                              )
    elif type_of_key_value != type_of_value:
        result = False
        not_valid = ["Type of {} value({}) is other than expected({})".format(variable_path,
                                                                              type_of_value,
                                                                              type_of_key_value
                                                                              )
                     ]
    elif type_of_key_value == str:
        result, not_valid = compare_str_value(key_value=key_value, value=value, variable_path=variable_path)
    elif type_of_key_value == int:
        result, not_valid = compare_int_value(key_value=key_value, value=value, variable_path=variable_path)
    elif type_of_key_value == dict:
        result, not_valid = compare_dictionary(key_value=key_value, value=value, variable_path=variable_path)
    elif type_of_key_value == list:
        result, not_valid = compare_list(key_value=key_value, value=value, variable_path=variable_path)

    return result, not_valid


def check_if_range_in_str(str_value):
    m = re.search(r'^~(\d+\.?\d*) \+\- (\d+\.?\d*)$', str_value)
    if m:
        min = float(m.group(1)) - float(m.group(2))
        max = float(m.group(1)) + float(m.group(2))
        return min, max
    else:
        return False


def check_if_or_in_str(str_value):
    m = re.search(r'^.* OR .*$', str_value)
    if m:
        values = str_value.split(" OR ")
        return values
    else:
        return False


def check_if_in_range(value, max, min, variable_path=""):
    if isinstance(value, str):
        value = float(value)
    if min <= value <= max:
        return True, []
    else:
        msg = "Value {} ({}) is not in range <{} {}>".format(value, variable_path, min, max)
        return False, [msg]


def check_if_in_array(value, array, variable_path=""):
    if str(value) in array:
        return True, []
    else:
        msg = "Value {} ({}) is not in array {}".format(value, variable_path, array)
        return False, [msg]


def compare_str_value(key_value, value, variable_path=""):
    if key_value == value:
        return True, []
    else:
        msg = "Value {} ({}) is not equal {} (expected value)".format(value, variable_path, key_value)
        return False, [msg]


def compare_int_value(key_value, value, variable_path=""):
    if key_value == value:
        return True, []
    else:
        msg = "Value {} ({}) is not equal {} (expected value)".format(value, variable_path, key_value)
        return False, [msg]


def compare_dictionary(key_value, value, variable_path=""):
    not_valid_list = []
    for key, val in key_value.items():
        if key not in value:
            not_valid_list.append('Key {} does not exist in {}'.format(key, variable_path))
        else:
            status, not_valid = compare(key_value=val,
                                        value=value[key],
                                        variable_path='{}->{}'.format(variable_path, key)
                                        )
            if status is False:
                not_valid_list = not_valid_list + not_valid

    if len(not_valid_list) != 0:
        return False, not_valid_list
    else:
        return True, not_valid_list


def compare_list(key_value, value, variable_path=""):
    if key_value == value:
        return True, []
    else:
        msg = "Value {} ({}) is not equal {} (expected value)".format(value, variable_path, key_value)
        return False, [msg]


def compare_list_of_dict(key_value, value, variable_path=""):
    main_status = True
    msg_list = []
    if len(key_value) != len(value):
        msg = "Value {} ({}) is not equal {} (expected value)".format(value, variable_path, key_value)
        return False, [msg]

    for index in range(0, len(value)):
        status, msg = compare(key_value=key_value[index], value=value[index],
                              variable_path="->".join([variable_path, str(index)]))
        if status is False:
            main_status = False
            msg_list = msg_list + msg

    return main_status, msg_list


def convert_csv_tti_trace_to_list(path=None, direction='dl'):
    logger_console("Converting TtiTrace csv file to list...")
    if path is None:
        logger_console("Checking TtiTrace path in common Variables...")
        path = BuiltIn().get_variable_value('${TTI_TRACE_PATH}')
        if path is None:
            raise CannotFindTtiTracePathException('Cannot find TtiTrace path')
    tti_list = create_list_from_tti_trace_csv(direction=direction, path_override=path)
    return tti_list


def filter_not_broadcast_tti_by_rnti(tti_list):
    tti_list = filter_tti_traces_with_value_not_in(tti_data=tti_list, column='rnti', values=['0', '65535'])
    return tti_list


def filter_throughput_ttitrace(tti_list):

    temp_tti_list = filter_out_tti_traces_with_value(tti_data=tti_list,
                                                     column='dlDrbWeightData.dlDrbsWeightData[0].sliceId', value='')
    temp_tti_list = create_list_from_column(tti_trace_list=temp_tti_list, column_name="timeStamp")

    first_throughput_ttitrace_timestamp = temp_tti_list[0]
    last_throughput_ttitrace_timestamp = (temp_tti_list[len(temp_tti_list)-1])

    before_throughput_ttitrace = filter_tti_traces_with_value_less_than(tti_data=tti_list,
                                                                        column="timeStamp",
                                                                        value=first_throughput_ttitrace_timestamp
                                                                        )

    after_throughput_ttitrace = filter_tti_traces_with_value_greater_than(tti_data=tti_list,
                                                                          column="timeStamp",
                                                                          value=last_throughput_ttitrace_timestamp
                                                                          )

    throughput_ttitrace = filter_tti_traces_with_value_in_the_range(tti_data=tti_list,
                                                                    column="timeStamp",
                                                                    min=first_throughput_ttitrace_timestamp,
                                                                    max=last_throughput_ttitrace_timestamp
                                                                    )

    return {'before_throughput_ttitrace': before_throughput_ttitrace,
            'throughput_ttitrace': throughput_ttitrace,
            'after_throughput_ttitrace': after_throughput_ttitrace}


def _get_middle_tti_for_not_empty_columns(tti_list, columns_list):
    logger_console("Getting middle tti for columns: {}".format(columns_list))
    header = tti_list[0]
    tti_to_return = {}
    length = len(tti_list)
    middle = int(length / 2)
    for column in columns_list:
        column_index = header.index(column)
        for tti in tti_list[middle:]:
            if tti[column_index] != '':
                tti_to_return[column] = (header, tti)
                break
    return tti_to_return


def _get_middle_tti_for_columns_with_values(tti_list, columns_list):
    logger_console("Getting middle tti for columns with values: {}".format(columns_list))

    header = tti_list[0]
    tti_to_return = {}
    length = len(tti_list)
    middle = int(length / 2)
    for column, expected_values in columns_list.items():
        column_index = header.index(column)
        tti_to_return[column] = {}
        for value in expected_values:
            for tti in tti_list[middle:]:
                if compare_values(tti[column_index], value):
                    tti_to_return[column][value] = (header, tti)
                    break

    return tti_to_return


def compare_values(x, y):
    if isinstance(x, str):
        if x:
            x = json.dumps(ast.literal_eval(x))
            x = json.loads(x)
        if y:
            y = json.dumps(ast.literal_eval(y))
            y = json.loads(y)

    return x == y


def get_value_from_columns_for_single_tti(tti_data, columns_name):
    value = {}
    for column_name in columns_name:
        value[column_name] = create_list_from_column(tti_trace_list=tti_data, column_name=column_name)[0]
    return value
