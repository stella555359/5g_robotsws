*** Settings ***
Force Tags    PY36
Documentation     author: qingqing.zhang
...                 contact: qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB010701-AA

Resource    ./Resources/CB010701_common_keywords.robot
Variables    ./Resources/CB010701_variables.py


Suite Setup   Run Keywords     Common Suite Setup for COAM
...             AND    Common Case TestLine Setup prepare
...             AND    Get sagnb release


Suite Teardown   Run Keywords
...              Run Keyword And Ignore Error    Common Suite Teardown for COAM
...              AND    Common Case TestLine Setup recover    AND
...              TL Recovery for TMO SCF    golden_scf_name=SCF_GNB2_${release_info}.xml    AND
...              Adjust gNB_RU Attenuation for 2gnb

*** Variables ***
${gnb_path}    /tmp
${scf_path}    /opt/workspace/SCF/
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${tl_scf_38611}    CB010701_SCF.xml
${tl_scf_38711}    SCF_GNB2_
${tl_scf_72e}    SCF_GNB1_72e_
${interface1}    br1
${expected_tput_ul_F}    109
${expected_tput_ul_F_1116_3}    80
${expected_tput_ul_T_1116_3}    204
${expected_tput_dl_F_1116_3}    120
${expected_tput_dl_T_1116_3}    830
${expected_tput_ul_F_1110_0_10M}    52
${expected_tput_ul_T_1208}    191
${expected_tput_ul_T_1070}    299
${expected_tput_ul_T_1layer}    70
${expected_tput_dl_F_pcell}   30
${expected_tput_dl_T_scell}   20
${expected_tput_dl_T_1layer}   100
${expected_tput_dl_F_scell}   50
${expected_tput_dl_T_pcell}   200
${expected_tput_ul_T_1116_3_B_B4_004}    180
${Send_Tput_UL_T_F}    400M
${Send_Tput_DL_T_F}    1200M
#${expected_tput_ul_grant}    40
#${expected_tput_dl_grant}   55
${logname_B3_001_attach_2TX}    AA_B3_001_attach_1208_2TX.pcap
${logname_B3_001_attach}    AA_B3_001_attach_1208_3TX.pcap
${logname_B4_001_attach}    AB_B4_001_attach_1070_3TX.pcap
${logname_AA_B4_001_attach}    AA_B4_001_attach_1116_0ms_3TX.pcap
${logname_AA_B5_005_attach}    AA_B5_005_attach_1116_3ms_3TX.pcap
${logname_AB_B5_004_attach}    AB_B5_004_attach_1116_3ms_3TX.pcap
${logname_B_B4_004_attach}    B_B4_004_attach_1110_0ms_3TX.pcap
${logname_B_B3_003_attach}    B_B3_003_attach_1110_0ms_3TX.pcap
${logname_B_B3_003_RRCReconfiguration}    B_B3_003_RRCReconfiguration.pcap
@{value_B_B3_003}    ${0}    ${0}
@{value_B_B3_003_1}    ${100}    ${100}
@{value_B_B3_003_1ayer}    ${0}    ${0}
@{value_B_B3_003_1_1ayer}    ${100}    ${100}
@{allow_fault_list}    4098    62003    7311    7307
@{nr_phy_cell_ids}    712    713

*** Test Cases ***
#[1]CB010701_ET_AA_B3_001_SingleUE_peak_TP_for_FT_UL_CA_2CCs_with_3Tx_PUSCH_typeA_1208_ABIP_256QAM
#    [Documentation]
#    ...    This user scenario describes the single UE peak throughput when FDD cell is configured with PUSCH mapping
#    ...    type A with feature enabled for FDD + TDD FR1 scenario.
#    [Tags]    classical
##    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4098,62003,7311,7307
##    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    TL prepare for AA_B3
#    MTK UE reboot
#    Wait until keyword succeeds    4x   10s    MTK UE Down all ccmni
#    MTK prepare UE    ue_type=${ue_type}    ue_index=${-1}
#    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value1=${0}    gnb2_cell1_value2=${0}    gnb2_cell1_value3=${0}
#    ...    gnb2_cell1_value4=${0}    gnb2_cell3_value1=${0}    gnb2_cell3_value4=${7}
#    bollinger attach and collect log    logname=${logname_B3_001_attach_2TX}
#    Check wireshark log for 3TX    logname=${logname_B3_001_attach_2TX}    TDD_MIMO_Layers=1    TDD_SRS_Ports=0
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${-1}
#    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${Modify_Para_Online_CB010701_open}
#    bollinger attach and collect log    logname=${logname_B3_001_attach}
#    ...    counter_id=${counter_id_AA_B3_001_attach}
#    ...    dic_path=${dic_path_AA_B3_001_Pcell_attach}
#    Check wireshark log for 3TX    logname=${logname_B3_001_attach}
##    Start BTSlogs Collection
#    Start DLUL traffic and check throughput   logname=${logname_B3_001_attach}
#    ...    scellid=31    pcellid=1    tput_dl_pcell=${expected_tput_dl_F_pcell}    tput_dl_scell=${expected_tput_dl_T_scell}
#    ...    tput_ul_pcell=${expected_tput_ul_F}    tput_ul_scell=${expected_tput_ul_T_1208}    duration=300s
#    ...    counter_id=${counter_id_AA_B3_001_with_traffic}    dic_path_T=${dic_path_AA_B3_001_with_traffic_TDD}
#    ...    dic_path_F=${dic_path_AA_B3_001_with_traffic_FDD}
#    Stop UE DLUL traffic    ue_index=${-1}
#    Stop Btslogs Collection
#    [Teardown]    run keywords
#    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${-1}
#    ...    AND    Run Keyword And Ignore Error    Stop UE DLUL traffic    ue_index=${-1}
#    ...    AND    Run Keyword And Ignore Error    Case Teardown
#
#[1]CB010701_ET_AB_B4_001_SingleUE_peak_TP_for_TF_UL_CA_2CCs_with_3Tx_PUSCH_typeB_1070_ABIP_256QAM
#    [Documentation]
#    ...    This user scenario describes the single UE peak throughput when FDD cell is configured with PUSCH mapping
#    ...    type B with feature enabled for TDD FR1 + FDD scenario.
#    [Tags]    classical
#    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4098,62003,7311,7307
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    TL prepare for AB_B4
#    MTK UE reboot
#    Wait until keyword succeeds    4x   10s    MTK UE Down all ccmni
#    MTK prepare UE    ue_type=${ue_type}    ue_index=${-1}
#    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value1=${0}    gnb2_cell1_value2=${0}    gnb2_cell1_value3=${0}
#    ...    gnb2_cell1_value4=${0}    gnb2_cell3_value1=${0}    gnb2_cell3_value4=${7}
#    Start BTSlogs Collection
#    bollinger attach and collect log    logname=${logname_B4_001_attach}
#    ...    counter_id=${counter_id_AA_B3_001_attach}    dic_path=${dic_path_AB_B4_001_Pcell_attach}
#    Stop Btslogs Collection
#    Check wireshark log for 2CC    logname=${logname_B4_001_attach}    scell_index=${1}    pcell_index=${31}
#    Start DLUL traffic and check throughput    logname=${logname_B4_001_attach}
#    ...    scellid=1    pcellid=31    tput_dl_pcell=${expected_tput_dl_T_pcell}    tput_dl_scell=${expected_tput_dl_F_scell}
#    ...    tput_ul_pcell=${expected_tput_ul_T_1070}    tput_ul_scell=${expected_tput_ul_F}    duration=300s
#    ...    counter_id=${counter_id_AA_B3_001_with_traffic}    dic_path_T=${dic_path_AA_B3_001_with_traffic_TDD}
#    ...    dic_path_F=${dic_path_AA_B3_001_with_traffic_FDD}
#    Stop UE DLUL traffic    ue_index=${-1}
#    [Teardown]    run keywords
#    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${-1}
#    ...    AND    Run Keyword And Ignore Error    Stop UE DLUL traffic    ue_index=${-1}
#    ...    AND    Run Keyword And Ignore Error    Case Teardown
#
#[1]CB010701_Syve_AA_B4_004_SingleUE_peak_TP_for_FT_UL_CA_2CCs_with_3Tx_PUSCH_typeB_1116_0ms_ABIO_256QAM
#    [Documentation]
#    ...    This user scenario describes the single UE peak throughput when FDD cell is configured with PUSCH mapping
#    ...    type B with feature enabled for TDD FR1 + FDD scenario.
#    [Tags]    classical
#    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4098,62003,7311,7307
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    TL prepare for AA_B4
#    MTK UE reboot
#    Wait until keyword succeeds    4x   10s    MTK UE Down all ccmni
#    MTK prepare UE    ue_type=${ue_type}    ue_index=${-1}
#    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value1=${0}    gnb2_cell1_value2=${0}    gnb2_cell1_value3=${0}
#    ...    gnb2_cell1_value4=${0}    gnb2_cell3_value1=${0}    gnb2_cell3_value4=${0}
#    bollinger attach and collect log    logname=${logname_AA_B4_001_attach}
#    Start DLUL traffic and check throughput   logname=${logname_AA_B4_001_attach}
#    ...    scellid=31    pcellid=1    tput_dl_pcell=${expected_tput_dl_F_pcell}    tput_dl_scell=${expected_tput_dl_T_scell}
#    ...    tput_ul_pcell=${expected_tput_ul_F}    tput_ul_scell=${expected_tput_ul_T_1208}    duration=30s
#    ...    counter_id=${counter_id_AA_B3_001_with_traffic}    dic_path_T=${dic_path_AA_B3_001_with_traffic_TDD}
#    ...    dic_path_F=${dic_path_AA_B3_001_with_traffic_FDD}
#    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value1=${0}     gnb2_cell1_value2=${0}    gnb2_cell1_value3=${0}
#    ...    gnb2_cell1_value4=${0}    gnb2_cell3_value4=${0}
#    Start BTSlogs Collection
#    Start DLUL traffic and check throughput
#    ...    scellid=31    pcellid=1    tput_dl_pcell=${expected_tput_dl_F_pcell}    tput_dl_scell=${expected_tput_dl_T_1layer}
#    ...    tput_ul_pcell=${expected_tput_ul_F}    tput_ul_scell=${expected_tput_ul_T_1layer}    duration=30s
#    ...    counter_id=${counter_id_AA_B3_001_with_traffic}    dic_path_T=${dic_path_AA_B3_001_with_traffic_TDD}
#    ...    dic_path_F=${dic_path_AA_B3_001_with_traffic_FDD}    TDD_layer=1
##    Stop Btslogs Collection
#    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value1=${0}    gnb2_cell1_value2=${0}    gnb2_cell1_value3=${0}
#    ...    gnb2_cell1_value4=${0}    gnb2_cell3_value1=${0}    gnb2_cell3_value4=${0}
#    Start DLUL traffic and check throughput
#    ...    scellid=31    pcellid=1    tput_dl_pcell=${expected_tput_dl_F_pcell}    tput_dl_scell=${expected_tput_dl_T_scell}
#    ...    tput_ul_pcell=${expected_tput_ul_F}    tput_ul_scell=${expected_tput_ul_T_1208}    duration=30s
#    ...    counter_id=${counter_id_AA_B3_001_with_traffic}    dic_path_T=${dic_path_AA_B3_001_with_traffic_TDD}
#    ...    dic_path_F=${dic_path_AA_B3_001_with_traffic_FDD}
#    Stop UE DLUL traffic    ue_index=${-1}
#    [Teardown]    run keywords
#    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${-1}
#    ...    AND    Run Keyword And Ignore Error    Stop UE DLUL traffic    ue_index=${-1}
#    ...    AND    Run Keyword And Ignore Error    Case Teardown
#
[1]CB010701_Syve_AA_B5_005_SingleUE_peak_TP_for_FT_UL_CA_2CCs_with_3Tx_1116_3ms_ABIO_256QAM_mix_PUSCH_type_IWK_PSRS
    [Documentation]
    ...    This user scenario describes
    [Tags]    classical
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4098,62003,7311,7307
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    TL prepare for AA_B5
    MTK UE reboot
    Wait until keyword succeeds    4x   10s    MTK UE Down all ccmni
    MTK prepare UE    ue_type=${ue_type}    ue_index=${-1}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${0}    gnb1_cell3_value1=${11}    gnb1_cell3_value3=${11}
    #######add check point for CB012810#####
    bollinger attach and collect log    logname=${logname_AA_B5_005_attach}    gnb_index=${0}
    Start DLUL traffic and check throughput   logname=${logname_AA_B5_005_attach}    gnb_index=${0}
    ...    scellid=3    pcellid=2    tput_dl_pcell=${expected_tput_dl_F_pcell}    tput_dl_scell=${expected_tput_dl_T_scell}
    ...    tput_ul_pcell=${expected_tput_ul_F}    tput_ul_scell=${expected_tput_ul_T_1208}    duration=300s
    ...    counter_id=${counter_id_AA_B3_001_with_traffic}    dic_path_T=${dic_path_AA_B3_001_with_traffic_TDD_gnb1}
    ...    dic_path_F=${dic_path_AA_B3_001_with_traffic_FDD_gnb1}
    Adjust gNB_RU Attenuation for 2gnb   gnb1_cell2_value=${0}    gnb1_cell3_value4=${0}
    Start DLUL traffic and check throughput    gnb_index=${0}
    ...    scellid=3    pcellid=2    tput_dl_pcell=${expected_tput_dl_F_pcell}    tput_dl_scell=${expected_tput_dl_T_1layer}
    ...    tput_ul_pcell=${expected_tput_ul_F}    tput_ul_scell=${expected_tput_ul_T_1layer}    duration=300s
    ...    counter_id=${counter_id_AA_B3_001_with_traffic}    dic_path_T=${dic_path_AA_B3_001_with_traffic_TDD_gnb1}
    ...    dic_path_F=${dic_path_AA_B3_001_with_traffic_FDD_gnb1}    TDD_layer=1
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${0}    gnb1_cell3_value1=${11}    gnb1_cell3_value3=${11}
    Start BTSlogs Collection
    Start DLUL traffic and check throughput    gnb_index=${0}
    ...    scellid=3    pcellid=2    tput_dl_pcell=${expected_tput_dl_F_pcell}    tput_dl_scell=${expected_tput_dl_T_scell}
    ...    tput_ul_pcell=${expected_tput_ul_F}    tput_ul_scell=${expected_tput_ul_T_1208}    duration=300s
    ...    counter_id=${counter_id_AA_B3_001_with_traffic}    dic_path_T=${dic_path_AA_B3_001_with_traffic_TDD_gnb1}
    ...    dic_path_F=${dic_path_AA_B3_001_with_traffic_FDD_gnb1}
    Stop UE DLUL traffic    ue_index=${-1}
    Stop Btslogs Collection
    [Teardown]    run keywords
    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${-1}
    ...    AND    Run Keyword And Ignore Error    Stop UE DLUL traffic    ue_index=${-1}
    ...    AND    Run Keyword And Ignore Error    Case Teardown

[1]CB010701_Syve_AB_B5_004_SingleUE_peak_TP_for_TF_UL_CA_2CCs_with_3Tx_1116_3ms_ABIO_256QAM_mix_PUSCH_type_IWK_PSRS
    [Documentation]
    ...    This user scenario describes the single UE peak throughput when FDD cell is configured with PUSCH mapping
    ...    type A and  TDD cell is configured with PUSCH mapping typeB with feature enabled for TDD FR1 + FDD scenario
    ...    and considers the interworking with P-SRS. UE is located in the cell center so that signal is good enough for
    ...    TDD to support 2 layers transmission in uplink, DFT-s-OFDM for PUSCH is not enabled in the cell center. FDD
    ...    transmits simultaneously with 1 layer at the overlapping UL slot with TDD FR1.This test case applies to single UE case.
    [Tags]    classical
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4098,62003,7311,7307,62001
    Run keyword If    '${gnb_instance0}'=='${gnb_id[1]}'    Set Suite Variable    ${SCOUT_TL_NAME}     7_5_UTE5G402T386_12
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    TL prepare for AB_B5
    MTK UE reboot
    MTK prepare UE    ue_type=${ue_type}    ue_index=${-1}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell3_value1=${7}    gnb2_cell3_value4=${0}
    ...    gnb2_cell1_value1=${0}    gnb2_cell1_value4=${0}
    Wait until keyword succeeds    3X    10s    Attach and Check OK    logname=${logname_AB_B5_004_attach}
    ...    counter_id=${counter_id_AA_B3_001_attach}    dic_path=${dic_path_AB_B5_004_Pcell_attach}
    ${biplog}    TDD traffic and collect bip    logname=${logname_AB_B5_004_attach}
    ...    tput_dl_pcell=${expected_tput_dl_T_1116_3}    tput_dl_scell=${expected_tput_dl_F_1116_3}
    ...    tput_ul_pcell=${expected_tput_ul_T_1116_3}    tput_ul_scell=${expected_tput_ul_F_1116_3}
    ...    dl_throughput=${Send_Tput_DL_T_F}    ul_throughput=${Send_Tput_UL_T_F}
    ...    scellid=${1}    pcellid=${3}    target_file_name=l1l2bip_log_AB_B5004    ue_index=${-1}    ports=1
    Check Bip log for PSRS FDD slot mute    logname=${biplog[0]}    ScellId=${1}
    [Teardown]    run keywords
    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${-1}    AND
    ...    Run Keyword And Ignore Error    Stop UE DLUL traffic    ue_index=${-1}    AND
    ...    Run Keyword And Ignore Error    Case Teardown

[1]CB010701_Syve_B_B3_003_IWK_with_CB006086_for_TF_UL_CA_2CCs_with_3Tx
    [Documentation]
    ...    This user scenario describes feature interworking with CB06086.
    [Tags]    classical
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4098,62003,7311,7307,62001
    Run keyword If    '${gnb_instance0}'=='${gnb_id[1]}'    Set Suite Variable    ${SCOUT_TL_NAME}     7_5_UTE5G402T386_12
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    TL prepare for B_B3
    MTK UE reboot
    MTK prepare UE    ue_type=${ue_type}    ue_index=${-1}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell3_value1=${7}    gnb2_cell3_value4=${0}
    ...    gnb2_cell1_value1=${0}    gnb2_cell1_value4=${0}
    Wait until keyword succeeds    3X    10s
    ...    Attach and Check OK    logname=${logname_B_B3_003_attach}
    ${biplog}    TDD traffic and collect bip B_B3003
    ...    logname=${logname_B_B3_003_attach}    logname_RRC=${logname_B_B3_003_RRCReconfiguration}
    ...    tput_ul_pcell=${expected_tput_ul_T_1116_3}    tput_ul_scell=${expected_tput_ul_F_1110_0_10M}    ul_throughput=${Send_Tput_UL_T_F}
    ...    scellid=${1}    pcellid=${3}    target_file_name=l1l2bip_log_B_B3_003    ports=1
    Check Bip log for PSRS FDD slot mute    logname=${biplog[0]}    ScellId=1    frame=11160
    Check Wireshark Log For 1Layers    logname=${logname_B_B3_003_RRCReconfiguration}
    [Teardown]    run keywords
    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${-1}    AND
    ...    Run Keyword And Ignore Error    Stop UE DLUL traffic    ue_index=${-1}    AND
    ...    TL Recovery for TMO SCF    AND
    ...    Run Keyword And Ignore Error    Case Teardown

[1]CB010701_Syve_B_B4_004_SingleUE_IWK_with_parallel_transmission_mute_for_ASRS_TDD_and_PUSCH_FDD_for_TF_UL_CA_2CCs_with_3Tx_1116_0ms
    [Documentation]
    ...    This user scenario describes the parallel transmission of aperiodic SRS(A-SRS) and other uplink channels in a single UE.
    [Tags]    classical
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4098,62003,7311,7307,62001
    Run keyword If    '${gnb_instance0}'=='${gnb_id[1]}'    Set Suite Variable    ${SCOUT_TL_NAME}     7_5_UTE5G402T386_12
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    TL prepare for B_B4
    MTK UE reboot
    MTK prepare UE    ue_type=${ue_type}    ue_index=${-1}
    Attach and Check ASRS for B_B4_004
    ...    target_file_name=target_file_name    target_file_name1=target_file_name1
    [Teardown]    run keywords
    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${-1}    AND
    ...    Run Keyword And Ignore Error    Stop UE DLUL traffic    ue_index=${-1}    AND
    ...    TL Recovery for TMO SCF    AND
    ...    Run Keyword And Ignore Error    Case Teardown

*** Keywords ***
Check wireshark log for 3TX
    [Arguments]    ${logname}    ${TDD_MIMO_Layers}=2    ${TDD_SRS_Ports}=1
    Check wireshark log for 2CC    logname=${logname}
    Check wireshark log for 3TX capability    logname=${logname}    TDD_MIMO_Layers=${TDD_MIMO_Layers}
    ...    TDD_SRS_Ports=${TDD_SRS_Ports}

TL prepare for AA_B3
    Modify SCF first then Perform Commission    gnb_index=${1}    scf_file_name=${tl_scf_${gnb_instance0}}${release_info}.xml
    ...    MOsToAdd=${MOS_ADD_GNB2}    ParameterToDelete=${PARAMS_TO_delete_AA_B4_001}
    ...    ParamterToModify=${PARAMETERS_ONLINE_MODIFY_GNB1_AA_B3_001}     ListToAdd=${LIST_TO_ADD_AA_B3_001}
    Check the COAM gnb RU status ready
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${PARAMETERS_MODIFY_GNB2_FOR_UL}

TL prepare for AB_B4
    Modify SCF first then Perform Commission    gnb_index=${1}    scf_file_name=${tl_scf_${gnb_instance0}}${release_info}.xml
    ...    MOsToAdd=${MOS_ADD_GNB2}    ParameterToDelete=${PARAMS_TO_delete_AA_B5_001}
    ...    ParamterToModify=${PARAMETERS_ONLINE_MODIFY_GNB1_AB_B4_001}    ListToAdd=${LIST_TO_ADD_AB_B4_001}
    Check the COAM gnb RU status ready
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${PARAMETERS_MODIFY_GNB2_FOR_UL}

TL prepare for AA_B4
    Modify SCF first then Perform Commission    gnb_index=${1}    scf_file_name=${tl_scf_${gnb_instance0}}${release_info}.xml
    ...    MOsToAdd=${MOS_ADD_GNB2}    ParameterToDelete=${PARAMS_TO_delete_AA_B4_001}
    ...    ParamterToModify=${PARAMETERS_ONLINE_MODIFY_GNB1_AA_B4_001}    ListToAdd=${LIST_TO_ADD_AA_B4_001}
    Check the COAM gnb RU status ready
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${PARAMETERS_MODIFY_GNB2_FOR_UL}

TL prepare for AA_B5
    Modify SCF first then Perform Commission    gnb_index=${0}    scf_file_name=${tl_scf_72e}${release_info}.xml
    ...    MOsToAdd=${MOS_ADD_GNB1}    ParameterToDelete=${PARAMS_TO_delete_AA_B5_001}
    ...    ParamterToModify=${PARAMETERS_ONLINE_MODIFY_GNB1_AA_B5_001}    ListToAdd=${LIST_TO_ADD_AA_B5_001}
    Check the COAM gnb RU status ready
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_MODIFY_GNB1_FOR_UL}

TL prepare for AB_B5
    Modify SCF first then Perform Commission    gnb_index=${1}
    ...    scf_file_name=${tl_scf_${gnb_instance0}}    ParamterToModify=${PARAMETERS_ONLINE_MODIFY_AB_B5_004}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host}

TL prepare for B_B4
    Modify SCF first then Perform Commission    gnb_index=${1}
    ...    scf_file_name=${tl_scf_${gnb_instance0}}    ParamterToModify=${PARAMETERS_ONLINE_MODIFY_B_B4_004}
    ...    ListToAdd=${LIST_TO_ADD_B_B4_004}    ParameterToDelete=${PARAMS_TO_delete_B_B4_004}
    ...    ListParamterToModify=${LIST_TO_MODIFY_B_B4_004}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host}

TL prepare for B_B3
    Modify SCF first then Perform Commission    gnb_index=${1}
    ...    scf_file_name=${tl_scf_${gnb_instance0}}    ParamterToModify=${PARAMETERS_ONLINE_MODIFY_B_B3_003}
    ...    ListToAdd=${LIST_TO_ADD_B_B3_003}    ParameterToDelete=${PARAMS_TO_delete_B_B4_004}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host}

TL Recovery for TMO SCF
    [Arguments]    ${golden_scf_name}=${tl_scf_${gnb_instance0}}
    Common Case TestLine Setup with singe BTS    gnb_index=${1}
    ...    is_commission=True    golden_scf_name=${golden_scf_name}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host}

Check Bip log for PSRS FDD slot mute
    [Arguments]    ${logname}    ${frame}=11163    ${ScellId}=1
    ...    ${message_filter_1}=(uldata_srsreceivereq or uldata_srsreceiverespbmps or uldata_srsreceiverespps)
    ...    ${message_filter_2}=uldata_puschreceivereq&& 3gpp.dmrsScramblingSequenceInt ==
    ...    ${xpath}=.//_3gpp.slot
    ...    ${xpath1}=.//UlData_puschReceiveReqGrant_t.numOfPuschSymbols
    ${scell_PCI}=    get required cell info   required_info=physicalCellId    cell_index=${ScellId}   gnb_index=${1}
    ${slot_list}=    Check wireshark log    logname=${logname}    message_filter=${message_filter_1}    xpath=${xpath}
    ...    epc_log_path=${EMPTY}
    ${slot_list_TDD}      Remove Duplicates     ${slot_list}
    Run keyword If    ${frame}==11163
    ...    Should Contain Any    ${slot_list_TDD}    7    17
    ...    ELSE IF    ${frame}==11160
    ...    Should Contain Any    ${slot_list_TDD}    3    13
    ...    ELSE    sleep    1s
    ${slot_FDD}    Run keyword If    ${frame}==11163 and ${slot_list_TDD[0]}==17    Set variable    8
    ...    ELSE IF    ${frame}==11163 and ${slot_list_TDD[0]}==7    Set variable    3
    ...    ELSE IF    ${frame}==11160 and ${slot_list_TDD[0]}==13    Set variable    6
    ...    ELSE IF    ${frame}==11160 and ${slot_list_TDD[0]}==3    Set variable    1
    ...    ELSE    sleep    1s
    ${PCS_List}=    Check wireshark log    logname=${logname}
    ...    message_filter=${message_filter_2}${scell_PCI}&& 3gpp.slot==${slot_FDD}
    ...    xpath=${xpath1}    epc_log_path=${EMPTY}
    ${PCS_List_TDD}      Remove Duplicates     ${PCS_List}
    Should Not Contain Any    ${PCS_List}    13    12
    ${PCS_length}    Get Length    ${PCS_List_TDD}
    Should Be Equal    ${PCS_length}    ${1}
    Should Be Equal    ${PCS_List_TDD[0]}    14


Check Bip log for ASRS FDD slot mute
    [Arguments]    ${logname}    ${ScellId}=1    ${PCS}=12
    ...    ${message_filter_1}=(uldata_srsreceivereq or uldata_srsreceiverespbmps or uldata_srsreceiverespps)
    ...    ${message_filter_2}=uldata_puschreceivereq&& 3gpp.dmrsScramblingSequenceInt ==
    ...    ${xpath}=.//_3gpp.slot
    ...    ${xpath1}=.//UlData_puschReceiveReqGrant_t.numOfPuschSymbols
    ##check TDD send ASRS on slot 5/15
    ${scell_PCI}=    get required cell info   required_info=physicalCellId    cell_index=${ScellId}   gnb_index=${1}
    ${slot_list}=    Check wireshark log    logname=${logname}    message_filter=${message_filter_1}    xpath=${xpath}
    ...    epc_log_path=${EMPTY}
    ${slot_list_TDD}      Remove Duplicates     ${slot_list}
    Sort List    ${slot_list_TDD}
    ${length_TDD}    Get Length    ${slot_list_TDD}
    Should be equal    ${length_TDD}    ${2}
    Should be true    ${slot_list_TDD[0]}    15
    Should be true    ${slot_list_TDD[1]}    5
    ##check TDD send ASRS on slot 5/15
    ${PCS_ASRS_List}=    Check wireshark log    logname=${logname}
    ...    message_filter=${message_filter_2}${scell_PCI}&& (3gpp.slot==7 or 3gpp.slot==2)
    ...    xpath=${xpath1}    epc_log_path=${EMPTY}
    ${PCS_ASRS_List_TDD}      Remove Duplicates     ${PCS_ASRS_List}
    ${length_FDD}    Get Length    ${PCS_ASRS_List_TDD}
    Should be equal    ${length_FDD}    ${1}
    Should be true    ${PCS_ASRS_List_TDD[0]}    ${PCS}

Check Bip log for no PSRS
    [Arguments]    ${logname}    ${ScellId}=1    ${PCS}=14
    ...    ${message_filter_1}=(uldata_srsreceivereq or uldata_srsreceiverespbmps or uldata_srsreceiverespps)
    ...    ${message_filter_2}=uldata_puschreceivereq && UlData_puschReceiveReqGrant_t.numOfPuschSymbols==${PCS}
    ...    ${xpath}=.//_3gpp.slot
    ...    ${xpath1}=.//UlData_puschReceiveReqGrant_t.numOfPuschSymbols
    ${scell_PCI}=    get required cell info   required_info=physicalCellId    cell_index=${ScellId}   gnb_index=${1}
    ${slot_list}=    Check wireshark log    logname=${logname}    message_filter=${message_filter_1}    xpath=${xpath}
    ...    epc_log_path=${EMPTY}
    Should be Empty    ${slot_list}
    ${slot_pcell}    Create List    1    6
    ${symbol_list_should}=    Create List    14
    FOR    ${slot_index}    IN    @{slot_pcell}
        ${symbol_list}=    Check wireshark log    logname=${logname}
        ...    message_filter=${message_filter_2}&&3gpp.dmrsScramblingSequenceInt==${scell_PCI}&& 3gpp.slot==${slot_index}
        ...    xpath=${xpath1}    epc_log_path=${EMPTY}
        ${symbol_list_1}      Remove Duplicates     ${symbol_list}
        Lists Should Be Equal    ${symbol_list_1}    ${symbol_list_should}
    END

Check Wireshark Log For 1Layers
    [Arguments]    ${logname}    ${TDD_MIMO_Layers}=1    ${TDD_SRS_Ports}=0
    ...    ${message_filter}=nokiaf1ap.procedureCode ==12 and nr-rrc.maxMIMO_Layers == 1 and nr-rrc.nrofSRS_Ports == 0
    ...    ${xpath_filter1}=.//nr-rrc.maxMIMO_Layers
    ...    ${xpath_filter2}=.//nr-rrc.nrofSRS_Ports
    ${maxMIMO_Layers}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath_filter1}
    Should be equal    ${maxMIMO_Layers[0]}    ${TDD_MIMO_Layers}
    ${SRS_Ports}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath_filter2}
    Should be equal    ${SRS_Ports[0]}    ${TDD_SRS_Ports}

TDD traffic and collect bip
    [Arguments]    ${logname}=NULL    ${scellid}=3   ${pcellid}=1
    ...    ${target_file_name}=l1l2bip_log
    ...    ${tput_dl_pcell}=NULL    ${tput_dl_scell}=NULL
    ...    ${tput_ul_pcell}=NULL    ${tput_ul_scell}=NULL
    ...    ${dl_throughput}=NULL    ${ul_throughput}=${Send_Tput_UL}    ${ue_index}=${-1}    ${apn}=dxdata1
    ...    ${gnb_index}=${1}    ${seg_size}=1180    ${dl_length}=1400B    ${duration}=5s    ${ports}=${ports_${gnb_instance0}}
    Start UE DLUL traffic MTK    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}    ports=${ports}
    ...    seg_size=${seg_size}    ue_index=${ue_index}    dl_length=${dl_length}    logname=${logname}    apn=${apn}
    sleep    120s
    Wait until keyword succeeds    3X    10s    Check 2CC DLUL tput    scellid=${scellid}    pcellid=${pcellid}
    ...    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}
    ...    tput_ul_pcell=${tput_ul_pcell}    tput_ul_scell=${tput_ul_scell}
    ...    duration=${duration}    gnb_index=${gnb_index}
    ${target_file_name}    Collect Bip logs    target_file_name=${target_file_name}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell3_value1=${7}    gnb2_cell3_value4=${127}
    ...    gnb2_cell1_value1=${0}    gnb2_cell1_value4=${0}
    sleep    60s
    Wait until keyword succeeds    3X    10s    Check 2CC DLUL tput    scellid=${scellid}    pcellid=${pcellid}
    ...    tput_dl_pcell=NULL    tput_dl_scell=NULL
    ...    tput_ul_pcell=NULL    tput_ul_scell=${tput_ul_scell}
    ...    duration=${duration}    gnb_index=${gnb_index}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell3_value1=${7}    gnb2_cell3_value4=${0}
    ...    gnb2_cell1_value1=${0}    gnb2_cell1_value4=${0}
    sleep    60s
    Wait until keyword succeeds    3X    10s    Check 2CC DLUL tput    scellid=${scellid}    pcellid=${pcellid}
    ...    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}
    ...    tput_ul_pcell=${tput_ul_pcell}    tput_ul_scell=${tput_ul_scell}
    ...    duration=${duration}    gnb_index=${gnb_index}
    [Teardown]    Stop UE DLUL traffic    ue_index=${-1}    dl_port=${DL_PORT}
    [Return]    ${target_file_name}

Attach and TDD traffic
    [Arguments]    ${logname}=${logname_B_B4_004_attach}    ${scellid}=3   ${pcellid}=1
    ...    ${tput_ul_pcell}=NULL    ${tput_ul_scell}=NULL
    ...    ${ul_throughput}=${Send_Tput_UL}    ${ue_index}=${-1}    ${apn}=dxdata1
    ...    ${gnb_index}=${1}    ${seg_size}=1180    ${dl_length}=1024B    ${duration}=5s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${-1}
    bollinger attach and collect log    logname=${logname}    gnb_index=${1}
    Start UE DLUL traffic MTK    dl_throughput=NULL    ul_throughput=${ul_throughput}    ports=1
    ...    seg_size=${seg_size}    ue_index=${ue_index}    dl_length=${dl_length}    logname=${logname}    apn=${apn}
    sleep    180s
    Wait until keyword succeeds    5X    10s    Check 2CC DLUL tput    scellid=${scellid}    pcellid=${pcellid}
    ...    tput_ul_pcell=${tput_ul_pcell}    tput_ul_scell=${tput_ul_scell}
    ...    duration=${duration}    gnb_index=${gnb_index}

TDD traffic and collect bip B_B4004
    [Arguments]    ${scellid}=3   ${pcellid}=1
    ...    ${target_file_name}=l1l2bip_log    ${target_file_name1}=NULL
    ...    ${tput_ul_pcell}=NULL    ${tput_ul_scell}=NULL
    ...    ${ue_index}=${-1}    ${gnb_index}=${1}    ${duration}=5s
    ${target_file_name}    Collect Bip logs    target_file_name=${target_file_name}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell3_value2=${127}    gnb2_cell3_value4=${0}
    ...    gnb2_cell1_value1=${0}    gnb2_cell1_value4=${0}
    Wait until keyword succeeds    3X   10s    Check 2CC DLUL tput    scellid=${scellid}    pcellid=${pcellid}
    ...    tput_ul_pcell=NULL    tput_ul_scell=${tput_ul_scell}
    ...    duration=${duration}    gnb_index=${gnb_index}
    ${target_file_name1}    Collect Bip logs    target_file_name=${target_file_name1}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell3_value2=${16}    gnb2_cell3_value4=${0}
    ...    gnb2_cell1_value1=${0}    gnb2_cell1_value4=${0}
    Wait until keyword succeeds    5X    10s    Check 2CC DLUL tput    scellid=${scellid}    pcellid=${pcellid}
    ...    tput_ul_pcell=${tput_ul_pcell}    tput_ul_scell=${tput_ul_scell}
    ...    duration=${duration}    gnb_index=${gnb_index}
    [Teardown]    Run keywords    Stop UE DLUL traffic    ue_index=${ue_index}    dl_port=NULL
    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    [Return]    ${target_file_name}    ${target_file_name1}

TDD traffic and collect bip B_B3003
    [Arguments]    ${logname}=NULL    ${logname_RRC}=NULL    ${scellid}=1   ${pcellid}=3
    ...    ${target_file_name}=l1l2bip_log
    ...    ${tput_ul_pcell}=NULL    ${tput_ul_scell}=NULL
    ...    ${ul_throughput}=${Send_Tput_UL}    ${ue_index}=${-1}    ${apn}=dxdata1
    ...    ${gnb_index}=${1}    ${seg_size}=1180    ${dl_length}=1024B    ${duration}=5s    ${ports}=${ports_${gnb_instance0}}
    Start UE DLUL traffic MTK    dl_throughput=NULL    ul_throughput=${ul_throughput}    ports=${ports}
    ...    seg_size=${seg_size}    ue_index=${ue_index}    dl_length=${dl_length}    logname=${logname}    apn=${apn}
    Prepare to caculate PM counter    period=start
    Wait until keyword succeeds    3X   10s    Check 2CC DLUL tput    scellid=${scellid}    pcellid=${pcellid}
    ...    tput_ul_pcell=${tput_ul_pcell}    tput_ul_scell=${tput_ul_scell}    duration=${duration}    gnb_index=${gnb_index}
    ${target_file_name}    Collect Bip logs    target_file_name=${target_file_name}
    Prepare to caculate PM counter    period=end
    Check counter for 3TX cell layer    gnb_index=${gnb_index}
    ...    counter_id=${counter_id_B_B3_003}    dic_path=${dic_path_B_B3_003}    value=${value_B_B3_003}
    ...    counter_id_1=${counter_id_B_B3_003_1}    dic_path_1=${dic_path_B_B3_003_1}    value_1=${value_B_B3_003_1}
    Start capture gNB log on master    filename=${logname_RRC}    gNB_index=${gnb_index}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell3_value1=${50}    gnb2_cell3_value4=${50}
    ...    gnb2_cell1_value1=${0}    gnb2_cell1_value4=${0}
    sleep    10s
    Stop and download the Logs    filename=${logname_RRC}   gNB_index=${gnb_index}
    Wait until keyword succeeds    3X   10s    Check 2CC DLUL tput    scellid=${scellid}    pcellid=${pcellid}
    ...    tput_ul_pcell=NULL    tput_ul_scell=20    duration=${duration}    gnb_index=${gnb_index}
    Prepare to caculate PM counter    period=start
    Prepare to caculate PM counter    period=end
    Check counter for 3TX cell layer    gnb_index=${gnb_index}
    ...    counter_id=${counter_id_B_B3_003_1layer}    dic_path=${dic_path_B_B3_003_1layer}    value=${value_B_B3_003_1ayer}
    ...    counter_id_1=${counter_id_B_B3_003_1_1layer}    dic_path_1=${dic_path_B_B3_003_1_1layer}    value_1=${value_B_B3_003_1_1ayer}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell3_value1=${7}    gnb2_cell3_value4=${0}
    ...    gnb2_cell1_value1=${0}    gnb2_cell1_value4=${0}
    Wait until keyword succeeds    3X   10s    Check 2CC DLUL tput    scellid=${scellid}    pcellid=${pcellid}
    ...    tput_ul_pcell=${tput_ul_pcell}    tput_ul_scell=${tput_ul_scell}    duration=${duration}    gnb_index=${gnb_index}
    [Teardown]    Stop UE DLUL traffic    ue_index=${-1}    dl_port=NULL
    [Return]    ${target_file_name}

Collect Bip logs
    [Arguments]    ${target_file_name}=l1l2bip_log    ${gnb_index}=1
    Collect Interface Mirroring Bip Collector from WEBUI    gnb_index=${gnb_index}    times=1s    target_file_name=${target_file_name}
    ${biplog}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=${target_file_name}
    Sleep    5s
    [Return]    ${biplog}

Check counter for 3TX cell layer
    [Arguments]    ${counter_id}=NULL    ${counter_id_1}=NULL    ${dic_path}=NULL    ${dic_path_1}=NULL
    ...    ${gnb_index}=${1}    ${value}=NULL    ${value_1}=NULL
    sleep    40s
    Check the PM counter should be value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id}    dic_path=${dic_path}    value=${value}
    Check the PM counter should be greater than 1
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_1}    dic_path=${dic_path_1}    value=${value_1}

Attach and Check ASRS for B_B4_004
    [Arguments]    ${target_file_name}    ${target_file_name1}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell3_value2=${16}    gnb2_cell3_value4=${0}
    ...    gnb2_cell1_value1=${0}    gnb2_cell1_value4=${0}
    Wait until keyword succeeds    3X   10s    Attach and TDD traffic    logname=${logname_B_B4_004_attach}
    ...    tput_ul_pcell=${expected_tput_ul_T_1116_3_B_B4_004}    tput_ul_scell=${expected_tput_ul_F_1110_0_10M}
    ...    ul_throughput=${Send_Tput_UL_T_F}    scellid=${1}    pcellid=${3}
    ${biplog}    ${biplog2}    TDD traffic and collect bip B_B4004
    ...    tput_ul_pcell=${expected_tput_ul_T_1116_3_B_B4_004}    tput_ul_scell=${expected_tput_ul_F_1110_0_10M}
    ...    scellid=${1}    pcellid=${3}    target_file_name=${target_file_name}    target_file_name1=${target_file_name1}
    Check Bip log for no PSRS    logname=${biplog[0]}
    Check Bip log for ASRS FDD slot mute    logname=${biplog2[0]}    ScellId=1    PCS=14

Attach and Check OK
    [Arguments]    ${logname}    ${counter_id}=${EMPTY}    ${dic_path}=NULL
    bollinger attach and collect log    logname=${logname}    gnb_index=${1}
    ...    counter_id=${counter_id}    dic_path=${dic_path}
    Check wireshark log for 2CC    logname=${logname}    scell_index=${1}    pcell_index=${3}