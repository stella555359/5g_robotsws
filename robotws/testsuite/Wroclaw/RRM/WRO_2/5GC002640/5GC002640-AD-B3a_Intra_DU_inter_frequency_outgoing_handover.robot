*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia

Resource    ../keywords/tshark_verifying.robot
Resource    ../5GC001167/feature_keywords.robot
Variables   ../5GC001167/feature_variables.py
Resource     ../keywords/logging.robot

Suite Teardown    Stop Default Logging
    ...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${scfc}=                                          scfc_AD_B3a.xml

${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=               f1ap.SCell_ToBeSetupMod_List == 2
${F1AP_SCELL_TO_ADD_MOD_LIST}=                    nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 51 &&
                                             ...  nr-rrc.physCellId == 55
${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}=      ngap.pDUSessionResourceModifyResponseTransfer &&
                                             ...  ngap.qosFlowIdentifier == 1

${HO_WITH_2_SCELLS_TO_BE_RELEASED}=               f1ap.SCell_ToBeRemoved_List == 2
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
5GC002640-AD-B3a_Intra_DU_inter_frequency_outgoing_handover
    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_AD_B3a.xml
      ...         AND          With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
      ...         AND          With Gnb Configuration    commissioning=${scfc}
      ...         AND          Wait For Testline Icmp Echo Replies And Ssh Services
      ...         AND          Start Default Logging    output_dirpath=${OUTPUT_DIR}
      ...         AND          Reach Onair    lua_cfg=${CURDIR}/config/basic_2640_3CC_non_contigous_TDD_Cells.cfg

    Register UE And Start Data Traffic    ue_id=1    cell_id=1
    Verify ICS On NGAP
    Verify Successful 3CC FFT On NGAP And F1AP Messages
    Start Data Traffic And Verify DL Traffic Scheduling On All SCell
    Perform Intra gNB Handover To Cell 4    ue_id=1    a2_meas_id=1    a3_meas_id=5    phycell_id=53   a3_rsrp=70
    Verify If SCells Are Released After HO
    [Teardown]    Run Keywords      Release Pdu Session    ue_id=1    pdu_id=1
        ...            AND          Deregister Ue    ue_id=1

*** Keywords ***
Perform Intra gNB Handover To Cell 4
    [Arguments]    ${ue_id}    ${a2_meas_id}=1    ${a3_meas_id}=5    ${phycell_id}=53    ${a3_rsrp}=70
    Send A2 Measurement To Reconfigure A3    ue_id=${ue_id}    a2_meas_id=${a2_meas_id}
    Send A3 Measurement To Perform UE Handover    ue_id=${ue_id}    phycell_id=${phycell_id}    a3_meas_id=${a3_meas_id}    a3_rsrp=${a3_rsrp}

Register UE And Start Data Traffic
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}=1    ${gw_id}=1
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue    ue_id=${ue_id}    cell=${cell_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=1

Verify Successful 3CC FFT On NGAP And F1AP Messages
    [Arguments]    ${number_of_messages}=1
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}   number_of_messages=${number_of_messages}

Start Data Traffic And Verify DL Traffic Scheduling On All SCell
    [Arguments]    ${ue_id}=1    ${qfi}=1   ${scell}=0-3
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} mbps=170 dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} mbps=50 dir=ul
    Wait For Traffic To Stabilize
    Execute Egate Command    cmd=ue_stats_nr id=${ue_id} scell=${scell}

Verify If SCells Are Released After HO
    Verify Tcpdump Log      packet_filter=${HO_WITH_2_SCELLS_TO_BE_RELEASED}    number_of_messages=1
