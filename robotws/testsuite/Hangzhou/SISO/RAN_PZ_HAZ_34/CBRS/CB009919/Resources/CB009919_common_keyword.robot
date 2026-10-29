*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/SBTS_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../resources/cbrs_common_keywords.robot
Variables    ./variables_9919.py
Library    ../lib/CB009919.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot

Documentation
...    author: Jiangjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${throughput_dl}    100
${throughput_ul}    40
${target_throughput_dl_20M_1_5}    56
${target_throughput_ul_20M_1_5}    26
${target_throughput_dl_10M_1_6}    36
${target_throughput_ul_10M_1_6}    12
${target_throughput_dl_10M_1_7}    36.8
${target_throughput_ul_10M_1_7}    12
${ipaddr_9919}          ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${username_9919}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${password_9919}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${CB009919_json_path}    ${CURDIR}/json
${disable_actcbrs}    ${CB009919_json_path}/disable_actcbrs.json

*** Keywords ***
CB009919 CBRS Suite Setup
    Download Sas Server
    set suite variable    ${test_teardown_fail}    ${True}
    robot_common_operations.CommonSuiteSetup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    sleep    10
#    run keyword if    '${if_commissioning}'=='True'
#    ...    Commissioning SCF And Check RU On Air    scf_file_path=${Golden_SCF_Path}
    &{fault_7312}     Create Dictionary     faultId=${7312}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    &{fault_6826}     Create Dictionary     faultId=${6826}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7312}    ${fault_7313}    ${fault_6826}
    set suite variable  ${ALLOWED_FAULT}
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    add allowed cbrs history fault to the allowed history fault list
    delete_icmp_policy
    Run Keyword And Ignore Error    kill SAS server started by manual

CB009919 CBRS Test Setup
    robot_common_operations.CommonCaseSetup
    log to console    Active_SW_version:${Active_SW_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[1]    ${False}
    Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    set test variable    ${scf_path}
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser

Calibration_Cal_Software_Component_Operation_Verification_20Mhz_frame_configuration1_5
    log to console    Commison scf
    ${SCF_20M_1_5}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_20M_1_5_
    COAM Commission with scf file  scf_file_path=${SCF_20M_1_5}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    sleep    120s
    start SAS server
    sleep    240s
    Wait until keyword succeeds    10min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${cell_numbers}    Get LTE Cell Numbers
    ${cell_numbers_double}    Evaluate   ${cell_numbers}+${cell_numbers}
    log to console    login RU
    connect to common unit master    alias=ASIK Master
    Connect to RU With Allocated IP
    log to console    execute bfcali -stat
    ${msg}    csn.execute    command=bfcali -stat    connection=RU
    log to console    check from the response info
    ${calibration_attempts}    check_calibration_attempts    msg=${msg}
    ${successful_calibrations}    check_successful_calibrations    msg=${msg}
    ${len_calibration_attempts}    Get length    ${calibration_attempts}
    ${len_successful_calibrations}    Get length    ${successful_calibrations}
    should be equal    ${calibration_attempts}    ${successful_calibrations}
    should be equal    ${len_calibration_attempts}    ${cell_numbers_double}
    should be equal    ${len_successful_calibrations}    ${cell_numbers_double}
    log to console    Perform LTE L3call	
    make_call_4G    ue_type_4G=nokia_fastmile    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800
    sleep    300s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=nokia_fastmile
    check_tput_for_4G_call    ue_type_4G=nokia_fastmile    target_throughput_dl=${target_throughput_dl_20M_1_5}
    ...    target_throughput_ul=${target_throughput_ul_20M_1_5}    duration=5m    target_avg_percent=0.95    min_percent=0.85    ignore_time=60
   [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    stop_traffic_and_detach_for_4G_call    ue_type_4G=nokia_fastmile
    ...    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

General_SiSo_Beamforming_Calibration_Cal_Software_Component_Operation_Verification_20Mhz_frame_configuration1_6
    log to console    Commison scf
    ${SCF_20M_1_6}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_20M_1_6_
    COAM Commission with scf file  scf_file_path=${SCF_20M_1_6}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    sleep    120s
    start SAS server
    sleep    240s
    Wait until keyword succeeds    10min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${mrbtsID}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${SCF_20M_1_6}
    log to console    check beamforming calibration
    ${cell_numbers}    Get LTE Cell Numbers
    ${cell_info}    coam.get_cells_info    cell_type=lte    connection=GNB_OAM
    ${cell_id}    set variable    ${cell_info[0]['globalCellId']}
    ${cell_numbers_double}    Evaluate   ${cell_numbers}+${cell_numbers}
    log to console    login RU
    connect to common unit master    alias=ASIK Master
    Connect to RU With Allocated IP
    log to console    execute bfcali -stat
    ${msg}    csn.execute    command=bfcali -stat    connection=RU
    log to console    check from the response info
    ${calibration_attempts}    check_calibration_attempts    msg=${msg}
    ${successful_calibrations}    check_successful_calibrations    msg=${msg}
    ${len_calibration_attempts}    Get length    ${calibration_attempts}
    ${len_successful_calibrations}    Get length    ${successful_calibrations}
    should be equal    ${calibration_attempts}    ${successful_calibrations}
    should be equal    ${len_calibration_attempts}    ${cell_numbers_double}
    should be equal    ${len_successful_calibrations}    ${cell_numbers_double}
    log to console    change desiredChBw and ChBw to 10M
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${ipaddr_9919}
    ...                    username=${username_9919}
    ...                    password=${password_9919}
    selenium_coam.disable_message_box
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${cell_id}/CBSDCEL-0
        ...    filter_param=Desired Channel Band Width    p_name=desiredChBw    value=10MHz
    ${item2}    create dictionary  dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${cell_id}/LNCEL_TDD-0
        ...    filter_param=Channel bandwidth TDD    p_name=chBw    value=10 MHz
    append to list    ${modify_params}    ${item}
    append to list    ${modify_params}    ${item2}
    Modify Parameters On Webem LTE    modify_params=${modify_params}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=lte
    log to console    peform L3 call with current 10M cell
    make_call_4G    ue_type_4G=mtk_lte    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800
    check_tput_for_4G_call    ue_type_4G=mtk_lte    target_throughput_dl=${target_throughput_dl_10M_1_6}
    ...    target_throughput_ul=${target_throughput_ul_10M_1_6}    duration=7m    ignore_time=200
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=mtk_lte
    [Teardown]    run keywords    run keyword and ignore error    csn.disconnect    connection=ASIK Master    AND
    ...    run keyword and ignore error    selenium_coam.logout

General_SiSo_E2E_system_setup_with_data_transfer_conducted_10Mhz_20Mhz_frame_configuration1_7
    log to console    Commison scf
    ${SCF_10M_20M_1_7}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_10M_20M_1_7_
    COAM Commission with scf file  scf_file_path=${SCF_10M_20M_1_7}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    sleep    120s
    start SAS server
    sleep    240s
    Wait until keyword succeeds    10min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    make_call_4G    ue_type_4G=nokia_fastmile    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800
    sleep    300s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=nokia_fastmile
    check_tput_for_4G_call    ue_type_4G=nokia_fastmile    target_throughput_dl=${target_throughput_dl_10M_1_7}
    ...    target_throughput_ul=${target_throughput_ul_10M_1_7}    duration=5m    target_avg_percent=0.95    min_percent=0.85    ignore_time=60
   [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    stop_traffic_and_detach_for_4G_call    ue_type_4G=nokia_fastmile
    ...    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

General_SiSo_Commissioning_BTS_Template_Commissioning_3_Cell_per_Loki
    log to console    Commison scf
    ${SCF_3CC}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_3CC_
    COAM Commission with scf file  scf_file_path=${SCF_3CC}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    sleep    120s
    start SAS server
    sleep    240s
    Wait until keyword succeeds    10min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${cell_numbers}    Get LTE Cell Numbers
    ${cell_numbers_double}    Evaluate   ${cell_numbers}+${cell_numbers}
    log to console    login RU
    connect to common unit master    alias=ASIK Master
    Connect to RU With Allocated IP
    log to console    execute bfcali -stat
    ${msg}    csn.execute    command=bfcali -stat    connection=RU
    log to console    check from the response info
    ${calibration_attempts}    check_calibration_attempts    msg=${msg}
    ${successful_calibrations}    check_successful_calibrations    msg=${msg}
    ${len_calibration_attempts}    Get length    ${calibration_attempts}
    ${len_successful_calibrations}    Get length    ${successful_calibrations}
    should be equal    ${calibration_attempts}    ${successful_calibrations}
    should be equal    ${len_calibration_attempts}    ${cell_numbers_double}
    should be equal    ${len_successful_calibrations}    ${cell_numbers_double}
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=ASIK Master
