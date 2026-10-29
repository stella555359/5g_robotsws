*** Settings ***
Documentation    Author: Ding Binmei
...    Trigger methods from LMF for CB007880
Library    XML
Library    OperatingSystem
Library    Collections
Library    String
Library    DateTime
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/L3_call_check_based_on_RRC.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/l3call.robot

*** Variables ***
${AMF_LCS_IP}    10.110.95.124
${AMF_LCS_ABORT_IP}    10.110.100.47

*** Keywords ***

__keywords_for_search__
    UE attach and trigger MT-LR procedure from LMF
    Trigger MT-LR procedure from LMF
    Update values in XML based on xpath

UE attach and trigger MT-LR procedure from LMF
    [Documentation]    Author: Ding Binmei
    ...    Trigger the MT-LR procedure and returned with F1AP log captured
    ...    ${cell_id_for_attach}: cell id where UE is attached
    ...    ${tcpdump_log_name}: F1AP log name prefix
    [Arguments]    ${cell_id_for_attach}    ${tcpdump_log_name}
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${tcpdump_log_name}    Set variable    ${tcpdump_log_name}_${timestamp}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}
    ${4G_check}    Set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    run keyword and continue on failure    Retry commercial ue attach if failed     prepare_ue_needed=${False}
    ...    4G_check=${4G_check}    detach_request=${True}
    ${bip_log_name}    Set variable    bip_log_${timestamp}
    Run keyword and ignore error    Collect Interface Mirroring Bip Collector    target_file_name=${bip_log_name}
    Log To Console    Start to trigger MT-LR procedure
    Trigger MT-LR procedure from LMF    trigger_config_file_path=${trigger_config_file_path}
    Sleep    10s    reason=Wait for MT-LR triggered and measurement report generated
    ${f1ap_log_path}    logs.Stop capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}
    ${bip_log_file_path}    Run keyword and ignore error    Get Bip Log Via Interface Mirroring Collector    target_file_name=${bip_log_name}
    Verify ue is attached to the expected cell    log_path_f1ap_ute=${f1ap_log_path}
    ...    cell_id_for_attach=${cell_id_for_attach}
    [Return]    ${f1ap_log_path}
    [Teardown]  Run keyword and ignore error    Run keywords    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}    AND
    ...    Stop Bip Log Via Interface Mirroring Collector    target_file_name=${bip_log_name}

Trigger MT-LR procedure from LMF
    [Documentation]    Author: Ding Binmei
    ...    Trigger the MT-LR procedure for a specific UE
    [Arguments]    ${trigger_config_file_path}=${None}
    ${trigger_config_file_path}    Run keyword if    "${trigger_config_file_path}"=="${None}"
    ...    Update attributes in config file and return new file path
    ...    ELSE    Set Variable    ${trigger_config_file_path}
    ${cmd_trigger_MT_LR_procedure}    Set Variable    curl -v http://${AMF_LCS_IP}:9210 -d@${trigger_config_file_path}
    ${result}    Run    ${cmd_trigger_MT_LR_procedure}
    Should Contain    ${result}    HTTP/1.1 200 OK

Trigger MT-LR abort procedure from LMF
    [Documentation]    Author: Qi Xin
    ...    Trigger the MT-LR measurement abort procedure for a specific UE
    [Arguments]    ${trigger_config_file_path}=${None}    ${ue_index}=0    ${retry_time}=3
    ${trigger_config_file_path}    Run keyword if    "${trigger_config_file_path}"=="${None}"
    ...    Update attributes in config file and return new file path
    ...    ELSE    Set Variable    ${trigger_config_file_path}
    FOR    ${i}    IN RANGE    ${retry_time}
        ${cmd_trigger_MT_LR_procedure_abort}    catenate
        ...    curl -s -v -X POST http://${AMF_LCS_ABORT_IP}:9092/nlmf-loc/v1/cancel-location -H
        ...    'Content-Type: application/json' -d'{ "ldrReference": "imsi-${tl.ues[${ue_index}].imsi}"}'
        ${result}    Run    ${cmd_trigger_MT_LR_procedure_abort}
        Run Keyword If    '204' in '''${result}'''    Exit For Loop
    END

Update attributes in config file and return new file path
    [Documentation]    Author: Ding Binmei
    ...    Update the XML file with new values based on provided xpath
    ...    ${ue_index}    Index of the UE to update
    ...    ${target_file_folder}    Folder to save the updated XML file
    [Arguments]    ${ue_index}=0    ${target_file_folder}=${SUITE_LOG_PATH}
    ${xml_file_path}    Set Variable    ${CURDIR}/lcs_srs_trigger.xml
    ${dict_params}    Create Dictionary    .//msid[@type\='IMSI']=${tl.ues[${ue_index}].imsi}
    ${new_file_path}    Update values in XML based on xpath    xml_file_path=${xml_file_path}    dict_params=${dict_params}
    ...    target_file_folder=${target_file_folder}
    [Return]    ${new_file_path}

Update values in XML based on xpath
    [Documentation]    Author: Ding Binmei
    ...    Update the XML file with new values based on provided xpath
    ...    ${xml_file_path}    Path to the XML file
    ...    ${dict_params}    Dictionary containing xpath and new values. E.G: {"xpath": "new_value"}
    [Arguments]    ${xml_file_path}    ${dict_params}    ${target_file_folder}
    # Get all xpath keys from dictionary
    ${xpath_params_xpath}    Get Dictionary Keys    dictionary=${dict_params}
    ${file_name}    Fetch from right   ${xml_file_path}    /
    ${new_file_path}    Join path    ${target_file_folder}    ${file_name}
    # Parse the XML file first
    ${xml}    Parse Xml    source=${xml_file_path}
    FOR    ${xpath}    IN    @{xpath_params_xpath}
        ${new_value}    Set Variable    ${dict_params}[${xpath}]
        ${param_original_value}    Get Element Text    source=${xml}    xpath=${xpath}
        Run keyword if    "${param_original_value}" != "${new_value}"
        ...    Set Element Text    source=${xml}    xpath=${xpath}    text=${new_value}
        ...    ELSE    Log to console    For ${xpath}: No need to update since value already matched
        # Verify the update
        ${updated_value}    Get Element Text    source=${xml}    xpath=${xpath}
        Should Be Equal As Strings    ${updated_value}    ${new_value}
        Log to console    Updated to value: ${updated_value} for ${xpath}
    END
    # Save the modified XML
    Save Xml    source=${xml}    path=${new_file_path}
    Log to console    XML file saved to: ${new_file_path}
    Run    cat ${new_file_path}
    [Return]    ${new_file_path}
