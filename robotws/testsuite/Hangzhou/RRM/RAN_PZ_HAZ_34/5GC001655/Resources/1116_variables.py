import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

PARAMS_1116_ELEMENTS = dict(frameStructureType='tdLte', guardPeriodLength='6Symbols',
                            lteToNrFrameShift='3ms', tdLteUlDlConfig='tdLteConfig2', ulDlDataSlotRatio='3/7')

PARAMS_1116_REMOVE_LIST = [
    dict(dist_name=MR_NR_CELL_NAME, list_name='tddFrameStructure')
]

PARAMS_1116_ADD_LIST = [
    dict(dist_name=MR_NR_CELL_NAME, list_name='tddFrameStructure')
]

PARAMS_1116_ADD_ITEM = [
    dict(dist_name=MR_NR_CELL_NAME, list_name='tddFrameStructure', elements=PARAMS_1116_ELEMENTS)
]

PARAMS_1116_A_01 = [
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='6Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='2CCEs', dist_name=MR_NR_CELL_NAME, p_name='aggregationLevel'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDlMuMimo'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1116_A_02 = [
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='6Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='4CCEs', dist_name=MR_NR_CELL_NAME, p_name='aggregationLevel'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDlMuMimo'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1116_A_03 = [
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='4CCEs', dist_name=MR_NR_CELL_NAME, p_name='aggregationLevel'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDlMuMimo'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1116_A_04 = [
    dict(value='8', dist_name=MR_NR_CELL_NAME, p_name='nrofHARQProcessesForPDSCH'),
    dict(value='8', dist_name=MR_NR_CELLGRP_NAME, p_name='maxDlHarqTx'),
    dict(value='8', dist_name=MR_NR_CELLGRP_NAME, p_name='maxUlHarqTx'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='4CCEs', dist_name=MR_NR_CELL_NAME, p_name='aggregationLevel'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDlMuMimo'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1116_A_05 = [
    dict(value='8', dist_name=MR_NR_CELL_NAME, p_name='nrofHARQProcessesForPDSCH'),
    dict(value='8', dist_name=MR_NR_CELLGRP_NAME, p_name='maxDlHarqTx'),
    dict(value='8', dist_name=MR_NR_CELLGRP_NAME, p_name='maxUlHarqTx'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='4CCEs', dist_name=MR_NR_CELL_NAME, p_name='aggregationLevel'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDlMuMimo'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1116_A_06 = [
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='28', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_1116_A_07 = [
    dict(value='28', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam')
]
