from taf.wts.runner import runner
from ta5g_pm_counters.interface import ta5g_pm_counters
from robot.api import logger
from robot.libraries.String import String
from robot.libraries.BuiltIn import BuiltIn
import logging
import re
import csv


def setup_x2_connection():
    logger.info("\n Setup X2 Connection ...")
    pattern = "ENB-1: X2AP Link with GNB-2 .* is up"
    runner().enb_x2_link_up(enb=1, target=2)
    output = runner().read_wtsemu_output_until_re(expected=pattern, timeout=300)
    output = String().get_lines_matching_regexp(string=output, pattern=pattern, partial_match=True)
    BuiltIn().log_to_console(" \n {}".format(output))


def get_ip(raw_ip):
    try:
        search_object = re.search("inet [0-9,.]*", raw_ip)
        source_ip = search_object.string[search_object.span()[0]+5:search_object.span()[1]]
    except AttributeError:
        logging.warning("Did not recieve usable input -AttributeError-, defaulting to ip 10.0.1.2")
        source_ip = "10.0.1.2"
    except TypeError:
        logging.warning("Wrong Input Type was given. setting IP to 10.0.1.2")
        source_ip = "10.0.1.2"
    return source_ip


def read_and_parse_csv_data_into_dictionary(sherpa_trace_file_path):
    """
    This function takes as input data from Sherpa L1L2 Traces, then, it
    rearrange these data an creates a dictionary where messages can be observed
    per slot.

    :sherpa_trace_file_path - Path in     which are located L1L2 traces
    :return  Returns dictionary with grants per slots

    e.g. {
            "536.16":{
                    "Dl SlotTypeReq":"slotType=29, C0",
                    "Dl PdschSendReq(30)":"codeBooki=3,i1/i2codBook4AntP=(16777215,3) ...
                    "Dl PdcchSendReq(29)":"grant for SI rnti, ...
            },
            "6397.32":{
                    "Dl PdcchSendReq(29)":"DL grant 1-1,...,
                    "Dl PdschSendReq(30)":"codeBooki=3,...,
            },
            "6397.56":{
                    "Dl PdcchSendReq(29)":"DL grant 1-1,dciSize=48,power=-28.00dB,...,
                    "Dl PdschSendReq(30)":"codeBooki=3,i1/i2codBook4AntP=(16777215,3),...,
            }
        }
    """
    with open(sherpa_trace_file_path, "r") as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=";")
        line_count = 0
        sherpa_data_dict = {}
        for row in csv_reader:
            slot = row[0]
            msg = row[9]
            txt = row[11]
            rnti = row[8]
            if line_count == 0:
                line_count += 1
            elif line_count == 1:
                sherpa_data_dict[slot] = {msg: [txt]}
                line_count += 1
            else:
                if slot in sherpa_data_dict:
                    if msg in sherpa_data_dict[slot].keys():
                        sherpa_data_dict[slot][msg].append(" - ".join([txt, rnti]))
                    else:
                        sherpa_data_dict[slot][msg] = [" - ".join([txt, rnti])]
                else:
                    sherpa_data_dict.update({slot: {msg: [" - ".join([txt, rnti])]}})
    return sherpa_data_dict


def get_traces_with_common_channel_sib(general_data):
    """ Return dict with common channel slots

        :general data - data containing all slots
    """
    slots_with_common_channel = {}
    for slot in general_data:
        for msg in general_data[slot]:
            if any([x for x in general_data[slot][msg] if "grant for SI rnti" in x]):
                slots_with_common_channel.update({slot: general_data[slot]})
    return slots_with_common_channel


def get_traces_without_common_channel_sib(general_data):
    """
    Return dict without common channel slots

    :general data - data containing all slots
    """
    slot_list = []
    slots_without_common_channel = {}
    for s in general_data:
        sib_count = 0
        for m in general_data[s]:
            if any([x for x in general_data[s][m] if "grant for SI rnti" in x]):
                sib_count += 1
        if sib_count >= 1:
            continue
        else:
            slot_list.append(s)

    for s in slot_list:
        slots_without_common_channel.update({s: general_data[s]})
    return slots_without_common_channel


def get_traces_with_al_set(data, al):
    """
    Returns dict with slots having a determined value of Aggregation Level

    :data - data containing all slots to process
    :al - aggregation level to filter
    """
    slots_with_specific_al = {}
    for s in data:
        for m in data[s]:
            if any([x for x in data[s][m] if "AL={}".format(al) in x]):
                slots_with_specific_al.update({s: data[s]})
    return slots_with_specific_al


def get_slot_id_that_has_pdsch_grant_at_symbol(general_data, symbol):
    """ Returns the Slots IDs containing startPDSCHSymbol=* and the data itself """
    slot_list = []
    for slot in general_data:
        for msg in general_data[slot]:
            if any([x for x in general_data[slot][msg] if "startPDSCHSymbol={}".format(symbol) in x]):
                slot_list.append(slot)
    return slot_list


def get_slot_ids_containing_both_ul_and_dl_grants(general_data):
    """ Returns the Slots IDs containing both UL and DL grants and the data itself"""
    slot_list = []
    ul_grant = "UL grant 0-1"
    dl_grant = "DL grant 1-1"
    for slot in general_data:
        slot_count_ul = 0
        slot_count_dl = 0
        for msg in general_data[slot]:
            if any([x for x in general_data[slot][msg] if ul_grant in x]):
                slot_count_ul += 1
            if any([x for x in general_data[slot][msg] if dl_grant in x]):
                slot_count_dl += 1
            if slot_count_dl > 0 and slot_count_ul > 0 and (slot not in slot_list):
                slot_list.append(slot)
    return slot_list


def verify_that_within_a_slot_start_pdsch_is_not_equal_start_pdcch(data):
    """
        This function verifies if within a slot the startPDCCHSymbol a grant
        is not equal startPDSCHSymbol.
    """
    for s in data:
        start_pdcch_values_list = []
        start_pdcch_values_dict = {}
        start_pdsch_values_list = []
        start_pdsch_values_dict = {}
        if any([k for k in list(data[s].keys()) if "Dl PdcchSendReq" in k]) and \
                any([k for k in list(data[s].keys()) if "Dl PdschSendReq" in k]):
            for m in data[s]:
                if "Dl PdcchSendReq" in m:
                    for content in data[s][m]:
                        initial_index_pdcch = content.find("startPDCCHSymbol=")
                        if initial_index_pdcch >= 0:
                            start_pdcch_values_list.append(content[initial_index_pdcch:initial_index_pdcch + 18])
                elif "Dl PdschSendReq" in m:
                    for content in data[s][m]:
                        initial_index_pdsch = content.find("startPDSCHSymbol=")
                        if initial_index_pdsch >= 0:
                            start_pdsch_values_list.append(content[initial_index_pdsch:initial_index_pdsch + 18])
        start_pdsch_values_dict.update({s: start_pdsch_values_list})
        start_pdcch_values_dict.update({s: start_pdcch_values_list})
        for slot_pdsch, value_pdsch in start_pdsch_values_dict.items():
            for slot_pdcch, value_pdcch in start_pdcch_values_dict.items():
                for dc in value_pdcch:
                    for ds in value_pdsch:
                        try:
                            assert dc[-1] != ds[-1]
                        except AssertionError:
                            msg = """ The value of startPDCCHSymbol ({0}) is equal to startPDSCHSymbol ({1})
                                       at slot ID ({2})""".format(dc, ds, slot_pdcch)
                            logger.debug(msg)
                            raise Exception(msg)


def verify_the_number_of_symbols_expected_for_pdcch_at_slots_without_common_channel(data,
                                                                                    exp_symbols,
                                                                                    exp_aggregation_level):
    """
    Checks the number of PDCCH symbols expected at specific slot based on startPDSCHSymbol and nbPDSCHSymbols

    ATT. This method should not be used for slots having grants SI-RNTI or P-RNTI

    :data - Data to be analyzed
    :exp_symbols - Number of symbols expected
    :exp_aggregation_level - expected aggregation level
    """
    list_to_validate = []
    data_without_common_channel = get_traces_without_common_channel_sib(data)
    data_without_common_channel_al_set = get_traces_with_al_set(data=data_without_common_channel,
                                                                al=exp_aggregation_level)
    for slot in data_without_common_channel_al_set:
        start_pdsch_symbols_list = []
        nb_pdsch_symbols_list = []
        for msg in data_without_common_channel_al_set[slot]:
            if re.match("Dl PdschSendReq(.*)", msg):
                for content in data_without_common_channel_al_set[slot][msg]:
                    start_pdsch_symb_index = content.find("startPDSCHSymbol=")
                    nb_pdsch_symbols_index = content.find("nbPDSCHSymbols=")
                    if start_pdsch_symb_index >= 0 and nb_pdsch_symbols_index >= 0:
                        start_pdsch_symbols_list.append(content[start_pdsch_symb_index:
                                                                start_pdsch_symb_index + 18])
                        nb_pdsch_symbols_list.append(content[nb_pdsch_symbols_index:
                                                             nb_pdsch_symbols_index + 17])
                    else:
                        continue
        if start_pdsch_symbols_list != nb_pdsch_symbols_list:
            number_of_pdcch_symbols_lists = \
                get_number_of_pdcch_symbols_at_slot_level(slot=slot, nb_pdsch_list=nb_pdsch_symbols_list)
            list_to_validate.append(number_of_pdcch_symbols_lists)
    check_that_the_number_of_pdcch_symbols_expected_is_present(expected_number=exp_symbols, data=list_to_validate)


def verify_the_number_of_symbols_expected_for_pdcch_at_slots_with_common_channel(data,
                                                                                 expected_symbols,
                                                                                 expected_aggregation_level):
    """
    Checks the number of PDCCH symbols expected at specific slot based on startPDSCHSymbol and nbPDSCHSymbols

    :data - Data to be analyzed
    :expected_symbols - Number of symbols expected
    :expected_aggregation_level - expected aggregation level
    """
    list_to_validate = []
    rnti = "0xffff"
    data_with_common_channel = get_traces_with_common_channel_sib(data)
    data_with_common_channel_al_set = get_traces_with_al_set(data=data_with_common_channel,
                                                             al=expected_aggregation_level)
    for slot in data_with_common_channel_al_set:
        start_pdsch_symbols_list = []
        nb_pdsch_symbols_list = []
        for msg in data_with_common_channel_al_set[slot]:
            if re.match("Dl PdschSendReq(.*)", msg):
                for content in data_with_common_channel_al_set[slot][msg]:
                    if rnti not in content:
                        start_pdsch_symb_index = content.find("startPDSCHSymbol=")
                        nb_pdsch_symbols_index = content.find("nbPDSCHSymbols=")
                        if start_pdsch_symb_index >= 0 and nb_pdsch_symbols_index >= 0:
                            start_pdsch_symbols_list.append(content[start_pdsch_symb_index:
                                                                    start_pdsch_symb_index + 18])
                            nb_pdsch_symbols_list.append(content[nb_pdsch_symbols_index:
                                                                 nb_pdsch_symbols_index + 17])
                        else:
                            continue
        if start_pdsch_symbols_list != nb_pdsch_symbols_list:
            number_of_pdcch_symbols_lists = \
                get_number_of_pdcch_symbols_at_slot_level(slot=slot, nb_pdsch_list=nb_pdsch_symbols_list)
            list_to_validate.append(number_of_pdcch_symbols_lists)
    check_that_the_number_of_pdcch_symbols_expected_is_present(expected_number=expected_symbols, data=list_to_validate)


def get_number_of_pdcch_symbols_at_slot_level(slot, nb_pdsch_list):
    """ Function returns the number of pdcch symbols with slot ID """
    NUM_OF_SYMBOLS = 14
    n_list_num_of_pdcch_symbols = []
    d = {}
    for nb_pdsch in nb_pdsch_list:
        if nb_pdsch.split('=')[1].startswith("1"):
            n_nb_pdsch = int(nb_pdsch.split('=')[1])
            number_of_pdcch_symbols = NUM_OF_SYMBOLS - n_nb_pdsch
            n_list_num_of_pdcch_symbols.append(number_of_pdcch_symbols)
            d.update({slot: n_list_num_of_pdcch_symbols})
    return d


def check_that_the_number_of_pdcch_symbols_expected_is_present(expected_number, data):
    """
    Check if the expected number of symbols is present within found sets

    :expected_number - Number of symbols expected
    :data - Parsed data containing data with slots information
    """
    result = any([slot_value for slot_value in data for s, v in slot_value.items() if int(expected_number) in v])
    BuiltIn().should_be_true(result)


def verify_counters(counter, condition, status, counter_files):
    reference_counter = ta5g_pm_counters().get_pm_counter_value(counter, "PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1",
                                                                counter_files[0])
    counter_to_compare = ta5g_pm_counters().get_pm_counter_value(counter, "PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1",
                                                                 counter_files[1])
    if status == 'disabled':
        reference_counter, counter_to_compare = counter_to_compare, reference_counter
    assert reference_counter > counter_to_compare if condition == 'higher' else reference_counter < counter_to_compare


def is_cce_split_activated_in_this_slot(messages, aggregation_level):
    ul_grant = "Dl PdcchSendReq(31)"
    dl_grant = "Dl PdcchSendReq(29)"

    aggregation_level = "AL={}".format(aggregation_level)
    pdcch_symbol_regexp = "startPDCCHSymbol=([0-9])"

    grants_to_skip = [
        "grant for SI rnti",
        "grant for msg2",
        "searchSpace=Type1",
        "searchSpace=Type3"
    ]

    is_ul_grant_here = ul_grant in messages
    is_dl_grant_here = dl_grant in messages

    if not (is_ul_grant_here and is_dl_grant_here):
        return False
    else:
        ul_symbols = set()
        dl_symbols = set()

        for uplink_grant in messages[ul_grant]:
            if any(grant in uplink_grant for grant in grants_to_skip):
                continue
            if aggregation_level not in uplink_grant:
                continue

            symbol = re.search(pdcch_symbol_regexp, uplink_grant).group(1)
            ul_symbols.add(symbol)

        for downlink_grant in messages[dl_grant]:
            if any(grant in downlink_grant for grant in grants_to_skip):
                continue
            if aggregation_level not in uplink_grant:
                continue

            symbol = re.search(pdcch_symbol_regexp, downlink_grant).group(1)
            dl_symbols.add(symbol)

        if any(pdcch_symbol in ul_symbols for pdcch_symbol in dl_symbols):
            return True
        else:
            return False


def is_common_channel_in_this_slot(messages):
    common_channel = "grant for SI rnti"
    dl_grant = "Dl PdcchSendReq(29)"

    if dl_grant not in messages:
        return False

    if any(common_channel in message for message in messages[dl_grant]):
        return True
    else:
        return False


def largest_ul_symbol_used_in_this_slot(messages):
    ul_grant = "Dl PdcchSendReq(31)"
    pdcch_symbol_regexp = "startPDCCHSymbol=([0-9])"
    ul_symbols = set()
    if ul_grant not in messages:
        return None

    for uplink_grant in messages[ul_grant]:
        symbol = re.search(pdcch_symbol_regexp, uplink_grant).group(1)
        ul_symbols.add(symbol)

    return max(ul_symbols)


def count_slots_with_common_channel_and_3_symbol_pattern(sherpa_csv):
    data = read_and_parse_csv_data_into_dictionary(sherpa_csv)
    counter_cc_and_3_symbols = 0

    for slot, messages in data.items():
        if is_common_channel_in_this_slot(messages):
            largest_symbol = largest_ul_symbol_used_in_this_slot(messages)
            if isinstance(largest_symbol, str) and "2" in largest_symbol:
                logger.debug("Common channel and 3 symbol pattern found in slot {}".format(slot))
                counter_cc_and_3_symbols += 1

    return counter_cc_and_3_symbols


def count_cce_split_occurences_on_given_al(sherpa_csv, aggregation_level):
    data = read_and_parse_csv_data_into_dictionary(sherpa_csv)
    cce_split_counter = 0
    for messages in data.values():
        if is_cce_split_activated_in_this_slot(messages, aggregation_level=aggregation_level):
            cce_split_counter += 1

    return cce_split_counter
