import copy
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import os
import time


def is_numeric(value):
    try:
        float(value)
        return True
    except ValueError:
        return False


def get_online_parameter_value(paras_info, dn, para_struct_path, return_list=False):
    """This keyword is used to get parameter value from current plan.
    | Input Parameters | Man. | Description |
    |  paras_info | Yes |  all parameter info returned by taf kw search_parameters_of_current_plan  |
    |  dn   | Yes |  fault id |
    |  para_struct_path   | Yes |  parameter path, like a2ThresholdRedirectSsbRsrp/0/a2MeasRedirectSsbRsrp  |


    *RETURN VALUE*
    parameter value, if it's simple or complex parameter, returns string type
    if it's a simple list type parameter, it will return a list.

    Example
    |  get_online_parameter_value  |  MRBTS-5248     |   btsName  |
    |  get_online_parameter_value  |  MRBTS-52/NRBTS-1/NRCELL-1| a2ThresholdRedirectSsbRsrp/0/a2MeasRedirectSsbRsrp |
    """
    para_struct_list = para_struct_path.split('/')
    items = paras_info["items"]
    for item in items:
        if item["distname"] == dn and item['parameter_name'] == para_struct_list[0]:
            para_info = item["parameter"]
            para_type = item["parameter"]["parameter_type"]
            if para_type == "simple":
                return _get_simple_parameter_value(para_info)
            elif para_type == "complex":
                return _get_complex_parameter_value(para_info, para_struct_list, return_list=return_list)
            elif para_type == "simpleList":
                return _get_simple_list_parameter_value(para_info)
            else:
                logger.error(
                    "Parameter type is not simple or complex or simpleList")


def _get_simple_parameter_value(para_info):
    # if item_info["parameter"]["simple_parameter"]["name"] == para_name:
    simple_value = para_info["simple_parameter"]
    if 'value' in simple_value.keys():
        return simple_value["value"]


def _get_complex_parameter_value(para_info, para_struct_list, return_list=False):
    if return_list:
        return para_info['complex_parameter']['value']
    complex_para_value = para_info['complex_parameter']['value'][int(para_struct_list[1])]

    for struct_para in complex_para_value.structure_parameters:
        if struct_para.parameter_type == 'simple' \
                and struct_para.simple_parameter.name == para_struct_list[-1] \
                and hasattr(struct_para.simple_parameter, 'value'):
            return struct_para.simple_parameter.value
        if struct_para.parameter_type == 'simpleList' \
                and struct_para.simple_list_parameter.name == para_struct_list[-1] \
                and hasattr(struct_para.simple_list_parameter, 'value'):
            return struct_para.simple_list_parameter.value


def _get_simple_list_parameter_value(para_info):
    # if item_info["parameter"]["simple_list_parameter"]["name"] == para_name:
    simple_list_value = para_info["simple_list_parameter"]
    if 'value' in simple_list_value.keys():
        return simple_list_value["value"]


def generate_delta_parameters_for_multiple_mo(updated_para_value_dict, origin_para_value_dict):
    ret_list = []
    for mo, para_value_info in updated_para_value_dict.items():
        one_mo_to_be_updated = copy.deepcopy(para_value_info)
        one_mo_to_be_updated_list = generate_delta_parameters_for_one_mo_for_changing_value(
            mo=mo, mo_value=one_mo_to_be_updated, origin_para_value_dict=origin_para_value_dict
        )
        for i in one_mo_to_be_updated_list:
            ret_list.append(i)
    return ret_list


def generate_delta_parameters_for_one_mo_for_changing_value(mo, mo_value, origin_para_value_dict):
    rtn_list_for_one_mo = []
    para_keys = mo_value.keys()
    for key, new_parameter_value in mo_value.items():
        # set mo_dn
        tmp_dict = {}
        tmp_dict["mo_dn"] = mo

        # set '<parameter_name>':'<parameter_value>'
        tmp_dict[key] = new_parameter_value

        # set operation
        original_mo_value = origin_para_value_dict.get(mo)
        original_parameter_value = original_mo_value.get(key)
        if (original_parameter_value is None) and new_parameter_value is not None:
            operation = "add"
        elif original_parameter_value is not None and new_parameter_value is not None:
            operation = "replace"
        elif original_parameter_value is not None and new_parameter_value is None:
            operation = "remove"
        else:
            operation = "remove"

        para_list = key.split("/")
        is_first_para_of_list = is_numeric(para_list[-1])

        # When remove it, we does not need "index" information for "/staticRoutes/<index>",
        # but we need it for "/acceptedClockClass/<index>"
        add_to_list = True
        if operation == "remove" and is_first_para_of_list is True:
            add_to_list = vdu_need_add_delete_info_to_list(para=key, para_keys=para_keys)
        if add_to_list is True:
            tmp_dict["operation"] = operation
            rtn_list_for_one_mo.append(tmp_dict)
    return rtn_list_for_one_mo


def vdu_need_add_delete_info_to_list(para, para_keys):
    filter = [i for i in para_keys if i.startswith(para)]
    rtn = True if len(filter) == 1 else False
    return rtn


def get_a_directory(*path):
    """
    crete a directory and return absolute path
    *Argument Description*
    | Input Parameters | Man. | Description |
    | path | Yes | list type, e.g, ["folder1", "fold2"] |

    *RETURN VALUE*
    string, a directory absolute path.

    *Example*:
    | ${folder_name}  | get_a_directory | folder1 | folder2 |
    """
    builtin_obj = BuiltIn()
    rtn = ""
    try:
        builtin_obj.log("Start get a directory", "INFO")
        log_path = generate_log_path(builtin_obj)
        builtin_obj.log("general log path" + log_path, "INFO")
        abs_path = os.path.join(log_path, os.path.sep.join(path))
        builtin_obj.log(abs_path, "INFO")
        if not os.path.exists(abs_path):
            os.makedirs(abs_path)
        rtn = abs_path
    except Exception as e:
        builtin_obj.log(e, "ERROR")
    if len(rtn) == 0:
        raise RuntimeError("get_a_directory(): fail!!")
    return rtn


def generate_log_path(BuiltIn_obj):
    """Generate case log path(will not create the log folder).
     """
    output_dir = BuiltIn_obj.get_variable_value("${OUTPUT_DIR}")
    print("output_dir:{}".format(output_dir))

    test_name = BuiltIn_obj.get_variable_value("${TEST_NAME}")
    timestamp = BuiltIn_obj.get_variable_value("${START_TIME}")

    if test_name:
        log_path_without_suite_name = os.path.join("TESTCASE__" + str(test_name), timestamp)
    else:
        log_path_without_suite_name = os.path.join(timestamp)

    log_path_without_suite_name = log_path_without_suite_name.replace(" ", "_").replace(":", "_").replace("-", "_")
    log_path = os.path.join(output_dir, log_path_without_suite_name)
    return log_path


def create_a_directory_for_param(log_path, directory_name):
    builtin_obj = BuiltIn()
    rtn = ""
    try:
        abs_path = os.path.join(log_path, directory_name)
        builtin_obj.log(abs_path, "INFO")
        if not os.path.exists(abs_path):
            os.makedirs(abs_path)
        rtn = abs_path
    except Exception as e:
        builtin_obj.log(e, "ERROR")
    if len(rtn) == 0:
        raise RuntimeError("get_a_directory(): fail!!")
    return rtn


# for M2M
def generate_delta_parameters_for_multiple_mo_for_m2m(updated_para_value_dict, origin_para_value_dict):
    ret_list = []
    for mo, para_value_info in updated_para_value_dict.items():
        one_mo_to_be_updated_list = generate_delta_parameters_for_one_mo_for_m2m(
            mo=mo, mo_value=para_value_info, origin_para_value_dict=origin_para_value_dict
        )
        if one_mo_to_be_updated_list:
            ret_list.append({
                "distName": mo,
                "operation": "update",
                "parameters": one_mo_to_be_updated_list
            })
    return ret_list


def need_add_delete_info_to_list_for_m2m(para, para_keys):
    filter = [i for i in para_keys if i.startswith(para)]
    rtn = True if len(filter) == 1 else False
    return rtn


def generate_delta_parameters_for_one_mo_for_m2m(mo, mo_value, origin_para_value_dict):
    rtn_list_for_one_mo = []
    para_keys = mo_value.keys()
    for key, new_parameter_value in mo_value.items():
        tmp_dict = {
            "parameterName": key,
            "value": new_parameter_value,
            "operation": "update"
        }

        original_mo_value = origin_para_value_dict.get(mo)
        original_parameter_value = original_mo_value.get(key)
        if (original_parameter_value is None) and new_parameter_value is not None:
            tmp_dict["operation"] = "create"
        elif original_parameter_value is not None and new_parameter_value is not None:
            tmp_dict["operation"] = "update"
        elif original_parameter_value is not None and new_parameter_value is None:
            tmp_dict["operation"] = "delete"
            tmp_dict["value"] = "None"
        else:
            tmp_dict["operation"] = "delete"
            tmp_dict["value"] = "None"

        para_list = key.split("/")
        is_first_para_of_list = is_numeric(para_list[-1])

        add_to_list = True
        if tmp_dict["operation"] == "delete" and is_first_para_of_list is True:
            add_to_list = need_add_delete_info_to_list_for_m2m(para=key, para_keys=para_keys)
        if add_to_list is True:
            rtn_list_for_one_mo.append(tmp_dict)
    return rtn_list_for_one_mo
