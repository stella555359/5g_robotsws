*** Settings ***
Documentation       Test case for RAN_ST_CB013031_012_CM_Disabling CB0130131 with delta plan for an operational BTS
...                 having auto-configured parameters in actual configuration from NMS
...                 Author: Yuyan Xu
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB2002    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_CB013031_012_Disabling_CB0130131_With_Delta_Plan_For_BTS_Having_Auto-configured_Parameters_Via_NMS
    [Documentation]    [CASE LINK]:
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision NR cell delete and add from NetAct based on prepare a delete NRCEL-1 plan
    ...
    ...    Pass criteria: delete and add NRCEL provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.09.2025 - New case by Xu Yuyan
    ...    *******************
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Prepare Delta Plan With CB013031 Enable
    Step 2: Provision the Delta Plan With CB013031 Enable
    Step 3: Check Auto-Config Parameters After Plan Provision
    Step 4: Disable CB013031 With REMOVE_VALUES
    Step 5: Check Parameters After Disable CB013031 With REMOVE_VALUES
    Step 6: Provision the Delta Plan With CB013031 Enable
    Step 7: Check Auto-Config Parameters After Plan Provision
    Step 8: Disable CB013031 With KEEP_VALUES
    Step 9: Check Parameters After Disable CB013031 With KEEP_VALUES


Step ${index}: Prepare Delta Plan With CB013031 Enable
    #authenticationMethod:AUTH_AES_GCM_ICV16_128   encryptionMethod delete will to ENC_AES_GCM_ICV16_128
    Log To Console    Step ${index}: Prepare Delta Plan With CB013031 Enable
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=init_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}   plan_name=None    operation_type=actual
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${name_enable}    CB013031_012_MRBTS-${mrbts_id}_${timestamp}_enable
    ${plan}    NetAct Create Plan    ${name_enable}    CB013031_012_MRBTS-${mrbts_id}_${timestamp}_enable
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items_FEATCADM}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1"]
    ${MO_items_NRBTS}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/NRBTS-${nrbts_id}"]
    ${MO_items_RMOD}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2"]
    ${MO_items_TNL}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/TNLSVC-1/TNL-1"]
    Set Test Variable    ${MO_items_FEATCADM}
    Set Test Variable    ${MO_items_NRBTS}
    Set Test Variable    ${MO_items_RMOD}
    Set Test Variable    ${MO_items_TNL}
    NetAct Create Managed Object    plan=${plan}   meta_class=${MO_items_FEATCADM['class']}    meta_version=${MO_items_FEATCADM['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1    operation=update    actCondAutoConfValCalc=true

    #legacyopt-y cacv-n default-y -> user configure value -> keep
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items_RMOD['class']}    meta_version=${MO_items_RMOD['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2   operation=update    alVoltHighThreshold=108
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items_RMOD['class']}    meta_version=${MO_items_RMOD['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2   operation=update    alVoltUnstableThreshold=10

    #legacyopt-y cacv-y default-y match rule setdefault10-> assign value  yuki: current is 10, when disable&keep should be 10 or empty??
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items_RMOD['class']}    meta_version=${MO_items_RMOD['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2   operation=update    advanceTimeForRURestore=${EMPTY}

    #legacyopt-y(or n) cacv-y default-n  CACV work-> delete, will be CACV value
    #MRBTS-37376/EQM-1/APEQM-1/RMOD-2/ANTL-1  useMeasuredRoundTripDelay
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.eqm:ANTL    meta_version=${MO_items_RMOD['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-1   operation=update    useMeasuredRoundTripDelay=${EMPTY}

    #legacyopt-n cacv-n(or y) default-y  CACV work-> delete, will be default
    #MRBTS-37376/NRBTS-37376 actRanSharing:default:false
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items_NRBTS['class']}    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}   operation=update    actRanSharing=${EMPTY}

#    ${status}    ${managed_object_get}    Run Keyword And Ignore Error    netact.Get Managed Object    configuration=Actual
#    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1
#
#    ${managed_object_delete}     Run Keyword If    "${status}"=="PASS"   netact.Create Managed Object    plan=${plan}
#    ...    meta_class=com.nokia.srbts.tnl:IPSECC    meta_version=${MO_items_TNL['version']}
#    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1    operation=delete

    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_enable}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}   plan_name=${name_enable}    operation_type=plan

Step ${index}: Provision the Delta Plan With CB013031 Enable
    Log To Console    Step ${index}: Provision the Delta Plan With CB013031 Enable
    NetAct Provision Plan    plan_name=${name_enable}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ...    backup_plan_name=${name_enable}_backup    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    20m    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Auto-Config Parameters After Plan Provision
    Log To Console    Step ${index}: Check Auto-Config Parameters After Plan Provision
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ${parameter}    Create Dictionary     useMeasuredRoundTripDelay=false
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-1
    ...    ui_values=true    &{parameter}
    ${parameter}    Create Dictionary     actRanSharing=false
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}    ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    alVoltHighThreshold=108    alVoltUnstableThreshold=10    advanceTimeForRURestore=10
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2    ui_values=true    &{parameter}

Step ${index}: Disable CB013031 With REMOVE_VALUES
    Log To Console    Step ${index}: Disable CB013031 With REMOVE_VALUES
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${name_disable_remove}    MRBTS-${mrbts_id}_${timestamp}_disable_remove
    ${parameter}    Create Dictionary     actCondAutoConfValCalc=false   modeOfCondAutoConfValCalcDeact=2
    ${plan}    NetAct Create And Edit Plan    name=${name_disable_remove}    description=disable_CB013031_MRBTS-${mrbts_id}_REMOVE_VALUES
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1   scf_distName=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1   &{parameter}

    #legacyopt-y cacv-y default-y match rule curren=default -> check when disable&keep/remove should be default
    #mhaType  MRBTS-37376/EQM-1/APEQM-1/ALD-255
    #If child object of this ALD MO is LNA type, then set mhaType to default(WMHA).
    #legacyopt-n cacv-y default-y match rule curren!=default ->check when disable&keep should keep current value, when disable&remove should empty
    #controlProtocol   MRBTS-37376/EQM-1/APEQM-1/ALD-255
    #If value of ALD-mhaType is equal to 'WMHA' or 'WMHB' or 'WMHC' then set ALD-controlProtocol to 'CWA'.
#    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.eqm:ALD   meta_version=${MO_items_RMOD['version']}
#    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-255   operation=create
#    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.eqm:LNA   meta_version=${MO_items_RMOD['version']}
#    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-255/LNA-1   operation=create    subunitNumber=1

    #legacyopt-n cacv-y default-y(Ungrouped)  CACV work set with Grouped
    #ipsecMeshAlarmGrouping
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.tnl:IPSECC   meta_version=${MO_items_TNL['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1   operation=create

    #legacyopt-y(or n) cacv-y default-n  CACV work-> delete, will be empty
    #MRBTS-37376/EQM-1/APEQM-1/RMOD-2/ANTL-1  useMeasuredRoundTripDelay
    #NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.eqm:ANTL    meta_version=${MO_items_RMOD['version']}
    #...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-1   operation=update    useMeasuredRoundTripDelay=${EMPTY}

    #legacyopt-n cacv-n(or y) default-y  CACV work-> delete, will be default
    #MRBTS-37376/NRBTS-37376 actRanSharing:default:false
    #yuki 0918 need comment this line?
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items_NRBTS['class']}    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}   operation=update    actRanSharing=${EMPTY}

    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_disable_remove}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}   plan_name=${name_disable_remove}    operation_type=plan
    NetAct Provision Plan    plan_name=${name_disable_remove}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ...    backup_plan_name=${name_disable_remove}_backup    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    20m    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Parameters After Disable CB013031 With REMOVE_VALUES
    Log To Console    Step ${index}: Check Parameters After Disable CB013031 With REMOVE_VALUES
    ${parameter}    Create Dictionary    ipsecMeshAlarmGrouping=Ungrouped
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1
    ...    ui_values=true    &{parameter}

    ${parameter}    Create Dictionary    alVoltHighThreshold=108    alVoltUnstableThreshold=10    advanceTimeForRURestore=${EMPTY}
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2    ui_values=true    &{parameter}

    ${parameter}    Create Dictionary    useMeasuredRoundTripDelay=${EMPTY}
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-1
    ...    ui_values=true    &{parameter}

    ${parameter}    Create Dictionary    actRanSharing=false
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    ui_values=true    &{parameter}

Step ${index}: Check Parameters After Disable CB013031 With KEEP_VALUES
    Log To Console    Step ${index}: Check Parameters After Disable CB013031 With KEEP_VALUES
    ${parameter}    Create Dictionary    ipsecMeshAlarmGrouping=Grouped
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1
    ...    ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    alVoltHighThreshold=108    alVoltUnstableThreshold=10    advanceTimeForRURestore=10
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2    ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    useMeasuredRoundTripDelay=false
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-1
    ...    ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    actRanSharing=false
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    ui_values=true    &{parameter}

Step ${index}: Disable CB013031 With KEEP_VALUES
    Log To Console    Step ${index}: Disable CB013031 With KEEP_VALUES
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${name_disable_keep}    MRBTS-${mrbts_id}_${timestamp}_disable_keep
    ${parameter}    Create Dictionary     actCondAutoConfValCalc=false   modeOfCondAutoConfValCalcDeact=1
    ${plan}    NetAct Create And Edit Plan    name=${name_disable_keep}    description=disable_CB013031_MRBTS-${mrbts_id}_REMOVE_VALUES
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1   scf_distName=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1   &{parameter}

    #legacyopt-y cacv-y default-y match rule curren=default -> check when disable&keep/remove should be default
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.tnl:IPSECC   meta_version=${MO_items_TNL['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1   operation=create

    #legacyopt-y(or n) cacv-y default-n  CACV work-> delete, will be empty
    #MRBTS-37376/EQM-1/APEQM-1/RMOD-2/ANTL-1  useMeasuredRoundTripDelay
    #NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.eqm:ANTL    meta_version=${MO_items_RMOD['version']}
    #...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-1   operation=update    useMeasuredRoundTripDelay=${EMPTY}

    #legacyopt-n cacv-n(or y) default-y  CACV work-> delete, will be default
    #MRBTS-37376/NRBTS-37376 actRanSharing:default:false
    #yuki 0918 need comment this line?
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items_NRBTS['class']}    meta_version=${MO_items_NRBTS['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}   operation=update    actRanSharing=${EMPTY}

    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_disable_keep}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}   plan_name=${name_disable_keep}    operation_type=plan
    NetAct Provision Plan    plan_name=${name_disable_keep}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=${name_disable_keep}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    20m    60s    Check SBTS SMOD RMOD Cells Alarms


Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF
    Return From Keyword If    '${when}'!='initial'
    ${dic_bts_infor}    coam.Get Bts Info
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${NRCELL_list}    ${cell_list['cells']['nr']}
    ${NRBTS_RT_cell_num_initial}    Evaluate    len(${NRCELL_list})
    Set Test Variable    ${NRBTS_RT_cell_num_initial}
    ${selected_cell}    Evaluate    random.choice(${NRCELL_list})    modules=random, sys
    Set Test Variable    ${selected_nrcell_DN}    ${selected_cell['id']['configuration']}
    Set Test Variable    ${selected_nrcell_R}    ${selected_cell['id']['internal']}
    ${ALL_NRCELL_list}    Create List
    ${ALL_NRCELL_ID_list}    Create List
    FOR    ${item}    IN    @{NRCELL_list}
        ${nrcell_R}    Set Variable    ${item['id']['internal']}
        Append To List    ${ALL_NRCELL_list}    ${nrcell_R}
    END
    ${selected_nrcell_id}    Fetch From Right    ${selected_nrcell_DN}    -
    Set Test Variable    ${selected_nrcell_id}
    ${Initial_NRCELL_list_R}    Copy List    ${ALL_NRCELL_list}    deepcopy=True
    Remove Values From List    ${ALL_NRCELL_list}    ${selected_nrcell_R}
    Set Test Variable    ${Other_NRCELL_list}    ${ALL_NRCELL_list}
    Set Test Variable    ${Initial_NRCELL_list_R}
    ${list_nrDU_infor}    Pop From Dictionary    ${dic_bts_infor}    nrDU
    Should Be Equal As Integers    ${list_nrDU_infor.__len__()}    ${1}
    ...    It must be one and only one NRDU for this test case.
    Set Test Variable    ${NRDU_NAME}    ${list_nrDU_infor[0]['id']['configuration']}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe


TC Setup
    Common Test Setup

TC Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_enable}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_enable}_backup
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_disable_remove}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_disable_remove} _backup
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_disable_keep}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_disable_keep} _backup
#    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
    #Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown    #SNAPSHOT ON FAILURE=NO