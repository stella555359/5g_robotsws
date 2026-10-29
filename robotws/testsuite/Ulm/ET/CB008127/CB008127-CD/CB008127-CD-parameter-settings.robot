*** Settings ***
Documentation   This is a keyword file for CB008127-CD, part parameter settings
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

@{a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}   0    96    100    98
@{a1MeashoPrefNRLayerSsbRsrq_a1ThresholdhoSsb}   0    95    99
@{a1MeashoSsbRsrp_a1ThresholdhoSsb}              0    92    96     94
@{a1MeashoSsbRsrq_a1ThresholdhoSsb}              0    91    95
@{a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}    0    78    82     80
@{a2MeasReleaseSsbRsrq_a2ThresholdReleaseSsb}    0    77    81
@{a2MeashoSsbRsrp_a2ThresholdhoSsb}              0    88    92     90
@{a2MeashoSsbRsrq_a2ThresholdhoSsb}              0    87    91
@{a3MeasSsbRsrp_a3OffsetSsb}                     0     6     4     5
@{a3MeasSsbRsrq_a3OffsetSsb}                     0     5     3
@{a5MeasSsbRsrp_a5Threshold1Ssb}                 0     76    78    77
@{a5MeasSsbRsrp_a5Threshold2Ssb}                 0     81    83    82
@{a5MeasSsbRsrq_a5Threshold1Ssb}                 0     75    77
@{a5MeasSsbRsrq_a5Threshold2Ssb}                 0     80    82

@{uePowerClass_item1}                            0     ue-PowerClass2    ue-PowerClass1Dot5
@{uePowerClass_item2}                            0     ue-PowerClass3    ue-PowerClass5

@{IEF_a3OffsetSsbRsrp}                 0     2       4        4
@{IEF_a3OffsetSsbRsrq}                 0     3       5        5
@{IEF_a4ThresholdSsbRsrp}              0     30      25       60
@{IEF_a4ThresholdSsbRsrq}              0     31      26       61
@{IEF_a4TimeToTriggerSsbRsrp_Rsrq}     0     ms64    ms40     ms40
@{IEF_a5Threshold1SsbRsrp}             0     64      60       66
@{IEF_a5Threshold2SsbRsrp}             0     69      70       71
@{IEF_a5Threshold1SsbRsrq}             0     65      61       67
@{IEF_a5Threshold2SsbRsrq}             0     70      71       72



${text_M55187C00001}    Number of UE configuration attempts for intra-frequency measurement profiles
${text_M55187C00002}    Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig
${text_M55188C00001}    Number of UE configuration attempts for inter-frequency measurement profiles
${text_M55188C00002}    Not used selections for inter-freq MP due to lack of inter-freq MP parameters in measConfig
${text_M55189C00001}    Number of UE configuration attempts for inter-RAT measurement profiles
${text_M55191C00001}    Number of selected measurement profiles for NSA
${text_M55191C00002}    Selections of measurement profile mappings for NSA when no MP parameters in measConfig are used

*** Keywords ***

prepare counters and expected values t1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB008127_CD_Configuration_of_intraFreq_meas_A2_A3_A5_during_SgNB_addition_using_selected_meas_profile_for_NSA
    ...       :Autor: Sylvia Schneider

    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     1    NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1    NRCELL-1   NRMIAF-2    MIAF

    set test variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    set test variable    @{text_M55191C00001-1}             ${text_M55191C00001}     1    NRCELL-1   NRMNSA-1    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     1    NRCELL-1   NRMNSA-2    MNSA

    set test variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}
    ...                                              M55191C00001-2=${text_M55191C00001-2}


prepare counters and expected values t2
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB008127_CD_Configuration_of_intraFreq_meas_A2_A3_A5_during_MeNB_initiated_SgNB_Modification_using_meas_profile
    ...       :Autor: Sylvia Schneider

    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     1    NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1    NRCELL-2   NRMIAF-1    MIAF

    set test variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    set test variable    @{text_M55191C00001-1}             ${text_M55191C00001}     1    NRCELL-1   NRMNSA-1    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     1    NRCELL-2   NRMNSA-1    MNSA

    set test variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}
    ...                                              M55191C00001-2=${text_M55191C00001-2}


prepare counters and expected values t3
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB008127_CD_Configuration_of_A2_measurement_using_measurement_profile_upon_A1_measurement_report
    ...       :Autor: Sylvia Schneider

    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     3    NRCELL-1   NRMIAF-1    MIAF

    set test variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}

    set test variable    @{text_M55191C00001-1}             ${text_M55191C00001}     3    NRCELL-1   NRMNSA-1    MNSA

    set test variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}


prepare counters and expected values t4
    [Documentation]    [PRIVATE]    set expected values for
    ...                         CB008127_CD_Configuration_of_intraFreq_measurements_during_interMeNB_handover_with_PSCell_change_using_meas_profile
    ...       :Autor: Sylvia Schneider

    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     2    NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1    NRCELL-2   NRMIAF-1    MIAF

    set test variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    set test variable    @{text_M55191C00001-1}             ${text_M55191C00001}     2    NRCELL-1   NRMNSA-1    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     1    NRCELL-2   NRMNSA-1    MNSA

    set test variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}
    ...                                              M55191C00001-2=${text_M55191C00001-2}


prepare counters and expected values t5
    [Documentation]    [PRIVATE]    set expected values for
    ...                         CB008127_CD_Interaction_with_mobility_profiles_and_MFBI_during_PS_cell_change_using_measurement_profile
    ...       :Autor: Sylvia Schneider

    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     3    NRCELL-1   NRMIAF-1    MIAF

    set test variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}

    set test variable    @{text_M55191C00001-1}             ${text_M55191C00001}     3    NRCELL-1   NRMNSA-3    MNSA

    set test variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}


prepare counters and expected values t6
    [Documentation]    [PRIVATE]    set expected values for
    ...                         CB008127_CD_Interaction_with_MFBI_and_A1_based_traffic_steering_to_preferred_NR_layer_after_SgNB_addition
    ...       :Autor: Sylvia Schneider

    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     2    NRCELL-1   NRMIAF-3    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1    NRCELL-2   NRMIAF-3    MIAF

    set test variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    set test variable    @{text_M55191C00001-1}             ${text_M55191C00001}     2    NRCELL-1   NRMNSA-3    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     1    NRCELL-2   NRMNSA-3    MNSA

    set test variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}
    ...                                              M55191C00001-2=${text_M55191C00001-2}


prepare counters and expected values t7
    [Documentation]    [PRIVATE]    set expected values for
    ...                         CB008127_PX_NSA_Distribution_of_mapping_selection_and_measurement_profile_usage
    ...       :Autor: Sylvia Schneider

    set test variable    @{miaf1_counter}                  NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     2
    set test variable    @{text_M55187C00002-1}             ${text_M55187C00002}     1
    set test variable    &{dict_miaf1_counter}
    ...                                              M55187C00001-2=${text_M55187C00001-2}
    ...                                              M55187C00002-1=${text_M55187C00002-1}

    set test variable    @{mief1_counter}                  NRCELL-1   NRMIEF-1    MIEF
    set test variable    @{text_M55188C00001-2}             ${text_M55188C00001}     1
    set test variable    @{text_M55188C00002-1}             ${text_M55188C00002}     1
    set test variable    &{dict_mief1_counter}
    ...                                              M55188C00001-2=${text_M55188C00001-2}
    ...                                              M55188C00002-1=${text_M55188C00002-1}

    set test variable    @{mnsa1_counter}                  NRCELL-1   NRMNSA-1    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     3
    set test variable    @{text_M55191C00002-1}             ${text_M55191C00002}     2
    set test variable    &{dict_mnsa1_counter}
    ...                                              M55191C00001-2=${text_M55191C00001-2}
    ...                                              M55191C00002-1=${text_M55191C00002-1}


prepare counters and expected values t8
    [Documentation]    [PRIVATE]    set expected values for
    ...                         CB008127_PX_Measurement_profile_selection_without_freqBandIndicatorNR_for_NSA
    ...       :Autor: Sylvia Schneider

    set test variable    @{miaf1_counter}                  NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1
    set test variable    &{dict_miaf1_counter}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    set test variable    @{miaf3_counter}                  NRCELL-1   NRMIAF-3    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1
    set test variable    &{dict_miaf3_counter}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    set test variable    @{mief1_counter}                  NRCELL-1   NRMIEF-1    MIEF
    set test variable    @{text_M55188C00001-2}             ${text_M55188C00001}     1
    set test variable    &{dict_mief1_counter}
    ...                                              M55188C00001-2=${text_M55188C00001-2}

    set test variable    @{mnsa1_counter}                  NRCELL-1   NRMNSA-1    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     2
    set test variable    &{dict_mnsa1_counter}
    ...                                              M55191C00001-2=${text_M55191C00001-2}

    set test variable    @{mnsa3_counter}                  NRCELL-1   NRMNSA-3    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     1
    set test variable    &{dict_mnsa3_counter}
    ...                                              M55191C00001-2=${text_M55191C00001-2}


prepare counters and expected values t9
    [Documentation]    [PRIVATE]    set expected values for
    ...                         CB008127_MN_Measurement_profile_reselection_due_to_frequenz_band_change_during_MeNB_mobility_scenario
    ...       :Autor: Sylvia Schneider

    set test variable    @{miaf2_counter}                  NRCELL-1   NRMIAF-2    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1
    set test variable    &{dict_miaf2_counter}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    set test variable    @{miaf3_counter}                  NRCELL-1   NRMIAF-3    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     2
    set test variable    &{dict_miaf3_counter}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    set test variable    @{mief2_counter}                  NRCELL-1   NRMIEF-2    MIEF
    set test variable    @{text_M55188C00001-2}             ${text_M55188C00001}     1
    set test variable    @{text_M55188C00002-1}             ${text_M55188C00002}     1
    set test variable    &{dict_mief2_counter}
    ...                                              M55188C00001-2=${text_M55188C00001-2}
    ...                                              M55188C00002-1=${text_M55188C00002-1}

    set test variable    @{mief3_counter}                  NRCELL-1   NRMIEF-3    MIEF
    set test variable    @{text_M55188C00001-2}             ${text_M55188C00001}     0
    set test variable    &{dict_mief3_counter}
    ...                                              M55188C00001-2=${text_M55188C00001-2}

    set test variable    @{mnsa2_counter}                  NRCELL-1   NRMNSA-2    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     2
    set test variable    @{text_M55191C00002-1}             ${text_M55191C00002}     1
    set test variable    &{dict_mnsa2_counter}
    ...                                              M55191C00001-2=${text_M55191C00001-2}
    ...                                              M55191C00002-1=${text_M55191C00002-1}

    set test variable    @{mnsa3_counter}                  NRCELL-1   NRMNSA-3    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     2
    set test variable    &{dict_mnsa3_counter}
    ...                                              M55191C00001-2=${text_M55191C00001-2}
