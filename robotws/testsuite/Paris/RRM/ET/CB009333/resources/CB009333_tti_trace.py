"""
:copyright: Nokia Networks
:author: Beata Kapusta, Damian Zak
:maintainer: Beata Kapusta, Damian Zak
:contact: beata.kapusta@nokia.com, damian.zak@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import json
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
from enum import Enum

from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console
from testsuite.Paris.RRM.ET.resources_KRK.python.common_wts import get_ue_rnti_from_wts
from CB009333_attach_traffic import generate_ue_ids as gen_ue_ids


# classPriorityIndex class is defined according to the enum class PriorityIndex of L2PS
# If a new value is inserted in L2PS PriorityIndex class, enum values could be shifted
# => this will cause error as dtxOptimizedDrbTraffic enum value could be 22 instead to 21
# => in that case, classPriorityIndex has to be updated too
# 02/04/2025: add harqRetxDcGbr and dcGbrTraffic and largeBufferTraffic values
# 10/06/2025: add subBandBfUeInPgTraffic value
class classPriorityIndex(Enum):
    rachMsg2 = 0
    harqRetxMsg4 = 1
    harqRetxsrb1 = 2
    harqRetxsrb3 = 3
    harqRetxsrb2 = 4
    harqRetxDcGbr = 5
    harqRetxVoip = 6
    harqRetxGbr = 7
    harqRetxDrb = 8
    dlMacCe = 9
    srb1Traffic = 10
    srb3Traffic = 11
    srb2Traffic = 12
    dcGbrTraffic = 13
    voipTraffic = 14
    gbrTraffic = 15
    nbrDrbTraffic = 16
    subBandBfUeInPgTraffic = 17
    largeBufferTraffic = 18
    drbTraffic = 19
    deprioritizedVoipTraffic = 20
    deprioritizedGbrTraffic = 21
    dtxOptimizedDrbTfc = 22
    lastUnUsed = 23


def get_all_events_dicts_from_tti(path, event):
    event_list = list()
    with open(path, 'r') as json_file:
        tti_even_list = json.load(json_file)["events"]
        for item in tti_even_list:
            if event in item:
                event_list.append(item)
    return event_list


def get_all_enumerated_events(path):
    event_list = list()
    with open(path, 'r') as json_file:
        tti_even_list = json.load(json_file)["events"]
        for index, item in enumerate(tti_even_list):
            event_list.append([index, item])
    return event_list


def get_all_dlprescheddata_events(path):
    return get_all_events_dicts_from_tti(path, 'dlPreSchedData')


def get_all_dlfdscheddata_events(path):
    return get_all_events_dicts_from_tti(path, 'dlFdSchedData')


def get_all_ulfdscheddata_events(path):
    return get_all_events_dicts_from_tti(path, 'ulFdSchedData')


def validate_priority_class(dlprescheddata_events, cell_id=50,
                            priority_class_value=classPriorityIndex.dtxOptimizedDrbTfc.value,
                            validation_condition='>=', validation_value=2):
    """
    Validate priority class field in tti trace logs. Check if the class matches the input value and condition on
    selected cell
    :param dlprescheddata_events: (list) List containing dlprescheddata events
    :param cell_id: (int)
    :param priority_class_value: (int)
    :param validation_condition: (str) Condition for validation value matching (== ,>= or <=)
    :param validation_value: (int) Occurances of desired priority class value
    """
    validated_messages_list = []
    for event in dlprescheddata_events:
        if event['dlPreSchedData']['body']['eventHeader']['physCellId'] == cell_id \
                and event['dlPreSchedData']['body']['highestClassPriority'] == priority_class_value:
            validated_messages_list.append(event)

    condition_status = validate_condition(validated_messages_list, validation_condition, validation_value)
    return {'status': condition_status, 'msg': f'Priority class validated with status:{condition_status}. '
                                               f'Found {len(validated_messages_list)} messages with '
                                               f'highestClassPriority = {priority_class_value} on cell '
                                               f'{cell_id} with expectation condition: {validation_condition} '
                                               f'{validation_value}'}


def validate_condition(validated_messages_list, validation_condition, validation_value):
    def __equal_condition(validated_messages_list, validation_value):
        return len(validated_messages_list) == validation_value

    def __greater_or_equal_condition(validated_messages_list, validation_value):
        return len(validated_messages_list) >= validation_value

    def __less_or_equal_condition(validated_messages_list, validation_value):
        return len(validated_messages_list) <= validation_value

    return {
        '==': __equal_condition,
        '>=': __greater_or_equal_condition,
        '<=': __less_or_equal_condition
    }.get(validation_condition)(validated_messages_list, validation_value)


def validate_scell_activation_delay(dlprescheddata_events, dlfdscheddata_events):
    """
    Validate Scell activation delay. Check if time difference between Scell activation message and closest macCE
    messsage if lower than 10ms
    :param dlprescheddata_events: (list) List containing dlprescheddata events
    :param dlfdscheddata_events: (list) List containing dlfdscheddata events
    """
    macce_messages_time = []
    validated_message = []
    scell_activation_time = -1
    for event in dlfdscheddata_events:
        eventHeader = event['dlFdSchedData']['body']['eventHeader']
        if '2' in str(event['dlFdSchedData']['body']['macCe']['sCellActDeact']):
            scell_activation_time = (eventHeader['sfn'] + eventHeader['slot'])
    if scell_activation_time == -1:
        return {'status': False, 'msg': 'Scell not activated'}

    for event in dlprescheddata_events:
        eventHeader = event['dlPreSchedData']['body']['eventHeader']
        if str(event['dlPreSchedData']['body']['highestClassPriority']) == '9' and '52' in str(
                event['dlPreSchedData']['body']['eventHeader']['physCellId']):
            macce_messages_time.append(eventHeader['sfn'] + eventHeader['slot'])

    for macce_message_time in macce_messages_time:
        if 10 >= scell_activation_time - macce_message_time >= 0:
            validated_message.append(macce_message_time)
    if len(validated_message) == 1:
        return {'status': True, 'msg': 'Scell activation delay validated successfully'}
    else:
        return {'status': False, 'msg': 'Scell activation delay validation fail'}


def validate_multicellsyncslot(enumerated_events):
    """
    Validate multi cell sync slot traces. Check if there are two multi cell sync slot traces in the same sfn and
    slot on both cells
    :param enumerated_events: (list) List containing enumerated tti trace events
    """
    pairs = []
    validated_sync_pairs = []
    for index, event in enumerated_events:
        if list(event.keys())[0] == 'dlDtxOptimData':
            if event['dlDtxOptimData']['body']['dlDtxOptimEvent'] == 'MULTICELLSYNCSLOT':
                pairs.append([index, event['dlDtxOptimData']['body']['eventHeader']['slot'],
                              event['dlDtxOptimData']['body']['eventHeader']['sfn'],
                              f'cell={event["dlDtxOptimData"]["body"]["eventHeader"]["physCellId"]}'])
    sorted_pairs = sorted(pairs)
    for element, next_element in zip(sorted_pairs[::], sorted_pairs[1::]):
        if element[1] == next_element[1] and element[2] != next_element[2]:
            validated_sync_pairs.append([element, next_element])
    if len(validated_sync_pairs) > 2:
        return {'status': True,
                'msg': f'Multicellsyncslot trace appeared {len(validated_sync_pairs)} on the same SLOT & SFN'}
    else:
        return {'status': False,
                'msg': f'Multicellsyncslot trace appeared {len(validated_sync_pairs)} on the same SLOT & SFN with '
                       f'expectation of minimum 2'}


def validate_txnumber(ulfdscheddata_events):
    """
    Validate if all txNumber traces values are equal to 1
    :param ulfdscheddata_events: (list) List containing ulfdscheddata events
    """
    txnumber_good_case_counter = 0
    txnumber_bad_case_counter = 0
    for event in ulfdscheddata_events:
        if event['ulFdSchedData']['body']['txNumber'] == 1:
            txnumber_good_case_counter += 1
        else:
            txnumber_bad_case_counter += 1

    if txnumber_good_case_counter > 0 and txnumber_bad_case_counter == 0:
        return {'status': True, 'msg': f'TxNumber trace with value 1 appeared {txnumber_good_case_counter} times. '
                                       f'Validation success'}
    else:
        return {'status': False, 'msg': f'TxNumber trace with value different then 1 appeared '
                                        f'{txnumber_bad_case_counter} times with expectation of 0. TxNumb trace with '
                                        f'value 1 appeared {txnumber_good_case_counter} times. Validation fail'}


def validate_maxharqtxnum(ulfdscheddata_events):
    """
    Validate if value 3 exists in max harq tx num trace
    :param ulfdscheddata_events: (list) List containing ulfdscheddata events
    """
    maxharqtxnum_good_case_counter = 0
    for event in ulfdscheddata_events:
        if event['ulFdSchedData']['body']['maxHarqTxNum'] == 3:
            maxharqtxnum_good_case_counter += 1

    if maxharqtxnum_good_case_counter > 0:
        return {'status': True, 'msg': f'MaxHarqTxNum trace with value 3 appeared {maxharqtxnum_good_case_counter}. '
                                       f'Validation succes'}
    else:
        return {'status': False, 'msg': f'MaxHarqTxNum trace with value 3 appeared {maxharqtxnum_good_case_counter} '
                                        f'with expectation of >0. Validation fail'}


def get_lc_id(dlfdscheddata_events):
    for index, element in enumerate(dlfdscheddata_events[52]['dlFdSchedData']['body']['scheduledBearers']):
        if element['lcId'] == 4:
            lc_id_4 = index
        elif element['lcId'] == 5:
            lc_id_5 = index
    return {'lc_id_4': lc_id_4, 'lc_id_5': lc_id_5}


def get_data_for_drb_validation(enumerated_events, dlfdscheddata_events, rnti=None):
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    cell_id = 52 if 'FDD' in test_name else 50
    lc_id = get_lc_id(dlfdscheddata_events)

    def __get_data_for_a_validation():
        data_to_validate = []
        for index, event in enumerated_events:
            if list(event.keys())[0] == 'dlPreSchedData':
                body = event['dlPreSchedData']['body']
                if body['csListEvent'] == 'ENTRYNONNULLBUFFER' and \
                        body['eventHeader']['physCellId'] == cell_id and \
                        body['highestClassPriority'] == classPriorityIndex.dtxOptimizedDrbTfc.value:
                    data_to_validate.append(
                        [index, body['eventHeader']['slot'], body['eventHeader']['sfn'], 'EntryUDtx'])

                if body['csListEvent'] == 'UPDATEPRIORITYCLASSUPGRADE' and \
                        body['eventHeader']['physCellId'] == cell_id and \
                        body['highestClassPriority'] == classPriorityIndex.drbTraffic.value:
                    data_to_validate.append([index, body['eventHeader']['slot'],
                                             body['eventHeader']['sfn'], 'UpdateDrb'])

            if list(event.keys())[0] == 'dlFdSchedData':
                data_to_validate.append([index,
                                         event['dlFdSchedData']['body']['eventHeader']['slot'],
                                         event['dlFdSchedData']['body']['eventHeader']['sfn'],
                                         event['dlFdSchedData']['body']['scheduledBearers'][lc_id['lc_id_4']][
                                             'scheduledBytesPerBearer'],
                                         event['dlFdSchedData']['body']['scheduledBearers'][lc_id['lc_id_5']][
                                             'scheduledBytesPerBearer'], 'Data'])
        return data_to_validate

    def __get_data_for_f_validation():
        data_to_validate = []
        for index, event in enumerated_events:
            if list(event.keys())[0] == 'dlPreSchedData':
                body = event['dlPreSchedData']['body']
                if body['csListEvent'] == 'ENTRYNONNULLBUFFER' and \
                        body['eventHeader']['physCellId'] == cell_id and \
                        body['highestClassPriority'] == classPriorityIndex.dtxOptimizedDrbTfc.value and \
                        body['eventHeader']['rnti'] == int(rnti):
                    data_to_validate.append(
                        [index, event['dlPreSchedData']['body']['eventHeader']['slot'],
                         event['dlPreSchedData']['body']['eventHeader']['sfn'], 'EntryUDtx'])
                if body['csListEvent'] == 'UPDATEPRIORITYCLASSUPGRADE' and \
                        body['eventHeader']['physCellId'] == cell_id and \
                        body['highestClassPriority'] == classPriorityIndex.drbTraffic.value and \
                        body['eventHeader']['rnti'] == int(rnti):
                    data_to_validate.append(
                        [index, event['dlPreSchedData']['body']['eventHeader']['slot'],
                         event['dlPreSchedData']['body']['eventHeader']['sfn'], 'UpdateDrb'])

            if list(event.keys())[0] == 'dlFdSchedData':
                if event['dlFdSchedData']['body']['eventHeader']['rnti'] == int(rnti):
                    data_to_validate.append([index, event['dlFdSchedData']['body']['eventHeader']['slot'],
                                             event['dlFdSchedData']['body']['eventHeader']['sfn'],
                                             event['dlFdSchedData']['body']['scheduledBearers'][lc_id['lc_id_4']][
                                                 'scheduledBytesPerBearer'],
                                             event['dlFdSchedData']['body']['scheduledBearers'][lc_id['lc_id_5']][
                                                 'scheduledBytesPerBearer'], 'Data'])
        return data_to_validate

    if rnti:
        data_to_validate = __get_data_for_f_validation()
    else:
        data_to_validate = __get_data_for_a_validation()
    return sorted(data_to_validate)


def validate_single_drb_retention_delay(enumerated_events, dlfdscheddata_events):
    data_for_a_validation = get_data_for_drb_validation(enumerated_events, dlfdscheddata_events)
    pass_scenario_counter = 0
    lc_id_4_bytes_per_bearer = 3
    lc_id_5_bytes_per_bearer = 4
    on_air_time_sfn = 2
    on_air_time_slot = 1
    for element, second_element, third_element in zip(data_for_a_validation[::], data_for_a_validation[1::],
                                                      data_for_a_validation[2::]):
        if 'EntryUDtx' in element and 'UpdateDrb' in second_element and 'Data' in third_element \
                and third_element[lc_id_4_bytes_per_bearer] != 0 and third_element[lc_id_5_bytes_per_bearer] == 0 \
                and abs((element[on_air_time_sfn] + element[on_air_time_slot]) -
                        (second_element[on_air_time_sfn] + second_element[on_air_time_slot])) == 1:
            pass_scenario_counter += 1
    if pass_scenario_counter > 50:
        return {'status': True, 'msg': f'DRB specific retention delay validated successfully. Found '
                                       f'{pass_scenario_counter} matching traces'}
    else:
        return {'status': False, 'msg': f'DRB specific retention delay validation fail. Found {pass_scenario_counter} '
                                        f'matching traces with expectation of minimum 50'}


def validate_multi_drb_retention_delay(enumerated_events, dlfdscheddata_events):
    data_for_a_validation = get_data_for_drb_validation(enumerated_events, dlfdscheddata_events)
    drb_specific_delay_counter = 0
    cell_drb_delay_counter = 0
    lc_id_4_bytes_per_bearer = 3
    lc_id_5_bytes_per_bearer = 4
    on_air_time_sfn = 2
    on_air_time_slot = 1
    for element, second_element, third_element in zip(data_for_a_validation[::], data_for_a_validation[1::],
                                                      data_for_a_validation[2::]):
        if 'EntryUDtx' in element and 'UpdateDrb' in second_element and 'Data' in third_element:
            if abs((element[on_air_time_sfn] + element[on_air_time_slot]) - (
                    second_element[on_air_time_sfn] + second_element[on_air_time_slot])) == 1:
                if third_element[lc_id_4_bytes_per_bearer] > 0 and third_element[lc_id_5_bytes_per_bearer] >= 0:
                    drb_specific_delay_counter += 1
            elif abs((element[on_air_time_sfn] + element[on_air_time_slot]) - (
                    second_element[on_air_time_sfn] + second_element[on_air_time_slot])) == 2:
                if third_element[lc_id_4_bytes_per_bearer] == 0 and third_element[lc_id_5_bytes_per_bearer] > 0:
                    cell_drb_delay_counter += 1
    if drb_specific_delay_counter > 40 and cell_drb_delay_counter > 20:
        return {'status': True, 'msg': f'DRB specific retention delay validated successfully. Found '
                                       f'{drb_specific_delay_counter} DRB specific matching traces and '
                                       f'{cell_drb_delay_counter} Cell value delay matching traces'}
    else:
        return {'status': False, 'msg': f'DRB specific retention delay validation fail. Found '
                                        f'{drb_specific_delay_counter} DRB specific matching traces with expectation '
                                        f'of minimum 50 and {cell_drb_delay_counter} Cell value delay matching traces '
                                        f'with expectation of minimum 20'}


def get_rnti(num_of_ues):
    ue_ids = gen_ue_ids(num_of_ues)
    rntis = [get_ue_rnti_from_wts(ue_id) for ue_id in ue_ids]

    return rntis


def get_data_for_drx_validation(enumerated_events, dlprescheddata_events):
    """
    Get unique data for which DRX is activated.

    :param enumerated_events: (list) List containing enumerated tti trace events
    :param dlprescheddata_events: (list) List containing dlprescheddata events
    """
    pairs = []
    unique_pairs = []
    drx_activated_unique_pairs = []
    hfn = None
    cycle_start_hfn = None
    drx_activated_found = False

    for index, event in enumerated_events:
        if list(event.keys())[0] == 'ulIntraDlToUlDrxSyncDlData' and \
                event['ulIntraDlToUlDrxSyncDlData']['body']['dlDrxOndurationTimerOn'] == 1 and \
                event['ulIntraDlToUlDrxSyncDlData']['body']['eventHeader']['physCellId'] == 52:
            sfn = event['ulIntraDlToUlDrxSyncDlData']['body']['eventHeader']['sfn']
            current_hfn = event['ulIntraDlToUlDrxSyncDlData']['body']['eventHeader']['hfnTickCount']

            if hfn is not None and current_hfn - hfn == 1:
                cycle_start_hfn = current_hfn
            if cycle_start_hfn is not None:
                sfn += 1024
            pairs.append([index, sfn])
            hfn = current_hfn

    sorted_pairs = sorted(pairs)
    for element, next_element in zip(sorted_pairs[::], sorted_pairs[1::]):
        if element[1] != next_element[1]:
            unique_pairs.append(element)

    for element in unique_pairs:
        sfn = element[1]
        for event in dlprescheddata_events:
            if event['dlPreSchedData']['body']['eventHeader']['sfn'] == sfn:
                drx_status = event['dlPreSchedData']['body']['csListEvent']
                if drx_status == "ENTRYDRX":
                    drx_activated_found = True
                    break

        if drx_activated_found:
            drx_activated_unique_pairs.append(element)

    return drx_activated_unique_pairs


def validate_drx_period(enumerated_events, dlprescheddata_events):
    """
    Validate drx period between SFNs.

    :param enumerated_events: (list) List containing enumerated tti trace events
    :param dlprescheddata_events: (list) List containing dlprescheddata events
    """
    invalid_items_list = []
    data_for_drx_validation = get_data_for_drx_validation(enumerated_events, dlprescheddata_events)
    for index in range(len(data_for_drx_validation) - 1):
        element, next_element = data_for_drx_validation[index][1], data_for_drx_validation[index + 1][1]
        if abs(next_element - element) < 8:
            dtx_optimized_class_uDtx_match = False
            for event in dlprescheddata_events:
                if event['dlPreSchedData']['body']['eventHeader']['sfn'] == element:
                    highest_class_priority = event['dlPreSchedData']['body']['highestClassPriority']
                    if highest_class_priority == classPriorityIndex.dtxOptimizedDrbTfc.value:
                        dtx_optimized_class_uDtx_match = True
                        break
            if not dtx_optimized_class_uDtx_match:
                invalid_items_list.append([element, next_element])
        if abs(next_element - element) == 9:
            dtx_optimized_class_drb_match = False
            for event in dlprescheddata_events:
                if event['dlPreSchedData']['body']['eventHeader']['sfn'] == element:
                    highest_class_priority = event['dlPreSchedData']['body']['highestClassPriority']
                    if highest_class_priority == classPriorityIndex.drbTraffic.value:
                        dtx_optimized_class_drb_match = True
                        break
            if not dtx_optimized_class_drb_match:
                invalid_items_list.append([element, next_element])
        if abs(next_element - element) > 9:
            invalid_items_list.append([element, next_element])

    if len(invalid_items_list) <= 1:
        return {'status': True, 'msg': f'The DRX period values are correct.'}
    else:
        return {'status': False,
                'msg': f'The DRX period values are NOT correct. The number of invalid values is'
                       f' {len(invalid_items_list)}.'}


def validate_multi_ue_retention_delay(enumerated_events, dlfdscheddata_events, rnti, validation_condition='drb1'):
    data_for_drb_validation = get_data_for_drb_validation(enumerated_events, dlfdscheddata_events, rnti)
    first_drb_data = 0
    second_drb_data = 0
    on_air_time_sfn = 2
    on_air_time_slot = 1
    lc_id_4_bytes_per_bearer = 3
    lc_id_5_bytes_per_bearer = 4
    for element, second_element, third_element in zip(data_for_drb_validation[::], data_for_drb_validation[1::],
                                                      data_for_drb_validation[2::]):
        if 'EntryUDtx' in element and 'UpdateDrb' in second_element and 'Data' in third_element:
            if abs((element[on_air_time_sfn] + element[on_air_time_slot]) - (
                    second_element[on_air_time_sfn] + second_element[on_air_time_slot])) == 1:
                if third_element[lc_id_4_bytes_per_bearer] > 0 and third_element[lc_id_5_bytes_per_bearer] == 0:
                    first_drb_data += 1
                elif third_element[lc_id_4_bytes_per_bearer] == 0 and third_element[lc_id_5_bytes_per_bearer] > 0:
                    second_drb_data += 1

    if 'drb1' in validation_condition:
        if first_drb_data > 0 and second_drb_data == 0:
            return {'status': True,
                    'msg': f'Multi UE retention delay validated successfully for first DRB. Found {first_drb_data} '
                           f'DRB1 data and {second_drb_data} DRB2 data'
                    }
        else:
            return {'status': False,
                    'msg': f'Multi UE retention delay validation for first DRB failed. Found {first_drb_data} '
                           f'DRB1 data (expected >0) and {second_drb_data} DRB2 data (expected ==0)'
                    }
    else:
        if second_drb_data > 0 and first_drb_data == 0:
            return {'status': True,
                    'msg': f'Multi UE retention delay validated successfully for second DRB. Found {first_drb_data} '
                           f'DRB1 data and {second_drb_data} DRB2 data'
                    }
        else:
            return {'status': False,
                    'msg': f'Multi UE retention delay validation for second DRB failed. Found {first_drb_data} '
                           f'DRB1 data (expected ==0) and {second_drb_data} DRB2 data (expected >0)'
                    }


def validate_tti_trace_a_tc01(enumerated_events, dlfdscheddata_events):
    single_drb_retention_delay_result = validate_single_drb_retention_delay(enumerated_events, dlfdscheddata_events)
    return single_drb_retention_delay_result,


def validate_tti_trace_a_tc04(enumerated_events, dlfdscheddata_events):
    multi_drb_retention_delay_result = validate_multi_drb_retention_delay(enumerated_events, dlfdscheddata_events)
    return multi_drb_retention_delay_result,


def validate_tti_trace_b(dlprescheddata_events, enumerated_events, ulfdscheddata_events):
    first_class_result = validate_priority_class(dlprescheddata_events, cell_id=50,
                                                 priority_class_value=classPriorityIndex.dtxOptimizedDrbTfc.value,
                                                 validation_value=25)
    second_class_result = validate_priority_class(dlprescheddata_events, cell_id=51,
                                                  priority_class_value=classPriorityIndex.dtxOptimizedDrbTfc.value,
                                                  validation_value=25)
    multicellsyncslot_result = validate_multicellsyncslot(enumerated_events)
    txnumber_result = validate_txnumber(ulfdscheddata_events)
    return first_class_result, second_class_result, multicellsyncslot_result, txnumber_result


def validate_tti_trace_c(test_case, dlprescheddata_events, dlfdscheddata_events):
    cells = [52, 53] if '7' in test_case else [53, 52]
    pcell_class_result = validate_priority_class(dlprescheddata_events, cell_id=cells[0],
                                                 priority_class_value=classPriorityIndex.dtxOptimizedDrbTfc.value,
                                                 validation_condition='<=', validation_value=10)
    scell_class_result = validate_priority_class(dlprescheddata_events, cell_id=cells[1],
                                                 priority_class_value=classPriorityIndex.dtxOptimizedDrbTfc.value,
                                                 validation_value=100)
    scell_activation_result = validate_scell_activation_delay(dlprescheddata_events, dlfdscheddata_events)
    return pcell_class_result, scell_class_result, scell_activation_result


def validate_tti_trace_d(enumerated_events, dlfdscheddata_events, dlprescheddata_events):
    single_drb_retention_delay_result = validate_single_drb_retention_delay(enumerated_events, dlfdscheddata_events)
    validate_drx_result = validate_drx_period(enumerated_events, dlprescheddata_events)
    return single_drb_retention_delay_result, validate_drx_result


def validate_tti_trace_e(enumerated_events, dlfdscheddata_events):
    rnti = get_rnti(num_of_ues=2)
    first_ue_retention_delay_result = validate_multi_ue_retention_delay(enumerated_events, dlfdscheddata_events,
                                                                        rnti[0])
    second_ue_retention_delay_result = validate_multi_ue_retention_delay(enumerated_events, dlfdscheddata_events,
                                                                         rnti[1], validation_condition='drb2')
    return first_ue_retention_delay_result, second_ue_retention_delay_result


def validate_tti_trace_f(dlprescheddata_events, ulfdscheddata_events):
    priority_class_result = validate_priority_class(dlprescheddata_events, cell_id=50,
                                                    priority_class_value=classPriorityIndex.dtxOptimizedDrbTfc.value,
                                                    validation_condition='==', validation_value=0)
    txnumber_result = validate_txnumber(ulfdscheddata_events)
    maxharqtxnum_result = validate_maxharqtxnum(ulfdscheddata_events)
    return priority_class_result, txnumber_result, maxharqtxnum_result


def handle_results(results):
    failed_results = []
    for result in results:
        if result['status']:
            logger_console(result['msg'])
        else:
            failed_results.append(result['msg'])
    if len(failed_results) >= 1:
        raise ExecutionFailed(message='\n'.join(failed_results))


def validate_tti_trace(tti_trace_json_path='/home/ute/ttiTrace.json'):
    logger_console('Start TTI trace validation')
    dlprescheddata_events = get_all_dlprescheddata_events(path=tti_trace_json_path)
    dlfdscheddata_events = get_all_dlfdscheddata_events(path=tti_trace_json_path)
    ulfdscheddata_events = get_all_ulfdscheddata_events(path=tti_trace_json_path)
    enumerated_events = get_all_enumerated_events(path=tti_trace_json_path)
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    if '_001_' in test_name:
        results = validate_tti_trace_a_tc01(enumerated_events=enumerated_events,
                                            dlfdscheddata_events=dlfdscheddata_events)
    elif '_004_' in test_name:
        results = validate_tti_trace_a_tc04(enumerated_events=enumerated_events,
                                            dlfdscheddata_events=dlfdscheddata_events)
    elif '_006_' in test_name:
        results = validate_tti_trace_b(dlprescheddata_events=dlprescheddata_events,
                                       enumerated_events=enumerated_events, ulfdscheddata_events=ulfdscheddata_events)
    elif '_007_' in test_name:
        results = validate_tti_trace_c(test_case='7', dlprescheddata_events=dlprescheddata_events,
                                       dlfdscheddata_events=dlfdscheddata_events)
    elif '_011_' in test_name:
        results = validate_tti_trace_c(test_case='11', dlprescheddata_events=dlprescheddata_events,
                                       dlfdscheddata_events=dlfdscheddata_events)
    elif '_013' in test_name:
        results = validate_tti_trace_d(enumerated_events=enumerated_events, dlfdscheddata_events=dlfdscheddata_events,
                                       dlprescheddata_events=dlprescheddata_events)
    elif '_015' in test_name:
        results = validate_tti_trace_e(enumerated_events=enumerated_events, dlfdscheddata_events=dlfdscheddata_events)
    elif '_018_' in test_name:
        results = validate_tti_trace_f(dlprescheddata_events=dlprescheddata_events,
                                       ulfdscheddata_events=ulfdscheddata_events)
    handle_results(results)
