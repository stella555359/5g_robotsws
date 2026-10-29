# Used for block all PA ports before initialize
PA_OUT_PORTS = [5, 6, 7, 8]
PA_ROWS = 8
PA_MAX_COLUMN_NUM = 32
PA_MAX_SUPPORTED_VALUE = 120

INIT_PA_5CC = {0: [0,
                   PA_MAX_SUPPORTED_VALUE,
                   PA_MAX_SUPPORTED_VALUE,
                   0,
                   PA_MAX_SUPPORTED_VALUE,
                   PA_MAX_SUPPORTED_VALUE,
                   0,
                   PA_MAX_SUPPORTED_VALUE,
                   ]}
# Used for calculate exepected tput for CA.
# dl/ul tput discount is not used for now. If it can be commonly used, will consider to add to common calculation
# 0.75 dl discount for cell 1 and 21 are due to LTE interference
# 0.73 ul discount for cell 21 is due to TX switching functionality
EXP_CELL_TPUT_INFO = {
    1: {'bandwidth': '15M', 'maxMIMO_layers_ul': '1', 'ul_tput': '', 'maxMIMO_layers_dl': '2', 'dl_tput': 160*0.75,
        'dl_tput_discount': 0.75},
    21: {'bandwidth': '20M', 'maxMIMO_layers_ul': '2', 'ul_tput': 228*0.73, 'maxMIMO_layers_dl': '4',
         'dl_tput': 395*0.75, 'ul_tput_discount': 0.73, 'dl_tput_discount': 0.75},
    41: {'bandwidth': '5M', 'maxMIMO_layers_ul': '1', 'ul_tput': '', 'maxMIMO_layers_dl': '4', 'dl_tput': 80},
    301: {'bandwidth': '100M', 'maxMIMO_layers_ul': '2', 'ul_tput': 230, 'maxMIMO_layers_dl': '4', 'dl_tput': 1560},
    311: {'bandwidth': '90M', 'maxMIMO_layers_ul': '1', 'ul_tput': '', 'maxMIMO_layers_dl': '4', 'dl_tput': 1390}
}

#  Pcell: 21; Scell: 1; 301; 41; 311
CA_GROUP_F_T_5CC = {
    'pcell_id': 21,
    'init_pa_value': INIT_PA_5CC
}

#  Pcell: 301; Scell: 1; 21; 41; 311
CA_GROUP_T_F_5CC = {
    'pcell_id': 301,
    'init_pa_value': INIT_PA_5CC
}
