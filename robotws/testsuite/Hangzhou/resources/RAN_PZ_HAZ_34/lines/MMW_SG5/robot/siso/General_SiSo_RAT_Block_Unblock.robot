*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Variables ***


*** Keywords ***
General_SiSo_RAT_Block_Unblock
    [Documentation]    the keyword is only applicable for verifying lte and nr, not applicable for 2G&3G
    [Arguments]    ${target_rat}=nr    ${other_rat}=null
    #step 1   block RAT
    Selenium_sbts.block_rat    rat=${target_rat}
    Wait Until Keyword Succeeds    30s    3s    Verify BTS Alarm Exist
    ...    fault_id=4614    fault_name=RAT blocked
    Run Keyword If    '${target_rat}'=='lte'    Verify block LTE rat status    other_rat=${other_rat}
    Run Keyword If    '${target_rat}'=='nr'    Verify block NR rat status    other_rat=${other_rat}

    #step 2    unblock RAT
    Selenium_sbts.unblock_rat    rat=${target_rat}
    Wait Until Keyword Succeeds    30s    3s    Verify BTS Alarm Not Exist
    ...    fault_id=4614    fault_name=RAT blocked
    Wait Until Keyword Succeeds    5min    15s    Verify BTS All Cells Status Is Normal State

Verify block LTE rat status
    [Documentation]    target_rat is blocked rat. if configure multi-rat, other_rat will be not null
    [Arguments]    ${target_rat}=lte    ${other_rat}=null
    ${blocked_cell_status}    Create Dictionary    administrativeState=unlocked
    ...    blockingState=Blocked
    ...    operationalState=disabled
    Wait Until Keyword Succeeds    300    3s    Verify BTS Cells Status
    ...    except_cell_status=${blocked_cell_status}
    ...    cell_type=${target_rat}
    Run Keyword If    '${other_rat}'=='nr'    Verify BTS 5G Cells Status Is Normal State

Verify block NR rat status
    [Documentation]    target_rat is blocked rat. if configure multi-rat, other_rat will be not null
    [Arguments]    ${target_rat}=nr    ${other_rat}=null
    ${blocked_cell_status}    Create Dictionary    administrativeState=Unlocked
    ...    blockingState=Blocked
    ...    operationalState=disabled
    Wait Until Keyword Succeeds    300    3s    Verify BTS Cells Status
    ...    except_cell_status=${blocked_cell_status}
    ...    cell_type=${target_rat}
    Run Keyword If    '${other_rat}'=='lte'    Verify BTS 4G Cells Status Is Normal State
