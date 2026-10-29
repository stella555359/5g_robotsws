#!/bin/python -B
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)


    Bellow is the list of known used NR 5G chipset Qualcomm under NOKIA Paris Saclay Entity
    don't hesitate to feel up the dictionary with new chipset pair
    Use the adb command line to get the hardware info:
        adb shell cat /proc/cpuinfo | grep -i Hardware
"""

QCT_Chipset = {
    'SM8150': 'SDX50',  # Hardware	: Qualcomm Technologies, Inc SM8150
    'KONA': 'SDX55'     # Hardware        : Qualcomm Technologies, Inc KONA
}
