*** Settings ***
Documentation    First version of simple test to run test with throughput on UE on wall
Resource    ../../Resources/ue_keywords/ue_keywords.robot
Resource    ../../Resources/cm_operations/cm_operations.robot
Resource    ../../Resources/logs_collecting/logs_collecting.robot
Library    OperatingSystem
Library    String
Library    ../../Resources/calient/calient.py
Library    ../../Resources/scurve/scurve.py
Library    ../../Resources/cm_operations/SwUpdate.py
Variables    scurve_resources/wall_tests.py

#Suite Setup    Run Keywords    Prepare Calient Connections
#    ...        AND    Sleep    60s
#    ...        AND    Check If Fid23 Is Active And Update Sw
Suite Setup    Run Keywords    Sleep    60s
    ...        AND    Check If Fid23 Is Active And Update Sw
Test Teardown     Collect Snapshot
#Suite Teardown    Clean And Restore Calient Connections

*** Variables ***
&{APOLLO_UE}=    ASKEY_23_APOLLO=A_UE
${DL_TPUT}=    1600
${UL_TPUT}=    300
${TEST_ITERATIONS}=    1
${TEST_SCENARIO}=    default
${TOOL}=    tti_only
${CELL_ID}=    203
${SYSLOG}=    false
${TIMEOUT}=    600

*** Test Cases ***
S-Curve Test In Loop
    [Tags]    manual
    #Wait For Cell To Be OnAir   id=204
    Sleep    60s
    ${content}    Get File    /home/ute/testline_init_results/taf_agents_logs/agent_taf.txt
    ${VM_PASSWORD}    Get Regexp Matches    ${content}    (?<=CM_PASSWORD": ").+?(?=")
    Set Test Variable    ${VM_PASSWORD}    ${VM_PASSWORD[0]}
    Prepare Ues    ${APOLLO_UE}    attach=${True}    detach=${False}
    FOR    ${iteration}    IN RANGE    0    ${TEST_ITERATIONS}
        S-Curve Test
    END

*** Keywords ***
S-Curve Test
    ${TEST_SCENARIO}=    Run Keyword If     '${TEST_SCENARIO}'=='WALL_SUBBAND_ANTS'
    ...    Set Variable    ${wall_subband_ants}
    ...    ELSE IF    '${TEST_SCENARIO}'=='WALL_DFT_ANTS'
    ...    Set Variable    ${wall_dft_ants}
    ...    ELSE
    ...    Set Variable    default
    ${apollo_ue_info}=    Get Ue Info    A_UE
    Log    ${apollo_ue_info}
    Start Tput    A_UE    A_UE_tput    ${DL_TPUT}    ${UL_TPUT}    ${TIMEOUT}s    apn=5gwrowpt1
    Start Scurve Test    ${CURDIR}/scurve_resources/ni_data.json
    ...     AUTO_APOLLO
    ...     ${TOOL}
    ...     ${SYSLOG}
    ...     ${VM_PASSWORD}
    ...     ${CELL_ID}
    ...     ${TEST_SCENARIO}
    ...     ${TIMEOUT}
    [Teardown]    Run Keywords    Stop Data Transfer For All Ues    AND    Sleep    60s
