*** Settings ***
Documentation       Test case for CB013998_001
...                 Author: Yuxing Zhai
...                 Contact: Yuxing.zhai@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB2002    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
#Parameter type is condition RAT Reset which will trigger rat reset
&{plan_info_13998_001_reset1}      scf_distName=MRBTS-10039/NRBTS-10039/NRDU-1
...    parameter_name=actNonBfAndBfCa    value1=true    value2=false
@{plan_info_001_reset_list}    ${plan_info_13998_001_reset1}
#Parameter type is condition RAT Reset which will not trigger rat reset
&{plan_info_13998_001_online1}      scf_distName=MRBTS-10039/LNBTS-10039
...    parameter_name=actFstDmrsBasedShrinkage    value1=true    value2=false
@{plan_info_001_online_list}    ${plan_info_13998_001_online1}
${RECOVERY_FLAG}    ${False}

*** Keywords ***
SyVe_CM_CB013998_921_Modify_Parameter_With_RAT_Reset
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for cases:
    ...    RAN_ST_CB013998_001_CM_SR_Modify with WebEM in SBTS some parameter(s) with “Conditional RAT reset” modification type
    ...
    ...
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.03.2025 - New by Xu Yuyan - New case
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    #Scenario1:not trigger rat reset
    Step 1: Random Select Not RAT Reset Parameter
    Step 2: Modify Parameter On SBTS And Check Not RAT Reset Behavior
    Step 3: Upload configuration status
    Step 4: Create and edit plan SyVe For Not RAT Reset
    Step 5: Provision the plan SyVe On NetAct And Check Not RAT Reset Behavior
    Step 6: Check modified Not RAT Reset parameter On NetAct
    #Scenario2:trigger rat reset
    Step 7: Random Select RAT Reset Parameter
    Step 8: Modify Parameter On SBTS And Check RAT Reset Behavior
    Step 9: Upload configuration status
    Step 10: Create and edit plan SyVe For RAT Reset
    Step 11: Provision the plan SyVe On NetAct And Check RAT Reset Behavior
    Step 12: Check modified RAT Reset parameter On NetAct


Step ${index}: Random Select Not RAT Reset Parameter
    Log    Step ${index}: Random Select Not RAT Reset Parameter    console=True
    ${plan_info_online}    Evaluate    random.choice(${plan_info_001_online_list})    modules=random, sys
    Set Test Variable    ${plan_info_online}
    Log To Console    plan_info_online:${plan_info_online}    console=True
    ${origin_value}    Get Parameter Value From WebEM    ${plan_info_online['scf_distName']}    ${plan_info_online['parameter_name']}
    Set Test Variable    ${origin_value}
    ${value_to_set_webem}    Set Variable If    "${origin_value}"=="${plan_info_online['value2']}"
    ...    ${plan_info_online['value1']}    ${plan_info_online['value2']}
    Set Test Variable    ${value_to_set_webem}
    Set To Dictionary    ${plan_info_online}    value=${origin_value}

Step ${index}: Modify Parameter On SBTS And Check Not RAT Reset Behavior
    Log    Step ${index}: Modify Parameter On SBTS And Check Not RAT Reset Behavior    console=True
    coam.perform_parameter_recommissioning
    ...    ${plan_info_online['scf_distName']}    ${plan_info_online['parameter_name']}    update    ${value_to_set_webem}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    ${current_value}    Get Parameter Value From WebEM    ${plan_info_online['scf_distName']}    ${plan_info_online['parameter_name']}
    Should Be Equal As Strings    ${current_value}    ${value_to_set_webem}
    Verify Cells State Changed From IMS2    ${BTSFiles}/InfoModel_log_for_not_rat_reset.ims2

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe For Not RAT Reset
    Log    Step ${index}: Create and edit plan SyVe For Not RAT Reset    console=True
    ${parameter}    Create Dictionary    ${plan_info_online["parameter_name"]}=${plan_info_online["value"]}
    Set Test Variable    ${parameter}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name_online}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name_online}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=PLMN-PLMN/${plan_info_online['scf_distName']}    scf_distName=${plan_info_online['scf_distName']}    &{parameter}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_online}.xml    dist_names=${MRBTS_DN}
    ...    plan_name=${name_online}    operation_type=plan

Step ${index}: Provision the plan SyVe On NetAct And Check Not RAT Reset Behavior
    Log    Step ${index}: Provision the plan SyVe On NetAct And Check Not RAT Reset Behavior    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable   racclimx.sh -planName ${name_online} -DN ${MRBTS_DN}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${name_online}_backup
    ${cmd3}    Set Variable    -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    Log    Check Action    console=True
    FOR    ${index}    IN RANGE    0    20
        sleep    3s
        ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
        ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
        ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
        ${nrcell}    Run Keyword And Return Status    coam.Assert Any    NRCEL
        ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status
        ...    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}    timeout=30
        ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status
        ...    coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}    timeout=30
        ${lncell_onair}    Run Keyword If    ${lncell}    Run Keyword And Return Status
        ...    coam.Assert Every    LNCEL    ${cells_LTE_expected_state}    timeout=30
        ${nrcell_onair}    Run Keyword If    ${nrcell}    Run Keyword And Return Status
        ...    coam.Assert Every    NRCEL    ${cells_NR_expected_state}    timeout=30
        Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
        Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
        Run Keyword If    ${lncell}    Should Be True    ${lncell_onair}
        Run Keyword If    ${nrcell}    Should Be True    ${nrcell_onair}
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Step ${index}: Check modified Not RAT Reset parameter On NetAct
    Log    Step ${index}: Check modified Not RAT Reset parameter On NetAct     console=True
    Wait Until Keyword Succeeds    5x    10s    NetAct Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${plan_info_online['scf_distName']}    ui_values=false    &{parameter}
    Set Test Variable    ${RECOVERY_FLAG}    ${False}


Step ${index}: Random Select RAT Reset Parameter
    Log    Step ${index}: Random Select RAT Reset Parameter    console=True
    ${plan_info_reset}    Evaluate    random.choice(${plan_info_001_reset_list})    modules=random, sys
    Set Test Variable    ${plan_info_reset}
    Log To Console    plan_info_reset:${plan_info_reset}    console=True
    ${origin_value}    Get Parameter Value From WebEM    ${plan_info_reset['scf_distName']}    ${plan_info_reset['parameter_name']}
    Set Test Variable    ${origin_value}
    ${value_to_set_webem}    Set Variable If    "${origin_value}"=="${plan_info_reset['value2']}"
    ...    ${plan_info_reset['value1']}    ${plan_info_reset['value2']}
    Set Test Variable    ${value_to_set_webem}
    Set To Dictionary    ${plan_info_reset}    value=${origin_value}
    ${rat_str}    Set Variable    ${plan_info_reset['scf_distName'].split("/")[1].split("-")[0]}
    ${techno}    Set Variable If    "${rat_str}" == "GNBTS"    GSM    "${rat_str}" == "WNBTS"    WCDMA
        ...    "${rat_str}" == "LNBTS"    LTE    "${rat_str}" == "NRBTS"    NR
    Set Test Variable    ${techno}
    ${Other_rats_list}    Create List    GSM    WCDMA    LTE    NR
    Remove Values From List    ${Other_rats_list}    ${techno}
    Set Test Variable   ${Other_rats_list}

Step ${index}: Modify Parameter On SBTS And Check RAT Reset Behavior
    Log    Step ${index}: Modify Parameter On SBTS And Check RAT Reset Behavior    console=True
    coam.perform_parameter_recommissioning
    ...    ${plan_info_reset['scf_distName']}    ${plan_info_reset['parameter_name']}    update    ${value_to_set_webem}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    ${current_value}    Get Parameter Value From WebEM    ${plan_info_reset['scf_distName']}    ${plan_info_reset['parameter_name']}
    Should Be Equal As Strings    ${current_value}    ${value_to_set_webem}
    ${impact_cells_list}    Create List
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${cells_list}    ${cell_list['cells']['${techno.lower()}']}
    FOR    ${cell}    IN    @{cells_list}
        ${cellName}    Set Variable    ${cell['id']['configuration'].split("/")[-1]}
        Append To List    ${impact_cells_list}    ${cell['id']['configuration'].split("/")[-1]}
    END
    Verify Cells State Changed From IMS2    ${BTSFiles}/InfoModel_log_for_rat_reset.ims2    @{impact_cells_list}


Step ${index}: Create and edit plan SyVe For RAT Reset
    Log    Step ${index}: Create and edit plan SyVe For RAT Reset    console=True
    ${parameter}    Create Dictionary    ${plan_info_reset["parameter_name"]}=${plan_info_reset["value"]}
    Set Test Variable    ${parameter}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=PLMN-PLMN/${plan_info_reset['scf_distName']}    scf_distName=${plan_info_reset['scf_distName']}    &{parameter}
    Set Test Variable    ${plan}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.xml    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe On NetAct And Check RAT Reset Behavior
    Log    Step ${index}: Provision the plan SyVe On NetAct And Check RAT Reset Behavior    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable   racclimx.sh -planName ${name} -DN ${MRBTS_DN}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${name}_backup
    ${cmd3}    Set Variable    -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    FOR    ${index}    IN RANGE    0    800
        ${result}    ${rat_status}=    Run Keyword And Ignore Error    Check ${techno} RAT status
        FOR    ${other_rat}    IN    @{Other_rats_list}
            ${other_rat_tmp}    Set Variable If    "${other_rat}"=="NR"    NRBTS    ${other_rat}
            ${condition}    Set Variable    ${${other_rat_tmp}_cell_ids}
            ${other_rat_state}    Run Keyword If    ${condition}    Check ${other_rat} RAT status
            Run Keyword If    ${condition}    Should Be Equal As Strings    ${other_rat_state}    ALL_ENABLED
        END
        ${reset}    run keyword and return status    Should Be Equal As Strings    ${rat_status}    ALL_DISABLED
        Exit For Loop If    ${reset}
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Should Be Equal As Strings    ${reset}    True
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection


Check ${rat_techo} RAT status
    ${rat}    String.Convert To Lower Case    ${rat_techo}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    set variable    ${btsinfo_list['ratState']['${rat}']}
    [Return]    ${rat_status}

Step ${index}: Check modified RAT Reset parameter On NetAct
    Log    Step ${index}: Check modified RAT Reset parameter On NetAct    console=True
    Wait Until Keyword Succeeds    5x    10s    NetAct Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${plan_info_reset['scf_distName']}    ui_values=false    &{parameter}


Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_online}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_online}_backup
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