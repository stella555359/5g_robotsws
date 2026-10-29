*** Settings ***
Documentation   This is a keyword file for CB012121-B verify syslogs
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

check syslog file B_B1_Alt2
    [Documentation]    [PRIVATE]    check syslog file B_B1_Alt2
    ...       :Autor: Yasir Mehmood
    Log To Console   \nCheck syslog trace of UE1
    unpack syslog file   ${resultDir}/UE1
    prepare syslogs checks B-B1-Alt2
    search for 1 entry TimeHoTgtSel
    set test variable   ${TimeHoTgtSel}   ${TimeHoTgtSel_NRCELL-1}

    ${int_starting_prio_service}   search for 1 entry   ${MeasurementReportPrioritizationServiceSa}
    ${int_TimerStarted}            search for 1 entry   ${TimerStarted}
    ${int_highest_prio_freq}       search for 1 entry   ${HighestPriorityFrequency}
    ${int_prio_finish_early}       search for 1 entry   ${PrioFinishingEarly}
    ${int_timer_exp_high_prio}     search for 1 entry   ${TimeExpiryHighestPrior}
    ${int_clearingPrio}            search for 1 entry   ${clearingPrio}
    ${int_TimerDeleted}            search for 1 entry   ${TimerDeleted}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                     ${lineNum_item1}                              ${item2}                          ${lineNum_item2}    IN
    ...   ${MeasurementReportPrioritizationServiceSa}  ${int_starting_prio_service}  ${TimerStarted}                   ${int_TimerStarted}
    ...   ${TimerStarted}              ${int_TimerStarted}                           ${HighestPriorityFrequency}       ${int_highest_prio_freq}
    ...   ${HighestPriorityFrequency}  ${int_highest_prio_freq}                      ${PrioFinishingEarly}             ${int_prio_finish_early}
    ...   ${PrioFinishingEarly}        ${int_prio_finish_early}                      ${TimeExpiryHighestPrior}         ${int_timer_exp_high_prio}
    ...   ${TimeExpiryHighestPrior}    ${int_timer_exp_high_prio}                    ${clearingPrio}                   ${int_clearingPrio}
    ...   ${clearingPrio}              ${int_clearingPrio}                           ${TimerDeleted}                   ${int_TimerDeleted}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END


check syslog file B_B6
    [Documentation]    [PRIVATE]    check syslog file B_B6
    ...       :Autor: Yasir Mehmood
    Log To Console   \nCheck syslog trace of UE1
    unpack syslog file   ${resultDir}/UE1
    prepare syslogs checks B-B6

    ${int_starting_prio_service}  search for 1 entry   ${MeasurementReportPrioritizationServiceSa}
    ${int_TimerStarted}           search for 1 entry   ${TimerStarted}
    ${int_A1DeactiveInterFreq}    search for 1 entry   ${A1DeactiveInterFreq}
    ${int_clearingPrio}           search for 1 entry   ${clearingPrio}
    ${int_TimerDeleted}           search for 1 entry   ${TimerDeleted}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                     ${lineNum_item1}                              ${item2}                          ${lineNum_item2}    IN
    ...   ${MeasurementReportPrioritizationServiceSa}  ${int_starting_prio_service}  ${TimerStarted}                   ${int_TimerStarted}
    ...   ${TimerStarted}              ${int_TimerStarted}                           ${A1DeactiveInterFreq}            ${int_A1DeactiveInterFreq}
    ...   ${A1DeactiveInterFreq}       ${int_A1DeactiveInterFreq}                    ${clearingPrio}                   ${int_clearingPrio}
    ...   ${clearingPrio}              ${int_clearingPrio}                           ${TimerDeleted}                   ${int_TimerDeleted}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END


check syslog file B_B8
    [Documentation]    [PRIVATE]    check syslog file B_B8
    ...       :Autor: Sylvia Schneider
    Log To Console   \nCheck syslog trace of UE1
    unpack syslog file   ${resultDir}/UE1
    prepare syslogs checks B-B8

    ${int_CpUeNiddDeliveryResponse_5}   search for 1 entry   ${CpUeNiddDeliveryResponse}
    ${int_starting_prio_service}  search for 1 entry   ${MeasurementReportPrioritizationServiceSa}
    ${int_determinePrio}          search for 1 entry   ${determinePriority}
    ${int_a3a5Priority}           search for 1 entry   ${a3a5Priority}
    ${int_TimerStarted}           search for 1 entry   ${TimerStarted}
    ${int_TimerExpired}           search for 1 entry   ${TimerExpired}
    ${int_clearingPrio}           search for 1 entry   ${clearingPrio}
    ${int_TimerDeleted}           search for 1 entry   ${TimerDeleted}

    search for 1 entry TimeHoTgtSel

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                     ${lineNum_item1}                              ${item2}                          ${lineNum_item2}    IN
    ...   ${CpUeNiddDeliveryResponse}  ${int_CpUeNiddDeliveryResponse_5}  ${MeasurementReportPrioritizationServiceSa}  ${int_starting_prio_service}
    ...   ${MeasurementReportPrioritizationServiceSa}  ${int_starting_prio_service}  ${determinePriority}              ${int_determinePrio}
    ...   ${determinePriority}         ${int_determinePrio}                          ${a3a5Priority}                   ${int_a3a5Priority}
    ...   ${a3a5Priority}              ${int_a3a5Priority}                           ${TimerStarted}                   ${int_TimerStarted}
    ...   ${TimerStarted}              ${int_TimerStarted}                           ${TimerExpired}                   ${int_TimerExpired}
    ...   ${TimerExpired}              ${int_TimerExpired}                           ${clearingPrio}                   ${int_clearingPrio}
    ...   ${clearingPrio}              ${int_clearingPrio}                           ${TimerDeleted}                   ${int_TimerDeleted}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END


check syslog file B_B10
    [Documentation]    [PRIVATE]    check syslog file B_B10
    ...       :Autor: Sylvia Schneider
    prepare syslogs checks B-B10

    Log To Console   \nCheck syslog trace of UE1
    unpack syslog file   ${resultDir}/UE1
    check single syslog file B_B10
    search for 1 entry TimeHoTgtSel
    set test variable   ${TimeHoTgtSel_1st}   ${TimeHoTgtSel_NRCELL-1}

    Log To Console   \nCheck syslog trace of UE2
    unpack syslog file   ${resultDir}/UE2
    check single syslog file B_B10
    search for 1 entry TimeHoTgtSel
    set test variable   ${TimeHoTgtSel_2nd}   ${TimeHoTgtSel_NRCELL-1}


check single syslog file B_B10
    [Documentation]    [PRIVATE]    check single syslog file B_B10
    ...       :Autor: Sylvia Schneider
    ${int_measRep_5_1}   ${int_measRep_5_2}         search for 2 entries   ${measRep_5}
    ${int_starting_prio_service}  search for 1 entry   ${MeasurementReportPrioritizationServiceSa}
    ${int_highPrioUE}                               search for 1 entry   ${highPrioUE}
    ${int_TimerStarted}                             search for 1 entry   ${TimerStarted}
    ${int_CpUeNiddDeliveryResponse_1}   ${int_CpUeNiddDeliveryResponse_2}     search for 2 entries   ${CpUeNiddDeliveryResponse}
    ${int_measRep_11}                               search for 1 entry   ${measRep_11}
    ${int_measRep_7}                                search for 1 entry   ${measRep_7}
    ${int_TimerExpired}                             search for 1 entry   ${TimerExpired}
    ${int_TimerDeleted}                             search for 1 entry   ${TimerDeleted}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                     ${lineNum_item1}                   ${item2}                          ${lineNum_item2}    IN
    ...   ${measRep_5}                 ${int_measRep_5_1}                 ${MeasurementReportPrioritizationServiceSa}   ${int_starting_prio_service}
    ...   ${MeasurementReportPrioritizationServiceSa}   ${int_starting_prio_service}   ${highPrioUE}        ${int_highPrioUE}
    ...   ${highPrioUE}                ${int_highPrioUE}                  ${TimerStarted}                   ${int_TimerStarted}
    ...   ${TimerStarted}              ${int_TimerStarted}                ${measRep_5}                      ${int_measRep_5_2}
    ...   ${measRep_5}                 ${int_measRep_5_2}                 ${CpUeNiddDeliveryResponse}       ${int_CpUeNiddDeliveryResponse_2}
    ...   ${CpUeNiddDeliveryResponse}  ${int_CpUeNiddDeliveryResponse_2}  ${measRep_11}                     ${int_measRep_11}
    ...   ${measRep_11}                ${int_measRep_11}                  ${measRep_7}                      ${int_measRep_7}
    ...   ${measRep_7}                 ${int_measRep_7}                   ${TimerExpired}                   ${int_TimerExpired}
    ...   ${TimerExpired}              ${int_TimerExpired}                ${TimerDeleted}                   ${int_TimerDeleted}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END


check syslog file B_B2-Alt3
    [Documentation]    [PRIVATE]    check syslog file B_B2-Alt3
    ...       :Autor: Sylvia Schneider
    Log To Console   \nCheck syslog trace of UE21
    prepare syslogs checks B-B2-Alt3
    unpack syslog file   ${resultDir}/UE21
    ${int_measRep_5}                                  search for 1 entry   ${measRep_5}
    ${int_measRep_7}                                  search for 1 entry   ${measRep_7}
    ${int_measRep_15}                                 search for 1 entry   ${measRep_15}
    ${int_measRep_21}                                 search for 1 entry   ${measRep_21}
    ${int_TimerStarted_1}   ${int_TimerStarted_2}     search for 2 entries   ${TimerStarted}
    ${int_TimerExpired_1}   ${int_TimerExpired_2}     search for 2 entries   ${TimerExpired}
    ${int_TimerDeleted_1}   ${int_TimerDeleted_2}     search for 2 entries   ${TimerDeleted}
    ${int_MeasRepPrioServSa_1}   ${int_MeasRepPrioServSa_2}     search for 2 entries   ${MeasRepPrioServSa}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                     ${lineNum_item1}                   ${item2}                          ${lineNum_item2}    IN
    ...   ${measRep_7}                 ${int_measRep_7}                   ${MeasRepPrioServSa}              ${int_MeasRepPrioServSa_1}
    ...   ${MeasRepPrioServSa}         ${int_MeasRepPrioServSa_1}         ${TimerStarted}                   ${int_TimerStarted_1}
    ...   ${TimerStarted}              ${int_TimerStarted_1}              ${measRep_5}                      ${int_measRep_5}
    ...   ${measRep_5}                 ${int_measRep_5}                   ${TimerExpired}                   ${int_TimerExpired_1}
    ...   ${TimerExpired}              ${int_TimerExpired_1}              ${TimerDeleted}                   ${int_TimerDeleted_1}
    ...   ${TimerDeleted}              ${int_TimerDeleted_1}              ${measRep21}                      ${int_measRep_21}
    ...   ${measRep21}                 ${int_measRep_21}                  ${MeasRepPrioServSa}              ${int_MeasRepPrioServSa_2}
    ...   ${MeasRepPrioServSa}         ${int_MeasRepPrioServSa_2}         ${TimerStarted}                   ${int_TimerStarted_2}
    ...   ${TimerStarted}              ${int_TimerStarted_2}              ${measRep_15}                     ${int_measRep_15}
    ...   ${measRep_15}                ${int_measRep_15}                  ${TimerExpired}                   ${int_TimerExpired_2}
    ...   ${TimerExpired}              ${int_TimerExpired_2}              ${TimerDeleted}                   ${int_TimerDeleted_2}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END

    search for 2 entries TimeHoTgtSel


check syslog file B_B3-Alt2-Alt3
    [Documentation]    [PRIVATE]    check syslog file B_B3-Alt2-Alt3
    ...       :Autor: Sylvia Schneider
    prepare syslogs checks B-B3-Alt2-Alt3

    Log To Console   \nCheck syslog trace of UE1
    unpack syslog file   ${resultDir}/UE1
    check single syslog file B-B3-Alt2-Alt3
    search for 1 entry TimeHoTgtSel
    set test variable   ${TimeHoTgtSel_1st}   ${TimeHoTgtSel_NRCELL-1}

    Log To Console   \nCheck syslog trace of UE2
    unpack syslog file   ${resultDir}/UE2
    check single syslog file B-B3-Alt2-Alt3
    search for 1 entry TimeHoTgtSel
    set test variable   ${TimeHoTgtSel_2nd}   ${TimeHoTgtSel_NRCELL-1}


check single syslog file B-B3-Alt2-Alt3
    [Documentation]    [PRIVATE]    check single syslog file B-B3-Alt2-Alt3
    ...       :Autor: Sylvia Schneider
    ${int_measRep_7}                                search for 1 entry     ${measRep_7}
    ${int_measRep_11}                               search for 1 entry     ${measRep_11}
    ${int_measRep_5_1}   ${int_measRep_5_2}         search for 2 entries   ${measRep_5}
    ${int_highPrioUE}                               search for 1 entry     ${highPrioUE}
    ${int_TimerStarted}                             search for 1 entry     ${TimerStarted}
    ${int_TimerExpired}                             search for 1 entry     ${TimerExpired}
    ${int_TimerDeleted}                             search for 1 entry     ${TimerDeleted}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                   ${lineNum_item1}             ${item2}                   ${lineNum_item2}    IN
    ...   ${measRep_7}               ${int_measRep_7}             ${highPrioUE}              ${int_highPrioUE}
    ...   ${highPrioUE}              ${int_highPrioUE}            ${TimerStarted}            ${int_TimerStarted}
    ...   ${TimerStarted}            ${int_TimerStarted}          ${measRep_11}              ${int_measRep_11}
    ...   ${measRep_11}              ${int_measRep_11}            ${measRep_5}               ${int_measRep_5_1}
    ...   ${measRep_5}               ${int_measRep_5_1}           ${measRep_5}               ${int_measRep_5_2}
    ...   ${measRep_5}               ${int_measRep_5_2}           ${TimerExpired}            ${int_TimerExpired}
    ...   ${TimerExpired}            ${int_TimerExpired}          ${TimerDeleted}            ${int_TimerDeleted}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END

