*** Settings ***
Documentation
    ...  TC for BBMOD reset from Web EM. BBMOD reset is performed. Cells on BBMOD must be failed and
    ...  the others should not have to be disabled. All of them are verified and must be as expected.
    ...  After BBMOD reset disabled cells must be onAir.

Resource  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/common_resources/ca_KPI_general.robot


*** Variables ***
${BBMOD_SERIAL_NUMBER}  ${EMPTY}  # Mandatory, serial number for BBMOD must be given
${RESET_TIMEOUT}  180  # Timeout in seconds for waitting for positive procedure (reset unit) result.
${RESET_TYPE}  Warm  # reset_type (string) for KW Unit Reset Cp ? Soft|Hard|Warm, if SW is SBTS17 please use Hard
${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  ${False}
${CALCULATE_RESET_DURATION}  ${False}


*** Keywords ***
TC__KPI__BBMOD_Reset_From_WebEM
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21232
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21232 - Test creation
    ...  - 22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  - 10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  - 10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  - 18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  - 12.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24213 - KPI__BBMOD_Reset_From_WebEM failed
    ...  - 13.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25540 - Add option for activating graceful cell shutdown before reset
    ...  - 27.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26323 - Change Get ids for all usage
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26611 - Add calculation for reset duration
    ...  - 26.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28008 - Decrease update interval for setup admin
    ...  - 30.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28308 - Try to calculate reset duration from both ims colected
    ...  - 20.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28430 - Use ims from common test teardown to calculate kpis

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS22

    Step 0: Set BBMOD Object
    Step 1: Perform BBMOD Reset
    Step 2: Check If Cells On BBMOD Are Failed
    Step 4: Check If Cells On BBMOD Are OnAir After BBMOD Reset


Step 0: Set BBMOD Object
    Log  Step 0: Set BBMOD object  console=true
    ${status}  Query Infomodel  check //BBMOD_R-* is [serialNumber=${BBMOD_SERIAL_NUMBER}]  allow_negative_result=True
    Run Keyword If  ${status}
    ...  Log  Serial number for BBMOD is correct!  console=true
    ...  ELSE
    ...  Fail  Serial number for BBMOD is wrong! Please provide another one!
    ${bbmod_obj}  Get Infomodel Object  //BBMOD_R-* is [serialNumber=${BBMOD_SERIAL_NUMBER}]
    Set Test Variable  ${BBMOD_OBJ}
    Set Distnames For Cells


Step 1: Perform BBMOD Reset
    Log  Step 1: Perform BBMOD reset  console=True
    coam.Reset_unit  dist_name=${BBMOD_OBJ.dist_name}  reset_type=${RESET_TYPE}  timeout=${RESET_TIMEOUT}
    ...  graceful_cell_shutdown=${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}


Step 2: Check If Cells On BBMOD Are Failed
    Log  Step 2: Check if cells on BBMOD are failed  console=True
    Wait Until Keyword Succeeds  180  10
    ...  Check Parameters Status For Cells  ${CELLS_DISTNAMES}  availabilityStatus=${FAILED}, operationalState=${DISABLED}


Step 4: Check If Cells On BBMOD Are OnAir After BBMOD Reset
    Log  Step 4: Check if cells on BBMOD are onAir after BBMOD reset  console=True
    Wait Until Keyword Succeeds  1200  10
    ...  Check Parameters Status For Cells  ${CELLS_DISTNAMES}  operationalState=${ENABLED}


Set Distnames For Cells
    #cells on bbmod which are reaching on air state
    ${CELLS_DISTNAMES}  Create List  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-22363/LNCEL_R-47477
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-22363/LNCEL_R-47478
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-22363/LNCEL_R-47479
    Set Test Variable  ${CELLS_DISTNAMES}


Calculate BBMOD Reset Duration
    ${kpibbmodreset}  Calculate Kpibbmodreset  ${BTS_FILES}/IM/InfoModel_log.ims2
    Log Delta In Seconds  ${kpibbmodreset}[kpibbmodreset][-1][delta]  kpibbmodreset
    Save Delta Results  kpibbmodreset


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  cells_check=${FALSE}  modules_check=${FALSE}  alarms_check=${FALSE}


TC Teardown
    Common Test Teardown
    ${kpi5}  Calculate Kpi5  ${BTS_FILES}/IM/InfoModel_log.ims2  cell_dist_names=${CELLS_DISTNAMES}
    Log Delta In Seconds  ${kpi5}[kpi5][-1][delta]  kpi5
    Save Delta Results  kpi5
    Run Keyword If  ${CALCULATE_RESET_DURATION}
    ...  Calculate BBMOD Reset Duration
