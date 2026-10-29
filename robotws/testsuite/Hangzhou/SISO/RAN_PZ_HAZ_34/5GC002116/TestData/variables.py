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
    '20B': 'peak',
    '21A': '0.8',
    'SBTS21B': '0.8',
    'SBTS22R1': '0.8',
    'master': '0.8'
}

rate_for_stream_min = {
    '20B': '0.8',
    '21A': '0.8',
    'SBTS21B': '0.8',
    'SBTS22R1': '0.8',
    'master': '0.8'
}

# General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
# General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
# General_SiSo_NR-ARFCN_check
Variables_CFAM_AEQE_CPRI = {
    'AEQE': {
        'Unit_name': 'AEQE',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QE</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474750A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    }
}
