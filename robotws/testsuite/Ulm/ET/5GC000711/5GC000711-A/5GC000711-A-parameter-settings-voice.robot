*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

prepare counters and expected values t7
    [Documentation]    [PRIVATE]    set expected values for InterRAT_handover_from_LTE_for_voice_over_NR_call test
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55306C05001}             ${text_M55306C05001}     0    ${cell_distName}   NRACH
    Set Test Variable    @{M55306C03001}             ${text_M55306C03001}     2    ${cell_distName}   NRACH

    Set Test Variable    @{M55142C00501}             ${text_M55142C00501}          1    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell_distName}   NRMO

    Set Test Variable    @{M55142C00509}             ${text_M55142C00509}          1    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00510}             ${text_M55142C00510}          1    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00516}             ${text_M55142C00516}          1    ${cell_distName}   NRMO

    Set Test Variable    &{dict_pm_counter}
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

    Set Test Variable    ${nonContentRachAcFullConfigHo}                  false
    Set Test Variable    ${actEnhancedVoNR}                       true
    Set Test Variable    ${actVoNR}                               true
    Set Test Variable    ${actVoNrMobilityThresholds}             VoNrMobilityThresholds
    Set Test Variable    ${actNormVCFallback}                     false
    Set Test Variable    ${actRedirect}                           false
    Set Test Variable    ${actVoFallBackLteB1MeaBaRedir}          false
    Set Test Variable    ${voiceFBMode}                           disabled
    Set Test Variable    ${actEmergencyCall}                      false
    Set Test Variable    ${emergencyCallLimServ}                  false
    Set Test Variable    ${maxNumOfCaUsersNRCell}                 250
    Set Test Variable    ${maxNumOfRrcSA}                         275
    Set Test Variable    ${maxNumOfSCellAlloc}                    250
    Set Test Variable    ${maxNumOfUsersPerNRCell}                275
    Set Test Variable    ${maxNumOfNrDcSnUsers}                   275
    Set Test Variable    ${maxNumOfUsersPerCell}                  275
    Set Test Variable    ${numOfRadioResReservForEmergency}       0
    Set Test Variable    ${numOfDrbsReservForEmergency}           0

    Set Test Variable    @{UE}         1


prepare counters and expected values t10
    [Documentation]    [PRIVATE]    set expected values for Voice_fallback_via_redirection_after_interRAT_HO_from_LTE test
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell_distName}   NRACH
    Set Test Variable    @{M55306C03001}             ${text_M55306C03001}     1    ${cell_distName}   NRACH
    Set Test Variable    @{M55124C02501}             ${text_M55124C02501}     1   ${cell_distName}    NRRCC

    Set Test Variable    @{M55142C00501}             ${text_M55142C00501}          1    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00503}             ${text_M55142C00503}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell_distName}   NRMO

    Set Test Variable    @{M55142C00509}             ${text_M55142C00509}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00510}             ${text_M55142C00510}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00511}             ${text_M55142C00511}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00516}             ${text_M55142C00516}          0    ${cell_distName}   NRMO

    Set Test Variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55306C03001=${M55306C03001}
    ...                                              M55124C02501=${M55124C02501}
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

    Set Test Variable    ${nonContentRachAcFullConfigHo}                  true
    Set Test Variable    ${actEnhancedVoNR}                       false
    Set Test Variable    ${actVoNR}                               false
    Set Test Variable    ${actVoNrMobilityThresholds}             off
    Set Test Variable    ${actNormVCFallback}                     true
    Set Test Variable    ${actRedirect}                           true
    Set Test Variable    ${actVoFallBackLteB1MeaBaRedir}          true
    Set Test Variable    ${voiceFBMode}                           redirection
    Set Test Variable    ${actEmergencyCall}                      false
    Set Test Variable    ${emergencyCallLimServ}                  false
    Set Test Variable    ${maxNumOfCaUsersNRCell}                 250
    Set Test Variable    ${maxNumOfRrcSA}                         275
    Set Test Variable    ${maxNumOfSCellAlloc}                    250
    Set Test Variable    ${maxNumOfUsersPerNRCell}                275
    Set Test Variable    ${maxNumOfNrDcSnUsers}                   275
    Set Test Variable    ${maxNumOfUsersPerCell}                  275
    Set Test Variable    ${numOfRadioResReservForEmergency}       0
    Set Test Variable    ${numOfDrbsReservForEmergency}           0

    Set Test Variable    @{UE}         1


prepare counters and expected values t11
    [Documentation]    [PRIVATE]    set expected values for InterRAT_handover_from_LTE_for_emergency_call test
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55306C05001}             ${text_M55306C05001}     0    ${cell_distName}   NRACH
    Set Test Variable    @{M55306C03001}             ${text_M55306C03001}     4    ${cell_distName}   NRACH

    Set Test Variable    @{M55142C00501}             ${text_M55142C00501}          2    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00502}             ${text_M55142C00502}          1    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00503}             ${text_M55142C00503}          1    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00505}             ${text_M55142C00505}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00506}             ${text_M55142C00506}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00507}             ${text_M55142C00507}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00508}             ${text_M55142C00508}          1    ${cell_distName}   NRMO

    Set Test Variable    @{M55142C00509}             ${text_M55142C00509}          2    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00510}             ${text_M55142C00510}          1    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00511}             ${text_M55142C00511}          1    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00513}             ${text_M55142C00513}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00514}             ${text_M55142C00514}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00515}             ${text_M55142C00515}          0    ${cell_distName}   NRMO
    Set Test Variable    @{M55142C00516}             ${text_M55142C00516}          1    ${cell_distName}   NRMO

    Set Test Variable    &{dict_pm_counter}
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

    Set Test Variable    ${nonContentRachAcFullConfigHo}                  false
    Set Test Variable    ${actEnhancedVoNR}                       true
    Set Test Variable    ${actVoNR}                               true
    Set Test Variable    ${actVoNrMobilityThresholds}             VoNrMobilityThresholds
    Set Test Variable    ${actNormVCFallback}                     false
    Set Test Variable    ${actRedirect}                           false
    Set Test Variable    ${actVoFallBackLteB1MeaBaRedir}          false
    Set Test Variable    ${voiceFBMode}                           disabled
    Set Test Variable    ${actEmergencyCall}                      true
    Set Test Variable    ${emergencyCallLimServ}                  true
    Set Test Variable    ${maxNumOfCaUsersNRCell}                 0
    Set Test Variable    ${maxNumOfRrcSA}                         1
    Set Test Variable    ${maxNumOfSCellAlloc}                    1
    Set Test Variable    ${maxNumOfUsersPerNRCell}                1
    Set Test Variable    ${maxNumOfNrDcSnUsers}                   1
    Set Test Variable    ${maxNumOfUsersPerCell}                  0
    Set Test Variable    ${numOfRadioResReservForEmergency}       1
    Set Test Variable    ${numOfDrbsReservForEmergency}           1

    Set Test Variable    @{UE}         1   2   3
