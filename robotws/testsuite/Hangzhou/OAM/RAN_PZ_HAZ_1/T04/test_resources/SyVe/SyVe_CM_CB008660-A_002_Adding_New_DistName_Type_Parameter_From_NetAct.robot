*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
&{new_dn_plan_info}    #scf_distName=MRBTS-1905/MNL-1/MNLENT-1/MPLANENW-1    mo_id=PLMN-PLMN/MRBTS-1905/MNL-1/MNLENT-1/MPLANENW-1 data changed
...    parameter_name=nrSysInfoNsaProfileDN    shortenedDN=NRSYSINFO_PROFILE_NSA-0    incorrect_shortenedDN=NRSYSINFO_PROFILE_NSA-5
&{NEW_OBJ_PARAM_DIC}    systemInformationTargetRate=0

*** Keywords ***
SyVe_CM_CB008660-A_002_Adding_New_DistName_Type_Parameter_From_NetAct
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing testing for VRAN_SyVe_CB008660-A_002_CM_Adding new distname-type parameter from NMS
    ...    The main steps performed for the test are:
    ...    - TC Parameter Check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Create Plan With New DistName Type Parameter
    ...    - Provision Plan And Check Behavior
    ...    - Check modified parameter in Admin after provision plan
    ...    - Check modified parameter in Netact after provision plan
    ...    - Create Plan With Incorrect DistName Type Parameter
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
    Step 5: Create Plan With New DistName Type Parameter
    Step 6: Provision Plan And Check Behavior
    Step 7: Check modified parameter in Admin after provision plan
    Step 8: Check modified parameter in Netact after provision plan
    Step 9: Create Plan With Incorrect DistName Type Parameter
    Step 10: Provision Plan And Check Feedback
    Step 11: Provision the backup plan
    Step 12: Check final alarms status from WebEM
    Step 13: Check final alarms status from Netact
    Step 14: Check final BTS state
    Step 15: Check final number and state of Cells and RMs

Step ${index}: TC Parameter Check
    Log    Step ${index}: TC Parameter Check    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${NRCells_list}    Fetch ID Mapping From Admin For Cells    NRBTS
    ${NRCells_list_length}    Get Length    ${NRCells_list}
    ${random}    Evaluate    random.randint(0, ${NRCells_list_length-1})    modules=random, sys
    ${nrcell_scf_dn}    Get From Dictionary    ${NRCells_list[${random}]}    configuration
    ${nrcell_dn_str_list}    Split String    ${nrcell_scf_dn}    /
    Set Test Variable    ${NRBTS}    ${nrcell_dn_str_list[1]}
    ${nrcell_internal_id}    Get From Dictionary    ${NRCells_list[${random}]}    internal
    Set Test Variable    ${nrcell_scf_dn}
    Set Test Variable    ${nrcell_internal_id}
    Set Test Variable    ${nrcell_mo_dn}    PLMN-PLMN/${nrcell_scf_dn}
    Set Test Variable    ${nrcell_meta_class}    com.nokia.srbts.nrbts:NRCELL
    Set Test Variable    ${new_nr_mo_dn}    ${MRBTS_DN}/${NRBTS}/${new_dn_plan_info['shortenedDN']}
    Set Test Variable    ${new_mo_meta_class}    com.nokia.srbts.nrbts:NRSYSINFO_PROFILE_NSA
    Set Test Variable    &{PARAM_DIC}    ${new_dn_plan_info['parameter_name']}=${new_dn_plan_info['shortenedDN']}
    Set Test Variable    &{INCORRECT_PARAM_DIC}    ${new_dn_plan_info['parameter_name']}=${new_dn_plan_info['incorrect_shortenedDN']}
    Set Test Variable    ${EXPECED_PDL_ERROR}
    ...    Distname parameter '${new_dn_plan_info['parameter_name']}' references non-existing '${new_dn_plan_info['incorrect_shortenedDN']}' object
    ${NRCells_Unlock_config_list}    Create List
    ${NRCells_Unlock_RTDN_list}    Create List
    Set Test Variable    ${NRCells_Unlock_config_list}
    Set Test Variable    ${NRCells_Unlock_RTDN_list}
    FOR    ${item}    IN    @{NRCells_list}
        Log    ${item}
        ${config}    Get From Dictionary    ${item}    configuration
        ${RT_DN}    Get From Dictionary    ${item}    internal
        Append To List    ${NRCells_Unlock_config_list}    ${config}
        Append To List    ${NRCells_Unlock_RTDN_list}    ${RT_DN}
    END
    Remove Values From List    ${NRCells_Unlock_config_list}    ${nrcell_scf_dn}
    Remove Values From List    ${NRCells_Unlock_RTDN_list}    ${nrcell_internal_id}
    NetAct CM Upload    dist_names=${MRBTS_DN}
    ${status}    Run Keyword And Return Status    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=check_netact_plan.xml    dist_names=${MRBTS_DN}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml_content}    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/check_netact_plan.xml
    ${status}    ${msg}    Run Keyword And Ignore Error     L_XML.Get Element Text    ${xml_content}
    ...    .//managedObject[@distName="${nrcell_mo_dn}"]/p[@name="${new_dn_plan_info['parameter_name']}"]
    ${msg_asexpected}    Run Keyword And Return Status
    ...    Should Contain    ${msg}
    ...    No element matching './/managedObject[@distName="${nrcell_mo_dn}"]/p[@name="${new_dn_plan_info['parameter_name']}"]' found
    Run Keyword If    '${status}'=='FAIL' and ${msg_asexpected}    Log    TC parameters successfully checked    console=True
    ...    ELSE    Run Keywords
    ...    Log    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    AND    Recovery Parameter Value   ${nrcell_mo_dn}    ${nrcell_scf_dn}   ${new_dn_plan_info['parameter_name']}=${EMPTY}

Recovery Parameter Value
    [Arguments]     ${mo_id}    ${scf_dn}    &{param_dic}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    recovery_MRBTS-${mrbts_id}_${timestamp}
    NetAct Create And Edit Plan    name=recovery_MRBTS-${mrbts_id}_${timestamp}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${mo_id}   scf_distName=${scf_dn}   &{param_dic}
    NetAct Provision Plan    plan_name=recovery_MRBTS-${mrbts_id}_${timestamp}    dist_names=${MRBTS_DN}    backup_plan_name=None
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

Step ${index}: Provision Plan And Check Behavior
    Log    Step ${index}: Provision Plan And Check Behavior    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN ${MRBTS_DN}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${plan_name}_backup -v
    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command     ${cmd1} ${cmd2} ${cmd3}
    Log    Check Action    console=True
    ${result}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    20
        sleep    3s
        ${result_tmp}    Run Keyword and Return Status    coam.Assert    NRCEL    ${nrcell_internal_id}    ${cells_NR_offline_state}
        ${result}    Set Variable If    ${result}    ${result}    ${result_tmp}
        Check Other Objects On Air
    END
    Should Be True    ${result}
    FOR    ${index}    IN RANGE    0    20
        sleep    3s
        ${result_tmp}    Run Keyword and Return Status    coam.Assert    NRCEL    ${nrcell_internal_id}    ${cells_NR_expected_state}
        ${result}    Set Variable    ${result_tmp}
        Check Other Objects On Air
        Exit For Loop If    ${result_tmp}
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Be True    ${result}
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan   console=True
     NetAct Check Actual Configuration Parameters    dist_name=${nrcell_mo_dn}   &{PARAM_DIC}

Step ${index}: Check modified parameter in Admin after provision plan
    Log    Step ${index}: Check modified parameter in Admin after provision plan    console=True
    Check WebEM After Modify Parameters    ${nrcell_scf_dn}    &{PARAM_DIC}

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

Check Other Objects On Air
    FOR    ${item}    IN    @{NRCells_Unlock_RTDN_list}
        coam.Assert    NRCEL    ${item}    ${cells_NR_expected_state}
    END
    ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
    ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
    ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
    ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status    coam.Assert Every    GNCEL
    ...    ${cells_GSM_expected_state}
    ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status    coam.Assert Every    WNCEL
    ...    ${cells_WCDMA_expected_state}
    ${lncell_onair}    Run Keyword If    ${lncell}    Run Keyword And Return Status    coam.Assert Every    LNCEL
    ...    ${cells_LTE_expected_state}
    Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
    Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
    Run Keyword If    ${lncell}    Should Be True    ${lncell_onair}

Step ${index}: Create Plan With New DistName Type Parameter
    [Documentation]    Create plan with new distName type parameter like: nrSysInfoNsaProfileDN
    Log    Step ${index}: Create Plan With New DistName Type Parameter    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${plan_name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}    NetAct Create Plan     ${plan_name}    Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${nrcell_scf_dn}"]
    Set Test Variable    ${MO_items}
    NetAct Create Managed Object    plan=${plan}    meta_class=${nrcell_meta_class}
    ...    meta_version=${MO_items['version']}    mo_id=${nrcell_mo_dn}
    ...    &{PARAM_DIC}
    NetAct Create Managed Object    plan=${plan}    meta_class=${new_mo_meta_class}
    ...    meta_version=${MO_items['version']}    mo_id=${new_nr_mo_dn}
    ...    &{NEW_OBJ_PARAM_DIC}

Step ${index}: Create Plan With Incorrect DistName Type Parameter
    [Documentation]    Create Plan With Incorrect DistName Type Parameter
    Log    Step ${index}: Create Plan With Incorrect DistName Type Parameter    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${incorret_plan_name}    MRBTS-${mrbts_id}_${timestamp}
    ${incorrect_plan}    NetAct Create Plan     ${incorret_plan_name}    Automation SyVe for MRBTS-${mrbts_id}
    NetAct Create Managed Object    plan=${incorrect_plan}    meta_class=${nrcell_meta_class}
    ...    meta_version=${MO_items['version']}     mo_id=${nrcell_mo_dn}
    ...    &{INCORRECT_PARAM_DIC}

Step ${index}: Provision Plan And Check Feedback
    Log    Step ${index}: Pre-Activate Plan And Check Feedback    console=True
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${incorret_plan_name}    dist_names=${MRBTS_DN}
    ...    create_backup_plan=False    provisioning_operation=activate
    Should Contain    ${feedback}    ${EXPECED_PDL_ERROR}
    Should Contain    ${feedback}    Error\n\t5G/LTE/SRAN plan provision failed

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}_backup
    ${current_value}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${nrcell_mo_dn}    &{EMPTY}
    Run Keyword If    not ${current_value}    Run Keywords
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
