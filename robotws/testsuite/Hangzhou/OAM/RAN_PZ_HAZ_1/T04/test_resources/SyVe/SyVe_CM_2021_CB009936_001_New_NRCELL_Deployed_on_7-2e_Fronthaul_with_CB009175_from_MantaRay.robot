*** Settings ***
Documentation       Test case for SyVe_CM_CB009936_001
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${RECOVERY_FLAG}           ${False}
#@{CB009936_RMOD_TYPE}    AVQD

*** Keywords ***
SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    RAN_ST_CB009936_001_CM_New NRCELL deployed on 7-2e fronthaul with CB009175 defined approach for channel configuration
    ...
    ...    Pass criteria: NRCELL is added and deployed on 7-2e fronthaul with CB009175 successfully
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.02.2025
    ...    *******************
    ...    Test case flowchart
    ...    *******************

    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Random Select NRCELL
    Step 5: Delete Selected NRCELL For Env Preparation
    Step 6: Modify Plan To Create 72e NRCELL Use Simplified Method
    Step 7: Provision Plan
    Step 8: Check final BTS state
    Step 9: Check NRCELL be added
    Step 10: Check Channels and Channel Groups Auto Created
    Step 11: Check RF Diagnostic Test Result
    Step 12: Provision the backup plan
    Step 13: Check final alarms status from WebEM
    Step 14: Check final alarms status from Netact
    Step 15: Check final BTS state
    Step 16: Check final number and state of Cells and RMs

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

Step ${index}: Random Select NRCELL
    Log To Console    Step ${index}: Random Select NRCELL
    #Updated 2025-8-13
    ${dic_bts_infor}    coam.Get Bts Info
    ${list_rmod_infor}    Set Variable    ${dic_bts_infor["radioModules"]["rmod"]}
    ${rmods_cells_mapping}    Get Relationship Between RMODs And Cells
    ${CB009936_cells_list}    Create List
    FOR    ${rmod_infor}    IN    @{list_rmod_infor}
        ${dn}    Set Variable    ${rmod_infor["id"]["configuration"]}
        ${dn_internal}    Set Variable    ${rmod_infor["id"]["internal"]}
        ${productName}    Set Variable    ${rmod_infor["productName"]}
        ${nrcell_list}    Set Variable    ${rmods_cells_mapping["${dn_internal}"]["activeNrCellsList"]}
        ${is_CB009936_RMOD}    Run Keyword And Return Status    List Should Contain Value    ${CB009936_RMOD_TYPE}    ${productName}
        Run Keyword If    ${is_CB009936_RMOD}    Append To List    ${CB009936_cells_list}    @{nrcell_list}
    END
    Should Be True    "${CB009936_cells_list.__len__()}">"${0}"    No NRCELLs found for CB009936 RMODs
    ${cell_list}    coam.Get Cell List
    ${nr_cell_list}    Set Variable    ${cell_list['cells']['nr']}
    ${all_nrcells_list}    Create List
    FOR    ${nr_cell}    IN    @{nr_cell_list}
        ${is_CB009936_cell}    Run Keyword And Return Status    List Should Contain Value    ${CB009936_cells_list}    ${nr_cell['id']['internal']}
        Run Keyword If    ${is_CB009936_cell}    Append To List    ${all_nrcells_list}    ${nr_cell['id']['configuration']}
    END
    #${selected_nrcell_info}    Evaluate    random.choice(${nr_cell_list})    modules=random, sys
    #Set Test Variable    ${selected_nrcell}    ${selected_nrcell_info['id']['configuration']}
    ${selected_nrcell}    Evaluate    random.choice(${all_nrcells_list})    modules=random, sys
    Should Not Be Empty    ${selected_nrcell}    No NRCELLs found for CB009936 RMODs
    ${selected_nrcell_id}    Fetch From Right    ${selected_nrcell}    -
    Set Test Variable    ${selected_nrcell_id}
    ${other_nrcell_list}    Copy List    ${all_nrcells_list}
    Remove Values From List    ${other_nrcell_list}    ${selected_nrcell}
    Set Test Variable    ${all_nrcells_list}
    Set Test Variable    ${other_nrcell_list}
    Set Test Variable    ${selected_nrcell}
#    FOR    ${item}    IN    @{nr_cell_list}
#        ${nrcell}    Set Variable    ${item['id']['configuration']}
#        Append To List    ${all_nrcells_list}    ${nrcell}
#    END
#    ${other_nrcell_list}    Copy List    ${all_nrcells_list}
#    Remove Values From List    ${other_nrcell_list}    ${selected_nrcell}
#    Set Test Variable    ${all_nrcells_list}
#    Set Test Variable    ${other_nrcell_list}

Step ${index}: Delete Selected NRCELL For Env Preparation
    Log To Console    Step ${index}: Delete Selected NRCELL For Env Preparation
    NetAct CM Upload    dist_names=${MRBTS_DN}
    ${delete_cell_plan_name}    Create Plan To Delete NRCELL Via NetAct    ${selected_nrcell}
    Set Test Variable    ${delete_cell_plan_name}
    Set Test Variable    ${delete_cell_backup_plan_name}    ${delete_cell_plan_name}_backup
    NetAct Provision Plan    plan_name=${delete_cell_plan_name}    dist_names=${MRBTS_DN}    backup_plan_name=${delete_cell_backup_plan_name}
    ...    create_backup_plan=True     provisioning_operation=activate
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

Step ${index}: Modify Plan To Create 72e NRCELL Use Simplified Method
    Log To Console    Step ${index}: Modify Plan To Create 72e NRCELL Use Simplified Method
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${delete_cell_backup_plan_name}.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${delete_cell_backup_plan_name}   operation_type=plan
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/${delete_cell_backup_plan_name}.csv
    ${lcelnr_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@class="LCELNR"]
    ${lcelnr_dn}    Set Variable    ${lcelnr_items["distName"]}
    ${channelgroup_dn_list}    ${auto_create_channelgroup}    Get Auto Create Obj Info From SCF
    ...    obj_xpath=.//managedObject[@class="CHANNELGROUP"]    scf_xml=${Test Results Dir}/NetActLogs/${delete_cell_backup_plan_name}.csv
    ${channel_dn_list}    ${auto_create_channel}    Get Auto Create Obj Info From SCF
    ...    obj_xpath=.//managedObject[@class="CHANNEL"]    scf_xml=${Test Results Dir}/NetActLogs/${delete_cell_backup_plan_name}.csv
    ${obj_to_remove}    Combine Lists    ${channelgroup_dn_list}    ${channel_dn_list}
    Set Test Variable    ${auto_create_channelgroup}
    L_XML.Set Element Text    ${scf_xml}    1    \r\n
    ...    cmData/managedObject[@distName="${lcelnr_dn}"]/p[@name="actSimplChConfMAA"]
    ${params}    Get Dictionary Keys    ${enable_features_params}
    FOR    ${param}  IN    @{params}
        ${element}   L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="PLMN-PLMN/${selected_nrcell}"]/p[@name="${param}"]
        Run Keyword If    '${element}' == '[${EMPTY}]'
        ...    L_XML.Add Element    ${scf_xml}    <p name="${param}"/>    xpath=cmData/managedObject[@distName="PLMN-PLMN/${selected_nrcell}"]
        L_XML.Set Element Text    ${scf_xml}    ${enable_features_params["${param}"]}    \r\n
        ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_nrcell}"]/p[@name="${param}"]
    END
    FOR    ${obj}    IN    @{obj_to_remove}
        L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@distName="${obj}"]    remove_tail=${True}
    END
    ${timestamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    Should Be String    new_plan_add_nrcell_MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${simp_add_new_72e_nrcell_plan}    new_plan_add_nrcell_MRBTS-${mrbts_id}_${timestamp}
    L_XML.Save XML    ${scf_xml}    ${Test Results Dir}/NetActLogs/${simp_add_new_72e_nrcell_plan}.csv
    NetAct Import Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${simp_add_new_72e_nrcell_plan}.csv
    ...    plan_name=${simp_add_new_72e_nrcell_plan}
    ${mo_params}    Create Dictionary
    FOR    ${cell}    IN    @{other_nrcell_list}
        Set To Dictionary    ${mo_params}    ${cell}     ${enable_features_params}
        ${nrcell_lcrid}    Get CM Parameter Value From SCF    ${BTS_scf_initial}    ${cell}    lcrId
        ${nrcell_cellmapping_str}    catenate    SEPARATOR=    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-    ${nrcell_lcrid}
        Set To Dictionary    ${mo_params}    ${nrcell_cellmapping_str}    ${enable_CB009175}
    END
    ${simp_add_new_72e_nrcell_plan}    Create Plan To Enable CB009936 And CB009175 On NetAct
    ...    ${other_nrcell_list}   ${mo_params}    ${simp_add_new_72e_nrcell_plan}
    Set Test Variable    ${simp_add_new_72e_nrcell_plan}

Step ${index}: Provision Plan
    Log To Console    Step ${index}: Provision Plan
    ${timestamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${plan_for_recovery}    MRBTS-${mrbts_id}_${timestamp}_recovery
    NetAct Provision Plan    plan_name=${simp_add_new_72e_nrcell_plan}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=${plan_for_recovery}   create_backup_plan=True    provisioning_operation=activate

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
    FOR    ${nrcell_dn}    IN    @{all_nrcells_list}
        ${nrcell_name}    Fetch From Right    ${nrcell_dn}    /
        ${channelgroup_name}    Fetch From Right    ${auto_create_channelgroup}    /
        ${TX_num}    ${RX_num}    Get MAA Cell TRX Num From Detailed Site View Via Selenium    ${nrcell_name}    ${channelgroup_name}
        ${type}    Set Variable    ${expected_trx.replace('DL','-').replace('UL','').split('-')}
        Should Be Equal As Integers    ${TX_num}    ${type[0]}
        Should Be Equal As Integers    ${RX_num}    ${type[-1]}
    END
    [Teardown]    Selenium Logout

Step ${index}: Check RF Diagnostic Test Result
    Log To Console    Step ${index}: Check RF Diagnostic Test Result
    FOR    ${cell_dn}    IN    @{all_nrcells_list}
        ${nrcell_id}    Fetch From Right    ${cell_dn}    -
        Run RF Diagnostic Test    ${nrcell_id}    NR
        Get And Check RF Diagnostic Test Result 5G
    END
    [Teardown]    Run Keyword And Ignore Error    Clean Up Test Object

Step ${index}: Provision the backup plan
    Log To Console     Step ${index}: Provision the backup plan
    NetAct Provision Plan    plan_name=${plan_for_recovery}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Wait Until Keyword Succeeds    5min    30s    Check SBTS SMOD RMOD Cells Alarms
    NetAct Provision Plan    plan_name=${delete_cell_backup_plan_name}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Wait Until Keyword Succeeds    5min    30s    Check SBTS SMOD RMOD Cells Alarms
    Set Test Variable    ${RECOVERY_FLAG}    ${False}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log To Console    Step ${index}: Check final number and state of Cells and RMs
    Final Checks SyVe

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
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}



TC Setup
    Log To Console    TC Setup
    Common Test Setup
    ${nrCellType_ui}   Set Variable    4DL2UL
    Set Test Variable     ${nrCellType_ui}
    ${trx_mapping}    Create Dictionary    4DL2UL=2DL12UL
    Set Test Variable     ${trx_mapping}
    ${txt_mapping_keys}    Get Dictionary Keys    ${trx_mapping}
    ${selected_key}    Evaluate    random.choice(${txt_mapping_keys})    modules=random, sys
    Set Test Variable    ${expected_trx}    ${trx_mapping["${selected_key}"]}
    ${nrCellType}    Set Variable    ${selected_key.replace('DL','').replace('UL','')}
    ${enable_features_params}    Create Dictionary    nrCellType=${nrCellType}    actEcpri72e=true    actBeamforming=true    numberOfRxBeamforming=16
    ...    numberOfRxPucch=8    actSuperCell=false    actExternalAntennaBF=false
    Set Test Variable     ${enable_features_params}
    ${enable_CB009175}    Create Dictionary    actSimplChConfMAA=true
    Set Test Variable     ${enable_CB009175}

TC Teardown
    Log To Console    TC Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${simp_add_new_72e_nrcell_plan}
    Run Keyword If    ${RECOVERY_FLAG}
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown
