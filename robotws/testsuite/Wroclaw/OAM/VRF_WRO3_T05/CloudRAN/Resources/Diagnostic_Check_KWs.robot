*** Settings ***
Documentation    Cloud keywords for Diagnostic Check functionality.
...              Author:     Piotr Lukaszewicz
...              Contact:    piotr.lukaszewicz@nokia.com

Resource    ../../../cloud_common_resources/parameters/parameters.robot

Library     taf.gnb.oam.coam.cu    WITH NAME    diag_check_vcu
Library     taf.gnb.oam.coam.vdu    WITH NAME    diag_check_vdu

*** Keywords ***
Start Diagnostic Check
    [Documentation]    Description: Start diagnostic check.
    ...                Input:
    ...                    - hw_type: 'vCU' or 'vDU'
    ...                    - allow_service_impact: If True, service-impact checkpoints will be executed (default: False)
    ...                    - wait_for_completion: If True, wait until operation finishes (default: False)
    ...                    - timeout: operation timeout in seconds (default: 300)
    ...                    - connection: connection alias; for vDU calls this will be passed as vdu_connection
    ...                Output: status dictionary returned by underlying library (operation id, status, ...)
    ...                Author: piotr.lukaszewicz@nokia.com
    [Arguments]    ${hw_type}=${None}    ${allow_service_impact}=${False}    ${wait_for_completion}=${False}
    ...            ${timeout}=${300}    ${connection}=${None}
    IF    '${hw_type}' == 'vCU'
        ${operation}=    diag_check_vcu.start_diagnostic_check    allow_service_impact=${allow_service_impact}
        ...    wait_for_completion=${wait_for_completion}    timeout=${timeout}    connection=${connection}
    ELSE IF    '${hw_type}' == 'vDU'
        ${operation}=    diag_check_vdu.start_diagnostic_check    allow_service_impact=${allow_service_impact}
        ...    wait_for_completion=${wait_for_completion}    timeout=${timeout}    vdu_connection=${connection}
    ELSE
        FAIL    Unsupported hw_type '${hw_type}'
    END
    [Return]    ${operation}

Get Diagnostic Check Status
    [Documentation]    Description: Get diagnostic check status.
    ...                Input:
    ...                    - hw_type: 'vCU' or 'vDU'
    ...                    - operation_id: diagnostic check operation ID (from Start Diagnostic Check)
    ...                    - timeout: timeout in seconds for the status call (default: 30)
    ...                    - connection: connection alias; for vDU calls this will be passed as vdu_connection
    ...                Output: status string (e.g. 'succeeded', 'failed') or raises on error
    ...                Author: piotr.lukaszewicz@nokia.com
    [Arguments]    ${hw_type}=${None}    ${operation_id}=${None}    ${timeout}=${30}    ${connection}=${None}
    IF    '${hw_type}' == 'vCU'
        ${diag_check_details}=    diag_check_vcu.get_diagnostic_check_status    operation_id=${operation_id}
        ...    timeout=${timeout}    connection=${connection}
    ELSE IF    '${hw_type}' == 'vDU'
        ${diag_check_details}=    diag_check_vdu.get_diagnostic_check_status    operation_id=${operation_id}
        ...    timeout=${timeout}    vdu_connection=${connection}
    ELSE
        FAIL    Unsupported hw_type '${hw_type}'
    END
    ${diag_check_status}=    Get From Dictionary    ${diag_check_details}    status
    [Return]    ${diag_check_status}

Get Diagnostic Check Report
    [Documentation]    Description: Retrieve diagnostic check report(s).
    ...                Input:
    ...                    - hw_type: 'vCU' or 'vDU'
    ...                    - timeout: timeout in seconds for the retrieval (default: 30)
    ...                    - connection: connection alias; for vDU calls this will be passed as vdu_connection
    ...                Output: list/dictionary with diagnostic check report content
    ...                Author: piotr.lukaszewicz@nokia.com
    [Arguments]    ${hw_type}=${None}    ${timeout}=${30}    ${connection}=${None}
    IF    '${hw_type}' == 'vCU'
        ${diag_check_report}=    diag_check_vcu.get_diagnostic_check_reports    timeout=${timeout}
        ...    connection=${connection}
    ELSE IF    '${hw_type}' == 'vDU'
        ${diag_check_report}=    diag_check_vdu.get_diagnostic_check_reports    timeout=${timeout}
        ...    vdu_connection=${connection}
    ELSE
        FAIL    Unsupported hw_type '${hw_type}'
    END
    [Return]    ${diag_check_report}

Start Custom Diagnostic Check
    [Documentation]    Description: Start a customized diagnostic check that runs only specified checkpoints.
    ...                Input:
    ...                    - hw_type: 'vCU' or 'vDU'
    ...                    - vnf_checkpoint_ids: list of VNF checkpoint IDs to execute (e.g. [38,39])
    ...                    - rmod_checkpoint_ids: list of RMOD checkpoint dicts (used only for vDU)
    ...                    - wait_for_completion: If True, wait until operation finishes (default: False)
    ...                    - timeout: timeout in seconds (default: 300)
    ...                    - connection: connection alias; for vDU calls this will be passed as vdu_connection
    ...                Output: status dictionary returned by underlying library (operation id, status, ...)
    ...                Author: piotr.lukaszewicz@nokia.com
    [Arguments]    ${hw_type}=${None}    ${vnf_checkpoint_ids}=${None}    ${rmod_checkpoint_ids}=${None}
    ...            ${wait_for_completion}=${False}    ${timeout}=${300}    ${connection}=${None}
    IF    '${hw_type}' == 'vCU'
        ${operation}=    diag_check_vcu.start_customized_diagnostic_check    vnf_checkpoint_ids=${vnf_checkpoint_ids}
        ...    wait_for_completion=${wait_for_completion}    timeout=${timeout}    connection=${connection}
    ELSE IF    '${hw_type}' == 'vDU'
        ${operation}=    diag_check_vdu.start_customized_diagnostic_check    vnf_checkpoint_ids=${vnf_checkpoint_ids}
        ...    rmod_checkpoint_ids=${rmod_checkpoint_ids}    wait_for_completion=${wait_for_completion}
        ...    timeout=${timeout}    vdu_connection=${connection}
    ELSE
        FAIL    Unsupported hw_type '${hw_type}'
    END
    [Return]    ${operation}

Get Custom Diagnostic Check Status
    [Documentation]    Description: Get customized diagnostic check status.
    ...                Input:
    ...                    - hw_type: 'vCU' or 'vDU'
    ...                    - operation_id: diagnostic check operation ID (from Start Custom Diagnostic Check)
    ...                    - timeout: timeout in seconds for the status call (default: 30)
    ...                    - connection: connection alias; for vDU calls this will be passed as vdu_connection
    ...                Output: status string (e.g. 'succeeded', 'failed')
    ...                Author: piotr.lukaszewicz@nokia.com
    [Arguments]    ${hw_type}=${None}    ${operation_id}=${None}    ${timeout}=${30}    ${connection}=${None}
    IF    '${hw_type}' == 'vCU'
        ${diag_check_details}=    diag_check_vcu.get_customized_diagnostic_check_status    operation_id=${operation_id}
        ...    timeout=${timeout}    connection=${connection}
    ELSE IF    '${hw_type}' == 'vDU'
        ${diag_check_details}=    diag_check_vdu.get_customized_diagnostic_check_status    operation_id=${operation_id}
        ...    timeout=${timeout}    vdu_connection=${connection}
    ELSE
        FAIL    Unsupported hw_type '${hw_type}'
    END
    ${diag_check_status}=    Get From Dictionary    ${diag_check_details}    status
    [Return]    ${diag_check_status}

Get Vnf And Rmod Checkpoints
    [Documentation]    Description: Get VNF and RMOD checkpoints for vDU.
    ...                Input:
    ...                    - timeout: timeout in seconds for the call (default: 30)
    ...                    - connection: connection alias (vdu_connection)
    ...                Output: list with diagnostic check checkpoints (vdu)
    ...                Author: piotr.lukaszewicz@nokia.com
    [Arguments]    ${timeout}=${30}    ${connection}=${None}
    ${checkpoints}=    diag_check_vdu.get_vnf_and_rmod_checkpoints    timeout=${timeout}    vdu_connection=${connection}
    [Return]    ${checkpoints}

Get Results For Specific Checkpoint Id From Report
    [Documentation]    Description: Extract all results for given checkpoint ID from a diagnostic check report.
    ...                Input:
    ...                    - diag_check_report: list of checkpoint results (from Get Diagnostic Check Report)
    ...                    - checkpoint_id: numeric checkpoint identifier
    ...                Output: list with matching checkpoint result(s)
    ...                Author: piotr.lukaszewicz@nokia.com
    [Arguments]    ${diag_check_report}=${None}    ${checkpoint_id}=${None}
    ${filtered_results}=    Create List
    FOR    ${result}    IN    @{diag_check_report}
        ${is_id_matching}=    Run Keyword And Return Status    Should Be Equal    ${result['checkpoint']}    ${checkpoint_id}
        Run Keyword If    ${is_id_matching}    Append To List    ${filtered_results}    ${result}
    END
    [Return]    ${filtered_results}

Get Results With Specific Status From Report
    [Documentation]    Description: Extract all results with specific status from a diagnostic check report.
    ...                Input:
    ...                    - diag_check_report: list of checkpoint results (from Get Diagnostic Check Report)
    ...                    - status: expected checkpoint status (e.g., 'succeeded', 'failed')
    ...                Output: list with matching checkpoint result(s)
    ...                Author: piotr.lukaszewicz@nokia.com
    [Arguments]    ${diag_check_report}=${None}    ${status}=${None}
    ${filtered_results}=    Create List
    FOR    ${result}    IN    @{diag_check_report}
        ${is_status_matching}=    Run Keyword And Return Status    Should Be Equal    ${result['lastDefinitiveCheckStatus']}    ${status}
        Run Keyword If    ${is_status_matching}    Append To List    ${filtered_results}    ${result}
    END
    [Return]    ${filtered_results}

Set Diagnostic Check Schedule
    [Documentation]    Description: Configure diagnostic check schedule (online DC).
    ...                Input:
    ...                    - hw_type: 'vCU' or 'vDU'
    ...                    - check_days: days in bit format when DC will be started (7 bits, bit#0 = Monday), e.g. '0111110'
    ...                    - check_time: time in 'HH:MM:SS' format when DC will be started
    ...                    - connection: connection alias (pre-connection) used for BTS parameter change
    ...                Output: none
    ...                Author: piotr.lukaszewicz@nokia.com
    [Arguments]    ${hw_type}=${None}    ${check_days}=${None}    ${check_time}=${None}    ${connection}=${None}
    ${modified_string}=    Evaluate    "${check_days}".lstrip('0')    string
    ${check_days_int}=    Evaluate    int('${modified_string}', 2)
    ${values_dc_schedule}=    Create Dictionary    checkDays    ${check_days_int}    checkTime    ${check_time}
    Change Parameter on BTS    dist_name=MRBTS-86991/MNL-1/MNLENT-1/TRBLCADM-1    param_name=diagnosticCheckSchedule
    ...    operation=update    hw_type=${hw_type}    param_value=${values_dc_schedule}    pre-connection=${connection}

Set Service Impact Diagnostic Check Schedule
    [Documentation]    Description: Configure service-impact diagnostic check schedule.
    ...                Input:
    ...                    - hw_type: 'vCU' or 'vDU'
    ...                    - check_days: days in bit format when DC will be started (7 bits, bit#0 = Monday)
    ...                    - check_time: time in 'HH:MM:SS' format when DC will be started
    ...                    - repeat_weeks: number of weeks for recurrence
    ...                    - start_date: start date in 'YYYY-MM-DD' format
    ...                    - connection: connection alias (pre-connection) used for BTS parameter change
    ...                Output: none
    ...                Author: piotr.lukaszewicz@nokia.com
    [Arguments]    ${hw_type}=${None}    ${check_days}=${None}    ${check_time}=${None}
    ...            ${repeat_weeks}=${None}    ${start_date}=${None}    ${connection}=${None}
    ${values_dc_schedule_serv_impact}=    Create Dictionary    checkDays    ${check_days}
    ...    checkTime    ${check_time}    repeatEveryNWeeks    ${repeat_weeks}    startDate    ${start_date}
    Change Parameter on BTS    dist_name=MRBTS-86991/MNL-1/MNLENT-1/TRBLCADM-1    param_name=servImpDiagnosticCheckSchedule
    ...    operation=update    hw_type=${hw_type}    param_value=${values_dc_schedule_serv_impact}    pre-connection=${connection}
