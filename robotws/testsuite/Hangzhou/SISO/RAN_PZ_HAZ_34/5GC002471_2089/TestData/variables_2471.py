# [1]General_SiSo_Commissioning_BTS_Template_Commissioning_30MHz
scf_commission_30MHz = [
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'Channel bandwidth', 'p_name': 'chBw',
     'value': '30MHz'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'NR Absolute radio frequency channel number',
     'p_name': 'nrarfcn', 'value': '636666'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'Frame Structure Type',
     'p_name': 'frameStructureType', 'value': 'semiStatic'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'Guard Period length',
     'p_name': 'guardPeriodLength', 'value': '2Symbols'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
     'p_name': 'ulDlDataSlotRatio', 'value': '3/7'}
]

ue_list = [0, 1]
cell_list = [1, 2]

cell_and_peak_info_contiguous = {
    '1': {'avg_expect_rate': 0.95,
          'dl_exp': 625,
          'dl_tp': '800M',
          'duration': 600,
          'min_expect_rate': 0.85,
          'peak_dl_tp': 620,
          'peak_ul_tp': 75,
          'ul_exp': 75,
          'ul_tp': '100M'
          },
    '2': {'avg_expect_rate': 0.95,
          'dl_exp': 505,
          'dl_tp': '650M',
          'duration': 600,
          'min_expect_rate': 0.85,
          'peak_dl_tp': 505,
          'peak_ul_tp': 60,
          'ul_exp': 60,
          'ul_tp': '100M'
          }
}

tput_define_contiguous = {
    1: {
        'dl_exp': 625,
        'dl_tp': '800M',
        'ul_exp': 75,
        'ul_tp': '100M',
        'ue_index': 0
    },
    2: {
        'dl_exp': 505,
        'dl_tp': '700M',
        'ul_exp': 60,
        'ul_tp': '100M',
        'ue_index': 1
    }
}

tput_define_2471 = {
    1: {
        'dl_exp': 1030,
        'dl_tp': '1200M',
        'ul_exp': 131.5,
        'ul_tp': '200M',
        'ue_index': 0
    }
}

frame_structure_list_50MHz_40MHz = [
    {'cellid': 1, 'frame': ['1070_GP1_A3'], 'band': '50', 'prach_index': ['98'], 'beamset': '2 beams',
     'dl_ul_layer': '4DL2UL', 'dl_modulation': 'dl_256QAM'},
    {'cellid': 2, 'frame': ['1070_GP1_A3'], 'band': '40', 'prach_index': ['98'], 'beamset': '2 beams',
     'dl_ul_layer': '4DL2UL', 'dl_modulation': 'dl_256QAM'},
]
