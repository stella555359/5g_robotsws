*** Settings ***
Documentation   This is a keyword file for CB008127-G, part counter
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------


Variables       CB008127-G-xpath-vars.yaml

*** Keywords ***



Collect and Filter last PM Counters file coam 8127
    [Documentation]    [PRIVATE]   Collect and Filter last PM Counters file coam 8127
    ...     :Autor: Shruthi Shivaprasad

    Log To Console    \nuploading pm file from coam
    ${webservice}    Create Dictionary
    ...            host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            port=443

    tafpmcounters.create pm collector
    ...    name=gnb_pm_counters
    ...    webservice=${webservice}
    ...    oam_type=sbts
    tafpmcounters.setup collectors
    ...    names=gnb_pm_counters
    tafpmcounters.collect collectors
    ...    names=gnb_pm_counters
    ...    target_dir=${resultDir}
    tafpmcounters.teardown collectors
    ...    names=gnb_pm_counters

    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    IF     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    split to lines    ${all_pm_file}
    ${pm_file_name}    set variable    ${temp[0]}
    ${pm_file_name_with_path}    set variable    ${resultDir}/${coam_pm_file_path}/${pm_file_name}

    Move File    ${pm_file_name_with_path}    ${resultDir}/
    Empty Directory    ${resultDir}/${coam_pm_file_path}
    Move File    ${resultDir}/${pm_file_name}   ${resultDir}/${coam_pm_file_path}/

    ${pm_file}   get file     ${pm_file_name_with_path}
    Set Test Variable    ${pm_file}


verify counter CB008127-G
    [Documentation]    [PRIVATE]   verify counter for testcases
    ...     :Autor: Shruthi Shivaprasad
    Collect and Filter last PM Counters file coam 8127
    @{dict_keys}         Get Dictionary Keys    ${dict_miaf_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_miaf_counter}    ${counterKeyName}
        ${temp}   split string   ${counterKeyName}    -
        ${counter}  set variable   ${temp}[0]
        Verify Counter 2 dimension objects    ${counter}    ${counterList}
    END
    @{dict_keys}         Get Dictionary Keys    ${dict_mnsa_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_mnsa_counter}    ${counterKeyName}
        ${temp}   split string   ${counterKeyName}    -
        ${counter}  set variable   ${temp}[0]
        Verify Counter 2 dimension objects    ${counter}    ${counterList}
    END
    @{dict_keys}         Get Dictionary Keys    ${dict_mief_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_mief_counter}    ${counterKeyName}
        ${temp}   split string   ${counterKeyName}    -
        ${counter}  set variable   ${temp}[0]
        Verify Counter 2 dimension objects    ${counter}    ${counterList}
    END


verify counter CB008127-G t4
    [Documentation]    [PRIVATE]   verify counter for testcases
    ...     :Autor: Shruthi Shivaprasad
    Collect and Filter last PM Counters file coam 8127
    @{dict_keys}         Get Dictionary Keys    ${dict_miaf_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_miaf_counter}    ${counterKeyName}
        ${temp}   split string   ${counterKeyName}    -
        ${counter}  set variable   ${temp}[0]
        Verify Counter 2 dimension objects    ${counter}    ${counterList}
    END
    @{dict_keys}         Get Dictionary Keys    ${dict_mnsa_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_mnsa_counter}    ${counterKeyName}
        ${temp}   split string   ${counterKeyName}    -
        ${counter}  set variable   ${temp}[0]
        Verify Counter 2 dimension objects    ${counter}    ${counterList}
    END
        @{dict_keys}         Get Dictionary Keys    ${dict_mief_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_mief_counter}    ${counterKeyName}
        ${temp}   split string   ${counterKeyName}    -
        ${counter}  set variable   ${temp}[0]
        Verify Counter 2 dimension objects    ${counter}    ${counterList}
    END



Verify Counter 2 dimension objects
    [Documentation]    [PRIVATE]   verify counter expected value and value from pm file
    ...     :Autor: Shruthi Shivaprasad
    ...     :param ${counter}: name of counter e.g M55114C00001
    ...     :param ${counterList}: list containing details of counter
    [Arguments]    ${counter}    ${counterList}
    ${counter_text}    Set Variable    ${counterList}[0]
    ${counter_expectedValue}    Set Variable    ${counterList}[1]
    ${counter_cell}    Set Variable    ${counterList}[2]
    ${counter_distName}    Set Variable   MRBTS-1/NRBTS-1/${counter_cell}
    ${counter_id}    Set Variable    ${counterList}[3]
    ${type}              Set Variable    ${counterList}[4]

    ${counter_search}    get from dictionary    ${xpath_vars_8127}    counter_8127
    ${counter_search}    replace variables    ${counter_search}

    ${string_found}  get regexp matches   ${pm_file}   ${counter_search}  1
    ${values_found}  get length   ${string_found}
    ${result}       Set Variable If    ${values_found}==1    Passed    Failed
    ${counter_value_from_pm_xml}   set variable   ${string_found}[0]
    IF    '${result}'=='Failed'    Fail    counter not found "${counter}", ${counter_cell}, ${counter_id}

    ${result}       Set Variable If    ${counter_value_from_pm_xml}==${counter_expectedValue}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counter} "${counter_text}" for cell ${counter_cell} and ${counter_id}
    ${msg2}         Set Variable      pm file value ${counter_value_from_pm_xml} == expectedValue ${counter_expectedValue}\n
    IF    '${result}'=='Passed'    Log to console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    report pm counter
    ...   id=${counter}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


verify counter CB008127 NRMIRF
    [Documentation]    [PRIVATE]   verify counter for testcases
    ...     :Autor: Shruthi Shivaprasad
    @{dict_keys}         Get Dictionary Keys    ${dict_mirf_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_mirf_counter}    ${counterKeyName}
        ${temp}   split string   ${counterKeyName}    -
        ${counter}  set variable   ${temp}[0]
        Verify Counter 2 dimension objects    ${counter}    ${counterList}
    END
