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
    '19B': 'peak',
    '20A': 'peak',
    '20B': 'peak',
    'SBTS21B': '0.8',
    'SBTS22R1': '0.8',
    'master': '0.8'
}

# General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
Variables_CFAM = {
    'Uint_name': 'AEQP',
    'unitType_expect': '<unitType>AE</unitType>',
    'variant_expect': '<variant>QP</variant>',
    'ProductCode_expect': '<p Name="Visible.Product.Code">475238A</p>',
    'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p><p>EUTRA</p></list>',
    'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
    'LinkType_expect': '<p Name="Type">CPRI</p>'
}
