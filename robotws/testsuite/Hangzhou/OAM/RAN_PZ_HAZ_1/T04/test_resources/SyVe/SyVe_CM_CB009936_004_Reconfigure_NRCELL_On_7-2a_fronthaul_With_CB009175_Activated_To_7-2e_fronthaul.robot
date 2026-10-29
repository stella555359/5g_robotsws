*** Settings ***
Documentation       Test case for SyVe_CM_CB009936_004
...                 Author: Yuyan Xu
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${RECOVERY_FLAG}           ${False}
@{CB009936_RMOD_TYPE}    AVQC
${expect_rx_num}     36

*** Keywords ***
SyVe_CM_CB009936_004_Reconfigure_NRCELL_On_7-2a_fronthaul_With_CB009175_Activated_To_7-2e_fronthaul
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    RAN_ST_CB009936_004_CM_Reconfigure NRCELL deployed on 7-2a fronthaul with CB009175 feature activated to 7-2e fronthaul interface
    ...    Scenario1 of
    ...    RAN_ST_CB009936_005_CM_Reconfigure NRCELL deployed on 7-2a fronthaul with CB009175 feature deactivated to 7-2e fronthaul interface
    ...
    ...    The main steps performed for the test are:
    ...
    ...    Pass criteria: CB009175 endable success, enable CB009936 success on cell(CB009175 already enabled)
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.02.2025
    ...    *******************
    ...    Test case flowchart
    ...    *******************

    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Enable CB009175 On NRCELLs
    Step 5: Check Channels and Channel Groups Auto Created By CB009175
    Step 6: Check RF Diagnostic Test Result
    Step 7: Enable CB009936 On NRCELLs
    Step 8: Check Channels and Channel Groups Auto Created By CB009936
    Step 9: Check RF Diagnostic Test Result
    Step 10: Check final alarms status from WebEM
    Step 11: Check final alarms status from Netact
    Step 12: Check final BTS state
    Step 13: Check final number and state of Cells and RMs


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

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log To Console    Step ${index}: Check final number and state of Cells and RMs
    Final Checks SyVe

Step ${index}: Enable CB009175 On NRCELLs
    Log To Console    Step ${index}: Enable CB009175 On NRCELLs
    ${allCells_DN}    Create List
    ${mo_params}    Create Dictionary
    FOR    ${cell}    IN    @{nr_cell_list}
        Append To List    ${allCells_DN}    ${cell['id']['configuration']}
        Set To Dictionary    ${mo_params}    ${cell['id']['configuration']}    ${enable_CB009175_params}
        ${nrcell_lcrid}    Get CM Parameter Value From SCF    ${BTS_scf_initial}    ${cell['id']['configuration']}    lcrId
        ${nrcell_cellmapping_str}    catenate    SEPARATOR=    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-    ${nrcell_lcrid}
        Set To Dictionary    ${mo_params}    ${nrcell_cellmapping_str}    ${enable_CB009175_LCellNR}
    END
    Set Test Variable    ${allCells_DN}
    ${planName}    Create Plan To Enable CB009936 And CB009175 On NetAct    ${allCells_DN}    ${mo_params}
    NetAct Provision Plan   plan_name=${planName}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=${planName}_backup    create_backup_plan=True    provisioning_operation=activate
    Set Test Variable    ${planName}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Channels and Channel Groups Auto Created By ${Feature}
    Log To Console    Step ${index}: Check Channels and Channel Groups Auto Created By ${Feature}
    Selenium Login    version=${version}
    FOR    ${cell_dn}    IN    @{allCells_DN}
        ${nrcell_name}    Fetch From Right    ${cell_dn}    /
        ${TX_num}    ${RX_num}    Get MAA Cell TRX Num From Detailed Site View Via Selenium    ${nrcell_name}    CHANNELGROUP-1
        Should Be Equal As Integers    ${TX_num}    ${cellType_${Feature.replace('CB00','')}_tx}
        Run keyword If    "${Feature}"=="CB009936"    Should Be Equal As Integers    ${RX_num}    ${cellType_${Feature.replace('CB00','')}_rx}
        ...    ELSE    Should Be Equal As Integers    ${RX_num}    ${expect_rx_num}
    END
    [Teardown]    Selenium Logout


Step ${index}: Check RF Diagnostic Test Result
    Log To Console    Step ${index}: Check RF Diagnostic Test Result
    FOR    ${cell_dn}    IN    @{allCells_DN}
        ${nrcell_id}    Set Variable    ${cell_dn.split("-")[-1]}
        Run RF Diagnostic Test    ${nrcell_id}    NR
        Get And Check RF Diagnostic Test Result 5G
    END

Step ${index}: Enable CB009936 On NRCELLs
    Log To Console    Step ${index}: Enable CB009936 On NRCELLs
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Test Variable    ${planname_9936}    Enable_CB009936_${timestamp}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${planname_9936}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${planname_9936}    ${plan}
    ${plan}    NetAct Create Plan    ${planname_9936}    Automation for ${planname_9936}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    FOR    ${cell_DN}    IN    @{allCells_DN}
        ${mo_attrs}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${cell_DN}"]
        NetAct Create Managed Object    plan=${plan}    meta_class=${mo_attrs['class']}
        ...    meta_version=${mo_attrs['version']}    mo_id=PLMN-PLMN/${cell_DN}    &{enable_CB009936_params}
    END
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${planname_9936}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${planname_9936}    operation_type=plan
    NetAct Provision Plan   plan_name=${planname_9936}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate
    Set Test Variable    ${planname_9936}
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms


TC Setup
    Log To Console    TC Setup
    Common Test Setup
    #${cell_list}    coam.Get Cell List
    #Set Test Variable    ${nr_cell_list}    ${cell_list['cells']['nr']}
    #9175enable 9936disable
    ${cellType_mapping_9175}    Create Dictionary    4DL4UL=4RX4TX    #celltype support CB009175enable&CB009936disable
    ${enable_CB009175_params}    Create Dictionary    actEcpri72e=false    actBeamforming=true    numberOfRxBeamforming=4
    ...    numberOfRxPucch=8    actSuperCell=false    actExternalAntennaBF=false
    ${cellType_9175_keys}    Get Dictionary Keys    ${cellType_mapping_9175}
    ${selected_9175_key}    Evaluate    random.choice(${cellType_9175_keys})    modules=random, sys
    ${cellType_9175}    Set Variable    ${selected_9175_key.replace('DL','-').replace('UL','').split('-')}
    ${9175_type}    Set Variable    ${cellType_mapping_9175["${selected_9175_key}"].replace('RX','-').replace('TX','').split('-')}
    Set Test Variable    ${cellType_9175_rx}    ${9175_type[0]}
    Set Test Variable    ${cellType_9175_tx}    ${9175_type[1]}
    Set To Dictionary    ${enable_CB009175_params}    nrCellType    ${cellType_9175[0]}${cellType_9175[1]}
    Set Test Variable    ${enable_CB009175_params}
    ${enable_CB009175_LCellNR}    Create Dictionary    actSimplChConfMAA=true
    Set Test Variable     ${enable_CB009175_LCellNR}
    #enable9939
    ${cellType_mapping_9936}    Create Dictionary    4DL2UL=12RX2TX    #celltype support CB009175enable&CB009936enable
    ${enable_CB009936_params}    Create Dictionary    actEcpri72e=true    actBeamforming=true    numberOfRxBeamforming=16
    ...    numberOfRxPucch=8    actSuperCell=false    actExternalAntennaBF=false
    ${cellType_9936_keys}    Get Dictionary Keys    ${cellType_mapping_9936}
    ${selected_9936_key}    Evaluate    random.choice(${cellType_9936_keys})    modules=random, sys
    ${cellType_9936}    Set Variable    ${selected_9936_key.replace('DL','-').replace('UL','').split('-')}
    ${9936_type}    Set Variable    ${cellType_mapping_9936["${selected_9936_key}"].replace('RX','-').replace('TX','').split('-')}
    Set Test Variable    ${cellType_9936_rx}    ${9936_type[0]}
    Set Test Variable    ${cellType_9936_tx}    ${9936_type[1]}
    Set To Dictionary    ${enable_CB009936_params}    nrCellType    ${cellType_9936[0]}${cellType_9936[1]}
    Set Test Variable    ${enable_CB009936_params}
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
    Set Test Variable    ${nr_cell_list}    ${cell_list['cells']['nr']}
    FOR    ${nr_cell}    IN    @{nr_cell_list}
        ${is_CB009936_cell}    Run Keyword And Return Status    List Should Contain Value    ${CB009936_cells_list}    ${nr_cell['id']['internal']}
        Run Keyword If    not ${is_CB009936_cell}    Remove Values From List    ${nr_cell_list}    ${nr_cell}
    END
    Should Not Be Empty    "${nr_cell_list.__len__()}">"${0}"    No NRCELLs found for CB009936 RMODs



TC Teardown
    Log To Console    TC Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${planName}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${planName}_backup
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${planname_9936}
    Run Keyword If    ${RECOVERY_FLAG}
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown