# # @Time    : 2023/5/19 14:35
# # @Author  : Jian.1.Chen
# # @Email   : jian.1.chen@nokia-sbell.com
# # @File    : CB008717-E.robot
# # @Software: PyCharm
# # @Doc     : Some Description
# *** Settings ***
# Documentation
# ...    author: Chen Jian
# ...    contact: jian.1.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# ...    Feature CB008717-E/-GA/-F/-FK
# 
# Suite Setup          Run Keywords    Replace Swconfig Through Local File    ${CURDIR}/swconfig.txt
# ...    AND     CI_interface.Common Suite Setup
# ...    AND     robot_common_operations.Common Suite Setup
# ...    AND    Wait Until Keyword Succeeds     3 times   30s    UE screen unlock and Switch Apn  apn_name=mdrb.nokia.com
# 
# Suite Teardown       Run Keywords    robot_common_operations.Common Suite Teardown
# ...    AND     CI_interface.Common Case Teardown
# Test Setup           MMW5 Common Case Setup
# Test Teardown        MMW5 Common Case Teardown
# 
# Force Tags      CRT_TRUNK    PY39
# Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# Library     taf.selenium.sbts    WITH NAME    selenium_sbts
# 
# *** Variables ***
# ${if_commissioning}    False
# ${TS_LOG_PATH_BASE}     ${OUTPUT DIR}
# ${102_WIRESHARK_LOG}    ${TS_LOG_PATH_BASE}/CB008717-E-102.pcap
# ${102_WIRESHARK_RRC}    ${TS_LOG_PATH_BASE}/CB008717-E-102-rrc.pcap
# ${102_WIRESHARK_NGAP}   ${TS_LOG_PATH_BASE}/CB008717-E-102-ngap.pcap
# ${102_WIRESHARK_F1AP}   ${TS_LOG_PATH_BASE}/CB008717-E-102-f1ap.pcap
# ${102_WIRESHARK_E1AP}   ${TS_LOG_PATH_BASE}/CB008717-E-102-e1ap.pcap
# 
# ${105_WIRESHARK_LOG}    ${TS_LOG_PATH_BASE}/CB008717-E-105.pcap
# ${107_WIRESHARK_LOG}    ${TS_LOG_PATH_BASE}/CB008717-E-107.pcap
# ${202_WIRESHARK_LOG}    ${TS_LOG_PATH_BASE}/CB008717-E-202.pcap
# ${206_WIRESHARK_LOG}    ${TS_LOG_PATH_BASE}/CB008717-E-206.pcap
# @{206_CHECK_INFOS}    nr-rrc.rrcSetupRequest_element
# ...    f1ap.UEContextSetupRequest_element
# ...    f1ap.UEContextSetupResponse_element
# ...    nr-rrc.rrcReestablishmentRequest_element
# ...    f1ap.DLRRCMessageTransfer_element
# ...    nr-rrc.rrcSetup_element
# ...    f1ap.ULRRCMessageTransfer_element
# ...    nr-rrc.rrcSetupComplete_element
# ...    ngap.InitialContextSetupRequest_element
# ...    ngap.NGResetAcknowledge_element
# ...    e1ap.BearerContextSetupRequest_element
# ...    e1ap.BearerContextSetupResponse_element
# ...    e1ap.BearerContextModificationRequest_element
# ...    e1ap.BearerContextModificationResponse_element
# #...    nr-rrc.rrcReconfiguration_element
# ...    ngap.InitialContextSetupResponse_element
# ${207_WIRESHARK_LOG}    ${TS_LOG_PATH_BASE}/CB008717-E-207.pcap
# @{207_CHECK_INFOS}    ngap.NGReset_element
# ...    ngap.NGResetAcknowledge_element
# ...    nr-rrc.rrcReestablishmentRequest_element
# ...    f1ap.DLRRCMessageTransfer_element
# ...    nr-rrc.rrcSetup_element
# ...    ngap.InitialContextSetupRequest_element
# ...    ngap.InitialContextSetupResponse_element
# ...    e1ap.BearerContextInactivityNotification_element
# ...    ngap.UEContextReleaseRequest_element
# ...    ngap.UEContextReleaseCommand_element
# ...    f1ap.UEContextReleaseComplete_element
# ...    ngap.UEContextReleaseComplete_element
# 
# ${F03_WIRESHARK_LOG}    ${TS_LOG_PATH_BASE}/CB008717-F-03.pcap
# ${F03_WIRESHARK_RRC}    ${TS_LOG_PATH_BASE}/CB008717-F-03-rrc.pcap
# ${F03_WIRESHARK_NGAP}   ${TS_LOG_PATH_BASE}/CB008717-F-03-ngap.pcap
# ${F03_WIRESHARK_F1AP}   ${TS_LOG_PATH_BASE}/CB008717-F-03-f1ap.pcap
# ${F03_WIRESHARK_E1AP}   ${TS_LOG_PATH_BASE}/CB008717-F-03-e1ap.pcap
# 
# ${FK01_WIRESHARK_LOG}    ${TS_LOG_PATH_BASE}/CB008717-FK-01.pcap
# ${FK01_WIRESHARK_RRC}    ${TS_LOG_PATH_BASE}/CB008717-FK-01-rrc.pcap
# ${FK01_WIRESHARK_NGAP}   ${TS_LOG_PATH_BASE}/CB008717-FK-01-ngap.pcap
# ${FK01_WIRESHARK_F1AP}   ${TS_LOG_PATH_BASE}/CB008717-FK-01-f1ap.pcap
# ${FK01_WIRESHARK_E1AP}   ${TS_LOG_PATH_BASE}/CB008717-FK-01-e1ap.pcap
# 
# ${KF01_WIRESHARK_LOG}    ${TS_LOG_PATH_BASE}/CB008717-KF-01.pcap
# ${KF01_WIRESHARK_RRC}    ${TS_LOG_PATH_BASE}/CB008717-KF-01-rrc.pcap
# ${KF01_WIRESHARK_NGAP}   ${TS_LOG_PATH_BASE}/CB008717-KF-01-ngap.pcap
# ${KF01_WIRESHARK_F1AP}   ${TS_LOG_PATH_BASE}/CB008717-KF-01-f1ap.pcap
# ${KF01_WIRESHARK_E1AP}   ${TS_LOG_PATH_BASE}/CB008717-KF-01-e1ap.pcap
# ${8CC_PHY_IDS}    41,42,43,44,45,46,47,48
# 
# ${KF02_WIRESHARK_LOG}    ${TS_LOG_PATH_BASE}/CB008717-KF-02.pcap
# ${KF02_WIRESHARK_RRC}    ${TS_LOG_PATH_BASE}/CB008717-KF-02-rrc.pcap
# ${KF02_WIRESHARK_NGAP}   ${TS_LOG_PATH_BASE}/CB008717-KF-02-ngap.pcap
# ${KF02_WIRESHARK_F1AP}   ${TS_LOG_PATH_BASE}/CB008717-KF-02-f1ap.pcap
# ${KF02_WIRESHARK_E1AP}   ${TS_LOG_PATH_BASE}/CB008717-KF-02-e1ap.pcap
# 
# ${KF08_WIRESHARK_LOG}    ${TS_LOG_PATH_BASE}/CB008717-KF-08.pcap
# ${KF08_WIRESHARK_RRC}    ${TS_LOG_PATH_BASE}/CB008717-KF-08-rrc.pcap
# ${KF08_WIRESHARK_NGAP}   ${TS_LOG_PATH_BASE}/CB008717-KF-08-ngap.pcap
# ${KF08_WIRESHARK_F1AP}   ${TS_LOG_PATH_BASE}/CB008717-KF-08-f1ap.pcap
# ${KF08_WIRESHARK_E1AP}   ${TS_LOG_PATH_BASE}/CB008717-KF-08-e1ap.pcap
# 
# ${SCF_102}    ${CURDIR}/commission/102.xml
# ${SCF_105}    ${CURDIR}/commission/105.xml
# ${SCF_202}    ${CURDIR}/commission/202.xml
# ${SCF_107}    ${CURDIR}/commission/107.xml
# ${SCF_206}    ${CURDIR}/commission/206.xml
# ${SCF_207}    ${CURDIR}/commission/207.xml
# ${SCF_F03}    ${CURDIR}/commission/F03.xml
# ${SCF_FK01}    ${CURDIR}/commission/FK01.xml
# ${SCF_KF01}    ${CURDIR}/commission/KF01.xml
# ${SCF_KF02}    ${CURDIR}/commission/KF02.xml
# ${SCF_KF08}    ${CURDIR}/commission/KF08.xml
# 
# *** Test Cases ***
# CB008717-5G-GA_201_#B1_NR-DC-SN_cells_setup_and_activation_in_pure_NR-DC-SN_cell_deployment_SA_First_siso2
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     coam.reset_site    timeout=600    connection=GNB_OAM
#     Wait Until Keyword Succeeds    15min    30s    Verify BTS 5G Cells Status Is Normal State
# 
# CB008717-5G-E_102_B2 _UE Release without bearer takeback interwork with CB007516
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c102
#     8717 102 Precondition
# 
#     Check Multi Cell Group And DRB    ${102_WIRESHARK_LOG}
# 
#     Filter Wireshark Log To RRC NGAP F1AP E1AP    ${102_WIRESHARK_LOG}    ${102_WIRESHARK_RRC}
#     ...    ${102_WIRESHARK_NGAP}   ${102_WIRESHARK_F1AP}   ${102_WIRESHARK_E1AP}
# 
#     # e1ap.uE-Activity: not-active (1) normal-release (20)
#     Check Field Value Via Wireshark    ${102_WIRESHARK_E1AP}    e1ap.BearerContextInactivityNotification_element
#     ...    e1ap.uE_Activity    1
#     Check Field Value Via Wireshark    ${102_WIRESHARK_E1AP}    e1ap.BearerContextReleaseCommand_element
#     ...    e1ap.radioNetwork    20
# 
#     # ngap.radioNetwork: user-inactivity (20)
#     Check Field Value Via Wireshark    ${102_WIRESHARK_NGAP}    ngap.UEContextReleaseRequest_element
#     ...    ngap.radioNetwork    20
#     Check Field Value Via Wireshark    ${102_WIRESHARK_NGAP}    ngap.UEContextReleaseCommand_element
#     ...    ngap.radioNetwork    20
# 
#     # f1ap.radioNetwork : unspecified (0)  nromal-release (10)
#     Check Field Value Via Wireshark    ${102_WIRESHARK_F1AP}     f1ap.UEContextReleaseCommand_element
#     ...    f1ap.radioNetwork    0
#     Check Field Value Via Wireshark    ${102_WIRESHARK_F1AP}     f1ap.UEContextReleaseCommand_element
#     ...    f1ap.radioNetwork    10
# 
#     #Clear Tmp Wireshark Csv    ${102_WIRESHARK_LOG[:-5]}
# 
# CB008717-5G-E_105_#B6_UE_Release_without_bearer_takeback_ due_to_PDCP_count_rollover
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c105
#     8717 105 Precondition
# 
#     Check Multi Cell Group And DRB    ${105_WIRESHARK_LOG}
#     # e1ap.radioNetwork: pPDCP-Count-wrap-around (5)  normal-release (20)
#     Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}    e1ap.BearerContextModificationRequired_element
#     ...    e1ap.radioNetwork    5
#     Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}    e1ap.BearerContextReleaseCommand_element
#     ...    e1ap.radioNetwork    20
#     # ngap.radioNetwork: up-confidentiality-protection-not-possible (38)
#     Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}    ngap.UEContextReleaseRequest_element
#     ...    ngap.radioNetwork    38
#     Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}    ngap.UEContextReleaseCommand_element
#     ...    ngap.radioNetwork    38
#     # f1ap.radioNetwork : unspecified (0)  nromal-release (10)
#     Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}    f1ap.UEContextReleaseCommand_element
#     ...    f1ap.radioNetwork    0
#     Check Field Value Via Wireshark    ${105_WIRESHARK_LOG}    f1ap.UEContextReleaseCommand_element
#     ...    f1ap.radioNetwork    10
# 
#     Clear Tmp Wireshark Csv    ${105_WIRESHARK_LOG[:-5]}
# 
# CB008717-5G-E_202_B2 _UE Release without bearer takeback due to user inactivity
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c202
#     8717 202 Precondition
# 
#     Check Multi Cell Group And DRB    ${202_WIRESHARK_LOG}
#     # e1ap.uE-Activity: not-active (1) normal-release (20)
#     Check Field Value Via Wireshark    ${202_WIRESHARK_LOG}    e1ap.BearerContextInactivityNotification_element
#     ...    e1ap.uE_Activity    1
#     Check Field Value Via Wireshark    ${202_WIRESHARK_LOG}    e1ap.BearerContextReleaseCommand_element
#     ...    e1ap.radioNetwork    20
#     # ngap.radioNetwork: user-inactivity (20)
#     Check Field Value Via Wireshark    ${202_WIRESHARK_LOG}    ngap.UEContextReleaseRequest_element
#     ...    ngap.radioNetwork    20
#     Check Field Value Via Wireshark    ${202_WIRESHARK_LOG}    ngap.UEContextReleaseCommand_element
#     ...    ngap.radioNetwork    20
#     # f1ap.radioNetwork : unspecified (0)
#     Check Field Value Via Wireshark    ${202_WIRESHARK_LOG}    f1ap.UEContextReleaseCommand_element
#     ...    f1ap.radioNetwork    0
# 
#     Clear Tmp Wireshark Csv    ${202_WIRESHARK_LOG[:-5]}
# 
# CB008717-5G-E_107_#B11_UPD004_UE Release without bearer takeback - due to F1 Partial Release
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c107
#     8717 107 Precondition
# 
#     # f1ap.ResetType: part0fF1-Interface (1)
#     Check Field Value Via Wireshark    ${107_WIRESHARK_LOG}    f1ap.Reset_element
#     ...    f1ap.ResetType    1
#     # e1ap.ResetType: part0fE1-Interface (1)
#     Check Field Value Via Wireshark    ${107_WIRESHARK_LOG}    e1ap.Reset_element
#     ...    e1ap.ResetType    1
#     # ngap.radioNetwork: release-due-to-ngran-generated-reason (3)
#     Check Field Value Via Wireshark    ${107_WIRESHARK_LOG}    ngap.NGReset_element
#     ...    ngap.radioNetwork    3
#     ${gnb_cu_ue_f1ap_ids}    Get Field Value Via Wireshark    ${107_WIRESHARK_LOG}    f1ap.UEContextSetupRequest_element
#     ...    f1ap.GNB_CU_UE_F1AP_ID
#     ${f1ap_ids}    Get Field Value Via Wireshark    ${107_WIRESHARK_LOG}    f1ap.Reset_element    f1ap.gNB_CU_UE_F1AP_ID
#     ${e1ap_ids}    Get Field Value Via Wireshark    ${107_WIRESHARK_LOG}    e1ap.Reset_element    e1ap.gNB_CU_CP_UE_E1AP_ID
#     List Should Contain Sub List    ${gnb_cu_ue_f1ap_ids}    ${f1ap_ids}
#     List Should Contain Sub List    ${gnb_cu_ue_f1ap_ids}    ${e1ap_ids}
# 
#     Clear Tmp Wireshark Csv    ${107_WIRESHARK_LOG[:-5]}
# 
# CB008717-5G-E_206_#B9_UPD001_NG_Full_Partial_Reset - AMF_gNB_Initiated_ALT2
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c206
#     8717 206 Precondition
# 
#     Check Info Exist In Wireshark Log    ${206_WIRESHARK_LOG}    ${206_CHECK_INFOS}
#     ...    output_file=/home/ute/test_results/check_wireshark_info_exist.txt
#     # ngap.ResetType : part0fNG-Interface (1)
#     Check Field Value Via Wireshark    ${206_WIRESHARK_LOG}    ngap.NGReset_element
#     ...    ngap.ResetType    1
#     # ngap.radioNetwork : release-due-to-ngran-generated-reason (3)
#     Check Field Value Via Wireshark    ${206_WIRESHARK_LOG}    ngap.NGReset_element
#     ...    ngap.radioNetwork    3
# 
#     Clear Tmp Wireshark Csv    ${206_WIRESHARK_LOG[:-5]}
# 
# CB008717-5G-E_207_B2_Exploratory_testing
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c207
#     8717 207 Precondition
# 
#     Check Info Exist In Wireshark Log    ${207_WIRESHARK_LOG}    ${207_CHECK_INFOS}
#     ...    output_file=/home/ute/test_results/check_wireshark_info_exist.txt
#     Check Field Value Via Wireshark    ${207_WIRESHARK_LOG}    ngap.InitialContextSetupRequest_element
#     ...    ngap.fiveQI    7,8
#     # ngap.radioNetwork: normal-release (20)
#     Check Field Value Via Wireshark    ${207_WIRESHARK_LOG}    ngap.UEContextReleaseRequest_element
#     ...    ngap.radioNetwork    20
#     Check Field Value Via Wireshark    ${207_WIRESHARK_LOG}    e1ap.BearerContextReleaseCommand_element
#     ...    e1ap.radioNetwork    20
#     # f1ap.radioNetwork : nromal-release (10) unspecified (0)
#     Check Field Value Via Wireshark    ${207_WIRESHARK_LOG}    f1ap.UEContextReleaseCommand_element
#     ...    f1ap.radioNetwork    10
#     Check Field Value Via Wireshark    ${207_WIRESHARK_LOG}    f1ap.UEContextReleaseCommand_element
#     ...    f1ap.radioNetwork    0
# 
#     Clear Tmp Wireshark Csv    ${207_WIRESHARK_LOG[:-5]}
# 
# CB008717-5G-F_3_B1_NR-DC_bearer_takeback_triggered_due_to_modification_of_PDU_session_containing_split bearers_ALT1
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    F03
#     8717 F03 Precondition
# 
#     Filter Wireshark Log To RRC NGAP F1AP E1AP    ${F03_WIRESHARK_LOG}    ${F03_WIRESHARK_RRC}
#     ...    ${F03_WIRESHARK_NGAP}   ${F03_WIRESHARK_F1AP}   ${F03_WIRESHARK_E1AP}
# 
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_NGAP}    ngap.InitialContextSetupRequest_element
#     ...    ngap.fiveQI    7,8
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_NGAP}    ngap.PDUSessionResourceModifyResponse_element
#     ...    ngap.pDUSessionID    1
# 
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_E1AP}    e1ap.BearerContextSetupRequest_element
#     ...    e1ap.fiveQI    7,8
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_E1AP}    e1ap.BearerContextSetupRequest_element
#     ...    e1ap.dRB_ID    4,5
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element
#     ...    e1ap.cell_Group_ID    1
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element
#     ...    e1ap.dRB_ID    4,5
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element
#     ...    e1ap.dL_TX_Stop    0,0
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_E1AP}    e1ap.BearerContextModificationResponse_element
#     ...    e1ap.dRB_ID    4,5
# 
#     # NRCELL-1(101):00af780010(183992321) NRCELL-11(41):00af7800b0(183992331)
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_F1AP}    f1ap.UEContextSetupRequest_element
#     ...    f1ap.nRCellIdentity    00af7800b0
#     ${request_f1ap_ids}    Get Field Value Via Wireshark    ${F03_WIRESHARK_F1AP}
#     ...    f1ap.UEContextModificationRequest_element    f1ap.GNB_DU_UE_F1AP_ID
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element
#     ...    f1ap.RRCReconfigurationCompleteIndicator    0
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element
#     ...    f1ap.GNB_DUConfigurationQuery    0
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element
#     ...    f1ap.TransmissionActionIndicator    0
#     ${response_f1ap_ids}    Get Field Value Via Wireshark    ${F03_WIRESHARK_F1AP}
#     ...    f1ap.UEContextModificationResponse_element    f1ap.GNB_DU_UE_F1AP_ID
#     Lists Should Be Equal    ${request_f1ap_ids}    ${response_f1ap_ids}
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_F1AP}    f1ap.UEContextReleaseCommand_element
#     ...    f1ap.radioNetwork    0
#     Check Field Value Via Wireshark    ${F03_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element
#     ...    f1ap.dRBID    5
# 
# CB008717-5G-FK_1_B1-NR-DC_bearer_takeback_triggered_due_to_modification_of_PDU_session_containing_split_bearers(CA_established_in_SCG)
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    Init Define: 2023/11/23 10:32
#     [Tags]    FK01
#     8717 FK01 Precondition
# 
#     Filter Wireshark Log To RRC NGAP F1AP E1AP    ${FK01_WIRESHARK_LOG}    ${FK01_WIRESHARK_RRC}
#     ...    ${FK01_WIRESHARK_NGAP}   ${FK01_WIRESHARK_F1AP}   ${FK01_WIRESHARK_E1AP}
# 
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_NGAP}    ngap.InitialContextSetupRequest_element    ngap.fiveQI    7
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_NGAP}    ngap.PDUSessionResourceModifyRequest_element    ngap.fiveQI    9
#     ${ngap_qosFlowIdentifier}    Get Field Value Via Wireshark    ${FK01_WIRESHARK_NGAP}
#     ...    ngap.PDUSessionResourceModifyResponse_element    ngap.qosFlowIdentifier
# 
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_E1AP}    e1ap.BearerContextSetupRequest_element    e1ap.dRB_ID    4
#     # E1AP:BearerContextModificationRequest Cell Group To Remove with Cell Group ID set to 1 (SCG)
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.cell_Group_ID    1
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.dRB_ID    4
#     # E1AP: BearerContextModificationRequest Cell Group(SCG) and DL TX Stop set to stop
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.dL_TX_Stop    0
# 
#     # SN FR2 cell added and 8CC setup on FR2 cells
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_F1AP}    f1ap.UEContextSetupRequest_element    f1ap.sCellIndex    2,3,4,5,6,7,8
#     # UEContextModificationRequest ('Transmission Action Indicator' IE set to 'stop')
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element
#     ...    f1ap.TransmissionActionIndicator    0
#     ${request_f1ap_ids}    Get Field Value Via Wireshark    ${FK01_WIRESHARK_F1AP}
#     ...    f1ap.UEContextModificationRequest_element    f1ap.GNB_DU_UE_F1AP_ID
#     ${response_f1ap_ids}    Get Field Value Via Wireshark    ${FK01_WIRESHARK_F1AP}
#     ...    f1ap.UEContextModificationResponse_element    f1ap.GNB_DU_UE_F1AP_ID
#     Lists Should Be Equal    ${request_f1ap_ids}    ${response_f1ap_ids}
#     # both RRC Reconfiguration Complete indicator and GNB-DU Configuration Query are set to true
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element
#     ...    f1ap.RRCReconfigurationCompleteIndicator    0
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element
#     ...    f1ap.GNB_DUConfigurationQuery    0
#     # F1AP:UEContextReleaseCommand 'Radio Network Layer Cause'::'Unspecified'
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_F1AP}    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    0
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element    f1ap.dRBID    5
#     Check Field Value Via Wireshark    ${FK01_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element    f1ap.fiveQI    9,9
#     ${f1ap_qosFlowIdentifier}    Get Field Value Via Wireshark    ${FK01_WIRESHARK_F1AP}
#     ...    f1ap.UEContextModificationRequest_element    f1ap.qoSFlowIdentifier
#     List Should Contain Sub List    ${f1ap_qosFlowIdentifier}    ${ngap_qosFlowIdentifier}
# 
# CB008717-5G-KF_1_5G_PM_1180&5G_PM_781_measure_MN_Initiated_S-Node_Release_procedure_which_releases_the_NR-DC_via_takeback
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    Init Define: 2024/01/16 14:28
#     [Tags]    KF01
#     8717 KF01 Precondition
# 
#     Filter Wireshark Log To RRC NGAP F1AP E1AP    ${KF01_WIRESHARK_LOG}    ${KF01_WIRESHARK_RRC}
#     ...    ${KF01_WIRESHARK_NGAP}   ${KF01_WIRESHARK_F1AP}   ${KF01_WIRESHARK_E1AP}
# 
#     Check Field Value Via Wireshark    ${KF01_WIRESHARK_NGAP}    ngap.PDUSessionResourceModifyRequest_element    ngap.fiveQI    9
#     # qosFlowIdentifier: 22, fiveQI: 9
#     ${ngap_qosFlowIdentifier}    Get Field Value Via Wireshark    ${KF01_WIRESHARK_NGAP}
#     ...    ngap.PDUSessionResourceModifyResponse_element    ngap.qosFlowIdentifier
# 
#     Check Field Value Via Wireshark    ${KF01_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.cell_Group_ID    1
#     Check Field Value Via Wireshark    ${KF01_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.dRB_ID    4
#     Check Field Value Via Wireshark    ${KF01_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.dRB_ID    5
#     # dRB-ID: 5, qoS-Flow-Identifier: 22, fiveQI: 9
#     ${e1ap_qosFlowIdentifier}    Get Field Value Via Wireshark    ${KF01_WIRESHARK_E1AP}
#     ...    e1ap.BearerContextModificationRequest_element    e1ap.qoS_Flow_Identifier
#     List Should Contain Sub List    ${e1ap_qosFlowIdentifier}    ${ngap_qosFlowIdentifier}
#     #Check Field Value Via Wireshark    ${KF01_WIRESHARK_E1AP}    e1ap.BearerContextInactivityNotification_element    e1ap.uE_Activity    1
# 
#     # dL-TX-Stop: stop (0)
#     Check Field Value Via Wireshark    ${KF01_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.dL_TX_Stop    0
# 
#     Check Field Value Via Wireshark    ${KF01_WIRESHARK_F1AP}    f1ap.UEContextSetupRequest_element    f1ap.sCellIndex    2,3,4,5,6,7,8
#     # TransmissionActionIndicator: stop (0)
#     Check Field Value Via Wireshark    ${KF01_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element
#     ...    f1ap.TransmissionActionIndicator    0
#     # radioNetwork: unspecified (0)
#     Check Field Value Via Wireshark    ${KF01_WIRESHARK_F1AP}    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    0
# 
#     # SCGIndicator: released (0)
#     ${count1}    Get Field Value Count Via Wireshark
#     ...    ${KF01_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element    f1ap.SCGIndicator    0
#     Should Be True    ${count1}==1
#     ${count2}    Get Field Value Count Via Wireshark
#     ...    ${KF01_WIRESHARK_NGAP}    ngap.UEContextReleaseRequest_element    ngap.radioNetwork    20
#     ${count}    Evaluate    ${count1}+${count2}
#     # Check with webem after step5 call release: Counter NRDC_IA_MN_CU_REQ
#     Verify CB008717 KF Counters Update Normal    29_except_counter_value=${count}
# 
#     UE airplane mode  switch=0
# 
#      [Teardown]   Run Keywords    UE Stop Traffic And Release UE    AND
#     ...    Wait Until Keyword Succeeds    3 times   30s  UE screen unlock and Switch Apn  apn_name=mdrb.nokia.com
# 
# CB008717-5G-KF_2_5G_PM_1180_measure_complete_UE_Context_Release_procedures
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    Init Define: 2024/01/19 17:11
#     [Tags]    KF02
#     8717 KF02 Precondition
# 
#     Filter Wireshark Log To RRC NGAP F1AP E1AP    ${KF02_WIRESHARK_LOG}    ${KF02_WIRESHARK_RRC}
#     ...    ${KF02_WIRESHARK_NGAP}   ${KF02_WIRESHARK_F1AP}   ${KF02_WIRESHARK_E1AP}
# 
#     Check Field Value Via Wireshark    ${KF02_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.cell_Group_ID    1
#     Check Field Value Via Wireshark    ${KF02_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.dRB_ID    4
#     Check Field Value Via Wireshark    ${KF02_WIRESHARK_E1AP}    e1ap.BearerContextInactivityNotification_element    e1ap.uE_Activity    1
#     # e1ap radioNetwork: normal-release (20)
#     Check Field Value Via Wireshark    ${KF02_WIRESHARK_E1AP}    e1ap.BearerContextReleaseCommand_element    e1ap.radioNetwork    20
# 
#     ${count}    Get Field Value Count Via Wireshark
#     ...    ${KF02_WIRESHARK_NGAP}    ngap.UEContextReleaseRequest_element    ngap.radioNetwork    20
#     # Check with webem after step5 call release: Counter NRDC_IA_MN_CU_REQ
#     Verify CB008717 KF02 Counters Update Normal    29_except_counter_value=${count}
# 
#     # f1ap radioNetwork: normal-release (10)
#     Check Field Value Via Wireshark    ${KF02_WIRESHARK_F1AP}    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    10
# 
#     UE airplane mode  switch=0
# 
#      [Teardown]   Run Keywords    UE Stop Traffic And Release UE    AND
#     ...    Wait Until Keyword Succeeds    3 times   30s  UE screen unlock and Switch Apn  apn_name=mdrb.nokia.com
# 
# CB008717-5G-KF_8_5G_PM_781_measure_bearers(QoS_Flow_level)_takeback_procedure_due_to_reception_of_PDU_Session_Resource_Modify_with_QoS_Flow_Release
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    Init Define: 2024/01/22 16:35
#     [Tags]    KF08
#     8717 KF08 Precondition
# 
#     Verify CB008717 KF08 Counters Update Normal
# 
#     Filter Wireshark Log To RRC NGAP F1AP E1AP    ${KF08_WIRESHARK_LOG}    ${KF08_WIRESHARK_RRC}
#     ...    ${KF08_WIRESHARK_NGAP}   ${KF08_WIRESHARK_F1AP}   ${KF08_WIRESHARK_E1AP}
# 
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_NGAP}    ngap.InitialContextSetupRequest_element    ngap.fiveQI    7,8
#     ${init_qos}    Get Field Value Via Wireshark    ${KF08_WIRESHARK_NGAP}
#     ...    ngap.InitialContextSetupRequest_element    ngap.qosFlowIdentifier
#     ${pdu_qos}    Get Field Value Via Wireshark    ${KF08_WIRESHARK_NGAP}
#     ...    ngap.PDUSessionResourceModifyRequest_element    ngap.qosFlowIdentifier
#     Should Contain    ${init_qos[0]}    ${pdu_qos[0]}
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_NGAP}    ngap.PDUSessionResourceModifyResponse_element    ngap.pDUSessionID    1
# 
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_E1AP}    e1ap.BearerContextSetupRequest_element    e1ap.fiveQI    7,8
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_E1AP}    e1ap.BearerContextSetupRequest_element    e1ap.dRB_ID    4,5
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.cell_Group_ID    1,1
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.dRB_ID    4,5
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.dRB_ID    5
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.dRB_ID    4,5
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_E1AP}    e1ap.BearerContextModificationRequest_element    e1ap.dL_TX_Stop    0,0
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_E1AP}    e1ap.BearerContextModificationResponse_element    e1ap.dRB_ID    4,5
# 
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element    f1ap.TransmissionActionIndicator    0
#     ${fpap_id_request}    Get Field Value Via Wireshark    ${KF08_WIRESHARK_F1AP}
#     ...    f1ap.UEContextModificationRequest_element    f1ap.GNB_DU_UE_F1AP_ID
#     ${fpap_id_response}    Get Field Value Via Wireshark    ${KF08_WIRESHARK_F1AP}
#     ...    f1ap.UEContextModificationResponse_element    f1ap.GNB_DU_UE_F1AP_ID
#     Should Be Equal    ${fpap_id_request}    ${fpap_id_response}
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element    f1ap.SCGIndicator    0
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element
#     ...    f1ap.RRCReconfigurationCompleteIndicator    0
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_F1AP}    f1ap.UEContextModificationRequest_element    f1ap.GNB_DUConfigurationQuery    0
#     Check Field Value Via Wireshark    ${KF08_WIRESHARK_F1AP}    f1ap.UEContextReleaseCommand_element    f1ap.radioNetwork    0
# 
# *** Keywords ***
# 8717 102 Precondition
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    ${SCF_102}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
#     Start To Capture Wireshark Log From DU
#     UE Attach And Start Traffic Wait Check Throughput
#     Sleep    10s
#     ${ue_type}    translate power ue type from testline    0
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
#     Sleep    120s
#     power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
#     Stop To Capture Wireshark Log From DU    local_pcap_path=${102_WIRESHARK_LOG}
# 
# 8717 105 Precondition
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    ${SCF_105}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
#     ...    parameter=administrativeState    value=Locked
#     Sleep    30s
#     Start To Capture Wireshark Log From DU
#     UE Attach And Start Traffic Wait Check Throughput
#     Sleep    3s
#     Stop To Capture Wireshark Log From DU    local_pcap_path=${105_WIRESHARK_LOG}
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
#     ...    parameter=administrativeState    value=Unlocked
# 
# 8717 202 Precondition
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    ${SCF_202}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
#     Start To Capture Wireshark Log From DU
#     UE Attach And Start Traffic Wait Check Throughput
#     Sleep    15s
#     ${ue_type}    translate power ue type from testline    0
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
#     Sleep    120s
#     UE Mobile Data Disable
#     Sleep    10s
#     power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
#     Stop To Capture Wireshark Log From DU    local_pcap_path=${202_WIRESHARK_LOG}
# 
# 8717 107 Precondition
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    ${SCF_107}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
#     SISO Coam Suite Setup
#     Selenium Login With Version
#     Start To Capture Wireshark Log From DU
#     UE Attach And Start Traffic Wait Check Throughput
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
#     ...    parameter=administrativeState    value=Locked
#     selenium_sbts.block_cell    1
#     Stop To Capture Wireshark Log From DU    local_pcap_path=${107_WIRESHARK_LOG}
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
#     ...    parameter=administrativeState    value=Unlocked
#     selenium_sbts.unblock_cell    1
#     ${ue_type}    translate power ue type from testline    0
#     power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
#     Run Keyword And Ignore Error    SISO Coam Suite Teardown
# 
# 8717 206 Precondition
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    ${SCF_206}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
#     SISO Coam Suite Setup
#     Selenium Login With Version
#     Start To Capture Wireshark Log From DU
#     UE Attach And Start Traffic Wait Check Throughput
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
#     ...    parameter=qRxLevMin    value=-60
#     Sleep    10s
#     selenium_sbts.block_cell    1
#     Sleep    10s
#     selenium_sbts.unblock_cell    1
#     Sleep    10s
#     ${ue_type}    translate power ue type from testline    0
#     power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
#     Stop To Capture Wireshark Log From DU    local_pcap_path=${206_WIRESHARK_LOG}
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
#     SISO Coam Suite Teardown
# 
# 8717 207 Precondition
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    ${SCF_207}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
#     Start To Capture Wireshark Log From DU
#     UE Attach And Start Traffic Wait Check Throughput
#     Sleep    5s
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
#     ...    parameter=qRxLevMin    value=-60
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
#     ...    parameter=dlMimoMode    value=4x4 or 4x2 Open Loop Spatial Multiplexing
#     Sleep    10s
#     ${ue_type}    translate power ue type from testline    0
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
#     Sleep    120s
#     UE Mobile Data Disable
#     Sleep    5s
#     power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
#     Stop To Capture Wireshark Log From DU    local_pcap_path=${207_WIRESHARK_LOG}
# 
# 8717 F03 Precondition
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    ${SCF_F03}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
#     Start To Capture Wireshark Log From DU
#     UE Attach And Start Traffic Wait Check Throughput
#     UE Start DL Traffic    throughput=500M    dl_time=200    dl_port=45005    hostname=10.71.219.27    alias=APPserver2
#     UE Start UL Traffic    throughput=50M    appserver_addr=10.71.219.27    ul_port=45005
#     Sleep    10s
#     modify_pdu_via_update_ncp_rule
#     Sleep    10s
#     ${ue_type}    translate power ue type from testline    0
#     power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
#     Stop To Capture Wireshark Log From DU    local_pcap_path=${F03_WIRESHARK_LOG}
# 
# 8717 FK01 Precondition
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    Init Define: 2023/11/23 10:47
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    ${SCF_FK01}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
#     Wait Until Keyword Succeeds     3 times   30s    UE screen unlock and Switch Apn
#     Start To Capture Wireshark Log From DU
#     UE Attach With Verify Attach
# 
#     UE Start UL&DL UDP Traffic    ul_tp=80M    dl_tp=2000M    duration=1200
#     Sleep    10s
#     modify_pdu_via_update_ncp_rule    rule_name=ADD5QI9-ZYH
#     Sleep    10s
#     UE Stop Traffic And Release UE
#     Stop To Capture Wireshark Log From DU    local_pcap_path=${FK01_WIRESHARK_LOG}
#     [Teardown]    Wait Until Keyword Succeeds     3 times   30s
#     ...      UE screen unlock and Switch Apn  apn_name=mdrb.nokia.com
# 
# 8717 KF01 Precondition
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    Init Define: 2024/01/16 17:10
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    ${SCF_KF01}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
# 
#     Wait Until Keyword Succeeds     3 times   30s    UE screen unlock and Switch Apn
# 
#     Sleep    60s
#     ${date}    Get Current Date
#     ${counter_start_time}    Convert Date    ${date}    epoch
#     Set Global Variable    ${COUNTER_START_TIME}
# 
#     Start To Capture Wireshark Log From DU
#     UE Attach With Verify Attach
#     UE Start UL&DL UDP Traffic    ul_tp=50M    dl_tp=1100M    duration=1200
#     ...    ul_port=45005    dl_port=45005    appserver_addr=${tl.appservers[0].iperf_details.network_interface_address}
#     Sleep    60s
#     modify_pdu_via_update_ncp_rule    rule_name=ADD5QI9-ZYH
#     UE Start UL&DL UDP Traffic    ul_tp=40M    dl_tp=300M    duration=1200
#     Sleep    60s
#     ${ue_type}    translate power ue type from testline    0
#     UE airplane mode  switch=1
#     Stop To Capture Wireshark Log From DU    local_pcap_path=${KF01_WIRESHARK_LOG}
#     #power_ue.UE Detach    ue_type=${ue_type}   ue_index=${0}
# 
# 8717 KF02 Precondition
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    Init Define: 2024/01/19 17:13
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    ${SCF_KF02}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
# 
#     Wait Until Keyword Succeeds     3 times   30s    UE screen unlock and Switch Apn
# 
#     Sleep    60s
#     ${date}    Get Current Date
#     ${counter_start_time}    Convert Date    ${date}    epoch
#     Set Global Variable    ${COUNTER_START_TIME}
# 
#     Start To Capture Wireshark Log From DU
#     UE Attach With Verify Attach
#     UE Start UL&DL UDP Traffic    ul_tp=60M    dl_tp=300M    duration=1200
#     Sleep    10s
#     ${ue_type}    translate power ue type from testline    0
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
#     Sleep    120s
#     UE airplane mode  switch=1
#     Stop To Capture Wireshark Log From DU    local_pcap_path=${KF02_WIRESHARK_LOG}
#     #power_ue.UE Detach    ue_type=${ue_type}   ue_index=${0}
# 
# 8717 KF08 Precondition
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    Init Define: 2024/01/22 17:25
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    ${SCF_KF08}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
#     #UE screen unlock
#     Start To Capture Wireshark Log From DU
#     UE Attach With Verify Attach
#     #UE Switch Apn After Attach    ui_version=${None}    apn_name=mdrb.nokia.com
#     UE Start UL&DL UDP Traffic    ul_tp=30M    dl_tp=300M    duration=1200
#     ...    ul_port=45005    dl_port=45005    appserver_addr=${tl.appservers[0].iperf_details.network_interface_address}
#     UE Start UL&DL UDP Traffic    ul_tp=50M    dl_tp=500M    duration=1200
#     modify_pdu_via_update_ncp_rule    rule_name=DEL5QI8-PZ3-ZYH
#     Sleep    10s
#     UE Stop Traffic And Release UE
#     Stop To Capture Wireshark Log From DU    local_pcap_path=${KF08_WIRESHARK_LOG}
#     Sleep    120s
# 
# Clear Tmp Wireshark Csv
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Arguments]    ${file_prefix}
#     OperatingSystem.Run    rm -rf ${file_prefix}_*
# 
# Check Multi Cell Group And DRB
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Arguments]    ${wireshark_log}    ${drbids}=4,5    ${cell_group_1}=5c42b1
#     Check Field Value Via Wireshark    ${wireshark_log}    f1ap.UEContextSetupResponse_element
#     ...    f1ap.dRBID    ${drbids}
#     ${cell_group_ids}    Get Field Value Via Wireshark    ${wireshark_log}    f1ap.UEContextSetupResponse_element
#     ...    f1ap.cellGroupConfig
#     Should Contain    ${cell_group_ids[-1]}    ${cell_group_1}
# 
# UE screen unlock and Switch Apn
#     [Documentation]    Author: felix.zhu@nokia-sbell.com
#     [Arguments]  ${ue_index}=0    ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${ui_version}=${None}   ${apn_name}=mdrb1.nokia.com
#     Connect to control pc enhanced    ue_index=${ue_index}
#     Repeat Keyword      2 times      csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
#     ...    connection=cpc_${ue_index}
#     csn.send_command    command=adb -s ${serial_number} shell settings put system screen_off_timeout 2147483640
#     ...    connection=cpc_${ue_index}
# 
#     csn.disconnect    connection=cpc_${ue_index}
# 
#     UE airplane mode  switch=0
# 
#     UE Switch Apn After Attach    ui_version=${ui_version}    apn_name=${apn_name}
# 
#     UE airplane mode  switch=1
# 
# 
# UE airplane mode
#     [Documentation]    Author: felix.zhu@nokia-sbell.com
#     [Arguments]  ${ue_index}=0    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${switch}=0
#     Connect to control pc enhanced    ue_index=${ue_index}
#     csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on ${switch}
#     ...    connection=cpc_${ue_index}
#     csn.disconnect    connection=cpc_${ue_index}
