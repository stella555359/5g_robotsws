*** Settings ***
Documentation
...    Author: challa.ravali@nokia.com
...    Maintainer: challa.ravali@nokia.com
...    Test Description: This feature is firstly supported in ASIL + APoABIO to introduce the general Nokia
...    world market O-RAN compliant O-CDU with FDD eCPRI interface (CAT-A) for FDD NR or FDD LTE.
...    Subitem -C is related to O-RAN V5.0 improvements with the use of 3rd party RU.
...    Confluence link: link
...    Group in charge: I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD_GMS <I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD@internal.nsn.com>
...    References: ToDo
...    QualityCenter: ToDo
...    Sample execution: robot -d /home/ute/logs -T /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG02/CB008205-C/general.robot
...    Review: -
...    AC/REQ: OAM_REQ_RADIO_801, OAM_REQ_RADIO_904, OAM_REQ_RADIO_913, OAM_REQ_RADIO_914, OAM_REQ_RADIO_916,
...    OAM_REQ_RADIO_918, OAM_REQ_RADIO_924, OAM_REQ_RADIO_973, OAM_REQ_WEBEM_1029, OAM_REQ_WEBEM_1032,
...    OAM_REQ_WEBEM_1035, OM_SFS_GEN_FM.3209, OM_SFS_GEN_FM.3255, OAM_REQ_RADIO_801_1, OAM_REQ_RADIO_913_1,
...    OAM_REQ_RADIO_914_1, OAM_REQ_RADIO_916_1, OAM_REQ_RADIO_918_1, OAM_REQ_RADIO_973_1, OAM_REQ_WEBEM_1035_1,
...    OAM_REQ_WEBEM_1029_1, OAM_REQ_WEBEM_1032_1, OAM_REQ_RADIO_904_1, OAM_REQ_RADIO_924_1, OM_GEN_SFS_FM.3209_1,
...    OM_GEN_SFS_FM.3255_1

Library    SSHLibrary
Library    BuiltIn
Library    SeleniumLibrary
Library    Process
Library    ute_fsmaccess
Library    DateTime
Library    Collections
Library    FtpLibrary
Library    OperatingSystem
Library    Screenshot
Library    String
Library    Telnet
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.sbts.oam.coam.admin
Library    taf.config.scf   WITH NAME  scf
Library    taf.sw.scout    WITH NAME    scout

Library     ./testsuite/Bangalore/ORAN/SG02/resources/python/swconfig_recommended.py
Library     ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/admin_infomodel.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/pretest_posttest.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/system.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/ORAN.robot
Resource    ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/selenium_keywords.robot

*** Variables ***
@{ALLOWED_ALARMS}    &{4592}    &{10_allowed}    &{4729_allowed}    &{4720}    &{7305}    &{7523}    &{7107}    &{6450}    &{7107_Critical}
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
&{10_allowed}     fault_id=10
...         alarm_id=7116
...         alarm_severity=Critical
...         notifier=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="No connection to unit"
&{10}     fault_id=10
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="No connection to unit"
&{4720}     fault_id=4720
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="Mismatch of RU reported capabilities with static HW Validation information"
...         notifier=[1] MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-1
&{7305}     fault_id=7305
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="NG SCTP setup fail"
...         notifier=[1] MRBTS-1/NRBTS-1/SERVEDAMF-1
&{7523}     fault_id=7523
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="Cell Activation timeout at gNB-DU"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-1
&{7107}     fault_id=7107
...         alarm_id=7114
...         alarm_severity=Major
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-1
&{7107_Critical}     fault_id=7107
...         alarm_id=7114
...         alarm_severity=Critical
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=[1] MRBTS-1/NRBTS-1/NRCELL-1
&{6450}     fault_id=6450
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="Diagnostic Files collected"
...         notifier=[1] MRBTS-1/EQM-1/APEQM-1/CABINET-1/SMOD-1

${RSA_FILE}=                            ./testsuite/Bangalore/ORAN/SG02/CB008205-C/configurations/rsa.pub
${oran_alias}=                          oran_sim
${DOCKER_NAME}=                         orusim
${Docker_user_name}			    inbabtslabuser
${Docker_password}			    BT5l@bus3rl0g1n
${NETCONF_TRACE_REMOTE_PATH}=           /tmp/node_FHNET80/tmp/RMOD_L-1_NetconfRpcMessageTrace_0.log
${NETCONF_TRACE_LOCAL_PATH}=            /home/ute/Downloads/RMOD_L-1_NetconfRpcMessageTrace.log
${CONFIGURATION}=                   //div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
${XML_DOCKER_PATH}=                     /home
${EDIT_CMD}=                            edit-config --target running --config=/home/
${RPC_CMD}=                             user-rpc --content /opt/dev/xml
${ORU_SIM_IP}=                          10.42.17.69
${SCF_PATH}=                            ./testsuite/Bangalore/ORAN/SG02/CB008205-C/configurations
${WebEM IP}                             https://192.168.255.1:3600
${url}                                  https://192.168.255.129
${browser}                              Chrome
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${INPUT_NAME_FIELD}=                    login-username
${INPUT_PASSWORD_FIELD}=                login-password
${oru_name}                             SSDORU-1
${DEFAULT_ACCOUNT_NAME}=    xranuser
${DEFAULT_ACCOUNT_PASS}=    xran-password
${ADDITIONAL_ACCOUNT_NAME}=    xranuser2
${ADDITIONAL_ACCOUNT_PASS}=    Xran-Password11!!
${RMOD_PATH}=    MRBTS-1/EQM-1/APEQM-1/RMOD-1
${NETCONF_MESSAGE1}=    <config><nacm xmlns="urn:ietf:params:xml:ns:yang:ietf-netconf-acm"><groups><group><name>####</name>
${NETCONF_MESSAGE2}=    <user-name>xranuser2</user-name></group></groups></nacm></config>
${SCF_FILE}						        ${CURDIR}/../configurations/SANSA_scf_ofgesa_cloud.xml
${DELTA_FILE_OLD} 				        ${CURDIR}/../configurations/vlanid_old.json
${DELTA_FILE_NEW}	        	        ${CURDIR}/../configurations/vlanid_new.json
${INSTALL_OFGESA}				        ${CURDIR}/../configurations/5G_install_ofgesa.sh
${X2LINK}		 				        ${CURDIR}/../configurations/x2link.sh
${XML_FILES_PATH}                             ./testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/Airphone_backdoor_commands
${lxc_id}=    0x551a
${ABIO_RPC_cmd}                 user-rpc --content /tmp/
${ORU_container_path}           /tmp/node_${ORU_ID}
${ORU_ID}                       ORU01
#${version}       SBTS24R2
${sw_config_recommended}=    /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG02/resources/python/swconfig_recommended_8205.txt
${sw_release}
${results_dir}
${timeout}
${APOABIO_IP}=    192.168.200.1
${APOABIO_user}=    oru01
${host}             127.0.0.1
${username}         ute
${password}         Utepassword@1
${cmd_TC04}             SEPARATOR=
...    active-alarm-test-list active-alarms[1]/fault-name=test_alarm1500 active-alarms[1]/
...    fault-id=1500 active-alarms[1]/fault-source=OFGESA active-alarms[1]/affected-objects[1]/
...    name=Object1 active-alarms[1]/affected-objects[2]/name=Object2 active-alarms[1]/
...    affected-objects[3]/name=Object3 active-alarms[1]/fault-severity=MINOR active-alarms[1]/
...    is-cleared=false active-alarms[1]/fault-text=alarm1 active-alarms[1]/event-time=2020-08-13T15:13:28+02:00

*** Keywords ***
TC_01_Access group configuration during O-RU startup
    swConfig    swconfigfile=${sw_config_recommended}
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=700
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    Login To Web Element Manager    ${url}    ${CUSTOMER_LOGIN}    ${CUSTOMER_PASSWORD}
    ...            ${sw_release}    ${browser}
    CB008205-C.Configure Additional Netconf Account
    CB008205-C.Wait Until Mplane Is Connected
    Sleep    120s
    Verify Access Group Created
    Check Logged In With Additional Account
    Check SSH Session Closed After Configuration

TC_02_SSD configuration for Netconf radio WebEM support
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    Login To Web Element Manager    ${url}    ${CUSTOMER_LOGIN}    ${CUSTOMER_PASSWORD}
    ...            ${sw_release}    ${browser}
    Configure Default Netconf Account In Webem With SSH Auth
    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    #Teardown Environment


TC_04_Vendor_specific_fault_simulation_on_O-RU
    ${Cell_is_onair}=    Run Keyword And Return Status    ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
    Run Keyword If   '${Cell_is_onair}' == 'False'   Run Keyword   Prepare_Testline_with_OFGESA
    Trigger Fault 1500 With Severity Minor
    Assert Fault 1500
    Login To Web Element Manager    ${url}    ${CUSTOMER_LOGIN}    ${CUSTOMER_PASSWORD}
    ...            ${sw_release}    ${browser}
    Site reset along with x2 link creation
    CB008205-C.Wait Until Mplane Is Connected    timeout=300
    ADMIN Assert Alarm Inactive    fault_id=1500    alarm_id=7240    alarm_severity=Minor    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name="alarm1"


Link SCOUT SCF to Configuration ID for Reporting
    ${scout_testline_name}=    Run    hostname
    [Documentation]    :Author: Mallikarjuna 
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    ${list}=    Split String    ${scout_testline_name}    -
    ${scout_testline_name}=    Evaluate    "_".join(${list})
    log    ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${TC_ID}=   scout.request_scf   use_scout_internal_id=${True}
    scout.teardown_scout_api
    ${TC_ID}    set variable    ute:id:${TC_ID}
    Set Tags  ${TC_ID}
    Sleep    120s

Test Teardown
    Collect SOS report
    CB008205-C.Collect Snapshot


Collect SOS report
    Run     chmod 777 /opt/iphy/latest/sosReport_ASIL/sosReport_ASIL.sh
    ${output} =    OperatingSystem.Run    pwd
    Run     sudo rm ${output}/SosReport*_UEAPP1.tgz
    Run     /opt/iphy/latest/sosReport_ASIL/sosReport_ASIL.sh
    Wait Until Created    ${output}/SosReport*_UEAPP1.tgz    400s
    Run     sudo cp ${output}/SosReport*_UEAPP1.tgz ${out}

Collect Snapshot
    taf.sbts.oam.coam.admin.collect_snapshot    target_file_name=${out}/Snapshotfile.zip    connection=suite


Copy Xml And Send Cmd to ORU
    [Arguments]    ${file}      ${path}
    Copy Xml And Send Cmd By Netopeer Cli to APOABIO    ${file}    ${path}

Trigger Fault 1500 With Severity Minor
        Create SSH Session To ORU
        sleep    10

Create SSH Session To ORU
    SSHLibrary.Open Connection    ${host}        alias=APoabio
    SSHLibrary.Login    ${username}    ${password}    delay=1
    SSHLibrary.Execute Command    ssh oru01@192.168.200.1 ${cmd_TC04}
    #SSHLibrary.Switch Connection     ${oran_alias}

Prepare_Testline_with_OFGESA
    Check VlanId
    Log to console   \nPerforming Commissioning
    ADMIN INFOMODEL Wait Till CPLANE Will Be Ready To Perfom Commissioning
    ADMIN Perform Commissioning
        ...   scf_file=${SCF_FILE}
        ...   skip_parameter_relation_errors=${True}
        ...   bts_id=1
    log    ${sw_release}
    Login To Web Element Manager    ${url}    ${CUSTOMER_LOGIN}    ${CUSTOMER_PASSWORD}
    ...            ${sw_release}    ${browser}
    CB008205-C.Configure Default Netconf Account
    Install OFGESA RU
    ADMIN Assert All Rmods Are In Enabled State   timeout=900
    Change VlanId
    FOR    ${i}	   IN RANGE    5
        Sleep	2s
        CB008205-C WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=200
        Run Keyword If    ${status}    Exit For Loop
    END

Check VlanId
    ${vlanId}=    ADMIN INFOMODEL Get Infomodel Object And Return Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/TNLSVC_CONF_M-1/TNL_CONF_M-1/ETHSVC_CONF_M-1/ETHIF_CONF_M-*/VLANIF_CONF_M-1
    ...                                                                                parameter=vlanId
    ...                                                                                alias=infomodel_1
    ${vlanId_str}=    Convert to String    ${vlanId}
    ${json}=   OperatingSystem.Get File    ${DELTA_FILE_OLD}
    ${replace}=     Replace String    ${json}    10000    ${vlanId_str}
    Create File   ${CURDIR}/../configurations/vlanid_new.json      ${replace}

Install OFGESA RU
    Run    chmod +x ${INSTALL_OFGESA}
    Run    sh ${INSTALL_OFGESA}
    Log to console    \nInstalling OFGESA radio


Change VlanId
	ADMIN Perform Delta Recommissioning
        ...    delta_file=${DELTA_FILE_NEW}
        ...    skip_parameter_relation_errors=${True}

CB008205-C WTSSIM X2 Link Establish
     Run    chmod 777 ${X2LINK}
     Run    sh ${X2LINK}
     Log to console   \nEstablishing X2 link...

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
    ...   username=ute
    ...   password=@Utepassword1
    SSHLibrary.Write    ssh root@192.168.255.120
    SSHLibrary.Read Until    password:
    SSHLibrary.Write    uteadmin
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
    ${output}           SSHLibrary.Read Until         root@
    SSHLibrary.Read Until        root@
    [Return]  ${output}
    [Teardown]  Clear SSH Session To Docker

Verify Access Group Created
    ${NETCONF_MESSAGE}=    Catenate    SEPARATOR=    ${NETCONF_MESSAGE1}    ${NETCONF_MESSAGE2}
    ${message}=    CB008205-C.Check Message In Netconf Trace File    ${NETCONF_MESSAGE}
    Should Contain    ${message}    ${NETCONF_MESSAGE}
    Should Contain    ${message}    <ok/></rpc-reply>

Check Logged In With Additional Account
    ${message}=    CB008205-C.Check Message In Netconf Trace File    Password authentication (host "172.22.8.2", user "xranuser2").
    Should Contain    ${message}    Password authentication (host "172.22.8.2", user "xranuser2").
    Should Contain    ${message}    Authentication successful

Check SSH Session Closed After Configuration
    ${NETCONF_MESSAGE}=    Catenate    SEPARATOR=    ${NETCONF_MESSAGE1}    ${NETCONF_MESSAGE2}
    ${message_id}=    CB008205-C.Check Message Id    ${NETCONF_MESSAGE}
    ${message_id_close}=    CB008205-C.Check Message Id    <close-session xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"/></rpc>
    Should Be True    ${message_id} < ${message_id_close}

Generate New SSH Public Key
    ${output}=    Send Cmd To Docker Shell    /opt/dev/script/update_hostkey.sh
    ${warning}=    Run Keyword And Return Status
    ...    Should Contain    ${output}    [WRN]
    Run Keyword If    ${warning}
    ...    Send Cmd To Docker Shell    /opt/dev/script/update_hostkey.sh

FSM Access Close Connection
    [Arguments]    ${alias}=fsm_access
    Teardown Enb Fsm Access    alias=${alias}

Click Deactivate SSH Validation
    Wait Until Element Is Visible    locator=${SSH_AUTH_METHOD}
    Click Element    locator=${SSH_AUTH_METHOD}
    Wait Until Element Is Visible    locator=//span[contains(text(),'Deactivation of SSH')]
    Click Element    locator=//span[contains(text(),'Deactivation of SSH')]

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

Site reset along with x2 link creation
    taf.sbts.oam.coam.admin.Reset Site   timeout=600
    ...                     wait_for_reconnection=True
    ...                     detailed_output=false
    ...                     connection=${ADMIN_ALIAS}
    sleep    100   # sleep time is to wait for start up window after site reset
    ${start_up_window}=    start_up_view_window_exists
    Run Keyword If    ${start_up_window}==True    close_start_up_view_window
    #${RMOD_detetction}=    CB008205-C.Check MPlaneLink Status
    #Run Keyword Unless    ${RMOD_detetction}==Connected
    ADMIN Assert All Bbmods Are In Enabled State    timeout=600
    CB008205-C.Configure Default Netconf Account
    CB008205-C.Wait Until Mplane Is Connected    timeout=300
    FOR    ${i}	   IN RANGE    7
        CB008205-C WTSSIM X2 Link Establish
        ${status}=	Run Keyword And Return Status	ADMIN Assert All Cells Are In Enabled State    class_name=NRCEL    timeout=300
        Run Keyword If    ${status}    Exit For Loop
    END

Delete the additional netconf account
    selenium.add_oru_account    60
    selenium.delete_oru_account    ${oru_name}

Configure Default Netconf Account
    selenium.add_oru_account    60
    selenium.configure_default_netconf_account    ${oru_name}    ${DEFAULT_ACCOUNT_NAME}    ${DEFAULT_ACCOUNT_PASS}
    ...    ${DEFAULT_ACCOUNT_PASS}
    selenium.send_netconf_configuration

Configure Additional Netconf Account
    selenium.add_oru_account    60
    selenium.configure_default_netconf_account    ${oru_name}    ${DEFAULT_ACCOUNT_NAME}    ${DEFAULT_ACCOUNT_PASS}
    ...    ${DEFAULT_ACCOUNT_PASS}
    selenium.configure_additional_netconf_account    ${oru_name}    ${ADDITIONAL_ACCOUNT_NAME}    ${ADDITIONAL_ACCOUNT_PASS}
    ...    ${ADDITIONAL_ACCOUNT_PASS}
    selenium.send_netconf_configuration

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


Configure Default Netconf Account In Webem With SSH Auth
    ${rsa_key}=    OperatingSystem.Get File    ${RSA_FILE}
    selenium.configure_bts_level    false    Public key based
    selenium.add_oru_account    60
    selenium.configure_authentifier_ssh_server    ${oru_name}    RSA    ${rsa_key}   timeout=60
    selenium.configure_oru_target_distname    ${oru_name}    ${RMOD_PATH}    timeout=60
    selenium.configure_default_netconf_account    ${oru_name}    ${DEFAULT_ACCOUNT_NAME}    ${DEFAULT_ACCOUNT_PASS}
    ...    ${DEFAULT_ACCOUNT_PASS}
    selenium.send_netconf_configuration    timeout=60

Assert Fault 1500
    ADMIN Assert Alarm Active    fault_id=1500    alarm_id=7240    alarm_severity=Minor    alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    fault_name="alarm1"    timeout=30
    Log To Console    Fault 1500 visible
    #${object_dict}    taf.sbts.oam.coam.admin.Get Parameters    MRBTS-1/EQM_R-4/APEQM_R-1/RMOD_R-1
    #...    alias=${ADMIN_ALIAS}
    #${object_str}    Convert To String    ${object_dict}
    #Should Contain    ${object_str}    'faultId': 1500
    #Should Contain    ${object_str}    'faultType': 'VendorSpecific'
    #Should Contain    ${object_str}    'faultSeverity': 'Minor'
    #Should Contain    ${object_str}    'affectedObjects': ['Object 1', 'Object 2', 'Object 3']
    Run Keyword And COntinue On Failure    Assert Fault 1500 Does Not Contain Meaning And Instruction

Assert Fault 1500 Does Not Contain Meaning And Instruction
    Prepare Environment
    Login To Web Element Manager    ${url}    ${CUSTOMER_LOGIN}    ${CUSTOMER_PASSWORD}
    ...            ${sw_release}    ${browser}
    ${alarm_info}=    selenium.get_active_alarm_detailed_info    1500    60
    ${alarm_details}=    Get From Dictionary    ${alarm_info}    Alarm details
    LOG    ${alarm_details}
    Dictionary Should Not Contain key    ${alarm_details}    Meaning
    Dictionary Should Not Contain key    ${alarm_details}    Instruction
    ${alarm_str}    Convert To String    ${alarm_info}
    Should Contain    ${alarm_str}    'Fault ID/Name': '1500 alarm1'
    Should Contain    ${alarm_str}    'Severity': 'Minor'
    Should Contain    ${alarm_str}    'Extra info': 'Object1; Object2; Object3'
    Teardown Environment

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
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    alias=admin_1
    ...    timeout=20
    [Return]    ${out_parameters_dict}

Get Rmod Id
    ${rmod_id}    ADMIN Get Id For Current    RMOD
    ${dist_name_string}    Convert To String    ${rmod_id}
    ${dist_name}    Get Substring    ${dist_name_string}    2    -2
    Set Global Variable    ${dist_name}

Check MPlaneLink Status
    ${act_mPlane}   CB008205-C.Check Parameter Under Rmod    mPlaneLinkStatus
    [Return]    ${act_mPlane}

Check Parameter Under Rmod
    [Arguments]    ${parameter}
    ${out_parameters_dict}    CB008205-C.Get Parameters    ${parameter}    ${dist_name}
    ${parameter_status}   Set Variable    ${out_parameters_dict}[${parameter}]
    [Return]    ${parameter_status}

Wait Until Mplane Is Connected
    [Arguments]    ${timeout}=800
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=${timeout}
    CB008205-C.Get Rmod Id
    Wait Until Keyword Succeeds
    ...                           ${timeout}
    ...                           5
    ...                           CB008205-C.Assert Mplane Connected
    Log    \n+ MPlane is Connected    console=yes

Assert Mplane Connected
    ${mplane_status}     CB008205-C.Check MPlaneLink Status
    Should Be Equal As Strings    ${mplane_status}
    ...                           Connected

Add Default Netconf Account Without Teardown
    [Arguments]    ${url}    ${username}    ${password}
    ...            ${sw_release}    ${browser}    ${oru_name}    ${account_name}    ${account_pwd}
    ...            ${confirm_account_pwd}
	Login To Web Element Manager    ${url}    ${username}    ${password}    ${sw_release}    ${browser}
    selenium.configure_default_netconf_account    ${oru_name}    ${account_name}    ${account_pwd}
    ...    ${confirm_account_pwd}
	selenium.send_netconf_configuration
    Log    \n+ Default Netconf Account Added    console=yes

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
    CB008205-C.Set Path In Infomodel
    #swConfig    swconfigfile=${sw_config_recommended}
    #ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=700
    ${sw_release}=    taf.sbts.oam.coam.admin.get_sw_release_name    connection=suite

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

