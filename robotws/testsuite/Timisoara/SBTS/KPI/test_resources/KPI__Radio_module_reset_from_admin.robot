*** Settings ***
Documentation
    ...  Expected radio states before and after reset:
    ...   blockingState=Unblocked,
    ...   operationalState=Enabled
    ...  Expected cell states before and after reset:
    ...   blockingState=Unblocked,
    ...   administrativeState=Unlocked,
    ...   operationalState=Enabled
    ...  step1:
    ...  Radio reset from ADMIN
    ...  step2:
    ...  SBTS is restored

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${RMOD_SERIAL_NUMBER}  ${EMPTY}  # Serial number reseted radio module, if empty reset all radio modules.
${RESET_TIMEOUT}  180  # Timeout in seconds for waitting for positive procedure (reset unit) result.
${RESETTYPE}  Warm  # reset_type (string) for KW Unit Reset Cp ? Soft|Hard|Warm, if SW is SBTS17 please use Hard
${BCF_VERIFICATION_TIMEOUT}  5 minutes  # Timeout for verification of BCF states (TRX, sectors, OAM link should have state WO)
${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  ${False}
${CALCULATE_RESET_DURATION}  ${False}


*** Keywords ***
TC__KPI__Radio_module_reset_from_admin
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21516
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.06.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21516 - New TC with KPI measurements for TAT-21516
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22066 - Adapt KPI TCs for CNI-61110
    ...  - 22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  - 10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  - 10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  - 18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  - 09.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24295 - Remove Log all TX power
    ...  - 16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24317 - Refactor KPI TCs and resources to use KWs from ca_SBTS_general
    ...  - 21.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24324 - Change collecting ims used in calculating KPI
    ...  - 13.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25540 - Add option for activating graceful cell shutdown before reset
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26611 - Add calculation for reset duration
    ...  - 26.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28008 - Decrease update interval for setup admin
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28139 - Set update interval to 50 ms
    ...  - 30.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28308 - Try to calculate reset duration from both ims colected
    ...  - 20.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28430 - Use ims from common test teardown to calculate kpis

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS21  SW-SBTS22

    Step1 Radio Reset From ADMIN
    Step2 SBTS Is Restored


Step1 Radio Reset From ADMIN
    Log  \nStep1 check all required states and radio reset from ADMIN.\n  console=true
    IF  '${RMOD_SERIAL_NUMBER}'
      _Reset Radio Module
    ELSE
      _Reset All Radio Modules
    END
    ${gncels}  coam.Get Parameters For All  GNCEL
    IF  ${gncels}  Verify BCF States


Step2 SBTS Is Restored
    Log  \nStep2 check all reqiuired states after reset.\nTimeout 10 min\n  console=true
    Wait Until Keyword Succeeds  9 minutes  60 sec  Admin Check All Required State
    ${alarms_msg}  Admin Check Active Alarms TAF  collect_snapshot=${True}
    IF  ${alarms_msg}  Set Test Restriction  Unexpected alarms are present: ${alarms_msg}


_Reset All Radio Modules
    ${param}  coam.Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{param}
        Log  Reset radio with dist name: ${rmod.id}  console=true
        coam.Reset_unit  dist_name=${rmod.id}  reset_type=${RESETTYPE}  timeout=${RESET_TIMEOUT}
        ...  graceful_cell_shutdown=${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}
        ${cells_on_rmod}  Get Cell Mapping By Module Id  ${rmod.id}
        Wait Until Keyword Succeeds  300  30  Check Cells To Be OnAir  ${cells_on_rmod}
    END


Check Cells To Be OnAir
    [Arguments]  ${cells_on_rmod}

    FOR  ${cell_id}  IN  @{cells_on_rmod}
        ${cell_type}  Get Regexp Matches  ${cell_id}  [A-Z]{2}CEL
        Assert  ${cell_type}[0]  ${cell_id}  operationalState=${ENABLED}
        Check If Cell Is Not Degraded  ${cell_type}[0]  ${cell_id}
    END


_Reset Radio Module
    ${rmod}  _Get Radio Module With Given Serial Number  ${RMOD_SERIAL_NUMBER}
    Log  Reset radio with dist name: ${rmod.id}  console=true
    coam.Reset_unit  dist_name=${rmod.id}  reset_type=${RESETTYPE}  timeout=${RESET_TIMEOUT}
    ...  graceful_cell_shutdown=${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}


_Get Radio Module With Given Serial Number
    [Arguments]  ${serial_number}

    ${rmods}  coam.Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods}
        IF  '${serial_number}'=='${rmod.serialNumber}'  RETURN  ${rmod}
    END
    Set Test Failed  ${serial_number} is wrong, please set correct RMOD_SERIAL_NUMBER  fail_fast=${True}


Verify BCF States
    Log  Verifying BCF state (TRXs, sectors, OAM link)  console=true
    ${bcf_id}  Infomodel Get BCF ID
    hran_bsc.Bsc SSH Connection  ${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}
    Wait Until Keyword Succeeds  ${BCF_VERIFICATION_TIMEOUT}  30 sec  _BCF States Checker  ${bcf_id}

    [Teardown]  hran_bsc.Close All Connections


_BCF States Checker
    [Arguments]  ${bcf_id}

    ${sectors_state}  hran_bsc.Get Sectors State  ${bcf_id}  operational
    ${sectors_state}  Evaluate  all([state[1]=='WO' for state in ${sectors_state}])

    ${trxs_state}  hran_bsc.Get TRXs State  ${bcf_id}  operational
    ${trxs_state}  Evaluate  all([state[1]=='WO' for state in ${trxs_state}])

    ${om_link_state}  hran_bsc.Get OM Link State  ${bcf_id}
    ${om_link_state}  Evaluate  '${om_link_state}'=='WO'

    Should Be True  ${sectors_state} and ${trxs_state} and ${om_link_state}


Calculate RMOD Reset Duration
    ${kpirmodreset}  Calculate Kpirmodreset  ${BTS_FILES}/IM/InfoModel_log.ims2
    Log Delta In Seconds  ${kpirmodreset}[kpirmodreset][-1][delta]  kpirmodreset
    Save Delta Results  kpirmodreset


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    Common Test Teardown
    ${kpi51}  Calculate Kpis  kpi51a kpi51b  ${BTS_FILES}/IM/InfoModel_log.ims2
    Log Delta In Seconds  ${kpi51}[kpi51a][-1][delta]  kpi51a
    Log Delta In Seconds  ${kpi51}[kpi51b][-1][delta]  kpi51b
    Save Delta Results  kpi51a
    Save Delta Results  kpi51b
    Run Keyword If  ${CALCULATE_RESET_DURATION}
    ...  Calculate RMOD Reset Duration
    Set Log Level  TRACE
