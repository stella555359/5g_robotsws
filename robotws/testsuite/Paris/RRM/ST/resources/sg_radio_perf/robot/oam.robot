*** Settings ***
Documentation    Simulation of interface
...              update 18.06.2020   change alias com to coam
...                                  change perform_commissioning : remove bts_id argument
...                             add: for asib : get_frm_asib
...                             add: verify_fsm_enabled_online, verify_fbbs_enabled_online,verify_rus_enabled_online
...                     01.07.2020    import collections
...                     10.07.2020    remove some comments and log to console, modify Verify_rus_enabled_online
...                     23.03.2021:   replace "coam" with "admin"
...                     24.06.2021:   taf.sbts.oam.coam.admin
...                                   give scf file via name (scf_file= ) in admin.perform_commissioning


Library     Collections
Library     taf.sbts.oam.coam.admin       WITH NAME       admin

*** Keywords ***
create_session
    [Documentation]     This keyword simulates the create_session
    [Arguments]     ${base_url}
    ...             ${user}=Nemuadmin
    ...             ${password}=nemuuser
    ...             ${alias}=${None}
    Set Suite Variable     ${SESSION_OPENED}      True
    admin.connect_to         bts_host=${base_url}
    ...                    username=${user}
    ...                    password=${password}
    ...                    name=${alias}


teardown_session
    [Documentation]     This keyword simulates the teardown_session
    [Arguments]     ${session}=${None}
    ...             ${timeout}=10

    #fix robocop
    ${timeout}=    Set Variable    ${timeout}

    Set Suite Variable     ${SESSION_OPENED}      False
    admin.teardown           ${session}


perform_commissioning
    [Documentation]     This keyword simulates the perform_commissioning
    [Arguments]     ${scf_path}
    ...             ${session}=${None}
    ...             ${timeout}=${None}
    Should Be Equal As Strings  ${SESSION_OPENED}        True         ignore_case=True
    Set Suite Variable         ${SESSION_OPENED}      False
    #18.06.2020 remove from coam.perform_commissioning  argument : "bts_id=1"
    admin.perform_commissioning
    ...    scf_file=${scf_path}
    ...    skip_parameter_relation_errors=${True}
    ...    timeout=${timeout}
    ...    connection=${session}


reset_site
    [Documentation]     This keyword simulates the reset site
    [Arguments]     ${session}=${None}
    Should Be Equal As Strings  ${SESSION_OPENED}       True         ignore_case=True
    admin.reset_site      connection=${session}


wait_for_site_availability
    [Documentation]     This keyword simulates the wait_for_site_availability
    [Arguments]     ${url}
    ...             ${timeout}
    ...             ${interval}=1.0
    #fix robocop
    ${url}=    Set Variable    ${url}
    ${interval}=    Set Variable    ${interval}
    Should Be Equal As Strings  ${SESSION_OPENED}               False                   ignore_case=True
    sleep           ${timeout}


wait_for_site_unavailability
    [Documentation]     This keyword simulates the wait_for_site_unavailability
    [Arguments]     ${url}
    ...             ${timeout}
    ...             ${interval}=1.0
    #fix robocop
    ${url}=    Set Variable    ${url}
    ${interval}=    Set Variable    ${interval}
    Should Be Equal As Strings  ${SESSION_OPENED}               False                   ignore_case=True
    sleep           ${timeout}


get_current_scf_file
    [Documentation]     This keyword simulates the get_current_scf_file
    [Arguments]     ${local_dir_path}
    ...             ${file_name}
    ...             ${session}=${None}
    ...             ${timeout}=${None}
    Should Be Equal As Strings  ${SESSION_OPENED}               True                   ignore_case=True
    admin.get_current_scf_file    local_dir_path=${local_dir_path}
    ...                         file_name=${file_name}
    ...                         timeout=${timeout}
    ...                         connection=${session}


validate_scf
    [Documentation]     This keyword simulates the validate_scf
    [Arguments]     ${scf_path}
    ...             ${max_retry}=10
    ...             ${session}=${None}
    ...             ${timeout}=${None}
    #fix robocop
    ${max_retry}=    Set Variable    ${max_retry}
    Should Be Equal As Strings  ${SESSION_OPENED}               True                   ignore_case=True
    admin.validate_scf    scf_path=${scf_path}    timeout=${timeout}    connection=${session}


get_fsm
    [Documentation]     This keyword simulates the get_fsm
    [Arguments]     ${attribute}=None
    ...             ${fsm_id}=1
    ...             ${session}=${None}
    ...             ${timeout}=${None}
    #fix robocop
    ${fsm_id}=    Set Variable    ${fsm_id}
    Should Be Equal As Strings  ${SESSION_OPENED}               True                   ignore_case=True
    ${fsm}          admin.get_fsm_info       timeout=${timeout}            connection=${session}
    ${status}       Get From Dictionary    ${fsm[0]}    status
    ${state}        Get From Dictionary    ${status}    ${attribute}
    Return From Keyword If    ${attribute} == 'availabilityStatus' and 'availabilityStatus' not in ${status}    Online
    [return]        ${state}


verify_fsm_enabled_online
    [Arguments]     ${fsm_id}=1
    ...             ${session}=${None}
    ...             ${timeout}=${None}
    #fix robocop
    ${fsm_id}=    Set Variable    ${fsm_id}
    Should Be Equal As Strings  ${SESSION_OPENED}               True                   ignore_case=True
    log          Checking FSM Status:       console=${DEBUG_MODE_CONSOLE}
    ${output}=    admin.get_fsm_info    timeout=${timeout}     connection=${session}
    #log          FSM info: ${output}
    FOR    ${elem}    IN    @{output}
         Run keyword if  'availabilityStatus' not in ${elem['status']}    Set To Dictionary    ${elem['status']}    availabilityStatus    Online
         Should contain    ${elem['status']['operationalState']}      Enabled         ignore_case=True
         Should contain    ${elem['status']['availabilityStatus']}    Online          ignore_case=True
         Should contain    ${elem['status']['proceduralStatus']}      configured      ignore_case=True
    END
    log          - operationalState = Enabled
    log          - availabilityStatus = Online
    log          - proceduralStatus = configured


get_fbb
    [Documentation]     This keyword simulates the get_fbb
    [Arguments]     ${attribute}=${None}
    ...             ${fbb_id}=0
    ...             ${session}=${None}
    ...             ${timeout}=${None}
    Should Be Equal As Strings  ${SESSION_OPENED}               True                   ignore_case=True
    ${fbb}          admin.get_fbb_info       timeout=${timeout}            connection=${session}
    ${status}       Get From Dictionary    ${fbb[${fbb_id}]}    status
    Return From Keyword If    ${attribute} == 'availabilityStatus' and 'availabilityStatus' not in ${status}    Online
    ${state}        Get From Dictionary    ${status}    ${attribute}
    [return]        ${state}

# todo to test
verify_fbbs_enabled_online
    [Arguments]     ${session}=${None}
    ...             ${timeout}=${None}
    Should Be Equal As Strings  ${SESSION_OPENED}               True                   ignore_case=True
    # Check ABILs
    log          Checking FBBs Status:       console=${DEBUG_MODE_CONSOLE}
    ${output}=      admin.get_fbb_info    timeout=${timeout}     connection=${session}
    #log          FBBs info: ${output}
    FOR    ${elem}    IN    @{output}
         Run keyword if  'availabilityStatus' not in ${elem['status']}    Set To Dictionary    ${elem['status']}    availabilityStatus    Online
         Should contain    ${elem['status']['operationalState']}      Enabled          ignore_case=True
         Should contain    ${elem['status']['availabilityStatus']}    Online           ignore_case=True
         Should contain    ${elem['status']['proceduralStatus']}      configured       ignore_case=True
    END
    log          - operationalState = Enabled
    log          - availabilityStatus = Online
    log          - proceduralStatus = configured


get_frm
    [Documentation]     This keyword simulates the get_frm
    [Arguments]     ${attribute}=${None}
    ...             ${frm_id}=0
    ...             ${session}=${None}
    ...             ${timeout}=10
    Should Be Equal As Strings  ${SESSION_OPENED}               True                   ignore_case=True
    ${frm}          admin.get_frm         timeout=${timeout}       connection=${session}
    Log      ${frm}
    ${rmod}         Get From Dictionary    ${frm}                rmod
    ${status}       Get From Dictionary    ${rmod[${frm_id}]}    status
    Return From Keyword If    ${attribute} == 'availabilityStatus' and 'availabilityStatus' not in ${status}    Online
    ${state}        Get From Dictionary    ${status}    ${attribute}
    [return]        ${state}


get_frm_asib
    [Arguments]     ${attribute}=${None}
    ...             ${frm_id}=0
    ...             ${session}=${None}
    ...             ${timeout}=10
    #fix robocop
    ${frm_id}=    Set Variable    ${frm_id}
    Should Be Equal As Strings      ${SESSION_OPENED}         True          ignore_case=True
    ${frm}          admin.get_frm         timeout=${timeout}       connection=${session}
    Log      ${frm}
    ${status}       Get From Dictionary    ${frm[0]}      status
    Return From Keyword If    ${attribute} == 'availabilityStatus' and 'availabilityStatus' not in ${status}    Online
    ${state}        Get From Dictionary    ${status}    ${attribute}
    [return]        ${state}


Verify_rus_enabled_online
    [Arguments]     ${session}=${None}
    ...             ${timeout}=${None}
    Should Be Equal As Strings  ${SESSION_OPENED}               True                   ignore_case=True
    ${output}=      admin.get frm       timeout=${timeout}       connection=${session}
    Should Not Be Empty    ${output}

    FOR    ${elem}    IN    @{output}
         Run keyword if  'availabilityStatus' not in ${elem['status']}    Set To Dictionary    ${elem['status']}    availabilityStatus    Online
         Should contain    ${elem['status']['availabilityStatus']}      Online         ignore_case=True
         Should contain    ${elem['status']['operationalState']}      Enabled         ignore_case=True
    END
    [return]        ${output}

get_cell_specific_info
    [Documentation]     This keyword simulates the get_cell_specific_info
    [Arguments]     ${cell_number}=${None}
    ...             ${attribute}=${None}
    ...             ${session}=${None}
    ...             ${timeout}=${None}
    Should Be Equal As Strings  ${SESSION_OPENED}               True                   ignore_case=True

    ${info}         admin.get_cell_specific_info          cell_id=${cell_number}
    ...             timeout=${timeout}
    ...             connection=${session}

    Run keyword if  'availabilityStatus' not in ${info['status']}    Set To Dictionary    ${info['status']}    availabilityStatus    Online
    Log    ${info['status']}
    ${status}       Get From Dictionary    ${info}       status
    ${state}        Get From Dictionary    ${status}    ${attribute}
    [return]        ${state}


is_cell_in_state
    [Documentation]     This keyword simulates the is_cell_in_state
    [Arguments]     ${state}
    ...             ${number}=${None}
    ...             ${session}=${None}
    ...             ${timeout}=${None}
    #fix robocop
    ${number}=    Set Variable    ${number}
    ${session}=    Set Variable    ${session}
    ${timeout}=    Set Variable    ${timeout}
    Should Be Equal As Strings  ${SESSION_OPENED}               True                   ignore_case=True
    #To be completed: how to extract only the expected attribute of mzc.is_cell_in_state response
    [return]        ${state}


get_gps_status
    [Documentation]     This keyword simulates the get_gps_status
    [Arguments]     ${session}=${None}
    ...             ${timeout}=${None}
    Should Be Equal As Strings  ${SESSION_OPENED}               True                   ignore_case=True
    ${gps}          admin.get_gnsses_statuses     timeout=${timeout}       connection=${session}
    ${status}       Get From Dictionary    ${gps}       GNSSE_R-1
    Return From Keyword If    'availabilityStatus' not in ${status}    Online
    ${state}        Get From Dictionary    ${status}    availabilityStatus
    [return]        ${state}
