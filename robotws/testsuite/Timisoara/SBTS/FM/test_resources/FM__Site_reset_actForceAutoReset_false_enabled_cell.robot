*** Settings ***
Documentation
    ...  This test case is created to trigger fault that normally will cause site reset as recovery action, but actForceAutoReset is set on false.
    ...  It will be done by escalation from secondary core reset to site reset. faultId 2080 will be send using Fault Generator method.
    ...  Recovery action for secondary will be tested by checking faultID 2080 with
    ...  alarmId=7101 BTS secondary core autonomous reset as recovery action.
    ...  When recovery counter for secondary core is exceeded, recovery site reset is not performed and original fault 2080 is reported.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${PING_TIMEOUT}  120  # Timeout for ping after reset


*** Keywords ***
TC__FM__Site_reset_actForceAutoReset_false_enabled_cell
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14622
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14622 - Initial TAT creation
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001534

    Step0: Verify All Required States Of SBTS
    Step1: Perform Site Reset
    Step2: Prepare FaultId 2080
    FOR  ${loop}  IN RANGE  0  2
        Step3: Verify Recovery Action
    END
    Step4: Trigger Escalation To Site Reset And Verify Behaviour
    Step5: Recover SBTS


Step0: Verify All Required States Of SBTS
    Log  Step0:\n Check actForceAutoReset and change for FALSE if needed  console=true
    Check Links Status  Available
    ${status}  Run Keyword And Return Status
    ...  Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    ${parameter_after_change}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Run Keyword If  ${status}
    ...  Should Be Equal  ${parameter_after_change}  false
    ...  ELSE
    ...  Fail  msg=Parameter change to false failed.


Step1: Perform Site Reset
    Log  step1:\n Site reset will be performed to clear all counters  console=true
    Perform Site Reset


Step2: Prepare FaultId 2080
    Log  step2:\n Prepare fault 2080  console=true
    ${hwapi_domain}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Idle]
    Run Keyword If  '${hwapi_domain.hwapiDomainId}' == '1'
    ...  Run Keyword
    ...  Receiver Value For HwapiDomain1
    ...  ELSE
    ...  Receiver Value For HwapiDomain2


Receiver Value For HwapiDomain1
    ${receiver}  Set Variable  269554178
    Set Test Variable  ${RECEIVER}
    ${sender}  Set Variable  269550144
    Set Test Variable  ${SENDER}
    ${domain_id}  Set Variable  16
    Set Test Variable  ${DOMAIN_ID}


Receiver Value For HwapiDomain2
    ${receiver}  Set Variable  537989634
    Set Test Variable  ${RECEIVER}
    ${sender}  Set Variable  537985600
    Set Test Variable  ${SENDER}
    ${domain_id}  Set Variable  32
    Set Test Variable  ${DOMAIN_ID}


Step3: Verify Recovery Action
    Log  step3:\n Verify if recovery was performed  console=true

    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=checkActiveFault
    ${fault_2nd_core_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_2080_2_ND_CORE_AUTO_RST}
    ${send_fault}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_2nd_core_auto_rst_params}  timeout=400  alias=checkActiveFault
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  2080  ${DOMAIN_ID}  timeout=80
    Log  Fault sent.  console=true
    ${states}  Catenate  SEPARATOR=  stateInfo.availabilityStatus=Failed, stateInfo.operationalState=Disabled,
    ...  stateInfo.reasoningStatus[0]=SrioHostLinkDown
    ${status_ccu_l}  ${im_ccu_l_object}  Run Keyword And Ignore Error
    ...  Query Infomodel  get object //CCU_L-1 is [${states}]  timeout=45
    Run Keyword If  '${status_ccu_l}'=='FAIL'
    ...  Set Test Restriction  message=StateInfo of CCU_L is different than expected [NOK]
    ...  ELSE
    ...  Log  StateInfo: availabilityStatus, operationalState, reasoningStatus for CCU_L is as expected [OK]  console=true
    ${status}  ${dict_result}  Run Keyword And Ignore Error
    ...  Collect Keyword Result  ${send_fault}  timeout=400
    Should Be True  '${status}'=='PASS'  Fault 2080 "${FAULT_2080_2_ND_CORE_AUTO_RST}[fault_name]" didn't occured. [NOK]
    Log  Fault 2080 "${FAULT_2080_2_ND_CORE_AUTO_RST}[fault_name]" is visible. [OK]  console=true
    Run Keyword And Continue On Failure
    ...  Teardown Admin  alias=checkActiveFault

    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD2['IP']}  timeout=${PING_TIMEOUT}  remote_host=${PC_IP2}
    Run Keyword If  ${ping_loss_status}==${False}
    ...  Set Test Failed  Ping has not been lost within timeout=${PING_TIMEOUT}
    ...  ELSE
    ...  Log  Ping is lost  console=true
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD2['IP']}  timeout=${PING_TIMEOUT}  remote_host=${PC_IP2}
    Run Keyword If  ${ping_regain_status}==${False}
    ...  Set Test Failed  Ping has not been regained within timeout=${PING_TIMEOUT}
    ...  ELSE
    ...  Log  Target is Reachable  console=true
    Log  Verify SBTS after Recovery  console=true
    Wait Until Keyword Succeeds  600  10
    ...  Check All Cells
    Check Links Status  Available
    Admin Check Active Alarms Taf


Step4: Trigger Escalation To Site Reset And Verify Behaviour
    Log  step4:\n Trigger escalation to site reset and verify behaviour  console=true
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  2080  ${DOMAIN_ID}  timeout=80
    Log  Fault sent.  console=true
    ${states}  Catenate  SEPARATOR=  stateInfo.availabilityStatus=Failed, stateInfo.operationalState=Disabled,
    ...  stateInfo.reasoningStatus[0]=SrioHostLinkDown
    ${status_ccu_l}  ${im_ccu_l_object}  Run Keyword And Ignore Error
    ...  Query Infomodel  get object //CCU_L-1 is [${states}]  timeout=45
    Run Keyword If  '${status_ccu_l}'=='FAIL'
    ...  Set Test Restriction  message=StateInfo of CCU_L is different than expected [NOK]
    ...  ELSE
    ...  Log  StateInfo: availabilityStatus, operationalState, reasoningStatus for CCU_L is as expected [OK]  console=true

    ${fault_srio_link_down}  Get String With Alarm Parameters  ${FAULT_2080_SRIO_LINK_DOWN}
    Assert Alarm Active  parameters=${fault_srio_link_down}  timeout=200
    Log  Fault 2080 "${FAULT_2080_SRIO_LINK_DOWN}[fault_name]" is visible.  console=true
    Check Impacted Cells  ${DISABLED}  ${FAILED}


Step5: Recover SBTS
    Log  step5:\n Recover SBTS  console=true

    Log  Site reset will be performed to recover SBTS  console=true
    Perform Site Reset


Check Impacted Cells
    [Documentation]
    ...  To check status of impacted cells after action
    ...  KW will check if there is at least one cell afected by operation for every RAT
    ...  operational state and availability status are mandatory arguments
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${operational_state}  ${availability_state}

    ${status_gsm}  Run Keyword And Return Status
    ...  Assert Any  GNCEL  operationalState=${operational_state}, availabilityStatus=${availability_state}  timeout=45
    Run Keyword If  ${status_gsm}
    ...  Log  There is at least one GSM cell with status: ${operational_state} ${availability_state}  console=TRUE
    ...  ELSE
    ...  Log  GSM cells not impacted.  console=TRUE

    ${status_wcdma}  Run Keyword And Return Status
    ...  Assert Any  WNCEL  operationalState=${operational_state}, availabilityStatus=${availability_state}  timeout=45
    Run Keyword If  ${status_wcdma}
    ...  Log  There is at least one WCDMA cell with status: ${operational_state} ${availability_state}  console=TRUE
    ...  ELSE
    ...  Log  WCDMA cells not impacted.  console=TRUE

    ${status_lte}  Run Keyword And Return Status
    ...  Assert Any  LNCEL  operationalState=${operational_state}, availabilityStatus=${availability_state}  timeout=45
    Run Keyword If  ${status_lte}
    ...  Log  There is at least one LTE cell with status: ${operational_state} ${availability_state}  console=TRUE
    ...  ELSE
    ...  Log  LTE cells not impacted.  console=TRUE


TC Setup
    Common Test Setup  tc_name=FM__Site_reset_actForceAutoReset_false_enabled_cell


TC Teardown
    Common Test Teardown
