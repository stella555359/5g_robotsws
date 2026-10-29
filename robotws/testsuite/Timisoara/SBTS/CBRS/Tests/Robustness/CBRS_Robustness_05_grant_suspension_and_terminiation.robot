*** Settings ***
Documentation
...    = Author =
...    piotr.lukaszewicz@nokia.com
...    = Maintainer =
...    piotr.lukaszewicz@nokia.com
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    aleksandra.chudzik@nokia.com
...    karol.sadowski@nokia.com
...    katarzyna.kadziela@nokia.com
...    = Summary =
...    Purpose: Verify system behavior in case of many random grant suspensions and terminations. Scenario choose
...    random CBSD and grant ID from configuration.

*** Keywords ***
CBRS_Robustness_05_grant_suspension_and_terminiation
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.314; OM_GEN_SFS_CBRS.355
    [Timeout]    420min

    ${num_of_loops}   Set Variable    5
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${expected_alarms}   Create List    SAS Grant SAS Grant Suspension Failure
    ...                                   Termination Revocation Failure
    ...                                   SAS Grant Failure

    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}

    Enable CBRS Feature On eNB
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/Robustness_05/SAS_Sim.conf
    Wait For All Cells To Be OnAir
    Log    ${\n}CBRS feature enabled, cells are on air    console=true
    Start Capturing Historical Alarms

    ${suspensions}   Create List
    ${terminations}   Create List
    ${possible_scenarios}   Create List    suspension    termination
    Log    Starting ${num_of_loops} iterations...    console=true

    FOR    ${i}    IN RANGE    ${1}    ${num_of_loops}+1
        # get random CBSD ID (in case more than one in configuration)
        ${cbsd_id}   Get Random Cbsd Object
        ${assignedCbsdId}   Get From Dictionary    ${cbsd_id}    assignedCbsdId
        # choose random scenario
        ${random_selection}   Evaluate    random.sample(${possible_scenarios}, 1)    modules=random
        ${chosen_scenario}   Convert To String    ${random_selection}[0]
        ${action_start_time}   Get Time
        Log    Iteration ${i} - Random grant ${chosen_scenario} for CBSD ${assignedCbsdId}    console=true
        # start proper scenario
        IF  '${chosen_scenario}'=='suspension'
            Suspend A Random Grant    enb_id=${enb_id}    cbsd_id=${assignedCbsdId}    sas_log=${sas_logs_dir}
            Append To List    ${suspensions}    ${action_start_time}
        ELSE IF    '${chosen_scenario}'=='termination'
            Terminate A Random Grant    enb_id=${enb_id}    cbsd_id=${assignedCbsdId}    sas_log=${sas_logs_dir}    AND
            Append To List    ${terminations}    ${action_start_time}
        END
    END
    # save number of suspensions and terminations
    ${num_of_suspensions}   Get Length   ${suspensions}
    ${num_of_terminations}   Get Length   ${terminations}
    Log    Performed ${num_of_suspensions} suspensions and ${num_of_terminations} terminations.    console=true

    [Teardown]    Run Keywords    Wait Until Keyword Succeeds    2x    60s    Save And Check Historical Alarms
    ...                           expected_alarms=${expected_alarms}    AND
    ...                           Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Kill All SAS Processes

*** Keywords ***
Suspend A Random Grant
    [Documentation]  Description:           Suspend a random grant and confirm cell drop. Check if SAS log contains
    ...                                     mngGrantSuspendResponse message and new channel has been choosen. At the end
    ...                                     free suspended grant and check fault list on BTS.    ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            piotr.lukaszewicz@nokia.com
    [Arguments]      ${enb_id}              # eNB ID, e.g.: 1876
    ...              ${cbsd_id}             # CBSD ID, e.g.: AEQMadmin_AEQM_1M211713652
    ...              ${sas_log}             # SAS log path, e.g.: /home/ute/SASSim/default/SAS_Sim.log

    Wait For All Cells To Be OnAir
    ${active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
    # get random grant ID for suspension
    ${random_grant_to_suspend}   Evaluate    random.choice(${active_grant_list})    modules=random
    ${grant_suspend_time}   Get Time
    Wait Until BTS Is Not Busy
    Suspend Grant And Confirm Cell Drop    cbsd_id=${cbsd_id}    grant_id=${random_grant_to_suspend}    print_details=False
    ${suspension_end_time}   Get Time
    # filter SAS log file near to grant suspension
    ${log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                   date_start=${grant_suspend_time}
    ...                                   date_stop=${suspension_end_time}
    ${log_file}   Convert To String    ${log_file}
    # check if SAS log contains grant suspension message
    Should Contain    ${log_file}    mngGrantSuspendResponse
    # add an entry to suspended grant list in the file
    Append To File    ${TEST_LOGS_DIR_PATH}/GrantSuspendingHistory.txt    ${grant_suspend_time} Grant ${random_grant_to_suspend} -- SUSPENDED ${\n}
    Log    Grant ${random_grant_to_suspend} suspended on ${grant_suspend_time}    console=true
    Wait For All Cells To Be OnAir
    ${new_active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
    # compare grant IDs before and after suspension to check if one of them changed
    Should Not Be Equal    ${new_active_grant_list}    ${active_grant_list}
    ${grant_free_time}   Get Time
    # free suspended grant in SAS resources for the next iteration
    Send Command To SAS Manager    alias=default    command=grant_free ${cbsd_id} ${random_grant_to_suspend}
    # add an entry to freed grant list in the file
    Append To File    ${TEST_LOGS_DIR_PATH}/GrantSuspendingHistory.txt
    ...    ${grant_free_time} Grant ${random_grant_to_suspend} -- suspension cleared ${\n}
    Log    Grant ${random_grant_to_suspend} freed on ${grant_free_time}    console=true
    ${active_faults}   List Active eNB Faults
    Check For Unwanted Faults    allowed_faults=@{enb_allowed_faults}    active_alarm_list=${active_faults}

Terminate A Random Grant
    [Documentation]  Description:           Terminate a random grant and confirm cell drop. Check if SAS log contains
    ...                                     mngGrantTerminateResponse message and new channel has been choosen. At the end
    ...                                     free terminated grant and check fault list on BTS.   ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            piotr.lukaszewicz@nokia.com
    [Arguments]      ${enb_id}              # eNB ID, e.g.: 1876
    ...              ${cbsd_id}             # CBSD ID, e.g.: AEQMadmin_AEQM_1M211713652
    ...              ${sas_log}             # SAS log path, e.g.: /home/ute/SASSim/default/SAS_Sim.log

    Wait For All Cells To Be OnAir
    # get random grant ID for termination
    ${active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
    ${random_grant_to_terminate}   Evaluate    random.choice(${active_grant_list})    modules=random
    ${grant_terminate_time}   Get Time
    Wait Until BTS Is Not Busy
    Terminate Grant And Confirm Cell Drop    cbsd_id=${cbsd_id}    grant_id=${random_grant_to_terminate}    print_details=False
    ${termination_end_time}   Get Time
    # filter SAS log file near to grant termination
    ${log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                   date_start=${grant_terminate_time}
    ...                                   date_stop=${termination_end_time}
    ${log_file}   Convert To String    ${log_file}
    # check if SAS log contains grant termination message
    Should Contain    ${log_file}    mngGrantTerminateResponse
    # add an entry to terminated grant list in the file
    Append To File    ${TEST_LOGS_DIR_PATH}/GrantTerminatingHistory.txt
    ...    ${grant_terminate_time} Grant ${random_grant_to_terminate} -- TERMINATED ${\n}
    Log    Grant ${random_grant_to_terminate} terminated on ${grant_terminate_time}    console=true
    Wait For All Cells To Be OnAir
    ${new_active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
    # compare grant IDs before and after termination to check if one of them changed
    Should Not Be Equal    ${new_active_grant_list}    ${active_grant_list}
    ${grant_free_time}   Get Time
    # free terminated grant in SAS resources for the next iteration
    Send Command To SAS Manager    alias=default    command=grant_free ${cbsd_id} ${random_grant_to_terminate}
    Append To File    ${TEST_LOGS_DIR_PATH}/GrantTerminatingHistory.txt
    ...    ${grant_free_time} Grant ${random_grant_to_terminate} -- termination cleared ${\n}
    Log    Grant ${random_grant_to_terminate} freed on ${grant_free_time}    console=true
    ${active_faults}   List Active eNB Faults
    Check For Unwanted Faults    allowed_faults=@{enb_allowed_faults}    active_alarm_list=${active_faults}
