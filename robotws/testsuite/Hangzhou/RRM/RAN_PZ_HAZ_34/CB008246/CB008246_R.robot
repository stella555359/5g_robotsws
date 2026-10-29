*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-R

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...             robot_common_operations.Common Suite Setup
...             AND    Common Suite Setup for COAM
...             AND    Get gnb release info
...             AND    Get sagnb version for selenium
...             AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
...             AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}
...             golden_scf_name=${tl_gnb1_scf_${sw_version}}
...             AND    Common UE parameter setup

Suite Teardown         Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_R_005_1}    log_name_R_005_1.pcap
${log_name_R_007_1}    log_name_R_007_1.pcap
${log_name_Q_002_1}    log_name_Q_002_1.pcap
${log_name_Q_002_2}    log_name_Q_002_2.pcap
${log_name_Q_002_3}    log_name_Q_002_3.pcap
${expected_tput_dl}    300
${Send_Tput_DL}        600M
${expected_tput_ul}    90
${Send_Tput_UL}        200M
${R007_expected_tput_dl}    100
${R007_Send_Tput_DL}     600M
${expected_tput_dl_R005}    0
${Send_Tput_DL_R005}        1K
${expected_tput_ul_R005}    0
${Send_Tput_UL_R005}        1K
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-R_Counter&KPI
${tool_path}    /opt/workspace/Tool

@{allow_fault_list}    2923    2922    7311    62001    8150    62003

*** Test Cases ***
#[1]CB008246-R_005_Fallback_Recovery_from_HR_to_BR_Enhancement-L2PS_PDSCH_PUSCH_Sampling_TDD
#    [Documentation]    CB008246-R
#    ...    make 1kb DL+UL traffic
#    [Tags]    CB008246-R    CRT_TRUNK    CRT_24R2
#    [Timeout]    6 hour
#    [Setup]
#    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
#    Set Test Variable    ${rerun_counter}    ${0}
#    Wait Until Keyword Succeeds    3x    5s    Run R005 case
#    [Teardown]    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot

[1]CB008246-R_007_High_Reliability_UE_counter_64QAM_table
    [Documentation]    CB008246-R    ZYY
    [Tags]    CB008246-R    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    R007 Prerequisite
    R007 Step 1 UE1 attach
    R007 Step 2 UE1 start traffic DL
    R007 Step 3 UE1 HR BR counter
    [Teardown]    R007 Teardown

*** Keywords ***
Run R005 case
    ${rerun_counter}=    Evaluate    ${rerun_counter}+1
    Set Test Variable    ${rerun_counter}
    R005 Prerequisite
    R005 Step 1 UE2 attach
    R005 Step 2 UE2 make traffic
    R005 Step 3 check HR KPI
    R005 Step 4 trigger HR to BR and check KPI
    R005 Step 5 trigger BR to HR and check KPI
    [Teardown]    R005 Teardown


R005 Prerequisite
    comment    R005 Prerequisite: same with -D and -E, but make 1kb traffic with DL and UL, modify parameter actDtxOptimizedScheduler as false
    robot_common_operations.Common Case Setup
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_R_005}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Run Keyword If    ${rerun_counter}==1    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

R005 Step 1 UE2 attach
    comment    Step1: UE2 attach on gnb1 cell2
    Start capture gNB log on master    filename=${log_name_R_005_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_R_005_1}
    ...    AND    Check wireshark log for 8246_R005_1

R005 Step 2 UE2 make traffic
    comment    Step2: UE2 make traffic with DL and UL
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl_R005}    dl_throughput=${Send_Tput_DL_R005}    duration=${7200}
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul_R005}    ul_throughput=${Send_Tput_UL_R005}    duration=${7200}

R005 Step 3 check HR KPI
    comment    Step3: check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Check D006 DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}

R005 Step 4 trigger HR to BR and check KPI
    Comment     Step4: gnb1 cell2 PA to 59db to trigger UL HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${59}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait HR switch to BR completely and xml report generated
    check if HR swtich to BR success
    check BR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_BR_KPI.txt    para_index=${2}
    Comment     Step4: gnb1 cell2 PA to 62db to trigger DL HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${62}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait HR switch to BR completely and xml report generated
    Check D006 BR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_BR_KPI.txt    para_index=${2}

R005 Step 5 trigger BR to HR and check KPI
    Comment     Step5: gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait BR switch to HR completely and xml report generated
    check if BR swtich to HR success
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}
    Check D006 DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}

R005 Teardown
    robot_common_operations.Common Case Teardown
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
#    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_R_005}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown





R007 Prerequisite
    comment    R007 Prerequisite: 5QI7 HR
    robot_common_operations.Common Case Setup    allowed_faults_ids=8150,62003,62001
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_R_007}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}

R007 Step 1 UE1 attach
    Comment    UE1 attach on gnb1 cell2
    Start capture gNB log on master    filename=${log_name_R_007_1}
    Power_ue.Prepare UE    ue_type=${tl.ues[0].capabilities[2]}    ue_index=${0}
    Attach and check power UE    ue_type=${tl.ues[0].capabilities[2]}    ue_index=${0}    gnb_index=${0}
    Sleep    10s
    [Teardown]    run keyword    Stop and download Logs on gNB on master    filename=${log_name_R_007_1}

R007 Step 2 UE1 start traffic DL
    Start only DL traffic and check tput    ue_index=${0}    cellid=2    ue_type=${ue_type1}    gnb_index=${0}
    ...                                tput_dl_cell=${R007_expected_tput_dl}    dl_throughput=${R007_Send_Tput_DL}    duration=7200
    ...                                dl_port=${tl.ues[0].iperf_details.port}

R007 Step 3 UE1 HR BR counter
	log to console    analysis HR counter ...
    sleep    15s
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Run Keyword And Continue On Failure    Check counter for 8246_HR_R007_gNB1cell2

	log to console    analysis BR counter ...
    Comment     gnb1 cell2 PA to 57db to trigger HR to BR
    sleep    5s
    HR to BR on R007 loop
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${57}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${57}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${57}
#    sleep    15s
##    Comment     gnb1 cell2 PA to 57db to trigger HR to BR
##    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust Signal HBTE gNB_eNB_RU Attenuation
##    ...                                                                gnb1_cell2_p3_value=${57}    gnb1_cell2_p4_value=${127}
##    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${62}
##    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${57}
##    sleep    25s
#    Prepare with PM counter time to caculate    period=start
#    sleep    5min
#    Run Keyword And Continue On Failure    Check counter for 8246_BR_R007_gNB1cell2

	log to console    analysis HR counter ...
	sleep    5s
    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    sleep    15s
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Run Keyword And Continue On Failure    Check counter for 8246_HR_R007_gNB1cell2

Check counter for 8246_HR_R007_gNB1cell2
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_R007_64QAM_HR_gNB1_cell2}    dic_path=${Trunk_counter_dic_path_R007_64QAM_HR_gNB1_cell2}
    Set suite variable    ${M55366C00013_64QAM_HR}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00014_64QAM_HR}                   ${counter_value_list}[1]
    Set suite variable    ${M55367C00013_64QAM_HR}                   ${counter_value_list}[2]
    Set suite variable    ${M55308C01000_64QAM_HR}                   ${counter_value_list}[3]
    Set suite variable    ${M55308C01001_64QAM_HR}                   ${counter_value_list}[4]

    Should Be True    ${M55366C00013_64QAM_HR}>0
    Should Be True    ${M55366C00014_64QAM_HR}>0
    Should Be True    ${M55367C00013_64QAM_HR}>0
    ${R007_64QAM_HR_counter1_counter4}=    Evaluate     ${M55366C00013_64QAM_HR}/${M55308C01000_64QAM_HR}
    Should Be Equal    ${R007_64QAM_HR_counter1_counter4}    ${1}
    ${R007_64QAM_HR_counter2_counter4}=    Evaluate     ${M55366C00014_64QAM_HR}/${M55308C01000_64QAM_HR}
    Should Be Equal    ${R007_64QAM_HR_counter2_counter4}    ${1}
    ${R007_64QAM_HR_counter3_counter5}=    Evaluate     ${M55367C00013_64QAM_HR}/${M55308C01001_64QAM_HR}
    Should Be Equal    ${R007_64QAM_HR_counter3_counter5}    ${1}

Check counter for 8246_BR_R007_gNB1cell2
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_R007_64QAM_BR_gNB1_cell2}    dic_path=${Trunk_counter_dic_path_R007_64QAM_BR_gNB1_cell2}
    Set suite variable    ${M55366C00013_64QAM_HR}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00014_64QAM_HR}                   ${counter_value_list}[1]
    Set suite variable    ${M55367C00013_64QAM_HR}                   ${counter_value_list}[2]
    Set suite variable    ${M55308C01000_64QAM_HR}                   ${counter_value_list}[3]
    Set suite variable    ${M55308C01001_64QAM_HR}                   ${counter_value_list}[4]

    Should Be True    ${M55366C00013_64QAM_HR}>0
    Should Be Equal    ${M55366C00014_64QAM_HR}    ${0}
    Should Be Equal    ${M55367C00013_64QAM_HR}    ${0}
    Should Be True    ${M55308C01000_64QAM_HR}>0
    Should Be True    ${M55308C01001_64QAM_HR}>0
    ${R007_64QAM_HR_counter1_counter4}=    Evaluate     ${M55366C00013_64QAM_HR}/${M55308C01000_64QAM_HR}
    Should Be Equal   ${R007_64QAM_HR_counter1_counter4}    ${1}

R007 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=${allow_fault_list}
#    Start capture syslog via btslog on ute
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    UE.UE Detach     ue_type=${ue_type1}     ue_index=${0}
#    Stop capture syslog via btslog on ute
    Adjust HBTE gNB_eNB_RU Attenuation
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_R_007}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    get and analysis syslog

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


Q002 Prerequisite
    comment    Q002 Prerequisite: 5QI7 HR, srbInactivityTimerSA and drbInactivityTimerSA set 10s
    robot_common_operations.Common Case Setup
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_Q_002}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}

Q002 Step 1 UE2 attach and trigger ue inactive
    comment    Step1: UE2 attach on gnb1 cell2
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_Q_002_1}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    run keywords
    ...    sleep    30s    reason=wait for ue into inactive status
    ...    AND    Stop and download Logs on gNB on master    filename=${log_name_Q_002_1}
    ...    AND    Prepare with PM counter time to caculate    period=end
    ...    AND    sleep    1m    reason=wait xml report generated
    ...    AND    Check wireshark log for 8246_Q002_1
    ...    AND    check into idle status on wireshark    logname=${log_name_Q_002_1}
    ...    AND    check counters of related inactive status from pm file    KPI_file=CB008246_Q_inactive_related_KPI.txt    para_index=${2}

#Q002 Step 2 trigger UE2 to inactive status
#    comment    Step2: set UE2 data to inactive status
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_Q_002_2}
#    sleep    1m    reason=trigger ue inactive, and wait for ue into inactive status
##    Setup data status on UE    ue_index=${2}    status=disable
##    sleep    10s    reason=wait for ue into inactive status
#    [Teardown]    run keywords
#    ...    Stop and download Logs on gNB on master    filename=${log_name_Q_002_2}
#    ...    AND    Prepare with PM counter time to caculate    period=end
#    ...    AND    sleep    1m    reason=wait xml report generated
#    ...    AND    check into idle status on wireshark    logname=${log_name_Q_002_2}
#    ...    AND    check counters of related inactive status from pm file    KPI_file=CB008246_Q_inactive_related_KPI.txt    para_index=${2}

Q002 Step 2 UE2 make DL traffic
    comment    step3: make DL traffic 5QI7
#    upgrade gnb logs tool on VM    tool_download_path=${tool_path}
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_Q_002_2}
    # need to check duration if enough
#    to capture logs via gnb_logs tool    option=-t    tool_download_path=${tool_path}    duration=30
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_Q_002_2}
    ...    AND    Prepare with PM counter time to caculate    period=end
    ...    AND    sleep    1m    reason=wait xml report generated
    ...    AND    check rrc resume on wireshark    logname=${log_name_Q_002_2}
    ...    AND    check counters of related rrc resume of cell from pm file    KPI_file=CB008246_Q_resume_related_KPI.txt    para_index=${2}
    ...    AND    check counters of related rrc resume of bts from pm file    KPI_file=CB008246_Q_resume_related_KPI2.txt    para_index=${1}

Q002 Step 3 UE2 make UL traffic
    comment    step4: make ul traffic 5QI7
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}

Q002 Step 4 check TTI and HR KPI
    comment    step5: check TTI and DL UL HR KPI
#    ${log_files}    ${folder_name}    get logs from gnb_logs folder    tool_download_path=${tool_path}
#    ${file_name}    get_required_tti_file_name    files_list=${log_files}
#    # need to check tti
#    check value on TTI file    file_name=${epc_log_path}/${folder_name}/${file_name}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}
    Check D006 HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}

Q002 Teardown
    robot_common_operations.Common Case Teardown
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
#    Setup data status on UE    ue_index=${2}    status=enable
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_Q_002}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown





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
    ...    abs(${dict_kpis_name_value}[${E_006_BR_value_5}]+${dict_kpis_name_value}[${E_006_BR_value_4}]-${dict_kpis_name_value}[${E_006_BR_value_3}])
    Should Be True    ${result_1}<=${2}
#    Should Be Equal    ${result_1}    ${dict_kpis_name_value}[${E_006_BR_value_5}]
    ${result_2}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_6}]+${dict_kpis_name_value}[${E_006_HR_value_7}]
    Should Be True    ${result_2}>${0}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_8}]+${dict_kpis_name_value}[${E_006_HR_value_9}]
    Should Be True    ${result_3}>${0}
    ${result_4}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_10}]+${dict_kpis_name_value}[${E_006_HR_value_11}]
    Should Be True    ${result_4}>${0}

check counters of related inactive status from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    should be true    ${dict_kpis_name_value}[NG_FLOW_SUSP_RRC_CONN_INACTIVE]>=${1}

check counters of related rrc resume of cell from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_Q_legacy_DL_traffic_check_kpi_names_larger_zero_cell}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}

check counters of related rrc resume of bts from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_Q_legacy_DL_traffic_check_kpi_names_larger_zero_bts}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}

Check D006 DL HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.011}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_greater_than_or_equal_specfied}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}

check D006 BR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_BR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_BR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_BR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.12}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_BR_traffic_check_kpi_names_greater_than_or_equal_specfied}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}

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

Check D006 HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.011}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_greater_than_or_equal_specfied}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}

Check wireshark log for 8246_R005_1
    Check UL_UE_MCS_table_Capbility    logname=${log_name_R_005_1}

Check wireshark log for 8246_Q002_1
    Check UL_UE_MCS_table_Capbility    logname=${log_name_Q_002_1}

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
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}

Setup data status on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin${ue_index}
    sleep   2s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

check into idle status on wireshark
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
#    ${Code42_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42
#    Log To Console    check UEContextReleaseRequest
#    ${filtered_packets}=    filter_packets_by_expression
#    ...    filter_expression=${Code42_0}    pcap_parser=test6
#    ${ngap_radioNetwork}=    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
#    Should Contain    ${ngap_radioNetwork}    20
#    ${Code41_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 41
#    Log To Console    check UEContextReleaseCommand
#    ${filtered_packets}=    filter_packets_by_expression
#    ...    filter_expression=${Code41_0}    pcap_parser=test6
#    ${ngap_radioNetwork}=    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
#    Should Contain    ${ngap_radioNetwork}    20
#    ${count_user_inactivity}=    Get Count    ${ngap_radioNetwork}    20
#    Should Be True    ${count_user_inactivity} >= 1
    ${BCIN_filter}    catenate    (e1ap.E1AP_PDU == 0) && (e1ap.procedureCode == 13)
    ${BCIN_packets}=    filter_packets_by_expression    filter_expression=${BCIN_filter}    pcap_parser=test6
    ${uE_Activity}=    get_field_value_by_xpath    xpath=.//e1ap.uE_Activity    pcap_parser=test6
    should contain    ${uE_Activity}    1

check rrc resume on wireshark
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    # InitialULRRCMessageTransfer, RRC Resume Request 1
    ${reusme_request_1_filter}    catenate    ((f1ap.F1AP_PDU == 0)) && (nr-rrc.resumeIdentity)
    ${reusme_request_1_packets}    cap.filter_packets_by_expression    filter_expression=${reusme_request_1_filter}
    ${procedureCode}=    cap.Get Field Value By Xpath    pdml_list=${reusme_request_1_packets}
    ...                                                xpath=.//f1ap.procedureCode
#    Should Be Equal    ${procedureCode}[0]    11
    # DLRRCMessageTransfer, RRC Resume
    ${RRC_Resume_filter}    catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.mcs_Table == 1)
    ${RRC_Resume_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Resume_filter}
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    FOR    ${i}    IN    @{mcs_Table}
        should be equal    ${i}    1
    END
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6


get_required_tti_file_name
    [Arguments]    ${files_list}    ${required_file_name}=dl__all.csv
    FOR    ${file}    IN    @{files_list}
        ${status}    run keyword and return status    should contain    ${file}    ${required_file_name}
        exit for loop if    '${status}' == 'True'
        set test variable    ${file}
    END
    [Return]    ${file}

check value on TTI file
    [Arguments]    ${file_name}
    ${col_br_BLER}    ${col_br_MCS}    get_BR_BLER_MCS_value    csv_file=${file_name}
    ...    filter_name1=laMode
    ...    filter_name2=targetBLER
    ...    filter_name3=isDefaultMcsProposed
    ...    filter_name4=${SA_UE_RNTI_ID}
    ...    filter_name5=rnti
#    FOR  ${i}    IN    @{col_br_BLER}
#        should contain       ${${i}}    ${${0.15}}
#    END
    should contain       ${col_br_BLER}    0.15
    FOR  ${i}    IN    @{col_br_MCS}
        should be equal      ${${i}}    ${${0.0}}
    END

HR to BR on R007 loop
    Set Test Variable    ${R007_HR_TO_BR}    ${57}
    FOR    ${index}    IN RANGE    ${6}
        ${status}=    Run Keyword And Return Status    HR to BR on R007    pa_value=${R007_HR_TO_BR}
        Exit For Loop If    ${status} == ${True}
        ${R007_HR_TO_BR}=    Evaluate    ${R007_HR_TO_BR} + ${1}
        Set Test Variable    ${R007_HR_TO_BR}
        IF    ${index} == ${5} and ${status} == ${False}
            Fail    msg=failed
        END
    END

HR to BR on R007
    [Arguments]    ${pa_value}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${pa_value}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${pa_value}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${pa_value}
    sleep    15s
#    Comment     gnb1 cell2 PA to 57db to trigger HR to BR
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust Signal HBTE gNB_eNB_RU Attenuation
#    ...                                                                gnb1_cell2_p3_value=${57}    gnb1_cell2_p4_value=${127}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${62}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${57}
#    sleep    25s
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Run Keyword And Continue On Failure    Check counter for 8246_BR_R007_gNB1cell2
