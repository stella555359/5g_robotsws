*** Settings ***
Documentation    Cloud commissioning keywords.
...              Authors:    Patryk Tatarek, Jagoda Kubacka
...              Contact:    patryk.tatarek@nokia.com, jagoda.kubacka@nokia.com

Resource    ../connections/connections.robot
Resource    taf/rfrl/cbts/robot/vcu/vcu_cm.robot
Resource    taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Resource    taf/rfrl/cbts/robot/webem_operations.robot

Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library     String
Library     Collections

*** Keywords ***

#################################################### Main  Keywords ####################################################

Download SCF
    [Documentation]    Description:    Download current SCF
    ...                Input:          hw_type = vCU/vDU
    ...                                scf_path = local path for downloaded scf,
    ...                                for example: /home/ute/scf.xml
    ...                                include_runtime_data = True/False
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${scf_path}     ${hw_type}    ${include_runtime_data}=${False}
    Run Keyword If    '${hw_type}'=='vCU'    _Download SCF from vCU    scf_path=${scf_path}    include_runtime_data=${include_runtime_data}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Download SCF from vDU    scf_path=${scf_path}    include_runtime_data=${include_runtime_data}
    ...    ELSE        FAIL                  hw_type doesn't exist

Trigger SCF Download
    [Documentation]    Description:    Download current SCF
    ...                Input:          hw_type = vCU/vDU
    ...                                include_runtime_data = True/False
    ...                Output:         {'id': 'a0129038-d9ff-45cf-b794-a700da8e0e12', 'isCompleted': False,
    ...                                 'links': [{'href': '/current-plan/operations/uploads/a0129038-d9ff-45cf-b794-a700da8e0e12', 'rel': 'self'}]}
    ...                Author:         karol.sadowski@nokia.com
    [Arguments]        ${hw_type}    ${include_runtime_data}=${False}
    ${output}=    Run Keyword If    '${hw_type}'=='vCU'    _Trigger SCF Download from vCU    include_runtime_data=${include_runtime_data}
                  ...    ELSE IF    '${hw_type}'=='vDU'    _Trigger SCF Download from vDU    include_runtime_data=${include_runtime_data}
                  ...    ELSE        FAIL                  hw_type doesn't exist
    [Return]    ${output}

Check SCF Download Status
    [Documentation]    Description:    Download current SCF
    ...                Input:          hw_type = vCU/vDU
    ...                                operation_id = ['id'] from Trigger SCF Download kw output dictionary
    ...                Output:         {'id': 'a0129038-d9ff-45cf-b794-a700da8e0e12', 'isCompleted': False,
    ...                                 'links': [{'href': '/current-plan/operations/uploads/a0129038-d9ff-45cf-b794-a700da8e0e12', 'rel': 'self'}]}
    ...                Author:         karol.sadowski@nokia.com
    [Arguments]        ${hw_type}    ${operation_id}
    ${output}=    Run Keyword If    '${hw_type}'=='vCU'    _Check SCF Download Status vCU    operation_id=${operation_id}
                  ...    ELSE IF    '${hw_type}'=='vDU'    _Check SCF Download Status vDU    operation_id=${operation_id}
                  ...    ELSE        FAIL                  hw_type doesn't exist
    [Return]    ${output}

Activate SCF With Preactivation
    [Documentation]    Description:    Activate given plan
    ...                Input:          hw_type = vCU/vDU
    ...                                plan_id = can be obtained from Upload SCF kw output
    ...                                timeout = timeout for activation in seconds (only for vDU)
    ...                Output:         Dictionary with values like operation status, operation id etc:
    ...                                {'cm_plan_id': , 'error_message': , 'id': '', 'links': , 'procedure_state': '', 'status': '' }
    ...                Author:         karol.sadowski@nokia.com
    [Timeout]          12 minutes
    [Arguments]        ${hw_type}    ${plan_id}    ${timeout}=300    ${wait_until_done}=${True}    ${pre_activated}=False
    &{output}=   Run Keyword If    '${hw_type}'=='vCU'    _Activate SCF On VCU    plan_id=${plan_id}
                                                          ...    wait_until_done=${wait_until_done}    pre_activated=${pre_activated}
                 ...    ELSE IF    '${hw_type}'=='vDU'    _Activate SCF On VDU    plan_id=${plan_id}    timeout=${timeout}
                                                          ...    wait_until_done=${wait_until_done}    pre_activated=${pre_activated}
                 ...    ELSE        FAIL                  hw_type doesn't exist
    [Return]    ${output}

Delete SCF
    [Documentation]    Description:    Delete given plan
    ...                Input:          hw_type = vCU/vDU
    ...                                plan_id = can be obtained from Upload SCF kw output
    ...                                timeout = timeout for activation in seconds (only for vDU)
    ...                Output:         None
    ...                Author:         karol.sadowski@nokia.com
    [Timeout]          3 minutes
    [Arguments]        ${hw_type}    ${plan_id}    ${timeout}=180
    Run Keyword If    '${hw_type}'=='vCU'    _Delete SCF On VCU    plan_id=${plan_id}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Delete SCF On VDU    plan_id=${plan_id}    timeout=${timeout}
    ...    ELSE        FAIL                  hw_type doesn't exist

Perform SCF Commissioning
    [Documentation]    Description:    Operation uploads, validates and optionally activates the plan. Usefull for pre-activation scenario,
     ...                               to activate pre-activated plan recall Perform Commissioning with should_activate=True
    ...                Input:          hw_type = vCU/vDU
    ...                                scf_path = local path for scf to upload,
    ...                                timeout = timeout for activation in seconds
    ...                                wait_until_done = True/False wait for operation finish
    ...                                should_activate = True/False perform activation after upload and validation
    ...                Output:         None
    ...                Author:         karol.sadowski@nokia.com
    [Timeout]          20 minutes
    [Arguments]    ${hw_type}    ${scf_path}    ${timeout}=1200    ${wait_until_done}=${True}    ${should_activate}=${True}
    &{output}=    Run Keyword If    '${hw_type}'=='vCU'   _Perform Commissioning on vCU    scf=${scf_path}    timeout=${timeout}
    ...    wait_until_done=${wait_until_done}    should_activate=${should_activate}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Perform Commissioning on vDU    scf=${scf_path}    timeout=${timeout}
    ...    wait_until_done=${wait_until_done}    should_activate=${should_activate}
    ...    ELSE        FAIL                  hw_type doesn't exist
    [Return]    ${output}

################################################ Supplementary Keywords ################################################

_Download SCF from vCU
    [Arguments]      ${scf_path}    ${include_runtime_data}
    ${temp_conn}=    Connect to ADMIN    hw_type=vCU
    vcu_admin.get_current_plan_file    path=${scf_path}    connection=${temp_conn}   include_runtime_data=${include_runtime_data}
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Download SCF from vDU
    [Arguments]      ${scf_path}    ${include_runtime_data}
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    ${split}=        Split String From Right    ${scf_path}    /    1
    ${dir_path}=     Get From List    ${split}    0
    ${file_name}=    Get From List    ${split}    1
    vdu_admin.get_current_plan_file    local_dir_path=${dir_path}    filename=${file_name}
    ...                                include_runtime_data=False    vdu_connection=${temp_conn}    include_runtime_data=${include_runtime_data}
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Trigger SCF Download from vCU
    [Arguments]    ${include_runtime_data}
    ${temp_conn}=    Connect to ADMIN    hw_type=vCU
    ${output}=    vcu_admin.trigger_download_of_current_plan    connection=${temp_conn}   include_runtime_data=${include_runtime_data}
    [Return]    ${output}
    [Teardown]    Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Trigger SCF Download from vDU
    [Arguments]    ${include_runtime_data}
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    ${output}=    vdu_admin.trigger_download_of_current_plan    vdu_connection=${temp_conn}   include_runtime_data=${include_runtime_data}
    [Return]    ${output}
    [Teardown]    Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Check SCF Download Status vCU
    [Arguments]    ${operation_id}
    ${temp_conn}=    Connect to ADMIN    hw_type=vCU
    ${output}=    vcu_admin.get_status_of_current_plan_download    operation_id=${operation_id}    connection=${temp_conn}
    [Return]    ${output}
    [Teardown]    Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Check SCF Download Status vDU
    [Arguments]    ${operation_id}
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    ${output}=    vdu_admin.get_status_of_current_plan_download    operation_id=${operation_id}    vdu_connection=${temp_conn}
    [Return]    ${output}
    [Teardown]    Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Activate SCF on vCU
    [Arguments]      ${plan_id}    ${wait_until_done}    ${pre_activated}
    ${temp_conn}=    Connect to ADMIN    hw_type=vCU
    ${output}=    vcu_admin.plan_activation    plan_id=${plan_id}    connection=${temp_conn}    pre_activated=${pre_activated}
    WHILE    ${wait_until_done}
        ${status}=    Wait Until Keyword Succeeds    12 min    5 sec    vcu_admin.get_operation_state_of_activating_plan
        ...    plan_id=${plan_id}    operation_id=${output['id']}    connection=${temp_conn}    pre_activated=${pre_activated}
        ${status}=    Run Keyword If    ${pre_activated}    Get From Dictionary    ${status}    isCompleted
        ...    ELSE    Get From Dictionary    ${status}    status
        IF    (${pre_activated} and '${status}' == 'False') or (not ${pre_activated} and '${status}' == 'ongoing')
            Sleep    100ms
        ELSE IF    '${status}' == 'failure'
            Fail    Upload failed
        ELSE IF    (${pre_activated} and '${status}' == 'True') or (not ${pre_activated} and '${status}' == 'success')
            BREAK
        ELSE
            Fail    Unknown status
        END
    END
    [Return]         ${output}
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Activate SCF on vDU
    [Arguments]      ${plan_id}    ${timeout}    ${wait_until_done}    ${pre_activated}
    Log    pre_activated activation currently not supported on vDU    level=WARN
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    ${output}=    vdu_admin.activate_plan    plan_id=${plan_id}    timeout=${timeout}    vdu_connection=${temp_conn}
    WHILE    ${wait_until_done}
        ${status}=    Wait Until Keyword Succeeds    10 min    5 sec    vdu_admin.get_activate_plan_operation_status
        ...    plan_id=${plan_id}    operation_id=${output['id']}    vdu_connection=${temp_conn}    timeout=5
        ${status}=    Get From Dictionary    ${status}    status
        IF    '${status}' == 'ongoing'
            Sleep    100ms
        ELSE IF    '${status}' == 'failure'
            Fail    Upload failed
        ELSE IF    (${pre_activated} and '${status}' == 'True') or (not ${pre_activated} and '${status}' == 'success')
            BREAK
        ELSE
            Fail    Unknown status
        END
    END
    [Return]         ${output}
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Delete SCF on vCU
    [Arguments]      ${plan_id}
    ${temp_conn}=    Connect to ADMIN    hw_type=vCU
    ${output}=    vcu_admin.plan_delete    plan_id=${plan_id}    connection=${temp_conn}
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Delete SCF on vDU
    [Arguments]      ${plan_id}    ${timeout}
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    ${output}=    vdu_admin.delete_staged_plan_file    id=${plan_id}    timeout=${timeout}    vdu_connection=${temp_conn}
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Perform Commissioning on vCU
    [Arguments]      ${scf}    ${timeout}    ${wait_until_done}    ${should_activate}
    ${temp_conn}=    Connect to ADMIN    hw_type=vCU
    &{output}=    vcu_admin.perform_commissioning    scf_file=${scf}    timeout=${timeout}    wait_for_completion=${wait_until_done}
    ...    connection=${temp_conn}    should_activate=${should_activate}
     WHILE    ${wait_until_done}
        ${status}=    Wait Until Keyword Succeeds    1 min    5 sec    vcu_admin.get_status_of_perform_commissioning
        ...    operation_id=${output['id']}    connection=${temp_conn}    should_activate=${should_activate}
        ${status}=    Get From Dictionary    ${status}    status
        Run Keyword If    '${status}'=='ongoing'    Sleep    100ms
        ...    ELSE IF    '${status}'=='fail'     Fail    Download failed
        ...    ELSE IF    '${status}'=='success'    Set Test Variable    ${wait_until_done}    ${False}
        ...    ELSE    Fail    Unknown status
    END
    [Teardown]    Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU
    [Return]    ${output}

_Perform Commissioning on vDU
    [Arguments]      ${scf}    ${timeout}    ${wait_until_done}    ${should_activate}
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    &{output}=    vdu_admin.perform_commissioning    scf_file=${scf}    timeout=${timeout}    wait_for_completion=${wait_until_done}
    ...    vdu_connection=${temp_conn}    should_activate=${should_activate}
    WHILE    ${wait_until_done}
        ${status}=    Wait Until Keyword Succeeds    10 min    5 sec    vdu_admin.get_status_of_perform_commissioning
        ...    operation_id=${output['id']}    vdu_connection=${temp_conn}    should_activate=${should_activate}
        ${status}=    Get From Dictionary    ${status}    status
        Run Keyword If    '${status}'=='ongoing'    Sleep    100ms
        ...    ELSE IF    '${status}'=='fail'     Fail    Download failed
        ...    ELSE IF    '${status}'=='success'    Set Test Variable    ${wait_until_done}    ${False}
        ...    ELSE    Fail    Unknown status
    END
    [Teardown]    Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU
    [Return]    ${output}