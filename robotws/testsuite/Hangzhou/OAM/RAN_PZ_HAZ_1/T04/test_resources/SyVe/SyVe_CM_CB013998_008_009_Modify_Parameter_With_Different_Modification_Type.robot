*** Settings ***
Documentation       Test case for NFTA CB013998_008,and CB013998_009
...                 Author: Xu Yuyxu
...                 Contact: yuyan.xu@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1014    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
&{plan_info_13998_008_rat}      scf_distName=MRBTS-1905/NRBTS-11435/NRDU-1
...    parameter_name=actNonBfAndBfCa    value1=true    value2=false
&{plan_info_13998_008_cell}      scf_distName=MRBTS-1905/NRBTS-11435/NRCELL-1
...    parameter_name=actPcsiOnF2Fdm    value1=true    value2=false
@{plan_info_008_list}    ${plan_info_13998_008_rat}    ${plan_info_13998_008_cell}
${RECOVERY_FLAG}    ${False}

*** Keywords ***
SyVe_CM_CB013998_008_009_Modify_Parameter_With_Different_Modification_Type
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for cases:
    ...    - CB013998_008
    ...    - CB013998_009
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.03.2025 - New by Xu Yuyan - New case
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Create And Edit Plan SyVe For Different Modification Type
    Step 2: Provision The Plan SyVe On NetAct
    Step 3: Check Modified Parameters On NetAct
    Step 4: Provision the backup plan

Step ${index}: Create And Edit Plan SyVe For Different Modification Type
    Log    Step ${index}: Create And Edit Plan SyVe For Different Modification Type    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    ${name}    Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    FOR    ${plan_info}    IN    @{plan_info_008_list}
        ${origin_value}    Get Parameter Value From WebEM    ${plan_info['scf_distName']}    ${plan_info['parameter_name']}
        Set Test Variable    ${origin_value}
        ${value_to_set}    Set Variable If    "${origin_value}"=="${plan_info['value2']}"
        ...    ${plan_info['value1']}    ${plan_info['value2']}
        Set To Dictionary    ${plan_info}    value=${value_to_set}
        ${parameter}    Create Dictionary    ${plan_info["parameter_name"]}=${plan_info["value"]}
        ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info['scf_distName']}"]
        NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
        ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${plan_info['scf_distName']}    &{parameter}
    END
    Set Test Variable    ${plan}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.xml    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision The Plan SyVe On NetAct
    Log    Step ${index}: Provision The Plan SyVe On NetAct    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable   racclimx.sh -planName ${name} -DN ${MRBTS_DN}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${name}_backup
    ${cmd3}    Set Variable    -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection


Step ${index}: Check Modified Parameters On NetAct
    Log    Step ${index}: Check Modified Parameters On NetAct    console=True
    FOR    ${plan_info}    IN    @{plan_info_008_list}
        ${parameter}    Create Dictionary    ${plan_info["parameter_name"]}=${plan_info["value"]}
        Wait Until Keyword Succeeds    5x    10s    NetAct Check Actual Configuration Parameters
        ...    dist_name=PLMN-PLMN/${plan_info['scf_distName']}    ui_values=false    &{parameter}
    END

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms


Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Run Keyword If    ${RECOVERY_FLAG}    Run Keywords
    ...   Log   Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown