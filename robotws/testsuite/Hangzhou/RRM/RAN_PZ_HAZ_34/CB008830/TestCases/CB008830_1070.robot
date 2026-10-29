*** Settings ***
Documentation    8830 DMRS
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008830/Resources/CB008830_keywords.robot
Force Tags        5G_RRM   PY36    RF50

Suite Setup    8830 Suite preparation    cell_chbw_config=1CC_T100M
    ...    pa_values_mapping=${INIT_PA_T1}
    ...    frame_structure=1070
Suite Teardown     run keyword and ignore error    CA Suite teardown

*** Test Cases ***
CB008830-SR-A1_001_DL_DMRS_type2_actitivation_deactivation_online_modification_SA
    [Documentation]    Author: Tony Tang
    ...    ***This user scenario describes DMRS TYPE2 online activation and deactivation on AEHC CELL-1.
    ...    ***After online activation and deactivation, legacy ue on the cell 1 should not impact, new UE will use dmrs type 2,
    ...    ***Throughput on the cell 1 dmrs type 2 should bigger than dmrs tyep 1.
    ...    ***This case use AEHC cell1 1 for DMRS TYPE2 testing.
    [Setup]    8830 Case setup
    log to console    \n    step1. DMRS Type 2 disabled in scf\n
    run keyword and continue on failure    Start capture F1AP log    tcpdump_collector_name=Dmrs_Type_F1AP    options=-i any sctp
    Retry commercial ue attach if failed    prepare_ue_needed=${False}    4G_check=${False}
    run keyword and continue on failure    Start data transfer based on direction    data_transfer_direction=both    protocol=udp
    ...    dl_tput=${DL_TPUT_IPERF}     ul_tput=${UL_TPUT_IPERF}   duration=3000s
    log to console    \n    step2. Online Enable CB008830\n
    COAM Update several parameters via rest api    parameters_to_update_via_api=${ONLINE_ENABLE_CB008830_API}
    ...    skip_parameter_relation_errors=False
    sleep    30s
    log to console    \n    step3. check bip on the cell leacy UE will not impact, still use DMRS Type 1.\n
    Run keyword and continue on failure    Captrue bip logs and Check DMRS TYPE2 Disabled

    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=180s
    ...    ignore_time=1min    filter=L2Lo

    run keyword and continue on failure     Check tput via power UE optimized     cell_index=1    direction=both
    ...    tput_log_path=${tput_log_path}   connection=GNB_OAM
    ...    exp_ul=${EXP_UL_T100M_2x2_64QAM_1070}   exp_dl=${EXP_DL_T100M_4x4_256QAM_1070_255_DMRSTYPE1}    target_avg_percent=0.95   min_percent=0.85
    ...    customized_log_name=DmrsType1_Throughput

    run keyword and continue on failure    Stop data transfer and detach UE    data_transfer_direction=both    ue_index=${0}
    sleep    30s
    Retry commercial ue attach if failed     prepare_ue_needed=${False}    4G_check=${False}
    run keyword and continue on failure    Start data transfer based on direction    data_transfer_direction=both   protocol=udp
    ...    dl_tput=${DL_TPUT_IPERF}     ul_tput=${UL_TPUT_IPERF}   duration=3000s

    log to console    \n    step4. online disable CB008830, and check bip on this cell legacy UE use DMRS TYPE2.\n
    COAM Update several parameters via rest api    parameters_to_update_via_api=${ONLINE_DISABLE_CB008830_API}
    sleep    30s
    Run keyword and continue on failure    Captrue bip logs and Check DMRS TYPE2 Enabled

    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=180s
    ...    ignore_time=1min    filter=L2Lo

    run keyword and continue on failure     Check tput via power UE optimized     cell_index=1    direction=both
    ...    tput_log_path=${tput_log_path}   connection=GNB_OAM
    ...    exp_ul=${EXP_UL_T100M_2x2_64QAM_1070}   exp_dl=${EXP_DL_T100M_4x4_256QAM_1070_255_DMRSTYPE2}    target_avg_percent=0.95   min_percent=0.85
    ...    customized_log_name=DmrsType2_Throughput

    run keyword and continue on failure    Stop data transfer and detach UE    data_transfer_direction=both    ue_index=${0}
    sleep    30s
    log to console    \n     step5. After Disable CB008830, and check bip on this cell new UE use DMRS TYPE 1.\n
    Retry commercial ue attach if failed     prepare_ue_needed=${False}    4G_check=${False}
    run keyword and continue on failure    Start data transfer based on direction    data_transfer_direction=both    protocol=udp
    ...    dl_tput=${DL_TPUT_IPERF}     ul_tput=${UL_TPUT_IPERF}   duration=3000s

    Run keyword and continue on failure    Captrue bip logs and Check DMRS TYPE2 Disabled    target_file_name=l1l2bip_log_dmrs_2nd_disabled

    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=180s
    ...    ignore_time=1min    filter=L2Lo

    run keyword and continue on failure     Check tput via power UE optimized     cell_index=1    direction=both
    ...    tput_log_path=${tput_log_path}   connection=GNB_OAM
    ...    exp_ul=${EXP_UL_T100M_2x2_64QAM_1070}   exp_dl=${EXP_DL_T100M_4x4_256QAM_1070_255_DMRSTYPE1}    target_avg_percent=0.95   min_percent=0.85
    ...    customized_log_name=DmrsType2_Disable_Throughput
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=Dmrs_Type_F1AP
    run keyword and continue on failure    Stop data transfer and detach UE    data_transfer_direction=both    ue_index=${0}
    [Teardown]    run keywords    run keyword and ignore error    Common case teardown    detach_ue=${True}    AND
    ...    CI_interface.Common Case Teardown

CB008830_SR_C3_004_Dynamic_switch_between_type_1_and_type_2_due_to_both_VONR_and_High_Reliability_DRB_SA
    [Documentation]    Author: chen.1.jing@nokia-sbell.com
    ...    This user scenario is to test DL DMRS TYPE 1 and TYPE 2 dynamic switch due to VONR and DL high reliability DRB
    ...    setup or release
    ...    Steps:
    ...    1. Online active CB008830, CB008246 and VoNR
    ...    2. Attach UE, start DL and UL traffic and check message-> DMRS TYPE2 is configured
    ...    3. Setup DL HR bearer(5QI8) and check message-> DMRS TYPE1 and qam64LowSE are configured, traffic is lower
    ...    4. Setup VoNR call and check message-> Still DMRS TYPE1 is in use, 256QAM are configured in Pcell
    ...    5. Trigger DL HR Bearer release-> Still DMRS TYPE 1 in use
    ...    6. Setup DL HR bearer(5QI8) and check message-> DMRS TYPE1 and 256QAM are configured
    ...    7. Trigger VoNR call release > Still DMRS TYPE 1 in use, qam64LowSE are configured
    ...    8. Release DL HR Bearer -> DMRS TYPE 2 and 256qam are configured

    [Setup]    8830 Case setup
    log to console    ***Step 1. Online Active CB008830, LA for HR DRB and VoNR***\n
    connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${ACTIVE_HR_DRB_VONR_IWK_CBOO8830}
    ...    skip_parameter_relation_errors=False

    log to console    ***Step 2. Attach UE, start traffic and check DMRS Type 2***\n
    Attach UE with traffic when CB008830 enabled    tcpdump_collector_name=Attach_expect_DMRS_TYPE2_step_2
    ...    exp_ul=${EXP_UL_T100M_2x2_64QAM_1070}     exp_dl=${EXP_DL_T100M_4x4_256QAM_1070_255_DMRSTYPE2}
    ...    customized_log_name=tput_attach_expect_DMRS_TYPE2_step_2

    log to console    ***Step 3. Setup DL HR bearer(5QI8) and check message***\n
    Setup HR DRB 5QI8 IWK CB008830   tcpdump_collector_name=HR_DRB_setup_expect_DMRS_TYPE1_qam64LowSE_step_3
    ...    exp_ul=${EXP_UL_T100M_2x2_64QAM_1070}     exp_dl=${EXP_DL_T100M_4x4_64QAM_1070_255_DMRSTYPE1}
    ...    customized_log_name=tput_expect_DMRS_TYPE_1_DL_qam64LowSE_step_3

    log to console    ***Step 4. Setup VoNR call and check message***\n
    VoNR IWK High Reliability And CBOO8830  tcpdump_collector_name=VoNR_expect_no_DMRS_TYPE_change_qam256_step_4
    ...    exp_ul=${EXP_UL_T100M_2x2_64QAM_1070}     exp_dl=${EXP_DL_T100M_4x4_256QAM_1070_255_DMRSTYPE1}
    ...    customized_log_name=tput_expect_DMRS_TYPE_1_DL_qam256_step_4

    log to console    ***Step 5. Trigger DL HR bearer(5QI8) release***\n
    Delete HR DRB 5QI8 after VoNR call setup   tcpdump_collector_name=HR_release_expect_DMRS_TYPE_no_change_qam256_step_5
    ...    rule=${DEL_5QI8_Rule}
    ...    exp_ul=${EXP_UL_T100M_2x2_64QAM_1070}     exp_dl=${EXP_DL_T100M_4x4_256QAM_1070_255_DMRSTYPE1}
    ...    customized_log_name=tput_expect_DMRS_TYPE_1_DL_qam256_step_5

    log to console    ***Step 6. Setup DL HR bearer(5QI8) and check message***\n
    Setup HR DRB 5QI8 IWK CB008830 after VoNR call setup    tcpdump_collector_name=No_DMRS_TYPE_change_and_mcstable_empty_step_6
    ...    mcs_table=3
    ...    exp_ul=${EXP_UL_T100M_2x2_64QAM_1070}     exp_dl=${EXP_DL_T100M_4x4_256QAM_1070_255_DMRSTYPE1}
    ...    customized_log_name=tput_expect_DMRS_TYPE_1_DL_256QAM_step_6

    log to console    ***Step 7. Trigger VoNR call release and check message***\n
    HR 5QI8 DRB IWK CBOO8830 after VoNR call release    tcpdump_collector_name=VoNR_release_No_DMRS_TYPE_change_qam64LowSE_step_7
    ...    exp_ul=${EXP_UL_T100M_2x2_64QAM_1070}     exp_dl=${EXP_DL_T100M_4x4_64QAM_1070_255_DMRSTYPE1}
    ...    customized_log_name=tput_attach_expect_DMRS_TYPE1_DL_64qam_step_7

    log to console    ***Step 8. Trigger DL HR bearer(5QI8) release***\n
    Delete HR DRB 5QI8 and Check CB008830   tcpdump_collector_name=HR_release_DMRS_TYPE_2_step_8    rule=${DEL_5QI8_Rule}
    ...    exp_ul=${EXP_UL_T100M_2x2_64QAM_1070}     exp_dl=${EXP_DL_T100M_4x4_256QAM_1070_255_DMRSTYPE2}
    ...    customized_log_name=tput_attach_expect_DMRS_TYPE2_step_8

    run keyword and continue on failure    Stop data transfer and detach UE    data_transfer_direction=both    ue_index=${0}
    [Teardown]    run keywords    run keyword and ignore error    Common case teardown    detach_ue=${True}    AND
    ...    CI_interface.Common Case Teardown

