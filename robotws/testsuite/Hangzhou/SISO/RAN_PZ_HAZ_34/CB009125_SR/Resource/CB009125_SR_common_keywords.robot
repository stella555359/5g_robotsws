*** Settings ***
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Library     taf.analyzer.pcap        WITH NAME    pcap
Library     taf.transport.ssh    WITH NAME    ssh
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/data_analysis.py
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/RUfile_opearte_common_keyword.robot


Documentation
...   author: yulu
...   contact: lu.1.yu@nokia-sbell.com
...   squad group: SG_02

*** Variables ***
${tmp_log_dir}      ${TS_LOG_PATH_BASE}

${vm_tmp_log_dir}    /tmp

${UL_THROUGHPUT_NR}    100M
${DL_THROUGHPUT_NR}    1400M
${UL_EXPECT_NR}    50
${DL_EXPECT_NR}    340

${UL_THROUGHPUT_LTE}    11
${DL_THROUGHPUT_LTE}    130
${UL_EXPECT_LTE}    10
${DL_EXPECT_LTE}    120

${UL_EXPECT_NR_9125}    50
${DL_EXPECT_NR_9125}    1200

${UL_EXPECT_LTE_9125}    11
${DL_EXPECT_LTE_9125}    125

${swipe}    500 2050 500 800
${brand}    samsung

${paths_file}        /mnt/factory/configs/unit/paths.txt

*** Keywords ***
9125 Coam Suite Setup
    SISO Coam Suite Setup
    ${version}     get software version for 9125
    Load Case SCF and Commission SCF for 9125       scf_file=commissionings/HGZ/7_5_UTE5G402T980/${version}_9125_SR.xml
    Add RU file on RU    file_path=${paths_file}   file_content=${PATHS_CONTENT}

CB009125_SR Case Setup
    robot_common_operations.Common Case Setup
    COAM Create log directory
    Set suite variable    ${tmp_log_dir}    ${LOG_PATH}
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    10min    20 sec    Check GNB Sync status
    COAM Navigate to login page via webUI    download_dir=${vm_tmp_log_dir}
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    ${backup_scf_file}    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    COAM selenium close browser
    Set Test Variable    ${backup_scf_file}
    Connect to Common Unit Master

CB009125_SR Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run Keyword If Test Failed    SG2_Common_setup_teardown.COAM commission scf and wait cell setup    scf_file_path=${backup_scf_file}
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    ssh.Disconnect    connection=ASIK Master
    CI_interface.Common Case Teardown

Load Case SCF and Commission SCF for 9125
    [Arguments]    ${scf_file}
    Selenium Login And Disable Screen Lock
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -59
    log to console    ${SCF_PATH}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min

Check GNB Sync status
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Check GNB Sync status
    ${sync_info}    coam.get_bts_sync_source_status    connection=${connection}
    @{sync_state}    Set variable    ${sync_info['syncSourceInfo']}
    &{sync_status}    Set variable    ${sync_state[0]}
    Run keyword and continue on failure    Should be equal as strings    ${sync_info['syncMode']}    PhaseSync
    ...                                    msg=Current synchronization mode is not PhaseSync mode    ignore_case=${True}
    Run keyword and continue on failure    Should be equal as strings    ${sync_status['status']['availability']}    Available
    ...                                    msg=Current synchronization status is not available    ignore_case=${True}
    Run keyword and continue on failure    Should contain any    ${sync_info['tuningMode']}    Normal tuning    Normal
    ...                                    msg=Current synchronization tuning mode is abnormal    ignore_case=${True}

get software version for 9125
    COAM Navigate to login page via webUI
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    COAM selenium logout
    ${stream}    String.Get Substring    ${current_version['Active']}    0    8
    [Return]     ${stream}

Lock all RUs
    [Arguments]  ${ru_index_list}
    ${led_status_list_lock}    create list    YELLOW YELLOW
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${rfsw_file_name}    Capture RFSW Log and Download    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status for 9125    log_name=${rfsw_file_name}
        selenium_coam.lock_ru    ru_index=${ru_index}
        sleep  15
        ${rfsw_file_name}    Capture RFSW Log and Download    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status for 9125    log_name=${rfsw_file_name}   timestamp=${new_timestamp}
        check LED list    matches=${mathes}    led_status_list=${led_status_list_lock}    exclude_led_status=GREEN GREEN
        ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        Check SOAP message_RU_lock    PC_soap_path=${PC_soap_path}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
    END

Capture RFSW Log and Download
    [Arguments]    ${ru_index}
    ${rfsw_log_path_on_ru}   Capture RFSW Log On RU    connection=RU_${ru_index}
    ${rfsw_path}    ${rfsw_file}    Split Path    ${rfsw_log_path_on_ru}
    ${rfsw_file_name}    ${rfsw_file_ext}    Split Extension    ${rfsw_file}d
    Download RU File To TestPC    ru_file_path=${rfsw_log_path_on_ru}    connection=RU_${ru_index}    download_dir=${TS_CASE_LOG_PATH}
    [Return]    ${rfsw_file_name}

Get Last LED Timestamp and Status for 9125
    [Arguments]  ${log_name}=ru_log     ${timestamp}=${None}
    Run  rm -rf ${TS_CASE_LOG_PATH}/${log_name}
    Run  unzip ${TS_CASE_LOG_PATH}/${log_name}.zip -d ${TS_CASE_LOG_PATH}/${log_name}
    Run  unzip ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_zip} -d ${TS_CASE_LOG_PATH}/${log_name}
    Run  unxz ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_xz}
    ${content}  get_binary_file  ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_log}
    ${content}  Convert To String    ${content}
    ${new_content}  ${new_timestamp}  Cut Out Runtime Log  content=${content}  timestamp=${timestamp}
    ${matches}    Get Regexp Matches    ${new_content}    New status for led 0: Colors: (.+?) Priority:    1
    [Return]  ${matches}  ${new_timestamp}

Unock all RUs
    [Arguments]  ${ru_index_list}
    ${led_status_list}    create list   GREEN GREEN
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${rfsw_file_name}    Capture RFSW Log and Download    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status for 9125    log_name=${rfsw_file_name}
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
        selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        Connect to all rus with allocated IP
        ${rfsw_file_name}    Capture RFSW Log and Download    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status for 9125    log_name=${rfsw_file_name}   timestamp=${new_timestamp}
        check LED list    matches=${mathes}    led_status_list=${led_status_list}    exclude_led_status=YELLOW YELLOW
        ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        Check SOAP message_RU_unlock    PC_soap_path=${PC_soap_path}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        sort list    ${cell_id_ru}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_id_ru}
    END

Multiple UE Attach NR and LTE then Start Traffic
    UE NR Attach and Start Traffic     throughput_ul=${UL_THROUGHPUT_NR}
    ...                           throughput_dl=${DL_THROUGHPUT_NR}
    ...                           target_throughput_ul=${UL_EXPECT_NR}
    ...                           target_throughput_dl=${DL_EXPECT_NR}
    UE LTE Attach and Start Traffic    throughput_ul=${UL_THROUGHPUT_LTE}
    ...                           throughput_dl=${DL_THROUGHPUT_LTE}
    ...                           target_throughput_ul=${UL_EXPECT_LTE}
    ...                           target_throughput_dl=${DL_EXPECT_LTE}

Multiple UE Attach NR and LTE
    UE NR Attach
    UE LTE Attach

Multiple UE Attach NR and LTE then Check UL DL maximum Tput
    UE NR Attach and Start Traffic check maximun Tput
    UE LTE Attach and Start Traffic check maximun Tput

Multiple UE Attach NR and LTE then Check UL DL when delete one of LTE cell
    run keyword and continue on failure    UE NR Attach and Traffic first     throughput_ul=${UL_THROUGHPUT_NR}
    ...                           throughput_dl=${DL_THROUGHPUT_NR}
    ...                           target_throughput_ul=${UL_EXPECT_NR}
    ...                           target_throughput_dl=${DL_EXPECT_NR}
    run keyword and continue on failure    UE LTE Attach and Traffic first    throughput_ul=${UL_THROUGHPUT_LTE}
    ...                           throughput_dl=${DL_THROUGHPUT_LTE}
    ...                           target_throughput_ul=${UL_EXPECT_LTE}
    ...                           target_throughput_dl=${DL_EXPECT_LTE}
    delete one of LTE cell
    run keyword and continue on failure    UE NR Attach and Traffic again
    run keyword and continue on failure    UE LTE Attach and Traffic again
    ${version}     get software version for 9125
    Load Case SCF and Commission SCF for 9125       scf_file=commissionings/HGZ/7_5_UTE5G402T980/${version}_9125_SR.xml

delete one of LTE cell
    [Arguments]    ${is_need_to_check_validation_errors}=${True}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    selenium_coam.remove_object   object_name=MRBTS-980/LNBTS-980/LNCEL-1
    selenium_coam.remove_object   object_name=MRBTS-980/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1
    selenium_coam.remove_element    dist_name=MRBTS-980/LNBTS-980/PSGRP-1
    ...                             filter_param=Load-based power saving cell list
    ...                             abbr=lbpsCellList
    ...                             node_index=${1}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM selenium logout

UE LTE Attach and Traffic first
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${2}
    Set Test Variable      ${ue_type_1}      ${ue_type}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type_1}    ue_index=${2}
    Preparation and execution for andriod UE Attach    UE_type=samgsung    ue_index=${2}    home=${3}    airplane=960 343    close_task=535 1865
    power_ue.UE Attach     ue_type=${ue_type_1}    ue_index=${2}
    power_ue.Start traffic     ue_type=${ue_type_1}     direction=ul     throughput=${throughput_ul}     duration=4200    ue_index=${2}
    ...                           ue_mode=NSA     apn_address=dxdata2     iperf_type=via_command
    power_ue.Start traffic     ue_type=${ue_type_1}     direction=dl     throughput=${throughput_dl}     duration=4200    ue_index=${2}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=120    ue_index=${2}
    ${list_of_cell_ids}    Create list    250880
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_1}
    ...                     direction=ul    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}
    ...                     ue_index=${2}
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_1}
    ...                     direction=dl    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}
    ...                     ue_index=${2}


UE NR Attach and Traffic first
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Test Variable      ${ue_type_0}      ${ue_type}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type_0}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type_0}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type_0}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type_0}     direction=ul     throughput=${throughput_ul}     duration=4200    process_num=5
    power_ue.Start traffic     ue_type=${ue_type_0}     direction=dl     throughput=${throughput_dl}     duration=4200
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type_0}    duration=2m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    16056321
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_0}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_0}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog

UE LTE Attach and Traffic again
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type_1}    duration=120    ue_index=${2}
    ${list_of_cell_ids}    Create list    250880
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_1}
    ...                     direction=ul    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${UL_EXPECT_LTE}
    ...                     ue_index=${2}
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_1}
    ...                     direction=dl    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${DL_EXPECT_LTE}
    ...                     ue_index=${2}
    power_ue.Stop traffic     ue_type=${ue_type_1}     direction=dl    ue_index=${2}
    power_ue.Stop traffic     ue_type=${ue_type_1}     direction=ul    ue_index=${2}

UE NR Attach and Traffic again
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type_0}    duration=2m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    16056321
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_0}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${UL_EXPECT_NR}    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_0}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${DL_EXPECT_NR}    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type_0}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type_0}     direction=ul

UE LTE Attach and Start Traffic
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${2}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${2}
    Preparation and execution for andriod UE Attach    UE_type=samgsung    ue_index=${2}    home=${3}    airplane=960 343    close_task=535 1865
    power_ue.UE Attach     ue_type=${ue_type}    ue_index=${2}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${throughput_ul}     duration=1200    ue_index=${2}
    ...                           ue_mode=NSA     apn_address=dxdata2    iperf_type=via_command
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=1200    ue_index=${2}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=120    ue_index=${2}
    ${list_of_cell_ids}    Create list    250880
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}
    ...                     ue_index=${2}    target_avg_percent=0.9
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}
    ...                     ue_index=${2}    target_avg_percent=0.9
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl    ue_index=${2}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul    ue_index=${2}

UE NR Attach and Start Traffic
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${throughput_ul}     duration=3600    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=3600
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    16056321
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

UE LTE Attach
   ${ue_type}    translate_power_ue_type_from_testline    ue_index=${2}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${2}
    Preparation and execution for andriod UE Attach    UE_type=samgsung    ue_index=${2}    home=${3}    airplane=960 343    close_task=535 1865
    power_ue.UE Attach     ue_type=${ue_type}    ue_index=${2}

UE NR Attach
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}

UE LTE Attach and Start Traffic check maximun Tput
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${2}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${2}
    Preparation and execution for andriod UE Attach    UE_type=samgsung    ue_index=${2}    home=${3}    airplane=960 343    close_task=535 1865
    power_ue.UE Attach     ue_type=${ue_type}    ue_index=${2}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${UL_THROUGHPUT_LTE}     duration=1200    ue_index=${2}
    ...                           ue_mode=NSA     apn_address=dxdata2     iperf_type=via_command
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${DL_THROUGHPUT_LTE}     duration=1200    ue_index=${2}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=120    ue_index=${2}
    ${list_of_cell_ids}    Create list    250880
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${UL_EXPECT_LTE_9125}
    ...                     ue_index=${2}
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${DL_EXPECT_LTE_9125}
    ...                     ue_index=${2}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl    ue_index=${2}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul    ue_index=${2}

UE NR Attach and Start Traffic check maximun Tput
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${UL_THROUGHPUT_NR}     duration=3600    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${DL_THROUGHPUT_NR}     duration=3600
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    16056321
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${UL_EXPECT_NR_9125}    target_avg_percent=0.9    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${DL_EXPECT_NR_9125}     target_avg_percent=0.9    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

Restart CPE 5G19-A before start traffic for 9125
    [Arguments]   ${pc_index}
    Run Keyword And Ignore Error     csn.disconnect    connection=cygwin
    Connect to control pc via cygwin    ue_index=${pc_index}
    Sleep    2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s KLT241000AF1 shell reboot    connection=cygwin
    sleep   3s
