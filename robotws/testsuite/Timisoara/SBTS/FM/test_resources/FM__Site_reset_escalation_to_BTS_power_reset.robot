*** Settings ***
Documentation
    ...  Test case will verify that after software update, if enforcedRecoTimeWindow is active, power resets on sBTS are allowed
    ...  for the list of faults covered in this feature.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${BBMOD_SN}  ${EMPTY}  # Optional. BBMOD serial number for test.
${BBMOD_TYPE}  ${EMPTY}  # Optional. BBMOD type for test.
${STARTUP_TIMEOUT}  900  # [in seconds] Timeout for SBTS to recover after site reset.
${RECOVERY_TIMEOUT}  600  # [in seconds] Timeout for SBTS to recover after test scenario.
${PING_TIMEOUT}  240  # [in seconds] Timeout for ping loss during reset.
${ALARM_TIMEOUT}  600  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  360  # [in seconds] Timeout for alarm to appear in Netact.
${PING_LOSS_TIMEOUT}  900  # [in seconds] Timeout for ping loss after sw rollback.
${PING_REGAIN_TIMEOUT}  600  # [in seconds] Timeout for ping regain after sw rollback.
${RESTORE_TIMEOUT}  1800  # [in seconds] Timeout for waiting until cells are onAir after rollback.


*** Keywords ***
TC__FM__Site_reset_escalation_to_BTS_power_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26012
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  22.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26012 - Initial TAT creation
    ...  25.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26309 - Update query based board
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  29.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26529 - Testcase fails at checking severity in Netact
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  06.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26772 - Option to disable alarm check on MantaRay
    ...  07.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26886 - Fix variable overwriting
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  29.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27231 - Change alarm fields evaluation
    ...  20.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27780 - Add check for fault 4592
    ...  20.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28105 - Change fault4592CancellationTimer value
    ...  17.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28556 - Test fails at Check Escalation To Site Reset keyword
    ...  27.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28938 - Move keyword to resource
    ...  08.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29852 - Fix receiver for fault generator with master on the right side
    ...  16.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29887 - Keyword fails and leaves SBTS in wrong SW
    ...  15.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29951 - Checking and integration with Netact after roolbacks
    ...  *******************

    Set Tags  CA-FM  OWNER-florin-sebastian.nedelcu@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB010883  FEATURE-CB007964

    Step0: Set Test Variables
    Step1: Escalation To BTS Power Reset


Step0: Set Test Variables
    Log  Step0: Set test variables.  console=true
    IF  '${BBMOD_SN}' != ''
      Set BBMOD Object By Serial Number  ${BBMOD_SN}
    ELSE
      Set BBMOD From Configuration
    END
    Check If BBMOD Is On Primary/secondary Core
    Set Variables For Fault Generation
    Set Cells Mapped On FSP
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${start_time}
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Change FMCADM parameter  fault4592CancellationTimer  150
    Log  Performing software rollback to pasive SW.  console=true
    Perform software rollback and check BTS state  ${RESTORE_TIMEOUT}  ${PING_LOSS_TIMEOUT}  ${PING_REGAIN_TIMEOUT}
    Check active and pasive software versions to be set correctly  ${passive SW version}  ${active SW version}
    ${date_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Log  Performing software rollback to target SW.  console=true
    Perform software rollback and check BTS state  ${RESTORE_TIMEOUT}  ${PING_LOSS_TIMEOUT}  ${PING_REGAIN_TIMEOUT}
    Check active and pasive software versions to be set correctly  ${active SW version}  ${passive SW version}

    ${netact_info}  coam.Get Nms State
    ${manager_id}  Get Manager Id For NetAct  ${netact_info}
    IF  '${manager_id}' == '${EMPTY}'
        Log  NetAct web_url is missing. Netact should be reintegrate.  console=true
        Integrate SBTS To NetAct
    ELSE
        Log  Integration to netact not lost. Reintegration not needed. Test will continue. [OK]  console=true
    END

    IF  '${ENB_BRANCH}' >= 'SBTS24R3'
      Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  60s  Check Fault 4592 Information In WebEM Alarm History  software rollback
      Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  60s  Check Fault 4592 Information In Netact Alarm History  software rollback  ${date_time}
    END
    ${active_partition_id}  ${passive_partition_id}  Get Active And Passive Partitions Ids
    Set Test Variable  ${ACTIVE_PARTITION_ID}  ${active_partition_id}


Step1: Escalation To BTS Power Reset
    Log  Step1: Escalation to BTS power reset.  console=true
    IF  ${CHECK_SECONDARY}
      Trigger BTS Power Reset From Secondary Core Escalation
    ELSE
      Trigger BTS Power Reset From Primary Core Escalation
    END
    Sleep  ${NETACT_TIMEOUT}s  Wait for alarm history update in Netact.
    Check Alarm History In Netact


Trigger BTS Power Reset From Secondary Core Escalation
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Change FMCADM parameter  fault4592CancellationTimer  60
    Trigger FSP Warm Reset
    Trigger FSP Warm Reset And Check Following FSP Power Reset
    Check Escalation To Secondary Core Reset
    Check Second Secondary Core Reset And Escalation To Site Reset
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Change FMCADM parameter  fault4592CancellationTimer  210
    Trigger FSP Warm Reset
    Trigger FSP Warm Reset And Check Following FSP Power Reset
    Check Escalation To Secondary Core Reset
    Check Second Secondary Core Reset And Escalation To BTS Power Reset


Trigger BTS Power Reset From Primary Core Escalation
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Change FMCADM parameter  fault4592CancellationTimer  60
    Trigger FSP Warm Reset
    Trigger FSP Warm Reset And Check Following FSP Power Reset
    Check Escalation To Site Reset
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Change FMCADM parameter  fault4592CancellationTimer  210
    Trigger FSP Warm Reset
    Trigger FSP Warm Reset And Check Following FSP Power Reset
    Check Escalation To BTS Power Reset


Trigger FSP Warm Reset
    Log  Trigger FSP warm reset.  console=true
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_warm_reset
    ${fault_bb_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_2078_BB_AUTO_RST}
    ${check_warm_reset}  Run Keyword In Background  Assert alarm active  parameters=${fault_bb_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    ...  alias=check_warm_reset
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  ${FAULT_2078_BB_AUTO_RST}[fault_id]  ${NODE_ID}  2
    Wait Until Keyword Succeeds  120  10  Checking Cells On The Given FSP  ${CELLS_LIST_ON_FSP}  ${FAILED}  ${DISABLED}
    ${check_result}  Run Keyword And Return Status  Collect Keyword Result  ${check_warm_reset}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_result}  Fault ${FAULT_2078_BB_AUTO_RST} was not active in WebEM.
    Log  Fault ${FAULT_2078_BB_AUTO_RST} was active in WebEM.  console=true

    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Should Be True  ${cells_status}  Cells didn't reached on air state after recovery.
    Log  Cells reached on air state after recovery.  console=true
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_warm_reset


Trigger FSP Warm Reset And Check Following FSP Power Reset
    Log  Trigger FSP warm reset and check following FSP power reset.  console=true
    Add 0x2005B Flag To Swconfig
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_warm_reset
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_power_reset
    ${fault_bb_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_2078_BB_AUTO_RST}
    ${check_warm_reset}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_bb_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    ...  alias=check_warm_reset
    ${fault_bb_power_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_69_BB_POWER_AUTO_RST}
    ${check_power_reset}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_bb_power_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    ...  alias=check_power_reset
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  ${FAULT_2078_BB_AUTO_RST}[fault_id]  ${NODE_ID}  2
    Wait Until Keyword Succeeds  120  10  Checking Cells On The Given FSP  ${CELLS_LIST_ON_FSP}  ${FAILED}  ${DISABLED}

    ${check_first_result}  Run Keyword And Return Status  Collect Keyword Result  ${check_warm_reset}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_first_result}  ${FAULT_2078_BB_AUTO_RST} was not active in WebEM.
    Log  Fault ${FAULT_2078_BB_AUTO_RST} was active in WebEM.  console=true
    ${check_second_result}  Run Keyword And Return Status  Collect Keyword Result  ${check_power_reset}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_second_result}  Fault ${FAULT_69_BB_POWER_AUTO_RST} was not active in WebEM.
    Log  Fault ${FAULT_69_BB_POWER_AUTO_RST} was active in WebEM.  console=true

    Run Keyword And Continue On Failure  Teardown Admin  alias=check_warm_reset
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_power_reset


Check Escalation To Secondary Core Reset
    Log  Check escalation to secondary core reset.  console=true
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_escalation_secondary
    ${fault_2nd_core_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_69_2_ND_CORE_AUTO_RST}
    ${check_escalation_secondary}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_2nd_core_auto_rst_params}
    ...  timeout=${ALARM_TIMEOUT}  alias=check_escalation_secondary
    IF  ${SCF_COUNT_WCDMA}  Assert Any  WNCEL  operationalState=${DISABLED}, availabilityStatus=${OFFLINE}  timeout=120
    ${check_escalation_result}  Run Keyword And Return Status  Collect Keyword Result  ${check_escalation_secondary}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_escalation_result}  Fault ${FAULT_69_2_ND_CORE_AUTO_RST} was not active in WebEm.
    Log  Fault ${FAULT_69_2_ND_CORE_AUTO_RST} was active in WebEm.  console=true

    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=192.168.255.119  timeout=${PING_TIMEOUT}  remote_host=${PC_IP2}
    IF  ${ping_loss_status}
      Log  Ping is lost.  console=True
    ELSE
      Set Test Restriction  Ping has not been lost within timeout.
    END
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=192.168.255.119  timeout=${PING_TIMEOUT}  remote_host=${PC_IP2}
    IF  ${ping_regain_status}
      Log  Target is reachable.  console=True
    ELSE
      Set Test Restriction  Ping has not been regained within timeout.
    END
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_escalation_secondary


Check Second Secondary Core Reset And Escalation To Site Reset
    Log  Check second secondary core reset and escalation to site reset.  console=true
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_escalation_secondary
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_escalation_site
    ${date_autonomous_reset}  Get Current Date  time_zone=UTC  result_format=datetime
    ${fault_2nd_core_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_69_2_ND_CORE_AUTO_RST}
    ${check_escalation_secondary}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_2nd_core_auto_rst_params}
    ...  timeout=${ALARM_TIMEOUT}  alias=check_escalation_secondary
    ${fault_site_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_69_SITE_AUTO_RST}
    ${check_escalation_site}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_site_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    ...  alias=check_escalation_site
    ${check_result_secondary}  Run Keyword And Return Status  Collect Keyword Result  ${check_escalation_secondary}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_result_secondary}  Fault ${FAULT_69_2_ND_CORE_AUTO_RST} was not active in WebEm.
    Log  Fault ${FAULT_69_2_ND_CORE_AUTO_RST} was active in WebEm.  console=true
    ${check_result_site}  Run Keyword And Return Status  Collect Keyword Result  ${check_escalation_site}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_result_site}  Fault ${FAULT_69_SITE_AUTO_RST} was not active in WebEm.
    Log  Fault ${FAULT_69_SITE_AUTO_RST} was active in WebEm.  console=true

    Wait Until Keyword Succeeds  ${PING_TIMEOUT}  10  Remove 0x2005B Flag From Swconfig
    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=192.168.255.129  timeout=${PING_TIMEOUT}
    IF  ${ping_loss_status}
      Log  Ping is lost.  console=True
    ELSE
      Set Test Restriction  Ping has not been lost within timeout.
    END
    ${ping_regain_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=192.168.255.129  timeout=${PING_TIMEOUT}
    IF  ${ping_regain_status}
      Log  Target is reachable.  console=True
    ELSE
      Set Test Restriction  Ping has not been regained within timeout.
    END
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10
    ...  Check All Cells
    Should Be True  ${cells_status}  Cells didn't reached on air state after recovery.
    Log  Cells reached on air state after recovery.  console=true
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_escalation_secondary
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_escalation_site
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'
      Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  60s  Check Fault 4592 Information In WebEM Alarm History  recovery
      Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  60s  Check Fault 4592 Information In Netact Alarm History  recovery  ${date_autonomous_reset}
    END


Check Escalation To Site Reset
    Log  Check escalation to site reset.  console=true
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_escalation_site
    ${date_autonomous_reset}  Get Current Date  time_zone=UTC  result_format=datetime
    ${fault_site_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_69_SITE_AUTO_RST}
    ${check_escalation_site}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_site_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    ...  alias=check_escalation_site
    IF  ${SCF_COUNT_WCDMA}
      Assert Any  WNCEL  operationalState=${DISABLED}, availabilityStatus=${OFFLINE}  timeout=300
    ELSE IF  ${SCF_COUNT_GSM}
      Assert Any  GNCEL  operationalState=${DISABLED}, availabilityStatus=${OFFLINE}  timeout=300
    END
    Remove 0x2005B Flag From Swconfig
    ${check_escalation_result}  Run Keyword And Return Status  Collect Keyword Result  ${check_escalation_site}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_escalation_result}  Fault ${FAULT_69_SITE_AUTO_RST} was not active in WebEM.
    Log  Fault ${FAULT_69_SITE_AUTO_RST} was active in WebEM.  console=true

    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=192.168.255.129  timeout=${PING_TIMEOUT}
    IF  ${ping_loss_status}
      Log  Ping is lost.  console=True
    ELSE
      Set Test Restriction  Ping has not been lost within timeout.
    END
    ${ping_regain_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=192.168.255.129  timeout=${PING_TIMEOUT}
    IF  ${ping_regain_status}
      Log  Target is reachable.  console=True
    ELSE
      Set Test Restriction  Ping has not been regained within timeout.
    END
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10
    ...  Check All Cells
    Should Be True  ${cells_status}  Cells didn't reached on air state after recovery.
    Log  Cells reached on air state after recovery.  console=true
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_escalation_site
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'
      Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  60s  Check Fault 4592 Information In WebEM Alarm History  recovery
      Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  60s  Check Fault 4592 Information In Netact Alarm History  recovery  ${date_autonomous_reset}
    END


Check Second Secondary Core Reset And Escalation To BTS Power Reset
    Log  Check second secondary core reset and escalation to BTS power reset.  console=true
    ${date_power_on}  Get Current Date  time_zone=UTC  result_format=datetime
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_escalation_secondary
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_power_reset
    ${fault_2nd_core_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_69_2_ND_CORE_AUTO_RST}
    ${check_escalation_secondary}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_2nd_core_auto_rst_params}
    ...  timeout=${ALARM_TIMEOUT}  alias=check_escalation_secondary
    ${fault_site_power_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_69_SITE_POWER_AUTO_RST}
    ${check_power_reset}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_site_power_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    ...  alias=check_power_reset
    ${check_result_secondary}  Run Keyword And Return Status  Collect Keyword Result  ${check_escalation_secondary}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_result_secondary}  Fault ${FAULT_69_2_ND_CORE_AUTO_RST} was not active in WebEm.
    Log  Fault ${FAULT_69_2_ND_CORE_AUTO_RST} was active in WebEm.  console=true

    ${check_result_power}  Run Keyword And Return Status  Collect Keyword Result  ${check_power_reset}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_result_power}  Fault ${FAULT_69_SITE_POWER_AUTO_RST} was not active in WebEm.
    Log  Fault ${FAULT_69_SITE_POWER_AUTO_RST} was active in WebEm.  console=true

    Wait Until Keyword Succeeds  ${PING_TIMEOUT}  10  Remove 0x2005B Flag From Swconfig
    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=192.168.255.129  timeout=${PING_TIMEOUT}
    IF  ${ping_loss_status}
      Log  Ping is lost.  console=True
    ELSE
      Set Test Restriction  Ping has not been lost within timeout.
    END
    ${ping_regain_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=192.168.255.129  timeout=${PING_TIMEOUT}
    IF  ${ping_regain_status}
      Log  Target is reachable.  console=True
    ELSE
      Set Test Restriction  Ping has not been regained within timeout.
    END
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10
    ...  Check All Cells
    Should Be True  ${cells_status}  Cells didn't reached on air state after recovery.
    Log  Cells reached on air state after recovery.  console=true
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_escalation_secondary
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_power_reset
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'
      Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  60s  Check Fault 4592 Information In WebEM Alarm History  recovery
      Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  60s  Check Fault 4592 Information In Netact Alarm History  recovery  ${date_power_on}
    END


Check Escalation To BTS Power Reset
    Log  Check escalation to BTS power reset.  console=true
    ${date_power_on}  Get Current Date  time_zone=UTC  result_format=datetime
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_power_reset
    ${fault_site_power_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_69_SITE_POWER_AUTO_RST}
    ${check_power_reset}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_site_power_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    ...  alias=check_power_reset
    IF  ${SCF_COUNT_WCDMA}
      Assert Any  WNCEL  operationalState=${DISABLED}, availabilityStatus=${OFFLINE}  timeout=300
    ELSE IF  ${SCF_COUNT_GSM}
      Assert Any  GNCEL  operationalState=${DISABLED}, availabilityStatus=${OFFLINE}  timeout=300
    END
    Remove 0x2005B Flag From Swconfig

    ${check_escalation_result}  Run Keyword And Return Status  Collect Keyword Result  ${check_power_reset}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_escalation_result}  Fault ${FAULT_69_SITE_POWER_AUTO_RST} was not active in WebEM.
    Log  Fault ${FAULT_69_SITE_POWER_AUTO_RST} was active in WebEm.  console=true

    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=192.168.255.129  timeout=${PING_TIMEOUT}
    IF  ${ping_loss_status}
      Log  Ping is lost.  console=True
    ELSE
      Set Test Restriction  Ping has not been lost within timeout.
    END
    ${ping_regain_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=192.168.255.129  timeout=${PING_TIMEOUT}
    IF  ${ping_regain_status}
      Log  Target is reachable.  console=True
    ELSE
      Set Test Restriction  Ping has not been regained within timeout.
    END
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10
    ...  Check All Cells
    Should Be True  ${cells_status}  Cells didn't reached on air state after recovery.
    Log  Cells reached on air state after recovery.  console=true
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_power_reset
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'
      Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  60s  Check Fault 4592 Information In WebEM Alarm History  recovery
      Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  60s  Check Fault 4592 Information In Netact Alarm History  recovery  ${date_power_on}
    END


Check Alarm History In Netact
    IF  '${DISABLE_NETACT_CHECK}' == 'True'
      Log  Netact check is disabled, check will be skipped.  console=true
      RETURN
    END
    Log  Check alarm history in Netact.  console=true
    ${time_to}  Get Current Date  time_zone=UTC  result_format=datetime
    ${netact_alarms}  netact.Get_cleared_alarms  dist_name=${MRBTS_DN}  time_from=${START_TIME}  time_to=${time_to}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${event_type_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[eventType]  PROCESSINGERROR
        ${additional_text1_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[additionalText1]  None
        ${additional_text3_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${na_alarm}[additionalText3]  None
        IF  ${event_type_status} or ${additional_text1_status} or ${additional_text3_status}  Remove Values From List  ${netact_alarms}  ${na_alarm}
    END
    ${warm_reset_bbmod}  Set Variable  4
    ${power_reset_bbmod}  Set Variable  2
    ${escalation_site_reset}  Set Variable  1
    ${escalation_power_reset_site}  Set Variable  1
    ${escalation_secondary_reset}  Set Variable If  ${CHECK_SECONDARY}  4  0
    Check Number Of Occurrences In Netact  alarms_list=${netact_alarms}  number=${warm_reset_bbmod}  &{FAULT_2078_BB_AUTO_RST}
    Check Number Of Occurrences In Netact  alarms_list=${netact_alarms}  number=${power_reset_bbmod}  &{FAULT_69_BB_POWER_AUTO_RST}
    Check Number Of Occurrences In Netact  alarms_list=${netact_alarms}  number=${escalation_secondary_reset}  &{FAULT_69_2_ND_CORE_AUTO_RST}
    Check Number Of Occurrences In Netact  alarms_list=${netact_alarms}  number=${escalation_site_reset}  &{FAULT_69_SITE_AUTO_RST}
    Check Number Of Occurrences In Netact  alarms_list=${netact_alarms}  number=${escalation_power_reset_site}  &{FAULT_69_SITE_POWER_AUTO_RST}


Check Number Of Occurrences In Netact
    [Arguments]
    ...  ${alarms_list}=${None}
    ...  ${number}=${None}
    ...  ${fault_id}=${None}
    ...  ${fault_name}=${None}
    ...  ${alarm_id}=${None}
    ...  ${alarm_name}=${None}
    ...  ${severity}=${None}

    ${mached_alarms_list}  Create List
    FOR  ${alarm}  IN  @{alarms_list}
        ${text3}  Get From Dictionary  ${alarm}  additionalText3
        ${fault_id_na}  Fetch From Left  ${text3}  ${SPACE}
        ${check_fault_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${fault_id}  ${fault_id_na}
        ${additional_text1}  Get From Dictionary  ${alarm}  additionalText1
        ${check_fault_name}  Run Keyword And Return Status  Should Be Equal  ${fault_name}  ${additional_text1}
        ${specific_problem}  Get From Dictionary  ${alarm}  specificProblem
        ${check_alarm_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm_id}  ${specific_problem}
        ${alarm_text}  Get From Dictionary  ${alarm}  alarmText
        ${check_alarm_name}  Run Keyword And Return Status  Should Be Equal  ${alarm_name}  ${alarm_text}
        ${alarm_additional_attributes}  Get From Dictionary  ${alarm}  additionalAttributes
        ${alarm_severity}  Set Variable  ${alarm_additional_attributes}[severity]
        ${severity_uppercase}  Convert To Upper Case  ${severity}
        ${check_severity}  Run Keyword And Return Status  Should Be Equal  ${severity_uppercase}  ${alarm_severity}
        ${match_condition}  Catenate  ${check_fault_id} and ${check_fault_name} and ${check_alarm_id} and ${check_alarm_name} and ${check_severity}
        IF  ${match_condition}  Append To List  ${mached_alarms_list}  ${alarm}
    END
    ${number_of_occurrences}  Get Length  ${mached_alarms_list}
    ${compare_alarm_count}  Run Keyword And Return Status  Should Be Equal As Strings  ${number_of_occurrences}  ${number}
    IF  ${compare_alarm_count}
      Log  Alarms found in Netact.  console=True
    ELSE
      Fail  Alarms not found in Netact.
    END


Set BBMOD Object By Serial Number
    [Arguments]  ${bbmod_serial_number}

    ${bbmods_list}  Get Parameters For All  BBMOD
    FOR  ${object}  IN  @{bbmods_list}
        ${match}  Run Keyword And Return Status  Should Be Equal  ${bbmod_serial_number}  ${object}[serialNumber]
        ${bbmod}  Set Variable If  ${match}  ${object}
        IF  ${match}  BREAK
    END
    Set Test Variable  ${BBMOD_DN}  ${bbmod}[id]
    ${bbmod_l}  Query Infomodel  get object //BBMOD_L-* is [serialNumber=${bbmod_serial_number}]
    Set Test Variable  ${BBMOD_L}  ${bbmod_l}


Set BBMOD From Configuration
    ${bbmods_list}  Get Parameters For All  BBMOD
    ${bbmods_for_test}  Create List
    ${type}  Create List
    Append To List  ${type}  NRCELL  LNCEL
    FOR  ${object}  IN  @{bbmods_list}
        ${cells_on_bbmod}  Get Cell Mapping By Module Id  ${object}[id]
        ${cells_match}  Check Cells Type  ${cells_on_bbmod}  ${type}
        IF  ${cells_match}  Append To List  ${bbmods_for_test}  ${object}
    END
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${bbmods_for_test}
    IF  ${status}
      Log  BBMOD with cells ${type} found in configuration.  console=true
    ELSE
      Fail  BBMOD with cells ${type} not found in configuration.
    END
    ${is_bbmod_defined}  Run Keyword And Return Status  Should Not Be Empty  ${BBMOD_TYPE}
    ${bbmod_chosen}  Evaluate  random.choice(${bbmods_for_test})  random
    IF  ${is_bbmod_defined}
      Set Chosen BBMOD Object From Available BBMODs  ${bbmods_for_test}
    ELSE
      Set Test Variable  ${BBMOD}  ${bbmod_chosen}
    END
    Log  BBMOD for test is: ${BBMOD}  console=true
    Set Test Variable  ${BBMOD_DN}  ${BBMOD}[id]
    ${bbmod_l}  Query Infomodel  get object //BBMOD_L-* is [serialNumber=${BBMOD}[serialNumber]]
    Set Test Variable  ${BBMOD_L}  ${bbmod_l}


Set Chosen BBMOD Object From Available BBMODs
    [Arguments]  ${bbmods_list}

    ${defined_bbmods}  Create List
    FOR  ${bbmod}  IN  @{bbmods_list}
        ${match}  Run Keyword And Return Status  Should Contain  ${bbmod}[productName]  ${BBMOD_TYPE}
        IF  ${match}  Append To List  ${defined_bbmods}  ${bbmod}
    END
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${defined_bbmods}
    IF  ${status}
      Log  ${BBMOD_TYPE} for test found in configuration.  console=true
    ELSE
      Fail  ${BBMOD_TYPE} for test not found in configuration.
    END
    ${bbmod_chosen}  Evaluate  random.choice(${defined_bbmods})  random
    Set Test Variable  ${BBMOD}  ${bbmod_chosen}


Set Variables For Fault Generation
    ${receiver}  Set Variable If  'BTS_L-1' in '${BBMOD_L}[dist_name]'  269554178  537989634
    ${bbu_exist}  Run Keyword And Return Status  Query Infomodel  check ${BBMOD_L.dist_name}/BBU_L-1
    ${bbu_string}  Set Variable If  ${bbu_exist}  ${BBMOD_L.dist_name}/BBU_L-1  ${BBMOD_L.dist_name}/BOARD_L-1
    ${cpu_l}  Query Infomodel  get object ${bbu_string}/POWER_GROUP_L-1/SOC_L-1/CPU_L-1
    ${cpu_nodeid}  Convert To Hex  ${cpu_l}[nodeId]
    ${sender}  Convert To Integer  0X${cpu_nodeid}04B5
    Set Test Variable  ${SENDER}  ${sender}
    Set Test Variable  ${RECEIVER}  ${receiver}
    ${bbu_l}  Query Infomodel  get object ${bbu_string}
    Set Test Variable  ${NODE_ID}  ${bbu_l}[nodeId]


Check If BBMOD Is On Primary/secondary Core
    ${string_bts}  Fetch From Left  ${BBMOD_L}[dist_name]  /EQM_L-1
    ${bts_l}  Query Infomodel  get object ${string_bts}
    ${check}  Set Variable If  '${bts_l}[storedRole]' == 'Idle'  True  False
    Set Test Variable  ${CHECK_SECONDARY}  ${check}


Add 0x2005B Flag To Swconfig
    Open Connection To Primary Core
    IF  ${CHECK_SECONDARY}  Open Connection To Secondary Core
    SSHLibrary.Write  echo 0x2005B=1 >> /rom/config/fsp/swconfig_local.txt
    SSHLibrary.Read Until Prompt
    Log  0x2005B flag added to swconfig.  console=true


Remove 0x2005B Flag From Swconfig
    Open Connection To Primary Core
    IF  ${CHECK_SECONDARY}  Open Connection To Secondary Core
    SSHLibrary.Write  rm -rf /rom/config/fsp/swconfig_local.txt
    SSHLibrary.Read Until Prompt
    Log  0x2005B flag removed from swconfig.  console=true


Recover Action
    Wait Until Keyword Succeeds  ${PING_TIMEOUT}  10  Remove 0x2005B Flag From Swconfig
    Change FMCADM parameter  fault4592CancellationTimer  30
    Recover SBTS If Passive SW Is Active


TC Setup
    Common Test Setup  tc_name=FM__Site_reset_escalation_to_BTS_power_reset
    Setup NetAct


TC Teardown
    Run Keyword And Ignore Error  Recover Action
    Teardown NetAct
    Common Test Teardown