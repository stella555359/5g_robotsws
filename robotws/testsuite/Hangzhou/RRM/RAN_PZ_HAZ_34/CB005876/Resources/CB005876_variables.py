# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2023/4/28 17:17
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_enb_id = str(tl.enbs[0].instance_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_gnb_id2 = str(tl.gnbs[0].instance_id)
_MRBTSname_enb = 'MRBTS-' + _global_id
_LNBTSname = _MRBTSname_enb + '/LNBTS-' + _enb_id
_MRBTSname = 'MRBTS-'+_global_id
_MRBTSname2 = 'MRBTS-'+_gnb_id2
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb_id2
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRCELL2name = _NRBTSname+'/NRCELL-2'
_NRCELL3name = _NRBTSname+'/NRCELL-3'
_NRCELL400name = _NRBTSname + '/NRCELL-400'
_NRCELL410name = _NRBTSname + '/NRCELL-410'
_NRCELL544name = _NRBTSname + '/NRCELL-544'
_NRCELL545name = _NRBTSname + '/NRCELL-545'
_NRCELL644name = _NRBTSname + '/NRCELL-644'
_NRCELL645name = _NRBTSname + '/NRCELL-645'
_NRCELL700name = _NRBTSname + '/NRCELL-700'
_NRCELL701name = _NRBTSname + '/NRCELL-701'
_NRCELLname2 = _NRBTSname2+'/NRCELL-1'
_LTECELL48040name = _LNBTSname + '/LNCEL-48040'
_LTECELL48041name = _LNBTSname + '/LNCEL-48041'
_LTECELL48042name = _LNBTSname + '/LNCEL-48042'
_LTECELL48043name = _LNBTSname + '/LNCEL-48043'
_LTECELL48044name = _LNBTSname + '/LNCEL-48044'
_LTECELL48045name = _LNBTSname + '/LNCEL-48045'
_LTECELL48046name = _LNBTSname + '/LNCEL-48046'
_LTECELL48047name = _LNBTSname + '/LNCEL-48047'
_LTECELL48048name = _LNBTSname + '/LNCEL-48048'
_LTECELL48049name = _LNBTSname + '/LNCEL-48049'

PATH_TO_SCF = ''

PARAMS_TO_MODIFY_CB005876_001_gnb1 = [
    dict(dist_name=_NRCELL544name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_NRCELL644name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_LTECELL48043name, parameter='administrativeState', value='locked'),
    dict(dist_name=_LTECELL48044name, parameter='administrativeState', value='locked'),
    dict(dist_name=_NRCELL700name, parameter='a2MeasRedirectEnabled', value='none'),
]
PARAMS_TO_MODIFY_CB005876_001_gnb1_383 = [
    dict(dist_name=_NRCELL3name, parameter='administrativeState', value='Locked'),
]

PARAMS_TO_MODIFY_CB005876_001_gnb2 = [
    dict(dist_name=_NRCELLname2, parameter='administrativeState', value='Locked')
]

PARAMS_TO_MODIFY_CB005876_001_gnb1_recover = [
    dict(dist_name=_NRCELL544name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_NRCELL644name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_LTECELL48043name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_LTECELL48044name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_NRCELL700name, parameter='a2MeasRedirectEnabled', value='rsrp'),
]
PARAMS_TO_MODIFY_CB005876_001_gnb1_recover_383 = [
    dict(dist_name=_NRCELL3name, parameter='administrativeState', value='Unlocked'),
]

PARAMS_TO_MODIFY_CB005876_001_gnb2_recover = [
    dict(dist_name=_NRCELLname2, parameter='administrativeState', value='Unlocked')
]
