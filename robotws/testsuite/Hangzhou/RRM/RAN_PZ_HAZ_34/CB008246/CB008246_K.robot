*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-K

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get gnb release info
...                            AND    Get sagnb version for selenium
...                            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
#...                            AND    Set Suite Variable    ${tl_gnb2_scf_${sw_version}}    ${sw_version}_gNB2_Golden_SCF.xml
#...                            AND    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True    scf_path=${scf_path}
#...                                          golden_scf_name=${tl_gnb1_scf_${sw_version}}    golden_scf_name_gnb2=${tl_gnb2_scf_${sw_version}}
...                            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}
...                                 golden_scf_name=${tl_gnb1_scf_${sw_version}}
...                            AND    Common UE parameter setup
...                            AND    Set multi DRB traffic DL UL port

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/common_8196/taf_log.robot

*** Variables ***
${log_name_K_001_1}    log_name_K_001_1.pcap
${log_name_K_001_2}    log_name_K_001_2.pcap
${log_name_K_004_1}    log_name_K_004_1.pcap
${log_name_K_004_2}    log_name_K_004_2.pcap
${log_name_K_004_3}    log_name_K_004_3.pcap
${log_name_04444966_1}    log_name_04444966_1.pcap
${log_name_04444966_2}    log_name_04444966_2.pcap
${log_name_04444966_3}    log_name_04444966_3.pcap
${log_name_K_006_1}    log_name_K_006_1.pcap
${log_name_K_006_2}    log_name_K_006_2.pcap
${log_name_K_006_3}    log_name_K_006_3.pcap
${log_name_K_06_1}    log_name_K_06_1.pcap
${log_name_K_06_2}    log_name_K_06_2.pcap
${log_name_K_06_3}    log_name_K_06_3.pcap
${log_name_K_011_1}    log_name_K_011_1.pcap
${log_name_K_011_2}    log_name_K_011_2.pcap
${log_name_K_011_3}    log_name_K_011_3.pcap
${log_name_K_012_1}    log_name_K_012_1.pcap
${log_name_K_012_2}    log_name_K_012_2.pcap
${log_name_K_16_1}    log_name_K_16_1.pcap
${log_name_K_16_2}    log_name_K_16_2.pcap
${log_name_K_16_3}    log_name_K_16_3.pcap
${log_name_K_018_1}    log_name_K_018_1.pcap
${log_name_K_018_2}    log_name_K_018_2.pcap
${log_name_K_018_3}    log_name_K_018_3.pcap
${log_name_K_019_1}    log_name_K_019_1.pcap
${log_name_K_019_2}    log_name_K_019_2.pcap
${log_name_K_019_3}    log_name_K_019_3.pcap
${expected_tput_dl}    1
${Send_Tput_DL}        500M
${expected_tput_ul}    1
${Send_Tput_UL}        100M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-K_Counter&KPI
${tool_path}    /opt/workspace/Tool
${X70_wap2apn_location}    959 1370
${X70_mdrb2apn_location}    959 1576
${X70_mdrb1apn_location}    959 1802

@{scell_cell_index}    ${1}
@{scell_gnb_index}    ${1}

@{release_name}    SBTS24R1_ENB_0000

${l2stream3_ttitrace_K006_1}    l2stream3_ttitrace_K006_1
${l2stream3_ttitrace_K16_1}    l2stream3_ttitrace_K16_1


*** Test Cases ***
#[1]CB008246-K_004_HRnonGBR _setup_after_Scell_addition_SA_UE_support_lowSE_table_inter_gnb_DL_CA_F+T+T
#    [Documentation]    CB008246-K
#    [Tags]    CB008246-K    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    Run Keyword And Continue On Failure    K004 Prerequisite
#    Run Keyword And Continue On Failure    K004 Step 1 UE2 attach
#    Run Keyword And Continue On Failure    K004 Step 2 check logs on wireshark
#    Run Keyword And Continue On Failure    K004 Step 3 UE2 make traffic
#    Run Keyword And Continue On Failure    K004 Step 4 UE2 setup 5QI8
#    Run Keyword And Continue On Failure    K004 Step 5 check logs on wireshark
#    Run Keyword And Continue On Failure    K004 Step 6 check HR KPI
#    Run Keyword And Continue On Failure    K004 Step 7 UE2 release 5QI8
#    Run Keyword And Continue On Failure    K004 Step 8 check logs on wireshark
#    Run Keyword And Continue On Failure    K004 Step 9 check legacy KPI
#    [Teardown]    K004 Teardown


[1]CB008246-K_006_interworking_between_DL_CA_VoNR_SA_UE_support_lowSE_intra_gnb_CA_T+T+T
    [Documentation]    CB008246-K
    [Tags]    CB008246-K    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    Run Keyword And Continue On Failure    K006 Prerequisite
    Run Keyword And Continue On Failure    K006 Step 1 UE2 attach
    Run Keyword And Continue On Failure    K006 Step 2 check logs on wireshark
    Run Keyword And Continue On Failure    K006 Step 3 UE2 make traffic
    Run Keyword And Continue On Failure    K006 Step 4 check HR KPI and TTI
    Run Keyword And Continue On Failure    K006 Step 5 UE2 make VoNR
    Run Keyword And Continue On Failure    K006 Step 6 check logs on wireshark
    Run Keyword And Continue On Failure    K006 Step 7 UE2 keep VoNR 5min
    Run Keyword And Continue On Failure    K006 Step 8 check Pcell an Scell HR BR KPI
    Run Keyword And Continue On Failure    K006 Step 9 UE2 hang up VoNR
    Run Keyword And Continue On Failure    K006 Step 10 check logs on wireshark and HR KPI on Pcell and Scell
    [Teardown]    K006 Teardown


#[1]CB008246_K_06_interworking_VoNR_RAC_UE_HRDRB_qam64LowSE_gNB_support_only
#    [Documentation]    CB008246-K
#    [Tags]    CB008246-K    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    K06 Prerequisite
#    K06 Step 1 UE2 attach
#    K06 Step 2 check logs on wireshark
#    K06 Step 3 UE2 make traffic
#    K06 Step 4 check HR KPI
#    K06 Step 5 UE2 make VoNR
#    K06 Step 6 check logs on wireshark
#    K06 Step 7 UE2 keep VoNR 5min
#    K06 Step 8 check legacy KPI
#    K06 Step 9 UE2 hang up VoNR
#    K06 Step 10 check logs on wireshark and HR KPI
#    [Teardown]    K06 Teardown


[1]CB008246-K_011_HRDRB _setup_after_Scell_addition_NSA_UE_support_lowSE_table_FAF_deactivated_in_Scell_intra_gnb_DL_CA
    [Documentation]    CB008246-K
    [Tags]    CB008246-K    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    Run Keyword And Continue On Failure    K011 Prerequisite
    Run Keyword And Continue On Failure    K011 Step 1 UE2 change APN and attach
    Run Keyword And Continue On Failure    K011 Step 2 check logs on wireshark
    Run Keyword And Continue On Failure    K011 Step 3 UE2 make traffic
    Run Keyword And Continue On Failure    K011 Step 4 UE2 setup QCI8
    Run Keyword And Continue On Failure    K011 Step 5 check logs on wireshark
    Run Keyword And Continue On Failure    K011 Step 6 check release KPI on Scell and HR KPI on Pcell
    Run Keyword And Continue On Failure    K011 Step 7 UE2 release QCI8
    Run Keyword And Continue On Failure    K011 Step 8 check logs on wireshark
    [Teardown]    K011 Teardown


#[1]CB008246-K_012_A1_based_Scell_addition_after_HRDRB _setup_NSA_UE_support_lowSE_table_intra_gnb_DL_CA
#    [Documentation]    CB008246-K
#    [Tags]    CB008246-K    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    Run Keyword And Continue On Failure    K012 Prerequisite
#    Run Keyword And Continue On Failure    K012 Step 1 UE2 attach
#    Run Keyword And Continue On Failure    K012 Step 2 check logs on wireshark
#    Run Keyword And Continue On Failure    K012 Step 3 UE2 make traffic
#    Run Keyword And Continue On Failure    K012 Step 4 trigger A1
#    Run Keyword And Continue On Failure    K012 Step 5 check logs on wireshark
##    K012 Step 6 Pcell trigger HR to BR then trigger back HR and check HR BR KPI
#    Run Keyword And Continue On Failure    K012 Step 6 keep 5min and check HR KPI
#    [Teardown]    K012 Teardown


#[1]CB008246_K16_SA_Blind_Scell_Addtion_FFF_FAF_Activated_Pcell_Scells_After_nonGBR_CG_DRB_Setup_Alt15
#    [Documentation]    CB008246-K
#    [Tags]    CB008246-K    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    Run Keyword And Continue On Failure    K16 Prerequisite
#    Run Keyword And Continue On Failure    K16 Step 1 UE2 attach
#    Run Keyword And Continue On Failure    K16 Step 2 check logs on wireshark
#    Run Keyword And Continue On Failure    K16 Step 3 UE2 make traffic
#    Run Keyword And Continue On Failure    K16 Step 4 check HR KPI and TTI
#    [Teardown]    K16 Teardown


[1]CB008246-K_018_ Interworking_with_CA_in_UL_and_DFT-s-OFDM_for_the_Scell
    [Documentation]    CB008246-K
    [Tags]    CB008246-K    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    Run Keyword And Continue On Failure    K018 Prerequisite
    Run Keyword And Continue On Failure    K018 Step 1 UE2 attach
    Run Keyword And Continue On Failure    K018 Step 2 check logs on wireshark
    Run Keyword And Continue On Failure    K018 Step 3 UE2 make traffic and check HR KPI
    Run Keyword And Continue On Failure    K018 Step 4 SINR decrease on scell
    Run Keyword And Continue On Failure    K018 Step 5 check logs on wireshark
    Run Keyword And Continue On Failure    K018 Step 6 check HR BR and legacy BR on scell
    Run Keyword And Continue On Failure    K018 Step 7 SINR increase on scell
    Run Keyword And Continue On Failure    K018 Step 8 check logs on wireshark
    Run Keyword And Continue On Failure    K018 Step 9 check HR KPI on scell
    [Teardown]    K018 Teardown


#[1]CB008246-K_019_interworking_with_VONR_and_DL_GBR_admission_intra_gNB_Reestablishment_SA_UE_support_lowSE
#    [Documentation]    CB008246-K
#    [Tags]    CB008246-K    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    K019 Prerequisite
#    K019 Step 1 UE2 change APN
#    K019 Step 2 UE2 attach
#    K019 Step 3 check logs on wireshark
#    K019 Step 4 UE2 make traffic and check HR KPI
#    K019 Step 5 UE2 make VoNR and capture syslog
#    K019 Step 6 check syslog
#    K019 Step 7 check legacy KPI
#    K019 Step 8 trigger reestablishment to gnb1 cell2
#    K019 Step 9 check legacy KPI on gnb1 cell2 after reestablishment
#    K019 Step 10 hang up VoNR and capture syslog
#    K019 Step 11 check syslog
#    K019 Step 12 check HR KPI
#    [Teardown]    K019 Teardown


*** Keywords ***
K004 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=8150
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    AlarmWatchdog.add_allow_alarms    fault_id=8150
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    comment    Prerequisite: config 5QI5 and 5QI7 as BR, 5QI8 as HR, CA enabled
    put f1ap xnap plug_in package on wireshark installation path
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_004}    skip_parameter_relation_errors=False
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb2_K_004}    skip_parameter_relation_errors=False    gnb_index=${1}
    Online delete parmeters    parameters_to_update=${PARAM_8246_delete_gnb1_K_004}    timeout=${300}
    Online delete parmeters    parameters_to_update=${PARAM_8246_delete_gnb2_K_004}    timeout=${300}    gnb_index=${1}
    COAM Wait for gnb ready and cell setup
    COAM Wait for gnb ready and cell setup    gnb_index=${1}    connection=GNB_OAM_1
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    [Teardown]    Stop capture syslog via btslog on ute

K004 Step 1 UE2 attach
    comment    step1: UE2 attach on gnb1 cell1
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${zzmdrb1_apn_name}
#    choice required APN on QCOM UE    usedapn=${X70_mdrb1apn_location}    ue_type=${ue_type}   ue_index=${2}
    Start capture gNB log on master    filename=${log_name_K_004_1}
#    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_004_1}

K004 Step 2 check logs on wireshark
    comment    step3: check msc_table is not in or is 256Qam on RRC reconfig and scell addition success
    Check wireshark log for 8246_K004_1

K004 Step 3 UE2 make traffic
    comment    step3: make DL traffic on 5QI7
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb2_cell1_value=${20}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb2_cell1_value=${20}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb2_cell1_value=${20}
    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}

K004 Step 4 UE2 setup 5QI8
    comment    step4 setup HR 5QI8 via dynamic rule tool
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_K_004_2}
    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[2].imsi}    rule=ADD5QI8-PZ4-MXD
    sleep    20s    reason=wait for 5QI8 added
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_004_2}

K004 Step 5 check logs on wireshark
    comment    step5: check mcs_table RRC Reconfig message
    ...    IgNBCAUeContextModificationRequest message scell release
    ...    next RRC Reconfig message scell release
    Run Keyword And Ignore Error    Check wireshark log for 8246_K004_2    logname=${log_name_K_004_2}

K004 Step 6 check HR KPI
    comment    step6: check lowSE HR counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=xml report generated 1min
    Check HR DRB setup check dict KPI from pm file    KPI_file=CB008246_K_04_HR_DRB_setup.txt    para_index=${1}
    Check scell release check dict KPI from pm file    KPI_file=CB008246_K_04_scell_release.txt    para_index=${1}
    sleep    5min    reason=check KPIs after make traffic during 5mins
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}
    Check HR traffic GBR non GBR setup not incremented in PCEL check dict KPI from pm file
    ...    KPI_file=CB008246_K_HR_GBR_non_GBR_setup_not_incremented_in_PCEL.txt    para_index=${1}

K004 Step 7 UE2 release 5QI8
    comment    step7: release 5QI8 via dynamic rule tool
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_K_004_3}
    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[2].imsi}    rule=DEL5QI8-PZ4-MXD
    sleep    20s    reason=wait for 5QI8 released
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_004_3}

K004 Step 8 check logs on wireshark
    comment    step8: check mcs_table not in RRC Rconfig messgae, and scell not addition again
    Run Keyword And Ignore Error    Check wireshark log for 8246_K004_3    logname=${log_name_K_004_3}

K004 Step 9 check legacy KPI
    comment    step9: check legacy counters
    Prepare with PM counter time to caculate    period=end
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check legacy DL traffic check dict KPI from pm file    KPI_file=CB008246_K_legacy_KPI.txt    para_index=${1}

K004 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=7311
    AlarmWatchdog.remove_allow_alarms    fault_id=8150
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
#    choice required APN on QCOM UE    usedapn=${X70_wap2apn_location}    ue_type=${ue_type}   ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_004}    timeout=${300}
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb2_K_004}    timeout=${300}    gnb_index=${1}
    Run Keyword If    '${release_info}' == 'SBTS24R2_ENB_0000'
    ...    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_004_24R2}    skip_parameter_relation_errors=False
    ...    ELSE    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_004}    skip_parameter_relation_errors=False
    Run Keyword If    '${release_info}' == 'SBTS24R2_ENB_0000'
    ...    Online modify parmeters
    ...    parameters_to_update=${PARAM_8246_recover_gnb2_K_004_24R2}    skip_parameter_relation_errors=False    gnb_index=${1}
    ...    ELSE    Online modify parmeters
    ...    parameters_to_update=${PARAM_8246_recover_gnb2_K_004}    skip_parameter_relation_errors=False    gnb_index=${1}
    rm f1ap xnap plug_in package on wireshark installation path
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    get and analysis syslog






K006 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=8150,2923
    AlarmWatchdog.add_allow_alarms    fault_id=8150
    AlarmWatchdog.add_allow_alarms    fault_id=2923
    ${release_year}=    check_release_year    release_info=${release_info}
    IF    ${release_year} > ${24}
        execute 04444966 steps
    END
    comment    Prerequisite: config 5QI5 as BR, 5QI7 as HR, dllaMcsMax64qamLowSERANK1HR set 20, CA enabled
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_006}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

K006 Step 1 UE2 attach
    comment    step1: UE2 attach on gnb1 cell1
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Start capture gNB log on master    filename=${log_name_K_006_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    Run Keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_K_006_1}
    ...    AND    Stop capture syslog via btslog on ute

K006 Step 2 check logs on wireshark
    comment    step2: check mcs_table and beatoffset on spcell and scell of 5QI5 and 5QI7
    check mcs_table and beatoffset    logname=${log_name_K_006_1}
    ${SA_UE_RNTI_ID}    Get RNTI ID message    logname=${log_name_K_006_1}
    set test variable    ${SA_UE_RNTI_ID}

K006 Step 3 UE2 make traffic
    comment    step3: make DL traffic on 5QI7
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
##    upgrade gnb logs tool on VM    tool_download_path=${tool_path}
##    to capture logs via gnb_logs tool    option=-t    tool_download_path=${tool_path}    duration=5
#    to capture logs via gnb_logs tool    option=-C1 -T    tool_download_path=${tool_path}    duration=5
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K006_1}    nr_phy_cell_ids=55    capture_time=2s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K006_1}    nr_phy_cell_ids=51    capture_time=2s

K006 Step 4 check HR KPI and TTI
    comment    step4: check lowSE HR counters and dllaMcsMax64qamLowSERANK1HR set lower or euqal than 20 on TTI(rrmDlProposedMcs)
#    ${log_files}    ${folder_name}    get logs from gnb_logs folder    tool_download_path=${tool_path}
##    ${log_files}    ${folder_name}    get logs from gnb_logs folder from v2.67    tool_download_path=${tool_path}    distname_id=${1}
#    ${file_name}    get_required_tti_file_name    files_list=${log_files}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}
#    check value on TTI file K006_1    file_path=${epc_log_path}/${folder_name}/${file_name}    queried_filed=rrmDlProposedMcs
    check value on TTI file K006_1    file_path=${epc_log_path}/${l2stream3_ttitrace_K006_1}_dl.csv    queried_filed=dlFdSchedData.rrmDlProposedMcs

K006 Step 5 UE2 make VoNR
    comment    step5: make VoNR during middle of counter timing cycle
    Prepare with PM counter time to caculate    period=start
    sleep    1min    reason=make VoNR during middle of counter timing cycle
    Start capture gNB log on master    filename=${log_name_K_006_2}
    Step2: UE setup VoNR call on SDX70    ue_index=${2}
    sleep    20s
    check voice call status    ue_index=${2}    status=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_006_2}

K006 Step 6 check logs on wireshark
    comment    step6: check lowSE HR and lowSE BR counters, and check msc_table(qam256) and beatoffset on wireshark
    check mcs_table and beatoffset    logname=${log_name_K_006_2}    lowSE_mcs=False

K006 Step 7 UE2 keep VoNR 5min
    comment    step7: keep VoNR 5min
    Prepare with PM counter time to caculate    period=end
    sleep    5min    reason=keep VoNR 5min

K006 Step 8 check Pcell an Scell HR BR KPI
    comment    step8: pscell check BR mcs counters have counter, but HR lowSE, mcs and BR lowSE can not count
    ...    scell check HR lowSE counters have counter, but BR lowSE, HR mcs and BR mcs can not count
    sleep    1min    reason=xml report generated 1min
    check legacy DL traffic check dict KPI from pm file    KPI_file=CB008246_K_legacy_KPI.txt    para_index=${1}
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}

K006 Step 9 UE2 hang up VoNR
    comment    step9: hang up VoNR
    Start capture gNB log on master    filename=${log_name_K_006_3}
    Step3: UE hang up VoNR call    ue_index=${2}
    sleep    20s
    check voice call status    ue_index=${2}    status=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_006_3}

K006 Step 10 check logs on wireshark and HR KPI on Pcell and Scell
    comment    step10: check msc_table and beatoffset on wireshark, check HR lowSE counters on 2 cells
    check mcs_table and beatoffset    logname=${log_name_K_006_3}    legacy_mcs=False    related_cell_num=1
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}

K006 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=8150
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    Step3: UE hang up VoNR call    ue_index=${2}
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_006}    timeout=${300}
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_006}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    get and analysis syslog






K06 Prerequisite
    robot_common_operations.Common Case Setup
    comment    Prerequisite: config 5QI5 as HR, 5QI7 as HR
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_06}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

K06 Step 1 UE2 attach
    comment    step1: UE2 attach on gnb1 cell1
    Start capture gNB log on master    filename=${log_name_K_06_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_06_1}

K06 Step 2 check logs on wireshark
    comment    step2: check mcs_table
    Check UL_UE_MCS_table_Capbility 256Qam    logname=${log_name_K_06_1}

K06 Step 3 UE2 make traffic
    comment    step3: make DL traffic on 5QI7
    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}

K06 Step 4 check HR KPI
    comment    step4: check lowSE HR counters
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}

K06 Step 5 UE2 make VoNR
    comment    step5: make VoNR
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_K_06_2}
    Step2: UE setup VoNR call on SDX70    ue_index=${2}
    sleep    20s
    check voice call status    ue_index=${2}    status=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_06_2}

K06 Step 6 check logs on wireshark
    comment    step6: check lowSE HR and lowSE BR counters, and check msc_table(qam256) and beatoffset on wireshark
    check mcs_table and beatoffset    logname=${log_name_K_06_2}    lowSE_mcs=False

K06 Step 7 UE2 keep VoNR 5min
    comment    step7: keep VoNR 5min
    Prepare with PM counter time to caculate    period=end
    sleep    5min    reason=keep VoNR 5min

K06 Step 8 check legacy KPI
    comment    step8: pscell check legacy counters
    sleep    1min    reason=xml report generated 1min
    check legacy DL traffic check dict KPI from pm file    KPI_file=CB008246_K_legacy_KPI.txt    para_index=${1}

K06 Step 9 UE2 hang up VoNR
    comment    step9: hang up VoNR
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_K_06_3}
    Step3: UE hang up VoNR call    ue_index=${2}
    sleep    20s
    check voice call status    ue_index=${2}    status=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_06_3}

K06 Step 10 check logs on wireshark and HR KPI
    comment    step10: check msc_table and beatoffset on wireshark, check HR lowSE counters on 2 cells
    check mcs_table and beatoffset    logname=${log_name_K_06_3}    legacy_mcs=False    related_cell_num=1
    Prepare with PM counter time to caculate    period=end
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}

K06 Teardown
    robot_common_operations.Common Case Teardown
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    Step3: UE hang up VoNR call    ue_index=${2}
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_06}    timeout=${300}
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_06}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown








K011 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=8150
    AlarmWatchdog.add_allow_alarms    fault_id=7523
    AlarmWatchdog.add_allow_alarms    fault_id=7107
    AlarmWatchdog.add_allow_alarms    fault_id=8150
#    Start capture syslog via btslog on ute
    comment    step1: NSA QCI5 and QCI7 BR, QCI8 HR, scell not support 8246
    Online modify parmeters enb    parameters_to_update=${PARAM_8246_enb1_K_011}    skip_parameter_relation_errors=False
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_011}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
#    [Teardown]    Stop capture syslog via btslog on ute

K011 Step 1 UE2 change APN and attach
    comment    step1: UE change APN to mdrb1.nokia.com and attach on gnb1 cell1 NSA
#    choice required APN on QCOM UE    usedapn=${X70_mdrb1apn_location}    ue_type=${ue_type}   ue_index=${2}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${zzmdrb1_apn_name}
    Start capture gNB log on master    filename=${log_name_K_011_1}
#    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}    4G_check=True
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_011_1}

K011 Step 2 check logs on wireshark
    comment    step2: check scell addition success, and wiresahrk mcs_table is 256qam if config 256qam
    check mcs_table and beatoffset NSA    logname=${log_name_K_011_1}    lowSE_mcs_nsa=False

K011 Step 3 UE2 make traffic
    comment    step3: make DL traffic on QCI7
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}

K011 Step 4 UE2 setup QCI8
    comment    step4: setup QCI8 via dynamic rule tool
    Prepare with PM counter time to caculate    period=start
    Sleep    1min    reason=wait for 1m to execute action for trigger counters
    Start capture gNB log on master    filename=${log_name_K_011_2}
    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[2].imsi}    rule=ADD5QI8-PZ4-MXD
    sleep    20s    reason=wait for QCI08 added
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_011_2}

K011 Step 5 check logs on wireshark
    comment    step5: check mcs_table lowSE and beatoffset on RRC Reconfig message, check scell release on UEcontextModifyrequest message
    check HR QCI added and scell released NSA    logname=${log_name_K_011_2}

K011 Step 6 check release KPI on Scell and HR KPI on Pcell
    comment    step6: check scell release counter on Scell, and after next couunter cycle(5min) check HR lowSE counters on Pcell
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=xml report generated 1min
    Check scell release KPI from pm file    KPI_file=CB008246_K_011_HR_release_KPI.txt    para_index=${1}
    sleep    5min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}

K011 Step 7 UE2 release QCI8
    comment    step7: release QCI8 via dynamic rule tool
    Start capture gNB log on master    filename=${log_name_K_011_3}
    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[2].imsi}    rule=DEL5QI8-PZ4-MXD
    sleep    20s    reason=wait for QCI8 release
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_011_3}

K011 Step 8 check logs on wireshark
    comment    step8: check scell is not added via wiresahrk
    check qci release and scell not added back NSA    logname=${log_name_K_011_3}
    should be equal    ${erab_1}    ${erab_2}

K011 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=7523
    AlarmWatchdog.remove_allow_alarms    fault_id=7107
    AlarmWatchdog.remove_allow_alarms    fault_id=8150
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
#    choice required APN on QCOM UE    usedapn=${X70_wap2apn_location}    ue_type=${ue_type}   ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}
#    ue execute reboot via adb command    ue_index=${2}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_011}    timeout=${300}
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_011}    skip_parameter_relation_errors=False
    Online modify parmeters enb    parameters_to_update=${PARAM_8246_recover_enb1_K_011}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    get and analysis syslog







K012 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=8150
    AlarmWatchdog.add_allow_alarms    fault_id=7523
    AlarmWatchdog.add_allow_alarms    fault_id=7107
    AlarmWatchdog.add_allow_alarms    fault_id=8150
    comment    Prerequisite: NSA QCI5 BR QCI7 HR, CA bease on A1
    ${release_info}    Get sagnb release
    Online modify parmeters enb    parameters_to_update=${PARAM_8246_enb1_K_012}    skip_parameter_relation_errors=False
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_012_amf}    skip_parameter_relation_errors=False
    run keyword if    '${release_info}' == '${release_name}[0]'
    ...    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_012_24R1}    skip_parameter_relation_errors=False
    ...    ELSE    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_012}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${15}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

K012 Step 1 UE2 attach
    comment    step1: UE2 attach on gnb1 cell1 NSA
    Start capture gNB log on master    filename=${log_name_K_012_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}    4G_check=True
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_012_1}

K012 Step 2 check logs on wireshark
    comment    step2: check NSA sgnbaddtion, mcs_table is lowSE, and beatoffset
    check sgnbaddition and mcs_table and beatoffset NSA    logname=${log_name_K_012_1}

K012 Step 3 UE2 make traffic
    comment    step3: make DL traffic QCI7
    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}

K012 Step 4 trigger A1
    comment    step4: trigger A1
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Start capture gNB log on master    filename=${log_name_K_012_2}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    sleep    20s    reason=wait for trigger A1 scell added
    [Teardown]    Run Keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_K_012_2}
    ...    AND    Stop capture syslog via btslog on ute

K012 Step 5 check logs on wireshark
    comment    step5: check measurement report and scell addition success, lowSE mcs_table via wireshark
    check scell added success via A1 NSA    logname=${log_name_K_012_2}

K012 Step 6 Pcell trigger HR to BR then trigger back HR and check HR BR KPI
    comment    step6: Pcell trigger HR to BR, then back HR
    ...    check Pcell and Scell HR lowSE counters to BR lowSE counters, then back HR lowSE counters respectively
    comment     gnb1 cell1 PA to 43db cell2 PA to 57db to trigger HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${43}    gnb1_cell2_value=${55}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait BR switch to HR completely and xml report generated
    check if DL HR swtich to BR success    para_index=${1}
    # need check
    Run Keyword And Ignore Error    check DL BR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_BR_KPI.txt    para_index=${1}
    Run Keyword And Ignore Error    check DL BR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_BR_KPI.txt    para_index=${2}
    Comment     gnb1 cell1 gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait BR switch to HR completely and xml report generated
    check if DL BR swtich to HR success    para_index=${1}
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}

K012 Step 6 keep 5min and check HR KPI
    comment    step6: keep 5-10min
    ...    Pcell and Scell HR lowSE counters respectively
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait HR completely and xml report generated
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}

K012 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=7523
    AlarmWatchdog.remove_allow_alarms    fault_id=7107
    AlarmWatchdog.remove_allow_alarms    fault_id=8150
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_012}    timeout=${300}
    ${release_info}    Get sagnb release
    run keyword if    '${release_info}' == '${release_name}[0]'
    ...    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_012_24R1}    skip_parameter_relation_errors=False
    ...    ELSE    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_012}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    recover enb mme ip
#    Online modify parmeters enb    parameters_to_update=${PARAM_8246_recover_enb1_K_012}    skip_parameter_relation_errors=False
#    ue execute reboot via adb command    ue_index=${2}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    get and analysis syslog





K16 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=8150
    AlarmWatchdog.add_allow_alarms    fault_id=8150
    comment    Prerequisite: config 5QI5 as BR, 5QI7 as HR, CA enabled, cell1 cell2 config actUlCgType2 nrDrbUlCgDN
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_16}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

K16 Step 1 UE2 attach
    comment    step1: UE2 attach on gnb1 cell1
    Start capture gNB log on master    filename=${log_name_K_16_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_16_1}

K16 Step 2 check logs on wireshark
    comment    step2: check mcs_table on spcell and scell of 5QI5 and 5QI7
    # Because there is no uplink CA, there is no information about IEs such as betaOffsetACKIndex1.
    # Information about IEs such as betaOffsetACKIndex1 is only available during uplink
    check UE_MCS_table_Capbility qam64LowSE table    logname=${log_name_K_16_1}

K16 Step 3 UE2 make traffic
    comment    step3: make DL traffic on 5QI7
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    Start only UL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
##    upgrade gnb logs tool on VM    tool_download_path=${tool_path}
##    to capture logs via gnb_logs tool    option=-t    tool_download_path=${tool_path}    duration=5
#    to capture logs via gnb_logs tool    option=-C1 -T    tool_download_path=${tool_path}    duration=5
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K16_1}    nr_phy_cell_ids=55    capture_time=2s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K16_1}    nr_phy_cell_ids=51    capture_time=2s

K16 Step 4 check HR KPI and TTI
    comment    step4: check lowSE HR counters and dllaMcsMax64qamLowSERANK1HR and ullaMcsMax64qamLowSERANK1HR lower or euqal than 20 on TTI
#    ${log_files}    ${folder_name}    get logs from gnb_logs folder    tool_download_path=${tool_path}
#    ${dl_file_name}    get_required_tti_file_name    files_list=${log_files}
#    ${ul_file_name}    get_required_tti_file_name    files_list=${log_files}    required_file_name=ul__all.csv
#    check value on TTI file K16_1    file_path=${epc_log_path}/${folder_name}/${dl_file_name}    queried_filed=rrmDlProposedMcs
    check value on TTI file K16_1    file_path=${epc_log_path}/${l2stream3_ttitrace_K16_1}_dl.csv    queried_filed=dlFdSchedData.rrmDlProposedMcs
#    check value on TTI file K16_1    file_path=${epc_log_path}/${folder_name}/${ul_file_name}    queried_filed=rrmUlProposedMcs
    check value on TTI file K16_1    file_path=${epc_log_path}/${l2stream3_ttitrace_K16_1}_ul.csv    queried_filed=ulFdSchedData.rrmUlProposedMcs
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    # pcell: cell1, scell: cell2
    # DL HR lowSE counters, UL legacy counters on pcell and scell
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}
    check UL CG traffic check dict KPI from pm file    KPI_file=CB008246_I_007_HR_KPI.txt    para_index=${1}
    # but scell UL not increased, due to scell no traffic, value of sCellOperationalMode is dlOnly, CA TDD+TDD is not support for ul
#    check UL CG traffic check dict KPI from pm file    KPI_file=CB008246_I_007_HR_KPI.txt    para_index=${2}

K16 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=8150
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Adjust HBTE gNB_eNB_RU Attenuation
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#    Start capture syslog via btslog on ute
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_16}    timeout=${300}
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_16}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
#    Stop capture syslog via btslog on ute
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    get and analysis syslog






K018 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=8150
    AlarmWatchdog.add_allow_alarms    fault_id=8150
    comment    Prerequisite: 5QI7 HR, pcell cell2 actUlDftSOfdm false, scell cell1 actUlDftSOfdm true
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_018}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

K018 Step 1 UE2 attach
    comment    step1: UE2 attach on gnb1 cell2
    Start capture gNB log on master    filename=${log_name_K_018_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_018_1}

K018 Step 2 check logs on wireshark
    comment    step2: check mcs_table lowSE and beatoffset on RRC reconfiguration message via wireshark
    check mcs_table and beatoffset    logname=${log_name_K_018_1}    index1=11

K018 Step 3 UE2 make traffic and check HR KPI
    comment    step3: make UL traffic, check HR lowSE counters
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}

    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    # HR lowSE counters will be checked when RSRP good
    Run Keyword And Ignore Error    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}
    [Teardown]    Stop capture syslog via btslog on ute

K018 Step 4 SINR decrease on scell
    comment    step4: decrease RSRP of scell, gnb1 cell1 PA to 42db to trigger SINR decrease to below value of ulTransPrecodeOnSinrThresh(1.5)
    Start capture gNB log on master    filename=${log_name_K_018_2}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${42}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    sleep    20s
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_018_2}

K018 Step 5 check logs on wireshark
    comment    step5: check mcs_table 256Qam on RRC Reconfig via wireshark
    Run Keyword And Ignore Error    check mcs_table and beatoffset    logname=${log_name_K_018_2}    lowSE_mcs=False

K018 Step 6 check HR BR and legacy BR on scell
    comment    step6: wait 5min, check lowSE HR and BR counters not counting on scell,
    ...    and check 64Qam counters on scell(due to DFT)  ulTransPrecodeOffSinrThresh
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    # need modify keyword and txt
    # pcell: cell2
    # scell: cell1
    # when SINR < ulTransPrecodeOnSinrThresh scell check legacy counters, when SINR > ulTransPrecodeOffSinrThresh scell check HR lowSE counters
    Run Keyword And Ignore Error    check UL CG traffic check dict KPI from pm file    KPI_file=CB008246_I_007_HR_KPI.txt    para_index=${1}
#    Run Keyword And Ignore Error    check UL legacy BR traffic check dict KPI from pm file    KPI_file=CB008246_I_007_BR_KPI.txt    para_index=${1}
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}

K018 Step 7 SINR increase on scell
    comment    step7: increase RSRP of scell, gnb1 cell1 PA to 0db to trigger SINR increase to above value of ulTransPrecodeOffSinrThresh(3.5)
    Start capture gNB log on master    filename=${log_name_K_018_3}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    sleep    30s
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_018_3}

K018 Step 8 check logs on wireshark
    comment    step8: check mcs_table lowSE and beatoffset on RRC Reconfiguration message via wireshark
    Run Keyword And Ignore Error    check mcs_table and beatoffset    logname=${log_name_K_018_3}    legacy_mcs=False

K018 Step 9 check HR KPI on scell
    comment    step9: check HR lowSE HR counters on scell
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}
    Run Keyword And Ignore Error    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}
#    Run Keyword And Ignore Error    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}
#    Run Keyword And Ignore Error    check UL legacy traffic check dict KPI from pm file    KPI_file=CB008246_I_007_HR_KPI.txt    para_index=${1}

K018 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=8150
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_018}    timeout=${300}
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_018}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    get and analysis syslog






K019 Prerequisite
    robot_common_operations.Common Case Setup
    comment    Prerequisite: 5QI7 3 HR
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_019}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}

K019 Step 1 UE2 change APN
    comment    UE2 change APN to mdrb2.nokia.com
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${zmdrb2_apn_name}

K019 Step 2 UE2 attach
    comment    UE2 attach on gnb1 cell1
    Start capture gNB log on master    filename=${log_name_K_019_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_019_1}

K019 Step 3 check logs on wireshark
    comment    step 3: check ue support lowSE table
    Check UL_UE_MCS_table_Capbility   logname=${log_name_K_019_1}

K019 Step 4 UE2 make traffic and check HR KPI
    comment    step4: make DL traffic 5QI7 and check DL HR KPI
    Start only DL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    ...                                dl_port=${DL_UL_port_mdrb2_5QI7}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}

K019 Step 5 UE2 make VoNR and capture syslog
    comment    step5: make VoNR call and cpature syslog
    Start capture gNB log on master    filename=${log_name_K_019_2}
    capture syslog for voice call    is_make_voice_call=${True}    ue_index=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_019_2}

K019 Step 6 check syslog
    comment    step6: check if changed value with scalFactorForHRGbrDl(1.1*100)
    ...    1)setup vonr:
    ...    is VONR use default ScaleFactorForGbrDLUL: DL=100, UL=100;
    ...    Update scaleFactorForGbr: DL from 110 to 100, UL from 110 to 100
    ...    2)release vonr:
    ...    scaleFactorForHRGbr: DL=110, UL=110;
    ...    Update scaleFactorForGbr: DL from 100 to 110, UL from 100 to 110
    ${log_files}    ${current_time}=    get logs from gnb_logs folder    tool_download_path=/opt/workspace/Tool    type=BTS_SYSLOG
    ${dl_num}    ${ul_num}=    get_scalefactorforhrgbr_dl_ul_num
    ...    log_path=${epc_log_path}/${current_time}/${log_files}[0]    is_vonr_setup=${True}
    Should Be Equal As Integers    ${dl_num}    ${100}
    Should Be Equal As Integers    ${ul_num}    ${100}

K019 Step 7 check legacy KPI
    comment    step7: check legacy KPI, legacy counter increase
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check legacy DL traffic check dict KPI from pm file    KPI_file=CB008246_K_legacy_KPI.txt    para_index=${1}

K019 Step 8 trigger reestablishment to gnb1 cell2
    comment    step8: trigger reestablishment to gnb1 cell2
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${127}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${127}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${127}    gnb1_cell2_value=${0}

K019 Step 9 check legacy KPI on gnb1 cell2 after reestablishment
    comment    step9: check legacy KPI on gnb1 cell2 after reestablishment
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check legacy DL traffic check dict KPI from pm file    KPI_file=CB008246_K_legacy_KPI.txt    para_index=${2}

K019 Step 10 hang up VoNR and capture syslog
    comment    step10: hang up VoNR and capture syslog
    check voice call status    ue_index=${2}    status=${2}
    Start capture gNB log on master    filename=${log_name_K_019_3}
    capture syslog for voice call    is_make_voice_call=${False}    ue_index=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_019_3}

K019 Step 11 check syslog
    comment    step6: check if changed value with scalFactorForHRGbrDl(1.1*100)
    ...    1)setup vonr:
    ...    is VONR use default ScaleFactorForGbrDLUL: DL=100, UL=100;
    ...    Update scaleFactorForGbr: DL from 110 to 100, UL from 110 to 100
    ...    2)release vonr:
    ...    scaleFactorForHRGbr: DL=110, UL=110;
    ...    Update scaleFactorForGbr: DL from 100 to 110, UL from 100 to 110
    ${log_files}    ${current_time}=    get logs from gnb_logs folder    tool_download_path=/opt/workspace/Tool    type=BTS_SYSLOG
    ${dl_num}    ${ul_num}=    get_scalefactorforhrgbr_dl_ul_num
    ...    log_path=${epc_log_path}/${current_time}/${log_files}[0]    is_vonr_setup=${False}
    ${scalFactorForHRGbrUl}=    Get value of parameter from SCF file    golden_scf_name=${tl_gnb1_scf_${sw_version}}
    ...    dist_name=${NRPUSCHHRLA_GNB1}    p_name=scalFactorForHRGbrUl    scf_path=${scf_path}
    ${scalFactorForHRGbrDl}=    Get value of parameter from SCF file    golden_scf_name=${tl_gnb1_scf_${sw_version}}
    ...    dist_name=${NRPDSCHHRLA_GNB1}    p_name=scalFactorForHRGbrDl    scf_path=${scf_path}
    Should Be Equal As Integers    ${dl_num}    ${scalFactorForHRGbrDl}
    Should Be Equal As Integers    ${ul_num}    ${scalFactorForHRGbrUl}

K019 Step 12 check HR KPI
    comment    step12: check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Check DL HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}

K019 Teardown
    robot_common_operations.Common Case Teardown
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL    iperf_port=${DL_UL_port_mdrb2_5QI7}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_019}
    Run Keyword If    '${release_info}' == 'SBTS24R2_ENB_0000'
    ...    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_019_24R2}    skip_parameter_relation_errors=False
    ...    ELSE    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_019}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown





execute 04444966 steps
    online add list parameter
    COAM Wait for gnb ready and cell setup
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_04444966}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    pdu session setup 5qi5 first then 5qi7
    Check wireshark log for PDUSessionResourceModifyRequest ok    logname=${log_name_04444966_3}
    Check wireshark log for PDUSessionResourceModifyResponse ok    logname=${log_name_04444966_3}
    [Teardown]    Run Keywords
    ...    online recover delete and add list parameter
    ...    AND    COAM Wait for gnb ready and cell setup
    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_8246_recover_gnb1_04444966}    skip_parameter_relation_errors=False
    ...    AND    COAM Wait for gnb ready and cell setup

pdu session setup 5qi5 first then 5qi7
    Switch QCOM airplane mode status on    ue_index=${2}    airplane_enable=${True}
    data disable
    Switch QCOM airplane mode status on    ue_index=${2}    airplane_enable=${False}
    pdu session setup 5qi5 first
    pdu session setup 5qi7 then
    voice call make
    [Teardown]    Switch QCOM airplane mode status on    ue_index=${2}    airplane_enable=${False}

data disable
    Connect to control pc via cygwin    ue_index=${2}
    operate data button on SDX70    ue_index=${2}    status=disable
    Sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

pdu session setup 5qi5 first
    Start capture gNB log on master    filename=${log_name_04444966_1}
    Switch QCOM airplane mode status on    ue_index=${2}    airplane_enable=${True}
    Sleep    2s
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_04444966_1}

pdu session setup 5qi7 then
    Start capture gNB log on master    filename=${log_name_04444966_2}
    Connect to control pc via cygwin    ue_index=${2}
    # data enable
    operate data button on SDX70    ue_index=${2}    status=enable
    [Teardown]    Run Keywords
    ...    csn.disconnect    connection=cygwin
    ...    AND    Stop and download Logs on gNB on master    filename=${log_name_04444966_2}

voice call make
    Start capture gNB log on master    filename=${log_name_04444966_3}
    # make voice
    Step2: UE setup VoNR call on SDX70    ue_index=${2}
    sleep    20s
    check voice call status    ue_index=${2}    status=${2}
    [Teardown]    Run Keywords    Stop and download Logs on gNB on master    filename=${log_name_04444966_3}
    ...    AND    Step3: UE hang up VoNR call    ue_index=${2}
    ...    AND    sleep    20s
    ...    AND    check voice call status    ue_index=${2}    status=${0}

Check wireshark log for PDUSessionResourceModifyRequest ok
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.fiveQI==1
    Log To Console    check PDUSessionResourceModifyRequest
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${Code26_0}    pcap_parser=test6
    ${5qi}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
#    Should Be Equal    ${5qi[0]}    1
    Should Contain    ${5qi}    1

Check wireshark log for PDUSessionResourceModifyResponse ok
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${criticality} =    get_field_value_by_xpath    xpath=.//ngap.criticality    pcap_parser=test6
#    Should Be Equal    ${criticality[0]}    0
    Should Contain    ${criticality}    0

#    Check EIAP log name    logname=${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check RRCreconfigurecomplete
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${ULRRCMessageTransfer}
    ${criticality} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.criticality
#    Should Be Equal    ${criticality[0]}    1
    Should Contain    ${criticality}    1

capture syslog for voice call
    [Arguments]    ${gnb_logs_tool_path}=/opt/workspace/Tool/gnb_logs/    ${is_make_voice_call}=${True}
    ...    ${ue_index}=${0}    ${gnb_index}=${0}    ${timeout}=${120}
    ${call_result}=    exec_gnb_logs_tool_for_voice_call
    ...    ute_ip=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ute_username=${tl.test_pc.default_ssh_connection_details.username}
    ...    ute_password=${tl.test_pc.default_ssh_connection_details.password}
    ...    gnb_logs_tool_path=${gnb_logs_tool_path}
    ...    gnb_ip=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    connection=ue_${ue_index}_cygwin
    ...    is_make_voice_call=${is_make_voice_call}
    ...    ue_index=${ue_index}
    ...    timeout=${timeout}
    should be equal    ${call_result}    ${True}

Set multi DRB traffic DL UL port
    ${port_common}=    Convert To Integer    ${tl.ues[2].iperf_details.port}
    ${DL_UL_port_mdrb2_5QI7}=    Evaluate    ${port_common}+${200}
    ${DL_UL_port_mdrb2_5QI3}=    Evaluate    ${port_common}+${300}
    ${DL_UL_port_mdrb2_5QI4}=    Evaluate    ${port_common}+${400}
    Set Suite Variable    ${DL_UL_port_mdrb2_5QI7}
    Set Suite Variable    ${DL_UL_port_mdrb2_5QI3}
    Set Suite Variable    ${DL_UL_port_mdrb2_5QI4}

check legacy DL traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_K_legacy_DL_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_K_legacy_DL_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_K_legacy_DL_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.011}
    ${result_1}    evaluate
    ...    ${dict_kpis_name_value}[${K_legacy_00}]+${dict_kpis_name_value}[${K_legacy_01}]
    should be true    ${result_1}>${0}
    ${result_2}    evaluate    abs(${dict_kpis_name_value}[${K_legacy_04}])
    should be true    ${0}<=${result_2}<${50}

Check scell release KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    comment    in this case, 1 scell is released
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_K_011_scell_release_check_kpi_names_value}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${1}

Check HR DRB setup check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_K_04_HR_DRB_setup}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${1}

Check scell release check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_K_04_scell_release}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${1}

Check HR traffic GBR non GBR setup not incremented in PCEL check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_K_04_HR_GBR_non_GBR_setup_not_incremented_in_PCEL}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}

Check DL HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_K_011_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.011}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_greater_than_or_equal_specfied}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}

check DL BR traffic check dict KPI from pm file
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

check if DL HR swtich to BR success
    [Arguments]    ${para_index}=${2}
    ${dict_HR_to_BR_check}=    get dict kpi from pm file   KPI_file=CB008246_DL_KPI_BR_HR_switch.txt    para_index=${para_index}
    # PUSCH_INITX_LOWSE_BRDRB>0 and PUSCH_INITX_LOWSE_HRD_PRFL1+PUSCH_INITX_LOWSE_HRD_PRFL2=0 check swtich to BR
    ${status_0}=    Evaluate    ${dict_HR_to_BR_check}[PDSCH_INITX_LOWSE_HRD_PRFL1] + ${dict_HR_to_BR_check}[PDSCH_INITX_LOWSE_HRD_PRFL2]
    Should Be Equal    ${status_0}    ${0}
    ${status_1}=    Evaluate    ${dict_HR_to_BR_check}[PDSCH_INITX_LOWSE_BR]>0
    Should Be Equal    ${status_1}    ${True}

check if DL BR swtich to HR success
    [Arguments]    ${para_index}=${2}
    ${dict_HR_to_BR_check}=    get dict kpi from pm file   KPI_file=CB008246_DL_KPI_BR_HR_switch.txt    para_index=${para_index}
    # PUSCH_INITX_LOWSE_BRDRB=0 and PUSCH_INITX_LOWSE_HRD_PRFL1+PUSCH_INITX_LOWSE_HRD_PRFL2>0 check swtich to HR
    ${status_0}=    Evaluate    ${dict_HR_to_BR_check}[PDSCH_INITX_LOWSE_HRD_PRFL1] + ${dict_HR_to_BR_check}[PDSCH_INITX_LOWSE_HRD_PRFL2]
    Should Be True    ${status_0}>${0}
    ${status_1}=    Evaluate    ${dict_HR_to_BR_check}[PDSCH_INITX_LOWSE_BR] == ${0}
    Should Be Equal    ${status_1}    ${True}

check KPI on pm file
    get kpi from per pm file

check UL legacy traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}
    ${result_0}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${I_007_HR_value_1}]+${dict_kpis_name_value}[${I_007_HR_value_2}]-${dict_kpis_name_value}[${I_007_HR_value_0}])
    Should Be True    ${result_0}<=${2}
    ${result_1}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${I_007_HR_value_4}]+${dict_kpis_name_value}[${I_007_HR_value_5}]-${dict_kpis_name_value}[${I_007_HR_value_3}])
    Should Be True    ${result_1}<=${2}
    ${result_2_1}=    Evaluate    ${dict_kpis_name_value}[${I_007_HR_value_7}]-${dict_kpis_name_value}[${I_007_HR_value_8}]
    ${result_2_2}=    Evaluate    ${result_2_1}-${dict_kpis_name_value}[${I_007_HR_value_6}]
    Should Be True    ${-50}<${result_2_2}<${50}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${I_007_HR_value_9}]+${dict_kpis_name_value}[${I_007_HR_value_10}]
    Should Be True    ${result_3}>${0}

check UL CG traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}
    ${result_0}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${I_007_HR_value_1}]+${dict_kpis_name_value}[${I_007_HR_value_2}]-${dict_kpis_name_value}[${I_007_HR_value_0}])
    Should Be True    ${result_0}<=${50}
    ${result_1}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${I_007_HR_value_4}]+${dict_kpis_name_value}[${I_007_HR_value_5}]-${dict_kpis_name_value}[${I_007_HR_value_3}])
    Should Be True    ${result_1}<=${2}
    ${result_2_1}=    Evaluate    ${dict_kpis_name_value}[${I_007_HR_value_7}]-${dict_kpis_name_value}[${I_007_HR_value_8}]
    ${result_2_2}=    Evaluate    ${result_2_1}-${dict_kpis_name_value}[${I_007_HR_value_6}]
    Should Be True    ${-50}<${result_2_2}<${50}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${I_007_HR_value_9}]+${dict_kpis_name_value}[${I_007_HR_value_10}]
    Should Be True    ${result_3}>${0}

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

check UL legacy BR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_BR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_BR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_BR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.11}
    ${result_0}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${I_007_BR_value_1}]+${dict_kpis_name_value}[${I_007_BR_value_2}]-${dict_kpis_name_value}[${I_007_BR_value_0}])
    Should Be True    ${result_0}<=${2}
    ${result_1}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${I_007_BR_value_4}]-${dict_kpis_name_value}[${I_007_BR_value_5}]-${dict_kpis_name_value}[${I_007_BR_value_3}])
#    Should Be True    ${result_1}<=${2}
    ${result_2}=    Evaluate    ${dict_kpis_name_value}[${I_007_BR_value_6}]+${dict_kpis_name_value}[${I_007_BR_value_7}]
    Should Be True    ${result_2}>${0}

check KPI
    check KPI with required name    KPI_name_list=${CB008246_E_006_kpi_names_in_range}    check_field=in_range
    check KPI with required name    KPI_name_list=${CB008246_E_006_kpi_names_value_zero}    check_field=zero
    check KPI with required name    KPI_name_list=${CB008246_E_006_kpi_names_larger_zero}    check_field=larger_zero
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_1}
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_2}
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_3}
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_4}

Check wireshark log for 8246_K004_1
    Check UEContextModificationResponse has physcellid on PrimegNB
    ...    logname=${log_name_K_004_1}
    ...    pcell_index=${1}    Primegnb_index=${0}
    ...    scell_index_list=${scell_cell_index}    extgnb_index_list=${scell_gnb_index}
    ...    UEContextModificationResponse_nums=${4}
    Check UE_MCS_table_Capbility without_ul-64QAM-MCS-TableAlt    logname=${log_name_K_004_1}

Check UL_UE_MCS_table_Capbility 256Qam
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

Check wireshark log for 8246_K004_2
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check mcs_table RRC Reconfig message
    check IgNBCAUeContextModificationRequest message scell release
    check next RRC Reconfig message scell release

check mcs_table RRC Reconfig message
    ${filter_expression}=     Catenate    nokiaf1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

check IgNBCAUeContextModificationRequest message scell release
    ${filter_expression}=     Catenate    nokiaf1ap.procedureCode == 14 and nokiaf1ap.IgNB_CA_SCell_ToBeRemoved_List == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${procedureCode}=     cap.Get Field Value By Xpath    xpath=.//nokiaf1ap.procedureCode    pcap_parser=test6
    Should Contain    ${procedureCode}    14

check next RRC Reconfig message scell release
    ${filter_expression}=     Catenate    nokiaf1ap.procedureCode == 12 and nr-rrc.sCellToReleaseList == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${SCellIndex}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.SCellIndex    pcap_parser=test6
    Should Contain    ${SCellIndex}    1

Check UL_UE_MCS_table_Capbility
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

check mcs_table and beatoffset
    [Arguments]    ${logname}    ${legacy_mcs}=True    ${lowSE_mcs}=True    ${related_cell_num}=2    ${index1}=10
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    run keyword if    '${legacy_mcs}' == 'True'    check legacy mcs_table and beatoffset on wireshark    index1=${index1}
    run keyword if    '${lowSE_mcs}' == 'True'    check lowSE table and beatoffset on wireshark    related_cell_num=${related_cell_num}

check UE_MCS_table_Capbility qam64LowSE table
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.mcs_Table == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Contain    ${nr_rrc_mcs_Table}    1

check legacy mcs_table and beatoffset on wireshark
    [Arguments]    ${index1}=10
    # DLRRCMessageTransfer, RRC Reconfiguration, DL NAS transport, PDU session establishment accept
    ${legacy_beatoffset_filter}    catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.betaOffsetACK_Index2 == 8)
    ${legacy_beatoffset_packets}    cap.filter_packets_by_expression    filter_expression=${legacy_beatoffset_filter}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${legacy_beatoffset_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${legacy_beatoffset_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${legacy_beatoffset_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${legacy_beatoffset_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${legacy_beatoffset_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Run Keyword If    '${release_info}' == 'SBTS24R2_ENB_0000'
    ...    Should Be Equal    ${betaOffsetACK_Index1}[0]    11
    ...    ELSE    Should Be Equal    ${betaOffsetACK_Index1}[0]    ${index1}
    Should Be Equal    ${betaOffsetACK_Index2}[0]    8
    Should Be Equal    ${betaOffsetACK_Index3}[0]    6
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    13
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    13

check lowSE table and beatoffset on wireshark
    [Arguments]    ${related_cell_num}=2
    # DLRRCMessageTransfer, RRC Reconfiguration, DL NAS transport, PDU session establishment accept
    ${pdu_s_e_accept_filter}    catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.mcs_Table == 1)
    ${pdu_s_e_accept_packets}    cap.filter_packets_by_expression    filter_expression=${pdu_s_e_accept_filter}
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    FOR    ${i}    IN    @{mcs_Table}
        should be equal    ${i}    1
    END
    ${num}    get length    ${mcs_Table}
    # ca_cell_num = pcell + scell, +1 due to DL+UL for one Pcell
    ${total_num}    evaluate    ${related_cell_num}+1
    should be equal as integers    ${num}    ${total_num}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6

check mcs_table and beatoffset NSA
    [Arguments]    ${logname}    ${legacy_mcs_nsa}=True    ${lowSE_mcs_nsa}=True    ${related_cell_num}=2
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    run keyword if    '${legacy_mcs_nsa}' == 'True'    check legacy mcs_table and beatoffset NSA on wireshark
    run keyword if    '${lowSE_mcs_nsa}' == 'True'    check lowSE table and beatoffset NSA on wireshark    related_cell_num=${related_cell_num}

check legacy mcs_table and beatoffset NSA on wireshark
    # SgNBAdditionRequestAcknowledge, RRC Reconfiguration
    ${UeAddition_req_filter}    Catenate    (x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 27)
    ${UeAddition_req_packets}    cap.filter_packets_by_expression    filter_expression=${UeAddition_req_filter}
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
    Should Be Equal    ${betaOffsetACK_Index1}[0]    11
    Should Be Equal    ${betaOffsetACK_Index2}[0]    8
    Should Be Equal    ${betaOffsetACK_Index3}[0]    6
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    13
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    13

check lowSE table and beatoffset NSA on wireshark
    [Arguments]    ${related_cell_num}=2
    # DLRRCMessageTransfer, RRC Reconfiguration, DL NAS transport, PDU session establishment accept
    ${pdu_s_e_accept_filter}    catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.mcs_Table == 1)
    ${pdu_s_e_accept_packets}    cap.filter_packets_by_expression    filter_expression=${pdu_s_e_accept_filter}
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    FOR    ${i}    IN    @{mcs_Table}
        should be equal    ${i}    1
    END
    ${num}    get length    ${mcs_Table}
    # ca_cell_num = pcell + scell, +1 due to DL+UL for one Pcell
    ${total_num}    evaluate    ${related_cell_num}+1
    should be equal as integers    ${num}    ${total_num}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6

check HR QCI added and scell released NSA
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check HR QCI added NSA on wireshark
    check scell released NSA on wireshark
    ${erab_1}=    get erab value when qci added NSA on wireshark
    set test variable    ${erab_1}

check HR QCI added NSA on wireshark
    # SgNBModificationRequest
    ${SgNBModificationRequest_filter}    catenate    (x2ap.X2AP_PDU == 0) && (x2ap.procedureCode == 29)
    ${SgNBModificationRequest_packets}    cap.filter_packets_by_expression    filter_expression=${SgNBModificationRequest_filter}
    ${x2ap_qCI}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequest_packets}
    ...                                                xpath=.//x2ap.qCI
    should be equal    ${x2ap_qCI}[0]    8
    # SgNBModificationRequestAcknowledge, RRC Reconfiguration
    ${SgNBModificationRequestAcknowledge_filter}    catenate    (x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 29)
    ${SgNBModificationRequestAcknowledge_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${SgNBModificationRequestAcknowledge_filter}
    ${x2ap_qCI}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//x2ap.qCI
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    should be equal    ${mcs_Table}[0]    1
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6

check scell released NSA on wireshark
    # UEContextModificationRequest
    ${UEContextModificationRequest_filter}    catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 7)) && (f1ap.id == 51)
    ${UEContextModificationRequest_packets}    cap.filter_packets_by_expression    filter_expression=${UEContextModificationRequest_filter}
    ${f1ap_id}=    cap.Get Field Value By Xpath    pdml_list=${UEContextModificationRequest_packets}
    ...                                                xpath=.//f1ap.id
    should contain    ${f1ap_id}    51

get erab value when qci added NSA on wireshark
    # SgNBModificationRequestAcknowledge, RRC Reconfiguration
    ${SgNBModificationRequestAcknowledge_filter}    catenate    (x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 29)
    ${SgNBModificationRequestAcknowledge_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${SgNBModificationRequestAcknowledge_filter}
    ${x2ap_e_RAB_ID}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//x2ap.e_RAB_ID
    [Return]    ${x2ap_e_RAB_ID}[0]

check legacy mcs_table and beatoffset SgNBModificationRequestAcknowledge NSA on wireshark
    # SgNBModificationRequestAcknowledge, RRC Reconfiguration
    ${SgNBModificationRequestAcknowledge_filter}    Catenate    (x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 29)
    ${SgNBModificationRequestAcknowledge_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${SgNBModificationRequestAcknowledge_filter}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    11
    Should Be Equal    ${betaOffsetACK_Index2}[0]    8
    Should Be Equal    ${betaOffsetACK_Index3}[0]    6
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    13
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    13

check scell not added back NSA on wireshark
    ${cell1_physcellid}=    Get physCellId from SCF    golden_scf_name=${tl_gnb1_scf_${sw_version}}    gnb_index=${0}
    ...    cell_index=${1}    scf_path=${scf_path}
    ${cell2_physcellid}=    Get physCellId from SCF    golden_scf_name=${tl_gnb1_scf_${sw_version}}    gnb_index=${0}
    ...    cell_index=${2}    scf_path=${scf_path}
    # UEContextModificationResponse
    ${UEContextModificationResponse_filter}
    ...    Catenate    ((f1ap.F1AP_PDU == 1) && (f1ap.procedureCode == 7)) && (nr-rrc.physCellId == ${cell1_physcellid})
    ${UEContextModificationResponse_packets}    cap.filter_packets_by_expression    filter_expression=${UEContextModificationResponse_filter}
    ${physCellId}=    cap.Get Field Value By Xpath    pdml_list=${UEContextModificationResponse_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should contain    ${physCellId}    ${cell1_physcellid}
    should not contain    ${physCellId}    ${cell2_physcellid}

check qci release and scell not added back NSA
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check legacy mcs_table and beatoffset SgNBModificationRequestAcknowledge NSA on wireshark
    ${erab_2}=    get erab value when qci added NSA on wireshark
    set test variable    ${erab_2}
    check scell not added back NSA on wireshark

check sgnbaddition and mcs_table and beatoffset NSA
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check sgnbaddition and mcs_table and beatoffset NSA on wireshark

check sgnbaddition and mcs_table and beatoffset NSA on wireshark
    ${cell1_physcellid}=    Get physCellId from SCF    golden_scf_name=${tl_gnb1_scf_${sw_version}}    gnb_index=${0}
    ...    cell_index=${1}    scf_path=${scf_path}
    ${cell2_physcellid}=    Get physCellId from SCF    golden_scf_name=${tl_gnb1_scf_${sw_version}}    gnb_index=${0}
    ...    cell_index=${2}    scf_path=${scf_path}
    # SgNBAdditionRequestAcknowledge, RRC Reconfiguration
    ${SgNBAdditionRequestAcknowledge_filter}    catenate
    ...    ((x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 27)) && (nr-rrc.physCellId == ${cell1_physcellid})
    ${SgNBAdditionRequestAcknowledge_packets}    cap.filter_packets_by_expression    filter_expression=${SgNBAdditionRequestAcknowledge_filter}
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    should contain    ${mcs_Table}    1
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6

check scell added success via A1 NSA
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check scell added via A1 NSA on wireshark

check scell added via A1 NSA on wireshark
    ${cell1_physcellid}=    Get physCellId from SCF    golden_scf_name=${tl_gnb1_scf_${sw_version}}    gnb_index=${0}
    ...    cell_index=${1}    scf_path=${scf_path}
    ${cell2_physcellid}=    Get physCellId from SCF    golden_scf_name=${tl_gnb1_scf_${sw_version}}    gnb_index=${0}
    ...    cell_index=${2}    scf_path=${scf_path}
    # Measurement Report
    ${Measurement_Report_filter}    catenate    (x2ap.X2AP_PDU == 0) && (x2ap.procedureCode == 35)
    ${Measurement_Report_packets}    cap.filter_packets_by_expression    filter_expression=${Measurement_Report_filter}
    ${physCellId}=    cap.Get Field Value By Xpath    pdml_list=${Measurement_Report_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should be equal    ${physCellId}[0]    ${cell1_physcellid}

    # SgNBModificationRequired, RRC Reconfiguration
    ${SgNBModificationRequired_filter}
    ...    catenate    ((x2ap.X2AP_PDU == 0) && (x2ap.procedureCode == 30)) && (nr-rrc.physCellId == ${cell2_physcellid})
    ${SgNBModificationRequired_packets}    cap.filter_packets_by_expression    filter_expression=${SgNBModificationRequired_filter}
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequired_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    should be equal    ${mcs_Table}[0]    1

    # SgNBModificationConfirm, RRC Reconfiguration Complete
    ${SgNBModificationConfirm_filter}    catenate    (x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 30)
    ${SgNBModificationConfirm_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${SgNBModificationConfirm_filter}
    ${x2ap_procedureCode}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationConfirm_packets}
    ...                                                xpath=.//x2ap.procedureCode
    should contain    ${x2ap_procedureCode}    30

Check wireshark log for 8246_K004_3
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check mcs_table not in RRC Rconfig messgae
    check scell not addition again

check mcs_table not in RRC Rconfig messgae
    # RRC Reconfiguration, DL NAS transport, PDU session modification command
    ${Reconfiguration_filter}    Catenate    (nokiaf1ap.F1AP_PDU == 0) && (nokiaf1ap.procedureCode == 12)
    ${Reconfiguration_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${Reconfiguration_filter}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${Reconfiguration_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${Reconfiguration_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${Reconfiguration_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${Reconfiguration_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${Reconfiguration_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    11
    Should Be Equal    ${betaOffsetACK_Index2}[0]    8
    Should Be Equal    ${betaOffsetACK_Index3}[0]    6
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    13
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    13

check scell not addition again
    ${cell1_physcellid}=    Get physCellId from SCF    golden_scf_name=${tl_gnb1_scf_${sw_version}}   gnb_index=${0}
    ...    cell_index=${1}    scf_path=${scf_path}
    ${GNB2_cell1_physcellid}=    Get physCellId from SCF    golden_scf_name=${tl_gnb2_scf_${sw_version}}    gnb_index=${1}
    ...    cell_index=${1}    scf_path=${scf_path}
    # UEContextModificationResponse
    ${UEContextModificationResponse_filter}    Catenate    (nokiaf1ap.F1AP_PDU == 0) && (nokiaf1ap.procedureCode == 12)
    ${UEContextModificationResponse_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${UEContextModificationResponse_filter}
    ${physCellId}=    cap.Get Field Value By Xpath    pdml_list=${UEContextModificationResponse_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    Should Not Contain    ${physCellId}    ${GNB2_cell1_physcellid}
    Should Contain    ${physCellId}    ${cell1_physcellid}

Check wireshark log for 8246_K006_1
    Check UL_UE_MCS_table_Capbility 256Qam   logname=${log_name_K_006_1}

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


get_required_tti_file_name
    [Arguments]    ${files_list}    ${required_file_name}=dl__all.csv
    FOR    ${file}    IN    @{files_list}
        ${status}    run keyword and return status    should contain    ${file}    ${required_file_name}
        exit for loop if    '${status}' == 'True'
        set test variable    ${file}
    END
    [Return]    ${file}


Get RNTI ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialULRRCMessageTransfer, RRC Setup Request
    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    [Return]    ${UE_RNTI_ID}[0]

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

check value on TTI file K006_1
    [Arguments]    ${file_path}    ${queried_filed}
    ${required_data_list}=    get_value_from_csv_file_255_exclude    file_path=${file_path}    queried_filed=${queried_filed}
    ${no_duplicates_required_data_list}    Remove Duplicates    ${required_data_list}
    FOR    ${data}    IN    @{no_duplicates_required_data_list}
        should be true    ${data}<=20
    END

check value on TTI file K16_1
    [Arguments]    ${file_path}    ${queried_filed}
    ${required_data_list}=    get_value_from_csv_file_255_exclude    file_path=${file_path}    queried_filed=${queried_filed}
    ${no_duplicates_required_data_list}    Remove Duplicates    ${required_data_list}
    FOR    ${data}    IN    @{no_duplicates_required_data_list}
        should be true    ${data}<=20
    END

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


put f1ap xnap plug_in package on wireshark installation path
     [Arguments]    ${plug_in_path}=/opt/workspace/Tool/wireshark_plug_in/
     ...    ${wireshark_installation_path}=/usr/lib/x86_64-linux-gnu/wireshark/plugins/4.2/epan/
     ${code}=    put_plug_in_to_wireshark_path_of_ute
     ...    plug_in_path=${plug_in_path}    wireshark_installation_path=${wireshark_installation_path}
     run keyword if    ${code} == 0    log to console    plug in files are put success
     ...    ELSE    fail    msg=plug in files are put failed

rm f1ap xnap plug_in package on wireshark installation path
    [Arguments]    ${plug_in_path}=/opt/workspace/Tool/wireshark_plug_in/
     ...    ${wireshark_installation_path}=/usr/lib/x86_64-linux-gnu/wireshark/plugins/4.2/epan/
     ${code}=    rm_plug_in_to_wireshark_path_of_ute
     ...    plug_in_path=${plug_in_path}    wireshark_installation_path=${wireshark_installation_path}
     run keyword if    ${code} == 0    log to console    plug in files are remove success
     ...    ELSE    fail    msg=plug in files are remove failed

Check wireshark log
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${attribute_name}=show
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${filtered_result}=     cap.get_field_value_by_xpath    attribute_name=${attribute_name}    xpath=${xpath}    pcap_parser=test6
    [Return]    ${filtered_result}

Check UEContextModificationResponse has physcellid on PrimegNB
    [Arguments]    ${logname}
    ...    ${pcell_index}=${pcell_index}    ${scell_index_list}=${scell_index_list}
    ...    ${Primegnb_index}=${Primegnb_index}    ${extgnb_index_list}=${extgnb_index_list}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList==
    ...    ${message_filter1}= and nr-rrc.physCellId ==
    ...    ${xpath1}=.//nr-rrc.physCellId    ${CA_OK}=True    ${UEContextModificationResponse_nums}=${3}
    ${pci_cclist}    Create List
    ${pci_pcell}=    get required cell info   required_info=physicalCellId    cell_index=${pcell_index}   gnb_index=${Primegnb_index}
    ${pci_pcell}=    Convert To String    ${pci_pcell}
    Append to list    ${pci_cclist}    ${pci_pcell}
    FOR    ${scell_index}    ${extgnb_index}    IN ZIP    ${scell_index_list}    ${extgnb_index_list}
        ${pci_scell}=    get required cell info
        ...    required_info=physicalCellId    cell_index=${scell_index}   gnb_index=${extgnb_index}
        ${pci_scell}=    Convert To String    ${pci_scell}
        Append to list    ${pci_cclist}    ${pci_scell}
    END
    ${scell_nums}    Get Length    ${scell_index_list}
    Log    check UEContextModificationResponse message
    ${physCellId_list}=    Check wireshark log    logname=${logname}
    ...    message_filter=${message_filter}${scell_nums}${message_filter1}${pci_pcell}    xpath=${xpath1}
    ${wireshark_cell_num}    Get Length    ${physCellId_list}
    ${CA_cell_num}    Get Length    ${pci_cclist}
    Run keyword If    ${CA_OK}==True    Should be true   ${wireshark_cell_num}==${UEContextModificationResponse_nums}*${CA_cell_num}
    ...    ELSE    Should be true   ${wireshark_cell_num}!=${UEContextModificationResponse_nums}*${CA_cell_num}
    ${CA_status}=    Run keyword and return status    List Should Contain Sub List    ${physCellId_list}    ${pci_cclist}
    Run keyword If    ${CA_OK}==True    should be equal    ${CA_status}    ${true}
    ...    ELSE    should be equal    ${CA_status}    ${false}

Check UE_MCS_table_Capbility without_ul-64QAM-MCS-TableAlt
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    nokiaf1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Not Contain    ${nr_rrc_mcs_Table}    1
