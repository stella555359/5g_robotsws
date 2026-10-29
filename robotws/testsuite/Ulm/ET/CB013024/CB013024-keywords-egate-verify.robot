*** Settings ***
Documentation   This is a keyword file for CB013024 part egate verify
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------

Library         OperatingSystem
Library         String

Resource        ../../resources/Common/reporting.robot

*** Variables ***

${egate_log_name}  egate_pdu_setup_ue8.txt



*** Keywords ***

Prepare Egate File For Verification
    [Documentation]    [PRIVATE]    prepare egate file for verification, remove empty lines, strip lines
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${egate_log_file}
    ${contents}    OperatingSystem.Get File           ${egate_log_file}
    OperatingSystem.Create File    ${resultDir}/egate.txt
    @{lines}       Split to lines     ${contents}

    FOR   ${line}    IN    @{lines}
       ${length}    GetLength    ${line}
       IF  ${length} == 0    CONTINUE
       ${line_wo_blanks}     String.Strip String     ${line}
       OperatingSystem.Append To File    ${resultDir}/egate.txt    ${line_wo_blanks}\n
    END


Verify Egate Logs T1
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB013024_A_ET_TC4_interBand_5CC_BCS0_BCS1_CA_n1A_n3A-n28A_n78C
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \nVerify file egate_pdu_setup_ue1.txt
    Prepare Egate File For Verification    ${resultDir}/egate_pdu_setup_ue1.txt
    ${contents}    OperatingSystem.Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   sCellIndex 1,
    ...   physCellId 50,
    ...   sCellIndex 2,
    ...   physCellId 51,
    ...   sCellIndex 3,
    ...   physCellId 52,
    ...   sCellIndex 4,
    ...   physCellId 54,
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END

    Log To Console    \nVerify file egate_throughput_pusch_pdsch
    ${contents}    OperatingSystem.Get File           ${resultDir}/egate_throughput_pdsch.txt
    ${contents1}    OperatingSystem.Get File           ${resultDir}/egate_throughput_pusch.txt
    ${linedl}      String.Get Lines Containing String     ${contents}     5 cells
    @{tempdl}      String.split string                    ${linedl}
    ${average_throughputdl}   set variable   ${tempdl}[8]
    Log To Console   temp8dl- ${tempdl}[8]

    ${lineul}      String.Get Lines Containing String     ${contents1}     2 cells
    @{tempul}      String.split string                    ${lineul}
    ${average_throughputul}   set variable   ${tempul}[8]
    Log To Console   temp8ul- ${tempul}[8]

    Log To Console    Verify that average_throughput_dl ${average_throughputdl} > expected value 500
    ${resultdl}   Set Variable If   ${average_throughputdl} > 500  Passed   Failed
    Log To Console    Verify that average_throughput_ul ${average_throughputul} > expected value 200
    ${resultul}   Set Variable If   ${average_throughputul} > 200  Passed   Failed
    Log To Console    \n\n\n${resultdl}
    Log To Console    \n\n\n${resultul}
    IF    '${resultdl}&${resultul}'=='Failed'
    ...     Run Keyword And Continue On Failure    Fail    failed average_throughput ${average_throughput} > expected value 500


Verify Egate Logs ${tc}
    [Documentation]    [PRIVATE]    verify egate log for
    ...        CB013024_A_ET_TC1_interBand_2CC_BCS0_CA_n25A_n41A
    ...       :Autor: Anja Becher
    Log To Console    \nVerify file egate_pdu_setup_ue8.txt

    IF    '${tc}'=='TC1'
           Set Suite Variable      ${sCellindex}        1
           Set Suite Variable      ${sCellphyCell}      51
           Set Suite Variable      ${pCellindex}        0
           Set Suite Variable      ${pCellphyCell}      55

    ELSE IF    '${tc}'=='TMO'
           Set Suite Variable      ${sCellindex}        1
           Set Suite Variable      ${sCellphyCell}      53
           Set Suite Variable      ${pCellindex}        0
           Set Suite Variable      ${pCellphyCell}      58

           Set Suite Variable      ${egate_log_name}    egate_console.log
    END

    Prepare Egate File For Verification    ${resultDir}/${egate_log_name}
    ${contents}    OperatingSystem.Get File           ${resultDir}/egate.txt
    FOR   ${value}   IN
    ...   sCellIndex ${sCellindex},
    ...   physCellId ${sCellphyCell},
    ...   pcid:${pCellphyCell},
    ...   scellIdx:${pCellindex}
       Log To Console    Check that "${value}" is contained
       Run Keyword And Continue On Failure   Should Contain   ${contents}    ${value}
    END

    Log To Console    \nVerify file egate_throughput_pusch_pdsch
    ${contents}    OperatingSystem.Get File           ${resultDir}/egate_throughput_pdsch.txt
    ${contents1}    OperatingSystem.Get File           ${resultDir}/egate_throughput_pusch.txt
    ${linedl}      String.Get Lines Containing String     ${contents}     2 cells
    @{tempdl}      String.Split String                    ${linedl}
    ${average_throughputdl}   Set Variable   ${tempdl}[8]
    Log To Console   temp8dl- ${tempdl}[8]

    ${lineul}      String.Get Lines Containing String     ${contents1}     1 cell
    @{tempul}      String.Split String                    ${lineul}
    ${average_throughputul}   Set Variable   ${tempul}[8]
    Log To Console   temp8ul- ${tempul}[8]

    Log To Console    Verify that average_throughput_dl ${average_throughputdl} > expected value 300
    ${resultdl}   Set Variable If   ${average_throughputdl} > 300  Passed   Failed
    Log To Console    Verify that average_throughput_ul ${average_throughputul} > expected value 100
    ${resultul}   Set Variable If   ${average_throughputul} > 100  Passed   Failed
    Log To Console    \n\n\n${resultdl}
    Log To Console    \n\n\n${resultul}
    IF    '${resultdl}&${resultul}'=='Failed'
    ...     Run Keyword And Continue On Failure    Fail    failed average_throughput ${average_throughput} > expected value 100
