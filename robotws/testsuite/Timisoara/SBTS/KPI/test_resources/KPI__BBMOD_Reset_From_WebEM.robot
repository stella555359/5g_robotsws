*** Settings ***
Documentation
    ...  TC for BBMOD reset from Web EM. BBMOD reset is performed. Cells on BBMOD must be failed and
    ...  the others should not have to be disabled. All of them are verified and must be as expected.
    ...  After BBMOD reset disabled cells must be onAir.

Resource  ../../common_resources/ca_KPI_general.robot


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
    ...  21.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21232 - Test creation
    ...  22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  12.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24213 - KPI__BBMOD_Reset_From_WebEM failed
    ...  13.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25540 - Add option for activating graceful cell shutdown before reset
    ...  27.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26323 - Change Get ids for all usage
    ...  15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26611 - Add calculation for reset duration
    ...  26.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28008 - Decrease update interval for setup admin
    ...  30.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28308 - Try to calculate reset duration from both ims colected
    ...  20.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28430 - Use ims from common test teardown to calculate kpis
    ...  20.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30063 - Add kpi5a and kpi5b
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS22

    Step 0: Set BBMOD Object
    Step 1: Perform BBMOD Reset
    Step 2: Check If Cells On BBMOD Are Failed
    Step 3: Check If Cells On Other BBMODs Are OnAir
    Step 4: Check If Cells On BBMOD Are OnAir After BBMOD Reset


Step 0: Set BBMOD Object
    Log  Step 0: Set BBMOD object  console=true
    ${BBMOD_OBJ}  Get BBMOD With Given Serial Number  ${BBMOD_SERIAL_NUMBER}
    Set Test Variable  ${BBMOD_OBJ}


Step 1: Perform BBMOD Reset
    Log  Step 1: Perform BBMOD reset  console=True
    coam.Reset_unit  dist_name=${BBMOD_OBJ}[id]  reset_type=${RESET_TYPE}  timeout=${RESET_TIMEOUT}
    ...  graceful_cell_shutdown=${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}


Step 2: Check If Cells On BBMOD Are Failed
    Log  Step 2: Check if cells on BBMOD are failed  console=True
    Wait Until Keyword Succeeds  300  30
    ...  Check Status For Cells On BBMOD  ${UNBLOCKED}  ${DISABLED}


Step 3: Check If Cells On Other BBMODs Are OnAir
    Log  Step 3: Check if cells on other BBMODs are onAir  console=True
    ${left_over_cells_on_bbmod}  Get All Cells On Bts
    ${cells_on_bbmod}  Get Cell Mapping By Module Id  ${BBMOD_OBJ.id}
    Remove Values From List  ${left_over_cells_on_bbmod}  @{cells_on_bbmod}
    Check Cells  ${left_over_cells_on_bbmod}  ${UNBLOCKED}  ${ENABLED}


Step 4: Check If Cells On BBMOD Are OnAir After BBMOD Reset
    Log  Step 4: Check if cells on BBMOD are onAir after BBMOD reset  console=True
    Wait Until Keyword Succeeds  1200  60  Check Status For Cells On BBMOD  ${UNBLOCKED}  ${ENABLED}
    Admin Check Active Alarms TAF


Check Status For Cells On BBMOD
    [Arguments]  ${blocking_state}  ${operational_state}

    ${cells_on_bbmod}  Get Cell Mapping By Module Id  ${BBMOD_OBJ.id}
    Check Cells  ${cells_on_bbmod}  ${blocking_state}  ${operational_state}


Check Cells
    [Arguments]  ${cells_list}  ${blocking_state}  ${operational_state}

    FOR  ${cell_id}  IN  @{cells_list}
        ${class_name}  Get Regexp Matches  ${cell_id}  [A-Z]{2}CEL
        ${status}  Run Keyword And Return Status
        ...  Assert  ${class_name}[0]  id=${cell_id}  blockingState=${blocking_state}, operationalState=${operational_state}  timeout=200s
        IF  ${status}
            Log  Cell with id ${cell_id} is ${blocking_state} and ${operational_state}. [OK]  console=true
        ELSE
            Set Test Failed  Cell with id ${cell_id} is not ${blocking_state} and ${operational_state}. [NOK]
        END
    END


Get BBMOD With Given Serial Number
    [Arguments]  ${serial_number}

    ${bbmods}  Get Parameters For All  BBMOD
    FOR  ${bbmod}  IN  @{bbmods}
        IF  '${serial_number}'=='${bbmod}[serialNumber]'  RETURN  ${bbmod}
    END
    Fail  ${serial_number} is wrong, please set correct BBMOD_SERIAL_NUMBER


Calculate BBMOD Reset Duration
    ${kpibbmodreset}  Calculate Kpibbmodreset  ${BTS_FILES}/IM/InfoModel_log.ims2
    Log Delta In Seconds  ${kpibbmodreset}[kpibbmodreset][-1][delta]  kpibbmodreset
    Save Delta Results  kpibbmodreset


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    Common Test Teardown
    ${kpis_to_be_calculated}  Create List  kpi5a  kpi5b
    ${kpi5}  Calculate Kpis  ${kpis_to_be_calculated}  ${BTS_FILES}/IM/InfoModel_log.ims2
    FOR  ${kpi}  IN  @{kpis_to_be_calculated}
        Log Delta In Seconds  ${kpi5}[${kpi}][-1][delta]  ${kpi}
        Save Delta Results  ${kpi}
    END
    IF  ${CALCULATE_RESET_DURATION}  Calculate BBMOD Reset Duration
    Set Log Level  TRACE
