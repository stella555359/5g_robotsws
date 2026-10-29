*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${Integrate_Need}    ${False}

*** Keywords ***
TC__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    For case:RAN_ST_CB007010-C_B1_001_CM_Lock_Unlock the BTS Running Datastore from SMO
    ...    The main steps performed for the test are:
    ...    - Provision On Netconf Locking Session And Check
    ...    - Lock The Netconf Database
    ...    - Provison On New Session When Netconf Locked And Check
    ...    - Reset BBMOD And Check ONAP CCN
    ...    - Reset RMOD And Check ONAP CCN
    ...    - Get Data From New Session When Netconf Locked
    ...    - Validate vesAckTimeout Via ONAP And Check CCN
    ...    - Validate Full Plan Via ONAP And Get FeedBack CCN
    ...    - Provision Via ONAP And Check CCN
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.09.2023 - New case
    ...    - 06.12.2023 - Add webEM checkpoint for CB007010-D
    ...    - 02.12.2024 - xuyuyan:comment O1 Management WebUI checkpoint
    ...    - 23.07.2025 removed CB013033 limitation due to PR840751
    Set Tags    AUTHOR-bin.7.liu@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Provision On Netconf Locking Session And Check
    Step 2: Lock The Netconf Database
    Step 3: Provison On New Session When Netconf Locked And Check
    Step 4: Reset BBMOD And Check ONAP CCN
    Step 5: Reset RMOD And Check ONAP CCN
    Step 6: Get Data From New Session When Netconf Locked
    Step 7: Validate vesAckTimeout Via ONAP And Check CCN
    #20250317:disable for CB013033 during 25R3 #20250723 removed this limitation
    Step 8: Validate Full Plan Via ONAP And Get FeedBack CCN
    Step 9: Provision Via ONAP And Check CCN

TC SetUp
    Log    TC SetUp    console=True
    Set Test Variable    ${NEED_RECOVER}    ${False}
    Common Test Setup SBTS    SetValidatePlanAgainstDetectedHW=${False}
    Case Precondition

TC TearDown
    Log    TC TearDown    console=True
#    ${time}    Get Time    epoch
#    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
#    SBTS WEM Download Chrome Console Log
#    Close All Browsers
    Remove Values From List    ${UNEXPECTED_ALARMS}    ${UNEXPECTED_ALARM}
    Run Keyword If    ${NEED_RECOVER}    Run Keywords
    ...    coam.Perform Commissioning    bts_id=${MRBTS_ID}    scf_file=${BTS_scf_initial}    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown SBTS
    SSHLibrary.Close All Connections

Case Precondition
    Set Test Variable    ${MRBTS_ID}    ${MRBTS_DN.split("-")[-1]}
    #for env prepare and cb13033 #20250723 removed this limitation
    coam.perform_parameter_recommissioning    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1   vesAckTimeout    update    ${6}
    coam.perform_parameter_recommissioning    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1   vesCMFeedbackNotificationInt    update    ${2}
    Comment    ${ONAP_INFOR}    Get Informations From ONAP    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Set Test Variable    ${ONAP_INFOR}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP    ${MRBTS_ID}    ${ONAP["host_ip"]}    ${ONAP["user"]}
    ...    ${ONAP["pwd"]}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}
    ${UNEXPECTED_ALARM}    Create Dictionary    alarmId=${7115}    faultId=${4639}
    Set Test Variable    ${UNEXPECTED_ALARM}
    Append To List    ${UNEXPECTED_ALARMS}    ${UNEXPECTED_ALARM}
    Get Origin Variables From SBT
    Get Delta Plan And Values From ONAP
    #SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${False}

Get Origin Variables From SBT
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}    export_type=configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf}
    ${count}    L_XML.Get Element Count    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"]
    ${xpath}    Set Variable If    '${count}'=='${1}'    .//managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"]/p[@name="serialNumber"]
    ...    .//managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"]/p[@name="activeRole" and text()="Primary"]/../p[@name="serialNumber"]
    ${PRIMARY_CORE_DN}    L_XML.Get Element Text    ${scf_xml}    ${xpath}
    ${val_vesCMFeedbackNotificationInt}    L_XML.Get Element Text
    ...    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.mnl:MPLANEONAP"]/p[@name="vesCMFeedbackNotificationInt"]
    ${ONAP_P1_VALUE}    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@class="com.nokia.srbts.mnl:MPLANEONAP"]/p[@name="vesAckTimeout"]
    Should Not Be Equal As Integers    ${val_vesCMFeedbackNotificationInt}    0    The value of vesCMFeedbackNotificationInt cannot be 0
    Should Not Be Equal As Integers    ${ONAP_P1_VALUE}    10    The value of vesAckTimeout cannot be the same as to be set
    #ABIA cannot be reset when configured GSM or WCDMA rat
    ${bbmod_R_elements}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[@class="com.nokia.srbts.eqmr:BBMOD_R"]/p[@name="productName" and text()!="ABIA AirScale Capacity"]/..
    ${count}    Get Length    ${bbmod_R_elements}
    ${index}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
    ${DN_BBMOD_R}    L_XML.Get Element Attribute    ${bbmod_R_elements[${index}]}    distName
    ${smod_R_elements}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    ${count}    Get Length    ${smod_R_elements}
    ${index}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
    ${DN_RMOD_R}    L_XML.Get Element Attribute    ${smod_R_elements[${index}]}    distName
    Set Test Variable    ${DN_RMOD_R}
    Set Test Variable    ${DN_BBMOD_R}
    Set Test Variable    ${PRIMARY_CORE_DN}
    Set Test Variable    ${ONAP_P1_VALUE}

Get Full Plan From ONAP
    ${time}    Get Time    epoch
    ${f_name}    Set Variable    CB007010_C_1_full_${time}.xml
    ${cmd}    Set Variable    get-config --source running --out=/tmp/${f_name}
    Comment    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${f_name}    ${BTSFiles}/${f_name}
    Get File From Simulator To Local    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${f_name}    ${BTSFiles}/${f_name}
    ${parsed_xml}    XML.Parse XML    ${BTSFiles}/${f_name}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    XML.Save XML    ${e_onap}    ${BTSFiles}/${f_name}
    Comment    Put File From Local To Pod    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ...    ${ONAP_INFOR['netconf_server']}    /tmp/${f_name}    ${BTSFiles}/${f_name}
    Put File From Local To Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    /tmp/${f_name}    ${BTSFiles}/${f_name}
    [Return]    ${f_name}

Get Delta Plan And Values From ONAP
    ${time}    Get Time    epoch
    ${ONAP_SCF_DN}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    ${ONAP_SCF_DN}
    ${ONAP_P1_PATH}    Set Variable    ${onap_path}/attributes/vesAckTimeout
    ${ORIGIN_ONAP_DELTA_PLAN}    Set Variable    CB007010_C_1_${time}.xml
    ${cmd}    Set Variable    get-config --source running --filter-xpath ${onap_path} --out=/tmp/${ORIGIN_ONAP_DELTA_PLAN}
    Comment    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${ORIGIN_ONAP_DELTA_PLAN}    ${BTSFiles}/${ORIGIN_ONAP_DELTA_PLAN}
    Get File From Simulator To Local    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ...    ${ORIGIN_ONAP_DELTA_PLAN}    ${BTSFiles}/${ORIGIN_ONAP_DELTA_PLAN}
    Set Test Variable    ${ONAP_P1_PATH}
    Set Test Variable    ${ORIGIN_ONAP_DELTA_PLAN}
    Set Test Variable    ${ONAP_SCF_DN}

Provision On Netconf Locking Session
    [Arguments]    ${delta_plan_name}
    ${ssh_id}    SSHLibrary.Open Connection    ${ONAP["host_ip"]}
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=360 seconds
#    ${cmd_conn}    Catenate    connect --tls --host IPSEC    --key /home/ute/netconf/ca-key.pem
#    ...    --cert /home/ute/netconf/ee_cert.pem    --trusted /home/ute/netconf/ca-certificate.pem
#    ${cmd_conn}    Catenate    connect --tls --host ONAP_Int_Test --key /home/ute/netconf/server-key.pem
#    ...    --cert /home/ute/netconf/server-cert.pem --trusted /home/ute/netconf/ca-cert.pem
    ${cmd_conn}    Catenate    connect --tls --host MRBTS-${MRBTS_ID} --key /home/ute/.local/pano/cert/server-key.pem
    ...    --cert /home/ute/.local/pano/cert/server-cert.pem --trusted /home/ute/.local/pano/cert/ca-cert.pem
    ${cmd}    Set Variable    lock --target running --rpc-timeout 120
    ${cmd1}    Catenate    edit-config --target running --config=/tmp/${delta_plan_name} --test test-then-set
    ...    --error rollback --rpc-timeout 300s
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "${cmd}";sleep 10s;echo "${cmd1}")|netopeer2-cli
    ${ret}    SSHLibrary.Read Until Prompt

Create Netconf Locking Session
    ${ssh_id}    SSHLibrary.Open Connection    ${ONAP["host_ip"]}
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=3700 seconds
#    ${cmd_conn}    Catenate    connect --tls --host IPSEC    --key /home/ute/netconf/ca-key.pem
#    ...    --cert /home/ute/netconf/ee_cert.pem    --trusted /home/ute/netconf/ca-certificate.pem
#    ${cmd_conn}    Catenate    connect --tls --host ONAP_Int_Test --key /home/ute/netconf/server-key.pem
#    ...    --cert /home/ute/netconf/server-cert.pem --trusted /home/ute/netconf/ca-cert.pem
    ${cmd_conn}    Catenate    connect --tls --host MRBTS-${MRBTS_ID} --key /home/ute/.local/pano/cert/server-key.pem
    ...    --cert /home/ute/.local/pano/cert/server-cert.pem --trusted /home/ute/.local/pano/cert/ca-cert.pem
    ${cmd}    set variable    lock --target running --rpc-timeout 120
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "status";sleep 10s;echo "${cmd}";sleep 3600s;echo "status")|netopeer2-cli
    Comment    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "${cmd}";sleep 3600s;echo "status")|netopeer2-cli
    ${out_put}    SSHLibrary.Read Until    OK
    ${str_ID}    Get Lines Matching Regexp    ${out_put}    \\s*ID\\s*:\\s*\\d+\\s*    flags=IGNORECASE
    Should Not Be Empty    ${str_ID}
    ${netconf_sessionID}    Set Variable    ${str_ID.split(':')[-1].strip()}
    [Return]    ${ssh_id}    ${netconf_sessionID}

Reset Unit And Check ONAP CCN
    [Arguments]    ${dn_R}    ${reset_type}
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MRBTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    coam.reset_unit    ${dn_R}    reset_type=${reset_type}    detailed_output=${True}    timeout=600s
    Wait Until Keyword Succeeds    10 min    30 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ${dic_param}    Create Dictionary    availabilityStatus    off line    operationalState    disabled
    ${moChange_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${dn_R}    ${PRIMARY_CORE_DN}
    ...    ${MPLANE_IP}    replace    ${dic_param}
    Should Not Be Empty    ${moChange_CCN_msg}
    ${dic_param}    Create Dictionary    operationalState    enabled    proceduralStatus    configured
    ${moChange_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${dn_R}    ${PRIMARY_CORE_DN}
    ...    ${MPLANE_IP}    replace    ${dic_param}
    Should Not Be Empty    ${moChange_CCN_msg}

Create And Put New Delta Plan To ONAP
    [Arguments]    ${new_val}
    ${time}    Get Time    epoch
    ${f_name}    Set Variable    CB007010_C_1_${time}.xml
    ${parsed_xml}    XML.Parse XML    ${BTSFiles}/${ORIGIN_ONAP_DELTA_PLAN}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    ${dic_param}    Create Dictionary    vesAckTimeout    ${new_val}
    Modify ONAP Plan Parameters Of MO    ${ONAP_SCF_DN}    ${dic_param}    ${e_onap}
    XML.Save XML    ${e_onap}    ${BTSFiles}/CB007010_C_1_${time}.xml
    Comment    Put File From Local To Pod    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ...    ${ONAP_INFOR['netconf_server']}    ${f_name}    ${BTSFiles}/${f_name}
    Put File From Local To Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${f_name}    ${BTSFiles}/${f_name}
    [Return]    ${f_name}

Step ${index}: Provision On Netconf Locking Session And Check
    Log To Console    Step ${index}: Provision On Netconf Locking Session And Check
    ${f_name}    Create And Put New Delta Plan To ONAP    10
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MRBTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    Set Test Variable    ${NEED_RECOVER}    ${True}
    Provision On Netconf Locking Session    ${f_name}
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages    ${ONAP["host_ip"]}    ${ONAP["user"]}
    ...    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ${dic_param}    Create Dictionary    vesAckTimeout    ${10}
    ${feedback_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    provision    completed
    ${moChange_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${ONAP_SCF_DN}    ${PRIMARY_CORE_DN}
    ...    ${MPLANE_IP}    replace    ${dic_param}
    Should Be Equal As Integers    ${feedback_CCN_msg.__len__()}    ${1}
    Should Be Equal As Integers    ${moChange_CCN_msg.__len__()}    ${1}

Step ${index}: Lock The Netconf Database
    Log To Console    Step ${index}: Lock The Netconf Database
    ${ssh_id}    ${netconf_sessionID}    Create Netconf Locking Session
    Set Test Variable    ${LOCKING_SESSION_ID}    ${ssh_id}
    #2024-12-02:comment O1 Management WebUI checkpoint
#    ${datas}    SBTS WEM Get Datas Of ORAN O1 Management
#    ${Netconf_clients}    Get From Dictionary    ${datas}    Netconf clients
#    ${locked_client}    Create Dictionary    IP address=${ONAP['host_ip']}    Locked datastore(s)=Running    Session ID=${netconf_sessionID}
#    ...    User name=cmuser
#    ${is_found}    Set Variable    ${False}
#    FOR    ${client}    IN    @{Netconf_clients}
#        ${ret}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${client}    ${locked_client}
#        Continue For Loop If    '${ret}'=='${False}'
#        ${is_found}    Set Variable    ${True}
#        Exit For Loop
#    END
#    Should Be True    ${is_found}
    Comment    Admin Check Active Alarms TAF    #Comment while using simulator

Step ${index}: Provison On New Session When Netconf Locked And Check
    Log To Console    Step ${index}: Provison On New Session When Netconf Locked And Check
    ${f_name}    Create And Put New Delta Plan To ONAP    5
    ${cmd_edit_config}    Catenate    edit-config --target running --config=/tmp/${f_name}
    ...    --test test-then-set --error rollback --rpc-timeout 300s
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_edit_config}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
	...   ${cmd_edit_config}
    Should Contain    ${ret}    Operation can not execute because the actual configuration is locked    ignore_case=True
    Comment    Admin Check Active Alarms TAF    #Comment while using simulator

Step ${index}: Reset BBMOD And Check ONAP CCN
    Log To Console    Step ${index}: Reset BBMOD And Check ONAP CCN
    Reset Unit And Check ONAP CCN    ${DN_BBMOD_R}    Warm

Step ${index}: Reset RMOD And Check ONAP CCN
    Log To Console    Step ${index}: Reset RMOD And Check ONAP CCN
    Reset Unit And Check ONAP CCN    ${DN_RMOD_R}    Soft

Step ${index}: Get Data From New Session When Netconf Locked
    Log To Console    Step ${index}: Get Data From New Session When Netconf Locked
    ${cmd}    Set Variable    get-config --source running --filter-xpath ${ONAP_P1_PATH}
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Should Match Regexp    ${ret}    <vesAckTimeout>\\d+</vesAckTimeout>
    ${cmd}    Set Variable    get --filter-xpath ${ONAP_P1_PATH}
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Should Match Regexp    ${ret}    <vesAckTimeout>\\d+</vesAckTimeout>
    Comment    Admin Check Active Alarms TAF    #Comment while using simulator

Step ${index}: Validate Full Plan Via ONAP And Get FeedBack CCN
    Log To Console    Step ${index}: Validate Full Plan Via ONAP And Get FeedBack CCN
    ${f_name}    Get Full Plan From ONAP
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MRBTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ${cmd}    Set Variable    validate --src-config=/tmp/${f_name} --rpc-timeout 60s
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    Admin Check Active Alarms TAF
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ${completed_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    validation    completed
    Should Not Be Empty    ${completed_CCN_msg}

Step ${index}: Validate vesAckTimeout Via ONAP And Check CCN
    Log To Console    Step ${index}: Validate vesAckTimeout Via ONAP And Check CCN
    ${f_name}    Create And Put New Delta Plan To ONAP    3
    ${cmd_edit_config}    Catenate    edit-config --target running --config=/tmp/${f_name}
    ...    --test test-only --error rollback --rpc-timeout 300s
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MRBTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_edit_config}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ...    ${cmd_edit_config}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Sleep    5s    #time gap for complete CCN
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    Check_SBTS_SMOD_RMOD_Cells_Alarms
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ${dic_param}    Create Dictionary    vesAckTimeout    ${3}
    ${completed_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    validation    completed
    ${moChange_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${ONAP_SCF_DN}    ${PRIMARY_CORE_DN}
    ...    ${MPLANE_IP}    replace    ${dic_param}
    Should Not Be Empty    ${completed_CCN_msg}
    Should Be Empty    ${moChange_CCN_msg}

Step ${index}: Provision Via ONAP And Check CCN
    Log To Console    Step ${index}: Provision Via ONAP And Check CCN
    SSHLibrary.Switch Connection    ${LOCKING_SESSION_ID}
    SSHLibrary.Close Connection
    ${f_name}    Create And Put New Delta Plan To ONAP    ${ONAP_P1_VALUE}
    ${cmd_edit_config}    Catenate    edit-config --target running --config=/tmp/${f_name}
    ...    --test test-then-set --error rollback --rpc-timeout 300s
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MRBTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_edit_config}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ...    ${cmd_edit_config}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Sleep    5s    #time gap for complete CCN
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    Check_SBTS_SMOD_RMOD_Cells_Alarms
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ${dic_param}    Create Dictionary    vesAckTimeout    ${${ONAP_P1_VALUE}}
    ${completed_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    provision    completed
    ${moChange_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${ONAP_SCF_DN}    ${PRIMARY_CORE_DN}    ${MPLANE_IP}    replace
    ...    ${dic_param}
    Should Not Be Empty    ${completed_CCN_msg}
    Should Not Be Empty    ${moChange_CCN_msg}
    Set Test Variable    ${NEED_RECOVER}    ${False}