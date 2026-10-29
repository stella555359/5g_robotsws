*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for RAN_ST_CB006092-A_002_CM_Upload full or part from SMO when VCU in commission state
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${RECOVERY_FLAG}    ${False}
@{Ignore_MOC}    SYNC_R

*** Keywords ***
VRAN_SyVe_CM_CB006092-A_002_Upload_Full_Or_Part_From_SMO_When_VCU_In_Commission_State
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.06.2025, yuyan.xu@nokia-sbell.com
    Step 1: Get Config And Check All CM Data From ONAP
    Step 2: Get And Check All CM Data From ONAP
    Step 3: Get And Check Partial CM Data From ONAP

Step ${index}: Get Config And Check All CM Data From ONAP
    Log To Console    Step ${index}: Get Config And Check All CM Data From ONAP
    ${time}    Get Time    epoch
    ${onap_get_file}    Set Variable    ${TEST_LOG_DIRECTORY}/onap_get_config_${time}.xml
    ${cmd}    Set Variable    get-config --source running --out /tmp/onap_get_config_${time}.xml
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vCU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}    onap_get_config_${time}.xml    ${onap_get_file}
    ${NOT_FOUND_DN}    Check MOs From Netconf    ${onap_get_file}    ${TEST_LOG_DIRECTORY}/backup_scf_vcu/vCU_scf.xml
    Should Be Empty    ${NOT_FOUND_DN}

Check MOs From Netconf
    [Arguments]    ${onap_get_xml}    ${scf_file}
    ${onap_get_content}    L_XML.Parse XML    ${onap_get_xml}
    ${scf_content}    L_XML.Parse XML    ${scf_file}
    ${managedObject_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject
    ${count}    Get Length    ${managedObject_elements}
    Log    ${count}
    ${mo_dn_list}    Create List
    FOR    ${managedObject_element}    IN    @{managedObject_elements}
        ${dn}    L_XML.Get Element Attribute    ${managedObject_element}    distName
        Append To List    ${mo_dn_list}    ${dn}
    END
    FOR    ${moc}    IN    @{Ignore_MOC}
        Remove Ignored MOC    ${mo_dn_list}    ${moc}
    END
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

Step ${index}: Get And Check All CM Data From ONAP
    Log To Console    Step ${index}: Get And Check All CM Data From ONAP
    ${time}    Get Time    epoch
    ${onap_get_file}    Set Variable    ${TEST_LOG_DIRECTORY}/onap_get_${time}.xml
    ${cmd}    Set Variable    get --out /tmp/onap_get_${time}.xml
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vCU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd}
    Get File From Simulator To Local
    ...    ${host_ip}    ${user}    ${pwd}    /tmp/onap_get_${time}.xml    ${onap_get_file}
    ${NOT_FOUND_DN}    Check MOs From Netconf    ${onap_get_file}    ${BTS_Scf_With_Runtime}
    Set Test Variable    ${NOT_FOUND_DN}
    Run Keyword And Ignore Error    Should Be Empty    ${NOT_FOUND_DN}

Step ${index}: Get And Check Partial CM Data From ONAP
    Log To Console    Step ${index}: Get And Check Partial CM Data From ONAP
    ${DIC_DIF_ALL}    Create Dictionary
    Set Test Variable    ${DIC_DIF_ALL}
    ${DIC_NOT_EXIST_ALL}    Create Dictionary
    Set Test Variable    ${DIC_NOT_EXIST_ALL}
    ${MO_type_list}    Create List    com.nokia.srbts.nrbts:NRCELL    com.nokia.srbts.nrbts:NRBTS
    ...    com.nokia.srbts.mnl:MPLANEONAP    com.nokia.srbts.eqmr:EQM_R    com.nokia.srbts.mnl:CELLMAPPING    com.nokia.srbts.tnl:ETHSVC
    FOR    ${MO_type}    IN    @{MO_type_list}
        ${filter}    Set Variable    ManagedElement//${MO_type.split(":")[-1]}
        ${diff_values}    ${not_exist_values}    Get And Check Partial CM Data From ONAP    ${filter}    ${MO_type}
        Run Keyword If    '${diff_values.__len__()}'!='${0}'
        ...    Set To Dictionary    ${DIC_DIF_ALL}    ${MO_type.split(":")[-1]}    ${diff_values}
        Run Keyword If    '${not_exist_values.__len__()}'!='${0}'
        ...    Set To Dictionary    ${DIC_NOT_EXIST_ALL}    ${MO_type.split(":")[-1]}    ${not_exist_values}
    END
    Log    ${DIC_DIF_ALL}
    Log    ${DIC_NOT_EXIST_ALL}
    ${DIC_DIF_ALL}    Remove Ignore Parameters    ${DIC_DIF_ALL}
    ${DIC_NOT_EXIST_ALL}    Remove Ignore Parameters    ${DIC_NOT_EXIST_ALL}
    Run Keyword And Ignore Error    Should Be Empty    ${DIC_DIF_ALL}
    Run Keyword And Ignore Error    Should Be Empty    ${DIC_NOT_EXIST_ALL}

Get And Check Partial CM Data From ONAP
    [Arguments]    ${filter_xpath}    ${MO_type}
    ${time}    Get Time    epoch
    ${onap_get_file}    Set Variable    ${TEST_LOG_DIRECTORY}/onap_get_${MO_type}_${time}.xml
    ${cmd}    Set Variable    get --filter-xpath ${filter_xpath} --out /tmp/onap_get_${MO_type}_${time}.xml
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vCU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd}
    Get File From Simulator To Local
    ...    ${host_ip}    ${user}    ${pwd}    /tmp/onap_get_${MO_type}_${time}.xml    ${onap_get_file}
    #yuki ${BTS_Scf_With_Runtime} 需要用netact export的plan吗
    ${diff_values}    ${not_exist_values}    Check Parameters From Netconf    ${MO_type}    ${BTS_Scf_With_Runtime}    ${onap_get_file}
    [Return]    ${diff_values}    ${not_exist_values}

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

Remove Ignore Parameters-delete
    [Arguments]    ${source_dic}
    ${file_content}    OperatingSystem.Get File    ${ONAP_IGNORE_PARAMS_FILE}
    ${ONAP_IGNORE_PARAMS}    Evaluate    ${file_content}
    Set Test Variable    ${ONAP_IGNORE_PARAMS}
    ${MOs}    Get Dictionary Keys    ${ONAP_IGNORE_PARAMS}
    FOR    ${MO}    IN    @{MOs}
        ${has_not_MO}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${source_dic}    ${MO}
        Continue For Loop If    ${has_not_MO}
        ${param_names}    Get From Dictionary    ${ONAP_IGNORE_PARAMS}    ${MO}
        Remove From Dictionary    ${source_dic['${MO}']}    @{param_names}
        ${count}    Get Length    ${source_dic['${MO}']}
        Run Keyword If    ${count}==${0}    Remove From Dictionary    ${source_dic}    ${MO}
    END
    [Return]    ${source_dic}

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Log    ${ReIntegrate_vDU}
    Common Test Setup For AIC
    #Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${du_release}    ${du_mr}
    #need develop kw
    #Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}
    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
    Set Test Variable    ${user}    ${ONAP["user"]}
    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
    Login To vCU By Rest
    ${vesSourceName}    Get Parameter Value From vCU     MRBTS-${vCU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName}
    ${dnPrefix}    Get Parameter Value From vCU     MRBTS-${vCU_id}    dnPrefix
    Set Test Variable    ${dnPrefix}
    ${time}    Get Time    epoch
    ${BTS_Scf_With_Runtime}    cu.get_current_plan_file    path=${TEST_LOG_DIRECTORY}/current_scf_${time}.xml    include_runtime_data=True
    ...    include_auto_config_data=${False}
    Set Test Variable    ${BTS_Scf_With_Runtime}

Case Postcondition
    Log To Console    Case Postcondition
    Common Test Teardown For AIC
    #Teardown NetAct