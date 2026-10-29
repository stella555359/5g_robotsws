*** Settings ***
Documentation   This is a keyword file for CB006139 CG part egate verify
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***
${THROUGHPUT_DL_HO}       170
${THROUGHPUT_UL_HO}       15

${MAX_THROUGHPUT_DL}      800
${MAX_THROUGHPUT_UL}      15



*** Keywords ***

Verify Egate Logs CG
    [Documentation]    [PRIVATE]    Verify Egate Logs CG
    ...       :Autor: Sylvia Schneider

    ${egate_file}  OperatingSystem.Get file   ${resultDir}/egate/egate_console.log
    Set Test Variable   ${egate_file}
    Verify 1st Measurement Period PCI56 And PCI57 Activated Successfully
    Verify Throughput After A4 And PhysCellId 55 SCellIndex 3 Activated
    Verify Throughput After A4 And PhysCellId 54 SCellIndex 2 Activated
    Verify Throughput After Handover
    Verify UE1 Located In Cell 5 After Handover


Verify 1st Measurement Period PCI56 And PCI57 Activated Successfully
    [Documentation]    [PRIVATE]    Verify 1st Measurement Period PCI56 And PCI57 Activated Successfully
    ...       :Autor: Sylvia Schneider
    FOR   ${PhysCellId}   ${SCellIndex}   IN
    ...   57              2
    ...   56              1
       ${search}  set variable
       ...  PhysCellId:${PhysCellId}] SCellIndex ${SCellIndex} activated successfully at airphone
       Log to console   --search for "${search}"
       ${found}  Get Lines Containing String   ${egate_file}       ${search}
       ${line_found}   Run Keyword And Return Status    Should Not Be Empty    ${found}
       IF    '${line_found}' == 'False'    Run Keyword And Continue On Failure   Fail   --not found
     END


Verify UE1 Located In Cell 5 After Handover
    [Documentation]    [PRIVATE]    Verify UE1 Located In Cell 5 After Handover
    ...       :Autor: Sylvia Schneider
    Log To Console   \n2nd measurement period verify after HO UE is located in cell5
    ${line_cell}  Grep File   ${resultDir}/egate_cell_info.txt       cell
    ${cell}       Remove String    ${line_cell}   ${SPACE}   ${EMPTY}
    IF  '${cell}'=='cell5'  Log To Console  Target ${cell} After Handover is correct
    ...  ELSE  Run Keyword And Continue On Failure    Fail   Target ${cell} After Handover is wrong, expected 'cell5'


Verify Throughput After Handover
    [Documentation]    [PRIVATE]    Verify Throughput After Handover
    ...       :Autor: Sylvia Schneider
    Log To Console   \n2nd measurement period verify throughput after HO

    Log To Console    verify file egate_throughput_pdsch_ue1_6.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pdsch_ue1_6.txt
    ${average_throughput_DL}    CB006139-keywords-egate-verify.Get Average Throughput  ${contents}  DL   1 cell
    Log To Console   Verify that average_throughput DL ${average_throughput_DL} > expected value ${THROUGHPUT_DL_HO}
    ${result}   Set Variable If   ${average_throughput_DL} > ${THROUGHPUT_DL_HO}  Passed   Failed
    IF    '${result}'=='Failed'
    ...     Run Keyword And Continue On Failure    Fail    failed ${average_throughput_DL} > expected value ${THROUGHPUT_DL_HO}

    Log To Console    verify file egate_throughput_pusch_ue1_6.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pusch_ue1_6.txt
    ${average_throughput_UL}    CB006139-keywords-egate-verify.Get Average Throughput  ${contents}  UL   1 cell
    Log To Console   Verify that average_throughput UL ${average_throughput_UL} > expected value ${THROUGHPUT_UL_HO}
    ${result}   Set Variable If   ${average_throughput_UL} > ${THROUGHPUT_UL_HO}  Passed   Failed
    IF    '${result}'=='Failed'
    ...     Run Keyword And Continue On Failure    Fail    failed ${average_throughput_UL} > expected value ${THROUGHPUT_UL_HO}


Verify Throughput After A4 And PhysCellId 55 SCellIndex 3 Activated
    [Documentation]    [PRIVATE]    Verify Throughput After A4 And PhysCellId 55 SCellIndex 3 Activated
    ...       :Autor: Sylvia Schneider
    Log To Console   \n1st measurement period verify throughput after A4 and PhysCellId 55 SCellIndex 3 activated
    Verify Max Throughput   run=2


Verify Throughput After A4 And PhysCellId 54 SCellIndex 2 Activated
    [Documentation]    [PRIVATE]    Verify Throughput After A4 And PhysCellId 54 SCellIndex 2 Activated
    ...       :Autor: Sylvia Schneider
    Log To Console   \n1st measurement period verify throughput after A4 and PhysCellId 54 SCellIndex 2 activated
    Verify Max Throughput   run=3


Verify Max Throughput
    [Documentation]    [PRIVATE]    Verify Max Throughput
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${run}
    Log To Console    verify file egate_throughput_pdsch_ue1_${run}.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pdsch_ue1_${run}.txt
    ${average_throughput_DL}    CB006139-keywords-egate-verify.Get Average Throughput  ${contents}  DL   4 cell
    Log To Console   Verify that average_throughput DL ${average_throughput_DL} > expected value ${MAX_THROUGHPUT_DL}
    ${result}   Set Variable If   ${average_throughput_DL} > ${MAX_THROUGHPUT_DL}  Passed   Failed
    IF    '${result}'=='Failed'
    ...     Run Keyword And Continue On Failure    Fail    failed ${average_throughput_DL} > expected value ${MAX_THROUGHPUT_DL}

    Log To Console    verify file egate_throughput_pusch_ue1_${run}.txt
    ${contents}    Get File           ${resultDir}/egate_throughput_pusch_ue1_${run}.txt
    ${average_throughput_UL}    CB006139-keywords-egate-verify.Get Average Throughput  ${contents}  UL   1 cell
    Log To Console   Verify that average_throughput UL ${average_throughput_UL} > expected value ${MAX_THROUGHPUT_UL}
    ${result}   Set Variable If   ${average_throughput_UL} > ${MAX_THROUGHPUT_UL}  Passed   Failed
    IF    '${result}'=='Failed'
    ...     Run Keyword And Continue On Failure    Fail    failed ${average_throughput_UL} > expected value ${MAX_THROUGHPUT_UL}

