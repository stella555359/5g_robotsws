import csv
import subprocess
import glob
import re
import time
import math
import unicodedata
from collections import OrderedDict
from taf.sbts.oam.coam.admin import admin
from os import path, remove, system
from logging import info
from robot.errors import ExecutionFailed
from robot.api import logger


def verify_that_a_specific_message_meets_the_post_conditions_criteria(message, field, value, pdml_file):
    with open(pdml_file, 'r') as pdml_file:
        file_reader = pdml_file.readlines()
        is_field_found = False
        for line in file_reader:
            field_check = re.search("{}..".format(message), line) and re.search("{}".format(field), line)
            if field_check:
                value_check = re.search("{}.*show=\"{}\"".format(field, value), line)
                logger.info("Field found in: {}".format(line))
                is_field_found = True
                line_found = line

                if value_check:
                    break

        else:
            if is_field_found:
                msg = "Incorrect {} value in {}. Expected {}".format(field, line_found, value)
            else:
                msg = "Message {} with field {} not found".format(message, field)
            raise ExecutionFailed(message=msg, continue_on_failure=True)


def read_and_parse_tti_data(path_to_tti):
    with open(path_to_tti, 'r') as csv_file:
        csv_dict = csv.DictReader(csv_file)
        csv_reader = list(csv_dict)
        line_count = 0
        tti_dict = OrderedDict()
        for row in csv_reader:
            time_stamp = row["timeStamp"]
            if line_count == 0:
                tti_dict[time_stamp] = {"HarqRxDataDtx": [row["ulHarqRxData.dtx"]],
                                        "csListEvent": [row["ulPreSchedData.csListEvent"]],
                                        "ulHarqProcessIndex": [row["ulFdSchedData.ulHarqProcessIndex"]],
                                        "txNumber": [row["ulFdSchedData.txNumber"]],
                                        "ulProGrantType": [row["ulFdSchedData.ulProGrantType"]],
                                        "crc": [row["ulHarqRxData.crcResult"]],
                                        "sfn": [row["sfn"]],
                                        "slot": [row["slot"]],
                                        "rnti": [row["rnti"]],
                                        "reportType": [row["csiSrReportData.reportType"]],
                                        "bufferSizeIndex": [row["ulBsrRxData.bufferSizeIndex"]],
                                        "dlAckNack": [row["dlFdSchedData.ackNack"]]}
                line_count += 1
            else:
                if time_stamp in tti_dict:
                    for field in tti_dict[time_stamp]:
                        if field == "HarqRxDataDtx":
                            tti_dict[time_stamp][field].append(row["ulHarqRxData.dtx"])
                        elif field == "csListEvent":
                            tti_dict[time_stamp][field].append(row["ulPreSchedData.csListEvent"])
                        elif field == "ulHarqProcessIndex":
                            tti_dict[time_stamp][field].append(row["ulFdSchedData.ulHarqProcessIndex"])
                        elif field == "ulProGrantType":
                            tti_dict[time_stamp][field].append(row["ulFdSchedData.ulProGrantType"])
                        elif field == "crc":
                            tti_dict[time_stamp][field].append(row["ulHarqRxData.crcResult"])
                        elif field == "txNumber":
                            tti_dict[time_stamp][field].append(row["ulFdSchedData.txNumber"])
                        elif field == "sfn":
                            tti_dict[time_stamp][field].append(row["sfn"])
                        elif field == "slot":
                            tti_dict[time_stamp][field].append(row["slot"])
                        elif field == "rnti":
                            tti_dict[time_stamp][field].append(row["rnti"])
                        elif field == "reportType":
                            tti_dict[time_stamp][field].append(row["csiSrReportData.reportType"])
                        elif field == "bufferSizeIndex":
                            tti_dict[time_stamp][field].append(row["ulBsrRxData.bufferSizeIndex"])
                        elif field == "dlAckNack":
                            tti_dict[time_stamp][field].append(row["dlFdSchedData.ackNack"])
                else:
                    tti_dict.update({time_stamp: {"HarqRxDataDtx": [row["ulHarqRxData.dtx"]],
                                                  "csListEvent": [row["ulPreSchedData.csListEvent"]],
                                                  "ulHarqProcessIndex": [row["ulFdSchedData.ulHarqProcessIndex"]],
                                                  "ulProGrantType": [row["ulFdSchedData.ulProGrantType"]],
                                                  "crc": [row["ulHarqRxData.crcResult"]],
                                                  "txNumber": [row["ulFdSchedData.txNumber"]],
                                                  "sfn": [row["sfn"]],
                                                  "slot": [row["slot"]],
                                                  "rnti": [row["rnti"]],
                                                  "reportType": [row["csiSrReportData.reportType"]],
                                                  "bufferSizeIndex": [row["ulBsrRxData.bufferSizeIndex"]],
                                                  "dlAckNack": [row["dlFdSchedData.ackNack"]]}})
    return tti_dict


def verify_that_ul_proactive_grants_are_not_sent_to_ue(tti_path):
    tti_data = read_and_parse_tti_data(tti_path)
    tmp_list = []
    for time_stamp in tti_data:
        for field in tti_data[time_stamp]:
            if field == "csListEvent" and tti_data[time_stamp][field] != ['']:
                if 'ENTRYPROACTIVEPUSCH' in tti_data[time_stamp][field]:
                    tmp_list.append(tti_data[time_stamp][field][0])
    assert ("ENTRYPROACTIVEPUSCH" not in tmp_list), "Proactive grants are sent towards UE"


def verify_that_ul_proactive_grants_are_sent_to_ue(tti_path):
    tti_data = read_and_parse_tti_data(tti_path)
    tmp_list = []
    for time_stamp in tti_data:
        for field in tti_data[time_stamp]:
            if field == "csListEvent" and tti_data[time_stamp][field] != ['']:
                if 'ENTRYPROACTIVEPUSCH' in tti_data[time_stamp][field]:
                    tmp_list.append(tti_data[time_stamp][field][0])
    assert ("ENTRYPROACTIVEPUSCH" in tmp_list), "Proactive grants are not sent towards UE"


def verify_that_retransmission_for_skippable_grant_is_not_started(tti_trace_dict):
    harq_processes = set(())
    for entry in reversed(list(tti_trace_dict.items())):
        if entry[1]["rnti"] == ["65535"]:
            continue
        if len(harq_processes) > 0 and len(entry[1]["txNumber"][0]) > 0 and float(entry[1]["txNumber"][0]) == 1:
            if entry[1]["ulHarqProcessIndex"][0] in harq_processes:
                if entry[1]["ulProGrantType"][0] == "SKIPPABLEDYNAMIC" and entry[1]["HarqRxDataDtx"][0] == 'DTX':
                    raise AssertionError("Retransmission for skippable grant at {}".format(entry[0]))
                else:
                    harq_processes.remove(entry[1]["ulHarqProcessIndex"][0])
        if len(entry[1]["txNumber"][0]) > 0 and float(entry[1]["txNumber"][0]) > 1:  # if txNumber is larger than 1
            harq_processes.add(entry[1]["ulHarqProcessIndex"][0])


def verify_that_there_is_retransmission_for_fake_sr(tti_trace_dict):
    harq_processes = set(())
    is_grant_fake_sr = False

    for timestamp, data in tti_trace_dict.items():
        if data["csListEvent"][0] == "ENTRYULGRANTFORRLCSTATUSPDU":
            is_grant_fake_sr = True

        if harq_processes and len(data["txNumber"][0]) > 0:
            if data["HarqRxDataDtx"][0] == "NON_DTX":
                is_grant_fake_sr = False

            if float(data["ulHarqProcessIndex"][0]) in harq_processes:
                if float(data["txNumber"][0]) == 1:
                    raise AssertionError("Expected retranssmision at {}".format(timestamp))
                if float(data["txNumber"][0]) > 1:
                    harq_processes.remove(float(data["ulHarqProcessIndex"][0]))
                    is_grant_fake_sr = False

        if is_grant_fake_sr is True and \
                (data["ulProGrantType"][0] == "DISABLED" or data["ulProGrantType"][0] == "NONSKIPPABLE") and \
                (data["HarqRxDataDtx"][0] == "DTX" or data["crc"][0] == "NOK") and \
                float(data["txNumber"][0]) == 1:
            harq_processes.add(float(data["ulHarqProcessIndex"][0]))


def verify_that_there_is_no_retransmission_for_fake_sr(tti_trace_dict):
    harq_processes = set(())
    is_grant_fake_sr = False
    skippable_grants_configured = False

    for timestamp, data in tti_trace_dict.items():
        if skippable_grants_configured is False and data["ulProGrantType"][0] == "SKIPPABLEDYNAMIC":
            skippable_grants_configured = True

        if skippable_grants_configured is True:
            if data["csListEvent"][0] == "ENTRYULGRANTFORRLCSTATUSPDU":
                is_grant_fake_sr = True

            if harq_processes and len(data["txNumber"][0]) > 0:
                if data["HarqRxDataDtx"][0] == "NON_DTX":
                    is_grant_fake_sr = False

                if float(data["ulHarqProcessIndex"][0]) in harq_processes:
                    if float(data["txNumber"][0]) > 1:
                        raise AssertionError("Unexpected retranssmision at {}".format(timestamp))
                    if float(data["txNumber"][0]) == 1:
                        harq_processes.remove(float(data["ulHarqProcessIndex"][0]))

            if is_grant_fake_sr is True and \
                    (data["ulProGrantType"][0] == "DISABLED" or data["ulProGrantType"][0] == "NONSKIPPABLE") and \
                    (data["HarqRxDataDtx"][0] == "DTX" or data["crc"][0] == "NOK") and \
                    float(data["txNumber"][0]) == 1:
                harq_processes.add(float(data["ulHarqProcessIndex"][0]))
                is_grant_fake_sr = False


def verify_that_retransmission_is_started_for_non_proactive_grant(tti_trace_dict):
    harq_processes = set(())
    skippable_grants_configured = False
    number_of_nonproactive_retransmissions = 0
    minimum_acceptable_number_of_retransmission = 3
    is_grant_fake_sr = False
    is_previous_bsr_empty = False
    is_current_bsr_empty = False

    for timestamp, data in tti_trace_dict.items():
        if any(data["bufferSizeIndex"]):
            if any(bsr == "[0, 0, 0, 0, 0, 0, 0, 0]" for bsr in data["bufferSizeIndex"]):
                is_current_bsr_empty = True
            else:
                is_current_bsr_empty = False

        if data["rnti"] == ["65535"]:
            continue

        if data["csListEvent"][0] == "ENTRYULGRANTFORRLCSTATUSPDU":
            is_grant_fake_sr = True

        if skippable_grants_configured is False and data["ulProGrantType"][0] == "SKIPPABLEDYNAMIC":
            skippable_grants_configured = True

        if harq_processes and len(data["txNumber"][0]) > 0 and float(data["ulHarqProcessIndex"][0]) in harq_processes:
            if float(data["txNumber"][0]) > 1:
                harq_processes.remove(float(data["ulHarqProcessIndex"][0]))
            elif float(data["txNumber"][0]) == 1:
                raise AssertionError("No retransmission for non proactive grant at {}".format(timestamp))

        if (data["ulProGrantType"][0] == "DISABLED" or data["ulProGrantType"][0] == "NONSKIPPABLE") and \
                (data["HarqRxDataDtx"][0] == "DTX" or data["crc"][0] == "NOK") and \
                float(data["txNumber"][0]) == 1 and not is_previous_bsr_empty:
            if is_grant_fake_sr is False:
                harq_processes.add(float(data["ulHarqProcessIndex"][0]))
                if skippable_grants_configured:
                    number_of_nonproactive_retransmissions += 1

        if is_grant_fake_sr and (data["ulProGrantType"][0] == "DISABLED" or data["ulProGrantType"][0] ==
                                 "NONSKIPPABLE"):
            is_grant_fake_sr = False

        is_previous_bsr_empty = is_current_bsr_empty
    if number_of_nonproactive_retransmissions < minimum_acceptable_number_of_retransmission:
        raise AssertionError("Expected retransmissions for at least {} different grants. Found {}"
                             .format(minimum_acceptable_number_of_retransmission,
                                     number_of_nonproactive_retransmissions))


def download_mcshark_from_repository_and_save_to_wireshark_location():
    wireshark_path = "/usr/lib/x86_64-linux-gnu/wireshark/plugins/*/epan/"
    current_path = glob.glob(wireshark_path)
    sw_version = get_sbts_sw_version()
    if len(current_path) < 1:
        raise Exception("not find path %s" % wireshark_path)

    mcshark = glob.glob("%s/mcshark*.so" % wireshark_path)
    if mcshark:
        for m in mcshark:
            exe_subprocess("sudo rm %s" % mcshark[0])

    url = 'https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local'
    cmd = "sudo wget -q -P '%s' -r -np -nH -nd -A.so %s/%s/" % (current_path[0], url, sw_version)
    exe_subprocess(cmd)


def get_sbts_sw_version():
    admin_api = admin().connect_to()
    sw_version_complete_format = str(admin_api.get_sw_version())
    sw_version_trunk = sw_version_complete_format.replace(sw_version_complete_format.split("_")[0][4:9], "00")
    admin().teardown_admin()
    return sw_version_trunk


def exe_subprocess(cmd):
    ret = subprocess.check_output(cmd, shell=True)
    ret = ret.decode()
    return ret


def remove_file_if_exists(file_input):
    """
    remove a file only if it exists
    """
    info("Attempting to remove {}".format(file_input))
    if not path.exists(file_input):
        info("File {} not found, nothing to do".format(file_input))
    else:
        try:
            remove(file_input)
            info("File {} properly removed".format(file_input))
        except OSError as err:
            info("ERROR:Unable to remove {}:{}".format(file_input, err))


def verify_proactive_grants_assignment(val, parsed_data, tti_csv):
    rntis = get_c_rnti_for_each_ue_from_tti_trace(parsed_data)
    if "65535" in rntis:
        rntis.remove("65535")
    if "0" in rntis:
        rntis.remove("0")
    with open(tti_csv, "r") as csvfile:
        reader = csv.DictReader(csvfile)
        for rnti in rntis:
            ms_list = []
            count_validation = 0
            other_grant_types_count = 0
            for row in reader:
                if row["rnti"] == rnti and row["ulPreSchedData.csListEvent"] == "ENTRYPROACTIVEPUSCH":
                    ms_list.append(row["timeStamp"].split(".")[1])
            for ms, next_ms in zip(ms_list, ms_list[1:]):
                val_diff = int(next_ms) - int(ms)
                if val_diff < 0:
                    val_diff += 1000000
                if str(int(val) * 1000) == str(val_diff):
                    count_validation += 1
                else:
                    other_grant_types_count += 1

            if count_validation < 100:
                raise ExecutionFailed(
                    message="only {} entryProactivePusch for rnti {}, "
                            "expected more than 100".format(count_validation, rnti),
                    continue_on_failure=True
                )

            if count_validation < other_grant_types_count:
                raise ExecutionFailed(
                    message="more incorrect entryProactivePusch timings"
                            " than correct ones for rnti {}".format(rnti),
                    continue_on_failure=True
                )
            csvfile.seek(0)


def get_c_rnti_for_each_ue_from_tti_trace(data):
    rnti_list = []
    for timestamp in data:
        for field in data[timestamp]:
            for rnti_value in data[timestamp][field]:
                if "rnti" == field:
                    rnti_list.append(rnti_value)
    dict_rnti_count = {i: rnti_list.count(i) for i in rnti_list}
    for rnti in list(dict_rnti_count.keys()):
        if dict_rnti_count[rnti] < 1000:
            del dict_rnti_count[rnti]
    return list(dict_rnti_count.keys())


def get_traces_for_each_ue(data, rnti):
    ue_tti = {}
    for timestamp in data:
        for field in data[timestamp]:
            if any([field_value for field_value in data[timestamp][field] if rnti in field_value]):
                ue_tti.update({timestamp: data[timestamp]})
    return ue_tti


def verify_that_skip_uplink_tx_dynamic_is_set_in_rrc(pdml_file, value):
    with open(pdml_file, 'r') as pdml_file:
        file_reader = pdml_file.readlines()
        skip_uplink_flag = False
        for line in file_reader:
            val = re.search("show=\"{}\"".format(value), line) and re.search("skipUplinkTxDynamic", line)
            if val:
                skip_uplink_flag = True
        assert skip_uplink_flag


def verify_the_size_of_ul_pro_grant(pdml_file, payload_size):
    with open(pdml_file, 'r') as pdml_file:
        file_reader = pdml_file.readlines()
        tmp_list = list()
        for line in file_reader:
            if "\"rlc-nr\"" in line:
                value = line.split("-bytes")[0][-2]
                print("The first number of byte is: {}".format(value))
                tmp_list.append(value)
        assert (payload_size[0] in tmp_list and tmp_list.count(payload_size[0]) > 10)


def check_sum(value_1, value_2, base_value):
    v1 = int(value_1[0])
    v2 = int(value_2[0])
    assert v1 + v2 == int(base_value)


def set_timestamp():
    timestamp = time.time()
    return timestamp


def counter_count(timestamp0, timestamp1):
    counter = int(math.floor(timestamp1 - timestamp0))
    return counter


def sum_timestamps(*args):
    return sum(args)


def check_pool20_pool40_counters(counter_p20, counter_p40, value_sr20, value_sr40):
    print("counter_p20: {}".format(counter_p20))
    print("counter_p40: {}".format(counter_p40))
    print("value_sr20: {}".format(value_sr20))
    print("value_sr40: {}".format(value_sr40))
    value1 = int(value_sr20[0])
    value2 = int(value_sr40[0])

    assert (counter_p20 == value1) or (counter_p20 + 1 == value1)
    assert (counter_p40 == value2) or (counter_p40 + 1 == value2)


def check_pool10_pool20_counters(counter_p10, counter_p20, value_sr10, value_sr20):
    print("counter_p10: {}".format(counter_p10))
    print("counter_p20: {}".format(counter_p20))
    print("value_sr10: {}".format(value_sr10))
    print("value_sr20: {}".format(value_sr20))
    value1 = int(value_sr10[0])
    value2 = int(value_sr20[0])

    assert (counter_p10 == value1) or (counter_p10 + 1 == value1)
    assert (counter_p20 == value2) or (counter_p20 + 1 == value2)


def local_time_counter():
    temporary_value = time.localtime()
    seconds = (temporary_value.tm_min % 5) * 60 + temporary_value.tm_sec
    return seconds


def check_pool_min_counter(localtime, value_sr):
    print("localtime1: {}".format(localtime))
    print("value_sr: {}".format(value_sr))
    value1 = int(value_sr[0])
    assert (localtime + 5 >= value1) and (localtime - 4 <= value1)


def check_pool_max_counter(localtime, value_sr):
    print("localtime2: {}".format(localtime))
    print("value_sr: {}".format(value_sr))
    value1 = 300 - int(value_sr[0])
    assert (localtime + 4 >= value1) and (localtime - 4 <= value1)


def return_list_of_slot_pool_at_rrc_setup_and_reconfiguration(file_log):
    """
    Get list of RRC Setup content
    :param file_log :   Path location to egate_console_log
    """
    with open(file_log, 'r') as log:
        log_content = log.read()
        sl_pool_in_rrc_setup = []
        sl_pool_in_rrc_setup_sl5 = []
        sl_pool_reconfiguration_after_thresholds = []
        sl_pool_reconfiguration_after_detaches = []
        list_of_lines_egate_logs = log_content.splitlines()
        list_of_indexes_of_each_rrc, rrc_len = \
            check_substring_index(list_of_lines_egate_logs, "message c1 : rrcSetup :")
        reconfiguration_indexes_after_thresholds, reconfiguration_indexes_after_detach = \
            check_substring_index_for_reconfiguration_after_thresholds_and_detaches(list_of_lines_egate_logs)
        for rrc in get_each_message(list_of_lines_egate_logs, list_of_indexes_of_each_rrc, min(rrc_len)):
            for content in rrc:
                if re.search(r'periodicityAndOffset sl\d\d : \d', content):
                    sl_pool_in_rrc_setup.append(content.strip())
                elif re.search(r'periodicityAndOffset sl\d : \d', content):
                    sl_pool_in_rrc_setup_sl5.append(content.strip())
        for msg in get_each_message(list_of_lines_egate_logs, reconfiguration_indexes_after_thresholds, 54):
            for content in msg:
                if re.search(r'periodicityAndOffset sl\d\d : \d', content):
                    sl_pool_reconfiguration_after_thresholds.append(content.strip())
        for msg in get_each_message(list_of_lines_egate_logs, reconfiguration_indexes_after_detach, 54):
            for content in msg:
                if re.search(r'periodicityAndOffset sl\d\d : \d', content):
                    sl_pool_reconfiguration_after_detaches.append(content.strip())
    return sl_pool_in_rrc_setup, sl_pool_reconfiguration_after_thresholds, sl_pool_reconfiguration_after_detaches,\
        sl_pool_in_rrc_setup_sl5


def verify_that_slot_pool_in_rrc_is_present_a_number_of_times(log_path, expected_pool, number_of_ues):
    if expected_pool == "sl5":
        sl_pool_in_rrc_setup = \
            return_list_of_slot_pool_at_rrc_setup_and_reconfiguration(log_path)[3]
    else:
        sl_pool_in_rrc_setup =\
            return_list_of_slot_pool_at_rrc_setup_and_reconfiguration(log_path)[0]
    string_from_list = '-'.join(sl_pool_in_rrc_setup)
    occurrences = re.findall(r"periodicityAndOffset {} : \d".format(expected_pool), string_from_list)
    assert any([pool for pool in sl_pool_in_rrc_setup if re.search(expected_pool, pool)])
    assert len(occurrences) == int(number_of_ues)


def verify_that_after_threshold_is_met_reconfiguration_from_shorter_pool_to_longer_pool_is_achieved(log_path):
    rrc_setup_attach, rrc_reconfiguration_threshold, rrc_reconfiguration_after_detach = \
        return_list_of_slot_pool_at_rrc_setup_and_reconfiguration(log_path)
    check_upgrade_pool_from_sl20_to_sl40(rrc_setup_attach, rrc_reconfiguration_threshold)
    check_upgrade_pool_from_sl40_to_sl80(rrc_setup_attach, rrc_reconfiguration_threshold)
    check_that_only_sr_period_was_modified_during_upgrade_reallocation(rrc_setup_attach, rrc_reconfiguration_threshold)


def verify_that_after_ues_release_sr_period_is_reconfigured_from_longer_to_shorter_pool(log_path):
    rrc_setup_attach, rrc_reconfiguration_threshold, rrc_reconfiguration_after_detach = \
        return_list_of_slot_pool_at_rrc_setup_and_reconfiguration(log_path)
    check_downgrade_pool_from_sl80_to_sl40_and_sl20(rrc_reconfiguration_after_detach)
    check_that_not_only_sr_period_was_modified_but_also_slot_offset(rrc_reconfiguration_threshold,
                                                                    rrc_reconfiguration_after_detach)


def check_that_not_only_sr_period_was_modified_but_also_slot_offset(reconfiguration_pool, reconfiguration_pool_detach):
    check_list_80_to_40 = []
    check_list_40_to_20 = []
    number_of_ues_pool_80_at_reconfiguration = len(re.findall(r'periodicityAndOffset sl80 : \d',
                                                              '_'.join(reconfiguration_pool)))
    number_of_ues_pool_40_at_reconfiguration = len(re.findall(r'periodicityAndOffset sl40 : \d',
                                                              '_'.join(reconfiguration_pool)))
    for period_offset_in_reconfiguration in reconfiguration_pool:
        for period_offset_reconfiguration_detach in reconfiguration_pool_detach:
            sl_offset_reconfiguration = period_offset_in_reconfiguration.split(":")
            sl_offset_reconfiguration_detach = period_offset_reconfiguration_detach.split(":")

            if sl_offset_reconfiguration[0] == "periodicityAndOffset sl80 " and \
                    sl_offset_reconfiguration_detach[0] == "periodicityAndOffset sl40 ":
                check_list_80_to_40.append(sl_offset_reconfiguration[1] != sl_offset_reconfiguration_detach[1])
            if sl_offset_reconfiguration[0] == "periodicityAndOffset sl40 " and \
                    sl_offset_reconfiguration_detach[0] == "periodicityAndOffset sl20 ":
                check_list_40_to_20.append(sl_offset_reconfiguration[1] != sl_offset_reconfiguration_detach[1])
    assert number_of_ues_pool_80_at_reconfiguration <= check_list_80_to_40.count(True) or \
           check_list_80_to_40.count(False) == 0
    assert number_of_ues_pool_40_at_reconfiguration <= check_list_40_to_20.count(True) or \
           check_list_40_to_20.count(False) == 0


def check_that_only_sr_period_was_modified_during_upgrade_reallocation(setup_pool, reconfiguration_pool):
    list_of_offsets = []
    count = 0
    for period_offset in setup_pool:
        for period_offset_reconfiguration in reconfiguration_pool:
            sl_offset_reconfiguration = period_offset_reconfiguration.split(":")
            slot_offset_setup = period_offset.split(":")
            if slot_offset_setup[0] == "periodicityAndOffset sl20 " and \
                    sl_offset_reconfiguration[0] == "periodicityAndOffset sl40 ":
                count = count + 1 if slot_offset_setup[1] != sl_offset_reconfiguration[1] else count
                list_of_offsets.append(slot_offset_setup[1] == sl_offset_reconfiguration[1])
            if slot_offset_setup[0] == "periodicityAndOffset sl40 " and \
                    sl_offset_reconfiguration[0] == "periodicityAndOffset sl80 ":
                assert slot_offset_setup[1] == sl_offset_reconfiguration[1], "The slot offset during upgrade " \
                                                                             "from sl40 to sl80 was changed " \
                                                                             "{}:{}".format(slot_offset_setup[1],
                                                                                            sl_offset_reconfiguration)
    assert any(el for el in list_of_offsets) and count == list_of_offsets.count(False)


def check_upgrade_pool_from_sl20_to_sl40(setup_pool, reconfiguration_pool):
    pool20_not_present = "periodicityAndOffset sl20" not in reconfiguration_pool
    number_of_ues_pool_20_at_setup = len(re.findall(r'periodicityAndOffset sl20 : \d', '_'.join(setup_pool)))
    number_of_ues_pool_40_at_reconfiguration = len(re.findall(r'periodicityAndOffset sl40 : \d',
                                                              '_'.join(reconfiguration_pool)))
    assert number_of_ues_pool_20_at_setup == number_of_ues_pool_40_at_reconfiguration \
           and pool20_not_present, "The number of UEs configured in sl20({}) is not equal to the number of UEs" \
                                   " configured at sl40 after the reallocation({}) or upgrade did not happen ({})". \
           format(number_of_ues_pool_20_at_setup, number_of_ues_pool_40_at_reconfiguration, pool20_not_present)


def check_upgrade_pool_from_sl40_to_sl80(setup_pool, reconfiguration_pool):
    number_of_ues_pool_40_at_setup = len(re.findall(r'periodicityAndOffset sl40 : \d', '_'.join(setup_pool)))
    number_of_ues_pool_20_at_setup = len(re.findall(r'periodicityAndOffset sl20 : \d', '_'.join(setup_pool)))
    number_of_ues_pool_80_at_reconfiguration = len(re.findall(r'periodicityAndOffset sl80 : \d',
                                                              '_'.join(reconfiguration_pool)))
    assert number_of_ues_pool_40_at_setup < number_of_ues_pool_80_at_reconfiguration and \
           number_of_ues_pool_20_at_setup + number_of_ues_pool_40_at_setup == \
           number_of_ues_pool_80_at_reconfiguration + 1


def check_downgrade_pool_from_sl80_to_sl40_and_sl20(reconfiguration_pool_detach):
    num_of_ues_pool_80 = len(re.findall(r'periodicityAndOffset sl80 : \d', '_'.join(reconfiguration_pool_detach)))
    num_of_ues_pool_40 = len(re.findall(r'periodicityAndOffset sl40 : \d', '_'.join(reconfiguration_pool_detach)))
    num_of_ues_pool_20 = len(re.findall(r'periodicityAndOffset sl20 : \d', '_'.join(reconfiguration_pool_detach)))
    assert num_of_ues_pool_80 == 0 and num_of_ues_pool_40 >= 2 and num_of_ues_pool_20 >= 2


def get_each_message(list_of_msg_egate, indexes, rrc_msg_length):
    list_of_msg = []
    for ix in range(0, len(indexes)):
        list_of_msg.append(list_of_msg_egate[indexes[ix]:indexes[ix] + rrc_msg_length])
    return list_of_msg


def check_substring_index_for_reconfiguration_after_thresholds_and_detaches(list_of_msg_egate):
    sp_cell_config_index = []
    sp_cell_config_index_after_detach = []
    for ix, (l1, l2) in enumerate(zip(list_of_msg_egate, list_of_msg_egate[1:])):
        if re.search("cellGroupId 0", l1) and re.search("spCellConfig", l2):
            if get_first_detach_index(list_of_msg_egate) > int(ix):
                sp_cell_config_index.append(ix)
            else:
                sp_cell_config_index_after_detach.append(ix)
    return sp_cell_config_index, sp_cell_config_index_after_detach


def get_first_detach_index(list_of_msg_egate):
    for ix, line in enumerate(list_of_msg_egate):
        if re.search(r'UEC-\d: UE([1-9]|[1-9][0-9]|100): detached', line):
            return int(ix)


def check_substring_index(list_of_msg_egate, substring):
    rrc_setup_indexes = []
    rrc_setup_complete_indexes = []
    for ix, line in enumerate(list_of_msg_egate):
        if substring in line:
            rrc_setup_indexes.append(ix)
        if "message c1 : rrcSetupComplete :" in line:
            rrc_setup_complete_indexes.append(ix)
    len_of_each_rrc_setup = [ix_complete-ix_setup for ix_setup, ix_complete in zip(rrc_setup_indexes,
                                                                                   rrc_setup_complete_indexes)]
    return rrc_setup_indexes, len_of_each_rrc_setup


def get_column_names(ttitrace_csv):
    with open(ttitrace_csv, 'r') as tti:
        column_names = tti.readline().rstrip().split(",")
    return column_names


def move_each_rnti_to_separate_tti_trace_csv(parsed_data, ttitrace_csv):
    rntis = get_c_rnti_for_each_ue_from_tti_trace(parsed_data)
    if "65535" in rntis:
        rntis.remove("65535")
    if "0" in rntis:
        rntis.remove("0")
    separate_ttitrace_file_list = []
    column_names = get_column_names(ttitrace_csv)
    with open(ttitrace_csv, 'r') as original_csv:
        reader = csv.DictReader(original_csv)
        for rnti in rntis:
            separate_ttitrace_filename = "{}/ttitrace_rnti_{}.csv".format(path.dirname(ttitrace_csv), rnti)
            separate_ttitrace_file_list.append(separate_ttitrace_filename)
            with open(separate_ttitrace_filename, 'w') as separate_ttitrace:
                writer = csv.DictWriter(separate_ttitrace, fieldnames=column_names)
                writer.writeheader()
                for row in reader:
                    if row['rnti'] == rnti:
                        writer.writerow(row)
            original_csv.seek(0)
    return separate_ttitrace_file_list


def check_if_grant_scheduled_in_the_same_slot_with_csi_report_is_not_type_of_skippabledynamicenhanced(ttitrace_dict):
    skippable_enhanced_grants_configured = False
    is_grant_and_csi_report_in_the_same_slot = False
    grant_types = ['SKIPPABLEDYNAMICENHANCED', 'SKIPPABLEDYNAMIC', 'DISABLED', 'NONSKIPPABLE']

    for timestamp, data in ttitrace_dict.items():
        if not skippable_enhanced_grants_configured and 'SKIPPABLEDYNAMICENHANCED' in data["ulProGrantType"]:
            skippable_enhanced_grants_configured = True

        is_grant_here = any(grant_type in data["ulProGrantType"] for grant_type in grant_types)
        is_csi_report_here = "PERIODIC_CSI" in data["reportType"]

        if skippable_enhanced_grants_configured and is_csi_report_here and is_grant_here:
            if 'SKIPPABLEDYNAMICENHANCED' in data["ulProGrantType"]:
                raise AssertionError("CQI report and SkippableDynamicEnhanced grant in the same slot at {}"
                                     .format(timestamp))

    assert skippable_enhanced_grants_configured, "SkippableDynamicEnhanced grants are not configured"


def check_if_grant_scheduled_in_the_same_slot_with_downlink_ack_is_not_type_of_skippabledynamicenhanced(ttitrace_dict):
    skippable_enhanced_grants_configured = False

    for timestamp, data in ttitrace_dict.items():
        if not skippable_enhanced_grants_configured and 'SKIPPABLEDYNAMICENHANCED' in data["ulProGrantType"]:
            skippable_enhanced_grants_configured = True

        if skippable_enhanced_grants_configured and 'ACK' in data["dlAckNack"] \
                and 'SKIPPABLEDYNAMICENHANCED' in data["ulProGrantType"]:
            raise AssertionError("dl ACK and SkippableDynamicEnhanced grant in the same slot at {}".format(timestamp))


def check_if_there_is_no_skippabledynamic_or_nonskippable_grant_and_csi_report_in_the_same_slot(ttitrace_dict):
    grant_types = ['SKIPPABLEDYNAMIC', 'NONSKIPPABLE']
    skippable_grants_configured = False

    for timestamp, data in ttitrace_dict.items():
        if not skippable_grants_configured and 'SKIPPABLEDYNAMIC' in data["ulProGrantType"]:
            skippable_grants_configured = True

        is_proactive_grant_here = any(grant_type in data["ulProGrantType"] for grant_type in grant_types)
        is_csi_report_here = "PERIODIC_CSI" in data["reportType"]

        if skippable_grants_configured and is_csi_report_here and is_proactive_grant_here:
            raise AssertionError("CQI report and {} grant in the same slot at {}"
                                 .format(data["ulProGrantType"], timestamp))

    assert skippable_grants_configured, "SkippableDynamic grants are not configured"


def filter_pcap_using_mcshark(pcapInFile, filterName=None, filterExp=None):
    """
    This method apply a filter on a pcap file and generate a new pcap
    containing only selected packets
    :param pcapInFile: input pcap file
    :param filterName: name of filter to add in root name of pcap
    :param filterExp: litteral expression of filter to apply
    :return: path of generated pcap file
    """
    pcapOutFile = path.abspath(pcapInFile.replace(".pcap", ".{}{}".format(filterName, ".pcap")))
    info("Applying filter [{}] on {}->{}".format(filterExp, pcapInFile, pcapOutFile))
    cmd = "tshark -r '{}' -Y '{}' -w '{}'"\
        .format(pcapInFile,
                filterExp,
                pcapOutFile)
    system(cmd)
    # if output file does not exists, it means an error occured on filter
    return pcapOutFile if path.isfile(pcapOutFile) else None


def count_proacticve_grant_sequence_start(ttitrace_csv):
    ttitrace_dict = read_and_parse_tti_data(ttitrace_csv)
    was_previous_grant_a_non_dtx = True
    proact_seq_start_counter = 0

    for timestamp, fields in ttitrace_dict.items():
        if "65535" in fields["rnti"]:
            continue

        if "SKIPPABLEDYNAMIC" in fields["ulProGrantType"] and was_previous_grant_a_non_dtx:
            proact_seq_start_counter += 1
            was_previous_grant_a_non_dtx = False

        if "NON_DTX" in fields["HarqRxDataDtx"]:
            was_previous_grant_a_non_dtx = True

        if "DTX" in fields["HarqRxDataDtx"]:
            was_previous_grant_a_non_dtx = False

    return proact_seq_start_counter
