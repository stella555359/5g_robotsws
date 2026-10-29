"""
:author: Anna Bien
:maintainer: Anna Bien
:owner_email: anna.bien@nokia.com
:team: I_5G_SW_MMW_PLKRK_04
:email: I_5G_SW_MMW_PLKRK_04@nokia.com
:description: Global values with requirements from test scenarios
              UE_CFG - variables used to configure UEs in wts.cfg and to perform actions in WTS simulator
"""

A_A1_01_UE_CFG = (
    {'ue_id': 1, 'cell_id': 11, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 2, 'cell_id': 11, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 3, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 4, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 80},
    {'ue_id': 5, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 6, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 7, 'cell_id': 13, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 8, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 80},
    {'ue_id': 11, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 12, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 80},
    {'ue_id': 13, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 80},
)

A_A1_01_UE_TO_DELETE_CFG = range(31, 39)

A_A1_02_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 2, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 750},
    {'ue_id': 3, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 750},
    {'ue_id': 4, 'cell_id': 6, 'enb_id': 3, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 300},
    {'ue_id': 5, 'cell_id': 8, 'enb_id': 3, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 750},
    {'ue_id': 6, 'cell_id': 6, 'enb_id': 3, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 100},
    {'ue_id': 11, 'cell_id': 8, 'enb_id': 3, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 750},
    {'ue_id': 12, 'cell_id': 7, 'enb_id': 3, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 100},
)

A_A1_03_CELL2_UE_CFG = (
    {'ue_id': 1, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 2, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 3, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 5, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 9, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 10, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100}
)

A_A1_03_CELL1_UE_CFG = (
    {'ue_id': 4, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 100},
    {'ue_id': 6, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 100},
    {'ue_id': 7, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 8, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100}
)

A_A1_03_UE_CFG = (*A_A1_03_CELL2_UE_CFG, *A_A1_03_CELL1_UE_CFG)

A_A1_04_UE_CFG = (
    {'ue_id': 8, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 7, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 100},
    {'ue_id': 6, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 4, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 3, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 2, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 1, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 9, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 10, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 5, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 100},
)

A_B103_01_UE_CFG = (
    {'ue_id': 21, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 75, 'dl_mbps': 750},
    {'ue_id': 151, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 25, 'dl_mbps': 200},
    {'ue_id': 71, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 25, 'dl_mbps': 50}
)

A_B104_01_UE_CFG = (
    {'ue_id': 1, 'cell_id': 11, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 2, 'cell_id': 11, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 3, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 4, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 80},
    {'ue_id': 5, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 6, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 7, 'cell_id': 13, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 8, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 80},
    {'ue_id': 11, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 80},
    {'ue_id': 12, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 80},
    {'ue_id': 13, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 80},
)

A_B104_01_UE_TO_DELETE_CFG = range(31, 39)

A_B104_02_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 50},
    {'ue_id': 2, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 750},
    {'ue_id': 3, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 750},
    {'ue_id': 4, 'cell_id': 6, 'enb_id': 3, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 300},
    {'ue_id': 5, 'cell_id': 8, 'enb_id': 3, 'net_arch': 'sa', 'ul_mbps': 100, 'dl_mbps': 750},
    {'ue_id': 6, 'cell_id': 6, 'enb_id': 3, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 50},
    {'ue_id': 11, 'cell_id': 8, 'enb_id': 3, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 750},
    {'ue_id': 12, 'cell_id': 7, 'enb_id': 3, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 50},
)

A_B104_03_CELL2_UE_CFG = (
    {'ue_id': 1, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 2, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 3, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 5, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 9, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 10, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100}
)

A_B104_03_CELL1_UE_CFG = (
    {'ue_id': 4, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 100},
    {'ue_id': 6, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 100},
    {'ue_id': 7, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 8, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100}
)

A_B104_03_UE_CFG = (*A_B104_03_CELL2_UE_CFG, *A_B104_03_CELL1_UE_CFG)

A_B104_04_UE_CFG = (
    {'ue_id': 8, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 7, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 100},
    {'ue_id': 6, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 4, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 3, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 2, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 1, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 9, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 10, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 5, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 100},
)

A_B201_01_UE_CFG_1 = (
    {'ue_id': 1, 'pdu': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 60, 'dl_mbps': 60},
    {'ue_id': 2, 'pdu': 1, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 60, 'dl_mbps': 525},
)

A_B201_01_UE_CFG_PDU_MODIFICATION_01 = (
    {'pdu': 1, 'ue': 1, 'qosflows_to_add': 2, 'by': 'amf'},
    {'pdu': 1, 'ue': 1, 'qosflows_to_add': 3, 'by': 'amf'},
    {'pdu': 1, 'ue': 2, 'qosflows_to_add': 2, 'by': 'amf'},
    {'pdu': 1, 'ue': 2, 'qosflows_to_add': 3, 'by': 'amf'}
)

A_B201_01_UE_CFG_2 = (
    {'ue_id': 9, 'pdu': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 60, 'dl_mbps': 225},
    {'ue_id': 10, 'pdu': 1, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 60, 'dl_mbps': 60},
)

A_B201_01_UE_CFG_TRAFFIC_1 = (
    {'ue_id': 1, 'qfi': 1, 'throughput': 20, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 1, 'qfi': 2, 'throughput': 20, 'pdu': 1, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 1, 'qfi': 3, 'throughput': 20, 'pdu': 1, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 1, 'qfi': 1, 'throughput': 20, 'pdu': 1, 'trf_id': 4, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 1, 'qfi': 2, 'throughput': 20, 'pdu': 1, 'trf_id': 5, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 1, 'qfi': 3, 'throughput': 20, 'pdu': 1, 'trf_id': 6, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 1, 'throughput': 150, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 2, 'throughput': 150, 'pdu': 1, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 3, 'throughput': 150, 'pdu': 1, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 1, 'throughput': 75, 'pdu': 1, 'trf_id': 4, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 1, 'throughput': 20, 'pdu': 1, 'trf_id': 4, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 2, 'throughput': 20, 'pdu': 1, 'trf_id': 5, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 3, 'throughput': 20, 'pdu': 1, 'trf_id': 6, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'}
)

A_B201_01_UE_CFG_TRAFFIC_2 = (
    {'ue_id': 9, 'qfi': 1, 'throughput': 75, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 9, 'qfi': 2, 'throughput': 75, 'pdu': 1, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 9, 'qfi': 3, 'throughput': 75, 'pdu': 1, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 9, 'qfi': 1, 'throughput': 20, 'pdu': 1, 'trf_id': 4, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 9, 'qfi': 2, 'throughput': 20, 'pdu': 1, 'trf_id': 5, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 9, 'qfi': 3, 'throughput': 20, 'pdu': 1, 'trf_id': 6, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 10, 'qfi': 1, 'throughput': 20, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 10, 'qfi': 2, 'throughput': 20, 'pdu': 1, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 10, 'qfi': 3, 'throughput': 20, 'pdu': 1, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 10, 'qfi': 1, 'throughput': 20, 'pdu': 1, 'trf_id': 4, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 10, 'qfi': 2, 'throughput': 20, 'pdu': 1, 'trf_id': 5, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 10, 'qfi': 3, 'throughput': 20, 'pdu': 1, 'trf_id': 6, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'}
)

A_B201_01_UE_CFG_PDU_MODIFICATION_02 = (
    {'pdu': 1, 'ue': 9, 'qosflows_to_add': 2, 'by': 'amf'},
    {'pdu': 1, 'ue': 9, 'qosflows_to_add': 3, 'by': 'amf'},
    {'pdu': 1, 'ue': 10, 'qosflows_to_add': 2, 'by': 'amf'},
    {'pdu': 1, 'ue': 10, 'qosflows_to_add': 3, 'by': 'amf'}
)

A_B201_01_UE_CFG = (*A_B201_01_UE_CFG_1, *A_B201_01_UE_CFG_2)

A_B201_01_QOS_FLOW_CONFIGURATION = [
    {'id': 2, '5qi': 7},
    {'id': 3, '5qi': 8},
]

A_B202_01_UE_CFG = (
    {'ue_id': 21, 'cell_id': 2, 'enb_id': 2, 'pdu': 1, 'net_arch': 'sa'},
    {'ue_id': 22, 'cell_id': 2, 'enb_id': 2, 'pdu': 2, 'net_arch': 'sa'},
    {'ue_id': 151, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'nsa'},
)

A_B202_01_UE_CFG_PDU_MODIFICATION = (
    {'pdu': 1, 'ue': 21, 'qosflows_to_add': 4, 'by': 'amf'},
    {'pdu': 2, 'ue': 22, 'qosflows_to_add': 4, 'by': 'amf'},
    {'pdu': 2, 'ue': 22, 'qosflows_to_add': 5, 'by': 'amf'},
)

A_B202_01_UE_CFG_TRAFFIC = (
    {'ue_id': 21, 'qfi': 1, 'throughput': 50, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 21, 'qfi': 2, 'throughput': 50, 'pdu': 1, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 21, 'qfi': 2, 'throughput': 100, 'pdu': 1, 'trf_id': 3, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 22, 'qfi': 1, 'throughput': 50, 'pdu': 2, 'trf_id': 4, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 22, 'qfi': 2, 'throughput': 50, 'pdu': 2, 'trf_id': 5, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 22, 'qfi': 3, 'throughput': 50, 'pdu': 2, 'trf_id': 6, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 22, 'qfi': 3, 'throughput': 50, 'pdu': 2, 'trf_id': 7, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 151, 'bearer': 3, 'throughput': 50, 'trf_id': 8, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'nsa'},
    {'ue_id': 151, 'bearer': 3, 'throughput': 50, 'trf_id': 9, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'nsa'},
)

A_B202_01_QOS_FLOW_CONFIGURATION = [
    {'id': 4, '5qi': 7},
    {'id': 5, '5qi': 8},
]

A_B202_01_BEARER_CONFIGURATION = [
    {'id': 3, 'ue': 151, 'qci': 8, 'pdn': 1, 'default': 'on'},
]

A_B202_02_QOS_FLOW_CONFIGURATION = [
    {'id': 2, '5qi': 7},
    {'id': 3, '5qi': 8},
    {'id': 4, '5qi': 9},
]

A_B202_02_UE_CFG = (
    {'ue_id': 3, 'cell_id': 4, 'enb_id': 2, 'pdu': 1, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 5, 'cell_id': 8, 'enb_id': 3, 'pdu': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 9, 'cell_id': 2, 'enb_id': 2, 'pdu': 3, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'pdu': 4, 'net_arch': 'sa', 'ul_mbps': 0, 'dl_mbps': 0},
    {'ue_id': 2, 'cell_id': 2, 'enb_id': 2, 'pdu': 5, 'net_arch': 'sa', 'ul_mbps': 0, 'dl_mbps': 0},
)

A_B202_03_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'pdu': 1, 'net_arch': 'sa'},
    {'ue_id': 23, 'cell_id': 2, 'enb_id': 2, 'pdu': 2, 'net_arch': 'sa'},
    {'ue_id': 24, 'cell_id': 2, 'enb_id': 2, 'pdu': 3, 'net_arch': 'sa'},
    {'ue_id': 51, 'cell_id': 3, 'enb_id': 2, 'pdu': 4, 'net_arch': 'sa'},
)

A_B_202_02_UE_CFG_PDU_MODIFICATION_1 = (
    {'pdu': 1, 'ue': 3, 'qosflows_to_add': 4, 'by': 'amf'},
    {'pdu': 2, 'ue': 5, 'qosflows_to_add': 2, 'by': 'amf'},
    {'pdu': 3, 'ue': 9, 'qosflows_to_add': 2, 'by': 'amf'}
)

A_B_202_02_UE_CFG_PDU_MODIFICATION_2 = (
    {'pdu': 4, 'ue': 1, 'qosflows_to_add': 2, 'by': 'amf'},
    {'pdu': 5, 'ue': 2, 'qosflows_to_add': 2, 'by': 'amf'},
    {'pdu': 5, 'ue': 2, 'qosflows_to_add': 3, 'by': 'amf'}
)

A_B202_02_UE_CFG_TRAFFIC_1 = (
    {'ue_id': 3, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 2, 'throughput': 175, 'pdu': 1, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 2, 'throughput': 175, 'pdu': 1, 'trf_id': 4, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 5, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 5, 'qfi': 1, 'throughput': 175, 'pdu': 2, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 5, 'qfi': 1, 'throughput': 175, 'pdu': 2, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 5, 'qfi': 2, 'throughput': 175, 'pdu': 2, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 5, 'qfi': 2, 'throughput': 175, 'pdu': 2, 'trf_id': 4, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 5, 'qfi': 1, 'throughput': 175, 'pdu': 2, 'trf_id': 5, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 9, 'qfi': 1, 'throughput': 175, 'pdu': 3, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 9, 'qfi': 1, 'throughput': 175, 'pdu': 3, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 9, 'qfi': 2, 'throughput': 175, 'pdu': 3, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 9, 'qfi': 2, 'throughput': 175, 'pdu': 3, 'trf_id': 4, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 9, 'qfi': 1, 'throughput': 175, 'pdu': 3, 'trf_id': 5, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
)

A_B202_02_UE_CFG_TRAFFIC_2 = (
    {'ue_id': 1, 'qfi': 1, 'throughput': 50, 'pdu': 4, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 1, 'qfi': 2, 'throughput': 50, 'pdu': 4, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 1, 'qfi': 1, 'throughput': 100, 'pdu': 4, 'trf_id': 3, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 2, 'throughput': 50, 'pdu': 5, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 3, 'throughput': 50, 'pdu': 5, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 2, 'throughput': 100, 'pdu': 5, 'trf_id': 3, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
)

A_B202_03_UE_CFG_PDU_MODIFICATION = (
    {'pdu': 2, 'ue': 23, 'qosflows_to_add': 5, 'by': 'amf'},
    {'pdu': 3, 'ue': 24, 'qosflows_to_add': 4, 'by': 'amf'},
    {'pdu': 4, 'ue': 51, 'qosflows_to_add': 4, 'by': 'amf'},
)

A_B202_03_UE_CFG_TRAFFIC = (
    {'ue_id': 23, 'qfi': 1, 'throughput': 50, 'pdu': 2, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 23, 'qfi': 2, 'throughput': 50, 'pdu': 2, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 23, 'qfi': 1, 'throughput': 50, 'pdu': 2, 'trf_id': 3, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 23, 'qfi': 2, 'throughput': 50, 'pdu': 2, 'trf_id': 4, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 24, 'qfi': 1, 'throughput': 50, 'pdu': 3, 'trf_id': 5, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 24, 'qfi': 2, 'throughput': 50, 'pdu': 3, 'trf_id': 6, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 24, 'qfi': 1, 'throughput': 50, 'pdu': 3, 'trf_id': 7, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 24, 'qfi': 2, 'throughput': 50, 'pdu': 3, 'trf_id': 8, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 1, 'qfi': 1, 'throughput': 50, 'pdu': 1, 'trf_id': 9, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 1, 'qfi': 1, 'throughput': 50, 'pdu': 1, 'trf_id': 10, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 51, 'qfi': 1, 'throughput': 50, 'pdu': 4, 'trf_id': 11, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 51, 'qfi': 2, 'throughput': 50, 'pdu': 4, 'trf_id': 12, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 51, 'qfi': 1, 'throughput': 50, 'pdu': 4, 'trf_id': 13, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 51, 'qfi': 2, 'throughput': 50, 'pdu': 4, 'trf_id': 14, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
)

A_B202_03_QOS_FLOW_CONFIGURATION = [
    {'id': 4, '5qi': 7},
    {'id': 5, '5qi': 8},
]

B_B101_01_UE_CFG = (
    {'ue_id': 4, 'cell_id': 2, 'enb_id': 2, 'pdu': 1, 'net_arch': 'sa'},
    {'ue_id': 10, 'cell_id': 2, 'enb_id': 2, 'pdu': 2, 'net_arch': 'sa'},
)

B_B101_01_UE_CFG_PDU_MODIFICATION = (
    {'pdu': 1, 'ue': 4, 'qosflows_to_add': 2, 'by': 'amf'},
    {'pdu': 2, 'ue': 10, 'qosflows_to_add': 4, 'by': 'amf'},
)

B_B101_01_UE_CFG_TRAFFIC = (
    {'ue_id': 4, 'qfi': 2, 'throughput': 80, 'pdu': 1, 'trf_id': 1, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 4, 'qfi': 2, 'throughput': 100, 'pdu': 1, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 10, 'qfi': 2, 'throughput': 80, 'pdu': 2, 'trf_id': 1, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
    {'ue_id': 10, 'qfi': 2, 'throughput': 100, 'pdu': 2, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa'},
)

B_B102_01_UE_CFG = (
    {'ue_id': 21, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 350},
    {'ue_id': 151, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 200},
    {'ue_id': 152, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 22, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
)

B_B102_02_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 2, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 11, 'cell_id': 8, 'enb_id': 3, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
)

B_B103_01_UE_CFG = (
    {'ue_id': 11, 'bearer': 2, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 12, 'bearer': 2, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 13, 'bearer': 2, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
)

B_B103_01_BEARER_QCI_CONFIGURATION = [
    {'id': 2, 'ue': 11, 'old_qci': 9, 'new_qci': 8},
]

B_B301_02_BEARER_QCI_CONFIGURATION = [
    {'id': 2, 'ue': 11, 'old_qci': 9, 'new_qci': 8},
]

B_B201_01_UE_CFG_1 = (
    {'ue_id': 11, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
)

B_B201_01_UE_CFG_2 = (
    {'ue_id': 11, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 100},
)

B_B301_01_UE_CFG_1 = (
    {'ue_id': 1, 'cell_id': 2, 'enb_id': 2, 'pdu': 1, 'net_arch': 'sa'},
    {'ue_id': 2, 'cell_id': 2, 'enb_id': 2, 'pdu': 2, 'net_arch': 'sa'},
    {'ue_id': 3, 'cell_id': 2, 'enb_id': 2, 'pdu': 3, 'net_arch': 'sa'},
    {'ue_id': 4, 'cell_id': 2, 'enb_id': 2, 'pdu': 4, 'net_arch': 'sa'},
    {'ue_id': 5, 'cell_id': 2, 'enb_id': 2, 'pdu': 5, 'net_arch': 'sa'},
    {'ue_id': 6, 'cell_id': 2, 'enb_id': 2, 'pdu': 6, 'net_arch': 'sa'}
)

B_B301_01_UE_CFG_2 = (
    {'ue_id': 7, 'cell_id': 1, 'enb_id': 2, 'pdu': 7, 'net_arch': 'sa'},
    {'ue_id': 8, 'cell_id': 1, 'enb_id': 2, 'pdu': 8, 'net_arch': 'sa'},
    {'ue_id': 9, 'cell_id': 1, 'enb_id': 2, 'pdu': 9, 'net_arch': 'sa'},
    {'ue_id': 10, 'cell_id': 1, 'enb_id': 2, 'pdu': 10, 'net_arch': 'sa'}
)

B_B301_01_UE_CFG = (*B_B301_01_UE_CFG_1, *B_B301_01_UE_CFG_2)

B_B301_01_UE_CFG_PDU_MODIFICATION_1 = (
    {'pdu': 2, 'ue': 2, 'qosflows_to_add': 4, 'by': 'amf'},
    {'pdu': 3, 'ue': 3, 'qosflows_to_add': 5, 'by': 'amf'},
    {'pdu': 4, 'ue': 4, 'qosflows_to_add': 6, 'by': 'amf'},
    {'pdu': 5, 'ue': 5, 'qosflows_to_add': 7, 'by': 'amf'},
    {'pdu': 6, 'ue': 6, 'qosflows_to_add': 8, 'by': 'amf'},
)

B_B301_01_UE_CFG_PDU_MODIFICATION_2 = (
    {'pdu': 8, 'ue': 8, 'qosflows_to_add': 4, 'by': 'amf'},
    {'pdu': 9, 'ue': 9, 'qosflows_to_add': 5, 'by': 'amf'},
    {'pdu': 10, 'ue': 10, 'qosflows_to_add': 6, 'by': 'amf'}
)

B_B301_01_UE_CFG_TRAFFIC_1 = (
    {'ue_id': 1, 'qfi': 1, 'throughput': 100, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 1, 'qfi': 1, 'throughput': 50, 'pdu': 1, 'trf_id': 2, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 2, 'qfi': 2, 'throughput': 100, 'pdu': 2, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 2, 'qfi': 2, 'throughput': 50, 'pdu': 2, 'trf_id': 4, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 3, 'qfi': 2, 'throughput': 100, 'pdu': 3, 'trf_id': 5, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 3, 'qfi': 2, 'throughput': 50, 'pdu': 3, 'trf_id': 6, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 4, 'qfi': 2, 'throughput': 100, 'pdu': 4, 'trf_id': 7, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 4, 'qfi': 2, 'throughput': 100, 'pdu': 4, 'trf_id': 8, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
)

B_B301_01_UE_CFG_TRAFFIC_2 = (
    {'ue_id': 7, 'qfi': 1, 'throughput': 100, 'pdu': 7, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 7, 'qfi': 1, 'throughput': 50, 'pdu': 7, 'trf_id': 2, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 8, 'qfi': 2, 'throughput': 100, 'pdu': 8, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 8, 'qfi': 2, 'throughput': 50, 'pdu': 8, 'trf_id': 4, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}}
)

B_B301_01_QOS_FLOW_CONFIGURATION = [
    {'id': 4, '5qi': 7},
    {'id': 5, '5qi': 8},
    {'id': 6, '5qi': 9},
    {'id': 7, '5qi': 80},
    {'id': 8, '5qi': 129},
]

B_B301_02_UE_CFG = (
    {'ue_id': 11, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'burst': {'period_ms': 10, 'burst': 3, 'size': 3000}},
    {'ue_id': 12, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'burst': {'period_ms': 10, 'burst': 3, 'size': 3000}}
)

B_B301_03_UE_CFG_1 = (
    {'ue_id': 1, 'cell_id': 11, 'enb_id': 2, 'net_arch': 'sa', 'pdu': 1},
    {'ue_id': 2, 'cell_id': 11, 'enb_id': 2, 'net_arch': 'sa', 'pdu': 2},
    {'ue_id': 3, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'sa', 'pdu': 3},
    {'ue_id': 4, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'sa', 'pdu': 4},
)

B_B301_03_UE_CFG_2 = (
    {'ue_id': 5, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'pdu': 5},
    {'ue_id': 6, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'pdu': 6},
    {'ue_id': 7, 'cell_id': 13, 'enb_id': 2, 'net_arch': 'sa', 'pdu': 7},
    {'ue_id': 8, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'pdu': 8},
)

B_B301_03_UE_CFG_3 = (
    {'ue_id': 11, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'nsa', 'pdu': 11},
    {'ue_id': 12, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'pdu': 12},
    {'ue_id': 13, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'nsa', 'pdu': 13},
)

B_B301_03_UE_CFG = (*B_B301_03_UE_CFG_1, *B_B301_03_UE_CFG_2, *B_B301_03_UE_CFG_3)

B_B301_03_UE_CFG_PDU_MODIFICATION_1 = (
    {'pdu': 2, 'ue': 2, 'qosflows_to_add': 4, 'by': 'amf'},
    {'pdu': 3, 'ue': 3, 'qosflows_to_add': 5, 'by': 'amf'},
    {'pdu': 4, 'ue': 4, 'qosflows_to_add': 6, 'by': 'amf'},
)

B_B301_03_UE_CFG_PDU_MODIFICATION_2 = (
    {'pdu': 6, 'ue': 6, 'qosflows_to_add': 4, 'by': 'amf'},
    {'pdu': 7, 'ue': 7, 'qosflows_to_add': 5, 'by': 'amf'},
    {'pdu': 8, 'ue': 8, 'qosflows_to_add': 6, 'by': 'amf'},
)

B_B301_03_UE_CFG_PDU_MODIFICATION_3 = (
    {'pdu': 12, 'ue': 12, 'qosflows_to_add': 6, 'by': 'amf'},
    {'pdu': 13, 'ue': 13, 'qosflows_to_add': 7, 'by': 'amf'}
)

B_B301_03_UE_CFG_TRAFFIC_1 = (
    {'ue_id': 1, 'qfi': 1, 'throughput': 100, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 1, 'qfi': 1, 'throughput': 50, 'pdu': 1, 'trf_id': 2, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 2, 'qfi': 2, 'throughput': 100, 'pdu': 2, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 2, 'qfi': 2, 'throughput': 50, 'pdu': 2, 'trf_id': 4, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 3, 'qfi': 2, 'throughput': 100, 'pdu': 3, 'trf_id': 5, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 3, 'qfi': 2, 'throughput': 50, 'pdu': 3, 'trf_id': 6, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 4, 'qfi': 2, 'throughput': 100, 'pdu': 4, 'trf_id': 7, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 4, 'qfi': 2, 'throughput': 100, 'pdu': 4, 'trf_id': 8, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}}
)

B_B301_03_UE_CFG_TRAFFIC_2 = (
    {'ue_id': 5, 'qfi': 1, 'throughput': 50, 'pdu': 5, 'trf_id': 9, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 5, 'qfi': 1, 'throughput': 100, 'pdu': 5, 'trf_id': 10, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 6, 'qfi': 2, 'throughput': 50, 'pdu': 6, 'trf_id': 11, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 6, 'qfi': 2, 'throughput': 100, 'pdu': 6, 'trf_id': 12, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 7, 'qfi': 2, 'throughput': 100, 'pdu': 7, 'trf_id': 13, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 7, 'qfi': 2, 'throughput': 50, 'pdu': 7, 'trf_id': 14, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 8, 'qfi': 2, 'throughput': 100, 'pdu': 8, 'trf_id': 15, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 8, 'qfi': 2, 'throughput': 50, 'pdu': 8, 'trf_id': 16, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
)

B_B301_03_UE_CFG_TRAFFIC_3 = (
    {'ue_id': 11, 'bearer': 2, 'throughput': 100, 'trf_id': 17, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'nsa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 12, 'bearer': 2, 'throughput': 100, 'trf_id': 18, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'nsa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 13, 'bearer': 2, 'throughput': 100, 'trf_id': 19, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'nsa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
)

B_B301_03_QOS_FLOW_CONFIGURATION = [
    {'id': 4, '5qi': 7},
    {'id': 5, '5qi': 8},
    {'id': 6, '5qi': 9},
    {'id': 7, '5qi': 80},
    {'id': 8, '5qi': 129},
]

B_B301_03_UE_TO_DELETE_CFG = range(31, 39)

B_B301_04_UE_CFG_1 = (
    {'ue_id': 11, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 12, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 13, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
)

B_B301_04_UE_CFG_2_burst = (
    {'ue_id': 14, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
)

B_B301_04_UE_CFG_3 = (
    {'ue_id': 15, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 16, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 17, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 18, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
    {'ue_id': 19, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
)
B_B301_04_UE_CFG_4_burst = (
    {'ue_id': 20, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 100},
)

C_B101_001_UE_CFG = (
    {'ue_id': 11, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 200},
)

C_B104_002_UE_CFG = (
    {'ue_id': 11, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 200},
)

C_B102_003_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 200},
)

C_B103_007_UE_CFG = (
    {'ue_id': 1, 'cell_id': 11, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 200, 'dl_mbps': 200},
)

C_B103_005_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 70},
    {'ue_id': 2, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 70},
    {'ue_id': 3, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 70},
)

C_B103_006_UE_CFG = (
    {'ue_id': 11, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 80, 'dl_mbps': 200},
)

C_B103_006_UE_CFG_TRAFFIC = (
    {'ue_id': 11, 'id': 1, 'throughput': 175, 'trf_id': 1, 'direction': 'dl', 'protocol': 'udp', 'duration': 15,
     'net_arch': 'nsa', 'bearer': 2},
    {'ue_id': 11, 'id': 1, 'throughput': 25, 'trf_id': 2, 'direction': 'dl', 'protocol': 'udp', 'duration': 15,
     'net_arch': 'nsa', 'bearer': 2},
    {'ue_id': 11, 'id': 1, 'throughput': 50, 'trf_id': 3, 'direction': 'ul', 'protocol': 'udp', 'duration': 15,
     'net_arch': 'nsa', 'bearer': 2}
)

C_B201_008_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 60, 'size': 9000}},
)

C_B201_009_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 80, 'dl_mbps': 200},
)

C_B201_010_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 60, 'size': 9000}},
)

C_B201_011_UE_CFG = (
    {'ue_id': 3, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 60, 'size': 9000}},
)

C_B202_012_UE_CFG = (
    {'ue_id': 11, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 12, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 13, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 70},
)

C_B202_013_UE_CFG = (
    {'ue_id': 11, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 150, 'dl_mbps': 1800},
)

C_B202_014_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'dl_mbps': 1000},
)

C_B202_015_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
)

C_B301_015_UE_CFG = [
    {'ue_id': 21, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 30, 'size': 9000}}
]

C_6CC_017_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
)

C_6CC_018_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
)

C_6CC_019_UE_CFG = (
    {'ue_id': 1, 'cell_id': 11, 'enb_id': 2, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 800},
)

C_6CC_020_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 3000},
)

C_6CC_021_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
)

C_6CC_022_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 1200},
)

C_6CC_016_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 400},
)

C_6CC_023_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
)

D_B101_01_UE_CFG = (
    {'ue_id': 1, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 11, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 2, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
)

D_B102_01_UE_CFG = (
    {'ue_id': 1, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 11, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 2, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
)

D_B103_01_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 11, 'cell_id': 4, 'enb_id': 3, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 2, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
)

D_B104_01_QOS_FLOW_CONFIGURATION = [
    {'id': 2, '5qi': 5},
    {'id': 3, '5qi': 1},
    {'id': 4, '5qi': 7},
    {'id': 5, '5qi': 8},
    {'id': 6, '5qi': 9},
    {'id': 7, '5qi': 80},
    {'id': 8, '5qi': 129},
]

D_B104_01_QOS_RULES_CONFIGURATION = [
    {'id': 1, 'proto': 'tcp', 'qos_flow': 2},
    {'id': 2, 'proto': 'udp', 'qos_flow': 3},
    {'id': 3, 'proto': 'udp', 'qos_flow': 4},
    {'id': 4, 'proto': 'udp', 'qos_flow': 5},
    {'id': 5, 'proto': 'udp', 'qos_flow': 6},
    {'id': 6, 'proto': 'udp', 'qos_flow': 7},
    {'id': 7, 'proto': 'udp', 'qos_flow': 8},
]

D_B104_01_UE_CFG_PDU_MODIFICATION_01 = (
    {'pdu': 1, 'ue': 2, 'qosflows_to_add': 4, 'by': 'amf'},
    {'pdu': 1, 'ue': 3, 'qosflows_to_add': 5, 'by': 'amf'},
    {'pdu': 1, 'ue': 4, 'qosflows_to_add': 6, 'by': 'amf'},
    {'pdu': 1, 'ue': 5, 'qosflows_to_add': 7, 'by': 'amf'},
    {'pdu': 1, 'ue': 6, 'qosflows_to_add': 8, 'by': 'amf'}
)

D_B104_01_UE_CFG = (
    {'ue_id': 1, 'pdu': 1, 'cell_id': 11, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 400},
    {'ue_id': 2, 'pdu': 1, 'cell_id': 11, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 400},
    {'ue_id': 3, 'pdu': 1, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 400},
    {'ue_id': 4, 'pdu': 1, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 400},
    {'ue_id': 5, 'pdu': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 400},
    {'ue_id': 6, 'pdu': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 400},
    {'ue_id': 7, 'pdu': 1, 'cell_id': 13, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 400},
    {'ue_id': 8, 'pdu': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 400},
    {'ue_id': 31, 'bearer': 2, 'cell_id': 12, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 400},
    {'ue_id': 32, 'bearer': 2, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 400},
    {'ue_id': 33, 'bearer': 2, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 400},
)

D_B104_01_UE_CFG_TRAFFIC = (
    {'ue_id': 1, 'qfi': 1, 'throughput': 150, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 2, 'throughput': 150, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 2, 'throughput': 150, 'pdu': 1, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 4, 'qfi': 2, 'throughput': 150, 'pdu': 1, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 5, 'qfi': 2, 'throughput': 150, 'pdu': 1, 'trf_id': 4, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 6, 'qfi': 2, 'throughput': 150, 'pdu': 1, 'trf_id': 4, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 7, 'qfi': 1, 'throughput': 150, 'pdu': 1, 'trf_id': 5, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 8, 'qfi': 1, 'throughput': 150, 'pdu': 1, 'trf_id': 6, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 31, 'bearer': 2, 'throughput': 50, 'trf_id': 8, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'nsa'},
    {'ue_id': 32, 'bearer': 2, 'throughput': 50, 'trf_id': 9, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'nsa'},
    {'ue_id': 33, 'bearer': 2, 'throughput': 50, 'trf_id': 9, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'nsa'}
)

D_B104_01_BEARER_CONFIGURATION = [
    {'id': 2, 'ue': 31, 'qci': 8, 'pdn': 1, 'default': 'on'},
    {'id': 2, 'ue': 32, 'qci': 9, 'pdn': 1, 'default': 'on'},
    {'id': 3, 'ue': 32, 'qci': 7, 'pdn': 1, 'default': 'off'},
    {'id': 2, 'ue': 33, 'qci': 9, 'pdn': 1, 'default': 'on'},
    {'id': 3, 'ue': 33, 'qci': 6, 'pdn': 1, 'default': 'off'},
]

D_B104_02_BEARER_QCI_CONFIGURATION = [
    {'id': 2, 'ue': 11, 'old_qci': 9, 'new_qci': 8},
]

D_B104_02_UE_CELL_ALIGNMENT = [
    {'id': 2, 'old_cell': 2, 'new_cell': 3},
    {'id': 3, 'old_cell': 3, 'new_cell': 4},
    {'id': 4, 'old_cell': 4, 'new_cell': 6},
    {'id': 5, 'old_cell': 5, 'new_cell': 8},
]

D_B104_02_UE_GNB_ALIGNMENT = [
    {'id': 4, 'old_gnb': 2, 'new_gnb': 3},
]

D_B104_02_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'pdu': 1, 'net_arch': 'sa'},
    {'ue_id': 2, 'cell_id': 3, 'enb_id': 2, 'pdu': 2, 'net_arch': 'sa'},
    {'ue_id': 3, 'cell_id': 4, 'enb_id': 2, 'pdu': 3, 'net_arch': 'sa'},
    {'ue_id': 4, 'cell_id': 6, 'enb_id': 3, 'pdu': 4, 'net_arch': 'sa'},
    {'ue_id': 5, 'cell_id': 8, 'enb_id': 3, 'pdu': 5, 'net_arch': 'sa'},
    {'ue_id': 6, 'cell_id': 6, 'enb_id': 3, 'pdu': 6, 'net_arch': 'sa'},
    {'ue_id': 11, 'cell_id': 8, 'enb_id': 3, 'net_arch': 'nsa'},
    {'ue_id': 12, 'cell_id': 7, 'enb_id': 3, 'net_arch': 'nsa'},
)

D_B104_02_UE_CFG_PDU_MODIFICATION = (
    {'pdu': 2, 'ue': 2, 'qosflows_to_add': 4, 'by': 'amf'},
    {'pdu': 3, 'ue': 3, 'qosflows_to_add': 5, 'by': 'amf'},
    {'pdu': 4, 'ue': 4, 'qosflows_to_add': 6, 'by': 'amf'},
    {'pdu': 5, 'ue': 5, 'qosflows_to_add': 7, 'by': 'amf'},
    {'pdu': 6, 'ue': 6, 'qosflows_to_add': 8, 'by': 'amf'},
)

D_B104_02_QOS_FLOW_CONFIGURATION = [
    {'id': 4, '5qi': 7},
    {'id': 5, '5qi': 8},
    {'id': 6, '5qi': 9},
    {'id': 7, '5qi': 80},
    {'id': 8, '5qi': 129},
]

D_B104_02_UE_CFG_TRAFFIC = (
    {'ue_id': 1, 'qfi': 1, 'throughput': 50, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 2, 'throughput': 175, 'pdu': 2, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 2, 'throughput': 175, 'pdu': 2, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 2, 'throughput': 175, 'pdu': 2, 'trf_id': 4, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 2, 'throughput': 175, 'pdu': 3, 'trf_id': 5, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 2, 'throughput': 175, 'pdu': 3, 'trf_id': 6, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 4, 'qfi': 2, 'throughput': 175, 'pdu': 4, 'trf_id': 7, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 4, 'qfi': 2, 'throughput': 175, 'pdu': 4, 'trf_id': 8, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 5, 'qfi': 2, 'throughput': 175, 'pdu': 5, 'trf_id': 9, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 5, 'qfi': 2, 'throughput': 175, 'pdu': 5, 'trf_id': 10, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 6, 'qfi': 2, 'throughput': 50, 'pdu': 6, 'trf_id': 11, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 11, 'bearer': 2, 'throughput': 175, 'trf_id': 12, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'nsa'},
    {'ue_id': 11, 'bearer': 2, 'throughput': 175, 'trf_id': 13, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'nsa'},
    {'ue_id': 12, 'bearer': 2, 'throughput': 175, 'trf_id': 14, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'nsa'},
)

D_B104_03_UE_CFG_PDU_MODIFICATION_01 = (
    {'pdu': 1, 'ue': 3, 'qosflows_to_add': 1, 'by': 'amf'},
    {'pdu': 1, 'ue': 4, 'qosflows_to_add': 2, 'by': 'amf'},
)

D_B104_03_UE_CFG = (
    {'ue_id': 4, 'pdu': 1, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 200, 'dl_mbps': 750},
    {'ue_id': 102, 'bearer': 2, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'nsa', 'ul_mbps': 200, 'dl_mbps': 750},
    {'ue_id': 3, 'pdu': 1, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 200, 'dl_mbps': 750},
)

D_B104_03_UE_CFG_TRAFFIC = (
    {'ue_id': 102, 'bearer': 2, 'throughput': 175, 'trf_id': 11, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'nsa'},
    {'ue_id': 102, 'bearer': 2, 'throughput': 175, 'trf_id': 12, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'nsa'},
    {'ue_id': 102, 'bearer': 2, 'throughput': 175, 'trf_id': 13, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'nsa'},
    {'ue_id': 102, 'bearer': 2, 'throughput': 175, 'trf_id': 14, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'nsa'},
    {'ue_id': 102, 'bearer': 2, 'throughput': 50, 'trf_id': 15, 'direction': 'ul', 'trf_dir': 'ul',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'nsa'},
    {'ue_id': 3, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 1, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 2, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 3, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 4, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 1, 'throughput': 50, 'pdu': 1, 'trf_id': 5, 'direction': 'ul', 'trf_dir': 'ul',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 4, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 6, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 4, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 7, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 4, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 8, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 4, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 9, 'direction': 'dl', 'trf_dir': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 4, 'qfi': 1, 'throughput': 50, 'pdu': 1, 'trf_id': 10, 'direction': 'ul', 'trf_dir': 'ul',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
)

D_B104_04_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'pdu': 1, 'net_arch': 'sa'},
    {'ue_id': 11, 'cell_id': 8, 'enb_id': 3, 'pdu': 11, 'net_arch': 'nsa'},
    {'ue_id': 9, 'cell_id': 2, 'enb_id': 2, 'pdu': 9, 'net_arch': 'sa'}
)


D_B104_04_UE_CFG_PDU_MODIFICATION = (
    {'pdu': 11, 'ue': 11, 'qosflows_to_add': 4, 'by': 'amf'},
    {'pdu': 9, 'ue': 9, 'qosflows_to_add': 5, 'by': 'amf'}
)

D_B104_04_UE_CFG_TRAFFIC = (
    {'ue_id': 1, 'qfi': 1, 'throughput': 100, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 1, 'qfi': 1, 'throughput': 50, 'pdu': 1, 'trf_id': 2, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 11, 'qfi': 2, 'throughput': 100, 'pdu': 11, 'trf_id': 3, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'nsa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 11, 'qfi': 2, 'throughput': 50, 'pdu': 11, 'trf_id': 4, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'nsa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 9, 'qfi': 2, 'throughput': 100, 'pdu': 9, 'trf_id': 5, 'direction': 'dl',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}},
    {'ue_id': 9, 'qfi': 2, 'throughput': 50, 'pdu': 9, 'trf_id': 6, 'direction': 'ul',
     'protocol': 'udp', 'duration': 5, 'net_arch': 'sa', 'burst': {'period_ms': 10, 'burst': 1, 'size': 9000}}
)

D_B104_04_QOS_FLOW_CONFIGURATION = [
    {'id': 4, '5qi': 7},
    {'id': 5, '5qi': 8}
]

D_B104_05_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 2, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 3, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 4, 'cell_id': 2, 'enb_id': 3, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 70},
    {'ue_id': 5, 'cell_id': 4, 'enb_id': 3, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 6, 'cell_id': 2, 'enb_id': 3, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 70},
    {'ue_id': 11, 'cell_id': 4, 'enb_id': 3, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 12, 'cell_id': 3, 'enb_id': 3, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 70},
)

E_B101_01_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 2, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 3, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 4, 'cell_id': 2, 'enb_id': 3, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 70},
    {'ue_id': 5, 'cell_id': 4, 'enb_id': 3, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 6, 'cell_id': 2, 'enb_id': 3, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 70},
    {'ue_id': 11, 'cell_id': 4, 'enb_id': 3, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 12, 'cell_id': 3, 'enb_id': 3, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 70},
)

E_B201_01_UE_CFG = (
    {'ue_id': 1, 'pdu': 1, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 200},
    {'ue_id': 2, 'pdu': 1, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 3, 'pdu': 1, 'cell_id': 5, 'enb_id': 3, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 4, 'pdu': 1, 'cell_id': 6, 'enb_id': 3, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 5, 'pdu': 1, 'cell_id': 2, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 150},
)

E_B201_01_QOS_FLOW_CONFIGURATION = [
    {'id': 2, '5qi': 5},
    {'id': 3, '5qi': 7},
    {'id': 4, '5qi': 8},
    {'id': 5, '5qi': 9},
 ]

E_B201_01_UE_CFG_PDU_MODIFICATION_01 = (
    {'pdu': 1, 'ue': 2, 'qosflows_to_add': 5, 'by': 'amf'},
    {'pdu': 1, 'ue': 3, 'qosflows_to_add': 2, 'by': 'amf'},
    {'pdu': 1, 'ue': 4, 'qosflows_to_add': 3, 'by': 'amf'},
    {'pdu': 1, 'ue': 5, 'qosflows_to_add': 4, 'by': 'amf'},
)

E_B201_01_UE_CFG_TRAFFIC = (
    {'ue_id': 1, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 2, 'qfi': 2, 'throughput': 70, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 3, 'qfi': 2, 'throughput': 70, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 4, 'qfi': 2, 'throughput': 70, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 5, 'qfi': 2, 'throughput': 150, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
)

E_B201_02_UE_CFG = (
    {'ue_id': 1, 'cell_id': 1, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 2, 'cell_id': 3, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 3, 'cell_id': 4, 'enb_id': 2, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 4, 'cell_id': 2, 'enb_id': 3, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 70},
    {'ue_id': 5, 'cell_id': 4, 'enb_id': 3, 'net_arch': 'sa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 6, 'cell_id': 2, 'enb_id': 3, 'net_arch': 'sa', 'trf_dir': 'dl', 'dl_mbps': 70},
    {'ue_id': 11, 'cell_id': 4, 'enb_id': 3, 'net_arch': 'nsa', 'ul_mbps': 20, 'dl_mbps': 70},
    {'ue_id': 12, 'cell_id': 3, 'enb_id': 3, 'net_arch': 'nsa', 'trf_dir': 'dl', 'dl_mbps': 70},
)

C_6CC_020_UE_CFG_TRAFFIC = (
    {'ue_id': 1, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 1, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 1, 'qfi': 1, 'throughput': 175, 'pdu': 1, 'trf_id': 2, 'direction': 'dl',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'},
    {'ue_id': 1, 'qfi': 1, 'throughput': 50, 'pdu': 1, 'trf_id': 3, 'direction': 'ul',
     'protocol': 'udp', 'duration': 15, 'net_arch': 'sa'}
)
