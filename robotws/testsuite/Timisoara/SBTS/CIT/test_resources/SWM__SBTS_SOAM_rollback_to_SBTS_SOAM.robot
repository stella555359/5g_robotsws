*** Settings ***
Documentation
    ...  Main purpose of TC is checking rollback functionality of SBTS SW
    ...  Way of rollback: from SBTS17 to SBTS17

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${PASSIVE_SW_STATE}  ${EMPTY}  # Expected SW state after rollback, available states: 'commissioned' 'notcommissioned'.
# Leave blank if TC shouldn't fail due BTS state.
${RESTORE_TIMEOUT}  15m  # Timeout for waiting until cells are onAir/notOnAir in Robot Framework format (600s, 10m)
${CONNECTION_RESET_ON_DEMAND}  ${FALSE}  # If ${TRUE} - connection to Admin and Infomodel will be reset on demand after rollback,
# if ${FALSE} - connection to Admin and Infomodel will be reset only if soamif version changed or
# connection broken
${PING_LOSS_TIMEOUT}  600  # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  600  # Timeout for ping regain during reset


*** Keywords ***
TC__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5213
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5213 - initial creation
    ...  - 18.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-6774 - Changes resources path, and ute_infomodel keywords to ute_admin
    ...  - 20.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-8081 - Change BTS_L-*
    ...  - 01.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9274 - Name changed, ACTIVE/PASSIVE_SW_PATTERN variable removed
    ...  - 29.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-9760 - Restore config from config.bak on passive partition
    ...  - 09.08.2018 - https://jira3.int.net.nokia.com/browse/TAT-10994 - Added timeout to modules states verification
    ...  - 13.08.2018 - https://jira3.int.net.nokia.com/browse/TAT-11803 - Bug fixed in step 6
    ...  - 30.08.2018 - https://jira3.int.net.nokia.com/browse/TAT-11970 - Bug fixed when PASSIVE_SW_STATE is notcommissioned
    ...  - 17.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-15966 - Adding possibility to force admin and infomodel connection after rollback
    ...  - 17.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16602 - Increasing max_downtime duration due to longer ping lost time during
    ...           rollback on dualcore
    ...  - 05.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17398 - TC OWNER changed
    ...  - 17.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17476 - Add waiting for reset after rollback
    ...  - 09.03.2020 - https://jira3.int.net.nokia.com/browse/TAT-19177 - Allow to trigger rollback when T1 package is active SW and base package
    ...           (not T1) is passive SW
    ...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24946 - Replace hran_tools with taf.sw.ping
    ...  - 19.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28168 - Include a check for fault 4592
    ...  - 20.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28460 - Adding software filtering
    ...  - 10.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28582 - Increasing the timer for fault 4592
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29103 - Update testcases and resourses for CB011146
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-5213.png#

    Set Tags  CA-SWM  PHASE-COMPA  PHASE-CIT  GROUP_IN_CHARGE-TIM_2_Vrf  SW-SBTS17  SW-SBTS18  SW-SBTS19  OWNER-tomasz.zadworny@nokia.com
    ...  AUTHOR-jaroslaw.piszczala@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com  FEATURE-RP001486_RP000938  FEATURE-RP001145_RP000938
    ...  FEATURE-RP001809  FEATURE-RP002035  FEATURE-RP001966  FEATURE-RP002179

    TC Preconditions
    Step1: Check Active And Passive Sw Version
    Step2: Software Rollback
    Step3: Wait Till BTS Is Stable And Ensure Admin Connectivity
    Step4: Check Software Version
    Step5: Check If Active Sw Is Commisioned
    Step6: BTS State Verification
    Step7: Check Fault 4592


TC Preconditions
    Log Step Header  ${\n}TC Preconditions
    Run Keyword And Ignore Error  Restore config from config.Bak On Passive Partition


Step1: Check Active And Passive Sw Version
    Log Step Header  Step1: Check active and passive sw version
    ${sw_pattern}  Set Variable  SBTS(?!16)
    ${active_sw_before}  ${passive_sw_before}  Infomodel Get SW Versions
    Set Tags  SW_BEFORE_ROLLBACK_active-${active_sw_before}
    Set Tags  SW_BEFORE_ROLLBACK_passive-${passive_sw_before}
    ${active_status}  Run Keyword And Return Status  Should Match Regexp  ${active_sw_before}  (?i)${sw_pattern}
    IF  ${active_status}==${FALSE}  FAIL  ${active_sw_before} not match ${sw_pattern} pattern.
    ${passive_status}  Run Keyword And Return Status  Should Match Regexp  ${passive_sw_before}  (?i)${sw_pattern}
    IF  ${passive_status}==${FALSE}  FAIL  ${passive_sw_before} not match ${sw_pattern} pattern
    Should Not Be Equal  ${active_sw_before}  ${passive_sw_before}  msg=${active_sw_before} match ${passive_sw_before} pattern  ignore_case=${TRUE}

    Set Test Variable  ${ACTIVE_SW_BEFORE}
    Set Test Variable  ${PASSIVE_SW_BEFORE}
    Log  Active and passive software match given patterns  console=true


Step2: Software Rollback
    Log Step Header  Step2: Software rollback
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${start_time}
    ${rollback_status}  Run Keyword And Return Status  Rollback Software
    IF  ${rollback_status}==${FALSE}  FAIL  Software rollback was not performed.
    Log  Software rollback ended successfully.  console=true
    Log  Will wait for ping loss  console=true
    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_LOSS_TIMEOUT}
    IF  ${ping_loss_status}
      Log  BTS is resetting after successful rollback  console=true
    ELSE
      Fail  BTS RESET after successful rollback DID NOT OCCUR
    END
    ${ping_regain_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_REGAIN_TIMEOUT}
    IF  ${ping_regain_status}
      Log  Ping regained after successful rollback  console=true
    ELSE
      Set Test Failed  Ping has not been regained within timeout
    END


Step3: Wait Till BTS Is Stable And Ensure Admin Connectivity
    Log Step Header  Step3: Wait till BTS is stable and ensure admin connectivity
    Log  Will check if BTS is stable  console=true
    ${ping_status}  Check If Target Is Stable  ip=${OAM_BTS_IP}  min_uptime=300  max_downtime=420  timeout=1200
    IF  ${ping_status}
      Log  BTS is stable after rollback.  console=true
    ELSE
      FAIL  BTS is not stable after rollback.
    END
    Log  BTS is stable after rollback.  console=true
    ${admin_working_state}  Run Keyword And Return Status  sbts_admin.Admin And Infomodel Connections Reset  ${CONNECTION_RESET_ON_DEMAND}
    IF  ${admin_working_state}==${FALSE}  Fail  Admin and/of infomodel failure after reset. Interface reset did not help.  console=true


Step4: Check Software Version
    Log Step Header  Step4: Check software version
    ${active_sw_after}  ${passive_sw_after}  Infomodel Get SW Versions

    Set Tags  SW_AFTER_ROLLBACK_active-${active_sw_after}
    Set Tags  SW_AFTER_ROLLBACK_passive-${passive_sw_after}

    ${active_sw_before}  Get Regexp Matches  ${ACTIVE_SW_BEFORE}  SBTS([09]{,2})(.)*
    ${active_sw_before}  Get From List  ${active_sw_before}  0

    ${active_sw_after}  Get Regexp Matches  ${active_sw_after}  SBTS([09]{,2})(.)*
    ${active_sw_after}  Get From List  ${active_sw_after}  0

    ${active_status}  Run Keyword And Return Status  Should Match Regexp  ${active_sw_after}  (?i)${PASSIVE_SW_BEFORE}
    IF  ${active_status}==${FALSE}  FAIL  ${active_sw_after} not match ${PASSIVE_SW_BEFORE} pattern
    ${passive_status}  Run Keyword And Return Status  Should Match Regexp  ${active_sw_before}  (?i)${passive_sw_after}
    IF  ${passive_status}==${FALSE}  FAIL  ${active_sw_before}  not match ${passive_sw_after} pattern
    Log  Active and passive software match given patterns  console=true


Step5: Check If Active Sw Is Commisioned
    Log Step Header  Step5: Check if active sw is commisioned
    ${is_commissioned}  Run Keyword And Return Status  Query Infomodel  every //SCF-* is [stateInfo.proceduralState=validated]
    Set Test Variable  ${IS_COMMISSIONED}  ${is_commissioned}
    IF  ${IS_COMMISSIONED}
      Log  Active sw is commisioned  console=true
    ELSE
      Log  Active sw is not commisioned  console=true
    END


Step6: BTS State Verification
    Log Step Header  Step6: BTS state verification
    ${status}  Wait Until Cells And Modules States Are As Expected
    IF  ${status}
      Log  BTS is operational  console=true
    ELSE
      Set Test Failed  Not all modules/cells are in the expected state. Check logs
    END

    ${critical_alarm}  Create Dictionary  severity=Critical|Major
    ${critical}  Create List  ${critical_alarm}
    ${status}  ${alarms_msg}  Run Keyword And Ignore Error  Admin Check Active Alarms TAF  critical_patterns=${critical}
    IF  '${status}'=='FAIL'
      Set Test Failed  Critical fail while checking alarms: ${alarms_msg}
    ELSE IF  ${alarms_msg}
      Set Test Restriction  Unexpected alarms are present: ${alarms_msg}
    END

    Check If TC Should Fail Due TC Variable


Step7: Check Fault 4592
    Log  Step7: Check Fault 4592  console=true
    ${active_sw}  Get Sw Version
    ${sw_version}  Fetch From Left  ${active_sw}  _
    IF  '${sw_version}' >= 'SBTS24R3'
      Initiating Alarm 4592 Verification If Needed
    ELSE
      Log  Active software is ${sw_version}. The check of alarm 4592 will not start.  console=true
    END


Initiating Alarm 4592 Verification If Needed
    ${date}  Get BTS time in UTC format  %Y-%m-%d %H
    Sleep  80  TC waits 80s for fault to be loaded in history.
    ${historical_alarms}  Get Historic Alarms  severity=warning
    FOR  ${alarm}  IN  @{historical_alarms}
        ${status_alarm}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultId]  ${FAULT_4592}[fault_id]
        ${gmt_string}  Remove String  ${alarm}[btsObservationTimezone]  :
        ${gmt_time}  Fetch From Right  ${gmt_string}  +
        ${status_suppl_info}  Run Keyword And Return Status
        ...  Should Match Regexp  ${alarm}[alarmText][alarmAdditionalInfo][supplAlarmInfo]
        ...  BTS booted at ${date}:\\d{2}:\\d{2} GMT\\+${gmt_time} due to software rollback
        IF  ${status_alarm} and ${status_suppl_info}
          Log  Alarm 7115 "${FAULT_4592}[alarm_name]" has the correct supplementary info in historical alarms in WebEM. [OK]  console=true
          Set Test Variable  ${SUPPL_INFO}  BTS booted at ${date}:\\d{2}:\\d{2} GMT\\+${gmt_time} due to software rollback
          BREAK
        END
    END
    IF  ${status_suppl_info}==${FALSE}  Log  Alarm "${FAULT_4592}[fault_name]" is not visible correctly in WebEM. [OK]  ERROR  console=true

    IF  ${STATUS_NETACT}  Checking Netact Integration State And Alarm in Cleared Alarms In Netact  &{FAULT_4592}  time_from=${START_TIME}
    ...  suppl_info=.*${SUPPL_INFO}.*


Restore Config From Config.Bak On Passive Partition
    Log  Restore config on passive partition  console=true
    ${rc}  Run Keyword And Return Status  Execute Command On SM Via SSH  ${OAM_BTS_IP}  [ -d "/ffs/stb/config.bak" ]
    IF  ${rc}
      Log  Config.bak exist on passive partition, and will be restored  console=true
      Execute Command On SM Via SSH  ${OAM_BTS_IP}  mv /ffs/stb/config.bak /ffs/stb/config
    END


Wait Until Cells And Modules States Are As Expected
    ${state}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  15s  Assert All Cells Are In Expected State

    [Return]  ${state}


Fail If Not All Cells Or Modules States Are As Expected
    IF  ${IS_COMMISSIONED}  Assert Alll Cells Are In Expected State

    ${modules_status}  Verify Modules States
    IF  ${modules_status}
      Log  All modules are in expected states  console=true
    ELSE
      Fail  Not all modules are in expected states
    END


Check If TC Should Fail Due TC Variable
    ${is_empty}  Run Keyword And Return Status  Should Be Empty  ${PASSIVE_SW_STATE}
    IF  ${is_empty}  RETURN
    IF  '${PASSIVE_SW_STATE}' == 'commissioned' and not ${IS_COMMISSIONED}  Set Test Failed  Passive SW should be commissioned
    IF  '${PASSIVE_SW_STATE}' == 'notcommissioned' and ${IS_COMMISSIONED}  Set Test Failed  Passive SW should be notcommissioned


TC Setup
    Common Test Setup  tc_name=SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    ${status_netact}  Run Keyword And Return Status  Setup Netact
    Set Test Variable  ${STATUS_NETACT}  ${status_netact}
    IF  ${status_netact}
      Log  SBTS is integrated into Netact. Alarm check will follow.  console=true
    ELSE
      Log  SBTS is not integrated into Netact. Alarm check will be skipped.  console=true
    END


TC Teardown
    IF  ${STATUS_NETACT}  Teardown NetAct
    Common Test Teardown