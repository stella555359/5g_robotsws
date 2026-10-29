*** Settings ***
Documentation       this file contains all keywords which will run in testsuit.
Library     python_keywords.py

Resource     ../Variables/common_variables.robot
Resource        ../Keywords/common_keywords.robot
Resource        ../../../resources/Keywords/generic_kw.robot
Resource        ../../../resources/Keywords/gnb_Keywords.robot
Resource        ../../../resources/Keywords/ap_Keywords.robot

*** Keywords ***
Common Optimized Suite Setup
    Get AP Suite Configuration Variables
    Get Component Carrier Variables
    Wait Coam Site to be Ready
    Check for 6765-D feature enabled and Verify DCI
    Modify UTE SCTP Timeout
    ${start_time}   Run Keyword And Ignore Error    Get Current Date
    Set Suite Variable    ${start_time}
    Create Basic Interface on UTE
    Backup Scf     /home/ute/Downloads      Original

Get AP Suite Configuration Variables
    [Documentation]    This keyword will identify the variables related to ap_configurations
    ${var}=    Get Variable Value    ${TOPOLOGY}
    ${var_exists}=      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Run Keyword If    '${var_exists}' == 'False'
    ...   Get AP Suite Configuration From File   ELSE
    ...   Set AP Suite Configuration Variables   ${TOPOLOGY}

get Component Carrier Variables
    ${var}=    Get Variable Value    ${COMPONENT_CARRIER}
    ${var_exists}=      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Run Keyword If    '${var_exists}' == 'False'
    ...   Get Component Carrier Value From File   ELSE
    ...   Set Component Carrier Variables    ${COMPONENT_CARRIER}

Set AP Suite Configuration Variables
    [Arguments]    ${TOPOLOGY}
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${${TOPOLOGY}}
    ${error}=    Catenate    User has passed wrong <TOPOLOGY> value. \n(OR)\n
                     ...   Mapping details is not defined for topology '${TOPOLOGY}' in common_variables file.
    Run Keyword If    '${status}' == 'FAIL'    FAIL    ${error}
    Set Suite Variable    ${TOPOLOGY}    ${TOPOLOGY}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    ${status}   ${value}=    Run Keyword And Ignore Error    Get Param Value From File    ${test_property_file}
    ...    variant_name=(\\S+)
    Run Keyword If    '${status}' == 'PASS'    Set Suite Variable    ${variant_name}    ${value}
    ...   ELSE   Set Suite Variable    ${variant_name}    ${variant_name}

Get Param Value From File
    [Arguments]    ${file_path}    ${search_string}
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${matched_value}    Should Match Regexp        ${file_content}    ${search_string}
    Log   ${matched_value[1]}
    [Return]    ${matched_value[1]}

Common Suite Teardown
    [Documentation]    This keyword is used to stop the Log collection at the end of the Suite
    ...                Teardowns the Edaemon and Egate process at the end of suite
    Run Keyword and Ignore Error     Teardown Edaemon and Egate process
    ${gNB_status}    Run Keyword And Return Status    Wait Coam Site to be Ready
    LOG TO CONSOLE     ${gNB_status}

Teardown Edaemon and Egate process
    [Documentation]    kill running Edaemon and Egate process
    wtsrunner.kill_wtsemu_edaemon    edaemon_port=22222   connection=${WTS.Connection}    sudo_password=ute
    sleep      5s
    wtsrunner.kill_wtsemu_egate      egate_port=20000     connection=${WTS.Connection}    sudo_password=ute

Update ueids for Combo MultiUE
    [Arguments]    ${ue_count}
    ${sa_ueids_val}=    Get Variable Value    ${sa_combo_mue_ueids}
    ${nsa_ueids_val}=    Get Variable Value    ${nsa_combo_mue_ueids}
    ${lte_ueids_val}=    Get Variable Value    ${lte_combo_mue_ueids}
    @{sa_ueids}=   Create List
    @{nsa_ueids}=   Create List
    @{lte_ueids}=   Create List
    FOR    ${value}    IN RANGE    ${ue_count}
       Append To List    ${sa_ueids}   ${value+51}
       Append To List    ${nsa_ueids}   ${value+21}
       Append To List    ${lte_ueids}   ${value+1}
    END
    RUN KEYWORD AND IGNORE ERROR    ${sa_ueids}=    Override Test Variables with Default Variables    ${sa_ueids_val}    ${sa_ueids}
    RUN KEYWORD AND IGNORE ERROR    ${nsa_ueids}=    Override Test Variables with Default Variables    ${nsa_ueids_val}    ${nsa_ueids}
    RUN KEYWORD AND IGNORE ERROR    ${lte_ueids}=    Override Test Variables with Default Variables    ${lte_ueids_val}    ${lte_ueids}
    Set Suite Variable    @{sa_ueids}
    Set Suite Variable    @{nsa_ueids}
    Set Suite Variable    @{lte_ueids}

Override Test Variables with Default Variables
   [Arguments]    ${variable_value}    ${generated_value}
   Return From Keyword If      '${variable_value}' == 'None'    ${generated_value}
   @{temp_list}=    Split String    ${variable_value}    ,
   [Return]    ${temp_list}

Append Test Property File For UE_IDs
   ${status}   Run Keyword And Return Status    File Should Exist    ${test_property_file}
   Run Keyword If    '${status}' == 'True'     Update Property File For UE_ID Values

Wait Coam Site to be Ready
    [Arguments]    ${timeout}=${gNB_Check_Timeout}
    Log to Console                 Waiting for gNB to be ready... (${timeout} timeout)
    Wait Until Keyword Succeeds    ${timeout}    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Set Variable SUITE_CFG_DIR
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam BTS is Configured
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam Radio is Online
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam Cell is Configured
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

Verify DCI Link Files
    [Arguments]    ${connection}
    FOR    ${index}    IN    @{CONN_CARDS}
        SSH.Send Command    ${index}    connection=${connection}
        ${status}    SSH.Assert File Exists    ${syscom_file}    ${connection}
        Run Keyword If    ${status}    Fail    msg= DCI file not exists
    END

Verify AP DCI Link Files
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    Verify DCI Link Files    ${AP_ASIK}[Connection]
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    ${AP_ASIK}[Connection]

Check for 6765-D feature enabled and Verify DCI
    Run Keyword And Ignore Error    Run    mkdir -p ${EXECDIR}/logs
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...               alias=${GNB_ASIK.Connection}
    SSH.Download File    /ffs/run/swconfig.txt    ${EXECDIR}/logs/swconfig_gnb.txt
    ...               ${GNB_ASIK.Connection}
    SSH.Disconnect    ${GNB_ASIK.Connection}
    ${status}     Run    grep "^0x20109=1" ${EXECDIR}/logs/swconfig_gnb.txt | cut -d" " -f1
    ${6765D_status}    Run Keyword And Return Status    Should Not Be Equal    "${status}"    "0x20109=1"    msg=6765-D feature is enabled!
    Run Keyword If    ${6765D_status}    Verify Syscom routes and DCI files    ELSE    Verify AP DCI Link Files

Verify Syscom routes and DCI files
    Wait Until Keyword Succeeds    10min    60sec    Verify cOAM Syscom Routes and DCI
    log    system routes and dci check

Verify cOAM Syscom Routes and DCI
    Run Keyword If    '${ap_sm_hardware}' == 'ASIK'    Verify AP DCI Link Files
    Run Keyword If    '${gnb_sm_hardware}' == 'ASIK'    Verify gnb DCI and Syscom routes

Verify gnb DCI and Syscom routes
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    Verify DCI Link Files    ${GNB_ASIK}[Connection]
    Verify Syscom Routes for GNB
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    ${GNB_ASIK}[Connection]

Verify Syscom Routes for GNB
    ${result}         SSH.Execute   bsh 1:0 "echo "syscom -p 0x573a 10 10" | nc 0 15007"
    ...               ${GNB_ASIK}[Connection]
    Should Contain    ${result}    Total time to send/receive 10 mesages
    ...               msg=Error in GNB Syscom Routes!

Modify UTE SCTP Timeout
    [Documentation]    Starting AirPhone load 4.0.10852, the sack timeout in the WTS VM and AP ASIK must be
    ...                configured before cell setup. This aims to prevent delayed messaging between AirPhone
    ...                and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...               alias=${AP_ASIK.Connection}
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...               sysctl -w net.sctp.rto_min=200 &&
    ...               sysctl -w net.sctp.rto_initial=200 &&
    ...               sysctl -w net.sctp.rto_max=800
    SSH.Execute       ${command}    ${AP_ASIK.Connection}
    SSH.Disconnect    ${AP_ASIK.Connection}

Get PROPERTY File Data
    [Arguments]    ${file_path}
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${topology}    Should Match Regexp        ${file_content}    NODE_TOPOLOGY=(\\S+)
    Log   JENKINS_RUN_TOPOLOGY=${topology[1]}
    Set AP Suite Configuration Variables    ${topology[1]}

Get INFO File Data
    [Arguments]    ${file_path}
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${topology}    Should Match Regexp        ${file_content}    LABEL:\\s+(\\S+)
    Log   SINGLE_RUNS_TOPOLOGY=${topology[1]}
    Set AP Suite Configuration Variables    ${topology[1]}

Get AP Suite Configuration From File
    ${status}   Run Keyword And Return Status    File Should Exist    ${test_property_file}
    Run Keyword If    '${status}' == 'True'    Get PROPERTY File Data    ${test_property_file}
    Return From Keyword If    '${status}' == 'True'
    ${status}   Run Keyword And Return Status    File Should Exist    ${single_run_info_file}
    Run Keyword If    '${status}' == 'True'    Get INFO File Data    ${single_run_info_file}
    Return From Keyword If    '${status}' == 'True'
    Run Keyword If    '${status}' == 'False'    FAIL   TOPOLOGY:<TOPOLOGY_VALUE> Test Variable is Expected.

Get Component Carrier Value From File
    [Documentation]    Keyword is used to fetch the component_carrier parm value from test properties
    ${result}   ${value}=    Run Keyword And Ignore Error    Get Param Value From File    ${test_property_file}
    ...    component_carrier=(\\d+)
    Run Keyword If    '${result}' == 'PASS'     Set Component Carrier Variables    component_carrier=${value}
    Return From Keyword If    '${result}' == 'PASS'
    Run Keyword If    '${result}' == 'FAIL'    Set Default Component Carrier Value

Set Default Component Carrier Value
   Log    COMPONENT_CARRIER details not found, so setting to default 1.
   Set Component Carrier Variables   component_carrier=1

Set Component Carrier Variables
    [Arguments]    ${component_carrier}
    ${status}    Run Keyword And Return Status    Should Match Regexp        ${component_carrier}    ^([1-9]+)$
    Run Keyword If    '${status}' == 'False'
    ...   FAIL    Format of the COMPONENT_CARRIER value is wrong. Please provide like 1 or 2 or 3..
    ${value}=   Convert To Integer    ${component_carrier}
    Set Suite Variable    ${component_carrier}    ${value}
    ${AP_P1Perf}=    Get Variable Value    ${AP_P1Perf}    False
    Set Suite Variable    ${AP_P1Perf}
    ${p1perf_ue_count}=    Get Variable Value    ${p1perf_ue_count}    2
    ${result}     Run Keyword If    '${AP_P1Perf}' == 'True'    Set Variable     ${P1Perf_ue_count}
    ${component_carrier}=      Set Variable If    "${result}" == 'None'    ${component_carrier}    ${result}
    ${AP_P1Perf_mmwv}=    Get Variable Value    ${AP_P1Perf_mmwv}    False
    Set Suite Variable    ${AP_P1Perf_mmwv}
    ${p1perf_mmwv_ue_count}=    Get Variable Value    ${p1perf_mmwv_ue_count}    20
    ${result}     Run Keyword If    '${AP_P1Perf_mmwv}' == 'True'    Set Variable     ${p1perf_mmwv_ue_count}
    ${component_carrier}=      Set Variable If    "${result}" == 'None'    ${component_carrier}    ${result}
    ${sa_ueids_val}=    Get Variable Value    ${sa_ueids}
    ${nsa_ueids_val}=    Get Variable Value    ${nsa_ueids}
    ${lte_ueids_val}=    Get Variable Value    ${lte_ueids}
    ${targetcell_ids_val}=    Get Variable Value    ${targetcell_ids}
    ${gw_ids_val}=    Get Variable Value    ${gw_ids}
    @{sa_ueids}=   Create List
    @{nsa_ueids}=   Create List
    @{targetcell_ids}=   Create List
    @{gw_ids}=   Create List
    @{lte_ueids}=   Create List
    FOR    ${value}    IN RANGE    ${component_carrier}
        Append To List    ${targetcell_ids}   ${value+1}
        Append To List    ${gw_ids}   ${value+1}
        Append To List    ${sa_ueids}   ${value+1}
        Append To List    ${nsa_ueids}   ${value+11}
        Append To List    ${lte_ueids}   ${value+21}
    END
    RUN KEYWORD AND IGNORE ERROR    ${sa_ueids}=    Override Test Variables with Default Variables    ${sa_ueids_val}    ${sa_ueids}
    RUN KEYWORD AND IGNORE ERROR     ${nsa_ueids}=    Override Test Variables with Default Variables    ${nsa_ueids_val}    ${nsa_ueids}
    RUN KEYWORD AND IGNORE ERROR     ${lte_ueids}=    Override Test Variables with Default Variables    ${lte_ueids_val}    ${lte_ueids}
    RUN KEYWORD AND IGNORE ERROR    ${targetcell_ids}=    Override Test Variables with Default Variables    ${targetcell_ids_val}    ${targetcell_ids}
    RUN KEYWORD AND IGNORE ERROR     ${gw_ids}=    Override Test Variables with Default Variables    ${gw_ids_val}    ${gw_ids}
    Set Suite Variable    @{sa_ueids}
    Set Suite Variable    @{nsa_ueids}
    Set Suite Variable    @{lte_ueids}
    Set Suite Variable    @{gw_ids}
    Set Suite Variable    @{targetcell_ids}
    Run Keyword if    '${4G5G_Combo}' == '1' and '${variant_name}' == '4G5G_COMBO_MultiUE'
    ...    Update ueids for Combo MultiUE    ue_count=20
    Append Test Property File For UE_IDs

Update Property File For UE_ID Values
   Append To File     ${test_property_file}    ${\n}sa_ueids=@{sa_ueids}${\n}
   Append To File     ${test_property_file}    nsa_ueids=@{nsa_ueids}${\n}
   Append To File     ${test_property_file}    lte_ueids=@{lte_ueids}${\n}
   Append To File     ${test_property_file}    gw_ids=@{gw_ids}${\n}
   Append To File     ${test_property_file}    targetcell_ids=@{targetcell_ids}${\n}
