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
...    feature : CB011169-w
...    cell4 cell5 cell6 TDD 3cell
...    cell1 cell2 cell3 FDD 3cell
...    cell4 pcell T+T+T 3CC  dl_peak xxx  ul_peak xxx
...    cell5 pcell T+T+F 3CC  dl_peak xxx  ul_peak xxx
...    cell1 pcell F+F+T+T 4CC  dl_peak xxx  ul_peak xxx
...    cell2 pcell F+T+T 3CC  ULCA dl_peak xxx  ul_peak xxx

*** Variables ***
${VDU_SCFC_NAME}    CB011169_W_CASE02_3F3T_VDU.xml
${VCU_SCFC_NAME}    CB011169_W_CASE02_3F3T_VCU.xml

${ROW_COUNTER}           6
${UE_NUM_SA}             1


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
CB011169_W_Cloud_case02_SA_2FDD_2TDD_4CC_performance
    Step1:Prepare for test
    Step2:Attach UE 3CC 3TDD and check logs
    Step3:Attach UE 4CC 1F3T and check logs


*** Keywords ***
Step1:Prepare for test
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    Set Suite Variable    ${parent_dir}
    Set Suite Variable    ${MCS_CONFIG_FILE}    /home/ute/testline_configuration/${TL_NAME}/mcs_config.yml
    Prepare Cloud Onair     vdu_scf_path=${parent_dir}/TestData/${BRANCH}/${VDU_SCFC_NAME}
    ...    cu_scf_path=${parent_dir}/TestData/${BRANCH}/${VCU_SCFC_NAME}
    log to console    set MCS
    Set UE pos    att_name=CA_att    phase_name=CA_phase

Step2:Attach UE 3CC 3TDD and check logs
    Online change qRxLevMin to select cell    cell_id=4
    Attach UEs and send full data
    Start capture UE log
    Stop UE log and check    spark_log=CEll4_TDD_3CC    ue_index=0
    Capture ttitrace and check    tti_path=CEll4_TDD_3CC    ini_path=tti_CA

Step3:Attach UE 4CC 1F3T and check logs
    Online change qRxLevMin to select cell    cell_id=1
    Attach UEs and send full data
    Start capture UE log
    Stop UE log and check    spark_log=CEll1_2F2T_4CC    ue_index=0
    Capture ttitrace and check    tti_path=CEll1_2F2T_4CC    ini_path=tti_CA

Step3:Attach UE 3CC 2T1F and check logs
    Online change qRxLevMin to select cell    cell_id=2
    Attach UEs and send full data
    Start capture UE log
    Stop UE log and check    spark_log=CEll1_2T1F_3CC    ue_index=0
    Capture ttitrace and check    tti_path=CEll1_2T1F_3CC    ini_path=tti_CA

Online change qRxLevMin to select cell
    [Arguments]    ${cell_id}
    Log To Console   online change qRxLevMin
    ${mo_dn}  Set Variable    MRBTS-37462/NRBTS-37462
    FOR    ${index}    IN RANGE    1    7
        run keyword if    ${index}==${cell_id}    Online Change Cloud Single Paramter  mo_dn=${mo_dn}/NRCELL-${index}
    ...    param_name=qRxLevMin  param_value=-60  operation_type=update
        Sleep    30s
        run keyword if    ${index}!=${cell_id}    Online Change Cloud Single Paramter  mo_dn=${mo_dn}/NRCELL-${index}
    ...    param_name=qRxLevMin  param_value=-22  operation_type=update
    END
    Sleep    10s

Attach UEs and send full data
    Log To Console   \n-------------:attach UEs--------------
	FOR    ${index}    IN RANGE    0    ${UE_NUM_SA}
	    Log To Console    UE${index} attach
	    Spark UE Attach    ue_index=${index}    power_reset=true
	    Spark UE Send DL Traffic    ue_index=${index}    send_traffic=1200MKbits/sec
	...    send_duration=6000    apn_address=weistatic
	    Spark UE Send DL Traffic    ue_index=${index}    send_traffic=1200MKbits/sec
	...    send_duration=6000    apn_address=weistatic
#	    Spark UE Send UL Traffic    ue_index=${index}    send_traffic=180MKbits/sec     send_duration=600
    END
	Sleep    10s

Capture ttitrace and check
    [Arguments]    ${tti_path}    ${ini_path}
    Log To Console   Start Capture TTI Trace
    Start Capture TTI Trace
    Log To Console   Stop TTI Trace and Decode TTI
    ${csv_file}    Wait '1s' to stop ttitrace with name'${tti_path}'
    Log To Console    csv_file=${csv_file}
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/${ini_path}.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_path}

Start capture UE log
    FOR    ${index}    IN RANGE    0    ${UE_NUM_SA}
        Spark Start UE Log    ue_index=${index}
    END
    Sleep    10s

Stop UE log and check
    [Arguments]    ${spark_log}    ${ue_index}
    ${log_name}    set variable    ${TEST_LOG_DIRECTORY()}/ueLog_${spark_log}_${ue_index}.csv
    Spark Stop UE Log    ue_index=${ue_index}    log_name=${log_name}    filter=test
    ${dl_tput}    ${ul_tput}    ${dl_bler}    ${ul_bler}    ${ssb_sinr}     ${ssb_rsrp}    ${push_txpower}    ${pucch_txpower}
    ...    ${dl_avg_rank}    ${dl_beast_rank}    Get dl and ul average data    csv_file=${log_name}


Set UE pos
	[Arguments]    ${att_name}    ${phase_name}
    Set Mcs3 Channel Phase And Attenuation    ${parent_dir}/TestData/${att_name}
    ...    ${parent_dir}/TestData/${phase_name}    frequency=2600_1_ALL


Start Capture TTI Trace
    ${vdu_custom_profile}=     Create List     L2Ps_Component
    ${vdu_web_ip}=     Start ttitrace log in vDU by dcap       dcap_ip=${DCAP_IP}    dcap_port=${DCAP_PORT}
    ...                username=${DCAP_USER}    password=${DCAP_PASSWORD}    vdu_custom_profiles=${vdu_custom_profile}
	...                gnb_index=${0}    vdu_index=${0}
    Set Test Variable    ${vdu_web_ip}

Wait '${time}' to stop ttitrace with name'${tti_tag}'
	Sleep    ${time}
    ${tti_csv_file_paths}=    Stop And Decode TTI Log In vDU    ${vdu_web_ip}
    ...    tti_csv_file=${TEST_LOG_DIRECTORY()}/All/${tti_tag}/tti.csv
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
    ${ret}    Run Keyword If    ${length} > 0    set variable    ${ret_l}
    ...    ELSE    Return From Keyword    0
    ${avg}    evaluate    sum(${ret})/${length}
    [Return]    ${avg}


Detach UE and stop data
	Spark UE Stop traffic    direction=dl    ue_index=0    apn_address=weistatic
	Spark UE Stop traffic    direction=ul    ue_index=0    apn_address=weistatic
	Spark UE Detach    ue_index=0

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
