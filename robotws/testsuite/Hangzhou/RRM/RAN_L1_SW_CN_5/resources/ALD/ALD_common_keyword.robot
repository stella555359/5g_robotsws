*** Settings ***
Documentation    Auther:jun.8.chen@nokia-sbell.com
...              This Common Keyword is for ALD related Feature.
Library    BuiltIn
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem
Resource    ../BTS/coam_gnb_classical.robot
Resource    ../BTS/coam_siso_common.robot
Resource    ../BTS/gnb_classical_hangzhou.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot


*** Variables ***
${BTS_ID}    ${tl.gnbs[0].instance_id}


*** Keywords ***
#-----------------------Some actions for ALD of GNB-------------------------------------#
Get BTS Information via rest api
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Info: ready to Get BTS Information
    ${bts_info} =    coam.get_bts_info    connection=${connection}
    [Return]    ${bts_info}

Get Running Object of ALD
    [Arguments]    ${ald_index}=1    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${bts_info} =    Get BTS Information via rest api    connection=${connection}
    @{alds}    Set Variable    ${bts_info["alds"]}
    ${ald_num} =    Get Length    ${alds}
    ${status} =    Set Variable    ${False}
    ${running_object} =    Set Variable    ${SPACE}
    FOR  ${ald}  IN  @{alds}
       Exit For Loop If    ${ald_num}==${0}
       ${running_object} =    Set Variable    ${ald["id"]["runtime"]}
       ${status} =    Run Keyword And Return Status    Should Contain    ${ald["id"]["configuration"]}    ALD-${ald_index}
       Exit For Loop If    ${status}
    END
    Run Keyword If    ${status}==${False}    Fail    ALD-${ald_index} is not present on gnb.
    [Return]    ${running_object}

Enable DC Voltgae For RET Port
    [Arguments]    ${mrbts_id}=${BTS_ID}    ${rmod_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Enable DC Voltgae
    &{dcVoltage_param}    Create Dictionary    abbr=dcVoltageEnabled
    ...    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_index}/RSL-1
    ...    filter_param=DC voltage enabled
    ...    new_value=true
    @{dcVoltage_param}    Create List    ${dcVoltage_param}
    COAM Update several parameters via webUI   parameters_to_update_via_webui=${dcVoltage_param}
    ...    download_dir=${download_dir}

Disable DC Voltgae For RET Port
    [Arguments]    ${mrbts_id}=${BTS_ID}    ${rmod_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Disable DC Voltgae
    &{dcVoltage_param}    Create Dictionary    abbr=dcVoltageEnabled
    ...    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_index}/RSL-1
    ...    filter_param=DC voltage enabled
    ...    new_value=false
    @{dcVoltage_param}    Create List    ${dcVoltage_param}
    COAM Update several parameters via webUI   parameters_to_update_via_webui=${dcVoltage_param}
    ...    download_dir=${download_dir}

Get ALD Information via webUI
    [Arguments]    ${ald_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Get ALD Information
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${ald_info} =    selenium_coam.get_ald_info    ald_index=${ald_index}
    [Return]    ${ald_info}
    [Teardown]    COAM selenium logout

Get RETU Information via webUI
    [Arguments]    ${retu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Get RETU Information
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${retu_info} =    selenium_coam.get_retu_info    retu_index=${retu_index}
    [Return]    ${retu_info}
    [Teardown]    COAM selenium logout

Get RAEU Information via webUI
    [Documentation]    Author: Wang Yixiang
    ...    This keyword will get RAE information from web UI
    [Arguments]    ${raeu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${retu_info} =    selenium_coam.get_raeu_info    raeu_index=${raeu_index}
    [Return]    ${retu_info}
    [Teardown]    COAM selenium logout

Reset ALD via webUI
    [Documentation]    Description: Resrt ALD from webui
    ...    ${reset_type}: value can be software, hardware, defult to use hardware
    ...    ${ald_index}: index of ALD
    [Arguments]    ${reset_type}=hardware    ${ald_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Reset ALD
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    selenium_coam.reset_ald    reset_type=${reset_type}    ald_index=${ald_index}
    [Teardown]    COAM selenium logout

Calibrate RETU via webUI
    [Arguments]    ${retu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Calibrate RETU
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    selenium_coam.calibrate_retu    retu_index=${retu_index}
    [Teardown]    COAM selenium logout

Set RETU Angless via webUI
    [Arguments]    ${angle_value}    ${retu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Set RETU Angless
    &{angle_configuration}    Create Dictionary    angle=${angle_value}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    selenium_coam.set_retu_angles    configuration=${angle_configuration}    retu_index=${retu_index}
    [Teardown]    COAM selenium logout

ALD Should Be Online
    [Arguments]    ${ald_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: ready to verify ALD should be online...
    ${ald_info} =    Get ALD Information via webUI    ald_index=${ald_index}    download_dir=${download_dir}
    Should Be Equal As Strings    ${ald_info["Status"]["Availability status"]}    Online
    ...    msg=Current ALD availability_status is not online    ignore_case=${True}

RETU Should Be Online
    [Arguments]    ${retu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: ready to verify RETU should be online...
    ${retu_info} =    Get RETU Information via webUI    retu_index=${retu_index}    download_dir=${download_dir}
    Should Be Equal As Strings    ${retu_info["Status"]["Availability status"]}    Online
    ...    msg=Current RETU availability_status is not online    ignore_case=${True}

RAEU Should Be Online
    [Documentation]    Author: Wang Yixiang
    ...    Check whether RAE is online or not by web UI
    [Arguments]    ${raeu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    ${retu_info} =    Get RAEU Information via webUI    raeu_index=${raeu_index}    download_dir=${download_dir}
    Should Be Equal As Strings    ${retu_info["Status"]["Availability status"]}    Online
    ...    msg=Current RAEU availability_status is not online    ignore_case=${True}

ALD Should Be Ready
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${ald_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: verify ALD should be ready...
    Check ALD Status
    ...    administrative_state=Unlocked    availability_status=Online
    ...    operational_state=Enabled    procedural_status=--
    ...    ald_index=${ald_index}    download_dir=${download_dir}

RAEU Should Be Ready
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${raeu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: verify RAEU should be ready...
    Check RAEU Status
    ...    administrative_state=Unlocked    availability_status=Online
    ...    operational_state=Enabled    procedural_status=--
    ...    raeu_index=${raeu_index}    download_dir=${download_dir}

Check ALD Status
    [Arguments]    ${administrative_state}
    ...    ${availability_status}
    ...    ${operational_state}
    ...    ${procedural_status}
    ...    ${ald_index}=1
    ...    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: ready to check ALD status...
    ${ald_info} =    Get ALD Information via webUI    ald_index=${ald_index}    download_dir=${download_dir}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${ald_info["Status"]["Administrative state"]}    ${administrative_state}
    ...    msg=Current ALD administrative_state is not in ${administrative_state} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${ald_info["Status"]["Availability status"]}    ${availability_status}
    ...    msg=Current ALD availability_status is not in ${availability_status} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${ald_info["Status"]["Operational state"]}    ${operational_state}
    ...    msg=Current ALD operational_state is not in ${operational_state} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${ald_info["Status"]["Procedural status"]}    ${procedural_status}
    ...    msg=Current ALD procedural_status is not in ${procedural_status} status    ignore_case=${True}

Check RETU Status
    [Arguments]    ${administrative_state}
    ...    ${availability_status}
    ...    ${operational_state}
    ...    ${procedural_status}
    ...    ${retu_index}=1
    ...    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: ready to check RETU status...
    ${retu_info} =    Get RETU Information via webUI    retu_index=${retu_index}    download_dir=${download_dir}
    Should Be Equal As Strings    ${retu_info["Status"]["Administrative state"]}    ${administrative_state}
    ...    msg=Current RETU administrative_state is not in ${administrative_state} status    ignore_case=${True}
    Should Be Equal As Strings    ${retu_info["Status"]["Availability status"]}    ${availability_status}
    ...    msg=Current RETU availability_status is not in ${availability_status} status    ignore_case=${True}
    Should Be Equal As Strings    ${retu_info["Status"]["Operational state"]}    ${operational_state}
    ...    msg=Current RETU operational_state is not in ${operational_state} status    ignore_case=${True}
    Should Be Equal As Strings    ${retu_info["Status"]["Procedural status"]}    ${procedural_status}
    ...    msg=Current RETU procedural_status is not in ${procedural_status} status    ignore_case=${True}

Check RAEU Status
    [Documentation]    Author: Wang Yixiang
    ...    Check RAE status(administrative_state, availability_status, operational_state, procedural_status) by web UI
    [Arguments]    ${administrative_state}
    ...    ${availability_status}
    ...    ${operational_state}
    ...    ${procedural_status}
    ...    ${raeu_index}=1
    ...    ${download_dir}=${TS_CASE_LOG_PATH}
    ${raeu_info} =    Get RAEU Information via webUI    raeu_index=${raeu_index}    download_dir=${download_dir}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${raeu_info["Status"]["Administrative state"]}    ${administrative_state}
    ...    msg=Current RAEU administrative_state is not in ${administrative_state} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${raeu_info["Status"]["Availability status"]}    ${availability_status}
    ...    msg=Current RAEU availability_status is not in ${availability_status} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${raeu_info["Status"]["Operational state"]}    ${operational_state}
    ...    msg=Current RAEU operational_state is not in ${operational_state} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${raeu_info["Status"]["Procedural status"]}    ${procedural_status}
    ...    msg=Current RAEU procedural_status is not in ${procedural_status} status    ignore_case=${True}
