*** Settings ***
Documentation
    ...    This resource constructs a command to inject or delete alarms via a Kubernetes pod and executes it
    ...    on the appropriate cluster (vCU or vDU) and Validates that the number of active critical alarms matches the expected value.
    ...    History of changes:    01.08.2025 - Initial creation
    ...    Author:         jakub.kokoszka@nokia.com


*** Keywords ***
Inject Or Delete Alarms
    [Documentation]
    ...  This keyword injects or deletes alarms in the vCU or vDU system.
    ...  Inject: Adds alarms to the system (inject=1).
    ...  Delete: Removes alarms from the system (delete=0)
    [Arguments]    ${inject_or_delete}    ${NUMBER_OF_INJECTED_ALARMS}  ${MRBTS_ID}  ${NRBTS_ID}    ${NAMESPACE}    ${FID_ID}    ${hw_type}

    Run Keyword If    ${inject_or_delete} == 1    Log to console    Injecting alarms
    ...    ELSE IF    ${inject_or_delete} == 0    Log to console    Deleting alarms
    ...    ELSE    Fail    Invalid argument: ${inject_or_delete}. Expected 1 (inject) or 0 (delete).

    ${cmd}    Catenate    SEPARATOR=
    ...    for ((i=1; i<=${NUMBER_OF_INJECTED_ALARMS}; i++));${SPACE}
    ...    do echo "$(TZ=\"UTC\" date +\"%Y-%m-%dT%H:%M:%S.%N%:z\")${SPACE}
    ...    - " && kubectl exec -n ${NAMESPACE} -it po-oamfm-0 -c ctr-oamfm${SPACE}
    ...    -- curl --request POST --url http://oam-faultmanagement:9004/api/fm/v1/faults${SPACE}
    ...    --header \'content-type: application/json\'${SPACE}
    ...    --data "{\\"faultId\\":${FID_ID},\\"state\\":${inject_or_delete},\\"severity\\":1,\\"source\\":\\"MRBTS-${MRBTS_ID}\\/NRBTS-
    ...    ${NRBTS_ID}\\/NRCELL-$i\\",\\"sourceType\\":1,\\"extraInfo\\":\\"test-alarm$i\\",\\"recoveryOverride\\":1}";done

    Run Keyword If    '${hw_type}' == 'vCU'    Connect To vCU K8s Master
    ...    ELSE    Connect To vDU K8s Master

    ${cmd_output}=   issh.Execute    command=${cmd}   alias=${connection_alias}
    common_keywords.Disconnect Interactive Connection    alias=${connection_alias}
    [Return]    ${cmd_output}

Connect To vCU K8s Master
    ${connection_alias}=    common_vcu.Connect To vCU K8s Master Node With Tenant    0    3600
    Set Test Variable    ${connection_alias}
Connect To vDU K8s Master
    ${connection_alias}=    common_vdu.Connect To vDU K8s Master Node With Tenant
    Set Test Variable    ${connection_alias}


Check Active Critical Alarm Summary Is Equal
    [Documentation]
    ...  Validates that the number of active critical alarms matches the expected value.
    [Arguments]  ${expected_number}    ${hw_type}

    Log    Check active critical alarm summary is equal ${expected_number}   console=${True}
    ${alarms_summary}=    Run Keyword If    '${hw_type}'=='vCU'
    ...    vcu_admin.get_active_alarms_summary    connection=${vcu_connection}
    ...    ELSE
    ...    vdu_admin.vdu_get_active_alarms_summary    vdu_connection=${vdu_connection}
    ${critical_value}=    Get From Dictionary    ${alarms_summary['severity']}    critical
    Run Keyword And Continue On Failure    Should Be Equal As Numbers    ${critical_value}    ${expected_number}
    Log    Active critical alarm summary is equal ${expected_number}   console=${True}
