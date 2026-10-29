import logging
import tsharkWithLuaVerifier as tshark
from message_to_tree import message_to_tree
import datetime


def filter_pcap(pcap_file, filter):
    frames = tshark.get_filtered_tshark_output_as_frames(pcap_file, tshark_filter=filter)
    single_msg = message_to_tree(frames[0])
    return single_msg


def filter_pcap_without_parsing(pcap_file, filter):
    return tshark.get_filtered_tshark_output_as_frames(pcap_file, tshark_filter=filter)


def verify_f1ap_establishment(pcap_file):
    try:
        request = filter_pcap(pcap_file, filter='f1ap.F1SetupRequest_element')
    except AssertionError as ex:
        request = False
        logging.warning("Caught error while seeking f1ap.F1SetupRequest_element for F1AP establishment: {}: {}"
                        "".format(type(ex).__name__, ex.args))
    try:
        response = filter_pcap(pcap_file, filter='f1ap.F1SetupResponse_element')
    except AssertionError as ex:
        response = False
        logging.warning("Caught error while seeking f1ap.F1SetupResponse_element for F1AP establishment: {}: {}"
                        "".format(type(ex).__name__, ex.args))
    logging.info("F1AP setup request caught: {}, response: {}".format(request, response))
    return request and response


def verify_maxMeasFreqsSCG_value(pcap_file):
    value = filter_pcap(pcap_file, filter='x2ap.SgNBAdditionRequest_element').find(b'maxMeasFreqsSCG')
    logging.info("My precious value: {}".format(value))
    maxmeasfreqSCG = int(value[0]['val'])
    logging.info("My precious value2: {}".format(maxmeasfreqSCG))
    events_list = filter_pcap(pcap_file, filter='x2ap.SgNBAdditionRequestAcknowledge_element') \
        .find(b'reportConfigToAddModList*')
    logging.info("My precious value: {}".format(events_list))


def verify_that_3Scells_are_configured_in_SgNB_Addition_Request_Ack(pcap_file):

    value = filter_pcap(pcap_file, filter='x2ap.SgNBAdditionRequestAcknowledge_element').find(b'sCellToAddModList*')
    number_of_scells_configured = len(value[0]['val'])
    logging.info("My precious value: {}".format(number_of_scells_configured))
    assert int(number_of_scells_configured) == 3, 'The number of configured Scells is not equal 3'


def verify_that_Scells_are_configured_in_SgNB_Addition_Request_Ack(pcap_file, numer_of_expected_scells_to_configured):

    value = filter_pcap(pcap_file, filter='x2ap.SgNBAdditionRequestAcknowledge_element').find(b'sCellToAddModList*')
    number_of_scells_configured = len(value[0]['val'])
    logging.info("My precious value: {}".format(number_of_scells_configured))
    assert int(number_of_scells_configured) == int(numer_of_expected_scells_to_configured), \
        'The number of configured Scells is not equal {}'.format(int(numer_of_expected_scells_to_configured))


def check_number_of_f1ap_establishments(pcap_file):
    try:
        response = filter_pcap_without_parsing(pcap_file, filter='f1ap.F1SetupResponse_element')
    except AssertionError as ex:
        response = []
        logging.warning("Caught error while seeking f1ap.F1SetupResponse_element for F1AP establishment: {}: {}"
                        "".format(type(ex).__name__, ex.args))
    logging.info("{} F1AP setup responses caught: {}".format(len(response), response))
    return len(response)


def check_number_of_f1ap_gnbcu_configuration_update(pcap_file):
    try:
        response = filter_pcap_without_parsing(pcap_file, filter='f1ap.GNBCUConfigurationUpdate_element')
    except AssertionError as ex:
        response = []
        logging.warning("Caught error while seeking GNBCUConfigurationUpdate_element for F1AP establishment: {}:{}"
                        "".format(type(ex).__name__, ex.args))
    logging.info("{} F1AP gNB CU Configuration messages caught: {}".format(len(response), response))
    return len(response)


def check_number_of_occurred_messages_in_pcap(pcap_file, filter_name):
    try:
        response = filter_pcap_without_parsing(pcap_file, filter=filter_name)
    except AssertionError as ex:
        response = []
        logging.warning("Caught error while seeking {} for F1AP establishment: {}: {}"
                        "".format(filter_name, type(ex).__name__, ex.args))
    logging.info("{} - {} messages caught: {}".format(len(response), filter_name, response))
    return len(response)


def verify_user_inactivity_release_cause_with_timer(pcap_file, start_of_timer, timer):
    """
    Verifies the existence of SgNBReleaseRequired and SgNBReleaseConfirm, checks the cause of SgNBReleaseRequired
    and finally checks if the time difference between timestamp and the arrival of SgNBReleaseRequired message
    is the same as  nsaInactivityTimer parameter set on gNB.
    :param pcap_file: file containing X2AP packets, containing relevant messages
    :param start_of_timer: datetime object of a timestamp, from when the traffic stopped
    :param timer: nsaInactivityTimer value or how much time should pass between start of timer and SgNBReleaseRequired
                    message appearance.
    :return:
    """
    packet_filter = 'x2ap.SgNBReleaseRequired_element or x2ap.SgNBReleaseConfirm_element'
    frames = tshark.get_filtered_tshark_output_as_frames(
        pcap_file,
        tshark_filter=packet_filter)
    logging.info("Caught frames fulfilling following query:\n"
                 "x2ap.SgNBReleaseRequired_element or x2ap.SgNBReleaseConfirm_element \n "
                 "{} ".format(frames))
    trees = [message_to_tree(message) for message in frames]

    assert len(trees) == 2, "Amount of packets for the filter \"{}\" is different than 2".format(packet_filter)

    release_required = trees[0]
    assert release_required, "No x2ap.SgNBReleaseRequired message recieved."
    cause = release_required.find(b'Item 2: id-Cause')
    logging.info("Found: \n{} \nas cause in Item 2: id-Cause field".format(cause))
    assert cause, "No cause field in x2ap.SgNBReleaseRequired message recieved."
    cause_value = cause[0]['val'][b'ProtocolIE-Field'][b'value'][b'Cause: radioNetwork (0)'][b'radioNetwork']
    assert cause_value == b'user-inactivity (42)'
    logging.info("Cause identified as {}".format(cause_value))
    release_confirm = trees[1]
    assert release_confirm, "No x2ap.SgNBReleaseConfirm_element message recieved"

    date = release_required.find(b'Arrival Time')[0]['val']
    logging.info("Start of the NSAuserInactivityTimer: {}".format(start_of_timer))
    message_timer_parse = date.decode().split()[:-1]
    message_timer_parse[-1] = message_timer_parse[-1][:-3]
    parsed = ' '.join(message_timer_parse)
    datetime_of_message_timer = datetime.datetime.strptime(parsed, "%b %d, %Y %H:%M:%S.%f")
    logging.info("SgNBReleaseRequired message arrival time: {}".format(datetime_of_message_timer))
    delta = datetime_of_message_timer - start_of_timer
    logging.info("Difference between start of the timer and message arrival: {}".format(delta))
    timedelta = datetime.timedelta(0, int(timer))
    uncertainty = datetime.timedelta(0, 5)
    assert timedelta + uncertainty >= delta >= timedelta - uncertainty, \
        "Difference is more than {} seconds +/- {}.".format(timer, uncertainty)
