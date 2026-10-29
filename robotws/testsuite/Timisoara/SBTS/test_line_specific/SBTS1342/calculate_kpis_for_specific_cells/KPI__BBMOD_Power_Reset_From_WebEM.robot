*** Settings ***
Documentation
    ...  TC is performing BBMOD power reset from WebEM. Cells on BBMOD must be failed and
    ...  the others should be unaffected.
    ...  After BBMOD reset affected cells must be onAir.
    ...  Kpi14 is calculated in TC teardown.

Resource  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/common_resources/ca_KPI_general.robot


*** Variables ***
${BBMOD_SERIAL_NUMBER}  ${EMPTY}  # Mandatory, serial number for BBMOD must be given
${RESET_TIMEOUT}  180  # Timeout in seconds for waitting for positive procedure (reset unit) result
${RECOVERY_TIMEOUT}  1200  # Timeout for BBMOD cells to reach onAir state after BBMOD reset
${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  ${False}


*** Keywords ***
TC__KPI__BBMOD_Power_Reset_From_WebEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26207
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26207 - TAT creation
    ...  - 19.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26290 - Change steps names

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS24

    Step0: Set BBMOD Parameters
    Step1: Perform BBMOD Power Reset
    Step2: Check Cells On BBMOD To Be Failed
    Step4: Check Cells On BBMOD To Be OnAir After BBMOD Reset


Step0: Set BBMOD Parameters
    Log  Step0: Set BBMOD parameters  console=true
    ${bbmods}  coam.Get Parameters For All  BBMOD
    FOR  ${bbmod}  IN  @{bbmods}
        Run Keyword If  '${bbmod}[serialNumber]'=='${BBMOD_SERIAL_NUMBER}'
        ...  Run Keywords
        ...  Set Test Variable  ${BBMOD_PARAMETERS}  ${bbmod}
        ...  AND
        ...  Set Variables For Cells
        ...  AND
        ...  Return From Keyword
    END
    Fail  Serial number for BBMOD is wrong! Please provide another one!


Step1: Perform BBMOD Power Reset
    Log  \nStep1: Perform BBMOD power reset  console=True
    coam.Reset Unit  dist_name=${BBMOD_PARAMETERS}[id]  reset_type=PowerReset  timeout=${RESET_TIMEOUT}
    ...  graceful_cell_shutdown=${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}


Step2: Check Cells On BBMOD To Be Failed
    Log  \nStep2: Check cells on BBMOD to be failed  console=True
    Wait Until Keyword Succeeds  180  10
    ...  Check Parameters Status For Cells  ${CELLS_DISTNAMES}  availabilityStatus=${FAILED}, operationalState=${DISABLED}


Step4: Check Cells On BBMOD To Be OnAir After BBMOD Reset
    Log  \nStep4: Check cells on BBMOD to be onAir after BBMOD reset  console=True
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check Parameters Status For Cells  ${CELLS_DISTNAMES}  operationalState=${ENABLED}


Set Variables For Cells
    #cells on bbmod which are reaching on air state
    ${CELLS_DISTNAMES}  Create List  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-22363/LNCEL_R-47477
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-22363/LNCEL_R-47478
    ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-22363/LNCEL_R-47479
    Set Test Variable  ${CELLS_DISTNAMES}


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  cells_check=${FALSE}  modules_check=${FALSE}  alarms_check=${FALSE}


TC Teardown
    Common Test Teardown
    ${kpi14}  Calculate Kpi14  ${BTS_FILES}/IM/InfoModel_log.ims2  cell_dist_names=${CELLS_DISTNAMES}
    Log Delta In Seconds  ${kpi14}[kpi14][-1][delta]  kpi14
    Save Delta Results  kpi14
