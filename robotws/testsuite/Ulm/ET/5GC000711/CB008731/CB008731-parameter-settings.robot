*** Settings ***
Documentation   This is a keyword file for CB008731, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${cell}                          NRCELL-1



*** Keywords ***

prepare counters and expected values t2
    [Documentation]    [PRIVATE]    set expected values for CB008731_Partial_admission_control_for_interRAT_handover_from_LTE
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell}   NRACH
    set test variable    @{M55138C02001}             ${text_M55138C02001}     1    ${cell}   RSACU

    set test variable    @{M55142C00501}             ${text_M55142C00501}          2    ${cell}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          1    ${cell}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell}   NRMO

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55138C02001=${M55138C02001}
    ...                                              M55142C00501=${M55142C00501}
    ...                                              M55142C00502=${M55142C00502}
    ...                                              M55142C00503=${M55142C00503}
    ...                                              M55142C00505=${M55142C00505}
    ...                                              M55142C00506=${M55142C00506}
    ...                                              M55142C00507=${M55142C00507}
    ...                                              M55142C00508=${M55142C00508}

    set test variable    @{UE}         1   2


prepare counters and expected values t3
    [Documentation]    [PRIVATE]    set expected values for CB008731_ARP_based_preemption_for_interRAT_HO_from_LTE
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell}   NRACH
    set test variable    @{M55125C11501}             ${text_M55125C11501}     1    ${cell}   NNGCC

    set test variable    @{M55142C00501}             ${text_M55142C00501}          1    ${cell}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell}   NRMO

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55125C11501=${M55125C11501}
    ...                                              M55142C00501=${M55142C00501}
    ...                                              M55142C00502=${M55142C00502}
    ...                                              M55142C00503=${M55142C00503}
    ...                                              M55142C00505=${M55142C00505}
    ...                                              M55142C00506=${M55142C00506}
    ...                                              M55142C00507=${M55142C00507}
    ...                                              M55142C00508=${M55142C00508}

    set test variable    @{UE}         1   2   3

