*** Settings ***
Documentation   This is a keyword file for CB008127-G, part parameter settings
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

@{a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}   0    96    100    102
@{a1MeashoPrefNRLayerSsbRsrq_a1ThresholdhoSsb}   0    95    99    101
@{a1MeashoSsbRsrp_a1ThresholdhoSsb}              0    92    96    98
@{a1MeashoSsbRsrq_a1ThresholdhoSsb}              0    91    95    97
@{a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}    0    78    82    84
@{a2MeasReleaseSsbRsrq_a2ThresholdReleaseSsb}    0    77    81    83
@{a2MeashoSsbRsrp_a2ThresholdhoSsb}              0    88    92    94
@{a2MeashoSsbRsrq_a2ThresholdhoSsb}              0    87    91    93
@{a3MeasSsbRsrp_a3OffsetSsb}                     0     6     4    2
@{a3MeasSsbRsrq_a3OffsetSsb}                     0     5     3    1
@{a5MeasSsbRsrp_a5Threshold1Ssb}                 0     76    78    80
@{a5MeasSsbRsrp_a5Threshold2Ssb}                 0     81    83    85
@{a5MeasSsbRsrq_a5Threshold1Ssb}                 0     75    77    79
@{a5MeasSsbRsrq_a5Threshold2Ssb}                 0     80    82    84

@{uePowerClass_item1}                            0     ue-PowerClass2    ue-PowerClass1Dot5
@{uePowerClass_item2}                            0     ue-PowerClass3    ue-PowerClass5

@{IEF_a3OffsetSsbRsrp}                 0     2       4
@{IEF_a3OffsetSsbRsrq}                 0     3       5
@{IEF_a4ThresholdSsbRsrp}              0     30      25
@{IEF_a4ThresholdSsbRsrq}              0     31      26
@{IEF_a4TimeToTriggerSsbRsrp_Rsrq}     0     ms64    ms40
@{IEF_a5Threshold1SsbRsrp}             0     64      60
@{IEF_a5Threshold2SsbRsrp}             0     69      70
@{IEF_a5Threshold1SsbRsrq}             0     65      61
@{IEF_a5Threshold2SsbRsrq}             0     70      71


${text_M55187C00001}    Number of UE configuration attempts for intra-frequency measurement profiles
${text_M55188C00001}    Number of UE configuration attempts for inter-frequency measurement profiles
${text_M55189C00001}    Number of UE configuration attempts for inter-RAT measurement profiles
${text_M55191C00001}    Number of selected measurement profiles for NSA

*** Keywords ***

prepare counters and expected values t1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             G_B1_Configuration_of_intraFreq_measurements_profile_based_upon_PLMN
    ...       :Autor: Shruthi Shivaprasad

    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     2    NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1    NRCELL-1   NRMIAF-3    MIAF

    set test variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}
    ...                                              M55187C00001-2=${text_M55187C00001-2}


    set test variable    @{text_M55188C00001-1}             ${text_M55188C00001}     1    NRCELL-1   NRMIEF-1    MIEF

    set test variable    &{dict_mief_counter}
    ...                                              M55188C00001-1=${text_M55188C00001-1}


    set test variable    @{text_M55191C00001-1}             ${text_M55191C00001}     3    NRCELL-1   NRMNSA-1    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     1    NRCELL-1   NRMNSA-3    MNSA

    set test variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}
    ...                                              M55191C00001-2=${text_M55191C00001-2}


prepare counters and expected values t2
    [Documentation]    [PRIVATE]    set expected values for
    ...                             G_B2_Configuration_of_intraFreq_measurements_measurement_profile_based_upon_PLMN_SPID
    ...       :Autor: Shruthi Shivaprasad

    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     2    NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1    NRCELL-1   NRMIAF-3    MIAF

    set test variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}
    ...                                              M55187C00001-2=${text_M55187C00001-2}


    set test variable    @{text_M55188C00001-1}             ${text_M55188C00001}     1    NRCELL-1   NRMIEF-1    MIEF

    set test variable    &{dict_mief_counter}
    ...                                              M55188C00001-1=${text_M55188C00001-1}


    set test variable    @{text_M55191C00001-1}             ${text_M55191C00001}     3    NRCELL-1   NRMNSA-1    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     1    NRCELL-1   NRMNSA-3    MNSA

    set test variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}
    ...                                              M55191C00001-2=${text_M55191C00001-2}

prepare counters and expected values t3
    [Documentation]    [PRIVATE]    set expected values for
    ...                             G_B3_Configuration_of_intraFreq_measurements_measurement_profile_based_upon_SPID
    ...       :Autor: Shruthi Shivaprasad

    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     2    NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-2}             ${text_M55187C00001}     1    NRCELL-1   NRMIAF-3    MIAF

    set test variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}
    ...                                              M55187C00001-2=${text_M55187C00001-2}


    set test variable    @{text_M55188C00001-1}             ${text_M55188C00001}     1    NRCELL-1   NRMIEF-1    MIEF

    set test variable    &{dict_mief_counter}
    ...                                              M55188C00001-1=${text_M55188C00001-1}


    set test variable    @{text_M55191C00001-1}             ${text_M55191C00001}     3    NRCELL-1   NRMNSA-1    MNSA
    set test variable    @{text_M55191C00001-2}             ${text_M55191C00001}     1    NRCELL-1   NRMNSA-3    MNSA

    set test variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}
    ...                                              M55191C00001-2=${text_M55191C00001-2}


prepare counters and expected values t4
    [Documentation]    [PRIVATE]    set expected values for
    ...                         G_B4_Configuration_of_intraFreq_measurements_Reselection
    ...       :Autor: Shruthi Shivaprasad

    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     9    NRCELL-1   NRMIAF-3    MIAF

    set test variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}


    set test variable    @{text_M55188C00001-1}             ${text_M55188C00001}     3    NRCELL-1   NRMIEF-1    MIEF

    set test variable    &{dict_mief_counter}
    ...                                              M55188C00001-1=${text_M55188C00001-1}


    set test variable    @{text_M55191C00001-1}             ${text_M55191C00001}     12    NRCELL-1   NRMNSA-3    MNSA

    set test variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}


prepare counters and expected values t5
    [Documentation]    [PRIVATE]    set expected values for
    ...                         G_B4_Configuration_of_intraFreq_measurements_Reselection_mobility_profile
    ...       :Autor: Shruthi Shivaprasad

    set test variable    @{text_M55187C00001-1}             ${text_M55187C00001}     3    NRCELL-1   NRMIAF-3    MIAF

    set test variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}


    set test variable    @{text_M55188C00001-1}             ${text_M55188C00001}     1    NRCELL-1   NRMIEF-1    MIEF

    set test variable    &{dict_mief_counter}
    ...                                              M55188C00001-1=${text_M55188C00001-1}


    set test variable    @{text_M55191C00001-1}             ${text_M55191C00001}     4    NRCELL-1   NRMNSA-3    MNSA

    set test variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}
