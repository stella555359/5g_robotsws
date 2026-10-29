*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Library    taf.selenium.sbts  WITH NAME  selenium_coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_variables.py
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002510/Resources/TestCaseVariables.py

*** Keywords ***
Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call
    [Arguments]  ${ue_index}=${0}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${port_type}  COAM get ru port type
    Delete RFTHLD If Exist
    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Modify actRemoteRfDiag Parameter
    Set default value for RFTHLD If Feature 956 Enabled
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    run keyword if    '${ue_type}'=='mtk'
    ...                          Make_L3_Call_With_MTK_UE    wireshark_log_prefix=ue_attach_${attach_timestamp}
    ...                                                      ul_data_transfer=100M
    ...                                                      dl_data_transfer=300M
    ...    ELSE IF   '${ue_type}' == 'huawei_sigspark'       Make_L3_Call_With_spark_UE    wireshark_log_prefix=ue_attach_${attach_timestamp}
    ...                                                                                    ul_data_transfer=100M
    ...                                                                                    dl_data_transfer=300M
    ...    ELSE                Make_L3_Call_With_Power_UE    reset_sol=${none}
    ...                                                               4G_check=${False}
    ...                                                               ul_data_transfer=100M
    ...                                                               dl_data_transfer=300M
    ...                                                               throuput_duration=900
    sleep   5min
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    ${freqBandIndicatorNR}    get_freqbandindicatornr_via_admin
    ${freqBandIndicatorNR}    Convert to string    ${freqBandIndicatorNR}
    ${bands_thresholds_temp}    create list    ${freqBandIndicatorNR}    100    3
    ${bands_thresholds}    create list    ${bands_thresholds_temp}
    ${stream}    get stream from version    ${Active_SW_version}
    ${test_cell}=    Set Variable If
    ...     '${stream}'=='11.800'        All cells
    ...     All NR cells
	${bands_thresholds_input}=    Set Variable If
    ...     '${stream}'=='SBTS22R2'       ${bands_thresholds}
    ...     ${None}
    RF Diagnostic Test Setup    cell=${test_cell}    bands_thresholds=${bands_thresholds_input}
    sleep  30
    Run Keyword If    '${stream}'=='SBTS00'    Run Keyword And Continue On Failure    Check AEHC Detailed Antenna
    ...               ELSE                      Run Keyword And Continue On Failure    Check Detailed Antenna    stream=${stream}
    Run Keyword If  '${port_type}'!='PHYANT'    Check VSWR With L3 Call
    Check General Test Information    stream=${stream}
    [Teardown]    run keywords    Run Keyword And Ignore Error    selenium logout and close browser    AND
    ...                           Run Keyword And Ignore Error    Stop Traffic In Teardown

Initiate_RF_Statistics_diagnostic_test_withL3call
    [Arguments]  ${ue_index}=${0}    ${cell_id}=${1}    ${radio_id}=${1}
    ...    ${RF_temperature_high_threshold}=${90}    ${min_temperature}=-5    ${max_temperature}=90
    ...    ${rf_port_id}=2
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Delete RFTHLD If Exist
    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Modify actRemoteRfDiag Parameter
    Set default value for RFTHLD If Feature 956 Enabled
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    run keyword if    '${ue_type}'=='mtk'
    ...                          Make_L3_Call_With_MTK_UE    wireshark_log_prefix=ue_attach_${attach_timestamp}
    ...                                                      ul_data_transfer=100M
    ...                                                      dl_data_transfer=300M
    ...    ELSE IF   '${ue_type}' == 'huawei_sigspark'       Make_L3_Call_With_spark_UE    wireshark_log_prefix=ue_attach_${attach_timestamp}
    ...                                                                                    ul_data_transfer=100M
    ...                                                                                    dl_data_transfer=300M
    ...    ELSE                Make_L3_Call_With_Power_UE    reset_sol=${none}
    ...                                                      4G_check=${False}
    ...                                                      ul_data_transfer=100M
    ...                                                      dl_data_transfer=300M
    ...                                                      throuput_duration=900
    sleep   3min
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    ${bts_thresholds}    create dictionary    RF temperature high threshold=${RF_temperature_high_threshold}
    RF statistics diagnostic test setup    bts_thresholds=${bts_thresholds}    radio_id=${radio_id}
    sleep  30
    Check Statistics General Information    radio_id=${radio_id}
    Check RF Temperature Supervision    radio_id=${radio_id}    min_temperature=${min_temperature}
    ...    max_temperature=${max_temperature}
    Check RF Ethernet Packet Monitoring    radio_id=${radio_id}    rf_port_id=${rf_port_id}
    [Teardown]    run keywords    Run Keyword And Ignore Error    selenium logout and close browser    AND
    ...                           Run Keyword And Ignore Error    Stop Traffic In Teardown
