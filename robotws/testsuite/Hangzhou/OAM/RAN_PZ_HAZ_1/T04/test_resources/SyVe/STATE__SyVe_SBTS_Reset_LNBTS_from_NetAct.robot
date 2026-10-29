*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com

Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
TC__STATE__SyVe_SBTS_Reset_LNBTS_from_NetAct
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-12592
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Automated testcase for reset LNBTS performed from NetAct.
    ...    Action: NetAct Monitor -> MRBTS-id -> LNBTS-id -> Element Management -> State Management -> Reset LNBTS
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - check state and alarms for BTS from WebEM and NetAct before and after reset LNBTS from NetAct
    ...    - check BTS MEDIATOR Connection status before and after reset LNBTS from NetAct
    ...    - perform reset LNBTS from NetAct
    ...    - check reset LNBTS behavior based on LTE cells state change
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-12592 - SyVe_STATE LTE RAT reset
    ...    - 13.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14317 - Switch to new Robot Framework-Selenium2 library
    ...    - 14.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-15962 - New expected alarmId for "LMP access via port xxxxx" alarm
    ...    - 27.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16639 - Adapt and check Syve test running on FlatOAM, no BTS MED usage
    ...    - 19.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17475 - Update ignored alarms list.
    ...    - 26.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17450
    ...    - [SyVe] We need to allow LNBTS ID to be user configurable and different from MRBTS ID
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476 - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/TAT-12592_STATE__SyVe_SBTS_Reset_LNBTS_from_NetAct.png
    Set Tags    CM    OWNER-violeta.costea@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-SyVe    SW-SBTS18    CABLING-RFS_01_UE
    Step 1: Check initial BTS state from WebEM
    Step 2: Check initial BTS alarms from WebEM
    Step 3: Perform BTS Alarm Upload from NetAct
    Step 4: Check initial BTS alarms from NetAct
    Step 5: Perform Reset LNBTS from NetAct
    Step 6: Check final BTS state from WebEM
    Step 7: Check final BTS alarms from WebEM
    Step 8: Perform BTS Alarm Upload from NetAct
    Step 9: Check final BTS alarms from NetAct
    Step 10: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state from WebEM
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state from WebEM    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} BTS alarms from WebEM
    [Documentation]    Check BTS alarms from WebEM
    Log    Step ${index}: Check ${when} BTS alarms from WebEM    console=True
    Get and Check Alarms SyVe    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Perform BTS Alarm Upload from NetAct
    [Documentation]    Check Alarm Upload operation from NetAct
    Log    Step ${index}: Perform Alarm Upload from NetAct    console=True
    NetAct Alarm Upload    dist_name=${MRBTS_DN}

Step ${index}: Check ${when} BTS alarms from NetAct
    [Documentation]    Check BTS alarms from NetAct
    Log    Step ${index}: Check ${when} BTS alarms from NetAct    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Perform Reset LNBTS from NetAct
    Log    Step ${index}: Perform Reset LNBTS from NetAct    console=True
    NetAct GUI Prepare Environment
    NetAct Download JNLP file    start_page_url=https://${NETACT['web_url']}    user=${NETACT['user']}    pass=${NETACT['password']}
    ...    application_name=Monitor    application_location=desktop/start.jnlp    jnlp_name=start.jnlp
    Perform Reset LNBTS from Monitor

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Perform Reset LNBTS from Monitor
    [Documentation]    Keyword used to perform all required actions for reset LNBTS from NetAct:
    ...    - select proper LNBTS and perform reset operation
    ...    - check reset LNBTS behavior based on cells state
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${node_path}=    Replace String    ${MRBTS_DN}    /    |
    Set Test Variable    ${mrbts_id}
    ${current_lnbts_id}=    Get Id For Current    LNBTS
    ${match}    ${lnbts_id}=    Should Match Regexp    ${current_lnbts_id}    (\\d+)\\D*\\Z
    Set Test Variable    ${lnbts_id}
    ${node_path}=    Catenate    SEPARATOR=|    ${node_path}    LNBTS-${lnbts_id}
    Log    Waiting for Monitor Application starting    console=True
    NetAct GUI Start Application    alias=Monitor    jnlp_file=${jnlp_location}    window_name=Monitor.*    timeout=600
    Log    Monitor Application started    console=True
    Screenshot.Take Screenshot
    NetAct GUI Go To Tree Node    Objects    ${node_path}
    Log    Perform Reset LNBTS    console=True
    NetAct GUI Perform Tree Node Popup Menu Operation    tree_id=Objects    node_path=${node_path}
    ...    operation=Element Management|State Management|Reset LNBTS    confirmation_dialog=Confirm Operation    confirmation_btn_name=Yes
    Sleep    10s
    Screenshot.Take Screenshot
    Check Reset LTE Behavior
    Log    Reset LNBTS from NetAct Monitor successfully performed    console=True
    Sleep    10s
    Screenshot.Take Screenshot
    [Teardown]    Run Keywords    SeleniumLibrary.Close Browser
    ...    AND    NetAct Close Monitor

Check Reset ${techno} Behavior
    [Documentation]    Helper keyword checking Reset ${techno} behavior based on cells state transition: Disabled -> Enabled
    ...    ${techno} can be LTE or WCDMA
    Wait Until Keyword Succeeds    3 min    5 sec    Check ${techno} Cells Operational State ${_Disabled_}
    Wait Until Keyword Succeeds    3 min    5 sec    Check ${techno} Cells Operational State ${_Enabled_}

Check ${techno} Cells Operational State ${state}
    [Documentation]    Helper keyword checking ${techno} Cells Operational State
    ...    ${techno} can be LTE or WCDMA
    ...    ${state} can be Enabled or Disabled
    Run Keyword If    ${${techno}_cell_ids}    coam.Assert Every    ${techno[0]}NCEL    operationalState=${state}

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
