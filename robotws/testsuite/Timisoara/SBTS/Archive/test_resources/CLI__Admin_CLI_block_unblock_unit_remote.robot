*** Settings ***
Resource    ../../common_resources/ca_CIT_general.robot

*** Variables ***
${SKIP_PARAMETER_RELATION_ERRORS}       True   # If you don't want to ignore relation errors, please set this parameter to False


*** Keywords ***
TC__CLI__Admin_CLI_block_unblock_unit_remote
    [Documentation]
    ...  [CASE LINK] https://jira3.int.net.nokia.com/browse/TAT-14513
    ...
    ...  *****************
    ...  The purpose of this test case is to check if unit block/unblock commands via Admin command line is working.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  27.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-14513- test creation
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image: https:https://tatools.emea.nsn-net.net/static/hran_doc/CLI__Admin_CLI_block_unblock_unit_remote.png#


    Set Tags    CA-ALD    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-vlad.slivilescu@nokia.com    GROUP_IN_CHARGE-TIM_2_Vrf    PHASE-CRT    SW-SBTS18    SW-SBTS19
    ...    FEATURE-RP002070

   Precondition
   Test_Step.1 Perfom Block Rmod Via CLI On Port 443
   Test_Step.2 Check If Rmod is in Blocked State
   Test_Step.3 Perfom Unblock Rmod Via CLI On Port 443
   Test_Step.4 Check If Rmod is in Unblocked State
   Test_Step.5 Perfom Block Rmod Via CLI On Port 3600
   Test_Step.6 Check If Rmod is in Blocked State
   Test_Step.7 Perfom Unblock Rmod Via CLI On Port 3600
   Test_Step.8 Check If Rmod is in Unblocked State
   Test_Step.9 Perform non-existent Rmod Block Via CLI On Port 443


Precondition
    [Documentation]     Check if parameter actCli is set as "true" if not change it to "true"
    Log To Console  \n
    Log in frame    Preconditions: Check and enable feature Admin Command Line
    Check If Admin CLI Feature Check Is Enabled  ${SKIP_PARAMETER_RELATION_ERRORS}
    ${RMOD_DISTNAME}=  Get Rmod Distname
    Set Test Variable  ${RMOD_DISTNAME}

Test_Step.${n} Perfom Block Rmod Via CLI On Port ${port}
    [Documentation]     Block RMOD Via CLI On Port ${port}
    Log To Console  \n
    Log in frame  Step ${n}: Block RMOD with distname:${RMOD_DISTNAME} Via CLI On Port ${port}
    Setup Admin CLI  ${active SW version}  ${MPLANE_IP}  ${ADMIN_CLI_KEY}  port=${port}
    ${request}=  Set Variable  {"requestId":321,"parameters":{"name":"blockUnit","parameters":{"id":"${RMOD_DISTNAME}"}}}
    ${requestStatus}  ${error_code}  CLI Send Request And Return Status And Error Code  ${request}
    Run Keyword If  '${requestStatus}' != 'completed'
    ...  Set Test Failed  message=Command sent with status: ${requestStatus}  fail_fast=True
    ...  ELSE   Log   Command sent with status: ${requestStatus}  console=${True}

Test_Step.${n} Perfom Unblock Rmod Via CLI On Port ${port}
    [Documentation]     Unblock RMOD Via CLI On Port ${port}
    Log To Console  \n
    Log in frame  Step ${n}: Unblock RMOD with distname:${RMOD_DISTNAME} Via CLI On Port ${port}
    Setup Admin CLI  ${active SW version}  ${MPLANE_IP}  ${ADMIN_CLI_KEY}  port=${port}
    ${request}=  Set Variable  {"requestId":321,"parameters":{"name":"unblockUnit","parameters":{"id":"${RMOD_DISTNAME}"}}}
    ${requestStatus}  ${error_code}  CLI Send Request And Return Status And Error Code  ${request}
    Run Keyword If  '${requestStatus}' != 'completed'
    ...  Set Test Failed  message=Command sent with status: ${requestStatus}  fail_fast=True
    ...  ELSE   Log   Command sent with status: ${requestStatus}  console=${True}

Test_Step.${n} Check If Rmod is in ${block_unblock} State
    [Documentation]  Check If Block RMOD Was Performed
    Log To Console  \n
    Log in frame   Step ${n}: Check If RMOD with distname:${RMOD_DISTNAME} is in ${block_unblock} state
    Sleep  60
    ${blockingState}=  Get Rmod BlockingState
    Run Keyword If  '${block_unblock}' == '${blockingState}'
    ...  Log  Rmod with distname:${RMOD_DISTNAME} is in ${block_unblock} state.  console=${True}
    ...  ELSE  Set Test Failed  message=Rmod with distname:${RMOD_DISTNAME} is in ${blockingState} state.  fail_fast=True

Test_Step.9 Perform non-existent Rmod Block Via CLI On Port ${port}
    [Documentation]  Check if correct error message will be reported if non-existent RMOD will be blocked.
    Log To Console  \n
    Log in frame   Test_Step.9 Perform non-existent Rmod Block Via CLI On Port ${port}
    ${non-existent_rmod_distname}=  Set Variable  /MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-12321
    Setup Admin CLI  ${active SW version}  ${MPLANE_IP}  ${ADMIN_CLI_KEY}  port=${port}
    ${request}=  Set Variable  {"requestId":321,"parameters":{"name":"blockUnit","parameters":{"id":"${non-existent_rmod_distname}"}}}
    ${requestStatus}  ${error_code}  CLI Send Request And Return Status And Error Code  ${request}
    Run Keyword If  ${error_code} != 70
    ...  Set Test Failed  message=Reported error code: ${error_code} is different than: 70  fail_fast=True
    ...  ELSE   Log   Correct error code reported:${error_code}   console=${True}

Get Rmod Distname
    ${rmod_list}=  Infomodel Get Objects Parameter  //APEQM_A-1/RMOD_A-*  dist_name  allow_negative_result=${True}
    ${first_rmod_number}=  Get Regexp Matches  ${rmod_list[0]}  RMOD_A-(\\d*)  1
    ${BTS_ID}=  Admin Get Bts Id
    Set Test Variable  ${BTS_ID}
    Return From Keyword  /MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${first_rmod_number[0]}

Get Rmod BlockingState
    ${bts_info}=  Get Bts Info
    ${RMODs_info}=  Get From Dictionary  ${bts_info['radioModules']}  rmod
    FOR  ${RMOD_info}  IN  @{RMODs_info}
      ${distname}=  Get From Dictionary  ${RMOD_info['id']}  configuration
      ${RUNTIME_DISTNAME}=  Get From Dictionary  ${RMOD_info['id']}  internal
      Set Test Variable  ${RUNTIME_DISTNAME}
      ${blockingState}=  Get From Dictionary  ${RMOD_info['status']}  blockingState
      Return From Keyword If  '/${distname}'=='${RMOD_DISTNAME}'  ${blockingState}
    END

Test Specific teardown
    [Documentation]   Check If Rmod blockingState is different than 'Unblocked' if yes then RMOD unblock via Admin API
    ...  will be performed
    ${blockingState}=  Get Rmod BlockingState
    Run Keyword Unless  '${blockingState}' == 'Unblocked'  Run Keywords
    ...  Log  Rmod dostname:${RMOD_DISTNAME} blocking state different than 'Unblocked'. RMOD will be unblocked  console=${True}
    ...  AND  Unblock  ${RUNTIME_DISTNAME}
    ...  AND  Wait Until Keyword Succeeds  5m  10s  Admin Check All Required State

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords    Test Specific teardown    AND    Common test teardown


