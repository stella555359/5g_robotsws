*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/cli.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     CLI.07_Admin_CLI_testRET_During_Exception_Conditions
...  AUTHOR:        mateusz.gadek@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is check if testRET command via Admin command line are working during exception
...  conditions, like: site reset, rmod reset etc.
...  *****************
...  Pre-conditions
...  *****************
...  1. RET is present on site, physically connected to RMOD, comissioned and detected.
...  2. RMOD to which RET is connected uses one of those Nokia RP1 protocols (OBSAI/CPRI-N/eCPRI.
...  ******************
...  History of changes
...  ******************
...  29.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-502 - test case creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Variables ***
@{key_list}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-7    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-4

*** Keywords ***
CLI.07_Admin_CLI_testRET_During_Exception_Conditions

    CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.0 Check If RETs Are In Configuration
    CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.1 Enable CLI Feature
    CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.2 Sending testRET Request Via CLI during site reset
    CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.3 Sending testRET Request Via CLI during RMOD reset
    CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.4 Sending testRET Request Via CLI With DC OFF
    CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.5 Sending testRET Request Via CLI To decommisioned RET


CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.0 Check If RETs Are In Configuration
    [Documentation]  Test step which checking if RETs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_RETs}
    Set Test Variable  ${num_of_RETs}
    Run Keyword If  ${num_of_RETs}==${0}
    ...  Fail  msg=There is no at least one expected RET in configuration
    Log  You have ${num_of_RETs} RETs in configuration  console=${True}

CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.1 Enable CLI Feature
    [Documentation]  Check if parameter actCli is set as "true", if not then change it to "true".
    Log to console    \n========================================
    Log  Step: 1 Enable CLI Feature  console=${True}
    Log to console    ========================================
    Set Feature On Expected Value  parameter=actCli  value=true

CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.2 Sending testRET Request Via CLI during site reset
    [Documentation]
    ...    1. Select random RET.
    ...    2. Send CLI request with command testRET for selected RET.
    Log to console    \n========================================
    Log  Step: 2 Sending testRET Request Via CLI during site reset  console=${True}
    Log to console    ========================================
    Log to console    \n... Gathering information before sending CLI command
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Collect And Setup ADMIN CLI
    ${chosen_RET}=  Select Random RET  ${ALD_R_RETs}
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${ALD_A}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${chosen_RET}
    ${ignore}  ${ALD}=  Split String From Right  ${ALD_A}  separator=APEQM_A-1/
    ${ALD_ID}=  Evaluate  re.search(r'ALD_A-(\\d+)','''${ALD}''').group(1)  re
    ${chosen_ALD}=    Set Variable    ALD-${ALD_ID}
    ${ret_parameters}=    admin.get managed objects    RETU_A
    ${ant_value_list}=    Create Dictionary
    FOR  ${ret}  IN  @{ret_parameters}
        ${ignore}    ${ALD_DN}=   Split String From Right  ${ret['distName']}  separator=APEQM_A-1/
        Run Keyword If    '${ALD_DN}'=='${ALD}/RETU_A-1'
        ...    Set To Dictionary    ${ant_value_list}    AntDNlist    ${ret['parameters']['antlDNList']}
    END
    Log    ${ant_value_list}
    Log    \nChosen RET ---> ${chosen_ALD}   console=${true}
    ${antldDN_list}=    Create List
    FOR    ${i}    IN    @{ant_value_list['AntDNlist']}
        ${ignore}    ${antlDN}=   Split String From Right  ${i}  separator=APEQM_A-1/
        ${antlDN}=  Replace String  ${antlDN}  search_for=_A  replace_with=
        ${rmod}    ${ignore}=   Split String From Right  ${antlDN}  separator=/
        Append to List    ${antldDN_list}    ${antlDN}
    END
    Log    ${antldDN_list}   console=${true}
    Log    \n${chosen_ALD} is connected to ${rmod}    console=${true}
    Log    \nAssociated antenna line with ${chosen_ALD} is: ${antldDN_list}    console=${true}
    Log    \nPerform BTS Reset site and send CLI command    console=${true}
    Log To Console  BTS Reset site...
    admin.reset site
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"testRET","parameters":{"targetDN":"${chosen_RET}"}}}
    Log To Console    Generated command CLI: ${command_cli}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    ${status}  ${alds_from_cli}  ${antList}  ${connectedRmodList}  ${resultList}  Get Data From Received CLI Message    ${requestMessage}
    ${result}=  Get From Dictionary    ${requestMessage['testResult']['alds']['${chosen_ALD}']}    result
    ${connectedRmod}=  Get From Dictionary    ${requestMessage['testResult']['alds']['${chosen_ALD}']}    connectedRmod
    Run Keyword If  '${requestStatus}' != 'completed' or '${result}' != 'FAIL'
    ...  Fail     msg=Command sent with status: ${requestStatus} and Result should not be: ${result}
    ...  ELSE   Log   \nCommand sent with status: ${requestStatus} and Result ${result}  console=${True}
    Run Keyword If  '${rmod}' != '${connectedRmod}' or '${chosen_ALD}' != '${alds_from_cli[0]}'
    ...  Fail     msg=RMOD and chosen RET from CLI message are incorrect
    ...  ELSE   Log   \nRMOD and chosen RET from CLI message are correct    console=${true}
    ${status}=  Run Keyword And Return Status  Lists Should Be Equal  ${antldDN_list}  ${antList['antlDNList']}
    Run Keyword If  ${status}
    ...  Log  \nAntenna lines are equal ${antldDN_list} <---> ${antList['antlDNList']}  console=${true}
    ...  ELSE  Fail  Antenna lines are different
    Check If NLWG Cells Are OnAir
    Check If ALDs Are Connected And Achieved Expected State
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB

CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.3 Sending testRET Request Via CLI during RMOD reset
    [Documentation]
    ...    1. Select random RMOD.
    ...    2. Send CLI request with command testRET for selected RMOD.
    Log to console    \n========================================
    Log  Step: 3 Sending testRET Request Via CLI For Selected RMOD  console=${True}
    Log to console    ========================================
    Get RMODs
    ${status}    ${rmod_and_retlist}    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  5x  2s   Select RMOD with connected RETs
    ${RETs_connected_to_rmod}=    Set Variable    ${rmod_and_retlist[0]}
    ${chosen_RMOD}=    Set Variable    ${rmod_and_retlist[1]}
    ${RET_A_connected}=    Create List
    FOR    ${i}    IN    @{RETs_connected_to_rmod}
        ${ALD_DN}=    Set Variable    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/${i}
        ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
        ${ALD_A_DN}=    Get From Dictionary    ${ALD_R_to_ALD_A}    ${ALD_DN}
        ${ignore}    ${ald_a}=   Split String From Right  ${ALD_A_DN}  separator=APEQM_A-1/
        ${ald}=  Replace String  ${ald_a}  search_for=_A  replace_with=
        Append To List    ${RET_A_connected}    ${ald}
    END
    Sort List    ${RET_A_connected}
    admin.reset unit  ${chosen_RMOD}  reset_type=Hard  timeout=600
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"testRET","parameters":{"targetDN":"${chosen_RMOD}"}}}
    Log To Console    Generated command CLI: ${command_cli}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    ${status}  ${alds_from_cli}  ${antList}  ${connectedRmodList}  ${resultList}  Get Data From Received CLI Message    ${requestMessage}
    Run Keyword If  '${requestStatus}' != 'completed'
    ...  Fail     msg=Command sent with status: ${requestStatus}
    ...  ELSE   Log   Command sent with status: ${requestStatus}  console=${True}
    ${Status}  Run Keyword And Return Status  List Should Not Contain Value  ${resultList}  'OK'
    Run Keyword If    '${Status}' != 'True'  Fail  msg=Status from CLI message is not correct
    ...  ELSE  Log  Status from CLI message is correct    console=${true}
    Sort List    ${alds_from_cli}
    ${Status}  Run Keyword And Return Status    Lists Should Be Equal  ${RET_A_connected}  ${alds_from_cli}
    Run Keyword If    '${Status}' != 'True'  Fail  msg=Lists for RETs are different
    ...  ELSE  Log  \nRETs from CLI message are matching selected ALDs: ${RET_A_connected} <--> ${alds_from_cli}  console=${true}
    ${ignore}    ${chosen_RMOD_for_check}=   Split String From Right  ${chosen_RMOD}  separator=APEQM-1/
    ${Status}  Run Keyword And Return Status    Should Be Equal  ${chosen_RMOD_for_check}  ${connectedRmodList[0]}
    Run Keyword If    '${Status}' != 'True'  Fail  msg=Selected RMOD is incorrect
    ...  ELSE  Log  RMOD from CLI message are matching selected rmods ${chosen_RMOD_for_check} <--> ${connectedRmodList[0]}  console=${true}

CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.4 Sending testRET Request Via CLI With DC OFF
    [Documentation]  Send command testRET Request Via CLI for RET With DC OFF
    Log to console    \n========================================
    Log  Step: 4 Sending testRET Request Via CLI With DC OFF  console=${True}
    Log to console    ========================================
    Get RMODs
    ${status}    ${rmod_and_retlist}    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  5x  2s   Select RMOD with connected RETs
    ${RETs_connected_to_rmod}=    Set Variable    ${rmod_and_retlist[0]}
    ${chosen_RMOD}=    Set Variable    ${rmod_and_retlist[1]}
    ${RET_A_connected}=    Create List
    FOR    ${i}    IN    @{RETs_connected_to_rmod}
        ${ALD_DN}=    Set Variable    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/${i}
        ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
        ${ALD_A_DN}=    Get From Dictionary    ${ALD_R_to_ALD_A}    ${ALD_DN}
        ${ignore}    ${ald_a}=   Split String From Right  ${ALD_A_DN}  separator=APEQM_A-1/
        ${ald}=  Replace String  ${ald_a}  search_for=_A  replace_with=
        Append To List    ${RET_A_connected}    ${ald}
    END
    Log    Chosen RMOD: ${chosen_RMOD} RET: ${RET_A_connected}  console=${true}
    Sort List    ${RET_A_connected}
    Allow Fault In Watchdog  faultID=4141  #fault_name: DC voltage administratively disabled
    DC Voltage Switching OFF
    Sleep  120s
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"testRET","parameters":{"targetDN":"${chosen_RMOD}"}}}
    Log To Console    Generated command CLI: ${command_cli}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    ${status}  ${alds_from_cli}  ${antList}  ${connectedRmodList}  ${resultList}  Get Data From Received CLI Message    ${requestMessage}
    Run Keyword If  '${requestStatus}' != 'completed'
    ...  Fail     msg=Command sent with status: ${requestStatus}
    ...  ELSE   Log   Command sent with status: ${requestStatus}  console=${True}
    ${Status}  Run Keyword And Return Status  List Should Not Contain Value  ${resultList}  'OK'
    Run Keyword If    '${Status}' != 'True'  Fail  msg=Status from CLI message is not correct
    ...  ELSE  Log  Status from CLI message is correct    console=${true}
    Sort List    ${alds_from_cli}
    ${Status}  Run Keyword And Return Status    Lists Should Be Equal  ${RET_A_connected}  ${alds_from_cli}
    Run Keyword If    '${Status}' != 'True'  Fail  msg=Lists for RETs are different
    ...  ELSE  Log  \nRETs from CLI message are matching selected ALDs: ${RET_A_connected} <--> ${alds_from_cli}  console=${true}
    ${ignore}    ${chosen_RMOD_for_check}=   Split String From Right  ${chosen_RMOD}  separator=APEQM-1/
    ${Status}  Run Keyword And Return Status    Should Be Equal  ${chosen_RMOD_for_check}  ${connectedRmodList[0]}
    Run Keyword If    '${Status}' != 'True'  Fail  msg=Selected RMOD is incorrect
    ...  ELSE  Log  RMOD from CLI message are matching selected rmods ${chosen_RMOD_for_check} <--> ${connectedRmodList[0]}  console=${true}
    DC Voltage Switching ON
    Sleep  120s
    Disallow Fault In Watchdog  faultID=4141  #fault_name: DC voltage administratively disabled

CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test_Step.5 Sending testRET Request Via CLI To decommisioned RET
    [Documentation]  Send command testRET for all RET devices.
    Log to console    \n========================================
    Log  Step: 5 Sending testRET Request Via CLI To decommisioned RET  console=${True}
    Log to console    ========================================
    ${chosen_RET}=  Select Random RET  ${ALD_R_RETs}
    Run Keyword If  ${num_of_RETs} != ${0}
    ...  Create Delta Remove For Selected ALD  ${chosen_RET}  deviceType=RET
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"testRET","parameters":{"targetDN":"${chosen_RET}"}}}
    Log To Console    Generated command CLI: ${command_cli}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    Run Keyword If  '${requestStatus}' != 'rejected' and '${error_code}' != '69'
    ...  Fail     msg=Command sent with status: ${requestStatus} and errorCode: ${error_code}
    ...  ELSE   Log   Command sent with status: ${requestStatus} and errorCode: ${error_code}  console=${True}


CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  \nRestoring original configuration settings  console=${True}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    admin.teardown admin  alias=${ute_admin_alias}

CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test Specific Teardown
