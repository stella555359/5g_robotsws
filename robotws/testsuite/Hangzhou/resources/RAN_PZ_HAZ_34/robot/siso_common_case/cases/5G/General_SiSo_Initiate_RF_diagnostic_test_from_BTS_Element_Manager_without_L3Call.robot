*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Library       testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/rf_diagnostic_test.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Variables ***

*** Keywords ***
General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_without_L3Call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to verify that RF diagnostic test can be run by WebEM and test
    ...    result can be gotten successfully in BTS.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.04.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]   ${low_RSSI}=${-140}    ${low_RTWP}=${-140}  ${RSSI_high}=${0}    &{kwargs}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Delete RFTHLD If Exist
    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Modify actRemoteRfDiag Parameter
    Set default value for RFTHLD If Feature 956 Enabled
    ${freqBandIndicatorNR}    get_freqbandindicatornr_via_admin
    ${freqBandIndicatorNR}    Convert to string    ${freqBandIndicatorNR}
    ${bands_thresholds_temp}    create list    ${freqBandIndicatorNR}    100    3
    ${bands_thresholds}    create list    ${bands_thresholds_temp}
    ${bts_thresholds}    create dictionary    Low RSSI threshold=${low_RSSI}    RTWP low threshold=${low_RTWP}
    ${stream}    get stream from version    ${Active_SW_version}
    ${bands_thresholds_input}    Set Variable If    '${cell_type}'=='nr'    ${None}    ${bands_thresholds}
    RF Diagnostic Test Setup    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds_input}
    sleep  30
    Check Detailed Antenna    RSSI_high=${RSSI_high}    stream=${stream}
    Check General Test Information    stream=${stream}
    [Teardown]  selenium logout and close browser
