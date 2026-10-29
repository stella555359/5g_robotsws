*** Settings ***
Documentation
...  Multi VM Robot Helper

Library    taf.sw.wtssim  # taf_sw_wtssim_wrapper dependency

Library    python/wts_multivm_helper.py
Library    python/taf_sw_wtssim_wrapper.py
Library    python/wts_wrapper.py

Resource    performance_keywords.robot
Resource    performance_test_setup.robot
Resource    performance_cellsetup_multivm.robot
Resource    performance_log_collection.robot
Resource    performance_snapshot.robot


*** Variables ***
${EGATE_CONFIG_TIMEOUT}        2minutes
${EGATE_CONFIG_PASS_REGEXP}    CHANGE STATE: CONFIGURED


*** Keywords ***
Run MultiVM PET Testcase
    [Documentation]
    ...    Specifically made to run AP PET Lua scripts only!
    ...       to create cfg_sim_files:
    ...          ex.    \@{cfg_sim_files}=  Create list
    ...                 ...    \${{ 1, (sansa_tdd_ap1.lua, run_configuration()) }}
    ...                 ...    \${{ 2, (no_operations, no_operations) }}
    ...                 ...    \${{ 3, (no_operations, no_operations) }}
    ...
    ...       to create script_files:
    ...          ex.    \@{script_files}=  Create list
    ...                 ...    \${{ 1, (commands_tdd_ap1.lua, tdd_3cells_varUEs_UL()) }}
    ...                 ...    \${{ 2, (no_operations, no_operations) }}
    ...                 ...    \${{ 3, (no_operations, no_operations) }}
    [Arguments]    ${argp}
    ${args}    Setup Lua Configuration For MultiVM    ${argp}

    wts_multivm_helper.Upload WTS Files To All VM    ${args.egate_files_dir}    tl=${tl}
    performance_keywords.Common Log Setup    ${args}

    # Modified by AI: 2026-03-17 - Skip cfg_sim and on-air setup when setup_on_air is false (loop iterations)
    IF    "${args.setup_on_air}"=="true" and ${ON_AIR_STATUS}==${False}
        Run Lua Configuration For MultiVM    ${args}
        performance_cellsetup_multivm.Wait For MultiVM On Air     start_cell=${args.start_cell}
        ...                                                       end_cell=${args.end_cell}
        ...                                                       active_cells=${args.active_cells}
        Set Test Variable    ${ON_AIR_STATUS}    ${True}
    ELSE
        Log To Console    Setup on Air is skipped (MultiVM)!
    END

    #  [VRFULMPERF-67] new requirement to have a different order in executing the scripts,
    #                  so added the option to pass the script files as an argument
    #                  instead of using the fixed order of script_file_1, script_file_2, script_file_3
    ${is_not_list}=      Evaluate     not isinstance($args.script_files, list)
    IF   ${is_not_list}
        @{script_files}=  Create list
        FOR    ${scripts}    IN    @{args.script_files.split(";")}
            FOR    ${vm}    ${script}    ${entry}    IN    @{scripts.split(",")}
                Append To List    ${script_files}    ${{ [${vm}, ${script}, ${entry}] }}
            END
        END
        Set To Dictionary    ${args}    script_files=${script_files}
    END

    FOR    ${script_file}    IN    @{args.script_files}
        ${vm}    ${script}    ${entry}    Set Variable    ${script_file}[0]    ${script_file}[1]    ${script_file}[2]
        Log To Console    EGATE VM${${vm}}: ${script}, ${entry}
        IF    "${script}"!="no_operations"
            ${cmd}    Set Variable    script file\=${script} entry\=${entry}
            taf_sw_wtssim_wrapper.Execute Egate Command    ${cmd}    test_pc_index=${{ int(${vm})-1 }}
            Sleep    ${args.egate_script_delay_per_vm}    reason=[VRFULMPERF-21] Add Option for MultiVM scripts to wait before executing the next vm
        END
    END

    [Teardown]    performance_keywords.Common Log Teardown


Run MultiVM WTS Manager Testcase
    [Arguments]    ${argp}
    ${args}    Setup Lua Configuration For MultiVM    ${argp}

    wts_multivm_helper.Upload WTS Files To All VM    ${args.egate_files_dir}    tl=${tl}
    performance_keywords.Common Log Setup    ${args}

    # Modified by AI: 2026-03-17 - Skip cfg_sim and on-air setup when setup_on_air is false (loop iterations)
    IF    "${args.setup_on_air}"=="true" and ${ON_AIR_STATUS}==${False}
        Run Lua Configuration For MultiVM    ${args}
        performance_cellsetup_multivm.Wait For MultiVM On Air     start_cell=${args.start_cell}
        ...                                                       end_cell=${args.end_cell}
        ...                                                       active_cells=${args.active_cells}
        Set Test Variable    ${ON_AIR_STATUS}    ${True}
    ELSE
        Log To Console    Setup on Air is skipped!
    END

    ${is_not_list}=      Evaluate     not isinstance($args.wts_manager_args, list)
    IF   ${is_not_list}
        @{wts_manager_args}=  Create list
        FOR    ${inputs}    IN    @{args.wts_manager_args.split(";")}
            FOR    ${vm}    ${input_json}    ${input_args}    IN    @{inputs.split(",")}
                Append To List    ${wts_manager_args}    ${{ [${vm}, ${input_json}, ${input_args.replace('%',' ')}] }}
            END
        END
        Set To Dictionary    ${args}    wts_manager_args=${wts_manager_args}
    END

    FOR    ${wts_manager_arg}    IN    @{args.wts_manager_args}
        ${vm}    ${input_json}    ${input_args}    Set Variable    ${wts_manager_arg}[0]
        ...                                                                    ${wts_manager_arg}[1]
        ...                                                                    ${wts_manager_arg}[2]
        Log To Console    EGATE VM${${vm}}: ${input_json}, ${input_args}
        IF    "${input_json}"!="no_operations"
            wts_multivm_helper.Execute WTS Manager On VM    ${input_json}
            ...                                             ${input_args}
            ...                                             test_pc_index=${{ int(${vm})-1 }}
            ...                                             run_async=${args.wts_manager_async}
            Sleep    ${args.egate_script_delay_per_vm}    reason=[VRFULMPERF-21] Add Option for MultiVM scripts to wait before executing the next vm
        END
    END

    Run Keyword And Continue On Failure     Wait Until Expected UE Count Reached    ${args}
    Run Keyword And Continue On Failure     Collect Traffic Logs    ${args}

    [Teardown]    performance_keywords.Common Log Teardown    subfolder=${RL_PATH.traffic_logs}


Setup Lua Configuration For MultiVM
    [Arguments]    ${args}
    ${is_not_list}=      Evaluate     not isinstance($args.cfg_sim_files, list)
    IF   ${is_not_list}
        @{cfg_sim_files}=  Create list
        FOR    ${scripts}    IN    @{args.cfg_sim_files.split(";")}
            FOR    ${vm}    ${script}    ${entry}    IN    @{scripts.split(",")}
                Append To List    ${cfg_sim_files}    ${{ [${vm}, ${script}, ${entry}] }}
            END
        END
        Set To Dictionary    ${args}    cfg_sim_files=${cfg_sim_files}
    END
    RETURN    ${args}


Run Lua Configuration For MultiVM
    [Arguments]    ${args}
    FOR    ${cfg_sim_file}    IN    @{args.cfg_sim_files}
        ${vm}    ${script}    ${entry}    Set Variable    ${cfg_sim_file}[0]    ${cfg_sim_file}[1]    ${cfg_sim_file}[2]
        Log To Console    EGATE VM${${vm}}: ${script}, ${entry}
        IF    "${script}"!="no_operations"
            ${cmd}    Set Variable    cfg_sim file\=${script} entry\=${entry}
            taf_sw_wtssim_wrapper.Execute Egate Command    ${cmd}
            ...                                            test_pc_index=${{ int(${vm})-1 }}
            ...                                            pass_regexp=${EGATE_CONFIG_PASS_REGEXP}
            ...                                            timeout=${EGATE_CONFIG_TIMEOUT}
        END
    END


Get UE Count For All Egates
    [Arguments]    ${num_cells}
    ${cells}    wts_multivm_helper.Get UE Count For All Egates    ${num_cells}    tl=${tl}
    RETURN    ${cells}


Assert Current UE Count
    [Arguments]    ${expected_ue_count}    ${num_cells}
    ${cells}    Get UE Count For All Egates    ${num_cells}
    ${ue_sum}    Evaluate    sum($cells)
    Should Be True     int($expected_ue_count) == int($ue_sum)


Wait Until Expected UE Count Reached
    [Arguments]    ${args}    ${expected_total_ue_count}=${None}    ${expected_ue_count_per_cell}=${None}
    ...            ${timeout}=2 min    ${interval}=15 s
    IF    ${expected_ue_count_per_cell}==${None}
        ${expected_ue_count_per_cell}    Set Variable    ${args.expect_ue_count}
    END
    IF    ${expected_total_ue_count}==${None}
        ${expected_total_ue_count}    performance_keywords.Get Total Expected UE Count    ${args}
    END
    Log To Console    Wait ${timeout} Until Expected UE Count Reached
    taf_sw_wtssim_wrapper.Setup All Egates And Edaemons Connections    tl=${tl}
    ${status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${timeout}   ${interval}
    ...        Assert Current UE Count    ${expected_total_ue_count}    ${args.num_cells}
    Print UE Count Per Cell    args=${args}    expected_total_ue_count=${expected_total_ue_count}
    ...                                        expected_ue_count_per_cell=${expected_ue_count_per_cell}
    IF    not ${status}      FAIL    Expected UE Count Not Reached!


Print UE Count Per Cell
    [Arguments]    ${args}    ${expected_total_ue_count}    ${expected_ue_count_per_cell}=${None}
    ${cells}    Get UE Count For All Egates    ${args.num_cells}
    IF    ${expected_ue_count_per_cell}!=${None}
        Log    Expected UE count per cell manually set    level=DEBUG
    ELSE IF    ${args.cell_max_ue}!=${TS_LIST_NULL}
        Log    Expected UE count from cell_max_ue    level=DEBUG
        ${expected_ue_count_per_cell}    Set Variable    ${args.cell_max_ue}
    ELSE
        Log    Expected UE count deduced from expected_total_ue_count    level=DEBUG
        ${expected_ue_count_per_cell}    Set Variable    ${expected_total_ue_count}
    END
    ${ue_table}    wts_wrapper.Get UE Count Per Cell Table    num_cells=${args.num_cells}
    ...                                                       cells=${cells}
    ...                                                       expected=${expected_ue_count_per_cell}
    Log To Console    ${ue_table}


Collect Traffic Logs
    [Arguments]    ${testcase_args}    ${subfolder}=${EMPTY}
    ${remote_subfolder}    Set Variable    ${RL_PATH.traffic_logs}
    IF    "${subfolder}" != "${EMPTY}"
        ${remote_subfolder}         Set Variable    ${remote_subfolder}/${subfolder}
    END
    ${pm_location}    performance_log_collection.Wait And Collect One Measurement Cycle    subfolder=${remote_subfolder}
    performance_keywords.PM Counter Routine    ${testcase_args}    pm_location=${pm_location}
    IF    "${TP.ENABLE_SNAPSHOT}"=="true"
        ${snapshot_path}    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=${remote_subfolder}
        performance_snapshot.Post Process Snapshot    ${snapshot_path}    subfolder=${remote_subfolder}
    END

Execute Egate Command On All VMs
    [Arguments]    ${command}    ${number_of_vms}=${3}  # Assuming 3 VMs, adjust if needed
    FOR    ${vm}    IN RANGE    1    ${number_of_vms+1}
        taf_sw_wtssim_wrapper.Execute Egate Command    ${command}    test_pc_index=${{ int(${vm})-1 }}
    END
