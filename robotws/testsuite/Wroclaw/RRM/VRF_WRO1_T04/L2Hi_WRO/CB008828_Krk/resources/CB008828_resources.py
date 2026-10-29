"""
:copyright: Nokia Networks
:authors:
    Michal Gorski, michal.gorski@nokia.com
    Jakub Grela, jakub.grela@nokia.com
    Magdalena Hebda, magdalena.hebda@nokia.com
    Kamil Krawiec, kamil.krawiec@nokia.com
    Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
    Aleksandra Wilczynska, aleksandra.wilczynska@nokia.com
:maintainers:
    Michal Gorski, michal.gorski@nokia.com
    Jakub Grela, jakub.grela@nokia.com
    Magdalena Hebda, magdalena.hebda@nokia.com
    Kamil Krawiec, kamil.krawiec@nokia.com
    Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
    Aleksandra Wilczynska, aleksandra.wilczynska@nokia.com
"""

from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources_kr.python.csv_verifiers import csv_verifiers
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources_kr.python.common_keywords import CounterManager
from ta_messaging.message_flows import get_flow
from robot.api import logger
from ta5g_pm_counters import ta5g_pm_counters
from statistics import mean
from copy import deepcopy
import variables
import json
import os

csv_tti_trace = csv_verifiers()
pm_counters = ta5g_pm_counters()
counter_report = CounterManager()


def verify_dlslicedata_and_dldrbweight_in_tti_traces(csv_path, expected_tti, cell_id, ues, deployment='SA'):
    """
    Verify that average values of dlSliceData and dlDrbWeight events in tti traces are in expected range
    :param csv_path: (str) file path to collected tti traces in csv format
    :param expected_tti: (str) expected tti traces values stored in variables.py
    :param cell_id: (str) cell ID
    :param ues: (dict) c-rnti and ue_id in dict format e.g. {c-rnti: ue} {34653: 1, 45323:2}
    :param deployment: (str) deployment: SA or NSA
    :return:
    """
    collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_path)
    expected_tti = variables.TTI_TRACES[expected_tti]

    validate_events_in_tti_traces(collected_tti, expected_tti, cell_id, ues, deployment)


def validate_events_in_tti_traces(collected_tti, expected_tti, cell_id, ues, deployment):
    """
    Function that validates values in tti traces
    :param collected_tti: (list) collected tti traces
    :param expected_tti: (dict) expected tti traces values stored in variables.py
    :param cell_id: (str) cell ID
    :param ues: (dict) c-rnti and ue_id in dict format
    :param deployment: (str) deployment: SA or NSA
    """
    tti_for_cell = csv_tti_trace.filter_csv_by_column_value(csv_list=collected_tti, column_name='physCellId',
                                                            condition='==', value=cell_id)
    results = []
    if 'dlDrbWeightData' in expected_tti:
        for rnti, ue in ues.items():
            tti_for_rnti = csv_tti_trace.filter_csv_by_column_value(csv_list=tti_for_cell, column_name='rnti',
                                                                    condition='==', value=rnti)
            for tti_event in list(expected_tti['dlDrbWeightData'][ue].keys()):
                result = _check_dl_drb_weight_data_for_cell(tti_for_rnti, expected_tti, tti_event, cell_id, ue)
                results.append(result)
    if 'dlSliceData' in expected_tti:
        tti_for_rnti = csv_tti_trace.filter_csv_by_column_multiple_values(csv_list=tti_for_cell, column_name='rnti',
                                                                          condition='in', values=[0, 65535])
        for tti_event in list(expected_tti['dlSliceData'].keys()):
            result = _check_dl_slice_data_for_cell(tti_for_rnti, expected_tti, tti_event, cell_id, deployment)
            results.append(result)

    assert all(results), 'Verification finished with status: failed. Check log.html errors'


def _get_rrm_available_prbs_for_sas(tti_for_rnti, expected_tti):
    """
    Function that gets dlSliceData.rrmAvailablePrbsForSas value from tti traces
    :param tti_for_rnti: (list) collected tti traces
    :param expected_tti: (dict) expected tti traces values stored in variables.py
    :return: collected_values (list) rrmAvailablePrbsForSas values
    """
    num_of_prb = csv_tti_trace.get_column_values(input_list=tti_for_rnti, column_name='dlPagingOrSibSchedData.numOfPrb')
    prb_sas = csv_tti_trace.get_column_values(input_list=tti_for_rnti, column_name='dlSliceData.rrmAvailablePrbsForSas')
    collected_values = []
    for index, value in enumerate(prb_sas):
        if value == '':
            continue
        elif float(value) != expected_tti["dlSliceData"]['dlSliceData.rrmAvailablePrbsForSas']:
            assert (float(value) + float(num_of_prb[index+1]) ==
                    expected_tti["dlSliceData"]['dlSliceData.rrmAvailablePrbsForSas']), \
                (f'Sum: numOfPrb + rrmAvailablePrbsForSas should be '
                 f'{expected_tti["dlSliceData"]["dlSliceData.rrmAvailablePrbsForSas"]}')
        else:
            collected_values.append(float(value))
    return collected_values


def _check_dl_slice_data_for_cell(tti_for_rnti, expected_tti, tti_event, cell_id, deployment):
    """
    Function that validates dlSliceData event matches expected value
    :param tti_for_rnti: (dict) collected tti traces for rnti
    :param expected_tti: (dict) expected tti traces values stored in variables.py
    :param tti_event: (str) tti event name
    :param cell_id: (str) cell ID
    :param deployment: (str) deployment: SA or NSA
    """
    if deployment == 'SA' and tti_event == 'dlSliceData.rrmAvailablePrbsForSas':
        collected_values = _get_rrm_available_prbs_for_sas(tti_for_rnti, expected_tti)
    else:
        collected_values = csv_tti_trace.filter_csv_by_column_value(csv_list=tti_for_rnti, column_name='rnti',
                                                                    condition='==', value='0')
        collected_values = csv_tti_trace.get_column_values(input_list=collected_values, column_name=tti_event)
        collected_values = list(map(float, [value for value in collected_values if value not in [' ', '']]))
    average_value = mean(collected_values)
    if isinstance(expected_tti['dlSliceData'][tti_event], (int, float)):
        if float(average_value) != expected_tti['dlSliceData'][tti_event]:
            logger.error(f'TTI event: {tti_event:<60} cell:{cell_id} verification failed.   Average: '
                         f'{round(average_value, 4)} != {expected_tti["dlSliceData"][tti_event]} '
                         f'Min: {min(collected_values)}, Max: {max(collected_values)}'
                         f'Range: {abs(max(collected_values))-abs(min(collected_values))}')
            return False
    elif isinstance(expected_tti['dlSliceData'][tti_event], list):
        if not (expected_tti['dlSliceData'][tti_event][0] <= float(average_value) <=
                expected_tti['dlSliceData'][tti_event][1]):
            logger.error(f'TTI event: {tti_event:<60} cell:{cell_id} verification failed.   Average: '
                         f'{round(average_value, 4)} is not in range as expected '
                         f'{expected_tti["dlSliceData"][tti_event]} '
                         f'Min: {min(collected_values)}, Max: {max(collected_values)} '
                         f'Range: {abs(max(collected_values))-abs(min(collected_values))}')
            return False
    else:
        logger.error(f'TTI event: {tti_event:<60} cell:{cell_id} cant be verified. '
                     f'Check expected value type variables.py')
        return False
    logger.info(f'TTI event: {tti_event:<60} cell:{cell_id} verified successfully. '
                f'Average: {round(average_value, 4)}. Expected {expected_tti["dlSliceData"][tti_event]} '
                f'Min: {min(collected_values)}, Max: {max(collected_values)} '
                f'Range: {abs(max(collected_values))-abs(min(collected_values))}')
    return True


def _check_dl_drb_weight_data_for_cell(tti_for_rnti, expected_tti, tti_event, cell_id, ue):
    """
    Function that validates dlDrbWeightData event matches expected value
    :param tti_for_rnti: (dict) collected tti traces
    :param expected_tti: (dict) expected tti traces values stored in variables.py
    :param cell_id: (str) cell ID
    :param ue : (str) UE ID
    """
    collected_values = csv_tti_trace.get_column_values(input_list=tti_for_rnti, column_name=tti_event)
    collected_values = list(map(float, [value for value in collected_values if value not in [' ', '']]))
    average_value = mean(collected_values)
    if isinstance(expected_tti['dlDrbWeightData'][ue][tti_event], (int, float)):
        if float(average_value) != expected_tti['dlDrbWeightData'][ue][tti_event]:
            logger.error(f'TTI event: {tti_event:<60} UE:{ue} cell:{cell_id} verification failed. '
                         f'Average: {round(average_value, 4)} != '
                         f'{expected_tti["dlDrbWeightData"][ue][tti_event]} '
                         f'Min: {min(collected_values)}, Max: {max(collected_values)} '
                         f'Range: {abs(max(collected_values))-abs(min(collected_values))}')
            return False
    elif isinstance(expected_tti['dlDrbWeightData'][ue][tti_event], list):
        if not (expected_tti['dlDrbWeightData'][ue][tti_event][0] <= float(average_value) <=
                expected_tti['dlDrbWeightData'][ue][tti_event][1]):
            logger.error(f'TTI event: {tti_event:<60} UE:{ue} cell:{cell_id} verification failed.   Average: '
                         f'{round(average_value, 4)} is not in range as expected '
                         f'{expected_tti["dlDrbWeightData"][ue][tti_event]} Min: {min(collected_values)}, Max: '
                         f'{max(collected_values)} Range: {abs(max(collected_values))-abs(min(collected_values))}')
            return False
    else:
        logger.error(f'TTI event: {tti_event:<60} UE:{ue} cell:{cell_id} cant be verified. '
                     f'Check expected value type in variables.py')
        return False
    logger.info(f'TTI event: {tti_event:<60} UE:{ue} cell:{cell_id} verified successfully. Average: '
                f'{round(average_value, 4)}. Expected: {expected_tti["dlDrbWeightData"][ue][tti_event]} '
                f'Min: {min(collected_values)}, Max: {max(collected_values)} '
                f'Range: {abs(max(collected_values))-abs(min(collected_values))}')
    return True


def get_from_message(flow_alias, message_alias, field):
    """
    Gets specific field value from message of specific flow
    :param flow_alias:
    :param message_alias:
    :param field:
    :return:
    """
    msg = get_flow(flow_alias).get_message(message_alias)
    field_values = msg.get_all_values_by_key(field)
    if len(field_values) > 1:
        if field != 'eventId':
            return field_values[0]
        field_value_list = list()
        for field_value in field_values:
            field_value_list.append(field_value.keys()[0])
        return field_value_list
    else:
        return field_values[0]


def convert_syscom_events_from_pcap_to_json(events, input_file):
    """
    Function that converts syscomdumps log events from pcap to json. Each event converted in separate json file.
    :param events: (str) names of the events in syscomdumps logs e.g. itf_l2_ps_user_bearersetupreq
    :param input_file: (str) pcap filepath
    :return: json_paths (list) list of paths to json files
    """
    events = events.split(',')
    json_paths = []
    for event in events:
        cmd = (f'tshark -r {input_file} -2 -R "{event}" -T json > {os.path.dirname(input_file)}/{event}.json '
               f'2>> {os.path.dirname(input_file)}/syscomdump_errors.txt')
        os.system(cmd)
        file_path = f'{os.path.dirname(input_file)}/{event}.json'
        if os.path.exists(file_path):
            json_paths.append(file_path)

    return json_paths


def verify_that_ues_are_in_correct_resource_group(input_file, expected_rg, ues):
    """
    Function that verifies in json syscomdump logs that UEs are in correct resource group
    :param input_file: (str) pcap filepath
    :param expected_rg: (dict) expected resource group for ues in variables.py
    :param ues: (dict) c-rnti: ue_id: e.g. ues={40834: '1', 7146: '2'}
    """
    expected_rg_for_ues = variables.EXPECTED_RESOURCE_GROUPS[expected_rg]
    if 'SA' in expected_rg_for_ues.keys():
        json_path = convert_syscom_events_from_pcap_to_json('itf_l2_ps_user_bearersetupreq', input_file)
        collected_rg_for_sa_ues = _get_resource_group_for_sa_ues(json_path, ues, expected_rg_for_ues['SA'])
        _validate_resource_group_for_ues(expected_rg_for_ues['SA'], collected_rg_for_sa_ues)
    if 'NSA' in expected_rg_for_ues.keys():
        json_paths = convert_syscom_events_from_pcap_to_json(
            'itf_l2_ps_user_usersetupreq,itf_l2_ps_user_usersetupresp', input_file)
        collected_rg_for_nsa_ues = _get_resource_group_for_nsa_ues(json_paths, ues, expected_rg_for_ues['NSA'])
        _validate_resource_group_for_ues(expected_rg_for_ues['NSA'], collected_rg_for_nsa_ues)


def _get_resource_group_for_sa_ues(json_path, ues, expected_rg_for_ues):
    """
    Function that gets Resource Group ID for SA UEs
    :return: rg_for_sa_ues (dict) {logical_channel: {ue: {'resource_group': 0}}}
    """
    itf_l2_ps_user_bearersetupreq = json_path[0]
    rg_for_sa_ues = _create_dict_ues_rg(expected_rg_for_ues)
    logger.info(f'Prepared dict: {rg_for_sa_ues}')
    with open(itf_l2_ps_user_bearersetupreq, 'r', encoding='utf-8') as file:
        data = json.load(file)
        for msg in range(len(data)):
            rnti = json.dumps(data[msg]['_source']['layers']['icom_5g']['psuser']['itf_l2_ps_user_bearersetupreq']
                              ['itf_l2_ps_user_bearersetupreq_t']['3gpp.rnti'])
            if json.loads(rnti) not in ues.keys():
                continue
            resource_group = json.dumps(data[msg]['_source']['layers']['icom_5g']['psuser']
                                        ['itf_l2_ps_user_bearersetupreq']['itf_l2_ps_user_bearersetupreq_t']
                                        ['drbAddReqPs (DynamicVariableSizedArray)']['itf_l2_ps_drbaddreqps']
                                        ["dlResourceGroupId (StaticOptional)"]
                                        ["itf_l2_ps_DrbAddReqPs.dlResourceGroupId_item"])
            logical_channel = json.dumps(data[msg]['_source']['layers']['icom_5g']['psuser']
                                         ['itf_l2_ps_user_bearersetupreq']['itf_l2_ps_user_bearersetupreq_t']
                                         ['drbAddReqPs (DynamicVariableSizedArray)']['itf_l2_ps_drbaddreqps']
                                         ['itf_l2_ps_DrbAddReqPs.logicalChannelIdentity'])
            rg_for_sa_ues[json.loads(logical_channel)][ues[json.loads(rnti)]].update(
                {'resource_group': json.loads(resource_group)})
        logger.info(f'Resource Groups for SA UEs: {rg_for_sa_ues}')

        return rg_for_sa_ues


def _get_resource_group_for_nsa_ues(json_paths, ues, expected_rg_for_ues):
    """
    Function that gets Resource Group ID for NSA UEs
    :return: rg_for_nsa_ues (dict) {logical_channel: {ue: {'resource_group': 0}}}
    """
    itf_user_setup_req, itf_user_setup_resp = json_paths
    rg_for_nsa_ues = _create_dict_ues_rg(expected_rg_for_ues)
    logger.info(f'Prepared dict: {rg_for_nsa_ues}')
    ue_id_du_rnti = _get_ueiddu_rnti_from_setup_resp(itf_user_setup_resp, ues)
    with open(itf_user_setup_req, 'r', encoding='utf-8') as file:
        data = json.load(file)
        for msg in range(len(data)):
            if json.dumps(data[msg]['_source']['layers']['icom_5g']['psuser']['itf_l2_ps_user_usersetupreq']
                          ['itf_l2_ps_user_usersetupreq_t']['itf_l2_ps_user_UserSetupReq_t.ueAddCause']) == '"10"':
                ueiddu = json.dumps(data[msg]['_source']['layers']['icom_5g']['psuser']['itf_l2_ps_user_usersetupreq']
                                    ['itf_l2_ps_user_usersetupreq_t']['itf_l2_ps_user_UserSetupReq_t.ueIdDu'])
                resource_group = json.dumps(data[msg]['_source']['layers']['icom_5g']['psuser']
                                            ['itf_l2_ps_user_usersetupreq']['itf_l2_ps_user_usersetupreq_t']
                                            ['drbAddReqPs (DynamicVariableSizedArray)']['itf_l2_ps_drbaddreqps']
                                            ['dlResourceGroupId (StaticOptional)']
                                            ['itf_l2_ps_DrbAddReqPs.dlResourceGroupId_item'])
                logical_channel = json.dumps(data[msg]['_source']['layers']['icom_5g']['psuser']
                                             ['itf_l2_ps_user_usersetupreq']['itf_l2_ps_user_usersetupreq_t']
                                             ['drbAddReqPs (DynamicVariableSizedArray)']['itf_l2_ps_drbaddreqps']
                                             ['itf_l2_ps_DrbAddReqPs.logicalChannelIdentity'])

                rg_for_nsa_ues[json.loads(logical_channel)][ue_id_du_rnti[json.loads(ueiddu)]['ue']].update(
                    {'resource_group': json.loads(resource_group)})
    logger.info(f'Resource Groups for NSA UEs: {rg_for_nsa_ues}')

    return rg_for_nsa_ues


def _get_ueiddu_rnti_from_setup_resp(itf_user_setup_resp, ues):
    """
    Get from itf_l2_ps_user_usersetupresp ueIDdu and rnti
    :return: ueiddu_rnti (dict) {ueIdDu: {'ue': ue_id, 'rnti': rnti}}
    """
    with open(itf_user_setup_resp, 'r', encoding='utf-8') as file:
        data = json.load(file)
    ueiddu_rnti = {}
    for msg in range(len(data)):
        rnti = json.dumps(data[msg]['_source']['layers']['icom_5g']['psuser']["itf_l2_ps_user_usersetupresp"]
                          ["itf_l2_ps_user_usersetupresp_t"]["3gpp.rnti"])
        if json.loads(rnti) not in ues.keys():
            continue
        ueiddu = json.dumps(data[msg]['_source']['layers']['icom_5g']['psuser']["itf_l2_ps_user_usersetupresp"]
                            ["itf_l2_ps_user_usersetupresp_t"]["itf_l2_ps_user_UserSetupResp_t.ueIdDu"])
        ueiddu_rnti[json.loads(ueiddu)] = {'ue': ues[json.loads(rnti)], 'rnti': json.loads(rnti)}

    return ueiddu_rnti


def _create_dict_ues_rg(expected_rg_for_ues):
    rg_for_sa_ues = deepcopy(expected_rg_for_ues['logicalChannelIdentity'])
    for logical_channel in rg_for_sa_ues.values():
        for ue in logical_channel.values():
            ue.update({'resource_group': 0})
    return rg_for_sa_ues


def _validate_resource_group_for_ues(expected_rg_for_ues, collected_rg_for_ues):
    logger.info("Resource Group verification for UEs")
    results = []
    for logical_channel, ues in expected_rg_for_ues['logicalChannelIdentity'].items():
        for ue, rg in ues.items():
            if rg['resource_group'] == collected_rg_for_ues[logical_channel][ue]['resource_group']:
                logger.info(f'UE:{ue} Bearer:{int(logical_channel)-3} is in expected resource group: '
                            f'{collected_rg_for_ues[logical_channel][ue]["resource_group"]}')
                results.append(True)
            else:
                logger.error(f'UE:{ue} Bearer:{int(logical_channel)-3} is in resource group: '
                             f'{collected_rg_for_ues[logical_channel][ue]["resource_group"]} '
                             f'not as expected: {rg["resource_group"]}')
                results.append(False)

    assert all(results), 'Verification finished with status: failed. Check log.html errors'


def get_counters_values(counters, localmoid, filepath, rg_id=1):
    """
    :return: counter_values (dict) {counter_name : value}
    """
    counter_values = {}
    list_of_counters = [x for x in counters.split(',')]
    for counter in list_of_counters:
        counter_value = pm_counters.get_pm_counter_value(counter, localmoid, filepath)
        counter_values[counter] = counter_value[rg_id - 1]
    logger.info(f'Collected pm counters: {counter_values}')

    return counter_values


def verify_counters(test_name, nrcell_id):
    """
    Function that verifies counters values
    :param test_name: (str) test case name
    :param nrcell_id: (str) nrcell_id
    """
    pm_counters_file = counter_report.wait_for_next_pm_interval_and_get_counters()
    counters_dict = {"C-a-1": {1: ["390000000-420000000", "5-6"], 2: ["390000000-430000000", "5-6"],
                               3: ["390000000-420000000", "5-6"], 4: ["380000000-420000000", "5-6"]},
                     "C-a-2": {1: ["930000000-980000000", "52-54"], 2: ["600000000-640000000", "34-36"],
                               3: ["290000000-320000000", "18-20"]},
                     "C-a-3": {1: ["1500000000-1800000000", "22-24"], 2: ["1500000000-1800000000", "22-24"],
                               3: ["630000000-690000000", "8-10"]},
                     "C-a-4": {1: ["860000000-930000000", "40-46"], 2: ["420000000-460000000", "20-26"],
                               3: ["680000000-820000000", "45-51"]}
                     }
    counters_to_verify = counters_dict[test_name]
    for rg, counters_value_range in counters_to_verify.items():
        counters_value_1 = get_counters_values(counters="M55910C00001",
                                               localmoid="PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-" + nrcell_id,
                                               filepath=pm_counters_file,
                                               rg_id=rg)
        counters_value_2 = get_counters_values(counters="M55910C00002",
                                               localmoid="PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-" + nrcell_id,
                                               filepath=pm_counters_file,
                                               rg_id=rg)

        assert int(counters_value_range[0].split("-")[0]) <= counters_value_1["M55910C00001"] <= \
               int(counters_value_range[0].split("-")[1]), "counter M55910C00001 in wrong range"

        assert int(counters_value_range[1].split("-")[0]) <= counters_value_2["M55910C00002"] \
               <= int(counters_value_range[1].split("-")[1]), "counter M55910C00002 in wrong range"

    for rg in counters_to_verify.keys():
        counter_report.get_counters_value_and_report_to_rp("M55910C00001, M55910C00002", "NRCELL-" + nrcell_id,
                                                           pm_counters_file, rg)
