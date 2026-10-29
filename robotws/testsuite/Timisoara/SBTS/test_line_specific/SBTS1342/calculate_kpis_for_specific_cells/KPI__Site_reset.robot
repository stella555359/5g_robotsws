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

Resource  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/common_resources/ca_KPI_general.robot


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
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4062.png#

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-valentin.suru@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS22

    Step0: TC Variables
    Step 1: SBTS Site Reset
    Step 2: SBTS Is Restored


Step0: TC Variables
    Log  \nStep0: TC Variables  console=true
    ${left_over_cells}  Get All Cells On Bts
    #cells failed on bbmod during entire TC
    ${cells_on_bbmod}  Create List  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-5
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-6
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-7
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-2
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-3
    Remove Values From List  ${left_over_cells}  @{cells_on_bbmod}
    Set test variable  ${CELLS_DISTNAMES}  ${left_over_cells}


Step 1: SBTS Site Reset
    Log  \nStep 1: SBTS Site reset  console=true
    coam.Reset Site  timeout=600


Step 2: SBTS Is Restored
    Log  \nStep 2: SBTS Is Restored  console=true
    Wait Until Keyword Succeeds  1200  10
    ...  Check Parameters Status For Cells  ${CELL_DISTNAMES}  operationalState=${ENABLED}


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  tc_name=KPI__Site_reset  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}


TC Teardown
    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    Common Test Teardown
    ${kpi1a}  Calculate Kpi1a  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    ...  cell_dist_names=${CELLS_DISTNAMES}
    Log Delta In Seconds  ${kpi1a}[kpi1a][-1][delta]  kpi1a
    Save Delta Results  kpi1a
    ${kpi1b}  Calculate Kpi1b  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    ...  cell_dist_names=${CELLS_DISTNAMES}
    Log Delta In Seconds  ${kpi1b}[kpi1b][-1][delta]  kpi1b
    Save Delta Results  kpi1b
