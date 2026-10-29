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
SyVe_CM_CB007010-E_010_Verify_VES_CCN_And_Netconf_Get_Client_During_Provission_In_Parallel
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For case:RAN_ST_CB007010-E_010_CM_Verify CCN operation on O1 VES Endpoint and Netconf Client upload operation in parallel
    ...  The main steps performed for the test are:
    ...  - Check Netconf Get All And VES CCN During Perform Delta Commission
    ...  - Check Netconf Get And VES CCN During Provision
    ...  - Check Netconf Get MO And VES CCN During Perform Delta Commission
    ...  Pass criteria: Provision delta plan from NetAct,and check CCN and check configuration get from ONAP Netconf,
    ...  same as on get from NetAct. Site is OK with no any unexpected alarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.08.2023 - New case
    Set Tags    CA-CM    AUTHOR-bin.7.liu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    Log To Console    ${TEST_NAME} start.
    Step 1: Check Netconf Get All And VES CCN During Perform Delta Commission
    Step 2: Check Netconf Get And VES CCN During Provision
    Step 3: Check Netconf Get MO And VES CCN During Perform Delta Commission

TC Setup
    Log To Console    TC Setup
    Common Test Setup
    Set Test Variable    ${BTS_ID}    ${MRBTS_DN.split("-")[-1]}
    Comment    ${ONAP_INFOR}    Get Informations From ONAP    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Set Test Variable    ${ONAP_INFOR}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP    ${BTS_ID}    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${BTS_ID}    ${ONAP['host_ip']}
    Prepare Case Variables CB007010_E_010

TC Teardown
    Log To Console    TC Teardown
    Comment    Tear VES Log Listener    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Run Keyword If    '${actCceSplit_to_set}'=='${initial_actCceSplit}'    Set Param Trigger NR Cell Lock Unlock    ${actCceSplit_to_set}
    Common Test Teardown

Prepare Case Variables CB007010_E_010
    netact.Export Configuration
    ...    local_dir=${Test Results Dir}/NetActLogs    file_name=scf_from_netact.xml    dist_names=${MRBTS_DN}    ui_values=${True}
    Set Test Variable    ${BTS_FULL_SCF_FILE}    ${Test Results Dir}/NetActLogs/scf_from_netact.xml
    ${scf_content}    L_XML.Parse XML    ${BTS_FULL_SCF_FILE}
    ${count}    L_XML.Get Element Count    ${scf_content}    .//managedObject[@class="SMOD_R"]
    ${xpath}    Set Variable If    '${count}'=='${1}'    .//managedObject[@class="SMOD_R"]/p[@name="serialNumber"]
    ...    .//managedObject[@class="SMOD_R"]/p[@name="activeRole" and text()="Primary"]/../p[@name="serialNumber"]
    ${PRIMARY_CORE_DN}    L_XML.Get Element Text    ${scf_content}    ${xpath}
    Set Test Variable    ${PRIMARY_CORE_DN}
    ${nrcell_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="NRCELL"]
    ${count}    Get Length    ${nrcell_elements}
    ${i}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${param_netact}    L_XML.Get Element Attributes    ${nrcell_elements[${i}]}
    ${initial_actCceSplit}    L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${param_netact['distName']}"]/p[@name="actCceSplit"]
    #${actCceSplit_to_set} is always opposite the current value
    ${actCceSplit_to_set}    Set Variable If    '${initial_actCceSplit}'=='true'    false    true
    Set Test Variable    ${initial_actCceSplit}
    Set Test Variable    ${actCceSplit_to_set}
    Set Test Variable    ${param_netact}
    ${NETCONF_XPATH_LNBTS}    Transfer SCF DN To Xpath Of ONAP Get Result    ${param_netact["distName"].replace("PLMN-PLMN/","")}
    Set Test Variable    ${NETCONF_XPATH_LNBTS}

Set Param Trigger NR Cell Lock Unlock
    [Arguments]    ${val_to_set}
    ${dn}    Set variable    ${param_netact["distName"].replace("PLMN-PLMN/","")}
    ${dict_actMplaneFronthaulFirewall}    Create Dictionary    parameterName=actCceSplit    operation=update    value=${val_to_set}
    ${param_list}    Create List    ${dict_actMplaneFronthaulFirewall}
    coam.Perform Object Recommissioning    dist_name=${dn}    operation=update    parameter=${param_list}

Get And Check CM Data From ONAP
    [Arguments]    ${filter_xpath}=${EMPTY}
    ${time}    Get Time    epoch
    ${cmd}    Set Variable If    '${filter_xpath}'=='${EMPTY}'
    ...    get --out /tmp/TA_CB007010_E_010_${time}.xml    get --filter-xpath ${filter_xpath} --out /tmp/TA_CB007010_E_010_${time}.xml
    ${onap_get_file}    Set Variable    ${BTSFiles}/onap_get_${time}.xml
    Comment    Exucute One Command On Netconf CLI
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['netconf_server']}
    ...    /tmp/TA_CB007010_E_010_${time}.xml    ${onap_get_file}
    Get File From Simulator To Local
    ...    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    tmp/TA_CB007010_E_010_${time}.xml    ${onap_get_file}
    ${get_result}    L_XML.Parse XML    ${onap_get_file}
    L_XML.Element Should Exist    ${get_result}    ${NETCONF_XPATH_LNBTS}

Check Netconf Get And VES CCN During Perform Delta Commission
    [Arguments]    ${onap_get_xpath}=${EMPTY}
    ${dic_param_value}    Create Dictionary    actCceSplit=${actCceSplit_to_set}
    Comment    ${ves_ccn_file}    Start VES Log Listen
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${BTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Set Param Trigger NR Cell Lock Unlock    ${actCceSplit_to_set}
    ${actCceSplit_to_set}    Set Variable If    '${actCceSplit_to_set}'=='true'    false    true
    Set Test Variable    ${actCceSplit_to_set}
    ${time_gap}    Evaluate    random.randint(1,5)    modules=random, sys
    Sleep    ${time_gap}
    Get And Check CM Data From ONAP    ${onap_get_xpath}
    Wait Until Keyword Succeeds    15 min    60 sec    Check SBTS SMOD RMOD Cells Alarms
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${param_netact["distName"].replace("PLMN-PLMN/","")}
    ...    ${PRIMARY_CORE_DN}    ${MPLANE_IP}    replace    ${dic_param_value}
    Should Not Be Empty    ${target_VES_CCN_msg}

Step ${index}: Check Netconf Get And VES CCN During Provision
    Log To Console    Step ${index}: Check Netconf Get And VES CCN During Provision
    ${time}    Get Time    epoch
    Set Test Variable    ${NETACT_PLAN_NAME}    TA_7010_E_10_${time}
    &{dic_param_value}    Create Dictionary    actCceSplit=${actCceSplit_to_set}
    NetAct CM Upload    dist_names=${MRBTS_DN}
    NetAct Create And Edit Plan    ${NETACT_PLAN_NAME}    Plan For TA_7010_E_10.
    ...    ${param_netact["distName"]}    ${param_netact["distName"].replace("PLMN-PLMN/","")}    &{dic_param_value}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${NETACT_PLAN_NAME}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${NETACT_PLAN_NAME}    operation_type=plan
    Comment    ${ves_ccn_file}    Start VES Log Listen
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${BTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Open Connection    ${NETACT['was_host']}    alias=provision
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmd}    Catenate    racclimx.sh -planName ${NETACT_PLAN_NAME} -DN ${MRBTS_DN}
    ...    -createBackupPlan false -backupPlanName ${NETACT_PLAN_NAME}_backup -v -provisioningOperation activate
    ...    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd}
    ${actCceSplit_to_set}    Set Variable If    '${actCceSplit_to_set}'=='true'    false    true
    Set Test Variable    ${actCceSplit_to_set}
    ${time_gap}    Evaluate    random.randint(1,5)    modules=random, sys
    Sleep    ${time_gap}
    Get And Check CM Data From ONAP    ${NETCONF_XPATH_LNBTS}
    Wait Until Keyword Succeeds    15 min    60 sec    Check SBTS SMOD RMOD Cells Alarms
    Wait Until Keyword Succeeds    5x    60s    NetAct Check Actual Configuration Parameters
    ...    dist_name=${param_netact["distName"]}    ui_values=true    &{dic_param_value}
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${param_netact["distName"].replace("PLMN-PLMN/","")}
    ...    ${PRIMARY_CORE_DN}    ${MPLANE_IP}    replace    ${dic_param_value}
    Should Not Be Empty    ${target_VES_CCN_msg}

Step ${index}: Check Netconf Get All And VES CCN During Perform Delta Commission
    Log To Console    Step ${index}: Check Netconf Get All And VES CCN During Perform Delta Commission
    Check Netconf Get And VES CCN During Perform Delta Commission

Step ${index}: Check Netconf Get MO And VES CCN During Perform Delta Commission
    Log To Console    Step ${index}: Check Netconf Get MO And VES CCN During Perform Delta Commission
    Check Netconf Get And VES CCN During Perform Delta Commission    ${NETCONF_XPATH_LNBTS}
