*** Settings ***
Documentation    ...
Library    taf.gnb.oam.coam.cu    WITH NAME    vcu

*** Keywords ***
VCU Login
    [Arguments]    ${gnb_index}=0    ${alias}=${None}    ${restapi_version}=cuoam_21b    ${delay}=${EMPTY}
    [Documentation]    Create rest session to CU.
    ...    | Input Parameters | Man. | Description |
    ...    |    gnb_index    | No |    gnb index to indicate which gnb will be used    |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given 'cuoam_21b'
    ...    other senarios should be use default value - cuoam_21b |
    ...    |    alias | No. | alias that identifies this connection, if the argument is given,
    ...    the alias must be given to the CU Logout keyword as connection argumument. |
    ...    |    delay | No |    delay, default is ${EMPTY}    |
    ...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...    Example
    ...    |    CU Rest Login    |    |
    ...    |    CU Rest Login    |    delay=3    |
    Run Keyword And Ignore Error    VCU Logout
    ${password}    Set Variable If    '${BRANCH}'=='Trunk'    Nokia@123    nemuuser
    vcu.Connect To    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${password}
    ...    cu_version=${restapi_version}
    ...    secure=${true}
    ...    alias=${alias}
    ...    timeout=120
    Run Keyword If    "${delay}"!="${EMPTY}"    Sleep    ${delay}

VCU Logout
    [Arguments]    ${connection}=${none}
    [Documentation]    Teardown rest session to CU.
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |
    ...    Example
    ...    |    CU Rest Logout |    |
    vcu.Disconnect    connection=${connection}

VCU Full Commssion
    [Arguments]    ${vcu_scfc_path}    ${gnb_index}=0
    [Documentation]    Send BTS commission via rest.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:    <13-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |    vCU_SCFC_PATH    | Yes. | Path of commission file |
    ...    |    gnb_index    | No |    gnb index to indicate which gnb will be used, 0 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | VCU Full Commssion |    /tmp/commission.xml    |

    Set Single Value From Scf File    ${vcu_scfc_path}   MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
    ...    destIpAddr    ${tl.test_pc.default_ssh_connection_details.addr}    staticRoutes
    VCU Login    ${gnb_index}
    Log To Console    \n*** Delete plan id if have ***
    ${plan_info_list}    Get Plan Info
    FOR    ${plan_info}    IN    @{plan_info_list}
        ${plan_id}     Get From Dictionary    ${plan_info}    plan_id
        Plan Delete    ${plan_id}
    END
    Log To Console    \n*** Start plan upload operation ***
    ${upload_operation_info}=    vcu.Upload Plan File    ${vcu_scfc_path}
    Log To Console    \n*** upload scfc operation success ***
    Log To Console    \n*** Wait plan upload operation success ***
    Wait Until Keyword Succeeds    60s    10s    VCU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    Log To Console    \n*** Start plan validate operation ***
    ${validate_operaition_info}=    vcu.Plan Validation    ${upload_operation_info["plan_id"]}
    Log To Console    \n*** Wait plan validate operation success ***
    Wait Until Keyword Succeeds    60s    10s    VCU Check Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}    ${validate_operaition_info["action_id"]}    success
    Log To Console    \n*** validation scfc operation success ***
    Log To Console    \n*** Start plan activate operation ***
    ${activate_operaition_info}=    vcu.Plan Activation    ${upload_operation_info["plan_id"]}
    Log To Console    \n*** Wait plan activate operation success in 10 mins ***
    Wait Until Keyword Succeeds    900s    60s    VCU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}    ${activate_operaition_info["id"]}    success
    [Teardown]    Run Keyword And Ignore Error    VCU Logout

VCU Check Plan Upload Status Should Be As Expected
    [Arguments]    ${operation_id}    ${expected_status}
    [Documentation]    Check plan upload status should be as expected.
    ...    | Input Parameters | Man. | Description |
    ...    |    operation_id    | Yes. |    Operation id for uploading plan file    |
    ...    |    expected_status    | Yes. |    Expected upload status, can be success, ongoing or failure    |
    ...    Example
    ...    |    CU Check Plan Upload Status Should Be As Expected    |    a_6cfa594f-0938-4732-a78c-16afdbd214d2 |    success    |
    ${operation_response}=    vcu.Get Operation State Of Uploading Plan    ${operation_id}
    Should Be True    "${operation_response["status"]}"=="${expected_status}"

VCU Check Plan Validate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   [Documentation]   Check plan validate status should be as expected.
        ...    | Input Parameters | Man. | Description |
        ...    |  plan_id  | Yes. |  Plan file id  |
        ...    |  operation_id  | Yes. |  Operation id for validating plan file  |
        ...    |  expected_status  | Yes. |  Expected validate status, can be success, ongoing or failure   |
        ...    |  CU Check Plan Validate Status Should Be As Expected  |  sp_39d02514-e65b-46db-9ad7  |  a_0c7769bd-78ae-4505-9ce1 |  success  |
   ${operation_response}=  vcu.get_operation_state_of_validating_plan     ${plan_id}    ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

VCU Check Plan Activate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   [Documentation]   Check plan activate status should be as expected.
        ...    | Input Parameters | Man. | Description |
        ...    |  plan_id  | Yes. |  Plan file id  |
        ...    |  operation_id  | Yes. |  Operation id for activating plan file  |
        ...    |  expected_status  | Yes. |  Expected activate status, can be success, ongoing or failure   |
        ...    |  CU Check Plan Activate Status Should Be As Expected   |  sp_39d02514-e65b-46db-9ad7 |  o_c1ca0de5-3225-46e4-86bd  |  success  |
   ${operation_response}=  vcu.get_operation_state_of_activating_plan    ${plan_id}   ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

VCU Get Current Plan File
    [Arguments]    ${log_dir}    ${scf_backup_name}    ${gnb_index}=0
    [Documentation]    This keyword is to save vcu plan file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the path to save scf file |
    ...    | ${scf_backup_name} | Yes | the name for saved scf file,eg. before_suite_vcu_scf.xml |
    ...    | ${gnb_index} | No | gnb index, the default value is 0 |
    ...
    ...    Examples:
    ...    | ${vcu_scf_file} | VCU Get Current Plan File | ${output_dir} | before_suite_vcu_scf.xml |
    VCU Login    ${gnb_index}
    vcu.get_current_plan_file    ${log_dir}//${scf_backup_name}
    ${vcu_scf_file}    Set Variable    ${log_dir}//${scf_backup_name}
    [Teardown]    Run Keyword And Ignore Error    VCU Logout
    [Return]    ${vcu_scf_file}

VCU Get Cell Numbers
    [Arguments]    ${gnb_index}=0
    VCU Login    ${gnb_index}
    ${cells_status_list}    vcu.get_cells_statuses
    ${cell_number}    Get Length    ${cells_status_list}
    [Teardown]    Run Keyword And Ignore Error    VCU Logout
    [Return]    ${cell_number}

VCU Verify F1 Setup
    [Documentation]   This keyword is used to Get the F1 link status by admin api to CU.
    [Arguments]    ${gnb_index}=0
    VCU Login    ${gnb_index}
    ${du_status}    vcu.get du state
    ${f1_status}    Set Variable    ${du_status['f1_link_status']}
    ${f1_status_str}    Convert To String    ${f1_status}
    Should Contain    ${f1_status_str}      'available': 1
    [Teardown]    Run Keyword And Ignore Error    VCU Logout

VCU Collect Snapshot
    [Arguments]    ${save_dir}    ${gnb_index}=0
    VCU Login    ${gnb_index}
    Log To Console      --> start saving vCU Snapshot log
    vcu.get_local_snapshot   directory=${save_dir}
    [Teardown]    Run Keyword And Ignore Error    VCU Logout

VCU Get PM Counter Value
    [Arguments]    ${counter_id}    ${dimension_dn}    ${measurement_id}=None
    [Documentation]    This keyword is to get the latest value for a vCU counter
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | yes | the counter id, e.g.M55115C00002 |
    ...    | ${dimension_dn} | yes | the dimension dist name that the counter belongs to, e.g.MRBTS-1111/NRBTS-1111/NRCELL-1 |
    ...    | ${measurement_id} | No | the measurement id, e.g.55115 ,the default value is None|
    ...
    ...    Examples:
    ...    |  |  |  |
    VCU Login
    # ${counter_info}    vcu.get_counter_info    counter_id=M55112C00002    measurement_id=55112
    ${counter}    vcu.get_counter    measurement_id=${measurement_id}    dimension_dist_name=${dimension_dn}
    ...    counter_id=${counter_id}
    ${counter_values}    Get From Dictionary    ${counter}    values
    Run Keyword If    ${counter_values}==[]    Fail    No counter value right now.
    ${counter_value}    Get From Dictionary    ${counter_values[-1]}    value
    Log To Console    The latest value for counter '${counter_id}': ${counter_value}
    [Teardown]    Run Keyword And Ignore Error    VCU Logout
    [Return]    ${counter_value}

VCU Get Software Version
    VCU Login
    ${vcu_sw_version}    vcu.get_active_software_version
    Set Suite Variable    ${TOTAL_VCU_SW_VERSION}    ${vcu_sw_version}
    Log    VCU Total SW Version: ${TOTAL_VCU_SW_VERSION}    console=${true}
    [Teardown]    Run Keyword And Ignore Error    VCU Logout