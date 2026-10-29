# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lei Jia
:contact: lei.jia@nokia-sbell.com
:both for coam_admin and selenium_coam
"""
import logging
from collections import Counter
import csv
from taf.sbts.oam.coam.admin import admin
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter as coam_parameter
from taf.analyzer.ttitrace import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.check_csv_log import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.SG6.gnb_logs.ul_ttitrace_analysis import (
    TTI_Trace_analysis,
)
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

MRBTS_ID = tl.gnbs[0].instance_id
NRBTS_ID = tl.gnbs[0].global_bts_id
MRBTS = "MRBTS-" + str(MRBTS_ID)
NRBTS = "NRBTS-" + str(NRBTS_ID)


tti_trace_analysis = TTI_Trace_analysis()
parameter_index_dict = {}


def get_current_bwpid(dist_name, connection="GNB_OAM"):
    try:
        bwpid_list_param = [
            dict(
                dist_name=dist_name,
                parameter="cellBwpList",
                value=[
                    dict(cellBwpId=None),
                    dict(cellBwpId=None),
                    dict(cellBwpId=None),
                    dict(cellBwpId=None),
                ],
            )
        ]
        cellBwpList = coam_parameter.get_list_values_from_scf_file(
            parameters=bwpid_list_param,
            timeout=600,
            connection=connection,
        )
    except IndexError:
        try:
            bwpid_list_param = [
                dict(
                    dist_name=dist_name,
                    parameter="cellBwpList",
                    value=[
                        dict(cellBwpId=None),
                        dict(cellBwpId=None),
                        dict(cellBwpId=None),
                    ],
                )
            ]
            cellBwpList = coam_parameter.get_list_values_from_scf_file(
                parameters=bwpid_list_param, timeout=600, connection=connection
            )
        except Exception:
            bwpid_list_param = [
                dict(
                    dist_name=dist_name,
                    parameter="cellBwpList",
                    value=[dict(cellBwpId=None), dict(cellBwpId=None)],
                )
            ]
            cellBwpList = coam_parameter.get_list_values_from_scf_file(
                parameters=bwpid_list_param, timeout=600, connection=connection
            )
    logging.debug("cellBwpList is {} for cell {} ".format(cellBwpList, dist_name))
    return cellBwpList[0]["value"]


def get_cell_chbw(dist_name, connection="GNB_OAM"):
    chbw = coam_parameter.get_single_value_from_scf_file(
        dist_name=dist_name, parameter="chBw", timeout=600, connection=connection
    )
    return chbw


def get_first_column_values(file_path, column_number=1):
    """
    author: Lei Jia
    Get the First Column Values, return test counts 1, 2, 3, 4, 5, 6... and first column name: Test_Count
    :param event_matrix:
    :return:
    """
    column_header_dict = tti_trace_analysis.get_column_header()
    event_matrix = read_csv_file_into_matrix(tti_trace_analysis.file_path)
    first_column_values = get_unique_values_in_column(
        matrix=event_matrix,
        column_number=column_number,
    )
    new_column_header_dict = {v: k for k, v in column_header_dict.items()}
    first_column_values = [
        x for x in first_column_values if x != new_column_header_dict[1]
    ]
    return first_column_values, new_column_header_dict[1]


def get_bwp_parameters_column(file_path, test_count, first_column_name):
    """
    author: Lei Jia
    :return:
    """
    with open(file_path, "r", encoding="utf-8-sig") as csv_file:
        reader = list(csv.reader(csv_file))
    parameter_index_dict["INDEX_Test_Count"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name=first_column_name,
    )
    parameter_index_dict["INDEX_Scenario"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="Scenario",
    )
    parameter_index_dict["INDEX_Category"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="Category",
    )
    parameter_index_dict["INDEX_MO_DN"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="MO_DN",
    )
    parameter_index_dict["INDEX_Parameters_Type"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="Parameters_Type",
    )
    parameter_index_dict["INDEX_ListName"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="List_Name",
    )
    parameter_index_dict["INDEX_ListIndex"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="List_Index",
    )
    parameter_index_dict["INDEX_Filter_Param"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="Filter_Param",
    )
    parameter_index_dict["INDEX_Parameters_Name"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="Parameters_Name",
    )
    parameter_index_dict["INDEX_Parameters_Value"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="Parameters_Value",
    )
    parameter_index_dict["INDEX_TestUEIndex"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="TestUEIndex",
    )
    parameter_index_dict["INDEX_PcellIndex"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="PcellIndex",
    )
    parameter_index_dict["INDEX_LteCellIndex"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="LteCellIndex",
    )
    parameter_index_dict["INDEX_TestUEMode"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="TestUEMode",
    )
    parameter_index_dict["INDEX_TestMode"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="TestMode",
    )
    parameter_index_dict["INDEX_Attenuation_Start"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="Attenuation_Start",
    )
    parameter_index_dict["INDEX_Attenuation_End"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="Attenuation_End",
    )
    parameter_index_dict["INDEX_Attenuation_Step"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="Attenuation_Step",
    )
    parameter_index_dict["INDEX_TargetTput_DL"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="TargetTput_DL(Mbps)",
    )
    parameter_index_dict["INDEX_TargetTput_UL"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="TargetTput_UL(Mbps)",
    )
    parameter_index_dict["INDEX_Target_Bler"] = tti_trace_analysis.get_columns(
        reader_list=reader,
        filter=test_count,
        column_name="Target_Bler(%)",
    )


def get_category_value_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_unique_column_values_and_count(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_Category"],
    )


def get_moDN_value_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_MO_DN"],
    )


def get_parametersType_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_Parameters_Type"],
    )


def get_listName_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_ListName"],
    )


def get_listIndex_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_ListIndex"],
    )


def get_filter_param_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_Filter_Param"],
    )


def get_parametersName_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_Parameters_Name"],
    )


def get_parametersValue_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_Parameters_Value"],
    )


def get_Scenario_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_Scenario"],
    )


def get_TestUEIndex_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_TestUEIndex"],
    )


def get_PcellIndex_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_PcellIndex"],
    )


def get_LteCellIndex_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_LteCellIndex"],
    )


def get_TestUEMode_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_TestUEMode"],
    )


def get_TestMode_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_TestMode"],
    )


def get_Attenuation_Start_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_Attenuation_Start"],
    )


def get_Attenuation_End_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_Attenuation_End"],
    )


def get_Attenuation_Step_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_Attenuation_Step"],
    )


def get_TargetTput_DL_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_TargetTput_DL"],
    )


def get_TargetTput_UL_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_TargetTput_UL"],
    )


def get_Target_Bler_list(event_matrix):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    return tti_trace_analysis.get_column_values_from_matrix(
        matrix=event_matrix,
        column_number=parameter_index_dict["INDEX_Target_Bler"],
    )


def get_testCount_event(test_count):
    """
    author: Lei Jia
    :return:
    """
    event_res = tti_trace_analysis.get_specific_event(event_name=test_count)
    return add_filters_to_matrix(
        event_res, [parameter_index_dict["INDEX_Test_Count"], [test_count]]
    )


def get_testCount_event_by_category(event_matrix, category):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    category = str(category)
    return add_filters_to_matrix(
        event_matrix,
        [parameter_index_dict["INDEX_Category"], [category]],
    )


def get_testCount_event_with_modn_and_parametertype(event_matrix, modn):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    category = str(modn)
    return add_filters_to_matrix(
        event_matrix,
        [parameter_index_dict["INDEX_MO_DN"], [category]],
    )


def get_parametertype_event_with_testcount_and_category(event_matrix, parameterstype):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    parameterstype = str(parameterstype)
    return add_filters_to_matrix(
        event_matrix,
        [parameter_index_dict["INDEX_Parameters_Type"], [parameterstype]],
    )


def get_listname_event_with_testcount_and_category(event_matrix, listname):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    listname = str(listname)
    return add_filters_to_matrix(
        event_matrix,
        [parameter_index_dict["INDEX_ListName"], [listname]],
    )


def generate_update_list_params(
    listname_event,
    listname_value,
    listindexs_list,
    test_count,
    dist_name_value,
    updated_list_params,
):
    list_params_values = []
    for listindex in listindexs_list:
        parametername, parametervalue = get_list_parameter_with_listname_and_index(
            event_matrix=listname_event, listindex=listindex
        )
        logging.debug(
            "for list name {} list index {}, parameter name is {}, parameter value is {}".format(
                listname_value, listindex, parametername, parametervalue
            )
        )
        if "bwpDN" in parametername:
            list_param_value_with_index_dict = {
                parametername: parametervalue,
                "cellBwpId": listindex,
            }
        else:
            list_param_value_with_index_dict = {parametername: parametervalue}
        list_params_values.append(list_param_value_with_index_dict)
    list_params_dict = dict(
        dist_name=dist_name_value, parameter=listname_value, value=list_params_values
    )
    updated_list_params.append(list_params_dict)
    logging.debug(
        "for testcount {}, these list params with list index need to be updated: {}".format(
            test_count, updated_list_params
        )
    )


def generate_add_list_params(
    listname_event,
    listname_value,
    listindexs_list,
    test_count,
    dist_name_value,
    add_list_params,
):
    list_params_values = []
    for listindex in listindexs_list:
        parametername, parametervalue = get_list_parameter_with_listname_and_index(
            event_matrix=listname_event, listindex=listindex
        )
        logging.debug(
            "for list name {} list index {}, parameter name is {}, parameter value is {}".format(
                listname_value, listindex, parametername, parametervalue
            )
        )
        if "bwpDN" in parametername:
            list_param_value_with_index_dict = {
                parametername: parametervalue,
                "cellBwpId": listindex,
            }
        else:
            list_param_value_with_index_dict = {parametername: parametervalue}
        list_params_values.append(list_param_value_with_index_dict)
    list_params_dict = dict(
        dist_name=dist_name_value, parameter=listname_value, value=list_params_values
    )
    add_list_params.append(list_params_dict)
    logging.debug(
        "for testcount {}, these list params with list index need to be added: {}".format(
            test_count, add_list_params
        )
    )


def generate_delete_list_params(
    listname_event, listname_value, test_count, dist_name_value, delete_list_params
):
    list_params_dict = dict(dist_name=dist_name_value, parameter=listname_value)
    delete_list_params.append(list_params_dict)
    logging.debug(
        "for testcount {}, these list need to be deleted: {}".format(
            test_count, delete_list_params
        )
    )


def generate_list_params(event_matrix, test_count, dist_name_value):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    updated_list_params = []
    add_list_params = []
    delete_list_params = []
    listname_values_list = get_listName_list(event_matrix=event_matrix)
    listname_values_list = list(set(listname_values_list))
    list_params_dict = {}
    for listname_value in listname_values_list:

        listname_event = get_listname_event_with_testcount_and_category(
            event_matrix=event_matrix, listname=listname_value
        )
        listindexs_list = get_listIndex_list(event_matrix=listname_event)
        listindexs_list = [x for x in list(set(listindexs_list)) if x]
        listindexs_list.sort()
        if len(listindexs_list) > 0:
            cellBwpId = get_current_bwpid(dist_name=dist_name_value)
            if len(listindexs_list) != len(cellBwpId):
                generate_delete_list_params(
                    listname_event=listname_event,
                    listname_value=listname_value,
                    test_count=test_count,
                    dist_name_value=dist_name_value,
                    delete_list_params=delete_list_params,
                )
                generate_add_list_params(
                    listname_event=listname_event,
                    listname_value=listname_value,
                    listindexs_list=listindexs_list,
                    dist_name_value=dist_name_value,
                    add_list_params=add_list_params,
                    test_count=test_count,
                )
            else:
                generate_update_list_params(
                    listname_event=listname_event,
                    listname_value=listname_value,
                    listindexs_list=listindexs_list,
                    updated_list_params=updated_list_params,
                    dist_name_value=dist_name_value,
                    test_count=test_count,
                )
        else:
            list_params_values = []
            list_param_value_wo_index_dict = {}
            parameternames_list = get_parametersName_list(event_matrix=listname_event)
            parameternames_list = list(set(parameternames_list))
            for parametername in parameternames_list:
                parametervalue, modn_value = get_parametervalue_with_parametername(
                    event_matrix=listname_event, parametername=parametername
                )
                logging.debug(
                    "for list name {}, parameter name is {}, parameter value is {}".format(
                        listname_value, parametername, parametervalue
                    )
                )
                list_param_value_wo_index_dict[parametername] = parametervalue
            list_params_values.append(list_param_value_wo_index_dict)
            list_params_dict = dict(
                dist_name=dist_name_value,
                parameter=listname_value,
                value=list_params_values,
            )
            updated_list_params.append(list_params_dict)
            logging.debug(
                "for testcount {}, these list params without list index need to be updated: {}".format(
                    test_count, updated_list_params
                )
            )
    return updated_list_params, delete_list_params, add_list_params


def get_list_parameter_with_listname_and_index(event_matrix, listindex):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    event_res = add_filters_to_matrix(
        event_matrix,
        [parameter_index_dict["INDEX_ListIndex"], [listindex]],
    )
    parameternames_list = get_parametersName_list(event_matrix=event_res)
    parametervalues_list = get_parametersValue_list(event_matrix=event_res)
    return parameternames_list[0].strip(), parametervalues_list[0].strip()


def get_parametervalue_with_parametername(event_matrix, parametername):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    event_res = add_filters_to_matrix(
        event_matrix,
        [parameter_index_dict["INDEX_Parameters_Name"], [parametername]],
    )
    parametervalues_list = get_parametersValue_list(event_matrix=event_res)
    modn_values_list = get_moDN_value_list(event_matrix=event_res)
    return parametervalues_list[0].strip(), modn_values_list[0].strip()


def get_filterparam_with_parametername(event_matrix, parametername):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    event_res = add_filters_to_matrix(
        event_matrix,
        [parameter_index_dict["INDEX_Parameters_Name"], [parametername]],
    )
    filterparam_list = get_filter_param_list(event_matrix=event_res)
    return filterparam_list[0].strip()


def get_modn_with_parametername(event_matrix, parametername):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    event_res = add_filters_to_matrix(
        event_matrix,
        [parameter_index_dict["INDEX_Parameters_Name"], [parametername]],
    )
    modn_values_list = get_moDN_value_list(event_matrix=event_res)
    return modn_values_list


def generate_params(event_matrix, test_count, dist_name_value):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    updated_params = []
    param_dict = {}
    parameternames_list = get_parametersName_list(event_matrix=event_matrix)
    parameternames_list = list(set(parameternames_list))
    for parametername in parameternames_list:
        parametervalue, modn_value = get_parametervalue_with_parametername(
            event_matrix=event_matrix, parametername=parametername
        )
        param_dict = dict(
            dist_name=dist_name_value,
            parameter=parametername.strip(),
            value=parametervalue,
        )
        updated_params.append(param_dict)
        logging.debug(
            "for testcount {}, these params need to be updated: {}".format(
                test_count, updated_params
            )
        )
    return updated_params


def get_testcount_from_csv_file(file_path):
    """
    Author:Lei Jia
    :return: testcount
    """
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    first_column_values, first_column_name = get_first_column_values(
        file_path=file_path
    )
    logging.debug(
        "first_column_values is {}{}".format(first_column_values, first_column_name)
    )
    int_test_count_values = list(map(int, first_column_values))
    int_test_count_values.sort()
    return int_test_count_values


def get_category_based_on_testcount(file_path, test_count):
    """
    Author:Lei Jia
    :return:
    """
    first_column_values, first_column_name = get_first_column_values(
        file_path=file_path
    )
    if test_count:
        get_bwp_parameters_column(
            file_path=file_path,
            test_count=str(test_count),
            first_column_name=first_column_name,
        )
    testcount_event = get_testCount_event(test_count=str(test_count))
    category_values, category_count = get_category_value_list(
        event_matrix=testcount_event,
    )
    category_values = list(set(category_values))
    return category_values


def get_parameters_value_based_on_testcount_and_category(
    file_path, test_count, category_value
):
    """
    Author:Lei Jia
    :return:parameters_value based on testcount and category
    """
    testcount_event = get_testCount_event(test_count=str(test_count))
    scenario_list = get_Scenario_list(
        event_matrix=testcount_event,
    )
    testcount_event_with_category = get_testCount_event_by_category(
        event_matrix=testcount_event, category=category_value
    )
    parametersValue_list = get_parametersValue_list(
        event_matrix=testcount_event_with_category
    )
    return parametersValue_list[0]


def get_testing_related_params_based_on_testcount(file_path, test_count):
    """
    Author:Lei Jia
    :return:
    """
    testcount_event = get_testCount_event(test_count=str(test_count))
    scenario_list = get_Scenario_list(
        event_matrix=testcount_event,
    )
    TestUEIndex_list = get_TestUEIndex_list(
        event_matrix=testcount_event,
    )
    PcellIndex_list = get_PcellIndex_list(
        event_matrix=testcount_event,
    )
    LteCellIndex_list = get_LteCellIndex_list(
        event_matrix=testcount_event,
    )
    TestUEMode_list = get_TestUEMode_list(
        event_matrix=testcount_event,
    )
    TestMode_list = get_TestMode_list(
        event_matrix=testcount_event,
    )
    Attenuation_Start_list = get_Attenuation_Start_list(
        event_matrix=testcount_event,
    )
    Attenuation_End_list = get_Attenuation_End_list(
        event_matrix=testcount_event,
    )
    Attenuation_Step_list = get_Attenuation_Step_list(
        event_matrix=testcount_event,
    )
    TargetTput_DL_list = get_TargetTput_DL_list(
        event_matrix=testcount_event,
    )
    TargetTput_UL_list = get_TargetTput_UL_list(
        event_matrix=testcount_event,
    )
    Target_Bler_list = get_Target_Bler_list(
        event_matrix=testcount_event,
    )
    testing_params_output_dict = {}
    testing_params_output_dict["TestCount"] = test_count
    testing_params_output_dict["Scenario"] = scenario_list[-1].strip()
    testing_params_output_dict["TestUEIndex"] = TestUEIndex_list[-1].strip()
    testing_params_output_dict["PcellIndex"] = PcellIndex_list[-1].strip()
    testing_params_output_dict["LteCellIndex"] = LteCellIndex_list[-1].strip()
    testing_params_output_dict["TestUEMode"] = TestUEMode_list[-1].strip()
    testing_params_output_dict["TestMode"] = TestMode_list[-1].strip()
    testing_params_output_dict["Attenuation_Start"] = Attenuation_Start_list[-1].strip()
    testing_params_output_dict["Attenuation_End"] = Attenuation_End_list[-1].strip()
    testing_params_output_dict["Attenuation_Step"] = Attenuation_Step_list[-1].strip()
    testing_params_output_dict["TargetTput_DL(Mbps)"] = TargetTput_DL_list[-1].strip()
    testing_params_output_dict["TargetTput_UL(Mbps)"] = TargetTput_UL_list[-1].strip()
    testing_params_output_dict["Target_Bler(%)"] = Target_Bler_list[-1].strip()
    return testing_params_output_dict


def get_nrCellType_related_params_based_on_testcount(file_path, test_count):
    """
    get nrCellType, ulMaxMuMimoLayer, dlMuMaxNumLayerPerMuRbg, actBbPoolTddFr1, actLargeBbPoolTddFr1 param values
    Author:Lei Jia
    :return:
    """
    testcount_event = get_testCount_event(test_count=str(test_count))
    celltype_related_params = []
    nrcelltype_values = []
    celltype_param_name_list = [
        "nrCellType",
        "ulMaxMuMimoLayer",
        "dlMuMaxNumLayerPerMuRbg",
        "actBbPoolTddFr1",
        "actLargeBbPoolTddFr1",
    ]
    for parametername in celltype_param_name_list:
        modn_values_list = get_modn_with_parametername(testcount_event, parametername)
        for modn_value in modn_values_list:
            modn_event = get_testCount_event_with_modn_and_parametertype(
                event_matrix=testcount_event, modn=modn_value
            )
            parametervalue, modn_value = get_parametervalue_with_parametername(
                event_matrix=modn_event, parametername=parametername
            )
            filter_param = get_filterparam_with_parametername(
                event_matrix=modn_event, parametername=parametername
            )
            param_dict = dict(
                dist_name=modn_value,
                abbr=parametername.strip(),
                filter_param=filter_param,
                new_value=parametervalue,
            )
            celltype_related_params.append(param_dict)
            if "nrCellType" in parametername:
                nrcelltype_values.append(param_dict)
        logging.debug(
            "for testcount {}, nrcelltype related params are list out: {}".format(
                test_count, celltype_related_params
            )
        )
    return nrcelltype_values, celltype_related_params


def generate_chbw_updated_params_based_on_testcount(
    file_path, test_count, category_value
):
    """
    Author:Lei Jia
    :return:
    """
    all_params_need_to_updated = []
    all_params_need_to_add = []
    all_params_need_to_delete = []
    testcount_event = get_testCount_event(test_count=str(test_count))
    logging.debug(
        "------ Start to modify bwp related parameters for round {}".format(test_count)
    )
    testcount_event_with_category = get_testCount_event_by_category(
        event_matrix=testcount_event, category=category_value
    )
    parameterstypes_list = get_parametersType_list(
        event_matrix=testcount_event_with_category
    )
    parameterstypes_list = list(set(parameterstypes_list))
    for parameterstype in parameterstypes_list:
        parametertype_event = get_parametertype_event_with_testcount_and_category(
            testcount_event_with_category, parameterstype=parameterstype
        )
        modn_values_list = get_moDN_value_list(event_matrix=parametertype_event)
        modn_values_list = list(set(modn_values_list))
        for item in modn_values_list:
            modn_value = item.strip()
            if "nrcell" in modn_value.lower():
                dist_name_value = MRBTS + "/" + NRBTS + "/" + modn_value
            else:
                dist_name_value = modn_value
            modn_event = get_testCount_event_with_modn_and_parametertype(
                event_matrix=parametertype_event, modn=modn_value
            )
            if "list" in parameterstype.lower():
                (
                    updated_list_params,
                    delete_list_params,
                    add_list_params,
                ) = generate_list_params(
                    event_matrix=modn_event,
                    test_count=test_count,
                    dist_name_value=dist_name_value,
                )
                logging.debug(
                    "for testcount {}, dist_name {}, list params need to add are:{}".format(
                        test_count, dist_name_value, add_list_params
                    )
                )
                logging.debug(
                    "for testcount {}, dist_name {}, list params need to delete:{}".format(
                        test_count, dist_name_value, delete_list_params
                    )
                )
                logging.debug(
                    "for testcount {}, dist_name {}, list params need to update:{}".format(
                        test_count, dist_name_value, updated_list_params
                    )
                )
                all_params_need_to_updated.extend(updated_list_params)
                all_params_need_to_add.extend(add_list_params)
                all_params_need_to_delete.extend(delete_list_params)
            else:
                updated_params = generate_params(
                    event_matrix=modn_event,
                    test_count=test_count,
                    dist_name_value=dist_name_value,
                )
                all_params_need_to_updated.extend(updated_params)
    return all_params_need_to_updated, all_params_need_to_delete, all_params_need_to_add


def generate_add_list_params_with_selenium(
    listname_event,
    listname_value,
    listindexs_list,
    test_count,
    dist_name_value,
    add_list_params,
    cellBwpId_dict,
):
    list_params_dict = []
    for index in listindexs_list:
        parametername, parametervalue = get_list_parameter_with_listname_and_index(
            event_matrix=listname_event, listindex=index
        )
        filter_param = get_filterparam_with_parametername(
            event_matrix=listname_event, parametername=parametername
        )
        list_params_dict = dict(
            dist_name=dist_name_value,
            filter_param=filter_param,
            abbr=parametername.strip(),
            new_value=parametervalue,
            bwpdn_index=int(index) + len(cellBwpId_dict),
            node_index=int(index),
        )
        add_list_params.append(list_params_dict)
    logging.debug(
        "for testcount {}, these list params with list index need to be added: {}".format(
            test_count, add_list_params
        )
    )


def generate_delete_list_params_with_selenium(
    listname_event,
    listname_value,
    test_count,
    dist_name_value,
    listindexs_list,
    delete_list_params,
    cellBwpId_dict,
):
    parametername, parametervalue = get_list_parameter_with_listname_and_index(
        event_matrix=listname_event, listindex=listindexs_list[0]
    )
    filter_param = get_filterparam_with_parametername(
        event_matrix=listname_event, parametername=parametername
    )
    for index in sorted(list(range(len(cellBwpId_dict))), reverse=True):
        list_params_dict = dict(
            dist_name=dist_name_value,
            filter_param=filter_param,
            abbr=parametername.strip(),
            node_index=int(index),
        )
        delete_list_params.append(list_params_dict)
    logging.debug(
        "for testcount {}, list element need to be deleted: {}".format(
            test_count, delete_list_params
        )
    )


def generate_list_params_with_selenium(
    event_matrix, test_count, dist_name_value, chbw_update_flag
):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    updated_list_params = []
    deleted_list_params = []
    add_list_params = []
    listname_values_list = get_listName_list(event_matrix=event_matrix)
    listname_values_list = list(set(listname_values_list))
    list_params_dict = {}
    for listname_value in listname_values_list:

        listname_event = get_listname_event_with_testcount_and_category(
            event_matrix=event_matrix, listname=listname_value
        )
        listindexs_list = get_listIndex_list(event_matrix=listname_event)
        listindexs_list = [x for x in list(set(listindexs_list)) if x]
        listindexs_list.sort()
        if len(listindexs_list) > 0:
            if chbw_update_flag:
                cellBwpId_dict = get_current_bwpid(dist_name=dist_name_value)
                generate_delete_list_params_with_selenium(
                    listname_event=listname_event,
                    listname_value=listname_value,
                    test_count=test_count,
                    listindexs_list=listindexs_list,
                    dist_name_value=dist_name_value,
                    delete_list_params=deleted_list_params,
                    cellBwpId_dict=cellBwpId_dict,
                )
                generate_add_list_params_with_selenium(
                    listname_event=listname_event,
                    listname_value=listname_value,
                    test_count=test_count,
                    listindexs_list=listindexs_list,
                    dist_name_value=dist_name_value,
                    add_list_params=add_list_params,
                    cellBwpId_dict=cellBwpId_dict,
                )
        else:
            list_params_values = []
            list_param_value_wo_index_dict = {}
            parameternames_list = get_parametersName_list(event_matrix=listname_event)
            parameternames_list = list(set(parameternames_list))
            for parametername in parameternames_list:
                parametervalue, modn_value = get_parametervalue_with_parametername(
                    event_matrix=listname_event, parametername=parametername
                )
                filter_param = get_filterparam_with_parametername(
                    event_matrix=listname_event, parametername=parametername
                )
                logging.debug(
                    "for list name {}, parameter name is {}, parameter value is {}".format(
                        listname_value, parametername, parametervalue
                    )
                )
                list_params_dict = dict(
                    dist_name=dist_name_value,
                    abbr=parametername.strip(),
                    filter_param=filter_param,
                    new_value=parametervalue,
                )
                updated_list_params.append(list_params_dict)
            logging.debug(
                "for testcount {}, these list params without list index need to be updated: {}".format(
                    test_count, updated_list_params
                )
            )
    return updated_list_params, deleted_list_params, add_list_params


def generate_params_with_selenium(event_matrix, test_count, dist_name_value):
    """
    author: Lei Jia
    :param event_matrix:
    :return:
    """
    updated_params = []
    param_dict = {}
    parameternames_list = get_parametersName_list(event_matrix=event_matrix)
    parameternames_list = list(set(parameternames_list))
    for parametername in parameternames_list:
        parametervalue, modn_value = get_parametervalue_with_parametername(
            event_matrix=event_matrix, parametername=parametername
        )
        filter_param = get_filterparam_with_parametername(
            event_matrix=event_matrix, parametername=parametername
        )
        param_dict = dict(
            dist_name=dist_name_value,
            abbr=parametername.strip(),
            filter_param=filter_param,
            new_value=parametervalue,
        )
        updated_params.append(param_dict)
        logging.debug(
            "for testcount {}, these params need to be updated: {}".format(
                test_count, updated_params
            )
        )
    return updated_params


def generate_chbw_updated_params_based_on_testcount_with_selenium(
    file_path, test_count, category_value
):
    """
    Author:Lei Jia
    :return:
    """
    all_params_need_to_updated = []
    all_params_need_to_deleted = []
    all_params_need_to_added = []
    testcount_event = get_testCount_event(test_count=str(test_count))
    logging.debug(
        "------ Start to modify bwp related parameters for round {}".format(test_count)
    )
    testcount_event_with_category = get_testCount_event_by_category(
        event_matrix=testcount_event, category=category_value
    )
    modn_values_list = get_moDN_value_list(event_matrix=testcount_event_with_category)
    modn_values_list = list(set(modn_values_list))
    logging.debug("modn_values_list are {}".format(modn_values_list))
    for item in modn_values_list:
        updated_params_per_cell_dict = {}
        modn_value = item.strip()
        logging.debug("modn_value is {}".format(modn_value))
        if "nrcell" in modn_value.lower():
            dist_name_value = MRBTS + "/" + NRBTS + "/" + modn_value
            logging.debug("enter to 1 {}".format(dist_name_value))
        else:
            dist_name_value = modn_value
            logging.debug("enter to 2 {}".format(dist_name_value))
        modn_event = get_testCount_event_with_modn_and_parametertype(
            event_matrix=testcount_event_with_category, modn=modn_value
        )
        # logging.debug("modn_event {}".format(modn_event))
        parameterstypes_list = get_parametersType_list(event_matrix=modn_event)
        parameterstypes_list = list(set(parameterstypes_list))
        logging.debug("parameterstypes_list are {}".format(parameterstypes_list))
        logging.debug("dist_name_value is {}".format(dist_name_value))
        last_dist_name_prefix = dist_name_value.split("/")[-1]
        if "NRCELL" in last_dist_name_prefix:
            logging.debug("enter to 3")
            current_chbw = get_cell_chbw(dist_name=dist_name_value)
            logging.debug("current_chbw is {}".format(current_chbw))
            updated_chbw, modn_value = get_parametervalue_with_parametername(
                event_matrix=modn_event, parametername="chBw"
            )
            logging.debug(
                "chbw in current scf is {}, updated chbw is {} for {}".format(
                    current_chbw, updated_chbw, dist_name_value
                )
            )
            chbw_update_flag = True if current_chbw != updated_chbw else False
            logging.debug("updated chbw flag is {}".format(chbw_update_flag))
        for parameterstype in parameterstypes_list:
            parametertype_event = get_parametertype_event_with_testcount_and_category(
                modn_event, parameterstype=parameterstype
            )
            if "list" in parameterstype.lower():
                (
                    updated_list_params,
                    deleted_list_params,
                    add_list_params,
                ) = generate_list_params_with_selenium(
                    event_matrix=parametertype_event,
                    test_count=test_count,
                    dist_name_value=dist_name_value,
                    chbw_update_flag=chbw_update_flag,
                )
                logging.debug(
                    "for testcount {}, dist_name {}, list params need to update:{}".format(
                        test_count, dist_name_value, updated_list_params
                    )
                )
                all_params_need_to_updated.extend(updated_list_params)
                all_params_need_to_added.extend(add_list_params)
                all_params_need_to_deleted.extend(deleted_list_params)
            else:
                updated_params = generate_params_with_selenium(
                    event_matrix=parametertype_event,
                    test_count=test_count,
                    dist_name_value=dist_name_value,
                )
                all_params_need_to_updated.extend(updated_params)
    return (
        all_params_need_to_updated,
        all_params_need_to_deleted,
        all_params_need_to_added,
    )
