*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot
Resource    ../../../resources_mem/onap.robot

Documentation
...  TEST NAME:     SM.28_CB007010-C_Lock-Unlock_Running_Datastore
...  AUTHORS:       mateusz.gumieniak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  This test checks if the lock and unlock operation via Netconf/ONAP is running correctly
...  *****************
...  Pre-conditions
...  *****************
...  BTS is fully commissioned.
...  BTS is running with Netconf server enabled and fully configured and working with all .yang modules loaded (O-RAN O1 model of the BTS).
...  NACM is configured on O-RAN O1 Netconf server.
...  Netconf client fingerprint is configured on BTS and it is authorized to perform <unlock> operation.
...  ******************
...  History of changes
...  ******************
...  23.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-398 test case creation
...  20.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-478 - additional blocking check
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.28_CB007010-C_Lock-Unlock_Running_Datastore
    SM.28_CB007010-C_Lock-Unlock_Running_Datastore.Test_Step:0 Test Preparation
    SM.28_CB007010-C_Lock-Unlock_Running_Datastore.Test_Step:1 Locking loop
    SM.28_CB007010-C_Lock-Unlock_Running_Datastore.Test_Step:2 Final Checkpoint

SM.28_CB007010-C_Lock-Unlock_Running_Datastore.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${all_cells}  ${4G_5G_cells}    Get one cell for each technology
    Set Test Variable    ${4G_5G_cells}
    Log to console    chosen cells: ${4G_5G_cells}


SM.28_CB007010-C_Lock-Unlock_Running_Datastore.Test_Step:1 Locking loop
    Log to console    \n========================================
    Log  Test_Step:1 Lock/Unlock Running Datastore  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=4340
    Switch Connection  ${ssh_index2}
    Sleep  60s
    FOR  ${i}  IN RANGE  0  15
        ${random_cell}    Evaluate  random.choice(${4G_5G_cells})    random
        Sleep  30s
        #lock the config
        SSHLibrary.Write  lock --target running\r\n
        ${output}  SSHLibrary.Read Until  OK
        Log to console  ${output} to lock configuration
        Sleep  30s
        #try making changes in scf via lock (should be False)
        ${status}    Run Keyword And Return Status    admin.lock    ${random_cell}
        Log to console    ${status} status to lock ${random_cell}
        Run Keyword If    '${status}' != 'False'    Fail
        #unlock the config
        SSHLibrary.Write  unlock --target running\r\n
        ${output}  SSHLibrary.Read Until  OK
        Log to console  ${output} to unlock configuration
        Sleep  30s
        #try making changes in scf via lock unlock (should be true)
        ${status}    Run Keyword And Return Status    admin.lock    ${random_cell}    timeout=180
        Log to console    ${status} status to lock ${random_cell}
        Run Keyword If    '${status}' == 'False'    Fail
        Sleep  30s
        ${status}    Run Keyword And Return Status    admin.unlock    ${random_cell}    timeout=180
        Log to console    ${status} status to unlock ${random_cell}
        Run Keyword If    '${status}' == 'False'    Fail
    END

SM.28_CB007010-C_Lock-Unlock_Running_Datastore.Test_Step:2 Final Checkpoint
    Log to console    \n========================================
    Log  Step: 3 Final Checkpoint  console=${True}
    Log to console    ========================================
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Wait until keyword succeeds  10x  20s  Check If NLWG Cells Are OnAir
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
	...  AND  Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}
