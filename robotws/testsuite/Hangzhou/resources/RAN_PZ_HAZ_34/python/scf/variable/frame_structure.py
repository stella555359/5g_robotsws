# -*- coding: utf-8 -*
"""
Author:        Zhong Tingting
Contacts:      tingting.zhong@nokia-sbell.com
Description:   dictionary FRAME_STRUCTURE use for frame structure mapping with gnb parameter details

"""

FRAME_STRUCTURE_CORRESPOND_DICTIONARY = {
    '1208_GP1_A1': {
        'frameStructureType': 'semiStatic', 'guardPeriodLength': '2Symbols', 'ulDlDataSlotRatio': '1/4',
        'timingAdvanceOffset': 'n25600'},
    '1208_GP2_A2': {
        'frameStructureType': 'semiStatic', 'guardPeriodLength': '4Symbols', 'ulDlDataSlotRatio': '1/4',
        'timingAdvanceOffset': 'n25600'},
    '1070_GP1_A3': {
        'frameStructureType': 'semiStatic', 'guardPeriodLength': '2Symbols', 'ulDlDataSlotRatio': '3/7',
        'timingAdvanceOffset': 'n25600'},
    '1070_GP2_A4': {
        'frameStructureType': 'semiStatic', 'guardPeriodLength': '4Symbols', 'ulDlDataSlotRatio': '3/7',
        'timingAdvanceOffset': 'n25600'},
    '1116_3ms_GP1_A5': {
        'frameStructureType': 'tdLte', 'guardPeriodLength': '4Symbols', 'lteToNrFrameShift': '3ms',
        'tdLteUlDlConfig': 'tdLteConfig2', 'timingAdvanceOffset': 'n25600'},
    '1116_3ms_GP2_A6': {
        'frameStructureType': 'tdLte', 'guardPeriodLength': '6Symbols', 'lteToNrFrameShift': '3ms',
        'tdLteUlDlConfig': 'tdLteConfig2', 'timingAdvanceOffset': 'n25600'},
    '1116_0ms_GP2_A7': {
        'frameStructureType': 'tdLte', 'guardPeriodLength': '6Symbols', 'lteToNrFrameShift': '0ms',
        'tdLteUlDlConfig': 'tdLteConfig2', 'timingAdvanceOffset': 'n25600'},
    '1116_0ms_GP1_A8': {
        'frameStructureType': 'tdLte', 'guardPeriodLength': '4Symbols', 'lteToNrFrameShift': '0ms',
        'tdLteUlDlConfig': 'tdLteConfig2', 'timingAdvanceOffset': 'n25600'},
    '1208_GP1_B1': {
        'frameStructureType': 'semiStatic', 'guardPeriodLength': '2Symbols', 'ulDlDataSlotRatio': '1/4',
        'timingAdvanceOffset': 'n39936'},
    '1208_GP2_B2': {
        'frameStructureType': 'semiStatic', 'guardPeriodLength': '4Symbols', 'ulDlDataSlotRatio': '1/4',
        'timingAdvanceOffset': 'n39936'},
    '1070_GP1_B3': {
        'frameStructureType': 'semiStatic', 'guardPeriodLength': '2Symbols', 'ulDlDataSlotRatio': '3/7',
        'timingAdvanceOffset': 'n39936'},
    '1070_GP2_B4': {
        'frameStructureType': 'semiStatic', 'guardPeriodLength': '4Symbols', 'ulDlDataSlotRatio': '3/7',
        'timingAdvanceOffset': 'n39936'},
    '1116_3ms_GP1_B5': {
        'frameStructureType': 'tdLte', 'guardPeriodLength': '4Symbols', 'lteToNrFrameShift': '3ms',
        'tdLteUlDlConfig': 'tdLteConfig2', 'timingAdvanceOffset': 'n39936'},
    '1116_3ms_GP2_B6': {
        'frameStructureType': 'tdLte', 'guardPeriodLength': '6Symbols', 'lteToNrFrameShift': '3ms',
        'tdLteUlDlConfig': 'tdLteConfig2', 'timingAdvanceOffset': 'n39936'},
    '1116_0ms_GP2_B7': {
        'frameStructureType': 'tdLte', 'guardPeriodLength': '6Symbols', 'lteToNrFrameShift': '0ms',
        'tdLteUlDlConfig': 'tdLteConfig2', 'timingAdvanceOffset': 'n39936'},
    '1116_0ms_GP1_B8': {
        'frameStructureType': 'tdLte', 'guardPeriodLength': '4Symbols', 'lteToNrFrameShift': '0ms',
        'tdLteUlDlConfig': 'tdLteConfig2', 'timingAdvanceOffset': 'n39936'},
    '1127': {
        'frameStructureType': 'semiStatic', 'guardPeriodLength': '2Symbols', 'ulDlDataSlotRatio': '1/4',
        'timingAdvanceOffset': 'n13792'},
}
