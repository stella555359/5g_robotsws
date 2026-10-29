from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
Variables_CFAM = {
    'UnitType_expect': '<unitType>AE</unitType>',
    'variant_expect': '<variant>NB</variant>',
    'ProductCode_expect': '<p Name="Visible.Product.Code">475728A</p>',
    'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
    'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>40</p><p>40</p></list>',
    'LinkType_expect': '<p Name="Interface.Type">CPRI-N</p>'
}

tput_define_60M = {
    1: {
        'dl_exp': 836,
        'dl_tp': '1083.95M',
        'ul_exp': 35.67,
        'ul_tp': '53.51M',
        'ue_index': 0
    },
}
