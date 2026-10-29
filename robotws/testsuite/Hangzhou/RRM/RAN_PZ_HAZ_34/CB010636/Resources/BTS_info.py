import os

__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS'
__email__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS@internal.nsn.com'

cell_info = {
    577: {'type': 'FR1_FDD', 'BW': 20, 'GNB_IP': '10.71.209.66', 'NRcellID': 167215105},
    574: {'type': 'FR1_FDD', 'BW': 20, 'GNB_IP': '10.71.209.77', 'NRcellID': 191283201},
    575: {'type': 'FR1_TDD', 'BW': 90, 'GNB_IP': '10.71.209.77', 'NRcellID': 191283202},
    576: {'type': 'FR1_TDD', 'BW': 90, 'GNB_IP': '10.71.209.77', 'NRcellID': 191283203},
}

pmqap_channnel_info = {'NRPMQAP-5': 4,
                       'NRPMQAP-7': 5,
                       'NRPMQAP-8': 6,
                       'NRPMQAP-9': 7,
                       }


DL_RLC_CC_FR1_SA_Counter = {1:
                            {'VOL': 'M55349C00026',
                                'TIME': 'M55349C00032'
                             },
                            2:
                                {'VOL': 'M55349C00027',
                                 'TIME': 'M55349C00033'
                                 },
                            3:
                                {'VOL': 'M55349C00028',
                                 'TIME': 'M55349C00034'
                                 },
                            4:
                                {'VOL': 'M55349C00029',
                                 'TIME': 'M55349C00035'
                                 },
                            5:
                                {'VOL': 'M55349C00030',
                                 'TIME': 'M55349C00036'
                                 },
                            }

PA_Info1 = {'IP': '10.71.203.150',
            'Port': '5000',
            'Port_Value': {13: 10,
                           14: 10,
                           15: 10,
                           16: 10},
            }

PA_Info2 = {'IP': '10.71.203.137',
            'Port': '5000',
            'Port_Value': {1: 0,
                           2: 0,
                           3: 0,
                           4: 0,
                           9: 10,
                           10: 10,
                           11: 10,
                           12: 10,
                           13: 10,
                           14: 10,
                           15: 10,
                           16: 10
                           },
            }

Block_TL926_PA = {'IP': 'None',
                  'Port': '5000',
                  'Port_Value': {1: 127,
                                 2: 127,
                                 3: 127,
                                 4: 127
                                 },
                  }

filter_info_list = ['WRN/', 'ERR/']

white_list = ['HandleGPSDataChange: reset_request indication']
