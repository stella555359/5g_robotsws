*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${Integrate_Need}        ${False}

*** Keywords ***
SyVe_CM_CB007010-A_014_Enable_And_Disable_O_RAN_O1_NetConf_Server_On_NE
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  For case:RAN_ST_CB007010-A_014_CM_Enable and disable O-RAN O1 NetConf server on NE
    ...  The main steps performed for the test are:
    ...  - Disable O1 Protocol Status And Check
    ...  - Enable O1 Protocol Status And Check
    ...  - Change Mplane And Check
    ...  - Recover Mplane And Check
    ...  - Check Netconf Get After Full Commission
    ...  Pass criteria: Provision delta plan from SBTS,and check CCN and check configuration get from ONAP Netconf,
    ...  same as on get from NetAct. Site is OK with no any unexpected alarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.08.2023 - New case
    ...  - 23.07.2025 removed CB013033 limitation due to PR840751
    Set Tags    CA-CM    AUTHOR-bin.7.liu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    Log To Console    ${TEST_NAME} start.
    Step 1: Disable O1 Protocol Status And Check
    Step 2: Enable O1 Protocol Status And Check
    Comment    Step 3: Change Mplane And Check    #cannot run on simulator
    Comment    Step 4: Recover Mplane And Check    #cannot run on simulator
    Step 5: Check Netconf Get After Full Commission

TC Setup
    Log    TC Setup
    Common Test Setup    SetValidatePlanAgainstDetectedHW=${False}
    ${time}    Get Time    epoch
    Set Test Variable    ${BTS_ID}    ${MRBTS_DN.split("-")[-1]}
    Set Test Variable    ${ONAP_GET_OUT_FILE}    /tmp/CB007010-A_014_get-config_${time}.xml
    Comment    ${ONAP_INFOR}    Get Informations From ONAP    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Set Test Variable    ${ONAP_INFOR}
    ${file_content}    OperatingSystem.Get File    ${ONAP_IGNORE_PARAMS_FILE}
    ${ONAP_IGNORE_PARAMS}    Evaluate    ${file_content}
    Set Test Variable    ${ONAP_IGNORE_PARAMS}    #tmp variable for using simulator
    Comment    Run Keyword If    ${Integrate_Need}
    ...    Integrate SBTS To ONAP    ${BTS_ID}    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${BTS_ID}    ${ONAP['host_ip']}
    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs    file_name=scf_from_netact.xml
    ...    dist_names=${MRBTS_DN}    ui_values=${True}
    Set Test Variable    ${BTS_FULL_SCF_FILE}    ${Test Results Dir}/NetActLogs/scf_from_netact.xml
    ${scf_content}    L_XML.Parse XML    ${BTS_FULL_SCF_FILE}
    ${5G_ipaddressv4_dn}    L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@class="NRBTS"]/list[@name="s1Uplane"]//p[@name="ipV4AddressDN1"]
    ${5G_mplane_ip}    L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="PLMN-PLMN/${5G_ipaddressv4_dn}"]/p[@name="localIpAddr"]
    ${4G_ipaddressv4_dn}    L_XML.Get Element Text    ${scf_content}    .//managedObject[@class="TRSNW"]/p[@name="ipV4AddressDN1"]
    ${4G_mplane_ip}    L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="PLMN-PLMN/${4G_ipaddressv4_dn}"]/p[@name="localIpAddr"]
    ${CUR_IPADDRESSV4_DN}    Set Variable If    '${MPLANE_IP}'=='${4G_MPLANE_IP}'    ${4G_ipaddressv4_dn}    ${5G_ipaddressv4_dn}
    ${SECOND_IPADDRESSV4_DN}    Set Variable If    '${MPLANE_IP}'=='${4G_MPLANE_IP}'    ${5G_ipaddressv4_dn}    ${4G_ipaddressv4_dn}
    ${SECOND_MPLANE_IP}    Set Variable If    '${MPLANE_IP}'=='${4G_MPLANE_IP}'    ${5G_mplane_ip}    ${4G_mplane_ip}
    ${count}    L_XML.Get Element Count    ${scf_content}    .//managedObject[@class="SMOD_R"]
    ${xpath}    Set Variable If    '${count}'=='${1}'    .//managedObject[@class="SMOD_R"]/p[@name="serialNumber"]
    ...    .//managedObject[@class="SMOD_R"]/p[@name="activeRole" and text()="Primary"]/../p[@name="serialNumber"]
    ${PRIMARY_CORE_DN}    L_XML.Get Element Text    ${scf_content}    ${xpath}
    Set Test Variable    ${PRIMARY_CORE_DN}
    Set Test Variable    ${CUR_IPADDRESSV4_DN}
    Set Test Variable    ${SECOND_IPADDRESSV4_DN}
    Set Test Variable    ${SECOND_MPLANE_IP}

TC Teardown
    Log    TC Teardown
    Common Test Teardown

Get And Check Partial CM Data From ONAP
    [Arguments]    ${sbts_ip}
    ${DIC_DIF_ALL}    Create Dictionary
    ${DIC_NOT_EXIST_ALL}    Create Dictionary
    ${MO_type_list}    Create List    RMOD
    FOR    ${MO_type}    IN    @{MO_type_list}
        ${filter}    Set Variable    ManagedElement//${MO_type}
        ${diff_values}    ${not_exist_values}    Get And Check MO Data From ONAP    ${filter}    ${MO_type}    ${sbts_ip}
        Run Keyword If    '${diff_values.__len__()}'!='${0}'    Set To Dictionary    ${DIC_DIF_ALL}    ${MO_type}    ${diff_values}
        Run Keyword If    '${not_exist_values.__len__()}'!='${0}'    Set To Dictionary    ${DIC_NOT_EXIST_ALL}    ${MO_type}    ${not_exist_values}
    END
    ${DIC_DIF_ALL}    Remove Ignore Parameters    ${DIC_DIF_ALL}
    ${DIC_NOT_EXIST_ALL}    Remove Ignore Parameters    ${DIC_NOT_EXIST_ALL}
    Should Be Empty    ${DIC_DIF_ALL}
    Should Be Empty    ${DIC_NOT_EXIST_ALL}    #20250627:disable for CB013033 during 25R3 #20250723 removed this limitation

Get And Check MO Data From ONAP
    [Arguments]    ${filter_xpath}    ${MO_type}    ${sbts_ip}
    ${cmd}    Set Variable    get-config --source running --filter-xpath ${filter_xpath} --out ${ONAP_GET_OUT_FILE}
    Comment    Exucute One Command On Netconf CLI
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['netconf_server']}    ${sbts_ip}    ${cmd}
    Execute NetConf Command On ONAP Simulator   MRBTS-${BTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Comment    Get File From Pod To Local
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['netconf_server']}    ${ONAP_GET_OUT_FILE}
    Get File From Simulator To Local
    ...    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${ONAP_GET_OUT_FILE}    ${BTSFiles}/${ONAP_GET_OUT_FILE.split('/')[-1]}
    ${diff_values}    ${not_exist_values}    Check Netconf Get
    ...    ${MO_type}    ${BTS_FULL_SCF_FILE}    ${BTSFiles}/${ONAP_GET_OUT_FILE.split('/')[-1]}
    [Return]    ${diff_values}    ${not_exist_values}

Set O1 Protocol Status And Check
    [Arguments]    ${status}    ${sbts_ip}
    ${mplane_onap}    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${dic_actCmEventsReporting}    create dictionary    parameterName=actCmEventsReporting    operation=update    value=${status}
    ${dict_activateOranO1NetconfService}    create dictionary
    ...    parameterName=activateOranO1NetconfService    operation=update    value=${status}
    ${parameter_list}    Create List    ${dic_actCmEventsReporting}    ${dict_activateOranO1NetconfService}
    coam.Perform Object Recommissioning    dist_name=${mplane_onap}    operation=update    parameter=${parameter_list}
    Wait Until Keyword Succeeds    15 min    60 sec    Check SBTS SMOD RMOD Cells Alarms
    Comment    ${kw_ret}    Run Keyword And Return Status    Connect To SBTS Netconf    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${sbts_ip}
    ${kw_ret}    Run Keyword And Return Status
    ...    Connect To SBTS Netconf    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    simulator_code    ${sbts_ip}
    Should Be Equal    ${status}    ${kw_ret}

Connect To SBTS Netconf
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${pod}    ${sbts_ip}
    Log To Console    ${pod}
    Comment    ${ret}    Exucute One Command On Netconf CLI
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['netconf_server']}    ${sbts_ip}    status
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${host_ip}    ${user}    ${pwd}    status
    Should Contain    ${ret}    Current NETCONF session
    Should Contain    ${ret}    ${sbts_ip}
    [Return]    ${ret}

Check Netconf Get
    [Arguments]    ${MO_type}    ${scf_file}    ${onap_get_xml}
    ${scf_content}    L_XML.Parse XML    ${scf_file}
    ${onap_get_content}    L_XML.Parse XML    ${onap_get_xml}
    ${elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="${MO_type}"]
    ${count}    Get Length    ${elements}
    ${ran_index}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
    ${dn}    L_XML.Get Element Attribute    ${elements[${ran_index}]}    distName
    ${diff_values}    Create Dictionary
    ${not_exist_values}    Create Dictionary
    #Check parameters of ${dn} those are not list nor structure
    Get MO Different P Parameters Of Netconf Get    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    #Check parameters of ${dn} those are list
    Get MO Different List Parameters Of Netconf Get    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    #Check parameters of ${dn} those are structure
    Get MO Different Struture Parameters Of Netconf Get    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    [Return]    ${diff_values}    ${not_exist_values}

Change Mplane
    [Arguments]    ${mPlaneAddressDN}
    ${mplane_onap}    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${dict_mPlaneAddressDN}    Create Dictionary    parameterName=mPlaneAddressDN    operation=update    value=${mPlaneAddressDN}
    ${params_onap}    Create List    ${dict_mPlaneAddressDN}
    ${dic_onap_params}    Create Dictionary    distName=${mplane_onap}    operation=update    parameters=${params_onap}
    ${mplanenw}    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ${dic_mPlaneIpv4AddressDN}    Create Dictionary    parameterName=mPlaneIpv4AddressDN    operation=update    value=${mPlaneAddressDN}
    ${params_mplanenw}    Create List    ${dic_mPlaneIpv4AddressDN}
    ${dic_mplanenw_params}    Create Dictionary    distName=${mplanenw}    operation=update    parameters=${params_mplanenw}
    ${param_list}    Create List    ${dic_onap_params}    ${dic_mplanenw_params}
    ${param_json}    Convert To String    ${param_list}
    ${param_json}    Replace String    ${param_json}    u'    "
    ${param_json}    Replace String    ${param_json}    '    "
    coam.Perform delta recommissioning    ${param_json}

Check VES CCN
    [Arguments]    ${mPlaneAddressDN}    ${mplane_ip}    ${VES_CCN_msgs}
    ${mplane_onap}    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${dict_mPlaneAddressDN}    Create Dictionary    mPlaneAddressDN    ${mPlaneAddressDN}
    ${mplanenw}    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ${dic_mPlaneIpv4AddressDN}    Create Dictionary    mPlaneIpv4AddressDN    ${mPlaneAddressDN}
    ${onap_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${mplane_onap}    ${PRIMARY_CORE_DN}    ${mplane_ip}    replace
    ...    ${dict_mPlaneAddressDN}
    ${mplanenw_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${mplanenw}    ${PRIMARY_CORE_DN}    ${mplane_ip}    replace
    ...    ${dic_mPlaneIpv4AddressDN}
    Should Not Be Empty    ${onap_VES_CCN_msg}
    Should Not Be Empty    ${mplanenw_VES_CCN_msg}

Step ${index}: Disable O1 Protocol Status And Check
    Log To Console    Step ${index}: Disable O1 Protocol Status And Check
    Set O1 Protocol Status And Check    ${false}    ${MPLANE_IP}

Step ${index}: Enable O1 Protocol Status And Check
    Log To Console    Step ${index}: Enable O1 Protocol Status And Check
    Set O1 Protocol Status And Check    ${true}    ${MPLANE_IP}
    Get And Check Partial CM Data From ONAP    ${MPLANE_IP}
    ${SCF_RECOVER}    Admin Collect scf.xml with timestamp TAF    folder_path=${OUTPUT DIR}
    Set Test Variable    ${SCF_RECOVER}

Step ${index}: Change Mplane And Check
    Log To Console    Step ${index}: Change Mplane And Check
    Comment    ${ves_ccn_file}    Start VES Log Listen
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${BTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    Change Mplane    ${SECOND_IPADDRESSV4_DN}
    Get And Check Partial CM Data From ONAP    ${SECOND_MPLANE_IP}
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    Check VES CCN    ${SECOND_IPADDRESSV4_DN}    ${SECOND_MPLANE_IP}    ${VES_CCN_msgs}

Step ${index}: Recover Mplane And Check
    Log To Console    Step ${index}: Recover Mplane And Check
    Comment    ${ves_ccn_file}    Start VES Log Listen
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${BTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    Change Mplane    ${CUR_IPADDRESSV4_DN}
    Get And Check Partial CM Data From ONAP    ${MPLANE_IP}
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    Check VES CCN    ${CUR_IPADDRESSV4_DN}    ${MPLANE_IP}    ${VES_CCN_msgs}

Step ${index}: Check Netconf Get After Full Commission
    Log To Console    Step ${index}: Check Netconf Get After Full Commission
    Admin Get bts_id and perform commissioning    ${SCF_RECOVER}    timeout=600
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Comment    Connect To SBTS Netconf    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}
    Connect To SBTS Netconf    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    simulator_code    ${MPLANE_IP}
