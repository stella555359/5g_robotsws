import time
import uuid
from taf.hw.fhgw.cli import cli
from pprint import pprint
from robot.libraries.BuiltIn import BuiltIn
import os.path
from common import yaml_file_to_dictionary

try:
    from cStringIO import StringIO
except ImportError:
    try:
        from StringIO import StringIO
    except ImportError:
        from io import StringIO

__all__ = [
    "dummy110",
    "get_unique_id",
    "fast_connect_to_k8s_master",
    "fast_disconnect",
    "fast_disconnect_all",
    "fast_execute",
    "get_vdu_namespace_from_testline",
    "get_k8s_admin_ssh_connection_info",
    "get_vdu_oam_http_connection_info",
    "get_vcu_oam_http_connection_info",
    "get_fhgw_extra_config_yaml_from_testLine",
    "get_fhgw_extra_config_dictionary_from_testLine",
    "get_fhgw_major_version",
    "strip_prompt"
]

issh_cli = cli()


def dummy110():
    print("dummy110")
    return None


def get_unique_id(prefix="", suffix="", precise="HIGH"):
    """This function is used to get unique id, came from robot KW

    *AUTHOR* chris.l.cao@nokia-sbell.com,
    ...    history change: <date>,<who>,<what and how>
    ...   28.11.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    | Input Parameters | Man. | Description |
    | prefix       | no | prefix, default is empty |
    | suffix       | no | suffix, default is empty |
    | precise      | no | precise, HIGH or LOW or FORMAT_DATETIME, default is HIGH |

    *RETURN VALUE*
    unique_id

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
    rtn = ""
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


def strip_prompt(content, remove_last_line=True, remove_first_line=True, return_list=False):
    """
    [Documentation]  Strip Prompt
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
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

    if length >= 1 and remove_first_line is True:
        lines.pop(0)

    length = len(lines)

    if length >= 1 and remove_last_line is True:
        lines.pop(-1)

    if return_list is True:
        return lines

    return "\n".join(lines)


def get_k8s_admin_ssh_connection_info(gnb_index=0, vdu_index=0):
    """
    [Documentation]  Get K8s Admin SSH Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OE server K8s Master SSH Connection Info defined in __init__.py,
    ...           dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'cloudadmin', 'password': 'system123', 'port': 22}
    ...
    ...    Example
    ...    | ${vdu_k8s_master_ssh_connection_info} | Get K8s Admin SSH Connection Info |
    ...    | ${vdu_k8s_master_ssh_connection_info} | Get K8s Admin SSH Connection Info | vdu_index=1 |
    ...
    """
    builtin_obj = BuiltIn()

    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}}".\
        format(gnb_index, vdu_index)
    addr = builtin_obj.get_variable_value(value)
    print(addr)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}}".\
        format(gnb_index, vdu_index)
    username = builtin_obj.get_variable_value(value)
    print(username)

    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}}".\
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


def get_vcu_oam_http_connection_info(gnb_index=0):
    """
    [Documentation]  Get VCU OAM Http Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OAM connection information defined in __init__.py,
    ...    dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'Nemuadmin', 'password': 'nemuuser', 'port': 8081}
    ...
    ...    Example
    ...    | ${vcu_oam_http_connection_info} | Get VCU OAM Http Connection Info |
    ...    | ${vcu_oam_http_connection_info} | Get VCU OAM Http Connection Info | gnb_index=1 |
    ...
    """
    builtin_obj = BuiltIn()
    gnb_index = int(gnb_index)

    value = "${{tl.gnbs[{}].cu.oam_http_connection_details.addr}}".format(gnb_index)
    addr = builtin_obj.get_variable_value(value)

    value = "${{tl.gnbs[{}].cu.oam_http_connection_details.username}}".format(gnb_index)
    username = builtin_obj.get_variable_value(value)

    value = "${{tl.gnbs[{}].cu.oam_http_connection_details.password}}".format(gnb_index)
    password = builtin_obj.get_variable_value(value)

    value = "${{tl.gnbs[{}].cu.oam_http_connection_details.port}}".format(gnb_index)
    port = builtin_obj.get_variable_value(value)

    rtn = {
        "addr": addr,
        "username": username,
        "password": password,
        "port": port,
    }

    return rtn


def get_vdu_oam_http_connection_info(gnb_index=0, vdu_index=0):
    """
    [Documentation]  Get vDU OAM Http Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OAM connection information defined in __init__.py,
    ...           dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'Nemuadmin', 'password': 'nemuuser', 'port': '443'}
    ...
    ...    Example
    ...    | ${vdu_oam_http_connection_info} | Get vDU OAM Http Connection Info |
    ...    | ${vdu_oam_http_connection_info} | Get vDU OAM Http Connection Info | vdu_index=1 |
    ...
    """
    builtin_obj = BuiltIn()

    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)

    value = "${{tl.gnbs[{}].dus[{}].oam_http_connection_details.addr}}".format(gnb_index, vdu_index)
    addr = builtin_obj.get_variable_value(value)

    value = "${{tl.gnbs[{}].dus[{}].oam_http_connection_details.username}}".format(gnb_index, vdu_index)
    username = builtin_obj.get_variable_value(value)

    value = "${{tl.gnbs[{}].dus[{}].oam_http_connection_details.password}}".format(gnb_index, vdu_index)
    password = builtin_obj.get_variable_value(value)

    port = "443"

    rtn = {
        "addr": addr,
        "username": username,
        "password": password,
        "port": port,
    }

    return rtn


def get_fhgw_extra_config_yaml_from_testLine(gnb_index=0, vdu_index=0, fhgw_index=0):
    """
    [Documentation]  Get FHGW Extra Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of FHGW extra configuration
    ...
    ...    Example
    ...    | ${yaml_file}     | Get FHGW Extra Config Yaml From TestLine |
    ...
    """
    builtin_obj = BuiltIn()

    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)
    fhgw_index = int(fhgw_index)

    value = "${{tl.gnbs[{}].cloud_deployment.default_cfg_dir}}".format(gnb_index)
    default_cfg_dir = builtin_obj.get_variable_value(value)
    yaml_file_name = os.path.join(default_cfg_dir, "DEP_SCF_FILES", "CU_{}".format(gnb_index),
                                  "vDU_{}".format(vdu_index), "FHGW_{}".format(fhgw_index),
                                  "fhgw_extra_config.yaml")
    return yaml_file_name


def get_fhgw_extra_config_dictionary_from_testLine(gnb_index=0, vdu_index=0, fhgw_index=0):
    """
    [Documentation]   Get FHGW Extra Config Dictionary From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of fhgw_extra_config_0 . If there is no this file, return {}
    ...
    ...    Example
    ...    | ${conf_dict}     | Get FHGW Extra Config Dictionary From TestLine |
    ...
    """
    yaml_file_name = get_fhgw_extra_config_yaml_from_testLine(gnb_index=gnb_index, vdu_index=vdu_index,
                                                              fhgw_index=fhgw_index)

    dictionary_content = yaml_file_to_dictionary(yaml_file_name)
    pprint(dictionary_content)

    return dictionary_content


def get_fhgw_major_version(gnb_index=0, vdu_index=0, fhgw_index=0):
    """
    [Documentation]   Get FHGW Major Version
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   FHGW Major Version, type is string, e.g, FHGW21A or FHGW21B or FHGW22R1
    ...
    ...    Example
    ...   | ${fhgw_major_version} | Get FHGW Major Version |
    ...
    """
    fhgw_extra_conf_dict = get_fhgw_extra_config_dictionary_from_testLine(
        gnb_index=gnb_index, vdu_index=vdu_index, fhgw_index=fhgw_index)
    fhgw_major_version = fhgw_extra_conf_dict["fhgw_release_branch"]
    print("FHGW major version:{}".format(fhgw_major_version))
    return fhgw_major_version


def fast_connect_to_k8s_master(gnb_index=0, vdu_index=0, alias="default"):
    """
    [Documentation]   Connect To K8s Master Interactively In Python
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   8.12.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
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
    gnb_index = int(gnb_index)
    vdu_index = int(vdu_index)

    vdu_http_info = get_k8s_admin_ssh_connection_info(gnb_index=gnb_index, vdu_index=vdu_index)
    ip = vdu_http_info["addr"]
    username = vdu_http_info["username"]
    password = vdu_http_info["password"]

    print(ip)
    print(username)
    print(password)

    prompt = "\\[core@\\S+\\s\\S+\\]\\$"
    issh_cli.connect_to(
        ip=ip, username=username, password=password, prompt=prompt, width=200, timeout=150, alias=alias)


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


def fast_disconnect_all():
    """
    [Documentation]   fast_disconnect_all
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
    ...    | fast_disconnect_all |
    ...
    ...    | ${alias} | Get Unique Id |
    ...    | fast_connect_to_k8s_master  | alias=${alias} |
    ...    | ${out} | fast_execute  |  command=ls -l | alias=${alias} |
    ...    | fast_disconnect_all | |
    """
    issh_cli.disconnect(alias=None)


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
    value = "${{tl.gnbs[{}].dus[{}].cloud_deployment.cloud_hosting.namespace}}".\
        format(gnb_index, vdu_index)
    ns = builtin_obj.get_variable_value(value)
    return ns


def fast_execute(command="ls -l", with_pipeline_command="", check_result=True, gnb_index=0,
                 vdu_index=0, alias="default", remove_first_line=True, remove_last_line=True):
    """
    [Documentation]   fast_execute
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   8.12.202,chris.l.cao@nokia-sbell.com, initialization version

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
