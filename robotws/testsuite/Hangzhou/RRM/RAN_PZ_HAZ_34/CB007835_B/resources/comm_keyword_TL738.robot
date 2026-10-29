*** Settings ***
Documentation
...   author: shengrong.rao@nokia-sbell.com
...   contact: shengrong.rao@nokia-sbell.com

Library    taf.selenium.sbts       WITH NAME    selenium_coam
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    ../../5GC001937_OTA/resources/5GC001937_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_calculation_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Library     taf.rfrl.common_resources.python.SWConfig
Resource    ./comm_case_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
#Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG3/Resource/common_KW.robot


*** Variables ***
${DU_OAM_IP}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}             ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}            ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}            ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}                  ${tl.gnbs[0].instance_id}
${NRBTS_ID}                ${tl.gnbs[0].instance_id}
${eNB_DU_OAM_IP}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_BTS_ID}              ${tl.enbs[0].instance_id}
${eNB_NRBTS_ID}            ${tl.enbs[0].global_bts_id}
@{case_row_list}           NR RLC Thr. DL [Mbps]    NR RLC Thr. UL [Mbps]    NR RLC Thr. DL [Mbps]    NR RLC Thr. UL [Mbps]
${default_scf}             ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/ENB_SCF.xml

*** Keywords ***
Setup Commission ENB SCF
    [Arguments]    ${BTS_Host}=${eNB_DU_OAM_IP}
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     COAM Commission with scf file    scf_file_path=${default_scf}  
     Wait Until Keyword Succeeds   16min   2min   COAM Check GNB cell on air
     [Teardown]    Run keyword and ignore error     coam.teardown    connection=GNB_OAM
    
Reset RU And Wait Until On Air
    [Arguments]    ${RU_index_list}    ${connection}=GNB_OAM
    Log To Console    Reset RU And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    FOR    ${RU_index}    IN    @{RU_index_list}
        coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}    force_radio_reset=${True}    timeout=${300}
        ...    connection=${connection}
    END
    Check BTS Should Be Normal
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

RF module poweroff on
    [Arguments]  ${ue_index}=0    ${pcmd}=${False}
    Log To Console    RF module reset
    ${fault_id_list_1}    Get BTS Alarm FaultID
    Poweroff On RU And Wait Until On Air
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    ue_index=${ue_index}    pcmd=${pcmd}

Cell Lock/Unlock And Wait Until On Air
    [Arguments]  ${cell_list}    ${connection}=GNB_OAM
    Log To Console    Cell Lock/Unlock And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    Log To Console    Lock Cell
    FOR    ${item}    IN    @{cell_list}
        coam.lock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${item}    timeout=${60}    connection=${connection}
    END
    sleep    3s
    Log To Console    Unlock Cell
    FOR    ${item}    IN    @{cell_list}
        coam.unlock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${item}    timeout=${60}    connection=${connection}
    END
    Check BTS Should Be Normal
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Reset LTE And Wait Until On Air
    [Arguments]    ${alias}=enb
    Log To Console    Reset LTE And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${alias}
    sleep    2s
    coam.reset_site    connection=${alias}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${alias}

Save Snapshot Log
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=600s    ${ip_address}=${DU_OAM_IP}
    Log To Console    Save Snapshot Log
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_file_path}    set variable    ${OUTPUT DIR}/snapshot/${timestamp}_snapshot.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${connection}    timeout=${timeout}
    [Return]    ${snapshot_file_path}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Configuration backup
    [Arguments]  ${connection}=GNB_OAM
    Log To Console    Configuration backup
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    coam.get_current_scf_file    local_dir_path=${OUTPUT DIR}/    file_name=${timestamp}_scf.xml    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Restart BBMOD
    [Arguments]    ${list}    ${connection}=GNB_OAM
    Log To Console    Restart BBMOD
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    FOR    ${i}    IN    @{list}
        coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${i}    reset_type=Warm    force_radio_reset=${True}
        ...    timeout=600s    connection=${connection}
        Log To Console    wait until bts should be normal
        wait until bts should be normal
    END
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Lock and unlock BBMOD
    [Arguments]    ${list}    ${connection}=GNB_OAM
    Log To Console    Lock and unlock BBMOD
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    FOR    ${i}    IN    @{list}
        coam.lock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${i}    timeout=600s    connection=${connection}
        sleep    20s
        coam.unlock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${i}    timeout=600s    connection=${connection}
        Log To Console    wait until bts should be normal
        wait until bts should be normal
    END
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

DMRS parameters modfiy
    [Arguments]  ${list}    ${connection}=GNB_OAM
    Log To Console  DMRS modfiy
    ${modify_param}    Create List
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    FOR    ${item}    IN    @{list}
        ${cell_dldmrs}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${item}
        ...    parameter=dlDMRSAdditionalPosition    value=One additional DMRS
        APPEND TO LIST  ${modify_param}    ${cell_dldmrs}
    END
    FOR    ${item}    IN    @{list}
        ${cell_uldmrs}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${item}
        ...    parameter=ulDMRSAdditionalPosition    value=One additional DMRS
        APPEND TO LIST  ${modify_param}    ${cell_uldmrs}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${connection}    timeout=600
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

DMRS parameters recover
    [Arguments]  ${list}    ${connection}=GNB_OAM
    Log To Console  DMRS parameters recover
    ${modify_param}    Create List
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    FOR    ${item}    IN    @{list}
        ${cell_dldmrs}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${item}
        ...    parameter=dlDMRSAdditionalPosition    value=Automatic
        APPEND TO LIST  ${modify_param}    ${cell_dldmrs}
    END
    FOR    ${item}    IN    @{list}
        ${cell_uldmrs}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1}
        ...    parameter=ulDMRSAdditionalPosition    value=Automatic
        APPEND TO LIST  ${modify_param}    ${cell_uldmrs}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${connection}    timeout=600
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

UE attach by Spark by Index
    [Arguments]  ${ue_index}=${0}    ${ue_type}=huawei_sigspark
    samsung_spark.require_ue    ue_alias=UE_${ue_index}    index=${ue_index}    reset_sol=${None}
    ${5Grach_ed}    wait until keyword succeeds    4X    2min    Prepare UE and Attach UE by spark    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=False

L3 call
    [Arguments]    ${protocol}=udp    ${log_time}=${log_time}    ${ul_enable}=${True}    ${dl_enable}=${True}    ${total_count}=${total_count}
    ...    ${exp_ul_tp}=${exp_ul}    ${exp_dl_tp}=${exp_dl}    ${ue_index}=0    ${ul_list}=@{ulcell_list}    ${dl_list}=@{dlcell_list}
    ...    ${pcmd}=${False}    ${4G_pcmd}=${False}    ${buffer_size}=1400B    ${buffer_size_ul}=1300B
    Log To Console    start L3 call
    ${total_result_dict}    set variable   ${total_tp_orge}
    UE attach by Spark by Index    ue_index=${ue_index}
    ${log_path}    Start UE data traffic and Record TP Log and Aasys Log
    ...    ue_index=${ue_index}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp}
    ...    ul_duration=${duration}    dl_duration=${duration}
    ...    protocol=${protocol}    if_ul=${ul_enable}    if_dl=${dl_enable}    file_name=Asys_ul_dl_udp.txt    time=${log_time}
    ...    buffer_size=${buffer_size}    buffer_size_ul=${buffer_size_ul}
    run keyword if    ${pcmd}==${True}    start collect pcmd logs    cmd=br1
    run keyword if    '${pcmd}'=='${True}' and '${4G_pcmd}'=='${True}'    start collect pcmd logs    hostip=${eNB_DU_OAM_IP}    filename=4G_pcmd.pcap
    ...    cmd=br1
    run keyword and continue on failure    Stop UE traffic and Stop Record TP Log in spark    ue_index=${ue_index}    if_ul=${ul_enable}
    ...    if_dl=${dl_enable}    protocol=${protocol}    spark_log_name=spark_ul_dl_udp
    sleep    10s
    run keyword and continue on failure    run keyword if    ${pcmd}==${True}    Stop and download pcmd log
    run keyword and continue on failure    run keyword if    '${pcmd}'=='${True}' and '${4G_pcmd}'=='${True}'    Stop and download pcmd log
    ...    hostip=${eNB_DU_OAM_IP}    filename=4G_pcmd.pcap
    run keyword and continue on failure    run keyword if    ${ul_enable}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=${1}
    ...    actCarrierAggregation=${True}    min_percent=0
    run keyword and continue on failure    run keyword if    ${dl_enable}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=${1}
    ...    actCarrierAggregation=${True}    min_percent=0
    ${total_result_list}    Get Each UE TP From Spark    ue_num=${1}    spark_log_name=spark_ul_dl_udp    list_length=${total_count}
    ...    row_list=${case_row_list}
    ${total_result_dict}    set variable    ${total_result_list}[-1]
#    run keyword and continue on failure    run keyword if    ${dl_enable}==${True}
#    ...    should be true    ${total_result_dict[0]['DL_bler'][0]} < 2.0
    run keyword and continue on failure    run keyword if    ${dl_enable}==${True}
    ...    should be true    ${total_result_dict[0]['DL_tp'][0]} > ${exp_dl_tp}
#    run keyword and continue on failure    run keyword if    ${ul_enable}==${True}
#    ...    should be true    ${total_result_dict[0]['UL_bler'][0]} < 2.0
    run keyword and continue on failure    run keyword if    ${ul_enable}==${True}
    ...    should be true    ${total_result_dict[0]['UL_tp'][0]} > ${exp_ul_tp}
    run keyword and continue on failure    run keyword if    ${pcmd}==${True}    pcmd log analysis
    run keyword and continue on failure    run keyword if    '${pcmd}'=='${True}' and '${4G_pcmd}'=='${True}'    LTE pcmd log analysis
    [Return]    ${total_result_dict}


Start UE data traffic and Record TP Log and Aasys Log
    [Arguments]  ${ue_index}    ${ul_throughput}   ${dl_throughput}   ${ul_duration}    ${dl_duration}    ${protocol}   ${file_name}    ${time}
    ...    ${if_ul}=${True}    ${if_dl}=${False}    ${buffer_size}=1400B    ${buffer_size_ul}=1300B
    start Signal power ue traffic ul and dl by spark attach    ue_index=${ue_index}    ul_throughput=${ul_throughput}
    ...    dl_throughput=${dl_throughput}
    ...    ul_duration=${ul_duration}    dl_duration=${dl_duration}    protocol=${protocol}    if_ul=${if_ul}    if_dl=${if_dl}
    ...    buffer_size=${buffer_size}    buffer_size_ul=${buffer_size_ul}
    sleep    60s
    Spark Start UE Log    ue_index=${ue_index}
    ${log_path}    power_ue.Collect Tput   ue_type=samsung    duration=${time}    ignore_time=10s
    [Return]    ${log_path}

Stop UE traffic and Stop Record TP Log in spark
    [Arguments]  ${ue_index}    ${if_ul}    ${if_dl}    ${protocol}    ${spark_log_name}    ${ue_type}=samsung
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Spark Stop UE Log    ue_index=${ue_index}    log_name=${TS_CASE_LOG_PATH}/${spark_log_name}_UE0.xml
    run keyword and continue on failure    run keyword if    ${if_ul}    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}
    ...    direction=ul    protocol=${protocol}    iperf_port=${ul_power_port_list}[${ue_index}]
    run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}
    ...    direction=dl    protocol=${protocol}    iperf_port=${dl_power_port_list}[${ue_index}]
    Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}

Site reset stability
    [Arguments]  ${ue_index}=0    ${pcmd}=${False}    ${protocol}=tcp
    Log To Console    Site reset stability
    ${fault_id_list_1}    Get BTS Alarm FaultID
    Reset BTS And Wait Until On Air
    sleep    5s
    ${fault_id_list_2}    Get BTS Alarm FaultID
    #run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    protocol=${protocol}    ue_index=${ue_index}    pcmd=${pcmd}

RF module reset
    [Arguments]    ${RU_index_list}   ${ue_index}=0    ${pcmd}=${False}
    Log To Console    RF module reset
#    ${RU_index_list}    Get All RU Index list
    ${fault_id_list_1}    Get BTS Alarm FaultID
    Reset RU And Wait Until On Air    RU_index_list=${RU_index_list}
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    ue_index=${ue_index}    pcmd=${pcmd}

All configured NRCells lock and unlock stability testing
    Log To Console    All configured NRCells lock/unlock stability testing
    [Arguments]  ${cell_list}    ${ue_index}=0    ${pcmd}=${False}
    ${fault_id_list_1}    Get BTS Alarm FaultID
    Cell Lock/Unlock And Wait Until On Air    cell_list=${cell_list}
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    ue_index=${ue_index}    pcmd=${pcmd}

NRCell group lock and unlock stability testing
    [Arguments]  ${ue_index}=0
    Log To Console    NRCell group lock/unlock stability testing
    ${fault_id_list_1}    Get BTS Alarm FaultID
    Cell Group Lock/Unlock And Wait Until On Air
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    ue_index=${ue_index}    protocol=tcp

Each RF module lock and unlock
    Log To Console    Each RF module lock/unlock
    [Arguments]  ${ue_index}=0    ${pcmd}=${False}
    ${fault_id_list_1}    Get BTS Alarm FaultID
    RU Lock/Unlock And Wait Until On Air
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    protocol=tcp    ue_index=${ue_index}    pcmd=${pcmd}

X2 link lock and unlock
    Log To Console    Check X2Link Lock And Unlock
    [Arguments]  ${ue_index}=0
    ${fault_id_list_1}    Get BTS Alarm FaultID
    ${status}    run keyword and return status    X2Link lock/Unlock And Wait Until On Air
    Run Keyword If    '${status}'=='False'    Modify X2Link Parameter    Actual_value=unlocked
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    ue_index=${ue_index}

4G site reset
    Log To Console    4G site reset
    [Arguments]  ${ue_index}=0    ${pcmd}=${False}    ${4G_pcmd}=${True}
    run keyword and continue on failure    Save Snapshot Log    ip_address=${eNB_DU_OAM_IP}
    ${fault_id_list_1}    Get BTS Alarm FaultID
    Reset LTE And Wait Until On Air
    sleep    30s
    Check BTS Should Be Normal    cell_type=lte    bts_host=${eNB_DU_OAM_IP}
    Check BTS Should Be Normal
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    run keyword if    '${pcmd}'=='${True}'    run keyword and continue on failure    L3 call
    ...    ue_index=${ue_index}    pcmd=${pcmd}    4G_pcmd=${4G_pcmd}

Each single Baseband module reset
    [Arguments]  ${list}
    Log To Console    Each single Baseband module reset
    ${fault_id_list_1}    Get BTS Alarm FaultID
    Restart BBMOD    list=${list}
    Check BTS Should Be Normal
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
##    run keyword and continue on failure    L3 call    protocol=tcp

Each single Baseband module lock and unlock
    [Arguments]  ${list}
    Log To Console    Each single Baseband module lock and unlock
    ${fault_id_list_1}    Get BTS Alarm FaultID
    Lock and unlock BBMOD    list=${list}
    Check BTS Should Be Normal
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
##    run keyword and continue on failure    L3 call

LED status check after site reset
    [Documentation]    return led status: Online - green, Failed - red, Degraded - yellow, Not installed / Offline - gray
    [Arguments]  ${SMOD_list}    ${BBMOD_list}    ${RMOD_list}
    Log To Console    LED status check after site reset
    Selenium Login And Disable Screen Lock    version=${release_sbts}
    FOR    ${SMOD_item}    IN    @{SMOD_list}
        ${SMOD_state}    selenium_coam.get_led_status_of_an_unit     unit=SMOD-${SMOD_item}
        should be true    '${SMOD_state}'=='Online' or '${SMOD_state}'=='Enabled'
    END
    FOR    ${BBMOD_item}    IN    @{BBMOD_list}
        ${BBMOD_state}    selenium_coam.get_led_status_of_an_unit     unit=BBMOD-${BBMOD_item}
        should be true    '${BBMOD_state}'=='Online' or '${BBMOD_state}'=='Enabled'
    END
    FOR    ${RMOD_item}    IN    @{RMOD_list}
        ${RMOD_state}    selenium_coam.get_led_status_of_an_unit     unit=RMOD-${RMOD_item}
        should be true    '${RMOD_state}'=='Online' or '${RMOD_state}'=='Enabled'
    END
    [Teardown]   Run Keyword And Ignore Error     Selenium Logout And Close Browser

parameter pdl check
    [Arguments]  ${connection}=GNB_OAM
    Log To Console  parameter pdl check drxInactivityTimer
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    #Long pucch configration
    ${parameter1}=      create dictionary    drxInactivityTimer=80ms    drxLongCycle=80ms
    ...    drxOnDurationTimer=8ms    drxRetransTimerDl=0slot    drxRetransTimerUl=0slot
    ${param_list}=         Create List     ${parameter1}
    run keyword and continue on failure     coam.perform_parameter_recommissioning      dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21
    ...    skip_parameter_relation_errors=${False}
    ...     should_activate=${False}    parameter=drxProfile1    operation=update    value=${param_list}    connection=${connection}
    ${status}    run keyword and return status    coam.perform_parameter_recommissioning      dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    ...    skip_parameter_relation_errors=${False}     should_activate=${False}
    ...    parameter=caConfigurationSupport    operation=update    value=none    connection=${connection}
    run keyword and continue on failure    Should be true    '${status}'=='False'
    ${status}    run keyword and return status    coam.perform_parameter_recommissioning      dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    ...    skip_parameter_relation_errors=${False}     should_activate=${False}
    ...    parameter=actCarrierAggregation    operation=update    value=false    connection=${connection}
    run keyword and continue on failure    Should be true    '${status}'=='False'
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Long pucch configration
    [Arguments]   ${connection}=GNB_OAM
    ${get_managed_objects}    coam.get_managed_objects    class_name=NRCELL_A    connection=${connection}
    ${mod}    coam.get_parameters    dist_name=${get_managed_objects[0]['distName']}
    ...    pattern=pucchModeSelect    connection=${connection}
    ${prb}    coam.get_parameters    dist_name=${get_managed_objects[0]['distName']}
    ...    pattern=reqMinNumPuschPrb    connection=${connection}
    ${msg1f}    coam.get_parameters    dist_name=${get_managed_objects[0]['distName']}
    ...    pattern=msg1FrequencyStart    connection=${connection}
    ${long_pu1}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-230    parameter=pucchModeSelect    value=longPucch
    ${long_pu2}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-231    parameter=pucchModeSelect    value=longPucch
    ${long_puprb1}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-230    parameter=reqMinNumPuschPrb    value=251
    ${long_puprb2}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-231    parameter=reqMinNumPuschPrb    value=251
    ${long_msg1_1}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-230    parameter=msg1FrequencyStart    value=14
    ${long_msg1_2}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-231    parameter=msg1FrequencyStart    value=14
    @{modify_param_min}    Create List    ${long_pu1}    ${long_pu2}    ${long_puprb1}    ${long_puprb2}    ${long_msg1_1}    ${long_msg1_2}
    sleep    1s
    ${mod}    coam.get_parameters    dist_name=${get_managed_objects[0]['distName']}
    ...    pattern=pucchModeSelect    connection=${connection}
    run keyword and continue on failure    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param_min}
    ...    connection=${connection}   timeout=600
    ${long_pu1}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-230    parameter=pucchModeSelect    value=shortPucch
    ${long_pu2}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-231    parameter=pucchModeSelect    value=shortPucch
    ${long_puprb1}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-230    parameter=reqMinNumPuschPrb    value=19
    ${long_puprb2}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-231    parameter=reqMinNumPuschPrb    value=19
    ${long_msg1_1}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-230    parameter=msg1FrequencyStart    value=1
    ${long_msg1_2}    Create Dictionary    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-231    parameter=msg1FrequencyStart    value=1
    @{modify_param_min}    Create List    ${long_pu1}    ${long_pu2}    ${long_puprb1}    ${long_puprb2}    ${long_msg1_1}    ${long_msg1_2}
    run keyword and continue on failure    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param_min}
    ...    connection=${connection}    timeout=600

start Signal power ue traffic ul and dl by spark attach
    [Arguments]    ${ue_index}=${0}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${buffer_size}=1400B    ${buffer_size_ul}=1300B
    log to console      Start traffic    console=yes
    run keyword and continue on failure    run keyword if    ${if_dl}    Signal UE start dl traffic    ue_index=${ue_index}
    ...    dl_throughput=${dl_throughput}    dl_duration=${dl_duration}    protocol=${protocol}    buffer_size=${buffer_size}
    sleep    1s
    run keyword and continue on failure    run keyword if    ${if_ul}    Signal UE start ul traffic    ue_index=${ue_index}
    ...    ul_throughput=${ul_throughput}    ul_duration=${ul_duration}    protocol=${protocol}    buffer_size_ul=${buffer_size_ul}

Signal UE start ul traffic
    [Arguments]  ${ue_index}    ${ul_throughput}    ${ul_duration}    ${protocol}    ${buffer_size_ul}
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung
    ...    iperf_type=via_command    protocol=${protocol}    iperf_port=${ul_power_port_list}[${ue_index}]    buffer_size=${buffer_size_ul}

Signal UE start dl traffic
    [Arguments]  ${ue_index}    ${dl_throughput}    ${dl_duration}    ${protocol}    ${buffer_size}=1400B
    Start DL traffic via spark attach    ue_index=${ue_index}    traffic=${dl_throughput}    time=${dl_duration}
    ...    iperf_port=${dl_power_port_list}[${ue_index}]    protocol=${protocol}    buffer_size=${buffer_size}

start collect pcmd logs
    [Arguments]    ${hostip}=${DU_OAM_IP}    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master    ${filename}=pcmd.pcap    ${cmd}=fp0
    csn.connect_to
    ...    hostname=${hostip}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    csn.send command    command=rm /tmp/${filename}    connection=${asik_alias}
    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}' |xargs kill -9    connection=${asik_alias}
    csn.Send Command    command=tcpdump -i ${cmd} -C 300 -w /tmp/${filename}    connection=${asik_alias}
    sleep    2s
    csn.send command    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=${asik_alias}
    ${output}    Csn.read_output    connection=${asik_alias}
    Should not be empty    ${output}
    [Teardown]   Run keyword and ignore error    csn.Disconnect    connection=${asik_alias}

Stop and download pcmd log
    [Arguments]    ${hostip}=${DU_OAM_IP}    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master    ${filename}=pcmd.pcap
    csn.connect_to
    ...    hostname=${hostip}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    csn.send command    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 | awk '{print $2}'    connection=${asik_alias}
    ${output}    Csn.read_output    connection=${asik_alias}
    csn.send command    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 | awk '{print $2}'| xargs kill -9    connection=${asik_alias}
    ${output}    Csn.read_output    connection=${asik_alias}
    Should be empty    ${output}
    ${time1}    DateTime.get current date
    ${time1_stamp}    convert Date    ${time1}    epoch
    csn.download_file   remote_path=/tmp/${filename}    local_path=${OUTPUT_DIR}/${filename}
    ...     connection=${asik_alias}
    csn.execute    command=rm -rf /tmp/${filename}     connection=${asik_alias}
    OperatingSystem.Run    cp ${OUTPUT_DIR}/${filename} ${OUTPUT_DIR}/${time1_stamp}_${filename}
    [Teardown]   Run keyword and ignore error    csn.Disconnect    connection=${asik_alias}
    [Return]    ${OUTPUT_DIR}/${filename}

pcmd log analysis
    [Arguments]    ${filename}=${OUTPUT_DIR}/pcmd.pcap
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.timeOfUePduRx >${OUTPUT_DIR}/1.pmdl
    ${timeOfUePduRx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.timeOfUeSched >${OUTPUT_DIR}/1.pmdl
    ${timeOfUeSched}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.timeOfUePduTx >${OUTPUT_DIR}/1.pmdl
    ${timeOfUePduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOfBad1stMacPduTx >${OUTPUT_DIR}/1.pmdl
    ${numOfBadPduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOfBadLastMacPduTx >${OUTPUT_DIR}/1.pmdl
    ${numOfMacPduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOf1stMacPduTx >${OUTPUT_DIR}/1.pmdl
    ${numOf1stMacPduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.sumOfRlcPduRxBytes >${OUTPUT_DIR}/1.pmdl
    ${sumOfRlcPduRxBytes}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.sumOfRlcPduTxBytes >${OUTPUT_DIR}/1.pmdl
    ${sumOfRlcPduTxBytes}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.sumOfWbCqi >${OUTPUT_DIR}/1.pmdl
    ${sumOfWbCqi}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOfWbCqiSamples >${OUTPUT_DIR}/1.pmdl
    ${numOfWbCqiSamples}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "x2ap" -T fields -e x2ap.SgNBReconfigurationComplete_element >${OUTPUT_DIR}/1.pmdl
    ${SgNBReconfigurationComplete_element}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "x2ap" -T fields -e x2ap.SNStatusTransfer_element >${OUTPUT_DIR}/1.pmdl
    ${SNStatusTransfer_element}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "x2ap" -T fields -e x2ap.SgNBReleaseRequest_element >${OUTPUT_DIR}/1.pmdl
    ${SgNBReleaseRequest_element}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    run keyword and continue on failure    Should not be empty    ${timeOfUePduRx}
    run keyword and continue on failure    Should not be empty    ${timeOfUeSched}
    run keyword and continue on failure    Should not be empty    ${timeOfUePduTx}
    run keyword and continue on failure    Should not be empty    ${numOfBadPduTx}
    run keyword and continue on failure    Should not be empty    ${numOfMacPduTx}
    run keyword and continue on failure    Should not be empty    ${numOf1stMacPduTx}
    run keyword and continue on failure    Should not be empty    ${sumOfRlcPduRxBytes}
    run keyword and continue on failure    Should not be empty    ${sumOfRlcPduTxBytes}
    run keyword and continue on failure    Should not be empty    ${sumOfWbCqi}
    run keyword and continue on failure    Should not be empty    ${numOfWbCqiSamples}
    #run keyword and continue on failure    Should not be empty    ${SgNBReconfigurationComplete_element}
    run keyword and continue on failure    Should not be empty    ${SNStatusTransfer_element}
    run keyword and continue on failure    Should not be empty    ${SgNBReleaseRequest_element}

LTE pcmd log analysis
     [Arguments]    ${filename}=${OUTPUT_DIR}/pcmd.pcap    ${4G_filename}=${OUTPUT_DIR}/4G_pcmd.pcap
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.sgnb_ue_x2ap_Id >${OUTPUT_DIR}/1.pmdl
    ${sgnb_ue_x2ap_Id}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.menb_ue_x2ap_Id >${OUTPUT_DIR}/1.pmdl
    ${menb_ue_x2ap_Id}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${4G_filename} -Y "nsetap.TraceMessage" -T fields -e nsetap.sgnb_ue_x2ap_Id >${OUTPUT_DIR}/1.pmdl
    ${LTE_sgnb_ue_x2ap_Id}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${4G_filename} -Y "nsetap.TraceMessage" -T fields -e nsetap.menb_ue_x2ap_Id >${OUTPUT_DIR}/1.pmdl
    ${LTE_menb_ue_x2ap_Id}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    should be true    ${sgnb_ue_x2ap_Id.split()[-1]}==${LTE_sgnb_ue_x2ap_Id.split()[-1]}
    should be true    ${menb_ue_x2ap_Id.split()[-1]}==${LTE_menb_ue_x2ap_Id.split()[-1]}

Select which UE to test
    [Documentation]    Select which UE to test.
    ...  :param  ue_index: The list index from tl.ues[]
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep    2s
    csn.send_command    command=adb devices |grep 7d38a4d4 | awk '{print $1}'
    ...    connection=cygwin
    sleep    5s
    ${UE_SN}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    ${status}    run keyword and return status    Should Not Be Empty    ${UE_SN}
    ${UE_index}=  Set Variable If    ${status}    0    2
    Log To Console    ${UE_SN}
    run keyword and continue on failure    Modify Enb PLMN According by selected UE    index=${UE_index}
    sleep    10s
    Wait ENB on air
    Check BTS Should Be Normal
    [Teardown]    csn.disconnect      connection=cygwin
    [Return]    ${UE_index}

Modify Enb PLMN According by selected UE
    [Arguments]    ${index}    ${alias}=GNB_OAM
    Log To Console    Modify Enb PLMN According by selected UE
    ${note20_mcc}    Create Dictionary    value=440    dist_name=MRBTS-${enb_mrbts}/LNBTS-${enb_lnbts}    p_name=mcc
    ${note20_mnc}    Create Dictionary    value=50    dist_name=MRBTS-${enb_mrbts}/LNBTS-${enb_lnbts}    p_name=mnc
    ${mcc}    Create Dictionary    value=262    dist_name=MRBTS-${enb_mrbts}/LNBTS-${enb_lnbts}    p_name=mcc
    ${mnc}    Create Dictionary    value=3    dist_name=MRBTS-${enb_mrbts}/LNBTS-${enb_lnbts}    p_name=mnc
    ${note20_plmn}    Create List    ${note20_mcc}    ${note20_mnc}
    ${plmn}    Create List    ${mcc}    ${mnc}
    ${PLMN_list}    set variable if    ${index}==2    ${note20_plmn}    ${plmn}
    Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${alias}
    sleep    2s
    ${scf_file_path}    COAM Download scf from cluster    scf_dir_path=${OUTPUT DIR}    connection=${alias}
    ${modified_scf_file_path}    COAM Modify scf file    scf_file_path=${scf_file_path}    scf_parameters_list=${PLMN_list}
    ${get_managed_objects}    coam.get_managed_objects    class_name=LNBTS_A    connection=${alias}
    ${current_mcc}    coam.get_parameters    dist_name=${get_managed_objects[0]['distName']}
    ...    pattern=mcc    connection=${alias}
    run keyword if    '${current_mcc['mcc']}'!='${PLMN_list[0]['value']}'   COAM Commission with scf file
    ...    scf_file_path=${modified_scf_file_path}    connection=${alias}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections    connection=${alias}

Wait ENB on air
    [Arguments]    ${connection}=enb
    Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    Wait Until Keyword Succeeds   180s     10s    COAM Check GNB cell on air
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections    connection=${connection}

Cmw env setup
    Modify Enb PLMN According by selected UE    index=${1}
    sleep    10s
    Wait ENB on air
    Check BTS Should Be Normal

Stability Reset with HWF deletion TL738
    ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
    Modify Swconfig File TL738   para_update=${swconfig_list}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    1 min    5 sec   Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    start btslog capture  name=btslog
    Reset BTS And Wait Until On Air
    Run Keyword And Continue On Failure    stop btslog and collect logs   status=FAIL
    ${bts_log_path}=   set variable   ${OUTPUT_DIR}/btslog/syslog_files.tgz
    Run Keyword And Continue On Failure    Check_btslog_After_Reset TL738   log_path=${bts_log_path}
    Run Keyword And Continue On Failure    Check_gNB_Startup_log TL738
    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections

Modify Swconfig File TL738
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${para_update}    ${local_path}=${OUTPUT_DIR}
    Run    rm ${local_path}/swconfig*
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    csn.send command    command=cp /ffs/run/swconfig.txt /ffs/run/swconfig.txt.bak   connection=ASIK Master
    swconf.Download swConfig file from asik to test pc    localFilePath=${local_path}/swconfig.txt
    ...                                                   asik_alias=ASIK Master
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    FOR   ${swconfig}   IN   @{para_update}
        ${config_id}    should match regexp     ${swconfig}    .*?(?==)
        Run   sed -i -e '/${config_id}.*=.*/'d ${local_path}/swconfig.txt
    END
    swconf.Modify swConfig file    parametersList=${para_update}    filePath=${local_path}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${local_path}/swconfig.txt
    ...                                                asik_alias=ASIK Master
    run keyword and ignore error  csn.disconnect    connection=ASIK Master

Check_gNB_Startup_log TL738
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    ${startup_command} =    set variable    cat /tmp/startup_BTSOM.log |grep -i 'startService loading from hwf is disabled'
    ${startup_xz_command} =  set variable
    ...       xzcat /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log.xz |grep -i 'startService loading from hwf is disabled'
    ${startup_log} =    Check Startup Defualt Log On ASIK
    ...    startup_cmd=${startup_command}    startup_xz_cmd=${startup_xz_command}    info=startService loading from hwf is disabled
    run keyword and ignore error  csn.disconnect    connection=ASIK Master

Check_btslog_After_Reset TL738
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]   ${log_path}
    ${bts_gz_command1} =  set variable
        ...   gunzip -c ${log_path} |grep -i 'CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold'
	${bts_gz_command2} =  set variable   gunzip -c ${log_path} |grep -i 'FaultId: 4329'
	${bts_gz_command3} =  set variable   gunzip -c ${log_path} |grep -i 'FaultId: 4330'
	${bts_gz_command4} =  set variable   gunzip -c ${log_path} |grep -i 'Detector 4329'
	${bts_gz_command5} =  set variable   gunzip -c ${log_path} |grep -i 'Detector 4330'
	${bts_gz_command6} =  set variable   gunzip -c ${log_path} |grep -i 'active 4329'
	${bts_gz_command7} =  set variable   gunzip -c ${log_path} |grep -i 'active 4330'
	${bts_gz_command8} =  set variable
	   ...   gunzip -c ${log_path} |grep -i '4230 Radio memory consumption exceeds critical threshold'
	${common_list}    create list   ${bts_gz_command1}  ${bts_gz_command2}  ${bts_gz_command3}  ${bts_gz_command4}
	...                             ${bts_gz_command5}  ${bts_gz_command6}  ${bts_gz_command7}  ${bts_gz_command8}
	${status_list}    create list
	FOR   ${common}   IN   @{common_list}
	    ${offline_output}   RUN    ${common}
	    ${status}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
	    Append To List    ${status_list}    ${status}
	END
	list should not contain value    ${status_list}    ${False}

Separately_CELL_block_unblock_then_L3call
    [Arguments]     ${ue_index}=0    ${pcmd}=${False}    ${connection}=GNB_OAM
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ${fault_id_list_1}    Get BTS Alarm FaultID
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${cell_list}    Get All Cell Id    connection=${connection}
    Get X2 link shutdown waiting time
    COAM Teardown gnb connections    connection=${connection}
    Selenium Login And Disable Screen Lock    version=${release_sbts}
    ${status}    run keyword and return status    Block and UnBlock Cells    block_list=${cell_list}
    run keyword if    not ${status}    Run Keyword And Ignore Error    UnBlock Cells and check status    block_list=${cell_list}
    should be true    ${status}
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    protocol=udp    log_time=3m    ue_index=${0}
    ...    ul_enable=${True}    dl_enable=${True}    total_count=${4200}
    [Teardown]     run keywords    selenium logout and close browser     AND
    ...    run keyword and ignore error     COAM Teardown gnb connections    connection=${connection}

Separately_site_block_unblock_then_L3call
    [Arguments]     ${ue_index}=0    ${pcmd}=${False}  ${connection}=GNB_OAM      ${timeout}=120s
    [Documentation]  Owner_shanshan.zhang@nokia-sbell.com
    ${fault_id_list_1}    Get BTS Alarm FaultID
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${cell_list}    Get All Cell Id    connection=${connection}
    Selenium Login And Disable Screen Lock    version=${release_sbts}
    selenium_coam.block_site
    FOR     ${cell_id}    IN     @{cell_list}
        Wait until keyword succeeds    1min   10s    comm_case_keyword.Check cell should be disabled    cell_id=${cell_id}   connection=${connection}
    END
    COAM Teardown gnb connections    connection=${connection}
    selenium_coam.unblock_site
    Wait Until Keyword Succeeds    10min    10s    Check BTS Should Be Normal
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    protocol=udp    log_time=3m    ue_index=${0}
    ...    ul_enable=${True}    dl_enable=${True}    total_count=${4200}
    [Teardown]     run keywords    selenium logout and close browser     AND
    ...    run keyword and ignore error     COAM Teardown gnb connections    connection=${connection}

Separately Filber break then L3call
    [Documentation]  Owner_shanshan.zhang@nokia-sbell.com
	[Arguments]      ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}    ${ue_index}=0
	...    ${S_RF1}=1   ${S_RF2}=2    ${loki}=1    ${bbmod_number}=2    ${pcmd}=${False}
	${fault_id_list_1}    Get BTS Alarm FaultID
    Connect to GNB with ssh
    ${sfpd}    Get SFPD ID    bbmod_number=${bbmod_number}    loki=${loki}
    ${original_Transceiver1}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF1}    bbmod_number=${bbmod_number}    loki=${loki}
    ${original_Transceiver2}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF2}    bbmod_number=${bbmod_number}    loki=${loki}
    should be true    ${original_Transceiver1}>0
    should be true    ${original_Transceiver2}>0
    Change two optical transmission by command    sfpd=${sfpd}    switch=1
    ...    S_RF1=${S_RF1}    S_RF2=${S_RF2}    loki=${loki}     bbmod_number=${bbmod_number}
    Wait until keyword succeeds    5min   20s     Check fault id should be appear    connection=${connection}    check_fault_id=${10}
    Change two optical transmission by command    sfpd=${sfpd}    switch=0
    ...     S_RF1=${S_RF1}    S_RF2=${S_RF2}    loki=${loki}    bbmod_number=${bbmod_number}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    connection=${connection}
    Wait Until Keyword Succeeds    2min    10s    Run Keyword And Expect Error   *
    ...    Check fault id should be appear    connection=${connection}    check_fault_id=${10}
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    Check Alarm after OAM opraetion
    run keyword and continue on failure    L3 call    protocol=udp    log_time=3m    ue_index=${0}
    ...    ul_enable=${True}    dl_enable=${True}    total_count=${4200}
    [Teardown]  run keywords    Run Keyword And Ignore Error    Disconnect SMOD with ssh    AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    ...    AND    selenium logout and close browser

Gnb upgraded via WEBUI
    [Arguments]  ${ue_index}=0    ${pcmd}=${False}    ${protocol}=udp    ${index}=0
    Run Keyword And Continue On Failure    SWM supports provision SW build package via WebUI
    sleep    50s
    run keyword and continue on failure    L3 call    protocol=${protocol}    ue_index=${ue_index}    pcmd=${pcmd}
    run keyword if    '${index}'!='${2}'    
    ...    Run Keyword And Continue On Failure    Classical gNB Software Rollback successfully via WebUI
