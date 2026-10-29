"""
:copyright: Nokia Networks
:author: Kamil Pokusa
:maintainer: Kamil Pokusa, Marcin Trebunia
:contact: kamil.pokusa@nokia.com, marcin.trebunia@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""
import os

from robot.libraries.OperatingSystem import OperatingSystem

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import \
    check_file_exists, get_latest_file
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console_info
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.bip_management import \
    create_tshark_command


def validate_cellsetupreq_pcap(txt_syscom_path, syscom_validation_template_path):
    with open(txt_syscom_path, "r") as syscom_file:
        read_text = syscom_file.read()
    if "is neither a field nor a protocol name" in str(read_text):
        logger_console_info("Decoding syscom failed, please check why")
    else:
        __sliceawarescheduler_is_activated(read_text)
        __quota_resgrplist_is_correct(read_text, syscom_validation_template_path)
        __verify_plmn_value_is_correct(read_text, syscom_validation_template_path)
        __default_resourcesgrp_is_correct(read_text, syscom_validation_template_path)
        logger_console_info("Syscom validated successfully")


def get_latest_collected_syscom_for_cell(output_dir, cell_id='1', patterns=None):
    cell_setup_filter = f'\"(itf_l2_ps_cell_cellsetupreq) && (itf_l2_ps_cell_CellSetupReq_t.physCellId == {cell_id})\"'
    if patterns is None:
        patterns = [
            "xp_syscom_gnb1_source.pcap",
            "p_*.pcap",
            "0_*.pcap",
            "1_*.pcap",
            "2_*.pcap",
            "bip.pcap",
        ]
    for pattern in patterns:
        found_bip_path = __look_for_pcap_file(
            output_dir=output_dir, pattern=pattern, using_mcshark="True", syscom_filter=cell_setup_filter
        )
        if found_bip_path is not None:
            return found_bip_path
    raise Exception(f"Could not find pcap file with filter {cell_setup_filter} in location {output_dir}!")


def __save_pcap_to_txt(output_dir, prefix, pcap_path, using_mcshark, syscom_filter):
    output_path = os.path.join(output_dir, prefix + ".txt")
    tshark = create_tshark_command(
        bip_pcap_file=pcap_path,
        using_mcshark=using_mcshark,
        filter_mode=syscom_filter,
        luashark_path=None,
        output_path=output_path,
    )
    tshark = f"{tshark} 2>&1"
    OperatingSystem().run(tshark)
    return output_path


def __look_for_pcap_file(output_dir, pattern, using_mcshark, syscom_filter):
    try:
        latest_bip = get_latest_file(os.path.join(output_dir, pattern))
        if latest_bip is None:
            return None
    except ValueError:
        return None
    logger_console_info(f"Decoding {latest_bip} file to txt format and checking if {syscom_filter} returns something")
    output = __save_pcap_to_txt(
        output_dir=output_dir,
        prefix='itf_l2_ps_cell_cellsetupreq',
        pcap_path=latest_bip,
        using_mcshark=using_mcshark,
        syscom_filter=syscom_filter,
    )
    if check_file_exists(output):
        return latest_bip
    logger_console_info(f"{latest_bip} does not contain any msg with filter {filter}!")


def __sliceawarescheduler_is_activated(items_list):
    if "sliceAwareSchedulerCellActivation (Boolean): True" not in items_list:
        raise Exception("sliceAwareScheduler is deactivated in cell setup request in syscom")


def __quota_resgrplist_is_correct(items_list, pattern_for_syscom):
    index_of_quota_value = []
    position_of_searching_value_rg = str(items_list).find("dlResourceGroupConfig")
    position_end_of_searching = str(items_list).find("defaultResourceGroupList")
    string_with_value_rg = items_list[position_of_searching_value_rg:position_end_of_searching]
    for quota_id in range(len(pattern_for_syscom["quotas"])):
        if string_with_value_rg.find("resourceGroupList_item_" + str(quota_id)) >= 0:
            index_of_quota_value.append(string_with_value_rg.find("resourceGroupList_item_" + str(quota_id)))
    index_of_quota_value.sort()
    counter = 0
    for rg_id in pattern_for_syscom["quotas"]:
        if len(index_of_quota_value) == (counter + 1):
            temp_range = string_with_value_rg[index_of_quota_value[counter]:]
        else:
            temp_range = string_with_value_rg[index_of_quota_value[0 + counter]: index_of_quota_value[1 + counter]]
        if temp_range.find(f"minQuota (Uint8): {int(pattern_for_syscom['quotas'][str(rg_id)]['min'])}") > 0:
            if temp_range.find(f"maxQuota (Uint8): {int(pattern_for_syscom['quotas'][str(rg_id)]['max'])}") < 0:
                raise Exception(
                    f"Max Quota is not correct in resourceGroup {str(rg_id)}"
                    f"\nShould be {pattern_for_syscom['quotas'][str(rg_id)]['max']}"
                )
        else:
            raise Exception(
                f"Min Quota is not correct in resourceGroup {str(rg_id)}"
                f"\nShould be {pattern_for_syscom['quotas'][str(rg_id)]['min']}"
            )
        counter = counter + 1


def __verify_plmn_value_is_correct(items_list, pattern_for_syscom):
    position_of_searching_value_plmn = str(items_list).find("plmnConfigList")
    position_end_of_searching_plmn = str(items_list).find("dlResourceGroupConfig")
    string_with_plmn_config_list = items_list[position_of_searching_value_plmn:position_end_of_searching_plmn]
    for plmn in pattern_for_syscom['plmns']:
        input_dict = {
            "mcc": int(pattern_for_syscom["plmns"][plmn]["mcc"]),
            "mnc": int(pattern_for_syscom["plmns"][plmn]["mnc"]),
            "mnc_length": int(pattern_for_syscom["plmns"][plmn]["mnc_length"])
        }
        plmn_tables = __encode_plmn_to_bytes(input_dict)
        if string_with_plmn_config_list.find(f"plmnIdBytes_item_0 (Uint8): {plmn_tables[0]}") < 0 \
            and string_with_plmn_config_list.find(f"plmnIdBytes_item_1 (Uint8): {plmn_tables[1]}") < 0 \
                and string_with_plmn_config_list.find(f"plmnIdBytes_item_2 (Uint8): {plmn_tables[2]}") < 0:
            raise Exception(
                 f"\nmcc should be {pattern_for_syscom['quotas'][plmn]['mcc']}"
                 f"\nmnc should be {pattern_for_syscom['quotas'][plmn]['mnc']}"
                 f"\nmnc_length should be {pattern_for_syscom['quotas'][plmn]['mnc_length']} "
            )


def __default_resourcesgrp_is_correct(items_list, pattern_for_syscom):
    pos_of_searching_value_default_rg = str(items_list).find("defaultResourceGroupList")
    pos_end_of_searching_value_default_rg = str(items_list).find("ulResourceGroupConfig")
    string_with_default_groups = items_list[pos_of_searching_value_default_rg:pos_end_of_searching_value_default_rg]
    for default_rg_id in pattern_for_syscom['default_rgs']:
        if f'resourceGroupId (Uint8): {default_rg_id}' not in string_with_default_groups:
            raise Exception(f"Default resource group {default_rg_id} not present in defaultResourceGroupList"
                            f"in cellSetupRequest")


def __decode_plmn_from_bytes(plmn):
    first_encoded_number = str(bin(int(plmn["first_encoded_number"]))).replace("0b", "").rjust(8, "0")
    second_encoded_number = str(bin(int(plmn["second_encoded_number"]))).replace("0b", "").rjust(8, "0")
    third_encoded_number = str(bin(int(plmn["third_encoded_number"]))).replace("0b", "").rjust(8, "0")
    digits = [
        first_encoded_number[max(0, iterator_encoded_number - 4): iterator_encoded_number]
        for iterator_encoded_number in range(len(first_encoded_number), 0, -4)
    ]
    digits += [
        second_encoded_number[max(0, iterator_encoded_number - 4): iterator_encoded_number]
        for iterator_encoded_number in range(len(second_encoded_number), 0, -4)
    ]
    digits += [
        third_encoded_number[max(0, iterator_encoded_number - 4): iterator_encoded_number]
        for iterator_encoded_number in range(len(third_encoded_number), 0, -4)
    ]
    mcc_and_mnc = ""
    for digit in digits:
        if digit != "1111":
            mcc_and_mnc += str(int(digit, 2))
    return {
        "mcc": mcc_and_mnc[0:3].lstrip("0").rjust(1, "0"),
        "mnc": mcc_and_mnc[3:].lstrip("0").rjust(1, "0"),
        "mnc_length": "3" if len(mcc_and_mnc) == 6 else "2",
    }


def __encode_plmn_to_bytes(input_dict={"mcc": 311, "mnc": 489, "mnc_length": 3}):
    mcc_and_mnc = list(str(input_dict["mcc"]) + str(input_dict["mnc"]))
    mcc_and_mnc = [int(letter) for letter in mcc_and_mnc]
    mcc_and_mnc = list(map(bin, mcc_and_mnc))
    result = []
    for counter, digit in enumerate(mcc_and_mnc):
        result.append(0)
        act_digit = digit.replace("0b", "")

        while len(act_digit) < 4:
            act_digit = "".join(["0", act_digit])
        result[counter] = act_digit
    result = [int(result[1] + result[0], 2), int(result[3] + result[2], 2), int(result[5] + result[4], 2)]
    return result
