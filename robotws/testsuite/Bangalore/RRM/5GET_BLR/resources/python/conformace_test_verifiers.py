from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.String import String
from robot.libraries.Collections import Collections
from luashark_tools import analyzer
from robot.api.logger import info
from taf.transport.ssh import ssh
from collections import defaultdict
from taf.sbts.oam.coam.admin import admin


def check_information_element_message_decimal_pucch(message, message_ie_dictionary, pdml_file,
                                                    sw_version, num_of_packet=1):
    err_log_message = "For {0} , expected was ({1}) obtained was ({2})"
    msg_dict = defaultdict()
    for k in message_ie_dictionary:
        if k.startswith("UlData_PucchReceiveReq") and "pucchResources_item_0" not in k:
            msg_dict[k.format(return_release_version_with_resources_item_id(sw_version))] = message_ie_dictionary[k]

    for key in dict(msg_dict).keys():
        ret_value = analyzer().get_unique(pdmlFile=pdml_file,
                                          packetName=message,
                                          path="{}$".format(key),
                                          startPacket=num_of_packet,
                                          endPacket=num_of_packet)
        if key == 'DlData_PdschSendReq.i1Codebook4AntPorts.i1Codebook4AntPorts':
            check_a_case(key, dict(msg_dict)[key], ret_value, True)
            continue
        if key == 'DlData_PdschSendReq.ceAxCIndex.ceAxCIndex':
            check_a_case(key, dict(msg_dict)[key], ret_value, False)
            continue

        comp_normalized_hexa = normalized_hexadecimal_values(ret_value)
        comp = compare_values_in_decimal(comp_normalized_hexa, dict(msg_dict)[key])
        BuiltIn().should_be_true(comp, msg=err_log_message.format(key, dict(msg_dict)[key], ret_value))


def check_beam_pattern(message, message_ie_dictionary, pdml_file, beam_pattern="0x000000c8",
                       num_of_packet=2):
    err_log_message = "For {0} , expected was ({1}) obtained was ({2})"
    beam_pattern_id = [bytes(beam_pattern)]
    for key in message_ie_dictionary.keys():
        ret_value = get_unique(pdmlFile=pdml_file, packetName=message, path="{}$".format(key),
                               startPacket=num_of_packet, endPacket=num_of_packet)
        if key == 'UlData_PucchReceiveReq.patternId.patternId_item_0':
            comp_normalized_hexa = normalized_hexadecimal_values(ret_value)
            comp = compare_values_in_decimal_within_a_list(comp_normalized_hexa, beam_pattern_id)
            if comp is False:
                continue
            else:
                verifier = True
            BuiltIn().should_be_true(verifier, msg=err_log_message.format(key, beam_pattern_id, ret_value))


def check_information_element_message_decimal_for_test_models(message,
                                                              message_ie_dictionary,
                                                              pdml_file,
                                                              tm,
                                                              bw,
                                                              num_of_packet=1):

    err_log_message = "For {0} , expected was ({1}) obtained was ({2})"

    acceptable_values_tm2a_50mhz = [b'0x00000000', b'0x00000042', b'0x00000084']
    acceptable_values_tm2a_70mhz = [b'0x00000000', b'0x0000005e', b'0x000000bc']
    acceptable_values_tm2a_90mhz = [b'0x00000000', b'0x0000007a', b'0x000000f4']

    acceptable_values_tm2_50mhz = [b'0x00000000', b'0x00000042', b'0x00000084']
    acceptable_values_tm2_70mhz = [b'0x00000000', b'0x0000005e', b'0x000000bc']
    acceptable_values_tm2_90mhz = [b'0x00000000', b'0x0000007a', b'0x000000f4']

    for key in message_ie_dictionary.keys():
        ret_value = analyzer().get_unique(pdmlFile=pdml_file,
                                          packetName=message,
                                          path="{}$".format(key),
                                          startPacket=num_of_packet,
                                          endPacket=num_of_packet)

        if key == 'DlData_PdschSendReq.i1Codebook4AntPorts.i1Codebook4AntPorts':
            check_a_case(key, message_ie_dictionary[key], ret_value, True)
            continue
        if key == 'DlData_PdschSendReq.ceAxCIndex.ceAxCIndex':
            check_a_case(key, message_ie_dictionary[key], ret_value, False)
            continue

        if key == 'DlData_PdschSendReq.grants_item_15.startPrb' and tm == 'TM2':
            comp_normalized_hexa = normalized_hexadecimal_values(ret_value)
            if bw == '50MHz':
                comp = compare_values_in_decimal_within_a_list(comp_normalized_hexa, acceptable_values_tm2_50mhz)
                BuiltIn().should_be_true(comp, msg=err_log_message.format(key,
                                                                          acceptable_values_tm2_50mhz,
                                                                          ret_value))
            elif bw == "70MHz":
                comp = compare_values_in_decimal_within_a_list(comp_normalized_hexa, acceptable_values_tm2_70mhz)
                BuiltIn().should_be_true(comp, msg=err_log_message.format(key,
                                                                          acceptable_values_tm2_70mhz,
                                                                          ret_value))
            else:
                comp = compare_values_in_decimal_within_a_list(comp_normalized_hexa, acceptable_values_tm2_90mhz)
                BuiltIn().should_be_true(comp, msg=err_log_message.format(key,
                                                                          acceptable_values_tm2_90mhz,
                                                                          ret_value))

        elif key == 'DlData_PdschSendReq.grants_item_15.startPrb' and tm == 'TM2A':
            comp_normalized_hexa = normalized_hexadecimal_values(ret_value)
            if bw == '50MHz':
                comp = compare_values_in_decimal_within_a_list(comp_normalized_hexa, acceptable_values_tm2a_50mhz)
                BuiltIn().should_be_true(comp, msg=err_log_message.format(key,
                                                                          acceptable_values_tm2a_50mhz,
                                                                          ret_value))
            elif bw == "70MHz":
                comp = compare_values_in_decimal_within_a_list(comp_normalized_hexa, acceptable_values_tm2a_70mhz)
                BuiltIn().should_be_true(comp, msg=err_log_message.format(key,
                                                                          acceptable_values_tm2a_70mhz,
                                                                          ret_value))
            else:
                comp = compare_values_in_decimal_within_a_list(comp_normalized_hexa, acceptable_values_tm2a_90mhz)
                BuiltIn().should_be_true(comp, msg=err_log_message.format(key,
                                                                          acceptable_values_tm2a_90mhz,
                                                                          ret_value))
        else:
            comp_normalized_hexa = normalized_hexadecimal_values(ret_value)
            comp = compare_values_in_decimal(comp_normalized_hexa, message_ie_dictionary[key])
            BuiltIn().should_be_true(comp, msg=err_log_message.format(key, message_ie_dictionary[key], ret_value))


def transform_in_hexa(pdml_value, reverse):
    if reverse:
        val = BuiltIn().evaluate("0x00000" + "".join(reversed(pdml_value.split(":")[:2])))
    else:
        val = BuiltIn().evaluate("0x00000" + "".join(pdml_value.split(":")[:2]))
    return val


def check_a_case(key, expected_value, pdml_value, reverse):
    comp_normalized_hexa = transform_in_hexa(pdml_value=pdml_value, reverse=reverse)
    convert_to_integer = BuiltIn().convert_to_integer(comp_normalized_hexa)
    BuiltIn().should_be_equal(first=expected_value, second=convert_to_integer,
                              msg="For {0} , expected was ({1}) obtained was ({2})".format(key,
                                                                                           expected_value,
                                                                                           convert_to_integer))


def normalized_hexadecimal_values(string_variable, reverse=True, digit=2):
    """
    Return a string normalized in hexa
    In some cases, wireshark reverse bytes
    Also, in some other cases, bytes are doubled
    This service perform the reverse operation to provide a normalized hexa value
    So, this service :
    -	Extension to 4 digits
    -	Reverse 2 first digits and 2 last digits
    -	Reverse 1 and 2, then 3 and 4  (if reverse is True)
    -	Take (N) digits
    -	Prefix with 0x
    Examples :
        toNormalizedHexa(bc:01:bc:01,reverse=True ,digit=2)=0x01bc
        toNormalizedHexa(05:00:00   ,reverse=False,digit=4)=0x00000005
        toNormalizedHexa(00:01:00:00,reverse=False,digit=4)=0x00000001
    :param string_variable: reversed doubled hexa string
    :param reverse:
    :param digit:
    :return: normalized hexa string
    """
    digit = int(digit)
    list_bytes = string_variable.split(":")
    length = len(list_bytes)
    if length == 1:
        if string_variable.startswith("0x"):
            return string_variable
        try:
            int_val = int(string_variable)
        except Exception:
            BuiltIn().fail('Unable to normalize string [{}] in hexa'.format(string_variable))
        return hex(int_val)
    # Extension to 4 bytes
    if length < 4:
        list_bytes.insert(0, '00')
    if length < 3:
        list_bytes.insert(0, '00')
    # Swap 1-2 with 3-4
    list_bytes = [list_bytes[2], list_bytes[3], list_bytes[0], list_bytes[1]]
    # Reverse 1/2 and 3:4 on demand
    if reverse:
        list_bytes = [list_bytes[1], list_bytes[0], list_bytes[3], list_bytes[2]]
    # Take N last digit
    res = ""
    for i in range(digit):
        res = "{}".format(list_bytes[3 - i]) + res
    return "0x" + res


def compare_values_in_decimal(v1, v2):
    """
    Compare to values converted in decimal
    compareInDecimal("0x0000C", "12") will return True
    :param v1: first value to compare
    :param v2: second value to compare
    :return: status of comparison
    """
    return to_decimal_str(v1) == to_decimal_str(v2)


def compare_values_in_decimal_within_a_list(v1, list_of_values):
    return v1 in list_of_values


def to_decimal_str(string_to_convert):
    """
    Convert a string into a decimal if possible
    In particular, an hexa string will be converted into a decimal
    Ex : '0x000c'    will be converted into '12'
         '0x0000001' will be converted into '1'
         '0x0000'    will be converted into '0'
    :param string_to_convert: string to convert in decimal
    :return: string containing decimal value
    """
    if string_to_convert.isdigit():
        return "{}".format(int(string_to_convert, 10))
    if string_to_convert.isalnum():
        return "{}".format((int(string_to_convert, 16)))
    return "{}".format(string_to_convert)


def extract_num_of_prb_from_message(sw_version, pdml_file, packet):
    if packet.startswith("UlData_PucchReceiveReq"):
        num_of_prb = get_unique(pdmlFile=pdml_file, packetName=packet, path=".*numOfPrb$", endPacket=1)
        return num_of_prb if len(num_of_prb) > 0 else ""


def extract_num_of_prb_from_format(format_f, format_type, num_pucchsymbol):
    int_num_pucchsymbol = int(num_pucchsymbol, 0)
    if format_f == "F0" or format_f == "F1":
        num_of_prb = "0x00000001"
    elif format_f == "F2" and format_type == "Ack":
        num_of_prb = "0x00000004"
    elif format_f == "F2" and format_type == "Uci":
        num_of_prb = "0x00000009"
    elif format_f == "F3" and int_num_pucchsymbol == 14:
        num_of_prb = "0x00000001"
    elif format_f == "F3" and int_num_pucchsymbol == 4:
        num_of_prb = "0x00000003"

    return num_of_prb


def extract_first_symbol_based_on_num_of_symbols(num_of_symbols):
    if num_of_symbols == '0x00000001':
        return "0x0000000d"
    elif num_of_symbols == "0x00000002":
        return "0x0000000c"


def extract_freq_hopping_based_on_num_of_symbols(num_of_symbols):
    if num_of_symbols == '0x00000001':
        return "0x00000000"
    elif num_of_symbols == "0x00000002":
        return "0x00000001"


def extract_second_hop_prb_based_on_largest_prb_index(num_of_prb, largest_prb_index):
    int_num_of_prb = int(num_of_prb, 0)
    int_largest_prb_index = int(largest_prb_index, 0)
    second_hop_prb = int_largest_prb_index - (int_num_of_prb - 1)
    hex_string_value = "0x0000000" + hex(second_hop_prb).split("x")[1]
    return hex_string_value


def convert_value_to_hex(value):
    value_int = int(value)
    hex_value = "0x000000" + hex(value_int).split("x")[1]
    return hex_value


def get_filtered_pdml_file_from_pcap(pcap_file, filter_exp=None):
    analyzer_obj = analyzer()
    filter_pcap = analyzer_obj.filter_pcap(pcapInFile=pcap_file, filterName=filter_exp,
                                           filterExp=filter_exp)
    pdml_file = analyzer_obj.pcap_to_pdml(pcapFile=filter_pcap)

    return pdml_file


def def_value():
    return "Not Present"


def get_unique(pdmlFile, packetName=None, filter="", path=None,
               kind="show", startPacket=1, endPacket=-1):
    """
        Return value of a unique path in some particular packet
        :param pdmlFile: path of pdml file to parse
        :param packetName: name of packet to retrieve
        :param path: regular expression of paths to retrieve
        :param kind: kind of field to get
               should be one of : "show", "showname" or "value"
        :param startPacket: index of starting packet to be considered
        :param endPacket: index of ending packet to be considered
        ERROR : if pdml file does not exist
        ERROR : if no packet matching <packetName> is found
        ERROR : if number of occurences of matching paths is not equal to 1
    """

    analyzer_obj = analyzer()
    print("GET_UNIQUE:PACKET:{} Path:{} KIND:{}".format(packetName, path, kind))
    list_sub_packet = analyzer_obj.get_match_from_path(pdmlFile=pdmlFile, packetName=packetName, filter=filter,
                                                       path=path, startPacket=startPacket, endPacket=endPacket)
    value = ""
    matching_packet_in_bounds = 0
    for idx, sub_packet in enumerate(list_sub_packet):
        matching_packet_in_bounds = matching_packet_in_bounds + 1
        matching_field = 0
        for idy, path in enumerate(sub_packet.fields.keys()):
            matching_field = matching_field + 1
            prefix_str = sub_packet.prefixStr(idx, idy)
            sub_packet.printWithPrefix(prefix_str, path)
            value = get_value_from_kind(sub_packet.fields[path], kind)
            print("{}{}[{}] = '{}'".format(prefix_str, last_elt_from_path(path), kind, value))
    if len(value) == 0:
        print("Found no Path (expected 1)")
    print(matching_packet_in_bounds != 1, "Found {} packet (expected 1)".format(len(list_sub_packet)))
    return value


def get_value_from_kind(field, kind):
    if kind == "show":
        return field.show
    elif kind == "showname":
        return field.showname
    return field.value


def get_slot_type_ru_mode(slot, ru_mode):
    list_of_acceptable_values = [57, 56, 31]
    slot_int = int(slot)
    if ru_mode == "NR_only":
        if 0 <= slot_int <= 6 or 10 <= slot_int <= 16:
            return list_of_acceptable_values[0]
        elif slot_int == 7 or slot_int == 17:
            return list_of_acceptable_values[1]
        elif slot_int == 8 or slot_int == 18 or slot_int == 9 or slot_int == 19:
            return list_of_acceptable_values[2]
    elif ru_mode == "MSR":
        if 0 <= slot_int <= 2 or 8 <= slot_int <= 12 or slot_int in [18, 19]:
            return list_of_acceptable_values[0]
        elif slot_int in [3, 13]:
            return list_of_acceptable_values[1]
        elif 4 <= slot_int <= 7 or 14 <= slot_int <= 17:
            return list_of_acceptable_values[2]
    else:
        return slot_int


def get_slot_type_ru_mode_tm2_2a(slot, ru_mode):
    list_of_acceptable_values = [33, 51, 31]
    slot_int = int(slot)
    if ru_mode == "NR_only":
        if 0 <= slot_int <= 6 or 10 <= slot_int <= 16:
            return list_of_acceptable_values[0]
        elif slot_int == 7 or slot_int == 17:
            return list_of_acceptable_values[1]
        elif slot_int == 8 or slot_int == 18 or slot_int == 9 or slot_int == 19:
            return list_of_acceptable_values[2]
    elif ru_mode == "MSR":
        if 0 <= slot_int <= 2 or 8 <= slot_int <= 12 or slot_int in [18, 19]:
            return list_of_acceptable_values[0]
        elif slot_int in [3, 13]:
            return list_of_acceptable_values[1]
        elif 4 <= slot_int <= 7 or 14 <= slot_int <= 17:
            return list_of_acceptable_values[2]
    else:
        return slot_int


def get_slot_type_from_slot_tdd(slot, ru_mode):
    return get_slot_type_ru_mode(slot, "NR_only") if int(ru_mode) == 0 else get_slot_type_ru_mode(slot, "MSR")


def get_slot_type_from_slot_tdd_tm2_2a(slot, ru_mode):
    if int(ru_mode) == 0:
        return get_slot_type_ru_mode_tm2_2a(slot, "NR_only")
    else:
        return get_slot_type_ru_mode_tm2_2a(slot, "MSR")


def get_slot_type_from_slot_fdd(slot):
    return 57 if 0 <= slot <= 9 else -1


def last_elt_from_path(path):
    return path.split("/")[-1]


def split_elements(compacted_list):
    """
    :param compacted_list: list containing all robot arguments

    :return: Returns splitted list
              [reporting_int, beamPatternId, pucch_format, ru_mode, pci, format_2_test_type,
              pucch_payload_content, num_payload_bit, run_time_id, numPucchSymbol]
    """
    list_of_arguments = ["reporting_int", "beamPatternId", "pucch_format", "ru_mode", "pci", "format_2_test_type",
                         "pucch_payload_content", "num_payload_bit", "run_time_id", "numPucchSymbol"]

    splitted_list = compacted_list.split(", ")
    dict_args = defaultdict()
    for index, elements in enumerate(list_of_arguments, start=0):
        dict_args[elements] = splitted_list[index]
    return dict(dict_args)


def extract_cprt_node_id(list_of_nodes):
    for node in list_of_nodes:
        if node.name == "CPRT":
            return node.nodeId


def return_release_version_with_resources_item_id(sw_build_version):
    """
    Returns the ID of pucch resources item based on 5G SW release in use
    :param sw_build_version: build version
    :return: returns pucch resources item ID based on sw release
    """

    if sw_build_version.startswith("5G21A") or sw_build_version.startswith("5G21B"):
        return "175"
    elif sw_build_version.startswith("SBTS"):
        return "175"
    elif sw_build_version.startswith("5G20B"):
        return "85"
    else:
        return "85"


def check_information_element_message_decimal(message, message_ie_dictionary, pdml_file, num_of_packet=1):

    err_log_message = "For {0} , expected was ({1}) obtained was ({2})"
    for key in message_ie_dictionary.keys():
        ret_value = analyzer().get_unique(pdmlFile=pdml_file,
                                          packetName=message,
                                          path="{}$".format(key),
                                          startPacket=num_of_packet,
                                          endPacket=num_of_packet)

        if key == 'DlData_PdschSendReq.i1Codebook4AntPorts.i1Codebook4AntPorts':
            check_a_case(key, message_ie_dictionary[key], ret_value, True)
            continue
        if key == 'DlData_PdschSendReq.ceAxCIndex.ceAxCIndex':
            check_a_case(key, message_ie_dictionary[key], ret_value, False)
            continue

        comp_normalized_hexa = normalized_hexadecimal_values(ret_value)
        comp = compare_values_in_decimal(comp_normalized_hexa, message_ie_dictionary[key])
        BuiltIn().should_be_true(comp, msg=err_log_message.format(key, message_ie_dictionary[key], ret_value))


def get_slot_type_from_slot_mode(slot, ru_mode, scs):
    """
    Returns the Slot type based on ruMode

    :param slot:
    :param ru_mode:
    :param scs:
    :return: Returns the Slot type based on ruMode which depends on cell technology
    """
    if scs == "30":
        return get_slot_type_from_slot_tdd(slot, ru_mode)
    else:
        return get_slot_type_from_slot_fdd(slot)


def get_slot_type_from_slot_mode_tm2_2a(slot, ru_mode, scs):
    """
    Returns the Slot type based on ruMode

    :param slot:
    :param ru_mode:
    :param scs:
    :return: Returns the Slot type based on ruMode which depends on cell technology
    """
    if scs == "30":
        return get_slot_type_from_slot_tdd_tm2_2a(slot, ru_mode)
    else:
        pass


def verify_the_slot_type(pdml, path_list, ru_mode, scs, slot_path, slot_type_path):
    list_packet = analyzer().get_match_from_paths(pdmlFile=pdml, packetName='DlData_SlotTypeReq',
                                                  pathList=path_list)
    for packet in list_packet[:19:1]:
        slot = BuiltIn().evaluate(packet.fields[slot_path].show)
        slot_type = BuiltIn().evaluate(packet.fields[slot_type_path].show)
        exp_slot_type = get_slot_type_from_slot_mode(slot, ru_mode, scs)
        BuiltIn().should_be_true("{0}=={1}".format(slot_type, exp_slot_type))


def verify_the_slot_type_tm2_2a(pdml, path_list, ru_mode, scs, slot_path, slot_type_path):
    list_packet = analyzer().get_match_from_paths(pdmlFile=pdml, packetName='DlData_SlotTypeReq',
                                                  pathList=path_list)
    for packet in list_packet[:19:1]:
        slot = BuiltIn().evaluate(packet.fields[slot_path].show)
        slot_type = BuiltIn().evaluate(packet.fields[slot_type_path].show)
        exp_slot_type = get_slot_type_from_slot_mode_tm2_2a(slot, ru_mode, scs)
        BuiltIn().should_be_true("{0}=={1}".format(slot_type, exp_slot_type))


def verify_information_elements_within_dldata_pdsch_sendreq(pdml_file,
                                                            list_packet_match,
                                                            verification_based_on_same_dictionary,
                                                            ue_id,
                                                            *args):
    """
    Verifies if encoded dictionaries matches the field_name:value in message DlData_PdschSendReq.

    :param pdml_file: PDML file object
    :param list_packet_match: list of packets for each rnti
    :param verification_based_on_same_dictionary: Bool variable defining which verification model execute
    :param ue_id: UE ID
    :param args: Test model value, encoded Dictionaries {args[1] ; args[2] ; args[3]}
                 Where:
                    args[0] = test Model Value;
                    args[1] = 1st dictionary
                    args[2] = 2nd dictionary
                    args[3] = 3rd dictionary
                    args[4] = UE ID 1
                    args[5] = UE ID 2
                    args[6] = UE ID 3
                    args[7] = bandwidth
    """
    n_packet = 1
    for packet in list_packet_match:
        rnti = get_value_in_packet_match(packet_match=packet, field='rnti')
        if verification_based_on_same_dictionary is not True:
            if rnti == '0x00000000' and args[0] == 'TM3_3':
                check_information_element_message_decimal(message="DlData_PdschSendReq",
                                                          message_ie_dictionary=args[1],
                                                          pdml_file=pdml_file,
                                                          num_of_packet=n_packet)
            elif rnti == '0x00000001' and args[0] == 'TM3_3':
                check_information_element_message_decimal(message="DlData_PdschSendReq",
                                                          message_ie_dictionary=args[2],
                                                          pdml_file=pdml_file,
                                                          num_of_packet=n_packet)
            elif rnti == '0x00000002' and args[0] == 'TM3_3':
                check_information_element_message_decimal(message="DlData_PdschSendReq",
                                                          message_ie_dictionary=args[3],
                                                          pdml_file=pdml_file,
                                                          num_of_packet=n_packet)
            else:
                BuiltIn().log_to_console(
                    "Rnti value: {0} and Test Model value: {1} not supported".format(rnti, args[0]))
        elif verification_based_on_same_dictionary is True:
            if rnti == '0x00000000' and '1' == ue_id:
                BuiltIn().log_to_console("n packet = {}".format(n_packet))
                check_information_element_message_decimal(message="DlData_PdschSendReq",
                                                          message_ie_dictionary=args[1],
                                                          pdml_file=pdml_file,
                                                          num_of_packet=n_packet)
            elif rnti == '0x00000001' and '2' == ue_id:
                BuiltIn().log_to_console("n packet = {}".format(n_packet))
                check_information_element_message_decimal(message="DlData_PdschSendReq",
                                                          message_ie_dictionary=args[2],
                                                          pdml_file=pdml_file,
                                                          num_of_packet=n_packet)
            elif rnti == '0x00000002' and '3' == ue_id:
                BuiltIn().log_to_console("n packet = {}".format(n_packet))
                check_information_element_message_decimal_for_test_models(message="DlData_PdschSendReq",
                                                                          message_ie_dictionary=args[3],
                                                                          pdml_file=pdml_file,
                                                                          tm=args[0],
                                                                          bw=args[7],
                                                                          num_of_packet=n_packet)
            else:
                BuiltIn().log_to_console("Rnti value: {0} and UE ID value: {1} not supported".format(rnti, ue_id))
        n_packet = BuiltIn().evaluate("{0} + 1".format(n_packet))


def verify_frc_index_value(frc_index):
    """
    Extracts frc_index from showname value of
    field name:itf_l2_ps_tm_cell_StartConformanceTestReq.receiverTestingConfig.frcIndex
    ex: "showname="frcIndex (Enum): 63 (itf_l2_ps_tm_EFrcIndex.G_FR1_A4_31)"
    :param args: frc_index.showname value
    :return: frc_index
    """
    frc_start = frc_index.find('G')
    frc_end = frc_index.find(')"')
    frc = frc_index[frc_start:frc_end]
    return frc


def verify_information_elements_based_on_same_dictionary(pdml_file,
                                                         list_packet_match,
                                                         ue_id,
                                                         *args):
    n_packet = 1
    for packet in list_packet_match:
        rnti = get_value_in_packet_match(packet_match=packet, field='rnti')
        if rnti == '0x00000000' and ue_id == '1':
            check_information_element_message_decimal(message="DlData_PdschSendReq",
                                                      message_ie_dictionary=args[1],
                                                      pdml_file=pdml_file,
                                                      num_of_packet=n_packet)
        elif rnti == '0x00000001' and ue_id == '2':
            check_information_element_message_decimal(message="DlData_PdschSendReq",
                                                      message_ie_dictionary=args[2],
                                                      pdml_file=pdml_file,
                                                      num_of_packet=n_packet)
        elif rnti == '0x00000002' and ue_id == '3':
            check_information_element_message_decimal_for_test_models(message="DlData_PdschSendReq",
                                                                      message_ie_dictionary=args[3],
                                                                      pdml_file=pdml_file,
                                                                      tm=args[0],
                                                                      bw=args[4],
                                                                      num_of_packet=n_packet)
        else:
            BuiltIn().log_to_console("Rnti value: {0} and UE ID value: {1} not supported".format(rnti, ue_id))
        n_packet = BuiltIn().evaluate("{0} + 1".format(n_packet))


def verify_information_elements_based_on_same_dictionary_aic(pdml_file, list_packet_match, ue_id, *args):
    n_packet = 1
    for packet in list_packet_match:
        rnti = get_value_in_packet_match(packet_match=packet, field='rnti')
        print(rnti)
        if rnti == '0x0000' and ue_id == '1':
            check_information_element_message_decimal(message="DlData_PdschSendReq",
                                                      message_ie_dictionary=args[1],
                                                      pdml_file=pdml_file,
                                                      num_of_packet=n_packet)
        elif rnti == '0x0002' and ue_id == '2':
            check_information_element_message_decimal(message="DlData_PdschSendReq",
                                                      message_ie_dictionary=args[2],
                                                      pdml_file=pdml_file,
                                                      num_of_packet=n_packet)
        elif rnti == '0x0003' and ue_id == '3':
            check_information_element_message_decimal_for_test_models(message="DlData_PdschSendReq",
                                                                      message_ie_dictionary=args[3],
                                                                      pdml_file=pdml_file,
                                                                      tm=args[0],
                                                                      bw=args[4],
                                                                      num_of_packet=n_packet)
        else:
            BuiltIn().log_to_console("Rnti value: {0} and UE ID value: {1} not supported".format(rnti, ue_id))
        n_packet = BuiltIn().evaluate("{0} + 1".format(n_packet))


def get_value_in_packet_match(packet_match, field):
    """
    Return value of a field retrieved in a packetMatch if not found, it return an empty string
    :param packet_match: name of the packet
    :param field: name of the field to find
    :return:
    """
    list_path = Collections().get_dictionary_keys(packet_match.fields)
    field = String().fetch_from_left(field, '$')
    for path in list_path:
        field_name = get_field_name_from_path(path)
        if field_name == field:
            return packet_match.fields[path].show


def get_field_name_from_path(path):
    """
    Retrieve from a full exhaustive path the the field name

    :param path: full name of message
    :return: returns the field name
    """
    pattern = '.*\\W(\\w*)$'
    short_key = String().get_regexp_matches(path, pattern, 1)
    return short_key[0]


def verify_hw_status(hw_node, alias, ccs_daemon_node_id):
    """
        check HW status

        :param string hw_node: board node number    0x12 or 0x10
        :param string alias: alias
        :param string ccs_daemon_node_id: CCS Daemon node id
        :return: bool True or False

        - Example::

              check_hw_status    0x12
    """
    csn = ssh()
    info("Start to check board status: \n")
    sys_result = csn.execute(
        "export PYTHONPATH=/opt/hwmt/python &&"
        " python3 /opt/hwmt/python/hwapi/AdetS.py -s -n {}|grep {}".format(
            ccs_daemon_node_id, hw_node), alias)
    if 'ready[0]' in sys_result:
        info("board in right status")
        return True
    else:
        info("Status is not ready", also_console=True)
        return False


def check_run_time_id():
    api = admin()
    connection = api.connect_to()
    result = connection.get_bts_info()
    run_time_id = result["id"]["internal"]
    return run_time_id[-1]
