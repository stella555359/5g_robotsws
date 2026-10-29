# General_SiSo_E2E_system_setup_with_data_transfer
frame_structure_list_60MHz = ['1116_0ms_GP2_A7']
frame_structure_list_40MHz = ['1116_0ms_GP2_A7']

rate_for_stream = {
    '21A': 'peak',
    'SBTS21B': '0.8',
    'SBTS22R1': '0.8',
    'master': '0.8'
}

# General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
Variables_CFAM_AEQV_eCPRI = {
    'AEQV': {
        'Unit_name': 'AEQV',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QV</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475294A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">CPRI-N,eCPRI</p>'
    }
}
