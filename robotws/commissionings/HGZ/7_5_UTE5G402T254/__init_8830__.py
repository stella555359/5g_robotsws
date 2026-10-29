__maintainer__ = 'Wu Rong'
__team__ = 'i_nsb_mn_ran_rd_vrf_haz3_01 '
__email__ = 'rong.2.wu@nokia-sbell.com'


T_F_ALLOCATION = {'TDD': [1, 4, 5], 'FDD': [2, 3]}
ALL_CELLS = T_F_ALLOCATION['TDD'] + T_F_ALLOCATION['FDD']


# unblock the AEHC signal
INIT_PA_T1 = {0: [0, 127, 127, 127]}


gnb_info = {
    'gNbId': '1170',
    'gNbIdLength': '32',
    'mcc': '460',
    'mnc': '2',
    'mncLength': '2',
}


ADD_5QI8_Rule = 'ADD-5QI8-VRF3-CJ5'
DEL_5QI8_Rule = 'DEL-5QI8-VRF3-CJ5'
