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
_NRCELL2name = _NRBTSname+'/NRCELL-2'
_NRCELL3name = _NRBTSname+'/NRCELL-3'
_NRDRB15name = _NRBTSname+'/NRDRB-15'
_NRBTSDUname = _NRBTSname+'/NRDU-1'
_NRBTSDUnameGRPgNB1cell = _NRBTSname+'/NRCELLGRP-1'
_NRHOIF11 = _NRCELLname+'/NRHOIF-1'
_NRHOIF21 = _NRCELLname21+'/NRHOIF-1'

PATH_TO_SCF = ''

PARAM_VONR_HO = [
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
]
PARAM_recover_VONR_HO = [
    dict(value='false', dist_name=_NRBTSname, parameter='actRohc'),
]

PARAM_TMO_VoNR_EPSFB = [
    dict(value='false', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptVoipTbs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='false', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEmergencyCall')
]
PARAM_DELETE_TMO_VoNR_EPSFB = [
    dict(dist_name=_NRCELLname, parameter='n310VoNR'),
    dict(dist_name=_NRCELLname, parameter='t310VoNR')
]
PARAM_TMO_VoNR_EPSFB_recover = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall')
]
PARAM_ADD_TMO_VoNR_EPSFB = [
    dict(value='n10', dist_name=_NRCELLname, parameter='n310VoNR'),
    dict(value='2000ms', dist_name=_NRCELLname, parameter='t310VoNR')
]

PARAM_TMO_Video = [
    dict(value='10', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value='10', dist_name=_NRBTSname, parameter='drbInactivityTimerSA5qi1'),
    dict(value='10', dist_name=_NRBTSname, parameter='drbInactivityTimerSA5qi5'),
    dict(value='10', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
]
PARAM_recover_TMO_Video = [
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value='45', dist_name=_NRBTSname, parameter='drbInactivityTimerSA5qi1'),
    dict(value='45', dist_name=_NRBTSname, parameter='drbInactivityTimerSA5qi5'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
]

PARAM_TMO_EMC_EPSFB = [
    dict(value='false', dist_name=_NRCELLname, parameter='emergencyCallLimServ'),
    dict(value='0', dist_name=_NRCELLname, parameter='maxNumOfGBRBearersSA'),
    dict(value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name=_NRCELL3name, parameter='numOfRadioResReservForEmergency'),
    dict(value='1', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='false', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='10', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value='10', dist_name=_NRBTSname, parameter='drbInactivityTimerSA5qi1'),
    dict(value='10', dist_name=_NRBTSname, parameter='drbInactivityTimerSA5qi5'),
    dict(value='10', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
]
PARAM_TMO_EMC_EPSFB_2 = [
    dict(value='0', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA'),
]
PARAM_recover_TMO_EMC_EPSFB = [
    dict(value='true', dist_name=_NRCELLname, parameter='emergencyCallLimServ'),
    dict(value='384', dist_name=_NRCELLname, parameter='maxNumOfGBRBearersSA'),
    dict(value='10', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='10', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='10', dist_name=_NRCELL3name, parameter='numOfRadioResReservForEmergency'),
    dict(value='30', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value='45', dist_name=_NRBTSname, parameter='drbInactivityTimerSA5qi1'),
    dict(value='45', dist_name=_NRBTSname, parameter='drbInactivityTimerSA5qi5'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
]
PARAM_recover_TMO_EMC_EPSFB_2 = [
    dict(value='550', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA'),
]


PARAM_ROHC = [
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='none', dist_name=_NRHOIF11, parameter='a3MeasEnabled'),
]
PARAM_ROHC_2 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='none', dist_name=_NRHOIF21, parameter='a3MeasEnabled'),
]
PARAM_recover_ROHC = [
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='rsrp', dist_name=_NRHOIF11, parameter='a3MeasEnabled'),
]
PARAM_recover_ROHC_2 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='rsrp', dist_name=_NRHOIF21, parameter='a3MeasEnabled'),
]

_mcc = str(tl.core.mcc)
_mnc = str(tl.core.mnc)
_mcc2 = '460'
_mnc2 = '02'
_mcc3 = '262'
_mnc3 = '03'

_ho_path1 = 'BTS/CELLS/NRCELL-1/NRRCC'
_ho_path2 = 'BTS/BTS/NRBTS-' + _gnb_id + '/NE1CS'
_ho_path22 = 'BTS/BTS/NRBTS-' + _gnb_id2 + '/NE1CS'
_ho_path3 = 'BTS/BTS/NRBTS-' + _gnb_id + '/PDCP2'
_ho_path32 = 'BTS/BTS/NRBTS-' + _gnb_id2 + '/PDCP2'
_ho_path4 = 'BTS/BTS/NRBTS-' + _gnb_id + '/PDCP1'
_ho_path42 = 'BTS/BTS/NRBTS-' + _gnb_id2 + '/PDCP1'
_ho_path5 = 'BTS/CELLS/NRCELL-1/NNGCC'
_ho_path52 = 'BTS/CELLS/NRCELL-2/NNGCC'
_ho_path6 = 'BTS/CELLS/NRCELL-1/RSACU'
_ho_path62 = 'BTS/CELLS/NRCELL-2/RSACU'
_ho_path71 = 'BTS/CELLS/NRCELL-1/MCC-'+_mcc+'_MNC-'+_mnc+'/NRANS'
_ho_path72 = 'BTS/CELLS/NRCELL-1/MCC-'+_mcc2+'_MNC-'+_mnc2+'/NRANS'
_ho_path73 = 'BTS/CELLS/NRCELL-1/MCC-'+_mcc3+'_MNC-'+_mnc3+'/NRANS'
_ho_path712 = 'BTS/CELLS/NRCELL-2/MCC-'+_mcc+'_MNC-'+_mnc+'/NRANS'
_ho_path722 = 'BTS/CELLS/NRCELL-2/MCC-'+_mcc2+'_MNC-'+_mnc2+'/NRANS'
_ho_path732 = 'BTS/CELLS/NRCELL-2/MCC-'+_mcc3+'_MNC-'+_mnc3+'/NRANS'


SA_GBR_DRB_REQ_1 = {'gnb_id': 2, 'dic_path': _ho_path6, 'counter_id': 'M55138C01001'}
SA_GBR_DRB_REQ_2 = {'gnb_id': 2, 'dic_path': _ho_path62, 'counter_id': 'M55138C01001'}
SUCC_GBR_DRB_SETUP_SA_PLMN_1 = {'gnb_id': 2, 'dic_path': _ho_path71, 'counter_id': 'M55145C01501'}
SUCC_GBR_DRB_SETUP_SA_PLMN_2 = {'gnb_id': 2, 'dic_path': _ho_path72, 'counter_id': 'M55145C01501'}
SUCC_GBR_DRB_SETUP_SA_PLMN_3 = {'gnb_id': 2, 'dic_path': _ho_path73, 'counter_id': 'M55145C01501'}
SUCC_GBR_DRB_SETUP_SA_PLMN_4 = {'gnb_id': 2, 'dic_path': _ho_path712, 'counter_id': 'M55145C01501'}
SUCC_GBR_DRB_SETUP_SA_PLMN_5 = {'gnb_id': 2, 'dic_path': _ho_path722, 'counter_id': 'M55145C01501'}
SUCC_GBR_DRB_SETUP_SA_PLMN_6 = {'gnb_id': 2, 'dic_path': _ho_path732, 'counter_id': 'M55145C01501'}
AVE_NUMBER_OF_SA_GBR_1 = {'gnb_id': 2, 'dic_path': _ho_path6, 'counter_id': 'M55138C01005'}
AVE_NUMBER_OF_SA_GBR_2 = {'gnb_id': 2, 'dic_path': _ho_path62, 'counter_id': 'M55138C01005'}
AVE_SA_GBR_HOLDING_TIME_1 = {'gnb_id': 2, 'dic_path': _ho_path6, 'counter_id': 'M55138C01008'}
AVE_SA_GBR_HOLDING_TIME_2 = {'gnb_id': 2, 'dic_path': _ho_path62, 'counter_id': 'M55138C01008'}
AVE_SA_GBR_HOLDING_TIME_DEN_1 = {'gnb_id': 2, 'dic_path': _ho_path6, 'counter_id': 'M55138C01009'}
AVE_SA_GBR_HOLDING_TIME_DEN_2 = {'gnb_id': 2, 'dic_path': _ho_path62, 'counter_id': 'M55138C01009'}
DL_VOL_ROHC_COMP_HEADER = {'gnb_id': 2, 'dic_path': _ho_path32, 'counter_id': 'M55320C19002'}
DL_VOL_TX_SA_QOS_GRP_01 = {'gnb_id': 2, 'dic_path': _ho_path42, 'counter_id': 'M55319C12001'}

SFE_case_001 = [
    SA_GBR_DRB_REQ_1, SA_GBR_DRB_REQ_2, SUCC_GBR_DRB_SETUP_SA_PLMN_1, SUCC_GBR_DRB_SETUP_SA_PLMN_2,
    SUCC_GBR_DRB_SETUP_SA_PLMN_3, SUCC_GBR_DRB_SETUP_SA_PLMN_4, SUCC_GBR_DRB_SETUP_SA_PLMN_5,
    SUCC_GBR_DRB_SETUP_SA_PLMN_6, AVE_NUMBER_OF_SA_GBR_1, AVE_NUMBER_OF_SA_GBR_2,
    AVE_SA_GBR_HOLDING_TIME_1, AVE_SA_GBR_HOLDING_TIME_2, AVE_SA_GBR_HOLDING_TIME_DEN_1,
    AVE_SA_GBR_HOLDING_TIME_DEN_2, DL_VOL_ROHC_COMP_HEADER, DL_VOL_TX_SA_QOS_GRP_01
]

counter_SFE_case_001 = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SFE_case_001]

NR_RRC_RELEASE_REDIR_VFB_LTE = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55124C02501'}
NRRCC_RRC_RELEASE_REDIR_LTE = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55124C01502'}

SFE_case_002 = [
    NR_RRC_RELEASE_REDIR_VFB_LTE, NRRCC_RRC_RELEASE_REDIR_LTE
]

counter_SFE_case_002 = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SFE_case_002]

NRRCC_RRC_STPREQ_MO_VIDEOCAL = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55124C01017'}

SFE_case_003 = [
    NRRCC_RRC_STPREQ_MO_VIDEOCAL
]

counter_SFE_case_003 = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SFE_case_003]

NNGCC_PDU_SES_STP_RESP_EC_SENT_1 = {'gnb_id': 2, 'dic_path': _ho_path5, 'counter_id': 'M55125C05506'}
NNGCC_PDU_SES_STP_RESP_EC_SENT_2 = {'gnb_id': 2, 'dic_path': _ho_path52, 'counter_id': 'M55125C05506'}
NNGCC_PDU_SES_STP_REQ_EC_RECD_1 = {'gnb_id': 2, 'dic_path': _ho_path5, 'counter_id': 'M55125C05505'}
NNGCC_PDU_SES_STP_REQ_EC_RECD_2 = {'gnb_id': 2, 'dic_path': _ho_path52, 'counter_id': 'M55125C05505'}
NNGCC_PDUSESMODREQ_EC_RECD_1 = {'gnb_id': 2, 'dic_path': _ho_path5, 'counter_id': 'M55125C05509'}
NNGCC_PDUSESMODREQ_EC_RECD_2 = {'gnb_id': 2, 'dic_path': _ho_path52, 'counter_id': 'M55125C05509'}

SFE_case_004 = [
    NNGCC_PDU_SES_STP_RESP_EC_SENT_1, NNGCC_PDU_SES_STP_RESP_EC_SENT_2, NNGCC_PDU_SES_STP_REQ_EC_RECD_1,
    NNGCC_PDU_SES_STP_REQ_EC_RECD_2, NNGCC_PDUSESMODREQ_EC_RECD_1, NNGCC_PDUSESMODREQ_EC_RECD_2
]

counter_SFE_case_004 = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SFE_case_004]

NR_RRC_RELEASE_REDIR_EC_LTE = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55124C04002'}
NNGCC_UE_CTXT_STP_REQ_EF_RECD = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55125C03001'}
NNGCC_UE_CTXT_STP_RESP_EF_SENT = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55125C03002'}
NNGCC_UE_CTXT_MOD_RESP_EF_SENT = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55125C03008'}
NNGCC_UE_CTXT_MOD_REQ_EF_RECD = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55125C03007'}
NRRCC_RRC_STPREQ_EMERGENCY = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55124C01004'}

SFE_case_005 = [
    NR_RRC_RELEASE_REDIR_EC_LTE, NNGCC_UE_CTXT_STP_REQ_EF_RECD, NNGCC_UE_CTXT_STP_RESP_EF_SENT,
    NNGCC_UE_CTXT_MOD_RESP_EF_SENT, NNGCC_UE_CTXT_MOD_REQ_EF_RECD, NRRCC_RRC_STPREQ_EMERGENCY
]

counter_SFE_case_005 = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SFE_case_005]

NRRCC_ROHC_DRB_CTX_CMP_RECD = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55124C06002'}
NRRCC_ROHC_DRB_CTX_REQ_SENT = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55124C06001'}
NE1CS_ROHC_DRB_CTX_RESP_RECD = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55135C01002'}
NE1CS_ROHC_DRB_CTX_REQ_SENT = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55135C01001'}
UL_VOL_ROHC_DECOMP_HEADER = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55320C19004'}
UL_VOL_RX_SA_QOS_GRP_01 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55319C16001'}
NRRCC_ROHC_DRB_CTX_CMP_RECD_02 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55124C06002'}
NRRCC_ROHC_DRB_CTX_REQ_SENT_02 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55124C06001'}
NE1CS_ROHC_DRB_CTX_RESP_RECD_02 = {'gnb_id': 2, 'dic_path': _ho_path22, 'counter_id': 'M55135C01002'}
NE1CS_ROHC_DRB_CTX_REQ_SENT_02 = {'gnb_id': 2, 'dic_path': _ho_path22, 'counter_id': 'M55135C01001'}
UL_VOL_ROHC_DECOMP_HEADER_02 = {'gnb_id': 2, 'dic_path': _ho_path32, 'counter_id': 'M55320C19004'}
UL_VOL_RX_SA_QOS_GRP_01_02 = {'gnb_id': 2, 'dic_path': _ho_path42, 'counter_id': 'M55319C16001'}

SFE_case_006 = [
    NRRCC_ROHC_DRB_CTX_CMP_RECD, NRRCC_ROHC_DRB_CTX_REQ_SENT, NE1CS_ROHC_DRB_CTX_RESP_RECD,
    NE1CS_ROHC_DRB_CTX_REQ_SENT, UL_VOL_ROHC_DECOMP_HEADER, UL_VOL_RX_SA_QOS_GRP_01,
    NRRCC_ROHC_DRB_CTX_CMP_RECD_02, NRRCC_ROHC_DRB_CTX_REQ_SENT_02, NE1CS_ROHC_DRB_CTX_RESP_RECD_02,
    NE1CS_ROHC_DRB_CTX_REQ_SENT_02, UL_VOL_ROHC_DECOMP_HEADER_02, UL_VOL_RX_SA_QOS_GRP_01_02
]

counter_SFE_case_006 = \
        ['GNB{}/{}/{}'.format(i['gnb_id'], i['dic_path'], i['counter_id']) for i in SFE_case_006]

AMOUNT_OF_CELLS = 1
