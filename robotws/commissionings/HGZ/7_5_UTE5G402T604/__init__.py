__maintainer__ = "Shi Zhihao"
__team__ = "5G_PZ_HZ_4_SG"
__email__ = "zhihao.shi@nokia-sbell.com"

__all__ = ["mappings"]


ue_mapping_1 = {
    "mobile_network_system": "NR",
    "ue_index": 0,  # ue index in TL
    "network_type": "SA",
    "cell_id_list": [5],
    "ul_iperf_process": 5,
}

ue_mapping_3 = {
    "mobile_network_system": "NR",
    "ue_index": 1,  # ue index in TL
    "network_type": "SA",
    "cell_id_list": [7],
    "ul_iperf_process": 5,
}

ue_mapping_2 = {
    "mobile_network_system": "LTE",
    "ue_index": 0,  # ue index in TL
    "cell_id_list": [2],
    "cell_pci": 63,
}

mappings = [
    {
        "scf_name": "SCF_SBTS*_1S-1CC-4D-4U_80M.xml",
        "ue_mapping_list": [ue_mapping_3],
    },
    {
        "scf_name": "*",
        "ue_mapping_list": [ue_mapping_1],
    },
]
