# -*- coding: utf-8 -*-
"""
Author: Liu Zheng
Contacts: zheng.4.liu@nokia-sbell.com
"""
import math
import logging


def get_average_peakMetric_dbm_value(peak_metric_list):
    peakmetric_dbm_list = []
    for element_bip in peak_metric_list:
        element_bip_float = float(element_bip)
        element_100 = 100 * 10 * math.log10(element_bip_float)
        element_floor = math.floor(element_100)
        element = element_floor/100
        logging.debug(
            "peakMetric in mW:{} , transfer to dBM is:{}".format(element_bip, element))
        peakmetric_dbm_list.append(element)
    if len(peakmetric_dbm_list) == 0:
        raise Exception("there is no peakmetric element in peak_metric_list, Please check the BIP log firstly")
    else:
        peakmetric_dbm_average_tmp = sum(peakmetric_dbm_list) / len(peakmetric_dbm_list)
        peakmetric_dbm_average = round(peakmetric_dbm_average_tmp, 2)

    return peakmetric_dbm_average


def get_the_updated_preamble_power_PRACH_level_based_on_peakmetric(
        peak_metric_list):
    """
    according to list values, get the updated counter values.

    Args:
        peak_metric_list: get from BIP Logs

    Returns:
        tuple:
    """
    M55340C00026_value = 0
    M55340C00027_value = 0
    M55340C00028_value = 0
    M55340C00029_value = 0
    M55340C00030_value = 0
    M55340C00031_value = 0
    M55340C00032_value = 0
    M55340C00033_value = 0
    M55340C00034_value = 0
    M55340C00035_value = 0
    M55340C00036_value = 0
    M55340C00037_value = 0
    M55340C00038_value = 0
    M55340C00039_value = 0
    M55340C00040_value = 0
    M55340C00041_value = 0
    M55340C00042_value = 0
    M55340C00043_value = 0
    M55340C00044_value = 0
    M55340C00045_value = 0
    M55340C00046_value = 0
    M55340C00047_value = 0
    M55340C00048_value = 0
    M55340C00049_value = 0
    M55340C00050_value = 0
    M55340C00051_value = 0
    M55340C00052_value = 0
    M55340C00053_value = 0
    M55340C00054_value = 0
    M55340C00055_value = 0
    M55340C00056_value = 0
    M55340C00057_value = 0
    M55340C00058_value = 0
    M55340C00059_value = 0
    M55340C00060_value = 0
    M55340C00061_value = 0
    M55340C00062_value = 0
    M55340C00063_value = 0
    M55340C00064_value = 0
    M55340C00065_value = 0
    M55340C00066_value = 0
    M55340C00067_value = 0
    M55340C00068_value = 0
    M55340C00069_value = 0
    PM_counters_dict = {}

    for element_bip in peak_metric_list:
        element_bip_float = float(element_bip)
        element_100 = 100 * 10 * math.log10(element_bip_float)
        element_floor = math.floor(element_100)
        element = element_floor/100
        if element <= -114:
            M55340C00026_value += 1
        elif (-114 <= element <= -112):
            M55340C00027_value += 1
        elif (-112 <= element <= -110):
            M55340C00028_value += 1
        elif (-110 <= element <= -108):
            M55340C00029_value += 1
        elif (-108 <= element <= -106):
            M55340C00030_value += 1
        elif (-106 <= element <= -104):
            M55340C00031_value += 1
        elif (-104 <= element <= -102):
            M55340C00032_value += 1
        elif (-102 <= element <= -100):
            M55340C00033_value += 1
        elif (-100 <= element <= -98):
            M55340C00034_value += 1
        elif (-98 <= element <= -96):
            M55340C00035_value += 1
        elif (-96 <= element <= -94):
            M55340C00036_value += 1
        elif (-94 <= element <= -92):
            M55340C00037_value += 1
        elif (-92 <= element <= -90):
            M55340C00038_value += 1
        elif (-90 <= element <= -88):
            M55340C00039_value += 1
        elif (-88 <= element <= -86):
            M55340C00040_value += 1
        elif (-86 <= element <= -84):
            M55340C00041_value += 1
        elif (-84 <= element <= -82):
            M55340C00042_value += 1
        elif (-82 <= element <= -80):
            M55340C00043_value += 1
        elif (-80 <= element <= -78):
            M55340C00044_value += 1
        elif (-78 <= element <= -76):
            M55340C00045_value += 1
        elif (-76 <= element <= -74):
            M55340C00046_value += 1
        elif (-74 <= element <= -72):
            M55340C00047_value += 1
        elif (-72 <= element <= -70):
            M55340C00048_value += 1
        elif (-70 <= element <= -68):
            M55340C00049_value += 1
        elif (-68 <= element <= -66):
            M55340C00050_value += 1
        elif (-66 <= element <= -64):
            M55340C00051_value += 1
        elif (-64 <= element <= -62):
            M55340C00052_value += 1
        elif (-62 <= element <= -60):
            M55340C00053_value += 1
        elif (-60 <= element <= -58):
            M55340C00054_value += 1
        elif (-58 <= element <= -56):
            M55340C00055_value += 1
        elif (-56 <= element <= -54):
            M55340C00056_value += 1
        elif (-54 <= element <= -52):
            M55340C00057_value += 1
        elif (-52 <= element <= -50):
            M55340C00058_value += 1
        elif (-50 <= element <= -48):
            M55340C00059_value += 1
        elif (-48 <= element <= -46):
            M55340C00060_value += 1
        elif (-46 <= element <= -44):
            M55340C00061_value += 1
        elif (-44 <= element <= -42):
            M55340C00062_value += 1
        elif (-42 <= element <= -40):
            M55340C00063_value += 1
        elif (-40 <= element <= -38):
            M55340C00064_value += 1
        elif (-38 <= element <= -36):
            M55340C00065_value += 1
        elif (-36 <= element <= -34):
            M55340C00066_value += 1
        elif (-34 <= element <= -32):
            M55340C00067_value += 1
        elif (-32 <= element <= -30):
            M55340C00068_value += 1
        elif (-30 <= element):
            M55340C00069_value += 1
        else:
            raise Exception("peakmetric value not valid, no counter matched")
    PM_counters_dict = dict(M55340C00026=M55340C00026_value,
                            M55340C00027=M55340C00027_value,
                            M55340C00028=M55340C00028_value,
                            M55340C00029=M55340C00029_value,
                            M55340C00030=M55340C00030_value,
                            M55340C00031=M55340C00031_value,
                            M55340C00032=M55340C00032_value,
                            M55340C00033=M55340C00033_value,
                            M55340C00034=M55340C00034_value,
                            M55340C00035=M55340C00035_value,
                            M55340C00036=M55340C00036_value,
                            M55340C00037=M55340C00037_value,
                            M55340C00038=M55340C00038_value,
                            M55340C00039=M55340C00039_value,
                            M55340C00040=M55340C00040_value,
                            M55340C00041=M55340C00041_value,
                            M55340C00042=M55340C00042_value,
                            M55340C00043=M55340C00043_value,
                            M55340C00044=M55340C00044_value,
                            M55340C00045=M55340C00045_value,
                            M55340C00046=M55340C00046_value,
                            M55340C00047=M55340C00047_value,
                            M55340C00048=M55340C00048_value,
                            M55340C00049=M55340C00049_value,
                            M55340C00050=M55340C00050_value,
                            M55340C00051=M55340C00051_value,
                            M55340C00052=M55340C00052_value,
                            M55340C00053=M55340C00053_value,
                            M55340C00054=M55340C00054_value,
                            M55340C00055=M55340C00055_value,
                            M55340C00056=M55340C00056_value,
                            M55340C00057=M55340C00057_value,
                            M55340C00058=M55340C00058_value,
                            M55340C00059=M55340C00059_value,
                            M55340C00060=M55340C00060_value,
                            M55340C00061=M55340C00061_value,
                            M55340C00062=M55340C00062_value,
                            M55340C00063=M55340C00063_value,
                            M55340C00064=M55340C00064_value,
                            M55340C00065=M55340C00065_value,
                            M55340C00066=M55340C00066_value,
                            M55340C00067=M55340C00067_value,
                            M55340C00068=M55340C00068_value,
                            M55340C00069=M55340C00069_value)
    return PM_counters_dict
