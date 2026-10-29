# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation   This contains keywords needed for coam
Library    BuiltIn
Library    DateTime
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    ${CURDIR}/python_keywords.py
Library    taf.gnb.oam.coam.cu    WITH NAME    coam_cu

*** Variables ***
${TL_CONFIG_DIR}    /home/ute/testline_update_results/commissionings/
${gNB_Check_Timeout}    10min

*** Keywords ***
Get Coam Active Alarms
    CoamAdmin.Connect To
    ${alarms}     CoamAdmin.Get Active Alarms
    [Return]    ${alarms}
    [Teardown]    CoamAdmin.Teardown

Get Coam SCF
    Set Suite Variable    ${coamSCF}    ${EXECDIR}/logs/gnb_coam_scf.xml
    ${path}                           ${file}    Split Path    ${coamSCF}
    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
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
    CoamAdmin.Get Snapshot    target_file_name=${EXECDIR}/${ymlUteGnbLogDir}[root]/snapshot_coam.zip
    ...                       timeout=20 mins
    File Should Exist         ${EXECDIR}/${ymlUteGnbLogDir}[root]/snapshot_coam.zip
    [Teardown]    CoamAdmin.Teardown

Reset Coam Site
    CoamAdmin.Connect To
    CoamAdmin.Reset Site
    [Teardown]    CoamAdmin.Teardown

Wait Coam Site to be Ready
    [Arguments]    ${timeout}=${gNB_Check_Timeout}
    Log to Console                 Waiting for gNB to be ready... (${timeout} timeout)
    Wait Until Keyword Succeeds    ${timeout}    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Set Variable SUITE_CFG_DIR
##    RAT Block Unblock
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam BTS is Configured
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam Radio is Online
##    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam Cell is Configured
    Sleep                          30s    reason=problems with cell setup on AP
    [Teardown]    CoamAdmin.Teardown

Verify Coam BTS is Configured
    ${bts_state}                  CoamAdmin.Get Mrbts State
    Log to Console                [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    Configured    IntegratedToRan    onAir    ignore_case=${TRUE}

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
    [Documentation]    stream_nr and suite_cfg_dir variables depends on the loads
    ...                If SBTS load: SBTSXX_ENB_YYYY_DDDD_VVVV (standard form) where YYYY = 9999 (reserved for trunk),
    ...                YYYY = other values for branch; list_index=2 (used for identification of load).
    ...                list_index[2]=9999, then stream_nr=SBTS00 else if list_index[2]=0000/0100 then stream_nr=SBTSXX
    ...                else stream_nr will get assigned with perticular trunk or branch load.
    ${sw_version}                 CoamAdmin.get_sw_version
    @{sw_version_list}=           Split String    ${sw_version}    separator=_
    ${stream_nr}=    Run Keyword if    "SBTS" in "${sw_version_list}[0]"
    ...              Set Variable if    "${sw_version_list}[2]"=="9999" or "${sw_version_list}[2]"=="9000" or "${sw_version_list}[0]"=="SBTS22R4"
    ...                                 SBTS00    ${sw_version_list}[0]
    ...              ELSE    python_keywords.parse_sw_to_stream    ${sw_version}
    ${SUITE_CFG_DIR}              Catenate    SEPARATOR=/    ${SUITE_CFG_DIR_tmp}    ${stream_nr}
    Set Global Variable           ${SUITE_CFG_DIR}
    Set Global Variable           ${stream_nr}

Get SCF and Snapshot from CU
    [Arguments]    ${path}=/tmp/snapshot_CU
    Open COAM Connection
    Log To Console                Collecting Snapshot from CU
    ${timestamp}                  Get Current Date    result_format=%d.%m_%H-%M
    Run                           mkdir ${path}
    coam_cu.get_local_snapshot    directory=${path}
    Run                           cd ${path}; tar czf Snapshot_CU_${timestamp}.tgz *.*
    Run                           cp ${path}/Snapshot_CU* ${EXECDIR}/logs/
    Run                           rm -rf ${path}/Snapshot*
    Log To Console                CU Snapshot Collected successfully...
    Set Suite Variable            ${CU_SCF}    ${EXECDIR}/logs/CU_scf.xml
    coam_cu.get_current_plan_file    ${CU_SCF}    timeout=100s
    Log To Console                CU SCF collected successfully...
    [Teardown]                    coam_cu.disconnect

Open COAM Connection
    [Arguments]         ${host}=192.168.125.10
    ...                 ${port}=${EMPTY}
    ...                 ${username}=Nemuadmin
    ...                 ${password}=nemuuser
    ...                 ${cu_version}=cuoam_19b
    ...                 ${secure}=${TRUE}
    Wait Until Keyword Succeeds    5min    20s    coam_cu.connect_to
    ...                 ${host}    ${port}    ${username}    ${password}    ${cu_version}    ${secure}
