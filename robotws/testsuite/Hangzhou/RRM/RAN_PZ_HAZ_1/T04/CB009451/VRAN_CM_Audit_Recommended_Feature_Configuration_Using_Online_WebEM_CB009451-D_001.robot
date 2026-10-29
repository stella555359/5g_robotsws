*** Settings ***
Documentation       Test suite for SyVe_CM_CB009451_D
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Library           ../Resources/python/FCT_Excel.py

*** Variables ***
${fct_feature_pdcch}    PDCCH
${fct_feature_pucch}    PUCCH
${planned_plan_name}    TA_CB009451-D_001
${additionInfo_csv_path}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ11/TestData/additionalInfo_11084.csv

*** Keywords ***
TC__VRAN_CM_Audit_Recommended_Feature_Configuration_Using_Online_WebEM_CB009451-D_001
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.07.2023, lixin.kang@nokia-sbell.com, draft
    ...    18.1.2024,yuyan.xu@nokia-sbell.com, add steps for CB010974 case4 pucch
    Log To Console    ${TEST_NAME} start.
    Step 1: Download And Install FCE
    Step 2: Import Prepared SCF And Check Is Selected As Default
    Step 3: Select PUCCH FCT From Droplist
    Step 4: Select Objects For PUCCH
    Step 5: Start Audit And Check Results
    Step 6: Save And Check Three Reports
    Step 7: Compare And Apply All Into Planned Configuration
    Step 8: Select PDCCH FCT From Droplist
    Step 9: Select Objects And Import Additional Params
    Step 10: Start Audit And Check Results
    Step 11: Save And Check Three Reports
    Step 12: Compare And Apply All Into Planned Configuration
    Step 13: Provision Plan And Check Site Status
    Step 14: Check Additional Param In Actual Plan

Step ${index}: Download And Install FCE
    Log To Console    Step ${index}: Download And Install FCE
    Open WEBEM and Login    https://${du_ip}    Nemuadmin    Nokia@123
    Go To PE Page
    ${fce_worker_f_name}    ${fct_file_f_name}    Download FCE Modules For Current SW    ${Trunk_Prefix}
    Set Test Variable    ${fce_worker_f_name}
    Set Test Variable    ${fct_file_f_name}
    ${msg}    Install FCE    ${TEST_LOG_DIRECTORY}/${fce_worker_f_name}
    Should Be Empty    ${msg}
    ${list_FCE_features}    Get FCE Feature List
    Should Not Be Empty    ${list_FCE_features}
    ${expected_feature_pdcch}    Set Variable
    ${expected_feature_pucch}    Set Variable
    FOR    ${fea}    IN    @{list_FCE_features}
        ${is_pdcch}    Run Keyword And Return Status    Should Contain    ${fea}    ${fct_feature_pdcch}
        ${is_pucch}    Run Keyword And Return Status    Should Contain    ${fea}    ${fct_feature_pucch}
        ${expected_feature_pdcch}    Set Variable If   ${is_pdcch}    ${fea}    ${expected_feature_pdcch}
        ${expected_feature_pucch}    Set Variable If   ${is_pucch}    ${fea}    ${expected_feature_pucch}
    END
    Should Not Be Empty    ${expected_feature_pdcch}
    Should Not Be Empty    ${expected_feature_pucch}
    Set Test Variable    ${expected_feature_pdcch}
    Set Test Variable    ${expected_feature_pucch}

Step ${index}: Import Prepared SCF And Check Is Selected As Default
    Log    Step ${index}: Import Prepared SCF And Check Is Selected As Default   console=True
    ##-12840 Upload New SCF And Validate    ${planned_plan_name}  # can't upload scf from vRAN GUI with selenium
    ${out}    svdu.load_commissioning_file_and_check_load_status
    ...    file_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    plan_name=${planned_plan_name}
    # need to select plan because no interact on vRAN GUI to make plan selected as default
    ${list_plan}    ${current_plan}    Get Plan Options From WebEM CA
    Run Keyword If    "${current_plan}"!="${planned_plan_name}"    Select Plan On CA    ${planned_plan_name}
    Capture Page Screenshot    select_planned.png

Step ${index}: Select ${Feature} FCT From Droplist
    Log To Console    Step ${index}: Select ${Feature} FCT From Droplist
    ${fce_list_objects}    Select Feature In Configuration Automation    ${expected_feature_${Feature.lower()}}
    Set Test Variable    ${fce_list_objects}

Step ${index}: Select Objects For PUCCH
    Log To Console    Step ${index}: Select Objects For PUCCH
    ${obj}    ${MOs_to_select}    Get Objects To Calculate
    Select Object And Check Selected Value Match FCT    ${obj}    ${MOs_to_select}    ${expected_feature_pucch}

Step ${index}: Select Objects And Import Additional Params
    Log To Console    Step ${index}: Select Objects And Import Additional Params
    ${obj}    ${MOs_to_select}    Get Objects To Calculate
    Select Object And Check Selected Value Match FCT    ${obj}    ${MOs_to_select}    ${expected_feature_pdcch}
    Import CSV On CA    ${additionInfo_csv_path}

Step ${index}: Start Audit And Check Results
    Log To Console    Step ${index}: Start Calculate And Check Results
    Enable Debug Function On CA
    ${result}    ${table_head_list}    ${validation_result}    ${addoutput_th_list}    ${add_output_param}     Audit On CA Page And Get Results
    ${result_properties}    Create List    Check ID    Checked condition    Object name    Severity
    Sort List    ${result_properties}
    Sort List    ${table_head_list}
    Lists Should Be Equal    ${result_properties}    ${table_head_list}    ignore_order=True
    Run Keyword If    "${validation_result[0]}"=="No data"    Run Keywords
    ...    Should Be Equal As Strings    ${result}    Audit operation successful
    ...    AND    Return From Keyword
    FOR    ${item}    IN    @{validation_result}
        Should Not Be Equal As Strings    ${item['Severity']}    error    ignore_case=${True}
    END
    Set Test Variable    ${validation_result}
    Set Test Variable    ${add_output_param}

Step ${index}: Compare And Apply All Into Planned Configuration
    Log To Console    Step ${index}: Compare And Apply All Into Planned Configuration
    ${params_list}    Create List    pucchSize
    ${DN_paramValues_tmp}    Compare And Apply Success On CA And Check Result    ${params_list}
    ${DN_paramValues}    Set Variable If    "${index}"=="7"    ${DN_paramValues_tmp}    ${DN_paramValues}
    Set Test Variable    ${DN_paramValues}

Step ${index}: Save And Check Three Reports
    Log To Console    Step ${index}: Save And Check Three Reports
    ${debug_fct_filename}    Save Debug FCT On CA    ${TEST_LOG_DIRECTORY}
    ${debug_fct}    Unzip File    ${TEST_LOG_DIRECTORY}/${debug_fct_filename}
    ${file_size}    OperatingSystem.Get File Size    ${TEST_LOG_DIRECTORY}/${debug_fct}
    Should Be True    ${file_size}>0

    ${json_report_filename}    Save JSON Report On CA    ${TEST_LOG_DIRECTORY}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/${json_report_filename}
    ${file_content}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/${json_report_filename}
    Should Not Be Empty    ${file_content}
    Check Saved FCT Json Report Content    ${TEST_LOG_DIRECTORY}/${json_report_filename}    ${validation_result}    ${add_output_param}

    ${audit_report_filename}    Save Audit Report On CA    ${TEST_LOG_DIRECTORY}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/${audit_report_filename}
    ${file_content}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/${audit_report_filename}
    Should Not Be Empty    ${file_content}

Step ${index}: Save And Check Audit Report
    Log To Console    Step ${index}: Save And Check Audit Report
    ${audit_report_filename}    Save Audit Report On CA     ${TEST_LOG_DIRECTORY}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/${audit_report_filename}
    ${file_content}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/${audit_report_filename}
    Should Not Be Empty    ${file_content}

Step ${index}: Provision Plan And Check Site Status
    Log To Console    Step ${index}: Provision Plan And Check Site Status
    ${has_no_error}    Validate Plan    ${planned_plan_name}
    Should Be True    ${has_no_error}
    Activate Plan    ${planned_plan_name}    ${False}    ${False}
    Set Test Variable    ${NEED_RECOVER}    ${True}
    Wait Until Keyword Succeeds    20min    2min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check Additional Param In Actual Plan
    Log To Console    Step ${index}: Check Additional Param In Actual Plan
    vDU Backup SCF From Test Line    scf_after_apply.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_after_apply.xml
    ${addInfo}    FCT_Excel.get_imported_additional_csv    ${additionInfo_csv_path}
    FOR    ${dn}    IN    @{all_MOs}
        ${param_dic}    Get From Dictionary    ${addInfo}    ${dn}
        ${param_dic}    Remove Empty Item For Dictionary    ${param_dic}
        Set To Dictionary    ${param_dic}    pucchSize    ${DN_paramValues["${dn}"]["pucchSize"]}
        Check Parameter Value From SCF For PDCCH    ${scf_content}    ${dn}    ${param_dic}
    END

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Set Test Variable    ${NEED_RECOVER}    ${False}

Case Postcondition
    Log To Console    Case Postcondition
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    Run Keyword And Return Status    netact.Delete Plan    ${planned_plan_name}
    Logout And Close WEBEM
    Run Keyword If    ${NEED_RECOVER}    Full Commission SCF Via Rest    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Common Test Teardown For AIC

Remove Empty Item For Dictionary
    [Arguments]    ${params_dic}
    ${keys}    Get Dictionary Keys    ${params_dic}
    FOR    ${key}    IN    @{keys}
        Run Keyword If    "${params_dic["${key}"]}"==""    Remove From Dictionary    ${params_dic}    ${key}
    END
    [Return]    ${params_dic}

Unzip File
    [Arguments]    ${zip_file}
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output    unzip -o ${zip_file} -d ${TEST_LOG_DIRECTORY}
    Should Be Equal As Integers    ${rc}    ${0}
    ${file_name}    Should Match Regexp    ${out_put}    .*\\.xlsx
    ${file_name}    Fetch From Right    ${file_name}    /
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/${file_name}
    [Return]    ${file_name}

Full Commission SCF Via Rest
    [Arguments]    ${scf_path}
    ##-12840 vDU Login By Rest
    ##-12840 ${plan_id}    ${action_id}    ${validate_id}    Upload And Validate Plan
    ##-12840  ...    plan_file=${scf_path}    plan_name=back_up_plan    validate=${True}
    ##-12840 Activate Plan By REST    ${plan_id}
    ##-12840 vdu.disconnect
    ${out}   Parameter Operation    operation=full_commission   product_type=vdu    scf_path=${scf_path}
    Wait Until Keyword Succeeds    10min    3min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Get Objects To Calculate
    ${obj}    Evaluate    random.choice(${fce_list_objects})    modules=random, sys
    ${all_MOs}    Filter MOs Of Plan On PE    ${obj}-    ${planned_plan_name}
    Set Test Variable    ${all_MOs}
    ${MOs_to_select}    Create List
    FOR    ${MO}    IN    @{all_MOs}
        ${MO_name}    Fetch From Right    ${MO}    /
        Append To List    ${MOs_to_select}    ${MO_name}
    END
    [Return]    ${obj}    ${MOs_to_select}

Select Object And Check Selected Value Match FCT
    [Arguments]    ${obj}    ${MOs_to_select}    ${expected_feature}
    Go To Configuration Automation
    Select Feature In Configuration Automation    ${expected_feature}
    ${dic_selected_param_value}    Select Object In Configuration Automation    ${obj}
    ${empty_list}    Create List
    ${selected_obj_list}    Pop From Dictionary    ${dic_selected_param_value}    selected_MOs    ${empty_list}
    Sort List    ${MOs_to_select}
    Sort List    ${selected_obj_list}
    Lists Should Be Equal    ${MOs_to_select}    ${selected_obj_list}
