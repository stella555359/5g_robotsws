*** Settings ***
Documentation
...   Adapted tests for feature CB008717 (testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008717/CB008717.robot)
...   author/adapter: damian.silkowski@nokia.com
...   maintainer: someone else, for sure not Damian Silkowski

Force Tags      CRT_TRUNK    PY39

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    resources/resources_CB008717.robot
Resource    resources/wireshark.robot
Resource    resources/counters.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

#Suite Setup     common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
#...             swconfig_from_path=testsuite/Krakow/RRM/RAN_PZ/regression/KRK4/CB008717/swconfig.txt
#Suite Teardown  common_setups_and_teardowns.Common Suite Teardown

*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${REMOTE_PCAP_PATH}         /tmp/tmp.pcap

${102_WIRESHARK_LOG}    ${OUTPUT_DIR}/CB008717-E-102.pcap
${102_WIRESHARK_RRC}    ${OUTPUT_DIR}/CB008717-E-102-rrc.pcap
${102_WIRESHARK_NGAP}   ${OUTPUT_DIR}/CB008717-E-102-ngap.pcap
${102_WIRESHARK_F1AP}   ${OUTPUT_DIR}/CB008717-E-102-f1ap.pcap
${102_WIRESHARK_E1AP}   ${OUTPUT_DIR}/CB008717-E-102-e1ap.pcap

${105_WIRESHARK_LOG}    ${OUTPUT_DIR}/CB008717-E-105.pcap
${107_WIRESHARK_LOG}    ${OUTPUT_DIR}/CB008717-E-107.pcap
${202_WIRESHARK_LOG}    ${OUTPUT_DIR}/CB008717-E-202.pcap
${206_WIRESHARK_LOG}    ${OUTPUT_DIR}/CB008717-E-206.pcap
@{206_CHECK_INFOS}    nr-rrc.rrcSetupRequest_element
...    f1ap.UEContextSetupRequest_element
...    f1ap.UEContextSetupResponse_element
...    nr-rrc.rrcReestablishmentRequest_element
...    f1ap.DLRRCMessageTransfer_element
...    nr-rrc.rrcSetup_element
...    f1ap.ULRRCMessageTransfer_element
...    nr-rrc.rrcSetupComplete_element
...    ngap.InitialContextSetupRequest_element
...    ngap.NGResetAcknowledge_element
...    e1ap.BearerContextSetupRequest_element
...    e1ap.BearerContextSetupResponse_element
...    e1ap.BearerContextModificationRequest_element
...    e1ap.BearerContextModificationResponse_element
#...    nr-rrc.rrcReconfiguration_element
...    ngap.InitialContextSetupResponse_element
${207_WIRESHARK_LOG}    ${OUTPUT_DIR}/CB008717-E-207.pcap
@{207_CHECK_INFOS}    f1ap.DLRRCMessageTransfer_element
...    nr-rrc.rrcSetup_element
...    ngap.InitialContextSetupRequest_element
...    ngap.InitialContextSetupResponse_element
...    e1ap.BearerContextInactivityNotification_element
...    ngap.UEContextReleaseRequest_element
...    ngap.UEContextReleaseCommand_element
...    f1ap.UEContextReleaseComplete_element
...    ngap.UEContextReleaseComplete_element

${F03_WIRESHARK_LOG}    ${OUTPUT_DIR}/CB008717-F-03.pcap
${F03_WIRESHARK_RRC}    ${OUTPUT_DIR}/CB008717-F-03-rrc.pcap
${F03_WIRESHARK_NGAP}   ${OUTPUT_DIR}/CB008717-F-03-ngap.pcap
${F03_WIRESHARK_F1AP}   ${OUTPUT_DIR}/CB008717-F-03-f1ap.pcap
${F03_WIRESHARK_E1AP}   ${OUTPUT_DIR}/CB008717-F-03-e1ap.pcap

${FK01_WIRESHARK_LOG}    ${OUTPUT_DIR}/CB008717-FK-01.pcap
${FK01_WIRESHARK_RRC}    ${OUTPUT_DIR}/CB008717-FK-01-rrc.pcap
${FK01_WIRESHARK_NGAP}   ${OUTPUT_DIR}/CB008717-FK-01-ngap.pcap
${FK01_WIRESHARK_F1AP}   ${OUTPUT_DIR}/CB008717-FK-01-f1ap.pcap
${FK01_WIRESHARK_E1AP}   ${OUTPUT_DIR}/CB008717-FK-01-e1ap.pcap

${KF01_WIRESHARK_LOG}    ${OUTPUT_DIR}/CB008717-KF-01.pcap
${KF01_WIRESHARK_RRC}    ${OUTPUT_DIR}/CB008717-KF-01-rrc.pcap
${KF01_WIRESHARK_NGAP}   ${OUTPUT_DIR}/CB008717-KF-01-ngap.pcap
${KF01_WIRESHARK_F1AP}   ${OUTPUT_DIR}/CB008717-KF-01-f1ap.pcap
${KF01_WIRESHARK_E1AP}   ${OUTPUT_DIR}/CB008717-KF-01-e1ap.pcap
${8CC_PHY_IDS}    41,42,43,44,45,46,47,48

${KF02_WIRESHARK_LOG}    ${OUTPUT_DIR}/CB008717-KF-02.pcap
${KF02_WIRESHARK_RRC}    ${OUTPUT_DIR}/CB008717-KF-02-rrc.pcap
${KF02_WIRESHARK_NGAP}   ${OUTPUT_DIR}/CB008717-KF-02-ngap.pcap
${KF02_WIRESHARK_F1AP}   ${OUTPUT_DIR}/CB008717-KF-02-f1ap.pcap
${KF02_WIRESHARK_E1AP}   ${OUTPUT_DIR}/CB008717-KF-02-e1ap.pcap

${KF08_WIRESHARK_LOG}    ${OUTPUT_DIR}/CB008717-KF-08.pcap
${KF08_WIRESHARK_RRC}    ${OUTPUT_DIR}/CB008717-KF-08-rrc.pcap
${KF08_WIRESHARK_NGAP}   ${OUTPUT_DIR}/CB008717-KF-08-ngap.pcap
${KF08_WIRESHARK_F1AP}   ${OUTPUT_DIR}/CB008717-KF-08-f1ap.pcap
${KF08_WIRESHARK_E1AP}   ${OUTPUT_DIR}/CB008717-KF-08-e1ap.pcap

${SCF_102}    ${CURDIR}/commission/102.xml
${SCF_105}    ${CURDIR}/commission/105.xml
${SCF_202}    ${CURDIR}/commission/202.xml
${SCF_107}    ${CURDIR}/commission/107.xml
${SCF_206}    ${CURDIR}/commission/206.xml
${SCF_207}    ${CURDIR}/commission/207.xml
${SCF_F03}    ${CURDIR}/commission/F03.xml
${SCF_FK01}    ${CURDIR}/commission/FK01.xml
${SCF_KF01}    ${CURDIR}/commission/KF01.xml
${SCF_KF02}    ${CURDIR}/commission/KF02.xml
${SCF_KF08}    ${CURDIR}/commission/KF08.xml

*** Test Cases ***
CB008717-5G-GA_201_#B1_NR-DC-SN_cells_setup_and_activation_in_pure_NR-DC-SN_cell_deployment_SA_First_siso2
    resources_CB008717.perform_site_reset
    Wait Until Keyword Succeeds    15min    30s    resources_CB008717.verify_BTS_and_cells

CB008717-5G-E_102_B2 _UE Release without bearer takeback interwork with CB007516
    [Tags]    c102
#    Wait Until Keyword Succeeds    5min    30s    resources_CB008717.verify_BTS_and_cells
    wireshark.Start To Capture Wireshark Log From DU
    resources_CB008717.start_stop_and_verify_data_transfer
    wireshark.Stop To Capture Wireshark Log From DU    local_pcap_path=${102_WIRESHARK_LOG}

    Check Multi Cell Group And DRB    ${102_WIRESHARK_LOG}

    wireshark.Filter Wireshark Log To RRC NGAP F1AP E1AP    ${102_WIRESHARK_LOG}    ${102_WIRESHARK_RRC}
    ...    ${102_WIRESHARK_NGAP}   ${102_WIRESHARK_F1AP}   ${102_WIRESHARK_E1AP}

    # e1ap.uE-Activity: not-active (1) normal-release (20)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${102_WIRESHARK_E1AP}
    ...    e1ap.BearerContextInactivityNotification_element    e1ap.uE_Activity    1
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${102_WIRESHARK_E1AP}
    ...    e1ap.BearerContextReleaseCommand_element    e1ap.radioNetwork    20
    # ngap.radioNetwork: user-inactivity (20)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${102_WIRESHARK_NGAP}
    ...    ngap.UEContextReleaseRequest_element    ngap.radioNetwork    20
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${102_WIRESHARK_NGAP}
    ...    ngap.UEContextReleaseCommand_element    ngap.radioNetwork    20
    # f1ap.radioNetwork : unspecified (0)  nromal-release (10)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${102_WIRESHARK_F1AP}
    ...    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    10
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${102_WIRESHARK_F1AP}
    ...    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    10

    Clear Tmp Wireshark Csv    ${102_WIRESHARK_LOG[:-5]}

CB008717-5G-E_105_#B6_UE_Release_without_bearer_takeback_ due_to_PDCP_count_rollover
    [Tags]    c105
    Wait Until Keyword Succeeds    5min    30s    resources_CB008717.verify_BTS_and_cells
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}
    ...                                     parameter=keyRefrMarg
    ...                                     value=4294906000
    wireshark.Start To Capture Wireshark Log From DU
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}/NRCELL-30
    ...                                     parameter=administrativeState
    ...                                     value=Locked
    Sleep    30s
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}/NRCELL-30
    ...                                     parameter=administrativeState
    ...                                     value=Unlocked
    resources_CB008717.start_stop_and_verify_data_transfer
    wireshark.Stop To Capture Wireshark Log From DU   local_pcap_path=${105_WIRESHARK_LOG}

    Check Multi Cell Group And DRB    ${105_WIRESHARK_LOG}
    # e1ap.radioNetwork: pPDCP-Count-wrap-around (5)  normal-release (20)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}
    ...    e1ap.BearerContextModificationRequired_element    e1ap.radioNetwork    5
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}
    ...    e1ap.BearerContextReleaseCommand_element    e1ap.radioNetwork    20
    # ngap.radioNetwork: up-confidentiality-protection-not-possible (38)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}
    ...    ngap.UEContextReleaseRequest_element    ngap.radioNetwork    38
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}
    ...    ngap.UEContextReleaseCommand_element    ngap.radioNetwork    38
    # f1ap.radioNetwork : unspecified (0)  nromal-release (10)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}
    ...    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    0
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}
    ...    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    10

    Clear Tmp Wireshark Csv    ${105_WIRESHARK_LOG[:-5]}
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}
    ...                                     parameter=keyRefrMarg
    ...                                     value=200000
    Sleep    30s

CB008717-5G-E_202_B2 _UE Release without bearer takeback due to user inactivity
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c202
    Wait Until Keyword Succeeds    5min    30s    resources_CB008717.verify_BTS_and_cells
    wireshark.Start To Capture Wireshark Log From DU
    resources_CB008717.start_data_transfer
    resources_CB008717.turn_off_mobile_data
    resources_CB008717.stop_data_transfer
    resources_CB008717.turn_on_mobile_data
    Sleep    30s
    wireshark.Stop To Capture Wireshark Log From DU    local_pcap_path=${202_WIRESHARK_LOG}

    Check Multi Cell Group And DRB    ${202_WIRESHARK_LOG}
    # e1ap.uE-Activity: not-active (1) normal-release (20)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${202_WIRESHARK_LOG}
    ...    e1ap.BearerContextInactivityNotification_element    e1ap.uE_Activity    1
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${202_WIRESHARK_LOG}
    ...    e1ap.BearerContextReleaseCommand_element    e1ap.radioNetwork    20
    # ngap.radioNetwork: user-inactivity (20)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${202_WIRESHARK_LOG}
    ...    ngap.UEContextReleaseRequest_element    ngap.radioNetwork    20
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${202_WIRESHARK_LOG}
    ...    ngap.UEContextReleaseCommand_element    ngap.radioNetwork    20
    # f1ap.radioNetwork : unspecified (0)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${202_WIRESHARK_LOG}
    ...    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    10

    Clear Tmp Wireshark Csv    ${202_WIRESHARK_LOG[:-5]}

CB008717-5G-E_107_#B11_UPD004_UE Release without bearer takeback - due to F1 Partial Release
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c107
    Wait Until Keyword Succeeds    5min    30s    resources_CB008717.verify_BTS_and_cells
    wireshark.Start To Capture Wireshark Log From DU
    resources_CB008717.start_data_transfer
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}/NRCELL-30
    ...                                     parameter=administrativeState
    ...                                     value=Locked
    resources_CB008717.Block Cell    cell_id=30
    Sleep    60
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}/NRCELL-30
    ...                                     parameter=administrativeState
    ...                                     value=Unlocked
    resources_CB008717.Unblock Cell    cell_id=30
    Sleep    30
    resources_CB008717.stop_data_transfer
    wireshark.Stop To Capture Wireshark Log From DU    local_pcap_path=${107_WIRESHARK_LOG}

    # f1ap.ResetType: part0fF1-Interface (1)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${107_WIRESHARK_LOG}
    ...    f1ap.Reset_element    f1ap.ResetType    1
    # e1ap.ResetType: part0fE1-Interface (1)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${107_WIRESHARK_LOG}
    ...    e1ap.Reset_element    e1ap.ResetType    1
    # ngap.radioNetwork: release-due-to-ngran-generated-reason (3)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${107_WIRESHARK_LOG}
    ...    ngap.NGReset_element    ngap.radioNetwork    3
    ${gnb_cu_ue_f1ap_ids}    wireshark.Get Field Value Via Wireshark    ${107_WIRESHARK_LOG}
    ...    f1ap.UEContextSetupRequest_element    f1ap.GNB_CU_UE_F1AP_ID
    ${f1ap_ids}    wireshark.Get Field Value Via Wireshark    ${107_WIRESHARK_LOG}
    ...    f1ap.Reset_element    f1ap.gNB_CU_UE_F1AP_ID
    ${e1ap_ids}    wireshark.Get Field Value Via Wireshark    ${107_WIRESHARK_LOG}
    ...    e1ap.Reset_element    e1ap.gNB_CU_CP_UE_E1AP_ID
    List Should Contain Sub List    ${gnb_cu_ue_f1ap_ids}    ${f1ap_ids}
    List Should Contain Sub List    ${gnb_cu_ue_f1ap_ids}    ${e1ap_ids}

    Clear Tmp Wireshark Csv    ${107_WIRESHARK_LOG[:-5]}

CB008717-5G-E_206_#B9_UPD001_NG_Full_Partial_Reset - AMF_gNB_Initiated_ALT2
    [Tags]    c206
    Wait Until Keyword Succeeds    5min    30s    resources_CB008717.verify_BTS_and_cells
    wireshark.Start To Capture Wireshark Log From DU
    resources_CB008717.start_data_transfer
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}/NRCELL-31
    ...                                     parameter=qRxLevMin
    ...                                     value=-60
    Sleep    20s
    resources_CB008717.block_cell    cell_id=30
    Sleep    20s
    resources_CB008717.unblock_cell    cell_id=30
    Sleep    20s
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}/NRCELL-31
    ...                                     parameter=qRxLevMin
    ...                                     value=-22
    resources_CB008717.detach_ue
    Sleep    20s
    resources_CB008717.stop_data_transfer_without_verification
    wireshark.Stop To Capture Wireshark Log From DU    local_pcap_path=${206_WIRESHARK_LOG}

    Check Info Exist In Wireshark Log    ${206_WIRESHARK_LOG}    ${206_CHECK_INFOS}
    ...    output_file=${OUTPUT_DIR}/check_wireshark_info_exist.txt
    # ngap.ResetType : part0fNG-Interface (1)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${206_WIRESHARK_LOG}
    ...    ngap.NGReset_element    ngap.ResetType    1
    # ngap.radioNetwork : release-due-to-ngran-generated-reason (3)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${206_WIRESHARK_LOG}
    ...    ngap.NGReset_element    ngap.radioNetwork    3

    Clear Tmp Wireshark Csv    ${206_WIRESHARK_LOG[:-5]}

CB008717-5G-E_207_B2_Exploratory_testing
    [Tags]    c207
    Wait Until Keyword Succeeds    5min    30s    resources_CB008717.verify_BTS_and_cells
    wireshark.Start To Capture Wireshark Log From DU
    resources_CB008717.start_data_transfer
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}/NRCELL-31
    ...                                     parameter=qRxLevMin
    ...                                     value=-60
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}/NRCELL-30
    ...                                     parameter=dlMimoMode
    ...                                     value=4x4 or 4x2 Open Loop Spatial Multiplexing
    Sleep    10s
    resources_CB008717.stop_data_transfer_without_verification
    Sleep    60s
    resources_CB008717.turn_off_mobile_data
    Sleep    60s
    resources_CB008717.detach_ue
    Sleep    60s
    resources_CB008717.Stop Data Transfer Without Verification
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}/NRCELL-31
    ...                                     parameter=qRxLevMin
    ...                                     value=-22
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}/NRCELL-30
    ...                                     parameter=dlMimoMode
    ...                                     value=4x4 or 4x2 Closed Loop Spatial Multiplexing
    wireshark.Stop To Capture Wireshark Log From DU    local_pcap_path=${207_WIRESHARK_LOG}
    resources_CB008717.modify_parameter     dist_name=MRBTS-{}/NRBTS-{}/NRCELL-30
    ...                                     parameter=dlMimoMode
    ...                                     value=4x4 or 4x2 Open Loop Spatial Multiplexing

    run keyword and continue on failure    Check Info Exist In Wireshark Log    ${207_WIRESHARK_LOG}
    ...    ${207_CHECK_INFOS}    output_file=${OUTPUT_DIR}/check_wireshark_info_exist.txt
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${207_WIRESHARK_LOG}
    ...    ngap.InitialContextSetupRequest_element    ngap.fiveQI    9
    # ngap.radioNetwork: normal-release (20)
    run keyword and continue on failure     wireshark.Check Field Value Via Wireshark    ${207_WIRESHARK_LOG}
    ...    ngap.UEContextReleaseRequest_element    ngap.radioNetwork    20
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${207_WIRESHARK_LOG}
    ...    e1ap.BearerContextReleaseCommand_element    e1ap.radioNetwork    20
    # f1ap.radioNetwork : nromal-release (10) unspecified (0)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${207_WIRESHARK_LOG}
    ...    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    10
    # run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${207_WIRESHARK_LOG}
    # ...    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    0

    Clear Tmp Wireshark Csv    ${207_WIRESHARK_LOG[:-5]}

CB008717-5G-KF_1_5G_PM_1180&5G_PM_781_measure_MN_Initiated_S-Node_Release_procedure_which_releases_the_NR-DC_via_takeback
    [Tags]    KF01
    Wait Until Keyword Succeeds    5min    30s    resources_CB008717.verify_BTS_and_cells
    ${date}    Get Current Date
    ${counter_start_time}    Convert Date    ${date}    epoch
    Set Global Variable    ${COUNTER_START_TIME}
    wireshark.Start To Capture Wireshark Log From DU
    resources_CB008717.start_data_transfer    dt_1=DT1    dt_2=DT_2
    Sleep    50s
    #TODO removed check is needed modify_pdu_via_update_ncp_rule    rule_name=ADD5QI9-ZYH
    resources_CB008717.start_data_transfer    dt_1=DT_3    dt_2=DT_4    require_ue=${False}
    resources_CB008717.turn_off_mobile_data
    wireshark.Stop To Capture Wireshark Log From DU    local_pcap_path=${KF01_WIRESHARK_LOG}

    wireshark.Filter Wireshark Log To RRC NGAP F1AP E1AP    ${KF01_WIRESHARK_LOG}    ${KF01_WIRESHARK_RRC}
    ...    ${KF01_WIRESHARK_NGAP}   ${KF01_WIRESHARK_F1AP}   ${KF01_WIRESHARK_E1AP}

    # qosFlowIdentifier: 22, fiveQI: 9
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF01_WIRESHARK_NGAP}
    ...    ngap    ngap.fiveQI    9
    ${ngap_qosFlowIdentifier}    wireshark.Get Field Value Via Wireshark    ${KF01_WIRESHARK_NGAP}
    ...    ngap.PDUSessionResourceModifyResponse_element    ngap.qosFlowIdentifier
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF01_WIRESHARK_E1AP}
    ...    e1ap.BearerContextModificationRequest_element    e1ap.cell_Group_ID    0
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF01_WIRESHARK_E1AP}
    ...    e1ap.BearerContextModificationRequest_element    e1ap.dRB_ID    4
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF01_WIRESHARK_E1AP}
    ...    e1ap.BearerContextModificationRequest_element    e1ap.dRB_ID    4
    # dRB-ID: 5, qoS-Flow-Identifier: 22, fiveQI: 9
    ${e1ap_qosFlowIdentifier}    wireshark.Get Field Value Via Wireshark    ${KF01_WIRESHARK_E1AP}
    ...    e1ap.BearerContextModificationRequest_element    e1ap.qoS_Flow_Identifier
    List Should Contain Sub List    ${e1ap_qosFlowIdentifier}    ${ngap_qosFlowIdentifier}

    # dL-TX-Stop: stop (0)
    #run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF01_WIRESHARK_E1AP}
    #...    e1ap.BearerContextModificationRequest_element    e1ap.dL_TX_Stop    0
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF01_WIRESHARK_F1AP}
    ...    f1ap.UEContextSetupRequest_element    f1ap.sCellIndex    2,3,4,5,6,7,8
    # TransmissionActionIndicator: stop (0)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF01_WIRESHARK_F1AP}
    ...    f1ap.UEContextModificationRequest_element
    ...    f1ap.TransmissionActionIndicator    0
    # radioNetwork: unspecified (0)
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF01_WIRESHARK_F1AP}
    ...    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    10
    # SCGIndicator: released (0)
    ${count1}    Get Field Value Count Via Wireshark
    ...    ${KF01_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element    f1ap.SCGIndicator    0
    Should Be True    ${count1}==1
    ${count2}    Get Field Value Count Via Wireshark
    ...    ${KF01_WIRESHARK_NGAP}    ngap.UEContextReleaseRequest_element    ngap.radioNetwork    20
    ${count}    Evaluate    ${count1}+${count2}
    run keyword and continue on failure    counters.Verify CB008717 KF Counters Update Normal    29_except_counter_value=${count}
    resources_CB008717.turn_on_mobile_data
    resources_CB008717.stop_data_transfer_without_verification    dt_1=DT_1    dt_2=DT_2
    resources_CB008717.stop_data_transfer_without_verification    dt_1=DT_3    dt_2=DT_4

#!!! NOT DOABLE IN KRK
#CB008717-5G-KF_2_5G_PM_1180_measure_complete_UE_Context_Release_procedures
#    [Documentation]    Author: jian.1.chen@nokia-sbell.com
#    ...    Init Define: 2024/01/19 17:11
#    [Tags]    KF02
#    Wait Until Keyword Succeeds    5min    30s    resources_CB008717.verify_BTS_and_cells
#    ${date}    Get Current Date
#    ${counter_start_time}    Convert Date    ${date}    epoch
#    Set Global Variable    ${COUNTER_START_TIME}
#    wireshark.Start To Capture Wireshark Log From DU
#    resources_CB008717.start_stop_and_verify_data_transfer
#    Sleep    60
#    resources_CB008717.turn_off_mobile_data
#    Sleep    15
#    Stop To Capture Wireshark Log From DU    local_pcap_path=${KF02_WIRESHARK_LOG}
#
#    run keyword and continue on failure    wireshark.Filter Wireshark Log To RRC NGAP F1AP E1AP    ${KF02_WIRESHARK_LOG}
#    ...    ${KF02_WIRESHARK_RRC}    ${KF02_WIRESHARK_NGAP}   ${KF02_WIRESHARK_F1AP}   ${KF02_WIRESHARK_E1AP}
#    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF02_WIRESHARK_E1AP}
#    ...    e1ap.BearerContextModificationRequest_element    e1ap.cell_Group_ID    0
#    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF02_WIRESHARK_E1AP}
#    ...    e1ap.BearerContextModificationRequest_element    e1ap.dRB_ID    4
#    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF02_WIRESHARK_E1AP}
#    ...    e1ap.BearerContextInactivityNotification_element    e1ap.uE_Activity    1
#    # e1ap radioNetwork: normal-release (20)
#    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF02_WIRESHARK_E1AP}
#    ...    e1ap.BearerContextReleaseCommand_element    e1ap.radioNetwork    20
#    ${count}    Get Field Value Count Via Wireshark
#    ...    ${KF02_WIRESHARK_NGAP}    ngap.UEContextReleaseRequest_element    ngap.radioNetwork    20
#    run keyword and continue on failure    counters.Verify CB008717 KF02 Counters Update Normal    29_except_counter_value=${count}
#    # f1ap radioNetwork: normal-release (10)
#    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${KF02_WIRESHARK_F1AP}
#    ...    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    10
#    resources_CB008717.turn_on_mobile_data

*** Keywords ***
Clear Tmp Wireshark Csv
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${file_prefix}
    OperatingSystem.Run    rm -rf ${file_prefix}_*

Check Multi Cell Group And DRB
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${wireshark_log}    ${drbids}=4    ${cell_group_1}=[5e40b1, 4402b1]
    run keyword and continue on failure    wireshark.Check Field Value Via Wireshark    ${wireshark_log}
    ...    f1ap.UEContextSetupResponse_element    f1ap.dRBID    ${drbids}
    ${cell_group_ids}    wireshark.Get Field Value Via Wireshark    ${wireshark_log}
    ...    f1ap.UEContextSetupResponse_element    f1ap.cellGroupConfig
    run keyword and continue on failure     Should Contain Any    ${cell_group_ids[-1]}    ${cell_group_1}[0]    ${cell_group_1}[1]
