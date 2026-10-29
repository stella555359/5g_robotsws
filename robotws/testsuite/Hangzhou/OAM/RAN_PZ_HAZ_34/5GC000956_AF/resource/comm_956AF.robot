*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin       WITH NAME    coam
Library    taf.collectors.btslog        WITH NAME    btslog
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    ../../../../RRM/Hangzhou/5GC000523_samsung/Resources/5GC000523_common_keyword.robot

*** Variables ***
${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${TS_CASE_LOG_PATH}    ${output_dir}
${default_scf_path}     ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00.xml
@{RFTHLD_parameter}    rFPowerErrorHighThreshold    rFPowerErrorLowThreshold    rxAntennaRSSIHighThreshold    rxAntennaRSSILowThreshold
...    rxAntennaRTWPHighThreshold    rxAntennaRTWPLowThreshold    txAntennaVSWRHighThreshold
${if_pdl_check}    True

*** Keywords ***
Rest Login DU
    [Arguments]  ${ip_address}=${DU_OAM_IP}        ${alias}=default
    ...          ${username}=${DU_OAM_WEBUI_USER}  ${password}=${DU_OAM_WEBUI_PASSWORD}
    [Documentation]   Rest Login DU
    Run Keyword And Ignore Error    Rest Logout DU   alias=${alias}
    Sleep  2
    ${connection}   coam.Connect To  bts_host=${ip_address}  bts_port=443
    ...                                    name=${alias}
    ...                                    username=${username}  password=${password}
    [Return]  ${connection}

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    coam.Teardown  connection=${alias}

WEBUI Login
    [Arguments]      ${virtual_enable}=${True}    ${version}=SBTS21B
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
#    Log To Console  Try to logout before login...
#    Run Keyword And Ignore Error    selenium_coam.Logout
    Log To Console  Logout successfully...
    Log To Console  Try to login...
    selenium_coam.Enable Virtual Display
    selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ...    version=${version}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
    Sleep    15s
    Log To Console  END:WEBUI Login!
    ${start_exits}    selenium_coam.start_up_view_window_exists
    Run Keyword If     ${start_exits} == ${TRUE}     selenium_coam.close_start_up_view_window

WEBUI Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Sleep    1s
    Log To Console  END:WEBUI Logout!

Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    Rest Login DU
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=800s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair

Gnb Cell Should Be Onair
    [Arguments]  ${alias}=default  ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be true    '${operationalState}'=='Enabled' or '${operationalState}'=='enabled'
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    Should Be true    '${operationalState}'=='Enabled' or '${operationalState}'=='enabled'
#    ${tmp}   Get From Dictionary    ${status}   availabilityStatus
#    Should Be Equal    ${tmp}    Online
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    Unlocked
    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal    ${tmp}    Unblocked
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal    ${tmp}    Active

Get Version
    Log To Console    Get Version
    ${connection}    coam.connect_to    bts_host=${DU_OAM_IP}     name=GNB_OAM
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${connection}

Setup Commission SCF
    suite setup to prepare default scf

Create TEST If Not Exit
    Log To Console    Create TEST If Not Exit
    ${connection}    Rest Login DU
    ${object_list}    coam.get_managed_objects    class_name=TEST_A
    ${length}    get length    ${object_list}
    run keyword if    ${length} == ${0}   Create TEST    connection=${connection}
    [Teardown]    Rest Logout DU

Create TEST
    [Arguments]    ${connection}
    Log To Console    Create TEST
    ${dict_1}    create dictionary    parameterName=testId    operation=update    value=${1}
    ${list1}    create list    ${dict_1}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1
    ...    parameter=${list1}    operation=create
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    sleep    2s

Delete RFTHLD If Exist OK
    [Arguments]    ${url}=${DU_OAM_WEBUI_URL}
    Wait Until Keyword Succeeds    2min    30s    COAM Navigate to login page via webUI    url=${url}
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${True}    ${True}
    ${object_list}    selenium_coam.get_object_name_list    object_name=TEST
    ${test_num}   Get Length   ${object_list}
    FOR    ${object}    IN    @{object_list}
        Exit For Loop If  ${test_num}==${0}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/${object}    timeout=15
    END
    Run Keyword If  ${test_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${test_num}!=${0}    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    [Teardown]  COAM selenium logout

Modify actRemoteRfDiag Parameters
    [Arguments]    ${actRemoteRfDiag}=true
    Log To Console    Modify actRemoteRfDiag Parameters
#    ${versiontitle}    Get Version
    comm_956AF.WEBUI Login
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate remote RF diagnostic test
    ...    abbr=actRemoteRfDiag
    ${modify_params}    create list
    ${item}    create dictionary    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate remote RF diagnostic test  p_name=actRemoteRfDiag  value=${actRemoteRfDiag}
    append to list    ${modify_params}    ${item}
    Run Keyword If    '${currect_status}'!='${actRemoteRfDiag}'    Modify Parameters    modify_params=${modify_params}
    [Teardown]    comm_956AF.WEBUI Logout

Set default value for RFTHLD
    [Arguments]    ${url}=${DU_OAM_WEBUI_URL}
    Log To Console    Set default value for RFTHLD
    Wait Until Keyword Succeeds    2min    30s    COAM Navigate to login page via webUI    url=${url}
#    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1
    ...    object_class_name=TEST    id_value=${1}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1
    ...    object_class_name=RFTHLD    is_load_default_values=${True}    id_value=${1}    timeout=15
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]  COAM selenium logout

Verify value for RFTHLD
    [Arguments]  ${totalRFPowerHighThreshold}=${120}    ${totalRFPowerLowThreshold}=${0.1}    ${rFPowerErrorHighThreshold}=${8}
    ...    ${rFPowerErrorLowThreshold}=${-8}    ${rxAntennaRSSIHighThreshold}=${-30}    ${rxAntennaRSSILowThreshold}=${-110}
    ...    ${rxAntennaRTWPHighThreshold}=${-30}    ${rxAntennaRTWPLowThreshold}=${-110}    ${txAntennaVSWRHighThreshold}=${3}
    ...    ${url}=${DU_OAM_WEBUI_URL}
    Log To Console    Verify value for RFTHLD
    Wait Until Keyword Succeeds    2min    30s    COAM Navigate to login page via webUI    url=${url}
    ${modify_params}    create list
    ${dist_name}    Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=Total RF power high threshold    p_name=totalRFPowerHighThreshold    value=${totalRFPowerHighThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=Total RF power low threshold    p_name=totalRFPowerLowThreshold    value=${totalRFPowerLowThreshold}
    append to list    ${modify_params}    ${item}
    ${item}  create dictionary    dist_name=${dist_name}
    ...    filter_param=RF power error high threshold    p_name=rFPowerErrorHighThreshold    value=${rFPowerErrorHighThreshold}
    append to list    ${modify_params}    ${item}
    ${item}  create dictionary    dist_name=${dist_name}
    ...    filter_param=RF Power error low threshold    p_name=rFPowerErrorLowThreshold    value=${rFPowerErrorLowThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=High RSSI threshold    p_name=rxAntennaRSSIHighThreshold    value=${rxAntennaRSSIHighThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=Low RSSI threshold    p_name=rxAntennaRSSILowThreshold    value=${rxAntennaRSSILowThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=RTWP high threshold    p_name=rxAntennaRTWPHighThreshold    value=${rxAntennaRTWPHighThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=RTWP low threshold    p_name=rxAntennaRTWPLowThreshold    value=${rxAntennaRTWPLowThreshold}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=TX antenna VSWR high threshold    p_name=txAntennaVSWRHighThreshold    value=${txAntennaVSWRHighThreshold}
    append to list    ${modify_params}    ${item}
    Modify Parameters    modify_params=${modify_params}    is_activate=${True}
    ${defErrs_dic}    run keyword and continue on failure    selenium_coam.get_definition_errors
    ${list_num}    Get Length    ${defErrs_dic}
    Should be true    ${list_num}==${11}
    selenium_coam.undo_changes
    [Teardown]  COAM selenium logout

Modify Parameters
    [Arguments]  ${modify_params}  ${is_activate}=${True}  ${despite_errors}=${False}
#    ${activate_plan_despite_errors}    set variable if    not ${if_pdl_check}    ${True}    ${despite_errors}
    run keyword and ignore error    run keyword if  ${activate_plan_despite_errors}  selenium_coam.refresh_page
    FOR  ${item}  IN  @{modify_params}
        selenium_coam.set_parameter_value  dist_name=${item}[dist_name]
        ...    filter_param=${item}[filter_param]
        ...    abbr=${item}[p_name]    new_value=${item}[value]
    END
    selenium_coam.validate_plan
    run keyword if  ${is_activate}==True    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

RF Diagnostic Test Setup And Check Time
    [Arguments]    ${cell}=NRCELL-1    ${bts_thresholds}=${None}     ${bands_thresholds}=${None}    ${cell_id}=1
    Log To Console    RF Diagnostic Test Setup
    selenium_coam.configure_rf_diagnostic_test    cell=${cell}    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}
    run keyword and ignore error    selenium_coam.save_thresholds
    selenium_coam.start_rf_diagnostic_test    timeout=30
    wait until keyword succeeds    1s    100ms    check test information    cell_id=${cell_id}

check test information
    [Arguments]    ${cell_id}
    ${test_information}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    should not be empty    ${test_information}

Check Detailed Antenna
    [Arguments]    ${cell_id}=1    ${expected_low}=0     ${expected_high}=120   ${error_low}=-8    ${error_high}=8
    ...    ${RSSI_low}=-180    ${RSSI_high}=-30    ${RTWP_low}=-180    ${RTWP_high}=-30    ${VSWR_high}=3
    ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}
    FOR    ${item}    IN    @{detail_result}
#        ${dict_forward_total}    get from dictionary    ${item}   Forward total transmit RF power
#        ${value_forward_total}    get from dictionary    ${dict_forward_total}     dBm
#        should be true    ${total_low} < ${value_forward_total} < ${total_high}
        ${dict_forward_expected}    get from dictionary    ${item}   Forward expected transmit RF power
        ${value_forward_expected}    get from dictionary    ${dict_forward_expected}     dBm
        should be true    ${expected_low} < ${value_forward_expected}
        ${value_forward_error}    get from dictionary    ${item}    Forward transmit RF power error (dB)
        should be true    ${error_low} < ${value_forward_error} < ${error_high}
        ${value_RSSI}    get from dictionary    ${item}    RSSI (dBm)
        should be true    ${RSSI_low} < ${value_RSSI} < ${RSSI_high}
        ${value_RTWP}    get from dictionary    ${item}    RTWP (dBm)
        should be true    ${RTWP_low} < ${value_RTWP} < ${RTWP_high}
        ${value_VSWR}    get from dictionary    ${item}    VSWR
        should be true    ${value_VSWR} < ${VSWR_high}
    END

Check VSWR With L3 Call
    [Arguments]    ${cell_id}=1    ${VSWR_high}=3
    Log To Console    Check VSWR With L3 Call
    ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}
    FOR    ${item}    IN    @{detail_result}
        ${value_VSWR}    get from dictionary    ${item}    VSWR
        should be true    0 < ${value_VSWR} < ${VSWR_high}
    END

Check General Information
    [Arguments]    ${cell_id}=1    ${forward_expected_result}=Pass    ${reverse_expected_result}=Pass
    ...    ${expected_outcome}=Pass
    ${general_result}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    ${forward_result}    get from dictionary    ${general_result[0]}    Forward test disposition
    ${reverse_result}    get from dictionary    ${general_result[0]}    Reverse test disposition
    ${outcome}    get from dictionary    ${general_result[0]}    Outcome
    should be equal    ${forward_result}    ${forward_expected_result}
    should be equal    ${reverse_result}    ${reverse_expected_result}
    should be equal    ${outcome}    ${expected_outcome}

Check Start And Stop Time
    [Arguments]    ${cell_id}=1    ${start_time_name}=Start time GMT +0800    ${stop_time_name}=Stop time GMT +0800
    ${general_result}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    ${start_time}    get from dictionary    @{general_result}    ${start_time_name}
    ${start_time_value}    split string    ${start_time}    ${SPACE}
    ${stop_time}    get from dictionary    @{general_result}    ${stop_time_name}
    ${stop_time_value}    split string    ${stop_time}    ${SPACE}
    ${time_differ}    subtract_time_from_time    ${start_time_value}[-1]     ${stop_time_value}[-1]
    ${time}    evaluate    abs(${time_differ})
    should be equal   ${time}    ${1.0}

Set Illegal Value
    Log To Console   Set Illegal Value
    ${connection}    Rest Login DU
    ${dict_lowvalue}    create dictionary    ${RFTHLD_parameter[0]}=19    ${RFTHLD_parameter[1]}=-81    ${RFTHLD_parameter[2]}=-1801
    ...    ${RFTHLD_parameter[3]}=-1801    ${RFTHLD_parameter[4]}=-1801    ${RFTHLD_parameter[5]}=-1801    ${RFTHLD_parameter[6]}=0
    ${dict_highvalue}    create dictionary    ${RFTHLD_parameter[0]}=81    ${RFTHLD_parameter[1]}=-19    ${RFTHLD_parameter[2]}=1
    ...    ${RFTHLD_parameter[3]}=1    ${RFTHLD_parameter[4]}=1    ${RFTHLD_parameter[5]}=1    ${RFTHLD_parameter[6]}=101
    Log To Console    Check lowvalue
    FOR    ${item}    IN    @{RFTHLD_parameter}
        ${dict_RFTHLD}    create dictionary    parameterName=${item}    operation=update    value=${dict_lowvalue}[${item}]
        ${list1}    create list    ${dict_RFTHLD}
        run keyword and expect error    *VALUE_IS_TOO_SMALL*    coam.perform_object_recommissioning
        ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
        ...    parameter=${list1}    operation=update
        ...    skip_parameter_relation_errors=${True}    should_activate=${False}    connection=${connection}
    END
    Log To Console    Check highvalue
    FOR    ${item}    IN    @{RFTHLD_parameter}
        ${dict_RFTHLD}    create dictionary    parameterName=${item}    operation=update    value=${dict_highvalue}[${item}]
        ${list2}    create list    ${dict_RFTHLD}
        run keyword and expect error    *VALUE_IS_TOO_BIG*    coam.perform_object_recommissioning
        ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
        ...    parameter=${list2}    operation=update
        ...    skip_parameter_relation_errors=${True}    should_activate=${False}    connection=${connection}
    END
    _Set Band class value    connection=${connection}
    [Teardown]    Rest Logout DU

_Set Band class value
    [Arguments]    ${connection}
    Log To Console     Set Band class value
    ${object_list}    coam.get_managed_objects    class_name=RFTHLD_A
    ${parameter}    get from dictionary     ${object_list[0]}    parameters
    ${nrBandRfTestThresholds}     get from dictionary    ${parameter}    nrBandRfTestThresholds
    set to dictionary    ${nrBandRfTestThresholds[0]}    totalRFPowerHighThreshold=0
    set to dictionary    ${nrBandRfTestThresholds[0]}    totalRFPowerLowThreshold=0
    ${dict_1}    create dictionary    parameterName=nrBandRfTestThresholds    operation=update    value=${nrBandRfTestThresholds}
    ${list1}    create list    ${dict_1}
    run keyword and expect error    *VALUE_IS_TOO_SMALL*    coam.perform_object_recommissioning
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
    ...    parameter=${list1}    operation=update
    ...    skip_parameter_relation_errors=${True}    should_activate=${False}    connection=${connection}
    set to dictionary    ${nrBandRfTestThresholds[0]}    totalRFPowerHighThreshold=1501
    set to dictionary    ${nrBandRfTestThresholds[0]}    totalRFPowerLowThreshold=1501
    ${dict_2}    create dictionary    parameterName=nrBandRfTestThresholds    operation=update    value=${nrBandRfTestThresholds}
    ${list2}    create list    ${dict_2}
    run keyword and expect error    *VALUE_IS_TOO_BIG*    coam.perform_object_recommissioning
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
    ...    parameter=${list2}    operation=update
    ...    skip_parameter_relation_errors=${True}    should_activate=${False}    connection=${connection}

Lock BTS Cell
    [Arguments]    ${alias}=default
    Log To Console    Lock BTS Cell
    Rest Login DU
    Perform cell lock via rest api    cell_idx=${1}    connection=${alias}
    sleep    10s
    Perform cell lock via rest api    cell_idx=${2}    connection=${alias}
    [Teardown]    Rest Logout DU

Unlock BTS Cell
    [Arguments]    ${alias}=default
    Log To Console    Unlock BTS Cell
    Rest Login DU
    Perform cell unlock via rest api    cell_idx=${1}    connection=${alias}
    sleep    10s
    Perform cell unlock via rest api    cell_idx=${2}    connection=${alias}
    [Teardown]    Rest Logout DU

RF Diagnostic Test Setup Fail
    [Arguments]    ${cell}=NRCELL-1    ${bts_thresholds}=${None}     ${bands_thresholds}=${None}    ${cell_id}=1
    Log To Console    RF Diagnostic Test Setup Fail
    selenium_coam.configure_rf_diagnostic_test    cell=${cell}    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}
    run keyword and expect error    *TimeoutException*    selenium_coam.start_rf_diagnostic_test

Lock/Unlock Cell And Wait Until On Air
    Log To Console    Lock/Unlock Cell And Wait Until On Air
    Rest Login DU
    sleep    2s
    Log To Console    Lock Cell
    coam.lock_cell    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    timeout=${60}
    coam.lock_cell    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2    timeout=${60}
    sleep    3s
    Log To Console    Unlock Cell
    coam.unlock_cell    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    timeout=${60}
    coam.unlock_cell    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2    timeout=${60}
    wait until bts should be normal
    [Teardown]    Rest Logout DU

Lock/Unlock RU And Wait Until On Air
    [Arguments]    ${RMOD_idx}=${1}
    Log To Console    RU Lock/Unlock And Wait Until On Air
    Rest Login DU
    sleep    2s
    Log To Console    Lock RU
    coam.lock_RU    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}
    sleep    3s
    Log To Console    Ulock RU
    coam.unlock_RU    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}
    wait until bts should be normal
    [Teardown]    Rest Logout DU

test
#    comm_956AF.WEBUI Login
#    RF Diagnostic Test Setup Fail
#    selenium_coam.get_object_name_list    object_name=RFRES
#    [Teardown]    comm_956AF.WEBUI Logout
    Rest Login DU
    Create TEST If Not Exit
    [Teardown]    Rest Logout DU

