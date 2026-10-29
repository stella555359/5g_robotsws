__maintainer__ = 'Liu Zheng'
__team__ = '5G_PZ_HZ_3_SG01'
__email__ = 'zheng.4.liu@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1]
}

# LTE
ue_mapping_2 = {
    'mobile_network_system': 'LTE',    # optional, if not exist, will be NR
    'ue_index': 0,  # ue index in TL    # mandatory
    'cell_id_list': [1],    # mandatory
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
