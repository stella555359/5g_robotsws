*** Settings ***
Documentation
    ...  The purpose of this test case is to check if RawAlarmHistory file can be downloaded from BTS via
    ...  ADMIN CLI.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Admin_CLI_get_alarm_history_remote
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24622
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24622 - Initial TAT creation

    Set Tags  CA-FM  OWNER-denis.gruia@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Change ActCli Parameter To Be true
    Step2: Get RawAlarmHistory Via CLI On Port 443
    Step3: Get RawAlarmHistory Via CLI On Port 3600
    Step4: Get RawAlarmHistory With Insufficient Access Rights Via CLI On Port 443
    Step5: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step${id}: Get RawAlarmHistory Via CLI On Port ${port}
    [Documentation]  In this step it is checked if RawAlarmHistory can be collected via ADMIN CLI

    Log  \nStep${id}: Get RawAlarmHistory Via CLI On Port ${port}  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  port=${port}
    ${request}  Set Variable  {"requestId":221,"parameters":{"name":"getRawAlarmHistory"}}
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  output_file=${BTS_FILES}/Test_Step_${id}_alarmlist.txt
    File Should Not Be Empty  ${BTS_FILES}/Test_Step_${id}_alarmlist.txt  msg='${BTS_FILES}/Test_Step_${id}_alarmlist.txt' is empty
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}. [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}. [NOK]


Step4: Get RawAlarmHistory With Insufficient Access Rights Via CLI On Port ${port}
    [Documentation]  In this step it is checked if correct error code: 69 will be reported when RawAlarmHistory
    ...  file will have modified access rights and get RawAlarmHistory command will be executed Via ADMIN CLI

    Log  \nStep4: Get RawAlarmHistory With Insufficient Access Rights Via CLI On Port ${port}  console=true
    ssh.Connect To  ${SMOD1['IP']}  toor4nsn  oZPS0POrRieRtu  alias=change_file_rights
    ssh.Execute  chmod u-r /tmp/RawAlarmHistory.txt  connection=change_file_rights
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  port=${port}
    ${request}  Set Variable  {"requestId":221,"parameters":{"name":"getRawAlarmHistory"}}
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  output_file=${BTS_FILES}/Test_Step_4_alarmlist.txt
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 69
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}. [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}. [NOK]

    [Teardown]  Run Keywords
    ...  ssh.Execute  chmod u+r /tmp/RawAlarmHistory.txt  connection=change_file_rights
    ...  AND
    ...  ssh.Disconnect  connection=change_file_rights


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
