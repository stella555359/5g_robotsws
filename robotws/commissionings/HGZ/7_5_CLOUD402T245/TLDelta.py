from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

TL_PARAMS_TO_ADD_8CC_CA = []

TL_PARAMS_TO_MODIFY_8CC_CA = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='8CCDL_4CC UL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='2DL0UL', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='nrCellType')
]
