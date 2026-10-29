*** Settings ***
Documentation
    ...  TC for LTE RAT reset from ADMIN API. At first LTE RAT reset is performed (whole operation from sending trigger
    ...  request to LTE reaching OnAir again). Then InfoModel log gathered from RAT reset is saved and then checked in order
    ...  to find all LTE DSPs and cells states changes.
    ...  | *Parameters*           | *Example*  |
    ...  | LTE_RAT_RESET_TIMEOUT  |  180       |

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${RESET_TYPE}  ${None}  # Mandatory starting from SBTS24R2. It can be Soft (kpi7a, kpi7c) or Hard (kpi7b, kpi7d).
${LTE_RAT_RESET_TIMEOUT}  180  # Timeout (in seconds) for ADMIN API LTE RAT reset. Timeout is applied for ADMIN procedure launched in step 2.
# Procedure starts with ADMIN trigger and ends when LTE RAT reset is completed
${CELLS_DISABLED_TIMEOUT}  360
${CELLS_ENABLED_TIMEOUT}  600


*** Keywords ***
TC__KPI__LTE_RAT_reset_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7655
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 30.6.2021 - https://jira3.int.net.nokia.com/browse/TAT-21478 - Test creation
    ...  - 27.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21261 - NR cells verification added
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22066 - Adapt KPI TCs for CNI-61110
    ...  - 22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  - 23.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23594 - Remove DSP check
    ...  - 10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  - 10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  - 18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  - 11.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25737 - kpi7 splitted into Soft and Hard RAT reset
    ...  - 02.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26832 - Refactor kpi calculation for branches lower than 24R2
    ...  - 14.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30066 - Add kpi7c for soft reset and kpi7d for hard reset
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7655_01.png#

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS22

    Step 0: TC Preconditions
    Step 1: Perform LTE RAT Reset
    Step 2: Check If LTE Cells Were Disabled
    Step 3: Check If Cells On Other RATs Are OnAir
    Step 4: Check If LTE Cells Are OnAir


Step 0: TC Preconditions
    IF  ${SCF_COUNT_LTE}
        Log  LTE cell exist!  console=true
    ELSE
        Fail  LTE cell does not exist!
    END
    IF  '${ENB_BRANCH}'>='SBTS24R2' and '${RESET_TYPE}'=='${None}'  Fail  Please provide RESET_TYPE (Soft/Hard).
    IF  '${ENB_BRANCH}'>='SBTS24R2'  Set ActRatResetEnhancement Parameter To True


Step 1: Perform LTE RAT Reset
    Log  Step 1: Perform LTE RAT reset  console=True
    ${result}  coam.Rat Reset  rat_type=LTE  reset_type=${RESET_TYPE}  timeout=${LTE_RAT_RESET_TIMEOUT}
    Log  Reset LTE RAT was performed  console=true


Step 2: Check If LTE Cells Were Disabled
    Log  Step 2: Check if LTE cells were disabled  console=true
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${CELLS_DISABLED_TIMEOUT}  30  Check LTE Cells  ${DISABLED}
    IF  ${status}
        Log  LTE cells are disabled  console=true
    ELSE
        Set Test Failed  LTE cells are not disabled!
    END


Step 3: Check If Cells On Other RATs Are OnAir
    Log  Step 3: Check if cells on other RATs are online  console=True
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  360  30  Check Other RATs  ${ENABLED}  ${ACTIVE}
    IF  ${status}
        Log  Cells on other RATs are Online  console=true
    ELSE
        Set Test Failed  Cells on other RATs are not Online!
    END


Step 4: Check If LTE Cells Are OnAir
    Log  Step 4: Check if LTE cells are operational  console=True
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${CELLS_ENABLED_TIMEOUT}  30  Check LTE Cells  ${ENABLED}
    IF  ${status}
        Log  LTE cells are Online  console=true
    ELSE
        Set Test Failed  LTE cells are not Online!
    END


Check LTE Cells
    [Arguments]  ${operational_state}

    IF  ${SCF_COUNT_LTE}  Assert Every  LNCEL  operationalState=${operational_state}  timeout=60
    Check If Cells Are Not Degraded  LNCEL


Check Other RATs
    [Arguments]  ${operational_state}  ${usage_state}

    IF  ${SCF_COUNT_GSM}
        Assert Every  GNCEL  usageState=${usage_state}, operationalState=${operational_state}  timeout=60
        Check If Cells Are Not Degraded  GNCEL
    END
    IF  ${SCF_COUNT_WCDMA}
        Assert Every  WNCEL  usageState=${usage_state}, operationalState=${operational_state}  timeout=60
        Check If Cells Are Not Degraded  WNCEL
    END
    IF  ${SCF_COUNT_NR}
        Assert Every  NRCEL  operationalState=${operational_state}  timeout=60
        Check If Cells Are Not Degraded  NRCEL
    END


Calculate Kpi7 Duration
    IF  '${ENB_BRANCH}'<'SBTS24R2'
        ${kpi7}  Calculate Kpi7  ${BTS_FILES}/IM/InfoModel_log.ims2
        Log Delta In Seconds  ${kpi7}[kpi7][-1][delta]  kpi7
        Save Delta Results  kpi7
    END
    IF  '${RESET_TYPE}'=='Soft'
        ${soft_kpi_ids}  Create List  kpi7a  kpi7c
        ${kpi7_soft}  Calculate Kpis  ${soft_kpi_ids}  ${BTS_FILES}/IM/InfoModel_log.ims2
        FOR  ${kpi}  IN  @{soft_kpi_ids}
            Log Delta In Seconds  ${kpi7_soft}[${kpi}][-1][delta]  ${kpi}
            Save Delta Results  ${kpi}
        END
    ELSE IF  '${RESET_TYPE}'=='Hard'
        ${hard_kpi_ids}  Create List  kpi7b  kpi7d
        ${kpi7_hard}  Calculate Kpis  ${hard_kpi_ids}  ${BTS_FILES}/IM/InfoModel_log.ims2
        FOR  ${kpi}  IN  @{hard_kpi_ids}
            Log Delta In Seconds  ${kpi7_hard}[${kpi}][-1][delta]  ${kpi}
            Save Delta Results  ${kpi}
        END
    END


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    Common Test Teardown
    Calculate Kpi7 Duration
    Set Log Level  TRACE
