*** Settings ***
Documentation       Test case for RAN_ST_CB013031_003_CM_Delta configuration plan provisioning
...                 (calculation and recalculation of conditional auto-configured value parameters) from NMS
...                 Author: Yuyan Xu
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1014    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_CB013031_003_Delta_Plan_Provision_Calculation_Of_Conditional_Auto-configured_Value_Parameters_Via_NMS
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
    ...    - 04.08.2025 - New case by Xu Yuyan
    ...    *******************
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    #Step 1: Check initial BTS state
    Step 2: Prepare Env To Delete NRCELL
    Step 3: Prepare Add NRCELL Plan With CB013031 Enable
    Step 4: Provision To Add NRCELL With CB013031 Enable
    Step 5: Check NRCELL Auto-Configured Parameter Values
    Step 6: Remove And Modify Auto-Configured Parameters
    Step 7: Check Updated Auto-Configured Parameter Values
    Step 8: Modify Depend Parameter And Check Auto-Config Parameter Values
    #Check USERCONFPAR_INTERNAL, RAML extension element userConfigured
    #Step 9: Check final BTS state
    #Step 10: Check final number and state of Cells and RMs

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

Step ${index}: Prepare Env To Delete NRCELL
    Log To Console    Step ${index}: Prepare Env To Delete NRCELL
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ${name}    Create Plan To Delete NRCELL Via NetAct    ${selected_nrcell_DN}
    Set Test Variable    ${name}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms
    ${cells_list}    coam.get_cell_list
    ${cells}    Get From Dictionary    ${cells_list["cells"]}    nr
    ${result}    Set Variable    ${False}
    FOR    ${cell}    IN    @{cells}
        ${result}    Run Keyword And Return Status    Should Not Be Equal As Strings
        ...    ${cell["id"]["configuration"]}    ${selected_nrcell_DN}
        Exit For Loop If   not ${result}
    END
    Should Be True    ${result}    The NRCELL-1 be deleted failed in the NRBTS-${nrbts_id} of MRBTS-${mrbts_id}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    plan_name=${name}_backup    operation_type=plan

Step ${index}: Prepare Add NRCELL Plan With CB013031 Enable
    Log To Console    Step ${index}: Prepare Add NRCELL Plan With CB013031 Enable
    coam.perform_parameter_recommissioning    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1   actCondAutoConfValCalc    update    true
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

    ${ParamValue_Dic1}   Create Dictionary    actORuFlexibleBeamIdMapping=false
    ${ParamValue_Dic2}   Create Dictionary    a1MeashoEnabled=0    #None
    &{parameter_child}    Create Dictionary    csiReportPeriodicity=320    scramblingIdStep=3    #maxCsirsNumber=${EMPTY}
    @{parameter_child_list}    Create List    ${parameter_child}
    ${ParamValue_Dic3}    Create Dictionary    periodicCsiAcquisition=@{parameter_child_list}
    ${Parameters_Dic}   Create Dictionary
    ...    ${selected_nrcell_DN}=${ParamValue_Dic1}
    ...    ${selected_nrcell_DN}=${ParamValue_Dic2}
    ...    ${selected_nrcell_DN}=${ParamValue_Dic3}
    Set Test Variable    ${ParamValue_Dic1}
    Set Test Variable    ${ParamValue_Dic2}
    Set Test Variable    ${ParamValue_Dic3}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/${name}_backup.csv
    ${nrcell_head_str}    Set Variable    .//managedObject[@distName="PLMN-PLMN/${selected_nrcell_DN}"]
    ${nrcellgrp_head_str}    Set Variable    .//managedObject[@distName="PLMN-PLMN/${selected_nrcellgrp_DN}"]
    #legacyoptional:no;  defaultvalue:Y; Boolean  nomatch->default
    ${element_cnt}    L_XML.Get Element Count   ${scf_content}
    ...    ${nrcell_head_str}/p[@name="actORuFlexibleBeamIdMapping"]
    Run Keyword If   ${element_cnt}!=0
    ...    L_XML.Remove Elements    ${scf_content}
    ...    ${nrcell_head_str}/p[@name="actORuFlexibleBeamIdMapping"]
    #legacyoptional:Y; defaultvalue:Y;Enumeration  match->default
    ${element_cnt}    L_XML.Get Element Count   ${scf_content}
    ...    ${nrcell_head_str}/p[@name="a1MeashoEnabled"]
    Run Keyword If   ${element_cnt}!=0
    ...    L_XML.Remove Elements    ${scf_content}
    ...    ${nrcell_head_str}/p[@name="a1MeashoEnabled"]
    #legacyoptional:Y; defaultvalue:N;Structure-Number  nomatch->empty
    ${element_cnt}    L_XML.Get Element Count   ${scf_content}
    ...    ${nrcell_head_str}/list[@name="periodicCsiAcquisition"]/item/p[@name="maxCsirsNumber"]
    Run Keyword If   ${element_cnt}!=0
    ...    L_XML.Remove Elements    ${scf_content}
    ...    ${nrcell_head_str}/list[@name="periodicCsiAcquisition"]/item/p[@name="maxCsirsNumber"]
    #legacyoptional:no; defaultvalue:N;Enumeration
#    ${element_cnt}    L_XML.Get Element Count   ${scf_content}
#    ...    ${nrcellgrp_head_str}/p[@name="scs"]
#    Run Keyword If   ${element_cnt}!=0
#    ...    L_XML.Remove Elements    ${scf_content}
#    ...    ${nrcellgrp_head_str}/p[@name="scs"]
    L_XML.Save XML    ${scf_content}    ${Test Results Dir}/NetActLogs/${name}_backup_updated.csv
    NetAct Import Plan    local_dir=${Test Results Dir}/NetActLogs/    file_name=${name}_backup_updated.csv    plan_name=${name}_backup_updated


Step ${index}: Provision To Add NRCELL With CB013031 Enable
    Log To Console    Step ${index}: Provision To Add NRCELL With CB013031 Enable
    NetAct Provision Plan    plan_name=${name}_backup_updated    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
#    NetAct Provision Plan    plan_name=${name}_backup    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=None
#    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms
    ${cells_list}    coam.get_cell_list
    ${cells}    Get From Dictionary    ${cells_list["cells"]}    nr
    ${result}    Set Variable    ${False}
    FOR    ${cell}    IN    @{cells}
        ${result}    Run Keyword And Return Status    Should Be Equal As Strings
        ...    ${cell["id"]["configuration"]}    ${selected_nrcell_DN}
        Exit For Loop If   ${result}
    END
    Should Be True    ${result}    The NRCELL-1 be added failed in the NRBTS-${nrbts_id} of MRBTS-${mrbts_id}

Step ${index}: Check NRCELL Auto-Configured Parameter Values
    Log To Console    Step ${index}: Check NRCELL Auto-Configured Parameter Values
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${selected_nrcell_DN}
        ...    ui_values=false    &{ParamValue_Dic1}
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${selected_nrcell_DN}
        ...    ui_values=false    &{ParamValue_Dic2}
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${selected_nrcell_DN}
        ...    ui_values=false    &{ParamValue_Dic3}

Step ${index}: Remove And Modify Auto-Configured Parameters
    Log To Console    Step ${index}: Remove And Modify Auto-Configured Parameters
    #MNL:actNcYgMPlane   legacyoptional:Y;  defaultvalue:Y; Boolean   matchrule->remove
    #EQM/APEQM:aldScanningInterval->1min   legacyoptional:no;  defaultvalue:Y; Enumeration  nomatchdefault->uservalue
    #MNL/MNLENT/SYNC/CLOCK/TOP/TOPP:phaseJumpDetectionThreshold->2800  legacyoptional:Y; defaultvalue:N; Number nomatchempty->uservalue
    #TNLSVC-1/PMTNLINT-1:ipSecSaStatisticsInterval  legacyoptional:no;  defaultvalue:Y; Enumeration   nomatchdefault->remove
    #TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1:l2IngressRate  legacyoptional:Y;  defaultvalue:N; Number  matchrule->uservalue
    ${ParamValue_Dic1}   Create Dictionary    actNcYgMPlane=${EMPTY}  #expected: false  #current:true
    ${ParamValue_Dic2}   Create Dictionary    aldScanningInterval=2    #1min   #30s
    ${ParamValue_Dic3}   Create Dictionary    phaseJumpDetectionThreshold=2800   #2800  #empty
    ${ParamValue_Dic4}   Create Dictionary    ipSecSaStatisticsInterval=${EMPTY}   #15min  #15min
    #${ParamValue_Dic5}   Create Dictionary    l2IngressRate=10000000    #10000000  #20000000 yuki will cause cell failed
    ${Parameters_Dic}   Create Dictionary
    ...    MRBTS-${mrbts_id}/MNL-1=${ParamValue_Dic1}
    ...    MRBTS-${mrbts_id}/EQM-1/APEQM-1=${ParamValue_Dic2}
    ...    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1=${ParamValue_Dic3}
    ...    MRBTS-${mrbts_id}/TNLSVC-1/PMTNLINT-1=${ParamValue_Dic4}
    #...    MRBTS-${mrbts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1=${ParamValue_Dic5}
    Set Test Variable    ${Parameters_Dic}
    ${time}    Get Time    epoch
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${time}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    ${keys}    Get Dictionary Keys    ${Parameters_Dic}
    FOR    ${DN}    IN    @{keys}
        ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${DN}"]
        ${parameter_dict}    Get From Dictionary    ${Parameters_Dic}    ${DN}
        NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
        ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${DN}    &{parameter_dict}
    END
    Set Test Variable    ${plan}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    plan_name=${name}    operation_type=plan
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    plan_name=${name}_backup    operation_type=plan
    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms


Step ${index}: Check Updated Auto-Configured Parameter Values
    Log To Console    Step ${index}: Check Updated Auto-Configured Parameter Values
    ${keys}    Get Dictionary Keys    ${Parameters_Dic}
    FOR    ${DN}    IN    @{keys}
        ${parameter_dict}    Get From Dictionary    ${Parameters_Dic}    ${DN}
        ${result}    Run Keyword And Return Status    Dictionary Should Contain Key    ${parameter_dict}    ipSecSaStatisticsInterval
        Run Keyword If    ${result}    Set To Dictionary    ${parameter_dict}    ipSecSaStatisticsInterval=15
        ${result}    Run Keyword And Return Status    Dictionary Should Contain Key    ${parameter_dict}    actNcYgMPlane
        Run Keyword If    ${result}    Set To Dictionary    ${parameter_dict}    actNcYgMPlane=0
        NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${DN}
        ...    ui_values=false    &{parameter_dict}
    END


Step ${index}: Modify Depend Parameter And Check Auto-Config Parameter Values
    Log To Console    Step ${index}: Modify Depend Parameter And Check Auto-Config Parameter Value
    ${time}    Get Time    epoch
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${time}
    #actPdschAllocAroundSsb  online  legacyoptional:Y; defaultvalue:Y
    #CACV:If NRCELL.actPdschAtSsbSlots is set to TRUE, then SET NRCELL.actPdschAllocAroundSsb to TRUE.
    #if not match rule, NRCELL.actPdschAtSsbSlots is set to false, then NRCELL.actPdschAllocAroundSsb will be empty.
    ${ParamValue_Dic}   Create Dictionary    actPdschAtSsbSlots=false    actPdschAllocAroundSsb=${EMPTY}
    ${plan}    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}_prepare
    ...    mo_id=PLMN-PLMN/${selected_nrcell_DN}
    ...    scf_distName=${selected_nrcell_DN}    &{ParamValue_Dic}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    plan_name=${name}    operation_type=plan
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms
    ${ParamValue_Dic}   Create Dictionary    actPdschAtSsbSlots=false    actPdschAllocAroundSsb=${EMPTY}
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${selected_nrcell_DN}
    ...    ui_values=false    &{ParamValue_Dic}
    ${time}    Get Time    epoch
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${time}
    #actPdschAllocAroundSsb  online  legacyoptional:Y; defaultvalue:Y
    #CACV:If NRCELL.actPdschAtSsbSlots is set to TRUE, then SET NRCELL.actPdschAllocAroundSsb to TRUE.
    #if not match rule, NRCELL.actPdschAtSsbSlots is set to false, then NRCELL.actPdschAllocAroundSsb will be empty.
    ${ParamValue_Dic}   Create Dictionary    actPdschAtSsbSlots=true    actPdschAllocAroundSsb=${EMPTY}
    ${plan}    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=PLMN-PLMN/${selected_nrcell_DN}
    ...    scf_distName=${selected_nrcell_DN}    &{ParamValue_Dic}
    Set Test Variable    ${plan}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    plan_name=${name}    operation_type=plan
    Start TCPDump On SBTS Common
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms
    Log To Console    Check Auto-Config Parameter Value
    ${ParamValue_Dic}   Create Dictionary    actPdschAtSsbSlots=true    actPdschAllocAroundSsb=true
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${selected_nrcell_DN}
    ...    ui_values=false    &{ParamValue_Dic}
    Stop TCPDump And Check CCN Messages For Parameters Update In Same MO   ${ParamValue_Dic}

Stop TCPDump And Check CCN Messages For Parameters Update In Same MO
    [Arguments]     ${param_dic}    ${eventChangeOriginType}=plan originated
    [Documentation]    Stop wireshark and check ccn message for parameters value update
    Stop TCPDump On SBTS Common
    ${file_content}    Save TCPDump File On Local And Get Content
    ${success_msg}    Set Variable    The operation was successfully completed.:Activation successful:Provision of the plan was successful.
    #check operation status report
    Should Contain    ${file_content}    ${success_msg}
    ${param_names}    Get Dictionary Keys    ${param_dic}
     ${eventChange_str}    Set Variable   <p\\s\+name="eventChangeOrigin">\\s\*${eventChangeOriginType}\\s\*</p>\\s\*
     ${eventChange_str}    Set Variable
     ...    ${eventChange_str}<list\\s\*name="userConfigured">\\s\*<p>\\s\*actPdschAtSsbSlots\\s\*</p>.*|\\s*</extension>
    FOR    ${param_name}    IN    @{param_names}
        ${eventChange_str}    Set Variable
        ...    ${eventChange_str}\\s\*<p\\s\+name="${param_name}">\\s\*${param_dic["${param_name}"]}\\s\*</p>
    END
    Should Match Regexp    ${file_content}    ${eventChange_str}
    #check TransferNotificationResponse
    Check TransferNotificationResponse According To Param Update    ${file_content}    ${param_names[0]}


Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe


TC Setup
    Common Test Setup
    Set Test Variable    ${selected_nrcell_DN}    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    Set Test Variable    ${selected_nrcellgrp_DN}    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-1

TC Teardown
#    NetAct Provision Plan    plan_name=${name}_backup    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=None
#    ...    create_backup_plan=False    provisioning_operation=activate
#    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
#    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown    #SNAPSHOT ON FAILURE=NO