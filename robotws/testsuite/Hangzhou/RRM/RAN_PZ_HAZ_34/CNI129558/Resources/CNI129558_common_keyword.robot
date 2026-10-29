*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library     sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan



*** Variables ***
${gNB_ip0}                    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_ip1}                    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${TL0_BTS_ID}                  ${tl.gnbs[0].instance_id}
${TL0_NRBTS_ID}                ${tl.gnbs[0].global_bts_id}
${TL0_ENB_ID}                  ${tl.enbs[0].instance_id}
${TL0_LNBTS_ID}                ${tl.enbs[0].global_bts_id}
${TL1_BTS_ID}                  ${tl.gnbs[1].instance_id}
${TL1_NRBTS_ID}                ${tl.gnbs[1].global_bts_id}
@{PA_port_list}               ${0}   ${1}   ${2}   ${3}   ${4}   ${5}   ${6}   ${7}   ${8}   ${9}   ${10}   ${11}   ${12}   ${13}   ${14}   ${15}
@{allowed_list1}              ${4655}    ${61524}    ${61652}    ${61649}    ${4654}    ${4592}    ${4298}
@{allowed_list2}              ${4655}    ${61524}    ${61652}    ${61649}    ${4654}    ${4592}    ${49}    ${7331}    ${7311}    ${4298}
@{gnb0_all_cell}              ${1}    ${2}    ${3}    ${4}
@{gnb1_all_cell}              ${2}    ${3}    ${11}    ${12}    ${13}
${allowed_faults_ids}         7311,7331,49
#@{case7_counter_name}         NCAC
@{counter_object_name}        NCAC    NCAC    NCADC





*** Keywords ***
########### setup and teardown KW #################
CNI129558 Suite setup
    #CI_interface.Common Suite Setup
    Setup Commission SCF       scf_name=_GNB1_129558    bts_host=${gNB_ip1}    connection=GNB1_OAM
    Setup Commission SCF       scf_name=_GNB0_129558    bts_host=${gNB_ip0}    connection=GNB0_OAM
    Check GNB on air    bts_host=${gnb_ip1}    connection=GNB1_OAM
    Check GNB on air    bts_host=${gnb_ip0}    connection=GNB0_OAM
    sleep    3min
    robot_common_operations.Common Suite Setup

CNI129558 Suite Teardown
    robot_common_operations.Common Suite Teardown

CNI129558 Common Case Teardown
    [Arguments]    ${unblock_cell_id_list0}    ${unblock_cell_id_list1}    ${gnb0_para_list}=${empty_list}    ${gnb1_para_list}=${empty_list}
    ${case_result}    set variable if    "${TEST_STATUS}"=="FAIL"    failed    OK
    Log to console    CASE: ${case_result}
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB_ip0}
    sparkMultiUE_yiyuan.require_ue    ue_alias=spark_UE    multiue_traffic_config=${TLCommonConfig["MultiUECFG"]}
    ...    is_need_reconnect_spark=${False}    prepare_ue=${False}    get_spark_license=${False}
    MultiUE Detach
    robot_common_operations.Common Case Teardown
    Run Keyword If    ${gnb0_para_list} != ${empty_list}    Modify Parameters with json    input_list=${gnb0_para_list}    bts_host=${gNB_ip0}
    Run Keyword If    ${gnb1_para_list} != ${empty_list}    Modify Parameters with json    input_list=${gnb1_para_list}    bts_host=${gNB_ip1}
    Run Keyword If    ${unblock_cell_id_list1} != ${empty_list}    BLock or UnBlock Cell And Check Status    allowed_list=${allowed_list1}
    ...    BTS_ID=${TL1_BTS_ID}    NRBTS_ID=${TL1_NRBTS_ID}    block_flag=${False}    bts_host=${gnb_ip1}
    ...    unblock_cell_id_list=${unblock_cell_id_list1}
    Run Keyword If    ${unblock_cell_id_list0} != ${empty_list}    BLock or UnBlock Cell And Check Status    allowed_list=${allowed_list1}
    ...    BTS_ID=${TL0_BTS_ID}    NRBTS_ID=${TL0_NRBTS_ID}    block_flag=${False}    bts_host=${gnb_ip0}
    ...    unblock_cell_id_list=${unblock_cell_id_list0}
    CI_interface.Common Case Teardown


CNI129558 Common Case Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids}
    _Create Test Log Directory

_Create Test Log Directory
    ${TEST_LOG_DIR}    Set Variable    ${OUTPUT_DIR}/${TEST_NAME[:21]}
    Create Directory  ${TEST_LOG_DIR}
    Set Suite Variable    ${TEST_LOG_DIR}

########### common operate #################
get_bts_counters
    [Arguments]    ${counter_ids}    ${counter_name_list}    ${NRCELL_ID}    ${MRBTS_ID}    ${NRBTS_ID}    ${if_before}     ${bts_host}=${gNB_ip1}
    ...    ${before_timestamp_list}=${empty_list}    ${connection}=GNB_OAM
    @{counter_value_list}    Create list
    @{counter_last_time_list}    Create list
    ${counter_id_list}    Split String    ${counter_ids}    separator=,
    ${counter_len}    Get Length    ${counter_name_list}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Log To Console    get bts counter
    ${counter_value}    coam.get_PM_counters    counter_ids=${counter_ids}    connection=${connection}
    FOR  ${item}  IN RANGE    0    ${counter_len}
        ${counter_id}    Set Variable    ${counter_id_list[${item}]}
        ${counter_name}    Set Variable    ${counter_name_list[${item}]}
        ${before_last_time}    Set Variable if    not ${if_before}    ${before_timestamp_list[${item}]}    0
        ${result}    Set Variable
        ...     ${counter_value['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['${NRCELL_ID}']['${counter_name}']['${counter_id}']}
        ${values}    get dictionary values     ${result}
        ${keys}    get dictionary keys     ${result}
        ${index}    get_list_index    my_list=${keys}    value=${before_last_time}
#        ${index}    Set Variable if    not ${if_before}    ${index_1}    ${-1}
        ${sum_value}    Evaluate    sum(${values[${index}:]})
        Append To List    ${counter_value_list}    ${sum_value}
        Append To List    ${counter_last_time_list}    ${keys[${-1}]}
    END
    [Return]    ${counter_value_list}    ${counter_last_time_list}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

check counter value
    [Arguments]    ${before_value}    ${after_value}    ${expected_value}
    ${counter_len}    Get Length    ${before_value}
    FOR  ${value}    IN RANGE    0    ${counter_len}
         ${before}    Set Variable    ${before_value[${value}]}
         ${after}    Set Variable    ${after_value[${value}]}
         ${expected}    Set Variable    ${expected_value[${value}]}
         ${actually}    Evaluate    ${after}-${before}
         should be equal    ${expected}      ${actually}
    END

Block Two Station Cell
    [Arguments]    ${block_cell_id_list0}    ${block_cell_id_list1}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    AlarmWatchdog.add_allow_alarms    fault_id=7331
    Run Keyword If    ${block_cell_id_list0} != ${empty_list}    BLock or UnBlock Cell And Check Status    allowed_list=${allowed_list2}
    ...    BTS_ID=${TL0_BTS_ID}   NRBTS_ID=${TL0_NRBTS_ID}    block_cell_id_list=${block_cell_id_list0}    block_flag=${True}    bts_host=${gnb_ip0}
    Run Keyword If    ${block_cell_id_list1} != ${empty_list}    BLock or UnBlock Cell And Check Status    allowed_list=${allowed_list2}
    ...    BTS_ID=${TL1_BTS_ID}   NRBTS_ID=${TL1_NRBTS_ID}    block_cell_id_list=${block_cell_id_list1}    block_flag=${True}    bts_host=${gnb_ip1}

########### about Spark Muliti UE ################
Lock UE to Dedicated Cell
    [Arguments]    ${lock_info}    ${ue_alias}=spark_UE
    Adjust the HBTE attenuation value    value_list=${init_PA_value}    port_list=${PA_port_list}
    ${UE_call_info}    Get Dictionary Keys    ${lock_info}
    ${ue_info}    Create Dictionary    ue_index_for_call=${UE_call_info}
    ${ue_config}    Change_TLConfigration_Info    ue_config=${TLCommonConfig}    UE_call_info=${ue_info}
    Prepare MultiUE And Attach    multiue_config_direction=${ue_config["MultiUECFG"]}    ue_alias=${ue_alias}
    Log to console    start lock UE: \n${lock_info}
    ${lock_result}    sparkMultiUE_yiyuan.lockUeWithPciAndFreq    ue_alias=${ue_alias}    lock_info=${lock_info}
    Log to console    lock result: ${lock_result}
    Log to console    start unlock UE...
    ${unlock_result}    sparkMultiUE_yiyuan.unlockUeWithPciAndFreq    ue_alias=${ue_alias}
    Log to console    unlock result: ${unlock_result}
    MultiUE Detach    ue_alias=${ue_alias}

Prepare MultiUE And Attach
    [Arguments]    ${multiue_config_direction}    ${ue_alias}=spark_UE    ${restart_ue}=${False}    ${restart_network}=${False}
    ...    ${get_spark_license}=${False}    ${max_ue_num}=${8}    ${prepare_ue}=${True}
    log to console      "Prepare UE: ${prepare_ue}"
    Run Keyword And Ignore Error    sparkMultiUE_yiyuan.require_ue    ue_alias=${ue_alias}    multiue_traffic_config=${multiue_config_direction}
    ...    restart_ue=${restart_ue}    restart_network=${restart_network}    get_spark_license=${get_spark_license}    max_ue_num=${max_ue_num}
    ...    is_need_reconnect_spark=${prepare_ue}    prepare_ue=${prepare_ue}
    log to console      "UE Attach ${multiue_config_direction['ue_index_for_call']}"
    sparkMultiUE_yiyuan.attach_ue    ue_alias=${ue_alias}

MultiUE Detach
    [Arguments]  ${ue_alias}=spark_UE
    log to console      "UE Detach"
    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}

########### about Log ################
Start Capture Aasyslog
    [Arguments]      ${gnb_index}    ${log_name}=Aasys_Tput.txt    ${gnb_path}=/tmp/
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}
    Aasyslog precondition    gnb_index=${gnb_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    gnb_path=${gnb_path}    log_name=${log_name}

Stop Capture Aasyslog
    [Arguments]  ${gnb_index}    ${log_name}=Aasys_Tput.txt    ${gnb_path}=/tmp/
    ${local_path}    set variable    ${TEST_LOG_DIR}/${log_name}
    Download Aasyslog File From GNB    gnb_index=${gnb_index}    log_path=${gnb_path}${log_name}    local_path=${local_path}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}
    [Return]    ${local_path}


########### Case Step #################
Adjust PA And UE Attach
    [Arguments]    ${UE_call_info}    ${value_list}    ${prepare_ue}=${False}    ${gnb_index}=${0}     ${need_syslog}=${False}    ${log_name}=None
    ${ue_num}    Get Length    ${UE_call_info['ue_index_for_call']}
    Run Keyword If    ${need_syslog}    Start Capture Aasyslog    gnb_index=${gnb_index}    log_name=${log_name}
    Adjust the HBTE attenuation value    value_list=${value_list}    port_list=${PA_port_list}
    ${ue_config}    Run Keyword If    '${ue_num}' != '${0}'    Change_TLConfigration_Info    ue_config=${TLCommonConfig}
    ...    UE_call_info=${UE_call_info}
    Run Keyword If    '${ue_num}' != '${0}'    Prepare MultiUE And Attach    multiue_config_direction=${ue_config["MultiUECFG"]}
    ...    prepare_ue=${prepare_ue}
    Run Keyword If    ${need_syslog}    sleep   30s
    ${local_path}    Run Keyword If    ${need_syslog}    Stop Capture Aasyslog    gnb_index=${gnb_index}    log_name=${log_name}
    [Return]   ${local_path}

Adjust PA And Check Aasyslog
    [Arguments]    ${UE_call_info}    ${PA_value_list}    ${gnb_index}=${0}    ${log_name}=Aasys_Attach.txt
    ...    ${check_list}=${A_B1_06_syslog_check_info}
    ${local_path}    Adjust PA And UE Attach    UE_call_info=${UE_call_info}    value_list=${PA_value_list}
    ...    gnb_index=${gnb_index}    log_name=${log_name}    need_syslog=${True}
    ${result}    Check_Syslog_signaling    check_list=${check_list}    syslog=${local_path}
    Run Keyword And Continue On Failure    List Should Not Contain Value    ${result}    ${False}
