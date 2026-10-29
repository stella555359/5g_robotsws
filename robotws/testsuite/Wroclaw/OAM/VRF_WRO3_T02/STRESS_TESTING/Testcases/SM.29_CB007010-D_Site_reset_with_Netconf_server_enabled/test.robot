*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot
Resource    ../../../resources_mem/onap.robot

Documentation
...  TEST NAME:     SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled
...  AUTHORS:       jakub.hirny@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if Netconf server is enabled after Site Reset.
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
...  20.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-399 - TC creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled
    SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled.Test_Step:0 Test Preparation
    SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled.Test_Step:1 Perfom Site Reset
    SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled.Test_Step:2 Check BTS After Reset

SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log    Step:0 Test Preparation    console=${True}
    Log to console    ========================================
    SCF Backup
    ${rats}=    Detect RATs
    ${if_nr_exist}=    Run Keyword And Return Status    List Should Contain Value    ${rats}    nr
    Set Test Variable    ${if_nr_exist}
    ${netconf_service_value}=    Get Value Under MPLANEONAP Object    activateOranO1NetconfService
    Run Keyword If    '${netconf_service_value}'=='False'    Run Keywords
    ...    Log To Console    \n== Preparing for test by setting 'activateOranO1NetconfService' value to 'true' ==
    ...    AND    Test Preparation Set Netconf Service To True
    ${COUNTER_BEFORE_TEST}=    Get Reset Counter From Blackbox    COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable    ${COUNTER_BEFORE_TEST}

SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled.Test_Step:1 Perfom Site Reset
    Log to console    \n========================================
    Log    Step:1 Perfoming Site Reset    console=${True}
    Log to console    ========================================
    Run Keyword If    ${if_nr_exist}    Run Keywords
    ...  Allow Fault In Watchdog    faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Allow Fault In Watchdog    faultID=7300  #fault_name: No X2 link available
    ...    AND    Allow Fault In Watchdog    faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ...    AND    Allow Fault In Watchdog    faultID=6150  #fault_name: GTP-U Path Failure
    Allow Fault In Watchdog    faultID=4744  #fault_name: O-RAN O1 Netconf service failure
    Log To Console    == Performing Site Reset... ==
    ${time_before}=    Get Current Date
    admin.Reset Site    timeout=700
    ${time_after}=    Get Current Date
    ${diff}=    Subtract Date From Date    ${time_after}    ${time_before}
    Should Be True    ${diff}<370  #OM_GEN_SFS_PERF_CAP.26203
    Log    == BTS Reset is done and it took ${diff} ==    console=${True}

SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled.Test_Step:2 Check BTS After Reset
    Log to console    \n========================================
    Log    Step:2 Checking BTS and NetConf Connection Status After Reset    console=${True}
    Log to console    ========================================
    Check SMODs State    ${SMOD_expected_states}
    Wait Until Keyword Succeeds    6x    20 sec    Check Netconf Status    Initializing
    Disallow Fault In Watchdog    faultID=4744  #fault_name: O-RAN O1 Netconf service failure
    Check RMODs State    ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
	Check BTS State    ${BTS_expected_states}
	Check If NLWG Cells Are OnAir
	Check Netconf Status
    Run Keyword If  ${if_nr_exist}  Run Keywords  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
    ...    AND    Disallow Fault In Watchdog    faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Disallow Fault In Watchdog    faultID=7300  #fault_name: No X2 link available
    ...    AND    Disallow Fault In Watchdog    faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ...    AND    Disallow Fault In Watchdog    faultID=6150  #fault_name: GTP-U Path Failure
    ${COUNTER_AFTER_TEST}=    Get Reset Counter From Blackbox    COLLECT_BLACKBOX_FILE=${True}
    ${counter_diff}    Evaluate    abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If    ${0}<${counter_diff}<${2}    Log To Console    Reset Counter Incremented +${counter_diff}
    ...  ELSE    Log    Reset Counter Incremented +${counter_diff}    WARN
	Check If Unexpected Alarms Are Raised    ${skip_fault}

Test Preparation Set Netconf Service To True
    ${COUNTER_BEFORE_TEST}=    Get Reset Counter From Blackbox    COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable    ${COUNTER_BEFORE_TEST}
    Run Keyword If    ${if_nr_exist}    Run Keywords
    ...  Allow Fault In Watchdog    faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Allow Fault In Watchdog    faultID=7300  #fault_name: No X2 link available
    ...    AND    Allow Fault In Watchdog    faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Netconf Service Parameter Update    True
    Log To Console    Checking BTS states...
    Check SMODs State    ${SMOD_expected_states}
	Wait Until Keyword Succeeds    6x    20 sec    Check Netconf Status    Initializing
	Check RMODs State    ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    Check BTS State    ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Check Netconf Status
    Run Keyword If    ${if_nr_exist}    Run Keywords
    ...    Disallow Fault In Watchdog    faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Disallow Fault In Watchdog    faultID=7300  #fault_name: No X2 link available
    ...    AND    Disallow Fault In Watchdog    faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Check If Unexpected Alarms Are Raised    ${skip_fault}
    ${COUNTER_AFTER_TEST}=    Get Reset Counter From Blackbox    COLLECT_BLACKBOX_FILE=${True}
    ${counter_diff}    Evaluate    abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If    ${0}<${counter_diff}<${2}    Log To Console    Reset Counter Incremented +${counter_diff}
    ...  ELSE    Log    Reset Counter Incremented +${counter_diff}    WARN
    Log to console    =======================
    Log to console    DONE - proceeding with testing.
    Log to console    =======================

