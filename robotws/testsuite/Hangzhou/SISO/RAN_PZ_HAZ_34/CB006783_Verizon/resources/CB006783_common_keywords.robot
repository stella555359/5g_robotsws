*** Settings ***
Documentation    This is for KDDI common keywords
...              Author: lanwen.cai
...              Squard: HZ SG8

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000643/Resource/team_steps.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Variables   ../TestData/variables_6783_E2E.py

*** Variables ***
@{cell_id1}    ${1}
*** Keywords ***
Each_RF_module_reset_on_WebEm
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of radio module reset triggered by user from GUI with use of RP1 messaging.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.02.2021  - Created
    ...    *******************
    ...    shufei.chen@nokia-sbell.com
    [Arguments]  ${with_peak}=${False}  ${duration}=${30}
#    ${ru_index_list}  Get All RU Index
    Selenium Login And Disable Screen Lock
    Sleep    10s
    ${ru_list}    Create list    1  8  9
    FOR  ${ru_index}  IN  @{ru_list}
        log to console    \n***Perform RF Module Reset from GUI***
        Perform Each RU Reset    ru_index=${ru_index}   download_dir=${SAVE LOG DIRECTORY}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}
    END
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]  Selenium Logout And Close Browser


check RU power
    [Documentation]   Auther: shufei.chen@nokia-sbell.com
    ${ru_list}    Create list    1  8  9
    connect to common unit master
    FOR  ${ru_index}  IN  @{ru_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
        check ru power via command    ru_index=${ru_index}
    END
    [Return]  run keywords  csn.disconnect   connection=RU_${ru_index}    AND
    ...    csn.Disconnect   connection=ASIK Master

check ru power via command
    [Documentation]   Auther: shufei.chen@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}
    FOR  ${i}    IN RANGE    2    10
        run keyword and ignore error    check RU power with dapd    made_ip_addr=192.168.102.${i}    made_usr=root
        ...    made_pwd=ZCS81C3RIAZegZtvIn43EaAdA4oMSNFkSBrj4iMwTuI=
        ...    made_alias=made_dapd_${i}    ru_alias=RU_${ru_index}
    END



Perform Each RU Reset
    [Documentation]   Auther: shufei.chen@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}   ${download_dir}=${TS_CASE_LOG_PATH}
    ${ru_index}  Convert To Integer    ${ru_index}
    selenium_coam.reset_ru  ru_index=${ru_index}
    Sleep    5s

E2E_Snapshot_capture_via_WEBUI
    [Documentation]  Author: shufei.chen
    ...              Description: Snapshot logs will be stored under the indicate download_dir
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}    ${url}=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${temp_dir_for_save_snapshot}    Set variable    /tmp/snapshot_ta
    Create directory    ${temp_dir_for_save_snapshot}
    COAM Navigate to login page via webUI    download_dir=${temp_dir_for_save_snapshot}    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.snapshot_collection_settings    coverage=All log files    save_location=Local
    ${temp_snapshot_file_path}    selenium_coam.collect_snapshot
    sleep   5s
    wait until keyword succeeds    15min    30s    Should Contain    ${temp_snapshot_file_path}    Snapshot_MRBTS
    [Teardown]   Selenium Logout And Close Browser

Parameter_change_validation_Activation_pmax
    [Documentation]   Auther: shufei.chen@nokia-sbell.com
    [Arguments]   ${dist_name}=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1
    ...    ${filter_param}=Maximum output power
    ...    ${new_value}=${31}    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    start login WEBUI
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    Close Start Up View    timeout=60
    ${orig_value}    get origin pmax
    Log to console    Update pmax value from ${orig_value} to ${new_value}
    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep   5s
    ${parameter_now}    get origin pmax
    Should be equal as strings    ${parameter_now}    ${new_value}    msg=paramter updated failed
    Log to console    modify the parameter to orgin vaule ${orig_value}  in teardown
    [Teardown]    run keywords
    ...    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    new_value=${orig_value}
    ...    AND    selenium_coam.validate_plan    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    AND   sleep    5s    AND
    ...    COAM selenium logout

E2E_multi_cell_L3call_data_transfer
    [Documentation]   Auther: shufei.chen@nokia-sbell.com
    [Arguments]    ${ue_index_list}    ${tput_expect}    ${duration}=30    ${protocol}=udp
    ...    ${attach_mode}=NSA    ${gnb_index}=${0}    ${du_index}=0    ${connection}=GNB_OAM
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${iperf_type}=${None}
    ${cell_list}    Create list    ${1}
    E2E_L3call    cell_list=${cell_list}    ue_index_list=${ue_index_list}    tput_expect=${tput_expect}    duration=${duration}
    ...    protocol=${protocol}    attach_mode=${attach_mode}    gnb_index=${gnb_index}    du_index=${du_index}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    iperf_type=${iperf_type}

E2E_L3call
      [Arguments]    ${cell_list}    ${ue_index_list}    ${tput_expect}    ${duration}=30    ${protocol}=udp
      ...    ${attach_mode}=NSA    ${gnb_index}=${0}    ${du_index}=0    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
      ...    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${iperf_type}=${None}
      ${ue_tput_mapping}    create dictionary
      ${ue_and_cell}    create dictionary
      ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
      FOR    ${ue_index}    IN    @{ue_index_list}
          ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
          ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
          log to console    \n***Prepare for UE_${ue_index}***
          run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
          ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
          Connect to Common Unit Master  alias=${alias}
          connect to gnb coam via ssl    connection=${connection}
          ${time}  get time  epoch
          ${attach_log}    set variable    /tmp/5Grach.txt
          ${local_dir}    set variable    ${SAVE LOG DIRECTORY}/attach_ue_${ue_index}/${time}
          run keyword and ignore error    run keywords    Create directory    ${local_dir}    AND
          ...    csn.download file    remote_path=${attach_log}    local_path=${local_dir}/5Grach.txt   connection=${alias}
          ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=${attach_log}
          ...    alias=${alias}    connection=${connection}
          run keyword and ignore error    csn.Execute    rm ${attach_log}   connection=${alias}
          set to dictionary  ${ue_and_cell}  ${ue_index}  ${cell_id}
          log to console    \n***Start traffic for UE_${ue_index}***
          ${duration_call}    Evaluate    ${duration}+${600}
          ${dl_tp}    set variable    ${tput_expect['${cell_id}']['dl_tp']}
          ${ul_tp}    set variable    ${tput_expect['${cell_id}']['ul_tp']}
          power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
          ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}
          power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
          ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}    data_amount=2M
      END
      FOR    ${ue_index}    IN    @{ue_index_list}
          log to console    \n***Start Collect Throughput for UE_${ue_index}***
          ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    ue_index=${ue_index}
          set to dictionary    ${ue_tput_mapping}    ${ue_index}    ${tput_log}
      END
      FOR    ${ue_index}    IN    @{ue_index_list}
          ${cell_id}     Get From Dictionary    ${ue_and_cell}     ${ue_index}
          ${dl_exp}    set variable    ${tput_expect['${cell_id}']['dl_exp']}
          ${ul_exp}    set variable    ${tput_expect['${cell_id}']['ul_exp']}
          ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
          ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
          ${cell_id}    Create List    ${cell_id}
          ${tput_log}    Get From Dictionary    ${ue_tput_mapping}     ${ue_index}
          log to console    \n***Check tput for UE_${ue_index}***
          power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
          ...    dltarget_throughput=${dl_exp}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
          log to console    \n***Stop traffic and Detach for UE_${ue_index}***
          run keyword and ignore error  power_ue.Stop traffic   ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
          run keyword and ignore error  power_ue.Stop traffic   ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
          run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_type}    ue_index=${ue_index}
      END

E2E_Cell_lock_and_unlock
    [Documentation]    *****************
    ...    - [TEST PURPOSE] To verify cell lock/ unlock functionality
    ...      during normal operation (OnAir state).
    ...    *******************
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}
    Get X2 link shutdown waiting time
    #${cell_id_list}  Get All Cell Id
    #${cell_num}    get length  ${cell_id_list}
    ${cell_list}    Create list    1  8  9
    ${cell_num}    get length  ${cell_list}
    Lock and Unlock Cells or Groups and L3  lock_list=${cell_list}  is_group=${False}  with_call=${with_call}  with_peak=${with_peak}
    run keyword if  ${cell_num}>1  E2E Lock and Unlock all Cells or Groups  lock_list=${cell_list}  is_group=${False}

E2E_Each_RF_module_lock_unlock
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of locking and unlocking.
    ...    ******************
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    Sleep    10s
    ${ru_list}    Create list    1  8  9
    FOR  ${ru_index}  IN  @{ru_list}
        selenium_coam.lock_ru    ru_index=${ru_index}
        wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${ru_index}
    END
    connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_list}
        selenium_coam.unlock_ru    ru_index=${ru_index}
        wait until keyword succeeds  5min  20sec  RU Should Be unLocked  ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    8min    30s    COAM Check GNB cell on air
    [Teardown]    Run Keywords    excute ru unlock    ru_index_list=${ru_list}    AND
    ...    Selenium Logout And Close Browser

E2E Lock and Unlock all Cells or Groups
    [Arguments]  ${lock_list}  ${is_group}=${True}
    ${output}   set variable if      ${is_group}==${False}   all cells    all cell groups
    log to console  \n***Lock ${output} and check status***
    Lock cells or groups and check status  lock_list=${lock_list}  is_group=${is_group}  check_alarm=${False}  gnb_type='${gNb_CuType}'
    log to console  \n***unLock ${output} and check status***
    Unlock cells or groups and check status  lock_list=${lock_list}  is_group=${is_group}  check_alarm=${False}  gnb_type='${gNb_CuType}'

eLLF_PTP_Failure_with_call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify when set wrong input sync for RAU
    ...    the syncstatus and lockstatus changed right both on webUI and RU soap log, then verify data transfer
    ...    *******************
    ...    melinda.gao@nokia-sbell.com
    [Arguments]
    ${sync_old}    get sync info of GNB
    set suite variable  ${sync_old}
    set sync info of GNB
    check sync status change of GNB
    Wait For Expect Fault Present    faultId=${16}    timeout=1200
    Wait For Expect Fault Present    faultId=${4298}    timeout=1200
#    check RU sync info from SOAP_file    status='abnormal'
    set sync info of GNB    syncinput=${sync_old['syncinput']}    acceptclock=${sync_old['acceptclock']}
    Wait For Expect Fault To Disappear    faultId=${16}    timeout=1200
    Wait For Expect Fault To Disappear    faultId=${4298}    timeout=1200
#    check RU sync info from SOAP_file    status='normal'
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
    ...    tput_from=self_define

check RU sync info from SOAP_file
    [Arguments]    ${status}
    Connect to Common Unit Master
    ${ru_index_list}    Create List    ${1}  ${8}  ${9}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${alias}    set variable    RU_${ru_index}
        csn.execute    command=cd /ram;gzip -d UnitOAM_SOAP_Log0.xml.gz    connection=${alias}
        ${RU_SOAP_log_remote_path}    set variable    /ram/UnitOAM_SOAP_Log0.xml
        ${RU_SOAP_log_local_dir}    set variable    ${TS_CASE_LOG_PATH}/RU_${ru_index}_SOAP_LOG
        create directory    ${RU_SOAP_log_local_dir}
        log    ${RU_SOAP_log_local_dir}
        csn.download_file    remote_path=${RU_SOAP_log_remote_path}    local_path=${RU_SOAP_log_local_dir}    connection=${alias}
        ${RU_SOAP_file}    set variable    ${RU_SOAP_log_local_dir}/UnitOAM_SOAP_Log0.xml
        log    ${RU_SOAP_file}
        log to console    start check RU_${ru_index}'s sync info from SOAP file......
        ${syncstate}    get syncstate from soap log    local_soap_path=${RU_SOAP_file}
        run keyword if    ${status}=='abnormal'    should be equal    ${syncstate[0]}    FREERUN
        ...   ELSE    should be equal    ${syncstate}    ${syncstate_ru_ok}
        ${lockstate}    get lockstate from soap log    local_soap_path=${RU_SOAP_file}
        run keyword if    ${status}=='abnormal'    should be equal    ${lockstate[-1]}    UNLOCKED
        ...   ELSE    should be equal    ${lockstate[-1]}    LOCKED
        ${acceptclock}    get acceptclock from soap log    local_soap_path=${RU_SOAP_file}
        @{acceptclock_list}    split string    ${acceptclock[-1]}    ,
        ${accept_clock_value_modify}    convert to string    ${accept_clock_value_modify[0]}
        run keyword if    ${status}=='abnormal'    should be equal    ${acceptclock[-1]}    ${accept_clock_value_modify}
        ...   ELSE    should be equal    ${acceptclock_list}    ${sync_old['acceptclock']}
        csn.Disconnect    connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master
