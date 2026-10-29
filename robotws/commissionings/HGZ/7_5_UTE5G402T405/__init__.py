from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Wang Yixiang'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'yixiang.x.wang@nokia-sbell.com'

__all__ = ['gnb_info', 'adjacent_gnb', 'ca_group_list']

# NR_CELL_ID_MAPPING = BuiltIn().get_variable_value('${NR_CELL_ID_MAPPING}')

gnb_info = {
    'gNbId': '1170',
    'gNbIdLength': '32',
    'mcc': '460',
    'mnc': '2',
    'mncLength': '2',
}

# record the target gNB and target cell's info, for TL251, the target is TL254, mapping is to record TL254 info
adjacent_gnb = {
    'gNbId': '564',
    'gNbIdLength': '32',
    'mcc': '460',
    'mnc': '2',
    'mncLength': '2',
    'fiveGsTac': '210',
    'cellDepType': 'SA',
    'freqBandIndicatorNR': '1',
    'lcrId': '1',
    'nrarfcn': '427970',
    'physCellId': '252',
    'ssbFrequency': '428030',
    'chBw': '20MHz',
    'ssbScs': '15KHz',
    'scs': '15 KHz',
    'ssBurstSetPeriod': '20'
}

Fdd_cell_1 = {
    'nrCellId': 1,
    'lcrId': '1',
    'nrCellGrpId': '0'
}

Tdd_cell_1 = {
    'nrCellId': 2,
    'lcrId': '2',
    'nrCellGrpId': '1'
}

ca_group_1 = {'pcell': Fdd_cell_1, 'scell': Tdd_cell_1}

ca_group_list = [ca_group_1]
