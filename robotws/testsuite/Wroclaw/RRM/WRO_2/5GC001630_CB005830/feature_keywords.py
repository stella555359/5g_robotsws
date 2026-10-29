import time
import feature_variables
from robot.api import logger
from datetime import datetime
from ta5g_tshark import ta5g_tshark
from contextlib import contextmanager
from ute_fsmaccess import ute_fsmaccess
from robot.libraries.BuiltIn import BuiltIn
from ta5g_commissioning import ta5g_commissioning
from ta5g_admin_operations import ta_admin_interface
from ta5g_interface_tools import ta5g_interface_tools
from ta5g_testline_management import ta5g_testline_management


ta_commissioning_instance = ta5g_commissioning()
tshark_instance = ta5g_tshark()


def add_5_additional_interfaces_for_handling_6_simulated_amfs():
    vm_management_instance = ta5g_testline_management()
    vm_management_instance.start_vm_ethernet_interface('eth3:amf2', '10.0.1.21/24')
    vm_management_instance.start_vm_ethernet_interface('eth3:amf3', '10.0.1.22/24')
    vm_management_instance.start_vm_ethernet_interface('eth3:amf4', '10.0.1.23/24')
    vm_management_instance.start_vm_ethernet_interface('eth3:amf5', '10.0.1.24/24')
    vm_management_instance.start_vm_ethernet_interface('eth3:amf6', '10.0.1.25/24')


@contextmanager
def gnb_fsm_access_manager(alias, teardown_session=True):
    fsm_access_instance = ute_fsmaccess()
    try:
        fsm_access_instance.setup_enb_fsm_access(alias=alias)
        yield fsm_access_instance
    finally:
        if teardown_session:
            fsm_access_instance.teardown_enb_fsm_access(alias=alias)
        else:
            pass


@contextmanager
def airphone_fsm_access_manager(alias, teardown_session=True):
    fsm_access_instance = ute_fsmaccess()
    try:
        fsm_access_instance.setup_wts_fsm_access(alias=alias)
        yield fsm_access_instance
    finally:
        if teardown_session:
            fsm_access_instance.teardown_wts_fsm_access(alias=alias)
        else:
            pass


@contextmanager
def packets_counting(packet_filter, packet_number=1, waiting_timeout=30, alias='default_uu'):
    ute_tshark_instance = BuiltIn().get_library_instance('ute_tshark')
    ute_tshark_instance.start_counting_packets(packet_filter=packet_filter, alias=alias)
    try:
        yield
        ute_tshark_instance.wait_for_given_packets_number(
            packet_number=packet_number,
            timeout=waiting_timeout,
            alias=alias
        )
    finally:
        ute_tshark_instance.stop_counting_packets(alias=alias)


def deactivate_barring():
    with packets_counting(feature_variables.BARRING_INFO_ABSENCE_FILTER):
        ta_commissioning_instance.find_scfc_and_send_delta_commissioning(
            scfc_filename=feature_variables.DELTA_DEACTIVATE_BARRING)


def activate_barring_and_check_it_on_f1_and_uu_interfaces(barring_type):
    activation_delta, packet_filter = {
        'explicit': (feature_variables.DELTA_ACTIVATE_BARRING_WITH_EXPLICIT_LIST,
                     feature_variables.SIB1_BARRING_INFO_EXPLICIT_FILTER),
        'implicit': (feature_variables.DELTA_ACTIVATE_BARRING_WITH_IMPLICIT_LIST,
                     feature_variables.SIB1_BARRING_INFO_IMPLICIT_FILTER)}[barring_type]
    with packets_counting(packet_filter):
        activate_barring_with_f1_gnb_du_configuration_update_check(activation_delta)


def activate_barring_with_f1_gnb_du_configuration_update_check(activation_delta):
    ta5g_commissioning().find_scfc_and_send_delta_commissioning(activation_delta)


def deactivate_barring_by_faf_only_and_check_it_on_f1_and_uu_interfaces():
    with packets_counting(feature_variables.SIB1_BARRING_INFO_WITH_UAC_BARRING_INFO_SET_LIST_ONLY):
        switch_faf('false')


def activate_barring_by_faf_only_and_check_it_on_f1_and_uu_interfaces():
    with packets_counting(feature_variables.SIB1_BARRING_INFO_IMPLICIT_FILTER):
        switch_faf('true')


def switch_faf(value):
    with ta_admin_interface.admin_interface() as admin_session:
        admin_session.perform_parameter_recommissioning(
            dist_name="MRBTS-1/NRBTS-1",
            parameter='actUacBarPerPlmn',
            operation='update',
            value=value,
            skip_parameter_relation_errors=True,
        )


def check_barring_absence_in_sib1_only_in_first_test():
    var_to_check = BuiltIn().get_variable_value('${WAS_ONE_TEST_EXECUTED}')
    if var_to_check is None:
        check_sibs()


def check_sibs():
    BuiltIn().set_suite_variable("${WAS_ONE_TEST_EXECUTED}", True)
    barring_absence_check_in_sib1()


def barring_absence_check_in_sib1():
    time.sleep(15)
    time_stamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    before_time_stamp_filter = '{} && frame.time <= "{}"'.format(
        feature_variables.BARRING_INFO_ABSENCE_FILTER, time_stamp)
    logger.info("filter: {}".format(before_time_stamp_filter), also_console=True)
    pcap_file_path = "{}/{}".format(ta5g_interface_tools().get_robot_output_dir(), 'UU_first_sibs.pcap')
    verify_tcpdump_log(
        before_time_stamp_filter,
        number_of_messages=1,
        pcap_file_path=pcap_file_path,
        timeout=30,
        relation_symbol='>=',
        alias='UU_first_sibs'
    )


def verify_tcpdump_log(packet_filter, number_of_messages=1, pcap_file_path='default', timeout=16, relation_symbol='==',
                       alias=None, continue_on_failure=True):
    pass_criteria = '{}{}'.format(relation_symbol, number_of_messages)
    tshark_instance.verify_tshark(
        alias=alias,
        packet_filter=packet_filter,
        pass_criteria=pass_criteria,
        pcap_file_path=pcap_file_path,
        timeout=timeout,
        continue_on_failure=continue_on_failure
    )


def start_uu_dedicated_tshark(log_dirpath=None):
    if log_dirpath is None:
        log_dirpath = ta5g_interface_tools().get_robot_output_dir()
    tshark_instance.start_tshark(
        log_filename='UU_first_sibs.pcap',
        eth_interface='eth4',
        capture_filter='less 1000',
        alias="UU_first_sibs",
        log_dirpath=log_dirpath,
    )
