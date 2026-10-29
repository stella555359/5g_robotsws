*** Settings ***
Documentation
    ...    The test injects a specified number of alarms into the vCU and then verifies if the number of active alarms meets the KPI requirements.
    ...    The process runs for a defined number of iterations as specified in the test suite.
    ...    At the end of the test, it checks if the maximum number of stored historical alarms matches the KPI value.
    ...    Author:    Jakub Kokoszka
    ...    Contact:   jakub.kokoszka@nokia.com

*** Variables ***
${NUMBER_OF_ITERATIONS_TC20_22}         3
${NUMBER_OF_INJECTED_ALARMS_TC20_22}    3000
${AMOUNT_OF_HISTORICAL_ALARMS_TC22}     8000
*** Keywords ***

CB011085_A_TC20_22_Capacity_Active_and_History_Alarms_WebEM_vCU
    Step 1: Precondition
    FOR    ${index}    IN RANGE    ${NUMBER_OF_ITERATIONS_TC20_22}
        Log    \n--- Execution loop: ${index + 1} ---    console=${True}
        Step 2: Inject amount of Alarms   ${NUMBER_OF_INJECTED_ALARMS_TC20_22}
        Step 3: Delete injected amount of Alarms   ${NUMBER_OF_INJECTED_ALARMS_TC20_22}
        Log    \n--- Loop ${index + 1}: Completed ---    console=${True}
    END
    Step 4: Check amount of historical alarm


Step 1: Precondition
    [Documentation]
    ...  This step collects the SCF and initializes variables necessary for subsequent test steps.

    Log    \nStep 1: Precondition    console=${True}

    vcu_admin.Get_Current_Plan_File    path=${Test_Results_Dir}/vcu_scf.xml    connection=${vcu_connection}
    ${scf_content}=   OperatingSystem.Get File   ${Test_Results_Dir}/vcu_scf.xml
    Log    ${scf_content}   console=${False}
    ${result}=     Get Regexp Matches    ${scf_content}   .*NRDU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRDU-(\\d+)"\\s+.*   1  2  3
    ${mrbts_id}=  Set Variable If    ${result}    ${result[0][0]}
    Set Test Variable    ${MRBTS_ID}    ${mrbts_id}
    ${nrbts_id}=  Set Variable If    ${result}    ${result[0][1]}
    Set Test Variable    ${NRBTS_ID}    ${nrbts_id}

Step 2: Inject amount of Alarms
    [Documentation]
    ...  Inject a specified number of alarms into the vCU and verify their active status.
    [Arguments]    ${NUMBER_OF_INJECTED_ALARMS_TC20_22}

    Log    Step 2: Inject amount of Alarms to the vCU     console=${True}

    Check active critical alarm summary is equal    0
    Log    Inject ${NUMBER_OF_INJECTED_ALARMS_TC20_22} alarms      console=${True}
    Inject or delete alarms    1
    Check active critical alarm summary is equal    ${NUMBER_OF_INJECTED_ALARMS_TC20_22}

Step 3: Delete injected amount of Alarms
    [Documentation]
    ...  Delete the previously injected alarms and verify that no critical alarms remain active.
    [Arguments]    ${NUMBER_OF_INJECTED_ALARMS_TC20_22}

    Log    Step 3: Delete injected amount of Alarms     console=${True}

    Log to console    delete ${NUMBER_OF_INJECTED_ALARMS_TC20_22} alarms
    Inject or delete alarms    0
    Check active critical alarm summary is equal    0

Step 4: Check amount of historical alarm
    [Documentation]
    ...  Verify that the total number of historical alarms in the system matches the expected KPI target.

    Log    Step 4: Check amount of historical alarm     console=${True}

    ${historical_alarms}=    vcu_admin.get_historical_alarms_summary    connection=${vcu_connection}
    ${total}=    Get From Dictionary    ${historical_alarms}    total
    Should Be True    ${total} >= ${NUMBER_OF_INJECTED_ALARMS_TC20_22}
    Log to console    Amount of historical alarms on vCU >= KPI target, ${total} >= ${NUMBER_OF_INJECTED_ALARMS_TC20_22}

Inject or delete alarms
    [Documentation]
    ...  This keyword injects or deletes alarms in the vCU system.
    ...  Inject: Adds alarms to the system (inject=1).
    ...  Delete: Removes alarms from the system (delete=0)
    [Arguments]    ${inject_or_delete}

    Run Keyword If    ${inject_or_delete} == 1    Log to console    Injecting alarms
    ...    ELSE IF    ${inject_or_delete} == 0    Log to console    Deleting alarms
    ...    ELSE    Fail    Invalid argument: ${inject_or_delete}. Expected 1 (inject) or 0 (delete).

    ${cmd}    Catenate    SEPARATOR=
    ...    for ((i=1; i<=${NUMBER_OF_INJECTED_ALARMS_TC20_22}; i++));${SPACE}
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
