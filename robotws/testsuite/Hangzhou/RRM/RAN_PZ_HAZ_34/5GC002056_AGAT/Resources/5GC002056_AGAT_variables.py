# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2023/4/14 14:09
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_MRBTSname2 = 'MRBTS-'+_gnb_id2
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb_id2
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRCELLname21 = _NRBTSname2+'/NRCELL-1'
_enb_id = str(tl.gnbs[0].instance_id + 10)
_LNBTSname = _MRBTSname+'/LNBTS-'+_enb_id
_LTECELLname = _LNBTSname+'/LNCEL-4'

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

_NRCELL400name = _NRBTSname + '/NRCELL-400'
_NRCELL410name = _NRBTSname + '/NRCELL-410'
_NRCELL544name = _NRBTSname + '/NRCELL-544'
_NRCELL545name = _NRBTSname + '/NRCELL-545'
_NRCELL644name = _NRBTSname + '/NRCELL-644'
_NRCELL645name = _NRBTSname + '/NRCELL-645'
_NRCELL700name = _NRBTSname + '/NRCELL-700'
_NRCELL701name = _NRBTSname + '/NRCELL-701'

PATH_TO_SCF = ''

PARAM_2056_AGAT_786_D_03_WA_348 = [
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState')
]

PARAM_2056_AGAT_786_D_03_WA = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState')
]

PARAM_2056_AGAT_786_D_03 = [
    dict(value='false', dist_name=_NRCELLname21, parameter='actVoNR'),
    dict(value='false', dist_name=_NRCELLname21, parameter='actEmergencyCall'),
    dict(value='false', dist_name=_NRCELLname21, parameter='actEnhancedVoNR'),
    dict(value='false', dist_name=_NRCELLname21, parameter='actAdaptVoipTbs'),
    dict(value='false', dist_name=_NRCELLname21, parameter='actCDrxVoNR'),
    dict(value='deactivated', dist_name=_NRCELLname21, parameter='actDataForwardingForVoNr'),
    dict(value='off', dist_name=_NRCELLname21, parameter='actGBRAdmissionControl'),
    dict(value='false', dist_name=_NRCELLname21, parameter='actVoipPacketAggr'),
    dict(value='false', dist_name=_NRBTSname2, parameter='actRohc')
]
PARAM_DELETE_2056_AGAT_786_D_03 = [
    dict(dist_name=_NRCELLname21, parameter='n310VoNR'),
    dict(dist_name=_NRCELLname21, parameter='t310VoNR')
]
PARAM_2056_AGAT_786_D_03_recover = [
    dict(value='true', dist_name=_NRCELLname21, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname21, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELLname21, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname21, parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name=_NRCELLname21, parameter='actCDrxVoNR'),
    dict(value='Xn_and_NG_activated', dist_name=_NRCELLname21, parameter='actDataForwardingForVoNr'),
    dict(value='EnhancedVoNR', dist_name=_NRCELLname21, parameter='actGBRAdmissionControl'),
    dict(value='true', dist_name=_NRCELLname21, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRBTSname2, parameter='actRohc')
]
PARAM_ADD_2056_AGAT_786_D_03_recover = [
    dict(value='n20', dist_name=_NRCELLname21, parameter='n310VoNR'),
    dict(value='2000ms', dist_name=_NRCELLname21, parameter='t310VoNR')
]
PARAM_2056_AGAT_786_D_03_recover_WA_348 = [
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState')
]
PARAM_2056_AGAT_786_D_03_recover_WA = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState')
]
