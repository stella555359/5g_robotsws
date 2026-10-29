*** Settings ***
Documentation
...   author: Marcin Wolczynski
...   contact: marcin.wolczynski@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB009142


Library      taf.ue
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009142/resources/test_specific_keywords_9142.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC007949/resources/test_specific_keywords.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod  WITH NAME  TcpdumpSmod
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py


*** Variables ***
${auto_responder_number}=  +555800903300998
${cells_to_be_locked}=      1
${first_pcap_name}=         1
${pm_interval_8021}=        15
@{counter_ids}  M55125C09014   M55125C09015
@{counter_ids_NSA}  M55114C00018   M55114C00016
${pm_interval_CNI}=        5
@{counter_actual_eirp}               M55324C00101    M55324C00102    M55324C00103    M55324C00104    M55324C00105
...                                  M55324C00106    M55324C00107    M55324C00108    M55324C00109
@{counter_maximum_eirp}              M55324C00201    M55324C00202    M55324C00203    M55324C00204    M55324C00205
...                                  M55324C00206    M55324C00207    M55324C00208    M55324C00209
@{counter_control_eirp}              M55324C00301    M55324C00302    M55324C00303    M55324C00304    M55324C00305
...                                  M55324C00306    M55324C00307    M55324C00308    M55324C00309
@{counter_maximum_sliding_eirp}      M55324C00501    M55324C00502    M55324C00503    M55324C00504    M55324C00505
...                                  M55324C00506    M55324C00507    M55324C00508    M55324C00509
@{counter_minimum_sliding_eirp}      M55324C00601    M55324C00602    M55324C00603    M55324C00604    M55324C00605
...                                  M55324C00606    M55324C00607    M55324C00608    M55324C00609
@{counter_actual_sliding_eirp}       M55324C00701    M55324C00702    M55324C00703    M55324C00704    M55324C00705
...                                  M55324C00706    M55324C00707    M55324C00708    M55324C00709
@{counter_power_beam}                M55324C00400    M55324C00401    M55324C00402    M55324C00403    M55324C00404
...                                  M55324C00405    M55324C00406    M55324C00407    M55324C00408    M55324C00409
@{counter_power_cell}                M55324C00464
@{counter_max_cell_power_sliding}    M55324C00800
@{counter_min_cell_power_sliding}    M55324C00801
@{counter_cell_power_sliding}        M55324C00802
${expected_value}     0
${cell}     11
${pm_interval_CNI_TC01}     10

*** Keywords ***
CB009142_01_A_Supercell_with_6_subcells_activation_deactivation_with_VoNR_SA
    ${pre_change_scf}           test_specific_keywords_9142.Backup SCF
    test_specific_keywords_9142.upload scf  A1
    supercell activation 9142    cni_test
    AdminUtils.Lock Cells    ${cells_to_be_locked}
    log to console       Cell locked
    nullify_supercell_attenuation  1st
    start logging   1_A_${first_pcap_name}
    BuiltIn.Sleep   20s
    Require UE   UE_1   capabilities=SA_UE
    Attach UE    UE_1
    taf.ue.Start Voice Call    vc_alias=VOICE_CALL    ue_alias=UE_1    to= ${auto_responder_number}  duration=1000s
    attenuation_6supercells
    BuiltIn.Sleep   10s
    taf.ue.Stop Voice Call    vc_alias=VOICE_CALL
    BuiltIn.Sleep   15s
    test_specific_keywords_9142.Check 5qi Setup  pcap_file=${LOG_PATH}/CB009142_1_A_1_tcpdump_SMOD_MASTER.pcap
    verify_ssb_messages  ${LOG_PATH}/CB009142_1_A_index_L1L2.pcap  5
    [Teardown]   Run Keywords
    ...          AdminUtils.Unlock All Cells   AND
    ...          supercell deactivation 9142    cni_test    AND
    ...          Run Keyword And Ignore Error  stop logging    teardown=True   AND
    ...          taf.ue.Detach Ue  UE_1    AND
    ...          testline_preparation.load_scf     ${pre_change_scf}    False


CB009142_01_B_Supercell_with_6_subcells_activation_deactivation_with_VoNR_stablishment_on_each_subcell_SA
    ${pre_change_scf}           test_specific_keywords_9142.Backup SCF
    test_specific_keywords_9142.upload scf   A1
    supercell activation 9142
    AdminUtils.Lock Cells    ${cells_to_be_locked}
    log to console       Cell locked
    nullify_supercell_attenuation  1st
    start logging   1_B_${first_pcap_name}
    BuiltIn.Sleep   10s
    Require UE   UE_1   capabilities=SA_UE
    Attach UE    UE_1
    attenuation_each_6scells  ${auto_responder_number}
    verify_5qi_in_files  ${LOG_PATH}/CB009142_1_B_index_tcpdump_SMOD_MASTER.pcap
    verify_ssb_messages  ${LOG_PATH}/CB009142_1_B_index_L1L2.pcap
    [Teardown]   Run Keywords
    ...          AdminUtils.Unlock All Cells   AND
    ...          supercell deactivation 9142  AND
    ...          Run Keyword And Ignore Error  stop logging    teardown=True   AND
    ...          taf.ue.Detach Ue  UE_1    AND
     ...         testline_preparation.load_scf     ${pre_change_scf}    False


CB009142_02_2_supercells_with_2_and_4_subcells_inter_freq_handover_between_supercells_NSA
    ${pre_change_scf}           test_specific_keywords_9142.Backup SCF
    test_specific_keywords_9142.upload scf   A2
    AdminUtils.Lock Cells    ${cells_to_be_locked}
    log to console       Cell locked
    nullify_supercell_attenuation  1st  FDD/TDD

    log to console       >>>>>>>>>> waiting for next pm interval <<<<<<<<<<<<<<<<<<
    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}
    start logging   2_${first_pcap_name}
    BuiltIn.Sleep   10s
    Require UE   UE_1   capabilities=NSA_UE
    Attach UE    UE_1
    log to console     >>>>>>>>>>> tput starting <<<<<<<<<<<<<<<<<<<<<
    Throughput_start_UL_DL
    BuiltIn.Sleep    10s
    check_data_transfer_is_alive    dt_name=DT_DL
    check_data_transfer_is_alive    dt_name=DT_UL

    log to console       >>>>>>>>>> starting handovers <<<<<<<<<<<<<<<<<<
    handover_cell  1st  2nd  3rd  2_  ${True}
    handover_cell  3rd  4th  5th  2_  ${True}
    handover_cell  5th  6th  FDD/TDD  2_  ${True}

    log to console   >>>>>>>>>>>>>>> Stop data transfer <<<<<<<<<<<<<<<<<<<<<<<<<<
    Stop data transfer    dt_name=DT_UL
    Stop data transfer    dt_name=DT_DL

    log to console   >>>>>>>>>>>>>>> Detach UE <<<<<<<<<<<<<<<<<<<<<<<<<<
    taf.ue.Detach Ue  UE_1

    log to console   >>>>>>>>>>>>>>> Counter collecting and verification <<<<<<<<<<<<<<<<<<<<<<<<<<
    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}

    ${counter_dir}  Collect Counters For Testcase  A2
    ${counters}  Get and verify counters  ${counter_dir}  ${counter_ids_NSA}
    Check if HO Counters Incremented A2 A3  ${counters}

    log to console   >>>>>>>>>>>>>>> Subcell ID verification <<<<<<<<<<<<<<<<<<<<<<<<<<

    verify_ssb_messages  ${LOG_PATH}/CB009142_2_index_L1L2.pcap  5

    [Teardown]   Run Keywords
    ...          AdminUtils.Unlock All Cells   AND
    ...          Run Keyword And Ignore Error  stop logging    teardown=True   AND
    ...          Run Keyword And Ignore Error  taf.ue.Detach Ue  UE_1    AND
    ...          testline_preparation.load_scf     ${pre_change_scf}    False


CB009142_03_Supercell_with_3_subcells_handover_to_normal_cell_TDD_NSA
    ${pre_change_scf}           test_specific_keywords_9142.Backup SCF
    test_specific_keywords_9142.upload scf  A3
    AdminUtils.Lock Cells    ${cells_to_be_locked}
    log to console       Cell locked
    nullify_supercell_attenuation  1st  FDD/TDD
    log to console       >>>>>>>>>> waiting for next pm interval <<<<<<<<<<<<<<<<<<
    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}
    start logging   3_${first_pcap_name}
    BuiltIn.Sleep   10s
    Require UE   UE_1   capabilities=NSA_UE
    Attach UE    UE_1
    log to console     >>>>>>>>>>> tput starting <<<<<<<<<<<<<<<<<<<<<
    Throughput_start_UL_DL
    BuiltIn.Sleep   10s
    check_data_transfer_is_alive    dt_name=DT_DL
    check_data_transfer_is_alive    dt_name=DT_UL

    attenuation_3_scells

    log to console   >>>>>>>>>>>>>>> Stop data transfer <<<<<<<<<<<<<<<<<<<<<<<<<<
    Stop data transfer    dt_name=DT_UL
    Stop data transfer    dt_name=DT_DL

    log to console   >>>>>>>>>>>>>>> Counter collecting waiting for next pm <<<<<<<<<<<<<<<<<<<<<<<<<<
    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}

    log to console   >>>>>>>>>>>>>>> Counter collecting <<<<<<<<<<<<<<<<<<<<<<<<<<
    ${counter_dir}  Collect Counters For Testcase  A3
    ${counters}  Get and verify counters  ${counter_dir}  ${counter_ids_NSA}

    log to console   >>>>>>>>>>>>>>> Subcell ID and counter verification <<<<<<<<<<<<<<<<<<<<<<<<<<

    test_specific_keywords_9142.Check if HO Counters Incremented A2 A3   ${counters}
    verify_ssb_messages  ${LOG_PATH}/CB009142_3_index_L1L2.pcap  2

    [Teardown]   Run Keywords
    ...          AdminUtils.Unlock All Cells   AND
    ...          Run Keyword And Ignore Error  stop logging    teardown=True   AND
    ...          taf.ue.Detach Ue  UE_1    AND
    ...          testline_preparation.load_scf     ${pre_change_scf}    False


CB009142_04_3_Supercells_with_2_subcells_handover_to_normal_cell_FDD_SA
    ${pre_change_scf}           test_specific_keywords_9142.Backup SCF
    test_specific_keywords_9142.upload scf   A4
    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}
    nullify_supercell_attenuation  1st
    start logging   4_${first_pcap_name}
    BuiltIn.Sleep   5s
    Require UE   UE_1   capabilities=SA_UE
    Attach UE    UE_1
    Throughput_start_UL_DL
    BuiltIn.Sleep   20s
    handover_cell  1st  2nd  3rd  4_
    handover_cell  3rd  4th  5th  4_
    handover_cell  5th  6th  FDD/TDD  4_
    BuiltIn.Sleep   20s
    Stop data transfer    dt_name=DT_UL
    Stop data transfer    dt_name=DT_DL
    Verify average throughput    dt_name=DT_DL    tput_min=1Mbits/sec
    Verify average throughput    dt_name=DT_UL    tput_min=1Mbits/sec
    BuiltIn.Sleep   15s
    GnbCounter.Wait for next pm period   interval=${pm_interval_8021}
    ${counter_dir}  Collect Counters For Testcase  A4
    ${counters}  Get and verify counters  ${counter_dir}  ${counter_ids}
    Check If HO Counters Incremented  ${counters}
    verify_ssb_messages  ${LOG_PATH}/CB009142_4_index_L1L2.pcap  3

    [Teardown]   Run Keywords
    ...          Run Keyword And Ignore Error  stop logging    teardown=True    AND
    ...          taf.ue.Detach Ue    UE_1    AND
    ...          testline_preparation.load_scf     ${pre_change_scf}    False


CNI113672_CB009142_01_Supercell_with_6_subcells_activation_deactivation_with_VoNR_SA_EIRP_counters
    ${pre_change_scf}           test_specific_keywords_9142.Backup SCF
    test_specific_keywords_9142.upload scf  A1
    log to console       >>>>>>>>>> waiting for next pm interval normal cell eirp <<<<<<<<<<<<<<<<<<
    GnbCounter.Wait for next pm period                interval=${pm_interval_CNI_TC01}
    @{counters_to_check}    Combine Lists
     ...   ${counter_actual_eirp}              ${counter_maximum_eirp}            ${counter_control_eirp}
    ...    ${counter_maximum_sliding_eirp}     ${counter_minimum_sliding_eirp}    ${counter_actual_sliding_eirp}
    ...    ${counter_power_beam}               ${counter_power_cell}              ${counter_max_cell_power_sliding}
    ...    ${counter_min_cell_power_sliding}   ${counter_cell_power_sliding}
    ${counter_dir}  Collect Counters For Testcase     CNI
    ${counters}  Get and verify counters  ${counter_dir}  ${counters_to_check}
    Check CNI counters   ${cell}   ${counters}    ${expected_value}    1
    supercell activation 9142   cni_test

    log to console       >>>>>>>>>> waiting for next pm interval supercell eirp <<<<<<<<<<<<<<<<<<
    GnbCounter.Wait for next pm period               interval=${pm_interval_CNI_TC01}
    ${counter_dir}  Collect Counters For Testcase    CNI
    ${counters}  Get and verify counters  ${counter_dir}  ${counters_to_check}
    Check CNI counters    ${cell}   ${counters}    ${expected_value}    6

    AdminUtils.Lock cells    ${cells_to_be_locked}
    log to console       Cell locked
    nullify_supercell_attenuation  1st
    start logging TTI   1_A_${first_pcap_name}
    BuiltIn.Sleep   20s

    log to console       >>>>>>>>>> attach starting <<<<<<<<<<<<<<<<<<
    Require UE   UE_1   capabilities=SA_UE
    Attach UE    UE_1
    Throughput_start_UL_DL
    BuiltIn.Sleep    10s
    check_data_transfer_is_alive    dt_name=DT_DL
    check_data_transfer_is_alive    dt_name=DT_UL
    taf.ue.Start Voice Call    vc_alias=VOICE_CALL    ue_alias=UE_1    to= ${auto_responder_number}  duration=1000s

    log to console       >>>>>>>>>> switch 6 subcell starting <<<<<<<<<<<<<<<<<<
    ${path_list}     attenuation_6supercells with TTI
    check_data_transfer_is_alive    dt_name=DT_DL
    check_data_transfer_is_alive    dt_name=DT_UL
    log to console    ${path list}
    BuiltIn.Sleep    10s
    taf.ue.Stop Voice Call    vc_alias=VOICE_CALL
    Stop data transfer    dt_name=DT_UL
    Stop data transfer    dt_name=DT_DL
    BuiltIn.Sleep    15s
    test_specific_keywords_9142.Check 5qi Setup  pcap_file=${LOG_PATH}/supercell_1_A_1_tcpdump_SMOD_MASTER.pcap
    ${rntis}=   find_exactly_x_attached_rntis    ${LOG_PATH}/supercell_1_A_1_tcpdump_SMOD_MASTER.pcap     1
    log to console      ${rntis}
    verify_current_subcell  ${path_list}   ${rntis[0]}    6
    [Teardown]   Run Keywords
    ...          AdminUtils.Unlock All Cells   AND
    ...          supercell deactivation 9142    cni_test   AND
    ...          Run Keyword And Ignore Error  stop logging    teardown=True   AND
    ...          taf.ue.Detach Ue  UE_1    AND
    ...          testline_preparation.load_scf     ${pre_change_scf}    False


CNI113672_02_Supercells_with_2_and_4_subcells_switch_between_different_power_reduction_factor_eirp_counters
    ${pre_change_scf}           test_specific_keywords_9142.Backup SCF
    test_specific_keywords_9142.upload scf   A2
    AdminUtils.Lock Cells    ${cells_to_be_locked}
    log to console       Cell locked
    nullify_supercell_attenuation  4th
    @{counters_to_check}    Combine Lists
    ...    ${counter_actual_eirp}              ${counter_maximum_eirp}            ${counter_control_eirp}
    ...    ${counter_maximum_sliding_eirp}     ${counter_minimum_sliding_eirp}    ${counter_actual_sliding_eirp}
    ...    ${counter_power_beam}               ${counter_power_cell}              ${counter_max_cell_power_sliding}
    ...    ${counter_min_cell_power_sliding}   ${counter_cell_power_sliding}

    log to console       >>>>>>>>>> attach starting <<<<<<<<<<<<<<<<<<
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    BuiltIn.Sleep   10s
    Require UE   UE_1   capabilities=SA_UE
    Attach UE    UE_1
    log to console     >>>>>>>>>>> tput starting <<<<<<<<<<<<<<<<<<<<<
    Throughput_start_UL_DL        100 Mbits/sec
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    log to console       >>>>>>>>>> waiting for next pm interval attach tput <<<<<<<<<<<<<<<<<<
    GnbCounter.Wait for next pm period   interval=${pm_interval_CNI}
    log to console       >>>>>>>>>> waiting for next pm interval UE in cell 12 2nd subcell  <<<<<<<<<<<<<<<<<<
    GnbCounter.Wait for next pm period   interval=${pm_interval_CNI}
    BuiltIn.Sleep    10s
    check_data_transfer_is_alive    dt_name=DT_DL
    check_data_transfer_is_alive    dt_name=DT_UL

    log to console       >>>>>>>>>> starting switch/handovers <<<<<<<<<<<<<<<<<<
    ${path_list}    single_switch_or_ho_with_TTI   4th      5th    1
    check_data_transfer_is_alive    dt_name=DT_DL
    check_data_transfer_is_alive    dt_name=DT_UL

    log to console       >>>>>>>>>> waiting for next pm interval switch <<<<<<<<<<<<<<<<<<
    GnbCounter.Wait for next pm period   interval=${pm_interval_CNI}
    log to console       >>>>>>>>>> waiting for next pm interval UE in cell 12 subcell 3rd <<<<<<<<<<<<<<<<<<
    GnbCounter.Wait for next pm period   interval=${pm_interval_CNI}

    log to console   >>>>>>>>>>>>>>> Counter collecting and verification <<<<<<<<<<<<<<<<<<<<<<<<<<
    ${counter_dir}  Collect Counters For Testcase  CNI_2
    ${counters}  Get and verify counters   ${counter_dir}   ${counters_to_check}

    log to console   >>>>>>>>>>>>>>> Stop data transfer and detach UE <<<<<<<<<<<<<<<<<<<<<<<<<<
    Stop data transfer    dt_name=DT_UL
    Stop data transfer    dt_name=DT_DL
    taf.ue.Detach Ue  UE_1

    log to console   >>>>>>>>>>>>>>> Subcell ID verification <<<<<<<<<<<<<<<<<<<<<<<<<<
    ${rnti}=   Find Exactly X Attached RNTIs    ${sctp_logs}   1
    verify_current_subcell  ${path_list}   ${rnti[0]}    2

    log to console   >>>>>>>>>>>>>>> Check CNI counters <<<<<<<<<<<<<<<<<<<<<<<<<<
    Check CNI counters    12   ${counters}    ${expected_value}    4    tput
    compare_different_power_reduction   12    ${counters}     2    3

    [Teardown]   Run Keywords
    ...          AdminUtils.Unlock All Cells   AND
    ...          Run Keyword And Ignore Error  stop logging    teardown=True   AND
    ...          Run Keyword And Ignore Error  taf.ue.Detach Ue  UE_1     AND
    ...          testline_preparation.load_scf     ${pre_change_scf}    False

############################# Other kewords #######################################

Make Counter Logs Path
    [Arguments]    ${logs_names}
    ${target_dir} =  Set Variable  ${OUTPUT DIR}/counters/${logs_names}
    [Return]    ${target_dir}

Collect Counters For Testcase
    [Arguments]  ${testcase}
    ${pi_dir} =   Collect Counters    log_name=${testcase}  target_dir=${OUTPUT DIR}/counters
    Log  ${pi_dir}  console=True
    [Return]  ${pi_dir}

Throughput_start_UL_DL
    [Arguments]     ${tput}=5 Mbits/sec
    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                   direction=dl     duration=10000s
    ...                   packet_size=1200            throughput=${tput}              protocol=udp
    ...                   iperf_version=2
    Start data transfer   dt_name=DT_UL               ue_alias=UE_1                   direction=ul     duration=10000s
    ...                   packet_size=1200            throughput=2 Mbits/sec         protocol=udp
    ...                   iperf_version=2
    check_data_transfer_is_alive    dt_name=DT_UL
    check_data_transfer_is_alive    dt_name=DT_DL
    log to console      Tput transfer started
