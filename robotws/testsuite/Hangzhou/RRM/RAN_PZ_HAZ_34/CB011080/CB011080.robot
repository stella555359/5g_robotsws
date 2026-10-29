# @Time    : 2024/4/22 10:25
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB011080_A.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: NSB MN RAN RD VRF HAZ3 5
...    Feature CB011080 DL TDD + FDD FR1 CA up to 6CCs (TDD as PCell)

Suite Setup         MMW5 Common Suite Setup
Suite Teardown      Run Keywords    MMW5 Common Suite Teardown    AND    CI_commssion.common commissioning
Test Setup          Run Keywords    MMW5 Common Case Setup  allowed_faults_ids=4681
...    AND     Set Test Variables    AND    Start DCAP Containers in UTE
Test Teardown       Run Keywords    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
...    AND    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
...    AND    MMW5 Common Case Teardown
Force Tags          CRT_TRUNK

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB011080_common_keywords.robot
Variables    ${CURDIR}/Resources/nrdim_params.py

*** Variables ***
#${TS_CASE_LOG_PATH}    ${OUTPUT_DIR}/${TEST NAME}
${SCF_A7}         ${CURDIR}/Resources/SCF_A7.xml
${SCF_A9}         ${CURDIR}/Resources/SCF_A9.xml
${SCF_A13}         ${CURDIR}/Resources/SCF_A13.xml
${SCF_A19}         ${CURDIR}/Resources/SCF_A19.xml
${SCF_A27}         ${CURDIR}/Resources/SCF_A27.xml
${SCF_A27_26R2}    ${CURDIR}/Resources/SCF_A27_26R2.xml
${SCF_A27_26R1}    ${CURDIR}/Resources/SCF_A27_26R1.xml
${SCF_B28}         ${CURDIR}/Resources/SCF_B28.xml
${SCF_C42}         ${CURDIR}/Resources/SCF_C42.xml
${6CC_SCELL_PHY_IDS}    50,266,267,271,52,55
${CELL7_2CC_PHY_IDS}    51,266
${CELL5_6CC_PHY_IDS}    52,266,267,271,50,55
@{6CC_GLOBAL_CELL_IDS}    1    2    3    4    5    6
@{CELL7_2CC_GLOBAL_CELL_IDS}    1    7
@{7CC_GLOBAL_CELL_IDS}    1    2    3    4    5    6    7
@{A7_MAX_CODE_DATES}        0    1
${7CC_BAND_LIST}    41,71,71,66,71,77,77
@{ul_cell_list}    608632833    608632836
@{dl_cell_list}    	608632833    608632834    608632835    608632836    608632837    608632838

# for a9
@{CUSTOM_PROFILE}    cp_5g
@{ADD_MEAS_IDS}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}
@{ADD_MEAS_OBJECTS}    ${2}    ${3}    ${4}    ${5}    ${6}
@{REMOVE_MEAS_IDS}    ${2}
@{REPORT_CONFIGS}    ${3}    ${4}
&{A9_EMIL_LOG}
...    add_meas_ids=${ADD_MEAS_IDS}
...    add_meas_objects=${ADD_MEAS_OBJECTS}
...    remove_meas_ids=${REMOVE_MEAS_IDS}
...    report_configs=${REPORT_CONFIGS}

# for b28
${counter_ids1}    M55138C03504,M55138C03507,M55118C00013,M55118C00018,M55139C03003,M55139C03006
${counter_ids2}    M55118C00001,M55118C00004,M55156C00027,M55310C20000,M55310C20001,M55316C03005,M55316C05005
${counter_CB10636}    M55349C00031,M55349C00037,M55349C00026,M55349C00032

# for a19
@{SER_CELL_IDS}    ${51}    ${266}    ${51}    ${266}
@{NEIGH_CELL_IDS}    ${52}
&{A19_EMIL_LOG}    ser_cell_ids=${SER_CELL_IDS}    neigh_cell_ids=${NEIGH_CELL_IDS}

*** Test Cases ***
CB011080-5G-A_7_B3_blind_Scell_addition_for_FR1_TDD_FDD_DL_6CCs_CA_and_UL_2CCs_CA_Different_TDD_Frame
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/10/23 16:37
    [Tags]    7
    COAM Commission with scf file    ${SCF_A7}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online
    Init PA For Peak Throughput

    Start To Capture Wireshark Log From DU    interface=VF1_CPIF00    stream=${stream}
    Run Keyword And Ignore Error    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=180M    dl_tp=1400M    parallel=3
    Sleep    30s
    UE Check Muiti Cells UL&DL Throughput    cells=${6CC_GLOBAL_CELL_IDS}    ultarget_throughput=0    dltarget_throughput=20
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=0    iperf_port=45040
    Sleep    10s
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${A7_WIRESHARK_LOG}    stream=${stream}

    Filter Wireshark Log To RRC    ${A7_WIRESHARK_LOG}    ${A7_WIRESHARK_RRC}
    ${field_values}    Check Field Value Via Wireshark    ${A7_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element
    ...    nr-rrc.physCellId    ${6CC_SCELL_PHY_IDS}
    ${max_code_rates}    Check Field Value Via Wireshark    ${A7_WIRESHARK_RRC}    nr-rrc.setup_element
    ...    nr-rrc.maxCodeRate    0
    Lists Should Be Equal    ${max_code_rates}    ${A7_MAX_CODE_DATES}
    Download aasyslog file from gNB    log_path=/tmp/5Grach.txt    local_path=${TS_CASE_LOG_PATH}/11080_7.txt
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    analysis_syslog_find_str    ${TS_CASE_LOG_PATH}/11080_7.txt    ModifType:START    5

CB011080-5G-A_9_B4_A1_Pcell_Measurement_based_Scell_Addition_for_FR1_TDD_Pcell_with_DL_6CCs_CA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/10/28 16:19
    [Tags]    9
    COAM Commission with scf file    ${SCF_A9}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online
    Init PA For Peak Throughput

    wait_until_next_5_min
    Run Keyword And Ignore Error    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}    is_ute_cloud=True
    Start To Capture Wireshark Log From DU    interface=VF1_CPIF00    stream=${stream}
    Run Keyword And Ignore Error    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=180M    dl_tp=1400M    parallel=3
    UE Check Muiti Cells UL&DL Throughput    cells=${6CC_GLOBAL_CELL_IDS}    ultarget_throughput=0    dltarget_throughput=20
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${A9_WIRESHARK_LOG}    stream=${stream}

    Filter Wireshark Log To RRC    ${A9_WIRESHARK_LOG}    ${A9_WIRESHARK_RRC}
    ${field_values}    Check Field Value Via Wireshark    ${A9_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element
    ...    nr-rrc.physCellId    ${6CC_SCELL_PHY_IDS}

    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=M5_DCAP
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm
    Sort List    ${emil_files}
    ${upload_result}    rd.upload_encoded_file    file_name=${emil_files}    connection=M5_DCAP
#    ${filter}=    Create List    ZMQ/SCTP name==SrbSendReq    #msg name changed due to CNI-148261 in 26R2
    ${filter}=    Create List    Message name==ITF_CP_CP_SB_UE_INTERFACE_SRBSENDREQ_ID
    ${decoded_content}    rd.get_decoded_file_contents_in_json    session_id=${upload_result["session_id"]}
    ...    data_source_id=${upload_result["grid_ids"][0]}    what=0    filter=${filter}    connection=M5_DCAP
    ${emil_result}    get_ue_contains_measconfig_from_emil    ${decoded_content}
    Should Be Equal    ${emil_result}    ${A9_EMIL_LOG}

   [Teardown]   Run Keywords
          ...    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
          ...    AND  Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
          ...    AND  MMW5 Common Case Teardown

CB011080-5G-A_13_B8_Buffer_based_Scell_Activation_Deactivation_for FR1_TDD_FDD_DL_6CCs_CA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/10/23 13:34
    [Tags]    13
    # Combined SCF for A_13 and A_27, both cases are use ${SCF_A27} after SBTS26R3.
    IF    '${stream}' == 'SBTS26R1' or '${stream}' == 'SBTS26R2'
        Set Test Variable    ${SCF}    ${SCF_A13}
    ELSE
        Set Test Variable    ${SCF}    ${SCF_A27}
    END
    COAM Commission with scf file    ${SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online
    Init PA For Peak Throughput

    # Step 1
    Run Keyword And Ignore Error    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}    is_ute_cloud=True
    Start To Capture Wireshark Log From DU    interface=VF1_CPIF00    stream=${stream}
    Wait Until Keyword Succeeds    3x    15s    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=220M    dl_tp=1400M    parallel=3
    UE Check Muiti Cells UL&DL Throughput    cells=${6CC_GLOBAL_CELL_IDS}    ultarget_throughput=0    dltarget_throughput=20
    ...    log_dir=${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=0    iperf_port=45040
    Sleep    10s
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${A13_WIRESHARK_LOG}    stream=${stream}

    Filter Wireshark Log To RRC    ${A13_WIRESHARK_LOG}    ${A13_WIRESHARK_RRC}
    ${field_values}    Check Field Value Via Wireshark    ${A13_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element
    ...    nr-rrc.physCellId    ${6CC_SCELL_PHY_IDS}
    ${length}    Get Length    ${field_values}
    Should Be True    ${length} <= 2

    # Step 2
    Get Theory CA Dl Ul Tput
    &{dict_exp_indv_tput_dl}    Run keyword if    ${exp_dl_indiv}
    ...    Get individual expected tput value for cells    list_nrCellIdentity=${dl_cell_list}     list_exp_tput=${exp_dl_indiv}
    ...    ELSE    Set variable    ${None}
    &{dict_exp_indv_tput_ul}    Run keyword if    ${exp_ul_indiv}
    ...    _Get individual expected tput value for cells    list_nrCellIdentity=${ul_cell_list}     list_exp_tput=${exp_ul_indiv}
    ...    ELSE    Set variable    ${None}
    Wait Until Keyword Succeeds    3x    15s    UE Attach With Verify Attach
    Start aasyslog capture    filter=SCellUeSchedulingReqForModifType
    UE Start Muiti DL Traffic   45340    45343    136M    3
    UE Start Muiti DL Traffic   45343    45346    136M    2
    UE Start Muiti DL Traffic   45346    45360    152M    1
    Download aasyslog file from gNB    log_path=/tmp/Aasys_CCS_MCU.txt    local_path=${TS_CASE_LOG_PATH}/11080_13_1.txt
    analysis_syslog_find_str    ${TS_CASE_LOG_PATH}/11080_13_1.txt    ModifType:START    5

    UE Start UL Traffic    throughput=220M    ul_time=600s
    IF    '${stream}' == 'SBTS26R1' or '${stream}' == 'SBTS26R2'
        UE Check Muiti Cells UL&DL Throughput    cells=${6CC_GLOBAL_CELL_IDS}    ultarget_throughput=0    dltarget_throughput=20
        ...    log_dir=${TS_CASE_LOG_PATH}
    ELSE
        ${ul_syslog_tp}    ${dl_syslog_tp}    Check_CA_Throught_From_Asslog    duration=5m
        ...    ul_tp=${theoretical_ul_2CC_sum}   dl_tp=${theoretical_dl_6CC_sum}    target_avg_percent=${0.95}
        ...    ul_list=${ul_cell_list}    dl_list=${dl_cell_list}
        ...    cell_indiv_tput_dl=${dict_exp_indv_tput_dl}    cell_indiv_tput_ul=${dict_exp_indv_tput_ul}
        ...    log_dir=${TS_CASE_LOG_PATH}
    END

    Start aasyslog capture    filter=SCellUeSchedulingReqForModifType
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=0    iperf_port=45040
    UE Stop Muiti DL Traffic   45346    45360
    Sleep    5s
    UE Stop Muiti DL Traffic   45343    45346
    Sleep    5s
    UE Stop Muiti DL Traffic   45341    45343
    Sleep    10s
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    Download aasyslog file from gNB    log_path=/tmp/Aasys_CCS_MCU.txt    local_path=${TS_CASE_LOG_PATH}/11080_13_2.txt
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    analysis_syslog_find_str    ${TS_CASE_LOG_PATH}/11080_13_2.txt    ModifType:DEACTIVATE    5

CB011080-5G-A_19_B14_Mobility_support_for_UE_with_FR1_TDD_FDD_DL_6CCs_CA_for_incoming_handover_UE
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/11/12 17:27
    [Tags]    19
    COAM Commission with scf file    ${SCF_A19}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online

    Init PA For Peak Throughput
    ${channels_to_modify}    create dictionary    9=120    10=120    11=120   12=120
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=3
    Run Keyword And Ignore Error    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}    is_ute_cloud=True
    Start To Capture Wireshark Log From DU    interface=VF1_CPIF00    stream=${stream}
    Wait Until Keyword Succeeds    3x    2min    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=180M    dl_tp=1400M    parallel=3
    UE Check Muiti Cells UL&DL Throughput    cells=${CELL7_2CC_GLOBAL_CELL_IDS}    ultarget_throughput=10
    ...    dltarget_throughput=20
    Stop To Capture Wireshark Log From DU    local_pcap_path=${A19_WIRESHARK_LOG}    stream=${stream}

    Filter Wireshark Log To RRC    ${A19_WIRESHARK_LOG}    ${A19_WIRESHARK_RRC}
    ${field_values}    Check Field Value Via Wireshark    ${A19_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element
    ...    nr-rrc.physCellId    ${CELL7_2CC_PHY_IDS}

    ${channels_to_modify}    create dictionary    9=28    10=24    11=28   12=24
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=3
    Start To Capture Wireshark Log From DU    interface=VF1_CPIF00    stream=${stream}
    ${channels_to_modify}    create dictionary    5=30    6=30   7=30    8=30
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    Sleep    20s
    ${channels_to_modify}    create dictionary    5=40    6=40   7=40    8=40
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    Sleep    40s
    ${channels_to_modify}    create dictionary    5=45    6=45   7=45    8=45
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    Sleep    20s
    ${channels_to_modify}    create dictionary    5=12    6=3   7=3    8=3
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    Sleep    60s
    Stop To Capture Wireshark Log From DU    local_pcap_path=${A19_WIRESHARK_LOG}    stream=${stream}
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true

    UE Check Muiti Cells UL&DL Throughput    cells=${6CC_GLOBAL_CELL_IDS}    ultarget_throughput=0
    ...    dltarget_throughput=20
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE

    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=M5_DCAP
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm
    Sort List    ${emil_files}
    ${upload_result}    rd.upload_encoded_file    file_name=${emil_files}    connection=M5_DCAP
#    ${filter}=    Create List    ZMQ/SCTP name==UlSduReceiveInd
    ${filter}=    Create List    Message name==ITF_CP_CP_SB_UE_INTERFACE_ULSDURECEIVEIND_ID
    ${decoded_content}    rd.get_decoded_file_contents_in_json    session_id=${upload_result["session_id"]}
    ...    data_source_id=${upload_result["grid_ids"][0]}    what=0    filter=${filter}    connection=M5_DCAP
    ${emil_result}    get_ue_contains_measreport_from_emil    ${decoded_content}
    Should Be Equal    ${emil_result}    ${A19_EMIL_LOG}

    Filter Wireshark Log To RRC    ${A19_WIRESHARK_LOG}    ${A19_WIRESHARK_RRC}
    ${field_values}    Check Field Value Via Wireshark    ${A19_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element
    ...    nr-rrc.physCellId    ${CELL5_6CC_PHY_IDS}

    [Teardown]   Run Keywords
          ...    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
          ...    AND  Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
          ...    AND  Run Keyword If    '${TEST STATUS}'=='PASS'    CI_commssion.common commissioning
          ...    AND  MMW5 Common Case Teardown

CB011080-5G-A_27_NR_DL_UL peak_Tput_per_UE_3T_3F
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/10/21 09:54
    [Tags]    27
    IF    '${stream}' == 'SBTS26R1'
        Set Test Variable    ${SCF}    ${SCF_A27_26R1}
    ELSE IF    '${stream}' == 'SBTS26R2'
        Set Test Variable    ${SCF}    ${SCF_A27_26R2}
    ELSE
        Set Test Variable    ${SCF}    ${SCF_A27}
    END
    COAM Commission with scf file    ${SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online
    Init PA For Peak Throughput

    Get Theory CA Dl Ul Tput
    &{dict_exp_indv_tput_dl}    Run keyword if    ${exp_dl_indiv}
    ...    Get individual expected tput value for cells    list_nrCellIdentity=${dl_cell_list}     list_exp_tput=${exp_dl_indiv}
    ...    ELSE    Set variable    ${None}
    &{dict_exp_indv_tput_ul}    Run keyword if    ${exp_ul_indiv}
    ...    _Get individual expected tput value for cells    list_nrCellIdentity=${ul_cell_list}     list_exp_tput=${exp_ul_indiv}
    ...    ELSE    Set variable    ${None}
    Sleep    10s
    Wait Until Keyword Succeeds    3x    15s    UE Attach With Verify Attach
    Sleep    30s
    UE Start DL Traffic    throughput=1400M    dl_time=600s    parallel=3
    Sleep    30s
    UE Start UL Traffic    throughput=220M    ul_time=600s

    ${ul_syslog_tp}    ${dl_syslog_tp}    Check_CA_Throught_From_Asslog    duration=5m
    ...    ul_tp=${theoretical_ul_2CC_sum}   dl_tp=${theoretical_dl_6CC_sum}
    ...    ul_list=${ul_cell_list}    dl_list=${dl_cell_list}
    ...    cell_indiv_tput_dl=${dict_exp_indv_tput_dl}    cell_indiv_tput_ul=${dict_exp_indv_tput_ul}
    ...    log_dir=${TS_CASE_LOG_PATH}
    UE Stop Traffic And Release UE
    Verify M55349 Counters    dl_syslog_value=${dl_syslog_tp}

CB011080-5G-B_28_B1_Multiple_Ues_call_setup_with_FR1_TDD_FDD_DL_6CCs_CA_and_UL_2CCs_CA_3T_3F
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/11/25 17:17
    [Tags]    28
    COAM Commission with scf file    ${SCF_B28}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online
    Init PA For Peak Throughput

    wait_until_next_5_min    extra_sleep_time=0
    Start To Capture Wireshark Log From DU    interface=VF1_CPIF00    stream=${stream}
    Run Keyword And Ignore Error    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=180M    dl_tp=1400M    parallel=3
    UE Check Muiti Cells UL&DL Throughput    cells=${6CC_GLOBAL_CELL_IDS}    ultarget_throughput=0    dltarget_throughput=20
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${B28_WIRESHARK_LOG}    stream=${stream}

    Filter Wireshark Log To RRC    ${B28_WIRESHARK_LOG}    ${B28_WIRESHARK_RRC}
    ${field_values}    Check Field Value Via Wireshark    ${B28_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element
    ...    nr-rrc.physCellId    ${6CC_SCELL_PHY_IDS}

    wait_until_next_5_min
    Verify CA Related Counters

CB011080-5G-C_42_IWK7_Interworking_with_CB008950_for_FR1_TDD_FDD_DL_6CCs_CA_and_UL_2CCs_CA_ALT1
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/11/1 13:40
    [Tags]    42
    COAM Commission with scf file    ${SCF_C42}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online
    Init PA For Peak Throughput

    # Step 1
    wait_until_next_5_min    extra_sleep_time=0
    Start To Capture Wireshark Log From DU    interface=VF1_CPIF00    stream=${stream}
    Run Keyword And Ignore Error    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=180M    dl_tp=1400M    parallel=3
    UE Check Muiti Cells UL&DL Throughput    cells=${6CC_GLOBAL_CELL_IDS}    ultarget_throughput=0    dltarget_throughput=20
    ...    duration=300s    ignore_time=30s
    Run Keyword And Ignore Error    UE Stop Traffic And Release UE
    Stop To Capture Wireshark Log From DU    local_pcap_path=${C42_WIRESHARK_LOG}    stream=${stream}

    Verify CA Related Counters

    Filter Wireshark Log To RRC    ${C42_WIRESHARK_LOG}    ${C42_WIRESHARK_RRC}
    ${field_values}    Check Field Value Via Wireshark    ${C42_WIRESHARK_RRC}    nr-rrc.sCellConfigCommon_element
    ...    nr-rrc.physCellId    ${6CC_SCELL_PHY_IDS}
    ${field_values}    Check Field Value Via Wireshark    ${C42_WIRESHARK_RRC}    nr-rrc.frequencyInfoUL_element
    ...    nr-rrc.FreqBandIndicatorNR    ${7CC_BAND_LIST}

*** Keywords ***
Verify M55349 Counters
    [Documentation]    Verify CB010636 M55349C00031 and M55349C00037 counters percent similar with syslog DL throughput value
    [Arguments]    ${dl_syslog_value}
    wait_until_next_5_min
    ${counters}    coam.get_pm_counters    counter_ids=${counter_CB10636},${counter_ids1},${counter_ids2}    connection=GNB_OAM
#    ${M55349C00026}    Get Recent Single Counter Value
#    ...    counters=${counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-4']['NHRRC']['M55349C00026']}
#    ${M55349C00032}    Get Recent Single Counter Value
#    ...    counters=${counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-4']['NHRRC']['M55349C00032']}
#    Should Be True    ${M55349C00026}>0
#    Should Be True    ${M55349C00032}>0
    ${vol}    Get Recent Single Counter Value
    ...    counters=${counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-4']['NHRRC']['M55349C00031']}
    ${time}    Get Recent Single Counter Value
    ...    counters=${counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-4']['NHRRC']['M55349C00037']}
    ${dl_counter_value}    Evaluate    ${vol}/${time}

    Verify Two Throughputs Are Percent Similar    ${dl_syslog_value}    ${dl_counter_value}

Verify CA Related Counters
    [Documentation]    Verify CA Related Counters in all 6 cells
    [Arguments]
    ${counters}    coam.get_pm_counters
    ...    counter_ids=${counter_ids1},${counter_ids2}
    ...    connection=GNB_OAM
    ${counter_values}    get_target_cell_recent_counters    ${counters}    MRBTS-${MRBTS_ID}    NRBTS-${NRBTS_ID}
    Should Be True    ${counter_values['NRCELL-4']['M55138C03504']}>0
    Should Be True    ${counter_values['NRCELL-4']['M55138C03507']}>0
    Should Be True    ${counter_values['NRCELL-4']['M55118C00013']}>0
    Should Be True    ${counter_values['NRCELL-1']['M55118C00018']}>0
    Should Be True    ${counter_values['NRCELL-2']['M55118C00018']}>0
    Should Be True    ${counter_values['NRCELL-3']['M55118C00018']}>0
    Should Be True    ${counter_values['NRCELL-5']['M55118C00018']}>0
    Should Be True    ${counter_values['NRCELL-6']['M55118C00018']}>0
    Should Be True    ${counter_values['NRCELL-4']['M55139C03003']}>0
    Should Be True    ${counter_values['NRCELL-4']['M55139C03006']}>0
    Should Be True    ${counter_values['NRCELL-4']['M55118C00001']}>0
    Should Be True    ${counter_values['NRCELL-4']['M55118C00004']}>0
    Should Be True    ${counter_values['NRCELL-4']['M55156C00027']}>0
    Should Be True    ${counter_values['NRCELL-4']['M55310C20001']}>0
    Should Be True    ${counter_values['NRCELL-1']['M55310C20000']}>0
    Should Be True    ${counter_values['NRCELL-2']['M55310C20000']}>0
    Should Be True    ${counter_values['NRCELL-3']['M55310C20000']}>0
    Should Be True    ${counter_values['NRCELL-5']['M55310C20000']}>0
    Should Be True    ${counter_values['NRCELL-6']['M55310C20000']}>0
    Should Be True    ${counter_values['NRCELL-4']['M55316C03005']}>0
    Should Be True    ${counter_values['NRCELL-4']['M55316C05005']}>0

