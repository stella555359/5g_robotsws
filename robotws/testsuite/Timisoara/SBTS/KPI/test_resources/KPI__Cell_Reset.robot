*** Settings ***
Documentation
...  One cell from all RATs is provided by user and kpi19 and kpicellreset are calculated based on reset operation of chosen cell.
...  Cell must change its state to Disabled due to reset operation and must reach Enabled state after cell reset is finished.
...  In the end, SBTS must be onAir, unaffected by cell reset.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${CELL_RECOVERY_TIMEOUT}  120  # Time in seconds for cell to reach on air state
${CELL_TO_RESET}  ${EMPTY}  # Mandatory, runtime distname of cell to reset


*** Keywords ***
TC__KPI__Cell_Reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30639
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 13.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30639 - Initial creation

    Set Tags  CA-KPI  OWNER-lorena.borobar@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  SW-SBTS26  CB014929

    Step1: Reset Cell And Wait For Disabled Status
    Step2: Check SBTS To Be OnAir


Step1: Reset Cell And Wait For Disabled Status
    Log  \nStep1: Reset Cell And Wait For Disabled Status  console=true

    Should Not Be Empty  ${CELL_TO_RESET}  Please provide runtime distname for desired cell to reset.
    Log  Reset will be performed on cell: ${CELL_TO_RESET}.  console=true
    Reset Cell  ${CELL_TO_RESET}  120
    ${cell_class_name}  Get Regexp Matches  ${CELL_TO_RESET}  [A-Z]{2}CEL
    Assert  ${cell_class_name}[0]  ${CELL_TO_RESET}  parameters=operationalState=${DISABLED}, availabilityStatus=${OFFLINE}  timeout=120


Step2: Check SBTS To Be OnAir
    Log  \nStep2: Check SBTS To Be OnAir  console=true

    Wait Until Keyword Succeeds  ${CELL_RECOVERY_TIMEOUT}  10s  Admin Check All Required State


Calculate KPI19 And Cell Reset Duration
    ${kpis_to_be_calculated}  Create List  kpi19  kpicellreset
    ${kpis_results}  Calculate Kpis  ${kpis_to_be_calculated}  ${BTS_FILES}/IM/InfoModel_log.ims2
    FOR  ${kpi}  IN  @{kpis_to_be_calculated}
        Log Delta In Seconds  ${kpis_results}[${kpi}][-1][delta]  ${kpi}
        Save Delta Results  ${kpi}
    END


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup


TC Teardown
    Common Test Teardown
    Calculate KPI19 And Cell Reset Duration
    Set Log Level  TRACE
