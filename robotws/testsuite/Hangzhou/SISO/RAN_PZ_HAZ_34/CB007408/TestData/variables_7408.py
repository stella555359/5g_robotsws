from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
# Variables_CFAM = {
#     'UnitType_expect': '<unitType>AE</unitType>',
#     'variant_expect': '<variant>NB</variant>',
#     'ProductCode_expect': '<p Name="Visible.Product.Code">475728A</p>',
#     'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
#     'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>40</p><p>40</p></list>',
#     'LinkType_expect': '<p Name="Interface.Type">CPRI-N</p>'
# }

# General_SiSo_RF_alarms_without_recovery
Tdanger_init = 110.0
Tdanger_target = 30.0

tput_define_8DL8UL_100M = {
    1: {
        'dl_exp': 594,
        'dl_tp': '700M',
        'ul_exp': 49.27,
        'ul_tp': '100M',
        'ue_index': 0
    },
    2: {
        'dl_exp': 1000,
        'dl_tp': '1200M',
        'ul_exp': 60,
        'ul_tp': '100M',
        'ue_index': 1
    },
}

tput_define_16DL8UL_100M = {
    1: {
        'dl_exp': 690,
        'dl_tp': '800M',
        'ul_exp': 49.27,
        'ul_tp': '100M',
        'ue_index': 0
    },
}

tput_define_80M = {
    1: {
        'dl_exp': 1144,
        'dl_tp': '1300M',
        'ul_exp': 66.2,
        'ul_tp': '100M',
        'ue_index': 0
    },
}
