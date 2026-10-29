*** Settings ***
Documentation   This is a keyword file for CB012121-A part egate verify
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***



prepare egate file for verification
    [Documentation]    [PRIVATE]    prepare egate file for verification, remove empty lines, strip lines
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${egate_log_file}
    ${contents}    Get File           ${egate_log_file}
    Create File    ${resultDir}/egate.txt
    @{lines}       Split to lines     ${contents}

    FOR   ${line}    IN    @{lines}
       ${length}    GetLength    ${line}
       IF  ${length} == 0    CONTINUE
       ${line_wo_blanks}     Strip String     ${line}
       Append To File    ${resultDir}/egate.txt    ${line_wo_blanks}\n
    END


verify egate logs t1
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB012121_A_B1_ALT1_feature_activation_interaction_with_mobility_profiles_best_cell_wait_timer_zero
    ...       :Autor: Sylvia Schneider

    FOR   ${run}        ${operation}     ${time_diff_expected}   IN
    ...   1            <                 1.0
    ...   2            >                 10.1
       Log To Console    \nVerify A3 trigger handover time difference ${operation}${time_diff_expected}s, scenario ${run}
       prepare egate file for verification    ${resultDir}/egate_A3_handover_ue1_log${run}.txt
       ${contents}    Get File           ${resultDir}/egate.txt
       ${line_after_send_meas}   Get Line                      ${contents}    0
       ${send_meas_time}         Get Regexp Matches	      ${line_after_send_meas}   (\\d+:\\d+:\\d+.\\d+)
       ${send_meas_time_conv}    DateTime.Convert Time         ${send_meas_time}[0]
       Log To Console    start measurement time: ${send_meas_time}

       ${line_start_HO}          Get Lines Containing String   ${contents}   Configuring Radio in AM for 5QI 6
       ${start_HO_time}          Get Regexp Matches	           ${line_start_HO}   (\\d+:\\d+:\\d+.\\d+)
       ${start_HO_time_conv}     DateTime.Convert Time    ${start_HO_time}[0]
       Log To Console    start handover time: ${start_HO_time}

       ${time_diff}    DateTime.subtract time from time    ${start_HO_time_conv}    ${send_meas_time_conv}
       Log To Console    verify that difference between HO start time ${start_HO_time} and start measurement ${send_meas_time}
       ...   is ${operation} ${time_diff_expected}s
       run keyword and continue on Failure   should be true   ${time_diff} < ${time_diff_expected}
    END


verify egate logs B4
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB012121_A_B4_no_handover_preparation_after_best_cell_wait_timer_expiry
    ...       :Autor: Sylvia Schneider

    Log To Console    \nVerify A3 with phycell_id=55 does not contain handover
    prepare egate file for verification    ${resultDir}/egate_log_A3_ue1_log1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   handover
    ...   rrcReconfiguration
    ...   PATH_SWITCH
       Log To Console    Check that "${search_for}" is not contained
       Run Keyword And Continue On Failure   Should Not Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify A3 with phycell_id=54 does not contain handover
    prepare egate file for verification    ${resultDir}/egate_log_A3_ue1_log2.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   handover
    ...   rrcReconfiguration
    ...   PATH_SWITCH
       Log To Console    Check that "${search_for}" is not contained
       Run Keyword And Continue On Failure   Should Not Contain   ${contents}    ${search_for}
    END
