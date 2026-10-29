*** Settings ***
Resource    ./../Resources/CB008542_keywords.robot
Resource    ./../../5GC002329/Resources/5GC002329_keywords.robot

Documentation    Suite description
...    author: Zhou Charlie
...    contact: charlie.zhou@nokia-sbell.com
...    squad group: MMW_SG1l
...    Feature CB008542-peak-tput

Force Tags    5G_RRM
...    PY36    RF50

Suite Setup  8542 Suite preparation
Suite Teardown  run keyword and ignore error    CA Suite teardown

*** Variables ***
${PCELL_DL_EXP_TPUT_100M_1116_0}    1490
${PCELL_UL_EXP_TPUT_100M_1116_0_1170}    72
${SCELL_DL_EXP_TPUT_20M_1116_0}     214
${PCELL_UL_EXP_TPUT_100M_1116_0_255}    80
${PCELL_UL_EXP_TPUT_100M_1116_0_10152}    80
${PCELL_UL_EXP_TPUT_100M_1116_0_10359}    80

${ENB_ID}                           ${tl.enbs[0].instance_id}

*** Test Cases ***
CB008542-BA_TC003_Single_UE_EN-DC_connection_setup_and_peak_DL_UL_data_scheduling_blind_1116_0ms_for_NSA_3x_mode
    [Tags]  CIT_TRUNK    CRT_22R3
    [Documentation]     Author: Zhou Charlie
    ...    Description: This case is to verify peak tput of Pcell:100M Scell:20M
    ...    Frame structure 1116_0, prachConfiguration 97, beamset_2, ScellAdditionMethod:blind
    ...    ScellActivationMethod:Bufferbased and with beamforming, UDP
    ...    step 1>  Attach UE to the LTE cell and initiates EN-DC toward the TDD FR1 cell(F1) as PCell
    ...    and with carrier aggregation (FDD cell as SCell)
    ...    step 2>  UE start dL data transfer
    ...    step 3>  UE stop dL data transfer, UE start uL data transfer
    ...    step 4>  UE stop uL data transfer, UE start uL/dL data transfer

    [Setup]     Common case setup   NSA_SA=${NSA_SA}   is_pdl_checking_needed=${true}    is_log_required=${true}
    log to console  there are some interference between Cell1 and Cell5 on TL254. for 8542, only cell-1 and cell-2 and enb needed. so block cell5.
    Run keyword if    '${PROGRAM}' == '23R3'    Perform cell lock via rest api    cell_idx=${5}
    CA_L3_call_tput_DL_UL_Bi
    ...    dl_tput=${DL_TPUT}    ul_tput=${UL_TPUT}
    ...    exp_dl_indiv=${PCELL_DL_EXP_TPUT_100M_1116_0},${SCELL_DL_EXP_TPUT_20M_1116_0}
    ...    exp_ul_indiv=${PCELL_UL_EXP_TPUT_100M_1116_0_${MRBTS_ID}},-1
    ...    tput_duration=300s
    ...    protocol=udp
    ...    ENB_Cellid=${${ENB_Cellid_${MRBTS_ID}}}

    [Teardown]    run keywords    run keyword and ignore error    Run keyword if    '${PROGRAM}' == '23R3'
    ...     Perform cell unlock via rest api     cell_idx=${5}
    ...    AND    run keyword and ignore error    Common case teardown    detach_ue=${True}

CB008542-BA_TC006_Single_UE_EN-DC_connection_setup_and_DL_UL_data_scheduling_in_NSA_option_3X_with_BF_and_A1_A2_measurement_based_SCell_Release
    [Tags]  CRT_TRUNK    CRT_22R3
    [Documentation]     Author: Zhou Charlie
    ...    Description: This case is to verify SCell Addition upon reception of A1 measurement report,
    ...    and SCell Release upon reception of A2 measurement report, check counter.
    ...    Frame structure 1116_0, prachConfiguration 97, beamset_2, ScellAdditionMethod:covBasedA1
    ...    ScellActivationMethod:Bufferbased and with beamforming, UDP
    ...    Precondition:  covBasedA1 configured for Pcell, A2 Meas release for Scell
    ...    Step1:A1 configured after attach with Pcell signal bad
    ...    Step2:A1 report and scell addition , inactivate when Pcell signal change to good
    ...    Step3:Scell activate when DL traffic increase from small to big for bufferbased
    ...    Step4:Scell deactivate when DL traffic stop with Bufferbased
    ...    Step5:A2 report and scell released when pcell signal and scell both in bad
    ...    Step6:Scell addition again when Pcell signal change to Good
    [Setup]    Common case setup    NSA_SA=${NSA_SA}   is_pdl_checking_needed=${true}    is_log_required=${true}
    Modify sCell addition method to covBasedA1    NSA_SA=${NSA_SA}    cell_index=${PCELL_ID}
    ...                                           a1ThresholdSCellAddSsbRsrp_FDD=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}

    Configure A2 Measurement For SCell Release Enabled    cell_index=${SCELL_ID}
    ...                                          a2ThresholdSCellRelSsbRsrp=${A2_THRESHOLD_SCELL_REL_SSB_RSRP}

    ${A1_configured_log_path}    Verify A1 configured and no Scell addition after attach with Pcell signal bad
    ...       exp_pa_value=${PCELL_BAD}         NSA_SA=${NSA_SA}

    ${a1ReportId}        Get reportConfigId for A1 measEvent in cpif log NSA     log_path_pcap=${A1_configured_log_path}
    ...        measEvent=eventA1

    ${case_start_time_info}    Prepare for counter log

    ${A2_configured_log_path}       Verify A1 report and Scell addition but in inactivate when Pcell Signal From Bad To Good NSA
    ...        a1_rsrp_thres=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}      meas_id=${a1ReportId}
    ...        a2_meas_for_scell_released=${True}
    ...        exp_pa_value=${PCELL_GOOD}

    ${a2ReportId}        Get reportConfigId for A2 measEvent in cpif log NSA     log_path_pcap=${A2_configured_log_path}
    ...        measEvent=eventA2

    run keyword and continue on failure    Check Scell activate when DL traffic increase from Small to Big with Bufferbased
    ...       dlTraffic_Small=${PCELL_TDD_DL_TRAFFIC_SMALL}
    ...       dlTraffic_big=${DL_TPUT}

    Check Scell deactivate when DL traffic stop with Bufferbased    scell_operator_mode=dl_only    scell_id=${SCELL_ID}

    A2 report and Scell released when Scell signal in bad NSA
    ...            exp_pa_value_pcell=${PCELL_BAD}         exp_pa_value_scell=${SCELL_A2_RELEASED_PA}
    ...            a2_rsrp_thres=${A2_THRESHOLD_SCELL_REL_SSB_RSRP}       meas_id=${a2ReportId}

    run keyword and continue on failure       check Scell Addition Release Activation Deactivation Counter
    ...      starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}

    Verify scell added again after released when pcell signal back to good
    ...            exp_pa_value_pcell=${INIT_PA_F_T}

    [Teardown]     run keyword and ignore error      run keywords    Common case teardown    detach_ue=${True}
    ...    AND    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_F_T}
