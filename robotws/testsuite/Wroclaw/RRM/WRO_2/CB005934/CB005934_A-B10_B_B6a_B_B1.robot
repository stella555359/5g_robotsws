*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Anonio Apiyo
...              :contact: antonio.apiyo@nokia.com
...              :original authors: Vira Solomashenko, jakub Magier, Palina Krasnova
...              :contact: vira.solomashenko@nokia.com, jakub.magier@nokia.com, palina.krasnova@nokia.com
...              :maintainer: Jakub Magier, Palina Krasnova
...              :contact: jakub.magier@nokia.com, palina.krasnova@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/tshark_verifying.robot
Resource     CB005934_keywords.robot
Library      ta5g_tshark
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Library      ta5g_testline_management
Library      taf.ul.ettf.setups
Library      ta5g_ue_mobility
Variables    ta5g_global_var
Variables    CB005934_messaging_filters.py
Variables    logging_policy.py

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
@{UE_IDs}=     1    10    11
@{PDU_IDs}=    1    2     3
@{GW_IDs}=     1    10    11
${PCELL_ID}=    1
${GNB_ID}=    2
${A1_MEAS_ID_TDD}=    1
${A1_MEAS_ID_FDD}=    4
${SRSRP_NR_TDD}=    75
${SRSRP_NR_FDD}=    90
&{A1_RSRP}=    Threshold=RSRP 70
@{A1_FREQUENCIES}=    389570
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${A1_MEAS_ID}=    1
${SRSRP_NR}=    90

${ue_id}=    1
${pdu_id}=    1
${gw_id}=    1
${a1_rsrp_scell_change}=    90
${scell_change_a1_meas_id}=    5

${Verification_A1_measurement}=
...  f1ap && nr-rrc.rrcReconfiguration_element &&
...  nr-rrc.measObjectToAddModList == 3 &&
...  nr-rrc.reportConfigToAddModList == 2 &&
...  nr-rrc.measIdToAddModList == 4 &&
...  nr-rrc.reportConfigToRemoveList == 1 &&
...  nr-rrc.measIdToRemoveList == 1
${rrcReconfigurationComplete}=
...  f1ap &&
...  nr-rrc.rrcReconfigurationComplete_element &&
...  nr-rrc.rrc_TransactionIdentifier == 3
${ULRRCMessageTransfer}=
...  f1ap &&
...  nr-rrc.measurementReport_element &&
...  nr-rrc.measId == 5 &&
...  nr-rrc.physCellId == 51
${UEContextModificationRequest}=
...  f1ap.UEContextModificationRequest_element &&
...  f1ap.SCell_ToBeRemoved_List == 3 &&
...  f1ap.SCell_ToBeSetupMod_List == 1
${UEContextModificationResponse}=
...  f1ap.UEContextModificationResponse_element &&
...  nr-rrc.maxPayloadSize == 4 &&
...  nr-rrc.resourceList == 2 &&
...  nr-rrc.sCellToAddModList == 1 &&
...  nr-rrc.sCellToReleaseList == 3
${DLRRCMessageTransfer}=
...  f1ap &&
...  nr-rrc.rrcReconfiguration_element &&
...  nr-rrc.measIdToRemoveList == 4 &&
...  nr-rrc.MeasId == 5 &&
...  nr-rrc.measObjectToRemoveList == 3 &&
...  nr-rrc.reportConfigToRemoveList == 2
${RRCReconfigCompleteIndicator}=
...  f1ap.UEContextModificationRequest_element &&
...  f1ap.RRCReconfigurationCompleteIndicator == 0
${GNB_DUConfigurationQuery}=
...  f1ap.UEContextModificationRequest_element &&
...  f1ap.GNB_DUConfigurationQuery == 0

${IPHY}=    ${CURDIR}/config/iphy_AP_LOO_AHFII_AHFIB_AEQE_AHFII_gnb_ABIO_4FDD_2TDD.xml
${CFG}=    ${CURDIR}/config/wts_4cells_4FDD_n25_30_15MHz_n66_40MHz_n71_20MHz_2TDD_n41_40MHz_n77_80MHz.cfg
${scf3}=    scf_gNB_BOO_4FDD_n25_30_15MHz_n66_40MHz_n71_20MHz_2TDD_n41_40MHz_n77_80MHz.xml
*** Test Cases ***
CB005934-SR-A-B10_Single_UE_Call-SCell_Change_based_on_A1-PCell_measurement_for_SA_UE_from_4CC_F-F-F-F_CA_to_2CC_F-T_CA
    [Setup]    Run Keywords   With Retry Context    3
    ...                           Update And Put Iphy Xml    input_filepath=${IPHY}
    ...            AND            With Gnb Configuration    commissioning=SCF_A_B10.xml
    ...            AND            Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND            Start Default Logging
    ...            AND            With Simulator Configuration    config=${CFG}
    ...            AND            Wait For Next Full Pm Interval

    Attach UE And Verify Establishing PDU Session    ue_id=${ue_id}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger A1 Measurement    ue_id=${ue_id}     meas_id=${A1_MEAS_ID}    srsrp_nr=75
    Verify Message After A1 Measurement Triggered    packet_filter=${Verification_A1_measurement}
    Trigger A1 Measurement    ue_id=${ue_id}     meas_id=${scell_change_a1_meas_id}    srsrp_nr=${a1_rsrp_scell_change}
    Verify Message After A1 Measurement Triggered    packet_filter=${rrcReconfigurationComplete}
    Verify Message After A1 Measurement Triggered    packet_filter=${ULRRCMessageTransfer}
    Verify Message After A1 Measurement Triggered    packet_filter=${UEContextModificationRequest}
    Verify Message After A1 Measurement Triggered    packet_filter=${UEContextModificationResponse}
    Verify Message After A1 Measurement Triggered    packet_filter=${DLRRCMessageTransfer}
    Verify Message After A1 Measurement Triggered    packet_filter=${RRCReconfigCompleteIndicator}    number_of_messages=0    relation_symbol= >
    Verify Message After A1 Measurement Triggered    packet_filter=${GNB_DUConfigurationQuery}    number_of_messages=0    relation_symbol= >
    Verify Pm Counters After SCell Change    local_moid=${LOCAL_MOID}
    [Teardown]    Run Keywords    Release UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    ...    AND    Stop Default Logging
    ...    AND    Teardown Egate
    ...    AND    Add Scout Data Info To Testcase

CB005934-SR-B-B6a_Multi_UE_Call-SCell_Change_based_on_A1-PCell_measurement_for_SA_UE_from_3CC_F-T-T_CA_to_4CC_F-F-F-F_CA

    [Setup]    Run Keywords    With Retry Context    3
    ...                            Update And Put Iphy Xml    input_filepath=${IPHY}
    ...            AND             With Gnb Configuration    commissioning=CB005934_B_B6a_3CC_to_4CC_change.xml
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging
    ...            AND             With Simulator Configuration    config=${CFG}
    ...            AND             Wait For Next Full Pm Interval

    Attach Multiple UEs And Verify Establishing PDU Sessions    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}
    ...    gw_ids=${GW_IDs}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}

    Verify A1 Measurements Are Configured At Multiple UEs    ue_ids=${UE_IDs}
    ...    a1_event_params=${A1_RSRP}    a1_frequencies=${A1_FREQUENCIES}

    Trigger A1 Measurement And Expect SCell Addition Messages Flow For Multiple UEs    gnb_id=${GNB_ID}
    ...    ue_ids=${UE_IDs}    meas_id=${A1_MEAS_ID_TDD}    srsrp_nr=${SRSRP_NR_TDD}
    Verify SCell Addition Messages Content After A1 TDD Event Trigger For Multiple UEs    ue_ids=${UE_IDs}

    Trigger A1 Measurement And Expect SCell Addition Messages Flow For Multiple UEs    gnb_id=${GNB_ID}
    ...    ue_ids=${UE_IDs}    meas_id=${A1_MEAS_ID_FDD}    srsrp_nr=${SRSRP_NR_FDD}
    Verify SCell Addition Messages Content After A1 FDD Event Trigger For Multiple UEs    ue_ids=${UE_IDs}

    Verify Pm Counters For 3CC To 4CC Change    local_moid=${LOCAL_MOID}
    [Teardown]    Run Keywords    Release Multiple UEs    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}
    ...    AND    Stop Default Logging
    ...    AND    Teardown Egate
    ...    AND    Add Scout Data Info To Testcase

CB005934-SR-B-B1_Multiple_UEs_Call-Setup_4CC_FDD_DL_CA
    [Setup]    Run Keywords    With Retry Context    3
    ...                            Update And Put Iphy Xml    input_filepath=${IPHY}
    ...            AND             With Gnb Configuration    commissioning=${scf3}
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging
    ...            AND             With Simulator Configuration    config=${CFG}

    Attach Multiple UEs And Verify Establishing PDU Sessions    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}
    ...    gw_ids=${GW_IDs}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}

    Verify A1 Measurements Are Configured At Multiple UEs    ue_ids=${UE_IDs}
    ...    a1_event_params=${A1_RSRP}    a1_frequencies=${A1_FREQUENCIES}
    Trigger A1 Measurement And Expect SCell Addition Messages Flow For Multiple UEs    gnb_id=${GNB_ID}
    ...    ue_ids=${UE_IDs}    meas_id=${A1_MEAS_ID}    srsrp_nr=${SRSRP_NR}
    Verify SCell Addition Messages Content After A1 Event Trigger For Multiple UEs    ue_ids=${UE_IDs}

    Start Data Traffic For Multiple UEs    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}
    Verify Traffic on PCell and All SCells For Multiple UEs    ue_ids=${UE_IDs}

    [Teardown]    Run Keywords    Release Multiple UEs    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}
    ...    AND    Stop Default Logging
    ...    AND    Teardown Egate
    ...    AND    Add Scout Data Info To Testcase


