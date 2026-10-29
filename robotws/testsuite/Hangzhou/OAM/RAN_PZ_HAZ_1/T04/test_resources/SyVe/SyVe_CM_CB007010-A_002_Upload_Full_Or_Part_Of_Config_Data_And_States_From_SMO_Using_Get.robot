*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${Integrate_Need}        ${False}
@{Ignore_MOC}    SYNC_R

*** Keywords ***
SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  For case:RAN_ST_CB007010-A_002_CM_Upload full or part of Configuration Data and State Data from SMO using get operation
    ...  The main steps performed for the test are:
    ...  - Get And Check Partial CM Data From ONAP
    ...  - Get And Check All CM Data From ONAP
    ...  - Check Compare Result
    ...  Pass criteria: Check configuration get from ONAP Netconf, same as on get from NetAct
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.08.2023 - New case
    ...  - 23.07.2025 removed CB013033 limitation due to PR840751
    Set Tags    CA-CM    AUTHOR-bin.7.liu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    Log To Console    ${TEST_NAME} start.
    Step 1: Get And Check Partial CM Data From ONAP
    Step 2: Get And Check All CM Data From ONAP
    Step 3: Check Compare Result

TC Setup
    Log    TC Setup
    Common Test Setup
    Set Test Variable    ${BTS_ID}    ${MRBTS_DN.split("-")[-1]}
    Comment    ${ONAP_INFOR}    Get Informations From ONAP    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Set Test Variable    ${ONAP_INFOR}
    ${file_content}    OperatingSystem.Get File    ${ONAP_IGNORE_PARAMS_FILE}
    ${ONAP_IGNORE_PARAMS}    Evaluate    ${file_content}
    Set Test Variable    ${ONAP_IGNORE_PARAMS}    #tmp variable for using simulator
    Comment    Run Keyword If    ${Integrate_Need}
    ...    Integrate SBTS To ONAP    ${BTS_ID}    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${BTS_ID}    ${ONAP['host_ip']}
    NetAct CM Upload    dist_names=${MRBTS_DN}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=scf_from_netact.xml
    ...    dist_names=${MRBTS_DN}    plan_name=None   operation_type=actual   ui_values=${True}
    Set Test Variable    ${BTS_FULL_SCF_FILE}    ${Test Results Dir}/NetActLogs/scf_from_netact.xml
    ${scf_file_sbts}    Admin Collect scf.xml with timestamp TAF
    ...    folder_path=${Test Results Dir}/NetActLogs    export_type=configurationAndRuntimeObjects
    Set Test Variable    ${SCF_FILE_SBTS}
    ${DIC_DIF_ALL}    Create Dictionary
    Set Test Variable    ${DIC_DIF_ALL}
    ${DIC_NOT_EXIST_ALL}    Create Dictionary
    Set Test Variable    ${DIC_NOT_EXIST_ALL}

TC Teardown
    Log    TC Teardown
    Common Test Teardown

Check MOs From Netconf
    [Arguments]    ${onap_get_xml}    ${scf_file}
    ${onap_get_content}    L_XML.Parse XML    ${onap_get_xml}
    ${scf_content}    L_XML.Parse XML    ${scf_file}
    ${managedObject_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject
    ${count}    Get Length    ${managedObject_elements}
    ${mo_dn_list}    Create List
    FOR    ${managedObject_element}    IN    @{managedObject_elements}
        ${dn}    L_XML.Get Element Attribute    ${managedObject_element}    distName
        Append To List    ${mo_dn_list}    ${dn}
    END
    FOR    ${moc}    IN    @{Ignore_MOC}
        Remove Ignored MOC    ${mo_dn_list}    ${moc}
    END
    Log    ${count}
    ${not_found_DN}    Create List
    FOR    ${dn}    IN    @{mo_dn_list}
        ${xpath}    Transfer SCF DN To Xpath Of ONAP Get Result    ${dn.replace("PLMN-PLMN/","")}
        ${is_found_on_onap}    Run Keyword And Return Status    L_XML.Element Should Exist    ${onap_get_content}    ${xpath}
        Continue For Loop If    ${is_found_on_onap}
        ${tmp_list}    Create List    ${dn}    ${xpath}
        Append To List    ${not_found_DN}    ${tmp_list}
    END
    [Return]    ${not_found_DN}

Remove Ignored MOC
    [Arguments]    ${mo_dn_list}    ${moc}
    FOR    ${dn}    IN    @{mo_dn_list}
        ${should_be_ignored}    Run Keyword And Return Status    Should Contain    ${dn}     ${moc}
        Run Keyword If    ${should_be_ignored}    Remove Values From List   ${mo_dn_list}    ${dn}
    END

Check Parameters From Netconf
    [Arguments]    ${MO_type}    ${scf_file}    ${onap_get_xml}
    ${diff_values}    Create Dictionary
    ${not_exist_values}    Create Dictionary
    ${scf_content}    L_XML.Parse XML    ${scf_file}
    ${onap_get_content}    L_XML.Parse XML    ${onap_get_xml}
    ${elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="${MO_type}"]
    ${count}    Get Length    ${elements}
    Return From Keyword If    ${count}==0    ${EMPTY}    ${EMPTY}
    ${ran_index}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
    ${dn}    L_XML.Get Element Attribute    ${elements[${ran_index}]}    distName
    #Check parameters of ${dn} those are not list nor structure
    Get MO Different P Parameters Of Netconf Get
    ...    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    #Check parameters of ${dn} those are list
    Get MO Different List Parameters Of Netconf Get
    ...    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    #Check parameters of ${dn} those are structure
    Get MO Different Struture Parameters Of Netconf Get
    ...    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    [Return]    ${diff_values}    ${not_exist_values}

Get And Check Patial CM Data From ONAP
    [Arguments]    ${filter_xpath}    ${MO_type}
    ${time}    Get Time    epoch
    ${onap_get_file}    Set Variable    ${BTSFiles}/onap_get_${MO_type}_${time}.xml
    ${cmd}    Set Variable    get --filter-xpath ${filter_xpath} --out /tmp/onap_get_${MO_type}_${time}.xml
    Comment    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}   ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    /tmp/onap_get_${MO_type}_${time}.xml    ${onap_get_file}
    Get File From Simulator To Local
    ...    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    /tmp/onap_get_${MO_type}_${time}.xml    ${onap_get_file}
    ${diff_values}    ${not_exist_values}    Check Parameters From Netconf    ${MO_type}    ${BTS_FULL_SCF_FILE}    ${onap_get_file}
    [Return]    ${diff_values}    ${not_exist_values}

Step ${index}: Get And Check All CM Data From ONAP
    Log To Console    Step ${index}: Get And Check All CM Data From ONAP
    ${time}    Get Time    epoch
    ${onap_get_file}    Set Variable    ${BTSFiles}/onap_get_${time}.xml
    ${cmd}    Set Variable    get --out /tmp/onap_get_${time}.xml
    Comment    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    /tmp/onap_get_${time}.xml    ${onap_get_file}
    Get File From Simulator To Local
    ...    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    /tmp/onap_get_${time}.xml    ${onap_get_file}
    ${NOT_FOUND_DN}    Check MOs From Netconf    ${onap_get_file}    ${SCF_FILE_SBTS}
    Set Test Variable    ${NOT_FOUND_DN}

Step ${index}: Get And Check Partial CM Data From ONAP
    Log To Console    Step ${index}: Get And Check Partial CM Data From ONAP
    ${MO_type_list}    Create List    GNBCF_R    GNCEL_R    WNCEL    NRCELL    LNCEL
    ...    NRBTS    LNBTS    MPLANEONAP    EQM_R    CELLMAPPING    ETHSVC
    FOR    ${MO_type}    IN    @{MO_type_list}
        ${filter}    Set Variable    ManagedElement//${MO_type}
        ${diff_values}    ${not_exist_values}    Get And Check Patial CM Data From ONAP    ${filter}    ${MO_type}
        Run Keyword If    '${diff_values.__len__()}'!='${0}'
        ...    Set To Dictionary    ${DIC_DIF_ALL}    ${MO_type}    ${diff_values}
        Run Keyword If    '${not_exist_values.__len__()}'!='${0}'
        ...    Set To Dictionary    ${DIC_NOT_EXIST_ALL}    ${MO_type}    ${not_exist_values}
    END

Step ${index}: Check Compare Result
    Log To Console    Step ${index}: Check Compare Result
    ${DIC_DIF_ALL}    Remove Ignore Parameters    ${DIC_DIF_ALL}
    ${DIC_NOT_EXIST_ALL}    Remove Ignore Parameters    ${DIC_NOT_EXIST_ALL}
    #20250214:disable for CB013033 during 25R3 #20250723 removed this limitation
    Should Be Empty    ${DIC_DIF_ALL}
    Should Be Empty    ${DIC_NOT_EXIST_ALL}
    Should Be Empty    ${NOT_FOUND_DN}