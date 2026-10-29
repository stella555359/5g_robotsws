__maintainer__ = 'Liu Zheng'
__team__ = '5G_PZ_HZ_3_SG01'
__email__ = 'zheng.4.liu@nokia-sbell.com'

__all__ = ['mappings', 'INIT_PA']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1],
    'mobile_network_system': 'NR',
}

# LTE
ue_mapping_2 = {
    'mobile_network_system': 'LTE',
    'ue_index': 0,  # ue index in TL    # mandatory
    'cell_id_list': [1],    # mandatory
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

# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
INIT_PA = {0: [0]}
