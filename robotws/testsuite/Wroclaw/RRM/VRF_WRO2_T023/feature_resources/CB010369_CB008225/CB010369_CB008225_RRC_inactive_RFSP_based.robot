*** Settings ***
Documentation  :copyright: Nokia
...  :authors: Wojciech Peciak
...  :contact: wojciech.peciak@nokia.com

Resource  ./resources/CB010369_CB008225_resources.robot

*** Variables ***
${NR_CELL_ID_ORIGIN}                                # ID of tested NR cell
${NR_CELL_ID_TARGET}                                # ID of NR cell to which HO is performed
${UE_ID}                                            # ID of UE from EGATE configuration file
${NAMESPACE}                                        # vDU namespace used for collecting Cplane logs
${GNB_VCU_TCPDUMP_ALIAS}=  default_F1_E1_RRC        # tshark alias of capture from CPIF pod on vCU
${RANAC_TARGET_CELL}                                # RanAC ID of HO target cell
${PLMN_ID}                                          # MO ID of PLMN associated with cells
${TAC}                                              # TAC value associated with cells

*** Keywords ***
TC__CB010369-B_Successful_transition_of_UE_from_RRC_Connected_to_RRC_Inactive_state_due_to_expiration_of_RFSP_Inactivity_timer_IWK_with_CB008225

    Set Tags  CA-RRM  AUTHOR-wojciech.peciak@nokia.com  MAINTAINER-wojciech.peciak@nokia.com
    ...  PHASE-CRT  SW-SBTS25R2  GROUP_IN_CHARGE-VRF_2_WRO_2

    Step 1: Attach Ue And Establish Pdu Session
    Step 2: Verify Rfsp And RfspRrcInactInactivityTimer Sent To Ue
    Step 3: Perform InterFreq Handover UE To Second Cell
    Step 4: Verify Expiration Of Timer Causing Transfer To RRC_Inactive


Preconditions
    Log  \n==== Preconditions ====  console=True

    Create Global Variables

    Prepare vCU Delta Scfs For CB010369_CB008225 Activate And Deactivate
    Prepare vDU Delta Scfs For CB010369_CB008225 Activate And Deactivate
    Wait For Target Cell State Due To Power Saving  expected_state=disabled
    Set Test Variable  ${PARAMETERS_CHANGED}  True
    Toggle CB010369 On Vcu And Vdu  state=Activate
    Save SCF VCU  vCU_SCF_after_commissioning.xml
    Save SCF VDU  vDU_SCF_after_commissioning.xml

    Verify Preconditions For CB010369 TC On VCU

    Configure AMF On Wts
    Wait For Target Cell State Due To Power Saving  expected_state=enabled

    [Teardown]  Run Keywords  Run Keyword And Ignore Error  vcu.Disconnect
    ...  AND  Run Keyword And Ignore Error  vdu.Disconnect


Step 1: Attach Ue And Establish Pdu Session
    Log  \n==== Step 1: Attach UE and establish PDU session ====  console=True

    Attach Ue  ue_id=${UE_ID}  cell=${NR_CELL_ID_ORIGIN}  enb=2
    Establish Pdu Session  ue_id=${UE_ID}  pdu_id=1  nwslice=1  gw_id=1

    Log  \nUE${UE_ID} attached to cell ${NR_CELL_ID_ORIGIN}.  console=True
    Execute EGATE Command  cmd=ue_disp id=${UE_ID}
    Execute EGATE Command  cmd=ue_meas_cfg_disp id=${UE_ID}

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'
    ...  Run Keywords  Stop Data Transfer For Simulated UE
    ...  AND  Stop Wireshark Logs


Step 2: Verify Rfsp And RfspRrcInactInactivityTimer Sent To UE
    Log  \n==== Step 2: Verify rfsp and rfspRrcInactInactivityTimer Sent To UE ====  console=True

    ${filter_rfspRrcInactInactivityTimer_set} =  Set Variable
    ...  e1ap.BearerContextSetupRequest_element && e1ap.Inactivity_Timer == ${RFSP_RRC_INACTINACTIVITY_TIMER}
    Verify Tshark For Single Message
    ...  alias=${GNB_VCU_TCPDUMP_ALIAS}
    ...  packet_filter=${filter_rfspRrcInactInactivityTimer_set}
    ...  pcap_file_path=${LOG_PATH}/tshark/gnb_F1_E1_RRC.pcap

    ${filter_RFSP_act_AMF}=  Set Variable
    ...  ngap.InitialContextSetupRequest_element && ngap.IndexToRFSP == ${INDEX_TO_RFSP}
    Verify Tshark For Single Message
    ...  alias=${GNB_VCU_TCPDUMP_ALIAS}
    ...  packet_filter=${filter_RFSP_act_AMF}
    ...  pcap_file_path=${LOG_PATH}/tshark/gnb_F1_E1_RRC.pcap


Step 3: Perform InterFreq Handover UE To Second Cell
    Log  \n==== Step 3: Perform InterFreq Handover UE To Second Cell ====  console=True

    ${arfcnSsbPbch_cell_2}=  Get Target Cell Parameter  arfcnSsbPbch
    ${physcell_id_2}=  Get Target Cell Parameter  physCellId
    Perform HO Meas Type A3  ue=${UE_ID}  tgt_phycell_id=${physcell_id_2}  tgt_cell_ssb_frequency=${arfcnSsbPbch_cell_2}
    Wait And Verify UE Transfer To RRC_Inactive At Ue And Gnb Level


Step 4: Verify Expiration Of Timer Causing Transfer To RRC_Inactive
    Log  \n==== Step 4: Verify Expiration Of Timer Causing Transfer To RRC_Inactive ====  console=True

    ${time_elapsed}=  Measure Time For The Transition To RRC_Inactive
    ${result}=   Evaluate   ${RFSP_RRC_INACTINACTIVITY_TIMER} - 10 <= ${time_elapsed} <= ${RFSP_RRC_INACTINACTIVITY_TIMER} + 10
    Should Be True  ${result}
    ...  msg=Measured time value ${time_elapsed}s is different than expected (${RFSP_RRC_INACTINACTIVITY_TIMER}s +-10s).


Create Global Variables
    Log  Setting global variables...  console=True
    Set Test Variable  ${PARAMETERS_CHANGED}  False

    Get MRBTS ID From VCU
    Get MRBTS ID From VDU
    Get NRBTS ID From VDU

    Set Test Variable  ${NRBTS_DIST_NAME}  MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}
    Set Test Variable  ${NRHOIF_DIST_NAME}  MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID_ORIGIN}/NRHOIF-1
    Set Test Variable  ${ORIGIN_CELL_NRPGRP_DIST_NAME}  MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NR_CELL_ID_ORIGIN}
    Set Test Variable  ${TARGET_CELL_NRPGRP_DIST_NAME}  MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NR_CELL_ID_TARGET}
    Set Test Variable  ${FILTER_RRC_INACTIVE_VERF_UE_LVL}  nr-rrc.suspendConfig_element && nr-rrc.RAN_AreaCode == ${RANAC_TARGET_CELL}

    ${index_to_rfsp} =  Get VCU Simple Parameter Value
    ...  dist_name=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRRFSP_PROFILE-1
    ...  param_name=rfsp
    Set Test Variable  ${INDEX_TO_RFSP}  ${index_to_rfsp}

    ${rfspRrcInactInactivityTimer} =  Get VCU Simple Parameter Value
    ...  dist_name=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRRFSP_PROFILE-1
    ...  param_name=rfspRrcInactInactivityTimer
    Set Test Variable  ${RFSP_RRC_INACTINACTIVITY_TIMER}  ${rfspRrcInactInactivityTimer}


TC Setup
    Cloud BTS Test Setup  ignored_alarms_vcu=${IGNORED_ALARMS_VCU}  ignored_alarms_vdu=${IGNORED_ALARMS_VDU}
    Save SCF VCU  vCU_SCF_original.xml
    Save SCF VDU  vDU_SCF_original.xml
    Preconditions


TC Teardown
    [Timeout]  60 min
    Log  \n === TC Teardown ===   console=True
    Ue Teardown
    Reset AMF On WTS To Default
    Run Keyword If  ${PARAMETERS_CHANGED}  Toggle CB010369 On Vcu And Vdu  state=Deactivate
    Wait For Target Cell State Due To Power Saving  expected_state=disabled
    Cloud BTS Test Teardown
