*** Settings ***
Documentation
    ...  Step 1: Check if all modules and cells are working
    ...  Checking all cells and modules operationalState if is Enabled, othervise fail.
    ...  If occurred active alarms snapshot is collected.
    ...  Step 2: Switch off power to the BTS
    ...  Step 3: Switch on power to BTS
    ...  and wait for SBTS to be reachable, timeout 10 min
    ...  Step 4: Check if all modules and cells are working
    ...  wait for infomodel response after reset, timeout 5 min
    ...  Checking all cells and modules operationalState if are Enabled, wait for correct state (default 10 min)
    ...  after restore connection to infomodel othervise fail.
    ...  If occurred active alarms snapshot is collected.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  10  # Time need to restor BTS after reset, default value 10 min
${RESET_SMOD_ONLY}  False  # If set False, SMODs and RMODs will reset, and if set True, just SMODs will reset


*** Keywords ***
TC__KPI__Site_power_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21228
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.06.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21228 - Initial creation
    ...  - 27.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21261 - NR cells verification added
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22068 - Option for resetting System module only added
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22066 - Adapt KPI TCs for CNI-61110
    ...  - 13.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22484 - Resolve KPI not collected for individual RATs
    ...  - 22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  - 17.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23922 - Change name of calculated kpi for all cells
    ...  - 10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  - 10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  - 18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  - 16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24317 - Refactor KPI TCs and resources to use KWs from ca_SBTS_general
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS21  SW-SBTS22

    Step 1: Check If All Modules And Cells Are Working
    Step 2: Switch Off Power To The BTS
    Step 3: Switch On Power To BTS
    Step 4: Check If All Modules And Cells Are Working


Step 1: Check If All Modules And Cells Are Working
    Log  Step 1: Check if all modules and cells are working  console=true
    Wait For Target To Be Reachable  ${SMOD1['IP']}  10
    Admin Check All Required State
    IF  ${RESET_SMOD_ONLY}==${TRUE}
        ${global_interfaces_module_list}  Admin Get SMOD Modules For Interfaces
    ELSE
        ${global_interfaces_module_list}  Admin Get Modules For Interfaces TAF
    END
    Set Test Variable  ${GLOBAL_INTERFACES_MODULE_LIST}
    Set Test Restriction If Active Alarms Are Present


Step 2: Switch Off Power To The BTS
    Log  Step 2: switch off power to the BTS  console=true
    ${exit_status}  Run Keyword And Ignore Error  Turn Off Pdu
    IF  '${exit_status[0]}'=='FAIL'  Restore PDU If Test Fails In Step 2  ${exit_status[1]}


Step 3: Switch On Power To BTS
    Log  Step 3: switch on power to the BTS  console=true
    ${power_on_timestamp}  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
    Set Test Variable  ${POWER_ON_TIMESTAMP}
    FOR  ${module_distname}  IN  @{GLOBAL_INTERFACES_MODULE_LIST}
        Pdu BTS Interface On  ${module_distname}
        Log  Power on ${module_distname} is ON.  console=true
        Sleep  1s
    END
    Log  Wait for restore ping to BTS  console=true
    Wait For Target To Be Reachable  ${SMOD1['IP']}  600


Step 4: Check If All Modules And Cells Are Working
    Log  Step 4: Wait for SBTS restore  console=true
    Log  Wait for infomodel response after reset. Timeout 5min.  console=true
    Wait Until Keyword Succeeds  300  30s  coam.Get Managed Objects  MRBTS
    Log  Wait for expected modules states. Timeout ${RESTORE_TIMEOUT}min.  console=true
    Wait For Two Successful Checks Of States In A Row
    Set Test Restriction If Active Alarms Are Present
    IF  ${SCF_COUNT_NR}  Check NR Status To Be Working


Admin Get SMOD Modules For Interfaces
    ${serial_number_list}  Create List
    ${smod_param}  coam.Get Parameters For All  SMOD
    FOR  ${mod}  IN  @{smod_param}
        Append To List  ${serial_number_list}  SMOD_${mod.serialNumber}
    END

    RETURN  ${serial_number_list}


Wait For Two Successful Checks Of States In A Row
    Set Test Variable  ${CHECKING_REQUIRED_STATES_COUNTER}  ${0}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT} min  60 s  Check Required States


Check Required States
    ${check_status}  ${check_msg}  Run Keyword And Ignore Error
    ...  Admin Check All Required State
    IF  '${check_status}'=='PASS'
        Set Test Variable  ${CHECKING_REQUIRED_STATES_COUNTER}  ${CHECKING_REQUIRED_STATES_COUNTER+1}
    ELSE IF  ${CHECKING_REQUIRED_STATES_COUNTER}>0
        Set Test Variable  ${CHECKING_REQUIRED_STATES_COUNTER}  ${0}
        Fail  States are unstable. Probably infomodel didn't refresh after power reset
    ELSE
        Set Test Variable  ${CHECKING_REQUIRED_STATES_COUNTER}  ${0}
        Fail  ${check_msg}
    END

    IF  ${CHECKING_REQUIRED_STATES_COUNTER}<2  Fail  Insufficient success in a row


Turn Off Pdu
    ${distname_turned_off_pdu}  Create List
    Set Test Variable  ${DISTNAME_TURNED_OFF_PDU_GLOBAL}  ${distname_turned_off_pdu}
    FOR  ${module_distname}  IN  @{GLOBAL_INTERFACES_MODULE_LIST}
        Pdu BTS Interface Off  ${module_distname}
        Log  Power on ${module_distname} is OFF.  console=true
        Append To List  ${distname_turned_off_pdu}  ${module_distname}
        Set Test Variable  ${DISTNAME_TURNED_OFF_PDU_GLOBAL}  ${distname_turned_off_pdu}
        Sleep  1s
    END
    Wait For Target To Be Not Reachable  ${SMOD1['IP']}


Restore PDU If Test Fails In Step 2
    [Arguments]  ${error_msg}

    Log  Error ${error_msg}  level=ERROR  console=true
    Log  Restore pdu  console=true
    FOR  ${module_distname}  IN  @{DISTNAME_TURNED_OFF_PDU_GLOBAL}
        Pdu BTS Interface On  ${module_distname}
        Log  Restore pdu on ${module_distname}  console=true
        Sleep  1s
    END
    Log  Restored pdu. Break execution  console=true
    Fail


Set Test Restriction If Active Alarms Are Present
    ${list_of_active_alarms}  Admin Check Active Alarms TAF  collect_snapshot=${True}
    ${length}  Get Length  ${list_of_active_alarms}
    IF  ${length}>0  Set Test Restriction  Active alarms exist: ${list_of_active_alarms}


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=KPI__Site_power_reset


TC Teardown
    Common Test Teardown
    ${kpi3}  Calculate Kpi3  ${BTS_FILES}/IM/InfoModel_log.ims2  ${POWER_ON_TIMESTAMP}
    Log Delta In Seconds  ${kpi3}[kpi3][-1][delta]  kpi3
    Save Delta Results  kpi3
    Set Log Level  TRACE
