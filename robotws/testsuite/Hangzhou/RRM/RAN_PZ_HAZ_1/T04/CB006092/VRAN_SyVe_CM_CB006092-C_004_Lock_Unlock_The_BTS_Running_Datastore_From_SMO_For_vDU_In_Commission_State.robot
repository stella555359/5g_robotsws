*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for NFTA
...   RAN_ST_CB006092-C_004_CM_Lock_Unlock the BTS Running Datastore from SMO for vDU in commission state
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot


*** Keywords ***
VRAN_SyVe_CM_CB006092-C_004_Lock_Unlock_The_BTS_Running_Datastore_From_SMO_For_vDU_In_Commission_State
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    09.07.2025, yuyan.xu@nokia-sbell.com
    Step 1: Provision On Netconf Locking Session And Check
    Step 2: Lock The Netconf Database
    Step 3: Provision On New Session When Netconf Locked And Check
    Step 4: Reset RMOD And Check ONAP CCN
    Step 5: Get Data From New Session When Netconf Locked
    Step 6: Validate vesAckTimeout Via ONAP And Check CCN
    Step 7: Validate Full Plan Via ONAP And Get FeedBack CCN
    Step 8: Provision Via ONAP And Check CCN

Step ${index}: Provision On Netconf Locking Session And Check
    Log To Console    Step ${index}: Provision On Netconf Locking Session And Check
    ${f_name}    Create And Put New Delta Plan To ONAP    10
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    #Set Test Variable    ${NEED_RECOVER}    ${True}
    Provision On Netconf Locking Session    ${f_name}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${dic_param}    Create Dictionary    vesAckTimeout    ${10}
    ${feedback_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN
    ...    ${VES_CCN_msgs}    vDU    ${vesSourceName}    provision    completed
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...   vDU    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${dic_param}

    Should Be Equal As Integers    ${feedback_CCN_msg.__len__()}    ${1}
    Should Be Equal As Integers    ${target_VES_CCN_msg.__len__()}    ${1}

Create And Put New Delta Plan To ONAP
    [Arguments]    ${new_val}
    ${time}    Get Time    epoch
    ${f_name}    Set Variable    CB006092-C_004_${time}.xml
    ${parsed_xml}    XML.Parse XML    ${TEST_LOG_DIRECTORY}/${ORIGIN_ONAP_DELTA_PLAN}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    ${dic_param}    Create Dictionary    vesAckTimeout    ${new_val}
    Modify ONAP Plan Parameters Of MO    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    ${dic_param}    ${e_onap}
    XML.Save XML    ${e_onap}    ${TEST_LOG_DIRECTORY}/${f_name}
    Put File From Local To Simulator    ${host_ip}    ${user}    ${pwd}    ${f_name}    ${TEST_LOG_DIRECTORY}/${f_name}
    [Return]    ${f_name}

Provision On Netconf Locking Session
    [Arguments]    ${delta_plan_name}
    ${ssh_id}    SSHLibrary.Open Connection    ${host_ip}
    ${out_put}    SSHLibrary.Login    ${user}    ${pwd}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=360 seconds
    ${cmd_conn}    Catenate    connect --tls --host MRBTS-${vDU_id} --key /home/ute/.local/pano/cert/server-key.pem
    ...    --cert /home/ute/.local/pano/cert/server-cert.pem --trusted /home/ute/.local/pano/cert/ca-cert.pem
    ${cmd}    Set Variable    lock --target running --rpc-timeout 120
    ${cmd1}    Catenate    edit-config --target running --config=/tmp/${delta_plan_name} --test test-then-set
    ...    --error rollback --rpc-timeout 300s
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "${cmd}";sleep 10s;echo "${cmd1}")|netopeer2-cli
    ${ret}    SSHLibrary.Read Until Prompt

Step ${index}: Lock The Netconf Database
    Log To Console    Step ${index}: Lock The Netconf Database
    ${ssh_id}    SSHLibrary.Open Connection    ${host_ip}
    ${out_put}    SSHLibrary.Login    ${user}    ${pwd}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=3700 seconds
    ${cmd_conn}    Catenate    connect --tls --host MRBTS-${vDU_id} --key /home/ute/.local/pano/cert/server-key.pem
    ...    --cert /home/ute/.local/pano/cert/server-cert.pem --trusted /home/ute/.local/pano/cert/ca-cert.pem
    ${cmd}    set variable    lock --target running --rpc-timeout 120
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "status";sleep 10s;echo "${cmd}";sleep 3600s;echo "status")|netopeer2-cli
    ${out_put}    SSHLibrary.Read Until    OK
    ${str_ID}    Get Lines Matching Regexp    ${out_put}    \\s*ID\\s*:\\s*\\d+\\s*    flags=IGNORECASE
    Should Not Be Empty    ${str_ID}
    ${netconf_sessionID}    Set Variable    ${str_ID.split(':')[-1].strip()}
    Set Test Variable    ${LOCKING_SESSION_ID}    ${ssh_id}

Step ${index}: Provision On New Session When Netconf Locked And Check
    Log To Console    Step ${index}: Provision On New Session When Netconf Locked And Check
    ${f_name}    Create And Put New Delta Plan To ONAP    5
    ${cmd_edit_config}    Catenate    edit-config --target running --config=/tmp/${f_name}
    ...    --test test-then-set --error rollback --rpc-timeout 300s
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_edit_config}
    Should Contain    ${ret}    Operation can not execute because the actual configuration is locked    ignore_case=True

Step ${index}: Reset RMOD And Check ONAP CCN
    Log To Console    Step ${index}: Reset RMOD And Check ONAP CCN
    ${rmods_list}    Get RMOD ID List
    ${rmod_id}    Evaluate    random.choice(${rmods_list})    modules=random, sys
    ${rmod_id_list}    Create List    ${rmod_id}
    #check CCN on ves
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    Reset RUs By Rest In vDU    ${rmod_id_list}
    Sleep    30s
    Wait Until Keyword Succeeds    10min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    log    ${VES_CCN_msgs}
    ${Unlock_RF_Dic}    Create Dictionary    administrativeState=Unlocked
    #${dic_param}    Create Dictionary    availabilityStatus    off line    operationalState    disabled
    #${dic_param}    Create Dictionary    operationalState    enabled    proceduralStatus    configured
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${vDU_id}/EQM_R-1/APEQM_R-1/RMOD_R-${rmod_id}
    ...    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${Unlock_RF_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Get Data From New Session When Netconf Locked
    Log To Console    Step ${index}: Get Data From New Session When Netconf Locked
    ${onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${cmd}    Set Variable    get-config --source running --filter-xpath ${onap_path}/attributes/vesAckTimeout
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd}
    Should Match Regexp    ${ret}    <vesAckTimeout>\\d+</vesAckTimeout>
    ${cmd}    Set Variable    get --filter-xpath ${onap_path}/attributes/vesAckTimeout
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd}
    Should Match Regexp    ${ret}    <vesAckTimeout>\\d+</vesAckTimeout>

Step ${index}: Validate vesAckTimeout Via ONAP And Check CCN
    Log To Console    Step ${index}: Validate vesAckTimeout Via ONAP And Check CCN
    ${f_name}    Create And Put New Delta Plan To ONAP    3
    ${cmd_edit_config}    Catenate    edit-config --target running --config=/tmp/${f_name}
    ...    --test test-only --error rollback --rpc-timeout 300s
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_edit_config}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Sleep    5s    #time gap for complete CCN
    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${dic_param}    Create Dictionary    vesAckTimeout    ${3}
    ${completed_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN
    ...    ${VES_CCN_msgs}    vDU    ${vesSourceName}    validation    completed
    ${moChange_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...    vDU    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${dic_param}
    Should Not Be Empty    ${completed_CCN_msg}
    Should Be Empty    ${moChange_CCN_msg}


Step ${index}: Validate Full Plan Via ONAP And Get FeedBack CCN
    Log To Console    Step ${index}: Validate Full Plan Via ONAP And Get FeedBack CCN
    #Generate full plan
    ${time}    Get Time    epoch
    ${f_name}    Set Variable    CB006092-C_004_full_${time}.xml
    ${cmd}    Set Variable    get-config --source running --out=/tmp/${f_name}
    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${f_name}    ${TEST_LOG_DIRECTORY}/${f_name}
    ${parsed_xml}    XML.Parse XML    ${TEST_LOG_DIRECTORY}/${f_name}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    XML.Save XML    ${e_onap}    ${TEST_LOG_DIRECTORY}/${f_name}
    Put File From Local To Simulator    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${f_name}    ${TEST_LOG_DIRECTORY}/${f_name}
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${cmd}    Set Variable    validate --src-config=/tmp/${f_name} --rpc-timeout 60s
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd}
    ##${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    ##Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${completed_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN
    ...    ${VES_CCN_msgs}    vDU    ${vesSourceName}    validation    completed
    ##Should Not Be Empty    ${completed_CCN_msg}

Step ${index}: Provision Via ONAP And Check CCN
    Log To Console    Step ${index}: Provision Via ONAP And Check CCN
    SSHLibrary.Switch Connection    ${LOCKING_SESSION_ID}
    SSHLibrary.Close Connection
    ${f_name}    Create And Put New Delta Plan To ONAP    ${ONAP_P1_VALUE}
    ${cmd_edit_config}    Catenate    edit-config --target running --config=/tmp/${f_name}
    ...    --test test-then-set --error rollback --rpc-timeout 300s
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_edit_config}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Sleep    5s    #time gap for complete CCN
    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${dic_param}    Create Dictionary    vesAckTimeout    ${${ONAP_P1_VALUE}}
    ${completed_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN
    ...    ${VES_CCN_msgs}    vDU    ${vesSourceName}    provision    completed
    ${moChange_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...    vDU    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${dic_param}
    Should Not Be Empty    ${completed_CCN_msg}
    Should Not Be Empty    ${moChange_CCN_msg}
    Set Test Variable    ${NEED_RECOVER}    ${False}


Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Log    ${ReIntegrate_vCU}
    Common Test Setup For AIC
    #Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    #need develop kw
    #Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}
    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
    Set Test Variable    ${user}    ${ONAP["user"]}
    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
    vDU Login By Rest
    ${vesSourceName}    Get Parameter Value From vDU     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName}
    ${dnPrefix}    Get Parameter Value From vDU     MRBTS-${vDU_id}    dnPrefix
    Set Test Variable    ${dnPrefix}

    ${time}    Get Time    epoch
    ${onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${ORIGIN_ONAP_DELTA_PLAN}    Set Variable    CB006092-C_003_${time}.xml
    ${cmd_getConfig}    Set Variable    get-config --source running --filter-xpath ${onap_path} --out=/tmp/${ORIGIN_ONAP_DELTA_PLAN}
    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_getConfig}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}
    ...    ${ORIGIN_ONAP_DELTA_PLAN}    ${TEST_LOG_DIRECTORY}/${ORIGIN_ONAP_DELTA_PLAN}
    Set Test Variable    ${ORIGIN_ONAP_DELTA_PLAN}
    #Check vesAckTimeout should not be 10
    @{para_list}    Create List    vesAckTimeout
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Set Test Variable    ${ONAP_P1_VALUE}    ${out["${mo_list[0]}"]["${para_list[0]}"]}
    Should Not Be Equal As Strings    ${out["${mo_list[0]}"]["${para_list[0]}"]}    ${10}
    ...    The value of vesAckTimeout cannot be the same as to be set

Case Postcondition
    Log To Console    Case Postcondition
    Common Test Teardown For AIC
    #Teardown NetAct