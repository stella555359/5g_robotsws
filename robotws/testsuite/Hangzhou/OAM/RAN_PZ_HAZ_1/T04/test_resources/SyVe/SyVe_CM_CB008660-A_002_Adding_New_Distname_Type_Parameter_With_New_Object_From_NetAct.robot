*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
&{new_obj_param_dic_8660_002}     transportNwId=5    transportNwInUse=false
...    cPlaneipV4AddressDN1=TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-3    ipV4AddressDN1=TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-3
&{incorrect_new_obj_param_dic_8660_002}    transportNwId=5    transportNwInUse=false
...    ipV4AddressDN1=TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-3
&{new_obj_plan_info_8660_002}    scf_distName=MRBTS-1894/LNBTS-5076/TRSNW-5    mo_id=PLMN-PLMN/MRBTS-1894/LNBTS-5076/TRSNW-5
...    metaclass=NOKLTE:TRSNW    param_dic=&{new_obj_param_dic_8660_002}   validate_param=uPlane-1.ipV4AddressDN1
...    validate_param_dn_value=TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-3    incorrect_param_dic=&{incorrect_new_obj_param_dic_8660_002}
&{new_dn_obj_param_dic_8660_002}    localIpAddr=1.1.1.0    localIpPrefixLength=25    ipAddressAllocationMethod=0
&{new_dn_obj_info_8660_002}    scf_distName=MRBTS-1894/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-3
...    mo_id=PLMN-PLMN/MRBTS-1894/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-3    metaclass=com.nokia.srbts.tnl:IPADDRESSV4
...    param_dic=&{new_dn_obj_param_dic_8660_002}

*** Keywords ***
SyVe_CM_CB008660-A_002_Adding_New_Distname_Type_Parameter_With_New_Object_From_NetAct
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing testing for RAN_SyVe_CB008660-A_02_CM_Adding new distname-type parameter with new object from NMS
    ...    The main steps performed for the test are:
    ...    - TC Parameter Check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create Plan With New Object And New DistName Type Parameter
    ...    - Provision the plan SyVe
    ...    - Check modified parameter in Netact after provision plan
    ...    - Provision the backup plan
    ...    -  Create Plan With New Object And New Incorrect DistName Type Parameter
    ...    -  Provision Plan And Check Feedback
    ...    -  Check final alarms status from WebEM
    ...    -  Check final alarms status from Netact
    ...    -  Check final BTS state
    ...    -  Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.12.2023 - Add new case on NMS with [1][1.0] RAN_SyVe_CB008660-A_XXX_CM_Adding new distname-type parameter with new object from NMS
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: TC Parameter Check
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Create Plan With New Object And New DistName Type Parameter
    Step 7: Provision the plan SyVe
    Step 8: Check modified parameter in Netact after provision plan
    Step 9: Provision the backup plan
    Step 10: Create Plan With New Object And New Incorrect DistName Type Parameter
    Step 11: Provision Plan And Check Feedback
    Step 13: Check final alarms status from WebEM
    Step 14: Check final alarms status from Netact
    Step 15: Check final BTS state
    Step 16: Check final number and state of Cells and RMs

Step ${index}: TC Parameter Check
    Log    Step ${index}: TC Parameter Check    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${plan_info}    ${new_obj_plan_info_8660_002}
    Set Test Variable    ${plan_info_dn}    ${new_dn_obj_info_8660_002}
    NetAct CM Upload    dist_names=${MRBTS_DN}
    ${status}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}   &{EMPTY}
    Run Keyword If    not ${status}    Log    TC Object successfully checked   console=True
    ...    ELSE    Run Keywords
    ...    Log    TC Object check failed: ${plan_info['scf_distName']} already exists! Will perform delta recommission   level=WARN
    ...    AND    coam.Perform Delta Recommissioning
    ...    [{"distName": "${plan_info['scf_distName']}", "operation": "delete", "parameters": []}]
    ...    True
    ${status}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info_dn['mo_id']}   &{EMPTY}
    Run Keyword If    not ${status}    Log    TC Object successfully checked    console=True
    ...    ELSE    Run Keywords
    ...    Log    TC Object check failed: ${plan_info_dn['mo_id']} already exists! Will perform delta recommission  level=WARN
    ...    AND    coam.Perform Delta Recommissioning
    ...    [{"distName": "${plan_info_dn['scf_distName']}", "operation": "delete", "parameters": []}]
    ...    True

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

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${plan_name}    dist_names=${MRBTS_DN}    backup_plan_name=${plan_name}_backup    create_backup_plan=True
    ...    provisioning_operation=activate
    # Conditional BTS Reset in this case scenario for this specific param: create new obj with new dn, so not check behavior

Step ${index}: Check modified parameter in Netact after provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Netact after provision ${plan_type}    console=True
     NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}   &{plan_info['param_dic']}

Step ${index}: Create Plan With New Object And New DistName Type Parameter
    Log    Step ${index}: Create Plan With New DistName Type Parameter    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${plan_name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}    NetAct Create Plan     ${plan_name}    Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${sub_obj}    Fetch From Right    ${plan_info['scf_distName']}    /
    ${parent_obj}    Remove String    ${plan_info['scf_distName']}    /${sub_obj}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${parent_obj}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${plan_info['metaclass']}
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id']}    operation=CREATE
    ...    &{plan_info['param_dic']}
    ${sub_obj}    Fetch From Right    ${plan_info_dn['scf_distName']}    /
    ${parent_obj}    Remove String    ${plan_info_dn['scf_distName']}    /${sub_obj}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${parent_obj}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${plan_info_dn['metaclass']}
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info_dn['mo_id']}    operation=CREATE
    ...    &{plan_info_dn['param_dic']}

Step ${index}: Create Plan With New Object And New Incorrect DistName Type Parameter
    [Documentation]    Create Plan With Incorrect DistName Type Parameter
    Log    Step ${index}: Create Plan With Incorrect DistName Type Parameter    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${incorret_plan_name}    MRBTS-${mrbts_id}_${timestamp}
    ${incorrect_plan}    NetAct Create Plan     ${incorret_plan_name}    Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${sub_obj}    Fetch From Right    ${plan_info['scf_distName']}    /
    ${parent_obj}    Remove String    ${plan_info['scf_distName']}    /${sub_obj}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${parent_obj}"]
    NetAct Create Managed Object    plan=${incorrect_plan}    meta_class=${plan_info['metaclass']}
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id']}    operation=CREATE
    ...    &{plan_info['incorrect_param_dic']}

Step ${index}: Provision Plan And Check Feedback
    Log    Step ${index}: Pre-Activate Plan And Check Feedback    console=True
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${incorret_plan_name}    dist_names=${MRBTS_DN}
    ...    create_backup_plan=False    provisioning_operation=activate
    Log To Console   ${feedback}
    Should Contain    ${feedback}    Error\n\t5G/LTE/SRAN plan provision failed
    ${error_message}    Set Variable
    ...    Distname parameter '${plan_info['validate_param']}' references non-existing '${plan_info['validate_param_dn_value']}' object.
    Should Contain    ${feedback}    ${error_message}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${plan_name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${plan_name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${plan_name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}_backup
    ${current_value}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}   &{EMPTY}
    Run Keyword If    ${current_value}    Run Keywords
    ...    Log     Parameters were not reset to initial values! Probably backup plan was not provisioned!   level=WARN
    ...    AND    Log     Will perform commissioning with initial scf!      level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Log    TC Setup    console=True
    Common Test Setup

TC Teardown
    Log    TC Teardown    console=True
    Particular Teardown
