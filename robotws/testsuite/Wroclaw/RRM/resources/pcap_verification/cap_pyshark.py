import pyshark
from pyshark.capture.capture import TSharkCrashException
from itertools import groupby
from enum import IntEnum
from shutil import copyfile
import taf.config.testline
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture


class Filters:
    SCTP_F1_INIT = 'sctp.chunk_type == 1 && (sctp.srcport == 38472) && (sctp.dstport == 38472)'
    SCTP_INIT_ACK = 'sctp.chunk_type == 2'
    SCTP_COOKIE_ECHO = 'sctp.chunk_type == 10'
    SCTP_COOKIE_ACK = 'sctp.chunk_type == 11'
    SCTP_X2_INIT = 'sctp.chunk_type == 1 && (sctp.srcport == 36422) && (sctp.dstport == 36422)'
    SCTP_ABORT = 'sctp.chunk_type == 6'
    SCTP_HB = 'sctp.chunk_type == 4 or sctp.chunk_type == 5'
    SCTP_X2_HB = '(sctp.chunk_type == 4 or sctp.chunk_type == 5) && (sctp.srcport == 36422) && (sctp.dstport == 36422)'

    UECap_eutra_rat = 'x2ap && nr-rrc.rat_Type == 1'
    UECap_5g_rat = 'x2ap && nr-rrc.rat_Type == 0'
    UE_CapabilityRAT_ContainerList = 'x2ap && nr-rrc.UE_CapabilityRAT_ContainerList'
    UE_supported_bands_list = 'x2ap && nr-rrc.supportedBandCombinationList'

    F1_SETUP_REQUEST = '.F1SetupRequest_element'
    F1_SETUP_RESPONSE = '.F1SetupResponse_element'
    F1_GNB_CU_REQUEST = '.GNBCUConfigurationUpdate_element'
    F1_GNB_CU_RESPONSE = '.GNBCUConfigurationUpdateAcknowledge_element'
    F1_GNB_DU_DEL_CELL = '.Served_Cells_To_Delete_List == 1'
    F1_GNB_DU_ADD_CELL = '.Served_Cells_To_Add_List == 1'
    F1_GNB_DU_ACK = '.GNBDUConfigurationUpdateAcknowledge_element'
    F1_UE_CONTEXT_RELEASE_COMMAND = '.UEContextReleaseCommand_element'
    F1_UE_CONTEXT_RELEASE_COMPLETE = '.UEContextReleaseComplete_element'
    F1_UE_CONTEXT_MODIF_REQUIRED = '.UEContextModificationRequired_element'
    F1_UE_CONTEXT_MODIF_CONFIRM = '.UEContextModificationConfirm_element'
    F1_UE_CONTEXT_MODIF_REQUEST = '.UEContextModificationRequest_element'
    F1_UE_CONTEXT_MODIF_RESPONSE = '.UEContextModificationResponse_element'

    X2_SETUP_REQUEST = '.ENDCX2SetupRequest_element'
    X2_SETUP_RESPONSE = '.ENDCX2SetupResponse_element'
    X2_SETUP_NO_CELL = '.radioNetwork == 11'
    X2_SETUP_X2LINKS_REACHED = '.misc == 4'
    X2_SGNB_REQ = '.procedureCode == 27'
    X2_SGNB_ACK = '.procedureCode == 27'
    X2_SGNB_RRC = '.ResponseInformationSgNBReconfComp == 0'
    X2_SGNB_RELEASE_REQUIRED = '.SgNBReleaseRequired_element'
    X2_SGNB_RELEASE_USER_INACTIVITY = '.radioNetwork == 42'
    X2_SGNB_RELEASE_NO_RADIO_RESOURCES = '.SgNBAdditionRequestReject_element && x2ap.radioNetwork == 12'
    X2_SGNB_RELEASE_CONFIRM = '.SgNBReleaseConfirm_element'
    X2_RESET_REQUEST = '.ResetRequest_element'
    X2_RESET_RESPONSE = '.ResetResponse_element'
    X2_UE_CONTEXT_RELEASE = '.UEContextRelease_element'
    X2_ERROR_INDICATION = '.ErrorIndication_element'
    X2_MeNBtoSgNBContainer = '.id == 206'
    X2_FAILURE_OM_INTERVENTION = '.ENDCX2SetupFailure_element && x2ap.misc == 2'
    X2_SN_STATUS_TRANSFER = '.procedureCode == 4'

    interface_F1_messages = {F1_SETUP_REQUEST, F1_SETUP_RESPONSE, F1_GNB_CU_REQUEST, F1_GNB_CU_RESPONSE,
                             F1_GNB_DU_DEL_CELL, F1_GNB_DU_ADD_CELL, F1_GNB_DU_ACK, F1_UE_CONTEXT_RELEASE_COMMAND,
                             F1_UE_CONTEXT_RELEASE_COMPLETE, F1_UE_CONTEXT_MODIF_REQUIRED, F1_UE_CONTEXT_MODIF_CONFIRM,
                             F1_UE_CONTEXT_MODIF_REQUEST, F1_UE_CONTEXT_MODIF_RESPONSE}

    interface_X2_messages = {X2_SETUP_REQUEST, X2_SETUP_RESPONSE, X2_SETUP_NO_CELL, X2_SETUP_X2LINKS_REACHED,
                             X2_SGNB_REQ, X2_SGNB_ACK, X2_SGNB_RRC, X2_SGNB_RELEASE_REQUIRED, X2_SGNB_RELEASE_CONFIRM,
                             X2_SGNB_RELEASE_USER_INACTIVITY, X2_RESET_REQUEST, X2_RESET_RESPONSE,
                             X2_UE_CONTEXT_RELEASE, X2_ERROR_INDICATION, X2_MeNBtoSgNBContainer,
                             X2_FAILURE_OM_INTERVENTION, X2_SN_STATUS_TRANSFER, X2_SGNB_RELEASE_NO_RADIO_RESOURCES}


class Ip(IntEnum):
    cu = 1
    du = 2
    sgnb = 3
    menb = 4
    second_menb = 5


class Protocols(IntEnum):
    F1 = 1
    X2 = 2


cap_pyshark = None


def check_f1_sctp_association(pcap_file_location):
    cap = get_cappyshark_instance(pcap_file_location)
    sctp_init_tag_list = get_initiation_tags(
        cap.get_ip_template(Ip.du), Filters.SCTP_F1_INIT, pcap_file_location)
    for init_tag in sctp_init_tag_list:
        init_ack_ver_tag = get_verification_tag(
            cap.get_ip_template(Ip.cu), Filters.SCTP_INIT_ACK, pcap_file_location)
        init_ack_tag = get_initiation_ack_tag(
            cap.get_ip_template(Ip.cu), Filters.SCTP_INIT_ACK, pcap_file_location)
        cookie_echo_ver_tag = get_verification_tag(
            cap.get_ip_template(Ip.du), Filters.SCTP_COOKIE_ECHO, pcap_file_location)
        cookie_ack_tag = get_verification_tag(cap.get_ip_template(Ip.cu), Filters.SCTP_COOKIE_ACK, pcap_file_location)
        if None in (init_tag, init_ack_ver_tag, cookie_echo_ver_tag, cookie_ack_tag):
            continue
        if init_tag == init_ack_ver_tag == cookie_ack_tag and init_ack_tag == cookie_echo_ver_tag:
            return True
    return False


def check_x2_sctp_association(pcap_file_location):
    cap = get_cappyshark_instance(pcap_file_location)
    sctp_init_filter = prepare_sctp_x2_init_filter(pcap_file_location, Filters.SCTP_X2_INIT)
    sctp_init_tag_list = get_initiation_tags(cap.get_ip_template(Ip.menb), sctp_init_filter, pcap_file_location)
    for init_tag in sctp_init_tag_list:
        init_ack_ver_tag = get_verification_tag(
            cap.get_ip_template(Ip.sgnb), Filters.SCTP_INIT_ACK, pcap_file_location)
        init_ack_tag = get_initiation_ack_tag(
            cap.get_ip_template(Ip.sgnb), Filters.SCTP_INIT_ACK, pcap_file_location)
        cookie_echo_ver_tag = get_verification_tag(
            cap.get_ip_template(Ip.menb), Filters.SCTP_COOKIE_ECHO, pcap_file_location)
        cookie_ack_tag = get_verification_tag(
            cap.get_ip_template(Ip.sgnb), Filters.SCTP_COOKIE_ACK, pcap_file_location)
        if None in (init_tag, init_ack_ver_tag, cookie_echo_ver_tag, cookie_ack_tag):
            continue
        if init_tag == init_ack_ver_tag == cookie_ack_tag and init_ack_tag == cookie_echo_ver_tag:
            return True
    return False


def get_log_count_of_given_message_type(pcap_file_location, message):
    cap = get_cappyshark_instance(pcap_file_location)
    return cap.with_filter(pcap_filter=message).get_log_count()


def check_sctp_abort(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    sctp_failure = log.with_filter(custom_filter=Filters.SCTP_ABORT).source_ip_is().equal_to(Ip.du)
    return sctp_failure


def check_sctp_connection(pcap_file_location):
    cap = get_cappyshark_instance(pcap_file_location)
    sctp_conn_du = cap.with_filter(custom_filter=Filters.SCTP_HB).source_ip_is().equal_to(Ip.du)
    sctp_conn_cu = cap.with_filter(custom_filter=Filters.SCTP_HB).source_ip_is().equal_to(Ip.cu)
    return sctp_conn_du or sctp_conn_cu


def check_x2_sgnb(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    sgnb_addition_request = log.with_filter(pcap_filter=Filters.X2_SGNB_REQ).source_ip_is().equal_to(Ip.menb)
    sgnb_addition_request_ack = log.with_filter(pcap_filter=Filters.X2_SGNB_ACK).source_ip_is().equal_to(Ip.sgnb)
    sgnb_reconfiguration_complete = log.with_filter(Protocols.X2, Filters.X2_SGNB_RRC).source_ip_is().equal_to(Ip.menb)

    return sgnb_addition_request and sgnb_addition_request_ack and sgnb_reconfiguration_complete


def check_x2_sn_status_transfer(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    sn_status_transfer = log.with_filter(pcap_filter=Filters.X2_SN_STATUS_TRANSFER).source_ip_is().equal_to(Ip.menb)

    return sn_status_transfer


def check_x2_sgnb_release_user_inactivity(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    sgnb_release_required = log.with_filter(pcap_filter=Filters.X2_SGNB_RELEASE_REQUIRED).\
        source_ip_is().equal_to(Ip.sgnb)
    sgnb_release_user_inactivity = log.with_filter(pcap_filter=Filters.X2_SGNB_RELEASE_USER_INACTIVITY).\
        source_ip_is().equal_to(Ip.sgnb)
    sgnb_release_confirm = log.with_filter(Protocols.X2, Filters.X2_SGNB_RELEASE_CONFIRM).\
        source_ip_is().equal_to(Ip.menb)

    return (sgnb_release_required and sgnb_release_user_inactivity) and sgnb_release_confirm


def check_x2_sgnb_release_no_radio_resources_in_target_cell(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    sgnb_addition_request = log.with_filter(pcap_filter=Filters.X2_SGNB_REQ).source_ip_is().equal_to(Ip.menb)
    sgnb_release_no_radio_resources = log.with_filter(pcap_filter=Filters.X2_SGNB_RELEASE_NO_RADIO_RESOURCES). \
        source_ip_is().equal_to(Ip.sgnb)

    return sgnb_addition_request and sgnb_release_no_radio_resources


def check_x2_sgnb_release(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    sgnb_release_required = log.with_filter(pcap_filter=Filters.X2_SGNB_RELEASE_REQUIRED).\
        source_ip_is().equal_to(Ip.sgnb)
    sgnb_release_confirm = log.with_filter(Protocols.X2, Filters.X2_SGNB_RELEASE_CONFIRM).\
        source_ip_is().equal_to(Ip.menb)

    return sgnb_release_required or sgnb_release_confirm


def check_f1_ap_association(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    f1_req = log.with_filter(pcap_filter=Filters.F1_SETUP_REQUEST)
    f1_rsp = log.with_filter(pcap_filter=Filters.F1_SETUP_RESPONSE)
    return f1_req and f1_rsp


def check_x2_ap_association(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    x2_req = log.with_filter(pcap_filter=Filters.X2_SETUP_REQUEST)
    x2_rsp = log.with_filter(pcap_filter=Filters.X2_SETUP_RESPONSE)
    return x2_req and x2_rsp


def check_f1_gnb_cu_association(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    cu_req = log.with_filter(pcap_filter=Filters.F1_GNB_CU_REQUEST)
    cu_rsp = log.with_filter(pcap_filter=Filters.F1_GNB_CU_RESPONSE)
    return cu_req and cu_rsp


def check_f1_gnb_du_association(pcap_file_location, sniffer_give_large_output_file=True):
    log = get_cappyshark_instance(pcap_file_location)
    cu_req_del_cell = log.with_filter(pcap_filter=Filters.F1_GNB_DU_DEL_CELL)
    cu_rsp = log.with_filter(pcap_filter=Filters.F1_GNB_DU_ACK)
    cu_req_add_cell = log.with_filter(pcap_filter=Filters.F1_GNB_DU_ADD_CELL)
    if sniffer_give_large_output_file:
        message_flow = log.check_message_flow_sequence(Filters.F1_GNB_DU_DEL_CELL, Filters.F1_GNB_DU_ACK,
                                                       Filters.F1_GNB_DU_ADD_CELL, Filters.F1_GNB_DU_ACK)
    else:
        message_flow = log.check_message_flow_sequence_without_checking_len(Filters.F1_GNB_DU_DEL_CELL,
                                                                            Filters.F1_GNB_DU_ACK,
                                                                            Filters.F1_GNB_DU_ADD_CELL,
                                                                            Filters.F1_GNB_DU_ACK)
    return cu_req_del_cell and cu_req_add_cell and cu_rsp and message_flow


def check_x2_ap_no_cell(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    x2_req = log.with_filter(pcap_filter=Filters.X2_SETUP_REQUEST).source_ip_is().equal_to(Ip.menb)
    x2_rsp = log.with_filter(pcap_filter=Filters.X2_SETUP_NO_CELL).source_ip_is().equal_to(Ip.sgnb)
    return x2_req and x2_rsp


def check_x2_links_reached(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    x2_req = log.with_filter(pcap_filter=Filters.X2_SETUP_REQUEST).source_ip_is().equal_to(Ip.second_menb)
    x2_rsp = log.with_filter(pcap_filter=Filters.X2_SETUP_X2LINKS_REACHED).source_ip_is().equal_to(Ip.sgnb)
    return x2_req and x2_rsp


def check_x2_failure_om_intervention(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    x2_req = log.with_filter(pcap_filter=Filters.X2_SETUP_REQUEST).source_ip_is().equal_to(Ip.menb)
    x2_rsp = log.with_filter(pcap_filter=Filters.X2_FAILURE_OM_INTERVENTION).source_ip_is().equal_to(Ip.sgnb)
    return x2_req and x2_rsp


def check_ue_5g_and_4g_capabilities(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    sgnb_container = log.with_filter(pcap_filter=Filters.X2_MeNBtoSgNBContainer).source_ip_is().equal_to(Ip.menb)
    ue_cap_container = log.with_filter(custom_filter=Filters.UE_CapabilityRAT_ContainerList).\
        source_ip_is().equal_to(Ip.menb)
    ue_supported_bands = log.with_filter(custom_filter=Filters.UE_supported_bands_list).\
        source_ip_is().equal_to(Ip.menb)
    check_eutra_rat_type = log.with_filter(custom_filter=Filters.UECap_eutra_rat).source_ip_is().equal_to(Ip.menb)
    check_5g_rat_type = log.with_filter(custom_filter=Filters.UECap_5g_rat).source_ip_is().equal_to(Ip.menb)
    return sgnb_container and ue_cap_container and ue_supported_bands and check_eutra_rat_type and check_5g_rat_type


def check_ue_capabilities_sent(pcap_file_location, timeout=30, retry_timeout=10):
    fixture.wait_for_method(check_ue_5g_and_4g_capabilities, timeout, retry_timeout,
                            method_args=(pcap_file_location,))


def wait_for_f1_sctp_association(pcap_file_location, timeout=1200, retry_timeout=30):
    fixture.wait_for_method(check_f1_sctp_association, timeout, retry_timeout,
                            method_args=(pcap_file_location,))


def wait_for_sctp_abort(pcap_file_location, timeout=600, retry_timeout=30):
    fixture.wait_for_method(check_sctp_abort, timeout, retry_timeout,
                            method_args=(pcap_file_location,))


def wait_for_sctp_connection(pcap_file_location, timeout=600, retry_timeout=30):
    fixture.wait_for_method(check_sctp_connection, timeout, retry_timeout,
                            method_args=(pcap_file_location,))


def wait_for_f1_establishment(pcap_file_location, timeout=600, retry_timeout=30):
    fixture.wait_for_method(check_f1_ap_association, timeout, retry_timeout,
                            method_args=(pcap_file_location,))


def wait_for_x2_establishment(pcap_file_location, timeout=300, retry_timeout=30):
    fixture.wait_for_method(check_x2_ap_association, timeout, retry_timeout,
                            method_args=(pcap_file_location,))


def wait_for_f1_gnb_cu_association(pcap_file_location, timeout=300, retry_timeout=30):
    fixture.wait_for_method(check_f1_gnb_cu_association, timeout, retry_timeout,
                            method_args=(pcap_file_location,))


def prepare_sctp_x2_init_filter(pcap_file_location, filtering):
    filtered_file_f1 = pyshark.FileCapture(pcap_file_location, display_filter=Filters.F1_SETUP_REQUEST)
    f1_ap_response = filtered_file_f1[1]
    filter_name = filtering + ' && frame.number > ' + f1_ap_response.number
    return filter_name


def filter_sctp(ip, filtering, pcap_file_location):
    filtered_file = pyshark.FileCapture(pcap_file_location, display_filter=filtering)
    for pkt in filtered_file:
        if hasattr(pkt, 'sctp') and pkt.ip.src == ip:
            return pkt.sctp


def get_initiation_tags(ip, filtering, pcap_file_location):
    filtered_file = pyshark.FileCapture(pcap_file_location, display_filter=filtering)
    init_tag_list = []
    for pkt in filtered_file:
        if hasattr(pkt, 'sctp') and pkt.ip.src == ip:
            init_tag_list.append(pkt.sctp.init_initiate_tag)
    return init_tag_list


def get_initiation_ack_tag(ip, filtering, pcap_file_location):
    return filter_sctp(ip, filtering, pcap_file_location).initack_initiate_tag


def get_verification_tag(ip, filtering, pcap_file_location):
    return filter_sctp(ip, filtering, pcap_file_location).verification_tag


def get_cappyshark_instance(pcap_file_location):
    global cap_pyshark
    if cap_pyshark is None:
        cap_pyshark = CapPyshark(pcap_file_location)
    cap_pyshark.reload(pcap_file_location)
    return cap_pyshark


def check_x2_heartbeat(pcap_file_location):
    log = get_cappyshark_instance(pcap_file_location)
    hb_req_sgnb = log.with_filter(custom_filter=Filters.SCTP_X2_HB).source_ip_is().equal_to(Ip.sgnb)
    hb_req_menb = log.with_filter(custom_filter=Filters.SCTP_X2_HB).source_ip_is().equal_to(Ip.menb)
    return hb_req_sgnb and hb_req_menb


def check_x2_heartbeat_interval(filter, pcap_file_location, expected_interval=20):
    filtered_pkts = pyshark.FileCapture(pcap_file_location, display_filter=filter)
    time_interval = []
    for pkt in filtered_pkts:
        time_interval.append(int(float(pkt.frame_info.time_delta_displayed)))
    return all([(expected_interval - 2) <= int(interval) <= (expected_interval + 1) for interval in time_interval[1:]])


class CapPyshark:
    def __init__(self, pcap_file):
        self.__pcap_file = None
        self.__cap = None
        self.__ip_templates = {obj: '' for obj in Ip}
        self.__protocols_holder = {}
        self.__source_ip = []
        self.__assign_testline_ip_addresses()
        self.reload(pcap_file)

    def __getitem__(self, packet_index):
        self.__cap.__getitem__(packet_index)

    def reload(self, pcap_file):
        self.__pcap_file = pcap_file
        working_file = '{}_backup'.format(self.__pcap_file)
        copyfile(self.__pcap_file, working_file)
        self.__cap = pyshark.FileCapture(working_file, display_filter='sctp')
        self.__cap.set_debug()
        self.__find_all_protocols_names()

    def __assign_testline_ip_addresses(self):
        self.__ip_templates[Ip.menb] = self.__get_menb_ip()
        self.__ip_templates[Ip.second_menb] = self.__increment_given_ip(self.__ip_templates[Ip.menb])
        self.__set_classical_ip_templates() if fixture.is_classical_testline else self.__set_cloud_ip_templates()
        fixture.log_message(
            message='\n'.join('{} ip = {}'.format(Ip(i).name, self.__ip_templates[i]) for i in self.__ip_templates))

    @staticmethod
    def __get_menb_ip():
        is_lte_emu = isinstance(fixture.get_robot_variable('${tl.core}'), taf.config.testline.core.LTEEmuCore)
        if is_lte_emu:
            return fixture.get_robot_variable('${tl.core.mme_ip}')
        return fixture.get_robot_variable('${tl.enbs[0].x2_link_addr.v4}')

    def __set_classical_ip_templates(self):
        self.__ip_templates[Ip.cu] = '192.168.253.228'
        self.__ip_templates[Ip.du] = '192.168.253.229'
        self.__ip_templates[Ip.sgnb] = fixture.get_robot_variable('${tl.gnbs[0].cu.x2c.v4}')

    def __set_cloud_ip_templates(self):
        self.__ip_templates[Ip.cu] = fixture.get_robot_variable('${tl.gnbs[0].cu.f1c.v4}')
        self.__ip_templates[Ip.du] = fixture.webUI.get_parameter_value_from_scf(
            'localIpAddr', parameter_dist_name='TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1')
        self.__ip_templates[Ip.sgnb] = fixture.get_robot_variable('${tl.gnbs[0].cu.x2c.v4}')

    @staticmethod
    def __increment_given_ip(address):
        split = address.split(".")
        split[-1] = str(int(split[-1]) + 1)
        return '.'.join(split)

    def __find_all_protocols_names(self):
        self.__protocols_holder = {protocol: self.__get_all_protocol_names(protocol.name) for protocol in Protocols}

    def __get_all_protocol_names(self, protocol):
        protocols = [pkt.highest_layer for pkt in self.__cap if protocol in pkt.highest_layer]
        if not protocols:
            protocols.append(protocol)
        return list(set(protocols))

    def source_ip_is(self):
        try:
            ips = [pkt.ip.src for pkt in self.__cap]
            ips = list(set(ips))
            self.__source_ip = ips
        except TSharkCrashException as e:
            print(e)
            self.__source_ip = []
        return self

    def get_log_count(self):
        try:
            i = 0
            for _ in self.__cap:
                i += 1
            return i
        except TSharkCrashException as e:
            print(e)
            return 0

    def with_filter(self, interface=None, pcap_filter=None, custom_filter=None):
        if custom_filter and not (interface and pcap_filter):
            self.__cap.display_filter = custom_filter
        elif interface and pcap_filter and not custom_filter:
            self.__set_display_filter_from_protocol_and_message(interface, pcap_filter)
        elif pcap_filter and not (interface and custom_filter):
            self.__set_display_filter_from_message(pcap_filter)
        return self

    def __set_display_filter_from_protocol_and_message(self, interface, pcap_filter):
        display_filter = ' or '.join(
            [protocol.lower() + pcap_filter for protocol in self.__protocols_holder[interface]])
        self.__cap.display_filter = display_filter

    def __set_display_filter_from_message(self, pcap_filter):
        interface = self.__get_interface_from_filter(pcap_filter)
        self.__set_display_filter_from_protocol_and_message(interface, pcap_filter)

    @staticmethod
    def __get_interface_from_filter(pcap_filter):
        if pcap_filter in Filters.interface_F1_messages:
            return Protocols.F1
        if pcap_filter in Filters.interface_X2_messages:
            return Protocols.X2

    def equal_to(self, ip_address):
        return self.__ip_templates[ip_address] in self.__source_ip

    def get_details(self):
        return self.__cap

    def get_ip_template(self, ip_enum):
        return self.__ip_templates[ip_enum]

    def check_message_flow_sequence(self, *args):
        message_flow = self.__prepare_flow_from_pcap(args)
        for pkt_id, pkt in enumerate(message_flow):
            if pkt[1] != args[pkt_id]:
                return False

        return True if message_flow and len(message_flow) == len(args) else False

    def check_message_flow_sequence_without_checking_len(self, *args):
        message_flow = self.__prepare_flow_from_pcap(args)
        for i, arg in enumerate(args):
            if message_flow[i][1] != arg:
                return False

        return True

    def __prepare_flow_from_pcap(self, args):
        message_flow = []
        for message in args:
            message_flow.extend(self.__get_packet_with_message(message))
        message_flow = self.__remove_duplicates(message_flow)
        return message_flow

    def __get_packet_with_message(self, message):
        self.__set_display_filter_from_message(message)
        pkt_with_message = [[packet_number, message] for packet_number in self.__get_packet_numbers()]
        return pkt_with_message

    def __get_packet_numbers(self):
        try:
            packet_numbers = [int(pkt.number) for pkt in self.__cap]
            return packet_numbers
        except TSharkCrashException as e:
            print(e)
            return []

    @staticmethod
    def __remove_duplicates(message_flow):
        removed_empty = [x for x in message_flow if x]
        removed_empty.sort()
        return list(removed_empty for removed_empty, _ in groupby(removed_empty))
