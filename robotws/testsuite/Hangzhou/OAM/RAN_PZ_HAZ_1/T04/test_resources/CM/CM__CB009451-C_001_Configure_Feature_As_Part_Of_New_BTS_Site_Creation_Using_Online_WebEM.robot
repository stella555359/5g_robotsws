*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot
Library           ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/FCT_Excel.py

*** Variables ***
${desired_fct_feature}    PDCCH
${default_plan_name}    CURRENT_BTS_CONF-1
${expected_fct_file_name}    FCT_PDCCH_MultiRelease.xlsx
${NEED_RECOVERY}    False

*** Keywords ***
CM__CB009451-C_001_Configure_Feature_As_Part_Of_New_BTS_Site_Creation_Using_Online_WebEM
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   New case for TA_RAN_ST_CB009451-C_001_CM_Configure feature as part of new BTS site creation using online WebEM
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.08.2023 - New Case

    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    Author-lixin.kang@nokia-sbell.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Download And Install FCE
    Step 2: Select Desired FCT From Droplist
    Step 3: Check Actual Full Configuration Selected As Default
    Step 4: Select Objects And Define Additional Params
    Step 5: Start Calculate And Check Results
    Step 6: Apply All Inputs Into Current Plan
    Step 7: Provision Plan And Check Site Status
    Step 8: Check Additional Param In Actual Plan

Step ${index}: Download And Install FCE
    Log    Step ${index}: Download FCE Package For Current BTS Version    console=True
    ${fce_worker_name}    ${fct_file_name}    Download FCE Modules For Current SW
    ${win_index}    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}
    Install FCE From WebEM CA    ${Test Results Dir}/TestFiles/${fce_worker_name}
    ${list_FCE_features}    Get Feature List From WebEM CA
    Should Not Be Empty    ${list_FCE_features}
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output
    ...    unzip ${Test Results Dir}/TestFiles/${fct_file_name} -d ${Test Results Dir}/TestFiles
    Should Be Equal As Integers    ${rc}    ${0}
    OperatingSystem.File Should Exist    ${Test Results Dir}/TestFiles/${expected_fct_file_name}
    ${expected_feature_name}    Set Variable
    FOR    ${fea}    IN    @{list_FCE_features}
        ${status}    Run Keyword And Return Status    Should Contain    ${fea}    ${desired_fct_feature}
        Run Keyword If    ${status}    Run Keywords    Set Test Variable    ${expected_feature_name}    ${fea}
        ...    AND    Return From Keyword
    END
    Should Not Be Empty    ${expected_feature_name}    No ${desired_fct_feature}FCT installed on site!
    Set Test Variable    ${expected_feature_name}

Step ${index}: Select Desired FCT From Droplist
    Log    Step ${index}: Select Desired FCT From Droplist    console=True
    ${fce_list_objects}    SBTS WEM Select Feature On CA    ${expected_feature_name}
    Set Test Variable    ${fce_list_objects}

Step ${index}: Check Actual Full Configuration Selected As Default
    Log    Step ${index}: Check Actual Full Configuration Selected As Default   console=True
    ${list_plan}    ${current_plan}    Get Plan Options From WebEM CA
    Should Be Equal As Strings    ${current_plan}    ${default_plan_name}
    SBTS WEM Select Plan On CA    ${default_plan_name}

Step ${index}: Select Objects And Define Additional Params
    Log    Step ${index}: Select Objects And Define Additional Params   console=True
    ${obj}    Evaluate    random.choice(${fce_list_objects})    modules=random, sys
    ${selected_object_instance}    ${dic_init_param_value}     SBTS WEM Select Object On CA   ${obj}
    ${sub_obj_list}    ${dic_all_param_value}    Get All Additional Param Value And Object Instance    ${obj}
    ${selected_obj_list}    Split String    ${selected_object_instance}    ,${SPACE}
    # validate selected sub objects match the objects in current plan
    Lists Should Be Equal    ${sub_obj_list}    ${nrcell_name_list}    ignore_order=True
    Lists Should Be Equal    ${selected_obj_list}    ${sub_obj_list}    ignore_order=True
    # validate default add param value
    ${addition_param}    FCT_Excel.get_default_value_ADDIN    ${Test Results Dir}/TestFiles/${expected_fct_file_name}  PARAMETER-METADATA
    ${addition_param_abbreviation_mapping}    Create Dictionary
    ${addition_param_value_for_set}    Create Dictionary
    ${addition_param_value_for_check}    Create Dictionary
    ${addition_param_name_to_display}    Create List
    FOR    ${item}    IN    @{addition_param}
        Append To List    ${addition_param_name_to_display}    ${item['Parameter Name']}:
        Run Keyword If    '${item['Default Value']}'!='None'    Run Keywords
        ...    Should Be Equal As Strings    ${item['Default Value']}    ${dic_init_param_value['${item['Parameter Name']}:']}
        ...    AND    Set To Dictionary    ${addition_param_value_for_check}    ${item['Abbreviation']}=${item['Default Value']}
        Set To Dictionary    ${addition_param_abbreviation_mapping}    ${item['Parameter Name']}:=${item['Abbreviation']}
    END
    # validate additional input parameters required for feature configuration calculation shall be all displayed
    ${displayed_addition_params}    Get Dictionary Keys    ${dic_init_param_value}
    Sort List    ${addition_param_name_to_display}
    Lists Should Be Equal    ${displayed_addition_params}    ${addition_param_name_to_display}
    Set Test Variable    ${addition_param_abbreviation_mapping}
    ${params_list}    Get Dictionary Keys    ${dic_all_param_value}
    FOR    ${param}    IN    @{params_list}
        Run Keyword If    '${dic_init_param_value['${param}']}' != '<Select value>'    Remove Values From List    ${params_list}    ${param}
    END
    # 2024-04-03 Kang Lixin: specicial case on crt envs startCRBOfCoreset0 need select from 1 to 3
    ${startCRBOfCoreset0_values}    Create List    0    1    2    3
    # 2024-08-27 Kang Lixin: specicial case on crt envs fineTuneMode can not select mode2 on 1813,1894
    ${fineTuneMode_values}    Create List    disabled    mode1    mode3
    FOR    ${key}    IN    @{params_list}
        ${value_list}    Set Variable If    '${key}'=='startCRBOfCoreset0:'
        ...    ${startCRBOfCoreset0_values}
        ...    ${dic_all_param_value['${key}']}
        ${value_list}    Set Variable If    '${key}'=='fineTuneMode:'
        ...    ${fineTuneMode_values}
        ...    ${value_list}
        ${value}    Evaluate    random.choice(${value_list})    modules=random, sys
        Set To Dictionary    ${addition_param_value_for_set}    ${key}=${value}
        ${key_abbr}    Set Variable    ${addition_param_abbreviation_mapping['${key}']}
        Set To Dictionary    ${addition_param_value_for_check}    ${key_abbr}=${value}
    END
    Set Param Value Of Feature Object    ${addition_param_value_for_set}
    Capture Page Screenshot
    Set Test Variable    ${addtional_param_value_dic}    ${addition_param_value_for_check}

Step ${index}: Start Calculate And Check Results
    Log    Step ${index}: Start Calculate And Check Results  console=True
    ${calculate_result}    ${table_head_list}    ${validation_result}    SBTS WEM Calculate On CA Page And Get Results
    ${result_properties}    Create List    Check ID    Object name    Severity    Checked condition
    Lists Should Be Equal    ${result_properties}    ${table_head_list}    ignore_order=True
    Run Keyword If    "${validation_result[0]}"=="No data"    Run Keywords
    ...    Should Be Equal As Strings    ${calculate_result}    Calculate operation successful
    ...    AND    Return From Keyword
    FOR    ${item}    IN    @{validation_result}
        Should Not Be Equal As Strings    ${item['Severity']}    error
    END

Step ${index}: Apply All Inputs Into Current Plan
    Log    Step ${index}: Apply All Inputs Into Current Plan  console=True
    ${apply_result}    SBTS WEM Apply All On CA
    Should Be Equal As Strings    ${apply_result}    Success

Step ${index}: Provision Plan And Check Site Status
    Log    Step ${index}: Provision Plan And Check Site Status  console=True
    SBTS WEM Validate Plan
    Set Test Variable    ${NEED_RECOVERY}    ${True}
    SBTS WEM Activate Plan
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Additional Param In Actual Plan
    Log    Step ${index}: Check Additional Param In Actual Plan  console=True
    ${scf_content}    coam.Get SCF
    FOR    ${dn}    IN    @{nrcell_dn_list}
        Check Parameter Value From SCF For PDCCH    ${scf_content}    ${dn}    ${addtional_param_value_dic}
    END

SetUp
    Common Test Setup SBTS    scf_check=${FALSE}
    ${mrbts_id}    Admin Get BTS ID
    Set Test Variable    ${mrbts_id}
    ${scf_content}    coam.Get SCF
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${nrcell_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${nrcell_dn_list}    Create List
    ${nrcell_name_list}    Create List
    FOR    ${element}   IN    @{nrcell_elements}
        ${celldn}    L_XML.Get Element Attribute    ${element}    distName
        ${cellname}    Fetch From Right    ${celldn}    /
        Append To List    ${nrcell_dn_list}    ${celldn}
        Append To List    ${nrcell_name_list}    ${cellname}
    END
    Set Test Variable    ${nrcell_dn_list}
    Set Test Variable    ${nrcell_name_list}
    Cleanup pdcchAutoConfig via Delta Recomission

TearDown
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    SBTS WEM Download Chrome Console Log
    Cleanup pdcchAutoConfig in SCF    ${BTS_scf_initial}
    Run Keyword If    ${NEED_RECOVERY}    Recovery SBTS Configuration Via Full Commissioning
    Common Test Teardown SBTS
    [Teardown]    Close All Browsers