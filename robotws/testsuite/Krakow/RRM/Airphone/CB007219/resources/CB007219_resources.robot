*** Settings ***
Documentation
...      == COPYRIGHT ==
...          Nokia Networks
...      == AUTHORS ==
...        - Bartlomiej Kukla <bartlomiej.kukla@nokia.com>
...      == MAINTAINER ==
...        - Bartlomiej Kukla <bartlomiej.kukla@nokia.com>

Library     OperatingSystem
Library     ute_fsmaccess
Library     ute_wtssim
Library     ta5g_egate
Library     ta5g_iphy
Library     ta5g_pm_counters
Library     ta5g_testline_management
Library     ta_emss
Library     ta_messaging
Library     taf.sbts.oam.coam.admin    WITH NAME   coam
Library     ../../resources/former_l2_sw1/python/traffic_handling.py
Library     ../../resources/former_l2_sw1/python/common_keywords.py
Resource    ../../resources/former_l2_sw1/robot/collectors.robot
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot


*** Keywords ***
UE Attach to target Cell
    [Arguments]    ${ue_id}=11    ${cell_id}=1
    Log to console    Attaching UE_${ue_id}
    Execute Egate Command    cmd=ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Sleep    2s
    Execute Egate Command    cmd=ue_disp id=${ue_id}
    Sleep    1s
    Log to console    Triggering LTE-NR dual connectivity for UE_${ue_id}
    Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    pass_regexp=UE${ue_id}: Proxy .eNB 2 cell ${cell_id}. reported successful RA
    ...    timeout=20s
    Sleep    1s

Start traffic
    [Arguments]    ${ue_id}=11
    Log to console    Starting traffic for UE_${ue_id}
    Start NSA traffic  ue=${ue_id}    dir=ul    bearer=2    traffic_rate=150Mbps
    Sleep    1s
    Start NSA traffic  ue=${ue_id}    dir=dl    bearer=2    traffic_rate=150Mbps

Verify traffic
    [Arguments]    ${ue_id}=11    ${ul_scells}=1    ${dl_scells}=1    ${ul_traffic}=1-200Mbps    ${dl_traffic}=1-200Mbps
    Wait 10s for tput stable
    Log to console    Verifying traffic for UE_${ue_id}
    Wait Until Keyword Succeeds    3x    5sec    Verify NSA traffic  ue=${ue_id}    dir=ul    expected_traffic=${ul_traffic}    scells=${ul_scells}
    Sleep    1s
    Wait Until Keyword Succeeds    3x    5sec    Verify NSA traffic  ue=${ue_id}    dir=dl    expected_traffic=${dl_traffic}    scells=${dl_scells}
    Log to console    Stopping traffic for UE_${ue_id}
    Run keyword and ignore error    Stop NSA traffic  ue=${ue_id}  dir=ul
    Run keyword and ignore error    Stop NSA traffic  ue=${ue_id}  dir=dl

Wait ${seconds}s for tput stable
    Log to console    Running traffic for ${seconds} seconds
    Sleep  ${seconds}

UE detach
    [Arguments]    ${ue_id}=11
    Log to console    Detaching UE_${ue_id}
    Execute egate command    cmd=ue_detach id=${ue_id}    pass_regexp=UE${ue_id}: detached
    Sleep    1s
