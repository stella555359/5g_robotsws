*** Settings ***
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB010611/Resource/CB010611_common.robot


Suite Setup   robot_common_operations.Common Suite Setup
Suite Teardown   robot_common_operations.Common Suite Teardown

*** Variables ***
@{ALL_TEST_STATUS}

*** Test Cases ***
#[1]CB010611-SR-C-B1_004_Online_modify_bandwidth_from_30MHz_to_50MHz_AZHA
#    [Timeout]   5h
#    [Setup]    Case Setup for CB010611
#    Set L3 CALL param CB010611    runame=AZHA    framestruct=5GC001208_30MHZ
##    Webem Change RRM params by list   ${param_change}    runame=AZHA     framestruct=5GC001208_30MHZ  aleady 1208 at original scf
#    Set the HBTE PA value    value_list=${PA_Value['AZHA']['5GC001208_30MHZ']}   att_index=${PA_Value['AZHA']['att_index']}
#    Start Capture Wireshark at gNB    nglogname=axis_0
#    PEAK L3 CALL Process CB010611
#    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    Set L3 CALL param CB010611    runame=AZHA    framestruct=5GC001116_0ms_30MHZ
#    Webem Change RRM params by list   ${param_change}    runame=AZHA     framestruct=5GC001116_0ms_30MHZ
#    Set the HBTE PA value    value_list=${PA_Value['AZHA']['5GC001116_0ms_30MHZ']}   att_index=${PA_Value['AZHA']['att_index']}
#    Start Capture Wireshark at gNB    nglogname=axis_1
#    PEAK L3 CALL Process CB010611
#    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_1
#    Set L3 CALL param CB010611    runame=AZHA    framestruct=5GC001116_0ms_50MHZ
#    Webem Change RRM params by list   ${param_change}    runame=AZHA     framestruct=5GC001116_0ms_50MHZ
#    Set the HBTE PA value    value_list=${PA_Value['AZHA']['5GC001116_0ms_50MHZ']}   att_index=${PA_Value['AZHA']['att_index']}
#    Start Capture Wireshark at gNB    nglogname=axis_2
#    PEAK L3 CALL Process CB010611
#    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_2
#    [Teardown]    Case Teardown for CB010611
#
#
#[1]CB010611-SR-C-B1_007_BTS_site_reset_for_30M_AZHA
#    [Timeout]   5h
#    [Setup]    Run Keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND   Case Setup for CB010611
#
#    # AZHA 1116_0MS 50M peak tset
##    Set L3 CALL param CB010611    runame=AZHA    framestruct=5GC001116_0ms_50MHZ
#    Webem Change RRM params by list   ${param_change}    runame=AZHA     framestruct=5GC001116_0ms_30MHZ
##    Set the HBTE PA value    value_list=${PA_Value['AZHA']['5GC001116_0ms_50MHZ']}
##    Start Capture Wireshark at gNB    nglogname=axis_0
##    PEAK L3 CALL Process CB010611
##    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#
#    # AZHA 1116_0MS 50M site reset kpi 5 times
#    CB010611 SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call    reset_flag=True    runame=AZHA   reset_times=5
#
#
#    #AZHA 30M 1208 PEAK TEST
##    Set L3 CALL param CB010611    runame=AZHA    framestruct=5GC001208_30MHZ
##    Webem Change RRM params by list   ${param_change}    runame=AZHA     framestruct=5GC001208_30MHZ
##    Set the HBTE PA value    value_list=${PA_Value['AZHA']['5GC001208_30MHZ']}
##    Start Capture Wireshark at gNB    nglogname=axis_2
##    PEAK L3 CALL Process CB010611
##    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_2
#
#    [Teardown]    Case Teardown for CB010611
#
#[1]CB010611-SR-C-B1_008_UE_attach_and_peak_TP_with_5GC001116_0ms_256QAM_SA_Mode_for_10MHz_AWHHF_Pooling_ABIP
#    [Timeout]   5h
#    [Setup]    Run Keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND   Case Setup for CB010611
#    Set L3 CALL param CB010611    runame=AWHHF    framestruct=5GC001116_0ms_10MHZ
#    Webem Change RRM params by list   ${param_change}    runame=AWHHF     framestruct=5GC001116_0ms_10MHZ
#    Set the HBTE PA value    value_list=${PA_Value['AWHHF']['5GC001116_0ms_10MHZ']}
#    Start Capture Wireshark at gNB    nglogname=axis_0
#    PEAK L3 CALL Process CB010611
#    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    CB010611 SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call    reset_flag=True    runame=AWHHF   reset_times=5
#    [Teardown]    Case Teardown for CB010611

CB010575_CB010611_CRT
    [Timeout]    15h
    [Setup]     robot_common_operations.Common Case Setup
#    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#    List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
    Run Keyword And Continue On Failure    CB010611-SR-C-B1_004_Online_modify_bandwidth_from_30MHz_to_50MHz_AZHA
    Run Keyword And Continue On Failure    CB010611-SR-C-B1_007_BTS_site_reset_for_30M_AZHA
    Run Keyword And Continue On Failure
    ...   CB010611-SR-C-B1_008_UE_attach_and_peak_TP_with_5GC001116_0ms_256QAM_SA_Mode_for_10MHz_AWHHF_Pooling_ABIP
    [Teardown]    robot_common_operations.Common Case Teardown

*** Keywords ***
CB010611-SR-C-B1_004_Online_modify_bandwidth_from_30MHz_to_50MHz_AZHA
    [Timeout]   5h
    Case Setup for CB010611
    Set L3 CALL param CB010611    runame=AZHA    framestruct=5GC001208_30MHZ
    Set the HBTE PA value    value_list=${PA_Value['AZHA']['5GC001208_30MHZ']}   att_index=${PA_Value['AZHA']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB010611
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
    Set L3 CALL param CB010611    runame=AZHA    framestruct=5GC001116_0ms_30MHZ
    Webem Change RRM params by list   ${param_change}    runame=AZHA     framestruct=5GC001116_0ms_30MHZ
    Set the HBTE PA value    value_list=${PA_Value['AZHA']['5GC001116_0ms_30MHZ']}   att_index=${PA_Value['AZHA']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_1
    PEAK L3 CALL Process CB010611
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_1
    Set L3 CALL param CB010611    runame=AZHA    framestruct=5GC001116_0ms_50MHZ
    Webem Change RRM params by list   ${param_change}    runame=AZHA     framestruct=5GC001116_0ms_50MHZ
    Set the HBTE PA value    value_list=${PA_Value['AZHA']['5GC001116_0ms_50MHZ']}   att_index=${PA_Value['AZHA']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_2
    PEAK L3 CALL Process CB010611
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_2
    [Teardown]    Case Teardown for CB010611


CB010611-SR-C-B1_007_BTS_site_reset_for_30M_AZHA
    [Timeout]   5h
    Case Setup for CB010611
    Webem Change RRM params by list   ${param_change}    runame=AZHA     framestruct=5GC001116_0ms_30MHZ
    CB010611 SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call    reset_flag=True    runame=AZHA   reset_times=5
    [Teardown]    Case Teardown for CB010611

CB010611-SR-C-B1_008_UE_attach_and_peak_TP_with_5GC001116_0ms_256QAM_SA_Mode_for_10MHz_AWHHF_Pooling_ABIP
    [Timeout]   5h
    Case Setup for CB010611
    Set L3 CALL param CB010611    runame=AWHHF    framestruct=5GC001116_0ms_10MHZ
    Webem Change RRM params by list   ${param_change}    runame=AWHHF     framestruct=5GC001116_0ms_10MHZ
    Set the HBTE PA value    value_list=${PA_Value['AWHHF']['5GC001116_0ms_10MHZ']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB010611
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
    CB010611 SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call    reset_flag=True    runame=AWHHF   reset_times=5
    [Teardown]    Case Teardown for CB010611