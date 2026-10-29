from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'shi ming'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-'+_global_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELL1 = _NRBTSname+'/NRCELL-1'
_NRCELL301 = _NRBTSname+'/NRCELL-301'

CB010701_pcell_counters = [
    "ACC_NUM_3TX_UE_CAP",
    "ACC_NUM_UL_CA_3TX_UE_CONFIG",
    "DEN_1_SEC_SAMPLE",
    "AVG_NUM_UE_DENOM",
    "SUM_1L_PUSCH_REC_SCELL_ACT_2P",
    "SUM_2L_PUSCH_REC_SCELL_ACT_2P",
    "SUM_1L_PUSCH_REC_SCELL_ACT_1P"
]

CB010701_scell_counters = [
    "SUM_1L_PUSCH_REC_SCELL_ACT_2P",
    "SUM_2L_PUSCH_REC_SCELL_ACT_2P",
    "SUM_1L_PUSCH_REC_SCELL_ACT_1P"
]

parameters_to_update_CB013151_CNI156183 = [
    dict(value='false', dist_name=_NRCELL1, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL301, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRBTSname, parameter='actUnlimitedDataRateUl'),
    dict(value='1-1-0_OCCs', dist_name=_NRCELL1, parameter='pucchF1ResOccConf'),
    dict(value='1-1-0_OCCs', dist_name=_NRCELL301, parameter='pucchF1ResOccConf'),
    dict(value='true', dist_name=_NRCELL1, parameter='actDynUlResAllocPhase2'),
    dict(value='true', dist_name=_NRCELL301, parameter='actDynUlResAllocPhase2'),
]

parameters_to_recovery_CB013151_CNI156183 = [
    dict(value='true', dist_name=_NRCELL1, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL301, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRBTSname, parameter='actUnlimitedDataRateUl'),
    dict(value='3-3-0_OCCs', dist_name=_NRCELL1, parameter='pucchF1ResOccConf'),
    dict(value='3-3-0_OCCs', dist_name=_NRCELL301, parameter='pucchF1ResOccConf'),
    dict(value='true', dist_name=_NRCELL1, parameter='actDynUlResAllocPhase2'),
    dict(value='true', dist_name=_NRCELL301, parameter='actDynUlResAllocPhase2'),
]
