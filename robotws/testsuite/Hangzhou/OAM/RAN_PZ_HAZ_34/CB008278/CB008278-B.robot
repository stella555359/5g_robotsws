*** Settings ***
Documentation
...   author: Han Ruiyu
...   contact: ruiyu.han@nokia-sbell.com
...   squad group: 5G_PZ_7_SG
...   This is to peak L3CALL for CB008278 AZHL RRU
...   :kw Set L3 CALL param CB008278 : set params in DICT__L3CALL_Set at resource.py.
...   :kw Change framestruct by list: change different framestruct parameters according to DICT__param_change
...   at resource.py; for 1208 no need to recall this kw because origianl SCF is 5GC001208 framestruct
...   :kw two paramater can choose[mcu,rt],the syslog with CCS_MCU contain L2LO and CCS_RT contain L2HI.
...   :kw PEAK L3 CALL Process CB008278: for kw limit, the duration of PEAK l3 CALL cannot less than 2min

Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB008278/Resource/CB008278_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot

Suite Setup   robot_common_operations.Common Suite Setup
Suite Teardown   robot_common_operations.Common Suite Teardown

*** Variables ***
${L3CALL_CELLID}    1

*** Test Cases ***
[1]CB008278-B_001_UE_attach_and_peak_TP_at_5GC001116_without_slot_shift_long_PUCCH_NSA_Mode_for_10MHz_AZHL
    [Timeout]   5h
    [Setup]    Case Setup for CB008278
    Set L3 CALL param CB008278    runame=AZHL    framestruct=5GC001116_0ms_10MHZ
    Webem Change RRM params by list    param_change=${param_change}    runame=AZHL     framestruct=5GC001116_0ms_10MHZ
    ...   x2_enb_mrbtsId=default   gnbmode=SA
    Set the HBTE PA value    value_list=${PA_Value['AZHL']['5GC001116_0ms_10MHZ']}   att_index=${PA_Value['AZHL']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    Wait Until Keyword Succeeds   3x   20mins   PEAK L3 CALL Process CB008278
    ...     runame=AZHL    framestruct=5GC001116_0ms_10MHZ    L3CALL_CELLID=${L3CALL_CELLID}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call    reset_flag=True    framestruct=5GC001116_0ms_10MHZ   reset_times=3
    Webem Change RRM params by list    param_change=${param_change}    runame=AZHL     framestruct=5GC001116_0ms_100MHZ
    ...   x2_enb_mrbtsId=default   gnbmode=SA
    Wait Until Keyword Succeeds   3x   20mins   PEAK L3 CALL Process CB008278
    ...     runame=AZHL    framestruct=5GC001116_0ms_100MHZ    L3CALL_CELLID=${L3CALL_CELLID}
        ## expect DL TP is 100MHZ UL is 20M, setted in resouce.py actually not peak test
    Webem Change RRM params by list    param_change=${param_change}    runame=AZHL     framestruct=5GC001116_0ms_10MHZ
    ...   x2_enb_mrbtsId=default   gnbmode=SA
    Wait Until Keyword Succeeds   3x   20mins   PEAK L3 CALL Process CB008278
    ...     runame=AZHL    framestruct=5GC001116_0ms_10MHZ    L3CALL_CELLID=${L3CALL_CELLID}
    [Teardown]    Case Teardown for CB008278

[1]CB008278-B_007_UE_attach_and_peak_TP_at_5GC001116_with_slot_shift_SA_Mode_for_10MHz_AZHL
    [Timeout]   5h
    [Setup]    Case Setup for CB008278
    Set L3 CALL param CB008278    runame=AZHL    framestruct=5GC001116_3ms_10MHZ
    Webem Change RRM params by list    param_change=${param_change}    runame=AZHL     framestruct=5GC001116_3ms_10MHZ
    ...   x2_enb_mrbtsId=default   gnbmode=SA
    Set the HBTE PA value    value_list=${PA_Value['AZHL']['5GC001116_3ms_10MHZ']}   att_index=${PA_Value['AZHL']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    Wait Until Keyword Succeeds   3x   20mins   PEAK L3 CALL Process CB008278
    ...     runame=AZHL    framestruct=5GC001116_3ms_10MHZ    L3CALL_CELLID=${L3CALL_CELLID}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call    reset_flag=True    framestruct=5GC001116_3ms_10MHZ   reset_times=3
    [Teardown]    Case Teardown for CB008278

[1]CB008278-B_008_UE_attach_and_peak_TP_at_5GC001208_frame_structure_short_PUCCH_SA_for_10MHz_AZHL
    [Timeout]   5h
    [Setup]    Case Setup for CB008278
    Set L3 CALL param CB008278    runame=AZHL    framestruct=5GC001208_10MHZ
    Webem Change RRM params by list    param_change=${param_change}    runame=AZHL     framestruct=5GC001208_10MHZ
    ...   x2_enb_mrbtsId=default   gnbmode=SA
    Set the HBTE PA value    value_list=${PA_Value['AZHL']['5GC001208_10MHZ']}   att_index=${PA_Value['AZHL']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    Wait Until Keyword Succeeds   3x   20mins   PEAK L3 CALL Process CB008278
    ...     runame=AZHL    framestruct=5GC001208_10MHZ    L3CALL_CELLID=${L3CALL_CELLID}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call    reset_flag=True    framestruct=5GC001208_10MHZ   reset_times=3
    [Teardown]    Case Teardown for CB008278

[1]CB008278-B_009_UE_attach_and_peak_TP_at_5GC001070_frame_structure__256QAM_SA_for_10MHz_AZHL
    [Timeout]   5h
    [Setup]    Case Setup for CB008278
    Set L3 CALL param CB008278    runame=AZHL    framestruct=5GC001070_10MHZ
    Webem Change RRM params by list    param_change=${param_change}    runame=AZHL     framestruct=5GC001070_10MHZ
    ...   x2_enb_mrbtsId=default   gnbmode=SA
    Set the HBTE PA value    value_list=${PA_Value['AZHL']['5GC001070_10MHZ']}   att_index=${PA_Value['AZHL']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    Wait Until Keyword Succeeds   3x   20mins   PEAK L3 CALL Process CB008278
    ...    runame=AZHL    framestruct=5GC001070_10MHZ    L3CALL_CELLID=${L3CALL_CELLID}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call    reset_flag=True    framestruct=5GC001070_10MHZ    reset_times=3
    [Teardown]    Case Teardown for CB008278


