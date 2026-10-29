*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-P

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get gnb release info
...                            AND    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True    scf_path=${scf_path}
...                                          golden_scf_name=${tl_scf_${release_info}}    golden_scf_name_gnb2=${tl_scf2_${release_info}}
#...                            AND    Setup for Env cell on-air for 2 gnb
...                            AND     Common UE parameter setup
...                            AND    Set multi DRB traffic DL UL port

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_P_002_1}    log_name_P_002_1.pcap
${log_name_P_002_2}    log_name_P_002_2.pcap
${log_name_P_003_1}    log_name_P_003_1.pcap
${log_name_P_003_2}    log_name_P_003_2.pcap
${log_name_P_003_3_1}    log_name_P_003_3_1.pcap
${log_name_P_003_3_2}    log_name_P_003_3_2.pcap
${log_name_P_003_4_1}    log_name_P_003_4_1.pcap
${log_name_P_003_4_2}    log_name_P_003_4_2.pcap
${log_name_P_003_5_1}    log_name_P_003_5_1.pcap
${log_name_P_003_5_2}    log_name_P_003_5_2.pcap
${log_name_P_003_6_1}    log_name_P_003_6_1.pcap
${log_name_P_003_6_2}    log_name_P_003_6_2.pcap
${log_name_P_009_1}    log_name_P_009_1.pcap
${log_name_P_009_2}    log_name_P_009_2.pcap
${expected_tput_dl}    1
${expected_tput_dl_5QI3}    1
${expected_tput_dl2}    1
${Send_Tput_DL}        500M
${Send_Tput_DL_5QI3}        30M
#${Send_Tput_DL_5QI4}        60M
${expected_tput_ul}    1
${expected_tput_ul_5QI3}    0.01
${expected_tput_ul2}    1
${Send_Tput_UL}        100M
${Send_Tput_UL_5QI3}        10M
#${Send_Tput_UL_5QI4}        20M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-P_Counter&KPI
${scf_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
${mdrb2_apn}    164 1670
${wap2_apn}    164 882
${X70_wap2apn_location}    959 1370
${X70_mdrb2apn_location}    959 1576

*** Test Cases ***
#[1]CB008246-P_002_scheduling_of_UE_with_HRGBR_HRNonGBR_in_DL_and_UL_upon_intra_gNB_HO
#    [Documentation]    CB008246-P
#    [Tags]    CB008246-P    CRT_TRUNK
#    [Timeout]    6 hour
#    [Setup]
#    Set Test Variable    ${rerun_counter}    ${0}
#    Wait Until Keyword Succeeds    3x    5s    Run P002 Case
#    [Teardown]    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot


[1]CB008246-P_003_scheduling_of_UE_with_HRGBR_BRGBR_in_DL_and_UL_upon_inter_gNB_HO
    [Documentation]    CB008246-P
    [Tags]    CB008246-P    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    P003 Prerequisite
    P003 Step 1 UE0 UE2 change APN
    P003 Step 2 UE0 attach
    P003 Step 3 UE2 attach preparation
    Wait Until Keyword Succeeds    3x    10s    P003 Step 4 UE2 attach
    P003 Step 5 UE0 make traffic
    P003 Step 6 UE2 make traffic
    P003 Step 7 check UE2 DL UL HR KPI
    P003 Step 8 trigger UE2 inter gnb HO from gnb2 cell 1 to gnb1 cell2
    P003 Step 9 check inter gnb HO failed and HR keep gnb2 cell1
    P003 Step 10 change PA to previous value
    P003 Step 11 UE0 stop traffic
    P003 Step 12 UE2 trigger inter gnb HO to gnb2 cell1 again
    P003 Step 13 check inter gnb HO success and HR on gnb1 cell2
    [Teardown]    P003 Teardown

[1]CB008246-P_009_scheduling_of_NSA_UE_with_HRDRB_BRDRB_in_DL_and_UL_upon_intra_gNB_ho
    [Documentation]    CB008246-P
    [Tags]    CB008246-P    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    Set Test Variable    ${rerun_counter}    ${0}
    Wait Until Keyword Succeeds    3x    5s    Run P009 case
    [Teardown]    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot

*** Keywords ***
Run P002 case
    ${rerun_counter}=    Evaluate    ${rerun_counter}+1
    Set Test Variable    ${rerun_counter}
    P002 Prerequisite
    P002 Step 1 UE2 change APN
    wait until keyword succeeds    3x    10s    P002 Step 2 UE2 attach
    P002 Step 3 UE2 make traffic
    P002 Step 4 check HR KPI
    P002 Step 5 trigger gnb1 cell2 intra gnb HO to gnb1 cell1
    P002 Step 6 check HR KPI
    [Teardown]    P002 Teardown

Run P009 case
    ${rerun_counter}=    Evaluate    ${rerun_counter}+1
    Set Test Variable    ${rerun_counter}
    P009 Prerequisite
    P009 Step 1 UE2 attach
    P009 Step 2 UE2 make traffic
    P009 Step 3 check HR KPI
    P009 Step 4 trigger gnb1 cell2 trigger NSA intra gnb HO to gnb1 cell1
    P009 Step 5 check HR KPI
    [Teardown]    P009 Teardown

P002 Prerequisite
    robot_common_operations.Common Case Setup
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_P_002}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}

P002 Step 1 UE2 change APN
    Comment    UE2 change APN to mdrb2.nokia.com
    Run Keyword If    ${rerun_counter}==1    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${zmdrb2_apn_name}
#    choice required APN on QCOM UE    usedapn=${X70_mdrb2apn_location}    ue_type=${ue_type}   ue_index=${2}

P002 Step 2 UE2 attach
    Comment    UE3 attach on gnb1 cell2
#    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Start capture gNB log on master    filename=${log_name_P_002_1}
    Comment    check scalFactorForHRGbrUl*guant_value(CN part) = value(in syslog), need to check on syslog
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_P_002_1}
    ...    AND    Check wireshark log for 8246_P002_1

P002 Step 3 UE2 make traffic
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    ...                                dl_port=${DL_UL_port_mdrb2_5QI7}
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL_5QI3}    duration=${7200}
    ...                                dl_port=${DL_UL_port_mdrb2_5QI3}
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    ...                                ul_port=${DL_UL_port_mdrb2_5QI7}
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL_5QI3}    duration=${7200}
    ...                                ul_port=${DL_UL_port_mdrb2_5QI3}

P002 Step 4 check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Run Keyword And Ignore Error
    ...    Check D006 DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}

P002 Step 5 trigger gnb1 cell2 intra gnb HO to gnb1 cell1
    Comment     gnb1 cell2 PA to 16db to trigger intra gnb HO to gnb1 cell1
    Start capture gNB log on master    filename=${log_name_P_002_2}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${26}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    sleep    30s    reason=wait HO finished
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_P_002_2}
    ...    AND    Comment    check HO message
    ...    AND    Check success message with intra gnb HO    logname=${log_name_P_002_2}

P002 Step 6 check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}
    Check D006 DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}

P002 Teardown
    robot_common_operations.Common Case Teardown
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL    iperf_port=${DL_UL_port_mdrb2_5QI7}
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL    iperf_port=${DL_UL_port_mdrb2_5QI7}
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL    iperf_port=${DL_UL_port_mdrb2_5QI3}
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL    iperf_port=${DL_UL_port_mdrb2_5QI3}
#    choice required APN on QCOM UE    usedapn=${X70_wap2apn_location}    ue_type=${ue_type}   ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}
#    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_P_002}
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_P_002}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown






P003 Prerequisite
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    Log To Console    P003 Prerequisite
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_P_003}    skip_parameter_relation_errors=False
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb2_P_003}    gnb_index=${1}    skip_parameter_relation_errors=False

P003 Step 1 UE0 UE2 change APN
    Log To Console    P003 Step 1 UE0 UE2 change APN
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${0}
    Comment    change UE0 APN to mdrb2.nokia.com
    set apn to change    usedapn=${mdrb2_apn}    ue_index=${0}
##    Switch to required APN    apn_name=mdrb2.nokia.com    ue_index=${0}    gnb_index=${0}
    QCM UE Recover Detach    ue_index=${0}    status=${0}    ue_type=${ue_type1}

    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
    Comment    change UE2 APN to mdrb2.nokia.com
#    choice required APN on QCOM UE    usedapn=${X70_mdrb2apn_location}    ue_type=${ue_type}   ue_index=${2}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${zmdrb2_apn_name}

P003 Step 2 UE0 attach
    Log To Console    P003 Step 2 UE0 attach
    comment    UE0 attach gnb1 cell2
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${15}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${0}
    Start capture gNB log on master    filename=${log_name_P_003_1}
    Attach and check power UE    ue_type=${ue_type1}    ue_index=${0}    gnb_index=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_P_003_1}

P003 Step 3 UE2 attach preparation
    Log To Console    P003 Step 3 UE2 attach preparation
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${15}    gnb2_cell1_value=${3}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}

P003 Step 4 UE2 attach
    Log To Console    P003 Step 4 UE2 attach
    Comment    UE2 SDX70 attach on gnb2 cell1
#    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Start capture gNB log on master    filename=${log_name_P_003_2}    gNB_index=${1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${1}
    Sleep    10s
    [Teardown]    Run Keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_P_003_2}    gNB_index=${1}
    ...    AND    Check wireshark log for 8246_P003_2

P003 Step 5 UE0 make traffic
    Log To Console    P003 Step 5 UE0 make traffic
    Start only DL traffic and check tput    ue_index=${0}    cellid=${2}    ue_type=${ue_type1}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    ...                                dl_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
    Start only UL traffic and check tput    ue_index=${0}    cellid=${2}    ue_type=${ue_type1}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    ...                                ul_port=${tl.ues[0].iperf_details.ssh_connection_details.port}

P003 Step 6 UE2 make traffic
    Log To Console    P003 Step 6 UE2 make traffic
    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${1}
    ...                                tput_dl_cell=${expected_tput_dl_5QI3}    dl_throughput=${Send_Tput_DL_5QI3}    duration=${7200}
    ...                                dl_port=${DL_UL_port_mdrb2_5QI3}
##    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${1}
##    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL_5QI4}    duration=${7200}
##    ...                                dl_port=${DL_UL_port_mdrb2_5QI4}
    Start only UL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${1}
    ...                                tput_ul_cell=${expected_tput_ul_5QI3}    ul_throughput=${Send_Tput_UL_5QI3}    duration=${7200}
    ...                                ul_port=${DL_UL_port_mdrb2_5QI3}
##    Start only UL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${1}
##    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL_5QI4}    duration=${7200}
##    ...                                ul_port=${DL_UL_port_mdrb2_5QI4}

P003 Step 7 check UE2 DL UL HR KPI
    Log To Console    P003 Step 7 check UE2 DL UL HR KPI
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${15}    gnb2_cell1_value=${3}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Run Keyword And Continue On Failure
    ...    Check P003 DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}    index=${1}
    Run Keyword And Continue On Failure
    ...    check P003 HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}    index=${1}

P003 Step 8 trigger UE2 inter gnb HO from gnb2 cell 1 to gnb1 cell2
    Log To Console    P003 Step 8 trigger UE2 inter gnb HO from gnb2 cell 1 to gnb1 cell2
    Comment    UE2 SDX70 trigger inter gnb HO to gnb2 cell1
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Start capture gNB log on master    filename=${log_name_P_003_3_1}
    Start capture gNB log on master    filename=${log_name_P_003_3_2}    gNB_index=${1}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${15}    gnb2_cell1_value=${7}
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${15}    gnb2_cell1_value=${10}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}
    sleep    30s    reason=wait HO finished
    [Teardown]    Run Keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_P_003_3_1}
    ...    AND    Stop and download Logs on gNB on master    filename=${log_name_P_003_3_2}    gNB_index=${1}
    ...    AND    Stop capture syslog via btslog on ute

P003 Step 9 check inter gnb HO failed and HR keep gnb2 cell1
    Log To Console    P003 Step 9 check inter gnb HO failed and HR keep gnb2 cell1
    Comment    check inter gnb HO failed due to no resource
    check inter gnb HO failed due to no resource    logname=${log_name_P_003_3_2}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${15}    gnb2_cell1_value=${3}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Run Keyword And Continue On Failure
    ...    Check P003 DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}    index=${1}
    Run Keyword And Continue On Failure
    ...    check P003 HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}    index=${1}

P003 Step 10 change PA to previous value
    Log To Console    P003 Step 10 change PA to previous value
    Comment    gnb2 cell1 PA reover to 10
    Start capture gNB log on master    filename=${log_name_P_003_5_1}
    Start capture gNB log on master    filename=${log_name_P_003_5_2}    gNB_index=${1}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${15}    gnb2_cell1_value=${3}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}
    [Teardown]    Run Keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_P_003_5_1}
    ...    AND    Stop and download Logs on gNB on master    filename=${log_name_P_003_5_2}    gNB_index=${1}

P003 Step 11 UE0 stop traffic
    Log To Console    P003 Step 11 UE0 stop traffic
    Comment    stop UE0 traffic
    Start capture gNB log on master    filename=${log_name_P_003_6_1}
    Start capture gNB log on master    filename=${log_name_P_003_6_2}    gNB_index=${1}
    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=DL
    ...    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=UL
    ...    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
    [Teardown]    Run Keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_P_003_6_1}
    ...    AND    Stop and download Logs on gNB on master    filename=${log_name_P_003_6_2}    gNB_index=${1}

P003 Step 12 UE2 trigger inter gnb HO to gnb2 cell1 again
    Log To Console    P003 Step 12 UE2 trigger inter gnb HO to gnb2 cell1 again
    Comment    UE2 SDX70 trigger inter gnb HO to gnb2 cell1 again
    Start capture gNB log on master    filename=${log_name_P_003_4_1}
    Start capture gNB log on master    filename=${log_name_P_003_4_2}    gNB_index=${1}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${15}    gnb2_cell1_value=${7}
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${15}    gnb2_cell1_value=${10}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}
    sleep    30s    reason=wait HO finished
    [Teardown]    Run Keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_P_003_4_1}
    ...    AND    Stop and download Logs on gNB on master    filename=${log_name_P_003_4_2}    gNB_index=${1}

P003 Step 13 check inter gnb HO success and HR on gnb1 cell2
    Log To Console    P003 Step 13 check inter gnb HO success and HR on gnb1 cell2
    Comment    check inter gnb HO success
    check inter gnb HO success due to another UE resource released
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Run Keyword And Continue On Failure
    ...    Check P003 DL HR traffic check dict KPI from pm file 02    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}
    Run Keyword And Continue On Failure
    ...    check P003 HR traffic check dict KPI from pm file 02    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}

P003 Teardown
    Log To Console    P003 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=7311
    Power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${0}
    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=DL
    ...    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=UL
    ...    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
    set apn to change    usedapn=${wap2_apn}    ue_index=${0}
    QCM UE Recover Detach    ue_index=${0}    status=${0}    ue_type=${ue_type1}
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL    iperf_port=${DL_UL_port_mdrb2_5QI3}
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL    iperf_port=${DL_UL_port_mdrb2_5QI3}
##    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL    iperf_port=${DL_UL_port_mdrb2_5QI4}
##    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL    iperf_port=${DL_UL_port_mdrb2_5QI4}
#    choice required APN on QCOM UE    usedapn=${X70_wap2apn_location}    ue_type=${ue_type}   ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_P_003}
    Run Keyword If    '${release_info}' == 'SBTS24R2_ENB_0000'
    ...    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_P_003_24R2}    skip_parameter_relation_errors=False
    ...    ELSE    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_P_003}    skip_parameter_relation_errors=False
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb2_P_003}    gnb_index=${1}
    Run Keyword If    '${release_info}' == 'SBTS24R2_ENB_0000'    Online modify parmeters
    ...    parameters_to_update=${PARAM_8246_recover_gnb2_P_003_24R2}    gnb_index=${1}    skip_parameter_relation_errors=False
    ...    ELSE    Online modify parmeters
    ...    parameters_to_update=${PARAM_8246_recover_gnb2_P_003}    gnb_index=${1}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    get and analysis syslog






P009 Prerequisite
    robot_common_operations.Common Case Setup
    Online modify parmeters enb    parameters_to_update=${PARAM_8246_enb1_P_009}    skip_parameter_relation_errors=False
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_P_009}    skip_parameter_relation_errors=False
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_P_009_AMF}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}    enb_cell1_value=${0}
#    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Run Keyword If    ${rerun_counter}==1    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

P009 Step 1 UE2 attach
    Comment    UE3 attach on gnb1 cell2
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Start capture gNB log on master    filename=${log_name_P_009_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}    4G_check=True
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_P_009_1}
    ...    AND    Check wireshark log for 8246_P009_1
    ...    AND    Stop capture syslog via btslog on ute

P009 Step 2 UE2 make traffic
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl2}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul2}    ul_throughput=${Send_Tput_UL}    duration=${7200}

P009 Step 3 check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Check NSA DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}
    check NSA HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}

P009 Step 4 trigger gnb1 cell2 trigger NSA intra gnb HO to gnb1 cell1
    Comment     gnb1 cell2 PA to 16db to trigger NSA intra gnb HO to gnb1 cell1
    Start capture gNB log on master    filename=${log_name_P_009_2}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${25}    enb_cell1_value=${0}
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${27}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    sleep    30s    reason=wait HO finished
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_P_009_2}
    ...    AND    Comment    check HO message
    ...    AND    Check success message with NSA intra gnb HO    logname=${log_name_P_009_2}

P009 Step 5 check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check NSA HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}
    Check NSA DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}

P009 Teardown
    robot_common_operations.Common Case Teardown
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    ue execute reboot via adb command    ue_index=${2}
#    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_P_009}
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_P_009}    skip_parameter_relation_errors=False
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_P_009_AMF}    skip_parameter_relation_errors=False
    Online modify parmeters enb    parameters_to_update=${PARAM_8246_recover_enb1_P_009}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    get and analysis syslog






Set multi DRB traffic DL UL port
    ${port_common}=    Convert To Integer    ${tl.ues[2].iperf_details.port}
    ${DL_UL_port_mdrb2_5QI7}=    Evaluate    ${port_common}+${200}
    ${DL_UL_port_mdrb2_5QI3}=    Evaluate    ${port_common}+${300}
    ${DL_UL_port_mdrb2_5QI4}=    Evaluate    ${port_common}+${400}
    Set Suite Variable    ${DL_UL_port_mdrb2_5QI7}
    Set Suite Variable    ${DL_UL_port_mdrb2_5QI3}
    Set Suite Variable    ${DL_UL_port_mdrb2_5QI4}

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

Check P003 DL HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
#    check required KPI via pm file    KPI_name_list=${CB008246_P_003_HR_traffic_check_kpi_names_value_zero}
#    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_P_003_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}
     check required KPI via pm file    KPI_name_list=${CB008246_P_003_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${150}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.023}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_greater_than_or_equal_specfied}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}

Check P003 DL HR traffic check dict KPI from pm file 02
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
#    check required KPI via pm file    KPI_name_list=${CB008246_P_003_HR_traffic_check_kpi_names_value_zero_02}
#    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_P_003_HR_traffic_check_kpi_names_value_zero_02}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}
    check required KPI via pm file    KPI_name_list=${CB008246_P_003_HR_traffic_check_kpi_names_value_zero_02}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${150}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.011}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_greater_than_or_equal_specfied}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}

Check NSA DL HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_P_009_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.011}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_greater_than_or_equal_specfied}
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
    ${result_0}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_1}]+${dict_kpis_name_value}[${E_006_HR_value_2}]
    # discrepancy is about 0.007 percent
    # change discrepancy to 0.02 percent after send pre-check mail
#    ${result_init}=    Evaluate    (${dict_kpis_name_value}[${E_006_HR_value_0}])*0.00007
    ${result_init}=    Evaluate    (${dict_kpis_name_value}[${E_006_HR_value_0}])*0.0002
    Should Be True    ${dict_kpis_name_value}[${E_006_HR_value_0}]-${result_0}<${result_init}
    ${result_1}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_4}]+${dict_kpis_name_value}[${E_006_HR_value_5}]
    Should Be Equal    ${result_1}    ${dict_kpis_name_value}[${E_006_HR_value_3}]
    ${result_2_1}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_6}]-${dict_kpis_name_value}[${E_006_HR_value_7}]
    ${result_2_2}=    Evaluate    ${result_2_1}-${dict_kpis_name_value}[${E_006_HR_value_8}]
    Should Be True    ${-50}<${result_2_2}<${50}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_9}]+${dict_kpis_name_value}[${E_006_HR_value_10}]
    Should Be True    ${result_3}>${0}
    ${result_4}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_11}]+${dict_kpis_name_value}[${E_006_HR_value_12}]
    Should Be True    ${result_4}>${0}
    ${result_5}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_13}]+${dict_kpis_name_value}[${E_006_HR_value_14}]
    Should Be True    ${result_5}>${0}

check P003 HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_P_003_UL_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_P_003_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_less_specified_value2}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${1000}
    ${result_0}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_1}]+${dict_kpis_name_value}[${E_006_HR_value_2}]
    # discrepancy is about 0.007 percent
    # change discrepancy to 0.02 percent after send pre-check mail
#    ${result_init}=    Evaluate    (${dict_kpis_name_value}[${E_006_HR_value_0}])*0.00007
    ${result_init}=    Evaluate    (${dict_kpis_name_value}[${E_006_HR_value_0}])*0.0002
    Should Be True    ${dict_kpis_name_value}[${E_006_HR_value_0}]-${result_0}<${result_init}
    ${result_1}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_4}]+${dict_kpis_name_value}[${E_006_HR_value_5}]
    Should Be Equal    ${result_1}    ${dict_kpis_name_value}[${E_006_HR_value_3}]
    ${result_2_1}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_6}]-${dict_kpis_name_value}[${E_006_HR_value_7}]
    ${result_2_2}=    Evaluate    ${result_2_1}-${dict_kpis_name_value}[${E_006_HR_value_8}]
    Should Be True    ${-50}<${result_2_2}<${50}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_9}]+${dict_kpis_name_value}[${E_006_HR_value_10}]
    Should Be True    ${result_3}>${0}
    ${result_4}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_11}]+${dict_kpis_name_value}[${E_006_HR_value_12}]
    Should Be True    ${result_4}>${0}
    ${result_5}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_13}]+${dict_kpis_name_value}[${E_006_HR_value_14}]
    Should Be True    ${result_5}>${0}

check P003 HR traffic check dict KPI from pm file 02
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_P_003_HR_traffic_check_kpi_names_less_specified_value2}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${1000}
    ${result_0}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_1}]+${dict_kpis_name_value}[${E_006_HR_value_2}]
    Should Be Equal    ${result_0}    ${dict_kpis_name_value}[${E_006_HR_value_0}]
    ${result_1}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_4}]+${dict_kpis_name_value}[${E_006_HR_value_5}]
    Should Be Equal    ${result_1}    ${dict_kpis_name_value}[${E_006_HR_value_3}]
    ${result_2_1}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_6}]-${dict_kpis_name_value}[${E_006_HR_value_7}]
    ${result_2_2}=    Evaluate    ${result_2_1}-${dict_kpis_name_value}[${E_006_HR_value_8}]
    Should Be True    ${-50}<${result_2_2}<${50}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_9}]+${dict_kpis_name_value}[${E_006_HR_value_10}]
    Should Be True    ${result_3}>${0}
    ${result_4}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_11}]+${dict_kpis_name_value}[${E_006_HR_value_12}]
    Should Be True    ${result_4}>${0}
    ${result_5}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_13}]+${dict_kpis_name_value}[${E_006_HR_value_14}]
    Should Be True    ${result_5}>${0}

check NSA HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_P_009_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_less_specified_value2}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${1000}
    ${result_0}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_1}]+${dict_kpis_name_value}[${E_006_HR_value_2}]
    # discrepancy is about 0.007 percent
    # change discrepancy to 0.02 percent after send pre-check mail
#    ${result_init}=    Evaluate    (${dict_kpis_name_value}[${E_006_HR_value_0}])*0.00007
    ${result_init}=    Evaluate    (${dict_kpis_name_value}[${E_006_HR_value_0}])*0.0002
    Should Be True    ${dict_kpis_name_value}[${E_006_HR_value_0}]-${result_0}<${result_init}
    ${result_1}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_4}]+${dict_kpis_name_value}[${E_006_HR_value_5}]
    Should Be Equal    ${result_1}    ${dict_kpis_name_value}[${E_006_HR_value_3}]
    ${result_2_1}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_6}]-${dict_kpis_name_value}[${E_006_HR_value_7}]
    ${result_2_2}=    Evaluate    ${result_2_1}-${dict_kpis_name_value}[${E_006_HR_value_8}]
    Should Be True    ${-50}<${result_2_2}<${50}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_9}]+${dict_kpis_name_value}[${E_006_HR_value_10}]
    Should Be True    ${result_3}>${0}
    ${result_4}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_11}]+${dict_kpis_name_value}[${E_006_HR_value_12}]
    Should Be True    ${result_4}>${0}
    ${result_5}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_13}]+${dict_kpis_name_value}[${E_006_HR_value_14}]
    Should Be True    ${result_5}>${0}

Check wireshark log for 8246_P002_1
    Check UL_UE_MCS_table_Capbility    logname=${log_name_P_002_1}

Check wireshark log for 8246_P003_2
    Check UL_UE_MCS_table_Capbility    logname=${log_name_P_003_2}

Check wireshark log for 8246_P009_1
    Check UL_UE_MCS_table_Capbility on NSA    logname=${log_name_P_009_1}

Check UL_UE_MCS_table_Capbility
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

Check UL_UE_MCS_table_Capbility on NSA
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${UeAddition_req_filter}    Catenate    (x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 27)
    ${UeAddition_req_packets}    cap.filter_packets_by_expression    filter_expression=${UeAddition_req_filter}
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${UeAddition_req_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    FOR    ${i}    IN    @{mcs_Table}
        should be equal    ${i}    1
    END
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${UeAddition_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${UeAddition_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${UeAddition_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${UeAddition_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${UeAddition_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6

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

Check success message with intra gnb HO
    [Arguments]    ${logname}    ${event_ID}=2
    ${cell1_physical_id}=    Get physCellId from SCF    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
    ...    gnb_index=${0}    cell_index=${1}
    ${cell2_physical_id}=    Get physCellId from SCF    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
    ...    gnb_index=${0}    cell_index=${2}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${measurement_filter}    Catenate     f1ap.procedureCode == 13 and nr-rrc.physCellId == ${cell1_physical_id}
    ${measurement_packets}    cap.filter_packets_by_expression    filter_expression=${measurement_filter}
    ${target_cell}=     cap.get_field_value_by_xpath    pdml_list=${measurement_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should not be empty    ${target_cell}
    ${UeModify_req_filter}    Catenate    f1ap.procedureCode == 7 and nr-rrc.eventId == ${event_ID} and nr-rrc.physCellId == ${cell1_physical_id}
    ${UeModify_req_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_req_filter}
    ${eventIds}=    cap.get_field_value_by_xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//nr-rrc.eventId
    should not be empty    ${eventIds}
    ${UeModify_res_filter}    Catenate    f1ap.protocolIEs == 5
    ${UeModify_res_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_res_filter}
    ${UeModify_res}    cap.get_field_value_by_xpath    pdml_list=${UeModify_res_packets}
    ...                                                xpath=.//f1ap.procedureCode
    should be equal    ${UeModify_res[0]}    7
    ${RRC_reconfig_filter}    Catenate    f1ap.procedureCode == 12
    ${RRC_reconfig_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_reconfig_filter}
    ${RRC_reconfig}    cap.get_field_value_by_xpath    pdml_list=${RRC_reconfig_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    ${rrc_TransactionIdentifier}    cap.get_field_value_by_xpath    pdml_list=${RRC_reconfig_packets}
    ...                                                xpath=.//nr-rrc.rrc_TransactionIdentifier
    should be equal    ${RRC_reconfig[0]}    ${cell1_physical_id}
    ${RRC_re_complete_filter}    Catenate    f1ap.procedureCode == 13 and nr-rrc.rrc_TransactionIdentifier == ${rrc_TransactionIdentifier[0]}
    ${RRC_re_complete_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_re_complete_filter}
    ${RRC_re_complete}    cap.get_field_value_by_xpath    pdml_list=${RRC_re_complete_packets}
    ...                                                xpath=.//f1ap.procedureCode
    should be equal    ${RRC_re_complete[0]}    13

make UE attach successful 1 times
    [Arguments]    ${filename}    ${ue_index}=${0}    ${gnb_index}=${0}    ${distname_id}=${1}
    make airplane mode to enable    ue_index=${ue_index}
    Start capture gNB log on master    filename=${filename}
    UE attach with new method    ue_index=${ue_index}    gnb_index=${gnb_index}    distname_id=${distname_id}
    [Teardown]    Stop and download Logs on gNB on master    filename=${filename}

check inter gnb HO failed due to no resource
    [Arguments]      ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${HandoverPreparationFailure_filter}=    Catenate    (xnap.procedureCode == 0) && (xnap.XnAP_PDU == 2)
    ${HandoverPreparationFailure_msg}=    cap.filter_packets_by_expression    filter_expression=${HandoverPreparationFailure_filter}
    ${radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${HandoverPreparationFailure_msg}
    ...                                                xpath=.//xnap.radioNetwork
    Should Not Be Empty    ${radioNetwork}
    FOR    ${i}    IN    @{radioNetwork}
        Should Be Equal    ${i}    4
    END

Setup status of UE data
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

check inter gnb HO success due to another UE resource released
    Check success message with inter gnb HO source    logname=${log_name_P_003_4_2}
    Check success message with inter gnb HO target    logname=${log_name_P_003_4_1}

Check success message with inter gnb HO source
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${HO_ack_filter}=     Catenate    (xnap.XnAP_PDU == 1) && (xnap.procedureCode == 0)
    ${HO_ack_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_ack_filter}
    ${HO_ack}=     cap.get_field_value_by_xpath    pdml_list=${HO_ack_packets}
    ...                                                xpath=.//xnap.XnAP_PDU
    should contain    ${HO_ack}    1
    ${UE_rel_filter}=     Catenate    (xnap.XnAP_PDU == 0) && (xnap.procedureCode == 6)
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}
    ${UE_rel}=     cap.get_field_value_by_xpath    pdml_list=${UE_rel_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${UE_rel}    6
    ${UE_rel_complete_filter}=     Catenate    (f1ap.F1AP_PDU == 1) && (f1ap.procedureCode == 6)
    ${UE_rel_complete_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_complete_filter}
    ${UE_rel_complete}=     cap.get_field_value_by_xpath    pdml_list=${UE_rel_complete_packets}
    ...                                                xpath=.//f1ap.procedureCode
    should contain    ${UE_rel_complete}    6

Check success message with inter gnb HO target
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${HO_ack_filter}=     Catenate    (xnap.XnAP_PDU == 1) && (xnap.procedureCode == 0)
    ${HO_ack_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_ack_filter}
    ${HO_ack}=     cap.get_field_value_by_xpath    pdml_list=${HO_ack_packets}
    ...                                                xpath=.//xnap.XnAP_PDU
    should contain    ${HO_ack}    1
    ${PathS_req_filter}=     Catenate    (ngap.NGAP_PDU == 0) && (ngap.procedureCode == 25)
    ${PathS_req_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PathS_req_filter}
    ${PathS_req}=     cap.get_field_value_by_xpath    pdml_list=${PathS_req_packets}
    ...                                                xpath=.//ngap.procedureCode
    should contain    ${PathS_req}    25
    ${PathS_ACK_filter}=     Catenate    (ngap.NGAP_PDU == 1) && (ngap.procedureCode == 25)
    ${PathS_ACK_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PathS_ACK_filter}
    ${PathS_ACK}=     cap.get_field_value_by_xpath    pdml_list=${PathS_ACK_packets}
    ...                                                xpath=.//ngap.procedureCode
    should contain    ${PathS_ACK}    25
    ${UE_rel_filter}=     Catenate    (xnap.XnAP_PDU == 0) && (xnap.procedureCode == 6)
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}
    ${UE_rel}=     cap.get_field_value_by_xpath    pdml_list=${UE_rel_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${UE_rel}    6

Check success message with NSA intra gnb HO
    [Arguments]    ${logname}
    ${cell1_physical_id}=    Get physCellId from SCF    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
    ...    gnb_index=${0}    cell_index=${1}
    ${cell2_physical_id}=    Get physCellId from SCF    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
    ...    gnb_index=${0}    cell_index=${2}

    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${measurement_filter}    Catenate      x2ap.procedureCode == 35 and nr-rrc.physCellId == ${cell2_physical_id}
    ...               and nr-rrc.physCellId == ${cell1_physical_id}
    ${measurement_packets}    cap.filter_packets_by_expression    filter_expression=${measurement_filter}
    ${target_cell}=     cap.Get Field Value By Xpath    pdml_list=${measurement_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should not be empty    ${target_cell}
    ${UeModify_req_filter}    Catenate    x2ap.procedureCode == 30 and  nr-rrc.physCellId == ${cell1_physical_id}
    ${UeModify_req_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_req_filter}
    ${radioNetwork}=    cap.Get Field Value By Xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//x2ap.radioNetwork
    should be equal    ${radioNetwork}[0]    0
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    FOR    ${i}    IN    @{mcs_Table}
        should be equal    ${i}    1
    END
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6
    ${UeModify_res_filter}    Catenate    x2ap.protocolIEs == 3 and x2ap.procedureCode == 30
    ${UeModify_res_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_res_filter}
    ${UeModify_res}    cap.Get Field Value By Xpath    pdml_list=${UeModify_res_packets}
    ...                                                xpath=.//x2ap.procedureCode
    should be equal    ${UeModify_res[0]}    30

Switch to required APN
    [Arguments]    ${apn_name}=${wap2.nokia.com}    ${ui_version}=${None}    ${ue_index}=${0}    ${gnb_index}=${0}
    Run Keywords
    ...    Power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[2]}    ue_index=${ue_index}
    ...    AND    Attach and check power UE    ue_type=${tl.ues[${ue_index}].capabilities[2]}    ue_index=${ue_index}    gnb_index=${gnb_index}
    CB008246_common_keywords.Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    [Teardown]    UE.UE Detach     ue_type=${tl.ues[${ue_index}].capabilities[2]}     ue_index=${ue_index}

Recover Switch to required APN
    [Arguments]    ${apn_name}=${wap2.nokia.com}     ${ui_version}=${None}       ${ue_index}=${0}    #${gnb_index}=${0}
    CB008246_common_keywords.Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    UE.UE Detach     ue_type=${tl.ues[${ue_index}].capabilities[2]}     ue_index=${ue_index}

set apn to change
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    make airplane mode to change    ue_index=${ue_index}    airplane_value=${True}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   10s
    #####Samsung S21 WA to click time cancel
#    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.APN_SETTINGS     connection=cygwin
    sleep   2s
    ${current_window}    csn.read output    connection=cygwin
    Should Contain    ${current_window}    APN_SETTINGS
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   8s
    make airplane mode to change    ue_index=${ue_index}    airplane_value=${False}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

make airplane mode to change
    [Arguments]    ${ue_index}=${0}    ${airplane_value}=${False}
    log to console    enable airplane mode UE${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${airplane_value}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}

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
    [Teardown]    csn.disconnect    connection=cygwin

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
