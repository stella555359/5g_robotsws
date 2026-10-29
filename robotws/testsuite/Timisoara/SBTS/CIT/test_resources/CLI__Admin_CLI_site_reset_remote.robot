*** Settings ***
Documentation
    ...  The purpose of this test case is check if site reset command via Admin command line is working.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SKIP_PARAMETER_RELATION_ERRORS}  True  # Parameter can be set as True or False -
# If you want to no ignore relation error please set this parameter as False
${ONAIR_VERIFICATION_TIMEOUT}  15  # Timeout for BTS to reach OnAir state after reset


*** Keywords ***
TC__CLI__Admin_CLI_site_reset_remote
    [Documentation]
    ...  [CASE LINK] https://jira3.int.net.nokia.com/browse/TAT-14516
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  16.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-14516 - test creation
    ...  19.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16914 - change method, which check if reset was performed
    ...  29.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17931 - the longer uptime was taken in to consideration (from 150 sec to 240 sec)
    ...  28.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18897 - extend wait time form ssh connection after site reset
    ...  13.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-19031 - add verification of BTS state after reset
    ...  04.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21983 - migration to TAF library
    ...  16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24946 - Replace hran_tools with taf.sw.ping
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/CLI__Admin_CLI_site_reset_remote.png

    Set Tags  CA-ALD  OWNER-artur.juszczak@nokia.com  AUTHOR-artur.juszczak@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CRT  SW-SBTS18  FEATURE-RP002070

    Precondition
    Test_Step.1 Perfom Site Reset Via CLI On Port 443
    Test_Step.2 Check If Site Reset Was Performed
    Test_Step.3 Perfom Site Reset Via CLI On Port 3600
    Test_Step.4 Check If Site Reset Was Performed


Precondition
    [Documentation]  Check if parameter actCli is set as "true" if not change it to "true"

    Log To Console  \n
    Log In Frame  Preconditions: Check and enable feature Admin Command Line
    Check If Admin CLI Feature Check Is Enabled  ${SKIP_PARAMETER_RELATION_ERRORS}


Test_Step.${n} Perfom Site Reset Via CLI On Port ${port}
    [Documentation]  Site Reset Via CLI On Port ${port}

    Log To Console  \n
    Log In Frame  Step ${n}: Site Reset Via CLI On Port ${port}
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  port=${port}
    BTS Site Reset Via CLI


BTS Site Reset Via CLI
    [Documentation]  Send reset command via Admin CLI, and check if response from CLI is 'completed'

    Log  Site Reset command sending via Admin CLI ...  console=true
    ${response}  Send Admin CLI Request
    ...  {"requestId":100,"parameters":{"name":"reset","parameters":{"waitForReconnection":true,"resetCoverage":"Site"}}}
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    Run Keyword If  '${request_status}' != 'completed'
    ...  Set Test Failed  message=Command sent with status: ${request_status}  fail_fast=True
    ...  ELSE
    ...  Log  Command sent with status: ${request_status}  console=true


Test_Step.${n} Check If Site Reset Was Performed
    [Documentation]  Check If Site Reset Was Performed

    Log To Console  \n
    Log In Frame  Step ${n}: Check If Site Reset Was Performed
    ${uptime}  Check Uptime
    Log  Uptime is (system working time on SM): ${uptime} sec  console=true
    Run Keyword IF  ${uptime} < 240
    ...  Log  Site Reset was performed  console=true
    ...  ELSE
    ...  Set Test Failed  message=Site Reset was not performed or reset was performed too long (above 4 min)  fail_fast=True

    Log  Wait for OnAir state after reset  console=true
    Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=180  max_downtime=180  timeout=1200
    Wait Until Keyword Succeeds  ${ONAIR_VERIFICATION_TIMEOUT}m  2m
    ...  Admin Check All Required State
    Sleep  60


Check Uptime
    [Documentation]  This keyword connect to system module via SSH and return time from last reset

    Wait Until Keyword Succeeds  2m  5s
    ...  SSHLibrary.Open Connection  ${SMOD1['IP']}
    Wait Until Keyword Succeeds  2m  5s
    ...  SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${ssh_command_uptime}  SSHLibrary.Execute Command  cut -f1 -d. /proc/uptime return_stdout=False
    ${uptime}  Convert To Number  ${ssh_command_uptime}
    [Teardown]  SSHLibrary.Close Connection
    [Return]  ${uptime}


TC Setup
    Common Test Setup  tc_name=CLI__Admin_CLI_site_reset_remote


TC Teardown
    Common Test Teardown
