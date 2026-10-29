from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# General_Peak_with_Given_Frame_Structure
band_list_1116_3ms_GP2_A6 = [100]
band_list_1070_GP1_A3 = [100]

# General_SiSo_E2E_system_setup_with_data_transfer
# General_gnb_can_be_on_air_with_Given_Frame_Structure
Exp_Len = '60m'
frame_structure_list_100MHz = ['1116_3ms_GP2_A6', '1070_GP1_A3']

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
Variables_CFAM_AWHQV_CPRI = {
    'AWHQV': {
        'Unit_name': 'AWHQV',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HQV</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475784A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AWHTA': {
        'Unit_name': 'AWHTA',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HTA</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475245A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>79</p><p>79</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    }
}
