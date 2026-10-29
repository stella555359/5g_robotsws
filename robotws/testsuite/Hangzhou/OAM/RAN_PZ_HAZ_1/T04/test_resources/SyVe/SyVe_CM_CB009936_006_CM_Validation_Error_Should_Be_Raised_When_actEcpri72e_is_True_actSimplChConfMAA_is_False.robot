*** Settings ***
Documentation       Test case for SyVe_CM_CB009175_001
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${RECOVERY_FLAG}           ${False}

*** Keywords ***
SyVe_CM_CB009936_006_CM_Validation_Error_Should_Be_Raised_When_actEcpri72e_is_True_actSimplChConfMAA_is_False
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    RAN_ST_CB009936_006_CM_Validation error should be raised when actEcpri72e is true and actSimplChConfMAA is false
    ...    and RAN_ST_CB009936_005_CM_Reconfigure NRCELL deployed on 7-2a fronthaul with CB009175 feature deactivated to 7-2e fronthaul interface
    ...    scenario2
    ...
    ...    Pass criteria: Validation error should be raised when actEcpri72e is true and actSimplChConfMAA is false CB009175 feature is deactivated
    ...    and NRCELL deployed on 7-2e fronthaul with CB009175 feature activated and actEcpri72e is true
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
    Step 4: Create Plan To Enable CB009936
    Step 5: Provision Plan And Check Error
    Step 6: Modify Plan To Enable CB009175
    Step 7: Provision Plan To Enable CB009936 With CB009175
    Step 8: Check Channels and Channel Groups Auto Created
    Step 9: Check RF Diagnostic Test Result
    Step 10: Disable Features On NRCELLs
    Step 11: Check final alarms status from WebEM
    Step 12: Check final alarms status from Netact
    Step 13: Check final BTS state
    Step 14: Check final number and state of Cells and RMs

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

Step ${index}: Create Plan To Enable CB009936
    Log To Console    Step ${index}: Create Plan To Enable CB009936
    ${cell_list}    coam.Get Cell List
    ${nr_cell_list}    Set Variable    ${cell_list['cells']['nr']}
    ${all_nrcells_dn_list}    Create List
    FOR    ${item}    IN    @{nr_cell_list}
        ${nrcell}    Set Variable    ${item['id']['configuration']}
        Append To List    ${all_nrcells_dn_list}    ${nrcell}
    END
    Set Test Variable    ${all_nrcells_dn_list}
    ${timestamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan_name}    NetAct Create Plan     ${name}    Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    FOR    ${nrcell_dn}    IN    @{all_nrcells_dn_list}
        ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${nrcell_dn}"]
        NetAct Create Managed Object    plan=${plan_name}    meta_class=${MO_items['class']}
        ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${nrcell_dn}    &{enable_CB009936_params}
    END
    Set Test Variable    ${plan_name}

Step ${index}: Provision Plan And Check Error
    Log To Console    Step ${index}: Provision Plan And Check Error
    ${status}    ${error}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=${name}_backup    create_backup_plan=None    provisioning_operation=activate
    Should Be True    '${status}' == 'FAIL'
    Should Contain    ${error}    the corresponding LCELNR instance (LCELNR.lCelnrId equal to NRCELL.lcrId) actSimplChConfMAA shall be equal to TRUE

Step ${index}: Modify Plan To Enable CB009175
    Log To Console    Step ${index}: Modify Plan To Enable CB009175
    ${mo_params}    Create Dictionary
    FOR    ${cell}    IN    @{all_nrcells_dn_list}
        ${nrcell_lcrid}    Get CM Parameter Value From SCF    ${BTS_scf_initial}    ${cell}    lcrId
        ${nrcell_cellmapping_str}    catenate    SEPARATOR=    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-    ${nrcell_lcrid}
        Set To Dictionary    ${mo_params}    ${nrcell_cellmapping_str}    ${enable_CB009175}
    END
    ${plan_new}    Create Plan To Enable CB009936 And CB009175 On NetAct    ${all_nrcells_dn_list}   ${mo_params}    ${name}
    Set Test Variable    ${plan_new}

Step ${index}: Provision Plan To Enable CB009936 With CB009175
    Log To Console    Step ${index}: Provision Plan To Enable CB009936 With CB009175
    NetAct Provision Plan    plan_name=${plan_new}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=${plan_new}_backup    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    5min    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Channels and Channel Groups Auto Created
    Log To Console    Step ${index}: Check Channels and Channel Groups Auto Created
    Selenium Login
    FOR    ${cell_dn}    IN    @{all_nrcells_dn_list}
        ${nrcell_name}    Fetch From Right    ${cell_dn}    /
        ${TX_num}    ${RX_num}    Get MAA Cell TRX Num From Detailed Site View Via Selenium    ${nrcell_name}    CHANNELGROUP-1
        ${type}    Set Variable    ${expected_trx.replace('DL','-').replace('UL','').split('-')}
        Should Be Equal As Integers    ${TX_num}    ${type[0]}
        Should Be Equal As Integers    ${RX_num}    ${type[-1]}
    END
    [Teardown]    Selenium Logout

Step ${index}: Check RF Diagnostic Test Result
    Log To Console    Step ${index}: Check RF Diagnostic Test Result
    FOR    ${cell_dn}    IN    @{all_nrcells_dn_list}
        ${nrcell_id}    Fetch From Right    ${cell_dn}    -
        Run RF Diagnostic Test    ${nrcell_id}    NR
        Get And Check RF Diagnostic Test Result 5G
    END
    [Teardown]    Run Keyword And Ignore Error    Clean Up Test Object

Step ${index}: Disable Features On NRCELLs
    Log To Console    Step ${index}: Disable Features On NRCELLs
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${planName}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${plan_new}_backup     operation_type=plan
    NetAct Provision Plan    plan_name=${plan_new}_backup     dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Sleep    60s
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Wait Until Keyword Succeeds    5min    60s    Check SBTS SMOD RMOD Cells Alarms

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

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_new}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_new}_backup
    Run Keyword If    ${RECOVERY_FLAG}
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${nrCellType_ui}   Set Variable    4DL2UL
    Set Test Variable     ${nrCellType_ui}
    ${trx_mapping}    Create Dictionary    4DL2UL=2DL12UL
    Set Test Variable     ${trx_mapping}
    ${txt_mapping_keys}    Get Dictionary Keys    ${trx_mapping}
    ${selected_key}    Evaluate    random.choice(${txt_mapping_keys})    modules=random, sys
    Set Test Variable    ${expected_trx}    ${trx_mapping["${selected_key}"]}
    ${nrCellType}    Set Variable    ${selected_key.replace('DL','').replace('UL','')}
    ${enable_CB009936_params}    Create Dictionary    nrCellType=${nrCellType}    actEcpri72e=true    actBeamforming=true    numberOfRxBeamforming=16
    ...    numberOfRxPucch=8    actSuperCell=false    actExternalAntennaBF=false
    Set Test Variable     ${enable_CB009936_params}
    ${enable_CB009175}    Create Dictionary    actSimplChConfMAA=true
    Set Test Variable     ${enable_CB009175}

TC Teardown
    Particular Teardown