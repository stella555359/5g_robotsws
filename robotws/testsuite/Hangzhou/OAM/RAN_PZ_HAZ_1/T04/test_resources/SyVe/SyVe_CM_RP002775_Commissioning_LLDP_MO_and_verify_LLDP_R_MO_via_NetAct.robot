*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-20124
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing ETHAPP configuration changes from NetAct to reset RMOD.
    ...    The main steps performed for the test are:
    ...    - Prepare the Plan Infor
    ...    - TC parameters check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check LLDP_R MO generate
    ...    - Create and edit backup plan SyVe
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export and provision operation works as expected; LLDP and LLDP_R added as expected;
    ...    states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 25.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-20124 SyVe_CM_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct_RP002775
    ...    - 02.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      fix: Get Plan -> Get Plan Configuration
    ...    29.03.2022 - Modified by YuaGao:Discard using netact_plan.yaml
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-20124_SyVe_CM_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct_RP002775.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Prepare the Plan Infor
    Step 2: TC parameters check
    Step 3: Check initial BTS state
    Step 4: Check initial alarms status from WebEM
    Step 5: Check initial alarms status from Netact
    Step 6: Upload configuration status
    Step 7: Create and edit plan SyVe
    Step 8: Export the plan SyVe
    Step 9: Provision the plan SyVe
    Step 10: Check LLDP_R MO generate
    Step 11: Create and edit backup Plan SyVe
    Step 12: Provision the backup plan
    Step 13: Check final alarms status from WebEM
    Step 14: Check final alarms status from Netact
    Step 15: Check final BTS state
    Step 16: Check final number and state of Cells and RMs

Step ${index}: Prepare the Plan Infor
    Log    Step ${index}: Prepare the Plan Infor    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    &{dic_parameter_ETHAPP}    Create Dictionary    optionalTlvReplyEnabled=0    remoteMepMacAutoLearningEnabled=0
    ...    serviceOamEnabled=0
    &{dic_parameter_LLDP}    Create Dictionary    ethlkDN=MRBTS-${mrbts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1
    &{plan_info}    Create Dictionary    scf_distName=MRBTS-${mrbts_id}/TNLSVC-1/TNL-1
    ...    mo_id_ETHAPP=${MRBTS_DN}/TNLSVC-1/TNL-1/ETHAPP-1    parameter_ETHAPP=${dic_parameter_ETHAPP}
    ...    mo_id_LLDP=${MRBTS_DN}/TNLSVC-1/TNL-1/ETHAPP-1/LLDP-1    parameter_LLDP=${dic_parameter_LLDP}
    ...    mo_id_LLDP_R=${MRBTS_DN}/TNLSVC-1/TNL-1/ETHAPP-1/LLDP-1/LLDP_R-1
    Set Test Variable    ${plan_info}
    Log Dictionary    ${plan_info}

Step ${index}: TC parameters check
    Log    Step ${index}:TC parameters check started    console=True
    &{plan_info['parameter_ETHAPP']}    Create Dictionary
    ${existed_ETHAPP}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_ETHAPP']}
    ...    &{plan_info['parameter_ETHAPP']}
    ${existed_LLDP}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_LLDP']}
    ...    &{plan_info['parameter_LLDP']}
    Set Test Variable    ${existed_ETHAPP}
    Set Test Variable    ${existed_LLDP}
    Run Keyword If    ${existed_LLDP}    Log    TC parameters check failed: Object LLDP should not be existed!    level=ERROR
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${existed_LLDP}

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

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    Log    Step ${index}: Create and edit plan SyVe    console=True
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
    Run Keyword If    not ${existed_ETHAPP}    netact.create_managed_object    operation=CREATE    plan=${plan}    meta_class=${mnl_class}:ETHAPP
    ...    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_ETHAPP']}    &{plan_info['parameter_ETHAPP']}
    NetAct Create Managed Object    plan=${plan}    meta_class=${mnl_class}:LLDP    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_LLDP']}    &{plan_info['parameter_LLDP']}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}    plan_name=${name}
    ...    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...   provisioning_operation=activate

Step ${index}: Check LLDP_R MO generate
    [Documentation]    Check LLDP_R MO generate.
    Log    Step ${index}: Check LLDP_R MO generate    console=True
    Wait Until Keyword Succeeds    1 min    3 sec    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_LLDP']}
    ...    &{plan_info['parameter_LLDP']}
    &{param_EMPTY}    Create Dictionary
    Wait Until Keyword Succeeds    3 min    3 sec    Check Actual Configuration Parameters   dist_name=${plan_info['mo_id_LLDP_R']}   &{param_EMPTY}

Step ${index}: Create and edit backup Plan SyVe
    Log    Step ${index}: Create and edit backup Plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name_bu}    MRBTS-${mrbts_id}_${timestamp}_Backup
    ${status}    ${plan_bu}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name_bu}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name_bu}    ${plan_bu}
    ${plan_bu}=    NetAct Create Plan    name=${name_bu}    description=Automation SyVe BackUp for MRBTS-${mrbts_id}
    ${mo_LLDP}=    netact.create_managed_object    operation=DELETE    plan=${plan_bu}
    ...    meta_class=${mnl_class}:LLDP
    ...    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_LLDP']}
    ...    &{plan_info['parameter_LLDP']}
    ${mo_ETHAPP}=    Run Keyword If    not ${existed_ETHAPP}    netact.create_managed_object    operation=DELETE    plan=${plan_bu}
    ...    meta_class=${mnl_class}:ETHAPP
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id_ETHAPP']}    &{plan_info['parameter_ETHAPP']}
    ${status}=    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan_bu}    mo_id=${plan_info['mo_id_LLDP']}
    Run Keyword If    ${status}    Run Keywords    Log    MO successfully deleted: ${mo_LLDP}    console=True
    ...    AND    Log    Parameters were set with plan ${plan_bu}    console=True
    ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
    ...    AND    Fail    MO creation failed!

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_bu}.csv    dist_names=${MRBTS_DN}    plan_name=${name_bu}
    ...    operation_type=plan
    NetAct Provision Plan    plan_name=${name_bu}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_bu}
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_LLDP']}
    ...    &{plan_info['parameter_LLDP']}
    Run Keyword If    ${plan_values} and not ${existed_LLDP}    Run Keywords    Log
    ...    Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
