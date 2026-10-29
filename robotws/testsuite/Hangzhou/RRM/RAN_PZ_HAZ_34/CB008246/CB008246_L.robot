*** Settings ***
Documentation
...    author: Zhang Yayun
...    contact: yayun.zhang@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-L

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get gnb release info
...                            AND    Common UE parameter setup

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_L_005_1}    log_name_L_005_1.pcap
${log_name_L_006_1}    log_name_L_006_1.pcap
${log_name_L_006_2}    log_name_L_006_2.pcap
${log_name_L_010_1}    log_name_L_010_1.pcap
${expected_tput_dl}    168
${expected_tput_dl_small}    1
${expected_tput_dl_L006}    25
${Send_Tput_DL_L006}        30M
${Send_Tput_DL}        600M
${Send_Tput_DL_small}        60M
${expected_tput_ul}    1
${expected_tput_ul_X70}    80
${expected_tput_ul_X70_small}    1
${Send_Tput_UL}        200M
${Send_Tput_UL_small}        20M
${Send_Tput_UL_L006}        10M
${expected_tput_ul_L006}    1
${Send_Tput_DL_L005}        1k
${Send_Tput_UL_L005}        1k
${expected_tput_dl_L005}    0
${expected_tput_ul_L005}    0
${Send_Tput_UL_L010}        10M
${expected_tput_ul_L010}    9
${zzmdrb2_apn_name}    ${tl.ues[0].pdn[5]}
${wap2_apn_name}    ${tl.ues[0].pdn[0]}
${X70_wap2apn_location}    959 1370
${X70_mdrb2apn_location}    959 1576
${ui_version}    emui 10.1.0
${zmdrb2_apn_name}    ${tl.ues[0].pdn[6]}
@{gnb1_cell2_pa_ports}    ${att_port_3_HBTE}    ${att_port_4_HBTE}
@{gnb1_cell2_pa_origin_values}    ${0}    ${0}
@{gnb1_cell2_pa_target_values}    ${50}    ${50}

${l2stream3_ttitrace_CNI126636_DL_part}    l2stream3_ttitrace_CNI126636_DL_part
${l2stream3_ttitrace_CNI126636_UL_part}    l2stream3_ttitrace_CNI126636_UL_part
${l2stream3_ttitrace_CNI131244_DL_part}    l2stream3_ttitrace_CNI131244_DL_part
${l2stream3_ttitrace_CNI131244_UL_part}    l2stream3_ttitrace_CNI131244_UL_part

*** Test Cases ***
[1]CB008246-L_005_high_reliability_feature_interworking_with_Power_Saving_UE
    [Documentation]    CB008246-L
    [Tags]    CB008246-L    CRT_TRUNK
    [Timeout]    4 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=62003,62001
    AlarmWatchdog.add_allow_alarms    fault_id=62003
    AlarmWatchdog.add_allow_alarms    fault_id=62001
    Get sagnb version for selenium
    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
#    Common Case TestLine Setup    ModifySCF_Beforecommission=True
#    ...    golden_scf_name=${tl_scf_${release_info}}     scf_path=${scf_path}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_L005}
#    ...    ParamterToModify=${PARAM_8246_gnb1_L_005}    ListToAdd=${LIST_TO_ADD_GNB1_L005}    ListParamterToModify=${LIST_TO_MODIFY_GNB1_L005}
#    ...    is_pdl_checking_needed=${False}
    Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...    golden_scf_name=${tl_gnb1_scf_${sw_version}}     scf_path=${scf_path}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_L005}
    ...    ParamterToModify=${PARAM_8246_gnb1_L_005}    ListToAdd=${LIST_TO_ADD_GNB1_L005}    ListParamterToModify=${LIST_TO_MODIFY_GNB1_L005}
    ...    is_pdl_checking_needed=${True}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Comment    UE3 attach on gnb1 cell1
    Start capture gNB log on master    filename=${log_name_L_005_1}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    Sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_L_005_1}
    Check wireshark log for 8246_L_UE_RNTI_ID    logname=${log_name_L_005_1}
    Comment    traffic DL 600M+UL 200M
    Check wap2 5QI7 traffic DL 600M+UL 200M 8246_HR_L005_counter
    Comment    traffic DL 1kb+UL 1kb
    Check wap2 5QI7 traffic DL 1kb+UL 1kb 8246_HR_L005_counter
    Comment    traffic DL 600M+UL 200M
    Check wap2 5QI7 traffic DL 600M+UL 200M 8246_HR_L005_counter
#    Run Keyword If    '${release_info}' == 'SBTS24R3_ENB_0000'
#    ...    Run Keyword And Continue On Failure    CNI126636 steps executed DL part
#    ...    ELSE IF    '${release_info}' == 'SBTS25R1_ENB_0000' or '${release_info}' == 'SBTS25R2_ENB_9999'
#    ...    Run Keyword And Continue On Failure    CNI131244 Steps Executed DL Part
#    Run Keyword If    '${release_info}' == 'SBTS24R3_ENB_0000'
#    ...    Run Keyword And Continue On Failure    CNI126636 steps executed UL part
#    ...    ELSE IF    '${release_info}' == 'SBTS25R1_ENB_0000' or '${release_info}' == 'SBTS25R2_ENB_9999'
#    ...    Run Keyword And Continue On Failure    CNI131244 Steps Executed UL Part
#    ${result}=    check_gnb_release_for_counter_path    release_info=${release_info}    release_year_diff=${24}    release_num_diff=${3}
#    IF    '${result}' == 'False'
    IF    ${sw_version}[-4:-2] < 25
        Run Keyword And Continue On Failure    CNI126636 steps executed DL part
        Run Keyword And Continue On Failure    CNI126636 steps executed UL part
#    ELSE IF    '${result}' == 'True'
    ELSE
        Run Keyword And Continue On Failure    CNI131244 Steps Executed DL Part
        Run Keyword And Continue On Failure    CNI131244 Steps Executed UL Part
    END
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=62003
    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=62001
    ...    AND    Start capture syslog via btslog on ute
    ...    AND    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    ...    AND    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
    ...    AND    UE.UE Detach     ue_type=${ue_type}     ue_index=${2}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_L_005_1}
    ...    AND    Adjust HBTE gNB_eNB_RU Attenuation
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
    ...    AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}
    ...    AND    get and analysis syslog
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


#[1]CB008246-L_006_high_reliability_feature_interworking_with_CB008698_ARP-based_pre-emption
#    [Documentation]    CB008246-L
#    [Tags]    CB008246-L   CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
##    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
##    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_L_006}
##    ...    Delete_Para_Online=${PARAM_8246_delete_gnb1_L_006}
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]' and '${release_info}' == '${branch}[2]'
#    ...    Common Case TestLine Setup    ModifySCF_Beforecommission=True
#    ...    golden_scf_name=${tl_scf_${release_info}}     scf_path=${scf_path}    ParameterToDelete=${Trunk_PARAMETERS_TO_DELETE_GNB1_L006}
#    ...    ParamterToModify=${Trunk_PARAM_8246_gnb1_L_006}    ListToAdd=${Trunk_LIST_TO_ADD_GNB1_L006}
#    ...    ListParamterToModify=${Trunk_LIST_TO_MODIFY_GNB1_L006}
#    ...    ELSE    Common Case TestLine Setup    ModifySCF_Beforecommission=True
#    ...    golden_scf_name=${tl_scf_${release_info}}     scf_path=${scf_path}    ParameterToDelete=${PARAM_8246_delete_gnb1_L_006}
#    ...    ParamterToModify=${PARAM_8246_gnb1_L_006}    ListParamterToModify=${LIST_TO_MODIFY_GNB1_L006}
#    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_L_006_online}
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    Comment    change UE1 APN to mdrb2.nokia.com
#    power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${0}
#    Switch APN to muti DRB    ue_index=${0}    ue_type=${ue_type1}    apn_name=${zzmdrb2_apn_name}    ui_version=${ui_version}
#    Comment    change UE3 APN to mdrb2.nokia.com
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
#    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${zmdrb2_apn_name}
#    Comment    UE1 attach on gnb1 cell2
#    Start capture gNB log on master    filename=${log_name_L_006_1}
#    Power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${0}
#    Attach and check power UE    ue_type=${ue_type1}    ue_index=${0}    gnb_index=${0}
#    Sleep    10s
#    Stop and download Logs on gNB on master    filename=${log_name_L_006_1}
#    Comment    5QI3 DL+UL trafic
#    Start only DL traffic and check tput    ue_index=${0}    cellid=2    ue_type=${ue_type1}    gnb_index=${0}
#    ...                                tput_dl_cell=${expected_tput_dl_L006}    dl_throughput=${Send_Tput_DL_L006}    duration=7200
#    ...                                dl_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
#    Start only UL traffic and check tput    ue_index=${0}    cellid=${2}    ue_type=${tl.ues[0].capabilities[2]}    gnb_index=${0}
#    ...                                tput_ul_cell=${expected_tput_ul_L006}    ul_throughput=${Send_Tput_UL_L006}    duration=${7200}
#    ...                                ul_port=${tl.ues[0].iperf_details.ssh_connection_details.port}    iperf_type=via_app
#    sleep    5s
#    Start capture gNB log on master    filename=${log_name_L_006_2}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
#    sleep    15s
#    Stop and download Logs on gNB on master    filename=${log_name_L_006_2}
#    Analysis wireshark for L006    logname=${log_name_L_006_2}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=DL
#    ...    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
#    ...    AND    Stop DL or UL traffic    ue_index=${0}    ue_type=${tl.ues[0].capabilities[2]}    direction=UL
#    ...    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
#    ...    AND    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}
#    ...    AND    CB008246_common_keywords.Android UE SwitchApn    ue_index=${0}    apn_name=${wap2_apn_name}    ui_version=${ui_version}
#    ...    AND    power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${0}
#    ...    AND    UE.UE Detach     ue_type=${ue_type1}     ue_index=${0}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_L_006_1}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_L_006_2}
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_recover_gnb1_L_006}
#    ...    Delete_Para_Online=${PARAM_8246_recover_delete_gnb1_L_006}
#    ...    AND    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


#[1]CB008246-L_010_high_reliability_feature_interworking_with_Adaptive_UL_BLER_for_Spectral_Efficiency_Improvement_SA_TDD
#    [Documentation]    CB008246-L
#    [Tags]    CB008246-L   CRT_TRUNK
#    [Timeout]    1 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False
#    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_L_010}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    Comment    UE3 attach on gnb1 cell1
#    Start capture gNB log on master    filename=${log_name_L_010_1}
#    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
#    Stop and download Logs on gNB on master    filename=${log_name_L_010_1}
#    Check wireshark log for 8246_L_UE_RNTI_ID    logname=${log_name_L_010_1}
#    Comment    traffic UL 10M
#    Check wap2 5QI7 traffic UL 10M 8246_HR_L010
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL    AND
#    ...    UE.UE Detach     ue_type=${ue_type}     ue_index=${2}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_L_010_1}    AND
##    ...   Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot    AND
#    ...    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_recover_gnb1_L_010}    AND
#    ...    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell1_value=${120}    gnb1_cell2_value=${120}    gnb2_cell1_value=${120}    enb_cell1_value=${120}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

*** Keywords ***
Check wireshark log for 8246_L_UE_RNTI_ID
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
    [Return]    ${UE_RNTI_ID}[0]

Analysis tti for L010_1
    [Arguments]    ${names}
    log to console    analysis Analysis tti for L010_1 from Case_Logs file...
    ${col_hr_BLER}    ${col_hr_SINR}    get_HR_BLER_SINR_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=ulFdSchedData.laMode  filter_name2=ulFdSchedData.targetBLER
    ...    filter_name3=ulFdSchedData.ueData.reScaledCorrAvgSinrAtb    filter_name4=${SA_UE_RNTI_ID}    filter_name5=rnti
    FOR  ${i}    IN    @{col_hr_BLER}
        should be equal      ${${i}}    ${${0.01}}
    END
    FOR  ${i}    IN    @{col_hr_SINR}
        should be true      ${${i}}<${${10.0}}
    END

Analysis tti for L010_2
    [Arguments]    ${names}
    log to console    analysis Analysis tti for L010_2 from Case_Logs file...
    ${col_br_BLER}    ${col_br_SINR}    get_BR_BLER_SINR_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=ulFdSchedData.laMode  filter_name2=ulFdSchedData.targetBLER
    ...    filter_name3=ulFdSchedData.ueData.reScaledCorrAvgSinrAtb    filter_name4=${SA_UE_RNTI_ID}    filter_name5=rnti
    FOR  ${i}    IN    @{col_br_BLER}
        should be equal      ${${i}}    ${${0.2}}
    END
    FOR  ${i}    IN    @{col_br_SINR}
        should be true      ${${i}}<=${${10.0}}
    END

Analysis tti for L010_3
    [Arguments]    ${names}
    log to console    analysis Analysis tti for L010_3 from Case_Logs file...
    ${col_br_BLER}    ${col_br_MCS}    get_BR_BLER_MCS_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=ulFdSchedData.laMode  filter_name2=ulFdSchedData.targetBLER
    ...    filter_name3=ulFdSchedData.isDefaultMcsProposed    filter_name4=${SA_UE_RNTI_ID}    filter_name5=rnti
#    FOR  ${i}    IN    @{col_br_BLER}
#        should contain       ${${i}}    ${${0.15}}
#    END
    should contain       ${col_br_BLER}    0.15
    FOR  ${i}    IN    @{col_br_MCS}
        should be equal      ${${i}}    ${${0.0}}
    END

Check wap2 5QI7 traffic UL 10M 8246_HR_L010
    sleep    5s
    Start only UL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul_L010}    ul_throughput=${Send_Tput_UL_L010}    duration=${7200}
    sleep    10s
    Log to console     gnb1 cell1 PA to 25db to trigger HR+Bler=1%+SINR<10
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${25}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    sleep    10s
    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_1    nr_phy_cell_ids=51
    sleep    10s
    Analysis tti for L010_1    names=l2stream3_ttitrace_1
    Log to console     gnb1 cell1 PA to 35db to trigger BR+Bler=20%+SINR<=10
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${35}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    sleep    10s
    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_2    nr_phy_cell_ids=51
    sleep    10s
    Analysis tti for L010_2    names=l2stream3_ttitrace_2
    Log to console     gnb1 cell1 PA to 43db to trigger BR+Bler include 15%+isDefaultMcsProposed(MCS)<=10
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${41}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    sleep    10s
    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_3    nr_phy_cell_ids=51
    sleep    10s
    Analysis tti for L010_3    names=l2stream3_ttitrace_3

Check wap2 5QI7 traffic DL 600M+UL 200M 8246_HR_L005_counter
    sleep    10s
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul_X70}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check trunk counter for 8246_HR_L005_1_gNB1cell2_BWP1
    [Teardown]     Run Keywords
    ...    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL    AND
    ...    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL

Check wap2 5QI7 traffic DL 1kb+UL 1kb 8246_HR_L005_counter
    sleep    10s
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl_L005}    dl_throughput=${Send_Tput_DL_L005}    duration=${7200}
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul_L005}    ul_throughput=${Send_Tput_UL_L005}    duration=${7200}
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check trunk counter for 8246_HR_L005_1_gNB1cell2_BWP2_PowerSaving

    [Teardown]     Run Keywords
    ...    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL    AND
    ...    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL

Check trunk counter for 8246_HR_L005_1_gNB1cell2_BWP1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_L005_HR_gNB1_cell2}    dic_path=${Trunk_counter_dic_path_L005_HR_gNB1_cell2}
    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55367C00001_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55367C00002_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55365C03007_DL_GRANT_HR_AL2_CBWP1}       ${counter_value_list}[4]
    Set suite variable    ${M55365C03008_DL_GRANT_HR_AL4_CBWP1}       ${counter_value_list}[5]
    Set suite variable    ${M55365C03002_UL_GRANT_HR_AL2_CBWP1}       ${counter_value_list}[6]
    Set suite variable    ${M55365C03003_UL_GRANT_HR_AL4_CBWP1}       ${counter_value_list}[7]
    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
    Should Be True    ${M55366C00001_02_gap}<=0.011
    ${M55367C00001_02_gap}=    Evaluate    (${M55367C00001_LOWSE_HRD} - ${M55367C00002_LOWSE_HRD})/${M55367C00001_LOWSE_HRD}
    Should Be True    ${M55367C00001_02_gap}<=0.011
    ${DL_GRANT_HR_AL2_AL4_CBWP1_gap}=    Evaluate    (${M55365C03007_DL_GRANT_HR_AL2_CBWP1} + ${M55365C03008_DL_GRANT_HR_AL4_CBWP1})
    Should Be True    ${DL_GRANT_HR_AL2_AL4_CBWP1_gap} >0
    ${UL_GRANT_HR_AL2_AL4_CBWP1_gap}=    Evaluate    (${M55365C03002_UL_GRANT_HR_AL2_CBWP1} + ${M55365C03003_UL_GRANT_HR_AL4_CBWP1})
    Should Be True    ${UL_GRANT_HR_AL2_AL4_CBWP1_gap} >0

Check counter for 8246_HR_L005_1_gNB1cell2_BWP1
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_L005_HR_gNB1_cell2}    dic_path=${counter_dic_path_L005_HR_gNB1_cell2}
    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55367C00001_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55367C00002_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55365C03007_DL_GRANT_HR_AL2_CBWP1}       ${counter_value_list}[4]
    Set suite variable    ${M55365C03008_DL_GRANT_HR_AL4_CBWP1}       ${counter_value_list}[5]
    Set suite variable    ${M55365C03002_UL_GRANT_HR_AL2_CBWP1}       ${counter_value_list}[6]
    Set suite variable    ${M55365C03003_UL_GRANT_HR_AL4_CBWP1}       ${counter_value_list}[7]
    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
    Should Be True    ${M55366C00001_02_gap}<=0.011
    ${M55367C00001_02_gap}=    Evaluate    (${M55367C00001_LOWSE_HRD} - ${M55367C00002_LOWSE_HRD})/${M55367C00001_LOWSE_HRD}
    Should Be True    ${M55367C00001_02_gap}<=0.011
    ${DL_GRANT_HR_AL2_AL4_CBWP1_gap}=    Evaluate    (${M55365C03007_DL_GRANT_HR_AL2_CBWP1} + ${M55365C03008_DL_GRANT_HR_AL4_CBWP1})
    Should Be True    ${DL_GRANT_HR_AL2_AL4_CBWP1_gap} >0
    ${UL_GRANT_HR_AL2_AL4_CBWP1_gap}=    Evaluate    (${M55365C03002_UL_GRANT_HR_AL2_CBWP1} + ${M55365C03003_UL_GRANT_HR_AL4_CBWP1})
    Should Be True    ${UL_GRANT_HR_AL2_AL4_CBWP1_gap} >0

Check trunk counter for 8246_HR_L005_1_gNB1cell2_BWP2_PowerSaving
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_L005_HR_gNB1_cell2}    dic_path=${Trunk_counter_dic_path_L005_HR_gNB1_cell2}
#    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
#    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
#    Set suite variable    ${M55367C00001_LOWSE_HRD}                   ${counter_value_list}[2]
#    Set suite variable    ${M55367C00002_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55365C06007_DL_GRANT_HR_AL2_CBWP2}       ${counter_value_list}[4]
    Set suite variable    ${M55365C06008_DL_GRANT_HR_AL4_CBWP2}       ${counter_value_list}[5]
    Set suite variable    ${M55365C06002_UL_GRANT_HR_AL2_CBWP2}       ${counter_value_list}[6]
    Set suite variable    ${M55365C06003_UL_GRANT_HR_AL4_CBWP2}       ${counter_value_list}[7]
    Comment    according to Precheck [CLOSED][L][L010]HR bler is about 0.45 with IWK_PS the Bler not need to check
#    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
#    Should Be True    ${M55366C00001_02_gap}<=0.011
#    ${M55367C00001_02_gap}=    Evaluate    (${M55367C00001_LOWSE_HRD} - ${M55367C00002_LOWSE_HRD})/${M55367C00001_LOWSE_HRD}
#    Should Be True    ${M55367C00001_02_gap}<=0.011
    ${DL_GRANT_HR_AL2_AL4_CBWP2_gap}=    Evaluate    (${M55365C06007_DL_GRANT_HR_AL2_CBWP2} + ${M55365C06008_DL_GRANT_HR_AL4_CBWP2})
    Should Be True    ${DL_GRANT_HR_AL2_AL4_CBWP2_gap} >0
    ${UL_GRANT_HR_AL2_AL4_CBWP2_gap}=    Evaluate    (${M55365C06002_UL_GRANT_HR_AL2_CBWP2} + ${M55365C06003_UL_GRANT_HR_AL4_CBWP2})
    Should Be True    ${UL_GRANT_HR_AL2_AL4_CBWP2_gap} >0

Check counter for 8246_HR_L005_1_gNB1cell2_BWP2_PowerSaving
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_L005_HR_gNB1_cell2}    dic_path=${counter_dic_path_L005_HR_gNB1_cell2}
#    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
#    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
#    Set suite variable    ${M55367C00001_LOWSE_HRD}                   ${counter_value_list}[2]
#    Set suite variable    ${M55367C00002_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55365C06007_DL_GRANT_HR_AL2_CBWP2}       ${counter_value_list}[4]
    Set suite variable    ${M55365C06008_DL_GRANT_HR_AL4_CBWP2}       ${counter_value_list}[5]
    Set suite variable    ${M55365C06002_UL_GRANT_HR_AL2_CBWP2}       ${counter_value_list}[6]
    Set suite variable    ${M55365C06003_UL_GRANT_HR_AL4_CBWP2}       ${counter_value_list}[7]
    Comment    according to Precheck [CLOSED][L][L010]HR bler is about 0.45 with IWK_PS the Bler not need to check
#    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
#    Should Be True    ${M55366C00001_02_gap}<=0.011
#    ${M55367C00001_02_gap}=    Evaluate    (${M55367C00001_LOWSE_HRD} - ${M55367C00002_LOWSE_HRD})/${M55367C00001_LOWSE_HRD}
#    Should Be True    ${M55367C00001_02_gap}<=0.011
    ${DL_GRANT_HR_AL2_AL4_CBWP2_gap}=    Evaluate    (${M55365C06007_DL_GRANT_HR_AL2_CBWP2} + ${M55365C06008_DL_GRANT_HR_AL4_CBWP2})
    Should Be True    ${DL_GRANT_HR_AL2_AL4_CBWP2_gap} >0
    ${UL_GRANT_HR_AL2_AL4_CBWP2_gap}=    Evaluate    (${M55365C06002_UL_GRANT_HR_AL2_CBWP2} + ${M55365C06003_UL_GRANT_HR_AL4_CBWP2})
    Should Be True    ${UL_GRANT_HR_AL2_AL4_CBWP2_gap} >0

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

Analysis wireshark for L006
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and nr-rrc.downlinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[0]}    1
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and nr-rrc.betaOffsetACK_Index1 == 9)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index1}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index1    pcap_parser=test6
    Should Be Equal    ${nr_rrc_betaOffsetACK_Index1[0]}    9
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and nr-rrc.betaOffsetACK_Index2 == 6)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index2}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index2    pcap_parser=test6
    Should Be Equal    ${nr_rrc_betaOffsetACK_Index2[0]}    6
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and nr-rrc.betaOffsetACK_Index3 == 3)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetACK_Index3}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetACK_Index3    pcap_parser=test6
    Should Be Equal    ${nr_rrc_betaOffsetACK_Index3[0]}    3
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and nr-rrc.betaOffsetCSI_Part1_Index1 == 11)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetCSI_Part1_Index1}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1    pcap_parser=test6
    Should Be Equal    ${nr_rrc_betaOffsetCSI_Part1_Index1[0]}    11
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and nr-rrc.betaOffsetCSI_Part1_Index2 == 6)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_betaOffsetCSI_Part1_Index2}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2    pcap_parser=test6
    Should Be Equal    ${nr_rrc_betaOffsetCSI_Part1_Index2[0]}    6
    Log To Console    check F1AP UEContextReleaseCommand,RRC Release
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 6 and f1ap.radioNetwork == 16)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${f1ap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${f1ap_radioNetwork[0]}    16
    Log To Console    check NGAP SACK(ACK=4,Arwnd=2097152)UEContextReleaseRequest
    ${filter_expression}=     Catenate    (ngap.procedureCode == 42 and ngap.radioNetwork == 46)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    46
    Log To Console     get RAN-UE-NGAP-ID
    ${UE_NGAP_ID}=    Get RAN-UE-NGAP-ID message    logname=${logname}
    Set Suite Variable    ${preemption_ue_id}    ${UE_NGAP_ID}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    Log To Console    check PDU sessionResourceSetupRequest,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    ...    and ngap.procedureCode == 29 and ngap.QosFlowSetupRequestList == 2 and ngap.qosFlowIdentifier)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_request_qosFlowIdentifier}=     cap.Get Field Value By Xpath    xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6
    Set Suite Variable    ${ngap_request_qosFlowIdentifier_id}    ${ngap_request_qosFlowIdentifier}
    Sort List    ${ngap_request_qosFlowIdentifier_id}
    Log To Console    check PDU sessionResourceSetupResponse
    ${filter_expression}=     Catenate    (ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    ...    and ngap.NGAP_PDU == 1 and ngap.procedureCode == 29 and ngap.qosFlowIdentifier)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_response_qosFlowIdentifier}=     cap.Get Field Value By Xpath    xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6
    Set Suite Variable    ${ngap_response_qosFlowIdentifier_id}    ${ngap_response_qosFlowIdentifier}
    Sort List    ${ngap_response_qosFlowIdentifier_id}
    Lists Should Be Equal    ${ngap_request_qosFlowIdentifier_id}    ${ngap_response_qosFlowIdentifier_id}

Get RAN-UE-NGAP-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####InitialUEMessage, Registration request, Registration request
    ${Registration_request}=     Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 15
    ${Registration_request_packets}=    cap.filter_packets_by_expression    filter_expression=${Registration_request}    pcap_parser=test6
    ${RAN_UE_NGAP_ID}=     cap.get_field_value_by_xpath    pdml_list=${Registration_request_packets}
    ...                                                xpath=.//ngap.RAN_UE_NGAP_ID    pcap_parser=test6
    [Return]    ${RAN_UE_NGAP_ID}[0]

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

#Switch QCOM APN to muti DRB
#    [Arguments]    ${apn_name}    ${ue_index}=${0}    ${ue_type}=${ue_type1}
#    Run Keyword And Ignore Error    Attach and check power UE   ue_type=${ue_type}    ue_index=${ue_index}
#    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    #ui_version=${ui_version}
#    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}
#
#Switch APN to muti DRB
#    [Arguments]    ${apn_name}    ${ui_version}    ${ue_index}=${0}    ${ue_type}=${ue_type1}
#    Run Keyword And Ignore Error    Attach and check power UE   ue_type=${ue_type}
#    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
#    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}
#
#Android UE SwitchApn
#    [Documentation]
#    ...    Note: Use the keyword must be ensure that UE UI Menu is English language
#    ...    str ui_version: mobile ui version.
#    ...        e.g Magic UI 3.1.1, have tested on honor CDY-AN90 1080x2400,
#    ...            EMUI 10.1.0, have tested on huawei mate30 LIO-AN00 1176x2400.
#    ...            Qualcomm qti lahaina for arm64 ue do not have UI, so this field equal to '' or ${None}
#    ...           if mobile is mtk peturs, pass 'petrus' as ui_version.
#    [Arguments]       ${ue_index}=${0}    ${host}=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}     ${ui_version}=${None}
#    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${apn_name}=mdrb    ${ue_alias}=UE_${ue_index}
#    android_mobile.setup
#    ...               ui_version=${ui_version}    host=${host}    username=${username}
#    ...               password=${password}    port=22     serial_number=${serial_number}    alias=${UE_alias}
#    run keyword and ignore error    android_mobile.switch_apn       apn_name=${apn_name}   mobile=${UE_alias}
#    android_mobile.teardown       mobile=${UE_alias}

CNI126636 steps executed DL part
    Comment    adjust PA to 0db as initial value
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Sleep    10s    reason=wait for PA adjust completely
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl_small}    dl_throughput=${Send_Tput_DL_small}    duration=${7200}
    Comment    adjust PA to 50db and capture TTI
#    capture TTI log during PA adjust
#    ...    adjust_att_ports=${gnb1_cell2_pa_ports}
#    ...    adjust_origin_values=${gnb1_cell2_pa_origin_values}
#    ...    adjust_target_values=${gnb1_cell2_pa_target_values}
#    ...    timeout=${1800}
#    ...    is_rm_old_log_file=${True}
##    ${log_files}    ${current_time}=    get logs from gnb_logs folder    tool_download_path=/opt/workspace/Tool    type=tti_packed
#    ${log_files}    ${folder_name}    get logs from gnb_logs folder from v2.67
#    ...    tool_download_path=/opt/workspace/Tool    distname_id=${1}    type=tti    lcrid=${2}
#    ${dl_file_name}    get_required_tti_file_name    files_list=${log_files}

    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace With Admin Mode and adjust PA and Convert format
    ...    names=${l2stream3_ttitrace_CNI126636_DL_part}    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace With Admin Mode and adjust PA and Convert format
    ...    names=${l2stream3_ttitrace_CNI126636_DL_part}    nr_phy_cell_ids=53

    Comment    analysis TTI report
    check_value
#    ...    file_path=${epc_log_path}/${folder_name}/${dl_file_name}
    ...    file_path=${epc_log_path}/${l2stream3_ttitrace_CNI126636_DL_part}_dl.csv
    ...    rank1_file_path=${CURDIR}/Resources/CQI_to_MCS_64QAM_Low_SE_with_RANK1_DL.csv
    ...    rank2_file_path=${CURDIR}/Resources/CQI_to_MCS_64QAM_Low_SE_with_RANK2_DL.csv
    [Teardown]    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL

CNI126636 steps executed UL part
    Comment    adjust PA to 0db as initial value
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Sleep    10s    reason=wait for PA adjust completely
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul_X70_small}    ul_throughput=${Send_Tput_UL_small}    duration=${7200}
    Comment    adjust PA to 50db and capture TTI
#    capture TTI log during PA adjust
#    ...    adjust_att_ports=${gnb1_cell2_pa_ports}
#    ...    adjust_origin_values=${gnb1_cell2_pa_origin_values}
#    ...    adjust_target_values=${gnb1_cell2_pa_target_values}
#    ...    timeout=${1800}
#    ...    is_rm_old_log_file=${True}
##    ${log_files}    ${current_time}=    get logs from gnb_logs folder    tool_download_path=/opt/workspace/Tool    type=tti_packed
#    ${log_files}    ${folder_name}    get logs from gnb_logs folder from v2.67
#    ...    tool_download_path=/opt/workspace/Tool    distname_id=${1}    type=tti    lcrid=${2}
#    ${ul_file_name}    get_required_tti_file_name    files_list=${log_files}    required_file_name=ul__all.csv

    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace With Admin Mode and adjust PA and Convert format
    ...    names=${l2stream3_ttitrace_CNI126636_UL_part}    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace With Admin Mode and adjust PA and Convert format
    ...    names=${l2stream3_ttitrace_CNI126636_UL_part}    nr_phy_cell_ids=53

    Comment    analysis TTI report
    check_values_on_direction_ul
#    ...    file_path=${epc_log_path}/${folder_name}/${ul_file_name}
    ...    file_path=${epc_log_path}/${l2stream3_ttitrace_CNI126636_UL_part}_ul.csv
    ...    rnti=${SA_UE_RNTI_ID}
    ...    rank1_file_path=${CURDIR}/Resources/SINR_to_MCS_64QAM_Low_SE_with_RANK1_UL.csv
    ...    rank2_file_path=${CURDIR}/Resources/SINR_to_MCS_64QAM_Low_SE_with_RANK2_UL.csv
    ...    rank1_rank2_mcs_mapping=${CURDIR}/Resources/RANK1_to_RANK2_MCS_mapping.csv
    [Teardown]     Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL

CNI131244 steps executed DL part
    Comment    adjust PA to 0db as initial value
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Sleep    10s    reason=wait for PA adjust completely
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl_small}    dl_throughput=${Send_Tput_DL_small}    duration=${7200}
    Comment    adjust PA to 50db and capture TTI
#    capture TTI log during PA adjust
#    ...    adjust_att_ports=${gnb1_cell2_pa_ports}
#    ...    adjust_origin_values=${gnb1_cell2_pa_origin_values}
#    ...    adjust_target_values=${gnb1_cell2_pa_target_values}
#    ...    timeout=${1800}
#    ...    is_rm_old_log_file=${True}
##    ${log_files}    ${current_time}=    get logs from gnb_logs folder    tool_download_path=/opt/workspace/Tool    type=tti_packed
#    ${log_files}    ${folder_name}    get logs from gnb_logs folder from v2.67
#    ...    tool_download_path=/opt/workspace/Tool    distname_id=${1}    type=tti    lcrid=${2}
#    ${dl_file_name}    get_required_tti_file_name    files_list=${log_files}

    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace With Admin Mode and adjust PA and Convert format
    ...    names=${l2stream3_ttitrace_CNI131244_DL_part}    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace With Admin Mode and adjust PA and Convert format
    ...    names=${l2stream3_ttitrace_CNI131244_DL_part}    nr_phy_cell_ids=53

    Comment    analysis TTI report
    check_value
#    ...    file_path=${epc_log_path}/${folder_name}/${dl_file_name}
    ...    file_path=${epc_log_path}/${l2stream3_ttitrace_CNI131244_DL_part}_dl.csv
    ...    rank1_file_path=${CURDIR}/Resources/CQI_to_MCS_64QAM_Low_SE_with_RANK1_DL_PRB2.csv
    ...    rank2_file_path=${CURDIR}/Resources/CQI_to_MCS_64QAM_Low_SE_with_RANK2_DL_PRB2.csv
    ...    num_prb=2
    [Teardown]    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL

CNI131244 steps executed UL part
    Comment    adjust PA to 0db as initial value
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Sleep    10s    reason=wait for PA adjust completely
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul_X70_small}    ul_throughput=${Send_Tput_UL_small}    duration=${7200}
    Comment    adjust PA to 50db and capture TTI
#    capture TTI log during PA adjust
#    ...    adjust_att_ports=${gnb1_cell2_pa_ports}
#    ...    adjust_origin_values=${gnb1_cell2_pa_origin_values}
#    ...    adjust_target_values=${gnb1_cell2_pa_target_values}
#    ...    timeout=${1800}
#    ...    is_rm_old_log_file=${True}
##    ${log_files}    ${current_time}=    get logs from gnb_logs folder    tool_download_path=/opt/workspace/Tool    type=tti_packed
#    ${log_files}    ${folder_name}    get logs from gnb_logs folder from v2.67
#    ...    tool_download_path=/opt/workspace/Tool    distname_id=${1}    type=tti    lcrid=${2}
#    ${ul_file_name}    get_required_tti_file_name    files_list=${log_files}    required_file_name=ul__all.csv

    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace With Admin Mode and adjust PA and Convert format
    ...    names=${l2stream3_ttitrace_CNI131244_UL_part}    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace With Admin Mode and adjust PA and Convert format
    ...    names=${l2stream3_ttitrace_CNI131244_UL_part}    nr_phy_cell_ids=53

    Comment    analysis TTI report
    check_values_on_direction_ul
#    ...    file_path=${epc_log_path}/${folder_name}/${ul_file_name}
    ...    file_path=${epc_log_path}/${l2stream3_ttitrace_CNI131244_UL_part}_ul.csv
    ...    rnti=${SA_UE_RNTI_ID}
    ...    rank1_file_path=${CURDIR}/Resources/SINR_to_MCS_64QAM_Low_SE_with_RANK1_UL_PRB2.csv
    ...    rank2_file_path=${CURDIR}/Resources/SINR_to_MCS_64QAM_Low_SE_with_RANK2_UL_PRB2.csv
    ...    rank1_rank2_mcs_mapping=${CURDIR}/Resources/RANK1_to_RANK2_MCS_mapping.csv
    ...    num_prb=2
    [Teardown]     Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL

capture TTI log during PA adjust
    [Arguments]    ${adjust_att_ports}    ${adjust_origin_values}    ${adjust_target_values}    ${option}=-C2 -t
    ...    ${gnb_index}=${0}    ${timeout}=${120}    ${is_rm_old_log_file}=${True}
    ...    ${gnb_logs_tool_path}=/opt/workspace/Tool/gnb_logs/
    ${call_result}=    exec_gnb_logs_tool_for_adjust_pa
    ...    ute_ip=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ute_username=${tl.test_pc.default_ssh_connection_details.username}
    ...    ute_password=${tl.test_pc.default_ssh_connection_details.password}
    ...    gnb_logs_tool_path=${gnb_logs_tool_path}
    ...    gnb_ip=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    option=${option}
    ...    att_ipaddr=${tl.attenuator[0].ip_addr}
    ...    att_api_port=${tl.attenuator[0].port}
    ...    vendor=${tl.attenuator[0].vendor}
    ...    att_ports=${adjust_att_ports}
    ...    origin_values=${adjust_origin_values}
    ...    target_values=${adjust_target_values}
    ...    att_connection_port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
    ...    max_attenuation_value=${max_attenuation_value}
    ...    model=${tl.attenuator[0].model}
    ...    is_rm_old_log_file=${is_rm_old_log_file}
    ...    timeout=${timeout}

get_required_tti_file_name
    [Arguments]    ${files_list}    ${required_file_name}=dl__all.csv
    FOR    ${file}    IN    @{files_list}
        ${status}    run keyword and return status    should contain    ${file}    ${required_file_name}
        exit for loop if    '${status}' == 'True'
        set test variable    ${file}
    END
    [Return]    ${file}

Capture Ttitrace With Admin Mode and adjust PA and Convert format
    [Arguments]
    ...            ${names}=l2stream3_ttitrace
    ...            ${SW_BRANCH}=NULL
    ...            ${nr_phy_cell_ids}=NULL
    ...            ${gNB_index}=${0}
    ...            ${target_dir}=${epc_log_path}
    Start Ttitrace With Admin Mode    names=${names}    SW_BRANCH=${SW_BRANCH}    nr_phy_cell_ids=${nr_phy_cell_ids}    gNB_index=${gNB_index}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${gnb1_cell2_pa_target_values}[0]
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${gnb1_cell2_pa_target_values}[0]
    Stop Ttitrace With Admin Mode    names=${names}      target_dir=${target_dir}
    Convert Ttitrace From Pcap To Excelcsv    names=${names}      target_dir=${target_dir}
