*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/verdicts.robot
Library     ../resources/extractor.py
Library     SSHLibrary
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot


*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  1200
${FID_6504_active}  ${False}
${ip_MSM}    192.168.255.129
${password_MSM}    oZPS0POrRieRtu
${user_name_MSM}    toor4nsn
${trigger_FID6504_MSM}    cd /ffs/run/logs; fallocate -l 990M test.txt     #set variable for trigger FID 6504
${trigger_FID6504_MSM_ASOG_ASOH}    cd /ffs/run/logs; fallocate -l 1990M test.txt     #set variable for trigger FID 6504
${check_trigger_FID6504}    ls -la /ffs/run/logs | grep test.txt    # variable check if trigger file is created successfully
${cancel_6504_MSM}    cd /ffs/run/logs; rm test.txt    #set variable for cancel FID 6504

*** Keywords ***
TC__LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25126
    ...  ******************
    ...  Author: Stepan Radysh
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 30.03.23 - TAT-25126 - TC created, version 1.0
    ...  - 20.04.2023 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 26.06.2024 -  Moldovan Dan    CB00969 - adding ASOH /ASOH case
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This Test Case check if FID 6504 is available, with proper information in Web-EM (REQ BTS_E2E_TRBL_907),
    ...  after exceeding the quota under folder /ff/run/logs in supported HW
    ...  (list of supported HW is specified in requirement BTS_E2E_TRBL_870.)
    ...  Supported HW: ASIB(A102 and newest HW variants), ASIL, ASOE, ASIM.
    ...  *******************
    ...  Test case flowchart: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...  LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.png
    ...  *******************

    Set Tags    CA-LOGS    OWNER-stepan.radysh@okia.com    AUTHOR-stepan.radysh@okia.com
    ...    MAINTAINER-stepan.radysh@okia.com    GROUP_IN_CHARGE-WRO_6_Vrf
    ...    PHASE-CRT    SW-SBTS23R2    FEATURE-CB008390-A
      Step 0: Preconditions
      Step 1: Trigger FID:6504
      Step 2: Check FID:6504 in WebEm
      Step 3: Collect Snapshot
      Step 4: Report is available in Snapshot


Step 0: Preconditions
    [Documentation]
    ...  Settting variables for connecting to BTS via SSH
    ...  Setting variables for execute commands via SSH

    Log    \nStep 0: Preconditions   console=${True}
    Set Test Variable  ${IP}  192.168.255.129
    Set Test Variable  ${CHECK_PREMISSION_CONTROL}  ls -la /ffs/run/ | grep logs
    Set Test Variable  ${PASSWORD}  oZPS0POrRieRtu
    Set Test Variable  ${USER_NAME}  toor4nsn
    Decide if MSM is ASOH ASOG for setting variables


Step 1: Trigger FID:6504
    [Documentation]
    ...    connect via SSH to MSM and create file for exceed the quota on folder ffs/run/logs

    Log    \nStep 1: Trigger FID:6504  console=${True}
    SSHLibrary.Open Connection    ${ip_MSM}
    SSHLibrary.Login    ${user_name_MSM}    ${password_MSM}
    SSHLibrary.Execute Command    ${trigger_FID6504_MSM}
    ${print_trigger_FID6504}    SSHLibrary.Execute Command    ${check_trigger_FID6504}
    Set Test Variable  ${FID_6504_active}  ${True}
    ${isEmpty}  Get length  ${print_trigger_FID6504}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  File ${print_trigger_FID6504} not created.  ${TRUE}
    ...  ELSE  Log  File ${print_trigger_FID6504} was created successfully.    console=${True}


Step 2: Check FID:6504 in WebEm
    [Documentation]
    ...    Check if FID 6504 is available in WebEm

    Log    \Step 2: Check FID:6504 in WebEm    console=${True}
    Log  Wait up to 15 min in order to check if alarm 6504 raised.  console=${True}
    ${expected_fault}=  Create Dictionary  faultId=6504
    ${expected_fault}=  Create List  ${expected_fault}
    ${status}=  Run keyword and return status  Wait Until Keyword Succeeds  15 min  30 sec
    ...  bts_states.Check Active Alarms  print_alarms=${False}  expected_patterns=${expected_fault}
    Run keyword unless  ${status}  Fail  Fault 6504 was not received.
    Log  Fault 6504 is reported  console=${True}


Step 3: Collect Snapshot
    [Documentation]
    ...    This step check if Snapshot collected successfully

    Log    \Step 3: Collect Snapshot   console=${True}
    @{time}=    Get Time    year month day hour min
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS Files}/Snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Collecting Snapshot Succeeded  ${time}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}


Step 4: Report is available in Snapshot
    [Documentation]
    ...    Check if report snapshot_ssdLogsDiskDump.csv.xz is available in Snapshot

    Log    \Step 4: Report is available in Snapshot   console=${True}
    ${found_file_dict}  snapshot.Get Data From Snapshot  ${snapshot_path}
    ${ssd_report}=    Set Variable    snapshot_ssdLogsDiskDump.csv.xz
    ${found_ssd_report}    Get Match Count    ${found_file_dict}   ${ssd_report}
    Run Keyword If  ${found_ssd_report}>0  Log    Report ${ssd_report} is available in Snapshot    console=${TRUE}
    ...  ELSE  verdicts.Set Test Failed  Report ${ssd_report} is not available in Snapshot     ${TRUE}

Decide if MSM is ASOH ASOG for setting variables
    [Documentation]    Sets variables which depend on variant of master SM
    ${sm_variant}=    Get SM variant
    Run Keyword If   '${sm_variant}' == 'ASOH AirScale Core' or '${sm_variant}' == 'ASOG AirScale Core'
                   ...    Case ASOG and ASOH
            ...    ELSE   log to console   trigger_FID6504_MSM unchanged

Case ASOG and ASOH
    [Documentation]    Sets variables for ASOH
    Set Test Variable  ${trigger_FID6504_MSM}    ${trigger_FID6504_MSM_ASOG_ASOH}

Get SM variant
 	[Documentation]
    ...  Return list of System Module variants in use. First is primary core, second (if exist) - secondary core
    ...
    ...  | **Author:** iuliia.taupeka@nokia.com
    ...
	${sm_variant}=  Create list
	${sm_variant_list}=  infomodel.Get SM variant with full name
	FOR  ${sm}  IN  @{sm_variant_list}
	    ${match}  ${group}=  Should match regexp  ${sm}  (ASIB|ASOE|ASIL|ASIM|ASOF AirScale Core|ASOH AirScale Core|ASOG AirScale Core)
	    Append To List  ${sm_variant}  ${match}
	END
	[Return]  ${sm_variant[0]}

Collecting Snapshot Succeeded
    [Arguments]    ${time}
    Log    Collecting snapshot via admin succeeded    console=yes
    Set Test Variable    ${snapshot_path}    ${BTS Files}/Snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip

Custom Test Teardown
    [Documentation]
    ...    delete file test.txt from /ffs/run/logs
    ...    Check if FID 6504 is canceled from WebEm

    Run Keyword If    ${FID_6504_active}    Run Keywords
    ...  Log    Cancel FID 6504    console=${True}
    ...  AND  Log  Delete file test.txt from /ffs/run/logs.  console=${True}
    ...  AND  SSHLibrary.Execute Command  ${cancel_6504_MSM}
    ...  AND  SSHLibrary.Close Connection
    ...  AND  Log  Wait up to 15 min in order to check if alarm 6504 is canceled.  console=${True}
    ...  AND  Wait Until Keyword Succeeds    15min    10s    coam.Assert alarm inactive    faultId=6504, severity=Minor
    ...  AND  Log  Fault 6504 is cleared in WebEm  console=${True}
    ...  AND  Set Test Variable  ${FID_6504_active}  ${False}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Custom Test Teardown
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
