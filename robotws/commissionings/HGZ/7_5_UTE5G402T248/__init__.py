from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = "Wang Yixiang"
__team__ = "I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS "
__email__ = "yixiang.x.wang@nokia-sbell.com"


# NR_CELL_ID_MAPPING = BuiltIn().get_variable_value('${NR_CELL_ID_MAPPING}')

gnb_info = {
    "gNbId": "248",
    "gNbIdLength": "32",
    "mcc": "310",
    "mnc": "260",
    "mncLength": "3",
    "enb_id": "1",
}

adjacent_gnb = {
    "gNbId": "10631",
    "gNbIdLength": "32",
    "mcc": "310",
    "mnc": "260",
    "mncLength": "3",
    # below is PCEll(FDD Cell) info on target gNB for handover use.
    "fiveGsTac": "270",
    "cellDepType": "SA+NSA",
    "freqBandIndicatorNR": "71",
    "lcrId": "1",
    "nrarfcn": "430160",
    "physCellId": "939",
    "ssbFrequency": "518430",
    "chBw": "20MHz",
    "ssbScs": "15KHz",
    "scs": "15 KHz",
    "ssBurstSetPeriod": "20",
    # for intra-freq
    "nrarfcn_intra": "127180",
}

Fdd_cell_1 = {
    "nrCellId": 2,
    "lcrId": "2",
    "nrCellGrpId": "1",
    "fddAbil": "1",
    "ru_index_in_testline_file": 1,
    # below info is for handover use.
    "fiveGsTac": "270",
    "cellDepType": "SA+NSA",
    "freqBandIndicatorNR": "71",
    "lcrId": "2",
    "nrarfcn": "127180",
    "physCellId": "937",
    "ssbFrequency": "126970",
    "chBw": "20MHz",
    "ssbScs": "15KHz",
    "scs": "15 KHz",
    "ssBurstSetPeriod": "20",
    "ru_index_in_testline_file": 1,
}

Tdd_cell_1 = {
    "nrCellId": 1,
    "lcrId": "1",
    "nrCellGrpId": "0",
    "tddAbil": "2",
    "ru_index_in_testline_file": 0,
}

ca_group_1 = {"pcell": Fdd_cell_1, "scell": Tdd_cell_1}

ca_group_list = [ca_group_1]
F_T_ALLOCATION = {"FDD": [Fdd_cell_1], "TDD": [Tdd_cell_1]}
# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
# Left: TDD 936, FDD 937; Right: FDD 938, TDD 939
INIT_PA_F_T = {0: [0, 10], 1: [127, 127]}
PA_OUT_PORTS = [1, 2, 5, 6, 7, 8, 9, 10]
PA_ROWS = 1
