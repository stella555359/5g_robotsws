__maintainer__ = 'Tony Tang'
__team__ = 'i_nsb_mn_ran_rd_vrf_haz3_01 '
__email__ = 'tony.2.tang@nokia-sbell.com'


T_F_ALLOCATION = {'TDD': [1, 4, 5], 'FDD': [2, 3]}
ALL_CELLS = T_F_ALLOCATION['TDD'] + T_F_ALLOCATION['FDD']


# unblock the AEHC signal
INIT_PA_T1 = {0: [0, 127, 127, 127]}


gnb_info = {
    'gNbId': '10152',
    'gNbIdLength': '32',
    'mcc': '310',
    'mnc': '260',
    'mncLength': '3',
}


ADD_5QI8_Rule = 'ADD-5QI8-VRF3-CJ3'
DEL_5QI8_Rule = 'DEL-5QI8-VRF3-CJ3'
