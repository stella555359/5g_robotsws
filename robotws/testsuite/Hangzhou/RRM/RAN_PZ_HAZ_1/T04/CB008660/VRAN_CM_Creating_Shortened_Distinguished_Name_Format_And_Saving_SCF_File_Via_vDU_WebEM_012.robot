*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for [1][6.0] Creating Shortened Distinguished Name (SDN) format and saving SCF file via vDU WebEM
...   unambiguity to the live NE
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
&{plan_info_8660_012}      scf_distName=MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRDU-1
...    parameter_name=targetDN    shortenedDN=APEQM-1    fullDN=MRBTS-${vDU_id}/EQM-1/APEQM-1

*** Keywords ***
TC__VRAN_CM_Creating_Shortened_Distinguished_Name_Format_And_Saving_SCF_File_Via_vDU_WebEM_012
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    13.02.2023, lixin.kang@nokia-sbell.com, draft
    ...    06.01.2025, lixin.kang@nokia-sbell.com, update for CB012840
    Step 1: TC Parameters Check
    Step 2: Activate Delta Plan With ${plan_info['shortenedDN']} And Check Site OnAir
    Step 3: Save Plan And Check ${plan_info['shortenedDN']}
    Step 4: Activate Delta Plan With ${plan_info['fullDN']} And Check Site OnAir
    Step 5: Save Plan And Check ${plan_info['fullDN']}

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}
    vDU Login By Rest

Case Postcondition
    Log To Console    Case Postcondition
    vDU Logout By Rest
    Common Test Teardown For AIC

Step ${index}: TC Parameters Check
    Log    Step ${index}: TC Parameters Check    console=True
    ${ne_dn}    Set Variable   MRBTS-${vDU_id}
    Set Test Variable    ${ne_dn}
    Set Test Variable    ${plan_info}    ${plan_info_8660_012}
    @{param_list}    Create List    ${plan_info['parameter_name']}
    @{param_value_list}    Create List    ${plan_info['shortenedDN']}
    @{param_value_list_origin}    Create List    ${plan_info['fullDN']}
    @{mo_list}    Create List    ${plan_info['scf_distName']}
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{param_list}    mo_list=@{mo_list}
    ${current_value}    Set Variable    ${out["${mo_list[0]}"]["${param_list[0]}"]}
    Run Keyword If    '${current_value}'=='${plan_info['shortenedDN']}'    Fail
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!
    ...    ELSE    Log    TC parameters successfully checked    console=True

Step ${index}: Activate Delta Plan With ${Expected_DN} And Check Site OnAir
    Log    Step ${index}: Activate New Delta Plan And Check Site Status    console=True
    @{param_list}    Create List    ${plan_info['parameter_name']}
    @{param_value_list}    Create List    ${Expected_DN}
    @{mo_list}    Create List    ${plan_info['scf_distName']}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{param_list}    mo_list=@{mo_list}    value_list=@{param_value_list}
    vDU Check All Cells Status Should Be Onair

Step ${index}: Save Plan And Check ${Expected_DN}
    Log    Step ${index}: Save Plan And Check SDN    console=True
    vDU Login By Rest
    ${saved_scf}    vdu.get_current_plan_file    local_dir_path=${TEST_LOG_DIRECTORY}    filename=scf_with_sdn.xml
    ...    include_runtime_data=${False}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/scf_with_sdn.xml
    ${status}    ${value}    Run Keyword And Ignore Error    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${plan_info['scf_distName']}"]/p[@name="${plan_info['parameter_name']}"]
    ${actual_value}   Set Variable If   '${status}'=='PASS'    ${value}    ${EMPTY}
    Should Be Equal    ${actual_value}    ${Expected_DN}