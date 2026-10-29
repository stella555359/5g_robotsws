*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define CB009355 15MHZ cases
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009355/Resource/CB009355_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot


Suite Setup   robot_common_operations.Common Suite Setup
Suite Teardown   robot_common_operations.Common Suite Teardown

*** Variables ***
@{ALL_TEST_STATUS}
@{L3CALL_CELLID_LIST}    1
${ue_index}   ${0}
${ue_lock}    ${false}
${band}      N41
${arfcn}     379000
${pci}       100
${ue_type}   nokia_fastmile
${traffic_dl}    200M
${traffic_ul}    25M


*** Test Cases ***
[1]CB009355_076_Long_PUCCH_resource_optimization_interaction_with_2_BWP_prbblank_15Mhz
   [Timeout]    8h
   [Tags]   24R3
   [Setup]   CB009355 Common Case Setup
   run keyword and continue on failure   CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_disable_bbpool
   run keyword and continue on failure   CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_SA_AEHC
   run keyword and continue on failure   CB009355_attach_detach_10_times_AEHC_CPE
   run keyword and continue on failure   CB009355_check_if_error_when_traffic
   [Teardown]   CB009355 Common Case Teardown

[1]CB009355_prbblank_15Mhz
   [Timeout]    8h
   [Tags]   24R3
   [Setup]   CB009355 Common Case Setup
   run keyword and continue on failure   CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_SA_AEHC_PRBBLANK_33
   run keyword and continue on failure   CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_SA_AEHC_PRBBLANK_44
   run keyword and continue on failure   CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_SA_AEHC_PRBBLANK_67
   [Teardown]   CB009355 Common Case Teardown


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

CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_SA_AEHC_PRBBLANK_67
    [Timeout]   3h
    Case Setup for CB009355    x2_enb_mrbtsId=8581    gnbmode=NSA
    Set L3 CALL param CB009355    runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank67
    Admin Change RRM params by list     param_change=${admin_param_change}    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank67
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Modify disableSchedAssistRfCooling to false in Venfor file    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank67
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AEHC']['5GC001116_0ms_15MHZ_multibwp']}   att_index=${PA_Value['AEHC']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB009355
    ...     runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank67    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001116_0ms_15MHZ_multibwp    runame=AEHC   reset_times=3
#    ...    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    [Teardown]    Case Teardown for CB009355

CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_SA_AEHC
    [Timeout]   5h
    Case Setup for CB009355    x2_enb_mrbtsId=8581    gnbmode=NSA
    Set L3 CALL param CB009355    runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp
    Admin Change RRM params by list     param_change=${admin_param_change}    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Modify disableSchedAssistRfCooling to false in Venfor file    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AEHC']['5GC001116_0ms_15MHZ_multibwp']}   att_index=${PA_Value['AEHC']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB009355
    ...     runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001116_0ms_15MHZ_multibwp    runame=AEHC   reset_times=3
#    ...    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    [Teardown]    Case Teardown for CB009355

CB009355_attach_detach_10_times_AEHC_CPE
   [Timeout]    1h
   Case Setup：CB009355_attach_detach_10_times_CPE
   ### 10 times attach and detach
   Start Capture Wireshark at gNB    nglogname=attach_detach_10_times.pcap
   BuiltIn.sleep  10s
    FOR   ${i}    IN RANGE    1    11
       log    ${i}
       ul_power_ue.UE Attach    ue=UE_${ue_index}
       Sleep   15s
       ul_power_ue.UE Detach    ue=UE_${ue_index}
       Sleep   10s
    END
    BuiltIn.sleep   5s
    Stop and download Wireshark at gNB    nglogname=attach_detach_10_times.pcap
    Check Wireshark Attach nRCellIdentity should be same    logpath=${OUTPUT_DIR}/${TESTNAME}/attach_detach_10_times.pcap
    Check Wireshark Attach Successful    logpath=${OUTPUT_DIR}/${TESTNAME}/attach_detach_10_times.pcap
    Check Wireshark No Restablisment    logpath=${OUTPUT_DIR}/${TESTNAME}/attach_detach_10_times.pcap
    ${gnb_release}   Get gnb release    host=${WEBUI_ADDR}
    Set Suite Variable   ${gnb_release}
    run keyword if   '${gnb_release}'=='SBTS25R2'   run keyword and ignore error   Siso Common Check Syslog Error
    ...   ELSE   Siso Common Check Syslog Error
   [Teardown]   Case Teardown：CB009355_attach_detach_10_times_CPE

CB009355_check_if_error_when_traffic
    [Timeout]    1h
    Case Setup：CB009355_attach_detach_10_times_CPE
    Start Capture Wireshark at gNB    nglogname=check_if_error_when_traffic.pcap
    ul_power_ue.UE Attach    ue=UE_${ue_index}
    Sleep   30s
    Start traffic CPE    ue_index=${ue_index}    ue_type=${ue_type}    Send_Tput=${traffic_dl}
    ...    duration=300    direction=dl
    Start traffic CPE   ue_index=${ue_index}    ue_type=${ue_type}
    ...    Send_Tput=${traffic_ul}   duration=300   direction=ul    process_num=5
    sleep   30s
    run keyword and ignore error    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}    direction=dl
    run keyword and ignore error    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}    direction=ul
    run keyword and ignore error    ul_power_ue.UE Detach    ue=UE_${ue_index}
    Stop and download Wireshark at gNB    nglogname=check_if_error_when_traffic.pcap
    Check Wireshark Attach nRCellIdentity should be same    logpath=${OUTPUT_DIR}/${TESTNAME}/check_if_error_when_traffic.pcap
    Check Wireshark Attach Successful    logpath=${OUTPUT_DIR}/${TESTNAME}/check_if_error_when_traffic.pcap    times=1
    Check Wireshark No Restablisment    logpath=${OUTPUT_DIR}/${TESTNAME}/check_if_error_when_traffic.pcap
    ${gnb_release}   Get gnb release    host=${WEBUI_ADDR}
    Set Suite Variable   ${gnb_release}
    run keyword if   '${gnb_release}'=='SBTS25R2'   run keyword and ignore error   Siso Common Check Syslog Error
    ...   ELSE   Siso Common Check Syslog Error
    [Teardown]   Case Teardown：CB009355_attach_detach_10_times_CPE

CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_disable_bbpool
    [Timeout]   5h
    Case Setup for CB009355    x2_enb_mrbtsId=8581    gnbmode=NSA
    Set L3 CALL param CB009355    runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp
    Admin Change RRM params by list     param_change=${admin_param_change}    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp_nobbpool
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Modify disableSchedAssistRfCooling to false in Venfor file    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp_nobbpool
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AEHC']['5GC001116_0ms_15MHZ_multibwp']}   att_index=${PA_Value['AEHC']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB009355
    ...     runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001116_0ms_15MHZ_multibwp    runame=AEHC   reset_times=3
#    ...    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    [Teardown]    Case Teardown for CB009355

CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHZ_PRBBLANK_67_disable_bbpool
    [Timeout]   5h
    Case Setup for CB009355    x2_enb_mrbtsId=8581    gnbmode=NSA
    Set L3 CALL param CB009355    runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank67
    Admin Change RRM params by list     param_change=${admin_param_change}    runame=AEHC
    ...     framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank67_nobbpool
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Modify disableSchedAssistRfCooling to false in Venfor file    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank67_nobbpool
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AEHC']['5GC001116_0ms_15MHZ_multibwp']}   att_index=${PA_Value['AEHC']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB009355
    ...     runame=AEHC    framestruct=5GC001116_0ms_15MHZ_multibwp    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001116_0ms_15MHZ_multibwp    runame=AEHC   reset_times=3
#    ...    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    [Teardown]    Case Teardown for CB009355

Case Setup：CB009355_attach_detach_10_times_CPE
    Case Setup for CB009355    x2_enb_mrbtsId=8581    gnbmode=NSA
    Admin Change RRM params by list     param_change=${admin_param_change}    runame=AEHC     framestruct=5GC001116_0ms_15MHZ_multibwp_prbblank33
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    UE precondition CPE   ue_index=${ue_index}   ue_type=${ue_type}
    run keyword if   ${ue_lock}    CPE Lock Opration   band=${band}   arfcn=${arfcn}    pci=${pci}   ue_index=${ue_index}
    Start Syslog Collection

Case Teardown：CB009355_attach_detach_10_times_CPE
    run keyword and ignore error    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}    direction=dl
    run keyword and ignore error    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}    direction=ul
    run keyword and ignore error    ul_power_ue.UE Detach    ue=UE_${ue_index}
    run keyword and ignore error    Stop Wireshark at gNB
    run keyword if     ${KEYWORD STATUS.count('PASS')}>0      Stop and Delete Syslog Collection
    run keyword if     ${KEYWORD STATUS.count('PASS')}<=0      Stop and Save Syslog Collection
    run keyword if   ${ue_lock}     Unlock band and PCI from CPE    ue_index=${ue_index}   band=${band}
    run keyword and ignore error    COAM LOGIN
    run keyword and ignore error    COAM LOGOUT
    run keyword if     ${KEYWORD STATUS.count('PASS')}<=0      Catch Snapshot COAM
    run keyword and ignore error    COAM LOGOUT

CB009355 Common Case Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000

CB009355 Common Case Teardown
   CI_interface.Common Suite Setup
   run keyword and ignore error    COAM LOGIN
   wait until keyword succeeds    15min    1min   Check onair and x2 meantime    x2_enb_mrbtsId=8581   gnbmode=NSA
   robot_common_operations.Common Case Teardown
   CI_interface.Common Case Teardown
   run keyword and ignore error    COAM LOGOUT
