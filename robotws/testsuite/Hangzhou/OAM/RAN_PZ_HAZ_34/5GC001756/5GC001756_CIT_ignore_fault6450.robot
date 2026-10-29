*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ./Resource/Common.robot

Force Tags   SG_07   CA_5G_OAM    CIT_TRUNK   CDRT_22R2   CRT_22R2   CIT_22R3   CIT_22R4   CIT   SBTS00   STATE_SW_UPLOADED
...   CDRT_22R3   CDRT_22R4
...   RAN_5G   RAN_5G_TDD   5G_RAN   5G_RAN_TDD   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIKL_ABILB1_AEQN_NETACT

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

5GC001756_D_14_SA_ClassicalgNB_Streaming_PCMD_Cell_Trace_combined
    [Documentation]   Author: yin.4.chen@nokia-sbell.com
    [Setup]   Case Setup: D_14
    D_14_SA_ClassicalgNB_Streaming_PCMD_Cell_Trace_combined
    [Teardown]   Case Teardown: D_14

5GC001756_D_15_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SUlSchedulingTraceRecord_Allfields
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Setup]   Case Setup: D_15
    D_15_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SUlSchedulingTraceRecord_Allfields
    [Teardown]   Case Teardown: D_15

5GC001756_D_16_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SDlSchedulingTraceRecord_Allfields
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Setup]   Case Setup: D_16
    D_16_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SDlSchedulingTraceRecord_Allfields
    [Teardown]   Case Teardown: D_16

5GC001756_D_17_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_ULRLCTraceRecord_Allfields
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Setup]   Case Setup: D_17
    D_17_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_ULRLCTraceRecord_Allfields
    [Teardown]   Case Teardown: D_17

5GC001756_D_18_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_DLRLCTraceRecord_Allfields
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Setup]   Case Setup: D_18
    D_18_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_DLRLCTraceRecord_Allfields
    [Teardown]   Case Teardown: D_18

5GC001756_D_19_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SBeamUsageTraceRecord_Allfields
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Setup]   Case Setup: D_19
    D_19_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SBeamUsageTraceRecord_Allfields
    [Teardown]   Case Teardown: D_19

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

5GC001756_G_30_SA_ClassicalgNB_Streaming_PCMD_Uplane_Multiple_Bearers_report
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Setup]   Case Setup: G_30
    G_30_SA_ClassicalgNB_Streaming_PCMD_Uplane_Multiple_Bearers_report
    [Teardown]   Case Teardown: G_30

5GC001756_G_31_SA_ClassicalgNB_Streaming_PCMD_Uplane_measuremnt_report_period
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Setup]   Case Setup: G_31
    G_31_SA_ClassicalgNB_Streaming_PCMD_Uplane_measuremnt_report_period
    [Teardown]   Case Teardown: G_31

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

CB008187_SR_D_Classical_SA_01_RAN_UE_ID_Sent_by_gNB_CU_CP_during_initial_access
    Check PCMD RAN UE ID   pcmd_file_path=${TCPDUMP_PATH}

CB008187_SR_D_Classical_SA_02_RAN_UE_ID_Sent_by_gNB_DU_during_initial_access
    Check PCMD RAN UE ID   pcmd_file_path=${TCPDUMP_PATH}


*** Keywords ***
Common Suite Setup
#    Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    robot_common_operations.Common Suite Setup
    AlarmWatchdog.add_allow_alarms    fault_id=6450
    ${TEST_NAME}   Set Variable   Suite_Setup
    Common Setup 1756
    Remove And Add PCMD Object
    Make L3CALL And Get ALL PCMD MSG
    ${all_pcmd_timestamp}   get_all_pcmd_timestamp   source_file=${TXT_FILE}
    Set Suite Variable   ${ALL_PCMD_TIMESTAMP}
    ${Reset_Reason}   Get Last Reset from Blackbox
    Set Suite Variable   ${RESET_REASON}

Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    ${TEST_NAME}   Set Variable   Suite_Teardown
    Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Catch Snapshot COAM
    Common Teardown 1756
