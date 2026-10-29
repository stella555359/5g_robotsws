*** Settings ***
Documentation   This is a keyword file for CB008127, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${cell}                 NRCELL-1


@{a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}   108   104   100  96   92   88   84   80   76
@{a1MeashoSsbRsrq_a1ThresholdhoSsb}              104   100   96   92   88   84   80   76   72
@{a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}  92    88    84   80   76   72   68   64   60
@{a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}    88    84    80   76   72   68   64   60   56
@{a2MeashoSsbRsrp_a2ThresholdhoSsb}              100   96    92   88   84   80   76   72   68
@{a3MeasSsbRsrp_a3OffsetSsb}                     0     2     4    6    8    10   12   14   16
@{a5MeasSsbRsrp_a5Threshold1Ssb}                 82    80    78   76   74   72   70   68   66
@{a5MeasSsbRsrp_a5Threshold2Ssb}                 87    85    83   81   79   77   75   73   71

@{b2Threshold1hoRsrp_b2Threshold1hoRsrq}    ${EMPTY}   70   68   66   64   62   60   58   56
@{b2Threshold2hoRsrp_b2Threshold2hoRsrq}    ${EMPTY}   28   26   24   22   20   18   16   14

${text_M55187C00001}    Number of UE configuration attempts for intra-frequency measurement profiles
${text_M55187C00002}    Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig
${text_M55188C00001}    Number of UE configuration attempts for inter-frequency measurement profiles
${text_M55188C00002}    Not used selections for inter-freq MP due to lack of inter-freq MP parameters in measConfig
${text_M55189C00001}    Number of UE configuration attempts for inter-RAT measurement profiles
${text_M55189C00002}    Not used selections for inter-RAT MP due to lack of inter-RAT MP parameters in measConfig
${text_M55190C00001}    Number of selected measurement profiles for SA
${text_M55190C00002}    Selections of measurement profile mappings for SA when no MP parameters in measConfig are used
${text_M55191C00001}    Number of selected measurement profiles for NSA

*** Keywords ***

Prepare Counters And Expected Values T1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Configuration_of_A2_A3_A5_intraFreq_measurements_with_measurement_profiles_during_context_setup
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-1}             ${text_M55187C00001}     2    ${cell}   NRMIAF-1    MIAF
    Set Test Variable    @{text_M55187C00001-2}             ${text_M55187C00001}     2    ${cell}   NRMIAF-2    MIAF
    Set Test Variable    @{text_M55187C00001-3}             ${text_M55187C00001}     2    ${cell}   NRMIAF-3    MIAF
    Set Test Variable    @{text_M55187C00001-4}             ${text_M55187C00001}     2    ${cell}   NRMIAF-4    MIAF
    Set Test Variable    @{text_M55187C00001-5}             ${text_M55187C00001}     2    ${cell}   NRMIAF-5    MIAF
    Set Test Variable    @{text_M55187C00001-6}             ${text_M55187C00001}     2    ${cell}   NRMIAF-6    MIAF
    Set Test Variable    @{text_M55187C00001-7}             ${text_M55187C00001}     2    ${cell}   NRMIAF-7    MIAF
    Set Test Variable    @{text_M55187C00001-8}             ${text_M55187C00001}     2    ${cell}   NRMIAF-8    MIAF

    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}
    ...                                              M55187C00001-2=${text_M55187C00001-2}
    ...                                              M55187C00001-3=${text_M55187C00001-3}
    ...                                              M55187C00001-4=${text_M55187C00001-4}
    ...                                              M55187C00001-5=${text_M55187C00001-5}
    ...                                              M55187C00001-6=${text_M55187C00001-6}
    ...                                              M55187C00001-7=${text_M55187C00001-7}
    ...                                              M55187C00001-8=${text_M55187C00001-8}

    Set Test Variable    @{text_M55190C00001-1}             ${text_M55190C00001}     2    ${cell}   NRMASA-1    MASA
    Set Test Variable    @{text_M55190C00001-2}             ${text_M55190C00001}     2    ${cell}   NRMASA-2    MASA
    Set Test Variable    @{text_M55190C00001-3}             ${text_M55190C00001}     2    ${cell}   NRMASA-3    MASA
    Set Test Variable    @{text_M55190C00001-4}             ${text_M55190C00001}     2    ${cell}   NRMASA-4    MASA
    Set Test Variable    @{text_M55190C00001-5}             ${text_M55190C00001}     2    ${cell}   NRMASA-5    MASA
    Set Test Variable    @{text_M55190C00001-6}             ${text_M55190C00001}     2    ${cell}   NRMASA-6    MASA
    Set Test Variable    @{text_M55190C00001-7}             ${text_M55190C00001}     2    ${cell}   NRMASA-7    MASA
    Set Test Variable    @{text_M55190C00001-8}             ${text_M55190C00001}     2    ${cell}   NRMASA-8    MASA

    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001-1=${text_M55190C00001-1}
    ...                                              M55190C00001-2=${text_M55190C00001-2}
    ...                                              M55190C00001-3=${text_M55190C00001-3}
    ...                                              M55190C00001-4=${text_M55190C00001-4}
    ...                                              M55190C00001-5=${text_M55190C00001-5}
    ...                                              M55190C00001-6=${text_M55190C00001-6}
    ...                                              M55190C00001-7=${text_M55190C00001-7}
    ...                                              M55190C00001-8=${text_M55190C00001-8}



Prepare Counters And Expected Values T2
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Redirection_based_on_A2_measurements_upon_selected_measurement_profile
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-8}             ${text_M55187C00001}     1    ${cell}   NRMIAF-8    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001-8=${text_M55187C00001-8}

    Set Test Variable    @{text_M55190C00001-8}             ${text_M55190C00001}     1    ${cell}   NRMASA-8    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001-8=${text_M55190C00001-8}



Prepare Counters And Expected Values T3
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Interworking_with_mobility_profiles_during_context_setup
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-5}             ${text_M55187C00001}     2    ${cell}   NRMIAF-5    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001-8=${text_M55187C00001-5}

    Set Test Variable    @{text_M55190C00001-5}             ${text_M55190C00001}     2    ${cell}   NRMASA-5    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001-8=${text_M55190C00001-5}



Prepare Counters And Expected Values T4
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Interworking_with_mobility_profiles_during_context_setup
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-3}             ${text_M55187C00001}     2    ${cell}   NRMIAF-3    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-3}

    Set Test Variable    @{text_M55190C00001-3}             ${text_M55190C00001}     2    ${cell}   NRMASA-3    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-3}



Prepare Counters And Expected Values T5
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Interaction_with_CB009205_A1_based_traffic_steering_to_preferred_NR_layer_during_context_setup
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-6}             ${text_M55187C00001}     1    ${cell}   NRMIAF-6    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-6}

    Set Test Variable    @{text_M55190C00001-6}             ${text_M55190C00001}     1    ${cell}   NRMASA-6    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-6}



Prepare Counters And Expected Values T6
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_A1_based_traffic_steering_to_preferred_NR_layer_after_Xn_HO
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-4}             ${text_M55187C00001}     2    ${cell}   NRMIAF-4    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-4}

    Set Test Variable    @{text_M55190C00001-4}             ${text_M55190C00001}     2    ${cell}   NRMASA-4    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-4}



Prepare Counters And Expected Values T7
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Configuration_of_A2_A3_A5_intraFreq_measurements_during_Xn_HO_using_measurement_profile
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-4}             ${text_M55187C00001}     1    ${cell}   NRMIAF-4    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-4}

    Set Test Variable    @{text_M55190C00001-4}             ${text_M55190C00001}     1    ${cell}   NRMASA-4    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-4}



Prepare Counters And Expected Values T8
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Configuration_of_A2_A3_A5_intraFreq_measurements_during_NG_HO_using_measurement_profile
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-1}             ${text_M55187C00001}     1    ${cell}   NRMIAF-1    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-1}

    Set Test Variable    @{text_M55190C00001-1}             ${text_M55190C00001}     1    ${cell}   NRMASA-1    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-1}


Prepare Counters And Expected Values T9
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_A1_based_traffic_steering_to_preferred_NR_layer_after_NG_HO
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-7}             ${text_M55187C00001}     2    ${cell}   NRMIAF-7    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-7}

    Set Test Variable    @{text_M55190C00001-7}             ${text_M55190C00001}     2    ${cell}   NRMASA-7    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-7}



Prepare Counters And Expected Values T10
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Interworking_with_mobility_profiles_during_Xn_handover
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-8}             ${text_M55187C00001}     2    ${cell}   NRMIAF-8    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-8}

    Set Test Variable    @{text_M55190C00001-8}             ${text_M55190C00001}     2    ${cell}   NRMASA-8    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-8}



Prepare Counters And Expected Values T11
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_InterRAT_handover_with_measurement_profiles
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-7}             ${text_M55187C00001}     3    ${cell}   NRMIAF-7    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-7}

    Set Test Variable    @{text_M55190C00001-7}             ${text_M55190C00001}     4    ${cell}   NRMASA-7    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-7}

    Set Test Variable    @{text_M55189C00001-7}             ${text_M55189C00001}     1    ${cell}   NRMIRF-7    MIRF
    Set Test Variable    &{dict_mirf_counter}
    ...                                              M55189C00001=${text_M55189C00001-7}



Prepare Counters And Expected Values T12
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Removal_of_Inter_RAT_B2_measurement_with_measurement_profiles
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-8}             ${text_M55187C00001}     3    ${cell}   NRMIAF-8    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-8}

    Set Test Variable    @{text_M55190C00001-8}             ${text_M55190C00001}     4    ${cell}   NRMASA-8    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-8}

    Set Test Variable    @{text_M55189C00001-8}             ${text_M55189C00001}     1    ${cell}   NRMIRF-8    MIRF
    Set Test Variable    &{dict_mirf_counter}
    ...                                              M55189C00001=${text_M55189C00001-8}



Prepare Counters And Expected Values T13
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_InterRAT_handover_for_VoNR_call_with_no_5QI_criterion_in_measurement_profiles
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-6}             ${text_M55187C00001}     3    ${cell}   NRMIAF-6    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-6}

    Set Test Variable    @{text_M55190C00001-6}             ${text_M55190C00001}     3    ${cell}   NRMASA-6    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-6}



Prepare Counters And Expected Values T14
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_A1_based_traffic_steering_to_preferred_NR_layer_after_RRC_Re_Establishment
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-3}             ${text_M55187C00001}     1    ${cell}   NRMIAF-3    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-3}

    Set Test Variable    @{text_M55190C00001-3}             ${text_M55190C00001}     1    ${cell}   NRMASA-3    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-3}



Prepare Counters And Expected Values T15
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_RRC_Re_Establishment_during_Xn_HO_with_measurement_profiles
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-4}             ${text_M55187C00001}     2    ${cell}   NRMIAF-4    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-4}

    Set Test Variable    @{text_M55190C00001-4}             ${text_M55190C00001}     2    ${cell}   NRMASA-4    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-4}



Prepare Counters And Expected Values T16
    [Documentation]    [PRIVATE]    set expected values for
    ...                             Second_RRC_Reconfiguration_for_InterFreq_A2_after_Xn_handover_using_measurement_profile
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-6}             ${text_M55187C00001}     3    ${cell}   NRMIAF-6    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-6}

    Set Test Variable    @{text_M55190C00001-6}             ${text_M55190C00001}     3    ${cell}   NRMASA-6    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-6}



Prepare Counters And Expected Values T17
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Second_RRC_Reconfiguration_for_A1_based_traffic_steering_after_Xn_handover
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{miaf6_counter}                  NRCELL-1   NRMIAF-6    MIAF
    Set Test Variable    @{text_M55187C00001-2}             ${text_M55187C00001}     2
    Set Test Variable    &{dict_miaf6_counter}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    Set Test Variable    @{mief1_counter}                  NRCELL-1   NRMIEF-1    MIEF
    Set Test Variable    @{text_M55188C00001-2}             ${text_M55188C00001}     2
    Set Test Variable    &{dict_mief1_counter}
    ...                                              M55188C00001-2=${text_M55188C00001-2}

    Set Test Variable    @{masa5_counter}                  NRCELL-1   NRMASA-5    MASA
    Set Test Variable    @{text_M55190C00001-2}             ${text_M55190C00001}     2
    Set Test Variable    &{dict_masa5_counter}
    ...                                              M55190C00001-2=${text_M55190C00001-2}

    Set Test Variable    @{masa6_counter}                  NRCELL-1   NRMASA-6    MASA
    Set Test Variable    @{text_M55190C00001-2}             ${text_M55190C00001}     2
    Set Test Variable    &{dict_masa6_counter}
    ...                                              M55190C00001-2=${text_M55190C00001-2}


Prepare Counters And Expected Values T18
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Second_RRC_Reconfiguration_using_measurment_profile_after_NG_handover
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-6}             ${text_M55187C00001}     2    ${cell}   NRMIAF-6    MIAF
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001=${text_M55187C00001-6}

    Set Test Variable    @{text_M55190C00001-6}             ${text_M55190C00001}     2    ${cell}   NRMASA-6    MASA
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001=${text_M55190C00001-6}


Prepare Counters And Expected Values T19
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Second_RRC_Reconfiguration_using_measurment_profile_after_NG_handover
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{miaf6_counter}                  NRCELL-1   NRMIAF-6    MIAF
    Set Test Variable    @{text_M55187C00001-2}             ${text_M55187C00001}     5
    Set Test Variable    &{dict_miaf6_counter}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    Set Test Variable    @{mief1_counter}                  NRCELL-1   NRMIEF-1    MIEF
    Set Test Variable    @{text_M55188C00001-2}             ${text_M55188C00001}     1
    Set Test Variable    &{dict_mief1_counter}
    ...                                              M55188C00001-2=${text_M55188C00001-2}

    Set Test Variable    @{mirf6_counter}                  NRCELL-1   NRMIRF-6    MIRF
    Set Test Variable    @{text_M55189C00001-2}             ${text_M55189C00001}     2
    Set Test Variable    &{dict_mirf6_counter}
    ...                                              M55189C00001-2=${text_M55189C00001-2}

    Set Test Variable    @{masa5_counter}                  NRCELL-1   NRMASA-5    MASA
    Set Test Variable    @{text_M55190C00001-2}             ${text_M55190C00001}     1
    Set Test Variable    &{dict_masa5_counter}
    ...                                              M55190C00001-2=${text_M55190C00001-2}

    Set Test Variable    @{masa6_counter}                  NRCELL-1   NRMASA-6    MASA
    Set Test Variable    @{text_M55190C00001-2}             ${text_M55190C00001}     7
    Set Test Variable    &{dict_masa6_counter}
    ...                                              M55190C00001-2=${text_M55190C00001-2}


Prepare Counters And Expected Values T20
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Measurement_profile_selection_without_freqBandIndicatorNR
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-1}             ${text_M55187C00001}     2    ${cell}   NRMIAF-1    MIAF
    Set Test Variable    @{text_M55187C00001-2}             ${text_M55187C00001}     2    ${cell}   NRMIAF-2    MIAF

    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    Set Test Variable    @{text_M55190C00001-1}             ${text_M55190C00001}     2    ${cell}   NRMASA-1    MASA
    Set Test Variable    @{text_M55190C00001-2}             ${text_M55190C00001}     2    ${cell}   NRMASA-2    MASA

    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001-1=${text_M55190C00001-1}
    ...                                              M55190C00001-2=${text_M55190C00001-2}



Prepare Counters And Expected Values T21
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Interworking_with_MFBI_during_ICS_and_after_RRC_Reestablishment
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{miaf_cell1_counter}                  NRCELL-1   NRMIAF-2    MIAF
    Set Test Variable    @{text_M55187C00001-1}             ${text_M55187C00001}     1
    Set Test Variable    &{dict_miaf_cell1_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}

    Set Test Variable    @{masa_cell1_counter}                  NRCELL-1   NRMASA-2    MASA
    Set Test Variable    @{text_M55190C00001-1}             ${text_M55190C00001}     1
    Set Test Variable    &{dict_masa_cell1_counter}
    ...                                              M55190C00001-1=${text_M55190C00001-1}

    Set Test Variable    @{miaf_cell2_counter}                  NRCELL-2   NRMIAF-2    MIAF
    Set Test Variable    @{text_M55187C00001-2}             ${text_M55187C00001}     0
    Set Test Variable    @{text_M55187C00002-1}             ${text_M55187C00002}     1
    Set Test Variable    &{dict_miaf_cell2_counter}
    ...                                              M55187C00001-2=${text_M55187C00001-2}
    ...                                              M55187C00002-1=${text_M55187C00002-1}

    Set Test Variable    @{masa_cell2_counter}                  NRCELL-2   NRMASA-2    MASA
    Set Test Variable    @{text_M55190C00001-2}             ${text_M55190C00001}     0
    Set Test Variable    @{text_M55190C00002-1}             ${text_M55190C00002}     1
    Set Test Variable    &{dict_masa_cell2_counter}
    ...                                              M55190C00001-2=${text_M55190C00001-2}
    ...                                              M55190C00002-1=${text_M55190C00002-1}



Prepare Counters And Expected Values T22
    [Documentation]    [PRIVATE]    set expected values for
    ...                             AB_Interworking_with_MFBI_during_incoming_Xn_handover
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-1}             ${text_M55187C00001}     3    NRCELL-1   NRMIAF-5    MIAF
    Set Test Variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1    NRCELL-2   NRMIAF-7    MIAF

    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}
    ...                                              M55187C00001-2=${text_M55187C00001-2}

    Set Test Variable    @{text_M55190C00001-1}             ${text_M55190C00001}     3    NRCELL-1   NRMASA-5    MASA
    Set Test Variable    @{text_M55190C00001-2}             ${text_M55190C00001}     1    NRCELL-2   NRMASA-7    MASA

    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001-1=${text_M55190C00001-1}
    ...                                              M55190C00001-2=${text_M55190C00001-2}


Prepare Counters And Expected Values T23
    [Documentation]    [PRIVATE]    set expected values for
    ...                             PX_SA_Distribution_of_mapping_selection_and_measurement_profile_usage
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{miaf3_counter}                  NRCELL-1   NRMIAF-3    MIAF
    Set Test Variable    @{text_M55187C00001-2}             ${text_M55187C00001}     2
    Set Test Variable    @{text_M55187C00002-1}             ${text_M55187C00002}     0
    Set Test Variable    &{dict_miaf3_counter}
    ...                                              M55187C00001-2=${text_M55187C00001-2}
    ...                                              M55187C00002-1=${text_M55187C00002-1}

    Set Test Variable    @{miaf4_counter}                  NRCELL-1   NRMIAF-4    MIAF
    Set Test Variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1
    Set Test Variable    @{text_M55187C00002-1}             ${text_M55187C00002}     2
    Set Test Variable    &{dict_miaf4_counter}
    ...                                              M55187C00001-2=${text_M55187C00001-2}
    ...                                              M55187C00002-1=${text_M55187C00002-1}

    Set Test Variable    @{mief1_counter}                  NRCELL-1   NRMIEF-1    MIEF
    Set Test Variable    @{text_M55188C00001-2}             ${text_M55188C00001}     1
    Set Test Variable    @{text_M55188C00002-1}             ${text_M55188C00002}     0
    Set Test Variable    &{dict_mief1_counter}
    ...                                              M55188C00001-2=${text_M55188C00001-2}
    ...                                              M55188C00002-1=${text_M55188C00002-1}

    Set Test Variable    @{mief2_counter}                  NRCELL-1   NRMIEF-2    MIEF
    Set Test Variable    @{text_M55188C00001-2}             ${text_M55188C00001}     1
    Set Test Variable    @{text_M55188C00002-1}             ${text_M55188C00002}     2
    Set Test Variable    &{dict_mief2_counter}
    ...                                              M55188C00001-2=${text_M55188C00001-2}
    ...                                              M55188C00002-1=${text_M55188C00002-1}

    Set Test Variable    @{mirf3_counter}                  NRCELL-1   NRMIRF-3    MIRF
    Set Test Variable    @{text_M55189C00001-2}             ${text_M55189C00001}     1
    Set Test Variable    @{text_M55189C00002-1}             ${text_M55189C00002}     0
    Set Test Variable    &{dict_mirf3_counter}
    ...                                              M55189C00001-2=${text_M55189C00001-2}
    ...                                              M55189C00002-1=${text_M55189C00002-1}

    Set Test Variable    @{mirf4_counter}                  NRCELL-1   NRMIRF-4    MIRF
    Set Test Variable    @{text_M55189C00001-2}             ${text_M55189C00001}     1
    Set Test Variable    @{text_M55189C00002-1}             ${text_M55189C00002}     2
    Set Test Variable    &{dict_mirf4_counter}
    ...                                              M55189C00001-2=${text_M55189C00001-2}
    ...                                              M55189C00002-1=${text_M55189C00002-1}

    Set Test Variable    @{masa3_counter}                  NRCELL-1   NRMASA-3    MASA
    Set Test Variable    @{text_M55190C00001-2}             ${text_M55190C00001}     4
    Set Test Variable    @{text_M55190C00002-1}             ${text_M55190C00002}     0
    Set Test Variable    &{dict_masa3_counter}
    ...                                              M55190C00001-2=${text_M55190C00001-2}
    ...                                              M55190C00002-1=${text_M55190C00002-1}

    Set Test Variable    @{masa4_counter}                  NRCELL-1   NRMASA-4    MASA
    Set Test Variable    @{text_M55190C00001-2}             ${text_M55190C00001}     3
    Set Test Variable    @{text_M55190C00002-1}             ${text_M55190C00002}     6
    Set Test Variable    &{dict_masa4_counter}
    ...                                              M55190C00001-2=${text_M55190C00001-2}
    ...                                              M55190C00002-1=${text_M55190C00002-1}
