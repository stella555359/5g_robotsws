*** Settings ***
Documentation       Test suite for SyVe_CM_CB009451_C
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Library           ../Resources/python/FCT_Excel.py

*** Variables ***
@{ignore_param_list}    pucchSize:    #is caculated in pucch fct and no need to set in pdcch fct
...    (rel >=24R1) bwpChBwSmallMin:    (rel >=24R1) bwpChBwDedicated3:   #can not be configured for Cloud BTS in this release

*** Keywords ***
TC__VRAN_CM_Configure_Feature_As_Part_Of_New_BTS_Site_Creation_Using_Online_WebEM_CB009451-C_001
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    New case for TA_RAN_ST_CB009451-C_001_CM_Configure feature as part of new BTS site creation using online WebEM
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 22.06.2023 - New case.
    ...    - 10.01.2024 - Add CB010974_001 scenario  Author: lixin.kang@nokia-sbell.com
    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Download And Install FCE
    Step 2: Select PUCCH FCT From Droplist
    Step 3: Check Actual Full Configuration Selected As Default
    Step 4: Get Objects From PE And Select Objects On CA
    Step 5: Start Calculate And Check Results
    Step 6: Apply All Inputs Into Current Plan
    Step 7: Save And Check FCT Logs And Reports
    Step 8: Select PDCCH FCT From Droplist
    Step 9: Check Actual Full Configuration Selected As Default
    Step 10: Select Objects On CA
    Step 11: Define Additional Params For PDCCH
    Step 12: Start Calculate And Check Results
    Step 13: Apply All Inputs Into Current Plan
    Step 14: Save And Check FCT Logs And Reports
    Step 15: Validate And Activation Delta Plan And Check Site Status
    Step 16: Check Additional Param In Actual Plan

Step ${index}: Download And Install FCE
    Log To Console    Step ${index}: Download And Install FCE
    Open WEBEM and Login    https://${du_ip}    Nemuadmin    Nokia@123
    Go To PE Page
    Run Keyword And Ignore Error    netact.Delete Plan    DELTA-PLAN-1
    ${special_str}    Generate Random Special Charactors
    Set Test Variable    ${actual_full_plan_name}    TA_CB009451-C_CB010974_001_${special_str}
    Create Delta Plan    ${actual_full_plan_name}
    ${fce_worker_f_name}    ${fct_file_f_name}    Download FCE Modules For Current SW    ${Trunk_Prefix}
    Set Test Variable    ${fce_worker_f_name}
    Set Test Variable    ${fct_file_f_name}
    ${msg}    Install FCE    ${TEST_LOG_DIRECTORY}/${fce_worker_f_name}
    Should Be Empty    ${msg}
    ${list_FCE_features}    Get FCE Feature List
    Should Not Be Empty    ${list_FCE_features}
    Set Test Variable    ${list_FCE_features}

Step ${index}: Select ${desired_fct_feature} FCT From Droplist
    Log To Console    Step ${index}: Select ${desired_fct_feature} FCT From Droplist
    ${expected_feature_name}    Get Expected Feature Name    ${list_FCE_features}    ${desired_fct_feature}
    ${fce_list_objects}    Select Feature In Configuration Automation    ${expected_feature_name}
    Set Test Variable    ${fce_list_objects}
    Set Test Variable    ${expected_feature_name}

Step ${index}: Check Actual Full Configuration Selected As Default
    Log To Console    Step ${index}: Check Actual Full Configuration Selected As Default
    ${list_plan}    ${current_plan}    Get Plan Options From WebEM CA
    Should Be Equal As Strings    ${current_plan}    ${actual_full_plan_name}

Step ${index}: Get Objects From PE And Select Objects On CA
    Log To Console    Step ${index}: Get Objects From PE And Select Objects On CA
    ${obj}    ${all_MOs}    ${MOs_to_select}    Get Objects To Calculate    ${fce_list_objects}    ${actual_full_plan_name}
    Set Test Variable    ${obj}
    Set Test Variable    ${all_MOs}
    Set Test Variable    ${MOs_to_select}
    Select Object And Check Selected Value Match FCT    ${obj}    ${MOs_to_select}

Step ${index}: Select Objects On CA
    Log To Console    Step ${index}: Select Objects On CA
    ${dic_selected_param_value}    Select Object And Check Selected Value Match FCT    ${obj}    ${MOs_to_select}
    Set Test Variable    ${dic_selected_param_value}

Step ${index}: Define Additional Params For PDCCH
    Log To Console    Step ${index}: Select Objects And Define Additional Params
    ${addition_param_abbreviation_mapping}    Check Addtional Param Selected Value Should Match FCT    ${obj}    ${dic_selected_param_value}
    ${all_param_and_value}    Get All Param And Value Of Feature Object    ${expected_feature_name}    ${obj}
    # specicial case on crt env 11083, startCRBOfCoreset0 need select from 1 to 10
    ${startCRBOfCoreset0_values}    Create List    0    1    2    3    4    5    6    7    8    9    10
    Set To Dictionary     ${all_param_and_value}    startCRBOfCoreset0:    ${startCRBOfCoreset0_values}
    ${param_names}    Get Dictionary Keys    ${dic_selected_param_value}
    ${addition_param_value_for_set}    Create Dictionary
    ${addition_param_value_for_check}    Create Dictionary
    FOR    ${param}    IN    @{ignore_param_list}
        Remove Values From List    ${param_names}    ${param}
    END
    FOR    ${param}    IN    @{param_names}
        ${has_tag}    ${tag}    Run Keyword And Ignore Error
        ...    Should Match Regexp    ${param}    \\(rel \\>=\\w+\\)|\\(rel \\<=\\w+\\)|\\(rel \\<\\w+\\)|\\(rel \\>\\w+\\)|\\(rel \\=\\w+\\)
        ${compare_result}    Run Keyword If    '${has_tag}'=='PASS'
        ...    Compare Additional Param Support Version With Current SW From Tag     ${tag}
        Continue For Loop If    '${has_tag}'=='FAIL' or '${compare_result}'=='True'
        Remove Values From List    ${param_names}    ${param}
    END
    FOR    ${param}    IN    @{param_names}
        ${selected_val}    Get From Dictionary    ${dic_selected_param_value}    ${param}
        Run Keyword If    "${selected_val}"!=""    Run Keywords
        ...    Set To Dictionary    ${addition_param_value_for_check}    ${addition_param_abbreviation_mapping["${param}"]}    ${selected_val}
        ...    AND    Continue For Loop
        ${count}    Get Length    ${all_param_and_value["${param}"]}
        ${index}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
        ${val_to_set}    Set Variable    ${all_param_and_value["${param}"][${index}]}
        Set To Dictionary    ${addition_param_value_for_set}    ${param}    ${val_to_set}
        Set To Dictionary    ${addition_param_value_for_check}    ${addition_param_abbreviation_mapping["${param}"]}    ${val_to_set}
    END
    Set To Dictionary    ${addition_param_value_for_set}    selected_MOs    ${MOs_to_select}
    Set Test Variable    ${addParam_dic}    ${addition_param_value_for_check}
    Set Param Value Of Feature Object    ${expected_feature_name}    ${obj}    ${addition_param_value_for_set}

Step ${index}: Start Calculate And Check Results
    Log To Console    Step ${index}: Start Calculate And Check Results
    Enable Debug Function On CA
    ${result}    ${table_head_list}    ${validation_result}    ${addoutput_th_list}    ${add_output_param}    Calculate On CA Page And Get Results
    ${result_properties}    Create List    Check ID    Checked condition    Object name    Severity
    Sort List    ${result_properties}
    Sort List    ${table_head_list}
    Lists Should Be Equal    ${result_properties}    ${table_head_list}    ignore_order=True
    Run Keyword If    "${validation_result[0]}"=="No data"    Run Keywords
    ...    Should Be Equal As Strings    ${result}    Calculate operation successful
    ...    AND    Return From Keyword
    FOR    ${item}    IN    @{validation_result}
        Should Not Be Equal As Strings    ${item['Severity']}    error    ignore_case=${True}
    END
    Set Test Variable    ${validation_result}
    Set Test Variable    ${add_output_param}

Step ${index}: Apply All Inputs Into Current Plan
    Log To Console    Step ${index}: Apply All Inputs Into Current Plan
    ${apply_result}    Apply All On CA
    Should Be Equal As Strings    ${apply_result}    Success

Step ${index}: Save And Check FCT Logs And Reports
    Log To Console    Step ${index}: Save And Check FCT Logs And Reports
    ${debug_fct_filename}    Save Debug FCT On CA    ${TEST_LOG_DIRECTORY}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/${debug_fct_filename}
    ${file_size}    OperatingSystem.Get File Size    ${TEST_LOG_DIRECTORY}/${debug_fct_filename}
    Should Be True    ${file_size}>0
    ${json_report_filename}    Save JSON Report On CA    ${TEST_LOG_DIRECTORY}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/${json_report_filename}
    ${file_content}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/${json_report_filename}
    Should Not Be Empty    ${file_content}
    Check Saved FCT Json Report Content    ${TEST_LOG_DIRECTORY}/${json_report_filename}    ${validation_result}    ${add_output_param}

Step ${index}: Validate And Activation Delta Plan And Check Site Status
    Log To Console    Step ${index}: Validate And Activation Delta Plan And Check Site Status
    ${has_no_error}    Validate Plan    ${actual_full_plan_name}
    Should Be True    ${has_no_error}
    vDU Login By Rest
    ${delta_scf_fullpath}    vdu.save_delta_plan_file    local_path=${TEST_LOG_DIRECTORY}/backup_scf/
    ...    local_filename=backup_delta_plan_after_apply.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${delta_scf_fullpath}
    FOR    ${dn}    IN    @{all_MOs}
        ${pdcchSizeValue}   L_XML.Get Element Text    ${scf_content}
        ...    .//managedObject[@distName="${dn}"]/list[@name="pdcchAutoConfig"]/item/p[@name="pucchSize"]
        Set To Dictionary    ${addParam_dic}    pucchSize    ${pdcchSizeValue}
        Exit For Loop
    END
    vDU Logout By Rest
    Set Test Variable    ${NEED_RECOVER}    ${True}
    Activate Plan    ${actual_full_plan_name}    ${True}    ${True}
    Wait Until Keyword Succeeds    10    3min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check Additional Param In Actual Plan
    Log To Console    Step ${index}: Check Additional Param In Actual Plan
    vDU Backup SCF From Test Line    scf_after_provision.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_after_provision.xml
    FOR    ${dn}    IN    @{all_MOs}
        Check Parameter Value From SCF For PDCCH    ${scf_content}    ${dn}    ${addParam_dic}
    END

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Set Test Variable    ${NEED_RECOVER}    ${False}

Case Postcondition
    Log To Console    Case Postcondition
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    Run Keyword And Return Status    netact.Delete Plan    ${actual_full_plan_name}
    Logout And Close WEBEM
    Run Keyword If    ${NEED_RECOVER}    Full Commission SCF Via Rest    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Common Test Teardown For AIC

Unzip FCT
    [Arguments]    ${zip_file}
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output    unzip -o ${zip_file} -d ${TEST_LOG_DIRECTORY}
    Should Be Equal As Integers    ${rc}    ${0}
    ${fct_name}    Should Match Regexp    ${out_put}    FCT_PDCCH_MultiRelease.xlsx
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/${fct_name}
    [Return]    ${fct_name}

Full Commission SCF Via Rest
    [Arguments]    ${scf_path}
    ##-12840    vDU Update Full SCF By Rest    ${scf_path}
    ${out}   Parameter Operation    operation=full_commission   product_type=vdu    scf_path=${scf_path}
    Wait Until Keyword Succeeds    10    3min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Get Expected Feature Name
    [Arguments]     ${list_FCE_features}    ${desired_fct_feature}
    ${expected_feature_name}    Set Variable
    FOR    ${fea}    IN    @{list_FCE_features}
        ${not_desired}    Run Keyword And Return Status    Should Not Contain    ${fea}    ${desired_fct_feature}
        Continue For Loop If    ${not_desired}
        ${expected_feature_name}    Set Variable    ${fea}
        Exit For Loop
    END
    [Return]      ${expected_feature_name}

Select Object And Check Selected Value Match FCT
    [Arguments]    ${obj}    ${MOs_to_select}
    Go To Configuration Automation
    Select Feature In Configuration Automation    ${expected_feature_name}
    ${dic_selected_param_value}    Select Object In Configuration Automation    ${obj}
    ${empty_list}    Create List
    ${selected_obj_list}    Pop From Dictionary    ${dic_selected_param_value}    selected_MOs    ${empty_list}
    Sort List    ${MOs_to_select}
    Sort List    ${selected_obj_list}
    Lists Should Be Equal    ${MOs_to_select}    ${selected_obj_list}
    [Return]     ${dic_selected_param_value}

Get Objects To Calculate
    [Arguments]     ${object_list}    ${plan_name}
    ${obj}    Evaluate    random.choice(${object_list})    modules=random, sys
    ${all_MOs}    Filter MOs Of Plan On PE    ${obj}-    ${plan_name}
    ${MOs_to_select}    Create List
    FOR    ${MO}    IN    @{all_MOs}
        ${MO_name}    Fetch From Right    ${MO}    /
        Append To List    ${MOs_to_select}    ${MO_name}
    END
    [Return]    ${obj}    ${all_MOs}    ${MOs_to_select}

Check Addtional Param Selected Value Should Match FCT
    [Arguments]    ${obj}    ${dic_selected_param_value}
    Log    ${obj}
    ${fct_name}    Unzip FCT    ${TEST_LOG_DIRECTORY}/${fct_file_f_name}
    ${ADDIN_Param}    FCT_Excel.get_default_value_ADDIN    ${TEST_LOG_DIRECTORY}/${fct_name}    PARAMETER-METADATA
    ${addition_param_abbreviation_mapping}    Create Dictionary
    ${count}    Get Length    ${dic_selected_param_value}
    Should Be Equal As Integers    ${count}    ${ADDIN_Param.__len__()}
    FOR    ${param}    IN    @{ADDIN_Param}
        Set To Dictionary    ${addition_param_abbreviation_mapping}    ${param['Parameter Name']}:=${param['Abbreviation']}
        ${param_name}    Get From Dictionary    ${param}    Parameter Name
        ${default_value}    Set Variable If    "${param['Default Value']}"=="None"    <Select value>    ${param['Default Value']}
        Should Be Equal As Strings    ${default_value}    ${dic_selected_param_value['${param_name}:']}
    END
    ${param_names}    Get Dictionary Keys    ${dic_selected_param_value}
    FOR    ${param}    IN    @{param_names}
        ${val}    Get From Dictionary    ${dic_selected_param_value}    ${param}
        Run Keyword If    '${val}'=='<Select value>'    Set To Dictionary    ${dic_selected_param_value}    ${param}    ${EMPTY}
    END
    [Return]    ${addition_param_abbreviation_mapping}

Generate Random Special Charactors
    ${special_charactor}   Create List    ,   .   。  ?   !  :   ;   '     ~    @    \#    $    %    ^   (    )    +    -   *
    ...     /   =     _    <    >    {    }    [    ]    \    |    ${EMPTY}
    ${special_str}    Set Variable
    FOR    ${index}    IN RANGE    0    20
        ${tmp_str1}    Evaluate    random.choice(${special_charactor})    modules=random, sys
        ${special_str}      Set Variable    ${special_str}${tmp_str1}
    END
    [Return]     ${special_str}