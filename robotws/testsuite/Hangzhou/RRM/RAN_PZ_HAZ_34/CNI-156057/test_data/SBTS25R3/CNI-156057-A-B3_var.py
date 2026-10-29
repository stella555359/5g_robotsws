from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Zhang Yin'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yin.zhang@nokia-sbell.com'

_enb_id = str(tl.enbs[0].instance_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-' + _global_id
_MRBTSname_enb = 'MRBTS-' + _global_id
NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_LNBTSname = _MRBTSname_enb + '/LNBTS-' + _enb_id
NRCELL21name = NRBTSname + "/NRCELL-21"
NRCELL31name = NRBTSname + "/NRCELL-31"
NRCELL32name = NRBTSname + "/NRCELL-32"
TRACKINGAREA_20300 = NRBTSname + "/TRACKINGAREA-20300"
NRDU = NRBTSname + "/NRDU-1"
SERVEDAMF = NRBTSname + "/SERVEDAMF-1"
NRHOIR1 = NRBTSname + "/NRHOIR-1"


PARAMS_ICS_RedirectionVoiceFallback_not_possible = [
    dict(value='10.70.255.6', dist_name=SERVEDAMF, parameter='amfIPAddress'),
    dict(value=TRACKINGAREA_20300, dist_name=NRCELL21name, parameter='trackingAreaDN'),
    # plmn 310260 or 26203
    dict(value='262', dist_name=NRBTSname, parameter='mcc'),
    dict(value='3', dist_name=NRBTSname, parameter='mnc'),
    dict(value='2', dist_name=NRBTSname, parameter='mncLength'),
    ]

PARAMS_156057_AB3_006 = [
    dict(value='8192', dist_name=NRCELL21name, parameter='tmpActFeat1'),  # bit13
    dict(value='true', dist_name=NRCELL21name, parameter='actVoNR'),
    dict(value='true', dist_name=NRCELL21name, parameter='actEmergencyCall'),
    dict(value='1', dist_name=NRCELL21name, parameter='arpPrioEmergencyCall'),
    dict(value='true', dist_name=NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=NRCELL21name, parameter='emergencyCallFails'),
    dict(value='1025', dist_name=NRCELL21name+'/NRREDRT-1', parameter='redirFreqEutra'),
    dict(value='eutra', dist_name=NRCELL21name+'/NRREDRT-1', parameter='redirRat'),
    dict(value='0', dist_name=NRCELL21name, parameter='maxNumOfDcGbrBearersSA'),
    dict(value='0', dist_name=NRCELL21name, parameter='maxNumOfGBRBearersSA'),
    dict(value='0', dist_name=NRDU, parameter='numOfDrbsReservForEmergency'),
    # dict(value='redirection', dist_name=NRBTSname, parameter='causeOfRelInVoiceFallback'),
    dict(value='Locked', dist_name=NRCELL31name, parameter='administrativeState'),
    dict(value='Locked', dist_name=NRCELL32name, parameter='administrativeState'),
    dict(value='false', dist_name=NRBTSname, parameter='actVoFallBackLteB1MeaBaRedir'),  # CB012118 disable
] + PARAMS_ICS_RedirectionVoiceFallback_not_possible

PARAMS_156057_AB3_007 = [
    # CB012118
    dict(value='true', dist_name=NRBTSname, parameter='actVoFallBackLteB1MeaBaRedir'),
    dict(value='10000', dist_name=NRBTSname, parameter='b1RedirSupervisionTimer'),
    # dict(value='fallback', dist_name=NRBTSname, parameter='causeOfRelInVoiceFallback'),
    dict(value=[dict(b1measPriority='1', nrhoirRedirDN='NRHOIR-1')],
         dist_name=NRCELL21name, parameter='b1RedirectList'),
    dict(value='rsrp', dist_name=NRHOIR1, parameter='b1MeasRedirectEnabled'),
    dict(value='1025', dist_name=NRHOIR1, parameter='earfcnValue'),
]

PARAMS_156057_AB3_009 = [
    dict(value='8192', dist_name=NRCELL21name, parameter='tmpActFeat1'),
]

PARAMS_156057_DISABLED = [
    dict(value='0', dist_name=NRCELL21name, parameter='tmpActFeat1'),
]
