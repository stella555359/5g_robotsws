*** Settings ***
Documentation
...  ** Common Useful keyword **
*** Keywords ***
Save Current SCF Plan
    [Documentation]    Saves the current SCF after delta plan application.
    [Arguments]    ${local_dir}    ${test_plan}
    Log    Saving current SCF plan to ${local_dir}
    # Add actual saving commands here
    ${plan_name}    Split Path    ${test_plan}
    ${path_to_scf}    gnbbbu.get_bts_configuration_file   local_dir=${local_dir}    filename=${plan_name[-1]}_scf.xml
    Log    SCF plan saved to ${path_to_scf}
    [Return]    ${path_to_scf}

Get Online NRCELL Count
    [Arguments]    ${bts_info}
    [Documentation]    Gets the count of online NRCELLs
    ${nrcell_infos}    utilities.Get Online Cells Info    ${bts_info}    rantype=nr
    Log    ${nrcell_infos}
    ${online_count}    Get Length    ${nrcell_infos}
    [Return]    ${online_count}

Get Configured NRCELL Count
    [Arguments]    ${bts_info}
    [Documentation]    Gets the count of configured NRCELLs
    ${nrcell_infos}    utilities.Get Configured Cells Info    ${bts_info}    rantype=nr
    Log    ${nrcell_infos}
    ${configured_count}    Get Length    ${nrcell_infos}
    [Return]    ${configured_count}

Get SBTS SW Build
    [Documentation]    Gets the SBTS SW build
    ${bts_info}  gnbbbu.get_bts_info
    ${SBTS_BUILD}  Set Variable    ${bts_info['swInfo']['swVersion']}
    [Return]    ${SBTS_BUILD}

Get SBTS SW Branch
    [Documentation]    Gets the SBTS SW branch
    [Arguments]    ${SBTS_BUILD}
    ${SBTS_BRANCH}  String.Split String    ${SBTS_BUILD}    _    1
    [Return]    ${SBTS_BRANCH[0]}
