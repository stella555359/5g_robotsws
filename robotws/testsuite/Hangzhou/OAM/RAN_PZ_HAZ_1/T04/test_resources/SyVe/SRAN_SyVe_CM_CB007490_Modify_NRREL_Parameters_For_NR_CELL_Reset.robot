*** Settings ***
Documentation       Test case for SyVe_CM_CB007490
...                 Author: Liu Bin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
# NRREL add plan will provision on NetAct
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${plan_path}      /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/Add_NRREL.xml
${COMMISSIONING_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml

*** Keywords ***
SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22434
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    New TC for CB007490.
    ...    Check whether nrcell will restart when nrrel is modified with or without parameter NRREL.sCellAdditionMethod:
    ...   |                             |remove NRREL|add NRREL |updateNRREL-.lcrId|add NRREL.sCellAdditionMethod|remove NRREL.sCellAdditionMethod|
    ...   |with NRREL.sCellAdditionMethod|NRCELL reset |NRCELL online |NRCELL reset     |      N/A               |NRCELL reset   |
    ...   |without NRREL.sCellAdditionMethod|NRCELL online|NRCELL online |NRCELL online |     NRCELL online      |    N/A        |
    ...    Precondition: Needs at least 3 NR cells, 2 NRRELs
    ...    The main steps performed for the test are:
    ...
    ...    - Get And Check SBTS Key MOs
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Modify NRREL Via NetAct Provision And Check Action
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...
    ...    Pass criteria: NRCELL actions as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 31.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22434 - New case
    ...    - 20.01.2022 - Modified by Liu Bin - https://jira3.ext.net.nokia.com/browse/TAT-22476 - Update according to status changes in CNI-61110
    ...    change the value of gloable variable ${plan_path} from .csv to .xml
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-22434_SRAN_SyVe_CM_Modify_NRREL_Parameters_For_NR_CELL_Reset_CB007490.png
    Set Tags    SyVe    AUTHOR-bin.7.liu@nokia.com    PHASE-CRT    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: Get And Check SBTS Key MOs
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Modify NRREL Via NetAct Provision And Check Action
    Step 6: Check final alarms status from WebEM
    Step 7: Check final alarms status from Netact

TC Setup
    Log    TC Setup    console=True
    Common Test Setup

TC Teardown
    Log    TC Teardown    console=True
    Particular Teardown

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${NAME}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${NAME}_backup
    Run Keyword If    ${NEED_RECOVER}    coam.Perform Commissioning    bts_id=${MRBTS_DN.split('-')[-1]}
    ...    scf_file=${COMMISSIONING_PATH}    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

Step ${index}: Get And Check SBTS Key MOs
    Log    Step ${index}: Get And Check SBTS Key MOs    console=True
    ${old_NIDD_versions}    Create List    SBTS22R4    SBTS23R1
    ${sw_head}    Fetch From Left    ${active SW version}    _
    ${is_old_NIDD}    Run Keyword And Return Status    List Should Contain Value    ${old_NIDD_versions}    ${sw_head}
    Set Test Variable    ${is_old_NIDD}
    ${scf_runtime_name_mapper}    ${dic_bts_infor}    Get BTS Key MOs Status
    Check BTS Key MOs Status All Online    ${dic_bts_infor}
    ${gNbCuType}    Pop From Dictionary    ${dic_bts_infor}    gNbCuType    SA
    ${MRBTS_DNs}    Get Dictionary Keys    ${scf_runtime_name_mapper["site"]}
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/${MRBTS_DNs[0]}
    Set Test Variable    ${GNB_CU_TYPE}    ${gNbCuType}
    Set Test Variable    ${NEED_RECOVER}    ${False}
    Run Keyword If    ${is_old_NIDD}    Adapt NRREL XML
    Add NRREL From CSV
    Set And Check NRREL Infor

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Modify NRREL Via NetAct Provision And Check Action
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Modify NRREL Via NetAct Provision And Check Action    console=True
    FOR    ${plan_info}    IN    @{PLAN_LIST}
        LOG    Provision for:\n${plan_info}    console=True
        Prepare SyVe Plan    ${plan_info}
        Provision And Check Action    ${NAME}    ${plan_info["expect_status"]}
    END
    Set Test Variable    ${NEED_RECOVER}    ${False}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Prepare SyVe Plan
    [Arguments]    ${plan_info}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${NAME}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${NAME}_backup
    ${plan}    NetAct Create Plan    ${NAME}    Automation for ${TEST_NAME}
    ${managed_object}    netact.Create Managed Object    plan=${plan}    meta_class=${VALUE_DIC_M_PARAM['meta_class']}
    ...    meta_version=${VALUE_DIC_M_PARAM['meta_version']}    mo_id=${VALUE_DIC_M_PARAM['mo_id']}
    ...    operation=${plan_info["${NRREL_M_DN}"]["operation"]}
    ...    &{plan_info["${NRREL_M_DN}"]["parameters"]}
    ${managed_object}    netact.Create Managed Object    plan=${plan}    meta_class=${VALUE_DIC_N_PARAM['meta_class']}
    ...    meta_version=${VALUE_DIC_N_PARAM['meta_version']}    mo_id=${VALUE_DIC_N_PARAM['mo_id']}
    ...    operation=${plan_info["${NRREL_N_DN}"]["operation"]}
    ...    &{plan_info["${NRREL_N_DN}"]["parameters"]}
    ${time}    Get Time    epoch
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${NAME}_${time}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${NAME}    operation_type=plan

Provision And Check Action
    [Arguments]    ${plan_name}    ${expect_status}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmd_str1}    Set Variable    racclimx.sh -planName ${plan_name} -DN ${MRBTS_DN} -createBackupPlan true -backupPlanName ${plan_name}_backup
    ${cmd_str2}    Set Variable    -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd_str1} ${cmd_str2}
    Set Test Variable    ${NEED_RECOVER}    ${True}
    ${ret}    Run Keyword And Return Status    Run Keyword If    "${expect_status}" == ""    Check All MO Status Keep Online
    ...    ELSE    Check MO Status Has Been Changed    ${expect_status}
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Be True    ${ret}
    Should Contain    ${result_Activate}    Provision of the plan was successful    ignore_case=True

Check MO Status Has Been Changed
    [Arguments]    ${expect_status}
    ${list_record_of_change1}    Get BTS Key MOs Status Duration Until Expected Changes    ${expect_status}    50
    ${list_record_of_change2}    Get BTS Key MOs Status Duration Until All Online
    ${list_record_of_change}    Combine Lists    ${list_record_of_change1}    ${list_record_of_change2}
    ${dic_key_MOs_status_duration}    Combine Changes Of BTS Key MOs Status    ${list_record_of_change}
    Check BTS Key MOs Status Duration    ${dic_key_MOs_status_duration}    ${expect_status}

Check All MO Status Keep Online
    FOR    ${i}    IN RANGE    ${0}    ${60}
        ${scf_runtime_name_mapper}    ${dic_bts_infor}    Get BTS Key MOs Status
        Check BTS Key MOs Status All Online    ${dic_bts_infor}
        sleep    1s
    END

Set And Check NRREL Infor
    Log    Set And Check NRREL Infor    console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${BTS_scf}    Admin Collect scf.xml with timestamp    folder_path=${BTSFiles}
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf}
    ${list_lcrId}    L_XML.Get Elements Texts    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/p[@name="lcrId"]
    ${count_NR_cell}    Get Length    ${list_lcrId}
    Should Be True    ${count_NR_cell} > ${2}    Needs at least 3 NR cells.
    ${nrrel_elements}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:NRREL"]
    ${count_NRREL}    Get Length    ${nrrel_elements}
    Should Be True    ${count_NRREL} > ${1}    Needs at least 2 NRREL.
    ${list_nrrel_M}    Create List
    ${list_nrrel_N}    Create List
    FOR    ${element}    IN    @{nrrel_elements}
        ${mo_dn}    L_XML.Get Element Attribute    ${element}    distName
        ${has_sCellAdditionMethod}    L_XML.Get Element Count    ${scf_xml}    .//managedObject[@distName="${mo_dn}"]/p[@name="sCellAdditionMethod"]
        ${list_pointer}    Set Variable If    '${has_sCellAdditionMethod}'=='${0}'    ${list_nrrel_N}    ${list_nrrel_M}
        Append To List    ${list_pointer}    ${mo_dn}
    END
    ${count}    Get Length    ${list_nrrel_M}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${NRREL_M_DN}    Set Variable    ${list_nrrel_M[${index}]}
    ${count}    Get Length    ${list_nrrel_N}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${NRREL_N_DN}    Set Variable    ${list_nrrel_N[${index}]}
    ${lcrId_M}    L_XML.Get Element Text    ${scf_xml}    .//managedObject[@distName="${NRREL_M_DN}"]/p[@name="lcrId"]
    ${lcrId_N}    L_XML.Get Element Text    ${scf_xml}    .//managedObject[@distName="${NRREL_N_DN}"]/p[@name="lcrId"]
    Remove Values From List    ${list_lcrId}    ${lcrId_M}    ${lcrId_N}
    ${count}    Get Length    ${list_lcrId}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${lcrId_R}    Set Variable    ${list_lcrId[${index}]}
    ${version}    L_XML.Get Element Attribute    ${scf_xml}    version    .//managedObject[@distName="${NRREL_M_DN}"]
    ${VALUE_DIC_M_PARAM}    Create Dictionary    meta_class=com.nokia.srbts.nrbts:NRREL    meta_version=${version}    mo_id=PLMN-PLMN/${NRREL_M_DN}
    ${version}    L_XML.Get Element Attribute    ${scf_xml}    version    .//managedObject[@distName="${NRREL_N_DN}"]
    ${VALUE_DIC_N_PARAM}    Create Dictionary    meta_class=com.nokia.srbts.nrbts:NRREL    meta_version=${version}    mo_id=PLMN-PLMN/${NRREL_N_DN}
    Set Test Variable    ${NRREL_M_DN}
    Set Test Variable    ${NRREL_N_DN}
    Set Test Variable    ${NRCELL_M_DN}    ${NRREL_M_DN.split('/NRREL-')[0]}
    Set Test Variable    ${NRCELL_N_DN}    ${NRREL_N_DN.split('/NRREL-')[0]}
    Set Test Variable    ${LCRID_M}    ${lcrId_M}
    Set Test Variable    ${LCRID_N}    ${lcrId_N}
    Set Test Variable    ${LCRID_R}    ${lcrId_R}
    Set Test Variable    ${VALUE_DIC_M_PARAM}
    Set Test Variable    ${VALUE_DIC_N_PARAM}
    ${tmpstr1}    Set Variable   {"${NRREL_M_DN}":{"operation":"update","parameters":
    ${tmpstr2}    Set Variable   {"lcrId":"${LCRID_R}"}},"${NRREL_N_DN}":{"operation":"update","parameters":{"lcrId":"${LCRID_R}"}},
    ${tmpstr3}    Set Variable   {"sCellAdditionMethod":"${EMPTY}"}},"${NRREL_N_DN}":{"operation":"update","parameters":{"sCellAdditionMethod":"0"}},
    ${tmpstr4}    Set Variable   "${NRREL_N_DN}":{"operation":"delete","parameters":{}},n":"update","parameters":{"sCellAdditionMethod":"0"}},
    ${tmpstr5}    Set Variable   ${tmpstr1}{"sCellAdditionMethod":"${EMPTY}"}},
    ${tmpstr6}    Set Variable   "${NRREL_N_DN}":{"operation":"update","parameters":{"sCellAdditionMethod":"0"}},
    ${tmpstr7}    Set Variable   ${tmpstr1}{"sCellAdditionMethod":"${EMPTY}",
    ${tmpstr8}    Set Variable   "sCellOperationalMode":"${EMPTY}"}},"${NRREL_N_DN}":{"operation":"update",
    ${tmpstr9}    Set Variable   "parameters":{"sCellAdditionMethod":"0","sCellOperationalMode":"0"}},
    ${tmpstr10}   Set Variable   {"${NRREL_M_DN}":{"operation":"delete","parameters":{}},"${NRREL_N_DN}":{"operation":"delete","parameters":{}},
    ${plan_string_2}    Set Variable If    ${is_old_NIDD}
    ...    ${tmpstr5}${tmpstr6}"expect_status":"${NRCELL_M_DN}:availabilityStatus:Offline;${NRCELL_M_DN}:operationalState:Disabled"}
    ...    ${tmpstr7}${tmpstr8}${tmpstr9}"expect_status":"${NRCELL_M_DN}:availabilityStatus:Offline;${NRCELL_M_DN}:operationalState:Disabled"}
    ${plan_data_1}    Evaluate
    ...    ${tmpstr1}${tmpstr2}"expect_status":"${NRCELL_M_DN}:availabilityStatus:Offline;${NRCELL_M_DN}:operationalState:Disabled"}
    ${plan_data_2}    Evaluate    ${plan_string_2}
    ${plan_data_3}    Evaluate    ${tmpstr10}"expect_status":"${NRCELL_N_DN}:availabilityStatus:Offline;${NRCELL_N_DN}:operationalState:Disabled"}
    ${PLAN_LIST}    Create List    ${plan_data_1}    ${plan_data_2}    ${plan_data_3}
    Set Test Variable    ${PLAN_LIST}
    LOG    ${PLAN_LIST}

Add NRREL From CSV
    Log    Add NRREL From CSV    console=True
    Set Test Variable    ${NAME}    TA_CB007490_Plan
    ${file_name}    Fetch From Right    ${plan_path}    /
    ${file_path}    Remove String    ${plan_path}    /${file_name}
    NetAct Import Plan    local_dir=${file_path}    file_name=${file_name}    plan_name=${NAME}
    ${expect_status}    Set Variable
    Provision And Check Action    plan_name=${NAME}    expect_status=${expect_status}

Adapt NRREL XML
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse Xml    ${plan_path}
    L_XML.Remove Elements    ${scf_xml}    .//managedObject/p[@name="sCellOperationalMode"]
    L_XML.Save Xml    ${scf_xml}    ${Test Results Dir}/NetActLogs/Add_NRREL.xml
    Set Test Variable    ${plan_path}    ${Test Results Dir}/NetActLogs/Add_NRREL.xml