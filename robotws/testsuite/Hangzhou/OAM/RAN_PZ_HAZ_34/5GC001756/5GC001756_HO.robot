*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ./Resource/Common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot

Force Tags   SG_07   CA_5G_OAM   CRT   master_classicalbts_all
...    PY36
...   5G_RAN_TDD   CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_AZQJ_NETACT   STATE_SW_UPLOADED
...   AUTHOR_yin.4.chen@nokia-sbell.com

Test Timeout   24h

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown

*** Variables ***
@{ALL_TEST_STATUS}
*** Test Cases ***
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# every case every call
#5GC001756_EA_25_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_intra_HO
#    [Documentation]   Author: yin.4.chen@nokia-sbell.com
#    [Setup]   Case Setup: EA_25
#    EA_25_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_intra_HO
#    [Teardown]   Case Teardown: EA_25

#5GC001756_EA_26_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_inter_gnb_HO
#    [Documentation]   Author: yin.4.chen@nokia-sbell.com
#    [Setup]   run keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}   AND   Case Setup: EA_26
#    EA_26_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_inter_gnb_HO
#    [Teardown]   Case Teardown: EA_26

#5GC001756_EA_36_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record_intra_gnb_HO
#    [Documentation]   Author: yin.4.chen@nokia-sbell.com
#    [Setup]   run keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}   AND   Case Setup: EA_36
#    EA_36_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record_intra_gnb_HO
#    [Teardown]   Case Teardown: EA_36

#5GC001756_EA_37_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record_inter_gnb_HO
#    [Documentation]   Author: yin.4.chen@nokia-sbell.com
#    [Setup]   run keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}   AND   Case Setup: EA_37
#    EA_37_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record_inter_gnb_HO
#    [Teardown]   Case Teardown: EA_37

#5GC001756_EA_38_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record_intra_gnb_HO
#    [Documentation]   Author: yin.4.chen@nokia-sbell.com
#    [Setup]   run keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}   AND   Case Setup: EA_38
#    EA_38_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record_intra_gnb_HO
#    [Teardown]   Case Teardown: EA_38

#5GC001756_EA_39_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record_inter_gnb_HO
#    [Documentation]   Author: yin.4.chen@nokia-sbell.com
#    [Setup]   run keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}   AND   Case Setup: EA_39
#    EA_39_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record_inter_gnb_HO
#    [Teardown]   Case Teardown: EA_39

#5GC001756_EA_40_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UeDuConnectivity_Record_inter_gnb_HO
#    [Documentation]   Author: yin.4.chen@nokia-sbell.com
#    [Setup]   run keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}   AND   Case Setup: EA_40
#    EA_40_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UeDuConnectivity_Record_inter_gnb_HO
#    [Teardown]   Case Teardown: EA_40

#5GC001756_B_35_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance_in_Intra_gNB_Intra_cell_HO_for_SA
#    [Documentation]   Author: liping.hong@nokia-sbell.com
#    [Setup]   run keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}   AND   Case Setup: B_35
#    B_35_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance_in_Intra_gNB_Intra_cell_HO_for_SA
#    [Teardown]   Case Teardown: B_35

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
# Second Cell
#5GC001756_D_11_SA_ClassicalgNB_PCMD_Report_after_lock_second_cell
#    [Documentation]   Author: yin.4.chen@nokia-sbell.com
#    [Setup]   run keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}   AND   Case Setup: D_11
#    D_11_SA_ClassicalgNB_PCMD_Report_after_lock_second_cell
#    [Teardown]   Case Teardown: D_11

# 5GC001756_D_34_SA_ClassicalgNB_PCMD_Report_after_add_cell_online
#     [Documentation]   Author: yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: D_34
#     D_34_SA_ClassicalgNB_PCMD_Report_after_add_cell_online
#     [Teardown]   Case Teardown: D_34

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
5GC001756_SA_ClassicalgNB_StreamingPCMD_Cplane_Records_for_Intra_gnb_HO_and_Inter_gnb_HO
    [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Run Keyword And Continue On Failure    5GC001756_EA_25_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_intra_HO
    Run Keyword And Continue On Failure    5GC001756_EA_26_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_inter_gnb_HO
    Run Keyword And Continue On Failure
    ...   5GC001756_EA_36_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record_intra_gnb_HO
    Run Keyword And Continue On Failure
    ...   5GC001756_EA_37_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record_inter_gnb_HO
    Run Keyword And Continue On Failure    5GC001756_EA_38_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record_intra_gnb_HO
    Run Keyword And Continue On Failure    5GC001756_EA_39_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record_inter_gnb_HO
    Run Keyword And Continue On Failure    5GC001756_EA_40_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UeDuConnectivity_Record_inter_gnb_HO
    Run Keyword And Continue On Failure
    ...   5GC001756_B_35_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance_in_Intra_gNB_Intra_cell_HO_for_SA
    Run Keyword And Continue On Failure    5GC001756_D_11_SA_ClassicalgNB_PCMD_Report_after_lock_second_cell
#    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#    List Should Not Contain Value    ${ALL_TEST_STATUS}    FAIL
#    Log To Console   total case restult is ${ALL_TEST_STATUS}
    [Teardown]   robot_common_operations.Common Case Teardown
*** Keywords ***
Common Suite Setup
    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    ${TEST_NAME}   Set Variable   Suite_Setup
    Common Setup 1756
    Get HO Suite Variables

    Remove And Add PCMD Object
    Trigger INTRA HO

    Remove And Add PCMD Object
    Trigger INTER HO

    Run Keyword And Ignore Error   Initialize PA

Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    Check Extra Reset From Blackbox
    Initialize PA
    Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Catch Snapshot COAM
    Common Teardown 1756
    ${hisory_faults_whitelist}   Create List   7311
    Check Unexpected History Faults   hisory_faults_whitelist=${hisory_faults_whitelist}

5GC001756_EA_25_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_intra_HO
    Case Setup: EA_25
    EA_25_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_intra_HO
    [Teardown]   Case Teardown: EA_25

5GC001756_EA_26_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_inter_gnb_HO
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    Case Setup: EA_26
    EA_26_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_inter_gnb_HO
    [Teardown]   Case Teardown: EA_26

5GC001756_EA_36_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record_intra_gnb_HO
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    Case Setup: EA_36
    EA_36_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record_intra_gnb_HO
    [Teardown]   Case Teardown: EA_36

5GC001756_EA_37_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record_inter_gnb_HO
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    Case Setup: EA_37
    EA_37_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record_inter_gnb_HO
    [Teardown]   Case Teardown: EA_37

5GC001756_EA_38_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record_intra_gnb_HO
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    Case Setup: EA_38
    EA_38_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record_intra_gnb_HO
    [Teardown]   Case Teardown: EA_38

5GC001756_EA_39_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record_inter_gnb_HO
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    Case Setup: EA_39
    EA_39_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record_inter_gnb_HO
    [Teardown]   Case Teardown: EA_39

5GC001756_EA_40_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UeDuConnectivity_Record_inter_gnb_HO
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    Case Setup: EA_40
    EA_40_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UeDuConnectivity_Record_inter_gnb_HO
    [Teardown]   Case Teardown: EA_40

5GC001756_B_35_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance_in_Intra_gNB_Intra_cell_HO_for_SA
    [Documentation]   Author: liping.hong@nokia-sbell.com
    Case Setup: B_35
    B_35_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance_in_Intra_gNB_Intra_cell_HO_for_SA
    [Teardown]   Case Teardown: B_35

5GC001756_D_11_SA_ClassicalgNB_PCMD_Report_after_lock_second_cell
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    Case Setup: D_11
    D_11_SA_ClassicalgNB_PCMD_Report_after_lock_second_cell
    [Teardown]   Case Teardown: D_11
