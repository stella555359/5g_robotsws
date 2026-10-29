*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot
Resource    ../../../resources_mem/onap.robot

Documentation
...  TEST NAME:     SM.30_Enable_disable_O_RAN_O1_NetConf_server
...  AUTHORS:       grzegorz.niedzwiedz@nokia.com, jakub.hirny@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check Netconf server status after Enabling/Disabling activateOranO1NetconfService parameter.
...  *****************
...  Pre-conditions
...  *****************
...  BTS is fully commissioned.
...  BTS is running with Netconf server enabled and fully configured and working with all .yang modules loaded (O-RAN O1 model of the BTS).
...  NACM is configured on O-RAN O1 Netconf server.
...  Netconf client fingerprint is configured on BTS.
...  ******************
...  History of changes
...  ******************
...  20.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-396
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
SM.30_CB007010-D_Enabled-Disabled_Netconf_server
    SM.30_CB007010-D_Enabled-Disabled_Netconf_server.Test_Step:0 Test Preparation
    SM.30_CB007010-D_Enabled-Disabled_Netconf_server.Test_Step:1 Netconf server activation flag enabled
    SM.30_CB007010-D_Enabled-Disabled_Netconf_server.Test_Step:2 Netconf server activation flag disabled

SM.30_CB007010-D_Enabled-Disabled_Netconf_server.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log    Step: 0 Test Preparation    console=${True}
    Log to console    ========================================
    ${rats}=    Detect RATs
    Set Test Variable    ${rats}
    ${if_nr_exist}=    Run Keyword And Return Status    List Should Contain Value    ${rats}    nr
    Set Test Variable    ${if_nr_exist}
    ${netconf_service_value}=    Get Value Under MPLANEONAP Object    activateOranO1NetconfService
    Run Keyword If    '${netconf_service_value}'=='True'    Run Keywords
    ...    Log To Console    \n== Preparing for test by setting 'activateOranO1NetconfService' value to 'false' ==
    ...    AND    Check Netconf Status
    ...    AND    Repeatable Checks And Setups    False    Disabled    Disabled

SM.30_CB007010-D_Enabled-Disabled_Netconf_server.Test_Step:1 Netconf server activation flag enabled
    Log to console    \n========================================
    Log    Step: 1 Netconf server activation flag enabling    console=${True}
    Log to console    ========================================
    Repeatable Checks And Setups    True    Initializing    Ready

SM.30_CB007010-D_Enabled-Disabled_Netconf_server.Test_Step:2 Netconf server activation flag disabled
    Log to console    \n========================================
    Log    Step: 2 Netconf server deactivation flag disabling    console=${True}
    Log to console    ========================================
    Repeatable Checks And Setups    False    Disabled    Disabled

BTS Check
    [Arguments]    ${expected1}    ${expected2}
    Check SMODs State    ${SMOD_expected_states}
    Wait Until Keyword Succeeds    6x    20 sec    Check Netconf Status    ${expected1}
    Check RMODs State    ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    Check BTS State    ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Check Netconf Status    ${expected2}
    Disallow NR Faults
    Check If Unexpected Alarms Are Raised    ${skip_fault}

Repeatable Checks And Setups
    [Arguments]    ${update}    ${expected1}    ${expected2}
    ${COUNTER_BEFORE_TEST}=    Get Reset Counter From Blackbox    COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable    ${COUNTER_BEFORE_TEST}
    Allow NR Faults
    Netconf Service Parameter Update    ${update}
    Log To Console    Checking BTS states...
    BTS Check    ${expected1}    ${expected2}
    ${COUNTER_AFTER_TEST}=    Get Reset Counter From Blackbox    COLLECT_BLACKBOX_FILE=${True}
    ${counter_diff}    Evaluate    abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If    ${0}<${counter_diff}<${2}    Log To Console    Reset Counter Incremented +${counter_diff}
    ...  ELSE    Log    Reset Counter Incremented +${counter_diff}    WARN
    Log to console    =======================
    Log to console    DONE
    Log to console    =======================

Allow NR Faults
    Run Keyword If    ${if_nr_exist}    Run Keywords
    ...  Allow Fault In Watchdog    faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Allow Fault In Watchdog    faultID=7300  #fault_name: No X2 link available
    ...    AND    Allow Fault In Watchdog    faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ...    AND    Allow Fault In Watchdog    faultID=6150  #fault_name: GTP-U Path Failure

Disallow NR Faults
    Run Keyword If    ${if_nr_exist}    Run Keywords    Wait Until Keyword Succeeds  10min  1min  Check X2 Link
    ...    AND    Disallow Fault In Watchdog    faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Disallow Fault In Watchdog    faultID=7300  #fault_name: No X2 link available
    ...    AND    Disallow Fault In Watchdog    faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ...    AND    Disallow Fault In Watchdog    faultID=6150  #fault_name: GTP-U Path Failure



