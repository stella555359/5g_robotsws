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
SyVe_CM_CB007010-C_002_Kill_Session_From_SMO
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For case:TA_RAN_ST_CB007010-C_B5_002_CM_Kill Session from SMO
    ...  The main steps performed for the test are:
    ...  - Setup Relationship Between RMOD And Cells
    ...  - Select One RMOD Randomly
    ...  - Provision Delta Plan On NetConf
    ...  - Check RMOD And Cells Action On SBTS
    ...  - Check Feedback and CCN Message On VES
    ...  Pass criteria: Provision delta plan from NetConf,and check parameter value on NetAct and CCN on ONAP.
    ...  Site is OK with no any unexpected alarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.19.2023 - New case
    ...  - 07.12.2023 - Add Step5 WebEM check point for CB007010-D
    ...  - 29.09.2024 - Comment WEBUI steps due to CB012236 Nokia rebranding in WebEM and CuDo

    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    LOG    ${TEST_NAME} of ${SUITE_NAME} start.    console=${True}
    Step 1: Get Current Session ID
    Step 2: Test Kill Upload Session
    Step 3: Test Kill Provision Session
    Step 4: Test Kill Lock Session
#    Step 5: Test Kill WebEM Session


Step ${index}: Get Current Session ID
    Log To Console    Step ${index}: Get Current Session ID
    ${status_ouput}    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    status
    ${tmp_str}    Fetch From Right    ${status_ouput}    Current NETCONF session:\r\n
    ${lines}    Split String    ${tmp_str}    \r\n
    ${sessionId}    Fetch From Right    ${lines[0]}    :
    Set Test Variable    ${sessionId_initial}    ${sessionId.strip()}
#    ${cmd_conn}    Catenate    connect --tls --host IPSEC    --key /home/ute/netconf/ca-key.pem
#    ...    --cert /home/ute/netconf/ee_cert.pem    --trusted /home/ute/netconf/ca-certificate.pem
#    ${cmd_conn}    Catenate    connect --tls --host ONAP_Int_Test --key /home/ute/netconf/server-key.pem
    ${cmd_conn}    Catenate    connect --tls --host MRBTS-${BTS_ID} --key /home/ute/netconf/server-key.pem
    ...    --cert /home/ute/netconf/server-cert.pem --trusted /home/ute/netconf/ca-cert.pem
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
    SSHLibrary.Get File    /tmp/Upload_Session1_command1.xml    ${Test Results Dir}/Upload_Session1_command1.xml
    Sleep    10s
    ${file_size}    OperatingSystem.Get File Size    ${Test Results Dir}/Upload_Session1_command1.xml
    Should Be True    ${file_size}>0
    Admin Check Active Alarms TAF

Step ${index}: Test Kill Provision Session
    Log To Console    Step ${index}: Test Kill Provision Session
    ${fileName_init}    Set Variable    Provision_Session1.xml
    ${fileName_updated1}    Set Variable    Provision_Session1_updated1.xml
    ${fileName_updated2}    Set Variable    Provision_Session1_updated2.xml
    ${current_value}    Get Parameter Value From WebEM    ${paramScfDN_Online}    ${paramName_Online}
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

    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd_getConfig}
    Get File From Simulator To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_init}    ${Test Results Dir}/${fileName_init}
    ${tmp_dic1}    Create Dictionary    ${paramName_Online}=${valueToSet}
    ${tmp_dic2}    Create Dictionary    ${paramName_Online}=${current_value_Online}
    ${param_dic1}    Create Dictionary     ${paramScfDN_Online}=${tmp_dic1}
    ${param_dic2}    Create Dictionary     ${paramScfDN_Online}=${tmp_dic2}
	Generate Delta Plan For NetConf    ${param_dic1}    ${Test Results Dir}/${fileName_init}    ${Test Results Dir}/${fileName_updated1}
	Generate Delta Plan For NetConf    ${param_dic2}    ${Test Results Dir}/${fileName_init}    ${Test Results Dir}/${fileName_updated2}
    Put File From Local To Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_updated1}    ${Test Results Dir}/${fileName_updated1}
    Put File From Local To Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_updated2}    ${Test Results Dir}/${fileName_updated2}

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
    ${newValue}    Get Parameter Value From WebEM    ${paramScfDN_Online}    ${paramName_Online}
    Should Be Equal As Strings    ${newValue}    ${valueToSet}
    Set Test Variable    ${needRecovery}    True
    Admin Check Active Alarms TAF

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
    Admin Check Active Alarms TAF

Step ${index}: Test Kill WebEM Session
    Log To Console    Step ${index}: Test Kill WebEM Session
    SSHLibrary.Open Connection    host=${ONAP["host_ip"]}    alias=WebEM_Session1
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=300 seconds
    ${cmd1}    Set Variable    get-config --source running --out=/tmp/WebEM_Session1_command1.xml
    ${cmd2}    Set Variable    get-config --source running --out=/tmp/WebEM_Session1_command2.xml
    SSHLibrary.Write    (echo "${cmd_conn}";sleep 30s;echo "${cmd1}";sleep 60s;echo "${cmd2}")|netopeer2-cli
    sleep    40s
    ${sessionId_WebEM}    evaluate    ${sessionId_initial}+8
    ${result}    SBTS WEM Kill Session on ORAN O1 Management    ${sessionId_WebEM}    ${ONAP["host_ip"]}
    Should Be True    ${result}
    SSHLibrary.Switch Connection    WebEM_Session1
    ${ret1}    SSHLibrary.Read Until Prompt
    Log    ${ret1}
    Should Contain    ${ret1}    \r\nnc ERROR: Communication socket unexpectedly closed (OpenSSL).\r\n
    SSHLibrary.Get File    /tmp/WebEM_Session1_command1.xml    ${Test Results Dir}/WebEM_Session1_command1.xml
    Sleep    10s
    ${file_size}    OperatingSystem.Get File Size    ${Test Results Dir}/WebEM_Session1_command1.xml
    Should Be True    ${file_size}>0
    Admin Check Active Alarms TAF

TC SetUp
    Log To Console    TC SetUp
    Common Test Setup
    #${win_index}    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}
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

    ${paramName_Online}    Set Variable    actARPBasedAC    #forceSingleTxModeSupportEnabled
    @{paramValuesPool_Online}    Create List    on    off
    ${paramScfDN_Online}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    Set Test Variable    ${paramName_Online}
    Set Test Variable    ${paramValuesPool_Online}
    Set Test Variable    ${paramScfDN_Online}


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
    [Teardown]    Close All Browsers

Recovery SBTS
    coam.Create Delta
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_Online}    parameter=${paramName_Online}    value=${current_value_Online}
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

