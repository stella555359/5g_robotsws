*** Settings ***
Documentation
    ...  Step1: Testcase preconditions
    ...  Check if all WCDMA cells have correct parameters:
    ...  availabilityStatus: Online
    ...  operationalStatus: Enabled
    ...  Check for critical or major alarms to not be active
    ...  Step2: Provoke CNBAP link break
    ...  CNBAP link break provoke via iptables DROP command
    ...  Step3: Check WCDMA cells state
    ...  Check if WCDMA cells have correct parameters after link break:
    ...  avalavilitiStatus=failed
    ...  proceduralStatus=prevalidated
    ...  operationalstate=disabled
    ...  Step4: Check alarm appearance
    ...  Fault 17 should be reported correctly
    ...  Step5: Restore CNBAP link
    ...  CNBAP link break restore via iptables DROP command
    ...  Check if all WCDMA cells have correct parameters after link restore:
    ...  availabilityStatus: Online
    ...  operationalStatus: Enabled
    ...  Step6: Check alarm cancel
    ...  Fault 17 should disappear

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${NUMBER_OF_LOOPS}  1  # Number of link breaks and restorations to be performed by test.
${ALARM_TIMEOUT}  400  # [in seconds] Timeout for alarm to appear in WebEM.


*** Keywords ***
TC__FM__Iub_CNBAP_link_break
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5513
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.02.2017 - https://jira3.int.net.nokia.com/browse/TAT-5513 - Initial creation
    ...  - 20.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-6209
    ...  - 20.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-6202
    ...  - 30.05.2017 - https://jira3.int.net.nokia.com/browse/TAT-6544
    ...  - 02.06.2017 - https://jira3.int.net.nokia.com/browse/TAT-6703
    ...  - 19.06.2017 - https://jira3.int.net.nokia.com/browse/TAT-6788
    ...  - 20.06.2017 - https://jira3.int.net.nokia.com/browse/TAT-6854
    ...  - 04.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7844 - Increased time to check SBTS cells and deleted checking channel states.
    ...  - 04.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7711 - When test fail, wait for alarm cancel and refactor.
    ...  - 20.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7654 - Added support for hran_logging==2.1.0
    ...  - 21.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8251
    ...  - 08.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-12444
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 04.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21290 - Test fails due to CarrierState removal
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 18.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27670 - Assert alarm active wrong parameter name
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-iwona.andrejewicz@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534  FEATURE-RP001145_RP000920  FEATURE-RP001486_RP000920

    FOR  ${loop}  IN RANGE  0  ${NUMBER_OF_LOOPS}
        Step1: Testcase Preconditions
        Step2: Provoke CNBAP Link Break
        Step3: Check WCDMA Cells State
        Step4: Check Alarm Appearance
        Step5: Restore CNBAP Link
        Step6: Check Alarm Cancel
    END


Step1: Testcase Preconditions
    Log  Step1: Testcase preconditions.  level=INFO  console=true
    Assert Every  WNCEL  operationalState=${ENABLED}
    Assert Alarm Inactive  severity=Critical  timeout=60
    Assert Alarm Inactive  severity=Major  timeout=60


Step2: Provoke CNBAP Link Break
    Log  Step2: Provoke CNBAP link break.  console=true
    ${configuration}  Check System Modules Configuration In InfoModel
    ${chain}  Set Variable If  '${configuration}' == '4+3' or '${configuration}' == '3+4'  FORWARD  INPUT
    Set Test Variable  ${CHAIN}  ${chain}
    Log  Tested configuration type is: ${configuration}  console=true
    Log  Chain for iptables which will be used: ${CHAIN}  console=true
    ${im_object}  Query Infomodel  get object /MRBTS-1/RAT-1//WNBTS_A-*
    Set Test Variable  ${PORT_IP}  ${im_object.cPlaneList.sctpPortMin}
    Break CNBAP Link
    Sleep  15s
    Query Infomodel  every /MRBTS-1//RNC_L-1 is [cnbapLinkStatus=Unavailable, dnbapLinkStatus=Unavailable]


Step3: Check WCDMA Cells State
    Log  Step3: Check WCDMA cells state.  level=INFO  console=true
    ${verdict}  Run Keyword And Return Status
    ...  Assert Every  WNCEL  operationalState=${DISABLED}  timeout=90
    Run Keyword If  '${verdict}' == 'False'
    ...  Restore CNBAP Link And Fail  Incorrect cells state  ${True}


Step4: Check Alarm Appearance
    Log  Step4: Check alarm appearance.  level=INFO  console=true
    Log  Wait until fault 17 appears.  console=true
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_17}
    ${alarm}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Run Keyword If  ${alarm}
    ...  Log  Alarm reported correctly.  console=true
    ...  ELSE
    ...  Restore CNBAP Link And Fail  Alarm didn't report corectly.  restore_link=${True}


Step5: Restore CNBAP Link
    Log  Step5: Restore CNBAP link.  level=INFO  console=true
    ${return_code}  Restore CNBAP Link
    Run Keyword If  ${return_code}!=0
    ...  Fail  Restore CNBAP link failed
    Wait Until Keyword Succeeds  120  10
    ...  Assert Every  WNCEL  operationalState=${ENABLED}
    Query Infomodel  every /MRBTS-1//RNC_L-1 is [cnbapLinkStatus=Available, dnbapLinkStatus=Available]


Step6: Check Alarm Cancel
    Log  Step6: Check alarm cancel.  level=INFO  console=true
    Log  Wait until fault 17 disappears.  console=true
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_17}
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_17}[fault_id] "${FAULT_17}[fault_name]" is not active.  console=true
    Admin Check Active Alarms TAF  timeout=400


Restore CNBAP Link And Fail
    [Documentation]  Restore CNBAP Link And Fail if ${restore_link}==True
    [Arguments]  ${msg}  ${restore_link}

    Log  Test Failed! Collect Snapshot and restore CNBAP link.  console=true
    Run Keyword If  ${restore_link}
    ...  Run Keywords
    ...  Restore CNBAP Link
    ...  AND
    ...  Assert Alarm Inactive  faultId=${FAULT_17}[fault_id]  timeout=400
    Fail  ${msg} Test Fail


Break CNBAP Link
    [Documentation]  Break CNBAP Link

    Connect To SMOD  ${SMOD1['IP']}
    ssh.Execute  iptables -I ${CHAIN} -4 -p SCTP --dport ${PORT_IP} -j DROP
    Log  Command sent: 'iptables -I ${CHAIN} -4 -p SCTP --dport ${PORT_IP} -j DROP'  console=true
    ${return_code}  ssh.Get Exit Status
    Run Keyword If  ${return_code}!=0
    ...  Run Keywords
    ...  Admin Get Snapshot
    ...  AND
    ...  Fail  Test failed because of link break failed.


Restore CNBAP Link
    [Documentation]  Restore CNBAP Link

    Connect To SMOD  ${SMOD1['IP']}
    ${output}  ssh.Execute  iptables -D ${CHAIN} -4 -p SCTP --dport ${PORT_IP} -j DROP
    Log  Command sent: 'iptables -D ${CHAIN} -4 -p SCTP --dport ${PORT_IP} -j DROP'  console=true
    ${return_code}  ssh.Get Exit Status
    Run Keyword If  ${return_code}!=0
    ...  Fail  Restore CNBAP Link failed.\n${output}

    [Return]  ${return_code}


TC Setup
    Common Test Setup  tc_name=FM__Iub_CNBAP_link_break


TC Teardown
    Common Test Teardown
