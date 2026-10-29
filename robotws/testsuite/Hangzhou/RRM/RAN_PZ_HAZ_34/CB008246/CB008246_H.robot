*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-H

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get gnb release info
...                            AND    Get sagnb version for selenium
...                            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
#...                            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}
#...                            golden_scf_name=${tl_scf_${release_info}}
...                            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}
...                            golden_scf_name=${tl_gnb1_scf_${sw_version}}
...                            AND    Common UE parameter setup

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_H_006_1}    log_name_H_006_1.pcap
${log_name_H_001_1}    log_name_H_001_1.pcap
${log_name_H_001_2}    log_name_H_001_2.pcap
${expected_tput_dl}    1
${Send_Tput_DL}        600M
${expected_tput_ul}    1
${Send_Tput_UL}        200M
${H001_expected_tput_dl}    150
${Send_Tput_IMS_DL}    10M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-E_Counter&KPI
@{PA_H06_values}    ${5}    ${32}    ${34}    ${38}    ${40}    ${42}

${origin_value}    0
@{target_value_H001}    39    40

#${specious_scf}    Configuration_scf_GNB1_CB008246_Q.xml
#${tl_scf_SBTS25R1_ENB_9999_specious}    25R1_Configuration_scf_GNB1_CB008246_specious.xml

*** Test Cases ***
[1]CB008246-H_006_PM_counters_with_PDCCH_PDSCH_switch_between_HR_and_BR_where_UE_with_Dl-64QAM-MCS-TableAlt_in_40Mhz_cell
    [Documentation]    CB008246-H
    [Tags]    CB008246-H    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    H006 Prerequisite
    H006 Step 1 UE2 attach
    H006 Step 2 UE2 make traffic
#    H006 Step 3 trigger HR on AL2 and check KPI
#    H006 Step 4 trigger HR on AL4 and check KPI
#    H006 Step 5 trigger HR on AL8 and check KPI
    H006 Step 3 4 5 trigger HR on AL2 AL4 AL8 and check KPI
    H006 Step 6 trigger HR to BR and check KPI
    H006 Step 7 trigger BR to HR and check KPI
    [Teardown]    H006 Teardown


#[1]CB008246-H_001_Scheduling_of_5G_Ues_for_multiple_DRBs_with_PDCCH_PDSCH_switch_between_HR_and_BR_where_UE_with_Dl-64QAM-MCS-TableAlt
#    [Documentation]    CB008246-H
#    [Tags]    CB008246-H   CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    comment    100M
##    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
#    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${specious_scf}    is_pdl_checking_needed=${False}
#    robot_common_operations.Common Case Setup
#    Modify Parameters for Cases    gnb_index=${0}    Add_Mo_Online=${parameters_to_update_8246_H_001}
#    Online modify parmeters     gnb_index=${0}    parameters_to_update=${PARAM_8246_gnb1_H_001}
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    Comment    UE3 attach on gnb1 cell1
#    Start capture gNB log on master    filename=${log_name_H_001_1}
#    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
#    Sleep    30s
#    Stop and download Logs on gNB on master    filename=${log_name_H_001_1}
#    Check wireshark log for 8246_H001_1
#    Start only DL traffic and check tput    ue_index=${2}    cellid=1    ue_type=${ue_type}    gnb_index=${0}
#    ...                                tput_dl_cell=${H001_expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=3600
#    Analysis tti for H001
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
##    ...    Stop DL or UL IMS traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
##    ...    iperf_port=${tl.ues[2].iperf_details.ssh_connection_details.port}    AND
#    ...    AND    Switch QCOM airplane mode status on    ue_index=${2}    ue_type=${ue_type}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_H_001_1}
#    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_8246_recover_gnb1_H_001}
#    ...    AND    Modify Parameters for Cases    gnb_index=${0}    Delete_Mo_Online=${parameters_to_delete_8246_H_001}
#    ...    Delete_Para_Online=${PARAM_8246_recover_delete_gnb1_H_001}
#    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    ...    AND    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


*** Keywords ***
Analysis tti for H001
    Comment     gnb1 cell1 PA to 40db to trigger HR to BR
    Start capture gNB log on master    filename=${log_name_H_001_2}
    Capture Ttitrace tti for H001_1
    sleep    10s
    Analysis tti for H001_1    names=l2stream3_ttitrace_1
    Comment     gnb1 cell1 PA to 0db to trigger BR to HR
    Capture Ttitrace tti for H001_2
    Stop and download Logs on gNB on master    filename=${log_name_H_001_2}
    Analysis tti for H001_2    names=l2stream3_ttitrace_2

Capture Ttitrace tti for H001_1
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE Attenuation For Loop    target_value=${target_value_H001}[1]
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE Attenuation For Loop    target_value=${target_value_H001}[0]
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE Attenuation For Loop    target_value=${target_value_H001}[1]
#    Start capture gNB log on master    filename=${log_name_H_001_2}
    Sleep    15s
    Capture Ttitrace and Convert format_H001_1    names=l2stream3_ttitrace_1    #gnb1_cell1_value=${39}

Adjust HBTE Attenuation For Loop
    [Arguments]    ${target_value}=${39}
    FOR  ${value}    IN RANGE    ${origin_value}    ${target_value}    ${1}
       Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${value}
    END

Capture Ttitrace and Convert format_H001_1
    [Arguments]    ${names}=l2stream3_ttitrace_1    ${gnb1_cell1_value}=${43}
    Log    ${gnb1_cell1_value}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace With Admin Mode and Convert format    nr_phy_cell_ids=55    names=${names}    gnb1_cell1_value=${50}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace With Admin Mode and Convert format    nr_phy_cell_ids=51    names=${names}    gnb1_cell1_value=${45}
#    ...    Capture Ttitrace With Admin Mode and Convert format    nr_phy_cell_ids=51    names=${names}    gnb1_cell1_value=${41}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace With Admin Mode and Convert format    nr_phy_cell_ids=59    names=${names}    gnb1_cell1_value=${50}

Capture Ttitrace tti for H001_2
    Capture Ttitrace and Convert format_H001_2    names=l2stream3_ttitrace_2    #gnb1_cell1_value=${0}

Capture Ttitrace and Convert format_H001_2
    [Arguments]    ${names}=l2stream3_ttitrace_1    #${gnb1_cell1_value}=${43}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace With Admin Mode and Convert format    nr_phy_cell_ids=55    names=${names}    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace With Admin Mode and Convert format    nr_phy_cell_ids=51    names=${names}    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace With Admin Mode and Convert format    nr_phy_cell_ids=59    names=${names}    gnb1_cell1_value=${0}








H006 Prerequisite
    comment    Modify 100M to 40M
    robot_common_operations.Common Case Setup    allowed_faults_ids=62003,62001
    AlarmWatchdog.add_allow_alarms    fault_id=62003
    AlarmWatchdog.add_allow_alarms    fault_id=62001
    set test variable    ${release_info}
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    online update list parameter model    parameters=${PARAM_list_8246_gnb1_H_006}
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_H_006}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
#    Stop capture syslog via btslog on ute
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

H006 Step 1 UE2 attach
    Comment    UE3 attach on gnb1 cell1
    Start capture gNB log on master    filename=${log_name_H_006_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_H_006_1}
    ...    AND    Check wireshark log for 8246_H006_1

H006 Step 2 UE2 make traffic
    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    Start only UL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}

H006 Step 3 trigger HR on AL2 and check KPI
    Comment     gnb1 cell1 PA to 5db to trigger HR on AL2
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${5}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait HR on AL2 completely and xml report generated
    check dict KPI from pm file on H006    KPI_file=CB008246_H_006_HR_AL2_KPI.txt    para_index=${1}    kpi_select=AL2

H006 Step 4 trigger HR on AL4 and check KPI
    Comment     gnb1 cell1 PA to 30db to trigger HR on AL4 24R1:32
    run keyword if    '${release_info}' == '${branch}[1]'    adjust pa on trunk    value1=${30}
    ...    ELSE    adjust pa on release build    value1=${31}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${30}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait HR on AL4 completely and xml report generated
    check dict KPI from pm file on H006    KPI_file=CB008246_H_006_HR_AL4_KPI.txt    para_index=${1}    kpi_select=AL4

H006 Step 5 trigger HR on AL8 and check KPI
    Comment     gnb1 cell1 PA to 32db to trigger HR on AL8 24R1:34
    run keyword if    '${release_info}' == '${branch}[1]'    adjust pa on trunk    value1=${32}
    ...    ELSE    adjust pa on release build    value1=${33}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${32}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait HR on AL8 completely and xml report generated
    check dict KPI from pm file on H006    KPI_file=CB008246_H_006_HR_AL8_KPI.txt    para_index=${1}    kpi_select=AL8

H006 Step 3 4 5 trigger HR on AL2 AL4 AL8 and check KPI
    comment    WA
    Comment     gnb1 cell1 PA to per value to trigger HR on AL2 AL4 AL8
    Prepare with PM counter time to caculate    period=start
    trigger AL2 AL4 AL8 counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=wait HR on AL2 AL4 AL8 completely and xml report generated
    check dict KPI from pm file on H006    KPI_file=CB008246_H_006_HR_AL2_AL4_AL8_KPI.txt    para_index=${1}    kpi_select=HR
#    check dict KPI from pm file on H006    KPI_file=CB008246_H_006_HR_AL2_KPI.txt    para_index=${1}    kpi_select=AL2
#    check dict KPI from pm file on H006    KPI_file=CB008246_H_006_HR_AL4_KPI.txt    para_index=${1}    kpi_select=AL4
#    check dict KPI from pm file on H006    KPI_file=CB008246_H_006_HR_AL8_KPI.txt    para_index=${1}    kpi_select=AL8

H006 Step 6 trigger HR to BR and check KPI
    Comment     gnb1 cell1 PA to 41db to trigger HR to BR 24R1:43
#    run keyword if    '${release_info}' == '${branch}[1]'    adjust pa on trunk    value1=${45}
#    ...    ELSE    adjust pa on release build    value1=${45}
    run keyword if    '${release_info}' == '${branch}[1]'    adjust pa on trunk    value1=${36}
    ...    ELSE    adjust pa on release build    value1=${36}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${41}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
    Prepare with PM counter time to caculate    period=start
    sleep    1min    reason=wait HR switch to BR completely and xml report generated
#    check if HR swtich to BR success
    check dict KPI from pm file on H006    KPI_file=CB008246_H_006_BR_KPI.txt    para_index=${1}    kpi_select=BR

H006 Step 7 trigger BR to HR and check KPI
    Comment     gnb1 cell1 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait BR switch to HR completely and xml report generated
#    check if BR swtich to HR success
    check dict KPI from pm file on H006    KPI_file=CB008246_H_006_HR_AL2_KPI.txt    para_index=${1}    kpi_select=AL2
#    CNI-144608:
#    'TMO_MAGENTA_1012a': 35.840345514950165,
#    'TMO_MAGENTA_1013a': 19.835725102990033,
#    'TMO_MAGENTA_1014a': 2.4157972187307863,
#    'TMO_MAGENTA_1015a': 3.8401228612986054,

H006 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=62003
    AlarmWatchdog.remove_allow_alarms    fault_id=62001
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_H_006}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    online update list parameter model    parameters=${PARAM_list_8246_recover_gnb1_H_006}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    get and analysis syslog






adjust pa on trunk
    [Arguments]    ${value1}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${value1}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}

adjust pa on release build
    [Arguments]    ${value1}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${value1}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}

trigger AL2 AL4 AL8 counters
    FOR    ${value}    IN    @{PA_H06_values}
        Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
        ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${value}
        ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
        sleep    30s
    END

Setup for Env cell on-air for 2 gnb modify scf first
    [Arguments]      ${ParamterToModify}=${PARAM_8246_gnb1_H_006_01}    ${ListParamterToModify}=${PARAM_list_8246_gnb1_H_006_01}
    ...    ${is_commission_for_second_gnb}=True    ${is_pdl_checking_needed}=True
    Common Case TestLine Setup    ModifySCF_Beforecommission=True    is_commission_for_second_gnb=${is_commission_for_second_gnb}
#    ...    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}    golden_scf_name_gnb2=${tl_scf2_${release_info}}
    ...    scf_path=${scf_path}    golden_scf_name=${specious_scf}    golden_scf_name_gnb2=${tl_scf2_${release_info}}
    ...    ParamterToModify=${ParamterToModify}    ListParamterToModify=${ListParamterToModify}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}

#Setup for Env cell on-air for 2 gnb modify scf first
#    [Arguments]      ${ParamterToModify}=${PARAM_8246_gnb1_H_006_01}    ${ListParamterToModify}=${PARAM_list_8246_gnb1_H_006_01}
#    ...    ${is_commission_for_second_gnb}=True
#    Common Case TestLine Setup    ModifySCF_Beforecommission=True    is_commission_for_second_gnb=${is_commission_for_second_gnb}
#    ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_scf_file_name1}    golden_scf_name_gnb2=${tl_scf_file_name2}
#    ...    ParamterToModify=${ParamterToModify}    ListParamterToModify=${ListParamterToModify}

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

check dict KPI from pm file on H006
    [Arguments]     ${KPI_file}    ${para_index}    ${kpi_select}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    Run Keyword If    '${kpi_select}' == 'AL2'
    ...    check required KPI via pm file    KPI_name_list=${CB008246_H_006_HR_AL2_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    ...    ELSE IF    '${kpi_select}' == 'AL4'
    ...    check required KPI via pm file    KPI_name_list=${CB008246_H_006_HR_AL4_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    ...    ELSE IF    '${kpi_select}' == 'AL8'
    ...    check required KPI via pm file    KPI_name_list=${CB008246_H_006_HR_AL8_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    ...    ELSE IF    '${kpi_select}' == 'HR'
    ...    check required KPI via pm file    KPI_name_list=${CB008246_H_006_HR_AL_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    ...    ELSE IF    '${kpi_select}' == 'BR'
    ...    check required KPI via pm file    KPI_name_list=${CB008246_H_006_BR_AL_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_H_006_HR_AL_common_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}

Check wireshark log for 8246_H006_1
    Check UL_UE_MCS_table_Capbility    logname=${log_name_H_006_1}

Check UL_UE_MCS_table_Capbility
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

COAM Save snapshot
    get gnb snapshot    gnb_index=${0}
#    get gnb snapshot    gnb_index=${1}

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
    Set 8246H the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set 8246H the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set 8246H the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set 8246H the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}

Check wireshark log for 8246_H001_1
    Check DL_UE_MCS_table_Capbility    logname=${log_name_H_001_1}

Check DL_UE_MCS_table_Capbility
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.downlinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[0]}    1

Start only DL IMS traffic and check tput
    [Documentation]
    ...                DL_port used UL prot for IMS DL traffic
    [Arguments]    ${logname}    ${ue_index}=${0}
    ...            ${DL_port}=${tl.ues[2].iperf_details.ssh_connection_details.port}    ${time}=600
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B
    ...            ${process_num}=${1}   ${cap_index}=${0}
    Log    ${cap_index}
    log to console    .....UE_${ue_index} udp dl IMS iperf start....
    ${UE_IP}    Get UE IP from wirehsark    logname=${logname}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l ${buffer_size} -T 64&
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} udp dl iperf start....

Capture Ttitrace With Admin Mode and Convert format
    [Documentation]    Auther: liujia
    [Arguments]    ${capture_time}=5s
    ...            ${names}=l2stream3_ttitrace
    ...            ${SW_BRANCH}=NULL
    ...            ${nr_phy_cell_ids}=NULL
    ...            ${gNB_index}=${0}
    ...            ${target_dir}=${epc_log_path}
    ...            ${gnb1_cell1_value}=${127}
    ...            ${gnb1_cell2_value}=${127}
    ...            ${gnb2_cell1_value}=${127}
    ...            ${enb_cell1_value}=${127}
    Start Ttitrace With Admin Mode    names=${names}    SW_BRANCH=${SW_BRANCH}    nr_phy_cell_ids=${nr_phy_cell_ids}    gNB_index=${gNB_index}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${gnb1_cell1_value}
    ...                   gnb1_cell2_value=${gnb1_cell2_value}    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${gnb1_cell1_value}
    ...                   gnb1_cell2_value=${gnb1_cell2_value}    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${gnb1_cell1_value}
    ...                   gnb1_cell2_value=${gnb1_cell2_value}    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
    Sleep    ${capture_time}    reason=capture ttitrace
    Stop Ttitrace With Admin Mode    names=${names}      target_dir=${target_dir}
    Convert Ttitrace From Pcap To Excelcsv    names=${names}      target_dir=${target_dir}

Set 8246H the attenuation value
    [Arguments]    ${att_ports}    ${values}    ${att_connection_port}=${att_connection_port}    ${att_ipaddr}=${att_ipaddr}
    ...    ${max_attenuation_value}=${127}
    [Documentation]    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_port}:List all the attenuator ports as int list
    ...    ${value}:List the value of attenuator ports  int list
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    ${Num_att_port}=    get length    ${att_ports}
    FOR    ${Num}    IN RANGE    ${0}    ${Num_att_port}
        att.set_attenuation     port=${att_ports[${Num}]}    value=${values[${Num}]}
        ${value_port}    att.read_attenuation    port=${att_ports[${Num}]}
        ${value_port}=    Convert To Integer    ${value_port}
        should be equal    ${value_port}    ${values[${Num}]}
    END

Analysis tti for H001_1
    [Arguments]    ${names}
    log to console    analysis HR to BR HR tti file from Case_Logs file...
#    ${col_hr_pdcchMetric_ratio}    ${col_hr_pdschMetric_ratio}    get_HR_HR_value    csv_file=/home/ute/TAF/zyy/l2stream3_ttitrace_1_dl.csv
    ${col_hr_pdcchMetric_ratio}    ${col_hr_pdschMetric_ratio}    get_HR_HR_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlLaSwitchBetweenHrAndBr.laMode   filter_name2=dlLaSwitchBetweenHrAndBr.event
    ...    filter_name3=dlLaSwitchBetweenHrAndBr.pdcchMetric.ratio    filter_name4=dlLaSwitchBetweenHrAndBr.pdschMetric.ratio
    FOR  ${i}    IN    @{col_hr_pdcchMetric_ratio}
        should be true      ${${i}}<${${50.0}}
    END
    FOR  ${i}    IN    @{col_hr_pdschMetric_ratio}
        should be true      ${${i}}<${${50.0}}
    END
    log to console    analysis HR to BR BR tti file from Case_Logs file...
    get_HR_BR_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlLaSwitchBetweenHrAndBr.laMode   filter_name2=dlLaSwitchBetweenHrAndBr.event
    ...    filter_name3=dlLaSwitchBetweenHrAndBr.pdcchMetric.ratio    filter_name4=dlLaSwitchBetweenHrAndBr.pdschMetric.ratio
    log to console    analysis add -A -D checkpoint when HR to BR AL4 tti file from Case_Logs file...
    ${col_hr_CqiAlSelection}    get_HR_HR_AL4_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.aggregationLevel    filter_name3=dlFdSchedData.cqiAlSelection
    FOR  ${i}    IN    @{col_hr_CqiAlSelection}
        should be true      ${${i}}>=${${4.5}}
    END
    log to console    analysis add -A -D checkpoint when HR to BR AL8 tti file from Case_Logs file...
    ${col_hr_CqiAlSelection}    get_HR_HR_AL8_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.aggregationLevel    filter_name3=dlFdSchedData.cqiAlSelection
    FOR  ${i}    IN    @{col_hr_CqiAlSelection}
        should be true      ${${i}}<${${4.5}}
    END
    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
    ${col_hr_rrmCorrAvgCqi}    ${num1}    get_HR_HR_rrmCorrAvgCqi_RANK1_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi    filter_name5=slot
    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
        should be true      ${${5.18}}<${${i}}<${${5.52}}
    END
    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
    ${col_hr_rrmCorrAvgCqi}    ${num2}    get_HR_HR_rrmCorrAvgCqi_RANK2_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi    filter_name5=slot
    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
        should be true      ${${5.48}}<${${i}}<${${5.91}}
    END
    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
    ${col_hr_rrmCorrAvgCqi}    ${num3}    get_HR_BR_rrmCorrAvgCqi_RANK1_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi    filter_name5=slot
    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
        should be true      ${${5.04}}<${${i}}<${${5.47}}
    END
    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
    ${col_hr_rrmCorrAvgCqi}    ${num4}    get_HR_BR_rrmCorrAvgCqi_RANK2_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi    filter_name5=slot
    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
        should be true      ${${5.43}}<${${i}}<${${5.81}}
    END
    ${num}=    Evaluate    ${num1} + ${num2} + ${num3} + ${num4}
    Should Be True    ${num}>=1
    [Teardown]    run keyword    Stop and download Logs on gNB on master    filename=${log_name_H_001_2}


#    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
#    ${col_hr_rrmCorrAvgCqi}    get_HR_HR_rrmCorrAvgCqi_RANK1_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
#    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
#    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi
#    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
#        should be true      ${${0.88}}<${${i}}<${${1.15}}
##        should be true      ${${0.88}}<${${i}}<${${1.8}}
#    END
#    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
#    ${col_hr_rrmCorrAvgCqi}    get_HR_HR_rrmCorrAvgCqi_RANK2_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
#    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
#    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi
#    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
#        should be true      ${${2.15}}<${${i}}<${${2.34}}
#    END
#    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
#    ${col_hr_rrmCorrAvgCqi}    get_HR_BR_rrmCorrAvgCqi_RANK1_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
#    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
#    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi
#    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
#        should be true      ${${0.79}}<${${i}}<${${1.01}}
#    END
#    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
#    ${col_hr_rrmCorrAvgCqi}    get_HR_BR_rrmCorrAvgCqi_RANK2_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
#    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
#    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi
#    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
#        should be true      ${${2.08}}<${${i}}<${${2.22}}
#    END

Analysis tti for H001_2
    [Arguments]    ${names}
    log to console    analysis BR to HR HR tti file from Case_Logs file...
    ${col_hr_pdcchMetric_ratio}    ${col_hr_pdschMetric_ratio}    get_BR_HR_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlLaSwitchBetweenHrAndBr.laMode   filter_name2=dlLaSwitchBetweenHrAndBr.event
    ...    filter_name3=dlLaSwitchBetweenHrAndBr.pdcchMetric.ratio    filter_name4=dlLaSwitchBetweenHrAndBr.pdschMetric.ratio
    should not be empty    ${col_hr_pdcchMetric_ratio}
    should not be empty    ${col_hr_pdschMetric_ratio}
    FOR  ${i}    IN    @{col_hr_pdcchMetric_ratio}
        should be true      ${${i}}>${${60.0}}
    END
    FOR  ${i}    IN    @{col_hr_pdschMetric_ratio}
        should be true      ${${i}}>${${60.0}}
    END
    log to console    analysis BR to HR BR tti file from Case_Logs file...
    get_BR_BR_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlLaSwitchBetweenHrAndBr.laMode   filter_name2=dlLaSwitchBetweenHrAndBr.event
    ...    filter_name3=dlLaSwitchBetweenHrAndBr.pdcchMetric.ratio    filter_name4=dlLaSwitchBetweenHrAndBr.pdschMetric.ratio
    log to console    analysis add -A -D checkpoint when BR to HR AL4 tti file from Case_Logs file...
    ${col_hr_CqiAlSelection}    get_HR_HR_AL4_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.aggregationLevel    filter_name3=dlFdSchedData.cqiAlSelection
    FOR  ${i}    IN    @{col_hr_CqiAlSelection}
        should be true      ${${i}}>=${${4.5}}
    END
    log to console    analysis add -A -D checkpoint when BR to HR AL8 tti file from Case_Logs file...
    ${col_hr_CqiAlSelection}    get_HR_HR_AL8_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.aggregationLevel    filter_name3=dlFdSchedData.cqiAlSelection
    FOR  ${i}    IN    @{col_hr_CqiAlSelection}
        should be true      ${${i}}<${${4.5}}
    END
    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
    ${col_hr_rrmCorrAvgCqi}    ${num1}    get_HR_HR_rrmCorrAvgCqi_RANK1_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi    filter_name5=slot
    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
        should be true      ${${5.18}}<${${i}}<${${5.52}}
    END
    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
    ${col_hr_rrmCorrAvgCqi}    ${num2}    get_HR_HR_rrmCorrAvgCqi_RANK2_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi    filter_name5=slot
    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
        should be true      ${${5.48}}<${${i}}<${${5.91}}
    END
    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
    ${col_hr_rrmCorrAvgCqi}    ${num3}    get_HR_BR_rrmCorrAvgCqi_RANK1_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi    filter_name5=slot
    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
        should be true      ${${5.04}}<${${i}}<${${5.47}}
    END
    log to console    analysis add -A -D checkpoint when HR to BR rrmCorrAvgCqi tti file from Case_Logs file...
    ${col_hr_rrmCorrAvgCqi}    ${num4}    get_HR_BR_rrmCorrAvgCqi_RANK2_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi    filter_name5=slot
    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
        should be true      ${${5.43}}<${${i}}<${${5.81}}
    END
    ${num}=    Evaluate    ${num1} + ${num2} + ${num3} + ${num4}
    Should Be True    ${num}>=1



#    log to console    analysis add -A -D checkpoint when BR to HR rrmCorrAvgCqi tti file from Case_Logs file...
#    ${col_hr_rrmCorrAvgCqi}    get_HR_HR_rrmCorrAvgCqi_RANK1_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
#    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
#    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi
#    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
#        should be true      ${${0.88}}<${${i}}<${${1.15}}
##        should be true      ${${0.88}}<${${i}}<${${1.8}}
#    END
#    log to console    analysis add -A -D checkpoint when BR to HR rrmCorrAvgCqi tti file from Case_Logs file...
#    ${col_hr_rrmCorrAvgCqi}    get_HR_HR_rrmCorrAvgCqi_RANK2_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
#    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
#    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi
#    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
#        should be true      ${${2.15}}<${${i}}<${${2.34}}
#    END
#    log to console    analysis add -A -D checkpoint when BR to HR rrmCorrAvgCqi tti file from Case_Logs file...
#    ${col_hr_rrmCorrAvgCqi}    get_HR_BR_rrmCorrAvgCqi_RANK1_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
#    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
#    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi
#    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
#        should be true      ${${0.79}}<${${i}}<${${1.01}}
#    END
#    log to console    analysis add -A -D checkpoint when BR to HR rrmCorrAvgCqi tti file from Case_Logs file...
#    ${col_hr_rrmCorrAvgCqi}    get_HR_BR_rrmCorrAvgCqi_RANK2_AD_value    csv_file=${epc_log_path}/${names}_dl.csv
#    ...    filter_name1=dlFdSchedData.laMode   filter_name2=dlFdSchedData.numOfLayers
#    ...    filter_name3=dlFdSchedData.rrmDlProposedMcs    filter_name4=dlFdSchedData.rrmCorrAvgCqi
#    FOR  ${i}    IN    @{col_hr_rrmCorrAvgCqi}
#        should be true      ${${2.08}}<${${i}}<${${2.22}}
#    END

Get UE IP from wirehsark
    [Arguments]    ${logname}
    ...    ${message_filter}=ngap.procedureCode == 14 and nas_5gs.sm.pdu_addr_inf_ipv4
    ...    ${xpath}=.//nas_5gs.sm.pdu_addr_inf_ipv4
    Log    Get UE IP from wirehsark
    ${UE_IP}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    [Return]    ${UE_IP}[0]

Check wireshark log
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${attribute_name}=show
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${filtered_result}=     cap.get_field_value_by_xpath    attribute_name=${attribute_name}    xpath=${xpath}    pcap_parser=test6
    [Return]    ${filtered_result}
