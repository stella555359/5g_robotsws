from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword
from taf.ul.vdu.helm import helm
import os
import os.path
import uuid
import time
import copy
import re
from taf.hw.fhgw.cli import cli
import json
from robot.api import logger

issh_cli = cli()


def get_cell_global_l2rt_mapping_dict(cell_to_l2rt_mapping):
    new_dict = {}
    for pod in cell_to_l2rt_mapping:
        for global_cell_id in cell_to_l2rt_mapping[pod]:
            new_dict[global_cell_id] = pod
    logger.console(new_dict)
    return new_dict


def get_vdu_pods_info(pod_name='all', namespace='', fail_on_error=False, conn=None):
    """
    *Args:*
        - pod_name: the pod name that containers existed (mandatory)
        - namespace: the tenant namespace which pod created in
        - fail_on_error: see `Failing on command execution errors`

    *Command:* ``kubectl get pods <pod_name> -n <namespace>``

    *Returns:*
        - each container status as a dict

    *Example:*
    | ${container_status} | get_containers_status | vdu-pod-0 | cran1
    """
    if namespace != '' and 'all' not in namespace:
        namespace = '-n ' + namespace
    elif 'all' in namespace:
        namespace = '--all-namespaces'
    if pod_name == 'all':
        command = 'kubectl get pods ' + namespace + ' -o wide'
    else:
        command = 'kubectl get pods ' + pod_name + ' ' + namespace + ' -o wide'
    output = helm().execute_command_on_master_cluster(command, fail_on_error, conn=conn).stdout
    return parse_output_with_ps_format_to_dict(output)


def fast_execute(command="ls -l", with_pipeline_command="", check_result=True, gnb_index=0,
                 vdu_index=0, alias="default", remove_first_line=True, remove_last_line=True):
    """
    [Documentation]   fast_execute
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   8.12.2022,chris.l.cao@nokia-sbell.com, initialization version

    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | command    |  no  | command, e.,g ls -l|
    ...    | with_pipeline_command | no | with_pipeline_command, e.g '|wc -l' |
    ...    | check_result | no  | check_result, if true will check linux execution result, if false will not check |
    ...    |   |    | default is True |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...    | remove_first_line  |  no  | remove_first_line, default is true |
    ...    | remove_last_line  |  no  | remove_last_line, default is true |
    ...
    ...    *RETURN VALUE*
    ...    Command execution result.
    ...
    ...    Example
    ...    | fast_connect_to_k8s_master |
    ...    | ${out} | fast_execute  | command=ls -l |
    ...    | fast_disconnect |
    ...
    ...    | ${alias} | Get Unique Id |
    ...    | fast_connect_to_k8s_master  | alias=${alias} |
    ...    | ${out} | fast_execute  |  command=ls -l | alias=${alias} |
    ...    | fast_disconnect | alias=${alias} |
    """
    ns = get_vdu_namespace_from_testline(gnb_index=gnb_index, vdu_index=vdu_index)
    new_command = "{} -n {} {}".format(command, ns, with_pipeline_command)
    out = issh_cli.execute(command=new_command, alias=alias, check_result=check_result)
    out = strip_prompt(out, remove_first_line=remove_first_line, remove_last_line=remove_last_line)

    return out


def parse_name_convention_from_json_cnf_release_values(cnf_release_values, namespace, name_type):
    assert name_type in ['pod_prefix', 'container_prefix'], 'name_type must be one of pod_prefix or container_prefix'
    cnf_release_values_dict = json.loads(cnf_release_values)
    name_prefix_list = cnf_release_values_dict['global']['name_convention'][name_type]
    name_prefix_tmp = '-'.join(name_prefix_list)
    name_prefix = name_prefix_tmp.replace('_NAMESPACE_', namespace)
    return name_prefix + '-'


def get_k8s_tenant_ssh_connection_info(gnb_index=0, vdu_index=0):
    """
    Get K8s Tenant SSH Connection Info
    *Author*: lingting.sun@nokia-sbell.com

    *History Change*:
    | date | who | what and how |
    | 06.05.2022 |lingting.sun@nokia-sbell.com | initial created |

    *Argument Description*
    | Input Parameters | Man. | Description |
    | gnb_index | no | gnb_index, default is 0 |
    | vdu_index | no | vdu_index, default is 0 |

    *RETURN VALUE*
    Dictionary of OE server K8s Master Tenant SSH Connection Info defined in __init__.py,
           dictionary keys are addr, username, password and port.
    example: {'addr': '1.1.1.1', 'username': 'cranuser1', 'password': 'system123', 'port': 22}

    *Example*
    | ${vdu_k8s_master_ssh_connection_info} | Get K8s Tenant SSH Connection Info |
    | ${vdu_k8s_master_ssh_connection_info} | Get K8s Tenant SSH Connection Info | vdu_index=1 |

    """
    builtin_obj = BuiltIn()

    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}}". \
        format(gnb_index, vdu_index)
    addr = builtin_obj.get_variable_value(value)
    print(addr)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}}". \
        format(gnb_index, vdu_index)
    username = builtin_obj.get_variable_value(value)
    print(username)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}}". \
        format(gnb_index, vdu_index)
    password = builtin_obj.get_variable_value(value)
    print(password)

    port = "22"

    rtn = {
        "addr": addr,
        "username": username,
        "password": password,
        "port": port,
    }

    return rtn


def fast_connect_to_k8s_master(gnb_index=0, vdu_index=0, alias="default"):
    """
     Connect To K8s Master Interactively In Python
     *AUTHOR* chris.l.cao@nokia-sbell.com
     *History Change*:
     | date | who | what and how |
     | 8.12.2021 | chris.l.cao@nokia-sbell.com | initialization version |
     *Argument Description*
     |  Input Parameters | Man. | Description |
     | gnb_index  |  no  | gnb index, default is 0 |
     | vdu_index  |  no  | VDU index, default is 0 |
     | alias      | no   | alias, default value is default |
     *RETURN VALUE*
     None.
     *Example*
    | fast_connect_to_k8s_master |
    | ${out} | fast_execute  | command=ls -l |
    | fast_disconnect |
    | ${alias} | Get Unique Id |
    | fast_connect_to_k8s_master  | alias=${alias} |
    | ${out} | fast_execute  |  command=ls -l | alias=${alias} |
    | fast_disconnect | alias=${alias} |
    """
    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)

    vdu_http_info = get_k8s_tenant_ssh_connection_info(gnb_index=gnb_index, vdu_index=vdu_index)
    ip = vdu_http_info["addr"]
    username = vdu_http_info["username"]
    password = vdu_http_info["password"]

    print(ip)
    print(username)
    print(password)

    prompt = "\\[core@\\S+\\s\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$"
    issh_cli.connect_to(
        ip=ip, username=username, password=password, prompt=prompt, width=200, timeout=150, alias=alias)


def generate_delta_parameters_for_multiple_mo(updated_para_value_dict, origin_para_value_dict):
    """
    [Documentation]   Generate Delta Parameters For Multiple MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.12.8  chris.l.cao@nokia-sbell.com, when original parameter does not exist, it will be added.
    ...                                          when new value is ${None}, it will be removed.
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | updated_paras_dict     | yes | the names of parameters list |
    ...   | origin_para_value_dict | No | if it's ${EMPTY}, it means we are restoring the parameters value |
    ...
    ...   *RETURN VALUE*
    ...  dictionray of MO, which can be used by 'VDU Online Change Parameters By Delta Plan REST'
    """
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
    """
    [Documentation]   _Generate Delta Parameters For One MO For Changing Value
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.12.11  chris.l.cao@nokia-sbell.com, support add, replace, remove operation
    ...  2023.12.25 ,chris.l.cao@nokia-sbell.com, support list like
    ...                                           <list name="acceptedClockClass"><p>6</p><p>7</p></list>
    ...
    ...   | Input Parameters      | Man. | Description |
    ...   | mo_dn                 | yes | distName where the parameter to be updated |
    ...   | mo_value              | yes | point to new value dictionary |
    ...   | origin_para_value_dict | yes | point to original value dictionary |
    """
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


def is_numeric(value):
    """
    [Documentation]  return True if it's numeric, otherwise return False
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.12.22  chris.l.cao@nokia-sbell.com, initialization
    """
    try:
        float(value)
        return True
    except ValueError:
        return False


def get_cu_namespace_from_testline(gnb_index=0):
    """
    [Documentation]    get cu namespace from testline
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...  history change:
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  27.11.2021,chris.l.cao@nokia-sbell.com, add support to VCU NCIR
    ...  28.1.2022,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...   *RETURN VALUE*
    ...   namespace for CNF, tenant name for VNF
    ...
    """
    gnb_index = int(gnb_index)

    builtin_obj = BuiltIn()
    cnf = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.namespace}}".format(gnb_index)
    vnf = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.control_nodes[0].default_ssh_connection_details.username}}". \
        format(gnb_index)
    ns = builtin_obj.get_variable_value(cnf)
    if ns is None:
        print("It's VNF.")
        ns = builtin_obj.get_variable_value(vnf)
    return ns


def get_vdu_namespace_from_testline(gnb_index=0, vdu_index=0):
    """
    [Documentation]  get vdu namespace from testline in init.py file
    ...  return the value correct get from TL
    ...  author: jianlin.zhang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu index | Yes. | the vdu index config on TL |
    ...    *RETURN VALUE*
    ...    namespace
    ...
    ...   Example
    ...  | ${ns} |  Get VDU Namespace From TestLine |
    """
    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)

    builtin_obj = BuiltIn()
    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.namespace}}". \
        format(gnb_index, vdu_index)
    ns = builtin_obj.get_variable_value(value)
    return ns


def strip_prompt(content, remove_last_line=True, remove_first_line=True, return_list=False):
    """
    [Documentation]  Strip Prompt
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...   26.12.2023,lingting.sun@nokia-sbell.com, adaption for different CU OCP version
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | content          | yes | content |
    ...	   | remove_last_line | no | remove_last_line, default is True, type is bool |
    ...	   | remove_first_line | no | remove_first_line, default is True, type is bool |
    ...	   | return_list      | no | return_list, default is False, type is bool |
    ...
    ...    *RETURN VALUE*
    ...    string or list
    ...
    ...    Example
    ...    | ${my_content} | Strip Prompt | aaaaa\nbbbb\nccccc |
    ...
    """
    lines = [i.strip() for i in content.split('\n')]
    length = len(lines)
    if length >= 1 and remove_last_line:
        lines.pop(-1)

    if length > 2 and remove_first_line:
        lines.pop(0)

    if return_list is True:
        return lines
    return "\n".join(lines)


def get_a_directory(*path):
    """
    Create a directory and return absolute path.

    *AUTHOR* fen.huang@nokia-sbell.com

    *History Change*
    | date | who | what and how |
    | 13.07.2020 | chris.l.cao@nokia-sbell.com | Raise exception if failed to generate a folder name. |

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

        if log_path is None:
            builtin_obj.log("log_path is None, setting default path: /home/ute/logs", "INFO")
            log_path = "/home/ute/logs"

        builtin_obj.log("Generated log path: " + log_path, "INFO")

        if not path:
            builtin_obj.log("Path is empty, setting default path", "INFO")
            path = ["/home/ute/logs"]

        abs_path = os.path.join(log_path, *path)
        builtin_obj.log("Absolute path: " + abs_path, "INFO")

        if not os.path.exists(abs_path):
            os.makedirs(abs_path)
        rtn = abs_path
    except Exception as e:
        builtin_obj.log(str(e), "ERROR")

    if not rtn:
        raise RuntimeError("get_a_directory(): failed!!")

    return rtn


def generate_log_path(BuiltIn_obj):
    """Generate case log path(will not create the log folder).
     *AUTHOR* fen.huang@nokia-sbell.com
     """
    output_dir = BuiltIn_obj.get_variable_value("${OUTPUT_DIR}")
    print("output_dir:{}".format(output_dir))

    builtin_obj = BuiltIn()  # delete
    test_name = BuiltIn_obj.get_variable_value("${TEST_NAME}")
    builtin_obj.log("test_name: " + test_name)  # delete
    timestamp = BuiltIn_obj.get_variable_value("${START_TIME}")
    builtin_obj.log("timestamp: " + timestamp)  # delete

    if test_name:
        log_path_without_suite_name = os.path.join("TESTCASE__" + str(test_name), timestamp)
    else:
        log_path_without_suite_name = os.path.join(timestamp)

    log_path_without_suite_name = log_path_without_suite_name.replace(" ", "_").replace(":", "_").replace("-", "_")
    log_path = os.path.join(output_dir, log_path_without_suite_name)
    return log_path


def get_a_file(*path):
    """get a file name with absolute path

    *AUTHOR* fen.huang@nokia-sbell.com
        history change, <date>,<who>,<what and how>
        -13.07.2020,chris.l.cao@nokia-sbell.com,
                   Raise exception if failed to generate a file name.
    | Input Parameters  | Man. | Description |
    | path            | Yes  |   list type, e.g, ["folder1", "fold2", "filename.txt"] |


    *RETURN VALUE*
    string

    Example:
    | ${file_name}  | get_a_file | folder1 | folder2 | filename.txt |
    """
    builtin_obj = BuiltIn()
    rtn = ""
    try:
        log_path = generate_log_path(builtin_obj)
        file_abs_path = os.path.join(log_path, os.path.sep.join(path))
        builtin_obj.log(file_abs_path, "INFO")
        file_dir, file_name = os.path.split(file_abs_path)
        if not os.path.exists(file_dir):
            os.makedirs(file_dir)
        if not os.path.exists(file_abs_path):
            os.system("touch %s" % file_abs_path)
        rtn = file_abs_path
    except Exception as e:
        builtin_obj.log(e, "ERROR")
    if len(rtn) == 0:
        raise RuntimeError("get_a_file(): fail!!")
    return rtn


def get_unique_id(prefix="", suffix="", precise="HIGH"):
    """This function is used to get unique id, came from robot KW

    *AUTHOR* chris.l.cao@nokia-sbell.com,

    *History Change*:
    | date | who | what and how |
    | 2021-11-28 | chris.l.cao@nokia-sbell.com | convert robot KW to python KW |
    | 2022-3-31 | r3li | update documentation |

    *Parameter Description*
    | Input Parameters | Man. | Description |
    | prefix       | no | prefix, default is empty |
    | suffix       | no | suffix, default is empty |
    | precise      | no | precise, HIGH or LOW or FORMAT_DATETIME or HIGH_WITH_FORMAT_DATETIME_EPOCH, default is HIGH |

    precise clear: If precise is HIGH, will return a random string, which including string and number;
    If precise is LOW, will return a random string, which only including number;
    If precise is FORMAT_DATETIME, will return time string;
    If precise is HIGH_WITH_FORMAT_DATETIME_EPOCH, will return a string including random char and time sting.

    *RETURN VALUE*
    - unique_id

    Example:
    | ${tmp_id} | Get Unique ID |
    | ${tmp_id} | Get Unique ID | prefix=myprefix |
    | ${tmp_id} | Get Unique ID | prefix=myprefix | precise=HIGH |
    | ${tmp_id} | Get Unique ID | precise=HIGH |
    | ${tmp_id} | Get Unique ID | precise=LOW |
    | ${tmp_id} | Get Unique ID | precise=FORMAT_DATETIME |
   | ${tmp_id} | Get Unique ID | precise=HIGH_WITH_FORMAT_DATETIME_EPOCH |
    """
    precise = precise.upper()
    if precise == "HIGH":
        rtn = _get_Unique_id_high_precise(prefix, suffix)
    elif (precise == "LOW"):
        rtn = _get_Unique_id_low_precise(prefix, suffix)
    elif (precise == "FORMAT_DATETIME"):
        rtn = _get_Unique_id_datetime_precise(prefix, suffix)
    elif (precise == "HIGH_WITH_FORMAT_DATETIME_EPOCH"):
        rtn = _get_Unique_id_datetime_precise_epoch(prefix, suffix)
    else:
        raise RuntimeError("Unknown precise:{}!!".format(precise))
    return rtn


def _get_Unique_id_high_precise(prefix="", suffix=""):
    rtn = str(uuid.uuid4())
    rtn = rtn.replace('-', '')
    rtn = "{}{}{}".format(prefix, rtn, suffix)
    return rtn


def _get_Unique_id_low_precise(prefix="", suffix=""):
    rtn = str(time.time())
    rtn = rtn.replace('.', '')
    rtn = "{}{}{}".format(prefix, rtn, suffix)
    return rtn


def _get_Unique_id_datetime_precise(prefix="", suffix=""):
    unique_id_part1 = time.strftime("%Y%m%d_%H%M%S", time.localtime())

    unique_id_part2 = str(time.time())
    unique_id_part2 = unique_id_part2.split(".")[-1]

    unique_id = "{}_{}".format(unique_id_part1, unique_id_part2)
    rtn = "{}{}{}".format(prefix, unique_id, suffix)
    return rtn


def _get_Unique_id_datetime_precise_epoch(prefix="", suffix=""):
    unique_id_part1 = str(uuid.uuid4())
    unique_id_part1 = unique_id_part1.replace('-', '')

    unique_id_part2 = time.strftime("%Y%m%d_%H%M%S", time.localtime())

    unique_id = "{}_{}".format(unique_id_part1, unique_id_part2)

    rtn = "{}{}{}".format(prefix, unique_id, suffix)
    return rtn


def parse_output_with_ps_format_to_dict(output):
    pods_info = {}
    keys = []
    if 'No resources found' in output:
        raise Exception('No pods found in the current environment')
    for line in output.splitlines():
        if not keys:
            if line.strip().startswith('NAME'):
                line = re.sub(r'(\S+) (\S+)', r"\g<1>_\g<2>", line).strip()
                keys.extend([key.lower().replace(" ", "_") for key in line.split()])
                continue
        items = line.split()
        if len(items) != len(keys):
            restarts_index = keys.index('restarts')
            if items[restarts_index] != 0:
                for i in len(keys), len(items):
                    items.pop(restarts_index + 1)
            if len(items) != len(keys):
                raise Exception('No pods found in the current environment')
        pod_info = {}
        for i, key in enumerate(keys):
            pod_info[key] = items[i]
        if pod_info:
            pods_info[pod_info['name']] = pod_info
    return pods_info


def get_app_server_info(ue_index=0):
    """
    [Documentation]      Get App Server Info
    ...  author:  chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index  |  no | ue_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    app server information, e.g, {'address': '10.108.229.222', 'user': 'ute', 'password': 'ute'}
    ...
    ...    Example
    ...    | ${app_server_info} | Get App Server Info |
    ...    | ${app_server_info} | Get App Server Info | ue_index=1 |
    """

    builtin_obj = BuiltIn()
    ue_index = int(ue_index)

    pattern = "${{tl.ues[{}]}}".format(ue_index)
    ue_info = builtin_obj.get_variable_value(pattern)

    rtn = {}
    if ue_info.__class__.__name__ == "TafUeAndroid":
        app_server = ue_info.data_transfer[0].app_server
        address = app_server.address
        user = app_server.user
        password = app_server.password
        rtn = {
            "address": address,
            "user": user,
            "password": password,
        }

    return rtn


def _get_ue_info_methods_dict(self):
    methods_dict = {'IMSI': self.ueman.get_imsi, 'IMEI': self.ueman.get_imei,
                    'ANDROID_VER': self.ueman.get_android_version,
                    'UE_OS_VER': self.ueman.get_android_version,
                    'DEVICE_MODEL': self.ueman.get_device_model, 'LAC': self.ueman.get_lac,
                    'MCC': self.ueman.get_mcc,
                    'MNC': self.ueman.get_mnc, 'PCI': self.ueman.get_pci, 'CELL_ID': self.get_cell_id,
                    'ENB_ID': self.get_enb_id,
                    'IP': self.get_ip,
                    'SIGNAL_STRENGTH': self.get_signal_strength,
                    'MOBILE_APP_VERSION': self.ueman.get_mobile_app_version}
    return methods_dict


def get_ue_info(self, info, timeout=None):
    """

        :param info:
        :param timeout: string/int/float in seconds
        :return:
        """
    methods_dict = self._get_ue_info_methods_dict()
    if info not in methods_dict:
        raise ValueError(
            "unsupported info type %s, supported are: %s" % (info, ", ".join(list(methods_dict.keys()))))

    info_output = self._invoke_with_timeout_if_need(info, methods_dict, timeout)
    self.logger.info(info_output, extra={'ue_id': self.sn_number})
    return info_output


def get_app_server_info(ue_index=0):
    """
    [Documentation]      Get App Server Info
    ...  author:  chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index  |  no | ue_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    app server information, e.g, {'address': '10.108.229.222', 'user': 'ute', 'password': 'ute'}
    ...
    ...    Example
    ...    | ${app_server_info} | Get App Server Info |
    ...    | ${app_server_info} | Get App Server Info | ue_index=1 |
    """

    builtin_obj = BuiltIn()
    ue_index = int(ue_index)

    pattern = "${{tl.ues[{}]}}".format(ue_index)
    ue_info = builtin_obj.get_variable_value(pattern)

    rtn = {}
    if ue_info.__class__.__name__ == "TafUeAndroid":
        app_server = ue_info.data_transfer[0].app_server
        address = app_server.address
        user = app_server.user
        password = app_server.password
        rtn = {
            "address": address,
            "user": user,
            "password": password,
        }

    return rtn


def get_unique_id(prefix="", suffix="", precise="HIGH"):
    """This function is used to get unique id, came from robot KW

    *AUTHOR* chris.l.cao@nokia-sbell.com,

    *History Change*:
    | date | who | what and how |
    | 2021-11-28 | chris.l.cao@nokia-sbell.com | convert robot KW to python KW |
    | 2022-3-31 | r3li | update documentation |

    *Parameter Description*
    | Input Parameters | Man. | Description |
    | prefix       | no | prefix, default is empty |
    | suffix       | no | suffix, default is empty |
    | precise      | no | precise, HIGH or LOW or FORMAT_DATETIME or HIGH_WITH_FORMAT_DATETIME_EPOCH, default is HIGH |

    precise clear: If precise is HIGH, will return a random string, which including string and number;
    If precise is LOW, will return a random string, which only including number;
    If precise is FORMAT_DATETIME, will return time string;
    If precise is HIGH_WITH_FORMAT_DATETIME_EPOCH, will return a string including random char and time sting.

    *RETURN VALUE*
    - unique_id

    Example:
    | ${tmp_id} | Get Unique ID |
    | ${tmp_id} | Get Unique ID | prefix=myprefix |
    | ${tmp_id} | Get Unique ID | prefix=myprefix | precise=HIGH |
    | ${tmp_id} | Get Unique ID | precise=HIGH |
    | ${tmp_id} | Get Unique ID | precise=LOW |
    | ${tmp_id} | Get Unique ID | precise=FORMAT_DATETIME |
   | ${tmp_id} | Get Unique ID | precise=HIGH_WITH_FORMAT_DATETIME_EPOCH |
    """
    precise = precise.upper()
    if precise == "HIGH":
        rtn = _get_Unique_id_high_precise(prefix, suffix)
    elif (precise == "LOW"):
        rtn = _get_Unique_id_low_precise(prefix, suffix)
    elif (precise == "FORMAT_DATETIME"):
        rtn = _get_Unique_id_datetime_precise(prefix, suffix)
    elif (precise == "HIGH_WITH_FORMAT_DATETIME_EPOCH"):
        rtn = _get_Unique_id_datetime_precise_epoch(prefix, suffix)
    else:
        raise RuntimeError("Unknown precise:{}!!".format(precise))
    return rtn


def continue_on_failure(exceptions=Exception, console=False):
    """
    Decorator for catching errors and reporting them without breaking the execution flow.
    !!! Warning !!!: decoration alternates return value by adding failure indicator
    :param exceptions: (tuple) Exception classes to look for. If decorated function throws an exception that is not a
                               descendant of any of provided exceptions, it will not be caught and thus it will be
                               propagated further. Defaults to 'Exception' meaning that pretty much every error is
                               covered. This might be undesirable as it makes debugging slightly more difficult.
    :param console: (bool)  Should be printed also to console if running in robot
    :return:  (ret_val, boolean)   Tuple containing whatever decorated function returned and boolean indicating
                                   method executed without errors
    """

    def wrapper(method):
        def try_catch_block(*args, **kwargs):
            method_id = "{}({}, {})".format(method.__name__, args, kwargs)
            try:
                return method(*args, **kwargs), True
            except KeyboardInterrupt:
                raise
            except exceptions as e:
                logger.info("Method: {} - Result: {}".format(method_id, e), also_to_console=console)
                for line in traceback.format_exc().splitlines():
                    logger.info(line, also_to_console=console)
            return None, False

        return try_catch_block

    return wrapper


class SingletonInterface:
    _singleton = None

    def __new__(cls, *args, **kwargs):
        if cls._singleton is None:
            cls._singleton = super().__new__(cls, *args, **kwargs)
        return cls._singleton

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def _is_instance_locked(self):
        try:
            assert self._instance_locked
            return True
        except (AttributeError, AssertionError):
            self._instance_locked = True
            return False


class TeardownInterface(SingletonInterface):
    teardown_wrapper = continue_on_failure


class CollectorsInterface(TeardownInterface):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._collectors = LogCollectorFacade()
        self._verification_logs = []
        self._test_logs = []

    def setup_collectors(self, collector_names):
        for name in collector_names:
            self._collectors.add_collector(name)
        self._collectors.setup_log_collectors(collectors=collector_names)
        self.schedule_test_teardown_function("Teardown collectors", self.teardown_collectors, (collector_names,))

    def setup_log_collectors(self, collectors=None):
        collectors = self._filter_collectors(collectors)
        for name, collector in collectors.items():
            logger.info(f"Setting up {name} collector...")
            collector.setup()
            logger.info(f"{name} collector set up!")

    def start_collectors(self, collector_names):
        self._collectors.start_log_collecting(collectors=collector_names)
        self.schedule_suite_teardown_function("Stop collectors", self.stop_collectors, (collector_names,))

    def stop_collectors(self, collector_names):
        self._collectors.stop_log_collecting(collectors=collector_names)


def get_nrcellid_list_from_l2_log(log_path):
    """This keyword is used to get nrcell list from l2rt log
    *AUTHOR* lingting.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  log path | Yes |  l2rt log local path  |

    *RETURN VALUE*
    nrcellid_list

    Example
    |  get_nrcellid_list_from_l2_log    |  ${log_dir}l2rt.log    |
    """
    with open(log_path, 'r') as f:
        content = f.read()
    nrcellid_list = re.findall(r'nrCellId\s+\d+', content)
    nrcellid_list = set(nrcellid_list)
    nrcellid_list_clean = []
    for nrcellid_info in nrcellid_list:
        nrcellid = re.findall(r'\d+', nrcellid_info)
        nrcellid_list_clean.append(nrcellid[0])
    return nrcellid_list_clean


def get_dl_tput_from_l2_log(log_path, cell_id=None):
    """This keyword is used to get dl t-put from l2rt log
    *AUTHOR* lingting.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  log path | Yes |  l2rt log local path  |
    |  cell_id  | No  |  global cell id, default is None |

    *RETURN VALUE*
    dl t-put

    Example
    |  get_dl_tput_from_l2_log     |  ${log_dir}l2rt.log    |
    """
    tb_list = list()
    with open(log_path, 'r') as f:
        lines = f.readlines()
        if cell_id is not None:
            for line in lines:
                if "DataPdu" in line and cell_id in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'\|DataPdu:\s*\d+\|', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("dl tb_size is {}".format(tb_list))
        if cell_id is None:
            for line in lines:
                if "DataPdu" in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'\|DataPdu:\s*\d+\|', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("dl tb_size is {}".format(tb_list))
        if tb_list:
            dl_tput = float(sum(tb_list)) / len(tb_list) * 8 / 1024 / 1024
        else:
            dl_tput = 0
    return dl_tput


def get_vcu_k8s_admin_ssh_connection_info(gnb_index=0):
    """
    [Documentation]  Get VCU K8s Admin SSH Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OE server K8s Master SSH Connection Info defined in __init__.py,
    ...                    dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'cbis-admin', 'password': 'systeM!23', 'port': 22}
      ...
    ...    Example
    ...    | ${vcu_k8s_master_ssh_connection_info} | Get VCU K8s Admin SSH Connection Info |
    ...    | ${vcu_k8s_master_ssh_connection_info} | Get VCU K8s Admin SSH Connection Info | gnb_index=1 |
    ...
    """
    builtin_obj = BuiltIn()

    gnb_index = int(gnb_index)

    value = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}}".\
        format(gnb_index)
    addr = builtin_obj.get_variable_value(value)
    print("vcu ssh addr:{}".format(addr))

    value = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}}".\
        format(gnb_index)
    username = builtin_obj.get_variable_value(value)
    print("vcu ssh username:{}".format(username))

    value = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}}".\
        format(gnb_index)
    password = builtin_obj.get_variable_value(value)
    print("vcu ssh password:{}".format(password))

    value = "${{tl.gnbs[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}}".\
        format(gnb_index)
    port = builtin_obj.get_variable_value(value)
    print("vcu ssh port:{}".format(port))

    rtn = {
        "addr": addr,
        "username": username,
        "password": password,
        "port": port,
    }

    return rtn


def get_ul_tput_from_l2_log(log_path, cell_id=None):
    """This keyword is used to get ul t-put from l2rt log
    *AUTHOR* lingting.sun@nokia-sbell.com
    | Input Parameters | Man. | Description |
    |  log path | Yes |  l2rt log local path  |
    |  cell_id  | No  |  global cell id, default is None |

    *RETURN VALUE*
    ul t-put

    Example
    |  get_ul_tput_from_l2_log     |  ${log_dir}l2rt.log    |
    """
    tb_list = list()
    with open(log_path, 'r') as f:
        lines = f.readlines()
        if cell_id is not None:
            for line in lines:
                if "UlCounterUpdate" in line and cell_id in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'/UL:\s*\d+\s*Bytes received', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("ul tb_size is {}".format(tb_list))
        if cell_id is None:
            for line in lines:
                if "UlCounterUpdate" in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'/UL:\s*\d+\s*Bytes received', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("ul tb_size is {}".format(tb_list))
        if tb_list:
            ul_tput = float(sum(tb_list))/len(tb_list)*8/1024/1024
        else:
            ul_tput = 0
    return ul_tput


def fast_disconnect(alias="default"):
    """
    [Documentation]   fast_disconnect
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   8.12.2021,chris.l.cao@nokia-sbell.com, initialization version

    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | alias      | no   | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | fast_connect_to_k8s_master |
    ...    | ${out} | fast_execute  | command=ls -l |
    ...    | fast_disconnect |
    ...
    ...    | ${alias} | Get Unique Id |
    ...    | fast_connect_to_k8s_master  | alias=${alias} |
    ...    | ${out} | fast_execute  |  command=ls -l | alias=${alias} |
    ...    | fast_disconnect | alias=${alias} |
    """
    issh_cli.disconnect(alias=alias)
