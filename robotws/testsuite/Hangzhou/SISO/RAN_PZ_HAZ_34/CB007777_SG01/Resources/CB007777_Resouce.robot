*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author
Resource     ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
*** Variables ***
${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

*** Keywords ***
General_SiSo_Power_Meter_counter_update_for_energy_consumption
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the case is to check Power Meter counter update for energy consumption.
    set suite variable      ${mrbtsID}      ${tl.gnbs[0].instance_id}
    set suite variable      ${nrbtsID}      ${tl.gnbs[0].global_bts_id}
    ${stream}    get stream from version    version=${Active_SW_version}
    ${stream}    Set variable if    '${stream}'=='SBTS00'    SBTS22R4    ${stream}
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled    abbr=actPowerMeter    new_value=true
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS Energy Consumption    abbr=mtBtsEnergyMonitoring    new_value=15min
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS SM Energy Monitoring    abbr=mtSBTSSmEnergyMonitoring    new_value=15min
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS RFM energy monitoring    abbr=mtSBTSRfmEnergyMonitoring    new_value=15min
    sleep  1800
    Check M40002 Counter
    Check M40003 Counter
    Check M40004 Counter
    Check M4000X Counter internal relationship
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled    abbr=actPowerMeter    new_value=false
    sleep  60
    Wait until keyword succeeds    1min    20s    Check M40002 Counter Not Work
    Wait until keyword succeeds    1min    20s    Check M40003 Counter Not Work
    Wait until keyword succeeds    1min    20s    Check M40004 Counter Not Work
    [Teardown]  Selenium Logout And Close Browser

#COMMON SISO SETUP AND TEARDOWM
SISO Suite Setup
    log to console    \n***SISO Coam Suite Setup***
    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
    ...    ELSE     UTECloud.AdaptCommissionFiles
    TestSuite.Start
    #set suite variable    ${testline_scf}   ${CurrentStreamSCF}
    Run Keyword If    '${testline_name}'=='7_5_UTE5G402T211'    Commission    ${CFGFILE_PATH}/SCF_CB007777.xml
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    #${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${testline_scf}
    #log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    #set suite variable  ${mrbtsID}
    #set suite variable  ${nrbtsID}

SISO Suite Teardown
    log to console    \n***SISO Coam Suite Teardown***

SISO Test Setup
    log to console    \n***SISO Coam Test Setup***
    log to console    Active_SW_version:${Active_SW_version}
    robot_common_operations.Common Case Setup
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}    Fail    TEST
    Run Keyword And Ignore Error    selenium.close_browser

SISO Test Teardown
    log to console    \n***SISO Coam Test Teardown***
    Connect to gnb coam via ssl
    COAM Teardown gnb connections
#    CI_interface.Common Case Teardown
    TestCase.Stop

Commission
    [Arguments]    ${scf_file}=${testline_scf}
    COAM_Admin.commission    scf_file=${scf_file}
    wait until keyword succeeds   10x   2min  COAM_Admin.VerifyCellOnAir
