*** Settings ***
Documentation
...    author: Li Na
...    contact: na.li@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB009487_supercell_common


Resource    ./Resources/CB011088_common_keyword.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Test Timeout      20 hours

*** Test Cases ***
[1][1.0] CB011088-D-siso-03-full_ASOG_8_cells_up_to_100M_4T4R_RU_lock_unlock
    [Tags]    CRT_25R1    CRT_TRUNK
    [Setup]  Case setup
    ${ue_info}    Change The parameter of UE    new_ue_dict=${CB011088_AWHQV_UE}    org_UE_dict=${TLCommonConfig['MultiUECFG']}
    unlock cell3 and attach cell3    exp_dl=${500}    exp_ul=${30}
    ...    target_avg_percent=0.9    log_time=100s    ue_info=${ue_info}
    [Teardown]    Run Keyword And Ignore Error    Case Teardown


[1][1.0] CB011088-G6-siso-01_4xtypD_cells_typeE_mix_celltype
    [Tags]    CRT_25R1    CRT_TRUNK
    [Setup]  Case setup
    lock RU1&2
    unlock AQQY cell12 and UE attach
    [Teardown]    Case Teardown

[1]CB009102_W_07_NSA_DL_UL_peak_Tput_with_CA_BW_30M+30MHz
    [Tags]    23R2    Trunk
    [Setup]    robot_common_operations.Common case Setup
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Modify Parameters for CB009102 30MHz
    ${nrcell_2_3_cell_list}    create list    2    3
    Download Current BTS SCF To UTE    scf_name=9102_SCF.xml
    #dl_gap=-17, other sibs were not included in NRDIM tool, slot6 with MOD(sfn, 32) in [0,8,16,24]
    ${expect_ul_tp}    ${expect_dl_tp}    Get Theoretical TP From NRDIM    scf_name=9102_SCF.xml    UL_Rank=${2}
    ...    dl_cell_list=${nrcell_2_3_cell_list}    ul_cell_list=${nrcell_2_3_cell_list}    dl_gap=${-14}
    log to console    ${expect_dl_tp},${expect_ul_tp}
    ${ue_info}    Change The parameter of UE    new_ue_dict=${Config_9102_UE}    org_UE_dict=${TLCommonConfig['MultiUECFG']}
    unlock cell23 and attach cell23    exp_dl=${expect_dl_tp}    exp_ul=${expect_ul_tp}    if_ul=${False}
    ...    target_avg_percent=0.98    min_percent=0.85    log_time=300s    ue_info=${ue_info}
    [Teardown]   Run Keyword And Ignore Error    Case Teardown

[1][1.0] CB011088-G4-siso-02_4xtypeC_cells_4xtypeD_cells _RF_Power_Reset
    [Tags]    CRT_25R1    CRT_TRUNK
    [Setup]  Case setup
    modify the parameter case G2
    lock RU1&2
    UE attach and check Traffic    ul_throughput=${70}    dl_throughput=${200}    ul_tp_list=${ul_tp_list}
    ...    cells=${cell_list[6:7]}   target_avg_percent=0.28    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    Power Off RU3 And check alarm
    UE attach and check Traffic    ul_throughput=${70}    dl_throughput=${200}    ul_tp_list=${ul_tp_list}
    ...    cells=${cell_list[6:7]}   target_avg_percent=0.28    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    [Teardown]    Case Teardown


[1][1.0] CB011088-G2-siso-01_3xtypeB_cells_4xtypeD_Cells_mixed_celltype
    [Tags]    CRT_25R1    CRT_TRUNK
    [Setup]  Case setup
    set chBwUl/DL
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    configuration AWHQE cell
    set chBwUl/DL    input_list=${json_update_100M}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    lock RU1&2
    Change_NRCELL6_To_64QAM_And_DMRS
    ${scf_name}    set variable    CB011088-G2-siso-01_peak_scf.xml
    Download Current BTS SCF To UTE    scf_name=${scf_name}
    ${NR_cell_id_list}    create list    6
    ${expect_ul_tp}    ${expect_dl_tp}    Get Theoretical TP From NRDIM    scf_name=${scf_name}
    ...    dl_cell_list=${NR_cell_id_list}    ul_cell_list=${NR_cell_id_list}    UL_Rank=${2}
    UE attach and check Traffic    ul_throughput=${expect_ul_tp}    dl_throughput=${expect_dl_tp}    ul_tp_list=${ul_tp_list}
    ...    cells=${cell_list[7:8]}   target_avg_percent=0.98     multiue_config_direction=${TLCommonConfig_CaseG02["MultiUECFG"]}
    ...    log_time=300s    min_percent=0.85
    [Teardown]    Run Keywords    Change_NRCELL6_To_256QAM_And_DMRS
    ...    AND    Case Teardown
