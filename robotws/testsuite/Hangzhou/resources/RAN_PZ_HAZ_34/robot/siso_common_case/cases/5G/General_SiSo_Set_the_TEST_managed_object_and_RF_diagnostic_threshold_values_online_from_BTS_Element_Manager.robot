*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/rf_diagnostic_test.robot
*** Variables ***

*** Keywords ***
General_SiSo_Set_the_TEST_managed_object_and_RF_diagnostic_threshold_values_online_from_BTS_Element_Manager
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to set the TEST managed object and/or RF diagnostic threshold values
    ...    online from BTS Element Manager.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.04.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Delete RFTHLD If Exist
    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Modify actRemoteRfDiag Parameter
    Set default value for RFTHLD If Feature 956 Enabled
    log to console   \nOut of min RFTHLD value
    Verify value for RFTHLD If Feature 956 Enabled    totalRFPowerHighThreshold=${0}    totalRFPowerLowThreshold=${0}
    ...    rFPowerErrorHighThreshold=${1}    rFPowerErrorLowThreshold=${-9}    rxAntennaRSSIHighThreshold=${-181}
    ...    rxAntennaRSSILowThreshold=${-181}    rxAntennaRTWPHighThreshold=${-181}    rxAntennaRTWPLowThreshold=${-181}
    ...    txAntennaVSWRHighThreshold=${0}
    log to console   \nOut of max RFTHLD value
    Verify value for RFTHLD If Feature 956 Enabled    totalRFPowerHighThreshold=${151}    totalRFPowerLowThreshold=${151}
    ...    rFPowerErrorHighThreshold=${9}    rFPowerErrorLowThreshold=${-1}    rxAntennaRSSIHighThreshold=${1}
    ...    rxAntennaRSSILowThreshold=${1}    rxAntennaRTWPHighThreshold=${1}    rxAntennaRTWPLowThreshold=${1}
    ...    txAntennaVSWRHighThreshold=${11}
    [Teardown]    Run keywords    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'
    ...    Modify actRemoteRfDiag Parameter  actRemoteRfDiag=false    AND   Selenium Logout And Close Browser
