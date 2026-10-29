*** Settings ***

*** Variables ***


*** Keywords ***
Backup Scf
    [Arguments]    ${log_dir}    ${scf_backup_name}
    [Documentation]    This keyword is to back up SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the scf file |
    ...    | ${scf_backup_name} | Yes | the saved SCF file name. it like SCF_${scf_backup_name}.xml |
    ...
    ...    Examples:
    ...    | Backup Scf | ${SUITE_LOG_DIRECTORY} | before_suite |
    ...    | Backup Scf | ${TEST_LOG_DIRECTORY} | after_suite |
    Log To Console    Backup Scf with name ${scf_backup_name}...
    coam.Setup Admin
    coam.Get Current Scf File    local_dir_path=${log_dir}    file_name=SCF_${scf_backup_name}.xml
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown Admin

Get Software Version
    ${coam_connection}    coam.connect_to    bts_host=${sbts_addr}    bts_port=${443}
    ...    username=${http_username}    password=${http_password}
    ${software_info_1}=    coam.Get Sw Version    connection=${coam_connection}
    Set Suite Variable    ${SOFTWARE_INFO}    ${software_info_1}
    Log    Software Version: ${SOFTWARE_INFO}    console=${True}    #5G21B_GNB_0000_000800_004084_0oeo9    5G21A_GNB_0011_000800_000601
    @{words}=    String.Split String    ${SOFTWARE_INFO}    _
    ${ENB_BUILD}=    Set Variable    ${words[0][0:4]}
    ${IS_SOFTWARE_KNIFE}=    Set Variable If    "${words[-1][0:3]}"=="000"    ${False}    ${True}
    #${ENB_BUILD}=    String.Get Substring    ${SOFTWARE_INFO}    0    4
    Set Suite Variable    ${ENB_BUILD}
    Set Suite Variable    ${IS_SOFTWARE_KNIFE}
    Get Software Version Total
    [Teardown]    coam.Teardown    ${coam_connection}

Get Software Version Total
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | SBTS00 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | SBTS21B_ENB_9999_210324_000019 | total sw version |
    ...    | ${SW_BRANCH} | SBTS21B | the folder to stort config files for case |
    ...
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999 or ${sw_list[2]}==9990
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION}    SBTS00
    ...    ELSE    Set Suite Variable    ${SW_VERSION}    ${sw_list[0]}
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION_TOTAL}
    ...    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ...    ELSE    Set Suite Variable    ${SW_VERSION_TOTAL}    ${SOFTWARE_INFO}
    Set Suite Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}    console=${True}


Get BTS Type And Status
    Run Keyword And Ignore Error    COAM.Setup Admin
    ${bts_hw_info}    COAM.Get Bts Info
    #BBU type
    ${BBU_TYPE}    Set Variable    ${bts_hw_info['systemModules'][0]['productName']}
    Log To Console    [INFO] BBU type: ${BBU_TYPE}
    ${bts_state}    COAM.Get Mrbts State
    Log To Console    [INFO] BTS STATE Before Test: ${bts_state}
    ${ru_nums}=    Get Length    ${bts_hw_info['radioModules']['rmod']}
    Log    RRU number: ${ru_nums}    console=True
    FOR    ${id}    IN RANGE    0    ${ru_nums}
        ${radio_state}    Set Variable
        ...    ${bts_hw_info['radioModules']['rmod'][${id}]['status']['operationalState']}
        ${radio_type}    Set Variable
        ...    ${bts_hw_info['radioModules']['rmod'][ ${id}]['productName']}
        ${ru_id}=    Evaluate    ${id}+1
        Log To Console    [INFO] RADIO${ru_id} TYPE: ${radio_type} STATE: ${radio_state}
    END
    ${cell_nums}=    Get Length    ${bts_hw_info['cells']['nr']}
    FOR    ${id}    IN RANGE    0    ${cell_nums}
        ${cell_status}    Set Variable    ${bts_hw_info['cells']['nr'][${id}]['status']['operationalState']}
        ${global_cell_id}    Set Variable    ${bts_hw_info['cells']['nr'][${id}]['globalCellId']}
        ${technology}    Set Variable    ${bts_hw_info['cells']['nr'][${id}]['technology']}
        Log To Console    [INFO] ${technology} Cell${global_cell_id} STATE: ${cell_status}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Full Commission With SCF File
    [Arguments]    ${scf_file}
    COAM.Setup Admin
    &{result}    COAM.Perform Commissioning
    # ...        bts_id=${bts_id}
    ...          scf_file=${scf_file}
    ...          skip_parameter_relation_errors=True
    ...          should_activate=True
    ...          timeout=300
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    BuiltIn.Log    Commission with scf file via rest API successfully.
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Online Change One Para With Admin
    [Arguments]   ${dist_name}    ${parameter}    ${value}
    [Documentation]    this keyword is used to modify one SCF parameter on testline,
    ...    paramter under list is not supported.
    ...    Examples:
    ...    | Online SCF Commission One Para | MRBTS-1/NRBTS-1 |  actLteNrDss  |  false  |
    COAM.Setup Admin
    COAM.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}    parameter=${parameter}    operation=update    value=${value}    skip_parameter_relation_errors=True
    [Teardown]    COAM.Teardown

Online delete One Para With Admin
    [Arguments]   ${dist_name}    ${parameter}    ${value}
    [Documentation]    this keyword is used to delete one SCF parameter on testline,
    ...    paramter under list is not supported.
    ...    Examples:
    ...    | Online SCF Commission One Para | MRBTS-1/NRBTS-1 |  actLteNrDss  |  false  |
    COAM.Setup Admin
    COAM.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}    parameter=${parameter}    operation=delete    value=${value}    skip_parameter_relation_errors=True
    [Teardown]    COAM.Teardown


Verify all cells should be onair
    [Documentation]
    ...                Description: verify all the cells status should be correct.
    [Arguments]    ${cell_type}=nr
    COAM.Setup Admin
    Log to console    Verify all cells are on air
    ${sw_version}     coam.get_sw_version
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${unlocked}    Set Variable If    ${result}==${False} and '${cell_type}'=='lte'    unlocked    ${unlocked}
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20
    FOR    ${cell}    IN    @{cells_info}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}     ${unlocked}
        Run keyword and continue on failure    Should be equal as strings    ${cell['status']['operationalState']}    ${enabled}
        run keyword if  ${result}    Run keyword and continue on failure
        ...    Should Be Equal As Strings    ${cell['status']['availabilityStatus']}   Online
    END
    [Teardown]    COAM.Teardown

Check If Alarm Appeared
    [Documentation]    This keyword is used to check if alarm appeared
    [Arguments]    ${fault_id}
    COAM.Setup Admin    timeout=120
    @{alarms}=    COAM.Get Active Alarms    #both $ and @ are OK
    @{active_fault_list}=    Create List
    FOR    ${alarm}    IN    @{alarms}    # get list right, must @
         ${fault}=    Get From Dictionary    ${alarm}    faultId
         Append To List    ${active_fault_list}    ${fault}    #${fault} is a number,not a string
    END
    ${fault_id}=    Convert To Integer    ${fault_id}    #${fault_id} is a string,it must be changed to number
    List Should Contain Value    ${active_fault_list}    ${fault_id}
    [Teardown]    COAM.Teardown

Check If Alarm Disappeared
    [Documentation]    This keyword is used to check if alarm disappeared
    [Arguments]    ${fault_id}
    COAM.Setup Admin    timeout=120
    @{alarms}=    COAM.Get Active Alarms    #both $ and @ are OK
    @{active_fault_list}=    Create List
    FOR    ${alarm}    IN    @{alarms}    # get list right, must @
         ${fault}=    Get From Dictionary    ${alarm}    faultId
         Append To List    ${active_fault_list}    ${fault}    #${fault} is a number,not a string
    END
    ${fault_id}=    Convert To Integer    ${fault_id}    #${fault_id} is a string,it must be changed to number
    List Should Not Contain Value    ${active_fault_list}    ${fault_id}
    [Teardown]    COAM.Teardown Admin

Display All Active Alarms
    COAM.Setup Admin    timeout=120
    @{alarms}=    COAM.Get Active Alarms    #both $ and @ are OK
    @{active_fault_list}=    Create List
    FOR    ${alarm}    IN    @{alarms}    # get list right, must @
        ${fault}=    Get From Dictionary    ${alarm}    faultId
        ${fault_name}=    Get From Dictionary    ${alarm}    alarmName
        Append To List    ${active_fault_list}    ${fault}:${fault_name}    #${fault} is a number,not a string
    END
    Log To Console    ${active_fault_list}
    [Teardown]    COAM.Teardown