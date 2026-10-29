from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = NR_NAME + '/NRCELL-1'

config_531_003 = [
    dict(value='2x2 Closed Loop Spatial Multiplexing',
         dist_name=NR_CELL_NAME, p_name='dlMimoMode'),
    dict(
        value='Automatic',
        dist_name=NR_CELL_NAME,
        p_name='openLoopScheme'),
    dict(value='1/4', dist_name=NR_CELL_NAME,
         p_name='ulDlDataSlotRatio', list_name='tddFrameStructure'),
    dict(value='false', dist_name=NR_NAME, p_name='actCarrierAggregation')]

config_531_005 = [
    dict(value='2x2 Open Loop Spatial Multiplexing',
         dist_name=NR_CELL_NAME, p_name='dlMimoMode'),
    dict(
        value='NoPrecoding',
        dist_name=NR_CELL_NAME,
        p_name='openLoopScheme'),
    dict(value='1/4', dist_name=NR_CELL_NAME,
         p_name='ulDlDataSlotRatio', list_name='tddFrameStructure'),
    dict(value='false', dist_name=NR_NAME, p_name='actCarrierAggregation')]

config_532_001 = [dict(value='Closed loop Spatial Multiplexing (2x2)', dist_name=NR_CELL_NAME, p_name='ulMimoMode'),
                  dict(value='0', dist_name=NR_CELL_NAME, p_name='ullaIniMcs'),
                  dict(value='3/7', dist_name=NR_CELL_NAME,
                       p_name='ulDlDataSlotRatio', list_name='tddFrameStructure'),
                  dict(value='false', dist_name=NR_NAME, p_name='actCarrierAggregation')]

config_532_002 = [
    dict(value='Closed loop Spatial Multiplexing (2x2)',
         dist_name=NR_CELL_NAME, p_name='ulMimoMode'),
    dict(
        value='11',
        dist_name=NR_CELL_NAME,
        p_name='ullaIniMcs'),
    dict(value='3/7', dist_name=NR_CELL_NAME,
         p_name='ulDlDataSlotRatio', list_name='tddFrameStructure'),
    dict(value='false', dist_name=NR_NAME, p_name='actCarrierAggregation')]

config_532_007 = [
    dict(value='Closed loop Spatial Multiplexing (2x2)',
         dist_name=NR_CELL_NAME, p_name='ulMimoMode'),
    dict(
        value='18',
        dist_name=NR_CELL_NAME,
        p_name='ullaIniMcs'),
    dict(value='3/7', dist_name=NR_CELL_NAME,
         p_name='ulDlDataSlotRatio', list_name='tddFrameStructure'),
    dict(value='false', dist_name=NR_NAME, p_name='actCarrierAggregation')]
