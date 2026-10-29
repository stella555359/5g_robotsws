*** Settings ***
Documentation
...               Pm Counters Management

Library    Python/getpmc.py
Library    Python/tools.py
Library    Collections
Library    logging

Resource   Log/collectionpm.robot

*** Keywords ***


# NEW update
Get Latest PM File From BTS Without Collecting
    [Arguments]   ${pm_files_path}
    [Documentation]    Returns Latest PM File From BTS Without Collecting
    ${latest_pm_file}=   tools.get_latest_pm_file   ${pm_files_path}
    [Return]   ${latest_pm_file}

# NEW latest values
Extract Counter Latest Value From a PM File
    [Arguments]   ${pm_file}  ${object_name}  ${counter_id}
    [Documentation]    Get Counter Latest Value From a PM File
    ${counter_value}=   getpmc.fetch_from_file_counter_latest_values_by_object
    ...                 ${pm_file}   ${object_name}  ${counter_id}
    Run keyword if  '${counter_value}' == '${EMPTY}'  Fail      KW: No value found for ${counter_id} in ${pm_file}
    [Return]  ${counter_value}


Extract Counter Different Values From PM Files in dir
    [Arguments]   ${pm_dir}    ${object_name}     ${counter_name}      ${object_id}
    [Documentation]   Get Counter Different Values From a PM File dir
    @{counter_values}=   getpmc.get_counter_values_from_dir
    ...                 pi_dir=${pm_dir}    object_name=${object_name}     counter_name=${counter_name}     object_id=${object_id}
    BuiltIn.log                     list_in_pm_robot @{counter_values}
    Run keyword if  @{counter_values} == @{EMPTY}  BuiltIn.log      KW: No value found for ${counter_name} in ${pm_dir}
    [Return]  @{counter_values}

Extract Latest PM File From BTS
    [Arguments]   ${pm_files_path}
    [Documentation]    Get Latest PM File From BTS
    ${latest_pm_file}    Set variable    ${EMPTY}
    Collect pm with path   ${pm_files_path}
    ${latest_pm_file}=   tools.get_latest_pm_file   ${pm_files_path}
    Run keyword if  '${latest_pm_file}' == '${EMPTY}'  Collect Result Not Expected      ${pm_files_path}
    [Return]   ${latest_pm_file}


# internal usage
Compare with Expected Value
    [Arguments]    ${comparison}    ${expected_val}     ${val}
    ${compare_result}=    Set Variable    ${False}
    ${iVal}=    evaluate      ${val}
    ${iExpected}=    evaluate      ${expected_val}
    ${compare_result1}=   Evaluate     ${iVal} >= ${iExpected}
    ${compare_result2}=   Evaluate     ${iVal} > ${iExpected}
    ${compare_result3}=   Evaluate     ${iVal} <= ${iExpected}
    ${compare_result4}=   Evaluate     ${iVal} < ${iExpected}
    ${compare_result5}=   Evaluate     ${iVal} == ${iExpected}
    ${compare_result}=      Run Keyword if      ${comparison}=='>='
    ...                         Set Variable    ${compare_result1}
    ...                     ELSE IF        ${comparison}=='>'
    ...                         Set Variable    ${compare_result2}
    ...                     ELSE IF        ${comparison}=='<='
    ...                         Set Variable    ${compare_result3}
    ...                     ELSE IF        ${comparison}=='<'
    ...                         Set Variable    ${compare_result4}
    ...                     ELSE IF        ${comparison}=='=='
    ...                         Set Variable    ${compare_result5}
    ...                     ELSE
    ...                         Set Variable    ${False}
    Debug Dated Log  FINAL_compare_result=${compare_result}
    [Return]    ${compare_result}

Collect Result Not Expected
    [Arguments]   ${pm_path}
    [Documentation]   Collect Result Not Expected
    ${res}    run    ls -R ${pm_path}
    BuiltIn.log     Content of collect directory : ${res}
    log to console     Content of collect directory ${res}
    Fail        No PM xml found after collection
