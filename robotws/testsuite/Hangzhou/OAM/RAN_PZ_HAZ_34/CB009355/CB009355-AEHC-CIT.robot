*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define CB009355 15MHZ cases
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009355/Resource/CB009355_common.robot


Suite Setup   robot_common_operations.Common Suite Setup
Suite Teardown   robot_common_operations.Common Suite Teardown

*** Variables ***
@{ALL_TEST_STATUS}
@{L3CALL_CELLID_LIST}    1


*** Test Cases ***
[2]CB009355_076_Long_PUCCH_resource_optimization_interaction_with_2_BWP_prbblank_15Mhz
   [Tags]   24R3
   [Setup]
   AlarmWatchdog.add_allow_alarms    fault_id=4459
   run keyword and continue on failure   CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_SA_AEHC_PRBBLANK_33
   run keyword and continue on failure   CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_SA_AEHC_PRBBLANK_44
   [Teardown]

*** Keywords ***
CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_SA_AEHC_PRBBLANK_33
    [Timeout]   3h
    Case Setup for CB009355    x2_enb_mrbtsId=8581    gnbmode=NSA
    Set L3 CALL param CB009355    runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank33
    Admin Change RRM params by list    param_change=${admin_param_change}    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank33
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Modify disableSchedAssistRfCooling to false in Venfor file    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank33
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AEHC']['5GC001116_0ms_15MHZ_multibwp']}   att_index=${PA_Value['AEHC']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB009355
    ...     runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank33    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
    ...    reset_flag=True    framestruct=5GC001116_0ms_15MHZ_multibwp    runame=AEHC   reset_times=3
    ...    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    [Teardown]    Case Teardown for CB009355

CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_SA_AEHC_PRBBLANK_44
    [Timeout]   3h
    Case Setup for CB009355    x2_enb_mrbtsId=8581    gnbmode=NSA
    Set L3 CALL param CB009355    runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank44
    Admin Change RRM params by list   param_change=${admin_param_change}    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank44
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Modify disableSchedAssistRfCooling to false in Venfor file    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank44
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AEHC']['5GC001116_0ms_15MHZ_multibwp']}   att_index=${PA_Value['AEHC']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB009355
    ...     runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank44    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001116_0ms_15MHZ_multibwp    runame=AEHC   reset_times=3
#    ...    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    [Teardown]    Case Teardown for CB009355



