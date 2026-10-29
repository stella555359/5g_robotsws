*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ald_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
*** Variables ***

*** Keywords ***
General_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check faulty notification recovery action indication
    ...     and visualization.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.03.2020 https://jiradc.int.net.nokia.com/browse/WESTLAKE- - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ald_type}=RAEU
    SISO ALD Test Setup
    log to console   \n disable HDLC communication
    Modify ALD HDLC Parameter    hdlc_flag=false
    sleep  20
    log to console   \n Check fault 4142 Appear On WebUI
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=4142
    log to console   \n disable DC voltage
    Modify ALD DC Voltage Parameter    dcvoltage_flag=false
    sleep  20
    log to console   \n Check fault 4141 Appear On WebUI
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=4141
    log to console   \n enable HDLC communication
    Modify ALD HDLC Parameter    hdlc_flag=true
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4142
    log to console   \n enable DC voltage
    Modify ALD DC Voltage Parameter    dcvoltage_flag=true
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4141
    log to console   \n Modfiy Antenna operating frequency band value to 99
    Modify ALD antFreqBand Parameter    antFreqBand_value=99    ald_type=${ald_type}
    sleep  20
    log to console   \n Check fault 4282 Appear On WebUI
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=4282
    log to console   \n Modfiy Antenna operating frequency band value to 1
    Modify ALD antFreqBand Parameter    antFreqBand_value=1    ald_type=${ald_type}
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4282
    [Teardown]    run keywords    SISO ALD ENV Recover    AND    COAM Teardown gnb connections
