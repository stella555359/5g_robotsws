*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
#BTS only have LTE rat
${LTE_NRBTS_SCF}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_LTE_NRBTS.xml

*** Keywords ***
SyVe_CM_LTE3296_Verify_HWRESETREQ_With_BBMOD_Reset
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19893
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing CMD configuration changes from NetAct to reset BBMOD. transfer from WRO5:[SFE]_LTE3296_Verify_HW_SW_Reset
    ...    The main steps performed for the test are:
    ...    - Prepare the Plan Infor
    ...    - Set to LTE and NRBTS Only
    ...    - Random Select BBMOD
    ...    - TC parameters check
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check Reset BBMOD Behavior
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    Pass criteria: create, edit, export and provision operation works as expected; BBMOD reset as expected; states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 07.17.2020 - https://jira3.int.net.nokia.com/browse/TAT-19893 - SyVe_CM_Verify_HWRESETREQ_With_BBMOD_Reset_LTE3296
    ...    - 31.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21121 - Update to replace infomodel keywords to admin keywords
    ...    - 06.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    - 17.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22367
    ...    - optimized case based on PR615689: can both have LTE and NRBTS rat on SBTS, then randomly select one ABIA to HW reset.
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      fix: Get Plan -> netact.Get Plan Configuration
    ...    - 23.03.2022 - Modified by YuaGao:Discard using netact_plan.yaml
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/TAT-19893_SyVe_CM_Verify_HWRESETREQ_With_BBMOD_Reset_LTE3296.png
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    Maintainer–I_NSB_MN_SRAN_PROD_HZH_OPER1_VRF@internal.nsn.com
    Step 1: Prepare the Plan Infor
    Step 2: Set to LTE and NRBTS Only
    Step 3: Random select BBMOD
    Step 4: TC parameters check
    Step 5: Check initial alarms status from WebEM
    Step 6: Check initial alarms status from Netact
    Step 7: Upload configuration status
    Step 8: Create and edit plan SyVe
    Step 9: Export the plan SyVe
    Step 10: Provision the plan SyVe
    Step 11: Check Reset BBMOD Behavior
    Step 12: Check final alarms status from WebEM
    Step 13: Check final alarms status from Netact

Step ${index}: Prepare the Plan Infor
    Log    Step ${index}: Prepare the Plan Infor    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    &{targetHwResetUDNN}    Create Dictionary    targetHwResetUDN=MRBTS-${mrbts_id}/EQM-1/APEQM-1
    &{plan_info}    Create Dictionary    scf_distName=MRBTS-${mrbts_id}/MNL-1    mo_id_CMD=${MRBTS_DN}/MNL-1/CMD-1
    ...    mo_id_HWRES=${MRBTS_DN}/MNL-1/CMD-1/HWRESETREQ-1    parameter1=${targetHwResetUDNN}
    Set Test Variable    ${plan_info}

Step ${index}: Set to LTE and NRBTS Only
    Log    Step ${index}: Set to LTE and NRBTS Only    console=True
    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${LTE_NRBTS_SCF}    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Random select ${mod}
    Log    Step ${index}:Random Select ${mod}    console=True
    ${mod_id_mapping_list}    Create List
    ${bts_all_info}=    coam.Get Bts Info
    ${bbmod_info_list}    Get From Dictionary    ${bts_all_info}    basebandModules
    Log    ${bbmod_info_list}
    FOR    ${item}    IN    @{bbmod_info_list}
        ${prodname}    Get From Dictionary    ${item}    productName
        ${prodtype}    Split String    ${prodname}
        Continue For Loop If    "${prodtype[0]}" != "ABIA"
        ${id}=    Get From Dictionary    ${item}    id
        Append To List    ${mod_id_mapping_list}    ${id}
    END
    ${mod_id_mapping_list_count}=    Get Length    ${mod_id_mapping_list}
    ${selected_num}    Evaluate    random.randint(0,${mod_id_mapping_list_count}-1)    modules=random, sys
    ${mod_id_mapping_list_selected}    Set Variable    ${mod_id_mapping_list[${selected_num}]}
    ${selected_mod_internal_id}=    Get From Dictionary    ${mod_id_mapping_list_selected}    internal
    ${selected_mod_config_id}=    Get From Dictionary    ${mod_id_mapping_list_selected}    configuration
    Set Test Variable    ${selected_mod_internal_id}
    Set Test Variable    ${selected_mod_config_id}
    ${para1_value}    get dictionary values    ${plan_info['parameter1']}
    ${para}    get dictionary keys    ${plan_info['parameter1']}
    set to dictionary    ${plan_info['parameter1']}    ${para[0]}    ${selected_mod_config_id}
    set test variable    &{para_dic}    &{plan_info['parameter1']}

Step ${index}: TC parameters check
    Log    Step ${index}:TC parameters check started    console=True
    &{param_EMPTY}    Create Dictionary
    Set Test Variable    &{param_EMPTY}
    ${existed_CMD}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_CMD']}   &{param_EMPTY}
    ${existed_HWRES}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id_HWRES']}    &{para_dic}
    Set Test Variable    ${existed_CMD}
    Set Test Variable    ${existed_HWRES}
    Run Keyword If    ${existed_HWRES}    Log    TC parameters check failed: Object HWRESETREQ should not be existed!    level=ERROR
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${existed_HWRES}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    unexpected_alarms=@{UNEXPECTED_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    unexpected_alarms=@{UNEXPECTED_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info['scf_distName']}"]
    ${mnl_class}    Fetch From Left    ${MO_items['class']}    :
    Set Test Variable    ${MO_items}
    Set Test Variable    ${mnl_class}
    Run Keyword If    not ${existed_CMD}    netact.Create Managed Object    operation=CREATE    plan=${plan}    meta_class=${mnl_class}:CMD
    ...    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    NetAct Create Managed Object    plan=${plan}    meta_class=${mnl_class}:HWRESETREQ    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_HWRES']}    &{para_dic}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Step ${index}: Check Reset ${mod} Behavior
    Log    Step ${index}: Check Reset ${mod} Behavior    console=True
    Wait Until Keyword Succeeds    3 min    2 sec    coam.Assert    ${mod}    ${selected_mod_internal_id}    operationalState=${_Disabled_}
    Wait Until Keyword Succeeds    3 min    2 sec    coam.Assert    ${mod}    ${selected_mod_internal_id}    operationalState=${_Enabled_}
    Wait Until Keyword Succeeds    3 min    3 sec    Check HWRESETRES Result

Check HWRESETRES Result
    ${BTS_scf_content}=    coam.Get SCF    export_type=configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_content}
    ${HWRESETRES_Result}=    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${plan_info['scf_distName']}/CMD-1/HWRESETREQ-1/HWRESETRES-1"]/p[@name="hwResetResult"]
    Should Be Equal As Strings    success    ${HWRESETRES_Result}

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
