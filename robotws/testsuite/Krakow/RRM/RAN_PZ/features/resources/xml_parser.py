from robot.api import logger
from taf.rfrl.utilities.robot.general import get_builtin_value
import re


def check_message_sequence(packets, field_name_list, message_sequence):
    actual_msc_list = []
    for packet in packets:
        for field_name in field_name_list:
            for value in packet.findall(field_name):
                actual_msc_list.append(value.showname)
    actual_msc = "\n".join(actual_msc_list)
    assert re.search(message_sequence, actual_msc, re.S), actual_msc


def verify_sgnb_additione_complete(packet_list):
    field_name_list = ["x2ap.SgNBAdditionRequest_element",
                       "x2ap.SgNBAdditionRequestAcknowledge_element", "x2ap.SgNBReconfigurationComplete_element",
                       "nr-rrc.RRCReconfiguration_element", "nr-rrc.RRCReconfigurationComplete_element"]
    message_sequence = "SgNBAdditionRequest.*" \
                       "SgNBAdditionRequestAcknowledge.*" \
                       "RRCReconfiguration.*" \
                       "SgNBReconfigurationComplete.*" \
                       "RRCReconfigurationComplete"
    try:
        check_message_sequence(packet_list, field_name_list, message_sequence)
        logger.info('SgNB Addition completed')
    except AssertionError as e:
        logger.debug(e)
        raise AssertionError('SgNB Addition failed not found message {}'.format(message_sequence))


def get_packets_based_on_message(packet_list, message):
    pdml_log_entries = []
    for packet in packet_list:
        for field_value in packet.findall(message['field_name']):
            if getattr(field_value, message['attrib_name']) == message['attrib_value']:
                if packet not in pdml_log_entries:
                    if message['not_contain']:
                        regex = re.compile(".*{}.*".format(message['not_contain']))
                        match = list(filter(regex.match, str(packet).splitlines()))
                        if not match:
                            pdml_log_entries.append(packet)
                    else:
                        pdml_log_entries.append(packet)
    return pdml_log_entries


def calculate_prb_based_on_location_and_bandwidth(riv_value):
    n_size_bwp = int(get_builtin_value("N_Size_BWP"))
    riv = int(riv_value)
    if ((riv / n_size_bwp) + (riv % n_size_bwp)) < n_size_bwp:
        lrb = int(riv / n_size_bwp) + 1
    else:
        lrb = n_size_bwp - int(riv / n_size_bwp) + 1
    logger.info(f'The total number of PRB {lrb}')
    return lrb


def get_value_for_path(packet, xml_path, attrib_name='show'):
    all_paths = packet.paths(xml_path)
    if attrib_name == 'show':
        return [packet.xpath(path)[0].show for path in all_paths]
    else:
        return [packet.xpath(path)[0].showname for path in all_paths]


def get_downlink_uplink_bwp(packet):
    downlink_initial_bwp = get_value_for_path(
        packet, r"x2ap/(.*?)/nr-rrc.initialDownlinkBWP_element/(.*?)/nr-rrc.locationAndBandwidth")
    uplink_initial_bwp = get_value_for_path(
        packet, r"x2ap/(.*?)/nr-rrc.initialUplinkBWP_element/(.*?)/nr-rrc.locationAndBandwidth")
    initail_bwp_list = [*downlink_initial_bwp, *uplink_initial_bwp]

    downlink_dedicated_bwp = get_value_for_path(
        packet, r"x2ap/(.*?)/nr-rrc.downlinkBWP_ToAddModList/(.*?)/nr-rrc.locationAndBandwidth")
    uplink_dedicated_bwp = get_value_for_path(
        packet, r"x2ap/(.*?)/nr-rrc.uplinkBWP_ToAddModList/(.*?)/nr-rrc.locationAndBandwidth")
    dedicated_bwp_list = [*downlink_dedicated_bwp, *uplink_dedicated_bwp]
    return initail_bwp_list, dedicated_bwp_list


def verify_if_prb_has_correct_value(packet, rb_dedicated, rb_initial):
    initial_bwp_list, dedicated_bwp_list = get_downlink_uplink_bwp(packet)
    for bwp in initial_bwp_list:
        current_prb = calculate_prb_based_on_location_and_bandwidth(bwp)
        assert current_prb == int(rb_dedicated), f'Total number of PRB should be {rb_dedicated} but is {current_prb}'

    for bwp in dedicated_bwp_list:
        current_prb = calculate_prb_based_on_location_and_bandwidth(bwp)
        assert current_prb == int(rb_initial), f'Total number of PRB should be {rb_initial} but is {current_prb}'


def verify_ue_not_support_25mhz(packet):
    feature_set_downlink = feature_set_uplink = None
    supported_subcarrier_dl = get_value_for_path(
        packet, r"x2ap/(.*?)/nr-rrc.FeatureSetDownlinkPerCC_element/nr-rrc.supportedSubcarrierSpacingDL", 'showname')
    for sub_dl in supported_subcarrier_dl:
        if 'kHz15' in sub_dl:
            feature_set_downlink = get_value_for_path(
                packet, "x2ap/(.*?)/nr-rrc.FeatureSetDownlinkPerCC_element/(.*?)/nr-rrc.fr1", 'showname')

    supported_subcarrier_ul = get_value_for_path(
        packet, r"x2ap/(.*?)/nr-rrc.FeatureSetUplinkPerCC_element/nr-rrc.supportedSubcarrierSpacingUL", 'showname')
    for sub_dl in supported_subcarrier_ul:
        if 'kHz15' in sub_dl:
            feature_set_uplink = get_value_for_path(
                packet, r"x2ap/(.*?)/nr-rrc.FeatureSetUplinkPerCC_element/(.*?)/nr-rrc.fr1", 'showname')

    feature_sets = [*feature_set_downlink, *feature_set_uplink]
    band_25mhz_list = [feature for feature in feature_sets if 'mhz25' not in feature]
    assert band_25mhz_list, "Found 25 MHz in Ue configuration but should not!"


def verify_correction_of_bwp(packet_list, rb_dedicated, rb_initial):
    message = {
        'field_name': 'x2ap.SgNBAdditionRequestAcknowledge_element',
        'attrib_name': 'showname',
        'attrib_value': 'SgNBAdditionRequestAcknowledge',
        'not_contain': None,
    }

    sgnb_add_request = get_packets_based_on_message(packet_list, message)
    verify_if_prb_has_correct_value(sgnb_add_request[0], rb_dedicated=rb_dedicated, rb_initial=rb_initial)

    message = {
        'field_name': 'x2ap.SgNBAdditionRequest_element',
        'attrib_name': 'showname',
        'attrib_value': 'SgNBAdditionRequest',
        'not_contain': None,
    }

    sgnb_add = get_packets_based_on_message(packet_list, message)
    verify_ue_not_support_25mhz(sgnb_add[0])
