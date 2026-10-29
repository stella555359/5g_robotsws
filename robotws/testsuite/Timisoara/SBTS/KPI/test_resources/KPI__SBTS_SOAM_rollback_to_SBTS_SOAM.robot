*** Settings ***
Documentation
    ...  Main purpose of TC is checking rollback functionality of SBTS SW
    ...  Way of rollback: from SBTS17 to SBTS17

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${PASSIVE_SW_STATE}  ${EMPTY}  # Expected SW state after rollback, available states: 'commissioned' 'notcommissioned'.
# Leave blank if TC shouldn't fail due BTS state.
${RESTORE_TIMEOUT}  15m  # Timeout for waiting until cells are onAir/notOnAir in Robot Framework format (600s, 10m)
${CONNECTION_RESET_ON_DEMAND}  ${TRUE}  # If ${TRUE} - connection to Admin and Infomodel will be reset on demand after rollback,
# if ${FALSE} - connection to Admin and Infomodel will be reset only if soamif version changed or
# connection broken
${PING_LOSS_TIMEOUT}  600  # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  600  # Timeout for ping regain during reset
${ROLLBACK_TIMEOUT}  30m  # Timeout for rollback retries


*** Keywords ***
TC__KPI__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5213
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24126 - Remove hran_logging library
    ...  16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24317 - Refactor KPI TCs and resources to use KWs from ca_SBTS_general
    ...  02.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23630 - Add kpi13 calculation
    ...  16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24946 - Replace hran_tools with taf.sw.ping
    ...  25.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25847 - Calculate kpi13 based on two ims files
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27599 - Check alarm GPS receiver alarm: firmware upgrade ongoing
    ...  13.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28091 - Calculate kpi13 only from Target to Base rollback
    ...  14.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28219 - Change starting time for collecting ims file after BTS reset
    ...  17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29103 - Update testcases and resourses for CB011146
    ...  22.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29763 - Call Reset Admin after ping is stable for 5 minutes
    ...  27.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29782 - Drop Check If Target Is Stable
    ...  03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29818 - Increase timeout for 5G links check
    ...  20.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30064 - Add kpi13a and kpi13c
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases
    ...  19.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30634 - Add check if 'Setup of X2 connectivity to gNB failed' appeared

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-jaroslaw.piszczala@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-RP001486_RP000938  FEATURE-RP001145_RP000938  FEATURE-RP001809  FEATURE-RP002035
    ...  FEATURE-RP001966  FEATURE-RP002179  SW-SBTS17  SW-SBTS18  SW-SBTS19  SW-SBTS22  SW-SBTS23

    TC Preconditions
    Step1: Check Active And Passive Sw Version
    Step2: Software Rollback
    Step3: Wait Till BTS Is Stable And Ensure Admin Connectivity
    Step4: Check Software Version
    Step5: Check If Active Sw Is Commisioned
    Step6: BTS State Verification


TC Preconditions
    Log  ${\n}TC Preconditions.  console=true

    Run Keyword And Ignore Error  Restore config from config.Bak On Passive Partition
    Setup Admin  bts_host=${OAM_BTS_IP}  update_interval=500  name=collect_snapshot_for_kpi13


Step1: Check Active And Passive Sw Version
    Log  Step1: Check active and passive sw version.  console=true

    ${sw_pattern}  Set Variable  SBTS(?!16)
    ${active_sw_before}  ${passive_sw_before}  Infomodel Get SW Versions
    Set Tags  SW_BEFORE_ROLLBACK_active-${active_sw_before}
    Set Tags  SW_BEFORE_ROLLBACK_passive-${passive_sw_before}
    ${active_status}  Run Keyword And Return Status  Should Match Regexp  ${active_sw_before}  (?i)${sw_pattern}
    IF  ${active_status}==${FALSE}  FAIL  ${active_sw_before} not match ${sw_pattern} pattern.
    ${passive_status}  Run Keyword And Return Status  Should Match Regexp  ${passive_sw_before}  (?i)${sw_pattern}
    IF  ${passive_status}==${FALSE}  FAIL  ${passive_sw_before} not match ${sw_pattern} pattern.
    Should Not Be Equal  ${active_sw_before}  ${passive_sw_before}  msg=${active_sw_before} match ${passive_sw_before} pattern  ignore_case=${TRUE}
    Set Test Variable  ${ACTIVE_SW_BEFORE}
    Set Test Variable  ${PASSIVE_SW_BEFORE}
    Log  Active and passive software match given patterns.  console=true


Step2: Software Rollback
    Log  Step2: Software rollback  console=true

    ${rollback_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${ROLLBACK_TIMEOUT}  1m  Rollback Software  timeout=900
    IF  ${rollback_status}==${FALSE}  FAIL  Software rollback was not performed.
    Log  Software rollback ended successfully.  console=true
    Log  Will wait for ping loss.  console=true
    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_LOSS_TIMEOUT}
    IF  ${ping_loss_status}
        Log  BTS is resetting after successful rollback.  console=true
    ELSE
        Fail  BTS RESET after successful rollback DID NOT OCCUR.
    END
    ${ping_regain_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_REGAIN_TIMEOUT}
    IF  ${ping_regain_status}
        Log  Ping regained after successful rollback.  console=true
    ELSE
        Fail  Ping has not been regained within timeout.
    END


Step3: Wait Till BTS Is Stable And Ensure Admin Connectivity
    Log  Step3: Wait till BTS is stable and ensure admin connectivity.  console=true

    Check Alarm GPS Receiver Alarm: Firmware Upgrade Ongoing
    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_from_current_session_until_reset.ims2
    ...  connection=collect_snapshot_for_kpi13
    Wait Until Keyword Succeeds  5min  30s  Reset Admin  connection=collect_snapshot_for_kpi13
    ${admin_working_state}  Run Keyword And Return Status  coam.Reset Admin
    IF  ${admin_working_state}==${FALSE}  Fail  Admin and/of infomodel failure after reset. Interface reset did not help.  console=true


Step4: Check Software Version
    Log  Step4: Check software version.  console=true

    ${active_sw_after}  ${passive_sw_after}  Infomodel Get SW Versions
    Set Tags  SW_AFTER_ROLLBACK_active-${active_sw_after}
    Set Tags  SW_AFTER_ROLLBACK_passive-${passive_sw_after}
    ${active_sw_before}  Get Regexp Matches  ${ACTIVE_SW_BEFORE}  SBTS([09]{,2})(.)*
    ${active_sw_before}  Get From List  ${active_sw_before}  0
    ${active_sw_after}  Get Regexp Matches  ${active_sw_after}  SBTS([09]{,2})(.)*
    ${active_sw_after}  Get From List  ${active_sw_after}  0
    ${active_status}  Run Keyword And Return Status  Should Match Regexp  ${active_sw_after}  (?i)${PASSIVE_SW_BEFORE}
    IF  ${active_status}==${FALSE}  FAIL  ${active_sw_after} not match ${PASSIVE_SW_BEFORE} pattern.
    ${passive_status}  Run Keyword And Return Status  Should Match Regexp  ${active_sw_before}  (?i)${passive_sw_after}
    IF  ${passive_status}==${FALSE}  FAIL  ${active_sw_before}  not match ${passive_sw_after} pattern.
    Log  Active and passive software match given patterns.  console=true


Step5: Check If Active Sw Is Commisioned
    Log  Step5: Check if active sw is commisioned.  console=true

    ${scf_objects}  coam.Get Managed Objects  SCF
    ${is_commissioned}  Set Variable  ${FALSE}
    FOR  ${scf}  IN  @{scf_objects}
        IF  '${scf}[parameters][stateInfo][proceduralState]'=='validated'
            ${is_commissioned}  Set Variable  ${TRUE}
            BREAK
        ELSE
            CONTINUE
        END
    END
    Set Test Variable  ${IS_COMMISSIONED}  ${is_commissioned}
    IF  ${IS_COMMISSIONED}
        Log  Active sw is commisioned.  console=true
    ELSE
        Log  Active sw is not commisioned.  console=true
    END


Step6: BTS State Verification
    Log  Step6: BTS state verification.  console=true

    Assert Alarm Inactive  parameters=alarmId=7107, faultId=6327, alarmName="BASE STATION CONNECTIVITY PROBLEM",
    ...  faultName="Setup of X2 connectivity to gNB failed"  timeout=300
    ${status}  Wait Until Cells And Modules States Are As Expected
    IF  ${status}
        Log  BTS is operational.  console=true
    ELSE
        Fail  Not all modules/cells are in the expected state.
    END
    ${critical_alarm}  Create Dictionary  severity=Critical|Major
    ${critical}  Create List  ${critical_alarm}
    ${status}  ${alarms_msg}  Run Keyword And Ignore Error  Admin Check Active Alarms TAF  critical_patterns=${critical}
    IF  '${status}'=='FAIL'
        Fail  Critical fail while checking alarms: ${alarms_msg}
    ELSE IF  ${alarms_msg}
        Set Test Restriction  Unexpected alarms are present: ${alarms_msg}
    END
    Check If TC Should Fail Due TC Variable
    IF  ${SCF_COUNT_NR}  Wait Until Keyword Succeeds  300  30  Check NR Status To Be Working


Restore Config From Config.Bak On Passive Partition
    Log  Restore config on passive partition.  console=true
    ${rc}  Run Keyword And Return Status  Execute Command On SM Via SSH  ${OAM_BTS_IP}  [ -d "/ffs/stb/config.bak" ]
    IF  ${rc}
        Log  Config.bak exist on passive partition, and will be restored.  console=true
        Execute Command On SM Via SSH  ${OAM_BTS_IP}  mv /ffs/stb/config.bak /ffs/stb/config
    END


Wait Until Cells And Modules States Are As Expected
    ${state}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  60s
    ...  Fail If Not All Cells Or Modules States Are As Expected

    RETURN  ${state}


Fail If Not All Cells Or Modules States Are As Expected
    IF  ${IS_COMMISSIONED}  Fail If Not All Cells Are On Air
    ${modules_status}  Verify Modules States
    IF  ${modules_status}
        Log  All modules are in expected states.  console=true
    ELSE
        Fail  Not all modules are in expected states.
    END


Fail If Not All Cells Are On Air
    ${cells_gsm_onair}  Verify GSM Cells States
    ${cells_wcdma_onair}  Verify WCDMA Cells States
    ${cells_lte_onair}  Verify LTE Cells States
    IF  ${cells_gsm_onair} and ${cells_wcdma_onair} and ${cells_lte_onair}
        Log  GSM, WCDMA and LTE cells are onAir.  console=true
    ELSE
        Fail  GSM:${cells_gsm_onair} WCDMA:${cells_wcdma_onair} LTE:${cells_lte_onair}
    END


Check If TC Should Fail Due TC Variable
    ${is_empty}  Run Keyword And Return Status  Should Be Empty  ${PASSIVE_SW_STATE}
    IF  ${is_empty}  RETURN
    IF  '${PASSIVE_SW_STATE}' == 'commissioned' and not ${IS_COMMISSIONED}  Fail  Passive SW should be commissioned.
    IF  '${PASSIVE_SW_STATE}' == 'notcommissioned' and ${IS_COMMISSIONED}  Fail  Passive SW should be notcommissioned.


Calculate Kpi13 For Target SW
    ${ims_list}  Create List  ${BTS_FILES}/IM/InfoModel_log_from_current_session_until_reset.ims2
    ...  ${BTS_FILES}/IM/InfoModel_log_from_current_session_after_reset.ims2
    ${kpis_to_be_calculated}  Create List  kpi13  kpi13a  kpi13c
    ${kpi13}  Calculate Kpis  ${kpis_to_be_calculated}  ${ims_list}
    FOR  ${kpi}  IN  @{kpis_to_be_calculated}
        Log Delta In Seconds  ${kpi13}[${kpi}][-1][delta]  ${kpi}
        Save Delta Results  ${kpi}
    END


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_from_current_session_after_reset.ims2
    ...  connection=collect_snapshot_for_kpi13
    Teardown Admin  connection=collect_snapshot_for_kpi13
    Common Test Teardown
    ${variable_exists}  Run Keyword And Return Status  Variable Should Exist  ${SBTS_DESIRED_SW_BUILD}
    IF  not ${variable_exists}  RETURN
    ${shorten_active_sw_before}  Remove String Using Regexp  ${ACTIVE_SW_BEFORE}  SBTS[0-9R]+_
    ${shorten_desired_sw_build}  Remove String Using Regexp  ${SBTS_DESIRED_SW_BUILD}  SBTS[0-9R]+_
    IF  '${shorten_active_sw_before}'=='${shorten_desired_sw_build}'  Calculate Kpi13 For Target SW
    Set Log Level  TRACE