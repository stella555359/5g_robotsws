*** Settings ***
Documentation   This is a keyword file for CB008137-force-HO, part parameter settings
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

Prepare Counters And Expected Values Force-HO
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB008731_03775066_Force_LTE_to_5G_handover_for_UE_with_insufficient_UE_Capability
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{miaf_counter}                  NRCELL-1   NRMIAF-1    MIAF
    Set Test Variable    @{text_M55187C00001-1}             ${text_M55187C00001}     3
    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}

    Set Test Variable    @{mief_counter}                  NRCELL-1   NRMIEF-1    MIEF
    Set Test Variable    @{text_M55188C00001-1}             ${text_M55188C00001}     1
    Set Test Variable    &{dict_mief_counter}
    ...                                              M55188C00001-1=${text_M55188C00001-1}

    Set Test Variable    @{mirf_counter}                  NRCELL-1   NRMIRF-1    MIRF
    Set Test Variable    @{text_M55189C00001-1}             ${text_M55189C00001}     1
    Set Test Variable    &{dict_mirf_counter}
    ...                                              M55189C00001-1=${text_M55189C00001-1}

    Set Test Variable    @{masa_counter}                  NRCELL-1   NRMASA-1    MASA
    Set Test Variable    @{text_M55190C00001-1}             ${text_M55190C00001}     5
    Set Test Variable    &{dict_masa_counter}
    ...                                              M55190C00001-1=${text_M55190C00001-1}


    Set Test Variable    @{M55142C00501}             ${text_M55142C00501}          2    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00502}             ${text_M55142C00502}          1    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00503}             ${text_M55142C00503}          1    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00505}             ${text_M55142C00505}          0    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00506}             ${text_M55142C00506}          0    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00507}             ${text_M55142C00507}          0    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00508}             ${text_M55142C00508}          1    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00509}             ${text_M55142C00509}          2    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00510}             ${text_M55142C00510}          1    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00511}             ${text_M55142C00511}          1    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00513}             ${text_M55142C00513}          0    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00514}             ${text_M55142C00514}          0    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00515}             ${text_M55142C00515}          0    NRCELL-1   NRMO
    Set Test Variable    @{M55142C00516}             ${text_M55142C00516}          1    NRCELL-1   NRMO

    Set Test Variable    &{dict_pm_counter}
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

    Set Test Variable    @{M55319C11001}             ${text_M55319C11001}     ${bts_distName}    PDCP1
    Set Test Variable    @{M55319C11005}             ${text_M55319C11005}     ${bts_distName}    PDCP1
    Set Test Variable    @{M55319C11006}             ${text_M55319C11006}     ${bts_distName}    PDCP1
    Set Test Variable    @{M55319C15001}             ${text_M55319C15001}     ${bts_distName}    PDCP1
    Set Test Variable    @{M55319C15005}             ${text_M55319C15005}     ${bts_distName}    PDCP1
    Set Test Variable    @{M55319C15006}             ${text_M55319C15006}     ${bts_distName}    PDCP1

    Set Test Variable    &{dict_pm_counter_55319}         M55319C11001=${M55319C11001}
    ...                                                   M55319C11005=${M55319C11005}
    ...                                                   M55319C15006=${M55319C15006}
    ...                                                   M55319C15001=${M55319C15001}
    ...                                                   M55319C15005=${M55319C15005}
    ...                                                   M55319C15006=${M55319C15006}


Prepare Counters And Expected Values Force-HO TMO
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB008731_03775066_Force_LTE_to_5G_handover_for_UE_with_insufficient_UE_Capability
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55142C00501}             ${text_M55142C00501}          4    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00502}             ${text_M55142C00502}          3    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00503}             ${text_M55142C00503}          1    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00505}             ${text_M55142C00505}          0    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00506}             ${text_M55142C00506}          0    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00507}             ${text_M55142C00507}          0    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00508}             ${text_M55142C00508}          3    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00509}             ${text_M55142C00509}          0    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00510}             ${text_M55142C00510}          0    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00511}             ${text_M55142C00511}          0    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00513}             ${text_M55142C00513}          0    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00514}             ${text_M55142C00514}          0    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00515}             ${text_M55142C00515}          0    NRCELL-4   NRMO
    Set Test Variable    @{M55142C00516}             ${text_M55142C00516}          0    NRCELL-4   NRMO

    Set Test Variable    &{dict_pm_counter}
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

