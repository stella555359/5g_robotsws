from collections import namedtuple

Counter_update_time_interval = '5min'
searchedPhrase = namedtuple('searchedPhrase', 'value')
RAmsg2 = searchedPhrase('MSG2')
wts_rrcsetuprequest = searchedPhrase('rrcSetupRequest')
cprt_RRC_Setup_Request = searchedPhrase('Received RrcSetupRequest in RrcUlCcchMessage')
L2LO_UserCcchDataReceivedInd = searchedPhrase('LoUser_CcchDataReceivedInd')
cprt_LoUser_CcchDataReceivedInd = searchedPhrase('CcchDataReceiveInd')

LoUser_CcchDataReceivedInd = searchedPhrase('LoUser_CcchDataReceivedInd')
PsUser_USerSetupResp = searchedPhrase('HandlePsUserUserSetupResp::on_entry Action:\
 Sending itf::l2::lo::user::UserSetupReq')
PsUser_USerSetupReq = searchedPhrase('HandlePsUserUserSetupResp::handle_event: itf::l2::lo::user::UserSetupResp - OK')
LoUser_USerSetupReq = searchedPhrase('UserSetupReq')
LoUser_USerSetupResp = searchedPhrase('l2::lo::user::UserSetupResp - OK')
HIUserDu_BearerSetupReq = searchedPhrase('Sending HiUserDuBearerSetupReq')
HIUserDu_BearerSetupResp = searchedPhrase('HiUserDuBearerSetupResp')
F1AP_Intial_UL_RRC_Message_transfer = searchedPhrase('InitialUlRrcMessageTransfer to CU')
F1AP_DlRrcMessageTransfer = searchedPhrase('DlRrcMessageTransfer from CU')

CpUeRecvInitialRRCMsg = searchedPhrase('CpUeRecvInitialRRCMsg')
CpCellRrcResourceReq = searchedPhrase('RrcResourceReq')
CpCell_RrcResourceResp = searchedPhrase('RrcResourceResp')
SrbUser_BearerSetupReq = searchedPhrase('BearerSetupReq')
SrbUser_BearerSetupResp = searchedPhrase('BearerSetupResp')
CpIfSendToDu = searchedPhrase('CpIfSendToDu')
CpIfReceiveFromDu = searchedPhrase('CpIfReceiveFromDu')
DlRRCMessageTransfer = searchedPhrase('DlRrcMessageTransfer')

LoUser_CcchDataSendReq = searchedPhrase('Received LoUser_CcchDataSendReq')
ContentionResolution = searchedPhrase('Contention resolution successful')
UEConnected = searchedPhrase('UE1: RrcState: NR CONNECTED')
HiSgnlDu_SrbReceiveInd = searchedPhrase('SrbReceiveInd')
UlRrcMessageTransfer = searchedPhrase('UlRrcMessageTransfer')
InitialUEMessageSuccess = searchedPhrase('Initial UE Message Success')
SrbSgnlUlPduReceiveInd = searchedPhrase('srb_sgnl::UlPduReceiveInd')
SrbSgnlUlSduReceiveInd = searchedPhrase('srb_sgnl::UlSduReceiveInd')
CpIfSendToCore = searchedPhrase('CpIfSendToCore')

CounterValue = namedtuple('CounterValue', 'before_ue_attach after_ue_attach')
DL_MAC_SDU_CCCH_SRB0_value = CounterValue('0', '1')
UL_MAC_SDU_VOL_CCCH_SRB0_value = CounterValue('0', '6')
UL_MAC_SDU_CCCH_SRB0_value = CounterValue('0', '1')
RA_MSG3_RECEP_value = CounterValue('0', '1')
RA_COMP_CONT_A_PRMBL_value = CounterValue('0', '1')
RA_ATT_CONT_A_PRMBL_SSB_00_value = CounterValue('0', '1')
DL_MAC_SDU_VOL_CCCH_SRB0_value = CounterValue('0', '323')
NNGCC_INIT_UE_MSG_SENT_value = CounterValue('0', '1')
NRRCC_RRC_STPREQ_MO_SIGNALLING_value = CounterValue('0', '1')
NRRCD_RRC_STPREQ_MO_SIGNALLING_value = CounterValue('0', '1')
NRRCC_RRC_STPREQ_MO_DATA_value = CounterValue('0', '1')
NRRCD_RRC_STPREQ_MO_DATA_value = CounterValue('0', '1')
NRRCC_RRC_STPREQ_MT_ACCESS_value = CounterValue('0', '1')
NRRCD_RRC_STPREQ_MT_ACCESS_value = CounterValue('0', '1')
NRRCC_RRC_STPREQ_EMERGENCY_value = CounterValue('0', '1')
NRRCD_RRC_STPREQ_EMERGENCY_value = CounterValue('0', '1')
NRRCC_RRC_STPREQ_HIPRIO_ACCESS_value = CounterValue('0', '1')
NRRCD_RRC_STPREQ_HIPRIO_ACCESS_value = CounterValue('0', '1')
NRRCC_RRC_STPREQ_MO_VOICECALL_value = CounterValue('0', '1')
NRRCD_RRC_STPREQ_MO_VOICECALL_value = CounterValue('0', '1')
UL_RLC_PDU_RX_L_SRB1_value = CounterValue('0', '1')
UL_MAC_SDU_DCCH_SRB1_value = CounterValue('0', '1')
UL_RLC_SDU_RX_H_SRB1_value = CounterValue('0', '1')
UL_RLC_COML_RX_H_SRB1_value = CounterValue('0', '1')
UL_RLC_PDU_RETX_H_SRB1_value = CounterValue('0', '0')
UL_PDCP_SDU_RX_SRB1_value = CounterValue('0', '1')
UL_PDCP_VOL_RX_SRB1_value = CounterValue('0', '1')

UserPlaneCounters = ["DL_MAC_SDU_CCCH_SRB0", "UL_MAC_SDU_CCCH_SRB0", "RA_MSG3_RECEP",
                     "RA_COMP_CONT_A_PRMBL", "DL_MAC_SDU_VOL_CCCH_SRB0", "UL_MAC_SDU_VOL_CCCH_SRB0"]

ControlplaneCounters = ["NNGCC_INIT_UE_MSG_SENT", "NRRCC_RRC_STPREQ_MO_SIGNALLING", "NRRCD_RRC_STPREQ_MO_SIGNALLING",
                        "NRRCC_RRC_STPREQ_MO_DATA", "NRRCD_RRC_STPREQ_MO_DATA", "NRRCC_RRC_STPREQ_MT_ACCESS",
                        "NRRCD_RRC_STPREQ_MT_ACCESS", "NRRCC_RRC_STPREQ_EMERGENCY", "NRRCD_RRC_STPREQ_EMERGENCY",
                        "NRRCC_RRC_STPREQ_HIPRIO_ACCESS", "NRRCD_RRC_STPREQ_HIPRIO_ACCESS",
                        "NRRCC_RRC_STPREQ_MO_VOICECALL", "NRRCD_RRC_STPREQ_MO_VOICECALL"]
MO_SIGNALLING_CplaneCounters = ["NNGCC_INIT_UE_MSG_SENT", "NRRCC_RRC_STPREQ_MO_SIGNALLING",
                                "NRRCD_RRC_STPREQ_MO_SIGNALLING"]
MO_DATA_CplaneCounters = ["NNGCC_INIT_UE_MSG_SENT", "NRRCC_RRC_STPREQ_MO_DATA", "NRRCD_RRC_STPREQ_MO_DATA"]
MT_ACCESS_CplaneCounters = ["NNGCC_INIT_UE_MSG_SENT", "NRRCC_RRC_STPREQ_MT_ACCESS", "NRRCD_RRC_STPREQ_MT_ACCESS"]
EMERGENCY_CplaneCounters = ["NNGCC_INIT_UE_MSG_SENT", "NRRCC_RRC_STPREQ_EMERGENCY", "NRRCD_RRC_STPREQ_EMERGENCY"]
MO_VOICECALL_CplaneCounters = ["NNGCC_INIT_UE_MSG_SENT", "NRRCC_RRC_STPREQ_MO_VOICECALL",
                               "NRRCD_RRC_STPREQ_MO_VOICECALL"]
HIGH_PRIORITY_ACCESS_CplaneCounters = ["NNGCC_INIT_UE_MSG_SENT", "NRRCC_RRC_STPREQ_HIPRIO_ACCESS",
                                       "NRRCD_RRC_STPREQ_HIPRIO_ACCESS"]

callTypeCommand = namedtuple('callTypeCommand', 'value')
MO_VOICECALL = callTypeCommand('ue_nr_rrc_setup_param establishment_cause=mo-VoiceCall id=1')
HIPRIO_ACCESS = callTypeCommand('ue_nr_rrc_setup_param establishment_cause=highPriorityAccess id=1')
EMERGENCY = callTypeCommand('ue_nr_rrc_setup_param establishment_cause=emergency id=1')
MT_ACCESS = callTypeCommand('ue_nr_rrc_setup_param establishment_cause=mt-Access id=1')
MO_DATA = callTypeCommand('ue_nr_rrc_setup_param establishment_cause=mo-Data id=1')
MO_SIGNALLING = callTypeCommand('ue_nr_rrc_setup_param establishment_cause=mo-Signalling id=1')

MessageName = namedtuple('MessageName', 'filter_name filter_expression message_type message_info')
InitialULRRCMessageTransfer = MessageName('InitialULRRCMessageTransfer', '(f1ap) && (f1ap.procedureCode == 11)',
                                          'ipv4_message', '')
L2_HI_DU_User_BearerSetupReq = MessageName('L2_HI_DU_User_BearerSetupReq', 'itf_l2_hi_du_user_bearersetupreq',
                                           'ipv4_message', '')
RRC_Setup_Complete = MessageName('RRC Setup Complete',
                                 '(f1ap.procedureCode == 13) && (f1ap.GNB_DU_UE_F1AP_ID == 1)',
                                 'ipv4_message', '')
RRC_Setup_Request = MessageName('RRC Setup Request',
                                '(f1ap) && (f1ap.procedureCode == 11)',
                                'ipv4_message', '')
RRC_Reject = MessageName('RRC_Reject',
                         '((f1ap.procedureCode == 6) && (f1ap.id == 0)) && (f1ap.GNB_DU_UE_F1AP_ID == 1)',
                         'ipv4_message', '')
RRC_Reject_cause_radioNW_unspecified = MessageName('RRC_Reject',
                                                   '(f1ap) && (f1ap.radioNetwork == 0)',
                                                   'ipv4_message', '')
RRC_Setup = MessageName('RRC_Setup',
                        '(f1ap.procedureCode == 12) && (nr-rrc.criticalExtensions == 0)',
                        'ipv4_message', '')
dldata_pdschpayloadtbsendreq1 = MessageName('dldata_pdschpayloadtbsendreq',
                                            '(dldata_pdschpayloadtbsendreq)\
                                             && (DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.rnti == 0x003d)',
                                            'bip_message', '')
dldata_pdschpayloadtbsendreq2 = MessageName('dldata_pdschpayloadtbsendreq',
                                            '(dldata_pdschpayloadtbsendreq)\
                                            && (DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.rnti == 0x003d)',
                                            'frame_two_message', '')
F1_SetupRequest = MessageName('F1_SetupRequest', 'f1ap.F1SetupRequest_element', 'MIB_message', '')
RRC_SETUP_REQUEST_presence = MessageName('RRC_SETUP_REQUEST_presence', 'nr-rrc.rrcSetupRequest_element', '', '')
RRC_SETUP_presence = MessageName('RRC_SETUP_presence', 'nr-rrc.rrcSetup_element', '', '')
RRC_SETUP_COMPLETE_presence = MessageName('RRC_SETUP_COMPLETE_presence', 'nr-rrc.rrcSetupComplete_element', '', '')
DL_RRC_Message_Transfer_presence = MessageName('DL_RRC_Message_Transfer_presence', 'f1ap.DLRRCMessageTransfer_element',
                                               '', '')
Initial_UL_RRC_Message_Transfer_presence = MessageName('Initial_UL_RRC_Message_Transfer_presence',
                                                       'f1ap.InitialULRRCMessageTransfer_element', '', '')
UL_RRC_Message_Transfer_presence = MessageName('UL_RRC_Message_Transfer_presence',
                                               'f1ap.ULRRCMessageTransfer_element', '', '')
Initial_UE_Message_presence = MessageName('Initial_UE_Message_presence', 'ngap.InitialUEMessage_element', '', '')
UE_Context_Release_Complete = MessageName('UEContextReleaseComplete',
                                          '(f1ap.procedureCode == 6) && (f1ap.F1AP_PDU == 1)',
                                          'ipv4_message', '')
RRC_SETUP_REQUEST_Without_DUtoCU_RRC_container = MessageName('RRC Setup Request',
                                                             '(f1ap.procedureCode == 11) && !(f1ap.id == 128)',
                                                             'ipv4_message', '')

messageType = namedtuple('messageType', 'field name value path')
ipv4_message = messageType('ip.version', 'show', '4', 'ip.version')
bip_message = messageType('bip', 'showname', 'BIP header dispatcher: Event Chaining', '')
frame_two_message = messageType('frame.number', 'show', '2', '')
MIB_message = messageType('nr-rrc.MIB_element', 'showname', 'MIB', '')

MessageField = namedtuple('MessageField', 'message_name field_name attrib_name')
ULpollPDU = MessageField('InitialULRRCMessageTransfer', 'nr-rrc.pollPDU', 'showname')
ULTPollRetr = MessageField('InitialULRRCMessageTransfer', 'nr-rrc.t_PollRetransmit', 'showname')
ULPollByte = MessageField('InitialULRRCMessageTransfer', 'nr-rrc.pollByte', 'showname')
ULMaxRetxThreshold = MessageField('InitialULRRCMessageTransfer', 'nr-rrc.maxRetxThreshold', 'showname')
DLTReassembly = MessageField('InitialULRRCMessageTransfer', 'nr-rrc.t_Reassembly', 'showname')
DLTProhib = MessageField('InitialULRRCMessageTransfer', 'nr-rrc.t_StatusProhibit', 'showname')
DLPollPDU = MessageField('L2_HI_DU_User_BearerSetupReq', 'nr-rrc.pollPDU', 'showname')
Phr_ProhibitTimer = MessageField('InitialULRRCMessageTransfer', 'nr-rrc.phr_ProhibitTimer', 'showname')
Phr_PeriodicTimer = MessageField('InitialULRRCMessageTransfer', 'nr-rrc.phr_PeriodicTimer', 'showname')
PhrTxPowerFactorChange = MessageField('InitialULRRCMessageTransfer', 'nr-rrc.phr_Tx_PowerFactorChange', 'showname')
msg5_time_stamp = MessageField('InitialULRRCMessageTransfer', 'timestamp', 'value')
RRC_Reject_timestamp = MessageField('RRC_Reject', 'timestamp', 'value')
RRC_Setup_Complete_timestamp = MessageField('RRC_Setup_Complete', 'timestamp', 'value')
RRC_setup_request = MessageField('RRC_Setup_Request', 'nr-rrc.rrcSetupRequest_element', 'showname')
RRC_Reject_wait_time = MessageField('RRC_Reject', 'nr-rrc.waitTime', 'show')
MSG4_frame_one = MessageField('dldata_pdschpayloadtbsendreq1', 'frame.number', 'show')
MSG4_frame_two = MessageField('dldata_pdschpayloadtbsendreq2', 'frame.number', 'show')
MIB_CellBarred = MessageField('F1_SetupRequest', 'nr-rrc.cellBarred', 'showname')

FlagName = namedtuple('FlagName', 'name file_path file_name')
rdRachSendMsg4Margin = FlagName('0x580038', '/ffs/run/', 'swconfig.txt')

vendorParameter = namedtuple('vendorParameter', 'name x_path new_value')
dlPollPDU = vendorParameter('dlPollPDU', 'cmData/managedObject/list[12]/item/p[3]', 'p64')
dlPollByte = vendorParameter('dlPollByte', 'cmData/managedObject/list[12]/item/p[2]', 'kB500')
dlTPollRetr = vendorParameter('dlTPollRetr', 'cmData/managedObject/list[12]/item/p[4]', 'ms50')
ulTProhib = vendorParameter('ulTProhib', 'cmData/managedObject/list[12]/item/p[11]', 'ms5')
ulTReassembly = vendorParameter('ulTReassembly', 'cmData/managedObject/list[12]/item/p[12]', 'ms40')
dlMaxRetxThreshold = vendorParameter('dlMaxRetxThreshold', 'cmData/managedObject/list[12]/item/p[1]', 't6')

ulTPollRetr = vendorParameter('ulTPollRetr', 'cmData/managedObject/list[12]/item/p[10]', 'ms50')
ulPollPDU = vendorParameter('ulPollPDU', 'cmData/managedObject/list[12]/item/p[9]', 'p64')
ulPollByte = vendorParameter('ulPollByte', 'cmData/managedObject/list[12]/item/p[8]', 'kB500')
ulMaxRetxThreshold = vendorParameter('ulMaxRetxThreshold', 'cmData/managedObject/list[12]/item/p[7]', 't6')
dlTReassembly = vendorParameter('dlTReassembly', 'cmData/managedObject/list[12]/item/p[6]', 'ms40')
dlTProhib = vendorParameter('dlTProhib', 'cmData/managedObject/list[12]/item/p[5]', 'ms5')

webUI_parameters = {'F1AP_Initial_UL_RRC_Message_Transfer': ['tProhibitPhr', 'tPeriodicPhr', 'dlPathlossChg']}
webUI_parameters_values = {'tProhibitPhr': {'default': '0sf',
                                            'modified': '10sf'},
                           'tPeriodicPhr': {'default': '20sf',
                                            'modified': '50sf'},
                           'dlPathlossChg': {'default': '3dB',
                                             'modified': '6dB'}
                           }
vendor_parameters = {'HiUserDu_BearerSetupReq': ['dlPollPDU', 'dlPollByte', 'dlTPollRetr',
                                                 'ulTProhib', 'ulTReassembly', 'dlMaxRetxThreshold'],
                     'F1AP_Initial_UL_RRC_Message_Transfer': ['ulTPollRetr', 'ulPollPDU', 'ulPollByte',
                                                              'ulMaxRetxThreshold', 'dlTReassembly', 'dlTProhib']}
message_fields = {'HiUserDu_BearerSetupReq': ['DLPollPDU', 'DLPollByte', 'DLTPollRetr',
                                              'ULTProhib', 'ULTReassembly', 'DLMaxRetxThreshold'],
                  'F1AP_Initial_UL_RRC_Message_Transfer': ['ULTPollRetr', 'ULPollPDU', 'ULPollByte',
                                                           'ULMaxRetxThreshold', 'DLTReassembly', 'DLTProhib',
                                                           'Phr_ProhibitTimer', 'Phr_PeriodicTimer',
                                                           'PhrTxPowerFactorChange']}
expected_field_value = {'ULTPollRetr': {'default': 't-PollRetransmit: ms45 (8)',
                                        'modified': 't-PollRetransmit: ms50 (9)'},
                        'ULPollPDU': {'default': 'pollPDU: infinity (23)',
                                      'modified': 'pollPDU: p64 (4)'},
                        'ULPollByte': {'default': 'pollByte: infinity (43)',
                                       'modified': 'pollByte: kB500 (13)'},
                        'ULMaxRetxThreshold': {'default': 'maxRetxThreshold: t4 (3)',
                                               'modified': 'maxRetxThreshold: t6 (4)'},
                        'DLTReassembly': {'default': 't-Reassembly: ms35 (7)',
                                          'modified': 't-Reassembly: ms40 (8)'},
                        'DLTProhib': {'default': 't-StatusProhibit: ms0 (0)',
                                      'modified': 't-StatusProhibit: ms5 (1)'},
                        'Phr_ProhibitTimer': {'default': 'phr-ProhibitTimer: sf0 (0)',
                                              'modified': 'phr-ProhibitTimer: sf10 (1)'},
                        'Phr_PeriodicTimer': {'default': 'phr-PeriodicTimer: sf20 (1)',
                                              'modified': 'phr-PeriodicTimer: sf50 (2)'},
                        'PhrTxPowerFactorChange': {'default': 'phr-Tx-PowerFactorChange: dB3 (1)',
                                                   'modified': 'phr-Tx-PowerFactorChange: dB6 (2)'}
                        }

ExpectedFieldValue = namedtuple('ExpectedFieldValue', 'value')
Cell_is_not_barred = ExpectedFieldValue('cellBarred: notBarred (1)')
Cell_is_barred = ExpectedFieldValue('cellBarred: barred (0)')

SRB1_CplaneCounters = ["UL_RLC_PDU_RX_L_SRB1", "UL_MAC_SDU_DCCH_SRB1",
                       "UL_RLC_SDU_RX_H_SRB1", "UL_RLC_COML_RX_H_SRB1",
                       "UL_RLC_PDU_RETX_H_SRB1", "UL_PDCP_SDU_RX_SRB1"]
# 723-A
Cell_on_air_timeout_seconds = 600
Flag_5min_PM_Counter = ['0x340000 = 3']
PM_Counter_interval = '5min'
tshark_filters_723A = {
    # Checks if RRCSetupRequest is present, and if it has f1ap attribute "initial UL RRC"
    'rrc_setup_req_initial_ul_rrc': 'f1ap.InitialULRRCMessageTransfer_element && nr-rrc.rrcSetupRequest_element',
    # Checks if RRCSetup is present and if it is DL RRC type
    'rrc_setup_dl_rrc': 'f1ap.procedureCode == 12 && nr-rrc.rrcSetup_element',
    # Checks if RRC Setup Complete is present and if it is UL RRC type
    'rrc_setup_complete_ul_rrc': 'f1ap.procedureCode == 13 && nr-rrc.rrcSetupComplete_element',
    # Checks for Initial UE Message teg
    'ngap_initial_ue_message': 'ngap.InitialUEMessage_element'
}
rrc_establishment_causes = ['mo-Signalling', 'mo-VoiceCall', 'mt-Access', 'emergency', 'highPriorityAccess', 'mo-Data']

# 723-Y
phr_param_name = 'phrConfig'

nidd_param_default_value_723Y = [
    {'tProhibitPhr': '0sf',
     'tPeriodicPhr': '20sf',
     'dlPathlossChg': '3dB'}
]

nidd_param_changed_value_723Y = [
    {'tProhibitPhr': '10sf',
     'tPeriodicPhr': '50sf',
     'dlPathlossChg': '6dB'}
]

tshark_filters_723Y = {
    'tProhibitPhrOriginal': "nr-rrc.phr_ProhibitTimer == 0",
    'tPeriodicPhrOriginal': "nr-rrc.phr_PeriodicTimer == 1",
    'dlPathlossChgOriginal': "nr-rrc.phr_Tx_PowerFactorChange == 1",
    'tProhibitPhrChanged': "nr-rrc.phr_ProhibitTimer == 1",
    'tPeriodicPhrChanged': "nr-rrc.phr_PeriodicTimer == 2",
    'dlPathlossChgChanged': "nr-rrc.phr_Tx_PowerFactorChange == 2"
}

# 723-K (with reject)
rrc_establishment_causes_723_K_with_reject = [
    'mo-Signalling',
    'mo-Data',
    'mt-Access',
    'emergency',
    'highPriorityAccess',
    'mo-VoiceCall',
    'mo-VideoCall',
    'mo-Sms',
    'mps-PriorityAccess',
    'mcs-PriorityAccess',
    'spare1'
]
NRRCC_RRC_STPREJ_MO_SIGNALLING = 'M55124C01021'
NRRCC_RRC_STPREJ_MO_DATA = 'M55124C01022'
NRRCC_RRC_STPREJ_MT_ACCESS = 'M55124C01023'
NRRCC_RRC_STPREJ_EMERGENCY = 'M55124C01024'
NRRCC_RRC_STPREJ_HIPRIO_ACCESS = 'M55124C01025'
NRRCC_RRC_STPREJ_MO_VOICECALL = 'M55124C01026'
NRRCC_RRC_STPREJ_MO_VIDEOCALL = 'M55124C01027'
NRRCC_RRC_STPREJ_MO_SMS = 'M55124C01028'
NRRCC_RRC_STPREJ_MPS = 'M55124C01029'
NRRCC_RRC_STPREJ_MCS = 'M55124C01030'
