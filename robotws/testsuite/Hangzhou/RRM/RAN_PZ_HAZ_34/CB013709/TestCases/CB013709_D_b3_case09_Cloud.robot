*** Settings ***
Documentation     CB013709_D_b3_case09_Cloud
Test Timeout      180 minutes
Suite Setup       Cloud Common Suite Setup
#Suite Teardown    Cloud Common Suite Teardown
Test Setup        Cloud Common Test Setup
#Test Teardown     Cloud Common Test Teardown
#Force Tags        cospark

Library     taf.gnb.oam.coam.cu    WITH NAME    vcu
Library      taf.ul.stream.aasyslog.aasyslog    WITH NAME    steam_aasyslog
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/cloud/robot/cloud_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/cloud/robot/cloud_log_operate.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/pm_counter.robot





*** Variables ***
${VDU_SCFC_NAME}    vdu_scfc_case09.xml
${VCU_SCFC_NAME}    vcu_scfc_case09.xml

${ATT_FILE_PATH}      att1
${PHASE_FILE_PATH}    phase1

${ROW_COUNTER}           6
${UE_NUM_SA}             1
${UE_NUM_SA_ALL}         5


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

${UE_INDEX}      1
#${SAVE LOG DIRECTORY}${Log_directory}


*** Test Cases ***
CB013709_D_b3_case09_Cloud_Verfication_actPdcpRlcBufCongOvlMech_bufferOverflow_PDCP_RLC_buffer_congestion_Counter
    Step1:Prepare for test
    Step2:Attach UE and send data
    Step3:check counter


*** Keywords ***
Step1:Prepare for test
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    Set Suite Variable    ${parent_dir}
#    Set Suite Variable    ${MCS_CONFIG_FILE}    /home/ute/testline_configuration/${TL_NAME}/mcs_config.yml
    Prepare Cloud Onair     vdu_scf_path=${parent_dir}/TestData/${BRANCH}/${VDU_SCFC_NAME}
    ...    cu_scf_path=${parent_dir}/TestData/${BRANCH}/${VCU_SCFC_NAME}
    ${cell_list}    vDU Get Cell List From Webem
    Set Test Variable    ${SAVE LOG DIRECTORY}     ${TEST_LOG_DIRECTORY()}/
#    ${peak_info}    Cloud Generate Peak Information    cell_list=${cell_list}
#    set test variable    ${peak_info}
#    Log To Console    peak_info=${peak_info}
#    ${pre_time}=    Get Current Date    result_format=%Y-%m-%dT%H:%M:%S%z
#    Log To Console   pre time is: ${pre_time}
#    Set Test Variable    ${pre_time}

Step2:Attach UE and send data
    Online change qRxLevMin value    cell_index=5    qrx_value=-22
    Online change qRxLevMin value    cell_index=6    qrx_value=-22
    Online change qRxLevMin value    cell_index=7    qrx_value=-22
    Attach UEs and send full data
    Sleep    300s


Step3:check counter
    Log To Console   \n-------------Step3:Attach multi_UEs and check counter--------------

    ${counter_ids}=    Create List    M55320C05006    M55320C05007    M55320C06006    M55320C06007    M55320C04006
    ...        M55320C04007    M55320C04008    M55320C03006    M55320C03007    M55320C03008
    ${vcu_counter_ids}=    Create List    M55350C00036
#    VDU Get Cloud PM Counter Data    MRBTS-37462/NRBTS-37462/NRCELGP-4    ${counter_ids}
    ${counter_list1}    VCU Get Cloud PM Counter Data    MRBTS-37462/NRBTS-37462    ${counter_ids}
    ${counter_list2}    VCU Get Cloud PM Counter Data    MRBTS-37462/NRBTS-37462/NRCELL-4    ${vcu_counter_ids}
    At Least One Greater Than Zero    ${counter_list1}
    At Least One Greater Than Zero    ${counter_list2}
    Log To Console     counter_list=${counter_list1}
    Log To Console     counter_list=${counter_list2}


Online change qRxLevMin value
    [Arguments]  ${cell_index}=4    ${qrx_value}=-56
    Log To Console   online change qRxLevMin ${qrx_value}
    ${mo_dn}  Set Variable    MRBTS-37462/NRBTS-37462/NRCELL-${cell_index}/
    Online Change Cloud Single Paramter  mo_dn=${mo_dn}  param_name=qRxLevMin  param_value=${qrx_value}  operation_type=update
    Sleep    10s


Cloud Change all cell qRxLevMin value
    [Documentation]    *****************
    ...    This keyword is used to Online Change Cloud Single Paramter.
    ...    - [Keyword Details]
    ...    It performs a fast delta commission with the constructed delta data.
    ...    It waits until all cells are on air for all vDUs.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | mo_dn | Yes | The managed object distinguished name. |
    ...    | param_name | Yes | The name of the parameter to be modified. |
    ...    | param_value | Yes | The new value of the parameter. |
    ...    | operation_type | No | The operation type for delta commissioning. Default is 'update'. |
    ...     example: Online Change Cloud Single Paramter  | mo_dn=MRBTS-37462/NRBTS-37462/NRCELL-4/NRDLMUMIMO-1 |
    ...     param_name=actMuAwareTdSch | param_value=true | operation_type=update |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    [Arguments]  ${cell1_value}=-56    ${cell2_value}=-22    ${cell3_value}=-22    ${cell4_value}=-22    ${gnb_id}=${37462}

    ${delta_data1}=  generic_utils.construct_delta_data_for_delta_commissioning
    ...  mo_dn=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-1
    ...  operation_type=update
    ...  qRxLevMin=${cell1_value}
    ${delta_data2}=  generic_utils.construct_delta_data_for_delta_commissioning
    ...  mo_dn=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2
    ...  operation_type=update
    ...  qRxLevMin=${cell2_value}
    ${delta_data3}=  generic_utils.construct_delta_data_for_delta_commissioning
    ...  mo_dn=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-3
    ...  operation_type=update
    ...  qRxLevMin=${cell3_value}
    ${delta_data4}=  generic_utils.construct_delta_data_for_delta_commissioning
    ...  mo_dn=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-4
    ...  operation_type=update
    ...  qRxLevMin=${cell4_value}

    ${all_delta_data_list}=  create list   ${delta_data1}   ${delta_data2}   ${delta_data3}   ${delta_data4}
    vdu_cm.Fast Delta Commission With Delta Data List   ${all_delta_data_list}
    log to console   \nOnline Change Cloud Single Paramter: ${param_name}=${param_value} completed.
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs

Change all cell qRxLevMin value
    [Arguments]    ${cell1_value}=-22    ${cell2_value}=-22    ${cell3_value}=-22    ${cell4_value}=-22    ${gnb_id}=${10754}
    ${conn}    TAF_ADMIN.connect to    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    ${modify1}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-1
    ...    parameter=qRxLevMin    value=${cell1_value}
    ${modify2}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2
    ...    parameter=qRxLevMin    value=${cell2_value}
    ${modify3}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-3
    ...    parameter=qRxLevMin    value=${cell3_value}
    ${modify4}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-4
    ...    parameter=qRxLevMin    value=${cell4_value}

    @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}    ${modify4}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
    Wait '30s' for stabible

    [Teardown]    TAF_ADMIN.teardown admin    connection=online

Attach UEs and send full data
    Log To Console   \n-------------:attach UEs--------------
	FOR    ${index}    IN RANGE    1    ${UE_NUM_SA_ALL}+1
        Log To Console    UE${index} attach
        Spark UE Attach    ue_index=${index}    power_reset=true
        Spark UE Send DL Traffic    ue_index=${index}    send_traffic=1200MKbits/sec    send_duration=6000    apn_address=weistatic    ue_mode=None
        Spark UE Send UL Traffic    ue_index=${index}    send_traffic=200MKbits/sec    send_duration=6000    apn_address=weistatic    ue_mode=None
    END

Capture ttitrace '${tti_tag}'
    Log To Console   Start Capture TTI Trace
    Start Capture TTI Trace
    Log To Console   Stop TTI Trace and Decode TTI
    ${csv_file}    Wait '2s' to stop ttitrace with name'tti${tti_tag}'
    Log To Console    csv_file=${csv_file}
#    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/tti_pair.ini
#    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

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


Detach UEs'${UE_NUM_SA}'
	FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#	    Spark UE Stop traffic    direction=dl    ue_index=${num}    apn_address=weistatic
	    Spark UE Detach    ue_index=${num}
    END

VDU Get Cloud PM Counter Data
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
    [Arguments]    ${dist_name}    ${counter_ids}    ${vdu_index}=0    ${gnb_index}=0
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

Cloud vCU Login
    [Arguments]    ${vcu_index}=0    ${gnb_index}=0    ${connection}=VCU_OAM
    ${vcu_connection}    CU.connect_to
    ...  host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...  username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...  port=${EMPTY}
    ...  secure=${True}
    ...  alias=${connection}
    log to console    ${vcu_index}
    [Return]    ${vcu_connection}

Cloud vCU Logout
    [Arguments]    ${connection}=VCU_OAM
    CU.disconnect    connection=${connection}

Get vCU 13079-D counter
     [Arguments]    ${vcu_index}=0    ${gnb_index}=0    ${cell_index}=4
     Log To Console     Get vCU 13079-D counter
     ${dimension_dn}    set variable    MRBTS-37462/NRBTS-37462/NRCELL-${cell_index}/PDCPC
     ${counter_id}   set variable    M55350C00036
     ${measurement_id}    set variable    55350
     log to console    ${vcu_index},${gnb_index}
     VCU Get Cloud PM Counter Data     counter_id=${counter_id}    dimension_dn=${dimension_dn}    measurement_id=${measurement_id}


VCU Get Cloud PM Counter Data
    [Arguments]    ${dimension_dn}    ${counter_ids}    ${measurement_id}=None
    [Documentation]    This keyword is to get the latest value for a vCU counter
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | yes | The list of counter IDs |
    ...    | ${dimension_dn} | yes | the dimension dist name that the counter belongs to, e.g.MRBTS-1111/NRBTS-1111/NRCELL-1 |
    ...    | ${measurement_id} | No | the measurement id, e.g.55115 ,the default value is None|
    ...
    ...    Examples:
    ...    |  |  |  |
    Cloud vCU Login
    ${datetime}=    Get Time    format=%Y-%m-%d
    ${date_and_time}=    Split String    ${datetime}    ${SPACE}
    ${date}=    Set Variable    ${date_and_time[0]}
    ${start_time}=  Set Variable  ${date}T00:00:00+08:00
    ${end_time}=    Set Variable  ${date}T23:59:59+08:00

    ${counter_value_list}    Create List
    FOR  ${counter_id}  IN  @{counter_ids}
        ${res}=  vcu.get_counter    measurement_id=${measurement_id}    dimension_dist_name=${dimension_dn}
        ...    counter_id=${counter_id}    connection=VCU_OAM    start_time_lower_limit=${start_time}    start_time_upper_limit=${end_time}
        ${counter_values}    Get From Dictionary    ${res}    values
#        Run Keyword If    ${counter_values}==[]    Fail    No counter value right now.

#        Run Keyword If    ${counter_values}!=[]    ${counter_value}=    Get From Dictionary    ${counter_values[-1]}    value
#        ...     Else    ${counter_value}     set variable    0

        ${counter_value}=    Run Keyword If    ${counter_values}!=[]    Get From Dictionary    ${counter_values[-1]}    value
        ...    ELSE    Set Variable    0
#        ${value}=  Set Variable  ${res[-1]['value']}
        ${counter_value}=    Convert To Integer    ${counter_value}
        Append To List    ${counter_value_list}    ${counter_value}
    END

#    ${counter}    vcu.get_counter    measurement_id=${measurement_id}    dimension_dist_name=${dimension_dn}
#    ...    counter_id=${counter_id}    connection=VCU_OAM    start_time_lower_limit=${start_time}    start_time_upper_limit=${end_time}
#    ${counter_values}    Get From Dictionary    ${counter}    values
#    Run Keyword If    ${counter_values}==[]    Fail    No counter value right now.
#    ${counter_value}    Get From Dictionary    ${counter_values[-1]}    value
#    Log To Console    The latest value for counter '${counter_id}': ${counter_value}
    [Teardown]    Run Keyword And Ignore Error    Cloud vCU Logout
    [Return]    ${counter_value_list}

Cloud Verify Peak Throughput
    [Documentation]    This keyword is designed to verify the peak throughput for a given UE.

    ...    It enters a loop where it processes each UE in the ue_index_list
    ...    It translates the power UE type from the testline and converts the UE index to string.
    ...    It retrieves the cell identity ID and creates a list containing this ID
    ...    It retrieves the downlink details and calculates the duration percent.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ue_index_list | Yes | The list of UE index. |
    ...    | ue_and_cell | Yes | A dictionary mapping UEs to cells. |
    ...    | cell_and_peak_info | Yes | A dictionary containing peak information for each cell. |
    ...    | log | Yes | The path to the log file. |
    ...    | check_source | No | The source to check. Default is 'Aasyslog'. |
    ...    | local_output_dir | No | The local output directory. Default is 'SAVE LOG DIRECTORY'. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    [Arguments]  ${log}    ${expect_traffic}=100   ${direction}=dl    ${cells}=[1]
    ...    ${target_avg_percent}=0.98    ${min_percent}=0.85
    ...    ${check_source}=Aasyslog    ${local_output_dir}=${SAVE LOG DIRECTORY}
    log to console    \nUE Verify Peak Throughput
    log to console    ${gnb_index}     ${check_source}    ${local_output_dir}
     ${all_dl_details}    run keyword and continue on failure    steam_aasyslog.check_aasyslog_throughput
     ...    direction=${direction}    log_path=${log}
     ...    cells=${cells}    theoretical_throughput=${expect_traffic}
     ...    average_tolerance=${target_avg_percent}   minimum_tolerance=${min_percent}

At Least One Greater Than Zero
    [Arguments]    ${variables}
    ${result}=    Evaluate    any(var > 0 for var in ${variables})
    Should Be True    ${result}    At least one results must be greater than 0