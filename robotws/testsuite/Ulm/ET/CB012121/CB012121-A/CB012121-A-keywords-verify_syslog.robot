*** Settings ***
Documentation   This is a keyword file for CB012121-A verify syslogs
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        ../CB012121-common/CB012121-keywords-verify_syslog.robot


*** Keywords ***

check syslog file A_B2_ALT5
    [Documentation]    [PRIVATE]    check syslog file A_B2_ALT5
    ...       :Autor: Sylvia Schneider
    verify syslog file A_B2-Alt5 UE21
    verify syslog file A_B2-Alt5 UE22


verify syslog file A_B2-Alt5 UE21
    [Documentation]    [PRIVATE]    verify syslog file A_B2-Alt5 UE21
    ...       :Autor: Sylvia Schneider
    Log To Console   \nCheck syslog trace of UE21
    prepare syslogs checks A_B2-Alt5 UE21
    unpack syslog file   ${resultDir}/UE21
    ${int_measRep_6}                                    search for 1 entry     ${measRep_6}
    ${int_TimerStarted1}   ${int_TimerStarted2}         search for 2 entries   ${TimerStarted}
    ${int_HO_cell50}                                    search for 1 entry     ${HO_cell50}
    ${int_TimerDeleted1}   ${int_TimerDeleted2}         search for 2 entries   ${TimerDeleted}
    ${int_measRep_15}                                   search for 1 entry     ${measRep_15}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                ${lineNum_item1}                 ${item2}                  ${lineNum_item2}    IN
    ...   ${measRep_6}            ${int_measRep_6}                 ${TimerStarted}           ${int_TimerStarted1}
    ...   ${TimerStarted}         ${int_TimerStarted1}             ${HO_cell50}              ${int_HO_cell50}
    ...   ${HO_cell50}            ${int_HO_cell50}                 ${TimerDeleted}           ${int_TimerDeleted1}
    ...   ${TimerDeleted}         ${int_TimerDeleted1}             ${measRep_15}             ${int_measRep_15}
    ...   ${measRep_15}           ${int_measRep_15}                ${TimerStarted}           ${int_TimerStarted2}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END


verify syslog file A_B2-Alt5 UE22
    [Documentation]    [PRIVATE]    verify syslog file A_B2-Alt5 UE22
    ...       :Autor: Sylvia Schneider
    Log To Console   \nCheck syslog trace of UE22
    prepare syslogs checks A_B2-Alt5 UE22
    unpack syslog file   ${resultDir}/UE22
    ${int_measRep_6}                                    search for 1 entry     ${measRep_6}
    ${int_TimerStarted1}   ${int_TimerStarted2}         search for 2 entries   ${TimerStarted}
    ${int_HO_cell50}                                    search for 1 entry     ${HO_cell50}
    ${int_TimerDeleted1}   ${int_TimerDeleted2}         search for 2 entries   ${TimerDeleted}
    ${int_measRep_20}                                   search for 1 entry     ${measRep_20}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                ${lineNum_item1}                 ${item2}                  ${lineNum_item2}    IN
    ...   ${measRep_6}            ${int_measRep_6}                 ${TimerStarted}           ${int_TimerStarted1}
    ...   ${TimerStarted}         ${int_TimerStarted1}             ${HO_cell50}              ${int_HO_cell50}
    ...   ${HO_cell50}            ${int_HO_cell50}                 ${TimerDeleted}           ${int_TimerDeleted1}
    ...   ${TimerDeleted}         ${int_TimerDeleted1}             ${measRep_20}             ${int_measRep_20}
    ...   ${measRep_20}           ${int_measRep_20}                ${TimerStarted}           ${int_TimerStarted2}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END


check syslog file A_B2_ALT4
    [Documentation]    [PRIVATE]    check syslog file A_B2_ALT4
    ...       :Autor: Sylvia Schneider
    Log To Console   \nCheck syslog trace of UE21
    unpack syslog file   ${resultDir}/UE21
    verify syslog file A_B2_ALT4 UE21
    Log To Console   \nCheck syslog trace of UE22
    unpack syslog file   ${resultDir}/UE22
    verify syslog file A_B2_ALT4 UE22


verify syslog file A_B2_ALT4 UE21
    [Documentation]    [PRIVATE]    verify syslog file A_B2_ALT4 UE21
    ...       :Autor: Sylvia Schneider
    prepare syslogs checks A_B2_ALT4 UE21
    ${int_measRep_6}                                    search for 1 entry     ${measRep_6}
    ${int_TimerStarted1}   ${int_TimerStarted2}         search for 2 entries   ${TimerStarted}
    ${int_HO_cell50}                                    search for 1 entry     ${HO_cell50}
    ${int_HO_cell51}                                    search for 1 entry     ${HO_cell51}
    ${int_TimerDeleted1}   ${int_TimerDeleted2}         search for 2 entries   ${TimerDeleted}
    ${int_measRep_16}                                   search for 1 entry     ${measRep_16}
    ${int_measRep_15}                                   search for 1 entry     ${measRep_15}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                ${lineNum_item1}                 ${item2}                  ${lineNum_item2}    IN
    ...   ${measRep_6}            ${int_measRep_6}                 ${TimerStarted}           ${int_TimerStarted1}
    ...   ${TimerStarted}         ${int_TimerStarted1}             ${TimerDeleted}           ${int_TimerDeleted1}
    ...   ${TimerDeleted}         ${int_TimerDeleted1}             ${HO_cell50}              ${int_HO_cell50}
    ...   ${HO_cell50}            ${int_HO_cell50}                 ${measRep_16}             ${int_measRep_16}
    ...   ${measRep_16}           ${int_measRep_16}                ${TimerStarted}           ${int_TimerStarted2}
    ...   ${TimerStarted}         ${int_TimerStarted2}             ${measRep_15}             ${int_measRep_15}
    ...   ${measRep_15}           ${int_measRep_15}                ${TimerDeleted}           ${int_TimerDeleted2}
    ...   ${TimerDeleted}         ${int_TimerDeleted2}             ${HO_cell51}              ${int_HO_cell51}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END

    Log To Console   \nget TimeHoTgtSel for counter M55142C00523 and M55142C00525
    ${search_TimeHoTgtSel}  Grep File   ${syslog_file}   TimeHoTgtSel=
    run keyword and continue on failure    should not be empty    ${search_TimeHoTgtSel}   no TimeHoTgtSel found in syslog
    ${lines}  split to lines   ${search_TimeHoTgtSel}
    ${tmp}    Get Regexp Matches    ${lines}[0]    TimeHoTgtSel=([0-9]*)ms     1
    set test variable      ${TimeHoTgtSel_NRCELL-2_1st}    ${tmp}[0]
    Log To Console   ${syslog_file} has TimeHoTgtSel=${TimeHoTgtSel_NRCELL-2_1st} for NRCELL-2
    ${tmp}    Get Regexp Matches    ${lines}[1]    TimeHoTgtSel=([0-9]*)ms     1
    set test variable      ${TimeHoTgtSel_NRCELL-1_1st}    ${tmp}[0]
    Log To Console   ${syslog_file} has TimeHoTgtSel=${TimeHoTgtSel_NRCELL-1_1st} for NRCELL-1


verify syslog file A_B2_ALT4 UE22
    [Documentation]    [PRIVATE]    verify syslog file A_B2_ALT4 UE22
    ...       :Autor: Sylvia Schneider

    prepare syslogs checks A_B2_ALT4 UE22
    ${int_measRep_6}                                    search for 1 entry     ${measRep_6}
    ${int_TimerStarted1}   ${int_TimerStarted2}         search for 2 entries   ${TimerStarted}
    ${int_HO_cell50}                                    search for 1 entry     ${HO_cell50}
    ${int_TimerDeleted1}   ${int_TimerDeleted2}         search for 2 entries   ${TimerDeleted}
    ${int_measRep_21}                                   search for 1 entry     ${measRep_21}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                ${lineNum_item1}                 ${item2}                  ${lineNum_item2}    IN
    ...   ${measRep_6}            ${int_measRep_6}                 ${TimerStarted}           ${int_TimerStarted1}
    ...   ${TimerStarted}         ${int_TimerStarted1}             ${TimerDeleted}           ${int_TimerDeleted1}
    ...   ${TimerDeleted}         ${int_TimerDeleted1}             ${HO_cell50}              ${int_HO_cell50}
    ...   ${HO_cell50}            ${int_HO_cell50}                 ${measRep_21}             ${int_measRep_21}
    ...   ${measRep_21}           ${int_measRep_21}                ${TimerStarted}           ${int_TimerStarted2}
    ...   ${TimerStarted}         ${int_TimerStarted2}             ${TimerDeleted}           ${int_TimerDeleted2}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END

    Log To Console   \nget TimeHoTgtSel for counter M55142C00523 and M55142C00525
    ${search_TimeHoTgtSel}  Grep File   ${syslog_file}   TimeHoTgtSel=
    run keyword and continue on failure    should not be empty    ${search_TimeHoTgtSel}   no TimeHoTgtSel found in syslog
    ${lines}  split to lines   ${search_TimeHoTgtSel}
    ${tmp}    Get Regexp Matches    ${lines}[0]    TimeHoTgtSel=([0-9]*)ms     1
    set test variable      ${TimeHoTgtSel_NRCELL-2_2nd}    ${tmp}[0]
    Log To Console   ${syslog_file} has TimeHoTgtSel=${TimeHoTgtSel_NRCELL-2_2nd} for NRCELL-1


check syslog file A_B9
    [Documentation]    [PRIVATE]    check syslog file A_B9
    ...       :Autor: Sylvia Schneider
    Log To Console   \nCheck syslog trace of UE1 and UE2
    prepare syslogs checks A-B9 UE1_U2
    unpack syslog file   ${resultDir}/UE1_UE2

    ${int_measRep_7}                                    search for 1 entry     ${measRep_7}
    ${int_TimerStarted}                                 search for 1 entry     ${TimerStarted}
    ${int_deltaCommiss}                                 search for 1 entry     ${deltaCommiss}
    ${int_TimerExpired}                                 search for 1 entry     ${TimerExpired}
    ${int_TimerDeleted}                                 search for 1 entry     ${TimerDeleted}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                ${lineNum_item1}                 ${item2}                  ${lineNum_item2}    IN
    ...   ${measRep_7}            ${int_measRep_7}                 ${TimerStarted}           ${int_TimerStarted}
    ...   ${TimerStarted}         ${int_TimerStarted}              ${deltaCommiss}           ${int_deltaCommiss}
    ...   ${deltaCommiss}         ${int_deltaCommiss}              ${TimerExpired}           ${int_TimerExpired}
    ...   ${TimerExpired}         ${int_TimerExpired}              ${TimerDeleted}           ${int_TimerDeleted}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END

    Log To Console   \nget TimeHoTgtSel for counter M55142C00523 and M55142C00525
    ${search_TimeHoTgtSel}  Grep File   ${syslog_file}   TimeHoTgtSel=
    run keyword and continue on failure    should not be empty    ${search_TimeHoTgtSel}   no TimeHoTgtSel found in syslog
    ${lines}  split to lines   ${search_TimeHoTgtSel}
    ${tmp}    Get Regexp Matches    ${lines}[0]    TimeHoTgtSel=([0-9]*)ms     1
    set test variable      ${TimeHoTgtSel_NRCELL-1}    ${tmp}[0]
    Log To Console   ${syslog_file} has TimeHoTgtSel=${TimeHoTgtSel_NRCELL-1} for NRCELL-1


check syslog file A_B8
    [Documentation]    [PRIVATE]    check syslog file A_B8
    ...       :Autor: Sylvia Schneider
    Log To Console   \nCheck syslog trace of UE1 and UE2
    prepare syslogs checks A-B8

    unpack syslog file   ${resultDir}/UE1_UE2
    ${int_measRep_11_1}   ${int_measRep_11_2}           search for 2 entries   ${measRep_11}
    ${int_TimerStarted}                                 search for 1 entry     ${TimerStarted}
    ${int_TimerExpired}                                 search for 1 entry     ${TimerExpired}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                ${lineNum_item1}                 ${item2}                  ${lineNum_item2}    IN
    ...   ${measRep_11}           ${int_measRep_11_1}              ${TimerStarted}           ${int_TimerStarted}
    ...   ${TimerStarted}         ${int_TimerStarted}              ${TimerExpired}           ${int_TimerExpired}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END

    Log To Console   \nget TimeHoTgtSel UE1 for counter M55142C00523 and M55142C00525
    ${search_TimeHoTgtSel}  Grep File   ${syslog_file}   TimeHoTgtSel=
    run keyword and continue on failure    should not be empty    ${search_TimeHoTgtSel}   no TimeHoTgtSel found in syslog
    ${lines}  split to lines   ${search_TimeHoTgtSel}
    ${tmp}    Get Regexp Matches    ${lines}[0]    TimeHoTgtSel=([0-9]*)ms     1
    set test variable      ${TimeHoTgtSel_UE1}    ${tmp}[0]
    Log To Console   ${syslog_file} has TimeHoTgtSel=${TimeHoTgtSel_UE1} for NRCELL-1


    Log To Console   \nCheck syslog trace of UE3
    unpack syslog file   ${resultDir}/UE3

    ${int_measRep_11}                                   search for 1 entry     ${measRep_11}
    ${int_TimerStarted}                                 search for 1 entry     ${TimerStarted}
    ${int_TimerExpired}                                 search for 1 entry     ${TimerExpired}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                ${lineNum_item1}                 ${item2}                  ${lineNum_item2}    IN
    ...   ${measRep_11}           ${int_measRep_11}                ${TimerStarted}           ${int_TimerStarted}
    ...   ${TimerStarted}         ${int_TimerStarted}              ${TimerExpired}           ${int_TimerExpired}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END

    Log To Console   \nget TimeHoTgtSel UE3 for counter M55142C00523 and M55142C00525
    ${search_TimeHoTgtSel}  Grep File   ${syslog_file}   TimeHoTgtSel=
    run keyword and continue on failure    should not be empty    ${search_TimeHoTgtSel}   no TimeHoTgtSel found in syslog
    ${lines}  split to lines   ${search_TimeHoTgtSel}
    ${tmp}    Get Regexp Matches    ${lines}[0]    TimeHoTgtSel=([0-9]*)ms     1
    set test variable      ${TimeHoTgtSel_UE3}    ${tmp}[0]
    Log To Console   ${syslog_file} has TimeHoTgtSel=${TimeHoTgtSel_UE3} for NRCELL-1


check syslog file A_B6
    [Documentation]    [PRIVATE]    check syslog file A_B6
    ...       :Autor: Sylvia Schneider
    Log To Console   \nCheck syslog trace of UE1
    unpack syslog file   ${resultDir}/UE1
    prepare syslogs checks A-B6 UE1
    ${int_measRep_4}                                    search for 1 entry     ${measRep_4}
    ${int_measRep_11}                                   search for 1 entry     ${measRep_11}
    ${int_measRep_12}                                   search for 1 entry     ${measRep_12}
    ${int_measRep_15}                                   search for 1 entry     ${measRep_15}
    ${int_TimerExpired}                                 search for 1 entry     ${TimerExpired}
    ${int_TimerStarted1}   ${int_TimerStarted2}         search for 2 entries   ${TimerStarted}
    ${int_TimerDeleted1}   ${int_TimerDeleted2}         search for 2 entries   ${TimerDeleted}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                ${lineNum_item1}                 ${item2}                  ${lineNum_item2}    IN
    ...   ${measRep_11}           ${int_measRep_11}                ${TimerStarted}           ${int_TimerStarted1}
    ...   ${TimerStarted}         ${int_TimerStarted1}             ${measRep_4}              ${int_measRep_4}
    ...   ${measRep_4}            ${int_measRep_4}                 ${TimerDeleted}           ${int_TimerDeleted1}
    ...   ${TimerDeleted}         ${int_TimerDeleted1}             ${measRep_12}             ${int_measRep_12}
    ...   ${measRep_12}           ${int_measRep_12}                ${measRep_15}             ${int_measRep_15}
    ...   ${measRep_15}           ${int_measRep_15}                ${TimerStarted}           ${int_TimerStarted2}
    ...   ${TimerStarted}         ${int_TimerStarted2}             ${TimerExpired}           ${int_TimerExpired}
    ...   ${TimerExpired}         ${int_TimerExpired}              ${TimerDeleted}           ${int_TimerDeleted2}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END
    search for TimeHoTgtSel not present

    Log To Console   \nCheck syslog trace of UE2
    unpack syslog file   ${resultDir}/UE2
    prepare syslogs checks A-B6 UE2
    ${int_measRep_12}                                   search for 1 entry     ${measRep_12}
    ${int_measRep_15}                                   search for 1 entry     ${measRep_15}
    ${int_TimerStarted1}   ${int_TimerStarted2}         search for 2 entries   ${TimerStarted}
    ${int_TimerExpired1}   ${int_TimerExpired2}         search for 2 entries   ${TimerExpired}
    ${int_TimerDeleted1}   ${int_TimerDeleted2}         search for 2 entries   ${TimerDeleted}

    Log To Console   \nVerify correct order of messages
    FOR   ${item1}                ${lineNum_item1}                 ${item2}                  ${lineNum_item2}    IN
    ...   ${TimerStarted}         ${int_TimerStarted1}             ${TimerExpired}           ${int_TimerExpired1}
    ...   ${TimerExpired}         ${int_TimerExpired1}             ${TimerDeleted}           ${int_TimerDeleted1}
    ...   ${TimerDeleted}         ${int_TimerDeleted1}             ${measRep_12}             ${int_measRep_12}
    ...   ${measRep_12}           ${int_measRep_12}                ${measRep_15}             ${int_measRep_15}
    ...   ${measRep_15}           ${int_measRep_15}                ${TimerStarted}           ${int_TimerStarted2}
    ...   ${TimerStarted}         ${int_TimerStarted2}             ${TimerExpired}           ${int_TimerExpired2}
    ...   ${TimerExpired}         ${int_TimerExpired2}             ${TimerDeleted}           ${int_TimerDeleted2}
       Log To Console   \n${item1} (line ${lineNum_item1})
       Log To Console   - before
       Log To Console   - ${item2} (line ${lineNum_item2})
       run keyword and continue on failure    should be true   ${lineNum_item1} < ${lineNum_item2}
    END
    search for TimeHoTgtSel not present


search for TimeHoTgtSel not present
    [Documentation]    [PRIVATE]    search for TimeHoTgtSel not present
    ...       :Autor: Sylvia Schneider
    Log To Console   \nTimeHoTgtSel should not be present therefore counter M55142C00523 and M55142C00525 have value 0
    run keyword and continue on failure    should not contain    ${syslog_file}   TimeHoTgtSel  error TimeHoTgtSel found
