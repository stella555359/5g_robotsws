*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB008502-A FH Ethernet Mode detection and selection feature
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Library     taf.ue    WITH NAME    ue
Library     helpers.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Run Keywords
...               Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_timeout_for_update_sw=900
...               AND    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
${capabilities}                       REAL_UE
${duration}                           60s
${tput_dl}                            1500 Mbits/sec
${tput_ul}                            110 Mbits/sec
${protocol}                           tcp
${deviation_ul}                       50%
${deviation_dl}                       50%
${parallel_streams_dl}                4
${parallel_streams_ul}                2
${size_packet_dl}                     1400B
${size_packet_ul}                     1330B
${buffer_server_dl}                   8M
${interval}                           1
${reboot_ue}                          False
${timeout_reboot_ue}                  100
${COLLECT_LOGS_DURING_DATA_TRANSFER}  ${False}
${ENABLE_RACH_OBSERVER}               ${False}

*** Test Cases ***
[1][1.0] CB008502-A-BTS_Deployment_via_Commissioning_wizard_or_SCF_load_10eCpri
    [Setup]    Common Preconditions With Watching Alarms
    Verify linkSpeed Value    expected_value=eCpri10
    Require And Detach UE And Perform L3 Call

[1][1.0] CB008502-A-Ethernet_mode_reconfiguration_during_BTS_runtime_to_25eCpri
    [Setup]    CB008502-A Test Setup 10eCPRI
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-76093/EQM-1/HWTOP-1/CABLINK-12
    ...    param_name=linkSpeed
    ...    param_value=eCpri25
    ...    timeout=300
    Verify linkSpeed Value    expected_value=eCpri25
    Wait For Site To Be OnAir
    Require And Detach UE And Perform L3 Call

[1][1.0] CB008502-A-BTS_Deployment_via_Commissioning_wizard_or_SCF_load_25eCpri
    [Setup]    Common Preconditions With Watching Alarms
    Perform Full Commissioning On gNB    scf_file=${CURDIR}/scf/2cc_25ecpri.xml
    Wait For Site To Be Onair
    Verify linkSpeed Value    expected_value=eCpri25
    Allow Alarm    NgGnbInitPartialReset
    Perform L3 Call On First Cell
    Perform L3 Call On Second Cell
    [Teardown]    Run keywords
    ...    Disallow alarm    NgGnbInitPartialReset
    ...    AND    Common Postconditions With Watching Alarms

[1][1.0] CB008502-A-Ethernet_mode_reconfiguration_during_BTS_runtime_to_10eCpri
    [Setup]    CB008502-A Test Setup 25eCPRI
    Allow alarm    BTS configuration error (not enough HW for LCR)
    Allow alarm    BTS Reset Cause
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-76093/EQM-1/HWTOP-1/CABLINK-12
    ...    param_name=linkSpeed
    ...    param_value=eCpri10
    ...    timeout=300
    Verify linkSpeed Value    expected_value=eCpri10
    gnbalarm.Wait For Alarm Activation
    ...    fault_id=1868
    ...    awaiting_time=900
    Wait For Site To Be Onair
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-76093/EQM-1/HWTOP-1/CABLINK-12
    ...    param_name=linkSpeed
    ...    param_value=eCpri25
    ...    timeout=300
    Verify linkSpeed Value    expected_value=eCpri25
    Wait Until Keyword Succeeds
    ...    900 sec
    ...    10 sec
    ...    gnbcell.Verify All Cells are OnAir
    [Teardown]    Run keywords
    ...    Disallow alarm    BTS configuration error (not enough HW for LCR)
    ...    AND    Common Postconditions With Watching Alarms
    ...    AND    Disallow alarm    BTS Reset Cause

*** Keywords ***
Verify linkSpeed Value
    [Arguments]    ${expected_value}
    ${cablink_params}    gnbscf.Get All Params Under Class Name    class_name=com.nokia.srbts.eqm:CABLINK
    ${current_linkSpeed}    Get Linkspeed Value From Cablink
    ...    all_cablinks_parameters=${cablink_params}
    ...    cablink_distname=MRBTS-76093/EQM-1/HWTOP-1/CABLINK-12
    Should Be Equal    ${current_linkSpeed}    ${expected_value}

Run And Verify DL Throughput
    [Arguments]    ${duration}    ${tput}    ${protocol}    ${deviation}    ${parallel_streams}=1    ${size_packet}=1400B
    ...    ${buffer_client}=${None}    ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}
    [Documentation]   Run and Verify DL Throughput with desired parameters
    Verify L3 Call One Way Data Transfer
    ...    direction=DL
    ...    duration=${duration}
    ...    tput=${tput}
    ...    protocol=${protocol}
    ...    deviation=${deviation}
    ...    parallel_streams=${parallel_streams}
    ...    size_packet=${size_packet}
    ...    buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    ...    interval=${interval}
    ...    qci=${qci}

Run And Verify UL Throughput
    [Arguments]    ${duration}    ${tput}    ${protocol}    ${deviation}    ${parallel_streams}=1    ${size_packet}=1400B
    ...    ${buffer_client}=${None}    ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}
    [Documentation]   Run and Verify UL Throughput with desired parameters
    Verify L3 Call One Way Data Transfer
    ...    direction=UL
    ...    duration=${duration}
    ...    tput=${tput}
    ...    protocol=${protocol}
    ...    deviation=${deviation}
    ...    parallel_streams=${parallel_streams}
    ...    size_packet=${size_packet}
    ...    buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    ...    interval=${interval}
    ...    qci=${qci}

Perform L3 Call
    [Documentation]   Run and Verify DL Throughput and UL Throughput
    Run Keyword And Continue On Failure
    ...    Run and Verify DL Throughput
    ...    duration=${duration}
    ...    tput=${tput_dl}
    ...    protocol=${protocol}
    ...    deviation=${deviation_dl}
    ...    parallel_streams=${parallel_streams_dl}
    ...    size_packet=${size_packet_dl}
    ...    interval=${interval}
    Sleep    240s    Wait for UE to thermal recover
    Run Keyword And Continue On Failure
    ...    Run and Verify UL Throughput
    ...    duration=${duration}
    ...    tput=${tput_ul}
    ...    protocol=${protocol}
    ...    deviation=${deviation_ul}
    ...    parallel_streams=${parallel_streams_ul}
    ...    size_packet=${size_packet_ul}
    ...    interval=${interval}

CB008502-A Test Setup 25eCPRI
   Common Preconditions With Watching Alarms
   Verify linkSpeed Value    expected_value=eCpri25

CB008502-A Test Setup 10eCPRI
   Common Preconditions With Watching Alarms
   Verify linkSpeed Value    expected_value=eCpri10

Require And Detach UE And Perform L3 Call
    Require Ue For L3 Call
    ue.Detach Ue    UE
    Perform L3 Call

Detach UE And Perform L3 Call
    ue.Detach Ue    UE
    Perform L3 Call

Perform L3 Call On First Cell
    Lock gNB Cell    cell_id=1
    Sleep    20s    Wait for cell to be locked
    Verify gNB Cell Is Locked    cell_id=1
    Require And Detach UE And Perform L3 Call
    Unlock gNB Cell    cell_id=1
    Sleep    40s    Wait for cell to bo unlocked and reach onAir state
    Verify gNB Cell Is OnAir    cell_id=1

Perform L3 Call On Second Cell
    Lock gNB Cell    cell_id=0
    Sleep    20s    Wait for cell to be locked
    Verify gNB Cell Is Locked    cell_id=0
    Detach UE And Perform L3 Call
    Unlock gNB Cell    cell_id=0
    Sleep    40s    Wait for cell to bo unlocked and reach onAir state
    Verify gNB Cell Is onAir    cell_id=0
