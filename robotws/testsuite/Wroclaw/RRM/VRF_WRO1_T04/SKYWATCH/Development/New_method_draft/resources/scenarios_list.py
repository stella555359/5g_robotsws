import json
import asyncio
from Static_SA import *
from Static_NSA import *
from RegexWatcher import *
from common import pdu_id_pair_generator, ue_id_generator

MAX_NUM_PDU_ID = 255
NSA_START_UE_ID = 101
NSA_MAX_UE_ID = 150
SA_START_UE_ID = 1
SA_MAX_UE_ID = 99
SCEN_LIMIT = asyncio.Semaphore(100)

gen_pdu_id = pdu_id_pair_generator(MAX_NUM_PDU_ID)
gen_nsa_ue = ue_id_generator(NSA_START_UE_ID, NSA_MAX_UE_ID)
gen_sa_ue = ue_id_generator(SA_START_UE_ID, SA_MAX_UE_ID)


sa_static_scen = [
    {"name": "SkyWatch_Seq_SA_001_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_001_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_001_03_n41", "args": {"target_cell": 201}},

    # {"name": "SkyWatch_Seq_SA_002_01_n71", "args": {"target_cell": 1}},   DONE BUT DISABLED
    # {"name": "SkyWatch_Seq_SA_002_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_002_03_n41", "args": {"target_cell": 201}},
    #
    # {"name": "SkyWatch_Seq_SA_004_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_004_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_004_03_n41", "args": {"target_cell": 201}},   DONE BUT DISABLED

    {"name": "SkyWatch_Seq_SA_005_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_005_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_005_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_006_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_006_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_006_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_008_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_008_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_008_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_009_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_009_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_009_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_025_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_025_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_025_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_027_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_027_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_027_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_028_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_028_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_028_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_046_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_046_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_046_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_047_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_047_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_047_03_n41", "args": {"target_cell": 201}},
    #
    # {"name": "SkyWatch_Seq_SA_010_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_010_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_010_03_n41", "args": {"target_cell": 201}},
    #
    # {"name": "SkyWatch_Seq_SA_029_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_029_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_029_03_n41", "args": {"target_cell": 201}},
    #
    # {"name": "SkyWatch_Seq_SA_048_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_048_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_048_03_n41", "args": {"target_cell": 201}},
    #
    # {"name": "SkyWatch_Seq_SA_011_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_011_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_011_03_n41", "args": {"target_cell": 201}},
    #
    # {"name": "SkyWatch_Seq_SA_030_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_030_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_030_03_n41", "args": {"target_cell": 201}},
    #
    # {"name": "SkyWatch_Seq_SA_049_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_049_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_049_03_n41", "args": {"target_cell": 201}},
    #
    {"name": "SkyWatch_Seq_SA_012_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_012_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_012_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_031_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_031_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_031_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_050_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_050_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_050_03_n41", "args": {"target_cell": 201}},

    # {"name": "SkyWatch_Seq_SA_013_01_n71", "args": {"target_cell": 1}},   DONE BUT DISABLED
    # {"name": "SkyWatch_Seq_SA_013_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_013_03_n41", "args": {"target_cell": 201}},

    # {"name": "SkyWatch_Seq_SA_032_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_032_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_032_03_n41", "args": {"target_cell": 201}},

    # {"name": "SkyWatch_Seq_SA_051_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_051_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_051_03_n41", "args": {"target_cell": 201}},   DONE BUT DISABLED

    {"name": "SkyWatch_Seq_SA_018_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_018_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_018_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_019_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_019_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_019_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_020_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_020_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_020_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_037_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_037_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_037_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_038_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_038_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_038_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_039_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_039_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_039_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_056_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_056_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_056_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_057_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_057_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_057_03_n41", "args": {"target_cell": 201}},

    {"name": "SkyWatch_Seq_SA_058_01_n71", "args": {"target_cell": 1}},
    {"name": "SkyWatch_Seq_SA_058_02_n25", "args": {"target_cell": 21}},
    {"name": "SkyWatch_Seq_SA_058_03_n41", "args": {"target_cell": 201}},

    # {"name": "SkyWatch_Seq_SA_014_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_014_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_014_03_n41", "args": {"target_cell": 201}},
    #
    # {"name": "SkyWatch_Seq_SA_033_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_033_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_033_03_n41", "args": {"target_cell": 201}},
    #
    # {"name": "SkyWatch_Seq_SA_052_01_n71", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_052_02_n25", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_052_03_n41", "args": {"target_cell": 201}},

]

sa_static_scen_without_pdu = [
    # {"name": "SkyWatch_Seq_SA_003_01_nonmMIMO", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_SA_003_01_nonmMIMO", "args": {"target_cell": 21}},
    # {"name": "SkyWatch_Seq_SA_003_02_mMIMO", "args": {"target_cell": 201}},
]

nsa_static_scen = [
    # {"name": "SkyWatch_Seq_NSA_001", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_001", "args": {"target_cell": 201}},
    # {"name": "SkyWatch_Seq_NSA_002", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_002", "args": {"target_cell": 201}},
    # {"name": "SkyWatch_Seq_NSA_003", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_003", "args": {"target_cell": 201}},
    # {"name": "SkyWatch_Seq_NSA_004", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_004", "args": {"target_cell": 201}},
    #
    # {"name": "SkyWatch_Seq_NSA_011", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_011", "args": {"target_cell": 201}},
    # {"name": "SkyWatch_Seq_NSA_012", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_012", "args": {"target_cell": 201}},
    # {"name": "SkyWatch_Seq_NSA_013", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_013", "args": {"target_cell": 201}},
    # {"name": "SkyWatch_Seq_NSA_014", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_014", "args": {"target_cell": 201}},
    #
    # {"name": "SkyWatch_Seq_NSA_021", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_021", "args": {"target_cell": 201}},
    # {"name": "SkyWatch_Seq_NSA_022", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_022", "args": {"target_cell": 201}},
    # {"name": "SkyWatch_Seq_NSA_023", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_023", "args": {"target_cell": 201}},
    # {"name": "SkyWatch_Seq_NSA_024", "args": {"target_cell": 1}},
    # {"name": "SkyWatch_Seq_NSA_024", "args": {"target_cell": 201}},
]


def merge_lists(*lists):
    merged_list = []
    max_length = max(map(len, lists)) if lists else 0

    for i in range(max_length):
        for lst in lists:
            if i < len(lst):
                merged_list.append(lst[i])

    return merged_list


def list_functions_in_module():
    return {name: obj for name, obj in globals().items() if callable(obj)}


def prepare_scenario_list(scen_list, ue_gen, gw_gen=None):
    func_registry = list_functions_in_module()
    callable_functions = []

    for func_data in scen_list:
        func_name = func_data["name"]
        args = func_data["args"]
        args["ue_id"] = next(ue_gen)
        if gw_gen:
            args["pdu_gw_list"] = next(gw_gen)
        args["semaphore"] = SCEN_LIMIT

        if func_name in func_registry:
            func = func_registry[func_name]
            callable_functions.append((func, args))

    return callable_functions
