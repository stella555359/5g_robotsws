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

# General_SiSo_RF_alarms_without_recovery
Tdanger_init = 110.0
Tdanger_target = 30.0

tput_define_40M = {
    1: {
        'dl_exp': 530,
        'dl_tp': '900M',
        'ul_exp': 23,
        'ul_tp': '100M',
        'ue_index': 0
    },
}
