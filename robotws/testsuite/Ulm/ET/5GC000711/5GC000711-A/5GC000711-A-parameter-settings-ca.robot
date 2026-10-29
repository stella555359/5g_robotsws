*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part parameter settings for ca
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

prepare counters and expected values t16
    [Documentation]    [PRIVATE]    set expected values for Blind_Scell_addition_after_handover_from_LTE test
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55306C05001}             ${text_M55306C05001}     0   ${cell_distName}    NRACH
    set test variable    @{M55306C03001}             ${text_M55306C03001}     4    ${cell_distName}   NRACH
    set test variable    @{M55138C01501}             ${text_M55138C01501}     2   ${cell_distName}    RSACU
    set test variable    @{M55138C01502}             ${text_M55138C01502}     2   ${cell_distName}    RSACU

    set test variable    @{M55142C00501}             ${text_M55142C00501}          2    ${cell_distName}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          2    ${cell_distName}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          2    ${cell_distName}   NRMO

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55306C03001=${M55306C03001}
    ...                                              M55138C01501=${M55138C01501}
    ...                                              M55138C01502=${M55138C01502}
    ...                                              M55142C00501=${M55142C00501}
    ...                                              M55142C00502=${M55142C00502}
    ...                                              M55142C00503=${M55142C00503}
    ...                                              M55142C00505=${M55142C00505}
    ...                                              M55142C00506=${M55142C00506}
    ...                                              M55142C00507=${M55142C00507}
    ...                                              M55142C00508=${M55142C00508}

    set test variable    ${nonContentRachAcFullConfigHo}   false
    set test variable    ${actMeasBasedSCellAdditionSa}    disabled
    set test variable    ${sCellAdditionMethod}            blind
    set test variable    ${a1MeasSCellAddEnabled}          none

    set test variable    @{UE}         1   2


prepare counters and expected values t17
    [Documentation]    [PRIVATE]    set expected values for Measurement_based_SCell_addition_after_handover_from_LTE test
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55306C05001}             ${text_M55306C05001}     1   ${cell_distName}    NRACH
    set test variable    @{M55306C03001}             ${text_M55306C03001}     1    ${cell_distName}   NRACH
    set test variable    @{M55138C01501}             ${text_M55138C01501}     1   ${cell_distName}    RSACU
    set test variable    @{M55138C01502}             ${text_M55138C01502}     1   ${cell_distName}    RSACU

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
    ...                                              M55138C01501=${M55138C01501}
    ...                                              M55138C01502=${M55138C01502}
    ...                                              M55142C00501=${M55142C00501}
    ...                                              M55142C00502=${M55142C00502}
    ...                                              M55142C00503=${M55142C00503}
    ...                                              M55142C00505=${M55142C00505}
    ...                                              M55142C00506=${M55142C00506}
    ...                                              M55142C00507=${M55142C00507}
    ...                                              M55142C00508=${M55142C00508}

    set test variable    ${nonContentRachAcFullConfigHo}   true
    set test variable    ${actMeasBasedSCellAdditionSa}    A1-based
    set test variable    ${sCellAdditionMethod}            covBasedA1
    set test variable    ${a1MeasSCellAddEnabled}          rsrp

    set test variable    @{UE}         1
