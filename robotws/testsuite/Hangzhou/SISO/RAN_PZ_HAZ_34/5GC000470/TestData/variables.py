from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# General_SiSo_E2E_system_setup_with_data_transfer
Exp_Len = '5m'
frame_structure_list_60MHz = ['1116_3ms_GP1_A5']
frame_structure_list_80MHz = ['1208_GP1_B1']
frame_structure_list_100MHz = ['1116_0ms_GP2_A7']

rate_for_stream = {
    '19B': 'peak',
    '20A': 'peak',
    '20B': 'peak',
    'SBTS21B': 'peak',
    'SBTS22R1': 'peak',
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
# General_SiSo_NR-ARFCN_check
Variables_CFAM_470 = {
    'AWHHD': {
        'Unit_name': 'AWHHD',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HHD</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475068A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>41</p><p>41</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AEQV': {
        'Unit_name': 'AEQV',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QV</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475294A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    }
}
