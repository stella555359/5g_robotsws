*** Settings ***
Documentation
    ...  The purpose of this test case is to check if snapshot collection via ADMIN CLI is working.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SKIP_PARAMETER_RELATION_ERRORS}  True  # If you don't want to ignore relation errors, please set this parameter to False


*** Keywords ***
TC__CLI__Admin_CLI_get_snapshot_remote
    [Documentation]
    ...  [CASE LINK] https://jira3.int.net.nokia.com/browse/TAT-14487
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  07.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-14487 - initial creation
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/CLI__Admin_CLI_get_snapshot_remote.png#

    Set Tags  CA-ALD  OWNER-lukasz.targonski@nokia.com  AUTHOR-lukasz.targonski@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CRT  SW-SBTS18  SW-SBTS19  FEATURE-RP002070

    Test_Step.0 Test Preconditions
    Test_Step.1 Collect Snapshot Via CLI On Port 443
    Test_Step.2 Collect Snapshot Via CLI On Port 3600


Test_Step.0 Test Preconditions
    [Documentation]  Check if parameter actCli is set as "true" if not change it to "true"

    Log To Console  \n
    Log In Frame  Preconditions: Check and enable feature Admin Command Line
    Check If Admin CLI Feature Check Is Enabled  ${SKIP_PARAMETER_RELATION_ERRORS}


Test_Step.${n} Collect Snapshot Via CLI On Port ${port}
    [Documentation]  In this test step snapshot is going to be collected via ADMIN CLI

    Log To Console  \n
    Log In Frame  Test_Step.${n} Collect Snapshot Via CLI On Port ${port}
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  port=${port}
    ${request}  Set Variable  {"requestId":321,"parameters":{"name":"snapshot","parameters":{"coverage":"Full","force":"Yes","reason":"test"}}}
    ${request_status}  ${error_code}  CLI Send Request And Return Status And Error Code  ${request}  output_file=${BTS_FILES}/snapshot.zip
    Run Keyword If  '${request_status}' != 'completed'
    ...  Set Test Failed  message=Command sent with status: ${request_status}  fail_fast=True
    ...  ELSE
    ...  Log  Command sent with status: ${request_status}  console=true


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
