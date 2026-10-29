*** Settings ***
Documentation       Test case for CB013998_004,CB013998_007
...                 Author: Yuxing Zhai
...                 Contact: yuxing.zhai@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB2002    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
#Parameter type is condition RU Reset which will not trigger rat reset
&{plan_info_13998_004_online1}      scf_distName=MRBTS-10039/EQM-1/APEQM-1/RMOD-1
...    parameter_name=ptpSyncRepPrd    value1=60    value2=70
@{plan_info_004_online_list}    ${plan_info_13998_004_online1}
#Parameter type is condition RU Reset which will trigger rat reset
&{plan_info_13998_004_reset1}      scf_distName=MRBTS-10039/MNL-1/MNLENT-1/FEATCADM-1
...    parameter_name=actEcpriRuMPlaneSecurity    value1=RuProtectEnabled    value2=RuProtectDisabled
@{plan_info_004_reset_list}    ${plan_info_13998_004_reset1}
${RECOVERY_FLAG}    ${False}

*** Keywords ***
SyVe_CM_CB013998_004_Modify_Parameter_With_RU_Reset
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for cases:
    ...    - CB013998_004
    ...    - CB013998_007
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.03.2025 - New by Xu Yuyan - New case
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    #Scenario1:not trigger ru reset
    Step 1: Random Select Not RU Reset Parameter
    Step 2: Modify Parameter On SBTS And Check Not RU Reset Behavior
    Step 3: Upload configuration status
    Step 4: Create and edit plan SyVe For Not RU Reset
    Step 5: Provision the plan SyVe On NetAct And Check Not RU Reset Behavior
    Step 6: Check modified Not RU Reset parameter On Netact
    #Scenario2:trigger ru reset
    Step 7: Random Select RU Reset Parameter
    Step 8: Modify Parameter On SBTS And Check RU Reset Behavior
    Step 9: Upload configuration status
    Step 10: Create and edit plan SyVe For RU Reset
    Step 11: Provision the plan SyVe On NetAct And Check RU Reset Behavior
    Step 12: Check modified RU Reset parameter On NetAct


Step ${index}: Random Select Not RU Reset Parameter
    Log    Step ${index}: Random Select Not RU Reset Parameter    console=True
    ${plan_info_online}    Evaluate    random.choice(${plan_info_004_online_list})    modules=random, sys
#    ${plan_info_online}    Evaluate    ${plan_info_13998_004_online1}
    Set Test Variable    ${plan_info_online}
    Log To Console    plan_info_online:${plan_info_online}    console=True
    ${origin_value}    Get Parameter Value From WebEM    ${plan_info_online['scf_distName']}    ${plan_info_online['parameter_name']}
    Set Test Variable    ${origin_value}
    ${value_to_set_webem}    Set Variable If    "${origin_value}"=="${plan_info_online['value2']}"
    ...    ${plan_info_online['value1']}    ${plan_info_online['value2']}
    Set Test Variable    ${value_to_set_webem}
    Set To Dictionary    ${plan_info_online}    value=${origin_value}
    ${rmod_id_dic_online}    Fetch ID Mapping From Admin For Module    ${plan_info_online['scf_distName']}
    Set Test Variable    ${rmod_id_dic_online}


Step ${index}: Modify Parameter On SBTS And Check Not RU Reset Behavior
    Log    Step ${index}: Modify Parameter On SBTS And Check Not RU Reset Behavior    console=True
    coam.perform_parameter_recommissioning
    ...    ${plan_info_online['scf_distName']}    ${plan_info_online['parameter_name']}    update    ${value_to_set_webem}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    FOR    ${index}    IN RANGE    0    10
        coam.Assert    RMOD     ${rmod_id_dic_online["internal"]}   operationalState=${_Enabled_}    timeout=20s
        Sleep    15s
    END
    Check SBTS SMOD RMOD Cells Alarms
    ${current_value}    Get Parameter Value From WebEM    ${plan_info_online['scf_distName']}    ${plan_info_online['parameter_name']}
    Should Be Equal As Strings    ${current_value}    ${value_to_set_webem}
    Verify Cells State Changed From IMS2    ${BTSFiles}/InfoModel_log_for_not_ru_reset.ims2

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe For Not RU Reset
    Log    Step ${index}: Create and edit plan SyVe For Not RU Reset    console=True
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

Step ${index}: Provision the plan SyVe On NetAct And Check Not RU Reset Behavior
    Log    Step ${index}: Provision the plan SyVe On NetAct And Check Not RU Reset Behavior    console=True
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
        coam.Assert    RMOD     ${rmod_id_dic_online["internal"]}   operationalState=${_Enabled_}
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
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Check SBTS SMOD RMOD Cells Alarms
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Step ${index}: Check modified Not RU Reset parameter On NetAct
    Log    Step ${index}: Check modified Not RU Reset parameter On NetAct     console=True
    Wait Until Keyword Succeeds    5x    10s    NetAct Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${plan_info_online['scf_distName']}    ui_values=false    &{parameter}

Step ${index}: Random Select RU Reset Parameter
    Log    Step ${index}: Random Select RU Reset Parameter    console=True
    ${plan_info_reset}    Evaluate    random.choice(${plan_info_004_reset_list})    modules=random, sys
#   ${plan_info_reset}    Evaluate    ${plan_info_13998_004_reset1}
    Set Test Variable    ${plan_info_reset}
    Log To Console    plan_info_reset:${plan_info_reset}    console=True
    ${origin_value}    Get Parameter Value From WebEM    ${plan_info_reset['scf_distName']}    ${plan_info_reset['parameter_name']}
    Set Test Variable    ${origin_value}
    ${value_to_set_webem}    Set Variable If    "${origin_value}"=="${plan_info_reset['value2']}"
    ...    ${plan_info_reset['value1']}    ${plan_info_reset['value2']}
    Set Test Variable    ${value_to_set_webem}
    Set To Dictionary    ${plan_info_reset}    value=${origin_value}

    ${rmod_id_dic_reset}    Fetch ID Mapping From Admin For Module    MRBTS-10039/EQM-1/APEQM-1/RMOD-1    #${plan_info_online['scf_distName']}
    Set Test Variable    ${rmod_id_dic_reset}
    ${impact_cells_list}    Create List
    ${full_scf}    coam.Get Scf    configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${full_scf_xml}    L_XML.Parse Xml    ${full_scf}
    ${cell_dic}    Get RMOD Related Cells    ${rmod_id_dic_reset["runtime"]}    ${full_scf_xml}
    FOR    ${index}    IN    @{cell_dic.keys()}
        ${cells_list}    Set Variable    ${cell_dic["${index}"]}
        FOR    ${cell}    IN    @{cells_list}
            Append To List    ${impact_cells_list}    ${cell.split("/")[-1].replace("_R","")}
        END
    END
    Set Test Variable    ${impact_cells_list}

Step ${index}: Modify Parameter On SBTS And Check RU Reset Behavior
    Log    Step ${index}: Modify Parameter On SBTS And Check RU Reset Behavior    console=True
    coam.perform_parameter_recommissioning
    ...    ${plan_info_reset['scf_distName']}    ${plan_info_reset['parameter_name']}    update    ${value_to_set_webem}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Wait Until Keyword Succeeds    10 min    2 sec
    ...    coam.Assert     RMOD     ${rmod_id_dic_reset["internal"]}   operationalState=${_Disabled_}
    Wait Until Keyword Succeeds    15 min    2 sec
    ...    coam.Assert    RMOD     ${rmod_id_dic_reset["internal"]}   operationalState=${_Enabled_}
     ${current_value}    Get Parameter Value From WebEM    ${plan_info_reset['scf_distName']}    ${plan_info_reset['parameter_name']}
    Should Be Equal As Strings    ${current_value}    ${value_to_set_webem}
    return from keyword    #no other parameter,actEcpriRuMPlaneSecurity set enable will cause SBTS1893 RMOD-9 failed,disable,sitereset will recovery
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Verify Cells State Changed From IMS2    ${BTSFiles}/InfoModel_log_for_ru_reset.ims2    @{impact_cells_list}
    Teardown Infomodel
    Wait Until Keyword Succeeds    3x    60s    Start Infomodel


Step ${index}: Create and edit plan SyVe For RU Reset
    Log    Step ${index}: Create and edit plan SyVe For RU Reset    console=True
    ${parameter}    Create Dictionary    ${plan_info_reset["parameter_name"]}=${plan_info_reset["value"]}
    Set Test Variable    ${parameter}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${value_tmp}    Set Variable If    "${parameter["actEcpriRuMPlaneSecurity"]}"=="RuProtectEnabled"    0    1
    ${parameter_NA}    Create Dictionary    ${plan_info_reset["parameter_name"]}=${value_tmp}
    Set Test Variable    ${parameter_NA}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=PLMN-PLMN/${plan_info_reset['scf_distName']}    scf_distName=${plan_info_reset['scf_distName']}    &{parameter_NA}
    Set Test Variable    ${plan}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.xml    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe On NetAct And Check RU Reset Behavior
    Log    Step ${index}: Provision the plan SyVe On NetAct And Check RU Reset Behavior    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable   racclimx.sh -planName ${name} -DN ${MRBTS_DN}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${name}_backup
    ${cmd3}    Set Variable    -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Wait Until Keyword Succeeds    10 min    2 sec    coam.Assert     RMOD     ${rmod_id_dic_reset["internal"]}   operationalState=${_Disabled_}
    Wait Until Keyword Succeeds    15 min    2 sec    coam.Assert    RMOD     ${rmod_id_dic_reset["internal"]}   operationalState=${_Enabled_}
    coam.reset_site
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    return from keyword    #no other parameter,actEcpriRuMPlaneSecurity set enable will cause SBTS1893 RMOD-9 failed,disable,sitereset will recovery
    Verify Cells State Changed From IMS2    ${BTSFiles}/InfoModel_log_for_ru_reset_netact.ims2    @{impact_cells_list}
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Step ${index}: Check modified RU Reset parameter On NetAct
    Log    Step ${index}: Check modified RU Reset parameter On NetAct    console=True
    Wait Until Keyword Succeeds    5x    10s    NetAct Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${plan_info_reset['scf_distName']}    ui_values=false    &{parameter_NA}

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