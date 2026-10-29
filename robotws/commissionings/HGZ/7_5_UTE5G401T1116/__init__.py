__maintainer__ = 'yajli'
__team__ = 'VRF_HAZ4_T01'
__email__ = 'yajie.li@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'BOTH',
    'cell_id_list': [1],
    'ul_iperf_process': 5
}


mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
