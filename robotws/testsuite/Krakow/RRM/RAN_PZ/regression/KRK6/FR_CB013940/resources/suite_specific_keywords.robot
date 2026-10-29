*** Settings ***
Documentation
...   author:     Dawid Dabrowski, Jakub Bak
...   contact:    dawid.dabrowski@nokia.com, jakub.1.bak@nokia.com

Library     DateTime                                                                         WITH NAME    dt
Library     taf.rfrl.bts.commissioning                                                       WITH NAME    commissioning
Library     ./suite_specific_keywords.py

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot


*** Keywords ***

Test Setup with on air tl preparation
    [Arguments]    ${prefix_tag}=${prefix_tag}
    [Documentation]    This KW is used for test setup with OnAir TL preparation
    Common Suite Setup With OnAir Test Line Preparation
    ...                 increase_timeout_for_update_sw=1800
    ...                 increase_time_for_checking_cells=1800
    ...                 prefix_tag=${prefix_tag}

Change Ru Voltage
    [Arguments]    ${voltage}    ${ru_id}=0
    [Documentation]    This KW is used for changing RMOD voltage
    ...    :param voltage:    RU voltage in mV
    ...    :param ru_id:      ID of the RMOD which voltage we're changing
    Log Action To Console    Changing voltage to ${voltage} mV
    Change Voltage    ${voltage}    ru_id=${ru_id}

Wait For Voltage Change
    [Arguments]    ${voltage}    ${ru_id}=1
    [Documentation]    KW used for changing if voltage has changed on RMOD
    ...    :param voltage:    RU voltage in mV
    ...    :param ru_id:      ID of the RMOD which voltage we're checking
    Log Action to Console     Waiting for RU voltage change
    Wait Until Keyword Succeeds    120s    15s    Validate Voltage Change     ${voltage}    ${ru_id}

Log Action to Console
    [Arguments]    ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    :param msg:    message logged
    Run keyword if    '${new_line_before}'=='${True}'    Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'    dt.Get Current Date
    Run keyword if    '${datatime}'=='${True}'    Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'    Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'    Log To Console    \n    no_newline=${True}

Set alVoltUnstableExpirationTimer value
    [Arguments]    ${value}=15   ${rmod_id}=1
    [Documentation]     Keyword used to setting alVoltUnstableExpirationTimer timer on RU to chosen value
    ...    :param value:      value of alVoltUnstableExpirationTimer timer. Should be in incrementation of 15min
    ...    :param rmod_id:    ID of the RMOD which voltage we're checking
    Log Action To Console   Set alVoltUnstableExpirationTimer timer to ${value} min
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/EQM-1/APEQM-1/RMOD-${rmod_id}
    ...    param_name=alVoltUnstableExpirationTimer
    ...    param_value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${180}

Set alVoltUnstableExpirationTimerRU value
    [Arguments]    ${value}=15
    [Documentation]     Keyword used to setting alVoltUnstableExpirationTimerRU timer on RU to chosen value
    ...    :param value: value of alVoltUnstableExpirationTimerRU. Should be in incrementation of 15min
    Log Action To Console   Set alVoltUnstableExpirationTimerRU to ${value} min
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/EQM-1/APEQM-1
    ...    param_name=alVoltUnstableExpirationTimerRU
    ...    param_value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${180}

Set alVoltUnstableThreshold value
    [Arguments]    ${threshold}=5   ${rmod_id}=1
    [Documentation]     Keyword used to setting alVoltUnstableThreshold on RU to chosen value
    ...    :param value: value of alVoltUnstableThreshold. Should be in incrementation of 1, max value of 10
    ...    :param rmod_id:    ID of the RMOD which voltage we're checking
    Log Action To Console   Set alVoltUnstableThreshold value to ${threshold}
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/EQM-1/APEQM-1/RMOD-${rmod_id}
    ...    param_name=alVoltUnstableThreshold
    ...    param_value=${threshold}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${180}
    Sleep   30s

Wait for alVoltUnstableExpirationTimerRU min to expiry
    [Arguments]     ${waiting_time}=15min
    [Documentation]     Keyword used to wait for alVoltUnstableExpirationTimerRU to expiry
    ...    :param waiting_time: value of alVoltUnstableExpirationTimerRU. Should be in incrementation of 15min
    Log Action To Console   Wait for ${waiting_time} for alVoltUnstableExpirationTimerRU to expiry
    Sleep    ${waiting_time}

Wait for all cells to be on air
    [Documentation]     Keyword used to wait for all cells to be on air
    Log Action to Console    Wait for all cells to be on air
    Wait Until Keyword Succeeds    600    20    gnbcell.Verify All Cells Are Onair    bts_id=0
