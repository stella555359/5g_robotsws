# -*- coding: utf-8 -*

"""
Author:         Cui Lingxue
Contact Mail:   lingxue.cui@nokia-sbell.com
Description:    Analyze pdml packet convert from pcap
"""

from robot.libraries.BuiltIn import BuiltIn
from taf.analyzer.pdml import PdmlReader, pdml
from taf.analyzer.pcap.pcap_parser import PcapParser
import os
import logging


def get_measurement_id_in_pdml(log_path_pdml, event_type):
    """
    Author: Cui Lingxue  5G_PZ_MMW_HZ_1_SG
    Read pdml file and find A1/A2/A3 measurement id inside RRC Reconfiguration message.
    """
    measurement_id = None

    if event_type == "A2":
        msg_srb1 = "x2ap//..//x2ap.SgNBAdditionRequestAcknowledge_element"
        msg_srb3 = msg_srb1
    elif event_type == "A1" or "A3":
        msg_srb1 = "x2ap//..//x2ap.SgNBModificationRequired_element"
        msg_srb3 = "f1ap//..//f1ap.DLRRCMessageTransfer_element"
    else:
        BuiltIn().fail("Event type {} does not exist!!!" % event_type)

    if not os.path.isfile(log_path_pdml):
        BuiltIn().fail("find_measurement_id(): %s does not exist!!!" % log_path_pdml)
    with open(log_path_pdml, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if root.xpath(msg_srb1) or root.xpath(msg_srb3):
                paths_of_reportConfigId = root.paths(
                    "(x2ap|f1ap)/(.*?)/nr-rrc.ReportConfigToAddMod_element/nr-rrc.reportConfigId")
                for path in paths_of_reportConfigId:
                    reportConfigIds = root.xpath(path)
                    paths_of_eventId = path + "//..//nr-rrc.eventId"
                    eventIds = root.xpath(paths_of_eventId)
                    if len(eventIds) != 0:
                        if ("event" + event_type) in eventIds[0].showname:
                            report_config_id = reportConfigIds[0].show
                            logging.info("{} report_config_id is: {}".format(event_type, report_config_id))
                            break

                paths_of_measId = root.paths("(x2ap|f1ap)/(.*?)/nr-rrc.measIdToAddModList/(.*?)/nr-rrc.measId")
                for path in paths_of_measId:
                    measIds = root.xpath(path)
                    paths_of_reportConfigId = path + "//..//nr-rrc.reportConfigId"
                    reportConfigIds = root.xpath(paths_of_reportConfigId)
                    if len(reportConfigIds) != 0:
                        if reportConfigIds[0].show == report_config_id:
                            measurement_id = measIds[0].show
                            logging.info("{} measurement_id is: {}".format(event_type, measurement_id))
                            break
                if measurement_id is not None:
                    break
    if measurement_id is None:
        BuiltIn().fail(msg="{} measurement id could not be found!!!".format(event_type))
    return measurement_id


def verify_msg_type_and_seq_in_pdml(log_path_pdml, filters):
    """
    Author: Cui Lingxue  5G_PZ_MMW_HZ_1_SG
    Look for msgs defined in 'filters' in pdml file, and msgs should be in same order as in 'filters'.
    If not all messages are found, kw will fail.
    :param log_path_pdml: captured msgs in pdml format.
    :param filters: list of msgs to be verified, should be in desired order.
           Each element represent the xpath which could find the corresponding msg.
           eg: PSCELL_CHANGE_SRB1 = [xpath_x2ap_SgnbAddReq, xpath_f1ap_UeCxtSetupReq]
           xpath_x2ap_SgnbAddReq = 'x2ap//..//x2ap.SgNBAdditionRequest_element'
    :return: list contain matched msgs in pdml format
    """
    filter_position = 0
    hit_flag = 0
    matched_list = []
    if not os.path.isfile(log_path_pdml):
        BuiltIn().fail("log file {} doesn't exist!".format(log_path_pdml))
    with open(log_path_pdml, 'rb') as file_obj:
        pdml_obj = PdmlReader(file_obj=file_obj)
        for index, entry in enumerate(pdml_obj):
            root = entry.packet
            if root.xpath(filters[filter_position]):
                logging.warning("Found {}th msg {}".format(filter_position, filters[filter_position]))
                filter_position += 1
                matched_list.append(root)
                if filter_position == len(filters):
                    break
            else:
                continue
        if filter_position != len(filters):
            raise Exception("Not all msgs in filters are found in log file {}!".format(log_path_pdml))
    return matched_list


def verify_detail_msg_ie_in_packet(packet_list, detail_ie_filters):
    """
    Author: Cui Lingxue  5G_PZ_MMW_HZ_1_SG
    Verify IE in msgs in a list of packets.
    :param packet_list: captured msgs in format converted by PdmlReader.
    :param detail_ie_filters: list of IEs to be verified, should be in desired order.
           Eg: IE_FILTERS = [
           {'detail_ie_xpath': 'x2ap//..//x2ap.SCGConfigurationQuery',
           'detail_id_showname': 'SCGConfigurationQuery: true (0)',
           'detail_ie_show': '0'}, ...]
           'detail_ie_show' will be verified which is find by 'detail_ie_xpath'.
           'detail_id_showname' is only for description use.
    """
    filter_position = 0  # used to indicate position in list 'detail_ie_filters'
    hit_flag = 0  # indicate how many IEs are matched
    length_of_filters = len(detail_ie_filters)  # indicate how many IEs in total
    for filter in detail_ie_filters:
        type_of_filter = type(filter)
        if type_of_filter == list:
            length_of_filters = length_of_filters + len(filter) - 1
    logging.info("length_of_filters is %i" % length_of_filters)

    filters_not_matched_list = []
    for packet in packet_list:
        logging.debug("current filter position is %s " % filter_position)
        current_filter = detail_ie_filters[filter_position]
        type_of_current_filter = type(current_filter)

        if type_of_current_filter == dict:
            detail_ie_xpath = current_filter['detail_ie_xpath']
            detail_ie_value = current_filter['detail_ie_show']
            logging.debug("Current filter is %s" % detail_ie_xpath)
            result_code = verify_ie_show_value_in_packet(packet=packet, xpath=detail_ie_xpath,
                                                         expected_show_value=detail_ie_value)
            if result_code != 'xpath not found':
                filter_position += 1
                if result_code == 'IE matched':
                    hit_flag += 1
                else:
                    filters_not_matched_list.append(current_filter)
        elif type_of_current_filter == list:
            result_code_list = []
            for sub_filter in current_filter:
                detail_ie_xpath = sub_filter['detail_ie_xpath']
                detail_ie_value = sub_filter['detail_ie_show']
                logging.debug("Current filter is %s" % detail_ie_xpath)
                result_code = verify_ie_show_value_in_packet(packet=packet, xpath=detail_ie_xpath,
                                                             expected_show_value=detail_ie_value)
                result_code_list.append(result_code)
                if result_code == 'IE matched':
                    hit_flag += 1
                elif result_code == 'IE not matched':
                    filters_not_matched_list.append(sub_filter)
                else:
                    continue
            # if all filters' xpath in list 'current_filter' are not found in this packet, filter_position will not
            # change, will continue to next packet. At least one xpath is found, filter_position will plus 1.
            if result_code_list.count('xpath not found') != len(current_filter):
                filter_position += 1

        if filter_position == len(detail_ie_filters):
            break
        else:
            continue
    if hit_flag != length_of_filters:
        length_of_filters_not_matched_list = length_of_filters - hit_flag
        raise Exception("Not all IEs in filters matched in log file!\n%s filters not matched: %s" %
                        (length_of_filters_not_matched_list, filters_not_matched_list))


def verify_ie_show_value_in_packet(packet, xpath, expected_show_value):
    """
    Author: Cui Lingxue  5G_PZ_MMW_HZ_1_SG
    Get IE show value by its xpath, and compare with expected show value, return different string for different result.
    :param packet: in which IE is to be verified.
    :param xpath: xpath of IE.
    :param expected_show_value: expected show value of IE.
    :return: "xpath not found" if xpath is not in packet;
             "IE not matched" if xpath could match in packet, but show value of IE doesn't match expected_show_value;
             "IE matched" if IE show value match expected_show_value.
    """
    if packet.xpath(xpath):
        attribute_show = packet.xpath(xpath)[0].show
        if attribute_show == expected_show_value:
            logging.info("IE value of %s is matched!" % xpath)
            result_code = 'IE matched'
        else:
            logging.warning("the IE value of %s is %s, should be %s!" % (xpath, attribute_show, expected_show_value))
            result_code = 'IE not matched'
    else:
        result_code = 'xpath not found'
    return result_code


def verify_detail_msg_ie_in_pdml(log_path_pdml, detail_ie_filters):
    """
    Author: Cui Lingxue  5G_PZ_MMW_HZ_1_SG
    Verify IE in msgs in pdml file.
    :param log_path_pdml: captured msgs in pdml format.
    :param detail_ie_filters: list of IEs to be verified, should be in desired order.
           Eg: IE_FILTERS = [
           {'detail_ie_xpath': 'x2ap//..//x2ap.SCGConfigurationQuery',
           'detail_id_showname': 'SCGConfigurationQuery: true (0)',
           'detail_ie_show': '0'}, ...]
           'detail_ie_show' will be verified which is find by 'detail_ie_xpath'.
           'detail_id_showname' is only for description use, will not be verified.
    """
    packet_list = []
    with open(log_path_pdml, 'rb') as file_obj:
        pdml_obj = PdmlReader(file_obj=file_obj)
        for entry in pdml_obj:
            packet_list.append(entry.packet)
    verify_detail_msg_ie_in_packet(packet_list=packet_list, detail_ie_filters=detail_ie_filters)
