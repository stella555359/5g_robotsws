__maintainer__ = 'Chen Xiaodong'
__team__ = '5G_PZ_HZ_2_SG'
__email__ = 'xiaodong.d.chen@nokia-sbell.com'

__all__ = ['mappings', 'iperf_type']


ue_mapping_1 = {
    'mobile_network_system': 'LTE',
    'ue_index': 0,  # ue index in TL
    'cell_pci': 81,
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]

iperf_type = 'via_command'
