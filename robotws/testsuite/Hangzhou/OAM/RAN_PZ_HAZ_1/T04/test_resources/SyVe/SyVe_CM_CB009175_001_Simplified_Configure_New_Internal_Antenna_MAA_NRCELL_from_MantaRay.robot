*** Settings ***
Documentation       Test case for SyVe_CM_CB009175_001
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
@{MMA_RMOD_PREFIX}    AE    AQ
${nrCellType}    84
${nrCellType_ui}   8DL4UL
&{mandatory_cell_param_to_update}    actSuperCell=0    actExternalAntennaBF=0    actBeamforming=1
#&{specific_nrbts_param_to_update}    actSaUeBasedAnrEutra=0    actSaUeBasedInterFreqAnrNr=0    actNormVCFallback=0
${RECOVERY_FLAG}           ${False}
${expect_rx_num}     68

*** Keywords ***
SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    RAN_ST_CB009175_001_CM_Configure new internal antenna MAA NRCELL Channel Groups and Channels using Simplified method from MantaRay
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - TC Preparation
    ...    - Modify Plan To Create MAA NRCELL Use Simplified Method
    ...    - Import the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check final BTS state
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check NRCELL be added
    ...    - Check Channels and Channel Groups Auto Created
    ...    - Check Channels and Channel Groups Auto Created
    ...    - Check RF Diagnostic Test Result
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: delete and add NRCEL provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.03.2024
    ...    *******************
    ...    Test case flowchart
    ...    *******************

    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Fetch MAA NRCELL
    Step 5: Delete Selected NRCELL For Env Preparation
    Step 6: Modify Plan To Create MAA NRCELL Use Simplified Method
    Step 7: Import the plan SyVe
    Step 8: Provision the plan SyVe
    Step 9: Check final BTS state
    Step 10: Check NRCELL be added
    Step 11: Check Channels and Channel Groups Auto Created
    Step 12: Check RF Diagnostic Test Result
    Step 13: Provision the backup plan
    Step 14: Check final alarms status from WebEM
    Step 15: Check final alarms status from Netact
    Step 16: Check final BTS state
    Step 17: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log To Console    Step ${index}: Check ${when} BTS state
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF
    Return From Keyword If    '${when}'!='initial'

Step ${index}: Check ${when} alarms status from WebEM
    Log To Console    Step ${index}: Check ${when} alarms status from WebEM
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log To Console    Step ${index}: Check ${when} alarms status from Netact
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Fetch MAA NRCELL
    Log To Console    Step ${index}: Fetch MAA NRCELL
    ${RMOD_list}    coam.Get Parameters For All    RMOD
    ${MMA_RF_list}    Create List
    FOR    ${rmod}    IN    @{RMOD_list}
        ${productName}    Set Variable    ${rmod['productName']}
        ${is_support_maa}    Check RMOD Supoort mMimo    ${productName}
        Run Keyword If    ${is_support_maa}    Append To List    ${MMA_RF_list}     ${rmod['id']}
    END
    ${rmod_cells_mapping}     Get Relationship Between RMODs And Cells
    ${all_maa_nrcell_id_list}    Create List
    FOR    ${rmod}    IN    @{MMA_RF_list}
        ${cell_list}    Set Variable    ${rmod_cells_mapping['${rmod}']['activeNrCellsList']}
        ${all_maa_nrcell_id_list}    Combine Lists    ${all_maa_nrcell_id_list}    ${cell_list}
    END
    ${selected_nrcell_inter_id}    Evaluate    random.choice(${all_maa_nrcell_id_list})    modules=random, sys
    Set Test Variable    ${selected_nrcell_inter_id}
    ${cell_mapping}    Fetch ID Mapping From Admin For Cells    NRBTS    ${selected_nrcell_inter_id}    internal
    Set Test Variable    ${selected_maa_nrcell}    ${cell_mapping['configuration']}
    ${selected_maa_nrcell_id}    Fetch From Right    ${selected_maa_nrcell}    -
    Set Test Variable    ${selected_maa_nrcell_id}
    ${dic_bts_infor}    coam.Get Bts Info
    ${list_nrDU_infor}    Pop From Dictionary    ${dic_bts_infor}    nrDU
    Should Be Equal As Integers    ${list_nrDU_infor.__len__()}    ${1}
    ...    It must be one and only one NRDU for this test case.
    Set Test Variable    ${NRDU_NAME}    ${list_nrDU_infor[0]['id']['configuration']}
    ${Other_NRCELL_list}    Copy List    ${NRBTS_cell_ids}
    Remove Values From List    ${Other_NRCELL_list}    ${selected_nrcell_inter_id}
    Set Test Variable    ${Other_NRCELL_list}

Step ${index}: Delete Selected NRCELL For Env Preparation
    Log To Console    Step ${index}: Delete Selected NRCELL For Env Preparation
    NetAct CM Upload    dist_names=${MRBTS_DN}
    ${plan_name}    Create Plan To Delete NRCELL Via NetAct    ${selected_maa_nrcell}
    Set Test Variable    ${name_bu}    ${plan_name}_backup
    NetAct Provision Plan    plan_name=${plan_name}    dist_names=${MRBTS_DN}    backup_plan_name=${name_bu}    create_backup_plan=True
    ...    provisioning_operation=activate
    ${init_nrcells}    coam.Get Ids For All    NRCEL
    ${deleted_nrcells}    Copy List    ${NRBTS_cell_ids}
    Remove Values From List    ${deleted_nrcells}    @{init_nrcells}
    Set Test Variable    ${deleted_nrcells}
    ${origin_nrcell_count}    Evaluate    len(${NRBTS_cell_ids})
    ${current_nrcell_count}    Evaluate    len(${init_nrcells})
    Should Be Equal As Integers    ${origin_nrcell_count}    ${current_nrcell_count+1}
    Set Test Variable    ${init_nrcells}
    Set Test Variable    ${origin_nrcell_count}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Set Test Variable    ${plan_name}

Step ${index}: Modify Plan To Create MAA NRCELL Use Simplified Method
    Log To Console    Step ${index}: Modify Plan To Create MAA NRCELL Use Simplified Method
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_bu}.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name_bu}   operation_type=plan
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/${name_bu}.csv
    ${lcelnr_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@class="LCELNR"]
    ${lcelnr_dn}    Set Variable    ${lcelnr_items["distName"]}
    ${channelgroup_dn_list}    ${auto_create_channelgroup}    Get Auto Create Obj Info From SCF
    ...    obj_xpath=.//managedObject[@class="CHANNELGROUP"]    scf_xml=${Test Results Dir}/NetActLogs/${name_bu}.csv
    ${channel_dn_list}    ${auto_create_channel}    Get Auto Create Obj Info From SCF
    ...    obj_xpath=.//managedObject[@class="CHANNEL"]    scf_xml=${Test Results Dir}/NetActLogs/${name_bu}.csv
    ${obj_to_remove}    Combine Lists    ${channelgroup_dn_list}    ${channel_dn_list}
#    Set Test Variable    ${auto_create_obj}    ${obj_to_remove}
    Set Test Variable    ${auto_create_channelgroup}
#    ${auto_create_obj_dn_param_dic}    Create Dictionary
#    FOR    ${dn}    IN    @{auto_create_obj}
#        ${param_dic}    Get Auto Create Obj Param Dic    ${scf_xml}    ${dn}
#        Set To Dictionary    ${auto_create_obj_dn_param_dic}    ${dn}    ${param_dic}
#    END
#    Set Test Variable    ${auto_create_obj_dn_param_dic}
    L_XML.Set Element Text    ${scf_xml}    1    \r\n
    ...    cmData/managedObject[@distName="${lcelnr_dn}"]/p[@name="actSimplChConfMAA"]
    L_XML.Set Element Text    ${scf_xml}    ${nrCellType}    \r\n
    ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_maa_nrcell}"]/p[@name="nrCellType"]
    ${params}    Get Dictionary Keys    ${mandatory_cell_param_to_update}
    FOR    ${param}  IN    @{params}
        L_XML.Set Element Text    ${scf_xml}    ${mandatory_cell_param_to_update["${param}"]}    \r\n
        ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_maa_nrcell}"]/p[@name="${param}"]
    END
    FOR    ${obj}    IN    @{obj_to_remove}
        L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@distName="${obj}"]    remove_tail=${True}
    END
    ${timestamp}    Generate Formatted Timestamp
    Should Be String    new_plan_add_nrcell_MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${simp_add_new_maa_nrcell_plan}    new_plan_add_nrcell_MRBTS-${mrbts_id}_${timestamp}
    L_XML.Save XML    ${scf_xml}    ${Test Results Dir}/NetActLogs/${simp_add_new_maa_nrcell_plan}.csv

#Get Auto Create Obj Info
#    [Arguments]     ${scf_xml}    ${obj_xpath}
#    ${obj_elementa}    L_XML.Get Elements    ${scf_xml}    ${obj_xpath}
#    ${obj_dn_list}    Create List
#    FOR    ${item}    IN    @{obj_elementa}
#        ${dn}    L_XML.Get Element Attribute    ${item}    distName
#        Append To List    ${obj_dn_list}    ${dn}
#    END
#    Sort List    ${obj_dn_list}
#    ${need_auto_create_obj}    Set Variable    ${obj_dn_list[0]}
#    Remove Values From List     ${obj_dn_list}    ${need_auto_create_obj}
#    [Return]    ${obj_dn_list}    ${need_auto_create_obj}

#Get Auto Create Obj Param Dic
#    [Arguments]     ${scf_xml}    ${dn}
#    ${param_dic}    Create Dictionary
#    ${params_count}    L_XML.Get Element Count     ${scf_xml}   .//managedObject[@distName="${dn}"]/p
#    Return From Keyword If    ${params_count}==0
#    ${params}    L_XML.Get Elements     ${scf_xml}   .//managedObject[@distName="${dn}"]/p
#    FOR    ${param}    IN    @{params}
#        ${key}    L_XML.Get Element Attribute    ${param}    name
#        ${value}    L_XML.Get Element Text    ${param}
#        Set To Dictionary    ${param_dic}    ${key}    ${value}
#    END
#    [Return]     ${param_dic}

Step ${index}: Import the plan SyVe
    Log To Console    Step ${index}: Import the plan SyVe
    NetAct Import Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${simp_add_new_maa_nrcell_plan}.csv
    ...    plan_name=${simp_add_new_maa_nrcell_plan}

Step ${index}: Provision the plan SyVe
    Log To Console    Step ${index}: Provision the plan SyVe
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${timestamp}    Generate Formatted Timestamp
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${plan_for_recovery}    MRBTS-${mrbts_id}_${timestamp}_recovery
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${simp_add_new_maa_nrcell_plan} -DN ${MRBTS_DN} -createBackupPlan true
    ${cmd2}    Set Variable    -backupPlanName ${plan_for_recovery} -v -provisioningOperation activate
    ${cmd3}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    Log    Check Action    console=True
    ${result}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    40
        Sleep    3s
        Check Other Cells Onair
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Check NRCELL be added
    Log To Console    Step ${index}: Check NRCELL be added
    ${after_added_nrcells}    coam.Get Ids For All    NRCEL
    ${added_nrcells}    Copy List    ${after_added_nrcells}
    Remove Values From List    ${added_nrcells}    @{init_nrcells}
    Sort List    ${added_nrcells}
    Lists Should Be Equal    ${deleted_nrcells}    ${added_nrcells}
    ${after_added_nrcells_count}    Evaluate    len(${after_added_nrcells})
    Should Be Equal As Integers    ${origin_nrcell_count}    ${after_added_nrcells_count}

Step ${index}: Check Channels and Channel Groups Auto Created
    Log To Console    Step ${index}: Check Channels and Channel Groups Auto Created
    Selenium Login
    ${nrcell_name}    Fetch From Right    ${selected_maa_nrcell}    /
    ${channelgroup_name}    Fetch From Right    ${auto_create_channelgroup}    /
    ${TX_num}    ${RX_num}    Get MAA Cell TRX Num From Detailed Site View Via Selenium    ${nrcell_name}    ${channelgroup_name}
    ${type}    Set Variable    ${nrCellType_ui.replace('DL','-').replace('UL','').split('-')}
    Should Be Equal As Integers    ${TX_num}    ${type[0]}
    #Should Be Equal As Integers    ${RX_num}    ${type[-1]}
    Should Be Equal As Integers    ${RX_num}    ${expect_rx_num}
    Selenium Logout

Step ${index}: Check RF Diagnostic Test Result
    Log To Console    Step ${index}: Check RF Diagnostic Test Result
    Run RF Diagnostic Test    ${selected_maa_nrcell_id}    NR
    Get And Check RF Diagnostic Test Result 5G
    Run Keyword And Ignore Error    Clean Up Test Object

Step ${index}: Provision the backup plan
    Log To Console     Step ${index}: Provision the backup plan
    NetAct Provision Plan    plan_name=${plan_for_recovery}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    NetAct Provision Plan    plan_name=${name_bu}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Set Test Variable    ${RECOVERY_FLAG}    ${False}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log To Console    Step ${index}: Check final number and state of Cells and RMs
    Final Checks SyVe

Check RMOD Supoort mMimo
    [Arguments]     ${rmod_pro_name}
    FOR    ${prefix}    IN    @{MMA_RMOD_PREFIX}
        ${is_support}    Run Keyword And Return Status    Should Start With    ${rmod_pro_name}    ${prefix}
        Return From Keyword If    ${is_support}    True
    END
    [Return]     False

Check Other Cells Onair
    FOR    ${item}    IN    @{Other_NRCELL_list}
        coam.Assert    NRCEL    ${item}    ${cells_NR_expected_state}    timeout=50s
    END
    ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
    ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
    ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
    ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status    coam.Assert Every
    ...    GNCEL    ${cells_GSM_expected_state}
    ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status    coam.Assert Every
    ...    WNCEL    ${cells_WCDMA_expected_state}
    ${lncell_onair}    Run Keyword If    ${lncell}    Run Keyword And Return Status    coam.Assert Every
    ...    LNCEL    ${cells_LTE_expected_state}
    Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
    Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
    Run Keyword If    ${lncell}    Should Be True    ${lncell_onair}

Clean Up Test Object
    ${plan_name}    Set Variable    MRBTS-${mrbts_id}_delete_TEST_obj
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${plan_name}    ${plan}
    ${plan}    NetAct Create Plan    ${plan_name}    Clean Up Test Obj
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TEST-1"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=${MRBTS_DN}/MNL-1/MNLENT-1/TEST-1   operation=DELETE    &{EMPTY}
    NetAct Provision Plan    plan_name=${plan_name}   dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_bu}
    Run Keyword If    ${RECOVERY_FLAG}
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
