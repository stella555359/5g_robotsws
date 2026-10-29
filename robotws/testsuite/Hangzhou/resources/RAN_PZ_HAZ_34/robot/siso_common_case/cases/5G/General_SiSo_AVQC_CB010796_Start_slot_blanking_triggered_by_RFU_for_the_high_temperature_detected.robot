*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot


*** Keywords ***
General_SiSo_AVQC_CB010796_Start_slot_blanking_triggered_by_RFU_for_the_high_temperature_detected
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to activate disableSchedAssistRfCooling false and get RRU
    ...    temperature High and Make call to check the DL Tput average value is 40%~60%
    ...    ******************
    ...    History of changes
    ...   ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1677?filter=-1
    ...    ******************
    ...    - 02.02.2024 - - Created
    ...    - 11.03.2024 - - update ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1867?filter=-1
    ...    - 24.06.2024 - - update by lijie: https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10166
    ...    - 25.06.2024 - - update by lijie: https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10252
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]    ${target_value_blank_off}=85    ${target_value_blank_on}=89    ${target_value_blank_timer}=60    ${connection}=GNB_OAM
    ...  ${ue_num_each_call}=1    ${suite_name}=default    ${test_name}=default  ${duration}=${60}  ${upload_duration}=${True}   ${ru_index}=${None}
    IF    ${ru_index}==${None}
        ${ru_index_list}    Get RU index list    connection=${connection}
    ELSE
        ${ru_index_list}    create list    ${ru_index}
    END
    Set Test Variable    ${ru_index_list}
    FOR    ${ru_index}    IN    @{ru_index_list}
        Modify T_sym_blank parameter    ru_index=${ru_index}    target_value_blank_off=${target_value_blank_off}
        ...    target_value_blank_on=${target_value_blank_on}    target_value_blank_timer=${target_value_blank_timer}
        #    delete this step because https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10252
        COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
        ${cell_list}    get all cell id    ru_index=${ru_index}
        ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
        log to console   generate peak information
        ${cell_and_peak_info}    generate peak information     cell_list=${cell_list}    duration=${duration}
        ...    suite_name=${suite_name}    test_name=${test_name}
        log to console   Make Dl Call And Check Tput 90%
        Make Dl Call And Check Tput   ue_index_list=${ue_index_list}   cell_list=${cell_list}  cell_and_peak_info=${cell_and_peak_info}
        ...   avg_expect_rate=0.9  direction=DL  duration=${duration}
        Adjusting RRU Temperature    ru_index=${ru_index}
        log to console   wait 5min after change Temperature parameter
        Selenium Login And Disable Screen Lock
        Wait Until Keyword Succeeds    5min    5sec   Check START_SLOTBLANKING from btslog
        ${ue_index_list}  ${ue_and_cell}  ${cell_and_peak_info}  Make Dl Call With RRU Tempearature High  ue_index_list=${ue_index_list}
        ...   cell_and_peak_info=${cell_and_peak_info}  direction=DL   duration=120
        power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    upload_duration=${upload_duration}
        ...    check_source=Aasyslog
        ${status_l3call_upper_limit}   Run Keyword And Return Status    UE Verify DL Peak Throughput With RRU Tempearature High
        ...   ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}  cell_list=${cell_list}
        ...   cell_and_peak_info=${cell_and_peak_info}  target_avg_rate_peak=0.55   duration=${duration}
        Run Keyword And Continue On Failure    UE Verify DL Peak Throughput With RRU Tempearature High
        ...   ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}  cell_list=${cell_list}
        ...   cell_and_peak_info=${cell_and_peak_info}  target_avg_rate_peak=0.35   duration=${duration}
        Run Keyword And Ignore Error  Ue Stop DL UL Traffic and Detach RRU High Temperture    ue_index_list=${ue_index_list}   direction=DL
        Run Keyword If   ${status_l3call_upper_limit}   Fail   average Tput over 0.6 after modify RU temperature
        #    delete this step because https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10252
    END
    [Teardown]    CB010796_Teardown

CB010796_Teardown
    FOR    ${ru_index}    IN    @{ru_index_list}
        Modify T_sym_blank parameter    ru_index=${ru_index}
    END
    [Teardown]  Selenium Logout And Close Browser

Check START_SLOTBLANKING from btslog
    [Arguments]
    log to console    \n Get START_SLOTBLANKING from btslog
    ${cmd}     Catenate
        ...    cat /tmp/btslog2/SYSLOG_*.LOG|grep 'START_SLOTBLANKING'
    ${result}=     Run    command=${cmd}
    log to console    \n Get START_SLOTBLANKING from btslog is ${result}
    Should Not Be Empty     ${result}

Check Temperature NIDD parameter value
    [Arguments]     ${dist_name}=MRBTS-${nrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-1    ${filter_param}=RF temperature state
    ...   ${target_value}=Normal
    ${temperature_Status}    Get Single Parameter Value on WebUI    dist_name=${dist_name}
    ...     filter_param=${filter_param}
    log to console    \n Get Temperature NIDD parameter value is ${temperature_Status}
    Should Be Equal As Strings   ${temperature_Status}   ${target_value}   ignore_case=${True}
    [Return]   ${temperature_Status}

Set disableSchedAssistRfCooling NIDD parameter value
    [Arguments]     ${value}=false
    Selenium Login And Disable Screen Lock
    log to console    \n Set disableSchedAssistRfCooling NIDD parameter value is ${value}
    ${cell_list}    get all cell id
    ${modify_params}  create list
    FOR    ${cell_id}    IN    @{cell_list}
        ${disableSchedAssistRfCooling_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=Disable schedule assisted RF cooling  p_name=disableSchedAssistRfCooling  value=${value}
        append to list  ${modify_params}   ${disableSchedAssistRfCooling_dic}
    END
    Modify Parameters On Webem    modify_params=${modify_params}
    [Teardown]  Selenium Logout And Close Browser

Modify T_sym_blank parameter
    [Arguments]     ${target_value_blank_off}=105  ${target_value_blank_on}=109  ${target_value_blank_timer}=180
     ...   ${ru_index}=1    ${connection}=GNB_OAM
    log to console    \n Modify T_sym_blank parameter
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${boundary}  get the boundary of stream with 24R2   stream=${stream}
    ${tcs_parameter}    Set Variable If   '${boundary}'=='old_version'   tcs   tcs_parameters
    ${blank_off_init_value}  ${blank_on_init_value}  ${blank_timer_init_value}   Get T_sym_blank Value from Json File
    ...    key_word_T_sym_blank_off=T_sym_blank_off    key_word_T_sym_blank_on=T_sym_blank_on
    ...    key_word_T_sym_blank_timer=T_sym_blank_timer   tcs_parameter=${tcs_parameter}    ru_index=${ru_index}
    log to console    \n blank_off_init_value is ${blank_off_init_value},blank_on_init_value is ${blank_on_init_value}
   Modify T_sym_blank Value In Json File   init_value_blank_off=${blank_off_init_value}  target_value_blank_off=${target_value_blank_off}
    ...   init_value_blank_on=${blank_on_init_value}   target_value_blank_on=${target_value_blank_on}
    ...   init_value_blank_timer=${blank_timer_init_value}   target_value_blank_timer=${target_value_blank_timer}   cmd=rm -rf
    ...   ru_index=${ru_index}   connection=${connection}  blank_off=T_sym_blank_off   blank_on=T_sym_blank_on
    ...   blank_timer=T_sym_blank_timer   tcs_parameter=${tcs_parameter}
    log to console    \n Perform RU Reset
    Perform RU Reset    ru_index=${ru_index}    download_dir=${SAVE LOG DIRECTORY}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    Selenium Login And Disable Screen Lock
    [Return]   ${blank_off_init_value}   ${blank_on_init_value}  ${blank_timer_init_value}
    [Teardown]  Selenium Logout And Close Browser

Make Dl Call And Check Tput
    [Arguments]  ${ue_index_list}  ${cell_list}  ${cell_and_peak_info}
    ...   ${avg_expect_rate}=0.9  ${duration}=${60}   ${direction}=DL
    ${ue_and_cell}    Ue Attach and Start DL UL Traffic RRU High Temperature    ue_index_list=${ue_index_list}
    ...   cell_and_peak_info=${cell_and_peak_info}
    ...   direction=${direction}  duration=${duration}
    FOR  ${cell_id}  IN  @{cell_list}
        ${cell_id}    convert to string    ${cell_id}
        ${cell_info}    get from dictionary    ${cell_and_peak_info}    ${cell_id}
        set to dictionary    ${cell_info}    avg_expect_rate=${avg_expect_rate}
        set to dictionary    ${cell_and_peak_info}    ${cell_id}=${cell_info}
    END
    log to console   UE Verify Peak Throughput RRU High Temperature avg_expect_rate is ${avg_expect_rate}
    UE Verify Peak Throughput RRU High Temperature   ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}
    ...   cell_and_peak_info=${cell_and_peak_info}
    ...   direction=${direction}  duration=${duration}
    [Teardown]     Ue Stop DL UL Traffic and Detach RRU High Temperture    ue_index_list=${ue_index_list}   direction=DL

Make Dl Call With RRU Tempearature High
    [Arguments]  ${ue_index_list}  ${cell_and_peak_info}  ${duration}=${60}   ${direction}=DL
    ${ue_and_cell}    Ue Attach and Start DL UL Traffic RRU High Temperature   ue_index_list=${ue_index_list}
    ...   cell_and_peak_info=${cell_and_peak_info}
    ...   direction=${direction}   duration=${duration}
    [Return]    ${ue_index_list}  ${ue_and_cell}  ${cell_and_peak_info}

UE Verify DL Peak Throughput With RRU Tempearature High
    [Documentation]  ue_and_cell:{'0': '1', '1' : '2'}
    [Arguments]  ${ue_index_list}=${None}  ${ue_and_cell}=${None}  ${cell_list}=${None}  ${dl_exp}=300  ${ul_exp}=100
    ...    ${duration}=${60}  ${direction}=DL    ${gnb_ssl_connection}=GNB_OAM    ${cell_and_peak_info}=${None}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${upload_tp}=${True}    ${scf_path}=${Case_SCF_Path}
    ...    ${check_source}=Aasyslog   ${target_avg_rate_peak}=0.35   ${min_expect_rate_peak}=0.1
    log to console    \nUE Verify Peak Throughput target_avg_rate_peak is ${target_avg_rate_peak}
    FOR  ${cell_id}  IN  @{cell_list}
        ${cell_id}    convert to string    ${cell_id}
        ${cell_info}    get from dictionary    ${cell_and_peak_info}    ${cell_id}
        set to dictionary    ${cell_info}    avg_expect_rate=${target_avg_rate_peak}
        set to dictionary    ${cell_info}    min_expect_rate=${min_expect_rate_peak}
        set to dictionary    ${cell_and_peak_info}    ${cell_id}=${cell_info}
    END
    ${path}    ${scf_name}    split path    path=${scf_path}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        ${testline_name}    Get Testline Name
        ${peak_percent}    get_ue_peak_percent_from_ue_mapping_file    testline_name=${testline_name}    ue_index=${ue_index}
        ...    scf_name=${scf_name}
        run keyword if    ${peak_percent}!=1
        ...    log to console    \nupdate target_avg_percent and min_expect_rate to value multiply by ${peak_percent}
        ${cell_id}    get from dictionary    ${ue_and_cell}    ${ue_index}
        ${dl_exp}  ${ul_exp}  ${avg_expect_rate}  ${min_expect_rate}  ${duration}    get_verify_traffic_information  cell_id=${cell_id}
        ...    dl_exp=${dl_exp}  ul_exp=${ul_exp}   duration=${duration}    avg_expect_rate=${target_avg_percent}
        ...    min_expect_rate=${min_percent}    cell_and_peak_info=${cell_and_peak_info}
        ${avg_expect_rate}    evaluate    ${avg_expect_rate}*${peak_percent}
        ${min_expect_rate}    evaluate    ${min_expect_rate}*${peak_percent}
        ${cell_id}    get from dictionary    ${ue_and_cell}    ${ue_index}
        ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${gnb_ssl_connection}
        ${nrCellIdentity}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
        ${cells}    Create List    ${nrCellIdentity}
        power_ue.Check Tput    ue_type=nokia_fastmile    direction=${direction}
        ...    target_throughput=${dl_exp}   log=${log_path}  cells=${cells}  target_avg_percent=${avg_expect_rate}
        ...     min_percent=${min_expect_rate}  check_source=${check_source}   ue_index=${ue_index}  upload_tp=${upload_tp}
    END

Ue Attach and Start DL UL Traffic RRU High Temperature
    [Documentation]   direction: value, DL,or UL,or BOTH
    [Arguments]  ${ue_index_list}    ${dl_tp}=300M  ${ul_tp}=100M  ${duration}=${60}  ${cell_and_peak_info}=${None}   ${protocol}=udp
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${check_wait_time}=30    ${iperf_type}=via_command   ${ui_version}=default
    ...    ${4G_check}=${False}    ${bip_log_path}=${SAVE LOG DIRECTORY}  ${bip_log}=${False}    ${reboot_ue}=${False}
    ...    ${scf_path}=${Case_SCF_Path}   ${direction}=BOTH    ${attach_cell_id}=${None}
    log to console    \nUe Attach and Start DL UL Traffic
    ${ue_number}  get length  ${ue_index_list}
    ${ue_and_cell}    create dictionary
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${direction_dl}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   DL   ignore_case=${True}
    ${direction_ul}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   UL   ignore_case=${True}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        run keyword if   ${bip_log}   run keyword and ignore error   Start BIP Logs Capture
        run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}   ui_version=${ui_version}
        ${pci}    Get Ue should attached pci    ue_index=${ue_index}    scf_path=${scf_path}    mobile_network_system=NR
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${reboot_ue}    pci=${pci}
    	run keyword if   ${bip_log}   run keyword and ignore error   Stop BIP Logs Capture And DownLoad Logs   bip_log_path=${bip_log_path}
        Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
        ${attach_cell_id}    get_ue_attached_cell_id_by_pci    pci=${pci}    connection=${connection}
        ${4G_check_input}    set variable    ${4G_check}
        ${4G_check}    run keyword if    '${ue_type}'=='mtk'    set variable    ${4G_check}    ELSE    set variable    ${False}
        power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed}    4G_check=${4G_check}
        ${4G_check}    set variable    ${4G_check_input}
        ${cell_id}    Run Keyword If    '${attach_cell_id}'=='${None}'
        ...    Get Cell ID from Aasyslog    alias=${alias}    connection=${connection}    ue_index=${ue_index}
        ...    ELSE    Set Variable    ${attach_cell_id}
        set to dictionary  ${ue_and_cell}  ${ue_index}  ${cell_id}
        ${dl_tp}  ${ul_tp}  ${duration_call}  get_start_traffic_information    cell_id=${cell_id}    ue_number=${ue_number}  dl_tp=${dl_tp}
        ...    ul_tp=${ul_tp}    duration=${duration}    cell_and_peak_info=${cell_and_peak_info}
        ...    check_wait_time=${check_wait_time}
        ${ul_iperf_process}    Get Ul Iperf Process    scf_name=${scf_name}
        ${ul_tp}    Calculate Send Tput with Process    tput=${ul_tp}    iperf_process=${ul_iperf_process}
        Run Keyword If  ${direction_dl}  power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}
        ...    ELSE IF  ${direction_ul}  power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}    data_amount=2M
        ...    process_num=${ul_iperf_process}
        ...    ELSE   Run Keywords   power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}
        ...    AND  power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}    data_amount=2M
        ...    process_num=${ul_iperf_process}
    END
    [Return]  ${ue_and_cell}

UE Verify Peak Throughput RRU High Temperature
    [Documentation]  ue_and_cell:{'0': '1', '1' : '2'}
    [Arguments]  ${ue_index_list}  ${ue_and_cell}  ${dl_exp}=300  ${ul_exp}=100  ${duration}=${60}  ${gnb_ssl_connection}=GNB_OAM
    ...    ${cell_and_peak_info}=${None}    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${upload_tp}=${True}
    ...    ${upload_duration}=${True}    ${scf_path}=${Case_SCF_Path}   ${direction}=BOTH  ${check_source}=Aasyslog
    log to console    \nUE Verify Peak Throughput
    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    upload_duration=${upload_duration}
    ...    check_source=Aasyslog
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${direction_dl}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   DL   ignore_case=${True}
    ${direction_ul}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   UL   ignore_case=${True}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        ${testline_name}    Get Testline Name
        ${peak_percent}    get_ue_peak_percent_from_ue_mapping_file    testline_name=${testline_name}    ue_index=${ue_index}
        ...    scf_name=${scf_name}
        run keyword if    ${peak_percent}!=1
        ...    log to console    \nupdate target_avg_percent and min_expect_rate to value multiply by ${peak_percent}
        ${cell_id}    get from dictionary    ${ue_and_cell}    ${ue_index}
        ${dl_exp}  ${ul_exp}  ${avg_expect_rate}  ${min_expect_rate}  ${duration}    get_verify_traffic_information  cell_id=${cell_id}
        ...    dl_exp=${dl_exp}  ul_exp=${ul_exp}   duration=${duration}    avg_expect_rate=${target_avg_percent}
        ...    min_expect_rate=${min_percent}    cell_and_peak_info=${cell_and_peak_info}
        ${avg_expect_rate}    evaluate    ${avg_expect_rate}*${peak_percent}
        ${min_expect_rate}    evaluate    ${min_expect_rate}*${peak_percent}
        ${cell_id}    get from dictionary    ${ue_and_cell}    ${ue_index}
        ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${gnb_ssl_connection}
        ${nrCellIdentity}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
        ${cells}    Create List    ${nrCellIdentity}
        Run Keyword If  ${direction_dl}  power_ue.Check Tput    ue_type=nokia_fastmile    direction=${direction}
        ...    target_throughput=${dl_exp}   log=${log_path}  cells=${cells}  target_avg_percent=${avg_expect_rate}
        ...     min_percent=${min_expect_rate}  check_source=${check_source}   ue_index=${ue_index}  upload_tp=${upload_tp}
        ...    ELSE IF  ${direction_ul}   power_ue.Check Tput    ue_type=nokia_fastmile    direction=${direction}
        ...    target_throughput=${ul_exp}   log=${log_path}  cells=${cells}  target_avg_percent=${avg_expect_rate}
        ...     min_percent=${min_expect_rate}  check_source=${check_source}   ue_index=${ue_index}  upload_tp=${upload_tp}
        ...    ELSE   power_ue.Check Bi Tput   ue_type=nokia_fastmile    cells=${cells}    ultarget_throughput=${ul_exp}
        ...    dltarget_throughput=${dl_exp}    target_avg_percent=${avg_expect_rate}    min_percent=${min_expect_rate}    upload_tp=${upload_tp}
        ...    ue_index=${ue_index}    log=${log_path}
    END

Ue Stop DL UL Traffic and Detach RRU High Temperture
    [Arguments]  ${ue_index_list}    ${iperf_type}=via_command    ${protocol}=udp    ${reboot_ue}=${False}    ${reboot_limit_time}=${1}
    ...   ${direction}=BOTH
    log to console    \nUe Stop DL UL Traffic and Detach
    ${direction_dl}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   DL   ignore_case=${True}
    ${direction_ul}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   UL   ignore_case=${True}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        Run Keyword If  ${direction_dl}  run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}
        ...    direction=dl    ue_index=${ue_index}   protocol=${protocol}
        ...    ELSE IF  ${direction_ul}   run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}
        ...    direction=ul    ue_index=${ue_index}   iperf_type=${iperf_type}    protocol=${protocol}
        ...    ELSE   Run Keywords   run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}
        ...    direction=dl    ue_index=${ue_index}   protocol=${protocol}
        ...    AND   run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}
        ...    direction=ul    ue_index=${ue_index}   iperf_type=${iperf_type}    protocol=${protocol}
        ${reboot_ue_flag}    ${reboot_time}    Get Ue Reboot Flag    ue_index=${ue_index}    reboot_ue=${reboot_ue}
        ...    reboot_limit_time=${reboot_limit_time}
        ${status}    run keyword and return status    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
        ...    power_reset=${reboot_ue_flag}
        ${reboot_time}   run keyword if    ${reboot_ue_flag} and ${status}    evaluate    ${reboot_time}+${1}
        ...    ELSE    set variable    ${reboot_time}
        set to dictionary    ${ue_reboot_dict}    UE_${ue_index}=${reboot_time}
    END
