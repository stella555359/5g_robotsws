import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

PARAMS_562_SA_01 = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='semiStatic', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='60MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='7832', dist_name=MR_NR_CELL_NAME, p_name='gscn'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_562_SA_02 = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='semiStatic', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='80MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='7825', dist_name=MR_NR_CELL_NAME, p_name='gscn'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_562_SA_03 = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='semiStatic', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='60MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='7832', dist_name=MR_NR_CELL_NAME, p_name='gscn'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]

PARAMS_562_SA_04 = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='semiStatic', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='80MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='20', dist_name=MR_NR_CELLGRP_NAME, p_name='ssBurstSetPeriod'),
    dict(value='7825', dist_name=MR_NR_CELL_NAME, p_name='gscn'),
    dict(value='148', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
]
