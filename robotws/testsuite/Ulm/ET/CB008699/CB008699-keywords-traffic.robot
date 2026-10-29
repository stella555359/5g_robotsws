*** Settings ***
Documentation   This is a keyword file for CB008699 part traffic
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***
${expected_average data rate_5Mbps}        4900000
${expected_Average packet rate_5Mbps}      490
${expected_average data rate_10Mbps}       9800000
${expected_Average packet rate_10Mbps}     980
${expected_Total packets dropped}    5
${expected_Packets corrupted}        5
${expected_Total packets lost}       5

${WIRESHARK_RUNNING}     false

*** Keywords ***


verify traffic statistics
    [Documentation]    [PRIVATE]    verify in egate log containing traffic
    ...       :Autor: Sylvia Schneider
    FOR   ${direction}         ${run}                         ${verify}    IN
    ...   dl                   after_pdu_setup                no
    ...   ul                   after_pdu_setup                no
    ...   dl                   after_handover                 yes
    ...   ul                   after_handover                 yes
       Log To Console    \nverify traffic statistics file egate_${direction}_ue1_qfi1_${run}.txt
       get values from egate traffic file
       ...    direction=${direction}   qfi=1   mbps=5    run=${run}    verify=${verify}
    END


verify traffic statistics t4
    [Documentation]    [PRIVATE]    verify in egate log containing traffic t4
    ...       :Autor: Sylvia Schneider
    FOR   ${direction}    ${qfi}   ${mbps}   ${run}                         ${verify}    IN
    ...   dl              1        5         after_pdu_setup                no
    ...   ul              1        5         after_pdu_setup                no
    ...   dl              2        10        after_pdu_setup                no
    ...   ul              2        10        after_pdu_setup                no
    ...   dl              1        5         after_handover                 yes
    ...   ul              1        5         after_handover                 yes
    ...   dl              2        10        after_handover                 yes
    ...   ul              2        10        after_handover                 yes
       Log To Console    \nverify traffic statistics file egate_${direction}_ue1_qfi${qfi}_${run}.txt
       get values from egate traffic file
       ...    direction=${direction}   qfi=${qfi}   mbps=${mbps}   run=${run}    verify=${verify}
    END


get values from egate traffic file
    [Documentation]    [PRIVATE]    get values from egate traffic file
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${direction}   ${qfi}   ${mbps}   ${run}    ${verify}
    ${contents}    Get File             ${resultDir}/egate_${direction}_ue1_qfi${qfi}_${run}.txt

    &{egate_values}   create dictionary
    FOR    ${search_string}    ${index}     IN
    ...    Average data rate      3
    ...    Average packet rate    3
    ...    Total packets dropped  3
    ...    Total packets lost     3
    ...    Packets corrupted      2
       ${line}      Get Lines Containing String     ${contents}     ${search_string}
       @{temp}      split string                    ${line}
       set to dictionary   ${egate_values}   ${search_string}=${temp}[${index}]
       Log To Console    ${search_string}=${temp}[${index}]
    END
    Log Dictionary    ${egate_values}
    IF   '${verify}'=='yes'    Verify Traffic Values    mbps=${mbps}   egate_values=${egate_values}


Verify Traffic Values
    [Documentation]    [PRIVATE]    verify_traffic values
    ...       :Autor: Sylvia Schneider
    [Arguments]      ${mbps}     ${egate_values}

    FOR   ${item}   ${operation}   ${expectedValue}   IN
    ...    Average data rate      >=     expected_average data rate_${mbps}Mbps
    ...    Average packet rate    >=     expected_Average packet rate_${mbps}Mbps
    ...    Total packets dropped  <      expected_Total packets dropped
    ...    Total packets lost     <      expected_Packets corrupted
    ...    Packets corrupted      <      expected_Total packets lost
       Log To Console    verify ${item} ${operation} ${${expectedValue}}
       ${value}   Get From Dictionary    ${egate_values}     ${item}
       ${result}   Set Variable If   ${value} ${operation} ${${expectedValue}}  Passed   Failed
       IF    '${result}'=='Failed'
       ...     Run Keyword And Continue On Failure    Fail    failed ${item}: ${value} ${operation} ${${expectedValue}}
   END
