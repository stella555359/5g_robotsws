*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is only for NFTA
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${RECOVERY_FLAG}    ${False}
${du_oamssh_ip}    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}

*** Keywords ***
VRAN_SyVe_CM_CB006092-C_011_CM_Kill_Session_from_SMO_for_vDU
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    16.07.2025, lixin.kang@nokia-sbell.com
    Step 1: Get Current Session ID
    Step 2: Test Kill Upload Session
    Step 3: Test Kill Provision Session
    Step 4: Test Kill Lock Session

Step ${index}: Get Current Session ID
    Log To Console    Step ${index}: Get Current Session ID
    ${status_ouput}    Execute NetConf Command On ONAP Simulator
    ...    MRBTS-${vDU_id}    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    status
    ${tmp_str}    Fetch From Right    ${status_ouput}    Current NETCONF session:\r\n
    ${lines}    Split String    ${tmp_str}    \r\n
    ${sessionId}    Fetch From Right    ${lines[0]}    :
    Set Test Variable    ${sessionId_initial}    ${sessionId.strip()}
    ${cmd_conn}    Catenate    connect --tls --host MRBTS-${vDU_id} --key /home/ute/.local/pano/cert/server-key.pem
    ...    --cert /home/ute/.local/pano/cert/server-cert.pem --trusted /home/ute/.local/pano/cert/ca-cert.pem
    Set Test Variable    ${cmd_conn}

Step ${index}: Test Kill Upload Session
    Log To Console    Step ${index}: Test Kill Upload Session
    SSHLibrary.Open Connection    host=${ONAP["host_ip"]}    alias=Upload_Session1
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=300 seconds
    ${cmd1}    Set Variable    get-config --source running --out=/tmp/Upload_Session1_command1.xml
    ${cmd2}    Set Variable    get-config --source running --out=/tmp/Upload_Session1_command2.xml
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "${cmd1}";sleep 60s;echo "${cmd2}")|netopeer2-cli
    SSHLibrary.Open Connection    host=${ONAP["host_ip"]}    alias=Upload_Session2
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=200 seconds
    ${sessionId_upload}    evaluate    ${sessionId_initial}+1
    ${cmd3}    Set Variable    kill-session --sid ${sessionId_upload}
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 60s;echo "${cmd3}")|netopeer2-cli
    ${ret2}    SSHLibrary.Read Until Prompt
    Log    ${ret2}
    Should Contain    ${ret2}    \r\nOK\r\n
    SSHLibrary.Switch Connection    Upload_Session1
    ${ret1}    SSHLibrary.Read Until Prompt
    Log    ${ret1}
    Should Contain    ${ret1}    \r\nnc ERROR: Communication socket unexpectedly closed (OpenSSL).\r\n
    SSHLibrary.Get File    /tmp/Upload_Session1_command1.xml    ${TEST_LOG_DIRECTORY}/Upload_Session1_command1.xml
    Sleep    10s
    ${file_size}    OperatingSystem.Get File Size    ${TEST_LOG_DIRECTORY}/Upload_Session1_command1.xml
    Should Be True    ${file_size}>0

Step ${index}: Test Kill Provision Session
    Log To Console    Step ${index}: Test Kill Provision Session
    ${fileName_init}    Set Variable    Provision_Session1.xml
    ${fileName_updated1}    Set Variable    Provision_Session1_updated1.xml
    ${fileName_updated2}    Set Variable    Provision_Session1_updated2.xml
    vDU Login By Rest
    ${current_value}    Get Parameter Value From vDU    ${paramScfDN_Online}    ${paramName_Online}
    Set Test Variable    ${current_value_Online}    ${current_value}
    Remove Values From List    ${paramValuesPool_Online}    ${current_value}
    ${valueToSet}    Evaluate    random.choice(${paramValuesPool_Online})    modules=random, sys
    ${paramXpathOnap}    Transfer SCF DN To Xpath Of ONAP Get Result    ${paramScfDN_Online}

    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --filter-xpath ${paramXpathOnap}/attributes/${paramName_Online} --out=/tmp/${fileName_init}
    ${cmd_editConfig1}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated1} --test test-then-set --error rollback --rpc-timeout 160s
    ${cmd_editConfig2}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated2} --test test-then-set --error rollback --rpc-timeout 160s

    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd_getConfig}
    Get File From Simulator To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_init}
    ${tmp_dic1}    Create Dictionary    ${paramName_Online}=${valueToSet}
    ${tmp_dic2}    Create Dictionary    ${paramName_Online}=${current_value_Online}
    ${param_dic1}    Create Dictionary     ${paramScfDN_Online}=${tmp_dic1}
    ${param_dic2}    Create Dictionary     ${paramScfDN_Online}=${tmp_dic2}
	Generate Delta Plan For NetConf    ${param_dic1}    ${TEST_LOG_DIRECTORY}/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_updated1}
	Generate Delta Plan For NetConf    ${param_dic2}    ${TEST_LOG_DIRECTORY}/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_updated2}
    Put File From Local To Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_updated1}    ${TEST_LOG_DIRECTORY}/${fileName_updated1}
    Put File From Local To Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_updated2}    ${TEST_LOG_DIRECTORY}/${fileName_updated2}

    SSHLibrary.Open Connection    host=${ONAP["host_ip"]}    alias=Provision_Session1
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=600 seconds
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "${cmd_editConfig1}";sleep 180s;echo "${cmd_editConfig2}")|netopeer2-cli

    SSHLibrary.Open Connection    host=${ONAP["host_ip"]}    alias=Provision_Session2
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=400 seconds
    ${sessionId_provision}    evaluate    ${sessionId_initial}+4
    ${cmd3}    Set Variable    kill-session --sid ${sessionId_provision}
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 180s;echo "${cmd3}")|netopeer2-cli
    ${ret2}    SSHLibrary.Read Until Prompt
    Should Contain    ${ret2}    \r\nOK\r\n
    SSHLibrary.Switch Connection    Provision_Session1
    ${ret1}    SSHLibrary.Read Until Prompt
    Should Contain    ${ret1}    \r\nnc ERROR: Communication socket unexpectedly closed (OpenSSL).\r\n
    ${newValue}    Get Parameter Value From vDU    ${paramScfDN_Online}    ${paramName_Online}
    Should Be Equal As Strings    ${newValue}    ${valueToSet}

Step ${index}: Test Kill Lock Session
    Log To Console    Step ${index}: Test Kill Lock Session
    SSHLibrary.Open Connection    host=${ONAP["host_ip"]}    alias=Lock_Session1
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=300 seconds
    ${cmd}    Set Variable    lock –-target running –-rpc-timeout 120
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "${cmd}";sleep 60s;echo "${cmd}")|netopeer2-cli
    SSHLibrary.Open Connection    host=${ONAP["host_ip"]}    alias=Lock_Session2
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=200 seconds
    ${sessionId_lock}    evaluate    ${sessionId_initial}+6
    ${cmd3}    Set Variable    kill-session --sid ${sessionId_lock}
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 60s;echo "${cmd3}")|netopeer2-cli
    ${ret2}    SSHLibrary.Read Until Prompt
    Log    ${ret2}
    Should Contain    ${ret2}    \r\nOK\r\n
    SSHLibrary.Switch Connection    Lock_Session1
    ${ret1}    SSHLibrary.Read Until Prompt
    Log    ${ret1}
    Should Contain    ${ret1}    \r\nnc ERROR: Communication socket unexpectedly closed (OpenSSL).\r\n

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Log    ${ReIntegrate_vCU}
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    #need develop kw
    #Run Keyword If    ${Integrate_Need}    Integrate VDU To ONAP Simulator    ${vDU_id}    ${ONAP['host_ip']}
    ${paramName_Online}    Set Variable    actDrxSleepOff
    @{paramValuesPool_Online}    Create List    Disabled    Enabled_VoNr_SAg
    ${paramScfDN_Online}    Set Variable    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-1
    Set Test Variable    ${paramName_Online}
    Set Test Variable    ${paramValuesPool_Online}
    Set Test Variable    ${paramScfDN_Online}

Case Postcondition
    Log To Console    Case Postcondition
    Run Keyword And Ignore Error     Delete CMD Via Admin
    Common Test Teardown For AIC
    Teardown NetAct