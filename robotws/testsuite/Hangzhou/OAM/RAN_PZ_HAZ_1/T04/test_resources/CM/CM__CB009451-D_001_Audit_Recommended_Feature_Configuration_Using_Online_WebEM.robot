*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot
Library           ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/FCT_Excel.py

*** Variables ***
${desired_fct_feature}    PDCCH
${planned_plan_name}    CONF-1
${planned_plan_file}    Planned_SCF
${NEED_RECOVERY}    False
${imported_addparam_file}
...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/test_line_specific/SBTS_SYVE_1905/additionalInfo.csv  #need set in testset

*** Keywords ***
CM__CB009451-D_001_Audit_Recommended_Feature_Configuration_Using_Online_WebEM
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   New case for TA_RAN_ST_CB009451-D_001_CM_Audit recommended feature configuration using online WebEM
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.07.2023 - New case

    Set Tags    CM    UI    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Download And Install FCE
    Step 2: Select Full Planned Configuration
    Step 3: Select Desired FCT From Droplist
    Step 4: Select Objects
    Step 5: Import Additional Dedicated Parameters
    Step 6: Audit And Check Result
    Step 7: Save And Check Audit Report
    Step 8: Apply All Success And Check Result Into Planned Configuration
    Step 9: Provision Planned Plan And Check Site Status
    Step 10: Check Imported Additional Param In Actual Plan

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
    OperatingSystem.File Should Exist    ${Test Results Dir}/TestFiles/${fct_file_name}
    ${expected_feature_name}    Set Variable
    FOR    ${fea}    IN    @{list_FCE_features}
        ${status}    Run Keyword And Return Status    Should Contain    ${fea}    ${desired_fct_feature}
        Run Keyword If    ${status}    Run Keywords    Set Test Variable    ${expected_feature_name}    ${fea}
        ...    AND    Return From Keyword
    END
    Should Not Be Empty    ${expected_feature_name}    No ${desired_fct_feature}FCT installed on site!
    Set Test Variable    ${expected_feature_name}

Step ${index}: Select Full Planned Configuration
    Log    Step ${index}: Select Full Planned Configuration   console=True
    ${planned_scf}    coam.Get Current Scf File    ${Test Results Dir}/TestFiles    ${planned_plan_file}.xml
    SBTS WEM Load SCF File    ${planned_scf}
    ${list_plan}    ${current_plan}    Get Plan Options From WebEM CA
    Run Keyword If    "${current_plan}"!="${planned_plan_name}"    SBTS WEM Select Plan On CA    ${planned_plan_name}
    Capture Page Screenshot    select_planned.png

Step ${index}: Select Desired FCT From Droplist
    Log    Step ${index}: Select Desired FCT From Droplist    console=True
    ${fce_objects_list}    SBTS WEM Select Feature On CA    ${expected_feature_name}
    Set Test Variable    ${fce_objects_list}

Step ${index}: Select Objects
    Log    Step ${index}: Select Objects   console=True
    ${obj}    Evaluate    random.choice(${fce_objects_list})    modules=random, sys
    ${selected_object_instance}    ${dic_init_param_value}     SBTS WEM Select Object On CA   ${obj}
    ${sub_obj_list}    ${dic_all_param_value}    Get All Additional Param Value And Object Instance    ${obj}
    ${selected_obj_list}    Split String    ${selected_object_instance}    ,${SPACE}
    # validate selected sub objects match the objects in current plan
    Lists Should Be Equal    ${selected_obj_list}    ${sub_obj_list}    ignore_order=True
    ${scf_content}    coam.Get SCF
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${nrcell_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="com.nokia.srbts.nrbts:${obj}"]
    ${current_nrcell_name_list}    Create List
    FOR    ${element}    IN    @{nrcell_elements}
        ${nrcell}    L_XML.Get Element Attribute    ${element}   distName
        ${cellname}    Fetch From Right    ${nrcell}    /
        Append To List   ${current_nrcell_name_list}    ${cellname}
    END
    Lists Should Be Equal    ${selected_obj_list}    ${current_nrcell_name_list}    ignore_order=True
    # Only select the NRCELL defined in CSV to avoid conflict - Error: MRBTS-1894/NRBTS-10534/BWP_PROFILE-70,
    #   MRBTS-1894/NRBTS-10534/BWP_PROFILE-72/PDCCH-1/PDCCH_CONFIG_DEDICATED-1 object(s) is(are) affected by calculation results of more
    #   than one target object [MRBTS-1894/NRBTS-10534/NRCELL-0, MRBTS-1894/NRBTS-10534/NRCELL-2]. Therefore, the resulting configuration
    #   has conflicts. Please modify the input plan to avoid conflicts.
    ${nrcell_name_list}    Create List
    ${addParam_CSV}    FCT_Excel.get_imported_additional_csv    ${imported_addparam_file}
    ${nrcell_dn_list}    Get Dictionary Keys   ${addParam_CSV}
    FOR    ${celldn}   IN    @{nrcell_dn_list}
        ${cellname}    Fetch From Right    ${celldn}    /
        Append To List    ${nrcell_name_list}    ${cellname}
    END
    ${unselected_sub_obj_list}    Set Variable    ${selected_obj_list}
    Remove Values From List    ${unselected_sub_obj_list}    @{nrcell_name_list}
    Wait Element Visible And Click    //p-multiselect//div[contains(@class,"p-clickable")]
    FOR    ${cellname}    IN    @{unselected_sub_obj_list}
        Wait Element Visible And Click    //p-multiselectitem//span[@ng-reflect-text="${cellname}"]
    END
    Set Test Variable    ${nrcell_dn_list}
    Set Test Variable    ${nrcell_name_list}

Step ${index}: Import Additional Dedicated Parameters
    Log    Step ${index}: Import Additional Dedicated Parameters    console=True
    SBTS WEM Import CSV On CA    ${imported_addparam_file}

Step ${index}: Audit and Check Result
    Log    Step ${index}: Audit And Check Results  console=True
    ${calculate_result}    ${table_head_list}    ${validation_result}    SBTS WEM Audit On CA Page And Get Results
    ${result_properties}    Create List    Check ID    Object name    Severity    Checked condition
    Lists Should Be Equal    ${result_properties}    ${table_head_list}    ignore_order=True
    Run Keyword If    "${validation_result[0]}"=="No data"    Run Keywords
    ...    Should Be Equal As Strings    ${calculate_result}    Audit operation successful
    ...    AND    Return From Keyword
    FOR    ${item}    IN    @{validation_result}
        Should Not Be Equal As Strings    ${item['Severity']}    error
    END

Step ${index}: Save And Check Audit Report
    Log    Step ${index}: Save And Check Audit Report  console=True
    ${audit_report_filename}    SBTS WEM Save Audit Report On CA    ${Test Results Dir}
    Log    ${audit_report_filename}    console=True

Step ${index}: Apply All Success And Check Result Into Planned Configuration
    Log    Step ${index}: Apply All Into Planned Configuration  console=True
    ${apply_result}    Compare And Apply Success And Check Result On CA

Step ${index}: Provision Planned Plan And Check Site Status
    Log    Step ${index}: Provision Planned Plan And Check Site Status    console=True
    Set Test Variable    ${NEED_RECOVERY}    ${True}
    SBTS WEM Activate Planed BTS Configuration    ${planned_plan_name} - ${planned_plan_file}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Imported Additional Param In Actual Plan
    Log    Step ${index}: Check Imported Additional Param In Actual Plan  console=True
    coam.Get Current Scf File    local_dir_path=${Test Results Dir}/TestFiles    file_name=scf_after_apply.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${Test Results Dir}/TestFiles/scf_after_apply.xml
    ${addParam_CSV}    FCT_Excel.get_imported_additional_csv    ${imported_addparam_file}
    FOR    ${dn}    IN    @{nrcell_dn_list}
        ${addParam_dic}    Get From Dictionary    ${addParam_CSV}    ${dn}
        ${addParam_dic}    Remove Empty Item For Dictionary    ${addParam_dic}
        Check Parameter Value From SCF For PDCCH     ${scf_content}    ${dn}    ${addParam_dic}
    END

Remove Empty Item For Dictionary
    [Arguments]    ${params_dic}
    ${keys}    Get Dictionary Keys    ${params_dic}
    FOR    ${key}    IN    @{keys}
        Run Keyword If    "${params_dic["${key}"]}"==""    Remove From Dictionary    ${params_dic}    ${key}
    END
    [Return]    ${params_dic}

SetUp
    Common Test Setup SBTS    scf_check=${FALSE}
    ${mrbts_id}    Admin Get BTS ID
    Set Test Variable    ${mrbts_id}
    Cleanup pdcchAutoConfig via Delta Recomission

TearDown
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    SBTS WEM Download Chrome Console Log
    Cleanup pdcchAutoConfig in SCF    ${BTS_scf_initial}
    Run Keyword If    ${NEED_RECOVERY}    Recovery SBTS Configuration Via Full Commissioning
    Common Test Teardown SBTS
    [Teardown]    Close All Browsers