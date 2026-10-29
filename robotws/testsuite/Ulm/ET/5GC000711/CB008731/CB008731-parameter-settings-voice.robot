*** Settings ***
Documentation   This is a keyword file for CB008731, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${cell}                          NRCELL-1



*** Keywords ***

prepare counters and expected values t1
    [Documentation]    [PRIVATE]    set expected values for InterRAT_handover_from_LTE_with_ROHC_for_VoNR_call
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55320C19001}             ${text_M55320C19001}      ${bts_distName}   PDCP2
    set test variable    @{M55320C19002}             ${text_M55320C19002}      ${bts_distName}   PDCP2
    set test variable    @{M55320C19003}             ${text_M55320C19003}      ${bts_distName}   PDCP2
    set test variable    @{M55320C19004}             ${text_M55320C19004}      ${bts_distName}   PDCP2

    set test variable    @{M55125C09516}             ${text_M55125C09516}      ${bts_distName}/${cell}   NNGCC
    set test variable    @{M55125C09526}             ${text_M55125C09526}      ${bts_distName}/${cell}   NNGCC
    set test variable    @{M55163C00521}             ${text_M55163C00521}      ${bts_distName}/${cell}   NGCCQ



    set test variable    &{dict_rohc_pm_counter1}     M55320C19001=${M55320C19001}
    ...                                               M55320C19002=${M55320C19002}
    ...                                               M55320C19003=${M55320C19003}
    ...                                               M55320C19004=${M55320C19004}

    set test variable    &{dict_rohc_pm_counter2}     M55320C19001=${M55320C19001}
    ...                                               M55320C19002=${M55320C19002}
    ...                                               M55320C19003=${M55320C19003}
    ...                                               M55320C19004=${M55320C19004}
    ...                                               M55125C09516=${M55125C09516}
    ...                                               M55125C09526=${M55125C09526}
    ...                                               M55163C00521=${M55163C00521}

    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell}   NRACH
    set test variable    @{M55125C09013}             ${text_M55125C09013}     2    ${cell}   NNGCC
    set test variable    @{M55125C09014}             ${text_M55125C09014}     2    ${cell}   NNGCC
    set test variable    @{M55125C09524}             ${text_M55125C09524}     1    ${cell}   NNGCC
    set test variable    @{M55125C09525}             ${text_M55125C09525}     1    ${cell}   NNGCC
    set test variable    @{M55163C00513}             ${text_M55163C00513}     2    ${cell}   NGCCQ
    set test variable    @{M55163C00514}             ${text_M55163C00514}     2    ${cell}   NGCCQ
    set test variable    @{M55125C09527}             ${text_M55125C09527}     0    ${cell}   NNGCC

    set test variable    @{M55142C00501}             ${text_M55142C00501}          1    ${cell}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell}   NRMO

    set test variable    @{M55142C00509}             ${text_M55142C00509}          1    ${cell}   NRMO
    set test variable    @{M55142C00510}             ${text_M55142C00510}          1    ${cell}   NRMO
    set test variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell}   NRMO
    set test variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell}   NRMO
    set test variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell}   NRMO
    set test variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell}   NRMO
    set test variable    @{M55142C00516}             ${text_M55142C00516}          1    ${cell}   NRMO

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55125C09013=${M55125C09013}
    ...                                              M55125C09014=${M55125C09014}
    ...                                              M55125C09524=${M55125C09524}
    ...                                              M55125C09525=${M55125C09525}
    ...                                              M55163C00513=${M55163C00513}
    ...                                              M55163C00514=${M55163C00514}
    ...                                              M55125C09527=${M55125C09527}
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



prepare counters and expected values t4
    [Documentation]    [PRIVATE]    set expected values for InterRAT_handover_from_LTE_with_ROHC_for_VoNR_call
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55124C09001}             ${text_M55124C09001}     1    ${cell}   NRRCC
    set test variable    @{M55125C12503}             ${text_M55125C12503}     2    ${cell}   NNGCC
    set test variable    &{dict_pm_counter1}         M55124C09001=${M55124C09001}
    ...                                              M55125C12503=${M55125C12503}

    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell}   NRACH
    set test variable    @{M55125C09526}             ${text_M55125C09526}     0    ${cell}   NNGCC
    set test variable    @{M55125C09013}             ${text_M55125C09013}     4    ${cell}   NNGCC
    set test variable    @{M55125C09014}             ${text_M55125C09014}     2    ${cell}   NNGCC
    set test variable    @{M55125C09524}             ${text_M55125C09524}     2    ${cell}   NNGCC
    set test variable    @{M55125C09525}             ${text_M55125C09525}     1    ${cell}   NNGCC
    set test variable    @{M55163C00513}             ${text_M55163C00513}     4    ${cell}   NGCCQ
    set test variable    @{M55163C00514}             ${text_M55163C00514}     2    ${cell}   NGCCQ

    set test variable    @{M55142C00501}             ${text_M55142C00501}          2    ${cell}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          1    ${cell}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell}   NRMO

    set test variable    @{M55142C00509}             ${text_M55142C00509}          2    ${cell}   NRMO
    set test variable    @{M55142C00510}             ${text_M55142C00510}          1    ${cell}   NRMO
    set test variable    @{M55142C00511}             ${text_M55142C00511}          1    ${cell}   NRMO
    set test variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell}   NRMO
    set test variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell}   NRMO
    set test variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell}   NRMO
    set test variable    @{M55142C00516}             ${text_M55142C00516}          1    ${cell}   NRMO

    set test variable    &{dict_pm_counter2}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55125C09526=${M55125C09526}
    ...                                              M55125C09013=${M55125C09013}
    ...                                              M55125C09014=${M55125C09014}
    ...                                              M55125C09524=${M55125C09524}
    ...                                              M55125C09525=${M55125C09525}
    ...                                              M55163C00513=${M55163C00513}
    ...                                              M55163C00514=${M55163C00514}
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

    set test variable    @{M55125C09516}             ${text_M55125C09516}      ${bts_distName}/${cell}   NNGCC
    set test variable    @{M55125C09527}             ${text_M55125C09527}      ${bts_distName}/${cell}   NNGCC
    set test variable    @{M55163C00521}             ${text_M55163C00521}      ${bts_distName}/${cell}   NGCCQ

    set test variable    @{UE}         1   2   3



prepare counters and expected values t5
    [Documentation]    [PRIVATE]    set expected values for InterRAT_handover_from_LTE_with_GBR_services_for_non_voice_bearer
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55306C05001}             ${text_M55306C05001}          2    ${cell}   NRACH
    set test variable    @{M55142C00501}             ${text_M55142C00501}          2    ${cell}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          2    ${cell}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          2    ${cell}   NRMO

    set test variable    @{M55142C00509}             ${text_M55142C00509}          1    ${cell}   NRMO
    set test variable    @{M55142C00510}             ${text_M55142C00510}          1    ${cell}   NRMO
    set test variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell}   NRMO
    set test variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell}   NRMO
    set test variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell}   NRMO
    set test variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell}   NRMO
    set test variable    @{M55142C00516}             ${text_M55142C00516}          1    ${cell}   NRMO

    set test variable    @{M55139C04505}             ${text_M55139C04505}          3    ${cell}   RSADU
    set test variable    @{M55139C04506}             ${text_M55139C04506}          3    ${cell}   RSADU

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
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
    ...                                              M55139C04505=${M55139C04505}
    ...                                              M55139C04506=${M55139C04506}

    set test variable    @{M55319C11001}             ${text_M55319C11001}      ${bts_distName}   PDCP1
    set test variable    @{M55319C11002}             ${text_M55319C11002}      ${bts_distName}   PDCP1
    set test variable    @{M55319C11005}             ${text_M55319C11005}      ${bts_distName}   PDCP1
    set test variable    @{M55319C11010}             ${text_M55319C11010}      ${bts_distName}   PDCP1
    set test variable    @{M55319C15001}             ${text_M55319C15001}      ${bts_distName}   PDCP1
    set test variable    @{M55319C15002}             ${text_M55319C15002}      ${bts_distName}   PDCP1
    set test variable    @{M55319C15005}             ${text_M55319C15005}      ${bts_distName}   PDCP1
    set test variable    @{M55319C15010}             ${text_M55319C15010}      ${bts_distName}   PDCP1

    set test variable    &{dict_pm_counter_ue1}           M55319C11001=${M55319C11001}
    ...                                                   M55319C11002=${M55319C11002}
    ...                                                   M55319C11005=${M55319C11005}
    ...                                                   M55319C15001=${M55319C15001}
    ...                                                   M55319C15002=${M55319C15002}
    ...                                                   M55319C15005=${M55319C15005}
    set test variable    &{dict_pm_counter_ue2}           M55319C11010=${M55319C11010}
    ...                                                   M55319C15010=${M55319C15010}

    set test variable    @{UE}         1   2
