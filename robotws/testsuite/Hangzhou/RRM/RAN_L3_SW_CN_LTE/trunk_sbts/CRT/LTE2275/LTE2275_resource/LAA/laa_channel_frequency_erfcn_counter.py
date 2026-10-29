"""
:copyright: Nokia Networks
:author: Aleksander Kleczek
:contact:
:maintainer: None
:contact: None
"""
from __future__ import print_function
from builtins import str
from importlib import import_module


radarDetectionResults_mapping = [
    52,
    56,
    60,
    64,
    68,
    96,
    100,
    104,
    108,
    112,
    116,
    120,
    124,
    128,
    132,
    136,
    140,
    144,
]

laa_rrh_param_sb_result_mapping = {
    1: [68, 64, 60, 56, 52, 48, 44, 40, 36, 32],
    2: [136, 132, 128, 124, 120, 116, 112, 108, 104, 100],
    3: [144, 140, 136, 132, 128, 124, 120, 116, 112, 108],
    4: [165, 161, 157, 153, 149],
    5: [68, 64, 60, 56, 52, 48, 44, 40, 36, 32],
    6: [165, 161, 157, 153, 149, 144, 140, 136, 132, 128],
}

uCellChannelSList_mapping = [
    149,
    153,
    157,
    161,
    165,
    32,
    36,
    40,
    44,
    48,
    52,
    56,
    60,
    64,
    68,
    96,
    100,
    104,
    108,
    112,
    116,
    120,
    124,
    128,
    132,
    136,
    140,
    144,
]

channel_frequency_map = {
    32: 5160.0,
    36: 5180.1,
    40: 5199.9,
    44: 5220.0,
    48: 5239.8,
    52: 5259.9,
    56: 5280.0,
    60: 5299.8,
    64: 5319.9,
    68: 5340.0,
    96: 5480.0,
    100: 5500.1,
    104: 5519.9,
    108: 5540.0,
    112: 5560.1,
    116: 5579.9,
    120: 5600.0,
    124: 5620.1,
    128: 5639.9,
    132: 5660.0,
    136: 5680.1,
    140: 5699.9,
    144: 5720.0,
    149: 5745.0,
    153: 5765.1,
    157: 5784.9,
    161: 5805.0,
    165: 5825.1,
}

channel_earfcn_map = {
    32: 46890,
    36: 47091,
    40: 47289,
    44: 47490,
    48: 47688,
    52: 47889,
    56: 48090,
    60: 48288,
    64: 48489,
    68: 48690,
    96: 50090,
    100: 50291,
    104: 50489,
    108: 50690,
    112: 50891,
    116: 51089,
    120: 51290,
    124: 51491,
    128: 51689,
    132: 51890,
    136: 52091,
    140: 52289,
    144: 52490,
    149: 52740,
    153: 52941,
    157: 53139,
    161: 53340,
    165: 53541,
}

subband_channel_map = {
    1: [32, 36, 40, 44, 48, 52, 56, 60, 64, 68],
    2: [100, 104, 108, 112, 116, 120, 124, 128, 132, 136],
    3: [108, 112, 116, 120, 124, 128, 132, 136, 140, 144],
    4: [128, 132, 136, 140, 144, 149, 153, 157, 161, 165],
    5: [36, 40, 44, 48],
    6: [149, 153, 157, 161, 165],
}

CCA_SUCCESS = {
    "36": "M8079C76",
    "40": "M8079C77",
    "44": "M8079C78",
    "48": "M8079C79",
    "52": "M8079C21",
    "56": "M8079C22",
    "60": "M8079C23",
    "64": "M8079C24",
    "100": "M8079C25",
    "104": "M8079C26",
    "108": "M8079C27",
    "112": "M8079C28",
    "116": "M8079C29",
    "120": "M8079C30",
    "124": "M8079C31",
    "128": "M8079C32",
    "132": "M8079C33",
    "136": "M8079C34",
    "140": "M8079C35",
    "144": "M8079C36",
    "149": "M8079C71",
    "153": "M8079C72",
    "157": "M8079C73",
    "161": "M8079C74",
    "165": "M8079C75",
}

CCA_ATTEMPTS = {
    "36": "M8079C80",
    "40": "M8079C81",
    "44": "M8079C82",
    "48": "M8079C83",
    "52": "M8079C37",
    "56": "M8079C38",
    "60": "M8079C39",
    "64": "M8079C40",
    "100": "M8079C41",
    "104": "M8079C42",
    "108": "M8079C43",
    "112": "M8079C44",
    "116": "M8079C45",
    "120": "M8079C46",
    "124": "M8079C47",
    "128": "M8079C48",
    "132": "M8079C49",
    "136": "M8079C50",
    "140": "M8079C51",
    "144": "M8079C52",
    "149": "M8079C84",
    "153": "M8079C85",
    "157": "M8079C86",
    "161": "M8079C87",
    "165": "M8079C88",
}

RADAR = {
    "52": "M8079C53",
    "56": "M8079C54",
    "60": "M8079C55",
    "64": "M8079C56",
    "100": "M8079C57",
    "104": "M8079C58",
    "108": "M8079C59",
    "112": "M8079C60",
    "116": "M8079C61",
    "120": "M8079C62",
    "124": "M8079C63",
    "128": "M8079C64",
    "132": "M8079C65",
    "136": "M8079C66",
    "140": "M8079C67",
    "144": "M8079C68",
}

COUNTER_TYPES = ["CCA_SUCCESS", "CCA_ATTEMPTS", "RADAR"]


def get_channel_frequency(channel):
    return channel_frequency_map[channel]


def get_channel_earfcn(channel):
    return channel_earfcn_map[channel]


def get_frequency_channel(frequency):
    return list(channel_frequency_map.keys())[
        list(channel_frequency_map.values()).index(frequency)
    ]


def get_earfcn_channel(earfcn):
    return list(channel_earfcn_map.keys())[
        list(channel_earfcn_map.values()).index(earfcn)
    ]


def get_channel_list_by_subband(subband):
    return subband_channel_map[subband]


def get_subband_list_by_channel(channel):
    return [
        subband
        for subband in list(subband_channel_map.keys())
        if channel in subband_channel_map[subband]
    ]


def get_counter_for_channel(channel, counter_type):
    assert str(counter_type) in COUNTER_TYPES, "Type {} not supported, use: {}".format(
        counter_type, COUNTER_TYPES
    )
    counter_database = globals()[counter_type]
    return counter_database[str(channel)] if str(channel) in counter_database else None


if __name__ == "__main__":
    # print(get_earfcn_channel(52740))
    # print(get_channel_earfcn(149))
    # print(get_frequency_channel(5745.0))
    # print(get_channel_frequency(149))

    # for i in range(32, 68, 4):
    #     print("{} <-> {}: {} ({})".format(i, i + 4, channel_frequency_map[i + 4] - channel_frequency_map[i],
    #                                       channel_earfcn_map[i + 4] - channel_earfcn_map[i]))
    # for i in range(96, 144, 4):
    #     print("{} <-> {}: {} ({})".format(i, i + 4, channel_frequency_map[i + 4] - channel_frequency_map[i],
    #                                       channel_earfcn_map[i + 4] - channel_earfcn_map[i]))
    # for i in range(149, 165, 4):
    #     print("{} <-> {}: {} ({})".format(i, i + 4, channel_frequency_map[i + 4] - channel_frequency_map[i],
    #                                       channel_earfcn_map[i + 4] - channel_earfcn_map[i]))

    print(get_counter_for_channel(52, "RADAR"))
