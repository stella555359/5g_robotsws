*** Settings ***
Documentation
...    author: Cuicui Wang
...    contact: cuicui.wang@nokia-sbell.com
...    Purpose: This file is internal source file, wont suggest feature team use it.

Library  OperatingSystem
Library  String
Library  ./DevNJ_get_tl_configuration.py    WITH NAME    Get_TL_Configuration
Library  ./DevNJ_sbts_keywords.py


*** Variables ***

*** Keywords ***
Get GNB ASIR And Testline Info
    [Arguments]    ${subtype}

    ${local_dir}  Get_TL_Configuration.Get Full Commission Dir
    Set Suite Variable  ${local_dir}
    ${testline_name}  DevNJ_testline.Get TestLine Name
    Set Suite Variable  ${testline_name}
    ${commission_type_json_path}  ${testline_json_path}  Get_TL_Configuration.Get Configure Json File  ${local_dir}
    ${mrbtsId}  ${commission_type_number}  ${commission_sub_type}  ${testline_configuration_list}
    ...    Get_TL_Configuration.Get Testline Configuration Info From Testline Json File  ${testline_json_path}  ${testline_name}
    ${subtype}  Set Variable If  '${subtype}'=='null'     ${commission_sub_type}    ${subtype}
    ${testline_type}  Get_TL_Configuration.Get Testline Type From Commission Type Json  ${commission_type_json_path}   ${commission_type_number}
    ${gnb_commission_path}  ${asir_commission_path}  Get_TL_Configuration.Get Gnb And Asir Commission Path
    ...                     ${local_dir}  ${testline_name}  ${testline_type}  ${ENB_BUILD}  ${subtype}
    ${PARAMS_IN_SCF_TOTAL}    Combine Lists   ${PARAMS_IN_SCF}     ${testline_configuration_list}
    [Return]    ${mrbtsid}  ${PARAMS_IN_SCF_TOTAL}  ${gnb_commission_path}  ${asir_commission_path}

Get Change Swconfig Base On Release
    ${release}      Get Sbts Release Verison
    ${swconfig_path}    Get_TL_Configuration.Get Swconfig Template Path  ${local_dir}  ${release}
    Change Swconfig File    ${PARAMS_IN_SWCONFIG}    ${swconfig_path}

Get TestLine Name
    [Documentation]  Cuicui Wang: Get TestLine Name Via Get VM Hostname
    @{Special_String}   Create List  -  +   *
    ${output}    Run    'hostname'
#    Log    ${output}    console=True
    ${TestLine}   Convert To String    ${output}
    Should Not Be Empty  ${TestLine}
    FOR    ${item}     IN      @{Special_String}
        ${TestLine}     String.Replace String   ${TestLine}    ${item}    _
    END
    [Return]    ${TestLine}
