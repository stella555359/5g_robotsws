import os
from taf.rfrl.utilities.robot.general import get_builtin_value

tl = get_builtin_value(param_name="tl")

# General vars
ADMIN_ALIAS = 'default'
NOKIA_PASS = tl.gnbs[0].cu.oam_ssh_connection_details.password
NOKIA_LOGIN = tl.gnbs[0].cu.oam_ssh_connection_details.username
NOKIA_USERNAME = tl.gnbs[0].cu.oam_ssh_connection_details.username
GNB_IP = tl.gnbs[0].cu.backhaul_site_oam_ip
try:
    GNB2_IP = tl.gnbs[1].cu.backhaul_site_oam_ip
except IndexError:
    GNB2_IP = None
AP_IP = tl.ues[0].l1.common_units[0].lmp_connection.addr
AP_PASSWD = tl.ues[0].l1.common_units[0].lmp_connection.password
WEBEM_USERNAME = tl.gnbs[0].cu.oam_http_connection_details.username
WEBEM_PASSWORD = tl.gnbs[0].cu.oam_http_connection_details.password
TL_CLOUD_TOPOLOGY = tl.tl_cloud_topology

config_dir = os.path.join(os.path.dirname(__file__), 'configuration')

DELTA_A_A1_01 = os.path.join(config_dir, 'CB010636-A-A1_01_delta.json')
DELTA_A_A1_02_GNB1 = os.path.join(config_dir, 'CB010636-A-A1_02_gnb1_delta.json')
DELTA_A_A1_02_GNB2 = os.path.join(config_dir, 'CB010636-A-A1_02_gnb2_delta.json')
DELTA_A_A1_03 = os.path.join(config_dir, 'CB010636-A-A1_03_delta.json')
DELTA_A_A1_04 = os.path.join(config_dir, 'CB010636-A-A1_04_delta.json')
DELTA_A_B103_01 = os.path.join(config_dir, 'CB010636-A-B103_01_delta.json')
DELTA_A_B201_01_GNB1 = os.path.join(config_dir, 'CB010636-A-B201_01_gnb1_delta.json')
DELTA_A_B201_01_GNB2 = os.path.join(config_dir, 'CB010636-A-B201_01_gnb2_delta.json')
DELTA_A_B201_01_DRB_ONLINE = os.path.join(config_dir, 'CB010636-A-B201_01_online_change_delta.json')
DELTA_A_B202_01 = os.path.join(config_dir, 'CB010636-A-B202_01_delta.json')
DELTA_A_B202_02_GNB1 = os.path.join(config_dir, 'CB010636-A-B202_02_gnb1_delta.json')
DELTA_A_B202_02_GNB2 = os.path.join(config_dir, 'CB010636-A-B202_02_gnb2_delta.json')
DELTA_A_B202_02_ONLINE_CHANGE_GNB1 = os.path.join(config_dir, 'CB010636-A-B202_02_online_change_gnb1_delta.json')
DELTA_A_B202_02_ONLINE_CHANGE_GNB2 = os.path.join(config_dir, 'CB010636-A-B202_02_online_change_gnb2_delta.json')
DELTA_A_B202_03 = os.path.join(config_dir, 'CB010636-A-B202_03_delta.json')
DELTA_B_B101_01 = os.path.join(config_dir, 'CB010636-B-B101_01_delta.json')
DELTA_B_B101_01_01 = os.path.join(config_dir, 'CB010636-B-B101_01_delta01.json')
DELTA_ACT_PER_CC_DL_UL = os.path.join(config_dir, 'Act_Per_CC_DL_UL.json')
DELTA_FR2_SA_PCELL_RECONF = os.path.join(config_dir, 'FR2_SA_PCell_reconfiguration.json')
DELTA_B_B102_01 = os.path.join(config_dir, 'CB010636-B-B102_01_delta.json')
DELTA_B_B102_DL_MAC_SDU = os.path.join(config_dir, 'CB010636-B-B102_dl_mac_sdu.json')
DELTA_B_B102_02_GNB1 = os.path.join(config_dir, 'CB010636-B-B102_02_gnb1_delta.json')
DELTA_B_B102_02_GNB2 = os.path.join(config_dir, 'CB010636-B-B102_02_gnb2_delta.json')
DELTA_B_B102_02_GNB1_DL_MAC_SDU = os.path.join(config_dir, 'CB010636-B-B102_02_gnb1_dl_mac_sdu.json')
DELTA_B_B102_02_GNB2_DL_MAC_SDU = os.path.join(config_dir, 'CB010636-B-B102_02_gnb2_dl_mac_sdu.json')
DELTA_C_B102_003_GNB1 = os.path.join(config_dir, 'CB010636-C-B102_003_gnb1_delta.json')
DELTA_C_B102_003_GNB2 = os.path.join(config_dir, 'CB010636-C-B102_003_gnb2_delta.json')
DELTA_C_B102_003_GNB1_activation = os.path.join(config_dir, 'CB010636-C-B102_003_gnb1_activation.json')
DELTA_C_B102_003_GNB2_activation = os.path.join(config_dir, 'CB010636-C-B102_003_gnb2_activation.json')
DELTA_C_B103_004 = os.path.join(config_dir, 'CB010636-C-B103_004_delta.json')
DELTA_C_B103_007 = os.path.join(config_dir, 'CB010636-C-B103_007_delta.json')
DELTA_C_B103_006 = os.path.join(config_dir, 'CB010636-C-B103_006_delta.json')
DELTA_C_6CC_016 = os.path.join(config_dir, 'CB010636-C-6CC_016_delta.json')
DELTA_C_6CC_019_SBTS00 = os.path.join(config_dir, 'CB010636-C-6CC_019_SBTS00_delta.json')
DELTA_C_6CC_019_SBTS25R1 = os.path.join(config_dir, 'CB010636-C-6CC_019_SBTS25R1_delta.json')
DELTA_C_6CC_019_SBTS25R2 = os.path.join(config_dir, 'CB010636-C-6CC_019_SBTS25R2_delta.json')
DELTA_C_6CC_020 = os.path.join(config_dir, 'CB010636-C-6CC_020_delta.json')
DELTA_C_6CC_022 = os.path.join(config_dir, 'CB010636-C-6CC_022_delta.json')
DELTA_B_B103_01_SBTS00_STEP_1 = os.path.join(config_dir, 'CB010636-B-B103_01_SBTS00_delta_step_1.json')
DELTA_B_B103_01_SBTS26R1_STEP_1 = os.path.join(config_dir, 'CB010636-B-B103_01_SBTS26R1_delta_step_1.json')
DELTA_B_B103_01_SBTS25R2_STEP_1 = os.path.join(config_dir, 'CB010636-B-B103_01_SBTS25R2_delta_step_1.json')
DELTA_B_B103_01_SBTS25R1_STEP_1 = os.path.join(config_dir, 'CB010636-B-B103_01_SBTS25R1_delta_step_1.json')
DELTA_B_B103_01_STEP_2 = os.path.join(config_dir, 'CB010636-B-B103_01_delta_step_2.json')
DELTA_C_B101_001 = os.path.join(config_dir, 'CB010636-C-B101_001_delta.json')
DELTA_C_B201_008 = os.path.join(config_dir, 'CB010636-C-B201_008_delta.json')
DELTA_C_B201_010 = os.path.join(config_dir, 'CB010636-C-B201_010_delta.json')
DELTA_C_B201_011 = os.path.join(config_dir, 'CB010636-C-B201_011_delta.json')
DELTA_C_B202_013 = os.path.join(config_dir, 'CB010636-C-B202_013_delta.json')
DELTA_B_B301_01_SBTS00 = os.path.join(config_dir, 'CB010636-B-B301_01_SBTS00_delta.json')
DELTA_B_B301_01_SBTS25R1 = os.path.join(config_dir, 'CB010636-B-B301_01_SBTS25R1_delta.json')
DELTA_B_B301_01_SBTS25R2 = os.path.join(config_dir, 'CB010636-B-B301_01_SBTS25R2_delta.json')
DELTA_B_B301_01_SBTS26R1 = os.path.join(config_dir, 'CB010636-B-B301_01_SBTS26R1_delta.json')
DELTA_B_B301_03_SBTS00 = os.path.join(config_dir, 'CB010636-B-B301_03_SBTS00_delta.json')
DELTA_B_B301_03_SBTS25R1 = os.path.join(config_dir, 'CB010636-B-B301_03_SBTS25R1_delta.json')
DELTA_B_B301_03_SBTS25R2 = os.path.join(config_dir, 'CB010636-B-B301_03_SBTS25R2_delta.json')

SCF_C_B202_014 = os.path.join(config_dir, 'CB010636-C-B202_014_scf.xml')
DELTA_B_B301_02_SBTS00 = os.path.join(config_dir, 'CB010636-B-B301_02_SBTS00_delta.json')
DELTA_B_B301_02_SBTS26R1 = os.path.join(config_dir, 'CB010636-B-B301_02_SBTS26R1_delta.json')
DELTA_B_B301_02_SBTS25R2 = os.path.join(config_dir, 'CB010636-B-B301_02_SBTS25R2_delta.json')
DELTA_B_B301_02_SBTS25R1 = os.path.join(config_dir, 'CB010636-B-B301_02_SBTS25R1_delta.json')
DELTA_C_B301_015 = os.path.join(config_dir, 'CB010636-C-B301_015_delta.json')
DELTA_C_B301_VOLTHRES = os.path.join(config_dir, 'CB010636-C-B301_volthres_delta.json')
DELTA_D_B104_01_SBTS00 = os.path.join(config_dir, 'CB010636-D-B104_01_SBTS00_delta.json')
DELTA_D_B104_01_SBTS25R1 = os.path.join(config_dir, 'CB010636-D-B104_01_SBTS25R1_delta.json')
DELTA_D_B104_01_SBTS25R2 = os.path.join(config_dir, 'CB010636-D-B104_01_SBTS25R2_delta.json')
DELTA_D_B104_01_SBTS26R1 = os.path.join(config_dir, 'CB010636-D-B104_01_SBTS26R1_delta.json')
DELTA_D_B104_03 = os.path.join(config_dir, 'CB010636-D-B104_03_delta.json')
DELTA_D_B104_02_GNB1 = os.path.join(config_dir, 'CB010636-D-B104_02_gnb1_delta.json')
DELTA_D_B104_02_GNB2 = os.path.join(config_dir, 'CB010636-D-B104_02_gnb2_delta.json')
DELTA_D_B104_04_GNB1 = os.path.join(config_dir, 'CB010636-D-B104_04_gnb1_delta.json')
DELTA_D_B104_04_GNB2 = os.path.join(config_dir, 'CB010636-D-B104_04_gnb2_delta.json')
DELTA_D_B104_04_GNB1_STEP_2 = os.path.join(config_dir, 'CB010636-D-B104_04_gnb1_delta_step_2.json')
DELTA_D_B104_04_GNB2_STEP_2 = os.path.join(config_dir, 'CB010636-D-B104_04_gnb2_delta_step_2.json')
DELTA_E_B201_01_GNB1 = os.path.join(config_dir, 'CB010636-E-B201_01_gnb1_delta.json')
DELTA_E_B201_01_GNB2 = os.path.join(config_dir, 'CB010636-E-B201_01_gnb2_delta.json')

IPHY_LO_AP_LO = os.path.join(config_dir, 'CB010636-LO_AP_LO_iphy.xml')
IPHY_A_A1_01 = os.path.join(config_dir, 'CB010636-MP_AP_LOOO_4CC_FDD_n66_TDD_n41_A_A1_01_iphy.xml')
IPHY_A_B103_01 = IPHY_LO_AP_LO
IPHY_A_B104_01 = os.path.join(config_dir, 'CB010636-MP_AP_LOOO_4CC_FDD_n66_TDD_n41_A_A1_01_iphy.xml')
IPHY_A_B201_01 = os.path.join(config_dir, 'CB010636-LO_LO_AP_LOO_4CC_2FDD_2TDD_3CC_FDD_iphy.xml')
IPHY_A_B202_01 = IPHY_LO_AP_LO
IPHY_A_B202_03 = IPHY_LO_AP_LO
IPHY_B_B102_01 = IPHY_LO_AP_LO
IPHY_B_B301_03 = os.path.join(config_dir, 'CB010636-MP_AP_LOOO_4CC_FDD_n66_TDD_n41_A_A1_01_iphy.xml')
IPHY_C_B103_004 = os.path.join(config_dir, 'CB010636-MP_AP_LOOO_4CC_FDD_n66_n71_iphy.xml')
IPHY_C_B103_007 = os.path.join(config_dir, 'CB010636-MP_AP_LOOO_4CC_FDD_n66_n71_iphy.xml')
IPHY_C_B201_008 = os.path.join(config_dir, 'CB010636-MP_AP_LOOO_4CC_C_B201_008_iphy.xml')
IPHY_C_B201_010 = os.path.join(config_dir, 'CB010636-BOO_AP_LOO_5CC_FDD_n66_n5_TDD_n78_iphy.xml')
IPHY_C_B201_011 = os.path.join(config_dir, 'CB010636-BOO_AP_LOO_5CC_TDD_n78_n41_FDD_n66_iphy.xml')
IPHY_C_B202_014 = os.path.join(config_dir, 'CB010636-BOO_AP_LOO_8CC_CB008294_iphy.xml')
IPHY_C_6CC_016 = os.path.join(config_dir, 'CB010636-MP_AP_LOOO_6CC_TDD_FDD_n41_A_n66_2A_n71_A_n77_2A.xml')
IPHY_C_6CC_019 = os.path.join(config_dir, 'CB010636-MP_AP_LOOO_6CC_TDD_FDD_n41_A_n66_2A_n71_A_n77_2A.xml')
IPHY_C_6CC_020 = os.path.join(config_dir, 'CB010636-MP_AP_LOOO_6CC_TDD_FDD_n41_A_n66_2A_n71_A_n77_2A.xml')
IPHY_C_6CC_022 = os.path.join(config_dir, 'CB010636-MP_AP_LOOO_6CC_TDD_FDD_n41_A_n66_2A_n71_A_n77_2A.xml')
IPHY_C_B301_015 = IPHY_LO_AP_LO
IPHY_D_B104_01 = os.path.join(config_dir, 'CB010636-MP_AP_LOOO_41_66_25_iphy.xml')
IPHY_D_B104_03 = os.path.join(config_dir, 'CB010636-LO_AP_LO_n78_n78_n71_n66_iphy.xml')

FR2_SA_TCS_SIB_CELL2 = ('a_a1_03', 'a_b104_03', 'b_b101_01', 'b_b301_01')
FR2_SA_TCS_SIB_CELL1 = ('c_b202_014',)
FR2_SA_TCS = FR2_SA_TCS_SIB_CELL2 + FR2_SA_TCS_SIB_CELL1

FR2_NSA_TCS = {'a_a1_04', 'a_b104_04', 'b_b103_01', 'b_b201_01', 'b_b301_02', 'b_b301_04', 'c_b101_001', 'c_b202_013',
               'c_b103_006'}
SYSCOM_TCS = ['b_b101_01', 'c_b101_001']
BURST_TRAFFIC_TCS = ['b_b201_01', 'b_b301_001', 'b_b301_002', 'b_b301_003', 'b_b301_004']
SYSLOG_VALIDATION_TCS = ['c_6cc_019', 'b_b102_01', 'e_b201_01', 'b_b102_02', 'c_6cc_022']
# CELL INFO
C_B103_004_CELL_INFO = [{'id': '11', 'pci': '60', 'type': 'FR1_FDD'}, {'id': '12', 'pci': '61', 'type': 'FR1_FDD'},
                        {'id': '13', 'pci': '62', 'type': 'FR1_FDD'}, {'id': '14', 'pci': '63', 'type': 'FR1_FDD'}]

C_B103_007_CELL_INFO = [{'id': '11', 'pci': '60', 'type': 'FR1_FDD'}, {'id': '12', 'pci': '61', 'type': 'FR1_FDD'},
                        {'id': '13', 'pci': '62', 'type': 'FR1_FDD'}, {'id': '14', 'pci': '63', 'type': 'FR1_FDD'}]

C_B201_010_CELL_INFO = [{'id': '1', 'pci': '50', 'type': 'FR1_FDD'}, {'id': '2', 'pci': '51', 'type': 'FR1_FDD'},
                        {'id': '3', 'pci': '52', 'type': 'FR1_TDD'}, {'id': '4', 'pci': '53', 'type': 'FR1_FDD'},
                        {'id': '6', 'pci': '55', 'type': 'FR1_TDD'}]

C_B201_011_CELL_INFO = [{'id': '1', 'pci': '50', 'type': 'FR1_FDD'}, {'id': '3', 'pci': '52', 'type': 'FR1_TDD'},
                        {'id': '5', 'pci': '54', 'type': 'FR1_FDD'}, {'id': '6', 'pci': '55', 'type': 'FR1_TDD'},
                        {'id': '7', 'pci': '56', 'type': 'FR1_TDD'}]

C_B202_013_CELL_INFO = [{'id': '1', 'pci': '51', 'type': 'FR2_TDD'}, {'id': '2', 'pci': '52', 'type': 'FR2_TDD'},
                        {'id': '3', 'pci': '53', 'type': 'FR2_TDD'}, {'id': '4', 'pci': '54', 'type': 'FR2_TDD'},
                        {'id': '5', 'pci': '55', 'type': 'FR2_TDD'}, {'id': '6', 'pci': '56', 'type': 'FR2_TDD'},
                        {'id': '7', 'pci': '57', 'type': 'FR2_TDD'}, {'id': '8', 'pci': '58', 'type': 'FR2_TDD'}]

C_6CC_020_CELL_INFO = [{'id': '1', 'pci': '50', 'type': 'FR1_TDD'}, {'id': '2', 'pci': '51', 'type': 'FR1_TDD'},
                       {'id': '3', 'pci': '52', 'type': 'FR1_TDD'}, {'id': '11', 'pci': '60', 'type': 'FR1_FDD'},
                       {'id': '12', 'pci': '61', 'type': 'FR1_FDD'}, {'id': '13', 'pci': '62', 'type': 'FR1_FDD'}]

C_6CC_022_CELL_INFO = [{'id': '1', 'pci': '50', 'type': 'FR1_TDD', 'bw': 50},
                       {'id': '2', 'pci': '51', 'type': 'FR1_TDD', 'bw': 50},
                       {'id': '3', 'pci': '52', 'type': 'FR1_TDD', 'bw': 50},
                       {'id': '11', 'pci': '60', 'type': 'FR1_FDD', 'bw': 10},
                       {'id': '12', 'pci': '61', 'type': 'FR1_FDD', 'bw': 10},
                       {'id': '13', 'pci': '62', 'type': 'FR1_FDD', 'bw': 10}]

C_B301_015_CELL_INFO = [{'id': '2', 'pci': '51', 'type': 'FR1_TDD'}, {'id': '3', 'pci': '52', 'type': 'FR1_FDD'}]

D_B104_01_CELL_INFO = [{'id': '1', 'pci': '50', 'type': 'FR1_TDD', 'bw': 50},
                       {'id': '2', 'pci': '51', 'type': 'FR1_TDD', 'bw': 50},
                       {'id': '3', 'pci': '52', 'type': 'FR1_TDD', 'bw': 50},
                       {'id': '4', 'pci': '53', 'type': 'FR1_TDD', 'bw': 60},
                       {'id': '11', 'pci': '60', 'type': 'FR1_FDD', 'bw': 10},
                       {'id': '12', 'pci': '61', 'type': 'FR1_FDD', 'bw': 10},
                       {'id': '13', 'pci': '62', 'type': 'FR1_FDD', 'bw': 10},
                       {'id': '14', 'pci': '63', 'type': 'FR1_FDD', 'bw': 20}]

D_B104_03_CELL_INFO = [{'id': '2', 'pci': '51', 'type': 'FR1_TDD', 'bw': 100},
                       {'id': '3', 'pci': '52', 'type': 'FR1_FDD', 'bw': 20},
                       {'id': '4', 'pci': '53', 'type': 'FR1_FDD', 'bw': 10}]

D_B104_02_CELL_INFO = [{'id': '1', 'pci': '50', 'type': 'FR1_FDD', 'bw': 15},
                       {'id': '2', 'pci': '51', 'type': 'FR1_FDD', 'bw': 10},
                       {'id': '3', 'pci': '52', 'type': 'FR1_TDD', 'bw': 100},
                       {'id': '4', 'pci': '53', 'type': 'FR1_TDD', 'bw': 100},
                       {'id': '5', 'pci': '54', 'type': 'FR1_FDD', 'bw': 15},
                       {'id': '6', 'pci': '55', 'type': 'FR1_FDD', 'bw': 15},
                       {'id': '7', 'pci': '56', 'type': 'FR1_TDD', 'bw': 100},
                       {'id': '8', 'pci': '57', 'type': 'FR1_TDD', 'bw': 100}]

D_B104_04_CELL_INFO = [{'id': '1', 'pci': '50', 'type': 'FR1_FDD', 'bw': 15},
                       {'id': '2', 'pci': '51', 'type': 'FR1_FDD', 'bw': 10},
                       {'id': '3', 'pci': '52', 'type': 'FR1_TDD', 'bw': 100},
                       {'id': '4', 'pci': '53', 'type': 'FR1_TDD', 'bw': 100},
                       {'id': '5', 'pci': '54', 'type': 'FR1_FDD', 'bw': 15},
                       {'id': '6', 'pci': '55', 'type': 'FR1_FDD', 'bw': 15},
                       {'id': '7', 'pci': '56', 'type': 'FR1_TDD', 'bw': 100},
                       {'id': '8', 'pci': '57', 'type': 'FR1_TDD', 'bw': 100}]

# PDU SESSION MODIFY
ADD_BEARER_3_UE_151 = {
    'ue': '151',
    'id': '3',
    'precedence_1': '3'
}

ADD_BEARER_3_MODIFY_UE_151 = {
    'ue': '151',
    'bearer_to_add': '3',
    'by': 'enb'
}

CPLANE_DEBUG_FLAGS = ['0x66001b=1', '0x890001=1', '0x890002=1', '0x890003=1', '0x890004=1', '0x890005=1', '0x890006=1',
                      '0x890008=1']
