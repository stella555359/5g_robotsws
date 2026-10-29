*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Library           BuiltIn
Library           taf.transport.ssh      WITH NAME    csn
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/licence_keeper.py
Library           licence_keeper.licence_keeper     WITH NAME    LK
Library           ./5GC002056-1348-A21_common_keywords.py
Library           ute_reporting_portal
Library     taf.ul.mobile.ui.android    WITH NAME    android_mobile
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/aasyslog_tput.py    WITH NAME    aastp
*** Variables ***
${gNB_ip}          ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${eNB_ip}          ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${gnb_ip_737}      ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${gnb737_cell_dist_name}      /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-10432/NRCELL_L-1
${gnb7372_cell_dist_name}     /MRBTS-1/RAT-1/NRTS-4/NRBTS_L-10431/NRCELL_L-1
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${serial_Number}          ${tl.ues[0].serial_number}
${Control_PC_IP}              ${tl.ues[0].ssh_connection_details.addr}
${Control_PC_USERNAME}        ${tl.ues[0].ssh_connection_details.username}
${Control_PC_PASSWORD}        ${tl.ues[0].ssh_connection_details.password}
${cell_1}    ${170901505}
${cell_2}    ${170901506}
*** Keywords ***
Common Case Setup
    log to console    Block Cell 737
    Block Cell_737       dist_name=${gnb737_cell_dist_name}
    log to console    Setup Commission SCF_4G...
    Setup Commission SCF_4G
    sleep   5min
    modify enb defaultLnRelGnbCellId parameter
    Commission GNB SCF

Block Cell_737
    [Arguments]      ${connection}=GNB_OAM    ${dist_name}=${gnb737_cell_dist_name}
    Connect to gnb coam via ssl     bts_host=${gnb_ip_737}
    ${info}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState}    set variable      ${info['stateInfo']['blockingState']}
    run keyword if    '${blockingState}'=="Unblocked"
    ...    coam.block_cell     dist_name=${MR_NR_BTS1_NRCELL}        connection=${connection}
    sleep     5s
    ${info1}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState1}    set variable      ${info1['stateInfo']['blockingState']}
    should be true    '${blockingState1}'=="Blocked"
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Setup Commission SCF_4G
    [Arguments]    ${connection}=ENB_OAM
    Connect to gnb coam via ssl    bts_host=${eNB_ip}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
    COAM Commission with scf file    scf_file_path=${CURDIR_path}SCF_SBTS22R2_4G.xml    connection=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

modify enb defaultLnRelGnbCellId parameter
    [Arguments]     ${value}=${0}
    log to console  modify enb defaultLnRelGnbCellId parameter
    Connect to gnb coam via ssl    bts_host=${Enb_ip}    username=${gNB_username}    password=${gNB_password}    connection=ENB_OAM
    ${dict}    create dictionary    parameterName=defaultLnRelGnbCellId    operation=update    value=${value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-10432/LNBTS-10432/LNCEL-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=ENB_OAM
    [Teardown]    coam.Teardown     connection=ENB_OAM

#Switch UE to NSA model
#    [Arguments]     ${mode_name}=5G/LTE/3G/2G (auto connect)    ${apn_NSA}=dxdata1
#    Android Mobile Setup
#    android_mobile.switch_network_mode    mode_name=${mode_name}    mobile=test
#    android_mobile.switch_apn    apn_name=${apn_NSA}      mobile=test
#    ${access_name}   android_mobile.get_access_point_name         mobile=test
#    log to console    ${access_name}
#    android_mobile.disable_volte_calls      mobile=test
#    [Teardown]    android_mobile.teardown    mobile=test
#
#Android Mobile Setup
#    [Arguments]     ${ui_version}=one ui 3.1      ${serial_number}=${serial_number}     ${port}=22    ${alias}=test
#    ...     ${host}=${Control_PC_IP}      ${username}=${Control_PC_USERNAME}     ${password}=${Control_PC_PASSWORD}
#    android_mobile.setup
#    ...   ui_version=${ui_version}
#    ...   host=${host}
#    ...   username=${username}
#    ...   password=${password}
#    ...   port=${port}
#    ...   serial_number=${serial_number}
#    ...   alias=${alias}
########### Commission SCF #################
Commission GNB SCF
    [Arguments]
    Log To Console  Commission GNB SCF
    Set Default scf name    SBTS_scf_name=SCF_SBTS00_1348    Branch_scf_name=SCF_SBTS22R2_1348
    Setup Commission SCF    gNB_ip=${gNB_ip}    default_scf=${default_scf}
    Wait Until Keyword Succeeds   20min     1min    Check BTS Cell On Air
    log to console    Commission GNB scf successful

Set Default scf name
    [Arguments]    ${SBTS_scf_name}    ${Branch_scf_name}    ${connection}=GNB_OAM
    Log To Console  Set Default scf name
    Connect to gnb coam via ssl     connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    set suite variable    ${version_list}
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}${SBTS_scf_name}.xml
    ...    ${CURDIR_path}${Branch_scf_name}.xml
    set suite variable    ${default_scf}
    log to console   ${default_scf}
    log to console   Set Default scf name successful
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Setup Commission SCF
    [Arguments]  ${gNB_ip}    ${default_scf}     ${connection}=GNB_OAM
    Log To Console  Setup Commission SCF
    Connect to gnb coam via ssl     connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Check BTS Cell On Air
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
    ${status}            coam.get_bts_statuses       connection=${connection}
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections   connection=${connection}

########### modify SCF #################
Modify GNB parameter_noPrachMultiplexing
    log to console    Modify parameter_noPrachMultiplexing
    Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_noPrachMultiplexing}     gNB_ip=${gNB_ip}

Modify GNB parameter_PrachMultiplexing
    log to console    Modify parameter_PrachMultiplexing
    Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_PrachMultiplexing}     gNB_ip=${gNB_ip}

Modify Common parameter via Coam
    [Arguments]  ${input_list}  ${gNB_ip}  ${connection}=GNB_OAM
    FOR    ${item}    IN    @{input_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air
        Connect to gnb coam via ssl     connection=${connection}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]
        ...    value=${dict_value}[2]    operation=update    skip_parameter_relation_errors=${True}
        ...    should_activate=${True}    connection=${connection}
        sleep    2min
    END
    Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air
    log to console  change parameter successful
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

#################   UE attach/dettach  ##################
attach power ue
    [Arguments]    ${ue_index}    ${ue_type}
    log to console       Prepare UE_${ue_index},and attach
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}     5Grach_ed=${5Grach_ed_0}    4G_check=False

attach power ue for xiaomi
    [Arguments]    ${ue_index}    ${ue_type}
    log to console       Prepare UE_${ue_index},and attach
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    Set all Xiaomi variable
    ${5Grach_ed_0}    xiaomi_UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}     5Grach_ed=${5Grach_ed_0}    4G_check=False

Set all Xiaomi variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    932 1633
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Preparation and execution for Commercial xiaomi_UE Attach
    [Documentation]    UE attach, make Commercial is on Airplane mode in default before, then Determine if UE has
    ...    attached to confirm whether the button was clicked once or twice
    ...    :param  UE_IP_net: check UP IP if eaqul this IP_net.
    ...    :param  UE_type: UE type
    ...    :param  ue_index: The list index from tl.ues[]
    [Arguments]    ${UE_IP_net}=127.0.0    ${UE_type}=${brand}    ${ue_index}=${0}    ${retry}=${3}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${home}=${home}    ${airplane}=${airplane}    ${close_task}=${close_task}
    Get Commercial UE IP    ue_index=${ue_index}
    ${passed}=    Run Keyword And Return Status    Should Contain    ${UE_IP}    ${UE_IP_net}

    FOR   ${index}    IN RANGE    ${retry}
        run keyword if    '${passed}'=='${True}'
    ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
    ...    Start TTI trace log    AND
    ...    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    ...    close_task=${close_task}    AND
    ...    Log to console    INFO:click AIRPLANE once for ${UE_type} UE attach.    AND
    ...    Stop TTI trace log    AND
    ...    sleep  1min    AND
    ...    Get Commercial UE IP    ue_index=${ue_index}    AND
    ...    Compare UE IP if is assigned on for loop    AND
    ...    Exit For Loop If    '${compare}'=='${True}'
    ...    ELSE
    ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
    ...    Start TTI trace log    AND
    ...    Commercial UE click AIRPLANE twice    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    ...    close_task=${close_task}    AND
    ...    Log to console    INFO:click AIRPLANE twice for ${UE_type} UE attach.    AND
    ...    Stop TTI trace log    AND
    ...    sleep  1min    AND
    ...    Get Commercial UE IP    ue_index=${ue_index}    AND
    ...    Compare UE IP if is assigned on for loop    AND
    ...    Exit For Loop If    '${compare}'=='${True}'
    END

new_xiaomi UE Attach
    [Arguments]    ${ue_index}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${du_index}=0
    ...    ${log_type}=Aasyslog    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  gnb_index: The list index from tl.gnbs[], it will use the index gnb for attach check
    ...  :param  hwcheck_index: The list index with mapping as 0->ASIK 1->ABIL1 2->ABIL2 3ABIL3, it will use the
    ...          mapping HW to check the ue attach status
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2lo
    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2hidu
    Preparation and execution for Commercial xiaomi_UE Attach    ue_index=${ue_index}
    Log    click Airplane mode switch to disable its function so that make UE attach
    [Return]    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    ${hwcheck_index}    ${log_type}
    ...    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}

xiaomi_UE Attach
    [Arguments]    ${ue_type}   ${attach_mode}=5G_SA   ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=0    ${hwcheck_index}=${1}
    ...    ${ue_alias}=UE_${ue_index}   ${abil_index}=${1}    ${log_type}=Aasyslog    ${interval}=${1}    ${power_reset}=False   ${retry}=${2}
    ...    ${vdu_index}=0
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  power_reset: <str> used to choose whether use power on or not in huawei spark,
    ...                       if it set to true, ue attach will use power on
    ...  :param retry: retry times for ue attach.
    ${output}    run keyword    new_xiaomi UE Attach   ue_index=${ue_index}
    ...                                                 gnb_index=${gnb_index}
    ...                                                 hwcheck_index=${hwcheck_index}
    ...                                                 ue_alias=${ue_alias}
    ...                                                 abil_index=${abil_index}
    ...                                                 du_index=${du_index}
	...                                                 vdu_index=${vdu_index}
    ...                                                 log_type=${log_type}
    ...                                                 attach_mode=${attach_mode}
    ...                                                 interval=${interval}
    ...                                                 power_reset=${power_reset}
    ...                                                 retry=${retry}
    [Return]    ${output}

Start TTI trace log
    log to console     Start TTI trace log capturing
    sleep   5s
    Start TTI trace log capturing

Stop TTI trace log
    log to console     Stop TTI trace log capturing
    sleep   15s
    Stop TTI trace log capturing
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
    ...    local_path=${TS_CASE_LOG_PATH}
    set suite variable    &{dict_csv_file_path}

detach power ue
    [Arguments]    ${ue_index}      ${ue_type}
    log to console      UE Detach
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

xiaomi_UE detach and attach
    [Arguments]    ${ue_index}=${not_TP_ue_index}      ${ue_type}=${not_TP_ue_type}
    log to console    xiaomi_UE detach and attach
    detach power ue    ue_index=${ue_index}    ue_type=${ue_type}
    attach power ue for xiaomi     ue_index=1    ue_type=Xiaomi

detach multi power ue
    log to console       detach UE_${not_TP_ue_index}
    detach power ue    ue_index=${not_TP_ue_index}     ue_type=${not_TP_ue_type}
    log to console       detach UE_${TP_ue_index}
    detach power ue    ue_index=${TP_ue_index}     ue_type=${TP_ue_type}

###############  case keywords  #############
Get PreambleData Sfn And Slot
    [Arguments]  ${file_path}
    ${sfn_slot_dict}    TTI_Trace.get_preambleData_sfn_slot    file_path=${file_path}
    [Return]  ${sfn_slot_dict}

Get PucchFormat filter By Sfn Slot
    [Arguments]  ${PreambleData_file_path}    ${PucchFormat_file_path}
    ${sfn_slot_dict}    Get PreambleData Sfn And Slot    file_path=${PreambleData_file_path}
    ${result_dict}    TTI_Trace.get_ulPucchReceiveRespPsData_pucchFormat_filter_sfn_slot
    ...    file_path=${PucchFormat_file_path}    input_dict=${sfn_slot_dict}
    [Return]  ${result_dict}

Get PucchFormat filter By Slot
    [Arguments]  ${PucchFormat_file_path}    ${slot_value}=19    ${Frame_period}=${4}    ${number}=${5}
    #${sfn_slot_dict}    Get PreambleData Sfn And Slot    file_path=${PreambleData_file_path}
    ${result_dict}    TTI_Trace.get_ulPucchReceiveRespPsData_pucchFormat_filter_slot    number=${number}
    ...    file_path=${PucchFormat_file_path}    slot_value=${slot_value}    Frame_period=${Frame_period}
    [Return]  ${result_dict}

Get Prb filter By Sfn Slot
    [Arguments]  ${PreambleData_file_path}    ${Prb_file_path}
    ${sfn_slot_dict}    Get PreambleData Sfn And Slot    file_path=${PreambleData_file_path}
    ${result_dict}    TTI_Trace.get_ulFdSchedData_prb_filter_sfn_slot    file_path=${Prb_file_path}
    ...    input_dict=${sfn_slot_dict}
    [Return]  ${result_dict}

Get Prb filter By Slot
    [Arguments]  ${Prb_file_path}    ${slot_value}=19    ${Frame_period}=${4}    ${number}=${5}
    #${sfn_slot_dict}    Get PreambleData Sfn And Slot    file_path=${PreambleData_file_path}
    ${result_dict}    TTI_Trace.get_ulFdSchedData_Prb_filter_slot    file_path=${Prb_file_path}
    ...    slot_value=${slot_value}    Frame_period=${Frame_period}    number=${number}
    [Return]  ${result_dict}

get all result
    [Arguments]  ${dict_csv_file_path}
    @{Prach_result_list}    Create List
    @{NoPrach_result_list}    Create List
    ${dict_csv_file_path_ul}    get from dictionary    ${dict_csv_file_path}    UL
    ${dict_csv_file_path_dl}    get from dictionary    ${dict_csv_file_path}    DL
    ${Prach_pucch_result_dict}    Get PucchFormat filter By Sfn Slot
    ...    PreambleData_file_path=${dict_csv_file_path_dl}     PucchFormat_file_path=${dict_csv_file_path_dl}
    APPEND TO LIST   ${Prach_result_list}    ${Prach_pucch_result_dict}
    ${Prach_pusch_result_dict}    Get Prb filter By Sfn Slot
    ...    PreambleData_file_path=${dict_csv_file_path_dl}     Prb_file_path=${dict_csv_file_path_ul}
    APPEND TO LIST   ${Prach_result_list}    ${Prach_pusch_result_dict}
    ${NoPrach_pucch_result_dict}    Get PucchFormat filter By Slot    PucchFormat_file_path=${dict_csv_file_path_dl}
    APPEND TO LIST   ${NoPrach_result_list}    ${NoPrach_pucch_result_dict}
    ${NoPrach_pusch_result_dict}    Get Prb filter By Slot    Prb_file_path=${dict_csv_file_path_ul}
    APPEND TO LIST   ${NoPrach_result_list}    ${NoPrach_pusch_result_dict}
    [Return]    ${Prach_result_list}    ${NoPrach_result_list}

check sigle Channel multiplexing
    [Arguments]  ${dict_csv_file_path}
    log to console    check Channel multiplexing
    ${all_result_list}    get all result    dict_csv_file_path=${dict_csv_file_path}
    ${Prach_result_list}    set variable    ${all_result_list}[0]
    ${NoPrach_result_list}    set variable    ${all_result_list}[1]
    ${is_Prach_multiplexing}    ${is_NoPrach_multiplexing}    Check_multiplexing_result
    ...     Prach_result_list=${Prach_result_list}    NoPrach_result_list=${NoPrach_result_list}
    should be true    ${is_Prach_multiplexing} == ${1} or ${is_NoPrach_multiplexing} == ${1}

get total tput
    [Arguments]    ${tput_result}
    ${sum_TP}    set variable    ${0}
    FOR    ${item}    IN    @{tput_result}
        ${TP}    get from dictionary    ${item}    peak
        ${sum_TP}     evaluate    ${sum_TP}+${TP}
    END
    [Return]    ${sum_TP}

check UL_Tput gain
    [Arguments]  ${new_total_UL_Tput}    ${orig_total_UL_Tput}
    log to console    check UL_Tput gain
    ${total_UL_Tput_gain}     Evaluate
    ...    (float(${new_total_UL_Tput})-float(${orig_total_UL_Tput}))/float(${orig_total_UL_Tput})
    should be true    float(${total_UL_Tput_gain})>${0.05}
    [Return]    ${total_UL_Tput_gain}

##############  Teardown  #############
Commmon Case Teardown
    run keyword and continue on failure    power_ue.Stop traffic    ue_index=${TP_ue_index}    ue_type=${TP_ue_type}
     ...    direction=ul    protocol=udp    iperf_port=${ul_power_port_list}[${TP_ue_index}]
    run keyword and continue on failure    detach multi power ue
    CI_interface.Common Case Teardown
