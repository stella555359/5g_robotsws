*** Settings ***
Documentation   This is a keyword file for CB006139, part counter
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../../resources/Common/pmcounters.robot

Library         String

*** Keywords ***

Save Date For Egate Log ${run}
    [Documentation]    [PRIVATE]   Save Date For Egate Log
    ...     :Autor: Sylvia Schneider
    ${year}  ${month}  ${day}     Get Time       year,month,day
    ${period_date}   Set Variable   ${year}-${month}-${day}
    Set Test Variable   ${period_date_${run}}   ${period_date}


Verify Counter M55118C00053
    [Documentation]    [PRIVATE]   Verify Counter M55118C00053
    ...     :Autor: Sylvia Schneider
    Log To Console    \nverify duration counter M55118C00053

    ${parsed_PmFileDuration}    Parse Xml    ${pm_file_name_with_path}
    ${xpath}    Set Variable
    ...     *[DN='PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1']/../NE-WBTS_1.0[@measurementType="NCAC"]/M55118C00053
    ${pm_M55118C00053}    Get Element Text     ${parsed_PmFileDuration}        xpath=.//${xpath}

    CB006139-keywords-egate-verify.Prepare Egate File For Verification    ${resultDir}/egate/egate_console.log
    ${search}   Set Variable   PhysCellId:54] SCellIndex 3 activated successfully at airphone
    ${found_item}       Grep File   ${resultDir}/egate.txt       ${search}
    ${scell_act_time}   Fetch From Left   ${found_item}   ${SPACE}
    ${scell_act_time}   Catenate       ${period_date_1st}     ${scell_act_time}
    Log To Console    PhysCellId:54] SCellIndex 3 activated time is ${scell_act_time}

    ${found_item}   Grep File   ${resultDir}/egate_pdu_release_ue1.txt       UE1: Released PDU session ID=1
    ${tmp}          Get Regexp Matches   ${found_item}    [0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9]*
    ${pdu_release_time}   Catenate       ${period_date_1st}     ${tmp}[0]
    Log To Console    pdu release time is ${pdu_release_time}

    ${calc_M55118C00053}    DateTime.Subtract Date From Date    ${pdu_release_time}           ${scell_act_time}
    ${min_M55118C00053}     Evaluate    ${calc_M55118C00053}*0.9
    ${max_M55118C00053}     Evaluate    ${calc_M55118C00053}*1.1
    ${result}   Set Variable If   ${min_M55118C00053} <= ${pm_M55118C00053} <= ${max_M55118C00053}   Passed   Failed
    ${msg1}     Set Variable    \ncounter M55118C00053 "${text_M55118C00053}" for object NRCELL-1
    ${msg2}     Set Variable    \nmin.expectedValue ${min_M55118C00053} <= pm fileValue ${pm_M55118C00053} <= max.expectedValue ${max_M55118C00053}
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE        Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=M55118C00053
    ...   value=${pm_M55118C00053}
    ...   result=${result}


Verify Duration Counter
    [Documentation]    [PRIVATE]   Verify Duration Counter
    ...     :Autor: Sylvia Schneider
    Log To Console    \nverify duration counter from 2nd measurement period

    ${parsed_PmFileDuration}    Parse Xml    ${pm_file_name_2nd_with_path}
    ${xpath}    Set Variable
    ...     *[DN='PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1']/../NE-WBTS_1.0[@measurementType="NCAC"]/M55118C00088
    ${pm_M55118C00088}    Get Element Text     ${parsed_PmFileDuration}        xpath=.//${xpath}
    ${xpath}    Set Variable
    ...     *[DN='PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1']/../NE-WBTS_1.0[@measurementType="NCAC"]/M55118C00089
    ${pm_M55118C00089}    Get Element Text     ${parsed_PmFileDuration}        xpath=.//${xpath}
    ${xpath}    Set Variable
    ...     *[DN='PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1']/../NE-WBTS_1.0[@measurementType="NCAC"]/M55118C00094
    ${pm_M55118C00094}    Get Element Text     ${parsed_PmFileDuration}        xpath=.//${xpath}

    ${found_item}   Grep File   ${resultDir}/egate_pdu_release_ue2.txt       UE2: Released PDU session ID=1
    ${tmp}          Get Regexp Matches   ${found_item}    [0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9]*
    ${pdu_release_time}   Catenate       ${period_date_2nd}     ${tmp}[0]
    Log To Console    pdu release time is ${pdu_release_time}

    CB006139-keywords-egate-verify.Prepare Egate File For Verification    ${resultDir}/egate/egate_console.log

    ${search}   Set Variable   PhysCellId:54] SCellIndex 3 activated successfully at airphone
    ${found_list}       Grep File   ${resultDir}/egate.txt       ${search}
    ${found_items}      Get Line   ${found_list}   1
    ${scell_act_time}   Fetch From Left   ${found_items}   ${SPACE}
    ${scell_act_time}   Catenate       ${period_date_2nd}     ${scell_act_time}
    Log To Console    PhysCellId:54] SCellIndex 3 activated time is ${scell_act_time}

    ${egate_file}   Get File    ${resultDir}/egate.txt
    ${parts_stopTraf}   Split String   ${egate_file}   Stopped Downlink Internal traffic on Ue:2 UpfId:1 Pdu:1 Qfi:1 TrfId:6
    ${parts_rrc}   Split String   ${parts_stopTraf}[1]     value DL-DCCH-Message
    ${scell_release_time_tmp}   Fetch From Left   ${parts_rrc}[0]   ${SPACE}
    ${scell_release_time}   Remove String    ${scell_release_time_tmp}    \n
    ${scell_release_time}   Catenate       ${period_date_1st}     ${scell_release_time}
    Log To Console    sCellToRelease 3 time is ${scell_release_time}

    ${calc_M55118C00088}    DateTime.Subtract Date From Date    ${scell_act_time}           ${scell_release_time}
    ${min_M55118C00088}     Evaluate    ${calc_M55118C00088}-5
    ${max_M55118C00088}     Evaluate    ${calc_M55118C00088}+5
    ${result}   Set Variable If   ${min_M55118C00088} <= ${pm_M55118C00088} <= ${max_M55118C00088}   Passed   Failed
    ${msg1}     Set Variable    \ncounter M55118C00088 "${text_M55118C00088}" for object NRCELL-1
    ${msg2}     Set Variable    \nmin.expectedValue ${min_M55118C00088} <= pm fileValue ${pm_M55118C00088} <= max.expectedValue ${max_M55118C00088}
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE        Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=M55118C00088
    ...   value=${pm_M55118C00088}
    ...   result=${result}

    ${calc_M55118C00089_94}    DateTime.Subtract Date From Date    ${pdu_release_time}         ${scell_act_time}
    ${min_M55118C00089_94}     Evaluate    ${calc_M55118C00089_94}-1
    ${max_M55118C00089_94}     Evaluate    ${calc_M55118C00089_94}+2
    ${result}   Set Variable If   ${min_M55118C00089_94} <= ${pm_M55118C00089} <= ${max_M55118C00089_94}   Passed   Failed
    ${msg1}     Set Variable    \ncounter M55118C00089 "${text_M55118C00089}" for object NRCELL-1
    ${msg2}     Set Variable
    ...    \nmin.expectedValue ${min_M55118C00089_94} <= pm fileValue ${pm_M55118C00089} <= max.expectedValue ${max_M55118C00089_94}
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=M55118C00089
    ...   value=${pm_M55118C00089}
    ...   result=${result}
    ${result}   Set Variable If   ${min_M55118C00089_94} <= ${pm_M55118C00094} <= ${max_M55118C00089_94}   Passed   Failed
    ${msg1}         Set Variable      \ncounter M55118C00094 "${text_M55118C00094}" for object NRCELL-1
    ${msg2}         Set Variable
    ...    \nmin.expectedValue ${min_M55118C00089_94} <= pm fileValue ${pm_M55118C00094} <= max.expectedValue ${max_M55118C00089_94}
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE        Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=M55118C00094
    ...   value=${pm_M55118C00094}
    ...   result=${result}


Collect Pm Counter File
    [Documentation]    [PRIVATE]   collect pm counter file for coam classical gnb
    ...     :Autor: Sylvia Schneider
    Log To Console    \nuploading pm file from coam
    ${webservice}    Create Dictionary
    ...            host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            port=443

    tafpmcounters.create pm collector
    ...    name=gnb_pm_counters
    ...    webservice=${webservice}
    tafpmcounters.setup collectors
    ...    names=gnb_pm_counters
    tafpmcounters.collect collectors
    ...    names=gnb_pm_counters
    ...    target_dir=${resultDir}
    tafpmcounters.teardown collectors
    ...    names=gnb_pm_counters


Collect Pm Counter File And Filter Last 2 PM Counters File Coam
    [Documentation]    [PRIVATE]   filter last 2 pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    collect pm counter file

    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    Set Variable If    '${rc}'=='${0}'    pass    fail
    IF    '${result}'=='fail'    Fail    no measurement file available
    ${temp}    Split To Lines    ${all_pm_file}
    Set Test Variable    ${pm_file_name_2nd_with_path}    ${resultDir}/${coam_pm_file_path}/${temp[0]}
    Set Test Variable    ${pm_file_name_1st_with_path}    ${resultDir}/${coam_pm_file_path}/${temp[1]}


Collect And Filter Last PM Counters File Coam
    [Documentation]    [PRIVATE]   Collect and Filter last PM Counters file coam
    ...     :Autor: Sylvia Schneider
    collect pm counter file

    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    Set Variable If    '${rc}'=='${0}'    pass    fail
    IF     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    Split To Lines    ${all_pm_file}
    ${pm_file_name}    Set Variable    ${temp[0]}
    ${pm_file_name_with_path}    Set Variable    ${resultDir}/${coam_pm_file_path}/${pm_file_name}

    Move File    ${pm_file_name_with_path}    ${resultDir}/
    Empty Directory    ${resultDir}/${coam_pm_file_path}
    Move File    ${resultDir}/${pm_file_name}   ${resultDir}/${coam_pm_file_path}/

    Set Test Variable   ${pm_file_name_with_path}


Verify Single Counter 6139
    [Documentation]    [PRIVATE]   verify counter expected value and value from pm file
    ...     :Autor: Sylvia Schneider
    [Arguments]    ${counter_no}
    ${counter}    Set Variable    ${counter_${counter_no}}[0]
    ${counter_check}    Set Variable       ${counter_${counter_no}}[1]
    ${counter_cell}    Set Variable        ${counter_${counter_no}}[2]
    ${counter_meastype}    Set Variable    ${counter_${counter_no}}[3]
    ${counter_distName}    Set Variable    PLMN-PLMN/MRBTS-1/NRBTS-1/${counter_cell}

    ${xpath}    Replace Variables
    ...     *[DN='${counter_distName}']/../NE-WBTS_1.0[@measurementType="${counter_meastype}"]/${counter}
    ${counter_value_from_pm_xml}    Get Element Text     ${parsed_PmFile}        xpath=.//${xpath}
    ${result}       Set Variable If    ${counter_value_from_pm_xml}${counter_check}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counter} "${text_${counter}}" for cell ${counter_cell}
    ${msg2}         Set Variable      pm file value ${counter_value_from_pm_xml} ${counter_check}\n
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    IF    '${result}'=='Failed'    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    report pm counter
    ...   id=${counter}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


Verify Counter CB006139 ${tc}
    [Documentation]    [PRIVATE]   verify counter CB006139
    ...     :Autor: Sylvia Schneider
    collect pm counter file and filter last 2 PM Counters file coam
    FOR   ${period}   IN   1st   2nd
      verify measurement period    ${period}   ${tc}
    END


Verify Measurement Period
    [Documentation]    [PRIVATE]   verify measurement period
    ...     :Autor: Sylvia Schneider
    [Arguments]    ${period}   ${tc}
    Log To Console    \nVerify counters of ${period} measurement period
    Run Keyword   prepare counters and expected values ${period} measurement period ${tc}
    ${parsed_PmFile}    Parse Xml    ${pm_file_name_${period}_with_path}
    Set Test Variable    ${parsed_PmFile}
    ${range_end}   Evaluate   ${no_counters_to_check}+1
    FOR    ${counter_no}    IN RANGE  1   ${range_end}
       Verify Single Counter 6139    ${counter_no}
    END


Verify Counter AA B7
    [Documentation]    [PRIVATE]   Verify Counter AA B7
    ...     :Autor: Sylvia Schneider
    Prepare Counters And Expected Values AA B7
    Collect And Filter Last PM Counters File COAM
    ${parsed_PmFile}    Parse Xml    ${pm_file_name_with_path}
    Set Test Variable    ${parsed_PmFile}
    ${range_end}   Evaluate   ${no_counters_to_check}+1
    FOR    ${counter_no}    IN RANGE  1   ${range_end}
       Verify Single Counter 6139    ${counter_no}
    END


Verify Counter DA ${tc}
    [Documentation]    [PRIVATE]   Verify Counter DA B1, B3, B12
    ...     :Autor: Sylvia Schneider
    Run Keyword   Prepare Counters And Expected Values DA ${tc}
    Collect And Filter Last PM Counters File COAM
    ${parsed_PmFile}    Parse Xml    ${pm_file_name_with_path}
    Set Test Variable    ${parsed_PmFile}
    ${range_end}   Evaluate   ${no_counters_to_check}+1
    FOR    ${counter_no}    IN RANGE  1   ${range_end}
       Verify Single Counter 6139    ${counter_no}
    END


Collect PM Counter Of 2 GNBs
    [Documentation]    [PRIVATE]    Collect PM Counter Of 2 GNBs
    ...       :Autor: Sylvia Schneider
    Log To Console   collect counters of primary gNB
    OperatingSystem.Create Directory     ${resultDir}/counter_gnb1
    ${path_counter_gnb1}    Collect PM Counter    gnb_id=0   target_dir=${resultDir}/counter_gnb1
    ${rc}   ${all_pm_file_gnb1}  OperatingSystem.Run And Return Rc And Output  ls -r ${path_counter_gnb1} | grep PM.*ANY.xml
    IF    '${rc}'!='${0}'    Fail    no measurement file available for primary gNB
    ${temp}    String.Split To Lines    ${all_pm_file_gnb1}
    Set Test Variable    ${gnb1_pm_file_name_2nd_with_path}    ${path_counter_gnb1}/${temp[0]}
    Set Test Variable    ${gnb1_pm_file_name_1st_with_path}    ${path_counter_gnb1}/${temp[1]}

    Log To Console   collect counters of external gNB
    OperatingSystem.Create Directory     ${resultDir}/counter_gnb2
    ${path_counter_gnb2}    Collect PM Counter    gnb_id=1   target_dir=${resultDir}/counter_gnb2
    ${rc}   ${all_pm_file_gnb2}   OperatingSystem.Run And Return Rc And Output   ls -r ${path_counter_gnb2} | grep PM.*ANY.xml
    IF    '${rc}'!='${0}'    Fail    no measurement file available for external gNB
    ${temp}    String.Split To Lines    ${all_pm_file_gnb2}
    Set Test Variable    ${gnb2_pm_file_name_2nd_with_path}    ${path_counter_gnb2}/${temp[0]}
    Set Test Variable    ${gnb2_pm_file_name_1st_with_path}    ${path_counter_gnb2}/${temp[1]}


Verify EB counter
    [Documentation]    [PRIVATE]    Verify EB counter
    ...       :Autor: Sylvia Schneider
    Prepare Counters And Expected Values For gNB1 1st And 2nd Measurement Period EB
    FOR   ${period}   IN
    ...   1st
    ...   2nd
       Log To Console   Verify counters of primpary gNB from ${period} measurement period
       ${parsed_PmFile}    XML.Parse Xml    ${gnb1_pm_file_name_${period}_with_path}
       Set Test Variable    ${parsed_PmFile}
       ${range_end}   Evaluate   ${no_counters_to_check}+1
       FOR    ${counter_no}    IN RANGE  1   ${range_end}
           Verify Single Counter 6139   ${counter_no}
       END
    END

    FOR   ${period}   IN
    ...   1st
    ...   2nd
       Log To Console   Verify counters of external gNB from ${period} measurement period
       Run Keyword   Prepare Counters And Expected Values For gNB2 ${period} Measurement Period EB
       ${parsed_PmFile}    XML.Parse Xml    ${gnb2_pm_file_name_${period}_with_path}
       Set Test Variable    ${parsed_PmFile}
       ${range_end}   Evaluate   ${no_counters_to_check}+1
       FOR    ${counter_no}    IN RANGE  1   ${range_end}
           Verify Single Counter 6139 NRBTS-2   ${counter_no}
       END
    END


Verify Single Counter 6139 NRBTS-2
    [Documentation]    [PRIVATE]   verify counter expected value and value from pm file for NRBTS-2
    ...     :Autor: Sylvia Schneider
    [Arguments]    ${counter_no}
    ${counter}    Set Variable    ${counter_${counter_no}}[0]
    ${counter_check}    Set Variable       ${counter_${counter_no}}[1]
    ${counter_cell}    Set Variable        ${counter_${counter_no}}[2]
    ${counter_meastype}    Set Variable    ${counter_${counter_no}}[3]
    ${counter_distName}    Set Variable    PLMN-PLMN/MRBTS-1/NRBTS-2/${counter_cell}

    ${xpath}    Replace Variables
    ...     *[DN='${counter_distName}']/../NE-WBTS_1.0[@measurementType="${counter_meastype}"]/${counter}
    ${counter_value_from_pm_xml}    XML.Get Element Text     ${parsed_PmFile}        xpath=.//${xpath}
    ${result}       Set Variable If    ${counter_value_from_pm_xml}${counter_check}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counter} "${text_${counter}}" for cell ${counter_cell}
    ${msg2}         Set Variable      pm file value ${counter_value_from_pm_xml} ${counter_check}\n
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE                     Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report PM Counter
    ...   id=${counter}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}
