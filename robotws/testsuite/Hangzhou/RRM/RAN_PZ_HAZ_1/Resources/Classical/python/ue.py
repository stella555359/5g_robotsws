# -*- coding:utf-8 -*-
"""
Description: These KW is related to UE
"""
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh
import re
import json
import logging
import time

ssh = ssh()
"""
This dict maps class names of objects given in tl.ues to their power UE type
"""
__power_ue_translator = {
    'MediaTek': 'mtk',
}


def get_ue_type(ue_info):
    def _translater_brand(ssh_session):
        ssh_process = ssh_session.send_command(
            "adb -s %s shell getprop ro.product.brand" %
            ue_info.serial_number)
        brand_output = ""
        brand = ""
        for i in range(10):
            brand_output += ssh_process.read_output()
            if brand_output:
                break
            time.sleep(1)
        if brand_output:
            brand = ''.join([i if ord(i) < 128 and ord(i) > 31 or ord(i) == 10
                             else '' for i in brand_output]).splitlines()[0].strip()
        return brand

    def _get_ue_type_by_brand(ue_info):
        ue_brand_map = {
            "lge": "lg_v50",
            "HUAWEI": "huawei",
            "qti": "qct_dx50",
            "samsung": "samsung",
            "HONOR": "huawei"
        }
        ssh_session = ssh.connect_to(hostname=ue_info.ssh_connection_details.addr,
                                     username=ue_info.ssh_connection_details.username,
                                     password=ue_info.ssh_connection_details.password, alias="get_brand")
        try:
            brand = _translater_brand(ssh_session)
            logging.info(brand)
        finally:
            ssh_session.disconnect()
        return ue_brand_map[brand]

    ue_type = type(ue_info).__name__
    if ue_type in __power_ue_translator.keys():
        return __power_ue_translator[ue_type]
    # elif ue_type == "dict":
    #     ue_type = get_common_ue_config()['capabilities'][-1]
    if ue_type == "Qualcomm":
        return "qct_dx50"
    elif ue_type == "Android":
        ue_type = _get_ue_type_by_brand(ue_info)
        if ue_type == 'huawei' and ue_info.server_dir.lower().count("sigspark.exe") > 0:
            return "huawei_sigspark"
        else:
            return ue_type
    else:
        return ue_type


def translate_power_ue_type_from_testline(ue_index=0, index=0):
    """
    This keyword will get UE by index, and translate it's type into Power UE's ue_type.

    :param ue_index: Int: the index of target UE in tl.ues
    :return: ue_type for Power UE usage.
    """
    tl = BuiltIn().get_variable_value("${tl}")
    if (int(ue_index) + 1) > len(tl.ues):
        ue_index = 0
        # Assert to be Askey/Inseego/Nokia CPE. use yml instead of
    ue = tl.ues[int(ue_index)]
    _ue_name = ue.__class__.__name__
    ue_type = None
    if _ue_name == "Qualcomm" or _ue_name == "Android":
        ue_type = ue.capabilities[0].lower()
    elif _ue_name == "dict":
        if "AndroidUePool" in ue["UE_POOLS"].keys():
            uename_list = list(
                ue["UE_POOLS"]["AndroidUePool"]["inline_config"].keys())
        else:
            # taf.ue.proxy new yaml
            pool_class = list(ue["UE_POOLS"].keys())[0]
            print(pool_class)
            uename_list = list(ue["UE_POOLS"][pool_class]
                               ["inline_config"].keys())
            ue_type = pool_class.replace("TafUe", "").replace("Pool", "")
        if "askey" in uename_list[index].lower():
            ue_type = "askey"
        elif "nokia_cpe" in uename_list[index].lower():
            ue_type = "nokia_cpe"
        elif "AT" in uename_list[index].upper():
            ue_type = "AT"
        elif "ADB" in uename_list[index].lower():
            ue_type = "ADB"
        elif "SPARK" in uename_list[index].lower():
            ue_type = "Spark"
        else:
            if ue_type is None:
                ue_type = "inseego"
    elif _ue_name in __power_ue_translator:
        ue_type = __power_ue_translator.get(_ue_name)
    else:
        raise Exception(
            "Current UE: {} is not supported Yet.".format(_ue_name))
    return ue_type


def verify_5G_new_attach_available(before, after, expect='PASS'):
    """Verify if 5G attached result in gNB debug log
    :param before: the output for filter 'flow control start' in gNB request HW module before attach.
    :param after: the output for filter 'flow control start' in gNB request HW module when attach finished.
    :param expect: the expection for comparation, if PASS, the new attach request should finished."""

    def _remove_last_empty_in_list(input_list):
        if not input_list[-1]:
            if len(input_list) > 1:
                input_list = input_list[0:-1]
            else:
                input_list = []
        return input_list

    before = _remove_last_empty_in_list(before)
    after = _remove_last_empty_in_list(after)
    if before:
        latest_before = before[-1]
        latest_in_new_index = -1
        for i, attach_info in enumerate(after):
            if attach_info == latest_before:
                latest_in_new_index = i + 1
        if expect != 'PASS':
            if latest_in_new_index == -1:
                return True
        elif latest_in_new_index != -1 and latest_in_new_index < len(after):
            return True
        elif after[-1] != before[-1]:
            return True
    else:
        if after and len(after) >= 1 and expect == "PASS":
            return True
    raise RuntimeError(
        "UE attach result not expected, should be %s but result is not." %
        expect)


def get_common_ue_config(ue_info, index=0):
    """This Keyword can read the android definition that not supported by taf.ue but can supported by ute-ue,
    inspite of the ue defined in testline_configuration_5G __init__ or yml format, combine the ue parameters in
    unique structure but not only e.g. ${tl.ues[<index>].serial_number} but also yml file contents to use the
    android_common_keyword possibility
    :param ue_info: ue_info=${tl.ues[${ue_index}]}
    :param index: list index from tl.ues[], it will use the index UE for traffic"""
    ue_output = {}
    index = int(index)
    if isinstance(ue_info, dict):
        _ues = []
        inline_config = _find_value_by_key(
            'inline_config', json.dumps(
                ue_info, sort_keys=False))
        for k, v in inline_config.items():
            _ues.append(json.dumps(v))
        print(_ues[index])
        ue_output['capabilities'] = _find_value_by_key(
            'CAPABILITIES', _ues[index])
        ue_output['cpc_ip'] = _find_value_by_key(
            'ue_pc_address', _ues[index]) or _find_value_by_key(
            'ue_pc_ip', _ues[index])
        ue_output['cpc_username'] = _find_value_by_key('ue_pc_login', _ues[index]) or \
            _find_value_by_key('login', _ues[index])
        ue_output['cpc_password'] = _find_value_by_key('ue_pc_password', _ues[index]) or \
            _find_value_by_key('password', _ues[index])
        data_transfer = _find_value_by_key('data_transfer', _ues[index])

        if "ssh" not in data_transfer.keys():
            # taf.ue.proxy yaml struct
            ue_output['data_transfer'] = {}
            ue_output['data_transfer']["ssh"] = {}
            ue_output['data_transfer']["ssh"]["host"] = data_transfer["iperf"]["app_server"]["address"]
            ue_output['data_transfer']["ssh"]["user"] = data_transfer["iperf"]["app_server"]["user"]
            ue_output['data_transfer']["ssh"]["password"] = data_transfer["iperf"]["app_server"]["password"]
        else:
            ue_output['data_transfer'] = data_transfer
        ue_output['ue_type'] = "ute"
        ue_output['serial_number'] = _find_value_by_key(
            'serial_number', _ues[index]) or "1234567890"
        _qci = _find_value_by_key('qci', _ues[index])
        ue_output['qci'] = True if _qci and _qci.get(
            '5') and _qci.get('6') else False
    else:
        ue_output['capabilities'] = ue_info.capabilities
        ue_output['cpc_ip'] = ue_info.ssh_connection_details.addr
        ue_output['cpc_username'] = ue_info.ssh_connection_details.username
        ue_output['cpc_password'] = ue_info.ssh_connection_details.password
        ue_output['ue_type'] = "taf"
        ue_output['serial_number'] = ue_info.serial_number
        if hasattr(ue_info, 'data_transfer'):
            print("i use taf.ue.proxy")
            ue_output['iperf_address'] = ue_info.data_transfer[index].app_server.address
            ue_output['iperf_user'] = ue_info.data_transfer[index].app_server.user
            ue_output['iperf_password'] = ue_info.data_transfer[index].app_server.password
            ue_output['iperf_port'] = ue_info.data_transfer[index].app_server.ports
        else:
            print("i use taf.ue.andriod")
            ue_output['iperf_address'] = ue_info.iperf_details.ssh_connection_details.addr
            ue_output['iperf_user'] = ue_info.iperf_details.ssh_connection_details.username
            ue_output['iperf_password'] = ue_info.iperf_details.ssh_connection_details.password
            ue_output['iperf_port'] = ue_info.iperf_details.ssh_connection_details.port

    return ue_output


def get_ava_ue_ip(ue_ifconfig_output):
    """To avoid LG Android9 can't remove the old APN setting, which cause the UE has 2 IPs but only 1 of it available,
    use this keyword to get the available one.
    Note: it only support the UE with inet6 setting if double IP received from core.
    :param ue_ifconfig_output: the output of command 'adb -s SN_OF_UE shell ifconfig'"""

    def _get_available_ip_multi_ip(ip_items):
        for ip_info in ip_items:
            if ip_info.count('inet6 addr') == 0:
                continue
            ue_ip = re.findall(
                r'inet addr:(1[^2, ^9]\d?\.\d{1,3}\.\d{1,3}\.\d{1,3})', ip_info)
            if ue_ip:
                return ue_ip[0]

    ue_info = ''.join([i if ord(i) < 128 and ord(i) > 31 or ord(i) == 10
                       else '' for i in ue_ifconfig_output])
    ue_ip_info = re.sub(r'\[(\?)?\d+\w', '', ue_info)
    ue_ip_list = re.findall(
        r'inet addr:(1[^2, ^9]\d?\.\d{1,3}\.\d{1,3}\.\d{1,3})',
        ue_ip_info)
    if len(ue_ip_list) == 1:
        return ue_ip_list[0]
    if len(ue_ip_list) == 0:
        raise Exception("No available UE IP found")
    ip_start_10 = 0
    ip_start_10_ip = []
    for ue_ip in ue_ip_list:
        if ue_ip.startswith('10.'):
            ip_start_10 += 1
            ip_start_10_ip.append(ue_ip)
    if ip_start_10 == 1:
        return ip_start_10_ip[0]
    return _get_available_ip_multi_ip(ue_ip_info.split('UNSPEC'))


def _find_value_by_key(ue_key, json_repr):
    def _decode_dict(a_dict):
        try:
            results[ue_key] = a_dict[ue_key]
        except KeyError:
            pass
        return a_dict

    results = dict()
    json.loads(json_repr, object_hook=_decode_dict)
    return results.get(ue_key)
