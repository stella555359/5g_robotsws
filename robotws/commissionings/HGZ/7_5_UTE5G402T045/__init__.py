from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Dandan Fang'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'dandan.fang@nokia-sbell.com'

# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
INIT_PA_SUBCELLS_MUTE = {0: [127, 127, 127, 127, 127, 127]}
NONCA_SUBCELL0_ATTACH_PA_INIT = {0: [0, 127, 127, 127, 127, 127]}
NONCA_SUBCELL1_ATTACH_PA_INIT = {0: [127, 0, 127, 127, 127, 127]}
NONCA_SUBCELL2_ATTACH_PA_INIT = {0: [127, 127, 0, 127, 127, 127]}

NONCA_Subcell_0_Switch_To_Subcell_5 = {
    'source_subcell': {'ru_index': 0, 'pa_value': 30},
    'target_subcell': {'ru_index': 5, 'pa_value': 0}
}

CA_PCELL_SCELL_PA_INIT = {0: [0, 127, 127, 0, 127, 127]}
PCELL_Subcell_0_SwitchTo_Subcell_1_PA = {
    'source_subcell': {'ru_index': 0, 'pa_value': 30},
    'target_subcell': {'ru_index': 1, 'pa_value': 0}
}

PCELL_Subcell_1_SwitchTo_Subcell_2_PA = {
    'source_subcell': {'ru_index': 1, 'pa_value': 20},
    'target_subcell': {'ru_index': 2, 'pa_value': 0}
}

SCELL_RLQ_Subcell0_RU_INDEX_PA_VALUE = {'ru_index': 3, 'pa_value': 50}
SCELL_Subcell_0_SwitchTo_Subcell_1_PA = {
    'source_subcell': {'ru_index': 3, 'pa_value': 50},
    'target_subcell': {'ru_index': 4, 'pa_value': 0}
}

SCELL_Subcell_1_SwitchTo_Subcell_2_PA = {
    'source_subcell': {'ru_index': 4, 'pa_value': 30},
    'target_subcell': {'ru_index': 5, 'pa_value': 0}
}

# 8985 T-T CA just support T-SuperCell + T-SuperCell
Cell_ALLOCATION = {'TDD': [1, 2]}
ALL_CELLS = Cell_ALLOCATION['TDD']
ALL_RMODS = [1, 2, 3, 4, 5, 6]

COMMON_PCELL_ID = Cell_ALLOCATION['TDD'][0]

T_T_2CC_CA_GROUP_COMMON = {
    'pcell_id': Cell_ALLOCATION['TDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                Cell_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'}
            }
        }
    ],
    'verify_scell_add_dl': Cell_ALLOCATION['TDD'][1]
}

DL_TPUT_Iperf = '1600M'
UL_TPUT_Iperf = '300m'
T_T_CA_DL_Iperf_Data = '2100M'

# TDD1 40MHZ TDD2 100MHZ
PCELL_EXP_DL_TP = 1440   # 3 Subcell- DL about 1440Mbps
SCELL_EXP_DL_TP = 560  # 50Mhz
PCELL_EXP_UL_TP = 199  # ul256qam is enable, if disable, should be 154
PCELL_EXP_UL_TP_NSA = 100   # TDD NSA just work at Rank1

SUPERCELL_6SUBCELL_DL_TP = 1452
SUPERCELL_6SUBCELL_UL_TP = 207

# Following code is just used for UTE Cloud Testline , forbidden to do sw upgrade for enb
# tl.ues[-1] just save real enb
tl = BuiltIn().get_variable_value('${tl}')

tl.enbs = []
tl.enbs.append(tl.ues[-1])
