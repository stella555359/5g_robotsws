*** Settings ***
Documentation
    ...  Main purpose of TC is checking consistant fallback functionality of SBTS SW triggered by RLC method
    ...  Way of fallback: from SBTS_SOAM to SBTS_SOAM

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${MODULES_RESTORE_TIMEOUT}  6m  # Timeout for waiting until moduls are online (600s, 10m)
${CELLS_RESTORE_TIMEOUT}  7m  # Timeout for waiting until cells are onAir/notOnAir in Robot Framework format (600s, 10m)
${PING_STABLE_TIMEOUT}  400  # Timeout for ping until target is stable
${SLEEP_TIMEOUT}  700  # Sleep Timeout before target is stable


*** Keywords ***
TC__SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5323
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.05.2017 - https://jira3.int.net.nokia.com/browse/TAT-5323 - initial creation
    ...  - 04.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7162 - rel4 support and ssh check added
    ...  - 13.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7933 - rework for better readability
    ...  - 07.12.2017 - https://jira3.int.net.nokia.com/browse/TAT-8553 - update for common SW release
    ...  - 13.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9311 - SBTS_SOAM creation
    ...  - 11.12.2018 - https://jira3.int.net.nokia.com/browse/TAT-13609 - additional reset check added
    ...  - 06.05.2019 - TAT-15826 Change Step 3 in SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC.robot
    ...           to use KW Software fallback from hran_compa.robot
    ...  - 03.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-16766 - timeout for Wait For Target To Be Reachable after fallback
    ...           changed from 200s to 360s
    ...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24946 - Replace hran_tools with taf.sw.ping
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 30.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27355 - Fix ping after fallback
    ...  - 23.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28637 - Reset admin connection
    ...  - 16.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29011 - Reset infomodel connection
    ...  - 01.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29962 - Fix Sbts stable and expected watchdog alarm
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-5323.png

    Set Tags  CA-COMPA  CA-SWM  OWNER-jacek.mnich@nokia.com  AUTHOR-jacek.mnich@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  PHASE-COMPA  PHASE-CRT
    ...  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP000938  FEATURE-RP001809  FEATURE-RP002035  FEATURE-RP002179_1

    Step1: Check Active And Passive Sw Version
    Step2: Software Fallback
    Step3: Wait Till BTS Is Stable
    Step4: Check Software Version
    Step5: Check Components States
    Step6: Alarm State Verification


Custom Test Setup
    Common Test Setup  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}  tc_name=SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Verify SSH Connection And Enable If Necessary
    Set Test Variables


Set Test Variables
    Set Test Variable  ${RADIO_DIST_NAME}  //EQM_L-1//RMOD_L-*/RU_L-*
    Set Test Variable  @{RADIO_EXPECTED_STATES}  administrativeState=${UNLOCKED}  operationalState=${ENABLED}  blockingState=${UNBLOCKED}
    Set Test Variable  ${SMOD_DIST_NAME}  //MCTRL-*/BBTOP_M-*/MRBTS_M-*
    Set Test Variable  @{SMOD_EXPECTED_STATES}  administrativeState=${UNLOCKED}  operationalState=${ENABLED}
    Set Test Variable  @{CELLS_EXPECTED_STATES}  administrativeState=${UNLOCKED}  operationalState=${ENABLED}  availabilityStatus=Degraded
    ...  blockingState=${UNBLOCKED}
    Set Test Variable  ${CELLS_DIST_NAME}  /MRBTS-*/RAT-*//BBTOP_M-*/MRBTS_M-*//CELL_M-*
    Set Test Variable  ${SCF_DIST_NAME}  /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*
    Set Test Variable  ${SW_PATTERN}  (?i)SBTS(?!16)


Step1: Check Active And Passive Sw Version
    Log  ${\n}======================================  console=true
    Log  Step1: Check active and passive sw version  console=true
    ${active_sw_before}  ${passive_sw_before}  Infomodel Get SW Versions
    ${passive_sw_before_list}  Get Regexp Matches  ${passive_sw_before}  SBTS([09]{0,2})(.)*
    ${passive_sw_before_pattern}  Get From List  ${passive_sw_before_list}  0
    ${active_sw_before_list}  Get Regexp Matches  ${active_sw_before}  SBTS([09]{0,2})(.)*
    ${active_sw_before_pattern}  Get From List  ${active_sw_before_list}  0
    Set Test Variable  ${ACTIVE_SW_BEFORE_SUITE_VAR}  ${active_sw_before_pattern}
    Set Test Variable  ${PASSIVE_SW_BEFORE_SUITE_VAR}  ${passive_sw_before_pattern}
    ${active_status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${active_sw_before}  ${SW_PATTERN}
    IF  ${active_status}
      Log  Active SW is checked!  console=true
    ELSE
      Fail  ${active_sw_before} doesn't match ${SW_PATTERN} pattern
    END
    ${passive_status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${passive_sw_before}  ${SW_PATTERN}
    IF  ${passive_status}
      Log  Passive SW is checked!  console=true
    ELSE
      Fail  ${passive_sw_before} doesn't match ${SW_PATTERN} pattern
    END
    Log  Sw versions checked and set as test variables  console=true


Step2: Software Fallback
    Log  ${\n}======================================  console=true
    Log  Step2: Software fallback  console=true
    ${sm_variant}  Get SM Variant
    Software Fallback  ${sm_variant[0]}


Step3: Wait Till BTS Is Stable
    Log  ${\n}======================================  console=true
    Log  Step3: Wait till BTS is stable  console=true
    Log  Wait For Target To Be Reachable  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  ${SMOD1['TRS_IP']}
    IF  ${status}
      Log  BTS is reachable!  console=true
    ELSE
      Fail  BTS not reachable after reboot.
    END
    Log  Wait For Reset  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=600
    IF  ${status}
      Log  Software reset was performed!  console=true
    ELSE
      Set Test Restriction  Software reset was not performed.
    END
    Log  Wait For Target To Be Reachable after Reset  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  ${SMOD1['TRS_IP']}  timeout=360
    IF  ${status}
      Log  BTS is reachable after reset.  console=true
    ELSE
      Fail  BTS not reachable after reset.
    END
    Log  Check If Target Is Stable  console=true
    Sleep  ${SLEEP_TIMEOUT}
    ${ping_stable_status}  Run Keyword And Return Status
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=${PING_STABLE_TIMEOUT}
    Reset Admin
    ${reset_counter}  Get Value Of Restart Counter
    Log  status:${ping_stable_status} reset_counter:${reset_counter}  console=true
    IF  ${ping_stable_status}==${FALSE}
      Fail  Ping has not been available for ${PING_STABLE_TIMEOUT} seconds
    ELSE
      Log  Ping is stable after fallback  console=true.
    END
    IF  '${reset_counter}'!='0' and '${reset_counter}'!='1'
      Set Test Restriction  Additional reset_number:${reset_counter} after fallback
    ELSE
      Log  BTS is stable after fallback.  console=true
    END
    ${admin_working_state}  sbts_admin.Reset Admin And Infomodel Connection If Broken TAF
    IF  ${admin_working_state}
      Log  Admin and infomodel are in working states after reset.  console=true
    ELSE
      Fail  Admin and/of infomodel failure after reset. Interface reset did not help.  console=true
    END


Step4: Check Software Version
    Log  ${\n}======================================  console=true
    Log  Step4: Check software version after fallback  console=true
    ${software_after}  Get Software Info
    Log  Passive SW after: ${software_after['Passive SW version']}  console=true
    Log  Active SW after: ${software_after['Active SW version']}  console=true
    ${active_status}  Run Keyword And Return Status
    ...  Should Contain  ${software_after['Active SW version']}  ${PASSIVE_SW_BEFORE_SUITE_VAR}  ignore_case=${True}
    IF  ${active_status}
      Log  ${software_after['Active SW version']} match ${PASSIVE_SW_BEFORE_SUITE_VAR}  console=true
    ELSE
      Fail  ${software_after['Active SW version']} not match ${PASSIVE_SW_BEFORE_SUITE_VAR}
    END
    ${passive_status}  Run Keyword And Return Status
    ...  Should Contain  ${software_after['Passive SW version']}  ${ACTIVE_SW_BEFORE_SUITE_VAR}  ignore_case=${True}
    IF  ${passive_status}
      Log  ${software_after['Passive SW version']} match ${ACTIVE_SW_BEFORE_SUITE_VAR}  console=true
    ELSE
      Fail  ${software_after['Passive SW version']} not match ${ACTIVE_SW_BEFORE_SUITE_VAR}
    END


Step5: Check Components States
    Log  ${\n}======================================  console=true
    Log  Step5: Check components states  console=true
    ute_admin_infomodel.Reset Infomodel  filename=${BTS_FILES}/IM/InfoModel_untilReset.ims2
    Log  Check if active sw is commisioned  console=true
    Verify Commissioned State
    Log  Check if modules states are correct  console=true
    Modules State Verification
    Log  Check cells states  console=true
    Cells State Verification


Step6: Alarm State Verification
    Log  ${\n}======================================  console=true
    Log  Step6: Alarm state verification  console=true
    ${expected_alarm1}  Create Dictionary  faultId=${FAULT_4082}[fault_id]  severity=${FAULT_4082}[severity]
    ${expected}  Create List  ${expected_alarm1}
    ${critical_alarm1}  Create Dictionary  severity=Major|Critical
    ${critical}  Create List  ${critical_alarm1}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected}  critical_patterns=${critical}
    IF  '${alarms_status}'=='FAIL'
      Fail  No Fault 4082 with Major severity found or other Major|Critical occured
    ELSE IF  ${alarms_msg}
      Set Test Restriction  Minor Faults found: ${alarms_msg}
    END


Is Ssh Enabled
    [Documentation]  If ssh is disabled test is Failed and execution is aborted

    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    ${is_ssh_enabled}  Check If Ssh Is Enabled
    IF  ${is_ssh_enabled}
      Log  Ssh is enabled!  console=true
    ELSE
      Fail  SSH not enabled
    END


Verify Commissioned State
    ${is_commissioned}  Run Keyword And Return Status
    ...  Query Infomodel  ${SCF_DIST_NAME} is [stateInfo.proceduralState=validated]
    IF  ${is_commissioned}
      Log  Active sw is commisioned  console=true
    ELSE
      Fail  Active sw is not commisioned
    END


Modules State Verification
    Log  \nChecking smod moduls states (max ${MODULES_RESTORE_TIMEOUT} for expected states)  console=true
    ${sm_status}  Infomodel Check If All Objects From Path Are Online  ${SMOD_DIST_NAME}  ${MODULES_RESTORE_TIMEOUT}  @{SMOD_EXPECTED_STATES}
    IF  ${sm_status}
      Log  All smod moduls are in expected state.  console=true
    ELSE
      Fail  At least one smod modul state is other than expected.
    END
    Log  \nChecking rf moduls states (max ${MODULES_RESTORE_TIMEOUT} for expected states)  console=true
    ${rf_status}  Infomodel Check If All Objects From Path Are Online  ${RADIO_DIST_NAME}  ${MODULES_RESTORE_TIMEOUT}  @{RADIO_EXPECTED_STATES}
    IF  ${rf_status}
      Log  All rf moduls are in expected state.  console=true
    ELSE
      Fail  At least one rf modul state is other than expected.
    END


Cells State Verification
    Log  \nChecking cells states (max ${CELLS_RESTORE_TIMEOUT} for expected states)  console=true
    ${cells_status}  Infomodel Check If All Objects From Path Are Online  ${CELLS_DIST_NAME}  ${CELLS_RESTORE_TIMEOUT}  @{CELLS_EXPECTED_STATES}
    IF  ${cells_status}
      Log  All cells are in expected state.  console=true
    ELSE
      Fail  At least one cell has state other than expected.
    END


TC Setup
    Custom Test Setup


TC Teardown
    Common Test Teardown
