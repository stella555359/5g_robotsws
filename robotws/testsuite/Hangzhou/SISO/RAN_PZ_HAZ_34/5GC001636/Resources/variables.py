from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# General_SiSo_E2E_system_setup_with_data_transfer
Exp_Len = '100m'
frame_structure_list_20MHz = ['1116_3ms_GP1_A5']
frame_structure_list_40MHz = ['1208_GP1_A1']
frame_structure_list_60MHz = ['1070_GP1_B3']
frame_structure_list_80MHz = ['1070_GP1_A3']
frame_structure_list_100MHz = ['1208_GP1_A1']

rate_for_stream = {
    '21B': 'peak',
    '20A': 'peak',
    '20B': 'peak',
    '21A': 'peak',
    'SBTS21B': 'peak',
    'SBTS22R1': 'peak',
    'master': '0.8'
}

# Template of appointed parameter. dynamically replace the value of parameter when run cases
scf_commission_100MHz = [
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'Channel bandwidth', 'p_name': 'chBw',
     'value': '100MHz'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'NR Absolute radio frequency channel number',
     'p_name': 'nrarfcn', 'value': '634464'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'Frame Structure Type',
     'p_name': 'frameStructureType', 'value': 'tdLte'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'Guard Period length',
     'p_name': 'guardPeriodLength', 'value': '6Symbols'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
     'p_name': 'ulDlDataSlotRatio', 'value': '1/4'}
]

scf_commission_30MHz = [
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'Channel bandwidth', 'p_name': 'chBw',
     'value': '30MHz'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'NR Absolute radio frequency channel number',
     'p_name': 'nrarfcn', 'value': '634464'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'Frame Structure Type',
     'p_name': 'frameStructureType', 'value': 'tdLte'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'Guard Period length',
     'p_name': 'guardPeriodLength', 'value': '6Symbols'},
    {'dist_name': 'MRBTS-1900/NRBTS-2458/NRCELL-1', 'filter_param': 'UL to DL logical data slot ratio',
     'p_name': 'ulDlDataSlotRatio', 'value': '1/4'}
]
