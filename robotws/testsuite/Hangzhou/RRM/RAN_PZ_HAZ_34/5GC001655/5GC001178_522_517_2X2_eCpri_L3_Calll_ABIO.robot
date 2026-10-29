*** Settings ***
Documentation     author: Yulu1
...               contact: lu.1.yu@nokia-sbell.com
...               squad group: SG_02
Force Tags        RAN_5G   RAN_5G_TDD   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_AEQE_ENB   SBTS00   CIT
...    PY39
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Huawei_sigspark_L3_call.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Variables         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/1655_variables.py
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot

Suite Setup    Run Keywords    SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}
...                     AND    5GC0001178 Suit Setup

*** Variables ***
# UL/DL throughput
${UL_PORT}        ${tl.appserver.iperf_details.port}
${UL_LENGTH}      1024B
${UL_TIME}        6000
${DL_PORT}        ${tl.ues[0].iperf_details.port}
${DL_LENGTH}      1024B
${DL_TIME}        6000
${UL_THROUGHPUT}    200Mbits/sec
${DL_THROUGHPUT}    1700Mbits/sec
# BLER Percentage
${EXP_TPUT_PERCENTAGE}    0.95
${UL_EXPECT_min}    0.05
${DL_EXPECT_min}    1
${UL_EXPECT_peak}    75M
${DL_EXPECT_peak}    1100M
${dldata_mcs}    DlData_PdschSendReq.grants_item_15.mcs
${uldata_mcs}    UlData_PuschReceiveReq.grants_item_15.mcs

@{attenuation_value}    37    50    60
@{test_mcs}    0x00    0x05    0x0C    0x15
&{dl_mcs_table}    0x00=25    0x05=160    0x0C=326    0x15=596
&{ul_mcs_table}    0x00=3    0x05=11    0x0C=25    0x15=53

*** Test Cases ***
[1][1.0] 5GC000517_B_229_DL_LA_table1_below6GHz_2layers_from_Near_to_Edge_Cell_radio_condition
    [Tags]
    [Setup]    SG2_Common_setup_teardown.Common Case setup
    # [Setup]    Run Keywords    SG2_Common_setup_teardown.Common Case setup    5GC0001178 Case Setup
    Run Keyword And Continue On Failure     Check DLUL and Attenuation     data_transfer_dl=${DL_EXPECT_peak}
    ...        data_transfer_ul=${UL_EXPECT_peak}
    ...        Expected_Throughput_DL=${DL_EXPECT_min}
    ...        Expected_Throughput_UL=${UL_EXPECT_min}
    ...        duration=8m
    ...        exp_dl_tput=${DL_EXPECT_min}
    ...        exp_ul_tput=${UL_EXPECT_min}
    ...        tput_percentage=${EXP_TPUT_PERCENTAGE}
    # FOR  ${item}  IN  @{attenuation_value}
    #    &{channels_to_modify}    create dictionary    1=${item}    2=${item}
    #    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}
    #    ${bip_log}    Start Bip Log on Loki and download BIP logs to testPC
    #END
    #Run keyword and ignore error    gnb_classical_hangzhou.Restore Attenuation Values For RU  initial_att_values=${initial_att_values}  vendor=HBTE
    ${bip_log}    Start Bip Log on Loki and download BIP logs to testPC
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    [Teardown]    Run Keyword And Ignore Error    SG2_Common_setup_teardown.Common Case teardown    is_need_to_teardown_l3_call=${True}

[1.0] 5GC001178_AB_5GC00522_2x2ClosedLoop_256QAM_ULandDLTput_Peakrate_WithoutLA
    [Tags]
    [Setup]    SG2_Common_setup_teardown.Common Case setup
    Run Keyword And Continue On Failure    Begin DLUL traffic and Caculate Tput      data_transfer_dl=${DL_EXPECT_peak}
    ...        data_transfer_ul=${UL_EXPECT_peak}
    ...        Expected_Throughput_DL=${DL_EXPECT_min}
    ...        Expected_Throughput_UL=${UL_EXPECT_min}
    ...        duration=8m
    ${bip_log}    Start Bip Log on Loki and download BIP logs to testPC
    # Run Keyword And Continue On Failure    Confirm mcs Conforming to mcs Table    bip_log=${bip_log[0]}    item=${dldata_mcs}    mcs=1b
    # Run Keyword And Continue On Failure    Confirm mcs Conforming to mcs Table    bip_log=${bip_log[0]}    item=${uldata_mcs}    mcs=1c
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    [Teardown]    Run Keyword And Ignore Error    SG2_Common_setup_teardown.Common Case teardown    is_need_to_teardown_l3_call=${True}

[1]5GC002052_E_5_EIRP measurement_Multi cell segment_beamset6_without_FDM_single UE
    [Tags]
    [Setup]  Common Case setup end
    ${version}     get software version
    Load Case SCF and Commission SCF for 1178     scf_file=commissionings/HGZ/7_5_UTE5G402T553/${version}_eirp_9x5.xml
#    Modify actEirpControl is true     parameters_to_add_via_api=${PARAM_1655_EIRPCONTROL}
#    ...                               parameters_to_update_via_api=${PARAM_1655_ACTEIRPCONTROL}
    Run Keyword And Ignore Error    Begin DLUL traffic and Caculate Tput      data_transfer_dl=${DL_EXPECT_peak}
    ...        data_transfer_ul=${UL_EXPECT_peak}
    ...        Expected_Throughput_DL=${DL_EXPECT_min}
    ...        Expected_Throughput_UL=${UL_EXPECT_min}
    ...        duration=20m
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    SG2_Common_setup_teardown.COAM commission scf and wait cell setup     scf_file_path=${backup_scf_file}
    [Teardown]  Run Keyword And Ignore Error    SG2_Common_setup_teardown.Common Case teardown    is_need_to_teardown_l3_call=${True}

*** Keywords ***
Common Case setup end
    [Timeout]    20 min
    [Arguments]    ${scf_path}=${None}    ${is_pdl_checking_needed}=${False}    ${swconfig_path}=${None}
    ...            ${gnb_type}='SA'    ${need_Btslog}=${False}
    robot_common_operations.Common Case Setup    allowed_faults_ids=4681
    COAM Wait for gnb ready and cell setup    gnb_type=${gnb_type}
    run keyword if    '${swconfig_path}'!='${None}'    swconf.Upload swConfig file to asik and crasign
    ...               localFilePath=${swconfig_path}    asik_alias=ASIK Master
    run keyword if    '${scf_path}'!='${None}'    COAM Commission with scf file
    ...               scf_file_path=${scf_path}    timeout=480    is_pdl_checking_needed=${is_pdl_checking_needed}
    COAM Wait for gnb ready and cell setup    gnb_type=${gnb_type}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}/SCF
    ${backup_scf_file}    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    Set Test Variable    ${backup_scf_file}
    COAM selenium close browser
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Connect to Common Unit Slave
    ${status}    @{RUS_ALIAS}    Run keyword and ignore error    Connect to all rus with allocated IP
    Set suite variable    ${RUS_ALIAS}
    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}
    Run keyword If    ${need_Btslog}==${True}    Common Case Capture BTS log

5GC0001178 Suit Setup
    robot_common_operations.Common Suite Setup
    Connect to gnb coam via ssl
    ${ru_info}   COAM get ru detial info by ru index  ru_index=${1}
    ${ru_type}   set variable  ${ru_info}[productName]
    run keyword if     '${ru_type}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Download and Unzip Luashark File

5GC0001178 Case Setup
    ${initial_att_values}    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=HBTE
    Set Test Variable    ${initial_att_values}

Enable mirror port on Loki
    [Arguments]     ${mirror_port}=eths2    ${asik_alias}=ASIK Master
    csn.Execute     command=/usr/bin/lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_UL -b "C1B1(2)" -s 1 -l ${mirror_port} -v 303
    ...             connection=${asik_alias}
    csn.Execute     command=/usr/bin//lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_DL -b "C1B1(2)" -s 1 -l ${mirror_port} -v 303
    ...             connection=${asik_alias}
    csn.Execute     command=ncp_portmirror -p xgmac97 -r    connection=${asik_alias}
    csn.Execute     command=ncp_portmirror -d netdriver -p xgmac97    connection=${asik_alias}

Start Bip Log Capture on Loki
    [Arguments]     ${mirror_port}=eths2    ${asik_alias}=ASIK Master
    Enable mirror port on Loki    mirror_port=${mirror_port}
    csn.Send command     command=tcpdump -i ${mirror_port} -w /tmp/tcpdump_L2L1.pcap
    ...                  connection=${asik_alias}

Stop Bip Log Capture on Loki and download BIP Logs to testPC
    [Arguments]     ${interface}=eths2    ${connection}=ASIK Master
    ...             ${log_path}=${TS_CASE_LOG_PATH}    ${download_type}=Download
    ...             ${log_prefix}=${None}
    Stop BIP Capture On ASIK    interface=${interface}
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it
    ...    log_path=${log_path}
    ...    connection=${connection}
    ...    download_type=${download_type}
    ...    log_prefix=${log_prefix}
    [Return]    ${list_log_path_local}

Start Bip Log on Loki and download BIP logs to testPC
    [Arguments]     ${duration}=1s
    Connect to Common Unit Master
    Start Bip Log Capture on Loki
    Sleep    ${duration}
    ${list_log_path_local}    Stop Bip Log Capture on Loki and download BIP Logs to testPC    log_path=${OUTPUT_DIR}
    [Return]    ${list_log_path_local}

Confirm mcs Conforming to mcs Table
    [Arguments]     ${bip_log}    ${item}    ${mcs}
    ${package}    Load BIP Log with Lua Script    pcap_file=${bip_log}
    ${value}    Get value from Bip Log    packets=${package}    field_name=${item}
    ${mcs_cnt}    Get Count    ${value}    ${mcs}
    ${total}    Get Length    ${value}
    ${min_mcs_cnt}    Evaluate    ${total} * 0.9
    Should Be True     ${min_mcs_cnt} < ${mcs_cnt} < ${total}

Check DLUL and Attenuation
    [Arguments]     ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}     ${Expected_Throughput_UL}    ${duration}
    ...           ${exp_dl_tput}   ${exp_ul_tput}    ${tput_percentage}
    power_ue.Prepare UE     ue_type=${ue_type}    ui_version=default
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}     duration=2000
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}     duration=2000
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}
    ${list_of_cell_ids}    Create list    68719438337
    power_ue.Check Tput     ue_type=${ue_type}     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_UL}
    power_ue.Check Tput     ue_type=${ue_type}     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_DL}
    Run keyword and ignore error    Verify tput from GNB within duration and record data to csv
    ...    total_time=300    exp_dl_tput=${exp_dl_tput}
    ...    exp_ul_tput=${exp_ul_tput}    interval=10    duration_time_for_once=300
    ...    tput_percentage=${tput_percentage}    is_need_to_capture_log=${False}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

Begin DLUL traffic and Caculate Tput
    [Arguments]     ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}     ${Expected_Throughput_UL}    ${duration}
    power_ue.Prepare UE     ue_type=${ue_type}    ui_version=default
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}     duration=2000
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}     duration=2000
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}
    ${list_of_cell_ids}    Create list    68719438337
    power_ue.Check Tput     ue_type=${ue_type}     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_UL}
    power_ue.Check Tput     ue_type=${ue_type}     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_DL}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

Modify actEirpControl is true
    [Arguments]    ${parameters_to_add_via_api}    ${parameters_to_update_via_api}    ${timeout}=${60}
    ...            ${connection}=GNB_OAM    ${should_activate}=${True}
    Add eirpControlPowerReductionFactorList
    ${para_file_update}    coam_parameter.create_update_parameters_delta
    ...    parameters=${parameters_to_update_via_api}
    ...    connection=${connection}
    ${para_file_add}    coam_parameter.create_add_parameters_delta
    ...    parameters=${parameters_to_add_via_api}
    ...    connection=${connection}
    ${add_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file_add['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file_update['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    should_activate=${should_activate}
    ${msg_for_parameter_activation_not_executed}    Catenate    Parameter update activation for ${parameters_to_update_via_api} is not executed,
    ...    due to flag should_activate is set to ${should_activate}
    Run keyword if    '${should_activate}'=='${True}'
    ...    Should contain    ${update_via_api_status}    PASS    msg=parameters do not update successfully.    ignore_case=${True}
    ...    ELSE    Log to console     ${msg_for_parameter_activation_not_executed}
    Should contain    ${add_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    [Return]   ${update_via_api_status}    ${add_via_api_status}

Add eirpControlPowerReductionFactorList
    [Arguments]   ${is_need_to_check_validation_errors}=${True}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    Add_elements_1655   dist_name=${ADD_1655_EIRCP_CPRFLIST[0]}[dist_name]
    ...             filter_param=${ADD_1655_EIRCP_CPRFLIST[0]}[filter_param]
    ...             abbr=${ADD_1655_EIRCP_CPRFLIST[0]}[abbr]
    Coam Input Parameter value via webUI_1655   param_data=${PARAM_1655_EIRCP_CPRFLIST[0]}
    ...                                    node_index=${1}
    Add_elements_1655   dist_name=${ADD_1655_EIRCP_CPRFLIST[0]}[dist_name]
    ...             filter_param=${ADD_1655_EIRCP_CPRFLIST[0]}[filter_param]
    ...             abbr=${ADD_1655_EIRCP_CPRFLIST[0]}[abbr]
    Coam Input Parameter value via webUI_1655   param_data=${PARAM_1655_EIRCP_CPRFLIST[1]}
    ...                                    node_index=${2}
    Add_elements_1655   dist_name=${ADD_1655_EIRCP_CPRFLIST[0]}[dist_name]
    ...             filter_param=${ADD_1655_EIRCP_CPRFLIST[0]}[filter_param]
    ...             abbr=${ADD_1655_EIRCP_CPRFLIST[0]}[abbr]
    Coam Input Parameter value via webUI_1655   param_data=${PARAM_1655_EIRCP_CPRFLIST[2]}
    ...                                    node_index=${3}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM selenium logout

Add_elements_1655
    [Arguments]    ${dist_name}    ${filter_param}  ${abbr}
    selenium_coam.add_element    dist_name=${dist_name}
    ...                         filter_param=${filter_param}
    ...                         abbr=${abbr}

Coam Input Parameter value via webUI_1655
    [Arguments]    ${param_data}  ${node_index}
    selenium_coam.set_parameter_value    dist_name=${param_data}[dist_name]
    ...                                  filter_param=${param_data}[filter_param]
    ...                                  new_value=${param_data}[new_value]
    ...                                  abbr=${param_data}[abbr]
    ...                                  node_index=${node_index}
    ...                                  timeout=${120}

Load Case SCF and Commission SCF for 1178
    [Arguments]    ${scf_file}
    Selenium Login And Disable Screen Lock
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -46
    log to console    ${SCF_PATH}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min

get software version
    COAM Navigate to login page via webUI
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    Set Test Variable    ${current_version}    ${current_version['Active']}
    COAM selenium logout
    ${stream}    String.Get Substring    ${current_version}    0    8
    [Return]     ${stream}

Check for unexpected alarms
    Connect to gnb coam via ssl
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=GNB_OAM
