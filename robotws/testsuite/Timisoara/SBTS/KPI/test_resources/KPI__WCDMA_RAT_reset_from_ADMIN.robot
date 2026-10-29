*** Settings ***
Documentation
    ...  TC for SW download and activation. There are optional parameters:
    ...  1. Target SW name - SW package name. If not given, TC will choose newest package in a directory
    ...  2. Target SW dir - Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
    ...  3. SW Update Timeout - Given in seconds; That is a timeout for SW download and Activation (probably without reset - will be clarified)
    ...  4. onAir Check Number - Number of checks for proceduralStatus: onAir (probably since the reset beginning); check interval = 10s

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${WCDMA_RAT_RESET_TIMEOUT}  180  # Timeout (in seconds) for ADMIN API WCDMA RAT reset. Timeout is applied for ADMIN procedure launched in step 2.
# Procedure starts with ADMIN trigger and ends when WCDMA RAT reset is completed


*** Keywords ***
TC__KPI__WCDMA_RAT_reset_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7656
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC for WCDMA RAT reset from ADMIN API. At first WCDMA RAT reset is performed (whole operation from sending trigger
    ...  request to WCDMA reaching OnAir again). Then InfoModel log gathered from RAT reset is saved and then checked in order
    ...  to find all DSPs and cells states changes.
    ...
    ...  | *Parameters*             | *Example*  |
    ...  | WCDMA_RAT_RESET_TIMEOUT  |  180       |
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  10.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7656 - Test creation
    ...  09.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-10029 - KPI - first WCDMA cell up after WCDMA reset request
    ...  03.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18397 - Adding new keyword to TC
    ...  09.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19860 - Adding TL recovery action
    ...  03.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-20007 - Deleted KPI reporting to WCTO database
    ...  07.12.2020 - https://jira3.int.net.nokia.com/browse/TAT-20628 - All steps timeouts increased to 30 min
    ...  30.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21764 - [CNI-61110] STATE TCs alignment
    ...  24.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22858 - TC moved from STATE folder
    ...  10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7656_01.png#

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-patryk.furman@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS22

    Step 1: Get All WCDMA DSPs Dist Names
    Step 2: Perform WCDMA RAT Reset
    Step 3: Save Infomodel Log For TC Checks
    Step 4: Check If WCDMA DSPs Were Restarted
    Step 5: Check If WCDMA Cells Were Degraded
    Step 6: Check If Cells On Other RATs Were Operational
    Step 7: Check If WCDMA Cells Are Operational


Step 1: Get All WCDMA DSPs Dist Names
    [Timeout]  30 min

    Log  Step 1: Get all WCDMA DSPs dist names  console=True
    ${dsps_dist_names}  Infomodel Get All DSPs Dist Names For Given RAT  WCDMA
    Log  WCDMA DSPs list: ${dsps_dist_names}  console=True
    Set Test Variable  ${DSPS_DIST_NAMES}  ${dsps_dist_names}


Step 2: Perform WCDMA RAT Reset
    [Timeout]  30 min

    Log  Step 2: Perform WCDMA RAT reset  console=True
    Reset Rat  WCDMA  timeout=${WCDMA_RAT_RESET_TIMEOUT}
    Log  WCDMA RAT reset has been performed via ADMIN API  console=True


Step 3: Save Infomodel Log For TC Checks
    [Timeout]  30 min

    Log  Step 3: Save Infomodel log for TC checks  console=True
    Sleep  120s  Wait for DSPs states save inside IM
    Save Infomodel Log  ${BTS_FILES}/IM/InfoModel_log_after_WCDMA_RAT_reset.ims2
    Set Test Variable  ${IM_LOG_PATH}  ${BTS_FILES}/IM/InfoModel_log_after_WCDMA_RAT_reset.ims2
    Log  Infomodel log saved under ${IM_LOG_PATH}  console=True


Step 4: Check If WCDMA DSPs Were Restarted
    [Timeout]  30 min

    Log  Step 4: Check if WCDMA DSPs were restarted  console=True
    Infomodel Check If DSPs Were Restarted According To Ims File  ${IM_LOG_PATH}  ${DSPS_DIST_NAMES}
    Log  All DSPs were restarted during WCDMA RAT reset  console=True


Step 5: Check If WCDMA Cells Were Degraded
    [Timeout]  30 min

    Log  Step 5: Check if WCDMA cells were degraded  console=True
    ${cells_m_objects}  coam.Get Managed Objects  CELL_M
    ${wcdma_cells_objects}  Create List
    FOR  ${cell_m}  IN  @{cells_m_objects}
        ${check_cell_id}  Run Keyword And Return Status  Should Contain  ${cell_m}[distName]  WNBTS_M
        IF  ${check_cell_id}  Append To List  ${wcdma_cells_objects}  ${cell_m}
    END
    ${wcdma_cells_runtime_objects}  coam.Get Managed Objects  WNCEL_R

    FOR  ${cell_object}  ${runtime_object}  IN ZIP  ${wcdma_cells_objects}  ${wcdma_cells_runtime_objects}
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event
        ...  change ${cell_object}[distName] [parameters.stateInfo.availabilityStatus: regex"(?i)Online" -> regex"(?i)Off\\s?line"]
        Add Expected Ims2 Event  change ${cell_object}[distName] [parameters.stateInfo.operationalState: regex"(?i)Enabled" -> regex"(?i)Disabled"]
        Validate Ims2
        Log  ${cell_object}[distName] states changed: availabilityStatus: Online -> Offline, operationalState: Enabled -> Disabled  console=True
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event  change ${cell_object}[distName] [parameters.stateInfo.blockingState]
        Run Keyword And Expect Error  InfoModelIms2ValidationException:*
        ...  Validate Ims2
        Log  ${cell_object}[distName] administrativeState and blockingState remained unchanged  console=True
    END
    Log  All WCDMA cells were degraded during WCDMA RAT reset  console=True


Step 6: Check If Cells On Other RATs Were Operational
    [Timeout]  30 min

    Log  Step 6: Check if cells on other RATs were operational  console=True
    Infomodel Check If Cells In RAT Were Operational According To IM Log  LTE  ${IM_LOG_PATH}
    Infomodel Check If Cells In RAT Were Operational According To IM Log  GSM  ${IM_LOG_PATH}


Step 7: Check If WCDMA Cells Are Operational
    [Timeout]  30 min

    Log  Step 7: Check if WCDMA cells are operational  console=True
    ${are_wncels_online}  Run Keyword And Return Status
    ...  Run Keywords
    ...  Assert Every  WNCEL  blockingState=${UNBLOCKED}, operationalState=${ENABLED}
    ...  AND
    ...  Assert No  WNCEL  availabilityStatus=${DEGRADED}
    Should Be True  ${are_wncels_online}  Not all WCDMA cells are online after WCDMA RAT reset


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    Common Test Teardown
    ${kpi8}  Calculate Kpi8  ${BTS_FILES}/IM/InfoModel_log.ims2
    Log Delta In Seconds  ${kpi8}[kpi8][-1][delta]  kpi8
    Save Delta Results  kpi8
    Set Log Level  TRACE
