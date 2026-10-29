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
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000679_AA/Resources/5GC000679_common_keyword_Dingli.robot

Documentation
...   author: yulu
...   contact: lu.1.yu@nokia-sbell.com
...   squad group: SG_02

*** Variables ***
${tmp_log_dir}      ${TS_LOG_PATH_BASE}
${vm_tmp_log_dir}    /tmp

${UL_THROUGHPUT_NR}    100Mbits/sec
${DL_THROUGHPUT_NR}    1400Mbits/sec
${UL_EXPECT_NR}    50
${DL_EXPECT_NR}    340

${UL_THROUGHPUT_LTE}    11Mbits/sec
${DL_THROUGHPUT_LTE}    130Mbits/sec
${UL_EXPECT_LTE}    10
${DL_EXPECT_LTE}    120

*** Keywords ***
9125 Coam Suite Setup
    [Arguments]    ${asik_addr_temp}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...            ${asik_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...            ${asik_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    SISO Coam Suite Setup
    ${version}     get software version for 9125
    Load Case SCF and Commission SCF for 9125       scf_file=commissionings/HGZ/7_5_UTE5G402T796/${version}_9125.xml

CB009125_SR Case Setup
    robot_common_operations.Common Case Setup
    COAM Create log directory
    Set suite variable    ${tmp_log_dir}    ${LOG_PATH}
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    10min    20 sec    Check GNB Sync status
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    COAM Navigate to login page via webUI    download_dir=${vm_tmp_log_dir}
    ${backup_scf_file}    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    COAM selenium logout
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
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -60
    log to console    ${SCF_PATH}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min

Check GNB Sync status
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Check GNB Sync status
    ${sync_info}    coam.get_bts_sync_source_status    connection=${connection}
    @{sync_status}    Set variable    ${sync_info['syncSourceInfo']}
    &{sync_status}    Set variable    ${sync_status[0]}
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

spark send CMD on UE1
    [Arguments]    ${ue_index}    ${ue_alias}=UE_${ue_index} 
    [Documentation]    send CMD for UE by spark
    spark.send_at_command_on_ue    command=AT+CGATT=0    ue_alias=${ue_alias}   
    spark.send_at_command_on_ue    command=at+cgdcont=1,"IPV4V6","wap1.nokia.com"    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=AT+GTACT=14    ue_alias=${ue_alias}    
    log to console      "attach_${ue_alias}"
    spark.send_at_command_on_ue    command=AT+CGATT=1     ue_alias=${ue_alias}
    sleep      5s

spark send CMD on UE2
    [Arguments]    ${ue_index}    ${ue_alias}=UE_${ue_index} 
    [Documentation]    send CMD for UE by spark  
    spark.send_at_command_on_ue    command=AT+CGATT=0    ue_alias=${ue_alias}   
    spark.send_at_command_on_ue    command=AT+CGDCONT=1,"IPV4V6","dxdata2"    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=AT+GTACT=2    ue_alias=${ue_alias}    
    log to console      "attach_${ue_alias}"
    spark.send_at_command_on_ue    command=AT+CGATT=1     ue_alias=${ue_alias}
    sleep      5s

Spark UE NR Attach
    [Arguments]    ${n}    ${get_spark_license}=False
    [Documentation]    Attach
    ...          :param  n: The ue_index of Spark
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${n}
    log to console      "Prepare_UE${n}"
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=${get_spark_license}
    sleep      3s
    log to console      "send_CMD_UE${n}"
    Run keyword and ignore error    spark send CMD on UE1    ue_index=${n}

Spark UE LTE Attach
    [Arguments]    ${n}    ${get_spark_license}=False
    [Documentation]    Attach
    ...          :param  n: The ue_index of Spark
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${n}
    log to console      "Prepare_UE${n}"
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=${get_spark_license}
    sleep      3s
    log to console      "send_CMD_UE${n}"
    Run keyword and ignore error    spark send CMD on UE2    ue_index=${n}

spark UE NR attach and start DLUL traffic
    [Arguments]     ${data_transfer_dl}    ${data_transfer_ul}    ${n}    ${apn_address}
    ...             ${ue_mode}    ${target_throughput_ul}    ${target_throughput_dl}    
    [Documentation]    Attach_start_DL_UL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${n}
    Set test variable    ${ue_type}
    Run Keyword And Continue On Failure    Spark UE NR Attach    n=${n}
    sleep      2s
    power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=120    ue_index=${n}
    ${list_of_cell_ids}    Create list    177143809
    Run keyword and ignore error     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}
    ...                     ue_index=${n}    target_avg_percent=0.9
    Run keyword and ignore error     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}
    ...                     ue_index=${n}    target_avg_percent=0.9
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl    ue_index=${n}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul    ue_index=${n}

spark UE LTE attach and start DLUL traffic
    [Arguments]     ${data_transfer_dl}    ${data_transfer_ul}    ${n}    ${apn_address}
    ...             ${ue_mode}    ${target_throughput_ul}    ${target_throughput_dl}
    [Documentation]    Attach_start_DL_UL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${n}
    Set test variable    ${ue_type}
    Run Keyword And Continue On Failure    Spark UE LTE Attach    n=${n}
    sleep      2s
    power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=120    ue_index=${n}
    ${list_of_cell_ids}    Create list    2767873
    Run keyword and ignore error     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}
    ...                     ue_index=${n}    target_avg_percent=0.9
    Run keyword and ignore error     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}
    ...                     ue_index=${n}    target_avg_percent=0.9
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl    ue_index=${n}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul    ue_index=${n}

Multiple UE Attach NR and LTE then Start Traffic
    spark UE NR attach and start DLUL traffic     data_transfer_dl=${DL_THROUGHPUT_NR}
    ...                                           data_transfer_ul=${UL_THROUGHPUT_NR}
    ...                                           n=0
    ...                                           ue_mode=SA
    ...                                           apn_address=wap1nokiacom
    ...                                           target_throughput_ul=${UL_EXPECT_NR}
    ...                                           target_throughput_dl=${DL_EXPECT_NR}
    spark UE LTE attach and start DLUL traffic    data_transfer_dl=${DL_THROUGHPUT_LTE}
    ...                                           data_transfer_ul=${UL_THROUGHPUT_LTE}
    ...                                           n=1
    ...                                           ue_mode=NSA
    ...                                           apn_address=dxdata2
    ...                                           target_throughput_ul=${UL_EXPECT_LTE}
    ...                                           target_throughput_dl=${DL_EXPECT_LTE}

Multiple UE Attach NR and LTE
    Spark UE NR Attach    n=0
    Spark UE LTE Attach    n=1
