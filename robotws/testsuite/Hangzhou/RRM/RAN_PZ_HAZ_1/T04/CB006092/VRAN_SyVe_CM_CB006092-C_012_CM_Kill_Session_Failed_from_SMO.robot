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
VRAN_SyVe_CM_CB006092-C_012_CM_Kill_Session_Failed_from_SMO
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    16.07.2025, lixin.kang@nokia-sbell.com
    Step 1: Test Kill Current Session
    Step 2: Test Kill Not Exist Session
    Step 3: Test Kill With Invalid Request

Step ${index}: Test Kill Current Session
    Log To Console    Step ${index}: Test Kill Current Session
    SSHLibrary.Open Connection    host=${ONAP["host_ip"]}    alias=current_session
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=300 seconds
    ${cmd_conn}    Catenate    connect --tls --host MRBTS-${vCU_id} --key /home/ute/.local/pano/cert/server-key.pem
    ...    --cert /home/ute/.local/pano/cert/server-cert.pem --trusted /home/ute/.local/pano/cert/ca-cert.pem
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "status")|netopeer2-cli
    ${ret}    SSHLibrary.Read Until Prompt
    ${tmp_str}    Fetch From Right    ${ret}    Current NETCONF session:\r\n
    ${lines}    Split String    ${tmp_str}    \r\n
    ${sessionId}    Fetch From Right    ${lines[0]}    :
    Set Test Variable    ${sessionId_initial}    ${sessionId.strip()}
    ${sessionId_new}    Evaluate    ${sessionId_initial}+1
    ${cmd}    Set Variable    kill-session --sid ${sessionId_new}
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "${cmd} ")|netopeer2-cli
    ${ret}    SSHLibrary.Read Until Prompt
    Should Contain    ${ret}    It is forbidden to kill own session

Step ${index}: Test Kill Not Exist Session
    Log To Console    Step ${index}: Test Kill Not Exist Session
    SSHLibrary.Open Connection    host=${ONAP["host_ip"]}    alias=current_session
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=300 seconds
    ${cmd_conn}    Catenate    connect --tls --host MRBTS-${vCU_id} --key /home/ute/.local/pano/cert/server-key.pem
    ...    --cert /home/ute/.local/pano/cert/server-cert.pem --trusted /home/ute/.local/pano/cert/ca-cert.pem
    ${cmd}    Set Variable    kill-session --sid 123
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "${cmd}")|netopeer2-cli
    ${ret}    SSHLibrary.Read Until Prompt
    Should Contain    ${ret}    Session with the specified "session-id" not found

Step ${index}: Test Kill With Invalid Request
    Log To Console    Step ${index}: Test Kill With Invalid Request
    SSHLibrary.Open Connection    host=${ONAP["host_ip"]}    alias=current_session
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=300 seconds
    ${cmd_conn}    Catenate    connect --tls --host MRBTS-${vCU_id} --key /home/ute/.local/pano/cert/server-key.pem
    ...    --cert /home/ute/.local/pano/cert/server-cert.pem --trusted /home/ute/.local/pano/cert/ca-cert.pem
    ${cmd}    Set Variable    kill --sid 123
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "${cmd}")|netopeer2-cli
    ${ret}    SSHLibrary.Read Until Prompt
    Should Contain    ${ret}    No such command

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
    ${paramName_Online}    Set Variable    a1MeashoPrefNRLayerEnabled
    @{paramValuesPool_Online}    Create List    rsrp    rsrpAndRsrq
    ${paramScfDN_Online}    Set Variable    MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-1
    Set Test Variable    ${paramName_Online}
    Set Test Variable    ${paramValuesPool_Online}
    Set Test Variable    ${paramScfDN_Online}

Case Postcondition
    Log To Console    Case Postcondition
    Run Keyword And Ignore Error     Delete CMD Via Admin
    Common Test Teardown For AIC
    Teardown NetAct