*** Settings ***
Documentation
    ...  This test case is created to trigger site reset as recovery action multiple times to exceed site reset counter.
    ...  It will be done by triggerring fault 2080 using Fault Generator method. Recovery action will be checked against faultID 2080 with
    ...  alarmId=7101 BTS site autonomous reset as recovery action and the occurence of BTS site reset presence, as well as alarmId=7116
    ...  SRIO host link down when reset counter is exceeded.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${PING_TIMEOUT}  120  # Timeout for ping regain during site reset
${STARTUP_TIMEOUT}  600  # Timeout for SBTS startup after site reset


*** Keywords ***
TC__FM__Site_reset_counter_exceeded
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8671
    ...
    ...  This test case is created to trigger site reset as recovery action multiple times to exceed site reset counter.
    ...  It will be done by triggerring fault 2080 using Fault Generator method. Recovery action will be checked against faultID 2080 with
    ...  alarmId=7101 BTS site autonomous reset as recovery action and the occurence of BTS site reset presence, as well as alarmId=7116
    ...  SRIO host link down when reset counter is exceeded.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  08.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-8671 - Initial TAT creation
    ...  12.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15755 - Alias added for ute_admin KWs running in background
    ...  28.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16300 - Added reset counter value printing after each recovery
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  30.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28147 - Add verification for eCPRI RMODs.
    ...  10.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28215 - Fix problem for CRPI RMODs.
    ...  22.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28247 - Test fails because actRuResetResiliency parameter not found in 24R2
    ...  22.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28276 - Verify CPRI and eCPRI from 25R1 release.
    ...  05.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28986 - Improving RMOD Uptime checks
    ...  27.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29371 - Enhancement for CB008708
    ...  04.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29516 - Skip CB008708 for software versions below 25R3
    ...  16.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30319 - Added maintenance window cleanup in case the test failed
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-pawel.korniak@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534

    Step0: Check All Required States
    FOR  ${loop}  IN RANGE  0  3
        Step1: Trigger Fault 2080 ${loop}
        Step2: Verify SBTS After Recovery ${loop}
    END

    Step3: Trigger 4th Fault 2080
    Step4: Activate Maintenance Window
    Step5: Deactivate Maintenance Window
    Step6: Perform Site Reset


Step0: Check All Required States
    Log  \nStep0: Check all required states  console=true
    ${bts_l_list}  Query Infomodel  get list /MRBTS-1/RAT-1/BTS_L-*
    ${length_bts_l_list}  Get Length  ${bts_l_list}
    IF  '${length_bts_l_list}'=='1'
        Checking Hwapi_Domain If One Core
    ELSE
        Checking Hwapi_Domain If Dual Core
    END


Checking Hwapi_Domain If One Core
    ${hwapi_domain}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-*
    Set Test Variable  ${HWAPI_DOMAIN}
    IF  '${HWAPI_DOMAIN.hwapiDomainId}' == '1'
        BTS_L And Receiver Value For HwapiDomain1
    ELSE
        BTS_L And Receiver Value For HwapiDomain2
    END


Checking Hwapi_Domain If Dual Core
    ${hwapi_domain}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Active]
    Set Test Variable  ${HWAPI_DOMAIN}
    IF  '${HWAPI_DOMAIN.hwapiDomainId}' == '1'
        BTS_L And Receiver Value For HwapiDomain1
    ELSE
        BTS_L And Receiver Value For HwapiDomain2
    END


BTS_L And Receiver Value For HwapiDomain1
    ${var_bts_l}  Set Variable  BTS_L-1
    Set Test Variable  ${VAR_BTS_L}
    ${receiver}  Set Variable  269554178
    Set Test Variable  ${RECEIVER}
    ${sender}  Set Variable  269550144
    Set Test Variable  ${SENDER}
    ${domain_id}  Set Variable  16
    Set Test Variable  ${DOMAIN_ID}
    Checking The Value Of Reset Counter


BTS_L And Receiver Value For HwapiDomain2
    ${var_bts_l}  Set Variable  BTS_L-4
    Set Test Variable  ${VAR_BTS_L}
    ${receiver}  Set Variable  537989634
    Set Test Variable  ${RECEIVER}
    ${sender}  Set Variable  537985600
    Set Test Variable  ${SENDER}
    ${domain_id}  Set Variable  32
    Set Test Variable  ${DOMAIN_ID}
    Checking The Value Of Reset Counter


Checking The Value Of Reset Counter
    ${smod_object}  Query Infomodel  get object /MRBTS-1/RAT-1/${VAR_BTS_L}/EQM_L-1/CABINET_L-1/SMOD_L-1
    Set Test Variable  ${RESET_COUNTER}  ${smod_object.restartCounter}
    Log  Current value of reset counter: ${RESET_COUNTER}  console=true
    IF  '${RESET_COUNTER}' != '0'  Perform Site Reset


Check Cells Status
    [Arguments]  ${operational_state}  ${availability_state}

    IF  ${SCF_COUNT_WCDMA}
        Assert Every  WNCEL  operationalState=${operational_state} availabilityStatus=${availability_state}  timeout=60
    END
    IF  ${SCF_COUNT_LTE}
        Assert Every  LNCEL  operationalState=${operational_state} availabilityStatus=${availability_state}  timeout=60
    END
    IF  ${SCF_COUNT_GSM}
        Assert Every  GNCEL  operationalState=${operational_state} availabilityStatus=${availability_state}  timeout=60
    END


Step1: Trigger Fault 2080 ${loop}
    Log  \nStep1: Trigger fault 2080  console=true

    IF  ${loop} == 0 and '${ENB_BRANCH}' >= 'SBTS25R1'
        Change FEATCADM Parameter  actRuResetResiliency  false
    ELSE IF  ${loop} == 1 and '${ENB_BRANCH}' >= 'SBTS25R1'
        Change FEATCADM Parameter  actRuResetResiliency  true
    END
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=alarmCheck
    ${fault_site_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_2080_SITE_AUTO_RST}
    ${send_fault}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_site_auto_rst_params}  timeout=400  alias=alarmCheck
    Run Keyword And Ignore Error
    ...  Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  2080  ${DOMAIN_ID}  timeout=75
    ${states}  Catenate  SEPARATOR=  stateInfo.availabilityStatus=Failed, stateInfo.operationalState=Disabled,
    ...  stateInfo.reasoningStatus[0]=SrioHostLinkDown
    ${status_ccu_l}  ${im_ccu_l_object}  Run Keyword And Ignore Error
    ...  Query Infomodel  get object //CCU_L-1 is [${states}]  timeout=60
    IF  '${status_ccu_l}'=='FAIL'
        Set Test Restriction  message=StateInfo of CCU_L is different than expected [NOK]
    ELSE
        Log  StateInfo: availabilityStatus, operationalState, reasoningStatus for CCU_L is as expected [OK]  console=true
    END
    ${status}  ${dict_result}  Run Keyword And Ignore Error
    ...  Collect Keyword Result  ${send_fault}  timeout=400
    IF  '${status}'=='FAIL'
        Set Test Failed  message=Fault 2080 with alarm 7101 BTS site autonomous reset as recovery action didn't occur.  fail_fast=${True}
    END
    Log  Fault 2080 with alarm 7101 'BTS site autonomous reset as recovery action' is visible.  console=true
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}
    IF  ${ping_loss_status}==${False}
        Set Test Failed  Ping has not been lost within timeout=${PING_TIMEOUT}
    ELSE
        Log  Ping is lost  console=true
    END
    ${time_after_ping_loss}  Get Current Date  exclude_millis=true
    Set Test Variable  ${TIME_AFTER_PING_LOSS}
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_TIMEOUT}
    IF  ${ping_regain_status}==${False}
        Set Test Failed  Ping has not been regained within timeout
    ELSE
        Log  Target is Reachable  console=true
    END
    Run Keyword And Continue On Failure
    ...  Teardown Admin  alias=alarmCheck
    Sleep  180


Step2: Verify SBTS After Recovery ${loop}
    Log  \nStep2: Verify SBTS after Recovery  console=true

    ${smod_object}  Query Infomodel  get object /MRBTS-1/RAT-1/${VAR_BTS_L}/EQM_L-1/CABINET_L-1/SMOD_L-1
    ${reset_counter_after_recovery}  Set Variable  ${smod_object.restartCounter}
    Log  Reset counter value after recovery: ${reset_counter_after_recovery}  console=true

    Assert Every  RMOD  operationalState=${ENABLED}  timeout=900
    ${time_after_recovery}  Get Current Date  exclude_millis=True
    ${reset_time}  Subtract Date From Date  ${time_after_recovery}  ${TIME_AFTER_PING_LOSS}  exclude_millis=True
    Return From Keyword If  '${ENB_BRANCH}' < 'SBTS25R1'
    IF  ${loop} == 0
        Verify that reset was performed on all CPRI/eCPRI RMODs  ${reset_time}
    ELSE
        Wait Until Keyword Succeeds  180  20  Verify that reset was not performed on CPRI/eCPRI RMODs
    END
    Wait Until Keyword Succeeds  600  10
    ...  Check All Cells
    Check Links Status  Available
    Admin Check Active Alarms Taf


Verify that reset was performed on all CPRI/eCPRI RMODs
    [Arguments]  ${reset_time}

    ${upper_limit_time}  Add Time To Time  ${reset_time}s  180s
    ${upper_limit_time}  Convert To String  ${upper_limit_time}
    ${upper_limit_time}  Fetch from left  ${upper_limit_time}  .
    ${reset_time}  Convert To String  ${reset_time}
    ${reset_time}  Fetch from left  ${reset_time}  .
    Wait Until Keyword Succeeds  180  20  Waiting Until Uptime Is Visible On WebEM And Checking RMOD Uptime  ${reset_time}  ${upper_limit_time}


Waiting Until Uptime Is Visible On WebEM And Checking RMOD Uptime
    [Arguments]  ${reset_time}  ${upper_limit_time}
    ${rmods}  Get Frm
    FOR  ${rmod}  IN  @{rmods}
         ${rmod_parameters}  coam.Get Parameters  ${rmod}[id][internal]
         ${cpri_status}  Run Keyword And Return Status  Should Contain  ${rmod_parameters}[l3Protocol]  CPRI
         Continue For Loop If  not(${cpri_status})
         ${rmod_measurements}  Get Rmod Measurements By Id  ${rmod}[id][internal]
         ${status_rmod_uptime}  Run Keyword And Return Status  Should Not Contain  ${rmod_measurements}[uptime][seconds]  -
         IF  ${status_rmod_uptime}
             Fail  RMOD uptime is not visible on WebEM.
         ELSE
             ${rmod_uptime}  Set Variable  ${rmod_measurements}[uptime][seconds]
         END
         IF  '${rmod_uptime}' > '${reset_time}' and '${rmod_uptime}' < '${upper_limit_time}'
             Log  RMOD(${rmod}[id][internal]) reset has been performed. [OK]  console=true
         ELSE
             Fail  RMOD(${rmod}[id][internal]) reset was not performed. [NOK]
         END
    END
    ${variable_status}  Run Keyword And Return Status  Variable Should Exist  ${rmod_uptime}
    Return From Keyword If  not(${variable_status})
    ${rmod_uptime}  Convert To Integer  ${rmod_uptime}
    Set Test Variable  ${LAST_RMOD_UPTIME}  ${rmod_uptime}


Verify that reset was not performed on CPRI/eCPRI RMODs
    ${rmods}  Get Frm
    FOR  ${rmod}  IN  @{rmods}
         ${rmod_parameters}  coam.Get Parameters  ${rmod}[id][internal]
         ${cpri_status}  Run Keyword And Return Status  Should Contain  ${rmod_parameters}[l3Protocol]  CPRI
         Continue For Loop If  not(${cpri_status})
         ${rmod_measurements}  Get Rmod Measurements By Id  ${rmod}[id][internal]
         ${status_rmod_uptime}  Run Keyword And Return Status  Should Not Contain  ${rmod_measurements}[uptime][seconds]  -
         IF  ${status_rmod_uptime}
             Fail  RMOD uptime is not visible on WebEM.
         ELSE
             ${rmod_uptime}  Set Variable  ${rmod_measurements}[uptime][seconds]
         END
         ${rmod_uptime}  Convert To Integer  ${rmod_uptime}
         IF  ${rmod_uptime} > ${LAST_RMOD_UPTIME}
             Log  RMOD(${rmod}[id][internal]) reset was not performed. [OK]  console=true
         ELSE
             Fail  RMOD(${rmod}[id][internal]) reset was performed. [NOK]
         END
    END
    ${variable_status}  Run Keyword And Return Status  Variable Should Exist  ${rmod_uptime}
    Return From Keyword If  not(${variable_status})
    ${rmod_uptime}  Convert To Integer  ${rmod_uptime}
    Set Test Variable  ${LAST_RMOD_UPTIME}  ${rmod_uptime}


Step3: Trigger 4th Fault 2080
    Log  \nStep3: Trigger 4th fault 2080  console=true
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=alarmCheck

    ${fault_srio_link_down_params}  Get String With Alarm Parameters  ${FAULT_2080_SRIO_LINK_DOWN}
    ${send_fault}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_srio_link_down_params}  timeout=400  alias=alarmCheck
    Run Keyword And Ignore Error
    ...  Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  2080  ${DOMAIN_ID}  timeout=300
    ${states}  Catenate  SEPARATOR=  stateInfo.availabilityStatus=Failed, stateInfo.operationalState=Disabled,
    ...  stateInfo.reasoningStatus[0]=SrioHostLinkDown
    ${status_ccu_l}  ${im_ccu_l_object}  Run Keyword And Ignore Error
    ...  Query Infomodel  get object //CCU_L-1 is [${states}]  timeout=60
    IF  '${status_ccu_l}'=='FAIL'
        Set Test Restriction  message=StateInfo of CCU_L is different than expected [NOK]
    ELSE
        Log  StateInfo: availabilityStatus, operationalState, reasoningStatus for CCU_L is as expected [OK]  console=true
    END
    ${status}  ${dict_result}  Run Keyword And Ignore Error
    ...  Collect Keyword Result  ${send_fault}  timeout=400
    IF  '${status}'=='FAIL'
        Set Test Failed  message=Fault 2080 with alarm 7116 'SRIO host link down' didn't occur.  fail_fast=${True}
    END
    Log  Fault 2080 with alarm 7116 'SRIO host link down' is visible  console=true
    Run Keyword And Continue On Failure
    ...  Teardown Admin  alias=alarmCheck
    Wait Until Keyword Succeeds  600  10
    ...  Check Cells Status  ${DISABLED}  ${FAILED}
    Admin Check Active Alarms Taf


Step4: Activate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep4: Activate Maintenance Window.  console=true
    Create Maintenance Window
    Wait Until Keyword Succeeds  900s  10s
    ...  Check All Cells
    ${recovery_execution_result}  Set Variable  BTS site recovery reset:MRBTS-${BTS_ID}

    ${list}  Create List  maintenanceWindowResult
    Log  Verifying maintenance window result in Parameter Editor to be equal to recoveryExecutionResult from Info Model.  console=true
    ${maintenance_window_result_object}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1  ${list}
    ${actual_value}  Set Variable  ${maintenance_window_result_object}[0][parameters][maintenanceWindowResult]
    Check Equality For Force Recovery Parameter  ${recovery_execution_result}  ${actual_value}
    ...  Maintenance Window Result did not matched.
    Log  Maintenance Window Result from Parameter Editor was correctly completed.  console=true


Step5: Deactivate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep5: Deactivate Maintenance Window.  console=true
    Delete Maintenance Window


Step6: Perform Site Reset
    Log  \nStep6: Site reset will be performed to clear all counters  console=true
    Perform Site Reset


TC Setup
    Common Test Setup  tc_name=FM__Site_reset_counter_exceeded


TC Teardown
    Run Keyword If Test Failed  Maintenance Window Cleanup
    Common Test Teardown
