*** Settings ***
Documentation       Test case for SyVe_SBTS_LockUnlock_LNCEL_from_NetAct
...                 Author: Liu Bin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
TC__STATE__SyVe_SBTS_LockUnlock_LNCEL_from_NetAct
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-12773
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Automated testcase for Lock/Unlock LNCEL performed from NetAct.
    ...    Action: NetAct Monitor -> MRBTS-id -> LNBTS-id -> LNCEL-id -> Element Management -> State Management -> Lock/Unlock LNCEL
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - check state and alarms for BTS from WebEM and NetAct before and after Lock/Unlock LNCEL from NetAct
    ...    - check BTS MEDIATOR Connection status before and after Lock/Unlock LNCEL from NetAct
    ...    - perform Lock/Unlock LNCEL from NetAct
    ...    - check final number and state for all cells
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-12773 - SyVe_STATE LTE cell lock unlock (administrative state change)
    ...    - 13.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14317 - Switch to new Robot Framework-Selenium2 library
    ...    - 04.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15552 - Add New Checks for Test: STATE__SyVe_SBTS_LockUnlock_LNCEL_from_NetAct
    ...    - 14.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-15962 - New expected alarmId for "LMP access via port xxxxx" alarm
    ...    - 27.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16639 - Adapt and check Syve test running on FlatOAM, no BTS MED usage
    ...    - 19.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17475 - Update ignored alarms list.
    ...    - 26.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17450 -
    ...    [SyVe] We need to allow LNBTS ID to be user configurable and different from MRBTS ID
    ...    - 02.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/TAT-12773_STATE__SyVe_SBTS_LockUnlock_LNCEL_from_NetAct.png
    Set Tags    FM    OWNER-violeta.costea@nokia.com    AUTHOR-serban.hamza@nokia.com    PHASE-SyVe    SW-SBTS18    CABLING-RFS_01_UE
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Lock LTE cell from NetAct monitor
    Step 5: Check LTE cell state Locked in WebEM
    Step 6: Unlock LTE cell from NetAct monitor
    Step 7: Check LTE cell state Unlocked in WebEM
    Step 8: Check final BTS state
    Step 9: Check final alarms status from WebEM
    Step 10: Check final alarms status from Netact
    Step 11: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: ${action} LTE cell from NetAct monitor
    Log    Step ${index}: ${action} LTE cell from NetAct monitor    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${current_lnbts_id}=    Get Id For Current    LNBTS
    ${match}    ${lnbts_id}=    Should Match Regexp    ${current_lnbts_id}    (\\d+)\\D*\\Z
    Set Test Variable    ${lnbts_id}
    Perform ${action} On LNCEL Tree Node
    ${administrativeState}=    Run Keyword If    '${action}' == 'Lock'    Set Variable    locked
    ...    ELSE IF    '${action}' == 'Unlock'    Set Variable    unlocked
    Wait Until Keyword Succeeds    3min    5s    Check Actual Configuration Parameters    ${MRBTS_DN}/LNBTS-${lnbts_id}/LNCEL-${lncel_id}
    ...    ui_values=true    administrativeState=${administrativeState}

Step ${index}: Check LTE cell state ${state} in WebEM
    Log    Step ${index}: Check LTE cell state ${state} in WebEM    console=True
    ${administrativeState}=    Run Keyword If    '${state}' == 'Locked'    Set Variable    ${_Locked_}
    ...    ELSE IF    '${state}' == 'Unlocked'    Set Variable    ${_Unlocked_}
    Wait Until Keyword Succeeds    3min    5s    coam.Assert    LNCEL    ${LTE_cell_ids[0]}    administrativeState=${administrativeState}
    Log    LNCEL-${lncel_id} administrative state confirmed from Admin: ${state}    console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Get First LNCEL ID
    ${lncel_id_matches}=    String.Get Regexp Matches    ${LTE_cell_ids[0]}    LNCEL_R-(\\d+)    1
    Set Test Variable    ${lncel_id}    ${lncel_id_matches[0]}
    Log    First LNCEL ID detected: ${lncel_id}    console=True

Perform ${operation} On LNCEL Tree Node
    [Documentation]    Keyword used to:
    ...    - get first LNCEL ID
    ...    - download JNLP file
    ...    - start NetAct Monitor application
    ...    - navigate inside tree node objects to first LNCEL
    ...    - perform lock/unlock on LNCEL selected from NetAct Monitor tree node
    Run Keyword If    "${operation}"=="Lock"    Run Keywords    Get First LNCEL ID
    ...    AND    NetAct GUI Prepare Environment
    ...    AND    NetAct Download JNLP file    start_page_url=https://${NETACT['web_url']}    user=${NETACT['user']}    pass=${NETACT['password']}
    ...    application_name=Monitor
    ...    application_location=desktop/start.jnlp    jnlp_name=start.jnlp
    ...    AND    NetAct GUI Start Application    alias=Monitor    jnlp_file=${jnlp_location}    window_name=Monitor.*    timeout=600
    ...    AND    Log    Open tree node to perform cell operation    console=True
    ...    AND    NetAct GUI Go To Tree Node    Objects    PLMN-PLMN|MRBTS-${mrbts_id}|LNBTS-${lnbts_id}|LNCEL-${lncel_id}
    Log    Perform ${operation} on LNCEL-${lncel_id}    console=True
    Run Keyword If    "${operation}"=="Unlock"    RemoteSwingLibrary.Select From Main Menu    Tools|Managed Objects|Object Explorer
    NetAct GUI Perform Tree Node Popup Menu Operation    tree_id=Objects    node_path=PLMN-PLMN|MRBTS-${mrbts_id}|LNBTS-${lnbts_id}|LNCEL-${lncel_id}
    ...    operation=Element Management|State Management|${operation} LNCEL    confirmation_dialog=Confirm Operation    confirmation_btn_name=Yes

Particular Teardown
    ${cell_locked}=    Run Keyword And Return Status    coam.Assert    LNCEL    ${LTE_cell_ids[0]}    administrativeState=${_Locked_}
    Run Keyword If    ${cell_locked}    Perform Unlock On LNCEL Tree Node
    SeleniumLibrary.Close Browser
    NetAct Close Monitor
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
