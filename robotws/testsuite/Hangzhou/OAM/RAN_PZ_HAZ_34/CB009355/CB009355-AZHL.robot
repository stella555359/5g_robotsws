*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define CB009355 15MHZ cases
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009355/Resource/CB009355_common.robot


Suite Setup   robot_common_operations.Common Suite Setup
Suite Teardown   robot_common_operations.Common Suite Teardown

*** Variables ***
@{L3CALL_CELLID_LIST}    1     14

*** Test Cases ***
[1]CB009355_042_UE_attach_and_peak_TP_with_5GC001208_for_15MHz_SA_AZHL
    [Timeout]   5h
    [Setup]    Case Setup for CB009355    x2_enb_mrbtsId=889    gnbmode=NSA
    Set L3 CALL param CB009355    runame=AZHL    framestruct=5GC001208_15MHZ_multibwp
    Admin Change RRM params by list     param_change=${admin_param_change}    runame=AZHL     framestruct=5GC001208_15MHZ_multibwp
    ...   x2_enb_mrbtsId=889   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AZHL']['5GC001208_15MHZ_multibwp']}   att_index=${PA_Value['AZHL']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB009355
    ...     runame=AZHL    framestruct=5GC001208_15MHZ_multibwp    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001208_15MHZ_multibwp    runame=AZHL   reset_times=3
#    ...   L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
#    Change framestruct by list    runame=AZHL     framestruct=5GC001116_3ms_100MHZ
#    PEAK L3 CALL Process CB009355    L3CALL_CELLID=${L3CALL_CELLID}
    ## expect DL TP is 100MHZ UL is 20M, setted in resouce.py actually not peak test
#    Change framestruct by list    runame=AZHL     framestruct=5GC001116_3ms_10MHZ
#    PEAK L3 CALL Process CB009355    L3CALL_CELLID=${L3CALL_CELLID}
    [Teardown]    Case Teardown for CB009355


[1]CB009355_043_UE_attach_and_peak_TP_with_5GC001070_for_15MHz_SA_AZHL
    [Timeout]   5h
    [Setup]    Case Setup for CB009355    x2_enb_mrbtsId=889   gnbmode=NSA
    Set L3 CALL param CB009355    runame=AZHL    framestruct=5GC001070_15MHZ_multibwp
    Admin Change RRM params by list     param_change=${admin_param_change}    runame=AZHL     framestruct=5GC001070_15MHZ_multibwp
    ...   x2_enb_mrbtsId=889   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AZHL']['5GC001070_15MHZ_multibwp']}   att_index=${PA_Value['AZHL']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB009355
    ...     runame=AZHL    framestruct=5GC001070_15MHZ_multibwp    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001070_15MHZ_multibwp    runame=AZHL   reset_times=3
#    ...    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    [Teardown]    Case Teardown for CB009355

[1]CB009355_040_UE_attach_and_peak_TP_with_5GC001116_0ms_for_15MHz_SA_AZHL
    [Timeout]   5h
    [Setup]    Case Setup for CB009355    x2_enb_mrbtsId=889    gnbmode=NSA
    Set L3 CALL param CB009355    runame=AZHL    framestruct=5GC001116_0ms_15MHZ_multibwp
    Admin Change RRM params by list     param_change=${admin_param_change}    runame=AZHL     framestruct=5GC001116_0ms_15MHZ_multibwp
    ...   x2_enb_mrbtsId=889   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AZHL']['5GC001116_0ms_15MHZ_multibwp']}   att_index=${PA_Value['AZHL']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB009355
    ...     runame=AZHL    framestruct=5GC001116_0ms_15MHZ_multibwp    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001116_0ms_15MHZ_multibwp    runame=AZHL   reset_times=3
#    ...    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    [Teardown]    Case Teardown for CB009355

[1]CB009355_041_UE_attach_and_peak_TP_with_5GC001116_3ms_for_15MHz_SA_AZHL
    [Timeout]   5h
    [Setup]    Case Setup for CB009355    x2_enb_mrbtsId=889    gnbmode=NSA
    Set L3 CALL param CB009355    runame=AZHL    framestruct=5GC001116_3ms_15MHZ_multibwp
    Admin Change RRM params by list     param_change=${admin_param_change}    runame=AZHL     framestruct=5GC001116_3ms_15MHZ_multibwp
    ...   x2_enb_mrbtsId=889   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AZHL']['5GC001116_3ms_15MHZ_multibwp']}   att_index=${PA_Value['AZHL']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    PEAK L3 CALL Process CB009355
    ...     runame=AZHL    framestruct=5GC001116_3ms_15MHZ_multibwp    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001116_3ms_15MHZ_multibwp    runame=AZHL   reset_times=3
#    ...    L3CALL_CELLID_list=${L3CALL_CELLID_LIST}
    [Teardown]    Case Teardown for CB009355
