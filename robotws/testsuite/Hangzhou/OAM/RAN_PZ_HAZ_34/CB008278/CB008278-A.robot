*** Settings ***
Documentation     author: ruiyu.han
...               contact: menghua.luo@nokia-sbell.com
...               squad group: HAZ3_T06
...               feature : CB008278-A

Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB008278/Resource/CB008278_common.robot

Suite Setup   robot_common_operations.Common Suite Setup
Suite Teardown   robot_common_operations.Common Suite Teardown


*** Variables ***
${L3CALL_CELLID}    1


*** Test Cases ***
[1]CB008278-A_017_activate_beamforming_on_10MHz_bandwidth_at_5GC001116_with_slot_shift_AEHC
    [Timeout]   5h
    [Setup]    Case Setup for CB008278    x2_enb_mrbtsId=8581    gnbmode=NSA
    Set L3 CALL param CB008278    runame=AEHC    framestruct=5GC001116_3ms_10MHZ
    Webem Change RRM params by list    param_change=${param_change}    runame=AEHC     framestruct=5GC001116_3ms_10MHZ
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AEHC']['5GC001116_3ms_10MHZ']}   att_index=${PA_Value['AEHC']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    Wait Until Keyword Succeeds   3x   20mins   PEAK L3 CALL Process CB008278
    ...     runame=AEHC    framestruct=5GC001116_3ms_10MHZ    L3CALL_CELLID=${L3CALL_CELLID}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001116_3ms_10MHZ    runame=AEHC   reset_times=3
#    ...   L3CALL_CELLID=${L3CALL_CELLID}
#    Change framestruct by list    runame=AEHC     framestruct=5GC001116_3ms_100MHZ
#    PEAK L3 CALL Process CB008278    L3CALL_CELLID=${L3CALL_CELLID}
    ## expect DL TP is 100MHZ UL is 20M, setted in resouce.py actually not peak test
#    Change framestruct by list    runame=AEHC     framestruct=5GC001116_3ms_10MHZ
#    PEAK L3 CALL Process CB008278    L3CALL_CELLID=${L3CALL_CELLID}
    [Teardown]    Case Teardown for CB008278


[1]CB008278-A_018_activate_beamforming_on_10MHz_bandwidth_at_5GC001208_frame_structure_AEHC
    [Timeout]   5h
    [Setup]    Case Setup for CB008278    x2_enb_mrbtsId=8581   gnbmode=NSA
    Set L3 CALL param CB008278    runame=AEHC    framestruct=5GC001208_10MHZ
    Webem Change RRM params by list    param_change=${param_change}    runame=AEHC     framestruct=5GC001208_10MHZ
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AEHC']['5GC001208_10MHZ']}   att_index=${PA_Value['AEHC']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    Wait Until Keyword Succeeds   3x   20mins   PEAK L3 CALL Process CB008278
    ...     runame=AEHC    framestruct=5GC001208_10MHZ    L3CALL_CELLID=${L3CALL_CELLID}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001208_10MHZ    runame=AEHC   reset_times=3
#    ...    L3CALL_CELLID=${L3CALL_CELLID}
    [Teardown]    Case Teardown for CB008278

[1]CB008278-A_019_activate_beamforming_on_10MHz_bandwidth_at_5GC001070_frame_structure_AEHC
    [Timeout]   5h
    [Setup]    Case Setup for CB008278    x2_enb_mrbtsId=8581    gnbmode=NSA
    Set L3 CALL param CB008278    runame=AEHC    framestruct=5GC001070_10MHZ
    Webem Change RRM params by list    param_change=${param_change}    runame=AEHC     framestruct=5GC001070_10MHZ
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AEHC']['5GC001070_10MHZ']}   att_index=${PA_Value['AEHC']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    Wait Until Keyword Succeeds   3x   20mins   PEAK L3 CALL Process CB008278
    ...     runame=AEHC    framestruct=5GC001070_10MHZ    L3CALL_CELLID=${L3CALL_CELLID}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001070_10MHZ    runame=AEHC   reset_times=3
#    ...    L3CALL_CELLID=${L3CALL_CELLID}
    [Teardown]    Case Teardown for CB008278

[1]CB008278-A_020_activate_beamforming_on_10MHz_bandwidth_at_5GC001116 without slot shift_AEHC
    [Timeout]   5h
    [Setup]    Case Setup for CB008278    x2_enb_mrbtsId=8581    gnbmode=NSA
    Set L3 CALL param CB008278    runame=AEHC    framestruct=5GC001116_0ms_10MHZ
    Wait Until Keyword Succeeds  3x  2m  COAM WEBUI Login
    Webem Change RRM params by list    param_change=${param_change}    runame=AEHC     framestruct=5GC001116_0ms_10MHZ
    ...   x2_enb_mrbtsId=8581   gnbmode=NSA
    Set the HBTE PA value    value_list=${PA_Value['AEHC']['5GC001116_0ms_10MHZ']}   att_index=${PA_Value['AEHC']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    Wait Until Keyword Succeeds   2x   20mins   PEAK L3 CALL Process CB008278
    ...     runame=AEHC    framestruct=5GC001116_0ms_10MHZ    L3CALL_CELLID=${L3CALL_CELLID}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB   nglogname=axis_0
#    SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    ...    reset_flag=True    framestruct=5GC001116_0ms_10MHZ    runame=AEHC   reset_times=3
#    ...    L3CALL_CELLID=${L3CALL_CELLID}
    [Teardown]    Case Teardown for CB008278
