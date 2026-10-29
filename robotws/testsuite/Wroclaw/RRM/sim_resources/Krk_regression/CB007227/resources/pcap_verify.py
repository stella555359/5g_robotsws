"""
:copyright: Nokia Networks
:author: Justyna Balcerzak
:maintainer: Justyna Balcerzak
:contact: justyna.balcerzak@nokia.com
"""
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.CB007227.resources.suite_specific_keywords import (
    get_test_prefix,
    get_test_prefix_number
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities \
    import logger_console, logger_info, logger_debug
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.tcpdump_verify import *
from ta5g_interface_tools import ta5g_interface_tools
from robot.libraries.BuiltIn import BuiltIn
from variables import *
import datetime
import os


def create_diff_list_from_timestamps(timestamps):
    diff_list = []
    for i in range(len(timestamps)):
        if i > 0:
            diff_list.append((timestamps[i] - timestamps[i - 1]).total_seconds())
    return diff_list


def check_if_values_in_list_are_positive(values_list, param_name, ue_id):
    for value in values_list:
        assert value > 0, 'Failed. Values from list are not grater then 0.' \
                          '\n Values list of param {} for UE{}: {}.'\
                          .format(param_name, ue_id, values_list)
    logger_console('SUCCESS. All values of param {} from list are grater then 0 for UE{}.'
                   .format(param_name, ue_id))


def check_if_values_in_list_are_zero(values_list, param_name, ue_id):
    for value in values_list:
        assert value == 0, 'Failed. Values from list are grater then 0.' \
                          '\n Values list of param {} for UE{}: {}.'\
                          .format(param_name, ue_id, values_list)
    logger_console('SUCCESS. All values of param {} from list are 0 for UE{}.'
                   .format(param_name, ue_id))


def check_if_values_in_list_are_between_range(values_list, param_name, start, end, ue_id=None):

    if ue_id is None:
        message_error = 'Failed. Values from list are not in range between {} - {}'.format(start, end)
        message_success = 'SUCCESS. All values of param {} from list are between range {}-{}'\
            .format(param_name, start, end)
    else:
        message_error = 'Failed. Values from list are not in range between {} - {}' \
                                '\n Values list of param {} for UE{}: {}.'\
                                .format(start, end, param_name, ue_id, values_list)
        message_success = 'SUCCESS. All values of param {} from list are between range {}-{} for UE{}.'\
            .format(param_name, start, end, ue_id)
    for value in values_list:
        assert start < value < end, message_error
    logger_console(msg=message_success)


def check_if_list_values_are_the_same(values_list, param_name, ue_id):
    assert len(set(values_list)) == 1, 'Failed. Values from list are not the same' \
                                        '\n Values list of param {} for UE{}: {}.'\
                                        .format(param_name, ue_id, values_list)
    logger_console('SUCCESS. All values of param {} from list are the same for UE{}.'.format(param_name, ue_id))


def check_if_list_values_are_the_same_as_nrcellid(values_list, param_name, ue_id):
    for value in values_list:
        assert value == NRCELL_ID, 'Failed. Values from list are not equal {}.' \
                          '\n Values list of param {} for UE{}: {}.'\
                          .format(NRCELL_ID, param_name, ue_id, values_list)
    logger_console('SUCCESS. All values of param {} from list are equal {} for UE{}.'
                   .format(NRCELL_ID, param_name, ue_id))


def count_percentage_difference_between_values(value1, value2):
    return round(abs((value1 - value2) / ((value1 + value2) / 2)) * 100, 2)


def check_if_no_gaps_in_messages_timestamps_for_ue(ue_id, timestamps):
    diff_list = create_diff_list_from_timestamps(timestamps)
    for time_diff in diff_list:
        assert time_diff > 3.09, 'Failed. Messages are too often ({}sec) for UE{}.' \
                                '\nTimestamps list: {}.' \
                                '\nDifferences list: {}'.format(time_diff, ue_id, timestamps, diff_list)
        assert time_diff < 5.09, 'Failed. Messages are too rarely ({}sec) for UE{}.' \
                                 '\nTimestamps list: {}.' \
                                 '\nDifferences list: {}'.format(time_diff, ue_id, timestamps, diff_list)
    logger_console('SUCCESS. Messages are sent approximately every 4 sec for UE{}.'.format(ue_id))


def get_itf_l2_nrt_SAvgIpLatency_sumOfDelay_params_for_ue(ue_id, number_of_ues_in_test, start_time=None,
                                                          traffic_duration=130, log_filepath=None):
    filter_prepared = "itf_l2_nrt_lotrace_pcmddlradiobearerrlcmeasind and itf_l2_nrt_savgiplatency"

    if start_time:
        filter_prepared += " and frame.time_epoch > {} and frame.time_epoch < {}" \
            .format(start_time, start_time + traffic_duration)

    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    if not log_filepath:
        log_filepath = log_dirpath + "/tshark.pcap"
    logger_debug(log_filepath)

    ue_uedu_map = None
    test_name = get_test_prefix_number()
    ue_uedu_map = UE_UEXU_MAP[test_name]
    logger_debug(ue_uedu_map)

    sumOfDelays = get_tshark_attribute_values_by_name(
        alias=ALIAS_TSHARK_VALIDATE,
        packet_filter=filter_prepared,
        element_xpath=".//proto[proto/field[@name='itf_l2_nrt_loTrace_PcmdDlRadioBearerRlcMeasInd_t.ueIdDu' "
                      "and @show='{}']]".format(ue_uedu_map[str(ue_id)]),
        attribute_name="itf_l2_nrt_SAvgIpLatency.sumOfDelay",
        pcap_file_path=log_filepath
    )
    sumOfDelays = [int(item) for item in sumOfDelays]
    return sumOfDelays


def get_itf_l2_nrt_SAvgIpLatency_numOfDelaySamples_params_for_ue(ue_id, number_of_ues_in_test, start_time=None,
                                                                 traffic_duration=130, log_filepath=None):
    filter_prepared = "itf_l2_nrt_lotrace_pcmddlradiobearerrlcmeasind and itf_l2_nrt_savgiplatency"

    if start_time:
        filter_prepared += " and frame.time_epoch > {} and frame.time_epoch < {}" \
            .format(start_time, start_time + traffic_duration)

    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    if not log_filepath:
        log_filepath = log_dirpath + "/tshark.pcap"
    logger_debug(log_filepath)

    ue_uedu_map = None
    test_name = get_test_prefix_number()
    ue_uedu_map = UE_UEXU_MAP[test_name]
    logger_debug(ue_uedu_map)

    numOfDelaySamples = get_tshark_attribute_values_by_name(
        alias=ALIAS_TSHARK_VALIDATE,
        packet_filter=filter_prepared,
        element_xpath=".//proto[proto/field[@name='itf_l2_nrt_loTrace_PcmdDlRadioBearerRlcMeasInd_t.ueIdDu' and "
                      "@show='{}']]".format(ue_uedu_map[str(ue_id)]),
        attribute_name="itf_l2_nrt_SAvgIpLatency.numOfDelaySamples",
        pcap_file_path=log_filepath
    )
    numOfDelaySamples = [int(item) for item in numOfDelaySamples]
    return numOfDelaySamples


def get_timestamps_for_itf_l2_nrt_lotrace_pcmddlradiobearerrlcmeasind_for_ue(
        ue_id, number_of_ues_in_test, start_time=None, traffic_duration=130, log_filepath=None):
    filter_prepared = "itf_l2_nrt_lotrace_pcmddlradiobearerrlcmeasind and itf_l2_nrt_savgiplatency"

    if start_time:
        filter_prepared += " and frame.time_epoch > {} and frame.time_epoch < {}" \
            .format(start_time, start_time + traffic_duration)

    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    if not log_filepath:
        log_filepath = log_dirpath + "/tshark.pcap"
    logger_debug(log_filepath)

    ue_uedu_map = None
    test_name = get_test_prefix_number()
    ue_uedu_map = UE_UEXU_MAP[test_name]
    logger_debug(ue_uedu_map)

    timestamps = get_timestamps_from_tshark_messages(
        alias=ALIAS_TSHARK_VALIDATE,
        filter=filter_prepared,
        element_xpath=".//packet[proto/proto//field[@name='itf_l2_nrt_loTrace_PcmdDlRadioBearerRlcMeasInd_t.ueIdDu' "
                      "and @show='{}']]".format(ue_uedu_map[str(ue_id)]),
        pcap_file_path=log_filepath
    )
    datetime_list = []
    # remove last time from list
    timestamps.pop()
    for i in range(len(timestamps)):
        datetime_list.append(datetime.datetime.fromtimestamp(float(timestamps[i])))
    return datetime_list


def validate_no_itf_l2_nrt_lotrace_pcmddlradiobearerrlcmeasind_with_SAvgIpLatency_existance(log_filepath=None):

    filter_prepared = "itf_l2_nrt_lotrace_pcmddlradiobearerrlcmeasind and itf_l2_nrt_savgiplatency"

    if not log_filepath:
        log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
        log_filepath = log_dirpath + "/tshark.pcap"

    verify_gnb_tcpdump_no_packet_existence(
        alias=ALIAS_TSHARK_VALIDATE, packet_filter=filter_prepared, pcap_file_path=log_filepath)


def check_if_first_value_from_itf_l2_nrt_sumOfDelay_values_after_start_traffic_is_greater_then_zero(
        ue_id, number_of_ues_in_test, start_time, traffic_duration, log_filepath=None):
    itf_l2_nrt_sumOfDelay_values_during_traffic = get_itf_l2_nrt_SAvgIpLatency_sumOfDelay_params_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=log_filepath)

    assert itf_l2_nrt_sumOfDelay_values_during_traffic[0] > 0, \
        'Failed. First value of itf_l2_nrt_SAvgIpLatency_sumOfDelay for UE{} after traffic start is equal to 0.'\
        .format(ue_id)
    logger_console('SUCCESS. First value of itf_l2_nrt_SAvgIpLatency_sumOfDelay for UE{} after traffic start is bigger '
                   'then 0.'.format(ue_id))


def check_if_first_value_from_itf_l2_nrt_numOfDelaySamples_values_after_start_traffic_is_greater_then_zero(
        ue_id, number_of_ues_in_test, start_time, traffic_duration, log_filepath=None):
    itf_l2_nrt_numOfDelaySamples_values_during_traffic = get_itf_l2_nrt_SAvgIpLatency_numOfDelaySamples_params_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=log_filepath)

    assert itf_l2_nrt_numOfDelaySamples_values_during_traffic[0] > 0, \
        'Failed. First value of itf_l2_nrt_numOfDelaySamples for UE{} after traffic start is equal to 0.'.format(ue_id)
    logger_console('SUCCESS. First value of itf_l2_nrt_numOfDelaySamples for UE{} after traffic start is bigger '
                   'then 0.'.format(ue_id))


def get_nsetapx_sumOfDelays_params_for_ue(ue_id, number_of_ues_in_test, start_time=None,
                                          traffic_duration=130, log_filepath=None):
    filter_prepared = "nsetapx.DlRadioBearerRlcMeasData_element and nsetapx.avgIpLatency_element"

    if start_time:
        filter_prepared += " and frame.time_epoch > {} and frame.time_epoch < {}" \
            .format(start_time, start_time + traffic_duration)

    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    if not log_filepath:
        log_filepath = log_dirpath + "/ipCapture.pcap"

    ue_hex_map = None
    if number_of_ues_in_test == 2:
        ue_hex_map = BuiltIn().get_variable_value("${UE_HEX_MAP_2UE}")
    elif number_of_ues_in_test == 4:
        ue_hex_map = BuiltIn().get_variable_value("${UE_HEX_MAP_4UE}")

    filter_prepared += " and nsetapx.ranUeId == {}".format(ue_hex_map[str(ue_id)])

    sumOfDelays = get_tshark_attribute_values_by_name(
        alias=ALIAS_TCPDUMP_GNB,
        packet_filter=filter_prepared,
        attribute_name="nsetapx.sumOfDelays",
        element_xpath=".//field[@name='nsetapx.DuRecordingSessionReport_element'][descendant::field"
                      "[@name='nsetapx.sumOfDelays'] and descendant::field[@name='nsetapx.ranUeId' "
                      "and @show='{}']]".format(ue_hex_map[ue_id]),
        pcap_file_path=log_filepath
    )
    sumOfDelays = [int(item) for item in sumOfDelays]
    return sumOfDelays


def get_nsetapx_numOfRlcSdus_params_for_ue(ue_id, number_of_ues_in_test, start_time=None,
                                           traffic_duration=130, log_filepath=None):
    filter_prepared = "nsetapx.DlRadioBearerRlcMeasData_element and nsetapx.avgIpLatency_element"

    if start_time:
        filter_prepared += " and frame.time_epoch > {} and frame.time_epoch < {}" \
            .format(start_time, start_time + traffic_duration)

    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())

    if not log_filepath:
        log_filepath = log_dirpath + "/ipCapture.pcap"

    ue_hex_map = None
    if number_of_ues_in_test == 2:
        ue_hex_map = BuiltIn().get_variable_value("${UE_HEX_MAP_2UE}")
    elif number_of_ues_in_test == 4:
        ue_hex_map = BuiltIn().get_variable_value("${UE_HEX_MAP_4UE}")

    filter_prepared += " and nsetapx.ranUeId == {}".format(ue_hex_map[str(ue_id)])

    numOfRlcSdus = get_tshark_attribute_values_by_name(
        alias=ALIAS_TCPDUMP_GNB,
        packet_filter=filter_prepared,
        attribute_name="nsetapx.numOfRlcSdus",
        element_xpath=".//field[@name='nsetapx.DuRecordingSessionReport_element'][descendant::field"
                      "[@name='nsetapx.sumOfDelays'] and descendant::field[@name='nsetapx.ranUeId' "
                      "and @show='{}']]".format(ue_hex_map[ue_id]),
        pcap_file_path=log_filepath
    )
    numOfRlcSdus = [int(item) for item in numOfRlcSdus]
    return numOfRlcSdus


def get_timestamps_for_nsetapx_DlRadioBearerRlcMeasData_for_ue(ue_id, number_of_ues_in_test, start_time=None,
                                                               traffic_duration=130, log_filepath=None):
    filter_prepared = "nsetapx.DlRadioBearerRlcMeasData_element and nsetapx.avgIpLatency_element"

    if start_time:
        filter_prepared += " and frame.time_epoch > {} and frame.time_epoch < {}" \
            .format(start_time, start_time + traffic_duration)

    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    if not log_filepath:
        log_filepath = log_dirpath + "/ipCapture.pcap"

    ue_hex_map = None
    if number_of_ues_in_test == 2:
        ue_hex_map = BuiltIn().get_variable_value("${UE_HEX_MAP_2UE}")
    elif number_of_ues_in_test == 4:
        ue_hex_map = BuiltIn().get_variable_value("${UE_HEX_MAP_4UE}")

    filter_prepared += " and nsetapx.ranUeId == {}".format(ue_hex_map[str(ue_id)])

    timestamps_seconds = get_timestamps_from_tshark_messages(
        alias=ALIAS_TSHARK_VALIDATE,
        filter=filter_prepared,
        element_xpath=".//field[@name='nsetapx.DuRecordingSessionReport_element'][descendant::field"
                      "[@name='nsetapx.sumOfDelays'] and descendant::field[@name='nsetapx.ranUeId' and @show='{}']]"
                      .format(ue_hex_map[str(ue_id)]),
        attribute_xpath='.//field[@name="nsetapx.seconds"]',
        attribute='show',
        pcap_file_path=log_filepath
    )
    timestamps_microseconds = get_timestamps_from_tshark_messages(
        alias=ALIAS_TSHARK_VALIDATE,
        filter=filter_prepared,
        element_xpath=".//field[@name='nsetapx.DuRecordingSessionReport_element'][descendant::field"
                      "[@name='nsetapx.sumOfDelays'] and descendant::field[@name='nsetapx.ranUeId' and "
                      "@show='{}']]".format(ue_hex_map[str(ue_id)]),
        attribute_xpath='.//field[@name="nsetapx.useconds"]',
        attribute='show',
        pcap_file_path=log_filepath
    )
    timestamps = []
    for i in range(min(len(timestamps_seconds), len(timestamps_microseconds))):
        timestamps.append(timestamps_seconds[i] + '.' + timestamps_microseconds[i])
    datetime_list = []
    # remove last time from list
    timestamps.pop()
    for i in range(len(timestamps)):
        datetime_list.append(datetime.datetime.fromtimestamp(float(timestamps[i])))
    return datetime_list


def check_if_nsetapx_sumOfDelays_and_itf_l2_nrt_sumOfDelay_values_are_identical(
        ue_id, number_of_ues_in_test, start_time, traffic_duration, ipcapture_filepath=None, tshark_filepath=None):
    nsetapx_sumOfDelays_values_during_traffic = get_nsetapx_sumOfDelays_params_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=ipcapture_filepath)

    itf_l2_nrt_sumOfDelay_values_during_traffic = get_itf_l2_nrt_SAvgIpLatency_sumOfDelay_params_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=tshark_filepath)

    # remove first or last element from longer list when time movement in logs appeared
    if len(nsetapx_sumOfDelays_values_during_traffic) > len(itf_l2_nrt_sumOfDelay_values_during_traffic):
        if nsetapx_sumOfDelays_values_during_traffic[0] == itf_l2_nrt_sumOfDelay_values_during_traffic[0]:
            nsetapx_sumOfDelays_values_during_traffic.pop()
        else:
            nsetapx_sumOfDelays_values_during_traffic.pop(0)
    elif len(nsetapx_sumOfDelays_values_during_traffic) < len(itf_l2_nrt_sumOfDelay_values_during_traffic):
        if nsetapx_sumOfDelays_values_during_traffic[0] == itf_l2_nrt_sumOfDelay_values_during_traffic[0]:
            itf_l2_nrt_sumOfDelay_values_during_traffic.pop()
        else:
            itf_l2_nrt_sumOfDelay_values_during_traffic.pop(0)

    assert nsetapx_sumOfDelays_values_during_traffic == itf_l2_nrt_sumOfDelay_values_during_traffic, \
        'Failed. Values of nsetapx_sumOfDelays and itf_l2_nrt_SAvgIpLatency_sumOfDelay during traffic are not ' \
        'the same for UE{}.' \
        '\nValues from nsetapx_sumOfDelays are: {}. ' \
        '\nValues from itf_l2_nrt_sumOfDelay are: {}.' \
        .format(ue_id, nsetapx_sumOfDelays_values_during_traffic, itf_l2_nrt_sumOfDelay_values_during_traffic)
    logger_console('SUCCESS. Values of nsetapx_sumOfDelays and itf_l2_nrt_SAvgIpLatency_sumOfDelay during traffic'
                   'are the same for UE{}.'.format(ue_id))


def check_if_nsetapx_numOfRlcSdus_and_itf_l2_nrt_numOfDelaySamples_values_are_identical(
        ue_id, number_of_ues_in_test, start_time, traffic_duration, ipcapture_filepath=None, tshark_filepath=None):
    nsetapx_numOfRlcSdus_values_during_traffic = get_nsetapx_numOfRlcSdus_params_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=ipcapture_filepath)

    itf_l2_nrt_numOfDelaySamples_values_during_traffic = get_itf_l2_nrt_SAvgIpLatency_numOfDelaySamples_params_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=tshark_filepath)

    # remove first or last element from longer list when time movement in logs appeared
    if len(nsetapx_numOfRlcSdus_values_during_traffic) > len(itf_l2_nrt_numOfDelaySamples_values_during_traffic):
        if nsetapx_numOfRlcSdus_values_during_traffic[0] == itf_l2_nrt_numOfDelaySamples_values_during_traffic[0]:
            nsetapx_numOfRlcSdus_values_during_traffic.pop()
        else:
            nsetapx_numOfRlcSdus_values_during_traffic.pop(0)
    elif len(nsetapx_numOfRlcSdus_values_during_traffic) < len(itf_l2_nrt_numOfDelaySamples_values_during_traffic):
        if nsetapx_numOfRlcSdus_values_during_traffic[0] == itf_l2_nrt_numOfDelaySamples_values_during_traffic[0]:
            itf_l2_nrt_numOfDelaySamples_values_during_traffic.pop()
        else:
            itf_l2_nrt_numOfDelaySamples_values_during_traffic.pop(0)

    assert nsetapx_numOfRlcSdus_values_during_traffic == itf_l2_nrt_numOfDelaySamples_values_during_traffic, \
        'Failed. Values of nsetapx_numOfRlcSdus and itf_l2_nrt_numOfDelaySamples during traffic are not ' \
        'the same for UE{}.' \
        '\nValues from nsetapx_numOfRlcSdus are: {}. ' \
        '\nValues from itf_l2_nrt_numOfDelaySamples are: {} .'\
        .format(ue_id, nsetapx_numOfRlcSdus_values_during_traffic, itf_l2_nrt_numOfDelaySamples_values_during_traffic)

    logger_console('SUCCESS. Values of nnsetapx_numOfRlcSdus and itf_l2_nrt_numOfDelaySamples during traffic are '
                   'the same for UE{}.'.format(ue_id))


def validate_test_C004(ue_id, start_time):
    number_of_ues_in_test = 2
    traffic_duration = 130

    logger_console("Start checking gaps in timestamps for message itf_l2_nrt_lotrace_pcmddlradiobearerrlcmeasind:")
    timestamps = get_timestamps_for_itf_l2_nrt_lotrace_pcmddlradiobearerrlcmeasind_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test)
    check_if_no_gaps_in_messages_timestamps_for_ue(
        ue_id=ue_id, timestamps=timestamps)

    itf_l2_nrt_sumOfDelay_values_during_traffic = get_itf_l2_nrt_SAvgIpLatency_sumOfDelay_params_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        start_time=start_time, traffic_duration=traffic_duration)
    check_if_values_in_list_are_positive(values_list=itf_l2_nrt_sumOfDelay_values_during_traffic,
                                         param_name='itf_l2_nrt_sumOfDelay', ue_id=ue_id)

    itf_l2_nrt_numOfDelaySamples_values_during_traffic = \
        get_itf_l2_nrt_SAvgIpLatency_numOfDelaySamples_params_for_ue(
            ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
            start_time=start_time, traffic_duration=traffic_duration)
    check_if_values_in_list_are_positive(values_list=itf_l2_nrt_numOfDelaySamples_values_during_traffic,
                                         param_name='itf_l2_nrt_numOfDelaySamples', ue_id=ue_id)


def validate_test_C014_for_ue(ue_id, start_time):
    number_of_ues_in_test = 2
    traffic_duration = 130

    check_if_nsetapx_sumOfDelays_and_itf_l2_nrt_sumOfDelay_values_are_identical(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, start_time=start_time,
        traffic_duration=traffic_duration)

    check_if_nsetapx_numOfRlcSdus_and_itf_l2_nrt_numOfDelaySamples_values_are_identical(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, start_time=start_time,
        traffic_duration=traffic_duration)

    check_if_first_value_from_itf_l2_nrt_sumOfDelay_values_after_start_traffic_is_greater_then_zero(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, start_time=start_time,
        traffic_duration=traffic_duration
    )

    check_if_first_value_from_itf_l2_nrt_numOfDelaySamples_values_after_start_traffic_is_greater_then_zero(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, start_time=start_time,
        traffic_duration=traffic_duration
    )


def validate_test_C005_C006_first_or_third_step_for_ue(ue_id, start_time, step="1"):
    number_of_ues_in_test = 4
    traffic_duration = 130

    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    tshark_filepath = log_dirpath + '/step_' + step + '/tshark.pcap'
    ipCapture_filepath = log_dirpath + '/step_' + step + '/ipCapture.pcap'

    logger_console("Start checking gaps in timestamps for message nsetapx_DlRadioBearerRlcMeasData:")
    timestamps = get_timestamps_for_nsetapx_DlRadioBearerRlcMeasData_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, log_filepath=ipCapture_filepath)
    check_if_no_gaps_in_messages_timestamps_for_ue(
        ue_id=ue_id, timestamps=timestamps)

    nsetapx_sumOfDelays_values_during_traffic = get_nsetapx_sumOfDelays_params_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, log_filepath=ipCapture_filepath,
        start_time=start_time, traffic_duration=traffic_duration)
    check_if_values_in_list_are_positive(values_list=nsetapx_sumOfDelays_values_during_traffic,
                                         param_name='nsetapx_sumOfDelays', ue_id=ue_id)

    nsetapx_numOfRlcSdus_values_during_traffic = get_nsetapx_numOfRlcSdus_params_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, log_filepath=ipCapture_filepath,
        start_time=start_time, traffic_duration=traffic_duration)
    check_if_values_in_list_are_positive(values_list=nsetapx_numOfRlcSdus_values_during_traffic,
                                         param_name='nsetapx_numOfRlcSdus', ue_id=ue_id)


def validate_test_C005_C006_second_step_for_ue(ue_id, start_time):
    number_of_ues_in_test = 4
    traffic_duration = 130

    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    tshark_filepath = log_dirpath + '/step_2' + '/tshark.pcap'
    ipcapture_filepath = log_dirpath + '/step_2' + '/ipCapture.pcap'

    logger_console("Start checking gaps in timestamps for message nsetapx_DlRadioBearerRlcMeasData:")
    timestamps = get_timestamps_for_nsetapx_DlRadioBearerRlcMeasData_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, log_filepath=ipcapture_filepath)
    check_if_no_gaps_in_messages_timestamps_for_ue(
        ue_id=ue_id, timestamps=timestamps)

    check_if_nsetapx_sumOfDelays_and_itf_l2_nrt_sumOfDelay_values_are_identical(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, start_time=start_time,
        traffic_duration=traffic_duration, ipcapture_filepath=ipcapture_filepath, tshark_filepath=tshark_filepath)

    check_if_nsetapx_numOfRlcSdus_and_itf_l2_nrt_numOfDelaySamples_values_are_identical(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, start_time=start_time,
        traffic_duration=traffic_duration, ipcapture_filepath=ipcapture_filepath, tshark_filepath=tshark_filepath)

    check_if_first_value_from_itf_l2_nrt_sumOfDelay_values_after_start_traffic_is_greater_then_zero(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, start_time=start_time,
        traffic_duration=traffic_duration, log_filepath=tshark_filepath)

    check_if_first_value_from_itf_l2_nrt_numOfDelaySamples_values_after_start_traffic_is_greater_then_zero(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, start_time=start_time,
        traffic_duration=traffic_duration, log_filepath=tshark_filepath)


def validate_test_C005_C006_compare_sumOfDelays_percentage_difference_between_two_given_steps_for_ue(
        ue_id, first_step, second_step):
    number_of_ues_in_test = 4
    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    ipCapture_filepath_first_step = log_dirpath + '/step_' + first_step + '/ipCapture.pcap'
    ipCapture_filepath_second_step = log_dirpath + '/step_' + second_step + '/ipCapture.pcap'

    nsetapx_sumOfDelays_values_first_step = get_nsetapx_sumOfDelays_params_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, log_filepath=ipCapture_filepath_first_step)
    sum_of_values_first_step = sum(nsetapx_sumOfDelays_values_first_step)

    nsetapx_sumOfDelays_values_second_step = get_nsetapx_sumOfDelays_params_for_ue(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, log_filepath=ipCapture_filepath_second_step)
    sum_of_values_second_step = sum(nsetapx_sumOfDelays_values_second_step)

    percentage_difference_value = count_percentage_difference_between_values(
        sum_of_values_first_step, sum_of_values_second_step)

    assert percentage_difference_value < 15.0, \
        'Warning. Difference between sums of nsetapx_sumOfDelays values from {} and {} traffic steps for UE{}' \
        ' is greater then 15%. This is {}%. \nValues from first step: {}. \nValues from second step: {}.\n' \
        .format(first_step, second_step, ue_id, percentage_difference_value, nsetapx_sumOfDelays_values_first_step,
                nsetapx_sumOfDelays_values_second_step)
    logger_console('SUCCESS. Difference between sums of nsetapx_sumOfDelays values from {} and {} traffic step '
                   'steps for UE{} is {}%.'.format(first_step, second_step, ue_id, percentage_difference_value))


def get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction(
        ue_id, number_of_ues_in_test, attribute_value, direction='dl', start_time=None,
        traffic_duration=130, log_filepath=None, step=None):

    filter_prepared = "itf_l2_hi_cu_trace_pcmd{}radiobearerpdcpmeasind".format(direction)
    if start_time:
        filter_prepared += " and frame.time_epoch > {} and frame.time_epoch < {}" \
            .format(start_time, start_time + traffic_duration)

    if not log_filepath:
        log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
        if step is not None:
            log_filepath = log_dirpath + '/step_' + step + '/tshark.pcap'
        else:
            log_filepath = log_dirpath + "/tshark.pcap"
    logger_debug(log_filepath)

    ue_uecu_map = None
    test_name = get_test_prefix_number()
    ue_uecu_map = UE_UEXU_MAP[test_name]
    logger_debug(ue_uecu_map)

    ueIdCu_xpath = ".//packet/proto/proto[@name='aatrace_mon_ind'][field[@name='MON_IND.data']//field"\
        "[@name='itf_l2_hi_cu_trace_Pcmd{}RadioBearerPdcpMeasInd_t.ueIdCu' and @show='{}']]"\
        .format(direction.capitalize(), ue_uecu_map[str(ue_id)])

    paramValues = get_tshark_attribute_values_by_name(
        alias=ALIAS_TSHARK_VALIDATE,
        packet_filter=filter_prepared,
        element_xpath=ueIdCu_xpath,
        attribute_name=attribute_value,
        pcap_file_path=log_filepath
    )
    paramValuesFixed = []
    for item in paramValues:
        if item == 'False':
            paramValuesFixed.append(0)
        else:
            paramValuesFixed.append(int(item))
    return paramValuesFixed


def get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_syscom_massage_length(
        attribute_value, direction='dl', start_time=None, traffic_duration=130, log_filepath=None, step=None):

    filter_prepared = "itf_l2_hi_cu_trace_pcmd{}radiobearerpdcpmeasind".format(direction)
    if start_time:
        filter_prepared += " and frame.time_epoch > {} and frame.time_epoch < {}" \
            .format(start_time, start_time + traffic_duration)

    if not log_filepath:
        log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
        if step is not None:
            log_filepath = log_dirpath + '/step_' + step + '/tshark.pcap'
        else:
            log_filepath = log_dirpath + "/tshark.pcap"
    logger_debug(msg=log_filepath)
    ueIdCu_xpath = ".//packet/proto[@name='syscom']"

    paramValues = get_tshark_attribute_values_by_name(
        alias=ALIAS_TSHARK_VALIDATE,
        packet_filter=filter_prepared,
        element_xpath=ueIdCu_xpath,
        attribute_name=attribute_value,
        pcap_file_path=log_filepath
    )
    paramValues = [int(item) for item in paramValues]
    return paramValues


def validate_syscom_message_length(direction="dl", start_time=None, traffic_duration=130, log_filepath=None, step=None):
    attribute_name = "sic.length"
    packets_length = get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_syscom_massage_length(
        attribute_value=attribute_name, direction=direction,
        start_time=start_time, traffic_duration=traffic_duration, step=step, log_filepath=log_filepath
    )
    check_if_values_in_list_are_between_range(
        values_list=packets_length, param_name=attribute_name, start=0, end=MAXIMUM_PACKET_LENGTH
    )


def validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_sumOfPdcpSduXxBytes(
        ue_id, number_of_ues_in_test=2, direction="dl", start_time=None, traffic_duration=130, log_filepath=None,
        step=None):

    rxOrTx = 'Tx' if direction == "dl" else "Rx"
    sumOfPdcpSduTxBytes_values = get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        attribute_value="itf_l2_hi_cu_trace_{}RadioBearerPdcpMeasData.sumOfPdcpSdu{}Bytes"
        .format(direction.capitalize(), rxOrTx), direction=direction,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=log_filepath, step=step
    )
    check_if_values_in_list_are_positive(
        values_list=sumOfPdcpSduTxBytes_values,
        param_name="itf_l2_hi_cu_trace_{}RadioBearerPdcpMeasData.sumOfPdcpSdu{}Bytes"
        .format(direction.capitalize(), rxOrTx), ue_id=ue_id
    )


def validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_sumOfPdcpXxBytesDiscarded(
        ue_id, number_of_ues_in_test=2, direction="dl", start_time=None, traffic_duration=130, log_filepath=None,
        step=None):

    rxOrTx = 'Tx' if direction == "dl" else "Rx"
    sumOfPdcpTxBytesDiscarded_values = get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        attribute_value="itf_l2_hi_cu_trace_{}RadioBearerPdcpMeasData.sumOfPdcp{}BytesDiscarded"
        .format(direction.capitalize(), rxOrTx), direction=direction,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=log_filepath, step=step
    )
    check_if_values_in_list_are_zero(
        values_list=sumOfPdcpTxBytesDiscarded_values,
        param_name="itf_l2_hi_cu_trace_{}RadioBearerPdcpMeasData.sumOfPdcp{}BytesDiscarded"
        .format(direction.capitalize(), rxOrTx), ue_id=ue_id
    )


def validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_dataCollectionDuration(
        ue_id, number_of_ues_in_test=2, direction="dl", start_time=None, traffic_duration=130, log_filepath=None,
        step=None):

    rxOrTx = 'Tx' if direction == "dl" else "Rx"
    dataCollectionDuration_values = get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        attribute_value="itf_l2_hi_cu_trace_{}RadioBearerPdcpMeasData.dataCollectionDuration"
        .format(direction.capitalize()), direction=direction,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=log_filepath, step=step
    )
    check_if_values_in_list_are_positive(
        values_list=dataCollectionDuration_values,
        param_name="itf_l2_hi_cu_trace_{}RadioBearerPdcpMeasData.dataCollectionDuration".format(direction.capitalize()),
        ue_id=ue_id
    )


def validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_drbId(
        ue_id, number_of_ues_in_test=2, direction="dl", start_time=None, traffic_duration=130, log_filepath=None,
        step=None):

    rxOrTx = 'Tx' if direction == "dl" else "Rx"
    drbId_values = get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        attribute_value="itf_l2_hi_cu_trace_{}RadioBearerPdcpMeasData.drbId"
        .format(direction.capitalize()), direction=direction,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=log_filepath, step=step
    )
    check_if_values_in_list_are_between_range(
        values_list=drbId_values, param_name="itf_l2_hi_cu_trace_{}RadioBearerPdcpMeasData."
        "drbId".format(direction.capitalize()), ue_id=ue_id, start=0, end=255
    )
    check_if_list_values_are_the_same(
        values_list=drbId_values, param_name="itf_l2_hi_cu_trace_{}"
        "RadioBearerPdcpMeasData.drbId".format(direction.capitalize()), ue_id=ue_id
    )


def validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_isLast(
        ue_id, number_of_ues_in_test=2, direction="dl", start_time=None, traffic_duration=130, log_filepath=None,
        step=None):

    rxOrTx = 'Tx' if direction == "dl" else "Rx"
    isLast_values = get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        attribute_value="itf_l2_hi_cu_trace_{}RadioBearerPdcpMeasData.isLast"
        .format(direction.capitalize()), direction=direction,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=log_filepath, step=step
    )
    check_if_values_in_list_are_zero(
        values_list=isLast_values,
        param_name="itf_l2_hi_cu_trace_{}RadioBearerPdcpMeasData.isLast".format(direction.capitalize()),
        ue_id=ue_id
    )


def validate_itf_l2_hi_cu_trace_PcmdRadioBearerPdcpMeasInd_t_nrCellId_item(
        ue_id, number_of_ues_in_test=2, direction="dl", start_time=None, traffic_duration=130, log_filepath=None,
        step=None):

    rxOrTx = 'Tx' if direction == "dl" else "Rx"
    nrCellId_values = get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test,
        attribute_value="itf_l2_hi_cu_trace_Pcmd{}RadioBearerPdcpMeasInd_t.nrCellId_item"
        .format(direction.capitalize()), direction=direction,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=log_filepath, step=step
    )
    check_if_list_values_are_the_same_as_nrcellid(
        values_list=nrCellId_values, param_name="itf_l2_hi_cu_trace_Pcmd{}"
        "RadioBearerPdcpMeasInd_t.nrCellId_item".format(direction.capitalize()), ue_id=ue_id
    )


def validate_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_sic_length(
        ue_id, number_of_ues_in_test=2, direction="dl", start_time=None, traffic_duration=130, log_filepath=None,
        step=None):

    rxOrTx = 'Tx' if direction == "dl" else "Rx"
    length_of_packets = get_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_params_for_attribute_ue_direction(
        ue_id=ue_id, number_of_ues_in_test=number_of_ues_in_test, attribute_value="sic.length", direction=direction,
        start_time=start_time, traffic_duration=traffic_duration, log_filepath=log_filepath, step=step
    )
    check_if_values_in_list_are_between_range(
        values_list=length_of_packets, param_name="sic.length", ue_id=ue_id, start=0, end=MAXIMUM_PACKET_LENGTH
    )


def get_timestamps_for_itf_l2_hi_cu_trace_radiobearerpdcpmeasdata_for_ue_and_direction(
        ue_id, number_of_ues_in_test, direction="dl", start_time=None, traffic_duration=130,
        log_filepath=None, step=None
        ):

    filter_prepared = "itf_l2_hi_cu_trace_pcmd{}radiobearerpdcpmeasind".format(direction)
    if start_time:
        filter_prepared += " and frame.time_epoch > {} and frame.time_epoch < {}" \
            .format(start_time, start_time + traffic_duration)

    if not log_filepath:
        log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
        if step is not None:
            log_filepath = log_dirpath + '/step_' + step + '/tshark.pcap'
        else:
            log_filepath = log_dirpath + "/tshark.pcap"
    logger_debug(log_filepath)

    ue_uecu_map = None
    test_name = get_test_prefix_number()
    ue_uecu_map = UE_UEXU_MAP[test_name]
    logger_debug(ue_uecu_map)

    ueIdCu_xpath = ".//packet[proto/proto//field[@name='itf_l2_hi_cu_trace_Pcmd{}RadioBearerPdcpMeasInd_t.ueIdCu' and "\
                   "@show='{}']]".format(direction.capitalize(), ue_uecu_map[str(ue_id)])

    timestamps = get_timestamps_from_tshark_messages(
        alias=ALIAS_TSHARK_VALIDATE,
        filter=filter_prepared,
        element_xpath=ueIdCu_xpath,
        pcap_file_path=log_filepath
    )
    datetime_list = []
    # remove last time from list
    timestamps.pop()
    for i in range(len(timestamps)):
        datetime_list.append(datetime.datetime.fromtimestamp(float(timestamps[i])))
    return datetime_list


# Xx means Dl or Ul
def check_the_message_itf_l2_hi_cu_trace_XxRadioBearerPdcpMeasData_not_exist(log_filepath=None, step=None):
    filter_prepared = "itf_l2_hi_cu_trace_pcmddlradiobearerpdcpmeasind"
    if not log_filepath:
        log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
        logger_debug("log_dirpath ", log_dirpath)
        if step is not None:
            log_filepath = log_dirpath + '/step_' + step + '/tshark.pcap'
        else:
            log_filepath = log_dirpath + "/tshark.pcap"
        logger_debug("log_filepath ", log_filepath)
    verify_gnb_tcpdump_no_packet_existence(
        alias=ALIAS_TSHARK_VALIDATE, packet_filter=filter_prepared, pcap_file_path=log_filepath)


def standardized_value_of_message_throughput_over_a_specified_period_of_time(
        sumOfPdcpSduXxBytes_values, traffic_duration=130):
    sumOfPdcpSduXxBytes_values = [int(val) if isinstance(val, str) else val for val in sumOfPdcpSduXxBytes_values]
    number_of_message = len(sumOfPdcpSduXxBytes_values)
    time_length_of_one_message = 4.096
    sumOfPdcpSduXxBytes = sum(sumOfPdcpSduXxBytes_values)
    sumOfPdcpSduXxBytes = sumOfPdcpSduXxBytes/(number_of_message*time_length_of_one_message)*traffic_duration/1000
    logger_debug("sumOfPdcpSduRxBytes : {}".format(sumOfPdcpSduXxBytes))
    return sumOfPdcpSduXxBytes


def set_counter_by_ue_to_validate(ue_id, direction="dl"):
    if not isinstance(ue_id, str):
        ue_id = str(ue_id)

    if ue_id == "1":
        logger_info("ue_id is equal ${}. Return Counter: {}".format(ue_id, PDCP_SDU_DATA_VOL_DL_SLICE))
        return PDCP_SDU_DATA_VOL_DL_SLICE if direction == "dl" else PDCP_SDU_DATA_VOL_UL_SLICE
    elif ue_id == "11":
        logger_info("ue_id is equal ${}. Return Counter: {}".format(ue_id, DL_PDCP_VOL_RCV_F1_QoS_GRP_09))
        return DL_PDCP_VOL_RCV_F1_QoS_GRP_09 if direction == "dl" else UL_PDCP_VOL_SNT_F1_QoS_GRP_09
    else:
        logger_info("Unexpected ue_id. ue_id is: {}".format(ue_id))
        raise ValueError("Unexpected ue_id. ue_id is: {}".format(ue_id))
