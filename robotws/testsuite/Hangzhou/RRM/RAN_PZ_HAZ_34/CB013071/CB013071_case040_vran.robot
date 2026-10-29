*** Settings ***
Test Timeout      180 minutes
Suite Setup       Cloud Common Suite Setup
#Suite Teardown    Cloud Common Suite Teardown
Test Setup        Cloud Common Test Setup
#Test Teardown     Cloud Common Test Teardown
#Force Tags        cospark

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/cloud/robot/cloud_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/cloud/robot/cloud_log_operate.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013071/Resources/Cloud_common_keyword.robot
#Resource     ./resource.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput

Documentation  CB013071-CR-A-B1_CASE040_32TRX_single_band_SubbandBm_4CC_peak


*** Variables ***
${VDU_SCFC_NAME}    ${CURDIR}/config/vdu_scfc_tl37462_case40.xml
${VCU_SCFC_NAME}    ${CURDIR}/config/vcu_scfc_tl37462_case40.xml

${ATT_FILE_PATH}      att1
${PHASE_FILE_PATH}    phase1

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

#${TS_CASE_LOG_PATH}        ${TEST_LOG_DIRECTORY()}/All
${UE_INDEX}                   0

${NRCELL4_CELLID}          613777412
${NRCELL5_CELLID}          613777413
${NRCELL6_CELLID}          613777414
${NRCELL7_CELLID}          613777415


*** Test Cases ***
CB013071-CR-A-B1_CASE040_32TRX_single_band_SubbandBm_4CC_peak
    Step1:Prepare for test
    step2:attach UEs in cell4 and check logs
    step3:attach UEs in cell5 and check logs
    step4:attach UEs in cell6 and check logs
    step5:attach UEs in cell7 and check logs

*** Keywords ***
Step1:Prepare for test
    Prepare Cloud Onair     vdu_scf_path=${VDU_SCFC_NAME}
    ...    cu_scf_path=${VCU_SCFC_NAME}
    run keyword and continue on failure   Get theoretical throughput from nrdim    SCF_Path=${VDU_SCFC_NAME}

step2:attach UEs in cell4 and check logs
    Log To Console   \n-------------step2:attach UEs in cell4 and check logs--------------
    Cloud Online change qRxLevMin value   cell_id=4    value=-56
    Cloud Online change qRxLevMin value   cell_id=5    value=-22
    Cloud Online change qRxLevMin value   cell_id=6    value=-22
    Cloud Online change qRxLevMin value   cell_id=7    value=-22

    Attach UEs and send full buffer and check tput
    Sleep    300s
    Get Cloud RT and DFT user Num by counter    cell_id=4    rt=1
    Detach all UEs

step3:attach UEs in cell5 and check logs
    Log To Console   \n-------------step3:attach UEs in cell5 and check logs--------------
    Cloud Online change qRxLevMin value   cell_id=4    value=-22
    Cloud Online change qRxLevMin value   cell_id=5    value=-56
    Attach UEs and send full buffer and check tput    cell_id=5
    Sleep    300s
    Get Cloud RT and DFT user Num by counter    cell_id=5    rt=1

    Detach all UEs

step4:attach UEs in cell6 and check logs
    Log To Console   \n-------------step4:attach UEs in cell6 and check logs--------------
    Cloud Online change qRxLevMin value   cell_id=5    value=-22
    Cloud Online change qRxLevMin value   cell_id=6    value=-56
#    Cloud Online change qRxLevMin value   cell_id=7    value=-56
    Attach UEs and send full buffer and check tput    cell_id=6

    Detach all UEs

step5:attach UEs in cell7 and check logs
    Log To Console   \n-------------step5:attach UEs in cell7 and check logs--------------
    Cloud Online change qRxLevMin value   cell_id=6    value=-22
    Cloud Online change qRxLevMin value   cell_id=7    value=-56
    Attach UEs and send full buffer and check tput    cell_id=7
    Detach all UEs

Attach UEs and send full buffer and check tput
    [Arguments]    ${cell_id}=4
	FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
	    Log To Console    UE${num} attachs
	    Spark UE Attach    ue_index=${num}    power_reset=true

	    Spark UE Send DL Traffic    ue_index=${num}    send_traffic=1326MKbits/sec    send_duration=600    apn_address=wustatic
	    ...    ue_mode=None
#	    Spark UE Send UL Traffic    ue_index=${num}    send_traffic=205MKbits/sec    send_duration=600    apn_address=wustatic
#	    ...    ue_mode=None
	END

	Start capture UE log
	Sleep    20s
	${cell_dl_tput}=    Set Variable    0
	${cell_ul_tput}=    Set Variable    0
	FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
	    ${dl_tput}    ${ul_tput}    Stop UE '${num}' log and check logs '${cell_id}'
        ${cell_dl_tput}    Evaluate    ${cell_dl_tput}+${dl_tput}
        ${cell_ul_tput}    Evaluate    ${cell_ul_tput}+${ul_tput}
    END

	${cellsid}    create list    ${NRCELL${cell_id}_CELLID}
	${expect_dl_tput}=    evaluate    ${cell${cell_id}_expect_tput}[0]*0.9
	${expect_ul_tput}=    evaluate    ${cell${cell_id}_expect_tput}[1]*0.9
#	run keyword and continue on failure    Spark UE Check Tput    ue_index=${UE_INDEX}    expect_traffic=${expect_dl_tput}
#	...    check_source=aasyslog    duration=3m    cells=${cellsid}    target_avg_percent=0.8
#	run keyword and continue on failure    Spark UE Check Tput    ue_index=${UE_INDEX}    direction=ul    expect_traffic=${expect_ul_tput}
#	...    check_source=aasyslog    duration=2m    cells=${cellsid}    target_avg_percent=0.8

    run keyword and continue on failure    should be true    ${cell_dl_tput} >= ${expect_dl_tput}
#    run keyword and continue on failure    should be true    ${cell_ul_tput} >= ${expect_ul_tput}

Detach all UEs
    Log To Console   \n-------------Detach all UEs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       Spark UE Detach    ue_index=${num}
    END

Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}    ${pcellid}=4
    [Documentation]  Get theoretical throughput from nrdim
    ...    RETURN list [theoretical_dl , theoretical_ul]

    ${cell4_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=${pcellid}

    ${cell5_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=5

    ${cell6_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=6

    ${cell7_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=7

    Set Test Variable   ${cell4_expect_tput}
    Set Test Variable   ${cell5_expect_tput}
    Set Test Variable   ${cell6_expect_tput}
    Set Test Variable   ${cell7_expect_tput}


Cloud Online change qRxLevMin value
    [Arguments]    ${cell_id}    ${value}    ${gnb_id}=${37462}
    ${mo_dn}  Set Variable    MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-${cell_id}
    Online Change Cloud Single Paramter  mo_dn=${mo_dn}  param_name=qRxLevMin  param_value=${value}  operation_type=update
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
    FOR    ${index}    IN RANGE    1    ${UE_NUM_SA}+1
        Spark Start UE Log    ue_index=${index}
    END
    Sleep    10s

Stop UE '${ue_index}' log and check logs '${cell_id}'
    ${log_name}    set variable    ${TEST_LOG_DIRECTORY()}/ue${ue_index}_${cell_id}.csv
    Spark Stop UE Log    ue_index=${ue_index}    log_name=${log_name}    filter=test

    ${dl_tput}    ${ul_tput}    ${dl_bler}    ${ul_bler}    Get dl and ul average data    csv_file=${log_name}
    Log To Console    dl_tput=${dl_tput}, ul_tput=${ul_tput}, dl_bler=${dl_bler}, ul_bler=${ul_bler}
    [Return]    ${dl_tput}    ${ul_tput}


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
    ${dl_tp}    get tp    ${csv_file}    NR PDCP Thr. DL [Mbps]
    ${ul_tp}    get tp    ${csv_file}    NR PDCP Thr. UL [Mbps]
    ${dl_bler}    get tp    ${csv_file}    NR PDSCH iBLER[%]
    ${ul_bler}    get tp    ${csv_file}    NR PUSCH iBLER[%]
    log to console   dltput=${dl_tp}, dl_bler=${dl_bler}, ultput=${ul_tp}, ul_bler=${ul_bler}
    [Return]    ${dl_tp}    ${ul_tp}    ${dl_bler}     ${ul_bler}

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


Get RT and DFT user Num by counter
    [Arguments]    ${cell_id}    ${rt}    ${dft}
    ${counter_ids}    Create List   M55196C00011    M55196C00012
    ${counter_values}=    Get Cloud Counter Data    dimension_dn=MRBTS-37462/NRBTS-37462/NRCELL-${cell_id}
    ...    counter_ids=${counter_ids}

    should be true    ${counter_values}[0]==${rt}
    should be true    ${counter_values}[1]==${dft}
    log to console    cellid_${cell_id} rt user num ${counter_values}[0],DFT user num ${counter_values}[1]


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

