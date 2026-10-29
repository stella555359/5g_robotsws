*** Keywords ***
SSB RACH mapping check 1 ABF
    [Documentation]  Check SSB and RACH mapping in L1L2 traces when analog beamforming is disabled

    # SSB is sent on slot 0 of odd frames:
    # - in DlData_SlotTypeReq, check that slottype is equald to 2 on every slot 0 of all frames
    # - in DlData_PatternConfigReq, check that the beam id is set to 1 on every slot 0 of all frames and that no other beam is sent
    # RACH is sent on slot 9, 19, 29,..., 79 of even frames
    # - in DlData_SlotTypeReq, check that slottype is equald to 0 on every slot 0 of odd frames
    # - in DlData_PatternConfigReq, check that the beam id is set to 1 on every slot 0 of odd frames and that no other beam is sent


    # Check slot type request

    # ICOM_5G/DlData_SlotTypeReq,0x000002d0,0x00000003,28

    ${slottypereq}        grep file    ${logs_path}/pcapprocessedSlotTypeReq.txt    ICOM_5G\/DlData_SlotTypeReq
    @{lines_slottypereq}    split to lines    ${slottypereq}
    @{rach_slot_list_hex}    Create list    0x00000009  0x00000013  0x0000001d  0x00000027  0x00000031  0x0000003b  0x00000045  0x0000004f
    FOR     ${line}    IN    @{lines_slottypereq}
        @{line_content}    split string    ${line}    separator=,
        ${sfn}             convert to integer    ${line_content[1]}
        ${slot}            convert to integer    ${line_content[2]}
        ${slottype}        convert to integer    ${line_content[3]}
        ${is_sfn_odd}      evaluate    ${sfn}%2
        ${is_slot_for_rach}    Get index from list   ${rach_slot_list_hex}    ${line_content[2]}
        log    ${is_slot_for_rach}

        Run keyword if    ${slot} == 0    Should be equal as integers    ${slottype}    2
        Run keyword if    ${slottype} == 2    Should be equal as integers    ${slot}    0
        Run keyword if    ${is_sfn_odd} == 1 and ${is_slot_for_rach} >= 0
        ...               Should be equal as integers    ${slottype}    0
        Run keyword if    ${slottype} == 0      Run keywords
        ...                Should be equal as integers    ${is_sfn_odd}    1    AND
        ...                Should contain match    ${rach_slot_list_hex}    ${line_content[2]}
    END
    log    Check of slot type successfull

    # Check SSB 0 for Pattern 1:4 ABF (slot 0x00):
    ${cmd}      catenate      SEPARATOR=          cat ${logs_path}/pcapprocessedPatterns.txt | grep -E 'ICOM_5G/
    ...         DlData_PatternConfigReq,0x(.*),0x00000000,((ff){16}){4}(((0100){2}(ff){12})){2}((ff){16}){7}(ff){15}(ff)' -c
    ${nb_pattern_specific}      Run      ${cmd}
    ${nb_pattern_specific}      Convert to Number   ${nb_pattern_specific}  2
    ${nb_pattern}               Run      cat ${logs_path}/pcapprocessedPatterns.txt | grep -E 'ICOM_5G/DlData_PatternConfigReq,0x(.*),0x00000000' -c
    ${nb_pattern}               Convert to Number   ${nb_pattern}  2

    log                         Number of SSB patterns on slot 0: ${nb_pattern_specific}; total number of pattern on slot 0: ${nb_pattern}
    ${result}                   Evaluate   ${nb_pattern}/${nb_pattern_specific}
    Should Be Equal as integers      ${result}    1
    log    Check of SSB pattern successfull


    #Check Rach for Pattern 1:4 ABF
    @{rach_slot_list}    Create list    09  13  1d  27  31  3b  45  4f
    ${nb_pattern_specific_total}    set variable    0
    ${nb_pattern_specific_total}    convert to integer    ${nb_pattern_specific_total}
    ${nb_pattern_total}             set variable    0
    ${nb_pattern_total}             convert to integer    ${nb_pattern_total}

    FOR    ${rach_slot}    IN   @{rach_slot_list}
        ${cmd}      catenate      SEPARATOR=          cat ${logs_path}/pcapprocessedPatterns.txt | grep -E 'ICOM_5G/
        ...         DlData_PatternConfigReq,0x(.*),0x000000${rach_slot},((0100){2}(ff){12}){12}(ff){31}(ff)' -c
        ${nb_pattern_specific_slot}      Run      ${cmd}
        ${nb_pattern_specific_total}     Evaluate    ${nb_pattern_specific_total} + ${nb_pattern_specific_slot}
        ${cmd}      catenate      SEPARATOR=          cat ${logs_path}/pcapprocessedPatterns.txt | grep -E 'ICOM_5G/
        ...         DlData_PatternConfigReq,0x(.*),0x000000${rach_slot}' -c
        ${nb_pattern_slot}      Run      ${cmd}
        ${nb_pattern_total}     Evaluate    ${nb_pattern_total} + ${nb_pattern_slot}
    END
    log           Number of RACH patterns on slot 9, 19,.., 79: ${nb_pattern_specific}; total number of pattern on slot 9, 19,.., 79: ${nb_pattern}

    ${nb_pattern_specific_total}    Convert to Number   ${nb_pattern_specific_total}    2
    ${nb_pattern_total}             Convert to Number   ${nb_pattern_total}    2
    ${result}                   Evaluate   ${nb_pattern_total}/${nb_pattern_specific_total}
    Should Be True              1.8 < ${result} < 2.2
    log    Check of RACH pattern successfull

