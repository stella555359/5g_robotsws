*** Settings ***

Documentation   This is a Robot Test Suite for subfeature 5GC001514 'CPCL crash and recovery'
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
#-------------------------------------------------------------------------------------------------------------

Resource        5GC001514-keywords.robot
Resource        5GC001514-keywords-traffic.robot
Resource        5GC001514-keywords-wireshark.robot

Resource        ../resources/SQD60/keywords-tracing.robot
Resource        ../../resources/Common/reporting.robot


Suite Setup     5GC001514-keywords.Prepare TL
Suite Teardown  Suite Teardown CPCL

*** Variables ***

${tcpdump_running}      false
${container}            0x2512
${kill_cmd}             pkill -15 cp_cl

${ue_id}                151
${cell_id}              3

*** Test Cases ***

5GC001514_CPCL_crash_and_recovery
    [Documentation]    This Test Scenario verifies that CPCL is successfully restarted after crash

    [Setup]    Perform Test Setup CPCL

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Start

    5GC001514-keywords.Set CPCL actForceUnitAutoReset To False
    5GC001514-keywords.Attach UE And Run Traffic

    Crash CPCL Process And Wait For Cell onAir
    5GC001514-keywords.Trigger sgNBaddition And Run Traffic

    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Stop

    5GC001514-keywords-traffic.Verify Traffic Statistics After Crash
    5GC001514-keywords-wireshark.Verify Wireshark Cell Not Available
    5GC001514-keywords-wireshark.Verify Wireshark ENDCX2SetupResponse CPCL
    5GC001514-keywords-wireshark.Verify Wireshark NGSetupRequest CPCL
    [Teardown]   Perform Test Teardown CPCL


*** Keywords ***

Perform Test Setup CPCL
    [Documentation]    [PRIVATE]    perform test setup
    ...       :Autor: Sylvia Schneider
    keywordbook-480.Create a Test Scenario Folder
    ute_workarounds.Bring Airphone TL To On Air Status


Suite Teardown CPCL
    [Documentation]    [PRIVATE]    Suite Teardown CPCL
    ...       :Autor: Sylvia Schneider
    wts_ue.Reload Stored WTS Config


Perform Test Teardown CPCL
    [Documentation]    [PRIVATE]    perform test teardown with saving logs
    ...       :Autor: Sylvia Schneider
    reporting.Set SCOUT TC ID for Reporting
    5GC001514-keywords.Stop Tcpdump Recording
    keywords-tracing.End Dcap Tracing And Collect Traces
    wts_ue.Teardown Egate Connection for Airphone
    wts_ue.Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}


Crash CPCL Process And Wait For Cell onAir
    [Documentation]    [PRIVATE]   crash CPCL process, wait for commissioned, wait for cell onAir
    ...     :Autor: Sylvia Schneider
    5GC001514-keywords.Start Tcpdump Recording
    Kill Process CPCL
    5GC001514-keywords.Check gNB onAir
    5GC001514-keywords.Stop Tcpdump Recording


Kill Process CPCL
    [Documentation]    [PRIVATE]   kill CPCL process
    ...     :Autor: Sylvia Schneider

    ${gNBCommUnit_alias}    Wait Until Keyword Succeeds
    ...    ${SSH_AUTHENTICATION_TIMEOUT}   ${SSH_AUTHENTICATION_RETRY_INTERVAL}
    ...    connect.Connect to Node Common Unit
    Sleep    2s
    Start Ssh Session For Containter Login And Kill Cmd   ${gNBCommUnit_alias}
    ssh.Disconnect   connection=${gNBCommUnit_alias}

    Wait for Node state   target_proceduralState=commissioned


Start Ssh Session For Containter Login And Kill Cmd
    [Documentation]    [PRIVATE]   start ssh session to specified address
    ...     :Autor: Sylvia Schneider
    [Arguments]     ${gNBCommUnit_alias}
    ${cmd}   Set Variable   lxc-attach -n ${container}
    Log To Console    \nattach to container in which cpcl is running with command ${cmd}
    ssh.Send Command    command=${cmd}    timeout=60s     get_pty=True   connection=${gNBCommUnit_alias}
    Sleep    1s
    ${output}    ssh.Read Output Until   ${SPACE}>    timeout=10   connection=${gNBCommUnit_alias}

    Log To Console    CPCL crash executed with ${kill_cmd}
    Run Keyword And Ignore Error    ssh.Write Input    ${kill_cmd}${\n}    connection=${gNBCommUnit_alias}
    ${output}    ssh.Read Output Until   ${SPACE}>    timeout=10   connection=${gNBCommUnit_alias}
    Sleep    2s
