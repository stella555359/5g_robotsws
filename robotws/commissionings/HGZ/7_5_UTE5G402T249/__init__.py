from robot.libraries.BuiltIn import BuiltIn

# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
# Source gNB: TDD 191, FDD 192; Target gNB: FDD 195, TDD 176
# if PA value of some RU is set to -1, it means this RU's PA ports won't be updated.
# For example: HO_A2_PA_F_T = {0: [-1, 20]}
INIT_PA = {0: [10]}
