*** Settings ***
Force Tags    PY39    RF50
Resource    ./../../CB008985/Resources/CB008985_keywords.robot
Resource    ./../../CB008985/Resources/CB008178_keywords.robot
Resource    ./../../../../resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot

Documentation    Suite description
...    author: Dandan Fang
...    contact: dandan.fang@nokia-sbell.com
...    squad group: MMW_SG1l
...    Feature CB008985 CNI peak-tput


Suite Setup  8985 CA Suite preparation      is_pdl_checking_needed=${true}

Suite Teardown  run keyword and ignore error    CA Suite teardown

*** Test Cases ***
CB008985_C3_2_tddFr1_intra_band_CA_Single_UE_connection_setup_and_RLQ_Scell_scheduling_suspension_with_bufferbased_SCellActivation
    [Tags]  CIT_TRUNK    CIT_23R3   CIT_23R4
    [Documentation]     Author: Dandan Fang
    ...    Description: This case is to verify peak tput of Pcell:100M Scell:20M
    ...    Frame structure 1116_0, beamset_2, ScellAdditionMethod:blind
    ...    ScellActivationMethod:Bufferbased and with beamforming, TCP
    ...    step 1>  Attach UE to TDD FR1 cell(F1) as PCell and with carrier aggregation (TDD cell as SCell)
    ...    step 2>  UE start DL/UL data transfer, Peak data checked.
    ...    step 3>  Pcell subcell-0 switch to Subcell-1. Peak data checked.
    ...    step 4>  Scell subcell-0 signal change to low and meet bad RLQ. Then DL traffic on Scell as zero.
    ...    step 5>  Scell 1 signal to good and Scell subcell-0 switch to Subcell-1. DL traffic on Scell resume.
    ...    step 6>  Scell subcell-1 switch to Subcell-2. Peak data checked.
    [Setup]   CB008985_C3_2 Case Setup
    Adjust PA And Check Attach Status   CA_enable=${True}   4G_check=${False}      NSA_SA=${NSA_SA}
    ...       pa_values_mapping=${CA_PCELL_SCELL_PA_INIT}    pcell_id=${PCELL_ID}

    run keyword and continue on failure    Start data transfer and Check Tput As Expected    cell_id=${PCELL_ID},${SCELL_ID}
    ...    exp_ul_indiv=${PCELL_EXP_UL_TP},-1      exp_dl_indiv=${PCELL_EXP_DL_TP},${SCELL_EXP_DL_TP}
    ...    ul_iperf_tput=${UL_TPUT_Iperf}     dl_iperf_tput=${T_T_CA_DL_Iperf_Data}
    ...    data_transfer_direction=both     customized_log_name=SuperCell_CA_DLUL_Tput_Check

    #Pcell subcell-0 switch to subcell-1
    run keyword and continue on failure    Trigger PCELL Subcell Switch And Check Tput BF Counter
    ...    bf_counter_cell_id=${PCELL_ID}    counter_name=${BEAM_CHANGE_0_1_PM}    counter_expected_number=${1}
    ...    exp_ul_indiv=${PCELL_EXP_UL_TP},-1       exp_dl_indiv=${PCELL_EXP_DL_TP},${SCELL_EXP_DL_TP}
    ...    tput_check_cell_id=${PCELL_ID},${SCELL_ID}
    ...    source_target_subcell_pa_info=${PCELL_Subcell_0_SwitchTo_Subcell_1_PA}

    #Scell subcell0 trigger into bad RLQ
    run keyword and continue on failure        Verify scell data suspened and not deactivated when scell subcell in bad
     ...                      scell_rlq_ruindex_pa_value=${SCELL_RLQ_Subcell0_RU_INDEX_PA_VALUE}

    #Scell subcell-0 switch to subcell-1
    run keyword and continue on failure   Trigger SCELL Subcell Switch And Check Tput
    ...    exp_ul_indiv=${PCELL_EXP_UL_TP},-1       exp_dl_indiv=${PCELL_EXP_DL_TP},${SCELL_EXP_DL_TP}
    ...    tput_check_cell_id=${PCELL_ID},${SCELL_ID}
    ...    source_target_subcell_pa_info=${SCELL_Subcell_0_SwitchTo_Subcell_1_PA}

    #Scell subcell-1 switch to subcell-2
    run keyword and continue on failure   Trigger SCELL Subcell Switch And Check Tput
    ...    exp_ul_indiv=${PCELL_EXP_UL_TP},-1       exp_dl_indiv=${PCELL_EXP_DL_TP},${SCELL_EXP_DL_TP}
    ...    tput_check_cell_id=${PCELL_ID},${SCELL_ID}
    ...    source_target_subcell_pa_info=${SCELL_Subcell_1_SwitchTo_Subcell_2_PA}

    [Teardown]     run keyword and ignore error      run keywords    Common case teardown    detach_ue=${True}
    ...    AND    Initialize attenuator values for testline  pa_values_mapping=${CA_PCELL_SCELL_PA_INIT}

CB008985_C3_5_eCPRI-CA-T-T_Single_UE_connection_setup_and_DL_UL_data_scheduling_in_NSA_with_2_supercells
    [Tags]  CIT_TRUNK    CIT_23R3   CIT_23R4
    [Documentation]     Author: Dandan Fang
    ...    Description: This case is to verify peak tput of Pcell:100M Scell:20M
    ...    Frame structure 1116_0, beamset_2, ScellAdditionMethod:blind
    ...    ScellActivationMethod:Bufferbased and with beamforming, TCP
    ...    step 1>  Attach UE to TDD FR1 cell(F1) as PCell and with carrier aggregation (TDD cell as SCell)
    ...    step 2>  UE start DL/UL data transfer
    ...    step 3>  Pcell subcell-0 switch to Subcell-1.
    ...    step 4>  Pcell subcell-1 switch to Subcell-2.
    ...    step 5>  Scell subcell-0 switch to Subcell-1.
    ...    step 6>  Scell subcell-1 switch to Subcell-2.
    [Setup]   8985 Case Setup   NSA_SA=NSA   is_pdl_checking_needed=${false}
    Adjust PA And Check Attach Status   CA_enable=${True}   4G_check=${True}      NSA_SA=${NSA_SA}
    ...       pa_values_mapping=${CA_PCELL_SCELL_PA_INIT}    pcell_id=${PCELL_ID}

    run keyword and continue on failure   Start data transfer and Check Tput As Expected   cell_id=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${PCELL_EXP_UL_TP_NSA},-1      exp_dl_indiv=${PCELL_EXP_DL_TP},${SCELL_EXP_DL_TP}
    ...    ul_iperf_tput=${UL_TPUT_Iperf}     dl_iperf_tput=${T_T_CA_DL_Iperf_Data}
    ...    data_transfer_direction=both     customized_log_name=SuperCell_CA_DLUL_Tput_Check

    #Pcell subcell-0 switch to subcell-1
    run keyword and continue on failure  Trigger PCELL Subcell Switch And Check Tput BF Counter
    ...    bf_counter_cell_id=${PCELL_ID}    counter_name=${BEAM_CHANGE_0_1_PM}    counter_expected_number=${1}
    ...    exp_ul_indiv=${PCELL_EXP_UL_TP_NSA},-1    exp_dl_indiv=${PCELL_EXP_DL_TP},${SCELL_EXP_DL_TP}
    ...    tput_check_cell_id=${PCELL_ID},${SCELL_ID}
    ...    source_target_subcell_pa_info=${PCELL_Subcell_0_SwitchTo_Subcell_1_PA}

    #Pcell subcell-1 switch to subcell-2
    run keyword and continue on failure  Trigger PCELL Subcell Switch And Check Tput BF Counter
    ...    bf_counter_cell_id=${PCELL_ID}    counter_name=${BEAM_CHANGE_1_2_PM}    counter_expected_number=${1}
    ...    exp_ul_indiv=${PCELL_EXP_UL_TP_NSA},-1    exp_dl_indiv=${PCELL_EXP_DL_TP},${SCELL_EXP_DL_TP}
    ...    tput_check_cell_id=${PCELL_ID},${SCELL_ID}
    ...    source_target_subcell_pa_info=${PCELL_Subcell_1_SwitchTo_Subcell_2_PA}

    #Scell subcell-0 switch to subcell-1
    run keyword and continue on failure  Trigger SCELL Subcell Switch And Check Tput
    ...    exp_ul_indiv=${PCELL_EXP_UL_TP_NSA},-1       exp_dl_indiv=${PCELL_EXP_DL_TP},${SCELL_EXP_DL_TP}
    ...    tput_check_cell_id=${PCELL_ID},${SCELL_ID}
    ...    source_target_subcell_pa_info=${SCELL_Subcell_0_SwitchTo_Subcell_1_PA}

    #Scell subcell-1 switch to subcell-2
    run keyword and continue on failure  Trigger SCELL Subcell Switch And Check Tput
    ...    exp_ul_indiv=${PCELL_EXP_UL_TP_NSA},-1       exp_dl_indiv=${PCELL_EXP_DL_TP},${SCELL_EXP_DL_TP}
    ...    tput_check_cell_id=${PCELL_ID},${SCELL_ID}
    ...    source_target_subcell_pa_info=${SCELL_Subcell_1_SwitchTo_Subcell_2_PA}

    [Teardown]     run keyword and ignore error      run keywords    Common case teardown    detach_ue=${True}
    ...    AND    Initialize attenuator values for testline  pa_values_mapping=${CA_PCELL_SCELL_PA_INIT}

CB008985_A6_1_SA_TDD_FR1_call_continuity_during_subcell_switch_including_PCMD_trace_check
    [Tags]  CIT_TRUNK  CIT_23R1
    [Documentation]     Author: Qi Xin
    ...    Description: This case is to verify SA peak tput of one Supercell, UDP
    ...    step 1>  Perform UE attach to subcell-0 and start bi-direction data transmission.
    ...    step 2>  Trigger subcell switch from subcell-0 to subcell-5, then related subcell switch counter M55305C03041 accumulated as 1.
    [Setup]    8985 6xSubcell Case Setup   NSA_SA=SA      is_pdl_checking_needed=${False}
    Adjust PA And Check Attach Status   CA_enable=${False}      pa_values_mapping=${NONCA_SUBCELL0_ATTACH_PA_INIT}
    ...       4G_check=${False}      NSA_SA=${NSA_SA}

    Start data transfer and Check Tput As Expected    cell_id=${PCELL_ID}
    ...    exp_ul_indiv=${SUPERCELL_6SUBCELL_UL_TP}      exp_dl_indiv=${SUPERCELL_6SUBCELL_DL_TP}
    ...    ul_iperf_tput=${UL_TPUT_Iperf}     dl_iperf_tput=${DL_TPUT_Iperf}
    ...    data_transfer_direction=both     customized_log_name=SuperCell_WithoutCA_DLUL_Tput_Check

    #Pcell subcell-0 switch to subcell-5
    Trigger PCELL Subcell Switch And Check Tput BF Counter
    ...    bf_counter_cell_id=${PCELL_ID}    counter_name=${BEAM_CHANGE_0_5_PM}    counter_expected_number=${1}
    ...    tput_check_cell_id=${PCELL_ID}    exp_ul_indiv=${SUPERCELL_6SUBCELL_UL_TP}    exp_dl_indiv=${SUPERCELL_6SUBCELL_DL_TP}
    ...    source_target_subcell_pa_info=${NONCA_Subcell_0_Switch_To_Subcell_5}

    [Teardown]  run keyword and ignore error     run keywords
    ...         Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_SUBCELLS_MUTE}     AND
    ...         Common case teardown    detach_ue=${True}

CB008178-A-TC305-PMO-PDSCH_PUSCH_INIRE_VOL_SSB-CPRI_TDD-SingleUE_subCell_switch-on_SuperCell
    [Tags]  CIT_TRUNK  CIT_23R1
    [Documentation]     Author: Liu Zheng
    ...    step1: UE attach 10 times, check  AVG_RX_PREAMBLE_POWER_SSB and RX_PREAMBLE_PWR_PRACH_LEVEL_** update correctly
    ...    step2: start DL and UL traffic, check PDSCH_INIRE_VOL_SSB，PUSCH_INIRE_VOL_SSB update correctly
    ...    step3: adjust PA to trigger subcell switch,
    ...    redo step1 and step2
    [Setup]     CB008178 Case setup
    Initialize attenuator values for testline    pa_values_mapping=${NONCA_Supercell2_SUBCELL0_ATTACH_PA_INIT}    NSA_SA=SA
    Set higher qRxLevMin via restAPI    cell_id=2
    UE attach several times then check AVG_RX_PREAMBLE_POWER_SSB and RX_PREAMBLE_PWR_PRACH_LEVEL counters
    ...    cell_id=2    subcell_id=0    attach_times=${5}    target_file_name=step1_bip_log_attach_5_times
    UE attach start DL and UL traffic then check PDSCH_INIRE_VOL_SSB and PUSCH_INIRE_VOL_SSB counters
    ...    cell_id=2    subcell_id=0   customized_log_name=step2_supercell_dl_ul_tput_check
    Adjust PA to trigger subcell switch check counters
    ...    cell_id=2    source_subcell_id=0    target_subcell_id=2    source_target_subcell_pa_info=${NONCA_Supercell2_Subcell_0_Switch_To_Subcell_2}
    ...    PA_back_after_subcell_switch=${NONCA_Supercell2_SUBCELL2_ATTACH_PA_INIT}
    UE attach several times then check AVG_RX_PREAMBLE_POWER_SSB and RX_PREAMBLE_PWR_PRACH_LEVEL counters
    ...    cell_id=2    subcell_id=2    attach_times=${5}    target_file_name=step4_bip_log_attach_5_times
    UE attach start DL and UL traffic then check PDSCH_INIRE_VOL_SSB and PUSCH_INIRE_VOL_SSB counters
    ...    cell_id=2    subcell_id=2   customized_log_name=step4_supercell_dl_ul_tput_check    detach_ue=${True}
    [Teardown]     run keyword and ignore error      run keywords    Common case teardown    detach_ue=${True}
    ...    AND    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_SUBCELLS_MUTE}
