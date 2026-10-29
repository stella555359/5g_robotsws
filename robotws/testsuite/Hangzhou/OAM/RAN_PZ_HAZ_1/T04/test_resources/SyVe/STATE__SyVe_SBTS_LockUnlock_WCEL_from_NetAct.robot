*** Settings ***
Documentation       Test case for SyVe_SBTS_LockUnlock_WCEL_from_NetAct
...                 Author: Liu Bin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
TC__STATE__SyVe_SBTS_LockUnlock_WCEL_from_NetAct
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-12891
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Automated testcase for LockUnlock first WCEL(WCEL-1) performed from NetAct.
    ...    Actions:
    ...
    ...    - NetAct Monitor -> PLMN-PLMN -> RNC-id -> WBTS-id -> WCEL-1 -> Element Management -> State Management -> Lock WCEL
    ...
    ...    - NetAct Monitor -> PLMN-PLMN -> RNC-id -> WBTS-id -> WCEL-1 -> Element Management -> State Management -> Unlock WCEL
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - check state and alarms for BTS from WebEM and NetAct before and after Lock/Unlock WCEL from NetAct
    ...    - check BTS MEDIATOR Connection status before and after LockUnlock WCEL from NetAct
    ...    - perform Lock_Unlock WCEL from NetAct
    ...    - check Cell Availability Status value from WebEM(Offline/Online)
    ...    - check Administrative Cell State value from NetAct(Locked/Unlocked)
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-12891 - SyVe_STATE_WCDMA cell lock unlock (administrative state change)
    ...    - 13.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14317 - Switch to new Robot Framework-Selenium2 library
    ...    - 15.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15780 - Adding time for block WCEL from NetAct
    ...    - 14.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-15962 - New expected alarmId for "LMP access via port xxxxx" alarm
    ...    - 27.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16639 - Adapt and check Syve test running on FlatOAM, no BTS MED usage
    ...    - 19.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17475 - Update ignored alarms list.
    ...    - 01.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-15921 - [SyVe] Investigate Lock_Unlock WCEL fail with TimeoutExpiredException
    ...    - 02.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476 - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/TAT-12891_STATE__SyVe_SBTS_LockUnlock_WCEL_from_NetAct.png
    Set Tags    FM    OWNER-violeta.costea@nokia.com    AUTHOR-ana.tugui@nokia.com    PHASE-SyVe    SW-SBTS18    CABLING-RFS_01_UE
    Step 1: Check initial BTS state from WebEM
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Perform Lock WCEL from NetAct Monitor
    Step 5: Check after lock alarms status from WebEM
    Step 6: Check after lock alarms status from Netact
    Step 7: Perform Unlock WCEL from NetAct Monitor
    Step 8: Check final alarms status from WebEM
    Step 9: Check final alarms status from Netact
    Step 10: Check final BTS state from WebEM
    Step 11: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state from WebEM
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state from WebEM    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from NetAct
    Log    Step ${index}: Check ${when} alarms status from NetAct    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Perform Lock WCEL from NetAct Monitor
    Log    Step ${index}: Perform Lock WCEL from NetAct Monitor    console=True
    Navigate To Tree Node
    Perform Lock WBTS Tree Node

Step ${index}: Perform Unlock WCEL from NetAct Monitor
    Log    Step ${index}: Perform Unlock WCEL from NetAct Monitor    console=True
    Perform Unlock WBTS Tree Node

Navigate To Tree Node
    Sort List    ${WCDMA_cell_ids}
    ${wncel_id_matches}=    String.Get Regexp Matches    ${WCDMA_cell_ids[0]}    WNCEL_R-(\\d+)    1
    Set Test Variable    ${wncel_id}    ${wncel_id_matches[0]}
    Log    First WCEL ID detected: ${wncel_id}    console=True
    ${node_path}=    Replace String    ${WCDMA_DN}    /    |
    ${node_path}=    Catenate    SEPARATOR=|    ${node_path}    WCEL-${wncel_id}
    NetAct GUI Prepare Environment
    NetAct Download JNLP file    start_page_url=https://${NETACT['web_url']}    user=${NETACT['user']}    pass=${NETACT['password']}
    ...    application_name=Monitor    application_location=desktop/start.jnlp    jnlp_name=start.jnlp
    Log    Waiting for Monitor Application starting    console=True
    NetAct GUI Start Application    alias=Monitor    jnlp_file=${jnlp_location}    window_name=Monitor.*    timeout=600
    Log    Monitor Application started    console=True
    Screenshot.Take Screenshot
    NetAct GUI Go To Tree Node    Objects    ${node_path}
    Set Test Variable    ${node_path}
    Screenshot.Take Screenshot

Perform ${operation} WBTS Tree Node
    [Documentation]    Keyword used to perform all actions before starting to apply the NetAct GUI operation:
    ...    - download and open JNLP file for Monitor application
    ...    - select proper WCEL and perform lock/unlock operation
    ...    - check cell availabilityStatus from WebEM (Offline/Online)
    ...    - check AdminCellState from NetAct(Locked/Unlocked)
    Log    Perform ${operation} WCEL-${wncel_id}    console=True
    Run Keyword If    "${operation}"=="Unlock"    RemoteSwingLibrary.Select From Main Menu    Tools|Managed Objects|Object Explorer
    Sleep    10s
    NetAct GUI Perform Tree Node Popup Menu Operation    tree_id=Objects    node_path=${node_path}
    ...    operation=Element Management|State Management|${operation} WCEL
    ...    confirmation_dialog=Confirm Operation    confirmation_btn_name=Yes
    Check ${operation} WCEL Behavior
    Log    ${operation} WCEL-${wncel_id} from NetAct Monitor successfully performed    console=True
    Screenshot.Take Screenshot

Check ${operation} WCEL Behavior
    [Documentation]    Helper keyword for checking cell availabilityStatus value from WebEM(Offline/Online)
    ...    and AdminCellState value from NetAct(Locked/Unlocked) based on selected operation(${operation})
    Run Keyword If    '${operation}'=='Lock'    Run Keywords    Wait Until Keyword Succeeds    5min    5s
    ...    Check WCDMA Cells Availability Status Offline
    ...    AND    Log    WCEL-${wncel_id} availabilityStatus confirmed from Admin: Offline    console=True
    ...    AND    Check Actual Configuration Parameters    ${WCDMA_DN}/WCEL-${wncel_id}    ui_values=true    AdminCellState=Locked
    ...    AND    Log    WCEL-${wncel_id} AdminCellState confirmed from NetAct: Locked    console=True
    ...    ELSE IF    '${operation}'=='Unlock'    Run Keywords    Wait Until Keyword Succeeds    5min    5s
    ...    Check WCDMA Cells Operational State Enabled
    ...    AND    Log    WCEL-${wncel_id} availabilityStatus confirmed from Admin: Online    console=True
    ...    AND    Check Actual Configuration Parameters    ${WCDMA_DN}/WCEL-${wncel_id}    ui_values=true    AdminCellState=Unlocked
    ...    AND    Log    WCEL-${wncel_id} AdminCellState confirmed from NetAct: Unlocked    console=True

Check WCDMA Cells Availability Status Offline
    [Documentation]    Helper keyword checking WCDMA Cells Availability Status
    Sort List    ${WCDMA_cell_ids}
    Run Keyword If    ${WCDMA_cell_ids}    coam.Assert    WNCEL    ${WCDMA_cell_ids[0]}    availabilityStatus="${_Offline_}"

Check WCDMA Cells Operational State Enabled
    [Documentation]    Helper keyword checking WCDMA Cells Availability Status
    Sort List    ${WCDMA_cell_ids}
    Run Keyword If    ${WCDMA_cell_ids}    coam.Assert    WNCEL    ${WCDMA_cell_ids[0]}    operationalState=${_Enabled_}

Particular Teardown
    ${cell_locked}=    Run Keyword And Return Status    Check WCDMA Cells Availability Status Offline
    Run Keyword If    ${cell_locked}    Perform Unlock WBTS Tree Node
    SeleniumLibrary.Close Browser
    NetAct Close Monitor
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
