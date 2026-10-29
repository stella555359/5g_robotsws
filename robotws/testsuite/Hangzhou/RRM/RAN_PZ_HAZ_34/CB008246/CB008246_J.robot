*** Settings ***
Documentation
...    author: Zhang Yayun
...    contact: yayun.zhang@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-J

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...             robot_common_operations.Common Suite Setup
...             AND    Common Suite Setup for COAM
...             AND    Get gnb release info
...             AND    Run Keyword If    '${release_info}' == 'SBTS25R1_ENB_9999'
...             Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}_specious}
...             ELSE    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${specious_scf}
...             AND    Common UE parameter setup

Suite Teardown     Run Keywords    Common Suite Teardown for COAM    gnb_list=${gnb_list}
...                AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_J_002_1}    log_name_J_002_1.pcap
${log_name_J_002_2}    log_name_J_002_2.pcap
${log_name_J_002_3}    log_name_J_002_3.pcap
${log_name_J_002_4}    log_name_J_002_4.pcap
${log_name_J_002_5}    log_name_J_002_5.pcap
${log_name_J_002_6}    log_name_J_002_6.pcap
${log_name_J_002_7}    log_name_J_002_7.pcap
${log_name_J_002_8}    log_name_J_002_8.pcap
${log_name_J_002_9}    log_name_J_002_9.pcap
${log_name_J_003_1}    log_name_J_003_1.pcap
${log_name_J_003_2}    log_name_J_003_2.pcap
${log_name_J_003_3}    log_name_J_003_3.pcap
${log_name_J_003_4}    log_name_J_003_4.pcap
${log_name_J_003_5}    log_name_J_003_5.pcap
${log_name_J_005_1}    log_name_J_005_1.pcap
${log_name_J_005_2}    log_name_J_005_2.pcap
${log_name_J_005_3}    log_name_J_005_3.pcap
${log_name_J_005_4}    log_name_J_005_4.pcap
${log_name_J_005_5}    log_name_J_005_5.pcap
${enb_log_name_J_005}    enb_log_name_J_005.pcap
${log_name_J_006_1}    log_name_J_006_1.pcap
${log_name_J_009_1}    log_name_J_009_1.pcap
${expected_tput_dl}    5
${Send_Tput_DL}        10M
${Send_Tput_UL}        100M
${expected_tput_ul_X70}    50
${Send_Tput_UL_J003}        20M
${expected_tput_ul_HW_J003}    15
${Send_Tput_DL_J005}    400M
${Send_Tput_UL_J005}    100M
${expected_tput_dl_J005}    200
${expected_tput_ul_J005}    50
${Send_Tput_UL_J006}    100M
${expected_tput_ul_J006}    50
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-J_Counter&KPI
${X70_wap2apn_location}    959 1370
${X70_mdrb1apn_location}    956 1804
${imsi3}    ${tl.ues[2].imsi}
${add5QI8rule}    ADD5QI8-PZ4-MXD
${dele5QI8rule}    DEL5QI8-PZ4-MXD
${zzmdrb1_apn_name}    ${tl.ues[0].pdn[7]}
${wap2_apn_name}    ${tl.ues[0].pdn[0]}

${specious_scf}    Configuration_scf_GNB1_CB008246_Q.xml
${tl_scf_SBTS25R1_ENB_9999_specious}    25R1_Configuration_scf_GNB1_CB008246_specious.xml

#*** Test Cases ***
#[1]CB008246-J_002_HR_DRB_is_added_or_released_while_the_UE_is_using_DFT-s-OFDM_waveform
#    [Documentation]    CB008246-J
#    [Tags]    CB008246-J    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Modify Parameters for Cases     gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_J_002}
#    ...    Delete_Para_Online=${PARAM_8246_delete_gnb1_J_002}    skip_parameter_relation_errors=False
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    Log To Console    change UE3 APN to mdrb1.nokia.com
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
#    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${zzmdrb1_apn_name}
#    Log To Console    UE3 attach on gnb1 cell1
#    Start capture gNB log on master    filename=${log_name_J_002_1}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
#    Sleep    30s
#    Stop and download Logs on gNB on master    filename=${log_name_J_002_1}
#    Check wireshark log for 8246_J_UE_RNTI_ID    logname=${log_name_J_002_1}
#    Log To Console    Analysis wireshark for J002_1
#    Analysis wireshark for J002_1    logname=${log_name_J_002_1}
#    sleep    10s
#    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
#    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
#    Start only UL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
#    ...                                tput_ul_cell=${expected_tput_ul_X70}    ul_throughput=${Send_Tput_UL}    duration=${7200}
#    Log To Console    Analysis wireshark for J002_2
#    Analysis wireshark for J002_2   logname=${log_name_J_002_2}
#    Log To Console    Analysis wireshark for J002_3
#    Analysis wireshark for J002_3   logname=${log_name_J_002_3}
#    Log To Console    Analysis wireshark for J002_4
#    Analysis wireshark for J002_4   logname=${log_name_J_002_4}
#    Log To Console    Analysis wireshark for J002_5
#    Analysis wireshark for J002_5   logname=${log_name_J_002_5}
#    Log To Console    Analysis wireshark for J002_6
#    Analysis wireshark for J002_6   logname=${log_name_J_002_6}
#    Log To Console    Analysis wireshark for J002_7
#    Analysis wireshark for J002_7   logname=${log_name_J_002_7}
#    Log To Console    Analysis wireshark for J002_8
#    Analysis wireshark for J002_8   logname=${log_name_J_002_8}
#    Log To Console    Analysis wireshark for J002_9
#    Analysis wireshark for J002_9   logname=${log_name_J_002_9}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
#    ...    AND    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
#    ...    AND    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs all log
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    AND    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_recover_gnb1_J_002}
#    ...    Delete_Para_Online=${PARAM_8246_recover_delete_gnb1_J_002}    skip_parameter_relation_errors=False
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#
#[1]CB008246-J_003_Link_adaptation_for_high_reliability_feature_interworking_with_DFT-s-OFDM_and_256QAM_Without_UE_capability
#    [Documentation]    CB008246-J
#    [Tags]    CB008246-J    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
##    ${release_info}    Get sagnb release
#    ####2023/12/17 descoped_CB009427_actAdaptiveUlBlerTarget IWK for trunk and 24R1
#    Modify Parameters for Cases J003
##    Modify Parameters for Cases     gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_J_003}
##    ...    skip_parameter_relation_errors=False
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    Log To Console    UE1 attach on gnb1 cell1
#    Start capture gNB log on master    filename=${log_name_J_003_1}
#    power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${0}
#    Attach and check power UE    ue_type=${ue_type1}    ue_index=${0}    gnb_index=${0}
#    Sleep    10s
#    Stop and download Logs on gNB on master    filename=${log_name_J_003_1}
#    Check wireshark log for 8246_J_UE_RNTI_ID    logname=${log_name_J_003_1}
#    Log To Console    Analysis wireshark for J003_1
#    Analysis wireshark for J003_1    logname=${log_name_J_003_1}
#    sleep    10s
#    Log To Console    UE1 UL traffic 20M
#    Start only UL traffic and check tput    ue_index=${0}    cellid=${1}    ue_type=${ue_type1}    gnb_index=${0}
#    ...                                tput_ul_cell=${expected_tput_ul_HW_J003}    ul_throughput=${Send_Tput_UL_J003}    duration=${7200}
#    Log To Console    Analysis wireshark for J003_2
#    Analysis wireshark for J003_2   logname=${log_name_J_003_2}
#    Log To Console    Analysis wireshark for J003_3
#    Analysis wireshark for J003_3   logname=${log_name_J_003_3}
#    Log To Console    Analysis wireshark for J003_4
#    Analysis wireshark for J003_4   logname=${log_name_J_003_4}
#    Log To Console    Analysis wireshark for J003_5
#    Analysis wireshark for J003_5   logname=${log_name_J_003_5}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=UL
#    ...    AND    UE.UE Detach    ue_type=${ue_type1}    ue_index=${0}
#    ...    AND    Run Keyword And Ignore Error    Stop J003 and download Logs all log
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    AND    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_recover_gnb1_J_003}
#    ...    skip_parameter_relation_errors=False
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#
#[1]CB008246-J_005_Link_adaptation_for_high_reliability_feature_interworking_with_DFT-s-OFDM_and_256QAM_With_NSA
#    [Documentation]    CB008246-J
#    [Tags]    CB008246-J    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    ####2023/12/17 descoped_CB009427_actAdaptiveUlBlerTarget IWK for trunk and 24R1
#    Online modify parmeters enb    parameters_to_update=${PARAM_8246_enb1_J_005}    skip_parameter_relation_errors=False
#    Modify Parameters for Cases     gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_J_005}
#    ...    Delete_Para_Online=${PARAM_8246_delete_gnb1_J_005}     skip_parameter_relation_errors=False
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
#    Comment    UE3 attach on gnb1 cell2
#    Start capture gNB log on master    filename=${log_name_J_005_1}
#    Start to collect the log on eNB    log_name=${enb_log_name_J_005}    interface=br1
#    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}    4G_check=True
#    Sleep    30s
#    Stop and download Logs on eNB    log_name=${enb_log_name_J_005}
#    Stop and download Logs on gNB on master    filename=${log_name_J_005_1}
#    Check wireshark log for 8246_J_UE_RNTI_ID_NSA    logname=${log_name_J_005_1}
#    Log To Console    Analysis wireshark for J005_1
#    Analysis wireshark for J005_1   logname=${log_name_J_005_1}
#    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
#    ...                                tput_dl_cell=${expected_tput_dl_J005}    dl_throughput=${Send_Tput_DL_J005}    duration=${7200}
#    Start only UL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
#    ...                                tput_ul_cell=${expected_tput_ul_J005}    ul_throughput=${Send_Tput_UL_J005}    duration=${7200}
#    Log To Console    Analysis wireshark for J005_2
#    Analysis wireshark for J005_2   logname=${log_name_J_005_2}
#    Log To Console    Analysis wireshark for J005_3
#    Analysis wireshark for J005_3   logname=${log_name_J_005_3}
#    Log To Console    Analysis wireshark for J005_4
#    Analysis wireshark for J005_4   logname=${log_name_J_005_4}
#    Log To Console    Analysis wireshark for J005_5
#    Analysis wireshark for J005_5   logname=${log_name_J_005_5}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
#    ...    AND    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
#    ...    AND    Switch QCOM airplane mode status on    ue_index=${2}    ue_type=${ue_type}
##    ...    AND    UE.UE Detach     ue_type=${ue_type}     ue_index=${2}
#    ...    AND    Run Keyword And Ignore Error    Stop J005 and download Logs all log
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    AND    Online modify parmeters enb    parameters_to_update=${PARAM_8246_recover_enb1_J_005}    skip_parameter_relation_errors=False
#    ...    AND    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_recover_gnb1_J_005}
#    ...    Delete_Para_Online=${PARAM_8246_recover_delete_gnb1_J_002}    skip_parameter_relation_errors=False
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#
#[1]CB008246-J_006_HR_LA_feature_interworking_with_Configured_Grants_Type2_in_UL_while_UE_is_not_previously_configured_with_CG_Type2_and_HR
#    [Documentation]    CB008246-J
#    [Tags]    CB008246-J    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
##    ${release_info}    Get sagnb release
#    Modify Parameters for Cases     gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_J_006}
#    ...    skip_parameter_relation_errors=False
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    Log To Console    UE3 attach on gnb1 cell1
#    Start capture gNB log on master    filename=${log_name_J_006_1}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
#    Sleep    30s
#    Stop and download Logs on gNB on master    filename=${log_name_J_006_1}
#    Check wireshark log for 8246_J_UE_RNTI_ID    logname=${log_name_J_006_1}
#    Log To Console    Analysis wireshark for J006_1
#    Analysis wireshark for J006_1    logname=${log_name_J_006_1}
#    sleep    10s
#    Start only UL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
#    ...                                tput_ul_cell=${expected_tput_ul_J006}    ul_throughput=${Send_Tput_UL_J006}    duration=${7200}
#    Log To Console    Analysis wireshark for J006_2
#    Analysis wireshark for J006_2
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
#    ...    AND    UE.UE Detach     ue_type=${ue_type}     ue_index=${2}
#    ...    AND    Run Keyword And Ignore Error    Stop J006 and download Logs all log
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    AND    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_recover_gnb1_J_006}
#    ...    Delete_Para_Online=${PARAM_8246_recover_delete_gnb1_J_006}    skip_parameter_relation_errors=False
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#
#[1]CB008246-J_009_HRLA_iwk_with_CGType2_in_UL_while_UE_is_not_previously_configured_with_CGType2_wo_ul_lowse
#    [Documentation]    CB008246-J
#    [Tags]    CB008246-J    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
##    ${release_info}    Get sagnb release
#    Modify Parameters for Cases     gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_J_009}
#    ...    Delete_Para_Online=${PARAM_8246_delete_gnb1_J_009}    skip_parameter_relation_errors=False
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    Log To Console    UE3 attach on gnb1 cell1
#    Start capture gNB log on master    filename=${log_name_J_009_1}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
#    Sleep    30s
#    Stop and download Logs on gNB on master    filename=${log_name_J_009_1}
#    Check wireshark log for 8246_J_UE_RNTI_ID    logname=${log_name_J_009_1}
#    Log To Console    Analysis wireshark for J009_1
#    Analysis wireshark for J009_1    logname=${log_name_J_009_1}
#    sleep    10s
#    Start only UL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
#    ...                                tput_ul_cell=${expected_tput_ul_J006}    ul_throughput=${Send_Tput_UL_J006}    duration=${7200}
#    Log To Console    Analysis wireshark for J009_2
#    Analysis wireshark for J009_2
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
#    ...    AND    UE.UE Detach     ue_type=${ue_type}     ue_index=${2}
#    ...    AND    Run Keyword And Ignore Error    Stop J009 and download Logs all log
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    AND    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_recover_gnb1_J_009}
#    ...    Delete_Para_Online=${PARAM_8246_recover_delete_gnb1_J_009}    skip_parameter_relation_errors=False
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

*** Keywords ***
Analysis wireshark for J009_1
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check 5QI5 qam256 F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.downlinkBWP_ToAddModList == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_mcs_Table}    1   2
    Log To Console    check 5QI7 qamLowSE F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_mcs_Table}    1   2
    Log To Console    check 5QI 7 CGType2 setup F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index1}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index1    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_betaOffsetACK_Index1}    9   1
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index2}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index2    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_betaOffsetACK_Index2}    6   1
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index3}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index3    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_betaOffsetACK_Index3}    3   1
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetCSI_Part1_Index1}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_betaOffsetCSI_Part1_Index1}    11   1
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetCSI_Part1_Index2}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_betaOffsetCSI_Part1_Index2}    6   1

Analysis wireshark for J009_2
    sleep    2s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_J009_2    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J009_2    nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J009_2    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J009_2    nr_phy_cell_ids=59
    sleep    5s
    Analysis tti for J009_2    names=l2stream3_ttitrace_J009_2
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check trunk counter for 8246_HR_J009_gNB1cell1

Check trunk counter for 8246_HR_J009_gNB1cell1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_J009_LowSE_HR_gNB1_cell1}    dic_path=${Trunk_counter_dic_path_J009_LowSE_HR_gNB1_cell1}
    Set suite variable    ${M55367C00001_LowSE_HR}                   ${counter_value_list}[0]
    Set suite variable    ${M55367C00002_LowSE_HR}                   ${counter_value_list}[1]
    Set suite variable    ${M55367C00003_LowSE_HR}                   ${counter_value_list}[2]
    Set suite variable    ${M55367C00004_LowSE_HR}                   ${counter_value_list}[3]
    ${J006_LowSE_HR_gap1}=    Evaluate    ${M55367C00001_LowSE_HR} + ${M55367C00003_LowSE_HR}- ${M55367C00002_LowSE_HR} - ${M55367C00004_LowSE_HR}
    ${J006_LowSE_HR_gap2}=    Evaluate    ${M55367C00001_LowSE_HR} + ${M55367C00003_LowSE_HR}
    ${J006_LowSE_HR_gap}=    Evaluate     ${J006_LowSE_HR_gap1}/${J006_LowSE_HR_gap2}
    Should Be True    ${J006_LowSE_HR_gap}<=0.011

Check counter for 8246_HR_J009_gNB1cell1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_J009_LowSE_HR_gNB1_cell1}    dic_path=${counter_dic_path_J009_LowSE_HR_gNB1_cell1}
    Set suite variable    ${M55367C00001_LowSE_HR}                   ${counter_value_list}[0]
    Set suite variable    ${M55367C00002_LowSE_HR}                   ${counter_value_list}[1]
    Set suite variable    ${M55367C00003_LowSE_HR}                   ${counter_value_list}[2]
    Set suite variable    ${M55367C00004_LowSE_HR}                   ${counter_value_list}[3]
    ${J006_LowSE_HR_gap1}=    Evaluate    ${M55367C00001_LowSE_HR} + ${M55367C00003_LowSE_HR}- ${M55367C00002_LowSE_HR} - ${M55367C00004_LowSE_HR}
    ${J006_LowSE_HR_gap2}=    Evaluate    ${M55367C00001_LowSE_HR} + ${M55367C00003_LowSE_HR}
    ${J006_LowSE_HR_gap}=    Evaluate     ${J006_LowSE_HR_gap1}/${J006_LowSE_HR_gap2}
    Should Be True    ${J006_LowSE_HR_gap}<=0.011

Analysis tti for J009_2
    [Arguments]    ${names}
    log to console    analysis tti file for J009_2 from Case_Logs file...
    ${hr_NgbrUlCgType2Prb}    get_NgbrUlCgType2Prb_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti    filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}    filter_name4=ulFdSchedData.mcsTable
    ...    filter_name5=ulFdSchedData.numOfNgbrUlCgType2Prb    filter_name6=ulFdSchedData.targetBLER
    Should Contain    ${hr_NgbrUlCgType2Prb}    4.0

Stop J009 and download Logs all log
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_009_1}

Stop J006 and download Logs all log
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_006_1}

Analysis wireshark for J006_1
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check 5QI5 qam256 F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.uplinkBWP_ToAddModList == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_mcs_Table}    0   2
    Log To Console    check 5QI5 cqitable2 F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.cqi_Table == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_cqi_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.cqi_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_cqi_Table[0]}    1

    Log To Console    check 5QI7 qamLowSE F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.uplinkBWP_ToAddModList == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_mcs_Table}    1   3
    Log To Console    check 5QI7 F1AP DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.transformPrecoder == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    Should Be Equal    ${nr_rrc_transformPrecoder[0]}    1

    Log To Console    check 5QI 7 F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index1}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index1    pcap_parser=test6
#    Should Be Equal    ${nr_rrc_betaOffsetACK_Index1[0]}    9
    Should Contain X Times    ${nr_rrc_betaOffsetACK_Index1}    9   2
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index2}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index2    pcap_parser=test6
#    Should Be Equal    ${nr_rrc_betaOffsetACK_Index2[0]}    6
    Should Contain X Times    ${nr_rrc_betaOffsetACK_Index2}    6   2
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index3}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index3    pcap_parser=test6
#    Should Be Equal    ${nr_rrc_betaOffsetACK_Index3[0]}    3
    Should Contain X Times    ${nr_rrc_betaOffsetACK_Index3}    3   2
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetCSI_Part1_Index1}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1    pcap_parser=test6
#    Should Be Equal    ${nr_rrc_betaOffsetCSI_Part1_Index1[0]}    11
    Should Contain X Times    ${nr_rrc_betaOffsetCSI_Part1_Index1}    11   2
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetCSI_Part1_Index2}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2    pcap_parser=test6
#    Should Be Equal    ${nr_rrc_betaOffsetCSI_Part1_Index2[0]}    6
    Should Contain X Times    ${nr_rrc_betaOffsetCSI_Part1_Index2}    6   2

    Log To Console    check 5QI7 cqitable1 F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.configuredGrantConfig == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_cqi_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.cqi_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_cqi_Table[0]}    0

Analysis wireshark for J006_2
    sleep    2s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_J006_2    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J006_2    nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J006_2    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J006_2    nr_phy_cell_ids=59
    sleep    5s
    Analysis tti for J006_2    names=l2stream3_ttitrace_J006_2
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check trunk counter for 8246_HR_J006_gNB1cell1

Analysis tti for J006_2
    [Arguments]    ${names}
    log to console    analysis tti file for J006_2 from Case_Logs file...
    ${hr_NgbrUlCgType2Prb}    get_NgbrUlCgType2Prb_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti    filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}    filter_name4=ulFdSchedData.mcsTable
    ...    filter_name5=ulFdSchedData.numOfNgbrUlCgType2Prb    filter_name6=ulFdSchedData.targetBLER
    Should Contain    ${hr_NgbrUlCgType2Prb}    4.0

Check trunk counter for 8246_HR_J006_gNB1cell1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_J006_LowSE_HR_gNB1_cell1}    dic_path=${Trunk_counter_dic_path_J006_LowSE_HR_gNB1_cell1}
    Set suite variable    ${M55367C00001_LowSE_HR}                   ${counter_value_list}[0]
    Set suite variable    ${M55367C00002_LowSE_HR}                   ${counter_value_list}[1]
    Set suite variable    ${M55367C00003_LowSE_HR}                   ${counter_value_list}[2]
    Set suite variable    ${M55367C00004_LowSE_HR}                   ${counter_value_list}[3]
    ${J006_LowSE_HR_gap1}=    Evaluate    ${M55367C00001_LowSE_HR} + ${M55367C00003_LowSE_HR}- ${M55367C00002_LowSE_HR} - ${M55367C00004_LowSE_HR}
    ${J006_LowSE_HR_gap2}=    Evaluate    ${M55367C00001_LowSE_HR} + ${M55367C00003_LowSE_HR}
    ${J006_LowSE_HR_gap}=    Evaluate     ${J006_LowSE_HR_gap1}/${J006_LowSE_HR_gap2}
    Should Be True    ${J006_LowSE_HR_gap}<=0.011

Check counter for 8246_HR_J006_gNB1cell1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_J006_LowSE_HR_gNB1_cell1}    dic_path=${counter_dic_path_J006_LowSE_HR_gNB1_cell1}
    Set suite variable    ${M55367C00001_LowSE_HR}                   ${counter_value_list}[0]
    Set suite variable    ${M55367C00002_LowSE_HR}                   ${counter_value_list}[1]
    Set suite variable    ${M55367C00003_LowSE_HR}                   ${counter_value_list}[2]
    Set suite variable    ${M55367C00004_LowSE_HR}                   ${counter_value_list}[3]
    ${J006_LowSE_HR_gap1}=    Evaluate    ${M55367C00001_LowSE_HR} + ${M55367C00003_LowSE_HR}- ${M55367C00002_LowSE_HR} - ${M55367C00004_LowSE_HR}
    ${J006_LowSE_HR_gap2}=    Evaluate    ${M55367C00001_LowSE_HR} + ${M55367C00003_LowSE_HR}
    ${J006_LowSE_HR_gap}=    Evaluate     ${J006_LowSE_HR_gap1}/${J006_LowSE_HR_gap2}
    Should Be True    ${J006_LowSE_HR_gap}<=0.011

Check wireshark log for 8246_J_UE_RNTI_ID_NSA
    [Arguments]    ${logname}
    ${UE_RNTI_ID}=    Get NSA_RNTI-ID message    logname=${logname}
    Set Suite Variable    ${SA_UE_RNTI_ID}    ${UE_RNTI_ID}

Get NSA_RNTI-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####SACK,UEContextSetupResponse
    ${UEContextSetupResponse}=     Catenate    (f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 5 and f1ap.C_RNTI)
    ${UEContextSetupResponse_packets}=    cap.filter_packets_by_expression    filter_expression=${UEContextSetupResponse}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${UEContextSetupResponse_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    [Return]    ${UE_RNTI_ID}[0]

Analysis wireshark for J005_1
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
	Log To Console    check qci 7 qam64LowSE SgNBAdditionRequestAckbowledge,RRC Reconfiguration
    ${filter_expression}=     Catenate    (x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.mcs_Table == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_mcs_Table}    1   2
    Log To Console    check qci 7 cqi_table SgNBAdditionRequestAckbowledge,RRC Reconfiguration
    ${filter_expression}=     Catenate    (x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.cqi_Table == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_cqi_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.cqi_Table   pcap_parser=test6
    Should Contain X Times    ${nr_rrc_cqi_Table}    0   1
    Log To Console    check qci 7 transformPrecoder: disabled (1) SgNBAdditionRequestAckbowledge,RRC Reconfiguration
    ${filter_expression}=     Catenate    (x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27 and nr-rrc.transformPrecoder == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder   pcap_parser=test6
    Should Contain X Times    ${nr_rrc_transformPrecoder}    1   1

Analysis wireshark for J005_2
    [Arguments]    ${logname}
    Log To Console    Decrease attenuation slowly to trigger SINR<10
    Start capture gNB log on master    filename=${log_name_J_005_2}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${30}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${20}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${20}    enb_cell1_value=${0}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_005_2}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check X2AP check No SgNBModificationRequired,RRC Reconfiguration
    ${filter_expression}=     Catenate    (x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 30)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${x2ap_procedureCode}=     cap.Get Field Value By Xpath    xpath=.//x2ap.procedureCode    pcap_parser=test6
    should not contain    ${x2ap_procedureCode}    30
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_J005_2    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_2    nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_2    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_2    nr_phy_cell_ids=59
    sleep    2s
    Analysis tti for J005_2    names=l2stream3_ttitrace_J005_2

Analysis tti for J005_2
    [Arguments]    ${names}
    log to console    analysis tti file for J005_2 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    HIGHRELIABILITY
    END

Analysis wireshark for J005_3
    [Arguments]    ${logname}
    Log To Console    Decrease attenuation slowly to trigger ulHRBlerOutageTbsThresh64qam<1000
    Start capture gNB log on master    filename=${log_name_J_005_3}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${45}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${40}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${40}    enb_cell1_value=${0}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_005_3}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check transformPrecoder SgNBModificationRequired,RRC Reconfiguration
    ${filter_expression}=     Catenate    (x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 30 and nr-rrc.transformPrecoder == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_transformPrecoder}    0   1
    Log To Console    check QCI 7 no cqi-table1(64QAM) F1AP DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 30 and nr-rrc.cqi_Table ==0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.cqi_Table    pcap_parser=test6
    should not contain    ${nr_rrc_mcs_Table}    0
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_J005_3    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_3    nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_3    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_3    nr_phy_cell_ids=59
    sleep    2s
    Analysis tti for J005_3    names=l2stream3_ttitrace_J005_3
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check Trunk counter for 8246_BR_J005_gNB1cell1

Check Trunk counter for 8246_BR_J005_gNB1cell1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_J005_LowSE_BR_gNB1_cell1}    dic_path=${Trunk_counter_dic_path_J005_LowSE_BR_gNB1_cell1}
    Set suite variable    ${M55302C00033_64QAM_BR}                   ${counter_value_list}[0]
    Set suite variable    ${M55302C00034_64QAM_BR}                   ${counter_value_list}[1]
    ${J005_64QAM_BR_gap}=    Evaluate    (${M55302C00033_64QAM_BR} - ${M55302C00034_64QAM_BR})/${M55302C00033_64QAM_BR}
    ####2023/12/17 descoped_CB009427_actAdaptiveUlBlerTarget IWK for trunk and 24R1, counter change to 0.12
#    Should Be True    ${J005_64QAM_BR_gap}<=0.2
    Should Be True    ${J005_64QAM_BR_gap}<=0.12

Analysis tti for J005_3
    [Arguments]    ${names}
    log to console    analysis tti file for J005_3 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    BASICRELIABILITY
    END
    ${hr_ulFdSchedData_targetBLER}    get_ulFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.targetBLER    filter_name3=${SA_UE_RNTI_ID}
    ####2023/12/17 descoped_CB009427_actAdaptiveUlBlerTarget IWK for trunk and 24R1
#    ${contains_value1_or_value2}    Set Variable    ${True}    if    any(item in ['0.15', '0.2'] for item in ${hr_ulFdSchedData_targetBLER})
#    Should Be True    ${contains_value1_or_value2}
    FOR  ${i}    IN    @{hr_ulFdSchedData_targetBLER}
        should be equal      ${${i}}    ${${0.1}}
    END

Analysis wireshark for J005_4
    [Arguments]    ${logname}
    Log To Console    increase attenuation slowly to trigger ulHRBlerRecoverTbsThresh64qam>7000
    Start capture gNB log on master    filename=${log_name_J_005_4}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${25}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${20}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${20}    enb_cell1_value=${0}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_005_4}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check X2AP check No SgNBModificationRequired,RRC Reconfiguration
    ${filter_expression}=     Catenate    (x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 30)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${x2ap_procedureCode}=     cap.Get Field Value By Xpath    xpath=.//x2ap.procedureCode    pcap_parser=test6
    should not contain    ${x2ap_procedureCode}    30
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_J005_4    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_4    nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_4    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_4    nr_phy_cell_ids=59
    sleep    2s
    Analysis tti for J005_4    names=l2stream3_ttitrace_J005_4

Analysis tti for J005_4
    [Arguments]    ${names}
    log to console    analysis tti file for J005_4 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    BASICRELIABILITY
    END

Analysis wireshark for J005_5
    [Arguments]    ${logname}
    Log To Console    increase attenuation slowly to trigger ulHRBlerRecoverTbsThresh64qam>7000
    Start capture gNB log on master    filename=${log_name_J_005_5}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_005_5}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check transformPrecoder DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 30 and nr-rrc.transformPrecoder == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    Should Be Equal    ${nr_rrc_transformPrecoder[0]}    1
    Log To Console    check qci 7 qam64LowSE SgNBAdditionRequestAckbowledge,RRC Reconfiguration
    ${filter_expression}=     Catenate    (x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 30 and nr-rrc.mcs_Table == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[0]}    1
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_J005_5    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_5    nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_5    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J005_5    nr_phy_cell_ids=59
    sleep    2s
    Analysis tti for J005_5    names=l2stream3_ttitrace_J005_5
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check Trunk counter for 8246_HR_J005_gNB1cell1

Check Trunk counter for 8246_HR_J005_gNB1cell1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_J005_LowSE_HR_gNB1_cell1}    dic_path=${Trunk_counter_dic_path_J005_LowSE_HR_gNB1_cell1}
    Set suite variable    ${M55367C00001_LowSE_HR}                   ${counter_value_list}[0]
    Set suite variable    ${M55367C00002_LowSE_HR}                   ${counter_value_list}[1]
    Set suite variable    ${M55367C00003_LowSE_HR}                   ${counter_value_list}[2]
    Set suite variable    ${M55367C00004_LowSE_HR}                   ${counter_value_list}[3]
    ${J006_LowSE_HR_gap1}=    Evaluate    ${M55367C00001_LowSE_HR} + ${M55367C00003_LowSE_HR}- ${M55367C00002_LowSE_HR} - ${M55367C00004_LowSE_HR}
    ${J006_LowSE_HR_gap2}=    Evaluate    ${M55367C00001_LowSE_HR} + ${M55367C00003_LowSE_HR}
    ${J006_LowSE_HR_gap}=    Evaluate     ${J006_LowSE_HR_gap1}/${J006_LowSE_HR_gap2}
    Should Be True    ${J006_LowSE_HR_gap}<=0.011

Analysis tti for J005_5
    [Arguments]    ${names}
    log to console    analysis tti file for J005_5 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    HIGHRELIABILITY
    END

Stop J005 and download Logs all log
        Run Keyword And Ignore Error    Stop and download Logs on eNB              log_name=${enb_log_name_J_005}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_005_1}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_005_2}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_005_3}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_005_4}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_005_5}

Stop J003 and download Logs all log
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_003_1}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_003_2}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_003_3}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_003_4}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_003_5}

Modify Parameters for Cases J003
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Modify Parameters for Cases     gnb_index=${0}
    ...                  Modify_Para_Online=${PARAM_8246_gnb1_J_003_367}    skip_parameter_relation_errors=False
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Modify Parameters for Cases     gnb_index=${0}
    ...                  Modify_Para_Online=${PARAM_8246_gnb1_J_003_382}    skip_parameter_relation_errors=False
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Modify Parameters for Cases     gnb_index=${0}
    ...                  Modify_Para_Online=${PARAM_8246_gnb1_J_003_343}    skip_parameter_relation_errors=False

Analysis wireshark for J003_1
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check 5QI 5 256QAM F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[0]}    0
    Log To Console    check 5QI 5 cqi Table2 F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.cqi_Table == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_cqi_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.cqi_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_cqi_Table[0]}    1
    Log To Console    check 5QI 5 F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.mcs_Table == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index1}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index1    pcap_parser=test6
    Should Be Equal    ${nr_rrc_betaOffsetACK_Index1[0]}    11
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.mcs_Table == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index2}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index2    pcap_parser=test6
    Should Be Equal    ${nr_rrc_betaOffsetACK_Index2[0]}    8
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.mcs_Table == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index3}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index3    pcap_parser=test6
    Should Be Equal    ${nr_rrc_betaOffsetACK_Index3[0]}    6
    Log To Console    check 5QI 7 cqi-table1 F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.dedicatedNAS_MessageList == 1
    ...    and nr-rrc.cqi_Table ==0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.cqi_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[0]}    0
    Log To Console    check 5QI 7 transformPrecoder F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.dedicatedNAS_MessageList == 1
    ...     and nr-rrc.transformPrecoder == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    Should Be Equal    ${nr_rrc_transformPrecoder[0]}    1

Analysis wireshark for J003_2
    [Arguments]    ${logname}
    Log To Console    Decrease attenuation slowly to trigger SINR<10
    Start capture gNB log on master    filename=${log_name_J_003_2}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${25}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${20}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${25}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_003_2}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP No DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${f1ap_procedureCode}=     cap.Get Field Value By Xpath    xpath=.//f1ap.procedureCode    pcap_parser=test6
    should not contain    ${f1ap_procedureCode}    12
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_2    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_2    nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_2    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_2    nr_phy_cell_ids=59
    sleep    2s
    Analysis tti for J003_2    names=l2stream3_ttitrace_J003_2

Analysis tti for J003_2
    [Arguments]    ${names}
    log to console    analysis tti file for J003_2 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    HIGHRELIABILITY
    END

Analysis wireshark for J003_3
    [Arguments]    ${logname}
    Log To Console    Decrease attenuation slowly to trigger ulHRBlerOutageTbsThresh64qam<1000
    Start capture gNB log on master    filename=${log_name_J_003_3}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${38}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${36}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${38}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_003_3}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check transformPrecoder DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.transformPrecoder == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    Should Be Equal    ${nr_rrc_transformPrecoder[0]}    0
    Log To Console    check 5QI 7 no cqi-table1(64QAM) F1AP DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.cqi_Table ==0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.cqi_Table    pcap_parser=test6
    should not contain    ${nr_rrc_mcs_Table}    0
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_3    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_3    nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_3    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_3    nr_phy_cell_ids=59
    sleep    2s
    Analysis tti for J003_3    names=l2stream3_ttitrace_J003_3
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check Trunk counter for 8246_BR_J003_gNB1cell1

Check Trunk counter for 8246_BR_J003_gNB1cell1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_J003_64QAM_BR_gNB1_cell1}    dic_path=${Trunk_counter_dic_path_J003_64QAM_BR_gNB1_cell1}
    Set suite variable    ${M55302C00033_64QAM_BR}                   ${counter_value_list}[0]
    Set suite variable    ${M55302C00034_64QAM_BR}                   ${counter_value_list}[1]
    ${J003_64QAM_BR_gap}=    Evaluate    (${M55302C00033_64QAM_BR} - ${M55302C00034_64QAM_BR})/${M55302C00033_64QAM_BR}
    ####2023/12/17 descoped_CB009427_actAdaptiveUlBlerTarget IWK for trunk and 24R1, counter change to 0.12
#    Should Be True    ${J003_64QAM_BR_gap}<=0.2
    Should Be True    ${J003_64QAM_BR_gap}<=0.12

Check counter for 8246_BR_J003_gNB1cell1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_J003_64QAM_BR_gNB1_cell1}    dic_path=${counter_dic_path_J003_64QAM_BR_gNB1_cell1}
    Set suite variable    ${M55302C00033_64QAM_BR}                   ${counter_value_list}[0]
    Set suite variable    ${M55302C00034_64QAM_BR}                   ${counter_value_list}[1]
    ${J003_64QAM_BR_gap}=    Evaluate    (${M55302C00033_64QAM_BR} - ${M55302C00034_64QAM_BR})/${M55302C00033_64QAM_BR}
    ####2023/12/17 descoped_CB009427_actAdaptiveUlBlerTarget IWK for trunk and 24R1, counter change to 0.12
#    Should Be True    ${J003_64QAM_BR_gap}<=0.2
    Should Be True    ${J003_64QAM_BR_gap}<=0.12

Analysis tti for J003_3
    [Arguments]    ${names}
    log to console    analysis tti file for J003_3 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    BASICRELIABILITY
    END
    ####2023/12/17 descoped_CB009427_actAdaptiveUlBlerTarget IWK for trunk and 24R1
    ${hr_ulFdSchedData_targetBLER}    get_ulFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.targetBLER    filter_name3=${SA_UE_RNTI_ID}
#    ${contains_value1_or_value2}    Set Variable    ${True}    if    any(item in ['0.15', '0.2'] for item in ${hr_ulFdSchedData_targetBLER})
#    Should Be True    ${contains_value1_or_value2}
    FOR  ${i}    IN    @{hr_ulFdSchedData_targetBLER}
        should be equal      ${${i}}    ${${0.1}}
    END


Analysis wireshark for J003_4
    [Arguments]    ${logname}
    Log To Console    increase attenuation slowly to trigger ulHRBlerRecoverTbsThresh64qam>7000
    Start capture gNB log on master    filename=${log_name_J_003_4}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${32}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${20}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${20}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_003_4}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP No DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${f1ap_procedureCode}=     cap.Get Field Value By Xpath    xpath=.//f1ap.procedureCode    pcap_parser=test6
    should not contain    ${f1ap_procedureCode}    12
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_4    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_4    nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_4    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_4    nr_phy_cell_ids=59
    sleep    2s
    Analysis tti for J003_4    names=l2stream3_ttitrace_J003_4

Analysis tti for J003_4
    [Arguments]    ${names}
    log to console    analysis tti file for J003_4 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    BASICRELIABILITY
    END

Analysis wireshark for J003_5
    [Arguments]    ${logname}
    Log To Console    increase attenuation slowly to trigger ulHRBlerRecoverTbsThresh64qam>7000
    Start capture gNB log on master    filename=${log_name_J_003_5}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_003_5}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check transformPrecoder DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.transformPrecoder == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    Should Be Equal    ${nr_rrc_transformPrecoder[0]}    1
    Log To Console    check 5QI 7 no cqi-table1(64QAM) F1AP DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.cqi_Table ==0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.cqi_Table    pcap_parser=test6
    should not contain    ${nr_rrc_mcs_Table}    0
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_5    nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_5    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J003_5    nr_phy_cell_ids=59
    sleep    2s
    Analysis tti for J003_5    names=l2stream3_ttitrace_J003_5
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check Trunk counter for 8246_HR_J003_gNB1cell1

Analysis tti for J003_5
    [Arguments]    ${names}
    log to console    analysis tti file for J003_5 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    HIGHRELIABILITY
    END

Check Trunk counter for 8246_HR_J003_gNB1cell1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_J003_64QAM_HR_gNB1_cell1}    dic_path=${Trunk_counter_dic_path_J003_64QAM_HR_gNB1_cell1}
    Set suite variable    ${M55302C00029_64QAM_HR}                   ${counter_value_list}[0]
    Set suite variable    ${M55302C00030_64QAM_HR}                   ${counter_value_list}[1]
    Set suite variable    ${M55302C00031_64QAM_HR}                   ${counter_value_list}[2]
    Set suite variable    ${M55302C00032_64QAM_HR}                   ${counter_value_list}[3]
    ${J003_64QAM_HR_gap1}=    Evaluate    ${M55302C00029_64QAM_HR} + ${M55302C00031_64QAM_HR}- ${M55302C00030_64QAM_HR} - ${M55302C00032_64QAM_HR}
    ${J003_64QAM_HR_gap2}=    Evaluate    ${M55302C00029_64QAM_HR} + ${M55302C00031_64QAM_HR}
    ${J003_64QAM_HR_gap}=    Evaluate     ${J003_64QAM_HR_gap1}/${J003_64QAM_HR_gap2}
    Should Be True    ${J003_64QAM_HR_gap}<=0.01

Check counter for 8246_HR_J003_gNB1cell1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_J003_64QAM_HR_gNB1_cell1}    dic_path=${counter_dic_path_J003_64QAM_HR_gNB1_cell1}
    Set suite variable    ${M55302C00029_64QAM_HR}                   ${counter_value_list}[0]
    Set suite variable    ${M55302C00030_64QAM_HR}                   ${counter_value_list}[1]
    Set suite variable    ${M55302C00031_64QAM_HR}                   ${counter_value_list}[2]
    Set suite variable    ${M55302C00032_64QAM_HR}                   ${counter_value_list}[3]
    ${J003_64QAM_HR_gap1}=    Evaluate    ${M55302C00029_64QAM_HR} + ${M55302C00031_64QAM_HR}- ${M55302C00030_64QAM_HR} - ${M55302C00032_64QAM_HR}
    ${J003_64QAM_HR_gap2}=    Evaluate    ${M55302C00029_64QAM_HR} + ${M55302C00031_64QAM_HR}
    ${J003_64QAM_HR_gap}=    Evaluate     ${J003_64QAM_HR_gap1}/${J003_64QAM_HR_gap2}
    Should Be True    ${J003_64QAM_HR_gap}<=0.01

Get the all PM counter value
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        append to list    ${counter_value_list}    ${counter_value[0]}
    END
    [Return]    ${counter_value_list}

Check wireshark log for 8246_J_UE_RNTI_ID
    [Arguments]    ${logname}
    ${UE_RNTI_ID}=    Get RNTI-ID message    logname=${logname}
    Set Suite Variable    ${SA_UE_RNTI_ID}    ${UE_RNTI_ID}

Get RNTI-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialULRRCMessageTransfer, RRC Setup Request
    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    [Return]    ${UE_RNTI_ID}[-1]

#Get all X70 pointer variable
#    Set Suite Variable    ${home}    3
#    Set Suite Variable    ${airplane}    953 1385
#    Set Suite Variable    ${close_task}    523 272
#    Set Suite Variable    ${Home_button}    3
#    Set Suite Variable    ${swipe}    500 2050 500 800
#    Set Suite Variable    ${open_iperf_location}    480 860
#    Set Suite Variable    ${iperf_button}    720 312
#    Set Suite Variable    ${iperf_space}    800 550
#    Set Suite Variable    ${brand}    qti

choice required APN on QCOM UE
    [Arguments]    ${usedapn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Get all X70 pointer variable
    set Qcom apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
    make airplane mode to enable    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    csn.disconnect    connection=cygwin

set Qcom apn to wap2
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    sleep   2s
    ####1.APN setting
    ####1.1 setting
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings/com.android.settings.Settings$ApnSettingsActivity
    ...    connection=cygwin
    ####1.2 Network&internet
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 447 938    connection=cygwin
    sleep   2s
    ####1.3 SIMs
    csn.send_command    command=adb -s ${serial_number} shell input tap 323 1205    connection=cygwin
    sleep   2s
    ####1.4 T-Mobile
    csn.send_command    command=adb -s ${serial_number} shell input tap 337 736    connection=cygwin
    sleep   2s
    ####1.5 swipe Access Point Names
    FOR  ${i}    IN RANGE    ${4}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin
        sleep    1s
    END
    ####1.6 click Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap 486 1604    connection=cygwin
    sleep   2s
    ####1.6 switch Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   2s
    [Teardown]    csn.disconnect    connection=cygwin

Stop and download Logs all log
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_002_1}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_002_2}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_002_3}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_002_4}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_002_5}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_002_6}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_002_7}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_002_8}
        Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_J_002_9}

Analysis wireshark for J002_1
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.uplinkBWP_ToAddModList == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[0]}    0
    Log To Console    check F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.cqi_Table == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_cqi_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.cqi_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_cqi_Table[0]}    1
    Log To Console    check F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.mcs_Table == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index1}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index1    pcap_parser=test6
    Should Be Equal    ${nr_rrc_betaOffsetACK_Index1[0]}    11
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.mcs_Table == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index2}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index2    pcap_parser=test6
    Should Be Equal    ${nr_rrc_betaOffsetACK_Index2[0]}    8
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.mcs_Table == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index3}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index3    pcap_parser=test6
    Should Be Equal    ${nr_rrc_betaOffsetACK_Index3[0]}    6

Analysis wireshark for J002_2
    [Arguments]    ${logname}
    Log To Console    Increase attenuation slowly to trigger UE in SINR<10db and  UE TBS < 8000bits
    Start capture gNB log on master    filename=${log_name_J_002_2}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${30}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${35}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${35}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_002_2}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.transformPrecoder == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    Should Be Equal    ${nr_rrc_transformPrecoder[0]}    0
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.uplinkBWP_ToAddModList == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    should not contain    ${nr_rrc_mcs_Table}    0

Analysis wireshark for J002_3
    [Arguments]    ${logname}
    Log To Console     trigger PDU session resource setup procedure with 5QI-8 associated with NRPDSCHHRLA and NRPUSCHHRLA
    Start capture gNB log on master    filename=${log_name_J_002_3}
    sleep    3s
    add or delete 5QI via npc dynamic rule     imsi=${imsi3}    rule=${add5QI8rule}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_002_3}
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_3    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J002_3    nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J002_3    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J002_3    nr_phy_cell_ids=59
    sleep    10s
    Analysis tti for J002_3    names=l2stream3_ttitrace_J002_3
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session modify command
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.mcs_Table == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[0]}    1
    ${filter_expression}=     Catenate    (ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.fiveQI == 8)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    8
    ${filter_expression}=     Catenate    (ngap.NGAP_PDU == 1 and ngap.procedureCode == 26)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_NGAP_PDU}=     cap.Get Field Value By Xpath    xpath=.//ngap.NGAP_PDU    pcap_parser=test6
    Should Be Equal    ${ngap_NGAP_PDU[0]}    1

Analysis wireshark for J002_4
    [Arguments]    ${logname}
    Log To Console    Decrease attenuation slowly to trigger UE in UL ULTBS >10000btis
    Start capture gNB log on master    filename=${log_name_J_002_4}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${13}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${13}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${13}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_002_4}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP No DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${f1ap_procedureCode}=     cap.Get Field Value By Xpath    xpath=.//f1ap.procedureCode    pcap_parser=test6
    should not contain    ${f1ap_procedureCode}    12


Analysis wireshark for J002_5
    [Arguments]    ${logname}
    Log To Console    then continue to increase attenuation to trigger UE SINR > 20db
    Start capture gNB log on master    filename=${log_name_J_002_5}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_002_5}
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J002_5     nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J002_5     nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J002_5     nr_phy_cell_ids=59
    sleep    10s
    Analysis tti for J002_5    names=l2stream3_ttitrace_J002_5
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.mcs_Table == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[0]}    1

Analysis wireshark for J002_6
    [Arguments]    ${logname}
    Log To Console    Increase attenuation slowly to trigger UE in SINR<10db
    Start capture gNB log on master    filename=${log_name_J_002_6}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${18}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${18}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${18}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_002_6}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP No DLRRCMessageTransfer RRC Reconfiguration
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${f1ap_procedureCode}=     cap.Get Field Value By Xpath    xpath=.//f1ap.procedureCode    pcap_parser=test6
    should not contain    ${f1ap_procedureCode}    12

Analysis wireshark for J002_7
    [Arguments]    ${logname}
    Log To Console    continue to increase attenuation to trigger UE TBS < 8000bits
    Start capture gNB log on master    filename=${log_name_J_002_7}
    sleep    3s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${40}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${30}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${30}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_002_7}
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_7    nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J002_7     nr_phy_cell_ids=55
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J002_7     nr_phy_cell_ids=51
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_J002_7     nr_phy_cell_ids=59
    sleep    10s
    Analysis tti for J002_7    names=l2stream3_ttitrace_J002_7
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.transformPrecoder == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    Should Be Equal    ${nr_rrc_transformPrecoder[0]}    0

Analysis wireshark for J002_8
    [Arguments]    ${logname}
    Log To Console    release 5QI-8 associated with NRPDSCHHRLA and NRPUSCHHRLA
    Start capture gNB log on master    filename=${log_name_J_002_8}
    sleep    5s
    add or delete 5QI via npc dynamic rule     imsi=${imsi3}    rule=${dele5QI8rule}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_002_8}
    Log To Console     get osFlowIdentifier_packets-ID
    ${qosFlowIdentifier_ID}=    Get qosFlowIdentifier_packets-ID message    logname=${log_name_J_002_3}
    Set Suite Variable    ${qosFlowIdentifier_ue_id}    ${qosFlowIdentifier_ID}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.qosFlowIdentifier == ${qosFlowIdentifier_ue_id})
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0

Analysis wireshark for J002_9
    [Arguments]    ${logname}
    Log To Console    Decrease attenuation slowly to trigger UE in TBS >10000db, and then continue to increase attenuation to trigger UE SINR > 20db
    Start capture gNB log on master    filename=${log_name_J_002_9}
    sleep    5s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_J_002_9}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.mcs_Table == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[0]}    0
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.transformPrecoder == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    Should Be Equal    ${nr_rrc_transformPrecoder[0]}    1

Get qosFlowIdentifier_packets-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####PDU session ResourceModifyRequest,DL NAS transport,PDU session modification command
    ${qosFlowIdentifier}=     Catenate    (ngap.NGAP_PDU == 0 and ngap.procedureCode == 26)
    ${qosFlowIdentifier_packets}=    cap.filter_packets_by_expression    filter_expression=${qosFlowIdentifier}    pcap_parser=test6
    ${ngap_qosFlowIdentifier_ID}=     cap.get_field_value_by_xpath    pdml_list=${qosFlowIdentifier_packets}
    ...                                                xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6
    [Return]    ${ngap_qosFlowIdentifier_ID}[0]

Analysis tti for J002_3
    [Arguments]    ${names}
    log to console    Analysis UL tti for J002_3 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    BASICRELIABILITY
    END
Analysis tti for J002_5
    [Arguments]    ${names}
    log to console    Analysis UL tti for J002_5 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    HIGHRELIABILITY
    END
Analysis tti for J002_7
    [Arguments]    ${names}
    log to console    Analysis UL tti for J002_7 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    BASICRELIABILITY
    END

check if HR swtich to BR success
    [Arguments]    ${para_index}=${2}
    ${dict_HR_to_BR_check}=    get dict kpi from pm file   KPI_file=CB008246_E_006_KPI_HR_to_BR_check.txt    para_index=${para_index}
    # PUSCH_INITX_LOWSE_BRDRB>0 and PUSCH_INITX_LOWSE_HRD_PRFL1+PUSCH_INITX_LOWSE_HRD_PRFL2=0 check swtich to BR
    ${status_0}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_HRD_PRFL1] + ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_HRD_PRFL2]
    Should Be Equal    ${status_0}    ${0}
    ${status_1}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_BRDRB]>0
    Should Be Equal    ${status_1}    ${True}

check if BR swtich to HR success
    [Arguments]    ${para_index}=${2}
    ${dict_HR_to_BR_check}=    get dict kpi from pm file   KPI_file=CB008246_E_006_KPI_BR_to_HR_check.txt    para_index=${para_index}
    # PUSCH_INITX_LOWSE_BRDRB=0 and PUSCH_INITX_LOWSE_HRD_PRFL1+PUSCH_INITX_LOWSE_HRD_PRFL2>0 check swtich to HR
    ${status_0}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_HRD_PRFL1] + ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_HRD_PRFL2]
    Should Be True    ${status_0}>${0}
    ${status_1}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_BRDRB] == ${0}
    Should Be Equal    ${status_1}    ${True}

check KPI on pm file
    get kpi from per pm file

check HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_less_specified_value2}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${1000}
    ${result_0}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${E_006_HR_value_1}]+${dict_kpis_name_value}[${E_006_HR_value_2}]-${dict_kpis_name_value}[${E_006_HR_value_0}])
    Should Be True    ${result_0}<=${2}
#    Should Be Equal    ${result_0}    ${dict_kpis_name_value}[${E_006_HR_value_0}]
    ${result_1}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${E_006_HR_value_4}]+${dict_kpis_name_value}[${E_006_HR_value_5}]-${dict_kpis_name_value}[${E_006_HR_value_3}])
    Should Be True    ${result_1}<=${2}
#    Should Be Equal    ${result_1}    ${dict_kpis_name_value}[${E_006_HR_value_3}]
    ${result_2_1}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_6}]-${dict_kpis_name_value}[${E_006_HR_value_7}]
    ${result_2_2}=    Evaluate    ${result_2_1}-${dict_kpis_name_value}[${E_006_HR_value_8}]
    Should Be True    ${-50}<${result_2_2}<${50}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_9}]+${dict_kpis_name_value}[${E_006_HR_value_10}]
    Should Be True    ${result_3}>${0}
    ${result_4}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_11}]+${dict_kpis_name_value}[${E_006_HR_value_12}]
    Should Be True    ${result_4}>${0}
    ${result_5}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_13}]+${dict_kpis_name_value}[${E_006_HR_value_14}]
    Should Be True    ${result_5}>${0}

check BR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_BR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_BR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_BR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.11}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_BR_traffic_check_kpi_names_less_specified_value2}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${1000}
    ${result_0}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${E_006_BR_value_1}]+${dict_kpis_name_value}[${E_006_BR_value_2}]-${dict_kpis_name_value}[${E_006_BR_value_0}])
#    Should Be Equal    ${result_0}    ${dict_kpis_name_value}[${E_006_BR_value_0}]
    Should Be True    ${result_0}<=${2}
    ${result_1}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${E_006_BR_value_5}]+${dict_kpis_name_value}[${E_006_BR_value_3}]-${dict_kpis_name_value}[${E_006_BR_value_4}])
    Should Be True    ${result_1}<=${2}
#    Should Be Equal    ${result_1}    ${dict_kpis_name_value}[${E_006_BR_value_5}]
    ${result_2}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_6}]+${dict_kpis_name_value}[${E_006_HR_value_7}]
    Should Be True    ${result_2}>${0}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_8}]+${dict_kpis_name_value}[${E_006_HR_value_9}]
    Should Be True    ${result_3}>${0}
    ${result_4}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_10}]+${dict_kpis_name_value}[${E_006_HR_value_11}]
    Should Be True    ${result_4}>${0}

check KPI
    check KPI with required name    KPI_name_list=${CB008246_E_006_kpi_names_in_range}    check_field=in_range
    check KPI with required name    KPI_name_list=${CB008246_E_006_kpi_names_value_zero}    check_field=zero
    check KPI with required name    KPI_name_list=${CB008246_E_006_kpi_names_larger_zero}    check_field=larger_zero
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_1}
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_2}
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_3}
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_4}


Check UL_UE_MCS_table_Capbility
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

COAM Save snapshot
    get gnb snapshot    gnb_index=${0}
    get gnb snapshot    gnb_index=${1}

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Adjust HBTE gNB_eNB_RU Attenuation
    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
    Adjust the tl HBTE attenuation value    #tl=@{diffTL_enb_ID}[0]
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}

Adjust the tl HBTE attenuation value
    [Arguments]     ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${enb_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_HBTE}     ${att_port_2_HBTE}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_3_HBTE}     ${att_port_4_HBTE}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_HBTE}     ${att_port_6_HBTE}
    @{att_ports_enb_cell1}     Create List    ${att_port_7_HBTE}     ${att_port_8_HBTE}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_enb_cell1}     Create List    ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
