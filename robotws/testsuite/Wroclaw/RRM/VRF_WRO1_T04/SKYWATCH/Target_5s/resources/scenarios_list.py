import asyncio
import random
from Static_SA import *
from Static_NSA import *
from Mobility_NSA import *
from Mobility_SA import *
from RegexWatcher import *
from itertools import zip_longest
import inspect
import re


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
        sa_match = re.search(r"_SA_(\d{3})", name)
        # Check for NSA pattern
        nsa_match = re.search(r"_NSA_(\d{3})", name)

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
    random.seed(42)
    all_group_lists = []
    n71_SA_group = [
        {"name": "SkyWatch_Seq_SA_001", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_002", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_003", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_004", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_005", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_006", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_007", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_008", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_009", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_010", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_011", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_012", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_013", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_014", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_015", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_016", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_017", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_018", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_019", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_020", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_021", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_022", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_023", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_024", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_025", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_026", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_027", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_028", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_029", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_030", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_031", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_032", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_033", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_034", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_035", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_036", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_037", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_038", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_039", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_040", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_041", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_042", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_043", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_044", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_045", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_046", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_047", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_048", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_049", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_050", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_051", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_052", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_053", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_054", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_055", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_056", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_057", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_058", "args": {"target_cell": 1}},
        # {"name": "SkyWatch_Seq_SA_067_01_n71", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_069_01_n71", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_071_01_n71", "args": {"target_cell": 1}},
        # {"name": "SkyWatch_Seq_SA_075_01_n71", "args": {"target_cell": 1}},
        # {"name": "SkyWatch_Seq_SA_079_01_n71", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_081_01_n71", "args": {"target_cell": 1}},
        # {"name": "SkyWatch_Seq_SA_085_01_n71", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_087_01_n71", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_SA_089_01_n71", "args": {"target_cell": 1}},
        # {"name": "SkyWatch_Seq_SA_093_01_n71", "args": {"target_cell": 1}},
    ]

    n71_NSA_group = [
        {"name": "SkyWatch_Seq_NSA_001", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_002", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_003", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_004", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_011", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_012", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_013", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_014", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_021", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_022", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_023", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_024", "args": {"target_cell": 1}},
        {"name": "SkyWatch_Seq_NSA_031", "args": {"target_cell": 1}},
        # {"name": "SkyWatch_Seq_NSA_032", "args": {"target_cell": 1, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_033", "args": {"target_cell": 1, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_034", "args": {"target_cell": 1, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_032", "args": {"target_cell": 1, "rf_condition": 'far_cell'}},
        # {"name": "SkyWatch_Seq_NSA_033", "args": {"target_cell": 1, "rf_condition": 'far_cell'}},
        # {"name": "SkyWatch_Seq_NSA_034", "args": {"target_cell": 1, "rf_condition": 'far_cell'}},
    ]
    random.shuffle(n71_SA_group)
    random.shuffle(n71_NSA_group)
    all_group_lists.append(n71_SA_group)
    all_group_lists.append(n71_NSA_group)

    n25_SA_group = [
        {"name": "SkyWatch_Seq_SA_001", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_002", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_003", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_004", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_005", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_006", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_007", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_008", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_009", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_010", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_011", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_012", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_013", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_014", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_015", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_016", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_017", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_018", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_019", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_020", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_021", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_022", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_023", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_024", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_025", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_026", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_027", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_028", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_029", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_030", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_031", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_032", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_033", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_034", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_035", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_036", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_037", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_038", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_039", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_040", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_041", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_042", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_043", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_044", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_045", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_046", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_047", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_048", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_049", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_050", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_051", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_052", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_053", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_054", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_055", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_056", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_057", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_058", "args": {"target_cell": 21}},
        # {"name": "SkyWatch_Seq_SA_067_02_n25", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_069_02_n25", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_071_02_n25", "args": {"target_cell": 21}},
        # {"name": "SkyWatch_Seq_SA_075_02_n25", "args": {"target_cell": 21}},
        # {"name": "SkyWatch_Seq_SA_079_02_n25", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_081_02_n25", "args": {"target_cell": 21}},
        # {"name": "SkyWatch_Seq_SA_085_02_n25", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_087_02_n25", "args": {"target_cell": 21}},
        {"name": "SkyWatch_Seq_SA_089_02_n25", "args": {"target_cell": 21}},
        # {"name": "SkyWatch_Seq_SA_093_02_n25", "args": {"target_cell": 21}},
    ]
    random.shuffle(n25_SA_group)
    all_group_lists.append(n25_SA_group)

    n41_SA_group = [
        {"name": "SkyWatch_Seq_SA_001", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_002", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_003", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_004", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_005", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_006", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_007", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_008", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_009", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_010", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_011", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_012", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_013", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_014", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_015", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_016", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_017", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_018", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_019", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_020", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_021", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_022", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_023", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_024", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_025", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_026", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_027", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_028", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_029", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_030", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_031", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_032", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_033", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_034", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_035", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_036", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_037", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_038", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_039", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_040", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_041", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_042", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_043", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_044", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_045", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_046", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_047", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_048", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_049", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_050", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_051", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_052", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_053", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_054", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_055", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_056", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_057", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_058", "args": {"target_cell": 201}},
        # {"name": "SkyWatch_Seq_SA_067_03_n41", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_069_03_n41", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_071_03_n41", "args": {"target_cell": 201}},
        # {"name": "SkyWatch_Seq_SA_075_03_n41", "args": {"target_cell": 201}},
        # {"name": "SkyWatch_Seq_SA_079_03_n41", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_081_03_n41", "args": {"target_cell": 201}},
        # {"name": "SkyWatch_Seq_SA_085_03_n41", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_087_03_n41", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_SA_089_03_n41", "args": {"target_cell": 201}},
        # {"name": "SkyWatch_Seq_SA_093_03_n41", "args": {"target_cell": 201}},
    ]

    n41_NSA_group = [
        {"name": "SkyWatch_Seq_NSA_001", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_002", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_003", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_004", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_011", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_012", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_013", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_014", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_021", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_022", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_023", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_024", "args": {"target_cell": 201}},
        {"name": "SkyWatch_Seq_NSA_031", "args": {"target_cell": 201}},
        # {"name": "SkyWatch_Seq_NSA_032", "args": {"target_cell": 201, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_033", "args": {"target_cell": 201, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_034", "args": {"target_cell": 201, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_032", "args": {"target_cell": 201, "rf_condition": 'far_cell'}},
        # {"name": "SkyWatch_Seq_NSA_033", "args": {"target_cell": 201, "rf_condition": 'far_cell'}},
        # {"name": "SkyWatch_Seq_NSA_034", "args": {"target_cell": 201, "rf_condition": 'far_cell'}},
    ]
    random.shuffle(n41_SA_group)
    random.shuffle(n41_NSA_group)
    all_group_lists.append(n41_SA_group)
    all_group_lists.append(n41_NSA_group)

    all_scenarios_list = merge_all_list(all_group_lists)
    random.shuffle(all_scenarios_list)
    assign_ue_id(all_scenarios_list)
    all_scenarios_list = all_scenarios_list * 25
    return all_scenarios_list


def create_background_scenarios():
    # n71=16UEs n25=22UEs n41=30UEs -> 68 background UEs
    # 3xVoNR + 3xNSA + 5xSA (midcell) + 5xSA (farcell) = 16UEs
    background_n71 = [
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'near_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'mid_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'far_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},

        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 1, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 1, "rf_condition": 'far_cell'}},
        # {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 1, "rf_condition": 'near_cell'}},
        # {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 1, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'mid_cell'}},

        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'far_cell'}},
    ]

    # 3xVoNR + 3xNSA + 8xSA (nearCell) + 8xSA (midCell) + 8xSA (farCell) = 30UEs
    background_n41 = [
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'near_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'mid_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'far_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},

        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'far_cell'}},
        # {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'near_cell'}},
        # {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'far_cell'}},
        # {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'near_cell'}},
        # {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'far_cell'}},

        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'near_cell'}},

        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'mid_cell'}},

        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'far_cell'}},

    ]

    # 3xVoNR + 3xSA (nearCell) + 8xSA (midCell) + 8xSA (farCell) = 22UEs
    background_n25 = [
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'near_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'mid_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'far_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},

        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'near_cell'}},

        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'mid_cell'}},

        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'far_cell'}},

    ]
    background_scenarios_list = background_n25 + background_n71 + background_n41
    return background_scenarios_list


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
