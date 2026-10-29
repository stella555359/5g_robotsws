*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ./Resource/Common.robot

Force Tags   SG_07   CA_5G_OAM   STATE_SW_UPDATED   RAN_5G   RAN_5G_TDD
...   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIKL_ABILB1_AEQN_NETACT    CRT_UTE   SBTS00
...   AUTHOR_yin.4.chen@nokia-sbell.com

Test Timeout   2h

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown

*** Variables ***
${ue_index}   ${0}

*** Test Cases ***
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
# all case one call
5GC001756_B_7_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_SINR
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Setup]   Case Setup: B_7
    B_7_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_SINR
    [Teardown]   Case Teardown: B_7

5GC001756_B_8_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Setup]   Case Setup: B_8
    B_8_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance
    [Teardown]   Case Teardown: B_8

5GC001756_D_12_SA_ClassicalgNB_Reset_After_PCMD_Time_Zone_Check
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    [Setup]   Case Setup: D_12
    D_12_SA_ClassicalgNB_Reset_After_PCMD_Time_Zone_Check
    [Teardown]   Case Teardown: D_12

5GC001756_EA_21_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Setup]   Case Setup: EA_21
    EA_21_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record
    [Teardown]   Case Teardown: EA_21

5GC001756_EA_41_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_for_Pdu_Session_Resource_Setup
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Setup]   Case Setup: EA_41
    EA_41_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_for_Pdu_Session_Resource_Setup
    [Teardown]   Case Teardown: EA_41

5GC001756_EA_42_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_for_Pdu_Session_Resource_Release
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Setup]   Case Setup: EA_42
    EA_42_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_for_Pdu_Session_Resource_Release
    [Teardown]   Case Teardown: EA_42

CB008208-5G-A-12_Classical_gNB-CU_Bearer_record_for_SA_Initial_Context_Setup
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Setup]   Case Setup: CB008208-5G-A-12
    CB008208-5G-A-12_Classical_gNB-CU_Bearer_record_for_SA_Initial_Context_Setup
    [Teardown]   Case Teardown: CB008208-5G-A-12

CB008208-5G-A-13_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Setup
    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
    [Setup]   Case Setup: CB008208-5G-A-13
    CB008208-5G-A-13_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Setup
    [Teardown]   Case Teardown: CB008208-5G-A-13

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
5GC001756_B_3_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_WebEM
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Setup]   Case Setup: B_3
    B_3_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_WebEM
    [Teardown]   Case Teardown: B_3

5GC001756_B_5_SA_ClassicalgNB_PCMD_Deactivation_From_WebEM
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Setup]   Case Setup: B_5
    B_5_SA_ClassicalgNB_PCMD_Deactivation_From_WebEM
    [Teardown]   Case Teardown: B_5

5GC001756_B_4_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_NetAct
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Setup]   Case Setup: B_4
    B_4_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_NetAct
    [Teardown]   Case Teardown: B_4

5GC001756_B_6_SA_ClassicalgNB_PCMD_Deactivation_From_NetAct
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Setup]   Case Setup: B_6
    B_6_SA_ClassicalgNB_PCMD_Deactivation_From_NetAct
    [Teardown]   Case Teardown: B_6

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
# every case every call
5GC001756_D_10_SA_ClassicalgNB_Reset_After_PCMD_Activation
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Setup]   Case Setup: D_10
    D_10_SA_ClassicalgNB_Reset_After_PCMD_Activation
    [Teardown]   Case Teardown: D_10

5GC001756_D_32_SA_ClassicalgNB_PCMD_Report_after_cell_from_lock_to_unlock
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    [Setup]   Case Setup: D_32
    D_32_SA_ClassicalgNB_PCMD_Report_after_cell_from_lock_to_unlock
    [Teardown]   Case Teardown: D_32

5GC001756_D_33_SA_ClassicalgNB_PCMD_Report_after_RU_reset
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    [Setup]   Case Setup: D_33
    D_33_SA_ClassicalgNB_PCMD_Report_after_RU_reset
    [Teardown]   Case Teardown: D_33

#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------
CB008187_SR_D_Classical_Common_01_RAN_UE_ID_Activation_of_MBA_functionality_on_the_gNB_CU
    [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check PCMD RAN UE ID   pcmd_file_path=${TCPDUMP_PATH}

CB008187_SR_D_Classical_Common_02_RAN_UE_ID_Deactivation_of_MBA_functionality_on_the_gNB_CU
    [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check PCMD RAN UE ID   pcmd_file_path=${TCPDUMP_PATH}

CB008187_SR_D_Classical_Common_03_RAN_UE_ID_Activation_of_MBA_functionality_on_the_gNB_DU
    [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check PCMD RAN UE ID   pcmd_file_path=${TCPDUMP_PATH}

CB008187_SR_D_Classical_Common_04_RAN_UE_ID_Deactivation_of_MBA_functionality_on_the_gNB_DU
    [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check PCMD RAN UE ID   pcmd_file_path=${TCPDUMP_PATH}

CB008187_SR_D_Classical_SA_01_RAN_UE_ID_Sent_by_gNB_CU_CP_during_initial_access
    [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check PCMD RAN UE ID   pcmd_file_path=${TCPDUMP_PATH}

CB008187_SR_D_Classical_SA_02_RAN_UE_ID_Sent_by_gNB_DU_during_initial_access
    [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check PCMD RAN UE ID   pcmd_file_path=${TCPDUMP_PATH}

*** Keywords ***
Common Suite Setup
    # Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    robot_common_operations.Common Suite Setup
    ${TEST_NAME}   Set Variable   Suite_Setup
    Common Setup 1756
    Remove And Add PCMD Object
    Make L3CALL And Get ALL PCMD MSG
    ${all_pcmd_timestamp}   get_all_pcmd_timestamp   source_file=${TXT_FILE}
    Set Suite Variable   ${ALL_PCMD_TIMESTAMP}
    Get PCMD Value
    ${Reset_Reason}   Get Last Reset from Blackbox
    Set Suite Variable   ${RESET_REASON}

Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    Run Keyword And Ignore Error   COAM WEBUI Logout
    Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Catch Snapshot COAM
    Common Teardown 1756
    ${hisory_faults_whitelist}   Create List   7311
    Check Unexpected History Faults   hisory_faults_whitelist=${hisory_faults_whitelist}
