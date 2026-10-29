*** Settings ***
Documentation   This is a keyword file for CB008127, part counter
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


Variables       CB008127-xpath-vars.yaml

*** Keywords ***



Collect And Filter Last PM Counters File Coam 8127
    [Documentation]    [PRIVATE]   Collect and Filter last PM Counters file coam 8127
    ...     :Autor: Sylvia Schneider

    Log To Console    \nuploading pm file from coam
    ${webservice}    Create Dictionary
    ...            host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            port=443

    tafpmcounters.Create Pm Collector
    ...    name=gnb_pm_counters
    ...    webservice=${webservice}
    tafpmcounters.Setup Collectors
    ...    names=gnb_pm_counters
    tafpmcounters.Collect Collectors
    ...    names=gnb_pm_counters
    ...    target_dir=${resultDir}
    tafpmcounters.Teardown Collectors
    ...    names=gnb_pm_counters

    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    Set Variable If    '${rc}'=='${0}'    pass    fail
    IF     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    Split To Lines    ${all_pm_file}
    ${pm_file_name}    Set Variable    ${temp[0]}
    ${pm_file_name_with_path}    Set Variable    ${resultDir}/${coam_pm_file_path}/${pm_file_name}

    Move File    ${pm_file_name_with_path}    ${resultDir}/
    Empty Directory    ${resultDir}/${coam_pm_file_path}
    Move File    ${resultDir}/${pm_file_name}   ${resultDir}/${coam_pm_file_path}/

    ${pm_file}   Get File     ${pm_file_name_with_path}
    Set Test Variable    ${pm_file}


Verify Counter CB008127
    [Documentation]    [PRIVATE]   verify counter for testcases
    ...     :Autor: Sylvia Schneider
    Collect And Filter Last PM Counters File Coam 8127
    @{dict_keys}         Get Dictionary Keys    ${dict_miaf_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_miaf_counter}    ${counterKeyName}
        ${temp}   Split String   ${counterKeyName}    -
        ${counter}  Set Variable   ${temp}[0]
        Verify Counter 2 Dimension Objects    ${counter}    ${counterList}
    END
    @{dict_keys}         Get Dictionary Keys    ${dict_masa_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_masa_counter}    ${counterKeyName}
        ${temp}   Split String   ${counterKeyName}    -
        ${counter}  Set Variable   ${temp}[0]
        Verify Counter 2 Dimension Objects    ${counter}    ${counterList}
    END


Verify Counter 2 Dimension Objects
    [Documentation]    [PRIVATE]   verify counter expected value and value from pm file
    ...     :Autor: Sylvia Schneider
    ...     :param ${counter}: name of counter e.g M55114C00001
    ...     :param ${counterList}: list containing details of counter
    [Arguments]    ${counter}    ${counterList}
    ${counter_text}    Set Variable    ${counterList}[0]
    ${counter_expectedValue}    Set Variable    ${counterList}[1]
    ${counter_cell}    Set Variable    ${counterList}[2]
    ${counter_distName}    Set Variable   MRBTS-1/NRBTS-1/${counter_cell}
    ${counter_id}    Set Variable    ${counterList}[3]
    ${type}              Set Variable    ${counterList}[4]

    ${counter_search}    Get From Dictionary    ${xpath_vars_8127}    counter_8127
    ${counter_search}    Replace Variables    ${counter_search}

    ${string_found}  Get Regexp Matches   ${pm_file}   ${counter_search}  1
    ${values_found}  Get Length   ${string_found}
    ${result}       Set Variable If    ${values_found}==1    Passed    Failed
    ${counter_value_from_pm_xml}   Set Variable   ${string_found}[0]
    IF    '${result}'=='Failed'    Fail    counter not found "${counter}", ${counter_cell}, ${counter_id}

    ${result}       Set Variable If    ${counter_value_from_pm_xml}==${counter_expectedValue}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counter} "${counter_text}" for cell ${counter_cell} and ${counter_id}
    ${msg2}         Set Variable      pm file value ${counter_value_from_pm_xml} == expectedValue ${counter_expectedValue}\n
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=${counter}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


Verify Counter CB008127 NRMIRF
    [Documentation]    [PRIVATE]   verify counter for testcases
    ...     :Autor: Sylvia Schneider
    @{dict_keys}         Get Dictionary Keys    ${dict_mirf_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_mirf_counter}    ${counterKeyName}
        ${temp}   Split String   ${counterKeyName}    -
        ${counter}  Set Variable   ${temp}[0]
        Verify Counter 2 Dimension Objects    ${counter}    ${counterList}
    END


Verify Counter CB008127 T21
    [Documentation]    [PRIVATE]   verify counter CB008127 t21
    ...     :Autor: Sylvia Schneider
    Collect And Filter Last PM Counters File Coam 8127
    FOR   ${counter_group}   IN
    ...   miaf_cell1
    ...   masa_cell1
    ...   miaf_cell2
    ...   masa_cell2
      Verify Counters Of Group ${counter_group}
    END


Verify 2 Counter Same Group
    [Documentation]    [PRIVATE]   verify 2 counter same group
    ...     :Autor: Sylvia Schneider
    [Arguments]    &{counter_dict}
    @{dict_keys}         Get Dictionary Keys    ${counter_dict}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${counter_dict}    ${counterKeyName}
        ${temp}   Split String   ${counterKeyName}    -
        ${counter}  Set Variable   ${temp}[0]
        Verify 2 Counter 2 Dimension Objects   ${counter}    ${counterList}
    END


Verify 2 Counter 2 Dimension Objects
    [Documentation]    [PRIVATE]   Verify 2 Counter 2 dimension objects
    ...     :Autor: Sylvia Schneider
    ...     :param ${counter}: name of counter e.g M55114C00001
    ...     :param ${counterList}: list containing details of counter
    [Arguments]    ${counter}    ${counterList}
    ${counter_text}    Set Variable    ${counterList}[0]
    ${counter_expectedValue}    Set Variable    ${counterList}[1]
    ${counter_cell}    Set Variable    ${counterList}[2]
    ${counter_distName}    Set Variable   MRBTS-1/NRBTS-1/${counter_cell}
    ${counter_id}    Set Variable    ${counterList}[3]
    ${type}              Set Variable    ${counterList}[4]

    ${s1}  Set Variable   <DN>PLMN-PLMN/MRBTS-1/NRBTS-1/${counter_cell}</DN></MO><MO dimension="NR${type}">
    ${s2}  Set Variable   <DN>PLMN-PLMN/${counter_id}</DN></MO><NE-WBTS_1.0 measurementType="${type}">
    ${temp1}         Fetch From Right      ${pm_file}      ${s1}${s2}
    ${allCounter}    Fetch From Left       ${temp1}        </NE-WBTS_1.0>

    ${counter_value_from_pm}   Get Regexp Matches   ${allCounter}   <${counter}>(\\d+)</${counter}>   1
    ${counter_pm}  Set Variable   ${counter_value_from_pm}[0]
    ${result}       Set Variable If    ${counter_pm}==${counter_expectedValue}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counter} "${counter_text}" for ${counter_cell} and ${counter_id}
    ${msg2}         Set Variable      pm file value ${counter_pm} == expectedValue ${counter_expectedValue}\n
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    Report Pm Counter
    ...   id=${counter}
    ...   value=${counter_pm}
    ...   result=${result}


Verify Counter CB008127 T17
    [Documentation]    [PRIVATE]   verify counter CB008127 t17
    Collect And Filter Last PM Counters File Coam 8127

    FOR   ${counter_group}   IN
    ...   miaf6
    ...   mief1
    ...   masa5
    ...   masa6
      Verify Counters Of Group ${counter_group}
    END


Verify Counter CB008127 T19
    [Documentation]    [PRIVATE]   verify counter CB008127 t19
    Collect And Filter Last PM Counters File Coam 8127

    FOR   ${counter_group}   IN
    ...   miaf6
    ...   mief1
    ...   mirf6
    ...   masa5
    ...   masa6
      Verify Counters Of Group ${counter_group}
    END


Verify Counter CB008127 T23
    [Documentation]    [PRIVATE]   verify counter CB008127 t23
    Collect And Filter Last PM Counters File Coam 8127

    FOR   ${counter_group}   IN
    ...   miaf3
    ...   miaf4
    ...   mief1
    ...   mief2
    ...   mirf3
    ...   mirf4
    ...   masa3
    ...   masa4
      Verify Counters Of Group ${counter_group}
    END


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
    ${temp1}         Fetch From Right      ${pm_file}      ${s1}${s2}
    ${allCounter}    Fetch From Left       ${temp1}        </NE-WBTS_1.0>
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
