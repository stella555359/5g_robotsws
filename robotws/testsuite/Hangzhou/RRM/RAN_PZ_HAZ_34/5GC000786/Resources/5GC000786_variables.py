from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Zhang yayun'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yayun.zhang@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_MRBTSname2 = 'MRBTS-'+_gnb_id2
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb_id2
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRCELL2name = _NRBTSname+'/NRCELL-2'
_NRDRB15name = _NRBTSname+'/NRDRB-15'
_NRBTSDUname = _NRBTSname+'/NRDU-1'
_NRCELLname2 = _NRBTSname2+'/NRCELL-1'
_NRBTSDUnameGRPgNB1cell = _NRBTSname+'/NRCELLGRP-0'
_NRBTSDUnameGRPgNB1cell2 = _NRBTSname+'/NRCELLGRP-1'
_NRRELLnamegnb1 = _NRCELL2name+'/NRREL-0'
_NRRELLnamegnb2 = _NRCELLname2+'/NRREL-1'
_NRRELLnamegnb20 = _NRCELLname2+'/NRREL-0'
_NRDU = _NRBTSname+'/NRDU-1'
_LTEENB = _NRBTSname+'/LTEENB-0'
_LTEENB2 = _NRBTSname2+'/LTEENB-0'
_NRRELL2NRREDRT = _NRCELL2name+'/NRREDRT-0'
_NRMOPR = _NRBTSname+'/NRMOPR_SA-1'
_NRDRB_9 = _NRBTSname+'/NRDRB_5QI-9'

PATH_TO_SCF = ''

PARAM_DELETE_Targetgnb1_W_001 = [
    dict(dist_name=_NRCELLname, parameter='n310VoNR'),
    dict(dist_name=_NRCELLname, parameter='t310VoNR'),
]

PARAM_749_Targetgnb1_W_001 = [
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='false', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptVoipTbs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='false', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_gNB1_786_B_018 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='false', dist_name=_NRBTSname, parameter='actInterRatHoSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actInterRatHoSADlDataForward'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_gNB1_786_B_018_PLMN_TL367 = [
    dict(value='MRBTS-1061/NRBTS-1061/NRPLMN-2', dist_name=_NRDRB_9, parameter='nrPlmnDN'),
]

PARAM_gNB1_786_B_018_PLMN_TL382 = [
    dict(value='MRBTS-38211/NRBTS-38211/NRPLMN-2', dist_name=_NRDRB_9, parameter='nrPlmnDN'),
]

PARAM_gNB1_786_B_018_PLMN_TL343 = [
    dict(value='MRBTS-1058/NRBTS-1058/NRPLMN-2', dist_name=_NRDRB_9, parameter='nrPlmnDN'),
]

_ho_path1 = 'BTS/CELLS/NRCELL-1/NNGCC'
_ho_path2 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path3 = 'BTS/CELLS/NRCELL-1/NX2CC'
_ho_path4 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/X2CCQ'
_ho_path5 = 'BTS/CELLS/NRCELL-1/RSADU'
_ho_path12 = 'BTS/CELLS/NRCELL-2/NNGCC'
_ho_path22 = 'BTS/CELLS/NRCELL-2/NRPMQAP-1/NGCCQ'
_ho_path32 = 'BTS/CELLS/NRCELL-2/NX2CC'
_ho_path42 = 'BTS/CELLS/NRCELL-2/NRPMQAP-1/X2CCQ'
_ho_path52 = 'BTS/CELLS/NRCELL-2/RSADU'
_ho_path53 = 'BTS/CELLS/NRCELL-2/RSACU'
_ho_path54 = 'BTS/CELLS/NRCELL-2/NRRCC'
_ho_path55 = 'BTS/CELLS/NRCELL-1/NRRCC'

SA_UE_CTX_REL_PREEM = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11501'}

AMOUNT_OF_CELLS = 1
