*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${Integrate_Need}    ${False}

*** Keywords ***
TC__SyVe_CM_CB007010_B_001_CM_Validate_Configuration_Plan_From_SMO
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision a random selected lncell delete and add from ONAP.
    ...    TA_RAN_ST_CB007010-B_B2_002_CM_Creation and Deleteion of LTE Cell for cOAM SBTS
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check Lncell be deleted
    ...    - Provision the backup plan
    ...    - Check Lncell be added
    ...    - Create and edit plan only with parent MO SyVe
    ...    - Export the parent plan SyVe
    ...    - Provision the parent plan SyVe
    ...    - Check Lncell be deleted
    ...    - Check the child MO be deleted
    ...    - Provision the backup plan
    ...    - Check Lncell be added
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: delete and add lncell provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.09.2023 - New Case
    ...    - 24.07.2025 removed CB013033 limitation due to PR840751
    Set Tags    AUTHOR-bin.7.liu@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Update vesCMFeedbackNotificationInt to 3 Via ONAP
    Step 6: Validate vesAckTimeout Via ONAP And Check CCN
    Step 7: Validate Via ONAP And Check FeedBack CCN Should Sent
    #20250214:disable for CB013033 during 25R3 #20250724 removed this limitation
    Step 8: Update vesCMFeedbackNotificationInt to 0 Via ONAP
    Step 9: Validate Via ONAP And Check FeedBack CCN Should Not Sent
    Step 10: Recover Parameters Of ONAP

Particular Teardown
    Run Keyword If    ${NEED_RECOVER}    Run Keywords
    ...    coam.Perform Commissioning    bts_id=${MRBTS_ID}    scf_file=${BTS_scf_initial}    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Set Test Variable    ${NEED_RECOVER}    ${False}
    Common Test Setup    SetValidatePlanAgainstDetectedHW=${False}
    Case Precondition

TC Teardown
    Particular Teardown

Case Precondition
    Set Test Variable    ${MRBTS_ID}    ${MRBTS_DN.split("-")[-1]}
    #for env prepare and cb13033
    coam.perform_parameter_recommissioning    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1   vesAckTimeout    update    ${6}
    coam.perform_parameter_recommissioning    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1   vesCMFeedbackNotificationInt    update    ${2}
    Comment    ${ONAP_INFOR}    Get Informations From ONAP    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Set Test Variable    ${ONAP_INFOR}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP    ${MRBTS_ID}    ${ONAP["host_ip"]}    ${ONAP["user"]}
    ...    ${ONAP["pwd"]}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}
    ${UNEXPECTED_ALARM}    Create Dictionary    alarmId=${7115}    faultId=${4639}
    Set Test Variable    ${UNEXPECTED_ALARM}
    Get Delta Plan And Values From ONAP
    Get Origin Variables From NetAct SCF
    Get Full Plan From ONAP

Get Full Plan From ONAP
    ${time}    Get Time    epoch
    ${ORIGIN_ONAP_FULL_PLAN}    Set Variable    CB007010_B_1_full_${time}.xml
    ${cmd}    Set Variable    get-config --source running --out=/tmp/${ORIGIN_ONAP_FULL_PLAN}
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${ORIGIN_ONAP_FULL_PLAN}    ${BTSFiles}/${ORIGIN_ONAP_FULL_PLAN}
    Get File From Simulator To Local    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ...    ${ORIGIN_ONAP_FULL_PLAN}    ${BTSFiles}/${ORIGIN_ONAP_FULL_PLAN}
    ${parsed_xml}    XML.Parse XML    ${BTSFiles}/${ORIGIN_ONAP_FULL_PLAN}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    XML.Save XML    ${e_onap}    ${BTSFiles}/${ORIGIN_ONAP_FULL_PLAN}
    Comment    Put File From Local To Pod    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ...    ${ONAP_INFOR['netconf_server']}    ${ORIGIN_ONAP_FULL_PLAN}    ${BTSFiles}/${ORIGIN_ONAP_FULL_PLAN}
    Put File From Local To Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ...    ${ORIGIN_ONAP_FULL_PLAN}    ${BTSFiles}/${ORIGIN_ONAP_FULL_PLAN}
    Set Test Variable    ${ORIGIN_ONAP_FULL_PLAN}

Get Origin Variables From NetAct SCF
    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs    file_name=scf_from_netact.xml
    ...    dist_names=${MRBTS_DN}    ui_values=${True}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/scf_from_netact.xml
    ${count}    L_XML.Get Element Count    ${scf_xml}    .//managedObject[@class="SMOD_R"]
    ${xpath}    Set Variable If    '${count}'=='${1}'    .//managedObject[@class="SMOD_R"]/p[@name="serialNumber"]
    ...    .//managedObject[@class="SMOD_R"]/p[@name="activeRole" and text()="Primary"]/../p[@name="serialNumber"]
    ${PRIMARY_CORE_DN}    L_XML.Get Element Text    ${scf_xml}    ${xpath}
    ${ONAP_P_VALUE}    L_XML.Get Element Text    ${scf_xml}    .//managedObject[@class="MPLANEONAP"]/p[@name="vesCMFeedbackNotificationInt"]
    ${ONAP_P1_VALUE}    L_XML.Get Element Text    ${scf_xml}    .//managedObject[@class="MPLANEONAP"]/p[@name="vesAckTimeout"]
    Should Not Be Equal As Integers    ${ONAP_P_VALUE}    3    The value of vesCMFeedbackNotificationInt cannot be the same as to be set
    Should Not Be Equal As Integers    ${ONAP_P1_VALUE}    10    The value of vesAckTimeout cannot be the same as to be set
    Set Test Variable    ${PRIMARY_CORE_DN}
    Set Test Variable    ${ONAP_P_VALUE}
    Set Test Variable    ${ONAP_P1_VALUE}

Get Delta Plan And Values From ONAP
    ${time}    Get Time    epoch
    ${ONAP_SCF_DN}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${ONAP_PATH}    Transfer SCF DN To Xpath Of ONAP Get Result    ${ONAP_SCF_DN}
    ${ONAP_P_PATH}    Set Variable    ${onap_path}/attributes/vesCMFeedbackNotificationInt
    ${ONAP_P1_PATH}    Set Variable    ${onap_path}/attributes/vesAckTimeout
    ${ORIGIN_ONAP_DELTA_PLAN}    Set Variable    CB007010_B_1_${time}.xml
    ${cmd}    Set Variable    get-config --source running --filter-xpath ${ONAP_PATH} --out=/tmp/${ORIGIN_ONAP_DELTA_PLAN}
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${ORIGIN_ONAP_DELTA_PLAN}    ${BTSFiles}/${ORIGIN_ONAP_DELTA_PLAN}
    Get File From Simulator To Local    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ...    ${ORIGIN_ONAP_DELTA_PLAN}    ${BTSFiles}/${ORIGIN_ONAP_DELTA_PLAN}
    Set Test Variable    ${ONAP_PATH}
    Set Test Variable    ${ONAP_P_PATH}
    Set Test Variable    ${ONAP_P1_PATH}
    Set Test Variable    ${ORIGIN_ONAP_DELTA_PLAN}
    Set Test Variable    ${ONAP_SCF_DN}

Validate Via ONAP And Get FeedBack CCN
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MRBTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ${cmd}    Set Variable    validate --src-config=/tmp/${ORIGIN_ONAP_FULL_PLAN} --rpc-timeout 60s
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ${completed_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    validation    completed
    ${ongoing_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    validation    ongoing
    [Return]    ${ongoing_CCN_msg}    ${completed_CCN_msg}

Step ${index}: Check ${when} BTS state
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Validate Via ONAP And Check FeedBack CCN Should Sent
    Log To Console    Step ${index}: Validate Via ONAP And Check FeedBack CCN Should Sent
    ${ongoing_CCN_msg}    ${completed_CCN_msg}    Validate Via ONAP And Get FeedBack CCN
    Should Not Be Empty    ${ongoing_CCN_msg}
    Should Not Be Empty    ${completed_CCN_msg}

Step ${index}: Validate Via ONAP And Check FeedBack CCN Should Not Sent
    Log To Console    Step ${index}: Validate Via ONAP And Check FeedBack CCN Should Not Sent
    ${ongoing_CCN_msg}    ${completed_CCN_msg}    Validate Via ONAP And Get FeedBack CCN
    Should Be Empty    ${ongoing_CCN_msg}
    Should Be Empty    ${completed_CCN_msg}

Step ${index}: Update vesCMFeedbackNotificationInt to ${val} Via ONAP
    Log To Console    Step ${index}: Update vesCMFeedbackNotificationInt to ${val} Via ONAP
    Set Test Variable    ${NEED_RECOVER}    ${True}
    ${time}    Get Time    epoch
    Comment    ${cmd_get_config}    Set Variable    get-config --source running --filter-xpath ${onap_P_path} --out=/tmp/CB007010_B_1_${time}.xml
    Comment    Execute NetConf Command On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd_get_config}
    Comment    Get File From Simulator To Local    CB007010_B_1_${time}.xml
    ${parsed_xml}    XML.Parse XML    ${BTSFiles}/${ORIGIN_ONAP_DELTA_PLAN}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    ${dic_param}    Create Dictionary    vesCMFeedbackNotificationInt    ${val}
    Modify ONAP Plan Parameters Of MO    ${ONAP_SCF_DN}    ${dic_param}    ${e_onap}
    XML.Save XML    ${e_onap}    ${BTSFiles}/CB007010_B_1_${time}.xml
    Comment    Put File From Local To Pod    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${ONAP_INFOR['netconf_server']}
    ...    CB007010_B_1_${time}.xml    ${BTSFiles}/CB007010_B_1_${time}.xml
    Put File From Local To Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ...    CB007010_B_1_${time}.xml    ${BTSFiles}/CB007010_B_1_${time}.xml
    ${cmd_edit_config}    Catenate    edit-config --target running --config=/tmp/CB007010_B_1_${time}.xml
    ...    --test test-then-set --error rollback --rpc-timeout 300s
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_edit_config}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
	...   ${cmd_edit_config}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Check_SBTS_SMOD_RMOD_Cells_Alarms

Step ${index}: Validate vesAckTimeout Via ONAP And Check CCN
    Log To Console    Step ${index}: Validate vesAckTimeout Via ONAP And Check CCN
    ${time}    Get Time    epoch
    Comment    ${cmd_get_config}    Set Variable    get-config --source running --filter-xpath ${onap_P1_path} --out=/tmp/CB007010_B_1_${time}.xml
    Comment    Execute NetConf Command On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd_get_config}
    Comment    Get File From Simulator To Local    CB007010_B_1_${time}.xml
    ${parsed_xml}    XML.Parse XML    ${BTSFiles}/${ORIGIN_ONAP_DELTA_PLAN}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    ${dic_param}    Create Dictionary    vesAckTimeout    10    vesCMFeedbackNotificationInt    3
    Modify ONAP Plan Parameters Of MO    ${ONAP_SCF_DN}    ${dic_param}    ${e_onap}
    XML.Save XML    ${e_onap}    ${BTSFiles}/CB007010_B_1_${time}.xml
    Comment    Put File From Local To Pod    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${ONAP_INFOR['netconf_server']}
    ...    CB007010_B_1_${time}.xml    ${BTSFiles}/CB007010_B_1_${time}.xml
    Put File From Local To Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    CB007010_B_1_${time}.xml
    ...    ${BTSFiles}/CB007010_B_1_${time}.xml
    ${cmd_edit_config}    Catenate    edit-config --target running --config=/tmp/CB007010_B_1_${time}.xml --test test-only
    ...    --error rollback --rpc-timeout 300s
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MRBTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_edit_config}
    ${ret}    Execute NetConf Command On ONAP Simulator   MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
	...   ${cmd_edit_config}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Sleep    5s    #time gap for complete CCN
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ${dic_param}    Create Dictionary    vesAckTimeout    ${10}    vesCMFeedbackNotificationInt    ${3}
    ${completed_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    validation    completed
    ${ongoing_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    validation    ongoing
    ${moChange_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${ONAP_SCF_DN}    ${PRIMARY_CORE_DN}    ${MPLANE_IP}    replace
    ...    ${dic_param}
    Should Not Be Empty    ${completed_CCN_msg}
    Should Not Be Empty    ${ongoing_CCN_msg}
    Should Be Empty    ${moChange_CCN_msg}
    Append To List    ${UNEXPECTED_ALARMS}    ${UNEXPECTED_ALARM}
    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Remove Values From List    ${UNEXPECTED_ALARMS}    ${UNEXPECTED_ALARM}

Step ${index}: Recover Parameters Of ONAP
    Log To Console    Step ${index}: Recover Parameters Of ONAP
    ${time}    Get Time    epoch
    Comment    ${cmd_get_config}    Set Variable    get-config --source running --filter-xpath ${ONAP_PATH} --out=/tmp/CB007010_B_1_${time}.xml
    Comment    Execute NetConf Command On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd_get_config}
    Comment    Get File From Simulator To Local    CB007010_B_1_${time}.xml
    ${parsed_xml}    XML.Parse XML    ${BTSFiles}/${ORIGIN_ONAP_DELTA_PLAN}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    ${dic_param}    Create Dictionary    vesAckTimeout    ${ONAP_P1_VALUE}    vesCMFeedbackNotificationInt    ${ONAP_P_VALUE}
    Modify ONAP Plan Parameters Of MO    ${ONAP_SCF_DN}    ${dic_param}    ${e_onap}
    XML.Save XML    ${e_onap}    ${BTSFiles}/CB007010_B_1_${time}.xml
    Comment    Put File From Local To Pod    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${ONAP_INFOR['netconf_server']}
    ...    CB007010_B_1_${time}.xml    ${BTSFiles}/CB007010_B_1_${time}.xml
    Put File From Local To Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ...    CB007010_B_1_${time}.xml    ${BTSFiles}/CB007010_B_1_${time}.xml
    ${cmd_edit_config}    Catenate    edit-config --target running --config=/tmp/CB007010_B_1_${time}.xml
    ...    --test test-then-set --error rollback --rpc-timeout 300s
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_edit_config}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
	...   ${cmd_edit_config}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Set Test Variable    ${NEED_RECOVER}    ${False}
    Check_SBTS_SMOD_RMOD_Cells_Alarms