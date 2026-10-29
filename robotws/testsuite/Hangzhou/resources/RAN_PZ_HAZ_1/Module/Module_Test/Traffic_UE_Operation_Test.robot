*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This is the module test case

Resource          ../Module.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Cloud/AIC_Common_Resource.robot

# Suite Setup       Common MultiBTS Suite Setup For RRM
# Test Setup        Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
# Test Teardown     Common MultiBTS Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM

Force Tags        RAN_VRF_HAZ1

Test Timeout      60 minutes



*** Test Cases ***
T00_Traffic_UE_Operation_Attach
    [Tags]    TC00
    Log To Console    Attach the UE...
    Traffic UE Operation    attach    ue_index=1

T01_Traffic_UE_Operation_Detach_And_Attach
    [Tags]    TC01
    Log To Console    Detach the UE...
    Traffic UE Operation    detach    ue_index=1
    sleep    10s
    Log To Console    Attach the UE...
    Traffic UE Operation    attach    ue_index=1
    sleep    10s
    Log To Console    Detach the UE...
    Traffic UE Operation    detach    ue_index=1
    sleep    10s
    Log To Console    Attach the UE...
    Traffic UE Operation    attach    ue_index=1

T02_Traffic_UE_Operation_Reboot
    [Tags]    TC02
    Log To Console    Reboot the UE...
    Traffic UE Operation    reboot    ue_index=1    timeout=5min
    Sleep    300s
    Log To Console    Attach the UE...
    Traffic UE Operation    attach    ue_index=1

T03_Traffic_UE_Operation_Voice_Call
    [Tags]    TC03
    Log To Console    Attach the UE...
    Traffic UE Operation    attach    ue_index=1
    Log To Console    Start the voice call for 20s...
    Traffic UE Operation    start voice call    ue_index=1    dial=006688    duration=20s
    Log To Console    The voice call shall stopped

    Log To Console    Start the voice call for 0...
    Traffic UE Operation    start voice call    ue_index=1    dial=006688    duration=0
    Sleep    20s
    Traffic UE Operation    stop voice call    ue_index=1
    Log To Console    The voice call shall stopped

    Log To Console    Start the voice call for 0s...
    Traffic UE Operation    start voice call    ue_index=1    dial=006688    duration=0s
    Sleep    20s
    Traffic UE Operation    stop voice call    ue_index=1
    Log To Console    The voice call shall stopped

    Log To Console    Start the voice call for 0S...
    Traffic UE Operation    start voice call    ue_index=1    dial=006688    duration=0m
    Sleep    20s
    Traffic UE Operation    stop voice call    ue_index=1
    Log To Console    The voice call shall stopped

    Log To Console    Start the voice call for None...
    Traffic UE Operation    start voice call    ue_index=1    dial=006688    duration=None
    Sleep    20s
    Traffic UE Operation    stop voice call    ue_index=1
    Log To Console    The voice call shall stopped

    Log To Console    Start the voice call for dureation is blank...
    Traffic UE Operation    start voice call    ue_index=1    dial=006688    duration=""
    Sleep    20s
    Traffic UE Operation    stop voice call    ue_index=1
    Log To Console    The voice call shall stopped


T04_Traffic_UE_Operation_UDP_DL_Call
    [Tags]    TC04
    Log To Console    Attach the UE...
    Traffic UE Operation    attach    ue_index=1
    Log To Console    Start the UDP DL call...
    Traffic UE Operation    start traffic    ue_index=1    option=udp_dl    bandwidth=100M    port=5000    duration=300
    ${dl_avg}    ${ul_avg}    Traffic UE Operation    check average tput    ue_index=1    period=20s
    ${dl_peak}    ${ul_peak}    Traffic UE Operation    check peak tput    ue_index=1    period=20s
    Traffic UE Operation    stop traffic    ue_index=1    option=udp_dl    port=5000

T05_Traffic_UE_Operation_UDP_UL_Call
    [Tags]    TC05
    Log To Console    Attach the UE...
    Traffic UE Operation    attach    ue_index=1
    Log To Console    Start the UDP UL call...
    Traffic UE Operation    start traffic    ue_index=1    option=udp_ul    bandwidth=100M    port=5000    duration=300
    ${dl_avg}    ${ul_avg}    Traffic UE Operation    check average tput    ue_index=1    period=20s
    ${dl_peak}    ${ul_peak}    Traffic UE Operation    check peak tput    ue_index=1    period=20s
    Traffic UE Operation    stop traffic    ue_index=1    option=udp_ul    port=5000

T06_Traffic_UE_Operation_UDP_ULDL_Call
    [Tags]    TC06
    Log To Console    Attach the UE...
    Traffic UE Operation    attach    ue_index=1
    Log To Console    Start the UDP UL/DL call...
    Traffic UE Operation    start traffic    ue_index=1    option=udp_uldl    bandwidth=100M    port=5000    duration=300
    ${dl_avg}    ${ul_avg}    Traffic UE Operation    check average tput    ue_index=1    period=20s
    ${dl_peak}    ${ul_peak}    Traffic UE Operation    check peak tput    ue_index=1    period=20s
    Traffic UE Operation    stop traffic    ue_index=1    option=udp_uldl    port=5000

T07_Trigger_UE_Operation_Get_UE_Status
    [Tags]    TC07
    Log To Console    Get the UE status...
    ${ue_live}    Traffic UE Operation    get    ue_index=1    item=alive
    Log To Console    UE is alive: ${ue_live}
    ${ue_mode}    Traffic UE Operation    get    ue_index=1    item=mode
    Log To Console    UE mode: ${ue_mode}
    ${ue_ipv4}    Traffic UE Operation    get    ue_index=1    item=ipv4
    Log To Console    UE IPv4: ${ue_ipv4}
    ${ue_cell}    Traffic UE Operation    get    ue_index=1    item=cellid
    Log To Console    UE cell ID: ${ue_cell}



