*** Settings ***
Resource    ../../CUDU_L2/common_setup_teardown.robot
Library     ./CB010240_check.py

*** Variables ***
${M55309C00002_NAME}     DL_MAC_SDU_VOL_UE_TPUT
${M55309C00003_NAME}     DL_MAC_SDU_TIME_UE_TPUT
${M55349C03002_NAME}     DL_RLC_PDU_VOL_UE_TPUT
${M55349C04002_NAME}     DL_RLC_PDU_TIME_UE_TPUT
${M55353C00002_NAME}     DL_RLC_PDU_VOL_UE_TPUT_PMQAP
${M55353C00003_NAME}     DL_RLC_PDU_TIME_UE_TPUT_PMQAP
${M55352C01002_NAME}     DL_PDCP_VOL_UE_TPUT_5G_PMQAP
${M55352C01003_NAME}     DL_PDCP_TIME_UE_TPUT_5G_PMQAP
${M55352C01004_NAME}     DL_PDCP_VOL_UE_TPUT_LTE_PMQAP
${M55352C01005_NAME}     DL_PDCP_TIME_UE_TPUT_LTE_PMQAP
${MEASUREMENTTYPE}       NMSDU
${RLC_PATH}              NHRRC
${RLC_PMQAP1_PATH}       NRPMQAP-1/HRLCQ
${RLC_PMQAP2_PATH}       NRPMQAP-2/HRLCQ
${5G_LTE_PMQAP1_PATH}    NRPMQAP-1/PDCPQ
${5G_LTE_PMQAP2_PATH}    NRPMQAP-2/PDCPQ
${EXP_GAP}               500

*** Keywords ***
UE GBR Establishment And DL Tput
    [Arguments]    ${ue_id}    ${dl_trf}
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=2 by\=amf
    Sleep    1s    reason=wait PDU session modify success
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=3 by\=amf
    Sleep    1s    reason=wait PDU session modify success
    Log To Console    Start VONR DL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi=2 trf_id=1 mbps\=${dl_trf} dir=dl protocol=udp
    Sleep    1s    reason=wait PDU session modify success
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi=3 trf_id=2 mbps\=${dl_trf} dir=dl protocol=udp
    Sleep    5s    reason=wait DL traffic is stable

Check CA UE Pcell Scell Cell TPut Equal To Target
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}    ${target_tp}
    ${tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    Should Be True    ${tput}==${target_tp}
    ...    msg=UE${ue_id} ${cell_type}${scell_index} tput is '${tput}'' not on target'${target_tp}'Mb
    Log To Console    \nUE${ue_id} ${cell_type} ${scell_index} ${dir} tput ${tput}Mb is on target: ${target_tp}Mb

Check UE DL All Pcell Scell TP Equal To Target For Single UE
    [Arguments]    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |    id of ue |
    ...    | ${exp_dl_tput_list} | yes | the list for DL expected tput of ue pcell ,scell |
    ...    | ${cc_num} | yes | the num for how many cc |
    ...
    ...    Examples:
    ...    | ${ue_id} |    | 1 |
    ...    | @{exp_dl_tput_list} |    | 200 | 100 | 100 |
    ...    | Check UE DL All Pcell Scell TP On Target For Single UE | ${ue_id} | ${exp_dl_tput_list} | 3 |
    ...
    FOR    ${id}    IN RANGE    ${cc_num}
    Run Keyword If    ${id}==${0}    Check CA UE Pcell Scell Cell TPut Equal To Target
    ...    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${exp_dl_tput_list[0]}
    ...    ELSE    Check CA UE Pcell Scell Cell TPut Equal To Target
    ...    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=${id}    target_tp=${exp_dl_tput_list[${id}]}
    END

Check Scell Active Status
    [Arguments]    ${scell_index}=1    ${scell_active_status}=activated    ${check_status}=pass
    ...    ${egate_file}=/opt/iphy/latest/egate_console.log
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${scell_activation}    Set Variable    SCellIndex ${scell_index} ${scell_active_status} successfully.
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}    Get Regexp Matches    ${content}    ${scell_activation}
    ${check_rst}    Get Length    ${match_list}
    ${scell_status}    Set Variable If    ${check_rst}>=1    pass    fail
    Should Be True    '${scell_status}'=='${check_status}'

Serving Cell Index For 5G NR
    [Arguments]    ${id}=1
    Log To Console    Serving Cell Index For 5G NR
    ute_wtssim.Execute Egate Command    enb_endc_param id\=${id} serving_cell_index_range_scg\=1:4
    Log To Console    Serving_cell_index_is_OK
    Sleep    10s

Set Value For CQI Testmode
    [Arguments]    ${profile_id}=3    ${cqi}=15    ${cqi_mode}=fixed    ${cqi_min}=1    ${cqi_max}=15    ${ri}=0
    Log To Console    Set Value For CQI Testmode...
    ${cmd}    Catenate    csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi} cqi_mode=${cqi_mode}
    ...    cqi_min=${cqi_min} cqi_max=${cqi_max} ri=${ri}
    ute_wtssim.Execute Egate Command    ${cmd}

NSA Check UE DL All Pcell Scell TP Equal To Target For Single UE
    [Arguments]    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |    id of ue |
    ...    | ${exp_dl_tput_list} | yes | the list for DL expected tput of ue pcell ,scell |
    ...    | ${cc_num} | yes | the num for how many cc |
    ...
    ...    Examples:
    ...    | ${ue_id} |    | 1 |
    ...    | @{exp_dl_tput_list} |    | 200 | 100 | 100 |
    ...    | Check UE DL All Pcell Scell TP On Target For Single UE | ${ue_id} | ${exp_dl_tput_list} | 3 |
    FOR    ${id}    IN RANGE    ${cc_num}
    ${index}    Evaluate    ${id}+1
    Run Keyword If    ${id}==${0}    Check CA UE Pcell Scell Cell TPut Equal To Target
    ...    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=1    target_tp=${exp_dl_tput_list[0]}
    ...    ELSE    Check CA UE Pcell Scell Cell TPut Equal To Target
    ...    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=${index}    target_tp=${exp_dl_tput_list[${id}]}
    END

NSA Check CA Multi UE Cell Average DL Tput Equal To Target
    [Arguments]    ${ue_id_list}    ${exp_dl_tput_list_list}    ${cc_num_list}
    FOR    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}    IN ZIP    ${ue_id_list}    ${exp_dl_tput_list_list}    ${cc_num_list}
    NSA Check UE DL All Pcell Scell TP Equal To Target For Single UE    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}
    END

NSA Check CA Multi UE Cell Average DL Tput On Target
    [Arguments]    ${ue_id_list}    ${exp_dl_tput_list_list}    ${cc_num_list}
    FOR    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}    IN ZIP    ${ue_id_list}    ${exp_dl_tput_list_list}    ${cc_num_list}
    NSA Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}
    END

NSA Check Average Traffic Equal To Target
    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}    ${expect_tput}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    | expect_tput | Yes | Throughput Rate for traffic |
    ...    Example:
    ...    | NSA Check Average Traffic bigger than target | 1 | 2 | ul | 10 |
    ...    | NSA Check Average Traffic bigger than target | 1 | 2 | dl | 10 |
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=${bearer_id} dir\=${dir} dc_cell_group=all
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${mavg}    Evaluate    ${avg}*0.000001
    Log To Console    \n The average ${dir} tput is: ${mavg}M \n
    ${tp_delta}    Evaluate    ${avg}*0.000001-${expect_tput}
    Should Be True    ${tp_delta}==0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${expect_tput}M \n

NSA Check NonCA Multi UE Cell Average DL Tput Equal To Target
    [Arguments]    ${ue_id_list}    ${bearer_id_list}    ${expect_tput_list}
    FOR    ${ue_id}    ${bearer_id}    ${expect_tput}    IN ZIP    ${ue_id_list}    ${bearer_id_list}    ${expect_tput_list}
    NSA Check Average Traffic Equal To Target    ${ue_id}    ${bearer_id}    dl    ${expect_tput}
    END

NSA Check NonCA Multi UE Cell Average DL Tput On Target
    [Arguments]    ${ue_id_list}    ${bearer_id_list}    ${expect_tput_list}
    FOR    ${ue_id}    ${bearer_id}    ${expect_tput}    IN ZIP    ${ue_id_list}    ${bearer_id_list}    ${expect_tput_list}
    NSA Check Average Traffic Bigger Than Target    ${ue_id}    ${bearer_id}    dl    ${expect_tput}
    END

Add Bearer
    [Arguments]    ${ue_id}    ${bearer_id}    ${filter}=0
    ...    ${precedence}=0    ${pass_regexp}=created    ${timeout}=30
    Execute Egate Command    bearer_add ue\=${ue_id} id\=${bearer_id} filter\=${filter} precedence\=${precedence}
    ...    pass_regexp=${pass_regexp}    timeout=${timeout}
    [Return]

Delete Bearer
    [Arguments]    ${ue_id}    ${bearer_id}
    ...    ${pass_regexp}=Bearer Deletion procedure    ${timeout}=30
    Execute Egate Command    bearer_del ue\=${ue_id} id\=${bearer_id}
    ...    pass_regexp=${pass_regexp}    timeout=${timeout}
    [Return]

Check PM Counter M55309C00002 And M55309C00003
    [Arguments]    ${cell_id}    ${physcellid}    ${cell_type}    ${counter_value_dict}
    ...    ${log_dir}=${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${calc_m55309c00002}    ${calc_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    ${physcellid}    ${cell_type}    ${log_dir}
    Run Keyword And Continue On Failure    Should Be True    ${counter_value_dict.cell${cell_id}.M55309C00002}>=${calc_m55309c00002}
    Run Keyword And Continue On Failure    Should Be True    ${counter_value_dict.cell${cell_id}.M55309C00003}>=${calc_m55309c00003}

Check PM Counter M55309C00002 And M55309C00003 For Multi Bear
    [Arguments]    ${cell_id}    ${physcellid}    ${cell_type}    ${counter_value_dict}
    ...    ${log_dir}=${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${calc_m55309c00002}    ${calc_m55309c00003}    Run Keyword And Continue On Failure    Get Value For Multi Bear From L2LO Ttitrace Log
    ...    ${physcellid}    ${cell_type}    ${log_dir}
    Run Keyword And Continue On Failure    Should Be True    ${counter_value_dict.cell${cell_id}.M55309C00002}>=${calc_m55309c00002}
    Run Keyword And Continue On Failure    Should Be True    ${counter_value_dict.cell${cell_id}.M55309C00003}>=${calc_m55309c00003}

SA 5G PDU Session Release
    [Arguments]    ${ue_id}    ${pdu_id}=1
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_release pdu=${pdu_id} ue=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Successfully released PDU Session    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Successfully released PDU Session    partial_match=${true}
    Log To Console    ${output}

SA Multi 5G PDU Session Release
    [Arguments]    ${ue_id_list}    ${pdu_id}=1
    [Documentation]    This Keyword Is To Multi SA UE Attach
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id_list} | YES | a list of ue id, such as [1,2,3] |
    ...
    ...    Examples:
    ...    | @{ue_id_list} |    | 1 | 3 | 5 |
    ...    | SA Multi NonCA UE Attach | ${ue_id_list} |
    ...
    FOR    ${ue_id}    IN    @{ue_id_list}
    SA 5G PDU Session Release    ${ue_id}    ${pdu_id}
    END

SA Multi 5G PDU Session Reestablishment
    [Arguments]    ${ue_id_list}    ${pdu_id}=1
    [Documentation]    This Keyword Is To Multi SA UE Attach
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id_list} | YES | a list of ue id, such as [1,2,3] |
    ...
    ...    Examples:
    ...    | @{ue_id_list} |    | 1 | 3 | 5 |
    ...    | SA Multi NonCA UE Attach | ${ue_id_list} |
    ...
    FOR    ${ue_id}    IN    @{ue_id_list}
    SA 5G PDU Session Reestablishment    ${ue_id}    ${pdu_id}
    END

SA 5G PDU Session Reestablishment
    [Arguments]    ${ue_id}    ${pdu_id}=1
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=setup/reestablishment complete    timeout=3minutes
    Log To Console    ${output}

Check PM Counter In Target For Counter File
    [Arguments]    ${counter_value_list}    ${calc_counter_value}
    ${gap_counter_value}    Evaluate    abs(int(max(${counter_value_list}))-${calc_counter_value})
    Run Keyword And Continue On Failure    Should Be True    0<=${gap_counter_value}<=${EXP_GAP}

Check PM Counter Is Zero
    [Arguments]    ${counter_name}    ${cell_counter_path}    ${MEASUREMENTTYPE}    ${counter_log}=${test_log_directory}
    ${counter_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter_name}
    ...    ${cell_counter_path}    ${MEASUREMENTTYPE}
    ${counter_value}    Evaluate    int(max(${counter_value_list}))
    Should Be True    ${counter_value}==${0}


Get DL RLC PDU PMQAP PM Counter From Counter File
    [Arguments]    ${cell_counter_path}    ${physcellid}    ${cell_type}    ${rlc_pmqap_path}
    ...    ${counter_log}=${test_log_directory}
    ${counter1_name}    Set Variable    ${M55353C00002_NAME}
    ${counter2_name}    Set Variable    ${M55353C00003_NAME}
    ${counter1_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter1_name}
    ...    ${cell_counter_path}    ${rlc_pmqap_path}
    ${counter1_value}    Evaluate    int(max(${counter1_value_list}))
    ${counter2_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter2_name}
    ...    ${cell_counter_path}    ${rlc_pmqap_path}
    ${counter2_value}    Evaluate    int(max(${counter2_value_list}))
    [Return]    ${counter1_value}    ${counter2_value}

Check DL MAC SDU PM Counter From Counter File
    [Arguments]    ${cell_counter_path}    ${physcellid}    ${cell_type}
    ...    ${volThresDiscardDlMacSdu}=${None}
    ...    ${durationThresDiscardDlMacSdu}=${None}
    ...    ${counter_log}=${test_log_directory}
    ...    ${trace_file}=${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${counter1_name}    Set Variable    ${M55309C00002_NAME}
    ${counter2_name}    Set Variable    ${M55309C00003_NAME}
    ${counter1_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter1_name}
    ...    ${cell_counter_path}    ${MEASUREMENTTYPE}
    ${counter2_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter2_name}
    ...    ${cell_counter_path}    ${MEASUREMENTTYPE}
    ${calc_counter1}    ${calc_counter2}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    ${physcellid}    ${cell_type}    ${trace_file}    ${volThresDiscardDlMacSdu}    ${durationThresDiscardDlMacSdu}
    ${counter1_gap}    Evaluate    abs(int(max(${counter1_value_list}))-${calc_counter1})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter1_gap}<=${EXP_GAP}
    ${counter2_gap}    Evaluate    abs(int(max(${counter2_value_list}))-${calc_counter2})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter2_gap}<=${EXP_GAP}

Check DL MAC SDU PM Counter From Counter File For Multi Bearer
    [Arguments]    ${cell_counter_path}    ${physcellid}    ${cell_type}
    ...    ${except_logicalChannelId}=${None}
    ...    ${counter_log}=${test_log_directory}
    ...    ${trace_file}=${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${counter1_name}    Set Variable    ${M55309C00002_NAME}
    ${counter2_name}    Set Variable    ${M55309C00003_NAME}
    ${counter1_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter1_name}
    ...    ${cell_counter_path}    ${MEASUREMENTTYPE}
    ${counter2_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter2_name}
    ...    ${cell_counter_path}    ${MEASUREMENTTYPE}
    ${calc_counter1}    ${calc_counter2}    Run Keyword And Continue On Failure    Get Value For Multi Bearer From L2LO Ttitrace Log
    ...    ${physcellid}    ${cell_type}    ${trace_file}    ${except_logicalChannelId}
    ${counter1_gap}    Evaluate    abs(int(max(${counter1_value_list}))-${calc_counter1})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter1_gap}<=${EXP_GAP}
    ${counter2_gap}    Evaluate    abs(int(max(${counter2_value_list}))-${calc_counter2})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter2_gap}<=${EXP_GAP}

Check DL RLC PDU PM Counter From Counter File
    [Arguments]    ${cell_counter_path}    ${physcellid}    ${cell_type}    ${is_pcell}=${empty}    ${ca_type}=${empty}
    ...    ${except_rnti}=${None}    ${include_rnti}=${None}
    ...    ${counter_log}=${test_log_directory}
    ...    ${trace_file}=${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    [Documentation]    kwargs optional parameters:
    ...    1. cell_type, FR1_FDD/FR1_TDD/FR2_TDD
    ...    2. is_pcell, true/false
    ...    3. ca_type, 3F/1T2F/4T/1F1T
    ${counter1_name}    Set Variable    ${M55349C03002_NAME}
    ${counter2_name}    Set Variable    ${M55349C04002_NAME}
    ${counter1_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter1_name}
    ...    ${cell_counter_path}    ${RLC_PATH}
    ${counter1_value}    Evaluate    int(max(${counter1_value_list}))
    ${counter2_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter2_name}
    ...    ${cell_counter_path}    ${RLC_PATH}
    ${counter2_value}    Evaluate    int(max(${counter2_value_list}))
    ${calc_counter1}    ${calc_counter2}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    ${physcellid}    ${cell_type}    ${is_pcell}    ${ca_type}    ${trace_file}    ${except_rnti}    ${include_rnti}
    ${counter1_gap}    Evaluate    abs(${counter1_value}-${calc_counter1})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter1_gap}<=${EXP_GAP}
    ${counter2_gap}    Evaluate    abs(${counter2_value}-${calc_counter2})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter2_gap}<=${EXP_GAP}
    [Return]    ${m55349c03002_value}    ${m55349c04002_value}

Check DL RLC PDU PMQAP PM Counter From Counter File For Bearer
    [Arguments]    ${cell_counter_path}    ${physcellid}    ${cell_type}    ${rlc_pmqap_path}
    ...    ${except_logicalChannelId}=${None}    ${counter_log}=${test_log_directory}
    ...    ${trace_file}=${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${counter1_name}    Set Variable    ${M55353C00002_NAME}
    ${counter2_name}    Set Variable    ${M55353C00003_NAME}
    ${counter1_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter1_name}
    ...    ${cell_counter_path}    ${rlc_pmqap_path}
    ${counter1_value}    Evaluate    int(max(${counter1_value_list}))
    ${counter2_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter2_name}
    ...    ${cell_counter_path}    ${rlc_pmqap_path}
    ${counter2_value}    Evaluate    int(max(${counter2_value_list}))
    ${calc_counter1}    ${calc_counter2}    Run Keyword And Continue On Failure    get_value_for_multi_bearer_from_L2LO_ttitrace_log
    ...    ${physcellid}    ${cell_type}    ${trace_file}    ${except_logicalChannelId}
    ${counter1_gap}    Evaluate    abs(${counter1_value}-${calc_counter1})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter1_gap}<=${EXP_GAP}
    ${counter2_gap}    Evaluate    abs(${counter2_value}-${calc_counter2})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter2_gap}<=${EXP_GAP}
    [Return]    ${counter1_value}    ${counter2_value}

Check DL RLC PDU PMQAP PM Counter From Counter File
    [Arguments]    ${cell_counter_path}    ${physcellid}    ${cell_type}    ${rlc_pmqap_path}
    ...    ${except_rnti}=${None}    ${include_rnti}=${None}
    ...    ${counter_log}=${test_log_directory}
    ...    ${trace_file}=${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${counter1_name}    Set Variable    ${M55353C00002_NAME}
    ${counter2_name}    Set Variable    ${M55353C00003_NAME}
    ${counter1_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter1_name}
    ...    ${cell_counter_path}    ${rlc_pmqap_path}
    ${counter1_value}    Evaluate    int(max(${counter1_value_list}))
    ${counter2_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter2_name}
    ...    ${cell_counter_path}    ${rlc_pmqap_path}
    ${counter2_value}    Evaluate    int(max(${counter2_value_list}))
    ${calc_counter1}    ${calc_counter2}    Run Keyword And Continue On Failure    get_RLC_value_from_L2LO_ttitrace_log
    ...    ${physcellid}    ${cell_type}    ${is_pcell}    ${ca_type}    ${trace_file}    ${except_rnti}    ${include_rnti}
    ${counter1_gap}    Evaluate    abs(${counter1_value}-${calc_counter1})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter1_gap}<=${EXP_GAP}
    ${counter2_gap}    Evaluate    abs(${counter2_value}-${calc_counter2})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter2_gap}<=${EXP_GAP}
    [Return]    ${counter1_value}    ${counter2_value}


Check DL 5G PMQAP PM Counter From Counter File
    [Arguments]    ${cell_counter_path}    ${physcellid}    ${cell_type}    ${5g_lte_pmqap_path}    ${is_pcell}=${empty}    ${ca_type}=${empty}
    ...    ${except_rnti}=${None}    ${include_rnti}=${None}
    ...    ${counter_log}=${test_log_directory}
    ...    ${trace_file}=${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${counter1_name}    Set Variable    ${M55352C01002_NAME}
    ${counter2_name}    Set Variable    ${M55352C01003_NAME}
    ${counter1_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter1_name}
    ...    ${cell_counter_path}    ${rlc_pmqap_path}
    ${counter1_value}    Evaluate    int(max(${counter1_value_list}))
    ${counter2_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter2_name}
    ...    ${cell_counter_path}    ${rlc_pmqap_path}
    ${counter2_value}    Evaluate    int(max(${counter2_value_list}))
    ${calc_counter1}    ${calc_counter2}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    ${physcellid}    ${cell_type}    ${is_pcell}    ${ca_type}    ${trace_file}    ${except_rnti}    ${include_rnti}
    ${counter1_gap}    Evaluate    abs(${counter1_value}-${calc_counter1})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter1_gap}<=${EXP_GAP}
    ${counter2_gap}    Evaluate    abs(${counter2_value}-${calc_counter2})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter2_gap}<=${EXP_GAP}
    [Return]    ${counter1_value}    ${counter2_value}

Check DL LTE PMQAP PM Counter From Counter File
    [Arguments]    ${cell_counter_path}    ${physcellid}    ${cell_type}    ${5g_lte_pmqap_path}    ${is_pcell}=${empty}    ${ca_type}=${empty}
    ...    ${counter_log}=${test_log_directory}
    ...    ${trace_file}=${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${counter1_name}    Set Variable    ${M55352C01004_NAME}
    ${counter2_name}    Set Variable    ${M55352C01005_NAME}
    ${counter1_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter1_name}
    ...    ${cell_counter_path}    ${rlc_pmqap_path}
    ${counter1_value}    Evaluate    int(max(${counter1_value_list}))
    ${counter2_value_list}    Get RD Counter Value From RD BTS Xml    ${counter_log}    ${counter2_name}
    ...    ${cell_counter_path}    ${rlc_pmqap_path}
    ${counter2_value}    Evaluate    int(max(${counter2_value_list}))
    ${calc_counter1}    ${calc_counter2}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    ${physcellid}    ${cell_type}    ${is_pcell}    ${ca_type}    ${trace_file}
    ${counter1_gap}    Evaluate    abs(${counter1_value}-${calc_counter1})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter1_gap}<=${EXP_GAP}
    ${counter2_gap}    Evaluate    abs(${counter2_value}-${calc_counter2})
    Run Keyword And Continue On Failure    Should Be True    0<=${counter2_gap}<=${EXP_GAP}
    [Return]    ${counter1_value}    ${counter2_value}

Check PM Counter For DL RLC PDU And DL RLC PDU PMQAP
    [Arguments]    ${counter1_list}    ${counter2_list}    ${operator}=equal
    FOR    ${counter1}    ${counter2}    IN ZIP    ${counter1_list}    ${counter2_list}
    Run Keyword If    '${operator}'=='equal'    Should Be True    ${counter1}==${counter2}
    ...    ELSE IF    '${operator}'=='bigger'    Should Be True    ${counter1}>${counter2}
    ...    ELSE IF    '${operator}'=='smaller'    Should Be True    ${counter1}<${counter2}
    END

Trigger A6 Event For Scell Swap
    [Arguments]    ${ue_id}    ${phycell_id}    ${scell_index}    ${scell_rsrp}=11    ${nrsrp_nr}=80    ${meas_id}=${EMPTY}
    Log To Console    Trigger A6 Event For Scell Swap
    ${meas_id_from_egate}    Get Measurement Id From Egate Log    A6
    ${measida6}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ${pattern}    Set Variable    rrcReconfigurationComplete
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measida6} event=A6 scell=${scell_index}
    ...    scell_rsrp=${scell_rsrp} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min


Trigger A2 Event For Pcell Change
    [Arguments]    ${ue_id}    ${newpcell}=50    ${srsrp_nr}=70    ${srsrq_nr}=66
    ...    ${scell1_index}=1    ${scell1_rsrp}=115    ${scell1_rsrq}=100
    ...    ${scell2_index}=2    ${scell2_rsrp}=115    ${scell2_rsrq}=100
    ...    ${scell3_index}=3    ${scell3_rsrp}=115    ${scell3_rsrq}=100    ${meas_id}=${EMPTY}
    Log To Console    Trigger A2 Event For PCell Change
    ${meas_id_from_egate}    Get Measurement Id From Egate Log    A2
    ${measida6}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ${pattern}    Set Variable    rrcReconfigurationComplete
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measida6} event=A2
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    scell=${scell1_index} scell_rsrp=${scell1_rsrp} scell_rsrq=${scell1_rsrq}
    ...    scell=${scell2_index} scell_rsrp=${scell2_rsrp} scell_rsrq=${scell2_rsrq}
    ...    scell=${scell3_index} scell_rsrp=${scell3_rsrp} scell_rsrq=${scell3_rsrq}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
    ${flag}    Catenate    reconfigurationWithSync with physCellId ${newpcell} is present in masterCellGroup.
    ...    Handover will be triggered using CBRA.
    Run Keyword and Ignore Error    Should Contain    ${output}    ${flag}

Background SA UE
    [Arguments]    ${ue_id}
    SA Single UE Attach    ${ue_id}
    ${crnti}    Get Crnti From Egate Log    ${ue_id}
    SA Start DL Traffic Internal    ${ue_id}    1    0.5    0.1s
    SA Stop Data Traffic Internal    ${ue_id}    1
    SA 5G Detach    ${ue_id}
    [Return]    ${crnti}