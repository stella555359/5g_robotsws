*** Settings ***
Test Timeout      180 minutes
Suite Setup       Cloud Common Suite Setup
Suite Teardown    Cloud Common Suite Teardown
Test Setup        Cloud Common Test Setup
Test Teardown     Cloud Common Test Teardown
#Force Tags        cospark

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/cloud/robot/cloud_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/cloud/robot/cloud_log_operate.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource     ./resource.robot

Documentation
...    author: l3gao
...    contact: lei.4.gao@nokia-sbell.com
...    squad group: SG13


*** Variables ***
${VDU_SCFC_NAME}    vdu_scfc_beamset2.xml
${VCU_SCFC_NAME}    vcu_scfc_beamset2.xml

${ATT_FILE_PATH}      att1
${PHASE_FILE_PATH}    phase1

${ROW_COUNTER}           6
${UE_NUM_SA}             3


${DCAP_IP}             ${tl.gnbs[0].dcap.connection_details.addr}
${DCAP_PORT}           ${tl.gnbs[0].dcap.connection_details.port}
${DCAP_USER}           ${tl.gnbs[0].dcap.connection_details.username}
${DCAP_PASSWORD}       ${tl.gnbs[0].dcap.connection_details.password}

${UE_TITLE_INDEX}        0
${DL_TPUT_INDEX}        1
${DL_BLER_INDEX}        2
${SSB_SINR_INDEX}       3
${SSB_RSRP_INDEX}       4
${PUSH_TXPOWER_INDEX}    5
${PUCCH_TXPOWER_INDEX}   6
${DL_AVG_RANK_INDEX}     7
${DL_BEST_RANK_INDEX}    8

${COL_COUNTER}          9    #equal


*** Test Cases ***
CB011169_CB009235_SA_8DL-4UL_Multi_UE_UDP DL Throughput Curve Benchmark
    Step1:Prepare for test
    Step2:Create excel table
    Step3:Attach UE and send data
    Step4:Set MCS and capture logs and check logs '0'
    Step5:Online change actMuAwareTdSch state 'true'
    Step6:Set MCS and capture logs and check logs '6'
    Step7:Online change actMuAwareTdSch state 'false'

*** Keywords ***
Step1:Prepare for test
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    Set Suite Variable    ${parent_dir}
    Set Suite Variable    ${MCS_CONFIG_FILE}    /home/ute/testline_configuration/${TL_NAME}/mcs_config.yml
    Prepare Cloud Onair     vdu_scf_path=${parent_dir}/TestData/${BRANCH}/${VDU_SCFC_NAME}
    ...    cu_scf_path=${parent_dir}/TestData/${BRANCH}/${VCU_SCFC_NAME}

Step2:Create excel table
	${mcs_list}    create list    21    53    57    60
    Set Test Variable    ${mcs_list}
	Build excel table
	Build excel table    ${ROW_COUNTER}

Step3:Attach UE and send data
    Attach UEs and send full data

Step${index}:Set MCS and capture logs and check logs '${times}'
    BuiltIn.log    Step${index}
    ${num}   set variable    ${times}
    FOR    ${mcs}    IN    @{mcs_list}
        log to console    attname=att_${mcs}
        Set UE pos    att_name=att_${mcs}    phase_name=phase_multi
	    ${num}    evaluate    ${num}+1
	    Set Test Variable   ${num}
	    log to console    num=${num}
	    log to console    times=${num}
	    Start capture UE log
        ${ue1_dl_tput}    Stop UE '0' log and check logs '${num}'
        ${ue2_dl_tput}    Stop UE '1' log and check logs '${num}'
        ${ue3_dl_tput}    Stop UE '2' log and check logs '${num}'
        ${total_tput}    Evaluate    ${ue1_dl_tput}+${ue2_dl_tput}+${ue3_dl_tput}
        run keyword if    ${mcs}==21    should be true    ${total_tput}>=1500
    END

Step${index}:Online change actMuAwareTdSch state '${state}'
    Log To Console   Step${index} online change 9235 ${state}
    ${mo_dn}  Set Variable    MRBTS-37462/NRBTS-37462/NRCELL-4/NRDLMUMIMO-1
    Online Change Cloud Single Paramter  mo_dn=${mo_dn}  param_name=actMuAwareTdSch  param_value=${state}  operation_type=update
    Sleep    10s

Attach UEs and send full data
    Log To Console   \n-------------:attach UEs--------------
	FOR    ${index}    IN RANGE    0    ${UE_NUM_SA}
        Log To Console    UE${index} attach
        Spark UE Attach    ue_index=${index}    power_reset=true
        Spark UE Send DL Traffic    ue_index=${index}    send_traffic=800MKbits/sec    send_duration=6000    apn_address=weistatic
    END

Capture ttitrace '${times}'
    Log To Console   Start Capture TTI Trace
    Start Capture TTI Trace
    Log To Console   Stop TTI Trace and Decode TTI
    ${csv_file}    Wait '2s' to stop ttitrace with name'tti${times}'
    Log To Console    csv_file=${csv_file}
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/tti_pair.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Start capture UE log
    FOR    ${index}    IN RANGE    0    ${UE_NUM_SA}
        Spark Start UE Log    ue_index=${index}
    END
    Sleep    10s

Stop UE '${ue_index}' log and check logs '${times}'
    ${log_name}    set variable    ${TEST_LOG_DIRECTORY()}/ue${ue_index}_${times}.csv
    Spark Stop UE Log    ue_index=${ue_index}    log_name=${log_name}    filter=test

    ${dl_tput}    ${ul_tput}    ${dl_bler}    ${ul_bler}    ${ssb_sinr}     ${ssb_rsrp}    ${push_txpower}    ${pucch_txpower}
    ...    ${dl_avg_rank}    ${dl_beast_rank}    Get dl and ul average data    csv_file=${log_name}

    Record UE 9235 result    row_index=${times}    ue_index=${ue_index}    dl_put=${dl_tput}    dl_bler=${dl_bler}    ssb_sinr=${ssb_sinr}
    ...    ssb_rsrp=${ssb_rsrp}
    ...   push_txpower=${push_txpower}    pucch_txpower=${pucch_txpower}    dl_avg_rank=${dl_avg_rank}    dl_beast_rank=${dl_beast_rank}
    [Return]    ${dl_tput}


Build excel table
    [Arguments]    ${row_index}=0
    ${row_name_list}   create list
    FOR    ${mcs}    IN    @{mcs_list}
        append to list    ${row_name_list}    path_loss${mcs}
    END

    ${mcs_list_len}     Get Length     ${mcs_list}
    FOR    ${num}    IN RANGE    0    ${mcs_list_len}
        ${row_num}    evaluate    ${num}+${row_index}+1
        modify excel cell       ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_num}    0    ${row_name_list[${num}]}
    END

    ${9235_state}     run keyword if    ${row_index} !=0    set variable    on
    ...    ELSE    set variable    off
    Log to console    9235_state=${9235_state}

    FOR    ${index}    IN RANGE    1    ${UE_NUM_SA}+1
        ${col_gap}    evaluate    ${COL_COUNTER}*(${index}-1)
        log to console    col_gap=${col_gap}
        ${UE_TITLE_INDEX_EX}   evaluate    ${UE_TITLE_INDEX}+${col_gap}
        ${DL_TPUT_INDEX_EX}   evaluate    ${DL_TPUT_INDEX}+${col_gap}
        ${DL_BLER_INDEX_EX}   evaluate    ${DL_BLER_INDEX}+${col_gap}
        ${SSB_SINR_INDEX_EX}    evaluate    ${SSB_SINR_INDEX}+${col_gap}
        ${SSB_RSRP_INDEX_EX}    evaluate    ${SSB_RSRP_INDEX}+${col_gap}
        ${PUSH_TXPOWER_INDEX_EX}    evaluate    ${PUSH_TXPOWER_INDEX}+${col_gap}
        ${PUCCH_TXPOWER_INDEX_EX}    evaluate    ${PUCCH_TXPOWER_INDEX}+${col_gap}
        ${DL_AVG_RANK_INDEX_EX}    evaluate    ${DL_AVG_RANK_INDEX}+${col_gap}
        ${DL_BEST_RANK_INDEX_EX}    evaluate    ${DL_BEST_RANK_INDEX}+${col_gap}
        modify excel cell       ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${UE_TITLE_INDEX_EX}
        ...    CB009235_${9235_state}_cloud_UE${index}
        modify excel cell    ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${DL_TPUT_INDEX_EX}
        ...    DL throught[Mbps]
        modify excel cell    ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${DL_BLER_INDEX_EX}
        ...    DL bler[%]
        modify excel cell    ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${SSB_SINR_INDEX_EX}
        ...    NR SSB SINR[dB]
        modify excel cell    ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${SSB_RSRP_INDEX_EX}
        ...    NR SSB RSRP[dBm]
        modify excel cell    ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${PUSH_TXPOWER_INDEX_EX}
        ...    NR PUSCH TxPower
        modify excel cell    ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${PUCCH_TXPOWER_INDEX_EX}
        ...    NR PUCCH TxPower
        modify excel cell    ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${DL_AVG_RANK_INDEX_EX}
        ...    NR Rank Avg. DL
        modify excel cell    ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${DL_BEST_RANK_INDEX_EX}
        ...    NR Rank Best DL
    END


Record UE 9235 result
    [Arguments]     ${row_index}    ${ue_index}    ${dl_put}    ${dl_bler}    ${ssb_sinr}    ${ssb_rsrp}    ${push_txpower}    ${pucch_txpower}
    ...    ${dl_avg_rank}    ${dl_beast_rank}
    ${col_gap}    evaluate    ${COL_COUNTER}*${ue_index}
    ${DL_TPUT_INDEX}    evaluate    ${DL_TPUT_INDEX}+${col_gap}
    ${DL_BLER_INDEX}    evaluate    ${DL_BLER_INDEX}+${col_gap}
    ${SSB_SINR_INDEX}    evaluate    ${SSB_SINR_INDEX}+${col_gap}
    ${SSB_RSRP_INDEX}    evaluate    ${SSB_RSRP_INDEX}+${col_gap}
    ${PUSH_TXPOWER_INDEX}    evaluate    ${PUSH_TXPOWER_INDEX}+${col_gap}
    ${PUCCH_TXPOWER_INDEX}    evaluate    ${PUCCH_TXPOWER_INDEX}+${col_gap}
    ${DL_AVG_RANK_INDEX}    evaluate    ${DL_AVG_RANK_INDEX}+${col_gap}
    ${DL_BEST_RANK_INDEX}    evaluate    ${DL_BEST_RANK_INDEX}+${col_gap}
    modify excel cell       ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${DL_TPUT_INDEX}   ${dl_put}
    modify excel cell       ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${DL_BLER_INDEX}    ${dl_bler}
    modify excel cell       ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${SSB_SINR_INDEX}    ${ssb_sinr}
    modify excel cell       ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${SSB_RSRP_INDEX}    ${ssb_rsrp}
    modify excel cell       ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${PUSH_TXPOWER_INDEX}    ${push_txpower}
    modify excel cell       ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${PUCCH_TXPOWER_INDEX}
    ...    ${pucch_txpower}
    modify excel cell       ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${DL_AVG_RANK_INDEX}    ${dl_avg_rank}
    modify excel cell       ${TEST_LOG_DIRECTORY()}/9235_multi_ues_cloud.xls     Sheet1     ${row_index}    ${DL_BEST_RANK_INDEX}    ${dl_beast_rank}

Set UE pos
	[Arguments]    ${att_name}    ${phase_name}
    Set Mcs3 Channel Phase And Attenuation    ${parent_dir}/TestData/${att_name}   ${parent_dir}/TestData/${phase_name}    frequency=2600_1_ALL


Start Capture TTI Trace
    ${vdu_custom_profile}=     Create List     L2Ps_Component
    ${vdu_web_ip}=     Start ttitrace log in vDU by dcap       dcap_ip=${DCAP_IP}    dcap_port=${DCAP_PORT}
    ...                username=${DCAP_USER}    password=${DCAP_PASSWORD}    vdu_custom_profiles=${vdu_custom_profile}
	...                gnb_index=${0}    vdu_index=${0}
    Set Test Variable    ${vdu_web_ip}

Wait '${time}' to stop ttitrace with name'${tti_tag}'
	Sleep    ${time}
    ${tti_csv_file_paths}=    Stop And Decode TTI Log In vDU    ${vdu_web_ip}    tti_csv_file=${TEST_LOG_DIRECTORY()}/All/${tti_tag}.csv
    log to console    ${tti_csv_file_paths}
    [Return]    ${tti_csv_file_paths}


Get dl and ul average data
    [Arguments]    ${csv_file}
    ${dl}    get tp    ${csv_file}    NR PDCP Thr. DL [Mbps]
    ${ul}    get tp    ${csv_file}    NR PDCP Thr. UL [Mbps]
    ${dl_bler}    get tp    ${csv_file}    NR PDSCH iBLER[%]
    ${ul_bler}    get tp    ${csv_file}    NR PUSCH iBLER[%]
    ${ssb_sinr}    get tp    ${csv_file}    NR SSB SINR[dB]
    ${ssb_rsrp}    get tp    ${csv_file}    NR SSB RSRP[dBm]
    ${push_txpower}    get tp    ${csv_file}    NR PUSCH TxPower
    ${pucch_txpower}    get tp    ${csv_file}    NR PUCCH TxPower
    ${dl_avg_rank}    get tp    ${csv_file}    NR Rank Avg. DL
    ${dl_best_rank}    get tp    ${csv_file}    NR Rank Best DL
    log to console   dltput=${dl}, dl_bler=${dl_bler},ssb_sinr=${ssb_sinr},ssb_rsrp =${ssb_rsrp},push_txpower=${push_txpower},
    ...    pucch_txpower=${pucch_txpower},dl_avg_rank=${dl_avg_rank},dl_best_rank=${dl_best_rank}
    [Return]    ${dl}    ${ul}    ${dl_bler}     ${ul_bler}    ${ssb_sinr}    ${ssb_rsrp}    ${push_txpower}    ${pucch_txpower}
    ...    ${dl_avg_rank}    ${dl_best_rank}

get tp
    [Arguments]    ${name}    ${col}
    ${ret_l}    Read Csv Columns    ${name}    ${col}
    ${length}    evaluate    len(${ret_l})
    Log To Console    ret_l len =${length}
    ${avg}    set variable    ${0}
    ${ret}    Run Keyword If    ${length} > 0    set variable    ${ret_l}
    ...    ELSE    Return from keyword    0
    ${avg}    evaluate    sum(${ret})/${length}
    [Return]    ${avg}


Detach UE and stop data
	FOR    ${num}    IN RANGE    0    ${UE_NUM_SA}
#	    Spark UE Stop traffic    direction=dl    ue_index=${num}    apn_address=weistatic
	    Spark UE Detach    ue_index=${num}
    END

Get Cloud Counter Data
    [Documentation]    *****************
    ...    This keyword is used to check counter data.
    ...    - [Keyword Details]
    ...    It iterates over each counter ID and retrieves the counter values.
    ...    It checks if the last value in the response is an integer.
    ...    If not, the keyword will fail.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | dist_name | Yes | The distribution name. |
    ...    | counter_ids | Yes | The list of counter IDs. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    [Arguments]  ${dist_name}  ${counter_ids}  ${vdu_index}=0  ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${datetime}=    Get Time    format=%Y-%m-%d
    ${date_and_time}=    Split String    ${datetime}    ${SPACE}
    ${date}=    Set Variable    ${date_and_time[0]}
    ${start_time}=  Set Variable  ${date}T00:00:00+08:00
    ${end_time}=    Set Variable  ${date}T23:59:59+08:00
    ${counter_value_list}    Create List
    FOR  ${counter_id}  IN  @{counter_ids}
        ${res}=  vdu.Get Counter Values  counter_id=${counter_id}  dimension_dn=${dist_name}  vdu_connection=${conn_alias}
        ...   start_time_lower_limit=${start_time}  start_time_upper_limit=${end_time}
        ${value}=  Set Variable  ${res[-1]['value']}
        Append To List    ${counter_value_list}    ${value}
    END
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}
    [Return]   ${counter_value_list}
