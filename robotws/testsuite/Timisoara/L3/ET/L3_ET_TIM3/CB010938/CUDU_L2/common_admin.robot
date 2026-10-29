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
    [Arguments]    ${delta_json}    ${timeout}=300
    [Documentation]    This keyword is to update parameters with delta file
    Log To Console    Perform delta commissioning...
    COAM.Setup Admin
    COAM.Perform Delta Recommissioning
    ...    delta_file=${delta_json}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Modify Vendor File And Do Full Commission
    [Arguments]    ${vendor_change_list}    ${scf_file}=${EMPTY}
    [Documentation]    This keyword is to update parameters with delta file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file | No | SCF file name.It usual exist in ${scf_path}/${sw_branch}/SCF/${scf_file}. |
    ...    |    |    | ${sw_branch} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...    | vendor_change_list | Yes | the element is dictionary, and it should be include the key list_name, ref_value, params_dict |
    ...    ...
    ...    Examples:
    ...    | &{xml_params_dict1} | Create Dictionary | maxNumLayerPrbDlL1Sp=200 | maxNumLayerPrbUlL1Sp=100 |
    ...    | ...| maxNumStreamPrbDlL1Sp=300 | maxNumStreamPrbUlL1Sp=200 |
    ...    | &{vendor_change_dict1} | Create Dictionary | list_name=bbL1SpPrbCapacity |
    ...    | ... |    | ref_value=ABIO\\d+FDD48 | params_dict=${xml_params_dict1} |
    ...    | &{xml_params_dict2} | Create Dictionary | guaranteedResourceRatioPerCell=10 |
    ...    | &{vendor_change_dict2} | Create Dictionary | list_name=${EMPTY} |
    ...    |  ref_value=${EMPTY}  |  params_dict=${xml_params_dict2} | ${vendor_change_dict2} |
    ...    | @{vendor_change_list} | Create List | ${vendor_change_dict1} | ${vendor_change_dict2} |
    ...    | Modify Vendor File And Do Full Commission | vendor_change_list=${vendor_change_list} |
    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
    ...    | ${scf_file} | Set Variable | ${CURDIR}/scf.xml |
    ...    | Modify Vendor File And Do Full Commission | vendor_change_list=${vendor_change_list} | scf_file=${scf_file} |
    ...
    Log To Console    Perform full commissioning, please use the scf with full configuration saved.
    ${bts_id}    Get BTS Id
    COAM.Setup Admin
    ${new_scf_path}    Run Keyword If    '${scf_file}'!='${EMPTY}'
    ...    _Set SCF Full File and Migration    ${scf_file}
    ${full_scf_file}    Set Variable If    '${scf_file}'=='${EMPTY}'    ${output_dir}/full_SCF.xml    ${new_scf_path}
    Run Keyword If    '${full_scf_file}'=='${output_dir}/full_SCF.xml'    COAM.get_current_scf_file
    ...    local_dir_path=${OUTPUT_DIR}    file_name=full_SCF.xml
    ...    export_type=configurationAndRuntimeObjects    timeout=120s
    ${vendor_path}    Set Variable    ${OUTPUT_DIR}/vendor_ini.xml
    COAM.Download Vendor File    ${vendor_path}
    Sleep    1s
    Modify Vendor XML File    ${vendor_path}    ${vendor_change_list}
    COAM.Set Vendor File    ${vendor_path}
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${full_scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    # Run Keyword And Ignore Error    Verify Coam Site Is Ready
    # Reboot TL And Check Configured
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

_Set SCF Full File and Migration
    [Arguments]    ${scf_file}
    ${scf_pull_path}=    Check Config File Absolute Path Or Relative Path    ${scf_file}
    Modify File Parameter    ${scf_pull_path}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${nrbts_distname}
    Modify VlanId In SCF File    ${scf_pull_path}
    # ${new_scf_path}    Migration SCF To New Release    ${scf_pull_path}
    [Return]    ${scf_pull_path}

Download Vendor File
    [Arguments]    ${log_dir}    ${vendor_file}
    COAM.Setup Admin
    ${vendor_path}    Set Variable    ${log_dir}/${vendor_file}
    COAM.Download Vendor File    ${vendor_path}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${vendor_path}

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

Get All Cell Status From COAM
    [Arguments]    ${status_type}=proceduralStatus
    [Documentation]    This keyword is to get cell status from COAM.
    ...    status_type = administrativeState/availabilityStatus/blockingState/operationalState/proceduralStatus/usageState
    [Teardown]    coam.Teardown    ${coam_connection}
    ${coam_connection}    coam.Connect To
    ${all_cell_info}    coam.Get Cells Info    cell_type=nr    timeout=30    connection=${coam_connection}
    ${all_cell_status}    Create List
    FOR    ${cell_info}    IN    @{all_cell_info}
        ${cell_status}    Evaluate    ${cell_info}.get('status').get('${status_type}')
        Append To List    ${all_cell_status}    ${cell_status}
    END
    [Return]    ${all_cell_status}

Verify All Cells Are OnAir
    ${ret}=    Get All Cell Status From COAM
    FOR    ${cell_info}    IN    @{ret}
        Should Be True    "${cell_info}"=="configured"
    END

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
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify Radio Is Online
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify All Cells Are Configured

Verify All Cells Are Configured
    ${all_cell_status}    Get All Cell Status From COAM
    List Should Not Contain Value    ${all_cell_status}    initializing    WRN:cell is not configured.Check SCF para!

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

Verify Radio Is Online
    [Documentation]    This keyword is to check the state of Radios are online
    #[Arguments]    ${ru_nums}=${RRU_NUMS}
    #${ru_nums}=    Evaluate    len(${RRU_TYPE_LIST})
    Log To Console    verify Radio is online...
    Run Keyword And Ignore Error    COAM.Setup Admin
    ${bts_hw_info}    COAM.Get Bts Info
    ${ru_nums}=    Get Length    ${bts_hw_info['radioModules']['rmod']}
    Log    RRU number: ${ru_nums}    console=True
    FOR    ${id}    IN RANGE    0    ${ru_nums}
        ${radio_state}    Set Variable
        ...    ${bts_hw_info['radioModules']['rmod'][ ${id}]['status']['operationalState']}
        ${ru_id}=    Evaluate    ${id}+1
        Log To Console    [INFO]    RADIO${ru_id}    STATE : ${radio_state}
        Should Be Equal As Strings    ${radio_state}    enabled    ignore_case=True
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
    Log To Console    Backup Scf with name ${scf_backup_name}...
    coam.Setup Admin
    coam.Get Current Scf File    local_dir_path=${log_dir}    file_name=SCF_${scf_backup_name}.xml
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown Admin

Get Current Full SCF From Admin
    [Documentation]    This keyword is to get current full scf file.
    COAM.Setup Admin
    ${scf_file}    COAM.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=scf_current_full.xml
    ...    export_type=configurationAndRuntimeObjects    timeout=120s
    [Teardown]    COAM.Teardown Admin
    [Return]    ${scf_file}

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

Get Cell PM Counters Latest Values With Admin
    [Arguments]    ${cell_id}    ${MO_name}    ${counter_ids_list}    ${bts_id}=1
    [Documentation]    This keyword is to get the latest counter value for multi cell pm counter.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cell_id} | YES | cell_id, such as 1,2,3... |
    ...    | ${MO_name} | Yes | the mo name for the pm counters, such as NLRLC, LTEMG, NRPMQAP-1/HRLCQ  |
    ...    | ${counter_ids_list} | yes | a list for pm counter id in same MO |
    ...
    ...    | Return | a dict with counter_id and the latest value |
    ...
    ...    Examples:
    ...    | ${cell_id} |  | 2 |
    ...    | ${MO_name} |  | LTEMG |
    ...    | @{test_counter_list} |  | M55136C00001 | M55136C00002 | M55136C00003 | M55136C00004 | M55136C00005 |
    ...    | ${counter_value_dict} | Get Cell PM Counters Latest Values With Admin | ${cell_id} |
    ...    | ... |  | ${MO_name} | ${counter_ids_list} |
    ...    | ${MO_name_2} |  | NRPMQAP-1/HRLCQ |
    ...    | @{test_counter_list_2} |  | M55353C00001 |
    ...    | ${counter_value_dict} | Get Cell PM Counters Latest Values With Admin | ${cell_id} |
    ...    | ... |  | ${MO_name_2} | ${test_counter_list_2} |
    ...
    ${counter_ids}    Evaluate    ','.join(${counter_ids_list})
    COAM.Setup Admin
    ${counter_dict}    COAM.Get Pm Counters    ${counter_ids}    timeout=2min
    ${counter_id_value_dict}    _Get Counter From Counter Dictionary    ${counter_dict}    ${cell_id}
    ...    ${MO_name}    ${counter_ids_list}   ${bts_id}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${counter_id_value_dict}

_Get Counter From Counter Dictionary
    [Arguments]    ${counter_dict}    ${cell_id}    ${MO_name}    ${counter_ids_list}    ${bts_id}=1
    ${counter_id_value_dict}    Create Dictionary
    ${mo_list}    Split String    ${MO_name}    /
    ${status}    ${value}    Run Keyword And Ignore Error    Evaluate    &{counter_dict}[BTS]['CELLS']['NRCELL-${cell_id}']
    ${counter_dict}    Run Keyword If    '${status}'=='PASS'
    ...    Evaluate    &{counter_dict}[BTS]['CELLS']['NRCELL-${cell_id}']
    ...    ELSE IF    '${status}'=='FAIL'    Evaluate    &{counter_dict}[BTS]['MRBTS-1']['NRBTS-${bts_id}']['NRCELL-${cell_id}']
    ${type}    Evaluate    type(${counter_dict})
    FOR    ${node}    IN    @{mo_list}
        ${counter_dict}    Get From Dictionary    ${counter_dict}    ${node}
    END
    FOR    ${counter_id}    IN    @{counter_ids_list}
        ${counter_value_dict}    Get From Dictionary    ${counter_dict}    ${counter_id}
        ${counter_value_list}    Get Dictionary Values    ${counter_value_dict}
        Set To Dictionary    ${counter_id_value_dict}    ${counter_id}    ${counter_value_list[-1]}
    END
    [Return]    ${counter_id_value_dict}


Get Multi Cells Multi PM Counters Latest Values With Admin
    [Arguments]    ${counter_info_list}    ${bts_id}=1
    [Documentation]    This keyword is to get the latest counter value for multi cell multi pm counter.
    ...                 Setup admin multiple times in this keywords.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_info_list} | YES | a list for counter info, the element should be include cell_id, MO_name and counter_ids_list |
    ...
    ...    | Return | a dict with counter_id and the latest value |
    ...
    ...    Examples:
    ...    | @{test_counter_list} |  | M55136C00001 | M55136C00002 | M55136C00003 | M55136C00004 | M55136C00005 |
    ...    | &{counter_info_1} |  | cell_id=1 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_2} |  | cell_id=2 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_3} |  | cell_id=3 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | @{counter_info_list} |  | ${counter_info_1} | ${counter_info_2} | ${counter_info_3} |
    ...    | ${counter_value_dict} | Get Multi Cells Multi PM Counters Latest Values With Admin | ${counter_info_list} |
    ...    | Should be True | ${counter_value_dict.Cell1.M55136C00001}>1
    ${counter_value_dict}    Create Dictionary
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${counter_id_value_dict}    Get Cell PM Counters Latest Values With Admin    ${counter_info.cell_id}
        ...    ${counter_info.MO_name}    ${counter_info.counter_ids_list}    ${bts_id}
        Set To Dictionary    ${counter_value_dict}    cell${counter_info.cell_id}    ${counter_id_value_dict}
    END
    [Return]    ${counter_value_dict}

Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    [Arguments]    ${counter_info_list}    ${bts_id}=1
    [Documentation]    This keyword is to get the latest counter value for multi cell multi same pm counters.
    ...                    Setup admin once in this keyword.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_info_list} | YES | a list for counter info, the element should be include cell_id, MO_name and counter_ids_list |
    ...
    ...    | Return | a dict with counter_id and the latest value |
    ...
    ...    Examples:
    ...    | @{test_counter_list} |  | M55136C00001 | M55136C00002 | M55136C00003 | M55136C00004 | M55136C00005 |
    ...    | &{counter_info_1} |  | cell_id=1 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_2} |  | cell_id=2 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_3} |  | cell_id=3 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | @{counter_info_list} |  | ${counter_info_1} | ${counter_info_2} | ${counter_info_3} |
    ...    | ${counter_value_dict} | Get Multi Cells Same Mo Multi PM Counters Latest Values With Admin | ${counter_info_list} |
    ...    | Should be True | ${counter_value_dict.Cell1.M55136C00001}>1
    Sleep    20s
    ${counter_value_dict}    Create Dictionary
    ${counter_ids}    Evaluate    ','.join(${counter_info_list[0].counter_ids_list})
    ${counter_id_value_dict}    Create Dictionary
    COAM.Setup Admin
    ${counter_dict}    COAM.Get Pm Counters    ${counter_ids}    timeout=5min
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${counter_id_value_dict}    _Get Counter From Counter Dictionary    ${counter_dict}    ${counter_info.cell_id}
        ...    ${counter_info.MO_name}    ${counter_info.counter_ids_list}    ${bts_id}
        Set To Dictionary    ${counter_value_dict}    cell${counter_info.cell_id}    ${counter_id_value_dict}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${counter_value_dict}

Show Relation Errors If Exist
    Backup Scf    ${OUTPUT_DIR}    running
    COAM.Setup Admin
    ${res}    Run Keyword And Ignore Error    COAM.Validate Scf    ${OUTPUT_DIR}/SCF_running.xml
    ${res}    Convert To String    ${res}
    ${status}    String.Get Regexp Matches    ${res}    \\('(?P<status>\\w+)'    status
    OperatingSystem.Create File    ${OUTPUT_DIR}/relation_errors.log    ${res}
    Run Keyword If    '${status}[0]'=='FAIL'    Log    ---------You Got Parameter Relation Errors    level=WARN
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Get Alarms
    [Documentation]    not issue alarm:
    ...    61652: R&D Service Port enabled
    ...    4654: Ethernet port security is disabled
    ...    4655: Service account root access is enabled
    ...    61524: SSH enabled
    ...    7523: Cell Activation timeout at gNB-DU
    ...    61649: LMP access via port 443
    ...    7103: SA cell activation failed
    ...    7100: F1 Cell activation failed due to X2 link unavailable
    ...    7305: NG SCTP setup fail
    ...    4298: ToP reference missing
    ...    7300: No X2 link available
    ...    7101: gNB CpCell configuration update failure
    ${alarm_white_list}=    Create List    61652    61524    4654    4655    61649    4298
    ${alarm_message_list}=    Create List
    ${fault_id_list}=    Create List
    COAM.Setup Admin
    ${alarm}=    COAM.Get Alarms
    FOR    ${item}    IN    @{alarm}
        ${alarmId}=    Set Variable    &{item}[alarmId]
        ${faultId}=    Set Variable    &{item}[faultId]
        ${faultSeverity}=    Set Variable    &{item}[faultSeverity]
        ${alarm_info}=    Set Variable    &{item}[alarmInformation]
        ${faultDescription}=    Set Variable    &{alarm_info}[faultDescription]
        #${alarm_white_list}=    Evaluate    map(int,${alarm_white_list})
        ${ret}=    Evaluate    ${faultId} in ${alarm_white_list}
        Run Keyword If    "${ret}"=="${False}"    append to list    ${alarm_message_list}
        ...    ${faultId}: ${faultDescription}:${faultSeverity}
        Run Keyword If    "${ret}"=="${False}"    append to list    ${fault_id_list}
        ...    ${faultId}
    END
    ${alarm_message}=    Catenate    SEPARATOR=${\n}    @{alarm_message_list}
    Log    ${alarm_message}    WARN
    Set Suite Variable    ${ALARM_MESSAGE}    ${alarm_message}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${fault_id_list}

Block Cell With Admin
    [Arguments]    ${cell_name}
    [Documentation]    This keyword is to block cell by admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cell_name} | Yes | Cell dist name. such as MRBTS-1/NRBTS-1/NRCELL-5 |
    ...
    ...    Examples:
    ...    | Block Cell With Admin | MRBTS-1/NRBTS-1/NRCELL-5 |
    ...
    Log To Console    Cell ${cell_name} Locked
    COAM.Setup Admin
    COAM.Block Cell    dist_name=${cell_name}
    Sleep    30s    reason=wait for gnb ok
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Unblock Cell With Admin
    [Arguments]    ${cell_name}
    [Documentation]    This keyword is to unblock cell by admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cell_name} | Yes | Cell dist name. such as MRBTS-1/NRBTS-1/NRCELL-5 |
    ...
    ...    Examples:
    ...    | unBlock Cell With Admin | MRBTS-1/NRBTS-1/NRCELL-5 |
    ...
    Log To Console    Cell ${cell_name} Unlocked
    COAM.Setup Admin
    COAM.UnBlock Cell    dist_name=${cell_name}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Get PM Counter Latest Value From Admin
    [Arguments]    ${counter_id}    ${counter_path}    ${bts_id}=1
    [Documentation]    This keyword is to get counter value with counter id and counter path from admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | YES | such as M55118C01000 |
    ...    | ${counter_path} | YES | such as CELLS/NRCELL-1/NCAC, can get from admin without the counter name |
    ...
    ...    Examples:
    ...    | ${value} | Get Latest PM Counter Value With Counter Path From Admin | M55118C01000 | CELLS/NRCELL-1/NCAC |
    ...
    @{path_list}    Split String    ${counter_path}    /
    Append To List    ${path_list}    ${counter_id}
    ${path_format}    Evaluate    ''.join(["['"+x+"']" for x in ${path_list}])
    ${status_cell}    ${value}    Run Keyword And Ignore Error    Should Contain    ${path_format}    NRCELL
    ${path_format_2}    Remove String    ${path_format}    ['CELLS']
    COAM.Setup Admin
    ${counter_dict}    COAM.Get Pm Counters    ${counter_id}
    ${status}    ${value}    Run Keyword And Ignore Error    Evaluate    &{counter_dict}[BTS]${path_format}
    ${counter_value_dict}    Run Keyword If    '${status_cell}'=='PASS' and '${status}'=='PASS'
    ...    Evaluate    &{counter_dict}[BTS]${path_format}
    ...    ELSE IF    '${status_cell}'=='PASS' and '${status}'=='FAIL'
    ...    Evaluate    &{counter_dict}[BTS]['MRBTS-1']['NRBTS-${bts_id}']${path_format_2}
    ...    ELSE IF    '${status_cell}'=='FAIL'    Evaluate    &{counter_dict}${path_format}
    ${counter_value_list}    Get Dictionary Values    ${counter_value_dict}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${counter_value_list[-1]}

Check PM Counter Latest Value From Admin
    [Arguments]    ${counter_id}    ${counter_path}    ${min_value}=${empty}    ${max_value}=${empty}    ${bts_id}=1
    [Documentation]    This keyword is to check single pm counters with counter path from admin
    ...     "${time}= ta_kiss_gnb.Get Counter File Remaining Time, counter_refresh_period=${counter_refresh_period}"
    ...     before this keyword is recomment. then, sleep     ${time}
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | counter id which want to get the value |
    ...    | ${counter_path} | Yes | counter path which display in admin but not includ counter name |
    ...    | ${min_value} | No | the expected min value, the default value is ${empty}, if not empty, counter value should bigger than this value |
    ...    | ${max_value} | No | the expected max value, the default value is ${empty}, if not empty, counter value should smaller than this value |
    ...
    ...    Examples:
    ...    | Check PM Counter Latest Value From Admin | M55118C01000 | CELLS/NRCELL-1/NCAC | max_value=350 |
    ...    | Check PM Counter Latest Value From Admin | M55800C00501 | BTS/MRBTS-1/CLOCK-1/GNSSE-1/NGNS | min_value=-1 |
    ...    | Check PM Counter Latest Value From Admin | M55602C00010 | SMOD/SFP-21/CABINET-1/BBMOD-1/SFPBM | min_value=20 | max_value=1000 |
    ${counter_value}    Get PM Counter Latest Value From Admin    ${counter_id}    ${counter_path}    ${bts_id}
    Run Keyword If    '${min_value}'!='${empty}' and '${max_value}'!='${empty}'    Should be True    ${min_value}<${counter_value}<${max_value}
    Run Keyword If    '${min_value}'=='${empty}' and '${max_value}'!='${empty}'    Should be True    ${counter_value}<${max_value}
    Run Keyword If    '${min_value}'!='${empty}' and '${max_value}'=='${empty}'    Should be True    ${min_value}<${counter_value}
    ute_reporting_portal.Report Pm Counter         ${counter_id}    ${counter_value}    Passed

Check Multi PM Counters Latest Value From Admin
    [Arguments]    ${counter_info_list}
    [Documentation]    This keyword is to check multi pm counters with counter path from admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_info_list} | Yes | the item is a dictionary, include keys:counter_id,counter_path,min_value/max_value |
    ...
    ...    Examples:
    ...    *** Variables ***
    ...    &{counter1_info}    counter_id=M55118C01000    counter_path=CELLS/NRCELL-1/NCAC    max_value=350
    ...    &{counter2_info}    counter_id=M55800C00501    counter_path=BTS/MRBTS-1/CLOCK-1/GNSSE-1/NGNS    min_value=-1
    ...    &{counter3_info}    counter_id=M55602C00010    counter_path=SMOD/SFP-21/CABINET-1/BBMOD-1/SFPBM    min_value=20    max_value=1000
    ...    @{counter_list}    ${counter1_info}    ${counter2_info}    ${counter3_info}
    ...    Check Multi PM Counters Latest Value From Admin    ${counter_list}
    ...
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${min_value_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counter_info}    min_value
        Run Keyword If    '${min_value_status}'=='False'    Set To Dictionary    ${counter_info}    min_value    ${empty}
        ${max_value_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counter_info}    max_value
        Run Keyword If    '${max_value_status}'=='False'    Set To Dictionary    ${counter_info}    max_value    ${empty}
        Check PM Counter Latest Value From Admin    ${counter_info.counter_id}
        ...    ${counter_info.counter_path}    ${counter_info.min_value}    ${counter_info.max_value}
    END

Wait Until PM Counter Update
    [Arguments]    ${counter_refresh_period}=5min    ${period_times}=0
    [Documentation]    This keyword is to calcute the wait time to get needed pm counter
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_refresh_period} | No | refresh period time for counter. the default value is 5min |
    ...    | ${period_times} | No | the number which counter need to get. the default value is 0 to get current counter |
    ...                          | 1 means to get next counter , and so on |
    ...
    ...    Examples:
    ...    | Wait PM Counter display | 5min | 1 |
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=${counter_refresh_period}
    ${time_to_sec}    Convert Time    ${counter_refresh_period}
    ${wait_time}    Evaluate   ${time}+${period_times}*int(${time_to_sec})
    Sleep    ${wait_time}    reason=wait until PM counter update

Get and Update BSR File
    [Arguments]     ${bsr_file_name}
    Run    git clone ${CUDU_L2_GOLDEN_FILE_ADDRESS} ${LOCAL_GOLDEN_FILE_PATH}
    COAM.setup admin
    ${ret}    COAM.Update Software    ${LOCAL_GOLDEN_FILE_PATH}/BSR_FILE/${bsr_file_name}
    COAM.teardown admin

