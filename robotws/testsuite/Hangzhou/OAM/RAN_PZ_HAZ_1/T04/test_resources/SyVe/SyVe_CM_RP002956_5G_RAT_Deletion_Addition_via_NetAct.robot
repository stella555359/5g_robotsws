*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${COMMISSIONING_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml

*** Keywords ***
SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21236
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision NR RAT delete and add from NetAct
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check NR cells and get parameters
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check SBTS reset
    ...    - Check SBTS SMOD RMOD Cells Alarms without NRCell
    ...    - Provision the backup plan
    ...    - Check SBTS SMOD RMOD Cells Alarms with NRCell
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...
    ...    Pass criteria: delete and add NR RAT provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 22.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21236
    ...    - SyVe_CM_RAT_Deletion_Addition_via_NetAct_RP002956_5G
    ...    - 04.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking and add step 9 12
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      fix: Get Plan -> Get Plan Configuration
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-21236_SyVe_CM_RAT_Deletion_Addition_via_NetAct_RP002956_5G.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Check NR cells and get parameters
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Provision the plan SyVe
    Step 9: Check SBTS reset
    Step 10: Check SBTS SMOD RMOD Cells Alarms without NRCell
    Step 11: Provision the backup plan
    Step 12: Check SBTS reset
    Step 13: Check SBTS SMOD RMOD Cells Alarms with NRCell
    Step 14: Check final alarms status from WebEM
    Step 15: Check final alarms status from Netact

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown

Get SBTS parameters
    ${dic_bts_infor}    coam.Get Bts Info
    ${MRBTS_ID}    Pop From Dictionary    ${dic_bts_infor}    mrbtsID
    ${nrBtsId}    Pop From Dictionary    ${dic_bts_infor}    nrBtsId
    ${scf_runtime_name_mapper}    ${all_cell_status}    Get Current Name And Status Of All Cells
    Set Test Variable    ${MRBTS_ID}
    Set Test Variable    ${NRBTS_NAME}    MRBTS-${MRBTS_ID}/NRBTS-${nrBtsId}
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/MRBTS-${MRBTS_ID}
    Set Test Variable    ${INITIAL_CELLS_STATUS}    ${all_cell_status}

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${scf_runtime_name_mapper}    ${all_cell_status}    Get Current Name And Status Of All Cells
    Dictionaries Should Be Equal    ${all_cell_status}    ${INITIAL_CELLS_STATUS}
    ${cells_same_as_initial}    Run Keyword And Return Status    Dictionaries Should Be Equal
    ...    ${all_cell_status}    ${INITIAL_CELLS_STATUS}
    ${is_all_service_ok}    Run Keyword And Return Status    Check SBTS SMOD RMOD Cells Alarms
    Run Keyword If    '${cells_same_as_initial}'=='False' or '${is_all_service_ok}'=='False'
    ...    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${COMMISSIONING_PATH}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown


Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Check SBTS SMOD RMOD Cells Alarms
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    Set Test Variable    ${NAME}    ${TEST_NAME}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${elements_for_nrbts}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${NRBTS_NAME}")]
    ${LCELNR_elements}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.mnl:LCELNR"]
    ${nr_cellMapping_reg_str}    L_XML.Get Element Attribute    ${LCELNR_elements[0]}    distName
    ${nr_cellMapping_reg_str}    ${tmp_s}    Split String From Right    ${nr_cellMapping_reg_str}    -    1
    ${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[contains(@distName,"${nr_cellMapping_reg_str}-")]
    ${elements_to_delete}    Combine Lists    ${elements_for_nrbts}    ${elements_for_cellMapping}
    FOR    ${element}    IN    @{elements_to_delete}
        ${MO_items}    L_XML.Get Element Attributes    ${element}
        ${managed_object}    netact.create_managed_object    plan=${plan}    meta_class=${MO_items['class']}
        ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${MO_items["distName"]}
        ...    operation=DELETE
        ${status}    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan}
        ...    mo_id=PLMN-PLMN/${MO_items["distName"]}
        Run Keyword If    ${status}    Run Keywords    Log    MO successfully created: ${managed_object}    console=True
        ...    AND    Log    Parameters were set with plan ${plan}    console=True
        ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
        ...    AND    Fail    MO creation failed!
    END

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${NAME}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${NAME}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${NAME}    dist_names=${MRBTS_DN}    backup_plan_name=${NAME}_backup
    ...    create_backup_plan=True    provisioning_operation=activate

Step ${index}: Check SBTS reset
    [Documentation]    This KW is Wait Until SBTS Disconnected, for linux system only.
    ...    Wait until 192.168.255.129 is not ping able from local PC.
    ...
    ...    *AUTHOR* yuyan.xu@nokia-sbell.com
    Log    Step ${index}: Check SBTS reset    console=True
    Wait Until Keyword Succeeds    300s    1s    Check IP Is Pingable    192.168.255.129    expect_pingable=${False}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check SBTS SMOD RMOD Cells Alarms ${with_or_without} NRCell
    Log    Step ${index}: Check SBTS SMOD RMOD Cells Alarms ${with_or_without} NRCell    console=True
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    ${expect_ret}    Set Variable If    '${with_or_without}'=='without'    FAIL    PASS
    ${has_cell}    ${kw_ret}    Run Keyword And Ignore Error    coam.Assert Any    NRCEL
    Should Be Equal As Strings    ${has_cell}    ${expect_ret}
    Return From Keyword If    '${with_or_without}'=='without'
    ${scf_runtime_name_mapper}    ${all_cell_status}    Get Current Name And Status Of All Cells
    Dictionaries Should Be Equal    ${all_cell_status}    ${INITIAL_CELLS_STATUS}

Step ${index}: Check NR cells and get parameters
    Log    Step ${index}: Check NR cells and get parameters    console=True
    Get SBTS parameters
