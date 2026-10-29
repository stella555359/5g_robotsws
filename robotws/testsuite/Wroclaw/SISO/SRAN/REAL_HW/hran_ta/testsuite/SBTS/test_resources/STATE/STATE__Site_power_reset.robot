*** Settings ***
Documentation
...  TC for verification of site power reset

Resource    ../../../../resources/ca_siso_hran.robot
Resource    ../../../../resources/hran_frame_sbts_siso.robot

*** Variables ***
${RESTORE_TIMEOUT}=                 10        #Time need to restor BTS after reset, default value 10 min


*** Keywords ***
TC__STATE__Site_power_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4055
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
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
    ...
    ...  NOTE. If test used with OBSAI RUs (dual link), fault 1811 Warning can appear. Please adjust accordingly your TS allowed faults.
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
    ...  - 20.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22244 - Changes due to CNI-61110
	...  - 19.08.2022 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-12528 - Aligning TC to 5G and remove hran resources
	...  - 10.11.2022 - Removing library hran_ims
	...  - 26.11.2024 - Adding documentation extension regarding fault 1811 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-48966
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4055.png#
    ...


    Set Tags    CA-STATE    OWNER-grzegorz.gulaj@nokia.com    AUTHOR-michal.kwasniewicz@nokia.com
    ...    MAINTAINER-daniel.bartkowiak@nokia.com    GROUP_IN_CHARGE-WRO_4_Vrf    PHASE-CIT    SW-SBTS17    SW-SBTS18
    ...    SW-SBTS19    FEATURE-RP001498_RP000923    FEATURE-RP001621_RP000923    FEATURE-RP001486_RP000923
    ...    FEATURE-RP0001145_RP000923

    Step 1: Check If All Modules And Cells Are Working
    Step 2: Switch Off Power To The BTS
    Step 3: Switch On Power To BTS
    Step 4: Check If All Modules And Cells Are Working

Step 1: Check If All Modules And Cells Are Working
    Log    Step 1: Check if all modules and cells are working    console=${TRUE}
    ${SMOD1_IP}=  Create List  ${SMOD1['IP']}
    Set Test Variable  ${SMOD1_IP}
    ${no_ping}=  Run Keyword And Return Status  ping.Wait For No Ping  ${SMOD1_IP}  timeout=10
    Run Keyword If  ${no_ping}  Fail  No ping to SMOD1
    Admin Check All Required State
    ${global_interfaces_module_list}=    Siso Admin Get Modules For Interfaces TAF
    Set Test Variable    ${global_interfaces_module_list}

Step 2: Switch Off Power To The BTS
    Log    Step 2: switch off power to the BTS    console=${TRUE}
    ${exit_status}=    Run Keyword And Ignore Error    Turn off pdu
    Run Keyword If    '${exit_status[0]}'=='FAIL'
    ...  Restore PDU if test fails in Step 2    ${exit_status[1]}

Step 3: Switch On Power To BTS
    Log  Step 3: switch on power to the BTS    console=${TRUE}
    FOR  ${module_distname}  IN  @{global_interfaces_module_list}
        Turn On Pdu Interface    ${module_distname}
        Log    Power on ${module_distname} is ON.    console=${TRUE}
        Sleep    1s
    END
    Log    Wait for restore ping to BTS    console=yes
    ping.Wait For Ping  ${SMOD1_IP}  timeout=600

Step 4: Check If All Modules And Cells Are Working
    Log    Step 4: Wait for SBTS restore    console=yes
    Log    Wait for infomodel response after reset. Timeout 5min.    console=${TRUE}
	${result}=  Wait Until Keyword Succeeds  300s  10s  admin.Get mrbts state  connection=default
    Log    Wait for expected modules states. Timeout ${RESTORE_TIMEOUT}min.    console=${TRUE}
    Wait for two successful checks of states in a row

Wait for two successful checks of states in a row
    Set test variable  ${checking_required_states_counter}  ${0}
    Wait Until Keyword Succeeds    ${RESTORE_TIMEOUT} min    30 s
    ...  Check required states

Check required states
    ${check_status}  ${check_msg}=  Run keyword and ignore error  Admin Check All Required State
    Run keyword if  '${check_status}'=='PASS'
        ...  Set test variable  ${checking_required_states_counter}  ${checking_required_states_counter+1}
    ...  ELSE IF  ${checking_required_states_counter}>0  Run keywords
        ...  Set test variable  ${checking_required_states_counter}  ${0}
        ...  AND  Fail  States are unstable. Probably infomodel didn't refresh after power reset
    ...  ELSE  Run keywords
        ...  Set test variable  ${checking_required_states_counter}  ${0}
        ...  AND  Fail  ${check_msg}
    Run keyword if  ${checking_required_states_counter}<2  Fail  Insufficient success in a row

Turn off pdu
    ${distname_turned_off_pdu}=  create list
    Set Test Variable    ${distname_turned_off_pdu_global}    ${distname_turned_off_pdu}
    FOR  ${module_distname}  IN  @{global_interfaces_module_list}
        Turn Off Pdu Interface    ${module_distname}
        Log    Power on ${module_distname} is OFF.    console=${TRUE}
        Append To List    ${distname_turned_off_pdu}    ${module_distname}
        Set Test Variable    ${distname_turned_off_pdu_global}    ${distname_turned_off_pdu}
        Sleep  1s
    END
    ping.Wait For No Ping  ${SMOD1_IP}  timeout=60

Restore PDU if test fails in Step 2
    [Arguments]  ${error_msg}

    Log    Error ${error_msg}    level=ERROR    console=${TRUE}
    Log    Restore pdu    console=yes
    FOR  ${module_distname}  IN  @{distname_turned_off_pdu_global}
        Turn On Pdu Interface    ${module_distname}
        Log  Restore pdu on ${module_distname}  console=${TRUE}
        Sleep  1s
    END
    Log    Restored pdu. Break execution    console=${TRUE}
    Fail

Admin Check All Required State
    Run Keyword If    ${SCF_COUNT_NR}   Run Keywords
    ...  admin.Assert Every  NRCEL  blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked"
    ...  AND
    ...  Siso Admin Check Cells Number TAF    NRCEL    ${SCF_COUNT_NR}
    Run Keyword If    ${SCF_COUNT_LTE}   Run Keywords
    ...  admin.Assert Every  LNCEL  blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked"
    ...  search_for_iot_cells=${True}
    ...  AND
    ...  Siso Admin Check Cells Number TAF    LNCEL    ${SCF_COUNT_LTE}
    Run Keyword If    ${SCF_COUNT_GSM}   Run Keywords
    ...  admin.Assert Every  GNCEL  blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked"
    ...  AND
    ...  Siso Admin Check Cells Number TAF    GNCEL    ${SCF_COUNT_GSM}
    Run Keyword If    ${SCF_COUNT_WCDMA}   Run Keywords
    ...  admin.Assert Every  WNCEL  blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Enabled", usageState=regex"(?i)Active"
    ...  AND
    ...  Siso Admin Check Cells Number TAF    WNCEL    ${SCF_COUNT_WCDMA}
    admin.Assert Every    RMOD    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
    admin.Assert Every    SMOD    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
