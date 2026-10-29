*** Settings ***
Documentation
...    Author:mengyan
...    Contact:meng.yan@nokia-sbell.com
...    Group: RAN_PZ_HAZ_3
...    Feature: CB010474

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/AIC_BTS.robot
Library        taf.gnb.oam.coam.vdu.interface    WITH NAME    vdu

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].cu.instance_id}
${SBTS_RM_MAX_TEMPERATURE_DIST}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
${SBTS_SFP_RM_AVG_TEMPERATURE_DIST}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/SFP-1
${ns}    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${namespace_vdu}    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${service_user_password}    bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
${rf_scan_file_path}    /home/ute/
*** Keywords ***
Delete RF scan test operation M2M_API
    [Arguments]    ${operation_id}   ${timeout}=30
    [Documentation]   this kw is used to delete RF scan test operation by M2MApi
    Log to console  delete rf scan test operation via M2MAPI
    vdu.delete_rf_scan_test_operation    operation_id=${operation_id}

Get rf scan test file M2M_API
    [Arguments]    ${local_path}=${rf_scan_file_path}    ${timeout}=30
    [Documentation]   this kw is used to get rfmonitoring_rfscan.zip fil by M2MApi
    Log to console  get rfmonitoring_rfscan.zip fil by M2MApi
    ${timestamp1}=       Get Current Date    result_format=%Y%m%d
    Set Suite Variable    ${rf_scan_file_name}    RFMonitoring_${MRBTS_ID}_rf_scan_${timestamp1}.zip
    ${rf_scan_file_path}    vdu.get_rf_scan_test_file    local_path=${local_path}    local_file_name=${rf_scan_file_name}
    Check RF scan file     ${rf_scan_file_path}
    #Return]    ${rf_scan_file_path}

Check Rf Scan Operation Status Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}    ${vdu_connection}=default
    ${out}    vdu.get_rf_scan_test_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

Start RF Scanning test with FIR9
    [Arguments]    ${ru_dn}=None    ${signal}=None    ${antenna_carrier}=None    ${antenna_panel}=None
    ...    ${timeout}=30
    vDU Login By Rest
    ${rf_scanning_status}    vdu.start_rf_scan_test    ru_dn=${ru_dn}    signal=${signal}    antenna_carrier=${antenna_carrier}
    ...    antenna_panel=${antenna_panel}    timeout=${timeout}
    Set Suite Variable    ${rf_scan_status}    ${rf_scanning_status}
    Wait Until Keyword Succeeds  60   3   Check Rf Scan Operation Status Should Be Expected   operation_id=${rf_scan_status["operation_id"]}
    ...    expected_status=success
    Get rf scan test file M2M_API
    [Teardown]    case teardown

Start RF Scanning test with HBF0
    [Arguments]    ${ru_dn}=None    ${signal}=None    ${antenna_panel}=None    ${timeout}=30
    vDU Login By Rest
    ${rf_scanning_status}    vdu.start_rf_scan_test    ru_dn=${ru_dn}    signal=${signal}    antenna_panel=${antenna_panel}    timeout=${timeout}
    Set Suite Variable    ${rf_scan_status}    ${rf_scanning_status}
    Wait Until Keyword Succeeds  90   3   Check Rf Scan Operation Status Should Be Expected   operation_id=${rf_scan_status["operation_id"]}
    ...    expected_status=success
    Get rf scan test file M2M_API
    [Teardown]    case teardown

case teardown
    Run Keyword And Ignore Error    Delete RF scan test operation M2M_API    operation_id=${rf_scan_status["operation_id"]}
    Run Keyword And Ignore Error    vDU Logout By Rest

Check RF scan file
    [Arguments]  ${RF_SCAN_FILE_PATH}
    Log To Console  Check RF scan file
    ${size}=  OperatingSystem.get file size  ${RF_SCAN_FILE_PATH}
    should be true  ${size} > 500
    Remove File  ${RF_SCAN_FILE_PATH}

vDU Login By Rest
    [Arguments]    ${restapi_version}=cuoam_21b    ${vdu_index}=0    ${gnb_index}=0    ${alias}=default
    [Documentation]    this kw is used to Login vDU By Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | restapi_version | yes | define api version |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Login By Rest |
    ...
    ${oam_httpaddr}    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    Run keyword and ignore error    vDU Logout By Rest    vdu_index=${vdu_index}
    ${vdu_connection}=    Run Keyword If    '${restapi_version}'=='cuoam_21b'    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}
    ...  ELSE    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=8081
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}

vDU Logout By Rest
    [Arguments]    ${vdu_index}=0    ${alias}=default
    [Documentation]  this kw is used to Logout vDU By Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Logout By Rest  |
    ...
    vdu.disconnect    ${alias}
