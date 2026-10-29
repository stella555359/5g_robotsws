*** Settings ***
Documentation   This is a keyword file for CB008146-E, part egate verification keywords
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
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


verify measIdToAddModList from egate log
    [Documentation]    [PRIVATE]    extract. prepare and verify measIdToAddModList
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${expected_measIdToAddModList}
    Log To Console    \ncheck measIdToAddModList
    ${contents}    Get File           ${resultDir}/egate.txt
    ${temp_1}    Fetch from right      ${contents}     measIdToAddModList
    ${temp}      Fetch from left       ${temp_1}       }\n}
    ${all_parts}    Split String      ${temp}      },
    ${egate_measIdToAddModList}    Create List
    FOR    ${part}    IN    @{all_parts}
      ${temp2}    Replace String   ${part}     \n     ${EMPTY}
      ${temp3}    Replace String   ${temp2}     {     ${EMPTY}
      ${temp4}    Replace String   ${temp3}     }     ${EMPTY}
      ${item_present}     Run Keyword And Return Status    Should Contain    ${temp4}      measId
      IF   '${item_present}'=='False'    BREAK
      Append To List    ${egate_measIdToAddModList}  ${temp4}
    END
    ${length_expected}    get length     ${expected_measIdToAddModList}
    ${length_egateLog}    get length     ${egate_measIdToAddModList}
    Run Keyword And Continue On Failure
    ...   Should Be Equal As Integers    ${length_expected}     ${length_egateLog}
    ...   number of events in measIdToAddModList incorrect
    FOR   ${item}   IN      @{expected_measIdToAddModList}
       Log To Console    check that ${item} present
       Run Keyword And Continue On Failure   Should Contain Match   ${egate_measIdToAddModList}    *${item}   ${item} not present
    END


verify measIdToRemoveList from egate log
    [Documentation]    [PRIVATE]    extract. prepare and verify measIdToRemoveList
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${expected_measIdToRemoveList}
    Log To Console    \ncheck measIdToRemoveList
    ${contents}    Get File           ${resultDir}/egate.txt
    ${temp1}    Fetch from right      ${contents}     measIdToRemoveList
    ${temp2}    Fetch from left       ${temp1}        },
    ${temp3}    Replace String   ${temp2}     \n     ${EMPTY}
    ${temp4}    Replace String   ${temp3}     {      ${EMPTY}

    ${all_parts}    Split String      ${temp4}        ,
    ${egate_measIdToRemoveList}    Create List
    FOR    ${part}    IN    @{all_parts}
      Append To List    ${egate_measIdToRemoveList}  ${part}
    END
    ${length_expected}    get length     ${expected_measIdToRemoveList}
    ${length_egateLog}    get length     ${egate_measIdToRemoveList}
    Run Keyword And Continue On Failure
    ...   Should Be Equal As Integers    ${length_expected}     ${length_egateLog}
    ...   number of events in measIdToRemoveList incorrect
    FOR   ${item}   IN      @{expected_measIdToRemoveList}
       Log To Console    check that ${item} present
       Run Keyword And Continue On Failure   List Should Contain Value   ${egate_measIdToRemoveList}    ${item}   ${item} not present
    END


verify measGapConfig from egate log
    [Documentation]    [PRIVATE]    extract. prepare and verify measGapConfig
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${expected_measGapConfig}
    Log To Console    \ncheck measGapConfig
    ${contents}    Get File           ${resultDir}/egate.txt
    ${temp1}    Fetch from right      ${contents}     measGapConfig
    ${temp2}    Fetch from left       ${temp1}        },
    FOR    ${part}    IN    @{expected_measGapConfig}
       Log To Console       check that "${part}" present
       Run Keyword and Continue on Failure    Should Contain      ${temp2}        ${part}
    END


verify gapUE release present in egate log
    [Documentation]    [PRIVATE]    verify gapUE release present
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck gapUE release
    ${contents}    Get File           ${resultDir}/egate.txt
    Log To Console       check that "gapUE release : NULL" present
    Run Keyword and Continue on Failure    Should Contain           ${contents}         gapUE release : NULL


verify Inter-eNB handover present in egate log
    [Documentation]    [PRIVATE]    verify Inter-eNB handover present
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${search_text}
    Log To Console    \ncheck string "${search_text}" present
    ${contents}    Get File           ${resultDir}/egate.txt
    Run Keyword and Continue on Failure    Should Contain           ${contents}         ${search_text}


verify not present in egate log
    [Documentation]    [PRIVATE]    verify that a special string is not present
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${string_not_present}
    Log To Console    \ncheck no "${string_not_present}"
    ${contents}    Get File           ${resultDir}/egate.txt
    Run Keyword and Continue on Failure    Should Not Contain           ${contents}         ${string_not_present}


verify reportConfigToAddModList from egate log with a2-Threshold for ${test}
    [Documentation]    [PRIVATE]    verify reportConfigToAddModList containing reportConfigId, eventId, a2-Threshold_rsrp
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck in reportConfigToAddModList all reportConfigId, all eventId, 1st and 2nd a2-Threshold_rsrp
    ${contents}    Get File           ${resultDir}/egate.txt
    ${temp1}    Fetch from right      ${contents}     reportConfigToAddModList
    ${act_config}   Split String     ${temp1}    includeBeamMeasurements
    ${number_of_configs}   get length     ${${test}_reportConfigId}
        FOR     ${index}   IN RANGE    0   ${number_of_configs}
         Log To Console       checking config for index ${index}:
         Log To Console       check that "${${test}_reportConfigId}[${index}]" present
         Run Keyword and Continue on Failure    Should Contain           ${act_config}[${index}]         ${${test}_reportConfigId}[${index}]
         Log To Console       check that "${${test}_eventId}[${index}]" present
         Run Keyword and Continue on Failure    Should Contain           ${act_config}[${index}]         ${${test}_eventId}[${index}]
         IF    ${index}>1   CONTINUE
         Log To Console       check that "${${test}_a2-Threshold_rsrp}[${index}]" present
         Run Keyword and Continue on Failure    Should Contain           ${act_config}[${index}]         ${${test}_a2-Threshold_rsrp}[${index}]
    END


verify reportConfigToAddModList from egate log for A2 ${test}
    [Documentation]    [PRIVATE]    verify reportConfigToAddModList containing reportConfigId, eventId, a1_a3_rsrp
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck in reportConfigToAddModList reportConfigId, eventId, a1_a3_rsrp
    ${contents}    Get File           ${resultDir}/egate.txt
    ${temp1}    Fetch from right      ${contents}     reportConfigToAddModList
    ${act_config}   Split String     ${temp1}    includeBeamMeasurements
    ${number_of_configs}   get length     ${${test}_A2_reportConfigId}
    FOR     ${index}   IN RANGE    0   ${number_of_configs}
         Log To Console       checking config for index ${index}:
         Log To Console       check that "${${test}_A2_reportConfigId}[${index}]" present
         Run Keyword and Continue on Failure    Should Contain           ${act_config}[${index}]         ${${test}_A2_reportConfigId}[${index}]
         Log To Console       check that "${${test}_A2_eventId}[${index}]" present
         Run Keyword and Continue on Failure    Should Contain           ${act_config}[${index}]         ${${test}_A2_eventId}[${index}]
         Log To Console       check that "${${test}_A2_a1_a3_rsrp}[${index}]" present
         Run Keyword and Continue on Failure    Should Contain           ${act_config}[${index}]         ${${test}_A2_a1_a3_rsrp}[${index}]
    END


verify reportConfigToAddModList from egate log for test ${test}
    [Documentation]    [PRIVATE]    verify reportConfigToAddModList 1st item containing reportConfigId, eventId, a2-Threshold rsrp
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck in reportConfigToAddModList reportConfigId, eventId, a2-Threshold rsrp

    ${scf_xml}    Parse Xml    ${resultDir}/SCF_final.xml
    ${xpath_NRCELL-10}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10"]
    ${rsrp_HoSA}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdhoSsbRsrpSA"]
    ${rsrpVoNr_HoSA}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdHoSsbRsrpVoNr"]

    IF        $test in ['t3_pdu', 't4_pdu']
              @{rCTAMList}   Create List    reportConfigId 1    eventId eventA2   a2-Threshold rsrp : ${rsrp_HoSA}
    ELSE IF   "${test}"=="t3_A1"
              @{rCTAMList}   Create List    reportConfigId 7    eventId eventA2   a2-Threshold rsrp : ${rsrp_HoSA}
    ELSE IF   "${test}"=="t4 pdu modify"
              @{rCTAMList}   Create List    reportConfigId 5    eventId eventA2   a2-Threshold rsrp : ${rsrpVoNr_HoSA}
    ELSE IF   "${test}"=="t4_A1"
              @{rCTAMList}   Create List    reportConfigId 8    eventId eventA2   a2-Threshold rsrp : ${rsrpVoNr_HoSA}
    END
    ${contents}       Get File           ${resultDir}/egate.txt
    ${temp1}          Fetch from right      ${contents}     reportConfigToAddModList
    ${act_report1}    Fetch from left       ${temp1}        includeBeamMeasurements
    Log To Console       check that "${rCTAMList}[0]" present
    Run Keyword and Continue on Failure    Should Contain           ${act_report1}         ${rCTAMList}[0]
    Log To Console       check that "${rCTAMList}[1]" present
    Run Keyword and Continue on Failure    Should Contain           ${act_report1}         ${rCTAMList}[1]
    Log To Console       check that "${rCTAMList}[2]" present
    Run Keyword and Continue on Failure    Should Contain           ${act_report1}         ${rCTAMList}[2]


verify reportConfigToAddModList from egate log reportConfigId eventId for ${test}
    [Documentation]    [PRIVATE]    verify reportConfigToAddModList containing reportConfigId, eventId
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck in reportConfigToAddModList reportConfigId, eventId
    ${contents}    Get File           ${resultDir}/egate.txt
    ${temp1}    Fetch from right      ${contents}     reportConfigToAddModList
    ${act_config}   Split String     ${temp1}    includeBeamMeasurements
    ${number_of_configs}   get length     ${${test}_reportConfigId}
    FOR     ${index}   IN RANGE    0   ${number_of_configs}
         Log To Console       checking config for index ${index}:
         Log To Console       check that "${${test}_reportConfigId}[${index}]" present
         Run Keyword and Continue on Failure    Should Contain           ${act_config}[${index}]         ${${test}_reportConfigId}[${index}]
         Log To Console       check that "${${test}_eventId}[${index}]" present
         Run Keyword and Continue on Failure    Should Contain           ${act_config}[${index}]         ${${test}_eventId}[${index}]
    END

