# -*- coding: utf-8 -*-
import json


def get_rimRsScramblingSequenceInit(log_line):
    json_str = log_line[log_line.find("{"):]
    data = json.loads(json_str)
    key_value = (
        '"rimRsScramblingSequenceInit"' + ":" + str(data["rimRsScramblingSequenceInit"])
    )
    return key_value


def get_nscID_from_syslog(log_line):
    json_str = log_line[log_line.find("{"):]
    data = json.loads(json_str)
    nscID = data["nscID"]
    return nscID


def get_rs_send_slots(send_rs_content):
    json_str = send_rs_content[send_rs_content.find("{"):]
    data = json.loads(json_str)
    key_value = '"slot"' + ":" + str(data["slot"])
    return key_value


def get_rimAsymmetricStatus(send_rimAsymmetric_content):
    get_json = send_rimAsymmetric_content.split("\n")
    # print(len(get_json))
    str1 = ""
    str2 = ""
    for line in get_json:
        if "{" in line:
            str1 = line[line.find("{"):]
            str3 = line[
                line.find(
                    "VIP/L2-PS/src/ul/sch/rim/RemoteInterferenceIndSender"
                ):line.find("{")
            ]
        if "}" in line:
            str2 = line[line.find(str3):line.find("}") + 1].replace(str3, "")
            # print(str2)
    json_str = str1 + str2
    print(json_str)
    data = json.loads(json_str)
    key_value = str(data["rimAsymmetricStatus"])
    return key_value


def get_dl_muting_slots_index(
    frame_type, rimDlMutingMaxRange_value, ri_effect_distance_value
):
    muting_slot = []
    if frame_type == "1116_0":
        if rimDlMutingMaxRange_value == "special slot":
            muting_slot.append([3])
        if rimDlMutingMaxRange_value == "DL+special slots":
            if ri_effect_distance_value <= 6:
                muting_slot.append([3])
            else:
                muting_slot.append([2, 3])
        if rimDlMutingMaxRange_value == "2DL+special slots":
            if ri_effect_distance_value <= 6:
                muting_slot.append([3])
            elif ri_effect_distance_value <= 20 and ri_effect_distance_value > 6:
                muting_slot.append([2, 3])
            else:
                muting_slot.append([1, 2, 3])
        if rimDlMutingMaxRange_value == "3DL+special slots":
            if ri_effect_distance_value <= 6:
                muting_slot.append([3])
            elif ri_effect_distance_value <= 20 and ri_effect_distance_value > 6:
                muting_slot.append([2, 3])
            elif ri_effect_distance_value <= 34 and ri_effect_distance_value > 20:
                muting_slot.append([1, 2, 3])
            else:
                muting_slot.append([0, 1, 2, 3])
    if frame_type == "1116_3":
        if rimDlMutingMaxRange_value == "special slot":
            muting_slot.append([3])
        if rimDlMutingMaxRange_value == "DL+special slots":
            if ri_effect_distance_value <= 6:
                muting_slot.append([3])
            else:
                muting_slot.append([6, 7])
        if rimDlMutingMaxRange_value == "2DL+special slots":
            if ri_effect_distance_value <= 6:
                muting_slot.append([3])
            elif ri_effect_distance_value <= 20 and ri_effect_distance_value > 6:
                muting_slot.append([6, 7])
            else:
                muting_slot.append([5, 6, 7])
        if rimDlMutingMaxRange_value == "3DL+special slots":
            if ri_effect_distance_value <= 6:
                muting_slot.append([3])
            elif ri_effect_distance_value <= 20 and ri_effect_distance_value > 6:
                muting_slot.append([6, 7])
            elif ri_effect_distance_value <= 34 and ri_effect_distance_value > 20:
                muting_slot.append([5, 6, 7])
            else:
                muting_slot.append([4, 5, 6, 7])
    return muting_slot[0], len(muting_slot[0])


def get_dl_muting_slots_index_from_syslog(DL_muting_slots_content):
    syslog_dl_muting_slots_index = []
    json_str = DL_muting_slots_content[DL_muting_slots_content.find("{"):]
    data = json.loads(json_str)
    for slot_index, slot in enumerate(data["pdschMitigationStates"]):
        if slot == "MUTING":
            syslog_dl_muting_slots_index.append(slot_index)
    return syslog_dl_muting_slots_index
