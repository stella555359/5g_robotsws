*** Settings ***
Documentation
    ...  TC for NR RAT reset from Web EM. At first NR RAT reset is performed (whole operation from sending trigger
    ...  request to NR reaching On Air again). After NR RAT reset, all cells from other technologies are checked
    ...  and they must be on Air.
    ...  | *Parameters*           | *Example*  |
    ...  | NR_RAT_RESET_TIMEOUT   |  300       |

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${RESET_TYPE}  ${None}  # Mandatory starting from SBTS24R2. It can be Soft (kpi10a, kpi10c) or Hard (kpi10b, kpi10d).
${NR_RAT_RESET_TIMEOUT}  600
${CELLS_ENABLED_TIMEOUT}  600
${CALCULATE_RESET_DURATION}  ${False}


*** Keywords ***
TC__KPI__5G_RAT_Reset_From_WebEM
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21233
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21233 - Test creation
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22066 - Adapt KPI TCs for CNI-61110
    ...  - 11.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22468 - Add variables for timeout
    ...  - 22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  - 17.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23297 - Remove usageState check for 5G cells
    ...  - 10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  - 10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  - 18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  - 20.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24217 - 5G RAT Reset From WebEM failed
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26611 - Add calculation for reset duration
    ...  - 11.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25737 - kpi10 splitted into Soft and Hard RAT reset
    ...  - 02.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26832 - Refactor kpi calculation for branches lower than 24R2
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 26.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28008 - Decrease update interval for setup admin
    ...  - 25.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28137 - Remove verification of cells to be disabled
    ...  - 30.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28308 - Try to calculate reset duration from both ims colected
    ...  - 20.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28430 - Use ims from common test teardown to calculate kpis
    ...  - 13.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30069 - Add kpi10c for soft reset and kpi10d for hard reset

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS22

    Step 0: TC Preconditions
    Step 1: Perform NR RAT Reset
    Step 2: Check If Cells On Other RATs Are OnAir
    Step 3: Check If NR Cells Are OnAir


Step 0: TC Preconditions
    IF  ${SCF_COUNT_NR}
        Log  NR cell exist!  console=true
    ELSE
        Fail  NR cell does not exist!
    END
    IF  '${ENB_BRANCH}'>='SBTS24R2' and '${RESET_TYPE}'=='${None}'  Fail  Please provide RESET_TYPE (Soft/Hard).
    IF  '${ENB_BRANCH}'>='SBTS24R2'  Set ActRatResetEnhancement Parameter To True


Step 1: Perform NR RAT Reset
    [Timeout]  15 min

    Log  \nStep 1: Perform NR RAT reset  console=True
    ${result}  coam.Rat Reset  rat_type=NR  reset_type=${RESET_TYPE}  timeout=${NR_RAT_RESET_TIMEOUT}
    Log  Reset NR RAT was performed  console=true


Step 2: Check If Cells On Other RATs Are OnAir
    [Timeout]  15 min

    Log  \nStep 2: Check If Cells On Other RATs Are OnAir  console=True
    Wait Until Keyword Succeeds  360  30  Check Other RATs  OnAirDone  ${ENABLED}  ${ACTIVE}
    Admin Check Active Alarms TAF


Step 3: Check If NR Cells Are OnAir
    [Timeout]  15 min

    Log  \nStep 3: Check If NR Cells Are OnAir  console=True
    Wait Until Keyword Succeeds  ${CELLS_ENABLED_TIMEOUT}  30  Check NR Cells  ${ENABLED}
    Admin Check Active Alarms TAF


Check NR Cells
    [Arguments]  ${operational_state}

    IF  ${SCF_COUNT_NR}  Assert Every  NRCEL  operationalState=${operational_state}  timeout=60


Check Other RATs
    [Arguments]  ${procedural_state}  ${operational_state}  ${usage_state}

    IF  ${SCF_COUNT_WCDMA}  Assert Every  WNCEL  usageState=${usage_state}, operationalState=${operational_state}  timeout=60
    IF  ${SCF_COUNT_LTE}  Assert Every  LNCEL  proceduralState=${procedural_state}, operationalState=${operational_state}  timeout=60
    IF  ${SCF_COUNT_GSM}  Assert Every  GNCEL  usageState=${usage_state}, operationalState=${operational_state}  timeout=60


Calculate Kpi10 Duration
    IF  '${ENB_BRANCH}'<'SBTS24R2'
        ${kpi10}  Calculate Kpi10  ${BTS_FILES}/IM/InfoModel_log.ims2
        Log Delta In Seconds  ${kpi10}[kpi10][-1][delta]  kpi10
        Save Delta Results  kpi10
    END
    IF  '${RESET_TYPE}'=='Soft'
        ${soft_kpi_ids}  Create List  kpi10a  kpi10c
        ${kpi10_soft}  Calculate Kpis  ${soft_kpi_ids}  ${BTS_FILES}/IM/InfoModel_log.ims2
        FOR  ${kpi}  IN  @{soft_kpi_ids}
            Log Delta In Seconds  ${kpi10_soft}[${kpi}][-1][delta]  ${kpi}
            Save Delta Results  ${kpi}
        END
    ELSE IF  '${RESET_TYPE}'=='Hard'
        ${hard_kpi_ids}  Create List  kpi10b  kpi10d
        ${kpi10_hard}  Calculate Kpis  ${hard_kpi_ids}  ${BTS_FILES}/IM/InfoModel_log.ims2
        FOR  ${kpi}  IN  @{hard_kpi_ids}
            Log Delta In Seconds  ${kpi10_hard}[${kpi}][-1][delta]  ${kpi}
            Save Delta Results  ${kpi}
        END
    END


Calculate NR Reset Duration
    ${kpinrratreset}  Calculate Kpinrratreset  ${BTS_FILES}/IM/InfoModel_log.ims2
    Log Delta In Seconds  ${kpinrratreset}[kpinrratreset][-1][delta]  kpinrratreset
    Save Delta Results  kpinrratreset


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=KPI__5G_RAT_Reset_From_WebEM


TC Teardown
    Common Test Teardown
    Calculate Kpi10 Duration
    IF  ${CALCULATE_RESET_DURATION}  Calculate NR Reset Duration
    Set Log Level  TRACE
