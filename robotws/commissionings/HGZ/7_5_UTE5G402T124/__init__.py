__maintainer__ = 'Wu Jerry'
__team__ = 'mmw2'
__email__ = 'jerry.wu@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'LTE',
    'ue_index': 0,  # ue index in TL
    'cell_id_list': [1],
    'cell_pci': 1,
    'arfcn': 40000,
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
