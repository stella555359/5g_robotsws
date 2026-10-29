*** Settings ***
Documentation
...    author: Zhang Yayun
...    contact: yayun.zhang@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-D

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...             robot_common_operations.Common Suite Setup
...             AND    Common Suite Setup for COAM
...             AND    Get gnb release info
...             AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
...             AND    Common UE parameter setup

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource     Resources/CB008246_common_keywords.robot


*** Variables ***
${log_name_D_001_1}    log_name_D_001_1.pcap
${log_name_D_001_2}    log_name_D_001_2.pcap
${log_name_D_001_3}    log_name_D_001_3.pcap
${log_name_D_006_1}    log_name_D_006_1.pcap
${log_name_D_008_1}    log_name_D_008_1.pcap
${expected_tput_dl}    300
${Send_Tput_DL}        600M
${expected_tput_ul}    100
${Send_Tput_UL}        200M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}

*** Test Cases ***
[1]CB008246-D_006_HRDRB_BRDRB_DL_initial_and_retransmission_counters_for_LowSE_MCS_table_2TX_PDSCH_Profile2
    [Documentation]    CB008246-D
    [Tags]    CB008246-D    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    robot_common_operations.Common Case Setup
#    ${release_info}    Get sagnb release
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_D_006}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Comment    UE3 attach on gnb1 cell1
    Start capture gNB log on master    filename=${log_name_D_006_1}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    Sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_D_006_1}
    Check wireshark log for 8246_D006_1
    Start only DL traffic and check tput    ue_index=${2}    cellid=2    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=3600
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check trunk counter for 8246_HR_D006_gNB1cell2_New
#    Check counter for 8246_HR_D006_gNB1cell2_New
    Check D006 HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}
    Comment     gnb1 cell2 PA to 55db to trigger HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${59}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    sleep    15s
    Comment     gnb1 cell2 PA to 55db to trigger HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${62}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    sleep    30s
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check trunk counter for 8246_BR_D006_gNB1cell2_New
    Check D006 BR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_BR_KPI.txt    para_index=${2}
    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    sleep    10s
    Prepare with PM counter time to caculate    period=start
    sleep    5min
    Check trunk counter for 8246_HR_D006_gNB1cell2_New
    Check D006 HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    ...    AND    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_006_1}
    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    ...    AND    Adjust HBTE gNB_eNB_RU Attenuation
    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_D_006}
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB008246-D_008_New_PM_counters_for_PDSCH_tx_success_failure_with_LowSE_MCS_Table
#    [Documentation]    CB008246-D
#    [Tags]    CB008246-D    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
##    ${release_info}    Get sagnb release
#    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_D_008}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    Comment    UE3 attach on gnb1 cell1
#    Start capture gNB log on master    filename=${log_name_D_008_1}
#    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
#    Stop and download Logs on gNB on master    filename=${log_name_D_008_1}
#    Check wireshark log for 8246_D008_1
#    Start only DL traffic and check tput    ue_index=${2}    cellid=1    ue_type=${ue_type}    gnb_index=${0}
#    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=3600
#    Prepare with PM counter time to caculate    period=start
#    sleep    5min
#    Run keyword if    '${release_info}' == '@{branch}[0]'    Check trunk counter for 8246_HR_D008_gNB1cell1_New
#    ...    ELSE    Check counter for 8246_HR_D008_gNB1cell1_New
##    Check counter for 8246_HR_D008_gNB1cell1_New
#    Check D008 HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}
#    Comment     gnb1 cell2 PA to 55db to trigger HR to BR
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${43}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
#    sleep    10s
#    Prepare with PM counter time to caculate    period=start
#    sleep    5min
#    Run keyword if    '${release_info}' == '@{branch}[0]'    Check trunk counter for 8246_BR_D008_gNB1cell1_New
#    ...    ELSE    Check counter for 8246_BR_D008_gNB1cell1_New
##    Check counter for 8246_BR_D008_gNB1cell1_New
#    Check D008 BR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_BR_KPI.txt    para_index=${1}
#    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL   AND
#    ...    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_008_1}    AND
#    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot    AND
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_D_008}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

*** Keywords ***
check D008 BR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_D_008_BR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_008_BR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_008_BR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.12}
#    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.13}
    check required KPI via pm file    KPI_name_list=${CB008246_D_008_BR_traffic_check_kpi_names_greater_than_or_equal_specfied}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}
    check required KPI via pm file    KPI_name_list=${CB008246_D_008_BR_traffic_check_kpi_names_less_specified_value2}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${1000}


Check D008 HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_D_008_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_008_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_008_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.011}
    check required KPI via pm file    KPI_name_list=${CB008246_D_008_HR_traffic_check_kpi_names_greater_than_or_equal_specfied}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}
    check required KPI via pm file    KPI_name_list=${CB008246_D_008_HR_traffic_check_kpi_names_less_specified_value2}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${1000}

Check trunk counter for 8246_HR_D008_gNB1cell1_New
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_D008_HR_gNB1_cell1_New}    dic_path=${Trunk_counter_dic_path_D008_HR_gNB1_cell1_New}
    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55366C00005_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55366C00006_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55308C00005_DATA_SLOT_PDSCH}             ${counter_value_list}[4]
    Set suite variable    ${M55308C00008_DATA_SLOT_PDSCH_TIME}        ${counter_value_list}[5]
    Set suite variable    ${M55308C03001_PDSCH_OFDM_SYMBOLS}          ${counter_value_list}[6]
    Set suite variable    ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}     ${counter_value_list}[7]
    Set suite variable    ${M55308C10001_PRB_USED_PDSCH}              ${counter_value_list}[8]
    Set suite variable    ${M55308C10003_PRB_AVAIL_PDSCH}             ${counter_value_list}[9]
    Set suite variable    ${M55309C01001_DL_MAC_SDU_VOL_DTCH}         ${counter_value_list}[10]
    Set suite variable    ${M55308C02000_ACC_UE_DL_DRB_DATA}          ${counter_value_list}[11]
    Should Be True        ${M55308C00005_DATA_SLOT_PDSCH}            >0
    Should Be True        ${M55308C00008_DATA_SLOT_PDSCH_TIME}       >0
    Should Be True        ${M55308C03001_PDSCH_OFDM_SYMBOLS}         >0
    Should Be True        ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}    >0
    Should Be True        ${M55308C10001_PRB_USED_PDSCH}             >0
    Should Be True        ${M55308C10003_PRB_AVAIL_PDSCH}            >0
    Should Be True        ${M55309C01001_DL_MAC_SDU_VOL_DTCH}        >0
    Should Be True        ${M55308C02000_ACC_UE_DL_DRB_DATA}         >0
    ${M55366C00001_gap}=    Evaluate    ${M55366C00001_LOWSE_HRD}-(${M55366C00005_LOWSE_HRD} + ${M55366C00006_LOWSE_HRD})
    Should Be True     -50<${M55366C00001_gap}<50
    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
    Should Be True    ${M55366C00001_02_gap}<=0.011

Check counter for 8246_HR_D008_gNB1cell1_New
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_D008_HR_gNB1_cell1_New}    dic_path=${counter_dic_path_D008_HR_gNB1_cell1_New}
    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55366C00005_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55366C00006_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55308C00005_DATA_SLOT_PDSCH}             ${counter_value_list}[4]
    Set suite variable    ${M55308C00008_DATA_SLOT_PDSCH_TIME}        ${counter_value_list}[5]
    Set suite variable    ${M55308C03001_PDSCH_OFDM_SYMBOLS}          ${counter_value_list}[6]
    Set suite variable    ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}     ${counter_value_list}[7]
    Set suite variable    ${M55308C10001_PRB_USED_PDSCH}              ${counter_value_list}[8]
    Set suite variable    ${M55308C10003_PRB_AVAIL_PDSCH}             ${counter_value_list}[9]
    Set suite variable    ${M55309C01001_DL_MAC_SDU_VOL_DTCH}         ${counter_value_list}[10]
    Set suite variable    ${M55308C02000_ACC_UE_DL_DRB_DATA}          ${counter_value_list}[11]
    Should Be True        ${M55308C00005_DATA_SLOT_PDSCH}            >0
    Should Be True        ${M55308C00008_DATA_SLOT_PDSCH_TIME}       >0
    Should Be True        ${M55308C03001_PDSCH_OFDM_SYMBOLS}         >0
    Should Be True        ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}    >0
    Should Be True        ${M55308C10001_PRB_USED_PDSCH}             >0
    Should Be True        ${M55308C10003_PRB_AVAIL_PDSCH}            >0
    Should Be True        ${M55309C01001_DL_MAC_SDU_VOL_DTCH}        >0
    Should Be True        ${M55308C02000_ACC_UE_DL_DRB_DATA}         >0
    ${M55366C00001_gap}=    Evaluate    ${M55366C00001_LOWSE_HRD}-(${M55366C00005_LOWSE_HRD} + ${M55366C00006_LOWSE_HRD})
    Should Be True     -50<${M55366C00001_gap}<50
    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
    Should Be True    ${M55366C00001_02_gap}<=0.011

Check trunk counter for 8246_BR_D008_gNB1cell1_New
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_D008_BR_gNB1_cell1_New}    dic_path=${Trunk_counter_dic_path_D008_BR_gNB1_cell1_New}
    Set suite variable    ${M55366C00009_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00010_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55366C00011_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55366C00012_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55308C00005_DATA_SLOT_PDSCH}             ${counter_value_list}[4]
    Set suite variable    ${M55308C00008_DATA_SLOT_PDSCH_TIME}        ${counter_value_list}[5]
    Set suite variable    ${M55308C03001_PDSCH_OFDM_SYMBOLS}          ${counter_value_list}[6]
    Set suite variable    ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}     ${counter_value_list}[7]
    Set suite variable    ${M55308C10001_PRB_USED_PDSCH}              ${counter_value_list}[8]
    Set suite variable    ${M55308C10003_PRB_AVAIL_PDSCH}             ${counter_value_list}[9]
    Set suite variable    ${M55309C01001_DL_MAC_SDU_VOL_DTCH}         ${counter_value_list}[10]
    Set suite variable    ${M55308C02000_ACC_UE_DL_DRB_DATA}          ${counter_value_list}[11]
    Should Be True        ${M55308C00005_DATA_SLOT_PDSCH}            >0
    Should Be True        ${M55308C00008_DATA_SLOT_PDSCH_TIME}       >0
    Should Be True        ${M55308C03001_PDSCH_OFDM_SYMBOLS}         >0
    Should Be True        ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}    >0
    Should Be True        ${M55308C10001_PRB_USED_PDSCH}             >0
    Should Be True        ${M55308C10003_PRB_AVAIL_PDSCH}            >0
    Should Be True        ${M55309C01001_DL_MAC_SDU_VOL_DTCH}        >0
    Should Be True        ${M55308C02000_ACC_UE_DL_DRB_DATA}         >0
    ${M55366C00009_gap}=    Evaluate    (${M55366C00009_LOWSE_HRD}- ${M55366C00010_LOWSE_HRD})/${M55366C00009_LOWSE_HRD}
    Should Be True     ${M55366C00009_gap}<=0.12
#    Should Be True     ${M55366C00009_gap}<=0.13
    ${M55366C00012_gap}=    Evaluate    ${M55366C00012_LOWSE_HRD}/( ${M55366C00011_LOWSE_HRD}+${M55366C00012_LOWSE_HRD})
#    ${M55366C00012_gap_LOWSE_HRD_Result_compare}    Evaluate    round(${M55366C00012_gap},4)
    Should Be True    ${M55366C00012_gap}<=0.12
#    Should Be True    ${M55366C00012_gap}<=0.13

Check counter for 8246_BR_D008_gNB1cell1_New
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_D008_BR_gNB1_cell1_New}    dic_path=${counter_dic_path_D008_BR_gNB1_cell1_New}
    Set suite variable    ${M55366C00009_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00010_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55366C00011_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55366C00012_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55308C00005_DATA_SLOT_PDSCH}             ${counter_value_list}[4]
    Set suite variable    ${M55308C00008_DATA_SLOT_PDSCH_TIME}        ${counter_value_list}[5]
    Set suite variable    ${M55308C03001_PDSCH_OFDM_SYMBOLS}          ${counter_value_list}[6]
    Set suite variable    ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}     ${counter_value_list}[7]
    Set suite variable    ${M55308C10001_PRB_USED_PDSCH}              ${counter_value_list}[8]
    Set suite variable    ${M55308C10003_PRB_AVAIL_PDSCH}             ${counter_value_list}[9]
    Set suite variable    ${M55309C01001_DL_MAC_SDU_VOL_DTCH}         ${counter_value_list}[10]
    Set suite variable    ${M55308C02000_ACC_UE_DL_DRB_DATA}          ${counter_value_list}[11]
    Should Be True        ${M55308C00005_DATA_SLOT_PDSCH}            >0
    Should Be True        ${M55308C00008_DATA_SLOT_PDSCH_TIME}       >0
    Should Be True        ${M55308C03001_PDSCH_OFDM_SYMBOLS}         >0
    Should Be True        ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}    >0
    Should Be True        ${M55308C10001_PRB_USED_PDSCH}             >0
    Should Be True        ${M55308C10003_PRB_AVAIL_PDSCH}            >0
    Should Be True        ${M55309C01001_DL_MAC_SDU_VOL_DTCH}        >0
    Should Be True        ${M55308C02000_ACC_UE_DL_DRB_DATA}         >0
    ${M55366C00009_gap}=    Evaluate    (${M55366C00009_LOWSE_HRD}- ${M55366C00010_LOWSE_HRD})/${M55366C00009_LOWSE_HRD}
    Should Be True     ${M55366C00009_gap}<=0.12
#    Should Be True     ${M55366C00009_gap}<=0.13
    ${M55366C00012_gap}=    Evaluate    ${M55366C00012_LOWSE_HRD}/( ${M55366C00011_LOWSE_HRD}+${M55366C00012_LOWSE_HRD})
#    ${M55366C00012_gap_LOWSE_HRD_Result_compare}    Evaluate    round(${M55366C00012_gap},4)
    Should Be True    ${M55366C00012_gap}<=0.12
#    Should Be True    ${M55366C00012_gap}<=0.13

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

Check trunk counter for 8246_HR_D006_gNB1cell2_New
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_D006_HR_gNB1_cell2_New}    dic_path=${Trunk_counter_dic_path_D006_HR_gNB1_cell2_New}
    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55366C00005_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55366C00006_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55308C00005_DATA_SLOT_PDSCH}             ${counter_value_list}[4]
    Set suite variable    ${M55308C00008_DATA_SLOT_PDSCH_TIME}        ${counter_value_list}[5]
    Set suite variable    ${M55308C03001_PDSCH_OFDM_SYMBOLS}          ${counter_value_list}[6]
    Set suite variable    ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}     ${counter_value_list}[7]
    Set suite variable    ${M55308C10001_PRB_USED_PDSCH}              ${counter_value_list}[8]
    Set suite variable    ${M55308C10003_PRB_AVAIL_PDSCH}             ${counter_value_list}[9]
    Set suite variable    ${M55309C01001_DL_MAC_SDU_VOL_DTCH}         ${counter_value_list}[10]
    Set suite variable    ${M55308C02000_ACC_UE_DL_DRB_DATA}          ${counter_value_list}[11]
    Should Be True        ${M55308C00005_DATA_SLOT_PDSCH}            >0
    Should Be True        ${M55308C00008_DATA_SLOT_PDSCH_TIME}       >0
    Should Be True        ${M55308C03001_PDSCH_OFDM_SYMBOLS}         >0
    Should Be True        ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}    >0
    Should Be True        ${M55308C10001_PRB_USED_PDSCH}             >0
    Should Be True        ${M55308C10003_PRB_AVAIL_PDSCH}            >0
    Should Be True        ${M55309C01001_DL_MAC_SDU_VOL_DTCH}        >0
    Should Be True        ${M55308C02000_ACC_UE_DL_DRB_DATA}         >0
    ${M55366C00001_gap}=    Evaluate    ${M55366C00001_LOWSE_HRD}-(${M55366C00005_LOWSE_HRD} + ${M55366C00006_LOWSE_HRD})
    Should Be True     -50<${M55366C00001_gap}<50
    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
    Should Be True    ${M55366C00001_02_gap}<=0.011

Check counter for 8246_HR_D006_gNB1cell2_New
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_D006_HR_gNB1_cell2_New}    dic_path=${counter_dic_path_D006_HR_gNB1_cell2_New}
    Set suite variable    ${M55366C00001_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00002_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55366C00005_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55366C00006_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55308C00005_DATA_SLOT_PDSCH}             ${counter_value_list}[4]
    Set suite variable    ${M55308C00008_DATA_SLOT_PDSCH_TIME}        ${counter_value_list}[5]
    Set suite variable    ${M55308C03001_PDSCH_OFDM_SYMBOLS}          ${counter_value_list}[6]
    Set suite variable    ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}     ${counter_value_list}[7]
    Set suite variable    ${M55308C10001_PRB_USED_PDSCH}              ${counter_value_list}[8]
    Set suite variable    ${M55308C10003_PRB_AVAIL_PDSCH}             ${counter_value_list}[9]
    Set suite variable    ${M55309C01001_DL_MAC_SDU_VOL_DTCH}         ${counter_value_list}[10]
    Set suite variable    ${M55308C02000_ACC_UE_DL_DRB_DATA}          ${counter_value_list}[11]
    Should Be True        ${M55308C00005_DATA_SLOT_PDSCH}            >0
    Should Be True        ${M55308C00008_DATA_SLOT_PDSCH_TIME}       >0
    Should Be True        ${M55308C03001_PDSCH_OFDM_SYMBOLS}         >0
    Should Be True        ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}    >0
    Should Be True        ${M55308C10001_PRB_USED_PDSCH}             >0
    Should Be True        ${M55308C10003_PRB_AVAIL_PDSCH}            >0
    Should Be True        ${M55309C01001_DL_MAC_SDU_VOL_DTCH}        >0
    Should Be True        ${M55308C02000_ACC_UE_DL_DRB_DATA}         >0
    ${M55366C00001_gap}=    Evaluate    ${M55366C00001_LOWSE_HRD}-(${M55366C00005_LOWSE_HRD} + ${M55366C00006_LOWSE_HRD})
    Should Be True     -50<${M55366C00001_gap}<50
    ${M55366C00001_02_gap}=    Evaluate    (${M55366C00001_LOWSE_HRD} - ${M55366C00002_LOWSE_HRD})/${M55366C00001_LOWSE_HRD}
    Should Be True    ${M55366C00001_02_gap}<=0.011

Check trunk counter for 8246_BR_D006_gNB1cell2_New
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_D006_BR_gNB1_cell2_New}    dic_path=${Trunk_counter_dic_path_D006_BR_gNB1_cell2_New}
    Set suite variable    ${M55366C00009_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00010_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55366C00011_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55366C00012_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55308C00005_DATA_SLOT_PDSCH}             ${counter_value_list}[4]
    Set suite variable    ${M55308C00008_DATA_SLOT_PDSCH_TIME}        ${counter_value_list}[5]
    Set suite variable    ${M55308C03001_PDSCH_OFDM_SYMBOLS}          ${counter_value_list}[6]
    Set suite variable    ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}     ${counter_value_list}[7]
    Set suite variable    ${M55308C10001_PRB_USED_PDSCH}              ${counter_value_list}[8]
    Set suite variable    ${M55308C10003_PRB_AVAIL_PDSCH}             ${counter_value_list}[9]
    Set suite variable    ${M55309C01001_DL_MAC_SDU_VOL_DTCH}         ${counter_value_list}[10]
    Set suite variable    ${M55308C02000_ACC_UE_DL_DRB_DATA}          ${counter_value_list}[11]
    Should Be True        ${M55308C00005_DATA_SLOT_PDSCH}            >0
    Should Be True        ${M55308C00008_DATA_SLOT_PDSCH_TIME}       >0
    Should Be True        ${M55308C03001_PDSCH_OFDM_SYMBOLS}         >0
    Should Be True        ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}    >0
    Should Be True        ${M55308C10001_PRB_USED_PDSCH}             >0
    Should Be True        ${M55308C10003_PRB_AVAIL_PDSCH}            >0
    Should Be True        ${M55309C01001_DL_MAC_SDU_VOL_DTCH}        >0
    Should Be True        ${M55308C02000_ACC_UE_DL_DRB_DATA}         >0
    ${M55366C00009_gap}=    Evaluate    (${M55366C00009_LOWSE_HRD}- ${M55366C00010_LOWSE_HRD})/${M55366C00009_LOWSE_HRD}
    Should Be True     ${M55366C00009_gap}<=0.12
    ${M55366C00012_gap}=    Evaluate    ${M55366C00012_LOWSE_HRD}/( ${M55366C00011_LOWSE_HRD}+${M55366C00012_LOWSE_HRD})
#    ${M55366C00012_gap_LOWSE_HRD_Result_compare}    Evaluate    round(${M55366C00012_gap},4)
    Should Be True    ${M55366C00012_gap}<=0.12

Check counter for 8246_BR_D006_gNB1cell2_New
    sleep    40s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_D006_BR_gNB1_cell2_New}    dic_path=${counter_dic_path_D006_BR_gNB1_cell2_New}
    Set suite variable    ${M55366C00009_LOWSE_HRD}                   ${counter_value_list}[0]
    Set suite variable    ${M55366C00010_LOWSE_HRD}                   ${counter_value_list}[1]
    Set suite variable    ${M55366C00011_LOWSE_HRD}                   ${counter_value_list}[2]
    Set suite variable    ${M55366C00012_LOWSE_HRD}                   ${counter_value_list}[3]
    Set suite variable    ${M55308C00005_DATA_SLOT_PDSCH}             ${counter_value_list}[4]
    Set suite variable    ${M55308C00008_DATA_SLOT_PDSCH_TIME}        ${counter_value_list}[5]
    Set suite variable    ${M55308C03001_PDSCH_OFDM_SYMBOLS}          ${counter_value_list}[6]
    Set suite variable    ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}     ${counter_value_list}[7]
    Set suite variable    ${M55308C10001_PRB_USED_PDSCH}              ${counter_value_list}[8]
    Set suite variable    ${M55308C10003_PRB_AVAIL_PDSCH}             ${counter_value_list}[9]
    Set suite variable    ${M55309C01001_DL_MAC_SDU_VOL_DTCH}         ${counter_value_list}[10]
    Set suite variable    ${M55308C02000_ACC_UE_DL_DRB_DATA}          ${counter_value_list}[11]
    Should Be True        ${M55308C00005_DATA_SLOT_PDSCH}            >0
    Should Be True        ${M55308C00008_DATA_SLOT_PDSCH_TIME}       >0
    Should Be True        ${M55308C03001_PDSCH_OFDM_SYMBOLS}         >0
    Should Be True        ${M55308C03005_PDSCH_OFDM_SYMBOLS_TIME}    >0
    Should Be True        ${M55308C10001_PRB_USED_PDSCH}             >0
    Should Be True        ${M55308C10003_PRB_AVAIL_PDSCH}            >0
    Should Be True        ${M55309C01001_DL_MAC_SDU_VOL_DTCH}        >0
    Should Be True        ${M55308C02000_ACC_UE_DL_DRB_DATA}         >0
    ${M55366C00009_gap}=    Evaluate    (${M55366C00009_LOWSE_HRD}- ${M55366C00010_LOWSE_HRD})/${M55366C00009_LOWSE_HRD}
    Should Be True     ${M55366C00009_gap}<=0.12
    ${M55366C00012_gap}=    Evaluate    ${M55366C00012_LOWSE_HRD}/( ${M55366C00011_LOWSE_HRD}+${M55366C00012_LOWSE_HRD})
#    ${M55366C00012_gap_LOWSE_HRD_Result_compare}    Evaluate    round(${M55366C00012_gap},4)
    Should Be True    ${M55366C00012_gap}<=0.12

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

Check counter for 8246
    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_D001_gNB1}    dic_path=${counter_dic_path_D001_gNB1}
    ...    value=${expected_value_D001_gnb1}

Check the PM counter should be value
    [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}    timeout=120
        Should Be Equal   ${counter_value}    ${value[${index}]}
    END
    [Teardown]    COAM Teardown gnb connections

Check wireshark log for 8246_D006_1
    Check DL_UE_MCS_table_Capbility    logname=${log_name_D_006_1}

Check wireshark log for 8246_D008_1
    Check DL_UE_MCS_table_Capbility    logname=${log_name_D_008_1}

Check DL_UE_MCS_table_Capbility
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.downlinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[0]}    1

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
