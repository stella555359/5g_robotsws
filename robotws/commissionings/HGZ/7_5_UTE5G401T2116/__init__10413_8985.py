__maintainer__ = 'Lingxue Cui'
__team__ = 'I_NSB_MN_RAN_RD_VRF_HAZ3_01@internal.nsn.com'
__email__ = 'lingxue.cui@nokia-sbell.com'

# # PA related variables
PA_OUT_PORTS = [1, 2, 3, 4]
PA_ROWS = 32
# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
INIT_PA = {0: [10, 10, 10, 10, 10, 10, 127]}

# NRCELL-1 and NRCELL-2 are supercells, NRCELL-3 is normal cell with AVQC
ALL_CELLS = [1, 3]
SUPERCELLS = [1]
REMOVE_CELLS = [2]  # Because only 1 supercell in 10413, remove the other one.
ALL_RMODS = [1, 2, 3, 4, 5, 6, 7]
SUPERCELL_RMODS = [1, 2, 3, 4, 5, 6]

EXP_DL_TPUT = 1466
EXP_UL_TPUT = 151
EXP_UL_TPUT_NSA = 75
EXP_DL_TPUT_NORMAL_CELL = 1538
