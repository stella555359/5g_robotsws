__maintainer__ = 'Liu Shasha'
__team__ = 'RAN_PZ_HAZ4_SG05'
__email__ = 'shasha.liu@nokia-sbell.com'

__all__ = ['mappings', 'ui_version', 'protocol']

ue_mapping_0 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1]
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_0],
    }
]

ui_version = 'S21UI4.0'
protocol = 'udp'
