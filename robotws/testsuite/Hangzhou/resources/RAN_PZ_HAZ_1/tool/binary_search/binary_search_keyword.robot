*** Settings ***
Documentation    Suite description
...    Author:        xingxin.lou@nokia-sbell.com
...    Maintainer:    Lou Xingxin

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library      ./binary_search.py
Library      ./sw_download.py

*** Variables ***
${SW_BUILDS_DIR_PATH}    /home/ute/Downloads/cloud
${MAX_CUT_COUNT}    10

*** Keywords ***
Binary Search
    [Arguments]    ${run_case}   &{arg}
    ${init_passed_build_id}  Get Build Id  ${pass_build}
    ${init_failed_build_id}  Get Build Id  ${fail_build}
    ${search_fisrt}  Search First Or Last Failed Build  ${init_passed_build_id}  ${init_failed_build_id}
    ${start_id}  Set Variable If  ${search_fisrt}  ${init_passed_build_id}  ${init_failed_build_id}
    ${end_id}  Set Variable If  ${search_fisrt}  ${init_failed_build_id}  ${init_passed_build_id}
    ${sort}  Set Variable If  ${search_fisrt}   DESC   ASC
    ${branch}  Get Branch  ${pass_build}   ${fail_build}
    ${build_collection}    Retrieve All Collection By Id  ${branch}   ${start_id}    ${end_id}   ${sort}
    ${failed_list}   Create List
    ${passed_list}   Create List
    FOR   ${count}    IN RANGE   ${max_cut_count}
         ${build_info}   Get Middle Build    ${build_collection}
         Update Sw To TargetBuild       ${build_info['version']}   ${package_type}   download_timeout=4800
          Log To Console  Begain to run ${run_case} ......
         ${case_result}  Run Keyword And Return Status  ${run_case}   &{arg}
         ${pass_message}   Evaluate  "\\033[22;32m PASS \\033[0m"
         ${fail_message}   Evaluate  "\\033[22;31m FAIL \\033[0m"
         Run Keyword If  ${case_result}  Log To Console  ${build_info['version']} ${pass_message}
         ...    ELSE  Log To Console  ${build_info['version']} ${fail_message}
         Run Keyword If  ${case_result}==False   Append To List   ${failed_list}   ${build_info}
         ...    ELSE   Append To List   ${passed_list}   ${build_info}
         ${collection_length}    Get Length   ${build_collection}
         Exit For Loop If    '${collection_length}'=='1'
         ${half_items}    Get Half Items    ${build_collection}    ${case_result}
         Set Test Variable    ${build_collection}    ${half_items}
    END
    ${first_failed_build}   Get Target Failed Build   ${failed_list}
    ${last_passed_build}   Get Target Passed Build   ${passed_list}

Get Branch
    [Arguments]   ${pass_build}   ${fail_build}
    ${pass_branch}    Split String    ${pass_build}    _
    ${fail_branch}    Split String    ${fail_build}    _
    Return From Keyword If   "${pass_branch[0]}"=="${fail_branch[0]}"    ${pass_branch[0]}
    Log To Console  Branch inconsistency!

Search First Or Last Failed Build
    [Arguments]  ${init_passed_build_id}  ${init_failed_build_id}
    ${search_fisrt}  Set Variable If  ${init_passed_build_id}<${init_failed_build_id}  True  False
    Run Keyword If  ${search_fisrt}  Log To Console  Ready to search first failed build......
    ...    ELSE   Log To Console  Ready to search latest failed build......
    [Return]  ${search_fisrt}

Update Sw To TargetBuild
    [Arguments]    ${target_builds}    ${package_type}   ${download_timeout}=4800
    ${connection}  coam.setup_admin  name=update_sw
    Run Keyword And Ignore Error  OperatingSystem.Create Directory    ${SW_BUILDS_DIR_PATH}
    Log To Console  Downloading ${target_builds}
    sw_download.sw_download   ${target_builds}  target_dir=${SW_BUILDS_DIR_PATH}   package_type=${package_type}  timeout=${download_timeout}
    coam.wait_sw_update_possible    connection=${connection}
    ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
    ${matched_file}    Get Matches   ${files}    ${target_builds}*
    Log To Console  Updating to ${target_builds}
    Wait Until Keyword Succeeds    20 min    30 sec    coam.Update Software
    ...    ${SW_BUILDS_DIR_PATH}/${matched_file[0]}    timeout=3600    connection=${connection}
    sleep  5min
    Empty Directory    ${SW_BUILDS_DIR_PATH}
    [Teardown]   coam.teardown_admin   connection=${connection}
