*** Settings ***
Documentation   This is a keyword file for CB012121-A, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${text_M55142C00523}    Numerator for average time for handover target selection due to measurement prioritization
${text_M55142C00524}    Denominator for average time for handover target selection due to measurement prioritization
${text_M55142C00525}    Maximum time for handover target selection due to measurement prioritization
${text_M55142C00526}    Total number of measurement reports received for measurement prioritization

${text_M55157C00034}    Number of times the SA mobility profile 2 is selected
${text_M55157C00035}    Number of times the SA mobility profile 3 is selected

*** Keywords ***

prepare counters and expected values 1st measurement period t1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B1_ALT1_feature_activation_interaction_with_mobility_profiles_best_cell_wait_timer_zero
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00034}             ${text_M55157C00034}     1    NRCELL-1   NRMOP


prepare counters and expected values 2nd measurement period t1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B1_ALT1_feature_activation_interaction_with_mobility_profiles_best_cell_wait_timer_zero
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00035}             ${text_M55157C00035}     1    NRCELL-1   NRMOP


prepare syslogs checks A_B2-Alt5 UE21
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_A_B2_ALT5_after_intra_frequency_Handover_via_XN_best_cell_wait_timer_started
    set test variable    ${measRep_6}      Received measId: 6
    set test variable    ${TimerStarted}   measurementReportPrioritizationTimer Timer is started with 10000 milliseconds
    set test variable    ${HO_cell50}      Triggering handover with type: intra gNB HO*PhyCellId??LOG_SCRAM_*>50</LOG_SCRAM_*>
    set test variable    ${TimerDeleted}   Timer measurementReportPrioritizationTimer deleted
    set test variable    ${measRep_15}     Received measId: 15


prepare syslogs checks A_B2-Alt5 UE22
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_A_B2_ALT5_after_intra_frequency_Handover_via_XN_best_cell_wait_timer_started
    set test variable    ${measRep_6}      Received measId: 6
    set test variable    ${TimerStarted}   measurementReportPrioritizationTimer Timer is started with 10000 milliseconds
    set test variable    ${HO_cell50}      Triggering handover with type: intra gNB HO*PhyCellId??LOG_SCRAM_*>50</LOG_SCRAM_*>
    set test variable    ${TimerDeleted}   Timer measurementReportPrioritizationTimer deleted
    set test variable    ${measRep_20}     Received measId: 20


prepare counters and expected values B2-Alt5 1st measurement period NRCELL-1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B1_ALT1_feature_activation_interaction_with_mobility_profiles_best_cell_wait_timer_zero
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55142C00523}             ${text_M55142C00523}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00524}             ${text_M55142C00524}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00525}             ${text_M55142C00525}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          1    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00523=${M55142C00523}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00525=${M55142C00525}
    ...                                              M55142C00526=${M55142C00526}


prepare counters and expected values B2-Alt5 1st measurement period NRCELL-2
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B1_ALT1_feature_activation_interaction_with_mobility_profiles_best_cell_wait_timer_zero
    set test variable    @{M55142C00523}             ${text_M55142C00523}          0    NRCELL-2   NRMO
    set test variable    @{M55142C00524}             ${text_M55142C00524}          0    NRCELL-2   NRMO
    set test variable    @{M55142C00525}             ${text_M55142C00525}          0    NRCELL-2   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          1    NRCELL-2   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00523=${M55142C00523}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00525=${M55142C00525}
    ...                                              M55142C00526=${M55142C00526}


prepare counters and expected values B2-Alt5 2nd measurement period NRCELL-1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B1_ALT1_feature_activation_interaction_with_mobility_profiles_best_cell_wait_timer_zero
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55142C00523}             ${text_M55142C00523}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00524}             ${text_M55142C00524}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00525}             ${text_M55142C00525}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          1    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00523=${M55142C00523}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00525=${M55142C00525}
    ...                                              M55142C00526=${M55142C00526}


prepare counters and expected values B2-Alt5 2nd measurement period NRCELL-2
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B1_ALT1_feature_activation_interaction_with_mobility_profiles_best_cell_wait_timer_zero
    set test variable    @{M55142C00523}             ${text_M55142C00523}          0    NRCELL-2   NRMO
    set test variable    @{M55142C00524}             ${text_M55142C00524}          0    NRCELL-2   NRMO
    set test variable    @{M55142C00525}             ${text_M55142C00525}          0    NRCELL-2   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          1    NRCELL-2   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00523=${M55142C00523}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00525=${M55142C00525}
    ...                                              M55142C00526=${M55142C00526}


prepare syslogs checks A_B2_ALT4 UE21
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_A_B2_ALT4_after_inter_frequency_Handover_via_XN_best_cell_wait_timer_started
    set test variable    ${measRep_6}      Received measId: 6
    set test variable    ${TimerStarted}   measurementReportPrioritizationTimer Timer is started with 10000 milliseconds
    set test variable    ${HO_cell50}      Triggering handover with type: intra gNB HO*PhyCellId??LOG_SCRAM_*>50</LOG_SCRAM_*>
    set test variable    ${HO_cell51}      Triggering handover with type: intra gNB HO*PhyCellId??LOG_SCRAM_*>51</LOG_SCRAM_*>
    set test variable    ${TimerDeleted}   Timer measurementReportPrioritizationTimer deleted
    set test variable    ${measRep_16}     Received measId: 16
    set test variable    ${measRep_15}     Received measId: 15


prepare syslogs checks A_B2_ALT4 UE22
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_A_B2_ALT4_after_inter_frequency_Handover_via_XN_best_cell_wait_timer_started
    set test variable    ${measRep_6}      Received measId: 6
    set test variable    ${TimerStarted}   measurementReportPrioritizationTimer Timer is started with 10000 milliseconds
    set test variable    ${HO_cell50}      Triggering handover with type: intra gNB HO*PhyCellId??LOG_SCRAM_*>50</LOG_SCRAM_*>
    set test variable    ${TimerDeleted}   Timer measurementReportPrioritizationTimer deleted
    set test variable    ${measRep_21}     Received measId: 21


prepare counters and expected values B2-Alt4 1st measurement period NRCELL-1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B2_ALT4_after_inter_frequency_Handover_via_XN_best_cell_wait_timer_started
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          3    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare counters and expected values B2-Alt4 1st measurement period NRCELL-2
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B2_ALT4_after_inter_frequency_Handover_via_XN_best_cell_wait_timer_started
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-2   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          4    NRCELL-2   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare counters and expected values B2-Alt4 2nd measurement period NRCELL-1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B2_ALT4_after_inter_frequency_Handover_via_XN_best_cell_wait_timer_started
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55142C00523}             ${text_M55142C00523}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00524}             ${text_M55142C00524}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00525}             ${text_M55142C00525}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          1    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00523=${M55142C00523}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00525=${M55142C00525}
    ...                                              M55142C00526=${M55142C00526}


prepare counters and expected values B2-Alt4 2nd measurement period NRCELL-2
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B2_ALT4_after_inter_frequency_Handover_via_XN_best_cell_wait_timer_started
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-2   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          2    NRCELL-2   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare syslogs checks A-B9 UE1_U2
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_A_B9_after_feature_deactivation_best_cell_wait_timer_running
    set test variable    ${measRep_7}      Received measId: 7
    set test variable    ${TimerStarted}   measurementReportPrioritizationTimer Timer is started with 70000 milliseconds
    set test variable    ${TimerExpired}   measurementReportPrioritizationTimer Timer expired for UE
    set test variable    ${TimerDeleted}   Timer measurementReportPrioritizationTimer deleted
    set test variable    ${deltaCommiss}   CP-NB received CpUeNiddDeliveryResponse OK


prepare counters and expected values B9 NRCELL-1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B9_after_feature_deactivation_best_cell_wait_timer_running
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          2    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare syslogs checks A-B8
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_A_B8_after_feature_deactivation_best_cell_wait_timer_not_running
    set test variable    ${measRep_11}     Received measId: 11
    set test variable    ${TimerStarted}   measurementReportPrioritizationTimer Timer is started with 60000 milliseconds
    set test variable    ${TimerExpired}   measurementReportPrioritizationTimer Timer expired for UE





prepare counters and expected values B8 1st measurement period NRCELL-1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B8_after_feature_deactivation_best_cell_wait_timer_not_running
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          4    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare counters and expected values B8 2nd measurement period NRCELL-1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B8_after_feature_deactivation_best_cell_wait_timer_not_running
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          4    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare syslogs checks A-B6 UE1
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_A_B6_measurement_report_with_A1_best_cell_wait_timer_still_running
    set test variable    ${measRep_4}      Received measId: 4
    set test variable    ${measRep_11}     Received measId: 11
    set test variable    ${measRep_12}     Received measId: 12
    set test variable    ${measRep_15}     Received measId: 15
    set test variable    ${TimerStarted}   measurementReportPrioritizationTimer Timer is started with 10000 milliseconds
    set test variable    ${TimerExpired}   measurementReportPrioritizationTimer Timer expired for UE
    set test variable    ${TimerDeleted}   Timer measurementReportPrioritizationTimer deleted


prepare syslogs checks A-B6 UE2
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_A_B6_measurement_report_with_A1_best_cell_wait_timer_still_running
    set test variable    ${measRep_12}     Received measId: 12
    set test variable    ${measRep_15}     Received measId: 15
    set test variable    ${TimerStarted}   measurementReportPrioritizationTimer Timer is started with 10000 milliseconds
    set test variable    ${TimerExpired}   measurementReportPrioritizationTimer Timer expired for UE
    set test variable    ${TimerDeleted}   Timer measurementReportPrioritizationTimer deleted


prepare counters and expected values B6 1st measurement period
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B6_measurement_report_with_A1_best_cell_wait_timer_still_running
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55142C00523}             ${text_M55142C00523}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00524}             ${text_M55142C00524}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00525}             ${text_M55142C00525}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          5    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00523=${M55142C00523}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00525=${M55142C00525}
    ...                                              M55142C00526=${M55142C00526}


prepare counters and expected values B6 2nd measurement period
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_A_B6_measurement_report_with_A1_best_cell_wait_timer_still_running
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55142C00523}             ${text_M55142C00523}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00524}             ${text_M55142C00524}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00525}             ${text_M55142C00525}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          4    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00523=${M55142C00523}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00525=${M55142C00525}
    ...                                              M55142C00526=${M55142C00526}
