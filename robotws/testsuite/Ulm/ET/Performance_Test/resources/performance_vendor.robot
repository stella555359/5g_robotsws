*** Settings ***
Documentation    Test variable and keyword resource file for Performance_Test

Library    python/perf_vendor.py

Resource    performance_keywords.robot

*** Variables ***
${GNB_VENDOR_IS_MODIFIED}    ${False}
${TS_VENDOR_ORIG}            ${none}
${TS_VENDOR_MOD}             ${none}

*** Keywords ***
Get Vendor File
    [Arguments]    ${oam_connection_alias}=${OAM_ALIAS}
    IF    "${TS_VENDOR_ORIG}"!="${None}" and "${TS_VENDOR_MOD}"!="${None}"   RETURN    ${TS_VENDOR_ORIG}    ${TS_VENDOR_MOD}
    #P_resultSuiteConfigDir is a suite variable defined in common_keywords.robot
    ${vendor_file_path}=    Set Variable    ${P_resultSuiteConfigDir}/vendor_lte.xml
    ${vendor_file_modified_path}=    Set Variable    ${P_resultSuiteConfigDir}/vendor_lte_modified.xml
    admin.Download Vendor File    target_file_name=${vendor_file_path}    connection=${oam_connection_alias}
    copy file  ${vendor_file_path}  ${vendor_file_modified_path}
    Set Suite Variable    $TS_VENDOR_ORIG    ${vendor_file_path}
    Set Suite Variable    $TS_VENDOR_MOD     ${vendor_file_modified_path}
    RETURN    ${vendor_file_path}    ${vendor_file_modified_path}


Set Vendor File
    [Arguments]    ${oam_connection_alias}
    Log to console    Setting Vendor File...
    Log    ----- start: Set Vendor File -----    console=${false}
    Enable GNB SwConfig Admin RD Mode Enable    value=1
    ${vendor_file_path}    ${vendor_file_modified_path}    Get Vendor File    ${oam_connection_alias}
    Log    ${SPACE} ${SPACE} - vendor_file_modified_path: ${vendor_file_modified_path}     console=${false}
    admin.Set Vendor File  vendor_file=${vendor_file_modified_path}  connection=${oam_connection_alias}
    perf_log_collection.Queue Logs To Turandot    ${vendor_file_modified_path}    subfolder=${RL_PATH.final_config}
    Log    ----- end: Set Vendor File -----    console=${false}


Modify Vendor File All Pname
    [Arguments]    ${p_name}    ${modifed_value}    ${path_class}=NRBTS    ${value_filter}=${None}    ${original_value}=${None}
    Log    ----- start: Modify Vendor File All Pname -----    console=${false}
    ${_}    ${vendor_file_modified_path}    Get Vendor File
    Log to console     ${SPACE}- Set Vendor ${p_name} to ${modifed_value}
    ${ns}=                     perf_vendor.Get Ns
    ${path_in_xml}=            perf_vendor.Get Xml Path    ${p_name}    path_class=${path_class}
    ${path_in_xml_str}=        perf_vendor.Get Clean Xml Path    ${path_in_xml}
    IF    "${original_value}"=="${None}"
        ${original_value_list}    perf_vendor.Get Xml Value    ${vendor_file_modified_path}    ${path_in_xml}
    ELSE
        ${original_value_list}    Create List    ${original_value}
    END

    Log    ${space} ${space} ${space} original_value_list: ${original_value_list}    console=${false}
    ${original_value_list_len}    Get Length     ${original_value_list}
    IF    "${original_value_list_len}"=="0"    Log    ${SPACE} ${SPACE} - vendor param not matched    level=ERROR
    FOR    ${orig_values}    IN    @{original_value_list}
        Log    ${space} ${space} ${space} orig: ${orig_values}    console=${false}
        ${filter_criteria}=        Create Dictionary     ${p_name}=${orig_values}
        ${data_to_be_modified}=    Create Dictionary     ${p_name}=${modifed_value}
        IF    "${value_filter}"=="${None}" or "${value_filter}"=="${orig_values}"
            Log    ${SPACE} ${SPACE} - Set ${path_in_xml_str} to ${modifed_value} (orig.: ${orig_values})
            ...               console=${P_scf_console}
            perf_vendor.Modify Vendor File Wrapper
            ...               filter_criteria=${filter_criteria}
            ...               data_to_be_modified=${data_to_be_modified}
            ...               path_to_reference_vendor_file=${vendor_file_modified_path}
            ...               path_to_modified_vendor_file=${vendor_file_modified_path}
            ...               xml_path=${path_in_xml}
            Set Suite Variable    $GNB_VENDOR_IS_MODIFIED    ${TRUE}
        END
    END
    Log    ----- end: Modify Vendor File All Pname -----    console=${false}
