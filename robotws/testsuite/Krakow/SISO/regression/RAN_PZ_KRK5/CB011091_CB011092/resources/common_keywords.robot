*** Settings ***
Documentation
...   Keywords for regression testing of feature CB011091/92
...   author: Mateusz Bugaj
...   contact: mateusz.bugaj@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Library      Collections
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms           WITH NAME    alarm
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                WITH NAME    gnb_du
Library     ./resources.py                                                        WITH NAME    local_resources
Library     ./prrh_actions.py                                                     WITH NAME    prrh_actions
Library     ./ru_actions.py                                                       WITH NAME    ru_actions
Library     ./asir_hub_actions.py                                                 WITH NAME    asir_hub_actions
Library     ./bts_actions.py                                                      WITH NAME    bts_actions
Library     ./sfp_actions.py                                                      WITH NAME    sfp_actions
Library      ./call_procedure/ue_proxy.py                                         WITH NAME    ue_proxy
Library      ./call_procedure/ue_operations.py
Library      ./call_procedure/bts_operations.py
Library      ./call_procedure/html_thput_table.py
Library      ./call_procedure/common_operations.py
Library      ./call_procedure/attenuator_operations.py
Library      ./call_procedure/console_thput_table.py

*** Keywords ***
Actions before test
    [Arguments]    ${prefix_tag}=${None}    ${alarms_for_test}=${None}
    local_resources.Perform Setup Reconfiguration   prefix_tag=${prefix_tag}
    Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Reset Hubs Via AsirWebEm
    asir_hub_actions.action_with_asir_hub        action=Reset     gnb_oam_ip=${gnb_oam_ip}     mrbts_id=${mrbts_id}
    ...    nrbts_id=${nrbts_id}
    Wait Until Keyword Succeeds    600 sec    15 sec    gnbcell.Verify All Cells Are Onair

Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Prepare BTS Before UUF UPGRADE Test
    [Arguments]     ${5G_SOURCE_SW}     ${path_to_download}=/home/ute/preparation_build
    local_resources.Prepare Bts before Test     sw_to_load=${5G_SOURCE_SW}      path_to_download=${path_to_download}
    Remove Dirs       ${path_to_download}
    gnb_du.Wait Unitl Connection Via Admin Is Possible      timeout=${600}
    local_resources.Perform Setup Reconfiguration
    Wait Until Keyword Succeeds    900 sec    30 sec    gnbcell.Verify All Cells Are Onair

SFP Lock And Unlock
    FOR     ${sfp_id}     IN      @{sfp_lock_action_dict}
        logger.log_info_to_console      Performing actions for SFP id ${sfp_id} - Lock
        sfp_actions.action with sfp    action=Lock      sfp_id=${sfp_id}
        Reset gNB
        logger.log_info_to_console      Sleeping for ${sfp_lock_action_dict}[${sfp_id}][timeout]
        BuiltIn.Sleep       ${sfp_lock_action_dict}[${sfp_id}][timeout]
        Wait Until Keyword Succeeds       900 sec    30 sec
        ...                               sfp_actions.verify expected alarms on cells and state on rest cells
        ...                               impacted_cells=${sfp_lock_action_dict}[${sfp_id}][impacted_cells]
        ...                               expected_alarms=${sfp_lock_action_dict}[${sfp_id}][expected_alarms]
        logger.log_info_to_console      Performing actions for SFP id ${sfp_id} - Unlock
        sfp_actions.action with sfp    action=Unlock      sfp_id=${sfp_id}
        Reset gNB
        Wait Until Keyword Succeeds       900 sec    30 sec    gnbcell.Verify All Cells Are Onair
    END

Lock And Ublock Hubs Via AsirWebEm
    logger.log_info_to_console      Locking All HUBs
    asir_hub_actions.action_with_asir_hub        action=Lock    gnb_oam_ip=${gnb_oam_ip}     mrbts_id=${mrbts_id}
    ...    nrbts_id=${nrbts_id}
    logger.log_info_to_console      Unlocking All HUBs
    asir_hub_actions.action_with_asir_hub        action=Unlock      gnb_oam_ip=${gnb_oam_ip}     mrbts_id=${mrbts_id}
    ...    nrbts_id=${nrbts_id}
    Wait Until Keyword Succeeds    600 sec    15 sec    gnbcell.Verify All Cells Are Onair

Add custom alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${additional_allowed_alarms}    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions after test
    Remove custom allowed alarms if defined
    Common Postconditions With Watching Alarms

Call To Selected Cells
    [Arguments]     ${cell_list}     ${duration}     ${alias}=UE     ${run_num}=1
    ...             ${additional_action}=${None}      ${additional_action_params}=${None}     ${deviation}=${None}
    ue_proxy.Restart UE Proxy On UE PC
    Call Procedure      cell_list=${cell_list}      alias=${alias}      raise_errors=${False}       run_num=${run_num}
    ...                 deviation=${deviation}      duration=${duration}
    ...                 additional_action=${additional_action}      additional_action_params=${additional_action_params}
    ${recall}=         Check If Need Recall
    ${failed_cells}=         Get Failed Cells List
    Run Keyword If     ${recall}==${True}     logger.log_info_to_console
    ...                                       Performing data call for previously failed cells: ${failed_cells}
    Run Keyword If     ${recall}==${True}     ue_proxy.restart_ue_proxy_on_ue_pc
    Run Keyword If     ${recall}==${True}     Call Procedure        cell_list=${failed_cells}     alias=${alias}
    ...                                       deviation=${deviation}      duration=${duration}
    ...                                       run_num=Prepare Num Run Before Recall    run_num=${run_num}    rerun=${True}
    ...                                       additional_action=${additional_action}
    ...                                       additional_action_params=${additional_action_params}
    Run Keyword and Ignore Error        html_thput_table.Generate Html Thput Table      run_num=${run_num}
    Run Keyword and Ignore Error        console_thput_table.Generate Console Thput Table

Call Procedure
    [Arguments]     ${cell_list}     ${deviation}     ${duration}     ${alias}=UE     ${run_num}=1
    ...             ${raise_errors}=${True}     ${rerun}=${False}       ${additional_action}=${None}
    ...             ${additional_action_params}=${None}
    Prepare Setup Before Call Procedure
    Prepare UE For Test     alias=${alias}        capabilities=${capabilities}
    ${auto_deviation}=    Set Variable    False
    FOR     ${cell}     IN      @{cell_list}
        logger.log_info_to_console      *** Call for cell: ${cell} ***
        Prepare Cell Before Call Procedure      cell=${cell}
        ${attach_status}=       Run Keyword And Return Status       Try To Make Attach      expected_cell=${cell}
        ...                     alias=${alias}
        ${tput_dl}      Set Variable    ${TPUT_MATRIX}[${cell}][tput_dl]
        ${tput_ul}      Set Variable    ${TPUT_MATRIX}[${cell}][tput_ul]
        ${protocol}     Set Variable    ${TPUT_MATRIX}[${cell}][protocol]
        ${parallel_streams}      Set Variable    ${TPUT_MATRIX}[${cell}][parallel_streams]
        ${linux_congestion}      Set Variable    ${TPUT_MATRIX}[${cell}][linux_congestion]
        ${action}=       Get Additional Action During Call    action_name=${additional_action}
        ${deviation}      ${auto_deviation}      Get Proper Deviation    deviation=${deviation}     cell=${cell}
        ...                                      auto_dev=${auto_deviation}
        Prepare Cell Before Data Transfer       cell=${cell}     attenuation_level=atten_dl
        Run Keyword If      ${attach_status}==${True}       Run Keyword And Continue On Failure
        ...                 Perform Data Transfer On UE     direction=dl    duration=${duration}    protocol=${protocol}
        ...                                                 parallel_streams=${parallel_streams}    tput=${tput_dl}
        ...                                                 deviation=${deviation}    cell_name=${cell}
        ...                                                 raise_errors=${raise_errors}        run_num=${run_num}
        ...                                                 rerun=${rerun}     linux_congestion=${linux_congestion}
        ...                                                 additional_action=${action}
        ...                                                 additional_action_params=${additional_action_params}
        Prepare Cell Before Data Transfer       cell=${cell}     attenuation_level=atten_ul
        Run Keyword If      ${attach_status}==${True}       Run Keyword And Continue On Failure
        ...                 Perform Data Transfer On UE     direction=ul    duration=${duration}    protocol=${protocol}
        ...                                                 parallel_streams=${parallel_streams}    tput=${tput_ul}
        ...                                                 deviation=${deviation}    cell_name=${cell}
        ...                                                 raise_errors=${raise_errors}    run_num=${run_num}
        ...                                                 rerun=${rerun}    linux_congestion=${linux_congestion}
        ...                                                 additional_action=${action}
        ...                                                 additional_action_params=${additional_action_params}

        Wait Until Keyword Succeeds     5x      10s        Try To Make Detach      alias=${alias}
        Prepare Setup Before Next Call      cell=${cell}
    END
    [Teardown]      Release Resources      ${alias}

Perform Data Transfer On UE
    [Documentation]     Parameters mapping for their aliases:
    ...                 duration                -t
    ...                 parallel_streams        -P - CLIENT
    ...                 size_packet             -l (for UDP) - CLIENT; -M (for TCP) - CLIENT
    ...                 buffer_(client/server)  -w
    ...                 interval                -i - CLIENT&SERVER
    ...                 linux_congestion        -Z - CLIENT
    [Arguments]     ${direction}    ${duration}    ${tput}    ${protocol}    ${deviation}           ${cell_name}
    ...             ${parallel_streams}     ${linux_congestion}     ${size_packet}=1320B   ${buffer_client}=${None}
    ...             ${buffer_server}=${None}    ${run_num}=1        ${interval}=1          ${alias}=UE
    ...             ${raise_errors}=${True}     ${rerun}=${False}       ${additional_action}=${None}
    ...             ${additional_action_params}=${None}

    Perform Data Transfer In Specific Direction     direction=${direction}      duration=${duration}    tput=${tput}
    ...                                             protocol=${protocol}        deviation=${deviation}
    ...                                             cell_name=${cell_name}      run_num=${run_num}
    ...                                             buffer_client=${buffer_client}      buffer_server=${buffer_server}
    ...                                             parallel_streams=${parallel_streams}    size_packet=${size_packet}
    ...                                             interval=${interval}        linux_congestion=${linux_congestion}
    ...                                             alias=${alias}      raise_errors=${raise_errors}    rerun=${rerun}
    ...                                             additional_action=${additional_action}
    ...                                             additional_action_params=${additional_action_params}

Prepare Setup Before Call Procedure
    Prepare Bts Before Call
    Adjust Attenuation      attenuation_level=max

Prepare Cell Before Call Procedure
    [Arguments]     ${cell}
    @{cell_to_call}       create list
    Append To List      ${cell_to_call}    ${cell}
    Perform Parameter Recommisioning        cell_list=${cell_to_call}       param_level=min
    Adjust Attenuation      cell_ids=${cell_to_call}    attenuation_level=avg

Prepare Setup Before Next Call
    [Arguments]     ${cell}
    @{cell_to_call}       create list
    Append To List      ${cell_to_call}    ${cell}
    Perform Parameter Recommisioning        cell_list=${cell_to_call}       param_level=max
    Adjust Attenuation      cell_ids=${cell_to_call}        attenuation_level=max

Prepare Cell Before Data Transfer
    [Arguments]     ${cell}     ${attenuation_level}
    @{cell_to_call}       create list
    Append To List      ${cell_to_call}    ${cell}
    Adjust Attenuation      cell_ids=${cell_to_call}        attenuation_level=${attenuation_level}
