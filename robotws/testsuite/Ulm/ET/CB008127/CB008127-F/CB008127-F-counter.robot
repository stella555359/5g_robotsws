*** Settings ***
Documentation   This is a keyword file for CB008127-F, part counter
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


#Variables       CB008127-xpath-vars.yaml

*** Keywords ***


collect pm counter file
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



collect pm counter file and filter last 2 PM Counters file coam
    [Documentation]    [PRIVATE]   filter last 2 pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    collect pm counter file

    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    IF     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    split to lines    ${all_pm_file}
    set test variable    ${pm_file_name_2nd_with_path}    ${resultDir}/${coam_pm_file_path}/${temp[0]}
    set test variable    ${pm_file_name_1st_with_path}    ${resultDir}/${coam_pm_file_path}/${temp[1]}


Collect and Filter last PM Counters file coam
    [Documentation]    [PRIVATE]   Collect and Filter last PM Counters file coam
    ...     :Autor: Sylvia Schneider
    collect pm counter file

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


verify counter CB008127-F t1
    [Documentation]    [PRIVATE]   verify counter CB008127-F t1
    collect pm counter file and filter last 2 PM Counters file coam

    Log to console    \nVerify counters of 1st measurement period
    prepare counters and expected values 1st measurement period t1
    ${pm_file}   get file     ${pm_file_name_1st_with_path}
    set test variable   ${pm_file}
    FOR   ${counter_group}   IN
    ...   miaf1
    ...   miaf2
    ...   mief1
    ...   mief2
    ...   mirf1
    ...   mirf2
    ...   masa1
    ...   masa2
      verify counters of group ${counter_group}
    END

    Log to console    \nVerify counters of 2nd measurement period
    prepare counters and expected values 2nd measurement period t1
    ${pm_file}   get file     ${pm_file_name_2nd_with_path}
    set test variable   ${pm_file}
    FOR   ${counter_group}   IN
    ...   miaf1
    ...   miaf2
    ...   mief1
    ...   mief2
    ...   mirf1
    ...   masa1
    ...   masa2
      verify counters of group ${counter_group}
    END
#    Log to console    Verify PLMN-PLMN/NRMIRF-2 (M55189C00001) is not contained
#    run keyword and continue on failure
#    ...  should not contain   ${pm_file}   PLMN-PLMN/NRMIRF-2  msg=Error -- PLMN-PLMN/NRMIRF-2 found values=False


verify counter CB008127-F t2
    [Documentation]    [PRIVATE]   verify counter CB008127-F t2
    Collect and Filter last PM Counters file coam

    Log to console    \nVerify counters
    prepare counters and expected values t2
    FOR   ${counter_group}   IN
    ...   miaf1
    ...   miaf3
    ...   mief1
    ...   mief3
    ...   mirf1
    ...   mirf3
    ...   masa1
    ...   masa3
      verify counters of group ${counter_group}
    END


verify counter CB008127-F t3
    [Documentation]    [PRIVATE]   verify counter CB008127-F t3
    Collect and Filter last PM Counters file coam

    Log to console    \nVerify counters
    prepare counters and expected values t3
    FOR   ${counter_group}   IN
    ...   miaf4
    ...   masa4
      verify counters of group ${counter_group}
    END


verify counters of group ${counter_group}
    [Documentation]    [PRIVATE]   verify counters belonging to same group
    ${counter_cell}    Set Variable    ${${counter_group}_counter}[0]
    ${counter_id}      Set Variable    ${${counter_group}_counter}[1]
    ${type}            Set Variable    ${${counter_group}_counter}[2]

    ${allCounter}    get all counters from same object and type   ${counter_cell}    ${type}     ${counter_id}
    verify counters of same group   ${counter_group}   ${allCounter}


get all counters from same object and type
    [Documentation]    [PRIVATE]   get all counters from same object and type
    [Arguments]    ${counter_cell}    ${type}     ${counter_id}
    ${s1}  set variable   <DN>PLMN-PLMN/MRBTS-1/NRBTS-1/${counter_cell}</DN></MO><MO dimension="NR${type}">
    ${s2}  set variable   <DN>PLMN-PLMN/${counter_id}</DN></MO><NE-WBTS_1.0 measurementType="${type}">
    Log to console    \nget all counters with ${s1}${s2}
    ${temp1}         Fetch from right      ${pm_file}      ${s1}${s2}
    ${allCounter}    Fetch from left       ${temp1}        </NE-WBTS_1.0>
    Log to console    found "${allCounter}"
    RETURN    ${allCounter}


verify counters of same group
    [Documentation]    [PRIVATE]   verify counters of same group
    ...     :Autor: Sylvia Schneider
    [Arguments]    ${counter_group}   ${allCounter}
    @{dict_keys}         Get Dictionary Keys    ${dict_${counter_group}_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_${counter_group}_counter}    ${counterKeyName}
        ${temp}   split string   ${counterKeyName}    -
        ${counter}  set variable   ${temp}[0]
        Verify single Counter 2 dimension objects   ${allCounter}   ${counter}    ${counterList}
    END


Verify single Counter 2 dimension objects
    [Documentation]    [PRIVATE]   Verify single Counter 2 dimension objects
    ...     :Autor: Sylvia Schneider
    ...     :param ${counter}: name of counter e.g M55114C00001
    ...     :param ${counterList}: list containing details of counter
    [Arguments]    ${allCounter}   ${counter}    ${counterList}
    ${counter_text}    Set Variable    ${counterList}[0]
    ${counter_expectedValue}    Set Variable    ${counterList}[1]

    ${counter_value_from_pm}   get regexp matches   ${allCounter}   <${counter}>(\\d+)</${counter}>   1
    ${counter_pm}  set variable   ${counter_value_from_pm}[0]
    ${result}       Set Variable If    ${counter_pm}==${counter_expectedValue}    Passed    Failed
    ${msg1}         Set Variable      counter ${counter} "${counter_text}"
    ${msg2}         Set Variable      pm file value ${counter_pm} == expectedValue ${counter_expectedValue}
    IF    '${result}'=='Passed'    Log to console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    report pm counter
    ...   id=${counter}
    ...   value=${counter_pm}
    ...   result=${result}
