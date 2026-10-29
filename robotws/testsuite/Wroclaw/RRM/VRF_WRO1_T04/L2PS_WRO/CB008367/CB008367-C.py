import csv
import json


def get_pdcch_start_and_length_for_bwp(pdcch_resources: list, bwp_id: int) -> int:
    """ Get PDCCH data for given BWP.

    Gets pdcchStartSymbolAndLength of each TTI from PdcchPatternData.perBwpPdcchResources
    for specified BWP

    :param pdcch_resources: list of PdcchPatternData.perBwpPdcchResources from TTI Trace
    :param bwp_id: Bandwidth Part ID of the cell
    :return: (int) pdcchStartSymbolAndLength
    """
    for item in pdcch_resources:
        if item["cellBwpId"] == bwp_id:
            pdcch_list = item.get("pdcchResourceList", [])
            if pdcch_list and "pdcchStartSymbolAndLength" in pdcch_list[0]:
                return pdcch_list[0].get("pdcchStartSymbolAndLength")


def get_pdcch_sym_and_length_in_ul_k1k2_slots(
        ul_trace_path: str,
        dl_trace_path: str,
        k1k2_slots: list,
        bwp_id: int) -> dict:
    """ Get UL grants data for given BWP from PDCCH pattern.

    Gets start symbol and length of PDCCH in slots with valid K1&K2 from PDCCH pattern in UL TTI Trace

    :param ul_trace_path: path to UL TTI Trace file
    :param dl_trace_path: path to DL TTI Trace file
    :param k1k2_slots: slots with non-zero K1&K2
    :param bwp_id: Bandwidth Part ID of the cell
    :return: (dict) with SFN.slot: UL pdcchStartSymbolAndLength
    """
    pdcch_dict_ul = {}

    with open(ul_trace_path, 'r') as ul_trace:
        csv_reader = csv.DictReader(ul_trace)
        for line in csv_reader:
            if line["slot"] in k1k2_slots and line["ulPdcchPatternData.perBwpPdcchResources"]:
                ul_pdcch_resources = json.loads(line["ulPdcchPatternData.perBwpPdcchResources"].replace("'", '"'))
                pdcch_dict_ul[f'{line["sfn"]}.{line["slot"]}'] = get_pdcch_start_and_length_for_bwp(
                    ul_pdcch_resources, bwp_id)

    cc_slots = get_pdcch_sym_and_length_in_dl_k1k2_slots(dl_trace_path, k1k2_slots, bwp_id)[1]
    pdcch_dict_ul = {key: value for key, value in pdcch_dict_ul.items() if key not in cc_slots}

    return pdcch_dict_ul


def get_pdcch_sym_and_length_in_dl_k1k2_slots(dl_trace_path: str, k1k2_slots: list, bwp_id: int) -> tuple:
    """ Get DL grants data for given BWP from PDCCH pattern.

    Gets start symbol and length of PDCCH in slots with valid K1&K2 from PDCCH pattern in DL TTI Trace

    :param dl_trace_path: path to DL TTI Trace file
    :param k1k2_slots: slots with non-zero K1&K2
    :param bwp_id: Bandwidth Part ID of the cell
    :return: (tuple) (dict with SFN.slot: DL pdcchStartSymbolAndLength, list of SFN.slot carrying common channels)
    """
    pdcch_dict_dl = {}
    cc_slots = []

    INVALID_UE_CRNTI = '65535'

    with open(dl_trace_path, 'r') as dl_trace:
        csv_reader = csv.DictReader(dl_trace)
        for line in csv_reader:
            sfn_slot_key = f'{line["sfn"]}.{line["slot"]}'

            if line["slot"] in k1k2_slots and line["dlPdcchPatternData.perBwpPdcchResources"]:
                dl_pdcch_resources = json.loads(line["dlPdcchPatternData.perBwpPdcchResources"].replace("'", '"'))
                if INVALID_UE_CRNTI in line["dlPdcchDciData.ueDciInfoList"] or (get_pdcch_start_and_length_for_bwp(
                        dl_pdcch_resources, bwp_id=0)):
                    cc_slots.append(sfn_slot_key)
                else:
                    pdcch_dict_dl[sfn_slot_key] = get_pdcch_start_and_length_for_bwp(dl_pdcch_resources, bwp_id)

    return pdcch_dict_dl, cc_slots


def cce_split_check(
        dl_trace_path: str,
        ul_trace_path: str,
        k1k2_slots: list,
        bwp_id: int,
        expected_cce_split: bool = False) -> None:
    """ Check CCE split presence in given slots.

    Checks if CCE split is visible in slots with valid K1&K2 not carrying common channels for given BWP
    based on PdcchPatternData.perBwpPdcchResources:
    pdcchStartSymbolAndLength is an 8-bit value holding start symbol and length of PDCCH,
    e.g. if pdcchStartSymbolAndLength == 1: start symbol = 0, length = 1
    pdcchStartSymbolAndLength == 17: start symbol = 1, length = 1

    :param dl_trace_path: path to DL TTI Trace file
    :param ul_trace_path: path to UL TTI Trace file
    :param k1k2_slots: slots with non-zero K1&K2
    :param bwp_id: Bandwidth Part ID of the cell
    :param expected_cce_split: flag with expected CCE split presence
    """

    failed_slots = []
    pdcch_dict_dl = get_pdcch_sym_and_length_in_dl_k1k2_slots(dl_trace_path, k1k2_slots, bwp_id)[0]
    pdcch_dict_ul = get_pdcch_sym_and_length_in_ul_k1k2_slots(ul_trace_path, dl_trace_path, k1k2_slots, bwp_id)

    pdcch_dict = {key: (pdcch_dict_dl[key], pdcch_dict_ul[key]) for key in pdcch_dict_dl if key in pdcch_dict_ul.keys()}

    cce_split = set(pdcch_dict.values()) == {(1, 1)}

    if cce_split == expected_cce_split:
        print(f"Check passed. Expected CCE split in BWP-{bwp_id}: {expected_cce_split}, actual: {cce_split}")
    elif cce_split and not expected_cce_split:
        failed_slots.extend(key for key in pdcch_dict.keys() if pdcch_dict[key] == (1, 1))
        raise Exception(f"Check failed. Expected CCE split: {expected_cce_split}, actual: {cce_split}"
                        f"\nFailed slots: {failed_slots}, check TTI Traces")
    else:
        failed_slots.extend(key for key in pdcch_dict.keys() if pdcch_dict[key] != (1, 1))
        raise Exception(f"Check failed. Expected CCE split: {expected_cce_split}, actual: {cce_split}"
                        f"\nFailed slots: {failed_slots}, check TTI Traces")
