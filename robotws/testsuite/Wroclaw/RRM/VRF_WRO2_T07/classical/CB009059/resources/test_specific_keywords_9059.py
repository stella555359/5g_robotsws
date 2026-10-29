import subprocess
import re
import logging
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections import connect_to_uepc, connect_to_appserver, disconnect
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import log_finder
from taf.transport.ssh import ssh
from taf.sbts.oam.coam.admin import admin
from time import sleep
from robot.libraries.BuiltIn import BuiltIn
from ast import literal_eval
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.CB007564.resources.test_specific_keywords_7564 import atten

_ssh = ssh()


@logged_keyword
def activate_feature_9059(bts_id, switcher='switch_Off', atten_value=35,
                          cell_1_attenuator_ports=tl.gnbs[0].dus[0].rus[1].attenuation_ports,
                          cell_2_attenuator_ports=tl.gnbs[0].dus[0].rus[2].attenuation_ports,
                          cell_4_attenuator_ports=tl.gnbs[0].dus[0].rus[3].attenuation_ports,
                          cell_5_attenuator_ports=tl.gnbs[0].dus[0].rus[4].attenuation_ports
                          ):
    atten.initialise_attenuator()
    blog(cell_1_attenuator_ports, "ports cell 1")
    blog(cell_2_attenuator_ports, "ports cell 2")
    blog(cell_4_attenuator_ports, "ports cell 4")
    blog(cell_5_attenuator_ports, "ports cell 5")
    atten.set_attenuation(value_string=atten_value, ports=cell_1_attenuator_ports)
    atten.set_attenuation(value_string=atten_value, ports=cell_2_attenuator_ports)
    atten.set_attenuation(value_string=atten_value, ports=cell_4_attenuator_ports)
    atten.set_attenuation(value_string=atten_value, ports=cell_5_attenuator_ports)
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object, 'actDrbProfileForCellAggrLevel', ['FR1_SA'])
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'qRxLevMin', '-22')
    if switcher == 'Cell4':
        ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                              'qRxLevMin', '-22')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                              'qRxLevMin', '-60')
    if switcher == 'switch_Off':
        ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                              'qRxLevMin', '-22')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                              'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-5',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-6',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-7',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-8',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-9',
                          'qRxLevMin', '-22')

    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Preconditions for qrxlevmin and drb profile fulfilled-------------------------")


@logged_keyword
def QRXLEVMIN_REVERT():
    bts_id = BuiltIn().get_variable_value("${MRBTS_5G_ID}")
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-5',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-6',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-7',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-8',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-9',
                          'qRxLevMin', '-60')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Preconditions for qrxlevmin and drb profile fulfilled-------------------------")


@logged_keyword
def set_act_buffer_based_scell_addition(param_value):
    bts_id = BuiltIn().get_variable_value("${MRBTS_5G_ID}")
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object, 'actBufferBasedSCellAddition', param_value)
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)


@logged_keyword
def setup_cell_aggr_level_9059(bts_id, drbs_dict):
    ds = DeltaStore()
    ds.initialise_delta_store()
    for drb, value in drbs_dict.items():
        ds.add_param_to_delta(f'MRBTS-{bts_id}/NRBTS-{bts_id}/{drb}', 'cellAggrLevel', [value])
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)


@logged_keyword
def setup_rlc_mode_9059(bts_id, drbs_dict):
    ds = DeltaStore()
    ds.initialise_delta_store()
    for drb, value in drbs_dict.items():
        ds.add_param_to_delta(f'MRBTS-{bts_id}/NRBTS-{bts_id}/{drb}', 'rlcMode', value)
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)


@logged_keyword
def update_custom_data_in_pcf(imsi, key, value):
    put_command = [
        'curl', '-k',
        '-X', 'PUT', 'http://10.78.62.141:80/services/ServiceManager/subscriber/updateCustomData/Device',
        '-H', 'accept: application/json',
        '-H', 'Authorization: Basic c21hZG1pbjpTcHMhc20w',
        '-H', 'Content-Type: application/json',
        '-d', f'{{"identities": [{{"identityType": "IMSI", "value": "{imsi}"}}], "id": "{imsi}",'
              f' "customData": {{"entry": [{{"key": "{key}", "value": {{"type": "STRING", "value": "{value}"}}}}]}}}}'
    ]
    try:
        result = subprocess.run(put_command, stdout=subprocess.PIPE, text=True)
        assert result.returncode == 0
        blog("PCF updated successfully.")
        blog(result.stdout)
    except AssertionError as e:
        e.args = (f'Command failed with return code: {result.returncode}\n'
                  f'STDERR: {result.stderr}',)
        raise e


@logged_keyword
def get_device_data_from_pcf(imsi):
    get_command = [
        'curl', '-k',
        '-X', 'GET', f'http://10.78.62.141:80/services/ServiceManager/subscriber/getData/Device'
                     f'?processParams=%7B%22identities%22%3A%20%5B%7B%22identityType%22%3A%20%22IMSI'
                     f'%22%2C%20%22value%22%3A%20%22{imsi}%22%7D%5D%7D',
        '-H', 'accept: application/json',
        '-H', 'Authorization: Basic c21hZG1pbjpTcHMhc20w'
    ]
    try:
        result = subprocess.run(get_command, stdout=subprocess.PIPE, text=True)
        assert result.returncode == 0
        blog("Data fetched successfully.")
        return result.stdout
    except AssertionError as e:
        e.args = (f'Command failed with return code: {result.returncode}\n'
                  f'STDERR: {result.stderr}',)
        raise e


@logged_keyword
def nullify_all_custom_data_in_pcf():
    imsi = BuiltIn().get_variable_value("${IMSI}")
    raw_device_data_str = get_device_data_from_pcf(imsi)
    type_mapping = {'null': 'None', 'true': 'True', 'false': 'False'}

    for json_type, python_type in type_mapping.items():
        raw_device_data_str = raw_device_data_str.replace(json_type, python_type)

    device_data_list = literal_eval(raw_device_data_str)

    if device_data_list[0]['customData']['entry']:
        for custom_data in device_data_list[0]['customData']['entry']:
            update_custom_data_in_pcf(imsi, custom_data['key'], None)


@logged_keyword
def fetch_ue_ip(adb_hash):
    ue_pc_conn = connect_to_uepc()
    cmd = f'adb -s {adb_hash} shell "ifconfig"'
    try:
        output = _ssh.execute(command=cmd, connection=ue_pc_conn)
        ip_pattern = r'rmnet_data0.*?inet6 addr: ([\w:]+)/\d+'
        ip_address = re.search(ip_pattern, output, re.DOTALL)
        disconnect(ue_pc_conn)
        return ip_address.group(1)
    except Exception as e:
        disconnect(ue_pc_conn)
        e.args = (f'Fetching UE IP address failed. Check connection to UEPC and UE status.',)
        raise e


@logged_keyword
def trigger_iperf_tput_on_app_server(ue_ip, time=300, traffic="50M"):
    app_srv_conn = connect_to_appserver()
    cmd = f'iperf -V -u -i 1 -t {time} -p 8021 -l 1300 -b {traffic} -m -c {ue_ip}' \
          f' & iperf -V -u -i 1 -t {time} -p 5008 -l 1300 -b {traffic} -m -c {ue_ip}' \
          f' & iperf -V -u -i 1 -t {time} -p 5007 -l 1300 -b {traffic} -m -c {ue_ip}'
    try:
        blog(f"Wait for {time}s for call finish.")
        _ssh.execute(command=cmd, connection=app_srv_conn)
        sleep(5)
        disconnect(app_srv_conn)
    except Exception as e:
        disconnect(app_srv_conn)
        e.args = (f'Starting tput failed. Check connection to appserver and UE status.',)
        raise e


@logged_keyword
def update_5qi_usage_count(rf_dict, qi):
    rf_dict[qi] = rf_dict[qi] + 1


@logged_keyword
def check_if_bts_counter_is_greater_than_specific_value(list_of_values, counter, compare_value):
    try:
        assert int(list_of_values[-1]) > compare_value or int(list_of_values[-2]) > compare_value
    except AssertionError as e:
        e.args = (f'Counter {counter} = {list_of_values[-1]}. Should be > {compare_value}.',)
        raise e


@logged_keyword
def check_if_bts_counter_is_equal_to_specific_value(list_of_values, counter, compare_value):
    try:
        assert int(list_of_values[-1]) == compare_value or int(list_of_values[-2]) == compare_value
    except AssertionError as e:
        e.args = (f'Counter {counter} = {list_of_values[-1]}. Should be == {compare_value}.',)
        raise e


@logged_keyword
def check_if_cell_counter_is_greater_than_specific_value(list_of_values, counter, cell, compare_value):
    try:
        assert int(list_of_values[-1]) > compare_value or int(list_of_values[-2]) > compare_value
    except AssertionError as e:
        e.args = (f'Counter {counter} for NRCELL-{cell} = {list_of_values[-1]}. Should be > {compare_value}.',)
        raise e


@logged_keyword
def check_if_cell_counter_is_equal_to_specific_value(list_of_values, counter, cell, compare_value):
    try:
        assert int(list_of_values[-1]) == compare_value or int(list_of_values[-2]) == compare_value
    except AssertionError as e:
        e.args = (f'Counter {counter} for NRCELL-{cell} = {list_of_values[-1]}. Should be == {compare_value}.',)
        raise e


@logged_keyword
def check_if_counters_are_greater_than_specific_value(counters_to_check, bts_counters, path_mapping, compare_value):
    blog('Check if counters are greater than specific value')
    for counter in counters_to_check:
        if counter in bts_counters:
            values_dict = path_mapping[counter]
            list_of_values = list(values_dict.values())
            check_if_bts_counter_is_greater_than_specific_value(list_of_values, counter, compare_value)
        else:
            values_dict = path_mapping[counter]
            counter, cell = counter.split('_')
            list_of_values = list(values_dict.values())
            check_if_cell_counter_is_greater_than_specific_value(list_of_values, counter, cell, compare_value)
    return 'Counters values are correct.'


@logged_keyword
def check_if_counters_are_equal_to_specific_value(counters_to_check, bts_counters, path_mapping, compare_value):
    blog('Check if counters are equal to specific value')
    for counter in counters_to_check:
        if counter in bts_counters:
            values_dict = path_mapping[counter]
            list_of_values = list(values_dict.values())
            check_if_bts_counter_is_equal_to_specific_value(list_of_values, counter, compare_value)
        else:
            values_dict = path_mapping[counter]
            counter, cell = counter.split('_')
            list_of_values = list(values_dict.values())
            check_if_cell_counter_is_equal_to_specific_value(list_of_values, counter, cell, compare_value)
    return 'Counters values are correct.'


# @logged_keyword
# def verify_counters(counter_values_dict, counters_to_check, bts_id, pcell_id, scell_id, operation, compare_value=0):
#     bts_counters = BuiltIn().get_variable_value("${BTS_COUNTERS}")
#     path_mapping = {
#         f'M55326C02006': counter_values_dict['BTS'].get('BTS', {'BTS': {}}).get(
#             f'NRBTS-{bts_id}', {f'NRBTS-{bts_id}': {}}).get('MCC-310_MNC-260', {'MCC-310_MNC-260': {}}).get(
#             'NRASU', {'NRASU': {}}).get('M55326C02006'),
#         f'M55326C02007': counter_values_dict['BTS'].get('BTS', {'BTS': {}}).get(
#             f'NRBTS-{bts_id}', {f'NRBTS-{bts_id}': {}}).get('MCC-310_MNC-260', {'MCC-310_MNC-260': {}}).get(
#             'NRASU', {'NRASU': {}}).get('M55326C02007'),
#         f'M55326C02008': counter_values_dict['BTS'].get('BTS', {'BTS': {}}).get(
#             f'NRBTS-{bts_id}', {f'NRBTS-{bts_id}': {}}).get('MCC-310_MNC-260', {'MCC-310_MNC-260': {}}).get(
#             'NRASU', {'NRASU': {}}).get('M55326C02008'),
#         f'M55326C02009': counter_values_dict['BTS'].get('BTS', {'BTS': {}}).get(
#             f'NRBTS-{bts_id}', {f'NRBTS-{bts_id}': {}}).get('MCC-310_MNC-260', {'MCC-310_MNC-260': {}}).get(
#             'NRASU', {'NRASU': {}}).get('M55326C02009'),
#         f'M55308C26001_{pcell_id}': counter_values_dict['BTS'].get('CELLS', {'CELLS': {}}).get(
#             f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NCELA', {'NCELA': {}}).get('M55308C26001'),
#         f'M55308C26001_{scell_id}': counter_values_dict['BTS'].get('CELLS', {'CELLS': {}}).get(
#             f'NRCELL-{scell_id}', {f'NRCELL-{scell_id}': {}}).get('NCELA', {'NCELA': {}}).get('M55308C26001'),
#         f'M55118C00036_{pcell_id}': counter_values_dict['BTS'].get('CELLS', {'CELLS': {}}).get(
#             f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NCAC', {'NCAC': {}}).get('M55118C00036'),
#         f'M55118C00037_{pcell_id}': counter_values_dict['BTS'].get('CELLS', {'CELLS': {}}).get(
#             f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NCAC', {'NCAC': {}}).get('M55118C00037'),
#         f'M55125C00039_{pcell_id}': counter_values_dict['BTS'].get('CELLS', {'CELLS': {}}).get(
#             f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NNGCC', {'NNGCC': {}}).get('M55125C00039'),
#         f'M55125C00040_{pcell_id}': counter_values_dict['BTS'].get('CELLS', {'CELLS': {}}).get(
#             f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NNGCC', {'NNGCC': {}}).get('M55125C00040')
#     }
#     operation_mapping = {'gt': check_if_counters_are_greater_than_specific_value,
#                          'eq': check_if_counters_are_equal_to_specific_value}
#     check_counters_func = operation_mapping[operation]
#     blog(check_counters_func(counters_to_check, bts_counters, path_mapping, compare_value))


@logged_keyword
def verify_counters(counter_values_dict, counters_to_check, bts_id, pcell_id, scell_id, operation, compare_value=0):
    bts_counters = BuiltIn().get_variable_value("${BTS_COUNTERS}")
    path_mapping = {
        f'M55326C02006': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            'MCC-310', {'MCC-310': {}}).get('MNC-260', {'MNC-260': {}}).get('NRASU', {'NRASU': {}}).get('M55326C02006'),
        f'M55326C02007': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            'MCC-310', {'MCC-310': {}}).get('MNC-260', {'MNC-260': {}}).get('NRASU', {'NRASU': {}}).get('M55326C02007'),
        f'M55326C02008': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            'MCC-310', {'MCC-310': {}}).get('MNC-260', {'MNC-260': {}}).get('NRASU', {'NRASU': {}}).get('M55326C02008'),
        f'M55326C02009': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            'MCC-310', {'MCC-310': {}}).get('MNC-260', {'MNC-260': {}}).get('NRASU', {'NRASU': {}}).get('M55326C02009'),
        f'M55308C26001_{pcell_id}': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NCELA', {'NCELA': {}}).get('M55308C26001'),
        f'M55308C26001_{scell_id}': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            f'NRCELL-{scell_id}', {f'NRCELL-{scell_id}': {}}).get('NCELA', {'NCELA': {}}).get('M55308C26001'),
        f'M55118C00036_{pcell_id}': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NCAC', {'NCAC': {}}).get('M55118C00036'),
        f'M55118C00037_{pcell_id}': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NCAC', {'NCAC': {}}).get('M55118C00037'),
        f'M55125C00039_{pcell_id}': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NNGCC', {'NNGCC': {}}).get('M55125C00039'),
        f'M55125C00040_{pcell_id}': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NNGCC', {'NNGCC': {}}).get('M55125C00040'),
        f'M55118C07004_{pcell_id}': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NCAC', {'NCAC': {}}).get('M55118C07004'),
        f'M55118C07003_{pcell_id}': counter_values_dict['BTS'][f'MRBTS-{bts_id}'][f'NRBTS-{bts_id}'].get(
            f'NRCELL-{pcell_id}', {f'NRCELL-{pcell_id}': {}}).get('NCAC', {'NCAC': {}}).get('M55118C07003')

    }
    operation_mapping = {'gt': check_if_counters_are_greater_than_specific_value,
                         'eq': check_if_counters_are_equal_to_specific_value}
    check_counters_func = operation_mapping[operation]
    blog(check_counters_func(counters_to_check, bts_counters, path_mapping, compare_value))


@logged_keyword
def check_req_scell_id(pcap_file, bts_scell_id, bts_scell_id2):
    frames = log_finder(pcap_file, 'f1ap', 'UEContextModificationRequest', 'SCell-ToBeSetupMod-Item')
    req_scell_ids = []

    for frame in frames:
        frame_text = str(frame)

        scell_items = re.findall(r'sCell.*?nRCellIdentity.*?decimal value (\d+)', frame_text)

        for scell_item in scell_items:
            req_scell_ids.append(scell_item)

    try:
        assert bts_scell_id in req_scell_ids or bts_scell_id2 in req_scell_ids
    except AssertionError as e:
        e.args = ('Wrong Scell ID:', bts_scell_id, bts_scell_id2, 'Scell present in pcap',
                  (list(req_scell_ids)))
        raise e


@logged_keyword
def check_res_scell_id(pcap_file, bts_phycell_id, bts_phycell_id2):
    frames = log_finder(pcap_file, 'f1ap', 'UEContextModificationResponse', 'sCellConfigCommon')
    req_phycell_ids = []
    for frame in frames:
        frame_text = str(frame)

        scell_items = re.findall(r'physCellId.*?(\d+)', frame_text)

        for scell_item in scell_items:
            req_phycell_ids.append(scell_item)

    req_phycell_ids = list((set(req_phycell_ids)))
    try:
        assert (bts_phycell_id in req_phycell_ids) and (bts_phycell_id2 in req_phycell_ids)
    except AssertionError as e:
        e.args = ('Wrong Phycell ID:', bts_phycell_id, bts_phycell_id2, 'PhycellID present in pcap',
                  (list(req_phycell_ids)))
        raise e


@logged_keyword
def check_qos_flow_identifier(pcap_file, qos_val='6'):
    frames = log_finder(pcap_file, 'ngap', 'PDUSessionResourceModifyRequest')
    qos_flow_identifier = frames[0].find('qosFlowIdentifier')[0]['val']
    try:
        assert qos_flow_identifier == qos_val
    except AssertionError as e:
        e.args = (f'Wrong qosFlowIdentifier value: {qos_flow_identifier} != {qos_val}',)
        raise e

    frames = log_finder(pcap_file, 'ngap', 'PDUSessionResourceModifyResponse')
    qos_flow_identifier = frames[0].find('qosFlowIdentifier')[0]['val']
    try:
        assert qos_flow_identifier == qos_val
    except AssertionError as e:
        e.args = (f'Wrong qosFlowIdentifier value: {qos_flow_identifier} != {qos_val}',)
        raise e


@logged_keyword
def check_nsetapx_report(pcap_file, bts_scell_id):
    frames = log_finder(pcap_file, 'nsetapx', 'DuSCellReleaseItem')
    du_scell_release_item = frames[0].find('DuSCellReleaseItem')[0]['val'].find('cellIdentity')[0]['val']
    scell_decimal_id = re.search(r'decimal value (\d+)', du_scell_release_item).group(1)
    try:
        assert scell_decimal_id == bts_scell_id
    except AssertionError as e:
        e.args = (f'Wrong scell_decimal_id value: {scell_decimal_id} != {bts_scell_id}',)
        raise e


@logged_keyword
def stop_webem_ip_capturing():
    ip_capture_alias = BuiltIn().get_variable_value("${IP_CAPTURE_ALIAS}")
    try:
        admin().stop_ip_capture_file(connection=ip_capture_alias)
    except Exception as e:
        logging.info(f"There is no active WebEm IP capturing. - {e}")
