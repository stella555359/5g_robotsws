*** Settings ***
Documentation
...    Author: velu.p@nokia.com
...    world market O-RAN compliant O-CDU with FDD eCPRI interface (CAT-A) for FDD NR or FDD LTE.
...    Subitem -C is related to O-RAN V5.0 improvements with the use of 3rd party RU.
...    Confluence link: link
...    References: ToDo
...    QualityCenter: ToDo
...    Sample execution:
...    AC/REQ:


Library    OperatingSystem    WITH NAME    os
Library        String      WITH NAME   str
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.transport.ssh
Library    taf.sbts.oam.coam.admin
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    classical
Library    taf.analyzer.netconf    WITH NAME    yang
Library    SSHLibrary
Library    Collections
Library    DateTime
Library    BuiltIn
Library    SeleniumLibrary
Library    taf.selenium.sbts    WITH NAME    selenium
Library    Process
Library    String
Library    taf.sw.scout    WITH NAME    scout
Library    taf.analyzer.netconf
Library     ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.collectors.core    WITH NAME    core
Library           taf.selenium.sbts    WITH NAME    soam
Library      taf.gnb.oam.coam.admin    WITH NAME    coam.admin    


Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin_infomodel.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/pretest_posttest.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/system.robot

#Test Setup      Test Setup
#Test Teardown   Test Teardown

*** Variables ***

${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}

${UPDATE_FILE_PATH}    /home/ute/RF_PCI/2392/Download_gNB_Package

${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}
${DIST_NAME}           MRBTS-{}/NRBTS-{}
${LOG_PATH}             /home/ute/results/troubleshooting_logs

@{ALLOWED_ALARMS}    &{4592}    &{10_allowed}    &{4729_allowed}    &{FAULT_61524}    &{FAULT_4654}    &{FAULT_4655}
...    &{FAULT_61649}    &{FAULT_61618}    &{FAULT_4073}    &{FAULT_4176}    &{FAULT_4720}
&{4592}     fault_id=4592
...         alarm_id=7115
...         alarm_severity=Warning
...         fault_name="BTS Reset Cause"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
&{1500}     fault_id=1500
...         alarm_id=7240
...         alarm_severity=Minor
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="alarm1"
&{4729_allowed}     fault_id=4729
...         alarm_id=7115
...         alarm_severity=Warning
...         notifier=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="O-RU host key change detected"
&{4729}     fault_id=4729
...         alarm_id=7115
...         alarm_severity=Warning
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="O-RU host key change detected"
&{FAULT_4654}              fault_id=4654
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Ethernet port security is disabled"
...                        notifier=
&{10_allowed}     fault_id=10
...         alarm_id=7116
...         alarm_severity=Critical
...         notifier=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="No connection to unit"
&{FAULT_61524}             fault_id=61524
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="SSH enabled"
...                        notifier=
&{FAULT_4655}              fault_id=4655
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Service account root access is enabled"
...                        notifier=
&{FAULT_4073}             fault_id=4073
...                        alarm_id=7115
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Fan vendor not detected"
...                        notifier=
&{FAULT_4176}             fault_id=4176
...                        alarm_id=7240
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="SFP Error"
...                        notifier=
&{FAULT_4720}             fault_id=4720
...                        alarm_id=7115
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Mismatch of RU reported capabilities with static HW Validation information"
...                        notifier=
&{10}     fault_id=10
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="No connection to unit"
&{FAULT_61649}             fault_id=61649
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name=regex"LMP access via port \\d+"
...                        notifier=
&{FAULT_61618}             fault_id=61618
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Operator Certificate About to Expire or Expired"
...                        notifier=

${RSA_FILE}=                            /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CB008205-G/Configurations/rsa.pub
${oran_alias}=                          oran_sim
${DOCKER_NAME}=                         SG01
${NETCONF_TRACE_REMOTE_PATH}=           /tmp/node_FHNET00/tmp/RMOD_L-1_NetconfRpcMessageTrace.log
${NETCONF_TRACE_LOCAL_PATH}=            /home/ute/Downloads/RMOD_L-1_NetconfRpcMessageTrace.log
${XML_DOCKER_PATH}=                     /home
${EDIT_CMD}=                            edit-config --target running --config=/home/
${RPC_CMD}=                             user-rpc --content /opt/dev/xml
${ORU_SIM_IP}=                          10.45.150.73
${SCF_PATH}=                            /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CB008205-G/Configurations
${WebEM IP}                             https://192.168.255.1:3600
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${url}=                                 https://192.168.255.129
${sw_release}=                          SBTS00
${browser}=                             Chrome
${INPUT_NAME_FIELD}=                    login-username
${INPUT_PASSWORD_FIELD}=                login-password
${LOGIN_BUTTON}=                        //span[contains(text(), 'Login')]
${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${PLUS_BUTTON_TRUNK}
...  //button[@class="p-element p-button-secondary p-button-text p-button-sm p-button p-component p-button-icon-only"]
${PLUS_BUTTON_22R2}    //button[@class="ui-button-secondary ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only"]
${SEND_BUTTON}=                         //span[contains(text(), 'Send')]
${CONFIGURE_RADIO_SUCCEEDED}=           //span[contains(text(), 'Configure netconf radio succeeded')]
${CONFIGURATION_TAB}=                   //div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
${NETCONF_RADIO_MANAGEMENT_BUTTON}=     //span[contains(text(),'Netconf Radio Management')]
${ACCOUNTS_CONFIGURATION}=    //div[contains(text(),'Accounts configuration')]
${DEFAULT_ACCOUNT_NAME}=    xranuser
${DEFAULT_ACCOUNT_PASS}=    xran-password
${UNSECURE_CIPHERS}=    //span[@id="pr_id_3_label"]
${SSH_AUTH_METHOD}=    //span[@id="pr_id_4_label"]
${TRASH_BUTTON}=    //button[@class="p-element delete-account p-button-secondary p-button-text p-button-sm p-button p-component p-button-icon-only"]
${RMOD_PATH}=    MRBTS-1/EQM-1/APEQM-1/RMOD-1
${ACCOUNT_REMOVE_BUTTON}=    //button[@class="p-element p-button-secondary p-button p-component p-button-icon-only ng-star-inserted"]
${netconf_file}=    /home/ute/robotws/${tc}/RMOD_L-1_NetconfRpcMessageTrace.log
${tc}=    TC_03_O-RU_M-Plane_version_check_when_supported_M-Plane_version_value_is_lower_than_O-DU_minimum_supported_version_in_LTE_FDD  



*** Keywords ***

TC_03_O-RU_M-Plane_version_check_when_supported_M-Plane_version_value_is_lower_than_O-DU_minimum_supported_version_in_LTE_FDD
    Common_Precondition
    Prepare Environment
    soam.login    https://192.168.255.129    Nemuadmin    nemuuser    version=Sbts24R2    browser=Chrome
    Log To Console    \n--checking m-plane link status after 2 min of additional Creation--\n
    ${ru_info}=    soam.get ru info    RMOD    1
    Log To Console    ${ru_info}
    ${mplane_status}    Set Variable    ${ru_info['Status']['M-Plane link status']}
    Run Keyword Unless    '${mplane_status}'== 'Connected'    Fail
    Netconf File Collection
    Step1: Validating M-plane negotiation    ${netconf_file}
    step2: Trigger log collection (snapshot) in O-DU from WebEM
    sleep    10
    #wait Until Keyword Succeeds    2min    10s    Link SCOUT SCF to Configuration ID for Reporting

Step1: Validating M-plane negotiation
    [Arguments]    ${netconf_file}
    ${a}=    netconf_get_value     ${netconf_file}    rpc    get    operational-info
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    supported-mplane-version
    run keyword and continue on failure   Should not be empty    ${a}
    Log to console  ${a}
    ${b}=  Get Dictionary Values  ${a[0][2]}
    Log to console  ${b}
    Should Be True    @{b} < ['5.0.0']
      
   
Netconf File Collection

    ${proxy}       Create Dictionary    host=10.58.238.216    user=ute    password=BT5l@bus3rl0g1n
    ${executor}    Create Dictionary    host=192.168.255.129    user=toor4nsn    password=oZPS0POrRieRtu
    ...     proxy=${proxy}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    30s
    core.collect_collectors    names=coredump    target_dir=/home/ute/robotws/${tc}
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/robotws/${tc}/coredump/coredump1.log.tgz -C /home/ute/robotws/${tc}/coredump
    os.Copy File    /home/ute/robotws/${tc}/coredump/RMOD_L-1_NetconfRpcMessageTrace.log    
	...    /home/ute/robotws/${tc}/RMOD_L-1_NetconfRpcMessageTrace.log
    sleep    100

Test Setup 
    os.Remove Files    /home/ute/results/troubleshooting_logs/*
    os.Remove Files    /home/ute/results/snapshot/*.zip
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    taf.sbts.oam.coam.admin.Setup Admin    name=admin1
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    Watch alarms           allowed_alarms=${allowed_alarms}
    ...                    interval=10 sec
    delete_files_netconf
    sleep    60
    


step2: Trigger log collection (snapshot) in O-DU from WebEM
        Log to console   \n--Start troubleshooting log collection(Snapshot) from WebEM--\n
        soam.login    https://192.168.255.129    Nemuadmin    nemuuser  timeout=180    
		...    download_dir=/home/ute/robotws/${tc}/snapshot    version=24R2    browser=Chrome
        Log To Console    Snapshot collection
        soam.snapshot_collection_settings    All log files    Local
        ${snapshot1}=    soam.collect_snapshot    snapshot_waiting_timeout=240
        os.Copy File    ${snapshot1}	/home/ute/results/Snapshot_step1.zip
       
        
snapshot
        soam.login    https://192.168.255.129    Nemuadmin    nemuuser  timeout=180    download_dir=/home/ute/results/snapshot    
		...    version=21B    browser=Firefox
        Log To Console    Snapshot collection
        soam.snapshot_collection_settings    All log files    Local
        ${snapshot1}=    soam.collect_snapshot    snapshot_waiting_timeout=240
        os.Copy File    ${snapshot1}	/home/ute/results/Snapshot1.zip
        sleep    15
        ${troubleshootinglog_file_1}=    file_ex    /home/ute/results/snapshot_dest/Snapshot1.zip   runtime_DEFAULT.log
        Should Be True    '${runtime_DEFAULT_1}'=='True'
        sleep    10
        Netconf File Collection
        Netconf_Message_validation
        delete_files_netconf
        sleep    60
        Log To Console    Snapshot cancellation inbetween
        classical.collect_snapshot    snapshot_waiting_timeout=3
        classical.cancel_collect_snapshot
        sleep    10
        os.Copy File    /home/ute/results/snapshot/*partial.zip    /home/ute/results/snapshot_dest/Snapshot_partial.zip
        sleep    15
        ${troubleshootinglog_file_2}=    file_ex    /home/ute/results/snapshot_dest/Snapshot_partial.zip    runtime_DEFAULT.log
        Run Keyword And Ignore Error    Should Be True    '${troubleshootinglog_file_2}'=='False'
        
        sleep    10
        Netconf File Collection
        Netconf_Message_validation
        delete_files_netconf
        sleep    60
        Log To Console    Snapshot collection
        ${snapshot3}=    classical.collect_snapshot    snapshot_waiting_timeout=120
        os.Copy File    ${snapshot3}	/home/ute/results/snapshot_dest/Snapshot3.zip
        ${troubleshootinglog_file_3}=    file_ex    /home/ute/results/snapshot_dest/Snapshot3.zip    runtime_DEFAULT.log
        Should Be True    '${troubleshootinglog_file_3}'=='True'
        sleep    10
        Netconf File Collection
        Netconf_Message_validation
        delete_files_netconf
        soam.Logout
        soam.close_browser
		
Test Teardown
    Log to console   \n--Tear down-End Test--\n
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    Run Keyword If Test Failed       Collect mandatory logs on ClassicalBts        log_dir=${LOG_PATH}

Common_Precondition
    Docker Container Setup
    ADMIN Perform Commissioning    bts_id=1
    ...                            scf_file=${SCF_PATH}/SCF_NR_FDD.xml
    Wait Until Mplane Is Connected
    Check If Gnb Is In On Air State And If Cell Is Enabled

Docker Container Setup
    Create SSH Session To Docker
    SSHLibrary.write    /root/start.sh
    SSHLibrary.Read Until         root@
    SSHLibrary.Write    supervisorctl status
    ${output}           SSHLibrary.Read Until         root@
    Log To Console      ${\n}Container created
    [Teardown]  Clear SSH Session To Docker

Configure Default Netconf Account
    selenium.add_oru_account    60
    selenium.configure_bts_level    cipher='true'    auth_method='NoAuthentication'    timeout=10
    selenium.configure_default_netconf_account    ${oru_name}    ${DEFAULT_ACCOUNT_NAME}    ${DEFAULT_ACCOUNT_PASS}
    ...    ${DEFAULT_ACCOUNT_PASS}
    selenium.send_netconf_configuration

Create SSH Session To Docker
    [Arguments]    ${oran_sim_host_ip}=${ORU_SIM_IP}
    ...            ${alias}=${oran_alias}
    ${oran_sim_host}    Set Variable     ${oran_sim_host_ip}
    Set Global Variable     ${oran_sim_host}
    SSHLibrary.Open Connection
    ...   host=${oran_sim_host}
    ...   alias=${alias}
    ...   timeout=180
    SSHLibrary.Login
    ...   username=inbabtslabuser
    ...   password=BT5l@bus3rl0g1n
    SSHLibrary.Write    sudo su
    SSHLibrary.Read Until    sudo
    SSHLibrary.Write    BT5l@bus3rl0g1n
    SSHLibrary.Read Until    root@
    SSHLibrary.Set Client Configuration        timeout=60
    SSHLibrary.Switch Connection     ${oran_alias}

Clear SSH Session To Docker
    [Arguments]    ${alias}=${oran_alias}
    Run Keyword And Ignore Error  SSHLibrary.Switch Connection  ${alias}
    Run Keyword And Ignore Error  SSHLibrary.Close Connection

Send Cmd To Docker Shell
    [Arguments]    ${cmd}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until         root@
    SSHLibrary.write    ${cmd}
    [Teardown]  Clear SSH Session To Docker

Verify Access Group Created
    ${message}=    Check Message In Netconf Trace File    ${NETCONF_MESSAGE}
    Should Contain    ${message}    ${NETCONF_MESSAGE}
    Should Contain    ${message}    <ok/></rpc-reply>

Check Logged In With Additional Account
    ${message}=    Check Message In Netconf Trace File    Password authentication (host "172.22.0.2", user "xranuser2").
    Should Contain    ${message}    Password authentication (host "172.22.0.2", user "xranuser2").
    Should Contain    ${message}    Authentication successful

Check SSH Session Closed After Configuration
    ${message_id}=    Check Message Id    ${NETCONF_MESSAGE}
    ${message_id_close}=    Check Message Id    <close-session xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"/></rpc>
    Should Be True    ${message_id} < ${message_id_close}

Generate New SSH Public Key
    ${output}=    Send Cmd To Docker Shell    /opt/dev/script/update_hostkey.sh
    ${warning}=    Run Keyword And Return Status
    ...    Should Contain    ${output}    [WRN]
    Run Keyword If    ${warning}
    ...    Send Cmd To Docker Shell    /opt/dev/script/update_hostkey.sh

Check Unsecure Ciphers Field
    Wait Until Element Is Visible    locator=${UNSECURE_CIPHERS}
    Click Element    locator=${UNSECURE_CIPHERS}
    Wait Until Element Is Visible    locator=//span[contains(text(),'false')]
    Wait Until Element Is Visible    locator=//span[contains(text(),'true')]
    Click Element    locator=//span[contains(text(),'false')]

Check SSH Auth Methods
    Wait Until Element Is Visible    locator=${SSH_AUTH_METHOD}
    Click Element    locator=${SSH_AUTH_METHOD}
    Wait Until Element Is Visible    locator=//span[contains(text(),'No authentication')]
    Wait Until Element Is Visible    locator=//span[contains(text(),'Public key based')]
    Wait Until Element Is Visible    locator=//span[contains(text(),'Deactivation of SSH')]
    Click Element    locator=//span[contains(text(),'No authentication')]

Click Deactivate SSH Validation
    Wait Until Element Is Visible    locator=${SSH_AUTH_METHOD}
    Click Element    locator=${SSH_AUTH_METHOD}
    Wait Until Element Is Visible    locator=//span[contains(text(),'Deactivation of SSH')]
    Click Element    locator=//span[contains(text(),'Deactivation of SSH')]

Delete Current Netconf Account
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(), 'SSDORU-1')]
    ...    timeout=20
    Click Element    locator=${TRASH_BUTTON}
    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
    Click Element    locator=${SEND_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
    ...                              timeout=90

Switch To No SSH Auth
    Wait Until Element Is Visible    locator=${SSH_AUTH_METHOD}
    Click Element    locator=${SSH_AUTH_METHOD}
    Wait Until Element Is Visible    locator=//span[contains(text(),'No authentication')]
    Click Element    locator=//span[contains(text(),'No authentication')]
    Wait Until Element Is Visible    locator=//span[contains(text(),'Continue')]
    ...                              timeout=20
    Click Element    locator=//span[contains(text(),'Continue')]

Deactivate SSH Public Key Validation
    Click Deactivate SSH Validation
    ${account_configured}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//span[contains(text(), 'SSDORU-1')]
    ...    timeout=20
    Run Keyword If    '${account_configured}' == 'True'    Run Keyword    Click Element    locator=${TRASH_BUTTON}
    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
    Click Element    locator=${SEND_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
    ...                              timeout=90

Remove Netconf Accounts From Gnb Using Webem
    Clear Netconf Account Configuration
    ADMIN Reset Site
    ADMIN Assert All Bbmods Are In Enabled State    timeout=180

Clear Netconf Account Configuration
    Prepare Environment
    Login To Web Element Manager
    Go To Netconf Radio Management Tab
    ${account_configured}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//span[contains(text(), 'SSDORU-1')]
    ...    timeout=20
    Run Keyword If    '${account_configured}' == 'True'    Run Keyword    Click Element    locator=${TRASH_BUTTON}
    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
    Click Element    locator=${SEND_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
    ...                              timeout=90

Go To Netconf Radio Management Tab
    Wait Until Element Is Visible   locator=${CONFIGURATION_TAB}
    Click Element   locator=${CONFIGURATION_TAB}
    Mouse Over  locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
    Click Element   locator=${NETCONF_RADIO_MANAGEMENT_BUTTON}
    Wait Until Element Is Visible    locator=${ACCOUNTS_CONFIGURATION}

Check Remove Additional Account
    Wait Until Element Is Visible    locator=${ACCOUNT_REMOVE_BUTTON}
    Click Element    locator=${ACCOUNT_REMOVE_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}
    Click Element    locator=${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}
    Wait Until Element Is Visible    locator=//div[contains(text(),'Additional netconf account')]
    Input Text    locator=additional-netconf-account-name
    ...           text=${ADDITIONAL_ACCOUNT_NAME}
    Input Password   locator=additional-netconf-account-pwd
    ...              password=${ADDITIONAL_ACCOUNT_PASS}
    Input Password   locator=confirm-additional-netconf-account-pwd
    ...              password=${ADDITIONAL_ACCOUNT_PASS}

Configure Additional Netconf Account In Webem
    [Arguments]    ${name}=${ADDITIONAL_ACCOUNT_NAME}
    ...            ${password}=${ADDITIONAL_ACCOUNT_PASS}
    ...            ${check_remove}=False
    ${account_configured}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//span[contains(text(), 'SSDORU-1')]
    ...    timeout=20
    Run Keyword If   '${account_configured}' == 'False'   Run Keyword   Configure Default Netconf Account In Webem Without Sending The Configuration
    Click Element
    ...    locator=//span[contains(text(), 'SSDORU-1')]
    Wait Until Element Is Visible    locator=${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}
    Click Element    locator=${CONFIGURE_ADDITIONAL_ACCOUNT_BUTTON}
    Wait Until Element Is Visible    locator=//div[contains(text(),'Additional netconf account')]
    Input Text    locator=additional-netconf-account-name
    ...           text=${name}
    Input Password   locator=additional-netconf-account-pwd
    ...              password=${password}
    Input Password   locator=confirm-additional-netconf-account-pwd
    ...              password=${password}
    Run Keyword If    ${check_remove}    Run Keyword    Check Remove Additional Account
    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
    Click Element    locator=${SEND_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
    ...                              timeout=90

Configure Default Netconf Account In Webem Without Sending The Configuration
    [Arguments]    ${name}=${DEFAULT_ACCOUNT_NAME}
    ...            ${password}=${DEFAULT_ACCOUNT_PASS}
    Click Element    ${PLUS_BUTTON_TRUNK}
    Wait Until Element Is Visible    locator=//span[contains(text(),'Default netconf account')]
    Input Text    locator=account-name
    ...           text=${name}
    Input Password   locator=account-pwd
    ...              password=${password}
    Input Password   locator=confirm-account-pwd
    ...              password=${password}

Configure Default Netconf Account In Webem
    [Arguments]    ${name}=${DEFAULT_ACCOUNT_NAME}
    ...            ${password}=${DEFAULT_ACCOUNT_PASS}
    ...            ${disable_ssh_auth}=False
    Run Keyword If    ${disable_ssh_auth}
    ...    Click Deactivate SSH Validation
    Click Element    ${PLUS_BUTTON_TRUNK}
    Wait Until Element Is Visible    locator=//span[contains(text(),'Default netconf account')]
    Input Text    locator=account-name
    ...           text=${name}
    Input Password   locator=account-pwd
    ...              password=${password}
    Input Password   locator=confirm-account-pwd
    ...              password=${password}

    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
    Click Element    locator=${SEND_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
    ...                              timeout=20

Configure Default Netconf Account In Webem With SSH Auth
    [Arguments]    ${name}=${DEFAULT_ACCOUNT_NAME}
    ...            ${password}=${DEFAULT_ACCOUNT_PASS}
    Wait Until Element Is Visible    locator=${SSH_AUTH_METHOD}
    Click Element    locator=${SSH_AUTH_METHOD}
    Wait Until Element Is Visible    locator=//span[contains(text(),'Public key based')]
    Click Element    locator=//span[contains(text(),'Public key based')]
    Wait Until Element Is Visible    locator=//span[contains(text(),'Continue')]
    ...                              timeout=20
    Click Element    locator=//span[contains(text(),'Continue')]
    Click Element    ${PLUS_BUTTON_TRUNK}
    Wait Until Element Is Visible    locator=//span[contains(text(),'Default netconf account')]
    Input Text    locator=oru-targerDN
    ...           text=${RMOD_PATH}
    Input Text    locator=ssh-server-host-public-key-format-identifier
    ...           text=RSA
    ${rsa_key}=    OperatingSystem.Get File    ${RSA_FILE}
    Input Text    locator=ssh-server-host-public-key-value
    ...           text=${rsa_key}
    Input Text    locator=account-name
    ...           text=${name}
    Input Password   locator=account-pwd
    ...              password=${password}
    Input Password   locator=confirm-account-pwd
    ...              password=${password}

    Wait Until Element Is Enabled    locator=${SEND_BUTTON}    timeout=20
    Click Element    locator=${SEND_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIGURE_RADIO_SUCCEEDED}
    ...                              timeout=20


Login To Web Element Manager
    [Arguments]    ${login}=${CUSTOMER_LOGIN}
    ...            ${password}=${CUSTOMER_PASSWORD}
    Set Selenium Implicit Wait    5
    Open Browser    ${WebEM IP}    Chrome
    Check Privacy Error
    Proceed Unsafe Connection
    Run Keyword And Ignore Error    Maximize Browser Window
    Input Text    locator=${INPUT_NAME_FIELD}
    ...           text=${login}
    Input Password    locator=${INPUT_PASSWORD_FIELD}
    ...               password=${password}
    Click Element   locator=${LOGIN_BUTTON}
    #Wait Until Element Is Visible    locator=${CONFIRM_BUTTON}    timeout=200
    Click Element    locator=${CONFIRM_BUTTON}
    Close BTS Startup View

Prepare Environment
    Set Plus Button Based On The Release
    Chmod Chromedriver
    Run Xvfb
    Export DISPLAY

Chmod Chromedriver
    os.Run  sudo chmod +x /usr/bin/chromedriver

Run Xvfb
    Start Process  /usr/bin/Xvfb :99 -screen 0 1920x1080x16   shell=yes

Export DISPLAY
    Set Environment Variable  DISPLAY  :99

Teardown Environment
    Close All Browsers
    Terminate All Processes

Set Plus Button Based On The Release
    ${status}=    Run Keyword And Return Status    Should Contain Any    ${OUT_ACTIVE_SW}    22R2
    Run Keyword If    ${status}    Set Suite Variable    ${PLUS_BUTTON}    ${PLUS_BUTTON_22R2}
    Run Keyword Unless    ${status}    Set Suite Variable    ${PLUS_BUTTON}    ${PLUS_BUTTON_TRUNK}

Close BTS Startup View
    ${close}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//button[contains(text(),'Close')]
    ...    timeout=100
    Run Keyword If    '${close}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Close')]

Check Privacy Error
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="main-message"]/h1
    ...                                           timeout=30
    ${privacy_error}    Run Keyword If    ${status}    Get Text    locator=//*[@id="main-message"]/h1
    ${privacy_error}    Run Keyword And Return Status    Should Contain    ${privacy_error}    is not private
    Run Keyword If    ${privacy_error}    Proceed Unsafe Connection

Proceed Unsafe Connection
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="details-button"]
    ...                                           timeout=30
    Run Keyword If    ${status}    Click Element  xpath=//*[@id="details-button"]
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="proceed-link"]
    ...                                           timeout=30
    Run Keyword If    ${status}    Click Element  xpath=//*[@id="proceed-link"]

Open Details Panel If Is Closed
    ${DetPanelOpen}    Run Keyword And Return Status    Page Should Not Contain Element
    ...    locator=//wf-panel[@class="details-panel view-panel ng-isolate-scope ng-hide"]
    ${DetPanelClose}    Run Keyword And Return Status    Page Should Contain Element
    ...    locator=//wf-panel[@class="details-panel view-panel ng-isolate-scope ng-hide"]
    Run Keyword If    ${DetPanelClose}    Click Element
    ...    locator=//ui-button[@class="show-panel-button ng-scope ng-isolate-scope ui-tooltip-source"]
    Log    DetPanelOpen=${DetPanelOpen} DetPanelClose=${DetPanelClose}

Get Parameters
    [Arguments]    ${parameter}
    ...            ${dist_name}
    ${out_parameters_dict}    taf.sbts.oam.coam.admin.Get Parameters
    ...             dist_name=${dist_name}
    ...    pattern=${parameter}
    ...            ${alias}=admin_1
    ...    timeout=20
    [Return]    ${out_parameters_dict}

Get Rmod Id
    ${rmod_id}    ADMIN Get Id For Current    RMOD
    ${dist_name_string}    Convert To String    ${rmod_id}
    ${dist_name}    Get Substring    ${dist_name_string}    2    -2
    Set Global Variable    ${dist_name}

Check MPlaneLink Status
    ${act_mPlane}   Check Parameter Under RMOD    RU M-Plane link status
    [Return]    ${act_mPlane}

Check Parameter Under Rmod
    [Arguments]    ${parameter}
    ${out_parameters_dict}    Get Parameters    ${parameter}    ${dist_name}
    ${parameter_status}   Set Variable    ${out_parameters_dict}[${parameter}]
    [Return]    ${parameter_status}

Wait Until Mplane Is Connected
    [Arguments]    ${timeout}=200
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=${timeout}
    Get Rmod Id
    #Wait Until Keyword Succeeds
    #...                           ${timeout}
    #...                           5
    #...                           Assert Mplane Connected
    Log    \n+ MPlane is Connected    console=yes

Assert Mplane Connected
    ${mplane_status}     Check MPlaneLink Status
    Should Be Equal As Strings    ${mplane_status}
    ...                           Connected

Copy Xml To Container
    [Arguments]  ${local_path_to_file}
    ...          ${file_name}
    ...          ${destination_path}=${XML_DOCKER_PATH}
    ...          ${docker_name}=${DOCKER_NAME}
    ${xml_file}    Run    cat ${local_path_to_file}/${file_name}
    Create SSH Session To Docker
    SSHLibrary.Read Until    plwr
    SSHLibrary.write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until    root@
    SSHLibrary.Write     ls ${destination_path}
    ${files_in_directory}    SSHLibrary.Read Until    root@
    ${is_file_exist}    BuiltIn.Run keyword and return status    Should Contain
    ...    ${files_in_directory}
    ...    ${file_name}
    Run Keyword If     ${is_file_exist}
    ...              SSHLibrary.write    rm ${destination_path}/${file_name}
    SSHLibrary.write    touch ${destination_path}/${file_name}
    SSHLibrary.Read Until    root@
    SSHLibrary.write    echo '${xml_file}' >> ${destination_path}/${file_name}
    SSHLibrary.Read Until    root@
    [Teardown]  Clear SSH Session To Docker

ORAN Preconditions
    Test Preconditions Without WTSSIM S1
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    Set Path In Infomodel

Check Message Id
    [Arguments]    ${message_to_grep}
    ...            ${grep_option}=head -n 1
    ...            ${remote_file_path}=${NETCONF_TRACE_REMOTE_PATH}
    ...            ${local_file_path}=${NETCONF_TRACE_LOCAL_PATH}
    SYSTEM Open SSH Connection To Enb
    SYSTEM Get File From Enb Over Ssh    ${remote_file_path}
    ...                                  ${local_file_path}
    ${output}   Run    grep -n '${message_to_grep}' ${local_file_path} | ${grep_option}
    ${output_1}    Fetch From Left    ${output}    "><
    ${output_2}    Fetch From Right    ${output_1}    message-id=
    ${message_id}    Fetch From Right    ${output_2}    "
    [Return]   ${message_id}
    [Teardown]    SYSTEM Close SSH Connection To Enb

Set Path In Infomodel
    ${position}=    ADMIN Get Smod Position
    Run Keyword If    '${position}' == 'left'    Run Keywords
        ...    Set Global Variable    ${EQM_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1    AND
        ...    Set Global Variable    ${MRBTS_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1    AND
        ...    Set Global Variable    ${BTS_L_PATH}    /MRBTS-1/RAT-1/BTS_L-1    AND
        ...    Set Global Variable    ${NRTS_PATH}    /MRBTS-1/RAT-1/NRTS-1
    ...    ELSE IF    '${position}' == 'right'    Run Keywords
        ...    Set Global Variable    ${EQM_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4    AND
        ...    Set Global Variable    ${MRBTS_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4    AND
        ...    Set Global Variable    ${BTS_L_PATH}    /MRBTS-1/RAT-1/BTS_L-4    AND
        ...    Set Global Variable    ${NRTS_PATH}    /MRBTS-1/RAT-1/NRTS-4

Reset Site And Prepare Oru
    ADMIN Perform Commissioning    bts_id=1
    ...                            scf_file=${SCF_PATH}/SCF_NR_FDD.xml
    Docker Container Setup
    Wait Until Mplane Is Connected

Assert Mrbts Is In Onair State
    [Arguments]    ${timeout}=50
    ...            ${alias}=admin_1
    ${mrbts_state}    taf.sbts.oam.coam.admin.Get Mrbts State    timeout=${timeout}
    ...                                        alias=${alias}
    Should Contain    ${mrbts_state}    OnAir

Check If Gnb Is In On Air State And If Cell Is Enabled
    Assert All NRCells Are In Expected State    operationalState    regex"Enabled|enabled"    timeout=70
    Assert Mrbts Is In Onair State

Assert All NRCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=NRCEL

Send Cmd By Netopeer Cli
    [Arguments]    ${cmd}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until         root@
    SSHLibrary.write   rm -f /home/cmd.txt
    SSHLibrary.write   echo connect --ssh --login netconf --host 127.0.0.1 --port 830 > /home/cmd.txt
    SSHLibrary.write   echo ${cmd} >> /home/cmd.txt
    SSHLibrary.write   netopeer2-cli < /home/cmd.txt
    ${res}  ${outp}    Run Keyword And Ignore Error
    ...                SSHLibrary.Read Until     Password:
    Run Keyword If     '${res}' == 'PASS'
    ...                SSHLibrary.write          netconf
    ...  ELSE IF       '${res}' == 'FAIL'        Run Keywords
    ...                SSHLibrary.write          yes
    ...  AND           SSHLibrary.Read Until     Password:
    ...  AND           SSHLibrary.write          netconf
    ${res}  ${outp}    Run Keyword And Ignore Error
    ...                SSHLibrary.Read Until     root@
    Return From Keyword If  '${res}' == 'PASS'   ${outp}
    SSHLibrary.write   yes
    ${output}          SSHLibrary.Read Until     root@
    [Return]  ${output}
    [Teardown]  Clear SSH Session To Docker

Check Message In Netconf Trace File
    [Arguments]    ${message_to_grep}
    ...            ${remote_file_path}=${NETCONF_TRACE_REMOTE_PATH}
    ...            ${local_file_path}=${NETCONF_TRACE_LOCAL_PATH}
    SYSTEM Open SSH Connection To Enb
    SYSTEM Get File From Enb Over Ssh    ${remote_file_path}
    ...                                  ${local_file_path}
    ${output}   Run    grep -A1 '${message_to_grep}' ${local_file_path}
    [Return]    ${output}
    [Teardown]    SYSTEM Close SSH Connection To Enb

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Wait Until Keyword Succeeds    2min    10s    Link SCOUT SCF to Configuration ID for Reporting   
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}


Link SCOUT SCF to Configuration ID for Reporting
    ${scout_testline_name}=    Run    hostname
    [Documentation]    :Author: Mallikarjuna 
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    ${list}=    Split String    ${scout_testline_name}    -
    ${scout_testline_name}=    Evaluate    "_".join(${list})
    log    ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${TC_ID}=   scout.request_scf   use_scout_internal_id=${True}
    scout.teardown_scout_api
    ${TC_ID}    set variable    ute:id:${TC_ID}
    Set Tags  ${TC_ID}
    Sleep    120s
