*** Settings ***
Documentation     Test case for EDA action 02874260
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1014    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}
...   /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/Different_Impact/CM_Different_Impact_para.yaml
@{SELECTED_TYPE}    Different_Impact
${RECOVERY_FLAG}    ${False}

*** Keywords ***
SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration changes from NetAct with different impact modification
    ...    based on SELECTED_TYPE
    ...
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.03.2025 - Added by Xu Yuyan - EDA Action Task For 02874260
    ...    *******************
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_4@internal.nsn.com
    TC parameters check
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create and edit plan SyVe
    Step 6: Export the plan SyVe
    Step 7: Provision the plan SyVe
    Step 8: Check modified parameter in Netact after provision plan
    Step 9: Check modified parameter in Admin after provision plan
    Step 10: Provision the backup plan
    Step 11: Check final alarms status from WebEM
    Step 12: Check final alarms status from Netact
    Step 13: Check final BTS state
    Step 14: Check final number and state of Cells and RMs


TC parameters check
    Log    TC parameters check started    console=True
    ${Param_plan_dic_list}    Select One Set TestData Of Trigger Action Parameters From Json    ${TEST_DATA_FILE}    ${SELECTED_TYPE}
    Log    ${Param_plan_dic_list}
    Set Test Variable    ${Param_plan_dic_list}
    FOR    ${Param_plan_dic}    IN    @{Param_plan_dic_list}
        ${same_values}=    Run Keyword And Return Status
        ...   Check Actual Configuration Parameters    dist_name=${Param_plan_dic["plan_info"]['mo_id']}
        ...   ui_values=false    &{Param_plan_dic["plan_info"]['parameter']}
        Run Keyword If    ${same_values}
        ...    Log     TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!   level=WARN
        ...    ELSE    Log    TC parameters successfully checked    console=True
        Should Not Be True     ${same_values}
    END

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains
    ...    informations   such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...   critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...   critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}

    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    ${name}    Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    FOR    ${Param_plan_dic}    IN    @{Param_plan_dic_list}
        ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${Param_plan_dic["plan_info"]['scf_distName']}"]
        NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
        ...    meta_version=${MO_items['version']}    mo_id=${Param_plan_dic["plan_info"]['mo_id']}    &{Param_plan_dic["plan_info"]['parameter']}
    END
    Set Test Variable    ${plan}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Wait Until Keyword Succeeds    5min    30s    Check SBTS SMOD RMOD Cells Alarms


Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan    console=True
    FOR    ${Param_plan_dic}    IN    @{Param_plan_dic_list}
        NetAct Check Actual Configuration Parameters    dist_name=${Param_plan_dic["plan_info"]['mo_id']}    ui_values=false
        ...    &{Param_plan_dic["plan_info"]['parameter']}
    END

Step ${index}: Check modified parameter in Admin after provision plan
    Log    Step ${index}: Check modified parameter in Admin after provision plan   console=True
    FOR    ${Param_plan_dic}    IN    @{Param_plan_dic_list}
        Check WebEM After Modify Parameters    ${Param_plan_dic["plan_info"]['scf_distName']}    &{Param_plan_dic["plan_info_ui"]['parameter']}
    END

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Wait Until Keyword Succeeds    5min    30s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Run Keyword If    ${RECOVERY_FLAG}    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Log To Console    TC Teardown
    Particular Teardown