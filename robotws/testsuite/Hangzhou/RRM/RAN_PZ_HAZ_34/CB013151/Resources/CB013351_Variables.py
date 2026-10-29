from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'zhang yayun'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yayun.zhang@nokia.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb1_id = str(tl.gnbs[0].instance_id)
_global1_id = str(tl.gnbs[0].global_bts_id)
# _gnb2_id = str(tl.gnbs[1].instance_id)
# _global2_id = str(tl.gnbs[1].global_bts_id)
_MRBTS1_name = 'MRBTS-' + _global1_id
_NRBTS1_name = _MRBTS1_name + '/NRBTS-' + _gnb1_id
# _MRBTS2_name = 'MRBTS-' + _global2_id
# _NRBTS2_name = _MRBTS2_name + '/NRBTS-' + _gnb2_id
_GNB1CELL1_name = _NRBTS1_name + '/NRCELL-1'
_GNB1CELL2_name = _NRBTS1_name + '/NRCELL-2'
_GNB1CELL3_name = _NRBTS1_name + '/NRCELL-3'

parameters_to_update_CB013151_CNI156183 = [
    dict(value='notBarred', dist_name=_GNB1CELL3_name, parameter='cellBarred'),
    dict(value='false', dist_name=_GNB1CELL3_name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRBTS1_name, parameter='actUnlimitedDataRateUl'),
    dict(value='1-1-0_OCCs', dist_name=_GNB1CELL3_name, parameter='pucchF1ResOccConf'),
    dict(value='true', dist_name=_GNB1CELL3_name, parameter='actDynUlResAllocPhase2'),
]

parameters_to_recovery_CB013151_CNI156183 = [
    dict(value='barred', dist_name=_GNB1CELL3_name, parameter='cellBarred'),
    dict(value='true', dist_name=_GNB1CELL3_name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRBTS1_name, parameter='actUnlimitedDataRateUl'),
    dict(value='3-3-0_OCCs', dist_name=_GNB1CELL3_name, parameter='pucchF1ResOccConf'),
    dict(value='true', dist_name=_GNB1CELL3_name, parameter='actDynUlResAllocPhase2'),
]
