*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
&{new_add_obj_params}    localIpAddr=2a00:8a00:8000:134:104:68:141:97    localIpPrefixLength=120    ipAddressAllocationMethod=0
&{add_param_plan_info}    scf_distName=MRBTS-1894/MNL-1/MNLENT-1/MPLANENW-1    mo_id=PLMN-PLMN/MRBTS-1894/MNL-1/MNLENT-1/MPLANENW-1
...    parameter_name=mPlaneIpv6AddressDN    shortenedDN=TNL-1/IPNO-1/IPIF-5/IPADDRESSV6-1    incorrect_shortenedDN=IPADDRESSV6-1
&{add_obj_plan_info}      scf_distName=MRBTS-1894/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV6-1
...    mo_id=PLMN-PLMN/MRBTS-1894/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV6-1    parent_obj=MRBTS-1894/TNLSVC-1/TNL-1
...    obj_class=com.nokia.srbts.tnl:IPADDRESSV6    parameter_dic=&{new_add_obj_params}
&{precondtion_obj_params}    actDualStackIpV4V6ForMplane=true
&{precondtion_obj_plan_info}    scf_distName=MRBTS-1894/MNL-1/MNLENT-1/FEATCADM-1    mo_id=PLMN-PLMN/MRBTS-1894/MNL-1/MNLENT-1/FEATCADM-1
...    parameter_name=actDualStackIpV4V6ForMplane    parameter_dic=&{precondtion_obj_params}

*** Keywords ***
SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing testing for
    ...    VRAN_SyVe_CB008660-A_004_CM_Adding an object breaking (or not) existing distname unambiguity to the live NE
    ...    based on random select parameter in json file
    ...    The main steps performed for the test are:
    ...    - TC Parameter Check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Create Plan With New Object Not Breaking Existing Distname-Type Parameter Unambiguity
    ...    - Provision Plan And Check Behavior
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Create Plan With New Object Breaking Existing Distname-Type Parameter Unambiguity
    ...    - Provision Plan And Check Feedback
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 18.01.2023 New case
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: TC Parameter Check
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Create Plan With New Object Breaking Existing Distname-Type Parameter Unambiguity
    Step 6: Provision Plan And Check Feedback
    Step 7: Create Plan With New Object Not Breaking Existing Distname-Type Parameter Unambiguity
    Step 8: Provision Plan And Check Behavior
    Step 9: Check modified parameter in Netact after provision plan
    Step 10: Check modified parameter in Admin after provision plan
    Step 11: Provision the backup plan
    Step 12: Check final alarms status from WebEM
    Step 13: Check final alarms status from Netact
    Step 14: Check final BTS state
    Step 15: Check final number and state of Cells and RMs

Step ${index}: TC Parameter Check
    Log    Step ${index}: TC Parameter Check    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${plan_info}    ${add_param_plan_info}
    ${PARAM_DIC}    Create Dictionary    ${plan_info['parameter_name']}=${plan_info['shortenedDN']}
    ${INCORRECT_PARAM_DIC}    Create Dictionary    ${plan_info['parameter_name']}=${plan_info['incorrect_shortenedDN']}
    ${tmp_str1}    Set Variable    Distname parameter '${plan_info['parameter_name']}' value '${plan_info['incorrect_shortenedDN']}' is invalid
    ${tmp_str2}    Set Variable    because the shortened distinguished names pointing to objects under TNL object model tree
    ${error_message}    Set Variable    ${tmp_str1} ${tmp_str2} must start at least from TNL and cannot be shortened further
    Set Test Variable    ${PARAM_DIC}
    Set Test Variable    ${INCORRECT_PARAM_DIC}
    Set Test Variable    ${error_message}
    NetAct CM Upload    dist_names=${MRBTS_DN}
    &{param_EMPTY}    Create Dictionary
    Set Test Variable    &{param_EMPTY}
    ${existed_notbreaking_obj}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${add_obj_plan_info['mo_id']}    &{param_EMPTY}
    Set Test Variable    ${existed_notbreaking_obj}
    Check Selected Parameter Is Not Exist
    ${status}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${precondtion_obj_plan_info['mo_id']}    ui_values=true    &{precondtion_obj_plan_info['parameter_dic']}
    Run Keyword If    not ${status}    Recovery Parameter Value   ${precondtion_obj_plan_info['mo_id']}
    ...    ${precondtion_obj_plan_info['scf_distName']}    &{precondtion_obj_plan_info['parameter_dic']}

Check Selected Parameter Is Not Exist
    ${status}    Run Keyword And Return Status    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=check_netact_plan.xml    dist_names=${MRBTS_DN}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml_content}    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/check_netact_plan.xml
    ${status}    ${msg}    Run Keyword And Ignore Error     L_XML.Get Element Text    ${xml_content}
    ...    .//managedObject[@distName="${plan_info['mo_id']}"]/p[@name="${plan_info['parameter_name']}"]
    ${msg_asexpected}    Run Keyword And Return Status
    ...    Should Contain    ${msg}
    ...    No element matching './/managedObject[@distName="${plan_info['mo_id']}"]/p[@name="${plan_info['parameter_name']}"]' found
    Run Keyword If    '${status}'=='FAIL' and ${msg_asexpected}    Log    TC parameters successfully checked    console=True
    ...    ELSE    Run Keywords
    ...    Log    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    AND    Recovery Parameter Value   ${plan_info['mo_id']}    ${plan_info['scf_distName']}   ${plan_info['parameter_name']}=${EMPTY}

Recovery Parameter Value
    [Arguments]     ${mo_id}    ${scf_dn}    &{param_dic}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    precondition_MRBTS-${mrbts_id}_${timestamp}
    NetAct Create And Edit Plan    name=precondition_MRBTS-${mrbts_id}_${timestamp}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${mo_id}   scf_distName=${scf_dn}   &{param_dic}
    NetAct Provision Plan    plan_name=precondition_MRBTS-${mrbts_id}_${timestamp}    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

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

Step ${index}: Check modified parameter in Netact after provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Netact after provision ${plan_type}    console=True
    Wait Until Keyword Succeeds    3 min    15 sec    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}   &{PARAM_DIC}

Step ${index}: Check modified parameter in Admin after provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Admin after provision ${plan_type}    console=True
    Check WebEM After Modify Parameters    ${plan_info['scf_distName']}     &{PARAM_DIC}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${plan_name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${plan_name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${plan_name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Run Keyword If    not ${existed_notbreaking_obj}    Run Keywords
    ...    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${dummy_mo_plan_name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${dummy_mo_plan_name}_backup    operation_type=plan
    ...    AND    NetAct Provision Plan    plan_name=${dummy_mo_plan_name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Create Plan With New Object Not Breaking Existing Distname-Type Parameter Unambiguity
    Log    Step ${index}: Create Plan With New Object Not Breaking Existing Distname-Type Parameter Unambiguity    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${plan_name}    MRBTS-${mrbts_id}_${timestamp}
    NetAct Create And Edit Plan    ${plan_name}     Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${plan_info['mo_id']}    scf_distName=${plan_info['scf_distName']}    &{PARAM_DIC}

Create Dummy Not Breaking MO
    ${plan}    NetAct Create Plan     ${dummy_mo_plan_name}   Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    Set Test Variable    ${scf_xml}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${add_obj_plan_info['parent_obj']}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${add_obj_plan_info['obj_class']}
    ...    meta_version=${MO_items['version']}    mo_id=${add_obj_plan_info['mo_id']}    operation=CREATE    &{add_obj_plan_info['parameter_dic']}
    NetAct Provision Plan    plan_name=${dummy_mo_plan_name}    dist_names=${MRBTS_DN}    backup_plan_name=${dummy_mo_plan_name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate

Step ${index}: Create Plan With New Object Breaking Existing Distname-Type Parameter Unambiguity
    Log    Step ${index}: Create Plan With New Object Breaking Existing Distname-Type Parameter Unambiguity    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${incorret_plan_name}    MRBTS-${mrbts_id}_${timestamp}
    Run Keyword If    not ${existed_notbreaking_obj}    Run Keywords
    ...    Set Test Variable    ${dummy_mo_plan_name}    MRBTS-${mrbts_id}_createmo_${timestamp}
    ...    AND    Create Dummy Not Breaking MO
    NetAct Create And Edit Plan    ${incorret_plan_name}     Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${plan_info['mo_id']}    scf_distName=${plan_info['scf_distName']}    &{INCORRECT_PARAM_DIC}

Step ${index}: Provision Plan And Check Behavior
    Log    Step ${index}: Provision Plan And Check Behavior    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN ${MRBTS_DN}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${plan_name}_backup -v
    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    Set Test Variable     ${plan_backup_name}    ${plan_name}_backup
    SSHLibrary.Start Command     ${cmd1} ${cmd2} ${cmd3}
    Log    Check Action    console=True
    FOR    ${index}    IN RANGE    0    30
        sleep    2s
        ${gncell_onair}    Run Keyword If      ${GSM_cell_ids}      Run Keyword And Return Status
        ...    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}
        ${wncell_onair}    Run Keyword If      ${WCDMA_cell_ids}    Run Keyword And Return Status
        ...    coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}
        ${lncell_onair}    Run Keyword If      ${LTE_cell_ids}      Run Keyword And Return Status
        ...    coam.Assert Every    LNCEL    ${cells_LTE_expected_state}
        ${nrcell_onair}    Run Keyword If      ${NRBTS_cell_ids}    Run Keyword And Return Status
        ...    coam.Assert Every    NRCEL    ${cells_NR_expected_state}
        Run Keyword If    ${GSM_cell_ids}      Should Be True    ${gncell_onair}
        Run Keyword If    ${WCDMA_cell_ids}    Should Be True    ${wncell_onair}
        Run Keyword If    ${LTE_cell_ids}      Should Be True    ${lncell_onair}
        Run Keyword If    ${NRBTS_cell_ids}    Should Be True    ${nrcell_onair}
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Provision Plan And Check Feedback
    Log    Step ${index}: Pre-Activate Plan And Check Feedback    console=True
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${incorret_plan_name}    dist_names=${MRBTS_DN}
    ...    create_backup_plan=False    provisioning_operation=activate
    Should Contain    ${feedback}    ${error_message}
    Should Contain    ${feedback}    Error\n\t5G/LTE/SRAN plan provision failed

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_backup_name}
    Check Selected Parameter Is Not Exist
    Common Test Teardown

TC Setup
    Log    TC Setup    console=True
    Common Test Setup

TC Teardown
    Log    TC Teardown    console=True
    Particular Teardown