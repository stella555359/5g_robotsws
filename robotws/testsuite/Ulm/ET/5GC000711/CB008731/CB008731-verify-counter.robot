*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part verify counter rohc 8731
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

Collect Pm Counter File And Filter Last 2 PM Counters File Coam
    [Documentation]    [PRIVATE]   filter last pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    Collect PM Counters file coam
    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    Set Variable If    '${rc}'=='${0}'    pass    fail
    IF     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    Split To Lines    ${all_pm_file}
    ${pm_file_name_2nd}              Set Variable    ${temp[0]}
    ${pm_file_name_2nd_with_path}    Set Variable    ${resultDir}/${coam_pm_file_path}/${pm_file_name_2nd}
    ${pm_file_name_1st}              Set Variable    ${temp[1]}
    ${pm_file_name_1st_with_path}    Set Variable    ${resultDir}/${coam_pm_file_path}/${pm_file_name_1st}

    Move File    ${pm_file_name_1st_with_path}         ${resultDir}/
    Move File    ${pm_file_name_2nd_with_path}         ${resultDir}/
    Empty Directory    ${resultDir}/${coam_pm_file_path}
    Move File    ${resultDir}/${pm_file_name_1st}      ${resultDir}/${coam_pm_file_path}/
    Move File    ${resultDir}/${pm_file_name_2nd}      ${resultDir}/${coam_pm_file_path}/

    ${file_string}   Get File   ${pm_file_name_1st_with_path}
    ${file_string}   Replace String    ${file_string}  ><  >\n<   count=-1
    Create File      ${resultDir}/pm_1st.xml    ${file_string}

    ${file_string}   Get File   ${pm_file_name_2nd_with_path}
    ${file_string}   Replace String    ${file_string}  ><  >\n<   count=-1
    Create File      ${resultDir}/pm_2nd.xml    ${file_string}

    Set Test Variable    ${pmCounter_xml_file_1st}    ${resultDir}/pm_1st.xml
    Set Test Variable    ${pmCounter_xml_file_2nd}    ${resultDir}/pm_2nd.xml


Verify Counters Of 1st Measurement Period t1
    [Documentation]    [PRIVATE]    verify counter in pm file using dictionary
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncounter 1st measurement period
    ${parsed_PmFile}     Parse Xml    ${pmCounter_xml_file_1st}
    Set Test Variable    ${parsed_PmFile}
    Log Dictionary      ${dict_rohc_pm_counter1}
    @{dict_keys}    Get Dictionary Keys    ${dict_rohc_pm_counter1}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_rohc_pm_counter1}    ${counter}
        Verify single counter >0    ${counter}    ${counterList}
    END


Save Date For Egate Log ${run}
    [Documentation]    [PRIVATE]   Save Date For Egate Log
    ...     :Autor: Sylvia Schneider
    ${year}  ${month}  ${day}     Get Time       year,month,day
    ${period_date}                Set Variable   ${year}-${month}-${day}
    Set Test Variable   ${HO_date_${run}}   ${period_date}


Verify Counter Of 2nd Measurment Period t1
    [Documentation]    [PRIVATE]    verify counter in 2 successive pm files
    ...       :Autor: Sylvia Schneider
    ${search}   Set Variable          Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed
    ${found_line}  Grep File   ${resultDir}/egate_handover_5G_ue1.txt   ${search}
    ${found_item}  Split String   ${found_line}   ${SPACE}

    ${time_handover}   Set Variable   ${found_item}[1]
    ${time_handover}   Catenate       ${HO_date_2ndPeriod}     ${time_handover}

    ${diff}    DateTime.Subtract Date From Date    ${time_release}    ${time_handover}
    ${duration}    Evaluate    ${diff}*1000
    Set Test Variable    ${duration}
    Log To Console   time between handover and ue release is ${duration} milisecs

    Log To Console    \ncounter 2nd measurement period
    ${parsed_PmFile}     Parse Xml    ${pmCounter_xml_file_2nd}
    Set Test Variable    ${parsed_PmFile}
    Log Dictionary       ${dict_pm_counter}
    @{dict_keys}         Get Dictionary Keys    ${dict_pm_counter}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_pm_counter}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_PmFile}
    END
    Verify Counter Calculate M55125C09526
    Verify Counter Calculate M55125C09516 t1
    Verify Counter Calculate M55320C19001
    Verify Counter Calculate M55320C19003
    Verify Single Counter >0    M55320C19002    ${M55320C19002}
    Verify Single Counter >0    M55320C19004    ${M55320C19004}
    Verify Counter M55163C00521


Verify Counters Of 1st Measurement Period t4
    [Documentation]    [PRIVATE]    verify counter in pm file using dictionary
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncounter 1st measurement period
    ${parsed_PmFile}     Parse Xml    ${pmCounter_xml_file_1st}
    Set Test Variable    ${parsed_PmFile}
    Log Dictionary      ${dict_pm_counter1}
    @{dict_keys}    Get Dictionary Keys    ${dict_pm_counter1}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_pm_counter1}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_PmFile}
    END


Verify Counter Of 2nd Measurment Period t4
    [Documentation]    [PRIVATE]    verify counter in 2 successive pm files
    ...       :Autor: Sylvia Schneider

    ${search}      Set Variable          Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed
    ${found_line}  Grep File   ${resultDir}/egate_handover_5G_ue3.txt   ${search}
    ${found_item}  Split String   ${found_line}   ${SPACE}

    ${time_handover}   Set Variable   ${found_item}[1]
    ${time_handover}   Catenate       ${HO_date_2ndPeriod}     ${time_handover}

    ${diff}        DateTime.Subtract Date From Date    ${time_release}    ${time_handover}
    ${duration}    Evaluate    ${diff}*1000
    Set Test Variable    ${duration}
    Log To Console   time between handover and ue release is ${duration} milisecs

    Log To Console       \ncounter 2nd measurement period
    ${parsed_PmFile}     Parse Xml    ${pmCounter_xml_file_2nd}
    Set Test Variable    ${parsed_PmFile}
    Log Dictionary       ${dict_pm_counter2}
    @{dict_keys}         Get Dictionary Keys    ${dict_pm_counter2}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_pm_counter2}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_PmFile}
    END
    Verify Counter Calculate M55125C09527
    Verify Counter Calculate M55125C09516 t4
    Verify Counter M55163C00521


Verify Counter Of Last Measurment Period t6
    [Documentation]    [PRIVATE]    verify counter of last measurment period t6
    ...       :Autor: Sylvia Schneider

    ${search}      Set Variable          Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed
    ${found_line}  Grep File   ${resultDir}/egate_handover_5G_ue1.txt   ${search}
    ${found_item}  Split String   ${found_line}   ${SPACE}

    ${time_handover}       Set Variable   ${found_item}[1]
    ${time_handover_ue1}   Catenate       ${HO_date_2ndPeriod}     ${time_handover}

    ${parsed_PmFile}     Parse Xml    ${pmCounter_xml_file}
    Set Test Variable    ${parsed_PmFile}

    ${duration}          DateTime.Subtract Date From Date    ${time_release}    ${time_handover_ue1}
    Set Test Variable    ${duration}
    Log To Console   time between handover and ue release of ue1 is ${duration} milisecs
    FOR    ${counterName}      ${packet_rate}    IN
    ...    M55319C11006        500
    ...    M55319C15006        500
        Verify Counter Calculate t5     ${counterName}      ${packet_rate}
    END


Verify Counter Of Last Measurment Period t5
    [Documentation]    [PRIVATE]    verify counter of last measurment period t5
    ...       :Autor: Sylvia Schneider

    ${parsed_PmFile}     Parse Xml    ${pmCounter_xml_file}
    Set Test Variable    ${parsed_PmFile}
    Verify Counter Ue1
    Verify Counter Ue2


Verify Counter Ue1
    [Documentation]    [PRIVATE]    verify counter of ue1
    ...       :Autor: Sylvia Schneider

    ${search}      Set Variable          Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed
    ${found_line}  Grep File   ${resultDir}/egate_handover_5G_ue1.txt   ${search}
    ${found_item}  Split String   ${found_line}   ${SPACE}

    ${time_handover}       Set Variable   ${found_item}[1]
    ${time_handover_ue1}   Catenate       ${HO_date_2ndPeriod}     ${time_handover}

    ${duration}          DateTime.Subtract Date From Date    ${time_release}    ${time_handover_ue1}
    Set Test Variable    ${duration}
    Log To Console   time between handover and ue release of ue1 is ${duration} milisecs
    FOR    ${counterName}      ${packet_rate}    IN
    ...    M55319C11001        10
    ...    M55319C11002        2750
    ...    M55319C11005        100
    ...    M55319C15001        10
    ...    M55319C15002        2750
    ...    M55319C15005        100
        Verify Counter Calculate t5     ${counterName}      ${packet_rate}
    END


Verify Counter Ue2
    [Documentation]    [PRIVATE]    verify counter of ue2
    ...       :Autor: Sylvia Schneider
    ${search}      Set Variable          Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed
    ${found_line}  Grep File   ${resultDir}/egate_handover_5G_ue2.txt   ${search}
    ${found_item}  Split String   ${found_line}   ${SPACE}

    ${time_handover}       Set Variable   ${found_item}[1]
    ${time_handover_ue2}   Catenate       ${HO_date_2ndPeriod}     ${time_handover}

    ${duration}          DateTime.Subtract Date From Date    ${time_release}    ${time_handover_ue2}
    Set Test Variable    ${duration}
    Log To Console   time between handover and ue release of ue2 is ${duration} milisecs
    FOR    ${counterName}      ${packet_rate}    IN
    ...    M55319C11010        1000
    ...    M55319C15010        1000
        Verify Counter Calculate t5     ${counterName}      ${packet_rate}
    END


Verify Counter Calculate t5
    [Documentation]    [PRIVATE]    calculate counter and verify for t5
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${counterName}    ${packet_rate}
    ${counter_text}        Set Variable    ${${counterName}}[0]
    ${counter_distName}    Set Variable    PLMN-PLMN/${${counterName}}[1]
    ${counter_meastype}    Set Variable    ${${counterName}}[2]

    ${xpath_param}    Get From Dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    ${xpath_param}    Replace Variables    ${xpath_param}
    ${counter_value_from_pm_xml}    Get Element Text     ${parsed_PmFile}        xpath=${xpath_param}
    ${start}   Evaluate   ${duration}*${packet_rate}*0.95
    ${end}     Evaluate   ${duration}*${packet_rate}
    ${result}       Set Variable If    ${start} <= ${counter_value_from_pm_xml} <= ${end}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counterName} "${counter_text}" for nrbts
    ${msg2}         Set Variable      ${start} <= pm file value ${counter_value_from_pm_xml} <= ${end}
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=${counterName}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


Verify Single Counter >0
    [Documentation]    [PRIVATE]   verify bts counter >0 and value from pm file
    ...     :Autor: Sylvia Schneider
    [Arguments]    ${counterName}    ${counterList}
    ${counter_text}        Set Variable    ${counterList}[0]
    ${counter_meastype}    Set Variable    ${counterList}[2]
    ${counter_distName}    Set Variable    PLMN-PLMN/${counterList}[1]

    ${xpath_param}    Get From Dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    ${xpath_param}    Replace Variables    ${xpath_param}
    ${counter_value_from_pm_xml}    Get Element Text     ${parsed_PmFile}        xpath=${xpath_param}
    ${result}       Set Variable If    ${counter_value_from_pm_xml} > ${0}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counterName} "${counter_text}" for bts
    ${msg2}         Set Variable      pm file value ${counter_value_from_pm_xml} > expectedValue 0\n
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=${counterName}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


Verify Counter Calculate M55125C09527
    [Documentation]    [PRIVATE]    verify counter M55125C09527
    ...       :Autor: Sylvia Schneider

    ${counterName}         Set Variable    M55125C09527
    ${counter_text}        Set Variable    ${${counterName}}[0]
    ${counter_distName}    Set Variable    PLMN-PLMN/${${counterName}}[1]
    ${counter_meastype}    Set Variable    ${${counterName}}[2]

    ${xpath_param}    Get From Dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    ${xpath_param}    Replace Variables    ${xpath_param}
    ${counter_value_from_pm_xml}    Get Element Text     ${parsed_PmFile}        xpath=${xpath_param}
    ${start}   Evaluate   ${duration}-1000
    ${end}     Evaluate   ${duration}+1000
    ${result}       Set Variable If    ${start} <= ${counter_value_from_pm_xml} <= ${end}    Passed    Failed
    ${msg1}         Set Variable       \ncounter ${counterName} "${counter_text}" for nrcell
    ${msg2}         Set Variable       ${start} <= pm file value ${counter_value_from_pm_xml} <= ${end}
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=M55125C09527
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}
    Set Test Variable    ${M55125C09527_value_pmFile}     ${counter_value_from_pm_xml}


Verify Counter Calculate M55125C09526
    [Documentation]    [PRIVATE]    verify counter M55125C09526
    ...       :Autor: Sylvia Schneider

    ${counterName}         Set Variable    M55125C09526
    ${counter_text}        Set Variable    ${${counterName}}[0]
    ${counter_distName}    Set Variable    PLMN-PLMN/${${counterName}}[1]
    ${counter_meastype}    Set Variable    ${${counterName}}[2]

    ${xpath_param}    Get From Dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    ${xpath_param}    Replace Variables      ${xpath_param}
    ${counter_value_from_pm_xml}    Get Element Text     ${parsed_PmFile}        xpath=${xpath_param}
    ${start}   Evaluate   ${duration}-1000
    ${end}     Evaluate   ${duration}+1000
    ${result}       Set Variable If    ${start} <= ${counter_value_from_pm_xml} <= ${end}    Passed    Failed
    ${msg1}         Set Variable       \ncounter ${counterName} "${counter_text}" for nrcell
    ${msg2}         Set Variable       ${start} <= pm file value ${counter_value_from_pm_xml} <= ${end}
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=M55125C09526
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}
    Set Test Variable    ${M55125C09526_value_pmFile}     ${counter_value_from_pm_xml}


Verify Counter Calculate M55125C09516 ${tc}
    [Documentation]    [PRIVATE]    verify counter M55125C09516
    ...       :Autor: Sylvia Schneider
    ${counterName}         Set Variable    M55125C09516
    ${counter_text}        Set Variable    ${${counterName}}[0]
    ${counter_distName}    Set Variable    PLMN-PLMN/${${counterName}}[1]
    ${counter_meastype}    Set Variable    ${${counterName}}[2]

    ${xpath_param}    Get From Dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    ${xpath_param}    Replace Variables      ${xpath_param}
    ${counter_value_from_pm_xml}    Get Element Text     ${parsed_PmFile}        xpath=${xpath_param}
   IF    '${tc}'=='t1'
            ${start}   Evaluate   ${M55125C09526_value_pmFile}*2
            ${end}     Evaluate   ${M55125C09526_value_pmFile}*2+1000
    ELSE
            ${start}   Evaluate   ${M55125C09527_value_pmFile}*2
            ${end}     Evaluate   ${M55125C09527_value_pmFile}*2+1000
    END
    ${result}      Set Variable If    ${start} <= ${counter_value_from_pm_xml} <= ${end}    Passed    Failed
    ${msg1}        Set Variable       \ncounter ${counterName} "${counter_text}" for nrcell
    ${msg2}        Set Variable       ${start} <= pm file value ${counter_value_from_pm_xml} <= ${end}
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=M55125C09516
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}
    Set Test Variable    ${M55125C09516_value_pmFile}     ${counter_value_from_pm_xml}


Verify Counter M55163C00521
    ${counterName}         Set Variable    M55163C00521
    ${counter_text}        Set Variable    ${${counterName}}[0]
    ${counter_distName}    Set Variable    PLMN-PLMN/${${counterName}}[1]
    ${counter_meastype}    Set Variable    ${${counterName}}[2]

    ${xpath_param}    Get From Dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    ${xpath_param}    Replace Variables    ${xpath_param}
    ${counter_value_from_pm_xml}    Get Element Text     ${parsed_PmFile}        xpath=${xpath_param}
    ${start}      Evaluate    ${M55125C09516_value_pmFile}-2
    ${end}        Evaluate    ${M55125C09516_value_pmFile}+2

    ${result}       Set Variable If    ${start} <= ${counter_value_from_pm_xml} <= ${end}    Passed    Failed
    ${msg1}         Set Variable       \ncounter ${counterName} "${counter_text}" for nrcell
    ${msg2}         Set Variable       ${start} <= pm file value ${counter_value_from_pm_xml} <= ${end}
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=${counterName}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


Verify Counter Calculate M55320C${id}
    [Documentation]    [PRIVATE]    verify counter M55320C19001 and M55320C19003
    ...       :Autor: Sylvia Schneider

    ${counterName}         Set Variable    M55320C${id}
    ${counter_text}        Set Variable    ${${counterName}}[0]
    ${counter_distName}    Set Variable    PLMN-PLMN/${${counterName}}[1]
    ${counter_meastype}    Set Variable    ${${counterName}}[2]

    ${xpath_param}    Get From Dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    ${xpath_param}    Replace Variables    ${xpath_param}
    ${counter_value_from_pm_xml}    Get Element Text     ${parsed_PmFile}        xpath=${xpath_param}

    ${exp_value}    Evaluate   ${duration}/1000*10*0.95
    ${result}       Set Variable If    ${exp_value} <= ${counter_value_from_pm_xml}    Passed    Failed
    ${msg1}         Set Variable       \ncounter ${counterName} "${counter_text}" for nrcell
    ${msg2}         Set Variable       ${exp_value} <= pm file value ${counter_value_from_pm_xml}
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=M55320C${id}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


Verify Counter forced-HO
    [Documentation]    [PRIVATE]    verify counter forced-HO
    ...       :Autor: Sylvia Schneider
    Upload And Filter Last Pm File
    Prepare Counters And Expected Values Force-HO
    Log To Console    \nVerify Measurement Profile counters
    FOR   ${counter_group}   IN
    ...   miaf
    ...   mief
    ...   mirf
    ...   masa
      verify counters of group ${counter_group}
    END

    ${file_string}   Get File   ${pm_file_name_with_path}
    ${file_string}  Replace String    ${file_string}  ><  >\n<   count=-1
    Create File    ${resultDir}/pm.xml    ${file_string}
    Set Test Variable    ${pmCounter_xml_file}    ${resultDir}/pm.xml

    Log To Console    \nVerify Inter-RAT handover counters
    ${parsed_PmFile}     Parse Xml    ${pmCounter_xml_file}
    Set Test Variable    ${parsed_PmFile}
    Log Dictionary       ${dict_pm_counter}
    @{dict_keys}         Get Dictionary Keys    ${dict_pm_counter}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_pm_counter}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_PmFile}
    END

    ${duration}    DateTime.Subtract Date From Date    ${time_stamp_after_bearer_stats}    ${time_stamp_before_HO}
    Set Test Variable    ${duration}
    Log To Console   time between handover start and bearer stat end is ${duration} milisecs
    FOR    ${counterName}      ${packet_rate}    IN
    ...    M55319C11001        10
    ...    M55319C15001        10
    ...    M55319C11005        100
    ...    M55319C15005        100
    ...    M55319C11006        500
    ...    M55319C15006        500
        Verify Counter Calculate t5     ${counterName}      ${packet_rate}
    END


Verify Counter forced-HO-TMO
    [Documentation]    [PRIVATE]    verify counter forced-HO-TMO
    ...       :Autor: Sylvia Schneider
    Upload And Filter Last Pm File
    Prepare Counters And Expected Values Force-HO TMO

    ${file_string}   Get File   ${pm_file_name_with_path}
    ${file_string}  Replace String    ${file_string}  ><  >\n<   count=-1
    Create File    ${resultDir}/pm.xml    ${file_string}
    Set Test Variable    ${pmCounter_xml_file}    ${resultDir}/pm.xml

    Log To Console    \nVerify Inter-RAT handover counters
    ${parsed_PmFile}     Parse Xml    ${pmCounter_xml_file}
    Set Test Variable    ${parsed_PmFile}
    Log Dictionary       ${dict_pm_counter}
    @{dict_keys}         Get Dictionary Keys    ${dict_pm_counter}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_pm_counter}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_PmFile}
    END


Upload And Filter Last Pm File
    [Documentation]    [PRIVATE]    Upload And Filter Last Pm File
    ...       :Autor: Sylvia Schneider
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

    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    Set Variable If    '${rc}'=='${0}'    pass    fail
    IF     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    Split To Lines    ${all_pm_file}
    ${pm_file_name}    Set Variable    ${temp[0]}
    ${pm_file_name_with_path}    Set Variable    ${resultDir}/${coam_pm_file_path}/${pm_file_name}
    Set Test Variable    ${pm_file_name_with_path}

    Move File    ${pm_file_name_with_path}    ${resultDir}/
    Empty Directory    ${resultDir}/${coam_pm_file_path}
    Move File    ${resultDir}/${pm_file_name}   ${resultDir}/${coam_pm_file_path}/

    ${pm_file}   Get File     ${pm_file_name_with_path}
    Set Test Variable    ${pm_file}


Verify Counters Of Group ${counter_group}
    [Documentation]    [PRIVATE]   verify counters belonging to same group
    ${counter_cell}    Set Variable    ${${counter_group}_counter}[0]
    ${counter_id}      Set Variable    ${${counter_group}_counter}[1]
    ${type}            Set Variable    ${${counter_group}_counter}[2]

    ${allCounter}    Get All Counters From Same Object And Type   ${counter_cell}    ${type}     ${counter_id}
    Verify Counters Of Same Group   ${counter_group}   ${allCounter}


Get All Counters From Same Object And Type
    [Documentation]    [PRIVATE]   get all counters from same object and type
    [Arguments]    ${counter_cell}    ${type}     ${counter_id}
    ${s1}  Set Variable   <DN>PLMN-PLMN/MRBTS-1/NRBTS-1/${counter_cell}</DN></MO><MO dimension="NR${type}">
    ${s2}  Set Variable   <DN>PLMN-PLMN/${counter_id}</DN></MO><NE-WBTS_1.0 measurementType="${type}">
    Log To Console    \nget all counters with ${s1}${s2}
    ${temp1}          Fetch From Right      ${pm_file}      ${s1}${s2}
    ${allCounter}     Fetch From Left       ${temp1}        </NE-WBTS_1.0>
    Log To Console    found "${allCounter}"
    RETURN    ${allCounter}


Verify Counters Of Same Group
    [Documentation]    [PRIVATE]   verify counters of same group
    ...     :Autor: Sylvia Schneider
    [Arguments]    ${counter_group}   ${allCounter}
    @{dict_keys}         Get Dictionary Keys    ${dict_${counter_group}_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_${counter_group}_counter}    ${counterKeyName}
        ${temp}   Split String   ${counterKeyName}    -
        ${counter}  Set Variable   ${temp}[0]
        Verify Single Counter 2 Dimension Objects   ${allCounter}   ${counter}    ${counterList}
    END


Verify Single Counter 2 Dimension Objects
    [Documentation]    [PRIVATE]   Verify single Counter 2 dimension objects
    ...     :Autor: Sylvia Schneider
    ...     :param ${counter}: name of counter e.g M55114C00001
    ...     :param ${counterList}: list containing details of counter
    [Arguments]    ${allCounter}   ${counter}    ${counterList}
    ${counter_text}    Set Variable    ${counterList}[0]
    ${counter_expectedValue}    Set Variable    ${counterList}[1]

    ${counter_value_from_pm}   Get Regexp Matches   ${allCounter}   <${counter}>(\\d+)</${counter}>   1
    ${counter_pm}  Set Variable   ${counter_value_from_pm}[0]
    ${result}       Set Variable If    ${counter_pm}==${counter_expectedValue}    Passed    Failed
    ${msg1}         Set Variable      counter ${counter} "${counter_text}"
    ${msg2}         Set Variable      pm file value ${counter_pm} == expectedValue ${counter_expectedValue}
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=${counter}
    ...   value=${counter_pm}
    ...   result=${result}
