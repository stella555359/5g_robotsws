*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Library       testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/rf_diagnostic_test.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***

*** Keywords ***
General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to verify that RF diagnostic test can be run by WebEM and test
    ...    result can be gotten successfully in BTS.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.05.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}    ${SINR_low}=${0}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${port_type}  COAM get ru port type
    Delete RFTHLD If Exist
    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Modify actRemoteRfDiag Parameter
    Set default value for RFTHLD If Feature 956 Enabled
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=300M
    ...    protocol=udp    duration=600    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M
    ...    protocol=udp    duration=600    ue_index=${ue_index}
    sleep   5min
    ${stream}    get stream from version    ${Active_SW_version}
    RF Diagnostic Test Setup
    sleep  30
    Check Detailed Antenna    stream=${stream}    SINR_low=${SINR_low}
    Run Keyword If  '${port_type}'!='PHYANT'    Check VSWR With L3 Call
    Check General Test Information    stream=${stream}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    [Teardown]  selenium logout and close browser
