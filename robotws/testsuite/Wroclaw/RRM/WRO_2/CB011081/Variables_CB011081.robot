*** Variables ***
${BASIC_SETUP}=       ${CURDIR}/config/wts_basic.cfg
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${SOURCE_CELL_ID}=    3
${GNB_ID}=      2
${PDU_ID}=    3
${GW_ID}=    3
${UE_ID_6CC}=    3
${A1_MEAS_ID}=    1
${iphy_booloo}=    ${CURDIR}/config/iphy_booloo.xml

# AB12
${scfc_AB12}=    CB011081-AB12.xml
${first_PDUModifyRequest}=
...    ngap.qosFlowIdentifier == 2 &&
...    ngap.fiveQI == 5 &&
...    ngap.PDUSessionResourceModifyListModReq == 1 &&
...    ngap.pDUSessionID == 3

${second_PDUModifyRequest}=
...    ngap.qosFlowIdentifier == 3 &&
...    ngap.pDUSessionID == 3 &&
...    ngap.fiveQI == 1 &&
...    ngap.PDUSessionResourceModifyListModReq == 1

${drx_profile_1_configuration}=
...    nr-rrc.drx_onDurationTimer == 1 &&
...    nr-rrc.milliSeconds == 7 &&
...    nr-rrc.drx_InactivityTimer == 14 &&
...    nr-rrc.drx_HARQ_RTT_TimerDL == 0 &&
...    nr-rrc.drx_HARQ_RTT_TimerUL == 0 &&
...    nr-rrc.drx_RetransmissionTimerDL == 0 &&
...    nr-rrc.drx_RetransmissionTimerUL == 0 &&
...    nr-rrc.drx_LongCycleStartOffset == 9 &&
...    nr-rrc.ms160 == 0 &&
...    nr-rrc.drx_SlotOffset == 0 &&
...    nr-rrc.rrc_TransactionIdentifier == 3

${drx_profile_2_configuration}=
...    nr-rrc.drx_onDurationTimer == 1 &&
...    nr-rrc.milliSeconds == 5 &&
...    nr-rrc.drx_InactivityTimer == 4 &&
...    nr-rrc.drx_HARQ_RTT_TimerDL == 0 &&
...    nr-rrc.drx_HARQ_RTT_TimerUL == 0 &&
...    nr-rrc.drx_RetransmissionTimerDL == 0 &&
...    nr-rrc.drx_RetransmissionTimerUL == 0 &&
...    nr-rrc.drx_LongCycleStartOffset == 3 &&
...    nr-rrc.ms40 == 0 &&
...    nr-rrc.drx_SlotOffset == 0

#AB13
${scfc_ab13}=              CB011081-AB13.xml
${AB13_setup}=       ${CURDIR}/config/wts_a6_config.cfg
${A6_meas_id}=   2
${iphy_booloo_AB13}=    ${CURDIR}/config/iphy_booloo_a6.xml

${Veryfication_A6_measurement}=
...    nr-rrc.measId == 2 &&
...    nr-rrc.physCellId == 53 &&
...    nr-rrc.servCellId == 1 &&
...    nr-rrc.physCellId == 51 &&
...    nr-rrc.servCellId == 2 &&
...    nr-rrc.physCellId == 54 &&
...    nr-rrc.servCellId == 3 &&
...    nr-rrc.physCellId == 55 &&
...    nr-rrc.servCellId == 4 &&
...    nr-rrc.physCellId == 56 &&
...    nr-rrc.servCellId == 5 &&
...    nr-rrc.physCellId == 57 &&
...    nr-rrc.measResultListNR == 1 &&
...    nr-rrc.physCellId == 52

${Veryfication_scell_swap}=
...    nr-rrc.measId == 2 &&
...    nr-rrc.sCellToAddModList == 1 &&
...    nr-rrc.sCellIndex == 6 &&
...    nr-rrc.physCellId == 52 &&
...    nr-rrc.sCellToReleaseList == 1 &&
...    nr-rrc.SCellIndex == 1

${A6_cmd}=
...  id=${UE_ID_6CC} meas_id=${A6_meas_id} event=A6 srsrp_nr=70 srsrq_nr=70 scell=1 scell_rsrp=20 scell_rsrq=20
...  scell=2 scell_rsrp=20 scell_rsrq=20
...  scell=3 scell_rsrp=20 scell_rsrq=20
...  scell=4 scell_rsrp=20 scell_rsrq=20
...  scell=5 scell_rsrp=20 scell_rsrq=20
...  phycell_id=52 nrsrp_nr=90 nrsrq_nr=95

${LOCAL_MOID_PCELL}=          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
@{COUNTER_IDs_PCELL_P1}=    M55118C10501    M55138C03507
@{COUNTER_NAMEs_PCELL_P1}=    SCELL_SWAP_1_ATT_SA    GNB_SCELL_5_ADMI_SUCC_SA

# AB14_AB18
${scfc_ab14_ab18}=              CB011081-AB14_AB18.xml

${rrc_resume_element}=
...     nr-rrc.rrcResume_element &&
...     nr-rrc.measObjectId == 1 &&
...     nr-rrc.measObjectToAddModList == 1 &&
...     nr-rrc.freqBandIndicatorNR == 66 &&
...     nr-rrc.ssbFrequency == 438050 &&
...     nr-rrc.reportConfigToAddModList == 1 &&
...     nr-rrc.reportConfigId == 1 &&
...     nr-rrc.a1_Threshold == 0 &&
...     nr-rrc.measIdToAddModList == 1 &&
...     nr-rrc.measId == 1 &&
...     nr-rrc.measObjectId == 1 &&
...     nr-rrc.reportConfigId == 1

${rrc_resume_complete_element}=
...    nr-rrc.rrcResumeComplete_element

${A2_meas_element}=
...     nr-rrc.servCellId == 2 &&
...     nr-rrc.physCellId == 54 &&
...     nr-rrc.measId == 3 &&
...     nr-rrc.physCellId == 53

${cell_release_after_A2}=
...     nr-rrc.sCellToReleaseList == 1 &&
...     nr-rrc.SCellIndex == 2

${cmd_ue_resume_configuration}=
...  amf_ue_ics_param id=1 ue=${UE_ID_6CC} core_network_assistance_info=on ue_identity_index_value=3
...  ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=100
