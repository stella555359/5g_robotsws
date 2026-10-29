# General_SiSo_E2E_system_setup_with_data_transfer
Exp_Len = '100m'
# frame_structure_list_20MHz = ['1116_3ms_GP1_A5']
# frame_structure_list_30MHz = ['1070_GP1_A3']
frame_structure_list_40MHz = ['1070_GP1_A3']
frame_structure_list_50MHz = ['1070_GP1_A3']
# frame_structure_list_60MHz = ['1070_GP1_B3']
# frame_structure_list_80MHz = ['1070_GP1_A3']
# frame_structure_list_100MHz = ['1116_0ms_GP2_A7']

rate_for_stream = {
    '21A': 'peak',
    '20B': 'peak',
    'master': '0.8'
}

# General_SiSo_E2E_system_setup_with_data_transfer
frame_structure_list_40MHz_50MHz = [
    {'cellid': 1, 'frame': ['1070_GP1_A3'], 'band':'40', 'prach_index':['98'], 'beamset':'2 beams',
     'dl_ul_layer': '4DL4UL', 'dl_modulation':'dl_256QAM'},
    {'cellid': 2, 'frame': ['1070_GP1_A3'], 'band':'50', 'prach_index':['98'], 'beamset':'2 beams',
     'dl_ul_layer': '4DL4UL', 'dl_modulation':'dl_256QAM'},
]
