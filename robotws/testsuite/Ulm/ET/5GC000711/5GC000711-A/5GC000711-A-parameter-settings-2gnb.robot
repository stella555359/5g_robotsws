*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part parameter settings 2gnb
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

prepare counters and expected values t8
    [Documentation]    [PRIVATE]    set expected values for InterRAT_handover_from_LTE_with_RFSP_and_mobility_profiles test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell_distName}   NRACH
    set test variable    @{M55306C03001}             ${text_M55306C03001}     1    ${cell_distName}   NRACH
    set test variable    @{M55157C00034}             ${text_M55157C00034}     1    ${cell_distName}   NRMOP

    set test variable    @{M55142C00501}             ${text_M55142C00501}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell_distName}   NRMO

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55306C03001=${M55306C03001}
    ...                                              M55157C00034=${M55157C00034}
    ...                                              M55142C00501=${M55142C00501}
    ...                                              M55142C00502=${M55142C00502}
    ...                                              M55142C00503=${M55142C00503}
    ...                                              M55142C00505=${M55142C00505}
    ...                                              M55142C00506=${M55142C00506}
    ...                                              M55142C00507=${M55142C00507}
    ...                                              M55142C00508=${M55142C00508}

    set test variable    @{UE}         1


prepare counters and expected values t9
    [Documentation]    [PRIVATE]    set expected values for InterRAT_handover_from_LTE_with_mobility_restriction_list test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell_distName}   NRACH
    set test variable    @{M55306C03001}             ${text_M55306C03001}     1    ${cell_distName}   NRACH

    set test variable    @{M55142C00501}             ${text_M55142C00501}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell_distName}   NRMO

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55306C03001=${M55306C03001}
    ...                                              M55142C00501=${M55142C00501}
    ...                                              M55142C00502=${M55142C00502}
    ...                                              M55142C00503=${M55142C00503}
    ...                                              M55142C00505=${M55142C00505}
    ...                                              M55142C00506=${M55142C00506}
    ...                                              M55142C00507=${M55142C00507}
    ...                                              M55142C00508=${M55142C00508}

    set test variable    @{UE}         1
