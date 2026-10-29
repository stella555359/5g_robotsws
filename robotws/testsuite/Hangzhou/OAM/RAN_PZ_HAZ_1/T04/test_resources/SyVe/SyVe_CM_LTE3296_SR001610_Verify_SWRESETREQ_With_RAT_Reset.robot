*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${NEED_TO_CHECK_5G_RAT_STATUS}    False
${NEED_TO_CHECK_LTE_RAT_STATUS}    True

*** Keywords ***
SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19721
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing CMD configuration changes from NetAct to reset GSM/WCDMA/LTE/NR rat.
    ...    based on selected PLAN_x
    ...    The main steps performed for the test are:
    ...    - Random Select SwResetLevel
    ...    - TC parameters check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check Reset RAT Behavior
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export and provision operation works as expected; Selected rat reset as expected;
    ...    states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.31.2020 - https://jira3.int.net.nokia.com/browse/TAT-19721 - SyVe_CM_Verify_SWRESETREQ_With_RAT_Reset_LTE3296_SR001610
    ...    - 26.02.2021 - https://jira3.int.net.nokia.com/browse/TAT-20958 - SyVe_CM_Verify_SWRESETREQ_With_RAT_Reset_LTE3296_SR001610
    ...    - 05.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking
    ...    - 20.01.2022 - Modified by Xu Yuyan  - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...     Add logic to remove RAT type which is not in SBTS config from resetting option list
    ...     Fix: Get Plan ->netact.Get Plan Configuration
    ...    - 16.11.2023 - Modified by Kang Lixin - add plan_info as test parameter not from file
    ...     Add new reset type due to CB008880: lteHardReset, gnbhardReset
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-19721_SyVe_CM_Verify_SWRESETREQ_With_RAT_Reset_LTE3296_SR001610.png
    Set Tags    AUTHOR-yiqing.yu@nokia-sbell.com    Maintainer–I_NSB_MN_SRAN_PROD_HZH_OPER1_VRF@internal.nsn.com
    Step 0: Prepare the Plan Info
    Step 1: Random Select SwResetLevel
    Step 2: TC parameters check
    Step 3: Check initial BTS state
    Step 4: Check initial alarms status from WebEM
    Step 5: Check initial alarms status from Netact
    Step 6: Upload configuration status
    Step 7: Create and edit plan SyVe
    Step 8: Export the plan SyVe
    Step 9: Get initial BTS RESET info from blackbox file
    Step 10: Provision the plan SyVe
    Step 11: Check Reset RAT Behavior
    Step 12: Provision the backup plan
    Step 13: Get final BTS RESET info from blackbox file
    Step 14: Check BTS RESET behavior
    Step 15: Check final alarms status from WebEM
    Step 16: Check final alarms status from Netact
    Step 17: Check final BTS state
    Step 18: Check final number and state of Cells and RMs

Step ${index}: Prepare the Plan Info
    Log    Step ${index}: Prepare the Plan Infor    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    &{plan_info}    Create Dictionary    scf_distName=MRBTS-${mrbts_id}/MNL-1    mo_id_CMD=${MRBTS_DN}/MNL-1/CMD-1
    ...    mo_id_SWRES=${MRBTS_DN}/MNL-1/CMD-1/SWRESETREQ-1
    Set Test Variable    ${plan_info}

Step ${index}: Random Select SwResetLevel
    [Documentation]    Step ${index}: Random Select SwResetLevel
    Log    Step ${index}: Random Select SwResetLevel    console=True
    @{techno_list}    Create List    GSM    WCDMA    LTE    GNB
    Run Keyword If    len(${NRBTS_cell_ids})==0    Remove Values From List    ${techno_list}    GNB
    Run Keyword If    len(${LTE_cell_ids})==0   Remove Values From List    ${techno_list}   LTE
    Run Keyword If    len(${WCDMA_cell_ids})==0    Remove Values From List    ${techno_list}    WCDMA
    Run Keyword If    len(${GSM_cell_ids})==0    Remove Values From List    ${techno_list}    GSM
    ${count}    Get Length   ${techno_list}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${techno}    Set Variable    ${techno_list[${index}]}
    Set Test Variable   ${techno}
    Remove Values From List    ${techno_list}    ${techno}
    Set Test Variable    ${techno_list}
    &{Para_dic}    Create Dictionary   gsmReset=2    wcdmaReset=3    lteReset=1   gnbReset=5    lteHardReset=9    gnbHardReset=10
    Run Keyword If    len(${NRBTS_cell_ids})==0     Remove From Dictionary    ${Para_dic}     gnbReset    gnbHardReset
    Run Keyword If     len(${LTE_cell_ids})==0     Remove From Dictionary    ${Para_dic}    lteReset    lteHardReset
    Run Keyword If    len(${WCDMA_cell_ids})==0     Remove From Dictionary    ${Para_dic}    wcdmaReset
    Run Keyword If    len(${GSM_cell_ids})==0     Remove From Dictionary    ${Para_dic}    gsmReset
    ${lte_type_list}    Create List    lteReset    lteHardReset
    ${gnb_type_list}    Create List    gnbReset    gnbHardReset
    ${lte_type}    Evaluate    random.choice(${lte_type_list})    modules=random, sys
    ${gnb_type}    Evaluate    random.choice(${gnb_type_list})    modules=random, sys
    ${techno_lower}    String.Convert To Lower Case    ${techno}
    ${SwResetLevel_act}    Set Variable If    '${techno}'=='LTE'    ${lte_type}
    ...    '${techno}'=='GNB'    ${gnb_type}
    ...     ${techno_lower}Reset
    ${swResetLevel_set}    Get From Dictionary    ${Para_dic}    ${SwResetLevel_act}
    &{swResetLevel_set_dic}    Create Dictionary    swResetLevel=${swResetLevel_set}
    Set Test Variable    &{swResetLevel_set_dic}
    &{swResetLevel_act_dic}    Create Dictionary    swResetLevel=${swResetLevel_act}
    Set Test Variable    &{swResetLevel_act_dic}

Step ${index}: TC parameters check
    Log    Step ${index}: TC parameters check started    console=True
    &{param_EMPTY}    Create Dictionary
    Set Test Variable    &{param_EMPTY}
    ${existed_CMD}   Run Keyword And Return Status   Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_CMD']}   &{param_EMPTY}
    ${existed_SWRES}   Run Keyword And Return Status   Check Actual Configuration Parameters   dist_name=${plan_info['mo_id_SWRES']}   &{param_EMPTY}
    Set Test Variable    ${existed_CMD}
    Set Test Variable    ${existed_SWRES}
    Run Keyword If    ${existed_SWRES}    Log    TC parameters check failed: Object SWRESETREQ should not be existed!    level=ERROR
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${existed_SWRES}

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
    Wait Until Keyword Succeeds    10x    60 sec    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}
    ...    ignored_alarms=${IGNORED_ALARMS}    unexpected_alarms=@{UNEXPECTED_ALARMS}     critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${status}    ${plan}=    Run Keyword And Ignore Error   netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info['scf_distName']}"]
    ${mnl_class}    Fetch From Left    ${MO_items['class']}    :
    Set Test Variable    ${MO_items}
    Set Test Variable    ${mnl_class}
    Run Keyword If    not ${existed_CMD}     netact.Create Managed Object    operation=CREATE    plan=${plan}    meta_class=${mnl_class}:CMD
    ...    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    NetAct Create Managed Object    plan=${plan}    meta_class=${mnl_class}:SWRESETREQ    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_SWRES']}    operation=CREATE     &{swResetLevel_set_dic}
    Set Test Variable    ${mrbts_id}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name_bu}    MRBTS-${mrbts_id}_${timestamp}_Backup
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name_bu}    create_backup_plan=True
    ...    provisioning_operation=activate

Step ${index}: Check Reset RAT Behavior
    Log    Step ${index}: Check ${techno} rat reset   console=True
    FOR    ${idx}    IN RANGE    180
        sleep  3s
        ${result}   ${rat_status}=    run keyword and ignore error  Check ${techno} RAT status
        Check Other RAT Status Enabled
        ${reset}   run keyword and return status  Should Be Equal As Strings   ${rat_status}    ALL_DISABLED
        exit for loop if   ${reset}
    END
    Should Be Equal As Strings    ${reset}    True
    FOR    ${idx}    IN RANGE    180
        ${cells_Status}     Run Keyword If    '${techno}'=='GNB'
        ...     Run Keyword And Return Status    coam.Assert Every    NRCEL    operationalState=${_Enabled_}
        ...     ELSE    Run Keyword And Return Status    coam.Assert Every    ${techno[0]}NCEL    operationalState=${_Enabled_}
        Check Other RAT Status Enabled
        Exit For Loop If    ${cells_Status}
    END
    Wait Until Keyword Succeeds    6x    10 sec    Check SWRESETRES result

Check Other RAT Status Enabled
    FOR    ${te}    IN    @{techno_list}
        Continue For Loop If    '${techno}'=='GNB' and '${te}'=='LTE' and '${NEED_TO_CHECK_LTE_RAT_STATUS}'=='False'
        Continue For Loop If    '${techno}'=='LTE' and '${te}'=='GNB' and '${NEED_TO_CHECK_5G_RAT_STATUS}'=='False'
        ${state}    Check ${te} RAT status
        Should Be Equal As Strings    ${state}    ALL_ENABLED
    END

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_bu}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name_bu}    operation_type=plan
    NetAct Provision Plan    plan_name=${name_bu}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Check ${techno} RAT status
    ${rat_techno}    run keyword if  '${techno}'=='GNB'  set variable   NR
    ...     ELSE     set variable   ${techno}
    ${rat}    String.Convert To Lower Case    ${rat_techno}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    set variable    ${btsinfo_list['ratState']['${rat}']}
    [Return]    ${rat_status}

Check SWRESETRES result
    ${BTS_scf_SWRESETRES}=  coam.get scf    export_type=configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_SWRESETRES}
    ${swResetResult}=    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${plan_info['scf_distName']}/CMD-1/SWRESETREQ-1/SWRESETRES-1"]/p[@name="swResetResult"]
    should be equal as strings  success   ${swResetResult}

Step ${index}: Get ${when} BTS RESET info from blackbox file
    [Documentation]    Get RESET info from blackbox file
    [Timeout]    15 min
    Log    Step ${index}: Get ${when} BTS RESET info from blackbox file    console=True
    Get BTS RESET info from blackbox file SyVe    when=${when}    target_ip=${SMOD1['TRS_IP']}

Step ${index}: Check BTS RESET behavior
    [Documentation]    Final RESET info is compared with initial RESET info: reset number is 0
    [Timeout]    10 min
    Log    Step ${index}: Check BTS RESET behavior    console=True
    Check BTS RESET behavior SyVe    0

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_bu}
    ${plan_values}    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_SWRES']}
    ...    ui_values=true    &{swResetLevel_act_dic}
    Run Keyword If    ${plan_values} and not ${existed_SWRES}    Run Keywords    Log
    ...    Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown

