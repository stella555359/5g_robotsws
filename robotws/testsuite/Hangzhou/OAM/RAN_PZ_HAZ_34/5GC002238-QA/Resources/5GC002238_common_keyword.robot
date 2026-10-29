*** Settings ***
Documentation     Suite description
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot

*** Keywords ***
Reboot DU and Check cell onAir
    coam.connect_to  bts_host=${DU_OAM_IP_TL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    log to console  login web successful
    coam.reset_site
    coam.teardown
    sleep  30s
    Connection to web and check cell onAir
    [Teardown]  coam.teardown

Connection to web and check cell onAir
    wait until keyword succeeds   5min    30s
    ...    coam.connect_to  bts_host=${DU_OAM_IP_TL}
    ...    username=${DU_OAM_WEBUI_USER}
    ...    password=${DU_OAM_WEBUI_PASSWORD}
    log to console  login web successful
    wait until keyword succeeds    15min    10s   check cell
    log to console  cell onAir successful
    [Teardown]  coam.teardown

check cell
    ${bts_status}    coam.get_bts_statuses
    log to console  bts status is:${bts_status}
    dictionary should contain value   ${bts_status}   OnAir

Connection to Du making alarm
    csn.connect_to    hostname=${DU_OAM_IP_TL}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}
    ...    alias=${asik_alias}
    csn.Send Command  command=lxc-ls --active > /tmp/lxc.txt  connection=${asik_alias}
    csn.download_file  local_path=${LOG_PATH}/lxc.txt    remote_path=/tmp/lxc.txt    connection=${asik_alias}
    log to console  download lxc.txt successful
    ${lxc}  GET_lxc_active    file_path=${LOG_PATH}/lxc.txt
    ${lxc}  strip_string   ${lxc}
    csn.Send Command  command=rm /tmp/lxc.txt   connection=${asik_alias}
    csn.Send Command  command=lxc-attach -n ${lxc}  connection=${asik_alias}
    sleep  40s
    log to console  lxc active :${lxc}
    csn.Send Command  command=ps aux |grep ${lxc} |grep /opt/CCS/CCSDaemonExe |awk '{print $2}' |xargs kill -9   connection=${asik_alias}
    log to console  kill ${lxc} successful
    sleep     5min
    Stop BTSLOG Collect btslog on remote machine
    Copy Btslog to UTE
    Check Btslog and Alarm     command=grep "AlarmNumber: 7101"    target=${OUTPUT DIR}/${Test_Case_Name}/bts_log.log
    Check Btslog and Alarm     command=grep "FaultId: 4383"    target=${OUTPUT DIR}/${Test_Case_Name}/bts_log.log
    log to console  check alarm successful
    sleep  60s
    [Teardown]   csn.disconnect    connection=${asik_alias}

Check Btslog and Alarm
    [Arguments]    ${command}   ${target}
    csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=ute
    sleep    1s
    csn.Send Command  command=cat ${target} |${command}    connection=ute
    ${data}    csn.Read Output    connection=ute
    ${data}    strip_string    ${data}
    Run keyword and continue on failure    should not be empty    ${data}
    [Teardown]    csn.Disconnect   connection=ute

attach multi power ue
    [Arguments]    ${ue_num}
    log to console       Prepare UE
    FOR    ${item}    IN RANGE    ${ue_num}
        ${status}    run keyword and return status    power ue attach again    ue_index=${item}
        run keyword if  not ${status}    power ue attach again    ue_index=${item}
    END

power ue attach again
    [Arguments]    ${ue_index}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False

start multi power ue traffic ul
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}     ${ul_duration}=600    ${protocol}=udp
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
        power_ue.Start traffic    ue_index=${item}    direction=ul    iperf_port=${ue_power_port}    protocol=${protocol}
        ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command
        sleep    1s
    END

stop multi power ue traffic
    [Arguments]    ${ue_num}    ${protocol}=tcp    ${if_ul}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
        ...    protocol=${protocol}    iperf_port=${ue_power_port}
    END

Create Default RFTHLD
    Log To Console    Delete RFTHLD If Exist
    Delete RFTHLD If Exist
    Modify actRemoteRfDiag Parameters
    Set default value for RFTHLD
    Verify value for RFTHLD    totalRFPowerHighThreshold=${0}    totalRFPowerLowThreshold=${0}
    ...    rFPowerErrorHighThreshold=${1}    rFPowerErrorLowThreshold=${-9}    rxAntennaRSSIHighThreshold=${-181}
    ...    rxAntennaRSSILowThreshold=${-181}    rxAntennaRTWPHighThreshold=${-181}    rxAntennaRTWPLowThreshold=${-181}
    ...    txAntennaVSWRHighThreshold=${0}
    Verify value for RFTHLD    totalRFPowerHighThreshold=${151}    totalRFPowerLowThreshold=${151}
    ...    rFPowerErrorHighThreshold=${9}    rFPowerErrorLowThreshold=${-1}    rxAntennaRSSIHighThreshold=${1}
    ...    rxAntennaRSSILowThreshold=${1}    rxAntennaRTWPHighThreshold=${1}    rxAntennaRTWPLowThreshold=${1}
    ...    txAntennaVSWRHighThreshold=${11}

Delete RFTHLD If Exist
    [Arguments]    ${url}=https://${DU_OAM_IP_TL}
    Wait Until Keyword Succeeds    2min    30s    WEBUI Login    version=5G21A
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${True}    ${True}
    ${object_list}    selenium_coam.get_object_name_list    object_name=TEST
    ${test_num}   Get Length   ${object_list}
    FOR    ${object}    IN    @{object_list}
        Exit For Loop If  ${test_num}==${0}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/${object}    timeout=15
    END
    Run Keyword If  ${test_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${test_num}!=${0}    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    [Teardown]    WEBUI Logout

WEBUI Login
    [Arguments]      ${virtual_enable}=${True}    ${version}=5G21A
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to logout before login...
    Run Keyword And Ignore Error    selenium_coam.Logout
    Log To Console  Logout successfully...
    Log To Console  Try to login...
    selenium_coam.Login    url=https://${DU_OAM_IP_TL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
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

Modify actRemoteRfDiag Parameters
    [Arguments]    ${actRemoteRfDiag}=true
    Log To Console    Modify actRemoteRfDiag Parameters
    ${versiontitle}    Get Version
    WEBUI Login    version=${versiontitle}
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate remote RF diagnostic test
    ...    abbr=actRemoteRfDiag
    ${modify_params}    create list
    ${item}    create dictionary    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate remote RF diagnostic test  p_name=actRemoteRfDiag  value=${actRemoteRfDiag}
    append to list    ${modify_params}    ${item}
    Run Keyword If    '${currect_status}'!='${actRemoteRfDiag}'    Modify Parameters    modify_params=${modify_params}
    [Teardown]    WEBUI Logout

Get Version
    Log To Console    Get Version
    ${connection}    coam.connect_to    bts_host=${DU_OAM_IP_TL}     name=GNB_OAM
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${connection}

Set default value for RFTHLD
    [Arguments]    ${url}=https://${DU_OAM_IP_TL}
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
    ...    ${url}=https://${DU_OAM_IP_TL}
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
    FOR  ${item}  IN  @{modify_params}
        selenium_coam.set_parameter_value  dist_name=${item}[dist_name]
        ...    filter_param=${item}[filter_param]
        ...    abbr=${item}[p_name]    new_value=${item}[value]
    END
    selenium_coam.validate_plan
    run keyword if  ${is_activate}==True    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Check RF Diagnostic Result
    [Arguments]    ${cell}=NRCELL-1    ${bts_thresholds}=${None}    ${bands_thresholds}=${None}    ${cell_id}=1
    RF Diagnostic Test Setup And Check Time
    ...    cell=${cell}    bts_thresholds=${bts_thresholds}    bands_thresholds=@{bands_thresholds}    cell_id=1
    Check Detail Antenna    RSSI_low=-160
    Check General Information
    Check Start And Stop Time    start_time_name=Start time GMT +0800    stop_time_name=Stop time GMT +0800

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

Check Detail Antenna
    [Arguments]    ${cell_id}=1    ${expected_low}=0     ${expected_high}=120   ${error_low}=-8    ${error_high}=8
    ...    ${RSSI_low}=-180    ${RSSI_high}=-30    ${RTWP_low}=-180    ${RTWP_high}=-30    ${VSWR_high}=3
    ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}
    FOR    ${item}    IN    @{detail_result}
        ${dict_forward_total}    get from dictionary    ${item}   Forward total transmit RF power
        ${value_forward_total}    get from dictionary    ${dict_forward_total}     dBm
        should be true    ${value_forward_total} == 0
        ${dict_forward_expected}    get from dictionary    ${item}   Forward expected transmit RF power
        ${value_forward_expected}    get from dictionary    ${dict_forward_expected}     dBm
        should be true    ${expected_low} < ${value_forward_expected}
        ${value_forward_error}    get from dictionary    ${item}    Forward transmit RF power error (dB)
        should be true    ${value_forward_error} == 0
        ${value_RSSI}    get from dictionary    ${item}    RSSI (dBm)
        should be true    ${value_RSSI} == 0
        ${value_RTWP}    get from dictionary    ${item}    RTWP (dBm)
        should be true    ${value_RTWP} == 0
        ${value_VSWR}    get from dictionary    ${item}    VSWR
        should be true    ${value_VSWR} == 0
    END

Check General Information
    [Arguments]    ${cell_id}=1    ${forward_expected_result}=Pass    ${reverse_expected_result}=Pass
    ...    ${expected_outcome}=Pass
    ${general_result}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    ${general_result_index}    evaluate    ${cell_id}-1
    ${forward_result}    get from dictionary    ${general_result[${general_result_index}]}    Forward test disposition
    ${reverse_result}    get from dictionary    ${general_result[${general_result_index}]}    Reverse test disposition
    ${outcome}    get from dictionary    ${general_result[${general_result_index}]}    Outcome
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

Rest Login DU
    [Arguments]  ${ip_address}=${DU_OAM_IP_TL}        ${alias}=default
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


case_teardown
    WEBUI Logout
    CI_interface.Common Case Teardown


Modify Structure parameter via Coam
    [Arguments]   ${class_name}   ${modify_list}    ${keywords_list}    ${index}   ${connection}=GNB_CON    ${bts_ip}=${DU_OAM_IP_TL}
    coam.connect_to    bts_host=${bts_ip}   name=${connection}
    ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
    ${output_dict_list}    Return_Structure_Mofify_Value    input_list=${get_managed_objects}    modify_list=${modify_list}
    ...    keywords_list=${keywords_list}    index=${index}
    FOR    ${item}  IN  @{output_dict_list}
         ${dict_value}    Get Content From Input Dict    input_dict=${item}
         coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  2min
    END
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

BTSLOG Start btslog on remote machine
    [Arguments]    ${name}=btslog     ${bts_logs_dir}=/tmp/btslog2    ${alias}=TESTPC
    csn.Connect to    hostname=${remote_ip}   username=${ute_name}    password=${test_password}    alias=${alias}
    csn.send_command  command=if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi    connection=${alias}
    &{executor}=    create dictionary    host=${remote_ip}    user=ute    password=ute
    btslog.create_btslog_collector    name=${name}    log_dir=${bts_logs_dir}    executor=${executor}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

Stop BTSLOG Collect btslog on remote machine
    [Arguments]   ${name}=btslog    ${bts_logs_dir}=/tmp/btslog2    ${alias}=TESTPC
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}
	csn.send_command  command=mkdir /tmp/${TEST_NAME}    connection=${alias}
    csn.send_command  command=mv ${bts_logs_dir}/syslog_files.tgz /tmp/${TEST_NAME}/bts_log.tgz    connection=${alias}
    csn.send_command  command=rm ${bts_logs_dir}/*    connection=${alias}
    [Teardown]  Run Keyword And Ignore error    Csn.Disconnect	connection=TESTPC

Copy Btslog to UTE
    [Arguments]  ${username}=${ute_name}   ${password}=${test_password}   ${alias}=TESTPC_local  ${dir}=/${OUTPUT_DIR}/${Test_Case_Name}
    csn.Connect to     hostname=${test_ute}    username=${username}    password=${password}	alias=${alias}
    csn.send_command  command=if [ ! -d ${dir} ]; then mkdir ${dir}; else rm ${dir}/*; fi    connection=${alias}
    csn.send_command  command=mkdir /${OUTPUT_DIR}/${TEST_NAME}    connection=${alias}
    csn.execute    command=sudo sshpass -p ute scp -p ${username}@${remote_ip}:/tmp/${TEST_NAME}/bts_log.tgz /${OUTPUT_DIR}/${TEST_NAME}
    ...    connection=${alias}
    csn.execute    command=tar zxvf ${OUTPUT_DIR}/${TEST_NAME}/bts_log.tgz -C ${OUTPUT_DIR}/${Test_Case_Name}/    connection=${alias}
	csn.execute    command=mv ${OUTPUT_DIR}/${Test_Case_Name}/*.LOG ${OUTPUT_DIR}/${Test_Case_Name}/bts_log.log    connection=${alias}
    ${message} =    OperatingSystem.Grep File    ${OUTPUT_DIR}/${Test_Case_Name}/bts_log.log    Estimator output
    [Teardown]   Run Keyword And Ignore error    Csn.Disconnect	connection=${alias}
