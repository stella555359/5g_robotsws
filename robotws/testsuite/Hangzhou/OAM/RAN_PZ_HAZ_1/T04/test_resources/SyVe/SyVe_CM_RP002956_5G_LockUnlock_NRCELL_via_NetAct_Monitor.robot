*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_RP002956_5G_LockUnlock_NRCELL_via_NetAct_Monitor
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-20796
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Automated testcase for Lock/Unlock NRCELL performed from NetAct.
    ...    Action: NetAct Monitor -> MRBTS-id -> NRBTS-id -> NRCEL-id -> Element Management -> State Management -> Lock/Unlock NRCELL
    ...    The main steps performed for the test are:
    ...    - check state and alarms for BTS from WebEM and NetAct before and after Lock/Unlock NRCELL from NetAct
    ...    - perform Lock/Unlock NRCELL from NetAct
    ...    - check final number and state for all cells
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.01.2021 - https://jira3.int.net.nokia.com/browse/TAT-20796 - new case
    ...    - 31.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21121 - Update to replace infomodel keywords to admin keywords
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-20796_SyVe_CM_LockUnlock_NRCELL_via_NetAct_Monitor_RP002956_5G.png
    Set Tags    CM    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com    AUTHOR-yuyan.xu@nokia.com    PHASE-SyVe
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Random Select NRCELL
    Step 5: Lock NRBTS cell from NetAct monitor
    Step 6: Check NRBTS cell state Locked in WebEM
    Step 7: Unlock NRBTS cell from NetAct monitor
    Step 8: Check NRBTS cell state Unlocked in WebEM
    Step 9: Check final BTS state
    Step 10: Check final alarms status from WebEM
    Step 11: Check final alarms status from Netact
    Step 12: Check final number and state of Cells and RMs

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

Step ${index}: Random Select NRCELL
    Log    Step ${index}: Random Select NRCELL    console=True
    ${mrbts_name}    Fetch From Right    ${MRBTS_DN}    /
    Set Test Variable    ${MRBTS}    ${mrbts_name}
    ${nrcell_ids}    coam.Get Ids For All    NRCEL
    ${nrcell_count}    Get Length    ${nrcell_ids}
    ${random}    Evaluate    random.randint(0, ${nrcell_count-1})    modules=random, sys
    ${nrcell_id_selected}    Set Variable    ${nrcell_ids[${random}]}
    ${cells_mapping}    Fetch ID Mapping From Admin For Cells    NRBTS    ${nrcell_id_selected}    internal
    ${NRCELL_id_conf_selected}    Get From Dictionary    ${cells_mapping}    configuration
    ${str_list}    Split String    ${NRCELL_id_conf_selected}    /
    Set Test Variable    ${NRBTS}    ${str_list[1]}
    Set Test Variable    ${NRCELL_id_conf_selected}
    Set Test Variable    ${NRCELL}    ${str_list[2]}
    Set Test Variable    ${NRCELL_RT_DN}    ${nrcell_id_selected}
    Set Test Variable    ${node_path}    PLMN-PLMN|${MRBTS}|${NRBTS}|${NRCELL}

Step ${index}: ${action} NRBTS cell from NetAct monitor
    Log    Step ${index}: ${action} NRBTS cell from NetAct monitor    console=True
    Perform ${action} On NRCELL Tree Node
    ${administrativeState}=    Run Keyword If    '${action}' == 'Lock'    Set Variable    ${_Com_Locked_}
    ...    ELSE IF    '${action}' == 'Unlock'    Set Variable    ${_Com_Unlocked_}
    Wait Until Keyword Succeeds    3min    5s    Check Actual Configuration Parameters    PLMN-PLMN/${NRCELL_id_conf_selected}
    ...    ui_values=true    administrativeState=${administrativeState}

Step ${index}: Check NRBTS cell state ${state} in WebEM
    Log    Step ${index}: Check NRBTS cell state ${state} in WebEM    console=True
    Run Keyword If    '${state}'=='Locked'    Wait Until Keyword Succeeds    3 min    2 sec    coam.Assert    NRCEL
    ...    ${NRCELL_RT_DN}    ${cells_NR_locked_state}
    ...    ELSE IF    '${state}'=='Unlocked'    Wait Until Keyword Succeeds    3 min    2 sec    Assert
    ...    NRCEL    ${NRCELL_RT_DN}    ${cells_NR_expected_state}
    Log    ${NRCELL} administrative state confirmed from Admin: ${state}    console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Perform ${operation} On NRCELL Tree Node
    [Documentation]    Keyword used to:
    ...    - download JNLP file
    ...    - start NetAct Monitor application
    ...    - navigate inside tree node objects to selected NRCELL
    ...    - perform lock/unlock on NRCELL selected from NetAct Monitor tree node
    Run Keyword If    "${operation}"=="Lock"    Run Keywords    NetAct GUI Prepare Environment
    ...    AND    NetAct Download JNLP file    start_page_url=https://${NETACT['web_url']}    user=${NETACT['user']}
    ...    pass=${NETACT['password']}    application_name=Monitor
    ...    application_location=desktop/start.jnlp    jnlp_name=start.jnlp
    ...    AND    NetAct GUI Start Application    alias=Monitor    jnlp_file=${jnlp_location}    window_name=Monitor.*    timeout=600
    ...    AND    Log    Open tree node to perform cell operation    console=True
    ...    AND    NetAct GUI Go To Tree Node    Objects    ${node_path}
    Log    Perform ${operation} on ${NRCELL}    console=True
    Run Keyword If    "${operation}"=="Unlock"    RemoteSwingLibrary.Select From Main Menu    Tools|Managed Objects|Object Explorer
    NetAct GUI Perform Tree Node Popup Menu Operation    tree_id=Objects    node_path=${node_path}
    ...    operation=Element Management|State Management|${operation} NRCELL    confirmation_dialog=Confirm Operation    confirmation_btn_name=Yes

Particular Teardown
    ${cell_locked}=    Run Keyword And Return Status    coam.Assert    NRCEL    ${NRCELL_RT_DN}    ${cells_NR_locked_state}
    Run Keyword If    ${cell_locked}    Perform Unlock On NRCELL Tree Node
    SeleniumLibrary.Close Browser
    NetAct Close Monitor
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
