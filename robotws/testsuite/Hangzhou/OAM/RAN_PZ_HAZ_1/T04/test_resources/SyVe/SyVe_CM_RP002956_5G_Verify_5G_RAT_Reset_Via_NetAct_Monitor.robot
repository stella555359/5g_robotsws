*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${plan_info}      PLAN_TAT-19721    # selected plan infomation define in netact_plan.yaml file;

*** Keywords ***
SyVe_CM_Verify_5G_RAT_Reset_Via_NetAct_Monitor_RP002956_5G
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-20991
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Automated testcase for reset NRBTS performed from NetAct.
    ...    Action: NetAct Monitor -> MRBTS-id -> NRBTS-id -> Element Management -> State Management -> Reset NRBTS
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - check state and alarms for BTS from WebEM and NetAct before and after reset NRBTS from NetAct
    ...    - perform reset NRBTS from NetAct
    ...    - check reset NRBTS behavior based on rat state change
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.03.2021 - https://jira3.int.net.nokia.com/browse/TAT-20991 - SyVe_STATE NR RAT reset
    ...    - 02.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking and add step 1 8
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...       fix: Get Plan -> Get Plan Configuration
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-20991_SyVe_CM_Verify_5G_RAT_Reset_Via_NetAct_Monitor_RP002956_5G.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Set Test Variable    ${plan_info}    ${NETACT_PLAN['${plan_info}']}
    Step 1: TC parameters check
    Step 2: Check initial BTS state
    Step 3: Check initial BTS alarms from WebEM
    Step 4: Check initial BTS alarms from NetAct
    Step 5: Perform Reset NRBTS from NetAct
    Step 6: Check final BTS alarms from WebEM
    Step 7: Check final BTS alarms from NetAct
    Step 8: Check SWRESETRES Result
    Step 9: Create and edit plan SyVe
    Step 10: Export the plan SyVe
    Step 11: Provision the plan SyVe
    Step 12: Check final number and state of Cells and RMs

Step ${index}: TC parameters check
    Log    Step ${index}: TC parameters check started    console=True
    &{param_EMPTY}    Create Dictionary
    Set Test Variable    &{param_EMPTY}
    ${existed_CMD}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_CMD']}
    ...    ui_values=true    &{param_EMPTY}
    ${existed_SWRES}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_SWRES']}
    ...    ui_values=true    &{param_EMPTY}
    Set Test Variable    ${existed_CMD}
    Set Test Variable    ${existed_SWRES}
    Should Not Be True    ${existed_SWRES}

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} BTS alarms from WebEM
    [Documentation]    Check BTS alarms from WebEM
    Log    Step ${index}: Check ${when} BTS alarms from WebEM    console=True
    Get and Check Alarms SyVe    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Check ${when} BTS alarms from NetAct
    [Documentation]    Check BTS alarms from NetAct
    Log    Step ${index}: Check ${when} BTS alarms from NetAct    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Perform Reset NRBTS from NetAct
    Log    Step ${index}: Perform Reset NRBTS from NetAct    console=True
    NetAct GUI Prepare Environment
    NetAct Download JNLP file    start_page_url=https://${NETACT['web_url']}    user=${NETACT['user']}    pass=${NETACT['password']}
    ...    application_name=Monitor    application_location=desktop/start.jnlp    jnlp_name=start.jnlp
    Perform Reset NRBTS from Monitor

Step ${index}: Check SWRESETRES Result
    Log    Step ${index}: Check SWRESETRES Result    console=True
    &{param_EMPTY}    Create Dictionary
    Set Test Variable    &{param_EMPTY}
    &{param_req}    Create Dictionary    swResetLevel=gnbReset
    ${existed_CMD}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_CMD']}
    ...    ui_values=true    &{param_EMPTY}
    ${existed_SWRES}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_SWRES']}
    ...    ui_values=true    &{param_req}
    Set Test Variable    ${existed_CMD}
    Set Test Variable    ${existed_SWRES}
    Should Be True    ${existed_SWRES}
    &{param_res}    Create Dictionary    swResetResult=success
    ${existed_SWRESRES}=    Run Keyword And Return Status    Check Actual Configuration Parameters    ${plan_info['mo_id_SWRES']}/SWRESETRES-1
    ...    ui_values=true    &{param_res}
    Should Be True    ${existed_SWRESRES}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info['scf_distName']}"]
    ${mnl_class}    Fetch From Left    ${MO_items['class']}    :
    Set Test Variable    ${MO_items}
    Set Test Variable    ${mnl_class}
    ${mo_SWRES}=    Run Keyword If    ${existed_SWRES}    netact.create_managed_object    operation=DELETE    plan=${plan}
    ...    meta_class=${mnl_class}:SWRESETREQ
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id_SWRES']}    &{param_EMPTY}
    ${mo_CMD}=    Run Keyword If    ${existed_CMD}    netact.create_managed_object    operation=DELETE    plan=${plan}
    ...    meta_class=${mnl_class}:CMD
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id_CMD']}    &{param_EMPTY}

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Perform Reset NRBTS from Monitor
    [Documentation]    Keyword used to perform all required actions for reset NRBTS from NetAct:
    ...    - select proper NRBTS and perform reset operation
    ...    - check reset NRBTS behavior based on cells state
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${node_path}=    Replace String    ${MRBTS_DN}    /    |
    ${nrbts_id}    Fetch NRBTS ID
    ${node_path}=    Catenate    SEPARATOR=|    ${node_path}    NRBTS-${nrbts_id}
    Log    Waiting for Monitor Application starting    console=True
    NetAct GUI Start Application    alias=Monitor    jnlp_file=${jnlp_location}    window_name=Monitor.*    timeout=600
    Log    Monitor Application started    console=True
    Screenshot.Take Screenshot
    NetAct GUI Go To Tree Node    Objects    ${node_path}
    Log    Perform Reset NRBTS    console=True
    NetAct GUI Perform Tree Node Popup Menu Operation    tree_id=Objects    node_path=${node_path}
    ...    operation=Element Management|State Management|Reset NRBTS    confirmation_dialog=Confirm Operation    confirmation_btn_name=Yes
    Sleep    1s
    Check NR RAT reset
    Screenshot.Take Screenshot
    [Teardown]    Run Keywords    SeleniumLibrary.Close Browser
    ...    AND    NetAct Close Monitor

Check ${rat_techo} RAT reset
    Log    Check ${rat_techo} RAT reset    console=True
    FOR    ${idx}    IN RANGE    60
        sleep    3s
        ${result}    ${rat_status}=    run keyword and ignore error    Check ${rat_techo} RAT status
        ${reset}    run keyword and return status    Should Be Equal As Strings    ${rat_status}    ALL_DISABLED
        exit for loop if    ${reset}
    END
    should be equal as strings    ${reset}    True
    Wait Until Keyword Succeeds    40x    10 sec    coam.Assert Every    NRCEL    operationalState=${_Enabled_}

Check ${rat_techo} RAT status
    ${rat}    String.Convert To Lower Case    ${rat_techo}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    set variable    ${btsinfo_list['ratState']['${rat}']}
    [Return]    ${rat_status}

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_SWRES']}
    ...    ui_values=true    &{param_EMPTY}
    Run Keyword If    ${plan_values}    Run Keywords    Log
    ...    Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Teardown
    Particular Teardown

TC Setup
    Common Test Setup
