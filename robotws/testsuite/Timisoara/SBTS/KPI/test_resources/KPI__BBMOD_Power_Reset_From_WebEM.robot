*** Settings ***
Documentation
    ...  TC is performing BBMOD power reset from WebEM. Cells on BBMOD must be failed and
    ...  the others should be unaffected.
    ...  After BBMOD reset affected cells must be onAir.
    ...  Kpi14a and Kpi14b are calculated in TC teardown.

Resource  ../../common_resources/ca_KPI_general.robot


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
    ...  - 20.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30059 - Add kpi14a and kpi14b
    ...  - 27.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30444 - Drop kpi14

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS24

    Step0: Set BBMOD Parameters
    Step1: Perform BBMOD Power Reset
    Step2: Check Cells On BBMOD To Be Failed
    Step3: Check The Other Cells To Be OnAir
    Step4: Check Cells On BBMOD To Be OnAir After BBMOD Reset


Step0: Set BBMOD Parameters
    Log  Step0: Set BBMOD parameters  console=true
    ${bbmods}  coam.Get Parameters For All  BBMOD
    FOR  ${bbmod}  IN  @{bbmods}
        IF  '${bbmod}[serialNumber]'=='${BBMOD_SERIAL_NUMBER}'
            Set Test Variable  ${BBMOD_PARAMETERS}  ${bbmod}
            Set Variables For Cells
            RETURN
        END
    END
    Fail  Serial number for BBMOD is wrong! Please provide another one!


Step1: Perform BBMOD Power Reset
    Log  \nStep1: Perform BBMOD power reset  console=True
    coam.Reset Unit  dist_name=${BBMOD_PARAMETERS}[id]  reset_type=PowerReset  timeout=${RESET_TIMEOUT}
    ...  graceful_cell_shutdown=${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}


Step2: Check Cells On BBMOD To Be Failed
    Log  \nStep2: Check cells on BBMOD to be failed  console=True
    Wait Until Keyword Succeeds  180  30
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS}  availabilityStatus=${FAILED}, operationalState=${DISABLED}


Step3: Check The Other Cells To Be OnAir
    Log  \nStep3: Check the other cells to be onAir  console=True
    Check Parameters Status For Cells  ${UNAFFECTED_CELLS}  operationalState=${ENABLED}


Step4: Check Cells On BBMOD To Be OnAir After BBMOD Reset
    Log  \nStep4: Check cells on BBMOD to be onAir after BBMOD reset  console=True
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS}  operationalState=${ENABLED}


Set Variables For Cells
    ${affected_cells}  Get Cell Mapping By Module Id  ${BBMOD_PARAMETERS}[id]
    ${unaffected_cells}  Get Ids For All Cells
    Remove Values From List  ${unaffected_cells}  @{affected_cells}
    Set Test Variable  ${AFFECTED_CELLS}
    Set Test Variable  ${UNAFFECTED_CELLS}


Get Ids For All Cells
    ${list_all_rat}  Create List  NRCEL  LNCEL  WNCEL  GNCEL
    ${cells_list}  Create List
    FOR  ${cell_class_name}  IN  @{list_all_rat}
        ${cell_on_rat}  Get Ids For All  ${cell_class_name}
        Append To List  ${cells_list}  @{cell_on_rat}
    END

    RETURN  ${cells_list}


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    Common Test Teardown
    ${kpis_to_be_calculated}  Create List  kpi14a  kpi14b
    ${kpi14}  Calculate Kpis  ${kpis_to_be_calculated}  ${BTS_FILES}/IM/InfoModel_log.ims2
    FOR  ${kpi}  IN  @{kpis_to_be_calculated}
        Log Delta In Seconds  ${kpi14}[${kpi}][-1][delta]  ${kpi}
        Save Delta Results  ${kpi}
    END
    Set Log Level  TRACE
