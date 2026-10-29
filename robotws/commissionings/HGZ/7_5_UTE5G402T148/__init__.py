__maintainer__ = 'Deng Qingqing'
__team__ = 'mmw2'
__email__ = 'qingqing.deng@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'LTE',
    'ue_index': 0,  # ue index in TL
    'cell_id_list': [193],
    'cell_pci': 123,
    'arfcn': 43960,
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
