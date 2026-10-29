*** Settings ***
Documentation       Test case for SyVe_CM_CB009936_003
...                 Author: Yuyan Xu
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${Operation}    Enable
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
@{CB009936_RMOD_TYPE}    AVQC
#${expect_rx_num}     36

*** Keywords ***
Env_Preparation_Enable_Disable_72e_Configuration
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Enable or disable 72e configuration
    ...
    ...    The main steps performed for the test are:
    ...
    ...    Pass criteria: Disable CB009175 and CB009936 success on cell.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 25.02.2025
    ...    *******************
    ...    Test case flowchart
    ...    *******************

    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Run Keyword If    '${Operation}'=='Enable'    Enable Features On NRCELLs
    ...    ELSE    Disable Features On NRCELLs

Enable Features On NRCELLs
    Log To Console    Enable Features On NRCELLs For Env Preparation
    ${cellType_mapping_9936}    Create Dictionary    4DL2UL=12RX2TX    #celltype support CB009175enable&CB009936enable
    ${enable_features_params}    Create Dictionary    actEcpri72e=true    actBeamforming=true    numberOfRxBeamforming=16
    ...    numberOfRxPucch=8    actSuperCell=false    actExternalAntennaBF=false
    ${cellType_9936_keys}    Get Dictionary Keys    ${cellType_mapping_9936}
    ${selected_9936_key}    Evaluate    random.choice(${cellType_9936_keys})    modules=random, sys
    ${cellType_9936}    Set Variable    ${selected_9936_key.replace('DL','-').replace('UL','').split('-')}
    Set Test Variable    ${cellType}   ${cellType_mapping_9936["${selected_9936_key}"].replace('RX','-').replace('TX','').split('-')}
    Set To Dictionary    ${enable_features_params}    nrCellType    ${cellType_9936[0]}${cellType_9936[1]}
    ${enable_CB009175}    Create Dictionary    actSimplChConfMAA=true
    ${mo_params}    Create Dictionary
    FOR    ${cell}    IN    @{all_nrcells_dn_list}
        Set To Dictionary    ${mo_params}    ${cell}   ${enable_features_params}
        ${nrcell_lcrid}    Get CM Parameter Value From SCF    ${BTS_scf_initial}    ${cell}    lcrId
        ${nrcell_cellmapping_str}    catenate    SEPARATOR=    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-    ${nrcell_lcrid}
        Set To Dictionary    ${mo_params}    ${nrcell_cellmapping_str}    ${enable_CB009175}
    END
    ${planName}    Create Plan To Enable CB009936 And CB009175 On NetAct    ${all_nrcells_dn_list}    ${mo_params}
    NetAct Provision Plan   plan_name=${planName}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=${planName}_backup    create_backup_plan=True    provisioning_operation=activate
    Set Suite Variable    ${planName}
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Check Channels and Channel Groups

Disable Features On NRCELLs
    Log To Console    Disable Features On NRCELLs
    ${has_plan}    Run Keyword And Return Status    Variable Should Exist    ${planName}
    Run Keyword If    not ${has_plan}
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${COMMISSIONING_PATH}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    ...    AND    Return From Keyword
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${planName}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${planName}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${planName}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${planName}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${planName}_backup

Check Channels and Channel Groups
    Log To Console    Check Channels and Channel Groups
    Selenium Login
    FOR    ${cell_dn}    IN    @{all_nrcells_dn_list}
        ${nrcell_name}    Fetch From Right    ${cell_dn}    /
        ${TX_num}    ${RX_num}    Get MAA Cell TRX Num From Detailed Site View Via Selenium    ${nrcell_name}    CHANNELGROUP-1
        Should Be Equal As Integers    ${RX_num}    ${cellType[0]}
        Should Be Equal As Integers    ${TX_num}    ${cellType[1]}
    END
    [Teardown]    Selenium Logout

TC Setup
    Log To Console    TC Setup
    Common Test Setup
    #${cell_list}    coam.Get Cell List
    #${nr_cell_list}    Set Variable    ${cell_list['cells']['nr']}
    #Updated 2025-12-10
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
    Set Test Variable    ${nr_cell_list}    ${cell_list['cells']['nr']}
    FOR    ${nr_cell}    IN    @{nr_cell_list}
        ${is_CB009936_cell}    Run Keyword And Return Status    List Should Contain Value    ${CB009936_cells_list}    ${nr_cell['id']['internal']}
        Run Keyword If    not ${is_CB009936_cell}    Remove Values From List    ${nr_cell_list}    ${nr_cell}
    END
    Should Not Be Empty    "${nr_cell_list.__len__()}">"${0}"    No NRCELLs found for CB009936 RMODs
    #Updated 2025-12-10
    ${all_nrcells_dn_list}    Create List
    FOR    ${item}    IN    @{nr_cell_list}
        ${nrcell}    Set Variable    ${item['id']['configuration']}
        Append To List    ${all_nrcells_dn_list}    ${nrcell}
    END
    Set Test Variable    ${all_nrcells_dn_list}


TC Teardown
    Log To Console    TC Teardown
    Common Test Teardown