*** Settings ***
Documentation
    ...  Step 1: Check if all modules and cells are working
    ...  Checking all cells and modules operationalState if is Enabled, othervise fail.
    ...  If occurred active alarms snapshot is collected.
    ...
    ...  Step 2: Switch off power to the BTS
    ...
    ...  Step 3: Switch on power to BTS
    ...  and wait for SBTS to be reachable, timeout 10 min
    ...
    ...  Step 4: Check if all modules and cells are working
    ...  wait for infomodel response after reset, timeout 5 min
    ...  Checking all cells and modules operationalState if are Enabled, wait for correct state (default 10 min)
    ...  after restore connection to infomodel othervise fail.
    ...  If occurred active alarms snapshot is collected.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  10  # Time need to restor BTS after reset, default value 10 min


*** Keywords ***
TC__STATE__Site_power_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4055
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 11.10.2016 - https://jira3.int.net.nokia.com/browse/TAT-4055 - Initial creation
    ...  - 28.10.2016 - https://jira3.int.net.nokia.com/browse/TAT-4491 - Added restore pdu when test fail during turn off pdu.
    ...  - 13.12.2016 - https://jira3.int.net.nokia.com/browse/TAT-4906 - Added work around collecting snapshot when ADMIN API fail.
    ...  - 24.01.2017 - https://jira3.int.net.nokia.com/browse/TAT-5325 - Failing check alarm function don't stop test execution.
    ...  - 06.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5718 - Corrected path to snapshot
    ...  - 17.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5651 - Updated Commom Test Setup
    ...  - 20.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-6208 - Added state cell logging, changed Try Collect Snapshot
    ...  keyword to Admin Get Snapshot from hran_admin.robot
    ...  - 24.07.2107 - https://jira3.int.net.nokia.com/browse/TAT-7203
    ...  - 11.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-7411
    ...  - 20.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7654 - Added support for hran_logging==2.1.0
    ...  - 14.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8249 - Migration from ute_infomodel to ADMIN Abstraction Layer
    ...  - 30.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8383
    ...  - 02.01.2018 - https://jira3.int.net.nokia.com/browse/TAT-8277 - Logging KPIs added
    ...  - 13.07.2018 - https://jira3.int.net.nokia.com/browse/TAT-9667 - added double check of required states after power reset
    ...  - 02.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12449 - Add allowed alarams due to RP001063 delivery
    ...  - 23.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15405 - Add restriction to TC when unexpected alarms are visible
    ...  - 03.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18397 - Adding new keyword to TC
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4055.png#
    ...

    Set Tags  CA-STATE  OWNER-grzegorz.gulaj@nokia.com  AUTHOR-michal.kwasniewicz@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP0001145_RP000923

    Step 1: Check If All Modules And Cells Are Working
    Step 2: Switch Off Power To The BTS
    Step 3: Switch On Power To BTS
    Step 4: Check If All Modules And Cells Are Working


Step 1: Check If All Modules And Cells Are Working
    Log  Step 1: Check if all modules and cells are working  console=true
    Wait For Target To Be Reachable  ${SMOD1['IP']}  10
    Admin Check All Required State
    ${global_interfaces_module_list}  Admin Get Modules For Interfaces TAF
    Set Test Variable  ${GLOBAL_INTERFACES_MODULE_LIST}
    Set Test Restriction If Active Alarms Are Present


Step 2: Switch Off Power To The BTS
    Log  Step 2: switch off power to the BTS  console=true
    ${exit_status}  Run Keyword And Ignore Error
    ...  Turn Off Pdu
    Run Keyword If  '${exit_status[0]}'=='FAIL'
    ...  Restore PDU If Test Fails In Step 2  ${exit_status[1]}


Step 3: Switch On Power To BTS
    Log  Step 3: switch on power to the BTS  console=true
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
    ute_admin_infomodel.Wait For Infomodel Response After Reset  timeout_for_reset=0  timeout_for_response=300
    Log  Wait for expected modules states. Timeout ${RESTORE_TIMEOUT}min.  console=true
    Wait For Two Successful Checks Of States In A Row
    Set Test Restriction If Active Alarms Are Present


Wait For Two Successful Checks Of States In A Row
    Set Test Variable  ${CHECKING_REQUIRED_STATES_COUNTER}  ${0}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT} min  30 s
    ...  Check Required States


Check Required States
    ${check_status}  ${check_msg}  Run Keyword And Ignore Error
    ...  Admin Check All Required State
    Run Keyword If  '${check_status}'=='PASS'
    ...  Set Test Variable  ${CHECKING_REQUIRED_STATES_COUNTER}  ${CHECKING_REQUIRED_STATES_COUNTER+1}
    ...  ELSE IF  ${CHECKING_REQUIRED_STATES_COUNTER}>0
    ...  Run Keywords
    ...  Set Test Variable  ${CHECKING_REQUIRED_STATES_COUNTER}  ${0}
    ...  AND
    ...  Fail  States are unstable. Probably infomodel didn't refresh after power reset
    ...  ELSE
    ...  Run Keywords
    ...  Set Test Variable  ${CHECKING_REQUIRED_STATES_COUNTER}  ${0}
    ...  AND
    ...  Fail  ${check_msg}

    Run Keyword If  ${CHECKING_REQUIRED_STATES_COUNTER}<2
    ...  Fail  Insufficient success in a row


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
    Run Keyword If  ${length}>0
    ...  Set Test Restriction  Active alarms exist: ${list_of_active_alarms}


TC Setup
    Common Test Setup  tc_name=STATE__Site_power_reset


TC Teardown
    Common Test Teardown
