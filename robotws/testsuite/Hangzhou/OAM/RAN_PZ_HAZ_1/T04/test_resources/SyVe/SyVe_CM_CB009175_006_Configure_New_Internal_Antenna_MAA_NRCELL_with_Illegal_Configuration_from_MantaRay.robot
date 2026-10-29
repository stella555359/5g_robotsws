*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
@{MMA_RMOD_PREFIX}    AE    AQ
${nrCellType}   44
${illegal_nrCellType}   12
&{specific_nrbts_param_to_update}   actSaUeBasedAnrEutra=0    actSaUeBasedInterFreqAnrNr=0    actNormVCFallback=0
#${feedback1_1}    Whenever LCELNR-1.actSimplChConfMAA (value: true) is equal to true,
#${feedback1_2}    it is required that there shall be exactly one instance of CHANNELGROUP and CHANNEL and CHANNEL.resourceDN shall be configured
#${feedback2}   Whenever LCELNR-1.actSimplChConfMAA (value: true) is equal to true, it is required that there shall be exactly one instance of CHANNEL

*** Keywords ***
SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    RAN_ST_CB009175_006_CM_Configure new internal antenna MAA NRCELL with illegal configuration from MantaRay
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - TC Preparation
    ...    - Modify Plan To Create MAA NRCELL WIth No Channel And Channel Group Instances
    ...    - Import the plan SyVe
    ...    - Provision Plan And Verify Feedback
    ...    - Modify Plan To Create MAA NRCELL WIth More Than One Channel And Channel Group Instances
    ...    - Import the plan SyVe
    ...    -  Provision Plan And Verify Feedback
    ...    -  Provision the backup plan
    ...    -  Check final BTS state
    ...    -  Check final alarms status from WebEM
    ...    -  Check final alarms status from Netact
    ...    -  Check final BTS state
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
    Step 6: Modify Plan To Create MAA NRCELL WIth No Channel And Channel Group Instances
    Step 7: Import the plan SyVe
    Step 8: Provision Plan And Verify Error Feedback
    Step 9: Modify Plan To Create MAA NRCELL WIth More Than One Channel And Channel Group Instances
    Step 10: Import the plan SyVe
    Step 11: Provision Plan And Verify Error Feedback
    Step 12: Provision the backup plan
    Step 13: Check final BTS state
    Step 14: Check final alarms status from WebEM
    Step 15: Check final alarms status from Netact
    Step 16: Check final BTS state
    Step 17: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
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
    Log To Console    Selected NRCell:${selected_nrcell_inter_id}
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
    #Create Plan To Delete Selected NRCELL
    ${name}    Create Plan To Delete NRCELL Via NetAct    ${selected_maa_nrcell}
    Set Test Variable    ${name}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan
    ${timestamp}    Generate Formatted Timestamp
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name_bu}    MRBTS-${mrbts_id}_${timestamp}_backup
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name_bu}    create_backup_plan=True
    ...    provisioning_operation=activate
    ${init_nrcells}    coam.Get Ids For All    NRCEL
    ${deleted_nrcells}    Copy List    ${NRBTS_cell_ids}
    Remove Values From List    ${deleted_nrcells}    @{init_nrcells}
    Set Test Variable    ${deleted_nrcells}
    ${origin_nrcell_count}    Evaluate    len(${NRBTS_cell_ids})
    ${current_nrcell_count}    Evaluate    len(${init_nrcells})
    Should Be Equal As Integers    ${origin_nrcell_count}    ${current_nrcell_count+1}
    Set Test Variable    ${origin_nrcell_count}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_bu}.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name_bu}   operation_type=plan
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/${name_bu}.csv
    ${lcelnr_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@class="LCELNR"]
    ${lcelnr_dn}    Set Variable    ${lcelnr_items["distName"]}
    ${channelgroup_dn_list}    Get Auto Create Obj Info    ${scf_xml}    .//managedObject[@class="CHANNELGROUP"]
    ${channel_dn_list}    Get Auto Create Obj Info    ${scf_xml}    .//managedObject[@class="CHANNEL"]
    Set Test Variable    ${lcelnr_dn}
    Set Test Variable    ${channelgroup_dn_list}
    Set Test Variable    ${channel_dn_list}
    Set Test Variable    ${feedback1_1}    Whenever ${lcelnr_dn.split("/")[-1]}.actSimplChConfMAA (value: true) is equal to true,it is required that
    Set Test Variable    ${feedback1_2}   there shall be exactly one instance of CHANNELGROUP and CHANNEL and CHANNEL.resourceDN shall be configured
    Set Test Variable    ${feedback2_1}   Whenever ${lcelnr_dn.split("/")[-1]}.actSimplChConfMAA (value: true) is equal to true,
    Set Test Variable    ${feedback2_2}   it is required that there shall be exactly one instance of CHANNEL


Step ${index}: Modify Plan To Create MAA NRCELL WIth No Channel And Channel Group Instances
    Log To Console    Step ${index}: Modify Plan To Create MAA NRCELL WIth No Channel And Channel Group Instances
    ${obj_to_remove}    Combine Lists    ${channelgroup_dn_list}    ${channel_dn_list}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml_content}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/${name_bu}.csv
    L_XML.Set Element Text    ${xml_content}    1    \r\n
    ...    cmData/managedObject[@distName="${lcelnr_dn}"]/p[@name="actSimplChConfMAA"]
    L_XML.Set Element Text    ${xml_content}    ${nrCellType}    \r\n
    ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_maa_nrcell}"]/p[@name="nrCellType"]
    L_XML.Set Element Text    ${xml_content}    0    \r\n
    ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_maa_nrcell}"]/p[@name="actSuperCell"]
    L_XML.Set Element Text    ${xml_content}    0    \r\n
    ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_maa_nrcell}"]/p[@name="actExternalAntennaBF"]
    L_XML.Set Element Text    ${xml_content}    1    \r\n
    ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_maa_nrcell}"]/p[@name="actBeamforming"]
    L_XML.Set Element Text    ${xml_content}    0    \r\n
    ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_maa_nrcell}"]/p[@name="actAdaptiveReTxResMcsEnh"]
    FOR    ${obj}    IN    @{obj_to_remove}
        L_XML.Remove Elements    ${xml_content}    cmData/managedObject[@distName="${obj}"]    remove_tail=${True}
    END
    ${timestamp}    Generate Formatted Timestamp
    Should Be String    new_plan_add_nrcell_MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${simp_add_new_maa_nrcell_plan}    new_plan_add_nrcell_MRBTS-${mrbts_id}_${timestamp}
    L_XML.Save XML    ${xml_content}    ${Test Results Dir}/NetActLogs/${simp_add_new_maa_nrcell_plan}.csv

Step ${index}: Modify Plan To Create MAA NRCELL WIth More Than One Channel And Channel Group Instances
    Log To Console    Step ${index}: Modify Plan To Create MAA NRCELL WIth More Than One Channel And Channel Group Instances
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml_content}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/${name_bu}.csv
    ${channelgroup_dn_list_copy}    Copy List    ${channelgroup_dn_list}
    ${channel_dn_list_copy}    Copy List    ${channel_dn_list}
    ${left_num}    Set Variable If    ${channelgroup_dn_list_copy.__len__()}>1    2    1
    Remove Need Created DNs    ${channelgroup_dn_list_copy}    ${left_num}
    FOR    ${channelgroup_dn}    IN    @{channelgroup_dn_list}
        ${channel_dn_for_channelgroup}    L_XML.Get Elements    ${xml_content}    .//managedObject[contains(@distName,"${channelgroup_dn}/CHANNEL-")]
        ${left_num}    Set Variable If    ${channel_dn_for_channelgroup.__len__()}>1    2    1
        Remove Need Created DNs   ${channel_dn_list_copy}    ${left_num}
    END
    ${obj_to_remove}    Combine Lists    ${channelgroup_dn_list_copy}    ${channel_dn_list_copy}
    L_XML.Set Element Text    ${xml_content}    1    \r\n
    ...    cmData/managedObject[@distName="${lcelnr_dn}"]/p[@name="actSimplChConfMAA"]
    L_XML.Set Element Text    ${xml_content}    ${nrCellType}    \r\n
    ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_maa_nrcell}"]/p[@name="nrCellType"]
    L_XML.Set Element Text    ${xml_content}    0    \r\n
    ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_maa_nrcell}"]/p[@name="actSuperCell"]
    L_XML.Set Element Text    ${xml_content}    0    \r\n
    ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_maa_nrcell}"]/p[@name="actExternalAntennaBF"]
    L_XML.Set Element Text    ${xml_content}    1    \r\n
    ...    cmData/managedObject[@distName="PLMN-PLMN/${selected_maa_nrcell}"]/p[@name="actBeamforming"]
#    FOR    ${obj}    IN    @{obj_to_remove}
#        L_XML.Remove Elements    ${xml_content}    cmData/managedObject[@distName="${obj}"]    remove_tail=${True}
#    END
    ${timestamp}    Generate Formatted Timestamp
    Should Be String    new_plan_add_nrcell_MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${simp_add_new_maa_nrcell_plan}    new_plan_add_nrcell_MRBTS-${mrbts_id}_${timestamp}
    L_XML.Save XML    ${xml_content}    ${Test Results Dir}/NetActLogs/${simp_add_new_maa_nrcell_plan}.csv

Step ${index}: Import the plan SyVe
    Log To Console    Step ${index}: Import the plan SyVe
    NetAct Import Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${simp_add_new_maa_nrcell_plan}.csv
    ...    plan_name=${simp_add_new_maa_nrcell_plan}

Step ${index}: Provision Plan And Verify Error Feedback
    Log To Console    Step ${index}: Provision Plan And Verify Error Feedback
    ${msg}    Set Variable If    ${index}=="8"    ${feedback1_1} ${feedback1_2}    ${feedback2_1} ${feedback2_2}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${simp_add_new_maa_nrcell_plan} -DN ${MRBTS_DN} -createBackupPlan false
    ${cmd2}    Set Variable    -backupPlanName None -v -provisioningOperation activate
    ${cmd3}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    Sleep    10s
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    5G/LTE/SRAN plan provision failed
    Should Contain    ${result_Activate}    ${msg}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${simp_add_new_maa_nrcell_plan}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log To Console    Step ${index}: Check final number and state of Cells and RMs
    Final Checks SyVe

Step ${index}: Provision the backup plan
    Log To Console   Step ${index}: Provision the backup plan
    NetAct Provision Plan    plan_name=${name_bu}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Remove Need Created DNs
    [Arguments]     ${dn_list}    ${num_to_remove}
    FOR    ${index}    IN RANGE    0   ${num_to_remove}
        Remove Values From List    ${dn_list}     ${dn_list[0]}
    END

Get Auto Create Obj Info
    [Arguments]     ${scf_xml}    ${obj_xpath}
    ${obj_elementa}    L_XML.Get Elements    ${scf_xml}    ${obj_xpath}
    ${obj_dn_list}    Create List
    FOR    ${item}    IN    @{obj_elementa}
        ${dn}    L_XML.Get Element Attribute    ${item}    distName
        Append To List    ${obj_dn_list}    ${dn}
    END
    Sort List    ${obj_dn_list}
    [Return]    ${obj_dn_list}

Check RMOD Supoort mMimo
    [Arguments]     ${rmod_pro_name}
    FOR    ${prefix}    IN    @{MMA_RMOD_PREFIX}
        ${is_support}    Run Keyword And Return Status    Should Start With    ${rmod_pro_name}    ${prefix}
        Return From Keyword If    ${is_support}    True
    END
    [Return]     False

Create Plan To Delete Selected NRCELL
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${elements_for_nrcell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${selected_maa_nrcell}")]
    ${selected_nrcell_lcrid}    Get CM Parameter Value From SCF    ${scf_path}    ${selected_maa_nrcell}    lcrId
    ${nrcell_cellmapping_str}    catenate    SEPARATOR=    LCELNR-    ${selected_nrcell_lcrid}
    ${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[contains(@distName,"${nrcell_cellmapping_str}")]
    Set Test Variable    ${nrcell_cellmapping_str}
    ${elements_for_nrcellGroup}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]
    ${cellgroup_dns}    Create List
    FOR    ${cellgroup}    IN    @{elements_for_nrcellGroup}
        ${MO_items}    L_XML.Get Element Attributes    ${cellgroup}
        Append To List    ${cellgroup_dns}    ${MO_items}
    END
    FOR    ${cellgroup}    IN    @{elements_for_nrcellGroup}
        ${MO_items}    L_XML.Get Element Attributes    ${cellgroup}
        ${nrCellList}    L_XML.Get Elements Texts    ${scf_xml}   .//managedObject[@distName="${MO_items['distName']}"]/list[@name="nrCellList"]
        ${formatedNRCellList}    Get Formatted NRCellList    ${nrCellList}
        ${isSelected_nrcell_cellgroup}    Run Keyword And Return Status    List Should Contain Value
        ...      ${formatedNRCellList}    ${selected_maa_nrcell_id}
        Continue For Loop If    not ${isSelected_nrcell_cellgroup}
        Remove Values From List    ${formatedNRCellList}    ${selected_maa_nrcell_id}
        Set Test Variable    ${formatedNRCellList}
        ${len}    Get Length    ${formatedNRCellList}
        ${nrcellgroup_operation}    Set Variable If    '${len}'=='0'   delete    update
        Set Test Variable    ${nrcellgroup_operation}
        Set Test Variable    ${selected_nrcellgroup}    ${MO_items}
        Exit For Loop
    END
    Remove Values From List    ${cellgroup_dns}    ${selected_nrcellgroup}
    ${other_cellgroup_ids}    Create List
    FOR    ${cellgroup}    IN    @{cellgroup_dns}
        ${distName}    Set Variable    ${cellgroup['distName']}
        ${grp_id}    Fetch From Right    ${distName}    -
        Append To List    ${other_cellgroup_ids}    ${grp_id}
    END
    ${elements_to_delete}    Combine Lists    ${elements_for_nrcell}    ${elements_for_cellMapping}
    FOR    ${element}    IN    @{elements_to_delete}
        ${MO_items}    L_XML.Get Element Attributes    ${element}
        ${managed_object}    netact.Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
        ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${MO_items["distName"]}
        ...    operation=DELETE
        ${status}    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan}
        ...    mo_id=PLMN-PLMN/${MO_items["distName"]}
        Run Keyword If    ${status}    Run Keywords    Log    MO successfully created: ${managed_object}    console=True
        ...    AND    Log    Parameters were set with plan ${plan}    console=True
        ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
        ...    AND    Fail    MO creation failed!
    END
    ${element_nrdu}    L_XML.Get Elements    ${scf_xml}     .//managedObject[contains(@distName,"${NRDU_NAME}")]
    ${MO_NRDU}    L_XML.Get Element Attributes    ${element_nrdu[0]}
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_NRDU['class']}
    ...    meta_version=${MO_NRDU['version']}    mo_id=PLMN-PLMN/${MO_NRDU["distName"]}    refNrCellGroup=${other_cellgroup_ids}
    ${nrbts}    L_XML.Get Element    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    ${MO_NRBTS}    L_XML.Get Element Attributes    ${nrbts}
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_NRBTS['class']}
    ...    meta_version=${MO_NRBTS['version']}    mo_id=PLMN-PLMN/${MO_NRBTS["distName"]}    &{specific_nrbts_param_to_update}
    Run Keyword If    '${nrcellgroup_operation}'=='delete'    NetAct Create Managed Object    plan=${plan}
    ...    meta_class=${selected_nrcellgroup['class']}    meta_version=${selected_nrcellgroup['version']}
    ...    mo_id=PLMN-PLMN/${selected_nrcellgroup["distName"]}    operation=DELETE    &{EMPTY}
    ...    ELSE    NetAct Create Managed Object    plan=${plan}    meta_class=${selected_nrcellgroup['class']}
    ...    meta_version=${selected_nrcellgroup['version']}    mo_id=PLMN-PLMN/${selected_nrcellgroup["distName"]}   nrCellList=${formatedNRCellList}

Get Formatted NRCellList
    [Arguments]     ${nrCellList}
    ${formatedNRCellList}    Create List
    FOR    ${item}    IN    @{nrCellList}
        ${cellid}    Set Variable    ${item.strip()}
        Append To List    ${formatedNRCellList}    ${cellid}
    END
    [Return]     ${formatedNRCellList}

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_bu}
    ${final_nrcells}    Wait Until Keyword Succeeds    5x    5s    coam.Get Ids For All    NRCEL
    Run Keyword If    ${final_nrcells.__len__()}!=${origin_nrcell_count}
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown