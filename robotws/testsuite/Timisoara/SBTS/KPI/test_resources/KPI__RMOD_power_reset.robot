*** Settings ***
Documentation
    ...  This test turns a specific RMOD off and on from the PDU.
    ...  It also collects different KPIs after execution.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${RMOD_SN}  ${NONE}  # Serial Number of RMOD that is to be tested (if left None, a random RMOD is chosen)
${RESET_TIMEOUT}  600  # Timeout in seconds for SBTS to recover to operational state after RMOD is powered back on


*** Keywords ***
TC__KPI__RMOD_power_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21234
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  21.04.2021 - https://jira3.int.net.nokia.com/browse/TAT-21234 - TAT Creation
    ...  20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22066 - Adapt KPI TCs for CNI-61110
    ...  15.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22197 - Query infomodel for 5G cells fails
    ...  22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24110 - Add kpi54b to be saved in delta json file
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24317 - Refactor KPI TCs and resources to use KWs from ca_SBTS_general
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-vlad.slivilescu@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB007215  GROUP_IN_CHARGE-TIM_1_Vrf  SW-SBTS21  SW-SBTS22

    Step 1: Check SBTS State And Select RMOD Object
    Step 2: Power Off RMOD
    Step 3: Power On RMOD
    Step 4: Wait Until State Is Reestablished


Step 1: Check SBTS State And Select RMOD Object
    Log  \nStep 1: Check SBTS State and select RMOD object  console=true
    Admin Check All Required State
    IF  $RMOD_SN is None  Set Random RMOD SN
    Log  Serial Number is ${RMOD_SN}  console=true


Step 2: Power Off RMOD
    Log  \nStep 2: Power Off RMOD  console=true
    Pdu Bts Interface Off  RMOD_${RMOD_SN}
    Log  RMOD_${RMOD_SN} turned off from pdu  console=true
    Sleep  10s


Step 3: Power On RMOD
    Log  \nStep 3: Power On RMOD  console=true
    ${power_on_timestamp}  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
    Set Test Variable  ${POWER_ON_TIMESTAMP}
    Pdu Bts Interface On  RMOD_${RMOD_SN}
    Log  RMOD_${RMOD_SN} turned on from pdu  console=true


Step 4: Wait Until State Is Reestablished
    Log  \nStep 4: Wait Until State is Reestablished  console=true
    Wait Until Keyword Succeeds  ${RESET_TIMEOUT} s  30 s
    ...  Admin Check All Required State


Set Random RMOD SN
    Log  Choosing a random RMOD SN...  console=True
    ${rmods}  Get Radio List
    ${rmod_count}  Get Length  ${rmods}[radioModules][rmod]
    ${random_rmod_number}  Evaluate  random.randint(0, ${rmod_count}-1)  modules=random
    Set Test Variable  ${RMOD_SN}  ${rmods}[radioModules][rmod][${random_rmod_number}][serialNumber]


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=KPI__RMOD_power_reset


TC Teardown
    Common Test Teardown
    ${kpi54a}  Calculate Kpi54a  ${BTS_FILES}/IM/InfoModel_log.ims2  ${POWER_ON_TIMESTAMP}
    ${kpi54b}  Calculate Kpi54b  ${BTS_FILES}/IM/InfoModel_log.ims2  ${POWER_ON_TIMESTAMP}
    Log Delta In Seconds  ${kpi54a}[kpi54a][-1][delta]  kpi54a
    Log Delta In Seconds  ${kpi54b}[kpi54b][-1][delta]  kpi54b
    Save Delta Results  kpi54a
    Save Delta Results  kpi54b
    Set Log Level  TRACE
