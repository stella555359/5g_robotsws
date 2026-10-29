*** Settings ***
Documentation       Test case for SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${test_data}      /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/delta_commissioning/dummy_mo_NetAct/dummy_mo_data.yaml
${config_path}    /home/ute/btsauto/hran_ta/config

*** Keywords ***
TC__SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19760
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing dummy manage object create and delete from NetAct and check the actual configuration based on random plan
    ...    The main steps performed for the test are:
    ...    - Step 1: Dummy Mo Select Plans
    ...    - Step 2: TC MO Check And Preparation
    ...    - Step 3: Check initial BTS state
    ...    - Step 4: Check initial alarms status from WebEM
    ...    - Step 5: Check initial alarms status from Netact
    ...    - Step 6: Upload configuration status
    ...    - Step 7: NetAct Import the Plan to Create Dummy MO
    ...    - Step 8: Provision the plan to create Dummy MO
    ...    - Step 9: Check added Dummy MO in Netact actual plan
    ...    - Step 10: NetAct Import the Plan to Delete Dummy MO
    ...    - Step 11: Provision the plan to delete Dummy MO
    ...    - Step 12: Check deleted Dummy MO in Netact actual plan
    ...    - Step 13: Check final alarms status from WebEM
    ...    - Step 14: Check final alarms status from Netact
    ...    - Step 15: Check final BTS state
    ...    - Step 16: Check final number and state of Cells and RMs
    ...    Pass criteria: creation and deletion works as expected for dummy MO; SBTS status, cell status and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19760 -
    ...    SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct
    ...    - 17.07.2020 - https://jira3.ext.net.nokia.com/browse/TAT-19904 -
    ...    Update code in resource for SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct
    ...    - 11.08.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20111 -
    ...    SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct enhancement to cover parent MO deletion scenario
    ...    - 31.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21121 -
    ...    Update to replace infomodel keywords to admin keywords
    ...    - 07.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21121 -
    ...    add new variable "config_path" for utecloud optimization
    ...    - 02.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697 -
    ...    Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    - 20.01.2022 - Modified by Xu Yuyan  - https://jira3.ext.net.nokia.com/browse/TAT-22476 -
    ...    Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847 -
    ...    Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/TAT-19760_SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct.png
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_NSB_MN_SRAN_PROD_HZH_OPER1_VRF@internal.nsn.com
    Step 1: Dummy Mo Select Plans
    Step 2: TC MO Check And Preparation
    Step 3: Check Initial BTS State
    Step 4: Check Initial Alarms Status from WebEM
    Step 5: Check Initial Alarms Status from Netact
    Step 6: Upload Configuration Status
    Step 7: NetAct Import the Plan to Create Dummy MO
    Step 8: Provision the Plan to Create Dummy MO
    Step 9: Check Added Dummy MO in Netact Actual Plan
    Step 10: NetAct Import the Plan to Delete Dummy MO
    Step 11: Provision the Plan to Delete Dummy MO
    Step 12: Check Deleted Dummy MO in Netact Actual Plan
    Step 13: Check Final Alarms Status from WebEM
    Step 14: Check Final Alarms Status from Netact
    Step 15: Check Final BTS State
    Step 16: Check Final Number and State of Cells and RMs

Step ${index}: Dummy MO Select Plans
    Log    Step ${index}: Dummy MO Select Plan    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${lnbts_id}=    Fetch LNBTS ID
    Set Test Variable    ${lnbts_id}
    ${TEST_DATA}    Load And Convert Json File    ${test_data}
    Set Test Variable    ${TEST_DATA}
    ${TEST_PLANS}    Random Select And Convert Plan From Test Data    ${TEST_DATA}
    Set Test Variable    ${TEST_PLANS}

Step ${index}: TC MO Check And Preparation
    Log    Step ${index}: TC MO check and preparation started    console=True
    Set Test Variable    ${parent_create_flag}    ${False}
    Set Test Variable    ${create_plan_path}    ${TEST_PLANS}[create_plan_path]
    Set Test Variable    ${delete_plan_path}    ${TEST_PLANS}[delete_plan_path]
    Set Test Variable    ${parent_create_plan_path}    ${TEST_PLANS}[parent_create_plan_path]
    Set Test Variable    ${parent_delete_plan_path}    ${TEST_PLANS}[parent_delete_plan_path]
    Run Keyword If    '${parent_create_plan_path}'!='${EMPTY}'    NetAct Check Parent MO ExistOrNot
    NetAct Check MO ExistOrNot

Step ${index}: Check ${when} BTS State
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} Alarms Status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} Alarms Status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload Configuration Status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: NetAct Import the Plan to Create Dummy MO
    Log    Step ${index}: NetAct Import the Plan to Create Dummy MO    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    ${file_name_create}    Fetch From Right    ${create_plan_path}    /
    ${file_path}    Remove String    ${create_plan_path}    /${file_name_create}
    Set Test Variable    ${plan_name_create}    Create_Dummy_MRBTS-${mrbts_id}_${timestamp}
    NetAct Import Plan    local_dir=${file_path}    file_name=${file_name_create}    plan_name=${plan_name_create}

Step ${index}: NetAct Import the Plan to Delete Dummy MO
    Log    Step ${index}: NetAct Import the Plan to Delete Dummy MO    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    ${file_name_delete}    Fetch From Right    ${delete_plan_path}    /
    ${file_name_delete_parent}    Fetch From Right    ${parent_delete_plan_path}    /
    ${file_path}    Remove String    ${delete_plan_path}    /${file_name_delete}
    Set Test Variable    ${plan_name_delete}    Delete_Dummy_MRBTS-${mrbts_id}_${timestamp}
    Run Keyword If    ${parent_create_flag}==${True} and '${parent_delete_plan_path}'!='${EMPTY}'
    ...    Run Keywords    NetAct Import Plan    local_dir=${file_path}    file_name=${file_name_delete_parent}    plan_name=${plan_name_delete}
    ...    AND    Append To List    ${mo_dic_keys}    ${parent_mo_dn}
    ...    ELSE    NetAct Import Plan    local_dir=${file_path}    file_name=${file_name_delete}    plan_name=${plan_name_delete}

Step ${index}: Provision the Plan to Create Dummy MO
    Log    Step ${index}: Provision the Plan to Create Dummy MO    console=True
    Provision Plan And Check Action    plan_name=${plan_name_create}    backup_plan_name=${plan_name_create}_backup

Step ${index}: Provision the Plan to Delete Dummy MO
    Log    Step ${index}: Provision the Plan to Delete Dummy MO    console=True
    Provision Plan And Check Action    plan_name=${plan_name_delete}    backup_plan_name=None

Step ${index}: Check Added Dummy MO in Netact Actual Plan
    Log    Step ${index}: Check Added Dummy MO in Netact Actual Plan    console=True
    FOR    ${key}    IN    @{mo_dic_keys}
        Log    ${key}
        ${status}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${key}    &{mo_dic["${key}"]}
        Run Keyword If    ${status}    Log    Dummy MO ${key} is created successfully    console=True
        ...    ELSE    Fail    Dummy MO ${key} is failed to create
    END

Step ${index}: Check Deleted Dummy MO in Netact Actual Plan
    Log    Step ${index}: Check Deleted Dummy MO in Netact Actual Plan    console=True
    FOR    ${key}    IN    @{mo_dic_keys}
        Log    ${key}
        ${status}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${key}    &{EMPTY}
        Run Keyword If    '${status}' == 'False'    Log    Dummy MO ${key} is deleted successfully    console=True
        ...    ELSE    Fail    Dummy MO ${key} is failed to delete
    END

Step ${index}: Check Final Number and State of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Provision Plan And Check Action
    [Arguments]    ${plan_name}    ${backup_plan_name}
    Log    Provision Plan And Check Action    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd_part1}    Set Variable    racclimx.sh -planName ${plan_name} -DN ${MRBTS_DN} -createBackupPlan true -backupPlanName ${backup_plan_name}
    ${cmd_part2}    Set Variable    -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd_part1} ${cmd_part2}
    Log    Check Action    console=True
    FOR    ${index}    IN RANGE    0    20
        Sleep    3s
        Run Keyword If    '${TEST_DATA_SELECTED}[Actions][expect]' == 'online'    Check All Cells On Air
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Check All Cells On Air
    ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
    ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
    ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
    ${nrcell}    Run Keyword And Return Status    coam.Assert Any    NRCEL
    ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}
    ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status    coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}
    ${lncell_onair}    Run Keyword If    ${lncell}    Run Keyword And Return Status    coam.Assert Every    LNCEL    ${cells_LTE_expected_state}
    ${nrcell_onair}    Run Keyword If    ${nrcell}    Run Keyword And Return Status    coam.Assert Every    NRCEL    ${cells_NR_expected_state}
    Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
    Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
    Run Keyword If    ${lncell}    Should Be True    ${lncell_onair}
    Run Keyword If    ${nrcell}    Should Be True    ${nrcell_onair}

Generate Param Dic
    [Arguments]    ${elements}
    ${param_dic}    Create Dictionary
    FOR    ${item}    IN    @{elements}
        ${key}=    L_XML.Get Element Attribute    ${item}    name
        ${value}=    L_XML.Get Element Text    ${item}
        Set To Dictionary    ${param_dic}    ${key}=${value}
    END
    [Return]    ${param_dic}

Fetch MO Param From Plan
    [Arguments]    ${plan}
    ${mo_dic}    Create Dictionary
    ${param_EMPTY}    Create Dictionary
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${create_plan_xml}=    L_XML.Parse xml    ${plan}
    ${MO_items}=    L_XML.Get Elements    ${create_plan_xml}    .//managedObject[@operation="create"]
    Set Test Variable    ${MO_items}
    FOR    ${item}    IN    @{MO_items}
        ${key}=    L_XML.Get Element Attribute    ${item}    distName
        ${para_items}=    L_XML.Get Elements    ${create_plan_xml}    .//managedObject[@distName="${key}"]/p
        ${count}=    Get Length    ${para_items}
        Run Keyword If    '${count}' == '0'    Run Keywords    Set To Dictionary    ${mo_dic}    ${key}    ${param_EMPTY}
        ...    AND    Continue For Loop
        ${param_dic}    Generate Param Dic    ${para_items}
        Set To Dictionary    ${mo_dic}    ${key}    ${param_dic}
    END
    [Return]    ${mo_dic}

Generate Plan From Template
    [Arguments]    ${source_plan}    ${target_plan}=tmp_data.xml
    ${file_content}    OperatingSystem.Get File    ${source_plan}
    ${file_content}    Replace Variables    ${file_content}
    Create File    ${target_plan}    ${file_content}

Random Select And Convert Plan From Test Data
    [Arguments]    ${data}
    ${count}    Get Length    ${data}
    ${random}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
    Set Test Variable    ${TEST_DATA_SELECTED}    ${data}[${random}]
    ${create_plan_path}    Set Variable    ${TEST_DATA_SELECTED}[Plans][0][create_plan_path]
    ${delete_plan_path}    Set Variable    ${TEST_DATA_SELECTED}[Plans][0][delete_plan_path]
    ${parent_create_plan_path}    Set Variable    ${TEST_DATA_SELECTED}[Plans][0][parent_create_plan_path]
    ${parent_delete_plan_path}    Set Variable    ${TEST_DATA_SELECTED}[Plans][0][parent_delete_plan_path]
    ${create_plan_name}    Fetch From Right    ${create_plan_path}    /
    ${delete_plan_name}    Fetch From Right    ${delete_plan_path}    /
    ${parent_create_plan_name}    Fetch From Right    ${parent_create_plan_path}    /
    ${parent_delete_plan_name}    Fetch From Right    ${parent_delete_plan_path}    /
    Set Test Variable    ${target_plan_path}    ${Test Results Dir}/NetActLogs
    ${plans}    Create Dictionary
    Generate Plan From Template    ${create_plan_path}    ${target_plan_path}/Plan_Dummy_MO_${create_plan_name}
    Generate Plan From Template    ${delete_plan_path}    ${target_plan_path}/Plan_Dummy_MO_${delete_plan_name}
    ${len}    Get Length    ${parent_create_plan_path}
    Run Keyword If    '${len}' != '${0}'    Run Keywords    Generate Plan From Template    ${parent_create_plan_path}
    ...    ${target_plan_path}/Plan_Dummy_MO_${parent_create_plan_name}
    ...    AND    Set To Dictionary    ${plans}    parent_create_plan_path    ${target_plan_path}/Plan_Dummy_MO_${parent_create_plan_name}
    ...    ELSE    Set To Dictionary    ${plans}    parent_create_plan_path    ${EMPTY}
    ${len1}    Get Length    ${parent_delete_plan_name}
    Run Keyword If    '${len1}' != '${0}'    Run Keywords    Generate Plan From Template    ${parent_delete_plan_path}
    ...    ${target_plan_path}/Plan_Dummy_MO_${parent_delete_plan_name}
    ...    AND    Set To Dictionary    ${plans}    parent_delete_plan_path    ${target_plan_path}/Plan_Dummy_MO_${parent_delete_plan_name}
    ...    ELSE    Set To Dictionary    ${plans}    parent_delete_plan_path    ${EMPTY}
    Set To Dictionary    ${plans}    create_plan_path    ${target_plan_path}/Plan_Dummy_MO_${create_plan_name}
    Set To Dictionary    ${plans}    delete_plan_path    ${target_plan_path}/Plan_Dummy_MO_${delete_plan_name}
    [Return]    ${plans}

NetAct Check MO ExistOrNot
    ${mo_dic}    Fetch MO Param From Plan    ${create_plan_path}
    ${mo_dic_keys}    Get Dictionary Keys    ${mo_dic}
    Set Test Variable    ${mo_dic}
    Set Test Variable    ${mo_dic_keys}
    ${mo_dn}    Get From Dictionary    ${mo_dic}    ${mo_dic_keys[0]}
    Set Test Variable    ${single_mo_distName}    ${mo_dn}
    ${plan_name_delete}    Fetch From Right    ${delete_plan_path}    /
    ${plan_path}    Remove String    ${delete_plan_path}    /${plan_name_delete}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${existed_MO}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${mo_dn}    &{EMPTY}
    Set Test Variable    ${existed_MO}
    Set Test Variable    ${plan_name_preparation}    MRBTS-${mrbts_id}_${timestamp}_Delete_MO_When_Exist
    Run Keyword If    ${existed_MO}    Run Keywords
    ...    Log    TC check failed: Dummy MO to be provisioned: ${mo_dn} already exist in current configuration    level=WARN
    ...    AND    NetAct Import Plan    local_dir=${plan_path}    file_name=${plan_name_delete}    plan_name=${plan_name_preparation}
    ...    AND    NetAct Provision Plan    plan_name=${plan_name_preparation}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    ...    ELSE    Log    TC Parent MO successfully checked! ${mo_dn} not exist in current configuration.

NetAct Check Parent MO ExistOrNot
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${create_plan_xml}=    L_XML.Parse xml    ${parent_create_plan_path}
    ${item}=    L_XML.Get Element    ${create_plan_xml}    .//managedObject[@operation="create"]
    ${parent_mo_dn}=    L_XML.Get Element Attribute    ${item}    distName
    Set Test Variable    ${parent_mo_dn}
    ${existed_parent_MO}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${parent_mo_dn}    &{EMPTY}
    ${plan_name}    Fetch From Right    ${parent_create_plan_path}    /
    ${plan_path}    Remove String    ${parent_create_plan_path}    /${plan_name}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${plan_name_parent_create}    MRBTS-${mrbts_id}_${timestamp}_create_parent_MO
    Run Keyword If    not ${existed_parent_MO}    Run Keywords
    ...    Log    TC check failed: Dummy MO to be provisioned has parent MO ${parent_mo_dn} not exist in current configuration    level=WARN
    ...    AND    NetAct Import Plan    local_dir=${plan_path}    file_name=${plan_name}    plan_name=${plan_name_parent_create}
    ...    AND    NetAct Provision Plan    plan_name=${plan_name_parent_create}    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False
    ...    provisioning_operation=activate
    ...    AND    Run Keyword And Ignore Error    Check If NetAct Plan Is Deleted    plan_name=${plan_name_parent_create}
    ...    AND    Set Test Variable    ${parent_create_flag}    ${True}
    ...    ELSE    Log    TC Parent MO successfully checked! ${parent_mo_dn} already exist in current configuration.

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name_create}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name_create}_backup
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name_delete}
    ${current_plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${single_mo_distName}    &{EMPTY}
    Run Keyword If    '${current_plan_values}' != '${existed_MO}'    Run Keywords
    ...    Log    Parameters were not reset to initial values! Probably backup plan was not provisioned!    level=WARN
    ...    AND    Log    Will perform commissioning with initial scf!    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
