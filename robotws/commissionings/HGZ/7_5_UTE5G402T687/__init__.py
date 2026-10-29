__maintainer__ = 'Liu Shasha'
__team__ = 'NSB MN RAN Pz 4 HAZ 5 SG'
__email__ = 'shasha.liu@nokia-sbell.com'

__all__ = ['mappings', 'protocol']

ue_mapping_1 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1],
    'ul_iperf_process': 5,
    'ue_ul_layer': 2    # now all ue ue_ul_layer should be same
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]

protocol = 'udp'
