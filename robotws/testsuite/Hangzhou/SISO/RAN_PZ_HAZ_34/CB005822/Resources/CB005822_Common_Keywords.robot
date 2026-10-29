*** Settings ***
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/RUfile_opearte_common_keyword.robot

Documentation
...   author: yulu
...   contact: lu.1.yu@nokia-sbell.com
...   squad group: SG_02


*** Variables ***
${UL_THROUGHPUT}    100M
${DL_THROUGHPUT}    1400M

${UL_EXPECT_50M}    50
${DL_EXPECT_50M}    1200

${tmp_log_dir}      ${TS_LOG_PATH_BASE}

${vm_tmp_log_dir}    /tmp

${paths_file}        /mnt/factory/configs/unit/paths.txt

${ru_runtime_tar}     1011_ccsrt-runtime.tar.gz

*** Keywords ***
5822 SISO Coam Suite Setup
    SISO Coam Suite Setup
    ${version}     get software version for 5822
    Set suite variable    ${version}    ${version}
    Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T980/SCF_${version}_980.xml
    Add RU file on RU    file_path=${paths_file}   file_content=${PATHS_CONTENT}

get software version for 5822
    COAM Navigate to login page via webUI
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    COAM selenium logout
    ${stream}    String.Get Substring    ${current_version['Active']}    0    8
    [Return]     ${stream}

CB005822 Case Setup
    robot_common_operations.Common Case Setup
    COAM Create log directory
    Set suite variable    ${tmp_log_dir}    ${LOG_PATH}
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    10min    20 sec    Check GNB Sync status
    COAM Navigate to login page via webUI    download_dir=${vm_tmp_log_dir}
    ${backup_scf_file}    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    COAM selenium close browser
    Set Test Variable    ${backup_scf_file}
    Connect to Common Unit Master
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl

CB005822 Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run Keyword If Test Failed    SG2_Common_setup_teardown.COAM commission scf and wait cell setup    scf_file_path=${backup_scf_file}
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    ssh.Disconnect    connection=ASIK Master
    CI_interface.Common Case Teardown

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

UE Attach and Start Traffic
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${throughput_ul}     duration=2000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=2000
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

UE Attach and Start Traffic for Other
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${throughput_ul}     duration=2000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=2000
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    16056323
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

UE Attach and Start Traffic for peak
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${throughput_ul}     duration=6000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=6000
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    16056321
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    target_avg_percent=0.98    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    target_avg_percent=0.98    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

Lock all RUs
    [Arguments]  ${ru_index_list}
    ${led_status_list_lock}    create list    YELLOW YELLOW
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${rfsw_file_name}    Capture RFSW Log and Download    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status for 5822    log_name=${rfsw_file_name}
        selenium_coam.lock_ru    ru_index=${ru_index}
        sleep  15
        ${rfsw_file_name}    Capture RFSW Log and Download    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status for 5822    log_name=${rfsw_file_name}   timestamp=${new_timestamp}
        check LED list    matches=${mathes}    led_status_list=${led_status_list_lock}    exclude_led_status=GREEN GREEN
        ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        Check SOAP message_RU_lock    PC_soap_path=${PC_soap_path}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
    END

Get RU Runtime Log Old
    [Arguments]  ${log_name}=ru_log     ${timestamp}=${None}
    log to console    ${timestamp}
    Run  rm -rf ${TS_CASE_LOG_PATH}/${log_name}
    Run  unzip ${TS_CASE_LOG_PATH}/${log_name}.zip -d ${TS_CASE_LOG_PATH}/${log_name}
    Run  unzip ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_zip} -d ${TS_CASE_LOG_PATH}/${log_name}
    Run  unxz ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_xz}

Get RU Runtime Log New
    [Arguments]  ${log_name}=ru_log     ${timestamp}=${None}
    log to console    ${timestamp}
    Run  rm -rf ${TS_CASE_LOG_PATH}/${log_name}
    Run  unzip ${TS_CASE_LOG_PATH}/${log_name}.zip -d ${TS_CASE_LOG_PATH}/${log_name}
    Run  tar -zxvf ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_tar} -C ${TS_CASE_LOG_PATH}/${log_name}
	${log_list}    List Directory  ${TS_CASE_LOG_PATH}/${log_name}/var/log/
	${log_length}    Get Length    ${log_list}
	FOR    ${log_id}    IN RANGE    ${log_length}-2    0    -1
	    Run  zcat ${TS_CASE_LOG_PATH}/${log_name}/var/log/${log_list[${log_id}]} >> ${TS_CASE_LOG_PATH}/${log_name}/runtime_DEFAULT.log
	END
	Run  cat ${TS_CASE_LOG_PATH}/${log_name}/var/log/runtime.log >> ${TS_CASE_LOG_PATH}/${log_name}/runtime_DEFAULT.log

Get Last LED Timestamp and Status for 5822
    [Arguments]  ${log_name}=ru_log     ${timestamp}=${None}
	${mathes}    ${new_timestamp}    Run Keyword If  '${version}'=='SBTS24R3'
	...                                              Get RU Runtime Log Old    log_name=${log_name}    timestamp=${timestamp}
	...                              ELSE    Get RU Runtime Log New    log_name=${log_name}    timestamp=${timestamp}
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
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status for 5822    log_name=${rfsw_file_name}
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
        selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        Connect to all rus with allocated IP
        ${rfsw_file_name}    Capture RFSW Log and Download    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status for 5822    log_name=${rfsw_file_name}   timestamp=${new_timestamp}
        check LED list    matches=${mathes}    led_status_list=${led_status_list}    exclude_led_status=YELLOW YELLOW
        ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        Check SOAP message_RU_unlock    PC_soap_path=${PC_soap_path}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        sort list    ${cell_id_ru}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_id_ru}
    END

Capture RFSW Log and Download
    [Arguments]    ${ru_index}
    ${rfsw_log_path_on_ru}   Capture RFSW Log On RU    connection=RU_${ru_index}
    ${rfsw_path}    ${rfsw_file}    Split Path    ${rfsw_log_path_on_ru}
    ${rfsw_file_name}    ${rfsw_file_ext}    Split Extension    ${rfsw_file}d
    Download RU File To TestPC    ru_file_path=${rfsw_log_path_on_ru}    connection=RU_${ru_index}    download_dir=${TS_CASE_LOG_PATH}
    [Return]    ${rfsw_file_name}

UE Attach and Check 90percent of DL absolute maximum Tput
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${UL_THROUGHPUT}     duration=2000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${DL_THROUGHPUT}     duration=2000
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    16056321
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${UL_EXPECT_50M}    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${DL_EXPECT_50M}     target_avg_percent=0.9    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

Load Case SCF and Commission SCF for 5822
    [Arguments]    ${scf_file}
    Selenium Login And Disable Screen Lock
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -57
    Set suite variable     ${SCF_PATH}    ${SCF_PATH}
    log to console    ${SCF_PATH}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_file}
	Selenium Logout And Close Browser
    COAM Wait for gnb ready and cell setup    timeout=15 min

General_SiSo_KPI_Cell_lock_unlock_success_rate
    FOR    ${n}    IN RANGE    10
        General_SiSo_Cell_lock_and_unlock    with_call=${False}
        sleep    5s
    END

General_SiSo_Beamforming_calibration for 5822
    [Arguments]  ${check_time}=5
    Perform BTS Site Reset    download_dir=${TS_CASE_LOG_PATH}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    log to console    sleep ${check_time}min to get beamforming calibration
    sleep  ${check_time}min
    ${ru_index_list}    get all ru index
    ${ru_num}    get length    ${ru_index_list}
    ${collect_file_mum}    set variable    ${0}
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${status}    run keyword and return status    Collect RF Logs To TestPC    ru_index=${ru_index}    log_name=ru_fault_history_log
        run keyword if    ${status}    run keyword and continue on failure    Check fault history log
                                                                              ...      log_name=ru_fault_history_log
                                                                              ...      log_path=${TS_CASE_LOG_PATH}
        ${collect_file_mum}    set variable if    not ${status}    ${collect_file_mum+1}    ${collect_file_mum}
    END
    ${bf_status}    Run Keyword And Return Status    Check RU Beamforming Status    check_count=${True}
    should be true  ${bf_status}
    should be true  ${collect_file_mum}<${ru_num}

Restart CPE 5G19-A before start traffic
    [Arguments]   ${pc_index}
    Run Keyword And Ignore Error     csn.disconnect    connection=cygwin
    Connect to control pc via cygwin    ue_index=${pc_index}
    Sleep    2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s KLT241000AF1 shell reboot    connection=cygwin
    sleep   3s
