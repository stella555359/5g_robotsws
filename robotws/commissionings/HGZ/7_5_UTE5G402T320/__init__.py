__maintainer__ = 'Zhong Tingting'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 1,  # ue index in Testline configruation file
    'network_type': 'SA',
    'cell_id_list': [141],
    'cell_pci': 415,
    'arfcn': 633408,
    'scs': 30,  # optional, only Receiver 28A used
    'dl_iperf_process': 5,
    'ul_iperf_process': 5,
    'ue_ul_layer': 2    # now all ue ue_ul_layer should be same
}

ue_mapping_2 = {
    'ue_index': 1,  # ue index in Testline configruation file
    'network_type': 'SA',
    'cell_id_list': [142],
    'cell_pci': 416,
    'arfcn': 646656,
    'scs': 30,  # optional, only Receiver 28A used
    'dl_iperf_process': 5,
    'ul_iperf_process': 5,
    'ue_ul_layer': 2    # now all ue ue_ul_layer should be same
}

ue_mapping_3 = {
    'ue_index': 0,  # ue index in Testline configruation file
    'network_type': 'SA',
    'cell_id_list': [142],
    'cell_pci': 416,
    'arfcn': 646656,
    'scs': 30,  # optional, only Receiver 28A used
    'dl_iperf_process': 5,
    'ul_iperf_process': 5,
    'ue_ul_layer': 2    # now all ue ue_ul_layer should be same
}

mcs_mapping_1 = {
    'mcs_file_name': 'MCS_DEFAULT.csv',
    'set_type': 'angles_setting',
    'matrix_id': 1,
    'output_group_id_list': list(range(1, 9)),
    'input_group_id_list': list(range(1, 17)),
    'horizontal_distance': 0.5,
    'vertical_distance': 4.04,
}

mappings = [
    {
        'scf_name': 'SCF_SBTS*_1S-2CC-8D-8U-MU-MIMO.xml',  # * means all scf common, to adpta all branchs
        'ue_mapping_list': [ue_mapping_2, ue_mapping_3],
        'mcs_mapping': mcs_mapping_1,
    },
    {
        'scf_name': 'SCF_SBTS*_1S-2CC-8D-8U-CA.xml',  # * means all scf common, CA only need 1 UE
        'ue_mapping_list': [ue_mapping_1],
        'mcs_mapping': mcs_mapping_1,
    },
    {
        'scf_name': 'SCF_SBTS*-72E.xml',  # * means all scf common, CA only need 1 UE
        'ue_mapping_list': [ue_mapping_1, ue_mapping_3],
        'mcs_mapping': mcs_mapping_1,
    },
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_3],
        'mcs_mapping': mcs_mapping_1,
    }
]
