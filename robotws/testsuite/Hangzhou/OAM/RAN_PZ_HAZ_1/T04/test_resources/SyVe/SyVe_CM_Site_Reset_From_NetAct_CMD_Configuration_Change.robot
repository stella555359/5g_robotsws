*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
TC__SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19726
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing CMD configuration changes from NetAct to reset SBTS.
    ...    The main steps performed for the test are:
    ...    - Prepare the Plan Infor
    ...    - TC parameters check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Get initial BTS RESET info from blackbox file
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe with parameter_plan_1
    ...    - Create and edit backup Plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe with swResetLevel is sbtsReset
    ...    - Get final BTS RESET info from blackbox file
    ...    - Check BTS RESET 1 times
    ...    - Provision the backup plan without site reset
    ...    - Create and edit plan SyVe with parameter_plan_2
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe with swResetLevel is resetToTestLevel
    ...    - Get final BTS RESET info from blackbox file
    ...    - Check BTS RESET 2 times
    ...    - Provision the backup plan with site reset
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export and provision operation works as expected; site rat reset as expected;
    ...    states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 06.18.2020 - https://jira3.int.net.nokia.com/browse/TAT-19726 - SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    ...    - 03.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking. Update keywords to remove infomodel
    ...    - 20.01.2022 - Modified by Xu Yuyan  - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      fix: Get Plan -> Get Plan Configuration
    ...    - 23.03.2023 - Modified by YuaGao:Discard using netact_plan.yaml
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
	...    TAT-19726_SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Prepare the Plan Infor
    Step 2: TC parameters check
    Step 3: Check initial BTS state
    Step 4: Check initial alarms status from WebEM
    Step 5: Check initial alarms status from Netact
    Step 6: Get initial BTS RESET info from blackbox file
    Step 7: Upload configuration status
    Step 8: Create and edit plan SyVe with parameter_plan_1
    Step 9: Create and edit backup Plan SyVe
    Step 10: Export the plan SyVe
    Step 11: Provision the plan SyVe with swResetLevel is sbtsReset
    Step 12: Get final BTS RESET info from blackbox file
    Step 13: Check BTS RESET 1 times
    Step 14: Provision the backup plan without site reset
    Step 15: Create and edit plan SyVe with parameter_plan_2
    Step 16: Export the plan SyVe
    Step 17: Provision the plan SyVe with swResetLevel is resetToTestLevel
    Step 18: Get final BTS RESET info from blackbox file
    Step 19: Check BTS RESET 2 times
    Step 20: Provision the backup plan with site reset
    Step 21: Check final alarms status from WebEM
    Step 22: Check final alarms status from Netact
    Step 23: Check final BTS state
    Step 24: Check final number and state of Cells and RMs

Step ${index}: Prepare the Plan Infor
    Log    Step ${index}: Prepare the Plan Infor    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    &{dic_parameter_plan_1}    Create Dictionary    swResetLevel=0
    &{dic_parameter_display_1}    Create Dictionary    swResetLevel=btsReset
    &{dic_parameter_plan_2}    Create Dictionary    swResetLevel=4
    &{plan_info}    Create Dictionary    scf_distName=MRBTS-${mrbts_id}/MNL-1    mo_id_CMD=${MRBTS_DN}/MNL-1/CMD-1
    ...    mo_id_SWRES=${MRBTS_DN}/MNL-1/CMD-1/SWRESETREQ-1    parameter_plan_1=${dic_parameter_plan_1}
    ...    parameter_display_1=${dic_parameter_display_1}    parameter_plan_2=${dic_parameter_plan_2}
    Set Test Variable    ${plan_info}
    Log Dictionary    ${plan_info}

Step ${index}: TC parameters check
    Log    Step ${index}: TC parameters check    console=True
    &{param_EMPTY}    Create Dictionary
    Set Test Variable    &{param_EMPTY}
    ${existed_CMD}=    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_CMD']}
    ...    &{param_EMPTY}
    ${existed_SWRES}=    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_SWRES']}
    ...    &{plan_info['parameter_display_1']}
    Set Test Variable    ${existed_CMD}
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
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe with ${parameter_name}
    Log    Step ${index}: Create and edit plan SyVe with ${parameter_name}    console=True
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
    Run Keyword If    not ${existed_CMD}    netact.Create Managed Object    operation=CREATE    plan=${plan}    meta_class=${mnl_class}:CMD
    ...    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    NetAct Create Managed Object    plan=${plan}    meta_class=${mnl_class}:SWRESETREQ    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_SWRES']}    &{plan_info['${parameter_name}']}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe with swResetLevel is sbtsReset
    Log    Step ${index}: Provision the plan SyVe with swResetLevel is sbtsReset    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Wait Until Keyword Succeeds    3min    5s    Check SWRESETRES Result

Step ${index}: Create and edit backup Plan SyVe
    Log    Step ${index}: Create and edit backup Plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name_bu}    MRBTS-${mrbts_id}_${timestamp}_Backup
    ${status}    ${plan_bu}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name_bu}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name_bu}    ${plan_bu}
    ${plan_bu}=    NetAct Create Plan    name=${name_bu}    description=Automation SyVe BackUp for MRBTS-${mrbts_id}
    ${mo_SWRES}=    netact.Create Managed Object    operation=DELETE    plan=${plan_bu}    meta_class=${mnl_class}:SWRESETREQ
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id_SWRES']}
    ...    &{param_EMPTY}
    ${mo_CMD}=    Run Keyword If    not ${existed_CMD}    netact.Create Managed Object    operation=DELETE    plan=${plan_bu}
    ...    meta_class=${mnl_class}:CMD    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    ${status}=    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan_bu}    mo_id=${plan_info['mo_id_SWRES']}
    Run Keyword If    ${status}    Run Keywords    Log    MO successfully created: ${mo_SWRES}    console=True
    ...    AND    Log    Parameters were set with plan ${plan_bu}    console=True
    ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
    ...    AND    Fail    MO creation failed!

Step ${index}: Provision the backup plan ${with} site reset
    Log    Step ${index}: Provision the backup plan ${with} site reset    console=True
    Run Keyword If    '${with}'=='with'    coam.Reset_Site    timeout=300
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_bu}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name_bu}    operation_type=plan
    NetAct Provision Plan    plan_name=${name_bu}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Wait Until Keyword Succeeds    5min    30s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Check BTS RESET ${count} times
    Log    Step ${index}: Check BTS RESET ${count} times    console=True
    Check BTS RESET behavior SyVe    ${count}

Step ${index}: Get ${when} BTS RESET info from blackbox file
    Log    Step ${index}: Get ${when} BTS RESET info from blackbox file    console=True
    Get BTS RESET info from blackbox file SyVe    when=${when}    target_ip=${SMOD1['TRS_IP']}

Step ${index}: Provision the plan SyVe with swResetLevel is resetToTestLevel
    Log    Step ${index}: Provision the plan SyVe with swResetLevel is resetToTestLevel    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    20s    Check BTS In Test Mode
    Wait Until Keyword Succeeds    15min    60s    Check SMOD and RMOD status should be OK
    Wait Until Keyword Succeeds    2min     10s    Check Cells Should Be Offline
    Wait Until Keyword Succeeds    3min     10s    Check SWRESETRES Result
    Admin Check Active Alarms TAF

Check BTS In Test Mode
    ${dic_btsInfo}    coam.Get BTS info
    ${dic_status}    Pop From Dictionary    ${dic_btsInfo}    status
    ${operationalState}     Get From Dictionary    ${dic_status}     operationalState
    ${proceduralState}    Get From Dictionary    ${dic_status}    proceduralState
    Should Be True    '${operationalState}'=='${_Com_Disabled_}'
    Should Be True    '${proceduralState}'=='${_Com_Test_}'

Check SWRESETRES Result
    ${tmp_str}    Fetch From Left     ${plan_info['mo_id_SWRES']}    /
    ${SWRESETRES_DN}    Fetch From Right    ${plan_info['mo_id_SWRES']}    ${tmp_str}/
    ${BTS_scf_content}=    coam.Get SCF    export_type=configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_content}
    ${SWRESETRES_Result}=    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${SWRESETRES_DN}/SWRESETRES-1"]/p[@name="swResetResult"]
    Should Be Equal As Strings    success    ${SWRESETRES_Result}

Check SMOD and RMOD status should be OK
    LOG    Check SMOD and RMOD status should be OK    console=${True}
    ${are_smods_online}    Check If All Objects Are Online    SMOD    10 sec
    ${are_rmods_online}    Check If All Objects Are Online    RMOD    10 sec
    Should Be True   "${are_smods_online}"=="PASS" and "${are_rmods_online}"=="PASS"    Not all conditions were satisfied!

Check Cells Should Be Offline
    ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
    ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
    ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
    ${nrcell}    Run Keyword And Return Status    coam.Assert Any    NRCEL
    ${gncell_offline}     Run Keyword If    ${gncell}    Run Keyword And Return Status    coam.Assert Every    GNCEL    ${cells_GSM_offline_state}
    ${wncell_offline}     Run Keyword If    ${wncell}    Run Keyword And Return Status    coam.Assert Every    WNCEL    ${cells_WCDMA_offline_state}
    ${lncell_offline}     Run Keyword If    ${lncell}    Run Keyword And Return Status    coam.Assert Every    LNCEL    ${cells_LTE_offline_state}
    ${nrcell_offline}     Run Keyword If    ${nrcell}    Run Keyword And Return Status    coam.Assert Every    NRCEL    ${cells_NR_offline_state}
    Run Keyword If    ${gncell}    Should Be True    ${gncell_offline}
    Run Keyword If    ${wncell}    Should Be True    ${wncell_offline}
    Run Keyword If    ${lncell}    Should Be True    ${lncell_offline}
    Run Keyword If    ${nrcell}    Should Be True    ${nrcell_offline}

Particular Teardown
    Log    Particular Teardown    console=True
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_SWRES']}
    ...    &{param_EMPTY}
    Run Keyword If    ${plan_values}    Run Keywords    Log
    ...    Parameters were not reset to initial values! Probably backup plan was not provisioned! Will do it again
    ...    level=WARN
    ...    AND    Step teardown: Provision the backup plan with site reset
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_bu}
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown