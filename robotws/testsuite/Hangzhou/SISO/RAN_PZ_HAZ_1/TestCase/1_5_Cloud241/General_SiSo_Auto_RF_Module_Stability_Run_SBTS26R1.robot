*** Settings ***
Documentation    Suite description
...    Author: deli.wang@nokia.com
...    Maintainer: Author

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Variables    ./env.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Library   taf.selenium.sbts    WITH NAME    selenium_coam

Force Tags    CLOUD_4G_5G_CLASSICAL_ASIB_ABIO_AEHC_CLOUD241    CA_RAN_PZ_HAZ_1    CA_4G_SISOPZ    SBTS26R1    RAN_4G    RAN_4G_TDD    CRT

Test Timeout    73h
*** Variables ***
&{CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS26R1}=    HW_ID=ABIP    ONAIR_TIME=20 min    site_mode=5G

${INIT_CONFIG_ID}=     CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS26R1

${GLO_TL_DESCRIPTOR_FILE_PATH}=    ${CURDIR}/TLdescriptor.xml

${TOP50}    True

${GLO_SCOUT_TESTLINE_NAME}    1_5_Cloud241_1

${times}   5


*** Test Cases ***

[1][1.0] General_SiSo_Auto_RF_Module_Stability_Run
    [Tags]    QC_252172    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_Module_Stability
    ...    config_id=CLOUD_RF_CRT2_UTE4G152_AEHC_TMO_SBTS26R1
    [Timeout]    72h
    FOR    ${time}    IN RANGE    1    ${times}+1
            Log to console    \n---------------------\nstability run: ${time}/${times}
            Common_SiSo_State Management_Block & Unblock cell_Then_ RF lock & unlock
	        RF Diagnostic Test Setup and start
	        Check General Test Information
   END
    [Teardown]    Testcase Basic Postcondition

*** Keywords ***
Common_SiSo_State Management_Block & Unblock cell_Then_ RF lock & unlock
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
    END
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
         ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
         Lock RU   ${btsId}
         Wait Until Keyword Succeeds    5min    10 sec    coam.assert any    class_name=RMOD    parameters=operationalState=regex"(?i)Enabled"
         ...    timeout=600s    alias=${CASE_NAME}_${bts_id}
         Unlock RU   ${btsId}
    END
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
    END
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms    additional_allowed_alarms=Cell blocked
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

RF Diagnostic Test Setup and start
    [Arguments]    ${bts_thresholds}=${None}     ${bands_thresholds}=${None}
	Log To Console    \n *** ssh ***
    selenium_coam.enable_virtual_display
	selenium_coam.login   https://192.168.255.129    Nemuadmin    nemuuser
    Log To Console    \n *** RF Diagnostic Test Setup ***
    selenium_coam.configure_rf_diagnostic_test      cell=All NR cells     bts_thresholds=${bts_thresholds}
    ...    bands_thresholds=${bands_thresholds}     technology=NR
    selenium_coam.start_rf_diagnostic_test    timeout=100

Check General Test Information
    [Arguments]    ${cell_id}=1    ${forward_expected_result}=Pass    ${reverse_expected_result}=Pass
    ...    ${expected_outcome}=Pass    ${expected_low}=-2     ${expected_high}=120
    ${general_result}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    FOR    ${item}    IN    @{general_result}
        ${start_time}    get from dictionary    ${item}    BTS test start time GMT +0800
        ${stop_time}    get from dictionary    ${item}    BTS test stop time GMT +0800
        ${start_time_value}    split string    ${start_time}    ${SPACE}
        ${stop_time_value}    split string    ${stop_time}    ${SPACE}
        ${time_differ}    robot.libraries.DateTime.subtract_time_from_time    ${stop_time_value}[-1]    ${start_time_value}[-1]
        should be true    ${time_differ} < ${30.0}
        ${forward_result}    get from dictionary    ${item}    Forward test disposition
        should be equal    ${forward_result}    ${forward_expected_result}
        ${reverse_result}    get from dictionary    ${item}    Reverse test disposition
        should be equal    ${reverse_result}    ${reverse_expected_result}
        ${outcome}    get from dictionary    ${item}    Outcome
        should be equal    ${outcome}    ${expected_outcome}
        ${result}    get from dictionary    ${item}   Result
        should be equal    ${result}    success
        ${value_forward_expected}   get from dictionary    ${item}   Forward expected transmit RF power
        should be true    ${expected_low} < ${value_forward_expected} < ${expected_high}
    END
    selenium_coam.logout
    selenium_coam.disable_virtual_display
