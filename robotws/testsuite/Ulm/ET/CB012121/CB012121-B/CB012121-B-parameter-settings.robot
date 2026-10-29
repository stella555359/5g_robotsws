*** Settings ***
Documentation   This is a keyword file for CB012121-B, part parameter settings
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


prepare counters and expected values B-B1-Alt2 NRCELL-1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_B_B1_ALT2_Priority_of_frequency_not_relevant_when_ony_one_frequency_is_configured_in the_UE
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          1    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare syslogs checks B-B1-Alt2
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_B_B1_ALT2_Priority_of_frequency_not_relevant_when_ony_one_frequency_is_configured_in the_UE
    set test variable    ${MeasurementReportPrioritizationServiceSa}   Starting MeasurementReportPrioritizationServiceSa, strategy=2, delay=10000
    set test variable    ${TimerStarted}                               measurementReportPrioritizationTimer Timer is started with 10000 milliseconds
    set test variable    ${HighestPriorityFrequency}                   Report is for the highest priority frequency
    set test variable    ${PrioFinishingEarly}                         Report prioritization finishing early by report no. 1
    set test variable    ${TimeExpiryHighestPrior}                     MeasurementReportPrioritizationTimer expiry or highest priority report received
    set test variable    ${clearingPrio}                               Clearing MeasurementReportPrioritizationServiceSa
    set test variable    ${TimerDeleted}                               Timer measurementReportPrioritizationTimer deleted


prepare counters and expected values B-B6 NRCELL-1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_B_B6_measurement_report_with_A1_received_priority_wait_timer_is_running
    set test variable    @{M55142C00524}             ${text_M55142C00524}          0    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          2    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare syslogs checks B-B6
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_B_B6_measurement_report_with_A1_received_priority_wait_timer_is_running
    set test variable    ${MeasurementReportPrioritizationServiceSa}   Starting MeasurementReportPrioritizationServiceSa, strategy=2, delay=10000
    set test variable    ${TimerStarted}                               measurementReportPrioritizationTimer Timer is started with 10000 milliseconds
    set test variable    ${A1DeactiveInterFreq}                        Received A1 event in SA mode
    set test variable    ${clearingPrio}                               Clearing MeasurementReportPrioritizationServiceSa
    set test variable    ${TimerDeleted}                               Timer measurementReportPrioritizationTimer deleted


prepare counters and expected values B-B8 NRCELL-1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_B_B8_ALT1_gNB_receives_new_priority_from_OAM
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          2    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare syslogs checks B-B8
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_B_B8_ALT1_gNB_receives_new_priority_from_OAM
    set test variable    ${CpUeNiddDeliveryResponse}   CP-NB received CpUeNiddDeliveryResponse OK (transactionId: 5) from CP-UE
    set test variable    ${MeasurementReportPrioritizationServiceSa}   Starting MeasurementReportPrioritizationServiceSa, strategy=2, delay=10000
    set test variable    ${determinePriority}                          determinePriority measId=7, measType=InterFreqA3
    set test variable    ${a3a5Priority}                               nrHoIfParams->get().a3a5Priority.value()=60
    set test variable    ${TimerStarted}                               measurementReportPrioritizationTimer Timer is started with 10000 milliseconds
    set test variable    ${TimerExpired}                               measurementReportPrioritizationTimer Timer expired for UE
    set test variable    ${clearingPrio}                               Clearing MeasurementReportPrioritizationServiceSa
    set test variable    ${TimerDeleted}                               Timer measurementReportPrioritizationTimer deleted


prepare syslogs checks B-B10
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_B_B10_feature_de_activated_while_priority_timer_is_running
    set test variable    ${measRep_5}      Received measId: 5
    set test variable    ${measRep_7}      Received measId: 7
    set test variable    ${measRep_11}     Received measId: 11
    set test variable    ${MeasurementReportPrioritizationServiceSa}   Starting MeasurementReportPrioritizationServiceSa, strategy=2, delay=70000
    set test variable    ${highPrioUE}                                 highestPriorityConfiguredinUe=20
    set test variable    ${CpUeNiddDeliveryResponse}                   CP-NB received CpUeNiddDeliveryResponse OK
    set test variable    ${TimerStarted}                               measurementReportPrioritizationTimer Timer is started with 70000 milliseconds
    set test variable    ${TimerExpired}                               measurementReportPrioritizationTimer Timer expired for UE
    set test variable    ${TimerDeleted}                               Timer measurementReportPrioritizationTimer deleted


prepare counters and expected values B-B10
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_B_B10_feature_de_activated_while_priority_timer_is_running
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          4    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare counters and expected values B-B14
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_B_B14_ALT1_ANR_not_activated_measurement_report_with_unknown_PCI_and_second_with_known_PCI_received
    set test variable    @{M55142C00526}             ${text_M55142C00526}          3    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00526=${M55142C00526}


prepare counters and expected values B-B2-Alt3 NRCELL-1
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_B_B2_ALT3_after_inter_frequency_Handover_via_XN_priority_wait_timer_started
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          2    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare counters and expected values B-B2-Alt3 NRCELL-2
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_B_B2_ALT3_after_inter_frequency_Handover_via_XN_priority_wait_timer_started
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-2   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          2    NRCELL-2   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare syslogs checks B-B2-Alt3
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                             CB012121_B_B2_ALT3_after_inter_frequency_Handover_via_XN_priority_wait_timer_started
    set test variable    ${measRep_5}      Received measId: 5
    set test variable    ${measRep_7}      Received measId: 7
    set test variable    ${measRep_15}     Received measId: 15
    set test variable    ${measRep_21}     Received measId: 21
    set test variable    ${MeasRepPrioServSa}   Starting MeasurementReportPrioritizationServiceSa, strategy=2, delay=10000
    set test variable    ${TimerStarted}                               measurementReportPrioritizationTimer Timer is started with 10000 milliseconds
    set test variable    ${TimerExpired}                               measurementReportPrioritizationTimer Timer expired for UE
    set test variable    ${TimerDeleted}                               Timer measurementReportPrioritizationTimer deleted


prepare counters and expected values B-B3-Alt2-Alt3
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_B_B3_ALT2_several_measurements_received_with_same_priority_received_measurement_with_best_rsrp_selected
    set test variable    @{M55142C00524}             ${text_M55142C00524}          1    NRCELL-1   NRMO
    set test variable    @{M55142C00526}             ${text_M55142C00526}          4    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00524=${M55142C00524}
    ...                                              M55142C00526=${M55142C00526}


prepare syslogs checks B-B3-Alt2-Alt3
    [Documentation]    [PRIVATE]    set syslog search values for
    ...                           CB012121_B_B3_ALT2_several_measurements_received_with_same_priority_received_measurement_with_best_rsrp_selected
    set test variable    ${measRep_5}      Received measId: 5
    set test variable    ${measRep_7}      Received measId: 7
    set test variable    ${measRep_11}     Received measId: 11
    set test variable    ${MeasRepPrioServSa}   Starting MeasurementReportPrioritizationServiceSa, strategy=2, delay=10000
    set test variable    ${TimerStarted}                               measurementReportPrioritizationTimer Timer is started with 10000 milliseconds
    set test variable    ${TimerExpired}                               measurementReportPrioritizationTimer Timer expired for UE
    set test variable    ${TimerDeleted}                               Timer measurementReportPrioritizationTimer deleted
    set test variable    ${highPrioUE}                                 highestPriorityConfiguredinUe=20


prepare counters and expected values B-B4
    [Documentation]    [PRIVATE]    set expected values for
    ...                             CB012121_B_B4_no_hanover_started_after_priority_timer_expiry_due_to_not_allowed_pci
    set test variable    @{M55142C00526}             ${text_M55142C00526}          2    NRCELL-1   NRMO
    set test variable    &{dict_pm_counter}
    ...                                              M55142C00526=${M55142C00526}
