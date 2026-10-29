from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = "Wu Rong"
__team__ = "I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS "
__email__ = "rong.2.wu@nokia-sbell.com"

from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = "Wu Rong"
__team__ = "I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS "
__email__ = "rong.2.wu@nokia-sbell.com"

__all__ = ['mappings', 'INIT_PA']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1]
}

ue_mapping_2 = {
    'ue_index': 0,  # ue index in TL
    'mobile_network_system': 'LTE',
    'cell_id_list': [1]
}

mappings = [
    {
        'scf_name': 'SCF_TEMPLATE_LTE_B25_10M.xml',  # SCF for LTE only, generated in suite prep
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]

INIT_PA = {0: [0]}
