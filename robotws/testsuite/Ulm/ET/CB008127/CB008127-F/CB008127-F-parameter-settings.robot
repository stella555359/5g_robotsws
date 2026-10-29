*** Settings ***
Documentation   This is a keyword file for CB008127, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${cell}                 NRCELL-1


@{IAF_a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}   ${EMPTY}   88    84    80         96
@{IAF_a1MeashoSsbRsrp_a1ThresholdhoSsb}              ${EMPTY}   96    92    72         100
@{IAF_a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}  ${EMPTY}   84    80    58         88
@{IAF_a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}    ${EMPTY}   80    76    ${EMPTY}   80
@{IAF_a2MeashoSsbRsrp_a2ThresholdhoSsb}              ${EMPTY}   92    88    68         92
@{IAF_a3MeasSsbRsrp_a3OffsetSsb}                     ${EMPTY}   4     6     8          2
@{IAF_a5MeasSsbRsrp_a5Threshold1Ssb}                 ${EMPTY}   78    76    66         80
@{IAF_a5MeasSsbRsrp_a5Threshold2Ssb}                 ${EMPTY}   83    81    71         85

@{IEF_a3OffsetSsbRsrp}            ${EMPTY}     2      3      5
@{IEF_a3OffsetSsbRsrq}            ${EMPTY}     3      4      6
@{IEF_a4ThresholdSsbRsrp}         ${EMPTY}     30     50     ${EMPTY}
@{IEF_a4ThresholdSsbRsrq}         ${EMPTY}     31     51     ${EMPTY}
@{IEF_a4TimeToTriggerSsbRsrp}     ${EMPTY}     ms64   ms40   ${EMPTY}
@{IEF_a5Threshold1SsbRsrp}        ${EMPTY}     64     65     72
@{IEF_a5Threshold2SsbRsrp}        ${EMPTY}     69     70     77
@{IEF_a5Threshold1SsbRsrq}        ${EMPTY}     65     66     73
@{IEF_a5Threshold2SsbRsrq}        ${EMPTY}     70     71     78


@{IRF_b2Threshold1hoRsrp_b2Threshold1hoRsrq}    ${EMPTY}   68   66   64
@{IRF_b2Threshold2hoRsrp_b2Threshold2hoRsrq}    ${EMPTY}   26   24   22

${text_M55187C00001}    Number of UE configuration attempts for intra-frequency measurement profiles
${text_M55188C00001}    Number of UE configuration attempts for inter-frequency measurement profiles
${text_M55189C00001}    Number of UE configuration attempts for inter-RAT measurement profiles
${text_M55190C00001}    Number of selected measurement profiles for SA

*** Keywords ***

prepare counters and expected values 1st measurement period t1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB008127_F_InterRAT_handover_for_VoNR_call_with_5QI_criterion_in_measurement_profiles
    ...       :Autor: Sylvia Schneider

    set test variable    @{miaf1_counter}                   NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     2
    set test variable    &{dict_miaf1_counter}              M55187C00001-1=${text_M55187C00001-1}

    set test variable    @{miaf2_counter}                   NRCELL-1   NRMIAF-2    MIAF
    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     2
    set test variable    &{dict_miaf2_counter}              M55187C00001-1=${text_M55187C00001-1}

    set test variable    @{mief1_counter}                   NRCELL-1   NRMIEF-1    MIEF
    set test variable    @{text_M55188C00001-1}             ${text_M55188C00001}     1
    set test variable    &{dict_mief1_counter}              M55188C00001-1=${text_M55188C00001-1}

    set test variable    @{mief2_counter}                   NRCELL-1   NRMIEF-2    MIEF
    set test variable    @{text_M55188C00001-1}             ${text_M55188C00001}     1
    set test variable    &{dict_mief2_counter}              M55188C00001-1=${text_M55188C00001-1}

    set test variable    @{mirf1_counter}                   NRCELL-1   NRMIRF-1    MIRF
    set test variable    @{text_M55189C00001-1}             ${text_M55189C00001}     1
    set test variable    &{dict_mirf1_counter}              M55189C00001-1=${text_M55189C00001-1}

    set test variable    @{mirf2_counter}                   NRCELL-1   NRMIRF-2    MIRF
    set test variable    @{text_M55189C00001-1}             ${text_M55189C00001}     1
    set test variable    &{dict_mirf2_counter}              M55189C00001-1=${text_M55189C00001-1}

    set test variable    @{masa1_counter}                   NRCELL-1   NRMASA-1    MASA
    set test variable    @{text_M55190C00001-1}             ${text_M55190C00001}     4
    set test variable    &{dict_masa1_counter}              M55190C00001-1=${text_M55190C00001-1}

    set test variable    @{masa2_counter}                   NRCELL-1   NRMASA-2    MASA
    set test variable    @{text_M55190C00001-1}             ${text_M55190C00001}     4
    set test variable    &{dict_masa2_counter}              M55190C00001-1=${text_M55190C00001-1}


prepare counters and expected values 2nd measurement period t1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB008127_F_InterRAT_handover_for_VoNR_call_with_5QI_criterion_in_measurement_profiles
    ...       :Autor: Sylvia Schneider

    set test variable    @{miaf1_counter}                   NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     1
    set test variable    &{dict_miaf1_counter}              M55187C00001-1=${text_M55187C00001-1}

    set test variable    @{miaf2_counter}                   NRCELL-1   NRMIAF-2    MIAF
    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     1
    set test variable    &{dict_miaf2_counter}              M55187C00001-1=${text_M55187C00001-1}

    set test variable    @{mief1_counter}                   NRCELL-1   NRMIEF-1    MIEF
    set test variable    @{text_M55188C00001-1}             ${text_M55188C00001}     1
    set test variable    &{dict_mief1_counter}              M55188C00001-1=${text_M55188C00001-1}

    set test variable    @{mief2_counter}                   NRCELL-1   NRMIEF-2    MIEF
    set test variable    @{text_M55188C00001-1}             ${text_M55188C00001}     1
    set test variable    &{dict_mief2_counter}              M55188C00001-1=${text_M55188C00001-1}

    set test variable    @{mirf1_counter}                   NRCELL-1   NRMIRF-1    MIRF
    set test variable    @{text_M55189C00001-1}             ${text_M55189C00001}     1
    set test variable    &{dict_mirf1_counter}              M55189C00001-1=${text_M55189C00001-1}

    set test variable    @{masa1_counter}                   NRCELL-1   NRMASA-1    MASA
    set test variable    @{text_M55190C00001-1}             ${text_M55190C00001}     3
    set test variable    &{dict_masa1_counter}              M55190C00001-1=${text_M55190C00001-1}

    set test variable    @{masa2_counter}                   NRCELL-1   NRMASA-2    MASA
    set test variable    @{text_M55190C00001-1}             ${text_M55190C00001}     2
    set test variable    &{dict_masa2_counter}              M55190C00001-1=${text_M55190C00001-1}


prepare counters and expected values t2
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB008127_F_Reselection_of_measurement_profile_based_on_5QI_and_CA_capability_criterions
    ...       :Autor: Sylvia Schneider

    set test variable    @{miaf1_counter}                   NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     2
    set test variable    &{dict_miaf1_counter}              M55187C00001-1=${text_M55187C00001-1}

    set test variable    @{miaf3_counter}                   NRCELL-1   NRMIAF-3    MIAF
    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     3
    set test variable    &{dict_miaf3_counter}              M55187C00001-1=${text_M55187C00001-1}

    set test variable    @{mief1_counter}                   NRCELL-1   NRMIEF-1    MIEF
    set test variable    @{text_M55188C00001-1}             ${text_M55188C00001}     0
    set test variable    &{dict_mief1_counter}              M55188C00001-1=${text_M55188C00001-1}

    set test variable    @{mief3_counter}                   NRCELL-1   NRMIEF-3    MIEF
    set test variable    @{text_M55188C00001-1}             ${text_M55188C00001}     1
    set test variable    &{dict_mief3_counter}              M55188C00001-1=${text_M55188C00001-1}

    set test variable    @{mirf1_counter}                   NRCELL-1   NRMIRF-1    MIRF
    set test variable    @{text_M55189C00001-1}             ${text_M55189C00001}     0
    set test variable    &{dict_mirf1_counter}              M55189C00001-1=${text_M55189C00001-1}

    set test variable    @{mirf3_counter}                   NRCELL-1   NRMIRF-3    MIRF
    set test variable    @{text_M55189C00001-1}             ${text_M55189C00001}     1
    set test variable    &{dict_mirf3_counter}              M55189C00001-1=${text_M55189C00001-1}

    set test variable    @{masa1_counter}                   NRCELL-1   NRMASA-1    MASA
    set test variable    @{text_M55190C00001-1}             ${text_M55190C00001}     2
    set test variable    &{dict_masa1_counter}              M55190C00001-1=${text_M55190C00001-1}

    set test variable    @{masa3_counter}                   NRCELL-1   NRMASA-3    MASA
    set test variable    @{text_M55190C00001-1}             ${text_M55190C00001}     5
    set test variable    &{dict_masa3_counter}              M55190C00001-1=${text_M55190C00001-1}


prepare counters and expected values t3
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB008127_F_Selection_of_measurement_profile_based_on_5QI_and_RedCap_criterions
    ...       :Autor: Sylvia Schneider

    set test variable    @{miaf4_counter}                   NRCELL-1   NRMIAF-4    MIAF
    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     3
    set test variable    &{dict_miaf4_counter}              M55187C00001-1=${text_M55187C00001-1}

    set test variable    @{masa4_counter}                   NRCELL-1   NRMASA-4    MASA
    set test variable    @{text_M55190C00001-1}             ${text_M55190C00001}     3
    set test variable    &{dict_masa4_counter}              M55190C00001-1=${text_M55190C00001-1}
