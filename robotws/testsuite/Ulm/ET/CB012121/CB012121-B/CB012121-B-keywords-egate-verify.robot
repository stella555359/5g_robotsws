*** Settings ***
Documentation   This is a keyword file for CB012121-B part egate verify
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


verify egate logs B-B4
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB012121_B_B4_no_handover_preparation_after_best_cell_wait_timer_expiry
    ...       :Autor: Sylvia Schneider

    Log To Console    \nVerify A3 with phycell_id=55 does not contain handover
    prepare egate file for verification    ${resultDir}/egate_log_A3_log1.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   handover
    ...   rrcReconfiguration
    ...   PATH_SWITCH
       Log To Console    Check that "${search_for}" is not contained
       Run Keyword And Continue On Failure   Should Not Contain   ${contents}    ${search_for}
    END

    Log To Console    \nVerify A3 with phycell_id=54 does not contain handover
    prepare egate file for verification    ${resultDir}/egate_log_A3_log2.txt
    ${contents}    Get File           ${resultDir}/egate.txt
    FOR   ${search_for}    IN
    ...   handover
    ...   rrcReconfiguration
    ...   PATH_SWITCH
       Log To Console    Check that "${search_for}" is not contained
       Run Keyword And Continue On Failure   Should Not Contain   ${contents}    ${search_for}
    END
