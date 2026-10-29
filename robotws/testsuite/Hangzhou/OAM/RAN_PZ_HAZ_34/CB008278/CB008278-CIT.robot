*** Settings ***
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB008278/Resource/CB008278_common.robot


Suite Setup   robot_common_operations.Common Suite Setup
Suite Teardown   robot_common_operations.Common Suite Teardown

*** Variables ***
${L3CALL_CELLID}    1

*** Test Cases ***
[1]CB008278-A_020_activate_beamforming_on_10MHz_bandwidth_at_5GC001116 without slot shift_AEHC
    [Timeout]   2h
    [Setup]    Case Setup for CB008278    x2_enb_mrbtsId=8581    gnbmode=NSA
    Set L3 CALL param CB008278    runame=AEHC    framestruct=5GC001116_0ms_10MHZ
#    Webem Change RRM params by list    param_change=${param_change}    runame=AEHC     framestruct=5GC001116_0ms_10MHZ
#    ...   x2_enb_mrbtsId=8541   gnbmode=NSA    ##base scf is 1116 0ms, no need change parameter
    Set the HBTE PA value    value_list=${PA_Value['AEHC']['5GC001116_0ms_10MHZ']}   att_index=${PA_Value['AEHC']['att_index']}
    Start Capture Wireshark at gNB    nglogname=axis_0
    Wait Until Keyword Succeeds   3x   20mins   PEAK L3 CALL Process CB008278
    ...     runame=AEHC    framestruct=5GC001116_0ms    L3CALL_CELLID=${L3CALL_CELLID}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB   nglogname=axis_0
    [Teardown]    Case Teardown for CB008278
