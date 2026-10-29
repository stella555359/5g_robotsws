import re
import os
import json
import time
from ta_messaging import ta_messaging
from ta_messaging.message_flows import get_flow
from ute_common_abstract_core.message import NotFoundKey
from robot.api import logger
from ta5g_interface_tools import ta5g_interface_tools
from robot.libraries.BuiltIn import BuiltIn
from ta5g_tshark import ta5g_tshark
from ta5g_ue_mobility import ta5g_ue_mobility
from ute_wtssim import ute_wtssim
from robot.libraries.OperatingSystem import OperatingSystem

startingPRB_ue_list_sa = []
secondHopPRB_ue_list_sa = []
ue_f1ap_id_list_sa = []
ue_dict_sa = {}
startingPRB_ue_list_nsa = []
secondHopPRB_ue_list_nsa = []
ue_f1ap_id_list_nsa = []
ue_dict_nsa = {}


def get_parameter_value_from_message(ue_id, general_flow_alias='Established_PDU_UE',
                                     message_alias='RRCReconfiguration',
                                     parameter_value='startingPRB'):
    message = get_flow(general_flow_alias + ue_id).get_message(message_alias)
    try:
        parameter_value_list = message.get_all_values_by_key(parameter_value)
        last_paramater_value = parameter_value_list[-1]
    except NotFoundKey:
        raise NotFoundKey('problem with fields in message')

    logger.info('UE:{}, parameter:{}, values_list:{} '.format(ue_id, parameter_value, parameter_value_list),
                also_console=True)
    logger.info('UE:{}, parameter:{}, last_value:{} '.format(ue_id, parameter_value, last_paramater_value),
                also_console=True)

    return last_paramater_value


def create_ue_aliases_in_loop(sa_ue_amount, nsa_ue_amount, sa_ue_first_id, nsa_ue_first_id):
    sa_ue_amount = int(sa_ue_amount)
    nsa_ue_amount = int(nsa_ue_amount)
    sa_ue_first_id = int(sa_ue_first_id)
    nsa_ue_first_id = int(nsa_ue_first_id)
    for ue in range(sa_ue_first_id, sa_ue_first_id + sa_ue_amount):
        if sa_ue_amount != 0:
            ta_messaging().create_ue_alias(alias='UE' + str(ue), ue_id=ue, id_type='wts_5g')
    for ue in range(nsa_ue_first_id, nsa_ue_first_id + nsa_ue_amount):
        if nsa_ue_amount != 0:
            ta_messaging().create_ue_alias(alias='UE' + str(ue), ue_id=ue, id_type='wts_5g')


def convert_pcap_to_txt(log_file):
    if re.search(r'.[pP]cap', log_file):
        os.system('tshark -V -r %s > %s' % (log_file, re.sub('[pP]cap', 'txt', log_file)))
        return re.sub('[pP]cap', 'txt', log_file)


def convert_pcap_to_json_using_tshark(
    pcap_path, message_filter=None, output_dir=None, output_filename=None
):
    """
    Converts a pcap file to a JSON file using tshark.

    Args:
        pcap_path (str): The path to the pcap file.
        message_filter (str, optional): The filter to apply to the pcap file. Defaults to None.
        output_dir (str, optional): The directory to save the output JSON file. Defaults to None.
        output_filename (str, optional): The name of the output JSON file. Defaults to None.

    Returns:
        str: The path to the converted JSON file.
    """
    file_name = os.path.basename(pcap_path)
    dir_name = os.path.dirname(pcap_path)
    if output_dir is None:
        output_dir = dir_name
    if output_filename is None:
        file_name = file_name.replace("pcap", "json")
    else:
        if output_filename.endswith(".json"):
            file_name = output_filename
        else:
            file_name = output_filename + ".json"
    output_path = os.path.join(output_dir, file_name)
    if not message_filter:
        os.system(
            f'tshark -r "{pcap_path}" -T json --no-duplicate > {output_path}'
        )
    else:
        command = f'tshark -Y "{message_filter}" -r {pcap_path} -T json --no-duplicate > {output_path}'
        logger.info(command)
        os.system(command)
    logger.info(
        f".pcap file was converted to .json file to path: {output_path}"
    )
    return output_path


def find_all_values_in_json_with_regex(json_file, pattern):
    """
    Extracts all values from a JSON string using a regular expression pattern.

    :param json_file: The JSON file.
    :param pattern: The regex pattern to match the desired values.
    :return: A list of all matched values. Returns an empty list if no matches are found.
    """
    with open(json_file, 'r') as file:
        json_data = json.load(file)

    # Convert the JSON data to a string
    json_string = json.dumps(json_data)

    # Find all matches of the pattern in the JSON string using re.DOTALL to include new lines
    matches = re.findall(pattern, json_string, re.DOTALL)

    logger.info(matches)
    # Return the list of matches
    return matches


def get_proper_regex(ue_type, parameter, ue_id, expected_starting_prb, expected_secondhop_prb):
    regex = ""
    if ue_type.upper() == "SA":
        if parameter == "startingPRB":
            regex = r"WTS\D+UEC\D+ProxyProto.*?UE\s+Id:\s+{}.*?rrcReconfiguration.*?startingPRB:\D+({})".format(
                ue_id, expected_starting_prb)
        elif parameter == "secondHopPRB":
            regex = r"WTS\D+UEC\D+ProxyProto.*?UE\s+Id:\s+{}.*?rrcReconfiguration.*?secondHopPRB:\D+({})".format(
                ue_id, expected_secondhop_prb)
        else:
            logger.error("Please provide either startingPRB or secondHopPRB value.")
            return
    if ue_type.upper() == "NSA":
        if parameter == "startingPRB":
            regex = r"SgNBAdditionRequestAcknowledge.*?startingPRB:\D(\d+)"
        elif parameter == "secondHopPRB":
            regex = r"SgNBAdditionRequestAcknowledge.*?secondHopPRB:\D(\d+)"
        else:
            logger.error("Please provide either startingPRB or secondHopPRB value.")
            return
    return regex


def find_starting_or_second_hop_prb(
        file_name, parameter, ue_type, ue_id, expected_starting_prb, expected_secondhop_prb):
    log_dirpath = ta5g_interface_tools().get_robot_output_dir()
    log_file = log_dirpath + "/" + file_name + ".pcap"
    convert_pcap_to_txt(log_file)
    file_txt = log_dirpath + "/" + file_name + ".txt"
    regex = get_proper_regex(ue_type, parameter, ue_id, expected_starting_prb, expected_secondhop_prb)

    with open(file_txt, 'r') as my_file:
        try:
            all_messages = my_file.read().replace('\n', '')
            # Find startingPRB of specific UE parsing pcap from eth4 with AP information about UE id
            starting_prb = re.findall(regex, all_messages)[0]
            return int(starting_prb)
        except IndexError:
            logger.error("startingPRB from rrcReconfiguration message couldn't be found in provided file.")


def find_file_in_directory(pattern):
    log_dirpath = OperatingSystem().join_path(
            ta5g_interface_tools().get_robot_output_dir(), ta5g_interface_tools().get_robot_test_name(), 'tshark'
        )
    for root, dirs, files in os.walk(log_dirpath):
        for file in files:
            if re.match(pattern, file):
                path_to_file = os.path.join(root, file)
                return path_to_file


def find_cell_setup_req_message_in_syslog():
    pattern = re.compile(r'cp_rt.*?Sent\s+to\s+L2PS.*?CellSetupReq_t')
    file_path = find_file_in_directory(pattern=r"default_syslog_enb\D+.log")

    for i, line in enumerate(open(file_path, 'r')):
        for match in re.finditer(pattern, line):
            if match:
                logger.info("Successfully found CellSetupReq message in syslog", also_console=True)
                logger.info('Found on line %s: %s' % (i + 1, match.group()))
                return True
            else:
                logger.error("CellSetupReq message was not found in syslog")
                return False


def open_file_and_check_value(feature_flag_activated, file_txt, regex, expected_number):
    with open(file_txt, 'r') as my_file:
        try:
            all_messages = my_file.read().replace('\n', '')
            # Find longPucchStartDynPuschPrb equals 6 for feature flag on and equals 0/null for feature flag off
            long_pusch_prb = re.findall(regex, all_messages)
            if feature_flag_activated:
                if expected_number in long_pusch_prb:
                    return True
                else:
                    return False
            if not feature_flag_activated:
                check_value = True
                # If feature flag deactivated - all longPucchStartDynPuschPrb must have value equal to 0
                for value in long_pusch_prb:
                    if value != '0':
                        check_value = False
                return check_value

        except IndexError:
            logger.error("longPucchStartDynPuschPrb message couldn't be found in provided file.")


def find_long_pucch_start_dyn_pusch_prb(file_name, expected_number, bwp_type='dedicated',
                                        feature_flag_activated=False):
    file_path = find_file_in_directory(pattern=file_name)
    convert_pcap_to_txt(file_path)
    file_txt = find_file_in_directory(pattern=file_name + '.txt')

    if not feature_flag_activated:
        regex = r"bwpType \(itf_l2_ps_cell_BwpType\): {} \(\d+\).*?longPucchStartDynPuschPrb" \
                r"\s+\(StaticVariableSizedArray\)\s+Length\s+\(Uint32\):\s+({})".format(bwp_type, expected_number)

    else:
        regex = r"bwpType \(itf_l2_ps_cell_BwpType\): dedicated \(\d+\).*?longPucchStartDynPuschPrb\s+" \
                r"\(StaticOptional\)\s+Length\s+\(Uint32\):\s+.*?longPucchStartDynPuschPrb" \
                r"_item_0\s+\(Uint16\):\s+({})".format(expected_number)

    prb_value = open_file_and_check_value(
        expected_number=expected_number, file_txt=file_txt, regex=regex, feature_flag_activated=feature_flag_activated)
    return prb_value


def get_PRB_value_and_assert_if_is_correct(packet_filter, prb, alias=None, subcase=None, expected_value=None):
    tshark_instance = ta5g_tshark()
    output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
    test_dir = BuiltIn().get_variable_value('${TEST_NAME}')
    PRB_values = tshark_instance.get_attribute_values_from_tshark_messages(
        alias=alias,
        filter=packet_filter,
        output_pdml_filepath="{}/converted_pcap.pdml".format(output_dir),
        element_xpath="//*[@name='nr-rrc.resourceToAddModList']/*/*/*[@name='nr-rrc.{}']".format(prb),
        attribute_xpath=".",
        attribute="show",
        pcap_file_path="{}/{}/tshark/{}_gnb_F1_E1_RRC.pcap".format(output_dir, test_dir, subcase)
    )
    assert int(PRB_values[-1]) == int(expected_value), 'Value of {} is {}, expected value is {}'.format(prb,
                                                                                                        PRB_values[-1],
                                                                                                        expected_value)


def get_PRB_value(packet_filter, prb, alias=None, subcase=None):
    tshark_instance = ta5g_tshark()
    output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
    test_dir = BuiltIn().get_variable_value('${TEST_NAME}')
    PRB_values = tshark_instance.get_attribute_values_from_tshark_messages(
        alias=alias,
        filter=packet_filter,
        output_pdml_filepath="{}/converted_pcap.pdml".format(output_dir),
        element_xpath="//*[@name='nr-rrc.resourceToAddModList']/*/*/*[@name='nr-rrc.{}']".format(prb),
        attribute_xpath=".",
        attribute="show",
        pcap_file_path="{}/{}/tshark/{}_gnb_F1_E1_RRC.pcap".format(output_dir, test_dir, subcase)
    )
    return PRB_values[-1]


def get_ue_f1ap_id_value(packet_filter, alias=None, subcase=None):
    tshark_instance = ta5g_tshark()
    output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
    test_dir = BuiltIn().get_variable_value('${TEST_NAME}')
    ue_f1ap_id = tshark_instance.get_attribute_values_from_tshark_messages(
        alias=alias,
        filter=packet_filter,
        output_pdml_filepath="{}/converted_pcap.pdml".format(output_dir),
        element_xpath="//*[@name='f1ap.protocolIEs']/*/*/*/*[@name='f1ap.GNB_CU_UE_F1AP_ID']",
        attribute_xpath=".",
        attribute="show",
        pcap_file_path="{}/{}/tshark/{}_gnb_F1_E1_RRC.pcap".format(output_dir, test_dir, subcase)
    )
    return ue_f1ap_id[-1]


def attach_multiple_ues_and_establish_pdu_sessions_with_prb_defining(first_ue, last_ue):
    global startingPRB_ue_list_sa
    global secondHopPRB_ue_list_sa
    global ue_f1ap_id_list_sa
    global ue_dict_sa
    startingPRB_ue_list_sa = []
    secondHopPRB_ue_list_sa = []
    ue_f1ap_id_list_sa = []
    ue_dict_sa = {}
    ue_index_in_list = 0
    output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
    test_dir = BuiltIn().get_variable_value('${TEST_NAME}')
    tshark_instance = ta5g_tshark()
    ue_mobility_instance = ta5g_ue_mobility()
    output = '{}/{}'.format(output_dir, test_dir)
    for index in range(int(first_ue), int(last_ue)+1):
        tshark_instance.start_pcaps_collection_for_test_subcase(output_dirpath=output,
                                                                subcase_name='Attach_Pdu_Session_UE_{}'.format(index))
        ue_mobility_instance.attach_ue(ue_id=index)
        ue_mobility_instance.establish_pdu_session(ue_id=index, pdu_id=1, gw_id=index)
        startingPRB_ue_list_value = get_PRB_value(
            packet_filter='(nr-rrc.rrcReconfiguration_element) && nr-rrc.startingPRB', prb='startingPRB',
            alias='tcpdump_subcase', subcase='Attach_Pdu_Session_UE_{}'.format(index))
        secondHopPRB_ue_list_value = get_PRB_value(
            packet_filter='(nr-rrc.rrcReconfiguration_element) && nr-rrc.startingPRB', prb='secondHopPRB',
            alias='tcpdump_subcase', subcase='Attach_Pdu_Session_UE_{}'.format(index))
        ue_f1ap_id = get_ue_f1ap_id_value(
            packet_filter='(nr-rrc.rrcReconfiguration_element) && nr-rrc.startingPRB',
            alias='tcpdump_subcase', subcase='Attach_Pdu_Session_UE_{}'.format(index))
        tshark_instance.stop_pcaps_collection_for_test_subcase()
        startingPRB_ue_list_sa.append(startingPRB_ue_list_value)
        secondHopPRB_ue_list_sa.append(secondHopPRB_ue_list_value)
        ue_f1ap_id_list_sa.append(ue_f1ap_id)
        ue_dict_sa[str(index)] = ue_index_in_list
        ue_index_in_list += 1
    return (startingPRB_ue_list_sa, secondHopPRB_ue_list_sa, ue_f1ap_id_list_sa)


def attach_multiple_ues_and_start_gnb_addition_with_prb_defining(first_ue, last_ue, target_cells=1,
                                                                 gnb_triggered=True):
    global startingPRB_ue_list_nsa
    global secondHopPRB_ue_list_nsa
    global ue_f1ap_id_list_nsa
    global ue_dict_nsa
    startingPRB_ue_list_nsa = []
    secondHopPRB_ue_list_nsa = []
    ue_f1ap_id_list_nsa = []
    ue_dict_nsa = {}
    ue_index_in_list = 0
    output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
    test_dir = BuiltIn().get_variable_value('${TEST_NAME}')
    tshark_instance = ta5g_tshark()
    ue_mobility_instance = ta5g_ue_mobility()
    ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')
    output = '{}/{}'.format(output_dir, test_dir)
    for index in range(int(first_ue), int(last_ue)+1):
        tshark_instance.start_pcaps_collection_for_test_subcase(output_dirpath=output,
                                                                subcase_name='Attach_Gnb_Addition_UE_{}'.format(index))
        if gnb_triggered:
            ute_wtssim_instance.execute_egate_command(cmd='ue_enb_param id={} drx_config=off measurement_gap=gp0:10 \
                gap_trigger=gnb_triggered mgta=ms0dot50 gap_purpose=perUE'.format(index))
        else:
            ute_wtssim_instance.execute_egate_command(cmd='ue_enb_param id={} drx_config=off \
                measurement_gap=gp0:10'.format(index))

        # Timer required for TSark collectors to get properly set up
        time.sleep(10)

        ue_mobility_instance.attach_ue_to_enb(ue_id=index, optional_parameters='profile=1')

        ue_mobility_instance.start_gnb_addition_procedure(
            ue=index, target_gnb=2, target_cells=target_cells, bearer=2,
            dc_type='split_scg', timeout=10,
            pass_regexp='Proxy \\(eNB 2 cell {}\\) reported successful RA'.format(target_cells))
        time.sleep(5)
        startingPRB_ue_list_value = get_PRB_value(
            packet_filter='nr-rrc.startingPRB && x2ap.SgNBAdditionRequestAcknowledge_element', prb='startingPRB',
            alias='tcpdump_subcase', subcase='Attach_Gnb_Addition_UE_{}'.format(index))
        secondHopPRB_ue_list_value = get_PRB_value(
            packet_filter='nr-rrc.startingPRB && x2ap.SgNBAdditionRequestAcknowledge_element', prb='secondHopPRB',
            alias='tcpdump_subcase', subcase='Attach_Gnb_Addition_UE_{}'.format(index))
        ue_f1ap_id = get_ue_f1ap_id_value(
            packet_filter='nr-rrc.startingPRB && f1ap.GNB_CU_UE_F1AP_ID && f1ap.UEContextSetupResponse_element',
            alias='tcpdump_subcase', subcase='Attach_Gnb_Addition_UE_{}'.format(index))
        tshark_instance.stop_pcaps_collection_for_test_subcase()
        startingPRB_ue_list_nsa.append(startingPRB_ue_list_value)
        secondHopPRB_ue_list_nsa.append(secondHopPRB_ue_list_value)
        ue_f1ap_id_list_nsa.append(ue_f1ap_id)
        ue_dict_nsa[str(index)] = ue_index_in_list
        ue_index_in_list += 1
    return (startingPRB_ue_list_nsa, secondHopPRB_ue_list_nsa, ue_f1ap_id_list_nsa)


def get_prb_value_of_given_ue_sa(ue_id, prb):
    if prb == 'startingPRB':
        return startingPRB_ue_list_sa[ue_dict_sa[ue_id]]
    elif prb == 'secondHopPRB':
        return secondHopPRB_ue_list_sa[ue_dict_sa[ue_id]]


def get_prb_value_of_given_ue_nsa(ue_id, prb):
    if prb == 'startingPRB':
        return startingPRB_ue_list_nsa[ue_dict_nsa[ue_id]]
    elif prb == 'secondHopPRB':
        return secondHopPRB_ue_list_nsa[ue_dict_nsa[ue_id]]


def get_f1ap_ue_nsa_id_value(ue_id):
    return ue_f1ap_id_list_nsa[ue_dict_nsa[ue_id]]


def get_f1ap_ue_sa_id_value(ue_id):
    return ue_f1ap_id_list_sa[ue_dict_sa[ue_id]]


def create_rrcReconfiguration_filter_with_new_prb_values_after_hkf_and_f1ap_id(ue_f1ap_id, startingPRB, secondHopPRB):
    return 'nr-rrc.rrcReconfiguration_element && f1ap.GNB_CU_UE_F1AP_ID=={} && \
    nr-rrc.startingPRB=={} && nr-rrc.secondHopPRB=={}'.format(ue_f1ap_id, startingPRB, secondHopPRB)


def create_UEContextModificationRequired_filter_with_new_prb_values_after_hkf_and_f1ap_id(ue_f1ap_id, startingPRB,
                                                                                          secondHopPRB):
    return 'f1ap.UEContextModificationRequired_element && f1ap.GNB_CU_UE_F1AP_ID=={} && nr-rrc.startingPRB=={} && \
    nr-rrc.secondHopPRB=={}'.format(ue_f1ap_id, startingPRB, secondHopPRB)


def create_rrcReconfiguration_filter_with_new_prb_values_after_hkf_and_resourceToAddModList(startingPRB, secondHopPRB):
    return 'nr-rrc.rrcReconfiguration_element && nr-rrc.startingPRB=={} && nr-rrc.secondHopPRB=={} && \
    nr-rrc.resourceToAddModList == 1'.format(startingPRB, secondHopPRB)


def create_UEContextModificationRequired_filter_with_new_prb_values_after_hkf_and_resourceToAddModList(startingPRB,
                                                                                                       secondHopPRB):
    return 'f1ap.UEContextModificationRequired_element && nr-rrc.startingPRB=={} && nr-rrc.secondHopPRB=={} && \
    nr-rrc.resourceToAddModList == 1 && nr-rrc.cellGroupId == 1'.format(startingPRB, secondHopPRB)


def return_startingPRB_ue_list_sa():
    return startingPRB_ue_list_sa


def return_startingPRB_ue_list_nsa():
    return startingPRB_ue_list_nsa


def return_secondHopPRB_ue_list_sa():
    return secondHopPRB_ue_list_sa


def return_secondHopPRB_ue_list_nsa():
    return secondHopPRB_ue_list_nsa
