# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation     This contains common keywords which are needed for ADMIN CLI operations

Library    BuiltIn
Library    DateTime
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    ${CURDIR}/python_keywords.py
Library    taf.gnb.oam.coam.cu    WITH NAME    coam_cu
Library    taf.gnb.oam.coam.vdu    WITH NAME    vDU

*** Variables ***
${TL_CONFIG_DIR}        /home/ute/testline_update_results/commissionings/
${gNB_Check_Timeout}    5min
${vDU_Password}         Nokia@123
${vCU_Password}         Nokia@123

*** Keywords ***
Get Coam Active Alarms
    CoamAdmin.Connect To
    ${alarms}     CoamAdmin.Get Active Alarms
    [Return]    ${alarms}
    [Teardown]    CoamAdmin.Teardown

Get Coam SCF
    Set Suite Variable    ${coamSCF}    ${vm_logdir}/gnb_coam_scf.xml
    ${path}                           ${file}    Split Path    ${coamSCF}
    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    CoamAdmin.Get Current Scf File    ${path}    ${file}    timeout=300
    File Should Exist                 ${coamSCF}
    [Teardown]    CoamAdmin.Teardown

Get Coam BTS Information
    CoamAdmin.Connect To
    ${result}     CoamAdmin.Get Bts Info
    [Return]    ${result}
    [Teardown]    CoamAdmin.Teardown

Collect gNB Snapshot via adminAPI
    [Timeout]    25 minutes
    Log To Console    Collecting gNB Snapshot via admin API
    ${timestamp}                  Get Current Date    result_format=%d.%m_%H-%M
    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    CoamAdmin.Get Snapshot    target_file_name=${vm_logdir}/Snapshot_MRBTS-1_${timestamp}.zip
    ...                       timeout=20 mins
    File Should Exist         ${vm_logdir}/Snapshot_MRBTS-1_${timestamp}.zip
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
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam BTS is Configured
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam Radio is Online
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

Verify VDU BTS is Configured
    ${vdu_data}       vDU.get_vdu_state_data
    ${bts_state}      set variable    ${vdu_data['operational_state']}
    Log To Console    ${bts_state}

Verify RMOD Status On Vdu
    ${RU_info}=  vDU.Get_Rmods_Status
    Log To Console     ${RU_info[0]["operational_state"]}
    Should Be Equal    ${RU_info[0]["operational_state"]}   enabled

Verify vDU Cell is Configured
    ${cell_info}     vDU.get_vdu_cells_status
    ${cell_state}    set variable    ${cell_info[0]['procedural_status']}
    Should Contain Any    ${cell_state}    Configured    onAir    ignore_case=${TRUE}

VDU Login
    vDU.connect_to    host=192.168.255.129     port=443    secure=True    username=Nemuadmin    password=${vDU_Password}    secure=True

VDU Logout
    vDU.disconnect

Wait VDU Site to be Ready
    [Arguments]    ${timeout}=${gNB_Check_Timeout}
    Log to Console                 Waiting for gNB to be ready... (${timeout} timeout)
    Wait Until Keyword Succeeds    ${timeout}    30sec    VDU Login
    Set Variable SUITE_CFG_DIR VDU
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify VDU BTS is Configured
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify RMOD Status On Vdu
    Sleep                          30s    reason=problems with cell setup on AP
    [Teardown]    VDU Logout

Set Variable SUITE_CFG_DIR VDU
    ${vdu_data}                   vDU.get_vdu_state_data
    ${sw_version}       set variable    ${vdu_data['software_version']}
    Log To console          ${sw_version}
    @{sw_version_list}=           Split String    ${sw_version}    separator=_
    ${stream_nr}=    Run Keyword if    "SBTS" in "${sw_version_list}[0]"
    ...              Set Variable if    "${sw_version_list}[2]"=="9999" or "${sw_version_list}[2]"=="9000" or "${sw_version_list}[0]"=="SBTS22R4"
    ...                                 SBTS00    ${sw_version_list}[0]
    ...              ELSE    python_keywords.parse_sw_to_stream    ${sw_version}
    ${SUITE_CFG_DIR}              Catenate    SEPARATOR=/    ${SUITE_CFG_DIR_tmp}    ${stream_nr}
    Set Global Variable           ${SUITE_CFG_DIR}
    Set Global Variable           ${stream_nr}      0.300

Set Variable SUITE_CFG_DIR
    [Documentation]    stream_nr and suite_cfg_dir variables depends on the loads
    ...                If SBTS load: SBTSXX_ENB_YYYY_DDDD_VVVV (standard form) where YYYY = 9999 (reserved for trunk),
    ...                YYYY = other values for branch; list_index=2 (used for identification of load).
    ...                list_index[2]=9999, then stream_nr=SBTS00 else if list_index[2]=0000/0100 then stream_nr=SBTSXX
    ...                else stream_nr will get assigned with perticular trunk or branch load.
    ${sw_version}                 CoamAdmin.get_sw_version
    @{sw_version_list}=           Split String    ${sw_version}    separator=_
    ${stream_num}=   Run Keyword And Return Status   BuiltIn.Should Start With   ${sw_version_list}[2]   9
    ${stream_nr}=    Run Keyword if    "SBTS" in "${sw_version_list}[0]"
    ...              Set Variable if    "${stream_num}"=="True"   SBTS00    ${sw_version_list}[0]
    ...              ELSE    python_keywords.parse_sw_to_stream    ${sw_version}
    ${SUITE_CFG_DIR}              Catenate    SEPARATOR=/    ${SUITE_CFG_DIR_tmp}    ${stream_nr}
    Set Global Variable           ${SUITE_CFG_DIR}
    Set Global Variable           ${stream_nr}

Get SCF and Snapshot from CU
    [Arguments]    ${path}=/tmp/snapshot_CU
    [Timeout]    15 min
    Open COAM Connection
    Run Keyword If    '${vRAN_Snapshot_Flag}' != 'False'    Collect CU Snapshot    ${path}
    ...    ELSE    Log To Console    CU Snapshot collection skipped...
    Set Suite Variable            ${CU_SCF}    ${EXECDIR}/logs/CU_scf.xml
    coam_cu.get_current_plan_file    ${CU_SCF}    timeout=100s
    Log To Console                CU SCF collected successfully...
    Collect SCF and Snapshot from vDU
    [Teardown]                    coam_cu.disconnect

Open COAM Connection
    [Arguments]         ${host}=192.168.100.129
    ...                 ${port}=${EMPTY}
    ...                 ${username}=Nemuadmin
    ...                 ${password}=${vCU_Password}
    ...                 ${cu_version}=cuoam_19b
    ...                 ${secure}=${TRUE}
    Wait Until Keyword Succeeds    5min    20s    coam_cu.connect_to
    ...                 ${host}    ${port}    ${username}    ${password}    ${cu_version}    ${secure}

Collect SCF and Snapshot from vDU
    Create Directory               ${EXECDIR}/logs
    Set Suite Variable            ${vDU_SCF}    ${EXECDIR}/logs
    VDU Login
    vDU.get_current_plan_file    ${vDU_SCF}    vDU_scf.xml    timeout=100s
    Log To Console                vDU SCF collected successfully...
    Run Keyword If    '${vRAN_Snapshot_Flag}' != 'False'    Collect vDU Snapshot
    ...    ELSE    Log To Console    vDU Snapshot collection skipped...
    [Teardown]         VDU Logout

Collect CU Snapshot And SCF
   Run Keyword And Ignore Error    Get SCF and Snapshot from CU

Get Cell Info for Classical
    [Documentation]    This Keyword provides the states of the cell
    Wait Until Keyword Succeeds    ${timeout}    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    ${cell_info}    CoamAdmin.get_cells_info
