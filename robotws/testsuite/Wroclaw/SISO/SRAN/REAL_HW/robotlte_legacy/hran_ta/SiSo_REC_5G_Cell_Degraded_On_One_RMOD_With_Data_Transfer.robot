*** Settings ***
Documentation   The purpose of this test case is to verify that data transfer is decreased after cell degraded.
...    Author:        daniel.bartkowiak@nokia.com
...    Maintainer:    Daniel Bartkowiak

Resource     resources/ca_recovery.robot
Resource     resources/ca_BSSM_Ssh_telnet_connection_to_Rmod.robot
Resource      ../../Resources/SiSo_L3_call.robot

*** Variables ***
${RMOD_SN}        ${EMPTY}              # RU serial number
${PIPE_NUMBER}    ${EMPTY}              # RU antena number
${node}           default               # Alias used in TC
@{SELECTED_CELLS}             # define list of nrCellIdentity ex. <nrCellIdentity_1>
${CELLS_YAML_PATH}            # define cells yaml file path

*** Keywords ***
TC__SiSo_REC_5G_Cell_Degraded_On_One_RMOD_With_Data_Transfer
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-17275
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check whether data transfer is available on degraded LTE cell or not.
    ...  Only cells from selected RMOD are going to be tested.
    ...  Antenaline from selected RMOD is interrupted by generating fault 1907.
    ...  Test is supporting only OBSAI RMODS. 'sendFault' command is used.
    ...
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.02.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-17275 - Initial creation
    ...  - 20.10.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-38999 - TC adaptation for L3 call proxy solution

    Set Tags    CA-REC    OWNER-daniel.bartkowiak@nokia.com    AUTHOR-daniel.bartkowiak@nokia.com
    ...    MAINTAINER-daniel.bartkowiak@nokia.com    PHASE-CRT
    ...    FEATURE-CB007184
  Common Test Setup
  Logging With Timestamp
  ...  message=TC__SiSo_REC_5G_Cell_Degraded_On_One_RMOD_With_Data_Transfer will be executed
  ...  style=ONGOING

    step1: One RMOD 5G Preconditions
    step2: Send Fault On RMOD 5G
    step3: Degraded 5G Cell Data Transfer
    step4: RMOD Recovery 5G

    [Teardown]  Run Keywords  Log to console  TC finished. Result = ${KEYWORD STATUS}
    ...  AND  Set Suite Variable  ${KEYWORD STATUS}
    ...  AND  Run Keyword If  "${KEYWORD STATUS}"=="FAIL" and ${IS_RECOVERY_NEEDED}
    ...  admin.Reset Unit  ${TESTED_RMOD}  timeout=180  connection=${node}
    ...  AND  Common Test Teardown

step1: One RMOD 5G Preconditions
    Log to console  ---------------------------------------
    Log to console  step1: One RMOD 5G Preconditions
    Log to console  ---------------------------------------${\n}
    Set Test Variable  ${IS_RECOVERY_NEEDED}  ${FALSE}
    Should Not Be Empty  ${RMOD_SN}  msg=Please provide RMOD SN
    Should Not Be Empty  ${PIPE_NUMBER}  msg=Please provide anetena number
    Set Test Variable  ${node}  ${cfg['RF_INFO']['${RMOD_SN}']['btsid']}
    ${TESTED_RMOD}=   Get RU DistName For Serial Number  rmod_sn=${RMOD_SN}  alias=${node}
    ${TESTED_CELLS}=  Find Cells By Antena  ${TESTED_RMOD}  ${PIPE_NUMBER}  connection=${node}

    ${gncel_list}=    admin.Get Ids For All    GNCEL    connection=${node}
    ${wncel_list}=    admin.Get Ids For All    WNCEL    connection=${node}
    ${lncel_list}=    admin.Get Ids For All    LNCEL  search_for_iot_cells=${True}  connection=${node}
    ${nrcel_list}=    admin.Get Ids For All    NRCEL    connection=${node}
    ${rmod_list}=     admin.Get Ids For All    RMOD     connection=${node}
    ${smod_list}=     admin.Get Ids For All    SMOD     connection=${node}
    ${bbmod_list}=    admin.Get Ids For All    BBMOD    connection=${node}
    ${BTS_COMPONENTS}=  Combine Lists  ${gncel_list}  ${wncel_list}  ${lncel_list}  ${nrcel_list}
    ...  ${rmod_list}  ${smod_list}  ${bbmod_list}
    Remove Values From List  ${BTS_COMPONENTS}  ${TESTED_RMOD}
    FOR  ${cell}  IN  @{TESTED_CELLS}
      Remove Values From List  ${BTS_COMPONENTS}  ${cell}
    END

    Set Test Variable  ${BTS_COMPONENTS}
    Set Test Variable  ${TESTED_RMOD}
    Set Test Variable  ${TESTED_CELLS}
    Log  TC preconditions finieshed successfuly  console=${TRUE}

step2: Send Fault On RMOD 5G
    Log to console  ------------------------------
    Log to console  step2: Send Fault On RMOD 5G
    Log to console  ------------------------------${\n}
    Send Fault 1907 OBSAI 5G  active
    admin.Assert Alarm Active  faultId=1907, serialNo=${RMOD_SN}  timeout=60  connection=${node}
    admin.Assert Alarm Active  faultId=4003  timeout=30  connection=${node}
    Append To List  ${GLO_ADMIN_ALLOWED_ALARMS}  faultId=1907, serialNo=${RMOD_SN}  faultId=4003
    Verify Alarms On All Nodes
    Wait Until Keyword Succeeds  120s  10s  Check If Tested Cells Degraded  ${TESTED_CELLS}  connection=${node}
    Log  Following cells are correctly degraded:${\n}${TESTED_CELLS}  console=${TRUE}

step3: Degraded 5G Cell Data Transfer
    Log to console  ---------------------------------------
    Log to console  step3: Degraded 5G Cell Data Transfer
    Log to console  ---------------------------------------${\n}
    SiSo Convert Id to Runtime Distname  connection=any
    Set Test Variable  ${LOGS_DIR}  ${cfg.test_logs_path}
    SiSo L3 Call

step4: RMOD Recovery 5G
    Log to console  ---------------------------------------
    Log to console  step4: RMOD Recovery 5G
    Log to console  ---------------------------------------${\n}
    Send Fault 1907 OBSAI 5G  clear
    admin.Assert Alarm Inactive  faultId=1907  timeout=60  connection=${node}
    admin.Assert Alarm Inactive  faultId=4003  timeout=60  connection=${node}
    Wait Until Keyword Succeeds  120s  10s  Check If All Cells Are OnAir  alias=${node}
    Remove Values From List  ${GLO_ADMIN_ALLOWED_ALARMS}  faultId=1907, serialNo=${RMOD_SN}  faultId=4003
    Verify Alarms On All Nodes
    admin.Collect Infomodel Log From Current Session  target_file_name=${cfg.test_logs_path}/ims_for_cells_check.ims2  connection=${node}
    Check If BTS Components Were Unchanged  ${cfg.test_logs_path}/ims_for_cells_check.ims2  ${BTS_COMPONENTS}

Send Fault 1907 OBSAI 5G
    [Arguments]  ${alarm_status}
    Open Connection To Radio Module With Serial Number  ${RMOD_SN}  ${node}
    Run Keyword If  '${alarm_status}'=='active'  sshLibrary.Write  sendFault 1116 ${PIPE_NUMBER} 0 0 0 0
    Run Keyword If  '${alarm_status}'=='clear'   sshLibrary.Write  sendFault 1116 ${PIPE_NUMBER} 0 1 0 0
    Sleep  3s  Timeout for command execution
    Log  Command on RMOD executed  console=${TRUE}
    Set Test Variable  ${IS_RECOVERY_NEEDED}  ${TRUE}
    [Teardown]  SSHLibrary.Close All Connections
