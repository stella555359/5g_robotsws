# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Library    BuiltIn
Library    DateTime
Library    OperatingSystem
Library    taf.gnb.oam.coam.admin    WITH NAME    CoamAdmin
Library    ${CURDIR}/python_keywords.py


*** Keywords ***
Get Coam Active Alarms
    CoamAdmin.Connect To
    ${alarms}     CoamAdmin.Get Active Alarms
    [Return]    ${alarms}
    [Teardown]    CoamAdmin.Teardown

Get Coam SCF
    ${coamSCF}                        Set Variable    ${EXECDIR}/logs/gnb_coam_scf.xml
    ${path}                           ${file}    Split Path    ${coamSCF}
    CoamAdmin.Connect To
    CoamAdmin.Get Current Scf File    ${path}    ${file}
    File Should Exist                 ${coamSCF}
    [Teardown]    CoamAdmin.Teardown

Get Coam BTS Information
    CoamAdmin.Connect To
    ${result}     CoamAdmin.Get Bts Info
    [Return]    ${result}
    [Teardown]    CoamAdmin.Teardown

Get Coam Snapshot
    [Timeout]    25 minutes
    CoamAdmin.Connect To
    CoamAdmin.Get Snapshot    target_file_name=${EXECDIR}/&{ymlUteGnbLogDir}[root]/snapshot_coam.zip
    ...                       timeout=20 mins
    File Should Exist         ${EXECDIR}/&{ymlUteGnbLogDir}[root]/snapshot_coam.zip
    [Teardown]    CoamAdmin.Teardown

Reset Coam Site
    CoamAdmin.Connect To
    CoamAdmin.Reset Site
    [Teardown]    CoamAdmin.Teardown

Wait Coam Site to be Ready
    Log to Console                 Waiting for gNB to be ready... (15min timeout)
    CoamAdmin.Connect To
    Set Variable SUITE_CFG_DIR
    Wait Until Keyword Succeeds    15min    30sec    Verify Coam BTS is at least Configured
    Wait Until Keyword Succeeds    15min    30sec    Verify Coam Radio is Online
    Wait Until Keyword Succeeds    15min    30sec    Verify Coam Cell is Configured
    Sleep                          30s    reason=problems with cell setup on AP
    [Teardown]    CoamAdmin.Teardown

Verify Coam BTS is at least Configured
    ${bts_state}                  CoamAdmin.Get Mrbts State
    Log to Console                [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    Configured    IntegratedToRan    onAir    ignore_case=${TRUE}

Verify Coam BTS is onAir
    ${bts_state}                  CoamAdmin.Get Mrbts State
    Log to Console                [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    onAir    ignore_case=${TRUE}

Verify Coam Radio is Online
    ${bts_hw_info}                CoamAdmin.Get Bts Info
    ${radio_state}                Set Variable
    ...                           ${bts_hw_info['radioModules']['rmod'][0]['status']['operationalState']}
    Log to Console                [INFO] RADIO STATE : ${radio_state}
    Should Be Equal As Strings    ${radio_state}    enabled    ignore_case=${TRUE}

Verify Coam Cell is Configured
    ${cells_info}                 CoamAdmin.Get Cells Info
    ${procedural_status}          Set Variable    ${cells_info[0]['status']['proceduralStatus']}
    Log to Console                [INFO] CELL STATE : ${procedural_status}
    Should Contain Any            ${procedural_status}    Configured    onAir    ignore_case=${TRUE}

Set Variable SUITE_CFG_DIR
    ${sw_version}                 CoamAdmin.get_sw_version
    @{version}=  Split String  ${sw_version}  separator=\_
    ${branch}=  Set Variable  @{version}[0]
    ${stream_nr}                  python_keywords.parse_sw_to_stream    ${sw_version}
    Convert To String  ${stream_nr}
    ${stream_common}=    Run Keyword And Return Status    Should Contain  ${stream_nr}  9999
    Run Keyword If  ${stream_common}  Set Suite Variable  ${stream_nr}    SBTS00
    ...   ELSE   Set Suite Variable  ${stream_nr}    ${branch}
    ${SUITE_CFG_DIR}              Catenate    SEPARATOR=/    ${SUITE_CFG_DIR_tmp}    ${stream_nr}
    Set Global Variable           ${SUITE_CFG_DIR}
    Set Global Variable           ${stream_nr}

