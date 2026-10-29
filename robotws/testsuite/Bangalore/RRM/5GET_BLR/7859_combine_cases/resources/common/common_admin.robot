*** Settings ***
Documentation    Suite documentation

*** Keywords ***
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

Full Commission SCF File With Admin
    [Arguments]    ${scf_file}
    COAM.Setup Admin
    COAM.Perform Commissioning
    ...    bts_id=1
    ...    scf_file=${scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    Run Keyword And Ignore Error    COAM.Teardown

Delta Commission Json File With Admin
    [Arguments]    ${delta_json}
    [Documentation]    This keyword is to update parameters with delta file
    Log To Console    Perform delta commissioning...
    COAM.Setup Admin
    COAM.Perform Delta Recommissioning
    ...    delta_file=${delta_json}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Modify Vendor File And Do Full Commission
    [Arguments]    ${scf_file}=${EMPTY}    ${vendor_path}=${EMPTY}    ${old_params}=${EMPTY}    ${new_params}=${EMPTY}
    [Documentation]    This keyword is to update parameters with delta file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file | No | SCF file name.It usual exist in ${scf_path}/${sw_branch}/SCF/${scf_file}. |
    ...    |    |    | ${sw_branch} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...    | vendor_path | No | the path used to save vendor file |
    ...    | old_params | No | a list to store the old values need to update, used in Modify Text File to modify vendor file    |
    ...    | new_params | No | a list to store the new values will be updated to, used in Modify Text File to modify vendor file    |
    ...
    ...    Examples:
    ...    | ${vendor_path} | Set Variable | ${test_log_directory}/vendor.xml |
    ...    | @{vendor_old_params} | Create List | <p name="dddsPeriod">[0-9]+</p> |
    ...    | @{vendor_new_params} | Create List | <p name="dddsPeriod">10</p> |
    ...    | Modify Vendor File And Do Full Commission | vendor_path=${vendor_path} |
    ...    | ... |  old_params=@{vendor_old_params} || new_params=@{vendor_new_params} |
    ...    Example2:
    ...    | ${scf_file} | Set Variable | ${CURDIR}/scf.xml |
    ...    | Modify Vendor File And Do Full Commission | ${scf_file} |
    ...
    Log To Console    Perform full commissioning,please use the scf with full configuration saved.
    ${bts_id}    Get BTS Id
    COAM.Setup Admin    username=developer    password=$developer#
    ${scf_file}    Set Variable If    '${scf_file}'=='${EMPTY}'    ${output_dir}/full_SCF.xml    ${scf_file}
    Run Keyword If    '${scf_file}'=='${output_dir}/full_SCF.xml'    COAM.Collect Scf    ${scf_file}
    ...    configurationAndRuntimeObjects
    ${join_scf_path}=    OperatingSystem.Join Path    ${scf_path}    ${sw_branch}    SCF    ${scf_file}
    ${is_join_path_file_exist}=    Run Keyword And Return Status    File Should Exist    ${join_scf_path}
    ${scf_path}    Set Variable If    '${is_join_path_file_exist}'==True    ${join_scf_path}    ${scf_file}
    Modify File Parameter    ${scf_path}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${nrbts_distname}
    Modify VlanId In SCF File    ${scf_path}
    ${new_scf_path}    Migration SCF To New Release    ${scf_path}
    Run Keyword If    '${vendor_path}'!='${EMPTY}'    COAM.Download Vendor File    ${vendor_path}
    Sleep    1s
    Run Keyword If    '${vendor_path}'!='${EMPTY}'    Modify Text File    ${vendor_path}    ${old_params}    ${new_params}
    Run Keyword If    '${vendor_path}'!='${EMPTY}'    COAM.Set Vendor File    ${vendor_path}
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${new_scf_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    Run Keyword And Ignore Error    Verify Coam Site Is Ready
    Reboot TL And Check Configured
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Get GNB Status From COAM
    [Arguments]    ${status_type}=proceduralState
    [Documentation]    This keyword is to get BTS status from COAM. Return the status with the given type.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${status_type} | No | operationalState/blockingState/proceduralState, the default value is proceduralState |
    ...
    ...    Examples:
    ...    | Get GNB Status From COAM |  |  |
    ...    | Get GNB Status From COAM | blockingState |  |

    [Teardown]    coam.Teardown    ${coam_connection}
    ${coam_connection}    coam.Connect To
    ${bts_status}    coam.Get Bts Statuses    connection=${coam_connection}
    [Return]    &{bts_status}[${status_type}]

Get Cell Status From COAM
    [Arguments]    ${status_type}=proceduralStatus
    [Documentation]    This keyword is to get cell status from COAM.
    ...    status_type = administrativeState/availabilityStatus/blockingState/operationalState/proceduralStatus/usageState
    [Teardown]    coam.Teardown    ${coam_connection}
    ${coam_connection}    coam.Connect To
    ${cell_status_coam}    coam.Get Cells Info    cell_type=nr    timeout=30    connection=${coam_connection}
    ${cell_status}    Evaluate    ${cell_status_coam}[0].get('status').get('${status_type}')
    [Return]    ${cell_status}

Wait For GNB Configured State
    [Documentation]    This keyword is to wait for the status of GNB and cell to configured.
    ...              The max time is 15min
    Wait Until Keyword Succeeds    15min    30sec    Ensure GNB State Is Configured
    Wait Until Keyword Succeeds    10min    30sec    Ensure Cell State Is Configured

Ensure Cell State Is Configured
    [Documentation]    This keyword is to check the state of cell is configured
    ${cell_state}    Get Cell Status From COAM
    Should Be Equal As Strings    ${cell_state}    configured    ignore_case=${true}

Ensure GNB State Is Configured
    [Documentation]    This keyword is to check the state of gNB is configured
    ${bts_state}    Get GNB Status From COAM
    Should Be Equal As Strings    ${bts_state}    Configured    ignore_case=${true}

Verify Coam Site Is Ready
    [Documentation]    This keyword is to check the state of gNB is configured and Radio is online.
    Log To Console    verify bts site is ready...
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify BTS Is Configured
    sleep    200s
    #Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify Radio Is Online

Verify BTS Is Configured
    [Documentation]    This keyword is to check the state of gNB is Configured or IntegratedToRan
    Log To Console    verify BTS is configured...
    Run Keyword And Ignore Error    COAM.Setup Admin
    ${bts_state}    COAM.Get Mrbts State
    Log To Console    [INFO] BTS STATE : ${bts_state}
    Should Contain Any    ${bts_state}    Configured    IntegratedToRan    OnAir    ignore_case=True
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Verify BTS Is OnAir
    [Documentation]    This keyword is to check the state of gNB is onAir
    Log To Console    verify BTS is onAir...
    Run Keyword And Ignore Error    COAM.Setup Admin
    ${bts_state}    COAM.Get Mrbts State
    Log To Console    [INFO] BTS STATE : ${bts_state}
    Should Contain Any    ${bts_state}    OnAir    ignore_case=True
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Verify BTS Is OnAir_A2_005
    [Documentation]    This keyword is to check the state of gNB is onAir
    Log To Console    verify BTS is onAir...
    Run Keyword And Ignore Error    COAM.Setup Admin
    ${bts_state}    COAM.Get Mrbts State
    Log To Console    [INFO] BTS STATE : ${bts_state}
    Should Contain Any    ${bts_state}    Configured    ignore_case=True
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Verify Radio Is Online
    [Documentation]    This keyword is to check the state of Radios are online
    #[Arguments]    ${ru_nums}=${RRU_NUMS}
    ${ru_nums}=    Evaluate    len(${RRU_TYPE_LIST})
    Log To Console    verify Radio is online...
    Run Keyword And Ignore Error    COAM.Setup Admin
    ${bts_hw_info}    COAM.Get Bts Info
    FOR    ${id}    IN RANGE    0    ${ru_nums}
        ${radio_state}    Set Variable
        ...    ${bts_hw_info['radioModules']['rmod'][ ${id}]['status']['availabilityStatus']}
        ${ru_id}=    Evaluate    ${id}+1
        Log To Console    [INFO]    RADIO${ru_id}    STATE : ${radio_state}
        Should Be Equal As Strings    ${radio_state}    Online    ignore_case=True
	END
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown Admin

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
    Log To Console    Backup Scf...
    Run Keyword And Ignore Error    coam.Setup Admin
    coam.Get Current Scf File    local_dir_path=${log_dir}    file_name=SCF_${scf_backup_name}.xml  timeout=120
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown Admin

Get All Counter Values List With Admin
    [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the couter value list from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get All Counter Values List With Admin | M55323C14001 |
    ...
    COAM.Setup Admin
    ${counter}    COAM.Get Pm Counters    ${counter_id}
    ${counter_str}    Convert To String    ${counter}
    ${counter_value_list}    String.Get Regexp Matches    ${counter_str}    '\\d+':\\s*(?P<${counter_id}>\\d+)    ${counter_id}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${counter_value_list}

Get Latest PM Counter Value With Admin
    [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the lastest value of couter from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get Latest PM Counter Value With Admin | M55323C14001 |
    ...
    COAM.Setup Admin
    ${counter}    COAM.Get Pm Counters    ${counter_id}
    ${counter_str}    Convert To String    ${counter}
    ${counter_list}    String.Get Regexp Matches    ${counter_str}
    ...    (?P<counter_time>\\d+)':\\s(?P<counter_num>\\d+)    counter_time    counter_num
    ${latest}    Evaluate    max(${counter_list})
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${latest[-1]}

Get Max PM Counter Value With Admin
    [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the max value of couter from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get Latest PM Counter Value From Coam | M55323C14001 |
    ...
    ${counter_value_list}    Get All Counter Values List With Admin    ${counter_id}
    ${max_counter_value}    Evaluate    max(${counter_value_list})
    [Return]    ${max_counter_value}

Get Min PM Counter Value With Admin
    [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the min value of couter from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get Latest PM Counter Value From Coam | M55323C14001 |
    ...
    ${counter_value_list}    Get All Counter Values List With Admin    ${counter_id}
    ${min_counter_value}    Evaluate    min(${counter_value_list})
    [Return]    ${min_counter_value}

Show Relation Errors If Exist
    Backup Scf    ${OUTPUT_DIR}    running
    COAM.Setup Admin
    ${res}    Run Keyword And Ignore Error    COAM.Validate Scf    ${OUTPUT_DIR}/SCF_running.xml
    ${res}    Convert To String    ${res}
    ${status}    String.Get Regexp Matches    ${res}    \\('(?P<status>\\w+)'    status
    OperatingSystem.Create File    ${OUTPUT_DIR}/relation_errors.log    ${res}
    Run Keyword If    '${status}[0]'=='FAIL'    Log    ---------You Got Parameter Relation Errors    level=WARN
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
