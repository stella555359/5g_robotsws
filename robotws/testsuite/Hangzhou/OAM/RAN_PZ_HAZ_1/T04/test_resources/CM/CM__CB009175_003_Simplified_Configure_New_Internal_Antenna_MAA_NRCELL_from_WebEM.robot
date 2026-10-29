*** Settings ***
Documentation       Test suite for RAN_ST_CB009175_003
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
@{MMA_RMOD_PREFIX}    AE    AQ
${nrCellType_ui}   4DL4UL
&{mandatory_cell_param_to_update_ui}    actSuperCell=false    actExternalAntennaBF=false    actBeamforming=true
#&{specific_nrbts_param_to_update_ui}    Activate ANR for EN-DC with resolution of unknown cells=false
#...    Activate robust header compression=false
#...    Activate ANR for SA with resolution of unknown E-UTRA cells=false
#...    Activate ANR for SA with resolution of unknown cells based on inter frequency UE measurements=false
#...    Activate normal voice call fallback to LTE=false
${RECOVERY_FLAG}           ${False}
${expect_rx_num}     68
@{Excluded_NRCells_RT}    NRCELL_R-302    # NRCell runtime DNs to be excluded in selected NRcells list

*** Keywords ***
CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Source case:
    ...   RAN_ST_CB009175_003_CM_Configure new internal antenna MAA NRCELL Channel Groups and Channels using Simplified method from WebEM
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.08.2023 - Commit to robotws
    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Fetch And Delete MAA NRCELL
    Step 2: Create MAA NRCELL Use Simplified Method
    Step 3: Check Cell Should Be Exist
    Step 4: Check Channels and Channel Groups Auto Created
    Step 5: Check RF Diagnostic Test Result

SetUp
    Log To Console    SetUp
    Common Test Setup SBTS
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable   ${mrbts_id}
    Selenium Login    https://192.168.255.129

TearDown
    Log To Console    TearDown
    Selenium Logout
    Run Keyword If    ${RECOVERY_FLAG}
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown SBTS

Step ${index}: Fetch And Delete MAA NRCELL
    Log To Console    Step ${index}: Fetch And Delete MAA NRCELL
    ${NRBTS_cell_ids}    coam.Get Ids For All    NRCEL
    Set Test Variable    ${NRBTS_cell_ids}
    Remove One MAA NRCell By PE
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

Remove One MAA NRCell By PE
    Log To Console    Remove One MAA NRCell By PE
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
    FOR   ${cell}    IN    @{all_maa_nrcell_id_list}
        ${existed}    Run Keyword And Return Status    List Should Contain Value    ${Excluded_NRCells_RT}    ${cell.split("/")[-1]}
        Run Keyword If    ${existed}    Remove Values From List    ${all_maa_nrcell_id_list}    ${cell}
    END
    Log To Console    All MAA NRCells:${all_maa_nrcell_id_list}
    ${selected_nrcell_inter_id}    Evaluate    random.choice(${all_maa_nrcell_id_list})    modules=random, sys
    ${cell_mapping}    Fetch ID Mapping From Admin For Cells    NRBTS    ${selected_nrcell_inter_id}    internal
    Set Test Variable    ${selected_maa_nrcell}    ${cell_mapping['configuration']}
    Log To Console    Selected MAA NRCell:${selected_maa_nrcell}
    ${selected_maa_nrcell_id}    Fetch From Right    ${selected_maa_nrcell}    -
    Set Test Variable    ${selected_maa_nrcell_id}
    ${lcrId}    ${cellGrp_id}    NR Cell Deletion Via Selenium    ${selected_maa_nrcell}
    Set Test Variable    ${lcrId}
    Set Test Variable    ${cellGrp_id}
    Wait Until Keyword Succeeds    10 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Step ${index}: Create MAA NRCELL Use Simplified Method
    LOG    Step ${index}: Create MAA NRCELL Use Simplified Method   console=${True}
     Modify SCF For Create MAA NRCELL Use Simplified Method
     NR Cell Addition Via Selenium    ${selected_maa_nrcell}    ${lcrId}    ${Test Results Dir}/BTSFiles/${simp_add_new_maa_nrcell_plan}.xml
     Wait Until Keyword Succeeds    10 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Modify SCF For Create MAA NRCELL Use Simplified Method
    Log To Console    Modify Backup Plan For Create MAA NRCELL Use Simplified Method
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${channelgroup_dn_list}    ${auto_create_channelgroup}    Get Auto Create Obj Info From SCF
    ...    obj_xpath=.//managedObject[@class="com.nokia.srbts.mnl:CHANNELGROUP"][contains(@distName,"LCELNR-${lcrId}")]
    ${channel_dn_list}    ${auto_create_channel}    Get Auto Create Obj Info From SCF
    ...    obj_xpath=.//managedObject[@class="com.nokia.srbts.mnl:CHANNEL"][contains(@distName,"LCELNR-${lcrId}/CHANNELGROUP")]
    ${obj_to_remove}    Combine Lists    ${channelgroup_dn_list}    ${channel_dn_list}
    Set Test Variable    ${auto_create_channelgroup}
    L_XML.Set Element Text    ${scf_xml}    true    \r\n
    ...    cmData/managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}"]/p[@name="actSimplChConfMAA"]
    L_XML.Set Element Text    ${scf_xml}    ${nrCellType_ui}    \r\n
    ...    cmData/managedObject[@distName="${selected_maa_nrcell}"]/p[@name="nrCellType"]
    ${params}    Get Dictionary Keys    ${mandatory_cell_param_to_update_ui}
    FOR    ${param}  IN    @{params}
        L_XML.Set Element Text    ${scf_xml}    ${mandatory_cell_param_to_update_ui["${param}"]}    \r\n
        ...    cmData/managedObject[@distName="${selected_maa_nrcell}"]/p[@name="${param}"]
    END
    FOR    ${obj}    IN    @{obj_to_remove}
        L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@distName="${obj}"]    remove_tail=${True}
    END
    ${timestamp}    Generate Formatted Timestamp
    Should Be String    new_plan_add_nrcell_MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${simp_add_new_maa_nrcell_plan}    new_plan_add_nrcell_MRBTS-${mrbts_id}_${timestamp}
    L_XML.Save XML    ${scf_xml}    ${Test Results Dir}/BTSFiles/${simp_add_new_maa_nrcell_plan}.xml
    ${file_content}    OperatingSystem.Get File    ${Test Results Dir}/BTSFiles/${simp_add_new_maa_nrcell_plan}.xml
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Save XML    ${scf_xml}    ${Test Results Dir}/BTSFiles/${simp_add_new_maa_nrcell_plan}.xml

Step ${index}: Check Cell Should Be Exist
    log    Step ${index}: Check Cell Should Be Exist    console=${True}
    ${cell_existed}    Run Keyword And Return Status    Wait Until Keyword Succeeds    2min    15s
    ...    selenium_sbts.get_cell_info    cell_idx=${selected_maa_nrcell.split("/")[-1].split("-")[-1]}    technology=NR
    Should Be True    ${cell_existed}

Step ${index}: Check Channels and Channel Groups Auto Created
    Log To Console    Step ${index}: Check Channels and Channel Groups Auto Created
    ${nrcell_name}    Fetch From Right    ${selected_maa_nrcell}    /
    ${channelgroup_name}    Fetch From Right    ${auto_create_channelgroup}    /
    ${TX_num}    ${RX_num}    Get MAA Cell TRX Num From Detailed Site View Via Selenium    ${nrcell_name}    ${channelgroup_name}
    ${type}    Set Variable    ${nrCellType_ui.replace('DL','-').replace('UL','').split('-')}
    Should Be Equal As Integers    ${TX_num}    ${type[0]}
    Should Be Equal As Integers    ${RX_num}    ${expect_rx_num}

Step ${index}: Check RF Diagnostic Test Result
    Log To Console    Step ${index}: Check RF Diagnostic Test Result
    Run RF Diagnostic Test    ${selected_maa_nrcell_id}    NR
    Get And Check RF Diagnostic Test Result 5G

Check RMOD Supoort mMimo
    [Arguments]     ${rmod_pro_name}
    FOR    ${prefix}    IN    @{MMA_RMOD_PREFIX}
        ${is_support}    Run Keyword And Return Status    Should Start With    ${rmod_pro_name}    ${prefix}
        Return From Keyword If    ${is_support}    True
    END
    [Return]     False