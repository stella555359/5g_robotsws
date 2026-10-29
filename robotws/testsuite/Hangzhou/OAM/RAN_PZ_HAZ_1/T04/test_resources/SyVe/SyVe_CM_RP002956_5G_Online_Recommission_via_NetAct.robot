*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NROnline/CM_NR_Online_para.yaml
@{SELECTED_TYPE}    NR_ONLINE
${ACTIVE_5G_ONLINE_DURATION_STANDARD}    65
${UPLOAD_DURATION_STANDARD}    35


*** Keywords ***
SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-20687
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration changes from NetAct with online parameter modification
    ...    based on random select parameter in json file
    ...    The main steps performed for the test are:
    ...    - Random Select Parameter
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.12.2020 - https://jira3.int.net.nokia.com/browse/TAT-20687 -
    ...    SyVe_CM_Online_Recommission_via_NetAct_RP002956_5G
    ...    - 12.04.2021 - https://jira3.int.net.nokia.com/browse/TAT-21180 -
    ...    Update case to move ute_admin_Infomodel, replace by ute_admin.
    ...    - 02.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697 -
    ...    Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking
    ...    - 10.12.2021 - Modified by Liu Bin - https://jira3.ext.net.nokia.com/browse/TAT-22028 -
    ...    LTE4985-C_ST_05_08 test point merge to SyVe case
    ...    - 11.05.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22175 -
    ...    [SyVe]Optimize case can read parameter value with units
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476 -
    ...    Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847 -
    ...    Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...    - 01.11.2023 - Modified by Kang Lixin - Update to unify testdata and keyword to get json test data parameters for ui/non-ui mapping
    ...    - 09.04.2024 - Modified by Kang Lixin - Add time kpi for CB012145
    ...    - 09.26.2025 - Updated by Xu Yuyan - Add structure parameter check for RCA/EDA
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-20687_SyVe_CM_Online_Recommission_via_NetAct_RP002956_5G.png
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: Random Select Parameter
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Pre-Activate Plan And Reset Site
    Step 9: Activate the pre-activated plan SyVe
    Step 10: Check modified parameter in Netact after provision plan
    Step 11: Check modified parameter in Admin after provision plan
    Step 12: Provision the backup plan
    Step 13: Check final alarms status from WebEM
    Step 14: Check final alarms status from Netact
    Step 15: Check final BTS state
    Step 16: Check final number and state of Cells and RMs

Step ${index}: Random Select Parameter
    Log    Step ${index}: Random Select Parameter    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${plan_info}    ${plan_info_ui}    ${expect_status}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE}    ${SELECTED_TYPE}
    Set Test Variable    ${plan_info}
    Log    ${plan_info}    console=True

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    ${start_time}    Get Time
    NetAct CM Upload    dist_names=${MRBTS_DN}
    ${end_time}    Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<${UPLOAD_DURATION_STANDARD}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${plan_info['mo_id']}    scf_distName=${plan_info['scf_distName']}    &{plan_info['parameter']}
    Set Test Variable    ${plan}
    #Add actRimCmFmReport on 2025-09-26
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items_NRBTS}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/NRBTS-${nrbts_id}"]
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=check_netact_plan_${timestamp}.xml    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}    ui_values=false
    ${scf_xml}    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/check_netact_plan_${timestamp}.xml
    &{parameter_child}    Create Dictionary    asymmetricStateReport=0
    @{parameter_child_list}    Create List    ${parameter_child}
    &{parameter_structure}    Create Dictionary    actRimCmFmReport=@{parameter_child_list}
    ${status}    Run Keyword And Return Status    Compare Parameter Contain In Structure In XML    ${scf_xml}    false
    ...    PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    actRimCmFmReport    ${parameter_child}
    Run Keyword If    ${status}    Set To Dictionary    ${parameter_structure["actRimCmFmReport"][0]}    asymmetricStateReport    1
    Log    ${parameter_structure}    console=True
    Set Test Variable    ${parameter_structure}
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items_NRBTS['class']}
        ...    meta_version=${MO_items_NRBTS['version']}    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}    &{parameter_structure}

Compare Parameter Contain In Structure In XML
    [Documentation]    Compare Parameter Contain In Structure In XML
    [Arguments]     ${scf_xml}    ${ui_values}    ${dist_name}    ${param_name}    ${expected_value}
    ${element_dic}    Create Dictionary
    ${actual_items}    L_XML.Get Child Elements    ${scf_xml}
    ...    .//managedObject[@distName="${dist_name}"]/list[@name="${param_name}"]/item
    FOR    ${item}    IN    @{actual_items}
        ${p_name}    L_XML.Get Element Attribute    ${item}    name
        ${p_value}    L_XML.Get Element Text    ${item}
        Set To Dictionary    ${element_dic}    ${p_name}    ${p_value}
    END
    ${expected_dic_formatted}    Run Keyword If    '${ui_values}'=='false'
    ...   Convert Boolean Value From UI_Value To Internal_Value For Structure    ${expected_value}    #${item}
    ...    ELSE    Set Variable     ${expected_value}
    Dictionary Should Contain Sub Dictionary    ${element_dic}    ${expected_dic_formatted}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Pre-Activate Plan And Reset Site
    Log    Step ${index}: Pre-Activate Plan And Reset Site    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=preactivate
    coam.Reset
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Activate the pre-activated plan SyVe
    Log    Step ${index}: Activate the pre-activated plan SyVe    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Activate_Pre-Activation    console=True
    SSHLibrary.Start Command    racclimx.sh -op Activate_Pre-Activation -planName ${name} -v
    Log    Check Action    console=True
    FOR    ${index}    IN RANGE    0    20
        sleep    3s
        ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
        ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
        ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
        ${nrcell}    Run Keyword And Return Status    coam.Assert Any    NRCEL
        ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status
        ...    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}    timeout=60
        ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status
        ...    coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}    timeout=60
        ${lncell_onair}    Run Keyword If    ${lncell}    Run Keyword And Return Status
        ...    coam.Assert Every    LNCEL    ${cells_LTE_expected_state}    timeout=60
        ${nrcell_onair}    Run Keyword If    ${nrcell}    Run Keyword And Return Status
        ...    coam.Assert Every    NRCEL    ${cells_NR_expected_state}    timeout=60
        Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
        Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
        Run Keyword If    ${lncell}    Should Be True    ${lncell_onair}
        Run Keyword If    ${nrcell}    Should Be True    ${nrcell_onair}
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Activation successful

Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}    console=True
    Wait Until Keyword Succeeds    20x    60s    NetAct Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}
    ${parameter_names}    Get Dictionary Keys    ${plan_info['parameter']}
    ${status}    ${current_param_value}    Run Keyword And Ignore Error    Get Actual Parameter Value From NetAct
    ...    ${plan_info['mo_id']}    ${parameter_names[0]}    ui_values=true
    Set Test Variable    &{parameter_ui}    ${parameter_names[0]}=${current_param_value}
    #Check actRimCmFmReport on 2025-09-26
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=check_netact_plan_${timestamp}.xml    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}    ui_values=false
    ${scf_xml}    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/check_netact_plan_${timestamp}.xml
    &{parameter_child}    Create Dictionary    asymmetricStateReport=0
    ${status}    Run Keyword And Return Status    Compare Parameter Contain In Structure In XML    ${scf_xml}    false
    ...    PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    actRimCmFmReport    ${parameter_structure["actRimCmFmReport"][0]}
    Should Be True    ${status}

Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}    console=True
    Check WebEM After Modify Parameters    ${plan_info['scf_distName']}    &{parameter_ui}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    ${status}    Run Keyword And Return Status    netact.Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}
    ...    backup_plan_name=None    backup_plan_name=False    provisioning_operation=preactivate    ignore_errors=True
    Should Be True    ${status}
    ${start_time}    Get Time
    ${status}    Run Keyword And Return Status    netact.Activate Preactivated Plan  plan_name=${name}_backup    dist_names=${MRBTS_DN}
    ${end_time}    Get Time
    Run Keyword If    ${status}    Log    Activate plan ${name} successfully done!    console=True
    ...    ELSE    Run Keywords    Log    Activate plan ${name} failed!    level=ERROR
    ...    AND    Fail    Activate plan ${name} failed!
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<${ACTIVE_5G_ONLINE_DURATION_STANDARD}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}
    Run Keyword If    ${plan_values}    Run Keywords
    ...    Log    Parameters were not reset to initial values! Probably backup plan was not provisioned!    level=WARN
    ...    AND    Log    Will perform commissioning with initial scf!    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown