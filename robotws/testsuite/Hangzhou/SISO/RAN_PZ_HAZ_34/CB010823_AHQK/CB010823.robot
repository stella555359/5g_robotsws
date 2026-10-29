*** Settings ***
Documentation     author: Chen Yin
...               contact: Yin.1.chen@nokia-sbell.com
...               squad group: SG_02
Force Tags        5G_SISO    CIT_TRUNK    COAM      AHQK      CB010823
...    PY36
Suite Setup          suite setup with environment setup      scf_path=SCF_10823.xml
Suite Teardown       suite setup with environment recovery      scf_path=9487_C_06.xml
Resource          Resources/CB010823_common_keywords.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002029-A/Resources/5GC002029_A_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Library           taf.selenium.sbts   WITH NAME   selenium_sbts
Library           testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010823_AHQK/Resources/Update_key_value.py
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot

*** Variables ***
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}    #Service account root access is enabled
&{fault_61649}             faultId=${61649}    #LMP access via port 443
@{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_4654}    &{fault_4655}      &{fault_61649}
@{WEBEM_RADIO_MODUDLES}    RMOD_R-1    RMOD_R-2
@{CLI_RADIO_MODUDLES}    MRBTS-226/EQM_R-1/APEQM_R-1/RMOD_R-1    MRBTS-226/EQM_R-1/APEQM_R-1/RMOD_R-2
@{POINT_40_WEBEM}    40 - RU SW package and NVM integrity
@{POINT_41_WEBEM}    41 - RU Memory usage
@{POINT_42_WEBEM}    42 - RU Temperature sensor
@{POINT_41_42_WEBEM}    40 - RU SW package and NVM integrity
...       41 - RU Memory usage    42 - RU Temperature sensor
&{CUSTOM_CHECK_41_42_WEBEM}    RMOD-1 / RMOD_R-1 (AHQK)=@{POINT_41_42_WEBEM}
...    RMOD-2 / RMOD_R-2 (AHQK)=@{POINT_41_42_WEBEM}


*** Test Cases ***
[1]CB010823_SR_A_01_Run_Full_Diagnostic_check_online_from_WebEM
    [Setup]    Test Case Setup
    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min
	sleep    10min
    COAM Navigate to login page via webUI
    ${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    set variable    ${full_diagnostic_report['RU diagnostic check report']}
    CheckRUReport    RUreport=${RUfullreport}    checkID=${41}    CheckPoint=RU Memory usage    TriggerType=Automatic
    CheckRUReport    RUreport=${RUfullreport}    checkID=${42}    CheckPoint=RU Temperature sensor    TriggerType=Automatic
	COAM selenium close browser
    COAM Navigate to login page via webUI
    selenium_sbts.start_diagnostic_check   scope=Full diagnostic check      allow_service_impact=${False}
    ${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    set variable    ${full_diagnostic_report['RU diagnostic check report']}
    CheckRUReport    RUreport=${RUfullreport}    checkID=${41}    CheckPoint=RU Memory usage    TriggerType=WebEM
    CheckRUReport    RUreport=${RUfullreport}    checkID=${42}    CheckPoint=RU Temperature sensor    TriggerType=WebEM
    selenium_sbts.start_diagnostic_check   scope=Full diagnostic check      allow_service_impact=${True}
    sleep   300s
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10 min    15 sec   COAM Check GNB cell on air
    COAM Navigate to login page via webUI
    ${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    set variable    ${full_diagnostic_report['RU diagnostic check report']}
    CheckRUReport    RUreport=${RUfullreport}    checkID=${41}    CheckPoint=RU Memory usage    TriggerType=WebEM
    CheckRUReport    RUreport=${RUfullreport}    checkID=${42}    CheckPoint=RU Temperature sensor    TriggerType=WebEM
    [Teardown]    Run keywords      COAM selenium close browser       AND      CB010823 Test case Teardown

[1]CB010823-SR-A_2_Run RF Diagnostic check online from WebEM
    [Setup]    Test Case Setup
    COAM Navigate to login page via webUI
    selenium_sbts.start_diagnostic_check   scope=Customized diagnostic check        radio_checkpoints=${CUSTOM_CHECK_41_42_WEBEM}
    sleep   60s
    ${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    set variable    ${full_diagnostic_report['RU diagnostic check report']}
    CheckRUReport    RUreport=${RUfullreport}    checkID=${41}    CheckPoint=RU Memory usage    TriggerType=WebEM
    CheckRUReport    RUreport=${RUfullreport}    checkID=${42}    CheckPoint=RU Temperature sensor    TriggerType=WebEM
    [Teardown]    Run keywords      COAM selenium logout       AND      CB010823 Test case Teardown

[1]CB010823-SR-A_3_Run FULL Diagnostic check from WebEM Remote tool
    [Setup]    Test Case Setup
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${diagnostic_result}    coam.run_diagnostic_check    connection=GNB_OAM
    CheckRUReport_CLI    RUreport=${diagnostic_result}    checkID=${41}    CheckPoint=RU Memory usage
    ...      TriggerType=WebEMRemoteTool      dist_Name=${CLI_RADIO_MODUDLES}
    CheckRUReport_CLI    RUreport=${diagnostic_result}    checkID=${42}    CheckPoint=RU Temperature sensor
    ...      TriggerType=WebEMRemoteTool      dist_Name=${CLI_RADIO_MODUDLES}
    [Teardown]    CB010823 Test case Teardown

[1]CB010823-SR-A_5_Check Diagnosctic Report
    [Documentation]    Trigger CP41 NOK case
    [Setup]    Test Case Setup
    Modify memoryTestThreshold in json file      memoryTestThreshold=10
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${diagnostic_result}    coam.run_diagnostic_check    connection=GNB_OAM
    CheckRUReport_CLI    RUreport=${diagnostic_result}    checkID=${41}    CheckPoint=RU Memory usage
    ...      TriggerType=WebEMRemoteTool      dist_Name=${CLI_RADIO_MODUDLES}      checking_status=NOK
    [Teardown]    Run keywords      Modify memoryTestThreshold in json file      memoryTestThreshold=100
    ...      AND      CB010823 Test case Teardown

[1]CB010823-SR-A_7_Check 4681 fault in NOK cases
    [Setup]    Test Case Setup
    Trigger CP42 NOK case
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${diagnostic_result}    coam.run_diagnostic_check    connection=GNB_OAM
    CheckRUReport_CLI    RUreport=${diagnostic_result}    checkID=${42}    CheckPoint=RU Memory usage
    ...      TriggerType=WebEMRemoteTool      dist_Name=${CLI_RADIO_MODUDLES}      checking_status=NOK
    [Teardown]    Run keywords      Clear FID1171      AND      CB010823 Test case Teardown

[1]CB010823-SR-A_9_Automatic Execution of Diagnostic check from webEM with cell onAir
    [Setup]    Test Case Setup
    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Login webEM
    sleep   60s
    ${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    set variable    ${full_diagnostic_report['RU diagnostic check report']}
    CheckRUReport    RUreport=${RUfullreport}    checkID=${41}    CheckPoint=RU Memory usage    TriggerType=Automatic
    CheckRUReport    RUreport=${RUfullreport}    checkID=${42}    CheckPoint=RU Temperature sensor    TriggerType=Automatic
    [Teardown]    CB010823 Test case Teardown
