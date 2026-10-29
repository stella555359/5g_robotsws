from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# General_SiSo_E2E_system_setup_with_data_transfer
Exp_Len = '5m'
frame_structure_list_20MHz = ['1070_GP1_A3']

rate_for_stream = {
    '20A': 'peak',
    '20B': 'peak',
    'SBTS21B': '0.9',
    'SBTS22R1': '0.9',
    'master': '0.85'
}

rate_for_stream_min = {
    '20B': '0.8',
    '21A': '0.8',
    'SBTS21B': '0.8',
    'SBTS22R1': '0.8',
    'master': '0.8'
}
