from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'xiaoxia.hao@nokia-sbell.com'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_6_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaoxia.hao@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-' + _global_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_NRCELLname = _NRBTSname + '/NRCELL-1'
_NRBTSDUname = _NRBTSname + '/NRDU-9999'
_NRDRBname_11 = _NRBTSname + '/NRDRB-11'
_NRDRBname_12 = _NRBTSname + '/NRDRB-12'
_NRDRBname_13 = _NRBTSname + '/NRDRB-13'
_NRDRBname_14 = _NRBTSname + '/NRDRB-14'
_NRPMRNL_1 = _NRBTSname + '/NRPMRNL-1'
_NRRESOURCEGROUP_PROFILE_1 = _NRBTSname + '/NRRESOURCEGROUP_PROFILE-1'

CB014044_C_1_3UE_FDD_20MHz = [
    {
        'ue_indx': 201,
        'ul_data_transfer': '175',
        'dl_data_transfer': '175',
        'dl_trf_id': '3',
        'ul_trf_id': '1',
    },
    {
        'ue_indx': 202,
        'ul_data_transfer': '10',
        'dl_data_transfer': '10',
        'dl_trf_id': '1',
        'ul_trf_id': '1',
    },
    {
        'ue_indx': 203,
        'ul_data_transfer': '0.056',
        'dl_data_transfer': '0.056',
        'dl_trf_id': '1',
        'ul_trf_id': '1',
    },
]
# 60 UE
CB008242_D_2UE_FDD_20MHz = [
    {
        'ue_indx': 201,
        'ul_data_transfer': '175',
        'dl_data_transfer': '175',
        'dl_trf_id': '3',
        'ul_trf_id': '1',
    },
    {
        'ue_indx': 202,
        'ul_data_transfer': '10',
        'dl_data_transfer': '10',
        'dl_trf_id': '1',
        'ul_trf_id': '1',
    },
]

CNI_125269_FDD_20MHz = [
    {
        'ue_indx': 51,
        'ul_data_transfer': '175',
        'dl_data_transfer': '175',
        'dl_trf_id': '3',
        'ul_trf_id': '1',
    }
]

PARAM_14044_delete_gnb1_Ba_B1_001_01 = [
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileDN'),
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileUlDN'),
]

PARAM_14044_gnb1_Ba_B1_001_01 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='30', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='25', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='5', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
]
