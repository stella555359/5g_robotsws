*** Settings ***
Documentation   This is a keyword file for CB008731, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${cell}                          NRCELL-1



*** Keywords ***

prepare counters and expected values t6
    [Documentation]    [PRIVATE]    set expected values for A1_based_traffic_steering_to_preferred_NR_layer_after_IRAT_HO_from_LTE
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55319C11006}             ${text_M55319C11006}      ${bts_distName}   PDCP1
    set test variable    @{M55319C15006}             ${text_M55319C15006}      ${bts_distName}   PDCP1

    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell}   NRACH
    set test variable    @{M55184C00003}             ${text_M55184C00003}     1    ${cell}   SMAGP
    set test variable    @{M55184C00004}             ${text_M55184C00003}     1    ${cell}   SMAGP

    set test variable    @{M55142C00501}             ${text_M55142C00501}          1    ${cell}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell}   NRMO

    set test variable    @{M55142C00509}             ${text_M55142C00509}          0    ${cell}   NRMO
    set test variable    @{M55142C00510}             ${text_M55142C00510}          0    ${cell}   NRMO
    set test variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell}   NRMO
    set test variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell}   NRMO
    set test variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell}   NRMO
    set test variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell}   NRMO
    set test variable    @{M55142C00516}             ${text_M55142C00516}          0    ${cell}   NRMO

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55184C00003=${M55184C00003}
    ...                                              M55184C00004=${M55184C00004}
    ...                                              M55142C00501=${M55142C00501}
    ...                                              M55142C00502=${M55142C00502}
    ...                                              M55142C00503=${M55142C00503}
    ...                                              M55142C00505=${M55142C00505}
    ...                                              M55142C00506=${M55142C00506}
    ...                                              M55142C00507=${M55142C00507}
    ...                                              M55142C00508=${M55142C00508}
    ...                                              M55142C00509=${M55142C00509}
    ...                                              M55142C00510=${M55142C00510}
    ...                                              M55142C00511=${M55142C00511}
    ...                                              M55142C00513=${M55142C00513}
    ...                                              M55142C00514=${M55142C00514}
    ...                                              M55142C00515=${M55142C00515}
    ...                                              M55142C00516=${M55142C00516}

    set test variable    @{UE}         1


prepare counters and expected values t7
    [Documentation]    [PRIVATE]    set expected values for Periodic_A4_based_mobility_after_interRAT_HO_from_LTE
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell}   NRACH
    set test variable    @{M55184C00003}             ${text_M55184C00003}     1    ${cell}   SMAGP
    set test variable    @{M55184C00004}             ${text_M55184C00003}     1    ${cell}   SMAGP

    set test variable    @{M55142C00501}             ${text_M55142C00501}          1    ${cell}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell}   NRMO

    set test variable    @{M55142C00509}             ${text_M55142C00509}          0    ${cell}   NRMO
    set test variable    @{M55142C00510}             ${text_M55142C00510}          0    ${cell}   NRMO
    set test variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell}   NRMO
    set test variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell}   NRMO
    set test variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell}   NRMO
    set test variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell}   NRMO
    set test variable    @{M55142C00516}             ${text_M55142C00516}          0    ${cell}   NRMO

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55184C00003=${M55184C00003}
    ...                                              M55184C00004=${M55184C00004}
    ...                                              M55142C00501=${M55142C00501}
    ...                                              M55142C00502=${M55142C00502}
    ...                                              M55142C00503=${M55142C00503}
    ...                                              M55142C00505=${M55142C00505}
    ...                                              M55142C00506=${M55142C00506}
    ...                                              M55142C00507=${M55142C00507}
    ...                                              M55142C00508=${M55142C00508}
    ...                                              M55142C00509=${M55142C00509}
    ...                                              M55142C00510=${M55142C00510}
    ...                                              M55142C00511=${M55142C00511}
    ...                                              M55142C00513=${M55142C00513}
    ...                                              M55142C00514=${M55142C00514}
    ...                                              M55142C00515=${M55142C00515}
    ...                                              M55142C00516=${M55142C00516}

    set test variable    @{UE}         1

