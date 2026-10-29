*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/diagnostic_check.robot
Library     DateTime
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${STARTUP_TIMEOUT}  10  # Timeout value in minutes after startup for all modules to reach working state.


*** Keywords ***
TC__LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25765
    ...  ******************
    ...  Author: Iuliia Taupeka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2023-07-10 - TC created. version 1.0
    ...  - 2024-03-20 - change coam.Run Diagnostic Check timeout in accordance to updated req OM_GEN_SFS_PERF_CAP.10677
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This TC is to verify that Diagnostic Check checks whether configuration file exists on active partition and
    ...  it can be triggered from WebEM GUI.
    ...  It is verified that proper fault (4681) with proper severity (Minor) is raised on BTS.
    ...  It also verifies that Diagnostic Check Error fault can be canceled after condition disappeared on BTS.
    ...  *******************
    ...  Test case flowchart: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/
    ...  LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-joanna.wolnicka@nokia.com    AUTHOR-iuliia.taupeka@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com     PHASE-CRT    SW-SBTS23R4    FEATURE-CB010239-A

    Step 1: Delete File model_5_ims2 On Active Partition And Run Diagnostic Check
    Step 2: Check If Alarm 4681 Is Present
    Step 3: Get DC report and check content
    Step 4: Restore File model_5_ims2 On Active Partition And Run Diagnostic Check


Step 1: Delete File model_5_ims2 On Active Partition And Run Diagnostic Check
    [Documentation]
    ...  In this step test:
    ...  - removes model_5.ims2 file from active partition;
    ...  - runs full Diagnostic Check triggered by WebEM.

    Log  \nStep 1: Diagnostic Check triggered by WebEM GUI raises minor fault of missing model_5.ims2 file on active partition.  console=${True}
	Log    Checking that model_ims2 file exists on BTS.    console=${True}
	SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${model_5_presence_active_part}    Run Keyword and Return Status    SSHLibrary.File Should Exist    /ffs/run/config/model_5.ims2
    Run Keyword Unless  ${model_5_presence_active_part}
    ...  verdicts.Set Test Failed  Fail: Check why model_5.ims is missing on BTS active partition, BTS must be commissioned to pass the test.  ${TRUE}

    Log  Copy file model_5.ims 2 to BTS_Files   console=${True}
    SSHLibrary.Get File  /rom/config/model_5.ims2  ${BTS_Files}/
    Log  Delete model_5.ims2 file from BTSs active partition.  console=${True}
    SSHLibrary.Execute Command    rm /rom/config/model_5.ims2
    SSHLibrary.Close Connection

    ${DC1_run_date}  DateTime.Get Current Date  exclude_millis=True  result_format=%Y-%m-%d %H:%M:%S
    Log    Timestamp before DC Start: ${DC1_run_date}. Sleep for 10s and run Diagnostic Check.    console=${True}
    ${DC1_run_date}  Replace String  ${DC1_run_date}  ${SPACE}  T
    Set Test Variable    ${DC1_run_date}
    Sleep    10s
    ${DC1_result} =    coam.Run Diagnostic Check  timeout=930
    Log    Diagnostic Check finished. [OK]    console=${True}

Step 2: Check If Alarm 4681 Is Present
    [Documentation]
    ...  In this step test verifies that minor fault (4681) of missing model_5.ims2 on active partition is raised on BTS.
    Log  \nStep 2: Check If Alarm 4681 Is Present.    console=${True}

    ${fault_status}  Run keyword and return status  Wait until keyword succeeds  120  10
    ...  coam.Assert Alarm Active  parameters=alarmId=7115, faultId=4681, faultName="Diagnostic Check Error", severity=Minor  timeout=120
    Run keyword if  ${fault_status}
    ...  Log  WebEM: Fault 4681 "Diagnostic Check Error" is active on BTS. [OK]  console=${True}
    ...  ELSE  Set Test Failed  WebEM: Fault 4681 "Diagnostic Check Error" is not active on BTS. [NOK]

Step 3: Get DC report and check content
    [Documentation]
    ...  In this step test gets Diagnostic Check report. From report is returned checkpoint 1 (Configuration file presence on the active partition)
    ...  and under CP 1 checked:
    ...  - timestamp - should be correct;
    ...  - lastResult - should be NOK.

    Log  \nStep 3: Get DC report and check content.   console=${True}
    ${report_status}  coam.Get Diagnostic Report
    ${found_checkpoint}=
    ...    diagnostic_check.Get Single Checkpoint Results By CP Name    ${report_status}    Configuration file presence on the active partition
    Log    Found checkpoint: ${found_checkpoint}. CP1 content will be verified.    console=${True}
    diagnostic_check.Verify Checkpoints Timestamp    ${found_checkpoint}    ${DC1_run_date}
    diagnostic_check.Verify CP Status    ${found_checkpoint}    NOK

Step 4: Restore File model_5_ims2 On Active Partition And Run Diagnostic Check
    [Documentation]
    ...  In this step test:
    ...  - restores model_5.ims2 file on active partition;
    ...  - runs full Diagnostic Check triggered by WebEM and verifies that fault 4681 disappeared.

    Log  \nStep 4: Restore File model_5_ims2 On Active Partition And Run Diagnostic Check.   console=${True}
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Put File      ${BTS_Files}/model_5.ims2    /rom/config    mode=0640
    SSHLibrary.Execute Command    chown btssw.btssw /rom/config/model_5.ims2
    SSHLibrary.Close Connection

	${DC2_run_date}  DateTime.Get Current Date  exclude_millis=True  result_format=%Y-%m-%d %H:%M:%S
    Log    Timestamp before DC Start: ${DC2_run_date}. Sleep for 5s and run Diagnostic Check.    console=${True}
    ${DC2_run_date}  Replace String  ${DC2_run_date}  ${SPACE}  T
    Set Test Variable    ${DC2_run_date}
    Sleep    5s
    ${DC2_result} =    coam.Run Diagnostic Check  timeout=930
    Log    Diagnostic Check finished. [OK]    console=${True}
    Sleep    31s

    ${inactive_fault_status}  Run keyword and return status  Wait until keyword succeeds  120  10
    ...  coam.Assert Alarm Inactive  parameters=alarmId=7115, faultId=4681, faultName="Diagnostic Check Error"  timeout=120
    Run keyword if  ${inactive_fault_status}
    ...  Log  WebEM: Fault 4681 "Diagnostic Check Error" is inactive on BTS. [OK]  console=${True}
    ...  ELSE  Set test failed  WebEM: Fault 4681 "Diagnostic Check Error" is active on BTS. [NOK]

    ${second_connection}  coam.Connect To  name=dc_connection
    ${report2_status}  coam.Get Diagnostic Report    connection=dc_connection
    ${found_checkpoint_2}=
    ...    diagnostic_check.Get Single Checkpoint Results By CP Name    ${report2_status}    Configuration file presence on the active partition
    Log    Found checkpoint: ${found_checkpoint_2}. CP1 content will be verified.    console=${True}
    diagnostic_check.Verify Checkpoints Timestamp    ${found_checkpoint_2}    ${DC2_run_date}
    diagnostic_check.Verify CP Status    ${found_checkpoint_2}    OK



TC Setup
    Common Test Setup    scf_check=${FALSE}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
