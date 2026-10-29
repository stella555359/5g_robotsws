# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: zhang bo
:contact: bo.5.zhang@nokia-sbell.com
:maintainer: zhang bo
:contact: bo.5.zhang@nokia-sbell.com
"""

import time
from taf.ul.oam.selenium_coam import selenium_coam


def change_nrlim(EUTRAcellID, earfcn, weburl, distname, username, password):
    NRLIM = {'Allowed measurement bandwidth for EUTRA': 'mbw100',
             'Carrier frequency for EUTRA': earfcn,
             'Absolute priority for NR frequency': '6',
             'Fractional priority for NR frequency': 'oDot2',
             'P-Max for EUTRA': '23',
             'Minimum required quality level for the EUTRA neighbour cell': '-30dB',
             'Minimum required RX level for the EUTRA neighbouring cell': '-65dBm',
             'Threshold SrxLev for reselecting higher priroity RAT/Frequency': '0',
             'Threshold Squal for reselecting higher priroity RAT/Frequency': '0',
             'Threshold SrxLev for reselecting lower priroity RAT/Frequency': '10dB',
             'Threshold Squal for reselecting lower priroity RAT/Frequency': '5dB',
             'Physical cell identifier': EUTRAcellID,
             # 'Offset between serving cell and neighboouring cell':'0',
             'Cell specific quality level offset to qQualMin': '2',
             'Cell specific Rx level offset to qRxLevMin': '2'}
    print(NRLIM.keys())
    coam = selenium_coam()
    coam.enable_virtual_display()
    coam.login(url=weburl, username=username, password=password)
    for key in NRLIM.keys():
        current_value = coam.get_parameter_value(dist_name=distname + '/NRSYSINFO_PROFILE-0/NRLIM-1', filter_param=key)
        print(NRLIM[key])
        print(str(current_value))
        if NRLIM[key] == str(current_value):
            NRLIM == NRLIM.pop(key)
        print(NRLIM)
    if len(NRLIM) > 0:
        for new_key in NRLIM.keys():
            coam.set_parameter_value(dist_name=distname + '/NRSYSINFO_PROFILE-0/NRLIM-1', filter_param=new_key,
                                     new_value=NRLIM[new_key])
        time.sleep(2)
        coam.validate_plan()
        time.sleep(2)
        coam.activate_plan(activate_plan_despite_errors=True)
        time.sleep(2)
        coam.logout()
    else:
        print("NRLIM parameters not need change ")
        coam.logout()
    coam.disable_virtual_display()
