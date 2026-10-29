import asyncio
import random
from TA_scenarios import *
# from Static_SA import *
from RegexWatcher import *
from itertools import zip_longest
import inspect
import re

random.seed(42)


def merge_all_list(lists):
    merged = []
    for group in zip_longest(*lists, fillvalue=None):
        for item in group:
            if item is not None and item not in merged:  # skip duplicates
                merged.append(item)
    return merged


def assign_ue_id(scenarios):
    """
    Assigns a unique ue_id to each scenario based on its name pattern (SA or NSA)
    and the target_cell value.

    Rules:
    - SA_xxx_: Extracts a 3-digit number (e.g., "SA_023_").
      - The first digit of ue_id is mapped from target_cell:
          {1 → "7", 21 → "2", 201 → "4", default → "0"}.
      - The remaining 3 digits are taken directly from the pattern (e.g., "023").
      - Example: name="SA_023_", target_cell=21 → ue_id=2023.

    - NSA_xxx: Extracts a 3-digit number (e.g., "NSA_023").
      - For target_cell=1: ue_id = 1000 + number (1001–1061).
      - For target_cell=201: ue_id = 1060 + number (1061–1121).
      - Other target_cell values are ignored.

    - Scenarios without a matching pattern are skipped.

    The assigned ue_id is stored in scenario["args"]["ue_id"].

    Returns:
        list: The input scenarios with ue_id added where applicable.
    """
    for scenario in scenarios:
        name = scenario["name"]
        target_cell = scenario["args"]["target_cell"]

        # Check for SA pattern
        sa_match = re.search(r"SA_(\d{3})", name)
        # Check for NSA pattern
        nsa_match = re.search(r"NSA_(\d{3})", name)

        if sa_match:
            num3 = sa_match.group(1)   # e.g. "001", "023", "142"

            # mapping target_cell -> first digit
            cell_map = {1: "7", 21: "2", 201: "4"}
            first_digit = cell_map.get(target_cell, "0")

            # build ue_id
            ue_id = int(first_digit + num3)

        elif nsa_match:
            num3 = int(nsa_match.group(1))  # numeric offset 001 → 1, etc.

            if target_cell == 1:
                base = 1000
                ue_id = base + num3   # 1001–1061 if num3 = 1–61
            elif target_cell == 201:
                base = 1060
                ue_id = base + num3   # 1062–1122 if num3 = 1–61
            else:
                continue  # skip if unsupported target_cell

        else:
            continue  # no match, skip

        # assign it
        scenario["args"]["ue_id"] = ue_id

    return scenarios


def create_main_scenarios():
    all_group_lists = []
    TA_SA_group = [
        # {"name": "SkyWatch_Seq_SA_004", "args": {"target_cell": 201}},
        # {"name": "SkyWatch_Seq_SA_004", "args": {"target_cell": 21}},
        # {"name": "SkyWatch_Seq_SA_004", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_005", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_005", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_005", "args": {"target_cell": 1}},

        # {"name": "SkyWatch_Seq_SA_003_01_nonmMIMO", "args": {"target_cell": 1}},
        # {"name": "SkyWatch_Seq_SA_003_01_nonmMIMO", "args": {"target_cell": 21}},
        # {"name": "SkyWatch_Seq_SA_003_02_mMIMO", "args": {"target_cell": 201}},
    ]
    all_group_lists.append(TA_SA_group)

    all_scenarios_list = merge_all_list(all_group_lists)
    random.shuffle(all_scenarios_list)
    assign_ue_id(all_scenarios_list)
    all_scenarios_list = all_scenarios_list * 1
    return all_scenarios_list


# def create_background_scenarios():
#     background_n71 = [
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'near_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'far_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
#
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
#     ]
#
#     background_n41 = [
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 201, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 201, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 201, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 201, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 201, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 201, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 201, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 201, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_NSA_Background", "args": {"cell": 201, "rf_condition": 'far_cell'}},
#
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
#
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
#
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
#
#     ]
#
#     background_n25 = [
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'near_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell',
#                                                         'default_slice_5qi': 9, "vonr": True}},
#
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
#
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
#
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#         {"name": "SkyWatch_Seq_SA_Background", "args": {"cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
#
#     ]
#     background_scenarios_list = background_n25 + background_n71 + background_n41
#     return background_scenarios_list


def list_functions_in_module():
    return {name: obj for name, obj in globals().items() if callable(obj)}
    # return {name: obj for name, obj in locals().items() if callable(obj)}


def prepare_scenario_list_background():
    scen_list = create_background_scenarios()
    func_registry = list_functions_in_module()
    callable_functions = []

    for func_data in scen_list:
        func_name = func_data["name"]
        args = func_data["args"]
        # if semaph:
        #     args["semaphore"] = BACKGROUND_LIMIT

        if func_name in func_registry:
            func = func_registry[func_name]
            callable_functions.append((func, args))
        else:
            logging.error(f"Can't find function {func_name} in current scope")

    return callable_functions


def prepare_scenario_list():
    scen_list = create_main_scenarios()
    func_registry = list_functions_in_module()
    callable_functions = []
    for func_data in scen_list:
        func_name = func_data["name"]
        args = func_data["args"]
        # if semaph:
        #     args["semaphore"] = SCEN_LIMIT

        if func_name in func_registry:
            func = func_registry[func_name]
            sig = inspect.signature(func)
            kwargs = {}
            for pname, param in sig.parameters.items():
                if param.default is inspect._empty:
                    kwargs[pname] = None
                else:
                    kwargs[pname] = param.default
            combined_args = kwargs | args
            callable_functions.append((func, combined_args))
        else:
            logging.error(f"Can't find function {func_name} in current scope")

    return callable_functions
