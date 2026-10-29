*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

prepare counters and expected values t1
    [Documentation]    [PRIVATE]    set expected values for interRAT_HO_from_LTE_to_5G_without_data_forwarding test
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

    set test variable    @{M55142C00509}             ${text_M55142C00509}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00510}             ${text_M55142C00510}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00516}             ${text_M55142C00516}          0    ${cell_distName}   NRMO

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
    ...                                              M55142C00509=${M55142C00509}
    ...                                              M55142C00510=${M55142C00510}
    ...                                              M55142C00511=${M55142C00511}
    ...                                              M55142C00513=${M55142C00513}
    ...                                              M55142C00514=${M55142C00514}
    ...                                              M55142C00515=${M55142C00515}
    ...                                              M55142C00516=${M55142C00516}

    set test variable    ${maxNumOfCaUsersNRCell}          250
    set test variable    ${maxNumOfRrcSA}                  275
    set test variable    ${maxNumOfSCellAlloc}             250
    set test variable    ${maxNumOfUsersPerNRCell}         275
    set test variable    ${maxNumOfNrDcSnUsers}            275
    set test variable    ${maxNumOfUsersPerCell}           275
    set test variable    ${actInterRatHoFromEutraToSA}     true
    set test variable    ${nonContentRachAcFullConfigHo}           true
    set test variable    ${tNgRelocExecDeltL}              5000
    set test variable    ${rrcReestabTypeSA}               deactivated
    set test variable    ${actLocationReportingSA}         false

    set test variable    @{UE}         1


prepare counters and expected values t2
    [Documentation]    [PRIVATE]    set expected values for Cancellation_of_interRAT_handover_from_LTE test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55306C05001}             ${text_M55306C05001}     0    ${cell_distName}   NRACH
    set test variable    @{M55306C03001}             ${text_M55306C03001}     2    ${cell_distName}   NRACH

    set test variable    @{M55142C00501}             ${text_M55142C00501}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00509}             ${text_M55142C00509}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00510}             ${text_M55142C00510}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00516}             ${text_M55142C00516}          0    ${cell_distName}   NRMO


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
    ...                                              M55142C00509=${M55142C00509}
    ...                                              M55142C00510=${M55142C00510}
    ...                                              M55142C00511=${M55142C00511}
    ...                                              M55142C00513=${M55142C00513}
    ...                                              M55142C00514=${M55142C00514}
    ...                                              M55142C00515=${M55142C00515}
    ...                                              M55142C00516=${M55142C00516}

    set test variable    ${maxNumOfCaUsersNRCell}          0
    set test variable    ${maxNumOfRrcSA}                  1
    set test variable    ${maxNumOfSCellAlloc}             1
    set test variable    ${maxNumOfUsersPerNRCell}         1
    set test variable    ${maxNumOfNrDcSnUsers}            1
    set test variable    ${maxNumOfUsersPerCell}           0
    set test variable    ${actInterRatHoFromEutraToSA}     true
    set test variable    ${nonContentRachAcFullConfigHo}           true
    set test variable    ${tNgRelocExecDeltL}              5000
    set test variable    ${rrcReestabTypeSA}               deactivated
    set test variable    ${actLocationReportingSA}         false

    set test variable    @{UE}         1   2


prepare counters and expected values t3
    [Documentation]    [PRIVATE]    set expected values for Rejection_of_interRAT_handover_from_LTE test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell_distName}   NRACH
    set test variable    @{M55306C03001}             ${text_M55306C03001}     2    ${cell_distName}   NRACH

    set test variable    @{M55142C00501}             ${text_M55142C00501}          3    ${cell_distName}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          2    ${cell_distName}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00509}             ${text_M55142C00509}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00510}             ${text_M55142C00510}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00516}             ${text_M55142C00516}          0    ${cell_distName}   NRMO

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
    ...                                              M55142C00509=${M55142C00509}
    ...                                              M55142C00510=${M55142C00510}
    ...                                              M55142C00511=${M55142C00511}
    ...                                              M55142C00513=${M55142C00513}
    ...                                              M55142C00514=${M55142C00514}
    ...                                              M55142C00515=${M55142C00515}
    ...                                              M55142C00516=${M55142C00516}

    set test variable    ${maxNumOfCaUsersNRCell}          0
    set test variable    ${maxNumOfRrcSA}                  1
    set test variable    ${maxNumOfSCellAlloc}             1
    set test variable    ${maxNumOfUsersPerNRCell}         1
    set test variable    ${maxNumOfNrDcSnUsers}            1
    set test variable    ${maxNumOfUsersPerCell}           0
    set test variable    ${actInterRatHoFromEutraToSA}     true
    set test variable    ${nonContentRachAcFullConfigHo}           true
    set test variable    ${tNgRelocExecDeltL}              5000
    set test variable    ${rrcReestabTypeSA}               deactivated
    set test variable    ${actLocationReportingSA}         false

    set test variable    @{UE}         1   2


prepare counters and expected values t4
    [Documentation]    [PRIVATE]    set expected values for Abort_of_handover_due_to_expiry_of_supervision_timer test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55306C05001}             ${text_M55306C05001}     0    ${cell_distName}   NRACH
    set test variable    @{M55306C03001}             ${text_M55306C03001}     2    ${cell_distName}   NRACH

    set test variable    @{M55142C00501}             ${text_M55142C00501}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00509}             ${text_M55142C00509}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00510}             ${text_M55142C00510}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00516}             ${text_M55142C00516}          0    ${cell_distName}   NRMO

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
    ...                                              M55142C00509=${M55142C00509}
    ...                                              M55142C00510=${M55142C00510}
    ...                                              M55142C00511=${M55142C00511}
    ...                                              M55142C00513=${M55142C00513}
    ...                                              M55142C00514=${M55142C00514}
    ...                                              M55142C00515=${M55142C00515}
    ...                                              M55142C00516=${M55142C00516}

    set test variable    ${maxNumOfCaUsersNRCell}          0
    set test variable    ${maxNumOfRrcSA}                  1
    set test variable    ${maxNumOfSCellAlloc}             1
    set test variable    ${maxNumOfUsersPerNRCell}         1
    set test variable    ${maxNumOfNrDcSnUsers}            1
    set test variable    ${maxNumOfUsersPerCell}           0
    set test variable    ${actInterRatHoFromEutraToSA}     true
    set test variable    ${nonContentRachAcFullConfigHo}           true
    set test variable    ${tNgRelocExecDeltL}              100
    set test variable    ${rrcReestabTypeSA}               deactivated
    set test variable    ${actLocationReportingSA}         false

    set test variable    @{UE}         1   2


prepare counters and expected values t5
    [Documentation]    [PRIVATE]    set expected values for Activation_and_deactivation_of_feature test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell_distName}   NRACH
    set test variable    @{M55306C03001}             ${text_M55306C03001}     1    ${cell_distName}   NRACH

    set test variable    @{M55142C00501}             ${text_M55142C00501}          2    ${cell_distName}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00509}             ${text_M55142C00509}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00510}             ${text_M55142C00510}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00516}             ${text_M55142C00516}          0    ${cell_distName}   NRMO

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
    ...                                              M55142C00509=${M55142C00509}
    ...                                              M55142C00510=${M55142C00510}
    ...                                              M55142C00511=${M55142C00511}
    ...                                              M55142C00513=${M55142C00513}
    ...                                              M55142C00514=${M55142C00514}
    ...                                              M55142C00515=${M55142C00515}
    ...                                              M55142C00516=${M55142C00516}

    set test variable    ${maxNumOfCaUsersNRCell}          250
    set test variable    ${maxNumOfRrcSA}                  275
    set test variable    ${maxNumOfSCellAlloc}             250
    set test variable    ${maxNumOfUsersPerNRCell}         275
    set test variable    ${maxNumOfNrDcSnUsers}            275
    set test variable    ${maxNumOfUsersPerCell}           275
    set test variable    ${actInterRatHoFromEutraToSA}     false
    set test variable    ${nonContentRachAcFullConfigHo}           false
    set test variable    ${tNgRelocExecDeltL}              5000
    set test variable    ${rrcReestabTypeSA}               deactivated
    set test variable    ${actLocationReportingSA}         false

    set test variable    @{UE}         1


prepare counters and expected values t6
    [Documentation]    [PRIVATE]    set expected values for RRC_Re_Establishment_request_for_IRAT_HO_from_LTE test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55306C05001}             ${text_M55306C05001}     0    ${cell_distName}   NRACH
    set test variable    @{M55306C03001}             ${text_M55306C03001}     4    ${cell_distName}   NRACH
    set test variable    @{M55124C00502}             ${text_M55124C00502}     1    ${cell_distName}   NRRCC
    set test variable    @{M55124C00505}             ${text_M55124C00505}     1    ${cell_distName}   NRRCC
    set test variable    @{M55124C00515}             ${text_M55124C00515}     1    ${cell_distName}   NRRCC
    set test variable    @{M55124C01031}             ${text_M55124C01031}     2    ${cell_distName}   NRRCC

    set test variable    @{M55142C00501}             ${text_M55142C00501}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          1    ${cell_distName}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00509}             ${text_M55142C00509}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00510}             ${text_M55142C00510}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00516}             ${text_M55142C00516}          0    ${cell_distName}   NRMO

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55306C03001=${M55306C03001}
    ...                                              M55124C00502=${M55124C00502}
    ...                                              M55124C00505=${M55124C00505}
    ...                                              M55124C00515=${M55124C00515}
    ...                                              M55124C01031=${M55124C01031}
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

    set test variable    ${maxNumOfCaUsersNRCell}          0
    set test variable    ${maxNumOfRrcSA}                  2
    set test variable    ${maxNumOfSCellAlloc}             0
    set test variable    ${maxNumOfUsersPerNRCell}         2
    set test variable    ${maxNumOfNrDcSnUsers}            2
    set test variable    ${maxNumOfUsersPerCell}           0
    set test variable    ${actInterRatHoFromEutraToSA}     true
    set test variable    ${nonContentRachAcFullConfigHo}           false
    set test variable    ${tNgRelocExecDeltL}              5000
    set test variable    ${rrcReestabTypeSA}               viaRRCSetup
    set test variable    ${actLocationReportingSA}         false

    set test variable    @{UE}         1   2


prepare counters and expected values t12
    [Documentation]    [PRIVATE]    set expected values for DL_NAS_message_transfer_during_IRAT_HO_from_LTE test
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55306C05001}             ${text_M55306C05001}     1   ${cell_distName}   NRACH
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

    set test variable    @{I_LTE_HO_RES_ALC_ATT}              ${text_M55142C00501}          1    ${cell_distName}   NRMO
    set test variable    @{I_LTE_HO_RES_ALC_SUCC}             ${text_M55142C00502}          1    ${cell_distName}   NRMO
    set test variable    @{I_LTE_HO_RES_ALC_F_AC}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    set test variable    @{I_LTE_HO_RES_ALC_F_OVLCP}          ${text_M55142C00505}          0    ${cell_distName}   NRMO
    set test variable    @{I_LTE_HO_FAIL_TIME_EXP}            ${text_M55142C00506}          0    ${cell_distName}   NRMO
    set test variable    @{I_LTE_HO_RES_ALC_F_OTHER}          ${text_M55142C00507}          0    ${cell_distName}   NRMO
    set test variable    @{I_LTE_HO_EXEC_NOTIFY}              ${text_M55142C00508}          1    ${cell_distName}   NRMO

    set test variable    ${maxNumOfCaUsersNRCell}          250
    set test variable    ${maxNumOfRrcSA}                  275
    set test variable    ${maxNumOfSCellAlloc}             250
    set test variable    ${maxNumOfUsersPerNRCell}         275
    set test variable    ${maxNumOfNrDcSnUsers}            275
    set test variable    ${maxNumOfUsersPerCell}           275
    set test variable    ${actInterRatHoFromEutraToSA}     true
    set test variable    ${nonContentRachAcFullConfigHo}           true
    set test variable    ${tNgRelocExecDeltL}              5000
    set test variable    ${rrcReestabTypeSA}               deactivated
    set test variable    ${actLocationReportingSA}         false

    set test variable    @{UE}         1


prepare counters and expected values t13
    [Documentation]    [PRIVATE]    set expected values for PDU_session_setup_release_modification_during_IRAT_HO_from_LTE test
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55306C05001}             ${text_M55306C05001}     0    ${cell_distName}   NRACH
    set test variable    @{M55306C03001}             ${text_M55306C03001}     6    ${cell_distName}   NRACH

    set test variable    @{M55142C00501}             ${text_M55142C00501}          3    ${cell_distName}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          3    ${cell_distName}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          3    ${cell_distName}   NRMO

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

    set test variable    ${maxNumOfCaUsersNRCell}          250
    set test variable    ${maxNumOfRrcSA}                  275
    set test variable    ${maxNumOfSCellAlloc}             250
    set test variable    ${maxNumOfUsersPerNRCell}         275
    set test variable    ${maxNumOfNrDcSnUsers}            275
    set test variable    ${maxNumOfUsersPerCell}           275
    set test variable    ${actInterRatHoFromEutraToSA}     true
    set test variable    ${nonContentRachAcFullConfigHo}           false
    set test variable    ${tNgRelocExecDeltL}              5000
    set test variable    ${rrcReestabTypeSA}               deactivated
    set test variable    ${actLocationReportingSA}         false

    set test variable    @{UE}         1   2   3


prepare counters and expected values t14
    [Documentation]    [PRIVATE]    set expected values for Successful_location_reporting_at_incoming_IRAT_HO_from LTE test
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55306C05001}             ${text_M55306C05001}     0   ${cell_distName}    NRACH
    set test variable    @{M55306C03001}             ${text_M55306C03001}     6    ${cell_distName}   NRACH
    set test variable    @{M55125C06502}             ${text_M55125C06502}     2   ${cell_distName}    NNGCC

    set test variable    @{M55142C00501}             ${text_M55142C00501}          3    ${cell_distName}   NRMO
    set test variable    @{M55142C00502}             ${text_M55142C00502}          3    ${cell_distName}   NRMO
    set test variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    set test variable    @{M55142C00508}             ${text_M55142C00508}          3    ${cell_distName}   NRMO

    set test variable    @{M55125C08001}             ${text_M55125C08001}          3    ${cell_distName}   NNGCC

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55306C03001=${M55306C03001}
    ...                                              M55125C06502=${M55125C06502}
    ...                                              M55142C00501=${M55142C00501}
    ...                                              M55142C00502=${M55142C00502}
    ...                                              M55142C00503=${M55142C00503}
    ...                                              M55142C00505=${M55142C00505}
    ...                                              M55142C00506=${M55142C00506}
    ...                                              M55142C00507=${M55142C00507}
    ...                                              M55142C00508=${M55142C00508}
    ...                                              M55125C08001=${M55125C08001}


    set test variable    ${maxNumOfCaUsersNRCell}          250
    set test variable    ${maxNumOfRrcSA}                  275
    set test variable    ${maxNumOfSCellAlloc}             250
    set test variable    ${maxNumOfUsersPerNRCell}         275
    set test variable    ${maxNumOfNrDcSnUsers}            275
    set test variable    ${maxNumOfUsersPerCell}           275
    set test variable    ${actInterRatHoFromEutraToSA}     true
    set test variable    ${nonContentRachAcFullConfigHo}           false
    set test variable    ${tNgRelocExecDeltL}              5000
    set test variable    ${rrcReestabTypeSA}               deactivated
    set test variable    ${actLocationReportingSA}         true

    set test variable    @{UE}         1   2   3
