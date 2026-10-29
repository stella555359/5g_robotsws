*** Settings ***
Documentation
...    Author:          Bartlomiej Lebda | Jakub Klein
...    Maintainer:      Bartlomiej Lebda | Jakub Klein
...    Contact:         bartlomiej.lebda@nokia.com jakub.klein@nokia.com
...    Team in charge:  I_EXT_PZ_1_WRO_6_GMS
...    Description:     The following keywords are responsible for checking the status of the selected BTS component
...                     while the blocked/locked status on other components

Resource   Component_states_resources/component_states_checker.robot

*** Keywords ***
###Locked checking
###While COAM BTS Locked
Check Component while BTS locked
    [Arguments]    ${component}    ${component_index}    ${connection}=default
    [Documentation]  This keyword check status of given component while BTS is locked, given component has to be: SMOD, BBMOD or RU
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked  proceduralStatus=configured
    Check specific status on selected component    ${component}-${component_index}    ${expected_statuses}    connection=${connection}

Check GNSS while COAM BTS locked
    [Arguments]    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
    Check specific status on selected component  GNSSE_R-All     ${expected_statuses}    connection=${connection}

Check Cell while COAM BTS locked
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    availabilityStatus=Dependency  operationalState=Disabled  administrativeState=Unlocked  proceduralStatus=configured
    Check specific status on selected component    NRCELL_R-${component_index}    ${expected_statuses}    connection=${connection}

###While BBMOD Locked
Check Component while BBMOD locked
    [Arguments]    ${component}    ${component_index}    ${connection}=default
    [Documentation]  This keyword check status of given component while BBMOD is locked, given component has to be: SMOD or RU
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked  proceduralStatus=configured
    Check specific status on selected component    ${component}-${component_index}    ${expected_statuses}    connection=${connection}

Check BBMOD while BBMOD locked
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Locked  proceduralStatus=configured
    Check specific status on selected component    RMOD_R-${component_index}    ${expected_statuses}    connection=${connection}

Check Cell while BBMOD locked
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    availabilityStatus=Dependency   operationalState=Disabled  administrativeState=Unlocked  proceduralStatus=configured
    Check specific status on selected component    NRCELL_R-${component_index}    ${expected_statuses}    connection=${connection}

Check GNSS while BBMOD locked
    [Arguments]    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
    Check specific status on selected component  GNSSE_R-All     ${expected_statuses}    connection=${connection}

###While RU Locked
Check Component while RU locked
    [Arguments]    ${component}    ${component_index}    ${connection}=default
    [Documentation]  This keyword check status of given component while BTS is locked, given component has to be: SMOD or BBMOD
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked  proceduralStatus=configured
    Check specific status on selected component    ${component}-${component_index}    ${expected_statuses}    connection=${connection}

Check RU while RU locked
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Locked  proceduralStatus=configured
    Check specific status on selected component    RMOD_R-${component_index}    ${expected_statuses}    connection=${connection}

Check Cell while RU locked
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    availabilityStatus=Dependency  operationalState=Disabled  administrativeState=Unlocked  proceduralStatus=configured
    Check specific status on selected component    NRCELL_R-${component_index}    ${expected_statuses}    connection=${connection}

Check GNSS while RU locked
    [Arguments]    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
    Check specific status on selected component  GNSSE_R-All     ${expected_statuses}    connection=${connection}

###While Cell Locked
Check Component while cell locked
    [Arguments]    ${component}    ${component_index}    ${connection}=default
    [Documentation]  This keyword check status of given component while BTS is locked, given component has to be: SMOD, BBMOD or RU
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked  proceduralStatus=configured
    Check specific status on selected component    ${component}-${component_index}    ${expected_statuses}    connection=${connection}

Check GNSS while Cell locked
    [Arguments]    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
    Check specific status on selected component  GNSSE_R-All     ${expected_statuses}    connection=${connection}

Check Cell while Cell locked
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    availabilityStatus=Offline  operationalState=Disabled  administrativeState=Locked  proceduralStatus=initialization required
    Check specific status on selected component    NRCELL_R-${component_index}    ${expected_statuses}    connection=${connection}

###OnAir checking
Check Component while OnAir
    [Arguments]    ${component}    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked  proceduralStatus=configured
    Check specific status on selected component    ${component}-${component_index}    ${expected_statuses}    connection=${connection}

Check GNSS while OnAir
    [Arguments]    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
    Check specific status on selected component  GNSSE_R-All    ${expected_statuses}

Check Cell while OnAir
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary    operationalState=Enabled  administrativeState=Unlocked  proceduralStatus=configured
    &{expected_statuses_2}  create dictionary    availabilityStatus=Online
    &{expected_statuses_3}  create dictionary    availabilityStatus=Degraded
    Check specific status on selected component    NRCELL_R-${component_index}    ${expected_statuses}    connection=${connection}
    ${Online}=     Run Keyword and Return Status  Check specific status on selected component    NRCELL_R-${component_index}
    ...    ${expected_statuses_2}    connection=${connection}
    ${Degraded}=   Run keyword if  ${Online}==False  Run Keyword and Return Status
    ...    Check specific status on selected component    NRCELL_R-${component_index}    ${expected_statuses_3}    connection=${connection}
    ...    ELSE IF   ${Online}==True  Set Variable  False
    Run Keyword If  ${Online}==False and ${Degraded}==False   Fail

###Reset checking
###While BBMOD Reset
Check Component while BBMOD reset
    [Arguments]    ${component}    ${component_index}   ${connection}=default
    [Documentation]  This keyword check status of given component while BTS is locked, given component has to be: RU or BBMOD
    &{expected_statuses}    create dictionary
    ...    operationalState=Disabled  availabilityStatus=Offline  administrativeState=Unlocked   #proceduralStatus=not initialized TO DO check if
#    ...                                                                                         #procedural is "initializing" or "not initialized"
    Check specific status on selected component    ${component}-${component_index}    ${expected_statuses}    connection=${connection}

Check SMOD while BBMOD reset
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked  proceduralStatus=configured
    Check specific status on selected component    SMOD_R-${component_index}    ${expected_statuses}    connection=${connection}

Check GNSS while BBMOD reset
    [Arguments]    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
    Check specific status on selected component  GNSSE_R-All     ${expected_statuses}    connection=${connection}

Check Cell while BBMOD reset
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    availabilityStatus=Failed  operationalState=Disabled  administrativeState=Unlocked  proceduralStatus=not initialized
    Check specific status on selected component    NRCELL_R-${component_index}    ${expected_statuses}    connection=${connection}

###While RU Reset
Check Component while RU reset
    [Arguments]    ${component}    ${component_index}    ${connection}=default
    [Documentation]  This keyword check status of given component while BTS is locked, given component has to be: SMOD or BBMOD
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked  proceduralStatus=configured
    Check specific status on selected component    ${component}-${component_index}    ${expected_statuses}    connection=${connection}

Check GNSS while RU reset
    [Arguments]    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
    Check specific status on selected component  GNSSE_R-All     ${expected_statuses}    connection=${connection}

Check RU while RU reset
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Disabled  availabilityStatus=Not Installed  administrativeState=Unlocked  proceduralStatus=not initialized
    Check specific status on selected component    RMOD_R-${component_index}    ${expected_statuses}    connection=${connection}

Check Cell while RU reset
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    availabilityStatus=Failed  operationalState=Disabled  administrativeState=Unlocked  proceduralStatus=not initialized
    Check specific status on selected component    NRCELL_R-${component_index}    ${expected_statuses}    connection=${connection}

###While GNSS Reset
Check Component while GNSS reset
    [Arguments]    ${component}    ${component_index}    ${connection}=default
    [Documentation]  This keyword check status of given component while BTS is locked, given component has to be:RU, SMOD or BBMOD
    &{expected_statuses}    create dictionary
    ...    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked  proceduralStatus=configured
    Check specific status on selected component    ${component}-${component_index}    ${expected_statuses}    connection=${connection}

Check GNSS while GNSS reset
    [Arguments]    ${connection}=default
    &{expected_statuses}    create dictionary
    ...    operationalState=Disabled  availabilityStatus=Offline  administrativeState=Unlocked
    Check specific status on selected component  GNSSE_R-All     ${expected_statuses}    connection=${connection}

Check Cell while GNSS reset
    [Arguments]    ${component_index}    ${connection}=default
    &{expected_statuses}    create dictionary    operationalState=Enabled  administrativeState=Unlocked  #proceduralStatus=configured
    &{expected_statuses_2}  create dictionary   availabilityStatus=Online
    &{expected_statuses_3}  create dictionary   availabilityStatus=Degraded
    Check specific status on selected component    NRCELL_R-${component_index}    ${expected_statuses}    connection=${connection}
    ${Online}=   Run Keyword and Return Status  Check specific status on selected component    NRCELL_R-${component_index}    ${expected_statuses_2}
    ...    connection=${connection}
    ${Degraded}=   Run keyword if  ${Online}==False  Run Keyword and Return Status
    ...    Check specific status on selected component    NRCELL_R-${component_index}    ${expected_statuses_3}    connection=${connection}
    ...    ELSE IF  ${Online}==True  Set Variable  False
    Run Keyword If  ${Online}==False and ${Degraded}==False   Fail
