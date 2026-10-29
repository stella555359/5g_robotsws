*** Settings ***
Documentation
    ...  Step 1: SBTS Site reset
    ...  Site reset can be performed in 4 ways:
    ...    - classic reset when graceful_cell_shutdown, reset_without_ru and actDualCoreParallelReset are set to false
    ...    - reset with graceful_cell_shutdown set to true
    ...    - site reset without radio reset, only CPRI RFs will not be resetting
    ...    - reset with no dependencies between primary and secondary core when actDualCoreParallelReset parameter is set to true.
    ...  Step 2: SBTS is restored
    ...  TC is waiting for SBTS to reach on air state after site reset.
    ...  In case of site reset without radio reset, uptimes for radio modules are verified and kpi1f is calculated.
    ...  For the other cases, kpi1a and kpi1b are calculated.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  10  # Time in minutes for SBTS to reach on air state
${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  ${False}
${RESET_WITHOUT_RU}  ${False}
${DUAL_CORE_PARALLEL_RESET}  ${False}
${ACTIVATE_FEATURE_CB009301}  ${False}


*** Keywords ***
TC__KPI__Site_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21226
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 30.06.2021 - https://jira3.int.net.nokia.com/browse/TAT-21226 - Initial creation
    ...  - 27.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21261 - NR cells verification added
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22066 - Adapt KPI TCs for CNI-61110
    ...  - 07.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22452 - Remove variables for register kpi to database
    ...  - 22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  - 10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  - 10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  - 18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  - 16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24317 - Refactor KPI TCs and resources to use KWs from ca_SBTS_general
    ...  - 13.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25540 - Add option for activating graceful cell shutdown before reset
    ...  - 14.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25540 - Change reset site request for branch 23R3
    ...  - 27.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25851 - Send graceful cell shutdown parameter only if it is True
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 11.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27097 - Add kpi1b calculation
    ...  - 27.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28145 - Check if C-Plane checkpoints are visible in snapshot
    ...  - 24.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28291 - Check CP checkpoints starting from 25R1
    ...  - 28.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28302 - Add kpi1f and dual core parallel reset
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28313 - Refactor RF uptime comparison
    ...  - 05.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28356 - Ignore parallel reset for classic site reset
    ...  - 12.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28375 - Add gNb type verification for checkpoints
    ...  - 20.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28426 - Include eCPRI RUs in not resetting list
    ...  - 20.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28426 - Add Site reset with CB009301
    ...  - 23.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29133 - Update parameters only if variables are set to True
    ...  - 09.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30623 - Add max duration calculation alongside kpi1a/b

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-valentin.suru@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS22

    Step 0: TC Prerequisites
    Step 1: SBTS Site Reset
    Step 2: SBTS Is Restored


Step 0: TC Prerequisites
    IF  ${RESET_WITHOUT_RU}  Set Uptime For RFs
    IF  ${DUAL_CORE_PARALLEL_RESET}  Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  actDualCoreParallelReset  true
    IF  ${ACTIVATE_FEATURE_CB009301}  Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  actEcpriDelayMeasurement  true


Step 1: SBTS Site Reset
    Log  \nStep 1: SBTS Site reset  console=true
    Setup Admin  bts_host=${OAM_BTS_IP}  update_interval=500  name=collect_infomodel_log
    coam.Reset Site  timeout=600  graceful_cell_shutdown=${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  reset_without_ru=${RESET_WITHOUT_RU}
    ...  connection=collect_infomodel_log


Step 2: SBTS Is Restored
    Log  \nStep 2: SBTS is restored\nCheck BTS and Cells states after reset\nWait ${RESTORE_TIMEOUT} mins for the states to be as expected
    ...  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT} min  30 s  Admin Check All Required State
    IF  ${SCF_COUNT_NR}  Wait Until Keyword Succeeds  300  30  Check X2 And NG Links To Be Working

    Sleep  60s  Time for all parameters to be loaded in Infomodel.
    IF  ${RESET_WITHOUT_RU}  Check Uptime For RFs After Site Reset Without RU

    ${list_of_active_alarms}  Admin Check Active Alarms TAF  collect_snapshot=${True}
    ${length}  Get Length  ${list_of_active_alarms}
    IF  ${length}>0  Set Test Restriction  Active alarms exist: ${list_of_active_alarms}


Set Uptime For RFs
    ${rmods_params}  Get Parameters For All  RMOD
    ${rmods_not_resetting_uptime}  Create Dictionary
    ${rmods_resetting_uptime}  Create Dictionary
    FOR  ${rmod}  IN  @{rmods_params}
        ${rmod_measurements}  Get Rmod Measurements By Id  ${rmod}[id]
        ${uptime}  Convert To Integer  ${rmod_measurements}[uptime][seconds]
        IF  'CPRI' in '${rmod}[l3Protocol]'
            Set To Dictionary  ${rmods_not_resetting_uptime}  ${rmod}[id]=${uptime}
        ELSE
            Set To Dictionary  ${rmods_resetting_uptime}  ${rmod}[id]=${uptime}
        END
    END
    Set Test Variable  ${RMODS_NOT_RESETTING_UPTIME}
    Set Test Variable  ${RMODS_RESETTING_UPTIME}
    ${rmods_will_reset}  Get Dictionary Keys  ${RMODS_RESETTING_UPTIME}
    ${rmods_will_not_reset}  Get Dictionary Keys  ${RMODS_NOT_RESETTING_UPTIME}
    Log  Following RMODs will reset: ${rmods_will_reset}.  console=true
    Log  Following RMODs will NOT reset: ${rmods_will_not_reset}.  console=true


Check Uptime For RFs After Site Reset Without RU
    ${rmods_params}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods_params}
        ${rmod_id}  Set Variable  ${rmod}[id]
        ${rmod_measurements}  Get Rmod Measurements By Id  ${rmod_id}
        ${rmods_not_in_reset}  Get Dictionary Keys  ${RMODS_NOT_RESETTING_UPTIME}
        ${rmod_uptime_after_reset}  Convert To Integer  ${rmod_measurements}[uptime][seconds]
        IF  '${rmod_id}' in ${rmods_not_in_reset}
            ${uptime_as_expected}  Run Keyword And Return Status  Should Be True
            ...  ${rmod_uptime_after_reset}>${RMODS_NOT_RESETTING_UPTIME}[${rmod_id}]
        ELSE
            ${uptime_as_expected}  Run Keyword And Return Status  Should Be True
            ...  ${rmod_uptime_after_reset}<${RMODS_RESETTING_UPTIME}[${rmod_id}]
        END
        ${rmod_id}  Fetch From Right  ${rmod_id}  /
        IF  not ${uptime_as_expected}  Set Test Failed  ${rmod}[productName] - ${rmod_id} has unexpected uptime.
    END


Calculate KPI 1a and 1b For Site Reset
    ${kpi1a_name}  Set Variable If  ${ACTIVATE_FEATURE_CB009301}  kpi1a_CB009301  kpi1a
    ${kpi1b_name}  Set Variable If  ${ACTIVATE_FEATURE_CB009301}  kpi1b_CB009301  kpi1b
    ${kpi1_max_duration_name}  Set Variable If  ${ACTIVATE_FEATURE_CB009301}  kpisiteresettobtsresponding_CB009301  kpisiteresettobtsresponding
    ${kpis_correspondence}  Create Dictionary  kpi1a=${kpi1a_name}  kpi1b=${kpi1b_name}  kpisiteresettobtsresponding=${kpi1_max_duration_name}

    ${kpis_to_be_calculated}  Get Dictionary Keys  ${kpis_correspondence}
    ${kpi1}  Calculate Kpis  ${kpis_to_be_calculated}  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    FOR  ${kpi}  IN  @{kpis_to_be_calculated}
        Log Delta In Seconds  ${kpi1}[${kpi}][-1][delta]  ${kpis_correspondence}[${kpi}]
        Save Delta Results  ${kpis_correspondence}[${kpi}]
    END


Calculate KPI 1f For Site Reset
    ${kpi1f}  Calculate Kpi1f  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    Log Delta In Seconds  ${kpi1f}[kpi1f][-1][delta]  kpi1f
    Save Delta Results  kpi1f


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=KPI__Site_reset


TC Teardown
    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2  connection=collect_infomodel_log
    ${active_release}  Get Sw Release Name
    IF  ${SCF_COUNT_NR}
        ${nrbts_type}  _Get NR Type
    END
    IF  ${DUAL_CORE_PARALLEL_RESET}  Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  actDualCoreParallelReset  false
    IF  ${ACTIVATE_FEATURE_CB009301}  Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  actEcpriDelayMeasurement  false
    Common Test Teardown

    IF  ${DUAL_CORE_PARALLEL_RESET}  Log
    ...  \nSite reset was performed with no dependency between primary and secondary core (actDualCoreParallelReset=true).\n  console=true

    IF  ${RESET_WITHOUT_RU}
        Calculate KPI 1f For Site Reset
    ELSE
        Calculate KPI 1a and 1b For Site Reset
    END

    IF  '${active_release}'>='SBTS25R1' and ${SCF_COUNT_NR}  Check Snapshot To Contain Checkpoints For CP Components  ${nrbts_type}
    Set Log Level  TRACE
