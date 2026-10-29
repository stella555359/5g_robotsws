__maintainer__ = 'Zhong Tingting'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'BOTH',
    'cell_id_list': [141],
    'cell_pci': 478,
    'arfcn': 633408,
    'scs': 30,  # optional, only Receiver 28A used
    'dl_iperf_process': 5,
    'ul_iperf_process': 5,
    'ue_ul_layer': 2    # now all ue ue_ul_layer should be same
}

ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'network_type': 'BOTH',
    'cell_id_list': [143],
    'cell_pci': 480,
    'arfcn': 465850,
    'scs': 30,  # optional, only Receiver 28A used
    'dl_iperf_process': 5,
    'ul_iperf_process': 5,
    'ue_ul_layer': 2    # now all ue ue_ul_layer should be same
}


mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    }
]
