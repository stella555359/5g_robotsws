*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-20851
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Automated testcase for Lock/Unlock RMOD performed from NetAct.
    ...    The main steps performed for the test are:
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Random Select RMOD
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check RMOD locked
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Provision the backup plan
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 10.02.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20851 - new case
    ...    - 02.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking and add step 13
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      fix: Get Plan -> netact.Get Plan Configuration
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/
    ...    SYVE/TAT-20851_SyVe_CM_Verify_Radio_Lock_Via_NetAct_RP002956.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Random Select RMOD
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Provision the plan SyVe
    Step 9: Check RMOD locked
    Step 10: Check final alarms status from WebEM
    Step 11: Check final alarms status from Netact
    Step 12: Provision the backup plan
    Step 13: Check final BTS state
    Step 14: Check final number and state of Cells and RMs

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
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Random Select RMOD
    Log    Step ${index}: Random Select RMOD    console=True
    ${DIC_RMOD_ACTIVE_CELL}    Get RMODs Active Cell List_case
    ${RMODs}    Get Dictionary Keys    ${DIC_RMOD_ACTIVE_CELL}
    ${count}    Get Length    ${RMODs}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    Set Test Variable    ${RMOD_TO_LOCK}    ${RMODs[${index}]}
    Set Test Variable    ${DIC_RMOD_ACTIVE_CELL}
    &{para}    create dictionary    administrativeState=0
    Set Test Variable    &{para_dic}    &{para}
    &{para_display}    create dictionary    administrativeState=Locked
    Set Test Variable    &{para_display_dic}    &{para_display}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${RMOD_TO_LOCK}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...     mo_id=PLMN-PLMN/${RMOD_TO_LOCK}    &{para_dic}
    Set Test Variable    ${mrbts_id}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate

Step ${index}: Check RMOD locked
    Log    Step ${index}: Check RMOD locked    console=True
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${RMOD_TO_LOCK}    ui_values=true    &{para_display_dic}
    should be true    ${plan_values}
    ${dic_RMOD_active_cell_after_lock}    Get RMODs Active Cell List_case
    ${RMOD_locked_active_cell_list}    Pop From Dictionary    ${dic_RMOD_active_cell_after_lock}    ${RMOD_TO_LOCK}
    Should Be Empty    ${RMOD_locked_active_cell_list['activeLteCellsList']}
    Should Be Empty    ${RMOD_locked_active_cell_list['activeGsmCellsList']}
    Should Be Empty    ${RMOD_locked_active_cell_list['activeNrCellsList']}
    Should Be Empty    ${RMOD_locked_active_cell_list['activeWcdmaCellsList']}
    ${rest_RMODs}    Get Dictionary Keys    ${dic_RMOD_active_cell_after_lock}
    FOR    ${RMOD}    IN    @{rest_RMODs}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeLteCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeLteCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeGsmCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeGsmCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeNrCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeNrCellsList']}
        Lists Should Be Equal    ${dic_RMOD_active_cell_after_lock['${RMOD}']['activeWcdmaCellsList']}
        ...    ${DIC_RMOD_ACTIVE_CELL['${RMOD}']['activeWcdmaCellsList']}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Get RMODs Active Cell List_case
    ${dic_RMOD_active_cell}    Create Dictionary
    ${RMOD_R_list}    ute_admin_infomodel.query_infomodel    get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR    ${MO}    IN    @{RMOD_R_list}
        ${DN}    Set Variable    ${MO['dist_name']}
        ${RMOD_DN}    Infomodel Get Objects Parameter    ${DN}    configDN    ${True}
        ${count}    Get Length    ${RMOD_DN}
        Should Be True    ${count}==${1}
        ${tmp_dic}    Create Dictionary    activeLteCellsList=${MO['activeLteCellsList']}
        ...    activeGsmCellsList=${MO['activeGsmCellsList']}    activeNrCellsList=${MO['activeNrCellsList']}
        ...    activeWcdmaCellsList=${MO['activeWcdmaCellsList']}
        ${tmp_str_list}    Split String    ${RMOD_DN[0]}    MRBTS_A-
        ${MO_name}    Set Variable    MRBTS-${tmp_str_list[1].replace("_A","")}
        Set To Dictionary    ${dic_RMOD_active_cell}    ${MO_name}    ${tmp_dic}
    END
    [Return]    ${dic_RMOD_active_cell}

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${RMOD_TO_LOCK}    ui_values=true    &{para_display_dic}
    Run Keyword If    ${plan_values}    Run Keywords
    ...    Log    Parameters were not reset to initial values! Probably backup plan was not provisioned!    level=WARN
    ...    AND    Log    Will perform commissioning with initial scf!    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
