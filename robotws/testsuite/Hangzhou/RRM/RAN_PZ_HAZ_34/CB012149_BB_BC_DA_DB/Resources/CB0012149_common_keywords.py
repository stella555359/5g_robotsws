import csv
import json
import time

import requests


def dynamic_rule_submit(imsi, rule):
    url = 'https://newhorizons.srn.dyn.nesc.nokia.net/api/selfservice/ncp_api_update_device'
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJwejRfaHozIiwiZW1haWwiOiJtaW5'
                         'nLnNoaUBub2tpYS1zYmVsbC5jb20iLCJkaXNwbGF5bmFtZSI6IlB6NCBIejMiLCJuc25jaXR5IjoiSGFuZ3'
                         'pob3UiLCJyb2xlcyI6WyJwejRfaHozX2F1dG9tYXRpb24iXSwiZXhwIjoyMDEzNDAxMTk3LjAwNzE4OH0.R'
                         'HAz-svYO1k5byDdHI6ECT_0RG_J7pXc8ZmNyZh25QzkddRBJZcEP1HkuhPrkpisH9ED8hH9aCBSYLC5B0Yd'
                         'edKqx2NIbaW1SHyaey8GpdZDE-XVL2Z2OSY5jEvkWPTbHxu4ldvld_MESZuxtQ5kNeoHghuo-DbY8hSAQi-c'
                         'yT-EPgDJCEcBt4O903Rka3TQ-f_hOxkwrjqMtIjT1yfF4oEfxnqQRRGyqk-_Rzyu9A_1vg5PSsgMzYR6t-bnj'
                         'FOrv9gHMVYaeBiCjlY1CX8idpgcUfV24jvwTPrzLONF3hiYG1_bxcxwS5EAGlCh-JpRoFH1NoQEmRHvn73Uz9Q7QA'
    }
    data = {
        'imsi': imsi,
        'rule_name': rule
    }
    response = requests.post(url=url, headers=headers, data=data, verify=False)
    print(response.text)
    result = json.loads(response.text)
    if response.status_code == 200:
        # msg = result['msg']['responseStatus']['message']
        msg = result['msg']
    elif response.status_code == 500:
        msg = result['msg']
    return response.status_code, msg


def get_value_from_csv_file(file_path, queried_filed, mode="r"):
    with open(file_path, mode) as csv_file:
        csv_data = csv.DictReader(f=csv_file)
        required_data_list = []
        for data in csv_data:
            if data[queried_filed] != '':
                required_data_list.append(data[queried_filed])

    return required_data_list


def get_corresponding_mo_id(parameter_list, distname_id):
    """
    get corresponding mo id from coam.get_managed_objects, which index is required to get
    parameter_list =
    [{'distName': '/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-37/SCF-1/MRBTS_A-38211/NRBTS_A-38211/NRCELL_A-2'},
    {'distName': '/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-37/SCF-1/MRBTS_A-38211/NRBTS_A-38211/NRCELL_A-1'}]
    :param parameter_list: mo_list from coam.get_managed_objects
    :param distname_id: which index is required to get
    """
    for i, j in enumerate(parameter_list):
        if int(parameter_list[i].get('distName').split('/')[-1][-1]) == int(distname_id):
            mo_id = i
    return mo_id


# def check_required_filed_data(filename, c_rnti, physCellId, mode="r"):
#     type_list = []
#     slot_list = []
#     rnti_list = []
#     physCellId_list = []
#     SLIV_list = []
#     numOfLayers_list = []
#     mcsTable_list = []
#     rrmUlProposedMcs_list = []
#     lastBufferSplitStatus_list = []
#     satisfied_num_1 = 0
#     satisfied_num_2 = 0
#     sliv_1_index = []
#     sliv_2_index = []
#     filter_lastBufferSplitStatus_list = []
#     with open(filename, mode=mode) as f:
#         csv_data = csv.DictReader(f=f)
#         for data in csv_data:
#             type_list.append(data["type"])
#             slot_list.append(data["slot"])
#             rnti_list.append(data["rnti"])
#             physCellId_list.append(data["physCellId"])
#             SLIV_list.append(data["SLIV"])
#             numOfLayers_list.append(data["numOfLayers"])
#             mcsTable_list.append(data["mcsTable"])
#             rrmUlProposedMcs_list.append(data["rrmUlProposedMcs"])
#             lastBufferSplitStatus_list.append(data["lastBufferSplitStatus"])
#         for index, item in enumerate(type_list):
#             if item == "ulFdSchedData" and (slot_list[index] == "1" or slot_list[index] == "6") and \
#                     rnti_list[index] == str(c_rnti) and physCellId_list[index] == str(physCellId):
#                 satisfied_num_1 += 1
#                 assert (SLIV_list[index] == "55" or SLIV_list[index] == "69" or SLIV_list[
#                     index] == "27"), "SLIV is not 55 or 69 or 27"
#                 if SLIV_list[index] == "27":
#                     sliv_1_index.append(index)
#                 assert numOfLayers_list[index] == "RANK1", "numOfLayers has other values besides RANK1"
#                 assert mcsTable_list[index] == "QAM256", "mcsTable has other values besides QAM256"
#                 assert int(rrmUlProposedMcs_list[index]) <= 27, "rrmUlProposedMcs is not less than or equal to 27"
#             if item == "ulFdSchedData" and (slot_list[index] == "3" or slot_list[index] == "8") and \
#                     rnti_list[index] == str(c_rnti) and physCellId_list[index] == str(physCellId):
#                 satisfied_num_2 += 1
#                 assert (SLIV_list[index] == "53" or SLIV_list[index] == "27"), "SLIV is not 53 or 27"
#                 if SLIV_list[index] == "27":
#                     sliv_2_index.append(index)
#                 assert numOfLayers_list[index] == "RANK1", "numOfLayers has other values besides RANK1"
#                 assert mcsTable_list[index] == "QAM256", "mcsTable has other values besides QAM256"
#                 assert int(rrmUlProposedMcs_list[index]) <= 27, "rrmUlProposedMcs is not less than or equal to 27"
#         if len(sliv_1_index + sliv_2_index) > 0:
#             for index in (sliv_1_index + sliv_2_index):
#                 if index > 5:
#                     for i in range(1, 6):
#                         if type_list[index - i] == "bufferSplitForFr1UlCa":
#                             filter_lastBufferSplitStatus_list.append(lastBufferSplitStatus_list[index - i])
#                 if index < len(type_list) - 5:
#                     for i in range(1, 6):
#                         if type_list[index + i] == "bufferSplitForFr1UlCa":
#                             filter_lastBufferSplitStatus_list.append(lastBufferSplitStatus_list[index + i])
#             assert "0" in filter_lastBufferSplitStatus_list, "lastBufferSplitStatus is not 0"
#
#     return satisfied_num_1, satisfied_num_2


def check_required_filed_data(filename, c_rnti, physCellId, mode="r"):
    timeStamp_list = []
    slot_list = []
    rnti_list = []
    physCellId_list = []
    SLIV_list = []
    numOfLayers_list = []
    mcsTable_list = []
    rrmUlProposedMcs_list = []
    satisfied_num_1 = 0
    satisfied_num_2 = 0
    sliv_1_index = []
    sliv_2_index = []
    with open(filename, mode=mode) as f:
        csv_data = csv.DictReader(f=f)
        for data in csv_data:
            timeStamp_list.append(data["timeStamp"])
            slot_list.append(data["slot"])
            rnti_list.append(data["rnti"])
            physCellId_list.append(data["physCellId"])
            SLIV_list.append(data["ulFdSchedData.SLIV"])
            numOfLayers_list.append(data["ulFdSchedData.numOfLayers"])
            mcsTable_list.append(data["ulFdSchedData.mcsTable"])
            rrmUlProposedMcs_list.append(data["ulFdSchedData.rrmUlProposedMcs"])
        for index, item in enumerate(timeStamp_list):
            if (slot_list[index] == "1" or slot_list[index] == "6") and rnti_list[index] == str(c_rnti) and \
                    physCellId_list[index] == str(physCellId):
                satisfied_num_1 += 1
                if SLIV_list[index] != "":
                    assert (int(float(SLIV_list[index])) == 55 or int(float(SLIV_list[index])) == 69 or int(
                        float(SLIV_list[index])) == 27), "SLIV is not 55 or 69 or 27"
                if SLIV_list[index] == "27":
                    sliv_1_index.append(index)
                assert numOfLayers_list[index] == "RANK1" or numOfLayers_list[
                    index] == "", "numOfLayers has other values besides RANK1"
                assert mcsTable_list[index] == "QAM256" or mcsTable_list[
                    index] == "", "mcsTable has other values besides QAM256"
                if rrmUlProposedMcs_list[index] != "":
                    assert (int(float(rrmUlProposedMcs_list[index])) <= 27 or int(
                        float(rrmUlProposedMcs_list[index])) == 255), ("rrmUlProposedMcs is not less than or "
                                                                       "equal to 27 or not equal 255")
            if (slot_list[index] == "3" or slot_list[index] == "8") and rnti_list[index] == str(c_rnti) and \
                    physCellId_list[index] == str(physCellId):
                satisfied_num_2 += 1
                if SLIV_list[index] != "":
                    assert (int(float(SLIV_list[index])) == 53 or int(
                        float(SLIV_list[index])) == 27), "SLIV is not 53 or 27"
                if SLIV_list[index] == "27":
                    sliv_2_index.append(index)
                assert numOfLayers_list[index] == "RANK1" or numOfLayers_list[
                    index] == "", "numOfLayers has other values besides RANK1"
                assert mcsTable_list[index] == "QAM256" or mcsTable_list[
                    index] == "", "mcsTable has other values besides QAM256"
                if rrmUlProposedMcs_list[index] != "":
                    assert (int(float(rrmUlProposedMcs_list[index])) <= 27 or int(
                        float(rrmUlProposedMcs_list[index])) == 255), ("rrmUlProposedMcs is not less than or "
                                                                       "equal to 27 or not equal 255")

    return satisfied_num_1, satisfied_num_2


# def check_numOfLayers_field_with_RANK(filename, check_data="RANK1", mode="r"):
#     numOfLayers_list = []
#     with open(filename, mode=mode) as f:
#         csv_data = csv.DictReader(f=f)
#         for data in csv_data:
#             numOfLayers_list.append(data["numOfLayers"])
#         empty_numOfLayers = numOfLayers_list.count("")
#         print(f"empty_numOfLayers: {empty_numOfLayers}")
#         if empty_numOfLayers > 0:
#             for item in numOfLayers_list:
#                 if item != "":
#                     assert item == check_data, f"numOfLayers has other values besides {check_data}"


def check_numOfLayers_field_with_RANK(filename, check_data="RANK1", mode="r"):
    numOfLayers_list = []
    with open(filename, mode=mode) as f:
        csv_data = csv.DictReader(f=f)
        for data in csv_data:
            numOfLayers_list.append(data["ulFdSchedData.numOfLayers"])
        empty_numOfLayers = numOfLayers_list.count("")
        print(f"empty_numOfLayers: {empty_numOfLayers}")
        if empty_numOfLayers > 0:
            for item in numOfLayers_list:
                if item != "":
                    assert item == check_data, f"numOfLayers has other values besides {check_data}"


def check_numOfLayers_field_contains_with_RANK(filename, check_data="RANK1", mode="r"):
    numOfLayers_list = []
    with open(filename, mode=mode) as f:
        csv_data = csv.DictReader(f=f)
        for data in csv_data:
            numOfLayers_list.append(data["ulFdSchedData.numOfLayers"])
        empty_numOfLayers = numOfLayers_list.count("")
        print(f"empty_numOfLayers: {empty_numOfLayers}")
        if empty_numOfLayers > 0:
            assert check_data in numOfLayers_list, f"numOfLayers not contain {check_data}"


def convert_to_json_file(data, json_path):
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
