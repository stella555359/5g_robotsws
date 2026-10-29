import os
import sys
import math
import re
from datetime import datetime


def get_timestamps(line, min_input, max_input):
    min_result = min_input
    max_result = max_input
    if '<' in line and '>' in line:
        time_string = line.split('<')[1].split('>')[0]
        try:
            datetime_object = datetime.strptime(
                time_string, "%Y-%m-%dT%H:%M:%S.%fZ")
            datetime_seconds = datetime_object.timestamp()
            min_result = min(datetime_seconds, min_input)
            max_result = max(datetime_seconds, max_result)
        except ValueError:
            pass
    return min_result, max_result


def analyse_syslog(syslog_filename, cs1_samples, avg_slot_delay_samples, avg_pre_and_td_sched_time_samples,
                   avg_mu_mimo_time_samples, avg_res_td_time_samples, avg_fd_ue_time_samples,
                   avg_fd_first_ue_time_samples, avg_fd_common_time_samples, avg_post_sched_time_samples,
                   avg_slot_processing_time_samples, skipped_fd_samples, queue_not_empty, queue_overload,
                   tti_too_long, l1_dl_errors):
    print(f"syslog_filename = {syslog_filename}")
    syslog_file = open(syslog_filename, "r", encoding="iso-8859-1")
    min_timestamp, max_timestamp = 1000000000000000000000, 0
    tti_too_long["ALL"] = 0
    line = syslog_file.readline().strip()
    while line:
        min_timestamp, max_timestamp = get_timestamps(
            line, min_timestamp, max_timestamp)
        core_id = line.split(" ", 5)[-2]

        item_search = re.search('L2PsSch([U|D]l)', line)
        if item_search:
            item = item_search.group(1)

        # ------------------------------------------------------------------------------------------------------------
        # Syslog notification example for Ul and Dl
        #
        # 24.09 11:21:18.208830 [192.168.255.129] 92 ASP-2730-Disp_3 <2024-09-24T09:21:18.206806Z>
        # 1540364-L2PsSchDl03 VIP/L2-PS/src/pscommon/synchro/overload/SlotProcessingRatioAdapter.cpp:218
        # slot utilization deviation (bin center points: -100;-70;-50;-35;-20;-15;-10;-5|0|5;10;15;20;35;50;70;100):
        # 0;0;0;0;217;22;0;1|182|258;274;46;0;0;0;0;0
        # ------------------------------------------------------------------------------------------------------------
        # To be filled ...

        # ------------------------------------------------------------------------------------------------------------
        # Syslog notification example for Ul and Dl
        #
        # 12.08 15:13:49.383764 [192.168.255.129] 97 ASP-2730-Disp_5 <2024-08-12T13:13:49.378803Z> 15C0192-L2PsSchUl01
        # VIP/L2-PS/src/pscommon/performance/SlotMeasurements.hpp:400 UE stats min/max/avg: CS1: 45/50/46.571438
        # CS2: 49/50/48.639385 scheduledUes: 5/5/4.910246 skippedFd: 0/0/0.000000
        #
        # 12.08 15:13:49.383882 [192.168.255.129] 98 ASP-2730-Disp_4 <2024-08-12T13:13:49.378816Z> 15C018B-L2PsSchDl01
        # VIP/L2-PS/src/pscommon/performance/SlotMeasurements.hpp:400 UE stats min/max/avg: CS1: 0/45/7.085927
        # CS2: 24/25/24.376930 scheduledUes: 0/5/4.384986 skippedFd: 0/0/0.000000
        # ------------------------------------------------------------------------------------------------------------
        if ("L2-PS/src/pscommon/performance/SlotMeasurements.hpp" in line) and ("UE stats min/max/avg: CS1" in line):
            if item not in cs1_samples:
                cs1_samples[item] = {}
                skipped_fd_samples[item] = {}
            if core_id not in cs1_samples[item]:
                cs1_samples[item][core_id] = []
                skipped_fd_samples[item][core_id] = []
            cs1_samples[item][core_id].append(
                float(line.split("UE stats min/max/avg: CS1: ")[1].split(" ")[0].split("/")[2]))

            if ("skippedFd: " in line):
                skipped_fd_samples[item][core_id].append(
                    float(line.split("skippedFd: ")[1].split(" ")[0].split("/")[2]))
            elif ("fdmUesSkipped: " in line):
                skipped_fd_samples[item][core_id].append(
                    float(line.split("fdmUesSkipped: ")[1].split(" ")[0].split("/")[2]))
            else:
                print("ERROR: <no skippedFd nor fdmUesSkipped pattern found for parsing!")
            # BHR end

        # ------------------------------------------------------------------------------------------------------------
        # Syslog notification example fot UL and DL
        #
        # 15.08 16:54:55.855914 [192.168.255.129] 2d ASP-2732-Disp_6 <2024-08-15T14:54:55.850367Z> 15C01D7-L2PsSchUl05
        # INF/L2-PS/src/pscommon/synchro/overload/OverloadControlMeasurements.cpp:305 Averaged Measurements:
        # slotDelay=2789, preAndTdSchedTime=33498, muMimoTime=0, resTdTime=0, fdUeTime=6023, fdFirstUeTime=11809,
        # fdCommonTime=6738, postSchedTime=7674, slotProcessingTime=60176
        #
        # 24.07 21:36:41.200995 [192.168.255.129] b7 ASP-2732-Disp_3 <2024-07-24T21:36:41.191448Z> 1540197-L2PsSchDl03
        # INF/L2-PS/src/pscommon/synchro/overload/OverloadControlMeasurements.cpp:305 Averaged Measurements:
        # slotDelay=3575, preAndTdSchedTime=60192, muMimoTime=0, resTdTime=7585, fdUeTime=11461, fdFirstUeTime=13802,
        # fdCommonTime=3509, postSchedTime=26305, slotProcessingTime=147320
        # ------------------------------------------------------------------------------------------------------------
        if ("overload/OverloadControlMeasurements.cpp" in line) and ("Averaged Measurements: slotDelay" in line):
            if item not in avg_slot_delay_samples:
                avg_slot_delay_samples[item] = {}
            if core_id not in avg_slot_delay_samples[item]:
                avg_slot_delay_samples[item][core_id] = []
            avg_slot_delay_samples[item][core_id].append(
                float(line.split("Averaged Measurements: slotDelay=")[1].split(",")[0]))
            if ("preAndTdSchedTime=" in line):
                if item not in avg_pre_and_td_sched_time_samples:
                    avg_pre_and_td_sched_time_samples[item] = {}
                if core_id not in avg_pre_and_td_sched_time_samples[item]:
                    avg_pre_and_td_sched_time_samples[item][core_id] = []
                avg_pre_and_td_sched_time_samples[item][core_id].append(
                    float(line.split("preAndTdSchedTime=")[1].split(",")[0]))
            if ("muMimoTime=" in line):
                if item not in avg_mu_mimo_time_samples:
                    avg_mu_mimo_time_samples[item] = {}
                if core_id not in avg_mu_mimo_time_samples[item]:
                    avg_mu_mimo_time_samples[item][core_id] = []
                avg_mu_mimo_time_samples[item][core_id].append(
                    float(line.split("muMimoTime=")[1].split(",")[0]))
            if ("resTdTime=" in line):
                if item not in avg_res_td_time_samples:
                    avg_res_td_time_samples[item] = {}
                if core_id not in avg_res_td_time_samples[item]:
                    avg_res_td_time_samples[item][core_id] = []
                avg_res_td_time_samples[item][core_id].append(
                    float(line.split("resTdTime=")[1].split(",")[0]))
            if ("fdUeTime=" in line):
                if item not in avg_fd_ue_time_samples:
                    avg_fd_ue_time_samples[item] = {}
                if core_id not in avg_fd_ue_time_samples[item]:
                    avg_fd_ue_time_samples[item][core_id] = []
                avg_fd_ue_time_samples[item][core_id].append(
                    float(line.split("fdUeTime=")[1].split(",")[0]))
            if ("fdFirstUeTime=" in line):
                if item not in avg_fd_first_ue_time_samples:
                    avg_fd_first_ue_time_samples[item] = {}
                if core_id not in avg_fd_first_ue_time_samples[item]:
                    avg_fd_first_ue_time_samples[item][core_id] = []
                avg_fd_first_ue_time_samples[item][core_id].append(
                    float(line.split("fdFirstUeTime=")[1].split(",")[0]))
            if ("fdCommonTime=" in line):
                if item not in avg_fd_common_time_samples:
                    avg_fd_common_time_samples[item] = {}
                if core_id not in avg_fd_common_time_samples[item]:
                    avg_fd_common_time_samples[item][core_id] = []
                avg_fd_common_time_samples[item][core_id].append(
                    float(line.split("fdCommonTime=")[1].split(",")[0]))
            if ("postSchedTime=" in line):
                if item not in avg_post_sched_time_samples:
                    avg_post_sched_time_samples[item] = {}
                if core_id not in avg_post_sched_time_samples[item]:
                    avg_post_sched_time_samples[item][core_id] = []
                avg_post_sched_time_samples[item][core_id].append(
                    float(line.split("postSchedTime=")[1].split(",")[0]))
            if ("slotProcessingTime=" in line):
                if item not in avg_slot_processing_time_samples:
                    avg_slot_processing_time_samples[item] = {}
                if core_id not in avg_slot_processing_time_samples[item]:
                    avg_slot_processing_time_samples[item][core_id] = []
                avg_slot_processing_time_samples[item][core_id].append(
                    float(line.split("slotProcessingTime=")[1].split(",")[0]))

        # BHR begin 24/08/2024 : FIFO queues may no longer managed like.
        if "remaining events in FIFO queue:" in line:
            queue_id = line.split("remaining events in FIFO queue:")[1][0]
            if queue_id not in queue_not_empty:
                queue_not_empty[queue_id] = 0
            queue_not_empty[queue_id] += 1
        if "FIFO queue overload triggered" in line:
            queue_id = line.split("FIFO queue overload triggered")[
                0].split(" ")[-3]
            if queue_id not in queue_overload:
                queue_overload[queue_id] = 0
            queue_overload[queue_id] += 1
        if "too long TTI processing" in line:
            tti_too_long["ALL"] += 1
        # BHR end

        # BHR begin 24/09/2024 : addition
        # ------------------------------------------------------------------------------------------------------------
        # Syslog notification example fot UL and DL (No differentiation between UL and DL)
        #
        # Syslog notification example fot UL and DL
        # 24.09 11:24:21.049189 [192.168.255.129] DE FSP-224D-0 <2024-09-24T09:24:21.039459Z> 728
        # INF/l1_application_rt, 07/INF RT C1: logMessageCounters: INF/ctrlTestability::logIdMiscs/0x37000800,
        # nrDl DU Stats<0>: 1920,0,0,0|9856,0,0,0|29036,0,0,0|256,0,0,0|29259,0,0,0|0,0,0,0|0,0,0,0
        # ------------------------------------------------------------------------------------------------------------
        # BHR end
        if ("ctrlTestability::logIdMiscs" in line) and (" Stats<" in line):
            if "TooEarly" not in l1_dl_errors:
                l1_dl_errors["TooEarly"] = 0
                l1_dl_errors["TooLate"] = 0
                l1_dl_errors["OtherError"] = 0
                l1_dl_errors["ALL"] = 0
            l1_group_stats = line.split(": ")[-1].split("|")
            for l1_group_stat in l1_group_stats:
                l1_stats = l1_group_stat.split(",")
                l1_dl_errors["TooEarly"] += int(l1_stats[1])
                l1_dl_errors["TooLate"] += int(l1_stats[2])
                l1_dl_errors["OtherError"] += int(l1_stats[3])
                l1_dl_errors["ALL"] = l1_dl_errors["TooEarly"] + l1_dl_errors["TooLate"] + l1_dl_errors["OtherError"]
        try:
            line = syslog_file.readline().strip()
        except UnicodeDecodeError:
            line = "UnicodeDecodeError"
            print(
                "****************************************************************** UnicodeDecodeError")
    syslog_file.close()
    return max_timestamp - min_timestamp


def get_statistics(syslog_duration, cs1_samples, avg_slot_delay_samples,
                   avg_pre_and_td_sched_time_samples, avg_mu_mimo_time_samples, avg_res_td_time_samples,
                   avg_fd_ue_time_samples, avg_fd_first_ue_time_samples, avg_fd_common_time_samples,
                   avg_post_sched_time_samples, avg_slot_processing_time_samples, skipped_fd_samples,
                   queue_not_empty, queue_overload, tti_too_long, l1_dl_errors):
    statistics = [f"syslog_duration: {syslog_duration}"]
    for item in cs1_samples:
        for core_id in cs1_samples[item]:
            samples = cs1_samples[item][core_id]
            lengh = len(samples)
            avg = sum(samples) / lengh
            # print(f"item = {item}   core_id = {core_id}    average = {average}")
            statistics.append(f"cs1_average[{item}][{core_id}]: {avg}, lengh: {lengh}, samples: {samples}")
    # print(f"statistics = {statistics}")

    for item in skipped_fd_samples:
        for core_id in skipped_fd_samples[item]:
            average = sum(skipped_fd_samples[item][core_id]) / len(skipped_fd_samples[item][core_id])
            # print(f"item = {item}   core_id = {core_id}    average = {average}")
            statistics.append(f"skipped_fd_average[{item}][{core_id}]: {average}")
    # print(f"statistics = {statistics}")

    for item in avg_slot_delay_samples:
        for core_id in avg_slot_delay_samples[item]:
            average = sum(avg_slot_delay_samples[item][core_id]) / len(avg_slot_delay_samples[item][core_id])
            # print(f"item = {item}   core_id = {core_id}    average = {average}")
            statistics.append(f"slot_delay_average[{item}][{core_id}]: {average}")
    # print(f"statistics = {statistics}")

    for item in avg_slot_delay_samples:
        max_over_core = 0
        for core_id in avg_slot_delay_samples[item]:
            # print(f"item={item}  core_id={core_id}  avg_slot_delay_samples={avg_slot_delay_samples[item][core_id]}")
            maximum = max(avg_slot_delay_samples[item][core_id])
            # print(f"maximum = {maximum}")
            statistics.append(f"slot_delay_max[{item}][{core_id}]: {maximum}")
            max_over_core = max(maximum, max_over_core)
            # print(f"max_over_core = {max_over_core}")
        statistics.append(f"slot_delay_max[{item}][ALL]: {max_over_core}")
    # print(f"statistics = {statistics}")

    for item in avg_pre_and_td_sched_time_samples:
        for core_id in avg_pre_and_td_sched_time_samples[item]:
            average = (sum(avg_pre_and_td_sched_time_samples[item][core_id]) /
                       len(avg_pre_and_td_sched_time_samples[item][core_id]))
            # print(f"item = {item}   core_id = {core_id}    average = {average}")
            statistics.append(f"avg_pre_and_td_sched_time_samples[{item}][{core_id}]: {average}")
    # print(f"statistics = {statistics}")

    for item in avg_mu_mimo_time_samples:
        for core_id in avg_mu_mimo_time_samples[item]:
            average = sum(avg_mu_mimo_time_samples[item][core_id]) / len(avg_mu_mimo_time_samples[item][core_id])
            # print(f"item = {item}   core_id = {core_id}    average = {average}")
            statistics.append(f"avg_mu_mimo_time_samples[{item}][{core_id}]: {average}")
    # print(f"statistics = {statistics}")

    for item in avg_res_td_time_samples:
        for core_id in avg_res_td_time_samples[item]:
            average = sum(avg_res_td_time_samples[item][core_id]) / len(avg_res_td_time_samples[item][core_id])
            # print(f"item = {item}   core_id = {core_id}    average = {average}")
            statistics.append(f"avg_res_td_time_samples[{item}][{core_id}]: {average}")
    # print(f"statistics = {statistics}")

    for item in avg_fd_ue_time_samples:
        for core_id in avg_fd_ue_time_samples[item]:
            average = sum(avg_fd_ue_time_samples[item][core_id]) / len(avg_fd_ue_time_samples[item][core_id])
            # print(f"item = {item}   core_id = {core_id}    average = {average}")
            statistics.append(f"avg_fd_ue_time_samples[{item}][{core_id}]: {average}")
    # print(f"statistics = {statistics}")

    for item in avg_fd_first_ue_time_samples:
        for core_id in avg_fd_first_ue_time_samples[item]:
            average = (sum(avg_fd_first_ue_time_samples[item][core_id]) /
                       len(avg_fd_first_ue_time_samples[item][core_id]))
            # print(f"item = {item}   core_id = {core_id}    average = {average}")
            statistics.append(f"avg_fd_first_ue_time_samples[{item}][{core_id}]: {average}")
    # print(f"statistics = {statistics}")

    for item in avg_fd_common_time_samples:
        for core_id in avg_fd_common_time_samples[item]:
            average = (sum(avg_fd_common_time_samples[item][core_id]) /
                       len(avg_fd_common_time_samples[item][core_id]))
            # print(f"item = {item}   core_id = {core_id}    average = {average}")
            statistics.append(f"avg_fd_common_time_samples[{item}][{core_id}]: {average}")
    # print(f"statistics = {statistics}")

    for item in avg_post_sched_time_samples:
        for core_id in avg_post_sched_time_samples[item]:
            average = (sum(avg_post_sched_time_samples[item][core_id]) /
                       len(avg_post_sched_time_samples[item][core_id]))
            # print(f"item = {item}   core_id = {core_id}    average = {average}")
            statistics.append(f"avg_post_sched_time_samples[{item}][{core_id}]: {average}")
    # print(f"statistics = {statistics}")

    for item in avg_slot_processing_time_samples:
        for core_id in avg_slot_processing_time_samples[item]:
            average = (sum(avg_slot_processing_time_samples[item][core_id]) /
                       len(avg_slot_processing_time_samples[item][core_id]))
            # print(f"item = {item}   core_id = {core_id}    average = {average}")
            statistics.append(f"avg_slot_processing_time_samples[{item}][{core_id}]: {average}")
    # print(f"statistics = {statistics}")

    for queue_id in queue_not_empty:
        statistics.append(
            f"queue_not_empty[{queue_id}]: {queue_not_empty[queue_id] / syslog_duration}")

    for queue_id in queue_overload:
        statistics.append(
            f"queue_overload[{queue_id}]: {queue_overload[queue_id] / syslog_duration}")

    for core_id in tti_too_long:
        statistics.append(f"tti_too_long[{core_id}]: {tti_too_long[core_id] / syslog_duration}")

    for error_type in l1_dl_errors:
        statistics.append(f"l1_dl_errors[{error_type}]: {l1_dl_errors[error_type] / syslog_duration}")

    return statistics


def extract_load_measurements(syslog_filename):
    print(f"extract_load_measurements on {syslog_filename}")
    cs1_samples = {}
    avg_slot_delay_samples = {}
    avg_pre_and_td_sched_time_samples = {}
    avg_mu_mimo_time_samples = {}
    avg_res_td_time_samples = {}
    avg_fd_ue_time_samples = {}
    avg_fd_first_ue_time_samples = {}
    avg_fd_common_time_samples = {}
    avg_post_sched_time_samples = {}
    avg_slot_processing_time_samples = {}
    skipped_fd_samples = {}
    queue_not_empty = {}
    queue_overload = {}
    tti_too_long = {}
    l1_dl_errors = {}
    syslog_duration = analyse_syslog(syslog_filename, cs1_samples, avg_slot_delay_samples,
                                     avg_pre_and_td_sched_time_samples, avg_mu_mimo_time_samples,
                                     avg_res_td_time_samples, avg_fd_ue_time_samples,
                                     avg_fd_first_ue_time_samples, avg_fd_common_time_samples,
                                     avg_post_sched_time_samples, avg_slot_processing_time_samples,
                                     skipped_fd_samples, queue_not_empty, queue_overload, tti_too_long,
                                     l1_dl_errors)

    return get_statistics(syslog_duration, cs1_samples, avg_slot_delay_samples, avg_pre_and_td_sched_time_samples,
                          avg_mu_mimo_time_samples, avg_res_td_time_samples, avg_fd_ue_time_samples,
                          avg_fd_first_ue_time_samples, avg_fd_common_time_samples, avg_post_sched_time_samples,
                          avg_slot_processing_time_samples, skipped_fd_samples, queue_not_empty, queue_overload,
                          tti_too_long, l1_dl_errors)


def create_pretty_load_meas_file(counter_file_name_with_path, syslog_file_name_with_path, destination_path):
    os.makedirs(destination_path, exist_ok=True)
    counter_file_name = counter_file_name_with_path.split('/')[-1]
    counter_file_name_tt = re.search(r'(\d{8}\.\d{6}.*)\.ANY\.xml', counter_file_name).group(1)
    # counter_file_name_tt = re.search(r'(\d+\.\d+.*)\.ANY\.xml', counter_file_name).group(1)
    pretty_file_name = "LOAD_MEASUREMENT." + counter_file_name_tt + ".csv"

    pretty_file = open(destination_path + "/" + pretty_file_name, "w")
    stats = extract_load_measurements(syslog_file_name_with_path)
    for stat in stats:
        pretty_file.write(f"{stat}\n")

    pretty_file.close()
    return pretty_file_name.replace(".csv", "")


if __name__ == '__main__':
    create_pretty_load_meas_file(sys.argv[1], sys.argv[2], sys.argv[3])
