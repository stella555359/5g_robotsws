*** Settings ***
Documentation       Resource for CB010545 feature
#Library    ta5g_testline_management
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_pm_counters
Library    ta5g_file_system
Library    ta5g_ue_measurements
Library    ta5g_dcap
Library    ta_pcmd.tshark_plugin_configurator
Library    ta_pcmd
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    M2M.py


*** Variables ***

${vdu_ip}     192.168.255.129
${vcu_ip}     192.168.100.129
${vdu_username}     Nemuadmin
${vdu_password}     Nokia@123

*** Keywords ***
Send getCellList Command and check active UEs from each cell
    [Arguments]    ${total_ues}
    ${cells_ues}    Set variable    0
    coam.connect to
    ${a}     coam.get cell list
    coam.teardown
    ${a_list}   Set variable   ${a['cells']['nr']}
    ${length}=   Get Length   ${a_list}
    ${cell_list_counters}=  create list
    ${cell_list_conf}=  create list
    ${get_bts_info}=  create list
    FOR  ${i}   IN RANGE   ${length}
        Append To List   ${cell_list_conf}   ${a_list[${i}]['id']['configuration']}
        Append To List   ${cell_list_counters}   ${a_list[${i}]['counters']['activeUEs']}
        ${cells_ues}=    Evaluate    ${cells_ues} + ${cell_list_counters}[${i}]
    END
    Should Be Equal As Integers     ${cells_ues}    ${total_ues}

Get vDu Cells 1
    ${cells}=   get_vdu_cells   host=${vdu_ip}   username=${vdu_username}     password=${vdu_password}
    log list    ${cells}

    FOR     ${cell}     IN      @{cells}
        ${cell_info}=   get_vdu_cell_with_id	host=${vdu_ip}	cell_id=${cell}[basicCell][id]
        ...     username=${vdu_username}     password=${vdu_password}
        Log Dictionary	${cell_info}
#        Log Dictionary	${cell_info}[availabilityStatus]
        Log To Console  \ncell_id: ${cell}[basicCell][id], activeUEs: ${cell_info}[activeUEs]
    END

Get vDu Cells nr1
    ${cells}=   get_vdu_cells   host=${vdu_ip}   username=${vdu_username}     password=${vdu_password}
    log list    ${cells}

    ${cell}=    Set Variable    ${cells}[0]
    ${cell_info}=   get_vdu_cell_with_id	host=${vdu_ip}	cell_id=${cell}[basicCell][id]
    ...     username=${vdu_username}     password=${vdu_password}
    Log Dictionary	${cell_info}
#   Log Dictionary	${cell_info}[availabilityStatus]
    Log To Console  \ncell_id: ${cell}[basicCell][id], activeUEs: ${cell_info}[activeUEs]
    [return]    ${cell}[basicCell][id]    ${cell_info}[activeUEs]


Get vCu Cells 1
    ${cells}  get_cu_cells   host=${vcu_ip}   username=${vdu_username}     password=${vdu_password}
    log list    ${cells}

    FOR     ${cell}     IN      @{cells}
        ${cell_info}=   get_cu_cell_with_id	host=${vcu_ip}	cell_id=${cell}[basicCell][id]
        ...     username=${vdu_username}     password=${vdu_password}
        Log Dictionary	${cell_info}
#        Log Dictionary	${cell_info}[availabilityStatus]
        Log To Console  \ncell_id: ${cell}[basicCell][id], activeUEs: ${cell_info}[activeUEs]
        [return]    ${cell}[basicCell][id]    ${cell_info}[activeUEs]
    END

Get vCu Cells nr1
    ${cells}=    Get Cu Cells    host=${vcu_ip}    username=${vdu_username}    password=${vdu_password}
    Log List    ${cells}

    ${cell}=    Set Variable    ${cells}[0]
    ${cell_info}=    Get Cu Cell With Id    host=${vcu_ip}    cell_id=${cell}[basicCell][id]
    ...    username=${vdu_username}    password=${vdu_password}
    Log Dictionary    ${cell_info}
    Log To Console    \ncell_id: ${cell}[basicCell][id], activeUEs: ${cell_info}[activeUEs]
    [Return]    ${cell}[basicCell][id]    ${cell_info}[activeUEs]


