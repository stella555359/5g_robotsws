*** Settings ***
Documentation
    ...    The test injects a specified number of alarms into the vCU and then verifies if the number of active alarms meets the KPI requirements.
    ...    The process runs for a defined number of iterations as specified in the test suite.
    ...    At the end of the test, it calculate average KPI result
    ...    Author:    Jakub Kokoszka
    ...    Contact:   jakub.kokoszka@nokia.com

*** Variables ***
${number_of_iterations_TC21}           10
${number_of_injected_alarms_TC21}      30
${KPI_target}    0.5
@{KPI_results}

*** Keywords ***
CB011085_A_TC21_Alarm_Rate_WebEM_vCU
    Step 1: Precondition
    FOR    ${index}    IN RANGE    ${number_of_iterations_TC21}
        Log    \n--- Execution loop: ${index + 1} ---    console=${True}
        Step 2: Inject amount of Alarms   ${number_of_injected_alarms_TC21}
        Step 3: Check alarm rate
        Step 4: Delete injected amount of Alarms    ${number_of_injected_alarms_TC21}
        Log    \n--- Loop ${index + 1}: Completed ---    console=${True}
    END
    Step 5: Calculate Average KPI Result    ${KPI_results}


Step 1: Precondition
    [Documentation]
    ...  This step collects the SCF and initializes variables necessary for subsequent test steps.

    Log    \nStep 1: Precondition    console=${True}

    vcu_admin.Get_Current_Plan_File    path=${Test_Results_Dir}/vcu_scf.xml    connection=${vcu_connection}
    ${scf_content}=   OperatingSystem.Get File   ${Test_Results_Dir}/vcu_scf.xml
    Log    ${scf_content}   console=${False}
    ${result}=     Get Regexp Matches    ${scf_content}   .*NRDU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRDU-(\\d+)"\\s+.*   1  2  3
    ${mrbts_id}=  Set Variable If  ${result}   ${result[0][0]}
    Set Test Variable    ${mrbts_id}
    ${nrbts_id}=  Set Variable If  ${result}   ${result[0][1]}
    Set Test Variable    ${nrbts_id}


Step 2: Inject amount of Alarms
    [Documentation]
    ...  Inject a specified number of alarms into the vCU and verify their active status.
    [Arguments]    ${number_of_injected_alarms_TC21}

    Log    Step 2: Inject amount of Alarms to the vCU     console=${True}

    Check active critical alarm summary is equal  0
    Log    Inject ${number_of_injected_alarms_TC21} alarms      console=${True}
    Inject or delete alarms    1
    Check active critical alarm summary is equal  ${number_of_injected_alarms_TC21}

Step 3: Check alarm rate
    [Documentation]
    ...  Verify that the total number of historical alarms in the system matches the expected KPI target.

    Log    Step 3: Check alarm rate    console=${True}
    ${INPUT}=    vcu_admin.get_active_alarms      connection=${vcu_connection}
    ${total}=    Set Variable    ${INPUT['total']}

    ${appear_times}=    Create List
    FOR    ${alarm}    IN    @{INPUT['alarms']}
        ${appear_time}=    Set Variable    ${alarm['appear_time']}
        Append To List    ${appear_times}    ${appear_time}
    END
    ${sorted_times}=    Evaluate    sorted(${appear_times})
    ${earliest}=    Set Variable    ${sorted_times}[0]
    ${latest}=      Set Variable    ${sorted_times}[-1]
    ${earliest_alarm_appere_time}=  Get Time From Date  ${earliest}
    ${latest_alarm_appere_time}=  Get Time From Date  ${latest}
    ${diff}=   Calculate Time Difference  ${earliest_alarm_appere_time}  ${latest_alarm_appere_time}
    ${time_per_alarm}=    Alarm Generation Rate Check    ${diff}    ${number_of_injected_alarms_TC21}

    Run Keyword And Continue On Failure    Should Be True    ${time_per_alarm} < ${KPI_target}
    ...  message=KPI target ${KPI_target}s/alarm now is ${time_per_alarm}s/alarm
    Log    KPIe on target ${time_per_alarm}s/alarm     console=${True}
    Append To List    ${KPI_results}    ${time_per_alarm}

    Run Keyword And Continue On Failure    Should Be True    ${total} == ${number_of_injected_alarms_TC21} and ${diff} < 60
    ...  message=number of alarms should be min ${number_of_injected_alarms_TC21} per minute
    Log    KPIe on target: ${total} alarms was generate in ${diff}s      console=${True}


Step 4: Delete injected amount of Alarms
    [Documentation]
    ...  Delete the previously injected alarms and verify that no critical alarms remain active.
    [Arguments]    ${number_of_injected_alarms_TC21}

    Log    Step 4: Delete injected amount of Alarms     console=${True}

    Log to console    delete ${number_of_injected_alarms_TC21} alarms
    Inject or delete alarms    0
    Check active critical alarm summary is equal    0


Step 5: Calculate Average KPI Result
    [Documentation]    This step calculates the average result of the provided KPI values.
    ...                The average is determined by summing all KPI values and dividing the total by the number of values.

    [Arguments]    ${KPI_results}

    ${total}=    Evaluate    sum(${KPI_results})
    ${count}=    Get Length    ${KPI_results}
    ${KPI_average_result}=    Evaluate    ${total} / ${count}
    Log    The average KPI result is ${KPI_average_result}    console=${True}

Alarm Generation Rate Check
    [Arguments]  ${total_time_seconds}    ${total_alarms}
    ${time_per_alarm}=   Evaluate  ${total_time_seconds} / ${total_alarms}
    [Return]  ${time_per_alarm}

Get Time From Date
    [Arguments]  ${date}
    ${date_without_timezone}=  Get Substring  ${date}  0  26
    ${formatted_date}=  Convert Date  ${date_without_timezone}  %Y-%m-%d %H:%M:%S.%f
    [Return]  ${formatted_date}

Calculate Time Difference
    [Arguments]  ${earliest_alarm_appere_time}  ${latest_alarm_appere_time}
    ${conv_time_0}=   Convert Date    ${earliest_alarm_appere_time}    epoch
    ${conv_time_1}=   Convert Date    ${latest_alarm_appere_time}    epoch
    ${delta_t}=    Evaluate   ${conv_time_1}-${conv_time_0}
    [Return]  ${delta_t}

Inject or delete alarms
    [Documentation]
    ...  This keyword injects or deletes alarms in the vCU system.
    ...  Inject: Adds alarms to the system (inject=1).
    ...  Delete: Removes alarms from the system (delete=0)
    [Arguments]    ${inject_or_delete}

    Run Keyword If    ${inject_or_delete} == 1    Log to console    Injecting alarms
    ...    ELSE IF    ${inject_or_delete} == 0    Log to console    Deleting alarms
    ...    ELSE    Fail    Invalid argument: ${inject_or_delete}. Expected 1 (inject) or 0 (delete).

    ${cmd}=    Catenate    SEPARATOR=
    ...    for ((i=1; i<=${number_of_injected_alarms_TC21}; i++));${SPACE}
    ...    do kubectl exec -n ${CRAN_VCU} -it po-${CRAN_VCU}-oamfm-0 -c ctr-${CRAN_VCU}-oamfm${SPACE}
    ...    -- curl --request POST --url http://oam-faultmanagement:9004/api/fm/v1/faults${SPACE}
    ...    --header \'content-type: application/json\'${SPACE}
    ...    --data "{\\"faultId\\":9001,\\"state\\":${inject_or_delete},\\"severity\\":1,\\"source\\":\\"MRBTS-${MRBTS_ID}\\/NRBTS-
    ...    ${NRBTS_ID}\\/NRCELL-$i\\",\\"sourceType\\":1,\\"extraInfo\\":\\"test-alarm$i\\",\\"recoveryOverride\\":1}";sleep 0.1;done

    ${alias_cu}=    common_vcu.Connect To vCU K8s Master Node With Tenant    0    3600
    Set Test Variable    ${alias_cu}
    ${output}=   issh.Execute    command=${cmd}   alias=${alias_cu}
    common_keywords.Disconnect Interactive Connection    alias=${alias_cu}

Check active critical alarm summary is equal
    [Documentation]
    ...  Validates that the number of active critical alarms matches the expected value.
    [Arguments]  ${expected_number}

    Log    Check active critical alarm summary is equal ${expected_number}   console=${True}
    ${alarms_summary_2}=    vcu_admin.get_active_alarms_summary  connection=${vcu_connection}
    ${critical_value}=    Get From Dictionary    ${alarms_summary_2['severity']}    critical
    Run Keyword And Continue On Failure    Should Be Equal As Numbers    ${critical_value}    ${expected_number}
    Log    Active critical alarm summary is equal ${expected_number}   console=${True}
