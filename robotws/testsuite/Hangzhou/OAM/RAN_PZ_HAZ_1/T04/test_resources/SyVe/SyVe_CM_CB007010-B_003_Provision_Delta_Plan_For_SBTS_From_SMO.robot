*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${Integrate_Need}        ${False}
${needRecovery}       False

*** Keywords ***
SyVe_CM_CB007010-B_003_Provision_Delta_Plan_For_SBTS_From_SMO
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For case:TA_RAN_ST_CB007010-B_B2_003_CM_Provision delta plan for SBTS from SMO
    ...  The main steps performed for the test are:
    ...  - Provision Delta Plan Contain Online Parameter On NetConf
    ...  - Check Online Parameter Action On SBTS
    ...  - Check Online Parameter Be Updated On NetAct
    ...  - Check Online Operation Feedback and CCN Message On VES
    ...  - Provision Delta Plan Contain SiteReset Parameter On NetConf
    ...  - Check SiteReset Parameter Action On SBTS
    ...  - Check SiteReset Parameter Be Updated On NetAct
    ...  - Check SiteReset Operation Feedback and CCN Message On VES
    ...  Pass criteria: Provision delta plan from NetConf,and check parameter value on NetAct and CCN on ONAP.
    ...  Site is OK with no any unexpected alarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.08.2023 - New case
    ...  - 16.01.2025 - Update due to code high performace when site reset
    ...  - 15.05.2025 - update test data due to cb013033/13031
    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    LOG    ${TEST_NAME} of ${SUITE_NAME} start.    console=${True}
    Step 1: Provision Delta Plan Contain Online Parameter On NetConf
    Step 2: Check Online Parameter Action On SBTS
    Step 3: Check Online Parameter Be Updated On NetAct
    Step 4: Check Online Operation Feedback and CCN Message On VES
    Step 5: Provision Delta Plan Contain SiteReset Parameter On NetConf
    Step 6: Check SiteReset Parameter Action On SBTS
    Step 7: Check SiteReset Parameter Be Updated On NetAct
    Step 8: Check SiteReset Parameter Be Updated On VES
#    Step 8: Check SiteReset Operation Feedback and CCN Message On VES

Step ${index}: Provision Delta Plan Contain ${Type} Parameter On NetConf
    Log To Console    Step ${index}: Provision Delta Plan Contain ${Type} Parameter On NetConf
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_${Type}_${time}.xml    #${Test Results Dir}
    ${fileName_updated}    Set Variable    onap_${Type}_${time}_updated.xml
    Set Test Variable    ${fileName_init}
    ${current_value}    Get Parameter Value From WebEM    ${paramScfDN_${Type}}    ${paramName_${Type}}
    Run Keyword If    "${Type}"=="Online"    Set Test Variable    ${current_value_Online}    ${current_value}
    Run Keyword If    "${Type}"=="SiteReset"    Set Test Variable    ${current_value_SiteReset}     ${current_value}
    Remove Values From List    ${paramValuesPool_${Type}}    ${current_value}
    ${valueToSet}    Evaluate    random.choice(${paramValuesPool_${Type}})    modules=random, sys
    ${paramXpathOnap}    Transfer SCF DN To Xpath Of ONAP Get Result    ${paramScfDN_${Type}}
    ${valueToSetNA}    Run Keyword If    "${valueToSet}"=="off"    Set Variable    0
    ...    ELSE IF    "${valueToSet}"=="on"    Set Variable    1
    ...    ELSE IF    "${valueToSet}"=="true"    Set Variable    1
    ...    ELSE IF    "${valueToSet}"=="false"    Set Variable    0
    ...    ELSE    Set Variable    ${valueToSet}
    ${paramNA_dic}    Create Dictionary    ${paramName_${Type}}=${valueToSetNA}
    Set Test Variable    ${paramNA_dic}
    Set Test Variable    ${valueToSet}
    ${paramValue_dic}    Create Dictionary
    Run Keyword If    "${Type}"=="Online"    Set to Dictionary    ${paramValue_dic}    ${paramName_Online}=${valueToSet}
    Run Keyword If    "${Type}"=="SiteReset"    Set to Dictionary    ${paramValue_dic}     ${paramName_SiteReset}=${valueToSet}
    Set Test Variable    ${paramValue_dic}
    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --filter-xpath ${paramXpathOnap}/attributes/${paramName_${Type}} --out=/tmp/${fileName_init}
    ${cmd_editConfig}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-then-set --error rollback --rpc-timeout 160s
    Set Test Variable    ${cmd_getConfig}
    #Simulator
    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd_getConfig}
    Get File From Simulator To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_init}    ${Test Results Dir}/${fileName_init}
	${param_dic}    Create Dictionary     ${paramScfDN_${Type}}=${paramValue_dic}
	Generate Delta Plan For NetConf    ${param_dic}    ${Test Results Dir}/${fileName_init}    ${Test Results Dir}/${fileName_updated}
	Put File From Local To Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_updated}    ${Test Results Dir}/${fileName_updated}
	Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
	...  ${cmd_editConfig}
	Should Contain    ${output}    \r\nOK\r\n
	Set Test Variable    ${needRecovery}    True
	Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

    #below are used for real ONAP
#    Exucute One Command On Netconf CLI
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_getConfig}
#    Get File From Pod To Local    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}
#    ...    /tmp/${fileName_init}    ${Test Results Dir}/${fileName_init}
#    Generate Delta Plan For NetConf    ${Test Results Dir}/${fileName_init}    ${Test Results Dir}/${fileName_updated}    ${paramONAP_dic}
#    Put File From Local To Pod    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}
#    ...    /tmp/${Test Results Dir}/${fileName_updated}    ${Test Results Dir}/${fileName_updated}
#    #Start CCN
#    ${output}    Exucute One Command On Netconf CLI
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_editConfig}
#    Should Contain    ${output}    \r\nOK\r\n
#    Set Test Variable    ${needRecovery}    True
#    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check ${Type} Parameter Be Updated On NetAct
    Log To Console    Step ${index}: Check ${Type} Parameter Be Updated On NetAct
    Wait Until Keyword Succeeds    10x    30s    NetAct Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${paramScfDN_${Type}}   ui_values=${True}    &{paramNA_dic}

Step ${index}: Check ${Type} Parameter Action On SBTS
    Log To Console    Step ${index}: Check ${Type} Parameter Action On SBTS
    ${ims2_file_path_name}    Set Variable    ${Test Results Dir}/BTSFiles/${Type}_check_restart_InfoModel_log.ims2
    ${reset_was_triggered}    Infomodel Check IM log if BTS reset was triggered    ${ims2_file_path_name}
    Run Keyword If    "${Type}"== "Online"    Should Not Be True    ${reset_was_triggered}    ELSE    Should Be True    ${reset_was_triggered}

Step ${index}: Check SiteReset Parameter Be Updated On VES
    Log To Console    Step ${index}: Check SiteReset Parameter Be Updated On VES
    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd_getConfig}
    Get File From Simulator To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_init}   ${Test Results Dir}/${fileName_init}
    ${file_content}    OperatingSystem.Get File    ${Test Results Dir}/${fileName_init}
    Should Contain    ${file_content}    <${paramName_SiteReset}>${valueToSet}</${paramName_SiteReset}>

Step ${index}: Check ${Type} Operation Feedback and CCN Message On VES
    Log To Console    Step ${index}: Check ${Type} Operation Feedback and CCN Message On VES
    ${op}    Set Variable If    "${Type}"=="Online"    replace    add
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_feedback}    Filter VES VsCmOperationFeedbackNotification CCN
    ...    ${VES_CCN_msgs}    ${Primary_SN}    provision    completed
    Log    ${target_VES_CCN_feedback}
    Should Be Equal As Integers	   ${target_VES_CCN_feedback.__len__()}    ${1}
	${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${paramScfDN_${Type}}    ${Primary_SN}    ${MPLANE_IP}    ${op}    ${paramValue_dic}
    Log    ${target_VES_CCN_msg}
    Should Be True    "${target_VES_CCN_msg.__len__()}">="${1}"

    #Below for real ONAP
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile}
#    ${target_VES_CCN_feedback}    Filter VES VsCmOperationFeedbackNotification CCN
#    ...    ${VES_CCN_msgs}    ${Primary_SN}    provision    completed
#    Log    ${target_VES_CCN_feedback}
#    Should Be Equal As Integers	   ${target_VES_CCN_feedback.__len__()}    ${1}
#    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
#    ...    ${VES_CCN_msgs}    ${paramScfDN_${Type}}    ${Primary_SN}    ${MPLANE_IP}    ${op}    ${paramValue_dic}
#    log    ${target_VES_CCN_msg}
#    Should Be True    "${target_VES_CCN_msg.__len__()}">="${1}"


Set Test Data
    ${paramName_Online}    Set Variable    actDataForwardingForVoNr      #actARPBasedAC    forceSingleTxModeSupportEnabled
#    @{paramValuesPool_Online}    Create List    on    off
    @{paramValuesPool_Online}    Create List    deactivated    Xn_activated    NG_activated
    ${paramScfDN_Online}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${paramName_SiteReset}    Set Variable    actEAPMode    #actMplaneFronthaulFirewall
#    @{paramValuesPool_SiteReset}     Create List    true    false
    @{paramValuesPool_SiteReset}     Create List    Combined Authenticator initiated mode and Supplicant initiated mode    EAP disabled
    ${paramScfDN_SiteReset}    Set Variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable    ${paramName_Online}
    Set Test Variable    ${paramValuesPool_Online}
    Set Test Variable    ${paramScfDN_Online}
    Set Test Variable    ${paramName_SiteReset}
    Set Test Variable    ${paramValuesPool_SiteReset}
    Set Test Variable    ${paramScfDN_SiteReset}

TC SetUp
    Log To Console    TC SetUp
    Common Test Setup
    ${BTS_ID}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${BTS_ID}
    ${NRBTS_ID}    Fetch NRBTS ID
    Set Test Variable    ${NRBTS_ID}

    ${Primary_SN}    Set Variable
    ${bts_info}    coam.Get Bts Info
    ${smod_info_list}=    Get From Dictionary    ${bts_info}    systemModules
    FOR    ${smod}    IN    @{smod_info_list}
        ${sn}    Get From Dictionary    ${smod}    serialNumber
        ${id}    Get From Dictionary    ${smod}    id
        ${config_DN}    Get From Dictionary    ${id}    configuration
        ${mode_name}    Fetch From Right    ${config_DN}    /
        ${Primary_SN}    Set Variable If  "${mode_name}"=="SMOD-1"    ${sn}    ${Primary_SN}
        Exit For Loop If    "${mode_name}"=="SMOD-1"
    END
    Set Test Variable    ${Primary_SN}
    Set Test Data

#    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
#    Set Test Variable    ${user}    ${ONAP["user"]}
#    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
#    ${ONAP_INFOR}    Get Informations From ONAP    ${host_ip}    ${user}    ${pwd}
#    Set Test Variable      ${ONAP_INFOR}
#    run keyword if    ${Integrate_Need}    Integrate SBTS To ONAP    ${BTS_ID}    ${host_ip}    ${user}    ${pwd}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${BTS_ID}    ${ONAP['host_ip']}

TC TearDown
    Log To Console    TC TearDown
    Run Keyword If    ${needRecovery}    Recovery SBTS
    Common Test Teardown

Recovery SBTS
    coam.Create Delta
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_Online}    parameter=${paramName_Online}    value=${current_value_Online}
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_SiteReset}   parameter=${paramName_SiteReset}   value=${current_value_SiteReset}
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms